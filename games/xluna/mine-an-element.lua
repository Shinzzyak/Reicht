-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    XLUNA HUB â MINE AN ELEMENT! [BETA]
    Author: By XLunaHUB
    Universal Protocol: Real MCP Architecture
    Framework: WindUI
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

local LocalPlayer = Players.LocalPlayer

-- Clean up any previous WindUI instances from CoreGui / RobloxGui / gethui
local function cleanPreviousWindUI()
    local hui = (gethui and gethui()) or game:GetService("CoreGui")
    pcall(function()
        for _, ch in ipairs(hui:GetChildren()) do
            if ch.Name:find("WindUI") then
                pcall(function() ch:Destroy() end)
            end
        end
    end)
    local rGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if rGui then
        pcall(function()
            for _, ch in ipairs(rGui:GetChildren()) do
                if ch.Name:find("WindUI") then
                    pcall(function() ch:Destroy() end)
                end
            end
        end)
    end
end
cleanPreviousWindUI()

-- Remotes & Network Topology
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local MineSwing = Remotes:WaitForChild("MineSwing")
local ChunkCollect = Remotes:WaitForChild("ChunkCollect")
local CrushRemote = Remotes:WaitForChild("Crush")
local BuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
local BuyPick = Remotes:WaitForChild("BuyPick")
local EquipPick = Remotes:WaitForChild("EquipPick")
local EquipBest = Remotes:WaitForChild("EquipBest")
local BuyEgg = Remotes:WaitForChild("BuyEgg")
local PickUpEgg = Remotes:WaitForChild("PickUpEgg")
local PlaceEgg = Remotes:WaitForChild("PlaceEgg")
local OpenEgg = Remotes:WaitForChild("OpenEgg")
local OpenHeld = Remotes:WaitForChild("OpenHeld")
local BuyNest = Remotes:WaitForChild("BuyNest")
local PokeGolem = Remotes:WaitForChild("PokeGolem")
local SkipTitle = Remotes:WaitForChild("SkipTitle")
local ClaimDaily = Remotes:WaitForChild("ClaimDaily")
local OpenPlayGift = Remotes:WaitForChild("OpenPlayGift")
local CollectMat = Remotes:WaitForChild("CollectMat")
local BonkMole = Remotes:WaitForChild("BonkMole")
local SetAutoMine = Remotes:WaitForChild("SetAutoMine")
local GoHome = Remotes:WaitForChild("GoHome")
local GoQuarry = Remotes:WaitForChild("GoQuarry")
local GoArea = Remotes:WaitForChild("GoArea")

-- Client Modules
local MineController = require(LocalPlayer.PlayerScripts.Client.MineController)
local RockCore = require(ReplicatedStorage.Shared.RockCore)
local PlayerState = require(LocalPlayer.PlayerScripts.Client.PlayerState)
local WorldLayout = require(ReplicatedStorage.Shared.WorldLayout)
local BaseLayout = require(ReplicatedStorage.Shared.BaseLayout)
local EggCore = require(ReplicatedStorage.Shared.EggCore)
local FightClient = require(LocalPlayer.PlayerScripts.Client.FightClient)

-- Internal MineController Upvalue Bindings
local mcSwingUps = debug.getupvalues(MineController.swing)
local MineFx = mcSwingUps and mcSwingUps[11] and mcSwingUps[11].MineFx

-- World Marker Positions
local LOCATIONS = {
    QuarryPad = Vector3.new(14, 4.726, -44),
    LavaPad = Vector3.new(172, 3.5, -30),
    LagoonPad = Vector3.new(-248, 3.5, -90),
    SkyPad = Vector3.new(-200, 243.6, -750),
    SkyPad2 = Vector3.new(-5, 273.6, -884),
    PickForge = Vector3.new(53.5, 7.2, 29.1),
    EggStand = Vector3.new(-2, 7, 45),
    GiftChest = Vector3.new(-29, 3.5, -24),
    HomeMat = Vector3.new(64, 9.6, 67),
    QuarrySpawn = Vector3.new(14, 4.726, -44),
    LavaSpawn = Vector3.new(158, 3.58, -44),
    LagoonSpawn = Vector3.new(-240, 3.58, -44),
    SkySpawn = Vector3.new(-165, 243.5, -700),
    CobbleGolem = Vector3.new(-33, 4.5, -164),
    CinderGolem = Vector3.new(301, 5, -211),
    TideGolem = Vector3.new(-453, 5, -128),
    GaleGolem = Vector3.new(195, 274, -785)
}

-- Boss Arenas Configuration
local BOSS_DATA = {
    ["Cobble Golem (Quarry)"] = {
        area = "quarry",
        pos = LOCATIONS.CobbleGolem,
        floor = 0.2,
        name = "Cobble Golem"
    },
    ["Cinder Golem (Lava)"] = {
        area = "lava",
        pos = LOCATIONS.CinderGolem,
        floor = 0.2,
        name = "Cinder Golem"
    },
    ["Tide Golem (Waterfall)"] = {
        area = "lagoon",
        pos = LOCATIONS.TideGolem,
        floor = 0.2,
        name = "Tide Golem"
    },
    ["Gale Golem (Sky)"] = {
        area = "sky",
        pos = LOCATIONS.GaleGolem,
        floor = 270,
        name = "Gale Golem"
    }
}

-- Boss Combat & Active State Classifier
local ACTIVE_BOSS_STATES = {
    rumble = true,
    waiting = true,
    title = true,
    step1 = true,
    step2 = true,
    step3 = true,
    dizzy = true,
    napping = true
}

local function getBossStatus(bossArea)
    local state = nil
    if FightClient then
        pcall(function()
            state = FightClient.stateOf(bossArea)
            if FightClient.area() == bossArea then
                local cur = FightClient.state()
                if cur then state = cur end
            end
        end)
    end

    local pState = PlayerState.get()
    local rocksLeft = nil
    if pState and pState.mined and pState.mined[bossArea] then
        local m = pState.mined[bossArea]
        if m.total and m.mined and m.total > 0 then
            rocksLeft = math.max(0, m.total - m.mined)
        end
    end

    local isActive = false
    if state and ACTIVE_BOSS_STATES[state] then
        isActive = true
    end

    return {
        state = state or "asleep",
        isActive = isActive,
        rocksLeft = rocksLeft,
        canWake = (rocksLeft == 0 and state == "asleep")
    }
end

-- Map / Biome Filtering
local MAP_NAMES = {
    ["Current Area"] = nil,
    ["Quarry (Pebble)"] = "quarry",
    ["Lava (Canyon)"] = "lava",
    ["Lagoon (Waterfall)"] = "lagoon",
    ["Sky (Cliffs)"] = "sky"
}

-- Pedestal Mapping
local EggPedestals = {
    ["Fire Egg (1.5k)"] = "fire_1",
    ["Water Egg (1.5k)"] = "water_1",
    ["Air Egg (1.5k)"] = "air_1",
    ["Canyon Egg (15k)"] = "fire_2",
    ["Lagoon Egg (150k)"] = "water_3",
    ["Sky Cliffs Egg (1.5M)"] = "air_4",
    ["Gem Egg"] = "gem",
    ["Rex Nest Egg"] = "lava_nest",
    ["Nessie Nest Egg"] = "lagoon_nest",
    ["Dragon Nest Egg"] = "sky"
}

