-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- XLunaHUB | Fisch Full Automation Script
-- Author: By XLunaHUB

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Clean up any prior XLunaHUB instance before loading
local env = (getgenv and getgenv()) or _G
if env.__XLunaHUB and type(env.__XLunaHUB.Destroy) == "function" then
    pcall(env.__XLunaHUB.Destroy)
end

local HUB = {
    Version = "1.0.0",
    Folder = "XLunaHUB_Fisch",
    ConfigDir = "XLunaHUB_Fisch/configs",
    AutoLoadFile = "XLunaHUB_Fisch/autoload.txt",
    Destroyed = false,
    Connections = {},
    Threads = {},
    State = {
        -- Master Progression
        FullAutoProgression = false,
        ProgressBuyRods = false,
        ProgressBuyBaitCrates = false,
        ProgressAutoSell = false,
        ProgressSellThreshold = 15,
        ProgressSpotMode = "Moosewood Dock",

        -- Fishing
        AutoCast = false,
        PerfectCast = false,
        AutoEquipRod = false,
        PreferredRod = "Best Owned",
        CastDelay = 0.25,

        AutoShake = false,
        ShakeInterval = 0.32,

        AutoReel = false,
        ReelMode = "Instant (Post-Ready)",
        AlwaysPerfect = false,
        ExpandCatchBar = false,
        ReelDelay = 0.05,

        FreezeWhileFishing = false,
        LockFishingSpot = false,
        AutoEquipBait = false,
        PreferredBait = "Best Owned",
        AutoCrabCages = false,
        CrabCageCount = 5,

        -- Economy & Stands
        AutoSellLoop = false,
        AutoSellInterval = 15,
        ProtectRareFish = false,
        ProtectMutatedFish = false,
        AutoBuyBaitCrates = false,
        ShopCategory = "All Stands",
        ShopItem = "Crab Cage",
        ShopAmount = 1,

        -- Rewards & World
        AutoClaimRewards = false,
        AutoClaimAquarium = false,
        AutoOpenCrates = false,
        AutoCollectItems = false,
        AutoFarmOceanEvent = false,
        CustomCode = "",

        -- Teleports
        SelectedIsland = "Moosewood",
        SelectedFishingZone = "Moosewood Docks",
        SelectedNPC = "Marc Merchant",
        SelectedPlayer = "",

        -- Player & Visuals
        EnableWalkSpeed = false,
        WalkSpeedValue = 32,
        EnableJumpPower = false,
        JumpPowerValue = 65,
        InfiniteJump = false,
        Noclip = false,
        WalkOnWater = false,
        InstantPrompts = false,
        Fullbright = false,
        NoUnderwaterFX = false,
        EspPlayers = false,
        EspOceanEvents = false,
        EspCollectibles = false,

        -- Misc / Config
        AntiAFK = false,
        ConfigName = "default",
        SelectedConfig = "",
    },
    Elements = {},
    SavedCollision = {},
    SavedPrompts = {},
    SavedLighting = nil,
    SavedDisabledConns = {},
    EspObjects = {},
    WaterPlatform = nil,
    LockedSpotCFrame = nil,
    LastCastTime = 0,
    LastShakeTime = 0,
    ShakeSeenAt = nil,
    StatusText = "Idle",
    CaughtSessionCount = 0,
}

env.__XLunaHUB = HUB

local function trackConn(conn)
    if conn then
        table.insert(HUB.Connections, conn)
    end
    return conn
end

local function spawnLoop(name, fn)
    local co = task.spawn(function()
        while not HUB.Destroyed do
            local ok, err = pcall(fn)
            if not ok then
                warn("[XLunaHUB][" .. name .. "] Loop error:", err)
                task.wait(1)
            end
        end
    end)
    table.insert(HUB.Threads, co)
    return co
end

-- Safe Game Module & Remote Lookups
local Packages = ReplicatedStorage:FindFirstChild("packages")
local Events = ReplicatedStorage:FindFirstChild("events")
local SharedModules = ReplicatedStorage:FindFirstChild("shared") and ReplicatedStorage.shared:FindFirstChild("modules")
local LibraryFolder = SharedModules and SharedModules:FindFirstChild("library")
local LegacyControllers = ReplicatedStorage:FindFirstChild("client") and ReplicatedStorage.client:FindFirstChild("legacyControllers")

local function requireSafe(inst)
    if not inst then return nil end
    local ok, mod = pcall(require, inst)
    if ok then return mod end
    return nil
end

local Net = requireSafe(Packages and Packages:FindFirstChild("Net"))
local DataController = requireSafe(LegacyControllers and LegacyControllers:FindFirstChild("DataController"))
local ReelController = requireSafe(LegacyControllers and LegacyControllers:FindFirstChild("ReelController"))
local CrabCageController = requireSafe(LegacyControllers and LegacyControllers:FindFirstChild("CrabCageController"))
local SharedCrabCage = requireSafe(SharedModules and SharedModules:FindFirstChild("SharedCrabCage"))
local FischUtils = requireSafe(ReplicatedStorage:FindFirstChild("shared") and ReplicatedStorage.shared:FindFirstChild("utils") and ReplicatedStorage.shared.utils:FindFirstChild("FischUtils"))

local RodsLib = requireSafe(LibraryFolder and LibraryFolder:FindFirstChild("rods")) or {}
local FishLib = requireSafe(LibraryFolder and LibraryFolder:FindFirstChild("fish")) or {}
local ItemsLib = requireSafe(LibraryFolder and LibraryFolder:FindFirstChild("items")) or {}
local BaitLib = requireSafe(LibraryFolder and LibraryFolder:FindFirstChild("bait")) or {}
local CrabCagesLib = requireSafe(LibraryFolder and LibraryFolder:FindFirstChild("crabcages")) or {}
local LocationsLib = requireSafe(LibraryFolder and LibraryFolder:FindFirstChild("locations")) or {}

local function getNetRemote(name)
    if not Packages then return nil end
    local netFolder = Packages:FindFirstChild("Net")
    if not netFolder then return nil end
    local r = netFolder:FindFirstChild("RF/" .. name) or netFolder:FindFirstChild("RE/" .. name)
    if r then return r end
    if Net then
        local ok, res = pcall(function() return Net:RemoteFunction(name) end)
        if ok and res then return res end
        ok, res = pcall(function() return Net:RemoteEvent(name) end)
        if ok and res then return res end
    end
    return nil
end

-- Helper Functions
local function getCharacter()
    return LocalPlayer.Character
end

local function getHRP()
    local ch = getCharacter()
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local ch = getCharacter()
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function getStatsFolder()
    local ps = Workspace:FindFirstChild("PlayerStats")
    local p = ps and ps:FindFirstChild(LocalPlayer.Name)
    local t = p and p:FindFirstChild("T")
    local pt = t and t:FindFirstChild(LocalPlayer.Name)
    return pt and pt:FindFirstChild("Stats")
end

local function getCoins()
    local st = getStatsFolder()
    local c = st and st:FindFirstChild("coins")
    return c and c.Value or 0
end

local function getLevel()
    local st = getStatsFolder()
    local l = st and st:FindFirstChild("level")
    return l and l.Value or 1
end

local function getCurrentRodName()
    local st = getStatsFolder()
    local r = st and st:FindFirstChild("rod")
    return r and r.Value or "None"
end

local function getCurrentBaitName()
    local st = getStatsFolder()
    local b = st and st:FindFirstChild("bait")
    return b and b.Value or "None"
end

local function getEquippedRodTool()
    local ch = getCharacter()
    if ch then
        for _, child in ipairs(ch:GetChildren()) do
            if child:IsA("Tool") and (RodsLib[child.Name] or child:FindFirstChild("values")) then
                return child
            end
        end
    end
    return nil
end

local function getAnyOwnedRodTool(targetName)
    local ch = getCharacter()
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if targetName then
        if ch and ch:FindFirstChild(targetName) then return ch:FindFirstChild(targetName) end
        if bp and bp:FindFirstChild(targetName) then return bp:FindFirstChild(targetName) end
    end
    local eq = getEquippedRodTool()
    if eq then return eq end
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") and (RodsLib[child.Name] or child:FindFirstChild("values")) then
                return child
            end
        end
    end
    return nil
end

local function getSeaLevelY()
    local world = Workspace:FindFirstChild("world")
    local water = world and world:FindFirstChild("water")
    local vols = water and water:FindFirstChild("seaVolumes")
    local sea = vols and vols:FindFirstChild("MainSea")
    if sea and sea:IsA("BasePart") then
        return sea.Position.Y + sea.Size.Y / 2
    end
    return 125.9
end

local function getInventoryTable()
    if DataController and DataController.InventoryReplicator then
        local ok, tbl = pcall(function() return DataController.InventoryReplicator:TryIndex({"Inventory"}) end)
        if ok and type(tbl) == "table" then return tbl end
        local ok2, tbl2 = pcall(function() return DataController.InventoryReplicator:Index({"Inventory"}) end)
        if ok2 and type(tbl2) == "table" then return tbl2 end
    end
    return {}
end

local function getOwnedRodsTable()
    if DataController and DataController.PlayerDataReplicator then
        local ok, tbl = pcall(function() return DataController.PlayerDataReplicator:TryIndex({"Rods"}) end)
        if ok and type(tbl) == "table" then return tbl end
    end
    return {}
end

local function scoreRod(name, data)
    if type(data) ~= "table" then return -1e9 end
    local price = tonumber(data.Price) or 0
    if price == math.huge then price = 50000000 end
    local luck = tonumber(data.Luck) or 0
    local lureBonus = 100 - (tonumber(data.LureSpeed) or 100)
    local res = tonumber(data.Resilience) or 0
    local str = tonumber(data.Strength) or 0
    if str == math.huge then str = 1e9 end
    return (price * 0.01) + (luck * 2.5) + (lureBonus * 3) + (res * 1.5) + math.log10(math.max(1, str)) * 20
end

local function getBestOwnedRodName()
    local owned = getOwnedRodsTable()
    local bestName, bestScore = getCurrentRodName(), -1e12
    for rodName in pairs(owned) do
        local info = RodsLib[rodName]
        local sc = info and scoreRod(rodName, info) or 0
        if sc > bestScore then
            bestScore = sc
            bestName = rodName
        end
    end
    return bestName
end

local function equipRodByName(rodName)
    if HUB.Destroyed then return false end
    if rodName == "Best Owned" or not rodName or rodName == "" then
        rodName = getBestOwnedRodName()
    end
    if not rodName or rodName == "None" then return false end

    local cur = getCurrentRodName()
    if cur ~= rodName then
        local rfEquip = getNetRemote("Rod/Equip")
        if rfEquip and rfEquip:IsA("RemoteFunction") then
            pcall(function() rfEquip:InvokeServer(rodName) end)
            task.wait(0.25)
        end
    end

    local tool = getAnyOwnedRodTool(rodName)
    local hum = getHumanoid()
    if tool and hum and tool.Parent ~= getCharacter() then
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.15)
    end
    return getEquippedRodTool() ~= nil
end

