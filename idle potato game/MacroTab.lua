--Macro Tab
local MacroTab = Window:CreateTab("Macro", "bitcoin") -- Title, Image
local Section = MacroTab:CreateSection("Prestige Macro 15-30")
local StableMacroLabel = MacroTab:CreateLabel("Stable Macro", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local MPrestige = Remotes:WaitForChild("PerformPrestige")
local MGoldenSell = Remotes:WaitForChild("SellGoldenPotatoes")
local MWisdom = Remotes:WaitForChild("PurchaseClickUpgrade")
local MEnergy = Remotes:WaitForChild("PurchaseClickUpgrade")
local MOmni = Remotes:WaitForChild("PurchaseClickUpgrade")
local MHarvest = Remotes:WaitForChild("PurchaseClickUpgrade")
local MGalactic = Remotes:WaitForChild("PurchaseClickUpgrade")

local macroing = false
local MacroV1Toggle = MacroTab:CreateToggle({
    Name = "Macro V1",
    CurrentValue = false,
    Flag = "MacroV1",
    Callback = function(MacroV1)
        macroing = MacroV1

        task.spawn(function()
            while macroing do
               -- Prestige                  
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PerformPrestige"):FireServer()
                task.wait(5)
                  
               -- 200K Sell (1)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(200000)
                task.wait(0.5)
                  
               -- Wisdom 1 (2)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("grandfathers_wisdom")
                task.wait(0.5)
                  
               -- 1M Sell (3)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1000000)
                task.wait(1)

               -- Wisdom 2 (4)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("grandfathers_wisdom")
                task.wait(2)

               -- 28M Sell (5)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(28000000)
                task.wait(1)

               -- Energy 1 (6)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("infinite_energy")
                task.wait(1)
                  
               -- 100M Sell And Energy 2 (7)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(100000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("infinite_energy")
                task.wait(3)
               
               -- 300M Sell And Energy 3 (8)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(300000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("infinite_energy")
                task.wait(3)

               -- 1B Sell And Omni 1 (9)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1000000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("omnipotato_blessing")
                task.wait(4)
                  
               -- 1.8B Sell And Omni 2 (10)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1800000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("omnipotato_blessing")
                task.wait(8)

                -- 14B Final Sell (11)  
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(14000000000)
                task.wait(1)
            end
        end)
    end,
})


local ksmacro = false

local MacroV1Toggle = MacroTab:CreateToggle({
    Name = "KS Macro V1",
    CurrentValue = false,
    Flag = "KSMacroV1",
    Callback = function(KSMacro1)
        ksmacro = KSMacro1

        task.spawn(function()
            while ksmacro do
               -- Prestige                  
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PerformPrestige"):FireServer()
                task.wait(5)
                  
               -- 200K Sell (1)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(200000)
                task.wait(0.5)
                  
               -- Wisdom 1 (2)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("grandfathers_wisdom")
                task.wait(0.5)
                  
               -- 1M Sell (3)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1000000)
                task.wait(1)

               -- Wisdom 2 (4)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("grandfathers_wisdom")
                task.wait(2)

               -- 28M Sell (5)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(28000000)
                task.wait(1)

               -- Energy 1 (6)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("infinite_energy")
                task.wait(1)
                  
               -- 100M Sell And Energy 2 (7)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(100000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("infinite_energy")
                task.wait(3)
               
               -- 300M Sell And Energy 3 (8)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(300000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("infinite_energy")
                task.wait(3)

               -- 1B Sell And Omni 1 (9)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1000000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("omnipotato_blessing")
                task.wait(4)
                  
               -- 1.8B Sell And Omni 2 (10)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1800000000)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseClickUpgrade"):FireServer("omnipotato_blessing")
                task.wait(8)

                -- 8B Final Sell (11)  
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(8000000000)
                task.wait(1)
            end
        end)
    end,
})

local SuperHumanMacroDivider = MacroTab:CreateDivider()
local SuperHumanMacroLabel = MacroTab:CreateLabel("SuperHuman Macro", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

local superhumanmacro = false

local SuperMacroV1 = {
    {"prestige", nil, 2.6},

    {"sell", 1_000_000, 0.05},
    {"wisdom", nil, 0.8},

    {"sell", 428_700, 0.05},
    {"wisdom", nil, 1.9},

    {"sell", 140_000_000, 0.05},
    {"energy", nil, 0.3},

    {"sell", 150_000_000, 0},
    {"energy", nil, 0.6},

    {"sell", 300_000_000, 0},
    {"energy", nil, 1},

    {"sell", 2_870_000_000, 0},
    {"omni", nil, 1},

    {"sell", 4_000_000_000, 0},
    {"omni", nil, 1},

    {"sell", 8_000_000_000, 0},
    {"harvest", nil, 0.6},

    {"sell", 27_830_000_000, 0},
    {"harvest", nil, 0.05},

    {"galactic", nil, 0.5},

    {"sell", 40_670_000_000, 0},
    {"galactic", nil, 20.5},

    {"sell", 3_000_000_000_000, 0.5}
}

local MacroV1Toggle = MacroTab:CreateToggle({
    Name = "SuperHumanMacro V1",
    CurrentValue = false,
    Flag = "SuperHumanMacroV1",

    Callback = function(superhumanmacrov1)
        superhumanmacro = superhumanmacrov1
        task.spawn(function()
            while superhumanmacro do

                for _,step in ipairs(SuperMacroV1) do
                    if not superhumanmacro then break end

                    local action,value,delay = unpack(step)

                    if action == "prestige" then
                        MPrestige:FireServer()

                    elseif action == "sell" then
                        MGoldenSell:FireServer(value)

                    elseif action == "wisdom" then
                        MWisdom:FireServer("grandfathers_wisdom")

                    elseif action == "energy" then
                        MEnergy:FireServer("infinite_energy")

                    elseif action == "omni" then
                        MOmni:FireServer("omnipotato_blessing")

                    elseif action == "harvest" then
                        MHarvest:FireServer("transcendent_harvest")

                    elseif action == "galactic" then
                        MGalactic:FireServer("galactic_harvest")
                    end

                    task.wait(delay)
                end

            end
        end)
    end,
})


local GeneratorMacroDivider = MacroTab:CreateDivider()
local GeneratorMacroLabel = MacroTab:CreateLabel("Generator Macro", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

local generatorfarm = false
local GeneratorMacroV1Toggle = MacroTab:CreateToggle({
    Name = "Generator Farm V1",
    CurrentValue = false,
    Flag = "GeneratorFarmV1",
    Callback = function(GenFarmV1)
        generatorfarm = GenFarmV1

        task.spawn(function()
            while generatorfarm do
               -- Prestige                  
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PerformPrestige"):FireServer()
                task.wait(1)
                  
               -- 4.4M Sell (1)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(4_400_000)
                task.wait(0.05)
                  
               -- Dimensional Mirror 1 
                local args = {"dimensional_mirror"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(0.5)
                  
               -- 460M Sell (3)
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(460_000_000)
                task.wait(0.05)

               -- Temporal Harvester 1
                local args = {"temporal_harvester"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(3)

               -- 100B Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(100_000_000_000)
                task.wait(0.05)

               -- Super Factory 1
                local args = {"superfactory_number_67"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(1.8)

               -- 1.2T Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(1_200_000_000_000)
                task.wait(0.05)

               -- Potato Nexus 1
                local args = {"potato_nexus"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(3.4)

               -- 20T Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(20_000_000_000_000)
                task.wait(0.05)

               -- Omni Potato 1
                local args = {"omnipotato"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(0.8)

               -- 30T Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(30_000_000_000_000)
                task.wait(0.05)

               -- Omni Potato 2
                local args = {"omnipotato"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(3.8)

               -- 300T Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(300_000_000_000_000)
                task.wait(0.05)

               -- Double Omni 1
                local args = {"double_omnipotato"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(2)

               -- 800T Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(800_000_000_000_000)
                task.wait(0.05)

               -- Double Omni 2
                local args = {"double_omnipotato"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(4)

               -- 5QA Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(5_000_000_000_000_000)
                task.wait(0.05)

               -- Infinite Omni 1
                local args = {"infinite_omnipotato"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(1)

               -- 8QA Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(8_000_000_000_000_000)
                task.wait(0.05)

               -- Infinite Omni 1
                local args = {"infinite_omnipotato"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(3.4)

               -- 50QA Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(50_000_000_000_000_000)
                task.wait(0.05)

               -- Infinite Universe 2
                local args = {"potato_infinite_universe"}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseGenerator"):FireServer(unpack(args))
                task.wait(7)

               -- 2QI Sell
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellGoldenPotatoes"):FireServer(2_000_000_000_000_000_000)
                task.wait(0.10)

            end
        end)
    end,
})
print("Macro Tab Loaded V1.38")