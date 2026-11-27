-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    SURVIVE YOUR IDEAS â MASTER AUTOMATION SUITE
    Author: By XLunaHUB
    UI Framework: WindUI | Language: English
    Keybind: LeftControl (Show/Hide) | Floating Button: Enabled (Draggable)
    Default State: ALL OFF (All toggles disabled at startup)
    ========================================================================
]]

-- -------------------------------------------------------------------------
-- 1. SERVICES & PREVIOUS INSTANCE CLEANUP
-- -------------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if getgenv().XLunaSYI_Unload then
    pcall(getgenv().XLunaSYI_Unload)
end

local Cleanups = {}
local Connections = {}
local Threads = {}

local function trackConn(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function trackThread(fn)
    local co = task.spawn(fn)
    table.insert(Threads, co)
    return co
end

-- -------------------------------------------------------------------------
-- 2. SAFE MODULE & REMOTE RESOLVERS
-- -------------------------------------------------------------------------
local function safeRequire(inst)
    if not inst or not inst:IsA("ModuleScript") then
        return nil
    end
    local ok, mod = pcall(require, inst)
    return ok and mod or nil
end

local function findChildPath(root, ...)
    local cur = root
    for _, name in ipairs({...}) do
        if not cur then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end

local DiaryFolder = ReplicatedStorage:FindFirstChild("Diary")
local DiaryCatalog = safeRequire(findChildPath(DiaryFolder, "DiaryCatalog"))
local DiaryConfig = safeRequire(findChildPath(DiaryFolder, "DiaryConfig"))
local DiaryRequest = findChildPath(DiaryFolder, "Remotes", "Request")

local ItemsFolder = ReplicatedStorage:FindFirstChild("Items")
local ItemLibrary = safeRequire(findChildPath(ItemsFolder, "ItemLibrary"))
local ItemsRequest = findChildPath(ItemsFolder, "Remotes", "Request")

local WeaponSystem = ReplicatedStorage:FindFirstChild("WeaponSystem")
local WeaponConfig = safeRequire(findChildPath(WeaponSystem, "WeaponConfig"))
local MeleeConfig = safeRequire(findChildPath(WeaponSystem, "MeleeConfig"))
local WeaponFireRemote = findChildPath(WeaponSystem, "Remotes", "Fire")
local MeleeSwingRemote = findChildPath(WeaponSystem, "MeleeRemotes", "Swing")
local MeleeHitRemote = findChildPath(WeaponSystem, "MeleeRemotes", "Hit")

local WriterRemotes = ReplicatedStorage:FindFirstChild("WriterRemotes")
local SubmitWordRemote = findChildPath(WriterRemotes, "SubmitWord")
local RollDiceRemote = findChildPath(WriterRemotes, "RollDice")
local WordPreviewRemote = findChildPath(WriterRemotes, "WordPreview")
local WriterPromptRemote = findChildPath(WriterRemotes, "WriterPrompt")
local WriterLiveRemote = findChildPath(WriterRemotes, "WriterLive")
local WordAnnouncedRemote = findChildPath(WriterRemotes, "WordAnnounced")
local BoxCheckRemote = findChildPath(WriterRemotes, "BoxCheck")

local MetaRemotes = findChildPath(ReplicatedStorage, "MetaWords", "Remotes")
local MetaWordsConfig = safeRequire(findChildPath(ReplicatedStorage, "MetaWords", "MetaWordsConfig"))
local TryMetaRemote = findChildPath(MetaRemotes, "TryMeta")
local UndoPickRemote = findChildPath(MetaRemotes, "UndoPick")
local MetaEffectRemote = findChildPath(MetaRemotes, "Effect")

local AdminWordCheckRemote = findChildPath(ReplicatedStorage, "AdminKit", "Remotes", "WordCheck")
local WriteCreditRequest = findChildPath(ReplicatedStorage, "WriteCreditsRemotes", "Request")
local LobbyReturnRemote = ReplicatedStorage:FindFirstChild("LobbyReturnRequest")
local FreeReviveRemote = ReplicatedStorage:FindFirstChild("FreeReviveRemote")
local GrabStruggleRemote = findChildPath(ReplicatedStorage, "GrabRemotes", "Struggle")
local LavaShellTapRemote = findChildPath(ReplicatedStorage, "LavaShellRemotes", "Tap")
local SetSprintRemote = findChildPath(ReplicatedStorage, "SprintRemotes", "SetSprint")
local CarryRequestRemote = findChildPath(ReplicatedStorage, "CarryRemotes", "Request")
local QuakeDrawRemote = findChildPath(ReplicatedStorage, "MasteryRemotes", "QuakeDraw")

local EdgeGuardConfig = safeRequire(findChildPath(ReplicatedStorage, "EdgeGuard", "EdgeGuardConfig"))
local PullFieldMod = safeRequire(ReplicatedStorage:FindFirstChild("PullField"))
local CarryConfig = safeRequire(ReplicatedStorage:FindFirstChild("CarryConfig"))
local ReviveConfig = safeRequire(ReplicatedStorage:FindFirstChild("ReviveConfig"))
local WriterShieldShared = safeRequire(ReplicatedStorage:FindFirstChild("WriterShieldShared"))
local PlaceIds = safeRequire(ReplicatedStorage:FindFirstChild("PlaceIds"))

-- Snapshot original WeaponConfig & PullField & Lighting state for clean restoration
local OriginalPullVelocityFor = PullFieldMod and PullFieldMod.velocityFor or nil
local OriginalWeapons = {}
if WeaponConfig and type(WeaponConfig.WEAPONS) == "table" then
    for id, data in pairs(WeaponConfig.WEAPONS) do
        if type(data) == "table" then
            OriginalWeapons[id] = {
                spread = data.spread,
                bloom = data.bloom,
                kick = data.kick,
                side = data.side,
                shake = data.shake,
                automatic = data.automatic,
                spinUp = data.spinUp,
                fireRate = data.fireRate,
            }
        end
    end
end

local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- -------------------------------------------------------------------------
-- 3. STATE STORE (STRICTLY ALL OFF ON STARTUP) & CONFIG PERSISTENCE
-- -------------------------------------------------------------------------
local CONFIG_DIR = "XLunaHUB_SurviveYourIdeas"
local CONFIG_PATH = CONFIG_DIR .. "/config.json"

local State = {
    -- Survival & Immunities
    SmartAutoSurvive = false,
    SkySanctuary = false,
    WalkOnWater = false,
    AutoEdgeRescue = false,
    AntiRagdoll = false,
    AntiSuction = false,
    AntiWind = false,
    AntiSlip = false,
    AntiMetaLag = false,
    AutoBreakGrabs = false,
    FreezeAnimatronics = false,
    SilentSprint = false,
    ClearVision = false,

    -- Writer & Words
    LiveTypingSpy = false,
    AutoWriteOnTurn = false,
    AutoWriteStrategy = "Undiscovered Diary Words (Cash Farm)",
    CustomWord1 = "nuke",
    CustomWord2 = "shield",
    SelectedMetaCommand = "/jackpot",
    ValidatorWord = "nuke",
    SelectedDiaryCategory = "weapons",
    AutoUseWriteCredits = false,
    AutoPickUndoTarget = false,

    -- Combat
    GunSilentAim = false,
    CombatTargetFilter = "Bosses & Creatures Only",
    GunMods = false,
    RapidFire = false,
    RapidFireMultiplier = 1.3,
    MeleeKillAura = false,
    AutoCarryYeet = false,
    YeetDirection = "Towards Ocean Edge",
    AutoQuakeRival = false,

    -- Loot & Economy
    AutoCollectCoins = false,
    AutoPickupWorldLoot = false,
    AutoEatFood = false,
    HealThreshold = 55,
    AutoClaimDiary = false,
    AutoRollFreeGacha = false,
    AutoRollCashGacha = false,
    AutoEquipBestLoadout = false,
    AutoFreeRevive = false,

    -- Teleport & Movement
    AntiAfk = false,
    CustomWalkSpeed = false,
    WalkSpeed = 32,
    CustomJumpPower = false,
    JumpPower = 75,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 60,

    -- Visuals & ESP
    BossESP = false,
    PlayerESP = false,
    LootESP = false,
    ShelterESP = false,
    DoomedTilesESP = false,
    Fullbright = false,

    -- Config
    AutoReExecuteOnTeleport = false,
}

local UI_Elements = {}

-- -------------------------------------------------------------------------
-- 4. LOAD WINDUI & INITIALIZE WINDOW
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
    Title = "Survive Your Ideas",
    Icon = "book-open",
    Author = "By XLunaHUB",
    Folder = "XLunaSYI",
    Size = UDim2.fromOffset(640, 500),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 1.5,
        Color = ColorSequence.new(Color3.fromRGB(255, 90, 0), Color3.fromRGB(255, 0, 128)),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

local function notify(title, msg, duration)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = msg,
            Duration = duration or 3,
        })
    end)
end

-- -------------------------------------------------------------------------
-- 5. SHARED HELPERS (BOUNDARIES, TELEPORT, DIARY, TARGETS)
-- -------------------------------------------------------------------------
local function getRootAndHum()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function getEdgeBounds()
    local min2 = Workspace:GetAttribute(EdgeGuardConfig and EdgeGuardConfig.BOX_MIN_ATTRIBUTE or "EdgeBoxMin")
    local max2 = Workspace:GetAttribute(EdgeGuardConfig and EdgeGuardConfig.BOX_MAX_ATTRIBUTE or "EdgeBoxMax")
    local floorY = Workspace:GetAttribute(EdgeGuardConfig and EdgeGuardConfig.FLOOR_Y_ATTRIBUTE or "EdgeFloorY")
    if typeof(min2) ~= "Vector2" then min2 = Vector2.new(-150, -150) end
    if typeof(max2) ~= "Vector2" then max2 = Vector2.new(150, 150) end
    if type(floorY) ~= "number" then floorY = 14.3 end
    local skyMaxY = floorY + ((EdgeGuardConfig and EdgeGuardConfig.SKY_LIMIT_STUDS or 175) - 8)
    local seaTop = Workspace:GetAttribute("SeaTop") or Workspace:GetAttribute("SeaLevel") or 7.35
    return min2, max2, floorY, skyMaxY, seaTop
end

local function clampSafePos(pos)
    local min2, max2, floorY, skyMaxY = getEdgeBounds()
    local x = math.clamp(pos.X, min2.X + 6, max2.X - 6)
    local z = math.clamp(pos.Z, min2.Y + 6, max2.Y - 6)
    local y = math.clamp(pos.Y, floorY - 4, skyMaxY)
    return Vector3.new(x, y, z)
end

local function isPosSafeFromEdgeAndSea(pos)
    local min2, max2, _, skyMaxY, seaTop = getEdgeBounds()
    return pos.X >= min2.X + 2
        and pos.X <= max2.X - 2
        and pos.Z >= min2.Y + 2
        and pos.Z <= max2.Y - 2
        and pos.Y <= skyMaxY
        and pos.Y >= seaTop + 0.5
end

local function getSafeCenterPos(yOffset)
    local min2, max2, floorY = getEdgeBounds()
    local cx = (min2.X + max2.X) * 0.5
    local cz = (min2.Y + max2.Y) * 0.5
    return Vector3.new(cx, floorY + (yOffset or 8), cz)
