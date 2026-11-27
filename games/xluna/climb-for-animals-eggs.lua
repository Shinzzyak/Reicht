-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [ð¥] Climb For Animals Eggs â Elite Automation Master Script
    Architecture: WindUI v1.6.66 / Modern Luau / Real MCP Execution
    Operating Directive: Universal English UI, Non-Negotiable Safety, ALL OFF Startup Default.
    Repository: E:\SC\Climb For Animals Eggs\ClientOP_ClimbForAnimalsEggs.lua
]]

-- Anti-double-execution guard
if getgenv()._CLIMB_EGGS_RUNNING then
    if getgenv()._CLIMB_EGGS_UNLOAD then
        pcall(getgenv()._CLIMB_EGGS_UNLOAD)
    end
    task.wait(0.2)
end

-- Clean any stale WindUI ScreenGuis
local targetParent = gethui and gethui() or game:GetService("CoreGui")
for _, c in ipairs(targetParent:GetChildren()) do
    if string.find(c.Name, "WindUI") then
        pcall(c.Destroy, c)
    end
end

getgenv()._CLIMB_EGGS_RUNNING = true

-- Nil-safe cloneref polyfill for WindUI compatibility
if cloneref then
    local _raw_cloneref = cloneref
    getgenv().cloneref = function(obj)
        if obj == nil then return nil end
        local success, result = pcall(_raw_cloneref, obj)
        return success and result or obj
    end
end

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LocalPlayer references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)
end)

-- Require Knit Framework & Packages
local KnitPackage = ReplicatedStorage:WaitForChild("src"):WaitForChild("Packages"):WaitForChild("knit")
local knit = require(KnitPackage)
local promise = require(ReplicatedStorage.src.Packages.promise)

-- Safe Knit Framework Resolvers (Pcall protected to prevent missing controller crashes)
local servicesFolder = ReplicatedStorage:FindFirstChild("Services", true)

local function SafeGetController(name)
    local ok, res = pcall(knit.GetController, name)
    return ok and res or nil
end

local function SafeGetService(name)
    if servicesFolder and not servicesFolder:FindFirstChild(name) then
        return nil
    end
    local ok, res = pcall(knit.GetService, name)
    return ok and res or nil
end

-- Resolve Knit Controllers
local DataController = SafeGetController("DataController")
local TreadmillController = SafeGetController("TreadmillController")
local GuardController = SafeGetController("GuardController")
local EggController = SafeGetController("EggController")
local EggHatchController = SafeGetController("EggHatchController")
local EggCarryController = SafeGetController("EggCarryController")
local AutoHatchController = SafeGetController("AutoHatchController")
local BaseController = SafeGetController("BaseController")
local BaseUpgradeController = SafeGetController("BaseUpgradeController")
local StaminaUpgradeController = SafeGetController("StaminaUpgradeController")
local RebirthController = SafeGetController("RebirthController")
local FuseController = SafeGetController("FuseController")
local AnimalSellController = SafeGetController("AnimalSellController")
local ButtonsController = SafeGetController("ButtonsController")
local ZoneController = SafeGetController("ZoneController")
local PanelController = SafeGetController("PanelController")

-- Resolve Knit Services
local TreadmillService = SafeGetService("TreadmillService")
local GuardService = SafeGetService("GuardService")
local EggHatchService = SafeGetService("EggHatchService")
local EggPurchaseService = SafeGetService("EggPurchaseService")
local BaseUpgradeService = SafeGetService("BaseUpgradeService")
local StaminaUpgradeService = SafeGetService("StaminaUpgradeService")
local RebirthService = SafeGetService("RebirthService")
local DailyRewardsService = SafeGetService("DailyRewardsService")
local GiftPlayTimeService = SafeGetService("GiftPlayTimeService")
local GroupRewardService = SafeGetService("GroupRewardService")
local IndexService = SafeGetService("IndexService")
local FuseService = SafeGetService("FuseService")
local PortalService = SafeGetService("PortalService")
local MiniMonsterService = SafeGetService("MiniMonsterService")
local AnimalSellService = SafeGetService("AnimalSellService")
local EggSpawnService = SafeGetService("EggSpawnService")
local HalloweenShopService = SafeGetService("HalloweenShopService")
local WitchBossService = SafeGetService("WitchBossService")

-- Configuration modules
local rebirthConfig = require(ReplicatedStorage.src.GameConfiguration.Economy.rebirthConfig)
local treadmillConfig = require(ReplicatedStorage.src.GameConfiguration.Economy.treadmillConfig)
local guardConfig = require(ReplicatedStorage.src.GameConfiguration.Gameplay.guardConfig)

-- Registry for clean shutdown
local Tasks = {}
local Connections = {}
local function RegisterTask(thread)
    table.insert(Tasks, thread)
    return thread
end
local function RegisterConnection(conn)
    table.insert(Connections, conn)
    return conn
end

-- =========================================================================
-- STATE MANAGEMENT (RULE 8: ALL OFF BY DEFAULT)
-- =========================================================================
local State = {
    -- Eggs & Hatching
    AutoHatchPlaced = false,
    InstantHatchClaim = false,
    AutoStealEggs = false,
    TargetStealBiome = "Closest",
    AutoReturnLobby = false,

    -- Halloween Event
    AutoBuyHalloweenEgg = false,
    AutoCollectCandy = false,
    AutoFarmMonsters = false,
    RapidAttack = false,
    TargetMonsterType = "All Monsters",
    AttackCooldown = 0.35,
    AutoEquipBat = false,

    -- Treadmill & Speed
    AutoTrainTreadmill = false,
    AutoBoostClicker = false,
    AutoUpgradeTreadmill = false,

    -- Guards & Stealth
    ParalyzeGuards = false,
    AutoCaptureGuards = false,

    -- Base & Upgrades
    AutoUpgradeBase = false,
    AutoUpgradeStamina = false,
    AutoRebirth = false,

    -- Rewards & Gifts
    AutoDailyRewards = false,
    AutoPlaytimeGifts = false,
    AutoGroupReward = false,
    AutoClaimIndex = false,

    -- Movement & Climbing
    AntiAFK = false,
    AutoClimbAscend = false,
    ClimbAscendSpeed = 80,
    AntiVoidFall = false,
    InfiniteJump = false,
    Noclip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    SelectedBiome = "Forest"
}

-- Biome Platform Coordinates Mapping
local BiomeLocations = {
    ["Lobby / Base"] = Vector3.new(2229.6, 72.5, -751.5),
    ["Forest"] = Vector3.new(2164.1, 211.5, -751.2),
    ["Winter"] = Vector3.new(2164.1, 415.5, -751.2),
    ["Ocean"] = Vector3.new(2164.1, 823.5, -751.2),
    ["Desert"] = Vector3.new(2164.1, 1367.5, -751.2),
    ["Crystal Mines"] = Vector3.new(2164.1, 2183.5, -751.2),
    ["Jungle"] = Vector3.new(2164.1, 3135.5, -751.2),
    ["Mystic Isles"] = Vector3.new(2164.1, 4359.5, -751.2),
    ["PreHistoric"] = Vector3.new(2164.1, 5651.5, -751.2),
    ["Divine Heights"] = Vector3.new(2164.1, 7147.5, -751.2),
    ["Celestial"] = Vector3.new(2164.1, 8643.5, -751.2),
    ["Realm of Legends"] = Vector3.new(2164.0, 10139.5, -751.4),
    ["Forbidden Forest"] = Vector3.new(2164.2, 12179.5, 9248.9),
    ["Ocean Abyss"] = Vector3.new(2164.0, 12179.5, -751.1),
    ["Astral Dominio"] = Vector3.new(2164.0, 16259.5, -751.1),
    ["Halloween Lobby"] = Vector3.new(2304.5, 75.0, 4514.0),
    ["Pumpkin Abyss"] = Vector3.new(2159.5, 460.0, 4555.3),
    ["Bone Field"] = Vector3.new(2160.3, 1670.0, 4544.7),
    ["Witches Castle"] = Vector3.new(2096.7, 3755.0, 4550.8),
    ["Witch Boss Arena"] = Vector3.new(2072.9, 3770.0, 4589.0),
    ["Halloween Dimension"] = Vector3.new(2304.5, 75.0, 4514.0)
}

