-- MiscTab.lua | Misc utilities
local Tato = getgenv().Tato

local MiscTab = Window:CreateTab("Misc", "app-window")

-- Notification container is resolved lazily (loading this tab never blocks
-- on the game GUI replicating)
local notifContainer = nil
local function setNotifications(hidden)
    task.spawn(function()
        if not notifContainer then
            local ok, c = pcall(function()
                return game:GetService("Players").LocalPlayer.PlayerGui
                    :WaitForChild("PotatoGameGUI", 30)
                    :WaitForChild("NotificationContainer", 10)
            end)
            if ok then notifContainer = c end
        end
        if notifContainer then
            notifContainer.Visible = not hidden
        end
    end)
end

MiscTab:CreateToggle({
    Name = "Disable Notifications",
    CurrentValue = false,
    Flag = "DisableNotifications",
    Callback = function(state)
        setNotifications(state)
    end,
})

MiscTab:CreateToggle({
    Name = "Auto Farm Generator",
    CurrentValue = false,
    Flag = "GeneratorFarm",
    Callback = Tato.loop(function()
        Tato.fire("PurchaseGenerator", "potato_seedling")
        Tato.fire("DeleteGenerator", "potato_seedling")
        task.wait(0.05)
    end),
})

-- ================================================================
-- Stats HUD: draggable live panel (cash / golden / potatoes / prestige)
-- ================================================================
MiscTab:CreateDivider()
MiscTab:CreateSection("Stats HUD")

local UserInputService = game:GetService("UserInputService")

local hud = Instance.new("Frame")
hud.Visible = false
hud.Active = true
hud.AnchorPoint = Vector2.new(1, 0)
hud.Position = UDim2.new(1, -12, 0, 12)
hud.Size = UDim2.fromOffset(190, 118)
hud.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
hud.BackgroundTransparency = 0.1
hud.BorderSizePixel = 0
hud.Parent = (gethui and gethui()) or game:GetService("CoreGui")

Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 12)
local hudStroke = Instance.new("UIStroke", hud)
hudStroke.Color = Color3.fromRGB(58, 60, 92)
hudStroke.Transparency = 0.3

local hudTitle = Instance.new("TextLabel")
hudTitle.Size = UDim2.new(1, -16, 0, 18)
hudTitle.Position = UDim2.fromOffset(12, 8)
hudTitle.BackgroundTransparency = 1
hudTitle.Font = Enum.Font.GothamBold
hudTitle.TextSize = 13
hudTitle.TextColor3 = Color3.fromRGB(235, 238, 250)
hudTitle.TextXAlignment = Enum.TextXAlignment.Left
hudTitle.Text = "ToT Nexus"
hudTitle.Parent = hud

local hudRows = {}
local function hudRow(y, label)
    local l = Instance.new("TextLabel")
    l.Position = UDim2.fromOffset(12, y)
    l.Size = UDim2.new(1, -16, 0, 16)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextColor3 = Color3.fromRGB(148, 152, 176)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = label
    l.Parent = hud

    local v = Instance.new("TextLabel")
    v.AnchorPoint = Vector2.new(1, 0)
    v.Position = UDim2.new(1, -12, 0, y)
    v.Size = UDim2.new(0, 90, 0, 16)
    v.BackgroundTransparency = 1
    v.Font = Enum.Font.GothamBold
    v.TextSize = 12
    v.TextColor3 = Color3.fromRGB(235, 238, 250)
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Text = "-"
    v.Parent = hud

    hudRows[#hudRows + 1] = { label = label, value = v }
    return v
end

hudRow(30, "Cash")
hudRow(50, "Golden")
hudRow(70, "Potatoes")
hudRow(90, "Prestige pts")

-- dragging (mouse + touch)
do
    local dragging, dragStart, startPos
    hud.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = hud.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            hud.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local hudOn = false
MiscTab:CreateToggle({
    Name = "Stats HUD (draggable)",
    CurrentValue = false,
    Flag = "StatsHUD",
    Callback = function(state)
        hudOn = state
        hud.Visible = state
    end,
})

task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local ok, currency = pcall(function()
        return Tato.waitForPath(player.PlayerGui,
            "PotatoGameGUI", "Background", "ClickerArea", "ClickerContainer", "CurrencyFrame")
    end)
    if not ok then return end

    local goldLabel = currency:WaitForChild("GoldenRow"):WaitForChild("GoldenCount")
    local potatoLabel = currency:WaitForChild("PotatoRow"):WaitForChild("PotatoCount")
    local cashLabel = currency:WaitForChild("CashRow"):WaitForChild("CashCount")

    local tick = 0
    while true do
        if hudOn then
            hudRows[1].value.Text = cashLabel.Text
            hudRows[2].value.Text = goldLabel.Text
            hudRows[3].value.Text = potatoLabel.Text

            tick = tick + 1
            if tick % 10 == 0 then -- prestige invoke every ~5s only
                local okPts, pts = Tato.invoke("GetPotentialPrestigePoints")
                hudRows[4].value.Text = (okPts and type(pts) == "number")
                    and tostring(math.floor(pts)) or "-"
            end
        end
        task.wait(0.5)
    end
end)

-- ================================================================
-- Dig Bot: auto-plays the dig minigame
-- ================================================================
MiscTab:CreateDivider()
MiscTab:CreateSection("Dig Bot")

local gridSize = 100
MiscTab:CreateInput({
    Name = "Grid Size (squares to try)",
    CurrentValue = "",
    PlaceholderText = "100",
    RemoveTextAfterFocusLost = false,
    Flag = "DigGrid",
    Callback = function(v)
        gridSize = math.max(1, math.floor(tonumber(v) or 100))
    end,
})

MiscTab:CreateToggle({
    Name = "Dig Bot",
    CurrentValue = false,
    Flag = "DigBot",
    Callback = Tato.loop(function(alive)
        Tato.fire("DigStartRound")
        task.wait(1)
        for i = 1, gridSize do
            if not alive() then return end
            Tato.fire("DigSquare", i)
            task.wait(0.05)
        end
        task.wait(2)
    end),
})

print("Misc Tab Loaded")
