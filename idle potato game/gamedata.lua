-- =====================================================================
-- gamedata.lua | Idle Potato Game remote reference
-- DATA ONLY -- not in MainScript's load list, never executes.
-- Source: player dump 2026-09-14 (157 remotes). Update via Import Tool.
--
-- Conventions:
--   C2S = client fires server (FireServer)  -> usable by the hub
--   S2C = server fires client (OnClientEvent) -> listen/monitor
--   [F] = RemoteFunction (InvokeServer)
-- Known args are documented inline from working script usage.
-- =====================================================================

local Gamedata = {
    Game = "Idle Potato Game",
    PlaceId = 122079988266644,
    UniverseId = 9655897254,

    -- Remote at the ReplicatedStorage ROOT (not in .Remotes):
    RootRemotes = {
        "PlayerIdled", -- S2C
    },
}

-- =====================================================================
-- CORE LOOP -- already used by the current script
-- =====================================================================
Gamedata.Core = {
    "PerformClick",         -- C2S, no args (auto clicker)
    "PerformPrestige",      -- C2S, no args (auto prestige)
    "PerformAscension",     -- C2S, kind: "abundance" | "prestige" | "thrifty"
    "SellGoldenPotatoes",   -- C2S, amount: number
    "PurchaseClickUpgrade", -- C2S, upgradeId (ids below)
    "PurchaseGenerator",    -- C2S, generatorId (ids below)
    "DeleteGenerator",      -- C2S, generatorId
    "PurchaseShopPotato",   -- C2S, itemId (ids below)
}

-- =====================================================================
-- SELLING
-- =====================================================================
Gamedata.Selling = {
    "SellAllGoldenPotatoes", -- C2S, REQUIRES GAMEPASS (do not use)
    "SellAllPotatoes",       -- C2S, REQUIRES GAMEPASS (do not use)
    "SellPotatoes",          -- C2S, amount (normal potatoes -- used by Auto Sell Potatoes)
    "AutoSellTriggered",     -- S2C
    "SellComplete",          -- S2C
}

-- =====================================================================
-- UPGRADES / GENERATORS / ROOTS
-- =====================================================================
Gamedata.Upgrades = {
    "AddGenerator",             -- C2S?
    "PurchaseGeneratorSlot",    -- C2S
    "PurchasePrestigeUpgrade",  -- C2S
    "PurchaseRootNode",         -- C2S
    "PurchasePotatoRoots",      -- C2S
    "PurchaseDigUpgrade",       -- C2S (dig minigame)
    "RefundAllRoots",           -- C2S
    "GetUpgradeCost",           -- [F]
    "GetPrestigeUpgradeCost",   -- [F]
    "GetGeneratorCost",         -- [F]
    "GetAscensionInfo",         -- [F]
    "GetPotentialPrestigePoints", -- [F]
    "AutoPrestigeTriggered",    -- S2C
    "PrestigeComplete",         -- S2C
    "AscensionComplete",        -- S2C
    "UpdateAutoPrestigeSettings", -- C2S (game has built-in auto prestige!)
    "UpdateAutoSellSettings",   -- C2S (built-in auto sell!)
    "ToggleAutoBuyGenerator",   -- C2S (built-in generator autobuy!)
}

-- =====================================================================
-- SHOP / POTIONS / MYSTERY BOXES
-- =====================================================================
Gamedata.Shop = {
    "PurchasePremiumItem",       -- C2S
    "PurchaseSeasonalItem",      -- C2S
    "PurchaseHotDeal",           -- C2S
    "SetPendingPremiumItem",     -- C2S
    "UsePotion",                 -- C2S (activate owned potion)
    "OpenMysteryBox",            -- C2S
    "OpenMultipleMysteryBoxes",  -- C2S
    "GetShopRotation",           -- [F]
    "GetPremiumShop",            -- [F]
    "GetSeasonalShop",           -- [F]
    "ResolveUsername",           -- [F]
    -- S2C updates/results:
    "ShopRotationUpdated", "PremiumShopUpdated", "SeasonalShopUpdated",
    "MysteryBoxResult", "MultipleMysteryBoxResult",
    "HotDealAvailable", "HotDealExpired", "HotDealPurchased",
    "PotionBuffUpdated",
}

-- =====================================================================
-- POTATOES: genetics / fusion / crafting / inventory
-- =====================================================================
Gamedata.Potatoes = {
    "GeneticsRollAll",      -- C2S
    "GeneticsRollSlot",     -- C2S
    "GeneticsUnlockSlot",   -- C2S
    "FusePotatoes",         -- C2S
    "CraftItem",            -- C2S
    "DissolvePotatoes",     -- C2S
    "EquipPotato",          -- C2S
    "EquipBackground",      -- C2S
    "DeletePotatoItem", "DeleteRelicItem", "DeleteBackgroundItem", "DeleteInventoryItem", -- C2S
    "TogglePotatoLock", "ToggleRelicLock", "ToggleBackgroundLock", -- C2S
    "UpdateFavoriteStatus", -- C2S
    -- S2C:
    "GeneticsResult", "FusionResult", "CraftResult", "DissolveResult",
    "GoldenPotatoFound", "RarePotatoFound", "MagicPotatoFound", "CosmicPotatoFound",
}

-- =====================================================================
-- BOOSTS
-- =====================================================================
Gamedata.Boosts = {
    "ActivateFreeBoost",                    -- C2S
    "ActivateFreeGlobalBoost",              -- C2S
    "ActivateLeaderboardFreeGlobalBoost",   -- C2S
    "ClaimOfflineBoostBonus",               -- C2S
    "RefreshSocialBonuses",                 -- C2S
    "GetActiveGlobalBoosts",                -- [F]
    "GetActiveServerBoosts",                -- [F]
    "CheckLeaderboardBoostEligibility",     -- [F]
    -- S2C:
    "GlobalBoostActivated", "GlobalBoostsUpdated",
    "ServerBoostActivated", "ServerBoostsUpdated",
    "LeaderboardFreeBoostUsed",
}