local BiomeList = {
    "Forest", "Winter", "Ocean", "Desert", "Crystal Mines",
    "Jungle", "Mystic Isles", "PreHistoric", "Divine Heights",
    "Celestial", "Realm of Legends", "Forbidden Forest",
    "Ocean Abyss", "Astral Dominio",
    "Halloween Lobby", "Pumpkin Abyss", "Bone Field", "Witches Castle", "Witch Boss Arena"
}

local StealBiomeFilter = {
    "Closest", "Forest", "Winter", "Ocean", "Desert", "Crystal Mines",
    "Jungle", "Mystic Isles", "PreHistoric", "Divine Heights",
    "Celestial", "Realm of Legends", "Forbidden Forest",
    "Ocean Abyss", "Astral Dominio",
    "Pumpkin Abyss", "Bone Field", "Witches Castle"
}

local MonsterDropdownList = {
    "All Monsters",
    "Pumpkin (Abyss)",
    "CoffinMonster (Bone Field)",
    "Gargoyle (Castle)",
    "SwampWitch (Boss)"
}

local MonsterNameLookup = {
    ["All Monsters"] = "All",
    ["Pumpkin (Abyss)"] = "Pumpkin",
    ["CoffinMonster (Bone Field)"] = "CoffinMonster",
    ["Gargoyle (Castle)"] = "Gargoyle",
    ["SwampWitch (Boss)"] = "SwampWitch"
}

-- =========================================================================
-- 6-LAYER BULLETPROOF GUARD NEUTRALIZATION & STUN DISCONNECT ENGINE
-- =========================================================================
local originalUpdateGuards = GuardController.updateGuards
local originalUpdateGuard = GuardController.updateGuard
local originalRequestCapture = GuardController.requestCapture
local originalFreezeCharacter = GuardController.freezeCharacter
local originalGetPunchVelocity = GuardController.getPunchVelocity
local originalConnectCharacter = GuardController.connectCharacter

-- Disconnect native StunConnection to permanently block client punch velocity & freeze
local function NeutralizeStunConnection()
    pcall(function()
        if GuardController.StunConnection then
            GuardController.StunConnection:Disconnect()
            GuardController.StunConnection = nil
        end
        if GuardController.RestoreStun then
            pcall(GuardController.RestoreStun)
            GuardController.RestoreStun = nil
        end
    end)
end

NeutralizeStunConnection()

-- Layer 1: Force all guards to sleep/jailed and prevent danger music
GuardController.updateGuards = function(self, a2)
    if State.ParalyzeGuards or State.AutoStealEggs or State.AutoCaptureGuards then
        NeutralizeStunConnection()
        for _, g in pairs(self.Guards) do
            if g.Model and g.Model.Parent then
                pcall(function()
                    self:setJailed(g, true, a2)
                end)
            end
        end
        self:setDanger(false)
        return
    end
    return originalUpdateGuards(self, a2)
end

-- Layer 2: Neutralize individual guard tick
GuardController.updateGuard = function(self, a2, a3, a4, a5, a6)
    if State.ParalyzeGuards or State.AutoStealEggs or State.AutoCaptureGuards then
        if a2.State ~= "Idle" then
            a2.State = "Idle"
        end
        return false
    end
    return originalUpdateGuard(self, a2, a3, a4, a5, a6)
end

-- Layer 3: Block all client-to-server capture requests
GuardController.requestCapture = function(self, a2, a3, a4)
    if State.ParalyzeGuards or State.AutoStealEggs or State.AutoCaptureGuards then
        return
    end
    return originalRequestCapture(self, a2, a3, a4)
end

-- Layer 4: Suppress character freeze on stun
GuardController.freezeCharacter = function(self, a2, a3)
    if State.ParalyzeGuards or State.AutoStealEggs or State.AutoCaptureGuards then
        return function() end
    end
    return originalFreezeCharacter(self, a2, a3)
end

-- Layer 5: Suppress character punch velocity (fling)
GuardController.getPunchVelocity = function(self)
    if State.ParalyzeGuards or State.AutoStealEggs or State.AutoCaptureGuards then
        return Vector3.zero
    end
    return originalGetPunchVelocity(self)
end

-- Layer 6: Auto-disconnect StunConnection whenever character respawns
GuardController.connectCharacter = function(self, char)
    originalConnectCharacter(self, char)
    NeutralizeStunConnection()
end

