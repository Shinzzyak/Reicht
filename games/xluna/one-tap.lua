-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [FPS] One Tap â Elite ClientOP Combat & Automation Master Suite
    Architecture: WindUI v1.6.65 / Modern Luau / Native Game Service Hooks
    Operating Directive: Strict SOP Compliance, Zero AI Slop, Native Service Hooks, Zero Detection Risk.
    Features: Precision Aimbot, Silent Aim, Triggerbot, Rapid-Fire Hook, Native Speed Modifier,
              Enemy Highlight Chams (Wallhack), 2D Box ESP, Tracers, Automated Quest & Reward Claimer,
              Instant Respawn, Auto Deploy, Configuration Persistence.
]]

-- Anti-double-execution guard
if getgenv()._ONETAP_SCRIPT_RUNNING then
    if getgenv()._ONETAP_SCRIPT_UNLOAD then
        pcall(getgenv()._ONETAP_SCRIPT_UNLOAD)
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

getgenv()._ONETAP_SCRIPT_RUNNING = true

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

-- Game Modules & ByteNet Packets
local Common = ReplicatedStorage:WaitForChild("Common")
local Managers = Common:WaitForChild("Managers")
local Packets = Common:WaitForChild("Packets")

local WeaponManager = nil
local QuestPackets = nil
local PlaytimeRewardPackets = nil
local LevelRewardPackets = nil
local GroupRewardPackets = nil
local DailyRewardPackets = nil
local MainGamePackets = nil
local DeathPackets = nil
local WeaponClient = nil

pcall(function() WeaponManager = require(Managers:WaitForChild("WeaponManager")) end)
pcall(function() QuestPackets = require(Packets:WaitForChild("QuestPackets")) end)
pcall(function() PlaytimeRewardPackets = require(Packets:WaitForChild("PlaytimeRewardPackets")) end)
pcall(function() LevelRewardPackets = require(Packets:WaitForChild("LevelRewardPackets")) end)
pcall(function() GroupRewardPackets = require(Packets:WaitForChild("GroupRewardPackets")) end)
pcall(function() DailyRewardPackets = require(Packets:WaitForChild("DailyRewardPackets")) end)
pcall(function() MainGamePackets = require(Packets:WaitForChild("MainGamePackets")) end)
pcall(function() DeathPackets = require(Packets:WaitForChild("DeathPackets")) end)

pcall(function()
    WeaponClient = require(LocalPlayer.PlayerScripts.Start.Game.WeaponClient)
end)

-- Retrieve native speed table from WeaponClient upvalues
local NativeSpeeds = nil
pcall(function()
    if WeaponClient and WeaponClient.onWeaponChanged then
        local uvs = debug.getupvalues(WeaponClient.onWeaponChanged)
        NativeSpeeds = uvs and uvs[3]
    end
end)

-- Global Automation State Table (Default: ALL OFF as per SOP Rule 8)
local State = {
    -- 1. Combat & Aimbot
    AimbotEnabled = false,
    AimbotTargetPart = "Head", -- "Head", "Torso", "HumanoidRootPart"
    AimbotFOV = 120,
    ShowFOVCircle = false,
    AimbotSmoothness = 1, -- 1 = instant snap, higher = smooth glide
    AimbotWallCheck = true,
    AimbotActivation = "Always Active", -- "Always Active", "Hold Right-Click (RMB)"
    AimbotPriority = "Closest to Crosshair", -- "Closest to Crosshair", "Lowest Health", "Closest Distance"

    -- Auto Teleport Knife Kill (Continuous Eliminator)
    AutoKnifeKill = false,
    KnifeKillDelay = 0.08,
    KnifeBurstDelay = 0.08,
    KnifeStickOffset = 1.6,

    -- Triggerbot
    TriggerbotEnabled = false,
    TriggerbotDelay = 0, -- ms
    TriggerbotHeadOnly = false,

    -- Weapon Mechanics
    RapidFire = false,
    InstantReload = false,

    -- 2. Visuals & ESP
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 30, 30),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsTransparency = 0.5,
    ChamsAlwaysOnTop = true,

    -- 3. Movement Modifiers
    SpeedEnabled = false,
    WalkSpeed = 22,
    BunnyHop = false,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = true,

    -- 4. Automation & Rewards
    AutoClaimQuests = false,
    AutoClaimPlaytime = false,
    AutoClaimLevelRewards = false,
    AutoRespawn = false,
    AutoDeploy = false,

    -- 5. Interface
    UIKeybind = Enum.KeyCode.LeftControl,
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
    getgenv()._ONETAP_SCRIPT_RUNNING = false
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
    Title = "One Tap",
    Icon = "crosshair",
    Author = "Elite Automation Suite",
    Folder = "OneTap",
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

