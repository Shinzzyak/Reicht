-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    =============================================================================
    RIVALS | TACTICAL AUTOMATION KERNEL
    Universe ID: 6035872082 | Place IDs: 17625359962 / 117398147513099
    Architecture: Custom Client Engine (Real) + WindUI Framework
    Branding: By XLunaHUB
    Defaults: ALL MODULES DEFAULT TO FALSE / OFF (Manual Activation / Config Load)
    =============================================================================
--]]

-- Clean existing instances
if _G.RivalsEngine and _G.RivalsEngine.Unload then
    pcall(function() _G.RivalsEngine:Unload() end)
end

-- Clean old UI ScreenGuis
pcall(function()
    local hui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if hui then
        for _, c in ipairs(hui:GetChildren()) do
            if c:IsA("ScreenGui") and (c.Name:find("WindUI") or c.Name == "RIVALS_FloatingBtn" or c.Name:find("Rivals")) then
                c:Destroy()
            end
        end
    end
end)

-- Core Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")

-- Native Game Controllers & Libraries
local FighterController = nil
local MechanicsController = nil
local CameraController = nil
local ControlsController = nil
local ShootingRangeController = nil
local DuelController = nil
local ItemLibrary = nil
local GameplayUtility = nil

pcall(function()
    FighterController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController", 5))
end)
pcall(function()
    MechanicsController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController", 5))
end)
pcall(function()
    CameraController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController", 5))
end)
pcall(function()
    ControlsController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController", 5))
end)
pcall(function()
    ShootingRangeController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("ShootingRangeController", 5))
end)
pcall(function()
    DuelController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("DuelController", 5))
end)
pcall(function()
    ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 5))
end)
pcall(function()
    GameplayUtility = require(ReplicatedStorage.Modules:WaitForChild("GameplayUtility", 5))
end)

-- Engine Root Object
local Engine = {
    Connections = {},
    Drawings = {},
    ESPObjects = {},
    OriginalWeaponData = {},
    UIElements = {},
    IsUnloaded = false,
    CurrentTarget = nil,

    -- Universal Configuration (Strictly ALL OFF by default)
    Config = {
        -- Combat
        Aimbot = false,
        AimbotSmooth = 3,
        AimbotFOV = 120,
        AimbotPart = "Head", -- "Head", "UpperTorso", "HumanoidRootPart"
        SilentAim = false,
        SilentAimFOV = 160,
        ShowFOV = false,
        FOVColor = Color3.fromRGB(255, 60, 60),
        Triggerbot = false,
        TriggerbotDelay = 0.05,
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        AutoReload = false,
        TeamCheck = false,
        TargetPlayers = false,
        TargetDummies = false,

        -- Visuals (ESP)
        ESPEnabled = false,
        ESPBoxes = false,
        ESPSkeletons = false,
        ESPNames = false,
        ESPHealth = false,
        ESPShield = false,
        ESPDistance = false,
        ESPWeapon = false,
        ESPTracers = false,
        ESPDummies = false,
        BoxColor = Color3.fromRGB(255, 50, 50),
        TracerColor = Color3.fromRGB(255, 210, 40),
        DummyColor = Color3.fromRGB(50, 180, 255),
        SkeletonColor = Color3.fromRGB(255, 255, 255),

        -- Movement
        CustomSpeed = false,
        SpeedValue = 26,
        BunnyHop = false,
        InfiniteJump = false,

        -- Automation
        AutoFarmDummies = false,
        AutoClaimRewards = false,
        AntiAFK = false,
    }
}

-- Anti-AFK Engine
local function SetupAntiAFK()
    pcall(function()
        if typeof(getconnections) == "function" then
            for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
                conn:Disable()
            end
        end
    end)

    local afkConn = LocalPlayer.Idled:Connect(function()
        if Engine.Config.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end
    end)
    table.insert(Engine.Connections, afkConn)
end
SetupAntiAFK()

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = Engine.Config.AimbotFOV
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Engine.Config.FOVColor
FOVCircle.Visible = false
table.insert(Engine.Drawings, FOVCircle)

--[[
    =============================================================================
    1. TARGET EVALUATION PIPELINE
    =============================================================================
--]]

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function GetTargetBone(model, bonePreference)
    if not model then return nil end
    if bonePreference == "Head" then
        return model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
    elseif bonePreference == "UpperTorso" then
        return model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
    else
        return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    end
end

