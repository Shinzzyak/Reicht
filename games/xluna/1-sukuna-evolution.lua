-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    +1 SUKUNA EVOLUTION ELITE AUTOMATION SUITE
    Game: [âï¸W2] +1 Sukuna Evolution
    PlaceId: 76658223549414
    Engine: WindUI Universal Framework
    Standard: Default ALL OFF | English UI | LeftCTRL Toggle | Floating Button | Config Manager
]]

-- Environment & Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Resolve Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClickRemote = Remotes:WaitForChild("Click")
local AttackRemote = Remotes:WaitForChild("Attack")
local TechniqueRemote = Remotes:WaitForChild("Technique")
local RebirthRemote = Remotes:WaitForChild("Rebirth")
local GoStageRemote = Remotes:WaitForChild("GoStage")
local ClaimPadRemote = Remotes:WaitForChild("ClaimPad")
local HatchRemote = Remotes:WaitForChild("Hatch")
local FlameRemote = Remotes:WaitForChild("Flame")
local UnlockDomainRemote = Remotes:WaitForChild("UnlockDomain")
local EquipDomainRemote = Remotes:WaitForChild("EquipDomain")
local RewardsRemote = Remotes:WaitForChild("Rewards")
local MinigameRemote = Remotes:WaitForChild("Minigame")
local EnterWorldRemote = Remotes:WaitForChild("EnterWorld")

-- Shared Balance Data
local BalanceSuccess, Balance = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Balance"))
end)

-- Default Master Config (Strictly ALL OFF by Default)
local Config = {
    -- Auto Click & Energy
    AutoClick = false,
    ClickSpeed = 15, -- Clicks per second
    AutoRebirth = false,
    AutoClaimRewards = false,

    -- Combat & Stages
    AutoAttackM1 = false,
    M1Speed = 15, -- Shots per second (Up to 30 CPS)
    M1AimMode = "Auto Aim (Nearest Enemy)", -- "Auto Aim (Nearest Enemy)", "Camera Center"
    InstantKill = false,
    AutoStageFarm = false,
    SelectedWorld = 2, -- 1 = World 1 (Stages 1-15), 2 = World 2 (Stages 16-30)
    SelectedStage = 30,
    AutoStepWinpad = false,
    WinpadType = "PadWins", -- "PadWins", "PadX3", "Auto Best"
    Killaura = false,
    AttackRange = 50,

    -- Upgrades & Progression
    AutoUnlockDomains = false,
    AutoEquipBestDomain = false,
    AutoBuyFlames = false,
    AutoEquipBestFlame = false,
    AutoMinigameScores = false,

    -- Pets & Hatch
    AutoHatch = false,
    SelectedEgg = 1,
    AutoEquipBestPets = false,
    AutoMergePets = false,

    -- Raid & Finger Shop
    AutoJoinRaid = false,
    AutoAttackRaid = false,
    AutoBuyFingerItems = false,

    -- Season & Worlds
    AutoClaimSeason = false,

    -- Movement & Visuals
    SpeedEnabled = false,
    SpeedValue = 35,
    JumpEnabled = false,
    JumpValue = 50,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,

    EnemyESP = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPHealth = false,

    -- UI State
    FloatingButton = true,
    UIVisible = true,
}

_G.SukunaConfig = Config
if getgenv then getgenv().SukunaConfig = Config end

-- Load WindUI Framework
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[Sukuna Evolution] Failed to load WindUI from primary CDN")
    return
end

-- Clean up previous execution if re-injected
if _G.SukunaCleanup then
    pcall(_G.SukunaCleanup)
end

local isScriptActive = true
_G.SukunaCleanup = function()
    isScriptActive = false
    if _G.SukunaWindow then
        pcall(function() _G.SukunaWindow:Destroy() end)
        _G.SukunaWindow = nil
    end
end

-- Create Main Window
local Window = WindUI:CreateWindow({
    Title = "+1 Sukuna Evolution",
    Icon = "flame",
    Author = "System Architect",
    Folder = "SukunaEvolution",
    Size = UDim2.fromOffset(600, 490),
    Transparent = true,
    Theme = "Dark",
})

_G.SukunaWindow = Window

-- Configure Native WindUI Keybind for LeftControl
Window:SetToggleKey(Enum.KeyCode.LeftControl)

-- Master UI Visibility Toggle Function (Using Native Window:Toggle() with 0.25s Debounce)
local _lastToggleTick = 0
local function toggleUIVisibility()
    local now = os.clock()
    if now - _lastToggleTick < 0.25 then return end
    _lastToggleTick = now
    pcall(function()
        Window:Toggle()
    end)
end

-- Ensure no custom duplicate Keybind connection is running
if _G.SukunaKeybindConnection then
    pcall(function() _G.SukunaKeybindConnection:Disconnect() end)
    _G.SukunaKeybindConnection = nil
end

-- File Storage Helpers for Config
local FOLDER_NAME = "SukunaEvolution_Configs"
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
-- FLOATING ACTION BUTTON (Draggable ScreenGui)
-- ====================================================================
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Clean any existing duplicate floating buttons to prevent ghost clicks
local oldBtn = guiParent:FindFirstChild("Sukuna_FloatingButton")
if oldBtn then
    oldBtn:Destroy()
end

local floatingGui = Instance.new("ScreenGui")
floatingGui.Name = "Sukuna_FloatingButton"
floatingGui.ResetOnSpawn = false
floatingGui.DisplayOrder = 999999
floatingGui.Parent = guiParent

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "ToggleButton"
floatBtn.Size = UDim2.fromOffset(48, 48)
floatBtn.Position = UDim2.new(0.04, 0, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
floatBtn.BackgroundTransparency = 0.1
floatBtn.AutoButtonColor = true
floatBtn.ZIndex = 999
floatBtn.Parent = floatingGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = floatBtn

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 60, 90)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = floatBtn

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.fromOffset(28, 28)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.fromScale(0.5, 0.5)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10709791437"
icon.ImageColor3 = Color3.fromRGB(255, 140, 170)
icon.ZIndex = 1000
icon.Parent = floatBtn

local isDragging = false
local dragStart = nil
local startPos = nil
local moved = false

floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        moved = false
        dragStart = input.Position
        startPos = floatBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 8 then
            moved = true
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        isDragging = false
        if dragStart and (input.Position - dragStart).Magnitude < 10 then
            toggleUIVisibility()
        end
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    toggleUIVisibility()
end)

floatBtn.TouchTap:Connect(function()
    toggleUIVisibility()
end)

-- ====================================================================
-- CORE AUTOMATION LOOPS
-- ====================================================================