-- Character Stun Attribute Protection Listener
local function AttachStunProtector(char)
    if not char then return end
    NeutralizeStunConnection()
    RegisterConnection(char:GetAttributeChangedSignal("GuardStunned"):Connect(function()
        if (State.ParalyzeGuards or State.AutoStealEggs or State.AutoCaptureGuards) and char:GetAttribute("GuardStunned") then
            pcall(function()
                NeutralizeStunConnection()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = State.WalkSpeed or 16
                    hum.JumpPower = State.JumpPower or 50
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end
    end))
end

if Character then AttachStunProtector(Character) end
LocalPlayer.CharacterAdded:Connect(AttachStunProtector)

-- =========================================================================
-- GAMEPASS BYPASS DETOUR (AUTO HATCH CONTROLLER)
-- =========================================================================
local originalAutoHatchIsEnabled = AutoHatchController.IsEnabled
AutoHatchController.IsEnabled = function(self)
    if State.AutoHatchPlaced then
        return true
    end
    return originalAutoHatchIsEnabled(self)
end

-- =========================================================================
-- INSTANT HATCH CLAIM DETOUR (EGG HATCH CONTROLLER ANIMATION BYPASS)
-- =========================================================================
local originalShakeEffect = EggHatchController.shakeEffect
local originalAnimalEffect = EggHatchController.animalEffect
local originalRobuxMysteryEffect = EggHatchController.robuxEggMysteryEffect

EggHatchController.shakeEffect = function(self, a2)
    if State.InstantHatchClaim then
        return promise.resolve()
    end
    return originalShakeEffect(self, a2)
end

EggHatchController.animalEffect = function(self, a2)
    if State.InstantHatchClaim then
        return promise.resolve()
    end
    return originalAnimalEffect(self, a2)
end

EggHatchController.robuxEggMysteryEffect = function(self, a1, a2)
    if State.InstantHatchClaim then
        return promise.resolve()
    end
    return originalRobuxMysteryEffect(self, a1, a2)
end

-- =========================================================================
-- TREADMILL BOOST CLICKER SIGNAL HOOK & FAST CLAIM
-- =========================================================================
local claimTmAction = nil
pcall(function()
    claimTmAction = require(LocalPlayer.PlayerScripts.src.userInterface.buttons.TypeFunctions.Action.claimTmMultiplierAction)
end)

local function ProcessClaimMultiplier(multiplierId)
    if not multiplierId then return end
    pcall(function()
        TreadmillService.MultiplierClicked:Fire(multiplierId)
    end)
    pcall(function()
        TreadmillController:ClaimMultiplier(multiplierId)
    end)
    task.defer(function()
        task.wait(0.04)
        local generalGui = LocalPlayer.PlayerGui:FindFirstChild("General")
        if generalGui then
            for _, child in pairs(generalGui:GetChildren()) do
                if child.Name ~= "BonusClick" and (child.Name == multiplierId or child:FindFirstChild("ImageButton")) then
                    local btn = child:FindFirstChildOfClass("ImageButton")
                    if btn then
                        if claimTmAction then
                            pcall(claimTmAction, btn)
                        end
                        if ButtonsController then
                            pcall(function() ButtonsController:Unlink(btn) end)
                        end
                    end
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)
end

if TreadmillController.Signals and TreadmillController.Signals.ShowMultiplierButton then
    RegisterConnection(TreadmillController.Signals.ShowMultiplierButton:Connect(function(multiplierId, sessionId)
        if State.AutoBoostClicker then
            ProcessClaimMultiplier(multiplierId)
        end
    end))
end

if TreadmillService.ShowMultiplier then
    RegisterConnection(TreadmillService.ShowMultiplier:Connect(function(multiplierId, sessionId)
        if State.AutoBoostClicker then
            ProcessClaimMultiplier(multiplierId)
        end
    end))
end

-- =========================================================================
-- UNLOAD HANDLER
-- =========================================================================
getgenv()._CLIMB_EGGS_UNLOAD = function()
    getgenv()._CLIMB_EGGS_RUNNING = false

    -- Restore GuardController hooks
    GuardController.updateGuards = originalUpdateGuards
    GuardController.updateGuard = originalUpdateGuard
    GuardController.requestCapture = originalRequestCapture
    GuardController.freezeCharacter = originalFreezeCharacter
    GuardController.getPunchVelocity = originalGetPunchVelocity
    GuardController.connectCharacter = originalConnectCharacter

    -- Restore AutoHatchController hook
    AutoHatchController.IsEnabled = originalAutoHatchIsEnabled

    -- Restore EggHatchController animation hooks
    EggHatchController.shakeEffect = originalShakeEffect
    EggHatchController.animalEffect = originalAnimalEffect
    EggHatchController.robuxEggMysteryEffect = originalRobuxMysteryEffect

    -- Cancel all background threads
    for _, t in ipairs(Tasks) do
        pcall(task.cancel, t)
    end
    table.clear(Tasks)

    -- Disconnect events
    for _, c in ipairs(Connections) do
        pcall(c.Disconnect, c)
    end
    table.clear(Connections)

    -- Remove LinearVelocity from HumanoidRootPart
    if HumanoidRootPart then
        local lv = HumanoidRootPart:FindFirstChild("OP_ClimbLinearVelocity")
        if lv then pcall(lv.Destroy, lv) end
        local att = HumanoidRootPart:FindFirstChild("OP_ClimbAttachment")
        if att then pcall(att.Destroy, att) end
    end

    -- Restore Humanoid defaults
    if Humanoid then
        pcall(function()
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end)
    end

    -- Destroy UI
    if getgenv()._CLIMB_EGGS_WINDOW then
        pcall(getgenv()._CLIMB_EGGS_WINDOW.Destroy, getgenv()._CLIMB_EGGS_WINDOW)
    end
end

-- =========================================================================
-- LOAD WINDUI FRAMEWORK
-- =========================================================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local function SafeNotify(opts)
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify(opts)
        end)
    end
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Climb For Animals Eggs",
    Icon = "egg",
    Author = "Elite Automation Suite",
    Folder = "ClimbForAnimalsEggs",
    Size = UDim2.fromOffset(620, 500),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Title = "Open Script",
        Icon = "crosshair",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("00D2FF"),
            Color3.fromHex("00FF88")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
    ToggleKey = Enum.KeyCode.LeftControl,
})

getgenv()._CLIMB_EGGS_WINDOW = Window

-- Construct Tabs
local TabEggs       = Window:Tab({ Title = "Eggs & Hatching", Icon = "egg" })
local TabHalloween  = Window:Tab({ Title = "Halloween Event", Icon = "ghost" })
local TabTreadmill  = Window:Tab({ Title = "Treadmill & Speed", Icon = "flame" })
local TabGuards     = Window:Tab({ Title = "Guards & Stealth", Icon = "shield" })
local TabBase       = Window:Tab({ Title = "Base & Upgrades", Icon = "wrench" })
local TabRewards    = Window:Tab({ Title = "Rewards & Gifts", Icon = "gift" })
local TabClimb      = Window:Tab({ Title = "Climbing & Biomes", Icon = "map-pin" })
local TabMovement   = Window:Tab({ Title = "Movement & Physics", Icon = "gauge" })
local TabConfig     = Window:Tab({ Title = "Configuration", Icon = "settings" })

-- =========================================================================
-- TAB 1: EGGS & HATCHING
-- =========================================================================
TabEggs:Section({ Title = "Base Egg Incubation", Opened = true })

local EggStatusLabel = TabEggs:Paragraph({
    Title = "Incubation Status",
    Desc = "Monitoring placed eggs on base plot...",
})

TabEggs:Toggle({
    Title = "Auto Hatch Placed Eggs (Gamepass Bypass)",
    Desc = "Automatically hatches eggs on your base when ready, bypassing the paid Gamepass requirement",
    Value = State.AutoHatchPlaced,
    Callback = function(val)
        State.AutoHatchPlaced = val
    end,
})

TabEggs:Toggle({
    Title = "Instant Claim Hatched Animals",
    Desc = "Immediately calls CompleteHatch to skip waiting for the 3D egg hatch sequence",
    Value = State.InstantHatchClaim,
    Callback = function(val)
        State.InstantHatchClaim = val
    end,
})

TabEggs:Section({ Title = "World Egg Stealing Automation", Opened = true })

local StealStatusLabel = TabEggs:Paragraph({
    Title = "Egg Steal Automation Status",
    Desc = "Idle - Waiting for activation...",
})

TabEggs:Dropdown({
    Title = "Target Steal Biome",
    Desc = "Choose whether to target the closest spawned egg or a specific biome",
    Values = StealBiomeFilter,
    Value = State.TargetStealBiome,
    Callback = function(val)
        State.TargetStealBiome = val
    end,
})

TabEggs:Toggle({
    Title = "Auto Steal & Deliver Eggs",
    Desc = "Automatically sweeps target eggs, triggers steal prompt instantly, and delivers them to safe zone",
    Value = State.AutoStealEggs,
    Callback = function(val)
        State.AutoStealEggs = val
    end,
})

TabEggs:Toggle({
    Title = "Auto Return to SafeZone When Carrying",
    Desc = "Instantly teleports you into the Lobby SafeZone as soon as an egg is grabbed to secure delivery",
    Value = State.AutoReturnLobby,
    Callback = function(val)
        State.AutoReturnLobby = val
    end,
})

-- =========================================================================
-- TAB 2: HALLOWEEN EVENT (EXCLUSIVE EVENT AUTOMATION)
-- =========================================================================
TabHalloween:Section({ Title = "Combat & Rapid Candy Farming", Opened = true })

local HalloweenCombatStatusLabel = TabHalloween:Paragraph({
    Title = "Candy Farming Telemetry",
    Desc = "Monitoring mini monsters, strike range, and candy drops...",
})

TabHalloween:Toggle({
    Title = "Auto Farm Mini Monsters (Candy Farm)",
    Desc = "Automatically targets active monsters, navigates to striking range, and rapid-attacks until defeated",
    Value = State.AutoFarmMonsters,
    Callback = function(val)
        State.AutoFarmMonsters = val
    end,
})

TabHalloween:Toggle({
    Title = "Rapid Attack (Auto Bat Strike)",
    Desc = "Continuously swings Bat weapon whenever a monster or boss is within striking reach",
    Value = State.RapidAttack,
    Callback = function(val)
        State.RapidAttack = val
    end,
})

TabHalloween:Dropdown({
    Title = "Target Monster Type",
    Desc = "Select monster species to target or farm all active Halloween monsters",
    Values = MonsterDropdownList,
    Value = State.TargetMonsterType,
    Callback = function(val)
        State.TargetMonsterType = val
    end,
})

