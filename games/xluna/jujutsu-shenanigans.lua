-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
    JUJUTSU SHENANIGANS â MASTER AUTOMATION SUITE (ULTIMATE V2)
    Author: By XLunaHUB
    Framework: WindUI
    Target Game: [ð] Jujutsu Shenanigans (PlaceId: 9391468976)
    Architecture: Non-Blocking Real-Time Knit Controller Engine
    âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
]]

-- Wait for Game & Player Loading
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

-- Wait for Player Character and Controller Environment
repeat task.wait(0.1) until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Safe Knit Resolution
local Knit = require(ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"))
local ToolController = Knit.GetController("ToolController")
local HitboxController = Knit.GetController("HitboxController")
local MovementController = Knit.GetController("MovementController")
local FXController = Knit.GetController("FXController")

-- Direct Service Remotes & Knit Services
local ServicesFolder = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
local JoinRE = ServicesFolder:WaitForChild("JoinService"):WaitForChild("RE")
local MovementRE = ServicesFolder:WaitForChild("MovementService"):WaitForChild("RE")
local BlockService = Knit.GetService("BlockService")
local HitboxService = Knit.GetService("HitboxService")

-- Clean Global Context
if getgenv().XLunaHUB_Loaded then
    pcall(function()
        if getgenv().XLunaHUB_Cleanup then
            getgenv().XLunaHUB_Cleanup()
        end
    end)
end
getgenv().XLunaHUB_Loaded = true

-- Master Settings Table (ALL DEFAULTS ARE OFF / FALSE AS MANDATED)
local Settings = {
    -- Combat
    Killaura = false,
    AttackRange = 35,
    AttackDelay = 0.22,
    FaceTarget = true,
    TeleportBehind = false,

    HitboxExpander = false,
    HitboxReach = 50,

    StickyTarget = true,
    AutoSkills = false,
    SkillRange = 65,
    AutoAwakening = false,
    AutoRespawn = false,

    AutoBlock = false,
    AutoBlockRange = 14,
    AntiRagdoll = false,

    -- Movement
    InfiniteDash = false,
    DashPower = 2.5,
    SpeedBoost = false,
    WalkSpeed = 45,
    InfiniteJump = false,
    Noclip = false,

    -- Farm & World
    AutoCollectCoins = false,
    AutoCollectItems = false,
    PromptAura = false,
    PromptAuraRadius = 16,
    SelectedCharacter = "Gojo",

    -- Visuals
    PlayerESP = false,
    PlayerNames = false,
    MovesetESP = false,
    HealthESP = false,

    -- System
    AntiAFK = false,
}

local UIReferences = {}
local Connections = {}
local ESPDrawings = {
    Highlights = {},
    Billboards = {},
}

-- Utility Functions & Persistent Target Lock System
local CurrentLockedTarget = nil

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head"))
end

local function isAlive(char)
    if not char or not char.Parent then return false end
    if char:GetAttribute("Dead") == true then return false end
    if char:FindFirstChild("Info") and char.Info:FindFirstChild("Dead") then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") ~= nil
end

local function getClosestEnemy(maxDist)
    local myChar = LocalPlayer.Character
    local myRoot = getRoot(myChar)
    if not myRoot then return nil, math.huge end

    local closest = nil
    local shortestDist = maxDist or math.huge

    if workspace:FindFirstChild("Characters") then
        for _, char in ipairs(workspace.Characters:GetChildren()) do
            if char ~= myChar and isAlive(char) then
                local enemyRoot = getRoot(char)
                if enemyRoot then
                    local dist = (enemyRoot.Position - myRoot.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = char
                    end
                end
            end
        end
    end
    return closest, shortestDist
end

-- Persistent Sticky Combat Target Resolver (Retains focus until target is dead)
local function getCombatTarget(maxDist)
    local myChar = LocalPlayer.Character
    local myRoot = getRoot(myChar)
    if not myRoot then
        CurrentLockedTarget = nil
        return nil, math.huge
    end

    maxDist = maxDist or 65

    -- Sticky Target: Jika musuh yang sedang dilock masih hidup dan belum keluar leash limit, jangan pindah target!
    if Settings.StickyTarget and CurrentLockedTarget and isAlive(CurrentLockedTarget) then
        local targetRoot = getRoot(CurrentLockedTarget)
        if targetRoot then
            local dist = (targetRoot.Position - myRoot.Position).Magnitude
            local leashLimit = math.max(maxDist * 1.4, maxDist + 25)
            if dist <= leashLimit then
                return CurrentLockedTarget, dist
            end
        end
    end

    -- Target sebelumnya mati / keluar leash limit -> reset dan cari musuh hidup terdekat baru
    CurrentLockedTarget = nil
    local closest, shortestDist = getClosestEnemy(maxDist)

    if Settings.StickyTarget then
        CurrentLockedTarget = closest
    end
    return closest, shortestDist
end

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- LUA-LEVEL HITBOX EXPANDER & TARGET RESOLVER DETOUR
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
local originalSphereHitbox = HitboxController.SphereHitbox
local originalGetTarget = ToolController.GetTarget

-- Auto Target Detour: Prioritize locked target so targeted skills (u62 == 2) focus the same enemy
ToolController.GetTarget = function(self, a2)
    if Settings.StickyTarget and CurrentLockedTarget and isAlive(CurrentLockedTarget) then
        local maxRange = math.max(Settings.SkillRange or 65, math.max(Settings.AttackRange or 35, Settings.HitboxReach or 50))
        local targetRoot = getRoot(CurrentLockedTarget)
        local myRoot = getRoot(LocalPlayer.Character)
        if targetRoot and myRoot and (targetRoot.Position - myRoot.Position).Magnitude <= (maxRange * 1.4) then
            return CurrentLockedTarget
        end
    end

    local target = originalGetTarget(self, a2)
    if not target and (Settings.AutoSkills or Settings.Killaura) then
        local maxRange = math.max(Settings.SkillRange or 65, math.max(Settings.AttackRange or 35, Settings.HitboxReach or 50))
        local fallbackEnemy = getCombatTarget(maxRange)
        if fallbackEnemy then
            return fallbackEnemy
        end
    end
    return target
end

-- Hitbox Expander Detour: Server damage injector across full range
HitboxController.SphereHitbox = function(self, attacker, offset, size)
    local results = originalSphereHitbox(self, attacker, offset, size)
    
    if (Settings.HitboxExpander or Settings.Killaura) and attacker == LocalPlayer.Character then
        local reach = math.max(Settings.HitboxReach or 50, Settings.AttackRange or 35)
        local myRoot = getRoot(LocalPlayer.Character)
        if myRoot and workspace:FindFirstChild("Characters") then
            for _, char in ipairs(workspace.Characters:GetChildren()) do
                if char ~= LocalPlayer.Character and isAlive(char) then
                    local enemyRoot = getRoot(char)
                    if enemyRoot and (enemyRoot.Position - myRoot.Position).Magnitude <= reach then
                        local alreadyIn = false
                        for _, existing in ipairs(results) do
                            if existing == char then
                                alreadyIn = true
                                break
                            end
                        end
                        if not alreadyIn then
                            table.insert(results, char)
                        end
                    end
                end
            end
        end
    end
    
    return results
end

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- COMBAT AUTOMATION THREADS
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- Thread 1: Killaura / Auto Attack
task.spawn(function()
    while true do
        if Settings.Killaura then
            local myChar = LocalPlayer.Character
            if isAlive(myChar) then
                local range = Settings.AttackRange or 35
                local target, dist = getCombatTarget(range)
                if target and dist <= range then
                    local myRoot = getRoot(myChar)
                    local targetRoot = getRoot(target)
                    if myRoot and targetRoot then
                        if Settings.TeleportBehind then
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3.2)
                        elseif Settings.FaceTarget then
                            myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                        end

                        -- Direct engine attack dispatch with ground truth parameters
                        pcall(function()
                            ToolController:UseSetService("Activated", false, target)
                            if FXController and Sounds and Sounds.Misc and Sounds.Misc.Swing and Sounds.Misc.Swing.Fist then
                                FXController:PlaySound(Sounds.Misc.Swing.Fist, myRoot, game.SoundService.Effect)
                            end
                        end)

                        task.wait(Settings.AttackDelay or 0.22)
                    else
                        task.wait(0.08)
                    end
                else
                    task.wait(0.08)
                end
            else
                task.wait(0.3)
            end
        else
            task.wait(0.15)
        end
    end
end)

-- Thread 2: Auto Skills Rotator (Dynamic Range & Multi-Verification Cooldown Engine)
task.spawn(function()
    while true do
        if Settings.AutoSkills then
            local myChar = LocalPlayer.Character
            if isAlive(myChar) and myChar:FindFirstChild("Moveset") then
                local isRagdoll = (myChar:GetAttribute("Ragdoll") or 0) > 0
                local isStun = (myChar:GetAttribute("Stun") == true)
                local inDash = myChar:FindFirstChild("Info") and (myChar.Info:FindFirstChild("InDash") or myChar.Info:FindFirstChild("InRoll"))

                if not isRagdoll and not isStun and not inDash then
                    local range = Settings.SkillRange or Settings.AttackRange or 65
                    local target, dist = getCombatTarget(range)

                    -- Fallback to ToolController target if already aimed
                    if not target and ToolController and ToolController.GetTarget then
                        pcall(function()
                            local t = ToolController:GetTarget()
                            if t and isAlive(t) then
                                local r1 = getRoot(myChar)
                                local r2 = getRoot(t)
                                if r1 and r2 then
                                    local d = (r2.Position - r1.Position).Magnitude
                                    if d <= range then
                                        target = t
                                        dist = d
                                        if Settings.StickyTarget then
                                            CurrentLockedTarget = t
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    if target and dist <= range then
                        local myRoot = getRoot(myChar)
                        local targetRoot = getRoot(target)

                        -- Automatically face enemy so directional skill projectiles connect
                        if myRoot and targetRoot and Settings.FaceTarget then
                            myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                        end

                        -- Sort moves by Key (1 -> 2 -> 3 -> 4) for proper combo order
                        local moves = {}
                        for _, move in ipairs(myChar.Moveset:GetChildren()) do
                            local key = move:GetAttribute("Key")
                            if key then
                                table.insert(moves, {
                                    instance = move,
                                    key = tonumber(key) or key,
                                    name = move.Name
                                })
                            end
                        end
                        table.sort(moves, function(a, b)
                            return (tonumber(a.key) or 0) < (tonumber(b.key) or 0)
                        end)

                        local now = workspace:GetServerTimeNow()
                        for _, mData in ipairs(moves) do
                            local move = mData.instance
                            local key = mData.key
                            local readyAt = move:GetAttribute("ReadyAt") or 0
                            local lastUse = move:GetAttribute("LastUse") or 0
                            local cd = (typeof(move.Value) == "number" and move.Value > 0) and move.Value or 15

                            -- Multi-phase cooldown check (Ground-truth ReadyAt + GUI confirmation)
                            local isOffCooldown = false
                            if readyAt > 0 then
                                isOffCooldown = (now >= readyAt)
                            elseif lastUse > 0 then
                                isOffCooldown = (now - lastUse >= cd)
                            else
                                isOffCooldown = true -- Unused / fresh move
                            end

                            -- Cross-verify with GUI cooldown frame
                            pcall(function()
                                local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                                if mainGui and mainGui:FindFirstChild("Controls") and mainGui.Controls:FindFirstChild("Moveset") then
                                    local itemFrame = mainGui.Controls.Moveset:FindFirstChild(move.Name)
                                    if itemFrame and itemFrame:FindFirstChild("Cooldown") then
                                        if itemFrame.Cooldown.Size.Y.Scale > 0.05 then
                                            isOffCooldown = false
                                        end
                                    end
                                end
                            end)

                            if isOffCooldown then
                                -- Primary execution via ToolController
                                pcall(function()
                                    ToolController:UseKey(key, "Activated")
                                end)

                                -- GUI MouseButton1Down fallback via firesignal
                                pcall(function()
                                    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                                    if mainGui and mainGui:FindFirstChild("Controls") and mainGui.Controls:FindFirstChild("Moveset") then
                                        local itemFrame = mainGui.Controls.Moveset:FindFirstChild(move.Name)
                                        if itemFrame and itemFrame:FindFirstChild("ItemName") and firesignal then
                                            firesignal(itemFrame.ItemName.MouseButton1Down)
                                        end
                                    end
                                end)

                                task.wait(0.12)

                                pcall(function()
                                    ToolController:UseKey(key, "Deactivated")
                                end)
                                pcall(function()
                                    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                                    if mainGui and mainGui:FindFirstChild("Controls") and mainGui.Controls:FindFirstChild("Moveset") then
                                        local itemFrame = mainGui.Controls.Moveset:FindFirstChild(move.Name)
                                        if itemFrame and itemFrame:FindFirstChild("ItemName") and firesignal then
                                            firesignal(itemFrame.ItemName.MouseButton1Up)
                                        end
                                    end
                                end)

                                task.wait(0.25)
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.12)
    end
end)

-- Thread 3: Auto Awakening (Continuous State Monitor & Dual-Phase Trigger)
task.spawn(function()
    while true do
        if Settings.AutoAwakening then
            local myChar = LocalPlayer.Character
            if isAlive(myChar) and not myChar:GetAttribute("InUlt") then
                local ultMeter = LocalPlayer:GetAttribute("Ultimate") or 0
                local ult2Meter = myChar:GetAttribute("Ult2") or 0
                local isBarReady = false

                -- Check GUI Bar Ready indicator and visual fill
                pcall(function()
                    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                    if mainGui and mainGui:FindFirstChild("Controls") and mainGui.Controls:FindFirstChild("Ultimate") then
                        local bar = mainGui.Controls.Ultimate:FindFirstChild("Bar")
                        if bar then
                            local readyFrame = bar:FindFirstChild("Ready")
                            if readyFrame and readyFrame.Visible then
                                isBarReady = true
                            end
                            local fill = bar:FindFirstChild("Fill")
                            if fill and fill.Size.X.Scale >= 0.98 then
                                isBarReady = true
                            end
                        end
                    end
                end)

                -- Float tolerant check (>= 99.5 covers all full meters)
                if ultMeter >= 99.5 or ult2Meter >= 99.5 or isBarReady then
                    local ragdoll = myChar:GetAttribute("Ragdoll") or 0
                    local stun = myChar:GetAttribute("Stun") == true

                    -- Avoid dropped input if locked in hard-stun/knockdown
                    if ragdoll == 0 and not stun then
                        -- Method 1: ToolController direct Knit service invocation
                        pcall(function()
                            ToolController:UseSetService("Ultimate")
                        end)

                        -- Method 2: GUI Touch button trigger (firesignal)
                        pcall(function()
                            local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                            if mainGui and mainGui:FindFirstChild("Controls") and mainGui.Controls:FindFirstChild("Ultimate") then
                                local bar = mainGui.Controls.Ultimate:FindFirstChild("Bar")
                                local touch = bar and bar:FindFirstChild("Touch")
                                if touch and firesignal then
                                    firesignal(touch.MouseButton1Down)
                                    task.wait(0.08)
                                    firesignal(touch.MouseButton1Up)
                                end
                            end
                        end)

                        -- Method 3: Direct RemoteEvent fallback
                        pcall(function()
                            local moveset = myChar:GetAttribute("Moveset")
                            if moveset then
                                local serviceFolder = ServicesFolder:FindFirstChild(moveset .. "Service")
                                if serviceFolder and serviceFolder:FindFirstChild("RE") and serviceFolder.RE:FindFirstChild("Ultimate") then
                                    serviceFolder.RE.Ultimate:FireServer()
                                end
                            end
                        end)

                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- Thread 4: Auto Parry / Auto Block
task.spawn(function()
    while true do
        if Settings.AutoBlock then
            local myChar = LocalPlayer.Character
            if isAlive(myChar) then
                local target, dist = getClosestEnemy(Settings.AutoBlockRange)
                if target and dist <= Settings.AutoBlockRange then
                    local currentM1 = target:GetAttribute("CurrentM1") or 0
                    local isAttacking = target:FindFirstChild("Info") and target.Info:FindFirstChild("Attacking")
                    local lastM1 = target:GetAttribute("LastM1") or 0
                    local isRecentM1 = (workspace:GetServerTimeNow() - lastM1) < 0.4
                    
                    if currentM1 > 0 or isAttacking or isRecentM1 then
                        pcall(function()
                            ToolController:Block()
                            task.wait(0.35)
                            BlockService.Deactivated:Fire()
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
        task.wait(0.06)
    end
end)

-- Thread 5: Anti-Ragdoll (Native Attribute Integration)
task.spawn(function()
    while true do
        if Settings.AntiRagdoll then
            local myChar = LocalPlayer.Character
            if myChar then
                myChar:SetAttribute("NoRagdoll", true)
                myChar:SetAttribute("Ragdoll", 0)
                myChar:SetAttribute("Stun", false)
                
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                local root = myChar:FindFirstChild("HumanoidRootPart")
                if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    if root then
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        else
            local myChar = LocalPlayer.Character
            if myChar and myChar:GetAttribute("NoRagdoll") then
                myChar:SetAttribute("NoRagdoll", nil)
            end
        end
        task.wait(0.05)
    end
end)

-- Thread 6: Auto Respawn Engine (Event-Driven + Polling Fallback)
local function checkAndRespawn()
    if Settings.AutoRespawn then
        pcall(function()
            JoinRE.Respawn:FireServer()
        end)
    end
end

-- Event 1: GUI Respawn button visibility listener
pcall(function()
    local mainGui = LocalPlayer:WaitForChild("PlayerGui", 5):WaitForChild("Main", 5)
    if mainGui and mainGui:FindFirstChild("Respawn") then
        local respawnConn = mainGui.Respawn:GetPropertyChangedSignal("Visible"):Connect(function()
            if mainGui.Respawn.Visible and Settings.AutoRespawn then
                checkAndRespawn()
            end
        end)
        table.insert(Connections, respawnConn)
    end
end)

-- Event 2: Humanoid.Died & Dead attribute listeners
local function setupRespawnListeners(char)
    CurrentLockedTarget = nil
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local diedConn = hum.Died:Connect(function()
            CurrentLockedTarget = nil
            if Settings.AutoRespawn then
                task.wait(0.08)
                checkAndRespawn()
            end
        end)
        table.insert(Connections, diedConn)
    end
    local deadAttrConn = char:GetAttributeChangedSignal("Dead"):Connect(function()
        if char:GetAttribute("Dead") == true then
            CurrentLockedTarget = nil
            if Settings.AutoRespawn then
                task.wait(0.08)
                checkAndRespawn()
            end
        end
    end)
    table.insert(Connections, deadAttrConn)
end

if LocalPlayer.Character then
    setupRespawnListeners(LocalPlayer.Character)
end
local charAddedConn = LocalPlayer.CharacterAdded:Connect(setupRespawnListeners)
table.insert(Connections, charAddedConn)

-- Fallback polling loop (handles edge cases like void falling or nil character)
task.spawn(function()
    while true do
        if Settings.AutoRespawn then
            local myChar = LocalPlayer.Character
            local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            local isRespawnBtnVisible = mainGui and mainGui:FindFirstChild("Respawn") and mainGui.Respawn.Visible
            
            if not myChar or not myChar.Parent or (hum and hum.Health <= 0) or (myChar:GetAttribute("Dead") == true) or isRespawnBtnVisible then
                checkAndRespawn()
                task.wait(0.5)
            end
        end
        task.wait(0.25)
    end
end)

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- MOBILITY ENGINE (NATIVE SPEED ATTRIBUTE & DASH BYPASS)
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- Speed Boost using Game's Native Humanoid "Speed" Attribute
local function updateSpeedBoost()
    local myChar = LocalPlayer.Character
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.SpeedBoost then
            local mult = (Settings.WalkSpeed or 45) / 16
            hum:SetAttribute("Speed", mult)
        else
            hum:SetAttribute("Speed", nil)
        end
    end
end

local speedConn = RunService.Heartbeat:Connect(function()
    if Settings.SpeedBoost then
        local myChar = LocalPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            local targetMult = (Settings.WalkSpeed or 45) / 16
            if hum:GetAttribute("Speed") ~= targetMult then
                hum:SetAttribute("Speed", targetMult)
            end
        end
    end
end)
table.insert(Connections, speedConn)

-- Infinite Jump
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local myChar = LocalPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 52, root.AssemblyLinearVelocity.Z)
        end
    end
end)
table.insert(Connections, jumpConn)

-- Infinite Dash: Direct Controller Invocation on KeyPress 'Q'
local dashKeyConn = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Q and Settings.InfiniteDash then
        local myChar = LocalPlayer.Character
        if isAlive(myChar) and MovementController then
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            local camCF = workspace.CurrentCamera.CFrame
            local lookFlat = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
            local rightFlat = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
            local moveDir = hum and hum.MoveDirection or Vector3.zero
            
            local dir = "Front"
            if moveDir.Magnitude > 0.1 then
                local dotF = moveDir:Dot(lookFlat)
                local dotR = moveDir:Dot(rightFlat)
                if math.abs(dotF) > math.abs(dotR) then
                    dir = (dotF > 0) and "Front" or "Back"
                else
                    dir = (dotR > 0) and "Right" or "Left"
                end
            end
            
            -- Apply custom Dash multiplier
            if myChar:FindFirstChild("Info") then
                local mult = myChar.Info:FindFirstChild("DashMultiplier")
                if not mult then
                    mult = Instance.new("NumberValue")
                    mult.Name = "DashMultiplier"
                    mult.Parent = myChar.Info
                end
                mult.Value = Settings.DashPower or 2.5
            end
            
            -- Refresh evade meter
            myChar:SetAttribute("Evade", 50)
            
            -- Trigger dash directly
            pcall(function()
                MovementController:Dash(LocalPlayer, myChar, dir)
            end)
        end
    end
end)
table.insert(Connections, dashKeyConn)