-- Master State Configuration (ALL OFF by default)
local Config = {
    -- Mining
    AutoMine = false,
    AutoClickMine = false,
    ClickSpeed = 0.1,
    MiningMap = "Current Area",
    AutoTravelMap = false,
    MineBurst = 2,
    MineDistance = 7,
    TargetMode = "Closest", -- "Closest", "Lowest HP", "Highest HP"
    RockFilter = "All", -- "All", "Small Only", "Big Only", "Giant Only"
    AutoTeleportToRock = false,
    AutoCollectChunks = false,
    AutoCrush = false,
    CrushPercent = 100,

    -- Eggs & Pets
    AutoBuyEgg = false,
    SelectedEgg = "Fire Egg (1.5k)",
    EggAmount = 1,
    AutoOpenHeld = false,
    AutoTapEgg = false,
    AutoPlaceEgg = false,
    AutoOpenEgg = false,
    AutoEquipBest = false,

    -- Upgrades
    AutoAllUpgrades = false,
    AutoBackpack = false,
    AutoPickPower = false,
    AutoSwingSpeed = false,
    AutoWalkSpeed = false,
    AutoReach = false,
    AutoCrusherSpeed = false,
    AutoBuyPick = false,

    -- Boss / Golem
    SelectedBoss = "Cobble Golem (Quarry)",
    AutoGolem = false,
    GolemFloat = true,

    -- Free Rewards
    AutoDaily = false,
    AutoPlayGifts = false,
    AutoBaseMat = false,
    AutoBonkMoles = false,
    AutoMinePerk = false,

    -- Player Mods
    WalkSpeed = 16,
    ModifyWalkSpeed = false,
    JumpPower = 50,
    ModifyJumpPower = false,
    InfJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    Fullbright = false,
    AntiAfk = true
}

local CONFIG_FILE = "XLuna_MineAnElement/config.json"
local Running = true
local isCrushingActive = false
local isBossCombatActive = false
local isEggActionActive = false
local currentTargetRock = nil
local activeConnections = {}

-- Clean Teardown Callback
_G.XLUNA_UNLOAD = function()
    Running = false
    isCrushingActive = false
    isBossCombatActive = false
    isEggActionActive = false
    for _, conn in ipairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    activeConnections = {}
    -- MineFx target cleanup bypassed to prevent thread capability drop
    cleanPreviousWindUI()
end

-- Anti-AFK Routine (Dual-layer: Event-driven + 5-minute Keepalive Pulse)
local antiAfkConn = LocalPlayer.Idled:Connect(function()
    if Config.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)
table.insert(activeConnections, antiAfkConn)

task.spawn(function()
    while Running do
        task.wait(300) -- Keepalive pulse every 5 minutes
        if Config.AntiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(10, 10))
            end)
        end
    end
end)