TabHalloween:Slider({
    Title = "Attack Cooldown (Seconds)",
    Desc = "Delay between bat attacks (Bat default hardware cooldown is 0.35s)",
    Value = {
        Min = 0.15,
        Max = 0.6,
        Default = State.AttackCooldown,
    },
    Callback = function(val)
        State.AttackCooldown = val
    end,
})

TabHalloween:Toggle({
    Title = "Auto Equip Bat Weapon",
    Desc = "Automatically equips Bat from backpack whenever combat is initiated",
    Value = State.AutoEquipBat,
    Callback = function(val)
        State.AutoEquipBat = val
    end,
})

TabHalloween:Section({ Title = "Event Overview & Status", Opened = true })

local HalloweenStatusLabel = TabHalloween:Paragraph({
    Title = "Halloween Event Status",
    Desc = "Monitoring Halloween Dimension data...",
})

TabHalloween:Toggle({
    Title = "Auto Collect Candy Everywhere",
    Desc = "Sweeps event candy drops across the map and magnetizes them directly to player",
    Value = State.AutoCollectCandy,
    Callback = function(val)
        State.AutoCollectCandy = val
    end,
})

TabHalloween:Toggle({
    Title = "Auto Buy Halloween Candy Egg (250 Candy)",
    Desc = "Automatically purchases the exclusive Halloween Dimension Egg whenever you reach 250 Candy",
    Value = State.AutoBuyHalloweenEgg,
    Callback = function(val)
        State.AutoBuyHalloweenEgg = val
    end,
})

TabHalloween:Section({ Title = "Halloween Shop & Actions", Opened = true })

TabHalloween:Button({
    Title = "Buy Halloween Egg Now (250 Candy)",
    Desc = "Invokes single purchase for Halloween Dimension Egg using current candy balance",
    Callback = function()
        pcall(function()
            local p = HalloweenShopService:BuyCandyEgg()
            if type(p) == "table" and type(p.await) == "function" then
                local ok, res = p:await()
                SafeNotify({
                    Title = "Halloween Shop",
                    Content = tostring(res or "Egg purchase requested."),
                    Duration = 2.5,
                    Icon = "ghost"
                })
            else
                SafeNotify({
                    Title = "Halloween Shop",
                    Content = "Purchase request dispatched.",
                    Duration = 2.5,
                    Icon = "ghost"
                })
            end
        end)
    end,
})

TabHalloween:Button({
    Title = "Open In-Game Halloween Event Panel",
    Desc = "Opens the native Halloween Dimension event rewards and chances menu",
    Callback = function()
        pcall(function()
            if PanelController and PanelController.TogglePanel then
                PanelController:TogglePanel("HalloweenEvent")
            end
        end)
    end,
})

TabHalloween:Section({ Title = "Halloween Dimension Fast Teleports", Opened = true })

TabHalloween:Button({
    Title = "Teleport to Halloween Lobby / SafeZone",
    Desc = "Instantly teleports character to the Halloween Dimension safe landing zone",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(2304.5, 75.0, 4514.0)
            SafeNotify({ Title = "Teleport Success", Content = "Arrived at Halloween Lobby", Duration = 2, Icon = "home" })
        end
    end,
})

TabHalloween:Button({
    Title = "Teleport to Pumpkin Abyss (Y=460)",
    Desc = "Teleports to the Pumpkin Abyss platform in Halloween Dimension",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(2159.5, 460.0, 4555.3)
            SafeNotify({ Title = "Teleport Success", Content = "Arrived at Pumpkin Abyss", Duration = 2, Icon = "map-pin" })
        end
    end,
})

TabHalloween:Button({
    Title = "Teleport to Bone Field (Y=1670)",
    Desc = "Teleports to the Bone Field platform in Halloween Dimension",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(2160.3, 1670.0, 4544.7)
            SafeNotify({ Title = "Teleport Success", Content = "Arrived at Bone Field", Duration = 2, Icon = "map-pin" })
        end
    end,
})

TabHalloween:Button({
    Title = "Teleport to Witches Castle (Y=3750)",
    Desc = "Teleports to the Witches Castle summit in Halloween Dimension",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(2096.7, 3755.0, 4550.8)
            SafeNotify({ Title = "Teleport Success", Content = "Arrived at Witches Castle", Duration = 2, Icon = "map-pin" })
        end
    end,
})

TabHalloween:Button({
    Title = "Teleport to Witch Boss Arena (SwampWitch)",
    Desc = "Teleports directly into the SwampWitch Boss battle arena",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(2072.9, 3770.0, 4589.0)
            SafeNotify({ Title = "Teleport Success", Content = "Arrived at Witch Boss Arena", Duration = 2, Icon = "skull" })
        end
    end,
})

-- =========================================================================
-- TAB 3: TREADMILL & SPEED
-- =========================================================================
TabTreadmill:Section({ Title = "Treadmill AFK Training", Opened = true })

local TreadmillStatusLabel = TabTreadmill:Paragraph({
    Title = "Treadmill Status",
    Desc = "Idle - Not currently mounted on treadmill.",
})

TabTreadmill:Toggle({
    Title = "Auto Train on Treadmill",
    Desc = "Positions and locks character onto your base treadmill for 100% uninterrupted AFK speed gain",
    Value = State.AutoTrainTreadmill,
    Callback = function(val)
        State.AutoTrainTreadmill = val
    end,
})

TabTreadmill:Toggle({
    Title = "Auto Boost Clicker (Instant 3x / 5x Multiplier)",
    Desc = "Instantly claims multiplier prompts with 0ms delay whenever the server triggers ShowMultiplier",
    Value = State.AutoBoostClicker,
    Callback = function(val)
        State.AutoBoostClicker = val
    end,
})

TabTreadmill:Section({ Title = "Treadmill Upgrades", Opened = true })

TabTreadmill:Toggle({
    Title = "Auto Upgrade Treadmill Tier",
    Desc = "Automatically purchases treadmill upgrades whenever sufficient Cash is available",
    Value = State.AutoUpgradeTreadmill,
    Callback = function(val)
        State.AutoUpgradeTreadmill = val
    end,
})

TabTreadmill:Button({
    Title = "Upgrade Treadmill Now",
    Desc = "Manually triggers a single treadmill tier upgrade request",
    Callback = function()
        pcall(function()
            TreadmillController:UpgradeTreadmill()
            SafeNotify({
                Title = "Treadmill Upgrade",
                Content = "Treadmill upgrade requested.",
                Duration = 2,
                Icon = "flame"
            })
        end)
    end,
})

-- =========================================================================
-- TAB 4: GUARDS & STEALTH
-- =========================================================================
TabGuards:Section({ Title = "Guard Neutralization System", Opened = true })

TabGuards:Paragraph({
    Title = "Stealth Overview",
    Desc = "5-layer defense: completely jails guards across all biomes, detours capture requests, nullifies punch velocity, and neutralizes character freeze.",
})

TabGuards:Toggle({
    Title = "Paralyze All Guards (Godmode Stealth)",
    Desc = "Completely neutralizes guard AI. Guards will never chase, punch, or jail you across all biomes",
    Value = State.ParalyzeGuards,
    Callback = function(val)
        State.ParalyzeGuards = val
        SafeNotify({
            Title = "Guard Paralyze",
            Content = val and "All guards are now paralyzed." or "Guards returned to normal AI.",
            Duration = 2,
            Icon = "shield"
        })
    end,
})

TabGuards:Toggle({
    Title = "Auto Capture / Knockout Nearby Guards",
    Desc = "Continuously relocates guard hitboxes away from player so they can never detect or contact you",
    Value = State.AutoCaptureGuards,
    Callback = function(val)
        State.AutoCaptureGuards = val
    end,
})

-- =========================================================================
-- TAB 5: BASE & UPGRADES
-- =========================================================================
TabBase:Section({ Title = "Plot & Player Progression", Opened = true })