-- 1. OP Auto Clicker
task.spawn(function()
    while isScriptActive do
        if Config.AutoClick then
            local delay = 1 / math.clamp(Config.ClickSpeed, 1, 30)
            ClickRemote:FireServer()
            task.wait(delay)
        else
            task.wait(0.2)
        end
    end
end)

-- 2. Auto Rebirth
task.spawn(function()
    while isScriptActive do
        task.wait(1.5)
        if Config.AutoRebirth then
            local level = LocalPlayer:GetAttribute("Level") or 0
            local req = LocalPlayer:GetAttribute("RebirthLevel") or math.huge
            if level >= req then
                RebirthRemote:FireServer()
                WindUI:Notify({
                    Title = "Rebirth Triggered",
                    Content = "Level " .. level .. " reached Rebirth target.",
                    Duration = 3,
                    Icon = "rotate-cw",
                })
            end
        end
    end
end)

-- 3. Auto Claim Daily & Playtime Rewards
task.spawn(function()
    while isScriptActive do
        task.wait(10)
        if Config.AutoClaimRewards then
            RewardsRemote:FireServer("daily")
            for i = 1, 12 do
                RewardsRemote:FireServer("gift", i)
            end
            RewardsRemote:FireServer("group")
        end
    end
end)

-- ====================================================================
-- COMBAT & STAGE ENGINE (TOTAL RECONSTRUCTION)
-- ====================================================================

-- 1. Deterministic Geometry & Stage Map (All 30 Stages)
local function isCheckpointStage(stage)
    return stage == 1 or stage == 5 or stage == 10 or stage == 15 or stage == 16 or stage == 20 or stage == 25 or stage == 30
end

local function getStageEntrance(stage)
    stage = math.clamp(stage, 1, 30)
    if stage <= 15 then
        return Vector3.new(0, 3.5, -196 - (stage - 1) * 108)
    else
        return Vector3.new(0, 3.5, -2146 - (stage - 16) * 108)
    end
end

local function getStagePadPosition(stage, padType)
    stage = math.clamp(stage, 1, 30)
    local entranceZ = if stage <= 15 then (-196 - (stage - 1) * 108) else (-2146 - (stage - 16) * 108)
    local z = entranceZ - 88
    local prefersX3 = (padType == "PadX3") or (padType == "Auto Best" and LocalPlayer:GetAttribute("X3Wins") == true)
    local x = prefersX3 and -14 or 14
    return Vector3.new(x, 1.5, z)
end

local function getStageFromZ(z, world)
    world = world or (LocalPlayer:GetAttribute("World") or 1)
    if world == 1 then
        if z > -180 then return 0 end
        return math.clamp(math.floor((-z - 190) / 108) + 1, 1, 15)
    else
        if z > -2100 and z < -1950 then return 0 end
        return math.clamp(math.floor((-z - 2140) / 108) + 16, 16, 30)
    end
end

-- 2. Stage State Tracking & Client Events
local isStageCleared = false
local currentActiveStage = 1

Remotes.Notify.OnClientEvent:Connect(function(event, data)
    if event == "RunStart" then
        isStageCleared = false
        if type(data) == "table" and data.stage then
            currentActiveStage = data.stage
        end
    elseif event == "Cleared" then
        isStageCleared = true
        if type(data) == "number" then
            currentActiveStage = data
        end
    elseif event == "Died" then
        isStageCleared = false
        -- Auto Revive safety net
        pcall(function()
            Remotes.Revive:FireServer("Revive")
        end)
    elseif event == "PadWins" or event == "RunEnd" then
        isStageCleared = false
    end
end)

-- Hub position watchdog: reset cleared flag if player is at Hub
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local z = root.Position.Z
        if z > -180 or (z > -2150 and z < -1950) then
            if not LocalPlayer:GetAttribute("InRun") then
                isStageCleared = false
            end
        end
    end
end)

-- 3. Enemy Discovery & Combat Internals Access
local function getSpawnedEnemies()
    local enemies = {}
    local myEnemies = workspace:FindFirstChild("MyEnemies")
    if myEnemies then
        for _, model in ipairs(myEnemies:GetChildren()) do
            if model:IsA("Model") then
                table.insert(enemies, model)
            end
        end
    end
    return enemies
end

local cachedCombatHeartbeatFn = nil
local cachedCheckPadsFn = nil
local function resolveCombatInternals()
    local combatScript = LocalPlayer.PlayerScripts:FindFirstChild("Combat")
    if not combatScript then return nil end

    if not (cachedCombatHeartbeatFn and cachedCheckPadsFn) then
        local conns = getconnections(RunService.Heartbeat)
        for _, c in ipairs(conns) do
            local fn = c.Function
            if fn and islclosure(fn) and getfenv(fn).script == combatScript then
                local upvals = getupvalues(fn)
                if #upvals == 12 and typeof(upvals[9]) == "RaycastParams" and typeof(upvals[2]) == "Instance" and upvals[2] == LocalPlayer then
                    cachedCombatHeartbeatFn = fn
                    cachedCheckPadsFn = upvals[4]
                    break
                end
            end
        end
    end

    if cachedCombatHeartbeatFn and cachedCheckPadsFn then
        local hbUpvals = getupvalues(cachedCombatHeartbeatFn)
        local cpUpvals = getupvalues(cachedCheckPadsFn)
        return {
            enemyMap = hbUpvals[5],
            stageState = cpUpvals[1],
            padMap = cpUpvals[2]
        }
    end
    return nil
end

local function isCurrentStageCleared(stageNum)
    -- A stage with living enemies or bosses in workspace.MyEnemies can NEVER be cleared!
    local me = workspace:FindFirstChild("MyEnemies")
    if me and #me:GetChildren() > 0 then
        return false
    end
    if isStageCleared then return true end
    local internals = resolveCombatInternals()
    if internals and internals.stageState and internals.stageState.cleared == true then
        return true
    end
    -- Normal mobs stage (Stages 1..29): if enemies spawned and reached 0, it's cleared!
    if stageNum and stageNum < 30 and me and #me:GetChildren() == 0 then
        return true
    end
    return false
end