-- Character Helpers
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Load WindUI Framework
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Master Window
local Window = WindUI:CreateWindow({
    Title = "XLuna Hub â Mine an Element!",
    Icon = "pickaxe",
    Author = "By XLunaHUB",
    Folder = "XLuna_MineAnElement",
    Size = UDim2.fromOffset(620, 490),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLuna Hub",
        Icon = "pickaxe",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("3b82f6"),
            Color3.fromHex("8b5cf6")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

-- =========================================================================
-- TABS INITIALIZATION
-- =========================================================================
local TabMining = Window:Tab({ Title = "Mining", Icon = "pickaxe" })
local TabPets = Window:Tab({ Title = "Eggs & Pets", Icon = "egg" })
local TabUpgrades = Window:Tab({ Title = "Upgrades & Forge", Icon = "hammer" })
local TabGolem = Window:Tab({ Title = "Boss / Golem", Icon = "swords" })
local TabRewards = Window:Tab({ Title = "Free Rewards", Icon = "gift" })
local TabTeleports = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
local TabVisuals = Window:Tab({ Title = "Player & Mods", Icon = "user" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- =========================================================================
-- TAB 1: MINING
-- =========================================================================
local SectionMining = TabMining:Section({ Title = "Core Mining Engine", Icon = "pickaxe" })

SectionMining:Dropdown({
    Title = "Mining Map / Area",
    Desc = "Target rocks exclusively in selected map/biome",
    Values = { "Current Area", "Quarry (Pebble)", "Lava (Canyon)", "Lagoon (Waterfall)", "Sky (Cliffs)" },
    Value = "Current Area",
    Callback = function(val)
        Config.MiningMap = val
        if Config.AutoTravelMap and val ~= "Current Area" then
            local mapId = MAP_NAMES[val]
            if mapId then
                GoArea:FireServer(mapId)
            end
        end
    end
})

SectionMining:Toggle({
    Title = "Auto Travel to Map",
    Desc = "Automatically travels to selected mining map when enabled",
    Value = false,
    Callback = function(val)
        Config.AutoTravelMap = val
        if val and Config.MiningMap ~= "Current Area" then
            local mapId = MAP_NAMES[Config.MiningMap]
            if mapId then
                GoArea:FireServer(mapId)
            end
        end
    end
})

SectionMining:Toggle({
    Title = "Auto Mine Rocks",
    Desc = "Target and break rocks continuously with server range validation",
    Value = false,
    Callback = function(val)
        Config.AutoMine = val
        if not val and MineFx and MineFx.setTarget then
            pcall(function() MineFx.setTarget(nil) end)
        end
    end
})

SectionMining:Toggle({
    Title = "Auto Click Mine (Fast Clicker)",
    Desc = "Rapid auto-clicker for manual or aimed mining targets",
    Value = false,
    Callback = function(val)
        Config.AutoClickMine = val
    end
})

SectionMining:Slider({
    Title = "Clicker Delay (Seconds)",
    Desc = "Interval between automated pickaxe click strikes",
    Step = 0.05,
    Value = {
        Min = 0.05,
        Max = 0.5,
        Default = 0.1
    },
    Callback = function(val)
        Config.ClickSpeed = val
    end
})

SectionMining:Toggle({
    Title = "Auto Teleport to Rock",
    Desc = "Aligns character within valid swing radius (3.2 studs)",
    Value = false,
    Callback = function(val)
        Config.AutoTeleportToRock = val
    end
})

SectionMining:Dropdown({
    Title = "Target Mode",
    Desc = "Algorithm used to evaluate and prioritize open rock targets",
    Values = { "Closest", "Lowest HP", "Highest HP" },
    Value = "Closest",
    Callback = function(val)
        Config.TargetMode = val
    end
})

SectionMining:Dropdown({
    Title = "Rock Size Filter",
    Desc = "Filter targeted rocks by dimension size",
    Values = { "All", "Small Only", "Big Only", "Giant Only" },
    Value = "All",
    Callback = function(val)
        Config.RockFilter = val
    end
})

SectionMining:Slider({
    Title = "Mine Burst Rate",
    Desc = "Network swing packets dispatched per swing cycle",
    Step = 1,
    Value = {
        Min = 1,
        Max = 4,
        Default = 2
    },
    Callback = function(val)
        Config.MineBurst = val
    end
})

local SectionChunks = TabMining:Section({ Title = "Chunk Collection & Crusher", Icon = "boxes" })

SectionChunks:Toggle({
    Title = "Auto Collect Chunks (Vacuum)",
    Desc = "Vacuums ground chunks within reach (<= 10 studs) with zero packet waste",
    Value = false,
    Callback = function(val)
        Config.AutoCollectChunks = val
    end
})

SectionChunks:Toggle({
    Title = "Auto Crush Carried Chunks",
    Desc = "Travels to crusher pad, streams all chunks into ore, and resumes mining",
    Value = false,
    Callback = function(val)
        Config.AutoCrush = val
    end
})

SectionChunks:Slider({
    Title = "Crush Capacity Threshold (%)",
    Desc = "Backpack fill percentage that triggers automated crusher cycle",
    Step = 5,
    Value = {
        Min = 10,
        Max = 100,
        Default = 100
    },
    Callback = function(val)
        Config.CrushPercent = val
    end
})

-- =========================================================================
-- TAB 2: EGGS & PETS
-- =========================================================================
local SectionEggs = TabPets:Section({ Title = "Hatching Automation", Icon = "egg" })

SectionEggs:Dropdown({
    Title = "Select Egg Pedestal",
    Desc = "Egg pedestal type to purchase",
    Values = {
        "Fire Egg (1.5k)",
        "Water Egg (1.5k)",
        "Air Egg (1.5k)",
        "Canyon Egg (15k)",
        "Lagoon Egg (150k)",
        "Sky Cliffs Egg (1.5M)",
        "Gem Egg",
        "Rex Nest Egg",
        "Nessie Nest Egg",
        "Dragon Nest Egg"
    },
    Value = "Fire Egg (1.5k)",
    Callback = function(val)
        Config.SelectedEgg = val
    end
})

SectionEggs:Slider({
    Title = "Hatch Quantity",
    Desc = "Eggs purchased per transaction",
    Step = 1,
    Value = {
        Min = 1,
        Max = 8,
        Default = 1
    },
    Callback = function(val)
        Config.EggAmount = val
    end
})

SectionEggs:Toggle({
    Title = "Auto Buy Selected Egg",
    Desc = "Purchases eggs while positioned near the egg stand",
    Value = false,
    Callback = function(val)
        Config.AutoBuyEgg = val
    end
})

SectionEggs:Toggle({
    Title = "Fast Open Held Egg",
    Desc = "Instantly skips opening cutscene animations",
    Value = false,
    Callback = function(val)
        Config.AutoOpenHeld = val
    end
})

SectionEggs:Toggle({
    Title = "Auto Tap Egg (Fast Unbox)",
    Desc = "Rapidly cracks and skips egg hatching cutscenes (<0.3s)",
    Value = false,
    Callback = function(val)
        Config.AutoTapEgg = val
    end
})

SectionEggs:Toggle({
    Title = "Auto Place Eggs onto Nests",
    Desc = "Transports and nests unhatched gate/carried eggs onto open incubator pads",
    Value = false,
    Callback = function(val)
        Config.AutoPlaceEgg = val
    end
})

SectionEggs:Toggle({
    Title = "Auto Open Ready Eggs",
    Desc = "Detects completed incubation on nest pads and hatches pets automatically",
    Value = false,
    Callback = function(val)
        Config.AutoOpenEgg = val
    end
})

SectionEggs:Button({
    Title = "Nests: Place Available Eggs Now",
    Desc = "Immediately transports and nests pending gate eggs",
    Callback = function()
        task.spawn(function()
            local state = PlayerState.get()
            local root = getRoot()
            local plotAttr = LocalPlayer:GetAttribute("Plot")
            local plot = plotAttr and BaseLayout.plot(plotAttr)
            if not state or not root or not plot or not plot.pads then return end

            local maxPads = (state.nests and state.nests.pads) or 2
            local occupiedPads = {}
            for _, egg in ipairs(state.eggs or {}) do
                if egg.place == "pad" and egg.pad then occupiedPads[egg.pad] = true end
            end

            local placedCount = 0
            for _, egg in ipairs(state.eggs or {}) do
                if egg.place == "gate" or egg.place == "carry" then
                    local emptyPad = nil
                    for p = 1, maxPads do
                        if not occupiedPads[p] then
                            emptyPad = p
                            break
                        end
                    end

                    if emptyPad then
                        local padData = plot.pads[emptyPad]
                        if egg.place == "gate" then
                            local eggsFolder = workspace:FindFirstChild("Eggs")
                            local myFolder = eggsFolder and eggsFolder:FindFirstChild(tostring(LocalPlayer.UserId))
                            local eggModel = myFolder and (myFolder:FindFirstChild("Egg_" .. egg.uid) or myFolder:FindFirstChild(tostring(egg.uid)))
                            local eggPos = eggModel and eggModel:IsA("Model") and eggModel.PrimaryPart and eggModel.PrimaryPart.Position
                            if eggPos then
                                root.CFrame = CFrame.new(eggPos.X, eggPos.Y + 1.5, eggPos.Z)
                                task.wait(0.25)
                                PickUpEgg:FireServer(egg.uid)
                                task.wait(0.35)
                            end
                        end

                        if padData and padData.position then
                            root.CFrame = CFrame.new(padData.position.x, padData.position.y + 0.2, padData.position.z)
                            task.wait(0.25)
                            PlaceEgg:FireServer(emptyPad)
                            task.wait(0.35)
                            occupiedPads[emptyPad] = true
                            placedCount = placedCount + 1
                        end
                    end
                end
            end

            WindUI:Notify({
                Title = "Eggs Placed",
                Content = ("Placed %d egg(s) onto nests!"):format(placedCount),
                Duration = 2
            })
        end)
    end
})

SectionEggs:Button({
    Title = "Nests: Open Ready Eggs Now",
    Desc = "Immediately hatches all completed nest eggs",
    Callback = function()
        task.spawn(function()
            local state = PlayerState.get()
            local root = getRoot()
            local plotAttr = LocalPlayer:GetAttribute("Plot")
            local plot = plotAttr and BaseLayout.plot(plotAttr)
            if not state or not root or not plot or not plot.pads then return end

            local now = workspace:GetServerTimeNow()
            local openedCount = 0
            for _, egg in ipairs(state.eggs or {}) do
                if egg.place == "pad" and egg.pad and egg.readyAt and (now >= egg.readyAt) then
                    local padData = plot.pads[egg.pad]
                    if padData and padData.position then
                        root.CFrame = CFrame.new(padData.position.x, padData.position.y + 0.2, padData.position.z)
                        task.wait(0.25)
                        OpenEgg:FireServer(egg.pad)
                        task.wait(0.4)
                        openedCount = openedCount + 1
                    end
                end
            end

            WindUI:Notify({
                Title = "Eggs Opened",
                Content = ("Hatched %d ready nest egg(s)!"):format(openedCount),
                Duration = 2
            })
        end)
    end
})

local SectionPetTeam = TabPets:Section({ Title = "Team Optimization", Icon = "users" })

SectionPetTeam:Toggle({
    Title = "Auto Equip Best Team",
    Desc = "Continuously equips the highest multiplier pet roster",
    Value = false,
    Callback = function(val)
        Config.AutoEquipBest = val
    end
})

SectionPetTeam:Button({
    Title = "Equip Best Team Now",
    Desc = "Immediately equips top 3 highest damage pets",
    Callback = function()
        EquipBest:FireServer(nil)
        WindUI:Notify({
            Title = "Pets Equipped",
            Content = "Best damage team equipped!",
            Duration = 2
        })
    end
})

-- =========================================================================
-- TAB 3: UPGRADES & FORGE
-- =========================================================================
local SectionUpgrades = TabUpgrades:Section({ Title = "Passive Upgrades", Icon = "arrow-up-circle" })

SectionUpgrades:Toggle({
    Title = "Auto Buy ALL Upgrades",
    Desc = "Purchases all available tier upgrades in rotation",
    Value = false,
    Callback = function(val)
        Config.AutoAllUpgrades = val
    end
})

SectionUpgrades:Toggle({
    Title = "Auto Upgrade Backpack",
    Desc = "Upgrades chunk storage capacity",
    Value = false,
    Callback = function(val)
        Config.AutoBackpack = val
    end
})

SectionUpgrades:Toggle({
    Title = "Auto Upgrade Pickaxe Power",
    Desc = "Upgrades base rock hit damage",
    Value = false,
    Callback = function(val)
        Config.AutoPickPower = val
    end
})

SectionUpgrades:Toggle({
    Title = "Auto Upgrade Swing Speed",
    Desc = "Reduces delay between consecutive pickaxe strikes",
    Value = false,
    Callback = function(val)
        Config.AutoSwingSpeed = val
    end
})

SectionUpgrades:Toggle({
    Title = "Auto Upgrade WalkSpeed",
    Desc = "Increases character base movement velocity",
    Value = false,
    Callback = function(val)
        Config.AutoWalkSpeed = val
    end
})

SectionUpgrades:Toggle({
    Title = "Auto Upgrade Reach",
    Desc = "Expands strike and pickup radius",
    Value = false,
    Callback = function(val)
        Config.AutoReach = val
    end
})

SectionUpgrades:Toggle({
    Title = "Auto Upgrade Crusher Speed",
    Desc = "Accelerates chunk conversion speed at the crusher",
    Value = false,
    Callback = function(val)
        Config.AutoCrusherSpeed = val
    end
})

local SectionForge = TabUpgrades:Section({ Title = "Pickaxe Forge", Icon = "anvil" })

SectionForge:Toggle({
    Title = "Auto Buy Next Tier Pickaxe",
    Desc = "Buys next pickaxe when standing at Pick Forge",
    Value = false,
    Callback = function(val)
        Config.AutoBuyPick = val
    end
})

SectionForge:Button({
    Title = "Warp to Pick Forge & Buy Pickaxe",
    Desc = "Warps to Forge, buys next pickaxe, and returns",
    Callback = function()
        task.spawn(function()
            local root = getRoot()
            if not root then return end
            local saved = root.CFrame
            root.CFrame = CFrame.new(LOCATIONS.PickForge)
            task.wait(0.3)
            local state = PlayerState.get()
            local pickPicks = { "wooden", "stone", "copper", "iron", "crystal", "coral", "pearl", "cloud", "gale" }
            if state and state.pickTier then
                local nextPick = pickPicks[state.pickTier + 1]
                if nextPick then
                    BuyPick:FireServer(nextPick)
                end
            end
            task.wait(0.3)
            root.CFrame = saved
            WindUI:Notify({
                Title = "Pickaxe Purchase",
                Content = "Attempted purchase at Pick Forge!",
                Duration = 2
            })
        end)
    end
})

-- =========================================================================
-- TAB 4: BOSS / GOLEM
-- =========================================================================
local SectionGolem = TabGolem:Section({ Title = "Golem Arena Automation", Icon = "swords" })

local GolemStatusParagraph = SectionGolem:Paragraph({
    Title = "Status: Cobble Golem",
    Desc = "Inspecting arena state..."
})

SectionGolem:Dropdown({
    Title = "Select Boss / Golem",
    Desc = "Target boss arena to monitor & fight",
    Values = {
        "Cobble Golem (Quarry)",
        "Cinder Golem (Lava)",
        "Tide Golem (Waterfall)",
        "Gale Golem (Sky)"
    },
    Value = "Cobble Golem (Quarry)",
    Callback = function(val)
        Config.SelectedBoss = val
        local boss = BOSS_DATA[val]
        if boss and GolemStatusParagraph then
            local st = getBossStatus(boss.area)
            local info = ""
            if st.isActive then
                info = "ACTIVE! In combat / waking (" .. tostring(st.state) .. ")"
            elseif st.canWake then
                info = "READY TO WAKE! (0 rocks left to mine)"
            elseif st.rocksLeft then
                info = "Asleep (" .. tostring(st.rocksLeft) .. " more rocks needed to wake)"
            else
                info = "Status: " .. tostring(st.state)
            end
            pcall(function()
                GolemStatusParagraph:SetTitle("Status: " .. boss.name)
                GolemStatusParagraph:SetDesc(info)
            end)
        end
    end
})

SectionGolem:Toggle({
    Title = "Auto Fight Selected Boss",
    Desc = "Only engages when boss actually wakes up/spawns (never interrupts active mining)",
    Value = false,
    Callback = function(val)
        Config.AutoGolem = val
        if not val then
            isBossCombatActive = false
        end
    end
})

SectionGolem:Toggle({
    Title = "Safe Floating Stance (Anti-Stomp)",
    Desc = "Suspends character 12 studs above arena floor to evade melee damage",
    Value = true,
    Callback = function(val)
        Config.GolemFloat = val
    end
})

SectionGolem:Button({
    Title = "Fight Cobble Golem (Quarry)",
    Desc = "Warps to Quarry and initiates Cobble Golem fight",
    Callback = function()
        task.spawn(function()
            isBossCombatActive = true
            GoArea:FireServer("quarry")
            task.wait(0.3)
            local root = getRoot()
            if root then root.CFrame = CFrame.new(LOCATIONS.CobbleGolem) end
            task.wait(0.2)
            PokeGolem:FireServer()
            SkipTitle:FireServer()
        end)
    end
})

SectionGolem:Button({
    Title = "Fight Cinder Golem (Lava)",
    Desc = "Warps to Lava Canyon and initiates Cinder Golem fight",
    Callback = function()
        task.spawn(function()
            isBossCombatActive = true
            GoArea:FireServer("lava")
            task.wait(0.3)
            local root = getRoot()
            if root then root.CFrame = CFrame.new(LOCATIONS.CinderGolem) end
            task.wait(0.2)
            PokeGolem:FireServer()
            SkipTitle:FireServer()
        end)
    end
})

SectionGolem:Button({
    Title = "Fight Tide Golem (Waterfall)",
    Desc = "Warps to Waterfall Lagoon and initiates Tide Golem fight",
    Callback = function()
        task.spawn(function()
            isBossCombatActive = true
            GoArea:FireServer("lagoon")
            task.wait(0.3)
            local root = getRoot()
            if root then root.CFrame = CFrame.new(LOCATIONS.TideGolem) end
            task.wait(0.2)
            PokeGolem:FireServer()
            SkipTitle:FireServer()
        end)
    end
})

SectionGolem:Button({
    Title = "Fight Gale Golem (Sky)",
    Desc = "Warps to Sky Cliffs and initiates Gale Golem fight",
    Callback = function()
        task.spawn(function()
            isBossCombatActive = true
            GoArea:FireServer("sky")
            task.wait(0.3)
            local root = getRoot()
            if root then root.CFrame = CFrame.new(LOCATIONS.GaleGolem) end
            task.wait(0.2)
            PokeGolem:FireServer()
            SkipTitle:FireServer()
        end)
    end
})

-- =========================================================================
-- TAB 5: FREE REWARDS
-- =========================================================================
local SectionRewards = TabRewards:Section({ Title = "Automated Free Rewards", Icon = "gift" })

SectionRewards:Toggle({
    Title = "Auto Claim Daily Reward Chest",
    Desc = "Detects ready status, visits Gift Chest (-29, 3.5, -24), and claims reward",
    Value = false,
    Callback = function(val)
        Config.AutoDaily = val
    end
})

SectionRewards:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Loops through milestone playtime gifts (1-12)",
    Value = false,
    Callback = function(val)
        Config.AutoPlayGifts = val
    end
})

SectionRewards:Toggle({
    Title = "Auto Collect Base Generator (Welcome Mat)",
    Desc = "Collects accumulated offline ore from Home base mat",
    Value = false,
    Callback = function(val)
        Config.AutoBaseMat = val
    end
})

SectionRewards:Toggle({
    Title = "Auto Bonk Moles",
    Desc = "Strikes bonus reward moles immediately upon spawning",
    Value = false,
    Callback = function(val)
        Config.AutoBonkMoles = val
    end
})

SectionRewards:Toggle({
    Title = "Force Official Auto-Mine Perk",
    Desc = "Enables built-in server auto-mine state",
    Value = false,
    Callback = function(val)
        Config.AutoMinePerk = val
        SetAutoMine:FireServer(val)
    end
})

-- =========================================================================
-- TAB 6: TELEPORTS & FAST TRAVEL
-- =========================================================================
local SectionWarps = TabTeleports:Section({ Title = "World Landmarks", Icon = "map-pin" })

SectionWarps:Button({
    Title = "Travel: Quarry Spawn",
    Desc = "Instant warp to Quarry entry point",
    Callback = function()
        GoQuarry:FireServer()
    end
})

SectionWarps:Button({
    Title = "Travel: Home Base",
    Desc = "Instant warp to player home plot",
    Callback = function()
        GoHome:FireServer()
    end
})

SectionWarps:Button({
    Title = "Travel: Lava Canyon",
    Desc = "Instant warp to Lava Canyon",
    Callback = function()
        GoArea:FireServer("lava")
    end
})

SectionWarps:Button({
    Title = "Travel: Waterfall Lagoon",
    Desc = "Instant warp to Waterfall Lagoon",
    Callback = function()
        GoArea:FireServer("lagoon")
    end
})

SectionWarps:Button({
    Title = "Travel: Sky Cliffs",
    Desc = "Instant warp to Sky Cliffs",
    Callback = function()
        GoArea:FireServer("sky")
    end
})

SectionWarps:Button({
    Title = "Warp: Crusher Drop Pad (Quarry)",
    Desc = "Teleports character onto the Quarry crusher pad",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(LOCATIONS.QuarryPad)
        end
    end
})

SectionWarps:Button({
    Title = "Warp: Crusher Drop Pad (Lava)",
    Desc = "Teleports character onto the Lava crusher pad",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(LOCATIONS.LavaPad)
        end
    end
})

SectionWarps:Button({
    Title = "Warp: Crusher Drop Pad (Lagoon)",
    Desc = "Teleports character onto the Lagoon crusher pad",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(LOCATIONS.LagoonPad)
        end
    end
})

SectionWarps:Button({
    Title = "Warp: Egg Stand",
    Desc = "Teleports character to the central Egg Stand",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(LOCATIONS.EggStand)
        end
    end
})

SectionWarps:Button({
    Title = "Warp: Pick Forge",
    Desc = "Teleports character to Pickaxe Forge stand",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(LOCATIONS.PickForge)
        end
    end
})

SectionWarps:Button({
    Title = "Warp: Daily Gift Chest",
    Desc = "Teleports character to Daily Reward chest",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(LOCATIONS.GiftChest)
        end
    end
})

-- =========================================================================
-- TAB 7: PLAYER MODS & VISUALS
-- =========================================================================
local SectionPlayer = TabVisuals:Section({ Title = "Character Physics Modifiers", Icon = "user" })

SectionPlayer:Toggle({
    Title = "Modify WalkSpeed",
    Desc = "Enforces custom movement speed",
    Value = false,
    Callback = function(val)
        Config.ModifyWalkSpeed = val
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = val and Config.WalkSpeed or 16
        end
    end
})

SectionPlayer:Slider({
    Title = "WalkSpeed Value",
    Desc = "Adjust character movement speed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 150,
        Default = 16
    },
    Callback = function(val)
        Config.WalkSpeed = val
        if Config.ModifyWalkSpeed then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = val end
        end
    end
})

SectionPlayer:Toggle({
    Title = "Modify JumpPower",
    Desc = "Enforces custom vertical jump velocity",
    Value = false,
    Callback = function(val)
        Config.ModifyJumpPower = val
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = val and Config.JumpPower or 50
        end
    end
})

SectionPlayer:Slider({
    Title = "JumpPower Value",
    Desc = "Adjust character jump velocity",
    Step = 5,
    Value = {
        Min = 50,
        Max = 300,
        Default = 50
    },
    Callback = function(val)
        Config.JumpPower = val
        if Config.ModifyJumpPower then
            local hum = getHumanoid()
            if hum then hum.JumpPower = val end
        end
    end
})

SectionPlayer:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in mid-air",
    Value = false,
    Callback = function(val)
        Config.InfJump = val
    end
})

