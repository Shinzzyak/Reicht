-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ============================================================================
    KING LEGACY - AUTONOMOUS MASTER AUTOMATION
    Architecture: WindUI v1.6+ | Universal English | Zero AI Slop
    Engine: Luau Client-Server RPC, Remote Automation, Safe Tween Movement
    Game: King Legacy (Sea King Games) | Max Level 5450
    ============================================================================
--]]

--  SERVICES
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

--  CLONEREF & CLEANUP GUARDS
if cloneref then
    local _origCloneref = cloneref
    cloneref = function(inst)
        if not inst then return inst end
        local ok, res = pcall(_origCloneref, inst)
        return ok and res or inst
    end
end

local function CleanOldWindUI()
    pcall(function()
        local h = (gethui and gethui()) or CoreGui or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui"))
        if h then
            for _, c in ipairs(h:GetChildren()) do
                if c.Name:find("WindUI") or c.Name:find("KingLegacyFloatingToggle") then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end)
    task.wait(0.1)
end
CleanOldWindUI()

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui", 30)

--  ANTI-AFK / ANTI-IDLE (ALWAYS ACTIVE IN BACKGROUND)
pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

--  REMOTES RESOLVER
local Chest = ReplicatedStorage:WaitForChild("Chest", 30)
local RemotesEvents = Chest:WaitForChild("Remotes"):WaitForChild("Events")
local RemotesFunctions = Chest:WaitForChild("Remotes"):WaitForChild("Functions")

local QuestRemote       = RemotesFunctions:WaitForChild("Quest")
local SkillActionRemote  = RemotesFunctions:WaitForChild("SkillAction")
local KenEventRemote    = RemotesFunctions:WaitForChild("KenEvent")
local EtcFunctionRemote = RemotesFunctions:WaitForChild("EtcFunction")

local ArmamentRemote    = RemotesEvents:WaitForChild("Armament")
local TurnOffKenRemote  = RemotesEvents:WaitForChild("TurnOffKenHaki")
local CollectFruitRemote= RemotesEvents:WaitForChild("CollectFruit")

--  GLOBAL CONFIG & STATE (DEFAULT ALL OFF - SOP RULE 8)
local CONFIG = {
    -- Farm
    AutoFarmLevel     = false,
    FastAttack        = false,
    AttackDelay       = 0.18,
    BringMobs         = false,
    BringRadius       = 250,
    FarmDistance      = 2.5,
    SelectedWeapon    = "Combat", -- "Combat", "Sword", "Fruit"

    -- Bosses
    AutoFarmBoss      = false,
    SelectedBoss      = "Smoky",

    -- Fruits & Items
    AutoGrabFruits    = false,
    AutoStoreFruit    = false,

    -- Visuals / ESP
    PlayerESP         = false,
    BossESP           = false,
    MonsterESP        = false,
    FruitESP          = false,

    -- Player & Combat
    AutoBuso          = false,
    AutoKen           = false,
    AutoStats         = false,
    StatTarget        = "Melee", -- "Melee", "Defense", "Sword", "Fruit"
    NoClip            = false,
    WaterWalk         = false,
    InfiniteJump      = false,
    TweenSpeed        = 260,
}

local STATE = {
    CurrentTween = nil,
    IsTweening   = false,
    FarmBodyVel  = nil,
    FloatingBtn  = nil,
    WindowVisible= true,
}

_G.KL_CONFIG = CONFIG
_G.KL_STATE = STATE
if getgenv then
    getgenv()._KL_CONFIG = CONFIG
    getgenv()._KL_STATE = STATE
end

