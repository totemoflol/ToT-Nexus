-- MiscTab.lua | Misc utilities
local Tato = getgenv().Tato

local MiscTab = Window:CreateTab("Misc", "app-window")

local NotificationContainer = game:GetService("Players").LocalPlayer.PlayerGui
    :WaitForChild("PotatoGameGUI"):WaitForChild("NotificationContainer")

MiscTab:CreateToggle({
    Name = "Disable Notifications",
    CurrentValue = false,
    Flag = "DisableNotifications",
    Callback = function(state)
        NotificationContainer.Visible = not state
    end,
})

MiscTab:CreateToggle({
    Name = "Auto Farm Generator",
    CurrentValue = false,
    Flag = "GeneratorFarm",
    Callback = Tato.loop(function()
        Tato.fire("PurchaseGenerator", "potato_seedling")
        Tato.fire("DeleteGenerator", "potato_seedling")
        task.wait(0.05)
    end),
})

print("Misc Tab Loaded")