SectionPlayer:Toggle({
    Title = "Noclip (Phase Through Walls)",
    Desc = "Disables character body part collisions",
    Value = false,
    Callback = function(val)
        Config.Noclip = val
    end
})

SectionPlayer:Toggle({
    Title = "Fly Mode",
    Desc = "Allows free 3D aerial navigation (WASD + Space/Shift)",
    Value = false,
    Callback = function(val)
        Config.Fly = val
        local root = getRoot()
        if not val and root then
            local bv = root:FindFirstChild("XLunaFlyVelocity")
            local bg = root:FindFirstChild("XLunaFlyGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
})

SectionPlayer:Slider({
    Title = "Fly Speed",
    Desc = "Velocity of aerial movement in Fly mode",
    Step = 5,
    Value = {
        Min = 20,
        Max = 200,
        Default = 50
    },
    Callback = function(val)
        Config.FlySpeed = val
    end
})

SectionPlayer:Toggle({
    Title = "Fullbright (Max Visibility)",
    Desc = "Removes world shadows and sets ambient brightness to maximum",
    Value = false,
    Callback = function(val)
        Config.Fullbright = val
        local Lighting = game:GetService("Lighting")
        if val then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

local SectionProtection = TabVisuals:Section({ Title = "Client Protections & Utility", Icon = "shield-check" })

SectionProtection:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents 20-minute idle disconnects via VirtualUser simulation and 5-min keepalive pulses",
    Value = true,
    Callback = function(val)
        Config.AntiAfk = val
    end
})

-- =========================================================================
-- TAB 8: CONFIG PROFILE SYSTEM
-- =========================================================================
local SectionConfig = TabConfig:Section({ Title = "Profile Management", Icon = "settings" })

SectionConfig:Button({
    Title = "Save Current Config",
    Desc = "Saves active toggle configuration to local disk",
    Callback = function()
        local payload = {}
        for k, v in pairs(Config) do
            if type(v) ~= "function" then
                payload[k] = v
            end
        end
        if writefile then
            pcall(function()
                if not isfolder("XLuna_MineAnElement") then
                    makefolder("XLuna_MineAnElement")
                end
                writefile(CONFIG_FILE, HttpService:JSONEncode(payload))
                WindUI:Notify({
                    Title = "Config Saved",
                    Content = "Configuration saved successfully!",
                    Duration = 3
                })
            end)
        end
    end
})

SectionConfig:Button({
    Title = "Load Saved Config",
    Desc = "Loads and applies settings from disk",
    Callback = function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(CONFIG_FILE))
            end)
            if success and type(data) == "table" then
                for k, v in pairs(data) do
                    Config[k] = v
                end
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Saved settings applied!",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "No Config Found",
                Content = "No saved configuration file found.",
                Duration = 3
            })
        end
    end
})

