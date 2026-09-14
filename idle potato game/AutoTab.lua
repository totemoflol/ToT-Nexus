-- AutoTab.lua | Auto Clicker
local Tato = getgenv().Tato

local AutoTab = Window:CreateTab("Auto", "circuit-board")
Tato.header(AutoTab, "Auto Clicker")

local AutoClickToggle = AutoTab:CreateToggle({
    Name = "Auto Click (0.02s)",
    CurrentValue = false,
    Flag = "AutoClickToggle",
    Callback = Tato.loop(function()
        Tato.fire("PerformClick")
        task.wait(0.02)
    end),
})
Tato.registerToggle("AutoClick", AutoClickToggle)

print("Auto Tab Loaded")
