-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    BloxStrike Tactical Automation Engine (V2 - High Performance Native Kernel)
    Place ID: 114234929420007 | Universe: 7633926880
    Architecture: Custom Client Engine (Real) + WindUI Framework
    Defaults: ALL MODULES DEFAULT TO FALSE / OFF (Manual Activation / Configuration Load)

    Feature Set:
      - Native VIP ESP Integration (Zero Render Overhead)
      - Multi-Target 3D Participant Billboard & Highlight ESP
      - Planted C4 Bomb Tracking & Countdown ESP
      - Zombie Horde Stream ESP (Survival Gamemode)
      - True Camera & Weapon Recoil Elimination (CameraController.weaponKick & setWeaponRecoil)
      - True In-Flight Bullet Dispersion Zeroing (BulletClass._performRaycast)
      - Native Mouse-Relative Aimbot (mousemoverel Input Pipeline with Smoothing)
      - Native Crosshair Triggerbot (mouse1press / mouse1release with Micro-Delay)
      - Source Movement Simulation Engine Hook (RuntimeSettings.getMovementConfig)
      - C4 Automated Defusal & Zombie Survival Automation
      - 1-Click Tactical Teleports (Site A, Site B, CT Spawn, T Spawn)
      - Complete Config Persistence & 100% Visual State Synchronization
--]]

if _G.BloxStrikeEngine and _G.BloxStrikeEngine.Unload then
    pcall(function() _G.BloxStrikeEngine:Unload() end)
end

-- Clean any existing WindUI ScreenGuis
pcall(function()
    local hui = (gethui and gethui()) or game:GetService("CoreGui")
    if hui then
        for _, c in ipairs(hui:GetChildren()) do
            if c:IsA("ScreenGui") and c.Name:find("WindUI") then
                c:Destroy()
            end
        end
    end
end)

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")

-- Core Controllers & Modules
local Participants = require(ReplicatedStorage.Components.Common.Participants)
local AimAssistController = require(ReplicatedStorage.Controllers.AimAssistController)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local InventoryController = require(ReplicatedStorage.Controllers.InventoryController)
local FireAction = require(ReplicatedStorage.Controllers.InputController.Actions.Fire)
local SimConfig = require(ReplicatedStorage.MovementV2.Simulation.Config)
local SpeedProfile = require(ReplicatedStorage.MovementV2.SpeedProfile)
local RuntimeSettings = require(ReplicatedStorage.MovementV2.Simulation.RuntimeSettings)
local Remotes = require(ReplicatedStorage.Database.Security.Remotes)
local Constants = require(ReplicatedStorage.Database.Custom.Constants)
local BulletClass = require(ReplicatedStorage.Components.Weapon.Classes.Bullet)

-- Safe sub-controller requires
local SurvivalDownedController = nil
pcall(function()
    SurvivalDownedController = require(ReplicatedStorage.Controllers.SurvivalDownedController)
end)

local CandyController = nil
pcall(function()
    CandyController = require(ReplicatedStorage.Controllers.CandyController)
end)

local HordeProtocol = nil
pcall(function()
    HordeProtocol = require(ReplicatedStorage.Components.Common.HordeProtocol)
end)

-- 60+ FPS Realtime FarThrottle Animation & Presentation Detours
local FarThrottle = nil
pcall(function()
    FarThrottle = require(ReplicatedStorage.Components.Common.FarThrottle)
end)
local OrigFarThrottleSkips = FarThrottle and FarThrottle.Skips
if FarThrottle then
    pcall(function()
        FarThrottle.Skips = function()
            return false
        end
    end)
end

-- Clear any spoofed VIP economy attributes that cause $0 buy menu rejection
workspace:SetAttribute("VIPInfiniteCashEnabled", nil)
workspace:SetAttribute("VIPInfiniteAmmoEnabled", nil)

-- Ensure all weapon schema tables remain strictly frozen (neutralizing anti-tamper while true do end trap)
pcall(function()
    local wf = ReplicatedStorage.Database.Custom:FindFirstChild("Weapons")
    if wf then
        for _, c in ipairs(wf:GetChildren()) do
            if c:IsA("ModuleScript") then
                local ok, data = pcall(require, c)
                if ok and typeof(data) == "table" then
                    if typeof(data.Spread) == "table" then
                        pcall(table.freeze, data.Spread)
                        pcall(setreadonly, data.Spread, true)
                    end
                    if typeof(data.Recoil) == "table" then
                        pcall(table.freeze, data.Recoil)
                        pcall(setreadonly, data.Recoil, true)
                    end
                    pcall(table.freeze, data)
                    pcall(setreadonly, data, true)
                end
            end
        end
    end
end)

-- Store Original States for Clean Reversion
local OrigSim = {
    AutoBunnyHop = SimConfig.Default.AutoBunnyHop,
    AirAccelerate = SimConfig.Default.AirAccelerate,
    DefaultBaseMoveSpeed = SimConfig.Default.DefaultBaseMoveSpeed,
    MaxBaseMoveSpeed = SimConfig.Default.MaxBaseMoveSpeed,
    MaxSpeed = SimConfig.Default.MaxSpeed,
    BunnyHopPenaltyBase = SimConfig.Default.BunnyHopPenaltyBase,
    BunnyHopPenaltyScale = SimConfig.Default.BunnyHopPenaltyScale,
}

local OrigSpeedProfile = {
    DefaultBaseSpeed = SpeedProfile.DefaultBaseSpeed,
    TopSpeed = SpeedProfile.TopSpeed,
    SprintSpeed = SpeedProfile.SprintSpeed,
}

local OrigWeaponKick = CameraController.weaponKick
local OrigSetWeaponRecoil = CameraController.setWeaponRecoil
local OrigGetWeaponKickRotation = CameraController.getWeaponKickRotation
local OrigPerformRaycast = BulletClass._performRaycast
local OrigGetTrueSpread = BulletClass.getTrueSpread
local OrigGetMovementConfig = RuntimeSettings.getMovementConfig
local OrigRecoilHook = AimAssistController.GetRecoilAssistScale
local OrigMagnetismRotation = AimAssistController.GetMagnetismRotation
local OrigUpdateCamera = CameraController.updateCamera
pcall(function()
    AimAssistController.GetMagnetismRotation = function(...)
        if Engine and Engine.Config and Engine.Config.Aimbot then
            return Vector2.zero
        end
        if OrigMagnetismRotation then
            return OrigMagnetismRotation(...)
        end
        return Vector2.zero
    end
end)

-- Engine Definition
local Engine = {
    Connections = {},
    ESPObjects = {},
    Drawings = {},
    GuiInstances = {},
    UIElements = {},
    State = {
        UIVisible = true,
        TriggerbotFiring = false,
        AimbotActive = false,
        AimbotTarget = nil,
        LastCandyVacuumTick = 0,
        LastReviveTick = 0,
        LastDefuseTick = 0,
        LastThrottleTick = 0,
    },
    Config = {
        -- Combat
        NativeVIPESP = false,
        NoRecoil = false,
        NoSpread = false,
        Triggerbot = false,
        TriggerbotDelay = 30,
        AimAssistBoost = false,
        Aimbot = false,
        AimbotKey = "Auto / In FOV",
        AimbotAutoShoot = false,
        AimbotFOV = 120,
        AimbotSmooth = 6,
        AimbotTargetPart = "Head",
        AimbotPriority = "Crosshair",
        AimbotVisibleOnly = true,
        ShowFOVCircle = false,

        -- Visuals
        PlayerESP = false,
        PlayerESPBoxes = true,
        PlayerESPNames = true,
        PlayerESPHealth = true,
        PlayerESPWeapon = true,
        PlayerESPDistance = true,
        PlayerTracers = false,
        BombESP = false,
        HordeESP = false,

        -- Movement
        AutoBunnyHop = false,
        CustomSpeed = false,
        SpeedValue = 26,
        AirStrafeBoost = false,
        InfiniteJump = false,

        -- Automation
        AutoDefuse = false,
        AutoVacuumCandy = false,
        AutoRevive = false,
    }
}

