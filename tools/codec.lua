-- =====================================================================
-- ToT Nexus | Remote-dump codec (TND2 format)
-- Single source of truth: used in-game by ImportTool.lua and locally by
-- tools/decode.lua. Pure Lua (no Roblox APIs) so it runs anywhere.
--
-- SPEC (stable -- do not change the format without bumping "TND2"):
--   Blob = "TND2:" + base64( lzss( compactText ) )
--   compactText structure (line by line):
--     1. header: "TND2|<gameName>|<placeId>|<universeId>|<dumped YYYY-MM-DD HH:MM>"
--     2. groups: a parent-path line "> <path>" followed by one line per remote
--        found under that path: "<E|F> <name>"  (E = RemoteEvent, F = RemoteFunction)
--        Path prefixes: "RS/" = game.ReplicatedStorage.
--                       "WS/" = workspace.
--                       "G/"  = game.  (anything else)
--     3. last line: "H <fnv1a>"  (32-bit FNV-1a hash, decimal, of all
--        preceding lines including newlines, excluding this line and its "\n")
--   Groups are sorted by path, names sorted within each group.
--   gameName may not contain "|" (encoder replaces with "/").
--
--   LZSS: window 2048, min match 3, max match 18.
--         A flag byte precedes each group of 8 tokens, bits used MSB first.
--         flag bit 1 = literal: 1 data byte follows.
--         flag bit 0 = match:   2 data bytes follow.
--             byte1 = (dist-1) & 0xFF                      (dist = 1..2048)
--             byte2 = ((dist-1) >> 8) * 16 + (length - 3)  (length = 3..18)
--             match source = current output length - dist + 1, byte-by-byte
--             copy in order (overlap/RLE allowed).
--
--   Base64: standard alphabet A-Za-z0-9+/ with "=" padding.
-- =====================================================================

local M = {}

