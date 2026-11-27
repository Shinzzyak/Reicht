-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- ==============================================================================
-- [ð¦] Harpoon a Fish â Universal Automation & Reverse-Engineered Suite
-- UI Library: WindUI (Universal English, Modern Dark, Zero Watermark/Filler)
-- Target Place ID: 113384248926706
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cleanup any previous execution instance
if getgenv()._HarpoonAutomation then
    pcall(function() getgenv()._HarpoonAutomation:Unload() end)
end

local App = {
    Connections = {},
    Loops = {},
    ESPObjects = {},
    FloatingPill = nil,
    Unloaded = false
}
getgenv()._HarpoonAutomation = App

-- Cache remotes & modules
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local HarpoonConfig = require(Modules:WaitForChild("HarpoonConfig"))
local FishMotionConfig = require(Modules:WaitForChild("FishMotionConfig"))
local FishDisplay = require(Modules:WaitForChild("FishDisplay"))
local KeyConfig = require(Modules:WaitForChild("KeyConfig"))
local PenConfig = require(Modules:WaitForChild("PenConfig"))
local TableConfig = require(Modules:WaitForChild("TableConfig"))
local DepthBands = require(Modules:WaitForChild("DepthBands"))
local Zones = require(Modules:WaitForChild("Zones"))

local HarpoonDive = Remotes:WaitForChild("HarpoonDive")
local HarpoonExit = Remotes:WaitForChild("HarpoonExit")
local HarpoonFire = Remotes:WaitForChild("HarpoonFire")
local HarpoonDepth = Remotes:WaitForChild("HarpoonDepth")
local ReelBeat = Remotes:WaitForChild("ReelBeat")
local SellFish = Remotes:WaitForChild("SellFish")
local CrateOpen = Remotes:WaitForChild("CrateOpen")
local ShopFreeClaim = Remotes:WaitForChild("ShopFreeClaim")
local PlaytimeClaim = Remotes:WaitForChild("PlaytimeClaim")
local SkyChestOpen = Remotes:WaitForChild("SkyChestOpen")
local DailyClaim = Remotes:WaitForChild("DailyClaim")
local FeedFish = Remotes:WaitForChild("FeedFish")
local PenUpgrade = Remotes:WaitForChild("PenUpgrade")
local TableUpgrade = Remotes:WaitForChild("TableUpgrade")
local IndexClaim = Remotes:WaitForChild("IndexClaim")
local AquariumAction = Remotes:WaitForChild("AquariumAction")

-- ==============================================================================
-- INTERNAL HARPOON HOOKS & TARGET GEOMETRY SOLVER
-- ==============================================================================
local function getHarpoonInternals()
    local HarpoonEnter = Remotes:FindFirstChild("HarpoonEnter")
    if not HarpoonEnter then return nil end
    local conns = getconnections(HarpoonEnter.OnClientEvent)
    for _, c in ipairs(conns) do
        if c.Function and debug.getinfo(c.Function).source:find("HarpoonController") then
            local firePress = debug.getupvalue(c.Function, 11)
            if firePress then
                return {
                    firePress = firePress,
                    get_u327 = function() return debug.getupvalue(firePress, 1) end, -- seated
                    get_u329 = function() return debug.getupvalue(firePress, 2) end, -- aim table
                    get_u328 = function() return debug.getupvalue(firePress, 3) end, -- harpoon model
                    get_u337 = function() return debug.getupvalue(firePress, 4) end, -- active reel minigame
                    get_u398 = function() return debug.getupvalue(firePress, 5) end, -- time sync function
                    nearestFish = debug.getupvalue(firePress, 14),                  -- native nearest fish finder
                    snapPoint = debug.getupvalue(firePress, 16),                    -- native trajectory snap point
                }
            end
        end
    end
    return nil
end

local function getMyPlot()
    local plotName = LocalPlayer:GetAttribute("Plot")
    local plots = workspace:FindFirstChild("Plots")
    if plots and plotName and plots:FindFirstChild(plotName) then
        return plots[plotName]
    end
    if plots then
        for _, p in ipairs(plots:GetChildren()) do
            if p:GetAttribute("Owner") == LocalPlayer.UserId then
                return p
            end
        end
    end
    return nil
end

local function getMyHarpoon()
    local plot = getMyPlot()
    return plot and plot:FindFirstChild("Harpoon") or nil
end

local function getHarpoonRefs(harpoon)
    if not harpoon or not harpoon.Parent then return nil end
    local Spear = harpoon:FindFirstChild("Spear")
    local TopRotate = harpoon:FindFirstChild("TopRotate")
    local Barrel = TopRotate and TopRotate:FindFirstChild("Barrel")
    local Barrel_2 = Barrel and Barrel:FindFirstChild("Barrel")
    local RopeBeamAttatchment = Barrel_2 and Barrel_2:FindFirstChild("RopeBeamAttatchment")
    local RopeBeam = Barrel_2 and Barrel_2:FindFirstChild("RopeBeam")
    local SpearSeat = Barrel_2 and Barrel_2:FindFirstChild("SpearSeat")
    local v2 = harpoon:GetAttribute("RestTop")
    local Attribute = harpoon:GetAttribute("RestBarrelOffset")
    if TopRotate and Barrel and RopeBeamAttatchment and RopeBeam and SpearSeat and v2 and Attribute then
        return {
            harpoon = harpoon,
            spear = Spear,
            top = TopRotate,
            barrel = Barrel,
            muzzleAtt = RopeBeamAttatchment,
            beam = RopeBeam,
            seat = SpearSeat,
            restTop = v2,
            restBarrelOffset = Attribute,
        }
    end
    return nil
end