--[[ 1. HELPER & UTILITY FUNCTIONS ]]--

local function GetLocalRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local LastKnownMyTeam = "Terrorists"

local function GetResolvedTeam(pOrChar)
    if not pOrChar then return nil end
    local team = pOrChar:GetAttribute("Team")
    if team and team ~= "" then return team end

    local charName = pOrChar:GetAttribute("PresentationCharacterName")
    if charName then
        if charName:find("Anarchist") or charName:find("Phoenix") or charName:find("Balkan") or charName:find("Separatist") or charName:find("Leet") or charName:find("Pirate") then
            return "Terrorists"
        elseif charName:find("IDF") or charName:find("SAS") or charName:find("GIGN") or charName:find("FBI") or charName:find("SWAT") or charName:find("GSG") or charName:find("SEAL") then
            return "Counter-Terrorists"
        end
    end

    local slot3 = pOrChar:GetAttribute("Slot3")
    if slot3 and typeof(slot3) == "string" then
        if slot3:find("T Knife") then return "Terrorists" end
        if slot3:find("CT Knife") then return "Counter-Terrorists" end
    end

    -- Model resolution fallback
    local char = (pOrChar:IsA("Player") and pOrChar.Character) or (pOrChar:IsA("Model") and pOrChar) or (Participants.Character and pOrChar.Parent and Participants.Character(pOrChar))
    if char and char ~= pOrChar then
        local cTeam = char:GetAttribute("Team")
        if cTeam and cTeam ~= "" then return cTeam end
        local cName = char:GetAttribute("PresentationCharacterName")
        if cName then
            if cName:find("Anarchist") or cName:find("Phoenix") or cName:find("Balkan") or cName:find("Separatist") or cName:find("Leet") or cName:find("Pirate") then
                return "Terrorists"
            elseif cName:find("IDF") or cName:find("SAS") or cName:find("GIGN") or cName:find("FBI") or cName:find("SWAT") or cName:find("GSG") or cName:find("SEAL") then
                return "Counter-Terrorists"
            end
        end
    end

    return nil
end

local function GetMyTeam()
    local t = GetResolvedTeam(LocalPlayer)
    if t then
        LastKnownMyTeam = t
        return t
    end
    return LastKnownMyTeam
end

local function IsEnemy(p, c)
    if not p and not c then return false end
    if p == LocalPlayer or c == LocalPlayer.Character then return false end

    -- Check if dead
    if p and not Participants.IsAlive(p) then return false end
    if c and c:GetAttribute("Dead") == true then return false end

    local gamemode = Workspace:GetAttribute("Gamemode")
    if gamemode == "Deathmatch" then return true end

    local myTeam = GetMyTeam()
    local theirTeam = (p and GetResolvedTeam(p)) or (c and GetResolvedTeam(c))

    if not theirTeam then
        return false -- Safe default: never target unverified/teammate
    end

    return myTeam ~= theirTeam
end

-- Synchronizes presentation state: Keeps live enemies in Workspace for wallhack rendering, and purges corpses
local function SyncAliveEnemyPresentation()
    local culledFolder = ReplicatedStorage:FindFirstChild("_PVS_CulledCharacters")
    local charsFolder = Workspace:FindFirstChild("Characters") or Workspace
    if not charsFolder then return end

    local myTeam = Engine.State.LastKnownMyTeam
    for _, p in ipairs(Participants.GetAll()) do
        local isDead = p:GetAttribute("Dead") == true
            or p:GetAttribute("IsSpectating") == true
            or (p:GetAttribute("Health") ~= nil and p:GetAttribute("Health") <= 0)

        local c = Participants.Character(p)
        if c and c:IsA("Model") then
            if not isDead and IsEnemy(p, c) then
                -- LIVE ENEMY: Force model into Workspace so Highlight & Billboard render through walls with AlwaysOnTop
                if c.Parent ~= charsFolder then
                    c.Parent = charsFolder
                end
            elseif isDead and culledFolder then
                -- DEAD CORPSE: Send into culled storage so dead bodies never clutter workspace or show fake ESP
                if c.Parent == charsFolder then
                    c.Parent = culledFolder
                end
            end
        end
    end
end

-- Full-Map Through-Wall Alive Enemy Resolver (Wallhack Active, Zero Ghost Clones)
local function GetEnemyCharacters()
    local list = {}
    local seen = {}
    local charsFolder = Workspace:FindFirstChild("Characters") or Workspace

    pcall(function()
        for _, p in ipairs(Participants.GetAll()) do
            -- 1. Strictly require ALIVE participant
            local isDead = p:GetAttribute("Dead") == true
                or p:GetAttribute("IsSpectating") == true
                or (p:GetAttribute("Health") ~= nil and p:GetAttribute("Health") <= 0)

            if not isDead and IsEnemy(p, nil) then
                local c = Participants.Character(p)
                if c and c:IsA("Model") then
                    -- Uncull to Workspace so Highlights/Billboards are rendered by Roblox
                    if c.Parent ~= charsFolder then
                        c.Parent = charsFolder
                    end
                    local root = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")
                    if root then
                        -- Filter out lobby/dead spawn coordinates (0, 140, 0)
                        if (root.Position - Vector3.new(0, 140, 0)).Magnitude > 15 then
                            seen[c] = true
                            table.insert(list, {
                                Participant = p,
                                Character = c,
                                Root = root,
                                Head = c:FindFirstChild("Head") or root,
                                Health = p:GetAttribute("Health") or 100,
                                Team = p:GetAttribute("Team") or GetResolvedTeam(c) or "Enemy",
                            })
                        end
                    end
                end
            elseif p then
                local c = Participants.Character(p)
                if c then seen[c] = true end
            end
        end
    end)

    return list
end

local function IsVisible(targetPart, originPos)
    if not targetPart then return false end
    local cam = Workspace.CurrentCamera or CurrentCamera
    local origin = originPos or cam.CFrame.Position
    local target = targetPart.Position
    local dir = target - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local ignoreList = {cam}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    local pvs = Workspace:FindFirstChild("_PVS_CulledCharacters")
    if pvs then table.insert(ignoreList, pvs) end
    local debris = Workspace:FindFirstChild("Debris")
    if debris then table.insert(ignoreList, debris) end
    local map = Workspace:FindFirstChild("Map")
    local barriers = map and map:FindFirstChild("Barriers")
    if barriers then table.insert(ignoreList, barriers) end

    params.FilterDescendantsInstances = ignoreList

    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

--[[ 2. DRAWING OBJECTS ]]--

local FOVCircle = nil
if Drawing and Drawing.new then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(0, 255, 170)
        FOVCircle.Thickness = 1.5
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.8
        FOVCircle.NumSides = 64
        FOVCircle.Visible = false
        table.insert(Engine.Drawings, FOVCircle)
    end)
end

local function UpdateFOVCircle()
    if not FOVCircle then return end
    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return end
    if Engine.Config.ShowFOVCircle and (Engine.Config.Aimbot or Engine.Config.Triggerbot) then
        local vp = cam.ViewportSize
        FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        FOVCircle.Radius = Engine.Config.AimbotFOV
        if Engine.State.AimbotTarget then
            FOVCircle.Color = Color3.fromRGB(255, 60, 60)
        else
            FOVCircle.Color = Color3.fromRGB(0, 255, 170)
        end
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

--[[ 3. COMBAT ENHANCEMENTS ]]--