local function getAliveEnemyIds()
    local ids = {}
    local internals = resolveCombatInternals()
    if internals and internals.enemyMap then
        for id, data in pairs(internals.enemyMap) do
            if data.hp and data.hp > 0 then
                table.insert(ids, id)
            end
        end
    end
    if #ids == 0 then
        local spawned = getSpawnedEnemies()
        if #spawned > 0 then
            for i = 1, math.max(#spawned + 5, 12) do
                table.insert(ids, i)
            end
        end
    end
    if #ids == 0 then
        ids = {-1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
    end
    return ids
end

local function getActivePad(stage, padType)
    padType = tostring(padType or "PadWins")
    local prefersX3 = (string.find(padType, "PadX3") ~= nil) or (string.find(padType, "Auto Best") ~= nil and LocalPlayer:GetAttribute("X3Wins") == true)
    local padName = prefersX3 and "PadX3" or "PadWins"
    local padX = prefersX3 and -14 or 14

    stage = math.clamp(stage, 1, 30)
    local entranceZ = if stage <= 15 then (-196 - (stage - 1) * 108) else (-2146 - (stage - 16) * 108)
    local padZ = entranceZ - 88

    -- 1. Try to find the exact pad part from this stage's model if streamed in
    local sStr = string.format("Stage%02d", stage)
    local map = workspace:FindFirstChild("Map")
    local stages = map and map:FindFirstChild("Stages")
    local stageModel = stages and stages:FindFirstChild(sStr)
    local pads = stageModel and stageModel:FindFirstChild("Pads")
    if pads then
        local target = pads:FindFirstChild(padName, true)
        if target and target:IsA("BasePart") then
            return Vector3.new(target.Position.X, 3.6, target.Position.Z), target, padName
        end
    end

    -- 2. Return deterministic exact mathematical coordinate (standing surface height Y = 3.6)
    return Vector3.new(padX, 3.6, padZ), nil, padName
end

local cachedShootFn = nil
local function getShootFunction()
    if cachedShootFn then return cachedShootFn end
    local combatScript = LocalPlayer.PlayerScripts:FindFirstChild("Combat")
    if not combatScript then return nil end
    for _, fn in ipairs(getgc(false)) do
        if type(fn) == "function" and islclosure(fn) and getfenv(fn).script == combatScript then
            local info = debug.getinfo(fn)
            if info.name == "shoot" then
                cachedShootFn = fn
                return cachedShootFn
            end
        end
    end
    return nil
end

local function executeInstantKill()
    local targets = getAliveEnemyIds()
    if #targets > 0 then
        -- 1. Native Aim-Shoot Projectile directly at closest enemy
        local shoot = getShootFunction()
        if shoot then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local me = workspace:FindFirstChild("MyEnemies")
                local first = me and me:GetChildren()[1]
                local targetPart = first and (first:FindFirstChild("Root") or first.PrimaryPart or first:FindFirstChildWhichIsA("BasePart"))
                if targetPart then
                    local origin = myRoot.Position + Vector3.new(0, 1.5, 0)
                    local dir = (targetPart.Position - origin).Unit
                    pcall(shoot, { ray = Ray.new(origin, dir), locked = true })
                else
                    pcall(shoot)
                end
            end
        end

        -- 2. Direct Full M1 Remote Strike (without true for unmitigated direct damage)
        AttackRemote:FireServer(targets)

        -- 3. Secondary DoT Burn Remote Strike
        AttackRemote:FireServer(targets, true)

        -- 4. Malevolent Shrine & Jujutsu Techniques
        TechniqueRemote:FireServer("Q")
        TechniqueRemote:FireServer("E", targets)
        TechniqueRemote:FireServer("R", targets)
    end
end

-- 4. Master Auto Stage Farm Engine (Full Progression Run: Start -> Target Stage -> Winpad -> Loop)
local isFarmingActive = false
task.spawn(function()
    while isScriptActive do
        task.wait(0.1)
        if Config.AutoStageFarm and not isFarmingActive then
            isFarmingActive = true
            pcall(function()
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                if not (myRoot and hum) then return end

                -- A. Revive check if died
                if hum.Health <= 0 then
                    Remotes.Revive:FireServer()
                    task.wait(1.0)
                    return
                end

                -- B. Determine World & Target Stage bounds
                local targetStage = Config.SelectedStage or 1
                local worldOfTarget = (targetStage > 15) and 2 or 1
                if Config.SelectedWorld then
                    worldOfTarget = Config.SelectedWorld
                end

                local startStage = (worldOfTarget == 2) and 16 or 1
                local maxWorldStage = (worldOfTarget == 2) and 30 or 15
                targetStage = math.clamp(targetStage, startStage, maxWorldStage)

                -- C. World synchronization
                local curWorld = LocalPlayer:GetAttribute("World") or 1
                if curWorld ~= worldOfTarget then
                    EnterWorldRemote:FireServer(worldOfTarget)
                    local tW = os.clock()
                    while os.clock() - tW < 2.5 and (LocalPlayer:GetAttribute("World") or 1) ~= worldOfTarget and Config.AutoStageFarm do
                        task.wait(0.1)
                    end
                    task.wait(0.4)
                    return
                end

                -- D. Determine Loop bounds (Always start at World first stage up to Target Stage!)
                local currentPhysStage = getStageFromZ(myRoot.Position.Z, curWorld)
                local startLoopStage = startStage

                -- If player is already mid-run inside this world between startStage and targetStage:
                if LocalPlayer:GetAttribute("InRun") == true and currentPhysStage >= startStage and currentPhysStage <= targetStage then
                    startLoopStage = currentPhysStage
                end
                local endLoopStage = targetStage

                -- E. STAGE FARM EXECUTION (Sequential Progression: Stage 1/16 -> Target Stage)
                for stage = startLoopStage, endLoopStage do
                    if not Config.AutoStageFarm then break end

                    myChar = LocalPlayer.Character
                    myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if not (myRoot and hum) then break end

                    if hum.Health <= 0 then
                        Remotes.Revive:FireServer()
                        task.wait(0.8)
                    end

                    -- Enter Stage Entrance:
                    if stage == startLoopStage and not (LocalPlayer:GetAttribute("InRun") == true and currentPhysStage == stage) then
                        if isCheckpointStage(stage) then
                            GoStageRemote:FireServer(stage)
                        end
                        local entrance = getStageEntrance(stage)
                        myRoot.CFrame = CFrame.new(entrance)
                        task.wait(0.6)
                    elseif stage > startLoopStage then
                        -- Advance smoothly through corridor (X = 0) past the stage barrier
                        local entrance = getStageEntrance(stage)
                        local curZ = myRoot.Position.Z
                        local padZ = entrance.Z
                        local stepDir = (padZ < curZ) and -20 or 20
                        local z = curZ
                        while (stepDir < 0 and z > padZ + 18) or (stepDir > 0 and z < padZ - 18) do
                            if not Config.AutoStageFarm then break end
                            z = z + stepDir
                            myRoot.CFrame = CFrame.new(0, 3.13, z)
                            task.wait(0.04)
                        end
                        myRoot.CFrame = CFrame.new(0, 3.13, padZ)
                        if isCheckpointStage(stage) then
                            GoStageRemote:FireServer(stage)
                        end
                        task.wait(0.3)
                    end

                    -- Wait for run registration & enemies to spawn
                    local tEnter = os.clock()
                    local me = workspace:FindFirstChild("MyEnemies")
                    while os.clock() - tEnter < 1.5 and Config.AutoStageFarm do
                        if (me and #me:GetChildren() > 0) or LocalPlayer:GetAttribute("InRun") then
                            break
                        end
                        task.wait(0.08)
                    end
                    task.wait(0.1)

                    -- Reset cleared status for this stage
                    isStageCleared = false

                    -- Extermination Phase (Keep attacking until SERVER confirms Cleared!)
                    -- For heavy boss stages (Stage 30 Muzan, 26 Akaza, 21 Enmu), hover at Y = 25 for complete immunity against melee & whip damage!
                    local tCombat = os.clock()
                    while not isCurrentStageCleared(stage) and Config.AutoStageFarm do
                        if stage == 30 or stage == 26 or stage == 21 then
                            myRoot.CFrame = CFrame.new(myRoot.Position.X, 25, myRoot.Position.Z)
                            myRoot.Velocity = Vector3.new()
                        end

                        executeInstantKill()
                        task.wait(0.08)

                        if hum.Health <= 0 then
                            Remotes.Revive:FireServer("Revive")
                            task.wait(0.5)
                        end

                        -- Safety timeout: 45 seconds for high-phase bosses like Muzan
                        if os.clock() - tCombat > 45 then
                            break
                        end
                    end

                    -- IF NOT CLEARED, DO NOT STEP ON WINPAD!
                    if not isCurrentStageCleared(stage) or not Config.AutoStageFarm then break end

                    -- Descend to normal standing height if hovering
                    if myRoot.Position.Y > 6 then
                        myRoot.CFrame = CFrame.new(myRoot.Position.X, 3.6, myRoot.Position.Z)
                        task.wait(0.1)
                    end

                    -- Check if Target Stage is reached:
                    if stage < targetStage then
                        -- Intermediate stage: DO NOT STEP ON WINPAD! Advance to next stage!
                        task.wait(0.15)
                    else
                        -- TARGET STAGE REACHED! Step smoothly to chosen Winpad
                        local padPos, padPart, padName = getActivePad(stage, Config.WinpadType)

                        -- 1. Step smoothly along Z towards the pad in increments of max 20 studs
                        local curZ = myRoot.Position.Z
                        local padZ = padPos.Z
                        local stepDir = (padZ < curZ) and -20 or 20
                        local z = curZ
                        while (stepDir < 0 and z > padZ + 18) or (stepDir > 0 and z < padZ - 18) do
                            if not Config.AutoStageFarm then break end
                            z = z + stepDir
                            myRoot.CFrame = CFrame.new(0, 3.13, z)
                            task.wait(0.04)
                        end

                        -- 2. Step directly onto chosen Winpad surface at standing height Y = 3.6
                        myRoot.CFrame = CFrame.new(padPos.X, 3.6, padZ)

                        -- 3. Always overwrite internal padMap with the current stage's active pad part!
                        local internals = resolveCombatInternals()
                        if internals and internals.padMap then
                            local partToInject = padPart
                            if not partToInject then
                                local sStr = string.format("Stage%02d", stage)
                                local map = workspace:FindFirstChild("Map")
                                local stages = map and map:FindFirstChild("Stages")
                                local stageModel = stages and stages:FindFirstChild(sStr)
                                local pads = stageModel and stageModel:FindFirstChild("Pads")
                                partToInject = pads and pads:FindFirstChild(padName, true)
                            end
                            if partToInject then
                                internals.padMap[padName] = partToInject
                            end
                        end

                        -- 4. Hold position firmly on the pad for 1.2s and dispatch ClaimPad confirmation
                        local tPad = os.clock()
                        while os.clock() - tPad < 1.2 and Config.AutoStageFarm do
                            myRoot.CFrame = CFrame.new(padPos.X, 3.6, padZ)
                            myRoot.Velocity = Vector3.new()
                            ClaimPadRemote:FireServer(padName)
                            task.wait(0.15)
                        end

                        -- 5. Await server / game teleporting player back to Hub
                        local tHub = os.clock()
                        while os.clock() - tHub < 4.0 and Config.AutoStageFarm do
                            task.wait(0.1)
                            ClaimPadRemote:FireServer(padName)
                            local pz = myRoot.Position.Z
                            if pz > -180 or (pz > -2150 and pz < -1950) or not LocalPlayer:GetAttribute("InRun") then
                                break
                            end
                        end
                        task.wait(0.6)
                    end
                end
            end)
            isFarmingActive = false
        end
    end
end)

-- 4.5. Standalone Auto Attack M1 (Fast Aim Shooting)
task.spawn(function()
    while isScriptActive do
        if Config.AutoAttackM1 and not Config.AutoStageFarm then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local shoot = getShootFunction()
                local me = workspace:FindFirstChild("MyEnemies")
                local count = me and #me:GetChildren() or 0

                if count > 0 then
                    local first = me:GetChildren()[1]
                    local targetPart = first and (first:FindFirstChild("Root") or first.PrimaryPart or first:FindFirstChildWhichIsA("BasePart"))
                    if targetPart and Config.M1AimMode == "Auto Aim (Nearest Enemy)" then
                        local origin = myRoot.Position + Vector3.new(0, 1.5, 0)
                        local dir = (targetPart.Position - origin).Unit
                        if shoot then
                            pcall(shoot, { ray = Ray.new(origin, dir), locked = true })
                        end
                    elseif shoot then
                        pcall(shoot)
                    end

                    local targets = {}
                    for i = 1, math.max(count + 2, 8) do
                        table.insert(targets, i)
                    end
                    table.insert(targets, -1)
                    AttackRemote:FireServer(targets)
                elseif shoot then
                    pcall(shoot)
                end
            end
            local delay = 1 / math.clamp(Config.M1Speed or 15, 5, 30)
            task.wait(delay)
        else
            task.wait(0.2)
        end
    end
end)

-- 5. Standalone Instant Kill Loop
task.spawn(function()
    while isScriptActive do
        task.wait(0.08)
        if Config.InstantKill and not Config.AutoStageFarm then
            local me = workspace:FindFirstChild("MyEnemies")
            if me and #me:GetChildren() > 0 then
                executeInstantKill()
            end
        end
    end
end)

-- 6. Standalone Auto Step Winpad (For Manual Play)
local hasEnemiesSpawned = false
task.spawn(function()
    while isScriptActive do
        task.wait(0.12)
        if Config.AutoStepWinpad and not Config.AutoStageFarm then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local inRun = LocalPlayer:GetAttribute("InRun") == true
                if inRun then
                    local curWorld = LocalPlayer:GetAttribute("World") or 1
                    local activeStage = getStageFromZ(myRoot.Position.Z, curWorld)
                    if activeStage == 0 then
                        activeStage = currentActiveStage or 1
                    end

                    local me = workspace:FindFirstChild("MyEnemies")
                    local enemyCount = me and #me:GetChildren() or 0
                    if enemyCount > 0 then
                        hasEnemiesSpawned = true
                    end

                    if (hasEnemiesSpawned and enemyCount == 0) or isCurrentStageCleared(activeStage) then
                        local padPos, padPart, padName = getActivePad(activeStage, Config.WinpadType)

                        if (padPos - myRoot.Position).Magnitude > 4 then
                            local curZ = myRoot.Position.Z
                            local padZ = padPos.Z
                            local stepDir = (padZ < curZ) and -20 or 20
                            local z = curZ
                            while (stepDir < 0 and z > padZ + 18) or (stepDir > 0 and z < padZ - 18) do
                                z = z + stepDir
                                myRoot.CFrame = CFrame.new(0, 3.13, z)
                                task.wait(0.04)
                            end
                            myRoot.CFrame = CFrame.new(padPos.X, 3.6, padZ)

                            local internals = resolveCombatInternals()
                            if internals and internals.padMap then
                                local partToInject = padPart
                                if not partToInject then
                                    local sStr = string.format("Stage%02d", activeStage)
                                    local map = workspace:FindFirstChild("Map")
                                    local stages = map and map:FindFirstChild("Stages")
                                    local stageModel = stages and stages:FindFirstChild(sStr)
                                    local pads = stageModel and stageModel:FindFirstChild("Pads")
                                    partToInject = pads and pads:FindFirstChild(padName, true)
                                end
                                if partToInject then
                                    internals.padMap[padName] = partToInject
                                end
                            end

                            -- Hold position on the pad for 1.2s and dispatch claim
                            local tPad = os.clock()
                            while os.clock() - tPad < 1.2 do
                                myRoot.CFrame = CFrame.new(padPos.X, 3.6, padZ)
                                myRoot.Velocity = Vector3.new()
                                ClaimPadRemote:FireServer(padName)
                                task.wait(0.15)
                            end
                            hasEnemiesSpawned = false
                        end
                    end
                else
                    hasEnemiesSpawned = false
                end
            end
        end
    end
end)

-- 7. Killaura Proximity
task.spawn(function()
    while isScriptActive do
        task.wait(0.08)
        if Config.Killaura and not Config.InstantKill and not Config.AutoStageFarm then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local enemies = getSpawnedEnemies()
                local targets = {}
                for idx, enemy in ipairs(enemies) do
                    local root = enemy:FindFirstChild("Root") or enemy.PrimaryPart or enemy:FindFirstChildWhichIsA("BasePart")
                    if root and (root.Position - myRoot.Position).Magnitude <= Config.AttackRange then
                        table.insert(targets, idx)
                    end
                end
                if #targets > 0 then
                    local shoot = getShootFunction()
                    if shoot then
                        local targetPart = enemies[1] and (enemies[1]:FindFirstChild("Root") or enemies[1].PrimaryPart or enemies[1]:FindFirstChildWhichIsA("BasePart"))
                        if targetPart then
                            local origin = myRoot.Position + Vector3.new(0, 1.5, 0)
                            local dir = (targetPart.Position - origin).Unit
                            pcall(shoot, { ray = Ray.new(origin, dir), locked = true })
                        else
                            pcall(shoot)
                        end
                    end
                    AttackRemote:FireServer(targets)
                    AttackRemote:FireServer(targets, true)
                    TechniqueRemote:FireServer("Q")
                    TechniqueRemote:FireServer("E", targets)
                    TechniqueRemote:FireServer("R", targets)
                end
            end
        end
    end
end)

-- 6. Auto Unlock & Equip Domains
task.spawn(function()
    while isScriptActive do
        task.wait(3)
        if Config.AutoUnlockDomains and BalanceSuccess and Balance and Balance.domains then
            local currentOwned = LocalPlayer:GetAttribute("DomainsOwned") or 1
            local wins = LocalPlayer:GetAttribute("Wins") or 0
            local nextDomain = currentOwned + 1
            local cfg = Balance.domains[nextDomain]
            if cfg and cfg.need and wins >= cfg.need then
                UnlockDomainRemote:FireServer(nextDomain)
            end
        end
        if Config.AutoEquipBestDomain then
            local currentOwned = LocalPlayer:GetAttribute("DomainsOwned") or 1
            local equipped = LocalPlayer:GetAttribute("Domain") or 1
            if equipped < currentOwned then
                EquipDomainRemote:FireServer(currentOwned)
            end
        end
    end
end)

-- 7. Auto Buy & Equip Flames
task.spawn(function()
    while isScriptActive do
        task.wait(3)
        if Config.AutoBuyFlames and BalanceSuccess and Balance and Balance.flames then
            local currentOwned = LocalPlayer:GetAttribute("FlamesOwned") or 1
            local wins = LocalPlayer:GetAttribute("Wins") or 0
            local nextFlame = currentOwned + 1
            local cfg = Balance.flames[nextFlame]
            if cfg and (cfg.need or cfg.cost) and wins >= (cfg.need or cfg.cost) then
                FlameRemote:FireServer("buy", nextFlame)
            end
        end
        if Config.AutoEquipBestFlame then
            local currentOwned = LocalPlayer:GetAttribute("FlamesOwned") or 1
            FlameRemote:FireServer("equip", currentOwned)
        end
    end
end)

-- 8. Auto Hatch Pets
task.spawn(function()
    while isScriptActive do
        if Config.AutoHatch then
            HatchRemote:FireServer(Config.SelectedEgg, 1, false, 0)
            task.wait(0.35)
        else
            task.wait(0.5)
        end
    end
end)

-- 9. Auto Minigames Max Scores
task.spawn(function()
    while isScriptActive do
        task.wait(15)
        if Config.AutoMinigameScores then
            MinigameRemote:FireServer("snake", 500)
            MinigameRemote:FireServer("blocks", 500)
        end
    end
end)

-- 10. Auto Pets Management (Equip Best & Merge All)
task.spawn(function()
    while isScriptActive do
        task.wait(4)
        if Config.AutoEquipBestPets then
            pcall(function()
                Remotes.PetAction:FireServer("best")
            end)
        end
        if Config.AutoMergePets then
            pcall(function()
                Remotes.PetAction:FireServer("mergeall")
            end)
        end
    end
end)

-- 11. Auto Raid Boss & Finger Shop
task.spawn(function()
    while isScriptActive do
        task.wait(1.5)
        local raidState = ReplicatedStorage:FindFirstChild("RaidState")
        local isRaidActive = raidState and raidState:GetAttribute("Active") == true

        if Config.AutoJoinRaid and isRaidActive then
            local inRun = LocalPlayer:GetAttribute("InRun")
            if not inRun then
                Remotes.Raid:FireServer("go")
                task.wait(2)
            end
        end

        if Config.AutoAttackRaid and isRaidActive then
            -- Raid boss target ID is -1
            AttackRemote:FireServer({-1})
            AttackRemote:FireServer({-1}, true)
            TechniqueRemote:FireServer("E", {-1})
            TechniqueRemote:FireServer("R", {-1})
        end

        if Config.AutoBuyFingerItems and BalanceSuccess and Balance and Balance.fingerShop then
            local tokens = LocalPlayer:GetAttribute("Fingers") or 0
            for i, item in ipairs(Balance.fingerShop) do
                if item.price and tokens >= item.price then
                    Remotes.Raid:FireServer("buy", i)
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- 12. Auto Season Pass Claim
task.spawn(function()
    while isScriptActive do
        task.wait(12)
        if Config.AutoClaimSeason then
            pcall(function()
                Remotes.Season:FireServer("claimAll")
            end)
        end
    end
end)

-- ====================================================================
-- MOVEMENT ENGINE
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
-- ANTI-AFK / ANTI-IDLE ENGINE
-- ====================================================================
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while isScriptActive do
        task.wait(120) -- Every 2 minutes
        if Config.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ====================================================================
-- VISUALS & ESP ENGINE
-- ====================================================================
local espDrawings = {}

local function createESPBox()
    return {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
    }
end

RunService.RenderStepped:Connect(function()
    if not Config.EnemyESP then
        for _, esp in pairs(espDrawings) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
        end
        return
    end

    local enemies = getSpawnedEnemies()
    local currentIds = {}

    for _, enemy in ipairs(enemies) do
        local root = enemy:FindFirstChild("Root") or enemy:FindFirstChildWhichIsA("BasePart")
        if root then
            local id = enemy:GetDebugId()
            currentIds[id] = true

            if not espDrawings[id] then
                espDrawings[id] = createESPBox()
            end

            local esp = espDrawings[id]
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local boxHeight = math.clamp(1400 / dist, 18, 200)
                local boxWidth = boxHeight * 0.7

                -- Box
                esp.Box.Visible = Config.ESPBoxes
                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box.Position = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)
                esp.Box.Color = Color3.fromRGB(255, 60, 90)
                esp.Box.Thickness = 1.5

                -- Name & Distance
                esp.Name.Visible = Config.ESPNames
                esp.Name.Text = enemy.Name .. " [" .. math.floor(dist) .. "m]"
                esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight / 2 - 16)
                esp.Name.Size = 13
                esp.Name.Center = true
                esp.Name.Outline = true
                esp.Name.Color = Color3.fromRGB(255, 255, 255)

                -- Health Indicator
                esp.Health.Visible = Config.ESPHealth
                esp.Health.Text = "Target Active"
                esp.Health.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight / 2 + 2)
                esp.Health.Size = 11
                esp.Health.Center = true
                esp.Health.Outline = true
                esp.Health.Color = Color3.fromRGB(100, 255, 120)
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
            end
        end
    end

    for id, esp in pairs(espDrawings) do
        if not currentIds[id] then
            esp.Box:Remove()
            esp.Name:Remove()
            esp.Health:Remove()
            espDrawings[id] = nil
        end
    end
end)

-- ====================================================================
-- INTERFACE CONSTRUCTION (WindUI Tabs)
-- ====================================================================

-- TAB 1: ENERGY & FARM
local TabFarm = Window:Tab({Title = "Energy & Farm", Icon = "zap"})
TabFarm:Section({Title = "Cursed Energy Farming"})

TabFarm:Toggle({
    Title = "OP Auto Clicker",
    Desc = "Rapidly pulses Click remote to farm Cursed Energy",
    Value = Config.AutoClick,
    Callback = function(v) Config.AutoClick = v end,
})

TabFarm:Slider({
    Title = "Click Speed (CPS)",
    Desc = "Clicks per second rate (Up to 30 CPS)",
    Step = 1,
    Value = {Min = 5, Max = 30, Default = Config.ClickSpeed},
    Callback = function(v) Config.ClickSpeed = v end,
})

TabFarm:Toggle({
    Title = "Auto Rebirth",
    Desc = "Triggers Rebirth automatically once Level target reached",
    Value = Config.AutoRebirth,
    Callback = function(v) Config.AutoRebirth = v end,
})

TabFarm:Toggle({
    Title = "Auto Claim All Rewards",
    Desc = "Claims Daily gifts, Playtime rewards, and Group rewards",
    Value = Config.AutoClaimRewards,
    Callback = function(v) Config.AutoClaimRewards = v end,
})

TabFarm:Button({
    Title = "Redeem Working Codes",
    Desc = "Instantly claims SUKUNA, KINGOFCURSES, and SORRY",
    Callback = function()
        RewardsRemote:FireServer("code", "SUKUNA")
        task.wait(0.3)
        RewardsRemote:FireServer("code", "KINGOFCURSES")
        task.wait(0.3)
        RewardsRemote:FireServer("code", "SORRY")
        WindUI:Notify({
            Title = "Codes Redeemed",
            Content = "All promo codes dispatched.",
            Duration = 3,
            Icon = "gift",
        })
    end,
})

-- TAB 2: COMBAT & STAGES
local TabCombat = Window:Tab({Title = "Combat & Stages", Icon = "swords"})
TabCombat:Section({Title = "Fast M1 Attack & Aim Shoot"})

TabCombat:Toggle({
    Title = "Auto Attack M1",
    Desc = "Continuously shoots M1 at curses and bosses with high CPS auto-aim",
    Value = Config.AutoAttackM1,
    Callback = function(v) Config.AutoAttackM1 = v end,
})

TabCombat:Slider({
    Title = "M1 Attack Speed (CPS)",
    Desc = "Shots per second rate (Up to 30 CPS)",
    Step = 1,
    Value = {Min = 5, Max = 30, Default = Config.M1Speed},
    Callback = function(v) Config.M1Speed = v end,
})

TabCombat:Dropdown({
    Title = "M1 Aim Target Mode",
    Desc = "Lock-on to closest enemy head/root or shoot toward camera crosshair",
    Values = {"Auto Aim (Nearest Enemy)", "Camera Center"},
    Value = Config.M1AimMode,
    Callback = function(v) Config.M1AimMode = v end,
})

TabCombat:Section({Title = "Instant Kill Burst"})

TabCombat:Toggle({
    Title = "Instant Kill (All Mobs)",
    Desc = "Obliterates all stage curses and bosses in milliseconds using Full Technique Burst",
    Value = Config.InstantKill,
    Callback = function(v) Config.InstantKill = v end,
})

TabCombat:Section({Title = "Automated Stage Farm Engine"})

TabCombat:Toggle({
    Title = "Auto Stage Farm",
    Desc = "Progression Farm: Starts at Stage 1/16 -> Clears all waves sequentially -> Claims Winpad at Target Stage -> Loops",
    Value = Config.AutoStageFarm,
    Callback = function(v) Config.AutoStageFarm = v end,
})

local w1Stages = {}
for i = 1, 15 do table.insert(w1Stages, "Stage " .. i) end

local w2Stages = {}
for i = 16, 30 do table.insert(w2Stages, "Stage " .. i) end

local targetStageDropdown = nil

local curWorld = LocalPlayer:GetAttribute("World") or 2
local defaultWorldStr = curWorld == 1 and "World 1 (Stages 1-15)" or "World 2 (Stages 16-30)"

TabCombat:Dropdown({
    Title = "Select World",
    Desc = "Choose World 1 (Stages 1-15) or World 2 (Stages 16-30)",
    Values = {"World 1 (Stages 1-15)", "World 2 (Stages 16-30)"},
    Value = defaultWorldStr,
    Callback = function(v)
        local w = string.find(v, "World 1") and 1 or 2
        Config.SelectedWorld = w
        local list = (w == 1) and w1Stages or w2Stages
        local defStage = (w == 1) and 1 or 16
        Config.SelectedStage = defStage
        if targetStageDropdown then
            targetStageDropdown:Refresh(list)
            targetStageDropdown:Select("Stage " .. defStage)
        end
    end,
})

local initialStageList = (Config.SelectedWorld == 1) and w1Stages or w2Stages
local initialStageVal = "Stage " .. Config.SelectedStage

targetStageDropdown = TabCombat:Dropdown({
    Title = "Select Stage",
    Desc = "Target stage to farm and claim Winpad",
    Values = initialStageList,
    Value = initialStageVal,
    Callback = function(v)
        local num = tonumber(string.match(v, "%d+"))
        if num then Config.SelectedStage = num end
    end,
})

TabCombat:Dropdown({
    Title = "Winpad Target",
    Desc = "PadWins (Yellow / Right) or PadX3 (Purple / Left)",
    Values = {"PadWins", "PadX3", "Auto Best"},
    Value = Config.WinpadType,
    Callback = function(v) Config.WinpadType = v end,
})

TabCombat:Section({Title = "Manual Play Enhancements"})

TabCombat:Toggle({
    Title = "Auto Step Winpad (Manual Play)",
    Desc = "Automatically teleports you to the Winpad the instant all mobs die",
    Value = Config.AutoStepWinpad,
    Callback = function(v) Config.AutoStepWinpad = v end,
})

TabCombat:Toggle({
    Title = "Killaura Proximity",
    Desc = "Attacks any cursed spirits in range automatically",
    Value = Config.Killaura,
    Callback = function(v) Config.Killaura = v end,
})

TabCombat:Slider({
    Title = "Killaura Range",
    Desc = "Studs distance threshold for hitting mobs",
    Step = 5,
    Value = {Min = 15, Max = 100, Default = Config.AttackRange},
    Callback = function(v) Config.AttackRange = v end,
})

-- TAB 3: UPGRADES & PROGRESSION
local TabUpgrades = Window:Tab({Title = "Upgrades", Icon = "crown"})
TabUpgrades:Section({Title = "Domain Expansion (Malevolent Shrine)"})

TabUpgrades:Toggle({
    Title = "Auto Unlock Next Domain",
    Desc = "Unlocks next shrine stage when Wins are sufficient",
    Value = Config.AutoUnlockDomains,
    Callback = function(v) Config.AutoUnlockDomains = v end,
})

TabUpgrades:Toggle({
    Title = "Auto Equip Best Domain",
    Desc = "Equips highest unlocked domain automatically",
    Value = Config.AutoEquipBestDomain,
    Callback = function(v) Config.AutoEquipBestDomain = v end,
})

TabUpgrades:Section({Title = "Cursed Flames"})

TabUpgrades:Toggle({
    Title = "Auto Buy Next Flame",
    Desc = "Purchases higher tier flame multipliers automatically",
    Value = Config.AutoBuyFlames,
    Callback = function(v) Config.AutoBuyFlames = v end,
})

TabUpgrades:Toggle({
    Title = "Auto Equip Best Flame",
    Desc = "Keeps highest multiplier flame equipped",
    Value = Config.AutoEquipBestFlame,
    Callback = function(v) Config.AutoEquipBestFlame = v end,
})

TabUpgrades:Section({Title = "Minigames"})

TabUpgrades:Toggle({
    Title = "Auto Max Minigame Scores",
    Desc = "Sets Snake and Blocks records to 500 automatically",
    Value = Config.AutoMinigameScores,
    Callback = function(v) Config.AutoMinigameScores = v end,
})

-- TAB 4: PETS
local TabPets = Window:Tab({Title = "Pets", Icon = "dog"})
TabPets:Section({Title = "Egg Hatching"})

TabPets:Toggle({
    Title = "Auto Hatch Eggs",
    Desc = "Continuously hatches the chosen egg",
    Value = Config.AutoHatch,
    Callback = function(v) Config.AutoHatch = v end,
})

local eggOptions = {
    "Egg 1 (10 Wins)",
    "Egg 2 (400 Wins)",
    "Egg 3 (World 2)",
    "Egg 6 (1B Wins)",
}

TabPets:Dropdown({
    Title = "Select Egg Station",
    Desc = "Target egg tier to hatch",
    Values = eggOptions,
    Value = "Egg 1 (10 Wins)",
    Callback = function(v)
        local num = tonumber(string.match(v, "%d+"))
        if num then Config.SelectedEgg = num end
    end,
})

TabPets:Section({Title = "Pet Management"})

TabPets:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Continuously keeps strongest hatched pets equipped",
    Value = Config.AutoEquipBestPets,
    Callback = function(v) Config.AutoEquipBestPets = v end,
})

