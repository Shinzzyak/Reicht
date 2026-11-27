-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    +1 Drain Water for Treasure â Master Automation Suite
    Architecture: WindUI Framework
    Game: [W4] +1 Drain Water for Treasure (PlaceId: 129172691103247)
    Author: Universal Operations
    All settings default to OFF upon execution.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local ConfigFolder = ReplicatedStorage:WaitForChild("Config", 15)

if not Remotes then
    warn("[-] Remotes directory not found in ReplicatedStorage.")
    return
end

-- Config module reference
local ZoneConfigModule = nil
pcall(function()
    ZoneConfigModule = require(ConfigFolder:WaitForChild("ZoneConfig", 10))
end)

-- Remote references
local RemoteClick = Remotes:WaitForChild("Click", 5)
local RemoteSell = Remotes:WaitForChild("Sell", 5)
local RemoteBuyUpgrade = Remotes:WaitForChild("BuyUpgrade", 5)
local RemoteBuyPump = Remotes:WaitForChild("BuyPump", 5)
local RemoteEquipPump = Remotes:WaitForChild("EquipPump", 5)
local RemoteRebirth = Remotes:WaitForChild("Rebirth", 5)
local RemoteSpinAura = Remotes:WaitForChild("SpinAura", 5)
local RemoteAuraSlot = Remotes:WaitForChild("AuraSlot", 5)
local RemoteOpenEgg = Remotes:WaitForChild("OpenEgg", 5)
local RemotePetAction = Remotes:WaitForChild("PetAction", 5)
local RemoteClaimDaily = Remotes:WaitForChild("ClaimDaily", 5)
local RemoteClaimPlaytime = Remotes:WaitForChild("ClaimPlaytime", 5)
local RemoteClaimOffline = Remotes:WaitForChild("ClaimOffline", 5)
local RemoteClaimGroupReward = Remotes:WaitForChild("ClaimGroupReward", 5)
local RemoteOpenPresent = Remotes:WaitForChild("OpenPresent", 5)
local RemoteBossClick = Remotes:WaitForChild("BossClick", 5)
local RemoteTeleport = Remotes:WaitForChild("Teleport", 5)
local RemoteTravelWorld = Remotes:WaitForChild("TravelWorld", 5)
local RemoteRedeemCode = Remotes:WaitForChild("RedeemCode", 5)
local RemotePickup = Remotes:WaitForChild("Pickup", 5)

-- Configuration & State Store
local State = {
    -- Auto Farm & Magnet
    FastWater = false,
    FastWaterDelay = 0.05,
    AutoSell = false,
    AutoSellThreshold = 1,
    AutoVacuumTreasures = false,
    VacuumSpeed = 0.03,
    VacuumLoopInterval = 0.4,
    NativeAutoDrain = false,
    TargetDrainZone = 1,
    AutoAfkPool = false,
    SelectedPool = "Auto Best Unlocked",

    -- Upgrades & Progression
    AutoUpgradeBackpack = false,
    AutoUpgradeSpeed = false,
    AutoUpgradeLuck = false,
    AutoBuyPump = false,
    AutoEquipPump = false,
    AutoRebirth = false,

    -- Eggs & Pets
    AutoOpenEgg = false,
    SelectedEgg = "MeadowEgg",
    HatchAmount = 1,
    AutoEquipBestPets = false,

    -- Auras & Events
    AutoSpinAuraMoney = false,
    AutoSpinAuraFree = false,
    AuraSpinDelay = 0.35,
    AuraStopTarget = "Rank 6+ (Abyss / Mythic+)",
    AutoStoreTargetAura = false,
    AutoEquipBestAura = false,
    AutoUnlockAuraSlots = false,
    AutoBossDps = false,
    AutoOpenPresents = false,

    -- Rewards
    AutoClaimDaily = false,
    AutoClaimPlaytime = false,
    AutoClaimOffline = false,
    AutoClaimGroup = false,

    -- Utility
    WalkSpeedValue = 16,
    CustomSpeedEnabled = false,
    JumpPowerValue = 50,
    CustomJumpEnabled = false,
    Noclip = false,
    InfiniteJump = false,
}

-- Config System Storage
local ConfigFolderDir = "DrainWaterAutomation"
local ConfigFilePath = ConfigFolderDir .. "/config.json"

local function SaveConfig()
    pcall(function()
        if not isfolder(ConfigFolderDir) then
            makefolder(ConfigFolderDir)
        end
        writefile(ConfigFilePath, HttpService:JSONEncode(State))
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile(ConfigFilePath) then
            local data = HttpService:JSONDecode(readfile(ConfigFilePath))
            for k, v in pairs(data) do
                if State[k] ~= nil then
                    State[k] = v
                end
            end
        end
    end)
end

-- Load WindUI Library
local WindUI = nil
local function loadWindUI()
    if not _G.WindUISource then
        local sources = {
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
            "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        }
        for _, url in ipairs(sources) do
            local ok, res = pcall(function() return game:HttpGet(url, true) end)
            if ok and typeof(res) == "string" and #res > 500 then
                _G.WindUISource = res
                break
            end
        end
    end
    if _G.WindUISource then
        local loader, err = loadstring(_G.WindUISource)
        if loader then
            local ok, lib = pcall(loader)
            if ok and lib then
                WindUI = lib
                return true
            end
        end
    end
    return false
end

if not loadWindUI() then
    warn("[-] Failed to load WindUI engine.")
    return
end

-- Clean previous instances
if _G.DrainWaterWindow then
    pcall(function() _G.DrainWaterWindow:Destroy() end)
    _G.DrainWaterWindow = nil
end
if _G.DrainWaterFloatGui then
    pcall(function() _G.DrainWaterFloatGui:Destroy() end)
    _G.DrainWaterFloatGui = nil
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "+1 Drain Water for Treasure",
    Icon = "droplet",
    Author = "Universal Operations",
    Folder = "DrainWaterHub",
    Size = UDim2.fromOffset(620, 520),
    Theme = "Dark",
})
_G.DrainWaterWindow = Window

