-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    Bike For Egg! Elite Automation Framework
    High-Performance Exploit & Automation Suite
    Powered by WindUI
]]

-- Cleanup Prior Instances
if getgenv and getgenv()._BikeForEggCleanup then
    pcall(getgenv()._BikeForEggCleanup)
end

local hui = (gethui and gethui()) or game:GetService("CoreGui")
for _, child in ipairs(hui:GetChildren()) do
    if child.Name:find("WindUI") then
        pcall(function() child:Destroy() end)
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

for _, child in ipairs(PlayerGui:GetChildren()) do
    if child.Name:find("WindUI") then
        pcall(function() child:Destroy() end)
    end
end

-- Game Framework Bindings
local Library = ReplicatedStorage:WaitForChild("Library")
local Network = require(Library:WaitForChild("Client"):WaitForChild("Network"))
local PlotCmds = require(Library:WaitForChild("Client"):WaitForChild("PlotCmds"))
local Save = require(Library:WaitForChild("Client"):WaitForChild("Save"))
local EggCmds = require(Library:WaitForChild("Client"):WaitForChild("EggCmds"))
local Assets = require(ReplicatedStorage:WaitForChild("Directory"):WaitForChild("Assets"))
local NET_MAP = Network.NET_MAP

-- Settings Registry (ALL OFF BY DEFAULT per directive)
local Settings = {
    -- Auto Steal & Eggs
    AutoStealEggs = false,
    SelectedAreaFilter = "All Areas",
    StealPriority = "Biggest Size First (Scale)",
    MinEggScale = 1.0,
    AutoHatch = false,
    AutoEquipBest = false,
    AutoSellPets = false,

    -- Treadmill & Speed
    AutoTreadmill = false,
    AutoUpgradeTreadmill = false,

    -- Base & Economy
    AutoUpgradeBase = false,
    AutoClaimIndex = false,
    AutoRedeemOffline = false,

    -- Exploits & Combat
    GodMode = false,
    AntiSlow = false,
    AntiAFK = false,

    -- Visuals / ESP
    EggsESP = false,
    GuardsESP = false,
    PlotsESP = false,

    -- Movement & Locomotion
    Fly = false,
    FlySpeed = 60,
    ClickTP = false,
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    InfiniteJump = false,
    NoClip = false,
}

local CONFIG_FILE = "BikeForEgg_Config.json"

local function SaveConfig()
    return pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Settings))
    end)
end

