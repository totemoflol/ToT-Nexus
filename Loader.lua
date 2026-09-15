-- ==================================================================================
-- ToT Nexus | Universal Loader + branded splash UI
-- Detects the current game, shows its Roblox icon, plays the boot sequence,
-- then executes the game script. All network fetches run in parallel.
-- ==================================================================================

local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = Players.LocalPlayer

local VERSION = "3.10"

local BASE = "https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main"

-- Registered games: key = main PlaceId
-- Features: listed in the boot feed by name.
-- GatedFeatures: shown as masked (•••••• + LOCKED) unless the user passes
--                the game's Whitelist file (UserId table).
local Games = {
    [122079988266644] = { -- Idle Potato Game
        Name = "Idle Potato Game",
        UniverseId = 9655897254,
        Script = BASE .. "/idle%20potato%20game/MainScript.lua",
        Whitelist = BASE .. "/idle%20potato%20game/WhitelistedTaters.lua",
        Features = { "Sell", "Auto", "Rebirths", "Boosts", "Misc", "Shop", "Macro" },
        GatedFeatures = { "Premium", "Webhook" },
    },
    -- [PLACE_ID] = {
    --     Name = "Game Name", UniverseId = 0,
    --     Script = BASE .. "/folder/MainScript.lua",
    --     Whitelist = BASE .. "/folder/WhitelistedTaters.lua",
    --     Features = { "..." },
    --     GatedFeatures = { "..." },
    -- },
}

local ACCENT = Color3.fromRGB(124, 92, 255)  -- purple
local ACCENT2 = Color3.fromRGB(64, 224, 255) -- cyan
local TEXT = Color3.fromRGB(235, 238, 250)
local MUTED = Color3.fromRGB(148, 152, 176)
local CARD = Color3.fromRGB(16, 17, 26)
local ITEM = Color3.fromRGB(25, 26, 38)
local RED = Color3.fromRGB(255, 92, 110)

-- ==================================================================================
-- Detection (PlaceId -> UniverseId -> marketplace name)
-- ==================================================================================
local function detectGame()
    local entry = Games[game.PlaceId]
    if not entry then
        for _, g in pairs(Games) do
            if g.UniverseId == game.GameId then
                entry = g
                break
            end
        end
    end
    if not entry then
        local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
        if ok and info and info.Name then
            local lowerName = string.lower(info.Name)
            for _, g in pairs(Games) do
                if string.find(lowerName, string.lower(g.Name), 1, true) then
                    entry = g
                    break
                end
            end
        end
    end
    return entry
end

-- Game photo via the Roblox thumbnails API -> CDN url (nil on failure)
local function fetchGameIcon(placeId)
    local ok, body = pcall(function()
        return game:HttpGet("https://thumbnails.roblox.com/v1/places/gameicons?placeIds="
            .. placeId .. "&size=512x512&format=Png")
    end)
    if not ok then return nil end

    local okD, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not okD or type(data) ~= "table" or type(data.data) ~= "table" then
        return nil
    end

    local entry = data.data[1]
    if entry and entry.state == "Completed" and entry.imageUrl then
        return entry.imageUrl
    end
    return nil
end

