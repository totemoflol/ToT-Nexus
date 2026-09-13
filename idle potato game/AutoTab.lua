-- AutoTab.lua | Auto Clicker
local Tato = getgenv().Tato

local AutoTab = Window:CreateTab("Auto", "circuit-board")
Tato.header(AutoTab, "Auto Clicker")

AutoTab:CreateToggle({
    Name = "Auto Click (0.02s)",
    CurrentValue = false,
    Flag = "AutoClickToggle",
    Callback = Tato.loop(function()
        Tato.fire("PerformClick")
        task.wait(0.02)
    end),
})

print("Auto Tab Loaded")