-- ==========================================================================
-- Base64
-- ==========================================================================
local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function M.b64encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local remaining = math.min(3, #data - i + 1) -- bytes in this group: 1..3
        local b1 = data:byte(i)
        local b2 = remaining >= 2 and data:byte(i + 1) or 0
        local b3 = remaining >= 3 and data:byte(i + 2) or 0
        local n = b1 * 65536 + b2 * 256 + b3
        out[#out + 1] = B64CHARS:sub(math.floor(n / 262144) % 64 + 1, math.floor(n / 262144) % 64 + 1)
        out[#out + 1] = B64CHARS:sub(math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1)
        out[#out + 1] = remaining >= 2 and B64CHARS:sub(math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1) or "="
        out[#out + 1] = remaining >= 3 and B64CHARS:sub(n % 64 + 1, n % 64 + 1) or "="
    end
    return table.concat(out)
end

function M.b64decode(s)
    if type(s) ~= "string" then return nil, "not a string" end
    s = s:gsub("%s", "")
    local body = s:gsub("=+$", "")
    if #body % 4 == 1 then
        return nil, "damaged (body length " .. #body .. " is impossible for base64)"
    end
    if #s - #body > 2 then
        return nil, "damaged (too much padding)"
    end

    local lookup = {}
    for i = 1, #B64CHARS do
        lookup[B64CHARS:sub(i, i)] = i - 1
    end
    local out = {}
    local n = 0
    local count = 0
    for i = 1, #body do
        local v = lookup[body:sub(i, i)]
        if not v then
            return nil, "damaged (invalid character at position " .. i .. ")"
        end
        n = n * 64 + v
        count = count + 1
        if count == 4 then
            out[#out + 1] = string.char(math.floor(n / 65536) % 256)
            out[#out + 1] = string.char(math.floor(n / 256) % 256)
            out[#out + 1] = string.char(n % 256)
            n, count = 0, 0
        end
    end
    if count == 2 then
        out[#out + 1] = string.char(math.floor(n / 16) % 256)
    elseif count == 3 then
        out[#out + 1] = string.char(math.floor(n / 1024) % 256)
        out[#out + 1] = string.char(math.floor(n / 4) % 256)
    end
    return table.concat(out)
end

-- ==========================================================================
-- LZSS (window 2048, match 3..18) -- see SPEC at top of file
-- ==========================================================================
local WINDOW = 2048
local MIN_MATCH = 3
local MAX_MATCH = 18

function M.compress(s)
    local n = #s
    local bytes = {}
    local flagIdx = 0
    local bitCount = 8 -- force a new flag byte on the first token

    local function addFlag(bit)
        if bitCount == 8 then
            flagIdx = #bytes + 1
            bytes[flagIdx] = 0
            bitCount = 0
        end
        if bit == 1 then
            bytes[flagIdx] = bytes[flagIdx] + 2 ^ (7 - bitCount)
        end
        bitCount = bitCount + 1
    end

    local i = 1
    while i <= n do
        local bestLen, bestDist = 0, 0
        local maxLen = math.min(MAX_MATCH, n - i + 1)

        if maxLen >= MIN_MATCH then
            local start = math.max(1, i - (WINDOW - 1))
            local j = start
            while j < i do
                if s:byte(j) == s:byte(i) then
                    local l = 1
                    while l < maxLen and s:byte(j + l) == s:byte(i + l) do
                        l = l + 1
                    end
                    if l > bestLen then
                        bestLen = l
                        bestDist = i - j
                        if l == maxLen then break end
                    end
                end
                j = j + 1
            end
        end

        if bestLen >= MIN_MATCH then
            local d = bestDist - 1 -- 0..2047
            addFlag(0)
            bytes[#bytes + 1] = d % 256
            bytes[#bytes + 1] = math.floor(d / 256) * 16 + (bestLen - MIN_MATCH)
            i = i + bestLen
        else
            addFlag(1)
            bytes[#bytes + 1] = s:byte(i)
            i = i + 1
        end
    end

    local t = {}
    for k, b in ipairs(bytes) do
        t[k] = string.char(b)
    end
    return table.concat(t)
end

function M.decompress(data)
    local out = {}
    local n = #data
    local i = 1
    local flags = 0
    local bitCount = 8 -- force reading the first flag byte

    while i <= n do
        if bitCount == 8 then
            flags = data:byte(i)
            i = i + 1
            bitCount = 0
            if i > n then break end
        end

        local isLiteral = math.floor(flags / 2 ^ (7 - bitCount)) % 2 == 1
        bitCount = bitCount + 1

        if isLiteral then
            out[#out + 1] = data:sub(i, i)
            i = i + 1
        else
            if i + 1 > n then break end
            local d = data:byte(i) + math.floor(data:byte(i + 1) / 16) * 256
            local len = (data:byte(i + 1) % 16) + MIN_MATCH
            local pos = #out - d
            for k = 0, len - 1 do
                out[#out + 1] = out[pos + k]
            end
            i = i + 2
        end
    end

    return table.concat(out)
end

-- ==========================================================================
-- Path compacting / TND1 dump format
-- ==========================================================================
function M.pathToCompact(path)
    if path:sub(1, 23) == "game.ReplicatedStorage." then
        return "RS/" .. path:sub(24)
    elseif path:sub(1, 10) == "workspace." then
        return "WS/" .. path:sub(11)
    elseif path:sub(1, 5) == "game." then
        return "G/" .. path:sub(6)
    end
    return path
end

function M.compactToPath(c)
    if c:sub(1, 3) == "RS/" then
        return ("game.ReplicatedStorage." .. c:sub(4)):gsub("/", ".")
    elseif c:sub(1, 3) == "WS/" then
        return ("workspace." .. c:sub(4)):gsub("/", ".")
    elseif c:sub(1, 2) == "G/" then
        return ("game." .. c:sub(3)):gsub("/", ".")
    end
    return c
end

-- 32-bit FNV-1a hash (decimal string) -- used for the "H <hash>" integrity line
function M.fnv1a(s)
    local h = 2166136261
    for i = 1, #s do
        h = (h ~ s:byte(i)) % 4294967296
        h = (h * 16777619) % 4294967296
    end
    return h
end

-- remotes: array of { path = full path, name = instance name (optional),
--                     isFunction = bool }
-- Returns the TND2 blob (remotes grouped by parent path).
function M.encodeDump(gameName, placeId, universeId, remotes)
    local groups = {}
    local order = {}

    for _, r in ipairs(remotes) do
        local name = r.name or r.path:match("%.([^%.]+)$") or r.path
        local parent = r.path:sub(1, #r.path - #name - 1)
        if parent == "" then parent = "." end

        if not groups[parent] then
            groups[parent] = {}
            order[#order + 1] = parent
        end
        local kids = groups[parent]
        kids[#kids + 1] = (r.isFunction and "F " or "E ") .. name
    end

    table.sort(order)

    local lines = {}
    local safeName = (gameName or "Unknown"):gsub("|", "/")
    lines[#lines + 1] = table.concat({ "TND2", safeName, tostring(placeId), tostring(universeId), os.date("%Y-%m-%d %H:%M") }, "|")

    for _, parent in ipairs(order) do
        lines[#lines + 1] = "> " .. M.pathToCompact(parent)
        local kids = groups[parent]
        table.sort(kids)
        for _, k in ipairs(kids) do
            lines[#lines + 1] = k
        end
    end

    local compact = table.concat(lines, "\n")
    local withHash = compact .. "\nH " .. tostring(M.fnv1a(compact))
    return "TND2:" .. M.b64encode(M.compress(withHash))
end

-- blob -> compact text (TND2 header + grouped remotes), verified or nil + error
function M.decodeBlob(blob)
    if type(blob) ~= "string" or blob:sub(1, 5) ~= "TND2:" then
        return nil, "missing TND2: prefix"
    end

    local data, err = M.b64decode(blob:sub(6))
    if not data then
        return nil, err
    end

    local ok, text = pcall(M.decompress, data)
    if not ok or type(text) ~= "string" then
        return nil, "decompress failed"
    end

    -- integrity: trailing "H <hash>" line + header check
    local compact, hash = text:match("^(.-)\nH (%d+)$")
    if not compact then
        return nil, "damaged (missing integrity line)"
    end
    if tostring(M.fnv1a(compact)) ~= hash then
        return nil, "damaged (checksum mismatch)"
    end
    if compact:sub(1, 5) ~= "TND2|" then
        return nil, "damaged (bad header)"
    end

    return compact
end

return M
