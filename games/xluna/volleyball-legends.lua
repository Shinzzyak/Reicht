-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- ==============================================================================
-- FLa ProjecT: Volleyball Legends ClientOP & Tactical Automation Engine
-- Version: v3.0 [Pro Master Edition - Predictive Apex Spike & Match Auto-Serve]
-- Framework: WindUI Engine (Multi-Language: English & Bahasa Indonesia)
-- Author: FLa ProjecT
-- Target Game: [UPD] Volleyball Legends (PlaceId: 74691681039273)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==============================================================================
-- 0. SINGLE-INSTANCE GUARD & CLEAN MUTEX HANDLER
-- ==============================================================================
local genv = getgenv and getgenv() or _G
if genv.__VOLLEYBALL_OP and genv.__VOLLEYBALL_OP.Stop then
    pcall(genv.__VOLLEYBALL_OP.Stop)
end

-- Safe GUI Root Container (Resolves CoreGui Plugin Capability Error)
local function getSafeGuiRoot()
    local ok, res = pcall(function()
        if gethui then return gethui() end
        if LP and LP:FindFirstChild("PlayerGui") then return LP.PlayerGui end
        return game:GetService("CoreGui")
    end)
    return ok and res or LP:WaitForChild("PlayerGui")
end

-- Cleanup prior GUI & HUD instances across all possible containers
pcall(function()
    local containers = {}
    if gethui then table.insert(containers, gethui()) end
    if LP and LP:FindFirstChild("PlayerGui") then table.insert(containers, LP.PlayerGui) end
    pcall(function() table.insert(containers, game:GetService("CoreGui")) end)

    for _, container in ipairs(containers) do
        pcall(function()
            for _, c in ipairs(container:GetChildren()) do
                if c.Name == "VolleyballLegends_FloatingBtn" or c.Name == "VolleyballLegends_HUD" or c.Name:find("VolleyballLegends") then
                    pcall(function() c:Destroy() end)
                end
            end
        end)
    end
end)

-- Safe Notification Helper
local isLoadingConfig = false
local function notify(title, message, duration)
    if isLoadingConfig then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Volleyball Legends OP",
            Text = message or "",
            Duration = duration or 3
        })
    end)
end

-- ==============================================================================
-- 1. KNIT FRAMEWORK & CONTROLLER RESOLUTION
-- ==============================================================================
local Knit = nil
local okKnit, resKnit = pcall(function() return require(ReplicatedStorage.Packages.Knit) end)
if okKnit and resKnit then
    Knit = resKnit
else
    local knitModule = ReplicatedStorage:FindFirstChild("Knit", true)
    if knitModule then Knit = require(knitModule) end
end

if not Knit then
    notify("Error", "Could not locate Knit framework. Script stopped.", 5)
    return
end

local function getService(serviceName)
    local ok, s = pcall(function() return Knit.GetService(serviceName) end)
    return ok and s or nil
end

local function getController(controllerName)
    local ok, c = pcall(function() return Knit.GetController(controllerName) end)
    return ok and c or nil
end

local BallService = getService("BallService")
local GameService = getService("GameService")
local BotService = getService("BotService")
local QuestService = getService("QuestService")
local ChallengeService = getService("ChallengeService")
local LevelService = getService("LevelService")
local MasteryService = getService("MasteryService")
local SeasonService = getService("SeasonService")
local DailyRewardService = getService("DailyRewardService")
local InventoryService = getService("InventoryService")
local CodeService = getService("CodeService")
local AbilityService = getService("AbilityService")
local StyleService = getService("StyleService")
local CrateService = getService("CrateService")
local PackService = getService("PackService")

local GameController = getController("GameController")
local BallController = getController("BallController")
local AbilityController = getController("AbilityController")
local StyleController = getController("StyleController")

-- Official Internal Mechanics Modules
local Handlers = nil
local TossModule = nil
local StateModule = nil
pcall(function()
    Handlers = require(game:GetService("ReplicatedFirst").Controllers.GameController.Handlers)
    TossModule = require(game:GetService("ReplicatedFirst").Controllers.GameController.Actions.Binding.Registry.Toss)
    StateModule = require(ReplicatedStorage.Common.State)
end)

-- Complete Controller & Physical Recovery (Destroys Dive Locks, Restores Upright Posture)
local function unfreezeController()
    pcall(function()
        local char = LP and LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        -- 1. Reset Game Controller States
        if Handlers and Handlers.States then
            if Handlers.States.IsBusy then Handlers.States.IsBusy:set(false) end
            if Handlers.States.IsDiving then Handlers.States.IsDiving:set(false) end
            if Handlers.States.IsStunned then Handlers.States.IsStunned:set(false) end
        end

        -- 2. Destroy any lingering physics constraints from Dive/Knockback
        if root then
            for _, item in ipairs(root:GetChildren()) do
                if item:IsA("LinearVelocity") or item:IsA("AlignOrientation") or item:IsA("BodyVelocity") or item:IsA("BodyGyro") then
                    item:Destroy()
                end
            end
        end

        -- 3. Restore Humanoid physical state and posture
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            if hum.WalkSpeed < 16 then
                hum.WalkSpeed = 16
            end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
end

-- ==============================================================================
-- 2. STATE & CONFIGURATION STORAGE
-- ==============================================================================
local S = {
    -- Super OP Defense & Net Block Suite
    AutoNetBlock = true,        -- Automatically teleports to the net, leaps into the air, and blocks opponent spikes!
    BlockReachDistance = 14.0,  -- Max distance from net to trigger auto-block

    -- Super OP Teleport & Auto-Spike Suite
    AutoTPSpike = true,         -- Instantly teleports mid-air directly behind high balls, jumps, and smashes at opponent court!
    AutoTPReceive = false,      -- Instantly teleports to ball landing zone to receive low balls / incoming serves cleanly
    AlwaysFaceOpponent = true,  -- Automatically locks character facing towards opponent court before every hit (ZERO out of bounds!)
    
    -- Predictive Apex Spike Engine
    AutoSpikeApex = true,       -- Automatically jumps and spikes high sets at peak apex
    AutoSpikeAirborne = true,   -- Instantly spikes if player jumps manually near ball
    SpikeHitRadius = 14.0,      -- Max distance to trigger spike hit (server max 20 studs)
    SpikeLeadTime = 0.32,       -- Pre-jump timing offset before ball drops into spike reach
    ForceMaxPower = true,       -- Forces 100% TRUE MAX POWER on all hits, tosses, and serves
    AutoAimOpponent = true,     -- Directs smashes towards opponent open back court

    -- Match Ground Defense (Bump & Dive)
    AutoBump = true,            -- Receives falling balls cleanly
    AutoDive = false,           -- Slides to save balls out of normal bump reach (Disabled by default to prevent floor lock)
    VerticalBumpReach = 7.5,    -- Max height above player to trigger ground bump (prevents phantom swings)
    GroundHitRadius = 12.0,     -- Ground receive horizontal distance
    StrictSideCheck = true,     -- Only hits balls on player's side of the net

    -- Intelligent Match Auto-Serve (100% TRUE MAX POWER)
    AutoServeMatch = true,      -- Detects when it's your turn to serve in matches and executes automatic 100% power ace
    AutoServeDelay = 0.45,      -- Realistic human delay before tossing (seconds)
    AutoServeAce = true,        -- Automatically teleports to apex and spikes the toss for an unstoppable ace

    -- Anti-Penalty & Fair Play Rules (Strict 1x Hit Limit)
    AntiDoubleHitGuard = true,  -- Strictly prevents hitting the ball twice consecutively (Zero penalties / double touch faults)
    MinHitCooldown = 0.55,      -- Minimum cooldown between consecutive touches (seconds)

    -- Court & Magnet Assist
    AutoBallMagnet = false,     -- Automatically walks to ball landing zone (only active when TP-Spike is OFF)
    MagnetMode = "Assist",      -- "Assist" (only walks when NOT pressing WASD) or "Force"
    StayOnSide = true,          -- Net boundary guard (never crosses net)
    IgnoreOutBalls = true,      -- Never chases balls landing out of bounds (free points)

    -- Practice Arena Tools
    LoopSpawnBall = false,
    LoopSpawnServe = false,
    PracticeSpawnDelay = 3.0,
    BotDifficulty = "Normal",

    -- Tactical HUD & Visuals
    TacticalHUD = true,         -- Real-time on-screen telemetry banner
    BallHighlight = true,       -- 3D Cham Highlight around active ball
    BallTrajectoryTracer = true,-- 3D Beam connecting ball to ground landing spot
    LandingCircleESP = true,    -- 3D Cylinder on landing zone (Blue = Our side, Orange = Opponent)

    -- Progression Auto-Farm
    AutoClaimQuests = false,
    AutoClaimLevelRewards = false,
    AutoClaimMastery = false,
    AutoClaimDailyPresents = false,
    AutoClaimDailyReward = false,
    AutoSellDuplicates = false,
    FarmLoopInterval = 5,

    -- Gacha Auto-Roll
    AutoRollStyle = false,
    LuckyStyle = false,
    StopOnStyleName = "None",
    LockStyleOnHit = true,

    AutoRollAbility = false,
    LuckyAbility = false,
    StopOnAbilityName = "None",
    LockAbilityOnHit = true,

    SelectedCrate = "EternalCrate",
    CrateOpenAmount = 1,
    AutoOpenCrates = false,

    SelectedPack = "Basic",
    AutoOpenPacks = false,

    -- Player & Physics
    CustomSpeed = false,
    WalkSpeed = 42,
    CustomJump = false,
    JumpPower = 90,
    InfiniteJump = false,
    AirWalkFloat = false,
    FloatHeight = 15,
    NoClip = false,
    AntiAFK = true
}

local UI_ELEMENTS = {}

-- Config Persistence
local CONFIG_FOLDER = "VolleyballLegendsConfig"
local CONFIG_FILE = CONFIG_FOLDER .. "/ClientOP_Config.json"

local function ensureFolder()
    pcall(function()
        if makefolder and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
end

local function saveConfig()
    pcall(function()
        ensureFolder()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(S))
            notify("Config Saved", "Preferences written to " .. CONFIG_FILE, 3)
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) and readfile then
            local raw = readfile(CONFIG_FILE)
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                isLoadingConfig = true
                for k, v in pairs(data) do
                    if S[k] ~= nil then S[k] = v end
                    local widget = UI_ELEMENTS[k]
                    if widget then
                        pcall(function()
                            local wType = widget.__type or widget.Type
                            if wType == "Toggle" then widget:Set(v == true)
                            elseif wType == "Slider" then
                                local num = tonumber(v)
                                if num then widget:Set(num) end
                            elseif wType == "Dropdown" then widget:Select(tostring(v))
                            end
                        end)
                    end
                end
                isLoadingConfig = false
                notify("Config Loaded", "Preferences restored from " .. CONFIG_FILE, 3)
            end
        end
    end)
