-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    +1 BOXING BATTLE EVOLUTION â ELITE AUTOMATION SUITE
    Universal Architecture & Reverse-Engineered Automation
    Built with WindUI | English Universal Interface
    Default State: STRICTLY ALL OFF
]]

-- Core Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Clean previous instance if re-executed
if getgenv()._BOXING_BATTLE_CLEANUP then
    pcall(getgenv()._BOXING_BATTLE_CLEANUP)
end

-- Wait for Game Remotes and Modules
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

local AuraConfig = Modules and require(Modules:WaitForChild("AuraConfig"))
local BoxingConfig = Modules and require(Modules:WaitForChild("BoxingConfig"))
local AuraShop = Modules and require(Modules:WaitForChild("AuraShop"))
local StageUtil = Modules and require(Modules:WaitForChild("StageUtil"))
local Treadmills = Modules and require(Modules:WaitForChild("Treadmills"))
local Worlds = Modules and require(Modules:WaitForChild("Worlds"))

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- State Configuration (Default: STRICTLY ALL OFF)
local State = {
    -- Training & Farming
    AutoClicker = false,
    ClickSpeed = 15,
    AutoPunchingBag = false,
    SelectedBag = "Auto Highest Unlocked",
    AutoTrainHere = false,
    AutoTapBoost = false,

    -- Combat & Stages
    AutoFight = false,
    AutoBeatStages = false,
    TargetStage = 1,
    PunchType = "Max DPS Hooks",
    PunchSpeed = 0.22,
    AutoGuard = false,
    AutoRevive = false,
    AutoLastStageWinpad = false,
    SelectedWinpad = "x1 Win (Normal)",
    WinpadDelay = 1.2,

    -- Progression & Evolution
    AutoRebirth = false,
    AutoAscend = false,
    AutoPrestige = false,
    ServerAutoRebirth = false,
    AutoBuyBestGlove = false,
    SelectedGlove = "Blue",

    -- Rewards & Claims
    AutoClaimRewards = false,
    AutoRedeemCodes = false,

    -- Movement & Exploits
    SpeedHack = false,
    WalkSpeed = 16,
    FlyHack = false,
    FlySpeed = 50,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = false,
}

-- Config System Storage
local ConfigFolder = "BoxingBattle_Configs"
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
    WindUI:Notify({Title = "Config Reset", Content = "All features set to OFF.", Duration = 3})
end

-- Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = "Boxing Battle Evolution",
    Author = "Automation Suite",
    Folder = "BoxingBattle_Suite",
    Icon = "swords",
    Size = UDim2.fromOffset(620, 480),
    Theme = "Dark",
    OpenButton = {
        Title = "Boxing Battle",
        Icon = "swords",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("FF4500"),
            Color3.fromHex("FFD700")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

-- LeftControl Keybind toggle
pcall(function() Window:SetToggleKey(Enum.KeyCode.LeftControl) end)
local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        pcall(function() Window:Toggle() end)
    end
end)

-- Standalone Floating Draggable Button
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "BoxingFloatingToggle"
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
floatBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
floatBtn.Text = "ð¥"
floatBtn.TextSize = 26
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.AutoButtonColor = true
floatBtn.Parent = floatGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 26)
btnCorner.Parent = floatBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 69, 0)
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
local TabTraining = Window:Tab({Title = "Training", Icon = "dumbbell"})
local TabCombat = Window:Tab({Title = "Combat", Icon = "swords"})
local TabProgression = Window:Tab({Title = "Progression", Icon = "zap"})
local TabRewards = Window:Tab({Title = "Rewards", Icon = "gift"})
local TabTeleport = Window:Tab({Title = "Teleports", Icon = "map-pin"})
local TabMovement = Window:Tab({Title = "Movement", Icon = "gauge"})
local TabConfig = Window:Tab({Title = "Config", Icon = "settings"})

-- Reference Coordinates & Helpers
local PUNCHING_BAGS = {
    ["Auto Highest Unlocked"] = nil,
    ["Galaxy (500x)"] = Vector3.new(53.40, 10.21, -340.76),
    ["Angel (100x)"] = Vector3.new(6.51, 14.74, -301.16),
    ["Rainbow (50x)"] = Vector3.new(6.43, 15.01, -317.96),
    ["Lava (12x)"] = Vector3.new(6.43, 15.01, -338.26),
    ["Void (9x)"] = Vector3.new(6.43, 15.01, -352.16),
    ["Diamond (6x)"] = Vector3.new(6.43, 15.01, -280.96),
    ["Ruby (4x)"] = Vector3.new(6.43, 15.01, -266.96),
    ["Emerald (3x)"] = Vector3.new(27.98, 11.02, -350.31),
    ["Golden (2x)"] = Vector3.new(27.98, 11.02, -268.71),
    ["Default (1x)"] = Vector3.new(27.98, 11.02, -315.61),
}

