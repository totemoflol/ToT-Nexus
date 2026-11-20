-- ToT Nexus | Advanced Team ESP V3
-- NEXUS_BUILD_ID: 2026.11.20.5
-- Standalone client-side player ESP UI. Uses a single Highlight per player with low-overhead team coloring.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ENV = (getgenv and getgenv()) or _G
ENV.ToTNexusTools = ENV.ToTNexusTools or {}
local KEY = "AdvancedTeamESP"
if ENV.ToTNexusTools[KEY] and ENV.ToTNexusTools[KEY].cleanup then
    pcall(ENV.ToTNexusTools[KEY].cleanup)
end

local alive = true
local enabled = false
local minimized = false
local highlights = {}
local connections = {}
local playerConnections = {}
local gui
local reopenButton

local COLORS = {
    Ally = Color3.fromRGB(75, 165, 255),
    Visible = Color3.fromRGB(91, 231, 151),
    Hidden = Color3.fromRGB(255, 82, 105),
    Background = Color3.fromRGB(12, 16, 28),
    Panel = Color3.fromRGB(21, 27, 44),
    Accent = Color3.fromRGB(139, 102, 255),
    Cyan = Color3.fromRGB(70, 224, 255),
    Text = Color3.fromRGB(242, 245, 255),
    Muted = Color3.fromRGB(145, 155, 180),
}

local function connect(signal, callback, bucket)
    local c = signal:Connect(callback)
    table.insert(bucket or connections, c)
    return c
end

local function isAlly(player)
    if player == LocalPlayer then return true end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team == player.Team
    end
    if LocalPlayer.TeamColor and player.TeamColor then
        return LocalPlayer.TeamColor == player.TeamColor
    end
    return false
end

local function clearPlayer(player)
    local h = highlights[player]
    if h then
        if h.instance then pcall(function() h.instance:Destroy() end) end
        for _, patch in ipairs(h.surfaces or {}) do
            pcall(function() patch:Destroy() end)
        end
        highlights[player] = nil
    end
end

local function applyPlayer(player)
    if not alive or not enabled or player == LocalPlayer then return end
    local character = player.Character
    if not character or not character.Parent then clearPlayer(player) return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then clearPlayer(player) return end

    local record = highlights[player]
    if not record or record.character ~= character or not record.instance or not record.instance.Parent then
        clearPlayer(player)
        local h = Instance.new("Highlight")
        h.Name = "ToTNexus_AdvancedTeamESP"
        h.Adornee = character
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency = 0.82
        h.OutlineTransparency = 0.04
        h.Parent = character
        -- Use one native Highlight per character. Avoid per-limb adornments:
        -- they multiply draw calls and can overwhelm lower-end/mobile clients.
        record = {instance = h, character = character, surfaces = {}, visible = false}
        highlights[player] = record
    end

    local color
    -- Initial color is team-aware. Visibility is updated by the throttled
    -- raycast worker below, never from RenderStepped or per-frame callbacks.
    if isAlly(player) then
        color = COLORS.Ally
    else
        color = record.visible and COLORS.Visible or COLORS.Hidden
    end
    record.instance.FillColor = color
    record.instance.OutlineColor = color
end

local function updateVisibility(player)
    if not alive or not enabled or player == LocalPlayer or isAlly(player) then return end
    local record = highlights[player]
    local character = player.Character
    if not record or not record.instance or not record.instance.Parent or not character then return end
    local camera = workspace.CurrentCamera
    local target = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not camera or not target or not target:IsA("BasePart") then return end

    local origin = camera.CFrame.Position
    local direction = target.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = LocalPlayer.Character and {LocalPlayer.Character} or {}
    params.IgnoreWater = true

    -- One ray per enemy per interval. No transparent-part scanning or retry chains.
    local result = workspace:Raycast(origin, direction, params)
    record.visible = result ~= nil and result.Instance:IsDescendantOf(character)
    local color = record.visible and COLORS.Visible or COLORS.Hidden
    record.instance.FillColor = color
    record.instance.OutlineColor = color
end

local function refreshAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then applyPlayer(player) end
    end
end

local function trackPlayer(player)
    if player == LocalPlayer or playerConnections[player] then return end
    local bucket = {}
    playerConnections[player] = bucket
    connect(player.CharacterAdded, function()
        task.wait(0.35)
        if alive and enabled then applyPlayer(player) end
    end, bucket)
    connect(player.CharacterRemoving, function()
        clearPlayer(player)
    end, bucket)
    connect(player:GetPropertyChangedSignal("Team"), function()
        if enabled then applyPlayer(player) end
    end, bucket)
    if player.Character and enabled then applyPlayer(player) end
end

local function untrackPlayer(player)
    clearPlayer(player)
    for _, c in ipairs(playerConnections[player] or {}) do pcall(function() c:Disconnect() end) end
    playerConnections[player] = nil
end

local parent = (gethui and gethui()) or game:GetService("CoreGui")
local previous = parent:FindFirstChild("ToTNexusAdvancedTeamESP")
if previous then previous:Destroy() end

gui = Instance.new("ScreenGui")
gui.Name = "ToTNexusAdvancedTeamESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000001
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function makeText(parentObj, text, pos, size, fontSize, color, font)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = pos
    t.Size = size
    t.Font = font or Enum.Font.Gotham
    t.Text = text
    t.TextSize = fontSize
    t.TextColor3 = color
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Parent = parentObj
    return t
end

local function makeButton(parentObj, text, pos, size)
    local b = Instance.new("TextButton")
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = COLORS.Panel
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = COLORS.Text
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.Parent = parentObj
    corner(b, 9)
    return b
end

