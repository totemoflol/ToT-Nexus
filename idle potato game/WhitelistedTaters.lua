-- WhitelistedTaters.lua | Premium whitelist
-- Add usernames to the list below (case doesn't matter).
-- UserId ranks are also checked, gated by `mode` for finer control.

local mode = "Devs" -- Owner | Devs | Premium

-- Whitelisted usernames (case-insensitive)
local Usernames = {
    "Totemoflol",
    "Banmelikeagoodboy672",
}

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

local nameWhitelist = {}
for _, name in ipairs(Usernames) do
    nameWhitelist[string.lower(name)] = true
end

-- Kept for backwards compatibility (UserId-only check)
getgenv().whitelistedtaters = idWhitelist

-- Case-insensitive check: UserId OR username
getgenv().isTaterWhitelisted = function(player)
    if idWhitelist[player.UserId] then return true end
    return nameWhitelist[string.lower(player.Name)] == true
end

print("[ToT Nexus] Whitelist loaded (" .. mode .. ")")
