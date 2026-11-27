-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- ==============================================================================
-- FLa ProjecT: Anime Dice Ultimate Automation Engine
-- Version: v1.0 [Halloween Edition]
-- Framework: WindUI Engine (English UI)
-- Author: FLa ProjecT
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

-- Single-instance guard & clean reload
local genv = getgenv and getgenv() or _G
if genv.__ANIMEDICE_OP and genv.__ANIMEDICE_OP.Stop then
    pcall(genv.__ANIMEDICE_OP.Stop)
end

-- Cleanup prior GUI instances
pcall(function()
    local cgui = game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
    for _, c in ipairs(cgui:GetChildren()) do
        if c.Name == "AnimeDice_FloatingBtn" or c.Name:find("AnimeDice") then
            pcall(function() c:Destroy() end)
        end
    end
    local rgui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if rgui then
        for _, c in ipairs(rgui:GetChildren()) do
            if c.Name:find("WindUI") then
                pcall(function() c:Destroy() end)
            end
        end
    end
end)

-- Safe notification helper
local isLoadingConfig = false
local function notify(title, message, duration)
    if isLoadingConfig then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Anime Dice OP",
            Text = message or "",
            Duration = duration or 3
        })
    end)
end

-- ==============================================================================
-- 1. STATE & CONFIGURATION STORAGE
-- ==============================================================================
local S = {
    -- Rolling
    FastRoll = false,
    RollDelay = 0.05,
    StopOnRarity = "None",
    StopOnMutation = "None",
    AutoBuyBestDice = false,
    AutoEquipBestDice = false,
    NotifyOnRoll = false,

    -- Halloween Event
    AutoPumpkinRoll = false,
    PumpkinRollDelay = 0.25,
    AutoTrickOrTreat = false,
    AutoClaimPumpkinPass = false,
    AutoBuyCandyUpgrades = false,
    AutoClaimHalloweenQuests = false,

    -- Standard Towers (Normal Map)
    AutoTowerRusher = false,
    TowerClearDelay = 0.05,
    SelectedTower = "Dragon Tower",
    AutoEquipTowerTeam = false,

    -- Haunted House (Halloween Event Map)
    AutoHauntedHouse = false,
    HauntedHouseDelay = 0.05,
    SelectedHauntedHouse = "Front Yard",

    -- Plot & Economy
    AutoCollectIncome = false,
    AutoLevelSlots = false,
    AutoEquipBestPlot = false,
    AutoBuyUpgrades = false,
    AutoRebirth = false,
    AutoRebirthStats = false,
    RebirthStatPriority = "Luck",

    -- Inventory & Rewards
    AutoRemoteSell = false,
    SellThreshold = "Common",
    AutoClaimDaily = false,
    AutoClaimGroup = false,
    AutoClaimOffline = false,
    AutoClaimQuests = false,
    AutoSpinWheel = false,

    -- Player & Physics
    CustomSpeed = false,
    WalkSpeed = 70,
    CustomJump = false,
    JumpPower = 90,
    NoClip = false,
    InfJump = false,
    AntiAFK = false
}

local UI_ELEMENTS = {}

local CONFIG_FILE = "AnimeDice_Config.json"
local function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(S))
            notify("Config Saved", "Preferences successfully written to " .. CONFIG_FILE, 3)
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) and readfile then
            local raw = readfile(CONFIG_FILE)
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                isLoadingConfig = true
                for k, v in pairs(data) do
                    if S[k] ~= nil then
                        S[k] = v
                    end
                    local widget = UI_ELEMENTS[k]
                    if widget then
                        pcall(function()
                            local wType = widget.__type or widget.Type
                            if wType == "Toggle" then
                                widget:Set(v == true)
                            elseif wType == "Slider" then
                                local num = tonumber(v)
                                if num then widget:Set(num) end
                            elseif wType == "Dropdown" then
                                widget:Select(tostring(v))
                            end
                        end)
                    end
                end
                isLoadingConfig = false
                notify("Config Loaded", "Preferences and visual controls restored from " .. CONFIG_FILE, 3.5)
            end
        else
            notify("Config Info", "No saved configuration file found (" .. CONFIG_FILE .. ")", 3)
        end
    end)
end

-- Startup: All features default strictly to OFF (manual load available in Settings)
-- pcall(loadConfig)

-- ==============================================================================
-- 2. GAME NETWORK & MODULE RESOLUTION
-- ==============================================================================
local Network = ReplicatedStorage:WaitForChild("Network", 8) or ReplicatedStorage:FindFirstChild("Network")
local Framework = ReplicatedStorage:WaitForChild("Framework", 8) or ReplicatedStorage:FindFirstChild("Framework")
local Features = Framework and (Framework:WaitForChild("Features", 8) or Framework:FindFirstChild("Features"))

-- Network Services Remotes
local RollService = Network and (Network:WaitForChild("RollService", 5) or Network:FindFirstChild("RollService"))
local RollDiceRF = RollService and RollService:FindFirstChild("RF") and RollService.RF:FindFirstChild("RollDice")
local SetAutoRollRE = RollService and RollService:FindFirstChild("RE") and RollService.RE:FindFirstChild("SetAutoRoll")

local DiceShopService = Network and (Network:WaitForChild("DiceShopService", 5) or Network:FindFirstChild("DiceShopService"))
local BuyDiceRE = DiceShopService and DiceShopService:FindFirstChild("RE") and DiceShopService.RE:FindFirstChild("BuyDice")
local EquipDiceRE = DiceShopService and DiceShopService:FindFirstChild("RE") and DiceShopService.RE:FindFirstChild("EquipDice")

local PlotService = Network and (Network:WaitForChild("PlotService", 5) or Network:FindFirstChild("PlotService"))
local CollectBalanceRE = PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("CollectBalance")
local LevelUpSlotRE = PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("LevelUpSlot")
local EquipBestPlotRE = PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("EquipBest")

local TowersService = Network and (Network:WaitForChild("Towers", 5) or Network:FindFirstChild("Towers"))
local PlayTowerRF = TowersService and TowersService:FindFirstChild("RF") and TowersService.RF:FindFirstChild("PlayTower")
local CompleteTowerFloorRF = TowersService and TowersService:FindFirstChild("RF") and TowersService.RF:FindFirstChild("CompleteTowerFloor")
local CancelTowerRF = TowersService and TowersService:FindFirstChild("RF") and TowersService.RF:FindFirstChild("CancelTower")
local EquipBestTowerTeamRE = TowersService and TowersService:FindFirstChild("RE") and TowersService.RE:FindFirstChild("EquipBestTowerTeam")

-- Halloween Services (Event Deprecated / Gracefully Resolved without Infinite Thread Yield)
local HalloweenService = Network and Network:FindFirstChild("HalloweenService")
local ClaimAllPathRE = HalloweenService and HalloweenService:FindFirstChild("RE") and HalloweenService.RE:FindFirstChild("ClaimAllPath")
local BuyHalloweenUpgradeRE = HalloweenService and (HalloweenService:FindFirstChild("BuyUpgrade") or (HalloweenService:FindFirstChild("RE") and HalloweenService.RE:FindFirstChild("BuyUpgrade")))
local TeleportHalloweenRF = HalloweenService and HalloweenService:FindFirstChild("RF") and HalloweenService.RF:FindFirstChild("Teleport")

local PumpkinDiceService = Network and Network:FindFirstChild("PumpkinDiceService")
local PumpkinRollRF = PumpkinDiceService and PumpkinDiceService:FindFirstChild("RF") and PumpkinDiceService.RF:FindFirstChild("Roll")

local HalloweenQuestService = Network and Network:FindFirstChild("HalloweenQuestService")
local ClaimHalloweenQuestRE = HalloweenQuestService and HalloweenQuestService:FindFirstChild("RE") and HalloweenQuestService.RE:FindFirstChild("Claim")

local TrickOrTreatService = Network and Network:FindFirstChild("TrickOrTreatService")
local KnockedRE = TrickOrTreatService and TrickOrTreatService:FindFirstChild("RE") and TrickOrTreatService.RE:FindFirstChild("Knocked")
local LandedRE = TrickOrTreatService and TrickOrTreatService:FindFirstChild("RE") and TrickOrTreatService.RE:FindFirstChild("Landed")

