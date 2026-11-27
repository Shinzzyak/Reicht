-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    STEAL A PC â UNIVERSAL AUTOMATION SUITE
    Game: [ð½] Steal a PC (vaultstudio)
    PlaceId: 135402322419238 | UniverseId: 10769563057
    Engine: Real MCP Architecture
    UI: WindUI (Universal English, Zero Watermark, Dark Acrylic Theme)
    ========================================================================
]]

-- Anti Double-Execution Guard
if getgenv().StealAPC_Loaded then
    if typeof(getgenv().StealAPC_Unload) == "function" then
        pcall(getgenv().StealAPC_Unload)
    end
end
getgenv().StealAPC_Loaded = true

-- Core Engine Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Game Architecture References
local SAP = ReplicatedStorage:WaitForChild("SAP")
local Remotes = SAP:WaitForChild("Remotes")
local SAPMap = Workspace:WaitForChild("SAPMap")
local Plots = SAPMap:WaitForChild("Plots")
local Hub = SAPMap:WaitForChild("Hub")
local SAPBoxes = Workspace:WaitForChild("SAPBoxes")

-- Remote References
local Remote_GetInventory = Remotes:WaitForChild("GetInventory")
local Remote_GetState = Remotes:WaitForChild("GetState")
local Remote_Place = Remotes:WaitForChild("Place")
local Remote_PickUp = Remotes:WaitForChild("PickUp")
local Remote_Sell = Remotes:WaitForChild("Sell")
local Remote_ClaimAllIndex = Remotes:WaitForChild("ClaimAllIndex")
local Remote_PenPanel = Remotes:WaitForChild("PenPanel")
local Remote_BuyRobux = Remotes:WaitForChild("BuyRobux")
local Remote_ClaimChest = Remotes:WaitForChild("ClaimChest")
local Remote_ChestFavorited = Remotes:WaitForChild("ChestFavorited")
local Remote_ClaimOffline = Remotes:WaitForChild("ClaimOffline")
local Remote_EquipWeapon = Remotes:WaitForChild("EquipWeapon")
local Remote_TrainingBubbleClicked = Remotes:WaitForChild("TrainingBubbleClicked")
local Remote_Treadmill = Remotes:WaitForChild("Treadmill")
local Remote_UpgradeTreadmill = Remotes:WaitForChild("UpgradeTreadmill")
local Remote_DropBox = Remotes:WaitForChild("DropBox")

-- Configuration & State Object (DEFAULT: ALL OFF)
local State = {
    -- Auto Steal & Delivery
    AutoSteal = false,
    TargetZone = "Any",
    RarityFilter = "Any",
    StealDelay = 0.35,
    AutoBank = false,
    AutoPlaceBoxes = false,
    AutoUnbox = false,
    AutoPlacePCs = false,

    -- Training
    AutoTreadmill = false,
    AutoPopBubbles = false,
    AutoUpgradeTreadmill = false,

    -- Base Management
    AutoUpgradePen = false,
    AutoSellLowTier = false,
    SellMaxRarity = "Common",
    AutoClaimRewards = false,

    -- Character & Movement
    WalkSpeedToggle = false,
    WalkSpeedValue = 16,
    InfiniteJump = false,
    Noclip = false,
    AntiRagdoll = false,
    AntiAfk = false
}

local CONFIG_FILE_NAME = "StealAPC_Config.json"

local function SaveConfiguration()
    if writefile then
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, State)
        if success then
            writefile(CONFIG_FILE_NAME, encoded)
        end
    end
end

local function LoadConfiguration()
    if readfile and isfile and isfile(CONFIG_FILE_NAME) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE_NAME))
        end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if State[k] ~= nil then
                    State[k] = v
                end
            end
        end
    end
end

-- Runtime Utilities
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetMyPlot()
    local plotIndex = LocalPlayer:GetAttribute("PlotIndex")
    if plotIndex then
        return Plots:FindFirstChild("Plot" .. tostring(plotIndex))
    end
    for _, plot in ipairs(Plots:GetChildren()) do
        local ownerId = plot:GetAttribute("OwnerId") or plot:GetAttribute("UserId")
        if ownerId == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

local function GetSafeZonePosition()
    local spawnPart = Hub:FindFirstChild("Spawn")
    if spawnPart then
        return spawnPart.Position + Vector3.new(0, 3, 0)
    end
    return Vector3.new(0, 3, 50)
end

