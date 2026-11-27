-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    +1 Gun Forge Elite Automation Framework
    High-Performance Exploit & Automation Suite
    Powered by WindUI
]]

-- Cleanup Prior Instances
if getgenv and getgenv()._GunForgeCleanup then
    pcall(getgenv()._GunForgeCleanup)
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
local PlusPlus = ReplicatedStorage:WaitForChild("PlusPlus")
local Remotes = PlusPlus:WaitForChild("Remotes")
local Config = PlusPlus:WaitForChild("Config")
local Shared = PlusPlus:WaitForChild("Shared")
local Controllers = PlusPlus:WaitForChild("Client"):WaitForChild("Controllers")

local GameConfig = require(Config:WaitForChild("GameConfig"))
local GunConfig = require(Config:WaitForChild("GunConfig"))
local UpgradeConfig = require(Config:WaitForChild("UpgradeConfig"))
local ForgeConfig = require(Config:WaitForChild("ForgeConfig"))
local GunMath = require(Shared:WaitForChild("GunMath"))

local ClientState = require(Controllers:WaitForChild("ClientState"))
local FireController = require(Controllers:WaitForChild("FireController"))
local AmmoController = require(Controllers:WaitForChild("AmmoController"))

-- Original Functions for Safe Teardown
local origShotCycle = GunMath.ShotCycle
local origMagazine = GunMath.Magazine
local origReloadSeconds = GunMath.ReloadSeconds
local origCanFire = AmmoController.CanFire
local origIsReloading = AmmoController.IsReloading

-- Remotes
local RequestFire = Remotes:WaitForChild("RequestFire")
local RequestCollect = Remotes:WaitForChild("RequestCollect")
local RequestReturnHub = Remotes:WaitForChild("RequestReturnHub")
local RequestSell = Remotes:WaitForChild("RequestSell")
local RequestUpgrade = Remotes:WaitForChild("RequestUpgrade")
local RequestForge = Remotes:WaitForChild("RequestForge")
local RequestEquipGun = Remotes:WaitForChild("RequestEquipGun")
local RequestRebirth = Remotes:WaitForChild("RequestRebirth")
local RequestRevive = Remotes:FindFirstChild("RequestRevive")

-- Rarity Mapping & Thresholds
local RARITY_RANK = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7,
    Exotic = 8,
}

local FILTER_MAP = {
    ["All (No Filter)"] = 1,
    ["Uncommon+"] = 2,
    ["Rare+ (Recommended)"] = 3,
    ["Epic+"] = 4,
    ["Legendary+"] = 5,
    ["Secret / Exotic Only"] = 7,
}

-- Settings Registry (ALL OFF BY DEFAULT)
local Settings = {
    -- Combat & Exploits
    GodMode = false,
    InstantKill = false,
    RapidFire = false,
    InfiniteAmmo = false,

    -- Auto Stage Progression (Full Hands-Free Autopilot)
    AutoStageSweeper = false,
    DropFilterMinRarity = "Rare+ (Recommended)",
    AutoBankOnBagFull = true,
    SelectedStage = 1,

    -- Training
    AutoTrainBest = false,
    SelectedPad = "Pad1_5x",
    AutoShootPad = false,

    -- Standless Remotes
    RemoteSell = false,
    RemoteForge = false,
    AutoUpgrade = false,
    AutoEquipBest = false,
    AutoRebirth = false,

    -- Visuals / ESP
    EnemyESP = false,
    DropESP = false,

    -- Movement & Physics
    Fly = false,
    FlySpeed = 60,
    ClickTP = false,
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    InfiniteJump = false,
    NoClip = false,
    AntiAFK = false,
}

local CONFIG_FILE = "GunForge_Config.json"

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

-- World Anchors
local LOCATIONS = {
    Spawn = Vector3.new(188, 54, 0),
    SellBooth = Vector3.new(47.4, 55, 105.4),
    UpgradeBooth = Vector3.new(47.4, 55, 71.4),
    PetBooth = Vector3.new(47.4, 55, 88.4),
    EnchantBooth = Vector3.new(47.4, 55, 16.6),
    Forge = Vector3.new(105.5, 54, 50),
    SpinWheel = Vector3.new(128, 75, -37),
    FreeReward = Vector3.new(117.5, 54, 109),
    BountyBoard = Vector3.new(73.9, 63.1, -70),
}