-- Floating Button (Draggable & Accessible)
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "DrainWaterFloatGui"
FloatGui.ResetOnSpawn = false
pcall(function()
    FloatGui.Parent = CoreGui
end)
if not FloatGui.Parent then
    FloatGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
_G.DrainWaterFloatGui = FloatGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "ToggleWindowButton"
FloatBtn.Size = UDim2.new(0, 46, 0, 46)
FloatBtn.Position = UDim2.new(0, 18, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
FloatBtn.BorderSizePixel = 0
FloatBtn.Text = "ð"
FloatBtn.TextSize = 22
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Parent = FloatGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 12)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 170, 255)
FloatStroke.Thickness = 1.5
FloatStroke.Parent = FloatBtn

-- Dragging logic
local dragging, dragInput, dragStart, startPos
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

FloatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

FloatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if Window.Toggle then
            Window:Toggle()
        end
    end)
end)

-- LeftControl Keybind Show/Hide
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        pcall(function()
            if Window.Toggle then
                Window:Toggle()
            end
        end)
    end
end)

-- Character Helper
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Egg Coordinates Map
local EggLocations = {
    ["MeadowEgg"] = Vector3.new(13, 0.5, 70),
    ["ArcticEgg"] = Vector3.new(-13, 0.5, 70),
    ["JungleEgg"] = Vector3.new(0, 0.5, 73),
    ["CyberEgg"] = Vector3.new(26, 0.5, 64),
    ["LeviathanEgg"] = Vector3.new(-27, 0.5, 64),
}

-- Dynamic AFK Pool Resolvers
local function getPoolWaterPart(poolId)
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local targetName = "Pool" .. tostring(poolId)
    for _, lobby in ipairs(map:GetChildren()) do
        if lobby.Name:match("^Lobby") then
            local afkPools = lobby:FindFirstChild("AFKPools")
            if afkPools then
                local poolModel = afkPools:FindFirstChild(targetName)
                if poolModel then
                    for _, desc in ipairs(poolModel:GetDescendants()) do
                        if desc:IsA("BasePart") and desc.Name:match("Water") then
                            return desc
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function getBestUnlockedPoolId()
    local rebirths = LocalPlayer:GetAttribute("Rebirths") or 0
    local passesStr = LocalPlayer:GetAttribute("Passes") or "{}"
    local ok, passes = pcall(HttpService.JSONDecode, HttpService, passesStr)
    if not ok or type(passes) ~= "table" then passes = {} end

    local map = workspace:FindFirstChild("Map")
    if not map then return 1 end

    local availablePoolIds = {}
    for _, lobby in ipairs(map:GetChildren()) do
        if lobby.Name:match("^Lobby") then
            local afkPools = lobby:FindFirstChild("AFKPools")
            if afkPools then
                for _, child in ipairs(afkPools:GetChildren()) do
                    local num = tonumber(child.Name:match("%d+"))
                    if num then
                        availablePoolIds[num] = true
                    end
                end
            end
        end
    end

    local RS = game:GetService("ReplicatedStorage")
    local GameConfig = nil
    pcall(function() GameConfig = require(RS.Config.GameConfig) end)
    local poolDefs = (GameConfig and GameConfig.Pools) or {}

    local bestId = 1
    local bestClicks = 0

    for id, p in ipairs(poolDefs) do
        if availablePoolIds[id] then
            local canUse = false
            if p.premium then
                if passes["AfkPool" .. id] == true then
                    canUse = true
                end
            elseif p.rebirths then
                if rebirths >= p.rebirths then
                    canUse = true
                end
            else
                canUse = true
            end

            if canUse and (p.clicks or 0) > bestClicks then
                bestClicks = p.clicks
                bestId = id
            end
        end
    end
    return bestId
end

local function resolveTargetPoolId(selectedSetting)
    if not selectedSetting or selectedSetting == "Auto Best Unlocked" then
        return getBestUnlockedPoolId()
    end
    local num = tonumber(string.match(tostring(selectedSetting), "%d+"))
    return num or getBestUnlockedPoolId()
end

-- Aura Data & Helpers
local AURA_RANKS = {
    ["Mist"] = 1,
    ["Splash"] = 1,
    ["Bubble"] = 2,
    ["Coral"] = 2,
    ["Tidal"] = 3,
    ["Glacier"] = 3,
    ["Storm"] = 4,
    ["Lava"] = 5,
    ["Abyss"] = 6,
    ["Aurora"] = 7,
    ["Poseidon"] = 8,
    ["Tsunami"] = 9,
    ["Leviathan"] = 10,
}

local function getAuraRank(auraId)
    if not auraId or auraId == "" then return 0 end
    return AURA_RANKS[auraId] or 0
end

local function checkMeetsTarget(auraId, targetSetting)
    if not targetSetting or targetSetting == "Disabled (Continuous Spin)" then
        return false
    end
    local rank = getAuraRank(auraId)
    if targetSetting == "Rank 4+ (Storm and above)" then return rank >= 4 end
    if targetSetting == "Rank 5+ (Lava and above)" then return rank >= 5 end
    if targetSetting == "Rank 6+ (Abyss / Mythic+)" then return rank >= 6 end
    if targetSetting == "Rank 7+ (Aurora / Secret+)" then return rank >= 7 end
    if targetSetting == "Rank 8+ (Poseidon and above)" then return rank >= 8 end
    if targetSetting == "Rank 9+ (Tsunami and above)" then return rank >= 9 end
    if targetSetting == "Rank 10 (Leviathan - 1 in 1M)" then return rank >= 10 end

    local specific = string.match(targetSetting, "Specific:%s*(%a+)")
    if specific then
        return auraId == specific
    end
    return false
end

local function getBestOwnedAura()
    local equipped = LocalPlayer:GetAttribute("Aura") or ""
    local bestAura = equipped
    local bestRank = getAuraRank(equipped)
    local bestSlot = nil

    for slot = 1, 3 do
        local isOpen = (slot == 1) or (LocalPlayer:GetAttribute("AuraSlotOpen" .. slot) == true)
        if isOpen then
            local stored = LocalPlayer:GetAttribute("AuraSlot" .. slot) or ""
            local rank = getAuraRank(stored)
            if rank > bestRank then
                bestRank = rank
                bestAura = stored
                bestSlot = slot
            end
        end
    end
    return bestAura, bestRank, bestSlot
