-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    DEPTH INCREMENTAL ELITE AUTOMATION SUITE
    Game: [UPD6 ð] Depth Incremental
    PlaceId: 119101118479978 | UniverseId: 10769835283
    Architecture: WindUI Universal Framework
    Standard: Default ALL OFF | English UI | LeftCTRL Toggle | Floating Button | Config Manager
]]

-- ====================================================================
-- SERVICES & ENVIRONMENT INITIALIZATION
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for critical game dependencies
local PitConfig = require(ReplicatedStorage:WaitForChild("PitConfig"))
local PitRemotes = ReplicatedStorage:WaitForChild("PitRemotes")

-- Clean up any previous execution to prevent loop or UI stacking
if _G.DepthCleanup then
    pcall(_G.DepthCleanup)
end

local isScriptActive = true

-- ====================================================================
-- MASTER CONFIGURATION TABLE (STRICTLY ALL OFF BY DEFAULT)
-- ====================================================================
local Config = {
    -- Auto Pit & Steps
    AutoBuySteps = false,
    StepBuyDelay = 0.08,
    TargetStepLimit = 0, -- 0 = infinite / no limit
    AutoBuyW2Steps = false,
    AutoBuyRooms = false,
    AutoClaimDailyEggs = false,

    -- Upgrades Automation
    AutoBuyAllUpgrades = false,
    UpgradeCategory = "All", -- All, Cash, Worms, Bucks, Magma, Souls, Fish, Wood, Spores, Embers
    AutoBuyTrees = false,

    -- Fossil Farm & Digger Engine
    AutoDigFossils = false,
    SelectedFossilZone = "Dirt",
    AutoSelectBestFossilZone = false,
    LockInFossilBed = false,
    AutoUpgradeFossilStats = false,

    -- Worm Farm
    AutoCollectWorms = false,
    WormFarmMode = "Instant Sweep (Teleport)", -- "Instant Sweep (Teleport)", "Proximity Only (Safe)"
    AutoWormRebirth = false,

    -- Combat & Boss Slayer
    AutoBossSlayer = false,
    BossSwingRate = 15, -- Swings per second
    SafeBossHover = false,
    AutoStartBoss = false,
    SelectedBoss = "Dirt",
    AutoMineVeins = false,

    -- Titles & Rebirth
    AutoRollTitles = false,
    SelectedTitleSet = "Dirt",
    AutoEquipBestTitle = false,
    AutoRebirth = false,

    -- Teleport & Navigation
    SelectedRoom = "Surface",
    TargetStep = 1,

    -- Movement & QoL
    SpeedEnabled = false,
    SpeedValue = 32,
    JumpEnabled = false,
    JumpValue = 60,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,

    -- UI Settings
    FloatingButton = true,
}

_G.DepthConfig = Config
if getgenv then getgenv().DepthConfig = Config end

-- ====================================================================
-- LOAD WINDUI FRAMEWORK
-- ====================================================================
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    WindUISuccess, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
end

if not WindUISuccess or not WindUI then
    warn("[Depth Incremental] Failed to load WindUI from remote CDNs.")
    return
end

-- ====================================================================
-- MAIN WINDOW SETUP
-- ====================================================================
local Window = WindUI:CreateWindow({
    Title = "Depth Incremental Elite",
    Icon = "mountain",
    Author = "System Architect",
    Folder = "DepthIncremental",
    Size = UDim2.fromOffset(620, 520),
    Transparent = true,
    Theme = "Dark",
})

_G.DepthWindow = Window

-- Set LeftControl Keybind for Window Visibility
Window:SetToggleKey(Enum.KeyCode.LeftControl)

local _lastToggleTick = 0
local function toggleUIVisibility()
    local now = os.clock()
    if now - _lastToggleTick < 0.25 then return end
    _lastToggleTick = now
    pcall(function()
        Window:Toggle()
    end)
end

-- ====================================================================
-- CONFIG PROFILE MANAGER (FILESYSTEM I/O)
-- ====================================================================
local CONFIG_FOLDER = "DepthIncremental_Configs"
if isfolder and not isfolder(CONFIG_FOLDER) then
    pcall(makefolder, CONFIG_FOLDER)
end

local function saveConfigFile(name)
    if not writefile then return end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local encoded = HttpService:JSONEncode(Config)
    pcall(writefile, path, encoded)
    WindUI:Notify({
        Title = "Config Saved",
        Content = "Profile '" .. name .. "' successfully saved.",
        Duration = 3,
        Icon = "check",
    })
end

local function loadConfigFile(name)
    if not readfile or not isfile then return false end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile(path) then
        local content = readfile(path)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if Config[k] ~= nil then
                    Config[k] = v
                end
            end
            WindUI:Notify({
                Title = "Config Loaded",
                Content = "Profile '" .. name .. "' successfully loaded.",
                Duration = 3,
                Icon = "check",
            })
            return true
        end
    end
    WindUI:Notify({
        Title = "Config Error",
        Content = "File '" .. name .. ".json' not found.",
        Duration = 3,
        Icon = "alert-circle",
    })
    return false