-- True Camera Kick & Weapon Recoil Detour
pcall(function()
    CameraController.weaponKick = function(a1, a2)
        if Engine.Config.NoRecoil then
            return
        end
        return OrigWeaponKick(a1, a2)
    end

    CameraController.setWeaponRecoil = function(a1, a2)
        if Engine.Config.NoRecoil then
            CameraController.resetWeaponRecoil()
            return
        end
        return OrigSetWeaponRecoil(a1, a2)
    end

    CameraController.getWeaponKickRotation = function()
        if Engine.Config.NoRecoil then
            return Vector3.zero
        end
        return OrigGetWeaponKickRotation()
    end

    if OrigUpdateCamera then
        CameraController.updateCamera = function(a1)
            if Engine.Config.NoRecoil or (Engine.Config.Aimbot and Engine.State.AimbotActive) then
                local cam = Workspace.CurrentCamera or CurrentCamera
                local cleanBase = cam and cam.CFrame or a1
                return OrigUpdateCamera(cleanBase)
            end
            return OrigUpdateCamera(a1)
        end
    end
end)

-- True Laser Accuracy & In-Flight Bullet Dispersion Zeroing
pcall(function()
    BulletClass._performRaycast = function(self, spreadAngle, ...)
        if Engine.Config.NoSpread then
            spreadAngle = 0
        end
        return OrigPerformRaycast(self, spreadAngle, ...)
    end

    BulletClass.getTrueSpread = function(self, ...)
        if Engine.Config.NoSpread then
            return 0
        end
        return OrigGetTrueSpread(self, ...)
    end
end)

-- Aim Assist Parameters Tuning (Native Controller Fallback)
local function ApplyAimAssistBoost(enable)
    local cfg = Constants and Constants.AIM_ASSIST_CONFIGS and Constants.AIM_ASSIST_CONFIGS.PLAYER
    if not cfg then return end
    pcall(function()
        setreadonly(cfg, false)
        if enable then
            cfg.PullAngle = 0.5
            cfg.TrackingStrength = 0.95
            cfg.PullRate = 8.0
            cfg.MaxPullSpeed = 1.5
        else
            cfg.PullAngle = 0.17453292519943295
            cfg.TrackingStrength = 0.55
            cfg.PullRate = 3.2
            cfg.MaxPullSpeed = 0.5235987755982988
        end
    end)
end

-- Unified High-Performance Weapon Fire Dispatcher
local function TriggerWeaponFire()
    if Engine.State.TriggerbotFiring then return end
    Engine.State.TriggerbotFiring = true
    task.spawn(function()
        local delayMs = math.max(0.025, (Engine.Config.TriggerbotDelay or 30) / 1000)
        if mouse1press and mouse1release then
            mouse1press()
            task.wait(delayMs)
            mouse1release()
        else
            local dummyInput = { UserInputType = Enum.UserInputType.MouseButton1 }
            pcall(function()
                FireAction.Callback(Enum.UserInputState.Begin, dummyInput)
            end)
            task.wait(delayMs)
            pcall(function()
                FireAction.Callback(Enum.UserInputState.End, dummyInput)
            end)
        end
        task.wait(0.04)
        Engine.State.TriggerbotFiring = false
    end)
end

-- Triggerbot Execution Logic
local function RunTriggerbot()
    if not Engine.Config.Triggerbot or Engine.State.TriggerbotFiring then return end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return end

    local rayOrigin = cam.CFrame.Position
    local rayDir = cam.CFrame.LookVector * 1000

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local ignore = {cam}
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    local pvs = Workspace:FindFirstChild("_PVS_CulledCharacters")
    if pvs then table.insert(ignore, pvs) end
    local map = Workspace:FindFirstChild("Map")
    local barriers = map and map:FindFirstChild("Barriers")
    if barriers then table.insert(ignore, barriers) end
    params.FilterDescendantsInstances = ignore

    local hit = Workspace:Raycast(rayOrigin, rayDir, params)
    if hit and hit.Instance then
        local hitPart = hit.Instance
        local hitChar = hitPart:FindFirstAncestorOfClass("Model")
        if hitChar then
            local isTargetEnemy = false
            for _, entry in ipairs(GetEnemyCharacters()) do
                if entry.Character == hitChar then
                    isTargetEnemy = true
                    break
                end
            end

            if isTargetEnemy then
                TriggerWeaponFire()
            end
        end
    end
end

-- Aimbot Target Resolution & Smooth Tracking
local function GetBestAimbotTarget()
    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return nil, nil end

    local vp = cam.ViewportSize
    local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestTarget = nil
    local bestEntry = nil
    local bestScore = math.huge

    for _, entry in ipairs(GetEnemyCharacters()) do
        local targetPart = (Engine.Config.AimbotTargetPart == "Head") and entry.Head or entry.Root
        if targetPart then
            local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
            if onScreen and screenPos.Z > 0 then
                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if screenDist <= Engine.Config.AimbotFOV then
                    if not Engine.Config.AimbotVisibleOnly or IsVisible(targetPart, cam.CFrame.Position) then
                        local score = screenDist
                        if Engine.Config.AimbotPriority == "Distance" then
                            score = (targetPart.Position - cam.CFrame.Position).Magnitude
                        elseif Engine.Config.AimbotPriority == "Lowest HP" then
                            score = entry.Health
                        end

                        if score < bestScore then
                            bestScore = score
                            bestTarget = targetPart
                            bestEntry = entry
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestEntry
end

local function RunAimbotStep()
    if not Engine.Config.Aimbot then
        Engine.State.AimbotActive = false
        Engine.State.AimbotTarget = nil
        return
    end

    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return end

    local targetPart, targetEntry = GetBestAimbotTarget()
    Engine.State.AimbotTarget = targetPart

    local key = Engine.Config.AimbotKey or "Auto / In FOV"
    local isAiming = false
    if key == "Auto / In FOV" or key == "Always On" or key == "Always" then
        isAiming = (targetPart ~= nil)
    elseif key == "LMB" then
        isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "RMB" then
        isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "LMB + RMB" or key == "Both" then
        isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end

    Engine.State.AimbotActive = isAiming

    if not isAiming or not targetPart then return end

    local currentCF = cam.CFrame
    local targetDir = (targetPart.Position - currentCF.Position).Unit
    local targetLookCF = CFrame.lookAt(currentCF.Position, currentCF.Position + targetDir, Vector3.yAxis)

    local smooth = math.clamp(Engine.Config.AimbotSmooth, 1, 30)
    local alpha = math.clamp(1 / smooth, 0.04, 1.0)

    -- Smooth monotonic interpolation towards target with zero overshooting & zero roll
    local lerpedCF = currentCF:Lerp(targetLookCF, alpha)
    cam.CFrame = lerpedCF
    if CameraController and CameraController.setBaseCameraCFrame then
        pcall(function()
            CameraController.setBaseCameraCFrame(lerpedCF)
        end)
    end

    -- Auto-Shoot on Lock Alignment within FOV
    if Engine.Config.AimbotAutoShoot then
        local vp = cam.ViewportSize
        local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)
        local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
        if onScreen and screenPos.Z > 0 then
            local distToCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            local lockThreshold = math.clamp(Engine.Config.AimbotFOV * 0.35, 18, 45)
            if distToCrosshair <= lockThreshold then
                TriggerWeaponFire()
            end
        end
    end
end

--[[ 4. VISUALS & ESP SYSTEM ]]--

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "BloxStrike_ESP"
pcall(function()
    local cam = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")
    ESPFolder.Parent = cam or Workspace
end)

local function ClearAllESP()
    for _, obj in pairs(Engine.ESPObjects) do
        if typeof(obj) == "Instance" and obj.Parent then
            pcall(function() obj:Destroy() end)
        elseif typeof(obj) == "table" then
            if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
            if obj.Billboard then pcall(function() obj.Billboard:Destroy() end) end
            if obj.Box and obj.Box.Remove then pcall(function() obj.Box:Remove() end) end
            if obj.BoxOutline and obj.BoxOutline.Remove then pcall(function() obj.BoxOutline:Remove() end) end
            if obj.HealthBar and obj.HealthBar.Remove then pcall(function() obj.HealthBar:Remove() end) end
            if obj.HealthBarBg and obj.HealthBarBg.Remove then pcall(function() obj.HealthBarBg:Remove() end) end
            if obj.Tracer and obj.Tracer.Remove then pcall(function() obj.Tracer:Remove() end) end
        end
    end
    table.clear(Engine.ESPObjects)
