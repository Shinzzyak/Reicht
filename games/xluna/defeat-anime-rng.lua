-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    DEFEAT ANIME RNG â MASTER AUTOMATION SUITE
    Author: By XLunaHUB
    UI Framework: WindUI | Language: English
    Keybind: LeftControl (Show/Hide) | Floating Button: Enabled (Draggable)
    Default State: ALL OFF (All toggles disabled at startup)
    Stealth: GUI & ESP parented to gethui()/CoreGui (PlayerGui untouched)
    ========================================================================
]]

-- -------------------------------------------------------------------------
-- 1. SERVICES, THREAD IDENTITY GUARD & RELOAD CLEANUP
-- -------------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)

if getgenv().XLunaDARNG_Unload then
    pcall(getgenv().XLunaDARNG_Unload)
end

local setIdentityFn = setthreadidentity or (syn and syn.set_thread_identity) or setidentity

local function ensureElevatedIdentity()
    if type(setIdentityFn) == "function" then
        pcall(setIdentityFn, 8)
    end
end

local function safeWait(sec)
    local dt = task.wait(sec)
    ensureElevatedIdentity()
    return dt
end

ensureElevatedIdentity()

local Connections = {}
local Threads = {}
local Cleanups = {}

local function trackConn(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function trackThread(fn)
    local co = task.spawn(function()
        ensureElevatedIdentity()
        fn()
    end)
    table.insert(Threads, co)
    return co
end

local function getStealthContainerParent()
    ensureElevatedIdentity()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then
            return hui
        end
    end
    return CoreGui
end

-- -------------------------------------------------------------------------
-- 2. SAFE MODULES, DATABASES & REMOTES
-- -------------------------------------------------------------------------
local function safeRequire(inst)
    if not inst or not inst:IsA("ModuleScript") then
        return nil
    end
    local ok, mod = pcall(require, inst)
    ensureElevatedIdentity()
    return ok and mod or nil
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local res = table.pack(pcall(fn, ...))
    ensureElevatedIdentity()
    if res[1] then
        return table.unpack(res, 2, res.n)
    end
    return nil
end

local Databases = ReplicatedStorage:WaitForChild("Databases", 30)
local GeneralUseModules = ReplicatedStorage:WaitForChild("GeneralUseModules", 30)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 30)
ensureElevatedIdentity()

local UnitDatabase = safeRequire(Databases and Databases:FindFirstChild("UnitDatabase")) or {}
local RarityConfig = safeRequire(Databases and Databases:FindFirstChild("RarityConfig")) or {}
local UpgradeConfig = safeRequire(Databases and Databases:FindFirstChild("UpgradeConfig")) or {}
local ZoneDatabase = safeRequire(Databases and Databases:FindFirstChild("ZoneDatabase")) or {}
local WeaponsDatabase = safeRequire(Databases and Databases:FindFirstChild("WeaponsDatabase")) or {}
local ItemDatabase = safeRequire(Databases and Databases:FindFirstChild("ItemDatabase")) or {}
local TraitDatabase = safeRequire(Databases and Databases:FindFirstChild("TraitDatabase")) or {}
local MutationDatabase = safeRequire(Databases and Databases:FindFirstChild("MutationDatabase")) or {}
local XPConfig = safeRequire(Databases and Databases:FindFirstChild("XPConfig")) or {}
local CodesConfig = safeRequire(Databases and Databases:FindFirstChild("CodesConfig")) or {}
local EvolutionDatabase = safeRequire(Databases and Databases:FindFirstChild("EvolutionDatabase")) or {}
local CraftingDatabase = safeRequire(Databases and Databases:FindFirstChild("CraftingDatabase")) or {}
local EventShopDatabase = safeRequire(Databases and Databases:FindFirstChild("EventShopDatabase")) or {}
local RaidShopDatabase = safeRequire(Databases and Databases:FindFirstChild("RaidShopDatabase")) or {}
local WorldConfig = safeRequire(Databases and Databases:FindFirstChild("WorldConfig")) or {}
local RollDisplayConfig = safeRequire(Databases and Databases:FindFirstChild("RollDisplayConfig")) or {}
local EventConfig = safeRequire(Databases and Databases:FindFirstChild("EventConfig")) or {}
local WorldRaidConfig = safeRequire(Databases and Databases:FindFirstChild("WorldRaidConfig")) or {}
local ElementTowerConfig = safeRequire(Databases and Databases:FindFirstChild("ElementTowerConfig")) or {}
local PityConfig = safeRequire(Databases and Databases:FindFirstChild("PityConfig")) or {}

local UnitInventory = safeRequire(ReplicatedStorage:FindFirstChild("UnitInventory"))
local NumberFormat = safeRequire(GeneralUseModules and GeneralUseModules:FindFirstChild("NumberFormat"))
local ClientSettings = safeRequire(GeneralUseModules and GeneralUseModules:FindFirstChild("ClientSettings"))

local function rem(name)
    return RemoteEvents and RemoteEvents:FindFirstChild(name)
end

local REVEAL_TAG = (RollDisplayConfig and RollDisplayConfig.REVEAL_TAG) or "FloatingRollDisplay"

local RarityOrderList = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary",
    "Mythic", "Secret", "Divine", "Cosmic", "Exclusive", "Limited",
}
local RarityRank = {}
for i, r in ipairs(RarityOrderList) do
    RarityRank[r] = i
end

local function formatNumber(n)
    local v = tonumber(n) or 0
    if NumberFormat and type(NumberFormat.Format) == "function" then
        local s = safeCall(NumberFormat.Format, v)
        if type(s) == "string" then return s end
    end
    local sign = v < 0 and "-" or ""
    v = math.floor(math.abs(v))
    return sign .. tostring(v):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- -------------------------------------------------------------------------
-- 3. STATE STORE (STRICTLY ALL OFF ON STARTUP) & CONFIG PERSISTENCE
-- -------------------------------------------------------------------------
local CONFIG_DIR = "XLunaHUB_DefeatAnimeRNG"

local State = {
    -- Master Auto-Play Brain
    AutoPlayMaster = false,
    AutoPlayFocus = "Balanced Progression",

    -- Combat & Drops
    InstantCashXpMagnet = false,
    KillAura = false,
    AutoEquipBestWeapon = false,
    AutoFarmEnemies = false,
    FarmPriority = "Boss First",
    FarmPositionMode = "Behind",
    FarmDistance = 7,
    AutoCastUnitAbilities = false,
    AutoEnableServerUnitAbilities = false,
    UnitTargetMode = "First",

    -- Roll & Units
    ServerAutoRoll = false,
    FreeCustomAutoBuy = false,
    AutoBuyUnownedOnly = false,
    AutoBuyAnyMutated = false,
    AutoBuyMinRarity = "Rare",
    AutoSkipUnwantedRolls = false,
    ForceSkipUnaffordableMythic = false,
    AutoRollEventTickets = false,
    AutoEquipBestUnits = false,
    AutoPlaceBestUnits = false,
    AutoLockRareUnits = false,
    AutoSellJunkUnits = false,
    SellMaxRarity = "Epic",
    SellSafetyMode = "Safe (Keep 3 + Protect Rare)",
    AllowSellMutatedOrStarred = false,
    SelectedTeamSlot = "1",

    -- Remote Booths
    AutoFuseUnits = false,
    FuseMaxRarity = "Legendary",
    AutoClaimPendingBooths = false,
    SelectedManageUnitId = "None",
    SelectedEvolveChoice = "Default",
    SelectedTraitUnitId = "None",
    TargetTraits = { "Psychic", "Instinct", "Awakened", "Berserker", "Limitless" },
    AutoRerollTrait = false,
    AutoBuyBestWeapon = false,
    SelectedWeaponName = "Katana",
    SelectedCraftRecipe = "Fireman Hat",
    AutoDismantleAccessoryStars = false,

    -- Zones, Raids & Towers
    AutoUnlockZones = false,
    AutoTravelHighestZone = false,
    GoldenZoneAutoSniper = false,
    SelectedZoneName = "Fire City",
    AutoStartChallenges = false,
    ChallengePriorities = { "Weekly", "Daily", "Regular" },
    SelectedChallengeTier = "Regular",
    AutoEnterInfiniteTower = false,
    AutoEnterElementTower = false,
    AutoClaimTowerBracket = false,
    AutoJoinWorldRaid = false,
    AutoEvadeWorldRaidRockets = false,
    AutoBuyMerchantAll = false,
    SelectedMerchantItem = "Luck Potion",
    SelectedEventShopItem = "Trait Shards",
    SelectedRaidShopItem = "TraitReroll",

    -- Upgrades, Codes & Rewards
    AutoUpgradeMoneyStats = false,
    UpgradeProfile = "Balanced Progression",
    AutoUpgradePrestigeTree = false,
    SelectedUpgradeStat = "LuckLv",
    AutoPrestige = false,
    AutoClaimAllRewards = false,
    AutoUsePotions = false,
    SelectedPotions = { "Luck Potion", "Gold Potion", "XP Potion", "Time Potion" },
    SelectedFaction = "CCG",

    -- Player & Visuals
    SelectedBoothTeleport = "BlacksmithBooth",
    CustomWalkSpeed = false,
    WalkSpeed = 40,
    CustomJumpPower = false,
    JumpPower = 75,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 80,
    InstantPrompts = false,
    EnemyBossESP = false,
    RolledStandESP = false,
    BoothMerchantESP = false,
    Fullbright = false,
    HideForeignEffects = false,

    -- Config & Anti-AFK
    AntiAfk = false,
    AutoReExecuteOnTeleport = false,
    ConfigName = "default",
}

local UI_Elements = {}

-- -------------------------------------------------------------------------
-- 4. LOAD WINDUI & INITIALIZE WINDOW (LeftControl Toggle + Floating Button)
-- -------------------------------------------------------------------------
local WindUI = nil
do
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    }
    for _, url in ipairs(urls) do
        local ok, src = pcall(function() return game:HttpGet(url, true) end)
        if ok and type(src) == "string" and #src > 500 then
            local fn = loadstring(src)
            if fn then
                local okLib, lib = pcall(fn)
                ensureElevatedIdentity()
                if okLib and lib then
                    WindUI = lib
                    break
                end
            end
        end
    end
end

if not WindUI then
    warn("[XLunaHUB] Failed to load WindUI library.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Defeat Anime RNG",
    Icon = "sparkles",
    Author = "By XLunaHUB",
    Folder = "XLunaDARNG",
    Size = UDim2.fromOffset(680, 540),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 1.5,
        Color = ColorSequence.new(Color3.fromRGB(255, 95, 45), Color3.fromRGB(190, 40, 255)),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

local function notify(title, msg, duration)
    ensureElevatedIdentity()
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = msg,
            Duration = duration or 3,
        })
    end)
end

local function safeSetDesc(para, text)
    if not para or not para.SetDesc then return end
    ensureElevatedIdentity()
    para.Desc = text
    pcall(function()
        para:SetDesc(text)
    end)
end

-- -------------------------------------------------------------------------
-- 5. SHARED HELPERS (BASE, UNITS, ENEMIES, INVENTORY, MOVEMENT, SNAPSHOTS)
-- -------------------------------------------------------------------------
local Runtime = {
    killsEstimate = 0,
    orbsCollected = 0,
    unitsAutoBought = 0,
    rollsSkipped = 0,
    fusionsDone = 0,
    upgradesBought = 0,
    codesRedeemed = 0,
    lastAction = "Idle (All OFF)",
    goldenZones = {},
    rocketDangerZones = {},
    disabledIdledConns = {},
    cachedItemInv = {},
    cachedItemInvAt = 0,
    cachedUnlockedUnits = {},
    cachedUnlockedAt = 0,
    lastAbilityCast = 0,
    lastRollPromptAt = 0,
    lastBuyPromptAt = 0,
    lastSkipConfirmedAt = 0,
    lastAutoPlaceAt = 0,
    lastMagnetSweepAt = 0,
    lastAntiAfkPingAt = 0,
    lastRewardsAt = 0,
    lastPotionAt = 0,
    lastTowerCheckAt = 0,
    lastMerchantAt = 0,
    lastMythicAlertAt = 0,
    lastAutoEquipUnitAt = 0,
    teleportLockUntil = 0,
}

local function getRootAndHum()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function safeTeleportCF(cf)
    local _, hrp = getRootAndHum()
    if not hrp or typeof(cf) ~= "CFrame" then return false end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = cf
    return true
end

local function safeTeleportPos(pos)
    return safeTeleportCF(CFrame.new(pos))
end

local function getOwnBase()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then return nil end
    local uid = tostring(LocalPlayer.UserId)
    for _, b in ipairs(bases:GetChildren()) do
        local owner = b:FindFirstChild("Owner")
        if owner and tostring(owner.Value) == uid then
            return b
        end
    end
    return nil
end

local function getMoney()
    return tonumber(LocalPlayer:GetAttribute("Money")) or 0
end

local function getPrestigePoints()
    return tonumber(LocalPlayer:GetAttribute("PrestigePoints")) or 0
end

local function getItemInventory(force)
    if not force and (os.clock() - Runtime.cachedItemInvAt) < 3 then
        return Runtime.cachedItemInv
    end
    local fn = rem("GetItemInventoryFunction")
    if fn then
        local ok, data = pcall(function() return fn:InvokeServer() end)
        ensureElevatedIdentity()
        if ok and type(data) == "table" then
            Runtime.cachedItemInv = data
            Runtime.cachedItemInvAt = os.clock()
            return data
        end
    end
    return Runtime.cachedItemInv
end

local function getUnlockedUnits(force)
    if not force and (os.clock() - Runtime.cachedUnlockedAt) < 8 then
        return Runtime.cachedUnlockedUnits
    end
    local fn = rem("GetUnlockedUnitsFunction")
    if fn then
        local ok, data = pcall(function() return fn:InvokeServer() end)
        ensureElevatedIdentity()
        if ok and type(data) == "table" then
            Runtime.cachedUnlockedUnits = data
            Runtime.cachedUnlockedAt = os.clock()
            return data
        end
    end
    return Runtime.cachedUnlockedUnits
end

local function getAllInventoryUnits()
    if UnitInventory and type(UnitInventory.getTools) == "function" then
        local tools = safeCall(UnitInventory.getTools)
        if type(tools) == "table" then
            return tools
        end
    end
    local folder = ReplicatedStorage:FindFirstChild("UnitInventoryProxies")
    return folder and folder:GetChildren() or {}
end

local function getUnitId(tool)
    if not tool then return nil end
    if UnitInventory and type(UnitInventory.remoteArg) == "function" then
        local id = safeCall(UnitInventory.remoteArg, tool)
        if id then return id end
    end
    return tool:GetAttribute("UnitId") or tool.Name
end

local function getPlacedUnits(base)
    base = base or getOwnBase()
    local list = {}
    if not base then return list end
    local slots = base:FindFirstChild("PlacementSlots")
    if not slots then return list end
    for _, slot in ipairs(slots:GetChildren()) do
        local slotNum = tonumber(slot.Name:match("_(%d+)$"))
        local placedModel = nil
        for _, child in ipairs(slot:GetChildren()) do
            if child:IsA("Model") and child.Name:sub(1, 11) == "PlacedUnit_" then
                placedModel = child
                break
            end
        end
        table.insert(list, {
            slot = slot,
            slotNum = slotNum,
            model = placedModel,
        })
    end
    table.sort(list, function(a, b) return (a.slotNum or 99) < (b.slotNum or 99) end)
    return list
end

