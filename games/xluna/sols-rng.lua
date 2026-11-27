-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB â Sol's RNG [ Part 2 ] Full Automation Suite
    Author: By XLunaHUB
    PlaceId: 15532962292
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Clean up any previous instance before initializing
local genv = getgenv and getgenv() or _G
if genv.__XLunaHUB_SolsRNG and type(genv.__XLunaHUB_SolsRNG.Cleanup) == "function" then
    pcall(genv.__XLunaHUB_SolsRNG.Cleanup)
end

local SESSION_ID = HttpService:GenerateGUID(false)
local Runtime = {
    SessionId = SESSION_ID,
    Alive = true,
    Connections = {},
    Threads = {},
    EspObjects = {},
    Window = nil,
    OrigQuickRoll = LocalPlayer:GetAttribute("QuickRollEnabled"),
    ModifiedQuickRoll = false,
    OrigLighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
    },
}

local function TrackConn(conn)
    if conn then
        table.insert(Runtime.Connections, conn)
    end
    return conn
end

local function TrackSpawn(fn)
    local co = task.spawn(fn)
    table.insert(Runtime.Threads, co)
    return co
end

local function ClearEsp()
    for i = #Runtime.EspObjects, 1, -1 do
        local obj = Runtime.EspObjects[i]
        if obj and obj.Parent then
            pcall(function() obj:Destroy() end)
        end
        Runtime.EspObjects[i] = nil
    end
end

-- ============================================================================
-- STATE & CONFIGURATION (STRICTLY ALL OFF AT STARTUP)
-- ============================================================================
local State = {
    -- Toggles (ALL OFF)
    AntiAFK = false,
    BiomeSniperAlerts = false,
    MerchantAlerts = false,

    AutoRoll = false,
    InstantRoll = false,
    AutoRespondRoll = false,
    KeepUndiscovered = false,
    KeepCraftingAuras = false,
    AutoLockRare = false,
    AutoUpgradeStorage = false,

    AutoCollectDrops = false,
    AutoAreaBuffs = false,
    AutoUsePotions = false,
    PotionOnlyTargetBiome = false,
    AutoOpenChests = false,
    AutoBiomeSelector = false,

    AutoCraftLoop = false,
    AutoEquipCrafted = false,

    AutoRodFish = false,
    AutoNetFish = false,
    AutoMinigamePerfect = false,
    AutoSellFish = false,
    SellMutantFish = false,
    AutoUpgradeFishBag = false,

    AutoClaimDailyQuests = false,
    AutoSideQuests = false,
    AutoClaimAchievements = false,
    AutoClaimSeasonPass = false,
    AutoClaimEventDaily = false,
    AutoClaimHalloweenHunt = false,
    AutoMemoryMatch = false,
    AutoBossRaid = false,

    AutoBuyMerchant = false,
    AutoExchangeItems = false,
    AutoBuyDailyShop = false,
    AutoUpgradeBank = false,

    EspDrops = false,
    EspMerchants = false,
    EspAreaGivers = false,
    EspStickyNotes = false,

    WalkSpeedEnabled = false,
    JumpPowerEnabled = false,
    InfiniteJump = false,
    Noclip = false,
    Fullbright = false,
    LowGfx = false,

    -- Parameters / Filters
    RollDelayBuffer = 0.05,
    MinKeepRarity = 10000,
    AutoLockRarity = 100000,
    AuraWhitelist = {},
    AuraBlacklist = {},
    TargetSniperBiomes = { "Glitched", "Dreamspace", "Null", "Starfall", "Corruption", "Hell", "Heaven", "Pumpkinmoon", "Blood Rain", "Singularity" },

    SelectedPotions = { "Lucky Potion", "Speed Potion", "Fortune Potion I" },
    SelectedChests = { "Potion Chest", "Rare Potion Chest", "Mega Potion Chest", "Random Rune Chest" },
    PotionBiomes = { "Glitched", "Pumpkinmoon", "Starfall", "Null", "Hell", "Heaven" },
    TargetSelectorBiome = "Glitched",

    CraftNamespace = "JakeWorkshop",
    SelectedRecipe = "",

    FishAreaFilter = "Any",
    SellFishTiers = { "common", "uncommon" },
    FishShopItem = "Basic Rod",

    BossName = "Sinister P.",
    BossDifficulty = "Normal",
    BossQueueMode = "Solo",

    MerchantWantedItems = { "Void Coin", "Oblivion Potion", "Heavenly Potion", "Lucky Penny", "Gear Basing", "Rune of Everything", "Rune of Nothing" },
    ExchangeWantedItems = { "Rainy Bottle", "Wind essence", "Icicle" },
    DailyShopWantedSlots = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
    DailyShopMethod = "Coin",

    WalkSpeedValue = 24,
    JumpPowerValue = 55,

    -- Live Telemetry (Populated from Actor Bridge)
    Live = {
        Biome = "Normal",
        Time = "Day",
        Luck = 1,
        Rolls = 0,
        Coins = 0,
        DarkCoins = 0,
        HollowPoints = 0,
        FishCoins = 0,
        Bank = 0,
        BankCapacity = 100000,
        BankEnabled = false,
        NextRollable = 0,
        RollDelay = 1,
        PendingAura = "",
        IsPendingResolved = true,
        AuraCount = 0,
        MaxStorableAuras = 20,
        FishCount = 0,
        FishInventorySize = 20,
        SeasonLevel = 0,
        Inventory = {},
        Buffs = {},
        Merchants = {},
        Discovered = {},
        DailyQuests = {},
        SideQuests = {},
        ActiveSideQuests = {},
        SessionRolls = 0,
        SessionRare = 0,
        LastAura = "None",
        LastRarity = 0,
        ActorReady = false,
        UnclaimedSeasonPass = false,
        MemoryMatchActive = false,
    },
    CraftingRecipes = {
        JakeWorkshop = {},
        StellaCauldron = {},
    },
    RecipeIngredients = {},
    CraftingRequiredAuras = {},
    MemoryBoard = {},
}

-- ============================================================================
-- LOAD CATALOGS NON-YIELDINGLY FROM REPLICATEDSTORAGE
-- ============================================================================
local AuraList = {}
local ItemList = {}
local TierFolder = ReplicatedStorage:FindFirstChild("TierList")
if TierFolder then
    local seen = {}
    for _, child in ipairs(TierFolder:GetChildren()) do
        local name = tostring(child:GetAttribute("Value") or child.Name)
        if name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(AuraList, name)
        end
    end
    table.sort(AuraList)
end

local ItemFolder = ReplicatedStorage:FindFirstChild("ItemList")
if ItemFolder then
    local seen = {}
    for _, child in ipairs(ItemFolder:GetChildren()) do
        if child.Name ~= "" and not seen[child.Name] then
            seen[child.Name] = true
            table.insert(ItemList, child.Name)
        end
    end
    table.sort(ItemList)
end

local PotionList = {}
local ChestList = {}
for _, name in ipairs(ItemList) do
    local lower = name:lower()
    if lower:find("potion") or lower:find("vial") or lower:find("brew") or lower:find("bottle") or lower:find("penny") or lower:find("essence") then
        table.insert(PotionList, name)
    end
    if lower:find("chest") or lower:find("box") or lower:find("pack") or lower:find("crate") or lower:find("present") then
        table.insert(ChestList, name)
    end
end
if #PotionList == 0 then PotionList = ItemList end
if #ChestList == 0 then ChestList = ItemList end

local RecipeList = {}
local NewRecipeFolder = ReplicatedStorage:FindFirstChild("NewRecipeList")
if NewRecipeFolder then
    local seen = {}
    for _, child in ipairs(NewRecipeFolder:GetChildren()) do
        if child.Name ~= "" and not seen[child.Name] then
            seen[child.Name] = true
            table.insert(RecipeList, child.Name)
        end
    end
    table.sort(RecipeList)
end
if #RecipeList == 0 then
    RecipeList = { "Luck Glove", "Lunar Device", "Solar Device" }
end

local KnownBiomes = {
    "Normal", "Windy", "Rainy", "Snowy", "Sand Storm", "Hell", "Starfall",
    "Corruption", "Null", "Glitched", "Dreamspace", "Heaven", "Pumpkinmoon",
    "Blood Rain", "Singularity", "Cyberspace", "Graveyard"
}

local KnownCodes = {
    "THXFOR1B", "HALLOWEEN2026", "SOLSRNG", "UPDATE", "SORRYFORDELAY",
    "PIXEL", "LIMBO", "FISHING", "BOSSRAID", "HAPPYNEWYEAR"
}

-- ============================================================================
-- ACTOR COMM BRIDGE (ReplicatedFirst.ClientHandlers)
-- ============================================================================
local cmdId, cmdCh = create_comm_channel()
local evtId, evtCh = create_comm_channel()

local function SendActorCmd(cmd, ...)
    if Runtime.Alive and cmdCh then
        cmdCh:Fire(SESSION_ID, cmd, ...)
    end
end

