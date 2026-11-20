-- ToT Nexus | Nexus UI v2
-- NEXUS_BUILD_ID: 2026.11.20.12
-- Animated game library with responsive layout and scoped developer tools.

local TweenService = game:GetService("TweenService")
local ACCENT = Color3.fromRGB(139, 102, 255)
local ACCENT_DARK = Color3.fromRGB(83, 63, 176)
local CYAN = Color3.fromRGB(70, 224, 255)
local BG = Color3.fromRGB(9, 11, 19)
local PANEL = Color3.fromRGB(17, 20, 32)
local PANEL2 = Color3.fromRGB(25, 29, 45)
local PANEL3 = Color3.fromRGB(34, 38, 58)
local TEXT = Color3.fromRGB(242, 244, 255)
local MUTED = Color3.fromRGB(139, 148, 173)
local GREEN = Color3.fromRGB(96, 231, 174)
local RED = Color3.fromRGB(255, 105, 128)

local function tween(object, duration, properties, style, direction)
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

return function(config)
    config = config or {}
    local games = config.games or {}
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local old = parent:FindFirstChild("ToTNexusGeneralScripts")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ToTNexusGeneralScripts"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent

    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900, 600)
    local width = math.max(300, math.min(880, viewport.X - 24))
    local height = math.max(300, math.min(560, viewport.Y - 28))
    local compact = width < 590
    local narrow = width < 390

    local shade = Instance.new("Frame")
    shade.Name = "Backdrop"
    shade.Size = UDim2.fromScale(1, 1)
    shade.BackgroundColor3 = Color3.new(0, 0, 0)
    shade.BackgroundTransparency = 1
    shade.BorderSizePixel = 0
    shade.Parent = gui
    tween(shade, 0.28, {BackgroundTransparency = 0.38})

    local card = Instance.new("Frame")
    card.Name = "Window"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.53)
    card.Size = UDim2.fromOffset(width, height)
    card.BackgroundColor3 = BG
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Active = true
    card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)
    local border = Instance.new("UIStroke", card)
    border.Color = Color3.fromRGB(78, 69, 130)
    border.Thickness = 1.2
    border.Transparency = 0.18

    local scale = Instance.new("UIScale")
    scale.Scale = 0.94
    scale.Parent = card
    tween(scale, 0.42, {Scale = 1}, Enum.EasingStyle.Back)

    local function corner(object, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 10)
        c.Parent = object
        return c
    end

    local function label(parentObject, text, position, size, fontSize, color, font, xAlign)
        local item = Instance.new("TextLabel")
        item.BackgroundTransparency = 1
        item.Position = position
        item.Size = size
        item.Font = font or Enum.Font.Gotham
        item.Text = text or ""
        item.TextSize = fontSize
        item.TextColor3 = color or TEXT
        item.TextXAlignment = xAlign or Enum.TextXAlignment.Left
        item.TextYAlignment = Enum.TextYAlignment.Center
        item.TextTruncate = Enum.TextTruncate.AtEnd
        item.Parent = parentObject
        return item
    end

    local function makeButton(parentObject, text, position, size, color)
        local button = Instance.new("TextButton")
        button.Position = position
        button.Size = size
        button.BackgroundColor3 = color or PANEL2
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = text
        button.TextColor3 = TEXT
        button.TextSize = 12
        button.Font = Enum.Font.GothamBold
        button.Parent = parentObject
        corner(button, 10)
        return button
    end

    -- Soft ambient glows and animated top accent.
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(0.72, 0, 0, 3)
    glow.Position = UDim2.new(0.14, 0, 0, 0)
    glow.BackgroundColor3 = ACCENT
    glow.BorderSizePixel = 0
    glow.Parent = card
    local glowGradient = Instance.new("UIGradient")
    glowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENT_DARK),
        ColorSequenceKeypoint.new(0.5, CYAN),
        ColorSequenceKeypoint.new(1, ACCENT),
    })
    glowGradient.Parent = glow
    corner(glow, 3)
    task.spawn(function()
        while gui.Parent do
            tween(glow, 2.4, {BackgroundColor3 = CYAN}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
            if not gui.Parent then break end
            tween(glow, 2.4, {BackgroundColor3 = ACCENT}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
        end
    end)

    local orb1 = Instance.new("Frame")
    orb1.AnchorPoint = Vector2.new(0.5, 0.5)
    orb1.Position = UDim2.new(1, 38, 0, 5)
    orb1.Size = UDim2.fromOffset(170, 170)
    orb1.BackgroundColor3 = ACCENT
    orb1.BackgroundTransparency = 0.91
    orb1.BorderSizePixel = 0
    orb1.Parent = card
    corner(orb1, 100)
    local orb2 = Instance.new("Frame")
    orb2.AnchorPoint = Vector2.new(0.5, 0.5)
    orb2.Position = UDim2.new(0, -35, 1, 30)
    orb2.Size = UDim2.fromOffset(150, 150)
    orb2.BackgroundColor3 = CYAN
    orb2.BackgroundTransparency = 0.94
    orb2.BorderSizePixel = 0
    orb2.Parent = card
    corner(orb2, 100)

    -- Header.
    local logo = Instance.new("Frame")
    logo.Position = UDim2.fromOffset(22, 17)
    logo.Size = UDim2.fromOffset(36, 36)
    logo.BackgroundColor3 = ACCENT_DARK
    logo.BorderSizePixel = 0
    logo.Parent = card
    corner(logo, 11)
    local logoText = label(logo, "N", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 20, TEXT, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    local logoGrad = Instance.new("UIGradient")
    logoGrad.Color = ColorSequence.new(ACCENT, CYAN)
    logoGrad.Rotation = 35
    logoGrad.Parent = logo

    label(card, "ToT Nexus", UDim2.fromOffset(68, 15), UDim2.new(1, -140, 0, 25), 19, TEXT, Enum.Font.GothamBold)
    label(card, "UNIVERSAL GAME HUB  /  LIBRARY", UDim2.fromOffset(69, 39), UDim2.new(1, -150, 0, 13), 8, CYAN, Enum.Font.GothamBold)
    local versionText = "v" .. tostring(config.version or "?") .. " · " .. tostring(config.versionStatus or "UNKNOWN")
    local versionBadge = label(card, versionText, UDim2.new(1, -214, 0, 43), UDim2.fromOffset(164, 12), 7,
        config.versionStatus == "UP TO DATE" and GREEN or (config.versionStatus == "UPDATE AVAILABLE" and RED or MUTED),
        Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    versionBadge.Name = "VersionStatus"
    versionBadge.Active = true


    local minimized = false
    local closeConfirm
    local minimize = makeButton(card, "−", UDim2.new(1, -84, 0, 16), UDim2.fromOffset(30, 30), PANEL3)
    minimize.TextSize = 22
    local close = makeButton(card, "×", UDim2.new(1, -48, 0, 16), UDim2.fromOffset(30, 30), Color3.fromRGB(48, 28, 43))
    close.TextColor3 = RED
    close.TextSize = 22

    local restore = makeButton(gui, "✦  ToT Nexus  ·  OPEN", UDim2.new(0, 16, 0, 72), UDim2.fromOffset(166, 38), PANEL)
    restore.Visible = false
    restore.TextSize = 10
    local restoreStroke = Instance.new("UIStroke", restore)
    restoreStroke.Color = ACCENT
    restoreStroke.Transparency = 0.2

    minimize.MouseButton1Click:Connect(function()
        if minimized then return end
        minimized = true
        card.Visible = false
        restore.Visible = true
        tween(shade, 0.18, {BackgroundTransparency = 1})
    end)
    restore.MouseButton1Click:Connect(function()
        if not gui.Parent then return end
        minimized = false
        restore.Visible = false
        shade.BackgroundTransparency = 1
        card.Visible = true
        tween(shade, 0.2, {BackgroundTransparency = 0.38})
        tween(scale, 0.22, {Scale = 1}, Enum.EasingStyle.Back)
    end)

    local function showCloseConfirmation()
        if closeConfirm then closeConfirm:Destroy() end
        closeConfirm = Instance.new("Frame")
        closeConfirm.Name = "CloseConfirmation"
        closeConfirm.Size = UDim2.fromScale(1, 1)
        closeConfirm.BackgroundColor3 = Color3.fromRGB(3, 4, 10)
        closeConfirm.BackgroundTransparency = 0.2
        closeConfirm.BorderSizePixel = 0
        closeConfirm.ZIndex = 50
        closeConfirm.Parent = gui
        local dialog = Instance.new("Frame")
        dialog.AnchorPoint = Vector2.new(0.5, 0.5)
        dialog.Position = UDim2.fromScale(0.5, 0.5)
        dialog.Size = UDim2.fromOffset(math.min(width - 36, 340), 184)
        dialog.BackgroundColor3 = PANEL
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 51
        dialog.Parent = closeConfirm
        corner(dialog, 16)
        local outline = Instance.new("UIStroke", dialog)
        outline.Color = RED
        outline.Transparency = 0.25
        local confirmTitle = label(dialog, "CLOSE LIBRARY?", UDim2.fromOffset(18, 17), UDim2.new(1, -36, 0, 24), 15, TEXT, Enum.Font.GothamBold)
        confirmTitle.ZIndex = 52
        local confirmBody = label(dialog, "This will close ToT Nexus. You can reopen it by executing the loader again.", UDim2.fromOffset(18, 48), UDim2.new(1, -36, 0, 48), 10, MUTED, Enum.Font.Gotham)
        confirmBody.ZIndex = 52
        local cancel = makeButton(dialog, "CANCEL", UDim2.new(0, 16, 1, -48), UDim2.new(0.5, -22, 0, 32), PANEL3)
        cancel.ZIndex = 52
        local confirm = makeButton(dialog, "CLOSE LIBRARY", UDim2.new(0.5, 6, 1, -48), UDim2.new(0.5, -22, 0, 32), Color3.fromRGB(112, 42, 65))
        confirm.ZIndex = 52
        cancel.MouseButton1Click:Connect(function()
            if closeConfirm then closeConfirm:Destroy(); closeConfirm = nil end
        end)
        confirm.MouseButton1Click:Connect(function()
            tween(scale, 0.18, {Scale = 0.95}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(shade, 0.18, {BackgroundTransparency = 1})
            task.wait(0.19)
            if gui and gui.Parent then gui:Destroy() end
        end)
    end
    close.MouseEnter:Connect(function() tween(close, 0.16, {BackgroundColor3 = Color3.fromRGB(76, 35, 52)}) end)
    close.MouseLeave:Connect(function() tween(close, 0.16, {BackgroundColor3 = Color3.fromRGB(48, 28, 43)}) end)
    close.MouseButton1Click:Connect(showCloseConfirmation)

    -- Global input capture avoids relying on InputBegan bubbling through nested
    -- Frames and TextLabels (which differs across touch clients/executors).
    do
        local UserInputService = game:GetService("UserInputService")
        local dragging, dragInput = false, nil
        local dragStart, startPos
        local function beginDrag(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local x = input.Position.X - card.AbsolutePosition.X
            local y = input.Position.Y - card.AbsolutePosition.Y
            if x < 0 or x > (card.AbsoluteSize.X - 92) or y < 0 or y > 66 then return end
            -- Preserve tapping the version badge to open its diagnostic screen.
            if y >= 40 and x >= (card.AbsoluteSize.X - 214) and x <= (card.AbsoluteSize.X - 48) then return end
            dragging, dragInput = true, input
            dragStart, startPos = input.Position, card.Position
        end
        local function move(input)
            if not dragging or not dragStart or not startPos then return end
            local mouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
            local touchMove = input.UserInputType == Enum.UserInputType.Touch and dragInput
                and input.TouchId == dragInput.TouchId
            if mouseMove or touchMove then
                local delta = input.Position - dragStart
                card.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
        local function finish(input)
            if input == dragInput or (dragInput and input.UserInputType == Enum.UserInputType.Touch and input.TouchId == dragInput.TouchId)
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging, dragInput, dragStart, startPos = false, nil, nil, nil
            end
        end
        UserInputService.InputBegan:Connect(beginDrag)
        UserInputService.InputChanged:Connect(move)
        UserInputService.TouchMoved:Connect(move)
        UserInputService.InputEnded:Connect(finish)
    end

    local divider = Instance.new("Frame")
    divider.Position = UDim2.fromOffset(20, 65)
    divider.Size = UDim2.new(1, -40, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(42, 47, 68)
    divider.BorderSizePixel = 0
    divider.Parent = card

    -- Two-column layout, adapts to narrow mobile screens.
    local margin = 18
    local top = 82
    local bottom = 18
    local leftWidth = compact and math.floor((width - margin * 2) * (narrow and 0.39 or 0.40)) or 278
    local gap = 12
    local rightWidth = width - margin * 2 - leftWidth - gap
    local listX = margin
    local listW = leftWidth
    local panelX = margin + leftWidth + gap

    label(card, "YOUR EXPERIENCE", UDim2.fromOffset(listX + 2, top), UDim2.fromOffset(listW - 4, 14), 8, MUTED, Enum.Font.GothamBold)
    local updatesButton = makeButton(card, "✦ UPDATES", UDim2.fromOffset(listX + listW - 78, top - 5), UDim2.fromOffset(78, 23), PANEL2)
    updatesButton.TextSize = 8
    local updatesStroke = Instance.new("UIStroke", updatesButton)
    updatesStroke.Color = CYAN
    updatesStroke.Transparency = 0.58

    local list = Instance.new("ScrollingFrame")
    list.Name = "GameList"
    list.Position = UDim2.fromOffset(listX, top + 21)
    list.Size = UDim2.new(0, listW, 1, -(top + 21 + bottom))
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 2
    list.ScrollBarImageColor3 = ACCENT
    list.CanvasSize = UDim2.new()
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = card
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 7)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    local detail = Instance.new("Frame")
    detail.Name = "Details"
    detail.Position = UDim2.fromOffset(panelX, top)
    detail.Size = UDim2.new(0, rightWidth, 1, -(top + bottom))
    detail.BackgroundColor3 = PANEL
    detail.BorderSizePixel = 0
    detail.ClipsDescendants = true
    detail.Parent = card
    corner(detail, 14)
    local detailStroke = Instance.new("UIStroke", detail)
    detailStroke.Color = Color3.fromRGB(48, 54, 80)
    detailStroke.Transparency = 0.32

    local selected
    local rows = {}
    local executeButton
    local statusLabel

    local function createNameplate(gameInfo, isCurrent, order)
        local row = Instance.new("TextButton")
        row.Name = "Game_" .. tostring(gameInfo.Id)
        row.Size = UDim2.new(1, -3, 0, compact and 58 or 64)
        row.BackgroundColor3 = PANEL
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = order
        row.Parent = list
        corner(row, 11)
        local stroke = Instance.new("UIStroke", row)
        stroke.Color = Color3.fromRGB(48, 54, 78)
        stroke.Transparency = 0.48

        local image
        if gameInfo.IsGeneralTools then
            -- Custom Nexus utility badge: intentionally designed in UI, no remote image required.
            image = Instance.new("Frame")
            image.Position = UDim2.fromOffset(7, 7)
            image.Size = UDim2.fromOffset(compact and 42 or 48, compact and 42 or 48)
            image.BackgroundColor3 = Color3.fromRGB(37, 30, 70)
            image.BorderSizePixel = 0
            image.Parent = row
            corner(image, 9)
            local artGradient = Instance.new("UIGradient")
            artGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(112, 76, 220)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 160, 190)),
            })
            artGradient.Rotation = 35
            artGradient.Parent = image
            local ring = Instance.new("Frame")
            ring.AnchorPoint = Vector2.new(0.5, 0.5)
            ring.Position = UDim2.fromScale(0.5, 0.5)
            ring.Size = UDim2.fromScale(0.67, 0.67)
            ring.BackgroundTransparency = 1
            ring.Parent = image
            corner(ring, 100)
            local ringStroke = Instance.new("UIStroke")
            ringStroke.Color = Color3.fromRGB(225, 220, 255)
            ringStroke.Thickness = 1.5
            ringStroke.Transparency = 0.18
            ringStroke.Parent = ring
            label(image, "✦", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), compact and 21 or 25, TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        else
            image = Instance.new("ImageLabel")
            image.Position = UDim2.fromOffset(7, 7)
            image.Size = UDim2.fromOffset(compact and 42 or 48, compact and 42 or 48)
            image.BackgroundColor3 = PANEL2
            image.BorderSizePixel = 0
            image.Image = gameInfo.Icon or ""
            image.ScaleType = Enum.ScaleType.Crop
            image.Parent = row
            corner(image, 9)
            image.ImageTransparency = 0
            image.Visible = true
            local fallback = Instance.new("TextLabel")
            fallback.Name = "IconFallback"
            fallback.Size = UDim2.fromScale(1, 1)
            fallback.BackgroundColor3 = Color3.fromRGB(42, 39, 68)
            fallback.BackgroundTransparency = 0
            fallback.BorderSizePixel = 0
            fallback.Font = Enum.Font.GothamBlack
            fallback.Text = string.upper(string.sub(gameInfo.Name or "G", 1, 1))
            fallback.TextColor3 = CYAN
            fallback.TextSize = compact and 19 or 22
            fallback.ZIndex = image.ZIndex + 1
            fallback.Parent = image
            corner(fallback, 9)
            local function syncIconFallback()
                fallback.Visible = not image.IsLoaded
            end
            image:GetPropertyChangedSignal("IsLoaded"):Connect(syncIconFallback)
            syncIconFallback()
        end

        local textX = compact and 55 or 62
        local name = label(row, gameInfo.Name, UDim2.fromOffset(textX, 8), UDim2.new(1, -textX - 6, 0, 20), compact and 9 or 11, TEXT, Enum.Font.GothamSemibold)
        local tagText = isCurrent and "●  CURRENT" or (gameInfo.IsGeneralTools and "✦  UTILITIES" or (gameInfo.Supported and "AVAILABLE" or "UNSUPPORTED"))
        local tagColor = isCurrent and GREEN or (gameInfo.IsGeneralTools and CYAN or MUTED)
        label(row, tagText, UDim2.fromOffset(textX, 30), UDim2.new(1, -textX - 5, 0, 13), compact and 7 or 8, tagColor, Enum.Font.GothamBold)

        row.MouseEnter:Connect(function()
            if selected ~= gameInfo then tween(row, 0.14, {BackgroundColor3 = PANEL2}) end
        end)
        row.MouseLeave:Connect(function()
            if selected ~= gameInfo then tween(row, 0.14, {BackgroundColor3 = PANEL}) end
        end)
        rows[gameInfo.Id] = {button = row, stroke = stroke}
        return row
    end

    local descriptions = {
        Sell = "Quick potato selling",
        Auto = "Automated farming",
        Rebirths = "Rebirth progression",
        Boosts = "Boost management",
        Misc = "Extra utilities",
        Shop = "In-game shop tools",
        Macro = "Automated action chains",
        Premium = "Premium features",
        Webhook = "Webhook alerts",
        ESP = "Player ESP with team and visibility colors",
    }

    local activeEsp = {enabled = false, highlights = {}, connections = {}}
    local function stopEsp()
        for _, connection in ipairs(activeEsp.connections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(activeEsp.connections)
        for _, highlight in pairs(activeEsp.highlights) do
            if highlight and highlight.Parent then highlight:Destroy() end
        end
        table.clear(activeEsp.highlights)
        activeEsp.enabled = false
    end

    local function addEspTarget(target)
        if not activeEsp.enabled or not target then return end
        if not (target:IsA("Model") or target:IsA("BasePart")) then return end
        if activeEsp.highlights[target] and activeEsp.highlights[target].Parent then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "ToTNexusTestHighlight"
        highlight.Adornee = target
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = ACCENT
        highlight.OutlineColor = CYAN
        highlight.FillTransparency = 0.78
        highlight.OutlineTransparency = 0.05
        highlight.Parent = target
        activeEsp.highlights[target] = highlight
    end

    local function renderDetails(gameInfo)
        selected = gameInfo
        for id, rowData in pairs(rows) do
            local active = id == gameInfo.Id
            tween(rowData.button, 0.16, {BackgroundColor3 = active and Color3.fromRGB(39, 34, 66) or PANEL})
            rowData.stroke.Color = active and ACCENT or Color3.fromRGB(48, 54, 78)
            rowData.stroke.Transparency = active and 0.04 or 0.48
        end

        if not gameInfo.IsGeneralTools and activeEsp.enabled then
            stopEsp()
        end

        local function newContent()
            for _, child in ipairs(detail:GetChildren()) do
                if child ~= detailStroke then child:Destroy() end
            end
            local content = Instance.new("CanvasGroup")
            content.Name = "Content"
            content.Size = UDim2.fromScale(1, 1)
            content.BackgroundTransparency = 1
            content.GroupTransparency = 1
            content.Position = UDim2.fromOffset(0, 8)
            content.Parent = detail
            tween(content, 0.23, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
            return content
        end

        local descriptions = {
            Sell = "Quick potato selling",
            Auto = "Automated farming",
            Rebirths = "Rebirth progression",
            Boosts = "Boost management",
            Misc = "Extra utilities",
            Shop = "In-game shop tools",
            Macro = "Automated action chains",
            Premium = "Premium features",
            Webhook = "Webhook alerts",
            ESP = "Highlight developer test targets",
        }

        local function addFeatureList(parentObject, features, gated)
            local list = Instance.new("ScrollingFrame")
            list.Position = UDim2.fromOffset(13, 0)
            list.Size = UDim2.new(1, -26, 1, -2)
            list.BackgroundTransparency = 1
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 2
            list.ScrollBarImageColor3 = ACCENT
            list.CanvasSize = UDim2.new()
            list.AutomaticCanvasSize = Enum.AutomaticSize.Y
            list.Parent = parentObject
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 6)
            layout.Parent = list

            for _, feature in ipairs(features or {}) do
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, -3, 0, compact and 27 or 30)
                item.BackgroundColor3 = PANEL2
                item.BorderSizePixel = 0
                item.Parent = list
                corner(item, 7)
                local dot = Instance.new("Frame")
                dot.AnchorPoint = Vector2.new(0, 0.5)
                dot.Position = UDim2.new(0, 9, 0.5, 0)
                dot.Size = UDim2.fromOffset(5, 5)
                dot.BackgroundColor3 = gated and MUTED or ACCENT
                dot.BorderSizePixel = 0
                dot.Parent = item
                corner(dot, 4)
                label(item, descriptions[feature] or feature, UDim2.fromOffset(22, 0), UDim2.new(1, -58, 1, 0), compact and 8 or 10, gated and MUTED or TEXT, Enum.Font.GothamMedium)
                label(item, gated and "LOCKED" or "READY", UDim2.new(1, -48, 0, 0), UDim2.fromOffset(41, item.Size.Y.Offset), 7, gated and MUTED or GREEN, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            end
            return list
        end

        local function showToolList()
            local content = newContent()
            label(content, "GENERAL TOOLS", UDim2.fromOffset(17, 17), UDim2.new(1, -34, 0, 22), 16, TEXT, Enum.Font.GothamBold)
            label(content, "Small utilities that work independently of game modules", UDim2.fromOffset(18, 41), UDim2.new(1, -36, 0, 26), 8, MUTED, Enum.Font.Gotham)
            local count = label(content, "1 TOOL", UDim2.new(0, 18, 0, 76), UDim2.new(1, -36, 0, 13), 8, CYAN, Enum.Font.GothamBold)

            local toolCard = Instance.new("TextButton")
            toolCard.Name = "Tool_ESP"
            toolCard.Position = UDim2.fromOffset(14, 99)
            toolCard.Size = UDim2.new(1, -28, 0, 86)
            toolCard.BackgroundColor3 = PANEL2
            toolCard.BorderSizePixel = 0
            toolCard.Text = ""
            toolCard.AutoButtonColor = false
            toolCard.Parent = content
            corner(toolCard, 12)
            local toolStroke = Instance.new("UIStroke", toolCard)
            toolStroke.Color = Color3.fromRGB(57, 65, 92)
            toolStroke.Transparency = 0.42

            local toolIcon = Instance.new("Frame")
            toolIcon.Position = UDim2.fromOffset(11, 11)
            toolIcon.Size = UDim2.fromOffset(64, 64)
            toolIcon.BackgroundColor3 = Color3.fromRGB(27, 31, 57)
            toolIcon.BorderSizePixel = 0
            toolIcon.ClipsDescendants = true
            toolIcon.Parent = toolCard
            corner(toolIcon, 12)
            local art = Instance.new("UIGradient")
            art.Color = ColorSequence.new(Color3.fromRGB(67, 45, 133), Color3.fromRGB(17, 112, 139))
            art.Rotation = 38
            art.Parent = toolIcon
            for i, diameter in ipairs({48, 34, 20}) do
                local radarRing = Instance.new("Frame")
                radarRing.AnchorPoint = Vector2.new(0.5, 0.5)
                radarRing.Position = UDim2.fromScale(0.5, 0.5)
                radarRing.Size = UDim2.fromOffset(diameter, diameter)
                radarRing.BackgroundTransparency = 1
                radarRing.Parent = toolIcon
                corner(radarRing, 100)
                local rs = Instance.new("UIStroke", radarRing)
                rs.Color = i == 1 and CYAN or Color3.fromRGB(220, 225, 255)
                rs.Thickness = 1.2
                rs.Transparency = 0.22 + i * 0.12
            end
            local radarSweep = Instance.new("Frame")
            radarSweep.AnchorPoint = Vector2.new(0, 1)
            radarSweep.Position = UDim2.fromScale(0.5, 0.5)
            radarSweep.Size = UDim2.fromOffset(2, 23)
            radarSweep.BackgroundColor3 = CYAN
            radarSweep.BorderSizePixel = 0
            radarSweep.Parent = toolIcon
            tween(radarSweep, 2.8, {Rotation = 360}, Enum.EasingStyle.Linear)
            local targetDot = Instance.new("Frame")
            targetDot.AnchorPoint = Vector2.new(0.5, 0.5)
            targetDot.Position = UDim2.new(0.68, 0, 0.32, 0)
            targetDot.Size = UDim2.fromOffset(6, 6)
            targetDot.BackgroundColor3 = Color3.fromRGB(255, 105, 128)
            targetDot.BorderSizePixel = 0
            targetDot.Parent = toolIcon
            corner(targetDot, 6)

            label(toolCard, "ADVANCED TEAM ESP", UDim2.fromOffset(87, 14), UDim2.new(1, -124, 0, 20), 11, TEXT, Enum.Font.GothamBold)
            label(toolCard, "Player outlines · team colors · visibility", UDim2.fromOffset(87, 37), UDim2.new(1, -124, 0, 17), 7, MUTED, Enum.Font.Gotham)
            label(toolCard, "›", UDim2.new(1, -33, 0, 0), UDim2.fromOffset(22, 86), 25, CYAN, Enum.Font.Gotham, Enum.TextXAlignment.Center)

            toolCard.MouseEnter:Connect(function()
                tween(toolCard, 0.15, {BackgroundColor3 = PANEL3})
                tween(toolStroke, 0.15, {Transparency = 0.05, Color = ACCENT})
                tween(toolIcon, 0.15, {BackgroundColor3 = ACCENT_DARK})
            end)
            toolCard.MouseLeave:Connect(function()
                tween(toolCard, 0.15, {BackgroundColor3 = PANEL2})
                tween(toolStroke, 0.15, {Transparency = 0.42, Color = Color3.fromRGB(57, 65, 92)})
                tween(toolIcon, 0.15, {BackgroundColor3 = Color3.fromRGB(48, 39, 87)})
            end)
            toolCard.MouseButton1Click:Connect(function()
                local detailContent = newContent()
                local back = makeButton(detailContent, "‹", UDim2.new(1, -49, 0, 12), UDim2.fromOffset(34, 30), PANEL3)
                back.TextSize = 25
                back.TextColor3 = CYAN
                back.MouseEnter:Connect(function() tween(back, 0.13, {BackgroundColor3 = ACCENT_DARK}) end)
                back.MouseLeave:Connect(function() tween(back, 0.13, {BackgroundColor3 = PANEL3}) end)
                back.MouseButton1Click:Connect(showToolList)

                local iconBox = Instance.new("Frame")
                iconBox.AnchorPoint = Vector2.new(0.5, 0)
                iconBox.Position = UDim2.new(0.5, 0, 0, compact and 16 or 21)
                iconBox.Size = UDim2.fromOffset(compact and 70 or 84, compact and 70 or 84)
                iconBox.BackgroundColor3 = Color3.fromRGB(27, 31, 57)
                iconBox.BorderSizePixel = 0
                iconBox.ClipsDescendants = true
                iconBox.Parent = detailContent
                corner(iconBox, 18)
                local detailArt = Instance.new("UIGradient")
                detailArt.Color = ColorSequence.new(Color3.fromRGB(77, 48, 154), Color3.fromRGB(20, 132, 157))
                detailArt.Rotation = 38
                detailArt.Parent = iconBox
                for i, diameter in ipairs({64, 46, 28}) do
                    local rr = Instance.new("Frame")
                    rr.AnchorPoint = Vector2.new(0.5, 0.5)
                    rr.Position = UDim2.fromScale(0.5, 0.5)
                    rr.Size = UDim2.fromOffset(diameter, diameter)
                    rr.BackgroundTransparency = 1
                    rr.Parent = iconBox
                    corner(rr, 100)
                    local rs = Instance.new("UIStroke", rr)
                    rs.Color = i == 1 and CYAN or TEXT
                    rs.Thickness = 1.4
                    rs.Transparency = 0.25 + i * 0.12
                end
                local centerDot = Instance.new("Frame")
                centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
                centerDot.Position = UDim2.fromScale(0.5, 0.5)
                centerDot.Size = UDim2.fromOffset(7, 7)
                centerDot.BackgroundColor3 = CYAN
                centerDot.BorderSizePixel = 0
                centerDot.Parent = iconBox
                corner(centerDot, 7)
                local iconStroke = Instance.new("UIStroke", iconBox)
                iconStroke.Color = CYAN
                iconStroke.Transparency = 0.35

                local titleY = (compact and 16 or 21) + (compact and 70 or 84) + 8
                label(detailContent, "ESP", UDim2.new(0, 12, 0, titleY), UDim2.new(1, -24, 0, 24), 17, TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                label(detailContent, "PLAYER TRACKING & TEAM VISUALIZATION", UDim2.new(0, 12, 0, titleY + 24), UDim2.new(1, -24, 0, 14), 8, CYAN, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                label(detailContent, "FEATURES", UDim2.fromOffset(16, titleY + 51), UDim2.new(1, -32, 0, 13), 8, MUTED, Enum.Font.GothamBold)

                local featureWrap = Instance.new("Frame")
                featureWrap.Position = UDim2.fromOffset(13, titleY + 69)
                featureWrap.Size = UDim2.new(1, -26, 0, math.max(48, height - (top + bottom) - titleY - 69 - 104))
                featureWrap.BackgroundTransparency = 1
                featureWrap.Parent = detailContent
                addFeatureList(featureWrap, {"Blue teammate limb highlights", "Instant red/green enemy limb visibility", "Glass-aware line-of-sight checks", "Frequent visibility refresh", "Mobile touch controls"}, false)

                statusLabel = label(detailContent, activeEsp.enabled and "ESP is active" or "Ready to enable", UDim2.new(0, 14, 1, -62), UDim2.new(1, -28, 0, 14), 8, activeEsp.enabled and GREEN or MUTED, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
                executeButton = makeButton(detailContent, "▶   OPEN ESP PANEL", UDim2.new(0, 13, 1, -42), UDim2.new(1, -26, 0, 36), ACCENT_DARK)
                executeButton.TextSize = 10
                local actionStroke = Instance.new("UIStroke", executeButton)
                actionStroke.Color = CYAN
                actionStroke.Transparency = 0.58
                executeButton.MouseEnter:Connect(function() tween(executeButton, 0.13, {BackgroundColor3 = ACCENT}) end)
                executeButton.MouseLeave:Connect(function() tween(executeButton, 0.13, {BackgroundColor3 = ACCENT_DARK}) end)

                executeButton.MouseButton1Click:Connect(function()
                    if type(config.onExecuteTool) ~= "function" then
                        statusLabel.Text = "ESP script launcher is not configured"
                        statusLabel.TextColor3 = RED
                        return
                    end
                    executeButton.Active = false
                    executeButton.Text = "LAUNCHING ESP..."
                    statusLabel.Text = "Starting Advanced Team ESP V5..."
                    statusLabel.TextColor3 = CYAN
                    task.spawn(function()
                        local ok, err = pcall(config.onExecuteTool, "ESP")
                        if executeButton and executeButton.Parent then
                            executeButton.Active = true
                            executeButton.Text = "▶   LAUNCH ESP"
                            statusLabel.Text = ok and "ESP UI launched" or ("Launch failed: " .. tostring(err))
                            statusLabel.TextColor3 = ok and GREEN or RED
                        end
                    end)
                end)
            end)
        end

        if gameInfo.IsGeneralTools then
            showToolList()
            return
        end

        local content = newContent()
        local iconSize = compact and (narrow and 58 or 70) or 94
        local image = Instance.new("ImageLabel")
        image.AnchorPoint = Vector2.new(0.5, 0)
        image.Position = UDim2.new(0.5, 0, 0, compact and 14 or 20)
        image.Size = UDim2.fromOffset(iconSize, iconSize)
        image.BackgroundColor3 = PANEL2
        image.BorderSizePixel = 0
        image.Image = gameInfo.Icon or ""
        image.ScaleType = Enum.ScaleType.Crop
        image.Parent = content
        corner(image, 16)
        local imageStroke = Instance.new("UIStroke", image)
        imageStroke.Color = ACCENT
        imageStroke.Transparency = 0.22

        local nameY = (compact and 14 or 20) + iconSize + (compact and 9 or 12)
        label(content, gameInfo.Name, UDim2.new(0, 12, 0, nameY), UDim2.new(1, -24, 0, 26), compact and 13 or 17, TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        local subtitleText = gameInfo.IsCurrent and "YOU ARE PLAYING THIS EXPERIENCE" or (gameInfo.Supported and "GAME MODULE" or "NO MODULE AVAILABLE")
        label(content, subtitleText, UDim2.new(0, 10, 0, nameY + 26), UDim2.new(1, -20, 0, 14), compact and 7 or 8, CYAN, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

        local featureY = nameY + 54
        label(content, "FEATURES", UDim2.fromOffset(15, featureY), UDim2.new(1, -30, 0, 14), 8, MUTED, Enum.Font.GothamBold)
        local featureWrap = Instance.new("Frame")
        featureWrap.Position = UDim2.fromOffset(13, featureY + 19)
        featureWrap.Size = UDim2.new(1, -26, 0, math.max(50, height - (top + bottom) - featureY - 19 - 72))
        featureWrap.BackgroundTransparency = 1
        featureWrap.Parent = content
        local allFeatures = {}
        for _, feature in ipairs(gameInfo.Features or {}) do table.insert(allFeatures, feature) end
        for _, feature in ipairs(gameInfo.GatedFeatures or {}) do table.insert(allFeatures, feature) end
        if #allFeatures > 0 then
            addFeatureList(featureWrap, allFeatures, false)
        else
            label(featureWrap, gameInfo.Supported and "No feature list yet" or "No script is registered for this experience.", UDim2.fromOffset(3, 2), UDim2.new(1, -6, 0, 32), 9, MUTED)
        end

        statusLabel = label(content, "", UDim2.new(0, 14, 1, -62), UDim2.new(1, -28, 0, 14), 8, MUTED, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
        executeButton = makeButton(content, gameInfo.Supported and "▶   EXECUTE MODULE" or "MODULE UNAVAILABLE",
            UDim2.new(0, 13, 1, -42), UDim2.new(1, -26, 0, 36), gameInfo.Supported and ACCENT_DARK or PANEL3)
        executeButton.TextSize = 10
        executeButton.Active = gameInfo.Supported
        executeButton.AutoButtonColor = gameInfo.Supported
        executeButton.MouseEnter:Connect(function()
            if gameInfo.Supported then tween(executeButton, 0.13, {BackgroundColor3 = ACCENT}) end
        end)
        executeButton.MouseLeave:Connect(function()
            if gameInfo.Supported then tween(executeButton, 0.13, {BackgroundColor3 = ACCENT_DARK}) end
        end)
        if not gameInfo.Supported then executeButton.TextColor3 = MUTED end

        executeButton.MouseButton1Click:Connect(function()
            if not selected or not selected.Supported then return end
            executeButton.Active = false
            executeButton.Text = "LOADING MODULE..."
            statusLabel.Text = "Fetching selected game module..."
            if config.onExecute then
                local target = gameInfo
                task.spawn(function()
                    local ok, err = pcall(config.onExecute, target)
                    if executeButton and executeButton.Parent then
                        executeButton.Active = true
                        executeButton.Text = "▶   EXECUTE MODULE"
                        statusLabel.Text = ok and "Execution requested" or ("Error: " .. tostring(err))
                    end
                end)
            end
        end)
    end

    -- The active experience is always pinned above the rest of the library.
    local current
    for _, item in ipairs(games) do
        if item.Id == config.currentGameId then current = item break end
    end
    if current then createNameplate(current, true, 0) end
    local order = 1
    for _, item in ipairs(games) do
        if not current or item.Id ~= current.Id then
            createNameplate(item, false, order)
            order = order + 1
        end
    end

    for _, item in ipairs(games) do
        local rowData = rows[item.Id]
        if rowData then
            rowData.button.MouseButton1Click:Connect(function()
                renderDetails(item)
            end)
        end
    end



    local function showVersionDetails()
        local content = Instance.new("CanvasGroup")
        content.Name = "VersionDetails"
        content.Size = UDim2.fromScale(1, 1)
        content.BackgroundTransparency = 1
        content.Parent = detail
        for _, child in ipairs(detail:GetChildren()) do
            if child ~= detailStroke and child ~= content then child:Destroy() end
        end
        label(content, "VERSION STATUS", UDim2.fromOffset(17, 16), UDim2.new(1, -34, 0, 23), 16, TEXT, Enum.Font.GothamBold)
        label(content, "LOADER AND REMOTE BUILD COMPARISON", UDim2.fromOffset(18, 40), UDim2.new(1, -36, 0, 14), 8, CYAN, Enum.Font.GothamBold)

        local componentStatuses = config.componentStatuses or {}
        local currentStatus = (config.versionState and config.versionState.status) or config.versionStatus or "UNKNOWN"
        versionBadge.Text = "v" .. tostring(config.version or "?") .. " · " .. currentStatus
        versionBadge.TextColor3 = currentStatus == "UP TO DATE" and GREEN or (currentStatus == "OUTDATED" and RED or MUTED)
        local rows = {
            {"LOADER", tostring(componentStatuses.Loader or "UNKNOWN")},
            {"LIBRARY", tostring(componentStatuses.GeneralScripts or "UNKNOWN")},
            {"ESP TOOL", tostring(componentStatuses.AdvancedTeamESP or "NOT CHECKED")},
            {"LATEST RELEASE", tostring(config.latestVersion or "Unknown") .. " · " .. tostring(config.latestBuildId or "Unknown")},
            {"OVERALL STATUS", tostring(currentStatus)},
        }
        for i, row in ipairs(rows) do
            local y = 76 + (i - 1) * 48
            local item = Instance.new("Frame")
            item.Position = UDim2.fromOffset(14, y)
            item.Size = UDim2.new(1, -28, 0, 42)
            item.BackgroundColor3 = PANEL2
            item.BorderSizePixel = 0
            item.Parent = content
            corner(item, 9)
            label(item, row[1], UDim2.fromOffset(11, 4), UDim2.new(1, -22, 0, 11), 7, MUTED, Enum.Font.GothamBold)
            local state = row[2]
            local stateColor = (state == "UP TO DATE" or state == "LATEST") and GREEN or ((state == "OUTDATED" or state == "MISMATCH") and RED or (state == "NOT CHECKED" or state == "UNKNOWN" or state == "PARTIAL CHECK") and MUTED or TEXT)
            label(item, state, UDim2.fromOffset(11, 16), UDim2.new(1, -22, 0, 21), 9, stateColor, Enum.Font.GothamSemibold)
        end
        label(content, "OUTDATED means this downloaded component does not match the published build. Re-execute the latest loader to replace it. ESP is checked when it is first launched.", UDim2.fromOffset(17, 326), UDim2.new(1, -34, 0, 48), 8, MUTED, Enum.Font.Gotham)
    end

    versionBadge.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            showVersionDetails()
        end
    end)

    local function showUpdateLog()
        local content = Instance.new("CanvasGroup")
        content.Name = "UpdateLog"
        content.Size = UDim2.fromScale(1, 1)
        content.BackgroundTransparency = 1
        content.Parent = detail
        for _, child in ipairs(detail:GetChildren()) do
            if child ~= detailStroke and child ~= content then child:Destroy() end
        end

        label(content, "UPDATE LOG", UDim2.fromOffset(17, 16), UDim2.new(1, -34, 0, 23), 16, TEXT, Enum.Font.GothamBold)
        label(content, "WHAT CHANGED · WHAT IT AFFECTS", UDim2.fromOffset(18, 40), UDim2.new(1, -36, 0, 14), 8, CYAN, Enum.Font.GothamBold)

        local log = Instance.new("ScrollingFrame")
        log.Position = UDim2.fromOffset(13, 64)
        log.Size = UDim2.new(1, -26, 1, -76)
        log.BackgroundTransparency = 1
        log.BorderSizePixel = 0
        log.ScrollBarThickness = 2
        log.ScrollBarImageColor3 = ACCENT
        log.CanvasSize = UDim2.new()
        log.AutomaticCanvasSize = Enum.AutomaticSize.Y
        log.Parent = content
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 9)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = log

        local entries = {
            {date = "20 NOV 2026 · ESP ACCURACY", title = "Faster limb checks with multi-point visibility", body = "Visibility now refreshes every 0.10 seconds. Each limb checks its center first, then up to four points across the camera-facing surface if the center is blocked. Transparent and glass blockers are skipped more reliably.", affected = "Affects: Advanced Team ESP; reduces false-red limbs when part of an enemy is exposed, with more frequent updates."},
            {date = "20 NOV 2026 · CUSTOM ESP RENDERER", title = "Instant native limb visibility colors", body = "Restored native Roblox Highlights, with one Highlight per body part. Enemy limb colors switch directly between green (visible) and red (blocked), with no tween, using frequent bounded raycasts. Teammates remain blue.", affected = "Affects: Advanced Team ESP; uses native Roblox Highlight instances; visibility updates are sampled at short intervals."},
            {date = "20 NOV 2026 · ESP VISIBILITY", title = "Team refresh and partial visibility", body = "Teams refresh every 7 seconds and on team property changes. Enemy body parts blend individually between green (visible) and red (hidden).", affected = "Affects: Advanced Team ESP; per-limb visibility approximation, capped highlights and raycasts."},
            {date = "20 NOV 2026 · ESP + UI HOTFIX", title = "Restored visibility checks and fixed dragging", body = "Enemy visibility now uses bounded raycasts that can pass through a few transparent or glass blockers. Both windows now capture mouse and touch movement globally.", affected = "Affects: Advanced Team ESP line-of-sight colors, mobile/desktop dragging, and performance safeguards."},
            {date = "20 NOV 2026 · ESP STABILITY", title = "Removed expensive ESP work", body = "Removed world raycasts, transparent-object scans and the recurring refresh loop. Player and character events now drive updates.", affected = "Affects: Advanced Team ESP performance. Enemy visibility colors are temporarily replaced with simple team-based colors."},
            {date = "20 NOV 2026 · MOBILE CONTROLS", title = "Improved touch dragging", body = "Added touch-movement handling for the ESP window and drag support for the main library.", affected = "Affects: Moving both ToT Nexus and the ESP panel on touch devices."},
            {date = "20 NOV 2026 · LIBRARY", title = "Added this update log", body = "The library now includes a chronological summary of changes and their impact.", affected = "Affects: General Tools library navigation."},
            {date = "19 NOV 2026 · LIBRARY UI", title = "Window controls and tool artwork", body = "Added custom ESP artwork, a minimize button with a reopen control, and a close confirmation dialog.", affected = "Affects: General Tools presentation and library window controls."},
        }

        for index, entry in ipairs(entries) do
            local cardEntry = Instance.new("Frame")
            cardEntry.Size = UDim2.new(1, -3, 0, compact and 132 or 120)
            cardEntry.BackgroundColor3 = PANEL2
            cardEntry.BorderSizePixel = 0
            cardEntry.LayoutOrder = index
            cardEntry.Parent = log
            corner(cardEntry, 10)
            label(cardEntry, entry.date, UDim2.fromOffset(11, 8), UDim2.new(1, -22, 0, 13), 7, CYAN, Enum.Font.GothamBold)
            label(cardEntry, entry.title, UDim2.fromOffset(11, 25), UDim2.new(1, -22, 0, 19), 10, TEXT, Enum.Font.GothamBold)
            label(cardEntry, entry.body, UDim2.fromOffset(11, 47), UDim2.new(1, -22, 0, compact and 39 or 34), 8, MUTED, Enum.Font.Gotham)
            label(cardEntry, entry.affected, UDim2.fromOffset(11, compact and 91 or 84), UDim2.new(1, -22, 0, compact and 34 or 28), 8, GREEN, Enum.Font.GothamMedium)
        end
    end

    updatesButton.MouseButton1Click:Connect(showUpdateLog)

    local initial = current or games[1]
    if initial then renderDetails(initial) end
end
