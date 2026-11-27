-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ILLEGAL SOCCER â UNIVERSAL AUTOMATION SYSTEM
    Engineered for Brutal Technical Rigor & Undetected Execution
    Platform: REAL MCP / Executor Architecture
    UI Framework: WindUI
    Default State: ALL OFF
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Internal Game Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = ReplicatedStorage:WaitForChild("Client")
local ContextState = require(Modules:WaitForChild("ContextState"))
local HitboxSettings = require(Modules.Gameplay:WaitForChild("HitboxSettings"))
local Renderer = require(Client.Gameplay.Ball:WaitForChild("Renderer"))
local Movement = require(Client.Gameplay.Player:WaitForChild("Movement"))
local Sprint = require(Modules.Actions:WaitForChild("Sprint"))
local ActionRemoteProtocol = require(Modules.Actions:WaitForChild("ActionRemoteProtocol"))
local ActorTeams = require(Client.Gameplay:WaitForChild("ActorTeams"))

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BallRemotes = Remotes:WaitForChild("Ball")
local KickRemote = BallRemotes:WaitForChild("Kick")

-- Global State & Settings (ALL DEFAULT TO OFF)
local State = {
    -- Combat & Movement
    InfiniteStamina = false,
    SpeedBoost = false,
    SpeedMultiplier = 1.3,
    HighJump = false,
    JumpMultiplier = 1.3,
    AntiRagdoll = false,
    NoClip = false,

    -- Ball & Goal Automation
    AutoGoal = false,
    GoalTarget = "Auto",            -- "Auto", "Team 1", "Team 2"
    ShotPlacement = "Random Corner", -- "Top Left", "Top Right", "Center", "Random Corner"
    HitboxExpander = false,
    ReachSize = 25,
    AutoTackle = false,
    TackleDistance = 18,
    BallMagnet = false,

    -- Visuals (ESP)
    BallESP = false,
    PlayerESP = false,
    Tracers = false,
    GoalESP = false,

    -- World & Utility
    FovChanger = false,
    FovValue = 90,
    Fullbright = false
}

-- Default Geometry & Hitbox Baselines
local DefaultHitboxes = {
    Receive = HitboxSettings.Receive.Size,
    AirReceive = HitboxSettings.AirReceive.Size,
    Kick = HitboxSettings.Kick.Size,
    SlideTackle = HitboxSettings.SlideTackle.Size,
}

local GoalPositions = {
    Team1 = Vector3.new(0, 7, 155),
    Team2 = Vector3.new(0, 7, -155),
}

-- Connection & Resource Tracking
local Connections = {}
local DrawingObjects = {}
local UI_Elements = {}

local function RegisterConnection(conn)
    table.insert(Connections, conn)
    return conn
end

-- =========================================================================
-- PHASE 1: ANTI-CHEAT DETOUR & INTEGRITY NEUTRALIZATION
-- =========================================================================
local function NeutralizeAntiCheat()
    pcall(function()
        local cs = ContextState.Get("AntiExploitSettings")
        if cs then
            cs.LocalEnabled = false
            if cs.Changed then
                cs.Changed:Fire()
            end
        end
    end)
end
NeutralizeAntiCheat()

-- =========================================================================
-- PHASE 2: CORE AUTOMATION IMPLEMENTATIONS
-- =========================================================================

-- Infinite Stamina
local function ApplyInfiniteStamina(enabled)
    pcall(function()
        Sprint.SetUnlimitedStamina(LocalPlayer, "UniversalBypass", enabled)
        if LocalPlayer.Character then
            Sprint.SetUnlimitedStamina(LocalPlayer.Character, "UniversalBypass", enabled)
        end
    end)
end

-- Speed & Jump Multipliers
local function ApplySpeed()
    pcall(function()
        if State.SpeedBoost then
            Movement.SetMultiplier("UniversalSpeed", {WalkSpeed = State.SpeedMultiplier})
        else
            Movement.ClearMultiplier("UniversalSpeed")
        end
    end)
end