local function LoadConfig()
    if isfile and isfile(CONFIG_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do
                if Settings[k] ~= nil then
                    Settings[k] = v
                end
            end
            return true
        end
    end
    return false
end

-- World Coordinate Anchors
local AREA_COORDS = {
    ["Prehistoric"] = Vector3.new(1580.8, 90.3, -357.0),
    ["Cosmic"] = Vector3.new(1772.1, 90.3, -357.0),
    ["Royal Kingdom"] = Vector3.new(3928.6, 68.0, -365.9),
    ["Abyss Ocean"] = Vector3.new(1370.5, 90.3, -357.0),
    ["Volcano"] = Vector3.new(1202.6, 90.7, -356.3),
    ["Snow"] = Vector3.new(1076.1, 90.7, -357.2),
    ["Jungle"] = Vector3.new(936.0, 90.2, -355.1),
    ["Desert"] = Vector3.new(785.7, 90.2, -362.4),
    ["Lake"] = Vector3.new(746.2, 91.0, -357.3),
    ["Forest"] = Vector3.new(602.3, 90.4, -371.1),
}

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function Teleport(pos)
    local hrp = GetRootPart()
    if hrp then
        hrp.CFrame = typeof(pos) == "Vector3" and CFrame.new(pos) or pos
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function GetMyPlot()
    local plots = PlotCmds.GetPlotsFolder()
    local mySlot = PlotCmds.GetMySlot()
    return plots and plots:FindFirstChild(tostring(mySlot))
end

local function GetMySpawn()
    local plot = GetMyPlot()
    local sp = plot and plot:FindFirstChild("SpawnPoint")
    return sp and sp.Position or Vector3.new(468.8, 73.8, -287.2)
end

local function GetMyTreadmill()
    local plot = GetMyPlot()
    local tb = plot and plot:FindFirstChild("TreadmillBottom")
    return tb and tb.Position or Vector3.new(478.8, 67.7, -307.5)
end

-- Sorted Candidates Evaluator (Exact Area Match + Size/Rarity Hierarchy)
local function GetSortedCandidates(records, areaFilter, priorityMode, minScale)
    local candidates = {}
    local minSize = minScale or 1.0

    for _, rec in ipairs(records or {}) do
        local areaMatches = (areaFilter == "All Areas" or rec.AreaId == areaFilter)
        local scale = rec.AssetScale or 1.0
        if areaMatches and scale >= minSize then
            table.insert(candidates, rec)
        end
    end

    table.sort(candidates, function(a, b)
        local scaleA = a.AssetScale or 1.0
        local scaleB = b.AssetScale or 1.0
        local defA = Assets.Directory[a.AssetCategory]
        local defB = Assets.Directory[b.AssetCategory]
        local rA = (defA and defA.Rarity and defA.Rarity.RarityNumber) or 1
        local rB = (defB and defB.Rarity and defB.Rarity.RarityNumber) or 1

        if priorityMode == "Highest Rarity" then
            if rA ~= rB then return rA > rB end
            return scaleA > scaleB
        elseif priorityMode == "Balanced (Size x Rarity)" then
            local scoreA = scaleA * rA
            local scoreB = scaleB * rB
            if math.abs(scoreA - scoreB) > 0.05 then return scoreA > scoreB end
            return scaleA > scaleB
        else
            -- "Biggest Size First (Scale)" - Default
            if math.abs(scaleA - scaleB) > 0.05 then
                return scaleA > scaleB
            end
            return rA > rB
        end
    end)

    return candidates
end

-- Initialize WindUI Framework (with fallback)
local WindUI
local successUI, uiObj = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if successUI and type(uiObj) == "table" then
    WindUI = uiObj
else
    local s, fallback = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if s and type(fallback) == "table" then
        WindUI = fallback
    end
end

local Window = WindUI:CreateWindow({
    Title = "Bike For Egg! Elite",
    Author = "Universal Operations",
    Icon = "egg",
    Folder = "BikeForEgg",
    Size = UDim2.fromOffset(620, 500),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Bike For Egg!",
        Icon = "egg",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

local function SendNotify(title, content, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Icon = "info",
    })
end

--------------------------------------------------------------------------------
-- TAB 1: AUTO STEAL & EGGS
--------------------------------------------------------------------------------
local TabSteal = Window:Tab({
    Title = "Egg Steal & Hatch",
    Icon = "egg",
})

TabSteal:Section({ Title = "Autonomous Egg Stealer" })

local ToggleAutoSteal = TabSteal:Toggle({
    Title = "Auto Steal Eggs (Full Autopilot)",
    Desc = "Teleports to target zone eggs, grabs them, deposits to your base nest",
    Value = false,
    Callback = function(state)
        Settings.AutoStealEggs = state
        if state then
            -- Unequip treadmill to allow locomotion
            pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_UNEQUIP) end)
        end
    end
})

local DropdownArea = TabSteal:Dropdown({
    Title = "Target Area Filter",
    Desc = "Exact zone to steal eggs from (No random jumping)",
    Values = {
        "All Areas",
        "Prehistoric",
        "Cosmic",
        "Royal Kingdom",
        "Abyss Ocean",
        "Volcano",
        "Snow",
        "Jungle",
        "Desert",
        "Lake",
        "Forest",
    },
    Value = "All Areas",
    Callback = function(val)
        Settings.SelectedAreaFilter = tostring(val)
    end
})

local DropdownPriority = TabSteal:Dropdown({
    Title = "Steal Priority Mode",
    Desc = "Target the largest colossal eggs first or the rarest tier first",
    Values = {
        "Biggest Size First (Scale)",
        "Highest Rarity",
        "Balanced (Size x Rarity)",
    },
    Value = "Biggest Size First (Scale)",
    Callback = function(val)
        Settings.StealPriority = tostring(val)
    end
})

