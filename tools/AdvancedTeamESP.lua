-- ToT Nexus | Advanced Team ESP V5
-- NEXUS_BUILD_ID: 2026.11.20.11
-- Standalone client-side player ESP UI. Uses native per-limb Highlights with immediate visibility colors.
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

-- Native Roblox Highlights, one per body part. Color changes are immediate (no tween).
local MAX_PARTS = 12
local VISIBILITY_INTERVAL = 0.10
local TEAM_INTERVAL = 7
local highlights = {}

local function isRenderablePart(part)
    return part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
        and part.Transparency < 0.95 and not part:FindFirstAncestorOfClass("Accessory")
end

local function clearPlayer(player)
    local record = highlights[player]
    if not record then return end
    for _, item in ipairs(record.items) do
        if item.highlight then pcall(function() item.highlight:Destroy() end) end
    end
    highlights[player] = nil
end

local function setPartColor(item, color)
    if not item.highlight or not item.highlight.Parent or item.color == color then return end
    item.color = color
    item.highlight.FillColor = color
    item.highlight.OutlineColor = color
end

local function applyPlayer(player)
    if not alive or not enabled or player == LocalPlayer then return end
    local character = player.Character
    if not character or not character.Parent then clearPlayer(player) return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then clearPlayer(player) return end
    local record = highlights[player]
    if not record or record.character ~= character then
        clearPlayer(player)
        record = {character = character, items = {}}
        highlights[player] = record
    end
    local known = {}
    for _, item in ipairs(record.items) do known[item.part] = true end
    for _, part in ipairs(character:GetChildren()) do
        if #record.items >= MAX_PARTS then break end
        if isRenderablePart(part) and not known[part] then
            local h = Instance.new("Highlight")
            h.Name = "ToTNexus_LimbESP"
            h.Adornee = part
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 0.72
            h.OutlineTransparency = 0.05
            local initial = isAlly(player) and COLORS.Ally or COLORS.Hidden
            h.FillColor = initial
            h.OutlineColor = initial
            h.Parent = part
            table.insert(record.items, {part = part, highlight = h, color = initial})
        end
    end
end

local function raySeesPart(origin, point, character, params, excluded)
    local direction = point - origin
    for attempt = 1, 4 do
        params.FilterDescendantsInstances = excluded
        local result = workspace:Raycast(origin, direction, params)
        if not result then return true end
        if result.Instance:IsDescendantOf(character) then return true end
        local blocker = result.Instance
        if attempt < 4 and blocker:IsA("BasePart")
            and (blocker.Transparency >= 0.55 or blocker.Material == Enum.Material.Glass) then
            table.insert(excluded, blocker)
        else
            return false
        end
    end
    return false
end

-- Test the center first, then four points around the camera-facing face.
-- This avoids marking an entire limb red just because its center is behind cover.
local function canSeePart(origin, part, character, params, excluded)
    if raySeesPart(origin, part.Position, character, params, table.clone(excluded)) then
        return true
    end

    local localCamera = part.CFrame:PointToObjectSpace(origin)
    local ax, ay, az = math.abs(localCamera.X), math.abs(localCamera.Y), math.abs(localCamera.Z)
    local uAxis, vAxis, normalAxis, normalSign
    local halfU, halfV, halfN

    if ax >= ay and ax >= az then
        normalAxis, normalSign = "X", localCamera.X >= 0 and 1 or -1
        uAxis, vAxis = "Y", "Z"
        halfN, halfU, halfV = part.Size.X/2, part.Size.Y/2, part.Size.Z/2
    elseif ay >= ax and ay >= az then
        normalAxis, normalSign = "Y", localCamera.Y >= 0 and 1 or -1
        uAxis, vAxis = "X", "Z"
        halfN, halfU, halfV = part.Size.Y/2, part.Size.X/2, part.Size.Z/2
    else
        normalAxis, normalSign = "Z", localCamera.Z >= 0 and 1 or -1
        uAxis, vAxis = "X", "Y"
        halfN, halfU, halfV = part.Size.Z/2, part.Size.X/2, part.Size.Y/2
    end

    local offsets = {
        {0.62, 0}, {-0.62, 0}, {0, 0.62}, {0, -0.62}
    }
    for _, offset in ipairs(offsets) do
        local localPoint = Vector3.zero
        local coords = {X = 0, Y = 0, Z = 0}
        coords[normalAxis] = normalSign * halfN * 0.96
        coords[uAxis] = offset[1] * halfU
        coords[vAxis] = offset[2] * halfV
        localPoint = Vector3.new(coords.X, coords.Y, coords.Z)
        local worldPoint = part.CFrame:PointToWorldSpace(localPoint)
        if raySeesPart(origin, worldPoint, character, params, table.clone(excluded)) then
            return true
        end
    end
    return false