TabBase:Toggle({
    Title = "Auto Upgrade Base Plot",
    Desc = "Automatically expands base plot size and capacity when required Cash is available",
    Value = State.AutoUpgradeBase,
    Callback = function(val)
        State.AutoUpgradeBase = val
    end,
})

TabBase:Toggle({
    Title = "Auto Upgrade Stamina",
    Desc = "Continuously purchases max stamina upgrades via StaminaUpgradeController",
    Value = State.AutoUpgradeStamina,
    Callback = function(val)
        State.AutoUpgradeStamina = val
    end,
})

TabBase:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths when your Speed meets the next rebirth requirement",
    Value = State.AutoRebirth,
    Callback = function(val)
        State.AutoRebirth = val
    end,
})

TabBase:Section({ Title = "Animal Mutation & Fusing", Opened = true })

TabBase:Button({
    Title = "Collect Ready Mutation",
    Desc = "Claims finished mutated animal from the MutateMachine",
    Callback = function()
        pcall(function()
            FuseController:call("Collect", "Failed to collect mutation")
            SafeNotify({
                Title = "Mutation",
                Content = "Collect request sent.",
                Duration = 2,
                Icon = "sparkles"
            })
        end)
    end,
})

TabBase:Button({
    Title = "Start Mutation Fusing",
    Desc = "Begins the animal fusing countdown in the MutateMachine",
    Callback = function()
        pcall(function()
            FuseController:call("Start", "Failed to start mutation")
            SafeNotify({
                Title = "Mutation",
                Content = "Start fusing request sent.",
                Duration = 2,
                Icon = "zap"
            })
        end)
    end,
})

-- =========================================================================
-- TAB 6: REWARDS & GIFTS
-- =========================================================================
TabRewards:Section({ Title = "Reward Telemetry & Controls", Opened = true })

local RewardsStatusLabel = TabRewards:Paragraph({
    Title = "Collection Status",
    Desc = "Monitoring daily calendar, playtime gifts 1-12, group chest, and index...",
})

TabRewards:Section({ Title = "Automated Reward Collection", Opened = true })

TabRewards:Toggle({
    Title = "Auto Claim Daily Rewards",
    Desc = "Regularly claims your unlocked daily login rewards calendar",
    Value = State.AutoDailyRewards,
    Callback = function(val)
        State.AutoDailyRewards = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Playtime Gifts (1 - 12)",
    Desc = "Sweeps all 12 playtime milestones and claims available rewards",
    Value = State.AutoPlaytimeGifts,
    Callback = function(val)
        State.AutoPlaytimeGifts = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Group Member Perks",
    Desc = "Claims the daily Roblox group reward chest bonus",
    Value = State.AutoGroupReward,
    Callback = function(val)
        State.AutoGroupReward = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim All Index Rewards",
    Desc = "Batch claims all animal collection index milestone rewards",
    Value = State.AutoClaimIndex,
    Callback = function(val)
        State.AutoClaimIndex = val
    end,
})

TabRewards:Button({
    Title = "Claim All Rewards Now",
    Desc = "Triggers a single manual sweep across all reward systems",
    Callback = function()
        pcall(function()
            DailyRewardsService:Claim()
            GroupRewardService:ClaimReward()
            IndexService:ClaimAll()
            for i = 1, 12 do
                GiftPlayTimeService:Claim(i)
            end
            SafeNotify({
                Title = "Rewards Claimed",
                Content = "All claimable reward remotes invoked.",
                Duration = 2.5,
                Icon = "check"
            })
        end)
    end,
})

-- =========================================================================
-- TAB 7: CLIMBING & BIOMES
-- =========================================================================
TabClimb:Section({ Title = "Biome Teleportation", Opened = true })

TabClimb:Dropdown({
    Title = "Select Destination Biome",
    Desc = "Choose a biome island to instantly teleport your character",
    Values = BiomeList,
    Value = State.SelectedBiome,
    Callback = function(val)
        State.SelectedBiome = val
    end,
})

TabClimb:Button({
    Title = "Teleport to Selected Biome",
    Desc = "Safely teleports character onto the central platform of the selected biome",
    Callback = function()
        local targetPos = BiomeLocations[State.SelectedBiome]
        if targetPos and HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(targetPos)
            SafeNotify({
                Title = "Teleport Success",
                Content = "Teleported to " .. State.SelectedBiome,
                Duration = 2,
                Icon = "map-pin"
            })
        end
    end,
})

TabClimb:Button({
    Title = "Teleport to Lobby / SafeZone",
    Desc = "Teleports character safely back to the lobby safe zone",
    Callback = function()
        local lobbyPos = BiomeLocations["Lobby / Base"]
        if lobbyPos and HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(lobbyPos)
            SafeNotify({
                Title = "Teleport Success",
                Content = "Teleported to Lobby SafeZone",
                Duration = 2,
                Icon = "home"
            })
        end
    end,
})

TabClimb:Button({
    Title = "Teleport to Personal Base Plot",
    Desc = "Teleports character directly onto your personal base plot",
    Callback = function()
        pcall(function()
            local tp = BaseController:GetTpCFrame()
            if tp and HumanoidRootPart then
                HumanoidRootPart.CFrame = tp + Vector3.new(0, 3, 0)
                SafeNotify({
                    Title = "Teleport Success",
                    Content = "Teleported to Personal Base Plot",
                    Duration = 2,
                    Icon = "home"
                })
            end
        end)
    end,
})

TabClimb:Section({ Title = "Ascension & Climbing Assistance", Opened = true })

TabClimb:Toggle({
    Title = "Auto Ascend / High-Speed Climb",
    Desc = "Smoothly propels your character upward along the climb tower using LinearVelocity physics",
    Value = State.AutoClimbAscend,
    Callback = function(val)
        State.AutoClimbAscend = val
    end,
})

TabClimb:Slider({
    Title = "Ascend Climb Speed",
    Desc = "Adjust the vertical climbing speed in studs per second",
    Value = {
        Min = 20,
        Max = 250,
        Default = State.ClimbAscendSpeed,
    },
    Callback = function(val)
        State.ClimbAscendSpeed = val
    end,
})

TabClimb:Toggle({
    Title = "Anti-Void Fall Protection",
    Desc = "Catches character if falling below Y=35 and safely returns them to the last safe platform",
    Value = State.AntiVoidFall,
    Callback = function(val)
        State.AntiVoidFall = val
    end,
})

-- =========================================================================
-- TAB 8: MOVEMENT & PHYSICS
-- =========================================================================
TabMovement:Section({ Title = "Character Attributes", Opened = true })

TabMovement:Slider({
    Title = "WalkSpeed",
    Desc = "Adjust player movement speed",
    Value = {
        Min = 16,
        Max = 200,
        Default = State.WalkSpeed,
    },
    Callback = function(val)
        State.WalkSpeed = val
        if Humanoid then Humanoid.WalkSpeed = val end
    end,
})