-- Noclip Engine
local noclipConn = RunService.Stepped:Connect(function()
    if Settings.Noclip then
        local myChar = LocalPlayer.Character
        if myChar then
            for _, part in ipairs(myChar:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
table.insert(Connections, noclipConn)

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- WORLD & FARM AUTOMATION
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- Thread 6: Auto Collect Coins & Item Magnet
task.spawn(function()
    while true do
        if Settings.AutoCollectCoins or Settings.AutoCollectItems then
            local myChar = LocalPlayer.Character
            local myRoot = getRoot(myChar)
            if myRoot and workspace:FindFirstChild("Items") then
                for _, item in ipairs(workspace.Items:GetChildren()) do
                    if item:IsA("BasePart") and item.Position.Y < 1000 then
                        local isCoin = (item.Name == "Coin")
                        if (isCoin and Settings.AutoCollectCoins) or (not isCoin and Settings.AutoCollectItems) then
                            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                local originalCF = myRoot.CFrame
                                myRoot.CFrame = item.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.12)
                                prompt.HoldDuration = 0
                                pcall(function() fireproximityprompt(prompt) end)
                                task.wait(0.15)
                                myRoot.CFrame = originalCF
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Thread 7: ProximityPrompt Instant Aura
task.spawn(function()
    while true do
        if Settings.PromptAura then
            local myChar = LocalPlayer.Character
            local myRoot = getRoot(myChar)
            if myRoot then
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local parentPart = prompt.Parent
                        if parentPart and parentPart:IsA("BasePart") and parentPart.Position.Y < 1000 then
                            local dist = (parentPart.Position - myRoot.Position).Magnitude
                            if dist <= (Settings.PromptAuraRadius or 16) then
                                prompt.HoldDuration = 0
                                pcall(function() fireproximityprompt(prompt) end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- Thread 8: Player ESP & Overhead HUD
local function createOrUpdateESP(playerChar)
    if playerChar == LocalPlayer.Character or not isAlive(playerChar) then return end
    local root = getRoot(playerChar)
    local head = playerChar:FindFirstChild("Head")
    if not root or not head then return end

    -- 1. Chams Highlight
    if Settings.PlayerESP then
        local hl = ESPDrawings.Highlights[playerChar]
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = "XLuna_ESP"
            hl.FillColor = Color3.fromRGB(255, 45, 85)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.55
            hl.OutlineTransparency = 0
            hl.Adornee = playerChar
            hl.Parent = playerChar
            ESPDrawings.Highlights[playerChar] = hl
        end
    else
        if ESPDrawings.Highlights[playerChar] then
            pcall(function() ESPDrawings.Highlights[playerChar]:Destroy() end)
            ESPDrawings.Highlights[playerChar] = nil
        end
    end

    -- 2. Billboard Text
    local needsBillboard = (Settings.PlayerNames or Settings.MovesetESP or Settings.HealthESP)
    if needsBillboard then
        local bb = ESPDrawings.Billboards[playerChar]
        if not bb or not bb.Parent then
            bb = Instance.new("BillboardGui")
            bb.Name = "XLuna_HUD"
            bb.Adornee = head
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true

            local label = Instance.new("TextLabel", bb)
            label.Name = "Info"
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            bb.Parent = head
            ESPDrawings.Billboards[playerChar] = bb
        end

        local hum = playerChar:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        local maxHp = hum and math.floor(hum.MaxHealth) or 100
        local moveset = playerChar:GetAttribute("Moveset") or "Unknown"
        local dist = math.floor((root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)

        local line1 = Settings.PlayerNames and string.format("%s (%d studs)", playerChar.Name, dist) or ""
        local line2 = ""
        if Settings.MovesetESP and Settings.HealthESP then
            line2 = string.format("[%s]  HP: %d/%d", moveset, hp, maxHp)
        elseif Settings.MovesetESP then
            line2 = string.format("[%s]", moveset)
        elseif Settings.HealthESP then
            line2 = string.format("HP: %d/%d", hp, maxHp)
        end

        local text = line1 .. (line1 ~= "" and line2 ~= "" and "\n" or "") .. line2
        local lbl = bb:FindFirstChild("Info")
        if lbl then lbl.Text = text end
    else
        if ESPDrawings.Billboards[playerChar] then
            pcall(function() ESPDrawings.Billboards[playerChar]:Destroy() end)
            ESPDrawings.Billboards[playerChar] = nil
        end
    end
end

task.spawn(function()
    while true do
        if workspace:FindFirstChild("Characters") then
            for _, char in ipairs(workspace.Characters:GetChildren()) do
                createOrUpdateESP(char)
            end
        end
        task.wait(0.3)
    end
end)

-- Thread 9: Anti-AFK Engine
local afkConn = LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)
table.insert(Connections, afkConn)

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- CONFIG PROFILE STORAGE ENGINE (JSON PERSISTENCE)
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
local ConfigFolder = "XLunaHUB_JJS"
pcall(function()
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if not isfolder(ConfigFolder .. "/configs") then makefolder(ConfigFolder .. "/configs") end
end)

local function saveConfig(name)
    name = (name and name ~= "") and name or "default"
    local json = HttpService:JSONEncode(Settings)
    writefile(ConfigFolder .. "/configs/" .. name .. ".json", json)
end

local function loadConfig(name)
    name = (name and name ~= "") and name or "default"
    local path = ConfigFolder .. "/configs/" .. name .. ".json"
    if isfile(path) then
        local raw = readfile(path)
        local data = HttpService:JSONDecode(raw)
        if type(data) == "table" then
            for k, v in pairs(data) do
                Settings[k] = v
                if UIReferences[k] and UIReferences[k].Set then
                    pcall(function() UIReferences[k]:Set(v) end)
                end
            end
            updateSpeedBoost()
            return true
        end
    end
    return false
end

-- Cleanup Handler
getgenv().XLunaHUB_Cleanup = function()
    -- Restore original Hitbox and Target functions
    if HitboxController and originalSphereHitbox then
        HitboxController.SphereHitbox = originalSphereHitbox
    end
    if ToolController and originalGetTarget then
        ToolController.GetTarget = originalGetTarget
    end
    CurrentLockedTarget = nil

    -- Restore Speed attribute
    pcall(function()
        local myChar = LocalPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetAttribute("Speed", nil)
        end
        if myChar and myChar:GetAttribute("NoRagdoll") then
            myChar:SetAttribute("NoRagdoll", nil)
        end
    end)

    -- Disconnect listeners
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)

    -- Destroy ESP
    for _, h in pairs(ESPDrawings.Highlights) do pcall(function() h:Destroy() end) end
    for _, b in pairs(ESPDrawings.Billboards) do pcall(function() b:Destroy() end) end
    table.clear(ESPDrawings.Highlights)
    table.clear(ESPDrawings.Billboards)

    getgenv().XLunaHUB_Loaded = nil
end

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- WINDUI USER INTERFACE DEFINITION
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Explicit GUI Parent Anchor
local guiParent = gethui and gethui() or game:GetService("CoreGui")
WindUI:SetParent(guiParent)

local Window = WindUI:CreateWindow({
    Title = "Jujutsu Shenanigans",
    Icon = "swords",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_JJS",
    Size = UDim2.fromOffset(620, 490),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "swords",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("7928CA"),
            Color3.fromHex("FF0080")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    }
})

-- Single-State LeftControl Keybind Toggle Guard
local isToggling = false
local keyToggleConn = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
        if isToggling then return end
        isToggling = true
        pcall(function()
            Window:Toggle()
        end)
        task.wait(0.25)
        isToggling = false
    end
end)
table.insert(Connections, keyToggleConn)

-- TAB 1: COMBAT
local TabCombat = Window:Tab({ Title = "Combat", Icon = "swords" })

local SecKillaura = TabCombat:Section({ Title = "Killaura / Auto Attack", Opened = true })
UIReferences.Killaura = SecKillaura:Toggle({
    Title = "Auto Attack (Killaura)",
    Desc = "Rapidly hits nearest player with M1 combo sequence",
    Value = false,
    Callback = function(val)
        Settings.Killaura = val
        if val then
            WindUI:Notify({ Title = "Killaura", Content = "Auto Attack Active", Duration = 2 })
        end
    end
})
UIReferences.AttackRange = SecKillaura:Slider({
    Title = "Attack Range (Studs)",
    Value = { Min = 5, Max = 200, Default = 35 },
    Step = 1,
    Callback = function(val) Settings.AttackRange = val end
})
UIReferences.AttackDelay = SecKillaura:Slider({
    Title = "Attack Cooldown (Seconds)",
    Value = { Min = 0.1, Max = 0.6, Default = 0.22 },
    Step = 0.02,
    Callback = function(val) Settings.AttackDelay = val end
})
UIReferences.FaceTarget = SecKillaura:Toggle({
    Title = "Face Target Automatically",
    Value = true,
    Callback = function(val) Settings.FaceTarget = val end
})
UIReferences.TeleportBehind = SecKillaura:Toggle({
    Title = "Teleport Behind Target (Shadow Step)",
    Value = false,
    Callback = function(val) Settings.TeleportBehind = val end
})

local SecReach = TabCombat:Section({ Title = "Hitbox Expander" })
UIReferences.HitboxExpander = SecReach:Toggle({
    Title = "Hitbox Expander (Reach)",
    Desc = "Registers hits on any player within reach radius",
    Value = false,
    Callback = function(val)
        Settings.HitboxExpander = val
        if val then
            WindUI:Notify({ Title = "Reach", Content = "Hitbox Expander Enabled", Duration = 2 })
        end
    end
})
UIReferences.HitboxReach = SecReach:Slider({
    Title = "Reach Distance (Studs)",
    Value = { Min = 10, Max = 200, Default = 50 },
    Step = 1,
    Callback = function(val) Settings.HitboxReach = val end
})

local SecSkills = TabCombat:Section({ Title = "Combos & Defense" })
UIReferences.StickyTarget = SecSkills:Toggle({
    Title = "Sticky Target Lock",
    Desc = "Focuses single enemy until knockout/death before switching",
    Value = true,
    Callback = function(val)
        Settings.StickyTarget = val
        if not val then
            CurrentLockedTarget = nil
        end
    end
})
UIReferences.AutoSkills = SecSkills:Toggle({
    Title = "Auto Skill Rotator",
    Desc = "Casts character abilities 1-4 when in range and off cooldown",
    Value = false,
    Callback = function(val) Settings.AutoSkills = val end
})
UIReferences.SkillRange = SecSkills:Slider({
    Title = "Skill Cast Range (Studs)",
    Value = { Min = 10, Max = 150, Default = 65 },
    Step = 1,
    Callback = function(val) Settings.SkillRange = val end
})
UIReferences.AutoAwakening = SecSkills:Toggle({
    Title = "Auto Awakening / Mode",
    Desc = "Automatically activates Ultimate as soon as meter reaches 100",
    Value = false,
    Callback = function(val) Settings.AutoAwakening = val end
})
UIReferences.AutoBlock = SecSkills:Toggle({
    Title = "Auto Parry / Auto Block",
    Desc = "Guards automatically when enemy swings in close proximity",
    Value = false,
    Callback = function(val) Settings.AutoBlock = val end
})
UIReferences.AutoBlockRange = SecSkills:Slider({
    Title = "Block Reaction Distance",
    Value = { Min = 6, Max = 20, Default = 14 },
    Step = 1,
    Callback = function(val) Settings.AutoBlockRange = val end
})
UIReferences.AntiRagdoll = SecSkills:Toggle({
    Title = "Anti-Ragdoll / Quick Recovery",
    Desc = "Native attribute bypass preventing ragdoll knockdown",
    Value = false,
    Callback = function(val)
        Settings.AntiRagdoll = val
        if val then
            WindUI:Notify({ Title = "Anti-Ragdoll", Content = "Quick Recovery Active", Duration = 2 })
        end
    end
})
UIReferences.AutoRespawn = SecSkills:Toggle({
    Title = "Auto Respawn",
    Desc = "Instantly respawns character upon death or knockout",
    Value = false,
    Callback = function(val)
        Settings.AutoRespawn = val
        if val then
            WindUI:Notify({ Title = "Auto Respawn", Content = "Auto Respawn Active", Duration = 2 })
            local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            if mainGui and mainGui:FindFirstChild("Respawn") and mainGui.Respawn.Visible then
                pcall(function() JoinRE.Respawn:FireServer() end)
            end
        end
    end
})

-- TAB 2: MOVEMENT
local TabMovement = Window:Tab({ Title = "Movement", Icon = "wind" })

local SecDash = TabMovement:Section({ Title = "Dash & Speed", Opened = true })
UIReferences.InfiniteDash = SecDash:Toggle({
    Title = "Infinite Dash (Tap Q)",
    Desc = "Bypasses 2s cooldown for continuous high-speed dodging",
    Value = false,
    Callback = function(val)
        Settings.InfiniteDash = val
        if val then
            WindUI:Notify({ Title = "Dash", Content = "Infinite Dash Active (Press Q)", Duration = 2 })
        end
    end
})
UIReferences.DashPower = SecDash:Slider({
    Title = "Dash Force Multiplier",
    Value = { Min = 1, Max = 5, Default = 2.5 },
    Step = 0.5,
    Callback = function(val) Settings.DashPower = val end
})
UIReferences.SpeedBoost = SecDash:Toggle({
    Title = "Speed Boost",
    Desc = "Native humanoid speed scaling with smooth physics",
    Value = false,
    Callback = function(val)
        Settings.SpeedBoost = val
        updateSpeedBoost()
        if val then
            WindUI:Notify({ Title = "Speed", Content = "Speed Boost Active", Duration = 2 })
        end
    end
})
UIReferences.WalkSpeed = SecDash:Slider({
    Title = "Movement Speed (Studs/sec)",
    Value = { Min = 16, Max = 80, Default = 45 },
    Step = 2,
    Callback = function(val)
        Settings.WalkSpeed = val
        updateSpeedBoost()
    end
})

local SecAir = TabMovement:Section({ Title = "Air Mobility & Collision" })
UIReferences.InfiniteJump = SecAir:Toggle({
    Title = "Infinite Jump",
    Desc = "Tap Space to hop continuously in the air",
    Value = false,
    Callback = function(val) Settings.InfiniteJump = val end
})
UIReferences.Noclip = SecAir:Toggle({
    Title = "Noclip (Pass Walls / Domain)",
    Value = false,
    Callback = function(val) Settings.Noclip = val end
})

-- TAB 3: FARMING & WORLD
local TabFarm = Window:Tab({ Title = "World & Farm", Icon = "coins" })

local SecFarm = TabFarm:Section({ Title = "Item & Coin Automation", Opened = true })
UIReferences.AutoCollectCoins = SecFarm:Toggle({
    Title = "Auto Collect Coins",
    Desc = "Sweeps and claims ground coins across the map",
    Value = false,
    Callback = function(val)
        Settings.AutoCollectCoins = val
        if val then
            WindUI:Notify({ Title = "Coins", Content = "Auto Coin Collector Active", Duration = 2 })
        end
    end
})
UIReferences.AutoCollectItems = SecFarm:Toggle({
    Title = "Auto Collect Dropped Weapons / Items",
    Desc = "Picks up RPG, TNT, Soda, Crowbars, Transfigured Humans",
    Value = false,
    Callback = function(val) Settings.AutoCollectItems = val end
})
UIReferences.PromptAura = SecFarm:Toggle({
    Title = "ProximityPrompt Aura (Fast Interact)",
    Desc = "Instantly triggers vending machines, arcade games, doors, buttons",
    Value = false,
    Callback = function(val) Settings.PromptAura = val end
})
UIReferences.PromptAuraRadius = SecFarm:Slider({
    Title = "Interact Aura Radius",
    Value = { Min = 6, Max = 30, Default = 16 },
    Step = 1,
    Callback = function(val) Settings.PromptAuraRadius = val end
})

local SecWorldActions = TabFarm:Section({ Title = "World Quick Actions" })
SecWorldActions:Button({
    Title = "Call Train (Station Request)",
    Callback = function()
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.ObjectText == "Station Request" then
                pcall(function() fireproximityprompt(prompt) end)
                WindUI:Notify({ Title = "Station", Content = "Train request sent!", Duration = 3 })
                break
            end
        end
    end
})
SecWorldActions:Button({
    Title = "Turn the Crane",
    Callback = function()
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.ObjectText == "Crane Control" then
                pcall(function() fireproximityprompt(prompt) end)
                WindUI:Notify({ Title = "Crane", Content = "Crane turned!", Duration = 3 })
                break
            end
        end
    end
})

local SecChar = TabFarm:Section({ Title = "Character Switcher" })
local characterList = {
    "Gojo", "Itadori", "Hakari", "Megumi", "Mahito", "Choso", "Todo", "Hiromi",
    "Yuta", "Mechamaru", "Naoya", "Nanami", "Hanami", "Ryu", "Reggie", "Toji",
    "Locust", "Yuki", "Charles", "Haruta", "MeiMei", "Kurourushi", "Uro", "Heian", "Goku", "Mokou"
}
SecChar:Dropdown({
    Title = "Select Character",
    Values = characterList,
    Value = "Gojo",
    Callback = function(sel) Settings.SelectedCharacter = sel end
})
SecChar:Button({
    Title = "Switch Character Now",
    Callback = function()
        pcall(function()
            JoinRE.Change:FireServer(Settings.SelectedCharacter)
            WindUI:Notify({ Title = "Character Switch", Content = "Switched to: " .. tostring(Settings.SelectedCharacter), Duration = 3 })
        end)
    end
})
SecChar:Button({
    Title = "Instant Respawn / Reset",
    Callback = function()
        pcall(function()
            JoinRE.Respawn:FireServer()
        end)
    end
})

-- TAB 4: VISUALS
local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })

local SecESP = TabVisuals:Section({ Title = "Player ESP", Opened = true })
UIReferences.PlayerESP = SecESP:Toggle({
    Title = "Chams / Highlight ESP",
    Value = false,
    Callback = function(val)
        Settings.PlayerESP = val
        if not val then
            for _, hl in pairs(ESPDrawings.Highlights) do pcall(function() hl:Destroy() end) end
            table.clear(ESPDrawings.Highlights)
        end
    end
})
UIReferences.PlayerNames = SecESP:Toggle({
    Title = "Show Player Names & Distance",
    Value = false,
    Callback = function(val)
        Settings.PlayerNames = val
        if not val and not Settings.MovesetESP and not Settings.HealthESP then
            for _, bb in pairs(ESPDrawings.Billboards) do pcall(function() bb:Destroy() end) end
            table.clear(ESPDrawings.Billboards)
        end
    end
})
UIReferences.MovesetESP = SecESP:Toggle({
    Title = "Show Character Moveset Tag",
    Value = false,
    Callback = function(val) Settings.MovesetESP = val end
})
UIReferences.HealthESP = SecESP:Toggle({
    Title = "Show Health Numbers",
    Value = false,
    Callback = function(val) Settings.HealthESP = val end
})

-- TAB 5: CONFIG & SETTINGS
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

