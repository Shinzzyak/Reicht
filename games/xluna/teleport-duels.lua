-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    TELEPORT DUELS â MASTER AUTOMATION SUITE
    Author: By XLunaHUB
    UI Framework: WindUI | Language: English
    Keybind: LeftControl (Show/Hide) | Floating Button: Enabled (Draggable)
    Default State: ALL OFF (All toggles disabled at startup)
    Stealth: GUI & ESP parented to gethui()/CoreGui (PlayerGui untouched)
    ========================================================================
]]

-- -------------------------------------------------------------------------
-- 1. SERVICES, THREAD IDENTITY GUARD & RELOAD CLEANUP
-- -------------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 30)

local setIdentityFn = setthreadidentity or (syn and syn.set_thread_identity) or setidentity

local function ensureElevatedIdentity()
    if type(setIdentityFn) == "function" then
        pcall(setIdentityFn, 8)
    end
end

local function safeWait(sec)
    local dt = task.wait(sec)
    ensureElevatedIdentity()
    return dt
end

ensureElevatedIdentity()

-- Tear down any previous standalone instance before initializing
if type(shared) == "table" and type(shared.XLunaTD_Unload) == "function" then
    pcall(shared.XLunaTD_Unload)
end
if type(getgenv) == "function" then
    local okGenv, genv = pcall(getgenv)
    if okGenv and type(genv) == "table" and type(genv.XLunaTD_Unload) == "function" then
        pcall(genv.XLunaTD_Unload)
    end
end
pcall(function()
    RunService:UnbindFromRenderStep("XLunaTD_CombatSteer")
end)

local GameG = (type(getrenv) == "function" and getrenv()._G) or _G

local Connections = {}
local Threads = {}
local Cleanups = {}
local Unloaded = false

local function trackConn(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function trackThread(fn)
    local co = task.spawn(function()
        ensureElevatedIdentity()
        fn()
    end)
    table.insert(Threads, co)
    return co
end

local function getStealthContainerParent()
    ensureElevatedIdentity()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then
            return hui
        end
    end
    return CoreGui
end

-- -------------------------------------------------------------------------
-- 2. SAFE MODULES & REMOTES
-- -------------------------------------------------------------------------
local function safeRequire(inst)
    if not inst or not inst:IsA("ModuleScript") then
        return nil
    end
    local ok, mod = pcall(require, inst)
    ensureElevatedIdentity()
    return ok and mod or nil
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local res = table.pack(pcall(fn, ...))
    ensureElevatedIdentity()
    if res[1] then
        return table.unpack(res, 2, res.n)
    end
    return nil
end

local DaggerModules = ReplicatedStorage:WaitForChild("DaggerModules", 30)
local Config = safeRequire(DaggerModules and DaggerModules:FindFirstChild("Config")) or {}
local SkillsModule = safeRequire(DaggerModules and DaggerModules:FindFirstChild("Skills")) or {}
local LevelingModule = safeRequire(DaggerModules and DaggerModules:FindFirstChild("Leveling")) or {}

local function rem(name)
    return ReplicatedStorage:FindFirstChild(name)
end

-- -------------------------------------------------------------------------
-- 3. STATE STORE (STRICTLY ALL OFF ON STARTUP) & CONFIG PERSISTENCE
-- -------------------------------------------------------------------------
local CONFIG_DIR = "XLunaHUB_TeleportDuels"

local State = {
    -- Master Autonomous Grinder
    AutoPlayMaster = false,
    AutoPlayQueueMode = "Classic 1v1",

    -- Dagger & Silent Aim
    SilentAim = false,
    TargetLockOn = false,
    AutoThrowDagger = false,
    AimTargetPart = "Head",
    AimPriority = "Closest Crosshair",
    PredictionStrength = 35,
    AutoTeleportStrike = false,
    AntiParryBait = false,
    PrioritizeStunThrow = false,
    AutoDaggerPartEscape = false,
    EscapeHPThreshold = 35,

    -- Auto-Parry & Melee
    AutoParryTeleport = false,
    ParryReactionMs = 215,
    AutoParryMeleeAndGate = false,
    AutoBulwarkFallback = false,
    AutoEquipDagger = false,
    MeleeKillAura = false,
    AggressiveCombatMove = false,
    CQCOrbitTarget = false,
    CQCOrbitMode = "Behind Target",
    CQCOrbitDistance = 6,
    AutoDashEvade = false,

    -- Skills & Loadout
    AutoUseSkills = false,
    SkillHealHP = 55,
    SelectedSkillSlot1 = "flurry",
    SelectedSkillSlot2 = "regen",
    SelectedBuySkill = "bloodlust",

    -- Matchmaking & Lobby
    SelectedQueueMode = "Classic 1v1",
    AutoQueueMatch = false,
    PreferredArenaVote = "Random",
    AutoVoteArena = false,
    AutoSkipResultAndPopups = false,
    DuelInvitePolicy = "Manual",
    AutoHandleDuelInvites = false,
    SelectedChallengePlayer = "None",
    SelectedLobbyTeleport = "Duel 1v1 Pad",

    -- Chests, Cosmetics & Rewards
    AutoClaimRewards = false,
    InstantSkipGacha = false,
    SelectedChestType = "1 - Rare Chest (500)",
    AutoOpenChests = false,
    AutoTransformWeapon = false,
    SelectedKillEffect = "Common",
    SelectedEmote = "Fresh",

    -- Player & Visuals
    EnemyCombatESP = false,
    DaggerAndAnchorESP = false,
    IncomingThreatAlert = false,
    CustomWalkSpeed = false,
    WalkSpeed = 28,
    CustomJumpPower = false,
    JumpPower = 75,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 70,
    CustomFOV = false,
    FOVValue = 95,
    Fullbright = false,
    AntiCameraShakeAndFlash = false,

    -- Config & Anti-AFK
    AntiAfk = false,
    AutoReExecuteOnTeleport = false,
    ConfigName = "default",
}

local UI_Elements = {}
local SuppressCallbacks = false

-- -------------------------------------------------------------------------
-- 4. LOAD WINDUI & INITIALIZE WINDOW (LeftControl Toggle + Floating Button)
-- -------------------------------------------------------------------------
local WindUI = nil
do
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    }
    for _, url in ipairs(urls) do
        local ok, src = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and type(src) == "string" and #src > 500 then
            local fn = loadstring(src)
            if fn then
                local okLib, lib = pcall(fn)
                ensureElevatedIdentity()
                if okLib and lib then
                    WindUI = lib
                    break
                end
            end
        end
    end
end

if not WindUI then
    warn("[XLunaHUB] Failed to load WindUI library.")
    return
end

ensureElevatedIdentity()
local Window = WindUI:CreateWindow({
    Title = "Teleport Duels",
    Icon = "zap",
    Author = "By XLunaHUB",
    Folder = "XLunaTD",
    Size = UDim2.fromOffset(680, 540),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "zap",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 1.5,
        Color = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(165, 55, 255)),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

local function notify(title, msg, duration)
    if Unloaded then
        return
    end
    ensureElevatedIdentity()
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = msg,
            Duration = duration or 3,
        })
    end)
end

local function safeSetDesc(para, text)
    if Unloaded or not para or not para.SetDesc then
        return
    end
    ensureElevatedIdentity()
    para.Desc = text
    pcall(function()
        para:SetDesc(text)
    end)
end

-- -------------------------------------------------------------------------
-- 5. SHARED TELEMETRY, COMBAT HELPERS & SNAPSHOT RESTORATION
-- -------------------------------------------------------------------------
local Runtime = {
    throwsAttempted = 0,
    silentAimRedirects = 0,
    teleportsAttempted = 0,
    parriesTriggered = 0,
    meleeSwings = 0,
    skillsCast = 0,
    chestsOpened = 0,
    rewardsClaimed = 0,
    matchesQueued = 0,
    lastAction = "Idle (All OFF)",
    disabledIdledConns = {},
    autoRejoinOrigDisabled = nil,
    targetIsParrying = false,
    parryEndedAt = 0,
    stuckSince = 0,
    lastThrowAt = 0,
    lastTeleportAt = 0,
    lastCancelAt = 0,
    lastMeleeAt = 0,
    lastDashAt = 0,
    lastSkillAt = 0,
    lastQueueAt = 0,
    lastVoteAt = 0,
    votedMatchId = nil,
    lastResultExitAt = 0,
    lastGachaDismissAt = 0,
    lastRewardAt = 0,
    lastChestAt = 0,
    lastTransformAt = 0,
    lastEscapeAt = 0,
    lastThreatAlertAt = 0,
    recallMarkedAt = 0,
    lastHudSyncAt = 0,
    lastEspUpdateAt = 0,
    lockedTargetModel = nil,
    lockedTargetName = "None",
    strafeDir = 1,
    nextStrafeFlipAt = 0,
    nextAutoJumpAt = 0,
    meleeComboStep = 0,
    meleeRecoverUntil = 0,
    wallDaggerSince = 0,
    combatMoveSteps = 0,
    gapCloseBlinks = 0,
    missedDaggerCancels = 0,
    wasCombatMoving = false,
    origAutoRotate = nil,
    camHooksOrig = {},
}

local function getRootAndHum()
    local char = LocalPlayer.Character
    if not char then
        return nil, nil, nil
    end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function safeTeleportCF(cf)
    local _, hrp = getRootAndHum()
    if not hrp or typeof(cf) ~= "CFrame" then
        return false
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = cf
    return true
end

local function formatNumber(n)
    local v = math.floor(math.abs(tonumber(n) or 0))
    local sign = (tonumber(n) or 0) < 0 and "-" or ""
    return sign .. tostring(v):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function getTutorialState()
    if type(GameG.DaggerGetTutorialState) == "function" then
        local st = safeCall(GameG.DaggerGetTutorialState)
        if type(st) == "table" then
            return st
        end
    end
    return { state = "none", onCooldown = false, throwing = false, hasTool = false }
end

local function isInMatch()
    return LocalPlayer:GetAttribute("MatchId") ~= nil
end

local function isInLobby()
    return LocalPlayer:GetAttribute("MatchId") == nil and LocalPlayer:GetAttribute("InTutorial") ~= true
end

local function isArenaVotingActive()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local mg = pg and pg:FindFirstChild("MatchGui")
    local picker = mg and mg:FindFirstChild("Picker", true)
    return (picker and picker:IsA("GuiObject") and picker.Visible == true) or false
end

local function isDaggerTool(inst)
    if not inst or not inst:IsA("Tool") then
        return false
    end
    if type(Config.VALID_DAGGERS) == "table" then
        return Config.VALID_DAGGERS[inst.Name] == true
    end
    return inst.Name:sub(1, 6) == "Dagger"
end

local function getEquippedDagger()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    for _, ch in ipairs(char:GetChildren()) do
        if isDaggerTool(ch) then
            return ch
        end
    end
    return nil
end

local function equipDaggerFromBackpack()
    local char, _, hum = getRootAndHum()
    if not char or not hum or hum.Health <= 0 then
        return nil
    end
    local cur = getEquippedDagger()
    if cur then
        return cur
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not bp then
        return nil
    end
    local preferred = tostring(LocalPlayer:GetAttribute("__LastDagger") or "")
    local pick = nil
    for _, tool in ipairs(bp:GetChildren()) do
        if isDaggerTool(tool) then
            if tool.Name == preferred then
                pick = tool
                break
            elseif not pick then
                pick = tool
            end
        end
    end
    if pick then
        pcall(function()
            hum:EquipTool(pick)
        end)
        return pick
    end
    return nil
end

local function isModelImmune(model, plr)
    local now = Workspace:GetServerTimeNow()
    if model:GetAttribute("Hibernating") == true then
        return true
    end
    local imm = tonumber(model:GetAttribute("ImmuneUntil"))
    if imm and now < imm then
        return true
    end
    return false
end

local function isModelParrying(model, plr)
    local now = Workspace:GetServerTimeNow()
    if plr then
        local pb = tonumber(plr:GetAttribute("ParryBlockUntil"))
        if pb and now < pb then
            return true
        end
    end
    if model:FindFirstChild("__BlockEffectClone") or model:FindFirstChild("__BlockHL") then
        return true
    end
    local stName = GameG.DaggerParryThrower
    if Runtime.targetIsParrying and stName and (model.Name == stName or (plr and plr.Name == stName)) then
        return true
    end
    return false
end

local function getValidCombatTargets()
    local targets = {}
    local myMatchId = LocalPlayer:GetAttribute("MatchId")
    local myTeam = LocalPlayer:GetAttribute("MatchTeam")
    local myChar = LocalPlayer.Character

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and char ~= myChar and hum and hum.Health > 0 and hrp then
                local bhp = char:GetAttribute("BattleHP")
                local alive = (bhp == nil) or (tonumber(bhp) and tonumber(bhp) > 0)
                if alive and plr:GetAttribute("DownAt") == nil and not plr:GetAttribute("Eliminated") then
                    local sameMatch = (plr:GetAttribute("MatchId") == myMatchId)
                    local sameTeam = (myMatchId ~= nil and myTeam ~= nil and plr:GetAttribute("MatchTeam") == myTeam)
                    if sameMatch and not sameTeam then
                        table.insert(targets, {
                            kind = "Player",
                            player = plr,
                            name = plr.DisplayName ~= "" and plr.DisplayName or plr.Name,
                            model = char,
                            hum = hum,
                            hrp = hrp,
                            hp = tonumber(bhp) or hum.Health,
                            maxHp = tonumber(char:GetAttribute("BattleMaxHP")) or hum.MaxHealth,
                            isImmune = isModelImmune(char, plr),
                            isParrying = isModelParrying(char, plr),
                        })
                    end
                end
            end
        end
    end

    local botsFolder = Workspace:FindFirstChild("Bots")
    if botsFolder then
        for _, bot in ipairs(botsFolder:GetChildren()) do
            if bot:IsA("Model") and bot:GetAttribute("IsBot") then
                local hum = bot:FindFirstChildOfClass("Humanoid")
                local hrp = bot:FindFirstChild("HumanoidRootPart")
                local bhp = bot:GetAttribute("BattleHP")
                local alive = (bhp == nil) or (tonumber(bhp) and tonumber(bhp) > 0)
                if hum and hum.Health > 0 and hrp and alive
                    and not bot:GetAttribute("BotDown")
                    and not bot:GetAttribute("Eliminated") then
                    local sameMatch = (bot:GetAttribute("MatchId") == myMatchId)
                    local sameTeam = (myMatchId ~= nil and myTeam ~= nil and bot:GetAttribute("MatchTeam") == myTeam)
                    if sameMatch and not sameTeam then
                        table.insert(targets, {
                            kind = "Bot",
                            player = nil,
                            name = bot.Name,
                            model = bot,
                            hum = hum,
                            hrp = hrp,
                            hp = tonumber(bhp) or hum.Health,
                            maxHp = tonumber(bot:GetAttribute("BattleMaxHP")) or hum.MaxHealth,
                            isImmune = isModelImmune(bot, nil),
                            isParrying = isModelParrying(bot, nil),
                        })
                    end
                end
            end
        end
    end

    return targets
end

local function getAimPartForTarget(target)
    if not target or not target.model then
        return nil
    end
    local choice = State.AimTargetPart
    if choice == "Head" then
        return target.model:FindFirstChild("Head") or target.hrp
    elseif choice == "UpperTorso / Torso" then
        return target.model:FindFirstChild("UpperTorso") or target.model:FindFirstChild("Torso") or target.hrp
    end
    return target.hrp
end

local function buildWorldExcludeList(extraInst)
    local exclude = {}
    local myChar = LocalPlayer.Character
    if myChar then
        table.insert(exclude, myChar)
    end
    if extraInst then
        table.insert(exclude, extraInst)
    end
    local botsFolder = Workspace:FindFirstChild("Bots")
    if botsFolder then
        table.insert(exclude, botsFolder)
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            table.insert(exclude, plr.Character)
        end
    end
    for _, ch in ipairs(Workspace:GetChildren()) do
        if ch.Name == "__DaggerVisual" or ch.Name:sub(1, 12) == "ThrownDagger" or ch.Name:sub(1, 17) == "ThrownDaggerModel" then
            table.insert(exclude, ch)
        end
    end
    return exclude
end

