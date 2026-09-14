-- ShopTab.lua | Potion auto-buyers
local Tato = getgenv().Tato

local ShopTab = Window:CreateTab("Shop", "cake-slice")

-- {toggle name, shop item id, config flag}
local Potions = {
    { "Production AutoBuy", "potion_production", "ProductionAutoBuy" },
    { "Luck AutoBuy",       "potion_luck",       "LuckAutoBuy" },
    { "GoldenAutoBuy",      "potion_golden",     "GoldenAutoBuy" },
    { "Click AutoBuy",      "potion_click",      "ClickAutoBuy" },
}

for _, p in ipairs(Potions) do
    local name, id, flag = p[1], p[2], p[3]
    ShopTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = flag,
        Callback = Tato.loop(function()
            Tato.fire("PurchaseShopPotato", id)
            task.wait(60)
        end),
    })
end

-- ================================================================
-- Smart Buyer: reads live costs via RemoteFunctions and only buys
-- the most expensive affordable upgrade/generator (cash from HUD label)
-- ================================================================
ShopTab:CreateSection("Smart Buyer")
Tato.header(ShopTab, "Smart Buyer")

local Gamedata = getgenv().Gamedata or { KnownIds = { ClickUpgrades = {}, Generators = {} } }

local cashLabel
local function cash()
    if not cashLabel then
        local ok = pcall(function()
            cashLabel = Tato.waitForPath(game:GetService("Players").LocalPlayer.PlayerGui,
                "PotatoGameGUI", "Background", "ClickerArea", "ClickerContainer",
                "CurrencyFrame", "CashRow", "CashCount")
        end)
        if not ok then return 0 end
    end
    if cashLabel then return Tato.parseCount(cashLabel.Text) end
    return 0
end

local function extractCost(v)
    return Tato.extractCost(v)
end

-- One pass: find the most expensive affordable id and buy it
local function smartPass(costRemote, buyRemote, ids)
    local money = cash()
    local best, bestCost = nil, -1

    for _, id in ipairs(ids) do
        local ok, res = Tato.invoke(costRemote, id)
        local cost = ok and extractCost(res) or nil
        if cost and cost > 0 and cost <= money and cost > bestCost then
            best, bestCost = id, cost
        end
    end

    if best then
        Tato.fire(buyRemote, best)
    end
end

local SmartBuyers = {
    { "Smart Click Upgrades", "GetUpgradeCost",  "PurchaseClickUpgrade", "SmartClickUpgrades", Gamedata.KnownIds.ClickUpgrades },
    { "Smart Generators",     "GetGeneratorCost", "PurchaseGenerator",    "SmartGenerators",     Gamedata.KnownIds.Generators },
}

for _, s in ipairs(SmartBuyers) do
    local name, costRemote, buyRemote, flag, ids = s[1], s[2], s[3], s[4], s[5]
    ShopTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = flag,
        Callback = Tato.loop(function()
            smartPass(costRemote, buyRemote, ids)
            task.wait(3)
        end),
    })
end

print("Shop Tab Loaded V1.10")