local STAGES = {
    [1] = {name = "Stage 1 (Noob)", pos = Vector3.new(93.48, 14.15, -203.75), opponent = "Noob"},
    [2] = {name = "Stage 2 (Beginner)", pos = Vector3.new(93.48, 14.15, -157.55), opponent = "Beginner"},
    [3] = {name = "Stage 3 (Rookie)", pos = Vector3.new(93.48, 14.15, -111.35), opponent = "Rookie"},
    [4] = {name = "Stage 4 (Starter)", pos = Vector3.new(93.48, 14.15, -64.96), opponent = "Starter"},
    [5] = {name = "Stage 5 (Better)", pos = Vector3.new(93.48, 14.15, -18.76), opponent = "Better"},
    [6] = {name = "Stage 6 (Advanced)", pos = Vector3.new(93.48, 14.15, 27.44), opponent = "Advanced"},
    [7] = {name = "Stage 7 (Pro)", pos = Vector3.new(93.48, 14.15, 73.64), opponent = "Pro"},
    [8] = {name = "Stage 8 (Challenger)", pos = Vector3.new(93.48, 14.15, 119.84), opponent = "Challenger"},
    [9] = {name = "Stage 9 (Expert)", pos = Vector3.new(93.48, 14.15, 166.04), opponent = "Expert"},
    [10] = {name = "Stage 10 (Elite)", pos = Vector3.new(93.48, 14.15, 212.24), opponent = "Elite"},
    [11] = {name = "Stage 11 (Master)", pos = Vector3.new(93.48, 14.15, 258.44), opponent = "Master"},
    [12] = {name = "Stage 12 (Boss)", pos = Vector3.new(93.48, 14.15, 304.64), opponent = "Boss"},
    [13] = {name = "Stage 13 (Champion)", pos = Vector3.new(93.48, 14.15, 350.84), opponent = "Champion"},
    [14] = {name = "Stage 14 (Legend)", pos = Vector3.new(93.48, 14.15, 397.24), opponent = "Legend"},
    [15] = {name = "Stage 15 (Mike Tyson)", pos = Vector3.new(93.48, 14.15, 443.64), opponent = "MikeTyson"},
}

local GLOVES_SHOP = {
    ["Red"] = Vector3.new(125.91, 11.90, -328.32),
    ["Blue"] = Vector3.new(125.91, 11.90, -318.53),
    ["Silver"] = Vector3.new(125.91, 11.90, -308.74),
    ["Golden"] = Vector3.new(125.91, 11.90, -298.95),
    ["Diamond"] = Vector3.new(125.91, 11.90, -289.16),
    ["Emerald"] = Vector3.new(141.81, 16.01, -339.21),
    ["Lava"] = Vector3.new(141.81, 16.01, -326.97),
    ["Lightning"] = Vector3.new(141.81, 16.01, -314.73),
    ["Rainbow"] = Vector3.new(141.81, 16.01, -302.50),
    ["Galaxy"] = Vector3.new(141.81, 16.01, -290.26),
    ["Void"] = Vector3.new(141.81, 16.01, -278.03),
}

local GLOVE_ORDER = {
    "Red", "Blue", "Silver", "Golden", "Diamond",
    "Emerald", "Lava", "Lightning", "Rainbow", "Galaxy", "Void"
}

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function SafeTeleport(cframe)
    local hrp = GetRootPart()
    if hrp then
        hrp.CFrame = cframe
    end
end

local function TouchTrigger(triggerPart)
    local hrp = GetRootPart()
    if hrp and triggerPart then
        pcall(function()
            if firetouchinterest then
                firetouchinterest(hrp, triggerPart, 0)
                task.wait(0.04)
                firetouchinterest(hrp, triggerPart, 1)
            end
        end)
    end
end

local function GetCurrentWorld()
    local w = LocalPlayer:GetAttribute("World")
    if not w and Worlds and Worlds.Get then
        w = Worlds.Get(LocalPlayer)
    end
    return w or 1
end

local function GetLastStageFolder()
    local world = GetCurrentWorld()
    local root = (world == 2 and workspace:FindFirstChild("WORLD2")) or workspace
    if not root then root = workspace end

    for stgNum = 15, 1, -1 do
        local folder = root:FindFirstChild("Stage" .. stgNum)
        if folder and (folder:FindFirstChild("Win") or folder:FindFirstChild("x2Win") or folder:FindFirstChild("x3Win")) then
            return folder, stgNum, world
        end
    end
    return root:FindFirstChild("LastStage"), 1, world
end