local function hasGroundBelow(worldPos, maxDrop)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    rp.RespectCanCollide = true
    rp.FilterDescendantsInstances = buildWorldExcludeList(nil)
    local hit = Workspace:Raycast(worldPos + Vector3.new(0, 3, 0), Vector3.new(0, -(maxDrop or 22), 0), rp)
    return hit ~= nil
end

local function hasLineOfSight(originPos, targetPos, targetModel)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    rp.RespectCanCollide = true
    rp.FilterDescendantsInstances = buildWorldExcludeList(targetModel)
    local dir = targetPos - originPos
    local hit = Workspace:Raycast(originPos, dir, rp)
    if not hit then
        return true
    end
    return (hit.Position - originPos).Magnitude >= (dir.Magnitude - 1.5)
end

local function getPredictedPosition(originPos, target)
    local part = getAimPartForTarget(target)
    if not part then
        return nil, nil
    end
    local pos = part.Position
    local vel = target.hrp and target.hrp.AssemblyLinearVelocity or Vector3.zero
    local dist = (pos - originPos).Magnitude
    -- Hitscan is enabled in Config.HITSCAN; lead horizontal motion smoothly while clamping vertical jump arcs
    local factor = (tonumber(State.PredictionStrength) or 0) / 100
    local leadTime = math.clamp(dist / 520, 0.02, 0.22) * factor
    local yLead = math.clamp(vel.Y * 0.22, -3.5, 3.5) * factor
    local predicted = pos + Vector3.new(vel.X * leadTime, yLead, vel.Z * leadTime)
    return predicted, part
end

local function scoreCombatCandidate(t, originPos, myHrp, camLook, predPos)
    local dist = (predPos - myHrp.Position).Magnitude
    if State.AimPriority == "Nearest Distance" then
        return dist
    elseif State.AimPriority == "Lowest HP" then
        return t.hp * 100 + dist * 0.1
    end
    local dirUnit = (predPos - originPos).Unit
    local dot = math.clamp(camLook:Dot(dirUnit), -1, 1)
    local angle = math.acos(dot)
    return angle * 1000 + dist * 0.05
end

local function resolveStickyCombatTarget(maxRange)
    local cam = Workspace.CurrentCamera
    local _, myHrp = getRootAndHum()
    if not myHrp then
        Runtime.lockedTargetModel = nil
        Runtime.lockedTargetName = "None"
        return nil, nil, nil
    end
    local originPos = cam and cam.CFrame.Position or (myHrp.Position + Vector3.new(0, 1.5, 0))
    local camLook = cam and cam.CFrame.LookVector or myHrp.CFrame.LookVector
    local rangeLimit = maxRange or 480
    local targets = getValidCombatTargets()

    if #targets == 0 then
        Runtime.lockedTargetModel = nil
        Runtime.lockedTargetName = "None"
        return nil, nil, nil
    end

    local curTarget, curDist, curPred, curPart, curLOS = nil, math.huge, nil, nil, false
    local nearestVis, nearestVisDist, nearestVisPred, nearestVisPart = nil, math.huge, nil, nil
    local bestVis, bestVisScore, bestVisPred, bestVisPart = nil, math.huge, nil, nil
    local nearestAny, nearestAnyDist, nearestAnyPred, nearestAnyPart = nil, math.huge, nil, nil
    local bestAny, bestAnyScore, bestAnyPred, bestAnyPart = nil, math.huge, nil, nil

    for _, t in ipairs(targets) do
        local predPos, part = getPredictedPosition(originPos, t)
        if predPos and part then
            local dist = (t.hrp.Position - myHrp.Position).Magnitude
            if dist <= rangeLimit then
                local los = hasLineOfSight(originPos, predPos, t.model)
                if t.model == Runtime.lockedTargetModel then
                    curTarget = t
                    curDist = dist
                    curPred = predPos
                    curPart = part
                    curLOS = los
                end
                if not t.isImmune then
                    local sc = scoreCombatCandidate(t, originPos, myHrp, camLook, predPos)
                    if t.isParrying then
                        sc += 2500
                    end
                    if dist < nearestAnyDist then
                        nearestAny, nearestAnyDist, nearestAnyPred, nearestAnyPart = t, dist, predPos, part
                    end
                    if sc < bestAnyScore then
                        bestAnyScore, bestAny, bestAnyPred, bestAnyPart = sc, t, predPos, part
                    end
                    if los then
                        if dist < nearestVisDist then
                            nearestVis, nearestVisDist, nearestVisPred, nearestVisPart = t, dist, predPos, part
                        end
                        if sc < bestVisScore then
                            bestVisScore, bestVis, bestVisPred, bestVisPart = sc, t, predPos, part
                        end
                    end
                end
            end
        end
    end

    local chosen, chosenPred, chosenPart = curTarget, curPred, curPart
    if not chosen or chosen.isImmune then
        if bestVis then
            chosen, chosenPred, chosenPart = bestVis, bestVisPred, bestVisPart
        else
            chosen, chosenPred, chosenPart = bestAny, bestAnyPred, bestAnyPart
        end
    elseif not curLOS and bestVis then
        chosen, chosenPred, chosenPart = bestVis, bestVisPred, bestVisPart
    elseif nearestVis and nearestVis ~= chosen then
        if (nearestVisDist <= 14 and curDist > 18) or (nearestVisDist < curDist * 0.55) then
            chosen, chosenPred, chosenPart = nearestVis, nearestVisPred, nearestVisPart
        end
    elseif not bestVis and nearestAny and nearestAny ~= chosen and nearestAnyDist < curDist * 0.55 then
        chosen, chosenPred, chosenPart = nearestAny, nearestAnyPred, nearestAnyPart
    end

    if chosen then
        Runtime.lockedTargetModel = chosen.model
        Runtime.lockedTargetName = chosen.name
        return chosen, chosenPred, chosenPart
    end

    Runtime.lockedTargetModel = nil
    Runtime.lockedTargetName = "None"
    return nil, nil, nil
end

local function pickBestCombatTarget(requireVisible, allowProtected, maxRange)
    local cam = Workspace.CurrentCamera
    local _, myHrp = getRootAndHum()
    if not myHrp then
        return nil, nil, nil
    end
    local originPos = cam and cam.CFrame.Position or (myHrp.Position + Vector3.new(0, 1.5, 0))
    local camLook = cam and cam.CFrame.LookVector or myHrp.CFrame.LookVector
    local rangeLimit = maxRange or 470

    local stickyTarget, stickyPred, stickyPart = resolveStickyCombatTarget(rangeLimit)
    if stickyTarget and stickyPred and stickyPart then
        local stickyDist = (stickyPred - myHrp.Position).Magnitude
        local protOk = allowProtected or (not stickyTarget.isImmune and not stickyTarget.isParrying)
        local visOk = (not requireVisible) or hasLineOfSight(originPos, stickyPred, stickyTarget.model)
        if protOk and visOk and stickyDist >= 1.5 and stickyDist <= rangeLimit then
            return stickyTarget, stickyPred, stickyPart
        end
    end

    local targets = getValidCombatTargets()
    local bestTarget, bestPredPos, bestPart = nil, nil, nil
    local bestScore = math.huge

    for _, t in ipairs(targets) do
        if allowProtected or (not t.isImmune and not t.isParrying) then
            local predPos, part = getPredictedPosition(originPos, t)
            if predPos and part then
                local dist = (predPos - myHrp.Position).Magnitude
                if dist <= rangeLimit and dist >= 1.5 then
                    local okVis = (not requireVisible) or hasLineOfSight(originPos, predPos, t.model)
                    if okVis then
                        local score = scoreCombatCandidate(t, originPos, myHrp, camLook, predPos)
                        if score < bestScore then
                            bestScore = score
                            bestTarget = t
                            bestPredPos = predPos
                            bestPart = part
                        end
                    end
                end
            end
        end
    end

    return bestTarget, bestPredPos, bestPart
end

local function getArenaDaggerParts()
    local list = {}
    local preview = Workspace:FindFirstChild("DaggerPreview")
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if (inst.Name == "DaggerPart" or inst.Name == "DaggerPartX") and (not preview or not inst:IsDescendantOf(preview)) then
            if inst:IsA("BasePart") then
                table.insert(list, inst)
            else
                for _, p in ipairs(inst:GetDescendants()) do
                    if p:IsA("BasePart") then
                        table.insert(list, p)
                    end
                end
            end
        end
    end
    return list
end

local function getEquippedSkillsList()
    local s1, s2 = nil, nil
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local td = pg and pg:FindFirstChild("TeleportDagger")
    local pcFrame = td and td:FindFirstChild("SkillFramePC")
    local function findSlotBtn(idx)
        if not td then
            return nil
        end
        if type(GameG.DaggerIsPCLike) == "function" and safeCall(GameG.DaggerIsPCLike) == true and pcFrame then
            local pcBtn = pcFrame:FindFirstChild("SkillButton" .. idx, true)
            if pcBtn then
                return pcBtn
            end
        end
        return td:FindFirstChild("SkillButton" .. idx) or td:FindFirstChild("SkillButton" .. idx, true)
    end
    local function readSlot(idx)
        local b = findSlotBtn(idx)
        local lbl = b and b:FindFirstChild("SkillLabel", true)
        if lbl and lbl:IsA("TextLabel") then
            local txt = string.upper(lbl.Text or "")
            for id, data in pairs(SkillsModule.DATA or {}) do
                if string.upper(data.name or "") == txt then
                    return id
                end
            end
        end
        return nil
    end
    s1 = readSlot(1) or State.SelectedSkillSlot1
    s2 = readSlot(2) or State.SelectedSkillSlot2
    return { s1, s2 }
end

local function getSkillStateInfo(skillId)
    if type(GameG.DaggerSkillState) == "function" then
        local st = safeCall(GameG.DaggerSkillState, skillId)
        if type(st) == "table" then
            return st
        end
    end
    return nil
end

local function isSkillReady(skillId)
    if not skillId or skillId == "" then
        return false
    end
    local st = getSkillStateInfo(skillId)
    if not st then
        return true
    end
    local activeFor = tonumber(st.activeFor) or 0
    local cdLeft = tonumber(st.cdLeft) or 0
    return activeFor <= 0 and cdLeft <= 0
end

local function useSkillById(skillId, lookVec)
    local ev = rem("SkillEvent")
    if not ev or not skillId or skillId == "" then
        return false
    end
    local cam = Workspace.CurrentCamera
    local vec = lookVec or (cam and cam.CFrame.LookVector) or Vector3.new(0, 0, -1)
    pcall(function()
        ev:FireServer("use", skillId, vec)
    end)
    Runtime.skillsCast += 1
    Runtime.lastSkillAt = os.clock()
    Runtime.lastAction = "Used skill: " .. skillId
    return true
end

local function throwDaggerAtWorldPos(targetPos)
    if type(GameG.DaggerTriggerThrowOnly) ~= "function" then
        return false
    end
    local cam = Workspace.CurrentCamera
    local _, hrp = getRootAndHum()
    if not cam or not hrp or typeof(targetPos) ~= "Vector3" then
        return false
    end

    local tut = getTutorialState()
    if tut.throwing then
        if not GameG.DaggerStuckOnPlayer and type(GameG.DaggerTriggerCancel) == "function" then
            safeCall(GameG.DaggerTriggerCancel)
            Runtime.missedDaggerCancels += 1
            Runtime.lastCancelAt = os.clock()
        end
        return false
    end

    local shootOrigin = hrp.Position + Vector3.new(0, 1, 0)
    local dir = targetPos - shootOrigin
    if dir.Magnitude < 0.1 then
        return false
    end
    local dirUnit = dir.Unit

    local lookFlat = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
    if (lookFlat - hrp.Position).Magnitude > 0.1 then
        hrp.CFrame = CFrame.lookAt(hrp.Position, lookFlat)
    end

    -- Align camera behind shootOrigin along dirUnit to eliminate computeThrowArgs projection parallax
    local origCF = cam.CFrame
    cam.CFrame = CFrame.lookAt(shootOrigin - dirUnit * 4, targetPos)
    local camSync = rem("DaggerCamSync")
    if camSync then
        local flat = Vector3.new(dirUnit.X, 0, dirUnit.Z)
        if flat.Magnitude > 0.01 then
            pcall(function()
                camSync:FireServer(flat.Unit)
            end)
        end
    end

    pcall(GameG.DaggerTriggerThrowOnly)
    ensureElevatedIdentity()

    cam.CFrame = origCF
    Runtime.throwsAttempted += 1
    Runtime.lastThrowAt = os.clock()
    return true
end

local function restoreCombatMovement()
    local _, _, hum = getRootAndHum()
    if hum then
        if Runtime.origAutoRotate ~= nil then
            local shiftLockActive = type(GameG.DaggerShiftLockIsOn) == "function" and safeCall(GameG.DaggerShiftLockIsOn) == true
            local restoreVal = shiftLockActive and false or true
            if not isInMatch() then
                restoreVal = true
            elseif Runtime.origAutoRotate == false and not shiftLockActive then
                restoreVal = true
            end
            pcall(function()
                hum.AutoRotate = restoreVal
            end)
        end
        if Runtime.wasCombatMoving then
            pcall(function()
                hum:Move(Vector3.zero, false)
            end)
        end
    end
    Runtime.origAutoRotate = nil
    Runtime.wasCombatMoving = false
    Runtime.lockedTargetModel = nil
    Runtime.lockedTargetName = "None"
end

-- Movement, Camera & Visual Snapshots (Clean Restoration on OFF / Unload)
local MovementOrig = { WalkSpeed = nil, JumpPower = nil, JumpHeight = nil, UseJumpPower = nil }
local NoClipModified = {}
local OriginalFOV = nil
local OriginalLighting = nil
local FullbrightActive = false

local function restoreWalkSpeed()
    local _, _, hum = getRootAndHum()
    if hum and MovementOrig.WalkSpeed ~= nil then
        local restoreWS = (MovementOrig.WalkSpeed > 1) and MovementOrig.WalkSpeed or (isInLobby() and 26 or 18)
        pcall(function()
            hum.WalkSpeed = restoreWS
        end)
    end
    MovementOrig.WalkSpeed = nil
end

local function restoreJumpPower()
    local _, _, hum = getRootAndHum()
    if hum and (MovementOrig.UseJumpPower ~= nil or MovementOrig.JumpPower ~= nil or MovementOrig.JumpHeight ~= nil) then
        pcall(function()
            if MovementOrig.UseJumpPower ~= nil then
                hum.UseJumpPower = MovementOrig.UseJumpPower
            end
            if MovementOrig.JumpPower ~= nil then
                hum.JumpPower = MovementOrig.JumpPower
            end
            if MovementOrig.JumpHeight ~= nil then
                hum.JumpHeight = MovementOrig.JumpHeight
            end
        end)
    end
    MovementOrig.UseJumpPower = nil
    MovementOrig.JumpPower = nil
    MovementOrig.JumpHeight = nil
end

local function restoreNoClip()
    for part, origCollide in pairs(NoClipModified) do
        if part and part.Parent and part:IsA("BasePart") then
            pcall(function()
                part.CanCollide = origCollide
            end)
        end
    end
    table.clear(NoClipModified)
end

local function restoreFly()
    local _, hrp = getRootAndHum()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function applyCustomFOV(on)
    local cam = Workspace.CurrentCamera
    if on then
        if OriginalFOV == nil then
            OriginalFOV = tonumber(GameG.DaggerBaseFOV) or (cam and cam.FieldOfView) or 70
        end
        local v = tonumber(State.FOVValue) or 95
        GameG.DaggerBaseFOV = v
        if type(GameG.DaggerSetBaseFOV) == "function" then
            safeCall(GameG.DaggerSetBaseFOV, v)
        end
        if cam then
            cam.FieldOfView = v
        end
    elseif OriginalFOV ~= nil then
        local orig = OriginalFOV
        OriginalFOV = nil
        GameG.DaggerBaseFOV = orig
        if type(GameG.DaggerSetBaseFOV) == "function" then
            safeCall(GameG.DaggerSetBaseFOV, orig)
        end
        if cam then
            cam.FieldOfView = orig
        end
    end
end

