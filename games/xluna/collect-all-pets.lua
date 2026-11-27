-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB | Collect All Pets!
    Author: By XLunaHUB
]]

local _STATE = type(STATE) == "table" and STATE or nil

local function ensureIdentity()
    if type(setthreadidentity) == "function" then
        pcall(setthreadidentity, 8)
    end
end
ensureIdentity()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

-- Cross-chunk cleanup via Instance signal (works reliably across all getgenv() views)
local CLEANUP_SIGNAL_NAME = "__XLunaHUB_CAP_CleanupSignal"
do
    local oldSignal = ReplicatedStorage:FindFirstChild(CLEANUP_SIGNAL_NAME)
    if oldSignal and oldSignal:IsA("BindableEvent") then
        pcall(function() oldSignal:Fire() end)
        task.wait(0.05)
        pcall(function() oldSignal:Destroy() end)
    end
end

-- Purge any orphaned WindUI ScreenGuis left behind by previous executions
local function purgeOrphanedWindUIs()
    local containers = { CoreGui, CoreGui:FindFirstChild("RobloxGui") }
    pcall(function()
        if type(gethui) == "function" then
            table.insert(containers, gethui())
        end
    end)
    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("ScreenGui") and (
                    child.Name == "WindUI"
                    or child.Name == "WindUI/Notifications"
                    or child.Name == "WindUI/Dropdowns"
                    or child.Name == "WindUI/Tooltips"
                ) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end
purgeOrphanedWindUIs()

local CleanupSignal = Instance.new("BindableEvent")
CleanupSignal.Name = CLEANUP_SIGNAL_NAME
CleanupSignal.Parent = ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

-- Tracked resources for clean teardown
local Connections = {}
local CleanupCallbacks = {}
local Running = true

local function trackConnection(conn)
    if conn then
        table.insert(Connections, conn)
        if _STATE and _STATE.connect then
            -- Note: _STATE.connect expects (signal, fn); manual connections are cleaned in onCleanup
        end
    end
    return conn
end