local function StepLastStageWinpad()
    local folder, stgNum, world = GetLastStageFolder()
    if not folder then
        WindUI:Notify({Title = "Winpad Error", Content = "Could not locate last stage folder!", Duration = 3})
        return false
    end

    local padModel
    local sel = State.SelectedWinpad or "x1 Win (Normal)"
    if sel == "x1 Win (Normal)" then
        padModel = folder:FindFirstChild("Win") or folder:FindFirstChild("x2Win")
    elseif sel == "x2 Win" then
        padModel = folder:FindFirstChild("x2Win") or folder:FindFirstChild("Win")
    elseif sel == "x3 Win" then
        padModel = folder:FindFirstChild("x3Win") or folder:FindFirstChild("x2Win") or folder:FindFirstChild("Win")
    else
        padModel = folder:FindFirstChild("Win") or folder:FindFirstChild("x2Win")
    end

    if not padModel then
        WindUI:Notify({Title = "Winpad Error", Content = "No winpad found in Stage " .. tostring(stgNum), Duration = 3})
        return false
    end

    local trigger = padModel:FindFirstChild("Trigger") or padModel:FindFirstChildWhichIsA("BasePart")
    if not trigger then
        WindUI:Notify({Title = "Winpad Error", Content = "Trigger part not found in winpad!", Duration = 3})
        return false
    end

    local hrp = GetRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(trigger.Position + Vector3.new(0, 3, 0))
        task.wait(0.12)
        if firetouchinterest then
            firetouchinterest(hrp, trigger, 0)
            task.wait(0.04)
            firetouchinterest(hrp, trigger, 1)
        end
        return true
    end
    return false
end

-- ==================== TAB 1: TRAINING ====================
TabTraining:Section({Title = "Aura & Power Auto Clicker"})

TabTraining:Toggle({
    Title = "Auto Clicker (Aura)",
    Desc = "Rapidly fires AuraClick remote to accumulate Power",
    Value = false,
    Callback = function(val)
        State.AutoClicker = val
    end
})

TabTraining:Slider({
    Title = "Click Speed (CPS)",
    Step = 1,
    Value = {Min = 5, Max = 25, Default = 15},
    Callback = function(val)
        State.ClickSpeed = val
    end
})

TabTraining:Section({Title = "Punching Bags (Zone Multipliers)"})

TabTraining:Toggle({
    Title = "Auto Punching Bag Farm",
    Desc = "Positions character inside PunchingBag zone for passive multi",
    Value = false,
    Callback = function(val)
        State.AutoPunchingBag = val
    end
})

local bagNames = {
    "Auto Highest Unlocked", "Galaxy (500x)", "Angel (100x)", "Rainbow (50x)",
    "Lava (12x)", "Void (9x)", "Diamond (6x)", "Ruby (4x)",
    "Emerald (3x)", "Golden (2x)", "Default (1x)"
}

TabTraining:Dropdown({
    Title = "Selected Punching Bag",
    Values = bagNames,
    Value = "Auto Highest Unlocked",
    Callback = function(val)
        State.SelectedBag = val
    end
})

TabTraining:Toggle({
    Title = "Auto Train Here",
    Desc = "Locks training status directly with the server",
    Value = false,
    Callback = function(val)
        State.AutoTrainHere = val
        if Remotes and Remotes:FindFirstChild("TrainHere") then
            pcall(function() Remotes.TrainHere:FireServer(val) end)
        end
    end
})

TabTraining:Section({Title = "Training Boosts (Multipliers)"})

TabTraining:Toggle({
    Title = "Auto Tap Boost Training (x1.5 / x2 / x3)",
    Desc = "Automatically claims floating power multiplier coins (x1.5, x2, x3) the instant they appear",
    Value = false,
    Callback = function(val)
        State.AutoTapBoost = val
    end
})

-- ==================== TAB 2: COMBAT ====================
TabCombat:Section({Title = "Battle Automation"})

TabCombat:Toggle({
    Title = "Auto Fight Stage",
    Desc = "Automatically triggers fight, sends Ready, and attacks with max DPS",
    Value = false,
    Callback = function(val)
        State.AutoFight = val
    end
})

local stageDisplayNames = {}
for i = 1, #STAGES do
    table.insert(stageDisplayNames, STAGES[i].name)
end

TabCombat:Dropdown({
    Title = "Target Stage Opponent",
    Values = stageDisplayNames,
    Value = stageDisplayNames[1],
    Callback = function(val)
        for i, s in ipairs(STAGES) do
            if s.name == val then
                State.TargetStage = i
                break
            end
        end
    end
})