TabPets:Toggle({
    Title = "Auto Merge All Pets",
    Desc = "Fuses duplicate pets into higher tier golden/rainbow forms",
    Value = Config.AutoMergePets,
    Callback = function(v) Config.AutoMergePets = v end,
})

TabPets:Button({
    Title = "Merge All Pets Now",
    Desc = "One-click trigger to fuse all mergeable pets",
    Callback = function()
        Remotes.PetAction:FireServer("mergeall")
        WindUI:Notify({
            Title = "Pets Merged",
            Content = "All duplicate pets merged.",
            Duration = 3,
            Icon = "check",
        })
    end,
})

-- TAB 5: RAID & BOSSES
local TabRaid = Window:Tab({Title = "Raid & Bosses", Icon = "skull"})
TabRaid:Section({Title = "Hourly World Raid"})

TabRaid:Toggle({
    Title = "Auto Join Raid",
    Desc = "Warps into raid arena automatically when event starts",
    Value = Config.AutoJoinRaid,
    Callback = function(v) Config.AutoJoinRaid = v end,
})

TabRaid:Toggle({
    Title = "Auto Attack Raid Boss",
    Desc = "Hits Mahoraga / Toji / Yuta / Akaza / Doma automatically",
    Value = Config.AutoAttackRaid,
    Callback = function(v) Config.AutoAttackRaid = v end,
})