local RecentlyPlacedSpots = {}
local function FindOpenPenSpot(plot)
    if not plot then return Vector2.new(0, 0) end
    local contents = plot:FindFirstChild("Contents")
    local occupied = {}
    if contents then
        for _, item in ipairs(contents:GetChildren()) do
            local px = item:GetAttribute("PX")
            local pz = item:GetAttribute("PZ")
            local fp = item:GetAttribute("Footprint") or 6
            if px and pz then
                table.insert(occupied, { X = px, Z = pz, R = fp })
            end
        end
    end

    -- Add recently placed spots (within last 6 seconds)
    local now = os.clock()
    for i = #RecentlyPlacedSpots, 1, -1 do
        local r = RecentlyPlacedSpots[i]
        if now - r.time > 6 then
            table.remove(RecentlyPlacedSpots, i)
        else
            table.insert(occupied, { X = r.X, Z = r.Z, R = 6 })
        end
    end

    -- Grid scan between -45 and 45 with step 12
    for x = -45, 45, 12 do
        for z = -45, 45, 12 do
            local valid = true
            for _, occ in ipairs(occupied) do
                local dist = math.sqrt((x - occ.X)^2 + (z - occ.Z)^2)
                if dist < (occ.R + 6) then
                    valid = false
                    break
                end
            end
            if valid then
                table.insert(RecentlyPlacedSpots, { X = x, Z = z, time = now })
                return Vector2.new(x, z)
            end
        end
    end
    local rx, rz = math.random(-35, 35), math.random(-35, 35)
    table.insert(RecentlyPlacedSpots, { X = rx, Z = rz, time = now })
    return Vector2.new(rx, rz)
end

-- Rarity Hierarchy Map
local RarityWeights = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Secret"] = 6,
    ["Divine"] = 7
}

local function FilterBox(box)
    if not box or not box:IsA("Model") then return false end
    local prompt = box:FindFirstChild("StealPrompt", true)
    if not prompt or not prompt.Enabled then return false end

    local zone = box:GetAttribute("Zone") or 1
    if State.TargetZone ~= "Any" then
        local targetNum = tonumber(string.match(State.TargetZone, "%d+"))
        if targetNum and zone ~= targetNum then
            return false
        end
    end

    local rarity = box:GetAttribute("Rarity") or "Common"
    if State.RarityFilter ~= "Any" and rarity ~= State.RarityFilter then
        return false
    end

    return true
end

local function FindTargetBox()
    local boxes = SAPBoxes:GetChildren()
    local hrp = GetHRP()
    if not hrp then return nil end

    local bestBox = nil
    local highestRarityWeight = -1
    local shortestDist = math.huge

    for _, box in ipairs(boxes) do
        if FilterBox(box) then
            local boxPos = box:GetPivot().Position
            local dist = (hrp.Position - boxPos).Magnitude
            local rarity = box:GetAttribute("Rarity") or "Common"
            local weight = RarityWeights[rarity] or 1

            if State.RarityFilter == "Any" then
                if weight > highestRarityWeight then
                    highestRarityWeight = weight
                    shortestDist = dist
                    bestBox = box
                elseif weight == highestRarityWeight and dist < shortestDist then
                    shortestDist = dist
                    bestBox = box
                end
            else
                if dist < shortestDist then
                    shortestDist = dist
                    bestBox = box
                end
            end
        end
    end
    return bestBox
end

-- Load WindUI Library
local WindUISrc = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
local WindUI = loadstring(WindUISrc)()

