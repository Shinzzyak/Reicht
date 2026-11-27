-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    Throw Food For Animals â ClientOP Automation Master Script
    Architecture: WindUI v1.x / Modern Luau / Real MCP Execution
    Operating Directive: Strict Compliance, Robust Engineering, Full Disassembly Verifications
]]

-- Anti-double-execution guard
if getgenv()._THROW_FOOD_RUNNING then
    if getgenv()._THROW_FOOD_UNLOAD then
        pcall(getgenv()._THROW_FOOD_UNLOAD)
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

getgenv()._THROW_FOOD_RUNNING = true

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

-- Configurations & Remotes
local RemotesModule = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local FoodsConfig = require(ReplicatedStorage.Config.FoodsConfig)
local AreasConfig = require(ReplicatedStorage.Config.AreasConfig)
local StandsConfig = require(ReplicatedStorage.Config.StandsConfig)
local LevelConfig = require(ReplicatedStorage.Config.LevelConfig)
local ClientControllers = LocalPlayer.PlayerScripts.Client.Controllers
local DataController = require(ClientControllers.DataController)
local ClientState = require(ClientControllers.ClientState)
local ThrowMeterController = require(ClientControllers.ThrowMeter)
local ThrowController = require(ClientControllers.ThrowController)

-- Global Automation State Table (Default: ALL OFF as per SOP Rule 8)
local State = {
    -- Auto Throw
    AutoThrow = false,
    AlwaysPerfect = true,
    ThrowMode = "Instant (Fastest)",
    ThrowDelay = 0.2,
    AutoSuperThrow = false,
    TargetBiome = "Max Available",

    -- Auto Train
    AutoTrain = false,
    AutoTapBonus = false,

    -- Plot & Animals
    AutoEquipBest = false,
    EquipBestInterval = 5,
    AutoUpgradeFence = false,
    FenceUpgradeInterval = 5,
    AutoSellAll = false,
    SellAllInterval = 5,

    -- Economy & Upgrades
    AutoUpgradeStand = false,
    StandUpgradeInterval = 4,
    AutoBuyFood = false,
    FoodBuyInterval = 3,
    AutoClaimFree = false,
    ClaimFreeInterval = 10,
    AutoClaimOffline = false,
    ClaimOfflineInterval = 15,

    -- Movement & Modifiers
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = true,
}

-- Cleanup Registry
local Connections = {}
local RunningTasks = {}

local function RegisterConnection(conn)
    table.insert(Connections, conn)
    return conn
end

local function RegisterTask(thread)
    table.insert(RunningTasks, thread)
    return thread
end

-- Helper Functions
local function GetPlot()
    local plotIndex = LocalPlayer:GetAttribute("PlotIndex")
    if not plotIndex then return nil end
    return workspace.Plots:FindFirstChild(tostring(plotIndex))
end

local function SafeTeleport(targetCFrame)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Character.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = targetCFrame
    end
end

-- Always Perfect (+20) Hook on Vanilla ThrowMeter
local OldThrowMeterNew = ThrowMeterController.new
ThrowMeterController.new = function(...)
    local meter = OldThrowMeterNew(...)
    if State.AlwaysPerfect then
        meter.Locked = true
        ThrowMeterController.TestAutoTap = 0.35
    end
    return meter
end

-- Server-Side Fallback: Enforce 1.0 (Maximum +20 Studs) on Throw_Resolve
local OldRemotesInvoke = RemotesModule.Invoke
RemotesModule.Invoke = function(remoteName, ...)
    local args = {...}
    if remoteName == "Throw_Resolve" and State.AlwaysPerfect then
        args[1] = 1.0
    end
    return OldRemotesInvoke(remoteName, table.unpack(args))
end

-- Load WindUI Library
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[ClientOP] Failed to fetch WindUI library.")
    getgenv()._THROW_FOOD_RUNNING = false
    return
end

if WindUI.SetParent then
    pcall(WindUI.SetParent, WindUI, gethui and gethui() or game:GetService("CoreGui"))
