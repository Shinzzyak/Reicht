-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    XLUNA HUB â [ð¹] SHOOT ARROWS FOR ANIMALS!
    Author: By XLunaHUB
    Universal Protocol: Real MCP Architecture
    Framework: WindUI
    All Defaults: OFF (Manual Toggle Standard)
    ========================================================================
]]

-- Lifecycle Cleanup & Teardown Guard
if _G.XLUNA_LOADED and type(_G.XLUNA_UNLOAD) == "function" then
    pcall(_G.XLUNA_UNLOAD)
end
_G.XLUNA_LOADED = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Clean up any previous WindUI / XLuna instances from CoreGui / RobloxGui / gethui
local function cleanPreviousWindUI()
    local hui = (gethui and gethui()) or CoreGui
    pcall(function()
        for _, ch in ipairs(hui:GetChildren()) do
            if ch.Name:find("WindUI") or ch.Name:find("XLuna") then
                pcall(function() ch:Destroy() end)
            end
        end
    end)
    local rGui = CoreGui:FindFirstChild("RobloxGui")
    if rGui then
        pcall(function()
            for _, ch in ipairs(rGui:GetChildren()) do
                if ch.Name:find("WindUI") or ch.Name:find("XLuna") then
                    pcall(function() ch:Destroy() end)
                end
            end
        end)
    end
end
cleanPreviousWindUI()

-- Remotes Topology
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShotRemotes = Remotes:WaitForChild("Shot")
local TrainingRemotes = Remotes:WaitForChild("Training")
local PlotRemotes = Remotes:WaitForChild("Plot")
local ShopRemotes = Remotes:WaitForChild("Shop")
local RewardsRemotes = Remotes:WaitForChild("Rewards")
local OfflineRemotes = Remotes:WaitForChild("Offline")
local SecretEggRemotes = Remotes:WaitForChild("SecretEgg")
local AdminAbuseRemotes = Remotes:WaitForChild("AdminAbuse")

-- Client Modules
local DataController = require(LocalPlayer.PlayerScripts.Client.DataController)
local Shooter = require(LocalPlayer.PlayerScripts.Client.Shooter)
local TrainingUI = require(LocalPlayer.PlayerScripts.Client.TrainingUI)
local Configs = ReplicatedStorage.Shared.Configs
local BowsConfig = require(Configs.Bows)
local StandsConfig = require(Configs.Stands)
local AreasConfig = require(Configs.Areas)
local RaritiesConfig = require(Configs.Rarities)
local PlotConfig = require(Configs.Plot)

-- Static World Locations
local LOCATIONS = {
    ShootingLine = Vector3.new(-38, 5.98, -36),
    LocalBowShop = Vector3.new(-47, 4.5, 7.19),
    PlotUpgradeSign = Vector3.new(-72.8, 4.5, 15)
}

-- Resolve Player Plot
local function getMyPlot()
    local plotIndex = LocalPlayer:GetAttribute("PlotIndex")
    local plots = workspace:FindFirstChild("Plots")
    if plotIndex and plots then
        return plots:FindFirstChild(tostring(plotIndex))
    end
    return nil
end

local function getMyBenchRoot()
    local plot = getMyPlot()
    if plot then
        local training = plot:FindFirstChild("Training")
        local benchStation = training and training:FindFirstChild("BenchStation")
        if benchStation and benchStation:FindFirstChild("Root") then
            return benchStation.Root
        end
    end
    return nil
end

-- Teleport Helper (Physics-safe)
local isTeleporting = false

local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e12 then
        return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then
        return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then
        return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.2fK", n / 1e3)
    else
        return tostring(math.floor(n))
    end
end