end

local function safeTeleport(pos)
    local _, hrp = getRootAndHum()
    if not hrp then return false end
    local safe = clampSafePos(pos)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(safe)
    return true
end

local function getModelPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, cf = pcall(function() return obj:GetPivot() end)
        if ok and typeof(cf) == "CFrame" then return cf.Position end
    end
    local p = obj:FindFirstChildWhichIsA("BasePart", true)
    return p and p.Position or nil
end

local function resolveWritableWord(entry)
    if not entry then return "nuke" end
    if DiaryCatalog and type(DiaryCatalog.displayName) == "function" then
        local dn = DiaryCatalog.displayName(entry)
        if type(dn) == "string" and dn ~= "" and not dn:find("%s") then
            return dn
        end
    end
    local raw = tostring(entry.key or "nuke"):gsub("^[^:]+:", ""):gsub("_", "")
    return raw ~= "" and raw or "nuke"
end

-- Sky Sanctuary & Walk-On-Water Local Parts
local SkyPlatform = nil
local WaterFloorPart = nil

local function ensureSkyPlatform()
    if SkyPlatform and SkyPlatform.Parent then return SkyPlatform end
    local _, _, floorY = getEdgeBounds()
    local center = getSafeCenterPos(130)
    local p = Instance.new("Part")
    p.Name = "XLuna_SkySanctuary"
    p.Size = Vector3.new(75, 2, 75)
    p.Position = Vector3.new(center.X, floorY + 130, center.Z)
    p.Anchored = true
    p.CanCollide = true
    p.Material = Enum.Material.ForceField
    p.Color = Color3.fromRGB(0, 210, 255)
    p.Transparency = 0.35
    p.Parent = Workspace
    SkyPlatform = p
    return p
end

local function destroySkyPlatform()
    if SkyPlatform then
        pcall(function() SkyPlatform:Destroy() end)
        SkyPlatform = nil
    end
end

local function ensureWaterFloor()
    if WaterFloorPart and WaterFloorPart.Parent then return WaterFloorPart end
    local p = Instance.new("Part")
    p.Name = "XLuna_WaterWalkFloor"
    p.Size = Vector3.new(40, 1, 40)
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 0.6
    p.Material = Enum.Material.ForceField
    p.Color = Color3.fromRGB(80, 255, 190)
    p.Parent = Workspace
    WaterFloorPart = p
    return p
end

local function destroyWaterFloor()
    if WaterFloorPart then
        pcall(function() WaterFloorPart:Destroy() end)
        WaterFloorPart = nil
    end
end

-- Patch Helpers for WeaponConfig & PullField & Lighting
local function applyGunMods()
    if not WeaponConfig or type(WeaponConfig.WEAPONS) ~= "table" then return end
    for id, data in pairs(WeaponConfig.WEAPONS) do
        local orig = OriginalWeapons[id]
        if type(data) == "table" and orig then
            if State.GunMods then
                data.spread = 0
                data.bloom = 0
                data.kick = 0
                data.side = 0
                data.shake = 0
                data.automatic = true
                data.spinUp = false
            else
                data.spread = orig.spread
                data.bloom = orig.bloom
                data.kick = orig.kick
                data.side = orig.side
                data.shake = orig.shake
                data.automatic = orig.automatic
                data.spinUp = orig.spinUp
            end
            if State.RapidFire then
                data.fireRate = (orig.fireRate or 5) * (State.RapidFireMultiplier or 1.3)
            else
                data.fireRate = orig.fireRate
            end
        end
    end
end

local function applyPullHook()
    if not PullFieldMod or not OriginalPullVelocityFor then return end
    if State.AntiSuction then
        PullFieldMod.velocityFor = function()
            return Vector3.zero, nil
        end
    else
        PullFieldMod.velocityFor = OriginalPullVelocityFor
    end
end

local function applyFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(220, 220, 220)
        Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

-- Writer Live State Cache
local LiveWriterInfo = {
    WriterName = "None",
    TypingText = "",
    LastWord = "None",
    LastCategory = "None",
    LastToastAt = 0,
    IsMyTurn = false,
    TurnWordCount = 1,
    TurnMode = "Normal",
}

local LethalAlertWords = {
    nuke = true, lava = true, tsunami = true, flood = true, supernova = true,
    antimatter = true, blackhole = true, black_hole = true, meteor = true,
    earthquake = true, tornado = true, volcano = true, apocalypse = true,
    acid = true, avalanche = true, war = true, airstrike = true, boss = true,
    extinction = true, destruction = true, rumbling = true,
}

-- Diary & Economy Cache
local DiaryCache = {
    discoveredCount = 0,
    totalCount = DiaryCatalog and DiaryCatalog.count() or 537,
    pages = {},
    claimed = {},
    lastFetch = 0,
}

local ItemsCache = {
    owned = {},
    loadout = {},
    freeSpins = 0,
    pity = 0,
    lastFetch = 0,
}

local function refreshDiaryCache(force)
    if not DiaryRequest then return end
    if not force and os.clock() - DiaryCache.lastFetch < 4 then return end
    DiaryCache.lastFetch = os.clock()
    local ok, res = pcall(function() return DiaryRequest:InvokeServer("state") end)
    if ok and type(res) == "table" then
        DiaryCache.pages = type(res.pages) == "table" and res.pages or {}
        DiaryCache.claimed = type(res.claimed) == "table" and res.claimed or {}
        local count = 0
        for _ in pairs(DiaryCache.pages) do count += 1 end
        DiaryCache.discoveredCount = count
    end
end

local function refreshItemsCache(force)
    if not ItemsRequest then return end
    if not force and os.clock() - ItemsCache.lastFetch < 4 then return end
    ItemsCache.lastFetch = os.clock()
    local ok, res = pcall(function() return ItemsRequest:InvokeServer("state") end)
    if ok and type(res) == "table" then
        ItemsCache.owned = type(res.owned) == "table" and res.owned or {}
        ItemsCache.loadout = type(res.loadout) == "table" and res.loadout or {}
        ItemsCache.freeSpins = tonumber(res.freeSpins) or 0
        ItemsCache.pity = tonumber(res.pity) or 0
    end
end

-- Word Strategy Picker
local StrategyBuckets = {
    Disasters = {"nuke", "tsunami", "lava", "meteor", "tornado", "earthquake", "volcano", "apocalypse", "avalanche", "supernova", "antimatter"},
    GodPowers = {"gojo", "goku", "saitama", "sonic", "superman", "ironman", "hulk", "titan", "god", "sukuna", "arise", "star"},
    WeaponsLoot = {"awp", "minigun", "barrett", "rpg", "at4", "railgun", "katana", "chainsaw", "medkit", "chest", "diamond"},
    FoodHealing = {"pizza", "burger", "tacos", "sushi", "medkit", "capybara", "oasis", "love", "jesus"},
}

