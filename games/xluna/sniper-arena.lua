-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    Gun Fight Arena (GFA) â Ultra-Performance ClientOP Automation Suite
    Architecture: WindUI v1.6.65 (Opaque Zero-Blur Mode) / Event-Driven Hooks / Low-Overhead Native Tracing
    Operating Directive: Strict SOP Compliance, Zero AI Slop, Native Service Hooks, Zero Frame-Drops.
    Optimizations: Event-Driven Weapon Tuning, Single-Raycast Aim Targeter, Native Crosshair Hook,
                   Highlight Pooling, Lighting Performance Booster.
]]

-- Anti-double-execution guard
if getgenv()._GFA_SCRIPT_RUNNING then
    if getgenv()._GFA_SCRIPT_UNLOAD then
        pcall(getgenv()._GFA_SCRIPT_UNLOAD)
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

getgenv()._GFA_SCRIPT_RUNNING = true

-- Ensure Game is loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- LocalPlayer references
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    LocalPlayer = Players.LocalPlayer
    task.wait(0.1)
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)
end)

-- Native Game Modules & Controllers
local Constant = require(ReplicatedStorage.Constant)
local EntityService = require(ReplicatedStorage.Remote.EntityService)
local LocalEntity = EntityService.LocalEntity
local CombatService = nil
local CombatController = nil
local Effects = nil
local CameraController = nil

pcall(function()
    CombatService = require(ReplicatedStorage.Remote.CombatService)
end)
pcall(function()
    CombatController = require(ReplicatedStorage.Client.CombatController)
end)
pcall(function()
    Effects = require(ReplicatedStorage.Client.Effects)
end)
pcall(function()
    CameraController = require(ReplicatedStorage.Client.CameraController)
end)

-- Static Constants (Zero GC Allocations)
local ZERO_RECOIL = {Degree = 0, Duration = 0, Resume = 0}

-- Global Automation State Table (Default: ALL OFF as per SOP Rule 8)
local State = {
    -- 1. Combat & Aimbot
    AimbotEnabled = false,
    AimbotTargetPart = "Head", -- "Head", "Body", "HumanoidRootPart"
    AimbotFOV = 120,
    ShowFOVCircle = false,
    AimbotSmoothness = 1, -- 1 = instant snap, higher = smoother
    AimbotWallCheck = true,
    AimbotPriority = "Closest to Crosshair", -- "Closest to Crosshair", "Lowest Health", "Closest Distance"
    AimbotKeyMode = "Always Active", -- "Always Active", "Hold Right-Click (RMB)"

    -- Triggerbot
    TriggerbotEnabled = false,
    TriggerbotDelay = 0, -- ms
    TriggerbotHeadOnly = false,

    -- Weapon Mechanics
    NoRecoil = false,
    NoSpread = false,
    AlwaysFullAuto = false,

    -- 2. Visuals & ESP
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 30, 30),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsTransparency = 0.5,
    ChamsAlwaysOnTop = true,

    -- 3. Movement Modifiers
    SpeedEnabled = false,
    WalkSpeed = 19.5,
    InfiniteSlide = false,
    BunnyHop = false,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = true,

    -- 4. Automation & Utilities
    AutoQuickMelee = false,
    AntiFlashSmoke = false,

    -- 5. Performance Boosters
    FPSBooster = false,
}

-- Cleanup Registry
local Connections = {}
local RunningTasks = {}
local DrawingsList = {}
local HighlightsList = {}

local function RegisterConnection(conn)
    table.insert(Connections, conn)
    return conn
end

local function RegisterTask(thread)
    table.insert(RunningTasks, thread)
    return thread
end

local function RegisterDrawing(d)
    table.insert(DrawingsList, d)
    return d
end

-- Load WindUI Library
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[ClientOP] Failed to fetch WindUI library.")
    getgenv()._GFA_SCRIPT_RUNNING = false
    return
end

if WindUI.SetParent then
    pcall(WindUI.SetParent, WindUI, gethui and gethui() or game:GetService("CoreGui"))