local function getOwnedBaitsList()
    local st = getStatsFolder()
    local baitVal = st and st:FindFirstChild("bait")
    local list = {}
    if baitVal then
        for _, child in ipairs(baitVal:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") then
                local baitName = child.Name:gsub("^bait_", "")
                if child.Value > 0 and BaitLib[baitName] then
                    table.insert(list, {name = baitName, count = child.Value, info = BaitLib[baitName]})
                end
            end
        end
    end
    return list
end

local function equipBestOrSelectedBait(target)
    local owned = getOwnedBaitsList()
    if #owned == 0 then return false end
    local chosen = nil
    if target and target ~= "Best Owned" then
        for _, entry in ipairs(owned) do
            if entry.name == target then
                chosen = entry.name
                break
            end
        end
    end
    if not chosen then
        table.sort(owned, function(a, b)
            local sa = (a.info.Luck or 0) * 2 + (a.info.Lure or 0) + (a.info.Resilience or 0)
            local sb = (b.info.Luck or 0) * 2 + (b.info.Lure or 0) + (b.info.Resilience or 0)
            return sa > sb
        end)
        chosen = owned[1].name
    end
    if chosen and getCurrentBaitName() ~= chosen then
        local reBait = getNetRemote("Bait/Equip")
        if reBait and reBait:IsA("RemoteEvent") then
            pcall(function() reBait:FireServer(chosen) end)
            return true
        end
    end
    return false
end

-- Safe Teleportation with StreamingEnabled Support
local function safeTeleport(targetCFOrVec, keepOrientation)
    local hrp = getHRP()
    local ch = getCharacter()
    if not hrp or not ch then return false end

    local pos = typeof(targetCFOrVec) == "CFrame" and targetCFOrVec.Position or targetCFOrVec
    if typeof(pos) ~= "Vector3" then return false end

    local dist = (hrp.Position - pos).Magnitude
    if dist > 250 then
        pcall(function()
            LocalPlayer:RequestStreamAroundAsync(pos)
        end)
        task.wait(0.15)
    end

    local destCF
    if typeof(targetCFOrVec) == "CFrame" and not keepOrientation then
        destCF = targetCFOrVec
    else
        local rot = hrp.CFrame - hrp.CFrame.Position
        destCF = CFrame.new(pos) * rot
    end

    pcall(function()
        local hum = getHumanoid()
        if hum and hum.Sit then hum.Sit = false end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        ch:PivotTo(destCF)
        hrp.CFrame = destCF
    end)
    return true
end

-- Curated & Dynamic World Tables
local ISLAND_COORDS = {
    ["Moosewood"] = CFrame.new(383.1, 134.5, 243.9),
    ["Moosewood Dock"] = CFrame.lookAt(Vector3.new(363, 134.5, 225), Vector3.new(280, 126, 225)),
    ["Roslit Bay"] = CFrame.new(-1485, 138, 675),
    ["Roslit Volcano"] = CFrame.new(-1888, 168, 329),
    ["Sunstone Island"] = CFrame.new(-933, 135, -1118),
    ["Terrapin Island"] = CFrame.new(-140, 145, 1909),
    ["Mushgrove Swamp"] = CFrame.new(2501, 134, -721),
    ["Forsaken Shores"] = CFrame.new(-2498, 136, 1555),
    ["Statue Of Sovereignty"] = CFrame.new(39, 136, -1013),
    ["Keepers Altar"] = CFrame.new(1308, -805, -96),
    ["Vertigo"] = CFrame.new(-112, -512, 1040),
    ["The Depths"] = CFrame.new(568, -704, 1230),
    ["Desolate Deep Buoy"] = CFrame.new(-790, 135, -3102),
    ["Ancient Isle"] = CFrame.new(5833, 140, 405),
    ["Castaway Cliffs"] = CFrame.new(540, 145, -1955),
    ["Northern Summit"] = CFrame.new(19590, 140, 5280),
    ["Cryogenic Canal"] = CFrame.new(19902, 692, 5663),
    ["Boreal Pines"] = CFrame.new(21572, 145, 4193),
    ["Grand Reef"] = CFrame.new(-3582, 135, 518),
    ["Tidefall"] = CFrame.new(3198, 236, 932),
    ["Skycrest"] = CFrame.new(3144, 1720, 950),
    ["Lost Jungle"] = CFrame.new(-2760, 168, -2109),
    ["Everturn Forest"] = CFrame.new(2474, 140, -2523),
    ["Scoria Reach"] = CFrame.new(-5218, 395, -1519),
}

local STAND_FALLBACKS = {
    -- Rods & Equipment in Moosewood
    ["GPS"] = Vector3.new(517.90, 149.22, 284.86),
    ["Flimsy Rod"] = Vector3.new(471.11, 148.36, 229.64),
    ["Training Rod"] = Vector3.new(457.69, 148.36, 230.41),
    ["Plastic Rod"] = Vector3.new(454.43, 148.17, 229.17),
    ["Carbon Rod"] = Vector3.new(454.08, 150.59, 225.33),
    ["Long Rod"] = Vector3.new(485.70, 171.66, 145.75),
    ["Fast Rod"] = Vector3.new(447.18, 148.23, 220.19),
    ["Lucky Rod"] = Vector3.new(446.09, 148.25, 222.16),
    ["Crab Cage"] = Vector3.new(475.93, 149.60, 228.11),
    ["Bait Crate"] = Vector3.new(372.42, 135.83, 281.47),
    ["Thankful Bait Crate"] = Vector3.new(390.44, 133.61, 303.19),
    ["Basic Diving Gear"] = Vector3.new(369.17, 132.51, 249.74),
    ["Fish Radar"] = Vector3.new(365.75, 134.50, 274.11),
    ["Clearcast Totem"] = Vector3.new(701.38, 251.25, 304.03),
}

local PROGRESSION_RODS = {
    {name = "Training Rod", price = 300},
    {name = "Plastic Rod", price = 750},
    {name = "Carbon Rod", price = 2000},
    {name = "Long Rod", price = 3000},
    {name = "Fast Rod", price = 4000},
    {name = "Lucky Rod", price = 4500},
    {name = "Steady Rod", price = 7000},
    {name = "Fortune Rod", price = 11000},
    {name = "Rapid Rod", price = 12000},
    {name = "Magnet Rod", price = 15000},
    {name = "Nocturnal Rod", price = 15000},
    {name = "Reinforced Rod", price = 20000},
    {name = "Arctic Rod", price = 25000},
    {name = "Avalanche Rod", price = 35000},
    {name = "Depthseeker Rod", price = 40000},
    {name = "Aurora Rod", price = 70000},
    {name = "Trident Rod", price = 150000},
    {name = "Rainbow Cluster Rod", price = 250000},
    {name = "Zeus Rod", price = 500000},
}

local KNOWN_CODES = {
    "RFG",
    "THEKRAKEN",
    "CARBON",
    "SORRYFORDELAY",
    "FISCHFRIGHT2024",
    "THANKYOUFOLLOWERS",
    "100M",
    "200M",
    "500M",
    "1B",
    "PREHISTORIC",
    "ANCIENTISLE",
    "ATLANTEAN",
    "NORTHERNEXPEDITION",
    "FISCHMASDAY",
    "MERRYFISCHMAS",
    "GOLDENTIDE",
    "NEWYEAR2025",
    "VALENTINES",
    "FISCHFEST",
    "SECONDSEA",
    "TIDEFALL",
    "ANNIVERSARY",
    "UPDATE",
}

local function collectDynamicLists()
    -- Islands
    local islandsMap = {}
    for k, cf in pairs(ISLAND_COORDS) do islandsMap[k] = cf end

    local world = Workspace:FindFirstChild("world")
    local spawns = world and world:FindFirstChild("spawns")
    if spawns then
        for _, d in ipairs(spawns:GetDescendants()) do
            if d:IsA("BasePart") and not d:FindFirstAncestor("loading") and d.Name ~= "spawn" then
                islandsMap[d.Name] = d.CFrame
            end
        end
    end
    local zones = Workspace:FindFirstChild("zones")
    local zPlayer = zones and zones:FindFirstChild("player")
    if zPlayer then
        for _, z in ipairs(zPlayer:GetChildren()) do
            local cf = z:IsA("BasePart") and z.CFrame or (z:IsA("Model") and z:GetPivot())
            if cf and not islandsMap[z.Name] then
                islandsMap[z.Name] = CFrame.new(cf.Position + Vector3.new(0, 5, 0))
            end
        end
    end

    local islandNames = {}
    for k in pairs(islandsMap) do table.insert(islandNames, k) end
    table.sort(islandNames)

    -- Fishing Zones / Ocean Events
    local fishingZonesMap = {}
    local active = Workspace:FindFirstChild("active")
    local oceanPOI = active and active:FindFirstChild("OceanPOI's")
    if oceanPOI then
        for _, d in ipairs(oceanPOI:GetChildren()) do
            local cf = d:IsA("BasePart") and d.CFrame or (d:IsA("Model") and d:GetPivot())
            if cf then
                fishingZonesMap["[POI] " .. d.Name] = cf
            end
        end
    end
    local zFishing = zones and zones:FindFirstChild("fishing")
    if zFishing then
        for _, z in ipairs(zFishing:GetChildren()) do
            local cf = z:IsA("BasePart") and z.CFrame or (z:IsA("Model") and z:GetPivot())
            if cf then
                fishingZonesMap[z.Name] = cf
            end
        end
    end
    local zoneNames = {}
    for k in pairs(fishingZonesMap) do table.insert(zoneNames, k) end
    table.sort(zoneNames)

    -- NPCs
    local npcsMap = {}
    local npcFolder = world and world:FindFirstChild("npcs")
    if npcFolder then
        for _, n in ipairs(npcFolder:GetDescendants()) do
            if n:IsA("Model") or (n:IsA("ProximityPrompt") and n.Parent) then
                local target = n:IsA("Model") and n or n.Parent
                if target and (target:FindFirstChildWhichIsA("ProximityPrompt", true) or target:GetAttribute("NpcType")) then
                    local ok, cf = pcall(function()
                        return target:IsA("Model") and target:GetPivot() or target.CFrame
                    end)
                    if ok and cf then
                        npcsMap[target.Name] = cf
                    end
                end
            end
        end
    end
    local npcNames = {}
    for k in pairs(npcsMap) do table.insert(npcNames, k) end
    table.sort(npcNames)

    -- Interactable Stands
    local standsMap = {}
    for k, v in pairs(STAND_FALLBACKS) do
        standsMap[k] = {pos = v, name = k}
    end
    local inter = world and world:FindFirstChild("interactables")
    if inter then
        for _, inst in ipairs(inter:GetChildren()) do
            local pr = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
            local ok, cf = pcall(function()
                return inst:IsA("Model") and inst:GetPivot() or (inst:IsA("BasePart") and inst.CFrame)
            end)
            local pos = inst:GetAttribute("pos") or (ok and cf and cf.Position)
            if pr and typeof(pos) == "Vector3" then
                standsMap[inst.Name] = {pos = pos, name = inst.Name, inst = inst, prompt = pr}
            end
        end
    end
    local standNames = {}
    for k in pairs(standsMap) do table.insert(standNames, k) end
    table.sort(standNames)

    return {
        islands = islandsMap,
        islandNames = islandNames,
        fishingZones = fishingZonesMap,
        zoneNames = zoneNames,
        npcs = npcsMap,
        npcNames = npcNames,
        stands = standsMap,
        standNames = standNames,
    }
end

-- Clean Stand Purchase Engine (respects ProximityPrompt -> events.prompt -> events.purchase)
local function cleanPurchaseOverlay()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local over = pg and pg:FindFirstChild("over")
    local pr = over and over:FindFirstChild("prompt")
    if pr then
        pcall(function() pr:Destroy() end)
    end
    local hud = pg and pg:FindFirstChild("hud")
    if hud then hud.Enabled = true end
    local bp = pg and pg:FindFirstChild("backpack")
    if bp then bp.Enabled = true end
    local blur = Lighting:FindFirstChild("uiblur")
    if blur then blur.Size = 0 end
    local cc = Lighting:FindFirstChild("uicc")
    if cc then cc.Brightness = 0; cc.Saturation = 0; cc.TintColor = Color3.fromRGB(255, 255, 255) end
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = 70 end
end

local function buyAtStand(itemName, amount)
    amount = math.max(1, math.floor(tonumber(amount) or 1))
    local dyn = collectDynamicLists()
    local world = Workspace:FindFirstChild("world")
    local inter = world and world:FindFirstChild("interactables")
    local targetEntry = dyn.stands[itemName]
    local targetPos = (targetEntry and targetEntry.pos) or STAND_FALLBACKS[itemName]

    if not targetPos and inter then
        local found = inter:FindFirstChild(itemName, true)
        if found then
            local ok, cf = pcall(function() return found:IsA("Model") and found:GetPivot() or found.CFrame end)
            if ok and cf then targetPos = cf.Position end
        end
    end

    if not targetPos then
        return false, "Stand location unknown or not found in current world: " .. tostring(itemName)
    end

    local hrp = getHRP()
    if not hrp then return false, "No HumanoidRootPart" end
    local origCF = hrp.CFrame
    local startCoins = getCoins()

    pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPos) end)
    safeTeleport(targetPos + Vector3.new(0, 2.5, 0), true)
    task.wait(0.35)

    local standInst = inter and (inter:FindFirstChild(itemName) or inter:FindFirstChild(itemName, true))
    local prompt = standInst and standInst:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        safeTeleport(origCF)
        return false, "ProximityPrompt not loaded at stand: " .. tostring(itemName)
    end

    local promptArgs = nil
    local promptConn
    local evPrompt = Events and Events:FindFirstChild("prompt")
    if evPrompt then
        promptConn = evPrompt.OnClientEvent:Connect(function(...)
            promptArgs = {...}
        end)
    end

    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    end

    local t0 = tick()
    while not promptArgs and tick() - t0 < 2.5 do
        task.wait(0.05)
    end
    if promptConn then promptConn:Disconnect() end

    local bought = false
    if promptArgs then
        local itemKey, _, cat, arg4, arg5 = promptArgs[1], promptArgs[2], promptArgs[3], promptArgs[4], promptArgs[5]
        if itemKey == "Aurora Totem" then
            local rf = getNetRemote("AuroraTotem/Purchase")
            if rf then
                local ok = pcall(function() rf:InvokeServer(arg5) end)
                bought = ok
            end
        elseif Events and Events:FindFirstChild("purchase") then
            Events.purchase:FireServer(itemKey, cat, arg4, amount)
            bought = true
        end
        task.wait(0.35)
    end

    cleanPurchaseOverlay()
    safeTeleport(origCF)

    local afterCoins = getCoins()
    if bought and (afterCoins < startCoins or itemName == "Flimsy Rod") then
        return true, string.format("Purchased x%d %s (-%d C$)", amount, itemName, math.max(0, startCoins - afterCoins))
    end
    if not promptArgs then
        return false, "Server did not open prompt session (level/requirements or insufficient C$)"
    end
    return false, "Purchase rejected (check C$ or already owned)"