local panel = Instance.new("Frame")
panel.Name = "ESPWindow"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 72)
panel.Size = UDim2.fromOffset(300, 188)
panel.BackgroundColor3 = COLORS.Background
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 14)
local stroke = Instance.new("UIStroke")
stroke.Color = COLORS.Accent
stroke.Transparency = 0.18
stroke.Thickness = 1.2
stroke.Parent = panel

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 48)
top.Active = true
top.BackgroundColor3 = COLORS.Panel
top.BorderSizePixel = 0
top.Parent = panel
corner(top, 14)
local topMask = Instance.new("Frame")
topMask.Position = UDim2.new(0, 0, 1, -14)
topMask.Size = UDim2.new(1, 0, 0, 14)
topMask.BackgroundColor3 = COLORS.Panel
topMask.BorderSizePixel = 0
topMask.Parent = top
makeText(top, "✦", UDim2.fromOffset(14, 0), UDim2.fromOffset(24, 48), 20, COLORS.Cyan, Enum.Font.GothamBlack)
makeText(top, "ADVANCED TEAM ESP", UDim2.fromOffset(43, 7), UDim2.new(1, -100, 0, 18), 11, COLORS.Text, Enum.Font.GothamBold)
makeText(top, "LIVE PLAYER VISUALIZATION", UDim2.fromOffset(44, 25), UDim2.new(1, -100, 0, 12), 7, COLORS.Muted, Enum.Font.GothamBold)

local minimize = makeButton(top, "—", UDim2.new(1, -38, 0, 9), UDim2.fromOffset(27, 27))
minimize.TextSize = 16
local status = makeText(panel, "ESP IS OFF", UDim2.fromOffset(17, 61), UDim2.new(1, -34, 0, 18), 9, COLORS.Muted, Enum.Font.GothamBold)

local toggle = makeButton(panel, "ENABLE ESP", UDim2.fromOffset(16, 91), UDim2.new(1, -32, 0, 39))
toggle.BackgroundColor3 = COLORS.Accent
toggle.TextSize = 12

local legend = Instance.new("Frame")
legend.Position = UDim2.fromOffset(16, 143)
legend.Size = UDim2.new(1, -32, 0, 27)
legend.BackgroundColor3 = COLORS.Panel
legend.BorderSizePixel = 0
legend.Parent = panel
corner(legend, 8)

local function legendDot(x, color, text)
    local dot = Instance.new("Frame")
    dot.Position = UDim2.fromOffset(x, 10)
    dot.Size = UDim2.fromOffset(7, 7)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = legend
    corner(dot, 5)
    makeText(legend, text, UDim2.fromOffset(x + 12, 0), UDim2.fromOffset(75, 27), 8, COLORS.Muted, Enum.Font.GothamMedium)
end
legendDot(9, COLORS.Ally, "TEAMMATE")
legendDot(145, COLORS.Visible, "VISIBLE ENEMY")

reopenButton = makeButton(gui, "✦  OPEN ESP", UDim2.new(0, 16, 0, 72), UDim2.fromOffset(116, 34))
reopenButton.Visible = false
reopenButton.BackgroundColor3 = COLORS.Background
local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = COLORS.Accent
reopenStroke.Parent = reopenButton

local function setEnabled(value)
    enabled = value
    if enabled then
        toggle.Text = "DISABLE ESP"
        toggle.BackgroundColor3 = Color3.fromRGB(65, 45, 105)
        status.Text = "ESP ACTIVE · VISIBILITY CHECK"
        status.TextColor3 = COLORS.Cyan
        refreshAll()
    else
        toggle.Text = "ENABLE ESP"
        toggle.BackgroundColor3 = COLORS.Accent
        status.Text = "ESP IS OFF"
        status.TextColor3 = COLORS.Muted
        for player in pairs(highlights) do clearPlayer(player) end
    end
end

toggle.MouseButton1Click:Connect(function()
    setEnabled(not enabled)
end)
minimize.MouseButton1Click:Connect(function()
    minimized = true
    panel.Visible = false
    reopenButton.Visible = true
end)
reopenButton.MouseButton1Click:Connect(function()
    minimized = false
    panel.Visible = true
    reopenButton.Visible = false
end)

-- Dedicated drag surface + UserInputService movement handling. No frame polling.
do
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragInput = input
        dragStart = input.Position
        startPos = panel.Position
    end
    top.InputBegan:Connect(beginDrag)
    connect(UserInputService.InputChanged, function(input)
        if not dragging or not dragStart or not startPos then return end
        local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouchMove = input.UserInputType == Enum.UserInputType.Touch and dragInput
            and input.TouchId == dragInput.TouchId
        if isMouseMove or isTouchMove then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragInput = nil
            dragStart = nil
            startPos = nil
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do trackPlayer(player) end
connect(Players.PlayerAdded, trackPlayer)
connect(Players.PlayerRemoving, untrackPlayer)
-- Low-frequency visibility worker: sleeps while disabled and raycasts only once
-- per enemy per pass. Player/character/team events still own highlight lifecycle.
task.spawn(function()
    while alive do
        if enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then updateVisibility(player) end
            end
            task.wait(0.75)
        else
            task.wait(0.5)
        end
    end
end)
local function cleanup()
    if not alive then return end
    alive = false
    enabled = false
    for player in pairs(highlights) do clearPlayer(player) end
    for player in pairs(playerConnections) do untrackPlayer(player) end
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    if gui and gui.Parent then gui:Destroy() end
end

ENV.ToTNexusTools[KEY] = {cleanup = cleanup}
if ENV.ToTNexusStartScript then
    ENV.ToTNexusStartScript("tool-advanced-team-esp", cleanup)
end
print("[ToT Nexus] Advanced Team ESP V3 loaded")