local function safeTeleport(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.AssemblyLinearVelocity = Vector3.zero
    char:PivotTo(CFrame.new(targetPos))
    return true
end

-- ============================================================================
-- GLOBAL SCRIPT SETTINGS (ALL DEFAULT TO FALSE/OFF AS PER RULE 8)
-- ============================================================================
local Settings = {
    -- Auto Shoot
    AutoShoot = false,
    AlwaysMaxPower = false,
    ShotDelay = 0.25,
    UseLuckyShot = false,
    MeterPower = 1.0,

    -- Auto Training
    AutoTraining = false,
    AutoTapBonus = false,
    AutoUpgradeBench = false,

    -- Plot & Animals
    AutoEquipBest = false,
    AutoSellAll = false,
    AutoUpgradeFence = false,

    -- Bows
    AutoBuyBow = false,
    AutoEquipHighestBow = false,

    -- Rewards
    AutoDailyClaim = false,
    AutoIndexClaim = false,
    AutoPlaytimeGifts = false,
    AutoFreeSpin = false,
    AutoOfflineClaim = false,
    AutoSecretEgg = false,
    AutoVacuumDrops = false,

    -- Movement / Player
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    JumpPowerEnabled = false,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    AntiAfk = false,

    -- Teleport Area Selection
    SelectedAreaIndex = 1
}
_G.XLUNA_SETTINGS = Settings

-- Master Connection Tracker for Lifecycle Teardown
local ActiveConnections = {}
local function trackConnection(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

-- ============================================================================
-- AUTOMATION COROUTINES & ENGINES
-- ============================================================================

-- 1. Auto Shoot Engine
task.spawn(function()
    while _G.XLUNA_LOADED do
        if Settings.AutoShoot then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                while isTeleporting do
                    task.wait(0.1)
                end

                -- Check position relative to shooting line
                local lineSpot = Shooter.LineSpot()
                local linePos = lineSpot and lineSpot.Position or LOCATIONS.ShootingLine
                local dist = (hrp.Position - linePos).Magnitude

                if dist > 8 then
                    safeTeleport(linePos)
                    task.wait(0.15)
                end

                -- Signal Meter Start
                pcall(function()
                    ShotRemotes.MeterStarted:FireServer()
                end)

                -- Exact half-period synchronization for 100% PERFECT meter calculation
                if Settings.AlwaysMaxPower then
                    task.wait(1.072)
                end

                while isTeleporting do
                    task.wait(0.1)
                end

                -- Invoke Shot Start
                local powerVal = Settings.AlwaysMaxPower and 1.0 or math.clamp(Settings.MeterPower, 0.1, 1.0)
                local luckyVal = Settings.UseLuckyShot == true

                local success, result = pcall(function()
                    return ShotRemotes.Start:InvokeServer(powerVal, luckyVal)
                end)

                if success and type(result) == "table" and result.Ok then
                    -- Instant complete & skip trajectory lag
                    pcall(function()
                        ShotRemotes.Complete:InvokeServer({Skipped = true})
                    end)
                end
            end
            task.wait(math.max(0.05, Settings.ShotDelay))
        else
            task.wait(0.3)
        end
    end
end)

-- 2. Auto Training Engine
task.spawn(function()
    while _G.XLUNA_LOADED do
        if Settings.AutoTraining and not Settings.AutoShoot then
            local benchRoot = getMyBenchRoot()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if benchRoot and hrp then
                local dist = (hrp.Position - benchRoot.Position).Magnitude
                if dist > 6 then
                    safeTeleport(benchRoot.Position + Vector3.new(0, 3, 0))
                    task.wait(0.2)
                end

                if not TrainingUI.IsTraining() then
                    pcall(function()
                        TrainingRemotes.Start:InvokeServer()
                    end)
                end
            end
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end)

-- Internal TrainingUI Upvalue Bindings for Guaranteed Tap Bonus
local claimOldestBonus = nil
pcall(function()
    claimOldestBonus = debug.getupvalue(TrainingUI.Init, 37)
end)

-- 3. Instant Tap Bonus Multi-Layered Engine (Guaranteed 2x XP Trigger)
-- Layer A: RemoteEvent Listener
trackConnection(TrainingRemotes.Bonus.OnClientEvent:Connect(function(bonusId)
    if Settings.AutoTapBonus then
        task.wait(0.02)
        if claimOldestBonus then
            pcall(claimOldestBonus)
        end
        if bonusId then
            pcall(function()
                TrainingRemotes.TapBonus:InvokeServer(bonusId)
            end)
        end
    end
end))

-- Layer B: GUI Frame ChildAdded Hook
task.spawn(function()
    local function watchBonusFrame(bonusFrame)
        if not bonusFrame then return end
        trackConnection(bonusFrame.ChildAdded:Connect(function(child)
            if Settings.AutoTapBonus and child.Name == "TapBonus" and child:IsA("GuiButton") then
                task.wait(0.02)
                if claimOldestBonus then
                    pcall(claimOldestBonus)
                end
                if firesignal then
                    pcall(function() firesignal(child.Activated) end)
                end
                if getconnections then
                    for _, conn in ipairs(getconnections(child.Activated)) do
                        pcall(function() conn:Fire() end)
                    end
                end
            end
        end))
    end

    local tg = LocalPlayer.PlayerGui:WaitForChild("TrainingGui", 10)
    local bonusFrame = tg and tg:WaitForChild("Bonus", 10)
    watchBonusFrame(bonusFrame)

    trackConnection(LocalPlayer.PlayerGui.ChildAdded:Connect(function(ch)
        if ch.Name == "TrainingGui" then
            local b = ch:WaitForChild("Bonus", 10)
            watchBonusFrame(b)
        end
    end))
end)

-- Layer C: High-Frequency Heartbeat Polling Fallback (Zero Miss Guarantee)
trackConnection(RunService.Heartbeat:Connect(function()
    if Settings.AutoTapBonus then
        -- Method 1: Internal Engine Claim
        if claimOldestBonus then
            pcall(claimOldestBonus)
        end

        -- Method 2: Physical GuiButton firesignal
        local tg = LocalPlayer.PlayerGui:FindFirstChild("TrainingGui")
        local bonusFrame = tg and tg:FindFirstChild("Bonus")
        if bonusFrame then
            for _, child in ipairs(bonusFrame:GetChildren()) do
                if child.Name == "TapBonus" and child:IsA("GuiButton") then
                    if firesignal then
                        pcall(function() firesignal(child.Activated) end)
                    end
                    if getconnections then
                        for _, conn in ipairs(getconnections(child.Activated)) do
                            pcall(function() conn:Fire() end)
                        end
                    end
                end
            end
        end
    end
end))

-- 4. Auto Bench Upgrade Engine
task.spawn(function()
    while _G.XLUNA_LOADED do
        if Settings.AutoUpgradeBench then
            local data = DataController.Data()
            local money = data and data.Money or 0
            local currentStand = data and data.Training and data.Training.Stand or 1
            local standsList = StandsConfig.All or StandsConfig.List or StandsConfig
            local nextStand = standsList[currentStand + 1]

            if nextStand and money >= (nextStand.Price or nextStand.Cost or 0) then
                local benchRoot = getMyBenchRoot()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if benchRoot and hrp then
                    isTeleporting = true
                    local prevCFrame = hrp.CFrame
                    safeTeleport(benchRoot.Position + Vector3.new(0, 3, 0))
                    task.wait(0.2)
                    local res = nil
                    pcall(function()
                        res = TrainingRemotes.Upgrade:InvokeServer()
                    end)
                    task.wait(0.2)
                    safeTeleport(prevCFrame.Position)
                    isTeleporting = false

                    if res and res.Ok then
                        pcall(function()
                            WindUI:Notify({
                                Title = "Bench Upgraded!",
                                Content = "Upgraded to [" .. tostring(currentStand + 1) .. "] " .. tostring(res.Name or nextStand.Name) .. "!",
                                Duration = 4,
                            })
                        end)
                    end
                    task.wait(1.5)
                end
            end
            task.wait(1.5)
        else
            task.wait(1.0)
        end
    end
end)

-- 5. Auto Plot & Pets Manager (Equip Best, Sell All, Upgrade Fence)
task.spawn(function()
    while _G.XLUNA_LOADED do
        -- Auto Equip Best
        if Settings.AutoEquipBest then
            pcall(function()
                PlotRemotes.EquipBest:InvokeServer()
            end)
        end

        -- Auto Sell All
        if Settings.AutoSellAll then
            pcall(function()
                PlotRemotes.SellAll:InvokeServer()
            end)
        end

        -- Auto Upgrade Fence (Seamless Teleport)
        if Settings.AutoUpgradeFence then
            local data = DataController.Data()
            local fenceLvl = data and data.FenceLevel or 0
            local money = data and data.Money or 0
            local nextUpgrade = PlotConfig and PlotConfig.Fence and PlotConfig.Fence.Upgrades and PlotConfig.Fence.Upgrades[fenceLvl + 1]

            if nextUpgrade and money >= (nextUpgrade.Price or 0) then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    isTeleporting = true
                    local prevCFrame = hrp.CFrame
                    safeTeleport(LOCATIONS.PlotUpgradeSign + Vector3.new(0, 3, 2))
                    task.wait(0.25)
                    local resFence = nil
                    pcall(function()
                        resFence = PlotRemotes.UpgradeFence:InvokeServer()
                    end)
                    task.wait(0.2)
                    safeTeleport(prevCFrame.Position)
                    isTeleporting = false

                    if resFence and resFence.Ok then
                        pcall(function()
                            WindUI:Notify({
                                Title = "Fence Upgraded!",
                                Content = "Upgraded to Level " .. tostring(fenceLvl + 1) .. " (" .. tostring(nextUpgrade.Slots or 0) .. " Slots)!",
                                Duration = 4,
                            })
                        end)
                    end
                    task.wait(2.0)
                end
            end
        end

        task.wait(3.0)
    end
end)

-- 6. Auto Bow Economy Engine
task.spawn(function()
    while _G.XLUNA_LOADED do
        if Settings.AutoBuyBow then
            local data = DataController.Data()
            local money = data and data.Money or 0
            local ownedBows = data and data.OwnedBows or {}
            local bowsList = BowsConfig.List or BowsConfig.All or BowsConfig

            -- Find next unowned bow
            local targetBowIndex = nil
            local targetBow = nil
            for i, bow in ipairs(bowsList) do
                if not ownedBows[tostring(i)] and not ownedBows[i] then
                    local price = bow.Price or bow.Cost or 0
                    if money >= price then
                        targetBowIndex = i
                        targetBow = bow
                    end
                    break
                end
            end

            if targetBowIndex and targetBow then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    isTeleporting = true
                    local prevCFrame = hrp.CFrame
                    safeTeleport(LOCATIONS.LocalBowShop)
                    task.wait(0.25)
                    local resBuy = nil
                    pcall(function()
                        resBuy = ShopRemotes.BuyBow:InvokeServer(targetBowIndex)
                    end)
                    task.wait(0.2)
                    pcall(function()
                        ShopRemotes.EquipBow:InvokeServer(targetBowIndex)
                    end)
                    task.wait(0.15)
                    safeTeleport(prevCFrame.Position)
                    isTeleporting = false

                    if resBuy and resBuy.Ok then
                        pcall(function()
                            WindUI:Notify({
                                Title = "Bow Purchased!",
                                Content = "Purchased & Equipped [" .. tostring(targetBowIndex) .. "] " .. tostring(targetBow.Name) .. "!",
                                Duration = 4,
                            })
                        end)
                    end
                    task.wait(2.0)
                end
            end
        end

        -- Auto Equip Highest Owned Bow
        if Settings.AutoEquipHighestBow then
            local data = DataController.Data()
            local ownedBows = data and data.OwnedBows or {}
            local currentBow = data and data.Bow or 1
            local highestOwned = 1

            for key, val in pairs(ownedBows) do
                if val == true then
                    local num = tonumber(key)
                    if num and num > highestOwned then
                        highestOwned = num
                    end
                end
            end

            if highestOwned > currentBow then
                pcall(function()
                    ShopRemotes.EquipBow:InvokeServer(highestOwned)
                end)
            end
        end

        task.wait(5.0)
    end
end)

-- 7. Auto Free Rewards Engine
task.spawn(function()
    while _G.XLUNA_LOADED do
        -- Daily Claim
        if Settings.AutoDailyClaim then
            pcall(function()
                RewardsRemotes.DailyClaim:InvokeServer()
            end)
        end

        -- Index Milestone Rewards
        if Settings.AutoIndexClaim then
            pcall(function()
                RewardsRemotes.IndexClaimAll:InvokeServer()
            end)
        end

        -- Playtime Gifts 1-12
        if Settings.AutoPlaytimeGifts then
            for i = 1, 12 do
                pcall(function()
                    RewardsRemotes.GiftClaim:InvokeServer(i)
                end)
            end
        end

        -- Fortune Spin
        if Settings.AutoFreeSpin then
            pcall(function()
                RewardsRemotes.SpinRequest:InvokeServer()
            end)
        end

        -- Offline Earnings
        if Settings.AutoOfflineClaim then
            pcall(function()
                OfflineRemotes.Claim:InvokeServer()
            end)
        end

        -- Secret OP Egg
        if Settings.AutoSecretEgg then
            local data = DataController.Data()
            local secretEgg = data and data.SecretEgg
            if secretEgg and (secretEgg.Left or 1) <= 0 then
                pcall(function()
                    SecretEggRemotes.Hatch:InvokeServer()
                end)
            end
        end

        task.wait(8.0)
    end
end)

-- 8. Auto Vacuum Admin Abuse Drops
task.spawn(function()
    local function processDrop(drop)
        if Settings.AutoVacuumDrops and drop and drop:IsA("BasePart") or drop:IsA("Model") then
            pcall(function()
                AdminAbuseRemotes.Pickup:FireServer(drop.Name)
            end)
        end
    end

    local dropsFolder = workspace:FindFirstChild("AdminAbuseDrops")
    if dropsFolder then
        trackConnection(dropsFolder.ChildAdded:Connect(processDrop))
        for _, drop in ipairs(dropsFolder:GetChildren()) do
            processDrop(drop)
        end
    end

    trackConnection(workspace.ChildAdded:Connect(function(ch)
        if ch.Name == "AdminAbuseDrops" and ch:IsA("Folder") then
            trackConnection(ch.ChildAdded:Connect(processDrop))
        end
    end))
end)

-- 9. Movement / Player Enforcers
trackConnection(RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip
    if Settings.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- WalkSpeed & JumpPower
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.WalkSpeedEnabled then
            hum.WalkSpeed = Settings.WalkSpeed
        end
        if Settings.JumpPowerEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPower
        end
    end
end))

-- Infinite Jump
trackConnection(UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- Anti-AFK
local antiAfkConn = LocalPlayer.Idled:Connect(function()
    if Settings.AntiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)
trackConnection(antiAfkConn)

-- ============================================================================
-- WINDUI INTERFACE INITIALIZATION
-- ============================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Shoot Arrows For Animals!",
    Icon = "rbxassetid://10723345518",
    Author = "By XLunaHUB",
    Folder = "XLuna_ShootArrows",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true
})