TabRaid:Button({
    Title = "Teleport to Raid Arena Now",
    Desc = "Fast warps straight into the active raid battle",
    Callback = function()
        Remotes.Raid:FireServer("go")
    end,
})

TabRaid:Section({Title = "Token / Finger Shop"})

TabRaid:Toggle({
    Title = "Auto Buy Finger Items",
    Desc = "Purchases charms, eggs, flames, and titles with tokens",
    Value = Config.AutoBuyFingerItems,
    Callback = function(v) Config.AutoBuyFingerItems = v end,
})

TabRaid:Section({Title = "Season Pass"})

TabRaid:Toggle({
    Title = "Auto Claim Season Pass",
    Desc = "Collects free battle pass rewards automatically",
    Value = Config.AutoClaimSeason,
    Callback = function(v) Config.AutoClaimSeason = v end,
})

TabRaid:Button({
    Title = "Claim All Season Rewards Now",
    Desc = "One-click trigger to claim all pending season tiers",
    Callback = function()
        Remotes.Season:FireServer("claimAll")
        WindUI:Notify({
            Title = "Season Rewards",
            Content = "Claimed all unlocked season tiers.",
            Duration = 3,
            Icon = "star",
        })
    end,
})

-- TAB 6: TELEPORTS
local TabTeleport = Window:Tab({Title = "Teleports", Icon = "map-pin"})
TabTeleport:Section({Title = "Hub & World Portals"})