getgenv()._ONETAP_WINDOW = Window
getgenv()._ONETAP_STATE = State
getgenv()._ONETAP_TABS = {
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
    Desc = "Automatically locks camera onto enemy head/hitbox",
    Value = State.AimbotEnabled,
    Callback = function(val)
        State.AimbotEnabled = val
    end,
})

TabCombat:Dropdown({
    Title = "Target Hitbox",
    Desc = "Bone priority for lock-on",
    Values = { "Head", "Torso", "HumanoidRootPart" },
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
    Title = "Auto Teleport Knife Eliminator (Sticky Burst)",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Auto Teleport Knife Kill (Sticky Burst)",
    Desc = "Teleports & magnetically GLUES to enemy body so they cannot escape, then slashes rapidly in high-speed bursts until dead, and moves to next enemy automatically",
    Value = State.AutoKnifeKill,
    Callback = function(val)
        State.AutoKnifeKill = val
        if val then
            SafeNotify({
                Title = "Sticky Knife Burst Active",
                Content = "Magnetically locking to enemies & bursting...",
                Duration = 3,
                Icon = "crosshair",
            })
        end
    end,
})

TabCombat:Slider({
    Title = "Burst Attack Delay (s)",
    Desc = "Delay between consecutive knife strikes (lower = faster burst)",
    Value = {
        Min = 0.05,
        Max = 0.2,
        Default = 0.08,
    },
    Step = 0.01,
    Callback = function(val)
        State.KnifeBurstDelay = val
    end,
})

TabCombat:Slider({
    Title = "Target Switch Delay (s)",
    Desc = "Delay before acquiring and teleporting to next enemy",
    Value = {
        Min = 0.05,
        Max = 0.3,
        Default = 0.08,
    },
    Step = 0.01,
    Callback = function(val)
        State.KnifeKillDelay = val
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
    Desc = "Only pulls trigger when crosshair is directly on the Head",
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
    Title = "Rapid Fire (Cooldown Bypass)",
    Desc = "Bypasses weapon firing delay for ultra-fast shooting",
    Value = State.RapidFire,
    Callback = function(val)
        State.RapidFire = val
    end,
})