SectionConfig:Button({
    Title = "Reset All to Default (ALL OFF)",
    Desc = "Resets all automation toggles to inactive state",
    Callback = function()
        for k, v in pairs(Config) do
            if type(v) == "boolean" then
                Config[k] = false
            end
        end
        WindUI:Notify({
            Title = "Settings Reset",
            Content = "All automation toggles are now OFF.",
            Duration = 3
        })
    end
})

-- =========================================================================
-- CORE BACKGROUND AUTOMATION ENGINES
-- =========================================================================

-- Target Evaluation Helper
local function getBestRockTarget()
    local targetArea = MAP_NAMES[Config.MiningMap]
    local open = MineController.openRocks(targetArea)
    if not open or #open == 0 then return nil end

    local root = getRoot()
    if not root then return nil end
    local myPos = root.Position

    local bestId = nil
    local bestScore = (Config.TargetMode == "Highest HP") and -math.huge or math.huge

    for _, id in ipairs(open) do
        local kind = MineController.kindOf(id)
        local pos = RockCore.position(id)
        local hp = MineController.shownHp(id) or 1

        if pos then
            local rockVec = Vector3.new(pos.x, pos.y, pos.z)
            local dist = (myPos - rockVec).Magnitude

            local passFilter = true
            if Config.RockFilter == "Small Only" and kind ~= "small" then passFilter = false end
            if Config.RockFilter == "Big Only" and kind ~= "big" then passFilter = false end
            if Config.RockFilter == "Giant Only" and kind ~= "giant" then passFilter = false end

            if passFilter then
                if Config.TargetMode == "Closest" then
                    if dist < bestScore then
                        bestScore = dist
                        bestId = id
                    end
                elseif Config.TargetMode == "Lowest HP" then
                    if hp < bestScore then
                        bestScore = hp
                        bestId = id
                    end
                elseif Config.TargetMode == "Highest HP" then
                    if hp > bestScore then
                        bestScore = hp
                        bestId = id
                    end
                end
            end
        end
    end

    return bestId