local function ApplyJump()
    pcall(function()
        if State.HighJump then
            Movement.SetMultiplier("UniversalJump", {JumpHeight = State.JumpMultiplier})
        else
            Movement.ClearMultiplier("UniversalJump")
        end
    end)
end

-- Anti-Ragdoll & Stun Suppressor
local function ApplyAntiRagdoll()
    pcall(function()
        if State.AntiRagdoll then
            Movement.SuppressServerRagdoll("UniversalRagdoll", math.huge, math.huge)
        else
            Movement.ClearServerRagdollSuppression("UniversalRagdoll")
        end
    end)
end

-- Hitbox Reach Expander
local function ApplyHitboxExpansion()
    pcall(function()
        if State.HitboxExpander then
            local reach = State.ReachSize
            HitboxSettings.Receive.Size = Vector3.new(reach, reach, reach)
            HitboxSettings.AirReceive.Size = Vector3.new(reach, reach, reach)
            HitboxSettings.Kick.Size = Vector3.new(reach, reach, reach)
            HitboxSettings.SlideTackle.Size = Vector3.new(reach, reach, reach)
        else
            HitboxSettings.Receive.Size = DefaultHitboxes.Receive
            HitboxSettings.AirReceive.Size = DefaultHitboxes.AirReceive
            HitboxSettings.Kick.Size = DefaultHitboxes.Kick
            HitboxSettings.SlideTackle.Size = DefaultHitboxes.SlideTackle
        end
    end)
end

-- Target Goal Calculation
local function GetCalculatedGoalTarget()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myZ = root and root.Position.Z or 0

    local targetBase = GoalPositions.Team2
    if State.GoalTarget == "Team 1" then
        targetBase = GoalPositions.Team1
    elseif State.GoalTarget == "Team 2" then
        targetBase = GoalPositions.Team2
    else
        targetBase = (myZ > 0) and GoalPositions.Team2 or GoalPositions.Team1
    end

    local finalTarget = targetBase
    if State.ShotPlacement == "Top Left" then
        finalTarget = targetBase + Vector3.new(-13, 3.8, 0)
    elseif State.ShotPlacement == "Top Right" then
        finalTarget = targetBase + Vector3.new(13, 3.8, 0)
    elseif State.ShotPlacement == "Center" then
        finalTarget = targetBase + Vector3.new(0, 1.5, 0)
    elseif State.ShotPlacement == "Random Corner" then
        local side = (math.random(1, 2) == 1) and -13 or 13
        finalTarget = targetBase + Vector3.new(side, 3.8, 0)
    end

    return finalTarget
end

-- Silent Aim Hook for Kicks / Shots
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and method == "FireServer" and self == KickRemote then
        local packet = args[1]
        if typeof(packet) == "table" and packet.Command and State.AutoGoal then
            local targetPos = GetCalculatedGoalTarget()
            local ballPos = Renderer.GetPosition()
            if not ballPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                ballPos = LocalPlayer.Character.HumanoidRootPart.Position
            end

            if targetPos and ballPos then
                local aimDir = (targetPos - ballPos).Unit
                if typeof(packet.Command.AimDirection) == "table" then
                    packet.Command.AimDirection.Direction = aimDir
                    packet.Command.AimDirection.TargetPosition = targetPos
                else
                    packet.Command.AimDirection = aimDir
                end
            end
        end
    end

    return oldNamecall(self, table.unpack(args))
end))

-- Auto Tackle Mechanism
local lastTackleAttempt = 0
local function ExecuteAutoTackle()
    if not State.AutoTackle then return end
    if os.clock() - lastTackleAttempt < 1.2 then return end

    local ownerId = Renderer.GetMainMatchOwnerUserId()
    if not ownerId or ownerId == LocalPlayer.UserId then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local enemyPlayer = Players:GetPlayerByUserId(ownerId)
    local enemyChar = enemyPlayer and enemyPlayer.Character
    local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return end

    local dist = (enemyRoot.Position - myRoot.Position).Magnitude
    if dist <= State.TackleDistance then
        lastTackleAttempt = os.clock()
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.delay(0.04, function()
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end)
    end
end

