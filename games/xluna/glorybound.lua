-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    GLORYBOUND ELITE AUTOMATION SUITE
    Game: [TRIALS] GloryBound
    PlaceId: 137629355240872
    Engine: WindUI Universal Framework
    Standard: Default ALL OFF | English UI | LeftCTRL Toggle | Floating Button | Config Manager
]]

-- Environment & Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Resolve Net Module
local NetModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"))
local ClientStateModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("ClientState"))

-- Remote Dispatcher Helper
local function fireRemote(name, ...)
    local remote = NetModule.get(name)
    if remote then
        if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
            remote:FireServer(...)
            return true
        end
    end
    return false
end

-- Default Master Config (Strictly ALL OFF by Default)
local Config = {
    -- Combat
    Killaura = false,
    AttackRange = 15,
    AttackRate = 5, -- Attacks per second (Rate limiter ceiling: 7)
    AutoAim = false,
    TargetMode = "Nearest", -- "Nearest", "Lowest HP"

    AutoParry = false,
    ParryDistance = 16,
    ParryPerfectRatio = 75, -- Safe ratio below server 90% FlagPerfectRate threshold
    AutoDash = false,

    -- Training & Progression
    AutoGym = false,
    GymRepDelay = 0.35, -- Safe delay (Rate limiter: 3/s, burst: 24)
    SelectedBarbell = "Auto Nearest",
    AutoRestAtCap = false,
    AutoRebirth = false,
    AutoUpgradeSkills = false,

    -- Misc / Items
    AutoOpenChests = false,
    AutoBuyCommon = false,
    AutoBuyRare = false,
    InstantPrompts = false,
    AutoSkipCutscenes = false,

    -- Movement & Visuals
    SpeedEnabled = false,
    SpeedValue = 24,
    JumpEnabled = false,
    JumpValue = 50,
    InfiniteJump = false,
    Noclip = false,

    EnemyESP = false,
    GymESP = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPHealth = false,
    ESPState = false,

    -- UI State
    FloatingButton = true,
    UIVisible = true,
}

-- Load WindUI Library
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[GloryBound] Failed to load WindUI from primary CDN")
    return
end

-- Window Construction
local Window = WindUI:CreateWindow({
    Title = "GloryBound Elite",
    Icon = "swords",
    Author = "System Architect",
    Folder = "GloryBound",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
})

-- Configure Keybind for Toggle
Window:SetToggleKey(Enum.KeyCode.LeftControl)

-- Backup Manual Toggle via LeftControl
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        Window:Toggle()
    end
end)

-- File Storage Helpers for Config
local FOLDER_NAME = "GloryBound_Configs"
if not isfolder(FOLDER_NAME) then
    pcall(makefolder, FOLDER_NAME)
end

local function saveConfigFile(name)
    local path = FOLDER_NAME .. "/" .. name .. ".json"
    local encoded = HttpService:JSONEncode(Config)
    pcall(writefile, path, encoded)
    WindUI:Notify({
        Title = "Config Saved",
        Content = "Profile '" .. name .. "' saved successfully.",
        Duration = 3,
        Icon = "check",
    })
end

local function loadConfigFile(name)
    local path = FOLDER_NAME .. "/" .. name .. ".json"
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
                Content = "Profile '" .. name .. "' loaded successfully.",
                Duration = 3,
                Icon = "check",
            })
            return true
        end
    end
    WindUI:Notify({
        Title = "Config Error",
        Content = "File '" .. name .. ".json' does not exist.",
        Duration = 3,
        Icon = "alert-circle",
    })
    return false
end

-- ====================================================================
-- FLOATING TOGGLE BUTTON (Custom Clean ScreenGui)
-- ====================================================================
local floatingGui = Instance.new("ScreenGui")
floatingGui.Name = "GloryBound_FloatingButton"
floatingGui.ResetOnSpawn = false