end

local function updateVisibility(player)
    if not alive or not enabled or player == LocalPlayer then return end
    local record = highlights[player]
    if not record or not record.character or not record.character.Parent then return end
    if isAlly(player) then
        for _, item in ipairs(record.items) do setPartColor(item, COLORS.Ally) end
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local origin = camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    for _, item in ipairs(record.items) do
        if item.part.Parent and item.highlight.Parent then
            local excluded = LocalPlayer.Character and {LocalPlayer.Character} or {}
            local visible = canSeePart(origin, item.part, record.character, params, excluded)
            setPartColor(item, visible and COLORS.Visible or COLORS.Hidden)
        end
    end
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
    connect(player:GetPropertyChangedSignal("TeamColor"), function()
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
    makeText(legend, text, UDim2.fromOffset(x + 12, 0), UDim2.fromOffset(64, 27), 7, COLORS.Muted, Enum.Font.GothamMedium)
end
legendDot(8, COLORS.Ally, "TEAM")
legendDot(94, COLORS.Visible, "VISIBLE")
legendDot(188, COLORS.Hidden, "HIDDEN")

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
        status.Text = "INSTANT LIMB VISIBILITY ACTIVE"
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

-- Global input capture makes dragging work even when the touch begins over
-- the title labels rather than the header Frame itself.
do
    local dragging, dragInput = false, nil
    local dragStart, startPos
    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local x = input.Position.X - top.AbsolutePosition.X
        local y = input.Position.Y - top.AbsolutePosition.Y
        if x < 0 or x > (top.AbsoluteSize.X - 44) or y < 0 or y > top.AbsoluteSize.Y then return end
        dragging, dragInput = true, input
        dragStart, startPos = input.Position, panel.Position
    end
    local function move(input)
        if not dragging or not dragStart or not startPos then return end
        local mouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
        local touchMove = input.UserInputType == Enum.UserInputType.Touch and dragInput
            and input.TouchId == dragInput.TouchId
        if mouseMove or touchMove then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    local function finish(input)
        if input == dragInput or (dragInput and input.UserInputType == Enum.UserInputType.Touch and input.TouchId == dragInput.TouchId)
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragInput, dragStart, startPos = false, nil, nil, nil
        end
    end
    connect(UserInputService.InputBegan, beginDrag)
    connect(UserInputService.InputChanged, move)
    connect(UserInputService.TouchMoved, move)
    connect(UserInputService.InputEnded, finish)
end

for _, player in ipairs(Players:GetPlayers()) do trackPlayer(player) end
connect(Players.PlayerAdded, trackPlayer)
connect(Players.PlayerRemoving, untrackPlayer)
-- Periodic team reconciliation catches games that update team state indirectly.
connect(LocalPlayer:GetPropertyChangedSignal("Team"), function()
    if enabled then refreshAll() end
end)
connect(LocalPlayer:GetPropertyChangedSignal("TeamColor"), function()
    if enabled then refreshAll() end
end)
task.spawn(function()
    while alive do
        if enabled then refreshAll() end
        task.wait(TEAM_INTERVAL)
    end
end)

-- Frequent bounded limb raycasts. No RenderStepped/Heartbeat.
task.spawn(function()
    while alive do
        if enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    applyPlayer(player)
                    updateVisibility(player)
                end
            end
            task.wait(VISIBILITY_INTERVAL)
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
print("[ToT Nexus] Advanced Team ESP V5 native limb renderer loaded")