local function pickAutoWords(wordCount)
    local picks = {}
    local strat = State.AutoWriteStrategy

    if strat == "Meta Command (/)" then
        return { State.SelectedMetaCommand or "/jackpot" }
    elseif strat == "Custom Word" then
        local w1 = (State.CustomWord1 or "nuke"):match("^%s*(%S+)") or "nuke"
        local w2 = (State.CustomWord2 or "shield"):match("^%s*(%S+)") or "shield"
        return wordCount == 2 and { w1, w2 } or { w1 }
    elseif strat == "Undiscovered Diary Words (Cash Farm)" and DiaryCatalog then
        refreshDiaryCache(false)
        local allEntries = DiaryCatalog.all()
        for key, entry in pairs(allEntries) do
            if not DiaryCache.pages[key] then
                local w = resolveWritableWord(entry)
                if w ~= "" and not table.find(picks, w) then
                    table.insert(picks, w)
                    if #picks >= wordCount then break end
                end
            end
        end
    else
        local bucket = StrategyBuckets.Disasters
        if strat == "God Morph Powers" then bucket = StrategyBuckets.GodPowers
        elseif strat == "Weapons & Loot" then bucket = StrategyBuckets.WeaponsLoot
        elseif strat == "Food & Healing" then bucket = StrategyBuckets.FoodHealing end
        for _ = 1, wordCount do
            table.insert(picks, bucket[math.random(1, #bucket)])
        end
    end

    while #picks < wordCount do
        local fallback = StrategyBuckets.Disasters[math.random(1, #StrategyBuckets.Disasters)]
        table.insert(picks, fallback)
    end
    return picks
end

local function submitWordsSafely(words)
    if not SubmitWordRemote or #words == 0 then return false, "Missing SubmitWord remote" end
    local first = tostring(words[1] or "")
    if first:sub(1, 1) == "/" then
        if not TryMetaRemote then return false, "TryMeta remote not found" end
        local ok, res, errMsg = pcall(function() return TryMetaRemote:InvokeServer(first) end)
        return ok and res == true, tostring(errMsg or res)
    end

    if ReplicatedStorage:GetAttribute("VipMatch") == true and AdminWordCheckRemote then
        local okCheck, allowed, msg = pcall(function() return AdminWordCheckRemote:InvokeServer(words) end)
        if okCheck and allowed == false then
            return false, tostring(msg or "Blocked in VIP match")
        end
    end
    if WriterRemotes and WriterRemotes:GetAttribute("GodSession") == true and BoxCheckRemote then
        local okBox, blockReason = pcall(function() return BoxCheckRemote:InvokeServer(words) end)
        if okBox and type(blockReason) == "string" and blockReason ~= "" then
            return false, blockReason
        end
    end

    SubmitWordRemote:FireServer(table.unpack(words))
    return true, table.concat(words, " + ")
end

-- Combat Target Resolver
local function isModelAlive(model)
    if not model or not model.Parent then return false end
    if model:GetAttribute("Protected") == true then return false end
    local sh = model:GetAttribute("ShootHealth")
    if type(sh) == "number" then
        return sh > 0
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health > 0
    end
    return true
end

local function getTargetPart(model)
    return model:FindFirstChild("Head")
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart")
end

local function collectCombatTargets(filterMode)
    local targets = {}
    local seen = {}
    local includeMobs = (filterMode == "Bosses & Creatures Only" or filterMode == "Bosses & Players (All)")
    local includePlayers = (filterMode == "Players Only" or filterMode == "Bosses & Players (All)")

    if includeMobs then
        for _, tag in ipairs({"Shootable", "Creature", "BossWeaponTarget"}) do
            for _, inst in ipairs(CollectionService:GetTagged(tag)) do
                if inst:IsA("Model") and not seen[inst] and not Players:GetPlayerFromCharacter(inst) and isModelAlive(inst) then
                    local part = getTargetPart(inst)
                    if part then
                        seen[inst] = true
                        table.insert(targets, { model = inst, part = part, isMob = true })
                    end
                end
            end
        end
        local bots = Workspace:FindFirstChild("BotCharacters")
        if bots then
            for _, bot in ipairs(bots:GetChildren()) do
                if bot:IsA("Model") and not seen[bot] and isModelAlive(bot) then
                    local part = getTargetPart(bot)
                    if part then
                        seen[bot] = true
                        table.insert(targets, { model = bot, part = part, isMob = true })
                    end
                end
            end
        end
    end

    if includePlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and not seen[plr.Character] then
                local char = plr.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local prot = char:GetAttribute("Status_protected")
                local isShielded = WriterShieldShared and type(WriterShieldShared.isShielded) == "function" and WriterShieldShared.isShielded(char)
                local protectedActive = type(prot) == "number" and prot > Workspace:GetServerTimeNow()
                if hum and hum.Health > 0 and not isShielded and not protectedActive then
                    local part = getTargetPart(char)
                    if part then
                        seen[char] = true
                        table.insert(targets, { model = char, part = part, isMob = false })
                    end
                end
            end
        end
    end
    return targets
end

local function findNearestTarget(originPos, maxRange, filterMode)
    local best, bestDist = nil, maxRange or math.huge
    for _, entry in ipairs(collectCombatTargets(filterMode)) do
        local d = (entry.part.Position - originPos).Magnitude
        if d <= bestDist then
            bestDist = d
            best = entry
        end
    end
    return best, bestDist
end

-- World Locations Helpers
local function findEscapeShelterPos()
    local tagged = CollectionService:GetTagged("Escape_Shelter")
    local shelter = tagged[1] or findChildPath(Workspace, "MatchContent", "EscapeShelter")
    if not shelter then return nil end
    if shelter:IsA("Model") then
        local floorPart = shelter:FindFirstChild("Floor")
        if floorPart and floorPart:IsA("BasePart") then
            return floorPart.Position + Vector3.new(0, 4, 0)
        end
        local cf = shelter:GetBoundingBox()
        return cf.Position + Vector3.new(0, 2, 0)
    elseif shelter:IsA("BasePart") then
        return shelter.Position + Vector3.new(0, 4, 0)
    end
    return nil
end

local function findHighestEscapeTowerPos()
    local _, _, _, skyMaxY = getEdgeBounds()
    local bestPos, bestY = nil, -math.huge
    for _, inst in ipairs(CollectionService:GetTagged("Escape_HighGround")) do
        local p = getModelPos(inst)
        if p and p.Y <= skyMaxY and p.Y > bestY then
            bestY = p.Y
            bestPos = p + Vector3.new(0, 4, 0)
        end
    end
    local mc = Workspace:FindFirstChild("MatchContent")
    if mc then
        for _, child in ipairs(mc:GetChildren()) do
            if child.Name == "EscapeTower" and child:IsA("Model") then
                for _, part in ipairs(child:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide and part.Position.Y <= skyMaxY - 4 then
                        local topY = part.Position.Y + part.Size.Y * 0.5
                        if topY > bestY then
                            bestY = topY
                            bestPos = Vector3.new(part.Position.X, topY + 3.5, part.Position.Z)
                        end
                    end
                end
            end
        end
    end
    return bestPos
end

local function findNearestWarmPos(fromPos)
    local bestPos, bestDist = nil, math.huge
    for _, inst in ipairs(CollectionService:GetTagged("Warm")) do
        local p = getModelPos(inst)
        if p and isPosSafeFromEdgeAndSea(p) then
            local d = fromPos and (p - fromPos).Magnitude or 0
            if d < bestDist then
                bestDist = d
                bestPos = p + Vector3.new(4, 3, 0)
            end
        end
    end
    local cf = findChildPath(Workspace, "MatchContent", "Campfire")
    if not bestPos and cf then
        local p = getModelPos(cf)
        if p then bestPos = p + Vector3.new(4, 3, 0) end
    end
    return bestPos
end

-- Config Save / Load / Sync Helpers
local function saveConfig()
    local ok, err = pcall(function()
        if isfolder and makefolder and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
        writefile(CONFIG_PATH, HttpService:JSONEncode(State))
    end)
    if ok then
        notify("Config", "Saved configuration to " .. CONFIG_PATH, 2.5)
    else
        notify("Config Error", tostring(err), 3.5)
    end
end

local function applyLoadedValue(key, val)
    if State[key] == nil or type(State[key]) ~= type(val) then return end
    State[key] = val
    local elem = UI_Elements[key]
    if not elem then return end
    pcall(function()
        if type(val) == "boolean" and elem.Set then
            elem:Set(val)
        elseif type(val) == "number" and elem.Set then
            elem:Set(val)
        elseif type(val) == "string" then
            if elem.Select then
                elem:Select(val)
            elseif elem.Set then
                elem:Set(val)
            end
        end
    end)
end

local function loadConfig()
    local ok, msg = pcall(function()
        if not isfile or not isfile(CONFIG_PATH) then
            error("No saved config found at " .. CONFIG_PATH)
        end
        local data = HttpService:JSONDecode(readfile(CONFIG_PATH))
        if type(data) ~= "table" then
            error("Invalid configuration format")
        end
        for k, v in pairs(data) do
            applyLoadedValue(k, v)
        end
    end)
    if ok then
        notify("Config", "Configuration loaded and synchronized!", 2.5)
    else
        notify("Config", tostring(msg), 3)
    end
end

local function resetAllToOff()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
            local elem = UI_Elements[k]
            if elem and elem.Set then
                pcall(function() elem:Set(false) end)
            end
        end
    end
    destroySkyPlatform()
    destroyWaterFloor()
    applyPullHook()
    applyGunMods()
    applyFullbright(false)
    local _, _, hum = getRootAndHum()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    notify("Config", "All features reset to OFF.", 2.5)
end

-- -------------------------------------------------------------------------
-- 6. BUILD 7 WINDUI TABS & ELEMENTS
-- -------------------------------------------------------------------------
local TabSurvival = Window:Tab({ Title = "Survival", Icon = "shield" })
local TabWriter = Window:Tab({ Title = "Writer & Words", Icon = "pen-tool" })
local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local TabEconomy = Window:Tab({ Title = "Loot & Economy", Icon = "coins" })
local TabMovement = Window:Tab({ Title = "Teleport & Move", Icon = "zap" })
local TabVisuals = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- =========================================================================
-- TAB 1: SURVIVAL & IMMUNITIES
-- =========================================================================
TabSurvival:Section({ Title = "Live Survival Telemetry" })
local SurvivalDashboard = TabSurvival:Paragraph({
    Title = "Match & Hazard Monitor",
    Desc = "Reading live arena telemetry...",
})

TabSurvival:Section({ Title = "Smart Disaster Survival" })
UI_Elements.SmartAutoSurvive = TabSurvival:Toggle({
    Title = "Smart Auto-Survive Disasters",
    Desc = "Context AI moves to EscapeShelter for Nuke/Supernova, Tower/Sky for Flood/Lava, Warmth when freezing, and off Doomed tiles",
    Value = false,
    Callback = function(v) State.SmartAutoSurvive = v end,
})

UI_Elements.SkySanctuary = TabSurvival:Toggle({
    Title = "Sky Sanctuary Platform",
    Desc = "Spawns an EdgeGuard-safe floating sanctuary at +130 studs and teleports you above floods, lava, and monsters",
    Value = false,
    Callback = function(v)
        State.SkySanctuary = v
        if v then
            local p = ensureSkyPlatform()
            safeTeleport(p.Position + Vector3.new(0, 4, 0))
            notify("Survival", "Deployed Sky Sanctuary inside EdgeGuard safe zone.", 2.5)
        else
            destroySkyPlatform()
        end
    end,
})

UI_Elements.WalkOnWater = TabSurvival:Toggle({
    Title = "Walk On Water / Lava Surface",
    Desc = "Maintains an invisible platform just above SeaTop so you never sink into water, acid, or lava",
    Value = false,
    Callback = function(v)
        State.WalkOnWater = v
        if not v then destroyWaterFloor() end
    end,
})

UI_Elements.AutoEdgeRescue = TabSurvival:Toggle({
    Title = "Auto EdgeGuard Rescue",
    Desc = "Instantly returns you to safe island center if EdgeWarn (Tentacle or Plane limit) triggers",
    Value = false,
    Callback = function(v) State.AutoEdgeRescue = v end,
})

TabSurvival:Section({ Title = "Hazard & Status Immunities" })
UI_Elements.AntiRagdoll = TabSurvival:Toggle({
    Title = "Anti-Ragdoll",
    Desc = "Prevents Physics ragdoll knockdown and keeps camera locked to your Humanoid",
    Value = false,
    Callback = function(v) State.AntiRagdoll = v end,
})

UI_Elements.AntiSuction = TabSurvival:Toggle({
    Title = "Anti-Suction (BlackHole / Tornado / Magnet)",
    Desc = "Neutralizes PullField velocity pull from black holes, tornadoes, and magnets",
    Value = false,
    Callback = function(v)
        State.AntiSuction = v
        applyPullHook()
    end,
})

UI_Elements.AntiWind = TabSurvival:Toggle({
    Title = "Anti-Wind Push",
    Desc = "Negates lateral wind velocity locally during storms and wind events",
    Value = false,
    Callback = function(v) State.AntiWind = v end,
})

UI_Elements.AntiSlip = TabSurvival:Toggle({
    Title = "Anti-Slip (No Ice Sliding)",
    Desc = "Disables SlipperyVelocity constraints when walking on ice surfaces",
    Value = false,
    Callback = function(v) State.AntiSlip = v end,
})

UI_Elements.AntiMetaLag = TabSurvival:Toggle({
    Title = "Anti-MetaLag (/lag Immunity)",
    Desc = "Prevents /lag rubberbanding and clears the fake ping overlay",
    Value = false,
    Callback = function(v) State.AntiMetaLag = v end,
})

UI_Elements.AutoBreakGrabs = TabSurvival:Toggle({
    Title = "Auto Break Grab & Lava Shell",
    Desc = "Automatically mashes Struggle and Tap remotes when grabbed or encased in lava",
    Value = false,
    Callback = function(v) State.AutoBreakGrabs = v end,
})

UI_Elements.FreezeAnimatronics = TabSurvival:Toggle({
    Title = "360Â° Freeze Animatronic Aura",
    Desc = "Continuously reports line-of-sight directly at active Animatronics to keep them frozen",
    Value = false,
    Callback = function(v) State.FreezeAnimatronics = v end,
})

UI_Elements.SilentSprint = TabSurvival:Toggle({
    Title = "Silent Sprint Stealth (Monster / SirenHead)",
    Desc = "Suppresses server sprint state so sound-reactive monsters cannot detect footsteps",
    Value = false,
    Callback = function(v)
        State.SilentSprint = v
        if v and SetSprintRemote then
            pcall(function() SetSprintRemote:FireServer(false) end)
        end
    end,
})

UI_Elements.ClearVision = TabSurvival:Toggle({
    Title = "Clear Vision (Anti-Blind / Blur / Shake)",
    Desc = "Hides Blind, Temperature vignette, Backrooms/Dive blurs, and cancels camera shake",
    Value = false,
    Callback = function(v) State.ClearVision = v end,
})

-- =========================================================================
-- TAB 2: WRITER & WORDS
-- =========================================================================
TabWriter:Section({ Title = "Live Writer Spy" })
local WriterDashboard = TabWriter:Paragraph({
    Title = "Active Writer Stream",
    Desc = "Waiting for WriterLive broadcasts...",
})

UI_Elements.LiveTypingSpy = TabWriter:Toggle({
    Title = "Lethal Word Typing Alerts",
    Desc = "Shows an instant toast alert when the active writer starts typing a lethal disaster word",
    Value = false,
    Callback = function(v) State.LiveTypingSpy = v end,
})

TabWriter:Section({ Title = "Auto-Writer Engine" })
UI_Elements.AutoWriteOnTurn = TabWriter:Toggle({
    Title = "Auto-Write On Turn",
    Desc = "Automatically submits words when your WriterPrompt triggers (Normal, 2-Words, Duel, Everyone)",
    Value = false,
    Callback = function(v) State.AutoWriteOnTurn = v end,
})

UI_Elements.AutoWriteStrategy = TabWriter:Dropdown({
    Title = "Auto-Write Strategy",
    Desc = "Selects how Auto-Write chooses words on your turn",
    Values = {
        "Undiscovered Diary Words (Cash Farm)",
        "Lethal Disasters",
        "God Morph Powers",
        "Weapons & Loot",
        "Food & Healing",
        "Custom Word",
        "Meta Command (/)",
    },
    Value = "Undiscovered Diary Words (Cash Farm)",
    Callback = function(v) State.AutoWriteStrategy = v end,
})

UI_Elements.CustomWord1 = TabWriter:Input({
    Title = "Custom Word 1",
    Desc = "Used when strategy is Custom Word",
    Placeholder = "e.g. nuke",
    Value = "nuke",
    Callback = function(v) State.CustomWord1 = v end,
})

UI_Elements.CustomWord2 = TabWriter:Input({
    Title = "Custom Word 2 (2-Words Turn)",
    Desc = "Second word used during 2-words turns",
    Placeholder = "e.g. shield",
    Value = "shield",
    Callback = function(v) State.CustomWord2 = v end,
})

UI_Elements.SelectedMetaCommand = TabWriter:Dropdown({
    Title = "Meta Command Selector",
    Desc = "Used when strategy is Meta Command (/)",
    Values = { "/jackpot", "/everyone", "/double", "/secret", "/lag", "/undo", "/fist", "/ghost", "/admin", "/reset", "/chaos", "/god" },
    Value = "/jackpot",
    Callback = function(v) State.SelectedMetaCommand = v end,
})

UI_Elements.AutoUseWriteCredits = TabWriter:Toggle({
    Title = "Auto-Use Write Credits",
    Desc = "Automatically consumes WriteCredits when > 0 to take the next Writer turn",
    Value = false,
    Callback = function(v) State.AutoUseWriteCredits = v end,
})

UI_Elements.AutoPickUndoTarget = TabWriter:Toggle({
    Title = "Auto-Pick /undo Target",
    Desc = "Automatically confirms UndoPick when the /undo selection card appears",
    Value = false,
    Callback = function(v) State.AutoPickUndoTarget = v end,
})

TabWriter:Section({ Title = "Word Validator & Instant Actions" })
UI_Elements.ValidatorWord = TabWriter:Input({
    Title = "Word To Check / Submit",
    Desc = "Enter a word or /command to preview or submit right now",
    Placeholder = "e.g. tsunami",
    Value = "nuke",
    Callback = function(v) State.ValidatorWord = v end,
})

TabWriter:Button({
    Title = "Check Server WordPreview",
    Desc = "Queries WriterRemotes.WordPreview to verify server keyword parsing (active during your turn)",
    Callback = function()
        local w = (State.ValidatorWord or "nuke"):match("^%s*(.-)%s*$") or "nuke"
        if not WordPreviewRemote then
            notify("WordPreview", "WordPreview remote unavailable.", 3)
            return
        end
        local ok, res = pcall(function() return WordPreviewRemote:InvokeServer(w, true) end)
        if ok and type(res) == "table" and type(res.parts) == "table" then
            local kept = {}
            for _, p in ipairs(res.parts) do
                table.insert(kept, string.format("%s(%s)", tostring(p.text), p.kept and "KEPT" or "skip"))
            end
            notify("WordPreview", table.concat(kept, " "), 4)
        else
            notify("WordPreview", ok and "Clean single word or not currently your Writer turn." or tostring(res), 3)
        end
    end,
})

TabWriter:Button({
    Title = "Submit Word Now (If Writer)",
    Desc = "Immediately submits the word above during an active Writer turn",
    Callback = function()
        local w = (State.ValidatorWord or "nuke"):match("^%s*(%S+)") or "nuke"
        local ok, info = submitWordsSafely({ w })
        notify("Writer Submit", (ok and "Sent: " or "Failed: ") .. tostring(info), 3)
    end,
})

TabWriter:Button({
    Title = "Roll Suggestion Dice",
    Desc = "Triggers WriterRemotes.RollDice for slot 1 & 2",
    Callback = function()
        if RollDiceRemote then
            pcall(function() RollDiceRemote:FireServer(1) end)
            pcall(function() RollDiceRemote:FireServer(2) end)
            notify("Writer", "Rolled suggestion dice!", 2)
        end
    end,
})

TabWriter:Section({ Title = "537-Word Diary Catalog Explorer" })
local DiaryExplorerPara = TabWriter:Paragraph({
    Title = "Category Preview",
    Desc = "Select a Diary category below to inspect valid writable words.",
})

local catOptions = { "weapons", "monsters", "animals", "nature", "weather", "disasters", "places", "food", "objects", "memes" }
local function updateDiaryPreview(catId)
    if not DiaryCatalog then return end
    refreshDiaryCache(false)
    local entries = DiaryCatalog.ofCategory(catId)
    local samples = {}
    local unlocked = 0
    for i, e in ipairs(entries) do
        if DiaryCache.pages[e.key] then unlocked += 1 end
        if i <= 24 then
            table.insert(samples, resolveWritableWord(e))
        end
    end
    DiaryExplorerPara:SetTitle(string.format("Category: %s (%d/%d Discovered)", catId:upper(), unlocked, #entries))
    DiaryExplorerPara:SetDesc("Sample words: " .. table.concat(samples, ", "))
end

UI_Elements.SelectedDiaryCategory = TabWriter:Dropdown({
    Title = "Diary Category",
    Values = catOptions,
    Value = "weapons",
    Callback = function(v)
        State.SelectedDiaryCategory = v
        updateDiaryPreview(v)
    end,
})

-- =========================================================================
-- TAB 3: COMBAT
-- =========================================================================
TabCombat:Section({ Title = "Live Combat Telemetry" })
local CombatDashboard = TabCombat:Paragraph({
    Title = "Weapon & Target Status",
    Desc = "Scanning equipped tools and active targets...",
})

TabCombat:Section({ Title = "Ranged & Melee Automation" })
UI_Elements.GunSilentAim = TabCombat:Toggle({
    Title = "Gun Silent Aim / Auto-Shoot Aura",
    Desc = "Automatically fires equipped WeaponId gun at targets within range with Headshot priority",
    Value = false,
    Callback = function(v) State.GunSilentAim = v end,
})

UI_Elements.CombatTargetFilter = TabCombat:Dropdown({
    Title = "Combat Target Filter",
    Values = { "Bosses & Creatures Only", "Players Only", "Bosses & Players (All)" },
    Value = "Bosses & Creatures Only",
    Callback = function(v) State.CombatTargetFilter = v end,
})

UI_Elements.GunMods = TabCombat:Toggle({
    Title = "Gun Mods (No Spread / No Recoil / Full-Auto)",
    Desc = "Zeroes spread, bloom, recoil, and spin-up delay; restores original WeaponConfig on disable",
    Value = false,
    Callback = function(v)
        State.GunMods = v
        applyGunMods()
    end,
})

UI_Elements.RapidFire = TabCombat:Toggle({
    Title = "Rapid Fire Boost",
    Desc = "Multiplies fire rate cleanly within server RATE_TOLERANCE",
    Value = false,
    Callback = function(v)
        State.RapidFire = v
        applyGunMods()
    end,
})

UI_Elements.RapidFireMultiplier = TabCombat:Slider({
    Title = "Rapid Fire Multiplier",
    Desc = "1.3x stays reliably within server fire-rate validation",
    Value = { Min = 1.0, Max = 2.5, Default = 1.3 },
    Step = 0.05,
    Callback = function(v)
        State.RapidFireMultiplier = v
        if State.RapidFire then applyGunMods() end
    end,
})

UI_Elements.MeleeKillAura = TabCombat:Toggle({
    Title = "Melee & Fist Kill Aura",
    Desc = "Auto-swings equipped MeleeId weapon at nearby bosses, creatures, or rival players",
    Value = false,
    Callback = function(v) State.MeleeKillAura = v end,
})

TabCombat:Section({ Title = "Carry Throw & Mastery Quake" })
UI_Elements.AutoCarryYeet = TabCombat:Toggle({
    Title = "Auto Carry & Full-Power Yeet",
    Desc = "Automatically picks up nearby Carryable objects/players and launches at full charge",
    Value = false,
    Callback = function(v) State.AutoCarryYeet = v end,
})

UI_Elements.YeetDirection = TabCombat:Dropdown({
    Title = "Yeet Throw Direction",
    Values = { "Towards Ocean Edge", "Straight Up", "Camera LookVector" },
    Value = "Towards Ocean Edge",
    Callback = function(v) State.YeetDirection = v end,
})

UI_Elements.AutoQuakeRival = TabCombat:Toggle({
    Title = "Auto Quake Path Under Nearest Rival",
    Desc = "Automatically targets the closest alive rival when Mastery QuakeDraw activates",
    Value = false,
    Callback = function(v) State.AutoQuakeRival = v end,
})

-- =========================================================================
-- TAB 4: LOOT & ECONOMY
-- =========================================================================
TabEconomy:Section({ Title = "Live Economy Telemetry" })
local EconomyDashboard = TabEconomy:Paragraph({
    Title = "Wallet, Items & Diary Progress",
    Desc = "Querying account inventory and diary progress...",
})

TabEconomy:Section({ Title = "World Pickups & Sustenance" })
UI_Elements.AutoCollectCoins = TabEconomy:Toggle({
    Title = "Auto Collect World Coins",
    Desc = "Safely micro-blinks to Coin-tagged pickups within EdgeGuard bounds and restores position",
    Value = false,
    Callback = function(v) State.AutoCollectCoins = v end,
})

UI_Elements.AutoPickupWorldLoot = TabEconomy:Toggle({
    Title = "Auto Pickup World Weapons, Loot & AirDrops",
    Desc = "Micro-blinks to safe unclaimed guns, melee drops, diamonds, and AirDrop crates",
    Value = false,
    Callback = function(v) State.AutoPickupWorldLoot = v end,
})

UI_Elements.AutoEatFood = TabEconomy:Toggle({
    Title = "Auto Eat World Food / Medkit When Low",
    Desc = "Collects nearby safe world food or uses Medkit/Bandage when HP or Hunger drops below threshold",
    Value = false,
    Callback = function(v) State.AutoEatFood = v end,
})

UI_Elements.HealThreshold = TabEconomy:Slider({
    Title = "Auto Heal / Food Threshold (%)",
    Value = { Min = 15, Max = 90, Default = 55 },
    Step = 5,
    Callback = function(v) State.HealThreshold = v end,
})

TabEconomy:Section({ Title = "Diary Rewards, Item Gacha & Loadout" })
local function claimAllDiaryRewards()
    if not DiaryRequest or not DiaryConfig then return 0 end
    local claimedCount = 0
    for _, cat in ipairs(DiaryConfig.CATEGORIES or {}) do
        local ok, res = pcall(function() return DiaryRequest:InvokeServer("claim", cat.id) end)
        if ok and res == true then
            claimedCount += 1
        elseif ok and type(res) == "table" and res.ok == true then
            claimedCount += 1
        end
    end
    refreshDiaryCache(true)
    return claimedCount
end

local function equipBestLoadout()
    if not ItemsRequest or not ItemLibrary then return false, "Missing ItemLibrary/Remote" end
    refreshItemsCache(true)
    local tierRank = {}
    for idx, t in ipairs(ItemLibrary.Tiers or {}) do
        tierRank[t.name] = idx
    end
    local ownedList = {}
    for k, v in pairs(ItemsCache.owned) do
        local itemId = type(k) == "number" and v or k
        local info = ItemLibrary.get and ItemLibrary.get(itemId)
        if info then
            table.insert(ownedList, { id = info.id, rank = tierRank[info.tier] or 0 })
        end
    end
    table.sort(ownedList, function(a, b) return a.rank > b.rank end)
    local slots = {}
    local size = ItemLibrary.LOADOUT_SIZE or 5
    for i = 1, size do
        slots[i] = (ownedList[i] and ownedList[i].id) or ""
    end
    local ok, res = pcall(function() return ItemsRequest:InvokeServer("loadout", slots) end)
    return ok, table.concat(slots, ", ")
end

UI_Elements.AutoClaimDiary = TabEconomy:Toggle({
    Title = "Auto Claim Diary Milestone Cash",
    Desc = "Periodically claims unlocked 5-word milestone Cash rewards across all 10 Diary categories",
    Value = false,
    Callback = function(v) State.AutoClaimDiary = v end,
})

TabEconomy:Button({
    Title = "Claim All Diary Rewards Now",
    Desc = "Attempts to claim every category milestone right now",
    Callback = function()
        local n = claimAllDiaryRewards()
        notify("Diary", n > 0 and ("Claimed " .. n .. " category reward(s)!") or "No pending category milestones ready.", 3)
    end,
})

UI_Elements.AutoRollFreeGacha = TabEconomy:Toggle({
    Title = "Auto Roll Item Gacha (Free Spins)",
    Desc = "Consumes free spins automatically via Items.Remotes.Request",
    Value = false,
    Callback = function(v) State.AutoRollFreeGacha = v end,
})

UI_Elements.AutoRollCashGacha = TabEconomy:Toggle({
    Title = "Auto Roll Item Gacha (With Cash)",
    Desc = "Spins item gacha automatically whenever Cash >= spin price",
    Value = false,
    Callback = function(v) State.AutoRollCashGacha = v end,
})

TabEconomy:Button({
    Title = "Roll 1x Item Gacha Now",
    Desc = "Executes one item roll right now",
    Callback = function()
        if not ItemsRequest then return end
        local ok, res = pcall(function() return ItemsRequest:InvokeServer("spin") end)
        refreshItemsCache(true)
        notify("Item Roll", ok and ("Roll result: " .. tostring(type(res) == "table" and (res.id or res.item or res.error or "Done") or res)) or tostring(res), 3)
    end,
})

UI_Elements.AutoEquipBestLoadout = TabEconomy:Toggle({
    Title = "Auto Equip Best 5-Slot Loadout",
    Desc = "Keeps your highest-rarity owned items (Mythical -> Common) equipped in loadout slots",
    Value = false,
    Callback = function(v) State.AutoEquipBestLoadout = v end,
})

TabEconomy:Button({
    Title = "Equip Best Loadout Now",
    Desc = "Immediately sorts owned items by tier and equips top 5 slots",
    Callback = function()
        local ok, info = equipBestLoadout()
        notify("Loadout", ok and ("Equipped: " .. info) or tostring(info), 3)
    end,
})

UI_Elements.AutoFreeRevive = TabEconomy:Toggle({
    Title = "Auto Free Revive",
    Desc = "Fires FreeReviveRemote automatically when a free revive offer is available on death",
    Value = false,
    Callback = function(v) State.AutoFreeRevive = v end,
})

-- =========================================================================
-- TAB 5: TELEPORT & MOVEMENT
-- =========================================================================
TabMovement:Section({ Title = "AFK & Character Physics" })
UI_Elements.AntiAfk = TabMovement:Toggle({
    Title = "Anti-AFK (20-Min Idle Protection)",
    Desc = "Prevents Roblox idle disconnection via VirtualUser Idled listener",
    Value = false,
    Callback = function(v) State.AntiAfk = v end,
})

UI_Elements.CustomWalkSpeed = TabMovement:Toggle({
    Title = "Custom WalkSpeed",
    Value = false,
    Callback = function(v)
        State.CustomWalkSpeed = v
        if not v then
            local _, _, hum = getRootAndHum()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

UI_Elements.WalkSpeed = TabMovement:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 120, Default = 32 },
    Step = 1,
    Callback = function(v) State.WalkSpeed = v end,
})

UI_Elements.CustomJumpPower = TabMovement:Toggle({
    Title = "Custom JumpPower",
    Value = false,
    Callback = function(v)
        State.CustomJumpPower = v
        if not v then
            local _, _, hum = getRootAndHum()
            if hum then hum.JumpPower = 50 end
        end
    end,
})

UI_Elements.JumpPower = TabMovement:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 200, Default = 75 },
    Step = 1,
    Callback = function(v) State.JumpPower = v end,
})

UI_Elements.InfiniteJump = TabMovement:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})

UI_Elements.NoClip = TabMovement:Toggle({
    Title = "NoClip",
    Value = false,
    Callback = function(v) State.NoClip = v end,
})

UI_Elements.Fly = TabMovement:Toggle({
    Title = "Flight Mode",
    Desc = "Camera-directional 3D flight (WASD + Space / LeftShift)",
    Value = false,
    Callback = function(v) State.Fly = v end,
})

UI_Elements.FlySpeed = TabMovement:Slider({
    Title = "Fly Speed",
    Value = { Min = 20, Max = 150, Default = 60 },
    Step = 2,
    Callback = function(v) State.FlySpeed = v end,
})

TabMovement:Section({ Title = "Safe World Teleports" })
TabMovement:Button({
    Title = "Teleport: Escape Shelter / Bunker",
    Callback = function()
        local pos = findEscapeShelterPos()
        if pos and safeTeleport(pos) then
            notify("Teleport", "Warped inside Escape Shelter!", 2)
        else
            notify("Teleport", "No Escape Shelter active in current map.", 2.5)
        end
    end,
})

TabMovement:Button({
    Title = "Teleport: Highest Escape Tower / HighGround",
    Callback = function()
        local pos = findHighestEscapeTowerPos()
        if pos and safeTeleport(pos) then
            notify("Teleport", "Warped to highest safe HighGround!", 2)
        else
            notify("Teleport", "No Escape Tower found in current map.", 2.5)
        end
    end,
})

TabMovement:Button({
    Title = "Teleport: Nearest Warm Campfire",
    Callback = function()
        local _, hrp = getRootAndHum()
        local pos = findNearestWarmPos(hrp and hrp.Position)
        if pos and safeTeleport(pos) then
            notify("Teleport", "Warped to warmth!", 2)
        else
            notify("Teleport", "No Campfire / Warm zone active.", 2.5)
        end
    end,
})

TabMovement:Button({
    Title = "Teleport: Safe Island Center",
    Callback = function()
        safeTeleport(getSafeCenterPos(8))
        notify("Teleport", "Returned to safe island center.", 2)
    end,
})

TabMovement:Button({
    Title = "Teleport: Active AirDrop / Chest",
    Callback = function()
        local mc = Workspace:FindFirstChild("MatchContent")
        local targetPos = nil
        if mc then
            for _, d in ipairs(mc:GetDescendants()) do
                if d.Name == "AirDrop" or d.Name:match("Chest") or d:GetAttribute("LootKind") then
                    local p = getModelPos(d)
                    if p and isPosSafeFromEdgeAndSea(p) then
                        targetPos = p + Vector3.new(0, 4, 0)
                        break
                    end
                end
            end
        end
        if targetPos and safeTeleport(targetPos) then
            notify("Teleport", "Warped to active AirDrop / Loot!", 2)
        else
            notify("Teleport", "No safe AirDrop or Chest active right now.", 2.5)
        end
    end,
})

TabMovement:Button({
    Title = "Return To Lobby Server",
    Desc = "Invokes LobbyReturnRequest to leave the match",
    Callback = function()
        if LobbyReturnRemote then
            pcall(function() LobbyReturnRemote:InvokeServer() end)
        else
            notify("Lobby", "Already in Lobby or LobbyReturnRequest unavailable.", 2.5)
        end
    end,
})

-- =========================================================================
-- TAB 6: VISUALS & ESP
-- =========================================================================
TabVisuals:Section({ Title = "Tactical Overlays & ESP" })
UI_Elements.BossESP = TabVisuals:Toggle({
    Title = "Boss & Creature ESP (Live HP)",
    Value = false,
    Callback = function(v) State.BossESP = v end,
})

UI_Elements.PlayerESP = TabVisuals:Toggle({
    Title = "Player ESP (Name, Tool & Distance)",
    Value = false,
    Callback = function(v) State.PlayerESP = v end,
})

UI_Elements.LootESP = TabVisuals:Toggle({
    Title = "Loot, Weapons, Food & AirDrop ESP",
    Value = false,
    Callback = function(v) State.LootESP = v end,
})

UI_Elements.ShelterESP = TabVisuals:Toggle({
    Title = "Shelter & Escape Tower ESP",
    Value = false,
    Callback = function(v) State.ShelterESP = v end,
})

UI_Elements.DoomedTilesESP = TabVisuals:Toggle({
    Title = "Doomed / Falling Tiles Warning Highlight",
    Value = false,
    Callback = function(v) State.DoomedTilesESP = v end,
})

UI_Elements.Fullbright = TabVisuals:Toggle({
    Title = "Fullbright & No Fog",
    Value = false,
    Callback = function(v)
        State.Fullbright = v
        applyFullbright(v)
    end,
})

-- =========================================================================
-- TAB 7: CONFIG & LIFECYCLE
-- =========================================================================
TabConfig:Section({ Title = "Profile Persistence" })
TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Saves all toggles, sliders, inputs, and strategies to disk",
    Callback = saveConfig,
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Loads saved configuration from disk and updates all UI elements",
    Callback = loadConfig,
})

