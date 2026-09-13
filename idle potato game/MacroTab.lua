-- MacroTab.lua | Timed prestige/sell/upgrade macros
local Tato = getgenv().Tato

local MacroTab = Window:CreateTab("Macro", "bitcoin")

local function sell(n) Tato.fire("SellGoldenPotatoes", n) end
local function upg(n) Tato.fire("PurchaseClickUpgrade", n) end

-- ================================================================
-- Stable macros (identical sequence; KS variant just sells 8B last)
-- ================================================================
MacroTab:CreateSection("Prestige Macro 15-30")
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

-- ================================================================
-- SuperHuman macro (data-driven: {upgrade key | "sell" | "prestige", amount, delay})
-- ================================================================
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
        elseif action == "sell" or type(action) == "number" then
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

-- ================================================================
-- Generator macro (number = sell amount, string = generator to buy)
-- ================================================================
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
