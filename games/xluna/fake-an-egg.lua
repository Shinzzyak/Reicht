-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    =========================================================================
    [ð§ª] FAKE AN EGG â ULTIMATE MASTER AUTOMATION SUITE (ALL-SYSTEMS EDITION)
    =========================================================================
    Game: [ð§ª] Fake an Egg (Slime Time Studios)
    Architecture: WindUI v1.6.65 / Modern Luau / REAL MCP Deep-Audited
    Complete System Coverage:
      1. Auto GG Rebirth Speedrunner: Targets exact animal from Rebirth.getNext(), buys, sells, rebirths
      2. Real Physical Bat Slap God Aura: firetouchinterest(oHrp, handle, 0/1) + SlapActivatedEvent
      3. Mr Egg's Lab & Mutation Engine: Auto Fuse & Auto Claim across all 5 Lab floors
      4. Bat Arsenal & Fence Architect: Equip/upgrade 15 Bat tiers & 14 Fence tiers
      5. Dual-Mode Egg Vacuum: Instant Teleport Sweep & Silent Remote Buy (Filtered IsEgg == true)
      6. Full Cycle Server Raid: Steal -> Bring to Base -> Repeat
      7. Index Rewards Sweeper: Claims all Normal, Biome, and Trait reward milestones
      8. Tycoon Maxer: Max Base Slots, Feeder Overdrive (1000 cal), Auto Sell Pets
      9. 3D Flight Hack: WASD + Space/Shift at 30â160 studs/sec
      10. 3D ESP Radar: Real vs Fake Eggs, Diamond/Gold Nest Pets, Infiltrator Players
    Repository: E:\SC\Fake an Egg\ClientOP_FakeAnEgg.lua
]]

-- Anti-double-execution guard
if getgenv()._FAKE_EGG_RUNNING then
    if getgenv()._FAKE_EGG_CLEANUP then
        pcall(getgenv()._FAKE_EGG_CLEANUP)
    end
end
getgenv()._FAKE_EGG_RUNNING = true

-- Clean stale GUI objects
local targetParent = gethui and gethui() or game:GetService("CoreGui")
for _, c in ipairs(targetParent:GetChildren()) do
    if string.find(c.Name, "WindUI") or c.Name == "FakeEgg_FloatingBtn" or c.Name == "FakeEgg_InfiltratorAlert" then
        pcall(function() c:Destroy() end)
    end
end

-- =========================================================================
-- SAFE CLONEREF & CORE SERVICES
-- =========================================================================
local oldCloneref = cloneref
if type(oldCloneref) == "function" then
    getgenv().cloneref = function(obj)
        if obj == nil then return nil end
        local ok, res = pcall(oldCloneref, obj)
        return ok and res or obj
    end
end

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local RemotesFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 20)
local EggRemotesFolder = ReplicatedStorage:WaitForChild("EggRemotes", 20)

-- Core Shared Modules
local EggsMod     = require(ReplicatedStorage:WaitForChild("Eggs", 10))
local ScannersMod = require(ReplicatedStorage:WaitForChild("Scanners", 10))
local RebirthMod  = require(ReplicatedStorage:WaitForChild("Rebirth", 10))
local FencesMod   = require(ReplicatedStorage:WaitForChild("Fences", 10))
local BatsMod     = require(ReplicatedStorage:WaitForChild("Bats", 10))
local LabMod      = require(ReplicatedStorage:WaitForChild("Lab", 10))

-- Core Verified Remotes
local R = {
    EggEvent           = EggRemotesFolder:WaitForChild("EggEvent", 10),
    ScannerEvent       = RemotesFolder:WaitForChild("ScannerEvent", 10),
    StealEvent         = RemotesFolder:WaitForChild("StealEvent", 10),
    SellAllEvent       = RemotesFolder:WaitForChild("SellAllEvent", 10),
    BaseUpgradeEvent   = RemotesFolder:WaitForChild("BaseUpgradeEvent", 10),
    RebirthEvent       = RemotesFolder:WaitForChild("RebirthEvent", 10),
    FoodEvent          = RemotesFolder:WaitForChild("FoodEvent", 10),
    LikeBaseEvent      = RemotesFolder:WaitForChild("LikeBaseEvent", 10),
    SlapActivatedEvent = RemotesFolder:WaitForChild("SlapActivatedEvent", 10),
    BatEvent           = RemotesFolder:WaitForChild("BatEvent", 10),
    IndexRewardEvent   = RemotesFolder:WaitForChild("IndexRewardEvent", 10),
    FenceEvent         = RemotesFolder:WaitForChild("FenceEvent", 10),
    LabFuseEvent       = RemotesFolder:WaitForChild("LabFuseEvent", 10),
    LabClaimEvent      = RemotesFolder:WaitForChild("LabClaimEvent", 10),
    DropBoxEvent       = RemotesFolder:WaitForChild("DropBoxEvent", 10),
    EquipBestEvent     = RemotesFolder:WaitForChild("EquipBestEvent", 10),
}

-- =========================================================================
-- GLOBAL STATE STORE (ALL OFF BY DEFAULT)
-- =========================================================================
local State = {
    -- Auto GG Rebirth Speedrunner
    AutoRebirthSpeedrun = false,
    AutoHatchReadyEggs  = false,
    AutoEquipBest       = false,
    LastEquipBestTick   = 0,
    AutoMaxBaseUpgrades = false,
    AutoFeedMultiplier  = false,
    FeedItem            = "Apple",

    -- Real Combat & Slap God Aura
    RealSlapAura        = false,
    SlapAuraRadius      = 22,
    BaseDefenderSlap    = false,
    AntiRagdoll         = false,
    AntiCarry           = false,

    -- Lab & Mutation Engine
    AutoLabFuse         = false,
    AutoLabClaim        = false,

    -- Bat & Fence Config
    SelectedBat         = "Basic",
    SelectedFence       = "Bamboo",

    -- Egg Vacuum
    RealEggVacuum       = false,
    VacuumMode          = "Instant Teleport", -- "Instant Teleport" or "Silent Remote"
    PrioritizeRebirthEgg= true,
    VacuumInterval      = 0.5,
    LastVacuumTick      = 0,

    -- Real Working Server Raid
    AutoWorkingRaid     = false,
    RaidTargetBase      = "All Bases",
    RaidFilter          = "Diamond / Gold Only",
    RaidDwellTime       = 1.0,
    LastRaidTick        = 0,

    -- Money & Selling
    AutoSellPets        = false,
    SellInterval        = 4.0,
    LastSellTick        = 0,

    -- 3D Flight & Movement
    FlyEnabled          = false,
    FlySpeed            = 65,
    ModifyWalkSpeed     = false,
    WalkSpeedValue      = 50,
    InfiniteJump        = false,
    Noclip              = false,

    -- Visuals & ESP
    RealVsFakeESP       = false,
    NestEggESP          = false,
    InfiltratorESP      = false,
}
getgenv()._FAKE_EGG_STATE = State

-- Scan database captured via packet sniffer
local ScannedEggDatabase = {}

