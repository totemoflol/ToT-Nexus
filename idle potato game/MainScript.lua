-- MainScript.lua | Tato Hub - Idle Potato Game entry point
print("Tato Hub V3.00")

local CoreGui = game:GetService("CoreGui")
local old = CoreGui:FindFirstChild("Rayfield")
if old then old:Destroy() end

local player = game:GetService("Players").LocalPlayer

-- Per-user config files (everyone else gets "Tato Hub")
local Configs = {
    [4874964037] = "BJDHCMAINConfig",
    [1242588417] = "Durianlover9Config",
    [3076753381] = "aaaionj2Config",
    [4993924900] = "urmotherlah6Config",
}

local BASE = "https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main/idle%20potato%20game"

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Potato Script V3",
    Icon = "venetian-mask",
    LoadingTitle = "Idle Potato Game (T)",
    LoadingSubtitle = "by Totemoflol",
    ShowText = "Tato", -- for mobile users to unhide Rayfield
    Theme = "Serenity",
    ToggleUIKeybind = "K",
    -- Discord prompt & KeySystem are disabled (Rayfield defaults)
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Tato Script",
        FileName = Configs[player.UserId] or "Tato Hub",
    },
})

getgenv().Window = Window

-- Startup sounds {id, volume, looped}
for _, s in ipairs({ { 5793681247, 1, false }, { 18967588612, 2, true } }) do
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. s[1]
    sound.Volume = s[2]
    sound.Looped = s[3]
    sound.Parent = workspace
    sound:Play()
end

-- Remote reference data (ids for smart buyer / potions)
pcall(function()
    getgenv().Gamedata = loadstring(game:HttpGet(BASE .. "/idle%20potato%20game/gamedata.lua"))()
end)

-- Load helpers, whitelist, then all tabs (order matters)
for _, file in ipairs({
    "lib", "WhitelistedTaters", "SellTab", "AutoTab",
    "RebirthTab", "MiscTab", "ShopTab", "BoostsTab", "MacroTab", "Premium",
}) do
    loadstring(game:HttpGet(BASE .. "/" .. file .. ".lua"))()
end

-- Anti-AFK
if getconnections then
    for _, c in pairs(getconnections(player.Idled)) do
        if c.Disable then c:Disable()
        elseif c.Disconnect then c:Disconnect() end
    end
else
    player.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)
end

Rayfield:LoadConfiguration()

-- Auto re-execute after teleport (via the universal loader)
local queue = queue_on_teleport or queueteleport or (syn and syn.queue_on_teleport)
if queue then
    queue('loadstring(game:HttpGet("https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main/Loader.lua"))()')
end