-- Raw un-clamped angles calculation for physical reachability verification (Finding #5)
local function rawAnglesTo(a1, a2)
    local v1 = a1.restTop * a1.restBarrelOffset
    local v2 = a2 - v1.Position
    if v2.Magnitude <= 2 then return nil, nil end
    local Unit = v2.Unit
    local YVector = v1.YVector
    local v1_xz = Vector3.new(YVector.X, 0, YVector.Z)
    local v3 = Vector3.new(Unit.X, 0, Unit.Z)
    if not (v1_xz.Magnitude <= 0.0001) and not (v3.Magnitude <= 0.0001) then
        local Unit_2 = v1_xz.Unit
        local Unit_3 = v3.Unit
        local v4 = if not (0 <= a1.restTop.ZVector.Y) then -1 else 1
        local rawYaw = math.deg((math.atan2((Unit_2:Cross(Unit_3)).Y, (Unit_2:Dot(Unit_3))))) * v4
        v4 = math.deg((math.asin((math.clamp(YVector.Y, -1, 1)))))
        v3 = math.deg((math.asin((math.clamp(Unit.Y, -1, 1)))))
        local rawPitch = v4 - v3
        return rawYaw, rawPitch
    end
    return nil, nil
end

local function anglesTo(a1, a2)
    local rawYaw, rawPitch = rawAnglesTo(a1, a2)
    if rawYaw and rawPitch then
        return math.clamp(rawYaw, -HarpoonConfig.YawRange, HarpoonConfig.YawRange),
            math.clamp(rawPitch, -HarpoonConfig.PitchUpMax, HarpoonConfig.PitchDownMax)
    end
    return nil, nil
end

local function needleAngleAt(a1, a2)
    local v1 = math.max(0, a2 - a1.time0)
    if v1 < a1.ramp then
        return (a1.angle0 + a1.v0 * v1 + (a1.v1 - a1.v0) * v1 * v1 / (2 * a1.ramp)) % 360
    end
    return (a1.angle0 + (a1.v0 + a1.v1) * a1.ramp / 2 + a1.v1 * (v1 - a1.ramp)) % 360
end

local RarityWeights = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Exotic = 7,
    Apex = 8,
    Celestial = 9,
    Secret = 10,
    Titan = 11,
    Exclusive = 12
}

local RarityColors = {
    Common = Color3.fromRGB(200, 200, 200),
    Uncommon = Color3.fromRGB(115, 230, 115),
    Rare = Color3.fromRGB(80, 175, 255),
    Epic = Color3.fromRGB(180, 80, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 60, 60),
    Exotic = Color3.fromRGB(255, 220, 50),
    Apex = Color3.fromRGB(255, 0, 128),
    Celestial = Color3.fromRGB(0, 255, 255),
    Secret = Color3.fromRGB(255, 255, 255),
    Titan = Color3.fromRGB(255, 50, 50),
    Exclusive = Color3.fromRGB(255, 105, 180)
}

local RarityThresholds = {
    ["All"] = 0,
    ["Uncommon+"] = 2,
    ["Rare+"] = 3,
    ["Epic+"] = 4,
    ["Legendary+"] = 5,
    ["Mythic+"] = 6,
    ["Exotic+"] = 7,
    ["Titan / Secret"] = 10
}

-- ==============================================================================
-- APPLICATION CONFIGURATION (STRICTLY ALL OFF INITIALLY - RULE 8)
-- ==============================================================================
local Config = {
    -- Harpoon & Auto-Farm
    AutoEnterHarpoon = false,
    AutoDepthControl = false,
    TargetDepth = 60,
    SmartDepth = false,
    AutoAim = false,
    AutoShoot = false,
    TargetRarity = "All",
    PrioritizeRarest = false,
    MaxDistance = 190,
    AutoReel = false,
    AutoSell = false,
    AutoSellBagThreshold = 5,
    
    -- Progression & Upgrades
    AutoPenUpgrade = false,
    AutoTableUpgrade = false,
    AutoEquipBest = false,
    AutoFeed = false,
    FeedTarget = "Highest Rate",
    
    -- Rewards & Claims
    AutoFreeShop = false,
    AutoPlaytime = false,
    AutoSkyChest = false,
    AutoDaily = false,
    AutoIndexClaim = false,
    AutoOpenCrates = false,
    CrateKeyTypes = {
        Wood = false,
        Stone = false,
        Gold = false,
        Ruby = false,
        Diamond = false,
        Secret = false,
    },
    
    -- Visuals
    FishESP = false,
    ESPRarity = "All",
    MaxESPDistance = 350,
    TitanAlert = false,
}
App.Config = Config

-- ==============================================================================
-- INITIALIZE WINDUI FRAMEWORK
-- ==============================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Harpoon a Fish",
    Icon = "fish",
    Author = "Universal Automation Suite",
    Folder = "HarpoonAFish",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Menu",
        Icon = "fish",
        CornerRadius = UDim.new(0, 16),
        Enabled = true,
        Draggable = true,
        OnlyMobile = false
    }
})

-- Hotkey binding for LeftControl toggle
local inputConn = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
        Window:Toggle()
    end
end)
table.insert(App.Connections, inputConn)

-- Floating Toggle Pill (Rule 8 compliance: Floating Button & LeftControl)
local function createFloatingToggle(window)
    local container = gethui and gethui() or CoreGui
    local oldPill = container:FindFirstChild("HarpoonFloatingToggle")
    if oldPill then pcall(function() oldPill:Destroy() end) end

    local screen = Instance.new("ScreenGui")
    screen.Name = "HarpoonFloatingToggle"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.fromOffset(125, 36)
    btn.Position = UDim2.new(0.5, -62, 0, 16)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    btn.BackgroundTransparency = 0.12
    btn.Text = "ð Menu (LCtrl)"
    btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Active = true
    btn.Draggable = true
    btn.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 75, 105)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if window and window.Toggle then
            window:Toggle()
        end
    end)

    screen.Parent = container
    return screen
end
App.FloatingPill = createFloatingToggle(Window)

