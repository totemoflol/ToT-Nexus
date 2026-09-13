-- ================================================================================
-- Tato Hub | Universal Loader
-- Detects the current game and executes the matching script.
-- Add new games to the Games table below to extend support.
-- ================================================================================

local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

local PlaceId = game.PlaceId
local GameId = game.GameId

local BASE = "https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main"

-- Registered games: key = main PlaceId
local Games = {
    [122079988266644] = { -- Idle Potato Game
        Name = "Idle Potato Game",
        UniverseId = 9655897254,
        Script = BASE .. "/idle%20potato%20game/MainScript.lua",
    },
    -- [PLACE_ID] = {
    --     Name = "Game Name",
    --     UniverseId = 0,
    --     Script = BASE .. "/game%20folder/MainScript.lua",
    -- },
}

-- 1) Exact place match
local entry = Games[PlaceId]

-- 2) Universe match (covers every place inside the same game)
if not entry then
    for _, g in pairs(Games) do
        if g.UniverseId == GameId then
            entry = g
            break
        end
    end
end

-- 3) Fallback: match by game name from the marketplace
if not entry then
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(PlaceId)
    end)
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

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
end

if entry then
    print("[Tato Hub] Game detected: " .. entry.Name .. " - loading script...")
    notify("Tato Hub", "Loading " .. entry.Name .. "...")
    loadstring(game:HttpGet(entry.Script))()
else
    local gameName = "Unknown"
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(PlaceId)
    end)
    if ok and info and info.Name then gameName = info.Name end

    local msg = string.format("Unsupported game: %s (PlaceId: %d)", gameName, PlaceId)
    warn("[Tato Hub] " .. msg)
    notify("Tato Hub", "This game is not supported yet!")
end
