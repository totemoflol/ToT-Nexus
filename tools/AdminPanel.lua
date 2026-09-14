-- ==================================================================================
-- ToT Nexus | Admin Panel (global whitelist control)
-- Opened from the ADMIN button on the loading splash (globally whitelisted users).
--
-- - All whitelisted users can: view the whitelist, add users
-- - Main admin ("Totemoflol", case-insensitive): revoke users, view action logs
-- - Writes commit straight to Whitelist.lua (and whitelist.log) on GitHub via
--   the Contents API. Requires a fine-grained GitHub PAT with Contents:Read/Write
--   scoped to ONLY this repo. The token is kept in the session / saved locally
--   on the admin's device -- it is NEVER committed to the repo.
-- ==================================================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local REPO_API = "https://api.github.com/repos/totemoflol/ToT-Nexus/contents"
local WL_RAW = "https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main/Whitelist.lua"
local LOG_RAW = "https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main/whitelist.log"
local CODEC_URL = "https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main/tools/codec.lua"
local TOKEN_FILE = "ToT-Nexus-token.txt"

local ACCENT = Color3.fromRGB(124, 92, 255)
local ACCENT2 = Color3.fromRGB(64, 224, 255)
local TEXT = Color3.fromRGB(235, 238, 250)
local MUTED = Color3.fromRGB(148, 152, 176)
local CARD = Color3.fromRGB(16, 17, 26)
local PANEL = Color3.fromRGB(20, 21, 31)
local ITEM = Color3.fromRGB(25, 26, 38)
local RED = Color3.fromRGB(255, 92, 110)

local requestFunc = http_request or request or syn.request

local isMainAdmin = string.lower(LocalPlayer.Name) == "totemoflol"

-- Gate: global whitelist, self-fetched (spoofing getgenv does nothing)
do
    local ok, wl = pcall(function() return loadstring(game:HttpGet(WL_RAW))() end)
    if not ok or type(wl) ~= "table" then return end
    local allowed = (wl.ids and wl.ids[LocalPlayer.UserId] == true)
        or (wl.names and wl.names[string.lower(LocalPlayer.Name)] == true)
    if not allowed then return end
end

-- Token (session memory + optional local device save) --------------------------
local token = getgenv().TatoNexusToken
if not token and readfile and isfile then
    pcall(function()
        if isfile(TOKEN_FILE) then
            token = readfile(TOKEN_FILE):gsub("%s+", "")
        end
    end)
end

local function setToken(t)
    token = t
    getgenv().TatoNexusToken = t
end

-- Base64 codec (shared with the dump tool) -------------------------------------
local codecOk, codec = pcall(function()
    return loadstring(game:HttpGet(CODEC_URL))()
end)
if not codecOk then codec = nil end

-- ==================================================================================
-- GitHub Contents API helpers
-- ==================================================================================
local function ghRequest(method, url, body)
    local headers = {
        ["User-Agent"] = "ToT-Nexus",
        ["Accept"] = "application/vnd.github+json",
    }
    if token and token ~= "" then
        headers["Authorization"] = "Bearer " .. token
    end

    local bodyStr
    if body ~= nil then
        bodyStr = HttpService:JSONEncode(body)
        headers["Content-Type"] = "application/json"
    end

    local ok, res = pcall(function()
        return requestFunc({ Url = url, Method = method, Headers = headers, Body = bodyStr })
    end)
    if not ok then return false, res end
    return true, res
end

-- -> ok, {sha, text} | false, err
local function getFile(path)
    local ok, res = ghRequest("GET", REPO_API .. "/" .. path)
    if not ok or not res or res.StatusCode ~= 200 then
        return false, "HTTP " .. tostring(res and res.StatusCode)
    end
    local okD, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if not okD or type(data) ~= "table" or not data.sha then
        return false, "bad API response"
    end
    local content = ""
    if codec and data.content then
        local stripped = data.content:gsub("\n", "")
        local okC, decoded = pcall(codec.b64decode, stripped)
        if okC and type(decoded) == "string" then
            content = decoded
        end
    end
    return true, { sha = data.sha, text = content }
end