end

-- Ground Chunk Vacuum Helper
local function vacuumNearbyChunks(radius)
    local root = getRoot()
    if not root then return end
    local myPos = root.Position
    local maxDist = radius or 10

    local success, ups = pcall(function()
        return debug.getupvalues(MineController.nearestGround)
    end)
    if success and ups and type(ups[2]) == "table" then
        for cId, cData in pairs(ups[2]) do
            if cData.at then
                local cVec = Vector3.new(cData.at.x, cData.at.y, cData.at.z)
                if (myPos - cVec).Magnitude <= maxDist then
                    ChunkCollect:FireServer(cId)
                end
            end
        end
    end
end

-- Safe Mining Footing & Raycast Grounding Solver
local function findSafeMiningPosition(targetId, currentRootPos)
    local pos = RockCore.position(targetId)
    if not pos then return nil end

    local rockVec = Vector3.new(pos.x, pos.y, pos.z)
    local kind = MineController.kindOf(targetId)
    local rad = (RockCore.radius and RockCore.radius(kind)) or 3
    local approachDist = math.clamp(rad + 2.2, 4.2, 7.2)

    local char = LocalPlayer.Character
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { char, Workspace:FindFirstChild("DropChunks"), Workspace:FindFirstChild("Moles") }
    rayParams.IgnoreWater = true

    -- Preferred approach angle: towards player's current location if possible
    local baseAngle = 0
    if currentRootPos then
        local delta = currentRootPos - rockVec
        if delta.Magnitude > 0.1 then
            baseAngle = math.deg(math.atan2(delta.Z, delta.X))
        end
    end

    -- Sweep 8 surrounding angles to find solid collidable floor
    local sweepOffsets = { 0, 45, -45, 90, -90, 135, -135, 180 }
    for _, offsetDeg in ipairs(sweepOffsets) do
        local testAngle = math.rad(baseAngle + offsetDeg)
        local testX = rockVec.X + math.cos(testAngle) * approachDist
        local testZ = rockVec.Z + math.sin(testAngle) * approachDist

        -- Raycast vertically down from above rock height
        local rayOrigin = Vector3.new(testX, rockVec.Y + 8, testZ)
        local hit = workspace:Raycast(rayOrigin, Vector3.new(0, -32, 0), rayParams)

        if hit and hit.Instance and hit.Instance.CanCollide then
            local partName = string.lower(hit.Instance.Name)
            if not string.find(partName, "pool") and not string.find(partName, "water") then
                local groundY = hit.Position.Y
                if groundY > -5 then
                    return Vector3.new(testX, groundY + 3.0, testZ)
                end
            end
        end
    end

    -- Fallback: If no raycast ground found (e.g. over water pool), approach safely at Dais level or safe hover
    return Vector3.new(rockVec.X + math.cos(math.rad(baseAngle)) * approachDist, rockVec.Y + rad + 2.5, rockVec.Z + math.sin(math.rad(baseAngle)) * approachDist)
end

-- Anti-Void Safety Net Daemon
local SAFE_MAP_BOUNDS = {
    quarry = { minY = -5, spawn = LOCATIONS.QuarryPad },
    lava   = { minY = -5, spawn = LOCATIONS.LavaPad },
    lagoon = { minY = -3, spawn = LOCATIONS.LagoonPad },
    sky    = { minY = 236, spawn = LOCATIONS.SkyPad },
    deep   = { minY = -170, spawn = Vector3.new(-1334, -157, 64) }
}

local function checkVoidSafety()
    local root = getRoot()
    if not root then return end
    local state = PlayerState.get()
    local curArea = (state and state.area) or LocalPlayer:GetAttribute("Area") or "quarry"
    local bounds = SAFE_MAP_BOUNDS[curArea] or SAFE_MAP_BOUNDS.quarry

    if root.Position.Y < bounds.minY then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(bounds.spawn)
        currentTargetRock = nil
    end
end

-- Auto Crush Controller
local function handleAutoCrush()
    if not Config.AutoCrush or isCrushingActive then return end

    local state = PlayerState.get()
    if not state or not state.backpack then return end

    local cap = state.backpack.cap or 120
    local chunks = state.backpack.chunks or 0
    local threshold = math.floor(cap * (Config.CrushPercent / 100))

    if chunks >= threshold and chunks > 0 then
        isCrushingActive = true
        task.spawn(function()
            local root = getRoot()
            if not root then
                isCrushingActive = false
                return
            end
            local savedPos = root.CFrame

            -- Area appropriate Crusher Drop Pad
            local crusherPos = LOCATIONS.QuarryPad
            local curArea = (state and state.area) or LocalPlayer:GetAttribute("Area") or "quarry"
            if curArea == "lava" then
                crusherPos = LOCATIONS.LavaPad
            elseif curArea == "lagoon" then
                crusherPos = LOCATIONS.LagoonPad
            elseif curArea == "sky" then
                local currentPos = root.Position
                if (currentPos - LOCATIONS.SkyPad2).Magnitude < (currentPos - LOCATIONS.SkyPad).Magnitude then
                    crusherPos = LOCATIONS.SkyPad2
                else
                    crusherPos = LOCATIONS.SkyPad
                end
            end

            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(crusherPos)
            task.wait(0.3) -- Allow server physics replication of pad arrival

            local t0 = os.clock()
            while Running and (os.clock() - t0 < 10) do
                local curState = PlayerState.get()
                if not curState or not curState.backpack or curState.backpack.chunks == 0 then
                    break
                end
                CrushRemote:FireServer()
                task.wait(0.35)
            end

            task.wait(0.2)
            if root and savedPos then
                root.CFrame = savedPos
            end
            task.wait(0.2)
            isCrushingActive = false
        end)
    end
end