-- ============================================================================
-- FLOATING TOGGLE BUTTON (RULE 8 COMPLIANT)
-- ============================================================================
local function createFloatingButton()
    local targetParent = (gethui and gethui()) or CoreGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XLuna_FloatingToggle"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local floatBtn = Instance.new("ImageButton")
    floatBtn.Name = "ToggleBtn"
    floatBtn.Size = UDim2.fromOffset(48, 48)
    floatBtn.Position = UDim2.new(0, 20, 0.5, -24)
    floatBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    floatBtn.Image = "rbxassetid://10723345518"
    floatBtn.ImageColor3 = Color3.fromRGB(0, 210, 255)
    floatBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = floatBtn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(60, 68, 90)
    stroke.Parent = floatBtn

    -- Drag Logic for Floating Button
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle Window Click Action
    local isDebounced = false
    floatBtn.MouseButton1Click:Connect(function()
        if isDebounced then return end
        isDebounced = true
        if Window.Closed then
            Window:Open()
        else
            Window:Close()
        end
        task.wait(0.2)
        isDebounced = false
    end)

    screenGui.Parent = targetParent
    return screenGui
end
local FloatingGui = createFloatingButton()

-- LeftControl Keybind Toggle (With Strict Debounce Guard to Prevent Simultaneous Desync)
local keybindDebounce = false
trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        if keybindDebounce then return end
        keybindDebounce = true
        if Window.Closed then
            Window:Open()
        else
            Window:Close()
        end
        task.wait(0.25)
        keybindDebounce = false
    end