local function GetValidTargets()
    local targets = {}
    local screenCenter = GetScreenCenter()
    local myPos = Camera.CFrame.Position
    local myFighter = FighterController and FighterController.LocalFighter
    local myTeam = LocalPlayer.Team

    -- Scan Players via FighterController
    if Engine.Config.TargetPlayers and FighterController and FighterController.Objects then
        for _, f in pairs(FighterController.Objects) do
            if f ~= myFighter and f:IsAlive() and f.Entity and f.Entity.Model then
                local model = f.Entity.Model
                local p = f.Player

                local isTeammate = false
                if Engine.Config.TeamCheck and p and myTeam and p.Team == myTeam then
                    isTeammate = true
                end

                if not isTeammate then
                    local targetBone = GetTargetBone(model, Engine.Config.AimbotPart)
                    if targetBone then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetBone.Position)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        table.insert(targets, {
                            Fighter = f,
                            Model = model,
                            Bone = targetBone,
                            Position = targetBone.Position,
                            Health = f:GetHealth(),
                            MaxHealth = f:GetMaxHealth(),
                            Shield = f:GetShield(),
                            Name = p and p.DisplayName or model.Name,
                            IsPlayer = true,
                            OnScreen = onScreen,
                            ScreenDistance = screenDist,
                            WorldDistance = (targetBone.Position - myPos).Magnitude
                        })
                    end
                end
            end
        end
    end

    -- Scan Shooting Range Dummies & Targets
    if Engine.Config.TargetDummies and myFighter and myFighter:Get("IsInShootingRange") then
        local srFolder = Workspace:FindFirstChild("ShootingRangeEntities")
        if srFolder then
            for _, ent in ipairs(srFolder:GetChildren()) do
                if ent.Name == "Dummy" or ent.Name == "DPS Dummy" or ent.Name == "Target" then
                    local targetBone = GetTargetBone(ent, Engine.Config.AimbotPart) or ent:FindFirstChildWhichIsA("BasePart")
                    if targetBone then
                        local hum = ent:FindFirstChildOfClass("Humanoid")
                        local hp = hum and hum.Health or 100
                        local maxHp = hum and hum.MaxHealth or 100
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetBone.Position)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        table.insert(targets, {
                            Model = ent,
                            Bone = targetBone,
                            Position = targetBone.Position,
                            Health = hp,
                            MaxHealth = maxHp,
                            Shield = 0,
                            Name = ent.Name,
                            IsPlayer = false,
                            OnScreen = onScreen,
                            ScreenDistance = screenDist,
                            WorldDistance = (targetBone.Position - myPos).Magnitude
                        })
                    end
                end
            end
        end
    end

    return targets
end

local function GetClosestTarget(maxFOV)
    local targets = GetValidTargets()
    local bestTarget = nil
    local shortestDist = maxFOV or math.huge

    for _, t in ipairs(targets) do
        if t.OnScreen and t.ScreenDistance < shortestDist then
            shortestDist = t.ScreenDistance
            bestTarget = t
        end
    end

    return bestTarget
end

--[[
    =============================================================================
    2. COMBAT SUBSYSTEM (Silent Aim, Camera Aimbot, Triggerbot, No Recoil/Spread)
    =============================================================================
--]]

-- Native Silent Aim Hook via GameplayUtility
if GameplayUtility and GameplayUtility.GetRaycastRedirection then
    local origRedirection = GameplayUtility.GetRaycastRedirection
    GameplayUtility.GetRaycastRedirection = function(self, fighter, lookupParams, lookDir, origin, maxAngle)
        if not Engine.IsUnloaded and Engine.Config.SilentAim then
            local silentTarget = GetClosestTarget(Engine.Config.SilentAimFOV)
            if silentTarget and silentTarget.Position then
                return (silentTarget.Position - origin).Unit
            end
        end
        return origRedirection(self, fighter, lookupParams, lookDir, origin, maxAngle)
    end
end

-- Weapon Recoil & Spread Nullifier
local function CacheAndPatchWeapons(enableNoRecoil, enableNoSpread)
    if not ItemLibrary or not ItemLibrary.Items then return end

    for name, item in pairs(ItemLibrary.Items) do
        if not Engine.OriginalWeaponData[name] then
            Engine.OriginalWeaponData[name] = {
                ShootRecoil = item.ShootRecoil,
                ShootSpread = item.ShootSpread,
                AimSpreadMultiplier = item.AimSpreadMultiplier,
                ShootCameraDisplacementRecoil = item.ShootCameraDisplacementRecoil,
            }
        end

        local cached = Engine.OriginalWeaponData[name]
        if enableNoRecoil then
            item.ShootRecoil = 0
            item.ShootCameraDisplacementRecoil = Vector2.zero
        else
            item.ShootRecoil = cached.ShootRecoil
            item.ShootCameraDisplacementRecoil = cached.ShootCameraDisplacementRecoil
        end

        if enableNoSpread then
            item.ShootSpread = 0
            item.AimSpreadMultiplier = 0
        else
            item.ShootSpread = cached.ShootSpread
            item.AimSpreadMultiplier = cached.AimSpreadMultiplier
        end
    end

    -- Update active equipped weapon
    local myFighter = FighterController and FighterController.LocalFighter
    if myFighter and myFighter.EquippedItem and myFighter.EquippedItem.Info then
        local eqInfo = myFighter.EquippedItem.Info
        if enableNoRecoil then
            eqInfo.ShootRecoil = 0
            eqInfo.ShootCameraDisplacementRecoil = Vector2.zero
            if myFighter.EquippedItem._camera_displacement_spring then
                myFighter.EquippedItem._camera_displacement_spring.Value = Vector2.zero
            end
        end
        if enableNoSpread then
            eqInfo.ShootSpread = 0
            eqInfo.AimSpreadMultiplier = 0
        end
    end
end