-- ==================================================================================
-- Splash UI
-- ==================================================================================
local function createSplash()
    local parent = (gethui and gethui()) or game:GetService("CoreGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "ToTNexusLoader"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(400, 480)
    local W = math.min(400, math.floor(vp.X * 0.92))
    local H = math.min(480, math.floor(vp.Y * 0.9))
    local compact = H < 380 -- small screens: skip the game showcase panel

    local card = Instance.new("CanvasGroup")
    card.Name = "Card"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(W, H)
    card.BackgroundColor3 = CARD
    card.GroupTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(46, 48, 74)
    stroke.Thickness = 1
    stroke.Transparency = 0.25
    stroke.Parent = card

    -- ==============================================================================
    -- Ambience: drifting starfield + breathing border (cheap: two looped tweens,
    -- stars are 2-3px frames with linear drift, no per-frame Lua)
    -- ==============================================================================
    local stars = {}
    for i = 1, 12 do
        local star = Instance.new("Frame")
        star.Size = UDim2.fromOffset(math.random(2, 3), math.random(2, 3))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = (i % 3 == 0) and ACCENT2 or Color3.fromRGB(210, 214, 240)
        star.BackgroundTransparency = 0.55 + math.random() * 0.3
        star.BorderSizePixel = 0
        star.Parent = card
        stars[i] = star

        task.spawn(function()
            while star.Parent do
                local riseH = math.random(60, 120)
                local dur = 4 + math.random() * 4
                star.Position = UDim2.new(math.random(), 0, 1, math.random(0, 40))
                local t = TweenService:Create(star,
                    TweenInfo.new(dur, Enum.EasingStyle.Linear),
                    { Position = star.Position - UDim2.fromOffset(0, riseH) })
                t:Play()
                t.Completed:Wait()
            end
        end)
    end

    task.spawn(function()
        while gui.Parent do
            local up = TweenService:Create(stroke,
                TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Color = ACCENT, Transparency = 0.1 })
            up:Play()
            up.Completed:Wait()
            if not gui.Parent then break end
            local down = TweenService:Create(stroke,
                TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Color = Color3.fromRGB(46, 48, 74), Transparency = 0.25 })
            down:Play()
            down.Completed:Wait()
        end
    end)

    -- Header: logo + wordmark + version ----------------------------------------------
    local rings = Instance.new("Frame")
    rings.Position = UDim2.fromOffset(24, 22)
    rings.Size = UDim2.fromOffset(44, 44)
    rings.BackgroundTransparency = 1
    rings.Parent = card

    local function ring(size, color, thickness, transparency)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.fromScale(0.5, 0.5)
        f.Size = UDim2.fromOffset(size, size)
        f.BackgroundTransparency = 1
        f.Parent = rings
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = f
        local s = Instance.new("UIStroke")
        s.Color = color
        s.Thickness = thickness
        s.Transparency = transparency
        s.Parent = f
        return f
    end

    local ringOuter = ring(44, ACCENT, 2, 0.2)
    local ringInner = ring(30, ACCENT2, 1.5, 0.4)

    local orbit = Instance.new("Frame")
    orbit.Size = UDim2.fromOffset(6, 6)
    orbit.Position = UDim2.new(1, -3, 0.5, 0)
    orbit.AnchorPoint = Vector2.new(0.5, 0.5)
    orbit.BackgroundColor3 = ACCENT2
    orbit.BorderSizePixel = 0
    orbit.Parent = ringOuter
    local oc = Instance.new("UICorner")
    oc.CornerRadius = UDim.new(1, 0)
    oc.Parent = orbit

    local core = Instance.new("Frame")
    core.AnchorPoint = Vector2.new(0.5, 0.5)
    core.Position = UDim2.fromScale(0.5, 0.5)
    core.Size = UDim2.fromOffset(6, 6)
    core.BackgroundColor3 = ACCENT
    core.BorderSizePixel = 0
    core.Parent = rings
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = core

    TweenService:Create(ringOuter,
        TweenInfo.new(2.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), { Rotation = 360 }):Play()
    TweenService:Create(ringInner,
        TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), { Rotation = -360 }):Play()
    TweenService:Create(core,
        TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
        { Size = UDim2.fromOffset(11, 11) }):Play()

    local brand = Instance.new("TextLabel")
    brand.Position = UDim2.fromOffset(80, 24)
    brand.Size = UDim2.new(1, -160, 0, 24)
    brand.BackgroundTransparency = 1
    brand.Font = Enum.Font.GothamBlack
    brand.TextSize = 22
    brand.TextColor3 = TEXT
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Text = "ToT Nexus"
    brand.Parent = card

    local brandGrad = Instance.new("UIGradient")
    brandGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, ACCENT2),
    })
    brandGrad.Rotation = 15
    brandGrad.Offset = Vector2.new(-1, 0)
    brandGrad.Parent = brand
    TweenService:Create(brandGrad,
        TweenInfo.new(2.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
        { Offset = Vector2.new(1, 0) }):Play()

    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(80, 48)
    subtitle.Size = UDim2.new(1, -160, 0, 14)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextColor3 = MUTED
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Text = "universal hub"
    subtitle.Parent = card

    local version = Instance.new("TextLabel")
    version.AnchorPoint = Vector2.new(1, 0)
    version.Position = UDim2.new(1, -24, 0, 28)
    version.Size = UDim2.fromOffset(60, 14)
    version.BackgroundTransparency = 1
    version.Font = Enum.Font.GothamMedium
    version.TextSize = 11
    version.TextColor3 = MUTED
    version.TextXAlignment = Enum.TextXAlignment.Right
    version.Text = "v" .. VERSION
    version.Parent = card

    -- Divider ------------------------------------------------------------------------
    local divider = Instance.new("Frame")
    divider.Position = UDim2.new(0, 24, 0, 82)
    divider.Size = UDim2.new(1, -48, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(44, 46, 70)
    divider.BorderSizePixel = 0
    divider.Parent = card
    local dgrad = Instance.new("UIGradient")
    dgrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.15, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 0.85),
    })
    dgrad.Parent = divider

    -- Status -------------------------------------------------------------------------
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Position = UDim2.fromOffset(24, 96)
    statusLabel.Size = UDim2.new(1, -48, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 9
    statusLabel.TextColor3 = Color3.fromRGB(108, 112, 138)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Text = "STATUS"
    statusLabel.Parent = card

    local status = Instance.new("TextLabel")
    status.Position = UDim2.fromOffset(24, 110)
    status.Size = UDim2.new(1, -48, 0, 18)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 13
    status.TextColor3 = TEXT
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTransparency = 1
    status.Text = ""
    status.Parent = card

    -- Game showcase (icon + name), revealed on detection ----------------------------
    local showcase, icon, iconStroke, gameNameLabel
    if not compact then
        showcase = Instance.new("CanvasGroup")
        showcase.Position = UDim2.fromOffset(24, 136)
        showcase.Size = UDim2.new(1, -48, 0, 76)
        showcase.BackgroundTransparency = 1
        showcase.GroupTransparency = 1
        showcase.Visible = false
        showcase.Parent = card

        icon = Instance.new("ImageLabel")
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, 2, 0.5, 0)
        icon.Size = UDim2.fromOffset(58, 58)
        icon.BackgroundColor3 = ITEM
        icon.BorderSizePixel = 0
        icon.Image = ""
        icon.Parent = showcase
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 14)
        iconCorner.Parent = icon
        iconStroke = Instance.new("UIStroke")
        iconStroke.Color = ACCENT
        iconStroke.Thickness = 1.5
        iconStroke.Transparency = 0.45
        iconStroke.Parent = icon

        local detTag = Instance.new("TextLabel")
        detTag.Position = UDim2.fromOffset(74, 14)
        detTag.Size = UDim2.new(1, -80, 0, 10)
        detTag.BackgroundTransparency = 1
        detTag.Font = Enum.Font.GothamBold
        detTag.TextSize = 9
        detTag.TextColor3 = ACCENT2
        detTag.TextXAlignment = Enum.TextXAlignment.Left
        detTag.Text = "GAME DETECTED"
        detTag.Parent = showcase

        gameNameLabel = Instance.new("TextLabel")
        gameNameLabel.Position = UDim2.fromOffset(74, 28)
        gameNameLabel.Size = UDim2.new(1, -80, 0, 20)
        gameNameLabel.BackgroundTransparency = 1
        gameNameLabel.Font = Enum.Font.GothamBold
        gameNameLabel.TextSize = 15
        gameNameLabel.TextColor3 = TEXT
        gameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        gameNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        gameNameLabel.Text = ""
        gameNameLabel.Parent = showcase

        local detLine = Instance.new("TextLabel")
        detLine.Position = UDim2.fromOffset(74, 50)
        detLine.Size = UDim2.new(1, -80, 0, 12)
        detLine.BackgroundTransparency = 1
        detLine.Font = Enum.Font.Gotham
        detLine.TextSize = 10
        detLine.TextColor3 = MUTED
        detLine.TextXAlignment = Enum.TextXAlignment.Left
        detLine.Text = "loading modules..."
        detLine.Parent = showcase
    end

    -- Feature feed (new items slide in, old ones push up & clip out) -----------------
    local feed = Instance.new("Frame")
    feed.BackgroundTransparency = 1
    feed.ClipsDescendants = true
    feed.Parent = card
    if compact then
        feed.AnchorPoint = Vector2.new(0, 1)
        feed.Position = UDim2.new(0, 24, 1, -64)
        feed.Size = UDim2.new(1, -48, 0, H - 140 - 64)
    else
        feed.Position = UDim2.fromOffset(24, 222)
        feed.Size = UDim2.new(1, -48, 1, -286)
    end

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = feed

    -- Progress bar -------------------------------------------------------------------
    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(0.5, 1)
    track.Position = UDim2.new(0.5, 0, 1, -46)
    track.Size = UDim2.new(1, -48, 0, 3)
    track.BackgroundColor3 = Color3.fromRGB(34, 36, 52)
    track.BorderSizePixel = 0
    track.Parent = card
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill
    local fg = Instance.new("UIGradient")
    fg.Color = ColorSequence.new(ACCENT, ACCENT2)
    fg.Parent = fill

    local footer = Instance.new("TextLabel")
    footer.AnchorPoint = Vector2.new(0, 1)
    footer.Position = UDim2.new(0, 24, 1, -18)
    footer.Size = UDim2.new(1, -48, 0, 12)
    footer.BackgroundTransparency = 1
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 10
    footer.TextColor3 = MUTED
    footer.TextTransparency = 0.4
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Text = "ToT Nexus"
    footer.Parent = card

    -- Intro --------------------------------------------------------------------------
    TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { GroupTransparency = 0 }):Play()

    -- Controller ---------------------------------------------------------------------
    local api = {}
    local order = 0

    function api.status(text, color, frac)
        local out = TweenService:Create(status, TweenInfo.new(0.1), { TextTransparency = 1 })
        out:Play()
        out.Completed:Wait()
        status.Text = text
        status.TextColor3 = color or TEXT
        TweenService:Create(status, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
        if frac then
            TweenService:Create(fill, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = UDim2.fromScale(frac, 1) }):Play()
        end
    end

    -- Game showcase: Roblox icon + name, popped in with a bounce
    function api.showGame(iconUrl, name)
        if not showcase then return end
        gameNameLabel.Text = name or ""

        if iconUrl then
            pcall(function()
                icon.Image = iconUrl
                ContentProvider:PreloadAsync({ icon })
            end)
        end

        showcase.Visible = true
        TweenService:Create(showcase, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { GroupTransparency = 0 }):Play()
        TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(72, 72) }):Play()
        TweenService:Create(iconStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad),
            { Transparency = 0.1 }):Play()
    end

    -- masked = gated feature for a non-whitelisted user (shown as •••••• / LOCKED)
    function api.feature(name, masked)
        order = order + 1

        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 0)
        item.BackgroundTransparency = 1
        item.ClipsDescendants = true
        item.LayoutOrder = order
        item.Parent = feed

        local inner = Instance.new("Frame")
        inner.Size = UDim2.new(1, 0, 1, 0)
        inner.Position = UDim2.fromScale(0, 1)
        inner.BackgroundColor3 = masked and Color3.fromRGB(21, 22, 33) or ITEM
        inner.BorderSizePixel = 0
        inner.Parent = item
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 6)
        ic.Parent = inner
        local is = Instance.new("UIStroke")
        is.Color = Color3.fromRGB(42, 44, 66)
        is.Transparency = masked and 0.2 or 0.5
        is.Parent = inner

        local dot = Instance.new("Frame")
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.new(0, 10, 0.5, 0)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.BackgroundColor3 = Color3.fromRGB(90, 94, 120)
        dot.BorderSizePixel = 0
        dot.Parent = inner
        local dc = Instance.new("UICorner")
        dc.CornerRadius = UDim.new(1, 0)
        dc.Parent = dot

        local label = Instance.new("TextLabel")
        label.Position = UDim2.new(0, 26, 0, 0)
        label.Size = UDim2.new(1, -26, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextColor3 = masked and Color3.fromRGB(108, 112, 138) or TEXT
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = name
        label.Parent = inner

        local tag = Instance.new("TextLabel")
        tag.AnchorPoint = Vector2.new(1, 0.5)
        tag.Position = UDim2.new(1, -10, 0.5, 0)
        tag.BackgroundTransparency = 1
        tag.Font = Enum.Font.GothamBold
        tag.TextSize = 9
        tag.TextColor3 = masked and MUTED or ACCENT2
        tag.TextTransparency = 1
        tag.Text = masked and "LOCKED" or "OK"
        tag.Parent = inner

        TweenService:Create(item, TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, 0, 0, 30) }):Play()
        TweenService:Create(inner, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Position = UDim2.fromScale(0, 0) }):Play()
        task.delay(0.18, function()
            if not masked then
                TweenService:Create(dot, TweenInfo.new(0.2), { BackgroundColor3 = ACCENT }):Play()
            end
            TweenService:Create(tag, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        end)
    end

    function api.fail(text)
        api.status(text, RED, 1)
        ringOuter.UIStroke.Color = RED
        ringInner.UIStroke.Color = RED
        core.BackgroundColor3 = RED
        orbit.BackgroundColor3 = RED
    end

    -- Small admin button shown during loading (globally whitelisted users only)
    function api.adminButton(onClick)
        local b = Instance.new("TextButton")
        b.AnchorPoint = Vector2.new(1, 1)
        b.Position = UDim2.new(1, -24, 1, -14)
        b.Size = UDim2.fromOffset(72, 22)
        b.BackgroundColor3 = Color3.fromRGB(21, 22, 33)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = MUTED
        b.Text = "ADMIN"
        b.Parent = card
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", b)
        s.Color = Color3.fromRGB(48, 50, 74)
        s.Transparency = 0.3
        b.MouseButton1Click:Connect(onClick)
    end

    function api.finish()
        task.wait(0.35)
        local out = TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { GroupTransparency = 1 })
        out:Play()
        out.Completed:Wait()
        gui:Destroy()
    end

    return api