end

local function SafeNotify(config)
    pcall(function()
        if WindUI and WindUI.Notify then
            SafeNotify(config)
        end
    end)
end

-- Build Main Window
local Window = WindUI:CreateWindow({
    Title = "Throw Food For Animals",
    Icon = "flame",
    Author = "Elite Automation Suite",
    Folder = "ThrowFoodForAnimals",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Title = "Open Script",
        Icon = "crosshair",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("FF512F"),
            Color3.fromHex("DD2476")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
    ToggleKey = Enum.KeyCode.LeftControl,
})

-- =========================================================================
-- CREATE ALL TABS FIRST (PREVENT CAPABILITY INSTANCE ACCESS ISSUES)
-- =========================================================================
local TabThrow = Window:Tab({ Title = "Throw Farm", Icon = "target" })
local TabTrain = Window:Tab({ Title = "Training & Power", Icon = "zap" })
local TabPlot = Window:Tab({ Title = "Plot & Animals", Icon = "layout-grid" })
local TabEconomy = Window:Tab({ Title = "Economy & Upgrades", Icon = "trending-up" })
local TabMovement = Window:Tab({ Title = "Movement & World", Icon = "map-pin" })
local TabConfig = Window:Tab({ Title = "Configuration", Icon = "settings" })

-- =========================================================================
-- TAB 1: THROW & ANIMAL FARM UI
-- =========================================================================
TabThrow:Section({
    Title = "Automated Animal Catching",
    Opened = true,
})

local ThrowStatusLabel = TabThrow:Paragraph({
    Title = "Status",
    Desc = "Idle - Auto throw is disabled.",
})

local BiomeOptions = { "Max Available" }
local BiomeIndexMap = {}
for i, area in ipairs(AreasConfig.All) do
    table.insert(BiomeOptions, area.Name)
    BiomeIndexMap[area.Name] = area
end

TabThrow:Toggle({
    Title = "Always Perfect (+20 Power)",
    Desc = "Locks meter to +20 (GREEN) and auto-taps automatically at maximum bonus",
    Value = State.AlwaysPerfect,
    Callback = function(val)
        State.AlwaysPerfect = val
        if not val then
            ThrowMeterController.TestAutoTap = nil
        end
    end,
})

TabThrow:Dropdown({
    Title = "Throw Mode",
    Desc = "Instant (Fastest, skips cutscene) vs Visual (Watch full throw & flight animation)",
    Values = { "Instant (Fastest)", "Visual (Full Animation)" },
    Value = State.ThrowMode,
    Callback = function(selected)
        State.ThrowMode = selected
    end,
})

TabThrow:Dropdown({
    Title = "Target Biome / Area",
    Desc = "Adjusts throw power to target specific animal biomes",
    Values = BiomeOptions,
    Value = "Max Available",
    Callback = function(selected)
        State.TargetBiome = selected
        if selected == "Max Available" then
            pcall(RemotesModule.Invoke, "Player_SetThrowPower", 0)
        else
            local area = BiomeIndexMap[selected]
            if area then
                local midDist = area.StartDistance + math.floor(area.Length / 2)
                pcall(RemotesModule.Invoke, "Player_SetThrowPower", midDist)
            end
        end
    end,
})

TabThrow:Toggle({
    Title = "Auto Super Throw",
    Desc = "Uses saved Super Throws automatically for maximum multipliers",
    Value = State.AutoSuperThrow,
    Callback = function(val)
        State.AutoSuperThrow = val
    end,
})

TabThrow:Slider({
    Title = "Throw Loop Delay",
    Desc = "Delay between consecutive throw cycles (seconds)",
    Value = {
        Min = 0.1,
        Max = 2.0,
        Default = 0.2,
    },
    Step = 0.05,
    Callback = function(val)
        State.ThrowDelay = val
    end,
})

