-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ANT EVOLUTION â ELITE AUTOMATION SUITE
    Universal Architecture & Reverse-Engineered Automation
    Built with WindUI | English Universal Interface
    Default State: STRICTLY ALL OFF
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Clean previous instance if re-executed
if getgenv()._ANT_EVOLUTION_CLEANUP then
    pcall(getgenv()._ANT_EVOLUTION_CLEANUP)
end

-- Wait for Ant modules and Remotes
local Ant = ReplicatedStorage:WaitForChild("Ant", 10)
local Config = require(Ant:WaitForChild("Config"))
local Net = require(Ant:WaitForChild("Net"))
local Registry = require(Ant:WaitForChild("Client"):WaitForChild("Registry"))
local StateModule = require(Ant:WaitForChild("Client"):WaitForChild("State"))

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- State Configuration (Default: ALL OFF)
local State = {
    -- Farming
    AutoCollectOrbs = false,
    AutoEvolve = false,
    AutoRebirth = false,
    AutoClaimQuests = false,
    AutoClaimRecords = false,
    AutoClaimPlaytime = false,
    AutoClaimDaily = false,

    -- Combat
    KillAura = false,
    AuraTarget = "All",
    AuraRadius = 45,
    AutoAbility = false,
    AutoPetBite = false,

    -- Pets & Mutations
    AutoHatchEgg = false,
    HatchSelectedEgg = "Colony",
    AutoRollMutations = false,
    RollAmount = 1,

    -- Upgrades
    AutoUpgradeAll = false,
    AutoJaws = false,
    AutoShell = false,
    AutoLegs = false,
    AutoMagnet = false,
    AutoAppetite = false,
    AutoRegen = false,

    -- Movement & Cheats
    FlyHack = false,
    FlySpeed = 50,
    SpeedHack = false,
    SpeedValue = 35,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,

    -- ESP
    CrittersESP = false,
    PlayersESP = false,
    LostEggsESP = false,
}

-- Config System Storage
local ConfigFolder = "AntEvolution_Configs"
pcall(function()
    if makefolder then makefolder(ConfigFolder) end
end)

local function GetConfigList()
    local list = {}
    pcall(function()
        if listfiles then
            for _, f in ipairs(listfiles(ConfigFolder)) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end)
    if #list == 0 then table.insert(list, "default") end
    return list
end

local function SaveConfig(name)
    name = (name and name ~= "") and name or "default"
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(State)
            writefile(ConfigFolder .. "/" .. name .. ".json", data)
            WindUI:Notify({Title = "Config Saved", Content = "Saved profile: " .. name, Duration = 3})
        end
    end)
end

local function LoadConfig(name)
    name = (name and name ~= "") and name or "default"
    pcall(function()
        local path = ConfigFolder .. "/" .. name .. ".json"
        if isfile and isfile(path) then
            local raw = readfile(path)
            local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if State[k] ~= nil then
                        State[k] = v
                    end
                end
                WindUI:Notify({Title = "Config Loaded", Content = "Loaded profile: " .. name .. ". Re-toggle values to reflect in UI.", Duration = 3})
            end
        else
            WindUI:Notify({Title = "Config Missing", Content = "File not found: " .. path, Duration = 3})
        end
    end)
end

local function ResetConfig()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    pcall(function() LocalPlayer:SetAttribute("MagnetMult", 1) end)
    WindUI:Notify({Title = "Config Reset", Content = "All features set to OFF.", Duration = 3})
end

-- Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = "Ant Evolution",
    Author = "Automation Suite",
    Folder = "AntEvolution_Suite",
    Icon = "bug",
    Size = UDim2.fromOffset(620, 480),
    Theme = "Dark",
    OpenButton = {
        Title = "Ant Evolution",
        Icon = "bug",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("00FFAA"),
            Color3.fromHex("0088FF")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

-- Ensure LeftControl Keybind toggles the window
pcall(function() Window:SetToggleKey(Enum.KeyCode.LeftControl) end)
local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        pcall(function() Window:Toggle() end)
    end
end)