--  LEVEL & QUEST ROUTING TABLE (KING LEGACY FIRST SEA)
local ROUTING_TABLE = {
    { min = 1, max = 9, quest = "Kill 4 Soldiers", mob = "Soldier [Lv. 1]", pos = Vector3.new(-1865, 50, -4608) },
    { min = 10, max = 49, quest = "Kill 5 Clown Pirates", mob = "Clown Pirate [Lv. 10]", pos = Vector3.new(-1871, 50, -4465) },
    { min = 50, max = 99, quest = "Kill 6 Clown Swordman", mob = "Clown Swordman [Lv. 50]", pos = Vector3.new(-729, 43, -3445) },
    { min = 100, max = 179, quest = "Kill 4 Commander", mob = "Commander [Lv. 100]", pos = Vector3.new(-2270, 49, -2594) },
    { min = 180, max = 249, quest = "Kill 4 Fighter Fishmans", mob = "Fighter Fishman [Lv. 180]", pos = Vector3.new(-749, 23, -1469) },
    { min = 250, max = 399, quest = "Kill 4 Trainer Chef", mob = "Trainer Chef [Lv. 250]", pos = Vector3.new(-4139, 15, -3274) },
    { min = 400, max = 574, quest = "Kill 5 Snow Soldier", mob = "Snow Soldier [Lv. 400]", pos = Vector3.new(-5362, 28, -1210) },
    { min = 575, max = 674, quest = "Kill 4 Sand Bandit", mob = "Sand Bandit [Lv. 575]", pos = Vector3.new(-2892, 41, -703) },
    { min = 675, max = 799, quest = "Kill 4 Desert Marauder", mob = "Desert Marauder [Lv. 675]", pos = Vector3.new(-2735, 41, -641) },
    { min = 800, max = 899, quest = "Kill 4 Sky Soldier", mob = "Sky Soldier [Lv. 800]", pos = Vector3.new(-4307, 383, 1391) },
    { min = 900, max = 999, quest = "Kill 4 Cloud Warrior", mob = "Cloud Warrior [Lv. 900]", pos = Vector3.new(-4472, 383, 1364) },
    { min = 1000, max = 1049, quest = "Kill 4 Elite Soldiers", mob = "Elite Soldier [Lv. 1000]", pos = Vector3.new(1616, 17, 953) },
    { min = 1050, max = 1199, quest = "Kill 4 High-class Soldier", mob = "High-class Soldier [Lv. 1050]", pos = Vector3.new(1488, 17, 760) },
    { min = 1200, max = 1349, quest = "Kill 4 Naval personnel", mob = "Naval personnel [Lv. 1200]", pos = Vector3.new(-1312, 20, 2305) },
    { min = 1350, max = 1399, quest = "Kill 4 Nautical soldier", mob = "Nautical soldier [Lv. 1350]", pos = Vector3.new(-1017, 20, 2248) },
    { min = 1400, max = 1499, quest = "Kill 4 Naval soldier", mob = "Naval soldier [Lv. 1400]", pos = Vector3.new(-1387, 7, 2564) },
    { min = 1500, max = 1549, quest = "Kill 5 Zombies", mob = "Zombie [Lv. 1500]", pos = Vector3.new(-2684, 15, 4207) },
    { min = 1550, max = 1599, quest = "Kill 4 Elite Zombies", mob = "Elite Zombie [Lv. 1550]", pos = Vector3.new(-2829, 15, 4084) },
    { min = 1600, max = 1699, quest = "Kill 4 Revenant", mob = "Revenant [Lv. 1600]", pos = Vector3.new(-2917, 20, 4239) },
    { min = 1700, max = 1749, quest = "Kill 4 New World Pirate", mob = "New World Pirate [Lv. 1700]", pos = Vector3.new(2322, 55, -1609) },
    { min = 1750, max = 1799, quest = "Kill 4 Cutlass Pirates", mob = "Cutlass Pirate [Lv. 1750]", pos = Vector3.new(2087, 6, -1862) },
    { min = 1800, max = 1999, quest = "Kill 4 Rear Admiral", mob = "Rear Admiral [Lv. 1800]", pos = Vector3.new(2337, 55, -2242) },
    { min = 2000, max = 2149, quest = "Kill 4 Fishmans", mob = "Fishman [Lv. 2000]", pos = Vector3.new(-1537, 40, 6125) },
    { min = 2150, max = 5450, quest = "Kill 4 Soldier Fishman", mob = "Soldier Fishman [Lv. 2150]", pos = Vector3.new(-1741, 45, 6691) },
}

local BOSS_TABLE = {
    ["Smoky [Lv. 20]"]              = { name = "Smoky", pos = Vector3.new(-2109.3, 49.6, -4787.5) },
    ["Tashi [Lv. 30]"]              = { name = "Tashi", pos = Vector3.new(-2361.4, 50.0, -4561.2) },
    ["The Clown [Lv. 75]"]          = { name = "The Clown", pos = Vector3.new(-444.9, 66.0, -3544.2) },
    ["Captain [Lv. 120]"]           = { name = "Captain", pos = Vector3.new(-2189.2, 49.2, -2467.2) },
    ["The Barbaric [Lv. 145]"]      = { name = "The Barbaric", pos = Vector3.new(-2323.6, 102.9, -2472.0) },
    ["Karate Fishman [Lv. 200]"]    = { name = "Karate Fishman", pos = Vector3.new(-872.9, 23.1, -1508.8) },
    ["Dark Leg [Lv. 300]"]          = { name = "Dark Leg", pos = Vector3.new(-4211.6, 18.0, -2892.8) },
    ["King Snow [Lv. 450]"]         = { name = "King Snow", pos = Vector3.new(-5420.1, 28.9, -1515.3) },
    ["Little Dear [Lv. 500]"]       = { name = "Little Dear", pos = Vector3.new(-5319.4, 22.6, -1103.7) },
    ["Candle Man [Lv. 525]"]        = { name = "Candle Man", pos = Vector3.new(-2931.9, 92.1, -500.1) },
    ["Bomb Man [Lv. 625]"]          = { name = "Bomb Man", pos = Vector3.new(-3052.8, 92.1, -634.3) },
    ["King of Sand [Lv. 725]"]      = { name = "King of Sand", pos = Vector3.new(-3091.4, 97.0, -475.7) },
    ["Ball Man [Lv. 850]"]          = { name = "Ball Man", pos = Vector3.new(-4864.7, 441.4, 1332.2) },
    ["Rumble Man [Lv. 950]"]        = { name = "Rumble Man", pos = Vector3.new(-4813.4, 441.4, 1190.8) },
    ["Leader [Lv. 1100]"]           = { name = "Leader", pos = Vector3.new(1688.2, 17.9, 741.5) },
    ["Pasta [Lv. 1150]"]            = { name = "Pasta", pos = Vector3.new(1850.5, 43.8, 869.8) },
    ["Wolf [Lv. 1250]"]             = { name = "Wolf", pos = Vector3.new(-1422.9, 21.0, 2106.9) },
    ["Giraffe [Lv. 1300]"]          = { name = "Giraffe", pos = Vector3.new(-1080.1, 21.0, 2059.8) },
    ["Leo [Lv. 1450]"]              = { name = "Leo", pos = Vector3.new(-1159.8, 7.7, 2521.1) },
    ["Shadow Master [Lv. 1650]"]    = { name = "Shadow Master", pos = Vector3.new(-2760.6, 20.1, 4368.9) },
    ["True Karate Fishman [Lv. 1850]"] = { name = "True Karate Fishman", pos = Vector3.new(2334.5, 55.1, -1937.8) },
    ["Quake Woman [Lv. 1925]"]      = { name = "Quake Woman", pos = Vector3.new(2205.4, 6.3, -1937.8) },
    ["Combat Fishman [Lv. 2050]"]   = { name = "Combat Fishman", pos = Vector3.new(-1967.5, 40.5, 6140.9) },
    ["Sword Fishman [Lv. 2100]"]    = { name = "Sword Fishman", pos = Vector3.new(-1498.5, 40.5, 6687.8) },
    ["Seasoned Fishman [Lv. 2200]"] = { name = "Seasoned Fishman", pos = Vector3.new(-1865.6, 45.3, 6725.7) },
    ["Expert Swordman [Lv. 3000]"]  = { name = "Expert Swordman", pos = Vector3.new(4236.7, 37.9, -3796.2) },
}