end

-- ==============================================================================
-- 3. AUDITED STATIC LISTS
-- ==============================================================================
local ALL_STYLES = {
    "None", "Asahi", "Daichi", "Encho", "Encho2", "Feiko", "Feiko2", "Hajime", 
    "Hakka", "Hakka2", "Hakka3", "Hidari", "Hidari2", "Hidari3", "Hirugami", 
    "Ibara", "Jester", "Jester2", "Jester3", "Jester4", "Kazana", "Kazana2", 
    "Kazana3", "Kei", "Kenma", "Kijo", "Kijo2", "Kijo3", "Kimiro", "Koshi", 
    "Kotaru", "Kumo", "Kurai", "Kurai2", "Lev", "Mikage", "Mikage2", "Mikage3", 
    "Mikage4", "Morisuke", "Ohira", "Riku", "Rintaro", "Roketto", "Ryunosuke", 
    "Samurai", "Samurai2", "Shinsuke", "Shiro", "Shirudo", "Shoyo", "Tadashi", 
    "Taketora", "TeamCaptain", "TeamCaptain2", "TeamCaptain3", "TeamCaptain4", 
    "Tetsuro", "TimeskipShoyo", "TimeskipShoyo2", "TimeskipShoyo3", "TimeskipShoyo4", 
    "TimeskipTobio", "TimeskipTobio2", "TimeskipTobio3", "TimeskipTobio4", 
    "TimeskipToru", "TimeskipToru2", "TimeskipToru3", "Tobio", "Toru", "Twin1", 
    "Twin1_2", "Twin1_3", "Twin1_4", "Twin2", "Twin2_2", "Twin2_3", "Twin2_4", 
    "Wakatoshi", "Yogan", "Yogan2", "Yu"
}

local ALL_ABILITIES = {
    "None", "BoomJump", "CurveSpike", "DivineStrength", "FourthTouch", "LeadFeet", 
    "MagneticPull", "Moonball", "RedirectionJump", "RollingThunder", "ShieldBreaker", 
    "SteelBlock", "SuperSprint", "TeamSpirit", "ZeroGravitySet"
}

local ALL_CRATES = {
    "EternalCrate", "LuckyCrate", "LuckyCrate2", "BeachCrate", "ChristmasCrate", 
    "CursedCrate", "EasterCrate", "EasterCrate_2026", "FestivalCrate", "FestivalCrate_2026", 
    "HalloweenCrate", "NewYearsCrate", "PirateCrate", "StreetCrate", "SummerCrate", 
    "ThanksgivingCrate", "UnderwaterCrate", "ValentinesCrate", "VolcanoCrate", 
    "WizardCrate1", "WizardCrate2"
}

local ALL_PACKS = {
    "Basic", "Medium", "Extreme", "Robux", "OldRobuxPack1", "Emote1", "ScoreEffect1", "Toxic1"
}

local KNOWN_CODES = {
    "RELEASE", "VOLLEYBALL", "UPDATE1", "LIKES50K", "LIKES25K", "EASTER", "2026", "STARTER", "GAMEPLAY"
}

-- ==============================================================================
-- 4. COURT GEOMETRY & TARGET SYNCHRONIZATION
-- ==============================================================================
local CourtData = {
    NetZ = -1356.51,
    CourtCenter = Vector3.new(-392.43, -23.66, -1356.51),
    CourtX_Min = -418.5,
    CourtX_Max = -366.5,
    Side1_Z_Min = -1407.5,
    Side1_Z_Max = -1356.5,
    Side2_Z_Min = -1356.5,
    Side2_Z_Max = -1305.5,
    FloorY = -23.66,
    SpikeApexMin = -16.0
}

local function getStandingFloorY()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return CourtData.FloorY end

    local rayOrigin = root.Position
    local rayDir = Vector3.new(0, -60, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local hit = Workspace:Raycast(rayOrigin, rayDir, rayParams)
    if hit then
        return hit.Position.Y
    end
    return root.Position.Y - 2.8
end

local function getActiveNetZ()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local rootPos = root and root.Position or CourtData.CourtCenter

    local closestNetZ = CourtData.NetZ
    local closestDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Net" then
            local dist = (obj.Position - rootPos).Magnitude
            if dist < closestDist and dist < 160 then
                closestDist = dist
                closestNetZ = obj.Position.Z
            end
        end
    end
    return closestNetZ
end

local function getPlayerTeamSide()
    if LP.Team then
        local idx = LP.Team:GetAttribute("Index")
        if idx == 1 then return -1 end
        if idx == 2 then return 1 end
    end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local netZ = getActiveNetZ()
        return (root.Position.Z < netZ) and -1 or 1
    end
    return -1
end

local function isPointOnPlayerSide(pos, tolerance)
    tolerance = tolerance or 3.0
    local netZ = getActiveNetZ()
    local side = getPlayerTeamSide()
    if side == -1 then
        return pos.Z <= (netZ + tolerance)
    else
        return pos.Z >= (netZ - tolerance)
    end
end

local function getOpponentTargetPosition()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local rootPos = root and root.Position or CourtData.CourtCenter
    local netZ = getActiveNetZ()
    local side = getPlayerTeamSide()

    local courtX = (math.abs(rootPos.X - (-392.43)) < 60) and -392.43 or rootPos.X
    local targetZ = (side == -1) and (netZ + 35.0) or (netZ - 35.0)

    return Vector3.new(courtX, rootPos.Y, targetZ)
end

local function snapFaceOpponent()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return Vector3.new(0, 0, -1) end

    local oppPos = getOpponentTargetPosition()
    local aimPos = Vector3.new(oppPos.X, root.Position.Y, oppPos.Z)
    root.CFrame = CFrame.lookAt(root.Position, aimPos)

    return (aimPos - root.Position).Unit
end

local function enforceMaxPower()
    pcall(function()
        local comp = require(game:GetService("ReplicatedFirst").Controllers.GameController.Components)
        if comp and comp.Power then
            comp.Power.get = function() return 1.0 end
            comp.Power.getCharge = function() return 1.0 end
        end
    end)
    pcall(function()
        if LP.Character then
            LP.Character:SetAttribute("Power", 1.0)
        end
    end)
end
pcall(enforceMaxPower)

-- Hook Physics.canInteract and GameHelper.isBallInNetBoundary to prevent uncaught nil exceptions
pcall(function()
    local RS = game:GetService("ReplicatedStorage")
    local RF = game:GetService("ReplicatedFirst")
    local Physics = require(RS.Common.Physics)
    local oldCanInteract = Physics.canInteract
    Physics.canInteract = function(player, moveName, ballPos)
        if not player or not player.Character then return false end
        if player.Team == nil then return true end
        local ok, res = pcall(function() return oldCanInteract(player, moveName, ballPos) end)
        if ok then return res end
        return true
    end

    local GameHelper = require(RF.Controllers.GameController.Actions.Move.DoMove.Game)
    local oldNetBoundary = GameHelper.isBallInNetBoundary
    GameHelper.isBallInNetBoundary = function(ball)
        if not LP.Team then return true end
        local ok, res = pcall(function() return oldNetBoundary(ball) end)
        if ok then return res end
        return true
    end
end)

local function ensureAirborne(forcePower)
    local States = Handlers and Handlers.States
    if not States then return false end

    -- Clear jump validator key
    pcall(function()
        local jVal = require(game:GetService("ReplicatedFirst").Controllers.GameController.Actions.Move.Jump.Validation)
        jVal._Key = nil
    end)

    if GameController and GameController.PerformJump then
        pcall(function()
            GameController:PerformJump(nil, nil, forcePower or 115)
        end)
    end

    -- Force state and attributes
    pcall(function()
        States.IsJumping:set(true)
        local char = LP.Character
        if char then
            char:SetAttribute("Jumping", true)
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root.AssemblyLinearVelocity.Y < 15 then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 32, root.AssemblyLinearVelocity.Z)
            end
        end
    end)

    return true
end

local function triggerGameJump(extraPower)
    return ensureAirborne(extraPower)
end

local function isLandingInBounds(pos)
    if pos.X < (CourtData.CourtX_Min - 3) or pos.X > (CourtData.CourtX_Max + 3) then
        return false
    end
    local side = getPlayerTeamSide()
    if side == -1 then
        return pos.Z >= (CourtData.Side1_Z_Min - 3) and pos.Z <= CourtData.NetZ
    else
        return pos.Z >= CourtData.NetZ and pos.Z <= (CourtData.Side2_Z_Max + 3)
    end
end

-- ==============================================================================
-- 5. BALL RECOGNITION & ACTIVE OBJECT RESOLVER
-- ==============================================================================
local function getActiveBall()
    local closestBall = nil
    local minDist = math.huge
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = root and root.Position or Vector3.new()

    for _, b in ipairs(CollectionService:GetTagged("Ball")) do
        local pp = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
        if pp and pp.Parent and pp:IsDescendantOf(Workspace) then
            local dist = (pp.Position - myPos).Magnitude
            if dist < minDist then
                minDist = dist
                closestBall = b
            end
        end
    end
    if closestBall then return closestBall end

    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name:sub(1, 12) == "CLIENT_BALL_" and child:IsA("Model") then
            return child
        end
    end
    return nil
end

local function getLandingIndicator()
    local shadow = Workspace:FindFirstChild("BallShadowIndicator")
    if shadow and shadow:IsA("BasePart") then return shadow end
    return Workspace:FindFirstChild("BallShadowIndicator", true)
end

-- Estimate ball velocity using differential positions if BallController object is unavailable
local lastBallPos = nil
local lastBallTime = 0
local estimatedBallVel = Vector3.new()

local function getBallVelocity(ball)
    if not ball then return Vector3.new() end
    if BallController and BallController.ActiveBalls then
        for _, bObj in pairs(BallController.ActiveBalls) do
            if bObj.Ball == ball and bObj.Velocity then
                return bObj.Velocity
            end
        end
    end
    local prim = ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart")
    if prim and prim.AssemblyLinearVelocity and prim.AssemblyLinearVelocity.Magnitude > 0.1 then
        return prim.AssemblyLinearVelocity
    end
    local curPos = ball:GetPivot().Position
    local curTime = os.clock()
    if lastBallPos and (curTime - lastBallTime > 0.01) then
        estimatedBallVel = (curPos - lastBallPos) / (curTime - lastBallTime)
    end
    lastBallPos = curPos
    lastBallTime = curTime
    return estimatedBallVel
