-- MacroTab.lua | Versatile macro + legacy timed macros
local Tato = getgenv().Tato
local Gamedata = getgenv().Gamedata or { KnownIds = { ClickUpgrades = {} } }

local MacroTab = Window:CreateTab("Macro", "bitcoin")

local function sell(n) Tato.fire("SellGoldenPotatoes", n) end
local function upg(n) Tato.fire("PurchaseClickUpgrade", n) end

-- ==================================================================================
-- VERSATILE MACRO
-- - Sells golden AND normal potatoes nonstop
-- - Auto-buys the click upgrade chain (stronger hands -> the final click)
--   via live cost checks, most expensive affordable first
-- - Auto-prestiges on a fixed interval (server rejects if still on cooldown)
-- ==================================================================================
MacroTab:CreateSection("Versatile Macro")
Tato.header(MacroTab, "Versatile Macro")

local UpgradeChain = Gamedata.KnownIds.ClickUpgradeChain or Gamedata.KnownIds.ClickUpgrades

local prestigeInterval = 31
MacroTab:CreateInput({
    Name = "Prestige Interval (seconds)",
    CurrentValue = "",
    PlaceholderText = "31",
    RemoveTextAfterFocusLost = false,
    Flag = "VersatilePrestigeInterval",
    Callback = function(v)
        prestigeInterval = math.max(5, tonumber(v) or 31)
    end,
})

-- Per-tier buy cap: stops over-leveling cheap tiers (+1s) while better tiers
-- (+100000s) sit unbought at the same price. When every tier hits the cap,
-- a new wave starts (counters reset).
local maxTierBuys = 15
MacroTab:CreateInput({
    Name = "Max Buys Per Tier (per wave)",
    CurrentValue = "",
    PlaceholderText = "15",
    RemoveTextAfterFocusLost = false,
    Flag = "VersatileMaxBuys",
    Callback = function(v)
        maxTierBuys = math.max(1, math.floor(tonumber(v) or 15))
    end,
})

-- Grace period: upgrade buying stops this many seconds before each prestige
-- so cash (which decides prestige points) can build up instead of being spent.
local prestigeGrace = 3
MacroTab:CreateInput({
    Name = "Prestige Grace (seconds)",
    CurrentValue = "",
    PlaceholderText = "3",
    RemoveTextAfterFocusLost = false,
    Flag = "VersatileGrace",
    Callback = function(v)
        prestigeGrace = math.max(0, tonumber(v) or 3)
    end,
})

MacroTab:CreateToggle({
    Name = "Versatile Macro",
    CurrentValue = false,
    Flag = "VersatileMacro",
    Callback = Tato.loop(function(alive)
        -- Turn on the supporting toggles (they exist as standalone toggles too)
        Tato.setToggle("AutoClick", true)
        Tato.setToggle("AutoSellGolden", true)
        Tato.setToggle("AutoSellPotatoes", true)

        local player = game:GetService("Players").LocalPlayer
        local currency = Tato.waitForPath(player.PlayerGui,
            "PotatoGameGUI", "Background", "ClickerArea", "ClickerContainer", "CurrencyFrame")
        local goldLabel = Tato.waitForPath(currency, "GoldenRow", "GoldenCount")
        local potatoLabel = Tato.waitForPath(currency, "PotatoRow", "PotatoCount")
        local cashLabel = Tato.waitForPath(currency, "CashRow", "CashCount")

        local lastSell, lastBuy = 0, 0
        -- First prestige waits a full interval so early cash isn't wasted
        local lastPrestige = os.clock()
        local lastFullRefresh = 0
        local tierBuys = {} -- purchases per tier this wave
        local costCache = {} -- id -> current cost (nil = unknown/maxed)
        local cacheLoaded = false

        -- Cost invokes are RemoteFunctions (slow) -- cache them and only
        -- re-check the tier we just bought + a full refresh every 10s
        local function refreshAllCosts()
            for _, id in ipairs(UpgradeChain) do
                local ok, res = Tato.invoke("GetUpgradeCost", id)
                costCache[id] = ok and Tato.extractCost(res) or nil
            end
            cacheLoaded = true
            lastFullRefresh = os.clock()
        end

        while alive() do
            local now = os.clock()
            local elapsed = now - lastPrestige
            local inGrace = (prestigeInterval - elapsed) <= prestigeGrace

            -- Sell pass every 0.15s (macro-local rate; SellTab stays at 0.25s)
            if now - lastSell >= 0.15 then
                lastSell = now
                local gold = Tato.parseCount(goldLabel.Text)
                if gold > 0 then
                    sell(gold)
                end
                local potatoes = Tato.parseCount(potatoLabel.Text)
                if potatoes > 0 then
                    Tato.fire("SellPotatoes", potatoes)
                end
            end

            -- Buy pass every 0.05s, paused during the pre-prestige grace:
            -- keep cash (prestige points) instead of spending it
            if not inGrace and now - lastBuy >= 0.05 then
                lastBuy = now

                if not cacheLoaded or now - lastFullRefresh >= 10 then
                    refreshAllCosts()
                end

                local money = Tato.parseCount(cashLabel.Text)
                local best, bestCost = nil, -1
                local allCapped = true

                for _, id in ipairs(UpgradeChain) do
                    if (tierBuys[id] or 0) < maxTierBuys then
                        allCapped = false
                        local cost = costCache[id]
                        if cost and cost > 0 and cost <= money and cost > bestCost then
                            best, bestCost = id, cost
                        end
                    end
                end

                if allCapped then
                    tierBuys = {} -- fresh wave: all tiers were capped
                elseif best then
                    tierBuys[best] = (tierBuys[best] or 0) + 1
                    upg(best)
                    -- tier leveled up: re-check just its cost
                    local ok, res = Tato.invoke("GetUpgradeCost", best)
                    costCache[best] = ok and Tato.extractCost(res) or nil
                end
            end

            -- Prestige pass: fire on interval; server rejects while on cooldown
            if elapsed >= prestigeInterval then
                lastPrestige = now
                tierBuys = {} -- fresh wave after each prestige
                costCache = {} -- levels reset -> costs changed
                cacheLoaded = false
                Tato.fire("PerformPrestige")
            end

            task.wait(0.05)
        end
    end),
})