local SliderMinScale = TabSteal:Slider({
    Title = "Minimum Egg Size (Scale)",
    Desc = "Skip small normal eggs (e.g. set 2.0x+ for Big/Colossal eggs only)",
    Value = { Min = 0.5, Max = 10, Default = 1.0 },
    Step = 0.5,
    Callback = function(val)
        Settings.MinEggScale = val
    end
})

TabSteal:Button({
    Title = "Steal 1 Best Egg Instantly",
    Desc = "Picks the #1 biggest/rarest egg matching your filters and deposits it",
    Callback = function()
        task.spawn(function()
            local hrp = GetRootPart()
            if not hrp then return end
            pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_UNEQUIP) end)

            local snap = EggCmds.GetAreaEggSnapshot()
            local candidates = GetSortedCandidates(snap and snap.Records, Settings.SelectedAreaFilter, Settings.StealPriority, Settings.MinEggScale)
            local bestRec = candidates[1]

            if not bestRec then
                SendNotify("Steal", "No eggs found matching filters in " .. Settings.SelectedAreaFilter, 3)
                return
            end

            local slot = workspace.AreaEggSlotsClient:FindFirstChild(bestRec.Uid)
            if slot then
                local eggPos = slot:GetPivot().Position
                hrp.CFrame = CFrame.new(eggPos.X, eggPos.Y + 2, eggPos.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.35)

                local ok = Network.Invoke(NET_MAP.Eggs.REQUEST_AREA_EGG_CARRY, { Uid = bestRec.Uid })
                task.wait(0.15)
                Teleport(GetMySpawn() + Vector3.new(0, 3, 0))

                -- Automatically place egg in nest for incubation
                task.wait(0.25)
                pcall(function()
                    local localCF = CFrame.new(math.random(-12, 12), 0, math.random(-12, 12))
                    EggCmds.RequestPlaceEgg(bestRec.Uid, localCF)
                end)

                if ok then
                    local scaleText = string.format("%.2fx", bestRec.AssetScale or 1)
                    SendNotify("Egg Stolen!", string.format("%s (%s Scale) from %s!", bestRec.AssetCategory, scaleText, bestRec.AreaId), 3)
                end
            end
        end)
    end
})

TabSteal:Section({ Title = "Nest Incubation & Pet Management" })

local ToggleAutoHatch = TabSteal:Toggle({
    Title = "Auto Hatch Ready Eggs",
    Desc = "Automatically completes incubation and cracks eggs when ready",
    Value = false,
    Callback = function(state)
        Settings.AutoHatch = state
    end
})

local ToggleAutoEquip = TabSteal:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Always equips the strongest pets from your inventory",
    Value = false,
    Callback = function(state)
        Settings.AutoEquipBest = state
    end
})

local ToggleAutoSell = TabSteal:Toggle({
    Title = "Auto Sell Duplicates / All Pets",
    Desc = "Clears duplicate pets to maximize pen efficiency",
    Value = false,
    Callback = function(state)
        Settings.AutoSellPets = state
    end
})

--------------------------------------------------------------------------------
-- TAB 2: TREADMILL & SPEED TRAINING
--------------------------------------------------------------------------------
local TabTrain = Window:Tab({
    Title = "Treadmill Training",
    Icon = "dumbbell",
})

TabTrain:Section({ Title = "Speed Power Farming" })

local ToggleTreadmill = TabTrain:Toggle({
    Title = "Auto Treadmill Training (Speed Farm)",
    Desc = "Locks onto your plot's treadmill and farms speed continuously",
    Value = false,
    Callback = function(state)
        Settings.AutoTreadmill = state
        if state then
            task.spawn(function()
                Teleport(GetMyTreadmill() + Vector3.new(0, 3, 0))
                task.wait(0.3)
                Network.Invoke(NET_MAP.Treadmills.REQUEST_EQUIP_STATIC)
            end)
        else
            pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_UNEQUIP) end)
        end
    end
})

local ToggleUpgradeTreadmill = TabTrain:Toggle({
    Title = "Auto Upgrade Treadmill Tier",
    Desc = "Automatically buys treadmill level upgrades when affordable",
    Value = false,
    Callback = function(state)
        Settings.AutoUpgradeTreadmill = state
    end
})