local function applyFullbright(on)
    if on then
        if not FullbrightActive then
            OriginalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
            FullbrightActive = true
        end
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    elseif FullbrightActive and OriginalLighting then
        FullbrightActive = false
        for prop, val in pairs(OriginalLighting) do
            pcall(function()
                Lighting[prop] = val
            end)
        end
        OriginalLighting = nil
    end
end

local function applyAntiShakeAndFlash(on)
    local hookKeys = { "DaggerCameraShake", "DaggerVignetteHold", "DaggerCamFadePulse" }
    if on then
        for _, k in ipairs(hookKeys) do
            if type(GameG[k]) == "function" and Runtime.camHooksOrig[k] == nil then
                Runtime.camHooksOrig[k] = GameG[k]
                GameG[k] = function() end
            end
        end
    else
        for k, origFn in pairs(Runtime.camHooksOrig) do
            if type(origFn) == "function" then
                GameG[k] = origFn
            end
        end
        table.clear(Runtime.camHooksOrig)
    end
end

-- Dual-Layer Anti-AFK (Idled Hook + 18.5-Min AutoRejoin LocalScript Suppression)
local MyIdledHandlerFn = function()
    if State.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end

local function applyAntiAfkState(enabled)
    local autoRejoin = PlayerScripts and PlayerScripts:FindFirstChild("AutoRejoin")
    if enabled then
        if type(getconnections) == "function" then
            local ok, conns = pcall(getconnections, LocalPlayer.Idled)
            if ok and type(conns) == "table" then
                for _, c in ipairs(conns) do
                    if c and c.Enabled and c.Function ~= MyIdledHandlerFn then
                        pcall(function()
                            c:Disable()
                        end)
                        table.insert(Runtime.disabledIdledConns, c)
                    end
                end
            end
        end
        if autoRejoin and autoRejoin:IsA("LocalScript") then
            if Runtime.autoRejoinOrigDisabled == nil then
                Runtime.autoRejoinOrigDisabled = autoRejoin.Disabled
            end
            autoRejoin.Disabled = true
        end
    else
        for _, c in ipairs(Runtime.disabledIdledConns) do
            pcall(function()
                c:Enable()
            end)
        end
        table.clear(Runtime.disabledIdledConns)
        if autoRejoin and autoRejoin:IsA("LocalScript") and Runtime.autoRejoinOrigDisabled ~= nil then
            autoRejoin.Disabled = Runtime.autoRejoinOrigDisabled
            Runtime.autoRejoinOrigDisabled = nil
        end
    end
end

-- -------------------------------------------------------------------------
-- 6. ACTION HANDLERS (REWARDS, QUEUE, CHESTS, SKILLS, TELEPORTS)
-- -------------------------------------------------------------------------
local function claimAllRewardsNow()
    local claimed = 0
    if LocalPlayer:GetAttribute("DailyCanClaim") == true then
        local dailyFn = rem("DailyLoginClaim")
        if dailyFn then
            local ok, res = pcall(function()
                return dailyFn:InvokeServer("claim")
            end)
            ensureElevatedIdentity()
            if ok and res then
                claimed += 1
            end
        end
    end

    if LocalPlayer:GetAttribute("PlaytimeState") == "claim" then
        local ptFn = rem("PlaytimeRewardClaim")
        if ptFn then
            local ok, res = pcall(function()
                return ptFn:InvokeServer()
            end)
            ensureElevatedIdentity()
            if ok and res then
                claimed += 1
            end
        end
    end

    if not LocalPlayer:GetAttribute("FavoriteClaimed") then
        local commFn = rem("CommunityReward")
        if commFn then
            local ok, res = pcall(function()
                return commFn:InvokeServer("favorite")
            end)
            ensureElevatedIdentity()
            if ok and (res == "granted" or res == "claimed") then
                if res == "granted" then
                    claimed += 1
                end
            end
        end
    end

    if claimed > 0 then
        Runtime.rewardsClaimed += claimed
        Runtime.lastAction = string.format("Claimed %d reward(s)", claimed)
    end
    return claimed
end

local QueueModeSpecs = {
    ["QuickPlay (TDM / FFA)"] = { kind = "quickplay" },
    ["Classic 1v1"] = { kind = "mmstart", sizes = { 1 }, ranked = false },
    ["Classic 2v2"] = { kind = "mmstart", sizes = { 2 }, ranked = false },
    ["Classic 3v3"] = { kind = "mmstart", sizes = { 3 }, ranked = false },
    ["Classic 4v4"] = { kind = "mmstart", sizes = { 4 }, ranked = false },
    ["Classic 1v1-4v4 Any"] = { kind = "mmstart", sizes = { 1, 2, 3, 4 }, ranked = false },
    ["Ranked 1v1"] = { kind = "mmstart", sizes = { 1 }, ranked = true },
    ["Ranked 2v2"] = { kind = "mmstart", sizes = { 2 }, ranked = true },
    ["Ranked 3v3"] = { kind = "mmstart", sizes = { 3 }, ranked = true },
}

local function startMatchQueue(modeName)
    local matchEv = rem("MatchEvent")
    if not matchEv or not isInLobby() then
        return false
    end
    local spec = QueueModeSpecs[modeName or State.SelectedQueueMode] or QueueModeSpecs["Classic 1v1"]
    if spec.kind == "quickplay" then
        pcall(function()
            matchEv:FireServer("quickplay")
        end)
    else
        pcall(function()
            matchEv:FireServer("mmstart", spec.sizes, spec.ranked == true)
        end)
    end
    Runtime.matchesQueued += 1
    Runtime.lastQueueAt = os.clock()
    Runtime.lastAction = "Queued: " .. tostring(modeName or State.SelectedQueueMode)
    return true
end

local function cancelMatchQueue()
    local matchEv = rem("MatchEvent")
    if matchEv then
        pcall(function()
            matchEv:FireServer("mmcancel")
        end)
        Runtime.lastAction = "Canceled queue"
        return true
    end
    return false
end

local function fireGuiButton(btn)
    if not btn or not btn:IsA("GuiButton") then
        return false
    end
    local fired = false
    if type(getconnections) == "function" then
        for _, sigName in ipairs({ "Activated", "MouseButton1Click" }) do
            local okSig, sig = pcall(function()
                return btn[sigName]
            end)
            if okSig and sig then
                local okConns, list = pcall(getconnections, sig)
                if okConns and type(list) == "table" then
                    for _, conn in ipairs(list) do
                        pcall(function()
                            conn:Fire()
                            fired = true
                        end)
                    end
                end
            end
        end
    end
    return fired
end

local function dismissChestGachaPopup()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local cg = pg and pg:FindFirstChild("ChestGui")
    if not cg or not cg:IsA("ScreenGui") or not cg.Enabled then
        return false
    end
    local fired = false
    local skipBtn = cg:FindFirstChild("SkipButton")
    if skipBtn and skipBtn:IsA("GuiButton") and skipBtn.Visible then
        if fireGuiButton(skipBtn) then
            fired = true
        end
    end
    for _, frameName in ipairs({ "DaggerResultFrame", "DaggerResult10Frame" }) do
        local frame = cg:FindFirstChild(frameName)
        if frame and frame:IsA("GuiObject") and frame.Visible then
            local closeBtn = frame:FindFirstChild("CloseButton")
            if closeBtn and closeBtn:IsA("GuiButton") then
                if fireGuiButton(closeBtn) then
                    fired = true
                end
            end
        end
    end
    return fired
end

local function skipActiveResultAndPopups()
    local acted = false
    if GameG.DaggerLevelUpClose then
        safeCall(GameG.DaggerLevelUpClose)
        acted = true
    end
    if dismissChestGachaPopup() then
        acted = true
    end
    if GameG.DaggerResultSceneActive then
        if type(GameG.DaggerResultGoLobby) == "function" then
            safeCall(GameG.DaggerResultGoLobby)
            acted = true
        else
            local matchEv = rem("MatchEvent")
            if matchEv then
                pcall(function()
                    matchEv:FireServer("resultlobby")
                end)
                acted = true
            end
        end
    end
    local dualHome = rem("DuelPlaceHome")
    if dualHome and GameG.DaggerIsDuelPlace and LocalPlayer:GetAttribute("MatchId") == nil then
        pcall(function()
            dualHome:FireServer("again")
        end)
        acted = true
    end
    return acted
end

local ChestIndexLookup = {
    ["1 - Rare Chest (500)"] = { idx = 1, price1 = 500, price10 = 4500 },
    ["2 - Epic Chest (1,000)"] = { idx = 2, price1 = 1000, price10 = 9500 },
    ["3 - Legendary Chest (2,000)"] = { idx = 3, price1 = 2000, price10 = 19300 },
    ["4 - Kill Effect Chest (1,500)"] = { idx = 4, price1 = 1500, price10 = 14300 },
}

local function buyChestRemote(count)
    local ev = rem("ChestGachaEvent")
    if not ev then
        return false, "ChestGachaEvent missing"
    end
    local info = ChestIndexLookup[State.SelectedChestType] or ChestIndexLookup["1 - Rare Chest (500)"]
    local amt = (count == 10) and 10 or 1
    local cost = (amt == 10) and info.price10 or info.price1
    local gems = tonumber(LocalPlayer:GetAttribute("Diamonds")) or 0
    if gems < cost then
        return false, string.format("Need %s Crystals (have %s)", formatNumber(cost), formatNumber(gems))
    end
    pcall(function()
        ev:FireServer("buy", info.idx, amt)
    end)
    Runtime.chestsOpened += amt
    Runtime.lastChestAt = os.clock()
    Runtime.lastAction = string.format("Opened %dx Chest #%d", amt, info.idx)
    return true
end

local function equipSkillLoadoutRemote(s1, s2)
    local skEv = rem("SkillEvent")
    local saveFn = rem("SaveJumpSettings")
    local loadout = { s1 or State.SelectedSkillSlot1, s2 or State.SelectedSkillSlot2 }
    if skEv then
        pcall(function()
            skEv:FireServer("setloadout", loadout)
        end)
    end
    if saveFn then
        pcall(function()
            saveFn:InvokeServer({ Skill1 = loadout[1], Skill2 = loadout[2] })
        end)
        ensureElevatedIdentity()
    end
    Runtime.lastAction = string.format("Equipped Skills: %s / %s", loadout[1], loadout[2])
    return true
end

local function getLobbyTeleportMap()
    local map = {}
    local sp = Workspace:FindFirstChild("SpawnPlayer")
    local sp1 = sp and sp:FindFirstChild("Spawn1")
    if sp1 and sp1:IsA("BasePart") then
        map["Lobby Spawn"] = sp1.CFrame + Vector3.new(0, 4, 0)
    end
    local function addPad(label, modelName, partName)
        local m = Workspace:FindFirstChild(modelName)
        local p = m and (m:FindFirstChild(partName or "Part") or m:FindFirstChildWhichIsA("BasePart"))
        if p and p:IsA("BasePart") then
            map[label] = p.CFrame + Vector3.new(0, 4, 0)
        end
    end
    addPad("Duel 1v1 Pad", "Duel1v1", "Team1")
    addPad("Duel 2v2 Pad", "Duel2v2", "Team1")
    addPad("Duel 3v3 Pad", "Duel3v3", "Team1")
    addPad("Duel 4v4 Pad", "Duel4v4", "Team1")
    addPad("Duel 1v1v1 Pad", "Duel1v1v1", "Team1")
    addPad("Chest Shop", "ChestShop", "Part")
    addPad("Free Crystal Stand", "CrystalFree", "Part")
    addPad("Community Stand", "JoinCommunity", "Part")
    addPad("Spectate Stand", "SpectateMode", "Part")
    return map
end

local function buildPlayerDropdownList()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    table.sort(names)
    if #names == 0 then
        return { "None" }
    end
    return names
end