end))

-- ============================================================================
-- TABS & CONTROLS SETUP
-- ============================================================================

-- TAB 1: AUTO SHOOT
local TabShoot = Window:Tab({Title = "Auto Shoot", Icon = "rbxassetid://10709791437"})

TabShoot:Section({Title = "Archery Automation"})

TabShoot:Toggle({
    Title = "Auto Shoot (Instant Skip)",
    Desc = "Fast auto-fires arrows and instantly claims caught animals",
    Value = false,
    Callback = function(val)
        Settings.AutoShoot = val
    end
})

TabShoot:Toggle({
    Title = "Always Max Power (100% PERFECT)",
    Desc = "Syncs arrow draw timing with server physics to hit 100% PERFECT rating and 2x distance",
    Value = false,
    Callback = function(val)
        Settings.AlwaysMaxPower = val
    end
})

TabShoot:Slider({
    Title = "Shot Delay (Seconds)",
    Desc = "Delay interval between shots",
    Step = 0.05,
    Value = {Min = 0.05, Max = 1.0, Default = 0.25},
    Callback = function(val)
        Settings.ShotDelay = tonumber(val) or 0.25
    end
})

TabShoot:Toggle({
    Title = "Use Lucky Shot",
    Desc = "Automatically consumes Lucky Shot charges for 100x rare catch chances",
    Value = false,
    Callback = function(val)
        Settings.UseLuckyShot = val
    end
})

TabShoot:Slider({
    Title = "Meter Power %",
    Desc = "Arrow draw power accuracy (100% = Maximum Distance & Perfect Rating)",
    Step = 5,
    Value = {Min = 10, Max = 100, Default = 100},
    Callback = function(val)
        Settings.MeterPower = (tonumber(val) or 100) / 100
    end
})

TabShoot:Button({
    Title = "Teleport to Shooting Line",
    Desc = "Instantly warps character directly to the active shooting lane",
    Callback = function()
        local lineSpot = Shooter.LineSpot()
        safeTeleport(lineSpot and lineSpot.Position or LOCATIONS.ShootingLine)
    end
})

-- TAB 2: AUTO TRAINING
local TabTraining = Window:Tab({Title = "Auto Training", Icon = "rbxassetid://10747372167"})

TabTraining:Section({Title = "Bench Press & XP Multipliers"})

local BenchStatusParagraph = TabTraining:Paragraph({
    Title = "Bench Press Status",
    Desc = "Calculating current bench progression..."
})

TabTraining:Toggle({
    Title = "Auto Bench Press Training",
    Desc = "Automatically trains strength at your plot bench press",
    Value = false,
    Callback = function(val)
        Settings.AutoTraining = val
    end
})

TabTraining:Toggle({
    Title = "Instant Auto Tap Bonus (2x XP)",
    Desc = "Instantly captures QTE bonus prompts with 0ms reaction delay for 2x XP",
    Value = false,
    Callback = function(val)
        Settings.AutoTapBonus = val
    end
})