TabTrain:Button({
    Title = "Teleport to My Treadmill",
    Callback = function()
        Teleport(GetMyTreadmill() + Vector3.new(0, 3, 0))
    end
})

--------------------------------------------------------------------------------
-- TAB 3: BASE & ECONOMY
--------------------------------------------------------------------------------
local TabEconomy = Window:Tab({
    Title = "Base & Economy",
    Icon = "building",
})

TabEconomy:Section({ Title = "Standless Upgrades & Dex" })

local ToggleUpgradeBase = TabEconomy:Toggle({
    Title = "Auto Upgrade Base / Plot",
    Desc = "Automatically buys plot expansions to fit more pets and eggs",
    Value = false,
    Callback = function(state)
        Settings.AutoUpgradeBase = state
    end
})

local ToggleClaimIndex = TabEconomy:Toggle({
    Title = "Auto Claim Animal Index Rewards",
    Desc = "Continuously claims all completed pet dex bonuses and bats",
    Value = false,
    Callback = function(state)
        Settings.AutoClaimIndex = state
    end
})

local ToggleOfflineRedeem = TabEconomy:Toggle({
    Title = "Auto Redeem Offline Earnings",
    Desc = "Collects pending offline cash periodically",
    Value = false,
    Callback = function(state)
        Settings.AutoRedeemOffline = state
    end
})

TabEconomy:Button({
    Title = "Claim All Index Rewards Now",
    Callback = function()
        local ok = Network.Invoke(NET_MAP.Index.REQUEST_CLAIM_ALL)
        if ok then
            SendNotify("Index", "Claimed all unlocked index rewards!", 3)
        end
    end
})

--------------------------------------------------------------------------------
-- TAB 4: EXPLOITS & COMBAT (BYPASS)
--------------------------------------------------------------------------------
local TabExploits = Window:Tab({
    Title = "Exploits & Defense",
    Icon = "shield-alert",
})

TabExploits:Section({ Title = "Guard & Trap Neutralization" })

local ToggleGod = TabExploits:Toggle({
    Title = "God Mode (Anti-Guard & Trap Immunity)",
    Desc = "Disables CanTouch on character parts: guards, lasers, and traps cannot hit you",
    Value = false,
    Callback = function(state)
        Settings.GodMode = state
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanTouch = not state
                end
            end
        end
        local hum = GetHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not state)
        end
    end
})

local ToggleAntiSlow = TabExploits:Toggle({
    Title = "Anti-Slow (Debuff Immunity)",
    Desc = "Prevents guards from applying speed reduction and fatigue penalties",
    Value = false,
    Callback = function(state)
        Settings.AntiSlow = state
    end
})

local ToggleAntiAFK = TabExploits:Toggle({
    Title = "Anti-AFK (Idle Kick Bypass)",
    Desc = "Disables 20-minute Roblox idle disconnect and simulates active heartbeat",
    Value = false,
    Callback = function(state)
        Settings.AntiAFK = state
        if state then
            pcall(function()
                for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
                    if conn.Disable then conn:Disable() end
                end
            end)
            SendNotify("Anti-AFK", "Anti-AFK protection active!", 3)
        end
    end
})

--------------------------------------------------------------------------------
-- TAB 5: VISUALS & ESP
--------------------------------------------------------------------------------
local TabVisuals = Window:Tab({
    Title = "Visuals & ESP",
    Icon = "eye",
})

TabVisuals:Section({ Title = "World ESP" })

local ToggleEggsESP = TabVisuals:Toggle({
    Title = "Area Eggs Highlight ESP",
    Desc = "Highlights all uncollected area eggs with bright gold outlines",
    Value = false,
    Callback = function(state)
        Settings.EggsESP = state
        if not state then
            local slots = workspace:FindFirstChild("AreaEggSlotsClient")
            if slots then
                for _, s in ipairs(slots:GetChildren()) do
                    local hl = s:FindFirstChild("EggHighlight")
                    if hl then hl:Destroy() end
                end
            end
        end
    end
})

