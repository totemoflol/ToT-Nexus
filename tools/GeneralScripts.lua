-- ToT Nexus | Game Library
-- Displays registered games and lets the user explicitly select and execute one.

local TweenService = game:GetService("TweenService")
local ACCENT = Color3.fromRGB(130, 105, 255)
local CYAN = Color3.fromRGB(65, 220, 255)
local BG = Color3.fromRGB(13, 15, 24)
local PANEL = Color3.fromRGB(22, 25, 38)
local PANEL2 = Color3.fromRGB(29, 33, 49)
local TEXT = Color3.fromRGB(239, 241, 250)
local MUTED = Color3.fromRGB(145, 153, 177)
local GREEN = Color3.fromRGB(95, 224, 170)

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
    gui.Parent = parent

    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900, 600)
    local width = math.min(820, viewport.X - 28)
    local height = math.min(520, viewport.Y - 40)
    local compact = width < 570

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(width, height)
    card.BackgroundColor3 = BG
    card.BorderSizePixel = 0
    card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
    local border = Instance.new("UIStroke", card)
    border.Color = Color3.fromRGB(55, 60, 86)
    border.Transparency = 0.2

    local function makeLabel(parentObject, text, position, size, fontSize, color, font)
        local item = Instance.new("TextLabel")
        item.BackgroundTransparency = 1
        item.Position = position
        item.Size = size
        item.Font = font or Enum.Font.Gotham
        item.Text = text or ""
        item.TextSize = fontSize
        item.TextColor3 = color
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.TextYAlignment = Enum.TextYAlignment.Center
        item.TextTruncate = Enum.TextTruncate.AtEnd
        item.Parent = parentObject
        return item
    end

    makeLabel(card, "ToT Nexus", UDim2.fromOffset(22, 14), UDim2.new(1, -90, 0, 26), 20, TEXT, Enum.Font.GothamBold)
    makeLabel(card, "GAME LIBRARY", UDim2.fromOffset(23, 41), UDim2.new(1, -50, 0, 14), 9, CYAN, Enum.Font.GothamBold)

    local close = Instance.new("TextButton")
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -14, 0, 13)
    close.Size = UDim2.fromOffset(32, 32)
    close.BackgroundColor3 = Color3.fromRGB(45, 34, 49)
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(255, 115, 135)
    close.TextSize = 23
    close.Font = Enum.Font.GothamBold
    close.Parent = card
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local divider = Instance.new("Frame")
    divider.Position = UDim2.fromOffset(20, 68)
    divider.Size = UDim2.new(1, -40, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(46, 50, 72)
    divider.BorderSizePixel = 0
    divider.Parent = card

    local leftWidth = compact and math.floor(width * 0.42) or 270
    local listX = 20
    local listY = 84
    local listW = leftWidth - 28
    makeLabel(card, "CURRENT GAME", UDim2.fromOffset(listX, listY), UDim2.fromOffset(listW, 15), 9, CYAN, Enum.Font.GothamBold)

    local list = Instance.new("ScrollingFrame")
    list.Position = UDim2.fromOffset(listX, listY + 22)
    list.Size = UDim2.new(0, listW, 1, -(listY + 42))
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = ACCENT
    list.CanvasSize = UDim2.new()
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = card
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    local panelX = leftWidth
    local panelW = width - leftWidth - 20
    local detail = Instance.new("Frame")
    detail.Position = UDim2.fromOffset(panelX, 84)
    detail.Size = UDim2.new(0, panelW, 1, -104)
    detail.BackgroundColor3 = PANEL
    detail.BorderSizePixel = 0
    detail.Parent = card
    Instance.new("UICorner", detail).CornerRadius = UDim.new(0, 13)

    local selected = nil
    local rows = {}
    local featureContainer
    local executeButton
    local statusLabel

    local function createNameplate(gameInfo, isCurrent, order)
        local row = Instance.new("TextButton")
        row.Name = "Game_" .. gameInfo.Id
        row.Size = UDim2.new(1, -4, 0, 58)
        row.BackgroundColor3 = PANEL
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = order
        row.Parent = list
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", row)
        stroke.Color = Color3.fromRGB(52, 57, 80)
        stroke.Transparency = 0.45

        local image = Instance.new("ImageLabel")
        image.Position = UDim2.fromOffset(8, 8)
        image.Size = UDim2.fromOffset(42, 42)
        image.BackgroundColor3 = PANEL2
        image.BorderSizePixel = 0
        image.Image = gameInfo.Icon or ""
        image.ScaleType = Enum.ScaleType.Crop
        image.Parent = row
        Instance.new("UICorner", image).CornerRadius = UDim.new(0, 8)

        local labelX = 59
        local labelW = listW - 72
        makeLabel(row, gameInfo.Name, UDim2.fromOffset(labelX, 8), UDim2.new(1, -labelX - 7, 0, 21), compact and 10 or 12, TEXT, Enum.Font.GothamSemibold)
        if isCurrent then
            local tag = makeLabel(row, "YOU ARE HERE", UDim2.fromOffset(labelX, 31), UDim2.new(1, -labelX - 5, 0, 14), 8, GREEN, Enum.Font.GothamBold)
        else
            makeLabel(row, gameInfo.Supported and "AVAILABLE" or "NOT SUPPORTED", UDim2.fromOffset(labelX, 31), UDim2.new(1, -labelX - 5, 0, 14), 8, MUTED, Enum.Font.GothamBold)
        end

        row.MouseButton1Click:Connect(function() end)
        rows[gameInfo.Id] = {button = row, stroke = stroke}
        return row
    end

    local function renderDetails(gameInfo)
        selected = gameInfo
        for id, rowData in pairs(rows) do
            local active = id == gameInfo.Id
            rowData.button.BackgroundColor3 = active and Color3.fromRGB(39, 35, 65) or PANEL
            rowData.stroke.Color = active and ACCENT or Color3.fromRGB(52, 57, 80)
            rowData.stroke.Transparency = active and 0.05 or 0.45
        end

        for _, child in ipairs(detail:GetChildren()) do child:Destroy() end

        local image = Instance.new("ImageLabel")
        image.AnchorPoint = Vector2.new(0.5, 0)
        image.Position = UDim2.new(0.5, 0, 0, 22)
        image.Size = UDim2.fromOffset(compact and 78 or 104, compact and 78 or 104)
        image.BackgroundColor3 = PANEL2
        image.BorderSizePixel = 0
        image.Image = gameInfo.Icon or ""
        image.ScaleType = Enum.ScaleType.Crop
        image.Parent = detail
        Instance.new("UICorner", image).CornerRadius = UDim.new(0, 17)
        local imageStroke = Instance.new("UIStroke", image)
        imageStroke.Color = ACCENT
        imageStroke.Transparency = 0.3

        local nameY = compact and 111 or 139
        local name = makeLabel(detail, gameInfo.Name, UDim2.new(0, 14, 0, nameY), UDim2.new(1, -28, 0, 28), compact and 14 or 18, TEXT, Enum.Font.GothamBold)
        name.TextXAlignment = Enum.TextXAlignment.Center
        local subtitle = makeLabel(detail, gameInfo.IsCurrent and "CURRENT EXPERIENCE" or (gameInfo.Supported and "GAME SCRIPT" or "UNAVAILABLE"), UDim2.new(0, 12, 0, nameY + 29), UDim2.new(1, -24, 0, 15), 8, CYAN, Enum.Font.GothamBold)
        subtitle.TextXAlignment = Enum.TextXAlignment.Center

        local featureY = nameY + 58
        makeLabel(detail, "FEATURES", UDim2.fromOffset(18, featureY), UDim2.new(1, -36, 0, 15), 9, MUTED, Enum.Font.GothamBold)
        local featureList = Instance.new("Frame")
        featureList.Position = UDim2.fromOffset(18, featureY + 22)
        featureList.Size = UDim2.new(1, -36, 0, math.max(70, height - featureY - 145))
        featureList.BackgroundTransparency = 1
        featureList.Parent = detail
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 7)
        layout.Parent = featureList

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
        }
        local count = 0
        for _, feature in ipairs(gameInfo.Features or {}) do
            count = count + 1
            makeLabel(featureList, "•  " .. (descriptions[feature] or feature), UDim2.new(), UDim2.new(1, 0, 0, 18), compact and 9 or 11, TEXT)
        end
        for _, feature in ipairs(gameInfo.GatedFeatures or {}) do
            count = count + 1
            makeLabel(featureList, "•  " .. (descriptions[feature] or feature), UDim2.new(), UDim2.new(1, 0, 0, 18), compact and 9 or 11, MUTED)
        end
        if count == 0 then
            makeLabel(featureList, gameInfo.Supported and "No feature list yet" or "No script for this game", UDim2.new(), UDim2.new(1, 0, 0, 18), 10, MUTED)
        end

        statusLabel = makeLabel(detail, "", UDim2.new(0, 16, 1, -65), UDim2.new(1, -32, 0, 16), 9, MUTED)
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center

        executeButton = Instance.new("TextButton")
        executeButton.AnchorPoint = Vector2.new(0.5, 1)
        executeButton.Position = UDim2.new(0.5, 0, 1, -16)
        executeButton.Size = UDim2.new(1, -32, 0, 42)
        executeButton.BackgroundColor3 = gameInfo.Supported and ACCENT or Color3.fromRGB(55, 58, 72)
        executeButton.BorderSizePixel = 0
        executeButton.Text = gameInfo.IsGeneralTools and "ENABLE ESP" or (gameInfo.Supported and "▶   EXECUTE" or "UNAVAILABLE")
        executeButton.TextColor3 = TEXT
        executeButton.TextSize = 12
        executeButton.Font = Enum.Font.GothamBold
        executeButton.AutoButtonColor = gameInfo.Supported
        executeButton.Parent = detail
        Instance.new("UICorner", executeButton).CornerRadius = UDim.new(0, 10)
        local espEnabled = false
        local espHighlights = {}
        local function clearEsp()
            for _, highlight in ipairs(espHighlights) do
                if highlight and highlight.Parent then highlight:Destroy() end
            end
            table.clear(espHighlights)
        end
        executeButton.MouseButton1Click:Connect(function()
            if not selected or not selected.Supported then return end
            if selected.IsGeneralTools then
                if espEnabled then
                    clearEsp()
                    espEnabled = false
                    executeButton.Text = "ENABLE ESP"
                    statusLabel.Text = "ESP disabled"
                    return
                end
                local folder = workspace:FindFirstChild("ToTNexusTestTargets")
                if not folder then
                    statusLabel.Text = "Create workspace.ToTNexusTestTargets first"
                    return
                end
                for _, target in ipairs(folder:GetChildren()) do
                    if target:IsA("Model") or target:IsA("BasePart") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ToTNexusTestHighlight"
                        highlight.Adornee = target
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.FillColor = ACCENT
                        highlight.OutlineColor = CYAN
                        highlight.FillTransparency = 0.78
                        highlight.OutlineTransparency = 0.05
                        highlight.Parent = target
                        table.insert(espHighlights, highlight)
                    end
                end
                espEnabled = true
                executeButton.Text = "DISABLE ESP"
                statusLabel.Text = "Highlighting test targets"
                return
            end
            executeButton.Active = false
            executeButton.Text = "LOADING..."
            statusLabel.Text = "Fetching selected game script..."
            if config.onExecute then
                task.spawn(function()
                    config.onExecute(selected)
                    if executeButton and executeButton.Parent then
                        executeButton.Active = true
                        executeButton.Text = "▶   EXECUTE"
                        statusLabel.Text = "Execution requested"
                    end
                end)
            end
        end)
    end

    -- Current game always occupies the first nameplate, followed by the catalog.
    local current = nil
    for _, item in ipairs(games) do
        if item.Id == config.currentGameId then current = item break end
    end
    if current then
        createNameplate(current, true, 0)
    end
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