TabCombat:Dropdown({
    Title = "Punch Attack Type",
    Values = {"Max DPS Hooks", "RightHook (1.25x)", "LeftHook (1.25x)", "Cross (1.0x)", "Jab (0.85x)"},
    Value = "Max DPS Hooks",
    Callback = function(val)
        State.PunchType = val
    end
})

TabCombat:Slider({
    Title = "Punch Speed (Cooldown)",
    Step = 0.01,
    Value = {Min = 0.22, Max = 0.50, Default = 0.22},
    Callback = function(val)
        State.PunchSpeed = val
    end
})

TabCombat:Toggle({
    Title = "Auto Guard (Reactive Parry)",
    Desc = "Automatically guards when opponent winds up attack",
    Value = false,
    Callback = function(val)
        State.AutoGuard = val
    end
})

TabCombat:Toggle({
    Title = "Auto Revive",
    Desc = "Instantly sends revive action if downed in a match",
    Value = false,
    Callback = function(val)
        State.AutoRevive = val
    end
})

TabCombat:Section({Title = "Cleared Stages Auto Beat"})

TabCombat:Toggle({
    Title = "Auto Beat All Cleared Stages",
    Desc = "Continuously beats all stages previously cleared for free wins",
    Value = false,
    Callback = function(val)
        State.AutoBeatStages = val
    end
})

TabCombat:Button({
    Title = "Insta-Beat Current Highest Stage",
    Desc = "Fires AutoBeat on your current BeatenStage",
    Callback = function()
        local beaten = LocalPlayer:GetAttribute("BeatenStage") or 1
        if Remotes and Remotes:FindFirstChild("AutoBeat") then
            pcall(function()
                Remotes.AutoBeat:FireServer(beaten)
                WindUI:Notify({Title = "AutoBeat", Content = "Fired AutoBeat for Stage " .. beaten, Duration = 2})
            end)
        end
    end
})

TabCombat:Section({Title = "Last Stage Winpad (Instant Win Farm)"})

TabCombat:Toggle({
    Title = "Auto Farm Last Stage Winpad",
    Desc = "Continuously teleports to the last stage in current world and steps on the winpad",
    Value = false,
    Callback = function(val)
        State.AutoLastStageWinpad = val
    end
})

TabCombat:Dropdown({
    Title = "Select Winpad Multiplier",
    Values = {"x1 Win (Normal)", "x2 Win", "x3 Win"},
    Value = "x1 Win (Normal)",
    Callback = function(val)
        State.SelectedWinpad = val
    end
})

TabCombat:Slider({
    Title = "Winpad Step Delay",
    Step = 0.1,
    Value = {Min = 0.8, Max = 3.0, Default = 1.2},
    Callback = function(val)
        State.WinpadDelay = val
    end
})

TabCombat:Button({
    Title = "Teleport & Step Winpad (1-Click)",
    Desc = "Teleports to the last stage and steps on the selected winpad immediately",
    Callback = function()
        local ok = StepLastStageWinpad()
        if ok then
            WindUI:Notify({Title = "Winpad", Content = "Stepped on Last Stage Winpad!", Duration = 2})
        end
    end
})

-- ==================== TAB 3: PROGRESSION ====================
TabProgression:Section({Title = "Rebirth, Ascend & Prestige"})

TabProgression:Toggle({
    Title = "Auto Rebirth",
    Desc = "Fires RebirthRequest when requirements are met",
    Value = false,
    Callback = function(val)
        State.AutoRebirth = val
    end
})

TabProgression:Toggle({
    Title = "Auto Ascend",
    Desc = "Fires AscendRequest when level cap is reached",
    Value = false,
    Callback = function(val)
        State.AutoAscend = val
    end
})

TabProgression:Toggle({
    Title = "Auto Prestige",
    Desc = "Fires PrestigeRequest when power requirement is reached",
    Value = false,
    Callback = function(val)
        State.AutoPrestige = val
    end
})

TabProgression:Toggle({
    Title = "Server Auto-Rebirth Mode",
    Desc = "Toggles internal server AutoRebirth state",
    Value = false,
    Callback = function(val)
        State.ServerAutoRebirth = val
        if Remotes and Remotes:FindFirstChild("AutoRebirthToggle") then
            pcall(function() Remotes.AutoRebirthToggle:FireServer(val) end)
        end
    end
})

TabProgression:Section({Title = "Gloves Shop & Equipment"})

TabProgression:Toggle({
    Title = "Auto Buy Best Affordable Glove",
    Desc = "Automatically purchases and equips best glove you have Wins for",
    Value = false,
    Callback = function(val)
        State.AutoBuyBestGlove = val
    end
})

TabProgression:Dropdown({
    Title = "Direct Glove Equip",
    Values = GLOVE_ORDER,
    Value = "Blue",
    Callback = function(val)
        State.SelectedGlove = val
    end
})

