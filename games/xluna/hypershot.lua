-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    Hypershot Tactical Automation Engine (Persistent, Full Suite Edition)
    Target: Place 100040622766961
    Architecture: Real + WindUI Framework
    Defaults: ALL FEATURES OFF ON STARTUP (Manual activation)
    Features:
      - Bullet Magnet: Trajectory Redirection towards Aimbot Target inside FOV
      - Auto Shoot with Wall Check: Strict Line-of-Sight verification (HumanoidRootPart must be visible)
      - No Ability Cooldown
      - Player Speed & Infinity Jump
      - Match & Farm Automation
      - Save / Load Config (with full visual/chams restore)
--]]

if _G.HypershotEngine and _G.HypershotEngine.Unload then
    pcall(function() _G.HypershotEngine:Unload() end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")
end

local function GetLocalPlayer()
    return Players.LocalPlayer
end

local function GetLocalRoot()
    local lp = GetLocalPlayer()
    if not lp then return nil end
    local char = lp.Character or (Workspace:FindFirstChild("Entities") and Workspace.Entities:FindFirstChild(lp.Name))
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local Engine = {
    Connections = {},
    Drawings = {},
    Highlights = {},
    GuiInstances = {},
    UIElements = {},
    Enabled = true,
    UIVisible = true,
    CurrentTarget = nil,
    CurrentTargetPart = nil,
    Settings = {
        Aimbot = {
            Enabled = false,
            EnemyOnly = false,
            TriggerKey = "LMB",
            AimBullet = false,
            AutoShoot = false,
            AutoShootWallCheck = false,
            BulletMagnet = false,
            AimPart = "Head",
            FOV = 150,
            Smoothing = 0.2,
            ShowFOV = false,
            WallCheck = false,
            TargetBots = false,
            TargetPlayers = false,
        },
        ESP = {
            Enabled = false,
            AlwaysOnTop = false,
            FillTransparency = 0.7,
            OutlineTransparency = 0.1,
            EnemyColor = Color3.fromRGB(255, 30, 30),
            FriendColor = Color3.fromRGB(0, 255, 180),
        },
        WeaponMods = {
            InfiniteAmmo = false,
            NoRecoil = false,
            NoAbilityCooldown = false,
            HitboxExpander = false,
            HitboxSize = 4,
        },
        Movement = {
            SpeedEnabled = false,
            SpeedValue = 35,
            InfiniteJump = false,
        },
        Loot = {
            AutoLoot = false,
            VacuumRadius = 1000,
            LootDroppables = false,
            LootWeapons = false,
        },
        Automation = {
            AutoMatch = false,
            AutoRematch = false,
            AutoSpawn = false,
        }
    }
}

_G.HypershotEngine = Engine

--[[ 1. CONFIGURATION SYSTEM (SAVE & LOAD) ]]--
local CONFIG_FILE = "Hypershot_Config.json"

local function ColorToTable(c)
    return { R = c.R, G = c.G, B = c.B }
end

local function TableToColor(t, default)
    if type(t) == "table" and t.R and t.G and t.B then
        return Color3.new(t.R, t.G, t.B)
    end
    return default
end

local function SaveConfig()
    local cfg = {
        Aimbot = {
            Enabled = Engine.Settings.Aimbot.Enabled,
            EnemyOnly = Engine.Settings.Aimbot.EnemyOnly,
            TriggerKey = Engine.Settings.Aimbot.TriggerKey,
            AimBullet = Engine.Settings.Aimbot.AimBullet,
            AutoShoot = Engine.Settings.Aimbot.AutoShoot,
            AutoShootWallCheck = Engine.Settings.Aimbot.AutoShootWallCheck,
            BulletMagnet = Engine.Settings.Aimbot.BulletMagnet,
            AimPart = Engine.Settings.Aimbot.AimPart,
            FOV = Engine.Settings.Aimbot.FOV,
            Smoothing = Engine.Settings.Aimbot.Smoothing,
            ShowFOV = Engine.Settings.Aimbot.ShowFOV,
            WallCheck = Engine.Settings.Aimbot.WallCheck,
            TargetBots = Engine.Settings.Aimbot.TargetBots,
            TargetPlayers = Engine.Settings.Aimbot.TargetPlayers,
        },
        ESP = {
            Enabled = Engine.Settings.ESP.Enabled,
            AlwaysOnTop = Engine.Settings.ESP.AlwaysOnTop,
            FillTransparency = Engine.Settings.ESP.FillTransparency,
            OutlineTransparency = Engine.Settings.ESP.OutlineTransparency,
            EnemyColor = ColorToTable(Engine.Settings.ESP.EnemyColor),
            FriendColor = ColorToTable(Engine.Settings.ESP.FriendColor),
        },
        WeaponMods = {
            InfiniteAmmo = Engine.Settings.WeaponMods.InfiniteAmmo,
            NoRecoil = Engine.Settings.WeaponMods.NoRecoil,
            NoAbilityCooldown = Engine.Settings.WeaponMods.NoAbilityCooldown,
            HitboxExpander = Engine.Settings.WeaponMods.HitboxExpander,
            HitboxSize = Engine.Settings.WeaponMods.HitboxSize,
        },
        Movement = {
            SpeedEnabled = Engine.Settings.Movement.SpeedEnabled,
            SpeedValue = Engine.Settings.Movement.SpeedValue,
            InfiniteJump = Engine.Settings.Movement.InfiniteJump,
        },
        Loot = {
            AutoLoot = Engine.Settings.Loot.AutoLoot,
            VacuumRadius = Engine.Settings.Loot.VacuumRadius,
            LootDroppables = Engine.Settings.Loot.LootDroppables,
            LootWeapons = Engine.Settings.Loot.LootWeapons,
        },
        Automation = {
            AutoMatch = Engine.Settings.Automation.AutoMatch,
            AutoRematch = Engine.Settings.Automation.AutoRematch,
            AutoSpawn = Engine.Settings.Automation.AutoSpawn,
        }
    }

    local jsonStr = HttpService:JSONEncode(cfg)
    if writefile then
        pcall(function() writefile(CONFIG_FILE, jsonStr) end)
    end
end

local UpdateChams

local function LoadConfig()
    if not (readfile and isfile and isfile(CONFIG_FILE)) then
        return false
    end

    local s, content = pcall(function() return readfile(CONFIG_FILE) end)
    if not s or not content or content == "" then return false end

    local s2, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not s2 or type(data) ~= "table" then return false end

    if data.Aimbot then
        for k, v in pairs(data.Aimbot) do
            if Engine.Settings.Aimbot[k] ~= nil then Engine.Settings.Aimbot[k] = v end
        end
    end

    if data.ESP then
        if data.ESP.Enabled ~= nil then Engine.Settings.ESP.Enabled = data.ESP.Enabled end
        if data.ESP.AlwaysOnTop ~= nil then Engine.Settings.ESP.AlwaysOnTop = data.ESP.AlwaysOnTop end
        if data.ESP.FillTransparency ~= nil then Engine.Settings.ESP.FillTransparency = data.ESP.FillTransparency end
        if data.ESP.OutlineTransparency ~= nil then Engine.Settings.ESP.OutlineTransparency = data.ESP.OutlineTransparency end
        if data.ESP.EnemyColor ~= nil then Engine.Settings.ESP.EnemyColor = TableToColor(data.ESP.EnemyColor, Engine.Settings.ESP.EnemyColor) end
        if data.ESP.FriendColor ~= nil then Engine.Settings.ESP.FriendColor = TableToColor(data.ESP.FriendColor, Engine.Settings.ESP.FriendColor) end
    end

    if data.WeaponMods then
        for k, v in pairs(data.WeaponMods) do
            if Engine.Settings.WeaponMods[k] ~= nil then Engine.Settings.WeaponMods[k] = v end
        end
    end

    if data.Movement then
        for k, v in pairs(data.Movement) do
            if Engine.Settings.Movement[k] ~= nil then Engine.Settings.Movement[k] = v end
        end
    end

    if data.Loot then
        for k, v in pairs(data.Loot) do
            if Engine.Settings.Loot[k] ~= nil then Engine.Settings.Loot[k] = v end
        end
    end

    if data.Automation then
        for k, v in pairs(data.Automation) do
            if Engine.Settings.Automation[k] ~= nil then Engine.Settings.Automation[k] = v end
        end
    end

    for name, el in pairs(Engine.UIElements) do
        pcall(function()
            local fn = el.Set or el.SetValue
            if fn then
                if name == "AimbotEnabled" then fn(el, Engine.Settings.Aimbot.Enabled)
                elseif name == "EnemyOnly" then fn(el, Engine.Settings.Aimbot.EnemyOnly)
                elseif name == "TriggerKey" then fn(el, Engine.Settings.Aimbot.TriggerKey)
                elseif name == "AimBullet" then fn(el, Engine.Settings.Aimbot.AimBullet)
                elseif name == "AutoShoot" then fn(el, Engine.Settings.Aimbot.AutoShoot)
                elseif name == "AutoShootWallCheck" then fn(el, Engine.Settings.Aimbot.AutoShootWallCheck)
                elseif name == "BulletMagnet" then fn(el, Engine.Settings.Aimbot.BulletMagnet)
                elseif name == "AimPart" then fn(el, Engine.Settings.Aimbot.AimPart)
                elseif name == "AimbotFOV" then fn(el, Engine.Settings.Aimbot.FOV)
                elseif name == "Smoothing" then fn(el, Engine.Settings.Aimbot.Smoothing)
                elseif name == "ShowFOV" then fn(el, Engine.Settings.Aimbot.ShowFOV)
                elseif name == "WallCheck" then fn(el, Engine.Settings.Aimbot.WallCheck)
                elseif name == "TargetBots" then fn(el, Engine.Settings.Aimbot.TargetBots)
                elseif name == "TargetPlayers" then fn(el, Engine.Settings.Aimbot.TargetPlayers)
                elseif name == "ESPEnabled" then fn(el, Engine.Settings.ESP.Enabled)
                elseif name == "AlwaysOnTop" then fn(el, Engine.Settings.ESP.AlwaysOnTop)
                elseif name == "FillTransparency" then fn(el, Engine.Settings.ESP.FillTransparency)
                elseif name == "EnemyColor" then fn(el, Engine.Settings.ESP.EnemyColor)
                elseif name == "InfiniteAmmo" then fn(el, Engine.Settings.WeaponMods.InfiniteAmmo)
                elseif name == "NoRecoil" then fn(el, Engine.Settings.WeaponMods.NoRecoil)
                elseif name == "NoAbilityCooldown" then fn(el, Engine.Settings.WeaponMods.NoAbilityCooldown)
                elseif name == "HitboxExpander" then fn(el, Engine.Settings.WeaponMods.HitboxExpander)
                elseif name == "HitboxSize" then fn(el, Engine.Settings.WeaponMods.HitboxSize)
                elseif name == "SpeedEnabled" then fn(el, Engine.Settings.Movement.SpeedEnabled)
                elseif name == "SpeedValue" then fn(el, Engine.Settings.Movement.SpeedValue)
                elseif name == "InfiniteJump" then fn(el, Engine.Settings.Movement.InfiniteJump)
                elseif name == "AutoLoot" then fn(el, Engine.Settings.Loot.AutoLoot)
                elseif name == "LootDroppables" then fn(el, Engine.Settings.Loot.LootDroppables)
                elseif name == "LootWeapons" then fn(el, Engine.Settings.Loot.LootWeapons)
                elseif name == "VacuumRadius" then fn(el, Engine.Settings.Loot.VacuumRadius)
                elseif name == "AutoMatch" then fn(el, Engine.Settings.Automation.AutoMatch)
                elseif name == "AutoRematch" then fn(el, Engine.Settings.Automation.AutoRematch)
                elseif name == "AutoSpawn" then fn(el, Engine.Settings.Automation.AutoSpawn)
                end
            end
        end)
    end

    -- Force instant Chams update across all current entities
    task.spawn(function()
        for i = 1, 3 do
            if UpdateChams then
                pcall(UpdateChams)
            end
            task.wait(0.1)
        end
    end)

    return true
end

--[[ 2. FOV CIRCLE INITIALIZATION ]]--
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Radius = Engine.Settings.Aimbot.FOV
table.insert(Engine.Drawings, FOVCircle)

--[[ 3. TARGET & LINE OF SIGHT UTILITIES ]]--
local function GetEntitiesFolder()
    return Workspace:FindFirstChild("Entities")
end

local function IsAlive(entity)
    if not entity or not entity.Parent then return false end
    local hum = entity:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.Health > 0 then
        return true
    end
    return false
end

local function IsBot(entity)
    return entity.Name:find("__Bot") ~= nil
end

local function IsEnemy(entity)
    if not entity then return false end
    local lp = GetLocalPlayer()
    if not lp then return false end
    if entity.Name == lp.Name then return false end

    if entity:GetAttribute("LobbyCharacter") or entity:GetAttribute("MenuCharacter") then
        return false
    end

    local enemyHl = entity:FindFirstChild("EnemyHighlight")
    local friendHl = entity:FindFirstChild("PlayerOutline") or entity:FindFirstChild("FriendlyOutline")

    if friendHl and not enemyHl then
        return false
    end
    if enemyHl then
        return true
    end

    local myModel = Workspace:FindFirstChild("Entities") and Workspace.Entities:FindFirstChild(lp.Name)
    local myTeam = myModel and (myModel:GetAttribute("Team") or myModel:GetAttribute("TeamColor")) or (lp.Team and lp.Team.Name)
    local entityTeam = entity:GetAttribute("Team") or entity:GetAttribute("TeamColor")

    if myTeam and entityTeam then
        return myTeam ~= entityTeam
    end

    local otherPlr = Players:FindFirstChild(entity.Name)
    if otherPlr and lp.Team and otherPlr.Team then
        return lp.Team ~= otherPlr.Team
    end

    return true
end

local function IsVisibleLOS(originPos, targetPart, entity)
    local lp = GetLocalPlayer()
    local myName = lp and lp.Name
    local myModel = myName and Workspace:FindFirstChild("Entities") and Workspace.Entities:FindFirstChild(myName)
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {
        myModel,
        entity,
        Workspace:FindFirstChild("IgnoreThese"),
        Workspace:FindFirstChild("Camera")
    }
    
    local raycastResult = Workspace:Raycast(originPos, targetPart.Position - originPos, rayParams)
    return raycastResult == nil
end

local function GetTargetPart(entity, partName)
    if not entity then return nil end
    local part = entity:FindFirstChild(partName)
    if not part then
        part = entity:FindFirstChild("Head") or entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("UpperTorso")
    end
    return part
end

local function WorldToScreen(worldPos)
    local cam = GetCamera()
    if not cam then return Vector2.zero, false, 0 end
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetClosestTarget()
    local folder = GetEntitiesFolder()
    local cam = GetCamera()
    local lp = GetLocalPlayer()
    if not folder or not cam or not lp then return nil end

    local myName = lp.Name
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closestDist = Engine.Settings.Aimbot.FOV
    local targetEntity = nil
    local targetPartInstance = nil

    for _, entity in ipairs(folder:GetChildren()) do
        if entity.Name ~= myName and IsAlive(entity) then
            local passTeamCheck = true
            if Engine.Settings.Aimbot.EnemyOnly then
                passTeamCheck = IsEnemy(entity)
            end

            if passTeamCheck then
                local isBot = IsBot(entity)
                if (isBot and Engine.Settings.Aimbot.TargetBots) or (not isBot and Engine.Settings.Aimbot.TargetPlayers) then
                    local part = GetTargetPart(entity, Engine.Settings.Aimbot.AimPart)
                    if part then
                        local screenPos, onScreen, depth = WorldToScreen(part.Position)
                        if onScreen and depth > 0 then
                            local dist = (screenPos - center).Magnitude
                            if dist <= closestDist then
                                if Engine.Settings.Aimbot.WallCheck then
                                    if IsVisibleLOS(cam.CFrame.Position, part, entity) then
                                        closestDist = dist
                                        targetEntity = entity
                                        targetPartInstance = part
                                    end
                                else
                                    closestDist = dist
                                    targetEntity = entity
                                    targetPartInstance = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return targetEntity, targetPartInstance
end

--[[ 4. AIMBOT, BULLET MAGNET & AUTO SHOOT ]]--
local function IsTriggerActive()
    if Engine.Settings.Aimbot.TriggerKey == "LMB" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    else
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
end

local AimbotConnection = RunService.RenderStepped:Connect(function()
    local cam = GetCamera()
    if not cam then return end

    FOVCircle.Visible = Engine.Settings.Aimbot.ShowFOV and Engine.Settings.Aimbot.Enabled
    FOVCircle.Radius = Engine.Settings.Aimbot.FOV
    FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    local targetEntity, targetPart = GetClosestTarget()
    Engine.CurrentTarget = targetEntity
    Engine.CurrentTargetPart = targetPart

    if not Engine.Settings.Aimbot.Enabled then return end

    local userHoldingTrigger = IsTriggerActive()
    local autoShootActive = Engine.Settings.Aimbot.AutoShoot

    if targetEntity and targetPart then
        local currentCF = cam.CFrame
        local targetPos = targetPart.Position
        
        local vel = Vector3.zero
        local root = targetEntity:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            vel = root.AssemblyLinearVelocity
        end
        local compensatedPos = targetPos + (vel * 0.035)

        if Engine.Settings.Aimbot.BulletMagnet then
            cam.CFrame = CFrame.new(currentCF.Position, compensatedPos)
        elseif userHoldingTrigger then
            if Engine.Settings.Aimbot.AimBullet then
                cam.CFrame = CFrame.new(currentCF.Position, compensatedPos)
            else
                local desiredCF = CFrame.new(currentCF.Position, compensatedPos)
                local smooth = math.clamp(1 - Engine.Settings.Aimbot.Smoothing, 0.05, 1)
                cam.CFrame = currentCF:Lerp(desiredCF, smooth)
            end
        end

        if autoShootActive then
            local canShoot = true
            if Engine.Settings.Aimbot.AutoShootWallCheck then
                local checkPart = root or targetPart
                canShoot = IsVisibleLOS(cam.CFrame.Position, checkPart, targetEntity)
            end

            if canShoot then
                pcall(function()
                    if mouse1press and mouse1release then
                        mouse1press()
                        task.defer(mouse1release)
                    else
                        local fp = GetLocalPlayer().PlayerGui:FindFirstChild("FirstPersonGUI")
                        if fp and fp:FindFirstChild("ActionHandler") and fp.ActionHandler:FindFirstChild("Shared") then
                            local s = require(fp.ActionHandler.Shared)
                            if s.CurrTool and s.CurrTool.ShootLogic then
                                s.CurrTool:ShootLogic()
                            end
                        end
                    end
                end)
            end
        end
    end
end)
table.insert(Engine.Connections, AimbotConnection)

--[[ 5. CLEAN WALLHACK / CHAMS OVERRIDE ]]--
UpdateChams = function()
    local folder = GetEntitiesFolder()
    local lp = GetLocalPlayer()
    if not folder or not lp then return end
    local myName = lp.Name

    for _, entity in ipairs(folder:GetChildren()) do
        if entity.Name ~= myName and IsAlive(entity) then
            for _, hl in ipairs(entity:GetChildren()) do
                if hl:IsA("Highlight") then
                    if Engine.Settings.ESP.Enabled then
                        hl.Enabled = true
                        hl.DepthMode = Engine.Settings.ESP.AlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                        hl.FillTransparency = Engine.Settings.ESP.FillTransparency
                        hl.OutlineTransparency = Engine.Settings.ESP.OutlineTransparency
                        if hl.Name == "EnemyHighlight" then
                            hl.FillColor = Engine.Settings.ESP.EnemyColor
                            hl.OutlineColor = Engine.Settings.ESP.EnemyColor
                        else
                            hl.FillColor = Engine.Settings.ESP.FriendColor
                            hl.OutlineColor = Engine.Settings.ESP.FriendColor
                        end
                    else
                        hl.DepthMode = Enum.HighlightDepthMode.Occluded
                    end
                end
            end
        end
    end
end

local ESPConnection = RunService.Heartbeat:Connect(function()
    UpdateChams()
end)
table.insert(Engine.Connections, ESPConnection)

--[[ 6. WEAPON BUFFERS, HITBOX SCALER & NO ABILITY COOLDOWN ]]--
local WeaponConnection = RunService.Heartbeat:Connect(function()
    local lp = GetLocalPlayer()
    if not lp then return end

    if Engine.Settings.WeaponMods.InfiniteAmmo then
        pcall(function()
            local fp = lp.PlayerGui:FindFirstChild("FirstPersonGUI")
            if fp and fp:FindFirstChild("ActionHandler") then
                local sharedMod = fp.ActionHandler:FindFirstChild("Shared")
                if sharedMod then
                    local s = require(sharedMod)
                    local curr = s.CurrTool
                    if curr then
                        curr.Ammo = (curr.WSettings and curr.WSettings.Ammo) or 99
                        curr.FillAmmo = 999
                    end
                end
            end
        end)
    end

    if Engine.Settings.WeaponMods.NoRecoil then
        pcall(function()
            local actionHandler = lp.PlayerGui:FindFirstChild("FirstPersonGUI")
            if actionHandler then
                local recoilMod = actionHandler:FindFirstChild("ActionHandler")
                if recoilMod and recoilMod:FindFirstChild("ViewModel") then
                    local recoilScript = recoilMod.ViewModel:FindFirstChild("Recoil")
                    if recoilScript then
                        local recoilReq = require(recoilScript)
                        if recoilReq and recoilReq.GetCamRecoilSpring then
                            local spr = recoilReq:GetCamRecoilSpring()
                            if spr then
                                spr.Velocity = Vector3.zero
                                spr.Position = Vector3.zero
                            end
                        end
                    end
                end
            end
        end)
    end

    if Engine.Settings.WeaponMods.NoAbilityCooldown then
        pcall(function()
            local abClient = require(ReplicatedStorage.Entity.AbilityClient)
            for i = 1, 4 do
                local ch = abClient:GetCharges(i)
                if ch then
                    ch[1] = 99
                    ch[2] = 99
                end
            end
            if abClient.ChargesChanged then
                abClient.ChargesChanged:Fire()
            end
        end)
    end

    if Engine.Settings.WeaponMods.HitboxExpander then
        local folder = GetEntitiesFolder()
        if folder then
            local myName = lp.Name
            local scale = Engine.Settings.WeaponMods.HitboxSize
            for _, entity in ipairs(folder:GetChildren()) do
                if entity.Name ~= myName and IsAlive(entity) then
                    if not Engine.Settings.Aimbot.EnemyOnly or IsEnemy(entity) then
                        local head = entity:FindFirstChild("Head")
                        if head and head:IsA("BasePart") then
                            head.Size = Vector3.new(scale, scale, scale)
                            head.Transparency = 0.6
                            head.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)
table.insert(Engine.Connections, WeaponConnection)

--[[ 7. PLAYER MOVEMENT & INFINITE JUMP ]]--
local MovementConnection = RunService.Heartbeat:Connect(function()
    local lp = GetLocalPlayer()
    if not lp then return end
    local char = lp.Character or (Workspace:FindFirstChild("Entities") and Workspace.Entities:FindFirstChild(lp.Name))
    if not char then return end

    if Engine.Settings.Movement.SpeedEnabled then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = Engine.Settings.Movement.SpeedValue
        end
        char:SetAttribute("BaseWS", Engine.Settings.Movement.SpeedValue)
    end
end)
table.insert(Engine.Connections, MovementConnection)

local JumpConnection = UserInputService.JumpRequest:Connect(function()
    if Engine.Settings.Movement.InfiniteJump then
        local lp = GetLocalPlayer()
        local char = lp and (lp.Character or (Workspace:FindFirstChild("Entities") and Workspace.Entities:FindFirstChild(lp.Name)))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(Engine.Connections, JumpConnection)

--[[ 8. AUTO LOOTING & VACUUM MAGNET ]]--
local LootConnection = RunService.Heartbeat:Connect(function()
    if not Engine.Settings.Loot.AutoLoot then return end

    local myRoot = GetLocalRoot()
    if not myRoot then return end

    local ignore = Workspace:FindFirstChild("IgnoreThese")
    local pickups = ignore and ignore:FindFirstChild("Pickups")
    if not pickups then return end

    local myPos = myRoot.Position
    local maxDist = Engine.Settings.Loot.VacuumRadius

    for _, folder in ipairs(pickups:GetChildren()) do
        local folderName = folder.Name
        local isWeaponFolder = (folderName == "Weapons")
        
        if (not isWeaponFolder and Engine.Settings.Loot.LootDroppables) or (isWeaponFolder and Engine.Settings.Loot.LootWeapons) then
            for _, item in ipairs(folder:GetChildren()) do
                local rootPart = item:IsA("BasePart") and item or (item:FindFirstChildWhichIsA("BasePart"))
                if rootPart then
                    local dist = (rootPart.Position - myPos).Magnitude
                    if dist <= maxDist then
                        if item:IsA("Model") then
                            item:PivotTo(myRoot.CFrame * CFrame.new(0, -1, 0))
                        else
                            rootPart.CFrame = myRoot.CFrame * CFrame.new(0, -1, 0)
                        end
                    end
                end
            end
        end
    end
end)
table.insert(Engine.Connections, LootConnection)

--[[ 9. MATCH & FARM AUTOMATION ]]--
local AutomationConnection = RunService.Heartbeat:Connect(function()
    local remotes = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Remotes")
    if not remotes then return end

    if Engine.Settings.Automation.AutoRematch then
        local rematchRE = remotes:FindFirstChild("Rematch")
        if rematchRE then
            pcall(function() rematchRE:FireServer() end)
        end
    end

    if Engine.Settings.Automation.AutoMatch then
        local joinQueueRE = remotes:FindFirstChild("JoinQueue")
        if joinQueueRE then
            pcall(function() joinQueueRE:FireServer() end)
        end
    end

    if Engine.Settings.Automation.AutoSpawn then
        local spawnRE = remotes:FindFirstChild("Spawn")
        if spawnRE then
            pcall(function() spawnRE:FireServer() end)
        end
    end
end)
table.insert(Engine.Connections, AutomationConnection)

--[[ 10. WINDUI INTERFACE ]]--
local WindUI
local success, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

local Window = nil
if success and WindUI then
    Window = WindUI:CreateWindow({
        Title = "Hypershot | Tactical Engine v3",
        Icon = "crosshair",
        -- Author removed
        Folder = "HypershotConfig",
        Size = UDim2.fromOffset(590, 480),
        Transparent = true,
        Theme = "Dark",
    })

    -- COMBAT TAB
    local CombatTab = Window:Tab({ Title = "Combat", Icon = "target" })
    
    Engine.UIElements.AimbotEnabled = CombatTab:Toggle({
        Title = "Aimbot Enabled",
        Desc = "Auto-aligns crosshair to enemies inside FOV",
        Value = Engine.Settings.Aimbot.Enabled,
        Callback = function(v) Engine.Settings.Aimbot.Enabled = v end
    })

    Engine.UIElements.EnemyOnly = CombatTab:Toggle({
        Title = "Enemy Only (Ignore Teammates)",
        Desc = "Completely ignores friendly players & teammates",
        Value = Engine.Settings.Aimbot.EnemyOnly,
        Callback = function(v) Engine.Settings.Aimbot.EnemyOnly = v end
    })

    Engine.UIElements.BulletMagnet = CombatTab:Toggle({
        Title = "Bullet Magnet (FOV Trajectory Redirection)",
        Desc = "Locks bullet & crosshair trajectory directly onto target within FOV",
        Value = Engine.Settings.Aimbot.BulletMagnet,
        Callback = function(v) Engine.Settings.Aimbot.BulletMagnet = v end
    })

    Engine.UIElements.AutoShoot = CombatTab:Toggle({
        Title = "Auto Shoot / TriggerBot",
        Desc = "Automatically discharges weapon when enemy is acquired",
        Value = Engine.Settings.Aimbot.AutoShoot,
        Callback = function(v) Engine.Settings.Aimbot.AutoShoot = v end
    })

    Engine.UIElements.AutoShootWallCheck = CombatTab:Toggle({
        Title = "Auto Shoot Wall Check",
        Desc = "Only shoot when enemy HumanoidRootPart is directly visible (No Wall Block)",
        Value = Engine.Settings.Aimbot.AutoShootWallCheck,
        Callback = function(v) Engine.Settings.Aimbot.AutoShootWallCheck = v end
    })

    Engine.UIElements.TriggerKey = CombatTab:Dropdown({
        Title = "Trigger Key",
        Values = { "LMB", "RMB" },
        Value = Engine.Settings.Aimbot.TriggerKey,
        Callback = function(v) Engine.Settings.Aimbot.TriggerKey = v end
    })

    Engine.UIElements.AimBullet = CombatTab:Toggle({
        Title = "Aim Bullet (Instant Hitscan Snap)",
        Desc = "Instant 0-lerp alignment on click",
        Value = Engine.Settings.Aimbot.AimBullet,
        Callback = function(v) Engine.Settings.Aimbot.AimBullet = v end
    })

    Engine.UIElements.AimPart = CombatTab:Dropdown({
        Title = "Aim Target Part",
        Values = { "Head", "UpperTorso", "HumanoidRootPart" },
        Value = "Head",
        Callback = function(v) Engine.Settings.Aimbot.AimPart = v end
    })

    Engine.UIElements.AimbotFOV = CombatTab:Slider({
        Title = "FOV Radius",
        Step = 1,
        Value = {
            Min = 30,
            Max = 600,
            Default = Engine.Settings.Aimbot.FOV
        },
        Callback = function(v) Engine.Settings.Aimbot.FOV = v end
    })

    Engine.UIElements.Smoothing = CombatTab:Slider({
        Title = "Smooth Factor",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 0.95,
            Default = Engine.Settings.Aimbot.Smoothing
        },
        Callback = function(v) Engine.Settings.Aimbot.Smoothing = v end
    })

    Engine.UIElements.ShowFOV = CombatTab:Toggle({
        Title = "Draw FOV Circle",
        Value = Engine.Settings.Aimbot.ShowFOV,
        Callback = function(v) Engine.Settings.Aimbot.ShowFOV = v end
    })

    Engine.UIElements.WallCheck = CombatTab:Toggle({
        Title = "Aimbot Wall Check",
        Value = Engine.Settings.Aimbot.WallCheck,
        Callback = function(v) Engine.Settings.Aimbot.WallCheck = v end
    })

    Engine.UIElements.TargetBots = CombatTab:Toggle({
        Title = "Target Bots",
        Value = Engine.Settings.Aimbot.TargetBots,
        Callback = function(v) Engine.Settings.Aimbot.TargetBots = v end
    })

    Engine.UIElements.TargetPlayers = CombatTab:Toggle({
        Title = "Target Players",
        Value = Engine.Settings.Aimbot.TargetPlayers,
        Callback = function(v) Engine.Settings.Aimbot.TargetPlayers = v end
    })

    -- VISUALS TAB
    local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

    Engine.UIElements.ESPEnabled = VisualTab:Toggle({
        Title = "Clean Silhouette Wallhack",
        Desc = "Forces character outlines visible through walls (AlwaysOnTop)",
        Value = Engine.Settings.ESP.Enabled,
        Callback = function(v) 
            Engine.Settings.ESP.Enabled = v 
            UpdateChams()
        end
    })

    Engine.UIElements.AlwaysOnTop = VisualTab:Toggle({
        Title = "Penetrate Walls (AlwaysOnTop)",
        Value = Engine.Settings.ESP.AlwaysOnTop,
        Callback = function(v) 
            Engine.Settings.ESP.AlwaysOnTop = v 
            UpdateChams()
        end
    })

    Engine.UIElements.FillTransparency = VisualTab:Slider({
        Title = "Fill Transparency",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 1,
            Default = Engine.Settings.ESP.FillTransparency
        },
        Callback = function(v) 
            Engine.Settings.ESP.FillTransparency = v 
            UpdateChams()
        end
    })

    Engine.UIElements.EnemyColor = VisualTab:Colorpicker({
        Title = "Enemy Highlight Color",
        Default = Engine.Settings.ESP.EnemyColor,
        Callback = function(c) 
            Engine.Settings.ESP.EnemyColor = c 
            UpdateChams()
        end
    })

    -- WEAPONS TAB
    local WeaponTab = Window:Tab({ Title = "Weapons", Icon = "zap" })

    Engine.UIElements.InfiniteAmmo = WeaponTab:Toggle({
        Title = "Infinite Ammo / No Reload",
        Desc = "Locks active weapon clip & reserve ammunition",
        Value = Engine.Settings.WeaponMods.InfiniteAmmo,
        Callback = function(v) Engine.Settings.WeaponMods.InfiniteAmmo = v end
    })

    Engine.UIElements.NoRecoil = WeaponTab:Toggle({
        Title = "Neutralize Recoil",
        Value = Engine.Settings.WeaponMods.NoRecoil,
        Callback = function(v) Engine.Settings.WeaponMods.NoRecoil = v end
    })

    Engine.UIElements.NoAbilityCooldown = WeaponTab:Toggle({
        Title = "No Ability Cooldown",
        Desc = "Locks ability charge stacks permanently to max ready",
        Value = Engine.Settings.WeaponMods.NoAbilityCooldown,
        Callback = function(v) Engine.Settings.WeaponMods.NoAbilityCooldown = v end
    })

    Engine.UIElements.HitboxExpander = WeaponTab:Toggle({
        Title = "Expand Head Hitbox",
        Value = Engine.Settings.WeaponMods.HitboxExpander,
        Callback = function(v) 
            Engine.Settings.WeaponMods.HitboxExpander = v 
            if not v then
                local folder = GetEntitiesFolder()
                if folder then
                    for _, entity in ipairs(folder:GetChildren()) do
                        local head = entity:FindFirstChild("Head")
                        if head and head:IsA("BasePart") then
                            head.Size = Vector3.new(1.14, 1.14, 1.14)
                            head.Transparency = 0
                        end
                    end
                end
            end
        end
    })

    Engine.UIElements.HitboxSize = WeaponTab:Slider({
        Title = "Hitbox Multiplier",
        Step = 0.5,
        Value = {
            Min = 2,
            Max = 10,
            Default = Engine.Settings.WeaponMods.HitboxSize
        },
        Callback = function(v) Engine.Settings.WeaponMods.HitboxSize = v end
    })

    -- MOVEMENT TAB
    local MoveTab = Window:Tab({ Title = "Movement", Icon = "wind" })

    Engine.UIElements.SpeedEnabled = MoveTab:Toggle({
        Title = "Enable Player Speed",
        Desc = "Modifies walk velocity and BaseWS attributes",
        Value = Engine.Settings.Movement.SpeedEnabled,
        Callback = function(v) Engine.Settings.Movement.SpeedEnabled = v end
    })

    Engine.UIElements.SpeedValue = MoveTab:Slider({
        Title = "Speed Multiplier / Value",
        Step = 1,
        Value = {
            Min = 16,
            Max = 100,
            Default = Engine.Settings.Movement.SpeedValue
        },
        Callback = function(v) Engine.Settings.Movement.SpeedValue = v end
    })

    Engine.UIElements.InfiniteJump = MoveTab:Toggle({
        Title = "Infinite Jump",
        Desc = "Enables jump state from mid-air freely",
        Value = Engine.Settings.Movement.InfiniteJump,
        Callback = function(v) Engine.Settings.Movement.InfiniteJump = v end
    })

    -- LOOT TAB
    local LootTab = Window:Tab({ Title = "Loot", Icon = "package" })

    Engine.UIElements.AutoLoot = LootTab:Toggle({
        Title = "Auto Loot / Vacuum Magnet",
        Desc = "Suction all drops across the map directly to local player",
        Value = Engine.Settings.Loot.AutoLoot,
        Callback = function(v) Engine.Settings.Loot.AutoLoot = v end
    })

    Engine.UIElements.LootDroppables = LootTab:Toggle({
        Title = "Loot Droppables (Heals / Shards / Coins)",
        Value = Engine.Settings.Loot.LootDroppables,
        Callback = function(v) Engine.Settings.Loot.LootDroppables = v end
    })

    Engine.UIElements.LootWeapons = LootTab:Toggle({
        Title = "Loot Ground Weapons",
        Desc = "Sucks dropped weapon models to character",
        Value = Engine.Settings.Loot.LootWeapons,
        Callback = function(v) Engine.Settings.Loot.LootWeapons = v end
    })

    Engine.UIElements.VacuumRadius = LootTab:Slider({
        Title = "Vacuum Range (Studs)",
        Step = 50,
        Value = {
            Min = 100,
            Max = 5000,
            Default = Engine.Settings.Loot.VacuumRadius
        },
        Callback = function(v) Engine.Settings.Loot.VacuumRadius = v end
    })

    -- AUTOMATION TAB
    local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })

    Engine.UIElements.AutoMatch = AutoTab:Toggle({
        Title = "Auto Queue / Matchmaking",
        Desc = "Automatically enters duel/match matchmaking when available",
        Value = Engine.Settings.Automation.AutoMatch,
        Callback = function(v) Engine.Settings.Automation.AutoMatch = v end
    })

    Engine.UIElements.AutoRematch = AutoTab:Toggle({
        Title = "Auto Rematch",
        Desc = "Automatically fires rematch request upon match completion",
        Value = Engine.Settings.Automation.AutoRematch,
        Callback = function(v) Engine.Settings.Automation.AutoRematch = v end
    })

    Engine.UIElements.AutoSpawn = AutoTab:Toggle({
        Title = "Auto Respawn",
        Desc = "Fires server spawn remote immediately upon elimination",
        Value = Engine.Settings.Automation.AutoSpawn,
        Callback = function(v) Engine.Settings.Automation.AutoSpawn = v end
    })

    -- REWARDS TAB
    local RewardsTab = Window:Tab({ Title = "Rewards", Icon = "gift" })

    RewardsTab:Button({
        Title = "Claim All Known Codes",
        Desc = "Automatically submits all valid and seasonal codes to server",
        Callback = function()
            local codes = {
                "HALLOWEEN26",
                "ONEBILLION",
                "SIXSEVEN",
                "HAPPYMAY",
                "100K",
                "CHRISTMAS2025",
                "THANKSGIVING",
                "CONTRACTS"
            }
            local rf = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Remotes") and ReplicatedStorage.Network.Remotes:FindFirstChild("RedeemCode")
            if rf then
                for _, code in ipairs(codes) do
                    task.spawn(function()
                        pcall(function() return rf:InvokeServer(code) end)
                    end)
                    task.wait(0.25)
                end
                if WindUI and WindUI.Notify then
                    WindUI:Notify({
                        Title = "Codes Redeemed",
                        Content = "Submitted codes to server!",
                        Duration = 3
                    })
                end
            end
        end
    })

    local inputCode = ""
    RewardsTab:Input({
        Title = "Custom Code",
        Desc = "Enter custom promo code",
        Placeholder = "Enter code here...",
        Callback = function(v) inputCode = v end
    })

    RewardsTab:Button({
        Title = "Redeem Custom Code",
        Callback = function()
            if inputCode ~= "" then
                local rf = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Remotes") and ReplicatedStorage.Network.Remotes:FindFirstChild("RedeemCode")
                if rf then
                    local s, res = pcall(function() return rf:InvokeServer(inputCode) end)
                    if WindUI and WindUI.Notify then
                        WindUI:Notify({
                            Title = "Redeem Status",
                            Content = (s and res) and ("Success: " .. inputCode) or ("Invalid / Already Redeemed: " .. inputCode),
                            Duration = 3
                        })
                    end
                end
            end
        end
    })

    -- CONFIG TAB
    local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })

    ConfigTab:Button({
        Title = "Save Current Configuration",
        Desc = "Persists all settings (Combat, Visuals, Mods, Movement, Loot) to disk",
        Callback = function()
            SaveConfig()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Configuration",
                    Content = "Configuration saved successfully!",
                    Duration = 3
                })
            end
        end
    })

    ConfigTab:Button({
        Title = "Load Configuration",
        Desc = "Restores all settings & instantly reapplies ESP / visual state",
        Callback = function()
            local ok = LoadConfig()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Configuration",
                    Content = ok and "Configuration & Visuals restored!" or "No saved config file found.",
                    Duration = 3
                })
            end
        end
    })

    Window:SelectTab(1)