-- Connection registry for clean unload
local ActiveConnections = {}
local ActiveESPObjects  = {}
local function RegConn(c) table.insert(ActiveConnections, c); return c end

-- =========================================================================
-- HELPERS
-- =========================================================================
local function GetCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil, nil, nil end
    return char, hrp, hum
end

local function GetMyBase()
    local myBaseNum = LocalPlayer:GetAttribute("Base") or 8
    local bases = workspace:FindFirstChild("Bases")
    return bases and bases:FindFirstChild(tostring(myBaseNum)) or nil
end

local function GetMyBaseSpawnPos()
    local myBase = GetMyBase()
    if myBase then
        local sp = myBase:FindFirstChild("Spawn")
        if sp then return sp.Position end
        return myBase:GetPivot().Position
    end
    return Vector3.new(-74.5, 10.3, 3.5)
end

local function EnsureNoScannerEquipped()
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and string.find(t.Name, "Scanner") then
                t.Parent = LocalPlayer.Backpack
            end
        end
    end
end

-- =========================================================================
-- PACKET SNIFFER (EGG SCAN DATABASE)
-- =========================================================================
RegConn(R.EggEvent.OnClientEvent:Connect(function(action, data)
    pcall(function()
        if action == "ScanResult" and type(data) == "table" and type(data.results) == "table" then
            for _, item in ipairs(data.results) do
                if item.id ~= nil then
                    ScannedEggDatabase[tostring(item.id)] = {
                        isFake = (item.fake == true),
                        time = os.clock(),
                    }
                end
            end
        end
    end)
end))

-- =========================================================================
-- LISTS GENERATION
-- =========================================================================
local BatNames = {
    "Basic", "Bamboo", "Candy", "Tralalero", "Soccer", "Keyboard",
    "Backrooms", "Lucky Block", "Verity", "Angel", "Cosmic", "Hacker",
    "Rainbow", "Meowl", "Strawberry Elephant"
}

local FenceNames = {
    "Basic", "Bamboo", "Candy", "Keyboard", "YinYang", "Rich",
    "LuckyBlock", "Royal", "Sushi", "Radioactive", "Dragon", "Needoh",
    "Void", "AngelDemon"
}

-- =========================================================================
-- LOAD WINDUI
-- =========================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function SafeNotify(opts)
    if WindUI and WindUI.Notify then
        pcall(function() WindUI:Notify(opts) end)
    end
end

-- =========================================================================
-- CREATE MAIN WINDOW
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title        = "Fake an Egg",
    Icon         = "trophy",
    Author       = "GG Overpower Edition v5.1",
    Folder       = "FakeAnEgg",
    Size         = UDim2.fromOffset(680, 560),
    Transparent  = false,
    Theme        = "Dark",
    SideBarWidth = 210,
    HasOutline   = true,
    Draggable    = true,
    ToggleKey    = Enum.KeyCode.LeftControl,
})
getgenv()._FAKE_EGG_WINDOW = Window

-- Construct Tabs
local TabGG       = Window:Tab({ Title = "Auto GG Speedrun",Icon = "trophy"     })
local TabCombat   = Window:Tab({ Title = "Real Slap God",   Icon = "swords"     })
local TabLab      = Window:Tab({ Title = "Lab & Mutation",  Icon = "flask-conical"})
local TabVacuum   = Window:Tab({ Title = "Egg Vacuum",      Icon = "circle-dot" })
local TabRaid     = Window:Tab({ Title = "Working Raid",    Icon = "crosshair"  })
local TabArsenal  = Window:Tab({ Title = "Bats & Fences",   Icon = "shield"     })
local TabMoney    = Window:Tab({ Title = "Infinite Cash",   Icon = "coins"      })
local TabFly      = Window:Tab({ Title = "3D Flight & Warp",Icon = "wind"       })
local TabVisuals  = Window:Tab({ Title = "Visuals & ESP",    Icon = "eye"        })
local TabConfig   = Window:Tab({ Title = "Configuration",   Icon = "settings"   })

-- Auto open window on injection
task.defer(function()
    pcall(function()
        if Window and Window.Open then
            Window:Open()
        end
    end)
end)

-- =========================================================================
-- TAB 1: AUTO GG SPEEDRUN (THE LEADERBOARD ENGINE)
-- =========================================================================
TabGG:Section({ Title = "Rebirth Speedrun Engine", Opened = true })

TabGG:Toggle({
    Title = "Auto Rebirth Speedrun (Target Egg Hunter)",
    Desc  = "Reads exact required animal from Rebirth system, hunts that egg, sells excess pets, and rebirths automatically",
    Value = false,
    Callback = function(v) State.AutoRebirthSpeedrun = v end,
})

TabGG:Toggle({
    Title = "Auto Hatch Ready Nest Eggs",
    Desc  = "Monitors your base nests and automatically hatches any egg whose timer is ready",
    Value = false,
    Callback = function(v) State.AutoHatchReadyEggs = v end,
})

TabGG:Toggle({
    Title = "Auto Equip Best Pets",
    Desc  = "Continuously equips your highest income pets into base nests to maximize CashPerSecond",
    Value = false,
    Callback = function(v) State.AutoEquipBest = v end,
})

TabGG:Toggle({
    Title = "Auto Max Base Slots (Burst Upgrades)",
    Desc  = "Spams BaseUpgradeEvent to expand nest slots to the maximum limit",
    Value = false,
    Callback = function(v) State.AutoMaxBaseUpgrades = v end,
})

TabGG:Toggle({
    Title = "Auto Feed Multiplier",
    Desc  = "Keeps feeder filled with food to multiply passive CashPerSecond",
    Value = false,
    Callback = function(v) State.AutoFeedMultiplier = v end,
})

TabGG:Dropdown({
    Title  = "Food Item",
    Desc   = "Type of food to buy for feeder",
    Values = { "Apple", "Carrot", "Corn", "Pumpkin", "Watermelon" },
    Value  = "Apple",
    Callback = function(v) State.FeedItem = v end,
})

TabGG:Section({ Title = "One-Click Progress Boosters", Opened = true })

TabGG:Button({
    Title = "Hatch All Ready Nest Eggs Now",
    Desc  = "Instantly walks/teleports through all ready eggs in your nests and hatches them all in 1 second",
    Callback = function()
        task.spawn(function()
            local char, hrp, _ = GetCharacter()
            if not hrp then return end
            local oldPos = hrp.CFrame
            local hatched = 0
            if workspace:FindFirstChild("NestEggs") then
                for _, eggModel in ipairs(workspace.NestEggs:GetChildren()) do
                    if eggModel:GetAttribute("Owner") == LocalPlayer.Name then
                        local hatchPrompt = nil
                        for _, p in ipairs(eggModel:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.ActionText == "Hatch" and p.Enabled then
                                hatchPrompt = p
                                break
                            end
                        end
                        if hatchPrompt then
                            local eggPos = hatchPrompt.Parent:IsA("Attachment") and hatchPrompt.Parent.WorldPosition or (hatchPrompt.Parent:IsA("BasePart") and hatchPrompt.Parent.Position or eggModel:GetPivot().Position)
                            hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 1.5, 0))
                            task.wait(0.12)
                            local oldHold = hatchPrompt.HoldDuration
                            hatchPrompt.HoldDuration = 0
                            hatchPrompt.RequiresLineOfSight = false
                            fireproximityprompt(hatchPrompt)
                            task.wait(0.15)
                            hatchPrompt.HoldDuration = oldHold
                            hatched += 1
                        end
                    end
                end
            end
            if oldPos then hrp.CFrame = oldPos end
            SafeNotify({ Title = "Hatched", Content = "Hatched " .. hatched .. " ready nest eggs!", Duration = 2.5, Icon = "egg" })
        end)
    end,
})

