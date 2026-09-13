local player = game:GetService("Players").LocalPlayer
local Whitelist = getgenv().whitelistedtaters or {}

if Whitelist[player.UserId] then
    local PremiumTab = Window:CreateTab("Premium", "gem")

    local PremiumFeaturesLabel = PremiumTab:CreateLabel(
        "Premium",
        4483362458,
        Color3.fromRGB(255, 255, 255),
        false
    )

    local EmojiBuying = false

    PremiumTab:CreateToggle({
        Name = "Emoji Mystery Potato Auto Buy",
        CurrentValue = false,
        Flag = "EmojiBuy",
        Callback = function(EmojiAutoBuy)
            EmojiBuying = EmojiAutoBuy

            if EmojiBuying then
                task.spawn(function()
                    while EmojiBuying do
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remotes")
                            :WaitForChild("PurchaseShopPotato")
                            :FireServer("emoji_mystery_potato")

                        task.wait(60)
                    end
                end)
            end
        end,
    })
end
