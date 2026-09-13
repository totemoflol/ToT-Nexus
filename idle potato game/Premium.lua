-- Premium.lua | Whitelist-gated: Premium tab + Webhook tab
local Tato = getgenv().Tato
if not Tato.isWhitelisted() then return end

-- ================================================================
-- Premium tab
-- ================================================================
local PremiumTab = Window:CreateTab("Premium", "gem")
Tato.header(PremiumTab, "Premium")

PremiumTab:CreateToggle({
    Name = "Emoji Mystery Potato Auto Buy",
    CurrentValue = false,
    Flag = "EmojiBuy",
    Callback = Tato.loop(function()
        Tato.fire("PurchaseShopPotato", "emoji_mystery_potato")
        task.wait(60)
    end),
})

-- ================================================================
-- Webhook tab
-- ================================================================
local HttpService = game:GetService("HttpService")
local player = game:GetService("Players").LocalPlayer
local requestFunc = http_request or request or syn.request
local url = "https://discord.com/api/webhooks/1480883485244919941/Kp7vYC3Zr9g_qJ4FrusgjjQjJClo2nYUrPMoQq6HxxnzidnOuOuNUypIrquLkO0kgvL2"

local messageText = player.Name .. " just executed the script!"

local WebhookTab = Window:CreateTab("Webhook", Tato.Icon)

WebhookTab:CreateInput({
    Name = "Webhook Message",
    PlaceholderText = "Type message here",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) messageText = v end,
})

WebhookTab:CreateButton({
    Name = "Send Webhook",
    Callback = function()
        local ok, result = pcall(function()
            return requestFunc({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ content = "`" .. messageText .. "`" }),
            })
        end)

        Rayfield:Notify({
            Title = ok and "Webhook" or "Webhook Error",
            Content = ok and "Message sent" or tostring(result),
            Duration = ok and 3 or 5,
            Image = Tato.Icon,
        })
    end,
})
