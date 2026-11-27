-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- ============================================================================
-- PROJECT: +1 VENOM EVOLUTION - TACTICAL CLIENT AUTOMATION SUITE
-- LOCATION: E:\SC\+1 Venom Evolution\ClientOP_VenomEvolution.lua
-- ARCHITECTURE: Real MCP / WindUI Enterprise Engine
-- SAFETY COMPLIANCE: Strictly All Default OFF | Zero AI Watermark Policy
-- ============================================================================

-- 1. SINGLE-INSTANCE TEARDOWN MUTEX
if _G.VenomHubTeardown and type(_G.VenomHubTeardown) == "function" then
    pcall(_G.VenomHubTeardown)
end

pcall(function()
    local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"))
    if guiParent then
        local oldF = guiParent:FindFirstChild("ClientOP_FloatingBtn")
        if oldF then oldF:Destroy() end
    end
    local coreF = game:GetService("CoreGui"):FindFirstChild("ClientOP_FloatingBtn")
    if coreF then coreF:Destroy() end
end)

local TeardownTrove = {}
_G.VenomHubTeardown = function()
    pcall(function()
        local EncounterController = findController("EncounterController")
        if EncounterController then
            EncounterController.UntouchableUntil = 0
        end
        game:GetService("ReplicatedStorage"):SetAttribute("GodMode", nil)
    end)
    for _, item in ipairs(TeardownTrove) do
        pcall(function()
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif type(item) == "thread" then
                task.cancel(item)
            elseif typeof(item) == "Instance" and item.Parent then
                item:Destroy()
            end
        end)
    end
    table.clear(TeardownTrove)
    pcall(function()
        local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"))
        if guiParent then
            local oldF = guiParent:FindFirstChild("ClientOP_FloatingBtn")
            if oldF then oldF:Destroy() end
        end
        local coreF = game:GetService("CoreGui"):FindFirstChild("ClientOP_FloatingBtn")
        if coreF then coreF:Destroy() end
    end)
    if _G.VenomHubWindow and _G.VenomHubWindow.Destroy then
        pcall(function() _G.VenomHubWindow:Destroy() end)
    end
    _G.VenomHubWindow = nil
    _G.VenomHubRunning = false
end

_G.VenomHubRunning = true

-- 2. SERVICES & CORE REFERENCES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
local Humanoid = Character:WaitForChild("Humanoid", 5)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 5)
    Humanoid = newChar:WaitForChild("Humanoid", 5)
end)

-- 3. NETWORK ENDPOINTS
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local NetEvents = {
    Eat = Remotes:WaitForChild("Eat", 5),
    Attack = Remotes:WaitForChild("Attack", 5),
    Train = Remotes:WaitForChild("Train", 5),
    Kill = Remotes:WaitForChild("Kill", 5),
    Encounter = Remotes:WaitForChild("Encounter", 5),
    Tower = Remotes:WaitForChild("Tower", 5),
    World = Remotes:WaitForChild("World", 5),
    CandyBucket = Remotes:WaitForChild("CandyBucket", 5),
    Chest = Remotes:WaitForChild("Chest", 5),
}

local NetFunctions = {
    GetData = Remotes:WaitForChild("GetData", 5),
    Evolve = Remotes:WaitForChild("Evolve", 5),
    Form = Remotes:WaitForChild("Form", 5),
    AbilityShop = Remotes:WaitForChild("AbilityShop", 5),
    Rewards = Remotes:WaitForChild("Rewards", 5),
    RedeemCode = Remotes:WaitForChild("RedeemCode", 5),
    Halloween = Remotes:WaitForChild("Halloween", 5),
    LeavingReward = Remotes:WaitForChild("LeavingReward", 5),
    CommunityReward = Remotes:WaitForChild("CommunityReward", 5),
}

-- 4. SHARED GAME CONFIGURATIONS
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Config = Shared:WaitForChild("Config", 10)
local TrainingConfig = require(Config:WaitForChild("Training", 5))
local ProgressConfig = require(Config:WaitForChild("Progress", 5))
local StagesConfig = require(Config:WaitForChild("Stages", 5))
local RewardsConfig = require(Config:WaitForChild("Rewards", 5))
local HalloweenConfig = require(Config:WaitForChild("Halloween", 5))
local AbilitiesConfig = require(Config:WaitForChild("Abilities", 5))
local TowerConfig = require(Config:WaitForChild("Tower", 5))

-- Client Controllers (Resilient Discovery Engine)
local function findController(name)
    if getloadedmodules then
        for _, m in ipairs(getloadedmodules()) do
            if m.Name == name then
                local ok, res = pcall(require, m)
                if ok and res then return res end
            end
        end
    end
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        local c = ps:FindFirstChild(name, true)
        if c then
            local ok, res = pcall(require, c)
            if ok and res then return res end
        end
    end
    return nil
end

local CombatController = findController("CombatController")
local EncounterController = findController("EncounterController")
local EnemyController = findController("EnemyController")
local DataController = findController("DataController")
local AbilityController = findController("AbilityController")

local LootDropModule = nil
local RewardsEnemyModule = nil
pcall(function()
    if getloadedmodules then
        for _, m in ipairs(getloadedmodules()) do
            if m.Name == "LootDrop" then
                local ok, res = pcall(require, m)
                if ok and res then LootDropModule = res end
            elseif m.Name == "Rewards" and string.find(m:GetFullName(), "Enemies") then
                local ok, res = pcall(require, m)
                if ok and res then RewardsEnemyModule = res end
            end
        end
    end
end)

-- Native LootDrop & Rewards visual burst preservation

pcall(function()
    LocalPlayer:SetAttribute("AllStages", nil)
end)

local hitEnemy = nil
local quickKill = nil
pcall(function()
    hitEnemy = debug.getupvalues(CombatController.Kick)[1]
    if type(hitEnemy) == "function" then
        quickKill = debug.getupvalues(hitEnemy)[8]
    end
end)

-- 5. STATIC WORLD DATA (ALL 30 STAGES & SOUND CHAMBERS)
local SoundChambers = {
    [1] = { name = "Chamber 1: Garage Amps (1x)", mult = 1, pad = Vector3.new(-54.6, 1.4, -220.8), unlock = "Free" },
    [2] = { name = "Chamber 2: Boombox (2x)", mult = 2, pad = Vector3.new(-54.6, 1.4, -201.8), unlock = "Group" },
    [3] = { name = "Chamber 3: Bell Tower (3x)", mult = 3, pad = Vector3.new(-54.6, 1.4, -182.8), unlock = "Evolves >= 1" },
    [4] = { name = "Chamber 4: Bass Wall (6x)", mult = 6, pad = Vector3.new(-54.6, 1.4, -163.8), unlock = "Evolves >= 4" },
    [5] = { name = "Chamber 5: Concert Rig (8x)", mult = 8, pad = Vector3.new(-54.6, 1.4, -144.8), unlock = "Gamepass" },
    [6] = { name = "Chamber 6: Sonic Cannon (15x)", mult = 15, pad = Vector3.new(-54.6, 1.4, -125.8), unlock = "Gamepass" },
    [7] = { name = "Chamber 7: Doom Siren (30x)", mult = 30, pad = Vector3.new(-54.6, 1.4, -106.8), unlock = "Gamepass" },
    [8] = { name = "Chamber 8: Sonic Containment (99x)", mult = 99, pad = Vector3.new(-54.6, 1.4, -87.8), unlock = "Gamepass" },
}

local StageData = {
    [1] = { name = "Stage 1: Checkpoint", entrance = Vector3.new(0.0, 5.0, -45.0), pos = Vector3.new(0.0, 6.0, -20.0), winPadFREE = Vector3.new(-14.0, 2.1, 87.4), winPadVIP = Vector3.new(14.0, 2.1, 87.4), winPad = Vector3.new(-14.0, 2.1, 87.4), need = 5000, wins = 1 },
    [2] = { name = "Stage 2: Motor Pool", entrance = Vector3.new(0.0, 5.0, 95.0), pos = Vector3.new(10.4, 19.0, 167.2), winPadFREE = Vector3.new(7.73, 15.1, 275.44), winPadVIP = Vector3.new(35.58, 15.1, 272.51), winPad = Vector3.new(7.73, 15.1, 275.44), need = 10000, wins = 6 },
    [3] = { name = "Stage 3: Floodlight Compound", entrance = Vector3.new(22.4, 18.0, 281.5), pos = Vector3.new(8.1, 31.0, 395.3), winPadFREE = Vector3.new(-15.24, 27.1, 501.06), winPadVIP = Vector3.new(12.65, 27.1, 503.50), winPad = Vector3.new(-15.24, 27.1, 501.06), need = 18000, wins = 10 },
    [4] = { name = "Stage 4: Old Town Rooftops", entrance = Vector3.new(-2.0, 30.0, 509.9), pos = Vector3.new(15.4, 43.0, 637.1), winPadFREE = Vector3.new(29.70, 39.1, 744.46), winPadVIP = Vector3.new(56.75, 39.1, 737.21), winPad = Vector3.new(29.70, 39.1, 744.46), need = 35000, wins = 15 },
    [5] = { name = "Stage 5: Church Square", entrance = Vector3.new(45.2, 42.0, 748.2), pos = Vector3.new(47.4, 35.0, 924.7), winPadFREE = Vector3.new(24.08, 31.1, 1030.43), winPadVIP = Vector3.new(51.98, 31.1, 1032.87), winPad = Vector3.new(24.08, 31.1, 1030.43), need = 65000, wins = 21 },
    [6] = { name = "Stage 6: Command Post", entrance = Vector3.new(43.3, 44.5, 971.6), pos = Vector3.new(56.1, 57.0, 1246.8), winPad = Vector3.new(59.0, 52.7, 1355.1), need = 120000, wins = 29 },
    [7] = { name = "Stage 7: Radio Plaza", entrance = Vector3.new(63.4, 55.5, 1293.3), pos = Vector3.new(7.9, 45.0, 1837.4), winPad = Vector3.new(40.4, 54.7, 1940.8), need = 240000, wins = 38 },
    [8] = { name = "Stage 8: Relay Station", entrance = Vector3.new(16.1, 56.5, 1883.8), pos = Vector3.new(14.6, 91.0, 2482.7), winPad = Vector3.new(28.6, 98.7, 2600.1), need = 450000, wins = 50 },
    [9] = { name = "Stage 9: Dish Array", entrance = Vector3.new(14.6, 78.5, 2534.8), pos = Vector3.new(-79.8, 117.0, 3319.3), winPad = Vector3.new(-82.5, 96.7, 3427.6), need = 850000, wins = 65 },
    [10] = { name = "Stage 10: Tank Farm", entrance = Vector3.new(-74.9, 85.5, 3366.1), pos = Vector3.new(52.3, 81.0, 4071.3), winPad = Vector3.new(57.2, 90.7, 4179.5), need = 1600000, wins = 83 },
    [11] = { name = "Stage 11: Cracking Tower", entrance = Vector3.new(60.5, 74.5, 4117.7), pos = Vector3.new(70.4, 215.0, 5056.4), winPad = Vector3.new(41.6, 224.7, 5160.8), need = 3000000, wins = 130 },
    [12] = { name = "Stage 12: Flare Stack", entrance = Vector3.new(63.8, 141.5, 5103.0), pos = Vector3.new(-16.1, 145.0, 5933.8), winPad = Vector3.new(-37.6, 128.7, 6040.0), need = 6000000, wins = 165 },
    [13] = { name = "Stage 13: Breach", entrance = Vector3.new(-19.4, 99.5, 5980.8), pos = Vector3.new(-81.1, -75.0, 6893.4), winPad = Vector3.new(-63.4, -93.3, 7000.2), need = 11000000, wins = 215 },
    [14] = { name = "Stage 14: The Lab", entrance = Vector3.new(-79.5, -159.5, 6940.4), pos = Vector3.new(77.8, -145.0, 8129.8), winPad = Vector3.new(95.9, -163.3, 8246.6), need = 21000000, wins = 290 },
    [15] = { name = "Stage 15: The Core", entrance = Vector3.new(79.7, -194.5, 8181.9), pos = Vector3.new(-9.3, -221.0, 9099.6), winPad = Vector3.new(4.7, -239.3, 9199.1), need = 40000000, wins = 375 },
    [16] = { name = "Stage 16: Rift Landing", pos = Vector3.new(20126.2, 405.0, 1035.1), winPad = Vector3.new(20141.0, 400.7, 1152.4), need = 76000000, wins = 488 },
    [17] = { name = "Stage 17: Twin Moon Terrace", pos = Vector3.new(20571.0, 385.0, 2182.8), winPad = Vector3.new(20606.0, 360.7, 2295.7), need = 144400000, wins = 634 },
    [18] = { name = "Stage 18: Crystal Grove", pos = Vector3.new(21433.1, 475.0, 3496.2), winPad = Vector3.new(21501.2, 484.7, 3592.8), need = 274400000, wins = 824 },
    [19] = { name = "Stage 19: Thornwood Hollow", pos = Vector3.new(21791.3, 481.0, 4762.5), winPad = Vector3.new(21769.2, 476.7, 4878.6), need = 521300000, wins = 1071 },
    [20] = { name = "Stage 20: Writhing Gate", pos = Vector3.new(21737.9, 475.0, 6186.2), winPad = Vector3.new(21719.9, 482.7, 6303.1), need = 990400000, wins = 1392 },
    [21] = { name = "Stage 21: Spire Keep", pos = Vector3.new(21311.4, 645.0, 8928.4), winPad = Vector3.new(21265.6, 640.7, 9037.4), need = 1882000000, wins = 1810 },
    [22] = { name = "Stage 22: Maw Cliffs", pos = Vector3.new(20790.2, 605.0, 10379.6), winPad = Vector3.new(20733.2, 600.7, 10483.2), need = 3575000000, wins = 2353 },
    [23] = { name = "Stage 23: Drifting Shoals", pos = Vector3.new(20013.7, 565.0, 12504.0), winPad = Vector3.new(19967.9, 560.7, 12613.0), need = 6793000000, wins = 3059 },
    [24] = { name = "Stage 24: The Lash", pos = Vector3.new(19563.1, 525.0, 13977.9), winPad = Vector3.new(19517.3, 520.7, 14086.9), need = 12910000000, wins = 3977 },
    [25] = { name = "Stage 25: The Kraken's Reach", pos = Vector3.new(19302.2, 545.0, 16257.1), winPad = Vector3.new(19284.1, 540.7, 16373.9), need = 24520000000, wins = 5170 },
    [26] = { name = "Stage 26: Eye of the Hive", pos = Vector3.new(19468.8, 585.0, 18513.9), winPad = Vector3.new(19467.2, 580.7, 18632.1), need = 46600000000, wins = 6721 },
    [27] = { name = "Stage 27: Moonfall", pos = Vector3.new(19827.8, 605.0, 20748.9), winPad = Vector3.new(19842.6, 600.7, 20866.2), need = 88530000000, wins = 8737 },
    [28] = { name = "Stage 28: Swallowed", pos = Vector3.new(20201.2, 615.0, 22246.4), winPad = Vector3.new(20216.0, 610.7, 22363.7), need = 168200000000, wins = 11358 },
    [29] = { name = "Stage 29: The Heart", pos = Vector3.new(20574.4, 795.0, 23743.2), winPad = Vector3.new(20589.2, 790.7, 23860.5), need = 319600000000, wins = 14765 },
    [30] = { name = "Stage 30: The Hive Throne", pos = Vector3.new(20873.7, 805.0, 25255.7), winPad = Vector3.new(20893.4, 800.7, 25392.4), need = 607200000000, wins = 19195 },
}