end

local function UpdatePlayerESP()
    if not Engine.Config.PlayerESP and not Engine.Config.PlayerTracers then
        ClearAllESP()
        return
    end

    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return end
    local enemies = GetEnemyCharacters()
    local activeKeys = {}

    for _, entry in ipairs(enemies) do
        local key = "Player_" .. entry.Participant.Name
        activeKeys[key] = true

        local cache = Engine.ESPObjects[key]
        if not cache then
            cache = {}
            -- Highlight
            local hl = Instance.new("Highlight")
            hl.Name = "HL_" .. entry.Participant.Name
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency = 0.55
            hl.OutlineTransparency = 0.1
            hl.Parent = ESPFolder
            cache.Highlight = hl

            -- Billboard
            local bb = Instance.new("BillboardGui")
            bb.Name = "BB_" .. entry.Participant.Name
            bb.Size = UDim2.fromOffset(160, 48)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 0
            bb.ExtentsOffset = Vector3.new(0, 3.2, 0)
            bb.Parent = ESPFolder

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "NameLabel"
            nameLbl.Size = UDim2.new(1, 0, 0.45, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextSize = 13
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.TextStrokeTransparency = 0.2
            nameLbl.Parent = bb
            cache.NameLabel = nameLbl

            local infoLbl = Instance.new("TextLabel")
            infoLbl.Name = "InfoLabel"
            infoLbl.Size = UDim2.new(1, 0, 0.4, 0)
            infoLbl.Position = UDim2.new(0, 0, 0.45, 0)
            infoLbl.BackgroundTransparency = 1
            infoLbl.TextSize = 11
            infoLbl.Font = Enum.Font.GothamMedium
            infoLbl.TextColor3 = Color3.fromRGB(0, 255, 170)
            infoLbl.TextStrokeTransparency = 0.3
            infoLbl.Parent = bb
            cache.InfoLabel = infoLbl

            -- Hardware-Accelerated 2D Drawing Visuals (Box, Health Bar, Tracer)
            if Drawing and Drawing.new then
                pcall(function()
                    local boxOutline = Drawing.new("Square")
                    boxOutline.Thickness = 2
                    boxOutline.Filled = false
                    boxOutline.Visible = false
                    cache.BoxOutline = boxOutline
                    table.insert(Engine.Drawings, boxOutline)

                    local box = Drawing.new("Square")
                    box.Thickness = 1.2
                    box.Filled = false
                    box.Visible = false
                    cache.Box = box
                    table.insert(Engine.Drawings, box)

                    local hpBg = Drawing.new("Square")
                    hpBg.Filled = true
                    hpBg.Visible = false
                    cache.HealthBarBg = hpBg
                    table.insert(Engine.Drawings, hpBg)

                    local hp = Drawing.new("Square")
                    hp.Filled = true
                    hp.Visible = false
                    cache.HealthBar = hp
                    table.insert(Engine.Drawings, hp)

                    local line = Drawing.new("Line")
                    line.Thickness = 1.2
                    line.Transparency = 0.8
                    line.Visible = false
                    cache.Tracer = line
                    table.insert(Engine.Drawings, line)
                end)
            end

            cache.Billboard = bb
            Engine.ESPObjects[key] = cache
        end

        local color = entry.Team == "Terrorists" and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 160, 255)
        cache.Color = color
        cache.Root = entry.Root
        cache.Head = entry.Head
        cache.Health = entry.Health

        cache.Highlight.Adornee = entry.Character
        cache.Highlight.FillColor = color
        cache.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        cache.Highlight.Enabled = Engine.Config.PlayerESP and Engine.Config.PlayerESPBoxes

        cache.Billboard.Adornee = entry.Root
        cache.Billboard.Enabled = Engine.Config.PlayerESP

        local dist = math.floor((entry.Root.Position - cam.CFrame.Position).Magnitude)
        local dispName = (typeof(entry.Participant) == "Instance" and (entry.Participant:GetAttribute("DisplayName") or entry.Participant.Name)) or entry.Character.Name

        cache.NameLabel.Text = dispName
        cache.NameLabel.TextColor3 = color
        cache.InfoLabel.Text = string.format("%d HP | %dm", math.floor(entry.Health), dist)
    end

    -- Cleanup missing enemies
    for k, v in pairs(Engine.ESPObjects) do
        if k:sub(1, 7) == "Player_" and not activeKeys[k] then
            if v.Highlight then pcall(function() v.Highlight:Destroy() end) end
            if v.Billboard then pcall(function() v.Billboard:Destroy() end) end
            if v.Box and v.Box.Remove then pcall(function() v.Box:Remove() end) end
            if v.BoxOutline and v.BoxOutline.Remove then pcall(function() v.BoxOutline:Remove() end) end
            if v.HealthBar and v.HealthBar.Remove then pcall(function() v.HealthBar:Remove() end) end
            if v.HealthBarBg and v.HealthBarBg.Remove then pcall(function() v.HealthBarBg:Remove() end) end
            if v.Tracer and v.Tracer.Remove then pcall(function() v.Tracer:Remove() end) end
            Engine.ESPObjects[k] = nil
        end
    end
end

-- High-rate 2D Tactical Drawing Overlay (60+ FPS RenderStepped Execution)
local function UpdateTracersOnly()
    local cam = Workspace.CurrentCamera or CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local origin = Vector2.new(vp.X / 2, vp.Y)

    for k, v in pairs(Engine.ESPObjects) do
        if k:sub(1, 7) == "Player_" then
            local root = v.Root
            local head = v.Head or root
            if root and root.Parent and head and head.Parent then
                local rootPos, rootOnScreen = cam:WorldToViewportPoint(root.Position)
                local headPos, headOnScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
                local legPos, legOnScreen = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.0, 0))

                if rootOnScreen and rootPos.Z > 0 then
                    local color = v.Color or Color3.fromRGB(255, 80, 80)
                    local boxHeight = math.abs(headPos.Y - legPos.Y)
                    local boxWidth = math.max(12, boxHeight * 0.62)
                    local boxPos = Vector2.new(rootPos.X - boxWidth / 2, math.min(headPos.Y, legPos.Y))

                    -- 1. True 2D Bounding Box
                    if v.Box and v.BoxOutline then
                        local showBox = Engine.Config.PlayerESP and Engine.Config.PlayerESPBoxes
                        v.Box.Visible = showBox
                        v.BoxOutline.Visible = showBox
                        if showBox then
                            v.BoxOutline.Size = Vector2.new(boxWidth + 2, boxHeight + 2)
                            v.BoxOutline.Position = Vector2.new(boxPos.X - 1, boxPos.Y - 1)
                            v.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
                            v.BoxOutline.Thickness = 2
                            v.BoxOutline.Filled = false

                            v.Box.Size = Vector2.new(boxWidth, boxHeight)
                            v.Box.Position = boxPos
                            v.Box.Color = color
                            v.Box.Thickness = 1.2
                            v.Box.Filled = false
                        end
                    end

                    -- 2. True Dynamic Health Bar
                    if v.HealthBar and v.HealthBarBg then
                        local showBar = Engine.Config.PlayerESP and Engine.Config.PlayerESPHealth
                        v.HealthBar.Visible = showBar
                        v.HealthBarBg.Visible = showBar
                        if showBar then
                            local barWidth = 3
                            local hpPct = math.clamp((v.Health or 100) / 100, 0, 1)
                            local barHeight = boxHeight * hpPct
                            local barX = boxPos.X - barWidth - 4

                            v.HealthBarBg.Size = Vector2.new(barWidth + 2, boxHeight + 2)
                            v.HealthBarBg.Position = Vector2.new(barX - 1, boxPos.Y - 1)
                            v.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
                            v.HealthBarBg.Filled = true

                            v.HealthBar.Size = Vector2.new(barWidth, math.max(1, barHeight))
                            v.HealthBar.Position = Vector2.new(barX, boxPos.Y + (boxHeight - barHeight))
                            v.HealthBar.Color = Color3.fromHSV(hpPct * 0.33, 1, 1)
                            v.HealthBar.Filled = true
                        end
                    end

                    -- 3. High-Rate Tracer Line
                    if v.Tracer then
                        local showTracer = Engine.Config.PlayerTracers
                        v.Tracer.Visible = showTracer
                        if showTracer then
                            v.Tracer.From = origin
                            v.Tracer.To = Vector2.new(rootPos.X, legPos.Y)
                            v.Tracer.Color = color
                        end
                    end
                else
                    if v.Box then v.Box.Visible = false end
                    if v.BoxOutline then v.BoxOutline.Visible = false end
                    if v.HealthBar then v.HealthBar.Visible = false end
                    if v.HealthBarBg then v.HealthBarBg.Visible = false end
                    if v.Tracer then v.Tracer.Visible = false end
                end
            else
                if v.Box then v.Box.Visible = false end
                if v.BoxOutline then v.BoxOutline.Visible = false end
                if v.HealthBar then v.HealthBar.Visible = false end
                if v.HealthBarBg then v.HealthBarBg.Visible = false end
                if v.Tracer then v.Tracer.Visible = false end
            end
        end
    end