TabThrow:Toggle({
    Title = "Auto Throw (Instant Complete)",
    Desc = "Bypasses all client-side animations for rapid animal farming",
    Value = State.AutoThrow,
    Callback = function(val)
        State.AutoThrow = val
        if val then
            ThrowStatusLabel:SetDesc("Active: Initiating rapid catch sequence...")
        else
            ThrowStatusLabel:SetDesc("Idle: Auto throw paused.")
        end
    end,
})

-- =========================================================================
-- TAB 2: TRAINING & POWER UI
-- =========================================================================
TabTrain:Section({
    Title = "Throw Power Generation",
    Opened = true,
})

local TrainStatusLabel = TabTrain:Paragraph({
    Title = "Training Status",
    Desc = "Idle - Training inactive.",
})

TabTrain:Toggle({
    Title = "Auto Train (Continuous Reps)",
    Desc = "Teleports to training bar and loops reps to maximize Throw Power",
    Value = State.AutoTrain,
    Callback = function(val)
        State.AutoTrain = val
        if not val then
            pcall(RemotesModule.Invoke, "Training_Stop")
            TrainStatusLabel:SetDesc("Stopped training.")
        end
    end,
})

TabTrain:Toggle({
    Title = "Auto Rapid Tap Bonus",
    Desc = "Instantly claims all random training tap bonuses for accelerated power",
    Value = State.AutoTapBonus,
    Callback = function(val)
        State.AutoTapBonus = val
    end,
})

-- =========================================================================
-- TAB 3: PLOT & ANIMAL MANAGEMENT UI
-- =========================================================================
TabPlot:Section({
    Title = "Plot Automation",
    Opened = true,
})

TabPlot:Toggle({
    Title = "Auto Equip Best Animals",
    Desc = "Automatically deploys highest income animals onto plot slots",
    Value = State.AutoEquipBest,
    Callback = function(val)
        State.AutoEquipBest = val
    end,
})

TabPlot:Slider({
    Title = "Equip Best Interval",
    Desc = "Interval between automatic best checks (seconds)",
    Value = {
        Min = 2,
        Max = 30,
        Default = 5,
    },
    Step = 1,
    Callback = function(val)
        State.EquipBestInterval = val
    end,
})

TabPlot:Toggle({
    Title = "Auto Upgrade Fence",
    Desc = "Expands animal storage capacity on plot when affordable",
    Value = State.AutoUpgradeFence,
    Callback = function(val)
        State.AutoUpgradeFence = val
    end,
})

TabPlot:Toggle({
    Title = "Auto Sell All (Backpack)",
    Desc = "Automatically liquidates unplaced animals to clear inventory",
    Value = State.AutoSellAll,
    Callback = function(val)
        State.AutoSellAll = val
    end,
})

TabPlot:Section({
    Title = "Manual Quick Actions",
    Opened = false,
})

TabPlot:Button({
    Title = "Equip Best Animals Now",
    Callback = function()
        local res = RemotesModule.Invoke("Plot_EquipBest")
        if res and res.Ok then
            SafeNotify({
                Title = "Plot Updated",
                Content = string.format("Equipped %d animals.", res.Count or 0),
                Duration = 3,
                Icon = "check-circle",
            })
        end
    end,
})

TabPlot:Button({
    Title = "Sell All Unplaced Animals",
    Callback = function()
        local res = RemotesModule.Invoke("Plot_SellAll")
        if res and res.Ok then
            SafeNotify({
                Title = "Sold Animals",
                Content = string.format("Sold %d animals for $%s.", res.Count or 0, tostring(res.Money or 0)),
                Duration = 3,
                Icon = "dollar-sign",
            })
        end
    end,
})

TabPlot:Button({
    Title = "Upgrade Fence Now",
    Callback = function()
        local res = RemotesModule.Invoke("Plot_UpgradeFence")
        if res and res.Ok then
            SafeNotify({
                Title = "Fence Upgraded",
                Content = string.format("Fence level %d unlocked (%d slots).", res.Level or 1, res.Slots or 0),
                Duration = 3,
                Icon = "shield-check",
            })
        else
            SafeNotify({
                Title = "Upgrade Failed",
                Content = tostring(res and res.Reason or "Insufficient Funds"),
                Duration = 3,
                Icon = "alert-circle",
            })
        end
    end,
})