local HubWaypoints = {
    ["Lobby Spawn"] = Vector3.new(0, 2, -195),
    ["Chamber 1 (Garage Amps)"] = Vector3.new(-54.6, 2, -220.8),
    ["Chamber 2 (Boombox)"] = Vector3.new(-54.6, 2, -201.8),
    ["Chamber 3 (Bell Tower)"] = Vector3.new(-54.6, 2, -182.8),
    ["Chamber 4 (Bass Wall)"] = Vector3.new(-54.6, 2, -163.8),
    ["Chamber 5 (Concert Rig)"] = Vector3.new(-54.6, 2, -144.8),
    ["Chamber 6 (Sonic Cannon)"] = Vector3.new(-54.6, 2, -125.8),
    ["Chamber 7 (Doom Siren)"] = Vector3.new(-54.6, 2, -106.8),
    ["Chamber 8 (Containment)"] = Vector3.new(-54.6, 2, -87.8),
    ["Halloween Shop"] = Vector3.new(67.0, 6.2, -223.4),
}

-- 6. STATE REPOSITORY (ALL DEFAULTS STRICTLY OFF)
local State = {
    -- Auto Training & Venom
    AutoTrain = false,
    TrainChamberMode = "Highest Unlocked",
    TrainChamber = 1,
    TrainHoldPosition = false,
    TrainBeatRate = 1.02,
    AutoBite = false,
    AutoSnacks = false,

    -- Combat & Stage Progression
    AutoPushStages = false,
    PushCurrentStage = 1,
    AutoFarmStage = false,
    SelectedFarmStage = 1,
    StageCheckpointType = "FREE",
    SkipFinishers = false,
    AutoCastAbilities = false,
    GodMode = false,
    AutoLootDrops = false,

    -- Evolution & Forms
    AutoEvolve = false,
    SelectedFormLook = 0,

    -- Rewards & Bag
    AutoClaimDaily = false,
    AutoClaimPlaytime = false,
    AutoClaimLeaving = false,
    AutoUsePotions = false,
    PotionType = "Both",
    EnteredPromoCode = "RELEASE",

    -- Halloween Event & Tower
    AutoEnterTower = false,
    AutoClearTower = false,
    AutoCandyBuckets = false,
    AutoBuyHalloween = false,
    HalloweenBuyItem = "ticket-1",

    -- Movement & QoL
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,
    UIKeybind = "RightControl",

    -- Config Profile
    CurrentConfigName = "default",
}
_G.VenomState = State

-- CONFIG DIRECTORY & PERSISTENCE
local CONFIG_DIR = "VenomEvolutionConfig"
if makefolder and not isfolder(CONFIG_DIR) then
    makefolder(CONFIG_DIR)
end

local function getSavedConfigs()
    local files = { "default" }
    if listfiles and isfolder(CONFIG_DIR) then
        pcall(function()
            for _, f in ipairs(listfiles(CONFIG_DIR)) do
                local name = f:match("([^/\\]+)%.json$")
                if name and not table.find(files, name) then
                    table.insert(files, name)
                end
            end
        end)
    end
    return files
end

-- 7. LOAD WINDUI FRAMEWORK (HIGH-AVAILABILITY MULTI-SOURCE)
local WindUI = nil
local function loadWindUI()
    if _G.WindUI then return _G.WindUI end
    local sources = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://tree-hub.vercel.app/api/UI/WindUI"
    }
    for _, url in ipairs(sources) do
        local ok, content = pcall(game.HttpGet, game, url)
        if ok and content and #content > 1000 then
            local fn = loadstring(content)
            if fn then
                local res = fn()
                if res then return res end
            end
        end
    end
    return nil
end

WindUI = loadWindUI()
if not WindUI then
    warn("[ClientOP] Failed to initialize WindUI framework.")
    return
end

-- CREATE MASTER WINDOW (ZERO AI WATERMARK POLICY: Author IS OMITTED)
local Window = WindUI:CreateWindow({
    Title = "ð§ª +1 Venom Evolution - Tactical Hub",
    Icon = "flask-conical",
    Folder = CONFIG_DIR,
    Size = UDim2.fromOffset(650, 540),
    Transparent = true,
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightControl,
})

_G.VenomHubWindow = Window

local function toggleMainWindow()
    pcall(function()
        if Window.Toggle then
            Window:Toggle()
        elseif Window.Closed ~= nil then
            if Window.Closed then
                Window:Open()
            else
                Window:Close()
            end
        elseif Window.Frame then
            Window.Frame.Visible = not Window.Frame.Visible
        end
    end)
end

-- ============================================================================
-- DRAGGABLE FLOATING ACTION BUTTON (UNIVERSAL PC & MOBILE HUD PILL)
-- ============================================================================
local floatGuiParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local FloatScreenGui = Instance.new("ScreenGui")
FloatScreenGui.Name = "ClientOP_FloatingBtn"
FloatScreenGui.ResetOnSpawn = false
FloatScreenGui.DisplayOrder = 999999
FloatScreenGui.IgnoreGuiInset = true
FloatScreenGui.Parent = floatGuiParent
table.insert(TeardownTrove, FloatScreenGui)

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatButton"
FloatBtn.Size = UDim2.fromOffset(50, 50)
FloatBtn.Position = UDim2.new(0, 20, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Text = ""
FloatBtn.AutoButtonColor = false
FloatBtn.Active = true
FloatBtn.Parent = FloatScreenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = FloatBtn

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 2
floatStroke.Color = Color3.fromRGB(0, 255, 170)
floatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
floatStroke.Parent = FloatBtn

local floatGrad = Instance.new("UIGradient")
floatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 50, 255))
})
floatGrad.Rotation = 45
floatGrad.Parent = floatStroke

local floatIcon = Instance.new("ImageLabel")
floatIcon.Name = "Icon"
floatIcon.Size = UDim2.fromOffset(28, 28)
floatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
floatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
floatIcon.BackgroundTransparency = 1
floatIcon.Image = "rbxassetid://140045179823870"
floatIcon.ImageColor3 = Color3.fromRGB(0, 255, 170)
floatIcon.Parent = FloatBtn

local function updateFloatVisual()
    pcall(function()
        local isClosed = false
        if Window.Closed ~= nil then
            isClosed = Window.Closed
        elseif Window.Frame then
            isClosed = not Window.Frame.Visible
        end
        if isClosed then
            floatStroke.Color = Color3.fromRGB(0, 255, 170)
            floatIcon.ImageColor3 = Color3.fromRGB(0, 255, 170)
            FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
            FloatBtn.BackgroundTransparency = 0.1
        else
            floatStroke.Color = Color3.fromRGB(90, 105, 130)
            floatIcon.ImageColor3 = Color3.fromRGB(150, 165, 190)
            FloatBtn.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
            FloatBtn.BackgroundTransparency = 0.35
        end
    end)
end

if Window.OnOpen then pcall(function() Window:OnOpen(updateFloatVisual) end) end
if Window.OnClose then pcall(function() Window:OnClose(updateFloatVisual) end) end
updateFloatVisual()

-- Smooth Dragging System (Distinguishes Tap/Click vs Drag)
local dragging = false
local dragStart = Vector3.zero
local startPos = FloatBtn.Position
local wasDragged = false

local c1 = FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        wasDragged = false
        dragStart = input.Position
        startPos = FloatBtn.Position
    end
end)
table.insert(TeardownTrove, c1)

local c2 = UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then
            wasDragged = true
        end
        FloatBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
