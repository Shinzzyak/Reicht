-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    Throw Key for Cars | Automation Suite
    Engineered for precision, zero fluff, high performance.
    UI Framework: WindUI
    Localization: Universal English
    Default State: All Toggles OFF
    Toggle Key: Left Control | Floating Button: Enabled
]]

-- Tear down previous instances if reloaded
if getgenv()._ThrowKeyForCarsCleanup then
    pcall(getgenv()._ThrowKeyForCarsCleanup)
end

local targetGui = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
for _, c in ipairs(targetGui:GetChildren()) do
    if string.find(c.Name, "WindUI") then
        pcall(function() c:Destroy() end)
    end
end

local isRunning = true
getgenv()._ThrowKeyForCarsCleanup = function()
    isRunning = false
    for _, c in ipairs(targetGui:GetChildren()) do
        if string.find(c.Name, "WindUI") then
            pcall(function() c:Destroy() end)
        end
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Wait for Game Framework & Replicas
local Nex = require(ReplicatedStorage:WaitForChild("Nex"))
local DataController = Nex.GetController("DataController")
local TrainingController = Nex.GetController("TrainingController")

local ThrowService = Nex.GetService("ThrowService")
local TrainingService = Nex.GetService("TrainingService")
local KeyShopService = Nex.GetService("KeyShopService")
local BarService = Nex.GetService("BarService")
local FenceService = Nex.GetService("FenceService")
local InventoryService = Nex.GetService("InventoryService")
local SellService = Nex.GetService("SellService")
local CosmeticsService = Nex.GetService("CosmeticsService")
local OfflineService = Nex.GetService("OfflineService")
local IndexService = Nex.GetService("IndexService")
local ProductService = Nex.GetService("ProductService")

local GameConfig = Nex.GetInfo("GameConfig")
local Economy = Nex.GetUtil("Economy")

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function safeNotify(options)
    pcall(function()
        safeNotify(options)
    end)
end

-- Master Settings State (Default: ALL OFF)
local Settings = {
    -- Auto Farm
    AutoThrow = false,
    ThrowDelay = 0.75,
    AutoTrain = false,
    AutoBonus = false,
    AutoUpgradeBar = false,
    AutoUpgradeFence = false,
    AutoBuyKey = false,
    AutoEquipKey = false,

    -- Cars & Inventory
    AutoEquipBestCars = false,
    AutoPlaceCars = false,
    AutoSellDuplicates = false,
    AutoSellCommon = false,
    AutoSellUncommon = false,
    AutoSellLowestWhenFull = false,

    -- Rewards
    AutoClaimRewards = false,

    -- Player & Physics
    AntiAFK = true,
    AutoReconnect = true,
    WalkSpeedEnabled = false,
    WalkSpeedValue = 20,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    Noclip = false,
    InfiniteJump = false,

    -- Config System
    AutoLoadConfig = false,
    SelectedConfig = "default"
}

local UI_Elements = {}
getgenv().ThrowKeySuite = {
    Settings = Settings,
    UI_Elements = UI_Elements,
}
local ConfigFolder = "ThrowKeyForCars"
if not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end