local function connectSignal(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(Connections, conn)
    return conn
end

local function onCleanup(fn)
    table.insert(CleanupCallbacks, fn)
end

local function isAlive()
    if _STATE and _STATE.alive then
        return Running and _STATE.alive()
    end
    return Running
end

-- Game Modules & Constants
local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local HyperTest = require(ReplicatedStorage:WaitForChild("HyperTest"))
local DB = ReplicatedStorage:WaitForChild("DB")
local PetsDB = require(DB:WaitForChild("Pets"))
local EggPrices = require(DB:WaitForChild("EggPrices"))
local AreaRequirements = require(DB:WaitForChild("AreaRequirements"))
local StatIncreasePrices = require(DB:WaitForChild("StatIncreasePrices"))
local PetEquipSlotPrices = require(DB:WaitForChild("PetEquipSlotPrices"))
local UpgradeTreeDB = require(DB:WaitForChild("UpgradeTree"))
local BadgeRequirements = require(DB:WaitForChild("BadgeRequirements"))
local OverclocksDB = require(DB:WaitForChild("Overclocks"))
local TitaniumCraftingDB = require(DB:WaitForChild("TitaniumCrafting"))
local ResearchDB = require(DB:WaitForChild("Research"))
local ResearchTierRequirements = require(DB:WaitForChild("ResearchTierRequirements"))
ensureIdentity()

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UIRemotes = ReplicatedStorage:WaitForChild("UI"):WaitForChild("Remotes")
local MiningFolder = ReplicatedStorage:WaitForChild("Mining")

local RemoteDrop = Remotes:WaitForChild("Drop")
local RemoteStoneDrop = Remotes:WaitForChild("StoneDrop")
local RemoteBuyEgg = Remotes:WaitForChild("BuyEgg")
local RemoteHatchEgg = Remotes:WaitForChild("HatchEgg")
local RemoteFusePets = Remotes:WaitForChild("FusePets")
local RemoteAutoFuse = Remotes:WaitForChild("AutoFuse")
local RemoteEquipBest = Remotes:WaitForChild("EquipBest")
local RemoteEquipExoticPet = Remotes:WaitForChild("EquipExoticPet")
local RemoteDispose = Remotes:WaitForChild("Dispose")
local RemoteClaimQuestReward = Remotes:WaitForChild("ClaimQuestReward")
local RemoteCollectHiddenEgg = Remotes:WaitForChild("CollectHiddenEgg")
local RemoteClaimDailyEgg = Remotes:WaitForChild("ClaimDailyEgg")
local RemoteClaimSubBoost = Remotes:WaitForChild("ClaimSubBoost")
local RemoteClaimMushBoost = Remotes:WaitForChild("ClaimMushBoost")
local RemoteBuyStatIncrease = Remotes:WaitForChild("BuyStatIncrease")
local RemoteBuyPetEquipSlot = Remotes:WaitForChild("BuyPetEquipSlot")
local RemoteBuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
local RemoteUnlockBadge = Remotes:WaitForChild("UnlockBadge")
local RemoteOpenDoor = Remotes:WaitForChild("OpenDoor")
local RemoteOnAreaButton = Remotes:WaitForChild("OnAreaButton")
local RemoteRedeemCode = Remotes:WaitForChild("RedeemCode")
local RemoteSetGeneratorEgg = Remotes:WaitForChild("SetGeneratorEgg")
local RemoteSetGeneratorOn = Remotes:WaitForChild("SetGeneratorOn")
local RemoteSetGeneratorCrank = Remotes:WaitForChild("SetGeneratorCrank")
local RemoteSetAutoEquip = Remotes:WaitForChild("SetAutoEquip")
local RemoteSetAutoFuse = Remotes:WaitForChild("SetAutoFuse")
local RemoteSetAutoCalcify = Remotes:WaitForChild("SetAutoCalcify")
local RemoteCalcifyAll = Remotes:WaitForChild("CalcifyAll")
local RemoteClaimTask = Remotes:WaitForChild("ClaimTask")
local RemoteGetResearch = Remotes:WaitForChild("GetResearch")
local RemoteIncreaseResearch = Remotes:WaitForChild("IncreaseResearch")
local RemoteCraft = Remotes:WaitForChild("Craft")
local RemoteSetSetting = Remotes:WaitForChild("SetSetting")

local RemoteStartRebirth = UIRemotes:WaitForChild("StartRebirth")
local RemoteMine = MiningFolder:WaitForChild("MineRemote")
local RemoteCancelMine = MiningFolder:WaitForChild("Cancel")
local RemoteSetOverclock = MiningFolder:WaitForChild("SetOverclock")

-- Safe Bindable Invoker (restores Real thread capability after game call)
local function safeInvoke(bindableName)
    local bf = LocalPlayer:FindFirstChild(bindableName)
    if not bf then
        ensureIdentity()
        return nil
    end
    local ok, res = pcall(function()
        return bf:Invoke()
    end)
    ensureIdentity()
    if ok then
        return res
    end
    return nil
end

local function safeGetStatValue(name, defaultVal)
    local obj = LocalPlayer:FindFirstChild(name)
    if obj and obj:IsA("ValueBase") then
        return obj.Value
    end
    return defaultVal
end

-- Feature State (ALL OFF by default)
local State = {
    AutoCollectDrops = false,
    SuppressDropFX = false,
    AutoClaimQuests = false,
    AutoHiddenEggs = false,
    AutoDailyEgg = false,
    AutoSubMushBoost = false,
    AutoOpenDoors = false,
    AutoLockHighestArea = false,
    WalkSpeedEnabled = false,
    WalkSpeedValue = 32,

    SelectedEgg = "Best Affordable",
    AutoHatch = false,
    HatchDelay = 0.25,
    SkipAnimations = false,

    SelectedGiantEgg = "1 - Common",
    AutoMineGiant = false,
    TeleportToGiant = true,

    AutoEquipBest = false,
    AutoFuseCustom = false,
    FuseMaxRarity = "Legendary (5)",
    FuseProtectEquipped = true,
    FuseProtectShiny = true,
    FuseProtectMetallic = true,
    FuseProtectGiant = true,
    AutoFuseGamepass = false,

    SelectedGoldStats = { "Damage", "DropRate", "Speed", "DropCollectionRange" },
    AutoBuyGoldStats = false,
    AutoBuyEquipSlots = false,
    AutoBuyRebirthTree = false,
    AutoBuyRunes = false,

    GeneratorEggRarity = "1 - Common",
    GeneratorEnabled = false,
    AutoCrank = false,
    AutoCalcifyLoop = false,

    AutoClaimLabTasks = false,
    AutoUpgradeResearch = false,
    AutoUnlockBadges = false,

    HideOtherPets = false,
    AntiAFK = false,
    ConfigName = "default",
}

-- Helpers
local RarityMap = {
    ["Common (1)"] = 1,
    ["Uncommon (2)"] = 2,
    ["Rare (3)"] = 3,
    ["Epic (4)"] = 4,
    ["Legendary (5)"] = 5,
    ["Prodigious (6)"] = 6,
    ["Ascended (7)"] = 7,
    ["Mythical (8)"] = 8,
}

local EggRarityDropdownValues = {
    "Best Affordable",
    "Common (1)",
    "Uncommon (2)",
    "Rare (3)",
    "Epic (4)",
    "Legendary (5)",
    "Prodigious (6)",
    "Ascended (7)",
}

local FuseCeilingValues = {
    "Uncommon (2)",
    "Rare (3)",
    "Epic (4)",
    "Legendary (5)",
    "Prodigious (6)",
    "Ascended (7)",
    "Mythical (8)",
}

local GiantEggValues = {
    "1 - Common",
    "2 - Uncommon",
    "3 - Rare",
    "4 - Epic",
    "5 - Legendary",
    "6 - Prodigious",
    "7 - Ascended",
    "8 - Mythical",
}

local AreaOptions = {
    "0 - Unlocked (Free)",
    "1 - The Meadow",
    "2 - The Forest",
    "3 - The Desert",
    "4 - The Arctic",
    "5 - The Beach",
    "6 - The Mountains",
    "7 - The Jungle",
    "8 - The Grotto",
    "9 - The Grove",
    "10 - The Mine",
}

local GoldStatNames = {
    "Damage",
    "DropRate",
    "Speed",
    "DropCollectionRange",
    "BonusDropCollectionRange",
    "ShinyLuck",
    "ShinyStoneLuck",
    "ExoticChance",
}

local RuneStatNames = {
    "RuneGoldMult",
    "RuneShinyLuck",
    "RuneMetallicLuck",
    "RuneGiantLuck",
    "RuneEggLuck",
}

local BadgeCategories = {
    { Key = "PetScore", Stat = "PetScore", Unlocked = "Badge_PetScore" },
    { Key = "GoldEarned", Stat = "GoldEarned", Unlocked = "Badge_GoldEarned" },
    { Key = "QuestsCompleted", Stat = "QuestsCompleted", Unlocked = "Badge_QuestsCompleted" },
    { Key = "DropsCollected", Stat = "DropsCollected", Unlocked = "Badge_DropsCollected" },
    { Key = "CrystalsDestroyed", Stat = "CrystalsDestroyed", Unlocked = "Badge_CrystalsDestroyed" },
    { Key = "Rebirths", Stat = "TotalRebirths", Unlocked = "Badge_Rebirths" },
    { Key = "ShinyScore", Stat = "ShinyScore", Unlocked = "Badge_ShinyScore" },
    { Key = "ExoticCrystalScore", Stat = "ExoticCrystalScore", Unlocked = "Badge_ExoticCrystalScore" },
    { Key = "MetallicScore", Stat = "MetallicScore", Unlocked = "Badge_MetallicScore" },
    { Key = "GiantScore", Stat = "GiantScore", Unlocked = "Badge_GiantScore" },
    { Key = "ShinyGiantScore", Stat = "ShinyGiantScore", Unlocked = "Badge_ShinyGiantScore" },
    { Key = "Ascensions", Stat = "Ascensions", Unlocked = "Badge_Ascensions" },
}

local DoorAreaMap = {
    { Index = 1, Prop = "Door_1", AreaReq = 5 },
    { Index = 2, Prop = "Door_2", AreaReq = 7 },
    { Index = 4, Prop = "Door_4", AreaReq = 9 },
    { Index = 5, Prop = "Door_5", AreaReq = 10 },
    { Index = 6, Prop = "Door_6", AreaReq = 10 },
}

local KnownCodes = {
    "FirstCodeEver",
    "4815162342",
    "SecretCode",
    "100k",
    "Metallic",
    "Shiny",
    "Fusion",
    "Penta",
    "Tree",
    "Speedy",
    "Seasons",
    "Click",
    "Amusement",
    "IfOnlyYouKnew",
    "LookOut",
    "Sub2TwoZoos",
}

local function getEggPrice(rarity)
    local tree = safeInvoke("GetUpgradeTree") or {}
    local tbl = EggPrices.Default
    if tree.Even_Cheaper_Eggs then
        tbl = EggPrices.EvenCheap
    elseif tree.Cheaper_Eggs then
        tbl = EggPrices.Cheap
    end
    return tbl[rarity] or math.huge
end

local function getMaxAffordableEggRarity(gold)
    local best = nil
    for r = 7, 1, -1 do
        local price = getEggPrice(r)
        if gold >= price then
            best = r
            break
        end
    end
    return best
end

local function restoreHatcherUI()
    local hatcherFrame = ScreenGui:FindFirstChild("Hatcher")
    local autoFuseFrame = ScreenGui:FindFirstChild("AutoFuse")
    local mainFrame = ScreenGui:FindFirstChild("Main")
    if hatcherFrame then
        hatcherFrame.Visible = false
    end
    if autoFuseFrame then
        autoFuseFrame.Visible = false
    end
    if mainFrame then
        mainFrame.Visible = true
    end
    local uiState = ReplicatedStorage:FindFirstChild("UIState")
    if uiState and uiState.Value ~= "main" then
        uiState.Value = "main"
    end
    pcall(function()
        local blur = Lighting:FindFirstChild("Blur")
        if blur and blur.Enabled then
            blur.Enabled = false
        end
    end)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if cam then
        if cam.CameraType ~= Enum.CameraType.Custom then
            cam.CameraType = Enum.CameraType.Custom
        end
        if hum and cam.CameraSubject ~= hum then
            cam.CameraSubject = hum
        end
    end
    pcall(function()
        local pm = require(PlayerScripts:WaitForChild("PlayerModule"))
        local controls = pm:GetControls()
        if controls then
            if not controls.activeController or not controls.activeController.enabled then
                controls:Enable()
            end
        end
    end)
    ensureIdentity()
end

local function isHatcherLocked()
    local uiState = ReplicatedStorage:FindFirstChild("UIState")
    if uiState and uiState.Value ~= "main" then
        return true
    end
    local hatcherFrame = ScreenGui:FindFirstChild("Hatcher")
    if hatcherFrame and hatcherFrame.Visible then
        return true
    end
    local autoFuseFrame = ScreenGui:FindFirstChild("AutoFuse")
    if autoFuseFrame and autoFuseFrame.Visible then
        return true
    end
    local blur = Lighting:FindFirstChild("Blur")
    if blur and blur.Enabled then
        return true
    end
    local cam = workspace.CurrentCamera
    if cam and cam.CameraType ~= Enum.CameraType.Custom then
        return true
    end
    local lockedByCtrl = false
    pcall(function()
        local pm = require(PlayerScripts:WaitForChild("PlayerModule"))
        local controls = pm:GetControls()
        if controls and controls.activeController and not controls.activeController.enabled then
            lockedByCtrl = true
        end
    end)
    ensureIdentity()
    return lockedByCtrl
end

local SuppressedConnections = {}

local function getCutsceneSignals()
    local list = {
        RemoteHatchEgg.OnClientEvent,
        RemoteFusePets.OnClientEvent,
        RemoteAutoFuse.OnClientEvent,
    }
    local hatcherFrame = ScreenGui:FindFirstChild("Hatcher")
    if hatcherFrame then
        local sp = hatcherFrame:FindFirstChild("ShowcasePet")
        if sp and sp:IsA("BindableEvent") then
            table.insert(list, sp.Event)
        end
        local fe = hatcherFrame:FindFirstChild("Fuse")
        if fe and fe:IsA("BindableEvent") then
            table.insert(list, fe.Event)
        end
    end
    return list
end

local function applyAnimationSuppression(enabled)
    if enabled then
        if type(getconnections) == "function" then
            for _, sig in ipairs(getCutsceneSignals()) do
                pcall(function()
                    for _, conn in ipairs(getconnections(sig)) do
                        if conn.Enabled then
                            conn:Disable()
                            table.insert(SuppressedConnections, conn)
                        end
                    end
                end)
            end
        end
        restoreHatcherUI()
    else
        for _, conn in ipairs(SuppressedConnections) do
            pcall(function()
                conn:Enable()
            end)
        end
        table.clear(SuppressedConnections)
    end
end

local function getDefaultGameWalkSpeed()
    return 24 * (1 + safeGetStatValue("Speed", 0) / 100)
end

-- Restore original game scripts & walkspeed on teardown
onCleanup(function()
    Running = false
    applyAnimationSuppression(false)
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and State.WalkSpeedEnabled then
            hum.WalkSpeed = getDefaultGameWalkSpeed()
        end
    end)
end)

-- Instant Drop & StoneDrop Interceptors
connectSignal(RemoteDrop.OnClientEvent, function(startId, _pos, sizesTable)
    if not State.AutoCollectDrops then
        return
    end
    if type(startId) ~= "number" or type(sizesTable) ~= "table" then
        return
    end
    local ids = {}
    local cur = startId
    for i = 1, Constants.NumDropSizes do
        local bucket = sizesTable[i]
        if type(bucket) == "table" then
            for _ = 1, #bucket do
                table.insert(ids, cur)
                cur = cur + 1
            end
        end
    end
    if #ids > 0 then
        RemoteDrop:FireServer(ids)
    end
end)