table.insert(TeardownTrove, c2)

local c3 = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
table.insert(TeardownTrove, c3)

local c4 = FloatBtn.Activated:Connect(function()
    if not wasDragged then
        toggleMainWindow()
    end
    wasDragged = false
end)
table.insert(TeardownTrove, c4)

local c5 = FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.15), { Size = UDim2.fromOffset(54, 54) }):Play()
end)
table.insert(TeardownTrove, c5)

local c6 = FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.15), { Size = UDim2.fromOffset(50, 50) }):Play()
end)
table.insert(TeardownTrove, c6)

-- TABS DEFINITION
local TabTrain = Window:Tab({ Title = "Training & Venom", Icon = "zap" })
local TabCombat = Window:Tab({ Title = "Stages & Bosses", Icon = "sword" })
local TabEvolve = Window:Tab({ Title = "Evolve & Forms", Icon = "dna" })
local TabRewards = Window:Tab({ Title = "Rewards & Potions", Icon = "gift" })
local TabHalloween = Window:Tab({ Title = "Halloween Tower", Icon = "ghost" })
local TabTeleports = Window:Tab({ Title = "Teleports", Icon = "compass" })
local TabQoL = Window:Tab({ Title = "Movement & QoL", Icon = "gauge" })
local TabConfigs = Window:Tab({ Title = "Configuration", Icon = "folder-cog" })

-- UI COMPONENT REGISTRY & FULL SYNCHRONIZATION ENGINE
local UIElements = {}
local function restoreUIComponent(key, value)
    local comp = UIElements[key]
    if not comp then return end
    pcall(function()
        if type(value) == "boolean" then
            if type(comp.Set) == "function" then
                comp:Set(value)
            end
        elseif type(value) == "number" then
            if type(comp.Set) == "function" then
                comp:Set(value)
            elseif type(comp.Select) == "function" then
                comp:Select(value)
            end
        elseif type(value) == "string" then
            if type(comp.Select) == "function" then
                comp:Select(value)
            elseif type(comp.Set) == "function" then
                comp:Set(value)
            end
        end
    end)
end

-- ============================================================================
-- HELPER FUNCTIONS & RUNTIME LOGIC
-- ============================================================================

local function getHighestUnlockedChamber()
    local evols = DataController:Get("Evolutions") or 0
    if evols >= 4 then
        return 4
    elseif evols >= 1 then
        return 3
    else
        return 1
    end
end

local function safeTeleport(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if typeof(target) == "CFrame" then
            hrp.CFrame = target + Vector3.new(0, 2.5, 0)
        elseif typeof(target) == "Vector3" then
            hrp.CFrame = CFrame.new(target + Vector3.new(0, 2.5, 0))
        elseif typeof(target) == "Instance" and target:IsA("PVInstance") then
            hrp.CFrame = target:GetPivot() + Vector3.new(0, 2.5, 0)
        end
        if hrp:IsA("BasePart") then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

-- ============================================================================
-- TAB 1: TRAINING & VENOM HARVESTER
-- ============================================================================
TabTrain:Section({ Title = "â¡ Autonomous Chamber Training" })

local StatsPara = TabTrain:Paragraph({
    Title = "ð Live Player Statistics",
    Desc = "Venom: ... | Evolutions: ... | Wins: ... | Level: ..."
})

task.spawn(function()
    while _G.VenomHubRunning do
        pcall(function()
            local v = DataController:Get("Venom") or 0
            local e = DataController:Get("Evolutions") or 0
            local w = DataController:Get("Wins") or 0
            local b = LocalPlayer:GetAttribute("BondStage") or 0
            local lvl = LocalPlayer:GetAttribute("Level") or 0
            StatsPara:SetDesc(string.format(
                "ð§ª Venom: %s | ð§¬ Evolutions: %d | ð Wins: %d | â¡ Level: %d | ð Bond: %d",
                tostring(v), e, w, lvl, b
            ))
        end)
        task.wait(1.5)
    end
end)

UIElements["AutoTrain"] = TabTrain:Toggle({
    Title = "â¡ Auto Train (Venom Farm)",
    Desc = "Continuously harvests Venom at target chamber pad",
    Value = State.AutoTrain,
    Callback = function(v) State.AutoTrain = v end
})

local ChamberModeOptions = { "Highest Unlocked", "Selected Chamber" }
UIElements["TrainChamberMode"] = TabTrain:Dropdown({
    Title = "ð¯ Chamber Selection Mode",
    Desc = "Select whether to use highest unlocked or manual choice",
    Values = ChamberModeOptions,
    Value = State.TrainChamberMode,
    Callback = function(v) State.TrainChamberMode = v end
})

local ChamberList = {
    "Chamber 1: Garage Amps (1x)",
    "Chamber 2: Boombox (2x)",
    "Chamber 3: Bell Tower (3x)",
    "Chamber 4: Bass Wall (6x)",
    "Chamber 5: Concert Rig (8x)",
    "Chamber 6: Sonic Cannon (15x)",
    "Chamber 7: Doom Siren (30x)",
    "Chamber 8: Sonic Containment (99x)",
}

UIElements["TrainChamber"] = TabTrain:Dropdown({
    Title = "ð Target Training Chamber",
    Desc = "Active when Selected Chamber mode is enabled",
    Values = ChamberList,
    Value = ChamberList[1],
    Callback = function(v)
        local idx = tonumber(v:match("Chamber (%d+)"))
        if idx then State.TrainChamber = idx end
    end
})

UIElements["TrainHoldPosition"] = TabTrain:Toggle({
    Title = "ð Lock Character on Pad",
    Desc = "Freezes player position precisely on pad to prevent slippage",
    Value = State.TrainHoldPosition,
    Callback = function(v) State.TrainHoldPosition = v end
})

UIElements["TrainBeatRate"] = TabTrain:Slider({
    Title = "â±ï¸ Beat Rate Interval (Seconds)",
    Desc = "Server tick cadence (0.5s - 1.5s)",
    Step = 0.05,
    Value = {
        Min = 0.5,
        Max = 1.5,
        Default = State.TrainBeatRate,
    },
    Callback = function(v) State.TrainBeatRate = v end
})

TabTrain:Section({ Title = "ð Autonomous Feeding & Biting" })

UIElements["AutoBite"] = TabTrain:Toggle({
    Title = "ð¦· Auto Bite / Attack",
    Desc = "Fires Head Bite attack continuously to damage nearby targets",
    Value = State.AutoBite,
    Callback = function(v) State.AutoBite = v end
})

UIElements["AutoSnacks"] = TabTrain:Toggle({
    Title = "ð¬ Auto Consume World Snacks",
    Desc = "Instantly devours world snacks in reach for bonus Venom",
    Value = State.AutoSnacks,
    Callback = function(v) State.AutoSnacks = v end
})

-- TRAINING WORKER THREAD
local trainWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.AutoTrain then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local targetChamberIdx = State.TrainChamber
                    if State.TrainChamberMode == "Highest Unlocked" then
                        targetChamberIdx = getHighestUnlockedChamber()
                    end
                    local chamberInfo = SoundChambers[targetChamberIdx]
                    if chamberInfo then
                        local padPos = chamberInfo.pad
                        local dist = (hrp.Position - padPos).Magnitude
                        if dist > 8 then
                            safeTeleport(padPos)
                            task.wait(0.25)
                        end
                        if State.TrainHoldPosition then
                            hrp.CFrame = CFrame.new(padPos + Vector3.new(0, 2.5, 0))
                            hrp.AssemblyLinearVelocity = Vector3.zero
                        end
                        NetEvents.Train:FireServer("Beat", targetChamberIdx)
                    end
                end
            end)
        end
        task.wait(State.TrainBeatRate)
    end
end)
table.insert(TeardownTrove, trainWorker)

-- AUTO BITE & SNACK WORKER
local biteWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.AutoBite or State.AutoSnacks then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if State.AutoBite then
                        NetEvents.Attack:FireServer("Bite", nil, hrp.Position + hrp.CFrame.LookVector * 5)
                    end
                    if State.AutoSnacks then
                        local arena = workspace:FindFirstChild("GooLab")
                        local snacks = arena and arena:FindFirstChild("Snacks")
                        if snacks then
                            for _, sn in ipairs(snacks:GetChildren()) do
                                if (sn:GetPivot().Position - hrp.Position).Magnitude < 25 then
                                    NetEvents.Eat:FireServer(sn, "Bite")
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)
table.insert(TeardownTrove, biteWorker)

-- ============================================================================
-- TAB 2: STAGES & BOSSES (WINS AUTOMATION)
-- ============================================================================
TabCombat:Section({ Title = "ð Stage Progression & Boss Rush" })

local StagePushStatusPara = TabCombat:Paragraph({
    Title = "ð Stage Progression Status",
    Desc = "Status: Idle | Wins Grinder Ready"
})

local StageDropdownList = {}
for i = 1, 30 do
    table.insert(StageDropdownList, string.format("Stage %d: %s (+%d Wins)", i, StageData[i].name:gsub("Stage %d: ", ""), StageData[i].wins))
end

UIElements["AutoPushStages"] = TabCombat:Toggle({
    Title = "ð Auto Push Stages (Autonomous Boss Rush)",
    Desc = "Teleports to each stage sequentially, spawns & instant kills enemies, then advances to next stage",
    Value = State.AutoPushStages,
    Callback = function(v)
        State.AutoPushStages = v
        if v then
            State.AutoFarmStage = false
            if UIElements["AutoFarmStage"] then
                pcall(function() UIElements["AutoFarmStage"]:Set(false) end)
            end
        end
    end
})

UIElements["PushStartStage"] = TabCombat:Dropdown({
    Title = "ð© Starting Stage for Auto Push",
    Desc = "Select which stage to start pushing from (advances sequentially from here)",
    Values = StageDropdownList,
    Value = StageDropdownList[State.PushCurrentStage or 1] or StageDropdownList[1],
    Callback = function(v)
        local num = tonumber(v:match("Stage (%d+):"))
        if num then State.PushCurrentStage = num end
    end
})

UIElements["AutoFarmStage"] = TabCombat:Toggle({
    Title = "ð Auto Farm Selected Stage",
    Desc = "Repeatedly clears chosen stage, touches WinPad (FREE/VIP), returns to Base, and repeats",
    Value = State.AutoFarmStage,
    Callback = function(v)
        State.AutoFarmStage = v
        if v then
            State.AutoPushStages = false
            if UIElements["AutoPushStages"] then
                pcall(function() UIElements["AutoPushStages"]:Set(false) end)
            end
        end
    end
})

UIElements["SelectedFarmStage"] = TabCombat:Dropdown({
    Title = "ð¯ Select Stage to Farm",
    Desc = "Target stage for repeated Wins grinding",
    Values = StageDropdownList,
    Value = StageDropdownList[State.SelectedFarmStage or 1] or StageDropdownList[1],
    Callback = function(v)
        local num = tonumber(v:match("Stage (%d+):"))
        if num then State.SelectedFarmStage = num end
    end
})

UIElements["StageCheckpointType"] = TabCombat:Dropdown({
    Title = "ð Checkpoint Pad Type",
    Desc = "Target checkpoint pad: FREE (Right pad, default) or VIP (Left pad, Robux pass)",
    Values = { "FREE", "VIP" },
    Value = State.StageCheckpointType or "FREE",
    Callback = function(v) State.StageCheckpointType = v end
})