local ToggleGuardsESP = TabVisuals:Toggle({
    Title = "Guards Highlight ESP",
    Desc = "Highlights all patrolling guards with visible red outlines",
    Value = false,
    Callback = function(state)
        Settings.GuardsESP = state
        if not state then
            local g = workspace:FindFirstChild("_Guards")
            if g then
                for _, guard in ipairs(g:GetChildren()) do
                    local hl = guard:FindFirstChild("GuardHighlight")
                    if hl then hl:Destroy() end
                end
            end
        end
    end
})

--------------------------------------------------------------------------------
-- TAB 6: MOVEMENT & FLIGHT
--------------------------------------------------------------------------------
local TabMovement = Window:Tab({
    Title = "Movement",
    Icon = "plane",
})

TabMovement:Section({ Title = "Flight Engine" })

local flyBodyVel, flyBodyGyro
local function StartFly()
    local hrp = GetRootPart()
    if not hrp then return end
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
end

local function StopFly()
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

local ToggleFly = TabMovement:Toggle({
    Title = "Fly Hack (WASD + Space/Shift)",
    Value = false,
    Callback = function(state)
        Settings.Fly = state
        if state then StartFly() else StopFly() end
    end
})

local SliderFlySpeed = TabMovement:Slider({
    Title = "Flight Speed",
    Value = { Min = 20, Max = 200, Default = 60 },
    Step = 5,
    Callback = function(val) Settings.FlySpeed = val end
})

TabMovement:Section({ Title = "Locomotion Exploits" })

local ToggleClickTP = TabMovement:Toggle({
    Title = "Click Teleport (Ctrl + Left Click)",
    Desc = "Hold Ctrl and Left-Click anywhere to warp immediately",
    Value = false,
    Callback = function(state) Settings.ClickTP = state end
})

local SliderSpeed = TabMovement:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 250, Default = 16 },
    Step = 1,
    Callback = function(val)
        Settings.WalkSpeed = val
        if Settings.WalkSpeedEnabled then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = val end
        end
    end
})

local ToggleSpeed = TabMovement:Toggle({
    Title = "Enable Custom WalkSpeed",
    Value = false,
    Callback = function(state)
        Settings.WalkSpeedEnabled = state
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = state and Settings.WalkSpeed or 16 end
    end
})

local SliderJump = TabMovement:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 300, Default = 50 },
    Step = 5,
    Callback = function(val)
        Settings.JumpPower = val
        if Settings.JumpPowerEnabled then
            local hum = GetHumanoid()
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val
            end
        end
    end
})

local ToggleJump = TabMovement:Toggle({
    Title = "Enable Custom JumpPower",
    Value = false,
    Callback = function(state)
        Settings.JumpPowerEnabled = state
        local hum = GetHumanoid()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = state and Settings.JumpPower or 50
        end
    end
})

local ToggleInfJump = TabMovement:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state) Settings.InfiniteJump = state end
})

local ToggleNoClip = TabMovement:Toggle({
    Title = "NoClip",
    Value = false,
    Callback = function(state) Settings.NoClip = state end
})

--------------------------------------------------------------------------------
-- TAB 7: TELEPORTS
--------------------------------------------------------------------------------
local TabTeleport = Window:Tab({
    Title = "Teleports",
    Icon = "map-pin",
})

TabTeleport:Section({ Title = "Base & Stations" })

TabTeleport:Button({
    Title = "My Base / Spawn",
    Callback = function() Teleport(GetMySpawn() + Vector3.new(0, 3, 0)) end
})

TabTeleport:Button({
    Title = "My Treadmill",
    Callback = function() Teleport(GetMyTreadmill() + Vector3.new(0, 3, 0)) end
})

TabTeleport:Button({
    Title = "Lobby Center",
    Callback = function() Teleport(Vector3.new(468.8, 73.8, -287.2)) end
})

TabTeleport:Section({ Title = "World Egg Zones" })
for areaName, pos in pairs(AREA_COORDS) do
    TabTeleport:Button({
        Title = areaName .. " Zone",
        Callback = function() Teleport(pos + Vector3.new(0, 4, 0)) end
    })
end

