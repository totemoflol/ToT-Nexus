-- ==================================================================================
-- ToT Nexus | Universal Loader + branded splash UI
-- Detects the current game, plays the boot sequence, then executes the game script.
-- ==================================================================================

local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local VERSION = "3.00"

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

    -- Feature feed (new items slide in, old ones push up & clip out) -----------------
    local feed = Instance.new("Frame")
    feed.AnchorPoint = Vector2.new(0, 1)
    feed.Position = UDim2.new(0, 24, 1, -64)
    feed.Size = UDim2.new(1, -48, 0, H - 140 - 64)
    feed.BackgroundTransparency = 1
    feed.ClipsDescendants = true
    feed.Parent = card

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
-- Boot sequence
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
pcall(function() game:HttpGet("https://sirius.menu/rayfield") end) -- warm the library

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
task.wait(0.5)

-- Gate check: are gated features visible for this user?
local whitelistedUser = false
if entry.GatedFeatures and #entry.GatedFeatures > 0 and entry.Whitelist then
    local ok, wl = pcall(function()
        return loadstring(game:HttpGet(entry.Whitelist))()
    end)
    whitelistedUser = ok and type(wl) == "table"
        and type(wl.ids) == "table"
        and wl.ids[LocalPlayer.UserId] == true
end

-- Global whitelist gate (admin panel button window during loading)
do
    local ok, gwl = pcall(function()
        return loadstring(game:HttpGet(BASE .. "/Whitelist.lua"))()
    end)
    local globalAllowed = ok and type(gwl) == "table"
        and ((gwl.ids and gwl.ids[LocalPlayer.UserId] == true)
            or (gwl.names and gwl.names[string.lower(LocalPlayer.Name)] == true))

    if globalAllowed and splash then
        splash.adminButton(function()
            pcall(function()
                loadstring(game:HttpGet(BASE .. "/tools/AdminPanel.lua"))()
            end)
        end)
    end
end

-- Fetch the game script in parallel while the feature feed plays
local scriptSrc, fetchErr = nil, nil
task.spawn(function()
    local ok, src = pcall(function() return game:HttpGet(entry.Script) end)
    if ok then
        scriptSrc = src
    else
        fetchErr = src
    end
end)

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

-- Wait for the parallel fetch (15s timeout)
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