local ActorBridgeSource = [===[
    local cmdId, evtId, sessionId = ...
    local cmdCh = get_comm_channel(cmdId)
    local evtCh = get_comm_channel(evtId)

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local RunService = game:GetService("RunService")

    local LocalPlayer = Players.LocalPlayer
    local Modules = ReplicatedStorage:WaitForChild("Modules")
    local Packets = ReplicatedStorage:WaitForChild("Packets")
    local Storage = ReplicatedStorage:WaitForChild("Storage")
    local Remote = ReplicatedStorage:WaitForChild("Remote")

    -- Terminate any older bridge inside this Actor
    local actorEnv = shared
    if actorEnv.__XLunaActorCleanup then
        pcall(actorEnv.__XLunaActorCleanup)
    end

    local alive = true
    local actorConns = {}
    local cfg = {
        autoRoll = false,
        instantRoll = false,
        autoRespond = false,
        minKeepRarity = 10000,
        keepUndiscovered = false,
        keepCraftingAuras = false,
        autoLockRare = false,
        autoLockRarity = 100000,
        whitelist = {},
        blacklist = {},
        craftingAuras = {},
        autoFishPerfect = false,
        autoSellFish = false,
        sellTiers = {},
        sellMutant = false,
    }

    local function CleanupActor()
        alive = false
        for _, c in ipairs(actorConns) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(actorConns)
    end
    actorEnv.__XLunaActorCleanup = CleanupActor

    local rc = require(ReplicatedStorage:WaitForChild("ReplicaController"))
    local Rolling = require(Packets:WaitForChild("Rolling"))
    local StoragePkt = require(Packets:WaitForChild("Storage"))
    local InventoryPkt = require(Packets:WaitForChild("Inventory"))
    local DailyQuestPkt = require(Packets:WaitForChild("DailyQuest"))
    local SideQuestPkt = require(Packets:WaitForChild("SideQuest"))
    local MerchantPkt = require(Packets:WaitForChild("Merchant"))
    local FishingPkt = require(Packets:WaitForChild("Fishing"))
    local GlobalPkt = require(Packets:WaitForChild("Global"))
    local LimboPkt = require(Packets:WaitForChild("Limbo"))

    local RollUI = require(Modules:WaitForChild("UI"):WaitForChild("RollUI"))
    local FishUI = nil
    pcall(function()
        FishUI = require(ReplicatedFirst.ClientHandlers.FishingClient.FishUI)
    end)
    local FishShopUI = nil
    pcall(function()
        FishShopUI = require(Modules:WaitForChild("UI"):WaitForChild("FishingShopUI"))
    end)
    local FishStore = nil
    pcall(function()
        FishStore = require(Storage:WaitForChild("FishStore"))
    end)
    local MerchantUIBeta = nil
    pcall(function()
        MerchantUIBeta = require(Modules.UI.Merchant.MerchantUIBeta)
    end)
    local BuffsMod = nil
    pcall(function()
        BuffsMod = require(Storage:WaitForChild("Buffs"))
    end)
    local ItemDB = nil
    pcall(function()
        ItemDB = require(Storage:WaitForChild("ItemDB"))
    end)
    local DailyQuestUI = nil
    pcall(function()
        DailyQuestUI = require(Modules:WaitForChild("UI"):WaitForChild("DailyQuestUI"))
    end)
    local Serializer = nil
    pcall(function()
        Serializer = require(Modules:WaitForChild("Serializer"))
    end)
    local SeasonPassUI = nil
    pcall(function()
        SeasonPassUI = require(Modules:WaitForChild("UI"):WaitForChild("SeasonPassUI"))
    end)
    local SideQuestUI = nil
    pcall(function()
        SideQuestUI = require(Modules:WaitForChild("UI"):WaitForChild("SideQuestUI"))
    end)
    local MemoryMatchUI = nil
    pcall(function()
        MemoryMatchUI = require(ReplicatedFirst.ClientHandlers.Funcs.MemoryMatchClient.MemoryMatchUI)
    end)

    local POTION_BUFF_MAP = {
        ["Lucky Potion"] = "Lucky",
        ["Speed Potion"] = "QuickRoll",
        ["Fortune Potion I"] = "Fortune I",
        ["Fortune Potion II"] = "Fortune II",
        ["Fortune Potion III"] = "Fortune III",
        ["Haste Potion I"] = "Haste I",
        ["Haste Potion II"] = "Haste II",
        ["Haste Potion III"] = "Haste III",
        ["Heavenly Potion"] = "Heavenly",
        ["Heavenly Potion I"] = "Heavenly I",
        ["Heavenly Potion II"] = "Heavenly II",
        ["Oblivion Potion"] = "Oblivion",
        ["Rage Potion"] = "Raged",
        ["Diver Potion"] = "Diver",
        ["Jewelry Potion"] = "Jewelry",
        ["Zombie Potion"] = "Zombie",
        ["Warp Potion"] = "Warp",
        ["Godlike Potion"] = "Godlike",
        ["Pump King's Blood"] = "Pump King's Blood",
    }

    local function extractPotionBuffName(itemName)
        if POTION_BUFF_MAP[itemName] then
            return POTION_BUFF_MAP[itemName]
        end
        if ItemDB and ItemDB.GetValueUnsafe then
            local ok, info = pcall(function() return ItemDB:GetValueUnsafe(itemName) end)
            if ok and type(info) == "table" and type(info.Description) == "string" then
                local plain = info.Description:gsub("<[^>]+>", "")
                local tag = plain:match("%[(.-)%]")
                if tag and tag ~= "" then
                    return tag
                end
            end
        end
        return (itemName:gsub(" Potion", ""))
    end

    local function isBuffActive(buffName, minRemaining)
        if not BuffsMod or not BuffsMod.IsReady or not BuffsMod:IsReady() then
            return false
        end
        local minRem = minRemaining or 2
        local function checkKey(key)
            if not key or key == "" then return false end
            local okH, has = pcall(function() return BuffsMod:HasBuff(key, 1, true) end)
            if not okH or not has then return false end
            local okR, rem = pcall(function() return BuffsMod:GetRemainingTime(key) end)
            return okR and type(rem) == "number" and rem > minRem
        end
        if checkKey(buffName) then return true end
        local compact = type(buffName) == "string" and buffName:gsub("%s+", "") or ""
        if compact ~= "" and compact ~= buffName then
            return checkKey(compact)
        end
        return false
    end

    local function getReplicas()
        local pData, sInfo = nil, nil
        for _, rep in pairs(rc._replicas or {}) do
            if rep.Class == "PlayerData" then
                pData = rep
            elseif rep.Class == "ServerInfo" then
                sInfo = rep
            end
        end
        return pData, sInfo
    end

    local nextRollable = 0
    local rollDelay = 1
    local pendingResponse = false
    local pendingSince = 0
    local lastPendingResolve = 0
    local lastDrinkAttempt = {}
    local dailyClaimCooldown = {}
    local achClaimedSent = {}

    local function isAuraDiscovered(pData, auraVal)
        if not pData or not pData.Data then return true end
        local d = pData.Data
        if auraVal == "Common" then return true end
        if d.HiddenAuraFound and d.HiddenAuraFound[auraVal] then return true end
        local base, skin = table.unpack(string.split(auraVal, "_"))
        if not skin then
            return d.DiscoveredAura and table.find(d.DiscoveredAura, base) ~= nil
        end
        return d.SkinsOwned and d.SkinsOwned[base] and table.find(d.SkinsOwned[base], skin) ~= nil
    end

    local function canStoreOrReplaceAura(pData)
        if not pData or not pData.Data then return true end
        local inv = pData.Data.InventoryAuras or {}
        local maxAuras = pData.Data.MaxStorableAuras or 20
        if #inv < maxAuras then return true end
        for i = 1, maxAuras do
            local entry = inv[i]
            if not entry or not entry.Locked then
                return true
            end
        end
        return false
    end

    local function evaluateRoll(auraName, rarityNum)
        if cfg.blacklist[auraName] then
            return 2 -- Delete
        end
        if cfg.whitelist[auraName] then
            return 1 -- Keep/Equip
        end
        if cfg.keepUndiscovered then
            local pData = getReplicas()
            if not isAuraDiscovered(pData, auraName) then
                return 1
            end
        end
        if cfg.keepCraftingAuras and cfg.craftingAuras[auraName] then
            return 1
        end
        if (tonumber(rarityNum) or 0) >= (tonumber(cfg.minKeepRarity) or 10000) then
            return 1
        end
        return 2
    end

    local function dismissRollUI()
        pcall(function()
            RollUI:ClearBackground()
            RollUI:DisappearBackground()
            if RollUI.Buttons then
                if RollUI.Buttons.Equip then RollUI.Buttons.Equip.Visible = false end
                if RollUI.Buttons.Skip then RollUI.Buttons.Skip.Visible = false end
                if RollUI.Buttons.Roll then RollUI.Buttons.Roll.Visible = true end
            end
        end)
    end

    local function resolveRollCleanly(auraName, rarityNum)
        local decision = evaluateRoll(auraName, rarityNum)
        if decision == 1 then
            local pData = getReplicas()
            if not canStoreOrReplaceAura(pData) then
                if (tonumber(rarityNum) or 0) >= 100000 then
                    pendingResponse = false
                    return -- Protect rare roll when storage is full & all locked
                end
                decision = 2
            end
        end
        Rolling.SendResponse.send(decision)
        pendingResponse = false
        dismissRollUI()
        task.delay(0.15, function()
            if alive then dismissRollUI() end
        end)
    end

    -- Rolling Listeners
    Rolling.ResetDelay.listen(function(pkt)
        if not alive then return end
        nextRollable = pkt.NextRollable or 0
        rollDelay = pkt.RollDelay or 1
        pendingResponse = false
        if cfg.instantRoll or cfg.autoRoll or cfg.autoRespond then
            dismissRollUI()
        end
        evtCh:Fire(sessionId, "RollDelay", nextRollable, rollDelay)
    end)

    Rolling.SendResult.listen(function(pkt)
        if not alive then return end
        local auraName = tostring(pkt.Value or "Common")
        local rarity = tonumber(pkt.Rarity) or 0
        pendingResponse = true
        pendingSince = os.clock()
        evtCh:Fire(sessionId, "RollResult", auraName, rarity, tostring(pkt.FromWhat or ""))

        if cfg.autoRespond or cfg.autoRoll then
            task.defer(function()
                if not alive then return end
                resolveRollCleanly(auraName, rarity)
            end)
        end
    end)

    StoragePkt.AddAura.listen(function(pkt)
        if not alive then return end
        if cfg.autoLockRare and pkt and pkt.Name then
            local pData = getReplicas()
            if pData and pData.Data and pData.Data.InventoryAuras then
                local idx = #pData.Data.InventoryAuras
                -- Check if last aura rarity meets threshold
                local lastRarity = 0
                pcall(function()
                    local RarityDB = require(Storage:WaitForChild("RarityDB"))
                    local info = RarityDB:GetValue(pkt.Name)
                    if type(info) == "table" then
                        lastRarity = tonumber(info.GeneralRarity) or 0
                    end
                end)
                if idx > 0 and lastRarity >= (tonumber(cfg.autoLockRarity) or 100000) and not pkt.Locked then
                    StoragePkt.Lock.send(idx)
                end
            end
        end
    end)

    -- Fishing Minigame Solver & Auto-Sell Confirm
    table.insert(actorConns, RunService.RenderStepped:Connect(function()
        if not alive or not FishUI then return end
        if cfg.autoFishPerfect and FishUI.isMinigameMode then
            local pos = FishUI.successPosition or 0.4
            local width = FishUI.successWidth or 0.2
            FishUI.fishProgress = math.clamp(pos + width * 0.5, 0, 1)
            FishUI.catchProgress = 100
        end
    end))

    FishingPkt.sellFish.listen(function(uid)
        if not alive then return end
        if cfg.autoSellFish and FishShopUI then
            FishShopUI.Store.SelectedFishUID = uid
            task.defer(function()
                FishingPkt.sellConfirm.send(true)
            end)
        end
    end)

    FishingPkt.sellAllFish.listen(function(fishId)
        if not alive then return end
        if cfg.autoSellFish then
            task.defer(function()
                FishingPkt.sellAllFishConfirm.send(true)
            end)
        end
    end)

    -- Merchant & Code Redeem Listeners
    local merchantSpawnedRemote = Remote:WaitForChild("Merchant"):FindFirstChild("MerchantSpawned")
    if merchantSpawnedRemote then
        table.insert(actorConns, merchantSpawnedRemote.OnClientEvent:Connect(function(info)
            if alive and type(info) == "table" then
                evtCh:Fire(sessionId, "MerchantSpawned", info.merchant_name or info.merchant_id or "Merchant")
            end
        end))
    end

    GlobalPkt.RedeemCodeResult.listen(function(pkt)
        if not alive then return end
        evtCh:Fire(sessionId, "CodeResult", pkt[1] == true, tostring(pkt[2] or ""))
    end)

    -- Memory Match Listener
    local mmRemote = Remote:WaitForChild("MemoryMatch"):FindFirstChild("RemoteEvent")
    if mmRemote then
        table.insert(actorConns, mmRemote.OnClientEvent:Connect(function(kind, ...)
            if not alive then return end
            local args = {...}
            if kind == "reveal" then
                evtCh:Fire(sessionId, "MMReveal", args[1], args[2])
            elseif kind == "matched" then
                evtCh:Fire(sessionId, "MMMatched", args[1])
            elseif kind == "unreveal" then
                evtCh:Fire(sessionId, "MMUnreveal", args[1])
            elseif kind == "revealAll" then
                evtCh:Fire(sessionId, "MMRevealAll")
            end
        end))
    end

    -- Command Dispatcher
    table.insert(actorConns, cmdCh.Event:Connect(function(sid, cmd, a1, a2, a3)
        if not alive or sid ~= sessionId then return end
        if cmd == "Shutdown" then
            CleanupActor()
            return
        elseif cmd == "Config" and type(a1) == "table" then
            for k, v in pairs(a1) do
                cfg[k] = v
            end
        elseif cmd == "SendResponse" then
            Rolling.SendResponse.send(tonumber(a1) or 2)
            pendingResponse = false
        elseif cmd == "UseItem" then
            InventoryPkt.UseItem.send({ itemName = tostring(a1), amount = tonumber(a2) or 1 })
        elseif cmd == "DrinkMissingPotions" and type(a1) == "table" then
            local pData = getReplicas()
            local inv = pData and pData.Data and pData.Data.Inventory or {}
            local nowClock = os.clock()
            for _, itemName in ipairs(a1) do
                local invEntry = inv[itemName]
                local amt = type(invEntry) == "table" and (invEntry.Amount or 0) or 0
                if amt > 0 and (nowClock - (lastDrinkAttempt[itemName] or 0) >= 3.5) then
                    local buffName = extractPotionBuffName(itemName)
                    local skipHigher = false
                    if buffName == "Fortune I" and (isBuffActive("Fortune II", 3) or isBuffActive("Fortune III", 3)) then
                        skipHigher = true
                    elseif buffName == "Fortune II" and isBuffActive("Fortune III", 3) then
                        skipHigher = true
                    elseif buffName == "Haste I" and (isBuffActive("Haste II", 3) or isBuffActive("Haste III", 3)) then
                        skipHigher = true
                    elseif buffName == "Haste II" and isBuffActive("Haste III", 3) then
                        skipHigher = true
                    end
                    if not skipHigher and not isBuffActive(buffName, 3) then
                        lastDrinkAttempt[itemName] = nowClock
                        InventoryPkt.UseItem.send({ itemName = tostring(itemName), amount = 1 })
                        task.wait(0.18)
                    end
                end
            end
        elseif cmd == "ClaimCompletedDailyQuests" then
            local pData = getReplicas()
            local d = pData and pData.Data
            local store = DailyQuestUI and DailyQuestUI.Store
            local cont = store and store.container
            if type(cont) == "table" and cont.__object then cont = cont.__object end
            if d and typeof(cont) == "Instance" then
                local claimed = d.ClaimedQuests or {}
                local nowClock = os.clock()
                for i = 1, 3 do
                    if not claimed[i] and (nowClock - (dailyClaimCooldown[i] or 0) >= 25) then
                        for _, child in ipairs(cont:GetChildren()) do
                            if child:IsA("ImageButton") and child.LayoutOrder == i then
                                local chk = child:FindFirstChildOfClass("ImageLabel")
                                if chk and chk.ImageTransparency == 0 then
                                    dailyClaimCooldown[i] = nowClock
                                    pcall(function()
                                        if replicatesignal then
                                            replicatesignal(child.MouseButton1Down)
                                        end
                                    end)
                                    task.wait(0.1)
                                    if store.claimButton and not store.claimButton.Disabled and type(store.claimButton.Callback) == "function" then
                                        pcall(store.claimButton.Callback)
                                    end
                                    task.wait(0.35)
                                end
                                break
                            end
                        end
                    end
                end
            end
        elseif cmd == "EquipGear" then
            InventoryPkt.EquipItem.send({ gearType = tostring(a1), gearName = tostring(a2) })
        elseif cmd == "UnequipGear" then
            InventoryPkt.UnequipItem.send(tostring(a1))
        elseif cmd == "UpgradeStorage" then
            StoragePkt.Upgrade.send()
        elseif cmd == "LockAura" then
            StoragePkt.Lock.send(tonumber(a1))
        elseif cmd == "EquipAura" then
            StoragePkt.Equip.send({ i = tonumber(a1), s = false })
        elseif cmd == "ClaimDailyQuest" then
            DailyQuestPkt.Claim.send(tonumber(a1))
        elseif cmd == "RerollDailyQuest" then
            DailyQuestPkt.Reroll.send(tonumber(a1))
        elseif cmd == "HandleSideQuestBoard" then
            local pData = getReplicas()
            local d = pData and pData.Data
            if SideQuestUI and SideQuestUI.Store and SideQuestUI.Store.visible == true then
                if SideQuestUI.Store.accepted and SideQuestUI.Store.completed and SideQuestUI.Store.claim and type(SideQuestUI.Store.claim.Callback) == "function" then
                    pcall(SideQuestUI.Store.claim.Callback)
                elseif not SideQuestUI.Store.accepted and d and #(d.ActiveSideQuests or {}) < 3 and SideQuestUI.Store.accept and type(SideQuestUI.Store.accept.Callback) == "function" then
                    pcall(SideQuestUI.Store.accept.Callback)
                end
                task.wait(0.15)
                SideQuestUI.Store.visible = false
            end
        elseif cmd == "ClaimSeasonPassSafe" then
            if SeasonPassUI and SeasonPassUI.unclaimedRewardExists == true then
                pcall(function()
                    if SeasonPassUI.claimAllButton and type(SeasonPassUI.claimAllButton.Callback) == "function" then
                        SeasonPassUI.claimAllButton.Callback()
                    else
                        Remote:WaitForChild("SeasonPass"):FireServer("claimAll")
                    end
                end)
            end
        elseif cmd == "ClaimAchievement" then
            GlobalPkt.ClaimAchievement.send(tonumber(a1))
        elseif cmd == "ClaimAllAchievements" then
            local pData = getReplicas()
            if pData and pData.Data then
                local Ach = require(Storage:WaitForChild("Achievements"))
                local list = Ach:GetList()
                local unlocked = pData.Data.UnlockedAchievements or {}
                local claimed = pData.Data.AchievementsClaimed or {}
                local nowClock = os.clock()
                local sentCount = 0
                for i, _ in ipairs(list) do
                    if sentCount >= 3 then break end
                    if i >= 1 and i <= 127 and (nowClock - (achClaimedSent[i] or 0) >= 120) then
                        local val = Ach:GetValue(i)
                        if val and val.Name and not val.Hidden and table.find(unlocked, val.Name) and not claimed[val.Name] and val.Rewards and next(val.Rewards) then
                            achClaimedSent[i] = nowClock
                            sentCount += 1
                            GlobalPkt.ClaimAchievement.send(i)
                            task.wait(0.45)
                        end
                    end
                end
            end
        elseif cmd == "DailyShopPurchase" then
            MerchantPkt.DailyShopPurchase.send({ index = tonumber(a1), method = tostring(a2 or "Coin") })
        elseif cmd == "DailyShopDiscover" then
            MerchantPkt.DiscoverProduct.send(tonumber(a1))
        elseif cmd == "RedeemCode" then
            GlobalPkt.RedeemCode.send(tostring(a1))
        elseif cmd == "ModifySetting" then
            GlobalPkt.ModifySetting.send({ Key = tostring(a1), Value = a2 })
        elseif cmd == "FishingStart" then
            FishingPkt.start.send(tostring(a1))
        elseif cmd == "FishingStartNet" then
            FishingPkt.startNet.send(tostring(a1))
        elseif cmd == "FishingQuit" then
            FishingPkt.quit.send()
        elseif cmd == "FishingUpgrade" then
            FishingPkt.upgrade.send(true)
        elseif cmd == "FishingBuy" then
            FishingPkt.purchaseItem.send({ id = tostring(a1), amount = tonumber(a2) or 1 })
        elseif cmd == "SellFilteredFish" then
            local pData = getReplicas()
            if pData and pData.Data and pData.Data.FishInventory and FishStore then
                local tierMap = a1 or {}
                local includeMutant = a2 == true
                for uid, fish in pairs(pData.Data.FishInventory) do
                    if type(fish) == "table" and fish.id then
                        local info = FishStore.getFishInfo(fish.id)
                        local tier = info and info.tier or "common"
                        if tierMap[tier] and (includeMutant or not fish.isMutant) then
                            if FishShopUI then
                                FishShopUI.Store.SelectedFishUID = uid
                            end
                            FishingPkt.sellFish.send(uid)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
    end))

    -- Periodic Telemetry Loop
    task.spawn(function()
        while alive do
            local pData, sInfo = getReplicas()
            if pData and pData.Data then
                local d = pData.Data
                local invSummary = {}
                for k, v in pairs(d.Inventory or {}) do
                    if type(v) == "table" and (v.Amount or 0) > 0 then
                        invSummary[k] = v.Amount
                    end
                end

                local buffSummary = {}
                if BuffsMod and BuffsMod.GetStates and BuffsMod.IsReady and BuffsMod:IsReady() then
                    local ok, states = pcall(function() return BuffsMod:GetStates() end)
                    if ok and type(states) == "table" then
                        for bName, bState in pairs(states) do
                            if isBuffActive(bName, 2) then
                                local okR, rem = pcall(function() return BuffsMod:GetRemainingTime(bName) end)
                                buffSummary[tostring(bName)] = {
                                    stack = bState.Stack or 1,
                                    remaining = (okR and type(rem) == "number") and rem or 0,
                                }
                            end
                        end
                    end
                end

                if (cfg.autoRoll or cfg.autoRespond) and (os.clock() - lastPendingResolve > 0.8) then
                    local btns = RollUI and RollUI.Buttons
                    local uiPending = btns and ((btns.Equip and btns.Equip.Visible) or (btns.Skip and btns.Skip.Visible))
                    local dataPending = (d.IsPendingResolved == false and tostring(d.PendingAura or "") ~= "")
                    if uiPending or dataPending then
                        lastPendingResolve = os.clock()
                        resolveRollCleanly(tostring(d.PendingAura or "Common"), 0)
                    end
                end

                local merchants = {}
                if MerchantUIBeta and MerchantUIBeta.store and type(MerchantUIBeta.store.merchant_infos) == "table" then
                    for mid, minfo in pairs(MerchantUIBeta.store.merchant_infos) do
                        if type(minfo) == "table" and minfo.model and minfo.model:IsDescendantOf(workspace) then
                            local pos = minfo.model:GetPivot().Position
                            merchants[tostring(mid)] = {
                                id = tostring(mid),
                                name = tostring(minfo.merchant_name or mid),
                                posX = pos.X, posY = pos.Y, posZ = pos.Z,
                                products = minfo.product_list or {},
                            }
                        end
                    end
                end

                local fishCount = 0
                for _ in pairs(d.FishInventory or {}) do fishCount += 1 end

                local luckAttr = LocalPlayer:FindFirstChild("Luck")
                local luckVal = luckAttr and luckAttr:IsA("ValueBase") and luckAttr.Value or 1
                local hpObj = LocalPlayer:FindFirstChild("HollowPoints")
                local hpVal = hpObj and hpObj:IsA("ValueBase") and hpObj.Value or 0

                if pendingResponse and (os.clock() - pendingSince > 4) then
                    pendingResponse = false
                end

                evtCh:Fire(sessionId, "Snapshot", {
                    Biome = sInfo and sInfo.Data and sInfo.Data.BiomeName or "Normal",
                    Time = sInfo and sInfo.Data and sInfo.Data.Time or "Day",
                    Luck = luckVal,
                    Rolls = d.roll or 0,
                    Coins = d.Coins or 0,
                    DarkCoins = d.DarkCoins or 0,
                    HollowPoints = hpVal,
                    FishCoins = d.FishCoins or 0,
                    Bank = d.Bank or 0,
                    BankCapacity = d.BankCapacity or 100000,
                    BankEnabled = d.BankEnabled == true,
                    NextRollable = nextRollable,
                    RollDelay = rollDelay,
                    PendingResponse = pendingResponse,
                    PendingAura = d.PendingAura or "",
                    IsPendingResolved = d.IsPendingResolved ~= false,
                    AuraCount = #(d.InventoryAuras or {}),
                    MaxStorableAuras = d.MaxStorableAuras or 20,
                    FishCount = fishCount,
                    FishInventorySize = d.FishInventorySize or 20,
                    SeasonLevel = d.SeasonLevel or 0,
                    Inventory = invSummary,
                    Buffs = buffSummary,
                    Merchants = merchants,
                    QuestProgress = d.QuestProgress or {},
                    ClaimedQuests = d.ClaimedQuests or {},
                    ActiveSideQuests = d.ActiveSideQuests or {},
                    SideQuests = d.BoardQuests or {},
                    FishUI_isFishing = FishUI and FishUI.isFishing or false,
                    FishUI_isMinigameMode = FishUI and FishUI.isMinigameMode or false,
                    FishUI_isResultMode = FishUI and FishUI.isResultMode or false,
                    LastMemoryMatchPlayed = d.LastMemoryMatchPlayed or 0,
                    UnclaimedSeasonPass = (SeasonPassUI and SeasonPassUI.unclaimedRewardExists == true) or false,
                    MemoryMatchActive = (MemoryMatchUI and MemoryMatchUI.mainWindow and MemoryMatchUI.mainWindow.Visible == true and MemoryMatchUI.bannerOpened == true) or false,
                })
            end
            task.wait(0.35)
        end
    end)
]===]