-- Utility: Get Player Plot Instance
local function getMyPlot()
    local plotAttr = LocalPlayer:GetAttribute("Plot")
    if plotAttr then
        local p = workspace.Plots:FindFirstChild(tostring(plotAttr))
        if p then return p end
    end
    for _, p in ipairs(workspace.Plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return p
        end
    end
    return nil
end

-- Utility: Calculate Smart Grid Spots on Plot
local function getPlotGridPositions(plot)
    if not plot then return {} end
    local grow = plot:GetAttribute("FenceGrow") or 0
    local floorPos = plot.Position
    local zMax = 19.5 + grow * 12
    local positions = {}
    
    local xOffsets = {-15, -7.5, 0, 7.5, 15}
    local zOffsets = {-14, -6, 2, 10, 18}
    if grow > 0 then
        table.insert(zOffsets, 26)
        table.insert(zOffsets, 34)
    end
    
    for _, z in ipairs(zOffsets) do
        if z <= zMax then
            for _, x in ipairs(xOffsets) do
                table.insert(positions, floorPos + Vector3.new(x, plot.Size.Y / 2, z))
            end
        end
    end
    return positions
end

-- Utility: Smart Auto Placement
local function placeUnplacedCars()
    local plot = getMyPlot()
    if not plot then return end
    
    local cars = DataController.GetData("Cars") or {}
    local fenceLevel = DataController.GetData("Fence") or 0
    local maxSlots = (GameConfig.Fence[fenceLevel + 1] and GameConfig.Fence[fenceLevel + 1].Slots) or 10
    
    local placedCount = 0
    local unplaced = {}
    for _, c in ipairs(cars) do
        if c.Placed then
            placedCount = placedCount + 1
        else
            table.insert(unplaced, c)
        end
    end
    
    if #unplaced == 0 or placedCount >= maxSlots then return end
    
    local grid = getPlotGridPositions(plot)
    for _, car in ipairs(unplaced) do
        if placedCount >= maxSlots then break end
        local spotIndex = (placedCount % #grid) + 1
        local targetSpot = grid[spotIndex]
        local ok, res = InventoryService.PlaceCar(car.Id, targetSpot):await()
        if ok and res and res.Ok then
            placedCount = placedCount + 1
        end
        task.wait(0.2)
    end
end

-- Utility: Pickup All Cars
local function pickupAllCars()
    local cars = DataController.GetData("Cars") or {}
    for _, c in ipairs(cars) do
        if c.Placed then
            InventoryService.PickupCar(c.Id):await()
            task.wait(0.15)
        end
    end
    safeNotify({
        Title = "Inventory",
        Content = "All placed cars picked up into inventory.",
        Duration = 3,
        Icon = "archive"
    })
end

-- Utility: Equip Best Cars (Ultra-fast Atomic Server Dispatch)
local function equipBestCars(notify)
    local ok, res = InventoryService.EquipBest():await()
    if ok and res and res.Ok then
        if notify then
            safeNotify({
                Title = "Equip Best",
                Content = "Equipped best " .. tostring(res.Best or 12) .. " cars instantly! (" .. tostring(res.Changed or 0) .. " updated)",
                Duration = 2,
                Icon = "check"
            })
        end
        return true
    end
    return false
end

-- Utility: High-Speed Multi-Filter Auto Sell
local isSelling = false
local function autoSellLogic()
    if isSelling then return end
    isSelling = true
    
    local cars = DataController.GetData("Cars") or {}
    if #cars == 0 then
        isSelling = false
        return
    end
    
    -- Filter 1: Auto Sell Duplicates (Only sells unplaced backpack duplicates)
    if Settings.AutoSellDuplicates then
        local placedModels = {}
        for _, c in ipairs(cars) do
            if c.Placed then
                placedModels[c.Model] = true
            end
        end
        local seenUnplaced = {}
        for _, c in ipairs(cars) do
            if not c.Placed then
                if placedModels[c.Model] or seenUnplaced[c.Model] then
                    SellService.SellCar(c.Id):await()
                    task.wait(0.01)
                else
                    seenUnplaced[c.Model] = true
                end
            end
        end
    end
    
    cars = DataController.GetData("Cars") or {}
    
    -- Filter 2: Auto Replace / Sell Lowest When Plot Full (or worse than plot)
    if Settings.AutoSellLowestWhenFull then
        local minPlacedIncome = math.huge
        local hasPlaced = false
        for _, c in ipairs(cars) do
            if c.Placed then
                local inc = Economy.IncomeOf(c)
                if inc < minPlacedIncome then
                    minPlacedIncome = inc
                end
                hasPlaced = true
            end
        end
        if hasPlaced and minPlacedIncome < math.huge then
            for _, c in ipairs(cars) do
                if not c.Placed then
                    local inc = Economy.IncomeOf(c)
                    if inc < minPlacedIncome then
                        SellService.SellCar(c.Id):await()
                        task.wait(0.01)
                    end
                end
            end
        end
    end
    
    cars = DataController.GetData("Cars") or {}
    
    -- Filter 3: Auto Sell Starter Cars (<= $100/s)
    if Settings.AutoSellCommon then
        for _, c in ipairs(cars) do
            if not c.Placed then
                local inc = Economy.IncomeOf(c)
                if inc <= 100 then
                    SellService.SellCar(c.Id):await()
                    task.wait(0.01)
                end
            end
        end
    end
    
    -- Filter 4: Auto Sell Tier 2 Cars (<= $1,000/s)
    if Settings.AutoSellUncommon then
        for _, c in ipairs(cars) do
            if not c.Placed then
                local inc = Economy.IncomeOf(c)
                if inc > 100 and inc <= 1000 then
                    SellService.SellCar(c.Id):await()
                    task.wait(0.01)
                end
            end
        end
    end
    
    isSelling = false
end

-- Event-Driven Reactive Inventory Listener (Triggers sub-50ms reaction)
task.spawn(function()
    DataController.OnSet("Cars", function()
        if not isRunning then return end
        task.defer(function()
            if Settings.AutoEquipBestCars then
                pcall(function() equipBestCars(false) end)
            elseif Settings.AutoPlaceCars then
                pcall(placeUnplacedCars)
            end
            if Settings.AutoSellDuplicates or Settings.AutoSellCommon or Settings.AutoSellUncommon or Settings.AutoSellLowestWhenFull then
                pcall(autoSellLogic)
            end
        end)
    end)
end)

-- Utility: Snipe Active Training Bonus
local function snipeBonusInstance(bonus)
    if not bonus or not bonus.Parent then return end
    local conns = (type(getconnections) == "function" and getconnections(bonus.Activated)) or {}
    local triggered = false
    if #conns > 0 then
        for _, c in ipairs(conns) do
            if c.Function then
                pcall(c.Function)
                triggered = true
            elseif c.Fire then
                pcall(function() c:Fire() end)
                triggered = true
            end
        end
    end
    if not triggered and type(firesignal) == "function" then
        pcall(function() firesignal(bonus.Activated) end)
        triggered = true
    end
    task.delay(0.12, function()
        if bonus and bonus.Parent then
            pcall(function() bonus:Destroy() end)
        end
    end)
end

-- Hook Training Bonus Event & Auto-Snipe Bubble
local oldBonus = TrainingController.Server.Bonus
TrainingController.Server.Bonus = function(a1, a2, a3)
    local ret = oldBonus(a1, a2, a3)
    if Settings.AutoBonus then
        task.spawn(function()
            task.wait(0.04)
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            local ts = pgui and pgui:FindFirstChild("TrainingSequence")
            local bonus = ts and ts:FindFirstChild("Bonus")
            if bonus then
                snipeBonusInstance(bonus)
            else
                TrainingService.TapBonus(a1)
            end
        end)
    end
    return ret
end

-- ChildAdded Watcher on TrainingSequence for Instant Bonus Popping
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    local ts = pgui:WaitForChild("TrainingSequence")
    ts.ChildAdded:Connect(function(child)
        if not isRunning then return end
        if child.Name == "Bonus" and Settings.AutoBonus then
            task.wait(0.04)
            snipeBonusInstance(child)
        end
    end)
end)

-- Background Task: Silent Auto Throw
task.spawn(function()
    while isRunning do
        if Settings.AutoThrow then
            local ok, startRes = ThrowService.Start():await()
            if ok and startRes and startRes.Ok then
                local throwId = startRes.ThrowId
                task.wait(Settings.ThrowDelay or 0.75)
                local ok2, resRes = ThrowService.Resolve(throwId, 1):await()
                task.wait(0.1)
                ThrowService.Complete(throwId):await()
                task.wait(1.5)
            elseif ok and startRes and startRes.Reason == "Busy" then
                ThrowService.Cancel():await()
                task.wait(1.5)
            elseif ok and startRes and startRes.Reason == "Cooldown" then
                task.wait(0.5)
            else
                task.wait(1.0)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Background Task: Auto Train
task.spawn(function()
    while isRunning do
        if Settings.AutoTrain then
            local plot = getMyPlot()
            local ts = plot and plot:FindFirstChild("TrainingSpot")
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if ts and hrp then
                local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(ts.WorldPosition.X, 0, ts.WorldPosition.Z)).Magnitude
                if dist > 3 then
                    hrp.CFrame = ts.WorldCFrame + Vector3.new(0, 3, 0)
                    task.wait(0.3)
                end
                if LocalPlayer:GetAttribute("Training") ~= true and not TrainingController.IsActive() then
                    hrp.CFrame = ts.WorldCFrame + Vector3.new(0, 3, 0)
                end
            end
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- Background Task: Auto Upgrade Barbell
task.spawn(function()
    while isRunning do
        if Settings.AutoUpgradeBar then
            local lpp = workspace:FindFirstChild("LocalPlotProps")
            local ub = lpp and lpp:FindFirstChild("UpgradeButton") and lpp.UpgradeButton:FindFirstChild("Pad")
            local barLevel = DataController.GetData("Bar") or 1
            local nextBar = GameConfig.Bars[barLevel + 1]
            local money = DataController.GetData("Money") or 0
            
            if ub and nextBar and money >= nextBar.Price then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local oldCF = hrp.CFrame
                    hrp.CFrame = ub.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.35)
                    BarService.Upgrade():await()
                    task.wait(0.05)
                    hrp.CFrame = oldCF
                end
            end
            task.wait(2.0)
        else
            task.wait(1.0)
        end
    end
end)

-- Background Task: Auto Upgrade Fence
task.spawn(function()
    while isRunning do
        if Settings.AutoUpgradeFence then
            local lpp = workspace:FindFirstChild("LocalPlotProps")
            local fs = lpp and lpp:FindFirstChild("FenceSign") and lpp.FenceSign:FindFirstChild("Board")
            local fenceLevel = DataController.GetData("Fence") or 0
            local nextFence = GameConfig.Fence[fenceLevel + 2]
            local money = DataController.GetData("Money") or 0
            
            if fs and nextFence and nextFence.Price and money >= nextFence.Price then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local oldCF = hrp.CFrame
                    hrp.CFrame = fs.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.35)
                    FenceService.Upgrade():await()
                    task.wait(0.05)
                    hrp.CFrame = oldCF
                end
            end
            task.wait(2.5)
        else
            task.wait(1.0)
        end
    end
end)