end

local function equipBestAura()
    local bestAura, bestRank, bestSlot = getBestOwnedAura()
    if bestSlot and RemoteAuraSlot then
        pcall(function()
            RemoteAuraSlot:InvokeServer(bestSlot)
        end)
        return true, bestAura
    end
    return false, bestAura
end

local function storeEquippedToSlot()
    if not RemoteAuraSlot then return false end
    local equipped = LocalPlayer:GetAttribute("Aura") or ""
    local equippedRank = getAuraRank(equipped)
    if equipped == "" then return false end

    -- Priority 1: First empty open slot
    for slot = 1, 3 do
        local isOpen = (slot == 1) or (LocalPlayer:GetAttribute("AuraSlotOpen" .. slot) == true)
        if isOpen then
            local stored = LocalPlayer:GetAttribute("AuraSlot" .. slot) or ""
            if stored == "" then
                local ok, res = pcall(function()
                    return RemoteAuraSlot:InvokeServer(slot)
                end)
                return ok and res
            end
        end
    end

    -- Priority 2: Replace lowest-rank stored aura if equipped is higher
    local lowestRank = 999
    local lowestSlot = nil
    for slot = 1, 3 do
        local isOpen = (slot == 1) or (LocalPlayer:GetAttribute("AuraSlotOpen" .. slot) == true)
        if isOpen then
            local stored = LocalPlayer:GetAttribute("AuraSlot" .. slot) or ""
            local sRank = getAuraRank(stored)
            if sRank < lowestRank and sRank < equippedRank then
                lowestRank = sRank
                lowestSlot = slot
            end
        end
    end

    if lowestSlot then
        local ok, res = pcall(function()
            return RemoteAuraSlot:InvokeServer(lowestSlot)
        end)
        return ok and res
    end

    return false
end