TabTeleport:Button({
    Title = "Teleport to Hub 1 (World 1)",
    Desc = "Spawns at the main central plaza",
    Callback = function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(0, 5, -142)
        end
    end,
})

TabTeleport:Button({
    Title = "Teleport to Hub 2 (World 2)",
    Desc = "Spawns at World 2 hub",
    Callback = function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(0, 5, -2092)
        end
    end,
})

TabTeleport:Section({Title = "Stage Waypoints"})

local allStageItems = {}
for i = 1, 30 do table.insert(allStageItems, "Stage " .. i) end

local selectedTpStage = 1
TabTeleport:Dropdown({
    Title = "Select Stage Destination",
    Desc = "Choose stage to teleport character to",
    Values = allStageItems,
    Value = "Stage 1",
    Callback = function(v)
        local num = tonumber(string.match(v, "%d+"))
        if num then selectedTpStage = num end
    end,
})

TabTeleport:Button({
    Title = "Teleport to Selected Stage",
    Desc = "Warps character directly to the stage gate",
    Callback = function()
        task.spawn(function()
            local reqWorld = selectedTpStage > 15 and 2 or 1
            local curWorld = LocalPlayer:GetAttribute("World") or 1
            if curWorld ~= reqWorld then
                EnterWorldRemote:FireServer(reqWorld)
                local ww = os.clock()
                while os.clock() - ww < 2.0 and (LocalPlayer:GetAttribute("World") or 1) ~= reqWorld do
                    task.wait(0.1)
                end
                task.wait(0.3)
            end

            if isCheckpointStage(selectedTpStage) then
                GoStageRemote:FireServer(selectedTpStage)
            end

            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(getStageEntrance(selectedTpStage))
            end
        end)
    end,
})