end

-- Selling Engine
local RARE_CHECK = {
    Mythical = true, Exotic = true, Secret = true, Limited = true, Apex = true, Special = true, Relic = true, Extinct = true
}

local function favoriteItem(itemId, bool)
    local reFav = getNetRemote("Backpack/Favourite") or (Events and Events:FindFirstChild("favourite"))
    if reFav and reFav:IsA("RemoteEvent") then
        pcall(function() reFav:FireServer(itemId, bool) end)
    end
end

local function isProtectedFish(entry)
    if type(entry) ~= "table" then return false end
    local sub = entry.sub or {}
    if sub.Favourited then return true end
    local fInfo = FishLib[entry.name]
    if HUB.State.ProtectRareFish and fInfo and RARE_CHECK[fInfo.Rarity] then
        return true
    end
    if HUB.State.ProtectMutatedFish and (sub.Mutation or sub.Shiny or sub.Sparkling) then
        return true
    end
    return false
end

local function sellAllSafe()
    if not Events or not Events:FindFirstChild("SellAll") then
        return false, "SellAll remote missing"
    end
    local beforeCoins = getCoins()

    -- Temporarily hold back protected fish if filters active
    if not HUB.State.ProtectRareFish and not HUB.State.ProtectMutatedFish then
        local ok, res = pcall(function() return Events.SellAll:InvokeServer() end)
        task.wait(0.35)
        local delta = getCoins() - beforeCoins
        return ok and (res == true or delta > 0), delta
    else
        -- Selective held sell when protection filters are enabled
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local hum = getHumanoid()
        local inv = getInventoryTable()
        if not bp or not hum or not Events:FindFirstChild("Sell") then
            return false, 0
        end
        local soldCount = 0
        for id, entry in pairs(inv) do
            if FishLib[entry.name] and not FishLib[entry.name].IsCrate and not isProtectedFish(entry) then
                -- Find matching tool linked to item id
                local targetTool = nil
                for _, tl in ipairs(bp:GetChildren()) do
                    if tl:IsA("Tool") then
                        local lnk = tl:FindFirstChild("link")
                        if lnk and lnk.Value == id then targetTool = tl; break end
                    end
                end
                if not targetTool then
                    local reEquip = getNetRemote("Backpack/Equip")
                    if reEquip and reEquip:IsA("RemoteEvent") then
                        pcall(function() reEquip:FireServer(id, true) end)
                        task.wait(0.12)
                        targetTool = getCharacter() and getCharacter():FindFirstChildWhichIsA("Tool")
                    end
                elseif targetTool.Parent ~= getCharacter() then
                    pcall(function() hum:EquipTool(targetTool) end)
                    task.wait(0.1)
                end
                if targetTool or (getCharacter() and getCharacter():FindFirstChildWhichIsA("Tool")) then
                    local ok = pcall(function() Events.Sell:InvokeServer() end)
                    if ok then soldCount += 1 end
                    task.wait(0.08)
                end
            end
        end
        local delta = getCoins() - beforeCoins
        return soldCount > 0 or delta > 0, delta
    end
end

-- Find Best Fishing Position for Zone
local function moveToFishingSpot(zoneNameOrCF)
    if typeof(zoneNameOrCF) == "CFrame" then
        safeTeleport(zoneNameOrCF)
        return true
    end
    local cf = ISLAND_COORDS[zoneNameOrCF]
    if cf then
        safeTeleport(cf)
        return true
    end
    local dyn = collectDynamicLists()
    local zCF = dyn.fishingZones[zoneNameOrCF] or dyn.islands[zoneNameOrCF]
    if zCF then
        -- Raycast near zone edge for solid ground or hover above sea level if WalkOnWater active
        local pos = zCF.Position
        pcall(function() LocalPlayer:RequestStreamAroundAsync(pos) end)
        task.wait(0.2)
        local seaY = getSeaLevelY()
        if pos.Y < seaY then
            pos = Vector3.new(pos.X, seaY + 5, pos.Z)
        end
        if not HUB.State.WalkOnWater then
            -- Enable temporary platform under feet so player never falls into water
            local plat = HUB.WaterPlatform or Instance.new("Part")
            plat.Name = "XLunaHUB_WaterFloor"
            plat.Size = Vector3.new(20, 2, 20)
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 0.65
            plat.Color = Color3.fromRGB(0, 170, 255)
            plat.CFrame = CFrame.new(pos.X, pos.Y - 4, pos.Z)
            plat.Parent = Workspace
            HUB.WaterPlatform = plat
        end
        safeTeleport(CFrame.lookAt(pos, Vector3.new(pos.X + 20, pos.Y - 4, pos.Z)))
        return true
    end
    return false
end

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then
    error("[XLunaHUB] Failed to load WindUI library.")
end

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB | Fisch",
    Icon = "fish",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_Fisch",
    Size = UDim2.fromOffset(630, 480),
    Theme = "Dark",
    Transparent = true,
    IgnoreAlerts = true,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "fish",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
    },
})

HUB.Window = Window
HUB.WindUI = WindUI

-- Disable built-in ToggleKey completely (nil, NEVER Enum.KeyCode.Unknown/None which fires on mouse clicks!)
pcall(function()
    Window:SetToggleKey(nil)
end)

local lastKeyToggle = 0
trackConn(UserInputService.InputBegan:Connect(function(input, _gp)
    if HUB.Destroyed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl and not UserInputService:GetFocusedTextBox() then
        local now = tick()
        if now - lastKeyToggle >= 0.18 then
            lastKeyToggle = now
            pcall(function() Window:Toggle() end)
        end
    end
end))

-- Ensure WindUI OpenButton cleanly toggles open/close when clicked
task.defer(function()
    pcall(function()
        local ob = Window.OpenButtonMain and Window.OpenButtonMain.Button
        if ob then
            local clickable = ob:FindFirstChildWhichIsA("TextButton", true) or ob:FindFirstChildWhichIsA("ImageButton", true) or (ob:IsA("GuiButton") and ob)
            if clickable then
                -- WindUI OpenButton defaults to Open when Closed; keep synced
                ob.Visible = true
            end
        end
    end)
end)

local function notify(title, content, duration)
    if HUB.Destroyed then return end
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Icon = "fish",
        })
    end)
end

-- Element Registry Helper (guarantees Config Save/Load sets BOTH UI widget & HUB.State)
local function bindElement(tab, kind, cfg)
    local flag = cfg.Flag
    local userCb = cfg.Callback
    if flag then
        cfg.Callback = function(val)
            HUB.State[flag] = val
            if userCb then
                pcall(userCb, val)
            end
        end
    end
    local elem
    if kind == "Toggle" then
        cfg.Value = false -- SOP Rule 8: Always OFF on load
        if flag then HUB.State[flag] = false end
        elem = tab:Toggle(cfg)
    elseif kind == "Slider" then
        elem = tab:Slider(cfg)
        if flag and cfg.Value and cfg.Value.Default ~= nil then
            HUB.State[flag] = cfg.Value.Default
        end
    elseif kind == "Dropdown" then
        elem = tab:Dropdown(cfg)
        if flag and cfg.Value ~= nil then
            HUB.State[flag] = cfg.Value
        end
    elseif kind == "Input" then
        elem = tab:Input(cfg)
        if flag and cfg.Value ~= nil then
            HUB.State[flag] = cfg.Value
        end
    end
    if flag and elem then
        HUB.Elements[flag] = {kind = kind, elem = elem}
    end
    return elem