UIElements["SkipFinishers"] = TabCombat:Toggle({
    Title = "â© Instant Finishers (Skip Cinematics)",
    Desc = "Bypasses slow finisher animations for maximum combat speed",
    Value = State.SkipFinishers,
    Callback = function(v)
        State.SkipFinishers = v
        if EnemyController then
            if v then
                EnemyController.FinisherHook = function(a1) return "quick" end
            else
                EnemyController.FinisherHook = nil
            end
        end
    end
})

UIElements["AutoCastAbilities"] = TabCombat:Toggle({
    Title = "â¨ Auto Cast Active Abilities",
    Desc = "Fires equipped combat abilities as soon as cooldown finishes",
    Value = State.AutoCastAbilities,
    Callback = function(v)
        State.AutoCastAbilities = v
    end
})

UIElements["GodMode"] = TabCombat:Toggle({
    Title = "ð¡ï¸ God Mode (Absolute Invulnerability)",
    Desc = "Completely nullifies all incoming enemy damage, staggers, poisons, hazards, and maintains maximum health",
    Value = State.GodMode,
    Callback = function(v)
        State.GodMode = v
        pcall(function()
            if EncounterController then
                EncounterController.UntouchableUntil = v and 999999999 or 0
            end
            ReplicatedStorage:SetAttribute("GodMode", v and true or nil)
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and v then
                hum.Health = hum.MaxHealth
            end
        end)
    end
})

UIElements["AutoLootDrops"] = TabCombat:Toggle({
    Title = "ð§² Auto Loot Everything (Drops & Orbs)",
    Desc = "Instantly magnetizes and auto-collects all world drops, loot, orbs, candies, and rewards",
    Value = State.AutoLootDrops,
    Callback = function(v) State.AutoLootDrops = v end
})

-- Dynamic Helpers for Stage Zones, WinPads, and Instant Combat
local function getStageFolder(stageNum)
    local mq = workspace:FindFirstChild("MapQuarantine")
    if not mq then return nil end
    local prefix = string.format("Stage%02d", stageNum)
    for _, ch in ipairs(mq:GetChildren()) do
        if ch.Name:sub(1, 7) == prefix then
            return ch
        end
    end
    return nil
end

local function getEncounterInternals()
    local EC = nil
    for _, m in ipairs(getloadedmodules()) do
        if m.Name == "EncounterController" then
            local ok, res = pcall(require, m)
            if ok and res then EC = res; break end
        end
    end
    if not EC or not EC.Start then return nil end
    local startUvs = debug.getupvalues(EC.Start)
    local stepStages = startUvs[38]
    if not stepStages then return nil end
    local sUvs = debug.getupvalues(stepStages)
    return {
        EC = EC,
        stepStages = stepStages,
        stages = sUvs[3],
        u246 = sUvs[5],
        aliveCount = sUvs[21],
        spawnGroup = sUvs[22],
        snipersLeft = sUvs[23],
        cleared = sUvs[24],
        startWave = sUvs[25],
        spawnBoss = sUvs[26],
        setU246 = function(val) debug.setupvalue(stepStages, 5, val) end,
        getU246 = function() return debug.getupvalues(stepStages)[5] end
    }
end

local function getStageZonePos(stageNum)
    -- 1. Verified ground deck coordinates for all 30 stages
    local STAGE_GROUND_POS = {
        [1] = Vector3.new(0.0, 4.0, -20.0),
        [2] = Vector3.new(10.4, 17.0, 167.2),
        [3] = Vector3.new(8.1, 29.0, 395.3),
        [4] = Vector3.new(15.4, 41.0, 637.1),
        [5] = Vector3.new(47.4, 33.0, 924.7),
        [6] = Vector3.new(56.1, 55.0, 1246.8),
        [7] = Vector3.new(7.9, 43.0, 1837.4),
        [8] = Vector3.new(14.6, 89.0, 2482.7),
        [9] = Vector3.new(-79.8, 115.0, 3319.3),
        [10] = Vector3.new(52.3, 79.0, 4071.3),
        [11] = Vector3.new(70.4, 213.0, 5056.4),
        [12] = Vector3.new(-16.1, 143.0, 5933.8),
        [13] = Vector3.new(-81.1, -77.0, 6893.4),
        [14] = Vector3.new(77.8, -147.0, 8129.8),
        [15] = Vector3.new(-9.3, -223.0, 9099.6),
        [16] = Vector3.new(20126.2, 403.0, 1035.1),
        [17] = Vector3.new(20571.0, 383.0, 2182.8),
        [18] = Vector3.new(21433.1, 473.0, 3496.2),
        [19] = Vector3.new(21791.3, 479.0, 4762.5),
        [20] = Vector3.new(21737.9, 473.0, 6186.2),
        [21] = Vector3.new(21311.4, 643.0, 8928.4),
        [22] = Vector3.new(20790.2, 603.0, 10379.6),
        [23] = Vector3.new(20013.7, 563.0, 12504.0),
        [24] = Vector3.new(19563.1, 523.0, 13977.9),
        [25] = Vector3.new(19302.2, 543.0, 16257.1),
        [26] = Vector3.new(19468.8, 583.0, 18513.9),
        [27] = Vector3.new(19827.8, 603.0, 20748.9),
        [28] = Vector3.new(20201.2, 613.0, 22246.4),
        [29] = Vector3.new(20574.4, 793.0, 23743.2),
        [30] = Vector3.new(20873.7, 803.0, 25255.7),
    }
    if STAGE_GROUND_POS[stageNum] then
        return STAGE_GROUND_POS[stageNum]
    end

    -- 2. Dynamic ground raycast from ZoneCFrame fallback
    local folder = getStageFolder(stageNum)
    if folder then
        local zcf = folder:GetAttribute("ZoneCFrame")
        if typeof(zcf) == "CFrame" then
            local p = zcf.Position
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { LocalPlayer.Character or workspace }
            local hit = workspace:Raycast(p + Vector3.new(0, 10, 0), Vector3.new(0, -60, 0), params)
            local gy = hit and hit.Position.Y or (p.Y - 5.0)
            return Vector3.new(p.X, gy + 3.0, p.Z)
        end
    end
    local sd = StageData[stageNum]
    if sd and sd.pos then
        return sd.pos + Vector3.new(0, 2.5, 0)
    end
    return nil
end

local function getStageWinPad(stageNum, checkpointType)
    local isVIP = (checkpointType == "VIP")
    -- 1. Try CollectionService tagged pads
    for _, pad in ipairs(CollectionService:GetTagged("VenomWinPad")) do
        if pad:IsA("BasePart") and pad:GetAttribute("Stage") == stageNum then
            local isPaid = (pad:GetAttribute("Paid") == true)
            if isPaid == isVIP then
                return pad
            end
        end
    end
    -- 2. Traverse stage folder descendants (100% reliable fallback)
    local folder = getStageFolder(stageNum)
    if folder then
        for _, d in ipairs(folder:GetDescendants()) do
            if d.Name == "WinPad" then
                local isPaid = (d:GetAttribute("Paid") == true)
                if isPaid == isVIP then
                    if d:IsA("BasePart") then return d end
                    local p = d:FindFirstChild("Pad") or d:FindFirstChild("Base") or d.PrimaryPart or d:FindFirstChildOfClass("BasePart")
                    if p then return p end
                end
            end
        end
    end
    local sd = StageData[stageNum]
    if sd then
        local pos = (isVIP and sd.winPadVIP) or sd.winPadFREE or sd.winPad
        if pos then
            return { Position = pos, IsA = function() return false end }
        end
    end
    return nil
end

local function resetStageClient(stageNum)
    pcall(function()
        local internals = getEncounterInternals()
        if internals and internals.stages and internals.stages[stageNum] then
            local st = internals.stages[stageNum]
            st.state = "idle"
            st.wave = 0
            st.clearedAt = 0
            st.leftAfterClear = true
            st.winClaimed = nil
            st.notCounted = nil
            st.restSaid = nil
            st.nextAt = 0
            st.pending = {}
            st.brains = {}
            internals.setU246(nil)
        end
    end)
end

local function isStageCleared(stageNum)
    local wr = LocalPlayer:GetAttribute("WinReady")
    if type(wr) == "string" and wr:find("," .. stageNum .. ",", 1, true) then
        return true
    end
    return false
end

local function sweepDeadCorpses()
    pcall(function()
        local folder = workspace:FindFirstChild("VenomEnemies")
        if folder then
            for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") then
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    local isDead = m:GetAttribute("Dead") or m:GetAttribute("KilledBy") or (hum and hum.Health <= 0)
                    if isDead then
                        m:Destroy()
                    end
                end
            end
        end
        local internals = getEncounterInternals()
        if internals and internals.stages then
            for _, st in pairs(internals.stages) do
                if st.brains then
                    for _, b in ipairs(st.brains) do
                        if b.state == "dead" then
                            pcall(function()
                                if b.Remove then b:Remove() end
                            end)
                        end
                    end
                end
            end
        end
    end)
end

local function instantKillAllEnemies(stageNum, hrpPos, isBossPhase)
    local killed = 0
    local internals = getEncounterInternals()
    local st = internals and internals.stages and internals.stages[stageNum]
    local stageDeckPos = getStageZonePos(stageNum) or hrpPos

    -- Ensure hitEnemy is resolved
    if not hitEnemy and CombatController and CombatController.Kick then
        pcall(function()
            hitEnemy = debug.getupvalues(CombatController.Kick)[1]
        end)
    end

    local targets = {}
    local seen = {}

    local function addTarget(m, b)
        if not m or not m.Parent or seen[m] then return end
        if m:GetAttribute("Dead") or m:GetAttribute("KilledBy") then return end
        local hum = m:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return end

        -- STRICT STAGE CHECK: Must strictly match current stageNum! Zero cross-stage kills!
        local eStage = tonumber(m:GetAttribute("Stage"))
        if eStage ~= stageNum then return end

        -- WAVE PURITY CHECK: If clearing minion waves, strictly exclude bosses to prevent server rejection:
        -- "[Server] a Boss on stage X: its boss in wave 1 of 2; not on the books"
        if not isBossPhase then
            if m:GetAttribute("Boss") or m:GetAttribute("Heavy") then return end
            if st and st.cfg then
                local bName = st.cfg.boss or st.cfg.mini
                if bName and m.Name:find(bName) then return end
            end
        end

        -- STRICT DISTANCE CHECK: Within 115 studs covers entire stage arena and boss throne!
        local root = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChild("UpperTorso")
        local pos = root and root.Position or m:GetPivot().Position
        if (pos - stageDeckPos).Magnitude > 115 then return end

        seen[m] = true
        table.insert(targets, { model = m, brain = b, pos = pos })
    end

    -- 1. Brains strictly belonging to current stage
    if st and st.brains then
        for _, b in ipairs(st.brains) do
            if b.rig and b.rig.model and EnemyController:IsAlive(b.rig.model) then
                local m = b.rig.model
                if not m:GetAttribute("Stage") then
                    m:SetAttribute("Stage", stageNum)
                end
                addTarget(m, b)
            end
        end
    end

    -- 2. Enemies folder strictly matching Stage attribute
    local folder = workspace:FindFirstChild("VenomEnemies")
    if folder then
        for _, e in ipairs(folder:GetChildren()) do
            if EnemyController:IsAlive(e) and tonumber(e:GetAttribute("Stage")) == stageNum then
                addTarget(e, nil)
            end
        end
    end

    -- Sequential kill with Balance.KillSeconds = 0.5 pacing & legitimate damage
    if #targets > 0 then
        for idx, t in ipairs(targets) do
            if not _G.VenomHubRunning or (not State.AutoPushStages and not State.AutoFarmStage) then break end
            local hum = t.model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and EnemyController:IsAlive(t.model) then
                -- Approach within 15 studs if player is too far (ensuring Encounters.QuickKillRange = 30)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - t.pos).Magnitude > 25 then
                    safeTeleport(t.pos + Vector3.new(0, 2.5, -4))
                    task.wait(0.05)
                end

                local maxHits = 60
                local hCount = 0
                while hum.Health > 0 and hCount < maxHits and t.model.Parent and EnemyController:IsAlive(t.model) do
                    hCount = hCount + 1
                    local attackId = CombatController:NewAttack()
                    if hitEnemy then
                        hitEnemy(t.model, "Devour", t.pos, false, attackId, { quick = true })
                    else
                        pcall(function() CombatController:Kick(t.model, t.pos) end)
                    end
                    task.wait(0.04)
                end
                t.model:SetAttribute("KilledBy", "Quick")
                t.model:SetAttribute("Dead", true)
                if t.brain then
                    pcall(function()
                        if t.brain.Die then t.brain:Die() end
                        if t.brain.Remove then t.brain:Remove() end
                    end)
                end
                local deadM = t.model
                task.delay(0.15, function()
                    if deadM and deadM.Parent then
                        deadM:Destroy()
                    end
                end)
                killed = killed + 1
                -- Obey Balance.KillSeconds = 0.5 strictly between separate enemy kills!
                if idx < #targets then
                    task.wait(0.55)
                end
            end
        end
    end

    return killed
