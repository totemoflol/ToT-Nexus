-- Auto Tab
local AutoTab = Window:CreateTab("Auto", "circuit-board") -- Title, Image
local AutoClickLabel = AutoTab:CreateLabel("Auto Clicker", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
-- Auto Click
local Clicking = false
local AutoClickToggle = AutoTab:CreateToggle({
    Name = "Auto Click (0.02s)",
    CurrentValue = false,
    Flag = "AutoClickToggle",
    Callback = function(Clicks)
        Clicking = Clicks

        task.spawn(function()
            while Clicks do
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Remotes")
                    :WaitForChild("PerformClick")
                    :FireServer()

                task.wait(0.02)
            end
        end)
    end,
})
print("Auto Tab Loaded")