end

-- ==============================================================================
-- 6. UNSTOPPABLE HIT EXECUTION WITH SERVER BYPASS & ANTI-DOUBLE-HIT GUARD
-- ==============================================================================
local lastHitTime = 0
local lastLocalHitTime = 0
local hasLocalHitCurrentRally = false
local lastTrackedBallId = nil

-- Synchronize with server authoritative attributes
pcall(function()
    ReplicatedStorage:GetAttributeChangedSignal("PreviousHitter"):Connect(function()
        local hitter = ReplicatedStorage:GetAttribute("PreviousHitter")
        if hitter and hitter ~= LP.Name and hitter ~= LP.DisplayName then
            hasLocalHitCurrentRally = false
        end
    end)
    ReplicatedStorage:GetAttributeChangedSignal("IsBallInPlay"):Connect(function()
        if not ReplicatedStorage:GetAttribute("IsBallInPlay") then
            hasLocalHitCurrentRally = false
        end
    end)
    ReplicatedStorage:GetAttributeChangedSignal("ActiveBall"):Connect(function()
        hasLocalHitCurrentRally = false
    end)
    ReplicatedStorage:GetAttributeChangedSignal("RoundState"):Connect(function()
        hasLocalHitCurrentRally = false
    end)
end)

local function canPerformHit(actionName, isServe, targetBall)
    if not S.AntiDoubleHitGuard then
        return true
    end

    -- Initial serve sequence is always allowed (first touch of rally)
    if isServe then
        return true
    end

    -- Check if active ball changed
    local currentBallId = targetBall and (targetBall:GetAttribute("ServerId") or targetBall.Name) or ReplicatedStorage:GetAttribute("ActiveBall")
    if currentBallId and lastTrackedBallId and currentBallId ~= lastTrackedBallId then
        hasLocalHitCurrentRally = false
        lastTrackedBallId = currentBallId
    end

    -- Check if round or play ended
    if ReplicatedStorage:GetAttribute("IsBallInPlay") == false then
        hasLocalHitCurrentRally = false
    end

    -- Guard 1: Server PreviousHitter check (authoritative)
    local serverPrevHitter = ReplicatedStorage:GetAttribute("PreviousHitter")
    if serverPrevHitter and (serverPrevHitter == LP.Name or serverPrevHitter == LP.DisplayName) then
        return false, "BLOCKED_BY_SERVER_PREVIOUS_HITTER"
    end

    -- If server sees someone else hit the ball, clear our local lock immediately
    if serverPrevHitter and serverPrevHitter ~= LP.Name and serverPrevHitter ~= LP.DisplayName then
        hasLocalHitCurrentRally = false
    end

    -- Guard 2: Local Possession Lock (prevents double contact before server replication)
    if hasLocalHitCurrentRally then
        -- Safety timeout: if 3.5s elapsed and ball is still in rally, allow reset
        if os.clock() - lastLocalHitTime > 3.5 then
            hasLocalHitCurrentRally = false
        else
            return false, "BLOCKED_BY_LOCAL_POSSESSION_LOCK"
        end
    end

    -- Guard 3: Minimum physical cooldown between hits
    if os.clock() - lastLocalHitTime < (S.MinHitCooldown or 0.55) then
        return false, "BLOCKED_BY_COOLDOWN"
    end

    return true
end

local function executeHit(actionName, isAerial, targetBall, isServe)
    local ball = targetBall or getActiveBall()
    if not ball then return false end

    -- Verify Anti-Double-Hit Contact Authorization
    local allowed, reason = canPerformHit(actionName, isServe, ball)
    if not allowed then
        return false
    end

    -- Cooldown guard
    if os.clock() - lastHitTime < 0.25 then return false end
    lastHitTime = os.clock()
    lastLocalHitTime = os.clock()
    hasLocalHitCurrentRally = true
    lastTrackedBallId = ball:GetAttribute("ServerId") or ball.Name or ReplicatedStorage:GetAttribute("ActiveBall")

    unfreezeController()
    enforceMaxPower()

    if isAerial then
        ensureAirborne()
    end

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local serverId = ball:GetAttribute("ServerId") or ReplicatedStorage:GetAttribute("ActiveBall") or tonumber(ball.Name:match("%d+"))

    local look = snapFaceOpponent()

    -- Priority 1: Native GameController:DoMove
    if GameController and GameController.DoMove then
        pcall(function()
            GameController:DoMove({
                ActionName = actionName,
                IsAerial = isAerial,
                IsForce = true,
                InputState = Enum.UserInputState.Begin,
                Metadata = {
                    Charge = 1.0,
                    SpecialCharge = 1.0,
                    Power = 1.0,
                    CustomClient = {}
                }
            })
        end)
    end

    -- Priority 2: Direct Knit BallService:Interact backup
    if BallService and BallService.Interact and serverId and (LP.Team ~= nil or LP:GetAttribute("Gameplay_InGame") == true) then
        task.spawn(function()
            pcall(function()
                local key = ("%s%d"):format(actionName, math.round(os.clock() * 1000))
                if BallService.CreateHitbox then
                    pcall(function()
                        BallService:CreateHitbox({
                            Key = key,
                            Move = actionName,
                            BallId = serverId,
                            Charge = 1.0,
                            ClientTimestamp = Workspace:GetServerTimeNow()
                        })
                    end)
                end

                BallService:Interact({
                    From = "Client",
                    Move = actionName,
                    BallId = serverId,
                    LookVector = look or (root and root.CFrame.LookVector) or Vector3.new(0, 0, 1),
                    MoveDirection = look or (root and root.CFrame.LookVector) or Vector3.new(0, 0, 1),
                    TiltDirection = Vector3.new(0, 1, 0),
                    Key = key,
                    Charge = 1.0,
                    SpecialCharge = 1.0,
                    ClientCanRunSpecial = false,
                    Timestamp = Workspace:GetServerTimeNow(),
                    CustomClient = {}
                })
            end)
        end)
    end

    return true
end

-- ==============================================================================
-- 7. TACTICAL REAL-TIME ON-SCREEN HUD OVERLAY
-- ==============================================================================
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "VolleyballLegends_HUD"
hudGui.ResetOnSpawn = false
pcall(function()
    hudGui.Parent = getSafeGuiRoot()
end)

local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUD_Banner"
hudFrame.Size = UDim2.fromOffset(430, 62)
hudFrame.Position = UDim2.new(0.5, -215, 0.02, 0)
hudFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
hudFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
hudFrame.BorderSizePixel = 1
hudFrame.Parent = hudGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 8)
hudCorner.Parent = hudFrame

local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(0, 200, 255)
hudStroke.Thickness = 1.5
hudStroke.Transparency = 0.3
hudStroke.Parent = hudFrame

local hudTitle = Instance.new("TextLabel")
hudTitle.Name = "Title"
hudTitle.Size = UDim2.new(1, -16, 0, 20)
hudTitle.Position = UDim2.new(0, 8, 0, 6)
hudTitle.BackgroundTransparency = 1
hudTitle.Font = Enum.Font.GothamBold
hudTitle.TextSize = 13
hudTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
hudTitle.TextXAlignment = Enum.TextXAlignment.Left
hudTitle.Text = "ð TACTICAL ENGINE: INITIALIZING..."
hudTitle.Parent = hudFrame

local hudStatus = Instance.new("TextLabel")
hudStatus.Name = "Status"
hudStatus.Size = UDim2.new(1, -16, 0, 26)
hudStatus.Position = UDim2.new(0, 8, 0, 28)
hudStatus.BackgroundTransparency = 1
hudStatus.Font = Enum.Font.GothamMedium
hudStatus.TextSize = 12
hudStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
hudStatus.TextXAlignment = Enum.TextXAlignment.Left
hudStatus.Text = "State: Idle | Ball: Searching..."
hudStatus.Parent = hudFrame

local function updateHUD(stateText, statusText, alertColor)
    pcall(function()
        if not S.TacticalHUD then
            if hudFrame then hudFrame.Visible = false end
            return
        end
        if not hudFrame or not hudTitle or not hudStatus then return end
        hudFrame.Visible = true
        hudTitle.Text = stateText or "ð TACTICAL ENGINE: ACTIVE"
        hudStatus.Text = statusText or ""
        if alertColor and hudStroke then
            hudStroke.Color = alertColor
            hudTitle.TextColor3 = alertColor
        elseif hudStroke then
            hudStroke.Color = Color3.fromRGB(0, 200, 255)
            hudTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
        end
    end)
end

-- ==============================================================================
-- 8. VISUALS / 3D ESP
-- ==============================================================================
local ESP_CONTAINER = Instance.new("Folder")
ESP_CONTAINER.Name = "Volleyball_ESP_Drawings"
pcall(function() ESP_CONTAINER.Parent = Workspace end)

local ballHighlightInstance = nil
local trajectoryBeamInstance = nil
local beamPartA = nil
local beamPartB = nil
local circleMarkerInstance = nil

local function cleanupESP()
    pcall(function()
        if ballHighlightInstance then ballHighlightInstance:Destroy() ballHighlightInstance = nil end
        if beamPartA then beamPartA:Destroy() beamPartA = nil end
        if beamPartB then beamPartB:Destroy() beamPartB = nil end
        if circleMarkerInstance then circleMarkerInstance:Destroy() circleMarkerInstance = nil end
        for _, obj in ipairs(ESP_CONTAINER:GetChildren()) do obj:Destroy() end
    end)
end