TabProgression:Button({
    Title = "Equip Selected Glove Now",
    Desc = "Touches shop trigger to equip selected glove",
    Callback = function()
        local shop = workspace:FindFirstChild("GlovesShop")
        local gloveModel = shop and shop:FindFirstChild(State.SelectedGlove)
        local trig = gloveModel and gloveModel:FindFirstChild("Trigger")
        if trig then
            TouchTrigger(trig)
            WindUI:Notify({Title = "Glove Shop", Content = "Equip triggered for " .. State.SelectedGlove, Duration = 2})
        else
            WindUI:Notify({Title = "Glove Shop", Content = "Trigger not found for " .. State.SelectedGlove, Duration = 2})
        end
    end
})

-- ==================== TAB 4: REWARDS ====================
TabRewards:Section({Title = "Automated Gift Claims"})

TabRewards:Toggle({
    Title = "Auto Claim All Free Rewards",
    Desc = "Automatically loops Daily, Playtime, Leave, and Offline claims",
    Value = false,
    Callback = function(val)
        State.AutoClaimRewards = val
    end
})

local function ClaimAllRewardsRoutine()
    if not Remotes then return end
    pcall(function()
        if Remotes:FindFirstChild("ClaimDaily") then
            Remotes.ClaimDaily:InvokeServer()
        end
    end)
    pcall(function()
        if Remotes:FindFirstChild("ClaimOffline") then
            Remotes.ClaimOffline:InvokeServer()
        end
    end)
    pcall(function()
        if Remotes:FindFirstChild("ClaimLeaveReward") then
            Remotes.ClaimLeaveReward:InvokeServer()
        end
    end)
    pcall(function()
        if Remotes:FindFirstChild("ClaimGroupReward") then
            Remotes.ClaimGroupReward:InvokeServer()
        end
    end)
    pcall(function()
        if Remotes:FindFirstChild("ClaimPlaytime") then
            for i = 1, 12 do
                Remotes.ClaimPlaytime:InvokeServer(i)
                task.wait(0.08)
            end
        end
    end)
end

TabRewards:Button({
    Title = "Claim All Rewards Now",
    Desc = "Instantly claims all available playtime, daily, leave, and offline gifts",
    Callback = function()
        ClaimAllRewardsRoutine()
        WindUI:Notify({Title = "Rewards", Content = "Triggered claim routines for all gift systems!", Duration = 3})
    end
})

TabRewards:Section({Title = "Codes System"})

local KNOWN_CODES = {"PUNCH", "DUOCORE", "RELEASE", "BOXING", "POWER", "CCU", "FREE"}

local function RedeemAllKnownCodes()
    if not Remotes or not Remotes:FindFirstChild("RedeemCode") then return end
    for _, code in ipairs(KNOWN_CODES) do
        pcall(function()
            Remotes.RedeemCode:InvokeServer(code)
        end)
        task.wait(0.5)
    end
end

TabRewards:Toggle({
    Title = "Auto Redeem Codes",
    Desc = "Automatically redeems working developer reward codes",
    Value = false,
    Callback = function(val)
        State.AutoRedeemCodes = val
    end
})

TabRewards:Button({
    Title = "Redeem Known Codes Now",
    Desc = "Redeems PUNCH, DUOCORE, RELEASE, and others",
    Callback = function()
        task.spawn(function()
            RedeemAllKnownCodes()
            WindUI:Notify({Title = "Codes", Content = "Codes redemption sequence finished!", Duration = 3})
        end)
    end
})

-- ==================== TAB 5: TELEPORTS ====================
TabTeleport:Section({Title = "Stage Teleports"})

TabTeleport:Dropdown({
    Title = "Select Stage Location",
    Values = stageDisplayNames,
    Value = stageDisplayNames[1],
    Callback = function(val)
        for i, s in ipairs(STAGES) do
            if s.name == val then
                State.TeleportTargetStage = i
                break
            end
        end
    end
})

TabTeleport:Button({
    Title = "Teleport to Selected Stage",
    Desc = "Teleports directly in front of the stage opponent",
    Callback = function()
        local idx = State.TeleportTargetStage or 1
        local stageData = STAGES[idx]
        if stageData then
            SafeTeleport(CFrame.new(stageData.pos + Vector3.new(0, 3, 5)))
            WindUI:Notify({Title = "Teleport", Content = "Teleported to " .. stageData.name, Duration = 2})
        end
    end
})

TabTeleport:Section({Title = "Area Teleports"})

TabTeleport:Dropdown({
    Title = "Select Punching Bag Location",
    Values = bagNames,
    Value = "Default (1x)",
    Callback = function(val)
        State.TeleportTargetBag = val
    end
})