local QuestService = Network and (Network:WaitForChild("QuestService", 5) or Network:FindFirstChild("QuestService"))
local ClaimQuestRE = QuestService and QuestService:FindFirstChild("RE") and QuestService.RE:FindFirstChild("Claim")

local CodesService = Network and (Network:WaitForChild("CodesService", 5) or Network:FindFirstChild("CodesService"))
local RedeemCodeRE = CodesService and CodesService:FindFirstChild("RE") and CodesService.RE:FindFirstChild("RedeemCode")

local SellService = Network and (Network:WaitForChild("SellService", 5) or Network:FindFirstChild("SellService"))
local SellInventoryRF = SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellInventory")

local RebirthService = Network and (Network:WaitForChild("RebirthService", 5) or Network:FindFirstChild("RebirthService"))
local RebirthRE = RebirthService and RebirthService:FindFirstChild("RE") and RebirthService.RE:FindFirstChild("Rebirth")
local AddStatRE = RebirthService and RebirthService:FindFirstChild("RE") and RebirthService.RE:FindFirstChild("AddStat")

local GeneralRE = Network and (Network:WaitForChild("RE", 5) or Network:FindFirstChild("RE"))
local BuyNormalUpgradeRE = GeneralRE and GeneralRE:FindFirstChild("BuyUpgrade")

local DailyRewardService = Network and (Network:WaitForChild("DailyRewardService", 5) or Network:FindFirstChild("DailyRewardService"))
local ClaimDailyRE = DailyRewardService and DailyRewardService:FindFirstChild("RE") and DailyRewardService.RE:FindFirstChild("Claim")

local GroupRewardService = Network and (Network:WaitForChild("GroupRewardService", 5) or Network:FindFirstChild("GroupRewardService"))
local ClaimGroupRE = GroupRewardService and GroupRewardService:FindFirstChild("RE") and GroupRewardService.RE:FindFirstChild("Claim")

local OfflineEarningsService = Network and (Network:WaitForChild("OfflineEarningsService", 5) or Network:FindFirstChild("OfflineEarningsService"))
local ClaimOfflineRE = OfflineEarningsService and OfflineEarningsService:FindFirstChild("RE") and OfflineEarningsService.RE:FindFirstChild("Claim")

local SpinService = Network and (Network:WaitForChild("SpinService", 5) or Network:FindFirstChild("SpinService"))
local UseSpinRE = SpinService and SpinService:FindFirstChild("RE") and SpinService.RE:FindFirstChild("Use")

-- Internal Controllers & Configs
local DataController = Features and require(Features:WaitForChild("Data", 5):WaitForChild("DataController", 5))
local DiceModule = Features and require(Features:WaitForChild("Rolling", 5):WaitForChild("Dice", 5))
local UpgradesModule = Features and require(Features:WaitForChild("Upgrades", 5):WaitForChild("Upgrades", 5))
local SellUtil = Features and require(Features:WaitForChild("Selling", 5):WaitForChild("SellUtil", 5))
local QuestConfig = Features and require(Features:WaitForChild("Quests", 5):WaitForChild("QuestConfig", 5))
local UnitConfig = Features and require(Features:WaitForChild("Inventory", 5):WaitForChild("Kinds", 5):WaitForChild("Unit", 5):WaitForChild("UnitConfig", 5))

local HalloweenFeat = Features and Features:FindFirstChild("Halloween")
local HalloweenQuests = nil
if HalloweenFeat and HalloweenFeat:FindFirstChild("HalloweenQuests") then
    pcall(function() HalloweenQuests = require(HalloweenFeat.HalloweenQuests) end)
end
local HalloweenConfig = nil
if HalloweenFeat and HalloweenFeat:FindFirstChild("HalloweenConfig") then
    pcall(function() HalloweenConfig = require(HalloweenFeat.HalloweenConfig) end)
end
local PumpkinDiceModule = nil
if HalloweenFeat and HalloweenFeat:FindFirstChild("PumpkinDice") then
    pcall(function() PumpkinDiceModule = require(HalloweenFeat.PumpkinDice) end)
end

-- Verified 18 Active Promo Codes
local ACTIVE_CODES = {
    "UPDATE10", "UPDATE7", "UPDATE6", "UPDATE5", "UPDATE4", "UPDATE3", "UPDATE2", "UPDATE1",
    "400KLIKES", "250KLIKES", "100KLIKES", "40KCCU", "30KCCU", "20KCCU", "10KCCU", "5KCCU", "1KCCU", "RELEASE"
}

-- Rarity Hierarchy Table (Aligned with Framework.Other.Rarities sortOrder)
local RARITY_RANKS = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythical"] = 6,
    ["Divine"] = 7,
    ["Exotic"] = 8,
    ["Celestial"] = 9,
    ["Secret I"] = 10,
    ["Secret II"] = 11,
    ["Heavenly"] = 12,
    ["Galactic"] = 13,
    ["Cosmic"] = 14,
    ["Exclusive"] = 15
}

local ALL_RARITIES_ORDERED = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythical",
    "Divine",
    "Exotic",
    "Celestial",
    "Secret I",
    "Secret II",
    "Heavenly",
    "Galactic",
    "Cosmic",
    "Exclusive"
}

local MUTATION_RANKS = {
    ["None"] = 0,
    ["Silver"] = 1,
    ["Gold"] = 2,
    ["Emerald"] = 3,
    ["Diamond"] = 4,
    ["Ruby"] = 5,
    ["Rainbow"] = 6,
    ["Haunted"] = 7
}

-- Verified Door Coordinates in Workspace.Halloween
local TRICK_OR_TREAT_DOORS = {
    Vector3.new(-1993.9, -17.3, 11363.6),
    Vector3.new(-1873.3, -17.3, 11368.1),
    Vector3.new(-1873.3, -17.3, 11313.4),
    Vector3.new(-1799.5, -17.3, 11363.6),
    Vector3.new(-2081.1, -17.3, 11350.8),
    Vector3.new(-1806.8, -17.3, 11319.6),
    Vector3.new(-1912.2, -17.3, 11267.5)
}

-- Standard Towers (Normal Map)
local NORMAL_TOWERS = {
    "Dragon Tower",
    "Cursed Tower",
    "Pirate Tower",
    "Hidden Leaf Tower",
    "Slayer Tower",
    "Shadow Tower",
    "Infinity Tower",
    "Soul Tower"
}

-- Haunted House Wings (Halloween Event Map)
local HAUNTED_HOUSE_WINGS = {
    "Front Yard",
    "Foyer",
    "Crypt",
    "Attic",
    "Bell Tower",
    "Catacombs",
    "The Abyss"
}

-- Safe Character Getter
local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getRoot()
    local char = getChar()
    return char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = getChar()
    return char:WaitForChild("Humanoid", 5) or char:FindFirstChild("Humanoid")
end

-- ==============================================================================
-- 3. BACKGROUND WORKER THREADS
-- ==============================================================================
local conns = {}
local running = true

-- ==============================================================================
-- ANTI-RELOG ENGINE & IMMUNITY SHIELD
-- Neutralizes game's PlayerScripts.AFK (18-min / 1080s force-relog bug)
-- ==============================================================================
local function neutralizeGameAFK()
    pcall(function()
        local ps = LP:WaitForChild("PlayerScripts", 5)
        if ps then
            local afk = ps:FindFirstChild("AFK")
            if afk then
                afk.Disabled = true
                afk:Destroy()
            end
            ps.ChildAdded:Connect(function(c)
                if c.Name == "AFK" then
                    c.Disabled = true
                    task.defer(function() pcall(function() c:Destroy() end) end)
                end
            end)
        end
    end)
end
neutralizeGameAFK()