local TRAINING_PADS = {
    { Name = "Pad50x", Rebirths = 15, Pos = Vector3.new(226.25, 58.5, 61.5) },
    { Name = "Pad25x", Rebirths = 12, Pos = Vector3.new(226.25, 58.5, 97.5) },
    { Name = "Pad15x", Rebirths = 9,  Pos = Vector3.new(195.25, 57.5, 43.5) },
    { Name = "Pad10x", Rebirths = 7,  Pos = Vector3.new(195.25, 57.5, 97.5) },
    { Name = "Pad8x",  Rebirths = 5,  Pos = Vector3.new(195.25, 57.5, 115.5) },
    { Name = "Pad6x",  Rebirths = 3,  Pos = Vector3.new(164.25, 56.5, 43.5) },
    { Name = "Pad4x",  Rebirths = 2,  Pos = Vector3.new(164.25, 56.5, 61.5) },
    { Name = "Pad2x",  Rebirths = 1,  Pos = Vector3.new(164.25, 56.5, 97.5) },
    { Name = "Pad1_5x",Rebirths = 0,  Pos = Vector3.new(164.25, 56.5, 115.5) },
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
    end
end

-- Micro-Teleport Spoofing (Satisfies distance validation in ~40ms and restores position)
local function RemoteActionAt(targetPos, actionCallback)
    local hrp = GetRootPart()
    if not hrp then return end
    local oldCF = hrp.CFrame
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.04)
    pcall(actionCallback)
    task.wait(0.04)
    hrp.CFrame = oldCF
end

-- Drop Rarity Filter Verification
local function ShouldCollectDrop(drop)
    local tier = drop:GetAttribute("Tier")
    local info = GameConfig.ScrapTiers and GameConfig.ScrapTiers[tier]
    local band = info and info.Band or "Common"
    local rank = RARITY_RANK[band] or 1
    local minRank = FILTER_MAP[Settings.DropFilterMinRarity] or 3
    return rank >= minRank
end

local function GetBestPad()
    local rebirths = (ClientState.Data and ClientState.Data.Rebirths) or 0
    for _, pad in ipairs(TRAINING_PADS) do
        if rebirths >= pad.Rebirths then
            return pad
        end
    end
    return TRAINING_PADS[#TRAINING_PADS]
end

local function GetPadInstance(padName)
    local pads = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("TrainingPads")
    return pads and pads:FindFirstChild(padName)
end

-- Initialize WindUI Framework
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "+1 Gun Forge Elite",
    Author = "Universal Operations",
    Icon = "crosshair",
    Folder = "PlusOneGunForge",
    Size = UDim2.fromOffset(620, 500),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Gun Forge",
        Icon = "crosshair",
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
-- TAB 1: COMBAT EXPLOITS
--------------------------------------------------------------------------------
local TabCombat = Window:Tab({
    Title = "Combat Exploits",
    Icon = "zap",
})

TabCombat:Section({ Title = "Invulnerability" })

local ToggleGod = TabCombat:Toggle({
    Title = "God Mode (Absolute Invulnerability)",
    Desc = "Prevents damage, locks health, and disables touch damage on character",
    Value = false,
    Callback = function(state)
        Settings.GodMode = state
        local hum = GetHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not state)
        end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanTouch = not state
                end
            end
        end
    end
})

TabCombat:Section({ Title = "Offensive Weapon Exploits" })

local ToggleInstaKill = TabCombat:Toggle({
    Title = "Instant Kill (Validated Hitbox Obliterator)",
    Desc = "Aims chest raycast and deletes active mobs in 1 shot",
    Value = false,
    Callback = function(state)
        Settings.InstantKill = state
    end
})