-- -------------------------------------------------------------------------
-- 7. BUILD WINDUI TABS & CONTROLS (8 TABS, ALL OFF BY DEFAULT)
-- -------------------------------------------------------------------------
local TabOverview = Window:Tab({ Title = "Overview", Icon = "layout-dashboard" })
local TabDagger = Window:Tab({ Title = "Dagger & Silent Aim", Icon = "crosshair" })
local TabParry = Window:Tab({ Title = "Auto-Parry & Melee", Icon = "shield" })
local TabSkills = Window:Tab({ Title = "Skills & Loadout", Icon = "sparkles" })
local TabMatch = Window:Tab({ Title = "Matchmaking & Lobby", Icon = "swords" })
local TabChests = Window:Tab({ Title = "Chests & Rewards", Icon = "gift" })
local TabVisuals = Window:Tab({ Title = "Player & Visuals", Icon = "eye" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- =========================== TAB 1: OVERVIEW =============================
TabOverview:Section({ Title = "Live Telemetry" })
local CombatStatusPara = TabOverview:Paragraph({
    Title = "Match & Combat Monitor",
    Desc = "Reading player and dagger state...",
})
local ProfileStatusPara = TabOverview:Paragraph({
    Title = "Profile, Economy & Rewards",
    Desc = "Reading progression attributes...",
})

TabOverview:Section({ Title = "Master Autonomous Grinder" })
UI_Elements.AutoPlayMaster = TabOverview:Toggle({
    Title = "Master Auto-Play (Full Autonomous Bot)",
    Desc = "Auto-queues matches, votes arena, runs Silent Auto-Throw + Smart Anti-Parry Teleport + Frame-Perfect Auto-Parry + Melee Aura + Tactical Skills + Escape.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoPlayMaster = v
        Runtime.lastAction = v and "Master Auto-Play Active" or "Master Auto-Play Stopped"
    end,
})
UI_Elements.AutoPlayQueueMode = TabOverview:Dropdown({
    Title = "Master Auto-Play Queue Mode",
    Values = { "Classic 1v1", "Classic 2v2", "Classic 1v1-4v4 Any", "QuickPlay (TDM / FFA)", "Ranked 1v1", "Ranked 2v2" },
    Value = State.AutoPlayQueueMode,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoPlayQueueMode = v
    end,
})

TabOverview:Section({ Title = "Quick Actions" })
TabOverview:Button({
    Title = "Claim All Ready Rewards Now",
    Callback = function()
        local n = claimAllRewardsNow()
        notify("Rewards", n > 0 and string.format("Claimed %d reward(s)!", n) or "No claimable rewards right now.", 3)
    end,
})
TabOverview:Button({
    Title = "Skip Active Result / Level-Up Screen",
    Callback = function()
        local ok = skipActiveResultAndPopups()
        notify("Skip", ok and "Triggered skip/return." or "No active screen detected.", 2.5)
    end,
})

-- ====================== TAB 2: DAGGER & SILENT AIM =======================
TabDagger:Section({ Title = "Silent Aim & Predictive Auto-Throw" })
UI_Elements.SilentAim = TabDagger:Toggle({
    Title = "Silent Aim (Redirects Manual & Auto Throws)",
    Desc = "Hooks DaggerThrowEvent arguments & micro-snaps throw vector to predicted enemy target without moving your visible camera.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SilentAim = v
    end,
})
UI_Elements.TargetLockOn = TabDagger:Toggle({
    Title = "Agile Target Lock-On (Auto-Face & Camera Track)",
    Desc = "Locks character facing and smooth camera tracking onto your active target without erratic target switching.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.TargetLockOn = v
        if not v and not State.AggressiveCombatMove and not State.AutoPlayMaster then
            restoreCombatMovement()
        end
    end,
})
UI_Elements.AutoThrowDagger = TabDagger:Toggle({
    Title = "Auto Throw Dagger At Best Target",
    Desc = "Automatically throws dagger when ready at the highest-priority visible enemy.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoThrowDagger = v
    end,
})
UI_Elements.AimTargetPart = TabDagger:Dropdown({
    Title = "Target Aim Part",
    Values = { "Head", "HumanoidRootPart", "UpperTorso / Torso" },
    Value = State.AimTargetPart,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AimTargetPart = v
    end,
})
UI_Elements.AimPriority = TabDagger:Dropdown({
    Title = "Target Selection Priority",
    Values = { "Closest Crosshair", "Nearest Distance", "Lowest HP" },
    Value = State.AimPriority,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AimPriority = v
    end,
})
UI_Elements.PredictionStrength = TabDagger:Slider({
    Title = "Velocity Prediction (%)",
    Step = 5,
    Value = { Min = 0, Max = 100, Default = State.PredictionStrength },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.PredictionStrength = tonumber(v) or 35
    end,
})

TabDagger:Section({ Title = "Smart Anti-Parry Teleport Strike" })
UI_Elements.AutoTeleportStrike = TabDagger:Toggle({
    Title = "Auto Teleport Strike (On Stuck Target)",
    Desc = "Automatically teleports onto stuck enemy once teleport lock expires.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoTeleportStrike = v
    end,
})
UI_Elements.AntiParryBait = TabDagger:Toggle({
    Title = "Anti-Parry Bait & Safe Auto-Cancel",
    Desc = "Delays teleport while victim is parrying/immune, strikes the instant parry ends, or cancels at 2.82s to avoid 30 reverse damage.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AntiParryBait = v
    end,
})
UI_Elements.PrioritizeStunThrow = TabDagger:Toggle({
    Title = "Prioritize Stun / Finisher Teleport",
    Desc = "Only holds teleport for <= 1.25s when Stun is about to finish recharging on high-HP targets; teleports immediately otherwise.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.PrioritizeStunThrow = v
    end,
})

TabDagger:Section({ Title = "Yellow Flash DaggerPart Escape (0s CD)" })
UI_Elements.AutoDaggerPartEscape = TabDagger:Toggle({
    Title = "Auto DaggerPart Blink Escape On Low HP",
    Desc = "Automatically throws & teleports to the furthest DaggerPart anchor when BattleHP drops below threshold.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoDaggerPartEscape = v
    end,
})
UI_Elements.EscapeHPThreshold = TabDagger:Slider({
    Title = "Escape HP Threshold",
    Step = 5,
    Value = { Min = 15, Max = 65, Default = State.EscapeHPThreshold },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.EscapeHPThreshold = tonumber(v) or 35
    end,
})
TabDagger:Button({
    Title = "Blink To Furthest DaggerPart Now",
    Callback = function()
        local _, hrp = getRootAndHum()
        local cam = Workspace.CurrentCamera
        if not hrp or not cam then return end
        local bestPart, bestDist = nil, -1
        for _, p in ipairs(getArenaDaggerParts()) do
            local d = (p.Position - hrp.Position).Magnitude
            if d >= 15 and d <= 490 and d > bestDist and hasLineOfSight(cam.CFrame.Position, p.Position, p) then
                bestDist = d
                bestPart = p
            end
        end
        if bestPart then
            throwDaggerAtWorldPos(bestPart.Position)
            notify("DaggerPart Blink", string.format("Threw at anchor (%.0f studs) â teleporting!", bestDist), 2.5)
            task.delay(0.28, function()
                if not Unloaded and type(GameG.DaggerTriggerTeleport) == "function" then
                    safeCall(GameG.DaggerTriggerTeleport)
                end
            end)
        else
            notify("DaggerPart Blink", "No visible DaggerPart anchor found in current map.", 2.5)
        end
    end,
})

-- ======================= TAB 3: AUTO-PARRY & MELEE =======================
TabParry:Section({ Title = "Frame-Perfect Auto-Parry" })
UI_Elements.AutoParryTeleport = TabParry:Toggle({
    Title = "Auto-Parry Incoming Teleports (Windup Sniper)",
    Desc = "Hooks DaggerStickEvent windup and triggers parry inside [0.18, windup - 0.10] for guaranteed 30 reverse damage.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoParryTeleport = v
    end,
})
UI_Elements.ParryReactionMs = TabParry:Slider({
    Title = "Windup Parry Timing (ms)",
    Step = 5,
    Value = { Min = 190, Max = 360, Default = State.ParryReactionMs },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.ParryReactionMs = tonumber(v) or 215
    end,
})
UI_Elements.AutoParryMeleeAndGate = TabParry:Toggle({
    Title = "Auto-Parry Close Melee & Gate Attacks",
    Desc = "Monitors nearby enemy Animator tracks for Melee/Gate animations and parries automatically.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoParryMeleeAndGate = v
    end,
})
UI_Elements.AutoBulwarkFallback = TabParry:Toggle({
    Title = "Auto Bulwark Fallback When Parry On Cooldown",
    Desc = "Activates Bulwark skill automatically if targeted while Parry is on cooldown.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoBulwarkFallback = v
    end,
})

TabParry:Section({ Title = "Melee Kill-Aura & CQC Orbit" })
UI_Elements.AutoEquipDagger = TabParry:Toggle({
    Title = "Auto Equip Dagger In Match",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoEquipDagger = v
    end,
})
UI_Elements.MeleeKillAura = TabParry:Toggle({
    Title = "Melee Kill-Aura (12 Stud Reach)",
    Desc = "Faces target and triggers combo-synced melee strikes whenever an enemy is within melee reach.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.MeleeKillAura = v
    end,
})
UI_Elements.AggressiveCombatMove = TabParry:Toggle({
    Title = "Aggressive Combat Footwork (Chase, Strafe & Hop)",
    Desc = "Actively rushes targets with zig-zag strafing, tactical hops, parry kiting, and flank circling.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AggressiveCombatMove = v
        if not v and not State.TargetLockOn and not State.AutoPlayMaster then
            restoreCombatMovement()
        end
    end,
})
UI_Elements.CQCOrbitTarget = TabParry:Toggle({
    Title = "CQC Orbit / Backstab Positioning",
    Desc = "Positions your character behind or around close targets so enemy frontal melee misses.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.CQCOrbitTarget = v
    end,
})
UI_Elements.CQCOrbitMode = TabParry:Dropdown({
    Title = "Orbit Positioning Mode",
    Values = { "Behind Target", "Circle Strafe", "Above Target" },
    Value = State.CQCOrbitMode,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.CQCOrbitMode = v
    end,
})
UI_Elements.CQCOrbitDistance = TabParry:Slider({
    Title = "Orbit Offset Distance",
    Step = 1,
    Value = { Min = 4, Max = 10, Default = State.CQCOrbitDistance },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.CQCOrbitDistance = tonumber(v) or 6
    end,
})
UI_Elements.AutoDashEvade = TabParry:Toggle({
    Title = "Auto Dash Evade Under Threat",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoDashEvade = v
    end,
})

-- ======================== TAB 4: SKILLS & LOADOUT ========================
local AllSkillIds = type(SkillsModule.ORDER) == "table" and SkillsModule.ORDER or {
    "regen", "bulwark", "reflex", "speedster", "bloodlust", "mastercombat",
    "trickster", "recall", "onigate", "hibernation", "detonate", "flurry",
}
local PaidSkillLabels = {}
local PaidSkillLookup = {}
for _, id in ipairs(AllSkillIds) do
    local p = SkillsModule.PRICE and SkillsModule.PRICE[id]
    if p then
        local lbl = string.format("%s (%s Crystals)", id, formatNumber(p))
        table.insert(PaidSkillLabels, lbl)
        PaidSkillLookup[lbl] = id
    end
end
if #PaidSkillLabels == 0 then
    PaidSkillLabels = { "bloodlust" }
    PaidSkillLookup["bloodlust"] = "bloodlust"
end

TabSkills:Section({ Title = "Tactical Skill AI" })
UI_Elements.AutoUseSkills = TabSkills:Toggle({
    Title = "Auto Use Tactical Skills (Context AI)",
    Desc = "Automatically triggers Regen/Hibernate on low HP, Flurry/Detonate/Trickster on target sight, Bloodlust on stuck, MasterCombat/OniGate in CQC.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoUseSkills = v
    end,
})
UI_Elements.SkillHealHP = TabSkills:Slider({
    Title = "Heal / Escape Skill HP Threshold",
    Step = 5,
    Value = { Min = 20, Max = 80, Default = State.SkillHealHP },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SkillHealHP = tonumber(v) or 55
    end,
})

TabSkills:Section({ Title = "Remote Loadout & Skill Shop" })
UI_Elements.SelectedSkillSlot1 = TabSkills:Dropdown({
    Title = "Skill Slot 1",
    Values = AllSkillIds,
    Value = State.SelectedSkillSlot1,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedSkillSlot1 = v
    end,
})
UI_Elements.SelectedSkillSlot2 = TabSkills:Dropdown({
    Title = "Skill Slot 2",
    Values = AllSkillIds,
    Value = State.SelectedSkillSlot2,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedSkillSlot2 = v
    end,
})
TabSkills:Button({
    Title = "Equip Selected 2-Skill Loadout Remotely",
    Callback = function()
        if State.SelectedSkillSlot1 == State.SelectedSkillSlot2 then
            notify("Skill Loadout", "Choose two different skills for Slot 1 and Slot 2.", 3)
            return
        end
        equipSkillLoadoutRemote(State.SelectedSkillSlot1, State.SelectedSkillSlot2)
        notify("Skill Loadout", string.format("Equipped %s & %s.", State.SelectedSkillSlot1, State.SelectedSkillSlot2), 3)
    end,
})
UI_Elements.SelectedBuySkill = TabSkills:Dropdown({
    Title = "Skill To Purchase",
    Values = PaidSkillLabels,
    Value = PaidSkillLabels[1],
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedBuySkill = PaidSkillLookup[v] or v
    end,
})
TabSkills:Button({
    Title = "Purchase Selected Skill Remotely",
    Callback = function()
        local buyFn = rem("SkillBuy")
        if not buyFn then return end
        local ok, res, reason = pcall(function()
            return buyFn:InvokeServer(State.SelectedBuySkill)
        end)
        ensureElevatedIdentity()
        if ok and res == true then
            notify("Skill Purchased", "Unlocked " .. tostring(State.SelectedBuySkill) .. "!", 3)
        else
            notify("Purchase Failed", tostring(reason or "Not enough Crystals or already owned."), 3)
        end
    end,
})

-- ====================== TAB 5: MATCHMAKING & LOBBY =======================
local ArenaVoteMap = {
    ["Random"] = "Random",
    ["A (BASEPLATE)"] = "A",
    ["B (PRISON)"] = "B",
    ["C (ISLANDS)"] = "C",
    ["D (EGYPT)"] = "D",
    ["E (ALTAR)"] = "E",
}

TabMatch:Section({ Title = "Remote Queue & Arena Voting" })
UI_Elements.SelectedQueueMode = TabMatch:Dropdown({
    Title = "Match Queue Mode",
    Values = { "Classic 1v1", "Classic 2v2", "Classic 3v3", "Classic 4v4", "Classic 1v1-4v4 Any", "QuickPlay (TDM / FFA)", "Ranked 1v1", "Ranked 2v2", "Ranked 3v3" },
    Value = State.SelectedQueueMode,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedQueueMode = v
    end,
})
UI_Elements.AutoQueueMatch = TabMatch:Toggle({
    Title = "Auto Queue Selected Mode In Lobby",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoQueueMatch = v
    end,
})
UI_Elements.PreferredArenaVote = TabMatch:Dropdown({
    Title = "Preferred Arena Map Vote",
    Values = { "Random", "A (BASEPLATE)", "B (PRISON)", "C (ISLANDS)", "D (EGYPT)", "E (ALTAR)" },
    Value = State.PreferredArenaVote,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.PreferredArenaVote = v
    end,
})
UI_Elements.AutoVoteArena = TabMatch:Toggle({
    Title = "Auto Vote Preferred Arena",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoVoteArena = v
    end,
})
UI_Elements.AutoSkipResultAndPopups = TabMatch:Toggle({
    Title = "Auto Skip Result Screen & Level-Up Modals",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoSkipResultAndPopups = v
    end,
})
TabMatch:Button({
    Title = "Start Queue Now",
    Callback = function()
        local ok = startMatchQueue(State.SelectedQueueMode)
        notify("Matchmaking", ok and ("Queued " .. State.SelectedQueueMode) or "Must be in Lobby to queue.", 2.5)
    end,
})
TabMatch:Button({
    Title = "Cancel Queue Now",
    Callback = function()
        cancelMatchQueue()
        notify("Matchmaking", "Sent queue cancel.", 2)
    end,
})
TabMatch:Button({
    Title = "Leave Current Match / Unspectate",
    Callback = function()
        local ev = rem("MatchEvent")
        if ev then
            pcall(function() ev:FireServer("leave") end)
            pcall(function() ev:FireServer("unspectate") end)
            notify("Match", "Sent leave/unspectate.", 2.5)
        end
    end,
})

TabMatch:Section({ Title = "1v1 Duel Challenges & Invites" })
UI_Elements.DuelInvitePolicy = TabMatch:Dropdown({
    Title = "Incoming Duel Invite Policy",
    Values = { "Manual", "Auto Accept All", "Auto Decline All" },
    Value = State.DuelInvitePolicy,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.DuelInvitePolicy = v
    end,
})
UI_Elements.AutoHandleDuelInvites = TabMatch:Toggle({
    Title = "Auto Handle Incoming Duel Invites",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoHandleDuelInvites = v
    end,
})
local initialPlayers = buildPlayerDropdownList()
UI_Elements.SelectedChallengePlayer = TabMatch:Dropdown({
    Title = "Target Player For 1v1 Duel",
    Values = initialPlayers,
    Value = initialPlayers[1],
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedChallengePlayer = v
    end,
})
TabMatch:Button({
    Title = "Refresh Server Player List",
    Callback = function()
        local list = buildPlayerDropdownList()
        if UI_Elements.SelectedChallengePlayer and UI_Elements.SelectedChallengePlayer.Refresh then
            pcall(function()
                UI_Elements.SelectedChallengePlayer:Refresh(list)
            end)
        end
        notify("Players", string.format("Found %d other player(s).", list[1] == "None" and 0 or #list), 2.5)
    end,
})
TabMatch:Button({
    Title = "Send 1v1 Duel Challenge Remotely",
    Callback = function()
        local targetPlr = Players:FindFirstChild(State.SelectedChallengePlayer)
        local ev = rem("MatchEvent")
        if ev and targetPlr then
            pcall(function()
                ev:FireServer("duelchallenge", targetPlr.UserId)
            end)
            notify("Duel Challenge", "Challenged " .. targetPlr.Name .. "!", 2.5)
        else
            notify("Duel Challenge", "Select a valid player in the server first.", 2.5)
        end
    end,
})

TabMatch:Section({ Title = "Lobby Pad Teleports" })
UI_Elements.SelectedLobbyTeleport = TabMatch:Dropdown({
    Title = "Lobby Destination",
    Values = { "Lobby Spawn", "Duel 1v1 Pad", "Duel 2v2 Pad", "Duel 3v3 Pad", "Duel 4v4 Pad", "Duel 1v1v1 Pad", "Chest Shop", "Free Crystal Stand", "Community Stand", "Spectate Stand" },
    Value = State.SelectedLobbyTeleport,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedLobbyTeleport = v
    end,
})
TabMatch:Button({
    Title = "Teleport To Lobby Destination",
    Callback = function()
        local map = getLobbyTeleportMap()
        local cf = map[State.SelectedLobbyTeleport]
        if cf and safeTeleportCF(cf) then
            notify("Teleported", "Moved to " .. State.SelectedLobbyTeleport, 2)
        else
            notify("Teleport Failed", "Destination not found in current place.", 2.5)
        end
    end,
})

-- ======================== TAB 6: CHESTS & REWARDS ========================
TabChests:Section({ Title = "Automated Rewards Claimer" })
UI_Elements.AutoClaimRewards = TabChests:Toggle({
    Title = "Auto Claim Daily, Playtime & Favorite Rewards",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoClaimRewards = v
    end,
})
TabChests:Button({
    Title = "Claim All Ready Rewards Now",
    Callback = function()
        local n = claimAllRewardsNow()
        notify("Rewards", n > 0 and string.format("Claimed %d reward(s)!", n) or "No claimable rewards right now.", 3)
    end,
})

TabChests:Section({ Title = "Remote Chest Shop & Instant Gacha Skip" })
UI_Elements.InstantSkipGacha = TabChests:Toggle({
    Title = "Instant Skip Chest Gacha Animation (0s Open)",
    Desc = "Automatically skips chest roulette and dismisses result dialogs.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.InstantSkipGacha = v
    end,
})
UI_Elements.SelectedChestType = TabChests:Dropdown({
    Title = "Chest Selection",
    Values = { "1 - Rare Chest (500)", "2 - Epic Chest (1,000)", "3 - Legendary Chest (2,000)", "4 - Kill Effect Chest (1,500)" },
    Value = State.SelectedChestType,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedChestType = v
    end,
})
UI_Elements.AutoOpenChests = TabChests:Toggle({
    Title = "Auto Open Selected Chest (1x Loop In Lobby)",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoOpenChests = v
    end,
})
TabChests:Button({
    Title = "Buy 1x Selected Chest Remotely",
    Callback = function()
        local ok, err = buyChestRemote(1)
        notify("Chest Shop", ok and "Purchased 1x chest!" or tostring(err), 3)
    end,
})
TabChests:Button({
    Title = "Buy 10x Selected Chest Remotely",
    Callback = function()
        local ok, err = buyChestRemote(10)
        notify("Chest Shop", ok and "Purchased 10x chests!" or tostring(err), 3)
    end,
})

TabChests:Section({ Title = "Transform, Kill Effects & Emotes" })
UI_Elements.AutoTransformWeapon = TabChests:Toggle({
    Title = "Auto Transform Eligible Legendary Weapon",
    Desc = "Automatically triggers DaggerTransformEvent when holding AWM/Guitar/Reaper pairs.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoTransformWeapon = v
    end,
})
local KillEffectList = (Config.KILL_EFFECTS and Config.KILL_EFFECTS.ORDER) or { "Common", "Fire", "Loved", "Thomb", "Jail", "AbyssBurn", "Hammer", "Freeze", "Hellshock", "Vanish" }
UI_Elements.SelectedKillEffect = TabChests:Dropdown({
    Title = "Kill Effect",
    Values = KillEffectList,
    Value = State.SelectedKillEffect,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedKillEffect = v
    end,
})
TabChests:Button({
    Title = "Equip Selected Kill Effect",
    Callback = function()
        local ev = rem("KillEffectEquip")
        if ev then
            pcall(function() ev:FireServer(State.SelectedKillEffect) end)
            notify("Kill Effect", "Equipped " .. State.SelectedKillEffect, 2.5)
        end
    end,
})
local EmoteList = (Config.EMOTES and Config.EMOTES.ORDER) or { "Clap", "Fresh", "Guitar", "HappyFeet", "Whoa" }
UI_Elements.SelectedEmote = TabChests:Dropdown({
    Title = "Emote",
    Values = EmoteList,
    Value = State.SelectedEmote,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.SelectedEmote = v
    end,
})
TabChests:Button({
    Title = "Equip & Play Selected Emote",
    Callback = function()
        local ev = rem("EmoteEvent")
        if ev then
            pcall(function() ev:FireServer("equip", State.SelectedEmote) end)
            pcall(function() ev:FireServer("play", State.SelectedEmote) end)
            notify("Emote", "Played " .. State.SelectedEmote, 2.5)
        end
    end,
})

-- ======================== TAB 7: PLAYER & VISUALS ========================
TabVisuals:Section({ Title = "Tactical Combat ESP (Stealth Container)" })
UI_Elements.EnemyCombatESP = TabVisuals:Toggle({
    Title = "Enemy Combat ESP (HP, State, Distance, Dagger)",
    Desc = "Color-coded status ESP: Yellow = Parrying, Cyan = Immune, Green = Stuck Dagger, Purple = Bot, Red = Vulnerable.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.EnemyCombatESP = v
    end,
})
UI_Elements.DaggerAndAnchorESP = TabVisuals:Toggle({
    Title = "Thrown Dagger & DaggerPart Anchor ESP",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.DaggerAndAnchorESP = v
    end,
})
UI_Elements.IncomingThreatAlert = TabVisuals:Toggle({
    Title = "Incoming Stuck / Windup Threat Alert",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.IncomingThreatAlert = v
    end,
})

TabVisuals:Section({ Title = "Movement & Camera Overrides" })
UI_Elements.CustomWalkSpeed = TabVisuals:Toggle({
    Title = "Enable Custom WalkSpeed",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.CustomWalkSpeed = v
        if not v then restoreWalkSpeed() end
    end,
})
UI_Elements.WalkSpeed = TabVisuals:Slider({
    Title = "WalkSpeed",
    Step = 2,
    Value = { Min = 18, Max = 80, Default = State.WalkSpeed },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.WalkSpeed = tonumber(v) or 28
    end,
})
UI_Elements.CustomJumpPower = TabVisuals:Toggle({
    Title = "Enable Custom JumpPower",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.CustomJumpPower = v
        if not v then restoreJumpPower() end
    end,
})
UI_Elements.JumpPower = TabVisuals:Slider({
    Title = "JumpPower",
    Step = 5,
    Value = { Min = 50, Max = 140, Default = State.JumpPower },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.JumpPower = tonumber(v) or 75
    end,
})
UI_Elements.InfiniteJump = TabVisuals:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.InfiniteJump = v
    end,
})
UI_Elements.NoClip = TabVisuals:Toggle({
    Title = "NoClip",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.NoClip = v
        if not v then restoreNoClip() end
    end,
})
UI_Elements.Fly = TabVisuals:Toggle({
    Title = "Fly (WASD + Space / LeftShift)",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.Fly = v
        if not v then restoreFly() end
    end,
})
UI_Elements.FlySpeed = TabVisuals:Slider({
    Title = "Fly Speed",
    Step = 5,
    Value = { Min = 30, Max = 150, Default = State.FlySpeed },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.FlySpeed = tonumber(v) or 70
    end,
})
UI_Elements.CustomFOV = TabVisuals:Toggle({
    Title = "Custom Camera FOV",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.CustomFOV = v
        applyCustomFOV(v)
    end,
})
UI_Elements.FOVValue = TabVisuals:Slider({
    Title = "Camera FOV",
    Step = 5,
    Value = { Min = 60, Max = 120, Default = State.FOVValue },
    Callback = function(v)
        if SuppressCallbacks then return end
        State.FOVValue = tonumber(v) or 95
        if State.CustomFOV then
            applyCustomFOV(true)
        end
    end,
})
UI_Elements.Fullbright = TabVisuals:Toggle({
    Title = "Fullbright",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.Fullbright = v
        applyFullbright(v)
    end,
})
UI_Elements.AntiCameraShakeAndFlash = TabVisuals:Toggle({
    Title = "Disable Camera Shake & Screen Flash",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AntiCameraShakeAndFlash = v
        applyAntiShakeAndFlash(v)
    end,
})

-- ============================= TAB 8: CONFIG =============================
local function getConfigPath(profileName)
    local safeName = tostring(profileName or "default"):gsub("[^%w%-%_]", "_")
    if safeName == "" then safeName = "default" end
    return CONFIG_DIR .. "/" .. safeName .. ".json"
end

local function ensureConfigDir()
    if type(isfolder) == "function" and type(makefolder) == "function" then
        if not isfolder(CONFIG_DIR) then
            pcall(makefolder, CONFIG_DIR)
        end
    end
end

local function syncElementVisual(key, value)
    local elem = UI_Elements[key]
    if not elem then return end
    SuppressCallbacks = true
    ensureElevatedIdentity()
    pcall(function()
        if elem.Set then
            elem:Set(value)
        elseif elem.Select then
            elem:Select(value)
        end
    end)
    SuppressCallbacks = false
end

local function saveConfig(profileName)
    if type(writefile) ~= "function" then
        notify("Config Error", "Filesystem API unavailable.", 3)
        return false
    end
    ensureConfigDir()
    local payload = HttpService:JSONEncode(State)
    local path = getConfigPath(profileName or State.ConfigName)
    local ok = pcall(writefile, path, payload)
    if ok then
        notify("Config Saved", "Saved profile to " .. path, 2.5)
    end
    return ok
end

local function loadConfig(profileName)
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return false
    end
    local path = getConfigPath(profileName or State.ConfigName)
    if not isfile(path) then
        notify("Config Not Found", "No saved config at " .. path, 3)
        return false
    end
    local okRead, raw = pcall(readfile, path)
    if not okRead then return false end
    local okDec, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not okDec or type(decoded) ~= "table" then return false end

    for k, v in pairs(decoded) do
        if State[k] ~= nil then
            State[k] = v
            syncElementVisual(k, v)
        end
    end
    applyAntiAfkState(State.AntiAfk == true)
    applyFullbright(State.Fullbright == true)
    applyCustomFOV(State.CustomFOV == true)
    applyAntiShakeAndFlash(State.AntiCameraShakeAndFlash == true)
    if not State.CustomWalkSpeed then restoreWalkSpeed() end
    if not State.CustomJumpPower then restoreJumpPower() end
    if not State.NoClip then restoreNoClip() end
    if not State.Fly then restoreFly() end
    if not State.TargetLockOn and not State.AggressiveCombatMove and not State.AutoPlayMaster then
        restoreCombatMovement()
    end
    notify("Config Loaded", "Loaded profile from " .. path, 2.5)
    return true
end

local function deleteConfig(profileName)
    if type(isfile) == "function" and type(delfile) == "function" then
        local path = getConfigPath(profileName or State.ConfigName)
        if isfile(path) then
            pcall(delfile, path)
            notify("Config Deleted", "Deleted " .. path, 2.5)
            return true
        end
    end
    return false
end

local function resetAllToOff()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
            syncElementVisual(k, false)
        end
    end
    applyAntiAfkState(false)
    applyFullbright(false)
    applyCustomFOV(false)
    applyAntiShakeAndFlash(false)
    restoreWalkSpeed()
    restoreJumpPower()
    restoreNoClip()
    restoreFly()
    restoreCombatMovement()
    Runtime.lastAction = "All Toggles Reset OFF"
    notify("Reset Complete", "All features turned OFF and baselines restored.", 2.5)
end

TabConfig:Section({ Title = "Anti-AFK & Teleport Persistence" })
UI_Elements.AntiAfk = TabConfig:Toggle({
    Title = "Anti-AFK (Dual-Layer Idled + 18.5m AutoRejoin Block)",
    Desc = "Blocks Roblox 20m Idled kick via VirtualUser AND disables PlayerScripts.AutoRejoin 18.5m idle lobby rejoin.",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AntiAfk = v
        applyAntiAfkState(v)
    end,
})
UI_Elements.AutoReExecuteOnTeleport = TabConfig:Toggle({
    Title = "Auto Re-Execute On Server Hop / Teleport",
    Value = false,
    Callback = function(v)
        if SuppressCallbacks then return end
        State.AutoReExecuteOnTeleport = v
        if v and type(queue_on_teleport) == "function" and type(isfile) == "function" and type(readfile) == "function" then
            local p = "E:\\SC\\Teleport Duels\\TeleportDuels_Master.lua"
            if isfile(p) then
                pcall(queue_on_teleport, readfile(p))
            end
        end
    end,
})

TabConfig:Section({ Title = "Configuration Profiles" })
UI_Elements.ConfigName = TabConfig:Input({
    Title = "Config Profile Name",
    Value = State.ConfigName,
    Placeholder = "default",
    Callback = function(v)
        if SuppressCallbacks then return end
        State.ConfigName = (v ~= "" and v or "default")
    end,
})
TabConfig:Button({
    Title = "Save Config",
    Callback = function() saveConfig(State.ConfigName) end,
})
TabConfig:Button({
    Title = "Load Config",
    Callback = function() loadConfig(State.ConfigName) end,
})
TabConfig:Button({
    Title = "Delete Config",
    Callback = function() deleteConfig(State.ConfigName) end,
})
TabConfig:Button({
    Title = "Reset All Settings (All OFF)",
    Callback = resetAllToOff,
})
TabConfig:Button({
    Title = "Unload Script Completely",
    Callback = function()
        if type(shared) == "table" and type(shared.XLunaTD_Unload) == "function" then
            shared.XLunaTD_Unload()
        end
    end,
})

TabConfig:Section({ Title = "Compliance Summary" })
TabConfig:Paragraph({
    Title = "XLunaHUB Compliance Card",
    Desc = "Title: Teleport Duels | Author: By XLunaHUB | ToggleKey: LeftControl | Floating Button: Active | Default Startup State: ALL OFF | GUI/ESP Parent: gethui() / CoreGui",
})

-- -------------------------------------------------------------------------
-- 8. REAL-TIME EVENT HOOKS (SILENT AIM, WINDUP PARRY, GACHA SKIP, DUELS)
-- -------------------------------------------------------------------------
local DaggerThrowEvent = rem("DaggerThrowEvent")
local DaggerStickEvent = rem("DaggerStickEvent")
local ChestGachaEvent = rem("ChestGachaEvent")
local MatchEvent = rem("MatchEvent")

-- Silent Aim interception on DaggerThrowEvent:FireServer
local function processSilentThrowArgs(args)
    local target, predPos, targetPart = pickBestCombatTarget(true, false, 475)
    if not target or not predPos or not targetPart then
        return false
    end
    local cam = Workspace.CurrentCamera
    local camPos = cam and cam.CFrame.Position or (typeof(args[2]) == "CFrame" and args[2].Position)
    if not camPos then
        return false
    end
    local startPos = typeof(args[2]) == "CFrame" and args[2].Position or camPos
    args[2] = CFrame.lookAt(startPos, predPos)
    args[3] = predPos
    args[5] = CFrame.lookAt(camPos, predPos)
    if type(args[7]) == "table" then
        args[7].aim = predPos
        args[7].origin = camPos
        args[7].part = targetPart
        args[7].pos = predPos
        args[7].land = nil
        args[7].landPart = nil
        args[7].fx = true
    end
    if typeof(args[8]) == "Vector3" then
        args[8] = (predPos - camPos).Unit
    end
    return true
end

local inSilentThrow = false
if type(STATE) == "table" and type(STATE.namecallHook) == "function" and DaggerThrowEvent then
    STATE.namecallHook("FireServer", function(self, method, ...)
        if inSilentThrow or Unloaded or not State.SilentAim or self ~= DaggerThrowEvent then
            return
        end
        local args = table.pack(...)
        if processSilentThrowArgs(args) then
            Runtime.silentAimRedirects += 1
            inSilentThrow = true
            pcall(function()
                self:FireServer(table.unpack(args, 1, args.n))
            end)
            inSilentThrow = false
            return true
        end
    end)
elseif type(hookmetamethod) == "function" and type(newcclosure) == "function" and DaggerThrowEvent then
    local oldNamecall = nil
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not Unloaded and State.SilentAim and not checkcaller() and self == DaggerThrowEvent and getnamecallmethod() == "FireServer" then
            local args = table.pack(...)
            if processSilentThrowArgs(args) then
                Runtime.silentAimRedirects += 1
                return oldNamecall(self, table.unpack(args, 1, args.n))
            end
        end
        return oldNamecall(self, ...)
    end))
    table.insert(Cleanups, function()
        if oldNamecall and type(restorefunction) == "function" then
            pcall(restorefunction, oldNamecall)
        end
    end)