TabConfig:Button({
    Title = "Reset All Settings (All OFF)",
    Desc = "Disables every active feature and restores original game values",
    Callback = resetAllToOff,
})

TabConfig:Section({ Title = "Session Lifecycle" })
UI_Elements.AutoReExecuteOnTeleport = TabConfig:Toggle({
    Title = "Auto Re-Execute On Match Teleport",
    Desc = "Queues script re-execution across Lobby <-> Match teleports via queue_on_teleport",
    Value = false,
    Callback = function(v) State.AutoReExecuteOnTeleport = v end,
})

TabConfig:Button({
    Title = "Unload XLunaHUB",
    Desc = "Cleanly removes all hooks, threads, platforms, ESP, and destroys this UI",
    Callback = function()
        if getgenv().XLunaSYI_Unload then
            getgenv().XLunaSYI_Unload()
        end
    end,
})

TabConfig:Paragraph({
    Title = "XLunaHUB Compliance Summary",
    Desc = "Toggle UI: LeftControl or Floating Button | Startup Default: ALL OFF | Built with WindUI",
})

pcall(function() Window:SelectTab(1) end)
pcall(updateDiaryPreview, "weapons")

-- -------------------------------------------------------------------------
-- 7. BACKGROUND ENGINES & SIGNAL LISTENERS
-- -------------------------------------------------------------------------