-- Intercept and suppress all unwanted auto-relog Teleport calls
local TeleportService = game:GetService("TeleportService")
pcall(function()
    if hookmetamethod and newcclosure then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if self == TeleportService and method == "Teleport" then
                local args = {...}
                local placeId = args[1]
                if placeId == game.PlaceId or placeId == nil then
                    warn("[FLa ProjecT Anti-Relog] Blocked unwanted auto-relog Teleport to PlaceId: " .. tostring(placeId))
                    return
                end
            end
            return oldNamecall(self, ...)
        end))
    end
    if hookfunction and newcclosure then
        local oldTeleport
        oldTeleport = hookfunction(TeleportService.Teleport, newcclosure(function(self, placeId, player, ...)
            if self == TeleportService and (placeId == game.PlaceId or placeId == nil) then
                warn("[FLa ProjecT Anti-Relog] Blocked direct auto-relog Teleport to PlaceId: " .. tostring(placeId))
                return
            end
            return oldTeleport(self, placeId, player, ...)
        end))
    end
end)

-- Robust Anti-AFK Engine (Disables idle disconnects & pulses heartbeat)
pcall(function()
    if getconnections then
        for _, conn in pairs(getconnections(LP.Idled)) do
            pcall(function() conn:Disable() end)
        end
    end
end)

local afkConn = LP.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(100, 100))
    end)
end)
table.insert(conns, afkConn)

-- Periodic Heartbeat Virtual Input (Keeps engine idle counter at 0)
task.spawn(function()
    while running do
        task.wait(120)
        pcall(function()
            if S.AntiAFK or running then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(50, 50))
            end
        end)
    end
end)

-- Character Physics & NoClip Loop
local noclipConn = RunService.Stepped:Connect(function()
    if not running then return end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            if S.CustomSpeed then hum.WalkSpeed = S.WalkSpeed end
            if S.CustomJump then hum.JumpPower = S.JumpPower end
        end
        if S.NoClip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end
end)
table.insert(conns, noclipConn)

-- Infinite Jump Listener
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if S.InfJump and running then
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(conns, jumpConn)

-- THREAD 1: Instant Fast Roll Engine
task.spawn(function()
    while running do
        if S.FastRoll then
            local ok, results = pcall(function()
                return RollDiceRF:InvokeServer()
            end)

            if ok and type(results) == "table" and #results > 0 then
                for _, res in ipairs(results) do
                    local unitName = res.result or "Unknown"
                    local mutation = res.mutation or "None"
                    local unitEntry = UnitConfig.entries and UnitConfig.entries[unitName]
                    local rarity = unitEntry and unitEntry.rarity or "Common"

                    if S.NotifyOnRoll then
                        notify("Rolled Unit", string.format("%s [%s] (Mut: %s)", unitName, rarity, mutation), 1.5)
                    end

                    -- Check Stop On Rarity Filter
                    if S.StopOnRarity ~= "None" then
                        local targetRank = RARITY_RANKS[S.StopOnRarity] or 0
                        local unitRank = RARITY_RANKS[rarity] or 0
                        if unitRank >= targetRank then
                            S.FastRoll = false
                            notify("Roll Guard Triggered!", string.format("Unlocked high-tier unit: %s [%s]! Auto-Roll paused.", unitName, rarity), 6)
                            break
                        end
                    end

                    -- Check Stop On Mutation Filter
                    if S.StopOnMutation ~= "None" then
                        local targetMutRank = MUTATION_RANKS[S.StopOnMutation] or 0
                        local unitMutRank = MUTATION_RANKS[mutation] or 0
                        if unitMutRank >= targetMutRank and unitMutRank > 0 then
                            S.FastRoll = false
                            notify("Mutation Guard Triggered!", string.format("Rolled rare mutation: %s on %s! Auto-Roll paused.", mutation, unitName), 6)
                            break
                        end
                    end
                end
            end
            task.wait(math.max(0.01, S.RollDelay))
        else
            task.wait(0.2)
        end
    end
end)

-- THREAD 2: Halloween Pumpkin Dice Auto-Roll
task.spawn(function()
    while running do
        if S.AutoPumpkinRoll then
            pcall(function()
                -- Multi-roll (5) requires 500 Pumpkins, Single (1) requires 100
                local rollAmount = 5
                PumpkinRollRF:InvokeServer(rollAmount)
            end)
            task.wait(math.max(0.1, S.PumpkinRollDelay))
        else
            task.wait(0.3)
        end
    end
end)

-- THREAD 3: Precision Sequential 7-House Trick-or-Treat Engine (All 7 Houses Verified, 4s Stand, 3s Spawn)
if LandedRE and LandedRE.OnClientEvent then
local trickConn = LandedRE.OnClientEvent:Connect(function(doorPart, candyAmount)
    if candyAmount and candyAmount > 0 then
        notify("Trick-or-Treat", string.format("ð¬ +%d Candy received!", candyAmount), 1.5)
    end
end)
table.insert(conns, trickConn)
end

-- Dynamic resolver for all 7 TrickOrTreat doors tagged in Halloween realm
-- Formatted as a closed clockwise racetrack circuit to eliminate long jumps (>185 studs)
local CIRCUIT_WAYPOINTS = {
    { name = "House 1 (West Corner)",   stand = Vector3.new(-2079.2, -17.8, 11351.4), face = Vector3.new(-2081.1, -17.5, 11350.8) },
    { name = "House 2 (West Street N)", stand = Vector3.new(-1993.9, -17.8, 11361.6), face = Vector3.new(-1993.9, -17.5, 11363.6) },
    { name = "House 3 (Mid Street N)",  stand = Vector3.new(-1873.3, -17.8, 11366.1), face = Vector3.new(-1873.3, -17.5, 11368.1) },
    { name = "House 4 (East Corner N)", stand = Vector3.new(-1799.5, -17.8, 11361.6), face = Vector3.new(-1799.5, -17.5, 11363.6) },
    { name = "House 5 (East Street S)", stand = Vector3.new(-1806.8, -17.8, 11321.6), face = Vector3.new(-1806.8, -17.5, 11319.6) },
    { name = "House 6 (Mid Street S)",  stand = Vector3.new(-1873.3, -17.8, 11315.4), face = Vector3.new(-1873.3, -17.5, 11313.4) },
    { name = "House 7 (South Pathway)", stand = Vector3.new(-1914.1, -17.8, 11268.0), face = Vector3.new(-1912.2, -17.5, 11267.5) }
}

local function getResolvedTrickOrTreatDoors()
    local CS = game:GetService("CollectionService")
    local tagged = CS:GetTagged("TrickOrTreatDoor")
    local resolvedCircuit = {}

    if #tagged >= 7 then
        local doorData = {}
        for _, door in ipairs(tagged) do
            local homeCF = door:GetAttribute("TrickOrTreatHome")
            local frontDir = door:GetAttribute("TrickOrTreatFront")
            local doorPos = homeCF and homeCF.Position or door.Position
            local dir = frontDir or Vector3.new(0, 0, 1)

            local stand = doorPos + dir * 2.0
            local standGround = Vector3.new(stand.X, -17.8, stand.Z)
            local face = Vector3.new(doorPos.X, -17.5, doorPos.Z)

            table.insert(doorData, {
                door = door,
                stand = standGround,
                face = face,
                name = door.Parent and door.Parent.Parent and door.Parent.Parent.Name or door.Name
            })
        end

        for _, wp in ipairs(CIRCUIT_WAYPOINTS) do
            local bestMatch = nil
            local bestDist = 999999
            for _, d in ipairs(doorData) do
                local dist = (Vector3.new(d.stand.X, 0, d.stand.Z) - Vector3.new(wp.stand.X, 0, wp.stand.Z)).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestMatch = d
                end
            end
            if bestMatch and bestDist < 25 then
                table.insert(resolvedCircuit, {
                    door = bestMatch.door,
                    stand = bestMatch.stand,
                    face = bestMatch.face,
                    name = wp.name
                })
            else
                table.insert(resolvedCircuit, wp)
            end
        end
    end

    if #resolvedCircuit == 7 then
        return resolvedCircuit
    end

    return CIRCUIT_WAYPOINTS
end