end

-- Auto-Parry Windup, Parry-Bait Tracking & Threat Alerts
if DaggerStickEvent then
    trackConn(DaggerStickEvent.OnClientEvent:Connect(function(kind, a2, a3)
        if Unloaded then return end
        if kind == "hit" then
            Runtime.stuckSince = os.clock()
            Runtime.targetIsParrying = false
        elseif kind == "parryon" then
            Runtime.targetIsParrying = true
            Runtime.parryEndedAt = os.clock() + (tonumber(a2) or 1.0)
        elseif kind == "parryoff" or kind == "end" or kind == "blocked" or kind == "parried" then
            Runtime.targetIsParrying = false
            Runtime.parryEndedAt = 0
        elseif kind == "start" then
            if State.IncomingThreatAlert and (os.clock() - Runtime.lastThreatAlertAt) >= 1.2 then
                Runtime.lastThreatAlertAt = os.clock()
                notify("Threat Alert", tostring(a3 or "Enemy") .. " stuck a dagger on you!", 2)
            end
            if (State.AutoUseSkills or State.AutoPlayMaster) and State.AutoBulwarkFallback then
                local equipped = getEquippedSkillsList()
                if table.find(equipped, "bulwark") and isSkillReady("bulwark") then
                    useSkillById("bulwark")
                end
            end
        elseif kind == "windup" then
            if State.IncomingThreatAlert and (os.clock() - Runtime.lastThreatAlertAt) >= 1.2 then
                Runtime.lastThreatAlertAt = os.clock()
                notify("PARRY NOW!", tostring(a3 or "Enemy") .. " is teleporting to you!", 1.5)
            end
            if State.AutoParryTeleport or State.AutoPlayMaster then
                local dur = tonumber(a2) or 0.5
                local delaySec = math.clamp((tonumber(State.ParryReactionMs) or 215) / 1000, 0.19, math.max(0.20, dur - 0.11))
                task.delay(delaySec, function()
                    if Unloaded or (not State.AutoParryTeleport and not State.AutoPlayMaster) then
                        return
                    end
                    local okParried = false
                    if type(GameG.DaggerTriggerParry) == "function" then
                        safeCall(GameG.DaggerTriggerParry)
                        Runtime.parriesTriggered += 1
                        Runtime.lastAction = string.format("Auto-Parried %s (%.0fms)", tostring(a3 or "Teleport"), delaySec * 1000)
                        okParried = true
                    end
                    if okParried and (State.AutoBulwarkFallback or State.AutoPlayMaster) then
                        -- If parry went on cooldown during double-threat, bulwark fallback is handled on next windup
                    end
                end)
            end
        end
    end))