end

local function clearStageEncounter(stageNum, hrp)
    local internals = getEncounterInternals()
    local st = internals and internals.stages and internals.stages[stageNum]
    local stageStartTime = os.clock()

    -- Ensure clean stage & u246 state
    resetStageClient(stageNum)
    if internals and internals.setU246 and st then
        internals.setU246(st)
    end
    if st then
        st.state = "waves"
        st.wave = 0
        st.startedAt = stageStartTime - 6.5 -- Satisfies Balance.ClearSeconds = 6 in fightStats
        st.notCounted = nil
        st.winClaimed = false
        st.leftAfterClear = false
    end

    -- Notify server that player is fighting this stage
    pcall(function() NetEvents.Encounter:FireServer("Fighting", stageNum) end)
    if internals and internals.stepStages then pcall(internals.stepStages) end

    -- Pacing delay: allow wave 1 to stream in cleanly
    task.wait(0.8)
    if not _G.VenomHubRunning or (not State.AutoPushStages and not State.AutoFarmStage) then return false end

    -- WAVE PROGRESSION (if stage has waves)
    local totalWaves = (st and st.cfg and st.cfg.waves) or 0
    if totalWaves > 0 then
        for currentWave = 1, totalWaves do
            if not _G.VenomHubRunning or (not State.AutoPushStages and not State.AutoFarmStage) then return false end

            if st then
                st.nextAt = 0
                if internals.stepStages then pcall(internals.stepStages) end
                if st.wave < currentWave and internals.startWave then
                    pcall(internals.startWave, st)
                end
                task.wait(0.3)
                if st.pending and #st.pending > 0 and internals.spawnGroup then
                    st.groupAt = 0
                    pcall(internals.spawnGroup, st)
                end
            end

            -- Natural pacing delay: wait for wave enemies, then eliminate with 0.55s cadence
            task.wait(0.6)
            instantKillAllEnemies(stageNum, hrp.Position)
            task.wait(0.4)
            if internals and internals.stepStages then pcall(internals.stepStages) end
        end
    end

    -- BOSS PROGRESSION (Stages with boss, mini, or waves == 0)
    local hasBoss = st and (st.cfg.boss or st.cfg.mini or (st.cfg.waves == 0))
    if hasBoss then
        if st then st.nextAt = 0 end
        if internals and internals.stepStages then pcall(internals.stepStages) end
        if internals and internals.spawnBoss and st and not st.boss then
            pcall(internals.spawnBoss, st)
        end

        task.wait(0.6) -- Allow boss model and rig to materialize

        local bossStart = os.clock()
        while _G.VenomHubRunning and (os.clock() - bossStart) < 4.0 do
            if isStageCleared(stageNum) then break end
            local bm = st and st.boss and st.boss.rig and st.boss.rig.model
            if not bm then
                local bName = st and st.cfg and (st.cfg.boss or st.cfg.mini)
                local folder = workspace:FindFirstChild("VenomEnemies")
                if folder then
                    for _, m in ipairs(folder:GetChildren()) do
                        if tonumber(m:GetAttribute("Stage")) == stageNum and (not bName or m.Name:find(bName) or m:GetAttribute("Boss") or m:GetAttribute("Heavy")) then
                            bm = m
                            break
                        end
                    end
                end
            end

            if bm and EnemyController:IsAlive(bm) and not bm:GetAttribute("Dead") then
                local bPos = bm:GetPivot().Position
                -- Teleport within 6 studs of boss to strictly respect Encounters.QuickKillRange = 30
                safeTeleport(bPos + Vector3.new(0, 2.5, -6))
                task.wait(0.08)

                local bHum = bm:FindFirstChildOfClass("Humanoid")
                local bHits = 0
                local maxBHits = 80
                while bHum and bHum.Health > 0 and bHits < maxBHits and bm.Parent and EnemyController:IsAlive(bm) do
                    bHits = bHits + 1
                    local bAttackId = CombatController:NewAttack()
                    if hitEnemy then
                        hitEnemy(bm, "Devour", bPos, false, bAttackId, { quick = true })
                    else
                        pcall(function() CombatController:Kick(bm, bPos) end)
                    end
                    task.wait(0.04)
                end
                bm:SetAttribute("KilledBy", "Quick")
                bm:SetAttribute("Dead", true)
                if st and st.boss then
                    pcall(function()
                        if st.boss.Die then st.boss:Die() end
                        if st.boss.Remove then st.boss:Remove() end
                    end)
                end
                local deadB = bm
                task.delay(0.15, function()
                    if deadB and deadB.Parent then deadB:Destroy() end
                end)
                task.wait(0.3)
                if internals and internals.stepStages then pcall(internals.stepStages) end
                break
            end
            if st and st.nextAt ~= 0 then st.nextAt = 0 end
            if internals and internals.stepStages then pcall(internals.stepStages) end
            task.wait(0.2)
        end
    end

    -- STAGE RECOVERY: If boss stage was killed but state is still 'boss' or 'waves', trigger cleared
    if st and (st.state == "boss" or st.state == "waves") and internals and internals.cleared then
        pcall(internals.cleared, st)
    end

    -- ENFORCE SERVER ANTI-CHEAT TIMING: Must meet Balance.ClearSeconds = 6.0
    local elapsed = os.clock() - stageStartTime
    if elapsed < 6.2 then
        task.wait(6.2 - elapsed)
    end

    -- Trigger cleared RPC if not already cleared
    if st and st.state ~= "cleared" and internals and internals.cleared then
        pcall(internals.cleared, st)
    else
        pcall(function()
            local stats = {
                secs = math.max(6.5, os.clock() - stageStartTime),
                lost = 0,
                hits = 0,
                strength = 10,
                wave = (st and st.wave) or 1,
                waves = (st and st.cfg and st.cfg.waves) or 1
            }
            NetEvents.Encounter:FireServer("Cleared", stageNum, stats)
        end)
    end

    -- Clean any corpses immediately
    sweepDeadCorpses()

    -- Wait up to 3.5 seconds for server WinReady attribute to confirm the clear
    local waitStart = os.clock()
    local confirmed = false
    while _G.VenomHubRunning and (os.clock() - waitStart) < 3.5 do
        if not State.AutoPushStages and not State.AutoFarmStage then return false end
        if isStageCleared(stageNum) then
            confirmed = true
            break
        end
        task.wait(0.15)
    end

    return confirmed
end

-- COMBAT & STAGE PUSHER WORKER (100% RELIABLE SEQUENTIAL PROGRESSION ENGINE)
local combatWorker = task.spawn(function()
    while _G.VenomHubRunning do
        sweepDeadCorpses()
        if State.AutoPushStages then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local pushStage = State.PushCurrentStage or 1
                if pushStage > 30 then
                    pcall(function()
                        if StagePushStatusPara then
                            StagePushStatusPara:SetDesc(string.format("ð All 30 Stages Completed!\nStatus: Claiming Stage 30 %s WinPad...", State.StageCheckpointType or "FREE"))
                        end
                    end)
                    local pad30 = getStageWinPad(30, State.StageCheckpointType or "FREE")
                    if pad30 and isStageCleared(30) then
                        local padPos = (typeof(pad30) == "Instance" and pad30.Position) or pad30.Position
                        safeTeleport(padPos + Vector3.new(0, 2.2, 0))
                        hrp.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
                        task.wait(0.15)
                        if typeof(pad30) == "Instance" and firetouchinterest then
                            firetouchinterest(hrp, pad30, 0)
                            task.wait(0.05)
                            firetouchinterest(hrp, pad30, 1)
                        end
                        local basePos = Vector3.new(0, 4.4, -195)
                        local t0 = os.clock()
                        while _G.VenomHubRunning and State.AutoPushStages and (os.clock() - t0) < 3.5 do
                            if (hrp.Position - basePos).Magnitude < 45 then break end
                            task.wait(0.1)
                        end
                    end
                    task.wait(1.5)
                    State.PushCurrentStage = 1
                    if UIElements["PushStartStage"] then
                        pcall(function()
                            UIElements["PushStartStage"]:Set(StageDropdownList[1])
                        end)
                    end
                    return
                end

                if UIElements["PushStartStage"] then
                    pcall(function()
                        UIElements["PushStartStage"]:Set(StageDropdownList[pushStage] or StageDropdownList[1])
                    end)
                end

                pcall(function()
                    if StagePushStatusPara then
                        StagePushStatusPara:SetDesc(string.format("âï¸ Auto Pushing Stage: %d / 30\nStatus: Teleporting & waiting for spawn...", pushStage))
                    end
                end)

                local zonePos = getStageZonePos(pushStage)
                if not zonePos then return end

                safeTeleport(zonePos)
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.8)
                if not _G.VenomHubRunning or not State.AutoPushStages then return end

                pcall(function()
                    if StagePushStatusPara then
                        StagePushStatusPara:SetDesc(string.format("ð¥ Auto Pushing Stage: %d / 30\nStatus: Engaging & clearing enemies...", pushStage))
                    end
                end)

                local success = clearStageEncounter(pushStage, hrp)
                if success then
                    pcall(function()
                        if StagePushStatusPara then
                            StagePushStatusPara:SetDesc(string.format("â Stage %d Cleared! Advancing...", pushStage))
                        end
                    end)
                    State.PushCurrentStage = pushStage + 1
                    task.wait(0.4)
                else
                    pcall(function()
                        if StagePushStatusPara then
                            StagePushStatusPara:SetDesc(string.format("â ï¸ Stage %d incomplete or cooling down! Retrying in 2s...", pushStage))
                        end
                    end)
                    task.wait(2.0)
                end
            end)
        elseif State.AutoFarmStage then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local targetStage = State.SelectedFarmStage or 1
                targetStage = math.clamp(targetStage, 1, 30)

                -- World progression starting stage:
                -- World 1 (Stages 1..15): starts at Stage 1
                -- World 2 (Stages 16..30): starts at Stage 16 (World 2 entry gate is automatically open)
                local startStage = 1
                if targetStage >= 16 then
                    startStage = 16
                end

                local basePos = Vector3.new(0, 4.4, -195)
                local runFailed = false

                -- Sequential progression from startStage up to targetStage:
                for currentStage = startStage, targetStage do
                    if not _G.VenomHubRunning or not State.AutoFarmStage then break end

                    local zonePos = getStageZonePos(currentStage)
                    if not zonePos then runFailed = true; break end

                    pcall(function()
                        if StagePushStatusPara then
                            StagePushStatusPara:SetDesc(string.format("ð Auto Farming Target: Stage %d (%s Pad)\nProgress: Stage %d / %d\nStatus: Teleporting & waiting for spawn...", targetStage, State.StageCheckpointType or "FREE", currentStage, targetStage))
                        end
                    end)

                    safeTeleport(zonePos)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.8) -- Pacing delay: allow enemies to fully spawn
                    if not _G.VenomHubRunning or not State.AutoFarmStage then break end

                    pcall(function()
                        if StagePushStatusPara then
                            StagePushStatusPara:SetDesc(string.format("ð¥ Auto Farming Target: Stage %d (%s Pad)\nProgress: Stage %d / %d\nStatus: Engaging & clearing enemies...", targetStage, State.StageCheckpointType or "FREE", currentStage, targetStage))
                        end
                    end)

                    local success = clearStageEncounter(currentStage, hrp)
                    if not success then
                        pcall(function()
                            if StagePushStatusPara then
                                StagePushStatusPara:SetDesc(string.format("â ï¸ Stage %d not confirmed in WinReady! Aborting cycle & returning to Base...", currentStage))
                            end
                        end)
                        safeTeleport(basePos)
                        task.wait(2.0)
                        runFailed = true
                        break
                    end
                    task.wait(0.3)
                end

                -- ONLY claim WinPad at targetStage after full sequence startStage..targetStage completed AND targetStage confirmed in WinReady:
                if not runFailed and _G.VenomHubRunning and State.AutoFarmStage and isStageCleared(targetStage) then
                    pcall(function()
                        if StagePushStatusPara then
                            StagePushStatusPara:SetDesc(string.format("ð Target Stage %d Cleared!\nStatus: Claiming %s WinPad & returning to Base...", targetStage, State.StageCheckpointType or "FREE"))
                        end
                    end)

                    local pad = getStageWinPad(targetStage, State.StageCheckpointType or "FREE")
                    if pad then
                        local padPos = (typeof(pad) == "Instance" and pad.Position) or pad.Position
                        safeTeleport(padPos + Vector3.new(0, 2.2, 0))
                        hrp.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
                        task.wait(0.15)

                        -- Single safe touch
                        if typeof(pad) == "Instance" and firetouchinterest then
                            firetouchinterest(hrp, pad, 0)
                            task.wait(0.05)
                            firetouchinterest(hrp, pad, 1)
                        end

                        local claimStart = os.clock()
                        while _G.VenomHubRunning and State.AutoFarmStage and (os.clock() - claimStart) < 3.5 do
                            if (hrp.Position - basePos).Magnitude < 45 then break end
                            task.wait(0.1)
                        end
                        task.wait(1.5) -- Settle delay at Base before starting next cycle afresh at startStage
                    end
                end
            end)
        end
        task.wait(0.12)
    end