local function updateESP()
    local ball = getActiveBall()
    local shadow = getLandingIndicator()

    -- 1. Ball 3D Highlight
    if S.BallHighlight and ball then
        if not ballHighlightInstance or ballHighlightInstance.Adornee ~= ball then
            if ballHighlightInstance then ballHighlightInstance:Destroy() end
            ballHighlightInstance = Instance.new("Highlight")
            ballHighlightInstance.Name = "Ball_Cham"
            ballHighlightInstance.Adornee = ball
            ballHighlightInstance.FillColor = Color3.fromRGB(255, 60, 60)
            ballHighlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
            ballHighlightInstance.FillTransparency = 0.35
            ballHighlightInstance.OutlineTransparency = 0.0
            ballHighlightInstance.Parent = ESP_CONTAINER
        end
    else
        if ballHighlightInstance then ballHighlightInstance:Destroy() ballHighlightInstance = nil end
    end

    -- 2. Landing Circle ESP
    if S.LandingCircleESP and shadow then
        if not circleMarkerInstance or not circleMarkerInstance.Parent then
            circleMarkerInstance = Instance.new("CylinderHandleAdornment")
            circleMarkerInstance.Name = "LandingCircle"
            circleMarkerInstance.Adornee = shadow
            circleMarkerInstance.Color3 = isPointOnPlayerSide(shadow.Position) and Color3.fromRGB(0, 230, 255) or Color3.fromRGB(255, 120, 0)
            circleMarkerInstance.Transparency = 0.3
            circleMarkerInstance.Height = 0.5
            circleMarkerInstance.Radius = 4.5
            circleMarkerInstance.CFrame = CFrame.Angles(math.rad(90), 0, 0)
            circleMarkerInstance.AlwaysOnTop = true
            circleMarkerInstance.ZIndex = 5
            circleMarkerInstance.Parent = ESP_CONTAINER
        end
        circleMarkerInstance.Adornee = shadow
        circleMarkerInstance.Color3 = isPointOnPlayerSide(shadow.Position) and Color3.fromRGB(0, 230, 255) or Color3.fromRGB(255, 120, 0)
    else
        if circleMarkerInstance then circleMarkerInstance:Destroy() circleMarkerInstance = nil end
    end

    -- 3. Trajectory Beam Tracer
    if S.BallTrajectoryTracer and ball and shadow then
        local ballPos = ball:GetPivot().Position
        local shadowPos = shadow.Position

        if not beamPartA or not beamPartA.Parent then
            beamPartA = Instance.new("Part")
            beamPartA.Size = Vector3.new(0.1, 0.1, 0.1)
            beamPartA.Transparency = 1
            beamPartA.Anchored = true
            beamPartA.CanCollide = false
            beamPartA.Parent = ESP_CONTAINER

            beamPartB = Instance.new("Part")
            beamPartB.Size = Vector3.new(0.1, 0.1, 0.1)
            beamPartB.Transparency = 1
            beamPartB.Anchored = true
            beamPartB.CanCollide = false
            beamPartB.Parent = ESP_CONTAINER

            local attA = Instance.new("Attachment", beamPartA)
            local attB = Instance.new("Attachment", beamPartB)

            trajectoryBeamInstance = Instance.new("Beam")
            trajectoryBeamInstance.Attachment0 = attA
            trajectoryBeamInstance.Attachment1 = attB
            trajectoryBeamInstance.Color = ColorSequence.new(Color3.fromRGB(255, 180, 0), Color3.fromRGB(0, 255, 200))
            trajectoryBeamInstance.Width0 = 0.4
            trajectoryBeamInstance.Width1 = 0.7
            trajectoryBeamInstance.FaceCamera = true
            trajectoryBeamInstance.Segments = 10
            trajectoryBeamInstance.Parent = ESP_CONTAINER
        end

        beamPartA.Position = ballPos
        beamPartB.Position = shadowPos
    else
        if trajectoryBeamInstance then
            if beamPartA then beamPartA:Destroy() beamPartA = nil end
            if beamPartB then beamPartB:Destroy() beamPartB = nil end
            trajectoryBeamInstance = nil
        end
    end
end

-- ==============================================================================
-- 9. SMART MATCH SERVE ENGINE (100% TRUE MAX POWER)
-- ==============================================================================
local isServingRoutineRunning = false

local function runMatchServeSequence()
    if isServingRoutineRunning then return end
    isServingRoutineRunning = true

    task.spawn(function()
        local ok, err = pcall(function()
            notify("Match Serve", "Your Turn to Serve! Executing 100% Max Power Jump Serve...", 3)
            updateHUD("ð SERVE TURN DETECTED", "Preparing 100% TRUE MAX POWER Jump Serve...", Color3.fromRGB(255, 220, 0))

            task.wait(S.AutoServeDelay or 0.4)

            -- Ensure controller is ready and facing opponent
            unfreezeController()
            snapFaceOpponent()
            enforceMaxPower()

            -- Step 1: Start Toss Power Bar (TossIdle)
            if TossModule then
                TossModule._tossDebounce = 0
                if TossModule.onTossRequest then
                    TossModule.onTossRequest(Enum.UserInputState.Begin)
                elseif TossModule.showPowerBall then
                    TossModule.showPowerBall()
                end
            end

            -- Wait 0.35s for power bar charging
            task.wait(0.35)

            -- Step 2: Release Toss into air with 100% TRUE MAX POWER
            snapFaceOpponent()
            enforceMaxPower()

            if TossModule then
                TossModule._tossDebounce = 0
                if TossModule.executeToss then
                    TossModule.executeToss(1.0)
                elseif TossModule.onTossRequest then
                    TossModule.onTossRequest(Enum.UserInputState.Begin)
                end
            end

            updateHUD("ð TOSS IN AIR", "Waiting for Apex to Jump & Smash...", Color3.fromRGB(0, 255, 180))

            -- Wait until ball is tossed and starts rising
            task.wait(0.2)

            -- Step 3: Track ball as it rises, physically LEAP INTO THE AIR!
            local startWait = os.clock()
            local jumped = false
            while (os.clock() - startWait) < 2.5 do
                RunService.Heartbeat:Wait()
                local ball = getActiveBall()
                local char = LP.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if ball and root then
                    local ballPos = ball:GetPivot().Position
                    local ballVel = getBallVelocity(ball)
                    local ballHeightRel = ballPos.Y - root.Position.Y

                    -- Trigger jump as ball approaches apex!
                    if not jumped and (ballVel.Y <= 6.0 or ballHeightRel >= 7.0) then
                        jumped = true
                        ensureAirborne(125)
                        updateHUD("ð JUMPING TO APEX!", "Smashing Jump Serve at Peak...", Color3.fromRGB(255, 100, 100))
                    end

                    -- In the air near apex -> Snap behind ball and SMASH!
                    if jumped then
                        local side = getPlayerTeamSide()
                        local oppPos = getOpponentTargetPosition()
                        local attackZ = (side == -1) and (ballPos.Z - 1.8) or (ballPos.Z + 1.8)
                        local attackPos = Vector3.new(ballPos.X, ballPos.Y - 1.0, attackZ)

                        root.CFrame = CFrame.lookAt(attackPos, Vector3.new(oppPos.X, attackPos.Y, oppPos.Z))
                        root.AssemblyLinearVelocity = Vector3.new(0, 5, 0)

                        task.wait(0.04)
                        enforceMaxPower()
                        executeHit("Spike", true, ball, true)
                        updateHUD("ð JUMP SPIKE SERVE ACE!", "Ball served at 100% TRUE MAX POWER!", Color3.fromRGB(0, 255, 100))
                        break
                    end
                end
            end
        end)

        if not ok then
            print("[SERVE_ERR] " .. tostring(err))
        end

        task.wait(1.0)
        unfreezeController()
        isServingRoutineRunning = false
    end)
end

-- ==============================================================================
-- 10. PREDICTIVE APEX SPIKE & MATCH COMBAT ENGINE (HEARTBEAT)
-- ==============================================================================
local activeConnections = {}
local isAerialRoutineRunning = false