local ISLAND_LOCATIONS = {
    ["Starter Island"]      = Vector3.new(-2170, 45, -4432),
    ["Pirate Island"]       = Vector3.new(-620, 20, -3256),
    ["Soldier Town"]        = Vector3.new(-2340, 20, -2414),
    ["Shark Island"]        = Vector3.new(-502, 65, -1480),
    ["Chef Ship"]           = Vector3.new(-4456, 31, -2962),
    ["Snow Island"]         = Vector3.new(-5302, 41, -1441),
    ["Desert Island"]       = Vector3.new(-2999, 112, -443),
    ["Skyland"]             = Vector3.new(-4901, 464, 1258),
    ["Bubbleland"]          = Vector3.new(1872, 20, 926),
    ["Lobby Island"]        = Vector3.new(-1190, 42, 2106),
    ["Zombie Island"]       = Vector3.new(-2945, 20, 4445),
    ["War Island"]          = Vector3.new(2480, 72, -2046),
    ["Fishland"]            = Vector3.new(-1737, 20, 6402),
    ["Dungeon Island"]      = Vector3.new(-4612, 30, -6010),
    ["Stone Arena"]         = Vector3.new(4211, 20, -3824),
}

--  HELPER FUNCTIONS
local function GetPlayerLevel()
    local ps = LP:FindFirstChild("PlayerStats")
    local lvl = ps and ps:FindFirstChild("lvl")
    return (lvl and tonumber(lvl.Value)) or 1
end

local function GetAppropriateQuest(level)
    for _, q in ipairs(ROUTING_TABLE) do
        if level >= q.min and level <= q.max then
            return q
        end
    end
    return ROUTING_TABLE[#ROUTING_TABLE]
end

local function HasActiveQuest()
    local cq = LP:FindFirstChild("CurrentQuest")
    return cq and cq.Value ~= ""
end

local function EquipDesiredWeapon()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then return nil end

    local targetTool = nil
    if CONFIG.SelectedWeapon == "Combat" then
        targetTool = char:FindFirstChild("None") or LP.Backpack:FindFirstChild("None")
    elseif CONFIG.SelectedWeapon == "Sword" then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name ~= "None" and not t.Name:lower():find("fruit") then
                targetTool = t
                break
            end
        end
        if not targetTool then
            for _, t in ipairs(LP.Backpack:GetChildren()) do
                if t:IsA("Tool") and t.Name ~= "None" and not t.Name:lower():find("fruit") then
                    targetTool = t
                    break
                end
            end
        end
    elseif CONFIG.SelectedWeapon == "Fruit" then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("fruit") then
                targetTool = t
                break
            end
        end
        if not targetTool then
            for _, t in ipairs(LP.Backpack:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("fruit") then
                    targetTool = t
                    break
                end
            end
        end
    end

    targetTool = targetTool or char:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChildOfClass("Tool")

    if targetTool and targetTool.Parent ~= char then
        hum:EquipTool(targetTool)
    end
    return targetTool
end

--  SAFE TWEENING (NOCLIP + VELOCITY HOLD)
local function SafeStopTween()
    if STATE.CurrentTween then
        pcall(function() STATE.CurrentTween:Cancel() end)
        STATE.CurrentTween = nil
    end
    STATE.IsTweening = false
    if STATE.FarmBodyVel then
        pcall(function() STATE.FarmBodyVel:Destroy() end)
        STATE.FarmBodyVel = nil
    end
end

local function SafeTweenTo(targetPos, speedOverride)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= 15 then
        hrp.CFrame = CFrame.new(targetPos)
        return true
    end

    local speed = speedOverride or CONFIG.TweenSpeed
    local duration = math.clamp(dist / speed, 0.2, 35)

    SafeStopTween()
    STATE.IsTweening = true

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e6, 9e6, 9e6)
    bv.Parent = hrp
    STATE.FarmBodyVel = bv

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(targetPos) })
    STATE.CurrentTween = tw
    tw:Play()

    local finished = false
    local conn
    conn = tw.Completed:Connect(function()
        finished = true
        if conn then conn:Disconnect() end
    end)

    while not finished and STATE.IsTweening do
        task.wait(0.1)
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            break
        end
    end

    SafeStopTween()
    return true
end