local clientActor = ReplicatedFirst:WaitForChild("ClientHandlers")
run_on_actor(clientActor, ActorBridgeSource, cmdId, evtId, SESSION_ID)

-- ============================================================================
-- HELPER UTILITIES (MOVEMENT, TELEPORT, INTERACT, ESP)
-- ============================================================================
local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function SafeTeleport(cfOrPos)
    local hrp = GetHRP()
    if not hrp then return false end
    local targetCF = typeof(cfOrPos) == "CFrame" and cfOrPos or CFrame.new(cfOrPos)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = targetCF
    return true
end

local function GetPromptPosition(prompt)
    local parent = prompt and prompt.Parent
    if not parent then return nil end
    if parent:IsA("Attachment") then
        return parent.WorldPosition
    elseif parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Model") then
        return parent:GetPivot().Position
    end
    return nil
end

local function SetCharCollision(char, enabled)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = enabled
        end
    end
end

local function IsNearTarget(hrpPos, targetPos)
    if (hrpPos - targetPos).Magnitude <= 7.5 then return true end
    local flat = (Vector3.new(hrpPos.X, 0, hrpPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
    return flat <= 5.5 and math.abs(hrpPos.Y - targetPos.Y) <= 9.0
end

local function ForceJump(hum)
    if not hum then return end
    hum.Jump = true
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
end

local function NativePathMoveTo(targetPos, watchObj)
    local hrp = GetHRP()
    local hum = GetHumanoid()
    if not hrp or not hum then return false end
    if IsNearTarget(hrp.Position, targetPos) then
        return true
    end

    local spd = math.max(12, hum.WalkSpeed)
    local maxTotalTime = math.clamp((hrp.Position - targetPos).Magnitude / spd * 3.0 + 6, 12, 55)
    local totalStart = os.clock()

    for attempt = 1, 4 do
        if not Runtime.Alive or (os.clock() - totalStart > maxTotalTime) then break end
        if watchObj and not watchObj:IsDescendantOf(workspace) then break end
        hrp = GetHRP()
        hum = GetHumanoid()
        if not hrp or not hum then break end
        if IsNearTarget(hrp.Position, targetPos) then break end

        -- On retry after an obstacle snag, sidestep perpendicular + jump to clear corner
        if attempt > 1 then
            local toTgt = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
            if toTgt.Magnitude > 0.5 then
                local u = toTgt.Unit
                local side = Vector3.new(-u.Z, 0, u.X) * ((attempt % 2 == 0) and 6 or -6)
                ForceJump(hum)
                hum:MoveTo(hrp.Position + side)
                task.wait(0.45)
            end
        end

        hrp = GetHRP()
        if not hrp then break end
        local path = PathfindingService:CreatePath({
            AgentRadius = (attempt <= 2) and 3.0 or 2.0,
            AgentHeight = 5.5,
            AgentCanJump = true,
            WaypointSpacing = 5,
        })
        local okPath = pcall(function()
            path:ComputeAsync(hrp.Position, targetPos)
        end)
        if not okPath or path.Status ~= Enum.PathStatus.Success then
            okPath = pcall(function()
                path:ComputeAsync(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
            end)
        end

        if okPath and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            local lastProgPos = hrp.Position
            local lastProgClock = os.clock()
            local stalled = false

            for idx = 2, #waypoints do
                if not Runtime.Alive or stalled or (os.clock() - totalStart > maxTotalTime) then break end
                if watchObj and not watchObj:IsDescendantOf(workspace) then break end
                hrp = GetHRP()
                hum = GetHumanoid()
                if not hrp or not hum then break end
                if IsNearTarget(hrp.Position, targetPos) then break end

                local wp = waypoints[idx]
                if wp.Action == Enum.PathWaypointAction.Jump then
                    ForceJump(hum)
                end
                hum:MoveTo(wp.Position)

                local wt = os.clock()
                while Runtime.Alive and os.clock() - wt < 1.6 do
                    if watchObj and not watchObj:IsDescendantOf(workspace) then
                        stalled = true
                        break
                    end
                    hrp = GetHRP()
                    hum = GetHumanoid()
                    if not hrp or not hum then
                        stalled = true
                        break
                    end
                    if (hrp.Position - lastProgPos).Magnitude >= 1.4 then
                        lastProgPos = hrp.Position
                        lastProgClock = os.clock()
                    elseif os.clock() - lastProgClock > 0.65 then
                        ForceJump(hum)
                    end
                    if os.clock() - lastProgClock > 1.6 then
                        stalled = true
                        break
                    end
                    local flatDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(wp.Position.X, 0, wp.Position.Z)).Magnitude
                    if flatDist <= 4.0 or IsNearTarget(hrp.Position, targetPos) then
                        break
                    end
                    task.wait(0.05)
                end
            end
        else
            -- Direct walk fallback for short ledges
            hum:MoveTo(targetPos)
            ForceJump(hum)
            task.wait(1.0)
        end
    end

    hrp = GetHRP()
    hum = GetHumanoid()
    local targetGone = watchObj and not watchObj:IsDescendantOf(workspace)
    if Runtime.Alive and not targetGone and hrp and hum and not IsNearTarget(hrp.Position, targetPos) then
        if (hrp.Position - targetPos).Magnitude <= 30 then
            hum:MoveTo(targetPos)
            local ft = os.clock()
            while Runtime.Alive and os.clock() - ft < 3.0 do
                if watchObj and not watchObj:IsDescendantOf(workspace) then break end
                hrp = GetHRP()
                if not hrp or IsNearTarget(hrp.Position, targetPos) then break end
                task.wait(0.05)
            end
        end
    end

    hrp = GetHRP()
    hum = GetHumanoid()
    if hum and hrp then
        pcall(function() hum:MoveTo(hrp.Position) end)
    end
    task.wait(0.2)
    hrp = GetHRP()
    return hrp ~= nil and ((hrp.Position - targetPos).Magnitude <= 9.0 or IsNearTarget(hrp.Position, targetPos))
end

local function SafeGlideTo(cfOrPos)
    if not Runtime.Alive then return false end
    local waitLock = 0
    while Runtime.Moving and Runtime.Alive and waitLock < 100 do
        waitLock += 1
        task.wait(0.05)
    end
    if not Runtime.Alive then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    Runtime.Moving = true

    local targetPos = typeof(cfOrPos) == "CFrame" and cfOrPos.Position or cfOrPos
    local reached = false
    pcall(function()
        local curX = hrp.Position.X
        local tgtX = targetPos.X

        -- Limbo requires entrance quest/dialogue on Main Island
        if tgtX < -8000 and curX > -2000 then
            local limboEntry = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Miscs") and workspace.Map.Miscs:FindFirstChild("LimboEntry")
            local entryPart = limboEntry and limboEntry:FindFirstChild("LimboEntry")
            if entryPart then
                NativePathMoveTo(entryPart.Position + Vector3.new(0, 2, 0), nil)
            end
            WindUI:Notify({ Title = "Limbo Portal", Content = "Walked to Limbo Entrance Portal (complete entry puzzle to enter).", Duration = 4, Icon = "map-pin" })
            reached = true
            return
        end

        -- Route Main Island -> Stella's Cave via CaveTeleporter / Portal
        if curX > -2000 and tgtX < -3000 and tgtX > -6000 then
            local miscs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Miscs")
            local telePart = miscs and miscs:FindFirstChild("CaveTeleporter")
            if telePart then
                NativePathMoveTo(telePart.Position + Vector3.new(0, 1, 0), nil)
                hrp = GetHRP()
                if hrp then
                    pcall(function()
                        firetouchinterest(hrp, telePart, 0)
                        task.wait(0.25)
                        firetouchinterest(hrp, telePart, 1)
                    end)
                end
                local wt = os.clock()
                while Runtime.Alive and os.clock() - wt < 2.5 do
                    hrp = GetHRP()
                    if hrp and hrp.Position.X < -3000 then break end
                    task.wait(0.1)
                end
            end
        -- Route Stella's Cave -> Main Island via Exit Portal
        elseif curX < -3000 and curX > -6000 and tgtX > -2000 then
            local miscs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Miscs")
            local exitPortal = nil
            if miscs then
                for _, c in ipairs(miscs:GetChildren()) do
                    if c.Name == "Portal" and c:IsA("Model") and c:GetPivot().Position.X < -3000 then
                        exitPortal = c
                        break
                    end
                end
            end
            if exitPortal then
                local touchPart = exitPortal:FindFirstChild("SoundPart") or exitPortal.PrimaryPart or exitPortal:FindFirstChildWhichIsA("BasePart")
                local pPos = exitPortal:GetPivot().Position
                NativePathMoveTo(pPos + Vector3.new(0, 1, 0), nil)
                hrp = GetHRP()
                if touchPart and hrp then
                    pcall(function()
                        firetouchinterest(hrp, touchPart, 0)
                        task.wait(0.25)
                        firetouchinterest(hrp, touchPart, 1)
                    end)
                end
                local wt = os.clock()
                while Runtime.Alive and os.clock() - wt < 2.5 do
                    hrp = GetHRP()
                    if hrp and hrp.Position.X > -2000 then break end
                    task.wait(0.1)
                end
            end
        end

        hrp = GetHRP()
        if hrp and math.abs(hrp.Position.X - targetPos.X) < 2500 then
            reached = NativePathMoveTo(targetPos, nil)
        end
    end)

    Runtime.Moving = false
    return reached
end

local function GetWorldPickups()
    local items = {}
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, child in ipairs(map:GetChildren()) do
            local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                local act = tostring(prompt.ActionText):lower()
                if act == "pick up" or act == "collect" or act:find("pick") then
                    local pos = GetPromptPosition(prompt) or (child:IsA("BasePart") and child.Position or child:GetPivot().Position)
                    local kind = "World Item"
                    if child:FindFirstChild("Coin") then
                        kind = "Coin"
                    elseif child:FindFirstChild("Liquid") or child:FindFirstChild("Casing") then
                        kind = "Potion"
                    end
                    table.insert(items, { obj = child, prompt = prompt, pos = pos, kind = kind })
                end
            end
        end
    end
    local uidKey = tostring(LocalPlayer.UserId)
    local serverNow = workspace:GetServerTimeNow()
    for _, drop in ipairs(CollectionService:GetTagged("DropItem")) do
        if drop:IsDescendantOf(workspace) and not drop:GetAttribute(uidKey) then
            local part = drop:FindFirstChild("Part")
            local prompt = part and part:FindFirstChildOfClass("ProximityPrompt")
            local stTime = drop:GetAttribute("startTime") or 0
            local dur = drop:GetAttribute("duration") or 1
            if part and prompt and prompt.Enabled and (serverNow - stTime >= dur) then
                table.insert(items, { obj = drop, prompt = prompt, pos = part.Position, kind = "DropItem" })
            end
        end
    end
    return items
end

local function WalkToTarget(targetPos, watchObj)
    if not watchObj then
        return SafeGlideTo(targetPos)
    end
    if not Runtime.Alive then return false end
    local waitLock = 0
    while Runtime.Moving and Runtime.Alive and waitLock < 100 do
        waitLock += 1
        task.wait(0.05)
    end
    if not Runtime.Alive then return false end
    Runtime.Moving = true
    local ok = false
    pcall(function()
        ok = NativePathMoveTo(targetPos, watchObj)
    end)
    Runtime.Moving = false
    return ok
end

local function TriggerPromptAt(prompt, pos, useWalk, watchObj)
    if not prompt or not prompt:IsDescendantOf(workspace) then return false end
    if pos then
        WalkToTarget(pos, watchObj)
    end
    local hrpNow = GetHRP()
    if not prompt:IsDescendantOf(workspace) or not prompt.Enabled then return false end
    if pos and (not hrpNow or ((hrpNow.Position - pos).Magnitude > 10.5 and not IsNearTarget(hrpNow.Position, pos))) then return false end

    local arrivedDist = (hrpNow and pos) and (math.floor((hrpNow.Position - pos).Magnitude * 10) / 10) or -1
    local diag = { arrivedDist = arrivedDist, ppGuiCount = 0, despawned = false, tier = 0 }
    Runtime.LastPickupAttempt = diag

    local cam = workspace.CurrentCamera
    local oldCamType = cam and cam.CameraType
    local oldCamCF = cam and cam.CFrame
    local ppGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ProximityPrompts")

    pcall(function()
        if cam and pos then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.lookAt(pos + Vector3.new(0, 3.5, 5.5), pos)
        end
        local tWait = os.clock()
        while Runtime.Alive and os.clock() - tWait < 0.5 do
            if cam and pos then
                cam.CFrame = CFrame.lookAt(pos + Vector3.new(0, 3.5, 5.5), pos)
            end
            if ppGui and #ppGui:GetChildren() > 0 and (os.clock() - tWait) >= 0.2 then
                break
            end
            task.wait(0.05)
        end
        diag.ppGuiCount = ppGui and #ppGui:GetChildren() or 0

        if not prompt:IsDescendantOf(workspace) or not prompt.Enabled then
            diag.despawned = true
            return
        end
        local holdWait = math.max(0.12, (prompt.HoldDuration or 0) + 0.06)

        -- Attempt 1: Native CoreScript ProximityPrompt TextButton signal
        local btn = ppGui and ppGui:FindFirstChildWhichIsA("TextButton", true)
        if btn and replicatesignal then
            diag.tier = 1
            pcall(function()
                replicatesignal(btn.MouseButton1Down)
                task.wait(holdWait)
                replicatesignal(btn.MouseButton1Up)
                replicatesignal(btn.Activated)
            end)
            task.wait(0.22)
        end

        -- Attempt 2: Executor fireproximityprompt
        if prompt:IsDescendantOf(workspace) and prompt.Enabled then
            diag.tier = 2
            pcall(function() fireproximityprompt(prompt) end)
            task.wait(0.22)
        end

        -- Attempt 3: Direct ProximityPrompt InputHoldBegin/End
        if prompt:IsDescendantOf(workspace) and prompt.Enabled then
            diag.tier = 3
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(holdWait)
                prompt:InputHoldEnd()
            end)
            task.wait(0.22)
        end

        -- Attempt 4: VirtualInputManager KeyCode fallback
        if prompt:IsDescendantOf(workspace) and prompt.Enabled and not UserInputService:GetFocusedTextBox() then
            diag.tier = 4
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                local kc = prompt.KeyboardKeyCode or Enum.KeyCode.E
                vim:SendKeyEvent(true, kc, false, game)
                task.wait(holdWait)
                vim:SendKeyEvent(false, kc, false, game)
            end)
            task.wait(0.22)
        end

        diag.despawned = (not prompt:IsDescendantOf(workspace)) or (not prompt.Enabled)
    end)

    if cam then
        pcall(function()
            cam.CameraType = oldCamType or Enum.CameraType.Custom
            if oldCamCF then cam.CFrame = oldCamCF end
        end)
    end
    return true