TabTeleport:Section({ Title = "Other Player Bases" })
for i = 1, 7 do
    TabTeleport:Button({
        Title = "Base Plot " .. i,
        Callback = function()
            local plots = PlotCmds.GetPlotsFolder()
            local targetPlot = plots and plots:FindFirstChild(tostring(i))
            local sp = targetPlot and (targetPlot:FindFirstChild("SpawnPoint") or targetPlot:FindFirstChild("CenterPoint"))
            if sp then
                Teleport(sp.Position + Vector3.new(0, 3, 0))
            end
        end
    })
end

--------------------------------------------------------------------------------
-- TAB 8: CONFIG
--------------------------------------------------------------------------------
local TabConfig = Window:Tab({
    Title = "Config",
    Icon = "settings",
})

TabConfig:Section({ Title = "Configuration Manager" })

TabConfig:Button({
    Title = "Save Config",
    Desc = "Saves current settings to disk (" .. CONFIG_FILE .. ")",
    Callback = function()
        if SaveConfig() then
            SendNotify("Config", "Settings saved successfully!", 2)
        else
            SendNotify("Error", "Failed to write config file.", 2)
        end
    end
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Loads stored settings from disk",
    Callback = function()
        if LoadConfig() then
            ToggleAutoSteal:Set(Settings.AutoStealEggs)
            DropdownArea:Select(Settings.SelectedAreaFilter)
            DropdownPriority:Select(Settings.StealPriority)
            SliderMinScale:Set(Settings.MinEggScale)
            ToggleAutoHatch:Set(Settings.AutoHatch)
            ToggleAutoEquip:Set(Settings.AutoEquipBest)
            ToggleAutoSell:Set(Settings.AutoSellPets)
            ToggleTreadmill:Set(Settings.AutoTreadmill)
            ToggleUpgradeTreadmill:Set(Settings.AutoUpgradeTreadmill)
            ToggleUpgradeBase:Set(Settings.AutoUpgradeBase)
            ToggleClaimIndex:Set(Settings.AutoClaimIndex)
            ToggleOfflineRedeem:Set(Settings.AutoRedeemOffline)
            ToggleGod:Set(Settings.GodMode)
            ToggleAntiSlow:Set(Settings.AntiSlow)
            ToggleAntiAFK:Set(Settings.AntiAFK)
            ToggleEggsESP:Set(Settings.EggsESP)
            ToggleGuardsESP:Set(Settings.GuardsESP)
            ToggleFly:Set(Settings.Fly)
            SliderFlySpeed:Set(Settings.FlySpeed)
            ToggleClickTP:Set(Settings.ClickTP)
            ToggleSpeed:Set(Settings.WalkSpeedEnabled)
            SliderSpeed:Set(Settings.WalkSpeed)
            ToggleJump:Set(Settings.JumpPowerEnabled)
            SliderJump:Set(Settings.JumpPower)
            ToggleInfJump:Set(Settings.InfiniteJump)
            ToggleNoClip:Set(Settings.NoClip)
            SendNotify("Config", "Settings loaded successfully!", 2)
        else
            SendNotify("Notice", "No existing config file found.", 2)
        end
    end
})

TabConfig:Button({
    Title = "Reset to Default (All OFF)",
    Desc = "Turns off all automated features",
    Callback = function()
        ToggleAutoSteal:Set(false)
        ToggleAutoHatch:Set(false)
        ToggleAutoEquip:Set(false)
        ToggleAutoSell:Set(false)
        ToggleTreadmill:Set(false)
        ToggleUpgradeTreadmill:Set(false)
        ToggleUpgradeBase:Set(false)
        ToggleClaimIndex:Set(false)
        ToggleOfflineRedeem:Set(false)
        ToggleGod:Set(false)
        ToggleAntiSlow:Set(false)
        ToggleAntiAFK:Set(false)
        ToggleEggsESP:Set(false)
        ToggleGuardsESP:Set(false)
        ToggleFly:Set(false)
        ToggleClickTP:Set(false)
        ToggleSpeed:Set(false)
        ToggleJump:Set(false)
        ToggleInfJump:Set(false)
        ToggleNoClip:Set(false)
        SendNotify("Config", "All features reset to OFF!", 2)
    end
})