end

-- Instant Gacha Skip Listener
if ChestGachaEvent then
    trackConn(ChestGachaEvent.OnClientEvent:Connect(function(kind, payload)
        if Unloaded then return end
        if kind == "start" and State.InstantSkipGacha then
            Runtime.lastAction = "Skipped Gacha Spin"
            task.delay(0.1, function()
                if not Unloaded and State.InstantSkipGacha then
                    dismissChestGachaPopup()
                end
            end)
            task.delay(0.35, function()
                if not Unloaded and State.InstantSkipGacha then
                    dismissChestGachaPopup()
                end
            end)
        end
    end))
end

-- Auto Duel Challenge Handler
if MatchEvent then
    trackConn(MatchEvent.OnClientEvent:Connect(function(kind, payload)
        if Unloaded then return end
        if kind == "duelchallenge" and type(payload) == "table" and payload.from and State.AutoHandleDuelInvites then
            if State.DuelInvitePolicy == "Auto Accept All" then
                pcall(function()
                    MatchEvent:FireServer("duelaccept", payload.from)
                end)
                Runtime.lastAction = "Accepted 1v1 from " .. tostring(payload.name or payload.from)
            elseif State.DuelInvitePolicy == "Auto Decline All" then
                pcall(function()
                    MatchEvent:FireServer("dueldecline", payload.from)
                end)
                Runtime.lastAction = "Declined 1v1 from " .. tostring(payload.name or payload.from)
            end
        end
    end))
end

trackConn(UserInputService.JumpRequest:Connect(function()
    if Unloaded or not State.InfiniteJump then return end
    local _, _, hum = getRootAndHum()
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

trackConn(LocalPlayer.Idled:Connect(MyIdledHandlerFn))

-- -------------------------------------------------------------------------
-- 9. TACTICAL ESP SYSTEM (gethui() / CoreGui -> XLuna_TD_ESP)
-- -------------------------------------------------------------------------
local EspContainer = Instance.new("Folder")
EspContainer.Name = "XLuna_TD_ESP"
EspContainer.Parent = getStealthContainerParent()
table.insert(Cleanups, function()
    if EspContainer and EspContainer.Parent then
        EspContainer:Destroy()
    end
end)

local EnemyEspMap = {}
local AnchorEspMap = {}

local function clearEspTable(tbl)
    for k, entry in pairs(tbl) do
        if entry.hl and entry.hl.Parent then entry.hl:Destroy() end
        if entry.bb and entry.bb.Parent then entry.bb:Destroy() end
        tbl[k] = nil
    end
end

local function createBoxEsp(adornee, namePrefix, color)
    local hl = Instance.new("Highlight")
    hl.Name = namePrefix .. "_HL"
    hl.Adornee = adornee
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.62
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = EspContainer

    local bb = Instance.new("BillboardGui")
    bb.Name = namePrefix .. "_BB"
    bb.Adornee = adornee:IsA("Model") and (adornee:FindFirstChild("Head") or adornee.PrimaryPart or adornee:FindFirstChildWhichIsA("BasePart")) or adornee
    bb.Size = UDim2.fromOffset(180, 38)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = EspContainer

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.25
    lbl.TextWrapped = true
    lbl.Parent = bb

    return { hl = hl, bb = bb, lbl = lbl }
end

local function updateTacticalESP()
    if Unloaded then return end
    if not State.EnemyCombatESP then
        if next(EnemyEspMap) ~= nil then clearEspTable(EnemyEspMap) end
    else
        local _, myHrp = getRootAndHum()
        local active = {}
        for _, t in ipairs(getValidCombatTargets()) do
            active[t.model] = t
            local entry = EnemyEspMap[t.model]
            if not entry then
                entry = createBoxEsp(t.model, "TD_Enemy", Color3.fromRGB(255, 70, 70))
                EnemyEspMap[t.model] = entry
            end
            local col = Color3.fromRGB(255, 75, 75)
            local tag = ""
            if t.isParrying then
                col = Color3.fromRGB(255, 215, 0)
                tag = " [PARRYING]"
            elseif t.isImmune then
                col = Color3.fromRGB(0, 220, 255)
                tag = " [IMMUNE]"
            elseif (t.model:GetAttribute("StuckCount") or 0) > 0 then
                col = Color3.fromRGB(75, 255, 110)
                tag = " [STUCK]"
            elseif t.kind == "Bot" then
                col = Color3.fromRGB(200, 120, 255)
                tag = " [BOT]"
            end
            local dist = myHrp and (t.hrp.Position - myHrp.Position).Magnitude or 0
            local tool = t.model:FindFirstChildOfClass("Tool")
            local weaponName = tool and ((Config.DAGGER_DISPLAY_NAMES and Config.DAGGER_DISPLAY_NAMES[tool.Name]) or tool.Name) or "Unarmed"
            entry.hl.FillColor = col
            entry.lbl.TextColor3 = col
            entry.lbl.Text = string.format("%s%s\n%.0f/%.0f HP | %.0fm | %s", t.name, tag, t.hp, t.maxHp, dist, weaponName)
        end
        for model, entry in pairs(EnemyEspMap) do
            if not active[model] or not model.Parent then
                if entry.hl then entry.hl:Destroy() end
                if entry.bb then entry.bb:Destroy() end
                EnemyEspMap[model] = nil
            end
        end
    end

    if not State.DaggerAndAnchorESP then
        if next(AnchorEspMap) ~= nil then clearEspTable(AnchorEspMap) end
    else
        local _, myHrp = getRootAndHum()
        local active = {}
        for _, p in ipairs(getArenaDaggerParts()) do
            active[p] = true
            local entry = AnchorEspMap[p]
            if not entry then
                entry = createBoxEsp(p, "TD_Anchor", Color3.fromRGB(0, 255, 175))
                AnchorEspMap[p] = entry
            end
            local dist = myHrp and (p.Position - myHrp.Position).Magnitude or 0
            entry.lbl.Text = string.format("DaggerPart (0s CD)\n%.0fm", dist)
        end
        for _, ch in ipairs(Workspace:GetChildren()) do
            if ch.Name:sub(1, 12) == "ThrownDagger" then
                local bp = ch:IsA("BasePart") and ch or ch:FindFirstChildWhichIsA("BasePart")
                if bp then
                    active[bp] = true
                    local entry = AnchorEspMap[bp]
                    if not entry then
                        entry = createBoxEsp(bp, "TD_Dagger", Color3.fromRGB(255, 150, 0))
                        AnchorEspMap[bp] = entry
                    end
                    local dist = myHrp and (bp.Position - myHrp.Position).Magnitude or 0
                    entry.lbl.Text = string.format("%s\n%.0fm", ch.Name, dist)
                end
            end
        end
        for inst, entry in pairs(AnchorEspMap) do
            if not active[inst] or not inst.Parent then
                if entry.hl then entry.hl:Destroy() end
                if entry.bb then entry.bb:Destroy() end
                AnchorEspMap[inst] = nil
            end
        end
    end
end

-- -------------------------------------------------------------------------
-- 10. HIGH-FREQUENCY MOVEMENT, CQC ORBIT & MELEE PARRY HEARTBEAT
-- -------------------------------------------------------------------------
local lastMeleeAutoParryAt = 0
local cqcOrbitAngle = 0

trackConn(RunService.Heartbeat:Connect(function(dt)
    if Unloaded then return end
    local char, hrp, hum = getRootAndHum()
    if not char or not hrp or not hum then return end

    if State.CustomWalkSpeed then
        if MovementOrig.WalkSpeed == nil then
            MovementOrig.WalkSpeed = (hum.WalkSpeed > 1) and hum.WalkSpeed or (isInLobby() and 26 or 18)
        end
        if hum.WalkSpeed ~= State.WalkSpeed then hum.WalkSpeed = State.WalkSpeed end
    end
    if State.CustomJumpPower then
        if MovementOrig.UseJumpPower == nil then
            MovementOrig.UseJumpPower = hum.UseJumpPower
            MovementOrig.JumpPower = (hum.JumpPower > 1) and hum.JumpPower or 50
            MovementOrig.JumpHeight = (hum.JumpHeight > 0.5) and hum.JumpHeight or 7.2
        end
        if not hum.UseJumpPower then hum.UseJumpPower = true end
        if hum.JumpPower ~= State.JumpPower then hum.JumpPower = State.JumpPower end
    end

    if State.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if NoClipModified[part] == nil then
                    NoClipModified[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end

    if State.Fly then
        local cam = Workspace.CurrentCamera
        if cam then
            local dir = Vector3.zero
            if hum.MoveDirection.Magnitude > 0 then
                local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
                local moveUnit = hum.MoveDirection.Unit
                local fwdDot = flatLook.Magnitude > 0.01 and moveUnit:Dot(flatLook.Unit) or 0
                local rightDot = flatRight.Magnitude > 0.01 and moveUnit:Dot(flatRight.Unit) or 0
                dir = (cam.CFrame.LookVector * fwdDot) + (cam.CFrame.RightVector * rightDot)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir += Vector3.new(0, -1, 0) end
            if dir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + dir.Unit * (State.FlySpeed * dt)
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- Auto-Parry Melee & Gate Animations + Melee Kill-Aura (Heartbeat)
    local now = os.clock()
    local inMatchNow = isInMatch()
    local inCountdown = type(GameG.DaggerInCountdown) == "function" and safeCall(GameG.DaggerInCountdown) == true

    if (State.AutoParryMeleeAndGate or State.AutoPlayMaster) and inMatchNow and (now - lastMeleeAutoParryAt) >= 0.4 then
        for _, t in ipairs(getValidCombatTargets()) do
            local dist = (t.hrp.Position - hrp.Position).Magnitude
            if dist <= 14.5 then
                local animator = t.hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        local animName = track.Animation and track.Animation.Name or ""
                        local animId = track.Animation and track.Animation.AnimationId or ""
                        if animName:find("Melee") or animName:find("Gate") or animId == (Config.MELEE and Config.MELEE.HIT3_ANIM) or animId == (SkillsModule.ANIM and SkillsModule.ANIM.gateSummon) then
                            local toMe = (hrp.Position - t.hrp.Position).Unit
                            if t.hrp.CFrame.LookVector:Dot(toMe) >= 0.1 and type(GameG.DaggerTriggerParry) == "function" then
                                safeCall(GameG.DaggerTriggerParry)
                                lastMeleeAutoParryAt = now
                                Runtime.parriesTriggered += 1
                                Runtime.lastAction = "Auto-Parried Melee/Gate"
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    local votingActive = isArenaVotingActive()
    local combatActive = inMatchNow and not inCountdown and not votingActive and hum.Health > 0 and not GameG.DaggerKnocked and not GameG.DaggerLobbyLock and not GameG.DaggerSpectateLock
    if combatActive and (State.MeleeKillAura or State.AutoPlayMaster) then
        local locked = resolveStickyCombatTarget(480)
        if (now - Runtime.lastMeleeAt) > 2.1 then
            Runtime.meleeComboStep = 0
        end
        if now >= Runtime.meleeRecoverUntil and (now - Runtime.lastMeleeAt) >= 0.36 then
            local lockUntil = char:GetAttribute("MeleeLockUntil")
            if not lockUntil or Workspace:GetServerTimeNow() >= tonumber(lockUntil) then
                local cqcTarget = nil
                if locked and locked.hrp and not locked.isImmune and not locked.isParrying then
                    local dLock = (locked.hrp.Position - hrp.Position).Magnitude
                    if dLock <= 10.6 and hasLineOfSight(hrp.Position, locked.hrp.Position, locked.model) then
                        cqcTarget = locked
                    end
                end
                if not cqcTarget then
                    local bestDist = 10.6
                    for _, t in ipairs(getValidCombatTargets()) do
                        if not t.isImmune and not t.isParrying then
                            local d = (t.hrp.Position - hrp.Position).Magnitude
                            if d < bestDist and hasLineOfSight(hrp.Position, t.hrp.Position, t.model) then
                                bestDist = d
                                cqcTarget = t
                            end
                        end
                    end
                end
                if cqcTarget then
                    equipDaggerFromBackpack()
                    local lookPt = Vector3.new(cqcTarget.hrp.Position.X, hrp.Position.Y, cqcTarget.hrp.Position.Z)
                    if (lookPt - hrp.Position).Magnitude > 0.1 then
                        hrp.CFrame = CFrame.lookAt(hrp.Position, lookPt)
                    end
                    if type(GameG.DaggerTriggerMelee) == "function" then
                        safeCall(GameG.DaggerTriggerMelee)
                        Runtime.meleeSwings += 1
                        Runtime.lastMeleeAt = now
                        Runtime.meleeComboStep += 1
                        if Runtime.meleeComboStep >= 3 then
                            Runtime.meleeComboStep = 0
                            Runtime.meleeRecoverUntil = now + 0.82
                        end
                    end
                end
            end
        end
    elseif not combatActive and (Runtime.origAutoRotate ~= nil or Runtime.wasCombatMoving) then
        restoreCombatMovement()
    end
end))

-- Pre-Physics Combat Steering & Target Facing Lock (Input+10 overrides ControlModule before C++ Humanoid move step)
RunService:BindToRenderStep("XLunaTD_CombatSteer", Enum.RenderPriority.Input.Value + 10, function(dt)
    if Unloaded then return end
    local char, hrp, hum = getRootAndHum()
    if not char or not hrp or not hum then return end

    local now = os.clock()
    local inMatchNow = isInMatch()
    local inCountdown = type(GameG.DaggerInCountdown) == "function" and safeCall(GameG.DaggerInCountdown) == true
    local moveAI = (State.AggressiveCombatMove or State.AutoPlayMaster) == true
    local lockAI = (State.TargetLockOn or moveAI) == true
    local votingActive = isArenaVotingActive()
    local combatActive = inMatchNow and not inCountdown and not votingActive and hum.Health > 0 and hum.WalkSpeed > 1 and not hrp.Anchored and not GameG.DaggerKnocked and not GameG.DaggerLobbyLock and not GameG.DaggerSpectateLock

    if not combatActive or (not lockAI and not State.CQCOrbitTarget) then
        if Runtime.origAutoRotate ~= nil or Runtime.wasCombatMoving then
            restoreCombatMovement()
        end
        return
    end

    local locked = resolveStickyCombatTarget(480)

    -- Sticky Horizontal Facing Lock
    if lockAI and locked and locked.hrp and not State.Fly then
        if Runtime.origAutoRotate == nil then
            Runtime.origAutoRotate = hum.AutoRotate
        end
        if hum.AutoRotate then
            hum.AutoRotate = false
        end
        local lookFlat = Vector3.new(locked.hrp.Position.X, hrp.Position.Y, locked.hrp.Position.Z)
        if (lookFlat - hrp.Position).Magnitude > 0.15 then
            hrp.CFrame = CFrame.lookAt(hrp.Position, lookFlat)
        end
    elseif Runtime.origAutoRotate ~= nil then
        local shiftLockActive = type(GameG.DaggerShiftLockIsOn) == "function" and safeCall(GameG.DaggerShiftLockIsOn) == true
        hum.AutoRotate = shiftLockActive and false or true
        Runtime.origAutoRotate = nil
    end

    -- Wall & Void-Safe CQC Orbit / Backstab Positioning
    local orbitedThisFrame = false
    if State.CQCOrbitTarget then
        local orbitTarget = nil
        if locked and locked.hrp and not locked.isImmune and not locked.isParrying and (locked.hrp.Position - hrp.Position).Magnitude <= 18 then
            orbitTarget = locked
        else
            local bestD = 18
            for _, t in ipairs(getValidCombatTargets()) do
                if not t.isImmune and not t.isParrying then
                    local d = (t.hrp.Position - hrp.Position).Magnitude
                    if d < bestD then
                        bestD = d
                        orbitTarget = t
                    end
                end
            end
        end
        if orbitTarget and orbitTarget.hrp then
            local distOff = tonumber(State.CQCOrbitDistance) or 6
            local desiredPos
            if State.CQCOrbitMode == "Circle Strafe" then
                cqcOrbitAngle = (cqcOrbitAngle + (dt or 0.016) * 6.5) % (math.pi * 2)
                desiredPos = orbitTarget.hrp.Position + Vector3.new(math.cos(cqcOrbitAngle) * distOff, 0.5, math.sin(cqcOrbitAngle) * distOff)
            elseif State.CQCOrbitMode == "Above Target" then
                desiredPos = orbitTarget.hrp.Position + Vector3.new(0, distOff + 2, 0)
            else
                desiredPos = orbitTarget.hrp.Position - orbitTarget.hrp.CFrame.LookVector * distOff
            end
            local wallRP = RaycastParams.new()
            wallRP.FilterType = Enum.RaycastFilterType.Exclude
            wallRP.IgnoreWater = true
            wallRP.RespectCanCollide = true
            wallRP.FilterDescendantsInstances = buildWorldExcludeList(orbitTarget.model)
            local delta = desiredPos - orbitTarget.hrp.Position
            if delta.Magnitude > 0.2 then
                local wallHit = Workspace:Raycast(orbitTarget.hrp.Position, delta, wallRP)
                if wallHit then
                    desiredPos = orbitTarget.hrp.Position + delta.Unit * math.max(2.2, wallHit.Distance - 1.5)
                end
            end
            if hasGroundBelow(desiredPos, 20) then
                hrp.CFrame = CFrame.lookAt(desiredPos, orbitTarget.hrp.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                orbitedThisFrame = true
            end
        end
    end

    -- Continuous Agile Chase, Zig-Zag Strafe, Parry-Kite & Tactical Hops
    if moveAI and not State.Fly and not orbitedThisFrame then
        local userMoving = UserInputService:IsKeyDown(Enum.KeyCode.W)
            or UserInputService:IsKeyDown(Enum.KeyCode.A)
            or UserInputService:IsKeyDown(Enum.KeyCode.S)
            or UserInputService:IsKeyDown(Enum.KeyCode.D)
            or UserInputService:IsKeyDown(Enum.KeyCode.Up)
            or UserInputService:IsKeyDown(Enum.KeyCode.Down)
            or UserInputService:IsKeyDown(Enum.KeyCode.Left)
            or UserInputService:IsKeyDown(Enum.KeyCode.Right)

        if not userMoving and locked and locked.hrp then
            local flatDelta = Vector3.new(locked.hrp.Position.X - hrp.Position.X, 0, locked.hrp.Position.Z - hrp.Position.Z)
            local dist = flatDelta.Magnitude
            if dist > 0.2 then
                local toFlat = flatDelta / dist
                local rightFlat = Vector3.new(-toFlat.Z, 0, toFlat.X) * Runtime.strafeDir

                local wallCheckRP = RaycastParams.new()
                wallCheckRP.FilterType = Enum.RaycastFilterType.Exclude
                wallCheckRP.IgnoreWater = true
                wallCheckRP.RespectCanCollide = true
                wallCheckRP.FilterDescendantsInstances = buildWorldExcludeList(nil)

                local hasLOS = hasLineOfSight(hrp.Position + Vector3.new(0, 1.5, 0), locked.hrp.Position, locked.model)
                local coverAhead = (not hasLOS) and (Workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), toFlat * 18, wallCheckRP) ~= nil)

                if coverAhead then
                    if now >= Runtime.nextStrafeFlipAt then
                        local hitR = Workspace:Raycast(hrp.Position, rightFlat * 9, wallCheckRP)
                        local hitL = Workspace:Raycast(hrp.Position, -rightFlat * 9, wallCheckRP)
                        local clearR = not hitR
                        local clearL = not hitL
                        local posR = hrp.Position + rightFlat * 9
                        local posL = hrp.Position - rightFlat * 9
                        local losR = clearR and hasLineOfSight(posR + Vector3.new(0, 1.5, 0), locked.hrp.Position, locked.model)
                        local losL = clearL and hasLineOfSight(posL + Vector3.new(0, 1.5, 0), locked.hrp.Position, locked.model)
                        local pickLeft = false
                        if losL and not losR then
                            pickLeft = true
                        elseif not losR and not losL then
                            local distR = hitR and hitR.Distance or 9
                            local distL = hitL and hitL.Distance or 9
                            if distL > distR then
                                pickLeft = true
                            end
                        end
                        if pickLeft then
                            Runtime.strafeDir = -Runtime.strafeDir
                            rightFlat = -rightFlat
                        end
                        Runtime.nextStrafeFlipAt = now + 1.15
                    elseif Workspace:Raycast(hrp.Position, rightFlat * 4.5, wallCheckRP) then
                        Runtime.strafeDir = -Runtime.strafeDir
                        Runtime.nextStrafeFlipAt = now + 0.9
                        rightFlat = Vector3.new(-toFlat.Z, 0, toFlat.X) * Runtime.strafeDir
                    end
                elseif now >= Runtime.nextStrafeFlipAt then
                    Runtime.strafeDir = -Runtime.strafeDir
                    Runtime.nextStrafeFlipAt = now + (0.42 + math.random() * 0.28)
                    rightFlat = Vector3.new(-toFlat.Z, 0, toFlat.X) * Runtime.strafeDir
                elseif Workspace:Raycast(hrp.Position, rightFlat * 4.5, wallCheckRP) then
                    Runtime.strafeDir = -Runtime.strafeDir
                    Runtime.nextStrafeFlipAt = now + 0.45
                    rightFlat = Vector3.new(-toFlat.Z, 0, toFlat.X) * Runtime.strafeDir
                end

                local moveDir
                if coverAhead then
                    moveDir = (toFlat * 0.32 + rightFlat * 0.95)
                elseif (locked.isParrying or locked.isImmune) and dist <= 16 then
                    moveDir = (-toFlat * 0.75 + rightFlat * 0.85)
                elseif dist > 10.2 then
                    moveDir = (toFlat * 0.88 + rightFlat * 0.48)
                else
                    local radial = (dist > 6.5) and 0.55 or ((dist < 4.0) and -0.45 or 0.10)
                    moveDir = (toFlat * radial + rightFlat * 0.95)
                end
                if moveDir.Magnitude > 0.01 then
                    moveDir = moveDir.Unit
                else
                    moveDir = toFlat
                end

                -- Forward wall slide & low-obstacle vault so footwork never stalls against walls
                local fwdHit = Workspace:Raycast(hrp.Position + Vector3.new(0, 0.5, 0), moveDir * 5.2, wallCheckRP)
                if fwdHit then
                    local highClear = Workspace:Raycast(hrp.Position + Vector3.new(0, 3.8, 0), moveDir * 5.2, wallCheckRP) == nil
                    if highClear and hum.FloorMaterial ~= Enum.Material.Air then
                        hum.Jump = true
                        Runtime.nextAutoJumpAt = now + 0.8
                    else
                        local nFlat = Vector3.new(fwdHit.Normal.X, 0, fwdHit.Normal.Z)
                        local slid = false
                        if nFlat.Magnitude > 0.1 then
                            local tangent = (moveDir - nFlat.Unit * moveDir:Dot(nFlat.Unit))
                            if tangent.Magnitude > 0.15 and Workspace:Raycast(hrp.Position, tangent.Unit * 4.0, wallCheckRP) == nil then
                                moveDir = tangent.Unit
                                slid = true
                            end
                        end
                        if not slid then
                            local hitR = Workspace:Raycast(hrp.Position, rightFlat * 10, wallCheckRP)
                            local hitL = Workspace:Raycast(hrp.Position, -rightFlat * 10, wallCheckRP)
                            local distR = hitR and hitR.Distance or 10
                            local distL = hitL and hitL.Distance or 10
                            if distL > distR then
                                Runtime.strafeDir = -Runtime.strafeDir
                                rightFlat = -rightFlat
                            end
                            moveDir = rightFlat
                        end
                        Runtime.nextStrafeFlipAt = math.max(Runtime.nextStrafeFlipAt, now + 0.9)
                    end
                end

                if not hasGroundBelow(hrp.Position + moveDir * 5.5, 22) then
                    Runtime.strafeDir = -Runtime.strafeDir
                    moveDir = hasGroundBelow(hrp.Position + toFlat * 4.5, 22) and toFlat or -moveDir
                end

                hum:Move(moveDir, false)
                Runtime.wasCombatMoving = true
                Runtime.combatMoveSteps += 1

                if hum.FloorMaterial ~= Enum.Material.Air and now >= Runtime.nextAutoJumpAt then
                    hum.Jump = true
                    Runtime.nextAutoJumpAt = now + (dist > 10.2 and (0.85 + math.random() * 0.45) or (1.1 + math.random() * 0.6))
                end
            end
        elseif not userMoving and Runtime.wasCombatMoving then
            hum:Move(Vector3.zero, false)
            Runtime.wasCombatMoving = false
        end
    elseif Runtime.wasCombatMoving then
        hum:Move(Vector3.zero, false)
        Runtime.wasCombatMoving = false
    end
end)

trackConn(RunService.RenderStepped:Connect(function(dt)
    if Unloaded then return end
    local cam = Workspace.CurrentCamera
    if State.CustomFOV and not GameG.ChestGachaActive and not (type(GameG.DaggerAimActive) == "function" and safeCall(GameG.DaggerAimActive) == true) then
        local targetFOV = tonumber(State.FOVValue) or 95
        GameG.DaggerBaseFOV = targetFOV
        if cam and math.abs(cam.FieldOfView - targetFOV) > 0.5 then
            cam.FieldOfView = targetFOV
        end
    end
    if cam and (State.TargetLockOn or State.AutoPlayMaster) and isInMatch() and not isArenaVotingActive() and not GameG.ChestGachaActive and not GameG.DaggerResultSceneActive and not GameG.DaggerLobbyLock and not GameG.DaggerSpectateLock then
        local inCd = type(GameG.DaggerInCountdown) == "function" and safeCall(GameG.DaggerInCountdown) == true
        local mdl = Runtime.lockedTargetModel
        if not inCd and not GameG.DaggerKnocked and mdl and mdl.Parent then
            local part = mdl:FindFirstChild("Head") or mdl:FindFirstChild("HumanoidRootPart")
            if part and (part.Position - cam.CFrame.Position).Magnitude > 2 then
                cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, part.Position), math.clamp((dt or 0.016) * 14, 0, 1))
            end
        end
    end
end))