end

-- ====================================================================
-- DRAGGABLE FLOATING ACTION BUTTON
-- ====================================================================
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local oldBtn = guiParent:FindFirstChild("Depth_FloatingButton")
if oldBtn then
    oldBtn:Destroy()
end

local floatingGui = Instance.new("ScreenGui")
floatingGui.Name = "Depth_FloatingButton"
floatingGui.ResetOnSpawn = false
floatingGui.DisplayOrder = 999999
floatingGui.Parent = guiParent

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "ToggleButton"
floatBtn.Size = UDim2.fromOffset(48, 48)
floatBtn.Position = UDim2.new(0.03, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
floatBtn.BackgroundTransparency = 0.1
floatBtn.AutoButtonColor = true
floatBtn.ZIndex = 999
floatBtn.Parent = floatingGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = floatBtn

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(80, 170, 255)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = floatBtn

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.fromOffset(26, 26)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.fromScale(0.5, 0.5)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10709791437"
icon.ImageColor3 = Color3.fromRGB(120, 200, 255)
icon.ZIndex = 1000
icon.Parent = floatBtn

local isDragging = false
local dragStart = nil
local startPos = nil
local moved = false

floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = floatBtn.Position
        moved = false
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 4 then
            moved = true
            floatBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    if not moved then
        toggleUIVisibility()
    end
end)

-- Cleanup handler registration
_G.DepthCleanup = function()
    isScriptActive = false
    if floatingGui then
        pcall(function() floatingGui:Destroy() end)
    end
    if _G.DepthWindow then
        pcall(function() _G.DepthWindow:Destroy() end)
        _G.DepthWindow = nil
    end
end

-- ====================================================================
-- TAB DEFINITIONS
-- ====================================================================
local TabPit = Window:Tab({ Title = "Auto Pit", Icon = "stairs" })
local TabFossils = Window:Tab({ Title = "Fossil Digger", Icon = "pickaxe" })
local TabWorms = Window:Tab({ Title = "Worm Farm", Icon = "bug" })
local TabCombat = Window:Tab({ Title = "Boss Slayer", Icon = "swords" })
local TabProgression = Window:Tab({ Title = "Skill & Titles", Icon = "crown" })
local TabTeleport = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
local TabPlayer = Window:Tab({ Title = "Movement & QoL", Icon = "zap" })
local TabConfig = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ====================================================================
-- TAB 1: AUTO PIT & PROGRESSION
-- ====================================================================
TabPit:Section({ Title = "Spiral Pit Steps (Remote Bypass Engine)" })

TabPit:Toggle({
    Title = "Auto Buy Steps (World 1)",
    Desc = "Bypasses distance check and buys steps remotely as soon as affordable.",
    Value = false,
    Callback = function(val)
        Config.AutoBuySteps = val
    end
})

TabPit:Slider({
    Title = "Step Purchase Delay",
    Desc = "Interval between consecutive step purchases.",
    Min = 0.02,
    Max = 0.5,
    Default = 0.08,
    Step = 0.01,
    Callback = function(val)
        Config.StepBuyDelay = val
    end
})

TabPit:Input({
    Title = "Target Step Limit (0 = Infinite)",
    Desc = "Stops auto buying steps upon reaching this step index.",
    Value = "0",
    Placeholder = "e.g. 100",
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 0 then
            Config.TargetStepLimit = math.floor(num)
        end
    end
})

TabPit:Toggle({
    Title = "Auto Buy Steps (World 2)",
    Desc = "Automatically buys next steps in World 2 using Bucks.",
    Value = false,
    Callback = function(val)
        Config.AutoBuyW2Steps = val
    end
})

TabPit:Section({ Title = "Rooms & Upgrades Automator" })

TabPit:Toggle({
    Title = "Auto Unlock Rooms",
    Desc = "Automatically purchases newly unlocked rooms across all layers.",
    Value = false,
    Callback = function(val)
        Config.AutoBuyRooms = val
    end
})

TabPit:Toggle({
    Title = "Auto Buy Upgrades (Max Tier)",
    Desc = "Automatically fires BuyMax on all affordable upgrades.",
    Value = false,
    Callback = function(val)
        Config.AutoBuyAllUpgrades = val
    end
})

TabPit:Dropdown({
    Title = "Upgrade Currency Filter",
    Desc = "Restrict upgrade purchasing to specific resource categories.",
    Values = { "All", "Cash", "Worms", "Bucks", "Magma", "Souls", "Fish", "Wood", "Spores", "Embers" },
    Value = "All",
    Callback = function(val)
        Config.UpgradeCategory = val
    end
})

TabPit:Toggle({
    Title = "Auto Claim Daily Hatchery Eggs",
    Desc = "Automatically claims free egg rewards when cooldown expires.",
    Value = false,
    Callback = function(val)
        Config.AutoClaimDailyEggs = val
    end
})

-- ====================================================================
-- TAB 2: FOSSIL DIGGER ENGINE (FULL AUTOMATION & TELEPORT)
-- ====================================================================
TabFossils:Section({ Title = "Autonomous Fossil Digger" })