-- Ball Magnet Mechanism
local function ExecuteBallMagnet()
    if not State.BallMagnet then return end
    local ownerId = Renderer.GetMainMatchOwnerUserId()
    if ownerId then return end

    local ballPos = Renderer.GetPosition()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not ballPos or not root then return end

    local dist = (ballPos - root.Position).Magnitude
    if dist <= 38 and dist > 2 then
        local ball = Renderer.GetBall()
        if ball and ball:IsA("BasePart") then
            local pullVector = (root.Position - ballPos).Unit * 38
            ball.AssemblyLinearVelocity = pullVector
        end
    end
end

-- Fullbright & FOV
local defaultFov = Camera.FieldOfView
local defaultLighting = {
    Brightness = game:GetService("Lighting").Brightness,
    ClockTime = game:GetService("Lighting").ClockTime,
    FogEnd = game:GetService("Lighting").FogEnd,
    GlobalShadows = game:GetService("Lighting").GlobalShadows,
    Ambient = game:GetService("Lighting").Ambient,
}

local function ApplyFullbright()
    local Lighting = game:GetService("Lighting")
    if State.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = defaultLighting.Brightness
        Lighting.ClockTime = defaultLighting.ClockTime
        Lighting.FogEnd = defaultLighting.FogEnd
        Lighting.GlobalShadows = defaultLighting.GlobalShadows
        Lighting.Ambient = defaultLighting.Ambient
    end
end

local function ApplyFov()
    if State.FovChanger then
        Camera.FieldOfView = State.FovValue
    else
        Camera.FieldOfView = defaultFov
    end
end

-- =========================================================================
-- PHASE 3: DRAWING ESP ENGINE (HIGH-PERFORMANCE)
-- =========================================================================
local function CreateDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do
        obj[k] = v
    end
    table.insert(DrawingObjects, obj)
    return obj
end

-- Ball ESP Objects
local BallTag = CreateDrawing("Text", {
    Size = 14,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(255, 215, 0),
    Visible = false,
})
local BallTracer = CreateDrawing("Line", {
    Thickness = 1.5,
    Color = Color3.fromRGB(255, 215, 0),
    Visible = false,
})

-- Goal ESP Objects
local Goal1Tag = CreateDrawing("Text", {
    Size = 13,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(80, 180, 255),
    Visible = false,
})
local Goal2Tag = CreateDrawing("Text", {
    Size = 13,
    Center = true,
    Outline = true,
    Color = Color3.fromRGB(255, 90, 90),
    Visible = false,
})

-- Player ESP Pool
local PlayerESP_Pool = {}

local function GetPlayerESP(player)
    if not PlayerESP_Pool[player] then
        PlayerESP_Pool[player] = {
            Box = CreateDrawing("Square", {Thickness = 1.5, Filled = false, Visible = false}),
            Tag = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Visible = false}),
            Tracer = CreateDrawing("Line", {Thickness = 1.2, Visible = false}),
        }
    end
    return PlayerESP_Pool[player]
end