connectSignal(RemoteStoneDrop.OnClientEvent, function(startId, _pos, count)
    if not State.AutoCollectDrops then
        return
    end
    if type(startId) ~= "number" then
        return
    end
    local total = tonumber(count) or 1
    if total < 1 then
        return
    end
    local ids = {}
    local base = startId - 1
    for i = 1, total do
        table.insert(ids, base + i)
    end
    if #ids > 0 then
        RemoteStoneDrop:FireServer(ids)
    end
end)

-- Anti-AFK listener
connectSignal(LocalPlayer.Idled, function()
    if not State.AntiAFK then
        return
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
ensureIdentity()

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB | Collect All Pets!",
    Icon = "paw-print",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_CollectAllPets",
    Size = UDim2.fromOffset(640, 480),
    MinSize = Vector2.new(540, 360),
    MaxSize = Vector2.new(900, 650),
    Theme = "Dark",
    Transparent = false,
    Resizable = true,
    SideBarWidth = 175,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "paw-print",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("6EE7B7"),
            Color3.fromHex("3B82F6")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
        Position = UDim2.new(0.5, 0, 0, 118),
    },
})

pcall(function()
    Window:EditOpenButton({
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
        Position = UDim2.new(0.5, 0, 0, 118),
    })
end)

-- Layered DisplayOrder for WindUI ScreenGuis on Real
local function applyWindUIDisplayOrder()
    pcall(function()
        if WindUI.ScreenGui then WindUI.ScreenGui.DisplayOrder = 10 end
        if WindUI.NotificationGui then WindUI.NotificationGui.DisplayOrder = 20 end
        if WindUI.DropdownGui then WindUI.DropdownGui.DisplayOrder = 30 end
        if WindUI.TooltipGui then WindUI.TooltipGui.DisplayOrder = 40 end
    end)
end
applyWindUIDisplayOrder()

onCleanup(function()
    ensureIdentity()
    pcall(function()
        if Window and not Window.Destroyed then
            Window:Destroy()
        end
    end)
    pcall(function()
        if WindUI.ScreenGui then WindUI.ScreenGui:Destroy() end
        if WindUI.NotificationGui then WindUI.NotificationGui:Destroy() end
        if WindUI.DropdownGui then WindUI.DropdownGui:Destroy() end
        if WindUI.TooltipGui then WindUI.TooltipGui:Destroy() end
    end)
end)

local function notify(title, content, duration, icon)
    ensureIdentity()
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Icon = icon or "info",
        })
    end)
end

-- Tabs
local TabMain = Window:Tab({ Title = "Main", Icon = "home" })
local TabEggs = Window:Tab({ Title = "Eggs & Mining", Icon = "egg" })
local TabPets = Window:Tab({ Title = "Pets & Fuse", Icon = "sparkles" })
local TabUpgrades = Window:Tab({ Title = "Upgrades & Factory", Icon = "cpu" })
local TabLab = Window:Tab({ Title = "Lab & Rebirth", Icon = "flask-conical" })
local TabConfig = Window:Tab({ Title = "Config & Misc", Icon = "settings" })

Window:SelectTab(1)
applyWindUIDisplayOrder()

-- =========================================================================
-- TAB 1: MAIN (Status, Drops, Quests, Hidden Eggs, Areas)
-- =========================================================================
local StatusParagraph = TabMain:Paragraph({
    Title = "Live Account Overview",
    Desc = "Loading stats...",
})

local SectionFarm = TabMain:Section({ Title = "Drop & Reward Automation", Opened = true })

SectionFarm:Toggle({
    Title = "Auto Collect Drops",
    Desc = "Instantly collects all Gold Drops & Mythic Stone Drops anywhere on the map",
    Flag = "AutoCollectDrops",
    Value = false,
    Callback = function(v)
        State.AutoCollectDrops = v
    end,
})

SectionFarm:Toggle({
    Title = "Reduce Drop FX Lag",
    Desc = "Disables visual drop pickup popups & particles",
    Flag = "SuppressDropFX",
    Value = false,
    Callback = function(v)
        State.SuppressDropFX = v
        local fxSetting = LocalPlayer:FindFirstChild("EnableDropPickUpFX")
        if fxSetting then
            RemoteSetSetting:FireServer("EnableDropPickUpFX", not v)
        end
    end,
})

SectionFarm:Toggle({
    Title = "Auto Claim Quests",
    Desc = "Automatically claims quest rewards upon completion",
    Flag = "AutoClaimQuests",
    Value = false,
    Callback = function(v)
        State.AutoClaimQuests = v
    end,
})

local hiddenEggsBusy = false
local lastHiddenEggsSweepAt = 0

local function hideHiddenEggVisual(eggPart, playFx)
    local changed = false
    local model = eggPart:FindFirstChild("Model")
    if model and model:IsA("BasePart") and model.Transparency < 1 then
        if playFx then
            pcall(function()
                local fx = require(ReplicatedStorage:WaitForChild("FX"))
                fx.Create("FlashExplosionYellow", eggPart.Position)
            end)
            ensureIdentity()
        end
        model.Transparency = 1
        changed = true
    end
    return changed
end

local function collectUnlockedHiddenEggs()
    if hiddenEggsBusy then
        return nil
    end
    hiddenEggsBusy = true

    local ok, result = pcall(function()
        local collectedMap = safeInvoke("GetHiddenEggs") or {}
        local unlockedArea = safeGetStatValue("UnlockedArea", 1)
        local hiddenFolder = workspace:FindFirstChild("HiddenEggs")
        local pendingEggs = {}
        local totalEggs = 0
        local unlockedTotal = 0
        local unlockedCollectedBefore = 0
        local syncedVisuals = 0

        if hiddenFolder then
            for _, eggPart in ipairs(hiddenFolder:GetChildren()) do
                totalEggs = totalEggs + 1
                local areaVal = eggPart:FindFirstChild("Area")
                local areaReq = areaVal and areaVal.Value or 1
                local alreadyClaimed = collectedMap[eggPart.Name] == true
                if alreadyClaimed then
                    if hideHiddenEggVisual(eggPart, false) then
                        syncedVisuals = syncedVisuals + 1
                    end
                end
                if areaReq <= unlockedArea then
                    unlockedTotal = unlockedTotal + 1
                    if alreadyClaimed then
                        unlockedCollectedBefore = unlockedCollectedBefore + 1
                    else
                        table.insert(pendingEggs, eggPart)
                    end
                end
            end
        end

        local confirmedCollected = 0
        if #pendingEggs > 0 then
            for _, eggPart in ipairs(pendingEggs) do
                RemoteCollectHiddenEgg:FireServer(eggPart.Name)
                task.wait(0.08)
            end
            task.wait(0.25)

            local afterMap = safeInvoke("GetHiddenEggs") or {}
            local stillPending = {}
            for _, eggPart in ipairs(pendingEggs) do
                if afterMap[eggPart.Name] == true then
                    confirmedCollected = confirmedCollected + 1
                    hideHiddenEggVisual(eggPart, true)
                else
                    table.insert(stillPending, eggPart)
                end
            end

            -- Fallback: if any unlocked egg did not register via remote alone, trigger touch + remote retry
            if #stillPending > 0 and type(firetouchinterest) == "function" then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, eggPart in ipairs(stillPending) do
                        if eggPart:IsA("BasePart") then
                            pcall(function()
                                firetouchinterest(hrp, eggPart, 0)
                                task.wait(0.02)
                                firetouchinterest(hrp, eggPart, 1)
                            end)
                            RemoteCollectHiddenEgg:FireServer(eggPart.Name)
                            task.wait(0.08)
                        end
                    end
                    task.wait(0.25)
                    local retryMap = safeInvoke("GetHiddenEggs") or {}
                    for _, eggPart in ipairs(stillPending) do
                        if retryMap[eggPart.Name] == true then
                            confirmedCollected = confirmedCollected + 1
                            hideHiddenEggVisual(eggPart, true)
                        end
                    end
                end
            end
        end

        return {
            confirmedCollected = confirmedCollected,
            syncedVisuals = syncedVisuals,
            unlockedCollected = unlockedCollectedBefore + confirmedCollected,
            unlockedTotal = unlockedTotal,
            lockedCount = math.max(0, totalEggs - unlockedTotal),
            unlockedArea = unlockedArea,
        }
    end)

    lastHiddenEggsSweepAt = os.clock()
    hiddenEggsBusy = false
    if ok then
        return result
    end
    return nil
end

SectionFarm:Toggle({
    Title = "Auto Collect Hidden Eggs",
    Desc = "Automatically claims uncollected Hidden Eggs in all unlocked areas",
    Flag = "AutoHiddenEggs",
    Value = false,
    Callback = function(v)
        State.AutoHiddenEggs = v
        if v then
            task.spawn(function()
                collectUnlockedHiddenEggs()
            end)
        end
    end,
})