end

-- Planted C4 Bomb ESP
local function UpdateBombESP()
    local key = "Bomb_Planted"
    if not Engine.Config.BombESP then
        if Engine.ESPObjects[key] then
            pcall(function()
                if Engine.ESPObjects[key].Billboard then Engine.ESPObjects[key].Billboard:Destroy() end
                if Engine.ESPObjects[key].Highlight then Engine.ESPObjects[key].Highlight:Destroy() end
            end)
            Engine.ESPObjects[key] = nil
        end
        return
    end

    local bombs = CollectionService:GetTagged("Bomb")
    local bomb = bombs and bombs[1]

    if bomb and bomb.Parent and bomb:GetAttribute("Defused") ~= true and bomb:GetAttribute("Exploded") ~= true then
        local cache = Engine.ESPObjects[key]
        if not cache then
            cache = {}
            local hl = Instance.new("Highlight")
            hl.Name = "HL_PlantedBomb"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = Color3.fromRGB(255, 40, 40)
            hl.OutlineColor = Color3.fromRGB(255, 255, 0)
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0.1
            hl.Parent = ESPFolder
            cache.Highlight = hl

            local bb = Instance.new("BillboardGui")
            bb.Name = "BB_PlantedBomb"
            bb.Size = UDim2.fromOffset(170, 50)
            bb.AlwaysOnTop = true
            bb.ExtentsOffset = Vector3.new(0, 2.5, 0)
            bb.Parent = ESPFolder

            local txt = Instance.new("TextLabel")
            txt.Name = "BombLabel"
            txt.Size = UDim2.fromScale(1, 1)
            txt.BackgroundTransparency = 1
            txt.TextSize = 13
            txt.Font = Enum.Font.GothamBold
            txt.TextColor3 = Color3.fromRGB(255, 220, 0)
            txt.TextStrokeTransparency = 0.2
            txt.Parent = bb
            cache.Label = txt

            cache.Billboard = bb
            Engine.ESPObjects[key] = cache
        end

        local rootPart = bomb.PrimaryPart or bomb:FindFirstChildWhichIsA("BasePart")
        if rootPart then
            cache.Highlight.Adornee = bomb
            cache.Billboard.Adornee = rootPart

            local cam = Workspace.CurrentCamera or CurrentCamera
            local dist = math.floor((rootPart.Position - cam.CFrame.Position).Magnitude)
            local isDefusing = bomb:GetAttribute("DefuseStartTime") ~= nil

            if isDefusing then
                cache.Label.Text = string.format("C4 [DEFUSING] | %dm", dist)
                cache.Label.TextColor3 = Color3.fromRGB(0, 255, 255)
            else
                cache.Label.Text = string.format("PLANTED C4 | %dm", dist)
                cache.Label.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end
    else
        if Engine.ESPObjects[key] then
            pcall(function()
                if Engine.ESPObjects[key].Billboard then Engine.ESPObjects[key].Billboard:Destroy() end
                if Engine.ESPObjects[key].Highlight then Engine.ESPObjects[key].Highlight:Destroy() end
            end)
            Engine.ESPObjects[key] = nil
        end
    end
end

-- Zombie Horde ESP (Survival Gamemode)
local function UpdateHordeESP()
    if not Engine.Config.HordeESP then return end
    local hordeFolder = Workspace:FindFirstChild("Horde") or Workspace:FindFirstChild("Zombies")
    if not hordeFolder then return end

    local activeKeys = {}
    for _, z in ipairs(hordeFolder:GetChildren()) do
        if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") and z:GetAttribute("Dead") ~= true then
            local key = "Zombie_" .. z.Name
            activeKeys[key] = true

            local cache = Engine.ESPObjects[key]
            if not cache then
                cache = {}
                local hl = Instance.new("Highlight")
                hl.Name = "HL_" .. z.Name
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = Color3.fromRGB(0, 255, 120)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.Parent = ESPFolder
                cache.Highlight = hl
                Engine.ESPObjects[key] = cache
            end
            cache.Highlight.Adornee = z
        end
    end

    for k, v in pairs(Engine.ESPObjects) do
        if k:sub(1, 7) == "Zombie_" and not activeKeys[k] then
            pcall(function() v.Highlight:Destroy() end)
            Engine.ESPObjects[k] = nil
        end
    end
end

--[[ 5. MOVEMENT & SIMULATION ENHANCEMENTS ]]--

-- True MovementV2 Kinematic Engine Hook
pcall(function()
    setreadonly(RuntimeSettings, false)
    RuntimeSettings.getMovementConfig = function(...)
        local base = OrigGetMovementConfig(...)
        if not (Engine.Config.AutoBunnyHop or Engine.Config.AirStrafeBoost or Engine.Config.CustomSpeed) then
            return base
        end
        local custom = table.clone(base)
        setreadonly(custom, false)
        if Engine.Config.AutoBunnyHop then
            custom.AutoBunnyHop = true
            custom.BunnyHopPenaltyBase = 0
            custom.BunnyHopPenaltyScale = 0
            custom.BunnyHopMinVelocityRetain = 1
            custom.StaminaJumpCost = 0
            custom.StaminaLandCost = 0
        end
        if Engine.Config.AirStrafeBoost then
            custom.AirAccelerate = 150
            custom.AirSpeedCap = 150
        end
        if Engine.Config.CustomSpeed then
            local spd = Engine.Config.SpeedValue
            custom.DefaultBaseMoveSpeed = spd
            custom.MaxBaseMoveSpeed = spd * 1.5
            custom.MaxSpeed = spd * 1.5
        end
        return custom
    end
end)