-- Egg Nests & Incubator Automation
local function handleEggAutomation()
    if not (Config.AutoPlaceEgg or Config.AutoOpenEgg) or isEggActionActive or isCrushingActive or isBossCombatActive then return end

    local state = PlayerState.get()
    if not state or not state.eggs then return end
    local root = getRoot()
    if not root then return end

    local now = workspace:GetServerTimeNow()
    local plotAttr = LocalPlayer:GetAttribute("Plot")
    local plot = plotAttr and BaseLayout.plot(plotAttr)
    if not plot or not plot.pads then return end

    -- 1. Auto Open Ready Eggs on Pads
    if Config.AutoOpenEgg then
        for _, egg in ipairs(state.eggs) do
            if egg.place == "pad" and egg.pad and egg.readyAt and (now >= egg.readyAt) then
                local padData = plot.pads[egg.pad]
                if padData and padData.position then
                    isEggActionActive = true
                    task.spawn(function()
                        local savedPos = root.CFrame
                        root.CFrame = CFrame.new(padData.position.x, padData.position.y + 0.2, padData.position.z)
                        task.wait(0.25)
                        OpenEgg:FireServer(egg.pad)
                        task.wait(0.35)
                        if savedPos and root then
                            root.CFrame = savedPos
                        end
                        task.wait(0.2)
                        isEggActionActive = false
                    end)
                    return
                end
            end
        end
    end

    -- 2. Auto Place Eggs onto Nests
    if Config.AutoPlaceEgg then
        local maxPads = (state.nests and state.nests.pads) or 2

        local carriedEgg = nil
        for _, egg in ipairs(state.eggs) do
            if egg.place == "carry" then
                carriedEgg = egg
                break
            end
        end

        local occupiedPads = {}
        for _, egg in ipairs(state.eggs) do
            if egg.place == "pad" and egg.pad then
                occupiedPads[egg.pad] = true
            end
        end

        local emptyPad = nil
        for p = 1, maxPads do
            if not occupiedPads[p] then
                emptyPad = p
                break
            end
        end

        if carriedEgg and emptyPad then
            local padData = plot.pads[emptyPad]
            if padData and padData.position then
                isEggActionActive = true
                task.spawn(function()
                    local savedPos = root.CFrame
                    root.CFrame = CFrame.new(padData.position.x, padData.position.y + 0.2, padData.position.z)
                    task.wait(0.25)
                    PlaceEgg:FireServer(emptyPad)
                    task.wait(0.35)
                    if savedPos and root then
                        root.CFrame = savedPos
                    end
                    task.wait(0.2)
                    isEggActionActive = false
                end)
                return
            end
        elseif not carriedEgg and emptyPad then
            local gateEgg = nil
            for _, egg in ipairs(state.eggs) do
                if egg.place == "gate" then
                    gateEgg = egg
                    break
                end
            end

            if gateEgg then
                isEggActionActive = true
                task.spawn(function()
                    local savedPos = root.CFrame
                    local eggPos = nil
                    local eggsFolder = workspace:FindFirstChild("Eggs")
                    local myFolder = eggsFolder and eggsFolder:FindFirstChild(tostring(LocalPlayer.UserId))
                    local eggModel = myFolder and (myFolder:FindFirstChild("Egg_" .. gateEgg.uid) or myFolder:FindFirstChild(tostring(gateEgg.uid)))
                    if eggModel and eggModel:IsA("Model") and eggModel.PrimaryPart then
                        eggPos = eggModel.PrimaryPart.Position
                    elseif plot.gate and plot.gate.position then
                        eggPos = Vector3.new(plot.gate.position.x, plot.gate.position.y + 2, plot.gate.position.z)
                    else
                        eggPos = Vector3.new(LOCATIONS.HomeMat.X - 5, LOCATIONS.HomeMat.Y - 3, LOCATIONS.HomeMat.Z + 7)
                    end

                    root.CFrame = CFrame.new(eggPos.X, eggPos.Y + 1.5, eggPos.Z)
                    task.wait(0.25)
                    PickUpEgg:FireServer(gateEgg.uid)
                    task.wait(0.35)

                    local padData = plot.pads[emptyPad]
                    if padData and padData.position then
                        root.CFrame = CFrame.new(padData.position.x, padData.position.y + 0.2, padData.position.z)
                        task.wait(0.25)
                        PlaceEgg:FireServer(emptyPad)
                        task.wait(0.35)
                    end

                    if savedPos and root then
                        root.CFrame = savedPos
                    end
                    task.wait(0.2)
                    isEggActionActive = false
                end)
                return
            end
        end
    end
end

-- Egg Hatching Cutscene & Fast Tap Engine
local HatchPopModule = nil
pcall(function()
    HatchPopModule = require(LocalPlayer.PlayerScripts.Client.HatchPop)
end)

local function handleAutoTapEgg()
    if not Config.AutoTapEgg then return end

    local hpGui = LocalPlayer.PlayerGui:FindFirstChild("HatchPop")
    local openAllGui = LocalPlayer.PlayerGui:FindFirstChild("EggOpenAll")

    if hpGui and hpGui.Enabled then
        if HatchPopModule and HatchPopModule.skipNow then
            pcall(HatchPopModule.skipNow)
        end
        local sk = hpGui:FindFirstChild("Skip")
        if sk and sk.Visible and firesignal then
            pcall(function() firesignal(sk.Activated) end)
        end
        local tc = hpGui:FindFirstChild("TapCatcher")
        if tc and firesignal then
            pcall(function() firesignal(tc.Activated) end)
        end
    end

    if openAllGui and openAllGui.Enabled then
        local bd = openAllGui:FindFirstChild("Backdrop")
        if bd and firesignal then
            pcall(function() firesignal(bd.Activated) end)
        end
    end
end

-- Auto Click Mine Engine
local lastClickTime = 0
local function handleAutoClickMine()
    if not Config.AutoClickMine or isCrushingActive or isBossCombatActive or isEggActionActive then return end

    local now = os.clock()
    local interval = Config.ClickSpeed or 0.1
    if now - lastClickTime < interval then return end
    lastClickTime = now

    local target = MineController.target()
    local root = getRoot()

    if not target and root then
        local myPos = root.Position
        local targetArea = MAP_NAMES[Config.MiningMap]
        local open = MineController.openRocks(targetArea)
        if open then
            for _, id in ipairs(open) do
                local pos = RockCore.position(id)
                if pos then
                    local rVec = Vector3.new(pos.x, pos.y, pos.z)
                    if (myPos - rVec).Magnitude <= 7.5 then
                        target = id
                        break
                    end
                end
            end
        end
    end

    if target then
        pcall(function() MineController.swing() end)
        MineSwing:FireServer(target)
        if Config.AutoCollectChunks then
            vacuumNearbyChunks(10)
        end
    end
end

-- Fast Main Automation Loop (Mining & Chunks)
task.spawn(function()
    while Running do
        task.wait(0.1)

        -- Void Safety Catch
        checkVoidSafety()

        -- 0. Fast Tap Egg Cutscenes
        handleAutoTapEgg()

        -- 0. Fast Auto Click Mine
        handleAutoClickMine()

        -- 1. Auto Mine Rocks (Strictly exclusive from Crushing, Boss Combat, and Egg actions)
        if Config.AutoMine and not isCrushingActive and not isBossCombatActive and not isEggActionActive then
            local targetId = getBestRockTarget()
            if targetId then
                currentTargetRock = targetId
                local pos = RockCore.position(targetId)
                local root = getRoot()

                if pos and root then
                    local rockVec = Vector3.new(pos.x, pos.y, pos.z)
                    local dist = (root.Position - rockVec).Magnitude

                    -- Set visual target highlight
                    if MineFx and MineFx.setTarget then
                        pcall(function() MineFx.setTarget(targetId) end)
                    end

                    -- Valid swing radius positioning with solid raycast grounding
                    if Config.AutoTeleportToRock and dist > 7.0 then
                        local safeSpot = findSafeMiningPosition(targetId, root.Position)
                        if safeSpot then
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.CFrame = CFrame.new(safeSpot, rockVec)
                            task.wait(0.2) -- Replication delay to ensure server recognizes position
                        end
                    end

                    -- Only swing if verified within valid range
                    local currentDist = (root.Position - rockVec).Magnitude
                    if currentDist <= 8.5 then
                        root.AssemblyLinearVelocity = Vector3.zero
                        local burst = math.clamp(Config.MineBurst or 2, 1, 4)
                        for i = 1, burst do
                            MineSwing:FireServer(targetId)
                        end
                        task.wait(0.2)
                    end

                    -- Vacuum dropped chunks immediately
                    if Config.AutoCollectChunks then
                        vacuumNearbyChunks(10)
                    end
                end
            else
                currentTargetRock = nil
                if MineFx and MineFx.setTarget then
                    pcall(function() MineFx.setTarget(nil) end)
                end
            end
        end

        -- 2. Standalone Chunk Collection
        if Config.AutoCollectChunks and not Config.AutoMine and not isCrushingActive and not isBossCombatActive then
            vacuumNearbyChunks(10)
        end

        -- 3. Auto Crush
        handleAutoCrush()

        -- 4. Fast Open Held Egg
        if Config.AutoOpenHeld then
            OpenHeld:FireServer()
        end

        -- 5. Auto Boss / Golem (STRICTLY REACTIVE: Only reacts when boss is awake / waking up)
        if Config.AutoGolem and not isCrushingActive and not isEggActionActive then
            local boss = BOSS_DATA[Config.SelectedBoss] or BOSS_DATA["Cobble Golem (Quarry)"]
            if boss then
                local bossArea = boss.area
                local status = getBossStatus(bossArea)

                -- Only engage if the boss is actually active (rumble, waiting, title, step1-3, dizzy, napping) or ready to wake
                if status.isActive or status.canWake then
                    isBossCombatActive = true
                    local root = getRoot()
                    if root then
                        local bossPos = boss.pos
                        local curArea = (PlayerState.get() and PlayerState.get().area) or LocalPlayer:GetAttribute("Area") or "quarry"

                        if curArea ~= bossArea then
                            GoArea:FireServer(bossArea)
                            task.wait(0.3)
                        end

                        if (root.Position - bossPos).Magnitude > 25 then
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.CFrame = CFrame.new(bossPos.X, boss.floor + 3, bossPos.Z)
                            task.wait(0.25)
                        end

                        PokeGolem:FireServer()
                        SkipTitle:FireServer()

                        if Config.GolemFloat then
                            root.AssemblyLinearVelocity = Vector3.zero
                            local c = root.Position
                            root.CFrame = CFrame.new(c.X, boss.floor + 12, c.Z)
                        end
                    end
                else
                    -- Boss is asleep / beaten. MUST NOT teleport! Reset combat flag so mining continues undisturbed!
                    if isBossCombatActive then
                        isBossCombatActive = false
                    end
                end
            end
        else
            if isBossCombatActive then
                isBossCombatActive = false
            end
        end

        -- 6. Auto Bonk Moles
        if Config.AutoBonkMoles then
            local moles = workspace:FindFirstChild("Moles")
            if moles then
                for _, mole in ipairs(moles:GetChildren()) do
                    local mId = tonumber(mole.Name)
                    if mId then
                        BonkMole:FireServer(mId)
                    end
                end
            end
        end
    end
end)