end

-- Dynamic Initial Lists
local InitLists = collectDynamicLists()

local RodOptions = {"Best Owned"}
do
    local tmp = {}
    for k, v in pairs(RodsLib) do
        if type(v) == "table" and not v.DEV then table.insert(tmp, k) end
    end
    table.sort(tmp)
    for _, k in ipairs(tmp) do table.insert(RodOptions, k) end
end

local BaitOptions = {"Best Owned"}
do
    local tmp = {}
    for k, v in pairs(BaitLib) do
        if type(v) == "table" then table.insert(tmp, k) end
    end
    table.sort(tmp)
    for _, k in ipairs(tmp) do table.insert(BaitOptions, k) end
end

--=====================================================================
-- TAB 1: AUTOMATION & TELEMETRY
--=====================================================================
local TabAuto = Window:Tab({Title = "Automation", Icon = "zap"})

local StatusPara = TabAuto:Paragraph({
    Title = "Player & Session Telemetry",
    Desc = "Loading live telemetry...",
})

TabAuto:Section({Title = "Full Auto Progression (End-to-End)", Opened = true})

bindElement(TabAuto, "Toggle", {
    Title = "Enable Full Auto Progression",
    Desc = "Master state machine: auto equips best rod & bait, goes to fishing spot, casts, shakes, catches, sells, and optionally upgrades gear.",
    Flag = "FullAutoProgression",
    Callback = function(on)
        HUB.StatusText = on and "Running Full Auto Progression" or "Idle"
    end,
})

bindElement(TabAuto, "Dropdown", {
    Title = "Progression Fishing Location",
    Values = InitLists.islandNames,
    Value = "Moosewood Dock",
    SearchBarEnabled = true,
    Flag = "ProgressSpotMode",
})

bindElement(TabAuto, "Toggle", {
    Title = "Auto Sell Fish During Progression",
    Desc = "Automatically sells unfavorited catches once inventory count hits threshold.",
    Flag = "ProgressAutoSell",
})

bindElement(TabAuto, "Slider", {
    Title = "Auto Sell Fish Threshold",
    Value = {Min = 1, Max = 100, Default = 15},
    Step = 1,
    Flag = "ProgressSellThreshold",
})

bindElement(TabAuto, "Toggle", {
    Title = "Auto Upgrade Progression Rods",
    Desc = "When C$ can afford the next unowned upgrade rod, visits its shop stand, buys it, equips it, and resumes fishing.",
    Flag = "ProgressBuyRods",
})

bindElement(TabAuto, "Toggle", {
    Title = "Auto Buy Bait Crates",
    Desc = "Buys Bait Crates at Moosewood Bait stand when funds exceed 500 C$ and bait stock is low.",
    Flag = "ProgressBuyBaitCrates",
})

--=====================================================================
-- TAB 2: FISHING
--=====================================================================
local TabFish = Window:Tab({Title = "Fishing", Icon = "anchor"})

TabFish:Section({Title = "Cast & Rod Preparation", Opened = true})

bindElement(TabFish, "Toggle", {
    Title = "Auto Cast",
    Desc = "Automatically casts rod when idle (RF/FishingRod/Cast).",
    Flag = "AutoCast",
})

bindElement(TabFish, "Toggle", {
    Title = "Always Perfect Cast",
    Desc = "Sends 100% power + perfect cast flag.",
    Flag = "PerfectCast",
})

bindElement(TabFish, "Slider", {
    Title = "Cast Cooldown (Seconds)",
    Value = {Min = 0.05, Max = 3.0, Default = 0.25},
    Step = 0.05,
    Flag = "CastDelay",
})

bindElement(TabFish, "Toggle", {
    Title = "Auto Equip Rod",
    Desc = "Keeps your chosen/best owned rod equipped before casting.",
    Flag = "AutoEquipRod",
})

bindElement(TabFish, "Dropdown", {
    Title = "Preferred Rod",
    Values = RodOptions,
    Value = "Best Owned",
    SearchBarEnabled = true,
    Flag = "PreferredRod",
})

TabFish:Section({Title = "Lure Shake & Reel Solver", Opened = true})

bindElement(TabFish, "Toggle", {
    Title = "Auto Shake",
    Desc = "Automatically clears LureShake minigame with server-safe >=0.30s timing.",
    Flag = "AutoShake",
})

bindElement(TabFish, "Slider", {
    Title = "Shake Interval (Seconds)",
    Value = {Min = 0.30, Max = 1.5, Default = 0.32},
    Step = 0.02,
    Flag = "ShakeInterval",
})

bindElement(TabFish, "Toggle", {
    Title = "Auto Reel",
    Desc = "Automatically completes the fishing reel minigame.",
    Flag = "AutoReel",
})

bindElement(TabFish, "Dropdown", {
    Title = "Auto Reel Mode",
    Values = {"Instant (Post-Ready)", "Legit Bar Lock"},
    Value = "Instant (Post-Ready)",
    Flag = "ReelMode",
})

bindElement(TabFish, "Toggle", {
    Title = "Always Perfect Catch",
    Desc = "Forces ActiveReel.perfect = true on every catch.",
    Flag = "AlwaysPerfect",
})

bindElement(TabFish, "Toggle", {
    Title = "Max Catch Bar Size (Legit Mode)",
    Desc = "Expands barSize = 1.0 during active reel minigames.",
    Flag = "ExpandCatchBar",
})

bindElement(TabFish, "Slider", {
    Title = "Post-Ready Finish Delay (Seconds)",
    Value = {Min = 0.0, Max = 2.0, Default = 0.05},
    Step = 0.05,
    Flag = "ReelDelay",
})

TabFish:Section({Title = "Baits, Position & Crab Cages", Opened = true})

bindElement(TabFish, "Toggle", {
    Title = "Auto Equip Bait",
    Desc = "Equips selected/highest-luck owned bait automatically.",
    Flag = "AutoEquipBait",
})

bindElement(TabFish, "Dropdown", {
    Title = "Preferred Bait",
    Values = BaitOptions,
    Value = "Best Owned",
    SearchBarEnabled = true,
    Flag = "PreferredBait",
})

bindElement(TabFish, "Toggle", {
    Title = "Freeze Character While Fishing",
    Desc = "Anchors HumanoidRootPart during Auto Cast/Shake/Reel.",
    Flag = "FreezeWhileFishing",
    Callback = function(on)
        local hrp = getHRP()
        if hrp and not on then hrp.Anchored = false end
    end,
})

bindElement(TabFish, "Toggle", {
    Title = "Lock & Return to Cast Spot",
    Desc = "Saves current CFrame when enabled and keeps character anchored to it.",
    Flag = "LockFishingSpot",
    Callback = function(on)
        local hrp = getHRP()
        HUB.LockedSpotCFrame = (on and hrp) and hrp.CFrame or nil
    end,
})

bindElement(TabFish, "Toggle", {
    Title = "Auto Place & Claim Crab Cages",
    Desc = "Places owned Crab Cages in nearby water and automatically claims ready catches.",
    Flag = "AutoCrabCages",
})

--=====================================================================
-- TAB 3: ECONOMY & STANDS
--=====================================================================
local TabEcon = Window:Tab({Title = "Economy", Icon = "coins"})

TabEcon:Section({Title = "Selling & Fish Protection", Opened = true})

TabEcon:Button({
    Title = "Sell All Fish Now",
    Desc = "Calls global SellAll remote (respects protection filters below).",
    Callback = function()
        local ok, delta = sellAllSafe()
        notify("Sell Fish", ok and ("Sold! +" .. tostring(delta) .. " C$") or "Nothing sold.", 3)
    end,
})

TabEcon:Button({
    Title = "Sell Held Item",
    Desc = "Sells only the fish currently equipped in your hand.",
    Callback = function()
        local before = getCoins()
        local ok = Events and Events:FindFirstChild("Sell") and pcall(function() return Events.Sell:InvokeServer() end)
        task.wait(0.25)
        local delta = getCoins() - before
        notify("Sell Held", (ok and delta > 0) and ("Sold +" .. delta .. " C$") or "Hold an unfavorited fish first.", 3)
    end,
})

bindElement(TabEcon, "Toggle", {
    Title = "Auto Sell Loop",
    Desc = "Periodically sells caught fish in background.",
    Flag = "AutoSellLoop",
})

bindElement(TabEcon, "Slider", {
    Title = "Auto Sell Interval (Seconds)",
    Value = {Min = 5, Max = 180, Default = 15},
    Step = 1,
    Flag = "AutoSellInterval",
})

bindElement(TabEcon, "Toggle", {
    Title = "Protect Rare Fish (Mythical/Exotic/Secret/Limited)",
    Desc = "Uses selective held-item sell so high-rarity fish stay safe in inventory.",
    Flag = "ProtectRareFish",
})

bindElement(TabEcon, "Toggle", {
    Title = "Protect Mutated / Shiny / Sparkling Fish",
    Desc = "Uses selective held-item sell so mutated/shiny/sparkling catches are never sold.",
    Flag = "ProtectMutatedFish",
})

TabEcon:Section({Title = "Stand Shop Buyer (Auto Visit + Prompt Session)", Opened = true})

local ShopDrop = bindElement(TabEcon, "Dropdown", {
    Title = "Select Shop Stand / Item",
    Values = InitLists.standNames,
    Value = table.find(InitLists.standNames, "Crab Cage") and "Crab Cage" or (InitLists.standNames[1] or "Crab Cage"),
    SearchBarEnabled = true,
    Flag = "ShopItem",
})

bindElement(TabEcon, "Slider", {
    Title = "Purchase Quantity",
    Value = {Min = 1, Max = 100, Default = 1},
    Step = 1,
    Flag = "ShopAmount",
})

TabEcon:Button({
    Title = "Buy Item at Stand & Return",
    Desc = "Streams & teleports to the item stand, fires ProximityPrompt session, purchases quantity, and returns you back.",
    Callback = function()
        local ok, msg = buyAtStand(HUB.State.ShopItem, HUB.State.ShopAmount)
        notify("Stand Shop", msg, 3.5)
    end,
})

