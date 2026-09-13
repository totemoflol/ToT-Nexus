-- Whitelist.lua | GLOBAL ToT Nexus whitelist (import tool & future global tools)
-- Separate from per-game whitelists. Usernames are case-insensitive.

local Usernames = {
    "Totemoflol",
    "Banmelikeagoodboy672",
}

local UserIds = {
    -- [1234567890] = true,
}

local names = {}
for _, name in ipairs(Usernames) do
    names[string.lower(name)] = true
end

getgenv().isNexusWhitelisted = function(player)
    if UserIds[player.UserId] then return true end
    return names[string.lower(player.Name)] == true
end

print("[ToT Nexus] Global whitelist loaded")