SectionFarm:Button({
    Title = "Collect Unlocked Hidden Eggs Now",
    Desc = "Runs an immediate sweep of all unlocked Hidden Eggs",
    Icon = "search",
    Callback = function()
        task.spawn(function()
            local info = collectUnlockedHiddenEggs()
            if not info then
                notify("Hidden Eggs", "Hidden Eggs sweep is already in progress.", 3, "egg")
                return
            end
            if info.confirmedCollected > 0 then
                notify(
                    "Hidden Eggs",
                    string.format(
                        "Collected %d Hidden Egg(s) (%d/%d in Areas 1-%d, %d in locked Areas %d+).",
                        info.confirmedCollected,
                        info.unlockedCollected,
                        info.unlockedTotal,
                        info.unlockedArea,
                        info.lockedCount,
                        info.unlockedArea + 1
                    ),
                    4,
                    "egg"
                )
            elseif info.syncedVisuals > 0 then
                notify(
                    "Hidden Eggs",
                    string.format(
                        "All %d/%d unlocked Hidden Eggs claimed (hid %d remaining visual(s); %d in locked Areas %d+).",
                        info.unlockedCollected,
                        info.unlockedTotal,
                        info.syncedVisuals,
                        info.lockedCount,
                        info.unlockedArea + 1
                    ),
                    4,
                    "egg"
                )
            else
                notify(
                    "Hidden Eggs",
                    string.format(
                        "All %d/%d unlocked Hidden Eggs (Areas 1-%d) already collected (%d in locked Areas %d+).",
                        info.unlockedCollected,
                        info.unlockedTotal,
                        info.unlockedArea,
                        info.lockedCount,
                        info.unlockedArea + 1
                    ),
                    4,
                    "egg"
                )
            end
        end)
    end,
})

SectionFarm:Toggle({
    Title = "Auto Claim Hourly/Daily Egg",
    Desc = "Claims the hourly free egg whenever ready",
    Flag = "AutoDailyEgg",
    Value = false,
    Callback = function(v)
        State.AutoDailyEgg = v
    end,
})

SectionFarm:Toggle({
    Title = "Auto Claim Sub & Mushroom Boosts",
    Desc = "Claims free Shiny Submarine & Metallic Mushroom boosts when restocked",
    Flag = "AutoSubMushBoost",
    Value = false,
    Callback = function(v)
        State.AutoSubMushBoost = v
    end,
})

local SectionArea = TabMain:Section({ Title = "Areas, Doors & Movement", Opened = true })

SectionArea:Dropdown({
    Title = "Lock Farming Area",
    Desc = "Locks your pets to a specific area (0 = Free / Follow Player)",
    Flag = "ManualLockArea",
    Values = AreaOptions,
    Value = "0 - Unlocked (Free)",
    Callback = function(selected)
        local id = tonumber(string.match(tostring(selected), "^(%d+)"))
        if id ~= nil then
            RemoteOnAreaButton:FireServer(id)
        end
    end,
})

SectionArea:Toggle({
    Title = "Auto Lock Highest Unlocked Area",
    Desc = "Automatically keeps LockedArea synced to your highest unlocked area",
    Flag = "AutoLockHighestArea",
    Value = false,
    Callback = function(v)
        State.AutoLockHighestArea = v
    end,
})

SectionArea:Toggle({
    Title = "Auto Open Unlockable Doors",
    Desc = "Automatically opens Area Doors & Rebirth Door when eligible",
    Flag = "AutoOpenDoors",
    Value = false,
    Callback = function(v)
        State.AutoOpenDoors = v
    end,
})

local SelectedTeleportArea = "1 - The Meadow"
SectionArea:Dropdown({
    Title = "Target Teleport Area",
    Values = {
        "1 - The Meadow",
        "2 - The Forest",
        "3 - The Desert",
        "4 - The Arctic",
        "5 - The Beach",
        "6 - The Mountains",
        "7 - The Jungle",
        "8 - The Grotto",
        "9 - The Grove",
        "10 - The Mine",
    },
    Value = "1 - The Meadow",
    Flag = "TeleportAreaSelect",
    Callback = function(selected)
        SelectedTeleportArea = selected
    end,
})

SectionArea:Button({
    Title = "Teleport to Selected Area",
    Icon = "map-pin",
    Callback = function()
        local id = tonumber(string.match(tostring(SelectedTeleportArea), "^(%d+)"))
        local areaPart = id and workspace.Areas:FindFirstChild("Area" .. tostring(id))
        local root = Util.GetPlayerRootPart(LocalPlayer)
        ensureIdentity()
        if areaPart and root then
            root.CFrame = CFrame.new(areaPart.Position + Vector3.new(0, areaPart.Size.Y / 2 + 5, 0))
            notify("Teleport", "Teleported to " .. SelectedTeleportArea, 2, "map-pin")
        else
            notify("Teleport Failed", "Could not locate character or target area.", 3, "alert-triangle")
        end
    end,
})

SectionArea:Toggle({
    Title = "Enable WalkSpeed Override",
    Flag = "WalkSpeedEnabled",
    Value = false,
    Callback = function(v)
        State.WalkSpeedEnabled = v
        if not v then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = getDefaultGameWalkSpeed()
            end
        end
    end,
})

SectionArea:Slider({
    Title = "WalkSpeed",
    Flag = "WalkSpeedValue",
    Value = { Min = 16, Max = 150, Default = 32 },
    Step = 1,
    Callback = function(v)
        State.WalkSpeedValue = v
    end,
})

-- =========================================================================
-- TAB 2: EGGS & MINING
-- =========================================================================
local SectionHatch = TabEggs:Section({ Title = "Egg Hatching", Opened = true })

SectionHatch:Dropdown({
    Title = "Target Egg Rarity",
    Desc = "Best Affordable automatically buys the highest tier egg you can afford",
    Flag = "SelectedEgg",
    Values = EggRarityDropdownValues,
    Value = "Best Affordable",
    Callback = function(v)
        State.SelectedEgg = v
    end,
})

SectionHatch:Toggle({
    Title = "Skip Hatch & Fuse Animations",
    Desc = "Suppresses egg hatching & fusing cutscenes so farming never pauses",
    Flag = "SkipAnimations",
    Value = false,
    Callback = function(v)
        State.SkipAnimations = v
        applyAnimationSuppression(v)
    end,
})

SectionHatch:Toggle({
    Title = "Auto Hatch Eggs",
    Desc = "Remotely purchases and hatches the selected egg rarity",
    Flag = "AutoHatch",
    Value = false,
    Callback = function(v)
        State.AutoHatch = v
        if not v and isHatcherLocked() then
            restoreHatcherUI()
        end
    end,
})

SectionHatch:Slider({
    Title = "Hatch Interval (Seconds)",
    Flag = "HatchDelay",
    Value = { Min = 0.1, Max = 3.0, Default = 0.25 },
    Step = 0.05,
    Callback = function(v)
        State.HatchDelay = v
    end,
})

local SectionMining = TabEggs:Section({ Title = "Giant Eggs & Overclocks (Area 10)", Opened = true })

SectionMining:Dropdown({
    Title = "Target Giant Egg",
    Flag = "SelectedGiantEgg",
    Values = GiantEggValues,
    Value = "1 - Common",
    Callback = function(v)
        State.SelectedGiantEgg = v
    end,
})

SectionMining:Toggle({
    Title = "Teleport Near Giant Egg When Mining",
    Flag = "TeleportToGiant",
    Value = true,
    Callback = function(v)
        State.TeleportToGiant = v
    end,
})

SectionMining:Toggle({
    Title = "Auto Mine Giant Egg",
    Desc = "Continuously mines the selected Giant Egg when Pickaxe & Gold allow",
    Flag = "AutoMineGiant",
    Value = false,
    Callback = function(v)
        State.AutoMineGiant = v
        if not v then
            pcall(function() RemoteCancelMine:FireServer() end)
        end
    end,
})

local OverclockKeys = { "Strike2", "Strike3", "Strike4", "Strike5", "GiantLuck", "ShinyLuck", "MythicStones" }
local OverclockLabels = {}
for _, k in ipairs(OverclockKeys) do
    table.insert(OverclockLabels, k .. " (" .. OverclocksDB[k].Name .. ")")
end

SectionMining:Dropdown({
    Title = "Active Overclocks",
    Desc = "Select Overclocks to activate on the server",
    Flag = "SelectedOverclocks",
    Values = OverclockLabels,
    Multi = true,
    AllowNone = true,
    Callback = function(selectedList)
        local activeSet = {}
        if type(selectedList) == "table" then
            for _, item in ipairs(selectedList) do
                local key = string.match(tostring(item), "^([^%s]+)")
                if key then
                    activeSet[key] = true
                end
            end
        end
        for _, k in ipairs(OverclockKeys) do
            RemoteSetOverclock:FireServer(k, activeSet[k] == true)
        end
    end,
})