end)
table.insert(TeardownTrove, combatWorker)

-- Auto Cast Abilities Background Engine
local abilityWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.AutoCastAbilities and AbilityController and AbilityController.Press then
            pcall(function()
                for slot = 1, 4 do
                    AbilityController:Press(slot)
                end
            end)
        end
        task.wait(0.3)
    end
end)
table.insert(TeardownTrove, abilityWorker)

-- Skip Finishers Background Engine
local finisherWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.SkipFinishers and CombatController and CombatController.SkipFinisher then
            pcall(function()
                CombatController:SkipFinisher()
            end)
        end
        task.wait(0.15)
    end
end)
table.insert(TeardownTrove, finisherWorker)

-- God Mode & Absolute Invulnerability Background Engine
local godModeWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.GodMode then
            pcall(function()
                if EncounterController and (not EncounterController.UntouchableUntil or EncounterController.UntouchableUntil < os.clock() + 1000) then
                    EncounterController.UntouchableUntil = 999999999
                end
                if not ReplicatedStorage:GetAttribute("GodMode") then
                    ReplicatedStorage:SetAttribute("GodMode", true)
                end
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if hum.Health < hum.MaxHealth and hum.MaxHealth > 0 then
                            hum.Health = hum.MaxHealth
                        end
                        pcall(function()
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        end)
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)
table.insert(TeardownTrove, godModeWorker)

-- Automated Loot & World Drop Collector Engine (Non-Destructive Smooth Magnetizer)
local lootWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.AutoLootDrops then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local playerCFrame = root.CFrame
                local playerPos = root.Position

                -- 1. Sweep workspace.LootDrops folder directly (smooth pull & touch)
                local lootFolder = workspace:FindFirstChild("LootDrops")
                if lootFolder then
                    for _, drop in ipairs(lootFolder:GetChildren()) do
                        if drop:IsA("BasePart") then
                            drop.CFrame = drop.CFrame:Lerp(playerCFrame, 0.5)
                            if firetouchinterest then
                                pcall(firetouchinterest, root, drop, 0)
                                pcall(firetouchinterest, root, drop, 1)
                            end
                        end
                    end
                end

                -- 2. Sweep workspace for any dropped items, candies, tokens, or touch collectibles
                for _, obj in ipairs(workspace:GetChildren()) do
                    local n = string.lower(obj.Name)
                    if n == "drops" or n == "loot" or n == "candy" or n == "candies" or n == "tokens" or n == "items" then
                        for _, item in ipairs(obj:GetChildren()) do
                            if item:IsA("BasePart") then
                                item.CFrame = item.CFrame:Lerp(playerCFrame, 0.5)
                                if firetouchinterest then
                                    pcall(firetouchinterest, root, item, 0)
                                    pcall(firetouchinterest, root, item, 1)
                                end
                            end
                        end
                    end
                end

                -- 3. HalloweenTower Candies
                local hw = workspace:FindFirstChild("HalloweenTower")
                local hwShop = hw and hw:FindFirstChild("HalloweenShop")
                if hwShop then
                    for _, c in ipairs(hwShop:GetChildren()) do
                        if c.Name == "Candy" and c:IsA("BasePart") then
                            c.CFrame = c.CFrame:Lerp(playerCFrame, 0.5)
                            if firetouchinterest then
                                pcall(firetouchinterest, root, c, 0)
                                pcall(firetouchinterest, root, c, 1)
                            end
                        end
                    end
                end

                -- 4. Auto collect active nearby ProximityPrompts
                for _, prompt in ipairs(CollectionService:GetTagged("ProximityPrompt") or {}) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local parent = prompt.Parent
                        if parent and parent:IsA("BasePart") then
                            if (parent.Position - playerPos).Magnitude <= (prompt.MaxActivationDistance or 20) + 10 then
                                if fireproximityprompt then
                                    pcall(fireproximityprompt, prompt, 0)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.15)
    end
end)
table.insert(TeardownTrove, lootWorker)

-- ============================================================================
-- TAB 3: EVOLVE & FORMS
-- ============================================================================
TabEvolve:Section({ Title = "ð§¬ Autonomous Evolution" })

local EvolveStatusPara = TabEvolve:Paragraph({
    Title = "ð§¬ Evolution Requirements",
    Desc = "Calculating requirements..."
})

task.spawn(function()
    while _G.VenomHubRunning do
        pcall(function()
            local evols = DataController:Get("Evolutions") or 0
            local wins = DataController:Get("Wins") or 0
            local lvl = LocalPlayer:GetAttribute("Level") or 0
            local reqLvl = ProgressConfig.LevelToEvolve(evols)
            local reqWins = ProgressConfig.WinsToEvolve(evols)
            EvolveStatusPara:SetDesc(string.format(
                "Current Evolutions: %d | Level: %d/%d | Wins: %d/%d\nStatus: %s",
                evols, lvl, reqLvl, wins, reqWins,
                (lvl >= reqLvl and wins >= reqWins) and "READY TO EVOLVE!" or "Requirements not met"
            ))
        end)
        task.wait(2)
    end
end)

UIElements["AutoEvolve"] = TabEvolve:Toggle({
    Title = "ð§¬ Auto Evolve",
    Desc = "Automatically evolves character when Level and Wins criteria are fulfilled",
    Value = State.AutoEvolve,
    Callback = function(v) State.AutoEvolve = v end
})

TabEvolve:Button({
    Title = "â¡ Manual Evolve Now",
    Desc = "Triggers Evolve:InvokeServer() immediately",
    Callback = function()
        pcall(function()
            local ok, res = pcall(function()
                return NetFunctions.Evolve:InvokeServer()
            end)
            if ok and res then
                WindUI:Notify({ Title = "Evolution", Content = "Successfully Evolved!", Duration = 3 })
            else
                WindUI:Notify({ Title = "Evolution", Content = "Cannot evolve yet: check requirements", Duration = 3 })
            end
        end)
    end
})

TabEvolve:Section({ Title = "ð­ Form Vanity & Strain Selector" })

local StrainNames = {}
for i, s in ipairs(ProgressConfig.Strains) do
    table.insert(StrainNames, string.format("%d: %s", i - 1, s.name))
end

UIElements["SelectedFormLook"] = TabEvolve:Dropdown({
    Title = "ð­ Select Form Look",
    Desc = "Visual appearance for your symbiote",
    Values = StrainNames,
    Value = StrainNames[1],
    Callback = function(v)
        local idx = tonumber(v:match("(%d+):"))
        if idx then State.SelectedFormLook = idx end
    end
})

TabEvolve:Button({
    Title = "â¨ Apply Form Look",
    Desc = "Equips the chosen strain appearance",
    Callback = function()
        pcall(function()
            NetFunctions.Form:InvokeServer("Look", State.SelectedFormLook)
            WindUI:Notify({ Title = "Form", Content = "Applied form appearance!", Duration = 2 })
        end)
    end
})

-- AUTO EVOLVE WORKER
local evolveWorker = task.spawn(function()
    while _G.VenomHubRunning do
        if State.AutoEvolve then
            pcall(function()
                local evols = DataController:Get("Evolutions") or 0
                local wins = DataController:Get("Wins") or 0
                local lvl = LocalPlayer:GetAttribute("Level") or 0
                local reqLvl = ProgressConfig.LevelToEvolve(evols)
                local reqWins = ProgressConfig.WinsToEvolve(evols)
                if lvl >= reqLvl and wins >= reqWins then
                    local ok, res = pcall(function()
                        return NetFunctions.Evolve:InvokeServer()
                    end)
                    if ok and res then
                        WindUI:Notify({ Title = "Evolution", Content = "Auto Evolved to Tier " .. tostring(evols + 1) .. "!", Duration = 4 })
                    end
                end
            end)
        end
        task.wait(3.5)
    end
end)
table.insert(TeardownTrove, evolveWorker)

-- ============================================================================
-- TAB 4: REWARDS, POTIONS & PROMO CODES
-- ============================================================================
TabRewards:Section({ Title = "ð Automated Gift & Reward Claimer" })

UIElements["AutoClaimDaily"] = TabRewards:Toggle({
    Title = "ð Auto Claim Daily Rewards",
    Desc = "Claims Days 1-7 daily gifts as they become available",
    Value = State.AutoClaimDaily,
    Callback = function(v) State.AutoClaimDaily = v end
})

UIElements["AutoClaimPlaytime"] = TabRewards:Toggle({
    Title = "â±ï¸ Auto Claim Playtime Milestones",
    Desc = "Continuously checks and redeems unlocked playtime rewards (1-10)",
    Value = State.AutoClaimPlaytime,
    Callback = function(v) State.AutoClaimPlaytime = v end
})