end

-- ==================================================================================
-- Boot sequence (all network fetches start in parallel up front)
-- ==================================================================================
print("[ToT Nexus] Loader starting")

-- Import tool for whitelisted devs: chat "import" after load to dump remotes
-- SECURITY: fetches the global whitelist directly and checks locally (no getgenv)
local function startImportTool()
    task.spawn(function()
        local ok, wl = pcall(function()
            return loadstring(game:HttpGet(BASE .. "/Whitelist.lua"))()
        end)
        if not ok or type(wl) ~= "table" then return end

        local allowed = (wl.ids and wl.ids[LocalPlayer.UserId] == true)
            or (wl.names and wl.names[string.lower(LocalPlayer.Name)] == true)

        if allowed then
            pcall(function()
                loadstring(game:HttpGet(BASE .. "/tools/ImportTool.lua"))()
            end)
        end
    end)
end

local splashOk, splash = pcall(createSplash)
if not splashOk then
    splash = nil
    warn("[ToT Nexus] Splash unavailable, running headless")
end

local function status(text, color, frac)
    if splash then
        splash.status(text, color, frac)
    end
end

status("Initializing...", nil, 0.06)
task.wait(0.4)

status("Fetching interface assets...", nil, 0.2)
-- Warm the library AND keep the source: MainScript reuses it instead of
-- re-downloading ~200KB of Rayfield
task.spawn(function()
    local ok, src = pcall(function() return game:HttpGet("https://sirius.menu/rayfield") end)
    if ok and type(src) == "string" and #src > 1000 then
        getgenv().TatoNexusRayfieldSrc = src
    end
end)

