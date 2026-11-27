-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [ð¥NEW CASE] Deagle Arena â Elite ClientOP Combat & Automation Master Suite
    Architecture: WindUI v1.6.65 / Modern Luau / Native Game Service Hooks / Ultra-Performance Engine
    Operating Directive: Strict SOP Compliance, Zero AI Slop, Native Service Hooks, Zero Detection Risk.
    Features: Precision Aimbot, Silent Aim (Headshot Redirect), Triggerbot, Auto Combat Eliminator (Auto Shoot Loop),
              Rapid Fire & Zero Cooldown, No Recoil, Enemy Highlight Chams (Wallhack), Billboard Distance ESP,
              FPS Booster (Ultra Performance), Custom WalkSpeed, Custom SlideSpeed, Infinite Slide (Zero Cooldown),
              BunnyHop, Noclip, Infinite Jump, Anti-AFK, Auto Rewards (Daily, Playtime, Welcome),
              Auto Floor Drops Vacuum, Auto Deploy, JSON Profile Config Save/Load,
              Draggable Floating Action Button, LeftControl Keybind Toggle.
]]

-- Anti-double-execution guard
if getgenv()._DEAGLE_SCRIPT_RUNNING then
    if getgenv()._DEAGLE_SCRIPT_UNLOAD then
        pcall(getgenv()._DEAGLE_SCRIPT_UNLOAD)
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

getgenv()._DEAGLE_SCRIPT_RUNNING = true

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
local CollectionService = game:GetService("CollectionService")
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

-- Game Modules
local ModuleLoader = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ModuleLoader")
local Network = nil
local DeagleController = nil
local MeleeController = nil
local MovementController = nil
local CameraController = nil
local RoundController = nil
local ClientData = nil
local EffectsController = nil
local DeagleShared = nil
local GamemodeShared = nil

pcall(function() Network = require(ReplicatedStorage.Modules.Packages.Network) end)
pcall(function() DeagleShared = require(ReplicatedStorage.Modules.Shared.DeagleShared) end)
pcall(function() GamemodeShared = require(ReplicatedStorage.Modules.Shared.GamemodeShared) end)
pcall(function() DeagleController = require(ModuleLoader:WaitForChild("DeagleController")) end)
pcall(function() MeleeController = require(ModuleLoader:WaitForChild("MeleeController")) end)
pcall(function() MovementController = require(ModuleLoader:WaitForChild("MovementController")) end)
pcall(function() CameraController = require(ModuleLoader:WaitForChild("CameraController")) end)
pcall(function() RoundController = require(ModuleLoader:WaitForChild("RoundController")) end)
pcall(function() ClientData = require(ModuleLoader:WaitForChild("ClientData")) end)
pcall(function() EffectsController = require(ModuleLoader:WaitForChild("EffectsController")) end)

-- Save original movement, network & camera defaults
local DefaultWalkSpeed = MovementController and MovementController.WalkSpeed or 22
local DefaultSlideSpeed = MovementController and MovementController.SlideSpeed or 48
local DefaultSlideCooldown = MovementController and MovementController.SlideCooldownTime or 0.65
local OriginalCameraShoot = CameraController and CameraController.Shoot or nil

-- Capture the ORIGINAL FireServer fresh per DataModel: after teleport/re-injection
-- the Network module is a brand-new instance; a getgenv-cached closure from the
-- previous place would be dead and silently break all Shoot packets.
local OriginalNetworkFireServer = Network and Network.FireServer or nil

-- Global Automation State Table (Default: ALL OFF as per SOP Rule 8)
local State = {
    -- 1. Combat & Aimbot
    AimbotEnabled = false,
    AimbotTargetPart = "HeadHitbox", -- "HeadHitbox", "Head", "UpperTorso", "HumanoidRootPart"
    AimbotFOV = 120,
    ShowFOVCircle = false,
    AimbotSmoothness = 1, -- 1 = instant snap, higher = smooth glide
    AimbotWallCheck = true,
    AimbotActivation = "Always Active", -- "Always Active", "Hold Right-Click (RMB)"
    AimbotPriority = "Closest to Crosshair", -- "Closest to Crosshair", "Lowest Health", "Closest Distance"

    -- Silent Aim
    SilentAim = false,
    SilentAimFOV = 150,

    -- Triggerbot
    TriggerbotEnabled = false,
    TriggerbotDelay = 0, -- ms
    TriggerbotHeadOnly = false,

    -- Auto Combat Eliminator (Auto Shoot Loop)
    AutoShoot = false,
    AutoShootDelay = 0.15,

    -- Teleport Kill (Sticky Eliminator)
    TeleportKill = false,
    TeleportKillDelay = 0.12,
    TeleportStickOffset = 2.5,
    TeleportSwitchDelay = 0.2,
    TeleportMaxDist = 90,
    TeleportChaseEnabled = true,
    TeleportChaseSpeed = 55,

    -- Auto Ranked Queue
    AutoRanked = false,

    -- Weapon Mechanics
    RapidFire = false,
    NoRecoil = false,

    -- 2. Visuals & ESP
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 30, 30),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsTransparency = 0.5,
    ChamsAlwaysOnTop = true,
    NametagsEnabled = false,
    FPSBooster = false,

    -- 3. Movement Modifiers
    CustomWalkSpeed = false,
    WalkSpeed = 22,
    CustomSlideSpeed = false,
    SlideSpeed = 48,
    InfiniteSlide = false,
    BunnyHop = false,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = true,

    -- 4. Automation & Rewards
    AutoClaimDaily = false,
    AutoClaimPlaytime = false,
    AutoClaimWelcome = false,
    AutoVacuumDrops = false,
    AutoDeploy = false,
    AutoRespawn = false,

    -- 5. Interface
    UIKeybind = Enum.KeyCode.LeftControl,
}

-- Cleanup Registry
local Connections = {}
local RunningTasks = {}
local DrawingsList = {}
local HighlightsList = {}
local BillboardsList = {}

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
    getgenv()._DEAGLE_SCRIPT_RUNNING = false
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