-- Parent to CoreGui if available, otherwise PlayerGui
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
floatingGui.Parent = guiParent

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "ToggleButton"
floatBtn.Size = UDim2.fromOffset(46, 46)
floatBtn.Position = UDim2.new(0.04, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
floatBtn.BackgroundTransparency = 0.15
floatBtn.AutoButtonColor = true
floatBtn.Parent = floatingGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = floatBtn

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0, 190, 255)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = floatBtn

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.fromOffset(26, 26)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.fromScale(0.5, 0.5)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10709791437" -- Swords Icon
icon.ImageColor3 = Color3.fromRGB(240, 240, 255)
icon.Parent = floatBtn

-- Dragging Logic for Floating Button
local dragging, dragStart, startPos
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
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

-- ====================================================================
-- COMBAT SYSTEM & KILLAURA ENGINE
-- ====================================================================
local attackSequence = 0
local lastAttackTick = 0
local activeParries = {}

-- Get Living Enemies in ActiveEnemies or ArenaBots
local function getActiveEnemies()
    local enemies = {}
    local containers = {"ActiveEnemies", "ArenaBots"}
    for _, name in ipairs(containers) do
        local folder = workspace:FindFirstChild(name)
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                    if hum and root and hum.Health > 0 then
                        table.insert(enemies, {Model = model, Humanoid = hum, Root = root})
                    end
                end
            end
        end
    end
    return enemies
end

-- Find Best Target
local function getTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local enemies = getActiveEnemies()
    if #enemies == 0 then return nil end

    local bestTarget = nil
    local bestMetric = math.huge

    for _, enemy in ipairs(enemies) do
        local dist = (enemy.Root.Position - myRoot.Position).Magnitude
        if dist <= Config.AttackRange then
            if Config.TargetMode == "Nearest" then
                if dist < bestMetric then
                    bestMetric = dist
                    bestTarget = enemy
                end
            elseif Config.TargetMode == "Lowest HP" then
                if enemy.Humanoid.Health < bestMetric then
                    bestMetric = enemy.Humanoid.Health
                    bestTarget = enemy
                end
            end
        end
    end
    return bestTarget
end

-- Killaura Loop
task.spawn(function()
    while true do
        task.wait(0.03)
        if Config.Killaura then
            local now = os.clock()
            local interval = 1 / math.clamp(Config.AttackRate, 1, 6.5)
            if now - lastAttackTick >= interval then
                local target = getTarget()
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

                if target and myRoot then
                    lastAttackTick = now
                    attackSequence = attackSequence + 1

                    -- Direction Vector towards Target
                    local targetPos = target.Root.Position
                    local aimDirection = (Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z) - myRoot.Position).Unit

                    -- Auto Face Target
                    if Config.AutoAim then
                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z))
                    end

                    -- Fire Attack Remote with sequence and direction
                    fireRemote("Attack", attackSequence, aimDirection, false)
                end
            end
        end
    end
end)