-- Auxiliary Standalone Floating Button (Draggable & Clickable)
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "AntEvoFloatingToggle"
floatGui.ResetOnSpawn = false
pcall(function()
    if gethui then
        floatGui.Parent = gethui()
    else
        floatGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

local floatBtn = Instance.new("TextButton")
floatBtn.Name = "ToggleBtn"
floatBtn.Size = UDim2.new(0, 52, 0, 52)
floatBtn.Position = UDim2.new(0, 20, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
floatBtn.Text = "ð"
floatBtn.TextSize = 26
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.AutoButtonColor = true
floatBtn.Parent = floatGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 26)
btnCorner.Parent = floatBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(0, 230, 160)
btnStroke.Thickness = 2
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Parent = floatBtn

-- Dragging logic for floatBtn
do
    local dragging, dragInput, dragStart, startPos
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    floatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    floatBtn.MouseButton1Click:Connect(function()
        pcall(function() Window:Toggle() end)
    end)
end

-- ==================== TABS SETUP ====================
local TabFarming = Window:Tab({Title = "Farming", Icon = "wheat"})
local TabCombat = Window:Tab({Title = "Combat", Icon = "swords"})
local TabPets = Window:Tab({Title = "Pets & Mutations", Icon = "sparkles"})
local TabUpgrades = Window:Tab({Title = "Upgrades", Icon = "arrow-up-circle"})
local TabMovement = Window:Tab({Title = "Player & Move", Icon = "activity"})
local TabTeleport = Window:Tab({Title = "Teleport & Misc", Icon = "map-pin"})
local TabVisuals = Window:Tab({Title = "Visuals (ESP)", Icon = "eye"})
local TabConfig = Window:Tab({Title = "Config", Icon = "settings"})

-- ==================== TAB 1: FARMING ====================
TabFarming:Section({Title = "Orb & Resource Gathering"})

TabFarming:Toggle({
    Title = "Auto Collect Orbs (Global Magnet)",
    Desc = "Modulates magnet radius to vacuum all food and DNA across the map without disconnects.",
    Value = false,
    Callback = function(val)
        State.AutoCollectOrbs = val
        if not val then
            pcall(function() LocalPlayer:SetAttribute("MagnetMult", 1) end)
        end
    end
})

TabFarming:Toggle({
    Title = "Auto Evolve",
    Desc = "Automatically evolves your ant to the next tier when power threshold is reached.",
    Value = false,
    Callback = function(val)
        State.AutoEvolve = val
    end
})

TabFarming:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths when final stage evolution and power requirements are met.",
    Value = false,
    Callback = function(val)
        State.AutoRebirth = val
    end
})

TabFarming:Section({Title = "Automated Reward Claims"})

TabFarming:Toggle({
    Title = "Auto Claim Quests",
    Desc = "Checks quest progress and automatically claims completed quests.",
    Value = false,
    Callback = function(val)
        State.AutoClaimQuests = val
    end
})

TabFarming:Toggle({
    Title = "Auto Claim Records / Achievements",
    Desc = "Scans all record tiers (Evolver, Hunter, Egg Finder, etc.) and claims ready rewards.",
    Value = false,
    Callback = function(val)
        State.AutoClaimRecords = val
    end
})

TabFarming:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Automatically claims timed gifts whenever unlocked.",
    Value = false,
    Callback = function(val)
        State.AutoClaimPlaytime = val
    end
})

TabFarming:Toggle({
    Title = "Auto Claim Daily Reward",
    Desc = "Collects daily login streak reward automatically.",
    Value = false,
    Callback = function(val)
        State.AutoClaimDaily = val
    end
})

-- ==================== TAB 2: COMBAT ====================
TabCombat:Section({Title = "Kill Aura & Bite Engine"})

TabCombat:Toggle({
    Title = "Kill Aura (Auto Bite)",
    Desc = "Automatically attacks selected targets in range using legit server bite rate.",
    Value = false,
    Callback = function(val)
        State.KillAura = val
    end
})

TabCombat:Dropdown({
    Title = "Aura Target Filter",
    Values = {"All", "Bugs / Aphids", "Enemy Ants", "Bosses Only"},
    Value = "All",
    Callback = function(val)
        State.AuraTarget = val
    end
})

TabCombat:Slider({
    Title = "Aura Range (Studs)",
    Step = 5,
    Value = {Min = 15, Max = 150, Default = 45},
    Callback = function(val)
        State.AuraRadius = val
    end
})

TabCombat:Toggle({
    Title = "Auto Use Ability",
    Desc = "Fires equipped combat ability (Spit / Dash / Stomp) on cooldown when in combat.",
    Value = false,
    Callback = function(val)
        State.AutoAbility = val
    end
})

TabCombat:Toggle({
    Title = "Auto Pet Attack",
    Desc = "Commands equipped pets to bite active targets.",
    Value = false,
    Callback = function(val)
        State.AutoPetBite = val
    end
})