-- Triggerbot Execution State
local lastTriggerShot = 0
local function ExecuteTriggerbot()
    if not Engine.Config.Triggerbot or tick() - lastTriggerShot < Engine.Config.TriggerbotDelay then
        return
    end

    local myFighter = FighterController and FighterController.LocalFighter
    if not myFighter or not myFighter:IsAlive() or not myFighter.EquippedItem then
        return
    end

    local screenCenter = GetScreenCenter()
    local unitRay = Camera:ViewportPointToRay(screenCenter.X, screenCenter.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local excludeList = {Camera}
    if LocalPlayer.Character then table.insert(excludeList, LocalPlayer.Character) end
    rayParams.FilterDescendantsInstances = excludeList

    local hit = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
    if hit and hit.Instance then
        local hitModel = hit.Instance:FindFirstAncestorOfClass("Model")
        local isTarget = false

        if hitModel then
            -- Check player
            if Engine.Config.TargetPlayers and FighterController and FighterController.Objects then
                for _, f in pairs(FighterController.Objects) do
                    if f ~= myFighter and f:IsAlive() and f.Entity and f.Entity.Model == hitModel then
                        if not Engine.Config.TeamCheck or not (f.Player and LocalPlayer.Team and f.Player.Team == LocalPlayer.Team) then
                            isTarget = true
                            break
                        end
                    end
                end
            end
            -- Check dummy
            if not isTarget and Engine.Config.TargetDummies and hitModel.Parent and hitModel.Parent.Name == "ShootingRangeEntities" then
                isTarget = true
            end
        end

        if isTarget then
            lastTriggerShot = tick()
            if typeof(mouse1click) == "function" then
                mouse1click()
            elseif myFighter.EquippedItem.StartShooting then
                myFighter.EquippedItem:StartShooting()
            end
        end
    end
end

-- Main Combat Render Loop
local combatConn = RunService.RenderStepped:Connect(function()
    if Engine.IsUnloaded then return end

    -- FOV Circle update
    local screenCenter = GetScreenCenter()
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = Engine.Config.AimbotFOV
    FOVCircle.Color = Engine.Config.FOVColor
    FOVCircle.Visible = Engine.Config.ShowFOV

    -- Aimbot Tracking
    if Engine.Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget(Engine.Config.AimbotFOV)
        if target and target.Bone then
            local screenPos = Camera:WorldToViewportPoint(target.Bone.Position)
            local deltaX = screenPos.X - screenCenter.X
            local deltaY = screenPos.Y - screenCenter.Y
            local smooth = math.max(1, Engine.Config.AimbotSmooth)

            if typeof(mousemoverel) == "function" then
                mousemoverel(deltaX / smooth, deltaY / smooth)
            end
        end
    end

    -- Triggerbot Check
    if Engine.Config.Triggerbot then
        ExecuteTriggerbot()
    end

    -- Auto Reload Check
    if Engine.Config.AutoReload then
        local myFighter = FighterController and FighterController.LocalFighter
        if myFighter and myFighter.EquippedItem then
            local eq = myFighter.EquippedItem
            if eq.Get and eq:Get("Ammo") == 0 and eq.StartReloading then
                eq:StartReloading(true)
            end
        end
    end
end)
table.insert(Engine.Connections, combatConn)

--[[
    =============================================================================
    3. VISUALS SUBSYSTEM (3D Box, Health/Shield Bar, Skeletons, Tracers, ESP)
    =============================================================================
--]]

local function CreateESPElement()
    return {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        ShieldBarOutline = Drawing.new("Square"),
        ShieldBar = Drawing.new("Square"),
        NameTag = Drawing.new("Text"),
        InfoTag = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
    }
end

local function CleanupESPElement(esp)
    for _, d in pairs(esp) do
        pcall(function()
            d.Visible = false
            d:Remove()
        end)
    end
end

local function UpdateESP()
    if Engine.IsUnloaded or not Engine.Config.ESPEnabled then
        for model, esp in pairs(Engine.ESPObjects) do
            for _, d in pairs(esp) do d.Visible = false end
        end
        return
    end

    local myFighter = FighterController and FighterController.LocalFighter
    local myPos = Camera.CFrame.Position
    local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local activeModels = {}

    -- Render Players
    if FighterController and FighterController.Objects then
        for _, f in pairs(FighterController.Objects) do
            if f ~= myFighter and f:IsAlive() and f.Entity and f.Entity.Model then
                local model = f.Entity.Model
                local p = f.Player
                local hrp = model:FindFirstChild("HumanoidRootPart")
                local head = model:FindFirstChild("Head")

                local isTeammate = false
                if Engine.Config.TeamCheck and p and LocalPlayer.Team and p.Team == LocalPlayer.Team then
                    isTeammate = true
                end

                if hrp and head and not isTeammate then
                    activeModels[model] = true
                    if not Engine.ESPObjects[model] then
                        Engine.ESPObjects[model] = CreateESPElement()
                    end

                    local esp = Engine.ESPObjects[model]
                    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))

                        local boxHeight = math.abs(headPos.Y - legPos.Y)
                        local boxWidth = boxHeight * 0.6
                        local boxX = hrpPos.X - (boxWidth / 2)
                        local boxY = headPos.Y

                        -- 2D Bounding Box
                        if Engine.Config.ESPBoxes then
                            esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                            esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                            esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
                            esp.BoxOutline.Thickness = 3
                            esp.BoxOutline.Visible = true

                            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                            esp.Box.Position = Vector2.new(boxX, boxY)
                            esp.Box.Color = Engine.Config.BoxColor
                            esp.Box.Thickness = 1
                            esp.Box.Visible = true
                        else
                            esp.BoxOutline.Visible = false
                            esp.Box.Visible = false
                        end

                        -- Health Bar (Left side)
                        local hp = f:GetHealth()
                        local maxHp = math.max(1, f:GetMaxHealth())
                        local hpPercent = math.clamp(hp / maxHp, 0, 1)

                        if Engine.Config.ESPHealth then
                            local barW = 3
                            local barX = boxX - 6
                            esp.HealthBarOutline.Size = Vector2.new(barW + 2, boxHeight + 2)
                            esp.HealthBarOutline.Position = Vector2.new(barX - 1, boxY - 1)
                            esp.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
                            esp.HealthBarOutline.Visible = true

                            local fillH = boxHeight * hpPercent
                            esp.HealthBar.Size = Vector2.new(barW, fillH)
                            esp.HealthBar.Position = Vector2.new(barX, boxY + (boxHeight - fillH))
                            esp.HealthBar.Color = Color3.fromHSV(hpPercent * 0.33, 1, 1)
                            esp.HealthBar.Visible = true
                        else
                            esp.HealthBarOutline.Visible = false
                            esp.HealthBar.Visible = false
                        end

                        -- Shield Bar (Right of health bar)
                        local shield = f:GetShield()
                        local maxShield = math.max(1, f:GetMaxShield())
                        local shieldPercent = math.clamp(shield / maxShield, 0, 1)

                        if Engine.Config.ESPShield and shield > 0 then
                            local sBarW = 3
                            local sBarX = boxX - 12
                            esp.ShieldBarOutline.Size = Vector2.new(sBarW + 2, boxHeight + 2)
                            esp.ShieldBarOutline.Position = Vector2.new(sBarX - 1, boxY - 1)
                            esp.ShieldBarOutline.Color = Color3.fromRGB(0, 0, 0)
                            esp.ShieldBarOutline.Visible = true

                            local sFillH = boxHeight * shieldPercent
                            esp.ShieldBar.Size = Vector2.new(sBarW, sFillH)
                            esp.ShieldBar.Position = Vector2.new(sBarX, boxY + (boxHeight - sFillH))
                            esp.ShieldBar.Color = Color3.fromRGB(0, 180, 255)
                            esp.ShieldBar.Visible = true
                        else
                            esp.ShieldBarOutline.Visible = false
                            esp.ShieldBar.Visible = false
                        end

                        -- Name & Distance Tag
                        if Engine.Config.ESPNames then
                            esp.NameTag.Text = p and p.DisplayName or model.Name
                            esp.NameTag.Size = 13
                            esp.NameTag.Center = true
                            esp.NameTag.Outline = true
                            esp.NameTag.Color = Color3.fromRGB(255, 255, 255)
                            esp.NameTag.Position = Vector2.new(hrpPos.X, boxY - 16)
                            esp.NameTag.Visible = true
                        else
                            esp.NameTag.Visible = false
                        end

                        -- Info Tag (Weapon & Distance)
                        if Engine.Config.ESPDistance or Engine.Config.ESPWeapon then
                            local dist = math.floor((hrp.Position - myPos).Magnitude)
                            local wName = f.EquippedItem and f.EquippedItem.Name or "None"
                            local infoStr = ""
                            if Engine.Config.ESPWeapon and Engine.Config.ESPDistance then
                                infoStr = string.format("[%s | %dm]", wName, dist)
                            elseif Engine.Config.ESPWeapon then
                                infoStr = string.format("[%s]", wName)
                            else
                                infoStr = string.format("[%dm]", dist)
                            end

                            esp.InfoTag.Text = infoStr
                            esp.InfoTag.Size = 12
                            esp.InfoTag.Center = true
                            esp.InfoTag.Outline = true
                            esp.InfoTag.Color = Color3.fromRGB(255, 215, 0)
                            esp.InfoTag.Position = Vector2.new(hrpPos.X, boxY + boxHeight + 2)
                            esp.InfoTag.Visible = true
                        else
                            esp.InfoTag.Visible = false
                        end

                        -- Tracers
                        if Engine.Config.ESPTracers then
                            esp.Tracer.From = screenBottom
                            esp.Tracer.To = Vector2.new(hrpPos.X, boxY + boxHeight)
                            esp.Tracer.Color = Engine.Config.TracerColor
                            esp.Tracer.Thickness = 1
                            esp.Tracer.Visible = true
                        else
                            esp.Tracer.Visible = false
                        end
                    else
                        for _, d in pairs(esp) do d.Visible = false end
                    end
                end
            end
        end
    end

    -- Render Shooting Range Dummies
    if Engine.Config.ESPDummies and myFighter and myFighter:Get("IsInShootingRange") then
        local srFolder = Workspace:FindFirstChild("ShootingRangeEntities")
        if srFolder then
            for _, ent in ipairs(srFolder:GetChildren()) do
                if ent.Name == "Dummy" or ent.Name == "DPS Dummy" or ent.Name == "Target" then
                    local hrp = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Primary") or ent:FindFirstChildWhichIsA("BasePart")
                    if hrp then
                        activeModels[ent] = true
                        if not Engine.ESPObjects[ent] then
                            Engine.ESPObjects[ent] = CreateESPElement()
                        end

                        local esp = Engine.ESPObjects[ent]
                        local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local boxHeight = math.clamp(1000 / math.max(1, (hrp.Position - myPos).Magnitude), 15, 120)
                            local boxWidth = boxHeight * 0.7
                            local boxX = hrpPos.X - (boxWidth / 2)
                            local boxY = hrpPos.Y - (boxHeight / 2)

                            if Engine.Config.ESPBoxes then
                                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                                esp.Box.Position = Vector2.new(boxX, boxY)
                                esp.Box.Color = Engine.Config.DummyColor
                                esp.Box.Thickness = 1
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end

                            if Engine.Config.ESPNames then
                                esp.NameTag.Text = ent.Name
                                esp.NameTag.Size = 12
                                esp.NameTag.Center = true
                                esp.NameTag.Outline = true
                                esp.NameTag.Color = Engine.Config.DummyColor
                                esp.NameTag.Position = Vector2.new(hrpPos.X, boxY - 14)
                                esp.NameTag.Visible = true
                            else
                                esp.NameTag.Visible = false
                            end

                            esp.BoxOutline.Visible = false
                            esp.HealthBarOutline.Visible = false
                            esp.HealthBar.Visible = false
                            esp.ShieldBarOutline.Visible = false
                            esp.ShieldBar.Visible = false
                            esp.InfoTag.Visible = false
                            esp.Tracer.Visible = false
                        else
                            for _, d in pairs(esp) do d.Visible = false end
                        end
                    end
                end
            end
        end
    end

    -- Clean stale models
    for model, esp in pairs(Engine.ESPObjects) do
        if not activeModels[model] then
            CleanupESPElement(esp)
            Engine.ESPObjects[model] = nil
        end
    end