-- Smart Auto Parry Engine (Telemetry Safe)
task.spawn(function()
    while true do
        task.wait(0.015)
        if Config.AutoParry then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local enemies = getActiveEnemies()
                local serverTime = workspace:GetServerTimeNow()

                for _, enemy in ipairs(enemies) do
                    local dist = (enemy.Root.Position - myRoot.Position).Magnitude
                    if dist <= Config.ParryDistance then
                        local model = enemy.Model
                        local aiState = model:GetAttribute("AIState")
                        local windupEnd = model:GetAttribute("WindupEnd")

                        if (aiState == "Windup" or aiState == "Attack" or aiState == "Charge") and typeof(windupEnd) == "number" then
                            local remaining = windupEnd - serverTime
                            local parryKey = model:GetDebugId() .. "_" .. tostring(windupEnd)

                            if not activeParries[parryKey] and remaining > 0 and remaining <= 0.28 then
                                activeParries[parryKey] = true

                                -- Anti-Detection Blending:
                                -- Config.ParryPerfectRatio controls chance of perfect vs good parry
                                -- Server flags if perfect parry rate exceeds 90% (FlagPerfectRate = 0.9)
                                local isPerfect = math.random(1, 100) <= Config.ParryPerfectRatio
                                local targetTimeLead = isPerfect and (math.random(40, 85) / 1000) or (math.random(160, 230) / 1000)

                                task.spawn(function()
                                    local waitDuration = remaining - targetTimeLead
                                    if waitDuration > 0 then
                                        task.wait(waitDuration)
                                    end

                                    -- Pulse Block Remote
                                    local nowTime = workspace:GetServerTimeNow()
                                    fireRemote("Block", true, nowTime)
                                    task.wait(0.12)
                                    fireRemote("Block", false, nil)
                                end)

                                -- Optional Auto Dash if enabled
                                if Config.AutoDash then
                                    local dashDir = -enemy.Root.CFrame.LookVector
                                    fireRemote("Dash", dashDir)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Clean Up Stale Parries Map
task.spawn(function()
    while true do
        task.wait(5)
        table.clear(activeParries)
    end
end)

-- ====================================================================
-- AUTO GYM & TRAINING AUTOMATION
-- ====================================================================
local function getGymBarbells()
    local gym = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Gym")
    local barbells = gym and gym:FindFirstChild("Barbells")
    if barbells then
        return barbells:GetChildren()
    end
    return {}
end

local function findAvailableBarbell(preferredName)
    local barbells = getGymBarbells()
    if preferredName and preferredName ~= "Auto Nearest" then
        for _, b in ipairs(barbells) do
            if b.Name == preferredName then
                return b
            end
        end
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local closest = nil
    local closestDist = math.huge

    for _, b in ipairs(barbells) do
        local occupant = b:GetAttribute("Occupant")
        if occupant == 0 or occupant == LocalPlayer.UserId then
            local promptPart = b:FindFirstChild("Prompt")
            local pos = promptPart and promptPart.Position or b:GetPivot().Position
            local dist = myRoot and (pos - myRoot.Position).Magnitude or 0
            if dist < closestDist then
                closestDist = dist
                closest = b
            end
        end
    end
    return closest
end

-- Auto Gym Loop
task.spawn(function()
    while true do
        task.wait(Config.GymRepDelay)
        if Config.AutoGym then
            local isTraining = LocalPlayer:GetAttribute("Training")
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            -- Check Strength Cap
            local state = ClientStateModule.get()
            local curStrength = state and state.Strength or 0
            local strengthCap = state and state.StrengthCap or 50

            if Config.AutoRestAtCap and curStrength >= strengthCap then
                if isTraining then
                    fireRemote("TrainStop")
                end
                task.wait(2)
            else
                if not isTraining or isTraining == "" then
                    -- Find and interact with barbell
                    local barbell = findAvailableBarbell(Config.SelectedBarbell)
                    if barbell and myRoot then
                        local promptPart = barbell:FindFirstChild("Prompt")
                        local prompt = promptPart and promptPart:FindFirstChild("TrainPrompt")
                        if prompt then
                            -- Move character directly to prompt if further than 5 studs
                            if (promptPart.Position - myRoot.Position).Magnitude > 5 then
                                myRoot.CFrame = CFrame.new(promptPart.Position + Vector3.new(0, 3, 0))
                                task.wait(1.0)
                            end
                            fireproximityprompt(prompt, 0)
                            task.wait(0.8)
                        end
                    end
                else
                    -- Send Reps at safe cadence
                    fireRemote("TrainRep", 1)
                end
            end
        end
    end
end)

-- Auto Rebirth Monitor
task.spawn(function()
    while true do
        task.wait(2)
        if Config.AutoRebirth then
            local state = ClientStateModule.get()
            if state and state.RebirthReady == true then
                if LocalPlayer:GetAttribute("Training") then
                    fireRemote("TrainStop")
                    task.wait(0.5)
                end
                fireRemote("Rebirth")
                WindUI:Notify({
                    Title = "Rebirth",
                    Content = "Rebirth triggered successfully.",
                    Duration = 4,
                    Icon = "rotate-cw",
                })
            end
        end
    end
end)

-- Auto Skill Upgrade Monitor
task.spawn(function()
    while true do
        task.wait(3)
        if Config.AutoUpgradeSkills then
            local state = ClientStateModule.get()
            local skillPoints = state and state.SkillPoints or 0
            if skillPoints > 0 then
                -- Upgrade primary origin skill
                fireRemote("SkillUpgrade", "Oath")
            end
        end
    end
end)

-- ====================================================================
-- AUTO CHEST OPENER & BUYER
-- ====================================================================
task.spawn(function()
    while true do
        task.wait(0.65)
        if Config.AutoOpenChests then
            local state = ClientStateModule.get()
            local ownedChests = state and state.OwnedChests or {}
            local chestId = next(ownedChests)
            if chestId then
                fireRemote("ChestOpen", tostring(chestId))
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1.5)
        local state = ClientStateModule.get()
        local cash = state and state.Cash or 0
        if Config.AutoBuyCommon and cash >= 250 then
            fireRemote("ChestBuy", "Common")
        elseif Config.AutoBuyRare and cash >= 750 then
            fireRemote("ChestBuy", "Rare")
        end
    end
end)