end

local function SafeNotify(config)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify(config)
        end
    end)
end

-- Build Main Window (Opaque Mode: Transparent = false to eliminate GPU blur shader lag)
local Window = WindUI:CreateWindow({
    Title = "Gun Fight Arena",
    Icon = "crosshair",
    Author = "Elite Performance Suite",
    Folder = "GunFightArena",
    Size = UDim2.fromOffset(640, 520),
    Transparent = false, -- Critical: Disables heavy frame-buffer blur for 60+ FPS
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Title = "Open Script",
        Icon = "crosshair",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("FF416C"),
            Color3.fromHex("8A2387")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
    ToggleKey = Enum.KeyCode.LeftControl,
})

-- =========================================================================
-- CREATE ALL TABS
-- =========================================================================
local TabCombat = Window:Tab({ Title = "Combat & Aimbot", Icon = "crosshair" })
local TabVisuals = Window:Tab({ Title = "Visuals (Chams)", Icon = "eye" })
local TabMovement = Window:Tab({ Title = "Movement Modifiers", Icon = "gauge" })
local TabAutomation = Window:Tab({ Title = "Automation & Quick", Icon = "zap" })
local TabConfig = Window:Tab({ Title = "Configuration", Icon = "settings" })

getgenv()._GFA_WINDOW = Window
getgenv()._GFA_STATE = State
getgenv()._GFA_TABS = {
    Combat = TabCombat,
    Visuals = TabVisuals,
    Movement = TabMovement,
    Automation = TabAutomation,
    Config = TabConfig,
}

-- =========================================================================
-- WEAPON CONFIGURATION HOOKS (EVENT-DRIVEN: ZERO PER-FRAME OVERHEAD)
-- =========================================================================
local function ApplyWeaponMods()
    if CombatController and CombatController.GetWeapon then
        local w = CombatController.GetWeapon()
        local conf = w and w:GetConfig()
        if conf then
            if State.NoRecoil then
                conf.Recoil = ZERO_RECOIL
            end
            if State.NoSpread then
                conf.Spread = 0
            end
            if State.AlwaysFullAuto then
                conf.FullAuto = true
            end
        end
    end
end

if CombatService and CombatService.LocalEvent and CombatService.LocalEvent.SlotSwitched then
    RegisterConnection(CombatService.LocalEvent.SlotSwitched:Connect(ApplyWeaponMods))
end
if CombatController and CombatController.Event and CombatController.Event.WeaponRefresh then
    RegisterConnection(CombatController.Event.WeaponRefresh:Connect(ApplyWeaponMods))
end

-- =========================================================================
-- TAB 1: COMBAT & AIMBOT
-- =========================================================================
TabCombat:Section({
    Title = "Precision Aimbot Engine",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Aimbot Enabled",
    Desc = "Automatically locks crosshair onto target enemy with zero frame-lag",
    Value = State.AimbotEnabled,
    Callback = function(val)
        State.AimbotEnabled = val
    end,
})

TabCombat:Dropdown({
    Title = "Target Hitbox",
    Desc = "Target bone for lock-on",
    Values = { "Head", "Body", "HumanoidRootPart" },
    Value = State.AimbotTargetPart,
    Callback = function(selected)
        State.AimbotTargetPart = selected
    end,
})

TabCombat:Slider({
    Title = "Aimbot FOV Radius",
    Value = {
        Min = 30,
        Max = 500,
        Default = 120,
    },
    Step = 5,
    Callback = function(val)
        State.AimbotFOV = val
    end,
})

TabCombat:Toggle({
    Title = "Show FOV Circle",
    Desc = "Draws lightweight on-screen radius circle indicating aimbot zone",
    Value = State.ShowFOVCircle,
    Callback = function(val)
        State.ShowFOVCircle = val
    end,
})

TabCombat:Slider({
    Title = "Aim Smoothness",
    Desc = "1 = Instant Snap, Higher = Smooth Glide",
    Value = {
        Min = 1,
        Max = 15,
        Default = 1,
    },
    Step = 1,
    Callback = function(val)
        State.AimbotSmoothness = val
    end,
})