TabTraining:Toggle({
    Title = "Auto Upgrade Bench",
    Desc = "Automatically warps and upgrades bench whenever affordable, then resumes training/shooting",
    Value = false,
    Callback = function(val)
        Settings.AutoUpgradeBench = val
    end
})

TabTraining:Button({
    Title = "Upgrade Bench Now",
    Desc = "Attempts to upgrade your bench immediately with real-time feedback",
    Callback = function()
        local data = DataController.Data()
        local money = data and data.Money or 0
        local currentStand = data and data.Training and data.Training.Stand or 1
        local standsList = StandsConfig.All or StandsConfig.List or StandsConfig
        local nextStand = standsList[currentStand + 1]

        if not nextStand then
            WindUI:Notify({
                Title = "Max Bench Reached",
                Content = "You have unlocked the highest bench tier!",
                Duration = 4,
            })
            return
        end

        local price = nextStand.Price or nextStand.Cost or 0
        if money < price then
            local missing = price - money
            WindUI:Notify({
                Title = "Insufficient Funds",
                Content = "Need $" .. formatNumber(price) .. " for [" .. tostring(currentStand + 1) .. "] " .. tostring(nextStand.Name) .. " | Short by $" .. formatNumber(missing),
                Duration = 4,
            })
            return
        end

        local benchRoot = getMyBenchRoot()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if benchRoot and hrp then
            isTeleporting = true
            local prevCFrame = hrp.CFrame
            safeTeleport(benchRoot.Position + Vector3.new(0, 3, 0))
            task.wait(0.2)
            local res = nil
            pcall(function()
                res = TrainingRemotes.Upgrade:InvokeServer()
            end)
            task.wait(0.2)
            safeTeleport(prevCFrame.Position)
            isTeleporting = false

            if res and res.Ok then
                WindUI:Notify({
                    Title = "Bench Upgraded!",
                    Content = "Successfully upgraded to [" .. tostring(currentStand + 1) .. "] " .. tostring(res.Name or nextStand.Name),
                    Duration = 4,
                })
            else
                WindUI:Notify({
                    Title = "Upgrade Failed",
                    Content = "Server rejected: " .. tostring(res and res.Reason or "Unknown"),
                    Duration = 4,
                })
            end
        end
    end
})

TabTraining:Button({
    Title = "Warp to My Bench Station",
    Desc = "Teleports directly to your plot bench press",
    Callback = function()
        local root = getMyBenchRoot()
        if root then
            safeTeleport(root.Position + Vector3.new(0, 3, 0))
        end
    end
})

-- TAB 3: PLOT & PETS
local TabPlot = Window:Tab({Title = "Plot & Pets", Icon = "rbxassetid://10709770560"})

TabPlot:Section({Title = "Plot Management & Animal Automation"})

local FenceStatusParagraph = TabPlot:Paragraph({
    Title = "Fence Capacity Status",
    Desc = "Calculating fence upgrade progression..."
})

TabPlot:Toggle({
    Title = "Auto Equip Best Animals",
    Desc = "Continuously keeps the highest income generating animals on plot pedestals",
    Value = false,
    Callback = function(val)
        Settings.AutoEquipBest = val
    end
})

TabPlot:Toggle({
    Title = "Auto Sell All Unplaced Animals",
    Desc = "Automatically sells unplaced and unlocked animals in inventory",
    Value = false,
    Callback = function(val)
        Settings.AutoSellAll = val
    end
})

TabPlot:Toggle({
    Title = "Auto Upgrade Fence (Plot Size)",
    Desc = "Automatically upgrades plot fence to expand pet capacity whenever affordable",
    Value = false,
    Callback = function(val)
        Settings.AutoUpgradeFence = val
    end
})

TabPlot:Button({
    Title = "Upgrade Fence Now",
    Desc = "Attempts to expand your fence immediately with real-time feedback",
    Callback = function()
        local data = DataController.Data()
        local fenceLvl = data and data.FenceLevel or 0
        local money = data and data.Money or 0
        local nextUpgrade = PlotConfig and PlotConfig.Fence and PlotConfig.Fence.Upgrades and PlotConfig.Fence.Upgrades[fenceLvl + 1]

        if not nextUpgrade then
            WindUI:Notify({
                Title = "Max Fence Level",
                Content = "Your plot fence is already at maximum capacity!",
                Duration = 4,
            })
            return
        end

        local price = nextUpgrade.Price or 0
        if money < price then
            local missing = price - money
            WindUI:Notify({
                Title = "Insufficient Funds",
                Content = "Need $" .. formatNumber(price) .. " for Level " .. tostring(fenceLvl + 1) .. " (" .. tostring(nextUpgrade.Slots or 0) .. " Slots) | Short by $" .. formatNumber(missing),
                Duration = 4,
            })
            return
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            isTeleporting = true
            local prevCFrame = hrp.CFrame
            safeTeleport(LOCATIONS.PlotUpgradeSign + Vector3.new(0, 3, 2))
            task.wait(0.25)
            local res = nil
            pcall(function()
                res = PlotRemotes.UpgradeFence:InvokeServer()
            end)
            task.wait(0.2)
            safeTeleport(prevCFrame.Position)
            isTeleporting = false

            if res and res.Ok then
                WindUI:Notify({
                    Title = "Fence Upgraded!",
                    Content = "Successfully upgraded fence to Level " .. tostring(fenceLvl + 1) .. " (" .. tostring(nextUpgrade.Slots or 0) .. " Slots)",
                    Duration = 4,
                })
            else
                WindUI:Notify({
                    Title = "Upgrade Failed",
                    Content = "Server rejected: " .. tostring(res and res.Reason or "Unknown"),
                    Duration = 4,
                })
            end
        end
    end
})

TabPlot:Button({
    Title = "Equip Best Animals Now",
    Desc = "Manually triggers an instant Best Animals placement",
    Callback = function()
        pcall(function()
            PlotRemotes.EquipBest:InvokeServer()
        end)
    end
})