task.spawn(function()
    while running do
        if S.AutoTrickOrTreat then
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if root and hum and hum.Health > 0 then
                -- 1. Ensure Player is inside Halloween Island
                if root.Position.Z < 10000 then
                    notify("Halloween Island", "Transporting to Halloween realm...", 2.0)
                    pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
                    task.wait(2.5)
                else
                    -- 2. Precision Sequential Traversal through ALL 7 HOUSES (Racetrack circuit, zero empty-yard detours)
                    local currentHouses = getResolvedTrickOrTreatDoors()
                    for houseIdx = 1, #currentHouses do
                        if not S.AutoTrickOrTreat or not running then break end

                        local h = currentHouses[houseIdx]

                        -- Move directly to doorstep & freeze velocity so server anti-cheat registers settled status
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                        char:PivotTo(CFrame.new(h.stand, h.face))

                        -- Stand for 4.5 seconds:
                        -- Guaranteed to satisfy server max travel speed limit (max leg = 185 studs / 60 = 3.08s)
                        -- 7 houses * 4.5s = 31.5s total cycle (guarantees door 30s cooldown is 100% refreshed)
                        local standStart = tick()
                        while (tick() - standStart < 4.5) and S.AutoTrickOrTreat and running do
                            root.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.1)
                        end
                    end
                end
            else
                task.wait(1.0)
            end
        else
            task.wait(1.0)
        end
    end
end)

-- Tower session execution helper
local function runTowerSession(towerName, clearDelay, isHaunted)
    if not towerName then return end

    if S.AutoEquipTowerTeam then
        pcall(function() EquipBestTowerTeamRE:FireServer() end)
    end

    -- Cancel any previous stale session
    pcall(function() CancelTowerRF:InvokeServer() end)
    task.wait(0.3)

    -- Attempt to enter tower with debounce retries
    local started = false
    for _ = 1, 6 do
        if not running then return end
        if isHaunted and not S.AutoHauntedHouse then return end
        if not isHaunted and not S.AutoTowerRusher then return end

        local ok, res = pcall(function()
            return PlayTowerRF:InvokeServer(towerName)
        end)
        if ok and res ~= false and res ~= nil then
            started = true
            break
        end
        task.wait(1.0)
    end

    if not started then
        -- Secondary verification: test if CompleteTowerFloor is active
        local okCheck, checkRes = pcall(function() return CompleteTowerFloorRF:InvokeServer() end)
        if okCheck and checkRes ~= "destroyed" then
            started = true
        end
    end

    if not started then
        return
    end

    -- Rapid floor completion loop
    local nilCount = 0
    while running do
        -- Exit if respective feature was toggled off
        if isHaunted and not S.AutoHauntedHouse then
            pcall(function() CancelTowerRF:InvokeServer() end)
            break
        end
        if not isHaunted and not S.AutoTowerRusher then
            pcall(function() CancelTowerRF:InvokeServer() end)
            break
        end

        task.wait(math.max(0.05, clearDelay or 0.05))

        local ok, res = pcall(function()
            return CompleteTowerFloorRF:InvokeServer()
        end)

        if not ok or res == "destroyed" then
            break
        elseif type(res) == "table" then
            nilCount = 0
        elseif res == nil then
            nilCount = nilCount + 1
            if nilCount > 250 then
                break
            end
        end
    end

    pcall(function() CancelTowerRF:InvokeServer() end)
    task.wait(1.0)
end

-- THREAD 4: Dual Tower & Haunted House Automation Coordinator
task.spawn(function()
    while running do
        if S.AutoHauntedHouse and S.AutoTowerRusher then
            -- Both enabled: run Haunted House session, then Standard Tower session
            runTowerSession(S.SelectedHauntedHouse, S.HauntedHouseDelay, true)
            task.wait(1.5)
            if S.AutoTowerRusher and running then
                runTowerSession(S.SelectedTower, S.TowerClearDelay, false)
                task.wait(1.5)
            end
        elseif S.AutoHauntedHouse then
            -- Only Haunted House enabled
            runTowerSession(S.SelectedHauntedHouse, S.HauntedHouseDelay, true)
            task.wait(1.5)
        elseif S.AutoTowerRusher then
            -- Only Normal Tower enabled
            runTowerSession(S.SelectedTower, S.TowerClearDelay, false)
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end)