TabCombat:Toggle({
    Title = "Visibility Raycast Check",
    Desc = "Only targets enemies that are not behind walls",
    Value = State.AimbotWallCheck,
    Callback = function(val)
        State.AimbotWallCheck = val
    end,
})

TabCombat:Dropdown({
    Title = "Target Priority",
    Values = { "Closest to Crosshair", "Lowest Health", "Closest Distance" },
    Value = State.AimbotPriority,
    Callback = function(selected)
        State.AimbotPriority = selected
    end,
})

TabCombat:Dropdown({
    Title = "Aimbot Activation",
    Desc = "Always locks on target or only when holding Right-Click",
    Values = { "Always Active", "Hold Right-Click (RMB)" },
    Value = State.AimbotKeyMode,
    Callback = function(selected)
        State.AimbotKeyMode = selected
    end,
})

TabCombat:Section({
    Title = "Triggerbot (Instant Reaction Fire)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Triggerbot Enabled",
    Desc = "Fires weapon instantly when crosshair intersects an enemy (0% CPU hook)",
    Value = State.TriggerbotEnabled,
    Callback = function(val)
        State.TriggerbotEnabled = val
    end,
})

TabCombat:Slider({
    Title = "Triggerbot Delay (ms)",
    Value = {
        Min = 0,
        Max = 100,
        Default = 0,
    },
    Step = 5,
    Callback = function(val)
        State.TriggerbotDelay = val
    end,
})

TabCombat:Toggle({
    Title = "Triggerbot Headshot Only",
    Desc = "Only pulls trigger when crosshair is directly on the Head",
    Value = State.TriggerbotHeadOnly,
    Callback = function(val)
        State.TriggerbotHeadOnly = val
    end,
})

TabCombat:Section({
    Title = "Weapon Modifications (Zero Bloom)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "No Recoil",
    Desc = "Completely eliminates weapon kickback and vertical recoil",
    Value = State.NoRecoil,
    Callback = function(val)
        State.NoRecoil = val
        ApplyWeaponMods()
    end,
})

TabCombat:Toggle({
    Title = "No Spread",
    Desc = "Removes bullet spread for 100% laser accuracy",
    Value = State.NoSpread,
    Callback = function(val)
        State.NoSpread = val
        ApplyWeaponMods()
    end,
})

TabCombat:Toggle({
    Title = "Always Full-Auto",
    Desc = "Converts semi-auto weapons and snipers into automatic fire weapons",
    Value = State.AlwaysFullAuto,
    Callback = function(val)
        State.AlwaysFullAuto = val
        ApplyWeaponMods()
    end,
})

-- =========================================================================
-- TAB 2: VISUALS (ESP & WALLHACK)
-- =========================================================================
TabVisuals:Section({
    Title = "Enemy Highlight Chams (Wallhack)",
    Opened = true,
})

TabVisuals:Toggle({
    Title = "Enemy Highlight Chams",
    Desc = "Renders colored silhouettes through all walls and obstacles",
    Value = State.ChamsEnabled,
    Callback = function(val)
        State.ChamsEnabled = val
    end,
})

TabVisuals:Colorpicker({
    Title = "Chams Fill Color",
    Default = State.ChamsColor,
    Callback = function(color)
        State.ChamsColor = color
    end,
})

TabVisuals:Colorpicker({
    Title = "Chams Outline Color",
    Default = State.ChamsOutlineColor,
    Callback = function(color)
        State.ChamsOutlineColor = color
    end,
})

TabVisuals:Slider({
    Title = "Chams Transparency",
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.5,
    },
    Step = 0.1,
    Callback = function(val)
        State.ChamsTransparency = val
    end,
})