local function onHeartbeat(dt)
    local ok, err = pcall(function()
        updateESP()

        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end

        -- Anti-Floor-Stuck Guard: If character ever gets stuck prone, in dive state, or immobilized with 0 WalkSpeed, auto-recover
        if (hum.WalkSpeed == 0 and not isAerialRoutineRunning) or (Handlers and Handlers.States and Handlers.States.IsDiving and Handlers.States.IsDiving:get()) then
            unfreezeController()
        end

        -- Movement Modifiers
        if S.CustomSpeed then hum.WalkSpeed = S.WalkSpeed end
        if S.CustomJump then hum.JumpPower = S.JumpPower end

        -- Air Walk Float
        if S.AirWalkFloat then
            local vel = root.AssemblyLinearVelocity
            if root.Position.Y < CourtData.FloorY + S.FloatHeight then
                root.AssemblyLinearVelocity = Vector3.new(vel.X, 15, vel.Z)
            end
        end

        -- Check Match Participation Guard
        local isInMatch = (LP.Team ~= nil) or (LP:GetAttribute("Gameplay_InGame") == true) or (GameController and GameController.IsPlaying and GameController.IsPlaying:get() == true)
        local isTraining = false
        pcall(function()
            local Gamemode = require(ReplicatedStorage.Configuration.Gamemode)
            if Gamemode and Gamemode.Current and Gamemode.Current() == Gamemode.Types.Training then
                isTraining = true
            end
        end)

        if not isInMatch and not isTraining then
            updateHUD("ð LOBBY / SPECTATING", "Join a match or enter queue to activate combat engine!", Color3.fromRGB(200, 200, 200))
            return
        end

        -- Check Match Serve Turn
        local isServingState = false
        if Handlers and Handlers.States and Handlers.States.IsServing then
            isServingState = Handlers.States.IsServing:get() == true
        elseif StateModule then
            isServingState = StateModule.get(LP, StateModule.Id.Context, "IsServing") == true
        end

        if isServingState then
            if S.AutoServeMatch and not isServingRoutineRunning then
                runMatchServeSequence()
            else
                updateHUD("ð YOUR TURN TO SERVE", "Press Toss (LMB) or Enable Auto-Serve in Menu", Color3.fromRGB(255, 210, 0))
            end
            return
        end

        local ball = getActiveBall()
        local shadow = getLandingIndicator()
        if not ball then
            updateHUD("ð MATCH ENGINE: ACTIVE", "Waiting for Serve / Ball in Play...", Color3.fromRGB(0, 200, 255))
            return
        end

        local ballPos = ball:GetPivot().Position
        local rootPos = root.Position
        local shadowPos = shadow and shadow.Position or ballPos
        local ballVel = getBallVelocity(ball)

        local distToBall = (rootPos - ballPos).Magnitude
        local distToShadow = (Vector3.new(rootPos.X, 0, rootPos.Z) - Vector3.new(shadowPos.X, 0, shadowPos.Z)).Magnitude

        local isBallOnOurSide = isPointOnPlayerSide(ballPos, 2.5)
        local isShadowOnOurSide = isPointOnPlayerSide(shadowPos, 2.5)
        local isBallInBounds = isLandingInBounds(shadowPos)
        local isAirborne = (hum.FloorMaterial == Enum.Material.Air) or (rootPos.Y > CourtData.FloorY + 2.5)
        local ballHeightRel = ballPos.Y - rootPos.Y

        -- Check Incoming Serve Protection
        local servedBy = ReplicatedStorage:GetAttribute("ServedByTeam")
        local isIncomingServe = false
        if servedBy and LP.Team then
            isIncomingServe = (LP.Team.Name ~= servedBy)
        end

        -- Update Live Telemetry HUD
        local statusSide = isBallOnOurSide and "OUR COURT" or "OPPONENT COURT"
        local statusBall = string.format("Ball: %.1fm | VelY: %.1f", distToBall, ballVel.Y)
        local actionAdvice = "Idle"

        local floorY = getStandingFloorY()
        local netZ = getActiveNetZ()
        local side = getPlayerTeamSide()
        local oppPos = getOpponentTargetPosition()

        -- Check Anti-Double-Hit Contact Authorization (Prevents Consecutive Hit Fault)
        local canHit, hitBlockReason = canPerformHit("Inspect", false, ball)
        if not canHit then
            actionAdvice = "WAITING FOR TEAMMATE TOUCH (1X LIMIT)"
            updateHUD(string.format("ð %s | %s", statusSide, actionAdvice), statusBall, Color3.fromRGB(255, 180, 0))
            return
        end

        -- 10.0 SUPER OP AUTO-NET BLOCK (SHUT DOWN OPPONENT SPIKES AT THE NET!)
        if S.AutoNetBlock and not isAerialRoutineRunning then
            local distNetBall = math.abs(ballPos.Z - netZ)
            local isBallAtNet = distNetBall <= S.BlockReachDistance and ballPos.Y >= (floorY + 7.0)
            local isOpponentSpiking = not isPointOnPlayerSide(ballPos, 1.5) or (ballVel.Z * side < 0)

            if isBallAtNet and isOpponentSpiking then
                isAerialRoutineRunning = true
                task.spawn(function()
                    local blockZ = (side == -1) and (netZ - 2.2) or (netZ + 2.2)
                    local blockX = math.clamp(ballPos.X, CourtData.CourtX_Min + 2, CourtData.CourtX_Max - 2)
                    local blockPos = Vector3.new(blockX, floorY + 2.7, blockZ)

                    root.CFrame = CFrame.lookAt(blockPos, Vector3.new(blockX, blockPos.Y, (side == -1) and (netZ + 25) or (netZ - 25)))
                    ensureAirborne(125)
                    task.wait(0.04)
                    executeHit("Block", true, ball)
                    updateHUD(string.format("ð %s | %s", statusSide, "SHUTDOWN NET BLOCK EXECUTED!"), statusBall, Color3.fromRGB(255, 50, 80))
                    task.wait(0.4)
                    unfreezeController()
                    isAerialRoutineRunning = false
                end)
                return
            end
        end

        -- 10.1 SUPER OP AERIAL TELEPORT-SPIKE (The Ultimate Solution to High Ball Spikes)
        if S.AutoTPSpike and not isAerialRoutineRunning and not isIncomingServe and (isShadowOnOurSide or isBallOnOurSide) then
            local isBallHighInAir = (ballPos.Y >= floorY + 7.5) and (ballVel.Y <= 8.0)

            if isBallHighInAir then
                isAerialRoutineRunning = true
                task.spawn(function()
                    local attackZ = (side == -1) and (ballPos.Z - 1.8) or (ballPos.Z + 1.8)
                    if S.StayOnSide then
                        attackZ = (side == -1) and math.min(attackZ, netZ - 2.5) or math.max(attackZ, netZ + 2.5)
                    end
                    local attackPos = Vector3.new(ballPos.X, ballPos.Y - 1.0, attackZ)

                    root.CFrame = CFrame.lookAt(attackPos, Vector3.new(oppPos.X, attackPos.Y, oppPos.Z))
                    ensureAirborne(120)
                    task.wait(0.04)
                    executeHit("Spike", true, ball)
                    updateHUD(string.format("ð %s | %s", statusSide, "TELEPORT-SPIKE 100% POWER!"), statusBall, Color3.fromRGB(0, 255, 120))
                    task.wait(0.4)
                    unfreezeController()
                    isAerialRoutineRunning = false
                end)
                return
            end
        end

        -- 10.2 AUTO TELEPORT-RECEIVE (TP-BUMP / TP-DIVE)
        if S.AutoTPReceive and not isAerialRoutineRunning and (isShadowOnOurSide or isBallOnOurSide) then
            local distH = (Vector3.new(rootPos.X, 0, rootPos.Z) - Vector3.new(shadowPos.X, 0, shadowPos.Z)).Magnitude

            -- When ball drops to ground reception height
            if (ballPos.Y - floorY <= 8.5) and (distH > 2.5) then
                isAerialRoutineRunning = true
                task.spawn(function()
                    local receiveZ = shadowPos.Z
                    if S.StayOnSide then
                        receiveZ = (side == -1) and math.min(receiveZ, netZ - 2.5) or math.max(receiveZ, netZ + 2.5)
                    end
                    local receivePos = Vector3.new(shadowPos.X, floorY + 2.7, receiveZ)

                    root.CFrame = CFrame.lookAt(receivePos, Vector3.new(oppPos.X, receivePos.Y, oppPos.Z))

                    -- Strictly use standing Bump (Never Dive) to eliminate floor rolling and stay mobile
                    actionAdvice = "TELEPORT-BUMP RECEIVE!"
                    executeHit("Bump", false, ball)
                    updateHUD(string.format("ð %s | %s", statusSide, actionAdvice), statusBall, Color3.fromRGB(0, 200, 255))
                    task.wait(0.35)
                    unfreezeController()
                    isAerialRoutineRunning = false
                end)
                return
            end
        end

        -- 10.3 Auto Ball Magnet Navigation (Smart Non-Intrusive Assist)
        if S.AutoBallMagnet and shadow and isShadowOnOurSide and not S.AutoTPSpike and not S.AutoTPReceive then
            if not S.IgnoreOutBalls or isBallInBounds then
                local side = getPlayerTeamSide()
                local targetZ = shadowPos.Z
                if S.StayOnSide then
                    targetZ = (side == -1) and math.min(targetZ, netZ - 2.5) or math.max(targetZ, netZ + 2.5)
                end
                local targetPos = Vector3.new(shadowPos.X, rootPos.Y, targetZ)

                local isMovingManually = UserInputService:IsKeyDown(Enum.KeyCode.W) or
                                         UserInputService:IsKeyDown(Enum.KeyCode.A) or
                                         UserInputService:IsKeyDown(Enum.KeyCode.S) or
                                         UserInputService:IsKeyDown(Enum.KeyCode.D)

                if (S.MagnetMode == "Force" or not isMovingManually) and distToShadow > 1.8 then
                    hum:MoveTo(targetPos)
                end
            end
        end

        -- 10.4 Predictive Apex Spike Synchronization (Pre-Jump When Nearby)
        if S.AutoSpikeApex and not isIncomingServe and isShadowOnOurSide and (not S.StrictSideCheck or isBallOnOurSide) and not S.AutoTPSpike then
            local isHighSet = (ballPos.Y > floorY + 8.5) and (distToShadow <= 12.0)

            if isHighSet and not isAirborne then
                local idealContactY = floorY + 14.5
                local diffY = ballPos.Y - idealContactY
                local fallingSpeed = math.max(math.abs(ballVel.Y), 16.0)
                local timeToContact = diffY / fallingSpeed

                actionAdvice = string.format("SET DETECTED (Time: %.2fs)", timeToContact)

                if timeToContact <= S.SpikeLeadTime and timeToContact >= -0.05 then
                    actionAdvice = "JUMPING FOR SPIKE APEX!"
                    snapFaceOpponent()
                    triggerGameJump(110)
                end
            end
        end

        -- 10.5 Airborne Spike Execution (When player jumps manually with Spacebar)
        if isAirborne and S.AutoSpikeAirborne and not isIncomingServe then
            actionAdvice = "AIRBORNE - READY TO SPIKE"
            if distToBall <= S.SpikeHitRadius and ballPos.Y >= (rootPos.Y - 2.5) then
                actionAdvice = "SMASH EXECUTED!"
                executeHit("Spike", true, ball)
                return
            end
        end

        -- 10.6 Aerial Net Block Execution
        if isAirborne and math.abs(rootPos.Z - netZ) <= 6.5 and distToBall <= 9.0 then
            actionAdvice = "BLOCKING AT NET!"
            executeHit("Block", true, ball)
            return
        end

        -- 10.7 Ground Defense (Bump & Emergency Dive)
        if not isAirborne and (isShadowOnOurSide or not S.StrictSideCheck) and not S.AutoTPReceive then
            if S.AutoDive and (ballPos.Y - floorY <= 6.0) and distToShadow > 6.0 and distToShadow <= 18.0 then
                actionAdvice = "EMERGENCY DIVE SAVE!"
                executeHit("Dive", false, ball)
                task.delay(0.65, unfreezeController)
                return
            elseif S.AutoBump and distToBall <= S.GroundHitRadius and (ballHeightRel <= S.VerticalBumpReach) and (ballPos.Y - floorY <= 8.5) then
                actionAdvice = "RECEIVE BUMP EXECUTED!"
                executeHit("Bump", false, ball)
                return
            end
        end

        -- Update HUD Display
        updateHUD(string.format("ð %s | %s", statusSide, actionAdvice), statusBall, isBallOnOurSide and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(255, 140, 0))
    end)

    if not ok then
        if not _G.__LAST_HB_ERR or _G.__LAST_HB_ERR ~= err then
            _G.__LAST_HB_ERR = err
            print("[HB_ERR] " .. tostring(err))
        end
    end
end

table.insert(activeConnections, RunService.Heartbeat:Connect(onHeartbeat))

-- Infinite Jump
table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump then
        triggerGameJump()
    end
end))

-- NoClip
table.insert(activeConnections, RunService.Stepped:Connect(function()
    if S.NoClip then
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end))

-- Anti-AFK
table.insert(activeConnections, LP.Idled:Connect(function()
    if S.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end
end))