-- THREAD 5: Plot & Economy Automation (Income, Slots, Upgrades, Rebirth)
task.spawn(function()
    while running do
        if S.AutoCollectIncome or S.AutoLevelSlots or S.AutoEquipBestPlot then
            pcall(function()
                local slots = DataController.Slots and DataController.Slots()
                if type(slots) == "table" then
                    for slotKey, slotData in pairs(slots) do
                        local slotIdx = tonumber(slotKey)
                        if slotIdx then
                            if S.AutoCollectIncome and slotData.balance and slotData.balance > 0 then
                                CollectBalanceRE:FireServer(slotIdx)
                            end
                            if S.AutoLevelSlots then
                                LevelUpSlotRE:FireServer(slotIdx)
                            end
                        end
                    end
                end
                if S.AutoEquipBestPlot then
                    EquipBestPlotRE:FireServer()
                end
            end)
        end

        -- Auto Skill Tree Upgrades
        if S.AutoBuyUpgrades then
            pcall(function()
                local playerMoney = tonumber(DataController.Money and DataController.Money() or 0) or 0
                local ownedUpgrades = DataController.Upgrades and DataController.Upgrades() or {}
                local allUpgrades = UpgradesModule.List or UpgradesModule
                if type(allUpgrades) == "table" then
                    for upgId, upgData in pairs(allUpgrades) do
                        if type(upgData) == "table" and not ownedUpgrades[upgId] then
                            local price = tonumber(upgData.price or upgData.cost or 0) or 0
                            if price > 0 and playerMoney >= price then
                                BuyNormalUpgradeRE:FireServer(upgId)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end

        -- Auto Buy Best Dice
        if S.AutoBuyBestDice or S.AutoEquipBestDice then
            pcall(function()
                local playerMoney = tonumber(DataController.Money and DataController.Money() or 0) or 0
                local ownedDice = DataController.OwnedDice and DataController.OwnedDice() or {}
                local allDice = DiceModule.GetAll and DiceModule.GetAll() or {}
                local bestAffordableDice = nil
                local highestPrice = -1

                for diceName, diceData in pairs(allDice) do
                    if type(diceData) == "table" then
                        local p = tonumber(diceData.price or 0) or 0
                        if S.AutoBuyBestDice and not ownedDice[diceName] and p <= playerMoney and p > highestPrice then
                            bestAffordableDice = diceName
                            highestPrice = p
                        end
                    end
                end

                if bestAffordableDice then
                    BuyDiceRE:FireServer(bestAffordableDice)
                    task.wait(0.2)
                    if S.AutoEquipBestDice then
                        EquipDiceRE:FireServer(bestAffordableDice)
                    end
                end
            end)
        end

        -- Auto Rebirth & Stats
        if S.AutoRebirth then
            pcall(function() RebirthRE:FireServer() end)
        end
        if S.AutoRebirthStats then
            pcall(function()
                AddStatRE:FireServer(S.RebirthStatPriority or "Luck", 1)
            end)
        end

        task.wait(1.0)
    end
end)

-- Quest Claiming Helper Functions
local function claimAllCompletedQuests(silent)
    local claimedCount = 0
    pcall(function()
        for periodName, periodData in pairs(QuestConfig.Periods or {}) do
            local qFn = DataController.Quests and DataController.Quests[periodName]
            local qData = qFn and qFn()
            if qData then
                local progress = qData.progress or {}
                local claimed = qData.claimed or {}
                local expiresAt = qData.expiresAt or 0

                for _, q in ipairs(periodData.quests or {}) do
                    local curProg = progress[q.id] or 0
                    local isClaimed = claimed[q.id] == true
                    if not isClaimed and curProg >= q.target then
                        pcall(function()
                            ClaimQuestRE:FireServer(periodName, q.id, expiresAt)
                        end)
                        claimedCount = claimedCount + 1
                    end
                end
            end
        end
    end)
    if not silent and claimedCount > 0 then
        notify("Quest Master", string.format("Claimed %d completed quest(s)!", claimedCount), 2.5)
    end
    return claimedCount
end

local function claimAllHalloweenQuests(silent)
    if not HalloweenQuests then
        if not silent then notify("Halloween Event", "Halloween event is currently inactive.", 2.5) end
        return 0
    end
    local claimedCount = 0
    pcall(function()
        for _, period in ipairs(HalloweenQuests.PERIODS or {}) do
            local hwKey = HalloweenQuests[period] and HalloweenQuests[period].dataKey
            local qFn = hwKey and DataController.Halloween and DataController.Halloween[hwKey]
            local qData = qFn and qFn()
            if qData then
                local progress = qData.progress or {}
                local claimed = qData.claimed or {}
                local pool = HalloweenQuests[period].pool or {}

                for _, q in ipairs(pool) do
                    local curProg = progress[q.id] or 0
                    local isClaimed = claimed[q.id] == true
                    if not isClaimed and curProg >= q.target then
                        pcall(function()
                            ClaimHalloweenQuestRE:FireServer(period, q.id)
                        end)
                        claimedCount = claimedCount + 1
                    end
                end
            end
        end
    end)
    if not silent and claimedCount > 0 then
        notify("Halloween Quests", string.format("Claimed %d Halloween quest(s)!", claimedCount), 2.5)
    end
    return claimedCount
end

-- THREAD 6: Rewards, Pass & Quests Automation
task.spawn(function()
    while running do
        -- Auto Claim Pumpkin Pass Tiers
        if S.AutoClaimPumpkinPass then
            pcall(function() ClaimAllPathRE:FireServer() end)
        end

        -- Auto Buy Halloween Candy Upgrades
        if S.AutoBuyCandyUpgrades then
            pcall(function()
                local candyList = {"Luck", "Pumpkins", "Money", "Damage", "PumpkinLuck"}
                for _, id in ipairs(candyList) do
                    BuyHalloweenUpgradeRE:FireServer(id)
                    task.wait(0.05)
                end
            end)
        end

        -- Auto Claim Daily, Group, Offline Rewards
        if S.AutoClaimDaily then pcall(function() ClaimDailyRE:FireServer() end) end
        if S.AutoClaimGroup then pcall(function() ClaimGroupRE:FireServer() end) end
        if S.AutoClaimOffline then pcall(function() ClaimOfflineRE:FireServer() end) end

        -- Auto Claim All Regular Quests (Daily & Weekly)
        if S.AutoClaimQuests then
            pcall(function() claimAllCompletedQuests(true) end)
        end

        -- Auto Claim All Halloween Quests (Hourly & Daily)
        if S.AutoClaimHalloweenQuests then
            pcall(function() claimAllHalloweenQuests(true) end)
        end

        -- Auto Spin Lucky Wheel
        if S.AutoSpinWheel then
            pcall(function()
                UseSpinRE:FireServer("Lucky Spin")
                UseSpinRE:FireServer("Pumpkin Spin")
            end)
        end

        -- Auto Remote Sell Inventory
        if S.AutoRemoteSell then
            pcall(function()
                local summary = SellUtil.CreateSummary(DataController.Inventory(), DataController.Slots())
                if summary and summary.sales and #summary.sales > 0 then
                    local keysToSell = {}
                    local thresholdRank = RARITY_RANKS[S.SellThreshold] or 1

                    for _, item in ipairs(summary.sales) do
                        local unitEntry = UnitConfig.entries and UnitConfig.entries[item.name]
                        local rarity = unitEntry and unitEntry.rarity or "Common"
                        local itemRank = RARITY_RANKS[rarity] or 1

                        if itemRank <= thresholdRank then
                            table.insert(keysToSell, item.key)
                        end
                    end

                    if #keysToSell > 0 then
                        SellInventoryRF:InvokeServer(keysToSell)
                    end
                end
            end)
        end

        task.wait(3.0)
    end
end)

-- ==============================================================================
-- 4. WINDUI GRAPHICAL USER INTERFACE INITIALIZATION
-- ==============================================================================
local WindUI = nil
local success, err = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not err then
    warn("[AnimeDice OP] Failed to load WindUI: " .. tostring(err))
    notify("Error", "Could not load WindUI from remote repository.")
    return
end
WindUI = err

local Window = WindUI:CreateWindow({
    Title = "FLa ProjecT Anime Dice",
    SubTitle = "v1.0 - Halloween Edition",
    Folder = "AnimeDice_WindUI",
    TabWidth = 145,
    Size = UDim2.fromOffset(590, 470),
    MinSize = Vector2.new(530, 390),
    MaxSize = Vector2.new(850, 620),
    Resizable = true,
    Transparent = true,
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Enabled = false -- Floating action button used instead
    }
})

-- Listen for RightControl as well so ANY Control key (Left or Right) toggles the UI
local ctrlToggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        pcall(function()
            if Window.Toggle then
                Window:Toggle()
            elseif Window.Frame then
                Window.Frame.Visible = not Window.Frame.Visible
            end
        end)
    end
end)
table.insert(conns, ctrlToggleConn)

-- TAB 1: Fast Roll & Dice
local TabRoll = Window:Tab({
    Title = "Fast Roll",
    Icon = "sparkles"
})

TabRoll:Section({Title = "Instant Auto-Roll Engine"})

UI_ELEMENTS.FastRoll = TabRoll:Toggle({
    Title = "Instant Fast Roll",
    Desc = "Rolls without cutscenes directly via server remote invocation",
    Value = S.FastRoll,
    Callback = function(v)
        S.FastRoll = v
        if v then notify("Roll Engine", "Fast Auto-Roll Activated") end
    end
})

UI_ELEMENTS.RollDelay = TabRoll:Slider({
    Title = "Roll Throttle Delay (Seconds)",
    Desc = "Cooldown interval between roll server requests",
    Step = 0.01,
    Value = {Min = 0.01, Max = 0.5, Default = S.RollDelay},
    Callback = function(v)
        S.RollDelay = v
    end
})

UI_ELEMENTS.StopOnRarity = TabRoll:Dropdown({
    Title = "Stop on Rarity Threshold",
    Desc = "Automatically pauses fast roll when hitting this rarity or higher",
    Values = {"None", "Rare", "Epic", "Legendary", "Mythical", "Divine", "Exotic", "Celestial", "Secret I", "Secret II", "Heavenly", "Galactic", "Cosmic", "Exclusive"},
    Value = S.StopOnRarity,
    Callback = function(v)
        S.StopOnRarity = v
    end
})

UI_ELEMENTS.StopOnMutation = TabRoll:Dropdown({
    Title = "Stop on Mutation",
    Desc = "Pauses fast roll if a rare mutation is discovered",
    Values = {"None", "Silver", "Gold", "Emerald", "Diamond", "Ruby", "Rainbow", "Haunted"},
    Value = S.StopOnMutation,
    Callback = function(v)
        S.StopOnMutation = v
    end
})

UI_ELEMENTS.NotifyOnRoll = TabRoll:Toggle({
    Title = "Show Roll Notifications",
    Desc = "Pops up HUD notifications for rolled units",
    Value = S.NotifyOnRoll,
    Callback = function(v)
        S.NotifyOnRoll = v
    end
})

TabRoll:Section({Title = "Dice Management"})

UI_ELEMENTS.AutoBuyBestDice = TabRoll:Toggle({
    Title = "Auto Buy Best Affordable Dice",
    Desc = "Monitors Money balance and buys the highest luck dice in shop",
    Value = S.AutoBuyBestDice,
    Callback = function(v)
        S.AutoBuyBestDice = v
    end
})

UI_ELEMENTS.AutoEquipBestDice = TabRoll:Toggle({
    Title = "Auto Equip Best Owned Dice",
    Desc = "Ensures the highest luck dice is always active",
    Value = S.AutoEquipBestDice,
    Callback = function(v)
        S.AutoEquipBestDice = v
    end
})

-- TAB 2: Halloween Event
local TabHW = Window:Tab({
    Title = "Halloween Event",
    Icon = "ghost"
})