-- Build Main Window (Solid Opaque Mode: Zero Blur Lag)
local Window = WindUI:CreateWindow({
    Title = "Deagle Arena",
    Icon = "crosshair",
    Author = "Elite Automation Suite",
    Folder = "DeagleArena",
    Size = UDim2.fromOffset(640, 520),
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Title = "Open Script",
        Icon = "crosshair",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("00F260"),
            Color3.fromHex("0575E6")
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
local TabVisuals = Window:Tab({ Title = "Visuals (ESP)", Icon = "eye" })
local TabMovement = Window:Tab({ Title = "Movement Modifiers", Icon = "gauge" })
local TabRewards = Window:Tab({ Title = "Auto Rewards & Quests", Icon = "gift" })
local TabConfig = Window:Tab({ Title = "Configuration", Icon = "settings" })

getgenv()._DEAGLE_WINDOW = Window
getgenv()._DEAGLE_STATE = State
getgenv()._DEAGLE_TABS = {
    Combat = TabCombat,
    Visuals = TabVisuals,
    Movement = TabMovement,
    Rewards = TabRewards,
    Config = TabConfig,
}

-- =========================================================================
-- TAB 1: COMBAT & AIMBOT
-- =========================================================================
TabCombat:Section({
    Title = "Precision Aimbot Engine",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Aimbot Enabled",
    Desc = "Automatically locks camera onto enemy head or chosen bone",
    Value = State.AimbotEnabled,
    Callback = function(val)
        State.AimbotEnabled = val
    end,
})

TabCombat:Dropdown({
    Title = "Target Hitbox",
    Desc = "Bone priority (HeadHitbox triggers 999 1-shot kill)",
    Values = { "HeadHitbox", "Head", "UpperTorso", "HumanoidRootPart" },
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
    Desc = "Draws on-screen radius circle indicating aimbot target zone",
    Value = State.ShowFOVCircle,
    Callback = function(val)
        State.ShowFOVCircle = val
    end,
})

TabCombat:Slider({
    Title = "Aim Smoothness",
    Desc = "1 = Instant Snap, Higher = Smooth Legit Glide",
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
    Title = "Visibility Wallcheck",
    Desc = "Only targets enemies that are not obstructed behind cover",
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
    Title = "Aimbot Activation Mode",
    Desc = "Always active or only active while holding Right-Click",
    Values = { "Always Active", "Hold Right-Click (RMB)" },
    Value = State.AimbotActivation,
    Callback = function(selected)
        State.AimbotActivation = selected
    end,
})

TabCombat:Section({
    Title = "Silent Aim (1-Shot Headshot Redirect)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Silent Aim",
    Desc = "Redirects outgoing shot packets to enemy HeadHitbox with 100% headshot accuracy without snapping camera",
    Value = State.SilentAim,
    Callback = function(val)
        State.SilentAim = val
    end,
})

TabCombat:Slider({
    Title = "Silent Aim FOV Radius",
    Value = {
        Min = 30,
        Max = 500,
        Default = 150,
    },
    Step = 5,
    Callback = function(val)
        State.SilentAimFOV = val
    end,
})

TabCombat:Section({
    Title = "Auto Combat Eliminator (Auto Shoot Loop)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Auto Shoot Loop",
    Desc = "Continuously acquires visible enemies and fires 1-shot headshot elimination packets automatically",
    Value = State.AutoShoot,
    Callback = function(val)
        State.AutoShoot = val
        if val then
            SafeNotify({
                Title = "Auto Eliminator Active",
                Content = "Auto firing 1-shot headshots at visible targets...",
                Duration = 3,
                Icon = "crosshair",
            })
        end
    end,
})

TabCombat:Slider({
    Title = "Auto Shoot Delay (s)",
    Desc = "Delay between consecutive auto shots",
    Value = {
        Min = 0.05,
        Max = 0.5,
        Default = 0.15,
    },
    Step = 0.01,
    Callback = function(val)
        State.AutoShootDelay = val
    end,
})

TabCombat:Section({
    Title = "Teleport Kill (Sticky Eliminator)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Teleport Kill",
    Desc = "Teleports & magnetically glues onto the closest enemy, fires instant 999-damage headshots at point-blank until dead, then auto-chains to the next enemy infinitely (team-safe)",
    Value = State.TeleportKill,
    Callback = function(val)
        State.TeleportKill = val
        if val then
            SafeNotify({
                Title = "Teleport Kill Active",
                Content = "Sticky-eliminating nearest enemies on sight...",
                Duration = 3,
                Icon = "crosshair",
            })
        end
    end,
})

TabCombat:Slider({
    Title = "Teleport Kill Fire Delay (s)",
    Desc = "Delay between point-blank headshots per target (lower = faster burst)",
    Value = {
        Min = 0.05,
        Max = 0.5,
        Default = 0.1,
    },
    Step = 0.01,
    Callback = function(val)
        State.TeleportKillDelay = val
    end,
})

TabCombat:Slider({
    Title = "Teleport Stick Distance (studs)",
    Desc = "How close to glue onto the enemy body",
    Value = {
        Min = 1.5,
        Max = 6,
        Default = 2.5,
    },
    Step = 0.1,
    Callback = function(val)
        State.TeleportStickOffset = val
    end,
})

TabCombat:Slider({
    Title = "Target Switch Delay (s)",
    Desc = "Pause before acquiring and teleporting to the next enemy",
    Value = {
        Min = 0.05,
        Max = 0.5,
        Default = 0.15,
    },
    Step = 0.01,
    Callback = function(val)
        State.TeleportSwitchDelay = val
    end,
})

TabCombat:Toggle({
    Title = "Auto Chase Target (No-Clip Run)",
    Desc = "If enemy is out of teleport range: auto-run towards them using noclip while staying on-ground, then teleport once within range",
    Value = State.TeleportChaseEnabled,
    Callback = function(val)
        State.TeleportChaseEnabled = val
    end,
})

TabCombat:Slider({
    Title = "Chase Running Speed",
    Desc = "Speed while noclip-chasing distant enemies (16â60 studs/s)",
    Value = {
        Min = 16,
        Max = 60,
        Default = 55,
    },
    Step = 1,
    Callback = function(val)
        State.TeleportChaseSpeed = val
    end,
})

TabCombat:Slider({
    Title = "Teleport Trigger Range (studs)",
    Desc = "Distance at which teleport is executed (after chase or if already close)",
    Value = {
        Min = 30,
        Max = 200,
        Default = 90,
    },
    Step = 5,
    Callback = function(val)
        State.TeleportMaxDist = val
    end,
})

TabCombat:Section({
    Title = "Triggerbot (Instant Auto-Fire)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Triggerbot Enabled",
    Desc = "Automatically fires weapon instantly when crosshair intersects an enemy",
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
    Desc = "Only pulls trigger when crosshair is directly on Head / HeadHitbox",
    Value = State.TriggerbotHeadOnly,
    Callback = function(val)
        State.TriggerbotHeadOnly = val
    end,
})

TabCombat:Section({
    Title = "Weapon Modifications",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Rapid Fire (Zero Cooldown)",
    Desc = "Bypasses weapon firing delay for ultra-fast continuous shooting",
    Value = State.RapidFire,
    Callback = function(val)
        State.RapidFire = val
    end,
})

TabCombat:Toggle({
    Title = "No Recoil & No Screen Shake",
    Desc = "Completely neutralizes camera kick for laser-beam accuracy",
    Value = State.NoRecoil,
    Callback = function(val)
        State.NoRecoil = val
        if CameraController then
            if val then
                CameraController.Shoot = function() end
            else
                CameraController.Shoot = OriginalCameraShoot
            end
        end
    end,
})

-- =========================================================================
-- TAB 2: VISUALS (ESP & WALLHACK)
-- =========================================================================
TabVisuals:Section({
    Title = "Performance & Shaders",
    Opened = true,
})

TabVisuals:Toggle({
    Title = "FPS Booster (Ultra Performance)",
    Desc = "Disables heavy blur shaders, depth of field, bloom, and dynamic shadows for 65+ FPS on laptops",
    Value = State.FPSBooster,
    Callback = function(val)
        State.FPSBooster = val
        pcall(function()
            Lighting.GlobalShadows = not val
            for _, c in ipairs(Lighting:GetChildren()) do
                if c:IsA("BlurEffect") or c:IsA("DepthOfFieldEffect") or c:IsA("SunRaysEffect") then
                    c.Enabled = not val
                end
            end
        end)
    end,
})

TabVisuals:Section({
    Title = "Enemy Highlight Chams (Wallhack)",
    Opened = true,
})

TabVisuals:Toggle({
    Title = "Enemy Highlight Chams",
    Desc = "Renders full colored silhouette through all walls and obstacles",
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

TabVisuals:Section({
    Title = "Billboard Distance & Info ESP",
    Opened = true,
})

TabVisuals:Toggle({
    Title = "Enemy Nametags & Distance",
    Desc = "Floating billboard above enemy heads showing Name, HP, and Distance",
    Value = State.NametagsEnabled,
    Callback = function(val)
        State.NametagsEnabled = val
    end,
})

-- =========================================================================
-- TAB 3: MOVEMENT MODIFIERS
-- =========================================================================
TabMovement:Section({
    Title = "Native Velocity Modifiers",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Custom WalkSpeed",
    Value = State.CustomWalkSpeed,
    Callback = function(val)
        State.CustomWalkSpeed = val
        if MovementController then
            MovementController.WalkSpeed = val and State.WalkSpeed or DefaultWalkSpeed
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed",
    Value = {
        Min = 16,
        Max = 60,
        Default = 22,
    },
    Step = 1,
    Callback = function(val)
        State.WalkSpeed = val
        if State.CustomWalkSpeed and MovementController then
            MovementController.WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Custom SlideSpeed",
    Value = State.CustomSlideSpeed,
    Callback = function(val)
        State.CustomSlideSpeed = val
        if MovementController then
            MovementController.SlideSpeed = val and State.SlideSpeed or DefaultSlideSpeed
        end
    end,
})

TabMovement:Slider({
    Title = "SlideSpeed",
    Value = {
        Min = 35,
        Max = 100,
        Default = 48,
    },
    Step = 1,
    Callback = function(val)
        State.SlideSpeed = val
        if State.CustomSlideSpeed and MovementController then
            MovementController.SlideSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Infinite Slide (Zero Cooldown)",
    Desc = "Removes slide cooldown and penalty window for continuous sliding",
    Value = State.InfiniteSlide,
    Callback = function(val)
        State.InfiniteSlide = val
        if MovementController then
            MovementController.SlideCooldownTime = val and 0 or DefaultSlideCooldown
            MovementController.SlidePenaltyWindow = val and 0 or 0.6
        end
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
    Desc = "Pass smoothly through walls and barriers",
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
-- TAB 4: AUTO REWARDS & QUESTS
-- =========================================================================
TabRewards:Section({
    Title = "Automated Reward Sweeper",
    Opened = true,
})

TabRewards:Toggle({
    Title = "Auto Claim Daily Rewards",
    Desc = "Automatically claims daily calendar milestone cash and crates",
    Value = State.AutoClaimDaily,
    Callback = function(val)
        State.AutoClaimDaily = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Playtime Rewards",
    Desc = "Automatically collects playtime milestone gifts",
    Value = State.AutoClaimPlaytime,
    Callback = function(val)
        State.AutoClaimPlaytime = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Welcome Bonuses",
    Desc = "Claims welcome back cases and cash gifts automatically",
    Value = State.AutoClaimWelcome,
    Callback = function(val)
        State.AutoClaimWelcome = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Collect Floor Drops (Vacuum)",
    Desc = "Automatically vacuums and collects all cash and ammo dropped by slain enemies",
    Value = State.AutoVacuumDrops,
    Callback = function(val)
        State.AutoVacuumDrops = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Respawn (Space)",
    Desc = "Instantly triggers the native respawn the moment you are eliminated (bypasses the death timer / kill-cam wait)",
    Value = State.AutoRespawn,
    Callback = function(val)
        State.AutoRespawn = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Deploy Into Match",
    Desc = "Automatically deploys into the match arena upon respawn or round change",
    Value = State.AutoDeploy,
    Callback = function(val)
        State.AutoDeploy = val
    end,
})

TabRewards:Section({
    Title = "Auto Ranked Queue",
    Opened = true,
})

TabRewards:Toggle({
    Title = "Auto Ranked Mode",
    Desc = "Automatically queues into Ranked match from lobby. Script survives loading screens via queue_on_teleport re-injection.",
    Value = State.AutoRanked,
    Callback = function(val)
        State.AutoRanked = val
        if val then
            SafeNotify({
                Title = "Auto Ranked ON",
                Content = "Will auto-queue Ranked and re-inject script after every loading screen.",
                Duration = 4,
                Icon = "zap",
            })
        end
    end,
})

TabRewards:Button({
    Title = "Claim All Available Rewards Now",
    Callback = function()
        pcall(function()
            if Network then
                Network:FireServer("ClaimDailyReward")
                Network:FireServer("ClaimTimeReward")
                Network:FireServer("ClaimWelcomeBackCase")
                Network:FireServer("ClaimWelcomeBackCash")
                Network:FireServer("ClaimHalloweenDaily")
            end
        end)
        SafeNotify({
            Title = "Rewards Swept",
            Content = "Claimed daily, playtime, and bonus rewards.",
            Duration = 3,
            Icon = "gift",
        })
    end,
})

-- =========================================================================
-- TAB 5: CONFIG & PERSISTENCE
-- =========================================================================
TabConfig:Section({
    Title = "Profile Persistence",
    Opened = true,
})

local ConfigFileName = "DeagleArena_Config.json"

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
    Value = State.UIKeybind,
    Callback = function(key)
        State.UIKeybind = key
        pcall(function() Window:SetToggleKey(key) end)
    end,
})

-- Bulletproof Hardware Keybind Listener (Bypasses ContextActionService sink)
local function ToggleInterface()
    pcall(function()
        local parent = gethui and gethui() or game:GetService("CoreGui")
        local winFolder = parent:FindFirstChild("WindUI") and parent.WindUI:FindFirstChild("Window")
        if winFolder then
            local mainFrame = nil
            local openBtn = nil
            for _, c in ipairs(winFolder:GetChildren()) do
                if c:IsA("Frame") then
                    if c.Size.X.Offset > 300 then
                        mainFrame = c
                    else
                        openBtn = c
                    end
                end
            end
            if mainFrame then
                local willBeVisible = not mainFrame.Visible
                mainFrame.Visible = willBeVisible
                if openBtn then
                    openBtn.Visible = not willBeVisible
                end
                return
            end
        end
        if Window and Window.Toggle then
            Window:Toggle()
        end
    end)
end

RegisterConnection(UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == State.UIKeybind
        or input.KeyCode == Enum.KeyCode.LeftControl
        or input.KeyCode == Enum.KeyCode.RightControl
        or input.KeyCode == Enum.KeyCode.Insert then
        ToggleInterface()
    end
end))

TabConfig:Button({
    Title = "Unload Automation Script",
    Icon = "power",
    Callback = function()
        if getgenv()._DEAGLE_SCRIPT_UNLOAD then
            getgenv()._DEAGLE_SCRIPT_UNLOAD()
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
getgenv()._DEAGLE_SCRIPT_UNLOAD = function()
    pcall(RunService.UnbindFromRenderStep, RunService, "DeagleArena_Aimbot")

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
    for _, b in pairs(BillboardsList) do
        pcall(b.Destroy, b)
    end

    if Network and OriginalNetworkFireServer then
        Network.FireServer = OriginalNetworkFireServer
    end

    if MovementController then
        MovementController.WalkSpeed = DefaultWalkSpeed
        MovementController.SlideSpeed = DefaultSlideSpeed
        MovementController.SlideCooldownTime = DefaultSlideCooldown
    end

    if CameraController and OriginalCameraShoot then
        CameraController.Shoot = OriginalCameraShoot
    end

    pcall(function()
        Lighting.GlobalShadows = true
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:IsA("BlurEffect") or c:IsA("DepthOfFieldEffect") or c:IsA("SunRaysEffect") then
                c.Enabled = true
            end
        end
    end)

    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    getgenv()._DEAGLE_SCRIPT_RUNNING = nil
    getgenv()._DEAGLE_SCRIPT_UNLOAD = nil
end

-- =========================================================================
-- DRAWING OVERLAY (FOV CIRCLE)
-- =========================================================================
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Radius = State.AimbotFOV
        FOVCircle.Color = Color3.fromRGB(0, 255, 120)
        FOVCircle.Thickness = 1.5
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.7
        RegisterDrawing(FOVCircle)
    end
end)

-- =========================================================================
-- ULTRA-PERFORMANCE THROTTLED ENTITY SCANNER (ZERO PER-FRAME GC CHURN)
-- =========================================================================
local CachedEnemies = {}

-- Server-grade team filter: skips teammates via native GamemodeShared.AreTeammates
-- (attribute GamemodeTeam on character/player; only active in TEAM gamemodes)
local function IsTeammate(model)
    if not GamemodeShared then return false end
    local ok, res = pcall(GamemodeShared.AreTeammates, LocalPlayer.Character, model)
    if ok and res == true then return true end
    -- Fallback: direct attribute comparison if AreTeammates unavailable mid-round-switch
    local myTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("GamemodeTeam")
    if myTeam then
        local theirTeam = model:GetAttribute("GamemodeTeam")
        if theirTeam == nil then
            local p = Players:GetPlayerFromCharacter(model)
            theirTeam = p and p:GetAttribute("GamemodeTeam")
        end
        if theirTeam ~= nil and theirTeam == myTeam then return true end
    end
    return false
end

RegisterTask(task.spawn(function()
    while true do
        local list = {}
        local myChar = LocalPlayer.Character
        for _, c in ipairs(workspace:GetChildren()) do
            if c:IsA("Model") and c ~= myChar then
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and c:GetAttribute("Alive") ~= false then
                    local isProtected = false
                    if EffectsController and EffectsController.ProtectedPlayers then
                        isProtected = EffectsController.ProtectedPlayers[c] == true
                    end
                    if not isProtected and c:GetAttribute("Ragdolled") ~= true and not IsTeammate(c) then
                        table.insert(list, c)
                    end
                end
            end
        end
        CachedEnemies = list
        task.wait(0.3)
    end
end))

-- Helper: Retrieve target hitbox part
local function GetTargetPart(model, partName)
    local p = model:FindFirstChild(partName)
    if p and p:IsA("BasePart") then return p end
    p = model:FindFirstChild("HeadHitbox") or model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso")
    if p and p:IsA("BasePart") then return p end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

-- Helper: Visibility Check using native camera Raycast or DeagleShared
local function IsVisible(targetPart, targetModel)
    if not State.AimbotWallCheck then return true end
    Camera = workspace.CurrentCamera
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position

    if DeagleShared and DeagleShared.Raycast then
        local hit = DeagleShared.Raycast(LocalPlayer.Character, origin, targetPos)
        if hit and hit.Instance then
            local hitChar = DeagleShared.GetCharacterFromHit(hit.Instance)
            return hitChar == targetModel
        end
        return false
    else
        local ignore = {LocalPlayer.Character, targetModel, workspace:FindFirstChild("Effects")}
        local obscuring = Camera:GetPartsObscuringTarget({targetPos}, ignore)
        return #obscuring == 0
    end
end

-- =========================================================================
-- WORKER THREADS & BACKGROUND LOOPS
-- =========================================================================

-- 1. FOV Circle & Rapid Fire Hook
RegisterConnection(RunService.RenderStepped:Connect(function()
    if FOVCircle then
        if State.ShowFOVCircle and State.AimbotEnabled then
            Camera = workspace.CurrentCamera
            FOVCircle.Visible = true
            FOVCircle.Position = Camera.ViewportSize / 2
            FOVCircle.Radius = State.AimbotFOV
        elseif FOVCircle.Visible then
            FOVCircle.Visible = false
        end
    end

    -- Rapid-Fire: Reset DeagleController cooldown
    if State.RapidFire and DeagleController then
        DeagleController.CanShoot = true
        DeagleController.ShootCooldownUntil = 0
        DeagleController.CooldownEndsAt = 0
    end
end))

-- 2. Precision Aimbot Engine
RunService:BindToRenderStep("DeagleArena_Aimbot", Enum.RenderPriority.Camera.Value + 20, function()
    if not State.AimbotEnabled then return end

    if State.AimbotActivation == "Hold Right-Click (RMB)" and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    Camera = workspace.CurrentCamera
    local viewportCenter = Camera.ViewportSize / 2
    local candidates = {}

    for _, enemy in ipairs(CachedEnemies) do
        if enemy.Parent then
            local targetPart = GetTargetPart(enemy, State.AimbotTargetPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                    if screenDist <= State.AimbotFOV then
                        local hum = enemy:FindFirstChildOfClass("Humanoid")
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

    if #candidates == 0 then return end
    table.sort(candidates, function(a, b) return a.score < b.score end)

    local bestTarget = nil
    for _, cand in ipairs(candidates) do
        if IsVisible(cand.part, cand.enemy) then
            bestTarget = cand.part
            break
        end
    end

    if bestTarget then
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, bestTarget.Position)
        if State.AimbotSmoothness <= 1 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / State.AimbotSmoothness)
        end
    end
end)

-- 3. Silent Aim Hook on Network:FireServer
if Network and Network.FireServer and OriginalNetworkFireServer then
    Network.FireServer = function(self, action, ...)
        if action == "Shoot" and State.SilentAim then
            local args = { ... }
            Camera = workspace.CurrentCamera
            local viewportCenter = Camera.ViewportSize / 2
            local bestEnemy = nil
            local bestDist = State.SilentAimFOV

            for _, enemy in ipairs(CachedEnemies) do
                local headPart = enemy:FindFirstChild("HeadHitbox") or enemy:FindFirstChild("Head")
                if headPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headPart.Position)
                    if onScreen then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                        if d <= bestDist and IsVisible(headPart, enemy) then
                            bestDist = d
                            bestEnemy = headPart
                        end
                    end
                end
            end

            if bestEnemy then
                args[2] = bestEnemy.Position
                args[3] = bestEnemy
                args[4] = bestEnemy.Position
                return OriginalNetworkFireServer(self, action, unpack(args))
            end
        end
        return OriginalNetworkFireServer(self, action, ...)
    end
end

-- 4. Triggerbot Engine
RegisterTask(task.spawn(function()
    while true do
        if State.TriggerbotEnabled and DeagleController and DeagleController.Shoot then
            Camera = workspace.CurrentCamera
            local center = Camera.ViewportSize / 2
            local ray = Camera:ViewportPointToRay(center.X, center.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, workspace:FindFirstChild("Effects")}

            local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            if hit and hit.Instance then
                local hitModel = hit.Instance:FindFirstAncestorOfClass("Model")
                if hitModel and hitModel ~= LocalPlayer.Character and hitModel:FindFirstChildOfClass("Humanoid") and not IsTeammate(hitModel) then
                    local canShoot = true
                    if State.TriggerbotHeadOnly then
                        canShoot = (hit.Instance.Name == "Head" or hit.Instance.Name == "HeadHitbox")
                    end

                    if canShoot then
                        if State.TriggerbotDelay > 0 then
                            task.wait(State.TriggerbotDelay / 1000)
                        end
                        pcall(function()
                            DeagleController.CanShoot = true
                            DeagleController.ShootCooldownUntil = 0
                            DeagleController.Shoot()
                        end)
                        task.wait(0.12)
                    end
                end
            end
        end
        task.wait(0.04)
    end
end))

-- 5. Auto Combat Eliminator (Auto Shoot Loop)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoShoot and Network then
            local myChar = LocalPlayer.Character
            if myChar and myChar:GetAttribute("Alive") ~= false and LocalPlayer:GetAttribute("InRound") == true then
                Camera = workspace.CurrentCamera
                local origin = Camera.CFrame.Position
                local bestTarget = nil
                local bestDist = math.huge

                for _, enemy in ipairs(CachedEnemies) do
                    local head = enemy:FindFirstChild("HeadHitbox") or enemy:FindFirstChild("Head")
                    if head and IsVisible(head, enemy) then
                        local d = (head.Position - origin).Magnitude
                        if d < bestDist then
                            bestDist = d
                            bestTarget = head
                        end
                    end
                end

                if bestTarget then
                    local hitPos = bestTarget.Position
                    local serverTime = workspace:GetServerTimeNow()
                    pcall(function()
                        Network:FireServer("Shoot", origin, hitPos, bestTarget, hitPos, serverTime)
                    end)
                    task.wait(State.AutoShootDelay or 0.15)
                end
            end
        end
        task.wait(0.06)
    end
end))

