local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local requestFunc = http_request or request or syn.request
local url = "https://discord.com/api/webhooks/1480883485244919941/Kp7vYC3Zr9g_qJ4FrusgjjQjJClo2nYUrPMoQq6HxxnzidnOuOuNUypIrquLkO0kgvL2"

if getgenv().whitelistedtaters[player.UserId] then
    local WebhookTab = Window:CreateTab("Webhook", 4483362458)

    local messageText = player.Name .. " just executed the script!"

    WebhookTab:CreateInput({
        Name = "Webhook Message",
        PlaceholderText = "Type message here",
        RemoveTextAfterFocusLost = false,
        Callback = function(Webhook)
            messageText = Webhook
        end,
    })

    WebhookTab:CreateButton({
        Name = "Send Webhook",
        Callback = function()
            local formatted = "`" .. messageText .. "`"

            local data = {
                ["content"] = formatted
            }

            local success, result = pcall(function()
                return requestFunc({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(data)
                })
            end)

            if success then
                Rayfield:Notify({
                    Title = "Webhook",
                    Content = "Message sent",
                    Duration = 3,
                    Image = 4483362458,
                })
            else
                Rayfield:Notify({
                    Title = "Webhook Error",
                    Content = tostring(result),
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        end,
    })
end