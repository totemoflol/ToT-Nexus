local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local PurchaseGenerator = Remotes:WaitForChild("PurchaseGenerator")

local MiscTab = Window:CreateTab("Misc", "app-window") -- Title, Image
local Players = game:GetService("Players")
local NotificationContainer = Players.LocalPlayer.PlayerGui:WaitForChild("PotatoGameGUI"):WaitForChild("NotificationContainer")
local NoNotifToggle = MiscTab:CreateToggle({
   Name = "Disable Notifications",
   CurrentValue = false,
   Flag = "DisableNotifications", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(DisableNotifications)
			NotificationContainer.Visible = not DisableNotifications
   end,
})

local GeneratorFarm = false

local GeneratorFarmToggle = MiscTab:CreateToggle({
   Name = "Auto Farm Generator",
   CurrentValue = false,
   Flag = "GeneratorFarm",
   Callback = function(GFarm)
      GeneratorFarm = GFarm

      task.spawn(function()
         while GeneratorFarm do
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer("potato_seedling")
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DeleteGenerator"):FireServer("potato_seedling")
            task.wait(0.05)
         end
      end)
   end,
})
print("Misc Tab Loaded")