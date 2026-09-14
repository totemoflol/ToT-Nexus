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
        prestigeInterval = math.max(5, tonumber(v) or 30)
    end,
})

MacroTab:CreateToggle({
    Name = "Versatile Macro",
    CurrentValue = false,
    Flag = "VersatileMacro",
    Callback = Tato.loop(function(alive)
        local player = game:GetService("Players").LocalPlayer
        local currency = Tato.waitForPath(player.PlayerGui,
            "PotatoGameGUI", "Background", "ClickerArea", "ClickerContainer", "CurrencyFrame")
        local goldLabel = Tato.waitForPath(currency, "GoldenRow", "GoldenCount")
        local potatoLabel = Tato.waitForPath(currency, "PotatoRow", "PotatoCount")
        local cashLabel = Tato.waitForPath(currency, "CashRow", "CashCount")

        local lastBuyPass, lastPrestige = 0, 0

        while alive() do
            -- Sell both currencies whenever the counters rise
            local gold = Tato.parseCount(goldLabel.Text)
            if gold > 0 then
                sell(gold)
            end
            local potatoes = Tato.parseCount(potatoLabel.Text)
            if potatoes > 0 then
                Tato.fire("SellPotatoes", potatoes)
            end

            local now = os.clock()

            -- Upgrade pass every 2s: buy the most expensive affordable tier
            if now - lastBuyPass >= 2 then
                lastBuyPass = now
                local money = Tato.parseCount(cashLabel.Text)
                local best, bestCost = nil, -1

                for _, id in ipairs(UpgradeChain) do
                    local ok, res = Tato.invoke("GetUpgradeCost", id)
                    local cost = ok and Tato.extractCost(res) or nil
                    if cost and cost > 0 and cost <= money and cost > bestCost then
                        best, bestCost = id, cost
                    end
                end

                if best then
                    upg(best)
                end
            end

            -- Prestige pass: fire on interval; server rejects while on cooldown
            if now - lastPrestige >= prestigeInterval then
                lastPrestige = now
                Tato.fire("PerformPrestige")
            end

            task.wait(0.25)
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