-- Instant Prompts & Cutscene Skip
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.InstantPrompts then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
        end
        if Config.AutoSkipCutscenes then
            fireRemote("BossCutsceneSkip", 1)
        end
    end
end)

-- ====================================================================
-- MOVEMENT ENGINE (WalkSpeed, JumpPower, Noclip, Inf Jump)
-- ====================================================================
RunService.RenderStepped:Connect(function()
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
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ====================================================================
-- VISUALS / ESP ENGINE
-- ====================================================================
local espDrawings = {}

local function createESPBox()
    return {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        State = Drawing.new("Text"),
    }
end

local function cleanESP()
    for _, esp in pairs(espDrawings) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.State then esp.State:Remove() end
    end
    table.clear(espDrawings)
end

RunService.RenderStepped:Connect(function()
    if not Config.EnemyESP then
        for _, esp in pairs(espDrawings) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.State.Visible = false
        end
        return
    end

    local enemies = getActiveEnemies()
    local currentIds = {}

    for _, enemy in ipairs(enemies) do
        local model = enemy.Model
        local root = enemy.Root
        local hum = enemy.Humanoid
        local id = model:GetDebugId()
        currentIds[id] = true

        if not espDrawings[id] then
            espDrawings[id] = createESPBox()
        end

        local esp = espDrawings[id]
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            local boxHeight = math.clamp(1800 / dist, 20, 250)
            local boxWidth = boxHeight * 0.65

            -- Box
            esp.Box.Visible = Config.ESPBoxes
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)
            esp.Box.Color = Color3.fromRGB(255, 60, 60)
            esp.Box.Thickness = 1.5

            -- Name & Distance
            esp.Name.Visible = Config.ESPNames
            esp.Name.Text = model.Name .. " [" .. math.floor(dist) .. "m]"
            esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight / 2 - 16)
            esp.Name.Size = 13
            esp.Name.Center = true
            esp.Name.Outline = true
            esp.Name.Color = Color3.fromRGB(255, 255, 255)

            -- Health
            esp.Health.Visible = Config.ESPHealth
            esp.Health.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            esp.Health.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight / 2 + 2)
            esp.Health.Size = 12
            esp.Health.Center = true
            esp.Health.Outline = true
            esp.Health.Color = Color3.fromRGB(80, 255, 120)

            -- AI State (Windup / Attack / Idle)
            local aiState = model:GetAttribute("AIState") or "Idle"
            esp.State.Visible = Config.ESPState
            esp.State.Text = "[" .. string.upper(tostring(aiState)) .. "]"
            esp.State.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight / 2 + 16)
            esp.State.Size = 11
            esp.State.Center = true
            esp.State.Outline = true
            esp.State.Color = (aiState == "Windup" or aiState == "Attack") and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(180, 180, 200)
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.State.Visible = false
        end
    end

    -- Cleanup despawned enemies
    for id, esp in pairs(espDrawings) do
        if not currentIds[id] then
            esp.Box:Remove()
            esp.Name:Remove()
            esp.Health:Remove()
            esp.State:Remove()
            espDrawings[id] = nil
        end
    end