status("Detecting game...", nil, 0.38)
task.wait(0.25)

local entry = detectGame()

if not entry then
    local gameName = "Unknown"
    local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    if ok and info and info.Name then
        gameName = info.Name
    end

    print("[ToT Nexus] Unsupported game: " .. gameName .. " (PlaceId: " .. game.PlaceId .. ")")
    if splash then
        splash.fail("Unsupported: " .. gameName)
    end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ToT Nexus",
            Text = "This game is not supported yet!",
            Duration = 5,
        })
    end)
    task.spawn(function()
        task.wait(2)
        if splash then splash.finish() end
    end)
    startImportTool()
    return
end

print("[ToT Nexus] Game detected: " .. entry.Name)
status("Detected: " .. entry.Name, ACCENT2, 0.55)

-- Parallel fetch crew: game script, game icon, game whitelist, global whitelist
local scriptSrc, fetchErr, iconUrl = nil, nil, nil
local gameWl, globalWl = nil, nil
local done = { script = false, icon = false, gameWl = not entry.Whitelist, globalWl = false }

task.spawn(function()
    local ok, src = pcall(function() return game:HttpGet(entry.Script) end)
    if ok then scriptSrc = src else fetchErr = src end
    done.script = true
end)

task.spawn(function()
    iconUrl = fetchGameIcon(game.PlaceId)
    done.icon = true
end)