local function ApplyMovementSimulation()
    pcall(function()
        if Engine.Config.AutoBunnyHop then
            SimConfig.Default.AutoBunnyHop = true
            SimConfig.Default.BunnyHopPenaltyBase = 0
            SimConfig.Default.BunnyHopPenaltyScale = 0
            SimConfig.Default.BunnyHopMinVelocityRetain = 1
        else
            SimConfig.Default.AutoBunnyHop = OrigSim.AutoBunnyHop
            SimConfig.Default.BunnyHopPenaltyBase = OrigSim.BunnyHopPenaltyBase
            SimConfig.Default.BunnyHopPenaltyScale = OrigSim.BunnyHopPenaltyScale
        end

        if Engine.Config.AirStrafeBoost then
            SimConfig.Default.AirAccelerate = 150
        else
            SimConfig.Default.AirAccelerate = OrigSim.AirAccelerate
        end

        if Engine.Config.CustomSpeed then
            local spd = Engine.Config.SpeedValue
            SimConfig.Default.DefaultBaseMoveSpeed = spd
            SimConfig.Default.MaxBaseMoveSpeed = spd * 1.5
            SimConfig.Default.MaxSpeed = spd * 1.5
            SpeedProfile.DefaultBaseSpeed = spd
            SpeedProfile.TopSpeed = spd * 1.5
            SpeedProfile.SprintSpeed = spd * 1.55
        else
            SimConfig.Default.DefaultBaseMoveSpeed = OrigSim.DefaultBaseMoveSpeed
            SimConfig.Default.MaxBaseMoveSpeed = OrigSim.MaxBaseMoveSpeed
            SimConfig.Default.MaxSpeed = OrigSim.MaxSpeed
            SpeedProfile.DefaultBaseSpeed = OrigSpeedProfile.DefaultBaseSpeed
            SpeedProfile.TopSpeed = OrigSpeedProfile.TopSpeed
            SpeedProfile.SprintSpeed = OrigSpeedProfile.SprintSpeed
        end
    end)
end

-- Native Infinite Jump Listener
local JumpConn = UserInputService.JumpRequest:Connect(function()
    if Engine.Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
end)
table.insert(Engine.Connections, JumpConn)

--[[ 6. GAMEMODE AUTOMATION ]]--

-- Auto Defuse Planted C4
local function RunAutoDefuse()
    if not Engine.Config.AutoDefuse then return end
    local now = os.clock()
    if now - Engine.State.LastDefuseTick < 1.0 then return end
    Engine.State.LastDefuseTick = now

    local root = GetLocalRoot()
    if not root then return end

    local bombs = CollectionService:GetTagged("Bomb")
    local bomb = bombs and bombs[1]
    if bomb and bomb.Parent and bomb:GetAttribute("Defused") ~= true and bomb:GetAttribute("Exploded") ~= true then
        local bPart = bomb.PrimaryPart or bomb:FindFirstChildWhichIsA("BasePart")
        if bPart then
            local dist = (bPart.Position - root.Position).Magnitude
            if dist <= 12 then
                pcall(function()
                    Remotes.C4.StartDefuse.Send({SessionId = 1})
                end)
            end
        end
    end
end

-- Auto Vacuum Candy (Survival Mode)
local function RunAutoCandyVacuum()
    if not Engine.Config.AutoVacuumCandy then return end
    local now = os.clock()
    if now - Engine.State.LastCandyVacuumTick < 1.2 then return end
    Engine.State.LastCandyVacuumTick = now

    pcall(function()
        if CandyController and CandyController.Start then
            Remotes.Survival.CandyVacuum.Send()
        end
    end)
end

-- Auto Revive Teammates (Survival Mode)
local function RunAutoRevive()
    if not Engine.Config.AutoRevive then return end
    local now = os.clock()
    if now - Engine.State.LastReviveTick < 1.0 then return end
    Engine.State.LastReviveTick = now

    if SurvivalDownedController and SurvivalDownedController.TryStartRevive then
        pcall(function()
            SurvivalDownedController.TryStartRevive()
        end)
    end
end

-- Tactical Locations
local TacticalPoints = {
    SiteA = Vector3.new(113.7, 9.5, -11.5),
    SiteB = Vector3.new(-70.8, 10.8, 114.6),
    TSpawn = Vector3.new(-36.5, 13.0, -137.2),
    CTSpawn = Vector3.new(91.5, 5.0, 90.0),
}

local function TeleportTo(position)
    local root = GetLocalRoot()
    if not root then return false end
    pcall(function()
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end)
    return true
end

--[[ 7. MAIN RENDER & HEARTBEAT PIPELINES ]]--

-- High-rate visual and input execution (Full FPS sync)
local RenderConnection = RunService.RenderStepped:Connect(function()
    pcall(UpdateFOVCircle)
    pcall(RunTriggerbot)
    pcall(UpdateTracersOnly)
end)
table.insert(Engine.Connections, RenderConnection)

-- Bind AimbotStep immediately AFTER CameraController.UpdateCamera (Enum.RenderPriority.Camera.Value + 1)
-- Running at Camera.Value + 2 guarantees zero camera fighting, zero repelling, and zero overshooting
pcall(function()
    RunService:BindToRenderStep("BloxStrike_Aimbot", Enum.RenderPriority.Camera.Value + 2, function()
        pcall(RunAimbotStep)
    end)
end)

-- Fast background simulation & ESP entity processing (0.05s interval)
local HeartbeatConnection = RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - Engine.State.LastThrottleTick >= 0.05 then
        Engine.State.LastThrottleTick = now
        pcall(SyncAliveEnemyPresentation)
        pcall(UpdatePlayerESP)
        pcall(UpdateBombESP)
        pcall(UpdateHordeESP)
        pcall(RunAutoDefuse)
        pcall(RunAutoCandyVacuum)
        pcall(RunAutoRevive)
    end
end)
table.insert(Engine.Connections, HeartbeatConnection)

--[[ 8. CONFIGURATION PERSISTENCE ]]--

local CONFIG_FOLDER = "BloxStrikeConfig"
local CONFIG_FILE = CONFIG_FOLDER .. "/default.json"

local function SaveConfig()
    local data = {}
    for k, v in pairs(Engine.Config) do
        data[k] = v
    end
    if not isfolder(CONFIG_FOLDER) then
        pcall(function() makefolder(CONFIG_FOLDER) end)
    end
    local json = HttpService:JSONEncode(data)
    writefile(CONFIG_FILE, json)
end

local function LoadConfig()
    if not isfile(CONFIG_FILE) then return false end
    local content = readfile(CONFIG_FILE)
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if ok and typeof(data) == "table" then
        for k, v in pairs(data) do
            if Engine.Config[k] ~= nil then
                Engine.Config[k] = v
            end
        end

        -- Synchronize WindUI visual element states
        for name, el in pairs(Engine.UIElements) do
            pcall(function()
                local val = Engine.Config[name]
                if val ~= nil and el then
                    if el.Select then
                        el:Select(val)
                    elseif el.Set then
                        el:Set(val)
                    elseif el.SetValue then
                        el:SetValue(val)
                    end
                end
            end)
        end

        -- Sync modifications & updates
        ApplyAimAssistBoost(Engine.Config.AimAssistBoost)
        ApplyMovementSimulation()
        LocalPlayer:SetAttribute("VIPESP", Engine.Config.NativeVIPESP)
        UpdateFOVCircle()
        return true
    end
    return false
end

--[[ 9. ENGINE UNLOAD ROUTINE ]]--