-- =====================================================================
-- REWARDS / LOGIN / CODES
-- =====================================================================
Gamedata.Rewards = {
    "ClaimLoginStreak",   -- C2S
    "ClaimBossReward",    -- C2S
    "DamageBoss",         -- C2S
    "RedeemCode",         -- C2S, presumably code string
    "ResetAllData",       -- C2S (DANGER)
    -- S2C:
    "LoginStreakClaimed", "SessionRewardGranted", "SessionRewardsReset",
    "CodeRedeemed", "WelcomeBack", "GamepassGiftReceived", "GamepassGiftResult",
    "InitiateGamepassGift", -- C2S
}

-- =====================================================================
-- DIG MINIGAME
-- =====================================================================
Gamedata.Dig = {
    "DigStartRound",     -- C2S
    "DigSquare",         -- C2S
    "DigResult",         -- S2C
    "DigRoundInfo",      -- S2C
    "DigStaminaUpdate",  -- S2C
}

-- =====================================================================
-- GUILDS
-- =====================================================================
Gamedata.Guild = {
    "CreateGuild", "JoinGuild", "LeaveGuild", "DisbandGuild", -- C2S
    "InviteToGuild", "RespondToGuildInvite", -- C2S
    "SearchGuilds", -- [F]
    "BanGuildMember", "UnbanGuildMember", "RemoveGuildMember", -- C2S
    "PromoteGuildMember", "DemoteGuildMember", -- C2S
    "TransferGuildOwnership", "DonateToGuild", "PurchaseGuildUpgrade", -- C2S
    "UpdateGuildName", "UpdateGuildEmblem", "UpdateGuildJoinMode", -- C2S
    "GuildChatSend",     -- C2S
    "GetGuildData", "GetGuildBuffs", -- [F]
    -- S2C:
    "GuildDataUpdated", "GuildBanned", "GuildBossUpdate", "GuildChatDelivery",
    "GuildDisbanded", "GuildInviteReceived", "GuildInviteResponse", "GuildKicked",
}

-- =====================================================================
-- TRADING
-- =====================================================================
Gamedata.Trading = {
    "SendTradeRequest", -- C2S
    "RespondToTrade",   -- C2S
    -- S2C:
    "TradeRequestReceived", "TradeResult",
}

-- =====================================================================
-- LEADERBOARDS / INFO
-- =====================================================================
Gamedata.Info = {
    "GetPlayerData",           -- [F]
    "GetLeaderboard",          -- [F]
    "GetGlobalLeaderboard",    -- [F]
    "GetServerLeaderboard",    -- [F]
    "GetServerPlayers",        -- [F]
    -- S2C:
    "DataUpdated", "DataReset", "ClickResult", "Error", "UpdateSettings", "UpdateGroupStatus",
}

-- =====================================================================
-- ADMIN (game-side) -- interesting targets
-- =====================================================================
Gamedata.Admin = {
    "AdminAction",          -- [F] !!!
    "AdminBroadcast",       -- S2C
    "AdminGift",            -- S2C?
    "SubmitBroadcastReply", -- C2S
}

-- =====================================================================
-- KNOWN ARGUMENT IDS (from working scripts)
-- =====================================================================
Gamedata.KnownIds = {
    -- Full click upgrade chain (spy-verified 2026-09-14).
    -- INCOMPLETE: more tiers exist past infinite_potato_mastery
    -- (not affordable yet -- spy more purchases to extend).
    ClickUpgradeChain = {
        "stronger_hands",
        "padded_gloves",
        "steel_trowel",
        "golden_trowel",
        "farmers_instinct",
        "advanced_techniques",
        "grandfathers_wisdom",
        "lunar_planting",
        "dimensional_reach",
        "infinite_energy",
        "omnipotato_blessing",
        "transcendent_harvest",
        "galactic_harvest",
        "universal_potato_power",
        "infinite_potato_mastery",
    },
    ClickUpgrades = {
        "grandfathers_wisdom",
        "infinite_energy",
        "omnipotato_blessing",
        "transcendent_harvest",
        "galactic_harvest",
    },
    Generators = {
        "potato_seedling",
        "dimensional_mirror",
        "temporal_harvester",
        "superfactory_number_67",
        "potato_nexus",
        "omnipotato",
        "double_omnipotato",
        "infinite_omnipotato",
        "potato_infinite_universe",
    },
    ShopItems = {
        "potion_production",
        "potion_luck",
        "potion_golden",
        "potion_click",
        "emoji_mystery_potato",
    },
    AscensionKinds = { "abundance", "prestige", "thrifty" },
}

-- =====================================================================
-- FEATURE IDEAS (from this dump)
-- =====================================================================
-- 1. SellAllGoldenPotatoes/SellAllPotatoes: replace GUI-reading sell-all with a direct remote (cleaner, faster)
-- 2. UsePotion: auto-use owned potions on a timer (pairs with the potion auto-buyers)
-- 3. Genetics/fusion macros: GeneticsRollAll loop, auto FusePotatoes on result
-- 4. Dig minigame auto-player: DigStartRound + DigSquare spam (DigResult tells hits)
-- 5. ClaimLoginStreak + ActivateFreeBoost on join
-- 6. DamageBoss loop for guild bosses
-- 7. UpdateAutoSellSettings/UpdateAutoPrestigeSettings: the game has NATIVE auto systems;
--    enabling them server-side may be safer/faster than client-side loops

return Gamedata
