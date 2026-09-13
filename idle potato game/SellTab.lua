-- SellTab.lua | Auto Sell
local Tato = getgenv().Tato

local SellTab = Window:CreateTab("Sell", Tato.Icon)
Tato.header(SellTab, "Auto Sell")

local Amount, Delay = 1, 1

SellTab:CreateInput({
    Name = "Amount Of Gold Potatoes",
    CurrentValue = "",
    PlaceholderText = "Enter Amount",
    RemoveTextAfterFocusLost = false,
    Flag = "AmountInput",
    Callback = function(v) Amount = tonumber(v) or 0 end,
})

SellTab:CreateInput({
    Name = "Delay (seconds)",
    CurrentValue = "",
    PlaceholderText = "Enter Delay",
    RemoveTextAfterFocusLost = false,
    Flag = "DelayInput",
    Callback = function(v) Delay = tonumber(v) or 0 end,
})

SellTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = Tato.loop(function()
        Tato.fire("SellGoldenPotatoes", Amount)
        task.wait(Delay)
    end),
})

-- Sell all: reads the on-screen currency counters (game formats numbers,
-- so plain tonumber() fails -- Tato.parseCount handles "1.5K"/"5QA" etc.)
SellTab:CreateSection("Sell All")

local sellGold, sellPotatoes = false, false

SellTab:CreateToggle({
    Name = "Auto Sell Golden Potatoes",
    CurrentValue = false,
    Flag = "AutoSellGolden",
    Callback = function(state) sellGold = state end,
})

SellTab:CreateToggle({
    Name = "Auto Sell Potatoes",
    CurrentValue = false,
    Flag = "AutoSellPotatoes",
    Callback = function(state) sellPotatoes = state end,
})

task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local currency = Tato.waitForPath(player.PlayerGui,
        "PotatoGameGUI", "Background", "ClickerArea", "ClickerContainer", "CurrencyFrame")
    local goldLabel = Tato.waitForPath(currency, "GoldenRow", "GoldenCount")
    local potatoLabel = Tato.waitForPath(currency, "PotatoRow", "PotatoCount")

    while true do
        local fired = false

        if sellGold then
            local gold = Tato.parseCount(goldLabel.Text)
            if gold > 0 then
                Tato.fire("SellGoldenPotatoes", gold)
                fired = true
            end
        end

        if sellPotatoes then
            local potatoes = Tato.parseCount(potatoLabel.Text)
            if potatoes > 0 then
                Tato.fire("SellPotatoes", potatoes)
                fired = true
            end
        end

        task.wait(fired and 0.25 or 0.1)
    end
end)

print("Sell Tab Loaded")
