-- Auto Sell Tab
local SellTab = Window:CreateTab("Sell", 4483362458) -- Title, Image
-- VARIABLES
local Amount = 1
local Delay = 1
local Running = false
local Label = SellTab:CreateLabel("Auto Sell", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
-- INPUT: Amount Of Gold Potatoes
local AmountInput = SellTab:CreateInput({
   Name = "Amount Of Gold Potatoes",
   CurrentValue = "",
   PlaceholderText = "Enter Amount",
   RemoveTextAfterFocusLost = false,
   Flag = "AmountInput",
   Callback = function(Value)
      Amount = tonumber(Value) or 0
   end,
})
-- INPUT: Delay
local DelayInput = SellTab:CreateInput({
   Name = "Delay (seconds)",
   CurrentValue = "",
   PlaceholderText = "Enter Delay",
   RemoveTextAfterFocusLost = false,
   Flag = "DelayInput",
   Callback = function(Value)
      Delay = tonumber(Value) or 0
   end,
})
-- TOGGLE: Auto Sell
local AutoSellToggle = SellTab:CreateToggle({
   Name = "Auto Sell",
   CurrentValue = false,
   Flag = "AutoSellToggle",
   Callback = function(Value)
      Running = Value

      task.spawn(function()
         while Running do
            local args = {
               Amount
            }

            game:GetService("ReplicatedStorage")
               :WaitForChild("Remotes")
               :WaitForChild("SellGoldenPotatoes")
               :FireServer(unpack(args))

            task.wait(Delay)
         end
      end)
   end,
})

local Section = SellTab:CreateSection("Section Example")

-- Toggle
local selling = false

local SellAllToggle = SellTab:CreateToggle({
    Name = "Auto Sell Golden Potatoes",
    CurrentValue = false,
    Flag = "AutoSellGolden",
    Callback = function(state)
        selling = state
    end,
})

-- Persistent selling loop
task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local gui = player.PlayerGui:WaitForChild("PotatoGameGUI")
        .Background.ClickerArea.ClickerContainer.CurrencyFrame
    local goldLabel = gui:WaitForChild("GoldenRow"):WaitForChild("GoldenCount")
    local r = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

    -- Cash label path (Stats Area)
    local cashLabel = player.PlayerGui:WaitForChild("PotatoGameGUI")
        .Background.StatsArea.StatsScrollFrame.StatsContainer
        :WaitForChild("SectionCard_Balances")
        :WaitForChild("SB_Cash")

    -- Function to parse numbers with M/B suffix
    local function parseText(text)
        local num = tonumber(string.match(text, "%d+%.?%d*")) or 0
        if string.find(text, "B") then
            return num * 1e9
        elseif string.find(text, "M") then
            return num * 1e6
        else
            return num
        end
    end

    while true do
        if selling then
            -- Sell all golden potatoes
            local gold = tonumber(goldLabel.Text) or 0
            if gold > 0 then
                r.SellGoldenPotatoes:FireServer(gold)
            end

            -- Read cash from ContentText (optional debug)
            local cash = parseText(cashLabel.ContentText)
            -- print("Current cash:", cash)
        end
        task.wait(0.1)
    end
end)
print("Sell Tab Loaded")