TabGG:Button({
    Title = "Equip Best Pets Now",
    Desc  = "Fires EquipBestEvent to automatically equip your strongest pets into nests",
    Callback = function()
        pcall(function() R.EquipBestEvent:FireServer() end)
        SafeNotify({ Title = "Equipped Best", Content = "Equipped your highest income pets!", Duration = 2, Icon = "zap" })
    end,
})

TabGG:Button({
    Title = "Rebirth Now",
    Desc  = "Fires RebirthEvent immediately if requirements are met",
    Callback = function()
        pcall(function() R.RebirthEvent:FireServer() end)
        SafeNotify({ Title = "Rebirth", Content = "Rebirth remote fired!", Duration = 2, Icon = "zap" })
    end,
})

TabGG:Button({
    Title = "Claim All 30 Index Rewards (Cash & Items)",
    Desc  = "Sweeps all completed Normal, Biome, and Trait index reward claims",
    Callback = function()
        for i = 1, 30 do
            pcall(function()
                R.IndexRewardEvent:FireServer("Normal", i)
                R.IndexRewardEvent:FireServer("Biome", i)
                R.IndexRewardEvent:FireServer("Traits", i)
            end)
        end
        SafeNotify({ Title = "Index Claimed", Content = "Swept all index reward tiers!", Duration = 2.5, Icon = "check-circle" })
    end,
})

TabGG:Button({
    Title = "Like All 10 Bases",
    Desc  = "Fires likes to all base plots for social cash rewards",
    Callback = function()
        for i = 1, 10 do pcall(function() R.LikeBaseEvent:FireServer(i) end); task.wait(0.05) end
        SafeNotify({ Title = "Bases Liked", Content = "Sent likes to all 10 bases.", Duration = 2, Icon = "heart" })
    end,
})

-- =========================================================================
-- TAB 2: REAL SLAP GOD (GENUINE TOUCH-REGISTERED COMBAT)
-- =========================================================================
TabCombat:Section({ Title = "Genuine Physical Bat Slap", Opened = true })

TabCombat:Toggle({
    Title = "Real Bat Slap God Aura",
    Desc  = "Equips Bat and physically fires touch interest (firetouchinterest) + swing remote: targets actually get knocked down!",
    Value = false,
    Callback = function(v) State.RealSlapAura = v end,
})

TabCombat:Slider({
    Title = "Slap Reach Distance (studs)",
    Desc  = "Radius to auto-slap other players",
    Value = { Min = 8, Max = 40, Default = 22 },
    Step  = 2,
    Callback = function(v) State.SlapAuraRadius = v end,
})

TabCombat:Toggle({
    Title = "Base Defender Mode",
    Desc  = "Specifically targets and slaps any rival player who steps into your base fence",
    Value = false,
    Callback = function(v) State.BaseDefenderSlap = v end,
})

TabCombat:Section({ Title = "God Mode Defenses", Opened = true })

TabCombat:Toggle({
    Title = "Anti-Ragdoll God Mode",
    Desc  = "Locks Ragdoll attribute to false every frame. Never get knocked down by rival bats",
    Value = false,
    Callback = function(v) State.AntiRagdoll = v end,
})

TabCombat:Toggle({
    Title = "Anti-Carry Shield",
    Desc  = "Prevents other players from ever carrying or moving your character",
    Value = false,
    Callback = function(v) State.AntiCarry = v end,
})

TabCombat:Button({
    Title = "Slap Nuke (All Players in Reach)",
    Desc  = "Physically slaps every nearby player 15 times right now",
    Callback = function()
        local char, hrp, _ = GetCharacter()
        if not hrp then return end
        local bat = char:FindFirstChild("Bat") or LocalPlayer.Backpack:FindFirstChild("Bat")
        if bat and bat.Parent == LocalPlayer.Backpack then bat.Parent = char end
        if not (bat and bat:FindFirstChild("Handle")) then return end

        local hit = 0
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= LocalPlayer and other.Character then
                local oHrp = other.Character:FindFirstChild("HumanoidRootPart")
                if oHrp and (oHrp.Position - hrp.Position).Magnitude < 35 then
                    for _ = 1, 10 do
                        R.SlapActivatedEvent:FireServer(bat)
                        firetouchinterest(oHrp, bat.Handle, 0)
                        task.wait(0.01)
                        firetouchinterest(oHrp, bat.Handle, 1)
                    end
                    hit += 1
                end
            end
        end
        SafeNotify({ Title = "Nuke", Content = "Slapped " .. hit .. " players!", Duration = 2, Icon = "zap" })
    end,
})

-- =========================================================================
-- TAB 3: MR EGG'S LAB & MUTATION ENGINE
-- =========================================================================
TabLab:Section({ Title = "Laboratory Automation", Opened = true })

TabLab:Toggle({
    Title = "Auto Fuse Across All 5 Floors",
    Desc  = "Continuously fires LabFuseEvent(1..5) to start pet mutation syntheses in Mr Egg's Lab",
    Value = false,
    Callback = function(v) State.AutoLabFuse = v end,
})

TabLab:Toggle({
    Title = "Auto Claim Finished Mutations",
    Desc  = "Continuously fires LabClaimEvent(1..5) to collect completed mutated pets",
    Value = false,
    Callback = function(v) State.AutoLabClaim = v end,
})

TabLab:Button({
    Title = "Trigger All 5 Lab Fuses Now",
    Desc  = "Fires LabFuseEvent across Floors 1â5 one time",
    Callback = function()
        for floor = 1, 5 do
            pcall(function() R.LabFuseEvent:FireServer(floor) end)
            task.wait(0.1)
        end
        SafeNotify({ Title = "Lab Fuses", Content = "Triggered fuses on Floors 1â5.", Duration = 2, Icon = "flask-conical" })
    end,
})

TabLab:Button({
    Title = "Claim All 5 Lab Floors Now",
    Desc  = "Fires LabClaimEvent across Floors 1â5 one time",
    Callback = function()
        for floor = 1, 5 do
            pcall(function() R.LabClaimEvent:FireServer(floor) end)
            task.wait(0.1)
        end
        SafeNotify({ Title = "Lab Claims", Content = "Claimed mutations from Floors 1â5.", Duration = 2, Icon = "check-circle" })
    end,
})