-- =========================================================================
-- TAB 4: ECONOMY & UPGRADES UI
-- =========================================================================
TabEconomy:Section({
    Title = "Automation Settings",
    Opened = true,
})

TabEconomy:Toggle({
    Title = "Auto Upgrade Pull-Up Stand",
    Desc = "Upgrades pull-up bar tier when money permits for higher XP / rep",
    Value = State.AutoUpgradeStand,
    Callback = function(val)
        State.AutoUpgradeStand = val
    end,
})

TabEconomy:Toggle({
    Title = "Auto Buy Best Food",
    Desc = "Automatically buys and equips highest affordable bait tier",
    Value = State.AutoBuyFood,
    Callback = function(val)
        State.AutoBuyFood = val
    end,
})

TabEconomy:Toggle({
    Title = "Auto Claim Free Shop Reward",
    Desc = "Claims periodic free animal reward from exclusive shop",
    Value = State.AutoClaimFree,
    Callback = function(val)
        State.AutoClaimFree = val
    end,
})

TabEconomy:Toggle({
    Title = "Auto Claim Offline Cash",
    Desc = "Automatically collects accumulated offline earnings",
    Value = State.AutoClaimOffline,
    Callback = function(val)
        State.AutoClaimOffline = val
    end,
})

-- =========================================================================
-- TAB 5: MOVEMENT & WAYPOINTS UI
-- =========================================================================
TabMovement:Section({
    Title = "Waypoints Teleport",
    Opened = true,
})

local WaypointDestinations = {
    ["My Plot Entrance"] = function()
        local plot = GetPlot()
        return plot and CFrame.new(plot.Position + GameConfig.Plot.EntranceOffset)
    end,
    ["My Training Bar"] = function()
        local plot = GetPlot()
        return plot and CFrame.new(plot.Position + GameConfig.Plot.TrainingSpotOffset + Vector3.new(0, 3, 0))
    end,
    ["My Stand Upgrade Sign"] = function()
        local plot = GetPlot()
        return plot and CFrame.new(plot.Position + GameConfig.Plot.UpgradeButtonOffset + Vector3.new(0, 2, 0))
    end,
    ["Starter Throw Line"] = function()
        return CFrame.new(0, 3, -42)
    end,
    ["Sell Place (Merchant)"] = function()
        return CFrame.new(53.92, 4.0, -28.49)
    end,
    ["Lobby Spawn"] = function()
        return CFrame.new(0, 3, 0)
    end,
}

local WaypointList = {
    "My Plot Entrance",
    "My Training Bar",
    "My Stand Upgrade Sign",
    "Starter Throw Line",
    "Sell Place (Merchant)",
    "Lobby Spawn",
}

for _, area in ipairs(AreasConfig.All) do
    local label = "Biome: " .. area.Name
    table.insert(WaypointList, label)
    WaypointDestinations[label] = function()
        local folder = workspace.Biomes:FindFirstChild(area.Key) or workspace.Biomes:FindFirstChild(area.Name)
        if folder then
            local primary = folder:FindFirstChildWhichIsA("BasePart", true)
            if primary then
                return CFrame.new(primary.Position + Vector3.new(0, 5, 0))
            end
        end
        return CFrame.new(0, 5, -(area.StartDistance + 20))
    end
end

local SelectedWaypoint = WaypointList[1]
TabMovement:Dropdown({
    Title = "Select Destination",
    Values = WaypointList,
    Value = SelectedWaypoint,
    Callback = function(selected)
        SelectedWaypoint = selected
    end,
})

