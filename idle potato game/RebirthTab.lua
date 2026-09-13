 -- Rebirth Tab    
local RebirthTab = Window:CreateTab("Rebirths", "aperture") -- Title, Image
local PrestigeSection = RebirthTab:CreateSection("Ascension")
local AscendLabel = RebirthTab:CreateLabel("Ascension Upgrades", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
local AbundanceAscend = false
local AscendToggle = RebirthTab:CreateToggle({
    Name = "Abundance Ascension",
    CurrentValue = false,
    Flag = "AutoAscend",
    Callback = function(abundance)
        AbundanceAscend = abundance
        task.spawn(function()
            while AbundanceAscend do
                local args = {
                    "abundance"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PerformAscension"):FireServer(unpack(args))
                task.wait(60) -- waits 60 seconds (1 minute)
            end
        end)
    end,
})

local PrestigeAscend = false

local PrestigeAscendToggle = RebirthTab:CreateToggle({
   Name = "Prestige Ascension",
   CurrentValue = false,
   Flag = "PrestigeAscension",
   Callback = function(PrestigeA)
      PrestigeAscend = PrestigeA

      task.spawn(function()
         while PrestigeAscend do
            local args = {
               "prestige"
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PerformAscension"):FireServer(unpack(args))

            task.wait(60)
         end
      end)
   end,
})

local ThriftAscend = false
local ThriftyAscendToggle = RebirthTab:CreateToggle({
   Name = "Thrifty Ascension",
   CurrentValue = false,
   Flag = "ThriftyAscension",
   Callback = function(ThriftyAscend)
      ThriftAscend = ThriftyAscend
      task.spawn(function()
         while ThriftAscend do
            local args = {"thrifty"}
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PerformAscension"):FireServer(unpack(args))
            task.wait(60)
         end
      end)
   end,
})

local Divider = RebirthTab:CreateDivider()
local PrestigeSection = RebirthTab:CreateSection("Prestige")
local PrestigeLabel = RebirthTab:CreateLabel("Auto Prestige", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
local Prestiging = false
local AutoPrestigeToggle = RebirthTab:CreateToggle({
    Name = "Auto Prestige (32s)",
    CurrentValue = false,
    Flag = "AutoPrestigeToggle",
    Callback = function(APrestige)
        Prestiging = APrestige

        task.spawn(function()
            while Prestiging do
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Remotes")
                    :WaitForChild("PerformPrestige")
                    :FireServer()

                task.wait(32)
            end
        end)
    end,
})
print("Rebirth Tab Loaded V1.01")