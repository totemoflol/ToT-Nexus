local CoreGui = game:GetService("CoreGui")
local old = CoreGui:FindFirstChild("Rayfield")
if old then
    old:Destroy()
end

local player = game:GetService("Players").LocalPlayer

local ConfigName
if player.UserId == 4874964037 then
    ConfigName = "BJDHCMAINConfig"
elseif player.UserId == 1242588417 then
    ConfigName = "Durianlover9Config"
elseif player.UserId == 3076753381 then
	ConfigName = "aaaionj2Config"
elseif player.UserId == 4993924900 then
	ConfigName = "urmotherlah6Config"
else
    ConfigName = "Tato Hub"
end

local s1 = Instance.new("Sound", workspace)
s1.SoundId = "rbxassetid://5793681247"
s1.Volume = 1

local s2 = Instance.new("Sound", workspace)
s2.SoundId = "rbxassetid://18967588612"
s2.Volume = 2
s2.Looped = true

s1:Play()
s2:Play()

Version = "V3.00"
print(Version)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- Window
local Window = Rayfield:CreateWindow({
   Name = "Potato Script V3",
   Icon = "venetian-mask", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Idle Potato Game (T)",
   LoadingSubtitle = "by Totemoflol",
   ShowText = "Tato", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Serenity", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Tato Script", -- Create a custom folder for your hub/game
      FileName = ConfigName
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Key Up You Bot",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"TTT", "ttt"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

getgenv().Window = Window

-- Whitelist
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/WhitelistedTaters.lua"))()

-- Sell Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/SellTab.lua"))()

-- Auto Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/AutoTab.lua"))()

-- Rebirth Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/RebirthTab.lua"))()

-- Macro Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/MacroTab.lua"))()

-- Misc Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/MiscTab.lua"))()

-- Shop Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/ShopTab.lua"))()

-- Premium Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/Admin.lua"))()

-- Webhook Tab
loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/idle%20potato%20game/Webhook.lua"))()

-- Anti-AFK (runs instantly when script runs)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
if getconnections then
    for _, connection in pairs(getconnections(player.Idled)) do
        if connection.Disable then
            connection:Disable()
        elseif connection.Disconnect then
            connection:Disconnect()
        end
    end
else
    player.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

Rayfield:LoadConfiguration()

-- Auto re-execute after teleport (like Infinite Yield)

local queue = queue_on_teleport or queueteleport or (syn and syn.queue_on_teleport)

if queue then
    queue('loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/Idle-Potato-Game/main/Loader.lua"))()')
end