end)

-- ====================================================================
-- WINDUI TABS & INTERFACE SETUP
-- ====================================================================

-- TAB 1: COMBAT
local TabCombat = Window:Tab({Title = "Combat", Icon = "swords"})
TabCombat:Section({Title = "Killaura / Automated Combat"})

TabCombat:Toggle({
    Title = "Enable Killaura",
    Desc = "Automatically targets and attacks nearest enemies",
    Value = Config.Killaura,
    Callback = function(v) Config.Killaura = v end,
})

TabCombat:Slider({
    Title = "Attack Range",
    Desc = "Target distance detection threshold",
    Step = 1,
    Value = {Min = 5, Max = 35, Default = Config.AttackRange},
    Callback = function(v) Config.AttackRange = v end,
})

TabCombat:Slider({
    Title = "Attack Speed (Hits/Sec)",
    Desc = "Respects server rate limiter (Max safe: 6)",
    Step = 1,
    Value = {Min = 1, Max = 6, Default = Config.AttackRate},
    Callback = function(v) Config.AttackRate = v end,
})

TabCombat:Toggle({
    Title = "Auto Face Target",
    Desc = "Directs character view towards the targeted enemy",
    Value = Config.AutoAim,
    Callback = function(v) Config.AutoAim = v end,
})

TabCombat:Dropdown({
    Title = "Targeting Priority",
    Desc = "Choose priority rule for targeting",
    Values = {"Nearest", "Lowest HP"},
    Value = Config.TargetMode,
    Callback = function(v) Config.TargetMode = v end,
})

TabCombat:Section({Title = "Smart Defense & Auto Parry"})

TabCombat:Toggle({
    Title = "Smart Auto Parry",
    Desc = "Calculates windup timestamps and pulses Block at safe timing",
    Value = Config.AutoParry,
    Callback = function(v) Config.AutoParry = v end,
})

TabCombat:Slider({
    Title = "Parry Distance",
    Desc = "Distance to detect enemy windups",
    Step = 1,
    Value = {Min = 5, Max = 25, Default = Config.ParryDistance},
    Callback = function(v) Config.ParryDistance = v end,
})

TabCombat:Slider({
    Title = "Perfect Parry Ratio %",
    Desc = "Evades server FlagPerfectRate 90% threshold (Keep under 85%)",
    Step = 5,
    Value = {Min = 50, Max = 85, Default = Config.ParryPerfectRatio},
    Callback = function(v) Config.ParryPerfectRatio = v end,
})

TabCombat:Toggle({
    Title = "Auto Dash Evade",
    Desc = "Executes dash backward upon enemy charge/windup",
    Value = Config.AutoDash,
    Callback = function(v) Config.AutoDash = v end,
})

-- TAB 2: TRAINING & PROGRESSION
local TabTrain = Window:Tab({Title = "Training", Icon = "dumbbell"})
TabTrain:Section({Title = "Gym Automation"})

TabTrain:Toggle({
    Title = "Auto Gym Train",
    Desc = "Auto claims station and executes barbell reps continuously",
    Value = Config.AutoGym,
    Callback = function(v) Config.AutoGym = v end,
})

local barbellOptions = {"Auto Nearest"}
for i = 1, 12 do table.insert(barbellOptions, "B" .. i) end

TabTrain:Dropdown({
    Title = "Select Barbell Station",
    Desc = "Target specific station or let script find nearest free one",
    Values = barbellOptions,
    Value = Config.SelectedBarbell,
    Callback = function(v) Config.SelectedBarbell = v end,
})

TabTrain:Slider({
    Title = "Rep Cadence (Delay)",
    Desc = "Seconds between reps (Safe: 0.35s)",
    Step = 0.05,
    Value = {Min = 0.25, Max = 1.0, Default = Config.GymRepDelay},
    Callback = function(v) Config.GymRepDelay = v end,
})