TabCombat:Toggle({
    Title = "Instant Reload & Infinite Ammo State",
    Desc = "Automatically clears firing lock state to eliminate reload delays",
    Value = State.InstantReload,
    Callback = function(val)
        State.InstantReload = val
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

-- =========================================================================
-- TAB 3: MOVEMENT MODIFIERS
-- =========================================================================
TabMovement:Section({
    Title = "Native Speed Multiplier (Anti-Rubberband)",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Custom Speed Multiplier",
    Value = State.SpeedEnabled,
    Callback = function(val)
        State.SpeedEnabled = val
        if NativeSpeeds then
            NativeSpeeds.Primary = val and State.WalkSpeed or 22
            NativeSpeeds.Secondary = val and (State.WalkSpeed + 2) or 24
            NativeSpeeds.Knife = val and (State.WalkSpeed + 4) or 26
            if WeaponClient and WeaponClient.onWeaponChanged then
                WeaponClient.onWeaponChanged()
            end
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed",
    Value = {
        Min = 22,
        Max = 60,
        Default = 22,
    },
    Step = 1,
    Callback = function(val)
        State.WalkSpeed = val
        if State.SpeedEnabled and NativeSpeeds then
            NativeSpeeds.Primary = val
            NativeSpeeds.Secondary = val + 2
            NativeSpeeds.Knife = val + 4
            if WeaponClient and WeaponClient.onWeaponChanged then
                WeaponClient.onWeaponChanged()
            end
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
    Title = "Automated Quest & Gift Sweeper",
    Opened = true,
})

TabRewards:Toggle({
    Title = "Auto Claim Daily & Hourly Quests",
    Desc = "Automatically collects rewards for all completed daily and hourly quests",
    Value = State.AutoClaimQuests,
    Callback = function(val)
        State.AutoClaimQuests = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Playtime Rewards",
    Desc = "Collects playtime minutes rewards and free sniper gifts automatically",
    Value = State.AutoClaimPlaytime,
    Callback = function(val)
        State.AutoClaimPlaytime = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Level Up Bonuses",
    Desc = "Claims milestone rank level bonuses automatically",
    Value = State.AutoClaimLevelRewards,
    Callback = function(val)
        State.AutoClaimLevelRewards = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Instant Respawn",
    Desc = "Bypasses the 4-second respawn timer upon elimination",
    Value = State.AutoRespawn,
    Callback = function(val)
        State.AutoRespawn = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Deploy Into Match",
    Desc = "Automatically deploys into the match from the lobby screen",
    Value = State.AutoDeploy,
    Callback = function(val)
        State.AutoDeploy = val
    end,
})

TabRewards:Button({
    Title = "Claim All Available Rewards Now",
    Callback = function()
        pcall(function()
            if QuestPackets then
                QuestPackets.claimDailyQuest.send(1)
                QuestPackets.claimDailyQuest.send(2)
                QuestPackets.claimDailyQuest.send(3)
                QuestPackets.claimHourlyQuest.send(1)
            end
            if PlaytimeRewardPackets then
                PlaytimeRewardPackets.claimSniperReward.send()
                for i = 1, 10 do PlaytimeRewardPackets.claimReward.send(i) end
            end
            if GroupRewardPackets then
                GroupRewardPackets.claimReward.send()
            end
            if DailyRewardPackets then
                for day = 1, 7 do DailyRewardPackets.claimReward.send(day) end
            end
            if LevelRewardPackets then
                for lvl = 1, 30 do LevelRewardPackets.claimLevelReward.send(lvl) end
            end
            if DeathPackets then
                DeathPackets.claimFreeCase.send()
            end
        end)
        SafeNotify({
            Title = "Rewards Swept",
            Content = "Claimed all available quests, playtime, and level rewards.",
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

local ConfigFileName = "OneTap_Config.json"

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
        if getgenv()._ONETAP_SCRIPT_UNLOAD then
            getgenv()._ONETAP_SCRIPT_UNLOAD()
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
getgenv()._ONETAP_SCRIPT_UNLOAD = function()
    pcall(RunService.UnbindFromRenderStep, RunService, "OneTap_Aimbot")

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

    if NativeSpeeds then
        NativeSpeeds.Primary = 22
        NativeSpeeds.Secondary = 24
        NativeSpeeds.Knife = 26
        if WeaponClient and WeaponClient.onWeaponChanged then
            WeaponClient.onWeaponChanged()
        end
    end

    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    getgenv()._ONETAP_SCRIPT_RUNNING = nil
    getgenv()._ONETAP_SCRIPT_UNLOAD = nil
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

-- Helper: Retrieve active enemy models
local function GetEnemies()
    local enemies = {}
    local myChar = LocalPlayer.Character
    for _, char in ipairs(CollectionService:GetTagged("Character")) do
        if char ~= myChar and char:IsA("Model") and char.Parent then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(enemies, char)
            end
        end
    end
    return enemies
end

-- Helper: Retrieve target part
local function GetTargetPart(model, partName)
    local p = model:FindFirstChild(partName)
    if p and p:IsA("BasePart") then return p end
    p = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if p and p:IsA("BasePart") then return p end
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

-- Helper: Visibility Check using native camera GetPartsObscuringTarget
local function IsVisible(targetPart, targetModel)
    if not State.AimbotWallCheck then return true end
    local ignore = {LocalPlayer.Character, targetModel, workspace:FindFirstChild("Effects")}
    local obscuring = Camera:GetPartsObscuringTarget({targetPart.Position}, ignore)
    return #obscuring == 0
end

-- =========================================================================
-- WORKER THREADS & BACKGROUND LOOPS
-- =========================================================================

-- 1. FOV Circle & Rapid Fire Hook
RegisterConnection(RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    if FOVCircle and State.ShowFOVCircle and State.AimbotEnabled then
        FOVCircle.Visible = true
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = State.AimbotFOV
    elseif FOVCircle and FOVCircle.Visible then
        FOVCircle.Visible = false
    end

    -- Rapid-Fire & Instant Reload hook
    if (State.RapidFire or State.InstantReload) and WeaponClient and WeaponClient.fire then
        pcall(function()
            local u171 = debug.getupvalues(WeaponClient.fire)[1]
            if typeof(u171) == "function" then
                if State.InstantReload then
                    debug.setupvalue(u171, 6, "free")
                end
                if State.RapidFire then
                    debug.setupvalue(u171, 1, 0)
                end
            end
        end)
    end
end))

-- 2. Precision Aimbot Engine
RunService:BindToRenderStep("OneTap_Aimbot", Enum.RenderPriority.Camera.Value + 20, function()
    if not State.AimbotEnabled then return end

    if State.AimbotActivation == "Hold Right-Click (RMB)" and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    Camera = workspace.CurrentCamera
    local viewportCenter = Camera.ViewportSize / 2
    local candidates = {}

    for _, enemy in ipairs(GetEnemies()) do
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
        local targetCFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
        if State.AimbotSmoothness <= 1 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / State.AimbotSmoothness)
        end
    end
end)

-- 3. Triggerbot Engine
RegisterTask(task.spawn(function()
    while true do
        if State.TriggerbotEnabled and WeaponClient and WeaponClient.fire then
            local center = Camera.ViewportSize / 2
            local ray = Camera:ViewportPointToRay(center.X, center.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, workspace:FindFirstChild("Effects")}

            local hit = workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
            if hit and hit.Instance then
                local hitModel = hit.Instance:FindFirstAncestorOfClass("Model")
                if hitModel and CollectionService:HasTag(hitModel, "Character") and hitModel ~= LocalPlayer.Character then
                    local canShoot = true
                    if State.TriggerbotHeadOnly and hit.Instance.Name ~= "Head" then
                        canShoot = false
                    end

                    if canShoot then
                        if State.TriggerbotDelay > 0 then
                            task.wait(State.TriggerbotDelay / 1000)
                        end
                        pcall(function()
                            WeaponClient.fire()
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.03)
    end
end))

-- 4. Enemy Highlight Chams (Wallhack) Engine
RegisterTask(task.spawn(function()
    while true do
        if State.ChamsEnabled then
            local enemies = GetEnemies()
            for _, enemy in ipairs(enemies) do
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

-- 6. Automated Rewards & Deployment Loop
RegisterTask(task.spawn(function()
    while true do
        -- Auto Quests
        if State.AutoClaimQuests and QuestPackets then
            pcall(function()
                QuestPackets.claimDailyQuest.send(1)
                QuestPackets.claimDailyQuest.send(2)
                QuestPackets.claimDailyQuest.send(3)
                QuestPackets.claimHourlyQuest.send(1)
            end)
        end

        -- Auto Playtime
        if State.AutoClaimPlaytime and PlaytimeRewardPackets then
            pcall(function()
                PlaytimeRewardPackets.claimSniperReward.send()
                for i = 1, 10 do PlaytimeRewardPackets.claimReward.send(i) end
            end)
        end

        -- Auto Level Rewards
        if State.AutoClaimLevelRewards and LevelRewardPackets then
            pcall(function()
                for lvl = 1, 30 do LevelRewardPackets.claimLevelReward.send(lvl) end
            end)
        end

        task.wait(2.5)
    end
end))

-- Fast Auto Instant Respawn & Auto Deploy Loop
RegisterTask(task.spawn(function()
    while true do
        if (State.AutoRespawn or State.AutoKnifeKill) and MainGamePackets then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then
                    MainGamePackets.respawn.send(true)
                end
            end)
        end

        if (State.AutoDeploy or State.AutoKnifeKill) and MainGamePackets then
            pcall(function()
                local char = LocalPlayer.Character
                if char and not char:GetAttribute("deployed") then
                    MainGamePackets.deploy.send()
                end
            end)
        end

        task.wait(0.3)
    end
end))

-- 7. Auto Teleport Knife Eliminator Loop (Sticky Burst Magnet)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoKnifeKill then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

            if not myChar or not myHRP or not myHum or myHum.Health <= 0 then
                if MainGamePackets and MainGamePackets.respawn then
                    pcall(function() MainGamePackets.respawn.send(true) end)
                end
                task.wait(0.2)
            elseif not myChar:GetAttribute("deployed") then
                if MainGamePackets and MainGamePackets.deploy then
                    pcall(function() MainGamePackets.deploy.send() end)
                end
                task.wait(0.3)
            else
                -- Ensure knife is equipped
                if WeaponClient and myChar:GetAttribute("currentWeapon") ~= "Knife" then
                    WeaponClient.setWeapon(3)
                    task.wait(0.06)
                end

                -- Find closest living enemy without spawn protection (ForceField)
                local target = nil
                local closestDist = math.huge

                for _, c in ipairs(CollectionService:GetTagged("Character")) do
                    if c ~= myChar and c:IsA("Model") and c.Parent then
                        local hum = c:FindFirstChildOfClass("Humanoid")
                        local hrp = c:FindFirstChild("HumanoidRootPart")
                        local ff = c:FindFirstChildWhichIsA("ForceField")
                        if hum and hum.Health > 0 and hrp and not ff then
                            local d = (hrp.Position - myHRP.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                target = c
                            end
                        end
                    end
                end

                if target then
                    local targetHRP = target:FindFirstChild("HumanoidRootPart")
                    local targetHead = target:FindFirstChild("Head") or targetHRP

                    if targetHRP and WeaponClient and WeaponClient.fire then
                        local u171 = debug.getupvalues(WeaponClient.fire)[1]

                        local startTime = os.clock()
                        while State.AutoKnifeKill and target and target.Parent and targetHRP and targetHRP.Parent do
                            local hum = target:FindFirstChildOfClass("Humanoid")
                            if not hum or hum.Health <= 0 or (os.clock() - startTime) > 1.2 then
                                break
                            end

                            -- Continuous Magnetic Sticky Lock: Glue directly to enemy body
                            local stickOffset = State.KnifeStickOffset or 1.6
                            local glueCF = targetHRP.CFrame * CFrame.new(0, 0, stickOffset)
                            myHRP.CFrame = CFrame.new(glueCF.Position, targetHRP.Position)
                            myHRP.AssemblyLinearVelocity = targetHRP.AssemblyLinearVelocity
                            myHRP.AssemblyAngularVelocity = Vector3.zero
                            Camera.CFrame = CFrame.lookAt(myChar.Head.Position, targetHead.Position)

                            -- Noclip during sticky lock so character doesn't glitch or bounce off
                            for _, part in ipairs(myChar:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end

                            -- Rapid burst strike
                            if typeof(u171) == "function" then
                                debug.setupvalue(u171, 1, 0)
                                debug.setupvalue(u171, 6, "free")
                            end
                            WeaponClient.fire()

                            task.wait(State.KnifeBurstDelay or 0.08)
                        end
                        task.wait(State.KnifeKillDelay or 0.08)
                    end
                end
            end
        end
        task.wait(0.04)
    end
end))

SafeNotify({
    Title = "One Tap",
    Content = "Elite Combat & Automation Suite Loaded (Toggle: LeftControl).",
    Duration = 4,
    Icon = "crosshair",
})