-- =========================================================================
-- TAB 3: PETS & FUSE
-- =========================================================================
local SectionPetMgmt = TabPets:Section({ Title = "Equipping & Smart Auto-Fuse", Opened = true })

SectionPetMgmt:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Automatically equips your strongest pets whenever your inventory grows",
    Flag = "AutoEquipBest",
    Value = false,
    Callback = function(v)
        State.AutoEquipBest = v
    end,
})

SectionPetMgmt:Button({
    Title = "Equip Best Pets Now",
    Icon = "zap",
    Callback = function()
        RemoteEquipBest:FireServer()
        notify("Pets", "Equipped best pets.", 2, "zap")
    end,
})

SectionPetMgmt:Toggle({
    Title = "Smart Auto Fuse (No GamePass Needed)",
    Desc = "Automatically fuses 5 same-rarity (Common..Legendary) or 3 identical (Prodigious..Ascended) pets",
    Flag = "AutoFuseCustom",
    Value = false,
    Callback = function(v)
        State.AutoFuseCustom = v
    end,
})

SectionPetMgmt:Dropdown({
    Title = "Max Target Rarity",
    Desc = "Will not fuse pets at or above this resulting rarity",
    Flag = "FuseMaxRarity",
    Values = FuseCeilingValues,
    Value = "Legendary (5)",
    Callback = function(v)
        State.FuseMaxRarity = v
    end,
})

SectionPetMgmt:Toggle({
    Title = "Protect Equipped Pets",
    Flag = "FuseProtectEquipped",
    Value = true,
    Callback = function(v)
        State.FuseProtectEquipped = v
    end,
})

SectionPetMgmt:Toggle({
    Title = "Protect Shiny Pets",
    Flag = "FuseProtectShiny",
    Value = true,
    Callback = function(v)
        State.FuseProtectShiny = v
    end,
})

SectionPetMgmt:Toggle({
    Title = "Protect Metallic Pets",
    Flag = "FuseProtectMetallic",
    Value = true,
    Callback = function(v)
        State.FuseProtectMetallic = v
    end,
})

SectionPetMgmt:Toggle({
    Title = "Protect Giant Pets",
    Flag = "FuseProtectGiant",
    Value = true,
    Callback = function(v)
        State.FuseProtectGiant = v
    end,
})

local function runCustomFuseCycle()
    local myPets = safeInvoke("GetPets")
    if type(myPets) ~= "table" then
        return 0
    end

    local maxResultRarity = RarityMap[State.FuseMaxRarity] or 5
    local eq = safeInvoke("GetEquippedPets") or {}
    local shinies = safeInvoke("GetShinies") or {}
    local metallics = safeInvoke("GetMetallics") or {}
    local giants = safeInvoke("GetGiants") or {}

    local equippedSet = {}
    for _, slot in pairs(eq) do
        if type(slot) == "table" and slot.Pet and slot.Index then
            equippedSet[slot.Pet .. "::" .. tostring(slot.Index)] = true
        end
    end

    local byRarity = { {}, {}, {}, {}, {}, {}, {} }
    local byPetType = {}

    for petName, count in pairs(myPets) do
        local info = PetsDB[petName]
        if info and info.Rarity and info.Rarity < maxResultRarity and info.Rarity <= 7 then
            for idx = 1, count do
                local isEquipped = equippedSet[petName .. "::" .. tostring(idx)] == true
                local isGiant = (giants[petName] or 0) >= idx
                local isMetallic = (idx == 1) and (not isGiant) and (metallics[petName] ~= nil and metallics[petName] > 0)
                local isShiny = (not isGiant) and (not isMetallic) and ((shinies[petName] or 0) >= idx)

                local blocked = (State.FuseProtectEquipped and isEquipped)
                    or (State.FuseProtectGiant and isGiant)
                    or (State.FuseProtectMetallic and isMetallic)
                    or (State.FuseProtectShiny and isShiny)

                if not blocked then
                    local entry = { Pet = petName, Index = idx }
                    if info.Rarity <= 5 then
                        table.insert(byRarity[info.Rarity], entry)
                    else
                        byPetType[petName] = byPetType[petName] or {}
                        table.insert(byPetType[petName], entry)
                    end
                end
            end
        end
    end

    local fusedBatches = 0
    -- Rarity 1..5: fuse 5 pets of same rarity
    for r = 1, math.min(5, maxResultRarity - 1) do
        local pool = byRarity[r]
        if #pool >= 5 then
            local batch = { pool[1], pool[2], pool[3], pool[4], pool[5] }
            RemoteFusePets:FireServer(batch)
            fusedBatches = fusedBatches + 1
            return fusedBatches -- return 1 batch per tick so indices stay fresh from server
        end
    end

    -- Rarity 6..7: fuse 3 identical pets
    for _, pool in pairs(byPetType) do
        if #pool >= 3 then
            local batch = { pool[1], pool[2], pool[3] }
            RemoteFusePets:FireServer(batch)
            fusedBatches = fusedBatches + 1
            return fusedBatches
        end
    end

    return 0
end

SectionPetMgmt:Button({
    Title = "Fuse One Batch Now",
    Icon = "layers",
    Callback = function()
        local count = runCustomFuseCycle()
        if count > 0 then
            notify("Auto Fuse", "Fused 1 batch cleanly.", 2, "layers")
        else
            notify("Auto Fuse", "No eligible fuse batch found under current filters.", 2, "info")
        end
    end,
})

SectionPetMgmt:Toggle({
    Title = "Auto Fuse All (GamePass Only)",
    Desc = "Triggers server AutoFuse remote for Rarity 1..7 if you own Fuse All GamePass",
    Flag = "AutoFuseGamepass",
    Value = false,
    Callback = function(v)
        State.AutoFuseGamepass = v
    end,
})

local SectionExotic = TabPets:Section({ Title = "Exotic Pets & Disposal", Opened = false })

SectionExotic:Button({
    Title = "Equip All Unlocked Exotic Pets",
    Icon = "star",
    Callback = function()
        local exotics = safeInvoke("GetExoticPets") or {}
        local equipped = 0
        for i = 1, 8 do
            if exotics[i] and exotics[i] > 0 then
                RemoteEquipExoticPet:FireServer(i, true)
                equipped = equipped + 1
            end
        end
        notify("Exotic Pets", "Equipped " .. tostring(equipped) .. " unlocked exotic pet(s).", 2, "star")
    end,
})

SectionExotic:Button({
    Title = "Dispose Excess Pets",
    Desc = "Triggers server Disposal prompt action",
    Icon = "trash-2",
    Callback = function()
        RemoteDispose:FireServer()
        notify("Disposal", "Sent Dispose request.", 2, "trash-2")
    end,
})

-- =========================================================================
-- TAB 4: UPGRADES & FACTORY
-- =========================================================================
local SectionGoldShops = TabUpgrades:Section({ Title = "Gold Stat Shops & Pet Slots", Opened = true })

SectionGoldShops:Dropdown({
    Title = "Gold Stat Upgrades to Buy",
    Flag = "SelectedGoldStats",
    Values = GoldStatNames,
    Value = { "Damage", "DropRate", "Speed", "DropCollectionRange" },
    Multi = true,
    AllowNone = true,
    Callback = function(list)
        if type(list) == "table" then
            State.SelectedGoldStats = list
        end
    end,
})

SectionGoldShops:Toggle({
    Title = "Auto Buy Selected Gold Stat Upgrades",
    Desc = "Automatically purchases upgrades when Gold >= next tier cost",
    Flag = "AutoBuyGoldStats",
    Value = false,
    Callback = function(v)
        State.AutoBuyGoldStats = v
    end,
})

SectionGoldShops:Toggle({
    Title = "Auto Buy Pet Equip Slots",
    Desc = "Automatically unlocks Pet Equip Slots 1..6 when Gold allows",
    Flag = "AutoBuyEquipSlots",
    Value = false,
    Callback = function(v)
        State.AutoBuyEquipSlots = v
    end,
})

local SectionRebirthUpgrades = TabUpgrades:Section({ Title = "Upgrade Tree (Mythic Gems) & Runes", Opened = true })

SectionRebirthUpgrades:Toggle({
    Title = "Auto Buy Upgrade Tree (Mythic Gems)",
    Desc = "Buys unlocked Upgrade Tree nodes and stat tiers with Mythic Gems",
    Flag = "AutoBuyRebirthTree",
    Value = false,
    Callback = function(v)
        State.AutoBuyRebirthTree = v
    end,
})

SectionRebirthUpgrades:Toggle({
    Title = "Auto Buy Rune Upgrades (Runes)",
    Desc = "Automatically upgrades RuneGoldMult, RuneShinyLuck, RuneMetallicLuck, RuneGiantLuck, RuneEggLuck",
    Flag = "AutoBuyRunes",
    Value = false,
    Callback = function(v)
        State.AutoBuyRunes = v
    end,
})

local SectionFactory = TabUpgrades:Section({ Title = "Factory, Generator & Calcifier", Opened = true })