TabPlot:Button({
    Title = "Sell All Animals Now",
    Desc = "Manually sells all unlocked animals not currently placed on pedestals",
    Callback = function()
        pcall(function()
            PlotRemotes.SellAll:InvokeServer()
        end)
    end
})

TabPlot:Button({
    Title = "Warp to My Plot",
    Desc = "Teleports character to the center of your plot",
    Callback = function()
        local plot = getMyPlot()
        if plot then
            safeTeleport(plot:GetPivot().Position + Vector3.new(0, 4, 0))
        end
    end
})

TabPlot:Button({
    Title = "Warp to Fence Upgrade Sign",
    Desc = "Teleports character directly in front of the fence upgrade sign",
    Callback = function()
        safeTeleport(LOCATIONS.PlotUpgradeSign + Vector3.new(0, 3, 2))
    end
})

-- TAB 4: BOWS & WEAPONS
local TabBows = Window:Tab({Title = "Bows & Weapons", Icon = "rbxassetid://10723345518"})

TabBows:Section({Title = "Bow Progression & Equipment"})

local BowStatusParagraph = TabBows:Paragraph({
    Title = "Bow Progression Status",
    Desc = "Calculating bow shop progression..."
})

TabBows:Toggle({
    Title = "Auto Buy Next Affordable Bow",
    Desc = "Automatically visits the bow shop and buys the next tier bow when funds permit",
    Value = false,
    Callback = function(val)
        Settings.AutoBuyBow = val
    end
})

TabBows:Toggle({
    Title = "Auto Equip Highest Owned Bow",
    Desc = "Always keeps the highest tier owned bow equipped",
    Value = false,
    Callback = function(val)
        Settings.AutoEquipHighestBow = val
    end
})

TabBows:Button({
    Title = "Buy Next Bow Now",
    Desc = "Attempts to buy and equip the next unowned bow with real-time feedback",
    Callback = function()
        local data = DataController.Data()
        local money = data and data.Money or 0
        local ownedBows = data and data.OwnedBows or {}
        local bowsList = BowsConfig.List or BowsConfig.All or BowsConfig

        local targetBowIndex = nil
        local targetBow = nil
        for i, bow in ipairs(bowsList) do
            if not ownedBows[tostring(i)] and not ownedBows[i] then
                targetBowIndex = i
                targetBow = bow
                break
            end
        end

        if not targetBowIndex or not targetBow then
            WindUI:Notify({
                Title = "All Bows Owned",
                Content = "You own every single bow available in the game!",
                Duration = 4,
            })
            return
        end

        local price = targetBow.Price or targetBow.Cost or 0
        if money < price then
            local missing = price - money
            WindUI:Notify({
                Title = "Insufficient Funds",
                Content = "Need $" .. formatNumber(price) .. " for [" .. tostring(targetBowIndex) .. "] " .. tostring(targetBow.Name) .. " | Short by $" .. formatNumber(missing),
                Duration = 4,
            })
            return
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            isTeleporting = true
            local prevCFrame = hrp.CFrame
            safeTeleport(LOCATIONS.LocalBowShop)
            task.wait(0.25)
            local res = nil
            pcall(function()
                res = ShopRemotes.BuyBow:InvokeServer(targetBowIndex)
            end)
            task.wait(0.2)
            pcall(function()
                ShopRemotes.EquipBow:InvokeServer(targetBowIndex)
            end)
            task.wait(0.15)
            safeTeleport(prevCFrame.Position)
            isTeleporting = false

            if res and res.Ok then
                WindUI:Notify({
                    Title = "Bow Purchased!",
                    Content = "Successfully bought and equipped [" .. tostring(targetBowIndex) .. "] " .. tostring(targetBow.Name),
                    Duration = 4,
                })
            else
                WindUI:Notify({
                    Title = "Purchase Failed",
                    Content = "Server rejected: " .. tostring(res and res.Reason or "Unknown"),
                    Duration = 4,
                })
            end
        end
    end
})

-- Build Bow Names List
local bowNames = {}
local bowsList = BowsConfig.List or BowsConfig.All or BowsConfig
for i, bow in ipairs(bowsList) do
    table.insert(bowNames, string.format("[%d] %s", i, bow.Name or ("Bow " .. i)))
end

TabBows:Dropdown({
    Title = "Equip Specific Bow",
    Desc = "Select and equip any bow you currently own",
    Values = bowNames,
    Value = bowNames[1],
    Callback = function(selection)
        local bowIndex = tonumber(selection:match("%[(%d+)%]"))
        if bowIndex then
            pcall(function()
                ShopRemotes.EquipBow:InvokeServer(bowIndex)
            end)
        end
    end
})

TabBows:Button({
    Title = "Warp to Bow Shop",
    Desc = "Teleports directly to the local Bow Shop merchant",
    Callback = function()
        safeTeleport(LOCATIONS.LocalBowShop)
    end
})

-- TAB 5: FREE REWARDS
local TabRewards = Window:Tab({Title = "Rewards & Gifts", Icon = "rbxassetid://10709798174"})

TabRewards:Section({Title = "Automated Free Claimers"})

TabRewards:Toggle({
    Title = "Auto Claim Daily Reward",
    Desc = "Automatically collects free daily login streaks",
    Value = false,
    Callback = function(val)
        Settings.AutoDailyClaim = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Index Milestones",
    Desc = "Automatically collects free cash rewards for newly discovered animals",
    Value = false,
    Callback = function(val)
        Settings.AutoIndexClaim = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Playtime Gifts (1-12)",
    Desc = "Continuously claims milestone playtime gift boxes",
    Value = false,
    Callback = function(val)
        Settings.AutoPlaytimeGifts = val
    end
})

