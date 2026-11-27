-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    DRAGON ARENA â MASTER AUTOMATION SUITE (PRODUCTION BUILD v2.0)
    Universal High-Performance Client-Side Automation Engine
    UI Framework: WindUI | Language: English (Universal)
    Keybind: LeftControl | Floating Button: Enabled (Draggable) | Default: ALL OFF
    ========================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean previous instances upon re-execution
if getgenv().DragonArenaUnload then
    pcall(getgenv().DragonArenaUnload)
end

local Cleanups = {}
getgenv().DragonArenaUnload = function()
    for _, fn in ipairs(Cleanups) do
        task.spawn(fn)
    end
    getgenv().DragonArenaWindow = nil
    getgenv().DragonArenaTabs = nil
    getgenv().DragonArenaState = nil
    getgenv().DragonArenaElements = nil
    getgenv().DragonArenaUnload = nil
end

-- =========================================================================
-- 1. FLAMEWORK CONTROLLER RESOLVER
-- =========================================================================
local Core = require(ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@flamework"):WaitForChild("core"):WaitForChild("out"))
local Flamework = Core.Flamework
local Reflect = Core.Reflect

local ControllerCache = {}
local function getController(name)
    if ControllerCache[name] then
        return ControllerCache[name]
    end
    for id, obj in pairs(Reflect.idToObj) do
        if tostring(obj) == name then
            local success, inst = pcall(function()
                return Flamework.resolveDependency(id)
            end)
            if success and inst then
                ControllerCache[name] = inst
                return inst
            end
        end
    end
    return nil
end

-- Resolve singletons
local fightCtrl = getController("FightController")
local orbCtrl = getController("OrbController")
local eggPedCtrl = getController("EggPedestalController")
local renderCtrl = getController("EggPedestalRenderController")
local nestCtrl = getController("NestController")
local eggCtrl = getController("EggController")
local dragonCtrl = getController("DragonController")
local teamCtrl = getController("TeamController")
local statCtrl = getController("StatUpgradeController")
local plotUpgradeCtrl = getController("PlotUpgradeController")
local foodCtrl = getController("FoodController")
local sellerCtrl = getController("SellerController")
local indexCtrl = getController("IndexController")
local wishCtrl = getController("WishingWellController")
local luckyCtrl = getController("LuckyFieldController")
local stayCtrl = getController("StayController")
local groupCtrl = getController("GroupController")
local codeCtrl = getController("CodeController")
local currCtrl = getController("CurrencyController")
local plotCtrl = getController("PlotController")
local powerCtrl = getController("PowerInventoryController")
local breedCtrl = getController("BreedController")

local dragonMgr = nil
for id, obj in pairs(Reflect.idToObj) do
    if tostring(obj) == "DragonManager" then
        local s, inst = pcall(function() return Flamework.resolveDependency(id) end)
        if s and inst then dragonMgr = inst end
        break
    end
end

-- =========================================================================
-- 2. STATE STORAGE
-- =========================================================================
local CONFIG_FILE = "DragonArena_Config.json"

local State = {
    -- Combat
    AutoBattle = false,
    FastSpeed = false,
    AutoRevive = false,
    AutoSkipCutscenes = false,
    AutoDismissResults = false,
    InstantOrbCollect = false,

    -- Hatchery & Quality Filtering
    AutoRollPedestal = false,
    RollDelay = 1.5,
    AutoBuyEggs = false,
    TargetEggType = "All Eggs",
    MinEggLevel = 3,
    SkipCommonEggs = true,
    AutoPlaceEggs = false,
    AutoPlaceDragons = false,
    AutoHatchEggs = false,
    AutoCollectDragons = false,
    AutoSkipTimer = false,
    AutoBuyNests = false,

    -- Breeding Automation (High-Tier Scaling)
    AutoBreed = false,
    AutoFastBreed = false,
    AutoCollectBreed = false,

    -- Progression
    AutoEquipBest = false,
    AutoUpgradeLuck = false,
    AutoUpgradePedestals = false,
    AutoUpgradePlot = false,
    AutoFeedMeat = false,
    AutoRollPowers = false,
    AutoSellPeriodically = false,

    -- Rewards & Utilities
    AutoClaimIndex = false,
    AutoWishingWell = false,
    AutoLuckyField = false,
    AutoClaimStay = false,
    AutoClaimGroup = false,

    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,

    -- Visuals / ESP
    PedestalESP = false,
    ArenaMobsESP = false,
    PlotsESP = false
}

local UI_Elements = {}

-- =========================================================================
-- 3. LOAD WINDUI
-- =========================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Dragon Arena",
    Icon = "flame",
    Author = "by XLUNA HUB",
    Folder = "DragonArena",
    Size = UDim2.fromOffset(620, 490),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Dragon Arena",
        Icon = "flame",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 1,
        Color = ColorSequence.new(Color3.fromRGB(255, 85, 0), Color3.fromRGB(255, 0, 128)),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true
    }
})

table.insert(Cleanups, function()
    pcall(function()
        if Window and Window.Parent and Window.Parent.Parent then
            Window.Parent.Parent:Destroy()
        elseif Window then
            Window:Destroy()
        end
    end)
end)

local function notify(title, msg, duration)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = msg,
            Duration = duration or 3
        })
    end)
end

-- =========================================================================
-- 4. TABS SETUP
-- =========================================================================
local TabCombat = Window:Tab({ Title = "Combat", Icon = "swords" })
local TabHatchery = Window:Tab({ Title = "Hatchery", Icon = "egg" })
local TabProgression = Window:Tab({ Title = "Progression", Icon = "trending-up" })
local TabRewards = Window:Tab({ Title = "Rewards", Icon = "gift" })
local TabMovement = Window:Tab({ Title = "Movement", Icon = "zap" })
local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- -------------------------------------------------------------------------
-- TAB 1: COMBAT & DROP MAGNET
-- -------------------------------------------------------------------------
TabCombat:Section({ Title = "Live Combat Telemetry" })

local CombatDashboard = TabCombat:Paragraph({
    Title = "â¡ Combat Telemetry & Team Power",
    Desc = "Calculating live combat metrics..."
})

TabCombat:Section({ Title = "Battle Automation" })

UI_Elements.AutoBattle = TabCombat:Toggle({
    Title = "Auto Battle",
    Desc = "Enforces in-game auto fight mode and starts battle automatically",
    Value = false,
    Callback = function(v)
        State.AutoBattle = v
        if v and fightCtrl then
            pcall(function()
                if not fightCtrl:isAutoFightSelected() then
                    fightCtrl:setAutoFight(true)
                end
                if not fightCtrl:isFighting() then
                    fightCtrl:startFight()
                end
            end)
            notify("Combat", "Auto Battle engaged!", 2)
        end
    end
})

