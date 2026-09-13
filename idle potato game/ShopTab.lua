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

print("Shop Tab Loaded V1.10")