function Engine:Unload()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.Connections)

    for _, drw in ipairs(self.Drawings) do
        pcall(function() drw:Remove() end)
    end
    table.clear(self.Drawings)

    if self.GuiInstances then
        for _, gui in ipairs(self.GuiInstances) do
            pcall(function() gui:Destroy() end)
        end
        table.clear(self.GuiInstances)
    end

    ClearAllESP()
    pcall(function() ESPFolder:Destroy() end)

    -- Revert hooks
    pcall(function() CameraController.weaponKick = OrigWeaponKick end)
    pcall(function() CameraController.setWeaponRecoil = OrigSetWeaponRecoil end)
    pcall(function() CameraController.getWeaponKickRotation = OrigGetWeaponKickRotation end)
    pcall(function() BulletClass._performRaycast = OrigPerformRaycast end)
    pcall(function() BulletClass.getTrueSpread = OrigGetTrueSpread end)
    pcall(function() RuntimeSettings.getMovementConfig = OrigGetMovementConfig end)
    pcall(function() AimAssistController.GetRecoilAssistScale = OrigRecoilHook end)
    pcall(function() AimAssistController.GetMagnetismRotation = OrigMagnetismRotation end)
    if OrigUpdateCamera then
        pcall(function() CameraController.updateCamera = OrigUpdateCamera end)
    end
    pcall(function() RunService:UnbindFromRenderStep("BloxStrike_Aimbot") end)
    if ClientCharacterPresentation and OrigGetCulledFolder then
        pcall(function() ClientCharacterPresentation.GetCulledFolder = OrigGetCulledFolder end)
    end
    if FarThrottle and OrigFarThrottleSkips then
        pcall(function() FarThrottle.Skips = OrigFarThrottleSkips end)
    end

    -- Revert simulation config
    pcall(function()
        SimConfig.Default.AutoBunnyHop = OrigSim.AutoBunnyHop
        SimConfig.Default.AirAccelerate = OrigSim.AirAccelerate
        SimConfig.Default.DefaultBaseMoveSpeed = OrigSim.DefaultBaseMoveSpeed
        SimConfig.Default.MaxBaseMoveSpeed = OrigSim.MaxBaseMoveSpeed
        SimConfig.Default.MaxSpeed = OrigSim.MaxSpeed
        SimConfig.Default.BunnyHopPenaltyBase = OrigSim.BunnyHopPenaltyBase
        SimConfig.Default.BunnyHopPenaltyScale = OrigSim.BunnyHopPenaltyScale

        SpeedProfile.DefaultBaseSpeed = OrigSpeedProfile.DefaultBaseSpeed
        SpeedProfile.TopSpeed = OrigSpeedProfile.TopSpeed
        SpeedProfile.SprintSpeed = OrigSpeedProfile.SprintSpeed
    end)

    -- Revert VIP ESP
    LocalPlayer:SetAttribute("VIPESP", false)

    _G.BloxStrikeEngine = nil
end

_G.BloxStrikeEngine = Engine

--[[ 10. WINDUI INTERFACE ]]--

local WindUI = nil
local ok, res = pcall(function()
    if isfile and isfile("WindUI_dist.lua") then
        local code = readfile("WindUI_dist.lua")
        return loadstring(code)()
    else
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end
end)

if ok and res then
    WindUI = res
else
    warn("[BloxStrike] Failed to load WindUI framework.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "BloxStrike | Tactical Engine [V2.5 LMB]",
    Icon = "crosshair",
    Author = "ClientOP Kernel",
    Folder = "BloxStrikeConfig",
    Size = UDim2.fromOffset(580, 420),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    ToggleKey = Enum.KeyCode.RightControl,
})

-- Tab 1: Combat & Aim Enhancement
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })

CombatTab:Section({ Title = "Gunplay Enhancements" })

Engine.UIElements.NoRecoil = CombatTab:Toggle({
    Title = "No Recoil (True Camera Detour)",
    Desc = "Zeroes weapon kick and recoil springs in CameraController",
    Value = false,
    Callback = function(val)
        Engine.Config.NoRecoil = val
        if val then
            CameraController.resetWeaponRecoil()
        end
    end
})

Engine.UIElements.NoSpread = CombatTab:Toggle({
    Title = "No Spread / Laser Accuracy",
    Desc = "Zeroes bullet dispersion angle directly via _performRaycast detour",
    Value = false,
    Callback = function(val)
        Engine.Config.NoSpread = val
    end
})

Engine.UIElements.Triggerbot = CombatTab:Toggle({
    Title = "Crosshair Triggerbot",
    Desc = "Discharges weapon automatically via hardware mouse pipeline on enemy hover",
    Value = false,
    Callback = function(val)
        Engine.Config.Triggerbot = val
        UpdateFOVCircle()
    end
})

Engine.UIElements.TriggerbotDelay = CombatTab:Slider({
    Title = "Triggerbot Delay (ms)",
    Desc = "Hold duration before trigger release",
    Step = 5,
    Value = { Min = 10, Max = 100, Default = 30 },
    Callback = function(val)
        Engine.Config.TriggerbotDelay = val
    end
})

Engine.UIElements.AimAssistBoost = CombatTab:Toggle({
    Title = "Aim Assist Booster",
    Desc = "Boosts native magnetism, tracking angle, and pull rate",
    Value = false,
    Callback = function(val)
        Engine.Config.AimAssistBoost = val
        ApplyAimAssistBoost(val)
    end
})

CombatTab:Section({ Title = "Aimbot Tracking" })

Engine.UIElements.Aimbot = CombatTab:Toggle({
    Title = "Aimbot Tracking",
    Desc = "Smoothly guides crosshair towards nearest enemy within FOV via mousemoverel",
    Value = false,
    Callback = function(val)
        Engine.Config.Aimbot = val
        UpdateFOVCircle()
    end
})

Engine.UIElements.AimbotKey = CombatTab:Dropdown({
    Title = "Aimbot Activation Key",
    Desc = "Choose activation mode (Auto / In FOV locks onto any target in circle)",
    Values = { "Auto / In FOV", "LMB", "RMB", "LMB + RMB", "Always On" },
    Value = Engine.Config.AimbotKey or "Auto / In FOV",
    Callback = function(val)
        Engine.Config.AimbotKey = val
    end
})

Engine.UIElements.AimbotAutoShoot = CombatTab:Toggle({
    Title = "Auto-Shoot on Lock",
    Desc = "Automatically fires weapon once enemy enters FOV and target is aligned",
    Value = false,
    Callback = function(val)
        Engine.Config.AimbotAutoShoot = val
    end
})

Engine.UIElements.ShowFOVCircle = CombatTab:Toggle({
    Title = "Show FOV Circle",
    Desc = "Displays visual circular boundary for target selection",
    Value = false,
    Callback = function(val)
        Engine.Config.ShowFOVCircle = val
        UpdateFOVCircle()
    end
})

Engine.UIElements.AimbotFOV = CombatTab:Slider({
    Title = "Aimbot FOV",
    Desc = "Maximum pixel distance from screen center",
    Step = 5,
    Value = { Min = 30, Max = 350, Default = 120 },
    Callback = function(val)
        Engine.Config.AimbotFOV = val
        UpdateFOVCircle()
    end
})

Engine.UIElements.AimbotSmooth = CombatTab:Slider({
    Title = "Aimbot Smoothness",
    Desc = "Higher values provide smoother, human-like interpolation",
    Step = 1,
    Value = { Min = 1, Max = 25, Default = 6 },
    Callback = function(val)
        Engine.Config.AimbotSmooth = val
    end
})

Engine.UIElements.AimbotTargetPart = CombatTab:Dropdown({
    Title = "Target Bone",
    Desc = "Selects bone position to track",
    Values = { "Head", "Torso" },
    Value = "Head",
    Callback = function(val)
        Engine.Config.AimbotTargetPart = val
    end
})

Engine.UIElements.AimbotPriority = CombatTab:Dropdown({
    Title = "Target Priority",
    Desc = "Ordering heuristic for multiple candidates",
    Values = { "Crosshair", "Distance", "Lowest HP" },
    Value = "Crosshair",
    Callback = function(val)
        Engine.Config.AimbotPriority = val
    end
})

Engine.UIElements.AimbotVisibleOnly = CombatTab:Toggle({
    Title = "Visibility Check",
    Desc = "Verifies line-of-sight before locking on",
    Value = true,
    Callback = function(val)
        Engine.Config.AimbotVisibleOnly = val
    end
})

-- Tab 2: Visuals (ESP)
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

VisualsTab:Section({ Title = "Native Highlight System" })

Engine.UIElements.NativeVIPESP = VisualsTab:Toggle({
    Title = "Native VIP ESP",
    Desc = "Activates the game's internal high-performance AlwaysOnTop ESP",
    Value = false,
    Callback = function(val)
        Engine.Config.NativeVIPESP = val
        LocalPlayer:SetAttribute("VIPESP", val)
    end
})

VisualsTab:Section({ Title = "Tactical Overlays" })

Engine.UIElements.PlayerESP = VisualsTab:Toggle({
    Title = "Enemy Player ESP (Billboard & Highlight)",
    Desc = "Displays 3D bounding box, player name, health, and distance",
    Value = false,
    Callback = function(val)
        Engine.Config.PlayerESP = val
        if not val then ClearAllESP() end
    end
})