local Window = WindUI:CreateWindow({
    Title = "Steal a PC",
    Author = "Universal Automation",
    Folder = "StealAPC_Data",
    Size = UDim2.fromOffset(590, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 175,
    HasOutline = true
})

-- TABS
local TabFarm = Window:Tab({ Title = "Auto Farm", Icon = "box" })
local TabTraining = Window:Tab({ Title = "Training", Icon = "zap" })
local TabBase = Window:Tab({ Title = "Base & Pen", Icon = "home" })
local TabTeleports = Window:Tab({ Title = "Teleports", Icon = "navigation" })
local TabMovement = Window:Tab({ Title = "Character", Icon = "user" })
local TabConfig = Window:Tab({ Title = "Settings", Icon = "settings" })

-- TAB 1: AUTO FARM
TabFarm:Section({ Title = "Steal & Delivery Pipeline" })

TabFarm:Toggle({
    Title = "Auto Steal Boxes",
    Default = false,
    Callback = function(val)
        State.AutoSteal = val
    end
})

local ZoneOptions = {"Any"}
for i = 1, 25 do
    table.insert(ZoneOptions, "Zone " .. i)
end

TabFarm:Dropdown({
    Title = "Target Zone",
    Values = ZoneOptions,
    Value = "Any",
    Multi = false,
    Callback = function(val)
        State.TargetZone = val
    end
})

TabFarm:Dropdown({
    Title = "Rarity Filter",
    Values = {"Any", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Secret", "Divine"},
    Value = "Any",
    Multi = false,
    Callback = function(val)
        State.RarityFilter = val
    end
})

TabFarm:Slider({
    Title = "Steal Delay (Seconds)",
    Step = 0.05,
    Value = { Min = 0.2, Max = 1.0, Default = 0.35 },
    Callback = function(val)
        State.StealDelay = val
    end
})

TabFarm:Toggle({
    Title = "Auto Bank (Return to Safe Zone)",
    Default = false,
    Callback = function(val)
        State.AutoBank = val
    end
})

TabFarm:Section({ Title = "Pen Placement & Hatching" })

TabFarm:Toggle({
    Title = "Auto Place Stolen Boxes",
    Default = false,
    Callback = function(val)
        State.AutoPlaceBoxes = val
    end
})

TabFarm:Toggle({
    Title = "Auto Unbox (Hatch Ready Boxes)",
    Default = false,
    Callback = function(val)
        State.AutoUnbox = val
    end
})

TabFarm:Toggle({
    Title = "Auto Place Hatched PCs",
    Default = false,
    Callback = function(val)
        State.AutoPlacePCs = val
    end
})

TabFarm:Button({
    Title = "Drop Carried Box Now",
    Callback = function()
        pcall(function()
            Remote_DropBox:InvokeServer()
        end)
    end
})

-- TAB 2: TRAINING & SPEED
TabTraining:Section({ Title = "Treadmill Operations" })

TabTraining:Toggle({
    Title = "Auto Mount Treadmill",
    Default = false,
    Callback = function(val)
        State.AutoTreadmill = val
    end
})

TabTraining:Toggle({
    Title = "Auto Pop Speed Bubbles",
    Default = false,
    Callback = function(val)
        State.AutoPopBubbles = val
    end
})

TabTraining:Toggle({
    Title = "Auto Upgrade Treadmill (Cash)",
    Default = false,
    Callback = function(val)
        State.AutoUpgradeTreadmill = val
    end
})

-- TAB 3: BASE & PEN MANAGEMENT
TabBase:Section({ Title = "Pen Infrastructure" })

TabBase:Toggle({
    Title = "Auto Upgrade Pen Slots",
    Default = false,
    Callback = function(val)
        State.AutoUpgradePen = val
    end
})

TabBase:Toggle({
    Title = "Auto Sell Low Tier PCs",
    Default = false,
    Callback = function(val)
        State.AutoSellLowTier = val
    end
})

TabBase:Dropdown({
    Title = "Auto Sell Max Rarity",
    Values = {"Common", "Uncommon", "Rare"},
    Value = "Common",
    Multi = false,
    Callback = function(val)
        State.SellMaxRarity = val
    end
})

TabBase:Button({
    Title = "Sell All Common PCs Now",
    Callback = function()
        task.spawn(function()
            local success, inv = pcall(function() return Remote_GetInventory:InvokeServer() end)
            if success and type(inv) == "table" then
                local keysToSell = {}
                for _, item in ipairs(inv) do
                    if item.T == "item" and item.Rarity == "Common" then
                        table.insert(keysToSell, item.Slot or item.Key)
                    end
                end
                if #keysToSell > 0 then
                    local soldAmount = Remote_Sell:InvokeServer(keysToSell)
                    WindUI:Notify({ Title = "Sold PCs", Content = "Sold " .. #keysToSell .. " Common PCs!", Duration = 3 })
                else
                    WindUI:Notify({ Title = "Sell", Content = "No Common PCs found.", Duration = 2 })
                end
            end
        end)
    end
})

TabBase:Button({
    Title = "Upgrade Pen Capacity Now",
    Callback = function()
        task.spawn(function()
            local plot = GetMyPlot()
            local hrp = GetHRP()
            if not plot or not hrp then return end
            local upSign = plot:FindFirstChild("UpgradeSign")
            local prompt = upSign and upSign:FindFirstChild("UpgradePrompt", true)
            local board = upSign and (upSign:FindFirstChild("Board") or upSign:FindFirstChild("Post"))
            if prompt and board then
                local oldPos = hrp.Position
                local signPos = board.Position
                hrp.CFrame = CFrame.lookAt(signPos + Vector3.new(0, 0, 4), signPos)
                task.wait(0.2)
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                end
                task.wait(0.3)
                hrp.CFrame = CFrame.new(oldPos)
                WindUI:Notify({ Title = "Pen Upgrade", Content = "Triggered pen upgrade at board.", Duration = 2.5 })
            end
        end)
    end
})

TabBase:Section({ Title = "Reward Collection" })

TabBase:Toggle({
    Title = "Auto Claim All Free Rewards",
    Default = false,
    Callback = function(val)
        State.AutoClaimRewards = val
    end
})

TabBase:Button({
    Title = "Claim All Discovered Index Rewards",
    Callback = function()
        task.spawn(function()
            local s = pcall(function() return Remote_ClaimAllIndex:InvokeServer() end)
            if s then
                WindUI:Notify({ Title = "Index Claim", Content = "Discovered index rewards claimed!", Duration = 2.5 })
            end
        end)
    end
})

-- TAB 4: TELEPORTS
TabTeleports:Section({ Title = "Safe Havens" })

TabTeleports:Button({
    Title = "Teleport to My Base",
    Callback = function()
        local plot = GetMyPlot()
        local hrp = GetHRP()
        if plot and hrp and plot:FindFirstChild("Floor") then
            hrp.CFrame = plot.Floor.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TabTeleports:Button({
    Title = "Teleport to Safe Zone (Hub)",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(GetSafeZonePosition())
        end
    end
})

TabTeleports:Button({
    Title = "Teleport to My Treadmill",
    Callback = function()
        local plot = GetMyPlot()
        local hrp = GetHRP()
        if plot and hrp and plot:FindFirstChild("TreadmillSpot") then
            hrp.CFrame = CFrame.new(plot.TreadmillSpot.Position + Vector3.new(0, 1.5, 0))
        end
    end
})

TabTeleports:Section({ Title = "Zone Waypoints" })

local SelectedTeleportZone = "Zone 1"
TabTeleports:Dropdown({
    Title = "Select Zone Waypoint",
    Values = (function()
        local z = {}
        for i = 1, 25 do table.insert(z, "Zone " .. i) end
        return z
    end)(),
    Value = "Zone 1",
    Multi = false,
    Callback = function(val)
        SelectedTeleportZone = val
    end
})

TabTeleports:Button({
    Title = "Teleport to Selected Zone",
    Callback = function()
        local zones = SAPMap:FindFirstChild("Zones")
        local hrp = GetHRP()
        if zones and hrp then
            local zNum = string.match(SelectedTeleportZone, "%d+")
            local targetZoneModel = zones:FindFirstChild("Zone" .. zNum)
            if targetZoneModel then
                local piv = targetZoneModel:GetPivot().Position
                hrp.CFrame = CFrame.new(piv.X, 3, piv.Z)
            end
        end
    end
})

-- TAB 5: CHARACTER & MOVEMENT
TabMovement:Section({ Title = "Movement Enhancements" })

TabMovement:Toggle({
    Title = "Enable Custom WalkSpeed",
    Default = false,
    Callback = function(val)
        State.WalkSpeedToggle = val
        if not val then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Step = 1,
    Value = { Min = 16, Max = 250, Default = 50 },
    Callback = function(val)
        State.WalkSpeedValue = val
    end
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(val)
        State.InfiniteJump = val
    end
})

TabMovement:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(val)
        State.Noclip = val
    end
})

TabMovement:Toggle({
    Title = "Anti-Ragdoll",
    Default = false,
    Callback = function(val)
        State.AntiRagdoll = val
    end
})

TabMovement:Toggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(val)
        State.AntiAfk = val
    end
})

-- TAB 6: SETTINGS & CONFIG
TabConfig:Section({ Title = "Profile Management" })

TabConfig:Button({
    Title = "Save Configuration",
    Callback = function()
        SaveConfiguration()
        WindUI:Notify({ Title = "Config", Content = "Configuration saved successfully.", Duration = 2.5 })
    end
})

TabConfig:Button({
    Title = "Load Configuration",
    Callback = function()
        LoadConfiguration()
        WindUI:Notify({ Title = "Config", Content = "Configuration loaded.", Duration = 2.5 })
    end
})

TabConfig:Button({
    Title = "Reset to Default (ALL OFF)",
    Callback = function()
        for k in pairs(State) do
            if type(State[k]) == "boolean" then
                State[k] = false
            end
        end
        WindUI:Notify({ Title = "Reset", Content = "All features reset to OFF.", Duration = 2.5 })
    end
})

TabConfig:Paragraph({
    Title = "Controls & Shortcuts",
    Desc = "Press [Left Control] or tap the floating button to toggle the window interface."
})

-- Floating Action Button (Toggle UI)
local ScreenGuiFloating = Instance.new("ScreenGui")
ScreenGuiFloating.Name = "StealAPC_FloatingToggle"
ScreenGuiFloating.ResetOnSpawn = false
ScreenGuiFloating.Parent = PlayerGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatButton"
FloatBtn.Size = UDim2.fromOffset(46, 46)
FloatBtn.Position = UDim2.new(0, 18, 0.5, -23)
FloatBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
FloatBtn.Text = "PC"
FloatBtn.TextColor3 = Color3.fromRGB(80, 220, 255)
FloatBtn.TextSize = 16
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGuiFloating

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 23)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Thickness = 2
FloatStroke.Color = Color3.fromRGB(45, 140, 255)
FloatStroke.Parent = FloatBtn

-- Dragging logic for Floating Button
local dragging, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

FloatBtn.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

-- Keybind Toggle: Left Control
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        Window:Toggle()
    end
end)