TabMovement:Slider({
    Title = "JumpPower",
    Desc = "Adjust player jump power",
    Value = {
        Min = 50,
        Max = 250,
        Default = State.JumpPower,
    },
    Callback = function(val)
        State.JumpPower = val
        if Humanoid then Humanoid.JumpPower = val end
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in mid-air",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Walk through obstacles, invisible walls, and barriers",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

-- Infinite Jump Hook
RegisterConnection(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- Noclip Hook
RegisterConnection(RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

TabMovement:Section({ Title = "Session & AFK Protection", Opened = true })

TabMovement:Toggle({
    Title = "Anti-AFK / Anti-Idle",
    Desc = "Prevents Roblox 20-minute idle disconnect so you can AFK train or farm continuously",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
        SafeNotify({
            Title = "Anti-AFK",
            Content = val and "Anti-AFK protection enabled." or "Anti-AFK disabled.",
            Duration = 2,
            Icon = "shield-check"
        })
    end,
})

-- Anti-AFK / Anti-Idle Engine (VirtualUser Event + 4-minute keepalive pulse)
local VirtualUser = game:GetService("VirtualUser")
RegisterConnection(LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end))

RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end
        task.wait(240)
    end
end))

-- =========================================================================
-- TAB 9: CONFIGURATION
-- =========================================================================
TabConfig:Section({ Title = "Config Profile & Storage", Opened = true })

local ConfigFilePath = "ClimbForAnimalsEggs_Config.json"

TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Saves active toggles, sliders, and preferences to local JSON",
    Callback = function()
        pcall(function()
            local serialized = HttpService:JSONEncode(State)
            if writefile then
                writefile(ConfigFilePath, serialized)
                SafeNotify({
                    Title = "Config Saved",
                    Content = "Configuration saved to " .. ConfigFilePath,
                    Duration = 2.5,
                    Icon = "check"
                })
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Loads saved preferences from local JSON",
    Callback = function()
        pcall(function()
            if readfile and isfile and isfile(ConfigFilePath) then
                local data = HttpService:JSONDecode(readfile(ConfigFilePath))
                for k, v in pairs(data) do
                    if State[k] ~= nil then
                        State[k] = v
                    end
                end
                SafeNotify({
                    Title = "Config Loaded",
                    Content = "Configuration applied successfully.",
                    Duration = 2.5,
                    Icon = "upload"
                })
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Reset to Defaults (ALL OFF)",
    Desc = "Turns all automation toggles OFF and restores standard values",
    Callback = function()
        for k, v in pairs(State) do
            if type(v) == "boolean" then
                State[k] = false
            end
        end
        if Humanoid then
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end
        SafeNotify({
            Title = "Defaults Restored",
            Content = "All automation toggles turned OFF.",
            Duration = 2.5,
            Icon = "rotate-ccw"
        })
    end,
})

TabConfig:Button({
    Title = "Unload Script Cleanly",
    Desc = "Safely cancels all threads, unhooks connections, and destroys UI",
    Callback = function()
        if getgenv()._CLIMB_EGGS_UNLOAD then
            getgenv()._CLIMB_EGGS_UNLOAD()
        end
    end,
})

-- =========================================================================
-- WORKER 1: AUTO HATCH PLACED EGGS (GAMEPASS BYPASS & TIME CHECK)
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            if State.AutoHatchPlaced then
                local placed = DataController:GetValue("PlacedEggs")
                if placed and typeof(placed) == "table" then
                    local now = workspace:GetServerTimeNow()
                    local readyCount = 0
                    for eggId, data in pairs(placed) do
                        if typeof(data) == "table" then
                            local isReady = data.CanHatch or (data.HatchDate and now >= data.HatchDate)
                            if isReady then
                                readyCount = readyCount + 1
                                if not EggHatchController.Pending[eggId] then
                                    EggHatchController:Hatch(eggId)
                                end
                            end
                        end
                    end
                    if EggStatusLabel then
                        EggStatusLabel:SetDesc("Monitoring base eggs. Ready to hatch: " .. readyCount)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end))

-- =========================================================================
-- WORKER 2: AUTO STEAL & DELIVER EGGS (ANTI-DETECTION CLIMB & PROMPT ENGINE)
-- =========================================================================
local StealBusy = false

-- Anti-Detection Transit with legitimate Humanoid Climbing State & ClimbZone tracking
local function ClimbTransit(targetCFrame, speed, isClimbingShaft)
    if not HumanoidRootPart then return false end
    local startCFrame = HumanoidRootPart.CFrame
    local startPos = startCFrame.Position
    local targetPos = targetCFrame.Position
    local dist = (targetPos - startPos).Magnitude
    if dist < 2 then
        HumanoidRootPart.CFrame = targetCFrame
        return true
    end

    local transitSpeed = math.max(speed or 120, 60)
    local duration = math.clamp(dist / transitSpeed, 0.1, 15)
    local steps = math.max(math.floor(duration / 0.04), 4)
    local dt = duration / steps

    for i = 1, steps do
        if not getgenv()._CLIMB_EGGS_RUNNING or not State.AutoStealEggs then
            return false
        end
        if isClimbingShaft and Humanoid then
            pcall(function()
                Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            end)
        end
        local alpha = i / steps
        HumanoidRootPart.CFrame = startCFrame:Lerp(targetCFrame, alpha)
        task.wait(dt)
    end
    HumanoidRootPart.CFrame = targetCFrame
    return true
end

RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        if State.AutoStealEggs and HumanoidRootPart and not StealBusy then
            StealBusy = true
            pcall(function()
                local isCarrying = LocalPlayer:GetAttribute("CarryingEgg") ~= nil

                if isCarrying then
                    -- =========================================================
                    -- PHASE: DELIVER CARRIED EGG TO SAFEZONE
                    -- =========================================================
                    if StealStatusLabel then
                        StealStatusLabel:SetDesc("Carrying egg! Safely descending to SafeZone...")
                    end

                    local inHalloween = false
                    pcall(function()
                        inHalloween = ZoneController:IsInHalloweenDimension(HumanoidRootPart.Position)
                    end)

                    local safeTarget
                    if inHalloween then
                        safeTarget = CFrame.new(2304.5, 75, 4514.0)
                    else
                        local safeZone = workspace:FindFirstChild("SafeZone")
                        safeTarget = safeZone and (safeZone.CFrame + Vector3.new(0, 3, 0)) or CFrame.new(2229.6, 73, -751.5)
                    end

                    -- Descend at natural freefall rate into SafeZone
                    ClimbTransit(safeTarget, 240, false)
                    task.wait(0.4)

                    if EggCarryController and EggCarryController.tryClaimEgg then
                        EggCarryController:tryClaimEgg()
                    end
                    task.wait(0.5)

                    if StealStatusLabel then
                        StealStatusLabel:SetDesc("Egg claimed into base inventory.")
                    end
                else
                    -- =========================================================
                    -- PHASE: LOCATE AND ACQUIRE TARGET EGG
                    -- =========================================================
                    local se = workspace:FindFirstChild("SpawnedEggs")
                    if se then
                        local targetEgg = nil
                        local targetDist = math.huge
                        local targetPrompt = nil

                        local folders = {}
                        if State.TargetStealBiome == "Closest" then
                            folders = se:GetChildren()
                        else
                            local f = se:FindFirstChild(State.TargetStealBiome)
                            if f then table.insert(folders, f) end
                        end

                        -- Scan all eligible eggs with enabled ProximityPrompts
                        for _, folder in ipairs(folders) do
                            for _, egg in ipairs(folder:GetChildren()) do
                                local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                                local pp = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart") or egg:FindFirstChild("Hitbox")
                                if prompt and pp and prompt.Enabled then
                                    local dist = (pp.Position - HumanoidRootPart.Position).Magnitude
                                    if dist < targetDist then
                                        targetDist = dist
                                        targetEgg = egg
                                        targetPrompt = prompt
                                    end
                                end
                            end
                        end

                        if targetEgg and targetPrompt then
                            local eggPart = targetEgg.PrimaryPart or targetEgg:FindFirstChildWhichIsA("BasePart") or targetEgg:FindFirstChild("Hitbox")
                            local eggPos = eggPart.Position
                            local inHalloween = eggPos.Z > 2000

                            if StealStatusLabel then
                                StealStatusLabel:SetDesc("Target: " .. targetEgg.Name .. " (" .. (targetEgg.Parent and targetEgg.Parent.Name or "World") .. ") - Ascending...")
                            end

                            local startY = HumanoidRootPart.Position.Y
                            local targetY = eggPos.Y
                            
                            -- Accurate ClimbZone centers to strictly satisfy ZoneController.IsInClimbZone
                            -- Normal Shaft center: X=2212.15, Z=-749.58 (StartCFrame)
                            -- Halloween Shaft center: X=2210.17, Z=4553.02 (DimensionLadderStart)
                            local shaftX = inHalloween and 2210.17 or 2212.15
                            local shaftZ = inHalloween and 4553.02 or -749.58

                            -- Climb up along central climb zone with Humanoid Climbing state
                            if targetY > startY + 25 then
                                ClimbTransit(CFrame.new(shaftX, startY, shaftZ), 140, true)
                                ClimbTransit(CFrame.new(shaftX, targetY, shaftZ), 160, true)
                            end

                            -- Approach egg platform smoothly and stand on platform floor
                            local approachTarget = CFrame.new(eggPos.X + 1.5, eggPos.Y + 1.2, eggPos.Z + 1.5)
                            ClimbTransit(approachTarget, 100, false)
                            task.wait(0.3)

                            if StealStatusLabel then
                                StealStatusLabel:SetDesc("Interacting with " .. targetEgg.Name .. " prompt...")
                            end

                            -- Hold ProximityPrompt legitimately for full duration to avoid server instant-fire anti-cheat check
                            local holdTime = (targetPrompt.HoldDuration and targetPrompt.HoldDuration > 0) and targetPrompt.HoldDuration or 0.5
                            targetPrompt:InputHoldBegin()
                            task.wait(holdTime + 0.15)
                            targetPrompt:InputHoldEnd()

                            task.wait(0.5)
                            local grabbed = LocalPlayer:GetAttribute("CarryingEgg") ~= nil

                            if grabbed then
                                if StealStatusLabel then
                                    StealStatusLabel:SetDesc("Egg secured! Returning to SafeZone...")
                                end

                                local safeTarget
                                if inHalloween then
                                    safeTarget = CFrame.new(2304.5, 75, 4514.0)
                                else
                                    local safeZone = workspace:FindFirstChild("SafeZone")
                                    safeTarget = safeZone and (safeZone.CFrame + Vector3.new(0, 3, 0)) or CFrame.new(2229.6, 73, -751.5)
                                end

                                ClimbTransit(safeTarget, 240, false)
                                task.wait(0.4)

                                if EggCarryController and EggCarryController.tryClaimEgg then
                                    EggCarryController:tryClaimEgg()
                                end
                                task.wait(0.5)

                                if StealStatusLabel then
                                    StealStatusLabel:SetDesc("Delivered " .. targetEgg.Name .. " egg successfully!")
                                end
                            else
                                if StealStatusLabel then
                                    StealStatusLabel:SetDesc("Prompt wait completed. Retrying sweep...")
                                end
                            end
                        else
                            if StealStatusLabel then
                                StealStatusLabel:SetDesc("No eligible eggs found. Waiting for restock...")
                            end
                        end
                    end
                end
            end)
            StealBusy = false
        else
            if not State.AutoStealEggs and StealStatusLabel and StealStatusLabel.Desc ~= "Idle - Automation OFF" then
                StealStatusLabel:SetDesc("Idle - Automation OFF")
            end
        end
        task.wait(0.3)
    end
