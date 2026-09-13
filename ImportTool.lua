-- ==================================================================================
-- ToT Nexus | Import Tool (whitelisted devs only)
-- Say "import" in chat within 3 minutes of loading to open the remote dumper.
-- Output is auto-copied to clipboard; also saveable as a text file.
-- ==================================================================================

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local WINDOW_SECONDS = 180 -- chat monitor duration after load

local ACCENT = Color3.fromRGB(124, 92, 255)
local ACCENT2 = Color3.fromRGB(64, 224, 255)
local TEXT = Color3.fromRGB(235, 238, 250)
local MUTED = Color3.fromRGB(148, 152, 176)
local CARD = Color3.fromRGB(16, 17, 26)
local PANEL = Color3.fromRGB(20, 21, 31)
local ITEM = Color3.fromRGB(25, 26, 38)

local check = getgenv().isNexusWhitelisted
local okc, allowed = pcall(function() return check and check(LocalPlayer) end)
if not (okc and allowed) then return end

-- ==================================================================================
-- UI
-- ==================================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ToTNexusImport"
gui.DisplayOrder = 1000001
gui.ResetOnSpawn = false
gui.Enabled = false
pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)

local card = Instance.new("CanvasGroup")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.fromOffset(520, 400)
card.BackgroundColor3 = CARD
card.GroupTransparency = 1
card.BorderSizePixel = 0
card.Parent = gui

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", card)
stroke.Color = Color3.fromRGB(58, 60, 92)
stroke.Transparency = 0.35

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.new(1, -70, 0, 26)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Import Tool"
title.Parent = card

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(20, 40)
subtitle.Size = UDim2.new(1, -70, 0, 14)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.TextColor3 = MUTED
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Remote dumper"
subtitle.Parent = card

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

local outputFrame = Instance.new("ScrollingFrame")
outputFrame.Position = UDim2.fromOffset(20, 64)
outputFrame.Size = UDim2.new(1, -40, 0, 248)
outputFrame.BackgroundColor3 = PANEL
outputFrame.BorderSizePixel = 0
outputFrame.ScrollBarThickness = 4
outputFrame.ScrollBarImageColor3 = ACCENT
outputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
outputFrame.CanvasSize = UDim2.new()
outputFrame.Parent = card
Instance.new("UICorner", outputFrame).CornerRadius = UDim.new(0, 8)

local outputPad = Instance.new("UIPadding", outputFrame)
outputPad.PaddingTop = UDim.new(0, 10)
outputPad.PaddingBottom = UDim.new(0, 10)
outputPad.PaddingLeft = UDim.new(0, 10)
outputPad.PaddingRight = UDim.new(0, 10)

local output = Instance.new("TextLabel")
output.Size = UDim2.new(1, 0, 0, 0)
output.AutomaticSize = Enum.AutomaticSize.Y
output.BackgroundTransparency = 1
output.Font = Enum.Font.Code
output.TextSize = 12
output.TextColor3 = TEXT
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.TextWrapped = true
output.Text = 'Press "Run Export"'
output.Parent = outputFrame

local function makeButton(text, x, w, bg, fg)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(x, 322)
    b.Size = UDim2.fromOffset(w, 40)
    b.BackgroundColor3 = bg
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = fg
    b.Text = text
    b.Parent = card
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    if bg ~= ACCENT then
        local s = Instance.new("UIStroke", b)
        s.Color = Color3.fromRGB(58, 60, 92)
        s.Transparency = 0.4
    end
    b.AutoButtonColor = true
    return b
end

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(20, 370)
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

-- ==================================================================================
-- Export
-- ==================================================================================
local function gameName()
    local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    if ok and info and info.Name then return info.Name end
    return "Place " .. game.PlaceId
end

local function runExport()
    local remotes = {}
    local roots = { game:GetService("ReplicatedStorage"), workspace }

    for _, root in ipairs(roots) do
        pcall(function()
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotes, obj:GetFullName() .. "  [" .. obj.ClassName .. "]")
                end
            end
        end)
    end

    table.sort(remotes)

    local dump = string.format(
        "# %s\nPlaceId: %d | UniverseId: %d | Dumped: %s\n\n## Remotes (%d)\n\n%s",
        gameName(), game.PlaceId, game.GameId, os.date("%Y-%m-%d %H:%M"), #remotes,
        table.concat(remotes, "\n")
    )

    output.Text = dump
    outputFrame.CanvasPosition = Vector2.new()

    if setclipboard then
        setclipboard(dump)
        setStatus("Found " .. #remotes .. " remotes - copied to clipboard!", ACCENT2)
    else
        setStatus("Found " .. #remotes .. " remotes", ACCENT2)
    end
    return dump
end

local lastDump = nil

makeButton("Run Export", 20, 150, ACCENT, TEXT).MouseButton1Click:Connect(function()
    lastDump = runExport()
end)

makeButton("Copy", 178, 130, ITEM, TEXT).MouseButton1Click:Connect(function()
    if lastDump and setclipboard then
        setclipboard(lastDump)
        setStatus("Copied to clipboard", ACCENT2)
    else
        setStatus("Nothing to copy yet" .. (setclipboard and "" or " (no clipboard support)"), MUTED)
    end
end)

makeButton("Save .txt", 316, 130, ITEM, TEXT).MouseButton1Click:Connect(function()
    if not lastDump then
        setStatus("Run the export first", MUTED)
    elseif writefile then
        writefile("ToT-Nexus-remotes.txt", lastDump)
        setStatus("Saved ToT-Nexus-remotes.txt to workspace folder", ACCENT2)
    else
        setStatus("writefile unsupported here - use Copy", MUTED)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    local out = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        { GroupTransparency = 1 })
    out:Play()
    out.Completed:Wait()
    gui:Destroy()
end)

-- ==================================================================================
-- Chat monitor (fires once when the local player says "import")
-- ==================================================================================
local conns = {}
local armed = false

local function stopMonitor()
    for _, c in ipairs(conns) do
        pcall(function() c:Disconnect() end)
    end
    conns = {}
end

local function tryTrigger(message)
    if armed then return end
    local clean = string.lower(tostring(message)):gsub("^%s+", ""):gsub("%s+$", "")
    if clean ~= "import" then return end

    armed = true
    stopMonitor()
    print("[ToT Nexus] Import tool opened")

    gui.Enabled = true
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { GroupTransparency = 0 }):Play()
end

pcall(function()
    table.insert(conns, LocalPlayer.Chatted:Connect(tryTrigger))
end)
pcall(function()
    table.insert(conns, TextChatService.MessageReceived:Connect(function(message)
        if message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
            tryTrigger(message.Text)
        end
    end))
end)

task.delay(WINDOW_SECONDS, stopMonitor)
print("[ToT Nexus] Import monitor armed for " .. WINDOW_SECONDS .. "s - say \"import\" in chat")