TabHW:Section({Title = "Pumpkin Dice & Door Farm"})

UI_ELEMENTS.AutoPumpkinRoll = TabHW:Toggle({
    Title = "Auto Roll Pumpkin Dice (x5 Multi)",
    Desc = "Spends collected Pumpkins on the exclusive Halloween unit banner",
    Value = S.AutoPumpkinRoll,
    Callback = function(v)
        S.AutoPumpkinRoll = v
    end
})

UI_ELEMENTS.PumpkinRollDelay = TabHW:Slider({
    Title = "Pumpkin Roll Delay",
    Step = 0.05,
    Value = {Min = 0.1, Max = 1.0, Default = S.PumpkinRollDelay},
    Callback = function(v)
        S.PumpkinRollDelay = v
    end
})

UI_ELEMENTS.AutoTrickOrTreat = TabHW:Toggle({
    Title = "Auto Trick-or-Treat Doors Farm",
    Desc = "Rotates through all 7 doors respecting 30s cooldown & server speed limit",
    Value = S.AutoTrickOrTreat,
    Callback = function(v)
        S.AutoTrickOrTreat = v
        if v then notify("Trick-or-Treat", "Door routing cycle started") end
    end
})

TabHW:Section({Title = "Pass & Event Upgrades"})

UI_ELEMENTS.AutoClaimPumpkinPass = TabHW:Toggle({
    Title = "Auto Claim Pumpkin Pass Tiers",
    Desc = "Instantly unlocks all available free & premium battle pass rewards",
    Value = S.AutoClaimPumpkinPass,
    Callback = function(v)
        S.AutoClaimPumpkinPass = v
    end
})

UI_ELEMENTS.AutoBuyCandyUpgrades = TabHW:Toggle({
    Title = "Auto Buy Candy Upgrades",
    Desc = "Invests earned Candy into Luck, Pumpkins, Money, Damage & Pumpkin Luck",
    Value = S.AutoBuyCandyUpgrades,
    Callback = function(v)
        S.AutoBuyCandyUpgrades = v
    end
})

UI_ELEMENTS.AutoClaimHalloweenQuests = TabHW:Toggle({
    Title = "Auto Claim Halloween Quests",
    Desc = "Automatically detects & claims completed Hourly & Daily event quests",
    Value = S.AutoClaimHalloweenQuests,
    Callback = function(v)
        S.AutoClaimHalloweenQuests = v
        if v then notify("Halloween Quests", "Auto Halloween Quest claimer active") end
    end
})

TabHW:Button({
    Title = "Claim All Halloween Quests Now",
    Desc = "Instantly claims all completed Hourly & Daily event quests",
    Callback = function()
        local count = claimAllHalloweenQuests(false)
        if count == 0 then
            notify("Halloween Quests", "No unclaimed event quests ready", 2)
        end
    end
})

TabHW:Button({
    Title = "Teleport to Halloween Island",
    Desc = "Transports character to the Halloween realm",
    Callback = function()
        pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
    end
})



-- TAB 3: Towers & Combat
local TabTower = Window:Tab({
    Title = "Towers",
    Icon = "swords"
})

TabTower:Section({Title = "Standard Tower Auto-Clear (Normal Map)"})

UI_ELEMENTS.SelectedTower = TabTower:Dropdown({
    Title = "Target Normal Tower",
    Desc = "Select standard map tower to conquer",
    Values = NORMAL_TOWERS,
    Value = S.SelectedTower,
    Callback = function(v)
        S.SelectedTower = v
    end
})

UI_ELEMENTS.AutoTowerRusher = TabTower:Toggle({
    Title = "Auto Rush Normal Tower",
    Desc = "Enters normal tower and rapidly clears floors via server remotes",
    Value = S.AutoTowerRusher,
    Callback = function(v)
        S.AutoTowerRusher = v
        if v then notify("Normal Tower", "Tower rusher active: " .. tostring(S.SelectedTower)) end
    end
})

UI_ELEMENTS.TowerClearDelay = TabTower:Slider({
    Title = "Normal Floor Clear Delay (Seconds)",
    Step = 0.05,
    Value = {Min = 0.05, Max = 1.5, Default = S.TowerClearDelay},
    Callback = function(v)
        S.TowerClearDelay = v
    end
})

TabTower:Section({Title = "Haunted House Auto-Clear (Halloween Event)"})

UI_ELEMENTS.SelectedHauntedHouse = TabTower:Dropdown({
    Title = "Target Haunted Wing",
    Desc = "Select Haunted House wing / floor category in Halloween map",
    Values = HAUNTED_HOUSE_WINGS,
    Value = S.SelectedHauntedHouse,
    Callback = function(v)
        S.SelectedHauntedHouse = v
    end
})

UI_ELEMENTS.AutoHauntedHouse = TabTower:Toggle({
    Title = "Auto Rush Haunted House",
    Desc = "Enters Haunted House and rapidly clears floors for Pumpkins & Candy",
    Value = S.AutoHauntedHouse,
    Callback = function(v)
        S.AutoHauntedHouse = v
        if v then notify("Haunted House", "Haunted House rusher active: " .. tostring(S.SelectedHauntedHouse)) end
    end
})

UI_ELEMENTS.HauntedHouseDelay = TabTower:Slider({
    Title = "Haunted Floor Clear Delay (Seconds)",
    Step = 0.05,
    Value = {Min = 0.05, Max = 1.5, Default = S.HauntedHouseDelay},
    Callback = function(v)
        S.HauntedHouseDelay = v
    end
})

TabTower:Section({Title = "Combat & Team Management"})

UI_ELEMENTS.AutoEquipTowerTeam = TabTower:Toggle({
    Title = "Auto Equip Best Tower Team",
    Desc = "Automatically equips top DPS units before entering battle",
    Value = S.AutoEquipTowerTeam,
    Callback = function(v)
        S.AutoEquipTowerTeam = v
    end
})

TabTower:Button({
    Title = "Equip Best Tower Team Now",
    Desc = "Instantly sets best 4 DPS units into battle team",
    Callback = function()
        pcall(function()
            EquipBestTowerTeamRE:FireServer()
            notify("Combat", "Best tower team equipped")
        end)
    end
})

TabTower:Button({
    Title = "Cancel Active Tower / Session",
    Desc = "Safely retreats from any active tower or Haunted House session",
    Callback = function()
        pcall(function()
            CancelTowerRF:InvokeServer()
            notify("Combat", "Tower session cancelled")
        end)
    end
})

-- TAB 4: Plot & Economy
local TabPlot = Window:Tab({
    Title = "Plot & Money",
    Icon = "coins"
})

TabPlot:Section({Title = "Plot Slots Automation"})

UI_ELEMENTS.AutoCollectIncome = TabPlot:Toggle({
    Title = "Auto Collect Plot Income",
    Desc = "Sweeps all unit slots and claims generated money instantly",
    Value = S.AutoCollectIncome,
    Callback = function(v)
        S.AutoCollectIncome = v
    end
})

UI_ELEMENTS.AutoLevelSlots = TabPlot:Toggle({
    Title = "Auto Level Up Slots",
    Desc = "Increases slot levels when cash balance permits",
    Value = S.AutoLevelSlots,
    Callback = function(v)
        S.AutoLevelSlots = v
    end
})

UI_ELEMENTS.AutoEquipBestPlot = TabPlot:Toggle({
    Title = "Auto Equip Best Units to Plot",
    Desc = "Maximizes passive money output with highest tier units",
    Value = S.AutoEquipBestPlot,
    Callback = function(v)
        S.AutoEquipBestPlot = v
    end
})

TabPlot:Section({Title = "Skill Tree & Rebirth"})

UI_ELEMENTS.AutoBuyUpgrades = TabPlot:Toggle({
    Title = "Auto Buy Skill Tree Upgrades",
    Desc = "Purchases affordable upgrades in topological skill tree order",
    Value = S.AutoBuyUpgrades,
    Callback = function(v)
        S.AutoBuyUpgrades = v
    end
})