--------------------------------------------------------------------------------
-- TABS CREATION
--------------------------------------------------------------------------------
local TabFarm = Window:Tab({ Title = "Auto Farm", Icon = "flame" })
local TabProgression = Window:Tab({ Title = "Progression", Icon = "trending-up" })
local TabPets = Window:Tab({ Title = "Pets & Eggs", Icon = "egg" })
local TabAuraEvent = Window:Tab({ Title = "Auras & Events", Icon = "zap" })
local TabRewards = Window:Tab({ Title = "Rewards", Icon = "gift" })
local TabTeleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TabMisc = Window:Tab({ Title = "Movement & Misc", Icon = "activity" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

--------------------------------------------------------------------------------
-- 1. TAB: AUTO FARM & VACUUM MAGNET
--------------------------------------------------------------------------------
TabFarm:Section({ Title = "Autonomous Treasure Vacuum (Magnet)" })

TabFarm:Toggle({
    Title = "Auto Vacuum Treasures",
    Desc = "Sweeps all spawned treasures in milliseconds without trapping or locking your character.",
    Value = false,
    Callback = function(val)
        State.AutoVacuumTreasures = val
    end
})

TabFarm:Slider({
    Title = "Treasure Grab Delay (Seconds)",
    Desc = "Micro-interval between treasure grabs during autonomous sweep",
    Value = {
        Min = 0.01,
        Max = 0.2,
        Default = 0.03,
    },
    Step = 0.01,
    Callback = function(val)
        State.VacuumSpeed = val
    end
})

TabFarm:Slider({
    Title = "Vacuum Loop Interval (Seconds)",
    Desc = "Delay between lake sweeps for newly spawned treasures",
    Value = {
        Min = 0.1,
        Max = 2.0,
        Default = 0.4,
    },
    Step = 0.1,
    Callback = function(val)
        State.VacuumLoopInterval = val
    end
})

TabFarm:Button({
    Title = "Vacuum All Spawned Treasures (Instant)",
    Desc = "Manually triggers a single sweep of all active treasures across the lake.",
    Callback = function()
        task.spawn(function()
            local myLakes = workspace:FindFirstChild("MyLakes")
            local root = getRoot()
            local hum = getHumanoid()
            if not myLakes or not root then return end

            local targets = {}
            for _, model in ipairs(myLakes:GetChildren()) do
                if model:IsA("Model") then
                    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        table.insert(targets, { prompt = prompt, pos = model:GetPivot().Position })
                    end
                end
            end

            if #targets == 0 then
                WindUI:Notify({ Title = "Treasure Vacuum", Content = "No treasures currently spawned in the lake.", Duration = 2 })
                return
            end

            local originCFrame = root.CFrame

            for _, t in ipairs(targets) do
                -- Capacity check
                local bp = LocalPlayer:GetAttribute("Backpack") or "[]"
                local ok, items = pcall(HttpService.JSONDecode, HttpService, bp)
                local bpCount = (ok and type(items) == "table") and #items or 0
                local maxBp = LocalPlayer:GetAttribute("BackpackMax") or 7

                if bpCount >= maxBp and RemoteSell then
                    RemoteSell:InvokeServer("all")
                    task.wait(0.1)
                end

                t.prompt.RequiresLineOfSight = false
                t.prompt.HoldDuration = 0
                t.prompt.MaxActivationDistance = 999999

                root.CFrame = CFrame.new(t.pos + Vector3.new(0, 1.5, 0))
                task.wait(0.03)
                pcall(function() fireproximityprompt(t.prompt) end)
                task.wait(0.03)
            end

            root.CFrame = originCFrame
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            WindUI:Notify({ Title = "Treasure Vacuum", Content = "Collected " .. #targets .. " treasures!", Duration = 3 })
        end)
    end
})

TabFarm:Section({ Title = "Safe Lake Navigation & Auto Drain" })

TabFarm:Toggle({
    Title = "Game Official Auto Drain",
    Desc = "Enables the game's built-in smooth Auto Drain pathfinding engine (Zero bugs, 100% natural movement).",
    Value = false,
    Callback = function(val)
        State.NativeAutoDrain = val
        pcall(function()
            LocalPlayer:SetAttribute("AutoDrainOn", val)
            local tele = Remotes:FindFirstChild("Telemetry")
            if tele then
                tele:FireServer("autoDrain", val)
            end
        end)
    end
})

TabFarm:Slider({
    Title = "Select Zone to Teleport Dock",
    Value = {
        Min = 1,
        Max = 60,
        Default = 1,
    },
    Step = 1,
    Callback = function(val)
        State.TargetDrainZone = val
    end
})

TabFarm:Button({
    Title = "Teleport to Safe Zone Dock",
    Desc = "Teleports character onto the official wooden dock facing the lake (Never underground).",
    Callback = function()
        pcall(function()
            if RemoteTeleport then
                RemoteTeleport:InvokeServer(State.TargetDrainZone)
            end
        end)
    end
})

TabFarm:Section({ Title = "Fast Water Generation" })

TabFarm:Toggle({
    Title = "Fast Water Clicks",
    Desc = "Spams Click:FireServer() for massive water acquisition (Drives server drain speed)",
    Value = false,
    Callback = function(val)
        State.FastWater = val
    end
})

TabFarm:Slider({
    Title = "Click Delay (Seconds)",
    Desc = "Interval between water generation calls",
    Value = {
        Min = 0.01,
        Max = 0.5,
        Default = 0.05,
    },
    Step = 0.01,
    Callback = function(val)
        State.FastWaterDelay = val
    end
})

TabFarm:Section({ Title = "Automated Selling" })

TabFarm:Toggle({
    Title = "Auto Sell All Treasures",
    Desc = "Globally invokes Sell:InvokeServer('all') without proximity limits",
    Value = false,
    Callback = function(val)
        State.AutoSell = val
    end
})

TabFarm:Slider({
    Title = "Backpack Count Trigger",
    Desc = "Sell when backpack reaches this amount of treasures",
    Value = {
        Min = 1,
        Max = 30,
        Default = 1,
    },
    Step = 1,
    Callback = function(val)
        State.AutoSellThreshold = val
    end
})

TabFarm:Section({ Title = "AFK Pool Farm (Automatic Passive Water)" })

TabFarm:Toggle({
    Title = "Auto AFK Pool Farm",
    Desc = "Continuously anchors character inside the selected pool for non-stop passive water gains",
    Value = false,
    Callback = function(val)
        State.AutoAfkPool = val
        if val then
            task.spawn(function()
                local poolId = resolveTargetPoolId(State.SelectedPool)
                local water = getPoolWaterPart(poolId)
                local root = getRoot()
                local hum = getHumanoid()
                if water and root then
                    root.CFrame = CFrame.new(water.Position + Vector3.new(0, 2.5, 0))
                    if hum then
                        hum.PlatformStand = false
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    WindUI:Notify({
                        Title = "AFK Pool Active",
                        Content = "Anchored in Pool " .. tostring(poolId) .. ". Passive ticks engaged.",
                        Duration = 3,
                    })
                end
            end)
        end
    end
})

TabFarm:Dropdown({
    Title = "AFK Pool Tier",
    Desc = "Choose pool tier or let script pick the highest unlocked pool",
    Values = {
        "Auto Best Unlocked",
        "Pool 1 (1x - 0 Rebirths)",
        "Pool 2 (1.5x - 2 Rebirths)",
        "Pool 3 (2x - 4 Rebirths)",
        "Pool 4 (3x - 6 Rebirths)",
        "Pool 5 (4x - 8 Rebirths)",
        "Pool 6 (5x - 10 Rebirths)",
        "Pool 7 (100x - Royal Pass)",
        "Pool 8 (200x - Galaxy Pass)",
        "Pool 17 (1000x - Atlantis Pass)",
    },
    Value = "Auto Best Unlocked",
    Callback = function(val)
        State.SelectedPool = val
        if State.AutoAfkPool then
            local poolId = resolveTargetPoolId(val)
            local water = getPoolWaterPart(poolId)
            local root = getRoot()
            if water and root then
                root.CFrame = CFrame.new(water.Position + Vector3.new(0, 2.5, 0))
            end
        end
    end
})

TabFarm:Button({
    Title = "Teleport to Pool (Instant)",
    Desc = "Instantly warps into the selected AFK pool water",
    Callback = function()
        local poolId = resolveTargetPoolId(State.SelectedPool)
        local water = getPoolWaterPart(poolId)
        local root = getRoot()
        local hum = getHumanoid()
        if water and root then
            root.CFrame = CFrame.new(water.Position + Vector3.new(0, 2.5, 0))
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            WindUI:Notify({
                Title = "AFK Pool Teleport",
                Content = "Teleported inside Pool " .. tostring(poolId) .. "!",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Pool Not Found",
                Content = "Pool " .. tostring(poolId) .. " not found in current world lobby.",
                Duration = 3,
            })
        end
    end
})

--------------------------------------------------------------------------------
-- 2. TAB: PROGRESSION
--------------------------------------------------------------------------------
TabProgression:Section({ Title = "Upgrades Automation" })

TabProgression:Toggle({
    Title = "Auto Upgrade Backpack",
    Desc = "Purchases inventory expansion when funds are available",
    Value = false,
    Callback = function(val)
        State.AutoUpgradeBackpack = val
    end
})

TabProgression:Toggle({
    Title = "Auto Upgrade Walkspeed",
    Desc = "Purchases permanent speed upgrades",
    Value = false,
    Callback = function(val)
        State.AutoUpgradeSpeed = val
    end
})

TabProgression:Toggle({
    Title = "Auto Upgrade Luck",
    Desc = "Purchases permanent server luck upgrades",
    Value = false,
    Callback = function(val)
        State.AutoUpgradeLuck = val
    end
})

TabProgression:Section({ Title = "Pump & Rebirth Automation" })

TabProgression:Toggle({
    Title = "Auto Buy Next Pump",
    Desc = "Iterates and buys next tiered pump when affordable",
    Value = false,
    Callback = function(val)
        State.AutoBuyPump = val
    end
})

TabProgression:Toggle({
    Title = "Auto Equip Best Pump",
    Desc = "Automatically equips highest tier unlocked pump",
    Value = false,
    Callback = function(val)
        State.AutoEquipPump = val
    end
})

TabProgression:Toggle({
    Title = "Auto Rebirth",
    Desc = "Triggers Rebirth:InvokeServer() when level requirements are met",
    Value = false,
    Callback = function(val)
        State.AutoRebirth = val
    end
})

--------------------------------------------------------------------------------
-- 3. TAB: PETS & EGGS
--------------------------------------------------------------------------------
TabPets:Section({ Title = "Automated Egg Hatching" })

TabPets:Dropdown({
    Title = "Target Egg",
    Values = { "MeadowEgg", "ArcticEgg", "JungleEgg", "CyberEgg", "LeviathanEgg" },
    Value = "MeadowEgg",
    Callback = function(val)
        State.SelectedEgg = val
    end
})

TabPets:Dropdown({
    Title = "Hatch Quantity",
    Values = { "1x", "3x" },
    Value = "1x",
    Callback = function(val)
        State.HatchAmount = val == "3x" and 3 or 1
    end
})

TabPets:Toggle({
    Title = "Auto Open Selected Egg",
    Desc = "Anchors player within activation radius and opens eggs",
    Value = false,
    Callback = function(val)
        State.AutoOpenEgg = val
    end
})

TabPets:Section({ Title = "Pet Inventory Operations" })

TabPets:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Constantly maintains optimal pet loadout",
    Value = false,
    Callback = function(val)
        State.AutoEquipBestPets = val
    end
})

TabPets:Button({
    Title = "Equip Best Pets (Instant)",
    Desc = "Manually invokes PetAction EquipBest once",
    Callback = function()
        pcall(function()
            if RemotePetAction then
                RemotePetAction:InvokeServer("EquipBest", nil)
            end
        end)
    end
})

--------------------------------------------------------------------------------
-- 4. TAB: AURAS & EVENTS
--------------------------------------------------------------------------------
TabAuraEvent:Section({ Title = "Smart Aura Roll & Target Engine" })

TabAuraEvent:Dropdown({
    Title = "Target Stop Aura / Tier",
    Desc = "Halt auto roll immediately when rolling this tier or specific aura",
    Values = {
        "Rank 4+ (Storm and above)",
        "Rank 5+ (Lava and above)",
        "Rank 6+ (Abyss / Mythic+)",
        "Rank 7+ (Aurora / Secret+)",
        "Rank 8+ (Poseidon and above)",
        "Rank 9+ (Tsunami and above)",
        "Rank 10 (Leviathan - 1 in 1M)",
        "Specific: Storm (Rank 4)",
        "Specific: Lava (Rank 5)",
        "Specific: Abyss (Rank 6)",
        "Specific: Aurora (Rank 7)",
        "Specific: Poseidon (Rank 8)",
        "Specific: Tsunami (Rank 9)",
        "Specific: Leviathan (Rank 10)",
        "Disabled (Continuous Spin)",
    },
    Value = "Rank 6+ (Abyss / Mythic+)",
    Callback = function(val)
        State.AuraStopTarget = val
    end
})

TabAuraEvent:Slider({
    Title = "Spin Interval (Seconds)",
    Desc = "Delay between consecutive aura roll requests",
    Value = {
        Min = 0.1,
        Max = 1.5,
        Default = 0.35,
    },
    Step = 0.05,
    Callback = function(val)
        State.AuraSpinDelay = val
    end
})

TabAuraEvent:Toggle({
    Title = "Auto Spin Aura (Money)",
    Desc = "Spins auras using money when available, stops on target",
    Value = false,
    Callback = function(val)
        State.AutoSpinAuraMoney = val
    end
})

TabAuraEvent:Toggle({
    Title = "Auto Spin Aura (Free / Available)",
    Desc = "Consumes free aura roll slots, stops on target",
    Value = false,
    Callback = function(val)
        State.AutoSpinAuraFree = val
    end
})

TabAuraEvent:Section({ Title = "Auto Store & Equip Automation" })

TabAuraEvent:Toggle({
    Title = "Auto Store Target Aura",
    Desc = "Automatically stores prized/target auras into open slots to prevent overwrite",
    Value = false,
    Callback = function(val)
        State.AutoStoreTargetAura = val
    end
})

TabAuraEvent:Toggle({
    Title = "Auto Equip Best Aura",
    Desc = "Constantly ensures highest multiplier aura is actively equipped",
    Value = false,
    Callback = function(val)
        State.AutoEquipBestAura = val
    end
})

TabAuraEvent:Toggle({
    Title = "Auto Unlock Aura Slots",
    Desc = "Purchases Slot 2 (1M) and Slot 3 (1B) automatically when affordable",
    Value = false,
    Callback = function(val)
        State.AutoUnlockAuraSlots = val
    end
})

TabAuraEvent:Section({ Title = "Manual Slot Operations" })

TabAuraEvent:Button({
    Title = "Equip Highest Owned Aura (Instant)",
    Desc = "Scans equipped aura and all slots, swapping to the highest tier",
    Callback = function()
        local switched, bestName = equipBestAura()
        WindUI:Notify({
            Title = "Aura Equipped",
            Content = "Active aura: " .. tostring(bestName),
            Duration = 3,
        })
    end
})

TabAuraEvent:Button({
    Title = "Store Equipped Aura into Slot",
    Desc = "Moves current equipped aura into an empty or lower-tier slot",
    Callback = function()
        local stored = storeEquippedToSlot()
        if stored then
            WindUI:Notify({
                Title = "Aura Stored",
                Content = "Equipped aura saved to inventory slot.",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Store Failed",
                Content = "No available or lower-tier slot to store into.",
                Duration = 3,
            })
        end
    end
})

TabAuraEvent:Button({
    Title = "Swap with Slot 1",
    Callback = function()
        if RemoteAuraSlot then
            pcall(function() RemoteAuraSlot:InvokeServer(1) end)
        end
    end
})

TabAuraEvent:Button({
    Title = "Swap with Slot 2",
    Callback = function()
        if RemoteAuraSlot then
            pcall(function() RemoteAuraSlot:InvokeServer(2) end)
        end
    end
})

TabAuraEvent:Button({
    Title = "Swap / Unlock Slot 3",
    Callback = function()
        if RemoteAuraSlot then
            pcall(function() RemoteAuraSlot:InvokeServer(3) end)
        end
    end
})

TabAuraEvent:Section({ Title = "Boss Fight Automation" })

TabAuraEvent:Toggle({
    Title = "Auto Boss DPS (Fast Click)",
    Desc = "Attacks Poseidon boss at max rate during Fight state",
    Value = false,
    Callback = function(val)
        State.AutoBossDps = val
    end
})

TabAuraEvent:Section({ Title = "Event Presents" })

TabAuraEvent:Toggle({
    Title = "Auto Collect Nearby Presents",
    Desc = "Opens presents that spawn in the workspace",
    Value = false,
    Callback = function(val)
        State.AutoOpenPresents = val
    end
})

--------------------------------------------------------------------------------
-- 5. TAB: REWARDS & CODES
--------------------------------------------------------------------------------
TabRewards:Section({ Title = "Recurring Free Rewards" })

TabRewards:Toggle({
    Title = "Auto Claim Daily",
    Desc = "Claims daily login gifts",
    Value = false,
    Callback = function(val)
        State.AutoClaimDaily = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Cycles through all active playtime gift slots (1-12)",
    Value = false,
    Callback = function(val)
        State.AutoClaimPlaytime = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Offline Rewards",
    Desc = "Collects accumulated offline earnings",
    Value = false,
    Callback = function(val)
        State.AutoClaimOffline = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Group Reward",
    Desc = "Collects group membership perks",
    Value = false,
    Callback = function(val)
        State.AutoClaimGroup = val
    end
})

TabRewards:Section({ Title = "Instant Redeem All Active Codes" })

TabRewards:Button({
    Title = "Redeem Verified Codes",
    Desc = "Submits known promo codes to server",
    Callback = function()
        local codes = { "RELEASE", "WATER", "DRAIN", "10KLIKES", "50KLIKES", "TREASURE", "UPDATE" }
        for _, code in ipairs(codes) do
            pcall(function()
                if RemoteRedeemCode then
                    RemoteRedeemCode:InvokeServer(code)
                end
            end)
            task.wait(0.2)
        end
    end
})

--------------------------------------------------------------------------------
-- 6. TAB: TELEPORTS
--------------------------------------------------------------------------------
TabTeleport:Section({ Title = "World Travel" })

local worldOptions = { "World 1", "World 2", "World 3", "World 4" }
for idx, wName in ipairs(worldOptions) do
    TabTeleport:Button({
        Title = "Travel to " .. wName,
        Callback = function()
            pcall(function()
                if RemoteTravelWorld then
                    RemoteTravelWorld:InvokeServer(idx)
                end
            end)
        end
    })
end

TabTeleport:Section({ Title = "Fast Zone Teleport" })

TabTeleport:Slider({
    Title = "Zone Selector (1 - 60)",
    Value = {
        Min = 1,
        Max = 60,
        Default = 1,
    },
    Step = 1,
    Callback = function(val)
        State.TargetDrainZone = val
    end
})

TabTeleport:Button({
    Title = "Teleport to Safe Zone Dock",
    Callback = function()
        pcall(function()
            if RemoteTeleport then
                RemoteTeleport:InvokeServer(State.TargetDrainZone)
            end
        end)
    end
})

TabTeleport:Button({
    Title = "Teleport to Spawn / Lobby",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(0, 5, 0)
        end
    end
})

--------------------------------------------------------------------------------
-- 7. TAB: MOVEMENT & MISC
--------------------------------------------------------------------------------
TabMisc:Section({ Title = "Local Player Physics" })

TabMisc:Toggle({
    Title = "Custom WalkSpeed",
    Value = false,
    Callback = function(val)
        State.CustomSpeedEnabled = val
        if not val then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

TabMisc:Slider({
    Title = "WalkSpeed Value",
    Value = {
        Min = 16,
        Max = 250,
        Default = 32,
    },
    Step = 1,
    Callback = function(val)
        State.WalkSpeedValue = val
        if State.CustomSpeedEnabled then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = val end
        end
    end
})

TabMisc:Toggle({
    Title = "Custom JumpPower",
    Value = false,
    Callback = function(val)
        State.CustomJumpEnabled = val
        if not val then
            local hum = getHumanoid()
            if hum then hum.JumpPower = 50 end
        end
    end
})

TabMisc:Slider({
    Title = "JumpPower Value",
    Value = {
        Min = 50,
        Max = 350,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        State.JumpPowerValue = val
        if State.CustomJumpEnabled then
            local hum = getHumanoid()
            if hum then hum.JumpPower = val end
        end
    end
})

TabMisc:Toggle({
    Title = "Noclip",
    Desc = "Walk through all map barriers and walls",
    Value = false,
    Callback = function(val)
        State.Noclip = val
    end
})

TabMisc:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(val)
        State.InfiniteJump = val
    end
})

-- Noclip loop
RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if State.CustomSpeedEnabled then
        local hum = getHumanoid()
        if hum and hum.WalkSpeed ~= State.WalkSpeedValue then
            hum.WalkSpeed = State.WalkSpeedValue
        end
    end
    if State.CustomJumpEnabled then
        local hum = getHumanoid()
        if hum and hum.JumpPower ~= State.JumpPowerValue then
            hum.JumpPower = State.JumpPowerValue
        end
    end
end)

-- Infinite Jump listener
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------------------------------------
-- 8. TAB: CONFIGURATION
--------------------------------------------------------------------------------
TabConfig:Section({ Title = "Profile Management" })

TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Persists current UI toggles and parameters to disk",
    Callback = function()
        SaveConfig()
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Configuration file successfully saved to " .. ConfigFilePath,
            Duration = 3,
        })
    end
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Restores toggles and parameters from disk",
    Callback = function()
        LoadConfig()
        WindUI:Notify({
            Title = "Config Loaded",
            Content = "Configuration successfully reloaded.",
            Duration = 3,
        })
    end
})