TabTrain:Toggle({
    Title = "Auto Rest At Cap",
    Desc = "Stops training when character hits max strength cap",
    Value = Config.AutoRestAtCap,
    Callback = function(v) Config.AutoRestAtCap = v end,
})

TabTrain:Section({Title = "Progression"})

TabTrain:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically triggers Rebirth when eligible",
    Value = Config.AutoRebirth,
    Callback = function(v) Config.AutoRebirth = v end,
})

TabTrain:Toggle({
    Title = "Auto Spend Skill Points",
    Desc = "Spends unallocated skill points automatically",
    Value = Config.AutoUpgradeSkills,
    Callback = function(v) Config.AutoUpgradeSkills = v end,
})

-- TAB 3: INVENTORY & CHESTS
local TabInventory = Window:Tab({Title = "Inventory", Icon = "package"})
TabInventory:Section({Title = "Chest Automation"})

TabInventory:Toggle({
    Title = "Auto Open Owned Chests",
    Desc = "Sequentially cracks open all owned inventory chests",
    Value = Config.AutoOpenChests,
    Callback = function(v) Config.AutoOpenChests = v end,
})

TabInventory:Button({
    Title = "Open All Chests Now",
    Desc = "One-click trigger to open all inventory chests",
    Callback = function()
        task.spawn(function()
            local state = ClientStateModule.get()
            local owned = state and state.OwnedChests or {}
            for id, tier in pairs(owned) do
                fireRemote("ChestOpen", tostring(id))
                task.wait(0.6)
            end
        end)
    end,
})

TabInventory:Toggle({
    Title = "Auto Buy Common Chests",
    Desc = "Purchases common chests whenever cash >= 250",
    Value = Config.AutoBuyCommon,
    Callback = function(v) Config.AutoBuyCommon = v end,
})

TabInventory:Toggle({
    Title = "Auto Buy Rare Chests",
    Desc = "Purchases rare chests whenever cash >= 750",
    Value = Config.AutoBuyRare,
    Callback = function(v) Config.AutoBuyRare = v end,
})

TabInventory:Section({Title = "World Interaction"})

TabInventory:Toggle({
    Title = "Instant Proximity Prompts",
    Desc = "Sets all interaction prompt hold times to 0 seconds",
    Value = Config.InstantPrompts,
    Callback = function(v) Config.InstantPrompts = v end,
})

TabInventory:Toggle({
    Title = "Auto Skip Boss Cutscenes",
    Desc = "Immediately bypasses boss entrance cinematics",
    Value = Config.AutoSkipCutscenes,
    Callback = function(v) Config.AutoSkipCutscenes = v end,
})

-- TAB 4: TELEPORTS
local TabTeleport = Window:Tab({Title = "Teleports", Icon = "map-pin"})
TabTeleport:Section({Title = "Fast Travel Stations (Server Validated)"})

local stations = {"Gym", "Shop", "Vault", "HallOfFame", "Gate", "Spectre", "Sparring", "Rebirth"}
for _, station in ipairs(stations) do
    TabTeleport:Button({
        Title = "Travel to " .. station,
        Desc = "Instantly teleports via TravelTo remote",
        Callback = function()
            fireRemote("TravelTo", station)
        end,
    })
end

TabTeleport:Section({Title = "Arena Coordinates"})
TabTeleport:Button({
    Title = "Teleport to Arena Center",
    Desc = "Physical CFrame teleport to arena combat floor",
    Callback = function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(0, 15, -150)
        end
    end,
})

-- TAB 5: MOVEMENT & VISUALS
local TabMoveVis = Window:Tab({Title = "Visuals & Movement", Icon = "eye"})
TabMoveVis:Section({Title = "Movement Mods"})

TabMoveVis:Toggle({
    Title = "WalkSpeed Modifier",
    Desc = "Overrides character movement speed",
    Value = Config.SpeedEnabled,
    Callback = function(v) Config.SpeedEnabled = v end,
})

