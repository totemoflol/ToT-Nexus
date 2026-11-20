-- ToT Nexus | Nexus UI v2
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

    local close = makeButton(card, "×", UDim2.new(1, -48, 0, 16), UDim2.fromOffset(30, 30), Color3.fromRGB(48, 28, 43))
    close.TextColor3 = RED
    close.TextSize = 22
    close.MouseEnter:Connect(function() tween(close, 0.16, {BackgroundColor3 = Color3.fromRGB(76, 35, 52)}) end)
    close.MouseLeave:Connect(function() tween(close, 0.16, {BackgroundColor3 = Color3.fromRGB(48, 28, 43)}) end)
    close.MouseButton1Click:Connect(function()
        tween(scale, 0.18, {Scale = 0.95}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(shade, 0.18, {BackgroundTransparency = 1})
        task.wait(0.19)
        gui:Destroy()
    end)

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

        local image = Instance.new("ImageLabel")
        image.Position = UDim2.fromOffset(7, 7)
        image.Size = UDim2.fromOffset(compact and 42 or 48, compact and 42 or 48)
        image.BackgroundColor3 = PANEL2
        image.BorderSizePixel = 0
        image.Image = gameInfo.Icon or ""
        image.ScaleType = Enum.ScaleType.Crop
        image.Parent = row
        corner(image, 9)

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
        ESP = "Highlight developer test targets",
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
            toolCard.Size = UDim2.new(1, -28, 0, 76)
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
            toolIcon.Size = UDim2.fromOffset(52, 52)
            toolIcon.BackgroundColor3 = Color3.fromRGB(48, 39, 87)
            toolIcon.BorderSizePixel = 0
            toolIcon.Parent = toolCard
            corner(toolIcon, 12)
            label(toolIcon, "◎", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 27, CYAN, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

            label(toolCard, "ESP", UDim2.fromOffset(75, 14), UDim2.new(1, -112, 0, 20), 12, TEXT, Enum.Font.GothamBold)
            label(toolCard, "Highlight test targets", UDim2.fromOffset(75, 37), UDim2.new(1, -112, 0, 17), 8, MUTED, Enum.Font.Gotham)
            label(toolCard, "›", UDim2.new(1, -33, 0, 0), UDim2.fromOffset(22, 76), 25, CYAN, Enum.Font.Gotham, Enum.TextXAlignment.Center)

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
                iconBox.Size = UDim2.fromOffset(compact and 64 or 76, compact and 64 or 76)
                iconBox.BackgroundColor3 = Color3.fromRGB(48, 39, 87)
                iconBox.BorderSizePixel = 0
                iconBox.Parent = detailContent
                corner(iconBox, 17)
                local iconStroke = Instance.new("UIStroke", iconBox)
                iconStroke.Color = CYAN
                iconStroke.Transparency = 0.35
                label(iconBox, "◎", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 36, CYAN, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

                local titleY = (compact and 16 or 21) + (compact and 64 or 76) + 8
                label(detailContent, "ESP", UDim2.new(0, 12, 0, titleY), UDim2.new(1, -24, 0, 24), 17, TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                label(detailContent, "DEVELOPER VISUALIZATION TOOL", UDim2.new(0, 12, 0, titleY + 24), UDim2.new(1, -24, 0, 14), 8, CYAN, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                label(detailContent, "FEATURES", UDim2.fromOffset(16, titleY + 51), UDim2.new(1, -32, 0, 13), 8, MUTED, Enum.Font.GothamBold)

                local featureWrap = Instance.new("Frame")
                featureWrap.Position = UDim2.fromOffset(13, titleY + 69)
                featureWrap.Size = UDim2.new(1, -26, 0, math.max(48, height - (top + bottom) - titleY - 69 - 104))
                featureWrap.BackgroundTransparency = 1
                featureWrap.Parent = detailContent
                addFeatureList(featureWrap, {"Highlight test targets", "Live target updates", "Toggleable outlines"}, false)

                statusLabel = label(detailContent, activeEsp.enabled and "ESP is active" or "Ready to enable", UDim2.new(0, 14, 1, -62), UDim2.new(1, -28, 0, 14), 8, activeEsp.enabled and GREEN or MUTED, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
                executeButton = makeButton(detailContent, activeEsp.enabled and "■   DISABLE ESP" or "▶   EXECUTE", UDim2.new(0, 13, 1, -42), UDim2.new(1, -26, 0, 36), ACCENT_DARK)
                executeButton.TextSize = 10
                local actionStroke = Instance.new("UIStroke", executeButton)
                actionStroke.Color = CYAN
                actionStroke.Transparency = 0.58
                executeButton.MouseEnter:Connect(function() tween(executeButton, 0.13, {BackgroundColor3 = ACCENT}) end)
                executeButton.MouseLeave:Connect(function() tween(executeButton, 0.13, {BackgroundColor3 = ACCENT_DARK}) end)

                executeButton.MouseButton1Click:Connect(function()
                    if activeEsp.enabled then
                        stopEsp()
                        executeButton.Text = "▶   EXECUTE"
                        statusLabel.Text = "ESP disabled"
                        statusLabel.TextColor3 = MUTED
                        return
                    end

                    local folder = workspace:FindFirstChild("ToTNexusTestTargets")
                    if not folder then
                        folder = Instance.new("Folder")
                        folder.Name = "ToTNexusTestTargets"
                        folder.Parent = workspace
                    end

                    activeEsp.enabled = true
                    for _, target in ipairs(folder:GetChildren()) do addEspTarget(target) end
                    table.insert(activeEsp.connections, folder.ChildAdded:Connect(addEspTarget))
                    table.insert(activeEsp.connections, folder.ChildRemoved:Connect(function(target)
                        local highlight = activeEsp.highlights[target]
                        if highlight then
                            highlight:Destroy()
                            activeEsp.highlights[target] = nil
                        end
                    end))

                    executeButton.Text = "■   DISABLE ESP"
                    statusLabel.TextColor3 = GREEN
                    local countTargets = 0
                    for _ in pairs(activeEsp.highlights) do countTargets = countTargets + 1 end
                    statusLabel.Text = countTargets > 0 and ("ESP active · " .. countTargets .. " test target(s)") or "ESP active · waiting for test targets"
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

    local initial = current or games[1]
    if initial then renderDetails(initial) end
end