-- ==================== TAB 3: PETS & MUTATIONS ====================
TabPets:Section({Title = "Pet Hatching"})

TabPets:Dropdown({
    Title = "Select Egg Tier",
    Values = {"Colony", "Royal"},
    Value = "Colony",
    Callback = function(val)
        State.HatchSelectedEgg = val
    end
})

TabPets:Toggle({
    Title = "Auto Hatch Egg",
    Desc = "Continuously hatches the selected egg using DNA.",
    Value = false,
    Callback = function(val)
        State.AutoHatchEgg = val
    end
})

TabPets:Section({Title = "Mutation Rolling"})

TabPets:Dropdown({
    Title = "Roll Mode",
    Values = {"1x Roll", "5x Roll"},
    Value = "1x Roll",
    Callback = function(val)
        State.RollAmount = (val == "5x Roll") and 5 or 1
    end
})

TabPets:Toggle({
    Title = "Auto Roll Mutations",
    Desc = "Continuously rolls mutations when roll tokens are available.",
    Value = false,
    Callback = function(val)
        State.AutoRollMutations = val
    end
})

-- ==================== TAB 4: UPGRADES ====================
TabUpgrades:Section({Title = "Stat Upgrades"})

TabUpgrades:Toggle({
    Title = "Auto Upgrade All Stats",
    Desc = "Continuously purchases all available upgrades with DNA.",
    Value = false,
    Callback = function(val)
        State.AutoUpgradeAll = val
    end
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Jaws (Bite Damage)",
    Value = false,
    Callback = function(val) State.AutoJaws = val end
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Shell (Health)",
    Value = false,
    Callback = function(val) State.AutoShell = val end
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Legs (Speed)",
    Value = false,
    Callback = function(val) State.AutoLegs = val end
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Magnet (Radius)",
    Value = false,
    Callback = function(val) State.AutoMagnet = val end
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Appetite (Power Gain)",
    Value = false,
    Callback = function(val) State.AutoAppetite = val end
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Regen (Health Regen)",
    Value = false,
    Callback = function(val) State.AutoRegen = val end
})

-- ==================== TAB 5: PLAYER & MOVEMENT ====================
TabMovement:Section({Title = "Flight & Speed Modification"})

TabMovement:Toggle({
    Title = "Fly Hack",
    Desc = "Fly anywhere with full 3D control (WASD + Space to climb + LeftShift to descend).",
    Value = false,
    Callback = function(val)
        State.FlyHack = val
    end
})

TabMovement:Slider({
    Title = "Fly Speed",
    Step = 5,
    Value = {Min = 20, Max = 250, Default = 60},
    Callback = function(val)
        State.FlySpeed = val
    end
})

TabMovement:Toggle({
    Title = "Speed Hack",
    Desc = "Custom movement speed override.",
    Value = false,
    Callback = function(val)
        State.SpeedHack = val
    end
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Step = 2,
    Value = {Min = 16, Max = 150, Default = 40},
    Callback = function(val)
        State.SpeedValue = val
    end
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air.",
    Value = false,
    Callback = function(val)
        State.InfiniteJump = val
    end
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Pass through terrain, rocks, and obstacles.",
    Value = false,
    Callback = function(val)
        State.Noclip = val
    end
})

TabMovement:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents Roblox 20-minute idle disconnection kick.",
    Value = false,
    Callback = function(val)
        State.AntiAFK = val
    end
})

-- ==================== TAB 6: TELEPORT & MISC ====================
TabTeleport:Section({Title = "Instant Exploitation & Codes"})

TabTeleport:Button({
    Title = "Collect All 20 Lost Eggs (1-Click)",
    Desc = "Instantly touches and collects all 20 hidden eggs for massive rewards.",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            WindUI:Notify({Title = "Error", Content = "Character not found!", Duration = 2})
            return
        end
        local eggsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("LostEggs")
        if not eggsFolder then
            WindUI:Notify({Title = "Error", Content = "LostEggs folder missing!", Duration = 2})
            return
        end
        task.spawn(function()
            local count = 0
            for i = 1, 20 do
                local egg = eggsFolder:FindFirstChild("Egg_" .. i)
                if egg and firetouchinterest then
                    firetouchinterest(hrp, egg, 0)
                    task.wait(0.04)
                    firetouchinterest(hrp, egg, 1)
                    count = count + 1
                end
            end
            WindUI:Notify({Title = "Eggs Collected", Content = "Processed all " .. count .. " eggs!", Duration = 3})
        end)
    end
})