TabRewards:Toggle({
    Title = "Auto Spin Fortune Wheel",
    Desc = "Automatically uses free wheel spins for lucky shots and bonuses",
    Value = false,
    Callback = function(val)
        Settings.AutoFreeSpin = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Offline Earnings",
    Desc = "Collects accumulated offline bonus funds",
    Value = false,
    Callback = function(val)
        Settings.AutoOfflineClaim = val
    end
})

TabRewards:Toggle({
    Title = "Auto Hatch Secret OP Egg",
    Desc = "Automatically opens your Secret OP Egg the exact instant the timer completes",
    Value = false,
    Callback = function(val)
        Settings.AutoSecretEgg = val
    end
})

TabRewards:Toggle({
    Title = "Auto Vacuum Admin Drops",
    Desc = "Instantly intercepts and claims all active admin abuse event drops in workspace",
    Value = false,
    Callback = function(val)
        Settings.AutoVacuumDrops = val
    end
})

TabRewards:Button({
    Title = "Claim All Free Rewards Now",
    Desc = "Instantly runs a one-time sweep across all daily, index, gift, and spin rewards",
    Callback = function()
        pcall(function() RewardsRemotes.DailyClaim:InvokeServer() end)
        pcall(function() RewardsRemotes.IndexClaimAll:InvokeServer() end)
        for i = 1, 12 do
            pcall(function() RewardsRemotes.GiftClaim:InvokeServer(i) end)
        end
        pcall(function() RewardsRemotes.SpinRequest:InvokeServer() end)
        pcall(function() OfflineRemotes.Claim:InvokeServer() end)
        pcall(function() SecretEggRemotes.Hatch:InvokeServer() end)
    end
})

-- TAB 6: TELEPORTS & AREAS
local TabTeleports = Window:Tab({Title = "Teleports", Icon = "rbxassetid://10734950309"})

TabTeleports:Section({Title = "Quick Hub Teleports"})

TabTeleports:Button({
    Title = "Shooting Lane Spot",
    Desc = "Warps directly onto the arrow launching pad",
    Callback = function()
        local lineSpot = Shooter.LineSpot()
        safeTeleport(lineSpot and lineSpot.Position or LOCATIONS.ShootingLine)
    end
})

TabTeleports:Button({
    Title = "My Plot Center",
    Desc = "Warps to your home plot",
    Callback = function()
        local plot = getMyPlot()
        if plot then
            safeTeleport(plot:GetPivot().Position + Vector3.new(0, 4, 0))
        end
    end
})

TabTeleports:Button({
    Title = "My Bench Press",
    Desc = "Warps directly to your plot bench",
    Callback = function()
        local root = getMyBenchRoot()
        if root then
            safeTeleport(root.Position + Vector3.new(0, 3, 0))
        end
    end
})

TabTeleports:Button({
    Title = "Bow Shop Merchant",
    Desc = "Warps directly to the Bow Shop stand",
    Callback = function()
        safeTeleport(LOCATIONS.LocalBowShop)
    end
})

TabTeleports:Button({
    Title = "Fence Upgrade Sign",
    Desc = "Warps to the fence upgrade interaction sign",
    Callback = function()
        safeTeleport(LOCATIONS.PlotUpgradeSign + Vector3.new(0, 3, 2))
    end
})

TabTeleports:Section({Title = "All 41 World Areas Fast Travel"})

local areaNames = {}
for i, area in ipairs(AreasConfig.List) do
    table.insert(areaNames, string.format("[%d] %s (Z: %d)", i, area.Name, math.floor(area.ZStart or 0)))
end

TabTeleports:Dropdown({
    Title = "Select Target Area",
    Desc = "Choose any world biome to travel to",
    Values = areaNames,
    Value = areaNames[1],
    Callback = function(selection)
        local idx = tonumber(selection:match("%[(%d+)%]"))
        if idx then
            Settings.SelectedAreaIndex = idx
        end
    end
})

TabTeleports:Button({
    Title = "Teleport to Selected Area",
    Desc = "Warps character directly into the chosen biome",
    Callback = function()
        local area = AreasConfig.List[Settings.SelectedAreaIndex]
        if area and area.ZStart then
            safeTeleport(Vector3.new(0, 6, area.ZStart - 10))
        end
    end
})

-- TAB 7: PLAYER & UTILITIES
local TabPlayer = Window:Tab({Title = "Player & Mods", Icon = "rbxassetid://10747373176"})

TabPlayer:Section({Title = "Movement & Physics Modifiers"})

TabPlayer:Toggle({
    Title = "Enable WalkSpeed Modifier",
    Desc = "Locks WalkSpeed to selected value against game resets",
    Value = false,
    Callback = function(val)
        Settings.WalkSpeedEnabled = val
        if not val then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

TabPlayer:Slider({
    Title = "WalkSpeed Value",
    Desc = "Custom player movement speed",
    Step = 1,
    Value = {Min = 16, Max = 250, Default = 16},
    Callback = function(val)
        Settings.WalkSpeed = tonumber(val) or 16
    end
})

TabPlayer:Toggle({
    Title = "Enable JumpPower Modifier",
    Desc = "Locks JumpPower to selected value",
    Value = false,
    Callback = function(val)
        Settings.JumpPowerEnabled = val
        if not val then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
})

TabPlayer:Slider({
    Title = "JumpPower Value",
    Desc = "Custom jump vertical leap power",
    Step = 5,
    Value = {Min = 50, Max = 300, Default = 50},
    Callback = function(val)
        Settings.JumpPower = tonumber(val) or 50
    end
})

TabPlayer:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in mid-air",
    Value = false,
    Callback = function(val)
        Settings.InfiniteJump = val
    end
})

TabPlayer:Toggle({
    Title = "Noclip",
    Desc = "Allows walking directly through fences and world barriers",
    Value = false,
    Callback = function(val)
        Settings.Noclip = val
    end
})

TabPlayer:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents Roblox 20-minute idle disconnection",
    Value = false,
    Callback = function(val)
        Settings.AntiAfk = val
    end
})