-- Background Auto-Claim Loop
local isAutomationRunning = true
task.spawn(function()
    while isAutomationRunning do
        task.wait(S.FarmLoopInterval)

        if S.AutoClaimQuests and QuestService and QuestService.ClaimAll then
            pcall(function() QuestService:ClaimAll():await() end)
        end
        if S.AutoClaimLevelRewards and LevelService and LevelService.ClaimLevelRewards then
            pcall(function() LevelService:ClaimLevelRewards():await() end)
        end
        if S.AutoClaimMastery and MasteryService and MasteryService.RequestClaim then
            pcall(function() MasteryService:RequestClaim():await() end)
        end
        if S.AutoClaimDailyPresents and SeasonService and SeasonService.ClaimDailyPresent then
            pcall(function()
                for i = 1, 5 do SeasonService:ClaimDailyPresent(i):await() task.wait(0.2) end
            end)
        end
        if S.AutoClaimDailyReward and DailyRewardService and DailyRewardService.AwardDailyReward then
            pcall(function() DailyRewardService:AwardDailyReward():await() end)
        end
        if S.AutoSellDuplicates and InventoryService and InventoryService.SellDuplicates then
            pcall(function() InventoryService:SellDuplicates():await() end)
        end
    end
end)

-- Practice Spawner Loop
task.spawn(function()
    while isAutomationRunning do
        task.wait(1.0)

        if S.LoopSpawnBall and BallService and BallService.SpawnBall then
            local ball = getActiveBall()
            if not ball then pcall(function() BallService:SpawnBall():await() end) end
            task.wait(S.PracticeSpawnDelay)
        end

        if S.LoopSpawnServe and BallService and BallService.SpawnServeBall then
            local ball = getActiveBall()
            if not ball then pcall(function() BallService:SpawnServeBall():await() end) end
            task.wait(S.PracticeSpawnDelay)
        end
    end
end)