local ToggleRapidFire = TabCombat:Toggle({
    Title = "Rapid Fire (Machine Gun Hook)",
    Desc = "Forces weapon fire rate to 0.04s, maximizing DPS on all guns",
    Value = false,
    Callback = function(state)
        Settings.RapidFire = state
        if state then
            GunMath.ShotCycle = function() return 0.04 end
        else
            GunMath.ShotCycle = origShotCycle
        end
    end
})

local ToggleInfAmmo = TabCombat:Toggle({
    Title = "Infinite Ammo & No Reload",
    Desc = "Magazine never empties and guns never reload",
    Value = false,
    Callback = function(state)
        Settings.InfiniteAmmo = state
        if state then
            AmmoController.CanFire = function() return true end
            AmmoController.IsReloading = function() return false end
            GunMath.Magazine = function() return 999999 end
            GunMath.ReloadSeconds = function() return 0 end
        else
            AmmoController.CanFire = origCanFire
            AmmoController.IsReloading = origIsReloading
            GunMath.Magazine = origMagazine
            GunMath.ReloadSeconds = origReloadSeconds
        end
    end
})

--------------------------------------------------------------------------------
-- TAB 2: AUTO STAGE SWEEPER (100% HANDS-FREE)
--------------------------------------------------------------------------------
local TabFarm = Window:Tab({
    Title = "Stage Sweeper",
    Icon = "swords",
})

TabFarm:Section({ Title = "Autonomous Progression (No Manual Walking)" })

local ToggleSweeper = TabFarm:Toggle({
    Title = "Auto Stage Sweeper (Full Hands-Free 1-69)",
    Desc = "Sweeps rooms, kills all mobs, vacuums rare loot, and advances continuously",
    Value = false,
    Callback = function(state)
        Settings.AutoStageSweeper = state
        if state then
            Settings.GodMode = true
            ToggleGod:Set(true)
            Settings.InstantKill = true
            ToggleInstaKill:Set(true)
            Settings.RapidFire = true
            ToggleRapidFire:Set(true)
            Settings.InfiniteAmmo = true
            ToggleInfAmmo:Set(true)
        end
    end
})

local StageList = {}
for i = 1, 69 do table.insert(StageList, "Stage " .. i) end

local DropdownStage = TabFarm:Dropdown({
    Title = "Manual Stage Warp",
    Values = StageList,
    Value = "Stage 1",
    Callback = function(val)
        local num = tonumber(string.match(tostring(val), "%d+"))
        if num then Settings.SelectedStage = num end
    end
})

TabFarm:Button({
    Title = "Teleport to Selected Stage Spawn",
    Callback = function()
        local stageName = "Stage" .. Settings.SelectedStage
        local stage = Workspace:FindFirstChild("Stages") and Workspace.Stages:FindFirstChild(stageName)
        local sp = stage and stage:FindFirstChild("Spawns") and stage.Spawns:FindFirstChild("Spawn_2")
        local floor = stage and stage:FindFirstChild("Floor")
        local pos = (sp and sp.Position) or (floor and floor.Position)
        if pos then
            Teleport(pos + Vector3.new(0, 3, 0))
            SendNotify("Stage Warp", "Warped to Stage " .. Settings.SelectedStage, 2)
        end
    end
})

TabFarm:Section({ Title = "Smart Loot Filter (No Junk Ores)" })

local DropdownDropFilter = TabFarm:Dropdown({
    Title = "Minimum Loot Rarity",
    Desc = "Ignores small junk drops (slagstone, rustiron) to keep bag clean for rare ores",
    Values = {
        "All (No Filter)",
        "Uncommon+",
        "Rare+ (Recommended)",
        "Epic+",
        "Legendary+",
        "Secret / Exotic Only"
    },
    Value = "Rare+ (Recommended)",
    Callback = function(val)
        Settings.DropFilterMinRarity = tostring(val)
    end
})

local ToggleReturnBag = TabFarm:Toggle({
    Title = "Auto Bank & Sell on Full Bag",
    Desc = "Seamlessly banks carried scrap and remote sells when bag is full",
    Value = true,
    Callback = function(state)
        Settings.AutoBankOnBagFull = state
    end
})