if entry.Whitelist then
    task.spawn(function()
        local ok, wl = pcall(function()
            return loadstring(game:HttpGet(entry.Whitelist))()
        end)
        if ok then gameWl = wl end
        done.gameWl = true
    end)
end

task.spawn(function()
    local ok, gwl = pcall(function()
        return loadstring(game:HttpGet(BASE .. "/Whitelist.lua"))()
    end)
    if ok then globalWl = gwl end
    done.globalWl = true
end)

-- Showcase the detected game while the fetches run (brief wait for the icon)
local iconWait = 0
while not done.icon and iconWait < 1.5 do
    task.wait(0.05)
    iconWait = iconWait + 0.05
end
if splash then
    splash.showGame(iconUrl, entry.Name)
end
task.wait(0.4)

-- Gate check: are gated features visible for this user? (join the parallel fetch, 3s cap)
local joinStart = os.clock()
while not (done.gameWl and done.globalWl) and os.clock() - joinStart < 3 do
    task.wait(0.05)
end

local whitelistedUser = false
if entry.GatedFeatures and #entry.GatedFeatures > 0 then
    whitelistedUser = type(gameWl) == "table"
        and type(gameWl.ids) == "table"
        and gameWl.ids[LocalPlayer.UserId] == true
end

-- Global whitelist gate (admin panel button window during loading)
if type(globalWl) == "table"
    and ((globalWl.ids and globalWl.ids[LocalPlayer.UserId] == true)
        or (globalWl.names and globalWl.names[string.lower(LocalPlayer.Name)] == true))
    and splash then
    splash.adminButton(function()
        pcall(function()
            loadstring(game:HttpGet(BASE .. "/tools/AdminPanel.lua"))()
        end)
    end)