local fossilZoneList = {
    "Dirt", "Stone", "Deep", "Web", "Nest", "Lake", "Abyss", "Frost", 
    "Glacier", "Spore", "Mycelium", "Void", "Eclipse", "Crypt", "Bone", 
    "Wreck", "Skull", "Crust", "Basalt", "Obsidian", "Molten", "Heartstone", 
    "Jungle", "Comb", "Amber", "BallPit", "Attic", "Popcorn", "Mirror", 
    "Chocolate", "RockCandy", "Flour", "Batter", "Storm", "Glass"
}

-- Progressive priority order from rarest / highest tier to basic
local fossilPriorityOrder = {
    "Heartstone", "Molten", "Obsidian", "Basalt", "Crust", "Skull", "Wreck", 
    "Bone", "Crypt", "Eclipse", "Void", "Mycelium", "Spore", "Glacier", 
    "Frost", "Abyss", "Lake", "Nest", "Web", "Deep", "Stone", "Dirt"
}

TabFossils:Toggle({
    Title = "Auto Dig Fossils",
    Desc = "Teleports to the chosen fossil bed and continuously digs fossils.",
    Value = false,
    Callback = function(val)
        Config.AutoDigFossils = val
    end
})

TabFossils:Dropdown({
    Title = "Selected Fossil Zone",
    Desc = "Choose target fossil site to dig at.",
    Values = fossilZoneList,
    Value = "Dirt",
    Callback = function(val)
        Config.SelectedFossilZone = val
    end
})

TabFossils:Toggle({
    Title = "Auto Select Best Unlocked Zone",
    Desc = "Automatically digs at the highest tier fossil bed you own and can afford.",
    Value = false,
    Callback = function(val)
        Config.AutoSelectBestFossilZone = val
    end
})

TabFossils:Toggle({
    Title = "Lock Position in Fossil Bed",
    Desc = "Stabilizes character position so mobs and physics never push you out.",
    Value = false,
    Callback = function(val)
        Config.LockInFossilBed = val
    end
})

TabFossils:Toggle({
    Title = "Auto Upgrade Fossil Stats",
    Desc = "Auto maxes FasterDigs (0.5s interval), MoreFossils, and FossilLuck.",
    Value = false,
    Callback = function(val)
        Config.AutoUpgradeFossilStats = val
    end
})