TabTeleport:Button({
    Title = "Teleport to Selected Bag",
    Desc = "Teleports directly into the chosen bag's zone",
    Callback = function()
        local sel = State.TeleportTargetBag or "Default (1x)"
        local pos = PUNCHING_BAGS[sel]
        if pos then
            SafeTeleport(CFrame.new(pos + Vector3.new(0, 3, 0)))
            WindUI:Notify({Title = "Teleport", Content = "Teleported to " .. sel, Duration = 2})
        end
    end
})

TabTeleport:Button({
    Title = "Teleport to Gloves Shop",
    Desc = "Teleports to the main Gloves Shop plaza",
    Callback = function()
        SafeTeleport(CFrame.new(125.91, 14.0, -318.53))
        WindUI:Notify({Title = "Teleport", Content = "Teleported to Gloves Shop", Duration = 2})
    end
})

TabTeleport:Button({
    Title = "Teleport to Spawn / Lobby",
    Desc = "Teleports back to main game spawn",
    Callback = function()
        SafeTeleport(CFrame.new(85.80, 15.0, -308.95))
        WindUI:Notify({Title = "Teleport", Content = "Teleported to Spawn", Duration = 2})
    end
})

TabTeleport:Section({Title = "World Switcher"})

TabTeleport:Button({
    Title = "Teleport to World 1",
    Desc = "Changes realm to World 1",
    Callback = function()
        if Remotes and Remotes:FindFirstChild("WorldRequest") then
            pcall(function() Remotes.WorldRequest:FireServer(1) end)
        end
    end
})

TabTeleport:Button({
    Title = "Teleport to World 2",
    Desc = "Changes realm to World 2 (If unlocked)",
    Callback = function()
        if Remotes and Remotes:FindFirstChild("WorldRequest") then
            pcall(function() Remotes.WorldRequest:FireServer(2) end)
        end
    end
})

-- ==================== TAB 6: MOVEMENT ====================
TabMovement:Section({Title = "Character Modifications"})

TabMovement:Toggle({
    Title = "Speed Hack",
    Desc = "Modifies walk speed",
    Value = false,
    Callback = function(val)
        State.SpeedHack = val
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = val and State.WalkSpeed or 16
        end
    end
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Step = 1,
    Value = {Min = 16, Max = 150, Default = 16},
    Callback = function(val)
        State.WalkSpeed = val
        if State.SpeedHack then
            local char = GetCharacter()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    end
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Allows walking through walls and barriers",
    Value = false,
    Callback = function(val)
        State.Noclip = val
    end
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air",
    Value = false,
    Callback = function(val)
        State.InfiniteJump = val
    end
})

TabMovement:Toggle({
    Title = "Fly Hack",
    Desc = "Enables 3D flight via BodyVelocity",
    Value = false,
    Callback = function(val)
        State.FlyHack = val
    end
})

TabMovement:Slider({
    Title = "Fly Speed",
    Step = 5,
    Value = {Min = 20, Max = 150, Default = 50},
    Callback = function(val)
        State.FlySpeed = val
    end
})

TabMovement:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents 20-minute Roblox idle kick",
    Value = false,
    Callback = function(val)
        State.AntiAFK = val
    end
})

-- ==================== TAB 7: CONFIG ====================
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

local activeThreads = {}
local function SpawnLoop(func)
    local alive = true
    table.insert(activeThreads, function() alive = false end)
    task.spawn(function()
        while alive do
            local ok, err = pcall(func)
            if not ok then
                task.wait(1)
            end
        end
    end)
end

-- 1. Auto Clicker Loop
SpawnLoop(function()
    if State.AutoClicker and Remotes and Remotes:FindFirstChild("AuraClick") then
        local inBattle = LocalPlayer:GetAttribute("InBattle") or LocalPlayer:GetAttribute("BattleCinematic")
        if not inBattle then
            Remotes.AuraClick:FireServer()
            local waitTime = math.max(0.04, 1 / (State.ClickSpeed or 15))
            task.wait(waitTime)
        else
            task.wait(0.5)
        end
    else
        task.wait(0.2)
    end
end)

-- 2. Auto Punching Bag Positioning Loop
SpawnLoop(function()
    if State.AutoPunchingBag then
        local inBattle = LocalPlayer:GetAttribute("InBattle") or LocalPlayer:GetAttribute("BattleCinematic")
        if not inBattle then
            local targetPos
            if State.SelectedBag == "Auto Highest Unlocked" then
                targetPos = PUNCHING_BAGS["Galaxy (500x)"] or PUNCHING_BAGS["Default (1x)"]
            else
                targetPos = PUNCHING_BAGS[State.SelectedBag]
            end

            local hrp = GetRootPart()
            if hrp and targetPos then
                local dist = (hrp.Position - targetPos).Magnitude
                if dist > 8 then
                    SafeTeleport(CFrame.new(targetPos + Vector3.new(0, 2, 0)))
                end
            end
        end
        task.wait(0.5)
    else
        task.wait(0.5)
    end
end)