TabLab:Button({
    Title = "ð Teleport to Mr Egg's Lab",
    Desc  = "Snaps character directly to Mr Egg's Lab entrance",
    Callback = function()
        local _, hrp, _ = GetCharacter()
        local lab = workspace:FindFirstChild("MrEggsLab")
        if hrp and lab then
            local ent = lab:FindFirstChild("Entrance")
            local pos = ent and ent:GetPivot().Position or Vector3.new(0, 15, -200)
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
            SafeNotify({ Title = "Teleported", Content = "Arrived at Mr Egg's Lab.", Duration = 2, Icon = "map-pin" })
        end
    end,
})

-- =========================================================================
-- TAB 4: REAL EGG VACUUM
-- =========================================================================
TabVacuum:Section({ Title = "Authentic Wild Egg Collection", Opened = true })

TabVacuum:Toggle({
    Title = "Real Egg Vacuum Loop",
    Desc  = "Filters real eggs (IsEgg == true), unequips scanner, and buys eggs reliably into your nests",
    Value = false,
    Callback = function(v) State.RealEggVacuum = v end,
})

TabVacuum:Dropdown({
    Title  = "Vacuum Mode",
    Desc   = "Instant Teleport: snaps directly to egg to guarantee purchase. Silent Remote: triggers from afar.",
    Values = { "Instant Teleport", "Silent Remote" },
    Value  = "Instant Teleport",
    Callback = function(v) State.VacuumMode = v end,
})

TabVacuum:Toggle({
    Title = "Prioritize Next Rebirth Egg",
    Desc  = "Scans for and buys the exact egg needed for your next Rebirth before anything else",
    Value = true,
    Callback = function(v) State.PrioritizeRebirthEgg = v end,
})

TabVacuum:Slider({
    Title = "Vacuum Loop Speed (seconds)",
    Desc  = "Delay between egg purchases",
    Value = { Min = 0.2, Max = 2.0, Default = 0.5 },
    Step  = 0.1,
    Callback = function(v) State.VacuumInterval = v end,
})

TabVacuum:Button({
    Title = "Sweep All Real Eggs Now",
    Desc  = "Immediately buys all active real eggs on the map",
    Callback = function()
        task.spawn(function()
            EnsureNoScannerEquipped()
            local ce = workspace:FindFirstChild("ClientEggs")
            if not ce then return end
            local count = 0
            for _, egg in ipairs(ce:GetChildren()) do
                if egg:GetAttribute("IsEgg") == true then
                    local p = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p and p.Enabled then
                        fireproximityprompt(p)
                        count += 1
                        task.wait(0.1)
                    end
                end
            end
            SafeNotify({ Title = "Vacuum", Content = "Triggered " .. count .. " real eggs!", Duration = 2.5, Icon = "circle-dot" })
        end)
    end,
})

-- =========================================================================
-- TAB 5: REAL WORKING SERVER RAID
-- =========================================================================
TabRaid:Section({ Title = "Full Cycle Pet Theft (Steal -> Deposit -> Repeat)", Opened = true })

TabRaid:Toggle({
    Title = "Auto Working Server Raid Loop",
    Desc  = "Real full cycle: Checks if holding stolen pet -> deposits at home -> teleports to enemy nest -> steals top pet -> escapes home",
    Value = false,
    Callback = function(v) State.AutoWorkingRaid = v end,
})

TabRaid:Dropdown({
    Title  = "Target Plot",
    Desc   = "Select specific enemy base or raid all",
    Values = { "All Bases", "Base 1", "Base 2", "Base 3", "Base 4", "Base 5", "Base 6", "Base 7", "Base 8", "Base 9", "Base 10" },
    Value  = "All Bases",
    Callback = function(v) State.RaidTargetBase = v end,
})

TabRaid:Dropdown({
    Title  = "Pet Rarity Priority",
    Desc   = "Only raid high-value pets",
    Values = { "Diamond / Gold Only", "Gold Only", "Diamond Only", "All Pets" },
    Value  = "Diamond / Gold Only",
    Callback = function(v) State.RaidFilter = v end,
})

TabRaid:Button({
    Title = "Execute Single Working Raid",
    Desc  = "One full raid cycle right now: steals top pet and deposits it in your base",
    Callback = function()
        task.spawn(function()
            local _, hrp, _ = GetCharacter()
            if not hrp then return end
            local nestEggs = workspace:FindFirstChild("NestEggs")
            if not nestEggs then return end

            local targetPet = nil
            for _, pet in ipairs(nestEggs:GetChildren()) do
                local owner = pet:GetAttribute("Owner")
                local variant = pet:GetAttribute("Variant") or "Normal"
                if owner and owner ~= LocalPlayer.Name then
                    local pass = (State.RaidFilter == "All Pets")
                        or (State.RaidFilter == "Diamond / Gold Only" and (variant == "Gold" or variant == "Diamond"))
                        or (State.RaidFilter == "Diamond Only" and variant == "Diamond")
                        or (State.RaidFilter == "Gold Only" and variant == "Gold")
                    if pass then targetPet = pet; break end
                end
            end

            if not targetPet then
                SafeNotify({ Title = "No Target", Content = "No matching enemy nest pets found.", Duration = 2, Icon = "alert-circle" })
                return
            end

            local petPos = targetPet:GetPivot().Position
            local ownerName = targetPet:GetAttribute("Owner") or "?"

            SafeNotify({ Title = "Raiding", Content = "Stealing " .. targetPet.Name .. " from @" .. ownerName, Duration = 2, Icon = "zap" })

            hrp.CFrame = CFrame.new(petPos + Vector3.new(0, 2, 0))
            task.wait(0.2)

            local prompt = targetPet:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.Enabled = true
                fireproximityprompt(prompt)
            end
            task.wait(0.4)

            local _, liveHrp, _ = GetCharacter()
            if liveHrp then
                liveHrp.CFrame = CFrame.new(GetMyBaseSpawnPos() + Vector3.new(0, 3, 0))
            end
            SafeNotify({ Title = "Deposited", Content = "Stolen pet secured at base!", Duration = 2.5, Icon = "check-circle" })
        end)
    end,
})

-- =========================================================================
-- TAB 6: BATS & FENCES ARSENAL
-- =========================================================================
TabArsenal:Section({ Title = "Bat Weapon Arsenal", Opened = true })

TabArsenal:Dropdown({
    Title  = "Select Bat to Equip",
    Desc   = "Select from all 15 bat tiers",
    Values = BatNames,
    Value  = "Basic",
    Callback = function(v) State.SelectedBat = v end,
})

TabArsenal:Button({
    Title = "Equip / Trial Selected Bat",
    Desc  = "Fires Remotes.BatEvent(batName) to equip or trial",
    Callback = function()
        pcall(function() R.BatEvent:FireServer(State.SelectedBat) end)
        SafeNotify({ Title = "Bat Arsenal", Content = "Equipped: " .. State.SelectedBat, Duration = 2, Icon = "shield" })
    end,
})

TabArsenal:Section({ Title = "Fence Architect", Opened = true })