-- TAB 8: CONFIGS (RULE 8 COMPLIANT)
local TabConfig = Window:Tab({Title = "Configs", Icon = "rbxassetid://10734950020"})

TabConfig:Section({Title = "Profile & Settings Storage"})

local configFileName = "XLuna_ShootArrows_Config.json"

TabConfig:Input({
    Title = "Config File Name",
    Desc = "Name of JSON file in executor workspace",
    Value = "XLuna_ShootArrows_Config",
    Callback = function(val)
        if val and #val > 0 then
            configFileName = val .. ".json"
        end
    end
})

TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Serializes all current toggle and slider values to disk",
    Callback = function()
        if writefile then
            pcall(function()
                writefile(configFileName, HttpService:JSONEncode(Settings))
            end)
        end
    end
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Restores saved parameters from JSON configuration",
    Callback = function()
        if readfile and isfile and isfile(configFileName) then
            pcall(function()
                local raw = readfile(configFileName)
                local decoded = HttpService:JSONDecode(raw)
                if type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        if Settings[k] ~= nil then
                            Settings[k] = v
                        end
                    end
                end
            end)
        end
    end
})

TabConfig:Button({
    Title = "Reset All Settings (All Off)",
    Desc = "Resets every feature back to its default disabled state",
    Callback = function()
        for k, v in pairs(Settings) do
            if type(v) == "boolean" then
                Settings[k] = false
            end
        end
    end
})

-- Real-time Dynamic Status Updater (Bench, Bows, Fence)
task.spawn(function()
    while _G.XLUNA_LOADED do
        pcall(function()
            local data = DataController.Data()
            if not data then return end
            local money = data.Money or 0

            -- 1. Bench Status
            if BenchStatusParagraph and BenchStatusParagraph.SetDesc then
                local currentStand = data.Training and data.Training.Stand or 1
                local standsList = StandsConfig.All or StandsConfig.List or StandsConfig
                local curStandData = standsList[currentStand]
                local nextStandData = standsList[currentStand + 1]
                if nextStandData then
                    local price = nextStandData.Price or nextStandData.Cost or 0
                    local pct = math.min(100, math.floor((money / math.max(1, price)) * 100))
                    BenchStatusParagraph:SetDesc(string.format("Current: [%d] %s\nNext: [%d] %s ($%s)\nProgress: $%s / $%s (%d%%)",
                        currentStand, curStandData and curStandData.Name or "Unknown",
                        currentStand + 1, nextStandData.Name or "Unknown", formatNumber(price),
                        formatNumber(money), formatNumber(price), pct
                    ))
                else
                    BenchStatusParagraph:SetDesc(string.format("Current: [%d] %s (MAX LEVEL REACHED)", currentStand, curStandData and curStandData.Name or "Unknown"))
                end
            end

            -- 2. Bow Status
            if BowStatusParagraph and BowStatusParagraph.SetDesc then
                local currentBow = data.Bow or 1
                local ownedBows = data.OwnedBows or {}
                local bowsList = BowsConfig.List or BowsConfig.All or BowsConfig
                local curBowData = bowsList[currentBow]
                local nextBowIndex = nil
                local nextBowData = nil
                for i, bow in ipairs(bowsList) do
                    if not ownedBows[tostring(i)] and not ownedBows[i] then
                        nextBowIndex = i
                        nextBowData = bow
                        break
                    end
                end
                if nextBowData then
                    local price = nextBowData.Price or nextBowData.Cost or 0
                    local pct = math.min(100, math.floor((money / math.max(1, price)) * 100))
                    BowStatusParagraph:SetDesc(string.format("Current: [%d] %s\nNext: [%d] %s ($%s)\nProgress: $%s / $%s (%d%%)",
                        currentBow, curBowData and curBowData.Name or "Unknown",
                        nextBowIndex, nextBowData.Name or "Unknown", formatNumber(price),
                        formatNumber(money), formatNumber(price), pct
                    ))
                else
                    BowStatusParagraph:SetDesc(string.format("Current: [%d] %s (ALL BOWS OWNED)", currentBow, curBowData and curBowData.Name or "Unknown"))
                end
            end

            -- 3. Fence Status
            if FenceStatusParagraph and FenceStatusParagraph.SetDesc then
                local fenceLvl = data.FenceLevel or 0
                local nextUpgrade = PlotConfig and PlotConfig.Fence and PlotConfig.Fence.Upgrades and PlotConfig.Fence.Upgrades[fenceLvl + 1]
                if nextUpgrade then
                    local price = nextUpgrade.Price or 0
                    local pct = math.min(100, math.floor((money / math.max(1, price)) * 100))
                    FenceStatusParagraph:SetDesc(string.format("Current: Level %d\nNext: Level %d (%d Slots) ($%s)\nProgress: $%s / $%s (%d%%)",
                        fenceLvl, fenceLvl + 1, nextUpgrade.Slots or 0, formatNumber(price),
                        formatNumber(money), formatNumber(price), pct
                    ))
                else
                    FenceStatusParagraph:SetDesc(string.format("Current: Level %d (MAX LEVEL REACHED)", fenceLvl))
                end
            end
        end)
        task.wait(2.0)
    end
end)

-- Automatically select and display first tab
pcall(function()
    Window:SelectTab(1)
end)

-- ============================================================================
-- UNLOAD LIFECYCLE HANDLER
-- ============================================================================
_G.XLUNA_UNLOAD = function()
    -- Disconnect all runtime listeners
    for _, conn in ipairs(ActiveConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ActiveConnections)

    -- Destroy UI elements
    pcall(function() FloatingGui:Destroy() end)
    pcall(function() Window:Destroy() end)
    cleanPreviousWindUI()

    -- Reset player speeds
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)

    _G.XLUNA_LOADED = false
end

return "XLuna Hub for [ð¹] Shoot Arrows For Animals loaded successfully!"