-- 3. Combat Loop (Rapid Hooks, Auto Ready, Auto Punch, Auto Guard, Auto Revive)
local punchToggle = false
SpawnLoop(function()
    if State.AutoFight then
        local inBattle = LocalPlayer:GetAttribute("InBattle") or LocalPlayer:GetAttribute("BattleCinematic")
        local boxingAction = Remotes and Remotes:FindFirstChild("BoxingAction")

        if inBattle and boxingAction then
            -- 1. Send Ready
            pcall(function() boxingAction:FireServer("Ready") end)

            -- 2. Handle Auto Revive
            if State.AutoRevive then
                pcall(function() boxingAction:FireServer("Revive") end)
            end

            -- 3. Punch Selection (Hooks = 1.25x damage multiplier)
            local chosenPunch = "RightHook"
            if State.PunchType == "Max DPS Hooks" then
                punchToggle = not punchToggle
                chosenPunch = punchToggle and "RightHook" or "LeftHook"
            elseif State.PunchType == "RightHook (1.25x)" then
                chosenPunch = "RightHook"
            elseif State.PunchType == "LeftHook (1.25x)" then
                chosenPunch = "LeftHook"
            elseif State.PunchType == "Cross (1.0x)" then
                chosenPunch = "Cross"
            elseif State.PunchType == "Jab (0.85x)" then
                chosenPunch = "Jab"
            end

            -- 4. Send Punch
            pcall(function() boxingAction:FireServer("Punch", chosenPunch) end)
            task.wait(math.max(0.22, State.PunchSpeed or 0.22))
        else
            -- Outside battle: seek target stage and fire prompt
            local stageData = STAGES[State.TargetStage or 1]
            if stageData then
                local sFolder = workspace:FindFirstChild("Stage" .. (State.TargetStage or 1))
                local opp = sFolder and sFolder:FindFirstChild(stageData.opponent)
                local hrp = opp and opp:FindFirstChild("HumanoidRootPart")
                local prompt = hrp and hrp:FindFirstChild("DanceBattlePrompt")

                local myHrp = GetRootPart()
                if myHrp and hrp then
                    local dist = (myHrp.Position - hrp.Position).Magnitude
                    if dist > 8 then
                        SafeTeleport(hrp.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.2)
                    end
                end

                if prompt and fireproximityprompt then
                    prompt.Enabled = true
                    prompt.MaxActivationDistance = 40
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
            task.wait(0.4)
        end
    else
        task.wait(0.3)
    end
end)

-- 4. Auto Beat Cleared Stages Loop
SpawnLoop(function()
    if State.AutoBeatStages and Remotes and Remotes:FindFirstChild("AutoBeat") then
        local inBattle = LocalPlayer:GetAttribute("InBattle") or LocalPlayer:GetAttribute("BattleCinematic")
        if not inBattle then
            local beaten = LocalPlayer:GetAttribute("BeatenStage") or 0
            if beaten > 0 then
                for stg = 1, beaten do
                    if not State.AutoBeatStages then break end
                    pcall(function()
                        Remotes.AutoBeat:FireServer(stg)
                    end)
                    task.wait(0.2)
                end
            end
        end
        task.wait(1)
    else
        task.wait(0.5)
    end
end)

-- 4b. Auto Farm Last Stage Winpad Loop
SpawnLoop(function()
    if State.AutoLastStageWinpad then
        local inBattle = LocalPlayer:GetAttribute("InBattle") or LocalPlayer:GetAttribute("BattleCinematic")
        if not inBattle then
            StepLastStageWinpad()
        end
        task.wait(math.max(0.6, State.WinpadDelay or 1.2))
    else
        task.wait(0.5)
    end
end)

-- 5. Auto Rebirth, Ascend, Prestige Loop
SpawnLoop(function()
    if State.AutoRebirth and Remotes and Remotes:FindFirstChild("RebirthRequest") then
        pcall(function() Remotes.RebirthRequest:FireServer() end)
    end
    if State.AutoAscend and Remotes and Remotes:FindFirstChild("AscendRequest") then
        pcall(function() Remotes.AscendRequest:FireServer() end)
    end
    if State.AutoPrestige and Remotes and Remotes:FindFirstChild("PrestigeRequest") then
        pcall(function() Remotes.PrestigeRequest:FireServer() end)
    end
    task.wait(1.5)
end)