-- Main Render Loop
RegisterConnection(RunService.RenderStepped:Connect(function()
    -- Camera FOV
    if State.FovChanger then
        Camera.FieldOfView = State.FovValue
    end

    -- NoClip
    if State.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Ball ESP
    if State.BallESP then
        local ballPos = Renderer.GetPosition()
        if ballPos then
            local screenPos, onScreen = Camera:WorldToViewportPoint(ballPos)
            if onScreen then
                local ownerId = Renderer.GetMainMatchOwnerUserId()
                local ownerName = "FREE"
                if ownerId then
                    local p = Players:GetPlayerByUserId(ownerId)
                    ownerName = p and p.DisplayName or ("Holder [" .. tostring(ownerId) .. "]")
                end

                local dist = math.floor((ballPos - Camera.CFrame.Position).Magnitude)
                BallTag.Text = string.format("â½ BALL [%d m]\n(%s)", dist, ownerName)
                BallTag.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
                BallTag.Visible = true

                if State.Tracers then
                    BallTracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    BallTracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    BallTracer.Visible = true
                else
                    BallTracer.Visible = false
                end
            else
                BallTag.Visible = false
                BallTracer.Visible = false
            end
        else
            BallTag.Visible = false
            BallTracer.Visible = false
        end
    else
        BallTag.Visible = false
        BallTracer.Visible = false
    end

    -- Goal ESP
    if State.GoalESP then
        local p1, on1 = Camera:WorldToViewportPoint(GoalPositions.Team1)
        if on1 then
            local d1 = math.floor((GoalPositions.Team1 - Camera.CFrame.Position).Magnitude)
            Goal1Tag.Text = string.format("ð¥ TEAM 1 GOAL [%d m]", d1)
            Goal1Tag.Position = Vector2.new(p1.X, p1.Y)
            Goal1Tag.Visible = true
        else
            Goal1Tag.Visible = false
        end

        local p2, on2 = Camera:WorldToViewportPoint(GoalPositions.Team2)
        if on2 then
            local d2 = math.floor((GoalPositions.Team2 - Camera.CFrame.Position).Magnitude)
            Goal2Tag.Text = string.format("ð¥ TEAM 2 GOAL [%d m]", d2)
            Goal2Tag.Position = Vector2.new(p2.X, p2.Y)
            Goal2Tag.Visible = true
        else
            Goal2Tag.Visible = false
        end
    else
        Goal1Tag.Visible = false
        Goal2Tag.Visible = false
    end

    -- Player ESP
    for _, player in ipairs(Players:GetPlayers()) do
        local esp = GetPlayerESP(player)
        if State.PlayerESP and player ~= LocalPlayer and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local myTeam = ActorTeams.GetActorTeamName(LocalPlayer)
                    local theirTeam = ActorTeams.GetActorTeamName(player)
                    local isTeammate = (myTeam ~= nil and theirTeam ~= nil and myTeam == theirTeam)
                    local espColor = isTeammate and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 75, 75)

                    -- Bounding Box Dimensions
                    local top, _ = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, 3, 0)).Position)
                    local bottom, _ = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3.2, 0)).Position)
                    local height = math.abs(bottom.Y - top.Y)
                    local width = height * 0.65

                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                    esp.Box.Color = espColor
                    esp.Box.Visible = true

                    local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                    esp.Tag.Text = string.format("%s [%d m]", player.DisplayName, dist)
                    esp.Tag.Position = Vector2.new(rootPos.X, rootPos.Y - height / 2 - 16)
                    esp.Tag.Color = espColor
                    esp.Tag.Visible = true

                    if State.Tracers then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height / 2)
                        esp.Tracer.Color = espColor
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Tag.Visible = false
                    esp.Tracer.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Tag.Visible = false
                esp.Tracer.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Tag.Visible = false
            esp.Tracer.Visible = false
        end
    end
end))

-- Heartbeat Logic Loop
RegisterConnection(RunService.Heartbeat:Connect(function()
    ExecuteAutoTackle()
    ExecuteBallMagnet()

    -- Stun Auto-Clear
    if State.AntiRagdoll and LocalPlayer.Character then
        if LocalPlayer.Character:GetAttribute("Stunned") then
            LocalPlayer.Character:SetAttribute("Stunned", false)
        end
    end
end))

-- Re-apply on Character Respawn
RegisterConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    NeutralizeAntiCheat()
    if State.InfiniteStamina then ApplyInfiniteStamina(true) end
    if State.SpeedBoost then ApplySpeed() end
    if State.HighJump then ApplyJump() end
    if State.AntiRagdoll then ApplyAntiRagdoll() end
end))

-- =========================================================================
-- PHASE 4: CONFIGURATION SYSTEM (PERSISTENCE)
-- =========================================================================
local ConfigPath = "IllegalSoccer"
local ConfigFile = ConfigPath .. "/config.json"

local function SaveConfiguration()
    pcall(function()
        if not isfolder(ConfigPath) then
            makefolder(ConfigPath)
        end
        local data = HttpService:JSONEncode(State)
        writefile(ConfigFile, data)
    end)
end

