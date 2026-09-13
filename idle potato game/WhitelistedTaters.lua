-- WhitelistedTaters.lua | Premium whitelist for Idle Potato Game (UserId ranks)
-- Global tool access (import tool etc.) is handled by Whitelist.lua in the repo root.
-- SECURITY: returns the id table directly; gated code must use the return value
-- (local upvalues), never getgenv(), so the checks can't be spoofed.

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

-- Legacy read-only copy (writes are silently ignored)
getgenv().whitelistedtaters = setmetatable(idWhitelist, {
    __newindex = function() end,
    __metatable = "ToT Nexus",
})

print("[ToT Nexus] Game whitelist loaded (" .. mode .. ")")

return {
    ids = idWhitelist,
}
