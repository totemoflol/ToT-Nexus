-- BoostsTab.lua | Free boosts, join claims, auto potion use
local Tato = getgenv().Tato
local Gamedata = getgenv().Gamedata or { KnownIds = { ShopItems = {
    "potion_production", "potion_luck", "potion_golden", "potion_click",
} } }

local BoostsTab = Window:CreateTab("Boosts", "zap")
BoostsTab:CreateSection("Free Boosts")
Tato.header(BoostsTab, "Free Boosts")

-- {toggle name, remote, flag}
local FreeBoosts = {
    { "Auto Free Boost (Personal)",  "ActivateFreeBoost",                 "AutoFreeBoost" },
    { "Auto Free Global Boost",      "ActivateFreeGlobalBoost",           "AutoGlobalBoost" },
    { "Auto Free Leaderboard Boost", "ActivateLeaderboardFreeGlobalBoost", "AutoLeaderboardBoost" },
}

for _, b in ipairs(FreeBoosts) do
    local name, remoteName, flag = b[1], b[2], b[3]
    BoostsTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = flag,
        Callback = Tato.loop(function()
            Tato.fire(remoteName)
            task.wait(300) -- re-fire every 5 min; server rejects if on cooldown
        end),
    })
end

BoostsTab:CreateDivider()
BoostsTab:CreateSection("Claims")
Tato.header(BoostsTab, "Auto Claim")

local autoClaim = false
BoostsTab:CreateToggle({
    Name = "Auto Claim on Join (Streak + Offline)",
    CurrentValue = false,
    Flag = "AutoClaimJoin",
    Callback = function(state)
        autoClaim = state
        if not state then return end

        task.spawn(function()
            task.wait(10) -- let the game finish loading data first
            while autoClaim do
                Tato.fire("ClaimLoginStreak")
                Tato.fire("ClaimOfflineBoostBonus")
                task.wait(1800) -- re-try every 30 min
            end
        end)
    end,
})

BoostsTab:CreateButton({
    Name = "Claim Now",
    Callback = function()
        Tato.fire("ClaimLoginStreak")
        Tato.fire("ClaimOfflineBoostBonus")
    end,
})

BoostsTab:CreateDivider()
BoostsTab:CreateSection("Potions")
Tato.header(BoostsTab, "Auto Use Potions")

BoostsTab:CreateToggle({
    Name = "Auto Use Potions (pairs with AutoBuy)",
    CurrentValue = false,
    Flag = "AutoUsePotions",
    Callback = Tato.loop(function(alive)
        for _, id in ipairs(Gamedata.KnownIds.ShopItems) do
            if not alive() then return end
            Tato.fire("UsePotion", id) -- arg assumed same id as purchase
            task.wait(0.2)
        end
        task.wait(60)
    end),
})

print("Boosts Tab Loaded")