-- =========================================================================
-- TAB 3: MOVEMENT MODIFIERS
-- =========================================================================
TabMovement:Section({
    Title = "Speed & Sprint Mechanics",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Custom Speed Multiplier",
    Value = State.SpeedEnabled,
    Callback = function(val)
        State.SpeedEnabled = val
        if LocalEntity then
            LocalEntity.WalkSpeed = val and State.WalkSpeed or 19.5
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed Multiplier",
    Value = {
        Min = 19.5,
        Max = 60,
        Default = 19.5,
    },
    Step = 1,
    Callback = function(val)
        State.WalkSpeed = val
        if State.SpeedEnabled and LocalEntity then
            LocalEntity.WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Infinite Slide Momentum",
    Desc = "Maintains top sliding speed indefinitely without deceleration",
    Value = State.InfiniteSlide,
    Callback = function(val)
        State.InfiniteSlide = val
    end,
})

TabMovement:Toggle({
    Title = "BunnyHop (BHop)",
    Desc = "Automatically jumps continuously upon hitting the ground when holding Space",
    Value = State.BunnyHop,
    Callback = function(val)
        State.BunnyHop = val
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Pass smoothly through walls, doors, and obstacles",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping mid-air continuously",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents client from 20-minute idle disconnects",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =========================================================================
-- TAB 4: AUTOMATION & QUICK UTILITIES
-- =========================================================================
TabAutomation:Section({
    Title = "Combat Automation",
    Opened = true,
})

TabAutomation:Toggle({
    Title = "Auto Quick Melee (Close-Combat)",
    Desc = "Automatically executes knife slash when an enemy enters within 5.5 studs",
    Value = State.AutoQuickMelee,
    Callback = function(val)
        State.AutoQuickMelee = val
    end,
})

TabAutomation:Toggle({
    Title = "Anti-Flash & Anti-Smoke",
    Desc = "Removes screen whiteout from flashbangs and smoke vision occlusion",
    Value = State.AntiFlashSmoke,
    Callback = function(val)
        State.AntiFlashSmoke = val
    end,
})

-- =========================================================================
-- TAB 5: CONFIG & PERSISTENCE
-- =========================================================================
TabConfig:Section({
    Title = "Performance & FPS Optimization",
    Opened = true,
})

TabConfig:Toggle({
    Title = "FPS Booster (Ultra Performance)",
    Desc = "Disables global shadows, bloom, blur, and water ripples to maximize framerate on laptops",
    Value = State.FPSBooster,
    Callback = function(val)
        State.FPSBooster = val
        pcall(function()
            Lighting.GlobalShadows = not val
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("BloomEffect") then
                    e.Enabled = not val
                end
            end
            if workspace:FindFirstChildOfClass("Terrain") then
                local terrain = workspace.Terrain
                terrain.WaterWaveSize = val and 0 or 0.15
                terrain.WaterWaveSpeed = val and 0 or 10
                terrain.WaterReflectance = val and 0 or 1
            end
        end)
    end,
})

TabConfig:Section({
    Title = "Profile Persistence",
    Opened = false,
})

local ConfigFileName = "GunFightArena_Config.json"

local function SaveProfile()
    local payload = HttpService:JSONEncode(State)
    if writefile then
        writefile(ConfigFileName, payload)
        SafeNotify({
            Title = "Config Saved",
            Content = "Settings successfully saved to disk.",
            Duration = 2.5,
            Icon = "save",
        })
    end
end

local function LoadProfile()
    if isfile and readfile and isfile(ConfigFileName) then
        local content = readfile(ConfigFileName)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                State[k] = v
            end
            SafeNotify({
                Title = "Config Loaded",
                Content = "Settings successfully restored.",
                Duration = 2.5,
                Icon = "folder-check",
            })
        end
    end
end

TabConfig:Button({
    Title = "Save Current Config",
    Icon = "save",
    Callback = SaveProfile,
})

TabConfig:Button({
    Title = "Load Saved Config",
    Icon = "download",
    Callback = LoadProfile,
})

TabConfig:Section({
    Title = "Interface Control",
    Opened = false,
})

TabConfig:Keybind({
    Title = "Toggle UI Keybind",
    Value = Enum.KeyCode.LeftControl,
    Callback = function(key)
        Window:SetToggleKey(key)
    end,
})

TabConfig:Button({
    Title = "Unload Automation Script",
    Icon = "power",
    Callback = function()
        if getgenv()._GFA_SCRIPT_UNLOAD then
            getgenv()._GFA_SCRIPT_UNLOAD()
        end
    end,
})

-- Focus Default Initial Tab
pcall(function()
    TabCombat:Select()
end)

-- =========================================================================
-- UNLOAD LIFECYCLE HANDLER
-- =========================================================================
getgenv()._GFA_SCRIPT_UNLOAD = function()
    pcall(RunService.UnbindFromRenderStep, RunService, "ClientOP_Aimbot")
    pcall(RunService.UnbindFromRenderStep, RunService, "ClientOP_Render")

    for _, conn in ipairs(Connections) do
        pcall(conn.Disconnect, conn)
    end
    for _, thr in ipairs(RunningTasks) do
        pcall(task.cancel, thr)
    end
    for _, d in ipairs(DrawingsList) do
        pcall(d.Remove, d)
    end
    for _, h in pairs(HighlightsList) do
        pcall(h.Destroy, h)
    end

    if LocalEntity then
        LocalEntity.WalkSpeed = 19.5
    end

    pcall(function()
        Lighting.GlobalShadows = true
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("BloomEffect") then
                e.Enabled = true
            end
        end
    end)

    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    getgenv()._GFA_SCRIPT_RUNNING = nil
    getgenv()._GFA_SCRIPT_UNLOAD = nil
end

-- =========================================================================
-- OPTIMIZED DRAWING & HITBOX RESOLVER
-- =========================================================================
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Radius = State.AimbotFOV
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Thickness = 1.5
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.7
        RegisterDrawing(FOVCircle)
    end
end)

-- Multi-Source Dynamic Enemy Scanner (100% Reliable across Lobby, Match, and UUID changes)
local function GetAllEnemies()
    local enemies = {}
    local myChar = LocalPlayer.Character
    local seen = {}

    -- 1. Primary: Workspace.World.*.Entities (Active Arena Matches)
    local world = workspace:FindFirstChild("World")
    if world then
        for _, w in ipairs(world:GetChildren()) do
            local entities = w:FindFirstChild("Entities")
            if entities then
                for _, m in ipairs(entities:GetChildren()) do
                    if m:IsA("Model") and m ~= myChar and not seen[m] then
                        seen[m] = true
                        table.insert(enemies, m)
                    end
                end
            end
        end
    end

    -- 2. Fallback: Workspace.Entities
    local wEnt = workspace:FindFirstChild("Entities")
    if wEnt then
        for _, m in ipairs(wEnt:GetChildren()) do
            if m:IsA("Model") and m ~= myChar and not seen[m] then
                seen[m] = true
                table.insert(enemies, m)
            end
        end
    end

    -- 3. Fallback: Workspace.Highlight.Enemy.HighlightHolder
    local holder = workspace:FindFirstChild("Highlight") and workspace.Highlight:FindFirstChild("Enemy") and workspace.Highlight.Enemy:FindFirstChild("HighlightHolder")
    if holder then
        for _, m in ipairs(holder:GetChildren()) do
            if m:IsA("Model") and m.Name ~= "Highlight" and m ~= myChar and not seen[m] then
                seen[m] = true
                table.insert(enemies, m)
            end
        end
    end

    -- 4. Fallback: Players in Workspace
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character ~= myChar and not seen[p.Character] then
            seen[p.Character] = true
            table.insert(enemies, p.Character)
        end
    end

    return enemies
end

-- Precise Hitbox Resolver (Collider -> Model -> PrimaryPart)
local function GetTargetPart(model, partName)
    local collider = model:FindFirstChild("Collider")
    if collider then
        local p = collider:FindFirstChild(partName)
            or (partName == "Head" and collider:FindFirstChild("Head"))
            or (partName == "Body" and collider:FindFirstChild("Body"))
            or collider:FindFirstChild("HumanoidRootPart")
        if p and p:IsA("BasePart") then return p end
    end
    local p = model:FindFirstChild(partName) or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    if p and p:IsA("BasePart") then return p end
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

-- Raycast Visibility Check (Ignores hits on the enemy itself)
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsVisible(targetEnemy, targetPart)
    if not State.AimbotWallCheck then return true end
    local camPos = Camera.CFrame.Position
    local dir = targetPart.Position - camPos

    RayParams.FilterDescendantsInstances = {
        Character,
        workspace:FindFirstChild("Highlight"),
        workspace:FindFirstChild("_Temp")
    }

    local hit = workspace:Raycast(camPos, dir, RayParams)
    if not hit then
        return true
    end

    -- If ray hits the enemy or any of its accessories/collider parts, it IS visible!
    if hit.Instance:IsDescendantOf(targetEnemy) then
        return true
    end
    return false
end

-- =========================================================================
-- OPTIMIZED WORKER THREADS
-- =========================================================================

-- 1. Lightweight Render Step (FOV Circle & Slide)
RunService:BindToRenderStep("ClientOP_Render", Enum.RenderPriority.Camera.Value + 15, function()
    Camera = workspace.CurrentCamera

    -- Update FOV circle ONLY if user enabled it
    if FOVCircle and State.ShowFOVCircle and State.AimbotEnabled then
        FOVCircle.Visible = true
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = State.AimbotFOV
    elseif FOVCircle and FOVCircle.Visible then
        FOVCircle.Visible = false
    end

    -- Infinite Slide (Lightweight C++ property update)
    if State.InfiniteSlide and LocalEntity then
        LocalEntity.SlidingSpeed = 35
    end
end)

-- 2. Precision Aimbot Engine (Camera Priority + 20: Overrides Game Camera Controller)
RunService:BindToRenderStep("ClientOP_Aimbot", Enum.RenderPriority.Camera.Value + 20, function()
    if not State.AimbotEnabled then return end

    -- Check Activation Mode (RMB hold vs Always)
    if State.AimbotKeyMode == "Hold Right-Click (RMB)" and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    Camera = workspace.CurrentCamera
    local viewportCenter = Camera.ViewportSize / 2
    local candidates = {}

    local enemies = GetAllEnemies()

    -- Pass 1: Screen-space distance pre-filter (Fast Math, Zero Raycasts)
    for _, enemy in ipairs(enemies) do
        if enemy.Parent then
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health > 0 then
                local targetPart = GetTargetPart(enemy, State.AimbotTargetPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                        if screenDist <= State.AimbotFOV then
                            local score = screenDist
                            if State.AimbotPriority == "Lowest Health" then
                                score = hum and hum.Health or screenDist
                            elseif State.AimbotPriority == "Closest Distance" then
                                score = (targetPart.Position - Camera.CFrame.Position).Magnitude
                            end
                            table.insert(candidates, {enemy = enemy, part = targetPart, score = score})
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then return end

    -- Sort candidates to find priority winner
    table.sort(candidates, function(a, b) return a.score < b.score end)

    -- Pass 2: Verify visibility on top candidate(s)
    local bestTarget = nil
    for _, cand in ipairs(candidates) do
        if IsVisible(cand.enemy, cand.part) then
            bestTarget = cand.part
            break
        end
    end

    if bestTarget then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
        if State.AimbotSmoothness <= 1 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / State.AimbotSmoothness)
        end

        -- Synchronize LocalEntity Yaw and Pitch so character and bullets match target
        if LocalEntity then
            local dir = (bestTarget.Position - Camera.CFrame.Position).Unit
            LocalEntity.Yaw = math.atan2(-dir.X, -dir.Z)
            LocalEntity.Pitch = math.asin(dir.Y)
        end
    end
end)

-- 3. Triggerbot Engine (Native Targeter Hook + Crosshair Raycast)
RegisterTask(task.spawn(function()
    while true do
        if State.TriggerbotEnabled and CombatController and CombatController.PrimaryAction then
            local canShoot = false

            -- Check 1: Native CameraController Crosshair Target
            if CameraController and CameraController.GetTargetingEntity then
                local targeting = CameraController.GetTargetingEntity()
                if targeting and targeting:IsAlive() and not (LocalEntity and LocalEntity:IsFriendly(targeting)) then
                    canShoot = true
                end
            end

            -- Check 2: Direct Center Screen Raycast fallback
            if not canShoot then
                local center = Camera.ViewportSize / 2
                local ray = Camera:ViewportPointToRay(center.X, center.Y)
                RayParams.FilterDescendantsInstances = {Character, workspace:FindFirstChild("Highlight")}
                local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, RayParams)
                if hit and hit.Instance then
                    for _, enemy in ipairs(GetAllEnemies()) do
                        if hit.Instance:IsDescendantOf(enemy) then
                            if not State.TriggerbotHeadOnly or hit.Instance.Name == "Head" then
                                canShoot = true
                                break
                            end
                        end
                    end
                end
            end

            if canShoot then
                if State.TriggerbotDelay > 0 then
                    task.wait(State.TriggerbotDelay / 1000)
                end
                pcall(function()
                    CombatController.PrimaryAction.Begin("autoShoot")
                    task.wait(0.04)
                    CombatController.PrimaryAction.End("autoShoot")
                end)
                task.wait(0.08)
            end
        end
        task.wait(0.04)
    end
end))