TabTeleport:Button({
    Title = "Redeem All Promo Codes",
    Desc = "Redeems ANTS, EVOLVE, QUEEN, RELEASE with rate-limit pacing.",
    Callback = function()
        task.spawn(function()
            local codes = {"ANTS", "EVOLVE", "QUEEN", "RELEASE"}
            for _, c in ipairs(codes) do
                pcall(function()
                    Net.Get("Redeem"):InvokeServer(c)
                end)
                task.wait(1.5)
            end
            WindUI:Notify({Title = "Redeem Complete", Content = "All valid promo codes submitted.", Duration = 3})
        end)
    end
})

TabTeleport:Section({Title = "Zone Teleports"})

local zonePoints = {
    ["Spawn Area"] = Vector3.new(0, 12, 0),
    ["Flower Field (Garden)"] = Vector3.new(61, 31, 191),
    ["Mushroom Hollow"] = Vector3.new(-165, 27, -164),
    ["Dusty Dunes (Picnic)"] = Vector3.new(225, 27, -61),
    ["Group Chest"] = Vector3.new(40, 6, 48),
}

for zoneName, cpos in pairs(zonePoints) do
    TabTeleport:Button({
        Title = "Teleport to " .. zoneName,
        Callback = function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(cpos)
                WindUI:Notify({Title = "Teleported", Content = "Arrived at " .. zoneName, Duration = 2})
            end
        end
    })
end

-- ==================== TAB 7: VISUALS (ESP) ====================
TabVisuals:Section({Title = "ESP Overlays"})

TabVisuals:Toggle({
    Title = "Bugs & Aphids ESP",
    Value = false,
    Callback = function(val)
        State.CrittersESP = val
    end
})

TabVisuals:Toggle({
    Title = "Enemy Players ESP",
    Value = false,
    Callback = function(val)
        State.PlayersESP = val
    end
})

TabVisuals:Toggle({
    Title = "Lost Eggs ESP",
    Value = false,
    Callback = function(val)
        State.LostEggsESP = val
    end
})

-- ==================== TAB 8: CONFIG ====================
TabConfig:Section({Title = "Profile Management"})

local currentConfigName = "default"

TabConfig:Dropdown({
    Title = "Saved Configs",
    Values = GetConfigList(),
    Value = "default",
    Callback = function(val)
        currentConfigName = val
    end
})

TabConfig:Button({
    Title = "Save Config",
    Desc = "Save current state to selected profile.",
    Callback = function()
        SaveConfig(currentConfigName)
    end
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Load settings from selected profile.",
    Callback = function()
        LoadConfig(currentConfigName)
    end
})

TabConfig:Button({
    Title = "Reset All (ALL OFF Default)",
    Desc = "Turn off all active automation toggles immediately.",
    Callback = function()
        ResetConfig()
    end
})

-- ==================== CORE AUTOMATION WORKERS ====================

-- 1. Anti-AFK Worker
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- 2. Infinite Jump Worker
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 3. Noclip & Speed Worker
local noclipConn = RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if State.SpeedHack and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= State.SpeedValue then
            hum.WalkSpeed = State.SpeedValue
        end
    end
end)

-- 4. Fly Hack Engine
local flyBodyGyro, flyBodyVel
local flyConn = RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera

    if State.FlyHack and hrp and hum and cam then
        if not flyBodyVel or not flyBodyVel.Parent then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Name = "AntFlyVelocity"
            flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.Name = "AntFlyGyro"
            flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            flyBodyGyro.P = 10000
            flyBodyGyro.Parent = hrp
        end

        flyBodyGyro.CFrame = cam.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        if dir.Magnitude > 0 then
            flyBodyVel.Velocity = dir.Unit * State.FlySpeed
        else
            flyBodyVel.Velocity = Vector3.zero
        end
    else
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    end
end)

-- 5. Global Magnet Worker (Farming)
task.spawn(function()
    while true do
        task.wait(0.35)
        if State.AutoCollectOrbs then
            pcall(function()
                if LocalPlayer:GetAttribute("MagnetMult") ~= 250 then
                    LocalPlayer:SetAttribute("MagnetMult", 250)
                end
            end)
        else
            if LocalPlayer:GetAttribute("MagnetMult") ~= 1 then
                pcall(function() LocalPlayer:SetAttribute("MagnetMult", 1) end)
            end
        end
    end
end)