end

local espConn = RunService.RenderStepped:Connect(UpdateESP)
table.insert(Engine.Connections, espConn)

--[[
    =============================================================================
    4. MOVEMENT SUBSYSTEM (Speed Detour, Bunny Hop, Infinite Jump)
    =============================================================================
--]]

-- Hook MechanicsController._UpdateWalkSpeed for seamless speed enhancement
if MechanicsController and MechanicsController._UpdateWalkSpeed then
    local origUpdateSpeed = MechanicsController._UpdateWalkSpeed
    MechanicsController._UpdateWalkSpeed = function(self)
        origUpdateSpeed(self)
        if not Engine.IsUnloaded and Engine.Config.CustomSpeed then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Engine.Config.SpeedValue
            end
        end
    end
end

-- Movement Render Loop
local moveConn = RunService.PreRender:Connect(function()
    if Engine.IsUnloaded then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Custom Speed Enforcement
    if Engine.Config.CustomSpeed and hum.WalkSpeed ~= Engine.Config.SpeedValue then
        hum.WalkSpeed = Engine.Config.SpeedValue
    end

    -- Bunny Hop (Auto jump on ground contact when space is held)
    if Engine.Config.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(Engine.Connections, moveConn)

-- Infinite Jump Listener
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if not Engine.IsUnloaded and Engine.Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(Engine.Connections, jumpConn)

--[[
    =============================================================================
    5. AUTOMATION SUBSYSTEM (Auto Range Farm, Auto Rewards)
    =============================================================================
--]]

-- Auto Farm Range Dummies Task
task.spawn(function()
    while not Engine.IsUnloaded do
        task.wait(0.1)
        if Engine.Config.AutoFarmDummies then
            local myFighter = FighterController and FighterController.LocalFighter
            if myFighter and myFighter:Get("IsInShootingRange") and myFighter.EquippedItem then
                local eq = myFighter.EquippedItem
                local dummyTarget = GetClosestTarget(math.huge)

                if dummyTarget and dummyTarget.Bone then
                    -- Align aim towards target
                    local myMuzzle = Camera.CFrame.Position
                    local aimDirection = (dummyTarget.Bone.Position - myMuzzle).Unit
                    Camera.CFrame = CFrame.new(myMuzzle, myMuzzle + aimDirection)

                    -- Shoot or reload
                    if eq:Get("Ammo") > 0 then
                        if eq.StartShooting then
                            eq:StartShooting()
                        end
                    else
                        if eq.StartReloading then
                            eq:StartReloading(true)
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Rewards Function
local function ClaimAllFreeRewards()
    local RS = game:GetService("ReplicatedStorage")
    pcall(function() RS.Remotes.Data.ClaimLoginReward:FireServer() end)
    pcall(function() RS.Remotes.Data.ClaimLikeReward:FireServer() end)
    pcall(function() RS.Remotes.Data.ClaimFavoriteReward:FireServer() end)
    pcall(function() RS.Remotes.Data.ClaimWelcomeBackGift:FireServer() end)
    pcall(function() RS.Remotes.Data.ClaimGroupReward:InvokeServer() end)
    pcall(function() RS.Remotes.Data.ClaimBattlePassReward:FireServer() end)
end

--[[
    =============================================================================
    6. CONFIGURATION SYSTEM (Save / Load / Persistence)
    =============================================================================
--]]

local ConfigPath = "RIVALS_Config.json"

local function SaveConfig()
    pcall(function()
        if writefile then
            local encoded = HttpService:JSONEncode(Engine.Config)
            writefile(ConfigPath, encoded)
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(ConfigPath) then
            local raw = readfile(ConfigPath)
            local decoded = HttpService:JSONDecode(raw)
            if decoded and typeof(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Engine.Config[k] ~= nil then
                        Engine.Config[k] = v
                        if Engine.UIElements[k] then
                            pcall(function()
                                if Engine.UIElements[k].Set then
                                    Engine.UIElements[k]:Set(v)
                                elseif Engine.UIElements[k].Select then
                                    Engine.UIElements[k]:Select(tostring(v))
                                end
                            end)
                        end
                    end
                end
                CacheAndPatchWeapons(Engine.Config.NoRecoil, Engine.Config.NoSpread)
            end
        end
    end)
end

--[[
    =============================================================================
    7. UNLOAD & LIFECYCLE MANAGEMENT
    =============================================================================
--]]

function Engine:Unload()
    if self.IsUnloaded then return end
    self.IsUnloaded = true

    -- Disconnect all event connections
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end

    -- Remove all Drawing objects
    for _, d in ipairs(self.Drawings) do
        pcall(function() d:Remove() end)
    end
    for _, esp in pairs(self.ESPObjects) do
        CleanupESPElement(esp)
    end

    -- Restore original weapon statistics
    CacheAndPatchWeapons(false, false)

    -- Destroy UI ScreenGuis
    pcall(function()
        local hui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if hui then
            for _, c in ipairs(hui:GetChildren()) do
                if c:IsA("ScreenGui") and (c.Name:find("WindUI") or c.Name == "RIVALS_FloatingBtn") then
                    c:Destroy()
                end
            end
        end
    end)

    _G.RivalsEngine = nil
end

_G.RivalsEngine = Engine

--[[
    =============================================================================
    8. WINDUI FRAMEWORK INTERFACE (Strict SOP: By XLunaHUB, English, ALL OFF)
    =============================================================================
--]]

local WindUI = nil
local ok, res = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if ok and res then
    WindUI = res
else
    warn("[RIVALS] Failed to load WindUI library.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "RIVALS | Tactical Engine",
    Icon = "shield",
    Author = "By XLunaHUB",
    Folder = "RIVALS_Config",
    Size = UDim2.fromOffset(590, 430),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    ToggleKey = Enum.KeyCode.LeftControl,
})

-- TAB 1: COMBAT
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })

CombatTab:Section({ Title = "Targeting & Aim Assist" })

Engine.UIElements.Aimbot = CombatTab:Toggle({
    Title = "Camera Aimbot (Hold RMB)",
    Desc = "Smoothly aligns camera crosshair towards nearest target bone",
    Value = false,
    Callback = function(val)
        Engine.Config.Aimbot = val
    end
})

Engine.UIElements.SilentAim = CombatTab:Toggle({
    Title = "Silent Aim (Bullet Redirection)",
    Desc = "Redirects raycast trajectories straight to target bone via engine hook",
    Value = false,
    Callback = function(val)
        Engine.Config.SilentAim = val
    end
})

Engine.UIElements.Triggerbot = CombatTab:Toggle({
    Title = "Triggerbot (Auto Fire On Crosshair)",
    Desc = "Automatically discharges weapon when crosshair hovers over target",
    Value = false,
    Callback = function(val)
        Engine.Config.Triggerbot = val
    end
})

Engine.UIElements.AimbotPart = CombatTab:Dropdown({
    Title = "Aim Target Bone",
    Desc = "Select specific anatomical hitbox to prioritize",
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Value = "Head",
    Callback = function(val)
        Engine.Config.AimbotPart = val
    end
})

Engine.UIElements.AimbotSmooth = CombatTab:Slider({
    Title = "Aimbot Smoothing",
    Desc = "Interpolation factor for mouse movement (1 = Instant snap)",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = 3 },
    Callback = function(val)
        Engine.Config.AimbotSmooth = val
    end
})