TabEcon:Button({
    Title = "Refresh Shop Stands in Range",
    Callback = function()
        local fresh = collectDynamicLists()
        if ShopDrop and ShopDrop.Refresh then
            ShopDrop:Refresh(fresh.standNames)
        end
        notify("Shop Stands", "Found " .. #fresh.standNames .. " shop stands.", 2.5)
    end,
})

TabEcon:Section({Title = "Equipment, Appraise & Keeper's Altar", Opened = false})

TabEcon:Button({
    Title = "Equip Preferred / Best Rod",
    Callback = function()
        local ok = equipRodByName(HUB.State.PreferredRod)
        notify("Rod Equip", ok and ("Equipped: " .. getCurrentRodName()) or "Failed to equip rod.", 2.5)
    end,
})

TabEcon:Button({
    Title = "Equip Best Bait Now",
    Callback = function()
        local ok = equipBestOrSelectedBait(HUB.State.PreferredBait)
        notify("Bait Equip", ok and ("Bait set to: " .. getCurrentBaitName()) or "No bait available or already equipped.", 2.5)
    end,
})

TabEcon:Button({
    Title = "Appraise Held Fish Anywhere (If Unlocked)",
    Desc = "Invokes RF/AppraiseAnywhere/Fire on currently held fish.",
    Callback = function()
        local rf = getNetRemote("AppraiseAnywhere/Fire")
        if not rf then notify("Appraise", "Remote unavailable.", 3) return end
        local ok, r1, r2 = pcall(function() return rf:InvokeServer() end)
        notify("Appraise", ok and tostring(r2 or r1 or "Attempted appraise") or tostring(r1), 3)
    end,
})

TabEcon:Button({
    Title = "Teleport to Appraiser (Moosewood)",
    Callback = function()
        safeTeleport(CFrame.new(452.6, 152.5, 206.9))
    end,
})

TabEcon:Button({
    Title = "Teleport to Keeper's Altar",
    Callback = function()
        safeTeleport(ISLAND_COORDS["Keepers Altar"])
    end,
})

TabEcon:Button({
    Title = "Offer Held Enchant Relic (Altar)",
    Callback = function()
        local rf = getNetRemote("EnchantAltar/OfferRelic")
        if rf then
            local ok, r1, r2 = pcall(function() return rf:InvokeServer() end)
            notify("Keeper's Altar", ok and tostring(r2 or r1 or "Relic offered") or tostring(r1), 3)
        end
    end,
})

--=====================================================================
-- TAB 4: REWARDS, QUESTS & CODES
--=====================================================================
local TabRewards = Window:Tab({Title = "Rewards", Icon = "gift"})

TabRewards:Section({Title = "Rewards, Aquarium & World Collectibles", Opened = true})

local function claimAllRewardsOnce()
    local d = getNetRemote("DailyReward/Claim")
    if d then pcall(function() d:FireServer() end) end
    local ch = getNetRemote("Challenges/Claim")
    if ch then
        pcall(function() ch:InvokeServer("Daily") end)
        pcall(function() ch:InvokeServer("Weekly") end)
    end
    if Events and Events:FindFirstChild("claimGroupReward") then
        pcall(function() Events.claimGroupReward:FireServer() end)
    end
    local rj = getNetRemote("RodJournal/ClaimAllRodRewards")
    if rj then pcall(function() rj:FireServer() end) end
    local tm = getNetRemote("TimeMission/ClaimReward")
    if tm then pcall(function() tm:FireServer() end) end
end

TabRewards:Button({
    Title = "Claim All Available Rewards Now",
    Desc = "Claims Daily Login, Daily & Weekly Challenges, Group Reward, Rod Journal, and Time Missions.",
    Callback = function()
        claimAllRewardsOnce()
        notify("Rewards", "Claimed all available rewards!", 3)
    end,
})

bindElement(TabRewards, "Toggle", {
    Title = "Auto Claim Rewards Loop",
    Desc = "Checks and claims Daily/Challenge/Journal/Time rewards every 60s.",
    Flag = "AutoClaimRewards",
})

TabRewards:Button({
    Title = "Claim Aquarium Rewards & Equip Best",
    Callback = function()
        local cr = getNetRemote("PersonalAquarium/ClaimRewards")
        local eb = getNetRemote("PersonalAquarium/EquipBest")
        if eb then pcall(function() eb:FireServer() end) end
        if cr then pcall(function() cr:FireServer() end) end
        notify("Aquarium", "Equipped best fish & claimed Personal Aquarium rewards!", 3)
    end,
})

bindElement(TabRewards, "Toggle", {
    Title = "Auto Claim Personal Aquarium",
    Flag = "AutoClaimAquarium",
})

bindElement(TabRewards, "Toggle", {
    Title = "Auto Collect World ItemSpawns",
    Desc = "Collects nearby valid ItemSpawn points (Sky Crystals, Stars, Shells, etc.) via ItemSpawnCollect.",
    Flag = "AutoCollectItems",
})

TabRewards:Button({
    Title = "Teleport to Unopened Treasure Map Coords",
    Desc = "Finds first Treasure Map in Inventory and teleports to its X/Y/Z coordinates.",
    Callback = function()
        local inv = getInventoryTable()
        for _, entry in pairs(inv) do
            if entry.name == "Treasure Map" and type(entry.sub) == "table" and entry.sub.x then
                local tx, ty, tz = tonumber(entry.sub.x) or 0, tonumber(entry.sub.y) or 140, tonumber(entry.sub.z) or 0
                safeTeleport(CFrame.new(tx, ty + 4, tz))
                notify("Treasure Map", string.format("Teleported to (%.0f, %.0f, %.0f) [Repaired=%s]", tx, ty, tz, tostring(entry.sub.Repaired)), 4)
                return
            end
        end
        notify("Treasure Map", "No Treasure Map found in Inventory.", 3)
    end,
})

TabRewards:Section({Title = "Promo Codes", Opened = true})

TabRewards:Button({
    Title = "Redeem All Known Codes",
    Desc = "Runs ReplicatedStorage.events.runcode across built-in Fisch promo codes.",
    Callback = function()
        if not Events or not Events:FindFirstChild("runcode") then
            notify("Codes", "runcode remote missing.", 3)
            return
        end
        task.spawn(function()
            for _, code in ipairs(KNOWN_CODES) do
                if HUB.Destroyed then break end
                pcall(function() Events.runcode:FireServer(code) end)
                task.wait(0.55)
            end
            notify("Codes", "Finished redeeming " .. #KNOWN_CODES .. " promo codes.", 3)
        end)
    end,
})

bindElement(TabRewards, "Input", {
    Title = "Custom Promo Code",
    Value = "",
    Placeholder = "Enter code...",
    Flag = "CustomCode",
})

TabRewards:Button({
    Title = "Redeem Custom Code",
    Callback = function()
        local code = HUB.State.CustomCode
        if not code or code == "" then
            notify("Codes", "Please enter a code first.", 2.5)
            return
        end
        if Events and Events:FindFirstChild("runcode") then
            Events.runcode:FireServer(code)
            notify("Codes", "Sent code: " .. code, 2.5)
        end
    end,
})

--=====================================================================
-- TAB 5: TELEPORTS & SERVER
--=====================================================================
local TabTP = Window:Tab({Title = "Teleports", Icon = "map-pin"})

TabTP:Section({Title = "Islands & World Locations", Opened = true})

local IslandDrop = bindElement(TabTP, "Dropdown", {
    Title = "Select Island / Location",
    Values = InitLists.islandNames,
    Value = "Moosewood",
    SearchBarEnabled = true,
    Flag = "SelectedIsland",
})

TabTP:Button({
    Title = "Teleport to Selected Island",
    Callback = function()
        local ok = moveToFishingSpot(HUB.State.SelectedIsland)
        notify("Teleport", ok and ("Arrived at " .. HUB.State.SelectedIsland) or "Location not found.", 2.5)
    end,
})

TabTP:Section({Title = "Fishing Zones & Ocean Events", Opened = true})

local ZoneDrop = bindElement(TabTP, "Dropdown", {
    Title = "Select Fishing Zone / Ocean POI",
    Values = InitLists.zoneNames,
    Value = InitLists.zoneNames[1] or "Moosewood Docks",
    SearchBarEnabled = true,
    Flag = "SelectedFishingZone",
})

TabTP:Button({
    Title = "Teleport to Fishing Zone",
    Callback = function()
        local ok = moveToFishingSpot(HUB.State.SelectedFishingZone)
        notify("Zone Teleport", ok and ("Moved to " .. HUB.State.SelectedFishingZone) or "Zone not found.", 2.5)
    end,
})

TabTP:Button({
    Title = "Refresh Locations, Zones & NPCs",
    Callback = function()
        local fresh = collectDynamicLists()
        if IslandDrop and IslandDrop.Refresh then IslandDrop:Refresh(fresh.islandNames) end
        if ZoneDrop and ZoneDrop.Refresh then ZoneDrop:Refresh(fresh.zoneNames) end
        if ShopDrop and ShopDrop.Refresh then ShopDrop:Refresh(fresh.standNames) end
        notify("World Scan", string.format("%d Islands | %d Zones | %d NPCs", #fresh.islandNames, #fresh.zoneNames, #fresh.npcNames), 3)
    end,
})

TabTP:Section({Title = "NPCs, Players & Server", Opened = false})

local NpcDrop = bindElement(TabTP, "Dropdown", {
    Title = "Select NPC",
    Values = InitLists.npcNames,
    Value = table.find(InitLists.npcNames, "Marc Merchant") and "Marc Merchant" or (InitLists.npcNames[1] or "Marc Merchant"),
    SearchBarEnabled = true,
    Flag = "SelectedNPC",
})

TabTP:Button({
    Title = "Teleport to NPC",
    Callback = function()
        local fresh = collectDynamicLists()
        local cf = fresh.npcs[HUB.State.SelectedNPC]
        if cf then
            safeTeleport(cf + Vector3.new(0, 3, 2))
            notify("NPC Teleport", "Teleported to " .. HUB.State.SelectedNPC, 2.5)
        else
            notify("NPC Teleport", "NPC streamed out. Visit its island first.", 3)
        end
    end,
})

local function getOtherPlayerNames()
    local list = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then table.insert(list, pl.Name) end
    end
    table.sort(list)
    if #list == 0 then list[1] = "No Other Players" end
    return list
end

local PlrDrop = bindElement(TabTP, "Dropdown", {
    Title = "Select Player",
    Values = getOtherPlayerNames(),
    Value = getOtherPlayerNames()[1],
    Flag = "SelectedPlayer",
})

TabTP:Button({
    Title = "Teleport to Player / Refresh List",
    Callback = function()
        local list = getOtherPlayerNames()
        if PlrDrop and PlrDrop.Refresh then PlrDrop:Refresh(list) end
        local target = Players:FindFirstChild(HUB.State.SelectedPlayer)
        local tHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            safeTeleport(tHRP.CFrame + Vector3.new(0, 3, 2))
            notify("Player Teleport", "Teleported to " .. target.Name, 2.5)
        else
            notify("Player Teleport", "Player list refreshed.", 2)
        end
    end,
})

TabTP:Button({
    Title = "Rejoin Current Server",
    Callback = function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end,
})

TabTP:Button({
    Title = "Server Hop (Random Server)",
    Callback = function()
        local rf = getNetRemote("ServerBrowser/TeleportToRandom")
        if rf then
            local ok = pcall(function() return rf:InvokeServer() end)
            if ok then return end
        end
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end,
})

--=====================================================================
-- TAB 6: PLAYER & VISUALS
--=====================================================================
local TabPlayer = Window:Tab({Title = "Player & ESP", Icon = "eye"})

TabPlayer:Section({Title = "Movement (WalkSpeedController Bypassed)", Opened = true})

bindElement(TabPlayer, "Toggle", {
    Title = "Custom WalkSpeed",
    Desc = "Overrides WalkSpeedController on Heartbeat; cleanly restores default speed when OFF.",
    Flag = "EnableWalkSpeed",
    Callback = function(on)
        local hum = getHumanoid()
        if hum and not on then hum.WalkSpeed = 16 end
    end,
})

bindElement(TabPlayer, "Slider", {
    Title = "WalkSpeed",
    Value = {Min = 16, Max = 250, Default = 32},
    Step = 1,
    Flag = "WalkSpeedValue",
})

bindElement(TabPlayer, "Toggle", {
    Title = "Custom JumpPower",
    Desc = "Overrides JumpPower on Heartbeat; restores 50 when OFF.",
    Flag = "EnableJumpPower",
    Callback = function(on)
        local hum = getHumanoid()
        if hum and not on then hum.JumpPower = 50 end
    end,
})

bindElement(TabPlayer, "Slider", {
    Title = "JumpPower",
    Value = {Min = 50, Max = 250, Default = 65},
    Step = 1,
    Flag = "JumpPowerValue",
})

bindElement(TabPlayer, "Toggle", {
    Title = "Infinite Jump",
    Flag = "InfiniteJump",
})

bindElement(TabPlayer, "Toggle", {
    Title = "Noclip",
    Desc = "Walk through walls; restores original CanCollide states when disabled.",
    Flag = "Noclip",
    Callback = function(on)
        if not on then
            for part, orig in pairs(HUB.SavedCollision) do
                if part and part.Parent then pcall(function() part.CanCollide = orig end) end
            end
            table.clear(HUB.SavedCollision)
        end
    end,
})

bindElement(TabPlayer, "Toggle", {
    Title = "Walk On Water",
    Desc = "Spawns an invisible platform under your feet at MainSea level (Y=" .. string.format("%.1f", getSeaLevelY()) .. ").",
    Flag = "WalkOnWater",
    Callback = function(on)
        if not on and HUB.WaterPlatform then
            pcall(function() HUB.WaterPlatform:Destroy() end)
            HUB.WaterPlatform = nil
        end
    end,
})

TabPlayer:Section({Title = "Interactions, Visuals & ESP", Opened = true})

local function applyInstantPrompts(on)
    if on then
        local function zeroPrompt(pr)
            if pr and pr:IsA("ProximityPrompt") then
                if HUB.SavedPrompts[pr] == nil then HUB.SavedPrompts[pr] = pr.HoldDuration end
                pr.HoldDuration = 0
            end
        end
        for _, pr in ipairs(CollectionService:GetTagged("ProximityPrompt")) do
            zeroPrompt(pr)
        end
        local world = Workspace:FindFirstChild("world")
        for _, container in ipairs({
            world and world:FindFirstChild("npcs"),
            world and world:FindFirstChild("interactables"),
            Workspace:FindFirstChild("active"),
        }) do
            if container then
                for _, d in ipairs(container:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then zeroPrompt(d) end
                end
            end
        end
    else
        for pr, orig in pairs(HUB.SavedPrompts) do
            if pr and pr.Parent then pcall(function() pr.HoldDuration = orig end) end
        end
        table.clear(HUB.SavedPrompts)
    end
end

bindElement(TabPlayer, "Toggle", {
    Title = "Instant Proximity Prompts",
    Desc = "Sets HoldDuration = 0 on all ProximityPrompts; restores original hold times when OFF.",
    Flag = "InstantPrompts",
    Callback = applyInstantPrompts,
})

local function applyFullbright(on)
    if on then
        if not HUB.SavedLighting then
            HUB.SavedLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
            }
        end
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    elseif HUB.SavedLighting then
        for k, v in pairs(HUB.SavedLighting) do
            pcall(function() Lighting[k] = v end)
        end
        HUB.SavedLighting = nil
    end
end

bindElement(TabPlayer, "Toggle", {
    Title = "Fullbright & No Fog",
    Flag = "Fullbright",
    Callback = applyFullbright,
})

bindElement(TabPlayer, "Toggle", {
    Title = "Remove Underwater Blur & Tint",
    Flag = "NoUnderwaterFX",
    Callback = function(on)
        if on then
            local bl = Lighting:FindFirstChild("underwaterbl")
            if bl then bl.Enabled = false end
            local cc = Lighting:FindFirstChild("underwatercc")
            if cc then cc.Enabled = false end
        end
    end,
})

local function clearESPGroup(groupKey)
    if HUB.EspObjects[groupKey] then
        for _, obj in ipairs(HUB.EspObjects[groupKey]) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
        HUB.EspObjects[groupKey] = nil
    end
end

bindElement(TabPlayer, "Toggle", {
    Title = "Player ESP",
    Flag = "EspPlayers",
    Callback = function(on)
        if not on then clearESPGroup("players") end
    end,
})

bindElement(TabPlayer, "Toggle", {
    Title = "Ocean Event & POI ESP",
    Flag = "EspOceanEvents",
    Callback = function(on)
        if not on then clearESPGroup("events") end
    end,
})

bindElement(TabPlayer, "Toggle", {
    Title = "World Collectibles & Chest ESP",
    Flag = "EspCollectibles",
    Callback = function(on)
        if not on then clearESPGroup("collectibles") end
    end,
})

--=====================================================================
-- TAB 7: MISC, ANTI-AFK & CONFIG
--=====================================================================
local TabConfig = Window:Tab({Title = "Config", Icon = "settings"})

TabConfig:Section({Title = "Safety & UI", Opened = true})

local function toggleGameAfkConnections(enableBool)
    if not getconnections then return 0 end
    local touched = 0
    for _, sig in ipairs({LocalPlayer.Idled, UserInputService.WindowFocusReleased}) do
        for _, c in ipairs(getconnections(sig)) do
            local fn = c.Function
            if fn ~= nil and (not iscclosure or not iscclosure(fn)) then
                local src = tostring(debug.info(fn, "s") or "")
                if src:find("ReplicatedStorage") or src:find("CL_Rework") or src:find("AntiAfk") then
                    if enableBool and c.Enable then
                        pcall(function() c:Enable() end)
                        touched += 1
                    elseif (not enableBool) and c.Disable then
                        pcall(function() c:Disable() end)
                        touched += 1
                    end
                end
            end
        end
    end
    return touched
end

local function setAntiAFK(on)
    if on then
        toggleGameAfkConnections(false)
        if Events then
            if Events:FindFirstChild("idleReport") then pcall(function() Events.idleReport:FireServer(false) end) end
            if Events:FindFirstChild("afk") then pcall(function() Events.afk:FireServer(false) end) end
        end
    else
        toggleGameAfkConnections(true)
    end
end

bindElement(TabConfig, "Toggle", {
    Title = "Anti-AFK Protection",
    Desc = "Disables Roblox Idled + Fisch custom AFK/focus hooks and dispatches VirtualUser activity.",
    Flag = "AntiAFK",
    Callback = setAntiAFK,
})

TabConfig:Button({
    Title = "Unload XLunaHUB",
    Desc = "Cleanly stops all loops, restores game defaults, and removes the UI.",
    Callback = function()
        if HUB.Destroy then HUB.Destroy() end
    end,
})

TabConfig:Section({Title = "Config Manager", Opened = true})

local function ensureConfigDir()
    if isfolder and makefolder then
        if not isfolder(HUB.Folder) then pcall(makefolder, HUB.Folder) end
        if not isfolder(HUB.ConfigDir) then pcall(makefolder, HUB.ConfigDir) end
    end
end

local function listSavedConfigs()
    ensureConfigDir()
    local names = {}
    if listfiles then
        local ok, files = pcall(listfiles, HUB.ConfigDir)
        if ok and type(files) == "table" then
            for _, p in ipairs(files) do
                local n = p:match("([^/\\]+)%.json$")
                if n then table.insert(names, n) end
            end
        end
    end
    table.sort(names)
    return names
end

local function saveConfig(cfgName)
    cfgName = (cfgName or ""):gsub("[^%w_%-%s]", ""):match("^%s*(.-)%s*$")
    if cfgName == "" then return false, "Invalid config name" end
    if not writefile then return false, "writefile unsupported" end
    ensureConfigDir()
    local payload = {}
    for flag, info in pairs(HUB.Elements) do
        if flag ~= "ConfigName" and flag ~= "SelectedConfig" then
            payload[flag] = HUB.State[flag]
        end
    end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, payload)
    if not ok then return false, "JSON encode failed" end
    writefile(HUB.ConfigDir .. "/" .. cfgName .. ".json", encoded)
    return true, cfgName
end

local function loadConfig(cfgName)
    if not cfgName or cfgName == "" then return false, "No config selected" end
    local path = HUB.ConfigDir .. "/" .. cfgName .. ".json"
    if not isfile or not isfile(path) or not readfile then return false, "Config file missing" end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(data) ~= "table" then return false, "Corrupt config JSON" end
    for flag, val in pairs(data) do
        if flag ~= "ConfigName" and flag ~= "SelectedConfig" then
            local prev = HUB.State[flag]
            HUB.State[flag] = val
            if prev ~= val then
                local reg = HUB.Elements[flag]
                if reg and reg.elem then
                    if reg.kind == "Dropdown" and reg.elem.Select then
                        pcall(function() reg.elem:Select(val) end)
                    elseif reg.elem.Set then
                        pcall(function() reg.elem:Set(val) end)
                    end
                end
            end
        end
    end
    return true, cfgName
end

local ConfigInput = bindElement(TabConfig, "Input", {
    Title = "Config Name",
    Value = "default",
    Placeholder = "Enter config name...",
    Flag = "ConfigName",
})

local initCfgList = listSavedConfigs()
local ConfigDrop = bindElement(TabConfig, "Dropdown", {
    Title = "Saved Configs",
    Values = #initCfgList > 0 and initCfgList or {"(none)"},
    Value = #initCfgList > 0 and initCfgList[1] or "(none)",
    Flag = "SelectedConfig",
})

local function refreshConfigDropdown(selectName)
    local cfgs = listSavedConfigs()
    local vals = #cfgs > 0 and cfgs or {"(none)"}
    if ConfigDrop and ConfigDrop.Refresh then ConfigDrop:Refresh(vals) end
    if selectName and table.find(vals, selectName) and ConfigDrop and ConfigDrop.Select then
        pcall(function() ConfigDrop:Select(selectName) end)
    end
end

TabConfig:Button({
    Title = "Save Config",
    Callback = function()
        local name = HUB.State.ConfigName
        if not name or name == "" then name = HUB.State.SelectedConfig end
        local ok, res = saveConfig(name)
        refreshConfigDropdown(ok and res or nil)
        notify("Config", ok and ("Saved: " .. res) or tostring(res), 3)
    end,
})

TabConfig:Button({
    Title = "Load Selected Config",
    Callback = function()
        local target = HUB.State.SelectedConfig
        if not target or target == "(none)" or target == "" then target = HUB.State.ConfigName end
        local ok, res = loadConfig(target)
        notify("Config", ok and ("Loaded: " .. res) or tostring(res), 3)
    end,
})

TabConfig:Button({
    Title = "Delete Selected Config",
    Callback = function()
        local target = HUB.State.SelectedConfig
        if not target or target == "(none)" or target == "" then notify("Config", "No config selected.", 2.5) return end
        local path = HUB.ConfigDir .. "/" .. target .. ".json"
        if delfile and isfile and isfile(path) then
            delfile(path)
            refreshConfigDropdown()
            notify("Config", "Deleted: " .. target, 3)
        end
    end,
})

TabConfig:Button({
    Title = "Refresh Config List",
    Callback = function()
        refreshConfigDropdown()
        notify("Config", "Config list refreshed.", 2)
    end,
})

TabConfig:Button({
    Title = "Set Selected as Auto-Load",
    Callback = function()
        local target = HUB.State.SelectedConfig
        if target and target ~= "(none)" and target ~= "" and writefile then
            ensureConfigDir()
            writefile(HUB.AutoLoadFile, target)
            notify("Config", "Auto-Load set to: " .. target, 3)
        end
    end,
})

TabConfig:Button({
    Title = "Clear Auto-Load",
    Callback = function()
        if delfile and isfile and isfile(HUB.AutoLoadFile) then
            delfile(HUB.AutoLoadFile)
            notify("Config", "Cleared Auto-Load.", 2.5)
        end
    end,
})

--=====================================================================
-- RUNTIME WORKERS & CONNECTIONS
--=====================================================================

-- Track new ProximityPrompts & Backpack/Catch telemetry
trackConn(ProximityPromptService.PromptShown:Connect(function(prompt)
    if HUB.State.InstantPrompts and prompt:IsA("ProximityPrompt") then
        if HUB.SavedPrompts[prompt] == nil then HUB.SavedPrompts[prompt] = prompt.HoldDuration end
        prompt.HoldDuration = 0
    end
end))

trackConn(UserInputService.JumpRequest:Connect(function()
    if HUB.State.InfiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

trackConn(LocalPlayer.Idled:Connect(function()
    if HUB.State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end))

-- Heartbeat Worker: WalkSpeed / JumpPower / Noclip / WalkOnWater / Position Lock / ActiveReel BarLock
trackConn(RunService.Heartbeat:Connect(function()
    if HUB.Destroyed then return end
    local ch = getCharacter()
    local hum = getHumanoid()
    local hrp = getHRP()

    if hum and ch then
        if HUB.State.EnableWalkSpeed then
            hum.WalkSpeed = HUB.State.WalkSpeedValue
        end
        if HUB.State.EnableJumpPower then
            hum.JumpPower = HUB.State.JumpPowerValue
        end
        if HUB.State.Noclip then
            for _, d in ipairs(ch:GetDescendants()) do
                if d:IsA("BasePart") then
                    if HUB.SavedCollision[d] == nil then HUB.SavedCollision[d] = d.CanCollide end
                    d.CanCollide = false
                end
            end
        end
    end

    if hrp then
        if HUB.State.WalkOnWater then
            local seaY = getSeaLevelY()
            if not HUB.WaterPlatform or not HUB.WaterPlatform.Parent then
                local plat = Instance.new("Part")
                plat.Name = "XLunaHUB_WaterFloor"
                plat.Size = Vector3.new(28, 2, 28)
                plat.Anchored = true
                plat.CanCollide = true
                plat.Transparency = 0.85
                plat.Color = Color3.fromRGB(0, 170, 255)
                plat.Parent = Workspace
                HUB.WaterPlatform = plat
            end
            HUB.WaterPlatform.CFrame = CFrame.new(hrp.Position.X, seaY - 0.9, hrp.Position.Z)
        end

        if HUB.State.LockFishingSpot and HUB.LockedSpotCFrame then
            if (hrp.Position - HUB.LockedSpotCFrame.Position).Magnitude > 2.5 then
                hrp.CFrame = HUB.LockedSpotCFrame
            end
        end

        local fishingBusy = (HUB.State.AutoCast or HUB.State.FullAutoProgression) and HUB.State.FreezeWhileFishing
        if fishingBusy then
            local tl = getEquippedRodTool()
            if tl and (tl:FindFirstChild("bobber") or (ReelController and ReelController.ActiveReel)) then
                hrp.Anchored = true
            else
                hrp.Anchored = false
            end
        end
    end

    -- No Underwater FX
    if HUB.State.NoUnderwaterFX then
        local bl = Lighting:FindFirstChild("underwaterbl")
        if bl and bl.Enabled then bl.Enabled = false end
        local cc = Lighting:FindFirstChild("underwatercc")
        if cc and cc.Enabled then cc.Enabled = false end
    end

    -- Reel Minigame Assists
    if ReelController and ReelController.ActiveReel then
        local ar = ReelController.ActiveReel
        if HUB.State.AlwaysPerfect then
            ar.perfect = true
        end
        if HUB.State.ExpandCatchBar and ar.barSize and ar.barSize < 1 then
            ar.barSize = 1
        end
        if (HUB.State.AutoReel or HUB.State.FullAutoProgression) and HUB.State.ReelMode == "Legit Bar Lock" and ar.active then
            ar.barPosition = ar.fishPosition
            ar.onbar = true
            if ar.progress then
                ar.progress = math.min(100, ar.progress + 0.8)
            end
        end
    end
end))

-- Fishing Worker (AutoCast + AutoShake + Instant AutoReel)
spawnLoop("FishingEngine", function()
    local isFishingActive = HUB.State.FullAutoProgression or HUB.State.AutoCast or HUB.State.AutoShake or HUB.State.AutoReel
    if not isFishingActive then
        HUB.ShakeSeenAt = nil
        task.wait(0.2)
        return
    end

    local tool = getEquippedRodTool()

    -- 1. Handle Auto Equip Bait
    if HUB.State.AutoEquipBait or HUB.State.FullAutoProgression then
        equipBestOrSelectedBait(HUB.State.PreferredBait)
    end

    -- 2. Handle Auto Reel (Instant Post-Ready)
    if (HUB.State.AutoReel or HUB.State.FullAutoProgression) and ReelController and ReelController.ActiveReel then
        local ar = ReelController.ActiveReel
        if HUB.State.ReelMode == "Instant (Post-Ready)" or HUB.State.FullAutoProgression then
            if ar.ready then
                if (HUB.State.ReelDelay or 0) > 0 then task.wait(HUB.State.ReelDelay) end
                if ReelController.ActiveReel == ar then
                    if HUB.State.AlwaysPerfect or HUB.State.FullAutoProgression then
                        ar.perfect = true
                    end
                    pcall(function() ar:EndMinigame(true) end)
                    HUB.CaughtSessionCount += 1
                    task.wait(0.4)
                    return
                end
            end
        end
    end

    -- 3. Handle Auto Shake (CRITICAL: >= 0.32s initial delay + >= 0.30s interval!)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local shakeUI = pg and pg:FindFirstChild("shakeui")
    if (HUB.State.AutoShake or HUB.State.FullAutoProgression) and shakeUI and shakeUI.Enabled and not (ReelController and ReelController.ActiveReel) then
        local now = tick()
        if not HUB.ShakeSeenAt then
            HUB.ShakeSeenAt = now
        end
        local minWait = math.max(0.32, tonumber(HUB.State.ShakeInterval) or 0.32)
        if now - HUB.ShakeSeenAt >= 0.32 and now - HUB.LastShakeTime >= minWait then
            HUB.LastShakeTime = now
            local reShake = getNetRemote("LureShake/Shake")
            if reShake and reShake:IsA("RemoteEvent") then
                pcall(function() reShake:FireServer() end)
            end
        end
    else
        HUB.ShakeSeenAt = nil
    end

    -- 4. Handle Auto Cast
    if (HUB.State.AutoCast or HUB.State.FullAutoProgression) and not (ReelController and ReelController.ActiveReel) and not (shakeUI and shakeUI.Enabled) then
        if (HUB.State.AutoEquipRod or HUB.State.FullAutoProgression) then
            equipRodByName(HUB.State.PreferredRod)
            tool = getEquippedRodTool()
        end
        local hasBobber = tool and tool:FindFirstChild("bobber")
        if hasBobber then
            -- Timeout stuck cast (>28s without reel)
            if tick() - HUB.LastCastTime > 28 then
                local reReset = getNetRemote("FishingRod/Reset")
                if reReset then pcall(function() reReset:FireServer() end) end
                task.wait(0.35)
            end
        elseif tool and tick() - HUB.LastCastTime >= math.max(0.15, tonumber(HUB.State.CastDelay) or 0.25) then
            local rfCast = getNetRemote("FishingRod/Cast")
            if rfCast and rfCast:IsA("RemoteFunction") then
                HUB.LastCastTime = tick()
                local pwr = HUB.State.PerfectCast and 100 or math.random(92, 100)
                pcall(function() rfCast:InvokeServer(pwr, HUB.State.PerfectCast or HUB.State.FullAutoProgression) end)
                task.wait(0.35)
            end
        end
    end

    task.wait(0.05)
end)

-- Full Auto Progression Coordinator
spawnLoop("FullAutoCoordinator", function()
    if not HUB.State.FullAutoProgression then
        task.wait(0.4)
        return
    end

    local isInMinigame = (ReelController and ReelController.ActiveReel) or (LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("shakeui"))
    local rodTl = getEquippedRodTool()
    local bobberOut = rodTl and rodTl:FindFirstChild("bobber")
    if isInMinigame or bobberOut then
        task.wait(0.5)
        return
    end

    -- 1. Check Spot Proximity
    local targetSpot = ISLAND_COORDS[HUB.State.ProgressSpotMode]
    local hrp = getHRP()
    if targetSpot and hrp then
        if (hrp.Position - targetSpot.Position).Magnitude > 35 then
            HUB.StatusText = "Moving to " .. tostring(HUB.State.ProgressSpotMode)
            moveToFishingSpot(HUB.State.ProgressSpotMode)
            task.wait(0.3)
        end
    end

    -- 2. Check Inventory Auto Sell
    if HUB.State.ProgressAutoSell then
        local count = 0
        for _, v in pairs(getInventoryTable()) do
            if FishLib[v.name] and not FishLib[v.name].IsCrate then
                count += (v.sub and v.sub.Stack or 1)
            end
        end
        if count >= (HUB.State.ProgressSellThreshold or 15) then
            HUB.StatusText = "Selling fish..."
            sellAllSafe()
            task.wait(0.4)
        end
    end

    -- 3. Check Progression Rod Upgrade
    if HUB.State.ProgressBuyRods then
        local coins = getCoins()
        local owned = getOwnedRodsTable()
        local curBest = scoreRod(getBestOwnedRodName(), RodsLib[getBestOwnedRodName()])
        for _, cand in ipairs(PROGRESSION_RODS) do
            if not owned[cand.name] and coins >= cand.price and STAND_FALLBACKS[cand.name] then
                local rInfo = RodsLib[cand.name]
                if rInfo and scoreRod(cand.name, rInfo) > curBest then
                    HUB.StatusText = "Buying upgrade: " .. cand.name
                    local ok = buyAtStand(cand.name, 1)
                    if ok then equipRodByName(cand.name) end
                    break
                end
            end
        end
    end

    -- 4. Check Bait Crate Refill
    if HUB.State.ProgressBuyBaitCrates and #getOwnedBaitsList() == 0 and getCoins() >= 600 then
        HUB.StatusText = "Buying Bait Crates..."
        buyAtStand("Bait Crate", 3)
    end

    HUB.StatusText = "Full Auto Fishing"
    task.wait(0.6)
end)

-- Secondary Loops: AutoSell / CrabCages / Rewards / Aquarium / ItemSpawns / AntiAFK / Telemetry / ESP
spawnLoop("EconomyAndWorldLoops", function()
    local now = tick()

    -- Auto Sell Loop
    if HUB.State.AutoSellLoop and not HUB.State.FullAutoProgression then
        if not HUB._nextSell or now >= HUB._nextSell then
            HUB._nextSell = now + (HUB.State.AutoSellInterval or 15)
            pcall(sellAllSafe)
        end
    end

    -- Auto Crab Cages
    if HUB.State.AutoCrabCages and (not HUB._nextCageTick or now >= HUB._nextCageTick) then
        HUB._nextCageTick = now + 2.0
        -- Claim ready cages
        if CrabCageController and CrabCageController.ActiveCages and SharedCrabCage then
            local rfClaim = getNetRemote("CrabCage/Claim")
            for id, cage in pairs(CrabCageController.ActiveCages) do
                if cage.data and cage.data.s == SharedCrabCage.CageState.Claimable and rfClaim then
                    pcall(function() rfClaim:InvokeServer(id) end)
                    task.wait(0.15)
                end
            end
        end
        -- Place cage if one is in inventory/backpack
        local inv = getInventoryTable()
        local cageItemId = nil
        for id, v in pairs(inv) do
            if v.name == "Crab Cage" or (CrabCagesLib.byName and CrabCagesLib.byName[v.name]) then
                cageItemId = {id = id, name = v.name}
                break
            end
        end
        if cageItemId and SharedCrabCage then
            local hrp = getHRP()
            local zFish = Workspace:FindFirstChild("zones") and Workspace.zones:FindFirstChild("fishing")
            if hrp and zFish then
                local rcP = RaycastParams.new()
                rcP.FilterType = Enum.RaycastFilterType.Include
                rcP.FilterDescendantsInstances = {zFish}
                local hit = Workspace:Raycast(hrp.Position + hrp.CFrame.LookVector * 8 + Vector3.new(0, 12, 0), Vector3.new(0, -40, 0), rcP)
                if hit then
                    local reEq = getNetRemote("Backpack/Equip")
                    if reEq then pcall(function() reEq:FireServer(cageItemId.id, true) end); task.wait(0.15) end
                    local cf = SharedCrabCage:RoundCFrame(hit.Position, CFrame.lookAt(hit.Position, hrp.Position))
                    local cid = (CrabCagesLib.byName and CrabCagesLib.byName[cageItemId.name] and CrabCagesLib.byName[cageItemId.name].Id) or 1
                    local rfPlace = getNetRemote("CrabCage/Place")
                    if rfPlace then pcall(function() rfPlace:InvokeServer(cf, cid) end) end
                end
            end
        end
    end

    -- Auto Rewards & Aquarium
    if HUB.State.AutoClaimRewards and (not HUB._nextRew or now >= HUB._nextRew) then
        HUB._nextRew = now + 60
        claimAllRewardsOnce()
    end
    if HUB.State.AutoClaimAquarium and (not HUB._nextAq or now >= HUB._nextAq) then
        HUB._nextAq = now + 60
        local cr = getNetRemote("PersonalAquarium/ClaimRewards")
        if cr then pcall(function() cr:FireServer() end) end
    end

    -- Auto Collect World ItemSpawns
    if HUB.State.AutoCollectItems then
        local hrp = getHRP()
        local rfCol = getNetRemote("ItemSpawnCollect")
        if hrp and rfCol then
            for _, inst in ipairs(CollectionService:GetTagged("ItemSpawn")) do
                if HUB.Destroyed or not HUB.State.AutoCollectItems then break end
                local root = inst:FindFirstChild("Root")
                local pr = root and root:FindFirstChild("Prompt")
                if pr and pr.Enabled and (root.Position - hrp.Position).Magnitude < 120 then
                    pcall(function() rfCol:InvokeServer(inst.Name) end)
                    task.wait(0.15)
                end
            end
        end
    end

    -- Periodic Anti-AFK keep-alive
    if HUB.State.AntiAFK and (not HUB._nextAFK or now >= HUB._nextAFK) then
        HUB._nextAFK = now + 60
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
            if Events and Events:FindFirstChild("idleReport") then Events.idleReport:FireServer(false) end
            if Events and Events:FindFirstChild("afk") then Events.afk:FireServer(false) end
        end)
    end

    task.wait(1)
end)

-- Live Telemetry & Lightweight ESP Loop
spawnLoop("TelemetryAndESP", function()
    if HUB.Destroyed then return end
    if StatusPara and StatusPara.SetDesc then
        local st = getStatsFolder()
        local caught = st and st:FindFirstChild("tracker_fishcaught") and st.tracker_fishcaught.Value or 0
        local world = ReplicatedStorage:FindFirstChild("world")
        local wv = world and world:FindFirstChild("weather") and world.weather.Value or "?"
        local cyc = world and world:FindFirstChild("cycle") and world.cycle.Value or "?"
        local bagFish = 0
        for _, v in pairs(getInventoryTable()) do
            if FishLib[v.name] and not FishLib[v.name].IsCrate then
                bagFish += (v.sub and v.sub.Stack or 1)
            end
        end
        pcall(function()
            StatusPara:SetDesc(string.format(
                "C$: %d  |  Level: %d  |  Caught: %d (+%d session)\nRod: %s  |  Bait: %s  |  Fish in Bag: %d\nWeather: %s  |  Time: %s  |  Status: %s",
                getCoins(), getLevel(), caught, HUB.CaughtSessionCount,
                getCurrentRodName(), getCurrentBaitName(), bagFish,
                tostring(wv), tostring(cyc), tostring(HUB.StatusText)
            ))
        end)
    end

    local hrp = getHRP()

    local function makeTag(parent, groupKey, text, color)
        local hl = Instance.new("Highlight")
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.7
        hl.Adornee = parent
        hl.Parent = parent
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(140, 32)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Adornee = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0.2
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.Text = text
        lbl.Parent = bb
        bb.Parent = parent
        HUB.EspObjects[groupKey] = HUB.EspObjects[groupKey] or {}
        table.insert(HUB.EspObjects[groupKey], hl)
        table.insert(HUB.EspObjects[groupKey], bb)
    end

    if HUB.State.EspPlayers then
        clearESPGroup("players")
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local thrp = pl.Character:FindFirstChild("HumanoidRootPart")
                local d = (hrp and thrp) and math.floor((hrp.Position - thrp.Position).Magnitude) or 0
                makeTag(pl.Character, "players", pl.Name .. " [" .. d .. "m]", Color3.fromRGB(90, 210, 255))
            end
        end
    end

    if HUB.State.EspOceanEvents then
        clearESPGroup("events")
        local act = Workspace:FindFirstChild("active")
        local poi = act and act:FindFirstChild("OceanPOI's")
        if poi then
            for _, d in ipairs(poi:GetChildren()) do
                local cf = d:IsA("BasePart") and d.CFrame or (d:IsA("Model") and d:GetPivot())
                local dist = (hrp and cf) and math.floor((hrp.Position - cf.Position).Magnitude) or 0
                makeTag(d, "events", d.Name .. " [" .. dist .. "m]", Color3.fromRGB(255, 210, 75))
            end
        end
    end

    if HUB.State.EspCollectibles then
        clearESPGroup("collectibles")
        for _, inst in ipairs(CollectionService:GetTagged("ItemSpawn")) do
            local root = inst:FindFirstChild("Root")
            local pr = root and root:FindFirstChild("Prompt")
            if pr and pr.Enabled then
                local dist = (hrp and root) and math.floor((hrp.Position - root.Position).Magnitude) or 0
                makeTag(inst, "collectibles", (inst:GetAttribute("ItemName") or inst.Name) .. " [" .. dist .. "m]", Color3.fromRGB(120, 255, 140))
            end
        end
    end

    task.wait(1.2)
end)

-- Auto-Load ONLY if user explicitly created autoload.txt (never on clean install)
if isfile and isfile(HUB.AutoLoadFile) and readfile then
    local savedTarget = (readfile(HUB.AutoLoadFile) or ""):match("^%s*(.-)%s*$")
    if savedTarget ~= "" then
        task.defer(function()
            local ok = loadConfig(savedTarget)
            if ok then notify("Auto-Load", "Loaded config: " .. savedTarget, 3) end
        end)
    end
end

-- Teardown Handler
function HUB.Destroy()
    if HUB.Destroyed then return end
    HUB.Destroyed = true

    for k in pairs(HUB.State) do
        if type(HUB.State[k]) == "boolean" then
            HUB.State[k] = false
        end
    end

    for _, c in ipairs(HUB.Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(HUB.Connections)

    for _, co in ipairs(HUB.Threads) do
        pcall(task.cancel, co)
    end
    table.clear(HUB.Threads)

    setAntiAFK(false)
    applyInstantPrompts(false)
    applyFullbright(false)
    for part, orig in pairs(HUB.SavedCollision) do
        if part and part.Parent then pcall(function() part.CanCollide = orig end) end
    end
    table.clear(HUB.SavedCollision)

    if HUB.WaterPlatform then pcall(function() HUB.WaterPlatform:Destroy() end) end
    local hrp = getHRP()
    if hrp then hrp.Anchored = false end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end

    clearESPGroup("players")
    clearESPGroup("events")
    clearESPGroup("collectibles")

    if HUB.Window then
        if HUB.Window.SetToggleKey then pcall(function() HUB.Window:SetToggleKey(nil) end) end
        if HUB.Window.Destroy then pcall(function() HUB.Window:Destroy() end) end
    end
    env.__XLunaHUB = nil
end

HUB.Actions = {
    SellAll = sellAllSafe,
    BuyAtStand = buyAtStand,
    ClaimAllRewards = claimAllRewardsOnce,
    SafeTeleport = moveToFishingSpot,
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,
    DeleteConfig = function(name)
        local p = HUB.ConfigDir .. "/" .. tostring(name) .. ".json"
        if delfile and isfile and isfile(p) then
            delfile(p)
            refreshConfigDropdown()
            return true
        end
        return false
    end,
}

notify("XLunaHUB | Fisch", "Loaded cleanly! All features start OFF. Press LeftControl or Floating Button to toggle UI.", 4)