--------------------------------------------------------------------------------
-- TAB 3: AFK POWER TRAINING
--------------------------------------------------------------------------------
local TabTrain = Window:Tab({
    Title = "Power Training",
    Icon = "dumbbell",
})

TabTrain:Section({ Title = "AFK Power Progression" })

local ToggleTrainBest = TabTrain:Toggle({
    Title = "Auto Train (Highest Unlocked Pad)",
    Desc = "Teleports to highest rebirth pad, locks target, and fires at max speed",
    Value = false,
    Callback = function(state)
        Settings.AutoTrainBest = state
        if not state then
            FireController.SetHolding(false)
            FireController.SetForcedTarget(nil)
        end
    end
})

local PadNames = {}
for _, p in ipairs(TRAINING_PADS) do table.insert(PadNames, p.Name) end

local DropdownPad = TabTrain:Dropdown({
    Title = "Select Specific Pad",
    Values = PadNames,
    Value = "Pad1_5x",
    Callback = function(val)
        Settings.SelectedPad = tostring(val)
    end
})

TabTrain:Button({
    Title = "Teleport to Selected Pad",
    Callback = function()
        for _, p in ipairs(TRAINING_PADS) do
            if p.Name == Settings.SelectedPad then
                Teleport(p.Pos)
                SendNotify("Training", "Teleported to " .. p.Name, 2)
                break
            end
        end
    end
})

local ToggleShootPad = TabTrain:Toggle({
    Title = "Hold Trigger Continuously (On Pad)",
    Value = false,
    Callback = function(state)
        Settings.AutoShootPad = state
        if not state then FireController.SetHolding(false) end
    end
})

--------------------------------------------------------------------------------
-- TAB 4: STANDLESS REMOTES (ZERO-WALK)
--------------------------------------------------------------------------------
local TabEconomy = Window:Tab({
    Title = "Standless Remotes",
    Icon = "hammer",
})

TabEconomy:Section({ Title = "Standless Automated Systems" })

local ToggleRemoteSell = TabEconomy:Toggle({
    Title = "Standless Auto Sell Ores",
    Desc = "Sells banked scrap via micro-teleport without player leaving current spot",
    Value = false,
    Callback = function(state)
        Settings.RemoteSell = state
    end
})

local ToggleRemoteForge = TabEconomy:Toggle({
    Title = "Standless Auto Forge Guns",
    Desc = "Crafts guns via micro-teleport without player having to walk to Forge",
    Value = false,
    Callback = function(state)
        Settings.RemoteForge = state
    end
})

local ToggleUpgrade = TabEconomy:Toggle({
    Title = "100% Remote Auto Upgrade",
    Desc = "Buys Capacity, Luck, Training, Speed from anywhere on the map",
    Value = false,
    Callback = function(state)
        Settings.AutoUpgrade = state
    end
})

local ToggleEquipBest = TabEconomy:Toggle({
    Title = "Remote Auto Equip Best Gun",
    Desc = "Always equips the highest power weapon available",
    Value = false,
    Callback = function(state)
        Settings.AutoEquipBest = state
    end
})

local ToggleRebirth = TabEconomy:Toggle({
    Title = "100% Remote Auto Rebirth",
    Desc = "Executes rebirth the moment firepower threshold is achieved",
    Value = false,
    Callback = function(state)
        Settings.AutoRebirth = state
    end
})

--------------------------------------------------------------------------------
-- TAB 5: VISUALS & ESP
--------------------------------------------------------------------------------
local TabVisuals = Window:Tab({
    Title = "Visuals & ESP",
    Icon = "eye",
})

TabVisuals:Section({ Title = "Highlight Visuals" })

local ToggleEnemyESP = TabVisuals:Toggle({
    Title = "Enemy Highlight ESP",
    Desc = "Renders visible red outlines on all monsters across active stage",
    Value = false,
    Callback = function(state)
        Settings.EnemyESP = state
        if not state then
            local ef = Workspace:FindFirstChild("EnemyFolder")
            if ef then
                for _, e in ipairs(ef:GetChildren()) do
                    local hl = e:FindFirstChild("ESPHighlight")
                    if hl then hl:Destroy() end
                end
            end
        end
    end
})