-- ==============================================================================
-- TABS CONSTRUCTION (CLEAN 5 HIGH-VALUE TABS, ZERO GIMMICK FILLER)
-- ==============================================================================
local TabHarpoon = Window:Tab({ Title = "Auto-Harpoon", Icon = "crosshair" })
local TabProgression = Window:Tab({ Title = "Progression", Icon = "trending-up" })
local TabRewards = Window:Tab({ Title = "Rewards & Crates", Icon = "gift" })
local TabVisuals = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- ==============================================================================
-- TAB 1: AUTO-HARPOON & FISHING
-- ==============================================================================
TabHarpoon:Section({ Title = "Harpoon Seating & Stability" })

TabHarpoon:Toggle({
    Title = "Auto Seat / Anti-Eject",
    Desc = "Continuously keeps player seated in harpoon; instantly re-seats if ejected",
    Value = Config.AutoEnterHarpoon,
    Callback = function(val)
        Config.AutoEnterHarpoon = val
    end
})

TabHarpoon:Section({ Title = "Depth Control" })

TabHarpoon:Toggle({
    Title = "Lock to Selected Depth",
    Desc = "Continuously maintains the harpoon at the depth set below",
    Value = Config.AutoDepthControl,
    Callback = function(val)
        Config.AutoDepthControl = val
    end
})

TabHarpoon:Slider({
    Title = "Harpoon Depth (Studs)",
    Desc = "Depth position in studs (supports all zones up to 2000 studs)",
    Value = { Min = 60, Max = 2000, Default = Config.TargetDepth },
    Step = 20,
    Callback = function(val)
        Config.TargetDepth = val
        if Config.AutoDepthControl then
            local snapped = DepthBands.Snap(val)
            pcall(function() HarpoonDepth:FireServer(snapped) end)
        end
    end
})

TabHarpoon:Dropdown({
    Title = "Quick Depth Presets",
    Desc = "Instantly dive harpoon to a standard ocean zone",
    Values = { 
        "Surface (60 studs)", 
        "Zone 1 (150 studs)", 
        "Zone 2 (300 studs)", 
        "Zone 3 (560 studs)", 
        "Zone 4 (860 studs)", 
        "Zone 5 (1160 studs)", 
        "Zone 6 Abyss (1600 studs)" 
    },
    Value = "Surface (60 studs)",
    Callback = function(val)
        local d = 60
        if val:find("150") then d = 150
        elseif val:find("300") then d = 300
        elseif val:find("560") then d = 560
        elseif val:find("860") then d = 860
        elseif val:find("1160") then d = 1160
        elseif val:find("1600") then d = 1600
        end
        local snapped = DepthBands.Snap(d)
        Config.TargetDepth = snapped
        pcall(function() HarpoonDepth:FireServer(snapped) end)
        WindUI:Notify({ Title = "Depth Set", Content = "Diving to " .. tostring(snapped) .. " studs...", Duration = 2, Icon = "arrow-down" })
    end
})

TabHarpoon:Toggle({
    Title = "Smart Target Depth Match",
    Desc = "Automatically dives harpoon to match the depth band of your locked target fish",
    Value = Config.SmartDepth,
    Callback = function(val)
        Config.SmartDepth = val
    end
})

TabHarpoon:Section({ Title = "Native Targeting & Firing" })

TabHarpoon:Toggle({
    Title = "Real Auto-Aim & Target Lock",
    Desc = "Calculates exact 3D barrel yaw/pitch trajectory onto physically reachable wild fish",
    Value = Config.AutoAim,
    Callback = function(val)
        Config.AutoAim = val
    end
})

TabHarpoon:Toggle({
    Title = "Native Auto-Shoot",
    Desc = "Dispatches native spear fire whenever locked onto target and ready",
    Value = Config.AutoShoot,
    Callback = function(val)
        Config.AutoShoot = val
    end
})

TabHarpoon:Dropdown({
    Title = "Target Minimum Rarity",
    Desc = "Only targets wild fish meeting or exceeding this threshold",
    Values = { "All", "Uncommon+", "Rare+", "Epic+", "Legendary+", "Mythic+", "Exotic+", "Titan / Secret" },
    Value = Config.TargetRarity,
    Callback = function(val)
        Config.TargetRarity = val
    end
})

TabHarpoon:Toggle({
    Title = "Prioritize Rarest Fish First",
    Desc = "Locks onto highest rarity fish in range before targeting common ones",
    Value = Config.PrioritizeRarest,
    Callback = function(val)
        Config.PrioritizeRarest = val
    end
})

TabHarpoon:Slider({
    Title = "Maximum Target Range",
    Desc = "Maximum distance to target wild fish (studs)",
    Value = { Min = 40, Max = 200, Default = Config.MaxDistance },
    Step = 5,
    Callback = function(val)
        Config.MaxDistance = val
    end
})

TabHarpoon:Section({ Title = "100% Perfect Auto-Reel" })

TabHarpoon:Toggle({
    Title = "Perfect Auto-Reel (Zero Misses)",
    Desc = "Calculates server-synchronized sweetspot timing on Heartbeat frame and hits beat flawlessly",
    Value = Config.AutoReel,
    Callback = function(val)
        Config.AutoReel = val
    end
})

TabHarpoon:Section({ Title = "Seamless Remote Auto-Sell" })

TabHarpoon:Toggle({
    Title = "Seamless Remote Auto-Sell",
    Desc = "Sells all bag fish remotely when full with guaranteed re-seat verification",
    Value = Config.AutoSell,
    Callback = function(val)
        Config.AutoSell = val
    end
})

TabHarpoon:Slider({
    Title = "Sell Bag Threshold",
    Desc = "Trigger sell when bag reaches this fish count",
    Value = { Min = 1, Max = 10, Default = Config.AutoSellBagThreshold },
    Step = 1,
    Callback = function(val)
        Config.AutoSellBagThreshold = val
    end
})

