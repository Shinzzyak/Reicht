-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [ð] Net a Fish! â Elite Automation Master Suite (Expanded v2.0)
    Architecture: WindUI v1.6.65 / Modern Luau / Real MCP Execution
    Operating Directive: Universal English UI, Non-Negotiable Safety, ALL OFF Startup Default.
    Repository: E:\SC\Net a Fish\ClientOP_NetAFish.lua
]]

-- Anti-double-execution guard
if getgenv()._NET_A_FISH_RUNNING then
    if getgenv()._NET_A_FISH_UNLOAD then
        pcall(getgenv()._NET_A_FISH_UNLOAD)
    end
    task.wait(0.2)
end

-- Clean any stale WindUI ScreenGuis
local targetParent = gethui and gethui() or game:GetService("CoreGui")
for _, c in ipairs(targetParent:GetChildren()) do
    if string.find(c.Name, "WindUI") then
        pcall(c.Destroy, c)
    end
end

getgenv()._NET_A_FISH_RUNNING = true

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- LocalPlayer references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)
end)

-- Shared Remotes & Modules
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
local FishingShared = require(ReplicatedStorage:WaitForChild("FishingShared", 30))
local SkillTreeModule = require(ReplicatedStorage:WaitForChild("SkillTree", 30))

-- Automation State Table (Strictly ALL OFF by Default as per SOP Rule 8)
local State = {
    -- Tab 1: Fishing Automation
    AutoThrowNet = false,
    AutoReelIn = false,
    ReelMode = "Instant (Fastest)", -- "Instant (Fastest)", "Wait Full Net", "Custom Delay"
    ReelDelay = 5,
    AutoPerfectTap = false,
    AutoCatchResolver = false,
    CatchDecision = "Keep All (Cooler)", -- "Keep All (Cooler)", "Sell All", "Place Best (Pedestal)"
    FastCycleExploit = false,

    -- Tab 2: Economy & Pedestals
    AutoCollectPads = false,
    AutoOptimizeShowcase = false,
    AutoCoolerStoreAll = false,
    AutoCoolerFuseAll = false,
    AutoCoolerSellJunk = false,

    -- Tab 3: Gear, Tackle & Potions
    AutoBuyBestNet = false,
    AutoBuyUpgrades = false,
    AutoEquipBestSetup = false,
    AutoPotions = false,
    AutoUpgradeSpear = false,
    AutoUpgradeBoat = false,
    AutoUpgradeHelper = false,

    -- Tab 4: Pets & Progression
    AutoRebirth = false,
    AutoAllocateSkills = false,
    AutoClaimFreeClam = false,
    AutoClaimContracts = false,
    AutoClaimIndexRewards = false,
    AutoClaimDaily = false,
    AutoClaimGifts = false,
    AutoClaimOffline = false,
    AutoEquipBestPet = false,
    AutoLevelUpPets = false,
    AutoJoinMegalodon = false,
    AutoShootMegalodon = false,
    MegalodonRapidFire = false,

    -- Tab 5: Visuals & River Fish ESP
    RiverFishESP = false,
    ESPMinRarity = "Rare", -- "All", "Rare", "Epic", "Legendary", "Mythic", "Apex", "Demigod"
    ESPShowMutations = true,
    ESPShowDistance = true,

    -- Screen Cleaners & Cutscene Skippers
    HideCatchPopups = false,
    AutoCloseBossLoot = false,
    DisableCutscenes = false,

    -- Tab 7: Movement & Physics
    CustomWalkSpeed = false,
    WalkSpeedValue = 16,
    CustomJumpPower = false,
    JumpPowerValue = 50,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = false,
}

-- Rarity Level Map for ESP Filtering
local RarityThresholds = {
    ["All"] = 1,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
    ["Apex"] = 7,
    ["Demigod"] = 8,
}

-- Registry for clean thread and connection unloads
local ActiveTasks = {}
local ActiveConnections = {}
local ActiveESPFolder = nil

local function RegisterTask(thread)
    table.insert(ActiveTasks, thread)
    return thread
end

local function RegisterConnection(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

-- Helper: Locate Player's Assigned Base and Dock
local function GetMyBase()
    local basesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Bases")
    if not basesFolder then return nil end
    for _, base in ipairs(basesFolder:GetChildren()) do
        if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return base
        end
    end
    return nil
end

local function GetMyDockCFrame()
    local myBase = GetMyBase()
    if myBase then
        local dock = myBase:FindFirstChild("Dock")
        if dock then
            return dock:GetPivot()
        end
        return myBase:GetPivot() + Vector3.new(0, 3, 0)
    end
    return CFrame.new(73, 5, -300)
end

local function IsOnDock()
    local myBase = GetMyBase()
    if not myBase or not HumanoidRootPart then return false end
    if not myBase:FindFirstChild("Dock") and not myBase:FindFirstChild("Floor") then
        return true
    end
    return FishingShared.OnOwnDock(myBase, HumanoidRootPart.Position)
end

-- Helper: Optimize Base Showcase (Fill open pedestals with highest income fish from cooler)
local function OptimizeShowcasePedestals()
    pcall(function()
        local data = Remotes.GetData:InvokeServer()
        if not data or not data.Cooler then return end

        local allFish = {}
        for key, stack in pairs(data.Cooler) do
            if type(stack) == "table" and type(stack.k) == "table" then
                for _, f in ipairs(stack.k) do
                    local specId = f.s or key:match("^([^|]+)")
                    local spec = FishingShared.SpeciesById and FishingShared.SpeciesById[specId]
                    local r = f.r or (spec and spec.Rarity) or 1
                    local val = f.v or 1
                    local inc = FishingShared.Income and FishingShared.Income(val) or val
                    table.insert(allFish, {
                        Key = key,
                        UID = f.uid,
                        Rarity = r,
                        Val = val,
                        Income = inc
                    })
                end
            end
        end

        table.sort(allFish, function(a, b)
            return a.Income > b.Income
        end)

        for slot = 1, math.min(10, #allFish) do
            local cur = data.Showcase and data.Showcase[tostring(slot)]
            local target = allFish[slot]
            local curVal = cur and cur.v or 0
            if not cur or target.Val > curVal then
                Remotes.CoolerAction:InvokeServer("place", target.Key, slot)
                task.wait(0.08)
            end
        end
    end)
end

-- Helper: Auto Fuse Duplicate Fish in Cooler
local function AutoFuseCoolerFish()
    pcall(function()
        local data = Remotes.GetData:InvokeServer()
        if not data or not data.Cooler then return end

        for key, stack in pairs(data.Cooler) do
            if type(stack) == "table" and type(stack.k) == "table" then
                local count = #stack.k
                local curMut = stack.mu or "Normal"
                local fuseCount = FishingShared.FuseCountFor and FishingShared.FuseCountFor(curMut) or 5
                if count >= fuseCount then
                    local nextMut = FishingShared.NextMutation and FishingShared.NextMutation(curMut)
                    if nextMut and nextMut.Id then
                        Remotes.CoolerAction:InvokeServer("fuse", key, nextMut.Id)
                        task.wait(0.1)
                    end
                end
            end
        end
    end)
end

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Safe Notification Helper
local function SafeNotify(opts)
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify(opts)
        end)
    end
end

-- =========================================================================
-- BUILD MAIN WINDOW & TABS
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Net a Fish!",
    Icon = "fish",
    Author = "Elite Automation Suite",
    Folder = "NetAFish",
    Size = UDim2.fromOffset(640, 530),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Title = "Open Script",
        Icon = "crosshair",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("00B4D8"),
            Color3.fromHex("0077B6")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
    ToggleKey = Enum.KeyCode.LeftControl,
})