local fastSpeedNotified = false
UI_Elements.FastSpeed = TabCombat:Toggle({
    Title = "Force 2.5x Speed",
    Desc = "Enforces fast combat execution speed on the server (Gamepass check)",
    Value = false,
    Callback = function(v)
        State.FastSpeed = v
        if v and fightCtrl then
            pcall(function()
                fightCtrl:setFastSpeed(true):catch(function()
                    if not fastSpeedNotified then
                        fastSpeedNotified = true
                        notify("Speed", "Server requires x2 Fight Speed Gamepass.", 3)
                    end
                end)
            end)
        end
    end
})

UI_Elements.AutoRevive = TabCombat:Toggle({
    Title = "Auto Revive (Endless Farm)",
    Desc = "Instantly revives fallen dragons upon defeat to sustain combat",
    Value = false,
    Callback = function(v)
        State.AutoRevive = v
    end
})

UI_Elements.AutoSkipCutscenes = TabCombat:Toggle({
    Title = "Auto Skip Boss Cutscenes",
    Desc = "Instantly clears boss introduction cutscenes",
    Value = false,
    Callback = function(v)
        State.AutoSkipCutscenes = v
    end
})

UI_Elements.AutoDismissResults = TabCombat:Toggle({
    Title = "Auto Dismiss Victory / Defeat Screen",
    Desc = "Closes result dialog immediately to maximize waves per minute",
    Value = false,
    Callback = function(v)
        State.AutoDismissResults = v
    end
})

TabCombat:Section({ Title = "Drop Magnet (Wild Exploit)" })

UI_Elements.InstantOrbCollect = TabCombat:Toggle({
    Title = "Instant Orb Collect",
    Desc = "Direct server RPC drop pickup for 100% of mob & boss drops",
    Value = false,
    Callback = function(v)
        State.InstantOrbCollect = v
        if v then
            notify("Magnet", "Instant Orb Magnet activated!", 2)
        end
    end
})

-- -------------------------------------------------------------------------
-- TAB 2: HATCHERY & EGGS
-- -------------------------------------------------------------------------
TabHatchery:Section({ Title = "Live Hatchery Status" })

local HatcheryDashboard = TabHatchery:Paragraph({
    Title = "â¡ Hatchery & Breeding Status",
    Desc = "Calculating nests and breeding metrics..."
})

TabHatchery:Section({ Title = "Pedestal Operations" })

UI_Elements.AutoRollPedestal = TabHatchery:Toggle({
    Title = "Auto Roll Pedestals",
    Desc = "Continuously rolls pedestal slots with real lever animation & pipe drops",
    Value = false,
    Callback = function(v)
        State.AutoRollPedestal = v
        if v then
            notify("Hatchery", "Auto Roll Pedestals enabled!", 2)
        end
    end
})

UI_Elements.RollDelay = TabHatchery:Slider({
    Title = "Roll Delay (Seconds)",
    Desc = "Cooldown between pedestal pulls",
    Value = { Min = 0.5, Max = 5, Default = 1.5 },
    Callback = function(v)
        State.RollDelay = v
    end
})

UI_Elements.AutoBuyEggs = TabHatchery:Toggle({
    Title = "Auto Buy Pedestal Eggs",
    Desc = "Purchases matching eggs from pedestal pipes automatically",
    Value = false,
    Callback = function(v)
        State.AutoBuyEggs = v
        if v then
            notify("Hatchery", "Auto Buy Pedestal Eggs enabled!", 2)
        end
    end
})

UI_Elements.MinEggLevel = TabHatchery:Slider({
    Title = "Min Egg Level Filter",
    Desc = "Min level to buy. Recommended: 3 or 4. Note: Level 7 requires 64 identical pipe merges (~45 mins)!",
    Value = { Min = 1, Max = 10, Default = 3 },
    Callback = function(v)
        State.MinEggLevel = v
    end
})

UI_Elements.SkipCommonEggs = TabHatchery:Toggle({
    Title = "Skip Level 1 Common Eggs",
    Desc = "Never buy level 1 Rock and Blaze eggs (stops buying trash eggs)",
    Value = true,
    Callback = function(v)
        State.SkipCommonEggs = v
    end
})

UI_Elements.TargetEggType = TabHatchery:Dropdown({
    Title = "Target Egg Filter",
    Desc = "Species or egg type to target for auto-purchase",
    Values = {
        "All Eggs",
        "Mutated Only",
        "RockEgg",
        "BlazeEgg",
        "TideEgg",
        "FrostEgg",
        "FlameEgg",
        "CryolithEgg",
        "EmberstoneEgg",
        "MountainEgg"
    },
    Value = "All Eggs",
    Callback = function(v)
        State.TargetEggType = v
    end
})

TabHatchery:Section({ Title = "Nest Automation" })