TabFossils:Button({
    Title = "Teleport to Selected Fossil Bed",
    Desc = "Instantly snaps your character into the center of the chosen fossil bed.",
    Callback = function()
        pcall(function()
            local targetZone = nil
            for _, z in ipairs(CollectionService:GetTagged("FossilZone")) do
                if z:GetAttribute("Set") == Config.SelectedFossilZone then
                    targetZone = z
                    break
                end
            end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetZone then
                hrp.CFrame = CFrame.new(targetZone.Position + Vector3.new(0, 3, 0))
                WindUI:Notify({
                    Title = "Fossil Bed Teleport",
                    Content = "Teleported to " .. Config.SelectedFossilZone .. " Fossil Bed.",
                    Duration = 2,
                    Icon = "map-pin",
                })
            else
                WindUI:Notify({
                    Title = "Teleport Error",
                    Content = "Fossil zone '" .. Config.SelectedFossilZone .. "' not found or room locked.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end)
    end
})

TabFossils:Section({ Title = "Live Fossil Telemetry" })

local FossilTelemetryParagraph = TabFossils:Paragraph({
    Title = "Fossil Digger Metrics",
    Desc = "Target: Dirt | Dig Speed: Calculating... | Total Dug: 0 | Bonus: 1.0x"
})

-- Telemetry update loop
task.spawn(function()
    while isScriptActive do
        task.wait(1.0)
        pcall(function()
            local dug = LocalPlayer:GetAttribute("FossilsDug") or 0
            local bonus = LocalPlayer:GetAttribute("FossilBonus") or 0
            local fd = LocalPlayer:GetAttribute("Up_FasterDigs") or 0
            local mf = LocalPlayer:GetAttribute("Up_MoreFossils") or 0
            local luck = LocalPlayer:GetAttribute("Up_FossilLuck") or 0

            local interval = PitConfig.DigInterval and PitConfig.DigInterval(fd) or 1
            local perRoll = PitConfig.DigsPerRoll and PitConfig.DigsPerRoll(mf) or 1
            local fossilsPerSec = perRoll / math.max(tonumber(interval) or 1, 0.1)

            local activeZone = Config.AutoSelectBestFossilZone and "(Auto Best)" or Config.SelectedFossilZone

            FossilTelemetryParagraph:SetDesc(string.format(
                "Active Zone: %s\n" ..
                "Dig Speed: %d fossils / %.1fs (~%.1f/sec)\n" ..
                "Total Fossils Dug: %s\n" ..
                "Cash Multiplier: +%.2fx\n" ..
                "Stats: FasterDigs Lv.%d | MoreFossils Lv.%d | Luck Lv.%d",
                activeZone,
                perRoll,
                interval,
                fossilsPerSec,
                PitConfig.Commas and PitConfig.Commas(dug) or tostring(dug),
                bonus,
                fd, mf, luck
            ))
        end)
    end
end)

-- ====================================================================
-- TAB 3: WORM FARM
-- ====================================================================
TabWorms:Section({ Title = "Worm Vacuum Engine" })

TabWorms:Toggle({
    Title = "Auto Collect Worms (Vacuum)",
    Desc = "Extracts spawned worms from client memory and sweeps them instantly.",
    Value = false,
    Callback = function(val)
        Config.AutoCollectWorms = val
    end
})

TabWorms:Dropdown({
    Title = "Worm Farm Mode",
    Desc = "Choose sweep behavior: Instant teleport sweep or proximity-only collect.",
    Values = { "Instant Sweep (Teleport)", "Proximity Only (Safe)" },
    Value = "Instant Sweep (Teleport)",
    Callback = function(val)
        Config.WormFarmMode = val
    end
})

TabWorms:Toggle({
    Title = "Auto Worm Rebirth",
    Desc = "Automatically triggers worm rebirth once requirements are reached.",
    Value = false,
    Callback = function(val)
        Config.AutoWormRebirth = val
    end
})

-- ====================================================================
-- TAB 4: BOSS SLAYER & COMBAT
-- ====================================================================
TabCombat:Section({ Title = "Boss Combat Automation" })

TabCombat:Toggle({
    Title = "Auto Boss Slayer (Fast Swing)",
    Desc = "Rapidly fires BossSwing remote to eliminate bosses in seconds.",
    Value = false,
    Callback = function(val)
        Config.AutoBossSlayer = val
    end
})

TabCombat:Slider({
    Title = "Boss Attack CPS",
    Desc = "Number of swings executed per second against active boss.",
    Min = 5,
    Max = 25,
    Default = 15,
    Step = 1,
    Callback = function(val)
        Config.BossSwingRate = val
    end
})

TabCombat:Toggle({
    Title = "Safe Boss Hover (Damage Immunity)",
    Desc = "Suspends character 15 studs safely above boss arena to avoid taking damage.",
    Value = false,
    Callback = function(val)
        Config.SafeBossHover = val
    end
})

TabCombat:Dropdown({
    Title = "Target Boss Selection",
    Desc = "Select boss to challenge and farm.",
    Values = { "Dirt", "Stone", "Spider", "Kraken", "FrostWyrm", "MushroomKing", "VoidEye", "SoulWarden", "GhostCaptain", "TitanSkull", "TectonicBeetle", "Ignaroth" },
    Value = "Dirt",
    Callback = function(val)
        Config.SelectedBoss = val
    end
})

TabCombat:Toggle({
    Title = "Auto Start Selected Boss",
    Desc = "Automatically triggers boss arena entry when ready.",
    Value = false,
    Callback = function(val)
        Config.AutoStartBoss = val
    end
})

TabCombat:Button({
    Title = "Challenge Selected Boss Now",
    Desc = "Fires BossStart for selected boss immediately.",
    Callback = function()
        pcall(function()
            PitRemotes.BossStart:FireServer(Config.SelectedBoss)
            WindUI:Notify({
                Title = "Boss Challenge",
                Content = "Started challenge for: " .. Config.SelectedBoss,
                Duration = 2,
                Icon = "swords",
            })
        end)
    end
})

TabCombat:Section({ Title = "Mining Automation" })

TabCombat:Toggle({
    Title = "Auto Mine Ore Veins",
    Desc = "Automatically hits and breaks nearby ore veins in the Mine room.",
    Value = false,
    Callback = function(val)
        Config.AutoMineVeins = val
    end
})

-- ====================================================================
-- TAB 5: PROGRESSION & SKILL TREES
-- ====================================================================
TabProgression:Section({ Title = "Skill Tree Automation" })

TabProgression:Toggle({
    Title = "Auto Buy Skill Tree Nodes",
    Desc = "Automatically unlocks all affordable nodes across Tree 1 - 15.",
    Value = false,
    Callback = function(val)
        Config.AutoBuyTrees = val
    end
})

TabProgression:Section({ Title = "Title Rolling & Equipping" })

TabProgression:Toggle({
    Title = "Auto Roll Titles",
    Desc = "Continuously rolls titles from the selected set whenever affordable.",
    Value = false,
    Callback = function(val)
        Config.AutoRollTitles = val
    end
})

TabProgression:Dropdown({
    Title = "Selected Title Set",
    Desc = "Choose title set to roll from.",
    Values = { "Dirt", "Spider", "Frost", "Void", "Pirate", "Core", "Hive", "Carnival", "Bakery" },
    Value = "Dirt",
    Callback = function(val)
        Config.SelectedTitleSet = val
    end
})

TabProgression:Toggle({
    Title = "Auto Equip Best Title",
    Desc = "Automatically equips the highest tier owned title.",
    Value = false,
    Callback = function(val)
        Config.AutoEquipBestTitle = val
    end
})

TabProgression:Section({ Title = "Pit Rebirth" })

TabProgression:Toggle({
    Title = "Auto Pit Rebirth",
    Desc = "Automatically triggers pit rebirth when layer requirements are met.",
    Value = false,
    Callback = function(val)
        Config.AutoRebirth = val
    end
})

-- ====================================================================
-- TAB 6: TELEPORTS & WAYPOINTS
-- ====================================================================
TabTeleport:Section({ Title = "Server Room Teleportation" })

local roomOptions = {
    "Surface", "Upgrades", "Fossils", "Worms", "Tree", "Titles", "Boss", 
    "StoneFossils", "Minecart", "DeepFossils", "TradingPost", "SpecialUpgrades", 
    "StoneBoss", "WebFossils", "Hatchery", "Tree2", "NestFossils", "Titles2", 
    "SpiderBoss", "LakeFossils", "FishingDock", "Tree3", "AbyssFossils", 
    "SpecialUpgrades2", "Kraken", "FrostFossils", "TradingPost2", "FrozenShrine", 
    "GlacierFossils", "Titles3", "FrostWyrm", "MushroomFarm", "SporeFossils", 
    "Tree4", "MyceliumFossils", "SpecialUpgrades3", "MushroomKing", "VoidFossils", 
    "ZeroG", "Tree5", "HallOfEchoes", "EclipseFossils", "Titles4", "VoidBoss", 
    "Graveyard", "CryptFossils", "Tree6", "BoneFossils", "SpecialUpgrades4", 
    "SoulReaper", "PlunderCove", "WreckFossils", "SmugglersDen", "SkullFossils", 
    "Titles5", "GhostCaptain", "MagmaMine", "CrustFossils", "Tree7", "Foundry", 
    "BasaltFossils", "CrustBoss", "Meltdown", "DeepVein", "ObsidianFossils", 
    "SpecialUpgrades5", "Titles6", "MantleBoss", "RollTheCore", "MoltenFossils", 
    "Tree8", "Enchanting", "HeartstoneFossils", "CoreExchange"
}

TabTeleport:Dropdown({
    Title = "Select Target Room",
    Desc = "Choose any unlocked room in the pit.",
    Values = roomOptions,
    Value = "Surface",
    Callback = function(val)
        Config.SelectedRoom = val
    end
})

TabTeleport:Button({
    Title = "Teleport to Selected Room",
    Desc = "Invokes server remote to instantly teleport your character.",
    Callback = function()
        pcall(function()
            PitRemotes.Teleport:FireServer(Config.SelectedRoom)
            WindUI:Notify({
                Title = "Teleport",
                Content = "Teleporting to " .. Config.SelectedRoom,
                Duration = 2,
                Icon = "map-pin",
            })
        end)
    end
})

TabTeleport:Section({ Title = "Step Positioning" })

TabTeleport:Button({
    Title = "Teleport to Current Lowest Step",
    Desc = "Teleports directly to your highest bought step in the pit.",
    Callback = function()
        pcall(function()
            local steps = LocalPlayer:GetAttribute("Steps") or 0
            local stepData = PitConfig.Steps[steps] or PitConfig.Entry
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and stepData then
                hrp.CFrame = CFrame.new(stepData.pos + Vector3.new(0, 3.5, 0))
            end
        end)
    end
})

TabTeleport:Input({
    Title = "Custom Step Number",
    Desc = "Enter specific step number to jump to.",
    Value = "1",
    Placeholder = "1 - 2000",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            Config.TargetStep = math.floor(num)
        end
    end
})

TabTeleport:Button({
    Title = "Teleport to Custom Step",
    Desc = "Teleports to the exact coordinates of the specified step.",
    Callback = function()
        pcall(function()
            local stepData = PitConfig.Steps[Config.TargetStep]
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and stepData then
                hrp.CFrame = CFrame.new(stepData.pos + Vector3.new(0, 3.5, 0))
            else
                WindUI:Notify({
                    Title = "Step Error",
                    Content = "Step " .. tostring(Config.TargetStep) .. " does not exist.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end)
    end
})

-- ====================================================================
-- TAB 7: MOVEMENT & PLAYER QOL
-- ====================================================================
TabPlayer:Section({ Title = "Character Modifiers" })

TabPlayer:Toggle({
    Title = "WalkSpeed Modifier",
    Desc = "Overrides default character walking speed.",
    Value = false,
    Callback = function(val)
        Config.SpeedEnabled = val
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and not val then
                hum.WalkSpeed = 16
            end
        end)
    end
})

TabPlayer:Slider({
    Title = "Speed Value",
    Desc = "Custom WalkSpeed value.",
    Min = 16,
    Max = 150,
    Default = 32,
    Step = 1,
    Callback = function(val)
        Config.SpeedValue = val
    end
})

TabPlayer:Toggle({
    Title = "JumpPower Modifier",
    Desc = "Overrides default character jump height.",
    Value = false,
    Callback = function(val)
        Config.JumpEnabled = val
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and not val then
                hum.JumpPower = 50
            end
        end)
    end
})

TabPlayer:Slider({
    Title = "Jump Power Value",
    Desc = "Custom JumpPower value.",
    Min = 50,
    Max = 250,
    Default = 60,
    Step = 5,
    Callback = function(val)
        Config.JumpValue = val
    end
})

TabPlayer:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in mid-air.",
    Value = false,
    Callback = function(val)
        Config.InfiniteJump = val
    end
})

TabPlayer:Toggle({
    Title = "Noclip",
    Desc = "Disables character collision with workspace geometry.",
    Value = false,
    Callback = function(val)
        Config.Noclip = val
    end
})

TabPlayer:Section({ Title = "Anti-AFK & Stability" })

TabPlayer:Toggle({
    Title = "Anti-AFK Engine",
    Desc = "Prevents 20-minute Roblox idle disconnect.",
    Value = false,
    Callback = function(val)
        Config.AntiAFK = val
    end
})

-- ====================================================================
-- TAB 8: CONFIG PROFILE MANAGER
-- ====================================================================
TabConfig:Section({ Title = "Profile Management" })

local currentProfileName = "default"

TabConfig:Input({
    Title = "Profile Name",
    Desc = "Enter profile name to save or load.",
    Value = "default",
    Placeholder = "Profile name...",
    Callback = function(val)
        if val and val:gsub("%s", "") ~= "" then
            currentProfileName = val
        end
    end
})

TabConfig:Button({
    Title = "Save Config",
    Desc = "Saves current configuration to local disk.",
    Callback = function()
        saveConfigFile(currentProfileName)
    end
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Loads specified profile from local disk.",
    Callback = function()
        loadConfigFile(currentProfileName)
    end
})

TabConfig:Button({
    Title = "Reset to Default (ALL OFF)",
    Desc = "Resets all features to default disabled state.",
    Callback = function()
        for k, _ in pairs(Config) do
            if type(Config[k]) == "boolean" then
                Config[k] = false
            end
        end
        WindUI:Notify({
            Title = "Config Reset",
            Content = "All features set to OFF.",
            Duration = 2,
            Icon = "rotate-ccw",
        })
    end
})

-- ====================================================================
-- BACKGROUND AUTOMATION LOOPS & ENGINES
-- ====================================================================

-- 1. FOSSIL DIGGER ENGINE (Autonomous Positioning + Auto Upgrade)
local function getBestAvailableFossilSet()
    for _, setName in ipairs(fossilPriorityOrder) do
        local f = PitConfig.Fossils and PitConfig.Fossils[setName]
        if f then
            local roomAttr = "Room_" .. (f.room or "Fossils")
            local isOwned = LocalPlayer:GetAttribute(roomAttr) == true
            local cur = LocalPlayer:GetAttribute(f.currency or "Cash") or 0
            if isOwned and cur >= f.cost then
                return setName
            end
        end
    end
    return "Dirt"
end

local function findFossilZonePart(setName)
    for _, z in ipairs(CollectionService:GetTagged("FossilZone")) do
        if z:GetAttribute("Set") == setName then
            return z
        end
    end
    return nil
end

task.spawn(function()
    while isScriptActive do
        if Config.AutoDigFossils then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local targetSetName = Config.AutoSelectBestFossilZone and getBestAvailableFossilSet() or Config.SelectedFossilZone
                local targetZone = findFossilZonePart(targetSetName)

                if targetZone then
                    local targetCFrame = CFrame.new(targetZone.Position + Vector3.new(0, 3, 0))
                    local dist = (hrp.Position - targetZone.Position).Magnitude

                    -- If not currently positioned in the dig zone, snap into it
                    if dist > 6 then
                        hrp.CFrame = targetCFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end

                    -- If position locking is enabled, keep character perfectly centered
                    if Config.LockInFossilBed then
                        hrp.CFrame = targetCFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end

                -- Auto buy fossil stats (FasterDigs, MoreFossils, FossilLuck)
                if Config.AutoUpgradeFossilStats then
                    PitRemotes.BuyUpgrade:FireServer("FasterDigs", true)
                    PitRemotes.BuyUpgrade:FireServer("MoreFossils", true)
                    PitRemotes.BuyUpgrade:FireServer("FossilLuck", true)
                end
            end)
            task.wait(0.5)
        else
            task.wait(1.0)
        end
    end
end)

-- 2. AUTO BUY STEPS ENGINE (World 1 & World 2)
task.spawn(function()
    while isScriptActive do
        if Config.AutoBuySteps then
            pcall(function()
                local curSteps = LocalPlayer:GetAttribute("Steps") or 0
                if Config.TargetStepLimit > 0 and curSteps >= Config.TargetStepLimit then
                    task.wait(0.5)
                    return
                end

                local nextStep = curSteps + 1
                local stepData = PitConfig.Steps[nextStep]
                if stepData and PitConfig.StepCurrency(nextStep) == "Cash" then
                    if not PitConfig.StepBlocked(LocalPlayer, nextStep) then
                        local price = PitConfig.Price(nextStep)
                        local discount = PitConfig.StepDiscount(LocalPlayer, nextStep)
                        local cost = math.floor(price * discount)
                        local cash = LocalPlayer:GetAttribute("Cash") or 0

                        if cash >= cost then
                            PitRemotes.BuyStep:FireServer(nextStep)
                        end
                    end
                end
            end)
            task.wait(Config.StepBuyDelay)
        else
            task.wait(0.3)
        end
    end
end)

-- World 2 Step Buying Loop
task.spawn(function()
    while isScriptActive do
        if Config.AutoBuyW2Steps then
            pcall(function()
                local curSteps = LocalPlayer:GetAttribute("W2Steps") or 0
                local nextStep = curSteps + 1
                if PitConfig.W2Steps and PitConfig.W2Steps[nextStep] then
                    if not PitConfig.W2StepBlocked(LocalPlayer, nextStep) then
                        local cost = PitConfig.W2Price(nextStep)
                        local bucks = LocalPlayer:GetAttribute("Bucks") or 0
                        if bucks >= cost then
                            PitRemotes.BuyW2Step:FireServer(nextStep)
                        end
                    end
                end
            end)
            task.wait(Config.StepBuyDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- 3. AUTO BUY UPGRADES ENGINE
task.spawn(function()
    while isScriptActive do
        if Config.AutoBuyAllUpgrades then
            pcall(function()
                for name, upg in pairs(PitConfig.Upgrades) do
                    if not isScriptActive or not Config.AutoBuyAllUpgrades then break end

                    local curTier = LocalPlayer:GetAttribute("Up_" .. name) or 0
                    if curTier < upg.max then
                        local curName = upg.currency or "Cash"
                        local passesFilter = (Config.UpgradeCategory == "All") or (curName == Config.UpgradeCategory)

                        if passesFilter then
                            local playerCur = LocalPlayer:GetAttribute(curName) or 0
                            local cost = PitConfig.UpgradeCost(name, curTier)
                            if playerCur >= cost then
                                PitRemotes.BuyUpgrade:FireServer(name, true)
                                task.wait(0.04)
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- 4. AUTO UNLOCK ROOMS ENGINE
task.spawn(function()
    while isScriptActive do
        if Config.AutoBuyRooms then
            pcall(function()
                local curSteps = LocalPlayer:GetAttribute("Steps") or 0
                for id, room in pairs(PitConfig.RoomById) do
                    local isOwned = LocalPlayer:GetAttribute("Room_" .. id) == true
                    if not isOwned and curSteps >= room.step then
                        local curName = room.currency or "Cash"
                        local playerCur = LocalPlayer:GetAttribute(curName) or 0
                        if playerCur >= room.price then
                            PitRemotes.BuyRoom:FireServer(id)
                            task.wait(0.1)
                        end
                    end
                end
            end)
            task.wait(1.0)
        else
            task.wait(1.0)
        end
    end
end)

-- 5. AUTO CLAIM DAILY HATCHERY EGGS
task.spawn(function()
    while isScriptActive do
        if Config.AutoClaimDailyEggs then
            pcall(function()
                if LocalPlayer:GetAttribute("Room_Hatchery") == true then
                    PitRemotes.EggClaim:FireServer()
                end
            end)
            task.wait(30)
        else
            task.wait(2)
        end
    end
end)

-- 6. WORM VACUUM ENGINE (Active Memory Extraction + Sweep)
task.spawn(function()
    while isScriptActive do
        if Config.AutoCollectWorms then
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local conns = getconnections(PitRemotes.WormSpawned.OnClientEvent)
                local wormsFound = {}

                for _, c in ipairs(conns) do
                    if c.Function then
                        local upvals = getupvalues(c.Function)
                        for _, val in pairs(upvals) do
                            if type(val) == "table" then
                                for k, v in pairs(val) do
                                    if type(v) == "table" and v.pos then
                                        table.insert(wormsFound, { id = k, pos = v.pos })
                                    end
                                end
                            end
                        end
                    end
                end

                if #wormsFound > 0 then
                    local originalPos = hrp.CFrame
                    for _, worm in ipairs(wormsFound) do
                        if not isScriptActive or not Config.AutoCollectWorms then break end

                        if Config.WormFarmMode == "Instant Sweep (Teleport)" then
                            hrp.CFrame = CFrame.new(worm.pos + Vector3.new(0, 2, 0))
                            task.wait(0.04)
                            PitRemotes.WormCollected:FireServer(worm.id)
                        else
                            local dist = (hrp.Position - worm.pos).Magnitude
                            if dist < 25 then
                                PitRemotes.WormCollected:FireServer(worm.id)
                            end
                        end
                    end

                    if Config.WormFarmMode == "Instant Sweep (Teleport)" and hrp then
                        hrp.CFrame = originalPos
                    end
                end
            end)
            task.wait(1.0)
        else
            task.wait(0.5)
        end
    end
end)

-- 7. AUTO WORM REBIRTH
task.spawn(function()
    while isScriptActive do
        if Config.AutoWormRebirth then
            pcall(function()
                if LocalPlayer:GetAttribute("WormRebirthsUnlocked") == true then
                    PitRemotes.WormRebirth:FireServer()
                end
            end)
            task.wait(5.0)
        else
            task.wait(1.0)
        end
    end
end)

-- 8. AUTO BOSS SLAYER & HOVER IMMUNITY
task.spawn(function()
    while isScriptActive do
        if Config.AutoBossSlayer then
            pcall(function()
                PitRemotes.BossSwing:FireServer()
            end)
            task.wait(1 / math.clamp(Config.BossSwingRate, 5, 30))
        else
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while isScriptActive do
        if Config.SafeBossHover then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bossModel = workspace:FindFirstChild("BossModel") or workspace:FindFirstChild("BossRig")
                    if bossModel then
                        local pivot = bossModel:GetPivot()
                        hrp.CFrame = CFrame.new(pivot.Position + Vector3.new(0, 18, 0))
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Start Boss Fight Loop
task.spawn(function()
    while isScriptActive do
        if Config.AutoStartBoss then
            pcall(function()
                PitRemotes.BossStart:FireServer(Config.SelectedBoss)
            end)
            task.wait(3.0)
        else
            task.wait(1.0)
        end
    end
end)

-- 9. AUTO MINE ORE VEINS
task.spawn(function()
    while isScriptActive do
        if Config.AutoMineVeins then
            pcall(function()
                local mineRem = PitRemotes:FindFirstChild("MineHit")
                if mineRem then
                    local mineFolder = workspace:FindFirstChild("MineVeins") or workspace:FindFirstChild("Veins")
                    if mineFolder then
                        for _, vein in ipairs(mineFolder:GetChildren()) do
                            local id = vein:GetAttribute("VeinId") or vein.Name
                            mineRem:FireServer(id)
                            task.wait(0.05)
                        end
                    end
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.5)
        end
    end
end)

-- 10. AUTO SKILL TREE NODES
task.spawn(function()
    while isScriptActive do
        if Config.AutoBuyTrees then
            pcall(function()
                for id, node in pairs(PitConfig.TreeById) do
                    if not isScriptActive or not Config.AutoBuyTrees then break end
                    local owned = LocalPlayer:GetAttribute("Tree_" .. id) == true
                    if not owned then
                        local curName = node.currency or "Cash"
                        local playerCur = LocalPlayer:GetAttribute(curName) or 0
                        if playerCur >= node.cost then
                            PitRemotes.BuyTreeNode:FireServer(id)
                            task.wait(0.05)
                        end
                    end
                end
            end)
            task.wait(1.5)
        else
            task.wait(1.0)
        end
    end
end)

-- 11. AUTO ROLL & EQUIP TITLES
task.spawn(function()
    while isScriptActive do
        if Config.AutoRollTitles then
            pcall(function()
                PitRemotes.RollTitle:FireServer(Config.SelectedTitleSet)
            end)
            task.wait(0.3)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while isScriptActive do
        if Config.AutoEquipBestTitle then
            pcall(function()
                local highestOwned = 0
                for i = 1, 200 do
                    local count = LocalPlayer:GetAttribute("Title_" .. i) or 0
                    if count > 0 then
                        highestOwned = i
                    end
                end
                if highestOwned > 0 and LocalPlayer:GetAttribute("EquippedTitle") ~= highestOwned then
                    PitRemotes.EquipTitle:FireServer(highestOwned)
                end
            end)
            task.wait(2.0)
        else
            task.wait(1.0)
        end
    end
end)

-- 12. AUTO PIT REBIRTH
task.spawn(function()
    while isScriptActive do
        if Config.AutoRebirth then
            pcall(function()
                local curRebirths = LocalPlayer:GetAttribute("Rebirths") or 0
                local nextRebirth = curRebirths + 1
                local data = PitConfig.Rebirths[nextRebirth]
                if data then
                    local steps = LocalPlayer:GetAttribute("Steps") or 0
                    local cash = LocalPlayer:GetAttribute("Cash") or 0
                    if steps >= (data.cost or 0) and cash >= (data.cash or 0) then
                        PitRemotes.Rebirth:FireServer()
                    end
                end
            end)
            task.wait(3.0)
        else
            task.wait(1.0)
        end
    end
end)

-- 13. MOVEMENT MODIFIERS (WalkSpeed & JumpPower)
RunService.Heartbeat:Connect(function()
    if not isScriptActive then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.SpeedEnabled then
            hum.WalkSpeed = Config.SpeedValue
        end
        if Config.JumpEnabled then
            hum.JumpPower = Config.JumpValue
        end
    end

    if Config.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if isScriptActive and Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 14. ANTI-AFK ENGINE
LocalPlayer.Idled:Connect(function()
    if isScriptActive and Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)

-- Notify user on successful suite initialization
WindUI:Notify({
    Title = "Depth Incremental Elite",
    Content = "Automation Suite loaded. Press LeftControl to toggle UI.",
    Duration = 4,
    Icon = "check-circle",
})
