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

-- Sell all golden potatoes whenever the counter rises
SellTab:CreateSection("Sell All")

local selling = false
SellTab:CreateToggle({
    Name = "Auto Sell Golden Potatoes",
    CurrentValue = false,
    Flag = "AutoSellGolden",
    Callback = function(state) selling = state end,
})

task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local goldLabel = player.PlayerGui:WaitForChild("PotatoGameGUI")
        .Background.ClickerArea.ClickerContainer.CurrencyFrame
        :WaitForChild("GoldenRow"):WaitForChild("GoldenCount")

    while true do
        if selling then
            local gold = tonumber(goldLabel.Text) or 0
            if gold > 0 then
                Tato.fire("SellGoldenPotatoes", gold)
            end
        end
        task.wait(0.1)
    end
end)

print("Sell Tab Loaded")