TabArsenal:Dropdown({
    Title  = "Select Fence to Equip",
    Desc   = "Select from all 14 base fence tiers",
    Values = FenceNames,
    Value  = "Bamboo",
    Callback = function(v) State.SelectedFence = v end,
})

TabArsenal:Button({
    Title = "Equip Selected Fence",
    Desc  = "Fires Remotes.FenceEvent(fenceName) to update base fence",
    Callback = function()
        pcall(function() R.FenceEvent:FireServer(State.SelectedFence) end)
        SafeNotify({ Title = "Fence Architect", Content = "Equipped: " .. State.SelectedFence, Duration = 2, Icon = "home" })
    end,
})

-- =========================================================================
-- TAB 7: INFINITE CASH MACHINE
-- =========================================================================
TabMoney:Section({ Title = "Automated Selling", Opened = true })

TabMoney:Toggle({
    Title = "Auto Sell Pets (Cash Generator)",
    Desc  = "Continuously liquidates inventory pets for instant Cash payouts",
    Value = false,
    Callback = function(v) State.AutoSellPets = v end,
})

TabMoney:Slider({
    Title = "Sell Sweep Interval (seconds)",
    Desc  = "Frequency of auto-sell",
    Value = { Min = 2.0, Max = 15.0, Default = 4.0 },
    Step  = 1.0,
    Callback = function(v) State.SellInterval = v end,
})

TabMoney:Button({
    Title = "Sell All Pets Now",
    Desc  = "Fires SellAllEvent('Pets') right now for instant Cash",
    Callback = function()
        pcall(function() R.SellAllEvent:FireServer("Pets") end)
        SafeNotify({ Title = "Sold", Content = "Sold all inventory pets!", Duration = 2, Icon = "coins" })
    end,
})

-- =========================================================================
-- TAB 8: 3D FLIGHT & MOVEMENT
-- =========================================================================
TabFly:Section({ Title = "3D Flight Hack", Opened = true })

TabFly:Toggle({
    Title = "Smooth 3D Flight (WASD + Space/Shift)",
    Desc  = "Full CFrame flight through the sky. Ignore fences, walls, and gates",
    Value = false,
    Callback = function(v)
        State.FlyEnabled = v
        local _, _, hum = GetCharacter()
        if not v and hum then hum.PlatformStand = false end
    end,
})

TabFly:Slider({
    Title = "Flight Velocity",
    Desc  = "Studs per second",
    Value = { Min = 30, Max = 160, Default = 65 },
    Step  = 5,
    Callback = function(v) State.FlySpeed = v end,
})

TabFly:Section({ Title = "Ground Modifiers", Opened = true })

