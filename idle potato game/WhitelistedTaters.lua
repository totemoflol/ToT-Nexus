-- WhitelistedTaters.lua | Premium whitelist for Idle Potato Game (UserId ranks)
-- Global tool access (import tool etc.) is handled by Whitelist.lua in the repo root.

local mode = "Devs" -- Owner | Devs | Premium

local Ranks = {
    Diamond = {
        [4874964037] = true, -- bjdhcmain
        [1242588417] = true, -- durianlover9
    },
    Emerald = {
        [3076753381] = true, -- aaaionj2
        [4993924900] = true, -- urmotherlah6
    },
    Gold = {},
}

local activeRanks = { Diamond = true }
if mode == "Devs" then
    activeRanks.Emerald = true
elseif mode == "Premium" then
    activeRanks.Emerald = true
    activeRanks.Gold = true
end

local idWhitelist = {}
for rank, active in pairs(activeRanks) do
    if active then
        for id in pairs(Ranks[rank]) do
            idWhitelist[id] = true
        end
    end
end

getgenv().whitelistedtaters = idWhitelist

-- UserId-only check for this game's premium features
getgenv().isTaterWhitelisted = function(player)
    return idWhitelist[player.UserId] == true
end

print("[ToT Nexus] Game whitelist loaded (" .. mode .. ")")