-- Gacha / Auto Roll Suite Loop (Safely Wrapped)
task.spawn(function()
    while isAutomationRunning do
        task.wait(0.4)

        if S.AutoRollStyle and StyleService and StyleService.Roll then
            local ok, res1, res2 = pcall(function() return StyleService:Roll(S.LuckyStyle):await() end)
            local rollData = (type(res1) == "table" and res1) or (type(res2) == "table" and res2)
            if ok and rollData then
                local lastItem = rollData[#rollData]
                local rolledName = (type(lastItem) == "table" and lastItem.Name) or tostring(lastItem)
                if S.StopOnStyleName ~= "None" and rolledName == S.StopOnStyleName then
                    S.AutoRollStyle = false
                    if UI_ELEMENTS.AutoRollStyle then UI_ELEMENTS.AutoRollStyle:Set(false) end
                    notify("Style Gacha Hit!", "Target Style: " .. rolledName, 6)
                    if S.LockStyleOnHit and StyleService.ToggleLockSlot then
                        pcall(function() StyleService:ToggleLockSlot(1, true):await() end)
                    end
                end
            end
        end

        if S.AutoRollAbility and AbilityService and AbilityService.Roll then
            local ok, res1, res2 = pcall(function() return AbilityService:Roll(S.LuckyAbility):await() end)
            local rollData = (type(res1) == "table" and res1) or (type(res2) == "table" and res2)
            if ok and rollData then
                local lastItem = rollData[#rollData]
                local rolledName = (type(lastItem) == "table" and lastItem.Name) or tostring(lastItem)
                if S.StopOnAbilityName ~= "None" and rolledName == S.StopOnAbilityName then
                    S.AutoRollAbility = false
                    if UI_ELEMENTS.AutoRollAbility then UI_ELEMENTS.AutoRollAbility:Set(false) end
                    notify("Ability Gacha Hit!", "Target Ability: " .. rolledName, 6)
                    if S.LockAbilityOnHit and AbilityService.ToggleLockSlot then
                        pcall(function() AbilityService:ToggleLockSlot(1, true):await() end)
                    end
                end
            end
        end

        if S.AutoOpenCrates and CrateService and CrateService.RequestOpen then
            pcall(function() CrateService:RequestOpen(S.SelectedCrate, S.CrateOpenAmount):await() end)
            task.wait(0.5)
        end
        if S.AutoOpenPacks and PackService and PackService.Open then
            pcall(function() PackService:Open(S.SelectedPack):await() end)
            task.wait(0.5)
        end
    end
end)

-- ==============================================================================
-- 11. WINDUI GRAPHICAL USER INTERFACE
-- ==============================================================================
local WindUI = nil
for attempt = 1, 3 do
    local okWind, resWind = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if okWind and type(resWind) == "table" then
        WindUI = resWind
        break
    else
        task.wait(1.2)
    end
end

if not WindUI then
    warn("[Volleyball Legends OP] Failed to download WindUI remote. Fallback abort.")
    notify("Error", "Could not load WindUI framework.", 5)
    return
end

local Window = WindUI:CreateWindow({
    Title = "FLa ProjecT Volleyball Legends",
    SubTitle = "v3.0 - Pro Master Edition",
    Folder = "VolleyballLegends_WindUI",
    TabWidth = 145,
    Size = UDim2.fromOffset(630, 490),
    MinSize = Vector2.new(550, 400),
    MaxSize = Vector2.new(850, 650),
    Resizable = true,
    Transparent = true,
    Theme = "Dark",
    -- Author removed
})

-- TAB 1: Gameplay & Auto-Hit
local TabCombat = Window:Tab({
    Title = "Gameplay",
    Icon = "target"
})

TabCombat:Section({Title = "Super OP Teleport & Air-Snap Suite"})

UI_ELEMENTS.AutoTPSpike = TabCombat:Toggle({
    Title = "Auto Teleport-Spike (OP)",
    Desc = "Instantly teleports into mid-air behind high sets, jumps, and smashes at opponent court with 100% max power",
    Value = S.AutoTPSpike,
    Callback = function(v) S.AutoTPSpike = v end
})

UI_ELEMENTS.AutoTPReceive = TabCombat:Toggle({
    Title = "Auto Teleport-Receive (OP)",
    Desc = "Instantly teleports to ball landing zone to receive low balls / incoming serves cleanly",
    Value = S.AutoTPReceive,
    Callback = function(v) S.AutoTPReceive = v end
})

UI_ELEMENTS.AutoNetBlock = TabCombat:Toggle({
    Title = "Auto Net Block (OP)",
    Desc = "Detects opponent spikes at the net, teleports to the net, leaps into the air, and blocks the ball down",
    Value = S.AutoNetBlock,
    Callback = function(v) S.AutoNetBlock = v end
})

UI_ELEMENTS.BlockReachDistance = TabCombat:Slider({
    Title = "Net Block Reach Distance",
    Desc = "Distance from net to trigger auto-block (Studs)",
    Step = 0.5,
    Value = {Min = 6, Max = 25, Default = S.BlockReachDistance},
    Callback = function(v) S.BlockReachDistance = v end
})

UI_ELEMENTS.AlwaysFaceOpponent = TabCombat:Toggle({
    Title = "Lock Aim Towards Opponent Court",
    Desc = "Always forces character to face opponent court when hitting, eliminating out-of-bounds hits",
    Value = S.AlwaysFaceOpponent,
    Callback = function(v) S.AlwaysFaceOpponent = v end
})

TabCombat:Section({Title = "Predictive Aerial Spike & Defense"})

UI_ELEMENTS.AutoSpikeApex = TabCombat:Toggle({
    Title = "Auto Apex Jump & Spike",
    Desc = "Detects high set balls, pre-jumps at the exact frame, and smashes at peak apex",
    Value = S.AutoSpikeApex,
    Callback = function(v) S.AutoSpikeApex = v end
})

UI_ELEMENTS.AutoSpikeAirborne = TabCombat:Toggle({
    Title = "Instant Spike on Manual Jump",
    Desc = "Whenever you jump into the air, instantly executes spike if near the ball",
    Value = S.AutoSpikeAirborne,
    Callback = function(v) S.AutoSpikeAirborne = v end
})

UI_ELEMENTS.AutoBump = TabCombat:Toggle({
    Title = "Auto Bump / Receive (Ground)",
    Desc = "Only receives when ball actually drops into reachable height (Zero phantom swings)",
    Value = S.AutoBump,
    Callback = function(v) S.AutoBump = v end
})

UI_ELEMENTS.AutoDive = TabCombat:Toggle({
    Title = "Auto Emergency Dive",
    Desc = "Slides to save low balls out of normal reach",
    Value = S.AutoDive,
    Callback = function(v) S.AutoDive = v end
})

UI_ELEMENTS.ForceMaxPower = TabCombat:Toggle({
    Title = "Force 100% Max Power",
    Desc = "Injects Charge 1.0 & SpecialCharge 1.0 into all hit actions",
    Value = S.ForceMaxPower,
    Callback = function(v) S.ForceMaxPower = v end
})

UI_ELEMENTS.AutoAimOpponent = TabCombat:Toggle({
    Title = "Auto Aim Opponent Court",
    Desc = "Drives hit angles away from net blockers towards open corners",
    Value = S.AutoAimOpponent,
    Callback = function(v) S.AutoAimOpponent = v end
})

TabCombat:Section({Title = "Match Auto-Serve Engine"})

UI_ELEMENTS.AutoServeMatch = TabCombat:Toggle({
    Title = "Auto Serve on Your Turn",
    Desc = "Monitors match state and automatically executes Toss + Apex Spike Ace when it's your turn",
    Value = S.AutoServeMatch,
    Callback = function(v) S.AutoServeMatch = v end
})

UI_ELEMENTS.AutoServeDelay = TabCombat:Slider({
    Title = "Serve Start Delay (Seconds)",
    Desc = "Pause before executing toss (realistic timing)",
    Step = 0.1,
    Value = {Min = 0.2, Max = 2.0, Default = S.AutoServeDelay},
    Callback = function(v) S.AutoServeDelay = v end
})

TabCombat:Section({Title = "Anti-Penalty & Fair Play Rules"})

UI_ELEMENTS.AntiDoubleHitGuard = TabCombat:Toggle({
    Title = "Anti-Double Hit Penalty Guard",
    Desc = "Strictly limits contact to 1x per possession, prevents consecutive hit faults (Zero penalties)",
    Value = S.AntiDoubleHitGuard,
    Callback = function(v) S.AntiDoubleHitGuard = v end
})

UI_ELEMENTS.MinHitCooldown = TabCombat:Slider({
    Title = "Minimum Hit Cooldown (Seconds)",
    Desc = "Minimum delay before player can hit again after teammate/opponent touch",
    Step = 0.05,
    Value = {Min = 0.2, Max = 1.5, Default = S.MinHitCooldown},
    Callback = function(v) S.MinHitCooldown = v end
})

TabCombat:Section({Title = "Hit Thresholds & Recovery"})

UI_ELEMENTS.SpikeHitRadius = TabCombat:Slider({
    Title = "Spike Reach Distance (Studs)",
    Desc = "Max distance to trigger spike (Default 13, Server max 20)",
    Step = 0.5,
    Value = {Min = 6, Max = 19, Default = S.SpikeHitRadius},
    Callback = function(v) S.SpikeHitRadius = v end
})

UI_ELEMENTS.VerticalBumpReach = TabCombat:Slider({
    Title = "Ground Bump Trigger Height",
    Desc = "Height above player to trigger receive (prevents swinging early)",
    Step = 0.5,
    Value = {Min = 4, Max = 12, Default = S.VerticalBumpReach},
    Callback = function(v) S.VerticalBumpReach = v end
})

TabCombat:Button({
    Title = "Instant Controller Unfreeze",
    Desc = "Resets IsBusy state if game ever freezes character moves",
    Callback = function()
        unfreezeController()
        notify("Controller", "IsBusy state reset to false!")
    end
})

-- TAB 2: Court Assist & Magnet
local TabCourt = Window:Tab({
    Title = "Court Assist",
    Icon = "compass"
})

TabCourt:Section({Title = "Smart Non-Intrusive Magnet"})

UI_ELEMENTS.AutoBallMagnet = TabCourt:Toggle({
    Title = "Auto Move to Ball Landing Spot",
    Desc = "Smoothly navigates to landing shadow (Never walks across net)",
    Value = S.AutoBallMagnet,
    Callback = function(v) S.AutoBallMagnet = v end
})

UI_ELEMENTS.MagnetMode = TabCourt:Dropdown({
    Title = "Magnet Navigation Mode",
    Desc = "Assist: Only walks when NOT pressing WASD (zero fighting controls); Force: Autonomous",
    Values = {"Assist", "Force"},
    Value = S.MagnetMode,
    Callback = function(v) S.MagnetMode = v end
})

UI_ELEMENTS.StayOnSide = TabCourt:Toggle({
    Title = "Strict Net Boundary Guard",
    Desc = "Prevents crossing net boundary line (Anti FootFault)",
    Value = S.StayOnSide,
    Callback = function(v) S.StayOnSide = v end
})

UI_ELEMENTS.IgnoreOutBalls = TabCourt:Toggle({
    Title = "Ignore Out-Of-Bounds Balls",
    Desc = "Doesn't chase balls landing outside court lines (Free Points!)",
    Value = S.IgnoreOutBalls,
    Callback = function(v) S.IgnoreOutBalls = v end
})

TabCourt:Button({
    Title = "Instant Dash to Ball Shadow (Hotkey / Click)",
    Desc = "Instantly positions character directly under the ball shadow",
    Callback = function()
        local shadow = getLandingIndicator()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if shadow and root then
            root.CFrame = CFrame.new(shadow.Position + Vector3.new(0, 3, 0))
            notify("Navigation", "Teleported to ball shadow!")
        end
    end
})

-- TAB 3: Visuals & Telemetry
local TabVisuals = Window:Tab({
    Title = "Visuals & HUD",
    Icon = "eye"
})

TabVisuals:Section({Title = "On-Screen Match Telemetry"})

UI_ELEMENTS.TacticalHUD = TabVisuals:Toggle({
    Title = "Tactical On-Screen Banner HUD",
    Desc = "Displays real-time point state, ball height, and live action recommendations",
    Value = S.TacticalHUD,
    Callback = function(v) S.TacticalHUD = v end
})

TabVisuals:Section({Title = "Ball 3D ESP"})

UI_ELEMENTS.BallHighlight = TabVisuals:Toggle({
    Title = "Ball 3D Highlight Cham",
    Desc = "Glowing outline visible through court geometry",
    Value = S.BallHighlight,
    Callback = function(v) S.BallHighlight = v end
})

UI_ELEMENTS.LandingCircleESP = TabVisuals:Toggle({
    Title = "Landing Zone Circle Marker",
    Desc = "Ground indicator (Cyan = Our side, Orange = Opponent side)",
    Value = S.LandingCircleESP,
    Callback = function(v) S.LandingCircleESP = v end
})

UI_ELEMENTS.BallTrajectoryTracer = TabVisuals:Toggle({
    Title = "Ball Trajectory 3D Tracer",
    Desc = "Dynamic beam connecting ball directly to landing position",
    Value = S.BallTrajectoryTracer,
    Callback = function(v) S.BallTrajectoryTracer = v end
})

-- TAB 4: Progression & Auto-Farm
local TabFarm = Window:Tab({
    Title = "Progression",
    Icon = "gift"
})

TabFarm:Section({Title = "Continuous Auto-Claim"})

UI_ELEMENTS.AutoClaimQuests = TabFarm:Toggle({
    Title = "Auto Claim Quests",
    Desc = "Periodically invokes QuestService:ClaimAll",
    Value = S.AutoClaimQuests,
    Callback = function(v) S.AutoClaimQuests = v end
})

UI_ELEMENTS.AutoClaimLevelRewards = TabFarm:Toggle({
    Title = "Auto Claim Level Rewards",
    Desc = "Periodically invokes LevelService:ClaimLevelRewards",
    Value = S.AutoClaimLevelRewards,
    Callback = function(v) S.AutoClaimLevelRewards = v end
})

UI_ELEMENTS.AutoClaimMastery = TabFarm:Toggle({
    Title = "Auto Claim Mastery",
    Desc = "Periodically invokes MasteryService:RequestClaim",
    Value = S.AutoClaimMastery,
    Callback = function(v) S.AutoClaimMastery = v end
})

UI_ELEMENTS.AutoClaimDailyPresents = TabFarm:Toggle({
    Title = "Auto Claim Season Presents",
    Desc = "Claims all 5 daily seasonal presents automatically",
    Value = S.AutoClaimDailyPresents,
    Callback = function(v) S.AutoClaimDailyPresents = v end
})

UI_ELEMENTS.AutoSellDuplicates = TabFarm:Toggle({
    Title = "Auto Sell Duplicate Items",
    Desc = "Liquidates duplicate cosmetic balls for currency",
    Value = S.AutoSellDuplicates,
    Callback = function(v) S.AutoSellDuplicates = v end
})

TabFarm:Button({
    Title = "Claim Everything Once",
    Desc = "Executes all claim remotes simultaneously right now",
    Callback = function()
        pcall(function()
            if QuestService and QuestService.ClaimAll then QuestService:ClaimAll():await() end
            if LevelService and LevelService.ClaimLevelRewards then LevelService:ClaimLevelRewards():await() end
            if MasteryService and MasteryService.RequestClaim then MasteryService:RequestClaim():await() end
            if InventoryService and InventoryService.SellDuplicates then InventoryService:SellDuplicates():await() end
            if DailyRewardService and DailyRewardService.AwardDailyReward then DailyRewardService:AwardDailyReward():await() end
            if SeasonService and SeasonService.ClaimDailyPresent then
                for i = 1, 5 do SeasonService:ClaimDailyPresent(i):await() end
            end
        end)
        notify("Progression", "All claimable rewards requested from server!")
    end
})

TabFarm:Button({
    Title = "Batch Redeem All Known Codes",
    Desc = "Iterates and redeems all verified promo codes",
    Callback = function()
        if CodeService and CodeService.Redeem then
            for _, code in ipairs(KNOWN_CODES) do
                pcall(function()
                    CodeService:Redeem(code):await()
                    task.wait(0.25)
                end)
            end
            notify("Codes", "Batch redeem execution complete!")
        end
    end
})

-- TAB 5: Gacha & Auto-Roll
local TabGacha = Window:Tab({
    Title = "Gacha & Rolls",
    Icon = "sparkles"
})

TabGacha:Section({Title = "Style Rolling Engine (83 Styles)"})

UI_ELEMENTS.AutoRollStyle = TabGacha:Toggle({
    Title = "Auto Roll Styles",
    Desc = "Loops style spins until target is obtained",
    Value = S.AutoRollStyle,
    Callback = function(v) S.AutoRollStyle = v end
})

UI_ELEMENTS.LuckyStyle = TabGacha:Toggle({
    Title = "Use Lucky Spins (Style)",
    Desc = "Consumes lucky spins for increased probability",
    Value = S.LuckyStyle,
    Callback = function(v) S.LuckyStyle = v end
})

UI_ELEMENTS.StopOnStyleName = TabGacha:Dropdown({
    Title = "Target Style (Stop Condition)",
    Desc = "Automatically stops and locks slot upon obtaining this style",
    Values = ALL_STYLES,
    Value = S.StopOnStyleName,
    Callback = function(v) S.StopOnStyleName = v end
})

TabGacha:Section({Title = "Ability Rolling Engine (14 Abilities)"})

UI_ELEMENTS.AutoRollAbility = TabGacha:Toggle({
    Title = "Auto Roll Abilities",
    Desc = "Loops ability spins until target is obtained",
    Value = S.AutoRollAbility,
    Callback = function(v) S.AutoRollAbility = v end
})

UI_ELEMENTS.LuckyAbility = TabGacha:Toggle({
    Title = "Use Lucky Spins (Ability)",
    Desc = "Consumes lucky spins for ability rolls",
    Value = S.LuckyAbility,
    Callback = function(v) S.LuckyAbility = v end
})

UI_ELEMENTS.StopOnAbilityName = TabGacha:Dropdown({
    Title = "Target Ability (Stop Condition)",
    Desc = "Stops upon rolling selected ability",
    Values = ALL_ABILITIES,
    Value = S.StopOnAbilityName,
    Callback = function(v) S.StopOnAbilityName = v end
})

TabGacha:Section({Title = "Crate & Pack Openers"})

UI_ELEMENTS.SelectedCrate = TabGacha:Dropdown({
    Title = "Select Crate",
    Desc = "Choose crate type to open",
    Values = ALL_CRATES,
    Value = S.SelectedCrate,
    Callback = function(v) S.SelectedCrate = v end
})

UI_ELEMENTS.AutoOpenCrates = TabGacha:Toggle({
    Title = "Auto Open Selected Crate",
    Desc = "Continuously opens chosen crate type",
    Value = S.AutoOpenCrates,
    Callback = function(v) S.AutoOpenCrates = v end
})

-- TAB 6: Arena & Practice
local TabArena = Window:Tab({
    Title = "Arena & Bot",
    Icon = "activity"
})

TabArena:Section({Title = "Practice Court & Bot"})

TabArena:Button({
    Title = "Join Training Court",
    Desc = "Teleports character into private practice court",
    Callback = function()
        if GameService and GameService.JoinTrainingGamemode then
            pcall(function() GameService:JoinTrainingGamemode():await() end)
            notify("Arena", "Teleporting to Training Gamemode...")
        end
    end
})

TabArena:Button({
    Title = "Return to Lobby",
    Desc = "Returns player character to main lobby area",
    Callback = function()
        if GameService and GameService.ReturnToLobby then
            pcall(function() GameService:ReturnToLobby():await() end)
            notify("Arena", "Returning to Lobby...")
        end
    end
})

UI_ELEMENTS.LoopSpawnBall = TabArena:Toggle({
    Title = "Continuous Practice Ball Stream",
    Desc = "Spawns new practice balls automatically when none exist",
    Value = S.LoopSpawnBall,
    Callback = function(v) S.LoopSpawnBall = v end
})

TabArena:Button({
    Title = "Toggle Practice Bot (ON/OFF)",
    Desc = "Spawns or despawns practice AI bot",
    Callback = function()
        if BotService and BotService.SetBot then
            pcall(function() BotService:SetBot(true):await() end)
            notify("Bot Service", "Bot status updated!")
        end
    end
})

UI_ELEMENTS.BotDifficulty = TabArena:Dropdown({
    Title = "Bot Difficulty Level",
    Desc = "Sets AI bot difficulty",
    Values = {"Easy", "Normal", "Hard", "Extreme"},
    Value = S.BotDifficulty,
    Callback = function(v)
        S.BotDifficulty = v
        if BotService and BotService.ChangeBotDifficulty then
            pcall(function() BotService:ChangeBotDifficulty(v):await() end)
            notify("Bot Service", "Bot difficulty set to " .. v)
        end
    end
})

-- TAB 7: Player & Physics
local TabPlayer = Window:Tab({
    Title = "Player",
    Icon = "user"
})

TabPlayer:Section({Title = "Movement Modifiers"})

UI_ELEMENTS.CustomSpeed = TabPlayer:Toggle({
    Title = "Enable Custom WalkSpeed",
    Desc = "Overrides default movement speed",
    Value = S.CustomSpeed,
    Callback = function(v)
        S.CustomSpeed = v
        if not v then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

UI_ELEMENTS.WalkSpeed = TabPlayer:Slider({
    Title = "WalkSpeed Value",
    Desc = "Character movement speed rate",
    Step = 1,
    Value = {Min = 16, Max = 100, Default = S.WalkSpeed},
    Callback = function(v) S.WalkSpeed = v end
})

UI_ELEMENTS.CustomJump = TabPlayer:Toggle({
    Title = "Enable Custom JumpPower",
    Desc = "Overrides default jump height",
    Value = S.CustomJump,
    Callback = function(v)
        S.CustomJump = v
        if not v then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
})

UI_ELEMENTS.JumpPower = TabPlayer:Slider({
    Title = "JumpPower Value",
    Desc = "Character jump power magnitude",
    Step = 1,
    Value = {Min = 50, Max = 200, Default = S.JumpPower},
    Callback = function(v) S.JumpPower = v end
})

UI_ELEMENTS.InfiniteJump = TabPlayer:Toggle({
    Title = "Infinite Air Jump",
    Desc = "Allows jumping repeatedly in mid-air",
    Value = S.InfiniteJump,
    Callback = function(v) S.InfiniteJump = v end
})

UI_ELEMENTS.NoClip = TabPlayer:Toggle({
    Title = "NoClip (Pass through Net/Players)",
    Desc = "Disables character collision physics",
    Value = S.NoClip,
    Callback = function(v) S.NoClip = v end
})

UI_ELEMENTS.AntiAFK = TabPlayer:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Simulates user input to prevent 20-minute idle disconnect",
    Value = S.AntiAFK,
    Callback = function(v) S.AntiAFK = v end
})

-- TAB 8: Settings & Persistence
local TabSettings = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

TabSettings:Section({Title = "Configuration"})

TabSettings:Button({
    Title = "Save Preferences to File",
    Desc = "Writes all current options to " .. CONFIG_FILE,
    Callback = saveConfig
})

TabSettings:Button({
    Title = "Reload Saved Preferences",
    Desc = "Restores all settings from " .. CONFIG_FILE,
    Callback = loadConfig
})

TabSettings:Section({Title = "Engine Lifecycle"})

TabSettings:Button({
    Title = "Clean Unload Engine",
    Desc = "Gracefully stops all background loops, disconnects hooks, and destroys UI",
    Callback = function()
        if genv.__VOLLEYBALL_OP and genv.__VOLLEYBALL_OP.Stop then
            genv.__VOLLEYBALL_OP.Stop()
        end
    end
})

-- ==============================================================================
-- 12. DRAGGABLE FLOATING TOGGLE BUTTON (MOBILE & CONVENIENCE)
-- ==============================================================================
local floatScreenGui = Instance.new("ScreenGui")
floatScreenGui.Name = "VolleyballLegends_FloatingBtn"
floatScreenGui.ResetOnSpawn = false
floatScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(floatScreenGui) end
end)
pcall(function()
    floatScreenGui.Parent = getSafeGuiRoot()
end)

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "TogglePill"
floatBtn.Size = UDim2.fromOffset(48, 48)
floatBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
floatBtn.BorderColor3 = Color3.fromRGB(0, 180, 255)
floatBtn.BorderSizePixel = 2
floatBtn.AutoButtonColor = false
floatBtn.Image = "rbxassetid://10723415903"
floatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Parent = floatScreenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(1, 0)
uicorner.Parent = floatBtn

local uistroke = Instance.new("UIStroke")
uistroke.Color = Color3.fromRGB(0, 180, 255)
uistroke.Thickness = 2
uistroke.Transparency = 0.2
uistroke.Parent = floatBtn

-- Dragging Mechanics
local dragging, dragInput, dragStart, startPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = floatBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

floatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if Window and Window.Toggle then
            Window:Toggle()
        end
    end)