TabMoveVis:Slider({
    Title = "Speed Value",
    Desc = "Custom movement speed (Default: 17)",
    Step = 1,
    Value = {Min = 17, Max = 80, Default = Config.SpeedValue},
    Callback = function(v) Config.SpeedValue = v end,
})

TabMoveVis:Toggle({
    Title = "JumpPower Modifier",
    Desc = "Overrides character jump height",
    Value = Config.JumpEnabled,
    Callback = function(v) Config.JumpEnabled = v end,
})

TabMoveVis:Slider({
    Title = "Jump Value",
    Desc = "Custom jump power (Default: 50)",
    Step = 1,
    Value = {Min = 50, Max = 150, Default = Config.JumpValue},
    Callback = function(v) Config.JumpValue = v end,
})

TabMoveVis:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in mid-air",
    Value = Config.InfiniteJump,
    Callback = function(v) Config.InfiniteJump = v end,
})

TabMoveVis:Toggle({
    Title = "Noclip",
    Desc = "Pass smoothly through walls and obstacles",
    Value = Config.Noclip,
    Callback = function(v) Config.Noclip = v end,
})

TabMoveVis:Section({Title = "Enemy ESP"})

TabMoveVis:Toggle({
    Title = "Enable Enemy ESP",
    Desc = "Renders visual indicators over all active enemies",
    Value = Config.EnemyESP,
    Callback = function(v) Config.EnemyESP = v end,
})

TabMoveVis:Toggle({
    Title = "Show Boxes",
    Desc = "Bounding 2D box around target",
    Value = Config.ESPBoxes,
    Callback = function(v) Config.ESPBoxes = v end,
})

TabMoveVis:Toggle({
    Title = "Show Name & Distance",
    Desc = "Entity tag and metric distance",
    Value = Config.ESPNames,
    Callback = function(v) Config.ESPNames = v end,
})

TabMoveVis:Toggle({
    Title = "Show Health",
    Desc = "Live HP values",
    Value = Config.ESPHealth,
    Callback = function(v) Config.ESPHealth = v end,
})

TabMoveVis:Toggle({
    Title = "Show AI State",
    Desc = "Real-time state tracking (Windup / Attack / Idle)",
    Value = Config.ESPState,
    Callback = function(v) Config.ESPState = v end,
})

-- TAB 6: CONFIG & SETTINGS
local TabConfig = Window:Tab({Title = "Config", Icon = "file-cog"})
TabConfig:Section({Title = "Configuration Management"})

local currentConfigName = "default"

TabConfig:Input({
    Title = "Profile Name",
    Desc = "Enter profile name to save or load",
    Value = "default",
    Callback = function(v) currentConfigName = v end,
})

TabConfig:Button({
    Title = "Save Config",
    Desc = "Saves current settings to disk",
    Callback = function()
        saveConfigFile(currentConfigName)
    end,
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Loads settings from disk profile",
    Callback = function()
        loadConfigFile(currentConfigName)
    end,
})

TabConfig:Button({
    Title = "Reset to Default (ALL OFF)",
    Desc = "Turns all automated features off immediately",
    Callback = function()
        for k, v in pairs(Config) do
            if typeof(v) == "boolean" and k ~= "FloatingButton" and k ~= "UIVisible" then
                Config[k] = false
            end
        end
        WindUI:Notify({
            Title = "Reset Complete",
            Content = "All features turned off.",
            Duration = 3,
            Icon = "shield-alert",
        })
    end,
})

TabConfig:Section({Title = "UI Controls"})

TabConfig:Toggle({
    Title = "Show Floating Action Button",
    Desc = "Toggles visibility of the screen floating button",
    Value = Config.FloatingButton,
    Callback = function(v)
        Config.FloatingButton = v
        floatingGui.Enabled = v
    end,
})

-- Initial Notification
WindUI:Notify({
    Title = "GloryBound Elite Active",
    Content = "Press LeftCTRL or tap floating button to Show/Hide.",
    Duration = 5,
    Icon = "swords",
})

print("[GloryBound Elite] Script initialized. Default state: ALL OFF.")