UIElements["AutoClaimLeaving"] = TabRewards:Toggle({
    Title = "ðª Auto Claim Leaving Gift",
    Desc = "Redeems the offline/leaving reward from server",
    Value = State.AutoClaimLeaving,
    Callback = function(v) State.AutoClaimLeaving = v end
})

TabRewards:Section({ Title = "ð§ª Potion Auto-Consumer" })

UIElements["AutoUsePotions"] = TabRewards:Toggle({
    Title = "âï¸ Auto Use Potions from Bag",
    Desc = "Consumes 2x Venom or 2x Wins boost when active timer expires",
    Value = State.AutoUsePotions,
    Callback = function(v) State.AutoUsePotions = v end
})

UIElements["PotionType"] = TabRewards:Dropdown({
    Title = "ð§ª Potion Target",
    Desc = "Which boost to keep active",
    Values = { "Both", "Venom", "Wins" },
    Value = State.PotionType,
    Callback = function(v) State.PotionType = v end
})

TabRewards:Section({ Title = "ðï¸ Secret Promo Codes" })

UIElements["EnteredPromoCode"] = TabRewards:Input({
    Title = "Code Input",
    Desc = "Type promo code to redeem",
    Value = State.EnteredPromoCode,
    Placeholder = "e.g. RELEASE",
    Callback = function(v) State.EnteredPromoCode = v end
})

TabRewards:Button({
    Title = "ðï¸ Redeem Entered Code",
    Desc = "Submits code to RedeemCode:InvokeServer()",
    Callback = function()
        pcall(function()
            local code = State.EnteredPromoCode
            if code and #code > 0 then
                local ok, res = pcall(function()
                    return NetFunctions.RedeemCode:InvokeServer(code)
                end)
                WindUI:Notify({ Title = "Promo Code", Content = "Result: " .. tostring(res), Duration = 3 })
            end
        end)
    end
})

TabRewards:Button({
    Title = "â¡ Redeem All Known Codes",
    Desc = "Batch-submits active codes (RELEASE, etc.)",
    Callback = function()
        pcall(function()
            local knownCodes = { "RELEASE" }
            for _, c in ipairs(knownCodes) do
                pcall(function() NetFunctions.RedeemCode:InvokeServer(c) end)
                task.wait(0.2)
            end
            WindUI:Notify({ Title = "Promo Code", Content = "Redeemed all known codes!", Duration = 3 })
        end)
    end
})

-- REWARDS WORKER THREAD
local rewardsWorker = task.spawn(function()
    while _G.VenomHubRunning do
        pcall(function()
            if State.AutoClaimDaily then
                for day = 1, 7 do
                    pcall(function() NetFunctions.Rewards:InvokeServer("Daily", day) end)
                end
            end
            if State.AutoClaimPlaytime then
                for idx = 1, 10 do
                    pcall(function() NetFunctions.Rewards:InvokeServer("Playtime", idx) end)
                end
            end
            if State.AutoClaimLeaving then
                pcall(function() NetFunctions.LeavingReward:InvokeServer() end)
            end
            if State.AutoUsePotions then
                if State.PotionType == "Venom" or State.PotionType == "Both" then
                    pcall(function() NetFunctions.Rewards:InvokeServer("Use", "Venom") end)
                end
                if State.PotionType == "Wins" or State.PotionType == "Both" then
                    pcall(function() NetFunctions.Rewards:InvokeServer("Use", "Wins") end)
                end
            end
        end)
        task.wait(15)
    end
end)
table.insert(TeardownTrove, rewardsWorker)

-- ============================================================================
-- TAB 5: HALLOWEEN EVENT & TOWER
-- ============================================================================
TabHalloween:Section({ Title = "ð Halloween Tower & Candy Event" })

local CandyStatsPara = TabHalloween:Paragraph({
    Title = "ð¬ Candy & Tickets Status",
    Desc = "Fetching Candy & Tower data..."
})

task.spawn(function()
    while _G.VenomHubRunning do
        pcall(function()
            local c = DataController:Get("Candy") or 0
            local tb = DataController:Get("TowerBest") or 0
            local t = DataController:Get("Tickets")
            local ticketCount = t and t.Count or 0
            CandyStatsPara:SetDesc(string.format(
                "ð¬ Candy: %s | ðï¸ Tower Tickets: %d | ð° Highest Tower Floor: %d",
                tostring(c), ticketCount, tb
            ))
        end)
        task.wait(2)
    end
end)

UIElements["AutoEnterTower"] = TabHalloween:Toggle({
    Title = "ð° Auto Enter Halloween Tower",
    Desc = "Spends available tickets to enter the 50-Floor Tower automatically",
    Value = State.AutoEnterTower,
    Callback = function(v) State.AutoEnterTower = v end
})

UIElements["AutoClearTower"] = TabHalloween:Toggle({
    Title = "âï¸ Auto Clear Tower Floors",
    Desc = "Downs tower monsters and notifies server of cleared floor",
    Value = State.AutoClearTower,
    Callback = function(v) State.AutoClearTower = v end
})

UIElements["AutoCandyBuckets"] = TabHalloween:Toggle({
    Title = "ðª£ Auto Harvest Candy Buckets",
    Desc = "Detects spawned Candy Merchant buckets in the lobby and activates prompts",
    Value = State.AutoCandyBuckets,
    Callback = function(v) State.AutoCandyBuckets = v end
})

TabHalloween:Section({ Title = "ðï¸ Halloween Shop Automation" })

local HalloweenItems = {
    "ticket-1",
    "potion-venom",
    "potion-wins",
    "ghostfire",
    "witchfire",
    "hellfire",
    "halloween-venom",
}

UIElements["AutoBuyHalloween"] = TabHalloween:Toggle({
    Title = "ð Auto Buy Selected Item",
    Desc = "Purchases the chosen reward whenever candy is sufficient",
    Value = State.AutoBuyHalloween,
    Callback = function(v) State.AutoBuyHalloween = v end
})

UIElements["HalloweenBuyItem"] = TabHalloween:Dropdown({
    Title = "ð Item to Buy",
    Desc = "Choose item to auto-purchase",
    Values = HalloweenItems,
    Value = State.HalloweenBuyItem,
    Callback = function(v) State.HalloweenBuyItem = v end
})

-- HALLOWEEN WORKER (ENTER, FULL 50-FLOOR TOWER AUTO-CLEAR, BUCKETS & SHOP)
local halloweenWorker = task.spawn(function()
    while _G.VenomHubRunning do
        pcall(function()
            local inTower = LocalPlayer:GetAttribute("Tower") ~= nil
            local currentFloor = tonumber(LocalPlayer:GetAttribute("Tower")) or 1

            -- 1. Auto Enter Tower (Physical Portal Entry Requirement)
            if State.AutoEnterTower and not inTower then
                local t = DataController:Get("Tickets")
                local ticketCount = (type(t) == "table" and (t.Count or 0)) or 0
                if ticketCount > 0 then
                    local lobbyPortal = workspace:FindFirstChild("HalloweenTower") and workspace.HalloweenTower:FindFirstChild("LobbyPortal")
                    local entryZone = lobbyPortal and lobbyPortal:FindFirstChild("EntryZone")
                    local portalPos = (entryZone and entryZone.Position) or Vector3.new(11, 4, -240)
                    safeTeleport(portalPos)
                    task.wait(0.3)
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and entryZone then
                        firetouchinterest(hrp, entryZone, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, entryZone, 1)
                    end
                    task.wait(0.2)
                    NetEvents.Tower:FireServer("Enter")
                    task.wait(1.5)
                end
            end

            -- 2. Auto Clear Tower Floors
            if State.AutoClearTower and inTower then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Teleport to floor arrival/zone if needed
                    local floorY = (currentFloor - 1) * 56
                    local floorFolder = workspace:FindFirstChild("HalloweenTower") and workspace.HalloweenTower:FindFirstChild(TowerConfig.FolderName(currentFloor))
                    local arrival = floorFolder and floorFolder:FindFirstChild("Arrival")
                    local targetPos = (arrival and arrival.Position + Vector3.new(0, 3, 0)) or Vector3.new(-4000, floorY + 4, 0)

                    if (hrp.Position - targetPos).Magnitude > 50 then
                        safeTeleport(targetPos)
                        task.wait(0.3)
                    end

                    -- Kill all spawned monsters for this tower floor
                    local activeEnemies = EnemyController:All()
                    local killedAny = false
                    for _, enemy in ipairs(activeEnemies) do
                        local eFloor = enemy:GetAttribute("Tower")
                        local eDist = (enemy:GetPivot().Position - hrp.Position).Magnitude
                        if (eFloor == currentFloor or eDist < 90) and EnemyController:IsAlive(enemy) then
                            killedAny = true
                            NetEvents.Kill:FireServer(
                                "Quick",
                                enemy:GetAttribute("NPCCharacterId"),
                                eFloor or currentFloor,
                                enemy:GetAttribute("Bonus"),
                                0,
                                enemy:GetAttribute("EnemyId"),
                                "Bite",
                                1,
                                1
                            )
                            local hum = enemy:FindFirstChildOfClass("Humanoid")
                            if hum then hum.Health = 0 end
                        end
                    end

                    if not killedAny then
                        NetEvents.Attack:FireServer("Bite", nil, hrp.Position)
                    end

                    -- Check floor clear status
                    local floorState = EncounterController:StageState(1000 + currentFloor)
                    if floorState == "cleared" then
                        NetEvents.Tower:FireServer("Cleared", currentFloor, true)
                        task.wait(0.3)
                        -- Locate the physical FloorGate PortalField and touch it to enter the next floor
                        local towerFolder = workspace:FindFirstChild(TowerConfig.Folder or "HalloweenTower")
                        local fFolder = towerFolder and towerFolder:FindFirstChild(TowerConfig.FolderName(currentFloor))
                        local fGate = fFolder and fFolder:FindFirstChild("FloorGate")
                        local portal = fGate and fGate:FindFirstChild("PortalField")
                        if portal and portal:IsA("BasePart") then
                            safeTeleport(portal.CFrame)
                            pcall(function()
                                firetouchinterest(hrp, portal, 0)
                                task.wait(0.08)
                                firetouchinterest(hrp, portal, 1)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
            end

            -- 3. Auto Candy Buckets Harvesting
            if State.AutoCandyBuckets then
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local act = tostring(prompt.ActionText)
                        local obj = tostring(prompt.ObjectText)
                        local pName = prompt.Parent and prompt.Parent.Name or ""
                        if act:find("Candy") or obj:find("Candy") or pName:find("Bucket") then
                            local promptPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or prompt.Parent:GetPivot().Position
                            local savedPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
                            safeTeleport(promptPos)
                            task.wait(0.2)
                            pcall(fireproximityprompt, prompt, 0)
                            task.wait(0.2)
                            if savedPos and not inTower then
                                safeTeleport(savedPos)
                            end
                            break
                        end
                    end
                end
            end

            -- 4. Auto Buy Halloween Shop
            if State.AutoBuyHalloween and State.HalloweenBuyItem then
                local candy = DataController:Get("Candy") or 0
                if candy > 0 then
                    pcall(function()
                        NetFunctions.Halloween:InvokeServer("Buy", State.HalloweenBuyItem)
                    end)
                end
            end
        end)
        task.wait(0.35)
    end
end)
table.insert(TeardownTrove, halloweenWorker)

-- ============================================================================
-- TAB 6: OMNIPRESENT TELEPORTS
-- ============================================================================
TabTeleports:Section({ Title = "ðï¸ Lobby & Sound Chambers" })

local WaypointList = {}
for name in pairs(HubWaypoints) do
    table.insert(WaypointList, name)
end
table.sort(WaypointList)

local SelectedWaypoint = WaypointList[1]
TabTeleports:Dropdown({
    Title = "ð Select Lobby Destination",
    Desc = "Instant waypoint in Main Quarantine Lobby",
    Values = WaypointList,
    Value = SelectedWaypoint,
    Callback = function(v) SelectedWaypoint = v end
})

TabTeleports:Button({
    Title = "ð Teleport to Lobby Destination",
    Desc = "Instantly moves character to chosen waypoint",
    Callback = function()
        local pos = HubWaypoints[SelectedWaypoint]
        if pos then
            safeTeleport(pos)
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. SelectedWaypoint, Duration = 2 })
        end
    end
})

