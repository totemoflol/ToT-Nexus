-- Whitelist.lua | GLOBAL ToT Nexus whitelist (import tool & future global tools)
-- Separate from per-game whitelists. Usernames are case-insensitive.
-- SECURITY: returns the tables directly; gated code must use the return value
-- (local upvalues), never getgenv(), so the checks can't be spoofed.

local Usernames = {
    "Totemoflol",
    "Banmelikeagoodboy672",
    "Durianlover9",
    "aaaionj2",
}

local UserIds = {
    -- [1234567890] = true,
}

local names = {}
for _, name in ipairs(Usernames) do
    names[string.lower(name)] = true
end

print("[ToT Nexus] Global whitelist loaded")

return {
    ids = UserIds,
    names = names,
}