end))

-- =========================================================================
-- WORKER 3: TREADMILL AFK TRAIN & AUTO MULTIPLIER CLICKER
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            -- Treadmill Auto Mount
            if State.AutoTrainTreadmill then
                if not TreadmillController.OnTreadmill then
                    local ownTm = TreadmillController.OwnTreadmill
                    if ownTm and ownTm.PrimaryPart and HumanoidRootPart then
                        HumanoidRootPart.CFrame = ownTm.PrimaryPart.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.2)
                        TreadmillController:ActivateTreadmill(ownTm)
                    end
                end
                if TreadmillStatusLabel then
                    TreadmillStatusLabel:SetDesc("Active - Training on base treadmill (" .. (TreadmillController.OnTreadmill and "Running" or "Mounting") .. ")")
                end
            else
                if TreadmillStatusLabel then
                    TreadmillStatusLabel:SetDesc("Idle - Not currently mounted on treadmill.")
                end
            end

            -- Auto Boost Clicker UI Sweep & Clean Dismissal
            if State.AutoBoostClicker then
                local generalGui = LocalPlayer.PlayerGui:FindFirstChild("General")
                if generalGui then
                    for _, c in ipairs(generalGui:GetChildren()) do
                        if c.Name ~= "BonusClick" then
                            local btn = c:FindFirstChildOfClass("ImageButton")
                            if btn and btn:GetAttribute("Action") == "ClaimTmMultiplier" then
                                local id = btn:GetAttribute("Id")
                                if id then
                                    ProcessClaimMultiplier(id)
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end))

-- =========================================================================
-- WORKER 4: GUARD ISOLATION & CAPTURE SYSTEM
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            if State.ParalyzeGuards or State.AutoCaptureGuards or State.AutoStealEggs then
                -- Ensure guards exist in GuardController table
                if GuardController.syncGuards then
                    GuardController:syncGuards()
                end

                for id, guard in pairs(GuardController.Guards) do
                    if guard.Model and guard.Model.Parent then
                        guard.Jailed = true

                        -- Neutralize hitboxes
                        if guard.Hitbox and guard.Hitbox:IsA("BasePart") then
                            guard.Hitbox.CanTouch = false
                            guard.Hitbox.CanCollide = false
                            guard.Hitbox.CanQuery = false
                        end

                        -- Physical isolation for AutoCaptureGuards: relocate model away
                        if State.AutoCaptureGuards and guard.Model.PrimaryPart then
                            guard.Model:PivotTo(CFrame.new(guard.Model.PrimaryPart.Position.X, -500, guard.Model.PrimaryPart.Position.Z))
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end))

-- =========================================================================
-- WORKER 5: AUTO UPGRADES (TREADMILL, BASE PLOT, STAMINA)
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            if State.AutoUpgradeTreadmill then
                TreadmillController:UpgradeTreadmill()
            end
        end)
        task.wait(1.5)

        pcall(function()
            if State.AutoUpgradeBase then
                BaseUpgradeService:RequestToUpgrade()
            end
        end)
        task.wait(1.5)

        pcall(function()
            if State.AutoUpgradeStamina then
                StaminaUpgradeController:Purchase()
            end
        end)
        task.wait(1.5)
    end
end))

-- =========================================================================
-- WORKER 6: AUTO REBIRTH
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            if State.AutoRebirth then
                local currentRebirths = DataController:GetValue("Rebirths") or 0
                local currentSpeed = DataController:GetValue("Speed") or 0
                local req = rebirthConfig.GetRequirements(currentRebirths + 1)
                if req and req.Speed and currentSpeed >= req.Speed then
                    RebirthController:Request()
                end
            end
        end)
        task.wait(3.0)
    end
end))

-- =========================================================================
-- WORKER 7: AUTO REWARDS COLLECTOR
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        if State.AutoDailyRewards then
            pcall(function()
                local p = DailyRewardsService:Claim()
                if p and p.await then p:await() end
                if RewardsStatusLabel then
                    RewardsStatusLabel:SetDesc("Daily calendar reward claimed.")
                end
            end)
        end
        task.wait(1.5)

        if State.AutoPlaytimeGifts then
            pcall(function()
                local claimedGifts = 0
                for i = 1, 12 do
                    local p = GiftPlayTimeService:Claim(i)
                    if p and p.await then p:await() end
                    claimedGifts = claimedGifts + 1
                end
                if RewardsStatusLabel then
                    RewardsStatusLabel:SetDesc("Swept playtime gifts 1-12.")
                end
            end)
        end
        task.wait(1.5)

        if State.AutoGroupReward then
            pcall(function()
                local p = GroupRewardService:ClaimReward()
                if p and p.await then p:await() end
                if RewardsStatusLabel then
                    RewardsStatusLabel:SetDesc("Group member reward chest claimed.")
                end
            end)
        end
        task.wait(1.5)

        if State.AutoClaimIndex then
            pcall(function()
                local p = IndexService:ClaimAll()
                if p and p.await then p:await() end
                if RewardsStatusLabel then
                    RewardsStatusLabel:SetDesc("All animal index milestones claimed.")
                end
            end)
        end
        task.wait(2.0)
    end