-- ========================================================================
-- BACKGROUND AUTOMATION ROUTINES
-- ========================================================================

-- Routine 1: Auto Steal & Auto Bank Loop
task.spawn(function()
    while true do
        task.wait(0.25)
        if State.AutoSteal then
            local hrp = GetHRP()
            local carrying = LocalPlayer:GetAttribute("Carrying")

            if not carrying and hrp then
                local targetBox = FindTargetBox()
                if targetBox and targetBox:FindFirstChild("StealPrompt", true) then
                    local prompt = targetBox:FindFirstChild("StealPrompt", true)
                    local rootPart = targetBox:FindFirstChild("Root") or targetBox.PrimaryPart
                    local boxPos = rootPart and rootPart.Position or targetBox:GetPivot().Position

                    -- Reposition directly adjacent to box
                    hrp.CFrame = CFrame.lookAt(boxPos + Vector3.new(0, 1.2, 2.5), boxPos)
                    task.wait(0.15)

                    -- Simulate E key hold
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(prompt.HoldDuration + State.StealDelay)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.2)
                end
            elseif carrying and State.AutoBank and hrp then
                -- Deliver box to Safe Zone
                hrp.CFrame = CFrame.new(GetSafeZonePosition())
                local startBank = os.clock()
                while LocalPlayer:GetAttribute("Carrying") and (os.clock() - startBank < 3) do
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- Routine 2: Auto Place Boxes into Pen
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoPlaceBoxes then
            local plot = GetMyPlot()
            if plot then
                local success, inv = pcall(function() return Remote_GetInventory:InvokeServer() end)
                if success and type(inv) == "table" then
                    for _, entry in ipairs(inv) do
                        if entry.T == "box" and not entry.Placed then
                            local spot = FindOpenPenSpot(plot)
                            pcall(function()
                                Remote_Place:InvokeServer(entry.Slot or entry.Key, spot.X, spot.Y, 0)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

-- Routine 3: Auto Unbox (Hatch ready boxes)
task.spawn(function()
    while true do
        task.wait(1.0)
        if State.AutoUnbox then
            local success, penData = pcall(function() return Remote_PenPanel:InvokeServer("get") end)
            if success and type(penData) == "table" and type(penData.Placed) == "table" then
                for _, item in ipairs(penData.Placed) do
                    if item.T == "box" and (tonumber(item.Left) or 0) <= 0 then
                        pcall(function()
                            Remote_PenPanel:InvokeServer("unbox", item.Key)
                        end)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end)

-- Routine 4: Auto Place Hatched PCs
task.spawn(function()
    while true do
        task.wait(2.0)
        if State.AutoPlacePCs then
            local plot = GetMyPlot()
            if plot then
                local success, inv = pcall(function() return Remote_GetInventory:InvokeServer() end)
                if success and type(inv) == "table" then
                    for _, entry in ipairs(inv) do
                        if entry.T == "item" and not entry.Placed then
                            local spot = FindOpenPenSpot(plot)
                            pcall(function()
                                Remote_Place:InvokeServer(entry.Slot or entry.Key, spot.X, spot.Y, 0)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

-- Routine 5: Treadmill & Bubble Auto-Farm
task.spawn(function()
    while true do
        task.wait(0.15)
        local hrp = GetHRP()

        -- Auto Pop Speed Bubbles
        if State.AutoPopBubbles then
            local tb = LocalPlayer:FindFirstChild("TrainingBubbles")
            if tb then
                for _, bubble in ipairs(tb:GetChildren()) do
                    pcall(function()
                        Remote_TrainingBubbleClicked:FireServer(bubble)
                    end)
                end
            end
        end

        -- Auto Mount Treadmill
        if State.AutoTreadmill and hrp then
            local onTread = LocalPlayer:GetAttribute("OnTreadmill")
            if not onTread then
                local plot = GetMyPlot()
                if plot and plot:FindFirstChild("TreadmillSpot") then
                    local spot = plot.TreadmillSpot.Position
                    if (hrp.Position - spot).Magnitude > 4 then
                        hrp.CFrame = CFrame.new(spot + Vector3.new(0, 1.5, 0))
                    end
                end
            end
        end
    end
end)

-- Routine 6: Auto Upgrades (Pen Slots & Treadmill)
task.spawn(function()
    while true do
        task.wait(2.0)
        local plot = GetMyPlot()
        if plot then
            -- Treadmill Upgrade via Direct Server Remote
            if State.AutoUpgradeTreadmill then
                pcall(function()
                    Remote_UpgradeTreadmill:InvokeServer()
                end)
            end

            -- Pen Upgrade
            if State.AutoUpgradePen then
                local upSign = plot:FindFirstChild("UpgradeSign")
                local prompt = upSign and upSign:FindFirstChild("UpgradePrompt", true)
                local board = upSign and (upSign:FindFirstChild("Board") or upSign:FindFirstChild("Post"))
                local hrp = GetHRP()
                if prompt and prompt.Enabled and hrp and board then
                    local signPos = board.Position
                    if (hrp.Position - signPos).Magnitude <= 20 and fireproximityprompt then
                        pcall(function()
                            fireproximityprompt(prompt, 0)
                        end)
                    end
                end
            end
        end
    end
end)

-- Routine 7: Auto Sell Low Tier PCs
task.spawn(function()
    while true do
        task.wait(4.0)
        if State.AutoSellLowTier then
            local success, inv = pcall(function() return Remote_GetInventory:InvokeServer() end)
            if success and type(inv) == "table" then
                local maxAllowedWeight = RarityWeights[State.SellMaxRarity] or 1
                local sellKeys = {}
                for _, item in ipairs(inv) do
                    if item.T == "item" then
                        local weight = RarityWeights[item.Rarity] or 1
                        if weight <= maxAllowedWeight then
                            table.insert(sellKeys, item.Slot or item.Key)
                        end
                    end
                end
                if #sellKeys > 0 then
                    pcall(function()
                        Remote_Sell:InvokeServer(sellKeys)
                    end)
                end
            end
        end
    end
end)

-- Routine 8: Auto Claim Free Rewards
task.spawn(function()
    while true do
        task.wait(10.0)
        if State.AutoClaimRewards then
            pcall(function() Remote_ClaimAllIndex:InvokeServer() end)
            pcall(function() Remote_BuyRobux:InvokeServer("FreeSpeed") end)
            pcall(function() Remote_ChestFavorited:InvokeServer() end)
            pcall(function() Remote_ClaimChest:InvokeServer() end)
            pcall(function() Remote_ClaimOffline:InvokeServer(false) end)
        end
    end
end)

-- Routine 9: Character Physics (WalkSpeed, Noclip, Infinite Jump, Anti-Ragdoll)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip
    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- WalkSpeed
    if State.WalkSpeedToggle then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= State.WalkSpeedValue then
            hum.WalkSpeed = State.WalkSpeedValue
        end
    end

    -- Anti-Ragdoll
    if State.AntiRagdoll then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum.AutoRotate = true
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end)

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti-AFK Routine
LocalPlayer.Idled:Connect(function()
    if State.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(120)
        if State.AntiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- Cleanup Handler
getgenv().StealAPC_Unload = function()
    ScreenGuiFloating:Destroy()
    Window:Destroy()
    getgenv().StealAPC_Loaded = nil
    getgenv().StealAPC_Unload = nil
end

WindUI:Notify({
    Title = "Steal a PC",
    Content = "Elite Automation initialized. Default state: ALL OFF.",
    Duration = 4
})