SectionFactory:Dropdown({
    Title = "Generator Egg Rarity",
    Flag = "GeneratorEggRarity",
    Values = {
        "1 - Common",
        "2 - Uncommon",
        "3 - Rare",
        "4 - Epic",
        "5 - Legendary",
        "6 - Prodigious",
        "7 - Ascended",
    },
    Value = "1 - Common",
    Callback = function(selected)
        State.GeneratorEggRarity = selected
        local r = tonumber(string.match(tostring(selected), "^(%d+)"))
        if r then
            RemoteSetGeneratorEgg:FireServer(r)
        end
    end,
})

SectionFactory:Toggle({
    Title = "Generator Enabled",
    Flag = "GeneratorEnabled",
    Value = false,
    Callback = function(v)
        State.GeneratorEnabled = v
        RemoteSetGeneratorOn:FireServer(v)
    end,
})

SectionFactory:Toggle({
    Title = "Auto Generator Crank",
    Desc = "Keeps the Generator Crank active remotely",
    Flag = "AutoCrank",
    Value = false,
    Callback = function(v)
        State.AutoCrank = v
        RemoteSetGeneratorCrank:FireServer(v)
    end,
})

SectionFactory:Toggle({
    Title = "Auto Calcify Mythicals",
    Desc = "Periodically triggers CalcifyAll & enables server AutoCalcify",
    Flag = "AutoCalcifyLoop",
    Value = false,
    Callback = function(v)
        State.AutoCalcifyLoop = v
        RemoteSetAutoCalcify:FireServer(v)
    end,
})

SectionFactory:Button({
    Title = "Calcify All Mythicals Now",
    Icon = "flame",
    Callback = function()
        RemoteCalcifyAll:FireServer()
        notify("Calcifier", "Sent CalcifyAll request.", 2, "flame")
    end,
})

SectionFactory:Button({
    Title = "Enable In-Game AutoEquip & AutoFuse",
    Desc = "Enables the Factory Automator toggles (if unlocked)",
    Icon = "check-circle",
    Callback = function()
        RemoteSetAutoEquip:FireServer(true)
        RemoteSetAutoFuse:FireServer(true)
        notify("Factory Automator", "Enabled AutoEquip & AutoFuse.", 2, "check-circle")
    end,
})

-- =========================================================================
-- TAB 5: LAB, BADGES, CODES & REBIRTH
-- =========================================================================
local SectionLab = TabLab:Section({ Title = "Lab Tasks & Research", Opened = true })

SectionLab:Toggle({
    Title = "Auto Claim Completed Lab Tasks",
    Desc = "Automatically claims finished Lab Tasks for Research Points",
    Flag = "AutoClaimLabTasks",
    Value = false,
    Callback = function(v)
        State.AutoClaimLabTasks = v
    end,
})

SectionLab:Toggle({
    Title = "Auto Spend Research Points",
    Desc = "Upgrades unlocked Research nodes in the active preset",
    Flag = "AutoUpgradeResearch",
    Value = false,
    Callback = function(v)
        State.AutoUpgradeResearch = v
    end,
})

local SectionBadgesCraft = TabLab:Section({ Title = "Badges & Titanium Crafting", Opened = true })

local function claimAllBadges()
    local claimed = 0
    for _, b in ipairs(BadgeCategories) do
        local statVal = safeGetStatValue(b.Stat, 0)
        local unlockedTier = safeGetStatValue(b.Unlocked, 0)
        local reqs = BadgeRequirements[b.Key]
        if reqs and unlockedTier < #reqs then
            for tier = unlockedTier + 1, #reqs do
                if statVal >= reqs[tier] then
                    RemoteUnlockBadge:FireServer(b.Key)
                    claimed = claimed + 1
                    task.wait(0.05)
                else
                    break
                end
            end
        end
    end
    return claimed
end

SectionBadgesCraft:Toggle({
    Title = "Auto Unlock Badges",
    Desc = "Automatically claims badge tiers as soon as requirements are met",
    Flag = "AutoUnlockBadges",
    Value = false,
    Callback = function(v)
        State.AutoUnlockBadges = v
    end,
})

SectionBadgesCraft:Button({
    Title = "Claim All Eligible Badges Now",
    Icon = "award",
    Callback = function()
        local count = claimAllBadges()
        notify("Badges", "Claimed " .. tostring(count) .. " badge tier(s).", 2, "award")
    end,
})

SectionBadgesCraft:Button({
    Title = "Craft Titanium Aura (5 Ingots)",
    Icon = "hammer",
    Callback = function()
        RemoteCraft:FireServer("TitaniumAura")
    end,
})

SectionBadgesCraft:Button({
    Title = "Craft Titanium Blade (10 Ingots)",
    Icon = "hammer",
    Callback = function()
        RemoteCraft:FireServer("TitaniumBlade")
    end,
})

SectionBadgesCraft:Button({
    Title = "Craft Titanium Handle (15 Ingots)",
    Icon = "hammer",
    Callback = function()
        RemoteCraft:FireServer("TitaniumHandle")
    end,
})

local SectionCodesRebirth = TabLab:Section({ Title = "Promo Codes & Rebirth", Opened = true })

local CustomCodeText = ""
SectionCodesRebirth:Input({
    Title = "Custom Promo Code",
    Placeholder = "Enter code...",
    Flag = "CustomCodeInput",
    Callback = function(v)
        CustomCodeText = v
    end,
})

SectionCodesRebirth:Button({
    Title = "Redeem Custom Code",
    Icon = "gift",
    Callback = function()
        if CustomCodeText and CustomCodeText ~= "" then
            RemoteRedeemCode:FireServer(CustomCodeText)
            notify("Codes", "Attempted redeem: " .. CustomCodeText, 2, "gift")
        end
    end,
})

SectionCodesRebirth:Button({
    Title = "Redeem All Known Promo Codes",
    Desc = "Attempts all known Collect All Pets! codes automatically",
    Icon = "sparkles",
    Callback = function()
        task.spawn(function()
            for _, code in ipairs(KnownCodes) do
                RemoteRedeemCode:FireServer(code)
                task.wait(0.15)
            end
            notify("Codes", "Finished redeeming " .. tostring(#KnownCodes) .. " known codes.", 3, "sparkles")
        end)
    end,
})

SectionCodesRebirth:Button({
    Title = "Trigger Rebirth (Requires 240/240 Discovered)",
    Desc = "Triggers the Rebirth Altar remotely when ready",
    Icon = "refresh-cw",
    Callback = function()
        local discovered = safeGetStatValue("NumDiscovered", 0)
        if discovered >= 240 then
            RemoteStartRebirth:FireServer()
            notify("Rebirth", "Sent StartRebirth request.", 3, "refresh-cw")
        else
            notify("Rebirth Locked", "Discovered pets: " .. tostring(discovered) .. " / 240", 3, "alert-triangle")
        end
    end,
})

-- =========================================================================
-- TAB 6: CONFIG & MISC
-- =========================================================================
local SectionMisc = TabConfig:Section({ Title = "Session & Optimization", Opened = true })

SectionMisc:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents 20-minute idle disconnect automatically",
    Flag = "AntiAFK",
    Value = false,
    Callback = function(v)
        State.AntiAFK = v
    end,
})

SectionMisc:Toggle({
    Title = "Hide Other Players' Pets",
    Desc = "Improves FPS by hiding pets belonging to other players",
    Flag = "HideOtherPets",
    Value = false,
    Callback = function(v)
        State.HideOtherPets = v
        RemoteSetSetting:FireServer("ShowOtherPlayersPets", not v)
    end,
})

SectionMisc:Button({
    Title = "Unstuck Character & Camera",
    Desc = "Restores player movement controls, camera, and UI state if stuck",
    Icon = "unlock",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.PlatformStand = false
                hum.Sit = false
                hum.WalkSpeed = State.WalkSpeedEnabled and State.WalkSpeedValue or getDefaultGameWalkSpeed()
            end
            if root then
                root.Anchored = false
                root.CFrame = CFrame.new(root.Position)
            end
            local pm = require(PlayerScripts:WaitForChild("PlayerModule"))
            pm:GetControls():Enable()
        end)
        restoreHatcherUI()
        notify("Unstuck", "Restored movement controls & camera.", 2, "unlock")
    end,
})