-- 6. Auto Buy Best Glove Loop
SpawnLoop(function()
    if State.AutoBuyBestGlove and AuraShop then
        local wins = 0
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Wins") then
            wins = leaderstats.Wins.Value
        end

        local currentWorld = 1
        local shopList = AuraShop.Lists and AuraShop.Lists[currentWorld] or {}
        local bestAffordable = nil

        for _, item in ipairs(shopList) do
            if item.Price and wins >= item.Price then
                bestAffordable = item.Name
            end
        end

        if bestAffordable then
            local shop = workspace:FindFirstChild("GlovesShop")
            local gloveModel = shop and shop:FindFirstChild(bestAffordable)
            local trig = gloveModel and gloveModel:FindFirstChild("Trigger")
            if trig then
                TouchTrigger(trig)
            end
        end
        task.wait(3)
    else
        task.wait(1)
    end
end)

-- 7. Auto Claim Rewards Loop
SpawnLoop(function()
    if State.AutoClaimRewards then
        ClaimAllRewardsRoutine()
        task.wait(30)
    else
        task.wait(2)
    end
end)

-- 8. Auto Redeem Codes Loop
SpawnLoop(function()
    if State.AutoRedeemCodes then
        RedeemAllKnownCodes()
        task.wait(120)
    else
        task.wait(3)
    end
end)

-- 9. Noclip Loop
RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 10. Infinite Jump Connection
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 11. Fly Hack Loop
local flyBodyVel, flyBodyGyro
RunService.RenderStepped:Connect(function()
    local hrp = GetRootPart()
    local cam = workspace.CurrentCamera

    if State.FlyHack and hrp and cam then
        if not flyBodyVel or flyBodyVel.Parent ~= hrp then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or flyBodyGyro.Parent ~= hrp then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBodyGyro.P = 1e4
            flyBodyGyro.Parent = hrp
        end

        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        flyBodyGyro.CFrame = cam.CFrame
        if moveDir.Magnitude > 0 then
            flyBodyVel.Velocity = moveDir.Unit * (State.FlySpeed or 50)
        else
            flyBodyVel.Velocity = Vector3.zero
        end
    else
        if flyBodyVel then
            flyBodyVel:Destroy()
            flyBodyVel = nil
        end
        if flyBodyGyro then
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end
    end
end)

-- 12. Anti-AFK Connection
local afkConn = LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- 13. Auto Tap Training Boost (Reactive Listener + Proactive Watcher)
local boostConn = Remotes and Remotes:FindFirstChild("TreadmillBoost") and Remotes.TreadmillBoost.OnClientEvent:Connect(function(action, mult)
    if State.AutoTapBoost and action == "Show" then
        pcall(function()
            Remotes.TreadmillBoost:FireServer("Claim")
        end)
        local main = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        if hud then
            for _, bName in ipairs({"x1.5GainButton", "x2GainButton", "x3GainButton"}) do
                local b = hud:FindFirstChild(bName)
                if b then b.Visible = false end
            end
        end
    end
end)

SpawnLoop(function()
    if State.AutoTapBoost and Remotes and Remotes:FindFirstChild("TreadmillBoost") then
        local main = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        if hud then
            for _, bName in ipairs({"x1.5GainButton", "x2GainButton", "x3GainButton"}) do
                local b = hud:FindFirstChild(bName)
                if b and b.Visible then
                    pcall(function()
                        Remotes.TreadmillBoost:FireServer("Claim")
                    end)
                    b.Visible = false
                end
            end
        end
        task.wait(0.2)
    else
        task.wait(0.5)
    end
end)

-- ============================================================================
-- GLOBAL TEARDOWN & RE-EXECUTION CLEANUP
-- ============================================================================
getgenv()._BOXING_BATTLE_CLEANUP = function()
    -- Stop background threads
    for _, cancel in ipairs(activeThreads) do
        pcall(cancel)
    end
    table.clear(activeThreads)

    -- Disconnect core listeners
    pcall(function() keybindConn:Disconnect() end)
    pcall(function() jumpConn:Disconnect() end)
    pcall(function() afkConn:Disconnect() end)
    if boostConn then pcall(function() boostConn:Disconnect() end) end

    -- Destroy flight physics objects
    if flyBodyVel then pcall(function() flyBodyVel:Destroy() end) end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end

    -- Destroy UI elements
    pcall(function() floatGui:Destroy() end)
    pcall(function() Window:Destroy() end)

    -- Restore humanoid speed
    pcall(function()
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end)
end

-- Notify Completion
WindUI:Notify({
    Title = "+1 Boxing Battle Evolution",
    Content = "Automation Suite loaded successfully! Press LeftControl or tap ð¥ to toggle.",
    Duration = 4
})