end))

-- =========================================================================
-- WORKER 8: AUTO CLIMB / ASCEND & ANTI-VOID
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            if HumanoidRootPart then
                -- Ascend physics
                if State.AutoClimbAscend then
                    local att = HumanoidRootPart:FindFirstChild("OP_ClimbAttachment")
                    if not att then
                        att = Instance.new("Attachment")
                        att.Name = "OP_ClimbAttachment"
                        att.Parent = HumanoidRootPart
                    end

                    local lv = HumanoidRootPart:FindFirstChild("OP_ClimbLinearVelocity")
                    if not lv then
                        lv = Instance.new("LinearVelocity")
                        lv.Name = "OP_ClimbLinearVelocity"
                        lv.Attachment0 = att
                        lv.RelativeTo = Enum.ActuatorRelativeTo.World
                        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                        lv.ForceLimitsEnabled = false
                        lv.Parent = HumanoidRootPart
                    end
                    lv.VectorVelocity = Vector3.new(0, State.ClimbAscendSpeed, 0)
                else
                    local lv = HumanoidRootPart:FindFirstChild("OP_ClimbLinearVelocity")
                    if lv then pcall(lv.Destroy, lv) end
                    local att = HumanoidRootPart:FindFirstChild("OP_ClimbAttachment")
                    if att then pcall(att.Destroy, att) end
                end

                -- Anti-void protection
                if State.AntiVoidFall and HumanoidRootPart.Position.Y < 35 then
                    local lobbyPos = BiomeLocations["Lobby / Base"]
                    if lobbyPos then
                        HumanoidRootPart.CFrame = CFrame.new(lobbyPos)
                        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end))

-- =========================================================================
-- WORKER 9: HALLOWEEN AUTOMATION (CANDY COLLECT & AUTO EGG PURCHASE)
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            -- Update Halloween live status label
            if HalloweenStatusLabel then
                local candy = DataController:GetValue("Candy") or 0
                local hd = workspace:FindFirstChild("HalloweenDimension")
                local witchAlive = hd and hd:GetAttribute("WitchAlive")
                local inH = false
                if HumanoidRootPart and ZoneController then
                    inH = ZoneController:IsInHalloweenDimension(HumanoidRootPart.Position)
                end
                HalloweenStatusLabel:SetDesc(string.format(
                    "Candy: %s ð¬ | Witch Boss: %s | Location: %s",
                    tostring(candy),
                    witchAlive and "ALIVE âï¸" or "Cooldown",
                    inH and "Halloween Dimension" or "Main Lobby"
                ))
            end

            -- Auto Buy Halloween Candy Egg (250 Candy)
            if State.AutoBuyHalloweenEgg then
                local candy = DataController:GetValue("Candy") or 0
                if candy >= 250 then
                    local p = HalloweenShopService:BuyCandyEgg()
                    if type(p) == "table" and type(p.await) == "function" then
                        p:await()
                    end
                    task.wait(1.5)
                end
            end

            -- Auto Collect / Vacuum Candy Drops
            if State.AutoCollectCandy then
                local cd = workspace:FindFirstChild("CandyDrops")
                if cd and HumanoidRootPart then
                    for _, candy in ipairs(cd:GetChildren()) do
                        if candy:IsA("BasePart") then
                            candy.CFrame = HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end)
        task.wait(0.4)
    end
end))

-- Initial Startup Notification
SafeNotify({
    Title = "Climb For Animals Eggs",
    Content = "Automation Suite Loaded. Press LeftControl to toggle.",
    Duration = 3.5,
    Icon = "egg"
})

-- =========================================================================
-- WORKER 10: HALLOWEEN RAPID COMBAT & AUTO MONSTER FARM ENGINE
-- =========================================================================
RegisterTask(task.spawn(function()
    local candyDropsMod = nil
    pcall(function()
        candyDropsMod = require(LocalPlayer.PlayerScripts.src.controllers.miniMonsterController.CandyDrops)
    end)

    while getgenv()._CLIMB_EGGS_RUNNING do
        pcall(function()
            if State.AutoFarmMonsters or State.RapidAttack then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp or hum.Health <= 0 then
                    return
                end

                -- Auto-equip Bat weapon
                local bat = char:FindFirstChild("Bat")
                if not bat and (State.AutoEquipBat or State.AutoFarmMonsters or State.RapidAttack) then
                    bat = LocalPlayer.Backpack:FindFirstChild("Bat")
                    if bat then
                        hum:EquipTool(bat)
                        task.wait(0.12)
                    end
                end

                local hd = workspace:FindFirstChild("HalloweenDimension")
                local amm = hd and hd:FindFirstChild("ActiveMiniMonsters")
                if not amm then return end

                local selectedFilter = MonsterNameLookup[State.TargetMonsterType] or "All"

                -- Find closest eligible monster
                local targetMonster = nil
                local targetDist = math.huge

                for _, monster in ipairs(amm:GetChildren()) do
                    if monster:IsA("Model") then
                        local hp = monster:GetAttribute("Health")
                        if hp and hp > 0 then
                            local matches = (selectedFilter == "All") or (monster.Name == selectedFilter)
                            if matches then
                                local pp = monster.PrimaryPart or monster:FindFirstChildWhichIsA("BasePart")
                                if pp then
                                    local dist = (pp.Position - hrp.Position).Magnitude
                                    if dist < targetDist then
                                        targetDist = dist
                                        targetMonster = monster
                                    end
                                end
                            end
                        end
                    end
                end

                if targetMonster then
                    local pp = targetMonster.PrimaryPart or targetMonster:FindFirstChildWhichIsA("BasePart")
                    local targetPos = pp.Position
                    local currentHP = targetMonster:GetAttribute("Health") or 0
                    local maxHP = targetMonster:GetAttribute("MaxHealth") or 0

                    if HalloweenCombatStatusLabel then
                        HalloweenCombatStatusLabel:SetDesc(string.format(
                            "Target: %s | HP: %d/%d | Dist: %d studs | Combat: Active",
                            targetMonster.Name, currentHP, maxHP, math.floor(targetDist)
                        ))
                    end

                    -- If AutoFarmMonsters is enabled, navigate safely to striking range
                    if State.AutoFarmMonsters then
                        if targetDist > 8 then
                            -- Stand 4 studs in front of monster looking at it
                            local attackCFrame = CFrame.new(targetPos + Vector3.new(0, 1.2, 3.8), targetPos)
                            hrp.CFrame = attackCFrame
                            task.wait(0.15)
                        end
                    end

                    -- Strike target if in reach (within 16 studs)
                    local newDist = (pp.Position - hrp.Position).Magnitude
                    if newDist <= 16 and bat and bat.Parent == char then
                        bat:Activate()
                        task.wait(State.AttackCooldown or 0.35)
                    end

                    -- Immediate Candy vacuum sweep
                    local cd = workspace:FindFirstChild("CandyDrops")
                    if cd then
                        for _, drop in ipairs(cd:GetChildren()) do
                            if drop:IsA("BasePart") then
                                drop.CFrame = hrp.CFrame
                            end
                        end
                    end
                else
                    if HalloweenCombatStatusLabel and HalloweenCombatStatusLabel.Desc ~= "Idle - No target monsters active." then
                        HalloweenCombatStatusLabel:SetDesc("Idle - No target monsters active.")
                    end
                end
            else
                if HalloweenCombatStatusLabel and HalloweenCombatStatusLabel.Desc ~= "Idle - Combat Automation OFF." then
                    HalloweenCombatStatusLabel:SetDesc("Idle - Combat Automation OFF.")
                end
            end
        end)
        task.wait(0.08)
    end
end))
