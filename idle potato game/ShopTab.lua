local ShopTab = Window:CreateTab("Shop", "cake-slice") -- Title, Image
local autobuy = false
local ProductionAutoBuyToggle = ShopTab:CreateToggle({
   Name = "Production AutoBuy",
   CurrentValue = false,
   Flag = "ProductionAutoBuy",
   Callback = function(ProductionPotion)
      autobuy = ProductionPotion
      task.spawn(function()
         while autobuy do
            local args = {
               "potion_production"
            }

            game:GetService("ReplicatedStorage")
               :WaitForChild("Remotes")
               :WaitForChild("PurchaseShopPotato")
               :FireServer(unpack(args))
            task.wait(60) -- change speed if needed
         end
      end)
   end,
})

local autobuyluck = false
local LuckAutoBuyToggle = ShopTab:CreateToggle({
   Name = "Luck AutoBuy",
   CurrentValue = false,
   Flag = "LuckAutoBuy",
   Callback = function(LuckPotion)
      autobuyluck = LuckPotion
      task.spawn(function()
         while autobuyluck do
            local args = {
               "potion_luck"
            }

            game:GetService("ReplicatedStorage")
               :WaitForChild("Remotes")
               :WaitForChild("PurchaseShopPotato")
               :FireServer(unpack(args))
            task.wait(60) -- change speed if needed
         end
      end)
   end,
})

local autobuygolden = false
local GoldenAutoBuyToggle = ShopTab:CreateToggle({
   Name = "GoldenAutoBuy",
   CurrentValue = false,
   Flag = "GoldenAutoBuy",
   Callback = function(GoldenPotion)
      autobuygolden = GoldenPotion
      task.spawn(function()
         while autobuygolden do
            local args = {
               "potion_golden"
            }

            game:GetService("ReplicatedStorage")
               :WaitForChild("Remotes")
               :WaitForChild("PurchaseShopPotato")
               :FireServer(unpack(args))
            task.wait(60) -- change speed if needed
         end
      end)
   end,
})
local AutoBuyClickPotion = false
local ClickAutoBuyToggle = ShopTab:CreateToggle({
   Name = "Click AutoBuy",
   CurrentValue = false,
   Flag = "ClickAutoBuy",
   Callback = function(ClickPotion)
      AutoBuyClickPotion = ClickPotion
      task.spawn(function()
         while AutoBuyClickPotion do
            local args = {
               "potion_click"
            }

            game:GetService("ReplicatedStorage")
               :WaitForChild("Remotes")
               :WaitForChild("PurchaseShopPotato")
               :FireServer(unpack(args))
            task.wait(60) -- change speed if needed
         end
      end)
   end,
})

print("Shop Tab Loaded V1.10")