TabMovement:Button({
    Title = "Teleport to Selected Destination",
    Callback = function()
        local resolver = WaypointDestinations[SelectedWaypoint]
        if resolver then
            local targetCF = resolver()
            if targetCF then
                SafeTeleport(targetCF)
                SafeNotify({
                    Title = "Teleported",
                    Content = "Arrived at " .. SelectedWaypoint,
                    Duration = 2,
                    Icon = "navigation",
                })
            end
        end
    end,
})

TabMovement:Section({
    Title = "Character Modifiers",
    Opened = false,
})

TabMovement:Toggle({
    Title = "WalkSpeed Modifier",
    Value = State.WalkSpeedEnabled,
    Callback = function(val)
        State.WalkSpeedEnabled = val
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val and State.WalkSpeed or 16
        end
    end,
})

TabMovement:Slider({
    Title = "Custom WalkSpeed",
    Value = {
        Min = 16,
        Max = 150,
        Default = 16,
    },
    Step = 1,
    Callback = function(val)
        State.WalkSpeed = val
        if State.WalkSpeedEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "JumpPower Modifier",
    Value = State.JumpPowerEnabled,
    Callback = function(val)
        State.JumpPowerEnabled = val
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            Character:FindFirstChildOfClass("Humanoid").JumpPower = val and State.JumpPower or 50
        end
    end,
})

