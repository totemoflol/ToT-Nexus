-- ToT Nexus | General Scripts library
-- General utilities are kept separate from game-specific modules.
-- ESP is intentionally scoped to developer test targets placed in
-- workspace.ToTNexusTestTargets (NPCs/dummies in your own experience).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(130, 105, 255)
local CYAN = Color3.fromRGB(65, 220, 255)
local BG = Color3.fromRGB(15, 17, 27)
local PANEL = Color3.fromRGB(24, 27, 41)
local TEXT = Color3.fromRGB(239, 241, 250)
local MUTED = Color3.fromRGB(151, 158, 181)

return function(onContinue)
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local existing = parent:FindFirstChild("ToTNexusGeneralScripts")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ToTNexusGeneralScripts"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000000
    gui.Parent = parent

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(350, 270)
    card.BackgroundColor3 = BG
    card.BorderSizePixel = 0
    card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 15)
    local outline = Instance.new("UIStroke", card)
    outline.Color = Color3.fromRGB(58, 61, 88)
    outline.Transparency = 0.2

    local function label(parentObject, text, pos, size, fontSize, color, font)
        local obj = Instance.new("TextLabel")
        obj.BackgroundTransparency = 1
        obj.Position = pos
        obj.Size = size
        obj.Font = font or Enum.Font.Gotham
        obj.Text = text
        obj.TextSize = fontSize
        obj.TextColor3 = color
        obj.TextXAlignment = Enum.TextXAlignment.Left
        obj.Parent = parentObject
        return obj
    end

    label(card, "ToT Nexus", UDim2.fromOffset(20, 16), UDim2.new(1, -80, 0, 25), 19, TEXT, Enum.Font.GothamBold)
    label(card, "GENERAL SCRIPTS", UDim2.fromOffset(21, 43), UDim2.new(1, -42, 0, 15), 9, CYAN, Enum.Font.GothamBold)

    local close = Instance.new("TextButton")
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -14, 0, 13)
    close.Size = UDim2.fromOffset(30, 30)
    close.BackgroundColor3 = Color3.fromRGB(43, 34, 48)
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(255, 112, 132)
    close.TextSize = 22
    close.Font = Enum.Font.GothamBold
    close.Parent = card
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

    label(card, "Choose a utility to launch, or continue into the detected game.", UDim2.fromOffset(21, 70), UDim2.new(1, -42, 0, 30), 11, MUTED)

    local function makeButton(text, y, accent)
        local b = Instance.new("TextButton")
        b.Position = UDim2.fromOffset(20, y)
        b.Size = UDim2.new(1, -40, 0, 43)
        b.BackgroundColor3 = PANEL
        b.BorderSizePixel = 0
        b.Text = text
        b.TextColor3 = TEXT
        b.TextSize = 13
        b.Font = Enum.Font.GothamSemibold
        b.Parent = card
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
        local s = Instance.new("UIStroke", b)
        s.Color = accent or Color3.fromRGB(54, 58, 82)
        s.Transparency = 0.35
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34, 37, 55)}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = PANEL}):Play()
        end)
        return b
    end

    local openGeneral = makeButton("✦    Browse General Scripts", 116, ACCENT)
    local continueGame = makeButton("▶    Continue to game script", 168, CYAN)
    label(card, "v1.0  •  ToT Nexus utility library", UDim2.fromOffset(21, 231), UDim2.new(1, -42, 0, 18), 9, MUTED)

    local function closeAndContinue()
        gui:Destroy()
        if onContinue then task.spawn(onContinue) end
    end
    close.MouseButton1Click:Connect(closeAndContinue)
    continueGame.MouseButton1Click:Connect(closeAndContinue)

    openGeneral.MouseButton1Click:Connect(function()
        card:TweenSize(UDim2.fromOffset(350, 315), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        openGeneral.Visible = false
        continueGame.Visible = false
        label(card, "AVAILABLE SCRIPTS", UDim2.fromOffset(21, 116), UDim2.new(1, -42, 0, 15), 9, CYAN, Enum.Font.GothamBold)

        local row = Instance.new("Frame")
        row.Position = UDim2.fromOffset(20, 140)
        row.Size = UDim2.new(1, -40, 0, 58)
        row.BackgroundColor3 = PANEL
        row.BorderSizePixel = 0
        row.Parent = card
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
        label(row, "ESP  •  Developer test targets", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 18), 12, TEXT, Enum.Font.GothamSemibold)
        label(row, "Highlight NPCs in workspace.ToTNexusTestTargets", UDim2.fromOffset(12, 29), UDim2.new(1, -24, 0, 15), 9, MUTED)

        local toggle = Instance.new("TextButton")
        toggle.AnchorPoint = Vector2.new(1, 0.5)
        toggle.Position = UDim2.new(1, -10, 0.5, 0)
        toggle.Size = UDim2.fromOffset(58, 27)
        toggle.BackgroundColor3 = Color3.fromRGB(54, 58, 78)
        toggle.Text = "OFF"
        toggle.TextColor3 = TEXT
        toggle.TextSize = 10
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = row
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)

        local enabled = false
        local highlights = {}
        local targetFolder = workspace:FindFirstChild("ToTNexusTestTargets")
        local function clearHighlights()
            for model, highlight in pairs(highlights) do
                if highlight then highlight:Destroy() end
                highlights[model] = nil
            end
        end
        local function applyHighlights()
            targetFolder = workspace:FindFirstChild("ToTNexusTestTargets")
            if not targetFolder then return end
            for _, target in ipairs(targetFolder:GetChildren()) do
                if target:IsA("Model") or target:IsA("BasePart") then
                    if not highlights[target] then
                        local h = Instance.new("Highlight")
                        h.Name = "ToTNexusTestHighlight"
                        h.Adornee = target
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.FillColor = ACCENT
                        h.OutlineColor = CYAN
                        h.FillTransparency = 0.78
                        h.OutlineTransparency = 0.05
                        h.Parent = target
                        highlights[target] = h
                    end
                end
            end
        end
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggle.Text = enabled and "ON" or "OFF"
            toggle.BackgroundColor3 = enabled and Color3.fromRGB(58, 48, 105) or Color3.fromRGB(54, 58, 78)
            if enabled then
                applyHighlights()
                if not targetFolder then
                    toggle.Text = "NO FOLDER"
                    enabled = false
                end
            else
                clearHighlights()
            end
        end)

        local back = makeButton("←    Back to menu", 218, ACCENT)
        back.MouseButton1Click:Connect(function()
            clearHighlights()
            gui:Destroy()
            if onContinue then task.spawn(onContinue) end
        end)
        local note = label(card, "Add NPC/dummy Models to workspace.ToTNexusTestTargets in your own place.", UDim2.fromOffset(21, 275), UDim2.new(1, -42, 0, 25), 9, MUTED)
        note.TextWrapped = true
    end)
end