end

local function InteractPrompt(prompt, returnHome)
    if not prompt or not prompt:IsDescendantOf(workspace) then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    local savedCF = hrp.CFrame
    TriggerPromptAt(prompt, GetPromptPosition(prompt))
    task.wait(0.15)
    if returnHome and savedCF then
        SafeGlideTo(savedCF)
    end
    return true
end

local function InvokeWithTimeout(timeoutSec, fn)
    local done = false
    local ok, r1, r2 = false, nil, "Timed out"
    local co = task.spawn(function()
        local s, a, b = pcall(fn)
        ok, r1, r2 = s, a, b
        done = true
    end)
    local t0 = os.clock()
    while not done and (os.clock() - t0) < (timeoutSec or 2.5) do
        task.wait(0.05)
    end
    if not done then
        pcall(task.cancel, co)
        return false, false, "Open Workshop NPC once first (Timed out)"
    end
    return ok, r1, r2
end

local function WithWorkshopProximity(ns, fn)
    local hrp = GetHRP()
    local savedCF = hrp and hrp.CFrame
    local moved = false
    local targetObj, fallbackPos

    if ns == "StellaCauldron" then
        targetObj = workspace:FindFirstChild("Cauldron")
        fallbackPos = Vector3.new(-4648.3, 145.0, -228.7)
    else
        local map = workspace:FindFirstChild("Map")
        local shop = map and map:FindFirstChild("SHOP")
        targetObj = shop and shop:FindFirstChild("Jake")
        fallbackPos = Vector3.new(344.5, 99.5, -331.0)
    end

    if hrp then
        local targetPos = fallbackPos
        if targetObj then
            local base = targetObj:IsA("BasePart") and targetObj.Position or targetObj:GetPivot().Position
            targetPos = base + Vector3.new(0, ns == "StellaCauldron" and 2 or 1.5, ns == "StellaCauldron" and 3 or 2)
        end
        if (hrp.Position - targetPos).Magnitude > 12 then
            moved = true
            SafeGlideTo(CFrame.new(targetPos))
            task.wait(0.4)
        end
    end

    local ok, r1, r2 = InvokeWithTimeout(2.5, fn)
    task.wait(0.1)

    if moved and savedCF then
        SafeGlideTo(savedCF)
    end
    return ok, r1, r2
end

local suppressSync = false
local function SyncActorConfig()
    if suppressSync then return end
    local wl = {}
    for _, v in ipairs(State.AuraWhitelist or {}) do wl[v] = true end
    local bl = {}
    for _, v in ipairs(State.AuraBlacklist or {}) do bl[v] = true end
    local st = {}
    for _, v in ipairs(State.SellFishTiers or {}) do st[v] = true end
    SendActorCmd("Config", {
        autoRoll = State.AutoRoll,
        instantRoll = State.InstantRoll,
        autoRespond = State.AutoRespondRoll,
        minKeepRarity = tonumber(State.MinKeepRarity) or 10000,
        keepUndiscovered = State.KeepUndiscovered,
        keepCraftingAuras = State.KeepCraftingAuras,
        autoLockRare = State.AutoLockRare,
        autoLockRarity = tonumber(State.AutoLockRarity) or 100000,
        whitelist = wl,
        blacklist = bl,
        craftingAuras = State.CraftingRequiredAuras,
        autoFishPerfect = State.AutoMinigamePerfect or State.AutoRodFish,
        autoSellFish = State.AutoSellFish,
        sellTiers = st,
        sellMutant = State.SellMutantFish,
    })
end

local function FormatNum(n)
    n = tonumber(n) or 0
    local formatted = tostring(math.floor(n))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

-- ============================================================================
-- LOAD WINDUI & BUILD INTERFACE (By XLunaHUB)
-- ============================================================================
local windSrc = genv.__XLuna_WindUISrc
if type(windSrc) ~= "string" or #windSrc < 1000 then
    windSrc = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    genv.__XLuna_WindUISrc = windSrc
end
local WindUI = loadstring(windSrc)()

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB | Sol's RNG",
    Icon = "sparkles",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_SolsRNG",
    Size = UDim2.fromOffset(630, 490),
    MinSize = Vector2.new(540, 380),
    MaxSize = Vector2.new(860, 620),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 185,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    ToggleKey = nil, -- Disabled so our single debounced LeftControl handler owns Show/Hide exclusively
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "sparkles",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

Runtime.Window = Window

pcall(function()
    Window:SetToggleKey(nil)
    Window:EditOpenButton({
        Title = "XLunaHUB",
        Icon = "sparkles",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    })
end)

-- Mutual-Exclusive Single-Owner LeftControl Show / Hide Controller
local isWindowOpen = true
local toggleLock = false

Window:OnOpen(function()
    isWindowOpen = true
    if Window.OpenButtonMain then
        pcall(function() Window.OpenButtonMain:Visible(false) end)
    end
end)

Window:OnClose(function()
    isWindowOpen = false
    task.delay(0.42, function()
        if not Runtime.Alive or isWindowOpen then return end
        if Window.OpenButtonMain then
            pcall(function() Window.OpenButtonMain:Visible(true) end)
        end
    end)
end)

TrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not Runtime.Alive then return end
    if gameProcessed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if toggleLock then return end
        toggleLock = true
        if isWindowOpen then
            isWindowOpen = false
            Window:Close()
        else
            isWindowOpen = true
            Window:Open()
        end
        task.delay(0.5, function()
            toggleLock = false
        end)
    end
end))

local function SetPara(para, title, desc)
    if not para then return end
    local target = (para.SetDesc and para) or para.ParagraphFrame
    if not target then return end
    if title and target.SetTitle then pcall(function() target:SetTitle(title) end) end
    if desc and target.SetDesc then pcall(function() target:SetDesc(desc) end) end
end

-- Helper to create toggles guaranteed OFF at startup
local function Notify(title, content, duration, icon)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 4,
            Icon = icon or "sparkles",
        })
    end)
end

-- ============================================================================
-- TABS CREATION
-- ============================================================================
local TabDashboard = Window:Tab({ Title = "Dashboard", Icon = "activity" })
local TabRoll      = Window:Tab({ Title = "Rolling & Auras", Icon = "sparkles" })
local TabFarm      = Window:Tab({ Title = "World & Buffs", Icon = "zap" })
local TabCraft     = Window:Tab({ Title = "Auto Crafting", Icon = "hammer" })
local TabFishing   = Window:Tab({ Title = "Fishing", Icon = "anchor" })
local TabEvents    = Window:Tab({ Title = "Quests & Events", Icon = "trophy" })
local TabMerchants = Window:Tab({ Title = "Merchants & Bank", Icon = "shopping-bag" })
local TabTeleport  = Window:Tab({ Title = "Teleport & Player", Icon = "map-pin" })
local TabConfig    = Window:Tab({ Title = "Config", Icon = "settings" })

-- ----------------------------------------------------------------------------
-- TAB 1: DASHBOARD & BIOME SNIPER
-- ----------------------------------------------------------------------------
TabDashboard:Section({ Title = "Live Account & World Telemetry", Opened = true })

local LiveStatsPara = TabDashboard:Paragraph({
    Title = "Sol's RNG Live Status",
    Desc = "Connecting to Actor Bridge...",
})

local SessionPara = TabDashboard:Paragraph({
    Title = "Session Roll Telemetry",
    Desc = "Rolls: 0 | Rare Kept: 0 | Last Aura: None",
})

TabDashboard:Section({ Title = "Biome & Merchant Alerts", Opened = true })

TabDashboard:Toggle({
    Title = "Rare Biome Sniper Alerts",
    Desc = "Pop high-priority alerts when a target biome spawns on the server",
    Flag = "BiomeSniperAlerts",
    Value = false,
    Callback = function(v) State.BiomeSniperAlerts = v end,
})

TabDashboard:Dropdown({
    Title = "Target Sniper Biomes",
    Values = KnownBiomes,
    Value = State.TargetSniperBiomes,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "TargetSniperBiomes",
    Callback = function(v) State.TargetSniperBiomes = v end,
})

TabDashboard:Toggle({
    Title = "Traveling Merchant Alerts",
    Desc = "Notify immediately when Mari or Jester spawns in the world",
    Flag = "MerchantAlerts",
    Value = false,
    Callback = function(v) State.MerchantAlerts = v end,
})

-- ----------------------------------------------------------------------------
-- TAB 2: ROLLING & SMART AURA ENGINE
-- ----------------------------------------------------------------------------
TabRoll:Section({ Title = "Group-Bypass Auto Rolling", Opened = true })

TabRoll:Toggle({
    Title = "Auto Roll (No Group Required)",
    Desc = "Replicates RollButton clicks synced to server NextRollable cooldown",
    Flag = "AutoRoll",
    Value = false,
    Callback = function(v)
        State.AutoRoll = v
        SyncActorConfig()
    end,
})

TabRoll:Toggle({
    Title = "Instant Roll (Skip Spin Animation)",
    Desc = "Bypasses client roll animation & clears background dim overlay",
    Flag = "InstantRoll",
    Value = false,
    Callback = function(v)
        State.InstantRoll = v
        if v then
            LocalPlayer:SetAttribute("QuickRollEnabled", true)
            Runtime.ModifiedQuickRoll = true
        elseif Runtime.ModifiedQuickRoll then
            LocalPlayer:SetAttribute("QuickRollEnabled", Runtime.OrigQuickRoll)
            Runtime.ModifiedQuickRoll = false
        end
        SyncActorConfig()
    end,
})

TabRoll:Slider({
    Title = "Roll Cooldown Buffer (s)",
    Value = { Min = 0, Max = 0.5, Default = 0.05 },
    Step = 0.01,
    Flag = "RollDelayBuffer",
    Callback = function(v) State.RollDelayBuffer = v end,
})

TabRoll:Button({
    Title = "Roll Once Now",
    Desc = "Trigger a single replicated Roll click",
    Callback = function()
        local bf = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainInterface")
        bf = bf and bf:FindFirstChild("BottomFrame")
        local rb = bf and bf:FindFirstChild("RollButton")
        if rb then
            replicatesignal(rb.MouseButton1Click)
        end
    end,
})

TabRoll:Section({ Title = "Smart Aura Filter & Storage", Opened = true })

TabRoll:Toggle({
    Title = "Auto Respond Roll Results (Equip / Delete)",
    Desc = "Automatically keeps or deletes rolled auras using your rules below",
    Flag = "AutoRespondRoll",
    Value = false,
    Callback = function(v)
        State.AutoRespondRoll = v
        SyncActorConfig()
    end,
})

TabRoll:Input({
    Title = "Min Rarity to Keep",
    Desc = "Auras with rarity >= this number are kept (e.g. 10000)",
    Placeholder = "10000",
    Value = "10000",
    Flag = "MinKeepRarity",
    Callback = function(v)
        State.MinKeepRarity = tonumber(v) or 10000
        SyncActorConfig()
    end,
})

TabRoll:Toggle({
    Title = "Always Keep Undiscovered Auras",
    Desc = "Never deletes an aura missing from your Collection",
    Flag = "KeepUndiscovered",
    Value = false,
    Callback = function(v)
        State.KeepUndiscovered = v
        SyncActorConfig()
    end,
})

TabRoll:Toggle({
    Title = "Always Keep Crafting Ingredient Auras",
    Desc = "Keeps any aura required by loaded Jake/Stella recipes",
    Flag = "KeepCraftingAuras",
    Value = false,
    Callback = function(v)
        State.KeepCraftingAuras = v
        SyncActorConfig()
    end,
})

TabRoll:Dropdown({
    Title = "Aura Whitelist (Always Keep)",
    Values = #AuraList > 0 and AuraList or { "Common", "Uncommon" },
    Value = {},
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "AuraWhitelist",
    Callback = function(v)
        State.AuraWhitelist = v
        SyncActorConfig()
    end,
})
task.wait()

TabRoll:Dropdown({
    Title = "Aura Blacklist (Always Delete)",
    Values = #AuraList > 0 and AuraList or { "Common", "Uncommon" },
    Value = {},
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "AuraBlacklist",
    Callback = function(v)
        State.AuraBlacklist = v
        SyncActorConfig()
    end,
})
task.wait()

TabRoll:Toggle({
    Title = "Auto Lock Rare Stored Auras",
    Desc = "Automatically locks newly stored auras above Lock Threshold",
    Flag = "AutoLockRare",
    Value = false,
    Callback = function(v)
        State.AutoLockRare = v
        SyncActorConfig()
    end,
})

TabRoll:Input({
    Title = "Auto Lock Rarity Threshold",
    Placeholder = "100000",
    Value = "100000",
    Flag = "AutoLockRarity",
    Callback = function(v)
        State.AutoLockRarity = tonumber(v) or 100000
        SyncActorConfig()
    end,
})

TabRoll:Toggle({
    Title = "Auto Upgrade Aura Storage",
    Desc = "Automatically expands aura storage slots when you have enough Coins",
    Flag = "AutoUpgradeStorage",
    Value = false,
    Callback = function(v) State.AutoUpgradeStorage = v end,
})

-- ----------------------------------------------------------------------------
-- TAB 3: WORLD FARM, BLESSINGS & POTIONS
-- ----------------------------------------------------------------------------
TabFarm:Section({ Title = "World Drop & Blessing Automation", Opened = true })