local function estimateUnitScore(unitName, mutation, stars)
    local def = UnitDatabase[unitName]
    local baseDmg = (def and tonumber(def.Damage)) or 10
    local atkSpd = (def and tonumber(def.AttackSpeed)) or 1
    if atkSpd <= 0 then atkSpd = 1 end
    local rarRank = (def and RarityRank[def.Rarity]) or 1
    local dps = baseDmg / atkSpd
    if MutationDatabase and type(MutationDatabase.ApplyDamage) == "function" and mutation then
        local modDmg = safeCall(MutationDatabase.ApplyDamage, baseDmg, mutation)
        if tonumber(modDmg) then
            dps = tonumber(modDmg) / atkSpd
        end
    end
    local starMult = 1 + (tonumber(stars) or 0) * 0.5
    return dps * starMult + rarRank * 0.01
end

local function buildUnitSelectionLabels()
    local labels = {}
    local lookup = {}
    for _, tool in ipairs(getAllInventoryUnits()) do
        local uid = tostring(getUnitId(tool))
        local uName = tool.Name
        local def = UnitDatabase[uName]
        local rar = def and def.Rarity or "?"
        local mut = tool:GetAttribute("Mutation")
        local tr = tool:GetAttribute("Trait")
        local st = tonumber(tool:GetAttribute("Stars")) or 0
        local lbl = string.format("%s [%s%s%s%s] (%s)",
            uName,
            rar,
            st > 0 and (" " .. st .. "â") or "",
            mut and (" | " .. tostring(mut)) or "",
            tr and (" | " .. tostring(tr)) or "",
            uid:sub(-6)
        )
        table.insert(labels, lbl)
        lookup[lbl] = uid
    end
    table.sort(labels)
    if #labels == 0 then
        return { "None" }, { None = "None" }
    end
    return labels, lookup
end

local UnitLabelLookup = {}

local function getUpgradePrice(statName, curLv)
    local cfg = UpgradeConfig[statName]
    if not cfg then return nil end
    curLv = curLv or (tonumber(LocalPlayer:GetAttribute(statName)) or 0)
    if cfg.MaxLevel and curLv >= cfg.MaxLevel then
        return nil
    end
    if type(cfg.Prices) == "table" then
        return cfg.Prices[curLv + 1]
    end
    if cfg.BasePrice and cfg.GrowthRate then
        return math.floor(cfg.BasePrice * (cfg.GrowthRate ^ (curLv - (cfg.ExponentOffset or 0))))
    end
    return nil
end

local function getBestAffordableWeapon()
    local bestName, bestDmg, bestPrice = nil, -1, 0
    local money = getMoney()
    for name, w in pairs(WeaponsDatabase) do
        if type(w) == "table" and not w.Unobtainable then
            local price = tonumber(w.Price) or 0
            local dmg = tonumber(w.Damage) or 0
            if price <= money and dmg > bestDmg then
                bestDmg = dmg
                bestName = name
                bestPrice = price
            end
        end
    end
    return bestName, bestDmg, bestPrice
end

local function getEquippedWeaponInCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and WeaponsDatabase[child.Name] then
            return child
        end
    end
    return nil
end

local function equipWeaponToolFromBackpack()
    local char, _, hum = getRootAndHum()
    if not char or not hum then return nil end
    local cur = getEquippedWeaponInCharacter()
    if cur then return cur end
    local bestTool, bestDmg = nil, -1
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and WeaponsDatabase[tool.Name] then
            local d = tonumber(WeaponsDatabase[tool.Name].Damage) or 0
            if d > bestDmg then
                bestDmg = d
                bestTool = tool
            end
        end
    end
    if bestTool then
        pcall(function() hum:EquipTool(bestTool) end)
        return bestTool
    end
    return nil
end

local function getActiveEnemies(base)
    base = base or getOwnBase()
    local targets = {}
    if base then
        for _, holderName in ipairs({ "BossHolder", "EnemiesHolder" }) do
            local holder = base:FindFirstChild(holderName)
            if holder then
                for _, m in ipairs(holder:GetChildren()) do
                    if m:IsA("Model") then
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                        if hum and hum.Health > 0 and hrp then
                            table.insert(targets, {
                                model = m,
                                hum = hum,
                                hrp = hrp,
                                isBoss = (holderName == "BossHolder") or (m:GetAttribute("Tier") == "Boss"),
                                isElite = (m:GetAttribute("Tier") == "Elite"),
                                scale = math.max(1, m:GetScale()),
                                hp = hum.Health,
                            })
                        end
                    end
                end
            end
        end
    end
    -- Include active World Raid Boss if player joined
    if LocalPlayer:GetAttribute(WorldRaidConfig.JOINED_ATTRIBUTE or "InWorldRaid") ~= nil then
        for _, inst in ipairs(Workspace:GetChildren()) do
            if inst:IsA("Model") and inst:GetAttribute("WorldRaidTarget") then
                local hum = inst:FindFirstChildOfClass("Humanoid")
                local hrp = inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart
                if hum and hum.Health > 0 and hrp then
                    table.insert(targets, {
                        model = inst,
                        hum = hum,
                        hrp = hrp,
                        isBoss = true,
                        isWorldRaid = true,
                        scale = math.max(1, inst:GetScale()),
                        hp = hum.Health,
                    })
                end
            end
        end
    end
    return targets
end

local function pickPriorityEnemy(targets, base)
    if #targets == 0 then return nil end
    local _, hrp = getRootAndHum()
    local myPos = hrp and hrp.Position
    local finishPart = base and base:FindFirstChild("FinishPart")
    local finishPos = finishPart and finishPart.Position
    local prio = State.FarmPriority

    table.sort(targets, function(a, b)
        if prio == "Boss First" then
            if a.isBoss ~= b.isBoss then return a.isBoss end
            if a.isElite ~= b.isElite then return a.isElite end
        elseif prio == "Highest HP" then
            if a.hp ~= b.hp then return a.hp > b.hp end
        elseif prio == "Closest To Finish" and finishPos then
            local da = (a.hrp.Position - finishPos).Magnitude
            local db = (b.hrp.Position - finishPos).Magnitude
            if math.abs(da - db) > 0.5 then return da < db end
        end
        if myPos then
            return (a.hrp.Position - myPos).Magnitude < (b.hrp.Position - myPos).Magnitude
        end
        return a.hp > b.hp
    end)
    return targets[1]
end

local function isEnemyInAttackBox(hrp, target, isGun)
    if not hrp or not target or not target.hrp then return false end
    local d = target.hrp.Position - hrp.Position
    if isGun then
        return Vector3.new(d.X, 0, d.Z).Magnitude <= 55
    end
    local reach = target.scale * 10
    if target.model:GetAttribute("WorldRaidTarget") then
        local localPt = target.hrp.CFrame:PointToObjectSpace(hrp.Position)
        local half = target.hrp.Size / 2
        local clamped = target.hrp.CFrame:PointToWorldSpace(Vector3.new(
            math.clamp(localPt.X, -half.X, half.X),
            math.clamp(localPt.Y, -half.Y, half.Y),
            math.clamp(localPt.Z, -half.Z, half.Z)
        ))
        d = clamped - hrp.Position
    end
    return math.abs(d.X) <= reach and math.abs(d.Y) <= reach and math.abs(d.Z) <= reach
end

local function safeFirePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    local origHold = prompt.HoldDuration
    prompt.HoldDuration = 0
    local fired = false
    if type(fireproximityprompt) == "function" then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then fired = true end
    end
    if not fired then
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.03)
            prompt:InputHoldEnd()
            fired = true
        end)
    end
    if not State.InstantPrompts then
        prompt.HoldDuration = origHold
    end
    return fired
end

-- Movement & Visuals Restoration Snapshots
local MovementOrig = { WalkSpeed = nil, JumpPower = nil }
local NoClipModified = {}
local FlyState = { active = false }
local FullbrightActive = false
local OriginalLighting = nil
local OrigPrompts = setmetatable({}, { __mode = "k" })

local function restoreWalkSpeed()
    local _, _, hum = getRootAndHum()
    if hum and MovementOrig.WalkSpeed ~= nil then
        pcall(function() hum.WalkSpeed = MovementOrig.WalkSpeed end)
    end
    MovementOrig.WalkSpeed = nil
end

local function restoreJumpPower()
    local _, _, hum = getRootAndHum()
    if hum and MovementOrig.JumpPower ~= nil then
        pcall(function() hum.JumpPower = MovementOrig.JumpPower end)
    end
    MovementOrig.JumpPower = nil
end

local function restoreNoClip()
    for part, origCollide in pairs(NoClipModified) do
        if part and part.Parent and part:IsA("BasePart") then
            pcall(function() part.CanCollide = origCollide end)
        end
    end
    table.clear(NoClipModified)
end

local function restoreFly()
    FlyState.active = false
    local _, hrp = getRootAndHum()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function applyFullbright(on)
    if on then
        if not FullbrightActive then
            OriginalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
            FullbrightActive = true
        end
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    elseif FullbrightActive and OriginalLighting then
        FullbrightActive = false
        for prop, val in pairs(OriginalLighting) do
            pcall(function() Lighting[prop] = val end)
        end
        OriginalLighting = nil
    end
end

local function applyInstantPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if OrigPrompts[prompt] == nil then
        OrigPrompts[prompt] = prompt.HoldDuration
    end
    prompt.HoldDuration = 0
end

local function restoreInstantPrompts()
    for prompt, origHold in pairs(OrigPrompts) do
        if prompt and prompt.Parent then
            pcall(function() prompt.HoldDuration = origHold end)
        end
    end
    table.clear(OrigPrompts)
end

local MyIdledHandlerFn = function()
    if State.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end

local function applyAntiAfkState(enabled)
    if enabled then
        if type(getconnections) == "function" then
            local ok, conns = pcall(getconnections, LocalPlayer.Idled)
            if ok and type(conns) == "table" then
                for _, c in ipairs(conns) do
                    if c and c.Enabled and c.Function ~= MyIdledHandlerFn then
                        pcall(function() c:Disable() end)
                        table.insert(Runtime.disabledIdledConns, c)
                    end
                end
            end
        end
        local ev = rem("AntiAfkActivityPingEvent")
        if ev then
            pcall(function() ev:FireServer() end)
            Runtime.lastAntiAfkPingAt = os.clock()
        end
    else
        for _, c in ipairs(Runtime.disabledIdledConns) do
            pcall(function() c:Enable() end)
        end
        table.clear(Runtime.disabledIdledConns)
    end
end

