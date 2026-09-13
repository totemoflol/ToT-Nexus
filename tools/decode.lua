-- =====================================================================
-- ToT Nexus | TND2 dump decoder (CLI)
-- Usage:
--   lua5.4 tools/decode.lua "TND2:....blob...."
--   lua5.4 tools/decode.lua blob.txt        (file containing the blob)
-- Prints the decoded remote list, grouped by parent path.
-- Format spec: see tools/codec.lua header (stable TND2 spec).
-- Any AI/session: to decode a pasted TND2 blob, run this file with lua5.4.
-- =====================================================================

local path = ...
if path and path:match("decode%.lua$") then
    path = select(2, ...) -- called with own filename first
end

local codec = dofile(arg and arg[0]:match("^(.*)decode%.lua$") and (arg[0]:match("^(.*)decode%.lua$") .. "codec.lua") or "tools/codec.lua")

local input = path

if not input then
    print("usage: lua5.4 tools/decode.lua <blob | file-containing-blob>")
    return
end

local file = io.open(input, "r")
if file then
    input = file:read("*a")
    file:close()
    input = input:gsub("^%s+", ""):gsub("%s+$", "")
end

local text, err = codec.decodeBlob(input)
if not text then
    print("decode failed: " .. tostring(err))
    return
end

local lines = {}
for line in text:gmatch("[^\n]+") do
    lines[#lines + 1] = line
end

local header = lines[1] or ""
local parts = {}
for part in header:gmatch("[^|]+") do
    parts[#parts + 1] = part
end

print("==================================================")
print("Game:      " .. (parts[2] or "?"))
print("PlaceId:   " .. (parts[3] or "?"))
print("UniverseId:" .. (parts[4] or "?"))
print("Dumped:    " .. (parts[5] or "?"))
print("==================================================")

local events, funcs = 0, 0
for i = 2, #lines do
    local line = lines[i]

    local group = line:match("^> (.+)$")
    if group then
        print("")
        print(codec.compactToPath(group))
    else
        local flag, name = line:match("^([EF]) (.+)$")
        if flag then
            if flag == "E" then
                events = events + 1
                print("  [Event]    " .. name)
            else
                funcs = funcs + 1
                print("  [Function] " .. name)
            end
        end
    end
end

print("==================================================")
print("Total: " .. (events + funcs) .. "  (Events: " .. events .. ", Functions: " .. funcs .. ")")