local TabFishing   = Window:Tab({ Title = "Fishing", Icon = "anchor" })
local TabEconomy   = Window:Tab({ Title = "Economy & Showcase", Icon = "coins" })
local TabUpgrades  = Window:Tab({ Title = "Gear & Tackle", Icon = "trending-up" })
local TabProgress  = Window:Tab({ Title = "Pets & Progression", Icon = "award" })
local TabVisuals   = Window:Tab({ Title = "Visuals & Fish ESP", Icon = "eye" })
local TabTeleport  = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
local TabMovement  = Window:Tab({ Title = "Movement", Icon = "gauge" })
local TabConfig    = Window:Tab({ Title = "Configuration", Icon = "settings" })

getgenv()._NET_A_FISH_WINDOW = Window

-- =========================================================================
-- TAB 1: FISHING AUTOMATION
-- =========================================================================
TabFishing:Section({
    Title = "Fishing Engine Core",
    Opened = true,
})

local FishingStatus = TabFishing:Paragraph({
    Title = "Net Status",
    Desc = "Standby - Ready to cast net.",
})

TabFishing:Toggle({
    Title = "Auto Throw Net",
    Desc = "Automatically casts net when idle and positioned on dock",
    Value = State.AutoThrowNet,
    Callback = function(val)
        State.AutoThrowNet = val
    end,
})

TabFishing:Toggle({
    Title = "Auto Reel In",
    Desc = "Automatically reels in net when target conditions are met",
    Value = State.AutoReelIn,
    Callback = function(val)
        State.AutoReelIn = val
    end,
})

TabFishing:Dropdown({
    Title = "Reel Mode",
    Desc = "Choose when the net should be reeled in",
    Values = { "Instant (Fastest)", "Wait Full Net", "Custom Delay" },
    Value = State.ReelMode,
    Callback = function(val)
        State.ReelMode = val
    end,
})

TabFishing:Slider({
    Title = "Custom Reel Delay (Seconds)",
    Desc = "Time to wait before reeling in if Custom Delay mode is selected",
    Value = {
        Min = 1,
        Max = 60,
        Default = State.ReelDelay,
    },
    Step = 1,
    Callback = function(val)
        State.ReelDelay = val
    end,
})

TabFishing:Toggle({
    Title = "Auto Perfect Tap (Max Multiplier)",
    Desc = "Injects server-synced Perfect Reel timing for maximum catch yield",
    Value = State.AutoPerfectTap,
    Callback = function(val)
        State.AutoPerfectTap = val
    end,
})

TabFishing:Toggle({
    Title = "Auto Catch Resolver (Auto Clear Dialog)",
    Desc = "Instantly clears the post-catch selection screen without manual clicks",
    Value = State.AutoCatchResolver,
    Callback = function(val)
        State.AutoCatchResolver = val
    end,
})

TabFishing:Dropdown({
    Title = "Catch Decision Mode",
    Desc = "Action taken for each caught fish during auto-resolve",
    Values = { "Keep All (Cooler)", "Sell All", "Place Best (Pedestal)" },
    Value = State.CatchDecision,
    Callback = function(val)
        State.CatchDecision = val
    end,
})

TabFishing:Section({
    Title = "High-Throughput Bypass",
    Opened = true,
})

TabFishing:Toggle({
    Title = "Instant Catch Exploit (Sub-Second Burst)",
    Desc = "Aggressive cycle: Cast -> Instant Reel -> Perfect Tap -> Resolve in continuous sub-second bursts",
    Value = State.FastCycleExploit,
    Callback = function(val)
        State.FastCycleExploit = val
        if val then
            State.AutoThrowNet = true
            State.AutoReelIn = true
            State.ReelMode = "Instant (Fastest)"
            State.AutoPerfectTap = true
            State.AutoCatchResolver = true
        end
    end,
})

TabFishing:Button({
    Title = "Force Throw Net Now",
    Icon = "arrow-up-right",
    Callback = function()
        pcall(function()
            Remotes.ThrowNet:FireServer()
        end)
    end,
})

TabFishing:Button({
    Title = "Force Reel In Now",
    Icon = "arrow-down-left",
    Callback = function()
        pcall(function()
            Remotes.ReelIn:FireServer()
        end)
    end,
})

-- =========================================================================
-- TAB 2: ECONOMY & SHOWCASE
-- =========================================================================
TabEconomy:Section({
    Title = "Income & Showcase Optimization",
    Opened = true,
})

local EconomyStatus = TabEconomy:Paragraph({
    Title = "Economy Overview",
    Desc = "Loading data...",
})

TabEconomy:Toggle({
    Title = "Auto Collect Base Income (Pads)",
    Desc = "Continuously drains passive bank earnings from all showcase pedestals",
    Value = State.AutoCollectPads,
    Callback = function(val)
        State.AutoCollectPads = val
    end,
})

TabEconomy:Toggle({
    Title = "Auto Optimize Showcase Pedestals",
    Desc = "Places your top 10 rarest fish from cooler onto all pedestals to maximize billions/sec",
    Value = State.AutoOptimizeShowcase,
    Callback = function(val)
        State.AutoOptimizeShowcase = val
        if val then
            OptimizeShowcasePedestals()
        end
    end,
})

TabEconomy:Button({
    Title = "Optimize Showcase Pedestals Now",
    Icon = "award",
    Callback = function()
        OptimizeShowcasePedestals()
        SafeNotify({
            Title = "Showcase Optimized",
            Content = "Placed highest rarity fish on all base pedestals!",
            Duration = 3,
            Icon = "check",
        })
    end,
})

TabEconomy:Button({
    Title = "Collect All Base Pads Now",
    Icon = "dollar-sign",
    Callback = function()
        pcall(function()
            for slot = 1, 10 do
                Remotes.CollectPadReq:FireServer(slot)
            end
            SafeNotify({
                Title = "Collected",
                Content = "Income collected from all 10 pedestals!",
                Duration = 2,
                Icon = "check",
            })
        end)
    end,
})

TabEconomy:Section({
    Title = "Cooler & Inventory Automation",
    Opened = true,
})