TabFarm:Toggle({
    Title = "Auto Collect World Drops",
    Desc = "Smoothly glides to world Potions, Coins, and DropItems, picks up, and returns",
    Flag = "AutoCollectDrops",
    Value = false,
    Callback = function(v) State.AutoCollectDrops = v end,
})

TabFarm:Toggle({
    Title = "Auto Stand in Area Buff Givers",
    Desc = "Glides to active Map.AreaGivers buffs until they despawn",
    Flag = "AutoAreaBuffs",
    Value = false,
    Callback = function(v) State.AutoAreaBuffs = v end,
})

TabFarm:Button({
    Title = "Teleport Near Obby Entrance",
    Desc = "Glides safely to the obby start to clear Basic Blessing manually",
    Callback = function()
        TrackSpawn(function()
            SafeGlideTo(CFrame.new(108, 99, -545))
            Notify("Obby", "Glided near Obby entrance.", 3, "zap")
        end)
    end,
})

TabFarm:Section({ Title = "Smart Potion & Chest Automation", Opened = true })

TabFarm:Toggle({
    Title = "Auto Use Selected Potions",
    Desc = "Automatically drinks selected potions from inventory when not active",
    Flag = "AutoUsePotions",
    Value = false,
    Callback = function(v) State.AutoUsePotions = v end,
})

TabFarm:Toggle({
    Title = "Only Use Potions in Target Biomes",
    Desc = "Saves potions until the server is in one of your Potion Target Biomes",
    Flag = "PotionOnlyTargetBiome",
    Value = false,
    Callback = function(v) State.PotionOnlyTargetBiome = v end,
})

TabFarm:Dropdown({
    Title = "Selected Potions",
    Values = #PotionList > 0 and PotionList or { "Lucky Potion", "Speed Potion", "Fortune Potion I" },
    Value = State.SelectedPotions,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "SelectedPotions",
    Callback = function(v) State.SelectedPotions = v end,
})

TabFarm:Dropdown({
    Title = "Potion Target Biomes",
    Values = KnownBiomes,
    Value = State.PotionBiomes,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "PotionBiomes",
    Callback = function(v) State.PotionBiomes = v end,
})

TabFarm:Toggle({
    Title = "Auto Open Chests / Boxes",
    Desc = "Automatically opens selected chests/boxes in inventory",
    Flag = "AutoOpenChests",
    Value = false,
    Callback = function(v) State.AutoOpenChests = v end,
})

TabFarm:Dropdown({
    Title = "Chests / Boxes to Open",
    Values = #ChestList > 0 and ChestList or { "Potion Chest", "Rare Potion Chest", "Mega Potion Chest" },
    Value = State.SelectedChests,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "SelectedChests",
    Callback = function(v) State.SelectedChests = v end,
})

TabFarm:Section({ Title = "Biome Selector / Randomizer", Opened = true })

TabFarm:Dropdown({
    Title = "Target Biome (Biome Selector)",
    Values = KnownBiomes,
    Value = "Glitched",
    SearchBarEnabled = true,
    Flag = "TargetSelectorBiome",
    Callback = function(v) State.TargetSelectorBiome = v end,
})

local AutoBiomeSelectorToggle = TabFarm:Toggle({
    Title = "Auto Trigger Biome Selector",
    Desc = "Uses BiomeSelectorHandler when you own a Selector/Randomizer until target biome spawns",
    Flag = "AutoBiomeSelector",
    Value = false,
    Callback = function(v) State.AutoBiomeSelector = v end,
})

TabFarm:Button({
    Title = "Invoke Biome Selector Now",
    Callback = function()
        local ok, res, msg = pcall(function()
            return ReplicatedStorage.Remote.BiomeSelectorHandler:InvokeServer(State.TargetSelectorBiome)
        end)
        Notify("Biome Selector", ok and ("Result: " .. tostring(res) .. " " .. tostring(msg or "")) or tostring(res), 4)
    end,
})

-- ----------------------------------------------------------------------------
-- TAB 4: AUTO CRAFTING (JAKE & STELLA PROXIMITY-SAFE)
-- ----------------------------------------------------------------------------
TabCraft:Section({ Title = "Remote Crafting (Proximity-Aware)", Opened = true })

TabCraft:Dropdown({
    Title = "Workshop / Cauldron",
    Values = { "JakeWorkshop", "StellaCauldron" },
    Value = "JakeWorkshop",
    Flag = "CraftNamespace",
    Callback = function(v)
        State.CraftNamespace = v
    end,
})

State.SelectedRecipe = (table.find(RecipeList, "Luck Glove") and "Luck Glove") or RecipeList[1] or "Luck Glove"

TabCraft:Dropdown({
    Title = "Select Recipe",
    Values = RecipeList,
    Value = State.SelectedRecipe,
    SearchBarEnabled = true,
    Flag = "SelectedRecipe",
    Callback = function(v) State.SelectedRecipe = v end,
})

TabCraft:Toggle({
    Title = "Auto Add Ingredients & Craft Recipe",
    Desc = "Continuously feeds ingredients and crafts the selected recipe safely",
    Flag = "AutoCraftLoop",
    Value = false,
    Callback = function(v) State.AutoCraftLoop = v end,
})

TabCraft:Button({
    Title = "Add All Ingredients Once",
    Desc = "Bypasses the 5-second warning timer cleanly",
    Callback = function()
        if State.SelectedRecipe == "" then return end
        TrackSpawn(function()
            local ok, s, msg = WithWorkshopProximity(State.CraftNamespace, function()
                return ReplicatedStorage.Remote.Crafting.AddAllIngredients:InvokeServer(State.CraftNamespace, State.SelectedRecipe, true)
            end)
            Notify("Crafting", ok and (s and "Added all available ingredients!" or tostring(msg or "Completed")) or tostring(s), 3, "hammer")
        end)
    end,
})

TabCraft:Button({
    Title = "Craft Selected Recipe Once",
    Callback = function()
        if State.SelectedRecipe == "" then return end
        TrackSpawn(function()
            local ok, s, msg = WithWorkshopProximity(State.CraftNamespace, function()
                return ReplicatedStorage.Remote.Crafting.CraftRecipe:InvokeServer(State.CraftNamespace, State.SelectedRecipe)
            end)
            Notify("Crafting", ok and (s and ("Crafted " .. State.SelectedRecipe) or tostring(msg or "Completed")) or tostring(s), 3, "hammer")
        end)
    end,
})

TabCraft:Button({
    Title = "Set Server Auto-Add + Auto-Craft Target",
    Desc = "Configures native server auto-add & auto-craft to Selected Recipe",
    Callback = function()
        if State.SelectedRecipe == "" then return end
        TrackSpawn(function()
            local ok, s, msg = WithWorkshopProximity(State.CraftNamespace, function()
                return ReplicatedStorage.Remote.Crafting.SetAutoSettings:InvokeServer(State.CraftNamespace, {
                    auto_add = State.SelectedRecipe,
                    auto_craft = State.SelectedRecipe,
                })
            end)
            Notify("Crafting Auto Target", ok and (s and ("Set target: " .. State.SelectedRecipe) or tostring(msg or "Updated")) or tostring(s), 3)
        end)
    end,
})

TabCraft:Section({ Title = "Quick Gear Equiper", Opened = true })

local selectedGearType = "Right"
local selectedGearName = "Luck Glove"

TabCraft:Dropdown({
    Title = "Gear Slot",
    Values = { "Right", "Left", "Pocket" },
    Value = "Right",
    Flag = "GearSlot",
    Callback = function(v) selectedGearType = v end,
})

TabCraft:Dropdown({
    Title = "Gear Item",
    Values = #ItemList > 0 and ItemList or { "Luck Glove" },
    Value = "Luck Glove",
    SearchBarEnabled = true,
    Flag = "GearItem",
    Callback = function(v) selectedGearName = v end,
})

TabCraft:Button({
    Title = "Equip Selected Gear",
    Callback = function()
        SendActorCmd("EquipGear", selectedGearType, selectedGearName)
        Notify("Gear", "Sent equip request: " .. selectedGearName, 3)
    end,
})

-- ----------------------------------------------------------------------------
-- TAB 5: FISHING & NET SUITE
-- ----------------------------------------------------------------------------
TabFishing:Section({ Title = "Auto Fishing & Perfect Minigame Solver", Opened = true })

TabFishing:Dropdown({
    Title = "Fishing Location Filter",
    Values = { "Any", "Sol's World - Main Island", "Sol's World - Island 1", "Sol's World - Island 2" },
    Value = "Any",
    Flag = "FishAreaFilter",
    Callback = function(v) State.FishAreaFilter = v end,
})

TabFishing:Toggle({
    Title = "Auto Rod Fishing (100% Perfect Catch)",
    Desc = "Teleports to an unoccupied FishingPoint, casts rod, and locks minigame bar",
    Flag = "AutoRodFish",
    Value = false,
    Callback = function(v)
        State.AutoRodFish = v
        SyncActorConfig()
        if not v and not State.AutoNetFish then
            SendActorCmd("FishingQuit")
        end
    end,
})

TabFishing:Toggle({
    Title = "Auto Net Fishing",
    Desc = "Automatically runs net fishing at an unoccupied FishingPoint",
    Flag = "AutoNetFish",
    Value = false,
    Callback = function(v)
        State.AutoNetFish = v
        SyncActorConfig()
        if not v and not State.AutoRodFish then
            SendActorCmd("FishingQuit")
        end
    end,
})

TabFishing:Toggle({
    Title = "Perfect Minigame Solver Only (Manual Cast)",
    Desc = "Automatically wins any fishing minigame you start manually",
    Flag = "AutoMinigamePerfect",
    Value = false,
    Callback = function(v)
        State.AutoMinigamePerfect = v
        SyncActorConfig()
    end,
})

TabFishing:Section({ Title = "Auto Sell & Fish Shop", Opened = true })

TabFishing:Dropdown({
    Title = "Auto Sell Tiers",
    Values = { "common", "uncommon", "rare", "epic" },
    Value = State.SellFishTiers,
    Multi = true,
    AllowNone = true,
    Flag = "SellFishTiers",
    Callback = function(v)
        State.SellFishTiers = v
        SyncActorConfig()
    end,
})

TabFishing:Toggle({
    Title = "Sell Mutant Fish Too",
    Flag = "SellMutantFish",
    Value = false,
    Callback = function(v)
        State.SellMutantFish = v
        SyncActorConfig()
    end,
})

TabFishing:Toggle({
    Title = "Auto Sell Filtered Fish",
    Desc = "Sells matching fish in inventory and auto-confirms sell modal",
    Flag = "AutoSellFish",
    Value = false,
    Callback = function(v)
        State.AutoSellFish = v
        SyncActorConfig()
    end,
})

TabFishing:Button({
    Title = "Sell Filtered Fish Once",
    Callback = function()
        local tierMap = {}
        for _, t in ipairs(State.SellFishTiers or {}) do tierMap[t] = true end
        State.AutoSellFish = true
        SyncActorConfig()
        SendActorCmd("SellFilteredFish", tierMap, State.SellMutantFish)
        Notify("Fishing", "Selling filtered fish...", 3, "anchor")
    end,
})

TabFishing:Toggle({
    Title = "Auto Upgrade Fish Inventory",
    Flag = "AutoUpgradeFishBag",
    Value = false,
    Callback = function(v) State.AutoUpgradeFishBag = v end,
})

-- ----------------------------------------------------------------------------
-- TAB 6: QUESTS, EVENTS & MINIGAMES
-- ----------------------------------------------------------------------------
TabEvents:Section({ Title = "Quests, Achievements & Progression", Opened = true })

TabEvents:Toggle({
    Title = "Auto Claim Daily Quests",
    Flag = "AutoClaimDailyQuests",
    Value = false,
    Callback = function(v) State.AutoClaimDailyQuests = v end,
})

TabEvents:Toggle({
    Title = "Auto Request / Accept / Claim Side Quests",
    Flag = "AutoSideQuests",
    Value = false,
    Callback = function(v) State.AutoSideQuests = v end,
})

TabEvents:Toggle({
    Title = "Auto Claim Unlocked Achievements",
    Flag = "AutoClaimAchievements",
    Value = false,
    Callback = function(v) State.AutoClaimAchievements = v end,
})

TabEvents:Toggle({
    Title = "Auto Claim Season Pass Rewards",
    Flag = "AutoClaimSeasonPass",
    Value = false,
    Callback = function(v) State.AutoClaimSeasonPass = v end,
})

TabEvents:Toggle({
    Title = "Auto Claim Event Daily Login Reward",
    Flag = "AutoClaimEventDaily",
    Value = false,
    Callback = function(v) State.AutoClaimEventDaily = v end,
})

TabEvents:Section({ Title = "Halloween 2026 & Minigames", Opened = true })

TabEvents:Toggle({
    Title = "Auto Claim Halloween 2026 Bounties",
    Desc = "Claims Slot1, Slot2, Slot3 and Final Bounty rewards automatically",
    Flag = "AutoClaimHalloweenHunt",
    Value = false,
    Callback = function(v) State.AutoClaimHalloweenHunt = v end,
})

local AutoMemoryMatchToggle = TabEvents:Toggle({
    Title = "Auto Solve Memory Match",
    Desc = "Starts Memory Match off cooldown and tracks revealed pairs deterministically",
    Flag = "AutoMemoryMatch",
    Value = false,
    Callback = function(v) State.AutoMemoryMatch = v end,
})

TabEvents:Dropdown({
    Title = "Boss Raid Boss",
    Values = { "Sinister P.", "Sandworm", "Red Full Moon" },
    Value = "Sinister P.",
    Flag = "BossName",
    Callback = function(v) State.BossName = v end,
})

TabEvents:Dropdown({
    Title = "Boss Raid Difficulty",
    Values = { "Easy", "Normal", "Hard", "Hell" },
    Value = "Normal",
    Flag = "BossDifficulty",
    Callback = function(v) State.BossDifficulty = v end,
})

TabEvents:Dropdown({
    Title = "Boss Queue Mode",
    Values = { "Solo", "Lobby" },
    Value = "Solo",
    Flag = "BossQueueMode",
    Callback = function(v) State.BossQueueMode = v end,
})

local AutoBossRaidToggle = TabEvents:Toggle({
    Title = "Auto Queue Boss Raid",
    Flag = "AutoBossRaid",
    Value = false,
    Callback = function(v) State.AutoBossRaid = v end,
})

local function QueueVerifiedBossRaid()
    local okL, list = pcall(function()
        return ReplicatedStorage.Remote.BossRaid.RemoteFunction:InvokeServer("getBossList")
    end)
    if not okL or type(list) ~= "table" or #list == 0 then
        return false, "No Boss Raid event is currently active."
    end
    local validBoss, validDiff = false, false
    for _, b in ipairs(list) do
        if type(b) == "table" and b.bossName == State.BossName then
            validBoss = true
            for _, df in ipairs(b.difficulties or {}) do
                if type(df) == "table" and df.name == State.BossDifficulty and not df.maintenance then
                    validDiff = true
                    break
                end
            end
            break
        end
    end
    if not validBoss or not validDiff then
        return false, "Selected Boss Raid is inactive or under maintenance."
    end
    local action = State.BossQueueMode == "Solo" and "playSolo" or "gotoLobby"
    ReplicatedStorage.Remote.BossRaid.RemoteEvent:FireServer(action, State.BossName, State.BossDifficulty)
    return true, ("Sent " .. action .. " (" .. State.BossName .. " / " .. State.BossDifficulty .. ")")
end

TabEvents:Button({
    Title = "Enter Boss Raid Now",
    Callback = function()
        TrackSpawn(function()
            local okQ, msg = QueueVerifiedBossRaid()
            Notify("Boss Raid", msg, okQ and 3 or 4)
        end)
    end,
})

-- ----------------------------------------------------------------------------
-- TAB 7: MERCHANTS, BANK & CODES
-- ----------------------------------------------------------------------------
TabMerchants:Section({ Title = "Traveling Merchants (Mari / Jester)", Opened = true })