TabHarpoon:Button({
    Title = "Instant Sell All Fish Now",
    Desc = "Executes one seamless remote sell cycle immediately with guaranteed re-dive",
    Callback = function()
        task.spawn(function()
            pcall(function() HarpoonExit:FireServer() end)
            task.wait(0.35)
            local success, res = pcall(function() return SellFish:InvokeServer("All") end)
            task.wait(0.35)
            
            local myHarpoon = getMyHarpoon()
            local t0 = os.clock()
            while myHarpoon and myHarpoon:GetAttribute("OccupantUserId") ~= LocalPlayer.UserId and os.clock() - t0 < 3.5 do
                pcall(function() HarpoonDive:FireServer() end)
                task.wait(0.4)
            end
            
            if success and res and res.sold and res.sold > 0 then
                WindUI:Notify({
                    Title = "Fish Sold",
                    Content = string.format("Sold %d fish for +$%s!", res.sold, tostring(res.cash)),
                    Duration = 3,
                    Icon = "check"
                })
            else
                WindUI:Notify({
                    Title = "Sell Status",
                    Content = "Bag is empty or already sold.",
                    Duration = 2,
                    Icon = "info"
                })
            end
        end)
    end
})

-- ==============================================================================
-- TAB 2: PROGRESSION & UPGRADES
-- ==============================================================================
TabProgression:Section({ Title = "Automated Plot Upgrades" })

TabProgression:Toggle({
    Title = "Auto Upgrade Pen Aquarium",
    Desc = "Automatically purchases pen capacity upgrades whenever cash is affordable",
    Value = Config.AutoPenUpgrade,
    Callback = function(val)
        Config.AutoPenUpgrade = val
    end
})

TabProgression:Toggle({
    Title = "Auto Upgrade Cutting Table",
    Desc = "Automatically purchases table upgrades whenever cash is affordable",
    Value = Config.AutoTableUpgrade,
    Callback = function(val)
        Config.AutoTableUpgrade = val
    end
})

TabProgression:Section({ Title = "Manual Upgrades" })

TabProgression:Button({
    Title = "Upgrade Pen Aquarium Now",
    Desc = "Fires remote upgrade for pen immediately",
    Callback = function()
        local curLvl = LocalPlayer:GetAttribute("PenLevel") or 1
        local cost = PenConfig.UpgradeCost(curLvl)
        local cash = LocalPlayer:GetAttribute("Cash") or 0
        if cost and cash >= cost then
            pcall(function() PenUpgrade:FireServer() end)
            WindUI:Notify({ Title = "Pen Upgrade", Content = "Upgraded pen aquarium!", Duration = 2, Icon = "check" })
        else
            WindUI:Notify({ Title = "Pen Upgrade", Content = "Cannot afford yet. Cost: $" .. tostring(cost), Duration = 3, Icon = "alert-triangle" })
        end
    end
})

TabProgression:Button({
    Title = "Upgrade Cutting Table Now",
    Desc = "Fires remote upgrade for table immediately",
    Callback = function()
        local curLvl = LocalPlayer:GetAttribute("TableLevel") or 1
        local cost = TableConfig.UpgradeCost(curLvl)
        local cash = LocalPlayer:GetAttribute("Cash") or 0
        if cost and cash >= cost then
            pcall(function() TableUpgrade:FireServer() end)
            WindUI:Notify({ Title = "Table Upgrade", Content = "Upgraded cutting table!", Duration = 2, Icon = "check" })
        else
            WindUI:Notify({ Title = "Table Upgrade", Content = "Cannot afford yet. Cost: $" .. tostring(cost), Duration = 3, Icon = "alert-triangle" })
        end
    end
})

TabProgression:Section({ Title = "Aquarium Management" })

TabProgression:Toggle({
    Title = "Auto Equip Best Fish to Aquarium",
    Desc = "Automatically places highest-income fish into your aquarium, replacing the weakest",
    Value = Config.AutoEquipBest,
    Callback = function(val)
        Config.AutoEquipBest = val
    end
})

TabProgression:Section({ Title = "Aquarium Feeding" })

TabProgression:Toggle({
    Title = "Auto Feed Pen Fish",
    Desc = "Feeds bag fish to your pen fish to boost passive income rate",
    Value = Config.AutoFeed,
    Callback = function(val)
        Config.AutoFeed = val
    end
})

TabProgression:Dropdown({
    Title = "Pen Target to Feed",
    Desc = "Which pen fish to feed (Highest Rate maximizes income ticks)",
    Values = { "Highest Rate", "First Slot" },
    Value = Config.FeedTarget,
    Callback = function(val)
        Config.FeedTarget = val
    end
})

-- ==============================================================================
-- TAB 3: REWARDS & CRATES
-- ==============================================================================
TabRewards:Section({ Title = "Automated Timed Claims" })

TabRewards:Toggle({
    Title = "Auto Claim Playtime Gifts (1-12)",
    Desc = "Claims unlocked playtime rewards continuously as timers expire",
    Value = Config.AutoPlaytime,
    Callback = function(val)
        Config.AutoPlaytime = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Free Daily Shop",
    Desc = "Claims the daily free gift in the shop whenever available",
    Value = Config.AutoFreeShop,
    Callback = function(val)
        Config.AutoFreeShop = val
    end
})

TabRewards:Toggle({
    Title = "Auto Open Sky Chest",
    Desc = "Opens the floating sky chest whenever available",
    Value = Config.AutoSkyChest,
    Callback = function(val)
        Config.AutoSkyChest = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Daily Calendar",
    Desc = "Claims the daily login calendar reward",
    Value = Config.AutoDaily,
    Callback = function(val)
        Config.AutoDaily = val
    end
})

TabRewards:Toggle({
    Title = "Auto Claim Index Discoveries",
    Desc = "Claims rewards for newly caught fish discoveries across all zones",
    Value = Config.AutoIndexClaim,
    Callback = function(val)
        Config.AutoIndexClaim = val
    end
})

TabRewards:Section({ Title = "Auto Open Key Crates" })