Engine.UIElements.AimbotFOV = CombatTab:Slider({
    Title = "Aimbot FOV Radius",
    Desc = "Maximum pixel distance from screen center for target acquisition",
    Step = 5,
    Value = { Min = 30, Max = 400, Default = 120 },
    Callback = function(val)
        Engine.Config.AimbotFOV = val
    end
})

Engine.UIElements.ShowFOV = CombatTab:Toggle({
    Title = "Show FOV Circle",
    Desc = "Draws dynamic circle representing aimbot target boundary",
    Value = false,
    Callback = function(val)
        Engine.Config.ShowFOV = val
    end
})

CombatTab:Section({ Title = "Gunplay Enhancements" })

Engine.UIElements.NoRecoil = CombatTab:Toggle({
    Title = "No Recoil (Zero Camera Kick)",
    Desc = "Nullifies weapon displacement impulse and camera recoil springs",
    Value = false,
    Callback = function(val)
        Engine.Config.NoRecoil = val
        CacheAndPatchWeapons(Engine.Config.NoRecoil, Engine.Config.NoSpread)
    end
})

Engine.UIElements.NoSpread = CombatTab:Toggle({
    Title = "No Spread (Laser Precision)",
    Desc = "Zeroes bullet dispersion angle and spread per velocity",
    Value = false,
    Callback = function(val)
        Engine.Config.NoSpread = val
        CacheAndPatchWeapons(Engine.Config.NoRecoil, Engine.Config.NoSpread)
    end
})

