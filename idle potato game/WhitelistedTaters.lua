-- WhitelistedTaters.lua | Premium whitelist (Diamond = always, others by mode)
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

local TaterWhitelist = {}
for rank, active in pairs(activeRanks) do
    if active then
        for id in pairs(Ranks[rank]) do
            TaterWhitelist[id] = true
        end
    end
end

getgenv().whitelistedtaters = TaterWhitelist