TabTeleports:Section({ Title = "ð World Fast Travel" })

for wNum = 1, 3 do
    local wNames = { "World 1: Quarantine Zone", "World 2: Alien Rift", "World 3: Cathedral & Grave" }
    TabTeleports:Button({
        Title = "ð Fast Travel to " .. wNames[wNum],
        Desc = "Invokes Net.Event('World'):FireServer('Travel', " .. wNum .. ")",
        Callback = function()
            pcall(function()
                NetEvents.World:FireServer("Travel", wNum)
                WindUI:Notify({ Title = "World Travel", Content = "Traveling to World " .. wNum .. "...", Duration = 3 })
            end)
        end
    })
end

TabTeleports:Section({ Title = "âï¸ Stage Arena Teleports (1-30)" })

local SelectedTeleportStage = 1
TabTeleports:Dropdown({
    Title = "ð¯ Select Stage Destination",
    Desc = "Target stage battleground",
    Values = StageDropdownList,
    Value = StageDropdownList[1],
    Callback = function(v)
        local num = tonumber(v:match("Stage (%d+):"))
        if num then SelectedTeleportStage = num end
    end
})

TabTeleports:Button({
    Title = "âï¸ Teleport to Stage Battle Arena",
    Desc = "Warps directly to Stage EnemyZone",
    Callback = function()
        local sInfo = StageData[SelectedTeleportStage]
        if sInfo and sInfo.pos then
            safeTeleport(sInfo.pos)
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. sInfo.name, Duration = 2 })
        end
    end
})

TabTeleports:Button({
    Title = "ð Teleport to Stage WinPad",
    Desc = "Warps directly onto the stage completion pad (Uses selected FREE or VIP pad)",
    Callback = function()
        if not isStageCleared(SelectedTeleportStage) then
            WindUI:Notify({ Title = "WinPad Warning", Content = string.format("Clear Stage %d first before touching WinPad!", SelectedTeleportStage), Duration = 3 })
            return
        end
        local pad = getStagePad(SelectedTeleportStage, State.StageCheckpointType == "VIP")
        if pad then
            safeTeleport(pad.CFrame + Vector3.new(0, 2.5, 0))
            WindUI:Notify({ Title = "Teleport", Content = string.format("Teleported to %s WinPad for Stage %d", State.StageCheckpointType or "FREE", SelectedTeleportStage), Duration = 2 })
        else
            local sInfo = StageData[SelectedTeleportStage]
            if sInfo and sInfo.winPad then
                safeTeleport(sInfo.winPad)
                WindUI:Notify({ Title = "Teleport", Content = "Teleported to WinPad for " .. sInfo.name, Duration = 2 })
            end
        end
    end
})

-- ============================================================================
-- TAB 7: MOVEMENT & QUALITY OF LIFE
-- ============================================================================
TabQoL:Section({ Title = "ð Physical Enhancements" })

UIElements["WalkSpeed"] = TabQoL:Slider({
    Title = "â¡ WalkSpeed Multiplier",
    Desc = "Adjust character base speed (16 = default)",
    Step = 1,
    Value = {
        Min = 16,
        Max = 250,
        Default = State.WalkSpeed,
    },
    Callback = function(v)
        State.WalkSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

UIElements["JumpPower"] = TabQoL:Slider({
    Title = "ð¦ JumpPower Boost",
    Desc = "Adjust character jump power (50 = default)",
    Step = 1,
    Value = {
        Min = 50,
        Max = 300,
        Default = State.JumpPower,
    },
    Callback = function(v)
        State.JumpPower = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end
})

UIElements["InfiniteJump"] = TabQoL:Toggle({
    Title = "ð¦ Infinite Jump",
    Desc = "Allows jumping mid-air indefinitely",
    Value = State.InfiniteJump,
    Callback = function(v) State.InfiniteJump = v end
})

local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(TeardownTrove, infJumpConn)

UIElements["Noclip"] = TabQoL:Toggle({
    Title = "ð» Noclip (Collision Pass-through)",
    Desc = "Disables wall collisions for your character",
    Value = State.Noclip,
    Callback = function(v) State.Noclip = v end
})

local noclipConn = RunService.Stepped:Connect(function()
    if State.Noclip then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)
table.insert(TeardownTrove, noclipConn)

UIElements["AntiAFK"] = TabQoL:Toggle({
    Title = "ð¡ï¸ Anti-AFK (20-Minute Disconnect Guard)",
    Desc = "Prevents Roblox 20-minute idle disconnects",
    Value = State.AntiAFK,
    Callback = function(v) State.AntiAFK = v end
})

local afkConn = LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)
table.insert(TeardownTrove, afkConn)

TabQoL:Section({ Title = "ð Performance & Graphics" })

TabQoL:Button({
    Title = "ð¥ Potato Graphics (FPS Booster)",
    Desc = "Disables shadows, decals, textures, and terrain decorations",
    Callback = function()
        pcall(function()
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
            WindUI:Notify({ Title = "Optimization", Content = "Potato Graphics Applied!", Duration = 2.5 })
        end)
    end
})

TabQoL:Section({ Title = "â¨ï¸ Interface Keybind" })

UIElements["UIKeybind"] = TabQoL:Keybind({
    Title = "UI Toggle Keybind",
    Desc = "Keyboard shortcut to toggle visibility of this window",
    Value = State.UIKeybind or "RightControl",
    Callback = function(key)
        State.UIKeybind = key
        pcall(function()
            local kc = Enum.KeyCode[key]
            if kc and Window.SetToggleKey then
                Window:SetToggleKey(kc)
            end
        end)
    end
})

-- ENFORCE HUMANOID VALUES (WalkSpeed & JumpPower)
local speedLoop = task.spawn(function()
    while _G.VenomHubRunning do
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if State.WalkSpeed ~= 16 and hum.WalkSpeed ~= State.WalkSpeed then
                    hum.WalkSpeed = State.WalkSpeed
                end
                if State.JumpPower ~= 50 then
                    hum.UseJumpPower = true
                    if hum.JumpPower ~= State.JumpPower then
                        hum.JumpPower = State.JumpPower
                    end
                end
            end
        end)
        task.wait(1)
    end
end)
table.insert(TeardownTrove, speedLoop)

-- ============================================================================
-- TAB 8: CONFIGURATION & PERSISTENCE
-- ============================================================================
TabConfigs:Section({ Title = "ð¾ Configuration Profiles" })

local ConfigDropdown = nil

UIElements["CurrentConfigName"] = TabConfigs:Input({
    Title = "Config Profile Name",
    Desc = "Name of profile for saving/loading",
    Value = State.CurrentConfigName,
    Placeholder = "e.g. default, farm_venom, rush_stages",
    Callback = function(v)
        if v and #v > 0 then State.CurrentConfigName = v end
    end
})

ConfigDropdown = TabConfigs:Dropdown({
    Title = "ð Select Configuration Profile",
    Desc = "Choose an existing profile to load or manage",
    Values = getSavedConfigs(),
    Value = State.CurrentConfigName,
    Callback = function(v)
        State.CurrentConfigName = v
        if UIElements["CurrentConfigName"] and type(UIElements["CurrentConfigName"].Set) == "function" then
            UIElements["CurrentConfigName"]:Set(v)
        end
    end
})

TabConfigs:Button({
    Title = "ð¾ Save Current Configuration",
    Desc = "Serializes and writes all toggles, sliders, and options to disk",
    Callback = function()
        pcall(function()
            if writefile then
                local path = CONFIG_DIR .. "/" .. State.CurrentConfigName .. ".json"
                local cleanState = {}
                for k, v in pairs(State) do
                    if typeof(v) == "boolean" or typeof(v) == "number" or typeof(v) == "string" then
                        cleanState[k] = v
                    end
                end
                writefile(path, HttpService:JSONEncode(cleanState))
                ConfigDropdown:Refresh(getSavedConfigs(), false)
                ConfigDropdown:Select(State.CurrentConfigName)
                WindUI:Notify({ Title = "Config Manager", Content = "Saved profile: " .. State.CurrentConfigName, Duration = 2.5 })
            else
                WindUI:Notify({ Title = "Config Manager", Content = "writefile not supported", Duration = 2.5 })
            end
        end)
    end
})

TabConfigs:Button({
    Title = "ð Load Selected Configuration",
    Desc = "Restores all saved values and dynamically updates every UI component",
    Callback = function()
        pcall(function()
            if readfile then
                local path = CONFIG_DIR .. "/" .. State.CurrentConfigName .. ".json"
                if isfile and not isfile(path) then
                    WindUI:Notify({ Title = "Config Manager", Content = "Profile not found: " .. State.CurrentConfigName, Duration = 2.5 })
                    return
                end
                local content = readfile(path)
                local loaded = HttpService:JSONDecode(content)
                if loaded and type(loaded) == "table" then
                    for k, v in pairs(loaded) do
                        State[k] = v
                        restoreUIComponent(k, v)
                    end
                    WindUI:Notify({
                        Title = "Config Manager",
                        Content = string.format("Restored profile '%s' with full visual UI synchronization!", State.CurrentConfigName),
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({ Title = "Config Manager", Content = "readfile not supported", Duration = 2.5 })
            end
        end)
    end
})

TabConfigs:Button({
    Title = "ð Refresh Profile List",
    Desc = "Scans disk for updated configuration files",
    Callback = function()
        ConfigDropdown:Refresh(getSavedConfigs(), false)
        WindUI:Notify({ Title = "Config Manager", Content = "Refreshed config files!", Duration = 2 })
    end
})

TabConfigs:Button({
    Title = "ðï¸ Delete Selected Profile",
    Desc = "Permanently deletes the selected configuration file",
    Callback = function()
        pcall(function()
            if State.CurrentConfigName == "default" then
                WindUI:Notify({ Title = "Config Manager", Content = "Cannot delete default profile", Duration = 2.5 })
                return
            end
            if delfile then
                local path = CONFIG_DIR .. "/" .. State.CurrentConfigName .. ".json"
                if isfile and isfile(path) then
                    delfile(path)
                    State.CurrentConfigName = "default"
                    ConfigDropdown:Refresh(getSavedConfigs(), false)
                    ConfigDropdown:Select("default")
                    if UIElements["CurrentConfigName"] and type(UIElements["CurrentConfigName"].Set) == "function" then
                        UIElements["CurrentConfigName"]:Set("default")
                    end
                    WindUI:Notify({ Title = "Config Manager", Content = "Deleted profile!", Duration = 2.5 })
                end
            end
        end)
    end
})

-- NOTIFY COMPLETION
WindUI:Notify({
    Title = "Tactical Hub Active",
    Content = "All automations initialized in OFF state. Ready for deployment!",
    Duration = 4
})