TabConfig:Section({ Title = "Interface Management" })

local ThemeKeys = {}
for name, _ in pairs(WindUI:GetThemes() or {}) do table.insert(ThemeKeys, tostring(name)) end
table.sort(ThemeKeys)
if #ThemeKeys == 0 then ThemeKeys = {"Dark", "Light", "Rose", "Plant", "Red"} end

TabConfig:Dropdown({
    Title = "UI Theme",
    Values = ThemeKeys,
    Value = "Dark",
    Callback = function(theme) WindUI:SetTheme(theme) end
})

--------------------------------------------------------------------------------
-- BACKGROUND ENGINE
--------------------------------------------------------------------------------

local running = true

getgenv()._BikeForEggCleanup = function()
    running = false
    StopFly()
    pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_UNEQUIP) end)
end

-- 1. Anti-AFK Simulation Hook
LocalPlayer.Idled:Connect(function()
    if not running then return end
    if Settings.AntiAFK then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

task.spawn(function()
    while running do
        task.wait(180)
        if Settings.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end
end)

-- 2. Click Teleport Hook
UserInputService.InputBegan:Connect(function(input, gpe)
    if not running or gpe then return end
    if Settings.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Mouse.Hit then
            Teleport(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- 3. Infinite Jump Hook
UserInputService.JumpRequest:Connect(function()
    if not running then return end
    if Settings.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 4. Stepped Hook: God Mode, NoClip, Speed, Flight
RunService.Stepped:Connect(function()
    if not running then return end

    -- God Mode & Anti-Touch
    if Settings.GodMode then
        local hum = GetHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanTouch then
                    p.CanTouch = false
                end
            end
        end
    end

    -- Anti-Slow Immunity
    if Settings.AntiSlow then
        local hum = GetHumanoid()
        if hum and hum.WalkSpeed < Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeed
        end
    end

    -- NoClip
    if Settings.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end

    -- Custom WalkSpeed
    if Settings.WalkSpeedEnabled then
        local hum = GetHumanoid()
        if hum and hum.WalkSpeed ~= Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeed
        end
    end

    -- Flight Controls
    if Settings.Fly and flyBodyVel and flyBodyGyro then
        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        flyBodyVel.Velocity = moveDir.Unit * Settings.FlySpeed
        if moveDir.Magnitude == 0 then flyBodyVel.Velocity = Vector3.zero end
        flyBodyGyro.CFrame = cam.CFrame
    end
end)

-- 5. ESP Render Hook
task.spawn(function()
    while running and task.wait(0.5) do
        -- Eggs ESP
        if Settings.EggsESP then
            local slots = workspace:FindFirstChild("AreaEggSlotsClient")
            if slots then
                for _, slot in ipairs(slots:GetChildren()) do
                    if not slot:FindFirstChild("EggHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "EggHighlight"
                        hl.FillColor = Color3.fromRGB(255, 215, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.3
                        hl.OutlineTransparency = 0
                        hl.Parent = slot
                    end
                end
            end
        end

        -- Guards ESP
        if Settings.GuardsESP then
            local guardsFolder = workspace:FindFirstChild("_Guards")
            if guardsFolder then
                for _, guard in ipairs(guardsFolder:GetChildren()) do
                    if not guard:FindFirstChild("GuardHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "GuardHighlight"
                        hl.FillColor = Color3.fromRGB(255, 45, 45)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = guard
                    end
                end
            end
        end
    end
end)

-- 6. Core Automation Loop (Steal, Hatch, Train, Economy)
task.spawn(function()
    local lastSteal = 0
    local lastHatch = 0
    local lastUpgrade = 0
    local lastIndex = 0
    local lastEquip = 0
    local lastOffline = 0

    while running and task.wait(0.2) do
        local now = os.clock()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local mySpawn = GetMySpawn()
        local myTreadmill = GetMyTreadmill()

        -- Auto Steal Eggs (Prioritizing Area Filter & Size Hierarchy)
        if Settings.AutoStealEggs and (now - lastSteal >= 1.2) and hrp then
            lastSteal = now
            local snap = EggCmds.GetAreaEggSnapshot()
            local candidates = GetSortedCandidates(snap and snap.Records, Settings.SelectedAreaFilter, Settings.StealPriority, Settings.MinEggScale)
            local targetRec = candidates[1]

            if targetRec then
                local slot = workspace.AreaEggSlotsClient:FindFirstChild(targetRec.Uid)
                if slot then
                    pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_UNEQUIP) end)
                    local eggPos = slot:GetPivot().Position

                    hrp.CFrame = CFrame.new(eggPos.X, eggPos.Y + 2, eggPos.Z)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.35)

                    local ok = Network.Invoke(NET_MAP.Eggs.REQUEST_AREA_EGG_CARRY, { Uid = targetRec.Uid })
                    task.wait(0.15)
                    Teleport(mySpawn + Vector3.new(0, 3, 0))

                    -- Automatically place egg in nest for incubation
                    task.wait(0.25)
                    pcall(function()
                        local localCF = CFrame.new(math.random(-12, 12), 0, math.random(-12, 12))
                        EggCmds.RequestPlaceEgg(targetRec.Uid, localCF)
                    end)
                end
            end
        end

        -- Auto Hatch & Place Ready Eggs
        if Settings.AutoHatch and (now - lastHatch >= 1.5) then
            lastHatch = now
            local serverTime = workspace:GetServerTimeNow()
            local eggs = Save.Get().EggInventory or {}
            for uid, egg in pairs(eggs) do
                if not egg.Placement then
                    pcall(function()
                        local localCF = CFrame.new(math.random(-12, 12), 0, math.random(-12, 12))
                        EggCmds.RequestPlaceEgg(uid, localCF)
                    end)
                elseif egg.Placement and egg.Placement.ReadyAt and egg.Placement.ReadyAt <= serverTime then
                    pcall(function()
                        Network.Invoke(NET_MAP.Eggs.REQUEST_HATCH_EGG, uid)
                        task.wait(0.1)
                        Network.Invoke(NET_MAP.Eggs.REQUEST_COMPLETE_HATCH_EGG, uid)
                    end)
                end
            end
        end

        -- Auto Equip Best Pets
        if Settings.AutoEquipBest and (now - lastEquip >= 5) then
            lastEquip = now
            pcall(function() Network.Invoke(NET_MAP.Backpack.EQUIP_BEST) end)
        end

        -- Auto Sell All / Extra Pets
        if Settings.AutoSellPets and (now - lastEquip >= 8) then
            pcall(function() Network.Fire(NET_MAP.AssetInventory.SELL_ALL_ASSETS) end)
        end

        -- Auto Treadmill Training (AFK Speed Farm)
        if Settings.AutoTreadmill and not Settings.AutoStealEggs and hrp then
            local dist = (hrp.Position - myTreadmill).Magnitude
            if dist > 10 then
                Teleport(myTreadmill + Vector3.new(0, 3, 0))
                task.wait(0.3)
                pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_EQUIP_STATIC) end)
            end
        end

        -- Auto Upgrade Treadmill Tier
        if Settings.AutoUpgradeTreadmill and (now - lastUpgrade >= 3) then
            lastUpgrade = now
            pcall(function() Network.Invoke(NET_MAP.Treadmills.REQUEST_UPGRADE) end)
        end

        -- Auto Upgrade Base / Plot
        if Settings.AutoUpgradeBase and (now - lastUpgrade >= 3.5) then
            pcall(function() Network.Fire(NET_MAP.Plots.REQUEST_BASE_UPGRADE) end)
        end

        -- Auto Claim Index Rewards
        if Settings.AutoClaimIndex and (now - lastIndex >= 8) then
            lastIndex = now
            pcall(function() Network.Invoke(NET_MAP.Index.REQUEST_CLAIM_ALL) end)
        end

        -- Auto Redeem Offline Earnings
        if Settings.AutoRedeemOffline and (now - lastOffline >= 15) then
            lastOffline = now
            pcall(function() Network.Invoke("OfflineAssets: Redeem") end)
        end
    end
end)

SendNotify("Bike For Egg! Elite", "Framework loaded! Press Left-Control to toggle UI.", 5)