-- Background Task: Auto Buy & Equip Key
task.spawn(function()
    while isRunning do
        if Settings.AutoBuyKey or Settings.AutoEquipKey then
            local ownedKeys = DataController.GetData("OwnedKeys") or {}
            local currentKey = DataController.GetData("EquippedKey") or 1
            local money = DataController.GetData("Money") or 0
            
            if Settings.AutoBuyKey then
                for _, keyInfo in ipairs(GameConfig.Keys) do
                    local keyNo = keyInfo.No
                    if not ownedKeys[tostring(keyNo)] and not ownedKeys[keyNo] then
                        if money >= keyInfo.Price then
                            KeyShopService.BuyKey(keyNo):await()
                            task.wait(0.3)
                        end
                        break
                    end
                end
            end
            
            if Settings.AutoEquipKey then
                local highestOwned = 1
                for _, keyInfo in ipairs(GameConfig.Keys) do
                    local keyNo = keyInfo.No
                    if ownedKeys[tostring(keyNo)] or ownedKeys[keyNo] then
                        if keyNo > highestOwned then
                            highestOwned = keyNo
                        end
                    end
                end
                if highestOwned ~= currentKey then
                    KeyShopService.EquipKey(highestOwned):await()
                end
            end
            task.wait(2.0)
        else
            task.wait(1.0)
        end
    end
end)