--  NOCLIP RUNTIME LOOP
RunService.Stepped:Connect(function()
    if CONFIG.NoClip or STATE.IsTweening or CONFIG.AutoFarmLevel or CONFIG.AutoFarmBoss then
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

--  INFINITE JUMP (GEPPO)
UserInputService.JumpRequest:Connect(function()
    if CONFIG.InfiniteJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--  WATER WALK
local WaterWalkPart = nil
RunService.Heartbeat:Connect(function()
    if CONFIG.WaterWalk then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not WaterWalkPart or not WaterWalkPart.Parent then
                WaterWalkPart = Instance.new("Part")
                WaterWalkPart.Name = "SafeWaterWalkSurface"
                WaterWalkPart.Size = Vector3.new(20, 1, 20)
                WaterWalkPart.Anchored = true
                WaterWalkPart.Transparency = 1
                WaterWalkPart.CanCollide = true
                WaterWalkPart.Parent = workspace
            end
            WaterWalkPart.CFrame = CFrame.new(hrp.Position.X, -0.5, hrp.Position.Z)
        end
    else
        if WaterWalkPart then
            pcall(function() WaterWalkPart:Destroy() end)
            WaterWalkPart = nil
        end
    end
end)

--  FAST ATTACK & HIT SIMULATION
local function ExecuteFastAttack(targetMob)
    EquipDesiredWeapon()

    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local renv = getrenv and getrenv()
            if renv and renv._G then
                renv._G.MouseHit = targetMob.HumanoidRootPart.CFrame
            end
        end)
    end

    -- 1. Fighting Style remote M1
    pcall(function()
        SkillActionRemote:InvokeServer("FS_None_M1")
    end)

    -- 2. Virtual click for tool swings
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(500, 500))
    end)
end

--  MOB MAGNET / BRING MOBS
local function BringNearbyMobs(centerPos, mobName)
    if not CONFIG.BringMobs then return end
    local monFolder = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Mon")
    if not monFolder then return end

    for _, enemy in ipairs(monFolder:GetChildren()) do
        if enemy.Name == mobName then
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if eHrp and eHum and eHum.Health > 0 then
                local dist = (eHrp.Position - centerPos).Magnitude
                if dist <= CONFIG.BringRadius and dist > 3 then
                    eHrp.CanCollide = false
                    eHrp.CFrame = CFrame.new(centerPos + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2)))
                    eHum.WalkSpeed = 0
                end
            end
        end
    end
end

-- ============================================================================
-- BACKGROUND AUTOMATION LOOPS
-- ============================================================================

-- 1. AUTO FARM LEVEL
task.spawn(function()
    while true do
        task.wait(0.2)
        if CONFIG.AutoFarmLevel then
            local pLvl = GetPlayerLevel()
            local questData = GetAppropriateQuest(pLvl)

            -- Check active quest
            if not HasActiveQuest() then
                pcall(function()
                    QuestRemote:InvokeServer("take", questData.quest)
                end)
                task.wait(0.5)
            else
                -- Find target mob in Monster.Mon
                local monFolder = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Mon")
                local targetMob = nil
                if monFolder then
                    for _, enemy in ipairs(monFolder:GetChildren()) do
                        if enemy.Name == questData.mob then
                            local hum = enemy:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                targetMob = enemy
                                break
                            end
                        end
                    end
                end

                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    local char = LP.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        local attackPos = (mobHrp.CFrame * CFrame.new(0, 0, 2.5)).Position
                        local dist = (hrp.Position - attackPos).Magnitude

                        if dist > 25 then
                            SafeTweenTo(attackPos)
                        else
                            hrp.CFrame = CFrame.lookAt(attackPos, mobHrp.Position)
                            if not STATE.FarmBodyVel or not STATE.FarmBodyVel.Parent then
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = Vector3.zero
                                bv.MaxForce = Vector3.new(9e6, 9e6, 9e6)
                                bv.Parent = hrp
                                STATE.FarmBodyVel = bv
                            end

                            BringNearbyMobs(mobHrp.Position, questData.mob)
                            ExecuteFastAttack(targetMob)
                            task.wait(CONFIG.AttackDelay)
                        end
                    end
                else
                    -- Move to mob spawn area
                    SafeTweenTo(questData.pos + Vector3.new(0, 3, 0))
                    task.wait(0.5)
                end
            end
        else
            if STATE.FarmBodyVel then
                pcall(function() STATE.FarmBodyVel:Destroy() end)
                STATE.FarmBodyVel = nil
            end
        end
    end
end)

-- 2. AUTO FARM BOSS
task.spawn(function()
    while true do
        task.wait(0.3)
        if CONFIG.AutoFarmBoss then
            local bossData = BOSS_TABLE[CONFIG.SelectedBoss]
            if bossData then
                local bossFolder = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Boss")
                local targetBoss = nil
                if bossFolder then
                    for _, b in ipairs(bossFolder:GetChildren()) do
                        if b.Name:find(bossData.name) then
                            local hum = b:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                targetBoss = b
                                break
                            end
                        end
                    end
                end

                if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
                    local bHrp = targetBoss.HumanoidRootPart
                    local char = LP.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local attackPos = (bHrp.CFrame * CFrame.new(0, 0, 2.5)).Position
                        local dist = (hrp.Position - attackPos).Magnitude

                        if dist > 25 then
                            SafeTweenTo(attackPos)
                        else
                            hrp.CFrame = CFrame.lookAt(attackPos, bHrp.Position)
                            ExecuteFastAttack(targetBoss)
                            task.wait(CONFIG.AttackDelay)
                        end
                    end
                else
                    SafeTweenTo(bossData.pos + Vector3.new(0, 3, 0))
                    task.wait(1)
                end
            end
        end
    end
end)