TabMerchants:Toggle({
    Title = "Auto Buy Traveling Merchant Stock",
    Desc = "Teleports to active merchant and purchases wanted items",
    Flag = "AutoBuyMerchant",
    Value = false,
    Callback = function(v) State.AutoBuyMerchant = v end,
})

TabMerchants:Dropdown({
    Title = "Merchant Wanted Items",
    Values = #ItemList > 0 and ItemList or State.MerchantWantedItems,
    Value = State.MerchantWantedItems,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Flag = "MerchantWantedItems",
    Callback = function(v) State.MerchantWantedItems = v end,
})

TabMerchants:Toggle({
    Title = "Auto Exchange Items at Jester",
    Desc = "Exchanges selected biome items for Jester Points when spawned",
    Flag = "AutoExchangeItems",
    Value = false,
    Callback = function(v) State.AutoExchangeItems = v end,
})

TabMerchants:Dropdown({
    Title = "Items to Exchange",
    Values = { "Rainy Bottle", "Wind essence", "Icicle", "Hour Glass", "Piece of Star", "Eternal Flame", "Feather Vial", "Curruptaine", "Stella's star", "NULL", "Void Coin" },
    Value = State.ExchangeWantedItems,
    Multi = true,
    AllowNone = true,
    Flag = "ExchangeWantedItems",
    Callback = function(v) State.ExchangeWantedItems = v end,
})

TabMerchants:Section({ Title = "Fischl Daily Shop & Bank", Opened = true })

TabMerchants:Toggle({
    Title = "Auto Buy Fischl Daily Shop",
    Desc = "Discovers and buys selected Daily Shop slots automatically",
    Flag = "AutoBuyDailyShop",
    Value = false,
    Callback = function(v) State.AutoBuyDailyShop = v end,
})

TabMerchants:Dropdown({
    Title = "Daily Shop Slots",
    Values = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
    Value = State.DailyShopWantedSlots,
    Multi = true,
    AllowNone = true,
    Flag = "DailyShopWantedSlots",
    Callback = function(v) State.DailyShopWantedSlots = v end,
})

TabMerchants:Dropdown({
    Title = "Daily Shop Payment Method",
    Values = { "Coin", "Point" },
    Value = "Coin",
    Flag = "DailyShopMethod",
    Callback = function(v) State.DailyShopMethod = v end,
})

TabMerchants:Toggle({
    Title = "Auto Repair / Upgrade Bank",
    Desc = "Invokes UpgradeBank automatically when ingredients are ready",
    Flag = "AutoUpgradeBank",
    Value = false,
    Callback = function(v) State.AutoUpgradeBank = v end,
})

TabMerchants:Section({ Title = "Codes & Secret StickyNotes", Opened = true })

local customCode = ""
TabMerchants:Input({
    Title = "Custom Code",
    Placeholder = "Enter code...",
    Value = "",
    Callback = function(v) customCode = v end,
})

TabMerchants:Button({
    Title = "Redeem Custom Code",
    Callback = function()
        if customCode ~= "" then
            SendActorCmd("RedeemCode", customCode)
        end
    end,
})

TabMerchants:Button({
    Title = "Redeem All Known Codes",
    Callback = function()
        TrackSpawn(function()
            for _, c in ipairs(KnownCodes) do
                if not Runtime.Alive then break end
                SendActorCmd("RedeemCode", c)
                task.wait(0.35)
            end
            Notify("Codes", "Finished trying " .. #KnownCodes .. " known codes.", 3)
        end)
    end,
})

TabMerchants:Button({
    Title = "Read StickyNote Cipher Clues",
    Callback = function()
        local notesFolder = workspace:FindFirstChild("CodeNotes")
        if not notesFolder then
            Notify("StickyNotes", "CodeNotes folder not found.", 3)
            return
        end
        local lines = {}
        for _, note in ipairs(notesFolder:GetChildren()) do
            local txt = {}
            for _, d in ipairs(note:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text ~= "" then
                    table.insert(txt, d.Text)
                end
            end
            table.insert(lines, note.Name .. ": " .. (#txt > 0 and table.concat(txt, " ") or "(blank)"))
        end
        table.sort(lines)
        Notify("StickyNotes", table.concat(lines, " | "), 8)
    end,
})

-- ----------------------------------------------------------------------------
-- TAB 8: TELEPORT, ESP & PLAYER
-- ----------------------------------------------------------------------------
TabTeleport:Section({ Title = "NPC & Map Teleports", Opened = true })

local TeleportCoords = {
    ["Spawn / Center"]       = Vector3.new(260, 102, -310),
    ["Jake's Workshop"]      = Vector3.new(344.5, 101, -331.0),
    ["Stella's Cauldron"]    = Vector3.new(-4648.7, 149.5, -228.4),
    ["Stella NPC"]           = Vector3.new(-4652.5, 149.5, -233.0),
    ["Fischl (Daily Shop)"]  = Vector3.new(444.2, 105, -369.2),
    ["Captain Flarg (Fish)"] = Vector3.new(100.5, 110.5, -296.8),
    ["Bank"]                 = Vector3.new(342.0, 99, -345.0),
    ["Quest Board"]          = Vector3.new(320.9, 100, -382.3),
    ["Memory Match"]         = Vector3.new(128.4, 95, -387.5),
    ["Obby Entrance"]        = Vector3.new(108.0, 99, -545.0),
    ["Boss Raid Portal"]     = Vector3.new(203.5, 104, -272.0),
    ["Shrine / Cup"]         = Vector3.new(608.5, 289, -197.5),
    ["Lime NPC"]             = Vector3.new(307.3, 101, -239.7),
    ["Bookcase"]             = Vector3.new(321.7, 101, -226.0),
    ["Bob's UGC Shop"]       = Vector3.new(243.2, 96, -251.9),
    ["Limbo Entrance"]       = Vector3.new(-9989.5, 4, -21.5),
    ["Jack (Halloween)"]     = Vector3.new(332.5, 109, -427.5),
}

local selectedTP = "Jake's Workshop"
local tpNames = {}
for k in pairs(TeleportCoords) do table.insert(tpNames, k) end
table.sort(tpNames)

TabTeleport:Dropdown({
    Title = "Select Destination",
    Values = tpNames,
    Value = selectedTP,
    SearchBarEnabled = true,
    Callback = function(v) selectedTP = v end,
})

TabTeleport:Button({
    Title = "Teleport to Destination",
    Callback = function()
        TrackSpawn(function()
            if selectedTP == "Jack (Halloween)" then
                local jh = workspace:FindFirstChild("JackHolder")
                local jack = jh and jh:FindFirstChild("Jack")
                if jack then
                    SafeGlideTo(CFrame.new(jack:GetPivot().Position + Vector3.new(0, 3, 4)))
                    return
                end
            end
            local pos = TeleportCoords[selectedTP]
            if pos then
                SafeGlideTo(CFrame.new(pos))
            end
        end)
    end,
})

TabTeleport:Button({
    Title = "Teleport to Active Traveling Merchant",
    Callback = function()
        for _, m in pairs(State.Live.Merchants or {}) do
            TrackSpawn(function()
                SafeGlideTo(CFrame.new(m.posX, m.posY + 3, m.posZ + 4))
                Notify("Teleport", "Glided to " .. m.name, 3)
            end)
            return
        end
        Notify("Teleport", "No traveling merchant is currently spawned.", 3)
    end,
})

TabTeleport:Section({ Title = "World ESP", Opened = true })

TabTeleport:Toggle({
    Title = "World DropItem ESP",
    Flag = "EspDrops",
    Value = false,
    Callback = function(v) State.EspDrops = v end,
})

TabTeleport:Toggle({
    Title = "Traveling Merchant ESP",
    Flag = "EspMerchants",
    Value = false,
    Callback = function(v) State.EspMerchants = v end,
})

TabTeleport:Toggle({
    Title = "Area Buff Giver ESP",
    Flag = "EspAreaGivers",
    Value = false,
    Callback = function(v) State.EspAreaGivers = v end,
})

TabTeleport:Toggle({
    Title = "StickyNote Cipher ESP",
    Flag = "EspStickyNotes",
    Value = false,
    Callback = function(v) State.EspStickyNotes = v end,
})

TabTeleport:Section({ Title = "Player, Anti-AFK & Performance", Opened = true })

local AntiAFKToggle = TabTeleport:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents Roblox 20-minute idle disconnect via VirtualUser",
    Flag = "AntiAFK",
    Value = false,
    Callback = function(v) State.AntiAFK = v end,
})

TabTeleport:Toggle({
    Title = "Enable WalkSpeed Override",
    Flag = "WalkSpeedEnabled",
    Value = false,
    Callback = function(v)
        State.WalkSpeedEnabled = v
        if not v then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabTeleport:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 45, Default = 24 },
    Step = 1,
    Flag = "WalkSpeedValue",
    Callback = function(v) State.WalkSpeedValue = v end,
})

TabTeleport:Toggle({
    Title = "Enable JumpPower Override",
    Flag = "JumpPowerEnabled",
    Value = false,
    Callback = function(v)
        State.JumpPowerEnabled = v
        if not v then
            local hum = GetHumanoid()
            if hum then hum.JumpPower = 50 end
        end
    end,
})

TabTeleport:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 85, Default = 55 },
    Step = 1,
    Flag = "JumpPowerValue",
    Callback = function(v) State.JumpPowerValue = v end,
})

TabTeleport:Toggle({
    Title = "Infinite Jump",
    Flag = "InfiniteJump",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})

TabTeleport:Toggle({
    Title = "Noclip",
    Flag = "Noclip",
    Value = false,
    Callback = function(v)
        State.Noclip = v
        if not v and LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end,
})

TabTeleport:Toggle({
    Title = "Fullbright",
    Flag = "Fullbright",
    Value = false,
    Callback = function(v)
        State.Fullbright = v
        if not v then
            Lighting.Brightness = Runtime.OrigLighting.Brightness
            Lighting.ClockTime = Runtime.OrigLighting.ClockTime
            Lighting.FogEnd = Runtime.OrigLighting.FogEnd
            Lighting.GlobalShadows = Runtime.OrigLighting.GlobalShadows
            Lighting.Ambient = Runtime.OrigLighting.Ambient
        end
    end,
})

TabTeleport:Toggle({
    Title = "Low-GFX AFK Optimizer (Strip Heavy Aura VFX)",
    Desc = "Disables world particles & lighting shadows for high FPS overnight AFK",
    Flag = "LowGfx",
    Value = false,
    Callback = function(v) State.LowGfx = v end,
})

-- ----------------------------------------------------------------------------
-- TAB 9: CONFIG & SETTINGS
-- ----------------------------------------------------------------------------
TabConfig:Section({ Title = "Configuration Manager", Opened = true })

local ConfigManager = Window.ConfigManager
local CONFIG_DIR = "WindUI/XLunaHUB_SolsRNG/config"
local configNameInput = "default"
local selectedConfigName = "default"
local ConfigDropdown = nil

local function EnsureConfigDir()
    if not isfolder or not makefolder then return false end
    if not isfolder("WindUI") then pcall(makefolder, "WindUI") end
    if not isfolder("WindUI/XLunaHUB_SolsRNG") then pcall(makefolder, "WindUI/XLunaHUB_SolsRNG") end
    if not isfolder(CONFIG_DIR) then pcall(makefolder, CONFIG_DIR) end
    return isfolder(CONFIG_DIR)
end

local function shallowEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    for k, v in pairs(a) do
        if b[k] ~= v then return false end
    end
    for k, v in pairs(b) do
        if a[k] ~= v then return false end
    end
    return true
end

local SKIP_STATE_KEYS = {
    Live = true,
    CraftingRecipes = true,
    RecipeIngredients = true,
    CraftingRequiredAuras = true,
    MemoryBoard = true,
}

local function SaveConfigFile(name)
    if not writefile then return false, "writefile unavailable" end
    if not name or name == "" then return false, "Invalid config name" end
    EnsureConfigDir()
    local snap = {}
    for k, v in pairs(State) do
        if not SKIP_STATE_KEYS[k] and type(v) ~= "function" then
            snap[k] = v
        end
    end
    local okEnc, json = pcall(function()
        return HttpService:JSONEncode({ version = 1, state = snap })
    end)
    if not okEnc or type(json) ~= "string" then
        return false, "JSON encode failed"
    end
    local okWr, errWr = pcall(writefile, CONFIG_DIR .. "/" .. name .. ".json", json)
    if not okWr then
        return false, tostring(errWr)
    end
    return true
end

local function LoadConfigFile(name)
    if not readfile or not isfile then return false, "readfile unavailable" end
    local path = CONFIG_DIR .. "/" .. tostring(name or "") .. ".json"
    if not isfile(path) then
        return false, "Config file does not exist"
    end
    local okDec, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not okDec or type(decoded) ~= "table" then
        return false, "Failed to parse config file"
    end
    local stateData = type(decoded.state) == "table" and decoded.state or decoded
    suppressSync = true
    local flags = Window.PendingFlags or {}
    for k, v in pairs(stateData) do
        if not SKIP_STATE_KEYS[k] and State[k] ~= nil and not shallowEqual(State[k], v) then
            State[k] = v
            local elem = flags[k]
            if elem then
                if elem.__type == "Toggle" and elem.Set then
                    pcall(function() elem:Set(v == true) end)
                elseif elem.__type == "Slider" and elem.Set then
                    pcall(function() elem:Set(tonumber(v) or 0) end)
                elseif elem.__type == "Input" and elem.Set then
                    pcall(function() elem:Set(tostring(v)) end)
                elseif elem.__type == "Dropdown" and elem.Select then
                    pcall(function() elem:Select(v) end)
                    task.wait()
                end
            end
        end
    end
    suppressSync = false
    SyncActorConfig()
    return true
end

local function DeleteConfigFile(name)
    if not delfile or not isfile then return false, "delfile unavailable" end
    local path = CONFIG_DIR .. "/" .. tostring(name or "") .. ".json"
    if not isfile(path) then
        return false, "Config file does not exist"
    end
    local ok, err = pcall(delfile, path)
    if not ok then
        return false, tostring(err)
    end
    return true, "Deleted " .. tostring(name)
end

local function GetConfigList()
    if not listfiles or not EnsureConfigDir() then return { "default" } end
    local out = {}
    local ok, files = pcall(listfiles, CONFIG_DIR)
    if ok and type(files) == "table" then
        for _, f in ipairs(files) do
            local name = tostring(f):match("([^\\/]+)%.json$")
            if name and name ~= "" then
                table.insert(out, name)
            end
        end
    end
    if #out > 0 then
        table.sort(out)
        return out
    end
    return { "default" }
end

TabConfig:Input({
    Title = "Config Name",
    Placeholder = "default",
    Value = "default",
    Callback = function(v)
        if v and v ~= "" then
            configNameInput = v
        end
    end,
})

ConfigDropdown = TabConfig:Dropdown({
    Title = "Saved Configs",
    Values = GetConfigList(),
    Value = selectedConfigName,
    Callback = function(v)
        if v and v ~= "" then
            selectedConfigName = v
        end
    end,
})

TabConfig:Button({
    Title = "Save Config",
    Desc = "Saves all current toggles and filter settings to JSON",
    Callback = function()
        local name = configNameInput ~= "" and configNameInput or selectedConfigName
        local ok, err = SaveConfigFile(name)
        if ok then
            selectedConfigName = name
            if ConfigDropdown and ConfigDropdown.Refresh then
                pcall(function() ConfigDropdown:Refresh(GetConfigList()) end)
            end
            Notify("Config Saved", "Saved configuration: " .. name, 3, "save")
        else
            Notify("Config Save Failed", tostring(err), 4)
        end
    end,
})