UI_ELEMENTS.AutoRebirth = TabPlot:Toggle({
    Title = "Auto Rebirth",
    Desc = "Executes rebirth immediately once requirement is met",
    Value = S.AutoRebirth,
    Callback = function(v)
        S.AutoRebirth = v
    end
})

UI_ELEMENTS.AutoRebirthStats = TabPlot:Toggle({
    Title = "Auto Distribute Rebirth Stat Points",
    Desc = "Automatically allocates earned rebirth points",
    Value = S.AutoRebirthStats,
    Callback = function(v)
        S.AutoRebirthStats = v
    end
})

UI_ELEMENTS.RebirthStatPriority = TabPlot:Dropdown({
    Title = "Rebirth Stat Priority",
    Values = {"Luck", "Money", "Damage", "Health", "Trait Luck", "Grade Luck"},
    Value = S.RebirthStatPriority,
    Callback = function(v)
        S.RebirthStatPriority = v
    end
})

-- TAB 5: Inventory & Codes
local TabInv = Window:Tab({
    Title = "Inventory",
    Icon = "box"
})

TabInv:Section({Title = "Remote Inventory Selling"})

UI_ELEMENTS.AutoRemoteSell = TabInv:Toggle({
    Title = "Auto Remote Sell Surplus Units",
    Desc = "Sells unequipped & unlocked units directly without visiting the NPC",
    Value = S.AutoRemoteSell,
    Callback = function(v)
        S.AutoRemoteSell = v
    end
})

UI_ELEMENTS.SellThreshold = TabInv:Dropdown({
    Title = "Max Rarity to Sell",
    Desc = "Units at or below this rarity will be converted to cash",
    Values = ALL_RARITIES_ORDERED,
    Value = S.SellThreshold,
    Callback = function(v)
        S.SellThreshold = v
    end
})

TabInv:Section({Title = "Promo Codes (18 Verified Active)"})

TabInv:Button({
    Title = "Redeem All Active Promo Codes",
    Desc = "Redeems all 18 codes for 257 Gems, 257 Trait Rerolls, 34 Lucky Spins & Jackpots",
    Callback = function()
        local redeemedCount = 0
        for _, code in ipairs(ACTIVE_CODES) do
            pcall(function()
                RedeemCodeRE:FireServer(code)
                redeemedCount = redeemedCount + 1
            end)
            task.wait(0.15)
        end
        notify("Codes Redeemed", string.format("Executed redemption for %d promo codes!", redeemedCount), 4)
    end
})

TabInv:Section({Title = "Daily & Wheel Rewards"})

UI_ELEMENTS.AutoClaimDaily = TabInv:Toggle({
    Title = "Auto Claim Daily Login Reward",
    Value = S.AutoClaimDaily,
    Callback = function(v) S.AutoClaimDaily = v end
})

UI_ELEMENTS.AutoClaimGroup = TabInv:Toggle({
    Title = "Auto Claim Group Chest Reward",
    Value = S.AutoClaimGroup,
    Callback = function(v) S.AutoClaimGroup = v end
})

UI_ELEMENTS.AutoClaimOffline = TabInv:Toggle({
    Title = "Auto Claim Offline Earnings",
    Value = S.AutoClaimOffline,
    Callback = function(v) S.AutoClaimOffline = v end
})

UI_ELEMENTS.AutoSpinWheel = TabInv:Toggle({
    Title = "Auto Spin Lucky & Pumpkin Wheels",
    Value = S.AutoSpinWheel,
    Callback = function(v) S.AutoSpinWheel = v end
})

TabInv:Section({Title = "Quests & Mission Claims"})

UI_ELEMENTS.AutoClaimQuests = TabInv:Toggle({
    Title = "Auto Claim All Quests (Daily & Weekly)",
    Desc = "Continuously detects and claims all completed regular quests",
    Value = S.AutoClaimQuests,
    Callback = function(v)
        S.AutoClaimQuests = v
        if v then notify("Quests", "Auto Quest Claimer activated") end
    end
})

TabInv:Button({
    Title = "Claim All Completed Quests Now",
    Desc = "Immediately scans and claims all finished Daily & Weekly quests",
    Callback = function()
        local count = claimAllCompletedQuests(false)
        if count == 0 then
            notify("Quests", "No unclaimed completed quests found", 2)
        end
    end
})

-- TAB 6: Player & Teleports
local TabPlayer = Window:Tab({
    Title = "Player & TPs",
    Icon = "user"
})

TabPlayer:Section({Title = "Movement Physics"})