-- TAB 7: MOVEMENT & VISUALS
local TabMoveVis = Window:Tab({Title = "Visuals & Movement", Icon = "eye"})
TabMoveVis:Section({Title = "Character Physics"})

TabMoveVis:Toggle({
    Title = "WalkSpeed Modifier",
    Desc = "Overrides character movement velocity",
    Value = Config.SpeedEnabled,
    Callback = function(v) Config.SpeedEnabled = v end,
})

TabMoveVis:Slider({
    Title = "Speed Value",
    Desc = "Custom movement speed (Default: 16)",
    Step = 1,
    Value = {Min = 16, Max = 100, Default = Config.SpeedValue},
    Callback = function(v) Config.SpeedValue = v end,
})

TabMoveVis:Toggle({
    Title = "JumpPower Modifier",
    Desc = "Overrides jump height",
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
    Desc = "Pass smoothly through walls and barriers",
    Value = Config.Noclip,
    Callback = function(v) Config.Noclip = v end,
})

TabMoveVis:Section({Title = "AFK & Utility"})

TabMoveVis:Toggle({
    Title = "Anti-AFK / Anti-Idle",
    Desc = "Prevents Roblox 20-minute idle disconnection",
    Value = Config.AntiAFK,
    Callback = function(v)
        Config.AntiAFK = v
        if v then
            WindUI:Notify({
                Title = "Anti-AFK Active",
                Content = "Protected against 20-minute idle disconnect.",
                Duration = 3,
                Icon = "shield-check",
            })
        end
    end,
})