-- Background Task: Auto Place, Auto Equip Best, and Auto Sell
task.spawn(function()
    while isRunning do
        if Settings.AutoEquipBestCars then
            local cars = DataController.GetData("Cars") or {}
            local hasUnplaced = false
            for _, c in ipairs(cars) do
                if not c.Placed then
                    hasUnplaced = true
                    break
                end
            end
            if hasUnplaced then
                pcall(function() equipBestCars(false) end)
            end
        elseif Settings.AutoPlaceCars then
            pcall(placeUnplacedCars)
        end
        if Settings.AutoSellDuplicates or Settings.AutoSellCommon or Settings.AutoSellUncommon or Settings.AutoSellLowestWhenFull then
            pcall(autoSellLogic)
        end
        task.wait(1.0)
    end
end)

-- Background Task: Auto Claim Rewards
task.spawn(function()
    while isRunning do
        if Settings.AutoClaimRewards then
            pcall(function()
                if DataController.GetData("FreeCarClaimed") ~= true then
                    ProductService.ClaimFree():await()
                    task.wait(0.3)
                end
                OfflineService.Claim():await()
                task.wait(0.3)
                CosmeticsService.ClaimDaily():await()
                task.wait(0.3)
                for i = 1, #GameConfig.Zones do
                    IndexService.Claim(i):await()
                    task.wait(0.1)
                end
            end)
            task.wait(12.0)
        else
            task.wait(2.0)
        end
    end
end)

-- Player Movement & Physics Controller
local function updatePlayerPhysics()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.WalkSpeedEnabled then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end
        if Settings.JumpPowerEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPowerValue
        end
    end
end

RunService.Stepped:Connect(function()
    if not isRunning then return end
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    updatePlayerPhysics()
end)

UserInputService.JumpRequest:Connect(function()
    if not isRunning then return end
    if Settings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti-AFK Engine (Bypasses Roblox 20-minute idle kick via Hardware Input Emulation)
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local idledConn = nil

local function dispatchAntiAFKPulse()
    pcall(function()
        -- 1. VirtualInputManager hardware mouse movement & click
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local rx = math.random(math.floor(vp.X * 0.3), math.floor(vp.X * 0.7))
        local ry = math.random(math.floor(vp.Y * 0.3), math.floor(vp.Y * 0.7))
        VirtualInputManager:SendMouseMoveEvent(rx, ry, game)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(rx, ry, 0, true, game, 0)
        task.wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(rx, ry, 0, false, game, 0)
        
        -- 2. VirtualInputManager hardware keypress (RightControl - non-intrusive)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
        task.wait(0.04)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
        
        -- 3. Fallback VirtualUser capture
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(rx, ry))
    end)
end

local function updateAntiAFK(enable)
    if enable then
        if not idledConn then
            idledConn = LocalPlayer.Idled:Connect(function()
                if Settings.AntiAFK then
                    dispatchAntiAFKPulse()
                end
            end)
        end
        pcall(function()
            local conns = (type(getconnections) == "function" and getconnections(LocalPlayer.Idled)) or {}
            for _, c in ipairs(conns) do
                if c ~= idledConn then
                    if c.Disable then c:Disable() elseif c.Disconnect then c:Disconnect() end
                end
            end
        end)
    else
        if idledConn then
            pcall(function() idledConn:Disconnect() end)
            idledConn = nil
        end
    end
end

-- Active Anti-AFK Heartbeat Pulse (Runs every 40-50s)
task.spawn(function()
    while isRunning do
        if Settings.AntiAFK then
            dispatchAntiAFKPulse()
        end
        task.wait(math.random(40, 50))
    end
end)

-- Auto Reconnect Engine (Monitors Disconnection Prompts & Reconnects)
local reconnectConn = nil
local promptConn = nil

local function attemptReconnect()
    if not Settings.AutoReconnect then return end
    task.wait(2.0)
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
    task.wait(4.0)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

local function updateAutoReconnect(enable)
    if enable then
        if not reconnectConn then
            reconnectConn = GuiService.ErrorMessageChanged:Connect(function()
                if Settings.AutoReconnect then
                    attemptReconnect()
                end
            end)
        end
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            local rPrompt = coreGui:FindFirstChild("RobloxPromptGui")
            local pOverlay = rPrompt and rPrompt:FindFirstChild("promptOverlay")
            if pOverlay and not promptConn then
                promptConn = pOverlay.ChildAdded:Connect(function(child)
                    if Settings.AutoReconnect and (child.Name == "ErrorPrompt" or string.find(child.Name:lower(), "error")) then
                        attemptReconnect()
                    end
                end)
                for _, child in ipairs(pOverlay:GetChildren()) do
                    if child.Name == "ErrorPrompt" or string.find(child.Name:lower(), "error") then
                        attemptReconnect()
                    end
                end
            end
        end)
    else
        if reconnectConn then
            pcall(function() reconnectConn:Disconnect() end)
            reconnectConn = nil
        end
        if promptConn then
            pcall(function() promptConn:Disconnect() end)
            promptConn = nil
        end
    end
end

-- Initialize Anti-AFK and Auto Reconnect immediately if enabled by default
if Settings.AntiAFK then
    updateAntiAFK(true)