-- 6. Auto Evolve & Rebirth Worker
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoEvolve then
            pcall(function()
                local power = tonumber(LocalPlayer:GetAttribute("Power")) or 0
                local need = tonumber(LocalPlayer:GetAttribute("Need")) or 1
                local stage = tonumber(LocalPlayer:GetAttribute("Stage")) or 1
                local rebirths = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
                local topStage = Config.TopStage(rebirths)

                if power >= need and stage < topStage then
                    Net.Get("Evolve"):InvokeServer()
                end
            end)
        end

        if State.AutoRebirth then
            pcall(function()
                local power = tonumber(LocalPlayer:GetAttribute("Power")) or 0
                local need = tonumber(LocalPlayer:GetAttribute("Need")) or 1
                local stage = tonumber(LocalPlayer:GetAttribute("Stage")) or 1
                local rebirths = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
                local topStage = Config.TopStage(rebirths)

                if stage >= topStage and power >= need then
                    Net.Get("Rebirth"):InvokeServer()
                end
            end)
        end
    end
end)

-- 7. Combat & Kill Aura Worker
task.spawn(function()
    local lastAbilityAt = 0
    while true do
        task.wait(0.28)
        if State.KillAura then
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local bestTarget = nil
                local shortestDist = State.AuraRadius

                for _, creature in ipairs(CollectionService:GetTagged("Creature")) do
                    if creature:IsA("Model") and creature.Parent and creature ~= LocalPlayer.Character then
                        local root = creature.PrimaryPart or creature:FindFirstChildWhichIsA("BasePart")
                        if root then
                            local dist = (root.Position - hrp.Position).Magnitude
                            if dist <= shortestDist then
                                local entId = creature:GetAttribute("EntityId")
                                local species = creature:GetAttribute("Species") or creature.Name

                                local isMatch = false
                                if State.AuraTarget == "All" then
                                    isMatch = true
                                elseif State.AuraTarget == "Bugs / Aphids" then
                                    isMatch = (species == "Aphid" or string.find(string.lower(creature.Name), "aphid") ~= nil)
                                elseif State.AuraTarget == "Enemy Ants" then
                                    isMatch = (entId and entId > 0 and entId ~= LocalPlayer.UserId)
                                elseif State.AuraTarget == "Bosses Only" then
                                    isMatch = (creature:GetAttribute("Boss") == true or string.find(string.lower(creature.Name), "mantis") ~= nil)
                                end

                                if isMatch then
                                    shortestDist = dist
                                    bestTarget = creature
                                end
                            end
                        end
                    end
                end

                if bestTarget then
                    local entId = bestTarget:GetAttribute("EntityId")
                    Net.Get("Bite"):FireServer(entId)

                    if State.AutoPetBite then
                        for _, pet in ipairs(Config.Pets.List) do
                            pcall(function() Net.Get("BitePet"):FireServer(pet.key, entId) end)
                        end
                    end

                    if State.AutoAbility and os.clock() - lastAbilityAt > 1.5 then
                        lastAbilityAt = os.clock()
                        pcall(function()
                            local root = bestTarget.PrimaryPart or bestTarget:FindFirstChildWhichIsA("BasePart")
                            if root then
                                local dir = (root.Position - hrp.Position).Unit
                                Net.Get("Ability"):FireServer("Spit", dir)
                                Net.Get("Ability"):FireServer("Dash", dir)
                                Net.Get("Ability"):FireServer("Stomp", root.Position)
                            end
                        end)
                    end
                end
            end)
        end
    end
end)