local ToggleDropESP = TabVisuals:Toggle({
    Title = "Filtered Ores / Scrap Drop ESP",
    Desc = "Renders gold outlines on valuable dropped materials",
    Value = false,
    Callback = function(state)
        Settings.DropESP = state
        if not state then
            local sd = Workspace:FindFirstChild("ScrapDrops")
            if sd then
                for _, d in ipairs(sd:GetChildren()) do
                    local hl = d:FindFirstChild("DropHighlight")
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
    Value = { Min = 16, Max = 200, Default = 16 },
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

TabMovement:Section({ Title = "AFK & Session Protection" })

local ToggleAntiAFK = TabMovement:Toggle({
    Title = "Anti-AFK (Idle Kick Bypass)",
    Desc = "Neutralizes 20-minute Roblox idle kick via connection suppression & VirtualUser simulation",
    Value = false,
    Callback = function(state)
        Settings.AntiAFK = state
        if state then
            pcall(function()
                for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
                    if conn.Disable then conn:Disable() end
                end
            end)
            SendNotify("Anti-AFK", "Idle kick protection activated!", 3)
        end
    end
})

--------------------------------------------------------------------------------
-- TAB 7: TELEPORTS
--------------------------------------------------------------------------------
local TabTeleport = Window:Tab({
    Title = "Teleports",
    Icon = "map-pin",
})

TabTeleport:Section({ Title = "Lobby Stations" })

TabTeleport:Button({ Title = "Lobby Spawn / Center", Callback = function() Teleport(LOCATIONS.Spawn) end })
TabTeleport:Button({ Title = "Sell Booth", Callback = function() Teleport(LOCATIONS.SellBooth) end })
TabTeleport:Button({ Title = "Upgrade Booth", Callback = function() Teleport(LOCATIONS.UpgradeBooth) end })
TabTeleport:Button({ Title = "Forge Station", Callback = function() Teleport(LOCATIONS.Forge) end })
TabTeleport:Button({ Title = "Spin Wheel", Callback = function() Teleport(LOCATIONS.SpinWheel) end })
TabTeleport:Button({ Title = "Free Reward Pedestal", Callback = function() Teleport(LOCATIONS.FreeReward) end })
TabTeleport:Button({ Title = "Bounty Board", Callback = function() Teleport(LOCATIONS.BountyBoard) end })

TabTeleport:Section({ Title = "Training Pads" })
for _, pad in ipairs(TRAINING_PADS) do
    TabTeleport:Button({
        Title = pad.Name .. " (" .. pad.Rebirths .. " Rebirths)",
        Callback = function() Teleport(pad.Pos) end
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
            ToggleGod:Set(Settings.GodMode)
            ToggleInstaKill:Set(Settings.InstantKill)
            ToggleRapidFire:Set(Settings.RapidFire)
            ToggleInfAmmo:Set(Settings.InfiniteAmmo)
            ToggleSweeper:Set(Settings.AutoStageSweeper)
            DropdownDropFilter:Select(Settings.DropFilterMinRarity)
            ToggleReturnBag:Set(Settings.AutoBankOnBagFull)
            ToggleTrainBest:Set(Settings.AutoTrainBest)
            ToggleShootPad:Set(Settings.AutoShootPad)
            ToggleRemoteSell:Set(Settings.RemoteSell)
            ToggleRemoteForge:Set(Settings.RemoteForge)
            ToggleUpgrade:Set(Settings.AutoUpgrade)
            ToggleEquipBest:Set(Settings.AutoEquipBest)
            ToggleRebirth:Set(Settings.AutoRebirth)
            ToggleEnemyESP:Set(Settings.EnemyESP)
            ToggleDropESP:Set(Settings.DropESP)
            ToggleFly:Set(Settings.Fly)
            SliderFlySpeed:Set(Settings.FlySpeed)
            ToggleClickTP:Set(Settings.ClickTP)
            ToggleSpeed:Set(Settings.WalkSpeedEnabled)
            SliderSpeed:Set(Settings.WalkSpeed)
            ToggleJump:Set(Settings.JumpPowerEnabled)
            SliderJump:Set(Settings.JumpPower)
            ToggleInfJump:Set(Settings.InfiniteJump)
            ToggleNoClip:Set(Settings.NoClip)
            ToggleAntiAFK:Set(Settings.AntiAFK)
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
        ToggleGod:Set(false)
        ToggleInstaKill:Set(false)
        ToggleRapidFire:Set(false)
        ToggleInfAmmo:Set(false)
        ToggleSweeper:Set(false)
        ToggleReturnBag:Set(false)
        ToggleTrainBest:Set(false)
        ToggleShootPad:Set(false)
        ToggleRemoteSell:Set(false)
        ToggleRemoteForge:Set(false)
        ToggleUpgrade:Set(false)
        ToggleEquipBest:Set(false)
        ToggleRebirth:Set(false)
        ToggleEnemyESP:Set(false)
        ToggleDropESP:Set(false)
        ToggleFly:Set(false)
        ToggleClickTP:Set(false)
        ToggleSpeed:Set(false)
        ToggleJump:Set(false)
        ToggleInfJump:Set(false)
        ToggleNoClip:Set(false)
        ToggleAntiAFK:Set(false)
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

getgenv()._GunForgeCleanup = function()
    running = false
    StopFly()
    GunMath.ShotCycle = origShotCycle
    GunMath.Magazine = origMagazine
    GunMath.ReloadSeconds = origReloadSeconds
    AmmoController.CanFire = origCanFire
    AmmoController.IsReloading = origIsReloading
    FireController.SetAutoFarm(false)
    FireController.SetHolding(false)
    FireController.SetForcedTarget(nil)
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

-- 2. Infinite Jump Hook
UserInputService.JumpRequest:Connect(function()
    if not running then return end
    if Settings.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 3. Stepped Hook: God Mode, NoClip, Speed, Flight
RunService.Stepped:Connect(function()
    if not running then return end

    -- God Mode (Continuous Health & Death Bypass)
    if Settings.GodMode then
        local hum = GetHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
            if hum.Health <= 0 and RequestRevive then
                RequestRevive:FireServer()
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

    -- WalkSpeed
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

-- 4. ESP Render Hook
task.spawn(function()
    while running and task.wait(0.5) do
        if Settings.EnemyESP then
            local ef = Workspace:FindFirstChild("EnemyFolder")
            if ef then
                for _, enemy in ipairs(ef:GetChildren()) do
                    if enemy:IsA("Model") and not enemy:FindFirstChild("ESPHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESPHighlight"
                        hl.FillColor = Color3.fromRGB(255, 45, 45)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = enemy
                    end
                end
            end
        end

        if Settings.DropESP then
            local sd = Workspace:FindFirstChild("ScrapDrops")
            if sd then
                for _, drop in ipairs(sd:GetChildren()) do
                    if not drop:FindFirstChild("DropHighlight") then
                        if ShouldCollectDrop(drop) then
                            local hl = Instance.new("Highlight")
                            hl.Name = "DropHighlight"
                            hl.FillColor = Color3.fromRGB(255, 215, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.OutlineTransparency = 0
                            hl.Parent = drop
                        end
                    end
                end
            end
        end
    end
end)

-- 5. Core Automation Loop (Full Hands-Free Auto Stage Sweeper & Drop Vacuum)
task.spawn(function()
    local lastSell = 0
    local lastUpgrade = 0
    local lastForge = 0
    local lastRebirth = 0
    local lastEquipCheck = 0
    local lastStageTick = 0

    while running and task.wait(0.08) do
        local now = os.clock()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local data = ClientState.Data or {}

        -- Auto Train Best Pad
        if Settings.AutoTrainBest and hrp then
            local bestPad = GetBestPad()
            local dist = (hrp.Position - bestPad.Pos).Magnitude
            if dist > 8 then
                Teleport(bestPad.Pos)
                task.wait(0.3)
            end

            local padInst = GetPadInstance(bestPad.Name)
            local face = padInst and padInst:FindFirstChild("Target") and padInst.Target:FindFirstChild("Face")
            local targetPart = face and (face:FindFirstChild("Face_White") or face.PrimaryPart)

            if targetPart then
                FireController.SetForcedTarget(targetPart, 0)
                FireController.SetHolding(true)
            else
                FireController.SetHolding(true)
            end
        elseif Settings.AutoShootPad then
            FireController.SetHolding(true)
        end

        -- Standalone Instant Kill (when not using AutoStageSweeper)
        if Settings.InstantKill and not Settings.AutoTrainBest and not Settings.AutoStageSweeper and hrp then
            local enemyFolder = Workspace:FindFirstChild("EnemyFolder")
            local enemies = enemyFolder and enemyFolder:GetChildren() or {}

            for _, enemy in ipairs(enemies) do
                local enemyId = enemy:IsA("Model") and enemy:GetAttribute("EnemyId")
                if enemyId then
                    local targetPos = enemy:GetPivot().Position
                    local origin = hrp.Position + Vector3.new(0, 1.5, 0)
                    local cf = CFrame.lookAt(origin, targetPos)
                    RequestFire:FireServer(enemyId, cf)
                end
            end
        end

        -- FULL HANDS-FREE AUTO STAGE SWEEPER (Stages 1 to 69)
        if Settings.AutoStageSweeper and (now - lastStageTick >= 0.2) and hrp then
            lastStageTick = now

            local currentStage = LocalPlayer:GetAttribute("EnemiesStage") or 0
            local unlockedStage = LocalPlayer:GetAttribute("StageUnlocked") or 1
            local targetStage = math.max(currentStage, unlockedStage)
            if targetStage < 1 then targetStage = 1 end
            if targetStage > 69 then targetStage = 1 end

            local enemyFolder = Workspace:FindFirstChild("EnemyFolder")
            local enemies = enemyFolder and enemyFolder:GetChildren() or {}
            local targetMob = nil

            for _, e in ipairs(enemies) do
                if e:IsA("Model") and e:GetAttribute("EnemyId") ~= nil then
                    targetMob = e
                    break
                end
            end

            if targetMob then
                -- 1. Smoothly position 5.5 studs directly above target mob (Safe from melee, point-blank accuracy)
                local targetPos = targetMob:GetPivot().Position
                hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + 5.5, targetPos.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero

                -- 2. Unleash validated one-hit deletion
                local enemyId = targetMob:GetAttribute("EnemyId")
                local origin = hrp.Position + Vector3.new(0, 1.5, 0)
                local cf = CFrame.lookAt(origin, targetPos)
                RequestFire:FireServer(enemyId, cf)

                -- 3. Vacuum drops landing beneath player
                local sd = Workspace:FindFirstChild("ScrapDrops")
                if sd then
                    local collected = 0
                    for _, drop in ipairs(sd:GetChildren()) do
                        local dropId = drop:GetAttribute("DropId")
                        if dropId and ShouldCollectDrop(drop) then
                            RequestCollect:FireServer(dropId)
                            collected = collected + 1
                            if collected >= 4 then break end
                        end
                    end
                end
            else
                -- No mobs currently alive in stage: advance to next stage room
                local stageObj = Workspace:FindFirstChild("Stages") and Workspace.Stages:FindFirstChild("Stage" .. targetStage)
                local sp = stageObj and stageObj:FindFirstChild("Spawns") and stageObj.Spawns:FindFirstChild("Spawn_2")
                local floor = stageObj and stageObj:FindFirstChild("Floor")
                local spawnPos = (sp and sp.Position) or (floor and floor.Position)

                if spawnPos and (hrp.Position - spawnPos).Magnitude > 20 then
                    Teleport(spawnPos + Vector3.new(0, 3, 0))
                    hrp.AssemblyLinearVelocity = Vector3.zero
                else
                    -- Advance stage
                    local nextTarget = targetStage + 1
                    if nextTarget > 69 then nextTarget = 1 end
                    local nextStageObj = Workspace:FindFirstChild("Stages") and Workspace.Stages:FindFirstChild("Stage" .. nextTarget)
                    local nextSp = nextStageObj and nextStageObj:FindFirstChild("Spawns") and nextStageObj.Spawns:FindFirstChild("Spawn_2")
                    local nextFloor = nextStageObj and nextStageObj:FindFirstChild("Floor")
                    local nextPos = (nextSp and nextSp.Position) or (nextFloor and nextFloor.Position)
                    if nextPos then
                        Teleport(nextPos + Vector3.new(0, 3, 0))
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end

            -- 4. Check Bag Capacity & Auto-Bank
            if Settings.AutoBankOnBagFull then
                local cap = (data.Derived or {}).CarryCap or 5
                local carried = 0
                for _, count in pairs(data.CarriedScrap or {}) do carried = carried + count end
                if carried >= cap then
                    RemoteActionAt(LOCATIONS.SellBooth, function()
                        RequestReturnHub:FireServer()
                        task.wait(0.1)
                        local banked = data.Scrap or {}
                        for tier, count in pairs(banked) do
                            if count > 0 then RequestSell:FireServer(tier) end
                        end
                    end)
                end
            end
        end

        -- Standless Remote Sell (Micro-Teleport Spoof)
        if Settings.RemoteSell and (now - lastSell >= 2.5) and hrp then
            lastSell = now
            local banked = data.Scrap or {}
            local hasScrap = false
            for _, count in pairs(banked) do
                if count > 0 then hasScrap = true break end
            end

            if hasScrap then
                RemoteActionAt(LOCATIONS.SellBooth, function()
                    for tier, count in pairs(banked) do
                        if count > 0 then RequestSell:FireServer(tier) end
                    end
                end)
            end
        end

        -- Standless Remote Upgrade
        if Settings.AutoUpgrade and (now - lastUpgrade >= 1.5) then
            lastUpgrade = now
            local cash = data.Cash or 0
            if cash > 50 then
                for _, upId in ipairs({"Capacity", "Luck", "Training", "Speed"}) do
                    RequestUpgrade:FireServer(upId)
                end
            end
        end

        -- Standless Remote Forge (Micro-Teleport Spoof)
        if Settings.RemoteForge and (now - lastForge >= 3.5) and hrp then
            lastForge = now
            local banked = data.Scrap or {}
            local totalOres = 0
            local forgeBatch = {}
            for ore, count in pairs(banked) do
                if count > 0 then
                    totalOres = totalOres + count
                    forgeBatch[ore] = math.min(count, 10)
                end
            end

            if totalOres >= (ForgeConfig.MinOrePerForge or 4) then
                RemoteActionAt(LOCATIONS.Forge, function()
                    RequestForge:FireServer(forgeBatch, 1, false)
                end)
            end
        end

        -- Standless Remote Equip Best Weapon
        if Settings.AutoEquipBest and (now - lastEquipCheck >= 3) then
            lastEquipCheck = now
            local ownedGuns = data.Guns or {}
            local bestGunId = nil
            local bestPower = -1

            for gunId, _ in pairs(ownedGuns) do
                local def = GunConfig.ById and GunConfig.ById[gunId]
                local power = def and def.Power or (def and def.BaseDamage) or 0
                if power > bestPower then
                    bestPower = power
                    bestGunId = gunId
                end
            end

            if bestGunId and bestGunId ~= data.EquippedGun then
                RequestEquipGun:FireServer(bestGunId)
            end
        end

        -- Standless Remote Rebirth
        if Settings.AutoRebirth and (now - lastRebirth >= 4) then
            lastRebirth = now
            if GameConfig.RebirthReady and GameConfig.RebirthReady(data) then
                RequestRebirth:FireServer()
                SendNotify("Rebirth", "Rebirth executed remotely!", 3)
            end
        end
    end
end)

SendNotify("+1 Gun Forge Elite", "Framework loaded! Press Left-Control to toggle UI.", 5)