end
if Settings.AutoReconnect then
    updateAutoReconnect(true)
end

-- Config File Utilities
local function saveConfigFile(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    local encoded = HttpService:JSONEncode(Settings)
    writefile(path, encoded)
    safeNotify({
        Title = "Configuration",
        Content = "Successfully saved: " .. name .. ".json",
        Duration = 3,
        Icon = "check"
    })
end

local function loadConfigFile(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local raw = readfile(path)
        local success, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if Settings[k] ~= nil then
                    Settings[k] = v
                    if UI_Elements[k] and UI_Elements[k].Set then
                        pcall(function() UI_Elements[k]:Set(v) end)
                    end
                end
            end
            safeNotify({
                Title = "Configuration",
                Content = "Successfully loaded: " .. name .. ".json",
                Duration = 3,
                Icon = "check"
            })
            return true
        end
    end
    safeNotify({
        Title = "Configuration",
        Content = "Config file not found: " .. name,
        Duration = 3,
        Icon = "alert-circle"
    })
    return false
end

-- ==========================================
-- CREATE WINDUI WINDOW INTERFACE
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "Throw Key for Cars | Automation Suite",
    Icon = "car",
    Author = "Universal Build v1.0",
    Folder = ConfigFolder,
    Size = UDim2.fromOffset(600, 480),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    SideBarWidth = 190,
    HideSearchBar = true,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Open Menu",
        Icon = "key",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromRGB(0, 200, 255),
            Color3.fromRGB(0, 100, 255)
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

getgenv().ThrowKeySuite.Window = Window

-- Ensure WindUI ScreenGuis always render with top DisplayOrder
task.defer(function()
    for _, c in ipairs(targetGui:GetChildren()) do
        if string.find(c.Name, "WindUI") and c:IsA("ScreenGui") then
            c.DisplayOrder = 999
        end
    end
end)

-- ------------------------------------------
-- TAB 1: AUTO FARM
-- ------------------------------------------
local FarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "zap"
})

FarmTab:Section({ Title = "Silent Auto Throw", Opened = true })

UI_Elements.AutoThrow = FarmTab:Toggle({
    Title = "Silent Auto Throw",
    Desc = "Spins throw cycle silently in background with 100% PERFECT meter rating",
    Value = false,
    Callback = function(val)
        Settings.AutoThrow = val
    end
})

FarmTab:Slider({
    Title = "Throw Meter Timing",
    Desc = "Time elapsed before resolving (0.65s - 2.0s)",
    Value = {
        Min = 0.65,
        Max = 2.0,
        Default = 0.75,
    },
    Step = 0.05,
    Callback = function(val)
        Settings.ThrowDelay = val
    end
})

FarmTab:Section({ Title = "Training Automation", Opened = true })

UI_Elements.AutoTrain = FarmTab:Toggle({
    Title = "Auto Training",
    Desc = "Auto teleports to barbell spot and loops reps",
    Value = false,
    Callback = function(val)
        Settings.AutoTrain = val
        if not val and TrainingController.IsActive() then
            pcall(function() TrainingController.Stop() end)
        end
    end
})

UI_Elements.AutoBonus = FarmTab:Toggle({
    Title = "Auto Snipe Bonus (2x XP)",
    Desc = "Instantly claims XP bonus bubbles the millisecond they spawn",
    Value = false,
    Callback = function(val)
        Settings.AutoBonus = val
        if val then
            pcall(function()
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local ts = pgui and pgui:FindFirstChild("TrainingSequence")
                local bonus = ts and ts:FindFirstChild("Bonus")
                if bonus then
                    snipeBonusInstance(bonus)
                end
            end)
        end
    end
})

FarmTab:Button({
    Title = "Teleport to Training Spot",
    Desc = "Positions character directly on the plot's barbell pull-up station",
    Callback = function()
        local plot = getMyPlot()
        local ts = plot and plot:FindFirstChild("TrainingSpot")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if ts and hrp then
            hrp.CFrame = ts.WorldCFrame + Vector3.new(0, 3, 0)
        end
    end
})

FarmTab:Section({ Title = "Base & Upgrades", Opened = true })

UI_Elements.AutoUpgradeBar = FarmTab:Toggle({
    Title = "Auto Upgrade Barbell",
    Desc = "Purchases higher barbell tiers as soon as money is sufficient",
    Value = false,
    Callback = function(val)
        Settings.AutoUpgradeBar = val
    end
})

UI_Elements.AutoUpgradeFence = FarmTab:Toggle({
    Title = "Auto Upgrade Fence",
    Desc = "Expands plot bounds and unlocks more car slots",
    Value = false,
    Callback = function(val)
        Settings.AutoUpgradeFence = val
    end
})

UI_Elements.AutoBuyKey = FarmTab:Toggle({
    Title = "Auto Buy Next Key",
    Desc = "Automatically buys the next highest key tier in shop",
    Value = false,
    Callback = function(val)
        Settings.AutoBuyKey = val
    end
})

UI_Elements.AutoEquipKey = FarmTab:Toggle({
    Title = "Auto Equip Best Key",
    Desc = "Ensures your highest bait key is always equipped",
    Value = false,
    Callback = function(val)
        Settings.AutoEquipKey = val
    end
})