-- 8. Auto Upgrades Worker
task.spawn(function()
    local upgradeKeys = {"Jaws", "Shell", "Legs", "Magnet", "Appetite", "Regen"}
    while true do
        task.wait(1.0)
        if State.AutoUpgradeAll then
            for _, u in ipairs(upgradeKeys) do
                pcall(function() Net.Get("BuyUpgrade"):InvokeServer(u) end)
                task.wait(0.1)
            end
        else
            for _, u in ipairs(upgradeKeys) do
                if State["Auto" .. u] then
                    pcall(function() Net.Get("BuyUpgrade"):InvokeServer(u) end)
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- 9. Auto Hatch & Mutations Worker
task.spawn(function()
    while true do
        task.wait(1.0)
        if State.AutoHatchEgg then
            pcall(function()
                Net.Get("HatchPet"):InvokeServer(State.HatchSelectedEgg)
            end)
        end
        if State.AutoRollMutations then
            pcall(function()
                Net.Get("RollMutation"):InvokeServer(State.RollAmount)
            end)
        end
    end
end)

-- 10. Automated Reward Claiming Worker
task.spawn(function()
    while true do
        task.wait(5.0)
        -- Quests
        if State.AutoClaimQuests then
            pcall(function()
                local rawQuests = LocalPlayer:GetAttribute("Quests")
                if rawQuests and type(rawQuests) == "string" then
                    local decoded = HttpService:JSONDecode(rawQuests)
                    if decoded and decoded.q then
                        for idx, qData in ipairs(decoded.q) do
                            local cur = qData[3] or 0
                            local goal = qData[4] or 1
                            local claimed = qData[5] or 0
                            if cur >= goal and claimed == 0 then
                                Net.Get("ClaimQuest"):InvokeServer(idx)
                                task.wait(0.6)
                            end
                        end
                    end
                end
            end)
        end

        -- Records
        if State.AutoClaimRecords then
            pcall(function()
                if Config.Records and Config.Records.List then
                    for _, r in ipairs(Config.Records.List) do
                        Net.Get("ClaimRecord"):InvokeServer(r.key)
                        task.wait(0.3)
                    end
                end
            end)
        end

        -- Playtime
        if State.AutoClaimPlaytime then
            pcall(function()
                if Config.Playtime then
                    for i = 1, #Config.Playtime do
                        Net.Get("ClaimPlaytime"):InvokeServer(i)
                        task.wait(0.3)
                    end
                end
            end)
        end

        -- Daily
        if State.AutoClaimDaily then
            pcall(function()
                Net.Get("ClaimDaily"):InvokeServer()
            end)
        end
    end
end)

-- 11. ESP Rendering Engine
local espFolder = Instance.new("Folder")
espFolder.Name = "AntEvoESPFolder"
pcall(function()
    if gethui then espFolder.Parent = gethui() else espFolder.Parent = LocalPlayer.PlayerGui end
end)

local function createBillboard(adornPart, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Name = "AntESP"
    bb.Adornee = adornPart
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.2
    lbl.Parent = bb

    return bb
end

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            espFolder:ClearAllChildren()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Lost Eggs ESP
            if State.LostEggsESP and workspace.Game:FindFirstChild("LostEggs") then
                for i = 1, 20 do
                    local egg = workspace.Game.LostEggs:FindFirstChild("Egg_" .. i)
                    if egg and egg:IsA("BasePart") then
                        local dist = math.floor((egg.Position - hrp.Position).Magnitude)
                        createBillboard(egg, "ð¥ Egg " .. i .. " [" .. dist .. "m]", Color3.fromRGB(255, 215, 0))
                    end
                end
            end

            -- Critters & Players ESP
            for _, creature in ipairs(CollectionService:GetTagged("Creature")) do
                if creature:IsA("Model") and creature.Parent and creature ~= LocalPlayer.Character then
                    local root = creature.PrimaryPart or creature:FindFirstChildWhichIsA("BasePart")
                    if root then
                        local entId = creature:GetAttribute("EntityId")
                        local species = creature:GetAttribute("Species") or creature.Name
                        local dist = math.floor((root.Position - hrp.Position).Magnitude)

                        if dist <= 300 then
                            if State.CrittersESP and (species == "Aphid" or entId == nil or entId < 0) then
                                createBillboard(root, "ð " .. species .. " [" .. dist .. "m]", Color3.fromRGB(80, 255, 120))
                            elseif State.PlayersESP and (entId and entId > 0) then
                                local stage = creature:GetAttribute("Stage") or "?"
                                createBillboard(root, "ð " .. creature.Name .. " (Stg " .. stage .. ") [" .. dist .. "m]", Color3.fromRGB(255, 80, 80))
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Cleanup Handler for Live Re-execution
getgenv()._ANT_EVOLUTION_CLEANUP = function()
    pcall(function() Window:Destroy() end)
    pcall(function() floatGui:Destroy() end)
    pcall(function() espFolder:Destroy() end)
    pcall(function() keybindConn:Disconnect() end)
    pcall(function() noclipConn:Disconnect() end)
    pcall(function() flyConn:Disconnect() end)
    pcall(function() LocalPlayer:SetAttribute("MagnetMult", 1) end)
end

WindUI:Notify({
    Title = "Ant Evolution Elite",
    Content = "Suite loaded successfully! Press LeftControl or tap the ant icon to open/hide.",
    Duration = 5
})