Engine.UIElements.AutoReload = CombatTab:Toggle({
    Title = "Auto Reload On Empty",
    Desc = "Instantly initiates reload sequence when magazine reaches 0",
    Value = false,
    Callback = function(val)
        Engine.Config.AutoReload = val
    end
})

CombatTab:Section({ Title = "Target Filtering" })

Engine.UIElements.TeamCheck = CombatTab:Toggle({
    Title = "Team Check",
    Desc = "Ignores friendly players on identical teams",
    Value = false,
    Callback = function(val)
        Engine.Config.TeamCheck = val
    end
})

Engine.UIElements.TargetPlayers = CombatTab:Toggle({
    Title = "Target Players",
    Desc = "Include player fighters in target evaluation queue",
    Value = false,
    Callback = function(val)
        Engine.Config.TargetPlayers = val
    end
})

Engine.UIElements.TargetDummies = CombatTab:Toggle({
    Title = "Target Range Dummies",
    Desc = "Include shooting range dummies in target evaluation queue",
    Value = false,
    Callback = function(val)
        Engine.Config.TargetDummies = val
    end
})

-- TAB 2: VISUALS (ESP)
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

VisualsTab:Section({ Title = "Master Visual Overlay" })

Engine.UIElements.ESPEnabled = VisualsTab:Toggle({
    Title = "Master ESP",
    Desc = "Master switch for all visual telemetry and entity indicators",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPEnabled = val
    end
})

VisualsTab:Section({ Title = "Entity Elements" })

Engine.UIElements.ESPBoxes = VisualsTab:Toggle({
    Title = "Bounding Boxes (2D Box)",
    Desc = "Draws high-contrast rectangular bounding frames around targets",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPBoxes = val
    end
})

Engine.UIElements.ESPHealth = VisualsTab:Toggle({
    Title = "Health Bars",
    Desc = "Dynamic color-coded health meters reflecting target hit points",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPHealth = val
    end
})

Engine.UIElements.ESPShield = VisualsTab:Toggle({
    Title = "Shield Bars",
    Desc = "Cyan shield meters reflecting armor barrier levels",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPShield = val
    end
})

Engine.UIElements.ESPNames = VisualsTab:Toggle({
    Title = "Player Names",
    Desc = "Displays target username or entity tag above character",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPNames = val
    end
})

Engine.UIElements.ESPDistance = VisualsTab:Toggle({
    Title = "Distance Indicator",
    Desc = "Renders exact metric distance in studs to target",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPDistance = val
    end
})

Engine.UIElements.ESPWeapon = VisualsTab:Toggle({
    Title = "Equipped Weapon Tag",
    Desc = "Displays active firearm or item currently held by target",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPWeapon = val
    end
})

Engine.UIElements.ESPTracers = VisualsTab:Toggle({
    Title = "Snaplines / Tracers",
    Desc = "Draws direct directional lines from screen bottom to target",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPTracers = val
    end
})

Engine.UIElements.ESPDummies = VisualsTab:Toggle({
    Title = "Shooting Range Dummy ESP",
    Desc = "Highlights targets and dummies within the Shooting Range",
    Value = false,
    Callback = function(val)
        Engine.Config.ESPDummies = val
    end
})

-- TAB 3: MOVEMENT
local MovementTab = Window:Tab({ Title = "Movement", Icon = "zap" })

MovementTab:Section({ Title = "Locomotion Modifiers" })

Engine.UIElements.CustomSpeed = MovementTab:Toggle({
    Title = "Speed Boost",
    Desc = "Seamlessly detours MechanicsController walk speed calculations",
    Value = false,
    Callback = function(val)
        Engine.Config.CustomSpeed = val
        if MechanicsController and MechanicsController._UpdateWalkSpeed then
            MechanicsController:_UpdateWalkSpeed()
        end
    end
})

Engine.UIElements.SpeedValue = MovementTab:Slider({
    Title = "Speed Multiplier",
    Desc = "Custom locomotion velocity (Default: 14.4)",
    Step = 1,
    Value = { Min = 16, Max = 45, Default = 26 },
    Callback = function(val)
        Engine.Config.SpeedValue = val
        if Engine.Config.CustomSpeed and MechanicsController and MechanicsController._UpdateWalkSpeed then
            MechanicsController:_UpdateWalkSpeed()
        end
    end
})

Engine.UIElements.BunnyHop = MovementTab:Toggle({
    Title = "Bunny Hop (Auto Jump)",
    Desc = "Continuously jumps on floor contact while holding Spacebar",
    Value = false,
    Callback = function(val)
        Engine.Config.BunnyHop = val
    end
})