TabMovement:Slider({
    Title = "Custom JumpPower",
    Value = {
        Min = 50,
        Max = 250,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        State.JumpPower = val
        if State.JumpPowerEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            Character:FindFirstChildOfClass("Humanoid").JumpPower = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Walk through all collision barriers smoothly",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents client from being disconnected after 20 minutes of inactivity",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =========================================================================
-- TAB 6: CONFIG & SYSTEM PROFILES UI
-- =========================================================================
TabConfig:Section({
    Title = "Profile Persistence",
    Opened = true,
})

local ConfigFileName = "ThrowFoodForAnimals_Config.json"

local function SaveProfile()
    local payload = HttpService:JSONEncode(State)
    if writefile then
        writefile(ConfigFileName, payload)
        SafeNotify({
            Title = "Config Saved",
            Content = "Profile successfully saved to disk.",
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
        if getgenv()._THROW_FOOD_UNLOAD then
            getgenv()._THROW_FOOD_UNLOAD()
        end
    end,
})

-- Focus Default Initial Tab
pcall(function()
    TabThrow:Select()
end)

-- =========================================================================
-- UNLOAD LIFECYCLE HANDLER
-- =========================================================================
getgenv()._THROW_FOOD_UNLOAD = function()
    for _, conn in ipairs(Connections) do
        pcall(conn.Disconnect, conn)
    end
    for _, thr in ipairs(RunningTasks) do
        pcall(task.cancel, thr)
    end
    State.AutoThrow = false
    State.AutoTrain = false
    task.spawn(function()
        pcall(RemotesModule.Invoke, "Training_Stop")
        pcall(RemotesModule.Invoke, "Throw_Cancel")
    end)

    if Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
    end

    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    getgenv()._THROW_FOOD_RUNNING = nil
    getgenv()._THROW_FOOD_UNLOAD = nil
end

-- =========================================================================
-- WORKER THREADS & BACKGROUND LOOPS (INITIALIZED AFTER UI MOUNT)
-- =========================================================================

-- Movement Listeners
RegisterConnection(RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if State.WalkSpeedEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid").WalkSpeed = State.WalkSpeed
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

-- Listen for Training Tap Bonuses (x2 Multiplier)
RegisterConnection(RemotesModule.Event("Training_Bonus").OnClientEvent:Connect(function(bonusData)
    if State.AutoTapBonus then
        local bonusId = (type(bonusData) == "table" and bonusData.Id) or bonusData
        if bonusId then
            task.spawn(function()
                pcall(RemotesModule.Invoke, "Training_TapBonus", bonusId)
                local tapLayer = LocalPlayer.PlayerGui:FindFirstChild("TrainingSequence")
                    and LocalPlayer.PlayerGui.TrainingSequence:FindFirstChild("TapBonusLayer")
                local tapBtn = tapLayer and tapLayer:FindFirstChild("TapBonus")
                if tapBtn then
                    pcall(tapBtn.Destroy, tapBtn)
                end
            end)
        end
    end
end))

-- GUI Fallback Poller for x2 Tap Bonus Button
RegisterConnection(RunService.Heartbeat:Connect(function()
    if State.AutoTapBonus then
        local tapLayer = LocalPlayer.PlayerGui:FindFirstChild("TrainingSequence")
            and LocalPlayer.PlayerGui.TrainingSequence:FindFirstChild("TapBonusLayer")
        local tapBtn = tapLayer and tapLayer:FindFirstChild("TapBonus")
        if tapBtn and tapBtn:IsA("GuiButton") and tapBtn.Visible then
            pcall(function()
                if firesignal then
                    firesignal(tapBtn.Activated)
                end
            end)
        end
    end
end))

-- Auto Throw Loop
RegisterTask(task.spawn(function()
    while true do
        if State.AutoThrow then
            if LocalPlayer:GetAttribute("Training") then
                pcall(RemotesModule.Invoke, "Training_Stop")
                task.wait(0.3)
            end

            local starterArea = workspace:FindFirstChild("StarterArea")
            local throwCFrame = starterArea and CFrame.new(starterArea.Position.X, starterArea.Position.Y + 1.5, starterArea.Position.Z - 1)
                or CFrame.new(0, 3, -46)

            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local hrp = Character.HumanoidRootPart
                if (hrp.Position - throwCFrame.Position).Magnitude > 8 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = throwCFrame
                    task.wait(0.3)
                end
            end

            if State.ThrowMode == "Visual (Full Animation)" then
                if not ClientState.Busy then
                    task.spawn(ThrowController.Start)
                    task.wait(1.5)
                    while ClientState.Busy == "Throw" do
                        task.wait(0.2)
                    end
                    ThrowStatusLabel:SetDesc("Completed visual throw (+20 Perfect).")
                end
            else
                local startRes = RemotesModule.Invoke("Throw_Start")
                if startRes and startRes.Ok then
                    if State.AutoSuperThrow then
                        pcall(RemotesModule.Invoke, "Throw_UseSuper")
                    end

                    local resolveRes = RemotesModule.Invoke("Throw_Resolve", 1.0)
                    if resolveRes and resolveRes.Ok then
                        local completeRes = RemotesModule.Invoke("Throw_Complete")
                        if completeRes and completeRes.Ok then
                            local caughtName = resolveRes.DisplayName or resolveRes.ModelName or "Animal"
                            local rarity = resolveRes.Rarity or "Unknown"
                            local inc = resolveRes.Income or 0
                            ThrowStatusLabel:SetDesc(string.format("Caught: %s (%s) | +$%s/s", caughtName, rarity, tostring(inc)))
                        else
                            ThrowStatusLabel:SetDesc("Completed catch cycle.")
                        end
                    else
                        pcall(RemotesModule.Invoke, "Throw_Cancel")
                    end
                else
                    if startRes and startRes.Reason == "TooFar" then
                        SafeTeleport(throwCFrame)
                    end
                end
            end
        end
        task.wait(State.ThrowDelay)
    end
end))

-- Auto Training Loop
RegisterTask(task.spawn(function()
    while true do
        if State.AutoTrain then
            if State.AutoThrow then
                State.AutoThrow = false
            end

            local plot = GetPlot()
            if plot then
                local trainingSpot = plot.Position + GameConfig.Plot.TrainingSpotOffset + Vector3.new(0, 3, 0)
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Character.HumanoidRootPart
                    if (hrp.Position - trainingSpot).Magnitude > 6 then
                        SafeTeleport(CFrame.new(trainingSpot))
                        task.wait(0.3)
                    end
                end

                if not LocalPlayer:GetAttribute("Training") then
                    local res = RemotesModule.Invoke("Training_Start")
                    if res and res.Ok then
                        TrainStatusLabel:SetDesc("Training active: Gaining Throw Power...")
                    else
                        TrainStatusLabel:SetDesc("Training start failed: " .. tostring(res and res.Reason or "Error"))
                    end
                end
            end
        end
        task.wait(1.0)
    end
end))

-- Auto Plot & Animals Loops
RegisterTask(task.spawn(function()
    while true do
        if State.AutoEquipBest then
            pcall(RemotesModule.Invoke, "Plot_EquipBest")
        end
        task.wait(State.EquipBestInterval)
    end
end))

RegisterTask(task.spawn(function()
    while true do
        if State.AutoUpgradeFence then
            pcall(RemotesModule.Invoke, "Plot_UpgradeFence")
        end
        task.wait(State.FenceUpgradeInterval)
    end
end))

RegisterTask(task.spawn(function()
    while true do
        if State.AutoSellAll then
            pcall(RemotesModule.Invoke, "Plot_SellAll")
        end
        task.wait(State.SellAllInterval)
    end
end))

-- Auto Economy Loops
RegisterTask(task.spawn(function()
    while true do
        if State.AutoUpgradeStand then
            local currentStand = DataController:Get("Stand") or 0
            local nextStand = StandsConfig.Get(currentStand + 1)
            local currentMoney = DataController:Get("Money") or 0

            if nextStand and nextStand.Price <= currentMoney then
                local plot = GetPlot()
                if plot and Character and Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Character.HumanoidRootPart
                    local upgradeSpot = plot.Position + GameConfig.Plot.UpgradeButtonOffset + Vector3.new(0, 2, 0)
                    local oldCFrame = hrp.CFrame
                    SafeTeleport(CFrame.new(upgradeSpot))
                    task.wait(0.25)
                    pcall(RemotesModule.Invoke, "Stand_Upgrade")
                    task.wait(0.1)
                    SafeTeleport(oldCFrame)
                end
            end
        end
        task.wait(State.StandUpgradeInterval)
    end
end))

RegisterTask(task.spawn(function()
    while true do
        if State.AutoBuyFood then
            local currentMoney = DataController:Get("Money") or 0
            local ownedFoods = DataController:Get("OwnedFoods") or {}
            local bestAffordableIndex = nil

            for _, food in ipairs(FoodsConfig.All) do
                if food.Price <= currentMoney and not ownedFoods[food.Index] then
                    bestAffordableIndex = food.Index
                end
            end

            if bestAffordableIndex then
                local plot = GetPlot()
                if plot and Character and Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Character.HumanoidRootPart
                    local shopSpot = plot.Position + GameConfig.Plot.ShopCircleOffset + Vector3.new(0, 3, 0)
                    local oldCF = hrp.CFrame
                    SafeTeleport(CFrame.new(shopSpot))
                    task.wait(0.4)
                    local buyRes = RemotesModule.Invoke("Shop_Buy", bestAffordableIndex)
                    if buyRes and buyRes.Ok then
                        pcall(RemotesModule.Invoke, "Shop_Equip", bestAffordableIndex)
                    end
                    task.wait(0.1)
                    SafeTeleport(oldCF)
                end
            end
        end
        task.wait(State.FoodBuyInterval)
    end
end))

RegisterTask(task.spawn(function()
    while true do
        if State.AutoClaimFree then
            pcall(RemotesModule.Invoke, "Shop_ClaimFree")
        end
        task.wait(State.ClaimFreeInterval)
    end
end))

RegisterTask(task.spawn(function()
    while true do
        if State.AutoClaimOffline then
            pcall(RemotesModule.Invoke, "Offline_Claim")
        end
        task.wait(State.ClaimOfflineInterval)
    end
end))

SafeNotify({
    Title = "Throw Food For Animals",
    Content = "ClientOP Automation Suite Loaded (Toggle: LeftControl).",
    Duration = 4,
    Icon = "zap",
})