-- 5b. Teleport Kill Engine (Sticky Hunter: Chase far enemies, teleport+glue close ones)
RegisterTask(task.spawn(function()
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    while true do
        if State.TeleportKill then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

            if not myChar or not myHRP or not myHum or myHum.Health <= 0 or myChar:GetAttribute("Alive") == false then
                task.wait(1)
            elseif LocalPlayer:GetAttribute("InRound") ~= true or #CachedEnemies == 0 then
                task.wait(0.4)
            else
                -- Acquire closest alive enemy
                local target = nil
                local closestDist = math.huge
                local maxDist = State.TeleportMaxDist or 90
                for _, c in ipairs(CachedEnemies) do
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - myHRP.Position).Magnitude
                        if d < closestDist then
                            closestDist = d
                            target = c
                        end
                    end
                end

                if not target then
                    task.wait(0.4)
                elseif closestDist > maxDist then
                    -- ================================================================
                    -- PHASE 1: NOCLIP CHASE â floor-following run towards enemy
                    -- ================================================================
                    if State.TeleportChaseEnabled then
                        local chaseSpeed = State.TeleportChaseSpeed or 55
                        local targetHRP = target:FindFirstChild("HumanoidRootPart")
                        local chaseStart = os.clock()

                        while State.TeleportKill and target and target.Parent
                                and targetHRP and targetHRP.Parent do
                            local hum = target:FindFirstChildOfClass("Humanoid")
                            if not hum or hum.Health <= 0 or target:GetAttribute("Alive") == false then break end
                            local curDist = (targetHRP.Position - myHRP.Position).Magnitude
                            if curDist <= maxDist then break end
                            if os.clock() - chaseStart > 8 then break end

                            -- Floor-following: raycast down to find ground
                            rayParams.FilterDescendantsInstances = {myChar}
                            local above = myHRP.Position + Vector3.new(0, 3, 0)
                            local floorHit = workspace:Raycast(above, Vector3.new(0, -6, 0), rayParams)
                            local targetY = floorHit and (floorHit.Position.Y + 2.8) or myHRP.Position.Y

                            -- Slide horizontally toward target, snap Y to floor
                            local tx, tz = targetHRP.Position.X, targetHRP.Position.Z
                            local dx, dz = tx - myHRP.Position.X, tz - myHRP.Position.Z
                            local len = math.sqrt(dx*dx + dz*dz)
                            if len > 0.01 then
                                dx, dz = dx/len, dz/len
                            end
                            local newPos = Vector3.new(
                                myHRP.Position.X + dx * chaseSpeed * 0.05,
                                targetY,
                                myHRP.Position.Z + dz * chaseSpeed * 0.05
                            )
                            myHRP.CFrame = CFrame.new(newPos, Vector3.new(tx, newPos.Y, tz))
                            myHRP.AssemblyLinearVelocity = Vector3.zero

                            -- Keep noclip during chase
                            for _, part in ipairs(myChar:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end
                            task.wait(0.05)
                        end
                    else
                        task.wait(0.4)
                    end
                else
                    -- ================================================================
                    -- PHASE 2: TELEPORT + MAGNETIC GLUE + BURST HEADSHOT
                    -- ================================================================
                    local targetHRP = target:FindFirstChild("HumanoidRootPart")
                    local targetHead = target:FindFirstChild("Head") or targetHRP
                    if not targetHRP then task.wait(0.2) else
                        local stickOffset = State.TeleportStickOffset or 2.5
                        local jumpCF = targetHRP.CFrame * CFrame.new(0, 0, -math.max(stickOffset, 4))
                        myHRP.CFrame = CFrame.new(jumpCF.Position, targetHead.Position)
                        myHRP.AssemblyLinearVelocity = targetHRP.AssemblyLinearVelocity
                        task.wait(0.1)

                        local startTime = os.clock()
                        local lastShot = 0
                        while State.TeleportKill and target.Parent and targetHRP and targetHRP.Parent do
                            local hum = target:FindFirstChildOfClass("Humanoid")
                            if not hum or hum.Health <= 0 or target:GetAttribute("Alive") == false then break end
                            if (os.clock() - startTime) > 3 then break end

                            local curDist = (targetHRP.Position - myHRP.Position).Magnitude
                            if curDist <= 10 then
                                local glueCF = targetHRP.CFrame * CFrame.new(0, 0, -stickOffset)
                                myHRP.CFrame = CFrame.new(glueCF.Position, targetHead.Position)
                                myHRP.AssemblyLinearVelocity = targetHRP.AssemblyLinearVelocity
                                myHRP.AssemblyAngularVelocity = Vector3.zero
                            else
                                break -- enemy escaped: re-acquire â will chase again next tick
                            end

                            Camera = workspace.CurrentCamera
                            Camera.CFrame = CFrame.lookAt(
                                myChar.Head and myChar.Head.Position or myHRP.Position,
                                (target:FindFirstChild("HeadHitbox") or targetHead).Position
                            )

                            local headPart = target:FindFirstChild("HeadHitbox") or target:FindFirstChild("Head")
                            local now = os.clock()
                            if headPart and Network and (now - lastShot) >= (State.TeleportKillDelay or 0.12) then
                                lastShot = now
                                pcall(function()
                                    Network:FireServer("Shoot",
                                        Camera.CFrame.Position, headPart.Position,
                                        headPart, headPart.Position,
                                        workspace:GetServerTimeNow())
                                end)
                            end
                            task.wait(0.05)
                        end
                        task.wait(State.TeleportSwitchDelay or 0.2)
                    end
                end
            end
        end
        task.wait(0.05)
    end
end))