-- 3. AUTO GRAB DROPPED FRUITS & AUTO STORE
task.spawn(function()
    while true do
        task.wait(1)
        if CONFIG.AutoGrabFruits then
            local dropped = workspace:FindFirstChild("AllDroppedFruit")
            if dropped then
                for _, fruit in ipairs(dropped:GetChildren()) do
                    if not CONFIG.AutoGrabFruits then break end
                    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        SafeTweenTo(handle.Position)
                        task.wait(0.3)
                        pcall(function()
                            local char = LP.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp and firetouchinterest then
                                firetouchinterest(hrp, handle, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, handle, 1)
                            end
                        end)
                        task.wait(0.5)
                        pcall(function()
                            CollectFruitRemote:FireServer(fruit.Name)
                        end)
                    end
                end
            end
        end

        if CONFIG.AutoStoreFruit then
            for _, item in ipairs(LP.Backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("fruit") then
                    pcall(function()
                        CollectFruitRemote:FireServer(item.Name)
                    end)
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- 4. AUTO HAKI & STATS
task.spawn(function()
    while true do
        task.wait(1)
        -- Buso Haki (Armament)
        if CONFIG.AutoBuso then
            local char = LP.Character
            if char and not char:FindFirstChild("ArmamentHaki") and not char:GetAttribute("Armament") then
                pcall(function()
                    ArmamentRemote:FireServer()
                end)
            end
        end

        -- Ken Haki (Observation)
        if CONFIG.AutoKen then
            pcall(function()
                KenEventRemote:InvokeServer()
            end)
        end

        -- Auto Stats
        if CONFIG.AutoStats then
            local ps = LP:FindFirstChild("PlayerStats")
            local pts = ps and ps:FindFirstChild("Points")
            local pVal = pts and tonumber(pts.Value) or 0
            if pVal > 0 then
                pcall(function()
                    local statsEvent = PlayerGui.MainGui.StarterFrame.StatsFrame.RemoteEvent
                    statsEvent:FireServer(CONFIG.StatTarget, math.min(pVal, 50))
                end)
            end
        end
    end
end)

-- ============================================================================
-- ESP SYSTEM (HIGHLIGHT + BILLBOARD GUI)
-- ============================================================================
local ESP_CONTAINER = Instance.new("Folder")
ESP_CONTAINER.Name = "KingLegacy_ESP_Container"
pcall(function()
    ESP_CONTAINER.Parent = (gethui and gethui()) or CoreGui or PlayerGui
end)

local _ActiveESP = {}

local function ClearESP(category)
    if not _ActiveESP[category] then return end
    for obj, items in pairs(_ActiveESP[category]) do
        if items.Highlight then pcall(function() items.Highlight:Destroy() end) end
        if items.Billboard then pcall(function() items.Billboard:Destroy() end) end
    end
    _ActiveESP[category] = {}
end

local function CreateESP(category, targetObj, labelText, color, isModelWithHum)
    _ActiveESP[category] = _ActiveESP[category] or {}
    if _ActiveESP[category][targetObj] then return end

    local adorneePart = targetObj:IsA("BasePart") and targetObj or (targetObj:FindFirstChild("HumanoidRootPart") or targetObj:FindFirstChild("Head") or targetObj.PrimaryPart or targetObj:FindFirstChildWhichIsA("BasePart", true))
    if not adorneePart then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.Adornee = targetObj
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.1
    pcall(function() hl.Parent = ESP_CONTAINER end)

    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP_Billboard"
    bg.Adornee = adorneePart
    bg.Size = UDim2.new(0, 160, 0, 40)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    pcall(function() bg.Parent = ESP_CONTAINER end)

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0.2
    txt.TextStrokeColor3 = Color3.new(0, 0, 0)
    txt.Text = labelText
    txt.Parent = bg

    _ActiveESP[category][targetObj] = {
        Highlight = hl,
        Billboard = bg,
        Label = txt,
        Part = adorneePart,
        Hum = isModelWithHum and targetObj:FindFirstChildOfClass("Humanoid") or nil,
        BaseText = labelText,
    }
end

-- ESP Updater Loop (Updates distances & health realtime)
task.spawn(function()
    while true do
        task.wait(0.15)
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local myPos = myHrp and myHrp.Position

        -- 1. Player ESP
        if CONFIG.PlayerESP then
            _ActiveESP["Players"] = _ActiveESP["Players"] or {}
            local pFolder = workspace:FindFirstChild("PlayerCharacters")
            if pFolder then
                for _, char in ipairs(pFolder:GetChildren()) do
                    if char ~= LP.Character then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if not _ActiveESP["Players"][char] then
                                CreateESP("Players", char, char.Name, Color3.fromRGB(0, 220, 255), true)
                            else
                                local entry = _ActiveESP["Players"][char]
                                local distStr = myPos and string.format(" [%dm]", math.floor((entry.Part.Position - myPos).Magnitude)) or ""
                                local hpStr = string.format(" [%d/%d HP]", math.floor(hum.Health), math.floor(hum.MaxHealth))
                                entry.Label.Text = entry.BaseText .. hpStr .. distStr
                            end
                        else
                            if _ActiveESP["Players"][char] then
                                pcall(function() _ActiveESP["Players"][char].Highlight:Destroy() end)
                                pcall(function() _ActiveESP["Players"][char].Billboard:Destroy() end)
                                _ActiveESP["Players"][char] = nil
                            end
                        end
                    end
                end
            end
        else
            ClearESP("Players")
        end

        -- 2. Boss ESP
        if CONFIG.BossESP then
            _ActiveESP["Bosses"] = _ActiveESP["Bosses"] or {}
            local bFolder = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Boss")
            if bFolder then
                for _, boss in ipairs(bFolder:GetChildren()) do
                    local hum = boss:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if not _ActiveESP["Bosses"][boss] then
                            CreateESP("Bosses", boss, boss.Name, Color3.fromRGB(255, 60, 60), true)
                        else
                            local entry = _ActiveESP["Bosses"][boss]
                            local distStr = myPos and string.format(" [%dm]", math.floor((entry.Part.Position - myPos).Magnitude)) or ""
                            local hpStr = string.format(" [%d/%d]", math.floor(hum.Health), math.floor(hum.MaxHealth))
                            entry.Label.Text = "[BOSS] " .. entry.BaseText .. hpStr .. distStr
                        end
                    else
                        if _ActiveESP["Bosses"][boss] then
                            pcall(function() _ActiveESP["Bosses"][boss].Highlight:Destroy() end)
                            pcall(function() _ActiveESP["Bosses"][boss].Billboard:Destroy() end)
                            _ActiveESP["Bosses"][boss] = nil
                        end
                    end
                end
            end
        else
            ClearESP("Bosses")
        end

        -- 3. Monster ESP
        if CONFIG.MonsterESP then
            _ActiveESP["Monsters"] = _ActiveESP["Monsters"] or {}
            local mFolder = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Mon")
            if mFolder then
                for _, mon in ipairs(mFolder:GetChildren()) do
                    local hum = mon:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local mHrp = mon:FindFirstChild("HumanoidRootPart")
                        local dist = myPos and mHrp and (mHrp.Position - myPos).Magnitude or 9999
                        if dist <= 300 then
                            if not _ActiveESP["Monsters"][mon] then
                                CreateESP("Monsters", mon, mon.Name, Color3.fromRGB(255, 170, 40), true)
                            else
                                local entry = _ActiveESP["Monsters"][mon]
                                local distStr = string.format(" [%dm]", math.floor(dist))
                                local hpStr = string.format(" [%d HP]", math.floor(hum.Health))
                                entry.Label.Text = entry.BaseText .. hpStr .. distStr
                            end
                        else
                            if _ActiveESP["Monsters"][mon] then
                                pcall(function() _ActiveESP["Monsters"][mon].Highlight:Destroy() end)
                                pcall(function() _ActiveESP["Monsters"][mon].Billboard:Destroy() end)
                                _ActiveESP["Monsters"][mon] = nil
                            end
                        end
                    else
                        if _ActiveESP["Monsters"][mon] then
                            pcall(function() _ActiveESP["Monsters"][mon].Highlight:Destroy() end)
                            pcall(function() _ActiveESP["Monsters"][mon].Billboard:Destroy() end)
                            _ActiveESP["Monsters"][mon] = nil
                        end
                    end
                end
            end
        else
            ClearESP("Monsters")
        end

        -- 4. Fruit ESP
        if CONFIG.FruitESP then
            _ActiveESP["Fruits"] = _ActiveESP["Fruits"] or {}
            local dFolder = workspace:FindFirstChild("AllDroppedFruit")
            if dFolder then
                for _, fruit in ipairs(dFolder:GetChildren()) do
                    if not _ActiveESP["Fruits"][fruit] then
                        CreateESP("Fruits", fruit, "[FRUIT] " .. fruit.Name, Color3.fromRGB(80, 255, 80), false)
                    else
                        local entry = _ActiveESP["Fruits"][fruit]
                        local distStr = myPos and string.format(" [%dm]", math.floor((entry.Part.Position - myPos).Magnitude)) or ""
                        entry.Label.Text = entry.BaseText .. distStr
                    end
                end
            end
        else
            ClearESP("Fruits")
        end
    end
end)

-- ============================================================================
-- WINDUI INITIALIZATION (UNIVERSAL ENGLISH, NO AI SLOP)
-- ============================================================================
local okWind, WindUI = pcall(function()
    local cached = getgenv and getgenv()._CachedWindUISource
    if not cached then
        cached = game:HttpGet("https://raw.githubusercontent.com/mhankbe/WindUi/refs/heads/main/dist/main.lua")
        if getgenv then getgenv()._CachedWindUISource = cached end
    end
    return loadstring(cached)()
end)

if not okWind or type(WindUI) ~= "table" then
    warn("[KING LEGACY] Failed to load WindUI: " .. tostring(WindUI))
    return
end

local Window = WindUI:CreateWindow({
    Title = "King Legacy | Master Automation",
    Icon = "crown",
    Author = "FLa Suite",
    Folder = "KingLegacyMaster",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
})

--  TABS DEFINITION
local FarmTab     = Window:Tab({ Title = "Farm", Icon = "crosshair" })
local BossesTab   = Window:Tab({ Title = "Bosses", Icon = "skull" })
local FruitsTab   = Window:Tab({ Title = "Fruits", Icon = "apple" })
local VisualsTab  = Window:Tab({ Title = "Visuals", Icon = "eye" })
local PlayerTab   = Window:Tab({ Title = "Player & Stats", Icon = "user" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local ConfigTab   = Window:Tab({ Title = "Config", Icon = "settings" })

-- ============================================================================
-- TAB: FARM
-- ============================================================================
local farmSec = FarmTab:Section({ Title = "Level Farming (1 - 5450)", Opened = true })

farmSec:Toggle({
    Title = "Auto Farm Level",
    Desc = "Dynamic Quest selector, safe hover, mob magnet & rapid attack",
    Value = false,
    Callback = function(v)
        CONFIG.AutoFarmLevel = v
        if not v then SafeStopTween() end
    end,
})

farmSec:Toggle({
    Title = "Fast Attack",
    Desc = "Multi-thread M1 invocation without cooldown",
    Value = false,
    Callback = function(v)
        CONFIG.FastAttack = v
    end,
})

farmSec:Slider({
    Title = "Attack Delay (Seconds)",
    Step = 0.01,
    Value = { Min = 0.02, Max = 0.3, Default = 0.08 },
    Callback = function(v)
        CONFIG.AttackDelay = tonumber(v) or 0.08
    end,
})

farmSec:Toggle({
    Title = "Bring Mobs (Mob Magnet)",
    Desc = "Clusters nearby quest enemies to single point",
    Value = false,
    Callback = function(v)
        CONFIG.BringMobs = v
    end,
})

farmSec:Slider({
    Title = "Bring Radius",
    Step = 10,
    Value = { Min = 50, Max = 350, Default = 250 },
    Callback = function(v)
        CONFIG.BringRadius = tonumber(v) or 250
    end,
})

farmSec:Dropdown({
    Title = "Weapon Type",
    Values = { "Combat", "Sword", "Fruit" },
    Value = "Combat",
    Callback = function(v)
        CONFIG.SelectedWeapon = v
    end,
})

farmSec:Slider({
    Title = "Farm Distance (Hover Height)",
    Step = 1,
    Value = { Min = 8, Max = 25, Default = 12 },
    Callback = function(v)
        CONFIG.FarmDistance = tonumber(v) or 12
    end,
})

-- ============================================================================
-- TAB: BOSSES
-- ============================================================================
local bossSec = BossesTab:Section({ Title = "World Boss Automation", Opened = true })

local bossNames = {}
for name, _ in pairs(BOSS_TABLE) do
    table.insert(bossNames, name)
end
table.sort(bossNames)

bossSec:Dropdown({
    Title = "Select Target Boss",
    Values = bossNames,
    Value = bossNames[1],
    Callback = function(v)
        CONFIG.SelectedBoss = v
    end,
})

bossSec:Toggle({
    Title = "Auto Farm Selected Boss",
    Desc = "Teleports & eliminates chosen boss repeatedly",
    Value = false,
    Callback = function(v)
        CONFIG.AutoFarmBoss = v
        if not v then SafeStopTween() end
    end,
})

-- ============================================================================
-- TAB: FRUITS
-- ============================================================================
local fruitSec = FruitsTab:Section({ Title = "Fruit Sniper & Inventory", Opened = true })

fruitSec:Toggle({
    Title = "Auto Grab Dropped Fruits",
    Desc = "Sweeps map for spawned fruits, picks up & auto stores",
    Value = false,
    Callback = function(v)
        CONFIG.AutoGrabFruits = v
        if not v then SafeStopTween() end
    end,
})

fruitSec:Toggle({
    Title = "Auto Store Fruit from Inventory",
    Desc = "Stores any fruit in backpack into treasure inventory",
    Value = false,
    Callback = function(v)
        CONFIG.AutoStoreFruit = v
    end,
})

fruitSec:Button({
    Title = "Check Spawned Fruits on Map",
    Callback = function()
        local dropped = workspace:FindFirstChild("AllDroppedFruit")
        local count = dropped and #dropped:GetChildren() or 0
        local names = {}
        if dropped then
            for _, f in ipairs(dropped:GetChildren()) do
                table.insert(names, f.Name)
            end
        end
        local listStr = #names > 0 and table.concat(names, ", ") or "None"
        WindUI:Notify({ Title = "Fruit Tracker", Content = string.format("Found %d fruits: %s", count, listStr), Duration = 5 })
    end,
})

-- ============================================================================
-- TAB: VISUALS (ESP)
-- ============================================================================
local espSec = VisualsTab:Section({ Title = "ESP & World Radar", Opened = true })

espSec:Toggle({
    Title = "Player ESP",
    Desc = "Chams & distance tracker for all players in server",
    Value = false,
    Callback = function(v)
        CONFIG.PlayerESP = v
    end,
})

espSec:Toggle({
    Title = "World Boss ESP",
    Desc = "Live tracking of all 26 world bosses in First Sea",
    Value = false,
    Callback = function(v)
        CONFIG.BossESP = v
    end,
})

espSec:Toggle({
    Title = "Monster ESP (Radius 300m)",
    Desc = "Chams and health tracker for nearby quest monsters",
    Value = false,
    Callback = function(v)
        CONFIG.MonsterESP = v
    end,
})

espSec:Toggle({
    Title = "Fruit ESP",
    Desc = "Tracks all spawned & dropped fruits on map",
    Value = false,
    Callback = function(v)
        CONFIG.FruitESP = v
    end,
})

-- ============================================================================
-- TAB: PLAYER & STATS
-- ============================================================================
local playerSec = PlayerTab:Section({ Title = "Player & Combat Enhancements", Opened = true })

playerSec:Toggle({
    Title = "Auto Buso Haki (Armament)",
    Desc = "Automatically turns on Armament Haki",
    Value = false,
    Callback = function(v)
        CONFIG.AutoBuso = v
    end,
})

playerSec:Toggle({
    Title = "Auto Ken Haki (Observation)",
    Desc = "Automatically activates Observation Haki",
    Value = false,
    Callback = function(v)
        CONFIG.AutoKen = v
    end,
})

playerSec:Toggle({
    Title = "Auto Stats Allocation",
    Desc = "Automatically distributes level-up points",
    Value = false,
    Callback = function(v)
        CONFIG.AutoStats = v
    end,
})

playerSec:Dropdown({
    Title = "Stat Allocation Target",
    Values = { "Melee", "Defense", "Sword", "Fruit" },
    Value = "Melee",
    Callback = function(v)
        CONFIG.StatTarget = v
    end,
})

playerSec:Toggle({
    Title = "NoClip",
    Desc = "Disable collisions on all character parts",
    Value = false,
    Callback = function(v)
        CONFIG.NoClip = v
    end,
})

playerSec:Toggle({
    Title = "Water Walk",
    Desc = "Creates solid surface at sea level to prevent water damage",
    Value = false,
    Callback = function(v)
        CONFIG.WaterWalk = v
    end,
})

playerSec:Toggle({
    Title = "Infinite Geppo (Skyjump)",
    Desc = "Unlimited jumps in mid-air",
    Value = false,
    Callback = function(v)
        CONFIG.InfiniteJump = v
    end,
})

-- ============================================================================
-- TAB: TELEPORT
-- ============================================================================
local tpSec = TeleportTab:Section({ Title = "First Sea Islands", Opened = true })

local islandList = {}
for name, _ in pairs(ISLAND_LOCATIONS) do
    table.insert(islandList, name)
end
table.sort(islandList)

local chosenIsland = islandList[1]

tpSec:Dropdown({
    Title = "Select Island",
    Values = islandList,
    Value = islandList[1],
    Callback = function(v)
        chosenIsland = v
    end,
})

tpSec:Button({
    Title = "Teleport to Selected Island",
    Desc = "Safe velocity tween with NoClip",
    Callback = function()
        local pos = ISLAND_LOCATIONS[chosenIsland]
        if pos then
            SafeTweenTo(pos + Vector3.new(0, 10, 0))
        end
    end,
})

tpSec:Button({
    Title = "STOP TELEPORT / TWEEN",
    Callback = function()
        SafeStopTween()
    end,
})

tpSec:Slider({
    Title = "Tween Speed (Studs/s)",
    Step = 10,
    Value = { Min = 150, Max = 350, Default = 260 },
    Callback = function(v)
        CONFIG.TweenSpeed = tonumber(v) or 260
    end,
})

-- ============================================================================
-- TAB: CONFIG & KEYBINDS (SOP RULE 8)
-- ============================================================================
local cfgSec = ConfigTab:Section({ Title = "Configuration & Controls", Opened = true })

cfgSec:Keybind({
    Title = "Show / Hide GUI",
    Desc = "Keybind to toggle menu visibility (Default LeftControl)",
    Value = "LeftControl",
    Callback = function()
        STATE.WindowVisible = not STATE.WindowVisible
        if Window.Toggle then
            Window:Toggle()
        end
    end,
})

-- Create Floating Button (SOP Rule 8)
local function CreateFloatingButton()
    if STATE.FloatingBtn then pcall(function() STATE.FloatingBtn:Destroy() end) end

    local guiParent = (gethui and gethui()) or CoreGui or PlayerGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "KingLegacyFloatingToggle"
    sg.ResetOnSpawn = false

    local btn = Instance.new("ImageButton")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.Position = UDim2.new(0, 20, 0.5, -22)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Draggable = true
    btn.Image = "rbxassetid://10723415766" -- Crown / Swords
    btn.ImageColor3 = Color3.fromRGB(255, 200, 40)
    btn.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 180, 40)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if Window.Toggle then
            Window:Toggle()
        end
    end)

    sg.Parent = guiParent
    STATE.FloatingBtn = sg
end
CreateFloatingButton()

cfgSec:Button({
    Title = "Recreate Floating Button",
    Callback = function()
        CreateFloatingButton()
    end,
})

cfgSec:Button({
    Title = "Save Configuration",
    Desc = "Saves all settings to KingLegacy_Config.json",
    Callback = function()
        pcall(function()
            local json = HttpService:JSONEncode(CONFIG)
            if writefile then
                writefile("KingLegacy_Config.json", json)
                WindUI:Notify({ Title = "Config Saved", Content = "Saved to KingLegacy_Config.json", Duration = 3 })
            end
        end)
    end,
})

cfgSec:Button({
    Title = "Load Configuration",
    Desc = "Restores settings from KingLegacy_Config.json",
    Callback = function()
        pcall(function()
            if readfile and isfile and isfile("KingLegacy_Config.json") then
                local json = readfile("KingLegacy_Config.json")
                local loaded = HttpService:JSONDecode(json)
                for k, v in pairs(loaded) do
                    CONFIG[k] = v
                end
                WindUI:Notify({ Title = "Config Loaded", Content = "Configuration applied", Duration = 3 })
            end
        end)
    end,
})

-- Select default tab
pcall(function()
    FarmTab:Select()
end)

WindUI:Notify({
    Title = "King Legacy Master Loaded",
    Content = "Press LeftControl or tap Floating Button to toggle UI. Default: ALL OFF.",
    Duration = 5,
})

print("[KING LEGACY] Master automation initialized. WindUI v1.6 active.")