TabMoveVis:Section({Title = "Enemy ESP"})

TabMoveVis:Toggle({
    Title = "Enable Enemy ESP",
    Desc = "Draws bounding boxes and labels over stage curses",
    Value = Config.EnemyESP,
    Callback = function(v) Config.EnemyESP = v end,
})

TabMoveVis:Toggle({
    Title = "Show Boxes",
    Desc = "2D box surrounding enemy hitbox",
    Value = Config.ESPBoxes,
    Callback = function(v) Config.ESPBoxes = v end,
})

TabMoveVis:Toggle({
    Title = "Show Names & Distance",
    Desc = "Curse name and metric range",
    Value = Config.ESPNames,
    Callback = function(v) Config.ESPNames = v end,
})

TabMoveVis:Toggle({
    Title = "Show Health Tag",
    Desc = "Target status tag",
    Value = Config.ESPHealth,
    Callback = function(v) Config.ESPHealth = v end,
})

-- TAB 8: CONFIG & SETTINGS
local TabConfig = Window:Tab({Title = "Config", Icon = "file-cog"})
TabConfig:Section({Title = "Profile Storage"})

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
    Desc = "Toggles visibility of screen toggle button",
    Value = Config.FloatingButton,
    Callback = function(v)
        Config.FloatingButton = v
        floatingGui.Enabled = v
    end,
})

-- Initial Notification
WindUI:Notify({
    Title = "+1 Sukuna Evolution Elite",
    Content = "Press LeftCTRL or tap floating button to Show/Hide.",
    Duration = 5,
    Icon = "flame",
})

print("[+1 Sukuna Evolution Elite] Script initialized. Default state: ALL OFF.")