-- ------------------------------------------
-- TAB 2: CARS & INVENTORY
-- ------------------------------------------
local CarsTab = Window:Tab({
    Title = "Cars & Inventory",
    Icon = "car"
})

CarsTab:Section({ Title = "Plot Placement", Opened = true })

UI_Elements.AutoEquipBestCars = CarsTab:Toggle({
    Title = "Auto Equip Best Cars",
    Desc = "Continuously ensures plot is occupied by your highest $/s income vehicles",
    Value = false,
    Callback = function(val)
        Settings.AutoEquipBestCars = val
        if val then
            task.spawn(function() equipBestCars(true) end)
        end
    end
})

CarsTab:Button({
    Title = "Equip Best Cars Now",
    Desc = "Instantly recalls inferior cars and places your top income vehicles",
    Callback = function()
        equipBestCars(true)
    end
})

UI_Elements.AutoPlaceCars = CarsTab:Toggle({
    Title = "Smart Auto Place Cars",
    Desc = "Automatically arranges unplaced cars into neat grid coordinates on plot floor",
    Value = false,
    Callback = function(val)
        Settings.AutoPlaceCars = val
    end
})

CarsTab:Button({
    Title = "Place All Cars Now",
    Desc = "Attempts to place all unplaced inventory cars immediately",
    Callback = function()
        placeUnplacedCars()
    end
})

CarsTab:Button({
    Title = "Pickup All Placed Cars",
    Desc = "Safely returns all cars on your plot back into inventory",
    Callback = function()
        pickupAllCars()
    end
})

CarsTab:Section({ Title = "Smart Selling Filters", Opened = true })

UI_Elements.AutoSellLowestWhenFull = CarsTab:Toggle({
    Title = "Auto Sell Inferior Cars (Worse than Plot)",
    Desc = "Instantly sells unplaced backpack cars with income lower than your plot's lowest car",
    Value = false,
    Callback = function(val)
        Settings.AutoSellLowestWhenFull = val
        if val then
            task.spawn(autoSellLogic)
        end
    end
})

UI_Elements.AutoSellDuplicates = CarsTab:Toggle({
    Title = "Auto Sell Duplicates",
    Desc = "Keeps only the best copy of each car model and liquidates duplicates in backpack",
    Value = false,
    Callback = function(val)
        Settings.AutoSellDuplicates = val
        if val then
            task.spawn(autoSellLogic)
        end
    end
})

UI_Elements.AutoSellCommon = CarsTab:Toggle({
    Title = "Auto Sell Starter Cars (<= $100/s)",
    Desc = "Instantly liquidates common low tier vehicles in backpack",
    Value = false,
    Callback = function(val)
        Settings.AutoSellCommon = val
        if val then
            task.spawn(autoSellLogic)
        end
    end
})

UI_Elements.AutoSellUncommon = CarsTab:Toggle({
    Title = "Auto Sell Low Tier Cars (<= $1,000/s)",
    Desc = "Liquidates low-mid vehicles in backpack to keep inventory clean",
    Value = false,
    Callback = function(val)
        Settings.AutoSellUncommon = val
        if val then
            task.spawn(autoSellLogic)
        end
    end
})

CarsTab:Button({
    Title = "Sell Unplaced Cars Now",
    Desc = "Instantly sells all unplaced cars in your inventory for cash",
    Callback = function()
        local cars = DataController.GetData("Cars") or {}
        local count = 0
        for _, c in ipairs(cars) do
            if not c.Placed then
                SellService.SellCar(c.Id):await()
                count = count + 1
                task.wait(0.04)
            end
        end
        safeNotify({
            Title = "Sell Action",
            Content = "Sold " .. count .. " unplaced cars.",
            Duration = 3,
            Icon = "dollar-sign"
        })
    end
})

-- ------------------------------------------
-- TAB 3: REWARDS
-- ------------------------------------------
local RewardsTab = Window:Tab({
    Title = "Rewards",
    Icon = "gift"
})

RewardsTab:Section({ Title = "Reward Automation", Opened = true })

UI_Elements.AutoClaimRewards = RewardsTab:Toggle({
    Title = "Auto Claim All Rewards",
    Desc = "Periodically collects Daily, Free Shop Car, Offline earnings, and Index Plates",
    Value = false,
    Callback = function(val)
        Settings.AutoClaimRewards = val
    end
})

RewardsTab:Button({
    Title = "Claim Free Shop Car",
    Desc = "Claims the complimentary vehicle from the premium shop",
    Callback = function()
        local ok, res = ProductService.ClaimFree():await()
        safeNotify({
            Title = "Free Shop Car",
            Content = (ok and res and res.Ok) and "Free car claimed successfully!" or "Already claimed or unavailable.",
            Duration = 3,
            Icon = "gift"
        })
    end
})

RewardsTab:Button({
    Title = "Claim Daily Reward",
    Desc = "Collects daily streak reward",
    Callback = function()
        local ok, res = CosmeticsService.ClaimDaily():await()
        safeNotify({
            Title = "Daily Reward",
            Content = (ok and res and res.Ok) and "Daily reward claimed!" or "Already claimed for today.",
            Duration = 3,
            Icon = "calendar"
        })
    end
})