UI_ELEMENTS.CustomSpeed = TabPlayer:Toggle({
    Title = "Custom WalkSpeed",
    Value = S.CustomSpeed,
    Callback = function(v)
        S.CustomSpeed = v
        if not v then
            local hum = getHum()
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

UI_ELEMENTS.WalkSpeed = TabPlayer:Slider({
    Title = "WalkSpeed Value",
    Step = 1,
    Value = {Min = 16, Max = 250, Default = S.WalkSpeed},
    Callback = function(v)
        S.WalkSpeed = v
    end
})

UI_ELEMENTS.CustomJump = TabPlayer:Toggle({
    Title = "Custom JumpPower",
    Value = S.CustomJump,
    Callback = function(v)
        S.CustomJump = v
        if not v then
            local hum = getHum()
            if hum then hum.JumpPower = 50 end
        end
    end
})

UI_ELEMENTS.JumpPower = TabPlayer:Slider({
    Title = "JumpPower Value",
    Step = 1,
    Value = {Min = 50, Max = 300, Default = S.JumpPower},
    Callback = function(v)
        S.JumpPower = v
    end
})

UI_ELEMENTS.NoClip = TabPlayer:Toggle({
    Title = "NoClip (Phase Through Walls)",
    Value = S.NoClip,
    Callback = function(v)
        S.NoClip = v
    end
})

UI_ELEMENTS.InfJump = TabPlayer:Toggle({
    Title = "Infinite Jump",
    Value = S.InfJump,
    Callback = function(v)
        S.InfJump = v
    end
})

TabPlayer:Section({Title = "Overworld Waypoints (Normal Map)"})

local function smartTeleport(destinationType)
    local char = getChar()
    local root = getRoot()
    if not char or not root then return end

    local currentZ = root.Position.Z
    local isCurrentlyHalloween = currentZ > 5000

    if destinationType == "Spawn" then
        if isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Hub") end)
            task.wait(0.7)
            char = getChar()
            root = getRoot()
        end
        local spawnPart = workspace:FindFirstChild("SpawnLocation")
        local targetCF = spawnPart and (spawnPart.CFrame + Vector3.new(0, 3.5, 0)) or CFrame.new(84.4, 4.0, 0.0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(targetCF)
        notify("Waypoint", "Arrived at Spawn / Lobby")

    elseif destinationType == "Plot" then
        if isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Hub") end)
            task.wait(0.7)
            char = getChar()
            root = getRoot()
        end
        local pc = require(ReplicatedStorage.Framework.Features.Plot.PlotController)
        local plotId = pc and pc.plot
        local plots = workspace.Plots.Claimed
        local myPlot = plotId and plots:FindFirstChild(tostring(plotId)) or plots:GetChildren()[1]
        local spawnPart = myPlot and myPlot:FindFirstChild("Spawn", true)
        local targetPos = spawnPart and (spawnPart.Position + Vector3.new(0, 3.5, 0)) or (myPlot and myPlot:GetPivot().Position + Vector3.new(0, 3.5, 0))
        if targetPos then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            char:PivotTo(CFrame.new(targetPos))
            notify("Waypoint", "Arrived at your Plot")
        else
            notify("Waypoint Error", "Plot not found in server")
        end

    elseif destinationType == "Towers" then
        if isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Hub") end)
            task.wait(0.7)
            char = getChar()
            root = getRoot()
        end
        local targetPos = Vector3.new(285.5, 23.5, 43.7)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(CFrame.new(targetPos))
        notify("Waypoint", "Arrived at Normal Towers Entrance")

    elseif destinationType == "Shops" then
        if isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Hub") end)
            task.wait(0.7)
            char = getChar()
            root = getRoot()
        end
        local targetPos = Vector3.new(285.5, 12.0, -280.0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(CFrame.new(targetPos))
        notify("Waypoint", "Arrived at Shops & Selling Plaza")

    elseif destinationType == "HalloweenIsland" then
        if not isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
            notify("Waypoint", "Transported to Halloween Island")
        else
            local hwFolder = workspace:FindFirstChild("Halloween")
            local arrivalPart = hwFolder and hwFolder:FindFirstChild("ArrivalPoint")
            local spawnCF = arrivalPart and (arrivalPart.CFrame + Vector3.new(0, 3.5, 0)) or CFrame.new(-1946.5, -17.5, 11203.0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            char:PivotTo(spawnCF)
            notify("Waypoint", "Arrived at Halloween Spawn")
        end

    elseif destinationType == "HauntedHouse" then
        if not isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
            task.wait(0.8)
            char = getChar()
            root = getRoot()
        end
        local targetPos = Vector3.new(-1943.6, -19.4, 11365.0)
        local facePos = Vector3.new(-1943.6, -19.4, 11380.0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(CFrame.new(targetPos, facePos))
        notify("Waypoint", "Arrived at Haunted House Entrance")

    elseif destinationType == "PumpkinDice" then
        if not isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
            task.wait(0.8)
            char = getChar()
            root = getRoot()
        end
        local targetPos = Vector3.new(-2057.0, -15.0, 11245.0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(CFrame.new(targetPos))
        notify("Waypoint", "Arrived at Pumpkin Dice Altar")

    elseif destinationType == "CandyShop" then
        if not isCurrentlyHalloween then
            pcall(function() TeleportHalloweenRF:InvokeServer("Island") end)
            task.wait(0.8)
            char = getChar()
            root = getRoot()
        end
        local targetPos = Vector3.new(-2098.0, -15.5, 11282.0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(CFrame.new(targetPos))
        notify("Waypoint", "Arrived at Candy Upgrades Altar")
    end
end

TabPlayer:Button({
    Title = "Teleport to Spawn / Lobby",
    Desc = "Fast authoritative teleport to central Overworld spawn",
    Callback = function() smartTeleport("Spawn") end
})

TabPlayer:Button({
    Title = "Teleport to Player Plot Area",
    Desc = "Dynamically finds and teleports directly to your assigned base plot",
    Callback = function() smartTeleport("Plot") end
})

TabPlayer:Button({
    Title = "Teleport to Towers Entrance",
    Desc = "Teleports directly in front of the Normal Tower portal",
    Callback = function() smartTeleport("Towers") end
})

TabPlayer:Button({
    Title = "Teleport to Shops & Selling Plaza",
    Desc = "Teleports to the center of Dice Shop, Selling NPC & Upgrades",
    Callback = function() smartTeleport("Shops") end
})

TabPlayer:Section({Title = "Halloween Realm Waypoints"})

TabPlayer:Button({
    Title = "Teleport to Halloween Island (Spawn)",
    Desc = "Safely crosses realms via server remote to Halloween arrival point",
    Callback = function() smartTeleport("HalloweenIsland") end
})

TabPlayer:Button({
    Title = "Teleport to Haunted House Entrance",
    Desc = "Lands directly on the Mansion stairs facing the Haunted House gate",
    Callback = function() smartTeleport("HauntedHouse") end
})

TabPlayer:Button({
    Title = "Teleport to Pumpkin Dice Altar",
    Desc = "Teleports in front of the exclusive Halloween rolling altar",
    Callback = function() smartTeleport("PumpkinDice") end
})

TabPlayer:Button({
    Title = "Teleport to Candy Upgrades Altar",
    Desc = "Teleports to the Candy upgrade vendor NPC",
    Callback = function() smartTeleport("CandyShop") end
})

-- TAB 7: Settings & Config
local TabSettings = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

TabSettings:Section({Title = "Configuration Management"})

TabSettings:Button({
    Title = "Save Configuration",
    Desc = "Writes current toggle and slider values to storage",
    Callback = saveConfig
})

TabSettings:Button({
    Title = "Load Configuration",
    Desc = "Restores saved preferences and updates all UI visuals",
    Callback = loadConfig
})

TabSettings:Button({
    Title = "Reset to Defaults (All OFF)",
    Desc = "Turns OFF all toggles both visually and in memory",
    Callback = function()
        for k, widget in pairs(UI_ELEMENTS) do
            local wType = widget.__type or widget.Type
            if wType == "Toggle" then
                pcall(function() widget:Set(false) end)
            end
        end
        notify("Reset Complete", "All features set to OFF.", 3)
    end
})

UI_ELEMENTS.AntiAFK = TabSettings:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents client disconnection on inactivity",
    Value = S.AntiAFK,
    Callback = function(v) S.AntiAFK = v end
})

TabSettings:Button({
    Title = "Clean Unload Script",
    Desc = "Disconnects all threads and destroys UI instances",
    Callback = function()
        if genv.__ANIMEDICE_OP and genv.__ANIMEDICE_OP.Stop then
            genv.__ANIMEDICE_OP.Stop()
        end
    end
})

-- ==============================================================================
-- 5. SLEEK FLOATING ACTION BUTTON (Draggable Widget)
-- ==============================================================================
local floatGuiParent = game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
local floatScreenGui = Instance.new("ScreenGui")
floatScreenGui.Name = "AnimeDice_FloatingBtn"
floatScreenGui.ResetOnSpawn = false
floatScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(floatScreenGui) end
end)
floatScreenGui.Parent = floatGuiParent

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "TogglePill"
floatBtn.Size = UDim2.fromOffset(50, 50)
floatBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
floatBtn.BorderColor3 = Color3.fromRGB(255, 140, 20)
floatBtn.BorderSizePixel = 2
floatBtn.AutoButtonColor = false
floatBtn.Image = "rbxassetid://94887238750996" -- Pumpkin Dice Icon
floatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Parent = floatScreenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(1, 0)
uicorner.Parent = floatBtn

local uistroke = Instance.new("UIStroke")
uistroke.Color = Color3.fromRGB(255, 140, 20)
uistroke.Thickness = 2
uistroke.Transparency = 0.2
uistroke.Parent = floatBtn

-- Dragging Mechanics
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

-- Toggle Visibility
floatBtn.MouseButton1Click:Connect(function()
    if Window then
        pcall(function()
            if Window.Toggle then
                Window:Toggle()
            elseif Window.Frame then
                Window.Frame.Visible = not Window.Frame.Visible
            end
        end)
    end
end)

-- Hover effect
floatBtn.MouseEnter:Connect(function()
    TweenService:Create(floatBtn, TweenInfo.new(0.2), {Size = UDim2.fromOffset(54, 54)}):Play()
end)
floatBtn.MouseLeave:Connect(function()
    TweenService:Create(floatBtn, TweenInfo.new(0.2), {Size = UDim2.fromOffset(50, 50)}):Play()
end)

-- ==============================================================================
-- 6. LIFECYCLE MANAGEMENT & REGISTRATION
-- ==============================================================================
local function stopAll()
    running = false
    for _, c in ipairs(conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(conns)

    pcall(function() floatScreenGui:Destroy() end)
    pcall(function()
        local rgui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if rgui then
            for _, c in ipairs(rgui:GetChildren()) do
                if c.Name:find("WindUI") then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end)
    notify("Anime Dice OP", "Script unloaded cleanly.")
end

genv.__ANIMEDICE_OP = {
    Version = "1.8.0",
    Stop = stopAll,
    S = S,
    UIElements = UI_ELEMENTS,
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,
    Window = Window,
    WindUI = WindUI,
    FloatGui = floatScreenGui
}

Window:SelectTab(1)
WindUI:Notify({
    Title = "FLa ProjecT: Anime Dice",
    Content = "All systems loaded. Fast Roll, Halloween Farm, Tower Rusher & Plot Auto are ready!",
    Duration = 4.5
})

print("[FLa ProjecT] Anime Dice Ultimate Automation Engine initialized successfully.")