TabConfig:Button({
    Title = "Load Selected Config",
    Desc = "Applies saved toggles and values from the selected config sequentially",
    Callback = function()
        local name = selectedConfigName ~= "" and selectedConfigName or configNameInput
        TrackSpawn(function()
            local ok, err = LoadConfigFile(name)
            if ok then
                Notify("Config Loaded", "Loaded configuration: " .. name, 3, "check")
            else
                Notify("Config Load Failed", tostring(err), 4)
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Delete Selected Config",
    Callback = function()
        local name = selectedConfigName ~= "" and selectedConfigName or configNameInput
        local ok, msg = DeleteConfigFile(name)
        if ConfigDropdown and ConfigDropdown.Refresh then
            pcall(function() ConfigDropdown:Refresh(GetConfigList()) end)
        end
        Notify("Config", tostring(msg or ok), 3)
    end,
})

TabConfig:Button({
    Title = "Refresh Config List",
    Callback = function()
        if ConfigDropdown and ConfigDropdown.Refresh then
            pcall(function() ConfigDropdown:Refresh(GetConfigList()) end)
        end
    end,
})

TabConfig:Section({ Title = "Interface & Lifecycle", Opened = true })

TabConfig:Paragraph({
    Title = "UI Controls",
    Desc = "Keybind: LeftControl (Single-Owner Show / Hide)\nFloating Button: Drag or tap 'XLunaHUB' when minimized\nStartup Policy: ALL OFF until manually enabled or loaded",
})

local themeNames = {}
local rawThemes = WindUI:GetThemes()
if type(rawThemes) == "table" then
    for name in pairs(rawThemes) do
        table.insert(themeNames, tostring(name))
    end
    table.sort(themeNames)
end
if #themeNames == 0 then
    themeNames = { "Dark", "Light" }
end

TabConfig:Dropdown({
    Title = "UI Theme",
    Values = themeNames,
    Value = "Dark",
    Callback = function(v)
        pcall(function() Window:SetTheme(v) end)
    end,
})

TabConfig:Button({
    Title = "Unload XLunaHUB",
    Desc = "Cleanly stops all automations, Actor listeners, ESP, and destroys UI",
    Callback = function()
        if genv.__XLunaHUB_SolsRNG and genv.__XLunaHUB_SolsRNG.Cleanup then
            genv.__XLunaHUB_SolsRNG.Cleanup()
        end
    end,
})

pcall(function() TabDashboard:Select() end)
pcall(function() Window:SelectTab(1) end)
task.delay(0.45, function()
    if not Runtime.Alive then return end
    pcall(function() Window:SelectTab(1) end)
    if isWindowOpen and Window.OpenButtonMain then
        pcall(function() Window.OpenButtonMain:Visible(false) end)
    end
end)

-- ============================================================================
-- ACTOR EVENT CONSUMER (evtCh -> State)
-- ============================================================================
local lastKnownBiome = nil
TrackConn(evtCh.Event:Connect(function(sid, kind, a1, a2, a3)
    if not Runtime.Alive or sid ~= SESSION_ID then return end
    if kind == "Snapshot" and type(a1) == "table" then
        for k, v in pairs(a1) do
            State.Live[k] = v
        end
        State.Live.ActorReady = true

        -- Biome Sniper check
        if lastKnownBiome ~= State.Live.Biome then
            if lastKnownBiome ~= nil and State.BiomeSniperAlerts then
                if table.find(State.TargetSniperBiomes or {}, State.Live.Biome) then
                    Notify("BIOME SNIPER", "Rare Biome Spawned: " .. tostring(State.Live.Biome), 10, "sparkles")
                end
            end
            lastKnownBiome = State.Live.Biome
        end

        -- Update Dashboard Paragraphs
        local mNames = {}
        for _, m in pairs(State.Live.Merchants or {}) do
            table.insert(mNames, m.name)
        end
        local mStr = #mNames > 0 and table.concat(mNames, ", ") or "None"
        SetPara(LiveStatsPara, nil, string.format(
            "Biome: %s (%s) | Luck: %.2f\nRolls: %s | Auras: %d/%d | Fish: %d/%d\nCoins: %s | Dark: %s | Hollow: %s | FishCoins: %s\nBank: %s / %s | Active Merchants: %s",
            tostring(State.Live.Biome), tostring(State.Live.Time), tonumber(State.Live.Luck) or 1,
            FormatNum(State.Live.Rolls), State.Live.AuraCount or 0, State.Live.MaxStorableAuras or 20,
            State.Live.FishCount or 0, State.Live.FishInventorySize or 20,
            FormatNum(State.Live.Coins), FormatNum(State.Live.DarkCoins), FormatNum(State.Live.HollowPoints), FormatNum(State.Live.FishCoins),
            FormatNum(State.Live.Bank), FormatNum(State.Live.BankCapacity), mStr
        ))
        SetPara(SessionPara, nil, string.format(
            "Session Rolls: %d | Rare Kept (10k+): %d | Last Aura: %s (1 in %s)",
            State.Live.SessionRolls or 0, State.Live.SessionRare or 0,
            tostring(State.Live.LastAura), FormatNum(State.Live.LastRarity)
        ))

    elseif kind == "RollDelay" then
        State.Live.NextRollable = a1 or 0
        State.Live.RollDelay = a2 or 1

    elseif kind == "RollResult" then
        State.Live.SessionRolls = (State.Live.SessionRolls or 0) + 1
        State.Live.LastAura = tostring(a1)
        State.Live.LastRarity = tonumber(a2) or 0
        if (tonumber(a2) or 0) >= 10000 then
            State.Live.SessionRare = (State.Live.SessionRare or 0) + 1
        end

    elseif kind == "MerchantSpawned" then
        if State.MerchantAlerts then
            Notify("TRAVELING MERCHANT", tostring(a1) .. " has spawned!", 10, "shopping-bag")
        end

    elseif kind == "CodeResult" then
        Notify("Code Redeem", (a1 and "[Success] " or "[Info] ") .. tostring(a2), 3)

    elseif kind == "MMReveal" then
        State.MemoryBoard[a1] = { rewardId = a2, revealed = true, matched = false }
    elseif kind == "MMMatched" and type(a1) == "table" then
        for _, idx in ipairs(a1) do
            if State.MemoryBoard[idx] then State.MemoryBoard[idx].matched = true end
        end
    elseif kind == "MMUnreveal" and type(a1) == "table" then
        for _, idx in ipairs(a1) do
            if State.MemoryBoard[idx] then State.MemoryBoard[idx].revealed = false end
        end
    elseif kind == "MMRevealAll" then
        table.clear(State.MemoryBoard)
    end
end))

-- ============================================================================
-- BACKGROUND AUTOMATION LOOPS (ALL GATED BY STATE FLAGS, DEFAULT OFF)
-- ============================================================================

-- 1. Anti-AFK Listener
TrackConn(LocalPlayer.Idled:Connect(function()
    if Runtime.Alive and State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

-- 2. Auto Roll Loop (replicatesignal on RollButton)
TrackSpawn(function()
    local lastRollTrigger = 0
    while Runtime.Alive do
        if State.AutoRoll and State.Live.ActorReady then
            local now = workspace:GetServerTimeNow()
            if not State.Live.PendingResponse and now >= (State.Live.NextRollable or 0) + (State.RollDelayBuffer or 0.05) then
                if os.clock() - lastRollTrigger >= 0.25 then
                    local pg = LocalPlayer:FindFirstChild("PlayerGui")
                    local mi = pg and pg:FindFirstChild("MainInterface")
                    local bf = mi and mi:FindFirstChild("BottomFrame")
                    local rb = bf and bf:FindFirstChild("RollButton")
                    if rb then
                        lastRollTrigger = os.clock()
                        pcall(function()
                            replicatesignal(rb.MouseButton1Click)
                        end)
                    end
                end
            end
        end
        task.wait(0.08)
    end
end)

-- 3. World Pickups & Area Buffs Loop (Smooth Glide + Proximity Wait)
TrackSpawn(function()
    local pickupCooldown = {}
    while Runtime.Alive do
        if State.AutoCollectDrops and not Runtime.Moving then
            local hrp = GetHRP()
            if hrp and #GetWorldPickups() > 0 then
                local returnCF = hrp.CFrame
                local collectedAny = false
                for _ = 1, 12 do
                    if not Runtime.Alive or not State.AutoCollectDrops then break end
                    hrp = GetHRP()
                    if not hrp then break end
                    local nowClock = os.clock()
                    local best, bestDist = nil, math.huge
                    for _, item in ipairs(GetWorldPickups()) do
                        if item.obj and item.obj:IsDescendantOf(workspace) and item.prompt and item.prompt.Enabled then
                            if (nowClock - (pickupCooldown[item.obj] or 0)) >= 10 then
                                local d = (hrp.Position - item.pos).Magnitude
                                if d < bestDist then
                                    bestDist = d
                                    best = item
                                end
                            end
                        end
                    end
                    if not best then break end
                    pickupCooldown[best.obj] = os.clock()
                    collectedAny = true
                    TriggerPromptAt(best.prompt, best.pos, true, best.obj)
                    local wt = os.clock()
                    while Runtime.Alive and os.clock() - wt < 0.35 do
                        if not best.obj:IsDescendantOf(workspace) or not best.prompt.Enabled then
                            break
                        end
                        task.wait(0.08)
                    end
                end
                if collectedAny and returnCF and Runtime.Alive then
                    WalkToTarget(returnCF.Position, nil)
                end
            end
        end

        if State.AutoAreaBuffs and not Runtime.Moving then
            local ag = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("AreaGivers")
            local hrp = GetHRP()
            if ag and hrp then
                local first = ag:GetChildren()[1]
                if first then
                    local pos = first:IsA("BasePart") and first.Position or first:GetPivot().Position
                    if (hrp.Position - pos).Magnitude > 8 then
                        SafeGlideTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
                    end
                end
            end
        end

        task.wait(0.8)
    end
end)

-- 4. Potions, Chests, Storage Upgrade, Biome Selector Loop
TrackSpawn(function()
    local lastSelectorAttempt = 0
    local lastPotionTick = 0
    while Runtime.Alive do
        if State.Live.ActorReady then
            local inv = State.Live.Inventory or {}

            -- Auto Use Potions (delegated to Actor using BuffsMod:HasBuff + remaining > 3)
            if State.AutoUsePotions and os.clock() - lastPotionTick >= 2.0 then
                local biomeOK = true
                if State.PotionOnlyTargetBiome then
                    biomeOK = table.find(State.PotionBiomes or {}, State.Live.Biome) ~= nil
                end
                if biomeOK then
                    lastPotionTick = os.clock()
                    SendActorCmd("DrinkMissingPotions", State.SelectedPotions or {})
                end
            end

            -- Auto Open Chests
            if State.AutoOpenChests then
                for _, chestName in ipairs(State.SelectedChests or {}) do
                    local amt = inv[chestName] or 0
                    if amt > 0 then
                        SendActorCmd("UseItem", chestName, math.min(amt, 10))
                        task.wait(0.3)
                    end
                end
            end

            -- Auto Upgrade Aura Storage
            if State.AutoUpgradeStorage then
                if (State.Live.AuraCount or 0) >= (State.Live.MaxStorableAuras or 20) - 1 then
                    SendActorCmd("UpgradeStorage")
                end
            end

            -- Auto Biome Selector (only when owning Randomizer/Selector)
            if State.AutoBiomeSelector and State.Live.Biome ~= State.TargetSelectorBiome then
                if (inv["Biome Randomizer"] or 0) <= 0 and (inv["Biome Selector"] or 0) <= 0 then
                    State.AutoBiomeSelector = false
                    pcall(function() AutoBiomeSelectorToggle:Set(false) end)
                    Notify("Biome Selector", "You don't own a Biome Randomizer/Selector item.", 4)
                elseif os.clock() - lastSelectorAttempt >= 3 then
                    lastSelectorAttempt = os.clock()
                    pcall(function()
                        ReplicatedStorage.Remote.BiomeSelectorHandler:InvokeServer(State.TargetSelectorBiome)
                    end)
                end
            end
        end
        task.wait(1.0)
    end
end)

-- 5. Auto Crafting Loop
TrackSpawn(function()
    local lastAutoSetKey = ""
    while Runtime.Alive do
        if State.AutoCraftLoop and State.SelectedRecipe ~= "" then
            local key = State.CraftNamespace .. ":" .. State.SelectedRecipe
            WithWorkshopProximity(State.CraftNamespace, function()
                if lastAutoSetKey ~= key then
                    local okSet = ReplicatedStorage.Remote.Crafting.SetAutoSettings:InvokeServer(State.CraftNamespace, {
                        auto_add = State.SelectedRecipe,
                        auto_craft = State.SelectedRecipe,
                    })
                    if okSet then
                        lastAutoSetKey = key
                    end
                    task.wait(0.15)
                end
                return ReplicatedStorage.Remote.Crafting.CraftRecipe:InvokeServer(State.CraftNamespace, State.SelectedRecipe)
            end)
            task.wait(2.0)
        else
            lastAutoSetKey = ""
            task.wait(0.5)
        end
    end
end)

-- 6. Auto Fishing & Net Fishing Loop
TrackSpawn(function()
    local function findBestFishingPoint()
        local fpFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Miscs") and workspace.Map.Miscs:FindFirstChild("FishingPoints")
        if not fpFolder then return nil end
        local hrp = GetHRP()
        local best, bestDist = nil, math.huge
        for _, m in ipairs(fpFolder:GetChildren()) do
            if m:IsA("Model") and not m:GetAttribute("occupied") and m:GetAttribute("spotId") then
                local loc = m:GetAttribute("locationName") or "Unknown"
                if State.FishAreaFilter == "Any" or State.FishAreaFilter == loc then
                    local pos = m:GetPivot().Position
                    local d = hrp and (hrp.Position - pos).Magnitude or 0
                    if d < bestDist then
                        bestDist = d
                        best = m
                    end
                end
            end
        end
        return best
    end

    local lastSellTime = 0
    local savedFishReturnCF = nil
    local noRodTries = 0
    while Runtime.Alive do
        if State.AutoRodFish or State.AutoNetFish then
            local hrp = GetHRP()
            if hrp and not savedFishReturnCF then
                savedFishReturnCF = hrp.CFrame
            end
            local spot = findBestFishingPoint()
            if spot and hrp then
                local spotPivot = spot:GetPivot().Position
                if (hrp.Position - spotPivot).Magnitude > 7 then
                    SafeGlideTo(CFrame.new(spotPivot + Vector3.new(0, 2.5, 0)))
                    task.wait(0.45) -- Wait for FishingClient's updateNearbyFishingPoint <= 10 stud check
                end
                if not State.Live.FishUI_isFishing and not State.Live.FishUI_isMinigameMode then
                    local spotId = spot:GetAttribute("spotId")
                    if State.AutoNetFish then
                        SendActorCmd("FishingStartNet", spotId)
                    else
                        SendActorCmd("FishingStart", spotId)
                    end
                    task.wait(1.2)
                    if State.AutoRodFish and not State.Live.FishUI_isFishing and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("FishingRod") then
                        noRodTries += 1
                        if noRodTries >= 2 then
                            State.AutoRodFish = false
                            SyncActorConfig()
                            noRodTries = 0
                            Notify("Fishing", "Equip or purchase a Rod from Captain Flarg first.", 4, "anchor")
                        end
                    else
                        noRodTries = 0
                    end
                else
                    noRodTries = 0
                end
            end
        elseif savedFishReturnCF then
            noRodTries = 0
            SendActorCmd("FishingQuit")
            SafeGlideTo(savedFishReturnCF)
            savedFishReturnCF = nil
        end

        if State.AutoSellFish and os.clock() - lastSellTime >= 6 then
            if (State.Live.FishCount or 0) > 0 then
                lastSellTime = os.clock()
                local tierMap = {}
                for _, t in ipairs(State.SellFishTiers or {}) do tierMap[t] = true end
                SendActorCmd("SellFilteredFish", tierMap, State.SellMutantFish)
            end
        end

        if State.AutoUpgradeFishBag then
            if (State.Live.FishCount or 0) >= (State.Live.FishInventorySize or 20) - 1 then
                SendActorCmd("FishingUpgrade")
            end
        end

        task.wait(0.4)
    end
end)

-- 7. Quests, Achievements, SeasonPass, EventDaily, Halloween26, MemoryMatch, BossRaid, Merchants, DailyShop, Bank Loop
TrackSpawn(function()
    local lastDailyCheck = 0
    local lastSideQuestCheck = 0
    local lastAchCheck = 0
    local lastSeasonCheck = 0
    local lastEventDailyCheck = 0
    local lastH26Check = 0
    local lastBossCheck = 0
    local lastDailyShopCheck = 0
    local lastBankCheck = 0
    while Runtime.Alive do
        if State.Live.ActorReady then
            local nowClock = os.clock()

            -- Daily Quests (gated to loaded goals 1..3 every 8s)
            if State.AutoClaimDailyQuests and (nowClock - lastDailyCheck >= 8) then
                lastDailyCheck = nowClock
                SendActorCmd("ClaimCompletedDailyQuests")
            end

            -- Side Quests (only interact when QuestPrompt papers exist on QuestBoard every 30s)
            if State.AutoSideQuests and (nowClock - lastSideQuestCheck >= 30) then
                lastSideQuestCheck = nowClock
                local papers = CollectionService:GetTagged("QuestPrompt")
                if #papers > 0 and #(State.Live.ActiveSideQuests or {}) < 3 then
                    local hrp = GetHRP()
                    local savedCF = hrp and hrp.CFrame
                    if hrp and (hrp.Position - Vector3.new(320.9, 98.0, -382.3)).Magnitude > 14 then
                        SafeGlideTo(CFrame.new(320.9, 98.0, -382.3))
                    end
                    pcall(function()
                        if fireclickdetector then
                            fireclickdetector(papers[1])
                        end
                    end)
                    task.wait(0.45)
                    SendActorCmd("HandleSideQuestBoard")
                    task.wait(0.25)
                    if savedCF then SafeGlideTo(savedCF) end
                end
            end

            -- Achievements (strictly batched 1..127 with 120s cooldown per entry)
            if State.AutoClaimAchievements and (nowClock - lastAchCheck >= 15) then
                lastAchCheck = nowClock
                SendActorCmd("ClaimAllAchievements")
            end

            -- Season Pass (native single-packet claimAll only when unclaimed rewards exist)
            if State.AutoClaimSeasonPass and State.Live.UnclaimedSeasonPass == true and (nowClock - lastSeasonCheck >= 15) then
                lastSeasonCheck = nowClock
                SendActorCmd("ClaimSeasonPassSafe")
            end

            -- Event Daily Reward (max once per 60s; Claim only when st.canClaim == true)
            if State.AutoClaimEventDaily and (nowClock - lastEventDailyCheck >= 60) then
                lastEventDailyCheck = nowClock
                pcall(function()
                    local st = ReplicatedStorage.Remote.EventDailyReward.GetState:InvokeServer()
                    if type(st) == "table" and st.canClaim == true then
                        ReplicatedStorage.Remote.EventDailyReward.Claim:InvokeServer()
                    end
                end)
            end

            -- Halloween 2026 Bounties (matches sDef.id properly & claims FinalReward ONLY when 3/3 completed)
            if State.AutoClaimHalloweenHunt and (nowClock - lastH26Check >= 30) then
                lastH26Check = nowClock
                pcall(function()
                    local h26 = ReplicatedStorage.Remote.Halloween26
                    local okM, defs, info = pcall(function() return h26.GetMissionInfo:InvokeServer() end)
                    local serverNow = workspace:GetServerTimeNow()
                    if okM and type(info) == "table" and (tonumber(info.NextUpdateTime) or 0) > serverNow then
                        local doneSlots = 0
                        for _, slot in ipairs({ "Slot1", "Slot2", "Slot3" }) do
                            local sData = info[slot]
                            local sDef = nil
                            if type(defs) == "table" and type(defs[slot]) == "table" and type(sData) == "table" then
                                for _, def in pairs(defs[slot]) do
                                    if type(def) == "table" and def.id == sData.id then
                                        sDef = def
                                        break
                                    end
                                end
                            end
                            local goal = (sDef and tonumber(sDef.goal)) or math.huge
                            local prog = (sData and tonumber(sData.progress)) or 0
                            if sData and sDef and prog >= goal then
                                doneSlots += 1
                                if not sData.completed then
                                    h26.ClaimBounty:InvokeServer(slot)
                                end
                            end
                        end
                        if doneSlots == 3 and info.FinalReward == nil then
                            h26.ClaimBounty:InvokeServer("FinalReward", info.NextUpdateTime)
                        end
                    end
                end)
            end

            -- Memory Match Deterministic Solver (only flips when MemoryMatchActive == true)
            if State.AutoMemoryMatch then
                pcall(function()
                    local mmRF = ReplicatedStorage.Remote.MemoryMatch.RemoteFunction
                    local mmRE = ReplicatedStorage.Remote.MemoryMatch.RemoteEvent
                    if not State.Live.MemoryMatchActive then
                        if (State.Live.LastMemoryMatchPlayed or 0) + 43200 >= os.time() then
                            State.AutoMemoryMatch = false
                            pcall(function() AutoMemoryMatchToggle:Set(false) end)
                            Notify("Memory Match", "Memory Match is on cooldown.", 4)
                            return
                        end
                        local hrp = GetHRP()
                        local savedCF = hrp and hrp.CFrame
                        if hrp and (hrp.Position - Vector3.new(128.4, 93.0, -387.5)).Magnitude > 14 then
                            SafeGlideTo(CFrame.new(128.4, 93.0, -387.5))
                        end
                        local started = mmRF:InvokeServer("start")
                        if not started then
                            State.AutoMemoryMatch = false
                            pcall(function() AutoMemoryMatchToggle:Set(false) end)
                            Notify("Memory Match", "Memory match is not available right now.", 4)
                            if savedCF then SafeGlideTo(savedCF) end
                            return
                        end
                        task.wait(2.5)
                    end
                    if State.Live.MemoryMatchActive == true then
                        local byReward = {}
                        for idx, card in pairs(State.MemoryBoard) do
                            if card.rewardId and not card.matched then
                                byReward[card.rewardId] = byReward[card.rewardId] or {}
                                table.insert(byReward[card.rewardId], idx)
                            end
                        end
                        local flippedPair = false
                        for _, indices in pairs(byReward) do
                            if #indices >= 2 then
                                mmRE:FireServer("flipCard", indices[1])
                                task.wait(0.35)
                                mmRE:FireServer("flipCard", indices[2])
                                flippedPair = true
                                break
                            end
                        end
                        if not flippedPair then
                            for idx = 1, 20 do
                                if not State.MemoryBoard[idx] then
                                    mmRE:FireServer("flipCard", idx)
                                    task.wait(0.45)
                                    break
                                end
                            end
                        end
                    end
                end)
            end

            -- Boss Raid Queue (verified active boss + non-maintenance difficulty)
            if State.AutoBossRaid and (nowClock - lastBossCheck >= 20) then
                lastBossCheck = nowClock
                local okQ, msg = QueueVerifiedBossRaid()
                if not okQ then
                    State.AutoBossRaid = false
                    pcall(function() AutoBossRaidToggle:Set(false) end)
                    Notify("Boss Raid", msg, 4)
                end
            end

            -- Traveling Merchant Auto Buy (smooth glide)
            if State.AutoBuyMerchant then
                local wanted = {}
                for _, item in ipairs(State.MerchantWantedItems or {}) do wanted[item] = true end
                for mId, mInfo in pairs(State.Live.Merchants or {}) do
                    local hrp = GetHRP()
                    local savedCF = hrp and hrp.CFrame
                    if hrp then
                        SafeGlideTo(CFrame.new(mInfo.posX, mInfo.posY + 3, mInfo.posZ + 4))
                    end
                    for pUid, pData in pairs(mInfo.products or {}) do
                        if type(pData) == "table" and wanted[pData.ProductName] then
                            pcall(function()
                                ReplicatedStorage.Remote.Merchant.PurchaseProduct:InvokeServer(mId, pUid, 1)
                            end)
                            task.wait(0.2)
                        end
                    end
                    if savedCF then SafeGlideTo(savedCF) end
                end
            end

            -- Auto Exchange Items at Jester (smooth glide)
            if State.AutoExchangeItems then
                for mId, mInfo in pairs(State.Live.Merchants or {}) do
                    if tostring(mInfo.name):lower():find("jester") then
                        local hrp = GetHRP()
                        local savedCF = hrp and hrp.CFrame
                        if hrp then
                            SafeGlideTo(CFrame.new(mInfo.posX, mInfo.posY + 3, mInfo.posZ + 4))
                        end
                        for _, exItem in ipairs(State.ExchangeWantedItems or {}) do
                            local amt = State.Live.Inventory[exItem] or 0
                            if amt > 0 then
                                pcall(function()
                                    ReplicatedStorage.Remote.Merchant.ExchangeItem:InvokeServer(mId, exItem, amt)
                                end)
                                task.wait(0.2)
                            end
                        end
                        if savedCF then SafeGlideTo(savedCF) end
                    end
                end
            end

            -- Fischl Daily Shop (within 10 studs, gated once every 45s when currency > 0)
            if State.AutoBuyDailyShop and (nowClock - lastDailyShopCheck >= 45) then
                local method = State.DailyShopMethod == "Point" and "Point" or "Coin"
                local hasCur = method == "Coin" and (State.Live.Coins or 0) > 0 or (State.Live.DarkCoins or 0) > 0
                if hasCur then
                    lastDailyShopCheck = nowClock
                    local hrp = GetHRP()
                    local savedCF = hrp and hrp.CFrame
                    if hrp and (hrp.Position - Vector3.new(444.2, 102, -369.2)).Magnitude > 9 then
                        SafeGlideTo(CFrame.new(444.2, 103.5, -369.2))
                    end
                    for _, slotStr in ipairs(State.DailyShopWantedSlots or {}) do
                        local idx = tonumber(slotStr)
                        if idx then
                            SendActorCmd("DailyShopDiscover", idx)
                            task.wait(0.08)
                            SendActorCmd("DailyShopPurchase", idx, method)
                            task.wait(0.12)
                        end
                    end
                    if savedCF then SafeGlideTo(savedCF) end
                end
            end

            -- Bank Upgrade (within 10 studs of BankPosition, gated once every 45s)
            if State.AutoUpgradeBank and (nowClock - lastBankCheck >= 45) then
                lastBankCheck = nowClock
                local hrp = GetHRP()
                local savedCF = hrp and hrp.CFrame
                if hrp and (hrp.Position - Vector3.new(342.0, 96.0, -345.0)).Magnitude > 9 then
                    SafeGlideTo(CFrame.new(342.0, 97.5, -345.0))
                end
                pcall(function()
                    ReplicatedStorage.Remote.Bank.UpgradeBank:InvokeServer()
                end)
                if savedCF then SafeGlideTo(savedCF) end
            end
        end
        task.wait(1.5)
    end
end)

-- 8. Player Movement, Fullbright & Low-GFX Loop
TrackConn(RunService.Stepped:Connect(function()
    if not Runtime.Alive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.WalkSpeedEnabled then
            hum.WalkSpeed = tonumber(State.WalkSpeedValue) or 24
        end
        if State.JumpPowerEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = tonumber(State.JumpPowerValue) or 55
        end
    end
    if State.Noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
    if State.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    end
end))

TrackConn(UserInputService.JumpRequest:Connect(function()
    if Runtime.Alive and State.InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- Low-GFX Optimizer Loop
TrackSpawn(function()
    while Runtime.Alive do
        if State.LowGfx then
            Lighting.GlobalShadows = false
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name:sub(-4) == "Aura" and obj.Name ~= (LocalPlayer.Name .. "Aura") then
                    for _, d in ipairs(obj:GetDescendants()) do
                        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
                            d.Enabled = false
                        end
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)

-- 9. World ESP Loop
local function AddEspBox(adornee, text, color)
    if not adornee or not adornee:IsDescendantOf(workspace) then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.65
    hl.Adornee = adornee
    hl.Parent = adornee
    table.insert(Runtime.EspObjects, hl)

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(160, 36)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.Adornee = adornee
    bb.Parent = adornee
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.2
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Text = text
    table.insert(Runtime.EspObjects, bb)
end

TrackSpawn(function()
    while Runtime.Alive do
        ClearEsp()
        local hrp = GetHRP()
        if State.EspDrops then
            for _, item in ipairs(GetWorldPickups()) do
                if item.obj and item.obj:IsDescendantOf(workspace) then
                    local dist = hrp and math.floor((hrp.Position - item.pos).Magnitude) or 0
                    AddEspBox(item.obj, ("%s [%dm]"):format(item.kind, dist), Color3.fromRGB(80, 255, 160))
                end
            end
        end
        if State.EspMerchants then
            for _, m in pairs(State.Live.Merchants or {}) do
                local pos = Vector3.new(m.posX, m.posY, m.posZ)
                local dist = hrp and math.floor((hrp.Position - pos).Magnitude) or 0
                local mm = workspace:FindFirstChild(m.name) or workspace:FindFirstChild(m.id)
                if mm then
                    AddEspBox(mm, ("%s [%dm]"):format(m.name, dist), Color3.fromRGB(255, 200, 50))
                end
            end
        end
        if State.EspAreaGivers then
            local ag = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("AreaGivers")
            if ag then
                for _, g in ipairs(ag:GetChildren()) do
                    local dist = hrp and math.floor((hrp.Position - g:GetPivot().Position).Magnitude) or 0
                    AddEspBox(g, ("Area Buff [%dm]"):format(dist), Color3.fromRGB(110, 200, 255))
                end
            end
        end
        if State.EspStickyNotes then
            local cn = workspace:FindFirstChild("CodeNotes")
            if cn then
                for _, note in ipairs(cn:GetChildren()) do
                    local dist = hrp and math.floor((hrp.Position - note:GetPivot().Position).Magnitude) or 0
                    AddEspBox(note, ("%s [%dm]"):format(note.Name, dist), Color3.fromRGB(255, 120, 220))
                end
            end
        end
        task.wait(1.2)
    end
end)

-- ============================================================================
-- TEARDOWN / CLEANUP EXPORT
-- ============================================================================
genv.__XLunaHUB_SolsRNG = {
    SessionId = SESSION_ID,
    State = State,
    Window = Window,
    ConfigManager = ConfigManager,
    Runtime = Runtime,
    SendActorCmd = SendActorCmd,
    SyncActorConfig = SyncActorConfig,
    WithWorkshopProximity = WithWorkshopProximity,
    SafeGlideTo = SafeGlideTo,
    GetWorldPickups = GetWorldPickups,
    AntiAFKToggle = AntiAFKToggle,
    SaveConfig = SaveConfigFile,
    LoadConfig = LoadConfigFile,
    DeleteConfig = DeleteConfigFile,
    GetConfigList = GetConfigList,
    Cleanup = function()
        Runtime.Alive = false
        SendActorCmd("Shutdown")
        for _, c in ipairs(Runtime.Connections) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(Runtime.Connections)
        for _, th in ipairs(Runtime.Threads) do
            pcall(function() task.cancel(th) end)
        end
        table.clear(Runtime.Threads)
        ClearEsp()
        pcall(function()
            if workspace.CurrentCamera then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            end
        end)
        if Runtime.ModifiedQuickRoll then
            pcall(function() LocalPlayer:SetAttribute("QuickRollEnabled", Runtime.OrigQuickRoll) end)
        end
        pcall(function()
            Lighting.Brightness = Runtime.OrigLighting.Brightness
            Lighting.ClockTime = Runtime.OrigLighting.ClockTime
            Lighting.FogEnd = Runtime.OrigLighting.FogEnd
            Lighting.GlobalShadows = Runtime.OrigLighting.GlobalShadows
            Lighting.Ambient = Runtime.OrigLighting.Ambient
        end)
        if Runtime.Window then
            pcall(function() Runtime.Window:Destroy() end)
            Runtime.Window = nil
        end
    end,
}

Notify("XLunaHUB Loaded", "All features initialized OFF. Press LeftControl to Hide/Show.", 4, "sparkles")