end

--[[ 11. FLOATING ACTION BUTTON & CTRL TOGGLE ]]--
local function ToggleUI()
    Engine.UIVisible = not Engine.UIVisible
    if Window then
        if Window.Toggle then
            pcall(function() Window:Toggle() end)
        elseif Window.Frame then
            Window.Frame.Visible = Engine.UIVisible
        end
    end
end

local KeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleUI()
    end
end)
table.insert(Engine.Connections, KeybindConnection)

local function CreateFloatingButton()
    local lp = GetLocalPlayer()
    local parentGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or (lp and lp:FindFirstChild("PlayerGui"))
    if not parentGui then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HypershotFloatingGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "HypershotToggleBtn"
    floatBtn.Size = UDim2.fromOffset(50, 50)
    floatBtn.Position = UDim2.new(0, 20, 0.5, -25)
    floatBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    floatBtn.Text = "â¡"
    floatBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    floatBtn.TextSize = 22
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.AutoButtonColor = false
    floatBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = floatBtn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Transparency = 0.2
    stroke.Parent = floatBtn

    local dragging = false
    local dragInput, dragStart, startPos

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

    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    table.insert(Engine.Connections, dragConn)

    floatBtn.MouseButton1Click:Connect(function()
        ToggleUI()
    end)

    screenGui.Parent = parentGui
    table.insert(Engine.GuiInstances, screenGui)