local function LoadConfiguration(WindUIWindow)
    pcall(function()
        if isfile(ConfigFile) then
            local raw = readfile(ConfigFile)
            local loaded = HttpService:JSONDecode(raw)
            if typeof(loaded) == "table" then
                for k, v in pairs(loaded) do
                    if State[k] ~= nil then
                        State[k] = v
                        if UI_Elements[k] then
                            if UI_Elements[k].Set then
                                UI_Elements[k]:Set(v)
                            end
                        end
                    end
                end
                -- Update physical states
                ApplyInfiniteStamina(State.InfiniteStamina)
                ApplySpeed()
                ApplyJump()
                ApplyAntiRagdoll()
                ApplyHitboxExpansion()
                ApplyFullbright()
                ApplyFov()
            end
        end
    end)
end

local function ResetConfiguration()
    for k, _ in pairs(State) do
        if typeof(State[k]) == "boolean" then
            State[k] = false
            if UI_Elements[k] and UI_Elements[k].Set then
                UI_Elements[k]:Set(false)
            end
        end
    end
    State.SpeedMultiplier = 1.3
    State.JumpMultiplier = 1.3
    State.ReachSize = 25
    State.TackleDistance = 18
    State.GoalTarget = "Auto"
    State.ShotPlacement = "Random Corner"
    State.FovValue = 90

    if UI_Elements.SpeedMultiplier then UI_Elements.SpeedMultiplier:Set(1.3) end
    if UI_Elements.JumpMultiplier then UI_Elements.JumpMultiplier:Set(1.3) end
    if UI_Elements.ReachSize then UI_Elements.ReachSize:Set(25) end
    if UI_Elements.TackleDistance then UI_Elements.TackleDistance:Set(18) end
    if UI_Elements.FovValue then UI_Elements.FovValue:Set(90) end

    ApplyInfiniteStamina(false)
    ApplySpeed()
    ApplyJump()
    ApplyAntiRagdoll()
    ApplyHitboxExpansion()
    ApplyFullbright()
    ApplyFov()
end

-- =========================================================================
-- PHASE 5: WINDUI CONSTRUCTION (ENGLISH INTERFACE & CONTROLS)
-- =========================================================================
pcall(function()
    local targetHui = gethui and gethui() or game:GetService("CoreGui")
    for _, gui in ipairs(targetHui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("WindUI") or gui.Name:find("IllegalSoccer")) then
            gui:Destroy()
        end
    end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Illegal Soccer | Universal Automation",
    Icon = "shield",
    Author = "Universal Architecture Engine",
    Folder = "IllegalSoccer",
    Size = UDim2.fromOffset(600, 470),
    Transparent = true,
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Illegal Soccer",
        Icon = "shield",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
    },
})

-- Tab 1: Combat & Movement
local TabMovement = Window:Tab({Title = "Movement", Icon = "zap"})

TabMovement:Section({Title = "Stamina & Velocity"})

UI_Elements.InfiniteStamina = TabMovement:Toggle({
    Title = "Infinite Stamina",
    Desc = "Bypasses all stamina depletion for sprint and jumps",
    Value = false,
    Callback = function(val)
        State.InfiniteStamina = val
        ApplyInfiniteStamina(val)
    end
})

UI_Elements.SpeedBoost = TabMovement:Toggle({
    Title = "Speed Multiplier Boost",
    Desc = "Applies native internal controller speed acceleration",
    Value = false,
    Callback = function(val)
        State.SpeedBoost = val
        ApplySpeed()
    end
})

UI_Elements.SpeedMultiplier = TabMovement:Slider({
    Title = "Speed Multiplier",
    Value = {Min = 1.0, Max = 2.5, Default = 1.3},
    Step = 0.1,
    Callback = function(val)
        State.SpeedMultiplier = val
        if State.SpeedBoost then ApplySpeed() end
    end
})

UI_Elements.HighJump = TabMovement:Toggle({
    Title = "High Jump Boost",
    Desc = "Increases vertical leap clearance",
    Value = false,
    Callback = function(val)
        State.HighJump = val
        ApplyJump()
    end
})

