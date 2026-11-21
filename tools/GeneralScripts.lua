-- ToT Nexus | Nexus UI v2
-- NEXUS_BUILD_ID: 2026.11.21.04
-- Animated game library with responsive layout and scoped developer tools.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
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

    -- Persist General Tools settings through the executor filesystem when available.
    local CONFIG_FOLDER = "ToTNexus"
    local CONFIG_PATH = CONFIG_FOLDER .. "/GeneralTools.json"
    local loadedConfig = {}
    local configStorageAvailable = type(readfile) == "function" and type(writefile) == "function"
    if configStorageAvailable then
        pcall(function()
            if type(isfolder) == "function" and not isfolder(CONFIG_FOLDER) and type(makefolder) == "function" then makefolder(CONFIG_FOLDER)
            elseif type(isfolder) ~= "function" and type(makefolder) == "function" then makefolder(CONFIG_FOLDER) end
        end)
        pcall(function()
            if type(isfile) ~= "function" or isfile(CONFIG_PATH) then
                local decoded = HttpService:JSONDecode(readfile(CONFIG_PATH))
                if type(decoded) == "table" then loadedConfig = decoded end
            end
        end)
    end
    local saveConfig
    local saveStatusLabel
    local saveButton
    local saveRevision = 0
    local function updateSaveStatus(message, color)
        if saveStatusLabel and saveStatusLabel.Parent then saveStatusLabel.Text = message; saveStatusLabel.TextColor3 = color or MUTED end
        if saveButton and saveButton.Parent then saveButton.Text = message == "SAVED" and "✓ SAVED" or "SAVE NOW" end
    end
    local Lighting = game:GetService("Lighting")
    local fullbright = {enabled=false, original=nil, connections={}, applying=false}
    local FULLBRIGHT_VALUES = {
        Ambient = Color3.new(1,1,1),
        OutdoorAmbient = Color3.new(1,1,1),
        ColorShift_Top = Color3.new(1,1,1),
        ColorShift_Bottom = Color3.new(1,1,1),
        Brightness = 2,
        ClockTime = 14,
        FogEnd = 100000,
        GlobalShadows = false,
    }
    local function updateFullbrightUI()
        local on=fullbright.enabled
        if fullbright.statusDot and fullbright.statusDot.Parent then fullbright.statusDot.BackgroundColor3=on and GREEN or RED end
        if fullbright.statusText and fullbright.statusText.Parent then fullbright.statusText.Text=on and "ACTIVE" or "OFF"; fullbright.statusText.TextColor3=on and GREEN or MUTED end
        if fullbright.detailDot and fullbright.detailDot.Parent then fullbright.detailDot.BackgroundColor3=on and GREEN or RED end
        if fullbright.detailStatus and fullbright.detailStatus.Parent then fullbright.detailStatus.Text=on and "FULLBRIGHT IS ACTIVE" or "FULLBRIGHT IS OFF"; fullbright.detailStatus.TextColor3=on and GREEN or MUTED end
        if fullbright.toggleButton and fullbright.toggleButton.Parent then fullbright.toggleButton.Text=on and "■   DISABLE FULLBRIGHT" or "☀   ENABLE FULLBRIGHT"; fullbright.toggleButton.BackgroundColor3=on and Color3.fromRGB(55,43,83) or ACCENT_DARK end
    end
    local function applyFullbright()
        if not fullbright.enabled then return end
        fullbright.applying=true
        for property,value in pairs(FULLBRIGHT_VALUES) do
            pcall(function() Lighting[property]=value end)
        end
        fullbright.applying=false
    end
    local function stopFullbright(skipSave)
        if not fullbright.enabled then return end
        fullbright.enabled=false
        for _,connection in ipairs(fullbright.connections) do pcall(function() connection:Disconnect() end) end
        table.clear(fullbright.connections)
        if fullbright.original then
            for property,value in pairs(fullbright.original) do pcall(function() Lighting[property]=value end) end
        end
        fullbright.original=nil
        updateFullbrightUI()
        if not skipSave and saveConfig then saveConfig() end
    end
    local function startFullbright()
        if fullbright.enabled then return end
        fullbright.original={}
        for property in pairs(FULLBRIGHT_VALUES) do
            local ok,value=pcall(function() return Lighting[property] end)
            if ok then fullbright.original[property]=value end
        end
        fullbright.enabled=true
        for property in pairs(FULLBRIGHT_VALUES) do
            local ok,signal=pcall(function() return Lighting:GetPropertyChangedSignal(property) end)
            if ok then
                table.insert(fullbright.connections,signal:Connect(function()
                    if fullbright.enabled and not fullbright.applying then applyFullbright() end
                end))
            end
        end
        applyFullbright()
        updateFullbrightUI()
        if saveConfig then saveConfig() end
    end

    local activeEsp={enabled=false,highlights={},playerConnections={},connections={},updateRate=math.clamp(math.floor(tonumber(loadedConfig.espUpdateRate) or 10),1,60),visibilityOrigin=(loadedConfig.espVisibilityOrigin=="Torso" or loadedConfig.espVisibilityOrigin=="Camera") and loadedConfig.espVisibilityOrigin or "Head",generation=0}
    saveConfig = function()
        if not configStorageAvailable then updateSaveStatus("SESSION ONLY", RED); return false end
        local snapshot = {schema=1, espEnabled=activeEsp.enabled, espUpdateRate=activeEsp.updateRate, espVisibilityOrigin=activeEsp.visibilityOrigin, fullbrightEnabled=fullbright.enabled}
        local ok, err = pcall(function()
            if type(isfolder) == "function" and not isfolder(CONFIG_FOLDER) and type(makefolder) == "function" then makefolder(CONFIG_FOLDER) end
            writefile(CONFIG_PATH, HttpService:JSONEncode(snapshot))
        end)
        if ok then updateSaveStatus("SAVED", GREEN); return true end
        warn("[ToT Nexus] Could not save General Tools config: " .. tostring(err))
        updateSaveStatus("SAVE FAILED", RED)
        return false
    end
    local function queueConfigSave()
        if not configStorageAvailable then updateSaveStatus("SESSION ONLY", RED); return end
        saveRevision = saveRevision + 1
        local revision = saveRevision
        updateSaveStatus("SAVING...", CYAN)
        task.delay(0.45, function() if revision == saveRevision and saveConfig then saveConfig() end end)
    end
    local EC={Ally=Color3.fromRGB(75,165,255),Visible=Color3.fromRGB(91,231,151),Hidden=Color3.fromRGB(255,82,105)}
    local function updateEspUI()
        local on=activeEsp.enabled
        if activeEsp.statusDot and activeEsp.statusDot.Parent then activeEsp.statusDot.BackgroundColor3=on and GREEN or RED end
        if activeEsp.statusText and activeEsp.statusText.Parent then activeEsp.statusText.Text=on and "ACTIVE" or "OFF"; activeEsp.statusText.TextColor3=on and GREEN or MUTED end
        if activeEsp.detailStatus and activeEsp.detailStatus.Parent then activeEsp.detailStatus.Text=on and "ESP IS ACTIVE · TRACKING PLAYERS" or "ESP IS OFF · READY TO ENABLE"; activeEsp.detailStatus.TextColor3=on and GREEN or MUTED end
        if activeEsp.detailDot and activeEsp.detailDot.Parent then activeEsp.detailDot.BackgroundColor3=on and GREEN or RED end
        if activeEsp.toggleButton and activeEsp.toggleButton.Parent then activeEsp.toggleButton.Text=on and "■   DISABLE ESP" or "▶   ENABLE ESP"; activeEsp.toggleButton.BackgroundColor3=on and Color3.fromRGB(55,43,83) or ACCENT_DARK end
    end
    local function ec(signal,fn,bucket) local c=signal:Connect(fn); table.insert(bucket or activeEsp.connections,c); return c end
    local function ally(p) if p==LocalPlayer then return true end; if LocalPlayer.Team and p.Team then return LocalPlayer.Team==p.Team end; if LocalPlayer.TeamColor and p.TeamColor then return LocalPlayer.TeamColor==p.TeamColor end; return false end
    local function clearPlayer(p) local r=activeEsp.highlights[p]; if not r then return end; for _,i in ipairs(r.items) do if i.highlight then pcall(function() i.highlight:Destroy() end) end end; activeEsp.highlights[p]=nil end
    local function colorPart(i,c) if i.highlight and i.highlight.Parent and i.color~=c then i.color=c; i.highlight.FillColor=c; i.highlight.OutlineColor=c end end
    local function applyPlayer(p)
        if not activeEsp.enabled or p==LocalPlayer then return end
        local char=p.Character; if not char or not char.Parent then clearPlayer(p); return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then clearPlayer(p); return end
        local r=activeEsp.highlights[p]; if not r or r.character~=char then clearPlayer(p); r={character=char,items={}}; activeEsp.highlights[p]=r end
        local known={}; for _,i in ipairs(r.items) do known[i.part]=true end
        for _,part in ipairs(char:GetChildren()) do
            if #r.items>=12 then break end
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and part.Transparency<0.95 and not part:FindFirstAncestorOfClass("Accessory") and not known[part] then
                local h=Instance.new("Highlight"); h.Name="ToTNexus_LimbESP"; h.Adornee=part; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.FillTransparency=0.72; h.OutlineTransparency=0.05
                local c=ally(p) and EC.Ally or EC.Hidden; h.FillColor=c; h.OutlineColor=c; h.Parent=part; table.insert(r.items,{part=part,highlight=h,color=c})
            end
        end
    end
    local function rayVisible(origin,point,char,params,excluded)
        local dir=point-origin
        for n=1,4 do
            params.FilterDescendantsInstances=excluded; local hit=workspace:Raycast(origin,dir,params)
            if not hit or hit.Instance:IsDescendantOf(char) then return true end
            local b=hit.Instance
            if n<4 and b:IsA("BasePart") and (b.Transparency>=0.55 or b.Material==Enum.Material.Glass) then table.insert(excluded,b) else return false end
        end
        return false
    end
    local function canSee(origin,part,char,params,excluded)
        if rayVisible(origin,part.Position,char,params,table.clone(excluded)) then return true end
        local p=part.CFrame:PointToObjectSpace(origin); local ax,ay,az=math.abs(p.X),math.abs(p.Y),math.abs(p.Z)
        local u,v,n,sg,hu,hv,hn
        if ax>=ay and ax>=az then n,sg="X",p.X>=0 and 1 or -1; u,v="Y","Z"; hn,hu,hv=part.Size.X/2,part.Size.Y/2,part.Size.Z/2
        elseif ay>=ax and ay>=az then n,sg="Y",p.Y>=0 and 1 or -1; u,v="X","Z"; hn,hu,hv=part.Size.Y/2,part.Size.X/2,part.Size.Z/2
        else n,sg="Z",p.Z>=0 and 1 or -1; u,v="X","Y"; hn,hu,hv=part.Size.Z/2,part.Size.X/2,part.Size.Y/2 end
        for _,o in ipairs({{0.62,0},{-0.62,0},{0,0.62},{0,-0.62}}) do local c={X=0,Y=0,Z=0}; c[n]=sg*hn*0.96; c[u]=o[1]*hu; c[v]=o[2]*hv; local w=part.CFrame:PointToWorldSpace(Vector3.new(c.X,c.Y,c.Z)); if rayVisible(origin,w,char,params,table.clone(excluded)) then return true end end
        return false
    end
    local function visibility(p)
        local r=activeEsp.highlights[p]; if not activeEsp.enabled or p==LocalPlayer or not r or not r.character or not r.character.Parent then return end
        if ally(p) then for _,i in ipairs(r.items) do colorPart(i,EC.Ally) end; return end
        local cam=workspace.CurrentCamera; if not cam then return end
        local character=LocalPlayer.Character
        local origin=cam.CFrame.Position
        if character then
            if activeEsp.visibilityOrigin=="Head" then
                local head=character:FindFirstChild("Head")
                if head and head:IsA("BasePart") then origin=head.Position end
            elseif activeEsp.visibilityOrigin=="Torso" then
                local torso=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
                if torso and torso:IsA("BasePart") then origin=torso.Position end
            end
        end
        local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.IgnoreWater=true
        for _,i in ipairs(r.items) do if i.part.Parent and i.highlight.Parent then local ex=character and {character} or {}; colorPart(i,canSee(origin,i.part,r.character,params,ex) and EC.Visible or EC.Hidden) end end
    end
    local function refresh() for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then applyPlayer(p) end end end
    local function untrack(p) clearPlayer(p); for _,c in ipairs(activeEsp.playerConnections[p] or {}) do pcall(function() c:Disconnect() end) end; activeEsp.playerConnections[p]=nil end
    local function track(p)
        if p==LocalPlayer or activeEsp.playerConnections[p] then return end
        local bucket={}; activeEsp.playerConnections[p]=bucket
        ec(p.CharacterAdded,function() task.wait(0.35); if activeEsp.enabled then applyPlayer(p) end end,bucket)
        ec(p.CharacterRemoving,function() clearPlayer(p) end,bucket)
        ec(p:GetPropertyChangedSignal("Team"),function() if activeEsp.enabled then applyPlayer(p) end end,bucket)
        ec(p:GetPropertyChangedSignal("TeamColor"),function() if activeEsp.enabled then applyPlayer(p) end end,bucket)
        if p.Character and activeEsp.enabled then applyPlayer(p) end
    end
    local function stopEsp(skipSave)
        activeEsp.enabled=false; activeEsp.generation=activeEsp.generation+1
        for _,c in ipairs(activeEsp.connections) do pcall(function() c:Disconnect() end) end; table.clear(activeEsp.connections)
        for p in pairs(activeEsp.playerConnections) do untrack(p) end
        for p in pairs(activeEsp.highlights) do clearPlayer(p) end; updateEspUI()
        if not skipSave and saveConfig then saveConfig() end
    end
    local function startEsp()
        if activeEsp.enabled then return end
        activeEsp.enabled=true; activeEsp.generation=activeEsp.generation+1; local gen=activeEsp.generation
        for _,p in ipairs(Players:GetPlayers()) do track(p) end
        ec(Players.PlayerAdded,track); ec(Players.PlayerRemoving,untrack)
        ec(LocalPlayer:GetPropertyChangedSignal("Team"),refresh); ec(LocalPlayer:GetPropertyChangedSignal("TeamColor"),refresh)
        refresh(); updateEspUI()
        if saveConfig then saveConfig() end
        task.spawn(function() while activeEsp.enabled and activeEsp.generation==gen do for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then applyPlayer(p); visibility(p) end end; task.wait(1/activeEsp.updateRate) end end)
        task.spawn(function() while activeEsp.enabled and activeEsp.generation==gen do task.wait(7); if activeEsp.enabled and activeEsp.generation==gen then refresh() end end end)
    end
    -- Client-side hitbox size preview. Changes are local to this client and do not
    -- alter server-authoritative hit detection in other experiences.
    local hitbox = {enabled=false, target="Body", scale=2, originals={}, generation=0}
    local function isHitboxPart(part)
        if not part:IsA("BasePart") or part.Name=="HumanoidRootPart" then return false end
        if hitbox.target=="Head" then return part.Name=="Head" end
        if hitbox.target=="Torso" then
            return part.Name=="Torso" or part.Name=="UpperTorso" or part.Name=="LowerTorso"
        end
        return true
    end
    local function restoreHitboxes()
        for part,original in pairs(hitbox.originals) do
            if part and part.Parent then pcall(function() part.Size=original end) end
        end
        table.clear(hitbox.originals)
    end
    local function applyHitboxes()
        if not hitbox.enabled then return end
        local seen={}
        for _,player in ipairs(Players:GetPlayers()) do
            if player~=LocalPlayer and player.Character then
                for _,part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        if isHitboxPart(part) then
                            seen[part]=true
                            if not hitbox.originals[part] then hitbox.originals[part]=part.Size end
                            local original=hitbox.originals[part]
                            pcall(function() part.Size=original*hitbox.scale end)
                        end
                    end
                end
            end
        end
        for part,original in pairs(hitbox.originals) do
            if not seen[part] then
                if part and part.Parent then pcall(function() part.Size=original end) end
                hitbox.originals[part]=nil
            end
        end
    end
    local function stopHitbox()
        if not hitbox.enabled then restoreHitboxes(); return end
        hitbox.enabled=false
        hitbox.generation=hitbox.generation+1
        restoreHitboxes()
        if hitbox.statusDot and hitbox.statusDot.Parent then hitbox.statusDot.BackgroundColor3=RED end
        if hitbox.statusText and hitbox.statusText.Parent then hitbox.statusText.Text="OFF"; hitbox.statusText.TextColor3=MUTED end
        if hitbox.detailStatus and hitbox.detailStatus.Parent then hitbox.detailStatus.Text="HITBOX PREVIEW IS OFF"; hitbox.detailStatus.TextColor3=MUTED end
        if hitbox.detailDot and hitbox.detailDot.Parent then hitbox.detailDot.BackgroundColor3=RED end
        if hitbox.toggleButton and hitbox.toggleButton.Parent then hitbox.toggleButton.Text="▶   ENABLE HITBOX PREVIEW"; hitbox.toggleButton.BackgroundColor3=ACCENT_DARK end
    end
    local function startHitbox()
        if hitbox.enabled then return end
        hitbox.enabled=true
        hitbox.generation=hitbox.generation+1
        local generation=hitbox.generation
        applyHitboxes()
        if hitbox.statusDot and hitbox.statusDot.Parent then hitbox.statusDot.BackgroundColor3=GREEN end
        if hitbox.statusText and hitbox.statusText.Parent then hitbox.statusText.Text="ACTIVE"; hitbox.statusText.TextColor3=GREEN end
        if hitbox.detailStatus and hitbox.detailStatus.Parent then hitbox.detailStatus.Text="LOCAL HITBOX PREVIEW IS ACTIVE"; hitbox.detailStatus.TextColor3=GREEN end
        if hitbox.detailDot and hitbox.detailDot.Parent then hitbox.detailDot.BackgroundColor3=GREEN end
        if hitbox.toggleButton and hitbox.toggleButton.Parent then hitbox.toggleButton.Text="■   DISABLE HITBOX PREVIEW"; hitbox.toggleButton.BackgroundColor3=Color3.fromRGB(55,43,83) end
        task.spawn(function()
            while hitbox.enabled and hitbox.generation==generation and gui.Parent do
                applyHitboxes()
                task.wait(1)
            end
        end)
    end
    gui.Destroying:Connect(stopHitbox)
    gui.Destroying:Connect(function() stopEsp(true) end)
    gui.Destroying:Connect(function() stopFullbright(true) end)

    -- Restore the last saved settings before the tool cards are rendered.
    if loadedConfig.fullbrightEnabled == true then startFullbright() end
    if loadedConfig.espEnabled == true then startEsp() end

    local function renderDetails(gameInfo)
        selected = gameInfo
        for id, rowData in pairs(rows) do
            local active = id == gameInfo.Id
            tween(rowData.button, 0.16, {BackgroundColor3 = active and Color3.fromRGB(39, 34, 66) or PANEL})
            rowData.stroke.Color = active and ACCENT or Color3.fromRGB(48, 54, 78)
            rowData.stroke.Transparency = active and 0.04 or 0.48
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
            ESP = "Independent limb visibility, team colors and line-of-sight settings",
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
            local count = label(content, "3 TOOLS", UDim2.new(0, 18, 0, 76), UDim2.new(0, 70, 0, 13), 8, CYAN, Enum.Font.GothamBold)
            saveStatusLabel = label(content, configStorageAvailable and "AUTO-SAVE READY" or "SESSION ONLY · NO FILE API", UDim2.new(0, 91, 0, 76), UDim2.new(1, -190, 0, 13), 7, configStorageAvailable and GREEN or RED, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            saveButton = makeButton(content, "SAVE NOW", UDim2.new(1, -91, 0, 69), UDim2.fromOffset(77, 25), PANEL3)
            saveButton.TextSize = 7
            saveButton.MouseButton1Click:Connect(function() if saveConfig then saveConfig() end end)

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
            local statusDot=Instance.new("Frame"); statusDot.AnchorPoint=Vector2.new(0.5,0.5); statusDot.Position=UDim2.new(1,-23,0.5,0); statusDot.Size=UDim2.fromOffset(9,9); statusDot.BackgroundColor3=activeEsp.enabled and GREEN or RED; statusDot.BorderSizePixel=0; statusDot.Parent=toolCard; corner(statusDot,8); activeEsp.statusDot=statusDot
            activeEsp.statusText=label(toolCard,activeEsp.enabled and "ACTIVE" or "OFF",UDim2.new(1,-65,0,0),UDim2.fromOffset(34,86),7,activeEsp.enabled and GREEN or MUTED,Enum.Font.GothamBold,Enum.TextXAlignment.Right)

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
                local dc=newContent()
                local back=makeButton(dc,"‹",UDim2.new(1,-49,0,12),UDim2.fromOffset(34,30),PANEL3); back.TextSize=25; back.TextColor3=CYAN; back.MouseButton1Click:Connect(showToolList)
                label(dc,"ADVANCED TEAM ESP",UDim2.fromOffset(16,17),UDim2.new(1,-78,0,22),14,TEXT,Enum.Font.GothamBold)
                label(dc,"PLAYER VISIBILITY & TEAM TRACKING",UDim2.fromOffset(17,42),UDim2.new(1,-34,0,13),7,CYAN,Enum.Font.GothamBold)
                local sp=Instance.new("Frame"); sp.Position=UDim2.fromOffset(14,68); sp.Size=UDim2.new(1,-28,0,44); sp.BackgroundColor3=PANEL2; sp.BorderSizePixel=0; sp.Parent=dc; corner(sp,9)
                local dot=Instance.new("Frame"); dot.Position=UDim2.fromOffset(12,17); dot.Size=UDim2.fromOffset(9,9); dot.BackgroundColor3=activeEsp.enabled and GREEN or RED; dot.BorderSizePixel=0; dot.Parent=sp; corner(dot,8); activeEsp.detailDot=dot
                activeEsp.detailStatus=label(sp,"",UDim2.fromOffset(30,0),UDim2.new(1,-42,1,0),8,MUTED,Enum.Font.GothamBold)
                local toggle=makeButton(dc,activeEsp.enabled and "■   DISABLE ESP" or "▶   ENABLE ESP",UDim2.fromOffset(14,122),UDim2.new(1,-28,0,38),ACCENT_DARK); toggle.TextSize=10; activeEsp.toggleButton=toggle
                toggle.MouseButton1Click:Connect(function() if activeEsp.enabled then stopEsp() else startEsp() end end)
                local panel=Instance.new("Frame"); panel.Position=UDim2.fromOffset(14,171); panel.Size=UDim2.new(1,-28,0,205); panel.BackgroundColor3=PANEL; panel.BorderSizePixel=0; panel.Parent=dc; corner(panel,11)
                local outline=Instance.new("UIStroke",panel); outline.Color=Color3.fromRGB(48,54,80); outline.Transparency=0.35
                label(panel,"VISIBILITY CHECK RATE",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,16),8,MUTED,Enum.Font.GothamBold)
                label(panel,"Higher values update more frequently but use more CPU.",UDim2.fromOffset(12,29),UDim2.new(1,-24,0,25),7,MUTED,Enum.Font.Gotham)
                local track=Instance.new("Frame"); track.Position=UDim2.fromOffset(13,75); track.Size=UDim2.new(1,-103,0,6); track.BackgroundColor3=PANEL3; track.BorderSizePixel=0; track.Active=true; track.Parent=panel; corner(track,5)
                local fill=Instance.new("Frame"); fill.Size=UDim2.new((activeEsp.updateRate-1)/59,0,1,0); fill.BackgroundColor3=CYAN; fill.BorderSizePixel=0; fill.Parent=track; corner(fill,5)
                local knob=Instance.new("Frame"); knob.AnchorPoint=Vector2.new(0.5,0.5); knob.Position=UDim2.new((activeEsp.updateRate-1)/59,0,0.5,0); knob.Size=UDim2.fromOffset(14,14); knob.BackgroundColor3=TEXT; knob.BorderSizePixel=0; knob.Parent=track; corner(knob,8)
                local box=Instance.new("TextBox"); box.Position=UDim2.new(1,-76,0,61); box.Size=UDim2.fromOffset(62,30); box.BackgroundColor3=PANEL3; box.BorderSizePixel=0; box.Text=tostring(activeEsp.updateRate); box.PlaceholderText="1-60"; box.ClearTextOnFocus=false; box.Font=Enum.Font.GothamBold; box.TextSize=11; box.TextColor3=TEXT; box.Parent=panel; corner(box,7)
                label(panel,"1",UDim2.fromOffset(12,89),UDim2.fromOffset(20,13),7,MUTED,Enum.Font.Gotham)
                label(panel,"60 checks/sec max",UDim2.new(1,-126,0,89),UDim2.fromOffset(112,13),7,MUTED,Enum.Font.Gotham,Enum.TextXAlignment.Right)
                local function setRate(v) v=math.clamp(math.floor(tonumber(v) or activeEsp.updateRate),1,60); if activeEsp.updateRate==v then box.Text=tostring(v); return end; activeEsp.updateRate=v; local a=(v-1)/59; fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,0.5,0); box.Text=tostring(v); queueConfigSave() end
                local dragging=false; local cons={}
                local function bind(sig,fn) table.insert(cons,sig:Connect(fn)) end
                local function moveTo(x) local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1); setRate(1+a*59) end
                bind(track.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; moveTo(i.Position.X) end end)
                local function dragMove(i) if dragging then moveTo(i.Position.X) end end
                bind(UserInputService.InputChanged,function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then dragMove(i) end end)
                bind(UserInputService.TouchMoved,dragMove)
                bind(UserInputService.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
                bind(box.FocusLost,function() local n=tonumber(box.Text); if n then setRate(n) else box.Text=tostring(activeEsp.updateRate) end end)
                label(panel,"VISIBILITY ORIGIN",UDim2.fromOffset(12,119),UDim2.new(1,-24,0,14),8,MUTED,Enum.Font.GothamBold)
                local originButtons={}
                local originOptions={"Head","Torso","Camera"}
                local function updateOriginButtons()
                    for name,button in pairs(originButtons) do
                        local selected=activeEsp.visibilityOrigin==name
                        button.BackgroundColor3=selected and ACCENT_DARK or PANEL3
                        button.TextColor3=selected and TEXT or MUTED
                    end
                end
                for index,name in ipairs(originOptions) do
                    local button=makeButton(panel,string.upper(name),UDim2.new((index-1)/3,12,0,141),UDim2.new(1/3,-16,0,29),PANEL3)
                    button.TextSize=8
                    originButtons[name]=button
                    bind(button.MouseButton1Click,function()
                        if activeEsp.visibilityOrigin==name then return end
                        activeEsp.visibilityOrigin=name
                        updateOriginButtons()
                        queueConfigSave()
                    end)
                end
                updateOriginButtons()
                label(panel,"Visibility rays start from your selected body point.",UDim2.fromOffset(12,175),UDim2.new(1,-24,0,18),7,MUTED,Enum.Font.Gotham)
                dc.Destroying:Connect(function() for _,c in ipairs(cons) do pcall(function() c:Disconnect() end) end; if activeEsp.detailStatus and activeEsp.detailStatus.Parent==sp then activeEsp.detailStatus=nil end; if activeEsp.detailDot==dot then activeEsp.detailDot=nil end; if activeEsp.toggleButton==toggle then activeEsp.toggleButton=nil end end)
                updateEspUI()
            end)
            -- Hitbox expander card.
            local hitboxCard=Instance.new("TextButton")
            hitboxCard.Name="Tool_HitboxExpander"
            hitboxCard.Position=UDim2.fromOffset(14,291)
            hitboxCard.Size=UDim2.new(1,-28,0,86)
            hitboxCard.BackgroundColor3=PANEL2
            hitboxCard.BorderSizePixel=0
            hitboxCard.Text=""
            hitboxCard.AutoButtonColor=false
            hitboxCard.Parent=content
            corner(hitboxCard,12)
            local hitboxStroke=Instance.new("UIStroke",hitboxCard)
            hitboxStroke.Color=Color3.fromRGB(57,65,92)
            hitboxStroke.Transparency=0.42
            local hitboxIcon=Instance.new("Frame")
            hitboxIcon.Position=UDim2.fromOffset(11,11)
            hitboxIcon.Size=UDim2.fromOffset(64,64)
            hitboxIcon.BackgroundColor3=Color3.fromRGB(39,35,75)
            hitboxIcon.BorderSizePixel=0
            hitboxIcon.Parent=hitboxCard
            corner(hitboxIcon,12)
            local hitboxGradient=Instance.new("UIGradient")
            hitboxGradient.Color=ColorSequence.new(Color3.fromRGB(121,78,207),Color3.fromRGB(28,147,166))
            hitboxGradient.Rotation=35
            hitboxGradient.Parent=hitboxIcon
            label(hitboxIcon,"▣",UDim2.fromScale(0,0),UDim2.fromScale(1,1),31,CYAN,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            label(hitboxCard,"HITBOX EXPANDER",UDim2.fromOffset(87,14),UDim2.new(1,-124,0,20),11,TEXT,Enum.Font.GothamBold)
            label(hitboxCard,"Body · head · torso size preview",UDim2.fromOffset(87,37),UDim2.new(1,-124,0,17),7,MUTED,Enum.Font.Gotham)
            local hbDot=Instance.new("Frame")
            hbDot.AnchorPoint=Vector2.new(0.5,0.5)
            hbDot.Position=UDim2.new(1,-23,0.5,0)
            hbDot.Size=UDim2.fromOffset(9,9)
            hbDot.BackgroundColor3=hitbox.enabled and GREEN or RED
            hbDot.BorderSizePixel=0
            hbDot.Parent=hitboxCard
            corner(hbDot,8)
            hitbox.statusDot=hbDot
            hitbox.statusText=label(hitboxCard,hitbox.enabled and "ACTIVE" or "OFF",UDim2.new(1,-65,0,0),UDim2.fromOffset(34,86),7,hitbox.enabled and GREEN or MUTED,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            hitboxCard.MouseEnter:Connect(function() tween(hitboxCard,0.15,{BackgroundColor3=PANEL3}); tween(hitboxStroke,0.15,{Transparency=0.05,Color=ACCENT}) end)
            hitboxCard.MouseLeave:Connect(function() tween(hitboxCard,0.15,{BackgroundColor3=PANEL2}); tween(hitboxStroke,0.15,{Transparency=0.42,Color=Color3.fromRGB(57,65,92)}) end)
            hitboxCard.MouseButton1Click:Connect(function()
                local dc=newContent()
                local back=makeButton(dc,"‹",UDim2.new(1,-49,0,12),UDim2.fromOffset(34,30),PANEL3)
                back.TextSize=25
                back.TextColor3=CYAN
                back.MouseButton1Click:Connect(showToolList)
                label(dc,"HITBOX EXPANDER",UDim2.fromOffset(16,17),UDim2.new(1,-78,0,22),14,TEXT,Enum.Font.GothamBold)
                label(dc,"LOCAL CHARACTER PART SIZE PREVIEW",UDim2.fromOffset(17,42),UDim2.new(1,-34,0,13),7,CYAN,Enum.Font.GothamBold)
                local sp=Instance.new("Frame")
                sp.Position=UDim2.fromOffset(14,68)
                sp.Size=UDim2.new(1,-28,0,44)
                sp.BackgroundColor3=PANEL2
                sp.BorderSizePixel=0
                sp.Parent=dc
                corner(sp,9)
                local dot=Instance.new("Frame")
                dot.Position=UDim2.fromOffset(12,17)
                dot.Size=UDim2.fromOffset(9,9)
                dot.BackgroundColor3=hitbox.enabled and GREEN or RED
                dot.BorderSizePixel=0
                dot.Parent=sp
                corner(dot,8)
                hitbox.detailDot=dot
                hitbox.detailStatus=label(sp,"",UDim2.fromOffset(30,0),UDim2.new(1,-42,1,0),8,MUTED,Enum.Font.GothamBold)
                local toggle=makeButton(dc,hitbox.enabled and "■   DISABLE HITBOX PREVIEW" or "▶   ENABLE HITBOX PREVIEW",UDim2.fromOffset(14,122),UDim2.new(1,-28,0,38),ACCENT_DARK)
                toggle.TextSize=9
                hitbox.toggleButton=toggle
                toggle.MouseButton1Click:Connect(function() if hitbox.enabled then stopHitbox() else startHitbox() end end)
                local panel=Instance.new("Frame")
                panel.Position=UDim2.fromOffset(14,171)
                panel.Size=UDim2.new(1,-28,0,190)
                panel.BackgroundColor3=PANEL
                panel.BorderSizePixel=0
                panel.Parent=dc
                corner(panel,11)
                local outline=Instance.new("UIStroke",panel)
                outline.Color=Color3.fromRGB(48,54,80)
                outline.Transparency=0.35
                label(panel,"TARGET PART",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,16),8,MUTED,Enum.Font.GothamBold)
                local targetButtons={}
                local targetOptions={"Body","Head","Torso"}
                local function updateTargetButtons()
                    for name,button in pairs(targetButtons) do
                        local chosen=hitbox.target==name
                        button.BackgroundColor3=chosen and ACCENT_DARK or PANEL3
                        button.TextColor3=chosen and TEXT or MUTED
                    end
                end
                for index,name in ipairs(targetOptions) do
                    local button=makeButton(panel,string.upper(name),UDim2.new((index-1)/3,12,0,32),UDim2.new(1/3,-16,0,30),PANEL3)
                    button.TextSize=8
                    targetButtons[name]=button
                    button.MouseButton1Click:Connect(function()
                        if hitbox.target==name then return end
                        restoreHitboxes()
                        hitbox.target=name
                        updateTargetButtons()
                        if hitbox.enabled then applyHitboxes() end
                    end)
                end
                updateTargetButtons()
                label(panel,"SIZE MULTIPLIER  (1.0× – 4.0×)",UDim2.fromOffset(12,76),UDim2.new(1,-100,0,16),8,MUTED,Enum.Font.GothamBold)
                local sizeBox=Instance.new("TextBox")
                sizeBox.Position=UDim2.new(1,-76,0,70)
                sizeBox.Size=UDim2.fromOffset(62,30)
                sizeBox.BackgroundColor3=PANEL3
                sizeBox.BorderSizePixel=0
                sizeBox.Text=tostring(hitbox.scale).."x"
                sizeBox.ClearTextOnFocus=false
                sizeBox.Font=Enum.Font.GothamBold
                sizeBox.TextSize=11
                sizeBox.TextColor3=TEXT
                sizeBox.Parent=panel
                corner(sizeBox,7)
                sizeBox.FocusLost:Connect(function()
                    local value=tonumber((string.gsub(sizeBox.Text,"x","")))
                    if not value then sizeBox.Text=tostring(hitbox.scale).."x"; return end
                    hitbox.scale=math.clamp(value,1,4)
                    sizeBox.Text=string.format("%.1fx",hitbox.scale)
                    if hitbox.enabled then restoreHitboxes(); applyHitboxes() end
                end)
                label(panel,"Changes are client-side only. Server hit detection is unchanged.",UDim2.fromOffset(12,116),UDim2.new(1,-24,0,45),7,MUTED,Enum.Font.Gotham)
                dc.Destroying:Connect(function()
                    if hitbox.detailDot==dot then hitbox.detailDot=nil end
                    if hitbox.detailStatus and hitbox.detailStatus.Parent==sp then hitbox.detailStatus=nil end
                    if hitbox.toggleButton==toggle then hitbox.toggleButton=nil end
                end)
                if hitbox.detailStatus then
                    hitbox.detailStatus.Text=hitbox.enabled and "LOCAL HITBOX PREVIEW IS ACTIVE" or "HITBOX PREVIEW IS OFF"
                    hitbox.detailStatus.TextColor3=hitbox.enabled and GREEN or MUTED
                end
            end)

            -- Fullbright tool card
            local fullbrightCard=Instance.new("TextButton")
            fullbrightCard.Name="Tool_Fullbright"
            fullbrightCard.Position=UDim2.fromOffset(14,195)
            fullbrightCard.Size=UDim2.new(1,-28,0,86)
            fullbrightCard.BackgroundColor3=PANEL2
            fullbrightCard.BorderSizePixel=0
            fullbrightCard.Text=""
            fullbrightCard.AutoButtonColor=false
            fullbrightCard.Parent=content
            corner(fullbrightCard,12)
            local fullbrightStroke=Instance.new("UIStroke",fullbrightCard)
            fullbrightStroke.Color=Color3.fromRGB(57,65,92)
            fullbrightStroke.Transparency=0.42
            local sunIcon=Instance.new("Frame")
            sunIcon.Position=UDim2.fromOffset(11,11)
            sunIcon.Size=UDim2.fromOffset(64,64)
            sunIcon.BackgroundColor3=Color3.fromRGB(54,45,91)
            sunIcon.BorderSizePixel=0
            sunIcon.Parent=fullbrightCard
            corner(sunIcon,12)
            local sunGradient=Instance.new("UIGradient")
            sunGradient.Color=ColorSequence.new(Color3.fromRGB(119,83,194),Color3.fromRGB(31,125,151))
            sunGradient.Rotation=35
            sunGradient.Parent=sunIcon
            local sun=label(sunIcon,"☀",UDim2.fromScale(0,0),UDim2.fromScale(1,1),32,Color3.fromRGB(255,239,173),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            sun.TextYAlignment=Enum.TextYAlignment.Center
            label(fullbrightCard,"FULLBRIGHT",UDim2.fromOffset(87,14),UDim2.new(1,-124,0,20),11,TEXT,Enum.Font.GothamBold)
            label(fullbrightCard,"Brighter world · reduced shadows and fog",UDim2.fromOffset(87,37),UDim2.new(1,-124,0,17),7,MUTED,Enum.Font.Gotham)
            local fbDot=Instance.new("Frame")
            fbDot.AnchorPoint=Vector2.new(0.5,0.5)
            fbDot.Position=UDim2.new(1,-23,0.5,0)
            fbDot.Size=UDim2.fromOffset(9,9)
            fbDot.BackgroundColor3=fullbright.enabled and GREEN or RED
            fbDot.BorderSizePixel=0
            fbDot.Parent=fullbrightCard
            corner(fbDot,8)
            fullbright.statusDot=fbDot
            fullbright.statusText=label(fullbrightCard,fullbright.enabled and "ACTIVE" or "OFF",UDim2.new(1,-65,0,0),UDim2.fromOffset(34,86),7,fullbright.enabled and GREEN or MUTED,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            fullbrightCard.MouseEnter:Connect(function() tween(fullbrightCard,0.15,{BackgroundColor3=PANEL3}); tween(fullbrightStroke,0.15,{Transparency=0.05,Color=ACCENT}) end)
            fullbrightCard.MouseLeave:Connect(function() tween(fullbrightCard,0.15,{BackgroundColor3=PANEL2}); tween(fullbrightStroke,0.15,{Transparency=0.42,Color=Color3.fromRGB(57,65,92)}) end)
            fullbrightCard.MouseButton1Click:Connect(function()
                local dc=newContent()
                local back=makeButton(dc,"‹",UDim2.new(1,-49,0,12),UDim2.fromOffset(34,30),PANEL3)
                back.TextSize=25
                back.TextColor3=CYAN
                back.MouseButton1Click:Connect(showToolList)
                label(dc,"FULLBRIGHT",UDim2.fromOffset(16,17),UDim2.new(1,-78,0,22),14,TEXT,Enum.Font.GothamBold)
                label(dc,"WORLD LIGHTING ENHANCEMENT",UDim2.fromOffset(17,42),UDim2.new(1,-34,0,13),7,CYAN,Enum.Font.GothamBold)
                local sp=Instance.new("Frame")
                sp.Position=UDim2.fromOffset(14,68)
                sp.Size=UDim2.new(1,-28,0,44)
                sp.BackgroundColor3=PANEL2
                sp.BorderSizePixel=0
                sp.Parent=dc
                corner(sp,9)
                local dot=Instance.new("Frame")
                dot.Position=UDim2.fromOffset(12,17)
                dot.Size=UDim2.fromOffset(9,9)
                dot.BackgroundColor3=fullbright.enabled and GREEN or RED
                dot.BorderSizePixel=0
                dot.Parent=sp
                corner(dot,8)
                fullbright.detailDot=dot
                fullbright.detailStatus=label(sp,"",UDim2.fromOffset(30,0),UDim2.new(1,-42,1,0),8,MUTED,Enum.Font.GothamBold)
                local toggle=makeButton(dc,fullbright.enabled and "■   DISABLE FULLBRIGHT" or "☀   ENABLE FULLBRIGHT",UDim2.fromOffset(14,122),UDim2.new(1,-28,0,38),ACCENT_DARK)
                toggle.TextSize=10
                fullbright.toggleButton=toggle
                toggle.MouseButton1Click:Connect(function() if fullbright.enabled then stopFullbright() else startFullbright() end end)
                local info=Instance.new("Frame")
                info.Position=UDim2.fromOffset(14,174)
                info.Size=UDim2.new(1,-28,0,105)
                info.BackgroundColor3=PANEL
                info.BorderSizePixel=0
                info.Parent=dc
                corner(info,11)
                local infoStroke=Instance.new("UIStroke",info)
                infoStroke.Color=Color3.fromRGB(48,54,80)
                infoStroke.Transparency=0.35
                label(info,"LIGHTING OVERRIDES",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,16),8,MUTED,Enum.Font.GothamBold)
                label(info,"• Bright ambient and outdoor lighting\n• Reduced fog and global shadows\n• Daytime lighting (14:00)\n• Original lighting restored when disabled",
                    UDim2.fromOffset(12,31),UDim2.new(1,-24,0,67),8,TEXT,Enum.Font.Gotham)
                dc.Destroying:Connect(function()
                    if fullbright.detailDot==dot then fullbright.detailDot=nil end
                    if fullbright.detailStatus and fullbright.detailStatus.Parent==sp then fullbright.detailStatus=nil end
                    if fullbright.toggleButton==toggle then fullbright.toggleButton=nil end
                end)
                updateFullbrightUI()
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
        label(content, "LOADER AND INTEGRATED LIBRARY BUILD", UDim2.fromOffset(18, 40), UDim2.new(1, -36, 0, 14), 8, CYAN, Enum.Font.GothamBold)

        local componentStatuses = config.componentStatuses or {}
        local currentStatus = (config.versionState and config.versionState.status) or config.versionStatus or "UNKNOWN"
        versionBadge.Text = "v" .. tostring(config.version or "?") .. " · " .. currentStatus
        versionBadge.TextColor3 = currentStatus == "UP TO DATE" and GREEN or (currentStatus == "OUTDATED" and RED or MUTED)
        local rows = {
            {"LOADER", tostring(componentStatuses.Loader or "UNKNOWN")},
            {"LIBRARY", tostring(componentStatuses.GeneralScripts or "UNKNOWN")},
            {"ESP MODULE", "INTEGRATED"},
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
        label(content, "OUTDATED means this downloaded component does not match the published build. Re-execute the latest loader to replace it. ESP now runs directly inside the General Tools library.", UDim2.fromOffset(17, 326), UDim2.new(1, -34, 0, 48), 8, MUTED, Enum.Font.Gotham)
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
            {date = "21 NOV 2026 · GENERAL TOOLS", title = "Added Hitbox Expander controls", body = "Added Body, Head and Torso target selection with an adjustable 1.0×–4.0× local part-size preview. Disabling the tool or closing the library restores the original part sizes.", affected = "Affects: General Tools. Client-side only; server-authoritative hit detection is unchanged."},
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