RewardsTab:Button({
    Title = "Claim Offline Earnings",
    Desc = "Collects pending cash accumulated while offline",
    Callback = function()
        local ok, res = OfflineService.Claim():await()
        safeNotify({
            Title = "Offline Earnings",
            Content = (ok and res and res.Ok) and "Offline earnings collected!" or "No pending offline earnings.",
            Duration = 3,
            Icon = "dollar-sign"
        })
    end
})

RewardsTab:Button({
    Title = "Claim All Index Plates",
    Desc = "Checks all unlocked biome milestones and collects completed plates",
    Callback = function()
        local claimed = 0
        for i = 1, #GameConfig.Zones do
            local ok, res = IndexService.Claim(i):await()
            if ok and res and res.Ok then
                claimed = claimed + 1
            end
            task.wait(0.1)
        end
        safeNotify({
            Title = "Index Plates",
            Content = "Claimed " .. claimed .. " completed zone plates.",
            Duration = 3,
            Icon = "award"
        })
    end
})

-- ------------------------------------------
-- TAB 4: TELEPORTS
-- ------------------------------------------
local TeleportsTab = Window:Tab({
    Title = "Teleports",
    Icon = "map-pin"
})

TeleportsTab:Section({ Title = "Plot & Lobby Locations", Opened = true })

TeleportsTab:Button({
    Title = "Teleport to My Plot",
    Desc = "Transports character to the entrance of your plot",
    Callback = function()
        local plot = getMyPlot()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if plot and hrp then
            local ent = plot:FindFirstChild("Entrance")
            local pos = ent and ent.WorldPosition or (plot.Position + Vector3.new(0, 3, 0))
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end
})

TeleportsTab:Button({
    Title = "Teleport to Barbell Station",
    Callback = function()
        local plot = getMyPlot()
        local ts = plot and plot:FindFirstChild("TrainingSpot")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if ts and hrp then
            hrp.CFrame = ts.WorldCFrame + Vector3.new(0, 3, 0)
        end
    end
})

TeleportsTab:Button({
    Title = "Teleport to Upgrade Bar Button",
    Callback = function()
        local lpp = workspace:FindFirstChild("LocalPlotProps")
        local ub = lpp and lpp:FindFirstChild("UpgradeButton") and lpp.UpgradeButton:FindFirstChild("Pad")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if ub and hrp then
            hrp.CFrame = ub.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TeleportsTab:Button({
    Title = "Teleport to Fence Upgrade Sign",
    Callback = function()
        local lpp = workspace:FindFirstChild("LocalPlotProps")
        local fs = lpp and lpp:FindFirstChild("FenceSign") and lpp.FenceSign:FindFirstChild("Board")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if fs and hrp then
            hrp.CFrame = fs.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TeleportsTab:Button({
    Title = "Teleport to Throw Line (Starter Area)",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local starter = workspace:FindFirstChild("StarterArea")
        if starter and hrp then
            hrp.CFrame = CFrame.new(starter.Position + Vector3.new(0, starter.Size.Y / 2 + 3, 0))
        end
    end
})

TeleportsTab:Button({
    Title = "Teleport to Sell Area",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local sell = workspace:FindFirstChild("SellPlace")
        if sell and hrp then
            hrp.CFrame = sell:GetPivot() + Vector3.new(0, 3, 0)
        end
    end
})

TeleportsTab:Section({ Title = "Biome / Zone Teleports", Opened = true })

local biomeNames = {
    "Forest", "Savana", "Desert", "Jungle", "Ocean",
    "Mountains", "Taiga", "Winter", "PrehistoricForest",
    "DeepWaters", "Hell", "AncientRuins", "MythicalParadise",
    "ShadowRealm", "HarvestFields"
}
local selectedBiome = biomeNames[1]

TeleportsTab:Dropdown({
    Title = "Select Biome Destination",
    Values = biomeNames,
    Value = selectedBiome,
    Callback = function(val)
        selectedBiome = val
    end
})

TeleportsTab:Button({
    Title = "Teleport to Selected Biome",
    Callback = function()
        local biomes = workspace:FindFirstChild("Biomes")
        local target = biomes and biomes:FindFirstChild(selectedBiome)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if target and hrp then
            hrp.CFrame = target:GetPivot() + Vector3.new(0, 4, 0)
        end
    end
})

-- ------------------------------------------
-- TAB 5: PLAYER & MOVEMENT
-- ------------------------------------------
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user"
})

PlayerTab:Section({ Title = "AFK & Session Protection", Opened = true })

UI_Elements.AntiAFK = PlayerTab:Toggle({
    Title = "Anti-AFK (Hardware Input Pulse)",
    Desc = "Prevents 20-min idle kicks via VirtualInputManager hardware mouse & key pulses",
    Value = Settings.AntiAFK,
    Callback = function(val)
        Settings.AntiAFK = val
        updateAntiAFK(val)
        if val then
            safeNotify({
                Title = "Anti-AFK",
                Content = "Hardware-level Anti-AFK protection active.",
                Duration = 3,
                Icon = "shield-check"
            })
        end
    end
})

UI_Elements.AutoReconnect = PlayerTab:Toggle({
    Title = "Auto Reconnect on Disconnect",
    Desc = "Instantly rejoins the game if disconnected or idle kicked",
    Value = Settings.AutoReconnect,
    Callback = function(val)
        Settings.AutoReconnect = val
        updateAutoReconnect(val)
        if val then
            safeNotify({
                Title = "Auto Reconnect",
                Content = "Auto Reconnect listener active.",
                Duration = 3,
                Icon = "refresh-cw"
            })
        end
    end
})

PlayerTab:Button({
    Title = "Trigger Anti-AFK Pulse Now",
    Desc = "Sends an immediate simulated hardware input to reset Roblox idle timer",
    Callback = function()
        dispatchAntiAFKPulse()
        safeNotify({
            Title = "Anti-AFK",
            Content = "Dispatched hardware input pulse successfully.",
            Duration = 2,
            Icon = "refresh-cw"
        })
    end
})

PlayerTab:Section({ Title = "Movement Enhancements", Opened = true })

UI_Elements.WalkSpeedEnabled = PlayerTab:Toggle({
    Title = "Enable Custom WalkSpeed",
    Value = false,
    Callback = function(val)
        Settings.WalkSpeedEnabled = val
        if not val and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 20 end
        end
    end
})

PlayerTab:Slider({
    Title = "WalkSpeed Multiplier",
    Value = {
        Min = 16,
        Max = 150,
        Default = 20
    },
    Step = 1,
    Callback = function(val)
        Settings.WalkSpeedValue = val
    end
})

UI_Elements.JumpPowerEnabled = PlayerTab:Toggle({
    Title = "Enable Custom JumpPower",
    Value = false,
    Callback = function(val)
        Settings.JumpPowerEnabled = val
        if not val and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
})

PlayerTab:Slider({
    Title = "JumpPower Multiplier",
    Value = {
        Min = 50,
        Max = 250,
        Default = 50
    },
    Step = 5,
    Callback = function(val)
        Settings.JumpPowerValue = val
    end
})

UI_Elements.Noclip = PlayerTab:Toggle({
    Title = "Noclip (Walk Through Walls)",
    Value = false,
    Callback = function(val)
        Settings.Noclip = val
    end
})

UI_Elements.InfiniteJump = PlayerTab:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(val)
        Settings.InfiniteJump = val
    end
})