-- -> true | false, err
local function putFile(path, text, message, sha)
    if not codec then return false, "codec unavailable" end
    if not token or token == "" then return false, "no token set" end

    local body = { message = message, content = codec.b64encode(text) }
    if sha then body.sha = sha end

    local ok, res = ghRequest("PUT", REPO_API .. "/" .. path, body)
    if not ok then return false, res end
    if res.StatusCode == 200 or res.StatusCode == 201 then
        return true
    end
    local msg = "HTTP " .. res.StatusCode
    pcall(function()
        msg = HttpService:JSONDecode(res.Body).message or msg
    end)
    return false, msg
end

-- ==================================================================================
-- Whitelist.lua source manipulation (string level)
-- ==================================================================================
-- All quoted entries inside the Usernames block
local function parseUsernames(src)
    local list = {}
    local inBlock = false
    for line in src:gmatch("[^\r\n]+") do
        if line:find("local Usernames") then
            inBlock = true
        elseif inBlock and line:find("}") then
            break
        elseif inBlock then
            local name = line:match('^%s*"([^"]+)"')
            if name then list[#list + 1] = name end
        end
    end
    return list
end

local function addUserToSource(src, name)
    local listStart = src:find("local Usernames%s*=%s*{")
    if not listStart then return nil end
    local listEnd = src:find("}", listStart, true)
    if not listEnd then return nil end
    -- ensure previous entry ends with a comma
    local prefix = src:sub(1, listEnd - 1):gsub("%s+$", "")
    if prefix:sub(-1) ~= "," then prefix = prefix .. "," end
    return prefix .. '\n    "' .. name .. '",\n' .. src:sub(listEnd)
end

local function removeUserFromSource(src, name)
    local lower = string.lower(name)
    local out, changed, inBlock = {}, false, false
    for line in src:gmatch("[^\r\n]*") do
        if line:find("local Usernames") then
            inBlock = true
            out[#out + 1] = line
        elseif inBlock and line:find("}") then
            inBlock = false
            out[#out + 1] = line
        elseif inBlock then
            local entry = line:match('^%s*"([^"]+)"%s*,?%s*$')
            if entry and string.lower(entry) == lower then
                changed = true -- drop the line
            else
                out[#out + 1] = line
            end
        else
            out[#out + 1] = line
        end
    end
    if not changed then return nil end
    return table.concat(out, "\n")
end

-- ==================================================================================
-- Actions
-- ==================================================================================
local function appendLog(line)
    local okG, file = getFile("whitelist.log")
    local sha, text = nil, ""
    if okG then
        sha, text = file.sha, file.text
    end
    local stamp = os.date("%Y-%m-%d %H:%M")
    return putFile("whitelist.log", text .. stamp .. " | " .. line .. "\n",
        "log: " .. line, sha)
end

local function whitelistUser(name)
    if not name:match("^[%w_]+$") then
        return false, "invalid username"
    end

    local okG, file = getFile("Whitelist.lua")
    if not okG then return false, file end

    for _, existing in ipairs(parseUsernames(file.text)) do
        if string.lower(existing) == string.lower(name) then
            return false, "already whitelisted"
        end
    end

    local newSrc = addUserToSource(file.text, name)
    if not newSrc then return false, "could not edit source" end

    local okP = putFile("Whitelist.lua", newSrc, "whitelist: add " .. name .. " (by " .. LocalPlayer.Name .. ")", file.sha)
    if okP then
        appendLog(LocalPlayer.Name .. " ADDED " .. name)
    end
    return okP
end

local function revokeUser(name)
    if not isMainAdmin then
        return false, "main admin only"
    end

    local okG, file = getFile("Whitelist.lua")
    if not okG then return false, file end

    local newSrc = removeUserFromSource(file.text, name)
    if not newSrc then return false, "not found" end

    local okP = putFile("Whitelist.lua", newSrc, "whitelist: revoke " .. name .. " (by " .. LocalPlayer.Name .. ")", file.sha)
    if okP then
        appendLog(LocalPlayer.Name .. " REVOKED " .. name)
    end
    return okP
end

-- ==================================================================================
-- UI
-- ==================================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ToTNexusAdmin"
gui.DisplayOrder = 1000002
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local card = Instance.new("CanvasGroup")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.fromOffset(480, 444)
card.BackgroundColor3 = CARD
card.GroupTransparency = 1
card.BorderSizePixel = 0
card.Parent = gui
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", card)
stroke.Color = Color3.fromRGB(46, 48, 74)
stroke.Transparency = 0.25

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.new(1, -70, 0, 24)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Nexus Admin"
title.Parent = card

local roleLabel = Instance.new("TextLabel")
roleLabel.Position = UDim2.fromOffset(20, 38)
roleLabel.Size = UDim2.new(1, -70, 0, 14)
roleLabel.BackgroundTransparency = 1
roleLabel.Font = Enum.Font.Gotham
roleLabel.TextSize = 11
roleLabel.TextColor3 = isMainAdmin and ACCENT2 or MUTED
roleLabel.TextXAlignment = Enum.TextXAlignment.Left
roleLabel.Text = isMainAdmin and "whitelist control - MAIN ADMIN" or "whitelist control"
roleLabel.Parent = card

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -16, 0, 16)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.BackgroundColor3 = ITEM
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = MUTED
closeBtn.Text = "X"
closeBtn.Parent = card
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- list / log view area
local listFrame = Instance.new("ScrollingFrame")
listFrame.Position = UDim2.fromOffset(20, 62)
listFrame.Size = UDim2.new(1, -40, 0, 188)
listFrame.BackgroundColor3 = PANEL
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = ACCENT
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.CanvasSize = UDim2.new()
listFrame.Parent = card
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
local listPad = Instance.new("UIPadding", listFrame)
listPad.PaddingTop = UDim.new(0, 8)
listPad.PaddingBottom = UDim.new(0, 8)
listPad.PaddingLeft = UDim.new(0, 8)
listPad.PaddingRight = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.Padding = UDim.new(0, 4)

local contentLabel = Instance.new("TextLabel")
contentLabel.Size = UDim2.new(1, 0, 0, 0)
contentLabel.AutomaticSize = Enum.AutomaticSize.Y
contentLabel.BackgroundTransparency = 1
contentLabel.Font = Enum.Font.Code
contentLabel.TextSize = 12
contentLabel.TextColor3 = TEXT
contentLabel.TextXAlignment = Enum.TextXAlignment.Left
contentLabel.TextYAlignment = Enum.TextYAlignment.Top
contentLabel.TextWrapped = true
contentLabel.Text = "loading..."
contentLabel.Parent = listFrame

local function makeButton(text, x, y, w, bg, fg)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(x, y)
    b.Size = UDim2.fromOffset(w, 36)
    b.BackgroundColor3 = bg
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = fg
    b.Text = text
    b.Parent = card
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    if bg ~= ACCENT then
        local s = Instance.new("UIStroke", b)
        s.Color = Color3.fromRGB(58, 60, 92)
        s.Transparency = 0.4
    end
    return b
end

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(20, 414)
status.Size = UDim2.new(1, -40, 0, 16)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = MUTED
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = ""
status.Parent = card

local function setStatus(msg, color)
    status.Text = msg
    status.TextColor3 = color or MUTED
end

-- add-user row
local nameInput = Instance.new("TextBox")
nameInput.Position = UDim2.fromOffset(20, 262)
nameInput.Size = UDim2.fromOffset(280, 36)
nameInput.BackgroundColor3 = ITEM
nameInput.Font = Enum.Font.Gotham
nameInput.TextSize = 13
nameInput.TextColor3 = TEXT
nameInput.PlaceholderText = "username to whitelist"
nameInput.PlaceholderColor3 = MUTED
nameInput.ClearTextOnFocus = false
nameInput.Text = ""
nameInput.Parent = card
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 10)

-- token row
local tokenInput = Instance.new("TextBox")
tokenInput.Position = UDim2.fromOffset(20, 306)
tokenInput.Size = UDim2.fromOffset(280, 36)
tokenInput.BackgroundColor3 = ITEM
tokenInput.Font = Enum.Font.Gotham
tokenInput.TextSize = 13
tokenInput.TextColor3 = TEXT
tokenInput.PlaceholderText = token and "token set (paste to replace)" or "GitHub token (contents write)"
tokenInput.PlaceholderColor3 = MUTED
tokenInput.ClearTextOnFocus = false
tokenInput.Text = ""
tokenInput.Parent = card
Instance.new("UICorner", tokenInput).CornerRadius = UDim.new(0, 10)

-- view toggles (main admin: logs)
makeButton("Show Users", 20, 350, 150, ITEM, TEXT)
makeButton(isMainAdmin and "View Logs" or "-", 178, 350, 150, ITEM,
    isMainAdmin and TEXT or Color3.fromRGB(60, 62, 88))

local addBtn = makeButton("Whitelist", 310, 262, 150, ACCENT, TEXT)
local saveTokenBtn = makeButton("Save Token", 310, 306, 150, ITEM, TEXT)

-- ==================================================================================
-- View logic
-- ==================================================================================
local showingLogs = false

local function showUsers()
    showingLogs = false
    local ok, src = pcall(function() return game:HttpGet(WL_RAW) end)
    if not ok then
        contentLabel.Text = "failed to load whitelist"
        return
    end

    local names = parseUsernames(src)
    local lines = { "-- whitelisted users (" .. #names .. ") --", "" }
    for _, n in ipairs(names) do
        local mark = (string.lower(n) == "totemoflol") and "  [main]" or ""
        lines[#lines + 1] = "  " .. n .. mark .. (isMainAdmin and "   [revoke]" or "")
    end
    contentLabel.Text = table.concat(lines, "\n")
    listFrame.CanvasPosition = Vector2.new()
end

local function showLogs()
    if not isMainAdmin then return end
    showingLogs = true
    local ok, log = pcall(function() return game:HttpGet(LOG_RAW) end)
    if not ok or log:find("404") == 1 then
        contentLabel.Text = "no logs yet"
        return
    end
    contentLabel.Text = log ~= "" and log or "no logs yet"
    listFrame.CanvasPosition = Vector2.new()
end

addBtn.MouseButton1Click:Connect(function()
    local name = nameInput.Text:gsub("%s+", "")
    if name == "" then
        setStatus("enter a username first", RED)
        return
    end
    setStatus("whitelisting " .. name .. "...", MUTED)
    task.spawn(function()
        local ok, err = whitelistUser(name)
        if ok then
            nameInput.Text = ""
            setStatus("whitelisted " .. name .. " (live on next load)", ACCENT2)
            if showingLogs then showLogs() else showUsers() end
        else
            setStatus("failed: " .. tostring(err), RED)
        end
    end)
end)

saveTokenBtn.MouseButton1Click:Connect(function()
    local t = tokenInput.Text:gsub("%s+", "")
    if t == "" then
        setStatus("paste a token first", RED)
        return
    end
    setToken(t)
    if writefile then
        pcall(function() writefile(TOKEN_FILE, t) end)
    end
    tokenInput.Text = ""
    setStatus("token saved" .. (writefile and " (device)" or " (session)"), ACCENT2)
end)

-- per-row revoke is handled by typing the name; keep a revoke input for main admin
do
    local revokeBtn = makeButton("Revoke (main)", 336, 350, 124, ITEM, isMainAdmin and RED or Color3.fromRGB(120, 70, 80))
    revokeBtn.MouseButton1Click:Connect(function()
        if not isMainAdmin then return end
        local name = nameInput.Text:gsub("%s+", "")
        if name == "" then
            setStatus("type the username to revoke in the top input", RED)
            return
        end
        task.spawn(function()
            local ok, err = revokeUser(name)
            if ok then
                setStatus("revoked " .. name, ACCENT2)
                if showingLogs then showLogs() else showUsers() end
            else
                setStatus("failed: " .. tostring(err), RED)
            end
        end)
    end)
end

-- wire view toggles
for _, child in ipairs(card:GetChildren()) do
    if child:IsA("TextButton") and child.Text == "Show Users" then
        child.MouseButton1Click:Connect(showUsers)
    elseif child:IsA("TextButton") and child.Text == "View Logs" then
        child.MouseButton1Click:Connect(showLogs)
    end
end

closeBtn.MouseButton1Click:Connect(function()
    local out = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        { GroupTransparency = 1 })
    out:Play()
    out.Completed:Wait()
    gui:Destroy()
end)

TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    { GroupTransparency = 0 }):Play()

showUsers()
print("[ToT Nexus] Admin panel loaded (" .. LocalPlayer.Name .. (isMainAdmin and ", main admin" or "") .. ")")