UI_Elements.AutoPlaceEggs = TabHatchery:Toggle({
    Title = "Auto Place Eggs to Nests",
    Desc = "Transfers unplaced eggs from bag into empty nests",
    Value = false,
    Callback = function(v)
        State.AutoPlaceEggs = v
        if v then
            local unplaced = eggCtrl and eggCtrl:getUnplacedEggs() or {}
            if #unplaced == 0 then
                notify("Hatchery", "Auto Place active: 0 eggs in bag. Enable 'Auto Buy Pedestal Eggs' to supply eggs!", 3.5)
            else
                notify("Hatchery", string.format("Auto Place active: %d egg(s) in bag queued for nests!", #unplaced), 3)
            end
        end
    end
})

UI_Elements.AutoPlaceDragons = TabHatchery:Toggle({
    Title = "Auto Place Dragons to Nests",
    Desc = "Transfers unnested idle dragons from bag into available nests",
    Value = false,
    Callback = function(v)
        State.AutoPlaceDragons = v
        if v then
            notify("Hatchery", "Auto Place Dragons to Nests enabled!", 2.5)
        end
    end
})

TabHatchery:Button({
    Title = "Place All Dragons to Nests Now",
    Desc = "Instantly fills empty nests with unnested dragons via direct Remote",
    Callback = function()
        if dragonCtrl and nestCtrl then
            local freeNests = nestCtrl:getFreeNests()
            local allDragons = dragonCtrl:getDragons()
            local unnested = {}
            for _, d in ipairs(allDragons) do
                if not nestCtrl:isNested(d.id) then
                    table.insert(unnested, d)
                end
            end
            if #freeNests == 0 then
                notify("Hatchery", "No free nests available!", 2.5)
                return
            end
            if #unnested == 0 then
                notify("Hatchery", "All owned dragons are already nested!", 2.5)
                return
            end
            local placed = 0
            for i = 1, math.min(#freeNests, #unnested) do
                local s = pcall(function()
                    nestCtrl:placeDragon(freeNests[i], unnested[i].id):expect()
                end)
                if s then placed = placed + 1 end
            end
            notify("Hatchery", string.format("Placed %d dragon(s) into nests!", placed), 3)
        end
    end
})

TabHatchery:Button({
    Title = "Recall All Dragons from Nests Now",
    Desc = "Pulls all resting dragons from nests back into your bag",
    Callback = function()
        if nestCtrl then
            local owned = nestCtrl:getOwnedNests()
            local recalled = 0
            for _, id in ipairs(owned) do
                local c = nestCtrl:getContent(id)
                if c and c.kind == "dragon" then
                    local s = pcall(function()
                        nestCtrl:takeDragon(id):expect()
                    end)
                    if s then recalled = recalled + 1 end
                end
            end
            notify("Hatchery", string.format("Recalled %d dragon(s) to bag!", recalled), 3)
        end
    end
})

UI_Elements.AutoSkipTimer = TabHatchery:Toggle({
    Title = "Fast Hatch (Skip Timer)",
    Desc = "Instantly clears incubation countdown timer (0s left)",
    Value = false,
    Callback = function(v)
        State.AutoSkipTimer = v
        if v then
            notify("Hatchery", "Fast Hatch (Skip Timer) enabled!", 2)
        end
    end
})

UI_Elements.AutoHatchEggs = TabHatchery:Toggle({
    Title = "Auto Hatch Ready Eggs",
    Desc = "Opens nests immediately once countdown completes",
    Value = false,
    Callback = function(v)
        State.AutoHatchEggs = v
        if v then
            notify("Hatchery", "Auto Hatch Ready Eggs enabled!", 2)
        end
    end
})

UI_Elements.AutoCollectDragons = TabHatchery:Toggle({
    Title = "Auto Take Hatched Dragons",
    Desc = "Claims baby dragons from hatched nests into inventory",
    Value = false,
    Callback = function(v)
        State.AutoCollectDragons = v
        if v then
            notify("Hatchery", "Auto Collect Dragons enabled!", 2)
        end
    end
})

UI_Elements.AutoBuyNests = TabHatchery:Toggle({
    Title = "Auto Buy New Nests",
    Desc = "Purchases additional nest slots whenever coins permit",
    Value = false,
    Callback = function(v)
        State.AutoBuyNests = v
    end
})

TabHatchery:Section({ Title = "Breeding Automation (High-Tier Evolution)" })

UI_Elements.AutoBreed = TabHatchery:Toggle({
    Title = "Auto Breed Reserve Dragons",
    Desc = "Continuously pairs highest-level idle dragons in free frames to breed Mythic & Godly species",
    Value = false,
    Callback = function(v)
        State.AutoBreed = v
        if v then
            notify("Breeding", "Auto Breed Reserve Dragons enabled!", 2.5)
        end
    end
})

UI_Elements.AutoFastBreed = TabHatchery:Toggle({
    Title = "Auto Fast Breed (Skip Timer)",
    Desc = "Instantly clears incubation countdown for breeding nests",
    Value = false,
    Callback = function(v)
        State.AutoFastBreed = v
        if v then
            notify("Breeding", "Fast Breed (Skip Timer) enabled!", 2)
        end
    end
})

UI_Elements.AutoCollectBreed = TabHatchery:Toggle({
    Title = "Auto Hatch & Deploy Offspring",
    Desc = "Opens completed breeding eggs and auto-deploys higher power dragons into battle",
    Value = false,
    Callback = function(v)
        State.AutoCollectBreed = v
        if v then
            notify("Breeding", "Auto Collect Breed enabled!", 2)
        end
    end
})

TabHatchery:Button({
    Title = "Instant Breed Best Pair Now",
    Desc = "Immediately pairs top 2 idle reserve dragons into an available breeding frame",
    Callback = function()
        if breedCtrl and dragonCtrl and teamCtrl and nestCtrl then
            if breedCtrl:getFreeFrames() <= 0 then
                notify("Breeding", "No free breeding frames available!", 2.5)
                return
            end
            local allDragons = dragonCtrl:getDragons()
            local equipped = teamCtrl:getEquipped()
            local freeNests = nestCtrl:getFreeNests()
            local candidates = {}
            for _, d in ipairs(allDragons) do
                local isFighting = table.find(equipped, d.id) ~= nil
                local isBreeding = breedCtrl:isBreeding(d.id)
                if not isFighting and not isBreeding then
                    table.insert(candidates, d)
                end
            end
            if #candidates < 2 then
                notify("Breeding", string.format("Need at least 2 idle reserve dragons! Current: %d", #candidates), 3)
                return
            end
            table.sort(candidates, function(a, b)
                return (a.level or 0) > (b.level or 0)
            end)

            local readyToBreed = {}
            for _, d in ipairs(candidates) do
                if nestCtrl:isNested(d.id) then
                    table.insert(readyToBreed, d)
                elseif #freeNests > 0 then
                    local nestId = table.remove(freeNests, 1)
                    local ok = pcall(function()
                        nestCtrl:placeDragon(nestId, d.id):expect()
                    end)
                    if ok then
                        table.insert(readyToBreed, d)
                    end
                end
                if #readyToBreed >= 2 then break end
            end

            if #readyToBreed < 2 then
                notify("Breeding", "Cannot start breed: dragons must be in nests! Please free nests or wait.", 3.5)
                return
            end

            local p1 = readyToBreed[1]
            local p2 = readyToBreed[2]
            local s, res = pcall(function()
                return breedCtrl:startBreed(p1.id, p2.id)
            end)
            if s and res then
                notify("Breeding", string.format("Started breeding %s (Lvl %d) + %s (Lvl %d)!", p1.species, p1.level, p2.species, p2.level), 3)
            else
                notify("Breeding", "Breed start failed: " .. tostring(res), 3)
            end
        end
    end
})

-- -------------------------------------------------------------------------
-- TAB 3: PROGRESSION & TEAM
-- -------------------------------------------------------------------------
TabProgression:Section({ Title = "Live Progression Dashboard" })

local ProgressionDashboard = TabProgression:Paragraph({
    Title = "â¡ Real-Time Progression Metrics",
    Desc = "Calculating live team power & growth..."
})

TabProgression:Section({ Title = "Team Optimization" })

UI_Elements.AutoEquipBest = TabProgression:Toggle({
    Title = "Auto Equip Best Dragons",
    Desc = "Automatically deploys your strongest dragons into battle slots",
    Value = false,
    Callback = function(v)
        State.AutoEquipBest = v
    end
})

TabProgression:Button({
    Title = "Equip Best Now",
    Desc = "Trigger instant best-dragon deployment",
    Callback = function()
        if teamCtrl then
            pcall(function() teamCtrl:equipBest() end)
            notify("Team", "Best dragons equipped successfully!", 2)
        end
    end
})

TabProgression:Button({
    Title = "Unequip All Now",
    Desc = "Remove all dragons from team slots",
    Callback = function()
        if teamCtrl then
            pcall(function() teamCtrl:unequipAll() end)
            notify("Team", "All dragons unequipped.", 2)
        end
    end
})

TabProgression:Section({ Title = "Upgrades & Skills" })

UI_Elements.AutoUpgradeLuck = TabProgression:Toggle({
    Title = "Auto Upgrade Egg Luck",
    Desc = "Automatically buys next level of Egg Luck stat upgrade when coins permit",
    Value = false,
    Callback = function(v)
        State.AutoUpgradeLuck = v
    end
})

UI_Elements.AutoUpgradePedestals = TabProgression:Toggle({
    Title = "Auto Upgrade Rolling Pedestals",
    Desc = "Unlocks extra rolling pipes and pedestal slots when coins permit",
    Value = false,
    Callback = function(v)
        State.AutoUpgradePedestals = v
    end
})

UI_Elements.AutoUpgradePlot = TabProgression:Toggle({
    Title = "Auto Upgrade Plot Floor",
    Desc = "Upgrades your plot level and unlocks additional floors when conditions are met",
    Value = false,
    Callback = function(v)
        State.AutoUpgradePlot = v
    end
})

UI_Elements.AutoFeedMeat = TabProgression:Toggle({
    Title = "Auto Feed Equipped Dragons",
    Desc = "Consumes available meat to level up your active dragons",
    Value = false,
    Callback = function(v)
        State.AutoFeedMeat = v
    end
})

UI_Elements.AutoRollPowers = TabProgression:Toggle({
    Title = "Auto Roll Powers (Free Spins Only)",
    Desc = "Consumes available free spins at the Dragon Power desk",
    Value = false,
    Callback = function(v)
        State.AutoRollPowers = v
    end
})

TabProgression:Section({ Title = "Marketplace Selling" })

TabProgression:Button({
    Title = "Sell All Duplicate/Unused Now",
    Desc = "Instantly clears sellable dragons and eggs for coins",
    Callback = function()
        if sellerCtrl then
            pcall(function() sellerCtrl:sellAll() end)
            notify("Seller", "Sell all triggered!", 2)
        end
    end
})

UI_Elements.AutoSellPeriodically = TabProgression:Toggle({
    Title = "Auto Sell Periodically",
    Desc = "Runs sell-all every 30 seconds to prevent inventory clog",
    Value = false,
    Callback = function(v)
        State.AutoSellPeriodically = v
    end
})

-- -------------------------------------------------------------------------
-- TAB 4: REWARDS & UTILITIES
-- -------------------------------------------------------------------------
TabRewards:Section({ Title = "Automated Claimers" })

UI_Elements.AutoClaimIndex = TabRewards:Toggle({
    Title = "Auto Claim Index Collection",
    Desc = "Claims all discovered dragon index rewards & permanent luck buffs",
    Value = false,
    Callback = function(v)
        State.AutoClaimIndex = v
    end
})

UI_Elements.AutoWishingWell = TabRewards:Toggle({
    Title = "Auto Wishing Well",
    Desc = "Triggers free wishes and collects pending rewards",
    Value = false,
    Callback = function(v)
        State.AutoWishingWell = v
    end
})

UI_Elements.AutoLuckyField = TabRewards:Toggle({
    Title = "Auto Lucky Field Boost",
    Desc = "Activates the Lucky Field surge boost when available",
    Value = false,
    Callback = function(v)
        State.AutoLuckyField = v
    end
})

UI_Elements.AutoClaimStay = TabRewards:Toggle({
    Title = "Auto Claim Playtime Rewards",
    Desc = "Claims all unlocked online stay rewards automatically",
    Value = false,
    Callback = function(v)
        State.AutoClaimStay = v
    end
})

UI_Elements.AutoClaimGroup = TabRewards:Toggle({
    Title = "Auto Claim Group Rewards",
    Desc = "Claims daily Roblox group reward sign",
    Value = false,
    Callback = function(v)
        State.AutoClaimGroup = v
    end
})

TabRewards:Section({ Title = "Promo Codes" })

TabRewards:Button({
    Title = "Redeem All Active Codes",
    Desc = "Redeems 'freeSpin' (250 gems) & 'release' (potions)",
    Callback = function()
        if codeCtrl and codeCtrl.net then
            for _, c in ipairs({"freeSpin", "release"}) do
                pcall(function() codeCtrl.net:call("redeem", c):expect() end)
            end
            notify("Codes", "Active codes redeemed successfully!", 3)
        end
    end
})

-- -------------------------------------------------------------------------
-- TAB 5: MOVEMENT & TELEPORT
-- -------------------------------------------------------------------------
TabMovement:Section({ Title = "Character Modifiers" })

UI_Elements.WalkSpeed = TabMovement:Slider({
    Title = "WalkSpeed",
    Desc = "Adjust player movement velocity",
    Value = { Min = 16, Max = 150, Default = 16 },
    Callback = function(v)
        State.WalkSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

UI_Elements.JumpPower = TabMovement:Slider({
    Title = "JumpPower",
    Desc = "Adjust jump velocity height",
    Value = { Min = 50, Max = 250, Default = 50 },
    Callback = function(v)
        State.JumpPower = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end
})

UI_Elements.InfiniteJump = TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air",
    Value = false,
    Callback = function(v)
        State.InfiniteJump = v
    end
})

UI_Elements.NoClip = TabMovement:Toggle({
    Title = "NoClip",
    Desc = "Phase freely through terrain and geometry",
    Value = false,
    Callback = function(v)
        State.NoClip = v
    end
})

UI_Elements.Fly = TabMovement:Toggle({
    Title = "Flight Mode",
    Desc = "Free 3D camera-directed flight",
    Value = false,
    Callback = function(v)
        State.Fly = v
    end
})

UI_Elements.FlySpeed = TabMovement:Slider({
    Title = "Flight Velocity",
    Desc = "Flight travel speed",
    Value = { Min = 10, Max = 150, Default = 50 },
    Callback = function(v)
        State.FlySpeed = v
    end
})

TabMovement:Section({ Title = "World Teleports" })

local function safeTeleport(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

TabMovement:Button({
    Title = "Teleport: My Plot Base",
    Desc = "Return to your personal DragonPlot spawn",
    Callback = function()
        if plotCtrl then
            local p = plotCtrl:getPlot()
            if p and p:FindFirstChild("SpawnPos") then
                safeTeleport(p.SpawnPos.Position)
            elseif p then
                safeTeleport(p:GetPivot().Position)
            end
        end
    end
})

TabMovement:Button({
    Title = "Teleport: Egg Pedestals",
    Desc = "Warp directly in front of the egg roll pedestal",
    Callback = function()
        if plotCtrl then
            local p = plotCtrl:getPlot()
            if p and p:FindFirstChild("EggPedestal") then
                safeTeleport(p.EggPedestal:GetPivot().Position)
            end
        end
    end
})

TabMovement:Button({
    Title = "Teleport: Wishing Well",
    Desc = "Warp to your plot's Wishing Well container",
    Callback = function()
        if plotCtrl then
            local p = plotCtrl:getPlot()
            if p and p:FindFirstChild("WishingWellContainer") then
                safeTeleport(p.WishingWellContainer:GetPivot().Position)
            end
        end
    end
})

TabMovement:Button({
    Title = "Teleport: Dragon Power Desk",
    Desc = "Warp to the power roll and ability shrine",
    Callback = function()
        if plotCtrl then
            local p = plotCtrl:getPlot()
            if p and p:FindFirstChild("DragonPower") then
                safeTeleport(p.DragonPower:GetPivot().Position)
            end
        end
    end
})

TabMovement:Button({
    Title = "Teleport: Lucky Field",
    Desc = "Warp to the Lucky Field activator",
    Callback = function()
        if plotCtrl then
            local p = plotCtrl:getPlot()
            if p and p:FindFirstChild("LuckySlot") then
                safeTeleport(p.LuckySlot:GetPivot().Position)
            end
        end
    end
})

-- -------------------------------------------------------------------------
-- TAB 6: VISUALS / ESP
-- -------------------------------------------------------------------------
TabVisuals:Section({ Title = "Overlays & Highlights" })

UI_Elements.PedestalESP = TabVisuals:Toggle({
    Title = "Egg Pedestal ESP",
    Desc = "Displays 3D billboard with Egg Type, Mutation, and Price over pipes",
    Value = false,
    Callback = function(v)
        State.PedestalESP = v
    end
})

UI_Elements.ArenaMobsESP = TabVisuals:Toggle({
    Title = "Arena Mobs ESP",
    Desc = "Highlights enemy mobs & bosses with real-time badges",
    Value = false,
    Callback = function(v)
        State.ArenaMobsESP = v
    end
})

UI_Elements.PlotsESP = TabVisuals:Toggle({
    Title = "Player Plots ESP",
    Desc = "Draws beacons over claimed plots in the game server",
    Value = false,
    Callback = function(v)
        State.PlotsESP = v
    end
})

-- -------------------------------------------------------------------------
-- TAB 7: CONFIG
-- -------------------------------------------------------------------------
TabConfig:Section({ Title = "Persistent Configuration" })

TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Saves active toggles and parameters to disk",
    Callback = function()
        pcall(function()
            local payload = HttpService:JSONEncode(State)
            writefile(CONFIG_FILE, payload)
            notify("Config", "Configuration saved to " .. CONFIG_FILE, 3)
        end)
    end
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Restores saved preferences from disk",
    Callback = function()
        pcall(function()
            if isfile and isfile(CONFIG_FILE) then
                local raw = readfile(CONFIG_FILE)
                local decoded = HttpService:JSONDecode(raw)
                for k, v in pairs(decoded) do
                    if State[k] ~= nil then
                        State[k] = v
                        if UI_Elements[k] then
                            if type(v) == "boolean" and UI_Elements[k].Set then
                                UI_Elements[k]:Set(v)
                            elseif type(v) == "number" and UI_Elements[k].Set then
                                UI_Elements[k]:Set(v)
                            elseif type(v) == "string" and UI_Elements[k].Select then
                                UI_Elements[k]:Select(v)
                            end
                        end
                    end
                end
                notify("Config", "Configuration loaded successfully!", 3)
            else
                notify("Config", "No saved configuration file found.", 3)
            end
        end)
    end
})

TabConfig:Button({
    Title = "Reset to Defaults (ALL OFF)",
    Desc = "Disables all active automation and resets speeds",
    Callback = function()
        for k, _ in pairs(State) do
            if type(State[k]) == "boolean" then
                State[k] = false
                if UI_Elements[k] and UI_Elements[k].Set then
                    UI_Elements[k]:Set(false)
                end
            end
        end
        State.WalkSpeed = 16
        State.JumpPower = 50
        State.RollDelay = 1.5
        if UI_Elements.WalkSpeed and UI_Elements.WalkSpeed.Set then UI_Elements.WalkSpeed:Set(16) end
        if UI_Elements.JumpPower and UI_Elements.JumpPower.Set then UI_Elements.JumpPower:Set(50) end
        if UI_Elements.RollDelay and UI_Elements.RollDelay.Set then UI_Elements.RollDelay:Set(1.5) end
        notify("Config", "Reset to ALL OFF defaults completed.", 3)
    end
})

TabConfig:Paragraph({
    Title = "Standard Compliance Notice",
    Desc = "Built natively against WindUI Beta. Default execution is strictly ALL OFF. Toggle interface visibility via LeftControl or the Floating Flame Button."
})

-- Select Default Tab (Combat)
pcall(function()
    Window:SelectTab(1)
end)

-- Expose handles for verification & integration
getgenv().DragonArenaWindow = Window
getgenv().DragonArenaTabs = {
    Combat = TabCombat,
    Hatchery = TabHatchery,
    Progression = TabProgression,
    Rewards = TabRewards,
    Movement = TabMovement,
    Visuals = TabVisuals,
    Config = TabConfig
}
getgenv().DragonArenaState = State
getgenv().DragonArenaElements = UI_Elements

-- =========================================================================
-- 5. AUTOMATION ENGINES & BACKGROUND LOOPS
-- =========================================================================

-- Keybind LeftControl backup listener
local KeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        pcall(function() Window:Toggle() end)
    end
end)
table.insert(Cleanups, function() KeybindConnection:Disconnect() end)

-- Character Controller enforcement
local JumpConnection = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(Cleanups, function() JumpConnection:Disconnect() end)

local SteppedConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- NoClip
    if State.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Humanoid Stats
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.WalkSpeed ~= 16 and hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
        if State.JumpPower ~= 50 and hum.JumpPower ~= State.JumpPower then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPower
        end
    end

    -- Flight Mode
    if State.Fly then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = Workspace.CurrentCamera
        if hrp and cam then
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            hrp.Velocity = (moveDir.Magnitude > 0) and (moveDir.Unit * State.FlySpeed) or Vector3.new(0, 0, 0)
        end
    end
end)
table.insert(Cleanups, function() SteppedConnection:Disconnect() end)

-- Instant Orb Collect Magnet Hook
if orbCtrl and orbCtrl.orbsSpawned then
    local OrbSignalConnection = orbCtrl.orbsSpawned:connect(function(batch)
        if State.InstantOrbCollect and batch and batch.orbs then
            for _, orb in ipairs(batch.orbs) do
                pcall(function()
                    orbCtrl:collect(orb.id)
                end)
            end
        end
    end)
    table.insert(Cleanups, function()
        pcall(function() OrbSignalConnection:disconnect() end)
    end)
end

-- =========================================================================
-- 6. HATCHERY ENGINE (PHYSICAL PRESENTATION + DISTANCE AWARE)
-- =========================================================================
local PedestalLoopTask = task.spawn(function()
    while true do
        task.wait(State.RollDelay or 1.5)

        if eggPedCtrl then
            -- 1. Auto Buy Pedestal Eggs (With Proximity Bypass)
            if State.AutoBuyEggs and currCtrl then
                pcall(function()
                    local ped = eggPedCtrl:getPedestal()
                    if ped and ped.offers then
                        local coins = currCtrl:getAmountOf("coins") or 0
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local myPlot = plotCtrl and plotCtrl:getPlot()
                        local pedModel = myPlot and myPlot:FindFirstChild("EggPedestal")
                        local pedPos = pedModel and pedModel:GetPivot().Position

                        for pipeNum, offer in pairs(ped.offers) do
                            local egg = offer.egg
                            local price = offer.price or 0

                            if coins >= price then
                                local eggLvl = egg.level or 1
                                local isCommonLvl1 = (eggLvl <= 1) and (egg.egg == "rock" or egg.egg == "blaze")
                                local isMutated = egg.mutation ~= nil

                                local shouldBuy = false
                                if State.SkipCommonEggs and isCommonLvl1 and not isMutated then
                                    shouldBuy = false
                                elseif isMutated or eggLvl >= (State.MinEggLevel or 1) then
                                    if State.TargetEggType == "All Eggs" then
                                        shouldBuy = true
                                    elseif State.TargetEggType == "Mutated Only" and isMutated then
                                        shouldBuy = true
                                    elseif egg.egg and (egg.egg:lower() .. "egg"):match(State.TargetEggType:lower()) then
                                        shouldBuy = true
                                    elseif egg.species and egg.species:lower():match(State.TargetEggType:lower()) then
                                        shouldBuy = true
                                    end
                                end

                                if shouldBuy then
                                    local needRestore = false
                                    local oldCF = nil
                                    if hrp and pedPos and (hrp.Position - pedPos).Magnitude > 15 then
                                        oldCF = hrp.CFrame
                                        hrp.CFrame = pedModel:GetPivot() + Vector3.new(0, 3, 0)
                                        task.wait(0.15)
                                        needRestore = true
                                    end

                                    local success = pcall(function()
                                        return eggPedCtrl:buyEgg(offer):expect()
                                    end)

                                    if needRestore and oldCF and hrp then
                                        hrp.CFrame = oldCF
                                    end

                                    if success then
                                        coins = coins - price
                                        notify("Hatchery", string.format("Purchased %s Egg (Pipe %d) for %d coins!", egg.species or egg.egg, tonumber(offer.pipe or pipeNum), price), 2.5)
                                    end
                                end
                            end
                        end
                    end
                end)
            end

            -- 2. Auto Roll Pedestals (Physical Lever Animation & VFX)
            if State.AutoRollPedestal then
                pcall(function()
                    local plot = renderCtrl and renderCtrl.pedestalPlot
                    if plot and not plot.pulling then
                        plot:onLeverTriggered()
                    elseif not plot then
                        eggPedCtrl:pull()
                    end
                end)
            end
        end
    end
end)
table.insert(Cleanups, function()
    pcall(function() task.cancel(PedestalLoopTask) end)
end)

-- Main Fast Loop for Nests, Combat, Team & Progression (Every 0.5s)
local MainLoopTask = task.spawn(function()
    while true do
        task.wait(0.5)

        -- 1. Combat Loop
        if fightCtrl then
            if State.AutoBattle then
                pcall(function()
                    if not fightCtrl:isAutoFightSelected() then
                        fightCtrl:setAutoFight(true)
                    end
                    if not fightCtrl:isFighting() then
                        fightCtrl:startFight()
                    end
                end)
            end

            if State.AutoRevive then
                pcall(function() fightCtrl:revive() end)
            end

            if State.AutoSkipCutscenes then
                pcall(function() fightCtrl:endBossCutscene() end)
            end

            if State.AutoDismissResults then
                pcall(function() fightCtrl:dismissResult() end)
            end
        end

        -- 2. Nest Management Loop
        if nestCtrl then
            pcall(function()
                local owned = nestCtrl:getOwnedNests()
                if not owned or #owned == 0 then return end

                -- Auto Place Eggs (Prioritizes egg incubation)
                if State.AutoPlaceEggs and eggCtrl then
                    local unplaced = eggCtrl:getUnplacedEggs()
                    if unplaced and #unplaced > 0 then
                        local freeNests = nestCtrl:getFreeNests()
                        -- If no free nests, check if we can free an idle resting dragon (NOT in combat)
                        if #freeNests == 0 and teamCtrl then
                            local equipped = teamCtrl:getEquipped()
                            for _, nId in ipairs(owned) do
                                local c = nestCtrl:getContent(nId)
                                if c and c.kind == "dragon" and not table.find(equipped, c.dragonId) then
                                    local freed = pcall(function() nestCtrl:takeDragon(nId):expect() end)
                                    if freed then
                                        table.insert(freeNests, nId)
                                        break
                                    end
                                end
                            end
                        end

                        if #freeNests > 0 then
                            for i = 1, math.min(#unplaced, #freeNests) do
                                local egg = unplaced[i]
                                local nestId = freeNests[i]
                                pcall(function()
                                    nestCtrl:placeEgg(nestId, egg.id):expect()
                                    notify("Hatchery", string.format("Placed %s Egg in Nest %s", egg.species or egg.egg, nestId), 2)
                                end)
                            end
                        end
                    end
                end

                -- Auto Place Dragons (Idle unnested dragons into available empty nests)
                -- Smart Allocation: ONLY use nests not needed by unplaced eggs!
                if State.AutoPlaceDragons and dragonCtrl then
                    local unplacedEggs = (State.AutoPlaceEggs and eggCtrl) and eggCtrl:getUnplacedEggs() or {}
                    local freeNests = nestCtrl:getFreeNests()
                    local availableForDragons = math.max(0, #freeNests - #unplacedEggs)
                    if availableForDragons > 0 then
                        local allDragons = dragonCtrl:getDragons()
                        for _, d in ipairs(allDragons) do
                            if availableForDragons <= 0 then break end
                            if not nestCtrl:isNested(d.id) then
                                local nestId = table.remove(freeNests, 1)
                                availableForDragons = availableForDragons - 1
                                pcall(function()
                                    nestCtrl:placeDragon(nestId, d.id):expect()
                                    notify("Hatchery", string.format("Placed %s into Nest %s", d.species or "Dragon", nestId), 2)
                                end)
                            end
                        end
                    end
                end

                -- Fast Hatch (Skip Timer) & Auto Open Ready Eggs
                for _, nestId in ipairs(owned) do
                    local content = nestCtrl:getContent(nestId)
                    if content then
                        if content.kind == "egg" then
                            local left = nestCtrl:getHatchSecondsLeft(nestId)
                            -- Instant Timer Skip
                            if State.AutoSkipTimer and left and left > 0 then
                                pcall(function()
                                    nestCtrl:skipTimer(nestId):expect()
                                    notify("Hatchery", "Instant Hatch! Countdown cleared for Nest " .. nestId, 2)
                                end)
                                left = 0
                            end

                            -- Open Ready Eggs
                            if State.AutoHatchEggs and (left == nil or left <= 0) then
                                pcall(function()
                                    local res = nestCtrl:openEgg(nestId):expect()
                                    if res then
                                        notify("Hatchery", "Hatched egg in Nest " .. nestId .. "!", 3)
                                        if State.AutoCollectDragons then
                                            task.wait(0.2)
                                            nestCtrl:takeDragon(nestId):expect()
                                            notify("Hatchery", "Claimed baby dragon to inventory!", 2)
                                        end
                                    end
                                end)
                            end
                        elseif content.kind == "breeding" then
                            -- Breeding Timer Skip
                            if State.AutoFastBreed then
                                pcall(function()
                                    nestCtrl:skipTimer(nestId):expect()
                                end)
                            end

                            -- Hatch & Deploy Breeding Offspring
                            if State.AutoCollectBreed then
                                local left = nestCtrl:getHatchSecondsLeft(nestId)
                                if left == nil or left <= 0 then
                                    pcall(function()
                                        local res = nestCtrl:openEgg(nestId):expect()
                                        if res then
                                            notify("Breeding", "Hatched breeding egg in Nest " .. nestId .. "!", 3)
                                            task.wait(0.2)
                                            if teamCtrl then teamCtrl:equipBest() end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                -- Auto Buy Nests
                if State.AutoBuyNests then
                    pcall(function() nestCtrl:buyNest() end)
                end
            end)
        end

        -- 2.5 Breeding Automation Loop (Idle Dragons Pairing)
        if State.AutoBreed and breedCtrl and dragonCtrl and teamCtrl and nestCtrl then
            pcall(function()
                if breedCtrl:getFreeFrames() > 0 then
                    local allDragons = dragonCtrl:getDragons()
                    local equipped = teamCtrl:getEquipped()
                    local freeNests = nestCtrl:getFreeNests()

                    -- Candidate must not be fighting, not already breeding
                    local candidates = {}
                    for _, d in ipairs(allDragons) do
                        local isFighting = table.find(equipped, d.id) ~= nil
                        local isBreeding = breedCtrl:isBreeding(d.id)
                        if not isFighting and not isBreeding then
                            table.insert(candidates, d)
                        end
                    end

                    -- Server requires: "Only dragons in a nest can breed"
                    -- Ensure top candidates are placed in nests if nests are free
                    table.sort(candidates, function(a, b)
                        return (a.level or 0) > (b.level or 0)
                    end)

                    local readyToBreed = {}
                    for _, d in ipairs(candidates) do
                        if nestCtrl:isNested(d.id) then
                            table.insert(readyToBreed, d)
                        elseif #freeNests > 0 then
                            local nestId = table.remove(freeNests, 1)
                            local ok = pcall(function()
                                nestCtrl:placeDragon(nestId, d.id):expect()
                            end)
                            if ok then
                                table.insert(readyToBreed, d)
                            end
                        end
                        if #readyToBreed >= 2 then break end
                    end

                    if #readyToBreed >= 2 then
                        local p1 = readyToBreed[1]
                        local p2 = readyToBreed[2]
                        local s, res = pcall(function()
                            return breedCtrl:startBreed(p1.id, p2.id)
                        end)
                        if s and res then
                            notify("Breeding", string.format("Breeding started: %s (Lvl %d) + %s (Lvl %d)!", p1.species, p1.level, p2.species, p2.level), 3)
                        end
                    end
                end
            end)
        end

        -- 3. Team Auto Deploy
        if State.AutoEquipBest and teamCtrl then
            pcall(function() teamCtrl:equipBest() end)
        end

        -- 4. Stat Upgrades (With Coin Safeguard)
        if statCtrl and plotCtrl and currCtrl then
            pcall(function()
                local myPlot = plotCtrl:getPlot()
                local coins = currCtrl:getAmountOf("coins") or 0
                if myPlot and coins > 5000 then
                    if State.AutoUpgradeLuck then
                        local cur = statCtrl:getPlotLevel(myPlot, "eggLuck")
                        statCtrl.net:call("upgrade", "eggLuck", cur + 1):andThen(function()
                            notify("Progression", "Egg Luck upgraded to Level " .. (cur + 1), 3)
                        end):catch(function() end)
                    end
                    if State.AutoUpgradePedestals then
                        local cur = statCtrl:getPlotLevel(myPlot, "rollingPedestals")
                        statCtrl.net:call("upgrade", "rollingPedestals", cur + 1):andThen(function()
                            notify("Progression", "Rolling Pedestals upgraded to Level " .. (cur + 1), 3)
                        end):catch(function() end)
                    end
                end
            end)
        end

        -- 5. Plot Floor Upgrade
        if State.AutoUpgradePlot and plotUpgradeCtrl then
            pcall(function()
                if plotUpgradeCtrl:canUnlockNext() then
                    plotUpgradeCtrl:upgrade(plotUpgradeCtrl.level + 1)
                    notify("Progression", "Plot floor upgraded!", 3)
                end
            end)
        end

        -- 6. Feeding Meat
        if State.AutoFeedMeat and foodCtrl and dragonCtrl then
            pcall(function()
                if foodCtrl:getAmount("meat") > 0 then
                    local dragons = dragonCtrl:getDragons()
                    if dragons and #dragons > 0 then
                        for _, d in ipairs(dragons) do
                            foodCtrl:feed(d.id, "meat")
                        end
                    end
                end
            end)
        end

        -- 7. Power Rolling (Free Spins Only)
        if State.AutoRollPowers and powerCtrl then
            pcall(function()
                if powerCtrl.data and powerCtrl.data.spins and powerCtrl.data.spins > 0 then
                    powerCtrl:roll()
                    notify("Progression", "Rolled free Dragon Power spin!", 3)
                end
            end)
        end
    end
end)
table.insert(Cleanups, function()
    pcall(function() task.cancel(MainLoopTask) end)
end)

-- Real-time Live Progression Dashboard Loop (Every 1.0s)
local DashboardLoopTask = task.spawn(function()
    while true do
        task.wait(1.0)
        pcall(function()
            local dragons = dragonCtrl and dragonCtrl:getDragons() or {}
            local equipped = teamCtrl and teamCtrl:getEquipped() or {}
            local teamPower = 0
            local strongest = nil

            for _, d in ipairs(dragons) do
                local pwr = (dragonMgr and dragonMgr:getPower(d)) or 0
                if table.find(equipped, d.id) then
                    teamPower = teamPower + pwr
                end
                if not strongest or pwr > strongest.power then
                    strongest = { species = d.species, level = d.level, power = pwr }
                end
            end

            local state = fightCtrl and fightCtrl:getState()
            local wave = state and state.wave or 0
            local phase = state and state.phase or "idle"

            local coins = currCtrl and currCtrl:getAmountOf("coins") or 0
            local gems = currCtrl and currCtrl:getAmountOf("gems") or 0
            local meat = foodCtrl and foodCtrl:getAmount("meat") or 0

            local ownedNests = nestCtrl and nestCtrl:getOwnedNests() or {}
            local freeNests = nestCtrl and nestCtrl:getFreeNests() or {}

            local freeFrames = breedCtrl and breedCtrl:getFreeFrames() or 0
            local totalFrames = breedCtrl and breedCtrl:getFramesUnlocked() or 0

            local text = string.format(
                "â¡ Team Combat Power: %s  |  Wave: %d (%s)\n" ..
                "ð Top Dragon: %s (Lvl %d | %s Power)\n" ..
                "ð§¬ Breeding Frames: %d/%d Free  |  Owned Dragons: %d\n" ..
                "ðªº Nests: %d Total  |  %d Free  |  %d Active\n" ..
                "ð° Coins: %s  |  Gems: %s  |  Meat: %d",
                string.format("%.0f", teamPower),
                wave,
                phase,
                strongest and (strongest.species:sub(1,1):upper() .. strongest.species:sub(2)) or "None",
                strongest and strongest.level or 0,
                string.format("%.0f", strongest and strongest.power or 0),
                freeFrames,
                totalFrames,
                #dragons,
                #ownedNests,
                #freeNests,
                #ownedNests - #freeNests,
                string.format("%d", coins),
                string.format("%d", gems),
                meat
            )

            if ProgressionDashboard and ProgressionDashboard.SetDesc then
                ProgressionDashboard:SetDesc(text)
            end
            if CombatDashboard and CombatDashboard.SetDesc then
                CombatDashboard:SetDesc(string.format(
                    "â¡ Team Combat Power: %s  |  Wave: %d (%s)\n" ..
                    "ð Active Roster: %d Dragons  |  Top Dragon: %s (Lvl %d)",
                    string.format("%.0f", teamPower),
                    wave,
                    phase,
                    #equipped,
                    strongest and (strongest.species:sub(1,1):upper() .. strongest.species:sub(2)) or "None",
                    strongest and strongest.level or 0
                ))
            end
            if HatcheryDashboard and HatcheryDashboard.SetDesc then
                HatcheryDashboard:SetDesc(string.format(
                    "ðªº Nests: %d Total  |  %d Free  |  %d Busy\n" ..
                    "ð§¬ Breeding Slots: %d/%d Free  |  Unplaced Eggs: %d",
                    #ownedNests,
                    #freeNests,
                    #ownedNests - #freeNests,
                    freeFrames,
                    totalFrames,
                    eggCtrl and #(eggCtrl:getUnplacedEggs() or {}) or 0
                ))
            end
        end)
    end
end)
table.insert(Cleanups, function()
    pcall(function() task.cancel(DashboardLoopTask) end)
end)

-- Slower Background Loop for Rewards & Periodic Selling (Every 5s)
local PeriodicLoopTask = task.spawn(function()
    local counter = 0
    while true do
        task.wait(5)
        counter = counter + 5

        -- Index Claims
        if State.AutoClaimIndex and indexCtrl then
            pcall(function()
                if indexCtrl:getClaimableCount() > 0 then
                    indexCtrl:claimAll()
                    notify("Rewards", "Claimed index collection luck rewards!", 2.5)
                end
            end)
        end

        -- Wishing Well
        if State.AutoWishingWell and wishCtrl then
            pcall(function()
                wishCtrl:wish()
                wishCtrl:collect()
            end)
        end

        -- Lucky Field
        if State.AutoLuckyField and luckyCtrl then
            pcall(function()
                if luckyCtrl:canActivate() then
                    luckyCtrl:activate()
                    notify("Rewards", "Lucky Field boost activated!", 2.5)
                end
            end)
        end

        -- Stay Rewards
        if State.AutoClaimStay and stayCtrl then
            pcall(function()
                for i = 1, 12 do
                    if not stayCtrl:isClaimed(i) then
                        stayCtrl:claim(i)
                    end
                end
            end)
        end

        -- Group Reward
        if State.AutoClaimGroup and groupCtrl then
            pcall(function()
                if not groupCtrl:isClaimed() then
                    groupCtrl:claim()
                    notify("Rewards", "Claimed Roblox group reward sign!", 2.5)
                end
            end)
        end

        -- Periodic Selling (Every 30s)
        if State.AutoSellPeriodically and sellerCtrl and (counter % 30 == 0) then
            pcall(function()
                sellerCtrl:sellAll()
            end)
        end
    end
end)
table.insert(Cleanups, function()
    pcall(function() task.cancel(PeriodicLoopTask) end)
end)

-- Visuals / ESP Manager
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "DragonArena_ESP"
ESP_Folder.Parent = Workspace
table.insert(Cleanups, function() pcall(function() ESP_Folder:Destroy() end) end)

local ESPLoopTask = task.spawn(function()
    while true do
        task.wait(1)

        ESP_Folder:ClearAllChildren()

        -- 1. Pedestal ESP
        if State.PedestalESP and eggPedCtrl then
            pcall(function()
                local ped = eggPedCtrl:getPedestal()
                local p = plotCtrl and plotCtrl:getPlot()
                if ped and ped.offers and p and p:FindFirstChild("EggPedestal") then
                    local pedModel = p.EggPedestal
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "Pedestal_Billboard"
                    bb.Adornee = pedModel:FindFirstChild("PrimaryPart") or pedModel:GetPivot().Position and pedModel
                    bb.Size = UDim2.fromOffset(220, 70)
                    bb.StudsOffset = Vector3.new(0, 6, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = ESP_Folder

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.fromScale(1, 1)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 215, 0)
                    txt.TextStrokeTransparency = 0
                    txt.TextSize = 13
                    txt.Font = Enum.Font.GothamBold

                    local summary = "PEDESTAL OFFERS:\n"
                    for _, off in pairs(ped.offers) do
                        local egg = off.egg
                        summary = summary .. string.format("[P%d] %s (%d Coins)\n", off.pipe, egg.species or egg.egg, off.price)
                    end
                    txt.Text = summary
                    txt.Parent = bb
                end
            end)
        end

        -- 2. Arena Mobs ESP
        if State.ArenaMobsESP and Workspace:FindFirstChild("FightArena") then
            pcall(function()
                for _, mob in ipairs(Workspace.FightArena:GetChildren()) do
                    if mob:IsA("Model") and not mob.Name:match("Dragon$") then
                        local primary = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "Mob_" .. mob.Name
                            bb.Adornee = primary
                            bb.Size = UDim2.fromOffset(140, 30)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = ESP_Folder

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.fromScale(1, 1)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 50, 50)
                            txt.TextStrokeTransparency = 0
                            txt.TextSize = 12
                            txt.Font = Enum.Font.GothamBold
                            txt.Text = "[MOB] " .. mob.Name
                            txt.Parent = bb
                        end
                    end
                end
            end)
        end

        -- 3. Plots ESP
        if State.PlotsESP and Workspace:FindFirstChild("Plots") then
            pcall(function()
                for _, plot in ipairs(Workspace.Plots:GetChildren()) do
                    if plot:IsA("Model") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "Plot_" .. plot.Name
                        bb.Adornee = plot
                        bb.Size = UDim2.fromOffset(120, 25)
                        bb.StudsOffset = Vector3.new(0, 10, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = ESP_Folder

                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.fromScale(1, 1)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(0, 200, 255)
                        txt.TextStrokeTransparency = 0
                        txt.TextSize = 11
                        txt.Font = Enum.Font.GothamBold
                        txt.Text = "DragonPlot"
                        txt.Parent = bb
                    end
                end
            end)
        end
    end
end)
table.insert(Cleanups, function()
    pcall(function() task.cancel(ESPLoopTask) end)
end)

notify("Dragon Arena", "Master Script v2.0 loaded! Press LeftControl or click Flame Button.", 4)