end

-- Feature feed: normal features by name, gated ones masked unless whitelisted
local feedItems = {}
for _, f in ipairs(entry.Features or {}) do
    feedItems[#feedItems + 1] = { name = f }
end
for _, f in ipairs(entry.GatedFeatures or {}) do
    feedItems[#feedItems + 1] = { name = whitelistedUser and f or "••••••", masked = not whitelistedUser }
end

status("Loading features...", nil, 0.6)
local total = #feedItems
for i, feedItem in ipairs(feedItems) do
    if splash then
        splash.feature(feedItem.name, feedItem.masked)
    end
    task.wait(0.26)
    if splash then
        splash.status("Loading features... (" .. i .. "/" .. total .. ")", nil, 0.6 + 0.38 * (i / total))
    end
end

-- Wait for the parallel script fetch (15s timeout)
local waited = 0
while not scriptSrc and not fetchErr and waited < 15 do
    task.wait(0.05)
    waited = waited + 0.05
end

if not scriptSrc then
    print("[ToT Nexus] Failed to fetch game script: " .. tostring(fetchErr))
    if splash then
        splash.fail("Failed to load script")
    end
    task.spawn(function()
        task.wait(2)
        if splash then splash.finish() end
    end)
    startImportTool()
    return
end

status("Ready - enjoy!", ACCENT2, 1)
startImportTool()
if splash then
    splash.finish()
end

print("[ToT Nexus] Executing " .. entry.Name)
loadstring(scriptSrc)()