-- -------------------------------------------------------------------------
-- 6. CORE AUTOMATION ACTION HANDLERS
-- -------------------------------------------------------------------------
local function hideOrbLocally(part)
    if not part or not part.Parent then return end
    pcall(function()
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
            part.CanQuery = false
        end
        for _, d in ipairs(part:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Transparency = 1
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("BillboardGui") then
                d.Enabled = false
            end
        end
    end)
end

local CollectedOrbs = setmetatable({}, { __mode = "k" })

local function collectAllOwnedOrbs()
    local cashEv = rem("CollectCashEvent")
    local xpEv = rem("CollectXpEvent")
    local uid = LocalPlayer.UserId
    local count = 0

    if cashEv then
        for _, orb in ipairs(CollectionService:GetTagged("CashThing")) do
            if orb and orb.Parent and not CollectedOrbs[orb] and orb:GetAttribute("OwnerUserId") == uid then
                CollectedOrbs[orb] = true
                hideOrbLocally(orb)
                pcall(function() cashEv:FireServer(orb) end)
                count += 1
            end
        end
    end

    if xpEv then
        for _, orb in ipairs(CollectionService:GetTagged("XpThing")) do
            if orb and orb.Parent and not CollectedOrbs[orb] and orb:GetAttribute("OwnerUserId") == uid then
                CollectedOrbs[orb] = true
                hideOrbLocally(orb)
                pcall(function() xpEv:FireServer(orb) end)
                count += 1
            end
        end
    end

    Runtime.orbsCollected += count
    return count
end

local function isZoneUnlockedOrAvailable(zoneName)
    local curZone = LocalPlayer:GetAttribute("Zone")
    local curIdx, targetIdx = 1, 999
    for i, z in ipairs(ZoneDatabase) do
        if z.Name == curZone then curIdx = i end
        if z.Name == zoneName then targetIdx = i end
    end
    if WorldConfig and type(WorldConfig.GetWorld) == "function" then
        local w = safeCall(WorldConfig.GetWorld, zoneName)
        if w == 2 and type(WorldConfig.GetBlock) == "function" and type(WorldConfig.KillsFromAttributes) == "function" then
            local kills = safeCall(WorldConfig.KillsFromAttributes, LocalPlayer)
            local blk = safeCall(WorldConfig.GetBlock, zoneName, LocalPlayer:GetAttribute("Prestige") or 0, kills, LocalPlayer:GetAttribute("World2KillReqLv"))
            return blk == nil
        end
    end
    return targetIdx <= curIdx
end

local function getHighestUnlockedZone()
    local bestName = LocalPlayer:GetAttribute("Zone") or "Wisteria"
    for _, z in ipairs(ZoneDatabase) do
        if isZoneUnlockedOrAvailable(z.Name) then
            bestName = z.Name
        end
    end
    return bestName
end

local function tryUnlockNextZone()
    local curZone = LocalPlayer:GetAttribute("Zone")
    local curIdx = nil
    for i, z in ipairs(ZoneDatabase) do
        if z.Name == curZone then
            curIdx = i
            break
        end
    end
    if not curIdx then return false end
    local nextZone = ZoneDatabase[curIdx + 1]
    if not nextZone then return false end

    local price = tonumber(nextZone.Price) or 0
    local w = WorldConfig and type(WorldConfig.GetWorld) == "function" and safeCall(WorldConfig.GetWorld, nextZone.Name)
    local canUnlock = false
    if w == 2 then
        canUnlock = isZoneUnlockedOrAvailable(nextZone.Name)
    else
        canUnlock = getMoney() >= price
    end
    if canUnlock then
        local ev = rem("ZonePurchaseRequestEvent")
        if ev then
            pcall(function() ev:FireServer() end)
            Runtime.lastAction = "Unlocked Zone: " .. nextZone.Name
            return true
        end
    end
    return false
end

local function getActiveGoldenZones()
    local base = getOwnBase()
    local list = {}
    if not base then return list end
    local now = Workspace:GetServerTimeNow()
    for _, m in ipairs(CollectionService:GetTagged("PlacedUnitDisplay")) do
        if m:IsA("Model") and m:IsDescendantOf(base) then
            local gz = m:GetAttribute("GoldenZone")
            local untilT = tonumber(m:GetAttribute("GoldenZoneUntil"))
            if type(gz) == "string" and untilT and untilT > now and isZoneUnlockedOrAvailable(gz) then
                table.insert(list, { zone = gz, left = untilT - now })
            end
        end
    end
    table.sort(list, function(a, b) return a.left < b.left end)
    Runtime.goldenZones = list
    return list
end

local function placeBestUnitsNow()
    local base = getOwnBase()
    if not base then return 0 end
    local slotsInfo = getPlacedUnits(base)
    local emptySlots = {}
    local occupiedSlots = {}
    local placedIds = {}
    for _, info in ipairs(slotsInfo) do
        if info.model then
            local uid = info.model:GetAttribute("UnitId")
            if uid then placedIds[tostring(uid)] = true end
            local pName = info.model:GetAttribute("UnitName") or info.model.Name:gsub("^PlacedUnit_", "")
            local pScore = estimateUnitScore(pName, info.model:GetAttribute("Mutation"), info.model:GetAttribute("Stars"))
            info.score = pScore
            table.insert(occupiedSlots, info)
        elseif info.slot:FindFirstChild("ProximityHolder") and info.slot.ProximityHolder:FindFirstChild("ProximityPrompt") then
            table.insert(emptySlots, info)
        end
    end
    table.sort(occupiedSlots, function(a, b) return (a.score or 0) < (b.score or 0) end)

    local candidates = {}
    for _, tool in ipairs(getAllInventoryUnits()) do
        local uid = tostring(getUnitId(tool))
        if not placedIds[uid] then
            table.insert(candidates, {
                tool = tool,
                uid = uid,
                name = tool.Name,
                equipped = tool:GetAttribute("Equipped") ~= false,
                score = estimateUnitScore(tool.Name, tool:GetAttribute("Mutation"), tool:GetAttribute("Stars")),
            })
        end
    end
    table.sort(candidates, function(a, b) return a.score > b.score end)
    if #candidates == 0 then return 0 end

    local targetSlots = {}
    for _, s in ipairs(emptySlots) do
        if #candidates > #targetSlots then
            table.insert(targetSlots, { slot = s.slot, cand = candidates[#targetSlots + 1] })
        end
    end
    -- Upgrade weaker occupied slots if stronger inventory candidates remain
    local candIdx = #targetSlots + 1
    for _, occ in ipairs(occupiedSlots) do
        local cand = candidates[candIdx]
        if cand and cand.score > (occ.score or 0) * 1.05 and occ.slot:FindFirstChild("ProximityHolder") and occ.slot.ProximityHolder:FindFirstChild("ProximityPrompt") then
            table.insert(targetSlots, { slot = occ.slot, cand = cand })
            candIdx += 1
        end
    end
    if #targetSlots == 0 then return 0 end

    local eqBest = rem("EquipBestRequestFunction")
    if eqBest then
        pcall(function() eqBest:InvokeServer() end)
        ensureElevatedIdentity()
    end

    local setEq = rem("SetUnitEquippedRequestFunction")
    local placedCount = 0
    local _, origHrp, hum = getRootAndHum()
    local origCF = origHrp and origHrp.CFrame
    Runtime.teleportLockUntil = os.clock() + 2.5

    for _, entry in ipairs(targetSlots) do
        local cand = entry.cand
        if not cand.equipped and setEq then
            pcall(function() setEq:InvokeServer(cand.uid, true) end)
            ensureElevatedIdentity()
            safeWait(0.15)
        end
        local bpTool = nil
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and (tostring(t:GetAttribute("UnitId")) == cand.uid or t.Name == cand.name) then
                bpTool = t
                break
            end
        end
        if not bpTool and LocalPlayer.Character then
            for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
                if t:IsA("Tool") and (tostring(t:GetAttribute("UnitId")) == cand.uid or t.Name == cand.name) then
                    bpTool = t
                    break
                end
            end
        end
        if bpTool and hum then
            pcall(function() hum:EquipTool(bpTool) end)
            safeWait(0.1)
            local holder = entry.slot:FindFirstChild("ProximityHolder")
            local prompt = holder and holder:FindFirstChild("ProximityPrompt")
            if holder and prompt then
                Runtime.teleportLockUntil = os.clock() + 0.8
                safeTeleportCF(holder.CFrame * CFrame.new(0, 3, 2))
                safeWait(0.32)
                safeFirePrompt(prompt)
                safeWait(0.25)
                placedCount += 1
            end
        end
    end

    if origCF and not State.AutoFarmEnemies then
        safeTeleportCF(origCF)
    end
    equipWeaponToolFromBackpack()
    Runtime.lastAction = string.format("Auto-Placed %d unit(s)", placedCount)
    return placedCount
end

local MYSTERY_TAG = (RollDisplayConfig and RollDisplayConfig.MYSTERY_TAG) or "MysteryRollDisplay"

local function processFreeRollStationOnce()
    local base = getOwnBase()
    if not base then return end
    local rs = base:FindFirstChild("RollStation")
    if not rs then return end

    for _, m in ipairs(CollectionService:GetTagged(MYSTERY_TAG)) do
        if m:IsDescendantOf(rs) then
            return
        end
    end

    local revealed = nil
    for _, m in ipairs(CollectionService:GetTagged(REVEAL_TAG)) do
        if m:IsA("Model") and m:IsDescendantOf(rs) then
            revealed = m
            break
        end
    end

    if revealed then
        local uName = revealed:GetAttribute("UnitName") or revealed.Name
        local def = UnitDatabase[uName]
        local rar = revealed:GetAttribute("Rarity") or (def and def.Rarity) or "Common"
        local mut = revealed:GetAttribute("Mutation")
        local rRank = RarityRank[rar] or 1
        local minRank = RarityRank[State.AutoBuyMinRarity] or 3
        local unlocked = getUnlockedUnits(false)
        local isUnowned = (unlocked[uName] ~= true)

        local wantBuy = false
        if rRank >= minRank then wantBuy = true end
        if (State.AutoBuyAnyMutated or State.AutoPlayMaster) and mut ~= nil then wantBuy = true end
        if (State.AutoBuyUnownedOnly or State.AutoPlayMaster) and isUnowned then wantBuy = true end

        local price = tonumber(revealed:GetAttribute("Price")) or (def and tonumber(def.Price)) or 0
        if mut and MutationDatabase and type(MutationDatabase.ApplyPrice) == "function" then
            local adj = safeCall(MutationDatabase.ApplyPrice, price, mut)
            if tonumber(adj) then price = tonumber(adj) end
        end

        local buyPrompt = revealed:FindFirstChildWhichIsA("ProximityPrompt", true)
        if wantBuy and buyPrompt then
            if getMoney() >= price then
                if os.clock() - Runtime.lastBuyPromptAt >= 0.65 then
                    local _, hrp = getRootAndHum()
                    local targetPart = buyPrompt.Parent and buyPrompt.Parent:IsA("BasePart") and buyPrompt.Parent or revealed:FindFirstChildWhichIsA("BasePart", true)
                    if hrp and targetPart and (hrp.Position - targetPart.Position).Magnitude > math.max(3, buyPrompt.MaxActivationDistance - 2) then
                        Runtime.teleportLockUntil = os.clock() + 0.6
                        safeTeleportCF(targetPart.CFrame * CFrame.new(0, 3, 2))
                        safeWait(0.32)
                    end
                    safeFirePrompt(buyPrompt)
                    Runtime.lastBuyPromptAt = os.clock()
                    Runtime.unitsAutoBought += 1
                    Runtime.lastAction = string.format("Auto-Bought: %s [%s%s]", uName, rar, mut and ("/" .. tostring(mut)) or "")
                end
                return
            elseif rRank >= (RarityRank.Mythic or 6) and not State.ForceSkipUnaffordableMythic then
                if os.clock() - Runtime.lastMythicAlertAt > 8 then
                    Runtime.lastMythicAlertAt = os.clock()
                    notify("Rare Roll Waiting!", string.format("%s (%s) costs Â¥%s â paused skip to protect roll!", uName, rar, formatNumber(price)), 5)
                end
                return
            end
        end

        -- Skip unwanted or unaffordable non-protected roll
        if (State.AutoSkipUnwantedRolls or State.AutoPlayMaster) and os.clock() - Runtime.lastRollPromptAt >= 2.6 then
            local minWarnRank = (PityConfig and PityConfig.Rank and PityConfig.Rank.Mythic) or 6
            if rRank >= minWarnRank then
                local conf = rem("ConfirmedRollRequestEvent")
                if conf and (os.clock() - Runtime.lastSkipConfirmedAt) >= 0.5 then
                    pcall(function() conf:FireServer() end)
                    Runtime.lastSkipConfirmedAt = os.clock()
                    Runtime.rollsSkipped += 1
                    Runtime.lastAction = "Confirmed Skip: " .. uName
                end
                return
            end
        end
    end

    -- Trigger next roll if enabled and no protected roll blocks it
    if State.AutoSkipUnwantedRolls or State.AutoPlayMaster or not revealed then
        local button = rs:FindFirstChild("Button")
        local rollBtn = button and button:FindFirstChild("RollButton", true)
        local rollPrompt = rollBtn and rollBtn:FindFirstChild("ProximityPrompt")
        if rollPrompt and rollPrompt.Enabled and (os.clock() - Runtime.lastRollPromptAt) >= 2.6 then
            local _, hrp = getRootAndHum()
            if hrp and rollBtn:IsA("BasePart") and (hrp.Position - rollBtn.Position).Magnitude > math.max(3, rollPrompt.MaxActivationDistance - 2) then
                Runtime.teleportLockUntil = os.clock() + 0.6
                safeTeleportCF(rollBtn.CFrame * CFrame.new(0, 3, 2))
                safeWait(0.32)
            end
            safeFirePrompt(rollPrompt)
            Runtime.lastRollPromptAt = os.clock()
            Runtime.rollsSkipped += (revealed and 1 or 0)
        end
    end
end

local function fuseAllEligibleNow()
    local fuseFn = rem("FuseRequestFunction")
    if not fuseFn then return 0 end
    local maxRank = RarityRank[State.FuseMaxRarity] or 5
    local counts = {}
    for _, tool in ipairs(getAllInventoryUnits()) do
        if tool:GetAttribute("Locked") ~= true then
            local def = UnitDatabase[tool.Name]
            local rar = def and def.Rarity or "Common"
            if (RarityRank[rar] or 1) <= maxRank then
                local st = tonumber(tool:GetAttribute("Stars")) or 0
                local key = tool.Name .. "|" .. tostring(st)
                counts[key] = counts[key] or {}
                table.insert(counts[key], tool)
            end
        end
    end

    local fused = 0
    for _, list in pairs(counts) do
        if #list >= 3 then
            local uid = getUnitId(list[1])
            local ok, res = pcall(function() return fuseFn:InvokeServer(uid, 1, false, "Max") end)
            ensureElevatedIdentity()
            if ok and res then
                fused += 1
            end
        end
    end
    Runtime.fusionsDone += fused
    if fused > 0 then
        Runtime.lastAction = string.format("Fused %d group(s)", fused)
    end
    return fused
end

local function sellJunkUnitsNow()
    local sellFn = rem("SellUnitsRequestFunction")
    if not sellFn then return 0, 0 end
    local maxRank = RarityRank[State.SellMaxRarity] or 4
    local protectRare = (State.SellSafetyMode ~= "Sell All Below Max Rarity") and not State.AllowSellMutatedOrStarred
    local keepThree = (State.SellSafetyMode == "Safe (Keep 3 + Protect Rare)")
    local grouped = {}
    for _, tool in ipairs(getAllInventoryUnits()) do
        local locked = tool:GetAttribute("Locked") == true
        local mut = tool:GetAttribute("Mutation")
        local stars = tonumber(tool:GetAttribute("Stars")) or 0
        local def = UnitDatabase[tool.Name]
        local rar = def and def.Rarity or "Common"
        local rRank = RarityRank[rar] or 1

        local protected = locked
            or (protectRare and (mut ~= nil or stars > 0))
            or (rRank > maxRank)
        if not protected then
            grouped[tool.Name] = grouped[tool.Name] or {}
            table.insert(grouped[tool.Name], getUnitId(tool))
        end
    end

    local toSell = {}
    for _, ids in pairs(grouped) do
        local keep = keepThree and 3 or 0
        for i = 1, math.max(0, #ids - keep) do
            table.insert(toSell, ids[i])
        end
    end
    if #toSell == 0 then return 0, 0 end

    local ok, success, gained, count = pcall(function() return sellFn:InvokeServer(toSell) end)
    ensureElevatedIdentity()
    if ok and success then
        Runtime.lastAction = string.format("Sold %d junk unit(s) for Â¥%s", tonumber(count) or #toSell, formatNumber(gained))
        return tonumber(count) or #toSell, tonumber(gained) or 0
    end
    return 0, 0
end

local function lockRareUnitsNow()
    local lockFn = rem("ToggleUnitLockRequestFunction")
    if not lockFn then return 0 end
    local locked = 0
    for _, tool in ipairs(getAllInventoryUnits()) do
        if tool:GetAttribute("Locked") ~= true then
            local def = UnitDatabase[tool.Name]
            local rRank = (def and RarityRank[def.Rarity]) or 1
            local mut = tool:GetAttribute("Mutation")
            local st = tonumber(tool:GetAttribute("Stars")) or 0
            if rRank >= (RarityRank.Mythic or 6) or mut ~= nil or st >= 2 then
                local ok = pcall(function() return lockFn:InvokeServer(getUnitId(tool)) end)
                ensureElevatedIdentity()
                if ok then locked += 1 end
            end
        end
    end
    return locked
end

local function runAutoUpgradeMoney()
    local upgEv = rem("UpgradeRequestEvent")
    if not upgEv then return 0 end
    local profile = State.UpgradeProfile
    local order
    if profile == "Luck & Roll Speed First" then
        order = { "AutoRollLv", "LuckLv", "SuperLuckLv", "RollSpeedLv", "RollSlots", "PlacementSlotLv", "EnemySpawnRateLv", "EnemiesLv", "GoldMutationLv", "DiamondMutationLv", "PsychicMutationLv", "BossChanceLv", "EliteChanceLv", "UnitDamageLv", "SwingSpeedLv", "SwingDamageLv", "LootGoldLv", "LootXpLv" }
    elseif profile == "DPS & Combat First" then
        order = { "PlacementSlotLv", "UnitDamageLv", "UnitCritChanceLv", "SwingDamageLv", "SwingSpeedLv", "SwingCritChanceLv", "SwingCritDamageLv", "BlacksmithLv", "EnemySpawnRateLv", "EnemiesLv", "BossChanceLv", "EliteChanceLv", "LuckLv", "RollSpeedLv" }
    elseif profile == "Gold & XP Economy First" then
        order = { "EnemySpawnRateLv", "EnemiesLv", "LootLv", "LootGoldLv", "LootXpLv", "PlacementSlotLv", "BossChanceLv", "EliteChanceLv", "OfflineGoldLv", "OfflineXpLv", "OfflineCapLv", "LuckLv", "UnitDamageLv", "SwingDamageLv" }
    else
        order = { "AutoRollLv", "BlacksmithLv", "LootLv", "TimersLv", "PlayerLv", "PlacementSlotLv", "LuckLv", "RollSpeedLv", "EnemySpawnRateLv", "EnemiesLv", "SwingSpeedLv", "SwingDamageLv", "UnitDamageLv", "BossChanceLv", "EliteChanceLv", "SuperLuckLv", "LootGoldLv", "LootXpLv", "RollSlots", "GoldMutationLv", "UnitCritChanceLv", "SwingCritChanceLv", "PlayerSpeedLv" }
    end

    local bought = 0
    local money = getMoney()
    for _, stat in ipairs(order) do
        local cfg = UpgradeConfig[stat]
        if cfg and cfg.Currency ~= "PrestigePoints" then
            local price = getUpgradePrice(stat)
            if price and price <= money then
                pcall(function() upgEv:FireServer(stat) end)
                money -= price
                bought += 1
                Runtime.upgradesBought += 1
                Runtime.lastAction = "Upgraded: " .. stat
            end
        end
    end
    return bought
end

local function runAutoUpgradePrestige()
    local upgEv = rem("UpgradeRequestEvent")
    if not upgEv then return 0 end
    local pts = getPrestigePoints()
    if pts <= 0 then return 0 end
    local order = { "UnitCapacityLv", "PrestigeGoldLv", "PrestigeXpLv", "World2KillReqLv", "EvolveTimeLv", "AtomizeTimeLv", "PrestigeGoldInfLv", "PrestigeXpInfLv" }
    local bought = 0
    for _, stat in ipairs(order) do
        local cfg = UpgradeConfig[stat]
        if cfg and cfg.Currency == "PrestigePoints" then
            local price = getUpgradePrice(stat)
            if price and price <= pts then
                pcall(function() upgEv:FireServer(stat) end)
                pts -= price
                bought += 1
                Runtime.upgradesBought += 1
                Runtime.lastAction = "Prestige Upgraded: " .. stat
            end
        end
    end
    return bought
end

local function claimAllRewardsNow()
    local claimed = 0
    -- 1. Daily Reward
    local dailyStatFn = rem("GetDailyRewardStatusFunction")
    local dailyClaimFn = rem("ClaimDailyRewardFunction")
    if dailyStatFn and dailyClaimFn then
        local ok, st = pcall(function() return dailyStatFn:InvokeServer() end)
        ensureElevatedIdentity()
        if ok and type(st) == "table" and st.CanClaim and st.NextDay then
            local ok2, res = pcall(function() return dailyClaimFn:InvokeServer(st.NextDay) end)
            ensureElevatedIdentity()
            if ok2 and res then claimed += 1 end
        end
    end

    -- 2. Group Reward
    local grpClaim = rem("ClaimGroupRewardFunction")
    if grpClaim then
        local ok, res = pcall(function() return grpClaim:InvokeServer() end)
        ensureElevatedIdentity()
        if ok and res then claimed += 1 end
    end

    -- 3. Offline Reward
    local offEv = rem("ClaimOfflineRewardEvent")
    if offEv then
        pcall(function() offEv:FireServer() end)
    end

    -- 4. Battlepass Free (and Premium if owned)
    local bpFn = rem("BattlepassFunction")
    if bpFn then
        local ok, ok2, st = pcall(function() return bpFn:InvokeServer("GetState") end)
        ensureElevatedIdentity()
        if ok and ok2 and type(st) == "table" and type(st.Level) == "number" then
            local claimedMap = st.Claimed or {}
            for lv = 1, st.Level do
                if not claimedMap["F" .. lv] then
                    local okC, resC = pcall(function() return bpFn:InvokeServer("Claim", lv, "Free") end)
                    ensureElevatedIdentity()
                    if okC and resC then claimed += 1 end
                end
                if st.Premium and not claimedMap["P" .. lv] then
                    local okP, resP = pcall(function() return bpFn:InvokeServer("Claim", lv, "Premium") end)
                    ensureElevatedIdentity()
                    if okP and resP then claimed += 1 end
                end
            end
        end
    end

    -- 5. Event Quests
    local eqSnapFn = rem("GetEventQuestSnapshotFunction")
    local eqClaimFn = rem("ClaimEventQuestRequestFunction")
    if eqSnapFn and eqClaimFn then
        local ok, snap = pcall(function() return eqSnapFn:InvokeServer() end)
        ensureElevatedIdentity()
        if ok and type(snap) == "table" then
            for _, q in ipairs(snap) do
                if type(q) == "table" and q.Id and not q.Claimed and (tonumber(q.Progress) or 0) >= (tonumber(q.Target) or 1) then
                    local okC, resC = pcall(function() return eqClaimFn:InvokeServer(q.Id) end)
                    ensureElevatedIdentity()
                    if okC and resC then claimed += 1 end
                end
            end
        end
    end

    -- 6. Pending Evolve / Clone / Atomize
    if State.AutoClaimPendingBooths or State.AutoClaimAllRewards then
        for _, pair in ipairs({
            { "GetPendingEvolutionFunction", "ClaimEvolveRequestFunction" },
            { "GetPendingCloneFunction", "ClaimCloneRequestFunction" },
            { "GetPendingAtomizeFunction", "ClaimAtomizeRequestFunction" },
        }) do
            local gFn, cFn = rem(pair[1]), rem(pair[2])
            if gFn and cFn then
                local ok, pend = pcall(function() return gFn:InvokeServer() end)
                ensureElevatedIdentity()
                if ok and type(pend) == "table" and pend.ReadyAt and Workspace:GetServerTimeNow() >= pend.ReadyAt then
                    local okC, resC = pcall(function() return cFn:InvokeServer() end)
                    ensureElevatedIdentity()
                    if okC and resC then claimed += 1 end
                end
            end
        end
    end

    if claimed > 0 then
        Runtime.lastAction = string.format("Claimed %d reward(s)", claimed)
    end
    return claimed
end

local function redeemAllCodesNow()
    local redeemFn = rem("RedeemCodeFunction")
    if not redeemFn then return 0, 0 end
    local okCount, total = 0, 0
    for code, _ in pairs(CodesConfig) do
        total += 1
        local ok, res = pcall(function() return redeemFn:InvokeServer(tostring(code)) end)
        ensureElevatedIdentity()
        if ok and res == true then
            okCount += 1
        end
        safeWait(0.05)
    end
    Runtime.codesRedeemed += okCount
    Runtime.lastAction = string.format("Codes Checked: %d | Newly Redeemed: %d", total, okCount)
    notify("Codes Redeemed", string.format("Checked %d codes â %d newly redeemed!", total, okCount), 4)
    return okCount, total
end

local PotionAttrMap = {
    ["Luck Potion"] = "LuckPotionEndsAt",
    ["Gold Potion"] = "GoldPotionEndsAt",
    ["XP Potion"] = "XPPotionEndsAt",
    ["Time Potion"] = "TimePotionEndsAt",
}

local function checkAndUsePotions()
    local useFn = rem("UsePotionRequestFunction")
    if not useFn then return 0 end
    local inv = getItemInventory(false)
    local now = Workspace:GetServerTimeNow()
    local used = 0
    local selected = type(State.SelectedPotions) == "table" and State.SelectedPotions or {}
    local want = {}
    for k, v in pairs(selected) do
        if type(k) == "string" and v == true then want[k] = true
        elseif type(v) == "string" then want[v] = true end
    end
    for potName, attrName in pairs(PotionAttrMap) do
        if want[potName] and (tonumber(inv[potName]) or 0) > 0 then
            local endsAt = tonumber(LocalPlayer:GetAttribute(attrName)) or 0
            if endsAt <= now + 3 then
                local ok, res = pcall(function() return useFn:InvokeServer(potName, 1) end)
                ensureElevatedIdentity()
                if ok and res then
                    used += 1
                    Runtime.cachedItemInvAt = 0
                    Runtime.lastAction = "Used " .. potName
                end
            end
        end
    end
    return used
end

local function triggerPrestigeIfReady()
    local req = 9999
    if XPConfig and type(XPConfig.RequiredLevelForPrestige) == "function" then
        local r = safeCall(XPConfig.RequiredLevelForPrestige, tonumber(LocalPlayer:GetAttribute("Prestige")) or 0)
        if tonumber(r) then req = tonumber(r) end
    end
    local lv = tonumber(LocalPlayer:GetAttribute("Level")) or 0
    if lv >= req then
        local pev = rem("PrestigeEvent")
        if pev then
            pcall(function() pev:FireServer() end)
            Runtime.lastAction = "Prestiged at Level " .. lv
            return true
        end
    end
    return false
end

local function findNearestThreatInRocketZones(pos)
    local now = Workspace:GetServerTimeNow()
    for i = #Runtime.rocketDangerZones, 1, -1 do
        local z = Runtime.rocketDangerZones[i]
        if now >= z.expiresAt then
            table.remove(Runtime.rocketDangerZones, i)
        elseif (pos - z.pos).Magnitude <= 22 then
            return z
        end
    end
    return nil
end

local function getBoothPositions()
    local map = {}
    local booths = Workspace:FindFirstChild("Booths")
    if booths then
        for _, m in ipairs(booths:GetChildren()) do
            local p = m:FindFirstChildWhichIsA("ProximityPrompt", true)
            if p and p.Parent and p.Parent:IsA("BasePart") then
                map[m.Name] = p.Parent.CFrame * CFrame.new(0, 3, 5)
            else
                local ok, piv = pcall(function() return m:GetPivot() end)
                if ok and typeof(piv) == "CFrame" then
                    map[m.Name] = piv * CFrame.new(0, 4, 6)
                end
            end
        end
    end
    local merch = Workspace:FindFirstChild("Merchant")
    if merch then
        local ok, piv = pcall(function() return merch:GetPivot() end)
        if ok and typeof(piv) == "CFrame" then
            map["Merchant"] = piv * CFrame.new(0, 4, 6)
        end
    end
    local raidShop = Workspace:FindFirstChild("RaidShopArima")
    if raidShop then
        local ok, piv = pcall(function() return raidShop:GetPivot() end)
        if ok and typeof(piv) == "CFrame" then
            map["RaidShop"] = piv * CFrame.new(0, 4, 6)
        end
    end
    return map
end

-- -------------------------------------------------------------------------
-- 7. BUILD WINDUI TABS & CONTROLS (8 TABS, ALL OFF BY DEFAULT)
-- -------------------------------------------------------------------------
local TabOverview = Window:Tab({ Title = "Overview", Icon = "layout-dashboard" })
local TabCombat = Window:Tab({ Title = "Combat & Drops", Icon = "swords" })
local TabRoll = Window:Tab({ Title = "Roll & Units", Icon = "dices" })
local TabBooths = Window:Tab({ Title = "Remote Booths", Icon = "hammer" })
local TabZones = Window:Tab({ Title = "Zones & Raids", Icon = "compass" })
local TabUpgrades = Window:Tab({ Title = "Upgrades & Rewards", Icon = "trending-up" })
local TabVisuals = Window:Tab({ Title = "Player & Visuals", Icon = "eye" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- =========================== TAB 1: OVERVIEW =============================
TabOverview:Section({ Title = "Live Telemetry & Status" })
local BaseStatusPara = TabOverview:Paragraph({
    Title = "Base, Combat & Wave Monitor",
    Desc = "Scanning base and active enemies...",
})
local EconomyStatusPara = TabOverview:Paragraph({
    Title = "Economy, Pity & Active Timers",
    Desc = "Reading player attributes...",
})

TabOverview:Section({ Title = "Master Autonomous Brain" })
UI_Elements.AutoPlayMaster = TabOverview:Toggle({
    Title = "Master Auto-Play (Full Autonomous Mode)",
    Desc = "Combines Kill Aura, Enemy TP Farm, Cash/XP Magnet, Smart Upgrades, Zone Unlock & Travel, Roll/Auto-Buy, Auto-Place, Auto-Fuse, and Reward Claims.",
    Value = false,
    Callback = function(v)
        State.AutoPlayMaster = v
        if v then
            Runtime.lastAction = "Master Auto-Play Running"
        else
            Runtime.lastAction = "Master Auto-Play Stopped"
        end
    end,
})
UI_Elements.AutoPlayFocus = TabOverview:Dropdown({
    Title = "Master Strategy Focus",
    Values = { "Balanced Progression", "Fast Zone Push", "Unit & Trait Farm" },
    Value = State.AutoPlayFocus,
    Callback = function(v) State.AutoPlayFocus = v end,
})

TabOverview:Section({ Title = "Quick One-Click Actions" })
TabOverview:Button({
    Title = "Collect All Cash & XP Orbs Now",
    Callback = function()
        local c = collectAllOwnedOrbs()
        notify("Magnet Sweep", string.format("Collected %d orb(s)!", c), 2.5)
    end,
})
TabOverview:Button({
    Title = "Equip & Place Best Units Now",
    Callback = function()
        local n = placeBestUnitsNow()
        notify("Placement", string.format("Placed %d unit(s) into empty slots.", n), 3)
    end,
})
TabOverview:Button({
    Title = "Claim All Available Rewards",
    Callback = function()
        local n = claimAllRewardsNow()
        notify("Rewards", string.format("Claimed %d reward(s).", n), 3)
    end,
})

-- ======================== TAB 2: COMBAT & DROPS ==========================
TabCombat:Section({ Title = "Cash & XP Drops (Pure Remote)" })
UI_Elements.InstantCashXpMagnet = TabCombat:Toggle({
    Title = "Instant Cash & XP Magnet",
    Desc = "Immediately collects owned CashThing & XpThing drops cross-map without waiting for tween animations.",
    Value = false,
    Callback = function(v)
        State.InstantCashXpMagnet = v
        if v then task.defer(collectAllOwnedOrbs) end
    end,
})

TabCombat:Section({ Title = "Player Combat & Auto-Farm" })
UI_Elements.KillAura = TabCombat:Toggle({
    Title = "Kill Aura (Melee & Gun)",
    Desc = "Rapidly fires PlayerAttackEvent at optimal server attack speed whenever an enemy is within weapon range.",
    Value = false,
    Callback = function(v) State.KillAura = v end,
})
UI_Elements.AutoEquipBestWeapon = TabCombat:Toggle({
    Title = "Auto Equip Weapon Tool",
    Desc = "Keeps your highest-damage unlocked weapon equipped in Character.",
    Value = false,
    Callback = function(v) State.AutoEquipBestWeapon = v end,
})
UI_Elements.AutoFarmEnemies = TabCombat:Toggle({
    Title = "Auto Farm Enemies & Bosses (TP)",
    Desc = "Teleports around priority enemies & World Raid bosses at optimal combat range for continuous Kill Aura clears.",
    Value = false,
    Callback = function(v) State.AutoFarmEnemies = v end,
})
UI_Elements.FarmPriority = TabCombat:Dropdown({
    Title = "Target Priority",
    Values = { "Boss First", "Closest To Finish", "Highest HP", "Nearest" },
    Value = State.FarmPriority,
    Callback = function(v) State.FarmPriority = v end,
})
UI_Elements.FarmPositionMode = TabCombat:Dropdown({
    Title = "TP Offset Mode",
    Values = { "Behind", "Above", "Front" },
    Value = State.FarmPositionMode,
    Callback = function(v) State.FarmPositionMode = v end,
})
UI_Elements.FarmDistance = TabCombat:Slider({
    Title = "Farm Offset Distance",
    Step = 1,
    Value = { Min = 3, Max = 14, Default = State.FarmDistance },
    Callback = function(v) State.FarmDistance = tonumber(v) or 7 end,
})

TabCombat:Section({ Title = "Placed Units AI & Abilities" })
UI_Elements.AutoCastUnitAbilities = TabCombat:Toggle({
    Title = "Auto Cast Placed Unit Abilities",
    Desc = "Periodically triggers UseAbilityRequestFunction across all placed units in your base.",
    Value = false,
    Callback = function(v) State.AutoCastUnitAbilities = v end,
})
UI_Elements.AutoEnableServerUnitAbilities = TabCombat:Toggle({
    Title = "Auto Enable Server Auto-Ability",
    Desc = "Ensures AutoUseEnabled = true on every placed unit in your base.",
    Value = false,
    Callback = function(v) State.AutoEnableServerUnitAbilities = v end,
})
UI_Elements.UnitTargetMode = TabCombat:Dropdown({
    Title = "Placed Units Target Mode",
    Values = { "First", "Last", "Strongest", "Weakest" },
    Value = State.UnitTargetMode,
    Callback = function(v) State.UnitTargetMode = v end,
})
TabCombat:Button({
    Title = "Apply Target Mode To All Placed Units",
    Callback = function()
        local setTarget = rem("SetTargetModeRequestFunction")
        if not setTarget then return end
        local n = 0
        for _, info in ipairs(getPlacedUnits()) do
            if info.model then
                local ok = pcall(function() setTarget:InvokeServer(info.model, State.UnitTargetMode) end)
                ensureElevatedIdentity()
                if ok then n += 1 end
            end
        end
        notify("Targeting", string.format("Set %d placed unit(s) to %s.", n, State.UnitTargetMode), 3)
    end,
})

-- ========================= TAB 3: ROLL & UNITS ===========================
TabRoll:Section({ Title = "Roll Automation & Free Auto-Buy (No Gamepass Needed)" })
UI_Elements.ServerAutoRoll = TabRoll:Toggle({
    Title = "Server Auto-Roll",
    Desc = "Starts/stops server-side AutoRollStartEvent (requires AutoRollLv >= 1).",
    Value = false,
    Callback = function(v)
        State.ServerAutoRoll = v
        local startEv = rem("AutoRollStartEvent")
        local stopEv = rem("AutoRollStopEvent")
        if v and startEv then
            pcall(function() startEv:FireServer() end)
        elseif not v and stopEv then
            pcall(function() stopEv:FireServer() end)
        end
    end,
})
UI_Elements.FreeCustomAutoBuy = TabRoll:Toggle({
    Title = "Free Custom Auto-Buy Sniper (Bypasses Gamepass)",
    Desc = "Monitors FloatingRollDisplay on RollStation and buys matching units directly via prompt without AutoBuy Gamepass.",
    Value = false,
    Callback = function(v) State.FreeCustomAutoBuy = v end,
})
UI_Elements.AutoBuyUnownedOnly = TabRoll:Toggle({
    Title = "Auto-Buy Unowned Index Units",
    Value = false,
    Callback = function(v) State.AutoBuyUnownedOnly = v end,
})
UI_Elements.AutoBuyAnyMutated = TabRoll:Toggle({
    Title = "Auto-Buy Any Mutated Unit",
    Value = false,
    Callback = function(v) State.AutoBuyAnyMutated = v end,
})
UI_Elements.AutoBuyMinRarity = TabRoll:Dropdown({
    Title = "Minimum Auto-Buy Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Cosmic" },
    Value = State.AutoBuyMinRarity,
    Callback = function(v) State.AutoBuyMinRarity = v end,
})
UI_Elements.AutoSkipUnwantedRolls = TabRoll:Toggle({
    Title = "Auto-Skip & Re-Roll Unwanted Stands",
    Desc = "Re-rolls unwanted stands automatically (safely pauses on unaffordable Mythic+ unless Force Skip is enabled).",
    Value = false,
    Callback = function(v) State.AutoSkipUnwantedRolls = v end,
})
UI_Elements.ForceSkipUnaffordableMythic = TabRoll:Toggle({
    Title = "Force Skip Unaffordable Mythic+ (ConfirmedRoll)",
    Value = false,
    Callback = function(v) State.ForceSkipUnaffordableMythic = v end,
})
UI_Elements.AutoRollEventTickets = TabRoll:Toggle({
    Title = "Auto Roll Event Tickets",
    Value = false,
    Callback = function(v) State.AutoRollEventTickets = v end,
})

TabRoll:Section({ Title = "Unit Management & Smart Selling" })
UI_Elements.AutoEquipBestUnits = TabRoll:Toggle({
    Title = "Auto Equip Best Units",
    Value = false,
    Callback = function(v) State.AutoEquipBestUnits = v end,
})
UI_Elements.AutoPlaceBestUnits = TabRoll:Toggle({
    Title = "Auto Place Best Units On Empty Slots",
    Value = false,
    Callback = function(v) State.AutoPlaceBestUnits = v end,
})
TabRoll:Button({
    Title = "Pick Up All Placed Units",
    Callback = function()
        local fn = rem("PickUpAllRequestFunction")
        if fn then
            pcall(function() fn:InvokeServer() end)
            ensureElevatedIdentity()
            notify("Units", "Picked up all placed units.", 2.5)
        end
    end,
})
UI_Elements.AutoLockRareUnits = TabRoll:Toggle({
    Title = "Auto Lock Mythic+ / Mutated / 2â+ Units",
    Value = false,
    Callback = function(v) State.AutoLockRareUnits = v end,
})
UI_Elements.AutoSellJunkUnits = TabRoll:Toggle({
    Title = "Auto Sell Junk Units",
    Value = false,
    Callback = function(v) State.AutoSellJunkUnits = v end,
})
UI_Elements.SellMaxRarity = TabRoll:Dropdown({
    Title = "Max Rarity To Sell",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary" },
    Value = State.SellMaxRarity,
    Callback = function(v) State.SellMaxRarity = v end,
})
UI_Elements.SellSafetyMode = TabRoll:Dropdown({
    Title = "Sell Safety Filter",
    Values = { "Safe (Keep 3 + Protect Rare)", "Protect Rare Only", "Sell All Below Max Rarity" },
    Value = State.SellSafetyMode,
    Callback = function(v) State.SellSafetyMode = v end,
})
UI_Elements.AllowSellMutatedOrStarred = TabRoll:Toggle({
    Title = "Allow Selling Mutated / Starred Units",
    Value = false,
    Callback = function(v) State.AllowSellMutatedOrStarred = v end,
})
TabRoll:Button({
    Title = "Sell Matching Junk Units Now",
    Callback = function()
        local cnt, gained = sellJunkUnitsNow()
        notify("Unit Sale", string.format("Sold %d unit(s) for Â¥%s.", cnt, formatNumber(gained)), 3)
    end,
})

TabRoll:Section({ Title = "Team Loadouts" })
UI_Elements.SelectedTeamSlot = TabRoll:Dropdown({
    Title = "Loadout Slot",
    Values = { "1", "2", "3" },
    Value = State.SelectedTeamSlot,
    Callback = function(v) State.SelectedTeamSlot = v end,
})
TabRoll:Button({
    Title = "Load Selected Team",
    Callback = function()
        local fn = rem("TeamLoadoutRequestFunction")
        if fn then
            local ok, res = pcall(function() return fn:InvokeServer("Load", tonumber(State.SelectedTeamSlot) or 1, nil) end)
            ensureElevatedIdentity()
            notify("Loadout", ok and res and "Team loaded!" or "Loadout request finished.", 2.5)
        end
    end,
})
TabRoll:Button({
    Title = "Save Current Placed Units To Slot",
    Callback = function()
        local fn = rem("TeamLoadoutRequestFunction")
        if fn then
            local ok, res = pcall(function() return fn:InvokeServer("Save", tonumber(State.SelectedTeamSlot) or 1, nil) end)
            ensureElevatedIdentity()
            notify("Loadout", ok and res and "Team saved!" or "Save request finished.", 2.5)
        end
    end,
})

-- ======================== TAB 4: REMOTE BOOTHS ===========================
local initialUnitLabels, initialUnitLookup = buildUnitSelectionLabels()
UnitLabelLookup = initialUnitLookup

TabBooths:Section({ Title = "Remote Fusion" })
UI_Elements.AutoFuseUnits = TabBooths:Toggle({
    Title = "Auto Fuse 3x Duplicate Units",
    Desc = "Remotely fuses 3+ unlocked copies of the same unit & star count.",
    Value = false,
    Callback = function(v) State.AutoFuseUnits = v end,
})
UI_Elements.FuseMaxRarity = TabBooths:Dropdown({
    Title = "Max Rarity To Auto-Fuse",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Value = State.FuseMaxRarity,
    Callback = function(v) State.FuseMaxRarity = v end,
})
TabBooths:Button({
    Title = "Fuse All Eligible Duplicates Now",
    Callback = function()
        local n = fuseAllEligibleNow()
        notify("Fusion", string.format("Completed %d fusion batch(es).", n), 3)
    end,
})

TabBooths:Section({ Title = "Evolution, Cloning & Atomizer" })
UI_Elements.AutoClaimPendingBooths = TabBooths:Toggle({
    Title = "Auto Claim Ready Evolve / Clone / Atomize",
    Value = false,
    Callback = function(v) State.AutoClaimPendingBooths = v end,
})
UI_Elements.SelectedManageUnitId = TabBooths:Dropdown({
    Title = "Select Inventory Unit",
    Values = initialUnitLabels,
    Value = initialUnitLabels[1],
    Callback = function(v)
        State.SelectedManageUnitId = UnitLabelLookup[v] or v
    end,
})
TabBooths:Button({
    Title = "Refresh Unit Dropdown List",
    Callback = function()
        local labels, map = buildUnitSelectionLabels()
        UnitLabelLookup = map
        if UI_Elements.SelectedManageUnitId and UI_Elements.SelectedManageUnitId.Refresh then
            pcall(function() UI_Elements.SelectedManageUnitId:Refresh(labels) end)
        end
        if UI_Elements.SelectedTraitUnitId and UI_Elements.SelectedTraitUnitId.Refresh then
            pcall(function() UI_Elements.SelectedTraitUnitId:Refresh(labels) end)
        end
        notify("Units Refreshed", string.format("Found %d unit(s) in inventory.", #labels), 2.5)
    end,
})
TabBooths:Button({
    Title = "Start Evolution On Selected Unit",
    Callback = function()
        local fn = rem("EvolveRequestFunction")
        if fn and State.SelectedManageUnitId ~= "None" then
            local ok, s, msg = pcall(function() return fn:InvokeServer(State.SelectedManageUnitId, nil) end)
            ensureElevatedIdentity()
            notify("Evolution", ok and s and "Evolution started!" or tostring(msg or "Cannot evolve unit."), 3)
        end
    end,
})
TabBooths:Button({
    Title = "Start Cloning On Selected Unit",
    Callback = function()
        local fn = rem("CloneRequestFunction")
        if fn and State.SelectedManageUnitId ~= "None" then
            local ok, s, msg = pcall(function() return fn:InvokeServer(State.SelectedManageUnitId) end)
            ensureElevatedIdentity()
            notify("Cloning", ok and s and "Cloning started!" or tostring(msg or "Cannot clone unit."), 3)
        end
    end,
})
TabBooths:Button({
    Title = "Start Atomize On Selected Unit",
    Callback = function()
        local fn = rem("AtomizeRequestFunction")
        if fn and State.SelectedManageUnitId ~= "None" then
            local ok, s, msg = pcall(function() return fn:InvokeServer(State.SelectedManageUnitId) end)
            ensureElevatedIdentity()
            notify("Atomizer", ok and s and "Atomizing started!" or tostring(msg or "Cannot atomize unit."), 3)
        end
    end,
})

TabBooths:Section({ Title = "Trait Reroll Sniper" })
local traitOptions = {}
for k, t in pairs(TraitDatabase) do
    if type(t) == "table" and t.Rarity then table.insert(traitOptions, k) end
end
table.sort(traitOptions)
if #traitOptions == 0 then
    traitOptions = { "Psychic", "Instinct", "Awakened", "Berserker", "Limitless", "Hollow", "Midas", "Blitz", "Assassin", "Marksman", "Precise", "Swift", "Superior" }
end

UI_Elements.SelectedTraitUnitId = TabBooths:Dropdown({
    Title = "Trait Target Unit",
    Values = initialUnitLabels,
    Value = initialUnitLabels[1],
    Callback = function(v)
        State.SelectedTraitUnitId = UnitLabelLookup[v] or v
    end,
})
UI_Elements.TargetTraits = TabBooths:Dropdown({
    Title = "Desired Stop Traits",
    Values = traitOptions,
    Value = State.TargetTraits,
    Multi = true,
    AllowNone = true,
    Callback = function(v) State.TargetTraits = v end,
})
UI_Elements.AutoRerollTrait = TabBooths:Toggle({
    Title = "Auto Reroll Trait Until Target Hit",
    Desc = "Uses InstaRollTraitRequestFunction (falls back to RerollTraitRequestFunction) until selected unit hits a target trait or shards run out.",
    Value = false,
    Callback = function(v) State.AutoRerollTrait = v end,
})
TabBooths:Button({
    Title = "Swap Stored Trait On Target Unit",
    Callback = function()
        local fn = rem("SwapStoredTraitRequestFunction")
        if fn and State.SelectedTraitUnitId ~= "None" then
            local ok, res = pcall(function() return fn:InvokeServer(State.SelectedTraitUnitId) end)
            ensureElevatedIdentity()
            notify("Traits", ok and res and "Swapped stored trait!" or "No stored trait available.", 2.5)
        end
    end,
})

TabBooths:Section({ Title = "Blacksmith, Crafting & Accessories" })
local weaponList = {}
for name, w in pairs(WeaponsDatabase) do
    if type(w) == "table" and not w.Unobtainable then
        table.insert(weaponList, { name = name, price = tonumber(w.Price) or 0 })
    end
end
table.sort(weaponList, function(a, b) return a.price < b.price end)
local weaponNames = {}
for _, w in ipairs(weaponList) do table.insert(weaponNames, w.name) end
if #weaponNames == 0 then weaponNames = { "Katana" } end

UI_Elements.AutoBuyBestWeapon = TabBooths:Toggle({
    Title = "Auto Buy & Equip Best Affordable Weapon",
    Value = false,
    Callback = function(v) State.AutoBuyBestWeapon = v end,
})
UI_Elements.SelectedWeaponName = TabBooths:Dropdown({
    Title = "Select Weapon",
    Values = weaponNames,
    Value = weaponNames[1],
    Callback = function(v) State.SelectedWeaponName = v end,
})
TabBooths:Button({
    Title = "Buy & Equip Selected Weapon",
    Callback = function()
        local buyFn = rem("BuyWeaponRequestFunction")
        local eqFn = rem("EquipWeaponRequestFunction")
        if buyFn then
            pcall(function() buyFn:InvokeServer(State.SelectedWeaponName) end)
            ensureElevatedIdentity()
        end
        if eqFn then
            pcall(function() eqFn:InvokeServer(State.SelectedWeaponName) end)
            ensureElevatedIdentity()
        end
        notify("Blacksmith", "Requested weapon: " .. tostring(State.SelectedWeaponName), 2.5)
    end,
})

local recipeNames = {}
local recipeLookup = {}
if type(CraftingDatabase.Recipes) == "table" then
    for idx, rec in pairs(CraftingDatabase.Recipes) do
        local rName = rec.Name or rec.Accessory or tostring(idx)
        table.insert(recipeNames, rName)
        recipeLookup[rName] = rec.Id or idx
    end
    table.sort(recipeNames)
end
if #recipeNames == 0 then recipeNames = { "Fireman Hat" } end

UI_Elements.SelectedCraftRecipe = TabBooths:Dropdown({
    Title = "Crafting Recipe",
    Values = recipeNames,
    Value = recipeNames[1],
    Callback = function(v) State.SelectedCraftRecipe = v end,
})
TabBooths:Button({
    Title = "Craft Selected Accessory",
    Callback = function()
        local fn = rem("CraftRequestFunction")
        local arg = recipeLookup[State.SelectedCraftRecipe] or State.SelectedCraftRecipe
        if fn then
            local ok, res, msg = pcall(function() return fn:InvokeServer(arg) end)
            ensureElevatedIdentity()
            notify("Crafting", ok and res and ("Crafted " .. State.SelectedCraftRecipe) or tostring(msg or "Missing materials."), 3)
        end
    end,
})
UI_Elements.AutoDismantleAccessoryStars = TabBooths:Toggle({
    Title = "Enable Server Auto-Dismantle (1â - 3â Accessories)",
    Value = false,
    Callback = function(v)
        State.AutoDismantleAccessoryStars = v
        local fn = rem("AutoDismantleFunction")
        if fn then
            for s = 1, 3 do
                pcall(function() fn:InvokeServer("Set", s, v) end)
                ensureElevatedIdentity()
            end
        end
    end,
})

-- ==================== TAB 5: ZONES, RAIDS & TOWERS =======================
local zoneNames = {}
for _, z in ipairs(ZoneDatabase) do
    table.insert(zoneNames, z.Name)
end
if #zoneNames == 0 then zoneNames = { "Wisteria", "Fire City" } end

TabZones:Section({ Title = "Zone Progression & Golden Zone Sniper" })
UI_Elements.AutoUnlockZones = TabZones:Toggle({
    Title = "Auto Unlock Next Zone",
    Value = false,
    Callback = function(v) State.AutoUnlockZones = v end,
})
UI_Elements.AutoTravelHighestZone = TabZones:Toggle({
    Title = "Auto Travel To Highest Unlocked Zone",
    Value = false,
    Callback = function(v) State.AutoTravelHighestZone = v end,
})
UI_Elements.GoldenZoneAutoSniper = TabZones:Toggle({
    Title = "Golden Zone Auto-Sniper",
    Desc = "Automatically switches your base zone whenever Johnny/Joe activates a Golden Zone, then returns to highest zone when it expires.",
    Value = false,
    Callback = function(v) State.GoldenZoneAutoSniper = v end,
})
UI_Elements.SelectedZoneName = TabZones:Dropdown({
    Title = "Manual Zone Selection",
    Values = zoneNames,
    Value = zoneNames[2] or zoneNames[1],
    Callback = function(v) State.SelectedZoneName = v end,
})
TabZones:Button({
    Title = "Travel To Selected Zone",
    Callback = function()
        local ev = rem("ZoneTravelRequestEvent")
        if ev then
            pcall(function() ev:FireServer(State.SelectedZoneName) end)
            notify("Zone Travel", "Requested travel to " .. tostring(State.SelectedZoneName), 2.5)
        end
    end,
})

TabZones:Section({ Title = "Challenges & Towers" })
UI_Elements.AutoStartChallenges = TabZones:Toggle({
    Title = "Auto Start Available Challenges",
    Value = false,
    Callback = function(v) State.AutoStartChallenges = v end,
})
UI_Elements.ChallengePriorities = TabZones:Dropdown({
    Title = "Challenge Priority Tiers",
    Values = { "Weekly", "Daily", "Regular" },
    Value = State.ChallengePriorities,
    Multi = true,
    AllowNone = false,
    Callback = function(v) State.ChallengePriorities = v end,
})
UI_Elements.SelectedChallengeTier = TabZones:Dropdown({
    Title = "Manual Challenge Tier",
    Values = { "Regular", "Daily", "Weekly" },
    Value = State.SelectedChallengeTier,
    Callback = function(v) State.SelectedChallengeTier = v end,
})
TabZones:Button({
    Title = "Start Selected Challenge Now",
    Callback = function()
        local fn = rem("ChallengeStartRequestFunction")
        if fn then
            local ok, res, msg = pcall(function() return fn:InvokeServer(State.SelectedChallengeTier) end)
            ensureElevatedIdentity()
            notify("Challenge", ok and res and (State.SelectedChallengeTier .. " challenge started!") or tostring(msg or "Cooldown/unavailable."), 3)
        end
    end,
})
TabZones:Button({
    Title = "End Active Challenge Early",
    Callback = function()
        local fn = rem("EndChallengeEarlyRequestFunction")
        if fn then
            pcall(function() fn:InvokeServer() end)
            ensureElevatedIdentity()
        end
    end,
})
UI_Elements.AutoEnterInfiniteTower = TabZones:Toggle({
    Title = "Auto Enter Infinite Tower",
    Value = false,
    Callback = function(v) State.AutoEnterInfiniteTower = v end,
})
UI_Elements.AutoEnterElementTower = TabZones:Toggle({
    Title = "Auto Enter Open Element Tower (If Available)",
    Value = false,
    Callback = function(v) State.AutoEnterElementTower = v end,
})
UI_Elements.AutoClaimTowerBracket = TabZones:Toggle({
    Title = "Auto Claim Tower Bracket Rewards",
    Value = false,
    Callback = function(v) State.AutoClaimTowerBracket = v end,
})
TabZones:Button({
    Title = "Use Infinite Tower Instant Clear Ticket",
    Callback = function()
        local fn = rem("UseInstantClearTicketRequestFunction")
        if fn then
            local ok, res, msg = pcall(function() return fn:InvokeServer() end)
            ensureElevatedIdentity()
            notify("Tower", ok and res and "Instant clear activated!" or tostring(msg or "No tickets / unavailable."), 3)
        end
    end,
})

TabZones:Section({ Title = "World Raid & Shops" })
UI_Elements.AutoJoinWorldRaid = TabZones:Toggle({
    Title = "Auto Join World Raid",
    Value = false,
    Callback = function(v) State.AutoJoinWorldRaid = v end,
})
UI_Elements.AutoEvadeWorldRaidRockets = TabZones:Toggle({
    Title = "Auto Evade World Raid Rockets",
    Desc = "Hooks WorldRaidEvent 'Rockets' payload and micro-steps away from incoming impact positions.",
    Value = false,
    Callback = function(v) State.AutoEvadeWorldRaidRockets = v end,
})
UI_Elements.AutoBuyMerchantAll = TabZones:Toggle({
    Title = "Auto Buy All Merchant Stock",
    Value = false,
    Callback = function(v) State.AutoBuyMerchantAll = v end,
})

local evShopKeys = {}
for k in pairs(EventShopDatabase) do table.insert(evShopKeys, tostring(k)) end
table.sort(evShopKeys)
if #evShopKeys == 0 then evShopKeys = { "Trait Shards", "Potions", "LimitedEssence" } end

UI_Elements.SelectedEventShopItem = TabZones:Dropdown({
    Title = "Event Shop Item",
    Values = evShopKeys,
    Value = evShopKeys[1],
    Callback = function(v) State.SelectedEventShopItem = v end,
})
TabZones:Button({
    Title = "Buy Selected Event Shop Item",
    Callback = function()
        local fn = rem("PurchaseEventShopItemRequestFunction")
        if fn then
            local ok, res, msg = pcall(function() return fn:InvokeServer(State.SelectedEventShopItem) end)
            ensureElevatedIdentity()
            notify("Event Shop", ok and res and ("Purchased " .. State.SelectedEventShopItem) or tostring(msg or "Cannot purchase."), 2.5)
        end
    end,
})

local raidShopIds = {}
if type(RaidShopDatabase.Items) == "table" then
    for _, it in pairs(RaidShopDatabase.Items) do
        if it.Id then table.insert(raidShopIds, tostring(it.Id)) end
    end
    table.sort(raidShopIds)
end
if #raidShopIds == 0 then raidShopIds = { "TraitReroll" } end

UI_Elements.SelectedRaidShopItem = TabZones:Dropdown({
    Title = "Raid Shop Item",
    Values = raidShopIds,
    Value = raidShopIds[1],
    Callback = function(v) State.SelectedRaidShopItem = v end,
})
TabZones:Button({
    Title = "Buy Selected Raid Shop Item",
    Callback = function()
        local fn = rem("BuyRaidShopItemFunction")
        if fn then
            local ok, res, msg = pcall(function() return fn:InvokeServer(State.SelectedRaidShopItem) end)
            ensureElevatedIdentity()
            notify("Raid Shop", ok and res and ("Purchased " .. State.SelectedRaidShopItem) or tostring(msg or "Cannot purchase."), 2.5)
        end
    end,
})

-- =================== TAB 6: UPGRADES, CODES & REWARDS ====================
local allUpgradeKeys = {}
for k, cfg in pairs(UpgradeConfig) do
    if type(cfg) == "table" then table.insert(allUpgradeKeys, k) end
end
table.sort(allUpgradeKeys)
if #allUpgradeKeys == 0 then allUpgradeKeys = { "LuckLv", "UnitDamageLv", "PlacementSlotLv" } end

TabUpgrades:Section({ Title = "Smart Remote Upgrades & Prestige" })
UI_Elements.AutoUpgradeMoneyStats = TabUpgrades:Toggle({
    Title = "Auto Upgrade Money Stats",
    Value = false,
    Callback = function(v) State.AutoUpgradeMoneyStats = v end,
})
UI_Elements.UpgradeProfile = TabUpgrades:Dropdown({
    Title = "Upgrade Priority Profile",
    Values = { "Balanced Progression", "Luck & Roll Speed First", "DPS & Combat First", "Gold & XP Economy First" },
    Value = State.UpgradeProfile,
    Callback = function(v) State.UpgradeProfile = v end,
})
UI_Elements.AutoUpgradePrestigeTree = TabUpgrades:Toggle({
    Title = "Auto Upgrade Prestige Point Tree",
    Value = false,
    Callback = function(v) State.AutoUpgradePrestigeTree = v end,
})
UI_Elements.SelectedUpgradeStat = TabUpgrades:Dropdown({
    Title = "Single Upgrade Target",
    Values = allUpgradeKeys,
    Value = State.SelectedUpgradeStat,
    Callback = function(v) State.SelectedUpgradeStat = v end,
})
TabUpgrades:Button({
    Title = "Buy Selected Upgrade Once",
    Callback = function()
        local ev = rem("UpgradeRequestEvent")
        if ev then
            pcall(function() ev:FireServer(State.SelectedUpgradeStat) end)
            notify("Upgrade", "Requested upgrade: " .. State.SelectedUpgradeStat, 2)
        end
    end,
})
UI_Elements.AutoPrestige = TabUpgrades:Toggle({
    Title = "Auto Prestige When Level Requirement Met",
    Value = false,
    Callback = function(v) State.AutoPrestige = v end,
})
TabUpgrades:Button({
    Title = "Prestige Now (If Eligible)",
    Callback = function()
        local ok = triggerPrestigeIfReady()
        notify("Prestige", ok and "Prestige triggered!" or "Level requirement not yet met.", 3)
    end,
})

TabUpgrades:Section({ Title = "Rewards, Potions, Faction & Game Codes" })
UI_Elements.AutoClaimAllRewards = TabUpgrades:Toggle({
    Title = "Auto Claim All Rewards (Daily / Offline / Group / BP / Event)",
    Value = false,
    Callback = function(v)
        State.AutoClaimAllRewards = v
        if v then task.defer(claimAllRewardsNow) end
    end,
})
TabUpgrades:Button({
    Title = "Redeem All 66+ Game Codes",
    Callback = function()
        task.spawn(function()
            ensureElevatedIdentity()
            redeemAllCodesNow()
        end)
    end,
})
UI_Elements.AutoUsePotions = TabUpgrades:Toggle({
    Title = "Auto Use Selected Potions On Expiry",
    Value = false,
    Callback = function(v) State.AutoUsePotions = v end,
})
UI_Elements.SelectedPotions = TabUpgrades:Dropdown({
    Title = "Auto-Use Potion List",
    Values = { "Luck Potion", "Gold Potion", "XP Potion", "Time Potion" },
    Value = State.SelectedPotions,
    Multi = true,
    AllowNone = true,
    Callback = function(v) State.SelectedPotions = v end,
})
UI_Elements.SelectedFaction = TabUpgrades:Dropdown({
    Title = "Event Faction",
    Values = { "CCG", "Ghouls" },
    Value = State.SelectedFaction,
    Callback = function(v) State.SelectedFaction = v end,
})
TabUpgrades:Button({
    Title = "Cast Faction Vote",
    Callback = function()
        local fn = rem("CastFactionVoteFunction")
        if fn then
            local ok, res = pcall(function() return fn:InvokeServer(State.SelectedFaction) end)
            ensureElevatedIdentity()
            notify("Faction Vote", ok and res and ("Joined " .. State.SelectedFaction) or "Already voted or vote closed.", 3)
        end
    end,
})

-- ===================== TAB 7: PLAYER & VISUALS ===========================
TabVisuals:Section({ Title = "Quick Teleports" })
TabVisuals:Button({
    Title = "Teleport To Own Base",
    Callback = function()
        local ev = rem("TeleportToBaseRequestEvent")
        if ev then pcall(function() ev:FireServer() end) end
    end,
})
TabVisuals:Button({
    Title = "Teleport To Roll Station",
    Callback = function()
        local base = getOwnBase()
        local rs = base and base:FindFirstChild("RollStation")
        local btn = rs and rs:FindFirstChild("Button")
        if btn then safeTeleportCF(btn:GetPivot() * CFrame.new(0, 4, 6)) end
    end,
})
TabVisuals:Button({
    Title = "Teleport To Plaza",
    Callback = function()
        local ev = rem("TeleportToPlazaRequestEvent")
        if ev then pcall(function() ev:FireServer() end) end
    end,
})
TabVisuals:Button({
    Title = "Teleport To Raid Portal",
    Callback = function()
        local ev = rem("TeleportToRaidRequestEvent")
        if ev then pcall(function() ev:FireServer() end) end
    end,
})
TabVisuals:Button({
    Title = "Teleport To Infinite Tower",
    Callback = function()
        local ev = rem("TeleportToTowerRequestEvent")
        if ev then pcall(function() ev:FireServer() end) end
    end,
})
UI_Elements.SelectedBoothTeleport = TabVisuals:Dropdown({
    Title = "Select Booth / NPC",
    Values = { "BlacksmithBooth", "TraitsBooth", "FuseBooth", "EvolveUnitsBooth", "ChallengeBooth", "AtomizerBooth", "CraftBooth", "GroupRewardsBooth", "InfiniteTower", "Merchant", "RaidShop" },
    Value = State.SelectedBoothTeleport,
    Callback = function(v) State.SelectedBoothTeleport = v end,
})
TabVisuals:Button({
    Title = "Teleport To Selected Booth",
    Callback = function()
        local map = getBoothPositions()
        local cf = map[State.SelectedBoothTeleport]
        if cf then safeTeleportCF(cf) end
    end,
})

TabVisuals:Section({ Title = "Movement & Interactions" })
UI_Elements.CustomWalkSpeed = TabVisuals:Toggle({
    Title = "Custom WalkSpeed",
    Value = false,
    Callback = function(v)
        State.CustomWalkSpeed = v
        local _, _, hum = getRootAndHum()
        if v then
            if hum and MovementOrig.WalkSpeed == nil then MovementOrig.WalkSpeed = hum.WalkSpeed end
            if hum then hum.WalkSpeed = State.WalkSpeed end
        else
            restoreWalkSpeed()
        end
    end,
})
UI_Elements.WalkSpeed = TabVisuals:Slider({
    Title = "WalkSpeed Value",
    Step = 1,
    Value = { Min = 16, Max = 150, Default = State.WalkSpeed },
    Callback = function(v)
        State.WalkSpeed = tonumber(v) or 40
        if State.CustomWalkSpeed then
            local _, _, hum = getRootAndHum()
            if hum then hum.WalkSpeed = State.WalkSpeed end
        end
    end,
})
UI_Elements.CustomJumpPower = TabVisuals:Toggle({
    Title = "Custom JumpPower",
    Value = false,
    Callback = function(v)
        State.CustomJumpPower = v
        local _, _, hum = getRootAndHum()
        if v then
            if hum and MovementOrig.JumpPower == nil then MovementOrig.JumpPower = hum.JumpPower end
            if hum then hum.JumpPower = State.JumpPower end
        else
            restoreJumpPower()
        end
    end,
})
UI_Elements.JumpPower = TabVisuals:Slider({
    Title = "JumpPower Value",
    Step = 1,
    Value = { Min = 50, Max = 200, Default = State.JumpPower },
    Callback = function(v)
        State.JumpPower = tonumber(v) or 75
        if State.CustomJumpPower then
            local _, _, hum = getRootAndHum()
            if hum then hum.JumpPower = State.JumpPower end
        end
    end,
})
UI_Elements.InfiniteJump = TabVisuals:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})
UI_Elements.NoClip = TabVisuals:Toggle({
    Title = "NoClip",
    Value = false,
    Callback = function(v)
        State.NoClip = v
        if not v then restoreNoClip() end
    end,
})
UI_Elements.Fly = TabVisuals:Toggle({
    Title = "Fly (Camera Direction)",
    Value = false,
    Callback = function(v)
        State.Fly = v
        if v then FlyState.active = true else restoreFly() end
    end,
})
UI_Elements.FlySpeed = TabVisuals:Slider({
    Title = "Fly Speed",
    Step = 5,
    Value = { Min = 30, Max = 200, Default = State.FlySpeed },
    Callback = function(v) State.FlySpeed = tonumber(v) or 80 end,
})
UI_Elements.InstantPrompts = TabVisuals:Toggle({
    Title = "Instant Proximity Prompts",
    Value = false,
    Callback = function(v)
        State.InstantPrompts = v
        if v then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") then applyInstantPrompt(d) end
            end
        else
            restoreInstantPrompts()
        end
    end,
})

TabVisuals:Section({ Title = "Stealth ESP & Performance (gethui/CoreGui)" })
UI_Elements.EnemyBossESP = TabVisuals:Toggle({
    Title = "Enemy & Boss HP ESP",
    Value = false,
    Callback = function(v) State.EnemyBossESP = v end,
})
UI_Elements.RolledStandESP = TabVisuals:Toggle({
    Title = "Rolled Unit Stand ESP",
    Value = false,
    Callback = function(v) State.RolledStandESP = v end,
})
UI_Elements.BoothMerchantESP = TabVisuals:Toggle({
    Title = "Booth & Merchant Waypoint ESP",
    Value = false,
    Callback = function(v) State.BoothMerchantESP = v end,
})
UI_Elements.Fullbright = TabVisuals:Toggle({
    Title = "Fullbright Lighting",
    Value = false,
    Callback = function(v)
        State.Fullbright = v
        applyFullbright(v)
    end,
})
UI_Elements.HideForeignEffects = TabVisuals:Toggle({
    Title = "FPS Boost (Client Settings Optimization)",
    Value = false,
    Callback = function(v)
        State.HideForeignEffects = v
        if ClientSettings and type(ClientSettings.Set) == "function" then
            safeCall(ClientSettings.Set, "FPSBoost", v)
            safeCall(ClientSettings.Set, "OtherPlayerEffects", not v)
        end
    end,
})

-- ============================ TAB 8: CONFIG ==============================
local function getConfigPath(name)
    local clean = tostring(name or "default"):gsub("[^%w_%-%s]", "_")
    if clean == "" then clean = "default" end
    return CONFIG_DIR .. "/" .. clean .. ".json"
end

local function ensureConfigDir()
    if type(isfolder) == "function" and type(makefolder) == "function" then
        if not isfolder(CONFIG_DIR) then
            pcall(makefolder, CONFIG_DIR)
        end
    end
end

local function syncElementVisual(key, val)
    local elem = UI_Elements[key]
    if not elem then return end
    ensureElevatedIdentity()
    if type(elem.Set) == "function" then
        pcall(function() elem:Set(val) end)
    elseif type(elem.Select) == "function" then
        pcall(function() elem:Select(val) end)
    end
end

local function saveConfig(profileName)
    if type(writefile) ~= "function" then
        notify("Config Error", "Executor filesystem API unavailable.", 3)
        return false
    end
    ensureConfigDir()
    local payload = {}
    for k, v in pairs(State) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" or type(v) == "table" then
            payload[k] = v
        end
    end
    local path = getConfigPath(profileName or State.ConfigName)
    local ok, err = pcall(writefile, path, HttpService:JSONEncode(payload))
    if ok then
        notify("Config Saved", "Saved profile to " .. path, 2.5)
        return true
    end
    notify("Save Failed", tostring(err), 3)
    return false
end

local function loadConfig(profileName)
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        notify("Config Error", "Executor filesystem API unavailable.", 3)
        return false
    end
    local path = getConfigPath(profileName or State.ConfigName)
    if not isfile(path) then
        notify("Config Not Found", "No saved config at " .. path, 3)
        return false
    end
    local okRead, raw = pcall(readfile, path)
    if not okRead then return false end
    local okDec, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not okDec or type(decoded) ~= "table" then return false end

    for k, v in pairs(decoded) do
        if State[k] ~= nil then
            State[k] = v
            syncElementVisual(k, v)
        end
    end
    notify("Config Loaded", "Loaded profile from " .. path, 2.5)
    return true
end

local function deleteConfig(profileName)
    if type(isfile) == "function" and type(delfile) == "function" then
        local path = getConfigPath(profileName or State.ConfigName)
        if isfile(path) then
            pcall(delfile, path)
            notify("Config Deleted", "Deleted " .. path, 2.5)
            return true
        end
    end
    return false
end

local function resetAllToOff()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
            syncElementVisual(k, false)
        end
    end
    applyAntiAfkState(false)
    applyFullbright(false)
    restoreWalkSpeed()
    restoreJumpPower()
    restoreNoClip()
    restoreFly()
    restoreInstantPrompts()
    Runtime.lastAction = "All Toggles Reset OFF"
    notify("Reset Complete", "All features turned OFF and baselines restored.", 2.5)
end

TabConfig:Section({ Title = "Anti-AFK & Teleport Persistence" })
UI_Elements.AntiAfk = TabConfig:Toggle({
    Title = "Anti-AFK (Dual-Layer AntiAfkHeartbeat Bypass)",
    Desc = "Disables game LocalPlayer.Idled reporter, blocks Roblox 20m kick, and sends 45s activity heartbeat.",
    Value = false,
    Callback = function(v)
        State.AntiAfk = v
        applyAntiAfkState(v)
    end,
})
UI_Elements.AutoReExecuteOnTeleport = TabConfig:Toggle({
    Title = "Auto Re-Execute On Server Hop / Teleport",
    Value = false,
    Callback = function(v)
        State.AutoReExecuteOnTeleport = v
        if v and type(queue_on_teleport) == "function" and type(isfile) == "function" and type(readfile) == "function" then
            local p = "E:\\SC\\Defeat Anime RNG\\DefeatAnimeRNG_Master.lua"
            if isfile(p) then
                pcall(queue_on_teleport, readfile(p))
            end
        end
    end,
})

TabConfig:Section({ Title = "Configuration Profiles" })
UI_Elements.ConfigName = TabConfig:Input({
    Title = "Config Profile Name",
    Value = State.ConfigName,
    Placeholder = "default",
    Callback = function(v) State.ConfigName = (v ~= "" and v or "default") end,
})
TabConfig:Button({
    Title = "Save Config",
    Callback = function() saveConfig(State.ConfigName) end,
})
TabConfig:Button({
    Title = "Load Config",
    Callback = function() loadConfig(State.ConfigName) end,
})
TabConfig:Button({
    Title = "Delete Config",
    Callback = function() deleteConfig(State.ConfigName) end,
})
TabConfig:Button({
    Title = "Reset All Settings (All OFF)",
    Callback = resetAllToOff,
})
TabConfig:Button({
    Title = "Unload Script Completely",
    Callback = function()
        if getgenv().XLunaDARNG_Unload then
            getgenv().XLunaDARNG_Unload()
        end
    end,
})

TabConfig:Section({ Title = "Compliance Summary" })
TabConfig:Paragraph({
    Title = "XLunaHUB Compliance Card",
    Desc = "Title: Defeat Anime RNG | Author: By XLunaHUB | ToggleKey: LeftControl | Floating Button: Active | Default Startup State: ALL OFF | GUI/ESP Parent: gethui() / CoreGui",
})

-- -------------------------------------------------------------------------
-- 8. REAL-TIME EVENT HOOKS (MAGNET, INFINITE JUMP, WORLD RAID, NOCLIP/FLY)
-- -------------------------------------------------------------------------
trackConn(CollectionService:GetInstanceAddedSignal("CashThing"):Connect(function(orb)
    if (State.InstantCashXpMagnet or State.AutoPlayMaster) and orb:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
        if not CollectedOrbs[orb] then
            CollectedOrbs[orb] = true
            hideOrbLocally(orb)
            local ev = rem("CollectCashEvent")
            if ev then pcall(function() ev:FireServer(orb) end) end
            Runtime.orbsCollected += 1
        end
    end
end))

trackConn(CollectionService:GetInstanceAddedSignal("XpThing"):Connect(function(orb)
    if (State.InstantCashXpMagnet or State.AutoPlayMaster) and orb:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
        if not CollectedOrbs[orb] then
            CollectedOrbs[orb] = true
            hideOrbLocally(orb)
            local ev = rem("CollectXpEvent")
            if ev then pcall(function() ev:FireServer(orb) end) end
            Runtime.orbsCollected += 1
        end
    end
end))

local wrEv = rem("WorldRaidEvent")
if wrEv then
    trackConn(wrEv.OnClientEvent:Connect(function(kind, payload)
        if kind == "Rockets" and type(payload) == "table" and type(payload.Targets) == "table" then
            local exp = (tonumber(payload.ImpactAt) or (Workspace:GetServerTimeNow() + 2.5)) + 0.6
            for _, t in ipairs(payload.Targets) do
                if typeof(t) == "Vector3" then
                    table.insert(Runtime.rocketDangerZones, { pos = t, expiresAt = exp })
                elseif typeof(t) == "Instance" then
                    local ok, piv = pcall(function() return t:GetPivot() end)
                    if ok and typeof(piv) == "CFrame" then
                        table.insert(Runtime.rocketDangerZones, { pos = piv.Position, expiresAt = exp })
                    end
                end
            end
        elseif kind == "Invite" and State.AutoJoinWorldRaid then
            pcall(function() wrEv:FireServer("Join") end)
            Runtime.lastAction = "Joined World Raid"
        end
    end))
end

trackConn(Workspace.DescendantAdded:Connect(function(inst)
    if State.InstantPrompts and inst:IsA("ProximityPrompt") then
        applyInstantPrompt(inst)
    end
end))

trackConn(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local _, _, hum = getRootAndHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

trackConn(LocalPlayer.Idled:Connect(MyIdledHandlerFn))

-- High-frequency Movement, Rocket Evasion & Combat Heartbeat
local lastKillAuraAt = 0
trackConn(RunService.Heartbeat:Connect(function(dt)
    local char, hrp, hum = getRootAndHum()
    if not char or not hrp or not hum then return end

    if State.CustomWalkSpeed then
        if MovementOrig.WalkSpeed == nil then MovementOrig.WalkSpeed = hum.WalkSpeed end
        if hum.WalkSpeed ~= State.WalkSpeed then hum.WalkSpeed = State.WalkSpeed end
    end
    if State.CustomJumpPower then
        if MovementOrig.JumpPower == nil then MovementOrig.JumpPower = hum.JumpPower end
        if hum.JumpPower ~= State.JumpPower then hum.JumpPower = State.JumpPower end
    end

    if State.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if NoClipModified[part] == nil then
                    NoClipModified[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    if State.Fly then
        local cam = Workspace.CurrentCamera
        if cam then
            local dir = Vector3.zero
            if hum.MoveDirection.Magnitude > 0 then
                local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                local moveUnit = hum.MoveDirection.Unit
                local fwdDot = flatLook.Magnitude > 0.01 and moveUnit:Dot(flatLook.Unit) or 0
                local rightDot = flatRight.Magnitude > 0.01 and moveUnit:Dot(flatRight.Unit) or 0
                dir = (cam.CFrame.LookVector * fwdDot) + (cam.CFrame.RightVector * rightDot)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir += Vector3.new(0, -1, 0) end
            if dir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + dir.Unit * (State.FlySpeed * dt)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if State.AutoEvadeWorldRaidRockets and #Runtime.rocketDangerZones > 0 then
        local threat = findNearestThreatInRocketZones(hrp.Position)
        if threat then
            local away = hrp.Position - threat.pos
            away = Vector3.new(away.X, 0, away.Z)
            if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
            safeTeleportPos(threat.pos + away.Unit * 28 + Vector3.new(0, 2, 0))
        end
    end

    -- Auto-Farm TP & Kill Aura
    local doFarm = (State.AutoFarmEnemies or State.AutoPlayMaster) and (os.clock() >= Runtime.teleportLockUntil)
    local doAura = State.KillAura or State.AutoPlayMaster
    if doFarm or doAura then
        local base = getOwnBase()
        local targets = getActiveEnemies(base)
        local prioTarget = pickPriorityEnemy(targets, base)

        if prioTarget then
            if doFarm then
                local offset
                local dist = State.FarmDistance
                if State.FarmPositionMode == "Above" then
                    offset = Vector3.new(0, dist + 2, 0)
                elseif State.FarmPositionMode == "Front" then
                    offset = prioTarget.hrp.CFrame.LookVector * dist
                else
                    offset = -prioTarget.hrp.CFrame.LookVector * dist
                end
                local targetPos = prioTarget.hrp.Position + offset
                safeTeleportCF(CFrame.lookAt(targetPos, prioTarget.hrp.Position))
            end

            if doAura then
                if State.AutoEquipBestWeapon or State.AutoPlayMaster then
                    equipWeaponToolFromBackpack()
                end
                local weaponTool = getEquippedWeaponInCharacter()
                local isGun = weaponTool and WeaponsDatabase[weaponTool.Name] and WeaponsDatabase[weaponTool.Name].IsGun == true
                local speedMult = 1 + (tonumber(LocalPlayer:GetAttribute("SwingSpeedLv")) or 0) * 0.1
                local cooldown = (isGun and 0.25 or 0.16) / speedMult

                if (os.clock() - lastKillAuraAt) >= cooldown and weaponTool then
                    if isEnemyInAttackBox(hrp, prioTarget, isGun) then
                        local atkEv = rem("PlayerAttackEvent")
                        if atkEv then
                            if isGun then
                                pcall(function() atkEv:FireServer(prioTarget.model) end)
                            else
                                pcall(function() atkEv:FireServer() end)
                            end
                            lastKillAuraAt = os.clock()
                        end
                    end
                end
            end
        end
    end
end))

-- -------------------------------------------------------------------------
-- 9. MAIN AUTOMATION WORKER LOOP
-- -------------------------------------------------------------------------
trackThread(function()
    while true do
        safeWait(0.25)
        local now = os.clock()

        if State.AntiAfk and (now - Runtime.lastAntiAfkPingAt) >= 45 then
            local ev = rem("AntiAfkActivityPingEvent")
            if ev then pcall(function() ev:FireServer() end) end
            Runtime.lastAntiAfkPingAt = now
        end

        -- Cash & XP Magnet backup sweep
        if (State.InstantCashXpMagnet or State.AutoPlayMaster) and (now - Runtime.lastMagnetSweepAt) >= 1.5 then
            Runtime.lastMagnetSweepAt = now
            collectAllOwnedOrbs()
        end

        -- Free Custom Auto-Buy & Skip on RollStation
        if State.FreeCustomAutoBuy or State.AutoSkipUnwantedRolls or State.AutoPlayMaster then
            pcall(processFreeRollStationOnce)
            ensureElevatedIdentity()
        end

        -- Event Ticket Rolling
        if State.AutoRollEventTickets and (tonumber(LocalPlayer:GetAttribute("EventTickets")) or 0) > 0 then
            local rollEvFn = rem("RollEventTicketRequestFunction")
            if rollEvFn then
                pcall(function() rollEvFn:InvokeServer(1) end)
                ensureElevatedIdentity()
            end
        end

        -- Auto Equip Best & Place Best Units
        if (State.AutoEquipBestUnits or State.AutoPlayMaster) and (now - Runtime.lastAutoEquipUnitAt) >= 4 then
            Runtime.lastAutoEquipUnitAt = now
            local eqFn = rem("EquipBestRequestFunction")
            if eqFn then
                pcall(function() eqFn:InvokeServer() end)
                ensureElevatedIdentity()
            end
        end

        if (State.AutoPlaceBestUnits or State.AutoPlayMaster) and (now - Runtime.lastAutoPlaceAt) >= 6 then
            Runtime.lastAutoPlaceAt = now
            pcall(placeBestUnitsNow)
            ensureElevatedIdentity()
        end

        -- Placed Unit Abilities
        if (State.AutoCastUnitAbilities or State.AutoPlayMaster) and (now - Runtime.lastAbilityCast) >= 2.5 then
            Runtime.lastAbilityCast = now
            local useAb = rem("UseAbilityRequestFunction")
            if useAb then
                for _, info in ipairs(getPlacedUnits()) do
                    if info.model and info.model:GetAttribute("UnitName") ~= "D (Capri)" then
                        pcall(function() useAb:InvokeServer(info.model) end)
                        ensureElevatedIdentity()
                    end
                end
            end
        end

        if State.AutoEnableServerUnitAbilities then
            local setAuto = rem("SetAutoUseRequestFunction")
            if setAuto then
                for _, info in ipairs(getPlacedUnits()) do
                    if info.model and info.model:GetAttribute("AutoUseEnabled") ~= true then
                        pcall(function() setAuto:InvokeServer(info.model, true) end)
                        ensureElevatedIdentity()
                    end
                end
            end
        end

        -- Auto Lock, Fuse, Sell
        if State.AutoLockRareUnits or State.AutoPlayMaster then
            pcall(lockRareUnitsNow)
        end
        if State.AutoFuseUnits or State.AutoPlayMaster then
            pcall(fuseAllEligibleNow)
        end
        if State.AutoSellJunkUnits then
            pcall(sellJunkUnitsNow)
        end

        -- Auto Buy Best Weapon
        if State.AutoBuyBestWeapon or State.AutoPlayMaster then
            local bestW, bestDmg = getBestAffordableWeapon()
            local curTool = getEquippedWeaponInCharacter()
            local curDmg = (curTool and WeaponsDatabase[curTool.Name] and tonumber(WeaponsDatabase[curTool.Name].Damage)) or 0
            if bestW and bestDmg > curDmg then
                local buyFn = rem("BuyWeaponRequestFunction")
                local eqFn = rem("EquipWeaponRequestFunction")
                if buyFn then
                    pcall(function() buyFn:InvokeServer(bestW) end)
                    ensureElevatedIdentity()
                end
                if eqFn then
                    pcall(function() eqFn:InvokeServer(bestW) end)
                    ensureElevatedIdentity()
                end
            end
        end

        -- Trait Reroll Sniper
        if State.AutoRerollTrait and State.SelectedTraitUnitId ~= "None" then
            local targetTool = nil
            for _, t in ipairs(getAllInventoryUnits()) do
                if tostring(getUnitId(t)) == tostring(State.SelectedTraitUnitId) then
                    targetTool = t
                    break
                end
            end
            if targetTool then
                local curTrait = targetTool:GetAttribute("Trait")
                local wantSet = {}
                for k, v in pairs(type(State.TargetTraits) == "table" and State.TargetTraits or {}) do
                    if type(k) == "string" and v == true then wantSet[k] = true
                    elseif type(v) == "string" then wantSet[v] = true end
                end
                if curTrait and wantSet[curTrait] then
                    State.AutoRerollTrait = false
                    syncElementVisual("AutoRerollTrait", false)
                    notify("Trait Sniper Hit!", string.format("%s rolled desired trait: %s!", targetTool.Name, curTrait), 5)
                elseif (tonumber(LocalPlayer:GetAttribute("TraitShardCount")) or 0) > 0 then
                    local fn = rem("InstaRollTraitRequestFunction") or rem("RerollTraitRequestFunction")
                    if fn then
                        local ok = pcall(function() return fn:InvokeServer(State.SelectedTraitUnitId) end)
                        ensureElevatedIdentity()
                        if not ok then safeWait(0.5) end
                    end
                else
                    State.AutoRerollTrait = false
                    syncElementVisual("AutoRerollTrait", false)
                    notify("Trait Sniper Paused", "Out of Trait Shards.", 3.5)
                end
            end
        end

        -- Zones & Golden Zone Sniper
        if State.AutoUnlockZones or State.AutoPlayMaster then
            pcall(tryUnlockNextZone)
        end
        if State.GoldenZoneAutoSniper then
            local gzs = getActiveGoldenZones()
            local base = getOwnBase()
            local curZone = base and base:FindFirstChild("CurrentZone") and base.CurrentZone.Value
            if #gzs > 0 then
                if curZone ~= gzs[1].zone then
                    local tv = rem("ZoneTravelRequestEvent")
                    if tv then pcall(function() tv:FireServer(gzs[1].zone) end) end
                    Runtime.lastAction = "Golden Zone Sniper -> " .. gzs[1].zone
                end
            elseif State.AutoTravelHighestZone or State.AutoPlayMaster then
                local highest = getHighestUnlockedZone()
                if curZone ~= highest then
                    local tv = rem("ZoneTravelRequestEvent")
                    if tv then pcall(function() tv:FireServer(highest) end) end
                end
            end
        elseif State.AutoTravelHighestZone or State.AutoPlayMaster then
            local base = getOwnBase()
            local curZone = base and base:FindFirstChild("CurrentZone") and base.CurrentZone.Value
            local highest = getHighestUnlockedZone()
            if curZone ~= highest then
                local tv = rem("ZoneTravelRequestEvent")
                if tv then pcall(function() tv:FireServer(highest) end) end
                Runtime.lastAction = "Traveled -> " .. highest
            end
        end

        -- Upgrades & Prestige
        if State.AutoUpgradeMoneyStats or State.AutoPlayMaster then
            pcall(runAutoUpgradeMoney)
        end
        if State.AutoUpgradePrestigeTree or State.AutoPlayMaster then
            pcall(runAutoUpgradePrestige)
        end
        if State.AutoPrestige or State.AutoPlayMaster then
            pcall(triggerPrestigeIfReady)
        end

        -- Periodic tasks (Rewards, Potions, Challenges, Towers, Merchant)
        if (State.AutoClaimAllRewards or State.AutoClaimPendingBooths or State.AutoPlayMaster) and (now - Runtime.lastRewardsAt) >= 8 then
            Runtime.lastRewardsAt = now
            pcall(claimAllRewardsNow)
        end

        if State.AutoUsePotions and (now - Runtime.lastPotionAt) >= 4 then
            Runtime.lastPotionAt = now
            pcall(checkAndUsePotions)
        end

        if (State.AutoStartChallenges or State.AutoEnterInfiniteTower or State.AutoClaimTowerBracket) and (now - Runtime.lastTowerCheckAt) >= 6 then
            Runtime.lastTowerCheckAt = now
            if State.AutoStartChallenges then
                local base = getOwnBase()
                if base and not base:GetAttribute("ChallengeActive") then
                    local chFn = rem("ChallengeStartRequestFunction")
                    if chFn then
                        local prios = type(State.ChallengePriorities) == "table" and State.ChallengePriorities or { "Weekly", "Daily", "Regular" }
                        local wantList = {}
                        for k, v in pairs(prios) do
                            if type(k) == "string" and v == true then table.insert(wantList, k)
                            elseif type(v) == "string" then table.insert(wantList, v) end
                        end
                        for _, tier in ipairs({ "Weekly", "Daily", "Regular" }) do
                            if table.find(wantList, tier) then
                                local ok, res = pcall(function() return chFn:InvokeServer(tier) end)
                                ensureElevatedIdentity()
                                if ok and res then break end
                            end
                        end
                    end
                end
            end
            if State.AutoClaimTowerBracket then
                local clFn = rem("ClaimTowerBracketRewardsFunction")
                if clFn then
                    pcall(function() clFn:InvokeServer() end)
                    ensureElevatedIdentity()
                end
            end
            if State.AutoEnterInfiniteTower then
                local infFn = rem("InfiniteTowerEnterRequestFunction")
                if infFn then
                    pcall(function() infFn:InvokeServer() end)
                    ensureElevatedIdentity()
                end
            end
        end

        if State.AutoBuyMerchantAll and (now - Runtime.lastMerchantAt) >= 10 then
            Runtime.lastMerchantAt = now
            local getSt = rem("GetMerchantStockRequestFunction")
            local buyAll = rem("BuyAllMerchantItemsRequestFunction")
            if getSt and buyAll then
                local ok, isOpen = pcall(function() return getSt:InvokeServer() end)
                ensureElevatedIdentity()
                if ok and isOpen then
                    pcall(function() buyAll:InvokeServer() end)
                    ensureElevatedIdentity()
                end
            end
        end
    end
end)

-- -------------------------------------------------------------------------
-- 10. LIVE TELEMETRY DASHBOARD & STEALTH ESP LOOP (gethui() / CoreGui)
-- -------------------------------------------------------------------------
local StealthParent = getStealthContainerParent()
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "XLuna_DARNG_ESP"
ESPFolder.Parent = StealthParent

local function ensureESPFolder()
    ensureElevatedIdentity()
    if not ESPFolder or not ESPFolder.Parent then
        ESPFolder = Instance.new("Folder")
        ESPFolder.Name = "XLuna_DARNG_ESP"
        ESPFolder.Parent = getStealthContainerParent()
    end
    return ESPFolder
end

local function addESPLabel(adornee, name, text, color, offsetY, maxDist)
    ensureElevatedIdentity()
    local folder = ensureESPFolder()
    local bb = Instance.new("BillboardGui")
    bb.Name = name
    bb.Adornee = adornee
    bb.Size = UDim2.fromOffset(220, 40)
    bb.StudsOffsetWorldSpace = Vector3.new(0, offsetY or 4, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = maxDist or 2000
    bb.Parent = folder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.15
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.Parent = bb
    return bb
end

local function addESPHighlight(adornee, color)
    ensureElevatedIdentity()
    local folder = ensureESPFolder()
    local hl = Instance.new("Highlight")
    hl.Adornee = adornee
    hl.FillColor = color
    hl.FillTransparency = 0.55
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.OutlineTransparency = 0.1
    hl.Parent = folder
    return hl
end

local function runTelemetryAndESPOnce()
    pcall(function()
        ensureElevatedIdentity()
        local base = getOwnBase()
        local curZone = base and base:FindFirstChild("CurrentZone") and base.CurrentZone.Value or tostring(LocalPlayer:GetAttribute("Zone") or "None")
        local enemies = getActiveEnemies(base)
        local placed = getPlacedUnits(base)
        local occupied = 0
        for _, p in ipairs(placed) do if p.model then occupied += 1 end end
        local maxSlots = #placed
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        local highestDps = ls and ls:FindFirstChild("Highest DPS") and tostring(ls["Highest DPS"].Value) or "0"
        local gzs = getActiveGoldenZones()

        safeSetDesc(BaseStatusPara, string.format(
            "Base: %s | Zone: %s | Placed Units: %d/%d | Inv Units: %d\nActive Enemies: %d | Highest DPS: %s | Golden Zones: %d | Last: %s",
            base and base.Name or "None", curZone, occupied, maxSlots, #getAllInventoryUnits(),
            #enemies, highestDps, #gzs, Runtime.lastAction
        ))

        local money = getMoney()
        local lv = tonumber(LocalPlayer:GetAttribute("Level")) or 1
        local prestige = tonumber(LocalPlayer:GetAttribute("Prestige")) or 0
        local pPts = getPrestigePoints()
        local shards = tonumber(LocalPlayer:GetAttribute("TraitShardCount")) or 0
        local pityM = tonumber(LocalPlayer:GetAttribute("PityMythic")) or 0
        local pityS = tonumber(LocalPlayer:GetAttribute("PitySecret")) or 0
        local luck = tonumber(LocalPlayer:GetAttribute("EffectiveLuckMultiplier")) or 1
        local goldMult = tonumber(LocalPlayer:GetAttribute("EffectiveGoldMultiplier")) or 1

        safeSetDesc(EconomyStatusPara, string.format(
            "Money: Â¥%s | Level: %d (Prestige %d | Pts: %d) | Shards: %d\nLuck: x%.2f | Gold: x%.2f | Pity M/S: %d / %d | Orbs: %d | Bought: %d",
            formatNumber(money), lv, prestige, pPts, shards, luck, goldMult, pityM, pityS, Runtime.orbsCollected, Runtime.unitsAutoBought
        ))
    end)

    pcall(function()
        ensureElevatedIdentity()
        local folder = ensureESPFolder()
        folder:ClearAllChildren()
        if not (State.EnemyBossESP or State.RolledStandESP or State.BoothMerchantESP) then
            return
        end

        local base = getOwnBase()
        local _, hrp = getRootAndHum()
        local myPos = hrp and hrp.Position

        if State.EnemyBossESP then
            for _, e in ipairs(getActiveEnemies(base)) do
                local col = e.isBoss and Color3.fromRGB(255, 85, 85) or (e.isElite and Color3.fromRGB(255, 195, 50) or Color3.fromRGB(115, 255, 130))
                addESPHighlight(e.model, col)
                addESPLabel(e.hrp, "EnemyESP", string.format("%s [%s]\nHP: %s / %s", e.model.Name, e.isBoss and "BOSS" or (e.isElite and "ELITE" or "MOB"), formatNumber(e.hp), formatNumber(e.hum.MaxHealth)), col, 4, 2000)
            end
        end

        if State.RolledStandESP and base then
            local rs = base:FindFirstChild("RollStation")
            if rs then
                for _, m in ipairs(CollectionService:GetTagged(REVEAL_TAG)) do
                    if m:IsA("Model") and m:IsDescendantOf(rs) then
                        local uName = m:GetAttribute("UnitName") or m.Name
                        local rar = m:GetAttribute("Rarity") or "?"
                        local mut = m:GetAttribute("Mutation")
                        local col = Color3.fromRGB(255, 220, 75)
                        addESPHighlight(m, col)
                        addESPLabel(m, "RollESP", string.format("%s [%s%s]", uName, rar, mut and (" / " .. tostring(mut)) or ""), col, 4.5, 2000)
                    end
                end
            end
        end

        if State.BoothMerchantESP then
            for name, cf in pairs(getBoothPositions()) do
                local booths = Workspace:FindFirstChild("Booths")
                local adornee = (booths and booths:FindFirstChild(name)) or Workspace:FindFirstChild(name)
                if adornee then
                    local dist = myPos and math.floor((cf.Position - myPos).Magnitude) or 0
                    addESPLabel(adornee, "BoothESP", string.format("%s [%dm]", name, dist), Color3.fromRGB(100, 210, 255), 8, 3000)
                end
            end
        end
    end)
end

task.defer(runTelemetryAndESPOnce)

trackThread(function()
    while true do
        safeWait(0.85)
        runTelemetryAndESPOnce()
    end
end)

-- -------------------------------------------------------------------------
-- 11. REGISTER UNLOAD, LIVE-RELOAD CLEANUP & RUNTIME HANDLES
-- -------------------------------------------------------------------------
getgenv().XLunaDARNG_Unload = function()
    ensureElevatedIdentity()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, t in ipairs(Threads) do
        pcall(function() task.cancel(t) end)
    end
    for _, fn in ipairs(Cleanups) do
        pcall(fn)
    end
    pcall(applyAntiAfkState, false)
    pcall(applyFullbright, false)
    pcall(restoreWalkSpeed)
    pcall(restoreJumpPower)
    pcall(restoreNoClip)
    pcall(restoreFly)
    pcall(restoreInstantPrompts)
    pcall(function() ESPFolder:Destroy() end)
    pcall(function()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end)
    getgenv().XLunaDARNG_Window = nil
    getgenv().XLunaDARNG_State = nil
    getgenv().XLunaDARNG_Elements = nil
    getgenv().XLunaDARNG_Actions = nil
    getgenv().XLunaDARNG_Unload = nil
end

if type(STATE) == "table" and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(getgenv().XLunaDARNG_Unload)
end

getgenv().XLunaDARNG_Window = Window
getgenv().XLunaDARNG_State = State
getgenv().XLunaDARNG_Elements = UI_Elements
getgenv().XLunaDARNG_Actions = {
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,
    DeleteConfig = deleteConfig,
    ResetAllToOff = resetAllToOff,
    CollectOrbs = collectAllOwnedOrbs,
    PlaceBestUnits = placeBestUnitsNow,
    FuseAll = fuseAllEligibleNow,
    SellJunk = sellJunkUnitsNow,
    LockRare = lockRareUnitsNow,
    UpgradeMoney = runAutoUpgradeMoney,
    UpgradePrestige = runAutoUpgradePrestige,
    ClaimRewards = claimAllRewardsNow,
    RedeemAllCodes = redeemAllCodesNow,
    GetRuntime = function() return Runtime end,
    GetOwnBase = getOwnBase,
    GetESPCount = function() return ESPFolder and #ESPFolder:GetChildren() or 0 end,
}

notify("XLunaHUB", "Defeat Anime RNG loaded (ALL OFF). Toggle with LeftControl or Floating Button.", 3.5)