-- 6. Enemy Highlight Chams (Wallhack) & Billboard Nametags Engine
RegisterTask(task.spawn(function()
    while true do
        if State.ChamsEnabled or State.NametagsEnabled then
            local currentSet = {}

            for _, enemy in ipairs(CachedEnemies) do
                currentSet[enemy] = true

                -- Chams Highlight
                if State.ChamsEnabled then
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

                -- Billboard Nametag
                if State.NametagsEnabled then
                    local head = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HeadHitbox")
                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    if head and hum then
                        local b = BillboardsList[enemy]
                        if not b or not b.Parent then
                            b = Instance.new("BillboardGui")
                            b.Name = "ClientOP_Nametag"
                            b.Adornee = head
                            b.Size = UDim2.fromOffset(160, 36)
                            b.StudsOffset = Vector3.new(0, 2.5, 0)
                            b.AlwaysOnTop = true

                            local lbl = Instance.new("TextLabel")
                            lbl.Name = "Info"
                            lbl.Size = UDim2.fromScale(1, 1)
                            lbl.BackgroundTransparency = 1
                            lbl.Font = Enum.Font.FredokaOne
                            lbl.TextSize = 13
                            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            lbl.TextStrokeTransparency = 0.2
                            lbl.Parent = b

                            b.Parent = head
                            BillboardsList[enemy] = b
                        end

                        local myPos = Camera.CFrame.Position
                        local dist = math.floor((head.Position - myPos).Magnitude)
                        local lbl = b:FindFirstChild("Info")
                        if lbl then
                            lbl.Text = string.format("%s\n%d HP | %dm", enemy.Name, math.floor(hum.Health), dist)
                        end
                    end
                end
            end

            -- Clean stale entities
            for enemy, h in pairs(HighlightsList) do
                if not currentSet[enemy] or not State.ChamsEnabled then
                    pcall(h.Destroy, h)
                    HighlightsList[enemy] = nil
                end
            end
            for enemy, b in pairs(BillboardsList) do
                if not currentSet[enemy] or not State.NametagsEnabled then
                    pcall(b.Destroy, b)
                    BillboardsList[enemy] = nil
                end
            end
        else
            for enemy, h in pairs(HighlightsList) do
                pcall(h.Destroy, h)
                HighlightsList[enemy] = nil
            end
            for enemy, b in pairs(BillboardsList) do
                pcall(b.Destroy, b)
                BillboardsList[enemy] = nil
            end
        end
        task.wait(1.5)
    end
end))