end)

-- Global Keybind (RightControl)
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        pcall(function()
            if Window and Window.Toggle then
                Window:Toggle()
            end
        end)
    end
end))

-- Hotkey: Instant Teleport-Spike (C key)
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.C then
        local ball = getActiveBall()
        if not canPerformHit("Spike", false, ball) then
            notify("Penalty Guard", "Double-hit blocked! Wait for teammate/opponent touch.", 1.5)
            return
        end
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if ball and root then
            local ballPos = ball:GetPivot().Position
            local side = getPlayerTeamSide()
            local oppPos = getOpponentTargetPosition()
            local attackZ = (side == -1) and (ballPos.Z - 1.8) or (ballPos.Z + 1.8)
            local attackPos = Vector3.new(ballPos.X, ballPos.Y - 1.0, attackZ)

            root.CFrame = CFrame.lookAt(attackPos, Vector3.new(oppPos.X, attackPos.Y, oppPos.Z))
            ensureAirborne(120)
            task.wait(0.04)
            executeHit("Spike", true, ball)
            notify("Combat", "Instant Teleport-Spike executed!", 1.5)
        end
    end
end))

-- Hotkey: Instant Teleport-Block at Net (X key)
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.X then
        local ball = getActiveBall()
        if not canPerformHit("Block", false, ball) then
            notify("Penalty Guard", "Double-hit blocked! Wait for teammate/opponent touch.", 1.5)
            return
        end
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if ball and root then
            local ballPos = ball:GetPivot().Position
            local floorY = getStandingFloorY()
            local netZ = getActiveNetZ()
            local side = getPlayerTeamSide()
            local blockZ = (side == -1) and (netZ - 2.2) or (netZ + 2.2)
            local blockX = math.clamp(ballPos.X, CourtData.CourtX_Min + 2, CourtData.CourtX_Max - 2)
            local blockPos = Vector3.new(blockX, floorY + 2.7, blockZ)

            root.CFrame = CFrame.lookAt(blockPos, Vector3.new(blockX, blockPos.Y, (side == -1) and (netZ + 25) or (netZ - 25)))
            ensureAirborne(125)
            task.wait(0.04)
            executeHit("Block", true, ball)
            notify("Combat", "Instant Net Block executed!", 1.5)
        end
    end
end))

-- Hotkey: Dash / Teleport to Ball Shadow (V key)
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.V then
        local shadow = getLandingIndicator()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if shadow and root then
            root.CFrame = CFrame.new(shadow.Position + Vector3.new(0, 3, 0))
            notify("Navigation", "Teleported to ball landing zone!", 1.5)
        end
    end
end))

-- Hotkey: Instant Teleport-Bump Save (B key)
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.B then
        local ball = getActiveBall()
        if not canPerformHit("Bump", false, ball) then
            notify("Penalty Guard", "Double-hit blocked! Wait for teammate/opponent touch.", 1.5)
            return
        end
        local shadow = getLandingIndicator()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if ball and root then
            local shadowPos = shadow and shadow.Position or ball:GetPivot().Position
            local floorY = getStandingFloorY()
            local oppPos = getOpponentTargetPosition()
            local receivePos = Vector3.new(shadowPos.X, floorY + 2.7, shadowPos.Z)

            root.CFrame = CFrame.lookAt(receivePos, Vector3.new(oppPos.X, receivePos.Y, oppPos.Z))
            enforceMaxPower()
            executeHit("Bump", false, ball)
            notify("Combat", "Instant Teleport-Bump executed!", 1.5)
        end
    end
end))

-- ==============================================================================
-- 13. MUTEX EXPORT & INITIALIZATION
-- ==============================================================================
local function stopEngine()
    isAutomationRunning = false
    for _, conn in ipairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    cleanupESP()
    pcall(function() if hudGui then hudGui:Destroy() end end)
    pcall(function() if floatScreenGui then floatScreenGui:Destroy() end end)
    pcall(function()
        local rgui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if rgui then
            for _, c in ipairs(rgui:GetChildren()) do
                if c.Name:find("WindUI") then pcall(function() c:Destroy() end) end
            end
        end
    end)
    notify("Volleyball Legends OP", "Engine gracefully stopped and unloaded.")
end

genv.__VOLLEYBALL_OP = {
    Stop = stopEngine,
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,
    Window = Window,
    WindUI = WindUI,
    FloatGui = floatScreenGui,
    HUD = hudGui
}

Window:SelectTab(1)
WindUI:Notify({
    Title = "FLa ProjecT: Volleyball Legends",
    Content = "v3.0 Pro Master Engine loaded. Predictive Apex Spike, Match Auto-Serve & HUD Active!",
    Duration = 5.0
})

print("[FLa ProjecT] Volleyball Legends ClientOP v3.0 initialized successfully.")