-- Anti-AFK listener
trackConn(LocalPlayer.Idled:Connect(function()
    if State.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

-- Infinite Jump listener
trackConn(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local _, _, hum = getRootAndHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- Writer Signals (Auto-Write, Typing Spy, Announcements)
if WriterPromptRemote then
    trackConn(WriterPromptRemote.OnClientEvent:Connect(function(seconds, maxLen, wordCount, mode)
        local isOpen = type(seconds) == "number" and seconds > 0
        LiveWriterInfo.IsMyTurn = isOpen
        LiveWriterInfo.TurnWordCount = wordCount == 2 and 2 or 1
        LiveWriterInfo.TurnMode = mode or "Normal"
        if isOpen and State.AutoWriteOnTurn then
            task.delay(0.25, function()
                if not State.AutoWriteOnTurn or not LiveWriterInfo.IsMyTurn then return end
                local words = pickAutoWords(LiveWriterInfo.TurnWordCount)
                local ok, info = submitWordsSafely(words)
                notify("Auto-Write", (ok and "Submitted: " or "Error: ") .. tostring(info), 3)
            end)
        end
    end))
end

if WriterLiveRemote then
    trackConn(WriterLiveRemote.OnClientEvent:Connect(function(kind, text, writerName)
        if kind == "begin" and type(writerName) == "string" then
            LiveWriterInfo.WriterName = writerName
            LiveWriterInfo.TypingText = ""
        elseif kind == "text" and type(text) == "string" then
            LiveWriterInfo.TypingText = text
            if State.LiveTypingSpy and text ~= "" and os.clock() - LiveWriterInfo.LastToastAt > 2.5 then
                local low = text:lower():gsub("%s+", "")
                if LethalAlertWords[low] then
                    LiveWriterInfo.LastToastAt = os.clock()
                    notify("LIVE WRITER ALERT", string.format("%s is typing: %s!", LiveWriterInfo.WriterName, text:upper()), 4)
                end
            end
        elseif kind == "stamp" then
            LiveWriterInfo.TypingText = ""
        end
    end))
end

if WordAnnouncedRemote then
    trackConn(WordAnnouncedRemote.OnClientEvent:Connect(function(richHtml, tone, category)
        if type(richHtml) == "string" then
            local w = richHtml:match("<i>(.-)</i>") or richHtml:gsub("<[^>]+>", "")
            LiveWriterInfo.LastWord = w ~= "" and w or "Unknown"
            LiveWriterInfo.LastCategory = type(category) == "string" and category or tostring(tone or "neutral")
        end
    end))
end

-- Auto-Pick /undo target when MetaWords Effect triggers undo UI
if MetaEffectRemote and UndoPickRemote then
    trackConn(MetaEffectRemote.OnClientEvent:Connect(function(kind, payload)
        if State.AutoPickUndoTarget and kind == "undoPrompt" and type(payload) == "table" and type(payload.items) == "table" then
            local first = payload.items[1]
            if type(first) == "table" and type(first.key) == "number" then
                task.delay(0.2, function()
                    pcall(function() UndoPickRemote:FireServer(first.key) end)
                end)
            end
        end
    end))
end

-- Auto QuakeDraw Targeting
if QuakeDrawRemote then
    trackConn(QuakeDrawRemote.OnClientEvent:Connect(function(kind, payload)
        if not State.AutoQuakeRival or kind ~= "begin" or type(payload) ~= "table" or type(payload.tiles) ~= "table" then
            return
        end
        local _, hrp = getRootAndHum()
        local refPos = hrp and hrp.Position or getSafeCenterPos(10)
        local rivalPos, rivalDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local rHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local rHum = plr.Character:FindFirstChildOfClass("Humanoid")
                if rHrp and rHum and rHum.Health > 0 then
                    local d = (rHrp.Position - refPos).Magnitude
                    if d < rivalDist then
                        rivalDist = d
                        rivalPos = rHrp.Position
                    end
                end
            end
        end
        if not rivalPos then rivalPos = refPos end
        local ranked = {}
        for _, t in ipairs(payload.tiles) do
            if type(t) == "table" and type(t[1]) == "number" and type(t[3]) == "number" then
                local dx = t[3] - rivalPos.X
                local dz = t[4] - rivalPos.Z
                table.insert(ranked, { x = t[1], z = t[2], d2 = dx * dx + dz * dz })
            end
        end
        table.sort(ranked, function(a, b) return a.d2 < b.d2 end)
        local limit = math.clamp(math.floor(tonumber(payload.limit) or 2), 1, #ranked)
        local chosen = {}
        for i = 1, limit do
            table.insert(chosen, { ranked[i].x, ranked[i].z })
        end
        if #chosen > 0 then
            task.delay(0.15, function()
                pcall(function() QuakeDrawRemote:FireServer("path", chosen) end)
                notify("Combat", "Submitted Quake path under nearest rival!", 2)
            end)
        end
    end))
end

-- Auto Re-Execute on Teleport hook
trackConn(LocalPlayer.OnTeleport:Connect(function(tpState)
    if State.AutoReExecuteOnTeleport and tpState == Enum.TeleportState.Started and queue_on_teleport then
        pcall(function()
            local src = getgenv().XLunaSYI_Source
            if type(src) ~= "string" and isfile and isfile("SurviveYourIdeas_Master.lua") then
                src = readfile("SurviveYourIdeas_Master.lua")
            end
            if type(src) == "string" and #src > 100 then
                queue_on_teleport(src)
            end
        end)
    end
end))

-- Fast Frame Physics & Immunity Loop
trackConn(RunService.Stepped:Connect(function(_, dt)
    local char, hrp, hum = getRootAndHum()
    if not char or not hrp or not hum then return end

    if State.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if State.CustomWalkSpeed and hum.WalkSpeed ~= State.WalkSpeed then
        hum.WalkSpeed = State.WalkSpeed
    end
    if State.CustomJumpPower then
        hum.UseJumpPower = true
        if hum.JumpPower ~= State.JumpPower then
            hum.JumpPower = State.JumpPower
        end
    end

    if State.Fly then
        local cam = Workspace.CurrentCamera
        if cam then
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
            hrp.AssemblyLinearVelocity = move.Magnitude > 0 and (move.Unit * State.FlySpeed) or Vector3.new(0, 0.05, 0)
        end
    end

    if State.AntiRagdoll then
        if char:GetAttribute("Ragdolled") then
            char:SetAttribute("Ragdolled", nil)
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        if hum:GetState() == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        local cam = Workspace.CurrentCamera
        if cam and cam.CameraSubject ~= hum then
            cam.CameraSubject = hum
        end
    end

    if State.AntiSlip then
        local slipVel = hrp:FindFirstChild("SlipperyVelocity")
        if slipVel and slipVel:IsA("LinearVelocity") and slipVel.Enabled then
            slipVel.Enabled = false
        end
    end

    if State.AntiWind then
        local ws = Workspace:GetAttribute("WindSpeed") or 0
        if ws > 0 then
            Workspace:SetAttribute("WindSpeed", 0)
        end
    end

    if State.AntiMetaLag then
        local untilTs = Workspace:GetAttribute("MetaLagUntil")
        if type(untilTs) == "number" and Workspace:GetServerTimeNow() < untilTs then
            Workspace:SetAttribute("MetaLagSpared", LocalPlayer.UserId)
        end
    end

    if State.WalkOnWater then
        local _, _, _, _, seaTop = getEdgeBounds()
        local floor = ensureWaterFloor()
        local safeXZ = clampSafePos(hrp.Position)
        floor.CFrame = CFrame.new(safeXZ.X, seaTop + 0.4, safeXZ.Z)
    end

    if State.AutoEdgeRescue then
        local min2, max2, _, skyMaxY = getEdgeBounds()
        local p = hrp.Position
        local outOfBounds = LocalPlayer:GetAttribute("EdgeWarn") ~= nil
            or p.X < min2.X + 1
            or p.X > max2.X - 1
            or p.Z < min2.Y + 1
            or p.Z > max2.Y - 1
            or p.Y > skyMaxY
        if outOfBounds then
            safeTeleport(getSafeCenterPos(12))
        end
    end

    if State.ClearVision then
        for _, guiName in ipairs({"SYI_Blind", "SYI_TemperatureEdge"}) do
            local g = PlayerGui:FindFirstChild(guiName)
            if g and g:IsA("ScreenGui") and g.Enabled then
                g.Enabled = false
            end
        end
        for _, fx in ipairs({Lighting, Workspace.CurrentCamera}) do
            if fx then
                for _, child in ipairs(fx:GetChildren()) do
                    if child:IsA("BlurEffect") or (child:IsA("ColorCorrectionEffect") and child.Name == "DiveTint") then
                        child.Enabled = false
                    end
                end
            end
        end
        pcall(function() RunService:UnbindFromRenderStep("WordCameraShake") end)
    end
end))

-- High-Frequency Survival / Grabs / Animatronic / Combat Loop
trackThread(function()
    local nextGunShotAt = 0
    local nextMeleeAt = 0
    local meleeSeq = 0
    local meleeCombo = 0
    local nextAnimLookAt = 0
    local nextSilentSprintAt = 0
    local nextSurviveMoveAt = 0

    while true do
        task.wait(0.06)
        local now = os.clock()
        local char, hrp, hum = getRootAndHum()

        -- Break Grabs & Lava Shell
        if State.AutoBreakGrabs and char then
            if GrabStruggleRemote and (PlayerGui:FindFirstChild("SYI_Grab") or char:GetAttribute("Grabbed")) then
                pcall(function() GrabStruggleRemote:FireServer() end)
            end
            if LavaShellTapRemote and (PlayerGui:FindFirstChild("SYI_LavaShell") or CollectionService:HasTag(char, "LavaShelled")) then
                pcall(function() LavaShellTapRemote:FireServer() end)
            end
        end

        -- 360Â° Freeze Animatronic Aura
        if State.FreezeAnimatronics and hrp and now >= nextAnimLookAt then
            nextAnimLookAt = now + 0.18
            local animRemotes = ReplicatedStorage:FindFirstChild("AnimatronicRemotes")
            local lookRemote = animRemotes and animRemotes:FindFirstChild("Look")
            if lookRemote and lookRemote:IsA("UnreliableRemoteEvent") then
                local headPos = (char:FindFirstChild("Head") or hrp).Position
                local sent = false
                local mc = Workspace:FindFirstChild("MatchContent")
                if mc then
                    for _, inst in ipairs(mc:GetDescendants()) do
                        if inst:IsA("Model") and (inst.Name:lower():find("animatronic") or inst:GetAttribute("UsedBy") == "animatronic") then
                            local tp = getModelPos(inst)
                            if tp then
                                local dir = (tp - headPos).Magnitude > 0.1 and (tp - headPos).Unit or Vector3.new(0, 0, -1)
                                pcall(function() lookRemote:FireServer(dir, headPos) end)
                                sent = true
                            end
                        end
                    end
                end
                if not sent then
                    local cam = Workspace.CurrentCamera
                    if cam then
                        pcall(function() lookRemote:FireServer(cam.CFrame.LookVector, headPos) end)
                    end
                end
            end
        end

        -- Silent Sprint Stealth
        if State.SilentSprint and SetSprintRemote and now >= nextSilentSprintAt then
            nextSilentSprintAt = now + 0.5
            pcall(function() SetSprintRemote:FireServer(false) end)
        end

        -- Smart Auto-Survive Disasters AI
        if State.SmartAutoSurvive and char and hrp and hum and hum.Health > 0 and now >= nextSurviveMoveAt then
            local _, _, floorY, _, seaTop = getEdgeBounds()
            local bodyTemp = LocalPlayer:GetAttribute("BodyTemp") or 0
            local lastLow = (LiveWriterInfo.LastWord or ""):lower()
            local needShelter = lastLow:find("nuke") or lastLow:find("supernova") or lastLow:find("airstrike")
                or lastLow:find("meteor") or findChildPath(Workspace, "MatchContent", "Preset_apocalypse") ~= nil
            local needWarmth = type(bodyTemp) == "number" and bodyTemp < -35
            local needHeight = seaTop > floorY - 2
                or #CollectionService:GetTagged("LavaFlood") > 0
                or #CollectionService:GetTagged("TsunamiWave") > 0
                or #CollectionService:GetTagged("AvalancheMountain") > 0
                or lastLow:find("tsunami") or lastLow:find("flood")
                or lastLow:find("lava") or findChildPath(Workspace, "MatchContent", "Preset_tsunami") ~= nil

            if needShelter then
                local sp = findEscapeShelterPos()
                if sp and (hrp.Position - sp).Magnitude > 14 then
                    safeTeleport(sp)
                    nextSurviveMoveAt = now + 0.6
                end
            elseif needWarmth then
                local wp = findNearestWarmPos(hrp.Position)
                if wp and (hrp.Position - wp).Magnitude > 10 then
                    safeTeleport(wp)
                    nextSurviveMoveAt = now + 0.6
                end
            elseif needHeight then
                local tp = findHighestEscapeTowerPos()
                if tp and hrp.Position.Y < tp.Y - 4 then
                    safeTeleport(tp)
                    nextSurviveMoveAt = now + 0.6
                elseif not tp then
                    local plat = ensureSkyPlatform()
                    if hrp.Position.Y < plat.Position.Y - 4 then
                        safeTeleport(plat.Position + Vector3.new(0, 4, 0))
                        nextSurviveMoveAt = now + 0.6
                    end
                end
            elseif not State.SkySanctuary and not State.WalkOnWater and not State.Fly then
                -- Check if standing on a blinking doomed tile or over missing floor near sea level
                local gt = Workspace:FindFirstChild("GroundTiles")
                if gt and hrp.Position.Y <= floorY + 18 then
                    local standingSafe = false
                    local nearestSafeTile, nearestDist = nil, math.huge
                    for _, tile in ipairs(gt:GetChildren()) do
                        if tile:IsA("BasePart") and tile.CanCollide then
                            local isDoomed = tile.Color.R > 0.75 and tile.Color.G < 0.35
                            local dx = math.abs(hrp.Position.X - tile.Position.X)
                            local dz = math.abs(hrp.Position.Z - tile.Position.Z)
                            if not isDoomed then
                                if dx <= tile.Size.X * 0.5 and dz <= tile.Size.Z * 0.5 then
                                    standingSafe = true
                                end
                                local d = (tile.Position - hrp.Position).Magnitude
                                if d < nearestDist then
                                    nearestDist = d
                                    nearestSafeTile = tile
                                end
                            end
                        end
                    end
                    if not standingSafe and nearestSafeTile then
                        safeTeleport(nearestSafeTile.Position + Vector3.new(0, nearestSafeTile.Size.Y * 0.5 + 3.5, 0))
                        nextSurviveMoveAt = now + 0.5
                    end
                end
            end
        end

        -- Gun Silent Aim / Auto-Shoot Aura
        if State.GunSilentAim and WeaponFireRemote and WeaponConfig and char and hrp and hum and hum.Health > 0 and now >= nextGunShotAt then
            local tool = char:FindFirstChildOfClass("Tool")
            local weaponId = tool and tool:GetAttribute("WeaponId")
            local weapon = weaponId and WeaponConfig.get and WeaponConfig.get(weaponId)
            if weapon and not tool:GetAttribute("Vanishing") then
                local ammoAttr = tool:GetAttribute("Ammo")
                if ammoAttr == nil or ammoAttr > 0 or tool:GetAttribute("InfiniteAmmo") == true then
                    local origin = hrp.Position + Vector3.new(0, 1.5, 0)
                    local target = findNearestTarget(origin, weapon.range or 300, State.CombatTargetFilter)
                    if target then
                        local diff = target.part.Position - origin
                        local dir = diff.Magnitude > 0.05 and diff.Unit or Vector3.new(0, 0, -1)
                        local shots = {}
                        if weapon.projectile == "hitscan" then
                            local count = math.max(1, tonumber(weapon.pellets) or 1)
                            for i = 1, count do
                                table.insert(shots, { dir, target.part, target.part.Position })
                            end
                        else
                            table.insert(shots, { dir })
                        end
                        pcall(function() WeaponFireRemote:FireServer(origin, shots) end)
                        local rate = math.max(0.5, tonumber(weapon.fireRate) or 4)
                        nextGunShotAt = now + (1 / rate)
                    end
                end
            end
        end

        -- Melee & Fist Kill Aura
        if State.MeleeKillAura and MeleeSwingRemote and MeleeHitRemote and MeleeConfig and char and hrp and hum and hum.Health > 0 and now >= nextMeleeAt then
            local tool = char:FindFirstChildOfClass("Tool")
            local meleeId = tool and tool:GetAttribute("MeleeId")
            local melee = meleeId and MeleeConfig.get and MeleeConfig.get(meleeId)
            if melee then
                local reach = math.max(10, (melee.radius or 1.2) + (MeleeConfig.REACH_SLACK or 5) + 4)
                local target = findNearestTarget(hrp.Position, reach, State.CombatTargetFilter)
                if target then
                    meleeSeq += 1
                    meleeCombo = (meleeCombo % 3) + 1
                    pcall(function()
                        MeleeSwingRemote:FireServer(meleeSeq, meleeCombo)
                        MeleeHitRemote:FireServer(meleeSeq, { target.part })
                    end)
                    local swingSec = type(MeleeConfig.swingSeconds) == "function" and MeleeConfig.swingSeconds(meleeId, false) or 0.38
                    nextMeleeAt = now + math.max(0.18, swingSec * 0.85)
                end
            end
        end
    end
end)

-- Slow Loop: Pickups, Food, Carry Yeet, Diary Claims, Gacha, Loadout, WriteCredits, Revive (0.35s)
trackThread(function()
    local nextWorldCollectAt = 0
    local nextEconomyAt = 0
    while true do
        task.wait(0.35)
        local now = os.clock()
        local char, hrp, hum = getRootAndHum()

        -- Auto Free Revive
        if State.AutoFreeRevive and FreeReviveRemote then
            local freeAttr = ReviveConfig and ReviveConfig.FREE_ATTRIBUTE or "FreeReviveOffer"
            if LocalPlayer:GetAttribute(freeAttr) == true then
                pcall(function() FreeReviveRemote:FireServer() end)
            end
        end

        -- Auto Carry & Full-Power Yeet
        if State.AutoCarryYeet and CarryRequestRemote and char and hrp and hum and hum.Health > 0 then
            if char:GetAttribute("Carrying") == true then
                local dir = Vector3.new(0, 0.4, 1)
                if State.YeetDirection == "Straight Up" then
                    dir = Vector3.new(0, 1, 0)
                elseif State.YeetDirection == "Camera LookVector" and Workspace.CurrentCamera then
                    dir = Workspace.CurrentCamera.CFrame.LookVector
                else
                    local center = getSafeCenterPos(hrp.Position.Y)
                    local out = hrp.Position - center
                    dir = (Vector3.new(out.X, 0, out.Z).Magnitude > 0.5 and Vector3.new(out.X, 0, out.Z).Unit or Vector3.new(1, 0, 0)) + Vector3.new(0, 0.35, 0)
                    dir = dir.Unit
                end
                pcall(function()
                    CarryRequestRemote:FireServer("charge")
                    task.wait(0.08)
                    CarryRequestRemote:FireServer("throw", dir, 1)
                end)
            else
                local range = (CarryConfig and CarryConfig.PICKUP_RANGE or 7) + 1
                local tag = CarryConfig and CarryConfig.CARRYABLE_TAG or "Carryable"
                for _, item in ipairs(CollectionService:GetTagged(tag)) do
                    if item:IsA("Model") and item:GetAttribute("CarriedBy") == nil and not item:GetAttribute("NoCarry") then
                        local pos = getModelPos(item)
                        if pos and (pos - hrp.Position).Magnitude <= range then
                            pcall(function() CarryRequestRemote:FireServer("pick", item) end)
                            break
                        end
                    end
                end
            end
        end

        -- World Collectibles (Coins, Loot, Food) with Safe EdgeGuard Micro-Blink
        if char and hrp and hum and hum.Health > 0 and now >= nextWorldCollectAt then
            local targetPickupPos = nil
            local hunger = LocalPlayer:GetAttribute("Hunger") or 100
            local hpPct = hum.MaxHealth > 0 and (hum.Health / hum.MaxHealth) * 100 or 100
            local needHeal = hpPct <= State.HealThreshold or (type(hunger) == "number" and hunger <= State.HealThreshold)

            if State.AutoEatFood and needHeal then
                local mc = Workspace:FindFirstChild("MatchContent")
                if mc then
                    for _, d in ipairs(mc:GetDescendants()) do
                        if d:GetAttribute("IsFood") == true then
                            local p = getModelPos(d)
                            if p and isPosSafeFromEdgeAndSea(p) then
                                targetPickupPos = p + Vector3.new(0, 2, 0)
                                break
                            end
                        end
                    end
                end
                -- Also trigger Medkit/Bandage tool if present
                for _, container in ipairs({ char, LocalPlayer:FindFirstChild("Backpack") }) do
                    if container and ItemsRequest then
                        for _, t in ipairs(container:GetChildren()) do
                            local itemId = t:IsA("Tool") and t:GetAttribute("ItemId")
                            if itemId == "medkit" or itemId == "bandage" or itemId == "pizza" then
                                pcall(function() ItemsRequest:InvokeServer("use", itemId) end)
                            end
                        end
                    end
                end
            end

            if not targetPickupPos and State.AutoCollectCoins then
                for _, coin in ipairs(CollectionService:GetTagged("Coin")) do
                    if coin:IsDescendantOf(Workspace) then
                        local exId = coin:GetAttribute("ExcludeUserId")
                        local exUntil = coin:GetAttribute("ExcludeUntil")
                        local excluded = exId == LocalPlayer.UserId and type(exUntil) == "number" and Workspace:GetServerTimeNow() < exUntil
                        if not excluded then
                            local p = getModelPos(coin)
                            if p and isPosSafeFromEdgeAndSea(p) then
                                targetPickupPos = p + Vector3.new(0, 2, 0)
                                break
                            end
                        end
                    end
                end
            end

            if not targetPickupPos and State.AutoPickupWorldLoot then
                local mc = Workspace:FindFirstChild("MatchContent")
                if mc then
                    for _, d in ipairs(mc:GetDescendants()) do
                        if d:GetAttribute("WeaponId") or d:GetAttribute("MeleeId") or d:GetAttribute("LootKind") == "weapon"
                            or d.Name == "AirDrop" or d.Name:match("Chest") then
                            local p = getModelPos(d)
                            if p and isPosSafeFromEdgeAndSea(p) then
                                targetPickupPos = p + Vector3.new(0, 2.5, 0)
                                break
                            end
                        end
                    end
                end
            end

            if targetPickupPos then
                nextWorldCollectAt = now + 0.45
                local savedCF = hrp.CFrame
                safeTeleport(targetPickupPos)
                task.wait(0.14)
                if hrp.Parent then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = savedCF
                end
            end
        end

        -- Economy, Diary Claims, Write Credits, Item Gacha & Best Loadout (every 3s)
        if now >= nextEconomyAt then
            nextEconomyAt = now + 3
            if State.AutoClaimDiary then
                pcall(claimAllDiaryRewards)
            end
            if State.AutoUseWriteCredits and WriteCreditRequest then
                local credits = LocalPlayer:GetAttribute("WriteCredits") or 0
                if credits > 0 then
                    pcall(function() WriteCreditRequest:InvokeServer("use") end)
                end
            end
            if (State.AutoRollFreeGacha or State.AutoRollCashGacha) and ItemsRequest and ItemLibrary then
                refreshItemsCache(false)
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                local cash = ls and ls:FindFirstChild("Cash") and ls.Cash.Value or 0
                local price = ItemLibrary.SPIN_PRICE or 1000
                if (State.AutoRollFreeGacha and ItemsCache.freeSpins > 0) or (State.AutoRollCashGacha and cash >= price) then
                    pcall(function() ItemsRequest:InvokeServer("spin") end)
                    refreshItemsCache(true)
                end
            end
            if State.AutoEquipBestLoadout then
                pcall(equipBestLoadout)
            end
        end
    end
end)

-- Live Dashboards & ESP Loop (Every 0.8s)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "XLuna_SYI_ESP"
ESPFolder.Parent = Workspace

local function ensureESPFolder()
    if not ESPFolder or not ESPFolder.Parent then
        ESPFolder = Instance.new("Folder")
        ESPFolder.Name = "XLuna_SYI_ESP"
        ESPFolder.Parent = Workspace
    end
    return ESPFolder
end

local function makeBillboard(adornee, name, text, color, offsetY)
    local folder = ensureESPFolder()
    local bb = Instance.new("BillboardGui")
    bb.Name = name
    bb.Adornee = adornee
    bb.Size = UDim2.fromOffset(220, 44)
    bb.StudsOffsetWorldSpace = Vector3.new(0, offsetY or 4, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 1200
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

trackThread(function()
    while true do
        task.wait(0.8)
        pcall(function()
            -- Dashboards Update
            local matchInfo = ReplicatedStorage:FindFirstChild("MatchInfo")
            local phase = matchInfo and matchInfo:GetAttribute("Phase") or "Lobby"
            local alive = matchInfo and matchInfo:GetAttribute("AliveCount") or #Players:GetPlayers()
            local bodyTemp = math.floor((LocalPlayer:GetAttribute("BodyTemp") or 0) * 10) / 10
            local breath = math.floor(LocalPlayer:GetAttribute("Breath") or 100)
            local stamina = math.floor(LocalPlayer:GetAttribute("Stamina") or 100)
            local _, _, _, _, seaTop = getEdgeBounds()
            local edgeWarn = LocalPlayer:GetAttribute("EdgeWarn")

            SurvivalDashboard:SetDesc(string.format(
                "Phase: %s | Alive: %s | SeaTop: %.1f\nTemp: %.1f | Breath: %d | Stamina: %d | EdgeWarn: %s",
                tostring(phase), tostring(alive), seaTop, bodyTemp, breath, stamina, tostring(edgeWarn or "Safe")
            ))

            WriterDashboard:SetDesc(string.format(
                "Writer: %s | Live Typing: %s\nLast Announced: [%s] (%s) | Turn: %s",
                LiveWriterInfo.WriterName,
                LiveWriterInfo.TypingText ~= "" and LiveWriterInfo.TypingText or "-",
                LiveWriterInfo.LastWord,
                LiveWriterInfo.LastCategory,
                LiveWriterInfo.IsMyTurn and ("YOUR TURN (" .. LiveWriterInfo.TurnWordCount .. "w)") or "Waiting"
            ))

            local char, hrp = getRootAndHum()
            local heldTool = char and char:FindFirstChildOfClass("Tool")
            local heldStr = heldTool and (heldTool:GetAttribute("WeaponId") or heldTool:GetAttribute("MeleeId") or heldTool:GetAttribute("ItemId") or heldTool.Name) or "None"
            local mobs = collectCombatTargets("Bosses & Creatures Only")
            CombatDashboard:SetDesc(string.format(
                "Equipped Tool: %s | Active Bosses/Creatures: %d\nFilter: %s | GunMods: %s | SilentAim: %s",
                tostring(heldStr), #mobs, State.CombatTargetFilter,
                State.GunMods and "ON" or "OFF", State.GunSilentAim and "ON" or "OFF"
            ))

            refreshDiaryCache(false)
            refreshItemsCache(false)
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            local cash = ls and ls:FindFirstChild("Cash") and ls.Cash.Value or 0
            local matchCash = LocalPlayer:GetAttribute("MatchCash") or 0
            local ownedCount = 0
            for _ in pairs(ItemsCache.owned) do ownedCount += 1 end
            EconomyDashboard:SetDesc(string.format(
                "Cash: %d | MatchCash: %d | WriteCredits: %d\nOwned Items: %d/%d | Free Spins: %d | Pity: %d\nDiary Progress: %d/%d Words",
                cash, matchCash, LocalPlayer:GetAttribute("WriteCredits") or 0,
                ownedCount, ItemLibrary and #(ItemLibrary.Items or {}) or 40,
                ItemsCache.freeSpins, ItemsCache.pity,
                DiaryCache.discoveredCount, DiaryCache.totalCount
            ))

            -- Refresh ESP
            local folder = ensureESPFolder()
            folder:ClearAllChildren()
            local myPos = hrp and hrp.Position

            if State.BossESP then
                for _, entry in ipairs(mobs) do
                    local sh = entry.model:GetAttribute("ShootHealth")
                    local smax = entry.model:GetAttribute("ShootMaxHealth")
                    local hpTxt = (type(sh) == "number" and type(smax) == "number") and string.format("%.0f/%.0f", sh, smax) or "Active"
                    local dist = myPos and math.floor((entry.part.Position - myPos).Magnitude) or 0
                    makeBillboard(entry.part, "Boss_" .. entry.model.Name, string.format("[BOSS] %s (%s) [%dm]", entry.model.Name, hpTxt, dist), Color3.fromRGB(255, 65, 65), 6)
                end
            end

            if State.PlayerESP then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local pHead = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
                        local pHum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if pHead and pHum and pHum.Health > 0 then
                            local pTool = plr.Character:FindFirstChildOfClass("Tool")
                            local toolTxt = pTool and (" | " .. pTool.Name) or ""
                            local dist = myPos and math.floor((pHead.Position - myPos).Magnitude) or 0
                            makeBillboard(pHead, "Plr_" .. plr.Name, string.format("%s [%.0f HP%s] [%dm]", plr.DisplayName, pHum.Health, toolTxt, dist), Color3.fromRGB(100, 220, 255), 3.2)
                        end
                    end
                end
            end

            if State.LootESP then
                for _, coin in ipairs(CollectionService:GetTagged("Coin")) do
                    if coin:IsDescendantOf(Workspace) then
                        local part = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                        if part then
                            makeBillboard(part, "CoinESP", "[COIN]", Color3.fromRGB(255, 220, 40), 2)
                        end
                    end
                end
                local mc = Workspace:FindFirstChild("MatchContent")
                if mc then
                    for _, d in ipairs(mc:GetDescendants()) do
                        if d:GetAttribute("IsFood") or d:GetAttribute("LootKind") or d.Name == "AirDrop" then
                            local p = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
                            if p then
                                local tag = d.Name == "AirDrop" and "[AIRDROP]" or (d:GetAttribute("IsFood") and "[FOOD]" or "[LOOT]")
                                makeBillboard(p, "Loot_" .. d.Name, tag .. " " .. d.Name, Color3.fromRGB(110, 255, 130), 3)
                            end
                        end
                    end
                end
            end

            if State.ShelterESP then
                local sp = findEscapeShelterPos()
                local shelter = CollectionService:GetTagged("Escape_Shelter")[1] or findChildPath(Workspace, "MatchContent", "EscapeShelter")
                if shelter then
                    local p = shelter:IsA("BasePart") and shelter or shelter:FindFirstChildWhichIsA("BasePart")
                    if p then makeBillboard(p, "ShelterESP", "[SHELTER BUNKER]", Color3.fromRGB(80, 255, 255), 10) end
                end
                local tp = findHighestEscapeTowerPos()
                if tp then
                    local mc = Workspace:FindFirstChild("MatchContent")
                    local tower = mc and mc:FindFirstChild("EscapeTower")
                    local p = tower and tower:FindFirstChildWhichIsA("BasePart")
                    if p then makeBillboard(p, "TowerESP", "[HIGHEST TOWER]", Color3.fromRGB(180, 140, 255), 12) end
                end
            end

            if State.DoomedTilesESP then
                local gt = Workspace:FindFirstChild("GroundTiles")
                if gt then
                    for _, tile in ipairs(gt:GetChildren()) do
                        if tile:IsA("BasePart") and tile.Color.R > 0.75 and tile.Color.G < 0.35 then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = tile
                            hl.FillColor = Color3.fromRGB(255, 40, 40)
                            hl.FillTransparency = 0.4
                            hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                            hl.Parent = folder
                        end
                    end
                end
            end
        end)
    end
end)

-- -------------------------------------------------------------------------
-- 8. REGISTER UNLOAD & EXPOSE RUNTIME HANDLES
-- -------------------------------------------------------------------------
getgenv().XLunaSYI_Unload = function()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, t in ipairs(Threads) do
        pcall(function() task.cancel(t) end)
    end
    for _, fn in ipairs(Cleanups) do
        pcall(fn)
    end
    if PullFieldMod and OriginalPullVelocityFor then
        pcall(function() PullFieldMod.velocityFor = OriginalPullVelocityFor end)
    end
    State.GunMods = false
    State.RapidFire = false
    pcall(applyGunMods)
    pcall(applyFullbright, false)
    pcall(destroySkyPlatform)
    pcall(destroyWaterFloor)
    pcall(function() ESPFolder:Destroy() end)
    pcall(function()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end)
    getgenv().XLunaSYI_Window = nil
    getgenv().XLunaSYI_State = nil
    getgenv().XLunaSYI_Elements = nil
    getgenv().XLunaSYI_Unload = nil
end

getgenv().XLunaSYI_Window = Window
getgenv().XLunaSYI_State = State
getgenv().XLunaSYI_Elements = UI_Elements

notify("XLunaHUB", "Survive Your Ideas loaded (ALL OFF). Toggle with LeftControl or Floating Button.", 3.5)