SectionMisc:Button({
    Title = "Rejoin Current Server",
    Icon = "rotate-ccw",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

local SectionCfg = TabConfig:Section({ Title = "Configuration (Save & Load)", Opened = true })

local ConfigManager = Window.ConfigManager

SectionCfg:Input({
    Title = "Config Profile Name",
    Placeholder = "default",
    Value = "default",
    Flag = "ConfigProfileName",
    Callback = function(v)
        if v and v ~= "" then
            State.ConfigName = v
        end
    end,
})

SectionCfg:Button({
    Title = "Save Config",
    Desc = "Saves all current toggles, sliders, and selections to disk",
    Icon = "save",
    Callback = function()
        ensureIdentity()
        local name = (State.ConfigName and State.ConfigName ~= "") and State.ConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        if cfg then
            cfg:Save()
            notify("Config Saved", "Saved profile '" .. name .. "'.", 3, "save")
        else
            notify("Config Error", "Could not initialize config '" .. name .. "'.", 3, "alert-triangle")
        end
    end,
})

SectionCfg:Button({
    Title = "Load Config",
    Desc = "Loads saved settings from the specified profile",
    Icon = "download",
    Callback = function()
        ensureIdentity()
        local name = (State.ConfigName and State.ConfigName ~= "") and State.ConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        if cfg then
            local res, err = cfg:Load()
            if res == false then
                notify("Config Load Failed", tostring(err or "Profile not found."), 3, "alert-triangle")
            else
                notify("Config Loaded", "Loaded profile '" .. name .. "'.", 3, "download")
            end
        end
    end,
})

SectionCfg:Button({
    Title = "Delete Config",
    Desc = "Deletes the specified saved profile",
    Icon = "trash",
    Callback = function()
        ensureIdentity()
        local name = (State.ConfigName and State.ConfigName ~= "") and State.ConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        if cfg and cfg.Delete then
            local ok, err = cfg:Delete()
            if ok == false then
                notify("Delete Failed", tostring(err or "Profile not found."), 3, "alert-triangle")
            else
                notify("Config Deleted", "Deleted profile '" .. name .. "'.", 3, "trash")
            end
        end
    end,
})

SectionCfg:Paragraph({
    Title = "Controls & Branding",
    Desc = "Press LeftCTRL to toggle (Show / Hide) the menu, or use the draggable XLunaHUB floating button. Created By XLunaHUB.",
})

-- =========================================================================
-- BACKGROUND LOOPS (All gated strictly by State flags - ALL OFF initially)
-- =========================================================================

-- WalkSpeed & Cutscene Recovery Stepped Loop
connectSignal(RunService.Stepped, function()
    if not isAlive() then
        return
    end
    if State.WalkSpeedEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= State.WalkSpeedValue then
            hum.WalkSpeed = State.WalkSpeedValue
        end
    end
    if State.SkipAnimations and isHatcherLocked() then
        restoreHatcherUI()
    end
end)

-- Fast Automation Loop (Auto Hatch, Giant Mining, Quests, Auto Fuse)
task.spawn(function()
    local lastHatch = 0
    local lastMine = 0
    local lastFuse = 0
    local lastEquip = 0
    local lastQuest = 0

    while isAlive() do
        local now = os.clock()

        -- 1. Auto Hatch Eggs
        if State.AutoHatch then
            -- If watching animations (SkipAnimations OFF), auto-click Continue when Showcase finishes
            if not State.SkipAnimations and type(getconnections) == "function" then
                local hatcherFrame = ScreenGui:FindFirstChild("Hatcher")
                local showcase = hatcherFrame and hatcherFrame:FindFirstChild("Showcase")
                local contBtn = showcase and showcase:FindFirstChild("ContinueButton")
                if showcase and showcase.Visible and contBtn and contBtn.Active then
                    pcall(function()
                        for _, conn in ipairs(getconnections(contBtn.Activated)) do
                            conn:Fire()
                        end
                    end)
                end
            end

            if (now - lastHatch) >= State.HatchDelay then
                local uiState = ReplicatedStorage:FindFirstChild("UIState")
                local canHatch = State.SkipAnimations or (not uiState or uiState.Value == "main")
                if canHatch then
                    lastHatch = now
                    local gold = safeGetStatValue("Gold", 0)
                    local totalPets = safeGetStatValue("TotalPets", 0)
                    if totalPets < Constants.InventoryCap then
                        local rarity = nil
                        if State.SelectedEgg == "Best Affordable" then
                            rarity = getMaxAffordableEggRarity(gold)
                        else
                            local r = RarityMap[State.SelectedEgg]
                            if r and gold >= getEggPrice(r) then
                                rarity = r
                            end
                        end
                        if rarity then
                            RemoteBuyEgg:FireServer(rarity)
                        end
                    end
                end
            end
        end

        -- 2. Auto Claim Quests
        if State.AutoClaimQuests and (now - lastQuest) >= 0.4 then
            lastQuest = now
            local qProg = safeGetStatValue("QuestProgress", 0)
            local qGoal = safeGetStatValue("QuestGoal", 1)
            if qGoal > 0 and qProg >= qGoal then
                RemoteClaimQuestReward:FireServer()
            end
        end

        -- 3. Auto Equip Best
        if State.AutoEquipBest and (now - lastEquip) >= 2.0 then
            lastEquip = now
            RemoteEquipBest:FireServer()
        end

        -- 4. Smart Auto Fuse (Custom)
        if State.AutoFuseCustom and (now - lastFuse) >= 0.45 then
            lastFuse = now
            runCustomFuseCycle()
        end

        -- 5. GamePass Auto Fuse
        if State.AutoFuseGamepass and (now - lastFuse) >= 1.5 then
            lastFuse = now
            RemoteAutoFuse:FireServer({ true, true, true, true, true, true, true, false })
        end

        -- 6. Auto Mine Giant Egg
        if State.AutoMineGiant and (now - lastMine) >= 0.25 then
            lastMine = now
            local r = tonumber(string.match(tostring(State.SelectedGiantEgg), "^(%d+)")) or 1
            local pickaxe = safeGetStatValue("Pickaxe", 0)
            local gold = safeGetStatValue("Gold", 0)
            if pickaxe >= r then
                local giantFolder = workspace:FindFirstChild("GiantEggs")
                local eggModel = nil
                if giantFolder then
                    for _, m in ipairs(giantFolder:GetChildren()) do
                        local rar = m:FindFirstChild("Rarity")
                        if rar and rar.Value == r then
                            eggModel = m
                            break
                        end
                    end
                end
                if eggModel and eggModel.PrimaryPart then
                    local priceObj = eggModel:FindFirstChild("Price")
                    local price = priceObj and priceObj.Value or (EggPrices.Giant[r] or math.huge)
                    if gold >= price then
                        local root = Util.GetPlayerRootPart(LocalPlayer)
                        ensureIdentity()
                        if root then
                            if State.TeleportToGiant then
                                local radius = (eggModel:FindFirstChild("MiningRadius") and eggModel.MiningRadius.Value) or 10
                                local dir = (root.Position - eggModel.PrimaryPart.Position)
                                local flat = Vector3.new(dir.X, 0, dir.Z)
                                if flat.Magnitude < 0.1 then
                                    flat = Vector3.new(0, 0, 1)
                                end
                                local groundY = workspace.Areas.Main.Position.Y + workspace.Areas.Main.Size.Y / 2 + 3
                                local targetPos = Vector3.new(
                                    eggModel.PrimaryPart.Position.X + flat.Unit.X * math.max(4, radius - 1),
                                    groundY,
                                    eggModel.PrimaryPart.Position.Z + flat.Unit.Z * math.max(4, radius - 1)
                                )
                                local lookTarget = Vector3.new(eggModel.PrimaryPart.Position.X, groundY, eggModel.PrimaryPart.Position.Z)
                                if (root.Position - targetPos).Magnitude > 6 then
                                    root.CFrame = CFrame.new(targetPos, lookTarget)
                                end
                            end
                            local hitPos = eggModel.PrimaryPart.Position + Vector3.new(0, 2.4, 0)
                            RemoteMine:FireServer(r, hitPos)
                        end
                    end
                end
            end
        end

        task.wait(0.1)
    end
end)

-- Secondary Automation & Dashboard Loop (Upgrades, Hidden Eggs, Daily, Lab, Badges, Overview)
task.spawn(function()
    local lastSlowTick = 0
    while isAlive() do
        local now = os.clock()
        if (now - lastSlowTick) >= 1.0 then
            lastSlowTick = now

            -- Update Dashboard Paragraph
            local gold = safeGetStatValue("Gold", 0)
            local petScore = safeGetStatValue("PetScore", 0)
            local totalPets = safeGetStatValue("TotalPets", 0)
            local mythicGems = safeGetStatValue("MythicGems", 0)
            local runes = safeGetStatValue("Runes", 0)
            local ingots = safeGetStatValue("Ingots", 0)
            local rebirths = safeGetStatValue("TotalRebirths", 0)
            local ascensions = safeGetStatValue("Ascensions", 0)
            local unlockedArea = safeGetStatValue("UnlockedArea", 1)
            local discovered = safeGetStatValue("NumDiscovered", 0)

            ensureIdentity()
            pcall(function()
                StatusParagraph:SetDesc(string.format(
                    "Gold: %s | Pets: %d/%d | Discovered: %d/240\nPet Score: %s | Area Unlocked: %d (%s)\nMythic Gems: %s | Runes: %s | Ingots: %s\nRebirths: %d | Ascensions: %d",
                    Util.FormatNumberShop(gold),
                    totalPets,
                    Constants.InventoryCap,
                    discovered,
                    Util.AddCommasToNumber(petScore),
                    unlockedArea,
                    Constants.AreaName[unlockedArea] or "Unknown",
                    Util.AddCommasToNumber(mythicGems),
                    Util.AddCommasToNumber(runes),
                    Util.AddCommasToNumber(ingots),
                    rebirths,
                    ascensions
                ))
            end)

            -- Auto Lock Highest Unlocked Area
            if State.AutoLockHighestArea then
                local currentLocked = safeGetStatValue("LockedArea", 0)
                if currentLocked ~= unlockedArea then
                    RemoteOnAreaButton:FireServer(unlockedArea)
                end
            end

            -- Auto Hidden Eggs
            if State.AutoHiddenEggs and not hiddenEggsBusy and (os.clock() - lastHiddenEggsSweepAt) >= 2 then
                task.spawn(collectUnlockedHiddenEggs)
            end

            -- Auto Daily/Hourly Egg
            if State.AutoDailyEgg then
                local lastClaim = safeGetStatValue("LastDailyEggClaim", 0)
                local t = os.time()
                local windowStart = t - (t % 3600) + (Constants.DailyEggTimeOffset or 0)
                if windowStart > lastClaim then
                    RemoteClaimDailyEgg:FireServer()
                end
            end

            -- Auto Sub & Mushroom Boosts
            if State.AutoSubMushBoost then
                local subLimit = safeGetStatValue("HasShinySubGamePass", false) and 4 or 1
                local subClaimed = safeGetStatValue("SubBoostsClaimed", 0)
                if subClaimed < subLimit then
                    RemoteClaimSubBoost:FireServer()
                end
                local mushLimit = safeGetStatValue("HasMetallicMushroomGamePass", false) and 4 or 1
                local mushClaimed = safeGetStatValue("MushBoostsClaimed", 0)
                if mushClaimed < mushLimit then
                    RemoteClaimMushBoost:FireServer()
                end
            end

            -- Auto Open Unlockable Doors
            if State.AutoOpenDoors then
                for _, d in ipairs(DoorAreaMap) do
                    if not safeGetStatValue(d.Prop, false) and unlockedArea >= d.AreaReq then
                        RemoteOpenDoor:FireServer(d.Index)
                    end
                end
                if not safeGetStatValue("Door_3", false) and discovered >= 240 then
                    RemoteOpenDoor:FireServer(3)
                end
            end

            -- Auto Buy Gold Stat Upgrades
            if State.AutoBuyGoldStats and type(State.SelectedGoldStats) == "table" then
                local tree = safeInvoke("GetUpgradeTree") or {}
                for _, statName in ipairs(State.SelectedGoldStats) do
                    local cfg = StatIncreasePrices[statName]
                    local tier = safeGetStatValue(statName .. "Tier", 0)
                    if cfg and cfg.Prices then
                        local cap = cfg.VanillaCap or #cfg.Prices
                        if tree["Mega_" .. statName] then
                            cap = #cfg.Prices
                        elseif tree["Extended_" .. statName] then
                            cap = cfg.ExtendedCap or #cfg.Prices
                        end
                        if tier < cap then
                            local nextPrice = cfg.Prices[tier + 1]
                            if nextPrice and safeGetStatValue("Gold", 0) >= nextPrice then
                                RemoteBuyStatIncrease:FireServer(statName)
                            end
                        end
                    end
                end
            end

            -- Auto Buy Pet Equip Slots
            if State.AutoBuyEquipSlots then
                local slotTable = safeInvoke("GetPetEquipSlotShops") or {}
                for idx = 1, #PetEquipSlotPrices do
                    if not slotTable[idx] then
                        local price = PetEquipSlotPrices[idx]
                        if price and safeGetStatValue("Gold", 0) >= price then
                            RemoteBuyPetEquipSlot:FireServer(idx)
                        end
                        break
                    end
                end
            end

            -- Auto Buy Rebirth Upgrade Tree (Mythic Gems)
            if State.AutoBuyRebirthTree then
                local tree = safeInvoke("GetUpgradeTree") or {}
                local gems = safeGetStatValue("MythicGems", 0)
                local exScore = safeGetStatValue("ExoticCrystalScore", 0)
                local mScore = safeGetStatValue("MetallicScore", 0)

                local function prereqMet(node)
                    if node.ExoticCrystalScoreRequirement and exScore < node.ExoticCrystalScoreRequirement then
                        return false
                    end
                    if node.PetScoreRequirement and petScore < node.PetScoreRequirement then
                        return false
                    end
                    if node.MetallicScoreRequirement and mScore < node.MetallicScoreRequirement then
                        return false
                    end
                    local p = node.Prerequisite
                    if not p then
                        return true
                    end
                    if StatIncreasePrices[p] then
                        return safeGetStatValue(p .. "Tier", 0) >= (node.Prerequisite_Tier or 1)
                    end
                    return tree[p] == true
                end

                for key, node in pairs(UpgradeTreeDB) do
                    if gems <= 0 then break end
                    if node.Price and not tree[key] and prereqMet(node) and gems >= node.Price then
                        RemoteBuyUpgrade:FireServer(key)
                        gems = gems - node.Price
                    elseif not node.Price and StatIncreasePrices[key] and prereqMet(node) then
                        local scfg = StatIncreasePrices[key]
                        local tier = safeGetStatValue(key .. "Tier", 0)
                        local maxTier = scfg.Quantity or (scfg.Prices and #scfg.Prices or 0)
                        if tier < maxTier then
                            local p = scfg.Price or (scfg.Prices and scfg.Prices[tier + 1])
                            if p and gems >= p then
                                RemoteBuyStatIncrease:FireServer(key)
                                gems = gems - p
                            end
                        end
                    end
                end
            end

            -- Auto Buy Rune Upgrades
            if State.AutoBuyRunes then
                local curRunes = safeGetStatValue("Runes", 0)
                for _, rStat in ipairs(RuneStatNames) do
                    local rcfg = StatIncreasePrices[rStat]
                    local tier = safeGetStatValue(rStat .. "Tier", 0)
                    if rcfg and rcfg.Prices and tier < #rcfg.Prices then
                        local price = rcfg.Prices[tier + 1]
                        if price and curRunes >= price then
                            RemoteBuyStatIncrease:FireServer(rStat)
                            curRunes = curRunes - price
                        end
                    end
                end
            end

            -- Auto Calcify Loop
            if State.AutoCalcifyLoop then
                RemoteCalcifyAll:FireServer()
            end

            -- Auto Claim Lab Tasks
            if State.AutoClaimLabTasks then
                local tProg = safeInvoke("GetTaskProgress") or {}
                local tComp = safeInvoke("GetCompletedTasks") or {}
                for taskName, val in pairs(tProg) do
                    if val == "?" and not tComp[taskName] then
                        RemoteClaimTask:FireServer(taskName)
                    end
                end
            end

            -- Auto Upgrade Research
            if State.AutoUpgradeResearch then
                local activePreset = safeGetStatValue("ActiveResearch", 1)
                local ok, rData = pcall(function()
                    return RemoteGetResearch:InvokeServer(activePreset)
                end)
                ensureIdentity()
                if ok and type(rData) == "table" then
                    local academic = safeGetStatValue("AcademicTier", 0)
                    local totalRP = safeGetStatValue("ResearchPoints", 0)
                    local spent = 0
                    local tierSpent = table.create(8, 0)
                    for id, info in pairs(ResearchDB) do
                        local lvl = rData[id] or 0
                        spent = spent + lvl * info.Price
                        if info.Tier < 8 then
                            tierSpent[info.Tier] = tierSpent[info.Tier] + lvl
                        end
                    end
                    local remRP = totalRP - spent
                    for id, info in pairs(ResearchDB) do
                        if remRP < info.Price then break end
                        local lvl = rData[id] or 0
                        local tierUnlocked = info.Tier <= (academic + 1)
                        local prevReqMet = (info.Tier == 1) or (tierSpent[info.Tier - 1] >= (ResearchTierRequirements[info.Tier - 1] or 0))
                        if tierUnlocked and prevReqMet and lvl < info.Max then
                            RemoteIncreaseResearch:FireServer(activePreset, id)
                            remRP = remRP - info.Price
                        end
                    end
                end
            end

            -- Auto Unlock Badges
            if State.AutoUnlockBadges then
                claimAllBadges()
            end
        end

        task.wait(0.25)
    end
end)

-- Register Cleanup Handler
local cleanedUp = false
local function fullCleanup()
    if cleanedUp then
        return
    end
    cleanedUp = true
    Running = false
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    for _, cb in ipairs(CleanupCallbacks) do
        pcall(cb)
    end
    table.clear(CleanupCallbacks)
    pcall(function()
        if CleanupSignal and CleanupSignal.Parent then
            CleanupSignal:Destroy()
        end
    end)
end

connectSignal(CleanupSignal.Event, fullCleanup)

if _STATE and _STATE.onCleanup then
    _STATE.onCleanup(fullCleanup)
end

notify("XLunaHUB", "Loaded Collect All Pets! Press LeftCTRL or tap XLunaHUB button to toggle UI.", 4, "paw-print")