TabRewards:Toggle({
    Title = "Master Auto Open Crates",
    Desc = "Uses available keys to automatically unlock selected crates",
    Value = Config.AutoOpenCrates,
    Callback = function(val)
        Config.AutoOpenCrates = val
    end
})

for _, keyName in ipairs({ "Wood", "Stone", "Gold", "Ruby", "Diamond", "Secret" }) do
    TabRewards:Toggle({
        Title = "Open " .. keyName .. " Crates",
        Value = Config.CrateKeyTypes[keyName],
        Callback = function(val)
            Config.CrateKeyTypes[keyName] = val
        end
    })
end

-- ==============================================================================
-- TAB 4: VISUALS & ESP
-- ==============================================================================
TabVisuals:Section({ Title = "Wild Fish ESP" })

TabVisuals:Toggle({
    Title = "Enable Wild Fish ESP",
    Desc = "Renders clean BillboardGuis showing Name, Rarity, and Distance over wild fish",
    Value = Config.FishESP,
    Callback = function(val)
        Config.FishESP = val
        if not val then
            for _, esp in pairs(App.ESPObjects) do
                pcall(function() esp:Destroy() end)
            end
            table.clear(App.ESPObjects)
        end
    end
})

TabVisuals:Dropdown({
    Title = "ESP Minimum Rarity Filter",
    Values = { "All", "Uncommon+", "Rare+", "Epic+", "Legendary+", "Mythic+", "Exotic+", "Titan / Secret" },
    Value = Config.ESPRarity,
    Callback = function(val)
        Config.ESPRarity = val
    end
})

TabVisuals:Slider({
    Title = "ESP Max Render Distance",
    Value = { Min = 100, Max = 600, Default = Config.MaxESPDistance },
    Step = 25,
    Callback = function(val)
        Config.MaxESPDistance = val
    end
})

TabVisuals:Section({ Title = "Titan & Boss Warnings" })

TabVisuals:Toggle({
    Title = "Titan / Boss Spawn Alert",
    Desc = "Shows an immediate screen notification whenever a Titan or Boss emerges",
    Value = Config.TitanAlert,
    Callback = function(val)
        Config.TitanAlert = val
    end
})

-- ==============================================================================
-- TAB 5: CONFIGURATION & PROFILES
-- ==============================================================================
TabConfig:Section({ Title = "Profile Manager" })

local configFileName = "Default"
TabConfig:Input({
    Title = "Profile Name",
    Default = configFileName,
    Callback = function(val)
        if val and #val > 0 then configFileName = val end
    end
})

local function getConfigPath(name)
    return "HarpoonAFish_" .. tostring(name) .. ".json"
end

TabConfig:Button({
    Title = "Save Config Profile",
    Desc = "Persists your current toggles and slider settings to disk",
    Callback = function()
        if writefile then
            local data = HttpService:JSONEncode(Config)
            writefile(getConfigPath(configFileName), data)
            WindUI:Notify({ Title = "Saved", Content = "Saved profile: " .. configFileName, Duration = 2, Icon = "save" })
        else
            WindUI:Notify({ Title = "Error", Content = "writefile not supported", Duration = 3, Icon = "alert-triangle" })
        end
    end
})

TabConfig:Button({
    Title = "Load Config Profile",
    Desc = "Restores previously saved configuration",
    Callback = function()
        if readfile and isfile and isfile(getConfigPath(configFileName)) then
            local content = readfile(getConfigPath(configFileName))
            local success, parsed = pcall(function() return HttpService:JSONDecode(content) end)
            if success and type(parsed) == "table" then
                for k, v in pairs(parsed) do
                    Config[k] = v
                end
                WindUI:Notify({ Title = "Loaded", Content = "Loaded profile: " .. configFileName, Duration = 2, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Failed to parse profile JSON", Duration = 3, Icon = "alert-circle" })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Profile file not found", Duration = 2, Icon = "alert-circle" })
        end
    end
})

TabConfig:Button({
    Title = "Reset to Defaults (STRICT ALL OFF)",
    Desc = "Immediately disables all automations",
    Callback = function()
        for k, v in pairs(Config) do
            if type(v) == "boolean" then
                Config[k] = false
            end
        end
        for k in pairs(Config.CrateKeyTypes) do
            Config.CrateKeyTypes[k] = false
        end
        WindUI:Notify({ Title = "Reset", Content = "All automations turned OFF.", Duration = 2, Icon = "rotate-ccw" })
    end
})

TabConfig:Button({
    Title = "Unload Automation Script",
    Desc = "Disconnects all listeners, stops all loops, and destroys the UI",
    Callback = function()
        App:Unload()
        Window:Destroy()
    end
})

-- Default tab selection
TabHarpoon:Select()

-- ==============================================================================
-- CORE EXECUTION LOOPS
-- ==============================================================================

local isSelling = false

-- 1. Dedicated Reeling Sweetspot Listener (Heartbeat - High Precision Zero Miss)
local lastReelHit = 0
local reelConn = RunService.Heartbeat:Connect(function()
    if App.Unloaded or not Config.AutoReel or isSelling then return end
    
    local internals = getHarpoonInternals()
    if not internals then return end
    
    local u337 = internals.get_u337()
    if u337 and (not u337.hearts or u337.hearts > 0) then
        local now = u337.drawnAt or (internals.get_u398 and internals.get_u398() or workspace:GetServerTimeNow())
        if not u337.graceUntil or now >= u337.graceUntil then
            if os.clock() - lastReelHit >= 0.15 then
                local angle = needleAngleAt(u337, now)
                local diff = math.abs((angle - u337.arcCenter + 180) % 360 - 180)
                local hitWindow = (u337.arcSize / 2)
                
                if diff <= hitWindow then
                    lastReelHit = os.clock()
                    pcall(function() internals.firePress() end)
                end
            end
        end
    end
end)
table.insert(App.Connections, reelConn)