TabEconomy:Toggle({
    Title = "Auto Deposit to Cooler (Store All)",
    Desc = "Automatically moves all caught fish into your base cooler storage",
    Value = State.AutoCoolerStoreAll,
    Callback = function(val)
        State.AutoCoolerStoreAll = val
    end,
})

TabEconomy:Toggle({
    Title = "Auto Fuse Duplicate Fish (Fuse All)",
    Desc = "Combines duplicate fish into higher mutations and increased base value",
    Value = State.AutoCoolerFuseAll,
    Callback = function(val)
        State.AutoCoolerFuseAll = val
    end,
})

TabEconomy:Button({
    Title = "Deposit All Fish to Cooler",
    Icon = "archive",
    Callback = function()
        pcall(function()
            Remotes.CoolerAction:InvokeServer("storeAll")
            SafeNotify({
                Title = "Cooler Updated",
                Content = "All fish deposited to cooler!",
                Duration = 2,
                Icon = "check",
            })
        end)
    end,
})

TabEconomy:Button({
    Title = "Fuse All Fish in Cooler",
    Icon = "sparkles",
    Callback = function()
        pcall(function()
            Remotes.CoolerAction:InvokeServer("fuseAll")
            SafeNotify({
                Title = "Fusing Complete",
                Content = "All matching fish fused to higher mutations!",
                Duration = 2,
                Icon = "check",
            })
        end)
    end,
})

-- =========================================================================
-- TAB 3: GEAR, TACKLE & POTIONS
-- =========================================================================
TabUpgrades:Section({
    Title = "Nets & Base Upgrades",
    Opened = true,
})

local UpgradeStatus = TabUpgrades:Paragraph({
    Title = "Gear Summary",
    Desc = "Loading gear info...",
})

TabUpgrades:Toggle({
    Title = "Auto Buy Best Net Tier",
    Desc = "Automatically purchases and equips the next net tier as soon as affordable",
    Value = State.AutoBuyBestNet,
    Callback = function(val)
        State.AutoBuyBestNet = val
    end,
})

TabUpgrades:Toggle({
    Title = "Auto Buy All Shop Upgrades",
    Desc = "Automatically levels up all 31 base upgrades (Luck, Reel, Haggler, Storage, Colossus, etc.)",
    Value = State.AutoBuyUpgrades,
    Callback = function(val)
        State.AutoBuyUpgrades = val
    end,
})