UI_Elements.JumpMultiplier = TabMovement:Slider({
    Title = "Jump Multiplier",
    Value = {Min = 1.0, Max = 2.5, Default = 1.3},
    Step = 0.1,
    Callback = function(val)
        State.JumpMultiplier = val
        if State.HighJump then ApplyJump() end
    end
})

TabMovement:Section({Title = "Collision & Recovery"})

UI_Elements.AntiRagdoll = TabMovement:Toggle({
    Title = "Anti-Ragdoll & Stun Suppressor",
    Desc = "Permanently suppresses server knockdowns and trips",
    Value = false,
    Callback = function(val)
        State.AntiRagdoll = val
        ApplyAntiRagdoll()
    end
})

UI_Elements.NoClip = TabMovement:Toggle({
    Title = "NoClip (Pass Through Colliders)",
    Desc = "Disables physical collisions with field barricades and world objects",
    Value = false,
    Callback = function(val)
        State.NoClip = val
    end
})

-- Tab 2: Ball & Goal Automation
local TabBall = Window:Tab({Title = "Ball & Goal", Icon = "circle-dot"})

TabBall:Section({Title = "Shooting & Scoring"})

UI_Elements.AutoGoal = TabBall:Toggle({
    Title = "Auto Goal (Silent Aim)",
    Desc = "Intercepts kicks/shots and redirects aim straight into the goal net",
    Value = false,
    Callback = function(val)
        State.AutoGoal = val
    end
})

UI_Elements.GoalTarget = TabBall:Dropdown({
    Title = "Target Goal Mode",
    Values = {"Auto", "Team 1", "Team 2"},
    Value = "Auto",
    Callback = function(val)
        State.GoalTarget = val
    end
})

UI_Elements.ShotPlacement = TabBall:Dropdown({
    Title = "Shot Net Placement",
    Values = {"Random Corner", "Top Left", "Top Right", "Center"},
    Value = "Random Corner",
    Callback = function(val)
        State.ShotPlacement = val
    end
})

TabBall:Section({Title = "Reach & Possession"})

UI_Elements.HitboxExpander = TabBall:Toggle({
    Title = "Hitbox Expander / Reach",
    Desc = "Expands ball receive and tackle interception boundary",
    Value = false,
    Callback = function(val)
        State.HitboxExpander = val
        ApplyHitboxExpansion()
    end
})

UI_Elements.ReachSize = TabBall:Slider({
    Title = "Reach Dimension (Studs)",
    Value = {Min = 10, Max = 40, Default = 25},
    Step = 1,
    Callback = function(val)
        State.ReachSize = val
        if State.HitboxExpander then ApplyHitboxExpansion() end
    end
})

UI_Elements.AutoTackle = TabBall:Toggle({
    Title = "Auto Tackle",
    Desc = "Automatically dispossesses opponent carriers entering your radius",
    Value = false,
    Callback = function(val)
        State.AutoTackle = val
    end
})

UI_Elements.TackleDistance = TabBall:Slider({
    Title = "Auto Tackle Distance (Studs)",
    Value = {Min = 8, Max = 30, Default = 18},
    Step = 1,
    Callback = function(val)
        State.TackleDistance = val
    end
})

UI_Elements.BallMagnet = TabBall:Toggle({
    Title = "Ball Magnet / Fetch",
    Desc = "Pulls loose match balls toward your feet",
    Value = false,
    Callback = function(val)
        State.BallMagnet = val
    end
})

-- Tab 3: Visuals (ESP)
local TabESP = Window:Tab({Title = "Visuals", Icon = "eye"})

TabESP:Section({Title = "Tactical ESP"})

UI_Elements.BallESP = TabESP:Toggle({
    Title = "Ball ESP & Indicator",
    Desc = "Highlights the ball, distance, and current possession holder",
    Value = false,
    Callback = function(val)
        State.BallESP = val
    end
})

UI_Elements.PlayerESP = TabESP:Toggle({
    Title = "Player 2D Box ESP",
    Desc = "Renders team-colored boxes, player names, and distance tags",
    Value = false,
    Callback = function(val)
        State.PlayerESP = val
    end
})