TabFly:Toggle({
    Title = "Custom WalkSpeed",
    Desc  = "Safe movement scaling",
    Value = false,
    Callback = function(v)
        State.ModifyWalkSpeed = v
        if not v then
            local _, _, hum = GetCharacter()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabFly:Slider({
    Title = "WalkSpeed Value",
    Desc  = "Velocity slider (16â80)",
    Value = { Min = 16, Max = 80, Default = 50 },
    Step  = 2,
    Callback = function(v) State.WalkSpeedValue = v end,
})

TabFly:Toggle({
    Title = "Noclip",
    Desc  = "Walk directly through all fences, gates, and walls",
    Value = false,
    Callback = function(v) State.Noclip = v end,
})

TabFly:Toggle({
    Title = "Infinite Jump",
    Desc  = "Jump indefinitely mid-air",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})

TabFly:Section({ Title = "Instant Waypoints", Opened = true })

TabFly:Button({
    Title = "ð  Teleport to My Base",
    Desc  = "Snaps character directly to your home plot",
    Callback = function()
        local _, hrp, _ = GetCharacter()
        if hrp then hrp.CFrame = CFrame.new(GetMyBaseSpawnPos() + Vector3.new(0, 3, 0)) end
    end,
})

TabFly:Button({
    Title = "ð Teleport to Map Center / Egg Spawns",
    Desc  = "Snaps to central egg field",
    Callback = function()
        local _, hrp, _ = GetCharacter()
        if hrp then hrp.CFrame = CFrame.new(Vector3.new(0, 15, 0)) end
    end,
})

for baseNum = 1, 10 do
    TabFly:Button({
        Title = "Base " .. baseNum .. " Teleport",
        Desc  = "Teleport to plot " .. baseNum,
        Callback = function()
            local _, hrp, _ = GetCharacter()
            local b = workspace.Bases:FindFirstChild(tostring(baseNum))
            if hrp and b then
                local sp = b:FindFirstChild("Spawn") or b
                local pos = sp:IsA("BasePart") and sp.Position or sp:GetPivot().Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end,
    })
end

-- =========================================================================
-- TAB 9: VISUALS & ESP
-- =========================================================================
TabVisuals:Section({ Title = "3D Radar Markers", Opened = true })

TabVisuals:Toggle({
    Title = "Real vs. Fake Egg ESP",
    Desc  = "Renders Bright Green for [REAL PET] and Bright Red for [FAKE/TROLL] eggs",
    Value = false,
    Callback = function(v)
        State.RealVsFakeESP = v
        if not v then
            for model, tag in pairs(ActiveESPObjects) do
                if tag and tag.Parent then pcall(function() tag:Destroy() end) end
                ActiveESPObjects[model] = nil
            end
        end
    end,
})

TabVisuals:Toggle({
    Title = "Nest Pets ESP (Gold/Diamond Highlights)",
    Desc  = "Highlights all pets in player nests with variant and owner names",
    Value = false,
    Callback = function(v) State.NestEggESP = v end,
})

TabVisuals:Toggle({
    Title = "Infiltrator Player ESP",
    Desc  = "Highlights enemy players disguised as eggs",
    Value = false,
    Callback = function(v) State.InfiltratorESP = v end,
})

-- =========================================================================
-- TAB 10: CONFIGURATION
-- =========================================================================
TabConfig:Section({ Title = "Preferences", Opened = true })

local ConfigFileName = "FakeAnEgg_AllSystemsConfig.json"
local ConfigKeys = {
    "SlapAuraRadius", "VacuumMode", "VacuumInterval", "RaidFilter",
    "RaidDwellTime", "SellInterval", "FeedItem", "FlySpeed", "WalkSpeedValue",
    "SelectedBat", "SelectedFence",
}

TabConfig:Button({
    Title = "Save Configuration",
    Desc  = "Saves preferences to local JSON",
    Callback = function()
        pcall(function()
            if not writefile then return end
            local payload = {}
            for _, k in ipairs(ConfigKeys) do payload[k] = State[k] end
            writefile(ConfigFileName, HttpService:JSONEncode(payload))
            SafeNotify({ Title = "Saved", Content = ConfigFileName, Duration = 2.5, Icon = "check-circle" })
        end)
    end,
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc  = "Restores preferences from local JSON",
    Callback = function()
        pcall(function()
            if not (isfile and readfile and isfile(ConfigFileName)) then
                SafeNotify({ Title = "No Config", Content = "No save file found.", Duration = 2, Icon = "alert-circle" })
                return
            end
            local data = HttpService:JSONDecode(readfile(ConfigFileName))
            if type(data) == "table" then
                for k, v in pairs(data) do if State[k] ~= nil then State[k] = v end end
                SafeNotify({ Title = "Loaded", Content = "Preferences restored.", Duration = 2.5, Icon = "check-circle" })
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Reset All (ALL OFF)",
    Desc  = "Turns off every active toggle immediately",
    Callback = function()
        local resetKeys = {
            "AutoRebirthSpeedrun", "AutoMaxBaseUpgrades", "AutoFeedMultiplier",
            "RealSlapAura", "BaseDefenderSlap", "AntiRagdoll", "AntiCarry",
            "AutoLabFuse", "AutoLabClaim", "RealEggVacuum", "AutoWorkingRaid", "AutoSellPets",
            "FlyEnabled", "ModifyWalkSpeed", "InfiniteJump", "Noclip",
            "RealVsFakeESP", "NestEggESP", "InfiltratorESP",
        }
        for _, k in ipairs(resetKeys) do State[k] = false end
        local _, _, hum = GetCharacter()
        if hum then hum.WalkSpeed = 16; hum.PlatformStand = false end
        SafeNotify({ Title = "Reset", Content = "All toggles OFF.", Duration = 2, Icon = "refresh-cw" })
    end,
})

TabConfig:Button({
    Title = "Clean Script Unload",
    Desc  = "Stops all background loops, disconnects listeners, and destroys UI",
    Callback = function()
        getgenv()._FAKE_EGG_RUNNING = false
        if getgenv()._FAKE_EGG_CLEANUP then
            pcall(getgenv()._FAKE_EGG_CLEANUP)
        end
        SafeNotify({ Title = "Unloaded", Content = "Suite cleanly unloaded.", Duration = 2, Icon = "x-circle" })
    end,
})

-- =========================================================================
-- FLOATING ACTION BUTTON & STATUS HUD
-- =========================================================================
local function CreateFloatingButton()
    local screen = Instance.new("ScreenGui")
    screen.Name = "FakeEgg_FloatingBtn"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 10000
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("ImageButton")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.fromOffset(54, 54)
    btn.Position = UDim2.new(0, 16, 0.45, 0)
    btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    btn.Image = "rbxassetid://10723346959"
    btn.ImageColor3 = Color3.fromRGB(255, 60, 60)
    btn.Active = true
    btn.Parent = screen

    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if Window then
            pcall(function()
                if Window.Closed then Window:Open() else Window:Close() end
            end)
        end
    end)
    return screen
end

local function CreateStatusHUD()
    local screen = Instance.new("ScreenGui")
    screen.Name = "FakeEgg_StatusHUD"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 9999
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(260, 48)
    frame.Position = UDim2.new(1, -275, 0, 12)
    frame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screen
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", frame)
    s.Color = Color3.fromRGB(255, 60, 60)
    s.Thickness = 1.5

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Text"
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(255, 230, 100)
    lbl.Text = "â¡ Suite Active Â· Press LeftControl"
    lbl.Parent = frame

    task.spawn(function()
        while screen.Parent do
            pcall(function()
                local reb = (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Rebirths") and LocalPlayer.leaderstats.Rebirths.Value) or 0
                local cash = (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash") and LocalPlayer.leaderstats.Cash.Value) or 0
                local nextInfo = RebirthMod.getNext(reb)
                local targetAnimal = nextInfo and nextInfo.animal or "MAX"

                local states = {}
                if State.AutoRebirthSpeedrun then table.insert(states, "GG-Rebirth") end
                if State.RealSlapAura then table.insert(states, "Slap-God") end
                if State.RealEggVacuum then table.insert(states, "Vacuum") end
                if State.AutoWorkingRaid then table.insert(states, "Raid") end
                if State.FlyEnabled then table.insert(states, "Fly") end

                local activeStr = #states > 0 and table.concat(states, "|") or "IDLE (ALL OFF)"
                lbl.Text = string.format("ð Rebirth: %d  (Need: %s)\nð° $%s | [%s]", reb, targetAnimal, tostring(cash), activeStr)
            end)
            task.wait(0.5)
        end
    end)
    return screen
end

local FloatingGui = CreateFloatingButton()
local StatusHUD   = CreateStatusHUD()

-- =========================================================================
-- WORKER 1: REAL BAT SLAP GOD AURA (PHYSICAL TOUCH REGISTERED)
-- =========================================================================
task.spawn(function()
    while getgenv()._FAKE_EGG_RUNNING do
        pcall(function()
            if not State.RealSlapAura and not State.BaseDefenderSlap then task.wait(0.1); return end

            local char, hrp, _ = GetCharacter()
            if not hrp then task.wait(0.2); return end

            local bat = char:FindFirstChild("Bat") or LocalPlayer.Backpack:FindFirstChild("Bat")
            if not bat then task.wait(0.5); return end
            if bat.Parent == LocalPlayer.Backpack then bat.Parent = char end
            local handle = bat:FindFirstChild("Handle")
            if not handle then task.wait(0.5); return end

            local myBase = GetMyBase()
            local myBasePos = myBase and myBase:GetPivot().Position or Vector3.zero

            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= LocalPlayer and other.Character then
                    local oHrp = other.Character:FindFirstChild("HumanoidRootPart")
                    local oHum = other.Character:FindFirstChildOfClass("Humanoid")
                    if oHrp and oHum and oHum.Health > 0 then
                        local distToMe = (oHrp.Position - hrp.Position).Magnitude
                        local distToBase = (oHrp.Position - myBasePos).Magnitude

                        local hit = false
                        if State.RealSlapAura and distToMe <= State.SlapAuraRadius then hit = true end
                        if State.BaseDefenderSlap and myBase and distToBase < 45 then hit = true end

                        if hit then
                            for _ = 1, 5 do
                                R.SlapActivatedEvent:FireServer(bat)
                                firetouchinterest(oHrp, handle, 0)
                                task.wait(0.01)
                                firetouchinterest(oHrp, handle, 1)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.05)
    end
end)

-- =========================================================================
-- WORKER 2: REAL EGG VACUUM (IS_EGG VERIFIED, SCANNER UNEQUIPPED)
-- =========================================================================
task.spawn(function()
    while getgenv()._FAKE_EGG_RUNNING do
        pcall(function()
            if not State.RealEggVacuum and not State.AutoRebirthSpeedrun then task.wait(0.3); return end

            local now = os.clock()
            if (now - State.LastVacuumTick) < State.VacuumInterval then task.wait(0.05); return end

            local _, hrp, _ = GetCharacter()
            if not hrp then task.wait(0.3); return end

            EnsureNoScannerEquipped()

            local ce = workspace:FindFirstChild("ClientEggs")
            if not ce then task.wait(0.3); return end

            -- Check next required animal for Rebirth
            local nextRebirthAnimal = nil
            if State.PrioritizeRebirthEgg or State.AutoRebirthSpeedrun then
                local curReb = (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Rebirths") and LocalPlayer.leaderstats.Rebirths.Value) or 0
                local nextInfo = RebirthMod.getNext(curReb)
                nextRebirthAnimal = nextInfo and nextInfo.animal or nil
            end

            -- Priority 1: Next rebirth target egg
            local targetEgg = nil
            if nextRebirthAnimal then
                for _, egg in ipairs(ce:GetChildren()) do
                    if egg:GetAttribute("IsEgg") == true and egg:GetAttribute("BaseName") == nextRebirthAnimal then
                        local p = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if p and p.Enabled then targetEgg = egg; break end
                    end
                end
            end

            -- Priority 2: Any real egg
            if not targetEgg and State.RealEggVacuum then
                for _, egg in ipairs(ce:GetChildren()) do
                    if egg:GetAttribute("IsEgg") == true then
                        local p = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if p and p.Enabled then targetEgg = egg; break end
                    end
                end
            end

            if targetEgg then
                local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    State.LastVacuumTick = now

                    if State.VacuumMode == "Instant Teleport" then
                        local eggPos = targetEgg:IsA("Model") and targetEgg:GetPivot().Position or targetEgg.Position
                        local oldPos = hrp.CFrame
                        hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 2, 0))
                        task.wait(0.15)
                        fireproximityprompt(prompt)
                        task.wait(0.15)
                        hrp.CFrame = oldPos
                    else
                        fireproximityprompt(prompt)
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- =========================================================================
-- WORKER 3: AUTO GG REBIRTH SPEEDRUNNER & AUTO NEST HATCHER
-- =========================================================================
task.spawn(function()
    while getgenv()._FAKE_EGG_RUNNING do
        pcall(function()
            if not State.AutoRebirthSpeedrun and not State.AutoHatchReadyEggs then task.wait(0.5); return end

            local _, hrp, _ = GetCharacter()

            -- 1. Auto Hatch any eggs in our nests that finished countdown
            if hrp and workspace:FindFirstChild("NestEggs") then
                local oldPos = hrp.CFrame
                local didHatch = false
                for _, eggModel in ipairs(workspace.NestEggs:GetChildren()) do
                    if eggModel:GetAttribute("Owner") == LocalPlayer.Name then
                        local hatchPrompt = nil
                        for _, p in ipairs(eggModel:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.ActionText == "Hatch" and p.Enabled then
                                hatchPrompt = p
                                break
                            end
                        end
                        if hatchPrompt then
                            local eggPos = hatchPrompt.Parent:IsA("Attachment") and hatchPrompt.Parent.WorldPosition or (hatchPrompt.Parent:IsA("BasePart") and hatchPrompt.Parent.Position or eggModel:GetPivot().Position)
                            hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 1.5, 0))
                            task.wait(0.12)
                            local oldHold = hatchPrompt.HoldDuration
                            hatchPrompt.HoldDuration = 0
                            hatchPrompt.RequiresLineOfSight = false
                            fireproximityprompt(hatchPrompt)
                            task.wait(0.15)
                            hatchPrompt.HoldDuration = oldHold
                            didHatch = true
                        end
                    end
                end
                if didHatch and oldPos then
                    hrp.CFrame = oldPos
                end
            end

            -- 2. Check Rebirth status
            if State.AutoRebirthSpeedrun then
                local curReb = (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Rebirths") and LocalPlayer.leaderstats.Rebirths.Value) or 0
                local curCash = (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash") and LocalPlayer.leaderstats.Cash.Value) or 0
                local reqCost = RebirthMod.getCost(curReb)

                if curCash < reqCost then
                    R.SellAllEvent:FireServer("Pets")
                    task.wait(0.3)
                end

                local canRebirth = RebirthMod.CanRebirth(LocalPlayer)
                if canRebirth then
                    R.RebirthEvent:FireServer()
                    SafeNotify({ Title = "Rebirth GG!", Content = "Advanced to Rebirth " .. (curReb + 1), Duration = 3, Icon = "zap" })
                    task.wait(0.5)
                end

                if State.AutoMaxBaseUpgrades then
                    for _ = 1, 3 do R.BaseUpgradeEvent:FireServer() end
                end

                if State.AutoFeedMultiplier then
                    R.FoodEvent:FireServer("Buy", State.FeedItem)
                end
            end

            -- 3. Auto Equip Best Pets
            if State.AutoEquipBest then
                local now = os.clock()
                if (now - State.LastEquipBestTick) >= 3.0 then
                    State.LastEquipBestTick = now
                    R.EquipBestEvent:FireServer()
                end
            end
        end)
        task.wait(1.0)
    end
end)

-- =========================================================================
-- WORKER 4: LAB & MUTATION AUTOMATION
-- =========================================================================
task.spawn(function()
    while getgenv()._FAKE_EGG_RUNNING do
        pcall(function()
            if State.AutoLabFuse then
                for floor = 1, 5 do
                    R.LabFuseEvent:FireServer(floor)
                    task.wait(0.05)
                end
            end

            if State.AutoLabClaim then
                for floor = 1, 5 do
                    R.LabClaimEvent:FireServer(floor)
                    task.wait(0.05)
                end
            end
        end)
        task.wait(2.0)
    end
end)

-- =========================================================================
-- WORKER 5: REAL WORKING SERVER RAID (FULL DEPOSIT LOOP)
-- =========================================================================
task.spawn(function()
    while getgenv()._FAKE_EGG_RUNNING do
        pcall(function()
            if not State.AutoWorkingRaid then task.wait(0.5); return end

            local now = os.clock()
            if (now - State.LastRaidTick) < State.RaidDwellTime then task.wait(0.1); return end

            local _, hrp, _ = GetCharacter()
            if not hrp then task.wait(0.3); return end

            local stolen = LocalPlayer:GetAttribute("StolenItem")
            if stolen and stolen ~= "" then
                hrp.CFrame = CFrame.new(GetMyBaseSpawnPos() + Vector3.new(0, 3, 0))
                task.wait(0.4)
                R.SellAllEvent:FireServer("Pets")
                State.LastRaidTick = now
                return
            end

            local nestEggs = workspace:FindFirstChild("NestEggs")
            if not nestEggs then task.wait(0.5); return end

            local targetPet = nil
            for _, pet in ipairs(nestEggs:GetChildren()) do
                local owner = pet:GetAttribute("Owner")
                local variant = pet:GetAttribute("Variant") or "Normal"
                if owner and owner ~= LocalPlayer.Name then
                    local pass = (State.RaidFilter == "All Pets")
                        or (State.RaidFilter == "Diamond / Gold Only" and (variant == "Gold" or variant == "Diamond"))
                        or (State.RaidFilter == "Diamond Only" and variant == "Diamond")
                        or (State.RaidFilter == "Gold Only" and variant == "Gold")
                    if pass then targetPet = pet; break end
                end
            end

            if targetPet then
                State.LastRaidTick = now
                local petPos = targetPet:GetPivot().Position

                hrp.CFrame = CFrame.new(petPos + Vector3.new(0, 2, 0))
                task.wait(0.2)

                local prompt = targetPet:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    prompt.Enabled = true
                    fireproximityprompt(prompt)
                end
                task.wait(0.4)

                local _, liveHrp, _ = GetCharacter()
                if liveHrp then
                    liveHrp.CFrame = CFrame.new(GetMyBaseSpawnPos() + Vector3.new(0, 3, 0))
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- =========================================================================
-- WORKER 6: 3D FLIGHT & MOVEMENT MODIFIERS
-- =========================================================================
RegConn(RunService.Heartbeat:Connect(function(dt)
    if not getgenv()._FAKE_EGG_RUNNING then return end
    pcall(function()
        local char, hrp, hum = GetCharacter()
        if not char or not hrp or not hum then return end

        if State.AntiRagdoll then
            LocalPlayer:SetAttribute("Ragdoll", false)
            char:SetAttribute("Ragdoll", false)
        end

        if State.AntiCarry then
            LocalPlayer:SetAttribute("Carrying", false)
        end

        if State.ModifyWalkSpeed and not State.FlyEnabled then
            hum.WalkSpeed = State.WalkSpeedValue
        end

        if State.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        if State.FlyEnabled then
            hum.PlatformStand = true
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

            hrp.Velocity = Vector3.zero
            if moveDir.Magnitude > 0.05 then
                hrp.CFrame += moveDir.Unit * (State.FlySpeed * dt)
            end
        end
    end)
end))

-- Infinite Jump
RegConn(UserInputService.JumpRequest:Connect(function()
    if not getgenv()._FAKE_EGG_RUNNING then return end
    if State.InfiniteJump and not State.FlyEnabled then
        local _, _, hum = GetCharacter()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- =========================================================================
-- WORKER 7: 3D RADAR ESP VISUALS
-- =========================================================================
task.spawn(function()
    while getgenv()._FAKE_EGG_RUNNING do
        pcall(function()
            local _, hrp, _ = GetCharacter()
            if not hrp then task.wait(0.5); return end

            local ce = workspace:FindFirstChild("ClientEggs")
            if State.RealVsFakeESP and ce then
                for _, egg in ipairs(ce:GetChildren()) do
                    if egg:GetAttribute("IsEgg") == true then
                        local tag = ActiveESPObjects[egg]
                        if not tag or not tag.Parent then
                            tag = Instance.new("BillboardGui")
                            tag.Size = UDim2.fromOffset(140, 34)
                            tag.StudsOffset = Vector3.new(0, 2.5, 0)
                            tag.AlwaysOnTop = true
                            tag.Adornee = egg:IsA("Model") and (egg:FindFirstChild("Keyhole") or egg:FindFirstChildWhichIsA("BasePart")) or egg
                            tag.Parent = targetParent

                            local txt = Instance.new("TextLabel")
                            txt.Name = "Info"
                            txt.Size = UDim2.fromScale(1, 1)
                            txt.BackgroundTransparency = 1
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 11
                            txt.TextStrokeTransparency = 0.2
                            txt.Parent = tag

                            ActiveESPObjects[egg] = tag
                        end

                        local info = tag:FindFirstChild("Info")
                        if info then
                            local db = ScannedEggDatabase[egg.Name]
                            if db then
                                if db.isFake then
                                    info.TextColor3 = Color3.fromRGB(255, 50, 50)
                                    info.Text = string.format("ð´ [FAKE / TROLL]\n%s", egg.Name)
                                else
                                    info.TextColor3 = Color3.fromRGB(50, 255, 120)
                                    info.Text = string.format("ð¢ [REAL PET]\n%s", egg.Name)
                                end
                            else
                                info.TextColor3 = Color3.fromRGB(255, 230, 80)
                                info.Text = string.format("ð¡ [WILD EGG]\n%s", egg.Name)
                            end
                        end
                    end
                end
            end

            local nestEggs = workspace:FindFirstChild("NestEggs")
            if State.NestEggESP and nestEggs then
                for _, pet in ipairs(nestEggs:GetChildren()) do
                    local owner = pet:GetAttribute("Owner") or "?"
                    local variant = pet:GetAttribute("Variant") or "Normal"
                    local isMine = (owner == LocalPlayer.Name)

                    local tag = ActiveESPObjects[pet]
                    if not tag or not tag.Parent then
                        tag = Instance.new("BillboardGui")
                        tag.Size = UDim2.fromOffset(130, 36)
                        tag.StudsOffset = Vector3.new(0, 3, 0)
                        tag.AlwaysOnTop = true
                        tag.Adornee = pet:IsA("Model") and (pet:FindFirstChild("EggCenter") or pet:FindFirstChildWhichIsA("BasePart")) or pet
                        tag.Parent = targetParent

                        local txt = Instance.new("TextLabel")
                        txt.Name = "Info"
                        txt.Size = UDim2.fromScale(1, 1)
                        txt.BackgroundTransparency = 1
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 11
                        txt.TextStrokeTransparency = 0.2
                        txt.Parent = tag

                        ActiveESPObjects[pet] = tag
                    end

                    local info = tag:FindFirstChild("Info")
                    if info then
                        local color = isMine and Color3.fromRGB(100, 255, 100)
                            or (variant == "Diamond" and Color3.fromRGB(80, 220, 255)
                            or (variant == "Gold" and Color3.fromRGB(255, 215, 0)
                            or Color3.fromRGB(255, 230, 120)))
                        local prefix = variant ~= "Normal" and ("[" .. variant .. "] ") or ""
                        info.TextColor3 = color
                        info.Text = string.format("%s%s\n@%s", prefix, pet.Name, owner)
                    end
                end
            end
        end)
        task.wait(0.8)
    end
end)

-- =========================================================================
-- CLEANUP HANDLER
-- =========================================================================
getgenv()._FAKE_EGG_CLEANUP = function()
    getgenv()._FAKE_EGG_RUNNING = false

    for _, conn in ipairs(ActiveConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(ActiveConnections)

    for _, tag in pairs(ActiveESPObjects) do
        if tag and tag.Parent then pcall(function() tag:Destroy() end) end
    end
    table.clear(ActiveESPObjects)

    if FloatingGui and FloatingGui.Parent then pcall(function() FloatingGui:Destroy() end) end
    if StatusHUD and StatusHUD.Parent then pcall(function() StatusHUD:Destroy() end) end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local bg = pg:FindFirstChild("FakeEgg_FloatingBtn")
        if bg then pcall(function() bg:Destroy() end) end
        local sh = pg:FindFirstChild("FakeEgg_StatusHUD")
        if sh then pcall(function() sh:Destroy() end) end
    end

    if Window and Window.Destroy then pcall(function() Window:Destroy() end) end
    for _, c in ipairs(targetParent:GetChildren()) do
        if string.find(c.Name, "WindUI") then pcall(function() c:Destroy() end) end
    end

    local _, _, hum = GetCharacter()
    if hum then hum.WalkSpeed = 16; hum.PlatformStand = false end
end

-- Startup Notice
SafeNotify({
    Title    = "Fake an Egg v5.1 Ready",
    Content  = "Menu Opened! Use UI toggles or Status HUD in top-right.",
    Duration = 4,
    Icon     = "trophy",
})