TabUpgrades:Button({
    Title = "Buy Next Net Tier Now",
    Icon = "shopping-bag",
    Callback = function()
        pcall(function()
            local data = Remotes.GetData:InvokeServer()
            local nextTier = (data and data.NetTier or 1) + 1
            local netInfo = FishingShared.Nets[nextTier]
            if netInfo and data.Cash >= netInfo.Cost then
                Remotes.BuyItem:FireServer("Net", nextTier)
                SafeNotify({
                    Title = "Net Purchased",
                    Content = "Bought Tier " .. tostring(nextTier) .. ": " .. netInfo.Name,
                    Duration = 3,
                    Icon = "check",
                })
            else
                SafeNotify({
                    Title = "Cannot Buy Net",
                    Content = "Insufficient cash or max tier reached.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end)
    end,
})

TabUpgrades:Button({
    Title = "Sweep All Affordable Upgrades Now",
    Icon = "zap",
    Callback = function()
        pcall(function()
            local data = Remotes.GetData:InvokeServer()
            if not data then return end
            local count = 0
            for _, up in ipairs(FishingShared.Upgrades or {}) do
                local id = up.Id or up.Name
                local curLvl = data.Upgrades and data.Upgrades[id] or 0
                local cost = FishingShared.UpgradeCost(id, curLvl, data)
                if cost and cost <= data.Cash and curLvl < (up.Max or 35) then
                    Remotes.BuyItem:FireServer("Upgrade", id)
                    data.Cash = data.Cash - cost
                    count = count + 1
                    task.wait(0.04)
                end
            end
            SafeNotify({
                Title = "Upgrades Swept",
                Content = "Purchased " .. tostring(count) .. " available upgrades!",
                Duration = 2,
                Icon = "check",
            })
        end)
    end,
})

TabUpgrades:Section({
    Title = "Tackle, Baits & Potions",
    Opened = true,
})

TabUpgrades:Toggle({
    Title = "Auto Equip Best Setup (Bait & Rigs)",
    Desc = "Continuously selects and activates your best available tackle and bait",
    Value = State.AutoEquipBestSetup,
    Callback = function(val)
        State.AutoEquipBestSetup = val
        if val then
            pcall(function()
                Remotes.BestSetup:FireServer()
            end)
        end
    end,
})

TabUpgrades:Toggle({
    Title = "Auto Buy & Drink Potions",
    Desc = "Sweeps the potion shop on refresh and drinks all buffs automatically",
    Value = State.AutoPotions,
    Callback = function(val)
        State.AutoPotions = val
        if val then
            pcall(function()
                Remotes.Potions:InvokeServer("auto", true)
                Remotes.Potions:InvokeServer("useAll")
            end)
        end
    end,
})

TabUpgrades:Button({
    Title = "Drink All Potions Now",
    Icon = "flask-conical",
    Callback = function()
        pcall(function()
            local res = Remotes.Potions:InvokeServer("useAll")
            SafeNotify({
                Title = "Potions Consumed",
                Content = "Activated all potions in inventory!",
                Duration = 2,
                Icon = "check",
            })
        end)
    end,
})

TabUpgrades:Section({
    Title = "Turrets & Auxiliaries",
    Opened = true,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Spear Gun",
    Desc = "Automatically levels up dock spear gun attachments when affordable",
    Value = State.AutoUpgradeSpear,
    Callback = function(val)
        State.AutoUpgradeSpear = val
    end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Boat",
    Desc = "Automatically purchases boat hull, engine, trawl, and sonar upgrades",
    Value = State.AutoUpgradeBoat,
    Callback = function(val)
        State.AutoUpgradeBoat = val
    end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Fisherman (Helper)",
    Desc = "Automatically upgrades autonomous dock fisherman helper stats",
    Value = State.AutoUpgradeHelper,
    Callback = function(val)
        State.AutoUpgradeHelper = val
    end,
})

-- =========================================================================
-- TAB 4: PETS & PROGRESSION
-- =========================================================================
TabProgress:Section({
    Title = "Rebirth & Skill Tree",
    Opened = true,
})

local ProgressStatus = TabProgress:Paragraph({
    Title = "Progression Overview",
    Desc = "Loading progress data...",
})

TabProgress:Toggle({
    Title = "Auto Rebirth",
    Desc = "Instantly executes rebirth as soon as requirements are fulfilled",
    Value = State.AutoRebirth,
    Callback = function(val)
        State.AutoRebirth = val
    end,
})

TabProgress:Toggle({
    Title = "Auto Allocate Skill Points",
    Desc = "Distributes available skill points into optimal branches (Luck > Net > Fortune > Crew)",
    Value = State.AutoAllocateSkills,
    Callback = function(val)
        State.AutoAllocateSkills = val
    end,
})

TabProgress:Button({
    Title = "Force Rebirth Now",
    Icon = "refresh-cw",
    Callback = function()
        pcall(function()
            local data = Remotes.GetData:InvokeServer()
            if FishingShared.CanRebirth(data) then
                Remotes.RebirthRequest:FireServer()
                SafeNotify({
                    Title = "Rebirth Triggered",
                    Content = "Rebirth requested successfully!",
                    Duration = 2,
                    Icon = "check",
                })
            else
                SafeNotify({
                    Title = "Rebirth Not Ready",
                    Content = "Requirements not met yet.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end)
    end,
})

TabProgress:Section({
    Title = "Pearls, Quests & Index",
    Opened = true,
})

TabProgress:Toggle({
    Title = "Auto Claim Free Clam (Pearls)",
    Desc = "Claims the daily free pearl clam whenever available",
    Value = State.AutoClaimFreeClam,
    Callback = function(val)
        State.AutoClaimFreeClam = val
        if val then
            pcall(function()
                Remotes.PearlShop:InvokeServer("freeClam")
            end)
        end
    end,
})

TabProgress:Toggle({
    Title = "Auto Claim Fish Index Rewards",
    Desc = "Collects completed fish index page bonuses (+% permanent money and mutation boost)",
    Value = State.AutoClaimIndexRewards,
    Callback = function(val)
        State.AutoClaimIndexRewards = val
        if val then
            pcall(function()
                Remotes.Rewards:InvokeServer("pageRewards")
            end)
        end
    end,
})

TabProgress:Toggle({
    Title = "Auto Claim Completed Contracts (Quests)",
    Desc = "Automatically turns in finished contracts for massive Cash and Pearl rewards",
    Value = State.AutoClaimContracts,
    Callback = function(val)
        State.AutoClaimContracts = val
    end,
})

TabProgress:Toggle({
    Title = "Auto Claim Daily Login & Gifts",
    Desc = "Redeems daily calendar login and active playtime gifts",
    Value = State.AutoClaimDaily,
    Callback = function(val)
        State.AutoClaimDaily = val
        State.AutoClaimGifts = val
        State.AutoClaimOffline = val
    end,
})

TabProgress:Section({
    Title = "Pets & Boss Events",
    Opened = true,
})

TabProgress:Toggle({
    Title = "Auto Equip Best Pet",
    Desc = "Automatically equips your rarest pet companion",
    Value = State.AutoEquipBestPet,
    Callback = function(val)
        State.AutoEquipBestPet = val
    end,
})

TabProgress:Toggle({
    Title = "Auto Join Megalodon Boss Event",
    Desc = "Enters Megalodon boss fight arena automatically whenever it spawns",
    Value = State.AutoJoinMegalodon,
    Callback = function(val)
        State.AutoJoinMegalodon = val
    end,
})

TabProgress:Toggle({
    Title = "Auto Shoot Megalodon (Turret Mode)",
    Desc = "Automatically aims and fires at Megalodon while active in arena",
    Value = State.AutoShootMegalodon,
    Callback = function(val)
        State.AutoShootMegalodon = val
    end,
})

TabProgress:Toggle({
    Title = "Megalodon Rapid Fire Mode",
    Desc = "Fires high-frequency volleys without waiting for client reload delay",
    Value = State.MegalodonRapidFire,
    Callback = function(val)
        State.MegalodonRapidFire = val
    end,
})

-- =========================================================================
-- TAB 5: VISUALS & RIVER FISH ESP
-- =========================================================================
TabVisuals:Section({
    Title = "River Swimming Fish ESP",
    Opened = true,
})

ActiveESPFolder = Instance.new("Folder")
ActiveESPFolder.Name = "_NetAFishESP"
ActiveESPFolder.Parent = targetParent

TabVisuals:Toggle({
    Title = "Enable River Fish ESP",
    Desc = "Renders colored name tags and mutation badges over swimming fish in the river",
    Value = State.RiverFishESP,
    Callback = function(val)
        State.RiverFishESP = val
        if not val and ActiveESPFolder then
            ActiveESPFolder:ClearAllChildren()
        end
    end,
})

TabVisuals:Dropdown({
    Title = "Minimum Rarity to Display",
    Desc = "Filters ESP to only show fish at or above the selected rarity tier",
    Values = { "All", "Rare", "Epic", "Legendary", "Mythic", "Apex", "Demigod" },
    Value = State.ESPMinRarity,
    Callback = function(val)
        State.ESPMinRarity = val
    end,
})

TabVisuals:Toggle({
    Title = "Show Mutation Tags",
    Desc = "Displays mutation attributes (Gold, Shiny, Crystal, Rainbow, Starlit)",
    Value = State.ESPShowMutations,
    Callback = function(val)
        State.ESPShowMutations = val
    end,
})

TabVisuals:Toggle({
    Title = "Show Distance (Studs)",
    Desc = "Displays exact distance from player to target fish",
    Value = State.ESPShowDistance,
    Callback = function(val)
        State.ESPShowDistance = val
    end,
})

TabVisuals:Section({
    Title = "Screen Cleaners & Cutscene Skippers",
    Opened = true,
})

TabVisuals:Toggle({
    Title = "Auto Skip / Hide Rare Catch Popups",
    Desc = "Hides 'FORBIDDEN!', 'CELESTIAL!', etc. popups and auto-dismisses 'Click to continue'",
    Value = State.HideCatchPopups,
    Callback = function(val)
        State.HideCatchPopups = val
    end,
})

TabVisuals:Toggle({
    Title = "Auto Close Boss Loot Cards",
    Desc = "Automatically closes Kraken and Megalodon damage rank loot summary screens",
    Value = State.AutoCloseBossLoot,
    Callback = function(val)
        State.AutoCloseBossLoot = val
    end,
})

TabVisuals:Toggle({
    Title = "Disable All 3D Camera Cutscenes",
    Desc = "Forces game engine to skip all cinematic camera sequences",
    Value = State.DisableCutscenes,
    Callback = function(val)
        State.DisableCutscenes = val
        pcall(function()
            LocalPlayer:SetAttribute("Set_Cutscenes", not val)
        end)
    end,
})

-- =========================================================================
-- TAB 6: WORLD & TELEPORTS
-- =========================================================================
TabTeleport:Section({
    Title = "Personal Base & Landmarks",
    Opened = true,
})

TabTeleport:Button({
    Title = "Teleport to My Dock",
    Icon = "anchor",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = GetMyDockCFrame()
        end
    end,
})

TabTeleport:Button({
    Title = "Teleport to Base Showcase Pedestals",
    Icon = "home",
    Callback = function()
        local myBase = GetMyBase()
        if myBase and HumanoidRootPart then
            HumanoidRootPart.CFrame = myBase:GetPivot() + Vector3.new(0, 4, 0)
        elseif HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(112, 5, -300)
        end
    end,
})

TabTeleport:Button({
    Title = "Teleport to Central Hub",
    Icon = "compass",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(-9.2, 16, 2.8)
        end
    end,
})

TabTeleport:Button({
    Title = "Teleport to River Center",
    Icon = "droplet",
    Callback = function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(0, 8, 0)
        end
    end,
})

TabTeleport:Button({
    Title = "Teleport to Megalodon Arena / Deep Sea",
    Icon = "shield-alert",
    Callback = function()
        pcall(function()
            Remotes.MegEvent:FireServer("enter")
        end)
    end,
})

TabTeleport:Button({
    Title = "Teleport to Rarest Swimming Fish",
    Icon = "crosshair",
    Callback = function()
        pcall(function()
            local cf = workspace:FindFirstChild("ClientFish")
            if not cf or not HumanoidRootPart then return end

            local bestFish = nil
            local bestRarity = 0

            for _, fish in ipairs(cf:GetChildren()) do
                if fish:IsA("BasePart") then
                    local fId = fish:GetAttribute("FishId") or fish.Name
                    local sp = FishingShared.SpeciesById and FishingShared.SpeciesById[fId]
                    local r = sp and sp.Rarity or 1
                    if r > bestRarity then
                        bestRarity = r
                        bestFish = fish
                    end
                end
            end

            if bestFish then
                HumanoidRootPart.CFrame = bestFish.CFrame + Vector3.new(0, 5, 0)
                SafeNotify({
                    Title = "Teleported to Fish",
                    Content = "Warped to " .. bestFish.Name .. " (Rarity Tier " .. tostring(bestRarity) .. ")",
                    Duration = 2,
                    Icon = "check",
                })
            else
                SafeNotify({
                    Title = "No Fish Found",
                    Content = "No swimming fish currently rendered.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end)
    end,
})

TabTeleport:Section({
    Title = "Base Docks 1 - 8",
    Opened = false,
})

for baseId = 1, 8 do
    TabTeleport:Button({
        Title = "Teleport to Dock " .. tostring(baseId),
        Icon = "map-pin",
        Callback = function()
            local basesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Bases")
            local b = basesFolder and basesFolder:FindFirstChild("Base" .. tostring(baseId))
            if b and HumanoidRootPart then
                local dock = b:FindFirstChild("Dock")
                HumanoidRootPart.CFrame = dock and dock:GetPivot() or (b:GetPivot() + Vector3.new(0, 3, 0))
            end
        end,
    })
end

-- =========================================================================
-- TAB 7: MOVEMENT & PHYSICS
-- =========================================================================
TabMovement:Section({
    Title = "Character Mobility",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Enable Custom WalkSpeed",
    Desc = "Override default movement velocity",
    Value = State.CustomWalkSpeed,
    Callback = function(val)
        State.CustomWalkSpeed = val
        if not val and Humanoid then
            Humanoid.WalkSpeed = 16
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Desc = "Set player movement speed",
    Value = {
        Min = 16,
        Max = 250,
        Default = State.WalkSpeedValue,
    },
    Step = 2,
    Callback = function(val)
        State.WalkSpeedValue = val
        if State.CustomWalkSpeed and Humanoid then
            Humanoid.WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Enable Custom JumpPower",
    Desc = "Override vertical leap impulse",
    Value = State.CustomJumpPower,
    Callback = function(val)
        State.CustomJumpPower = val
        if not val and Humanoid then
            Humanoid.JumpPower = 50
        end
    end,
})

TabMovement:Slider({
    Title = "JumpPower Value",
    Desc = "Set player jump height",
    Value = {
        Min = 50,
        Max = 300,
        Default = State.JumpPowerValue,
    },
    Step = 5,
    Callback = function(val)
        State.JumpPowerValue = val
        if State.CustomJumpPower and Humanoid then
            Humanoid.JumpPower = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Pass freely through docks, terrain barriers, and water boundaries",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows endless mid-air jumping",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents Roblox 20-minute idle disconnection",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =========================================================================
-- TAB 8: CONFIGURATION & CODES
-- =========================================================================
TabConfig:Section({
    Title = "Settings Persistence",
    Opened = true,
})

local ConfigFileName = "NetAFish_Config.json"

local function SaveProfile()
    local payload = HttpService:JSONEncode(State)
    if writefile then
        writefile(ConfigFileName, payload)
        SafeNotify({
            Title = "Config Saved",
            Content = "Settings saved to " .. ConfigFileName,
            Duration = 2,
            Icon = "save",
        })
    end
end

local function LoadProfile()
    if readfile and isfile and isfile(ConfigFileName) then
        local raw = readfile(ConfigFileName)
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                if State[k] ~= nil then
                    State[k] = v
                end
            end
            SafeNotify({
                Title = "Config Loaded",
                Content = "Settings restored from profile!",
                Duration = 2,
                Icon = "download",
            })
        end
    end
end

TabConfig:Button({
    Title = "Save Current Config",
    Icon = "save",
    Callback = SaveProfile,
})

TabConfig:Button({
    Title = "Load Saved Config",
    Icon = "download",
    Callback = LoadProfile,
})

TabConfig:Button({
    Title = "Reset All Settings (All OFF)",
    Icon = "rotate-ccw",
    Callback = function()
        for k, _ in pairs(State) do
            if type(State[k]) == "boolean" then
                State[k] = false
            end
        end
        SafeNotify({
            Title = "Reset Complete",
            Content = "All features turned off.",
            Duration = 2,
            Icon = "check",
        })
    end,
})

TabConfig:Section({
    Title = "Promo Codes",
    Opened = true,
})

local EnteredCode = ""

TabConfig:Input({
    Title = "Promo Code",
    Desc = "Enter secret promo code to redeem",
    Placeholder = "e.g. RELEASE",
    Callback = function(text)
        EnteredCode = text
    end,
})

TabConfig:Button({
    Title = "Redeem Code",
    Icon = "key",
    Callback = function()
        if EnteredCode == "" then
            SafeNotify({
                Title = "Code Empty",
                Content = "Please type a code first.",
                Duration = 2,
                Icon = "alert-circle",
            })
            return
        end
        pcall(function()
            local res = Remotes.Rewards:InvokeServer("redeem", EnteredCode)
            if res and res.ok then
                SafeNotify({
                    Title = "Code Redeemed",
                    Content = res.msg or "Reward claimed successfully!",
                    Duration = 3,
                    Icon = "check",
                })
            else
                SafeNotify({
                    Title = "Redeem Failed",
                    Content = (res and res.msg) or "Invalid code.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Clean Unload Script",
    Icon = "trash-2",
    Callback = function()
        if getgenv()._NET_A_FISH_UNLOAD then
            getgenv()._NET_A_FISH_UNLOAD()
        end
    end,
})

-- =========================================================================
-- BACKGROUND WORKERS & AUTOMATION ENGINES
-- =========================================================================

-- Worker 1: Core Fishing Loop Engine (0.15s Tick)
local lastCastTime = 0
local lastReelTime = 0

RegisterTask(task.spawn(function()
    while true do
        if State.AutoThrowNet or State.FastCycleExploit then
            local myBase = GetMyBase()
            local netState = myBase and myBase:GetAttribute("NetState") or "Idle"

            -- Throw Net
            if netState == "Idle" and (os.clock() - lastCastTime > 0.8) then
                if not IsOnDock() and HumanoidRootPart then
                    HumanoidRootPart.CFrame = GetMyDockCFrame()
                    task.wait(0.2)
                end
                pcall(function()
                    Remotes.ThrowNet:FireServer()
                    lastCastTime = os.clock()
                end)
            end

            -- Reel In
            if (State.AutoReelIn or State.FastCycleExploit) and netState == "Fishing" then
                local shouldReel = false
                if State.FastCycleExploit or State.ReelMode == "Instant (Fastest)" then
                    shouldReel = true
                elseif State.ReelMode == "Wait Full Net" then
                    local count = myBase:GetAttribute("NetCount") or 0
                    local cap = myBase:GetAttribute("NetCap") or 1
                    if count >= cap then
                        shouldReel = true
                    end
                elseif State.ReelMode == "Custom Delay" then
                    if (os.clock() - lastCastTime) >= State.ReelDelay then
                        shouldReel = true
                    end
                end

                if shouldReel and (os.clock() - lastReelTime > 0.5) then
                    pcall(function()
                        Remotes.ReelIn:FireServer()
                        lastReelTime = os.clock()
                    end)
                end
            end

            -- Perfect Tap during reeling
            if (State.AutoPerfectTap or State.FastCycleExploit) and netState == "Reeling" then
                pcall(function()
                    Remotes.PerfectTap:FireServer(workspace:GetServerTimeNow())
                end)
            end
        end
        task.wait(0.15)
    end
end))

-- Worker 2: Auto Catch Modal Resolver
local function ResolveCatchList(caughtFish)
    if not (State.AutoCatchResolver or State.FastCycleExploit) then return end
    if type(caughtFish) ~= "table" then return end
    local decisions = {}
    local decisionType = "keep"
    if State.CatchDecision == "Sell All" then
        decisionType = "sell"
    elseif State.CatchDecision == "Place Best (Pedestal)" then
        decisionType = "place"
    end
    for _, fish in ipairs(caughtFish) do
        if fish.uid then
            decisions[tostring(fish.uid)] = decisionType
        end
    end
    pcall(function()
        Remotes.ResolveCatch:FireServer(decisions)
    end)
end

RegisterConnection(Remotes.CatchReady.OnClientEvent:Connect(function(caughtList)
    ResolveCatchList(caughtList)
end))

-- Worker 3: Base Pad Passive Income Collector (High-Yield Proximity Sweep Engine)
local isSweepingPads = false
local function SweepCollectPads()
    if isSweepingPads then return end
    isSweepingPads = true
    pcall(function()
        local myBase = GetMyBase()
        if not myBase then return end
        local peds = myBase:FindFirstChild("Pedestals")
        if not peds then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local origCF = hrp.CFrame
        local anyCollected = false

        for _, ped in ipairs(peds:GetChildren()) do
            if ped:GetAttribute("Open") == true then
                local slot = ped:GetAttribute("Slot")
                local collect = ped:FindFirstChild("Collect")
                local pad = collect and collect:FindFirstChild("Pad")
                if pad and slot then
                    hrp.CFrame = CFrame.new(pad.Position + Vector3.new(0, 1.8, 0))
                    task.wait(0.04)
                    Remotes.CollectPadReq:FireServer(slot)
                    anyCollected = true
                end
            end
        end

        if anyCollected then
            task.wait(0.04)
            hrp.CFrame = origCF
        end
    end)
    isSweepingPads = false
end

RegisterTask(task.spawn(function()
    while true do
        if State.AutoCollectPads then
            SweepCollectPads()
        end
        task.wait(4.0)
    end
end))

-- Worker 4: Cooler & Showcase Optimization Engine (4.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoCoolerFuseAll then
            AutoFuseCoolerFish()
        end
        if State.AutoOptimizeShowcase then
            OptimizeShowcasePedestals()
        end
        task.wait(4.0)
    end
end))

-- Worker 5: Auto Upgrades & Gear (2.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoBuyBestNet or State.AutoBuyUpgrades or State.AutoUpgradeSpear or State.AutoUpgradeBoat or State.AutoUpgradeHelper or State.AutoEquipBestSetup or State.AutoPotions then
            pcall(function()
                local data = Remotes.GetData:InvokeServer()
                if not data then return end
                local myCash = LocalPlayer:GetAttribute("Cash") or data.Cash or 0

                -- Buy Net
                if State.AutoBuyBestNet then
                    local currentTier = data.NetTier or (LocalPlayer:GetAttribute("NetTier") or 1)
                    local nextTier = currentTier + 1
                    local netInfo = FishingShared.Nets[nextTier]
                    if netInfo and myCash >= netInfo.Cost then
                        local rebOk = FishingShared.NetRebirthOk and FishingShared.NetRebirthOk(data, nextTier)
                        if rebOk ~= false then
                            Remotes.BuyItem:FireServer("Net", nextTier)
                            myCash = myCash - netInfo.Cost
                        end
                    end
                end

                -- Buy Base Upgrades (Filter Hidden, verify Rebirth requirements)
                if State.AutoBuyUpgrades then
                    for _, up in ipairs(FishingShared.Upgrades or {}) do
                        if not up.Hidden then
                            local id = up.Id
                            local curLvl = data.Upgrades and data.Upgrades[id] or 0
                            local maxLvl = up.Max or 35
                            if curLvl < maxLvl then
                                local cost = FishingShared.UpgradeCost(id, curLvl)
                                local ok = FishingShared.UpgradeLevelOk(data, up, curLvl + 1)
                                if ok and cost and cost <= myCash then
                                    Remotes.BuyItem:FireServer("Upgrade", id)
                                    myCash = myCash - cost
                                    task.wait(0.04)
                                end
                            end
                        end
                    end
                end

                -- Auto Best Setup
                if State.AutoEquipBestSetup then
                    Remotes.BestSetup:FireServer()
                end

                -- Auto Potions
                if State.AutoPotions then
                    Remotes.Potions:InvokeServer("auto", true)
                    Remotes.Potions:InvokeServer("useAll")
                end

                -- Spear Gun Upgrades (Up to max level 34)
                if State.AutoUpgradeSpear and FishingShared.SpearById then
                    for id, spearUp in pairs(FishingShared.SpearById) do
                        local curLvl = data.Spear and data.Spear[id] or 0
                        local maxLvl = spearUp.Max or 34
                        if curLvl < maxLvl then
                            local cost = FishingShared.SpearCost(id, curLvl)
                            local ok = FishingShared.HelperLevelOk and FishingShared.HelperLevelOk(data, spearUp, curLvl + 1)
                            if ok ~= false and cost and cost <= myCash then
                                Remotes.SpearAction:InvokeServer("buy", id)
                                myCash = myCash - cost
                                task.wait(0.04)
                            end
                        end
                    end
                end

                -- Boat Upgrades (Hull priority + Up to max level 34)
                if State.AutoUpgradeBoat and FishingShared.BoatUpgradeById then
                    pcall(function()
                        Remotes.BoatAction:InvokeServer("buy", "Hull")
                    end)
                    for id, boatUp in pairs(FishingShared.BoatUpgradeById) do
                        local curLvl = data.Boat and data.Boat[id] or 0
                        local maxLvl = boatUp.Max or 34
                        if curLvl < maxLvl then
                            local cost = FishingShared.BoatCost(id, curLvl)
                            local ok = FishingShared.HelperLevelOk and FishingShared.HelperLevelOk(data, boatUp, curLvl + 1)
                            if ok ~= false and cost and cost <= myCash then
                                Remotes.BoatAction:InvokeServer("buy", id)
                                myCash = myCash - cost
                                task.wait(0.04)
                            end
                        end
                    end
                end

                -- Helper Upgrades (Up to max level 34)
                if State.AutoUpgradeHelper and FishingShared.HelperById then
                    for id, helpUp in pairs(FishingShared.HelperById) do
                        local curLvl = data.Helper and data.Helper[id] or 0
                        local maxLvl = helpUp.Max or 34
                        if curLvl < maxLvl then
                            local cost = FishingShared.HelperCost(id, curLvl)
                            local ok = FishingShared.HelperLevelOk and FishingShared.HelperLevelOk(data, helpUp, curLvl + 1)
                            if ok ~= false and cost and cost <= myCash then
                                Remotes.HelperAction:InvokeServer("buy", id)
                                myCash = myCash - cost
                                task.wait(0.04)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(2.0)
    end
end))

-- Worker 6: Progression, Quests & Events (2.5s Tick)
RegisterTask(task.spawn(function()
    while true do
        -- Auto Rebirth
        if State.AutoRebirth then
            pcall(function()
                local data = Remotes.GetData:InvokeServer()
                if FishingShared.CanRebirth and FishingShared.CanRebirth(data) then
                    Remotes.RebirthRequest:FireServer()
                end
            end)
        end

        -- Auto Allocate Skill Tree
        if State.AutoAllocateSkills then
            pcall(function()
                local stState = Remotes.SkillTree:InvokeServer("state")
                if stState and (stState.free or 0) > 0 and SkillTreeModule.Nodes then
                    for _, node in ipairs(SkillTreeModule.Nodes) do
                        local curLvl = stState.skills and stState.skills[node.Id] or 0
                        if curLvl < node.Max and node.Cost <= stState.free then
                            local res = Remotes.SkillTree:InvokeServer("buy", node.Id)
                            if res and res.ok then
                                stState.free = stState.free - node.Cost
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end

        -- Auto Free Pearl Clam
        if State.AutoClaimFreeClam then
            pcall(function()
                if LocalPlayer:GetAttribute("PearlFreeClam") == true then
                    Remotes.PearlShop:InvokeServer("freeClam")
                end
            end)
        end

        -- Auto Index Page Rewards
        if State.AutoClaimIndexRewards then
            pcall(function()
                Remotes.Rewards:InvokeServer("pageRewards")
            end)
        end

        -- Auto Claim Contracts
        if State.AutoClaimContracts then
            pcall(function()
                local state = Remotes.Contracts:InvokeServer("state")
                if state and state.list then
                    for i, c in ipairs(state.list) do
                        if c.p and c.goal and c.p >= c.goal and c.k ~= "wait" then
                            Remotes.Contracts:InvokeServer("claim", i)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end

        -- Auto Claim Daily & Playtime Gifts
        if State.AutoClaimDaily or State.AutoClaimGifts or State.AutoClaimOffline then
            pcall(function()
                local rState = Remotes.Rewards:InvokeServer("state")
                if rState then
                    if State.AutoClaimDaily and rState.daily and rState.daily.claimable then
                        Remotes.Rewards:InvokeServer("claimDaily")
                    end
                    if State.AutoClaimGifts and rState.gifts then
                        for i, g in ipairs(rState.gifts) do
                            if g.ready and not g.claimed then
                                Remotes.Rewards:InvokeServer("claimGift", i)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end

        -- Auto Claim Season Pass
        pcall(function()
            local spState = Remotes.SeasonPass:InvokeServer("state")
            if spState and spState.claimable then
                for tier, ready in pairs(spState.claimable) do
                    if ready then
                        Remotes.SeasonPass:InvokeServer("claim", tier, false)
                        task.wait(0.1)
                    end
                end
            end
        end)

        -- Auto Equip Best Pet
        if State.AutoEquipBestPet then
            pcall(function()
                local pState = Remotes.Pets:InvokeServer("state")
                if pState and pState.pets then
                    local bestPet = nil
                    local bestMult = 0
                    for pId, count in pairs(pState.pets) do
                        if count > 0 then
                            local sp = FishingShared.PetById and FishingShared.PetById[pId]
                            local mult = sp and (sp.Mult or sp.Rarity) or 1
                            if mult > bestMult then
                                bestMult = mult
                                bestPet = pId
                            end
                        end
                    end
                    if bestPet and pState.equip ~= bestPet then
                        Remotes.Pets:InvokeServer("equip", bestPet)
                    end
                end
            end)
        end

        task.wait(2.5)
    end
end))

-- Worker 7: River Fish ESP Engine (0.5s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.RiverFishESP and ActiveESPFolder then
            pcall(function()
                local cf = workspace:FindFirstChild("ClientFish")
                if not cf then
                    ActiveESPFolder:ClearAllChildren()
                    return
                end

                local minRarityTier = RarityThresholds[State.ESPMinRarity] or 1
                local currentFishSet = {}

                for _, fish in ipairs(cf:GetChildren()) do
                    if fish:IsA("BasePart") then
                        currentFishSet[fish] = true
                        local fId = fish:GetAttribute("FishId") or fish.Name
                        local sp = FishingShared.SpeciesById and FishingShared.SpeciesById[fId]
                        local r = sp and sp.Rarity or 1

                        if r >= minRarityTier then
                            local bb = fish:FindFirstChild("_NetAFishBillboard")
                            if not bb then
                                bb = Instance.new("BillboardGui")
                                bb.Name = "_NetAFishBillboard"
                                bb.AlwaysOnTop = true
                                bb.Size = UDim2.fromOffset(180, 40)
                                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                bb.MaxDistance = 500

                                local lbl = Instance.new("TextLabel")
                                lbl.Name = "Tag"
                                lbl.BackgroundTransparency = 1
                                lbl.Size = UDim2.fromScale(1, 1)
                                lbl.Font = Enum.Font.FredokaOne
                                lbl.TextSize = 14
                                lbl.TextStrokeTransparency = 0
                                lbl.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
                                lbl.Parent = bb
                                bb.Parent = fish
                            end

                            local rInfo = FishingShared.Rarities[r]
                            local rColor = rInfo and rInfo.Color or Color3.fromRGB(255, 255, 255)
                            local mut = fish:GetAttribute("Mutation")
                            local dist = HumanoidRootPart and math.floor((HumanoidRootPart.Position - fish.Position).Magnitude) or 0

                            local tagText = (sp and sp.Name or fId)
                            if State.ESPShowMutations and mut and mut ~= "" then
                                tagText = "[" .. string.upper(mut) .. "] " .. tagText
                            end
                            tagText = string.format("[%s] %s", rInfo and rInfo.Name or "Fish", tagText)
                            if State.ESPShowDistance then
                                tagText = tagText .. string.format(" (%d studs)", dist)
                            end

                            local tagLabel = bb:FindFirstChild("Tag")
                            if tagLabel then
                                tagLabel.Text = tagText
                                tagLabel.TextColor3 = rColor
                            end
                        else
                            local existing = fish:FindFirstChild("_NetAFishBillboard")
                            if existing then
                                existing:Destroy()
                            end
                        end
                    end
                end
            end)
        else
            pcall(function()
                local cf = workspace:FindFirstChild("ClientFish")
                if cf then
                    for _, fish in ipairs(cf:GetChildren()) do
                        local bb = fish:FindFirstChild("_NetAFishBillboard")
                        if bb then
                            bb:Destroy()
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end))

-- Worker 8: Physics, Movement & Noclip (Stepped Engine)
RegisterConnection(RunService.Stepped:Connect(function()
    if Character then
        if State.CustomWalkSpeed and Humanoid then
            Humanoid.WalkSpeed = State.WalkSpeedValue
        end
        if State.CustomJumpPower and Humanoid then
            Humanoid.JumpPower = State.JumpPowerValue
        end
        if State.Noclip then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end))

-- Worker 9: Infinite Jump
RegisterConnection(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- Worker 10: Anti-AFK Protection
RegisterConnection(LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        pcall(function()
            Remotes.AFKRejoinPing:FireServer()
        end)
    end
end))

-- Worker 11: Dynamic HUD Status Updater (1.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        pcall(function()
            local myBase = GetMyBase()
            local netState = myBase and myBase:GetAttribute("NetState") or "Idle"
            local netCount = myBase and myBase:GetAttribute("NetCount") or 0
            local netCap = myBase and myBase:GetAttribute("NetCap") or 0
            local netTier = myBase and myBase:GetAttribute("NetTier") or (LocalPlayer:GetAttribute("NetTier") or 1)
            local netInfo = FishingShared.Nets[netTier]
            local netName = netInfo and netInfo.Name or ("Tier " .. tostring(netTier))

            FishingStatus:SetTitle("Net Status: " .. string.upper(netState))
            FishingStatus:SetDesc(string.format(
                "Net: %s (Tier %d)\nSpace: %d / %d fish\nOn Dock: %s",
                netName, netTier, netCount, netCap, IsOnDock() and "YES" or "NO"
            ))

            local cash = LocalPlayer:GetAttribute("Cash") or 0
            local rebirths = LocalPlayer:GetAttribute("Rebirths") or 0
            local pearls = LocalPlayer:GetAttribute("Pearls") or 0
            local inc = LocalPlayer:GetAttribute("IncomePerSec") or 0

            EconomyStatus:SetTitle("Economy Overview")
            EconomyStatus:SetDesc(string.format(
                "Cash: $%s\nShowcase Income: +$%s / sec\nRebirths: %d  |  Pearls: %d",
                FishingShared.Money(cash), FishingShared.Money(inc), rebirths, pearls
            ))

            UpgradeStatus:SetTitle("Equipped Net: " .. netName)
            UpgradeStatus:SetDesc(string.format(
                "Max Rarity: %s\nReach: %.1f studs\nCapacity: %d fish",
                netInfo and (FishingShared.Rarities[netInfo.MaxRarity] and FishingShared.Rarities[netInfo.MaxRarity].Name or "Unknown") or "?",
                netInfo and netInfo.Reach or 0,
                netCap
            ))

            local skPts = LocalPlayer:GetAttribute("SkillPoints") or 0
            ProgressStatus:SetTitle("Progression & Skills")
            ProgressStatus:SetDesc(string.format(
                "Rebirths: %d\nUnspent Skill Points: %d\nFree Clam: %s",
                rebirths, skPts, LocalPlayer:GetAttribute("PearlFreeClam") and "READY!" or "Claimed"
            ))
        end)
        task.wait(1.0)
    end
end))

-- Worker 12: Screen Cleaners, Popup Suppressor & Cutscene Skipper
RegisterTask(task.spawn(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local rrui = pg:WaitForChild("RareRevealUI")
    local vim = game:GetService("VirtualInputManager")

    local isDismissing = false
    local function DismissRareReveal()
        if not State.HideCatchPopups or isDismissing then return end
        isDismissing = true
        rrui.Enabled = false
        task.spawn(function()
            local startT = os.clock()
            while os.clock() - startT < 3.0 do
                rrui.Enabled = false
                for _, btn in ipairs(rrui:GetDescendants()) do
                    if btn:IsA("TextButton") then
                        pcall(function() firesignal(btn.MouseButton1Click) end)
                    end
                end
                pcall(function()
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.03)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
                if #rrui:GetChildren() == 0 then break end
                task.wait(0.08)
            end
            rrui.Enabled = false
            isDismissing = false
        end)
    end

    rrui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if rrui.Enabled and State.HideCatchPopups then
            DismissRareReveal()
        end
    end)

    rrui.ChildAdded:Connect(function()
        if State.HideCatchPopups then
            DismissRareReveal()
        end
    end)

    while true do
        task.wait(0.15)
        -- Keep cutscene attribute synced
        if State.DisableCutscenes then
            if LocalPlayer:GetAttribute("Set_Cutscenes") ~= false then
                pcall(function() LocalPlayer:SetAttribute("Set_Cutscenes", false) end)
            end
        end

        -- Active RareRevealUI fallback
        if State.HideCatchPopups and rrui.Enabled then
            DismissRareReveal()
        end

        -- Auto close Boss Loot screens (KrakenLootUI, MegEndUI, BloopEndUI)
        if State.AutoCloseBossLoot then
            for _, name in ipairs({"KrakenLootUI", "MegEndUI", "BloopEndUI"}) do
                local ui = pg:FindFirstChild(name)
                if ui and ui:IsA("ScreenGui") and ui.Enabled then
                    for _, d in ipairs(ui:GetDescendants()) do
                        if d:IsA("TextButton") and (d.Name:lower():find("close") or d.Name:lower():find("leave") or d.Text:lower():find("continue") or d.Text:lower():find("close")) then
                            pcall(function() firesignal(d.MouseButton1Click) end)
                        end
                    end
                end
            end
        end
    end
end))