-- 2. Main Harpoon Worker: Auto Seat, Seamless Auto Sell, Reachable Aim & Shoot
local lastShootTime = 0
local fishingThread = task.spawn(function()
    while not App.Unloaded do
        task.wait(0.04)
        
        local internals = getHarpoonInternals()
        local myHarpoon = getMyHarpoon()
        
        -- Auto Seat / Anti-Eject
        if Config.AutoEnterHarpoon and myHarpoon and not isSelling then
            local occupant = myHarpoon:GetAttribute("OccupantUserId") or 0
            if occupant ~= LocalPlayer.UserId then
                pcall(function() HarpoonDive:FireServer() end)
                task.wait(0.4)
            end
        end
        
        -- Lock to Selected Depth
        if Config.AutoDepthControl and myHarpoon and not isSelling then
            local occupant = myHarpoon:GetAttribute("OccupantUserId") or 0
            if occupant == LocalPlayer.UserId then
                local currentDy = myHarpoon:GetAttribute("PoseDy") or 0
                local targetSnapped = DepthBands.Snap(Config.TargetDepth)
                if math.abs(-currentDy - targetSnapped) > 10 then
                    pcall(function() HarpoonDepth:FireServer(targetSnapped) end)
                end
            end
        end
        
        -- Auto Equip Best Fish into Aquarium (Before Sell / Feed)
        if Config.AutoEquipBest and not isSelling then
            local penCap = LocalPlayer:GetAttribute("PenCap") or 0
            local penCount = LocalPlayer:GetAttribute("PenCount") or 0
            local penBoardRaw = LocalPlayer:GetAttribute("PenBoard")
            local penFish = {}
            if penBoardRaw then
                local ok, parsed = pcall(function() return HttpService:JSONDecode(penBoardRaw) end)
                if ok and type(parsed) == "table" then penFish = parsed end
            end
            
            local minPenRate = math.huge
            local minPenId = nil
            for _, pf in ipairs(penFish) do
                local r = pf.r or 0
                if r < minPenRate then
                    minPenRate = r
                    minPenId = pf.i
                end
            end
            if #penFish == 0 then minPenRate = 0 end
            
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            local sources = { bp, LocalPlayer.Character }
            for _, src in ipairs(sources) do
                if src then
                    for _, item in ipairs(src:GetChildren()) do
                        if item:IsA("Tool") then
                            local bagId = item:GetAttribute("BagId")
                            local rate = item:GetAttribute("Rate") or 0
                            if bagId and rate > 0 then
                                if penCount < penCap then
                                    pcall(function() AquariumAction:FireServer("Equip", bagId) end)
                                    penCount = penCount + 1
                                    task.wait(0.2)
                                elseif rate > minPenRate and minPenId then
                                    pcall(function()
                                        AquariumAction:FireServer("Unequip", minPenId)
                                        task.wait(0.15)
                                        AquariumAction:FireServer("Equip", bagId)
                                    end)
                                    minPenRate = rate
                                    task.wait(0.25)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Seamless Remote Auto-Sell with Active Re-Seat Verification (Finding #2)
        if Config.AutoSell and not isSelling and not Config.AutoFeed then
            local bagCount = LocalPlayer:GetAttribute("BagCount") or 0
            local bagCap = LocalPlayer:GetAttribute("BagCap") or 5
            local threshold = math.min(Config.AutoSellBagThreshold, bagCap)
            
            if bagCount >= threshold and bagCount > 0 then
                isSelling = true
                task.spawn(function()
                    pcall(function() HarpoonExit:FireServer() end)
                    task.wait(0.35)
                    pcall(function() SellFish:InvokeServer("All") end)
                    task.wait(0.35)
                    
                    local t0 = os.clock()
                    while myHarpoon and myHarpoon:GetAttribute("OccupantUserId") ~= LocalPlayer.UserId and os.clock() - t0 < 3.5 do
                        pcall(function() HarpoonDive:FireServer() end)
                        task.wait(0.4)
                    end
                    isSelling = false
                end)
            end
        end
        
        -- Reachable Auto Aim & Shoot (Finding #5)
        if (Config.AutoAim or Config.AutoShoot) and internals and myHarpoon and not isSelling then
            local isSeated = internals.get_u327()
            local u329 = internals.get_u329()
            local u337 = internals.get_u337()
            local spearReady = myHarpoon:GetAttribute("SpearReady")
            local refs = getHarpoonRefs(myHarpoon)
            
            if isSeated and u329 and not u337 and refs then
                local fishFolder = workspace:FindFirstChild("Fish")
                if fishFolder then
                    local targetScore = RarityThresholds[Config.TargetRarity] or 0
                    local bestFish = nil
                    local bestTargetPoint = nil
                    local bestRarityWeight = -1
                    local bestDist = math.huge
                    local muzzlePos = refs.muzzleAtt.WorldPosition
                    
                    for _, f in ipairs(fishFolder:GetChildren()) do
                        if f:GetAttribute("PenOwner") == nil and f.PrimaryPart then
                            local dist = (f.PrimaryPart.Position - muzzlePos).Magnitude
                            if dist <= Config.MaxDistance then
                                local rarity = f:GetAttribute("Rarity")
                                local disp = FishDisplay[f.Name]
                                if not rarity and disp then rarity = disp.rarity end
                                rarity = rarity or "Common"
                                
                                local rWeight = RarityWeights[rarity] or 1
                                if rWeight >= targetScore then
                                    -- Calculate 3D Target Snap Point
                                    local tPoint = nil
                                    if internals.snapPoint then
                                        tPoint = internals.snapPoint(f, muzzlePos)
                                    else
                                        tPoint = f.PrimaryPart.Position
                                    end
                                    
                                    -- Verify Physical Angle Reachability (Avoid Clamped Misses)
                                    local rawYaw, rawPitch = rawAnglesTo(refs, tPoint)
                                    if rawYaw and rawPitch then
                                        local isReachable = math.abs(rawYaw) <= HarpoonConfig.YawRange 
                                            and rawPitch >= -HarpoonConfig.PitchUpMax 
                                            and rawPitch <= HarpoonConfig.PitchDownMax
                                            
                                        if isReachable then
                                            if Config.PrioritizeRarest then
                                                if rWeight > bestRarityWeight or (rWeight == bestRarityWeight and dist < bestDist) then
                                                    bestRarityWeight = rWeight
                                                    bestDist = dist
                                                    bestFish = f
                                                    bestTargetPoint = tPoint
                                                end
                                            else
                                                if dist < bestDist then
                                                    bestDist = dist
                                                    bestFish = f
                                                    bestTargetPoint = tPoint
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if bestFish and bestTargetPoint then
                        -- Smart Target Depth Match
                        if Config.SmartDepth then
                            local fishDepth = -bestFish.PrimaryPart.Position.Y
                            local curDy = myHarpoon:GetAttribute("PoseDy") or 0
                            local maxD = myHarpoon:GetAttribute("MaxDepth") or 1600
                            local minD = myHarpoon:GetAttribute("MinDepth") or 60
                            if math.abs(-curDy - fishDepth) > 60 then
                                local targetD = DepthBands.Snap(math.clamp(fishDepth, minD, maxD))
                                pcall(function() HarpoonDepth:FireServer(targetD) end)
                            end
                        end
                        
                        local yaw, pitch = anglesTo(refs, bestTargetPoint)
                        if yaw and pitch then
                            u329.targetYaw = yaw
                            u329.targetPitch = pitch
                            u329.yaw = yaw
                            u329.pitch = pitch
                            u329.lastTargetPoint = bestTargetPoint
                            u329.lastRayHit = true
                            
                            if Config.AutoShoot and spearReady and (os.clock() - lastShootTime >= 0.35) then
                                lastShootTime = os.clock()
                                pcall(function() internals.firePress() end)
                            end
                        end
                    end
                end
            end
        end
    end
end)
table.insert(App.Loops, fishingThread)

-- 3. Progression Loop: Auto Pen & Table Upgrades, Optimal Feeding (runs every 1.5 seconds)
local progressionThread = task.spawn(function()
    while not App.Unloaded do
        task.wait(1.5)
        
        -- Auto Pen Upgrade
        if Config.AutoPenUpgrade then
            local penLvl = LocalPlayer:GetAttribute("PenLevel") or 1
            local cost = PenConfig.UpgradeCost(penLvl)
            local cash = LocalPlayer:GetAttribute("Cash") or 0
            if cost and cash >= cost then
                pcall(function() PenUpgrade:FireServer() end)
            end
        end
        
        -- Auto Table Upgrade
        if Config.AutoTableUpgrade then
            local tblLvl = LocalPlayer:GetAttribute("TableLevel") or 1
            local cost = TableConfig.UpgradeCost(tblLvl)
            local cash = LocalPlayer:GetAttribute("Cash") or 0
            if cost and cash >= cost then
                pcall(function() TableUpgrade:FireServer() end)
            end
        end
        
        -- Auto Feeding Pen Fish (Finding #4: Optimal Rate Targeting)
        if Config.AutoFeed and not Config.AutoSell and not isSelling then
            local bagCount = LocalPlayer:GetAttribute("BagCount") or 0
            if bagCount > 0 then
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                local bagIds = {}
                if backpack then
                    for _, t in ipairs(backpack:GetChildren()) do
                        local bId = t:GetAttribute("BagId")
                        if bId then table.insert(bagIds, bId) end
                    end
                end
                
                local function getBestPenFishId()
                    local penBoardRaw = LocalPlayer:GetAttribute("PenBoard")
                    if not penBoardRaw then return nil end
                    local ok, parsed = pcall(function() return HttpService:JSONDecode(penBoardRaw) end)
                    if ok and type(parsed) == "table" and #parsed > 0 then
                        if Config.FeedTarget == "First Slot" then
                            return parsed[1].i
                        end
                        -- Find fish with highest rate r
                        local bestId = parsed[1].i
                        local bestRate = parsed[1].r or 0
                        for _, pf in ipairs(parsed) do
                            local r = pf.r or 0
                            if r > bestRate then
                                bestRate = r
                                bestId = pf.i
                            end
                        end
                        return bestId
                    end
                    return nil
                end
                
                if #bagIds > 0 then
                    local penFishId = getBestPenFishId()
                    if penFishId then
                        pcall(function() FeedFish:FireServer(penFishId, bagIds) end)
                    end
                else
                    isSelling = true
                    task.spawn(function()
                        pcall(function() HarpoonExit:FireServer() end)
                        task.wait(0.35)
                        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                        local ids = {}
                        if bp then
                            for _, t in ipairs(bp:GetChildren()) do
                                local bId = t:GetAttribute("BagId")
                                if bId then table.insert(ids, bId) end
                            end
                        end
                        local penFishId = getBestPenFishId()
                        if penFishId and #ids > 0 then
                            pcall(function() FeedFish:FireServer(penFishId, ids) end)
                        end
                        task.wait(0.3)
                        
                        local myHarpoon = getMyHarpoon()
                        local t0 = os.clock()
                        while myHarpoon and myHarpoon:GetAttribute("OccupantUserId") ~= LocalPlayer.UserId and os.clock() - t0 < 3.5 do
                            pcall(function() HarpoonDive:FireServer() end)
                            task.wait(0.4)
                        end
                        isSelling = false
                    end)
                end
            end
        end
    end
end)
table.insert(App.Loops, progressionThread)

-- 4. Rewards & Timed Claims Loop (runs every 4 seconds)
local rewardsThread = task.spawn(function()
    while not App.Unloaded do
        task.wait(4)
        
        -- Auto Free Shop Gift
        if Config.AutoFreeShop then
            pcall(function() ShopFreeClaim:InvokeServer() end)
        end
        
        -- Auto Playtime Gifts (1 to 12)
        if Config.AutoPlaytime then
            for i = 1, 12 do
                pcall(function() PlaytimeClaim:InvokeServer(i) end)
            end
        end
        
        -- Auto Sky Chest
        if Config.AutoSkyChest then
            local opened = LocalPlayer:GetAttribute("SkyChestOpened")
            if opened == false then
                pcall(function() SkyChestOpen:InvokeServer() end)
            end
        end
        
        -- Auto Daily Calendar
        if Config.AutoDaily then
            local dailyOpens = LocalPlayer:GetAttribute("DailyOpensAt")
            local claimed = LocalPlayer:GetAttribute("DailyClaimed") or 0
            if dailyOpens and workspace:GetServerTimeNow() >= dailyOpens then
                pcall(function() DailyClaim:InvokeServer(claimed + 1) end)
            end
        end
        
        -- Auto Index Discoveries
        if Config.AutoIndexClaim then
            for z = 1, 7 do
                pcall(function() IndexClaim:InvokeServer("Fish", tostring(z)) end)
                pcall(function() IndexClaim:InvokeServer("Rungs", tostring(z)) end)
            end
        end
        
        -- Auto Open Key Crates (Finding #6: 0.6s breathing delay)
        if Config.AutoOpenCrates then
            for keyName, enabled in pairs(Config.CrateKeyTypes) do
                if enabled then
                    local count = LocalPlayer:GetAttribute("Key" .. keyName) or 0
                    if count > 0 then
                        pcall(function() CrateOpen:InvokeServer(keyName) end)
                        task.wait(0.6)
                    end
                end
            end
        end
    end
end)
table.insert(App.Loops, rewardsThread)

-- 5. Wild Fish ESP Render Loop with Robust Stale Node Cleanup (Finding #3)
local espConn = RunService.RenderStepped:Connect(function()
    if App.Unloaded then return end
    
    -- Clean up all ESP objects immediately if toggled off
    if not Config.FishESP then
        if next(App.ESPObjects) ~= nil then
            for _, esp in pairs(App.ESPObjects) do
                pcall(function() esp:Destroy() end)
            end
            table.clear(App.ESPObjects)
        end
        return
    end
    
    local fishFolder = workspace:FindFirstChild("Fish")
    if not fishFolder then return end
    
    local targetScore = RarityThresholds[Config.ESPRarity] or 0
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myPos = root and root.Position or Camera.CFrame.Position
    
    -- Cleanup despawned fish references
    for f, bb in pairs(App.ESPObjects) do
        if not f or not f.Parent then
            pcall(function() bb:Destroy() end)
            App.ESPObjects[f] = nil
        end
    end
    
    for _, f in ipairs(fishFolder:GetChildren()) do
        if f:GetAttribute("PenOwner") == nil and f.PrimaryPart then
            local dist = math.floor((f.PrimaryPart.Position - myPos).Magnitude)
            local rarity = f:GetAttribute("Rarity")
            local disp = FishDisplay[f.Name]
            if not rarity and disp then rarity = disp.rarity end
            rarity = rarity or "Common"
            
            local rWeight = RarityWeights[rarity] or 1
            if rWeight >= targetScore and dist <= Config.MaxESPDistance then
                local bb = App.ESPObjects[f]
                if not bb or not bb.Parent then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "FishESP"
                    bb.Adornee = f.PrimaryPart
                    bb.Size = UDim2.fromOffset(130, 36)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = Config.MaxESPDistance + 50
                    
                    local lbl = Instance.new("TextLabel")
                    lbl.Name = "Info"
                    lbl.Size = UDim2.fromScale(1, 1)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.TextStrokeTransparency = 0.2
                    lbl.Parent = bb
                    
                    bb.Parent = f
                    App.ESPObjects[f] = bb
                end
                
                local lbl = bb:FindFirstChild("Info")
                if lbl then
                    local col = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
                    lbl.TextColor3 = col
                    lbl.Text = string.format("%s\n[%s] %dm", f.Name, rarity, dist)
                end
            else
                if App.ESPObjects[f] then
                    pcall(function() App.ESPObjects[f]:Destroy() end)
                    App.ESPObjects[f] = nil
                end
            end
        end
    end
end)
table.insert(App.Connections, espConn)

-- 6. Titan / Boss Alert
local lastTitanAlert = 0
local titanWatcher = task.spawn(function()
    while not App.Unloaded do
        task.wait(3)
        if Config.TitanAlert then
            local titan = workspace:FindFirstChild("TitanRise") or workspace:FindFirstChild("TitanRise_Umibozu")
            if titan and (os.clock() - lastTitanAlert > 30) then
                lastTitanAlert = os.clock()
                WindUI:Notify({
                    Title = "TITAN DETECTED!",
                    Content = "A wild ocean Titan / Boss has emerged!",
                    Duration = 6,
                    Icon = "skull"
                })
            end
        end
    end
end)
table.insert(App.Loops, titanWatcher)

-- ==============================================================================
-- UNLOAD LIFECYCLE
-- ==============================================================================
function App:Unload()
    self.Unloaded = true
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.Connections)
    for _, th in ipairs(self.Loops) do
        pcall(function() task.cancel(th) end)
    end
    table.clear(self.Loops)
    for _, esp in pairs(self.ESPObjects) do
        pcall(function() esp:Destroy() end)
    end
    table.clear(self.ESPObjects)
    if self.FloatingPill then
        pcall(function() self.FloatingPill:Destroy() end)
        self.FloatingPill = nil
    end
    pcall(function() Window:Destroy() end)
    getgenv()._HarpoonAutomation = nil
end

WindUI:Notify({
    Title = "Harpoon a Fish",
    Content = "Universal Automation Suite loaded! Press LeftControl or click floating icon to open.",
    Duration = 4,
    Icon = "check"
})