end

pcall(CreateFloatingButton)

--[[ 12. RESPAWN & MAP RECOVERY HANDLER ]]--
local lp = GetLocalPlayer()
if lp then
    local RespawnConn = lp.CharacterAdded:Connect(function()
        task.wait(1)
        pcall(function()
            UpdateChams()
        end)
    end)
    table.insert(Engine.Connections, RespawnConn)
end

--[[ 13. CLEANUP ENGINE ROUTINE ]]--
function Engine:Unload()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, draw in ipairs(self.Drawings) do
        pcall(function() draw:Remove() end)
    end
    for _, hl in pairs(self.Highlights) do
        pcall(function() hl:Destroy() end)
    end
    for _, gui in ipairs(self.GuiInstances) do
        pcall(function() gui:Destroy() end)
    end
    
    local folder = GetEntitiesFolder()
    if folder then
        for _, entity in ipairs(folder:GetChildren()) do
            for _, hl in ipairs(entity:GetChildren()) do
                if hl:IsA("Highlight") then
                    hl.DepthMode = Enum.HighlightDepthMode.Occluded
                end
            end
            local head = entity:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                head.Size = Vector3.new(1.14, 1.14, 1.14)
                head.Transparency = 0
            end
        end
    end
    _G.HypershotEngine = nil
end

return Engine