-- -------------------------------------------------------------------------
-- 11. MAIN AUTONOMOUS WORKER LOOP
-- -------------------------------------------------------------------------
trackThread(function()
    while not Unloaded do
        safeWait(0.05)
        if Unloaded then break end

        local now = os.clock()
        local char, hrp, hum = getRootAndHum()
        local tutState = getTutorialState()
        local inMatch = isInMatch()
        local inLobby = isInLobby()
        local inCountdown = type(GameG.DaggerInCountdown) == "function" and safeCall(GameG.DaggerInCountdown) == true
        local myHP = tonumber(char and char:GetAttribute("BattleHP")) or (hum and hum.Health) or 100
        local myMaxHP = tonumber(char and char:GetAttribute("BattleMaxHP")) or (hum and hum.MaxHealth) or 100

        -- 1. ESP Update (~0.12s throttle)
        if (now - Runtime.lastEspUpdateAt) >= 0.12 then
            Runtime.lastEspUpdateAt = now
            pcall(updateTacticalESP)
        end

        -- 2. Auto Equip Dagger & Transform
        if (State.AutoEquipDagger or State.AutoPlayMaster) and inMatch and hum and hum.Health > 0 then
            equipDaggerFromBackpack()
        end

        if State.AutoTransformWeapon and inMatch and not inCountdown and (now - Runtime.lastTransformAt) >= 2 then
            local tool = getEquippedDagger()
            local pairsTbl = Config.TRANSFORM and Config.TRANSFORM.PAIRS
            local pairTarget = tool and pairsTbl and pairsTbl[tool.Name]
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if pairTarget and bp and bp:FindFirstChild(pairTarget) and type(GameG.DaggerTriggerTransform) == "function" then
                safeCall(GameG.DaggerTriggerTransform)
                Runtime.lastTransformAt = now
                Runtime.lastAction = "Triggered Weapon Transform"
            end
        end

        -- 3. Auto Skip Result / LevelUp / Chest Gacha / Arena Voting / Auto Queue
        if (State.InstantSkipGacha or State.AutoSkipResultAndPopups or State.AutoPlayMaster) and (now - Runtime.lastGachaDismissAt) >= 0.25 then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local cg = pg and pg:FindFirstChild("ChestGui")
            if GameG.ChestGachaActive or (cg and cg:IsA("ScreenGui") and cg.Enabled) then
                if dismissChestGachaPopup() then
                    Runtime.lastGachaDismissAt = now
                end
            end
        end

        if (State.AutoSkipResultAndPopups or State.AutoPlayMaster) and (now - Runtime.lastResultExitAt) >= 1.5 then
            if GameG.DaggerResultSceneActive then
                Runtime.lastResultExitAt = now
                skipActiveResultAndPopups()
            else
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local mm = pg and pg:FindFirstChild("MainMenuGui")
                local luf = mm and mm:FindFirstChild("LevelUpFrame", true)
                if luf and luf:IsA("GuiObject") and luf.Visible and type(GameG.DaggerLevelUpClose) == "function" then
                    Runtime.lastResultExitAt = now
                    safeCall(GameG.DaggerLevelUpClose)
                end
            end
        end

        if (State.AutoVoteArena or State.AutoPlayMaster) and (now - Runtime.lastVoteAt) >= 1.5 then
            if isArenaVotingActive() then
                local curMatchId = LocalPlayer:GetAttribute("MatchId")
                if Runtime.votedMatchId ~= curMatchId then
                    local matchEv = rem("MatchEvent")
                    if matchEv then
                        local voteKey = ArenaVoteMap[State.PreferredArenaVote] or "Random"
                        if voteKey == "Random" then
                            local keys = { "A", "B", "C", "D", "E" }
                            voteKey = keys[math.random(1, #keys)]
                        end
                        pcall(function()
                            matchEv:FireServer("pick", voteKey)
                        end)
                        Runtime.lastVoteAt = now
                        Runtime.votedMatchId = curMatchId
                        Runtime.lastAction = "Voted Arena: " .. voteKey
                    end
                end
            else
                Runtime.votedMatchId = nil
            end
        end

        if (State.AutoQueueMatch or State.AutoPlayMaster) and inLobby and not GameG.DaggerResultSceneActive and (now - Runtime.lastQueueAt) >= 6 then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local mm = pg and pg:FindFirstChild("MainMenuGui")
            local mmFrame = mm and mm:FindFirstChild("MatchmakingFrame", true)
            local alreadySearching = mmFrame and mmFrame:IsA("GuiObject") and mmFrame.Visible
            if not alreadySearching then
                local qMode = State.AutoPlayMaster and State.AutoPlayQueueMode or State.SelectedQueueMode
                startMatchQueue(qMode)
            end
        end

        -- 4. Rewards & Auto Open Chests in Lobby
        if State.AutoClaimRewards and inLobby and (now - Runtime.lastRewardAt) >= 6 then
            Runtime.lastRewardAt = now
            claimAllRewardsNow()
        end

        if State.AutoOpenChests and inLobby and (now - Runtime.lastChestAt) >= 2 then
            local info = ChestIndexLookup[State.SelectedChestType] or ChestIndexLookup["1 - Rare Chest (500)"]
            if (tonumber(LocalPlayer:GetAttribute("Diamonds")) or 0) >= info.price1 then
                buyChestRemote(1)
            end
        end

        -- 5. Active Match Combat AI (Escape, Skills, Smart Teleport, Throw, Dash)
        if inMatch and not inCountdown and not isArenaVotingActive() and hrp and hum and hum.Health > 0 and not GameG.DaggerKnocked then
            -- Low HP DaggerPart Blink Escape
            if (State.AutoDaggerPartEscape or State.AutoPlayMaster) and myHP <= State.EscapeHPThreshold and not GameG.DaggerStuckOnPlayer and (now - Runtime.lastEscapeAt) >= 3 then
                local cam = Workspace.CurrentCamera
                if cam then
                    local bestPart, bestDist = nil, -1
                    for _, p in ipairs(getArenaDaggerParts()) do
                        local d = (p.Position - hrp.Position).Magnitude
                        if d >= 25 and d <= 480 and d > bestDist and hasLineOfSight(cam.CFrame.Position, p.Position, p) then
                            bestDist = d
                            bestPart = p
                        end
                    end
                    if bestPart and tutState.state == "none" and not tutState.onCooldown then
                        Runtime.lastEscapeAt = now
                        throwDaggerAtWorldPos(bestPart.Position)
                        Runtime.lastAction = "Low-HP Blink Escape"
                        task.delay(0.28, function()
                            if not Unloaded and type(GameG.DaggerTriggerTeleport) == "function" then
                                safeCall(GameG.DaggerTriggerTeleport)
                            end
                        end)
                    end
                end
            end

            -- Tactical Context Skill AI
            if (State.AutoUseSkills or State.AutoPlayMaster) and (now - Runtime.lastSkillAt) >= 0.6 then
                local equipped = getEquippedSkillsList()
                local nearestTarget, nearestDist = nil, math.huge
                for _, t in ipairs(getValidCombatTargets()) do
                    local d = (t.hrp.Position - hrp.Position).Magnitude
                    if d < nearestDist then
                        nearestDist = d
                        nearestTarget = t
                    end
                end

                for _, sk in ipairs(equipped) do
                    if isSkillReady(sk) then
                        if sk == "regen" and myHP <= State.SkillHealHP and nearestDist > 16 then
                            useSkillById("regen")
                            break
                        elseif sk == "hibernation" and myHP <= State.SkillHealHP and nearestDist <= 18 then
                            useSkillById("hibernation")
                            break
                        elseif sk == "bloodlust" and GameG.DaggerStuckOnPlayer and myHP <= 85 then
                            useSkillById("bloodlust")
                            break
                        elseif sk == "mastercombat" and nearestTarget and nearestDist <= 15 then
                            useSkillById("mastercombat")
                            break
                        elseif sk == "onigate" and nearestTarget and nearestDist <= 15 then
                            useSkillById("onigate")
                            break
                        elseif (sk == "reflex" or sk == "speedster") and nearestTarget and nearestDist <= 120 then
                            useSkillById(sk)
                            break
                        elseif (sk == "flurry" or sk == "detonate" or sk == "trickster") and nearestTarget and nearestDist <= 260 and tutState.state == "none" then
                            useSkillById(sk)
                            break
                        elseif sk == "recall" then
                            local st = getSkillStateInfo("recall")
                            if st and (tonumber(st.activeFor) or 0) > 0 and myHP <= State.SkillHealHP then
                                useSkillById("recall")
                                break
                            elseif (not st or (tonumber(st.activeFor) or 0) <= 0) and myHP >= 85 and (now - Runtime.recallMarkedAt) >= 12 then
                                Runtime.recallMarkedAt = now
                                useSkillById("recall")
                                break
                            end
                        end
                    end
                end
            end

            local lockedTarget = resolveStickyCombatTarget(480)
            local moveAI = (State.AggressiveCombatMove or State.AutoPlayMaster) == true

            -- Wall/Ground Missed Dagger Gap-Close Blink & Fast Auto-Cancel
            if tutState.throwing and not GameG.DaggerStuckOnPlayer then
                if Runtime.wallDaggerSince == 0 then
                    Runtime.wallDaggerSince = now
                end
                local tdModel = Workspace:FindFirstChild("ThrownDaggerModel_" .. LocalPlayer.Name)
                local tdObj = tdModel and (tdModel:FindFirstChild("ThrownDagger_" .. LocalPlayer.Name) or tdModel:FindFirstChildWhichIsA("BasePart"))
                local dagPos = nil
                if tdObj then
                    dagPos = tdObj:IsA("BasePart") and tdObj.Position or (tdObj:IsA("Model") and tdObj:GetPivot().Position)
                end

                local blinkedGap = false
                if dagPos and (State.AutoTeleportStrike or State.AutoPlayMaster) and not GameG.DaggerNoObjectTeleport and lockedTarget and lockedTarget.hrp and not lockedTarget.isParrying and not lockedTarget.isImmune and (now - Runtime.lastThrowAt) >= 0.21 and (now - Runtime.lastTeleportAt) >= 0.25 then
                    local myDist = (lockedTarget.hrp.Position - hrp.Position).Magnitude
                    local dagDist = (lockedTarget.hrp.Position - dagPos).Magnitude
                    if (myDist - dagDist) >= 8 and dagDist <= 55 and hasGroundBelow(dagPos, 20) and type(GameG.DaggerTriggerTeleport) == "function" then
                        safeCall(GameG.DaggerTriggerTeleport)
                        Runtime.gapCloseBlinks += 1
                        Runtime.teleportsAttempted += 1
                        Runtime.lastTeleportAt = now
                        Runtime.wallDaggerSince = 0
                        Runtime.lastAction = "Gap-Close Blink -> " .. lockedTarget.name
                        blinkedGap = true
                    end
                end
                if not blinkedGap and (State.AutoThrowDagger or State.AutoPlayMaster) and (now - Runtime.wallDaggerSince) >= 0.32 and (now - Runtime.lastCancelAt) >= 0.35 and type(GameG.DaggerTriggerCancel) == "function" then
                    safeCall(GameG.DaggerTriggerCancel)
                    Runtime.missedDaggerCancels += 1
                    Runtime.lastCancelAt = now
                    Runtime.wallDaggerSince = 0
                    Runtime.lastAction = "Fast-Canceled Missed Dagger"
                end
            else
                Runtime.wallDaggerSince = 0
            end

            -- Smart Anti-Parry Teleport Strike (or Safe Cancel)
            if (State.AutoTeleportStrike or State.AutoPlayMaster) and GameG.DaggerStuckOnPlayer then
                local lockUntil = tonumber(GameG.DaggerTeleportLockUntil) or 0
                local elapsedStuck = Runtime.stuckSince > 0 and (now - Runtime.stuckSince) or 0
                local stuckTarget = nil
                local tName = GameG.DaggerParryThrower
                for _, t in ipairs(getValidCombatTargets()) do
                    if (t.model:GetAttribute("StuckCount") or 0) > 0 or (tName and (t.name == tName or (t.player and t.player.Name == tName))) then
                        stuckTarget = t
                        break
                    end
                end
                local danger = Runtime.targetIsParrying or (stuckTarget and (stuckTarget.isParrying or stuckTarget.isImmune))
                if danger and (State.AntiParryBait or State.AutoPlayMaster) then
                    if elapsedStuck >= 2.82 and (now - Runtime.lastCancelAt) >= 0.8 and type(GameG.DaggerTriggerCancel) == "function" then
                        safeCall(GameG.DaggerTriggerCancel)
                        Runtime.lastCancelAt = now
                        Runtime.lastAction = "Safe-Canceled Blocked Dagger"
                    end
                elseif tick() >= lockUntil and (now - Runtime.lastTeleportAt) >= 0.25 then
                    local stunOk = true
                    if State.PrioritizeStunThrow and GameG.DaggerKnockReady ~= true then
                        local knockLeft = math.max(0, (tonumber(GameG.DaggerKnockCdEnd) or 0) - Workspace:GetServerTimeNow())
                        if stuckTarget and stuckTarget.hp > 40 and knockLeft > 0 and knockLeft <= 1.25 and elapsedStuck < 2.3 then
                            stunOk = false
                        end
                    end
                    if stunOk and type(GameG.DaggerTriggerTeleport) == "function" then
                        -- Trigger Bloodlust right before teleport if available
                        if (State.AutoUseSkills or State.AutoPlayMaster) and myHP <= 85 then
                            local eq = getEquippedSkillsList()
                            if table.find(eq, "bloodlust") and isSkillReady("bloodlust") then
                                useSkillById("bloodlust")
                            end
                        end
                        safeCall(GameG.DaggerTriggerTeleport)
                        Runtime.teleportsAttempted += 1
                        Runtime.lastTeleportAt = now
                        Runtime.lastAction = GameG.DaggerKnockReady and "Stun Teleport Strike!" or "Teleport Strike!"
                    end
                end
            end

            -- Auto Throw Dagger
            if (State.AutoThrowDagger or State.AutoPlayMaster) and not GameG.DaggerStuckOnPlayer and (now - Runtime.lastThrowAt) >= 0.73 then
                if tutState.state == "none" and not tutState.onCooldown and not tutState.throwing and tutState.hasTool then
                    local target, predPos = pickBestCombatTarget(true, false, 475)
                    if target and predPos then
                        throwDaggerAtWorldPos(predPos)
                        Runtime.lastAction = "Auto-Threw -> " .. target.name
                    end
                end
            end

            -- Auto Dash Evade (Evasive + Offensive Rush)
            if (State.AutoDashEvade or State.AutoPlayMaster) and (now - Runtime.lastDashAt) >= 0.85 then
                local shouldDash = false
                local nearThreat = false
                for _, t in ipairs(getValidCombatTargets()) do
                    local d = (t.hrp.Position - hrp.Position).Magnitude
                    if d <= 9.5 then
                        nearThreat = true
                        break
                    elseif d <= 48 and t.hrp.CFrame.LookVector:Dot((hrp.Position - t.hrp.Position).Unit) > 0.88 then
                        shouldDash = true
                    end
                end
                local lockUntil = char:GetAttribute("MeleeLockUntil")
                local meleeLocked = lockUntil and Workspace:GetServerTimeNow() < tonumber(lockUntil)
                if nearThreat and (meleeLocked or myHP <= 45) then
                    shouldDash = true
                elseif moveAI and lockedTarget and lockedTarget.hrp then
                    local dLock = (lockedTarget.hrp.Position - hrp.Position).Magnitude
                    if dLock >= 16 and dLock <= 48 and not lockedTarget.isParrying then
                        shouldDash = true
                    end
                end
                if shouldDash and type(GameG.DaggerTriggerDash) == "function" then
                    safeCall(GameG.DaggerTriggerDash)
                    Runtime.lastDashAt = now
                end
            end
        end

        -- 6. Periodic HUD Telemetry Update (every ~0.5s)
        if (now - Runtime.lastHudSyncAt) >= 0.5 then
            Runtime.lastHudSyncAt = now
            local matchStr = inMatch and ("IN MATCH (" .. tostring(LocalPlayer:GetAttribute("MatchMode") or "duel") .. ")") or "LOBBY"
            local targets = getValidCombatTargets()
            local dagState = string.format("%s | StuckOnEnemy: %s | StunReady: %s",
                tostring(tutState.state),
                tostring(GameG.DaggerStuckOnPlayer == true),
                tostring(GameG.DaggerKnockReady == true)
            )
            safeSetDesc(CombatStatusPara, string.format(
                "State: %s | HP: %.0f / %.0f | Targets: %d | Locked: %s\nDagger: %s\nThrows: %d | Teleports: %d (GapBlinks: %d) | Parries: %d | Melee: %d\nLast Action: %s",
                matchStr, myHP, myMaxHP, #targets, tostring(Runtime.lockedTargetName), dagState,
                Runtime.throwsAttempted, Runtime.teleportsAttempted, Runtime.gapCloseBlinks, Runtime.parriesTriggered, Runtime.meleeSwings,
                Runtime.lastAction
            ))

            local exp = tonumber(LocalPlayer:GetAttribute("Exp")) or 0
            local lv, curExp, needExp = exp, 0, 1
            if type(LevelingModule.progress) == "function" then
                local r1, r2, r3 = safeCall(LevelingModule.progress, exp)
                if r1 then lv, curExp, needExp = r1, r2, r3 end
            end
            local gems = tonumber(LocalPlayer:GetAttribute("Diamonds")) or 0
            local trophies = tonumber(LocalPlayer:GetAttribute("Trophies")) or 0
            local wins = tonumber(LocalPlayer:GetAttribute("DuelWins")) or 0
            local streak = tonumber(LocalPlayer:GetAttribute("WinStreak")) or 0
            local tierName = "UNRANKED"
            if type(Config.rankTierOf) == "function" and Config.RANKED and Config.RANKED.TIERS then
                local idx = safeCall(Config.rankTierOf, trophies)
                if idx and Config.RANKED.TIERS[idx] then
                    tierName = Config.RANKED.TIERS[idx].name
                end
            end
            safeSetDesc(ProfileStatusPara, string.format(
                "Level %d (%d / %d EXP) | Crystals: %s | Trophies: %d (%s)\nDuel Wins: %d | Win Streak: %d | Daily Claimable: %s | Playtime: %s",
                lv, curExp, needExp, formatNumber(gems), trophies, tierName,
                wins, streak, tostring(LocalPlayer:GetAttribute("DailyCanClaim") == true),
                tostring(LocalPlayer:GetAttribute("PlaytimeState") or "count")
            ))
        end
    end
end)

-- -------------------------------------------------------------------------
-- 12. CENTRAL UNLOAD & LIVE-RELOAD CLEANUP REGISTRATION
-- -------------------------------------------------------------------------
local function unloadAll()
    if Unloaded then return end
    Unloaded = true
    ensureElevatedIdentity()

    pcall(function()
        RunService:UnbindFromRenderStep("XLunaTD_CombatSteer")
    end)

    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)

    for _, co in ipairs(Threads) do
        pcall(task.cancel, co)
    end
    table.clear(Threads)

    applyAntiAfkState(false)
    applyFullbright(false)
    applyCustomFOV(false)
    applyAntiShakeAndFlash(false)
    restoreWalkSpeed()
    restoreJumpPower()
    restoreNoClip()
    restoreFly()
    restoreCombatMovement()
    clearEspTable(EnemyEspMap)
    clearEspTable(AnchorEspMap)

    for _, fn in ipairs(Cleanups) do
        pcall(fn)
    end
    table.clear(Cleanups)

    pcall(function()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end)
end

if type(shared) == "table" then
    shared.XLunaTD_Unload = unloadAll
end
if type(getgenv) == "function" then
    local okGenv, genv = pcall(getgenv)
    if okGenv and type(genv) == "table" then
        genv.XLunaTD_Unload = unloadAll
    end
end
if type(STATE) == "table" and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(unloadAll)
end

-- Expose minimal read-only verification bridge for live testing
if type(shared) == "table" then
    shared.XLunaTD_Bridge = {
        GetState = function() return State end,
        GetRuntime = function() return Runtime end,
        GetUIElements = function() return UI_Elements end,
        GetWindow = function() return Window end,
        GetEspContainer = function() return EspContainer end,
        SyncVisual = syncElementVisual,
        SaveConfig = saveConfig,
        LoadConfig = loadConfig,
        DeleteConfig = deleteConfig,
        ResetAllToOff = resetAllToOff,
        ClaimRewards = claimAllRewardsNow,
        SetAntiAfk = applyAntiAfkState,
        SetFullbright = applyFullbright,
        SetCustomFOV = applyCustomFOV,
        SetAntiShake = applyAntiShakeAndFlash,
        RestoreWalkSpeed = restoreWalkSpeed,
        RestoreJumpPower = restoreJumpPower,
        RestoreNoClip = restoreNoClip,
        RestoreFly = restoreFly,
        RestoreCombatMove = restoreCombatMovement,
        StartQueue = startMatchQueue,
        CancelQueue = cancelMatchQueue,
        EquipSkills = equipSkillLoadoutRemote,
        GetEquippedSkills = getEquippedSkillsList,
        GetLobbyTeleports = getLobbyTeleportMap,
        TeleportToCF = safeTeleportCF,
    }
end