-- ------------------------------------------
-- TAB 6: CONFIG & SETTINGS
-- ------------------------------------------
local ConfigTab = Window:Tab({
    Title = "Configuration",
    Icon = "settings"
})

ConfigTab:Section({ Title = "Profile Management", Opened = true })

local configInputName = "default"

ConfigTab:Input({
    Title = "Profile Name",
    Default = "default",
    Callback = function(val)
        if val and val ~= "" then
            configInputName = val
        end
    end
})

ConfigTab:Button({
    Title = "Save Current Profile",
    Desc = "Saves active toggle states and slider values to disk",
    Callback = function()
        saveConfigFile(configInputName)
    end
})

ConfigTab:Button({
    Title = "Load Saved Profile",
    Desc = "Applies stored toggle states and slider values",
    Callback = function()
        loadConfigFile(configInputName)
    end
})

UI_Elements.AutoLoadConfig = ConfigTab:Toggle({
    Title = "Auto-Load Profile on Launch",
    Desc = "Automatically applies the specified config profile on startup",
    Value = false,
    Callback = function(val)
        Settings.AutoLoadConfig = val
        local autoLoadFile = ConfigFolder .. "/autoload.txt"
        if val then
            writefile(autoLoadFile, configInputName)
        else
            if isfile(autoLoadFile) then
                delfile(autoLoadFile)
            end
        end
    end
})

ConfigTab:Button({
    Title = "Reset All Toggles to Default (OFF)",
    Desc = "Turns off all automated loops immediately",
    Callback = function()
        for k, v in pairs(UI_Elements) do
            if v and v.Set then
                pcall(function() v:Set(false) end)
            end
        end
        Settings.AutoThrow = false
        Settings.AutoTrain = false
        Settings.AutoBonus = false
        Settings.AutoUpgradeBar = false
        Settings.AutoUpgradeFence = false
        Settings.AutoBuyKey = false
        Settings.AutoEquipKey = false
        Settings.AutoEquipBestCars = false
        Settings.AutoPlaceCars = false
        Settings.AutoSellDuplicates = false
        Settings.AutoSellCommon = false
        Settings.AutoSellUncommon = false
        Settings.AutoSellLowestWhenFull = false
        Settings.AutoClaimRewards = false
        Settings.AntiAFK = false
        updateAntiAFK(false)
        Settings.WalkSpeedEnabled = false
        Settings.JumpPowerEnabled = false
        Settings.Noclip = false
        Settings.InfiniteJump = false
        
        safeNotify({
            Title = "Reset",
            Content = "All automation toggles are now OFF.",
            Duration = 3,
            Icon = "power"
        })
    end
})

-- Check for Auto-Load file
task.spawn(function()
    local autoLoadFile = ConfigFolder .. "/autoload.txt"
    if isfile(autoLoadFile) then
        local savedName = readfile(autoLoadFile)
        if savedName and savedName ~= "" then
            task.wait(1.5)
            loadConfigFile(savedName)
        end
    end
end)

pcall(function()
    FarmTab:Select()
end)

safeNotify({
    Title = "Loaded",
    Content = "Automation Suite initialized. Toggle menu with LeftCTRL or Floating Button.",
    Duration = 5,
    Icon = "check"
})