UI_Elements.Tracers = TabESP:Toggle({
    Title = "Snaplines / Tracers",
    Desc = "Draws guide tracers from screen bottom to ball and targets",
    Value = false,
    Callback = function(val)
        State.Tracers = val
    end
})

UI_Elements.GoalESP = TabESP:Toggle({
    Title = "Goal Net ESP",
    Desc = "Marks Team 1 and Team 2 goals with distance meters",
    Value = false,
    Callback = function(val)
        State.GoalESP = val
    end
})

-- Tab 4: World & Environment
local TabWorld = Window:Tab({Title = "World", Icon = "sliders"})

TabWorld:Section({Title = "Vision & Environment"})

UI_Elements.FovChanger = TabWorld:Toggle({
    Title = "Custom Field of View",
    Desc = "Extends viewport angle for broader pitch awareness",
    Value = false,
    Callback = function(val)
        State.FovChanger = val
        ApplyFov()
    end
})

UI_Elements.FovValue = TabWorld:Slider({
    Title = "Field of View (Degrees)",
    Value = {Min = 70, Max = 120, Default = 90},
    Step = 1,
    Callback = function(val)
        State.FovValue = val
        if State.FovChanger then ApplyFov() end
    end
})

UI_Elements.Fullbright = TabWorld:Toggle({
    Title = "Fullbright Mode",
    Desc = "Strips darkness and pitch shadows for crisp visibility",
    Value = false,
    Callback = function(val)
        State.Fullbright = val
        ApplyFullbright()
    end
})

-- Tab 5: Configuration Manager
local TabConfig = Window:Tab({Title = "Config", Icon = "save"})

TabConfig:Section({Title = "Profile Persistence"})

TabConfig:Button({
    Title = "Save Config",
    Desc = "Persists your current feature toggles and slider values to disk",
    Icon = "save",
    Callback = function()
        SaveConfiguration()
        WindUI:Notify({
            Title = "Configuration Saved",
            Content = "Saved successfully to " .. ConfigFile,
            Duration = 3,
            Icon = "check"
        })
    end
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Loads and restores previously saved settings from disk",
    Icon = "folder-up",
    Callback = function()
        LoadConfiguration(Window)
        WindUI:Notify({
            Title = "Configuration Loaded",
            Content = "Settings applied successfully!",
            Duration = 3,
            Icon = "check"
        })
    end
})

TabConfig:Button({
    Title = "Reset to Defaults (ALL OFF)",
    Desc = "Immediately turns off all active automations and resets to baseline",
    Icon = "rotate-ccw",
    Callback = function()
        ResetConfiguration()
        WindUI:Notify({
            Title = "Configuration Reset",
            Content = "All automations turned OFF.",
            Duration = 3,
            Icon = "alert-triangle"
        })
    end
})

TabConfig:Section({Title = "Keybind Information"})
TabConfig:Paragraph({
    Title = "Menu Toggle Key",
    Desc = "Press [Left Control] on your keyboard to Show or Hide this menu anytime.\nOn mobile or touch devices, tap the floating shield button."
})

-- Teardown Hook for Live Reloading & Unloading
if typeof(STATE) == "table" and STATE.onCleanup then
    STATE.onCleanup(function()
        for _, conn in ipairs(Connections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, obj in ipairs(DrawingObjects) do
            pcall(function() obj:Remove() end)
        end
        for _, esp in pairs(PlayerESP_Pool) do
            pcall(function() esp.Box:Remove() end)
            pcall(function() esp.Tag:Remove() end)
            pcall(function() esp.Tracer:Remove() end)
        end
        ApplyInfiniteStamina(false)
        ApplySpeed()
        ApplyJump()
        ApplyAntiRagdoll()
        ApplyHitboxExpansion()
        ApplyFullbright()
        ApplyFov()
        if Window and Window.Destroy then
            pcall(function() Window:Destroy() end)
        end
    end)
end

WindUI:Notify({
    Title = "Illegal Soccer Automation",
    Content = "Script loaded successfully! Press LeftCTRL to toggle menu.",
    Duration = 4,
    Icon = "shield"
})
