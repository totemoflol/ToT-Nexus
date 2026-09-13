-- lib.lua | Tato Hub shared helpers (loaded before all tabs)
local Players = game:GetService("Players")

local Tato = {}
getgenv().Tato = Tato

Tato.Icon = 4483362458

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- Wait for a nested instance chain (e.g. PlayerGui > GUI > Frame > Label)
function Tato.waitForPath(root, ...)
    local node = root
    for _, name in ipairs({ ... }) do
        node = node:WaitForChild(name)
    end
    return node
end

-- Parse game-formatted counters: "1,234" "1.5K" "2.3m" "5QA" "1.2B" -> number
local SUFFIXES = {
    K = 1e3, M = 1e6, B = 1e9, T = 1e12,
    QA = 1e15, QI = 1e18, SX = 1e21, SP = 1e24,
    OC = 1e27, NO = 1e30, DC = 1e33,
}

function Tato.parseCount(text)
    if type(text) ~= "string" then return 0 end
    local s = text:gsub(",", "")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    s = s:upper()
    local num, suffix = s:match("^(%d+%.?%d*)%s*(%a*)$")
    if not num then return 0 end
    local value = tonumber(num) or 0
    if suffix ~= "" then
        value = value * (SUFFIXES[suffix] or 1)
    end
    return math.floor(value)
end

-- Fire a game remote by name
function Tato.fire(name, ...)
    Remotes:WaitForChild(name):FireServer(...)
end

-- Bind a toggle callback to a repeating loop.
-- fn(alive) must yield (task.wait) at least once per pass.
-- alive() returns false once toggled off, so long macros can bail mid-sequence.
-- Guarantees at most one running loop per toggle (rapid off/on safe).
function Tato.loop(fn)
    local on, gen = false, 0
    return function(state)
        on = state
        if not state then return end
        gen = gen + 1
        local myGen = gen
        task.spawn(function()
            local function alive() return on and gen == myGen end
            while alive() do
                local ok, err = pcall(fn, alive)
                if not ok then
                    warn("[Tato Hub] loop error: " .. tostring(err))
                    break
                end
            end
        end)
    end
end

local WHITELIST_URL = "https://raw.githubusercontent.com/totemoflol/ToT-Nexus/main/idle%20potato%20game/WhitelistedTaters.lua"

-- Premium check. SECURITY: fetches the whitelist directly and keeps it local,
-- so spoofing getgenv() (e.g. whitelisting yourself) has no effect.
function Tato.isWhitelisted()
    local ok, wl = pcall(function()
        return loadstring(game:HttpGet(WHITELIST_URL))()
    end)
    if not ok or type(wl) ~= "table" or type(wl.ids) ~= "table" then
        return false
    end
    return wl.ids[Players.LocalPlayer.UserId] == true
end

-- Standard section header label
function Tato.header(tab, text)
    tab:CreateLabel(text, Tato.Icon, Color3.fromRGB(255, 255, 255), false)
end