Engine.UIElements.PlayerTracers = VisualsTab:Toggle({
    Title = "ESP Tracers",
    Desc = "Draws directional guidance lines to enemy combatants",
    Value = false,
    Callback = function(val)
        Engine.Config.PlayerTracers = val
        if not val then
            for _, v in pairs(Engine.ESPObjects) do
                if v.Tracer then v.Tracer.Visible = false end
            end
        end
    end
})

Engine.UIElements.BombESP = VisualsTab:Toggle({
    Title = "Planted C4 Bomb ESP",
    Desc = "Highlights active C4, defusal state, and distance indicator",
    Value = false,
    Callback = function(val)
        Engine.Config.BombESP = val
        if not val and Engine.ESPObjects["Bomb_Planted"] then
            pcall(function()
                Engine.ESPObjects["Bomb_Planted"].Billboard:Destroy()
                Engine.ESPObjects["Bomb_Planted"].Highlight:Destroy()
            end)
            Engine.ESPObjects["Bomb_Planted"] = nil
        end
    end
})

Engine.UIElements.HordeESP = VisualsTab:Toggle({
    Title = "Zombie Horde ESP (Survival)",
    Desc = "Highlights active zombie entities from HordeStream",
    Value = false,
    Callback = function(val)
        Engine.Config.HordeESP = val
        if not val then
            for k, v in pairs(Engine.ESPObjects) do
                if k:sub(1, 7) == "Zombie_" then
                    pcall(function() v.Highlight:Destroy() end)
                    Engine.ESPObjects[k] = nil
                end
            end
        end
    end
})

-- Tab 3: Movement & Physics
local MovementTab = Window:Tab({ Title = "Movement", Icon = "zap" })

MovementTab:Section({ Title = "Source Simulation Engine" })

Engine.UIElements.AutoBunnyHop = MovementTab:Toggle({
    Title = "Auto BunnyHop",
    Desc = "Hold Spacebar to continuously hop at maximum velocity with zero penalty via RuntimeSettings",
    Value = false,
    Callback = function(val)
        Engine.Config.AutoBunnyHop = val
        ApplyMovementSimulation()
    end
})

Engine.UIElements.AirStrafeBoost = MovementTab:Toggle({
    Title = "Air Strafe Booster",
    Desc = "Boosts air acceleration parameter for fluid Source-style surfing",
    Value = false,
    Callback = function(val)
        Engine.Config.AirStrafeBoost = val
        ApplyMovementSimulation()
    end
})

Engine.UIElements.CustomSpeed = MovementTab:Toggle({
    Title = "Custom Movement Speed",
    Desc = "Modifies internal simulation walk & sprint rates in physics pipeline",
    Value = false,
    Callback = function(val)
        Engine.Config.CustomSpeed = val
        ApplyMovementSimulation()
    end
})

Engine.UIElements.SpeedValue = MovementTab:Slider({
    Title = "Move Speed Rate",
    Desc = "Default base speed is 18.75 studs/s",
    Step = 1,
    Value = { Min = 19, Max = 55, Default = 26 },
    Callback = function(val)
        Engine.Config.SpeedValue = val
        if Engine.Config.CustomSpeed then
            ApplyMovementSimulation()
        end
    end
})

Engine.UIElements.InfiniteJump = MovementTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Continuous mid-air jumping via native Humanoid state transition",
    Value = false,
    Callback = function(val)
        Engine.Config.InfiniteJump = val
    end
})

-- Tab 4: Gamemode Automation
local AutoTab = Window:Tab({ Title = "Automation", Icon = "sliders" })

AutoTab:Section({ Title = "Bomb Defusal Mode" })

Engine.UIElements.AutoDefuse = AutoTab:Toggle({
    Title = "Auto Defuse C4",
    Desc = "Automatically initiates defusal sequence when within bomb perimeter",
    Value = false,
    Callback = function(val)
        Engine.Config.AutoDefuse = val
    end
})

AutoTab:Section({ Title = "Zombies & Survival Mode" })

Engine.UIElements.AutoVacuumCandy = AutoTab:Toggle({
    Title = "Auto Vacuum Candy",
    Desc = "Continuously pulses vacuum protocol to collect all dropped candy",
    Value = false,
    Callback = function(val)
        Engine.Config.AutoVacuumCandy = val
    end
})

Engine.UIElements.AutoRevive = AutoTab:Toggle({
    Title = "Auto Revive Teammates",
    Desc = "Automatically revives downed squad members within interaction range",
    Value = false,
    Callback = function(val)
        Engine.Config.AutoRevive = val
    end
})

AutoTab:Section({ Title = "Tactical Teleports" })

AutoTab:Button({
    Title = "Warp to Bomb Site A",
    Callback = function()
        local ok = TeleportTo(TacticalPoints.SiteA)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Teleport", Content = ok and "Warped to Site A" or "Character unavailable", Duration = 2 })
        end
    end
})

AutoTab:Button({
    Title = "Warp to Bomb Site B",
    Callback = function()
        local ok = TeleportTo(TacticalPoints.SiteB)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Teleport", Content = ok and "Warped to Site B" or "Character unavailable", Duration = 2 })
        end
    end
})

AutoTab:Button({
    Title = "Warp to Terrorist Spawn",
    Callback = function()
        local ok = TeleportTo(TacticalPoints.TSpawn)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Teleport", Content = ok and "Warped to T Spawn" or "Character unavailable", Duration = 2 })
        end
    end
})

AutoTab:Button({
    Title = "Warp to Counter-Terrorist Spawn",
    Callback = function()
        local ok = TeleportTo(TacticalPoints.CTSpawn)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Teleport", Content = ok and "Warped to CT Spawn" or "Character unavailable", Duration = 2 })
        end
    end
})

-- Tab 5: Settings & Config
local SettingsTab = Window:Tab({ Title = "Config", Icon = "settings" })

SettingsTab:Section({ Title = "Profile Management" })

SettingsTab:Button({
    Title = "Save Configuration",
    Desc = "Persists current module states to default.json",
    Callback = function()
        SaveConfig()
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Configuration", Content = "Settings saved successfully!", Duration = 3 })
        end
    end
})

SettingsTab:Button({
    Title = "Load Configuration",
    Desc = "Restores module states from default.json",
    Callback = function()
        local ok = LoadConfig()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "Configuration",
                Content = ok and "Configuration & visual states restored!" or "No saved configuration file found.",
                Duration = 3
            })
        end
    end
})

SettingsTab:Button({
    Title = "Unload Script",
    Desc = "Completely unhooks controllers, removes GUI, and restores default states",
    Callback = function()
        Engine:Unload()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end
})

--[[ 11. FLOATING ACTION BUTTON & KEYBIND TOGGLE ]]--

local function SetupFloatingButtonAndKeybind()
    local hui = (gethui and gethui()) or game:GetService("CoreGui")
    if not hui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BloxStrike_FloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "OpenButton"
    floatBtn.Size = UDim2.fromOffset(50, 50)
    floatBtn.Position = UDim2.new(0.04, 0, 0.45, 0)
    floatBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    floatBtn.BorderSizePixel = 0
    floatBtn.Text = "BS"
    floatBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
    floatBtn.TextSize = 16
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.AutoButtonColor = false
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = floatBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 170)
    stroke.Thickness = 1.8
    stroke.Transparency = 0.25
    stroke.Parent = floatBtn

    local function ToggleUI()
        Engine.State.UIVisible = not Engine.State.UIVisible
        if Window then
            pcall(function() Window:Toggle() end)
        end
    end

    floatBtn.MouseButton1Click:Connect(ToggleUI)

    local KeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightShift then
            ToggleUI()
        end
    end)
    table.insert(Engine.Connections, KeyConn)
    table.insert(Engine.GuiInstances, screenGui)

    pcall(function() screenGui.Parent = hui end)
end

SetupFloatingButtonAndKeybind()