Engine.UIElements.InfiniteJump = MovementTab:Toggle({
    Title = "Infinite Jump (Air Jump)",
    Desc = "Enables mid-air jumping on every Spacebar actuation",
    Value = false,
    Callback = function(val)
        Engine.Config.InfiniteJump = val
    end
})

-- TAB 4: AUTOMATION
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })

AutoTab:Section({ Title = "Shooting Range & Combat Automation" })

Engine.UIElements.AutoFarmDummies = AutoTab:Toggle({
    Title = "Auto Farm Range Dummies",
    Desc = "Continuously aims and shoots nearest dummy inside Shooting Range",
    Value = false,
    Callback = function(val)
        Engine.Config.AutoFarmDummies = val
    end
})

AutoTab:Button({
    Title = "Enter Shooting Range",
    Desc = "Remotely teleports character directly into the Shooting Range",
    Callback = function()
        if ShootingRangeController and ShootingRangeController.Enter then
            ShootingRangeController:Enter()
        end
    end
})

AutoTab:Button({
    Title = "Leave Shooting Range",
    Desc = "Remotely teleports character back to the Main Hub",
    Callback = function()
        if ShootingRangeController and ShootingRangeController.Leave then
            ShootingRangeController:Leave()
        end
    end
})

AutoTab:Section({ Title = "Economy & Progression" })

AutoTab:Button({
    Title = "Claim All Free Rewards",
    Desc = "Fires all daily login, like, favorite, and group reward remotes",
    Callback = function()
        ClaimAllFreeRewards()
    end
})

Engine.UIElements.AntiAFK = AutoTab:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents client disconnection due to 20-minute inactivity timer",
    Value = false,
    Callback = function(val)
        Engine.Config.AntiAFK = val
    end
})

-- TAB 5: CONFIGURATION & PERSISTENCE
local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })

ConfigTab:Section({ Title = "Profile Management" })

ConfigTab:Button({
    Title = "Save Configuration",
    Desc = "Persists active toggle and slider states to RIVALS_Config.json",
    Callback = function()
        SaveConfig()
    end
})

ConfigTab:Button({
    Title = "Load Configuration",
    Desc = "Restores all states from saved profile RIVALS_Config.json",
    Callback = function()
        LoadConfig()
    end
})

ConfigTab:Button({
    Title = "Reset All to Default (ALL OFF)",
    Desc = "Restores all tactical features to strictly disabled default states",
    Callback = function()
        for k, _ in pairs(Engine.Config) do
            if typeof(Engine.Config[k]) == "boolean" then
                Engine.Config[k] = false
                if Engine.UIElements[k] and Engine.UIElements[k].Set then
                    Engine.UIElements[k]:Set(false)
                end
            end
        end
        CacheAndPatchWeapons(false, false)
    end
})

ConfigTab:Section({ Title = "Kernel Lifecycle" })

ConfigTab:Button({
    Title = "Clean Unload Engine",
    Desc = "Disconnects all hooks, cleans drawings, and terminates UI cleanly",
    Callback = function()
        Engine:Unload()
    end
})

--[[
    =============================================================================
    9. SLEEK DRAGGABLE FLOATING ACTION BUTTON
    =============================================================================
--]]

local floatGuiParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")
local floatScreenGui = Instance.new("ScreenGui")
floatScreenGui.Name = "RIVALS_FloatingBtn"
floatScreenGui.ResetOnSpawn = false
floatScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(floatScreenGui) end
end)
floatScreenGui.Parent = floatGuiParent

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "TogglePill"
floatBtn.Size = UDim2.fromOffset(48, 48)
floatBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
floatBtn.BorderColor3 = Color3.fromRGB(255, 60, 60)
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = false
floatBtn.Image = "rbxassetid://10709791437" -- Shield Icon
floatBtn.ImageColor3 = Color3.fromRGB(255, 60, 60)
floatBtn.Parent = floatScreenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = floatBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 60, 60)
btnStroke.Thickness = 1.8
btnStroke.Transparency = 0.2
btnStroke.Parent = floatBtn

-- Draggable Mechanics
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
        floatBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle Visibility with Debounce
local lastToggle = 0
local function ToggleUI()
    if tick() - lastToggle < 0.25 then return end
    lastToggle = tick()
    if Window then
        pcall(function()
            if Window.Toggle then
                Window:Toggle()
            elseif Window.Frame then
                Window.Frame.Visible = not Window.Frame.Visible
            end
        end)
    end
end

floatBtn.MouseButton1Click:Connect(ToggleUI)

-- Clean LeftControl Keybind Handling (Single-event, no double-firing)
local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleUI()
    end
end)
table.insert(Engine.Connections, keybindConn)

-- Button Hover Animation
floatBtn.MouseEnter:Connect(function()
    TweenService:Create(floatBtn, TweenInfo.new(0.2), {Size = UDim2.fromOffset(52, 52)}):Play()
end)
floatBtn.MouseLeave:Connect(function()
    TweenService:Create(floatBtn, TweenInfo.new(0.2), {Size = UDim2.fromOffset(48, 48)}):Play()
end)

print("[RIVALS] Tactical Kernel initialized successfully. By XLunaHUB.")
