-- lib.lua | Tato Hub shared helpers (loaded before all tabs)
local Players = game:GetService("Players")

local Tato = {}
getgenv().Tato = Tato

Tato.Icon = 4483362458

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

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

-- Premium check (whitelist is set by WhitelistedTaters.lua; UserId or username)
function Tato.isWhitelisted()
    local check = getgenv().isTaterWhitelisted
    if check then
        local ok, res = pcall(check, Players.LocalPlayer)
        if ok then return res == true end
    end
    local list = getgenv().whitelistedtaters or {}
    return list[Players.LocalPlayer.UserId] == true
end

-- Standard section header label
function Tato.header(tab, text)
    tab:CreateLabel(text, Tato.Icon, Color3.fromRGB(255, 255, 255), false)
end