-- 4. Enemy Highlight Chams (Multi-Source Wallhack)
RegisterTask(task.spawn(function()
    while true do
        if State.ChamsEnabled then
            local enemies = GetAllEnemies()
            for _, enemy in ipairs(enemies) do
                if enemy.Parent then
                    local h = HighlightsList[enemy]
                    if not h or not h.Parent then
                        h = Instance.new("Highlight")
                        h.Name = "ClientOP_Chams"
                        h.FillColor = State.ChamsColor
                        h.OutlineColor = State.ChamsOutlineColor
                        h.FillTransparency = State.ChamsTransparency
                        h.OutlineTransparency = 0
                        h.DepthMode = State.ChamsAlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                        h.Adornee = enemy
                        h.Parent = enemy
                        HighlightsList[enemy] = h
                    else
                        h.FillColor = State.ChamsColor
                        h.OutlineColor = State.ChamsOutlineColor
                        h.FillTransparency = State.ChamsTransparency
                        h.DepthMode = State.ChamsAlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    end
                end
            end
        else
            for enemy, h in pairs(HighlightsList) do
                pcall(h.Destroy, h)
                HighlightsList[enemy] = nil
            end
        end
        task.wait(1.5)
    end
end))

-- 5. Movement Modifiers (BHop, Noclip, Anti-AFK)
RegisterConnection(RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if State.SpeedEnabled and LocalEntity then
        LocalEntity.WalkSpeed = State.WalkSpeed
    end
end))

RegisterConnection(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

RegisterConnection(LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end))

-- Auto Quick Melee Loop
RegisterTask(task.spawn(function()
    while true do
        if State.AutoQuickMelee and Character and Character:FindFirstChild("HumanoidRootPart") then
            local myPos = Character.HumanoidRootPart.Position
            for _, enemy in ipairs(GetAllEnemies()) do
                local targetPart = GetTargetPart(enemy, "HumanoidRootPart")
                if targetPart and (targetPart.Position - myPos).Magnitude <= 5.5 then
                    pcall(function()
                        if CombatController and CombatController.PrimaryAction then
                            CombatController.PrimaryAction.Begin("quickMelee")
                            task.wait(0.04)
                            CombatController.PrimaryAction.End("quickMelee")
                        end
                    end)
                    task.wait(0.3)
                    break
                end
            end
        end
        task.wait(0.1)
    end
end))

SafeNotify({
    Title = "Gun Fight Arena",
    Content = "Ultra-Performance Suite Loaded (Opaque Mode Active).",
    Duration = 4,
    Icon = "crosshair",
})