TabConfig:Button({
    Title = "Reset All Settings",
    Desc = "Resets all features to OFF default state",
    Callback = function()
        for k, v in pairs(State) do
            if typeof(v) == "boolean" then
                State[k] = false
            end
        end
        WindUI:Notify({
            Title = "Settings Reset",
            Content = "All automation modules disabled.",
            Duration = 3,
        })
    end
})

--------------------------------------------------------------------------------
-- BACKGROUND ENGINE LOOPS (100% Non-Intrusive, Zero Freeze)
--------------------------------------------------------------------------------

-- Fast Water Generation Thread
task.spawn(function()
    while true do
        if State.FastWater and RemoteClick then
            pcall(function()
                RemoteClick:FireServer()
            end)
            task.wait(State.FastWaterDelay)
        else
            task.wait(0.2)
        end
    end
end)

-- Auto Sell Thread
task.spawn(function()
    while true do
        if State.AutoSell and RemoteSell then
            local bpAttr = LocalPlayer:GetAttribute("Backpack") or "[]"
            local success, items = pcall(HttpService.JSONDecode, HttpService, bpAttr)
            local count = (success and type(items) == "table") and #items or 0
            if count >= State.AutoSellThreshold then
                pcall(function()
                    RemoteSell:InvokeServer("all")
                end)
            end
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- Auto Upgrade & Progression Thread
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoUpgradeBackpack and RemoteBuyUpgrade then
            pcall(function() RemoteBuyUpgrade:InvokeServer("Backpack") end)
        end
        if State.AutoUpgradeSpeed and RemoteBuyUpgrade then
            pcall(function() RemoteBuyUpgrade:InvokeServer("Walkspeed") end)
        end
        if State.AutoUpgradeLuck and RemoteBuyUpgrade then
            pcall(function() RemoteBuyUpgrade:InvokeServer("Luck") end)
        end
        if State.AutoRebirth and RemoteRebirth then
            local lvl = LocalPlayer:GetAttribute("Level") or 0
            local rCount = LocalPlayer:GetAttribute("Rebirths") or 0
            local needed = 25 * (rCount + 1)
            if lvl >= needed then
                pcall(function() RemoteRebirth:InvokeServer() end)
            end
        end
        if State.AutoBuyPump and RemoteBuyPump then
            local ownedPumpsStr = LocalPlayer:GetAttribute("Pumps") or "[]"
            local ok, ownedList = pcall(HttpService.JSONDecode, HttpService, ownedPumpsStr)
            local currentPump = LocalPlayer:GetAttribute("Pump") or 1
            local nextPump = currentPump + 1
            if ok and type(ownedList) == "table" and not table.find(ownedList, nextPump) and nextPump <= 84 then
                pcall(function() RemoteBuyPump:InvokeServer(nextPump) end)
            end
        end
        if State.AutoEquipPump and RemoteEquipPump then
            local ownedPumpsStr = LocalPlayer:GetAttribute("Pumps") or "[]"
            local ok, ownedList = pcall(HttpService.JSONDecode, HttpService, ownedPumpsStr)
            if ok and type(ownedList) == "table" and #ownedList > 0 then
                table.sort(ownedList)
                local highest = ownedList[#ownedList]
                local current = LocalPlayer:GetAttribute("Pump") or 1
                if highest > current then
                    pcall(function() RemoteEquipPump:InvokeServer(highest) end)
                end
            end
        end
    end
end)

-- Auto Eggs Thread
task.spawn(function()
    while true do
        if State.AutoOpenEgg and RemoteOpenEgg then
            local eggPos = EggLocations[State.SelectedEgg]
            local root = getRoot()
            if root and eggPos then
                if (root.Position - eggPos).Magnitude > 12 then
                    root.CFrame = CFrame.new(eggPos + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                end
                pcall(function()
                    RemoteOpenEgg:InvokeServer(State.SelectedEgg, State.HatchAmount)
                end)
            end
            task.wait(0.35)
        else
            task.wait(1)
        end
    end
end)

-- Auto Pets Equip Best
task.spawn(function()
    while true do
        if State.AutoEquipBestPets and RemotePetAction then
            pcall(function()
                RemotePetAction:InvokeServer("EquipBest", nil)
            end)
            task.wait(2)
        else
            task.wait(2)
        end
    end
end)

-- Smart Auto Aura Engine Thread
task.spawn(function()
    while true do
        if (State.AutoSpinAuraMoney or State.AutoSpinAuraFree) and RemoteSpinAura then
            -- Auto Unlock Slots if enabled
            if State.AutoUnlockAuraSlots and RemoteAuraSlot then
                local money = LocalPlayer:GetAttribute("Money") or 0
                if not LocalPlayer:GetAttribute("AuraSlotOpen2") and money >= 1000000 then
                    pcall(function() RemoteAuraSlot:InvokeServer(2) end)
                end
                if not LocalPlayer:GetAttribute("AuraSlotOpen3") and money >= 1000000000 then
                    pcall(function() RemoteAuraSlot:InvokeServer(3) end)
                end
            end

            -- Determine roll type
            local rollMode = "Money"
            if State.AutoSpinAuraFree then
                local freeUsed = LocalPlayer:GetAttribute("AuraFreeUsed")
                if freeUsed == false then
                    rollMode = "Free"
                elseif not State.AutoSpinAuraMoney then
                    task.wait(1)
                    continue
                end
            end

            -- Execute Spin
            local ok, result = pcall(function()
                return RemoteSpinAura:InvokeServer(rollMode)
            end)

            if ok and type(result) == "table" and result.aura then
                local rolledId = result.aura
                local rolledRank = getAuraRank(rolledId)

                -- Check target match
                local isTarget = checkMeetsTarget(rolledId, State.AuraStopTarget)

                if isTarget then
                    -- Halt auto spin
                    State.AutoSpinAuraMoney = false
                    State.AutoSpinAuraFree = false

                    WindUI:Notify({
                        Title = "TARGET AURA ROLLED!",
                        Content = "Rolled " .. tostring(rolledId) .. " (Rank " .. tostring(rolledRank) .. ")! Auto Spin stopped.",
                        Duration = 6,
                    })

                    -- Store to slot if enabled
                    if State.AutoStoreTargetAura then
                        local stored = storeEquippedToSlot()
                        if stored then
                            WindUI:Notify({
                                Title = "Target Aura Protected",
                                Content = tostring(rolledId) .. " safely moved into slot.",
                                Duration = 4,
                            })
                        end
                    end

                    -- Equip best if enabled
                    if State.AutoEquipBestAura then
                        task.wait(0.25)
                        equipBestAura()
                    end

                    task.wait(1)
                    continue
                end

                -- If not target, but AutoStoreTargetAura is on and it's rare (>= Rank 4)
                if State.AutoStoreTargetAura and rolledRank >= 4 then
                    storeEquippedToSlot()
                end

                -- Auto Equip best aura if enabled
                if State.AutoEquipBestAura then
                    equipBestAura()
                end
            end

            task.wait(State.AuraSpinDelay or 0.35)
        else
            -- When not spinning, maintain best aura if toggle is active
            if State.AutoEquipBestAura and RemoteAuraSlot then
                equipBestAura()
            end
            task.wait(1)
        end
    end
end)

-- Auto Boss DPS Thread
task.spawn(function()
    while true do
        if State.AutoBossDps and RemoteBossClick then
            local bossState = ReplicatedStorage:GetAttribute("BossState")
            if bossState == "Fight" then
                pcall(function()
                    RemoteBossClick:FireServer()
                end)
                task.wait(0.08)
            else
                task.wait(0.5)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Auto AFK Pool Thread
task.spawn(function()
    while true do
        if State.AutoAfkPool then
            local root = getRoot()
            local hum = getHumanoid()
            if root and hum then
                local poolId = resolveTargetPoolId(State.SelectedPool)
                local water = getPoolWaterPart(poolId)
                if water then
                    local targetPos = water.Position + Vector3.new(0, 2.5, 0)
                    local dist = (root.Position - targetPos).Magnitude
                    local inPoolAttr = LocalPlayer:GetAttribute("InPool")

                    -- Re-align if player drifted away or server hasn't registered inPool
                    if dist > 5 or inPoolAttr ~= poolId then
                        root.CFrame = CFrame.new(targetPos)
                        hum.PlatformStand = false
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
            task.wait(1.5)
        else
            task.wait(1.5)
        end
    end
end)

-- Auto Claim Free Rewards Thread
task.spawn(function()
    while true do
        task.wait(5)
        if State.AutoClaimDaily and RemoteClaimDaily then
            pcall(function() RemoteClaimDaily:InvokeServer() end)
        end
        if State.AutoClaimOffline and RemoteClaimOffline then
            pcall(function() RemoteClaimOffline:InvokeServer() end)
        end
        if State.AutoClaimGroup and RemoteClaimGroupReward then
            pcall(function() RemoteClaimGroupReward:InvokeServer() end)
        end
        if State.AutoClaimPlaytime and RemoteClaimPlaytime then
            for slot = 1, 12 do
                pcall(function()
                    RemoteClaimPlaytime:InvokeServer(slot)
                end)
                task.wait(0.15)
            end
        end
    end
end)

-- Seamless Autonomous Treasure Vacuum Engine (Zero Movement Impairment)
task.spawn(function()
    local isVacuuming = false
    while true do
        if State.AutoVacuumTreasures and RemotePickup and not isVacuuming then
            local myLakes = workspace:FindFirstChild("MyLakes")
            local root = getRoot()
            local hum = getHumanoid()

            if myLakes and root and hum then
                local targets = {}
                for _, model in ipairs(myLakes:GetChildren()) do
                    if model:IsA("Model") then
                        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            table.insert(targets, {
                                model = model,
                                prompt = prompt,
                                pos = model:GetPivot().Position,
                            })
                        end
                    end
                end

                if #targets > 0 then
                    isVacuuming = true
                    local originCFrame = root.CFrame

                    for _, t in ipairs(targets) do
                        if not State.AutoVacuumTreasures then break end
                        if not t.model.Parent then continue end

                        -- Capacity check & auto sell
                        local bp = LocalPlayer:GetAttribute("Backpack") or "[]"
                        local ok, items = pcall(HttpService.JSONDecode, HttpService, bp)
                        local bpCount = (ok and type(items) == "table") and #items or 0
                        local maxBp = LocalPlayer:GetAttribute("BackpackMax") or 7

                        if bpCount >= maxBp and RemoteSell then
                            RemoteSell:InvokeServer("all")
                            task.wait(0.1)
                        end

                        t.prompt.RequiresLineOfSight = false
                        t.prompt.HoldDuration = 0
                        t.prompt.MaxActivationDistance = 999999

                        root.CFrame = CFrame.new(t.pos + Vector3.new(0, 1.5, 0))
                        task.wait(State.VacuumSpeed)

                        pcall(function()
                            fireproximityprompt(t.prompt)
                        end)
                        task.wait(State.VacuumSpeed)
                    end

                    -- Instantly return to the original dock spot
                    root.CFrame = originCFrame
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.Running)

                    task.wait(State.VacuumLoopInterval or 0.4)
                    isVacuuming = false
                else
                    task.wait(State.VacuumLoopInterval or 0.4)
                end
            else
                task.wait(0.5)
            end
        else
            task.wait(0.5)
        end
    end
end)

WindUI:Notify({
    Title = "+1 Drain Water Loaded",
    Content = "Clean Physics & Safe Dock Engine Active. Hotkey: [LeftControl]",
    Duration = 4,
})