-- 7. Movement Modifiers (BHop, Noclip, Infinite Jump, Anti-AFK)
RegisterConnection(RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
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

-- BHop via Heartbeat
RegisterConnection(RunService.Heartbeat:Connect(function()
    if State.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and (hum.FloorMaterial ~= Enum.Material.Air and hum.FloorMaterial ~= Enum.Material.Plastic or hum:GetState() == Enum.HumanoidStateType.Landed) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- 8. Automated Rewards Sweeper & Floor Drops Vacuum Loop
RegisterTask(task.spawn(function()
    while true do
        -- Auto Daily Rewards
        if State.AutoClaimDaily and Network then
            pcall(function()
                Network:FireServer("ClaimDailyReward")
            end)
        end

        -- Auto Playtime
        if State.AutoClaimPlaytime and Network then
            pcall(function()
                Network:FireServer("ClaimTimeReward")
            end)
        end

        -- Auto Welcome Bonuses
        if State.AutoClaimWelcome and Network then
            pcall(function()
                Network:FireServer("ClaimWelcomeBackCase")
                Network:FireServer("ClaimWelcomeBackCash")
                Network:FireServer("ClaimHalloweenDaily")
            end)
        end

        -- Auto Vacuum Floor Drops
        if State.AutoVacuumDrops and Network then
            pcall(function()
                local killDropCtrl = require(ModuleLoader:WaitForChild("KillDropController"))
                local drops = debug.getupvalues(killDropCtrl.Init)[1]
                if type(drops) == "table" then
                    for _, dropGroup in pairs(drops) do
                        if dropGroup.Mine and dropGroup.Drops then
                            for _, drop in ipairs(dropGroup.Drops) do
                                if not drop.Reported then
                                    drop.Reported = true
                                    Network:FireServer("KillDropCollect", dropGroup.Id, drop.Index)
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- Auto Deploy into Arena
        if State.AutoDeploy and RoundController then
            pcall(function()
                if LocalPlayer:GetAttribute("InRound") ~= true and RoundController.IsDeployReady and RoundController.IsDeployReady() then
                    RoundController.Spawn()
                end
            end)
        end

        task.wait(2.5)
    end
end))

-- 9. Auto Respawn (Space) Engine â ONE native re-deploy per death (no teleport spam)
RegisterTask(task.spawn(function()
    local deployedForThisDeath = false
    local deathClock = 0
    while true do
        if State.AutoRespawn then
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local dead = not myChar or not myHum or myHum.Health <= 0 or myChar:GetAttribute("Alive") == false

            if dead then
                if not deployedForThisDeath then
                    deathClock = os.clock()
                    deployedForThisDeath = true
                elseif (os.clock() - deathClock) > 2.5 then
                    -- Still dead 2.5s after first attempt: game's own kill-cam/deploy gate may
                    -- still be cooling down. Fire ONE more native request, then wait again.
                    deathClock = os.clock()
                    pcall(function()
                        local dc = require(ModuleLoader.UI.HUD.DeathCamera)
                        if dc and dc.RequestDeploy then
                            dc.RequestDeploy()
                        elseif RoundController and RoundController.Spawn then
                            RoundController.Spawn()
                        end
                    end)
                end
            else
                -- Alive again: arm for the next death
                deployedForThisDeath = false
            end
        else
            deployedForThisDeath = false
        end
        task.wait(0.2)
    end
end))

-- Maintain FPS Booster state against game menu blur re-enables
RegisterTask(task.spawn(function()
    while true do
        if State.FPSBooster then
            pcall(function()
                for _, c in ipairs(Lighting:GetChildren()) do
                    if c:IsA("BlurEffect") or c:IsA("DepthOfFieldEffect") or c:IsA("SunRaysEffect") then
                        if c.Enabled then c.Enabled = false end
                    end
                end
            end)
        end
        task.wait(1)
    end
end))

SafeNotify({
    Title = "Deagle Arena",
    Content = "Elite Combat & Automation Suite Loaded (Toggle: LeftControl).",
    Duration = 4,
    Icon = "crosshair",
})

-- =========================================================================
-- 10. SCRIPT PERSISTENCE ACROSS LOADING SCREENS / TELEPORTS (queue_on_teleport)
-- The game teleports players between lobby/match/ranked places; the DataModel
-- resets and this script dies with it. We snapshot our config to disk and
-- re-queue an injector on every teleport so the GUI + toggles survive.
-- =========================================================================
local PersistFileName = "DeagleArena_Persist.json"

local function SnapshotConfig()
    pcall(function()
        local out = {}
        for k, v in pairs(State) do
            if typeof(v) ~= "EnumItem" then
                out[k] = v
            else
                out[k] = tostring(v)
            end
        end
        writefile(PersistFileName, HttpService:JSONEncode(out))
    end)
end

local INJECTOR_SOURCE = [==[
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(3)
    local hs = game:GetService("HttpService")
    local saved = {}
    pcall(function()
        if isfile("DeagleArena_Persist.json") then
            saved = hs:JSONDecode(readfile("DeagleArena_Persist.json"))
        end
    end)
    local src
    for _, name in ipairs({"DeagleArena.lua", "ClientOP_DeagleArena.lua"}) do
        pcall(function()
            if isfile(name) then src = readfile(name) end
        end)
        if src then break end
    end
    if src then
        local fn = loadstring(src)
        if fn then
            pcall(fn)
            task.wait(2)
            local st = getgenv()._DEAGLE_STATE
            if st then
                for k, v in pairs(saved) do
                    if k ~= "UIKeybind" and st[k] ~= nil and type(v) ~= "table" and type(st[k]) ~= "table" then
                        st[k] = v
                    end
                end
            end
        end
    end
]==]

-- Schedule exactly ONE injector per place: when PlaceId changes (we got teleported
-- into a new DataModel), the previous queue entry was consumed, so arm a new one.
getgenv()._DEAGLE_PERSIST_ARMED_FOR = getgenv()._DEAGLE_PERSIST_ARMED_FOR

RegisterTask(task.spawn(function()
    if type(queue_on_teleport) ~= "function" then return end
    while true do
        if getgenv()._DEAGLE_PERSIST_ARMED_FOR ~= game.PlaceId then
            getgenv()._DEAGLE_PERSIST_ARMED_FOR = game.PlaceId
            SnapshotConfig()
            pcall(queue_on_teleport, INJECTOR_SOURCE)
        end
        task.wait(2)
    end
end))

-- Snapshot config whenever a toggle changes too (cheap, every 6s)
RegisterTask(task.spawn(function()
    while true do
        SnapshotConfig()
        task.wait(6)
    end
end))

-- =========================================================================
-- 11. AUTO RANKED QUEUE ENGINE
-- From lobby: queues Ranked via the game's own SelectPlayMode RPC, deploys
-- when ready, and re-queues after each round ends. One request per lobby
-- entry (never spammed mid-teleport â same kick-protection as before).
-- =========================================================================
local RANKED_PLACE_ID = 112087763192016

RegisterTask(task.spawn(function()
    local lastQueue = 0
    while true do
        if State.AutoRanked then
            pcall(function()
                local inMatch = LocalPlayer:GetAttribute("InRound") == true
                local placeId = game.PlaceId
                local serverMode = tostring(ReplicatedStorage:GetAttribute("ServerMode"))
                local now = os.clock()

                if placeId == RANKED_PLACE_ID or serverMode == "Ranked" then
                    -- Already in a ranked server: ensure we're deployed in-round
                    if not inMatch and RoundController and RoundController.IsDeployReady and RoundController.IsDeployReady() then
                        if now - lastQueue > 3 then
                            lastQueue = now
                            pcall(RoundController.Spawn)
                        end
                    end
                elseif not inMatch and now - lastQueue > 5 then
                    -- In lobby/casual: fire ONE ranked queue request like the PlayMenu button does
                    lastQueue = now
                    local res = Network and Network.InvokeServer and Network:InvokeServer("SelectPlayMode", "Ranked")
                    if res == "Deploy" and RoundController and RoundController.Spawn then
                        task.wait(0.5)
                        pcall(RoundController.Spawn)
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end))