-- ==================================================================================
-- LEGACY MACROS (kept for compatibility; will be reworked)
-- ==================================================================================
MacroTab:CreateDivider()
MacroTab:CreateSection("Legacy")
Tato.header(MacroTab, "Legacy Macros")

-- Stable macros (identical sequence; KS variant just sells 8B last) ---------------
MacroTab:CreateSection("Stable Macro 15-30")
Tato.header(MacroTab, "Stable Macro")

local function stableMacro(finalSell)
    Tato.fire("PerformPrestige"); task.wait(5)

    sell(200000); task.wait(0.5)
    upg("grandfathers_wisdom"); task.wait(0.5)

    sell(1000000); task.wait(1)
    upg("grandfathers_wisdom"); task.wait(2)

    sell(28000000); task.wait(1)
    upg("infinite_energy"); task.wait(1)

    sell(100000000); upg("infinite_energy"); task.wait(3)
    sell(300000000); upg("infinite_energy"); task.wait(3)

    sell(1000000000); upg("omnipotato_blessing"); task.wait(4)
    sell(1800000000); upg("omnipotato_blessing"); task.wait(8)

    sell(finalSell); task.wait(1)
end

MacroTab:CreateToggle({
    Name = "Macro V1",
    CurrentValue = false,
    Flag = "MacroV1",
    Callback = Tato.loop(function() stableMacro(14000000000) end),
})

MacroTab:CreateToggle({
    Name = "KS Macro V1",
    CurrentValue = false,
    Flag = "KSMacroV1",
    Callback = Tato.loop(function() stableMacro(8000000000) end),
})

-- SuperHuman macro (data-driven: {action, amount, delay}) -------------------------
MacroTab:CreateDivider()
Tato.header(MacroTab, "SuperHuman Macro")

local Upgrades = {
    wisdom = "grandfathers_wisdom",
    energy = "infinite_energy",
    omni = "omnipotato_blessing",
    harvest = "transcendent_harvest",
    galactic = "galactic_harvest",
}

local SuperHumanV1 = {
    {"prestige", nil, 2.6},

    {1000000, nil, 0.05}, {"wisdom", nil, 0.8},
    {428700, nil, 0.05}, {"wisdom", nil, 1.9},

    {140000000, nil, 0.05}, {"energy", nil, 0.3},
    {150000000, nil, 0}, {"energy", nil, 0.6},
    {300000000, nil, 0}, {"energy", nil, 1},

    {2870000000, nil, 0}, {"omni", nil, 1},
    {4000000000, nil, 0}, {"omni", nil, 1},

    {8000000000, nil, 0}, {"harvest", nil, 0.6},
    {27830000000, nil, 0}, {"harvest", nil, 0.05},

    {"galactic", nil, 0.5},
    {40670000000, nil, 0}, {"galactic", nil, 20.5},

    {3000000000000, nil, 0.5},
}

local function runSuperHuman(alive)
    for _, step in ipairs(SuperHumanV1) do
        if not alive() then return end
        local action, value, delay = step[1], step[2], step[3]

        if action == "prestige" then
            Tato.fire("PerformPrestige")
        elseif type(action) == "number" then
            sell(value or action)
        else
            upg(Upgrades[action])
        end

        task.wait(delay)
    end
end

MacroTab:CreateToggle({
    Name = "SuperHumanMacro V1",
    CurrentValue = false,
    Flag = "SuperHumanMacroV1",
    Callback = Tato.loop(runSuperHuman),
})

-- Generator macro (number = sell amount, string = generator to buy) ---------------
MacroTab:CreateDivider()
Tato.header(MacroTab, "Generator Macro")

local GeneratorV1 = {
    {"prestige", 1},

    4400000, {"dimensional_mirror", 0.5},
    460000000, {"temporal_harvester", 3},
    100000000000, {"superfactory_number_67", 1.8},
    1200000000000, {"potato_nexus", 3.4},
    20000000000000, {"omnipotato", 0.8},
    30000000000000, {"omnipotato", 3.8},
    300000000000000, {"double_omnipotato", 2},
    800000000000000, {"double_omnipotato", 4},
    5000000000000000, {"infinite_omnipotato", 1},
    8000000000000000, {"infinite_omnipotato", 3.4},
    50000000000000000, {"potato_infinite_universe", 7},
    {2000000000000000000, 0.1}, -- final sell (longer pause)
}

local function runGenerator(alive)
    for _, step in ipairs(GeneratorV1) do
        if not alive() then return end

        if type(step) == "number" then -- sell, short pause
            sell(step)
            task.wait(0.05)
        elseif type(step[1]) == "number" then -- sell with explicit delay
            sell(step[1])
            task.wait(step[2])
        elseif step[1] == "prestige" then
            Tato.fire("PerformPrestige")
            task.wait(step[2])
        else -- buy generator, wait its delay
            Tato.fire("PurchaseGenerator", step[1])
            if step[2] then task.wait(step[2]) end
        end
    end
end

MacroTab:CreateToggle({
    Name = "Generator Farm V1",
    CurrentValue = false,
    Flag = "GeneratorFarmV1",
    Callback = Tato.loop(runGenerator),
})

print("Macro Tab Loaded V1.38")
