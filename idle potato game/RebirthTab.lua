-- RebirthTab.lua | Ascension & Prestige loops
local Tato = getgenv().Tato

local RebirthTab = Window:CreateTab("Rebirths", "aperture")
RebirthTab:CreateSection("Ascension")
Tato.header(RebirthTab, "Ascension Upgrades")

local function ascensionToggle(name, flag, kind)
    RebirthTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = flag,
        Callback = Tato.loop(function()
            Tato.fire("PerformAscension", kind)
            task.wait(60)
        end),
    })
end

ascensionToggle("Abundance Ascension", "AutoAscend", "abundance")
ascensionToggle("Prestige Ascension", "PrestigeAscension", "prestige")
ascensionToggle("Thrifty Ascension", "ThriftyAscension", "thrifty")

RebirthTab:CreateDivider()
RebirthTab:CreateSection("Prestige")
Tato.header(RebirthTab, "Auto Prestige")

RebirthTab:CreateToggle({
    Name = "Auto Prestige (32s)",
    CurrentValue = false,
    Flag = "AutoPrestigeToggle",
    Callback = Tato.loop(function()
        Tato.fire("PerformPrestige")
        task.wait(32)
    end),
})

print("Rebirth Tab Loaded V1.01")