local SecAFK = TabConfig:Section({ Title = "Anti AFK", Opened = true })
UIReferences.AntiAFK = SecAFK:Toggle({
    Title = "Anti-AFK (Prevent 20-min Kick)",
    Value = false,
    Callback = function(val)
        Settings.AntiAFK = val
        if val then
            WindUI:Notify({ Title = "Anti-AFK", Content = "Anti-AFK active", Duration = 3 })
        end
    end
})

local SecProfile = TabConfig:Section({ Title = "Profile Management" })
local currentConfigName = "default"
SecProfile:Input({
    Title = "Configuration Profile Name",
    Value = "default",
    Placeholder = "Enter name...",
    Callback = function(text) currentConfigName = text end
})
SecProfile:Button({
    Title = "Save Current Config",
    Callback = function()
        saveConfig(currentConfigName)
        WindUI:Notify({ Title = "Config", Content = "Successfully saved: " .. currentConfigName, Duration = 3 })
    end
})
SecProfile:Button({
    Title = "Load Selected Config",
    Callback = function()
        local ok = loadConfig(currentConfigName)
        if ok then
            WindUI:Notify({ Title = "Config", Content = "Loaded: " .. currentConfigName, Duration = 3 })
        else
            WindUI:Notify({ Title = "Config", Content = "File not found: " .. currentConfigName, Duration = 3 })
        end
    end
})

local SecUnload = TabConfig:Section({ Title = "Shutdown" })
SecUnload:Button({
    Title = "Unload / Destroy Script",
    Callback = function()
        if getgenv().XLunaHUB_Cleanup then
            getgenv().XLunaHUB_Cleanup()
        end
        Window:Destroy()
    end
})

-- Default to Combat Tab on Launch
pcall(function()
    TabCombat:Select()
end)

-- Notification on Launch
WindUI:Notify({
    Title = "XLunaHUB",
    Content = "Jujutsu Shenanigans Suite Loaded! Press LeftControl to toggle UI.",
    Duration = 5,
    Icon = "swords"
})