-- Secondary Periodic Automation Loop (Slower interval for economy/upgrades/rewards)
task.spawn(function()
    while Running do
        task.wait(1.5)

        -- Realtime Boss Status UI Monitor
        if GolemStatusParagraph and Config.SelectedBoss then
            local boss = BOSS_DATA[Config.SelectedBoss]
            if boss then
                local st = getBossStatus(boss.area)
                local info = ""
                if st.isActive then
                    info = "ACTIVE! In combat / waking (" .. tostring(st.state) .. ")"
                elseif st.canWake then
                    info = "READY TO WAKE! (0 rocks left to mine)"
                elseif st.rocksLeft then
                    info = "Asleep (" .. tostring(st.rocksLeft) .. " more rocks needed to wake)"
                else
                    info = "Status: " .. tostring(st.state)
                end
                pcall(function()
                    GolemStatusParagraph:SetTitle("Status: " .. boss.name)
                    GolemStatusParagraph:SetDesc(info)
                end)
            end
        end

        -- 1. Auto Buy Eggs (Respecting stand proximity)
        if Config.AutoBuyEgg then
            local root = getRoot()
            if root then
                local distToStand = (root.Position - LOCATIONS.EggStand).Magnitude
                if distToStand <= 30 then
                    local ped = EggPedestals[Config.SelectedEgg] or "fire_1"
                    local amt = Config.EggAmount or 1
                    BuyEgg:FireServer({ id = ped, many = amt })
                end
            end
        end

        -- 2. Auto Place & Auto Open Eggs
        handleEggAutomation()

        -- 2. Auto Equip Best Pets
        if Config.AutoEquipBest then
            EquipBest:FireServer(nil)
        end

        -- 3. Auto Upgrades
        if Config.AutoAllUpgrades then
            local upgradeList = {
                "backpack", "pickPower", "swing", "walk", "reach",
                "crusherSpeed", "holdToMine", "giant", "helpers",
                "super", "home", "room", "lucky"
            }
            for _, uId in ipairs(upgradeList) do
                BuyUpgrade:FireServer(uId)
            end
        else
            if Config.AutoBackpack then BuyUpgrade:FireServer("backpack") end
            if Config.AutoPickPower then BuyUpgrade:FireServer("pickPower") end
            if Config.AutoSwingSpeed then BuyUpgrade:FireServer("swing") end
            if Config.AutoWalkSpeed then BuyUpgrade:FireServer("walk") end
            if Config.AutoReach then BuyUpgrade:FireServer("reach") end
            if Config.AutoCrusherSpeed then BuyUpgrade:FireServer("crusherSpeed") end
        end

        -- 4. Auto Buy Pickaxe (Only if at Pick Forge)
        if Config.AutoBuyPick then
            local root = getRoot()
            if root and (root.Position - LOCATIONS.PickForge).Magnitude <= 20 then
                local state = PlayerState.get()
                local pickPicks = { "wooden", "stone", "copper", "iron", "crystal", "coral", "pearl", "cloud", "gale" }
                if state and state.pickTier then
                    local nextPick = pickPicks[state.pickTier + 1]
                    if nextPick then
                        BuyPick:FireServer(nextPick)
                    end
                end
            end
        end

        -- 5. Auto Daily Reward (Visits Gift Chest when ready)
        if Config.AutoDaily and not isCrushingActive then
            local state = PlayerState.get()
            if state and state.daily and state.daily.ready then
                task.spawn(function()
                    local root = getRoot()
                    if not root then return end
                    local savedPos = root.CFrame
                    root.CFrame = CFrame.new(LOCATIONS.GiftChest)
                    task.wait(0.3)
                    ClaimDaily:FireServer()
                    task.wait(0.4)
                    if root and savedPos then
                        root.CFrame = savedPos
                    end
                end)
            end
        end

        -- 6. Auto Playtime Gifts
        if Config.AutoPlayGifts then
            for giftIdx = 1, 12 do
                OpenPlayGift:FireServer(giftIdx)
            end
        end

        -- 7. Auto Base Mat (Welcome Mat)
        if Config.AutoBaseMat then
            local root = getRoot()
            if root and (root.Position - LOCATIONS.HomeMat).Magnitude <= 15 then
                CollectMat:FireServer()
            end
        end
    end
end)

-- Physics Modifiers Loop (Noclip, WalkSpeed, JumpPower, InfJump, Fly)
local noclipConn = RunService.Stepped:Connect(function()
    if not Running then return end

    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip
    if Config.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- WalkSpeed & JumpPower enforcement
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.ModifyWalkSpeed and hum.WalkSpeed ~= Config.WalkSpeed then
            hum.WalkSpeed = Config.WalkSpeed
        end
        if Config.ModifyJumpPower and hum.JumpPower ~= Config.JumpPower then
            hum.JumpPower = Config.JumpPower
        end
    end
end)
table.insert(activeConnections, noclipConn)

-- Infinite Jump Listener
local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if Running and Config.InfJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(activeConnections, infJumpConn)

-- Fly Controller
task.spawn(function()
    while Running do
        task.wait()
        if Config.Fly then
            local root = getRoot()
            local hum = getHumanoid()
            local cam = workspace.CurrentCamera

            if root and hum and cam then
                local bv = root:FindFirstChild("XLunaFlyVelocity")
                local bg = root:FindFirstChild("XLunaFlyGyro")

                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "XLunaFlyVelocity"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = root
                end

                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "XLunaFlyGyro"
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.P = 9e4
                    bg.Parent = root
                end

                bg.CFrame = cam.CFrame

                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end

                if move.Magnitude > 0 then
                    bv.Velocity = move.Unit * Config.FlySpeed
                else
                    bv.Velocity = Vector3.zero
                end
            end
        end
    end
end)

-- Character Added Re-attachment Guard
local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum then
        if Config.ModifyWalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
        if Config.ModifyJumpPower then hum.JumpPower = Config.JumpPower end
    end
end)
table.insert(activeConnections, charAddedConn)

-- Final Load Notification
WindUI:Notify({
    Title = "XLuna Hub Loaded",
    Content = "Mine an Element! script verified & ready. Press LeftCTRL to toggle.",
    Duration = 4
})
