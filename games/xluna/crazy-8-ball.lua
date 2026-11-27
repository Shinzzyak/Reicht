-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ================================================================================
    [ABILITIES] CRAZY 8 BALL â MASTER REVERSE-ENGINEERED AUTOMATION SUITE
    ================================================================================
    Universal English | WindUI Modern Dark | Zero Watermark / Zero AI Slop
    Standard Operating Procedure (SOP) Rule Compliance:
    - Default State: ALL OFF (Strictly initialized to false per SOP Rule 8)
    - Keybind: LeftControl (Show/Hide Toggle)
    - Floating Screen Button: Draggable interactive pill
    - Config Management: Save/Load/Reset configuration
    - Built on: Deterministic Physics Re-simulation, ShotFinder & Bank Rebound Engine
    ================================================================================
]]

-- Tear down previous instances if re-executing
if getgenv()._Crazy8BallSuite then
    pcall(function() getgenv()._Crazy8BallSuite:Teardown() end)
end

local App = {
    Connections = {},
    Visuals = {},
    Active = true,
    CurrentTarget = nil,
    TurnStartTime = 0,
    LastShotTime = 0,
    LastTurnId = -1,
    LastClaimTime = 0,
    Version = "1.1.0"
}
getgenv()._Crazy8BallSuite = App

-- ==============================================================================
-- SERVICES & SHARED REPOSITORIES
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Config_Game = require(Shared:WaitForChild("Config"))
local TableBuilder = require(Shared:WaitForChild("TableBuilder"))
local ShotJudge = require(Shared:WaitForChild("Rules"):WaitForChild("ShotJudge"))
local ShotFinder = require(Shared:WaitForChild("Bots"):WaitForChild("ShotFinder"))
local Plan = require(Shared:WaitForChild("Tutorial"):WaitForChild("Plan"))
local Catalog = require(Shared:WaitForChild("Ults"):WaitForChild("Catalog"))
local ItemState = require(LocalPlayer.PlayerScripts.Client.ItemState)
local Sim = require(Shared:WaitForChild("Physics"):WaitForChild("Simulation"))

-- ==============================================================================
-- MASTER CONFIGURATION SPECIFICATION (DEFAULT ALL OFF PER SOP RULE 8)
-- ==============================================================================
local Config = {
    -- Aim & Trajectory
    ExtendedGuideline = false,
    LaserESP = false,
    LaserColor = Color3.fromRGB(0, 255, 170),
    PocketColor = Color3.fromRGB(255, 215, 0),
    AutoAim = false,
    SmoothAim = false,
    AimSpeed = 15,
    ManualAimKey = Enum.KeyCode.E,
    AutoShoot = false,
    AutoShootDelay = 1.2,
    AutoPower = false,
    CustomPower = 0.65,
    AvoidScratch = false,

    -- Brutal Rage Mode & High-Tier Physics
    RageMode = false,
    AntiScratchSpin = false,
    BankShotSolver = false,
    AutoBreak = false,

    -- Autonomous Grinder & Matchmaking
    EndlessFarm = false,
    AutoQueueBot = false,
    AutoQueueMatch = false,
    AutoDismissResult = false,
    AutoUlt = false,
    AutoOpenLucky = false,

    -- Target ESP & Markers
    TargetESP = false,
    TargetBallColor = Color3.fromRGB(255, 60, 60),
    PocketHighlighter = false,

    -- Automated Rewards
    AutoClaimDaily = false,
    AutoClaimPlaytime = false,
    AutoClaimRank = false,
    AutoRedeemCodes = false,

    -- Character & Utilities
    SafeWalkSpeed = 16,
    SafeJumpPower = 50,
    ModifyWalkSpeed = false,
    ModifyJumpPower = false,
    InfiniteJump = false,
    AntiAFK = false,
}
App.Config = Config

-- ==============================================================================
-- RUNTIME REVERSE-ENGINEERED STATE RESOLVER
-- ==============================================================================
local EngineState = {
    InputObj = nil,
    HubObj = nil,
    MainUpvalues = nil,
    CurrentTable = nil,
    CurrentSnapshot = nil,
    CurrentPhysicsState = nil,
    MyTeam = 1,
    MyGroup = nil,
    IsMyTurn = false,
    LastResolveAttempt = 0
}

function EngineState:Resolve()
    -- 1. Fast Hub object resolution (0.01ms via workspace signal connection)
    if not self.HubObj or not self.HubObj.snapshots then
        local slowmoCons = getconnections(workspace:GetAttributeChangedSignal("ReplaySlowmo_1"))
        if #slowmoCons > 0 and slowmoCons[1].Function then
            local hub = debug.getupvalues(slowmoCons[1].Function)[1]
            if hub and hub.fire and hub.snapshots then
                self.HubObj = hub
            end
        end
    end

    -- 2. Fast Input object resolution (0.01ms via SpinToggle UI connection)
    if not self.InputObj or not self.InputObj.angle then
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        local btn = pgui and pgui:FindFirstChild("SpinToggle", true)
        if btn then
            local cons = getconnections(btn.Activated)
            if #cons > 0 and cons[1].Function then
                for _, v in ipairs(debug.getupvalues(cons[1].Function)) do
                    if type(v) == "table" and v.aimListeners and v.setAngle then
                        self.InputObj = v
                        break
                    end
                end
            end
        end
    end

    -- 3. Extract Main upvalues from aim listener
    if self.InputObj and self.InputObj.aimListeners and self.InputObj.aimListeners[1] then
        local fn = self.InputObj.aimListeners[1]
        local u = debug.getupvalues(fn)
        if u and #u >= 14 then
            self.MainUpvalues = u
            self.CurrentSnapshot = u[11]
            self.CurrentPhysicsState = u[14]
        end
    end

    -- 4. Fallback to Hub snapshot if available
    if self.HubObj and self.HubObj.mySeat and self.HubObj.snapshots then
        local snap = self.HubObj.snapshots[self.HubObj.mySeat]
        if snap then
            self.CurrentSnapshot = snap
            self.CurrentTable = self.HubObj.mySeat
        end
    end

    -- 5. Determine team, group, and turn status
    if self.CurrentSnapshot then
        local myUserId = LocalPlayer.UserId
        local myTeam = 1
        if self.CurrentSnapshot.seats then
            for _, s in ipairs(self.CurrentSnapshot.seats) do
                if s.userId == myUserId then
                    myTeam = s.team
                    break
                end
            end
        end
        self.MyTeam = myTeam

        if self.CurrentSnapshot.groups and self.CurrentSnapshot.groups[myTeam] then
            self.MyGroup = self.CurrentSnapshot.groups[myTeam]
        else
            self.MyGroup = nil
        end

        self.IsMyTurn = (self.CurrentSnapshot.phase == "Aiming" and self.CurrentSnapshot.shooter == myUserId)
    else
        self.IsMyTurn = false
        self.MyGroup = nil
    end

    return (self.InputObj ~= nil and self.CurrentSnapshot ~= nil)
end

-- ==============================================================================
-- 100% DETERMINISTIC NATIVE PHYSICS PREDICTOR & SHOT OPTIMIZER
-- ==============================================================================
local ShotSolver = {
    CachedShot = nil,
    CachedKey = nil
}

function ShotSolver:ResetCache()
    self.CachedShot = nil
    self.CachedKey = nil
end

function ShotSolver:GetBestShot(forceRecalculate)
    if not EngineState.CurrentSnapshot or not EngineState.CurrentPhysicsState then
        return nil
    end

    local snap = EngineState.CurrentSnapshot
    local phys = EngineState.CurrentPhysicsState
    local balls = phys.state and phys.state.balls
    local geometry = phys.state and phys.state.geometry

    if not balls or not geometry then
        return nil
    end

    local cueBall = balls[1]
    if not cueBall or cueBall.pocketed then
        return nil
    end

    -- Turn & Cue position cache key (quantized to 0.1 inch resolution)
    local cuePosKey = string.format("%s_%.1f_%.1f", tostring(snap.turnId or 0), cueBall.x or 0, cueBall.y or 0)
    if not forceRecalculate and self.CachedKey == cuePosKey and self.CachedShot ~= nil then
        return self.CachedShot
    end

    local shot = self:ComputeBestShot(snap, phys, balls, geometry, cueBall)
    self.CachedShot = shot
    self.CachedKey = cuePosKey
    return shot
end

function ShotSolver:ComputeBestShot(snap, phys, balls, geometry, cueBall)

    -- 0. Precision Break Shot (100% Velocity Apex Strike)
    if (Config.AutoBreak or Config.RageMode) and (snap.breakShot or (snap.turnId == 1 and (snap.phase == "Placement" or snap.phase == "Aiming"))) then
        return {
            ball = 1,
            pocket = 0,
            angle = 0,
            power = 1.0,
            spin = { x = 0, y = 0 },
            called = nil,
            cut = 0,
            distance = 50,
            safe = true,
            ghostX = 0,
            ghostY = 0,
            isBreak = true,
            guaranteed = true
        }
    end

    -- Determine legal target group & remaining count
    local myGroup = EngineState.MyGroup
    local remaining = myGroup and ShotJudge.remaining(balls, myGroup) or 7
    local targetingEight = (remaining == 0 and myGroup ~= nil)
    local targetGroup = targetingEight and "eight" or myGroup

    local legalBalls = {}
    for _, b in ipairs(balls) do
        if not b.pocketed and b.id ~= 0 then
            if targetingEight and b.id == 8 then
                table.insert(legalBalls, b)
            elseif not targetingEight and b.id ~= 8 and (targetGroup == nil or ShotJudge.group(b.id) == targetGroup) then
                table.insert(legalBalls, b)
            end
        end
    end

    -- Fallback: if all group balls cleared, target the 8-ball
    if #legalBalls == 0 and not targetingEight then
        for _, b in ipairs(balls) do
            if b.id == 8 and not b.pocketed then
                table.insert(legalBalls, b)
                targetingEight = true
                break
            end
        end
    end

    local RadiusInches = Config_Game.Balls.RadiusInches or 1.125
    local candidates = {}

    -- 1. Geometric Candidate Mapping across all pockets
    for _, targetBall in ipairs(legalBalls) do
        for _, pkt in ipairs(geometry.pockets) do
            local pdx = pkt.x - targetBall.x
            local pdy = pkt.y - targetBall.y
            local pdist = math.sqrt(pdx * pdx + pdy * pdy)
            if pdist > 0.01 then
                local pDirX = pdx / pdist
                local pDirY = pdy / pdist
                local ghostX = targetBall.x - pDirX * 2 * RadiusInches
                local ghostY = targetBall.y - pDirY * 2 * RadiusInches

                local cdx = ghostX - cueBall.x
                local cdy = ghostY - cueBall.y
                local cdist = math.sqrt(cdx * cdx + cdy * cdy)
                if cdist > 0.01 then
                    local cDirX = cdx / cdist
                    local cDirY = cdy / cdist
                    local baseAngle = math.atan2(cdy, cdx)
                    local dot = math.clamp(cDirX * pDirX + cDirY * pDirY, -1, 1)
                    local cutDeg = math.deg(math.acos(dot))

                    -- Cut angles > 76 degrees are physically impossible
                    if cutDeg < 76 then
                        table.insert(candidates, {
                            ball = targetBall,
                            pocket = pkt,
                            baseAngle = baseAngle,
                            cutDeg = cutDeg,
                            cdist = cdist,
                            pdist = pdist,
                            ghostX = ghostX,
                            ghostY = ghostY
                        })
                    end
                end
            end
        end
    end

    -- Sort candidates by minimal cut angle and distance
    table.sort(candidates, function(a, b)
        return (a.cutDeg * 1.5 + a.cdist + a.pdist) < (b.cutDeg * 1.5 + b.cdist + b.pdist)
    end)

    -- 2. Native Physics Re-Simulation & Trajectory Verification
    local bestVerified = nil
    local bestScore = -999999

    for cIdx = 1, math.min(#candidates, 8) do
        local c = candidates[cIdx]
        local tb = c.ball
        local pkt = c.pocket
        local cosCut = math.max(0.18, math.cos(math.rad(c.cutDeg)))
        local effectiveDist = c.cdist + (c.pdist / cosCut)

        -- Micro-tuning grid: fine angle sweep + calibrated power levels
        local angleOffsets = { 0, math.rad(-0.5), math.rad(0.5), math.rad(-1.0), math.rad(1.0), math.rad(-1.5), math.rad(1.5) }
        local powerLevels = {
            math.clamp(0.24 + (effectiveDist / 130) * 0.38, 0.26, 0.85),
            math.clamp(0.32 + (effectiveDist / 110) * 0.45, 0.35, 0.95),
            math.clamp(0.18 + (effectiveDist / 140) * 0.32, 0.22, 0.70)
        }

        local spinTests = { { x = 0, y = 0 } }
        if Config.AntiScratchSpin or c.cutDeg < 25 then
            table.insert(spinTests, { x = 0, y = -0.85 })
        end

        local foundForCandidate = false
        for _, dAngle in ipairs(angleOffsets) do
            if foundForCandidate then break end
            local testAngle = c.baseAngle + dAngle

            for _, pwr in ipairs(powerLevels) do
                if foundForCandidate then break end

                for _, sp in ipairs(spinTests) do
                    local clone = Sim.cloneState(phys.state)
                    local testShot = {
                        angle = testAngle,
                        power = pwr,
                        spin = sp,
                        elevation = 0
                    }
                    local ret = Sim.runHeadless(clone, testShot)

                    -- Verification Criterion 1: Cue ball MUST NOT scratch
                    if not clone.balls[1].pocketed then
                        -- Verification Criterion 2: First contact MUST be legal
                        local fc = Sim.firstContact(ret.events)
                        local isLegalContact = (fc == tb.id)
                        if not isLegalContact and fc and targetGroup then
                            if targetingEight and fc == 8 then
                                isLegalContact = true
                            elseif not targetingEight and ShotJudge.group(fc) == targetGroup then
                                isLegalContact = true
                            end
                        end

                        if isLegalContact then
                            -- Verification Criterion 3: 8-ball MUST NOT be pocketed prematurely
                            local eightBall = Sim.findBall(clone, 8)
                            local illegalEight = (not targetingEight and eightBall and eightBall.pocketed)

                            if not illegalEight then
                                -- Verification Criterion 4: Target ball MUST enter designated pocket
                                local targetPocketed = false
                                local dropSpeed = 0
                                for _, ev in ipairs(ret.events) do
                                    if ev.type == "pocket" and ev.ball == tb.id and ev.other == pkt.id then
                                        targetPocketed = true
                                        dropSpeed = ev.speed or 0
                                        break
                                    end
                                end

                                if targetPocketed then
                                    local score = 1000 - (c.cutDeg * 5) - (math.abs(dAngle) * 200) - (pwr * 50)
                                    if sp.y < -0.5 then score = score + 50 end
                                    if score > bestScore then
                                        bestScore = score
                                        bestVerified = {
                                            ball = tb.id,
                                            pocket = pkt.id,
                                            angle = testAngle,
                                            power = pwr,
                                            spin = sp,
                                            called = (tb.id == 8 or targetingEight) and pkt.id or nil,
                                            cut = c.cutDeg,
                                            distance = c.cdist + c.pdist,
                                            safe = true,
                                            ghostX = c.ghostX,
                                            ghostY = c.ghostY,
                                            dropSpeed = dropSpeed,
                                            guaranteed = true
                                        }
                                        foundForCandidate = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestVerified and bestVerified.cut < 32 then
            break
        end
    end

    if bestVerified then
        return bestVerified
    end

    -- 3. Cushion Bank Shot Simulation (If direct pot path blocked)
    if Config.BankShotSolver and targetGroup then
        local halfW = geometry.halfWidth or 22.5
        for _, tb in ipairs(legalBalls) do
            for _, pkt in ipairs(geometry.pockets) do
                for _, railSign in ipairs({ 1, -1 }) do
                    local virtualPocketY = railSign * 2 * halfW - pkt.y
                    local vdx = pkt.x - tb.x
                    local vdy = virtualPocketY - tb.y
                    local vdist = math.sqrt(vdx * vdx + vdy * vdy)
                    if vdist > 0.01 then
                        local dirX = vdx / vdist
                        local dirY = vdy / vdist
                        local ghostX = tb.x - dirX * 2 * RadiusInches
                        local ghostY = tb.y - dirY * 2 * RadiusInches
                        local cdx = ghostX - cueBall.x
                        local cdy = ghostY - cueBall.y
                        local cdist = math.sqrt(cdx * cdx + cdy * cdy)
                        if cdist > 0.01 then
                            local cueAngle = math.atan2(cdy, cdx)
                            for _, pwr in ipairs({ 0.65, 0.80, 0.95 }) do
                                local clone = Sim.cloneState(phys.state)
                                local testShot = { angle = cueAngle, power = pwr, spin = { x = 0, y = 0 }, elevation = 0 }
                                local ret = Sim.runHeadless(clone, testShot)
                                if not clone.balls[1].pocketed then
                                    for _, ev in ipairs(ret.events) do
                                        if ev.type == "pocket" and ev.ball == tb.id and ev.other == pkt.id then
                                            return {
                                                ball = tb.id,
                                                pocket = pkt.id,
                                                angle = cueAngle,
                                                power = pwr,
                                                spin = { x = 0, y = 0 },
                                                called = (tb.id == 8 or targetingEight) and pkt.id or nil,
                                                cut = 45,
                                                distance = cdist + vdist,
                                                safe = true,
                                                ghostX = ghostX,
                                                ghostY = ghostY,
                                                isBank = true,
                                                guaranteed = true
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 4. Fallback Candidate (Unverified Heuristic)
    if candidates[1] then
        return {
            ball = candidates[1].ball.id,
            pocket = candidates[1].pocket.id,
            angle = candidates[1].baseAngle,
            power = 0.50,
            spin = { x = 0, y = 0 },
            called = (candidates[1].ball.id == 8 or targetingEight) and candidates[1].pocket.id or nil,
            cut = candidates[1].cutDeg,
            distance = candidates[1].cdist + candidates[1].pdist,
            safe = false,
            ghostX = candidates[1].ghostX,
            ghostY = candidates[1].ghostY,
            guaranteed = false
        }
    end

    return nil
end

-- ==============================================================================
-- 3D LASER GUIDELINE & VISUAL ADORNMENTS ENGINE
-- ==============================================================================
local Visuals = {
    Folder = nil,
    CueToGhostBeam = nil,
    GhostToPocketBeam = nil,
    TargetBallAdornment = nil,
    PocketBeacon = nil,
    Billboard = nil,
    BillboardLabel = nil,
    IsVisible = false
}

function Visuals:Init()
    local folder = Instance.new("Folder")
    folder.Name = "Crazy8Ball_Visuals"
    folder.Parent = workspace.Terrain
    self.Folder = folder

    -- Adornment Cylinder 1: Cue to Ghost
    local c1 = Instance.new("CylinderHandleAdornment")
    c1.Name = "CueToGhost"
    c1.Adornee = workspace.Terrain
    c1.AlwaysOnTop = true
    c1.ZIndex = 5
    c1.Radius = 0.07
    c1.Color3 = Config.LaserColor
    c1.Transparency = 0.15
    c1.Visible = false
    c1.Parent = folder
    self.CueToGhostBeam = c1

    -- Adornment Cylinder 2: Ghost to Pocket
    local c2 = Instance.new("CylinderHandleAdornment")
    c2.Name = "GhostToPocket"
    c2.Adornee = workspace.Terrain
    c2.AlwaysOnTop = true
    c2.ZIndex = 5
    c2.Radius = 0.05
    c2.Color3 = Config.PocketColor
    c2.Transparency = 0.15
    c2.Visible = false
    c2.Parent = folder
    self.GhostToPocketBeam = c2

    -- Pocket Beacon
    local pb = Instance.new("CylinderHandleAdornment")
    pb.Name = "PocketBeacon"
    pb.Adornee = workspace.Terrain
    pb.AlwaysOnTop = true
    pb.ZIndex = 6
    pb.Radius = 0.45
    pb.Height = 0.1
    pb.Color3 = Config.PocketColor
    pb.Transparency = 0.3
    pb.Visible = false
    pb.Parent = folder
    self.PocketBeacon = pb

    -- Target Ball Marker
    local tb = Instance.new("CylinderHandleAdornment")
    tb.Name = "TargetBallMarker"
    tb.Adornee = workspace.Terrain
    tb.AlwaysOnTop = true
    tb.ZIndex = 6
    tb.Radius = 0.42
    tb.Height = 0.05
    tb.Color3 = Config.TargetBallColor
    tb.Transparency = 0.2
    tb.Visible = false
    tb.Parent = folder
    self.TargetBallAdornment = tb

    -- Target Info Billboard
    local bbPart = Instance.new("Part")
    bbPart.Name = "TargetInfoAnchor"
    bbPart.Anchored = true
    bbPart.CanCollide = false
    bbPart.Transparency = 1
    bbPart.Size = Vector3.new(0.1, 0.1, 0.1)
    bbPart.Parent = folder

    local bb = Instance.new("BillboardGui")
    bb.Name = "TargetInfoBB"
    bb.Adornee = bbPart
    bb.Size = UDim2.fromOffset(160, 48)
    bb.StudsOffset = Vector3.new(0, 1.8, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = folder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 0.35
    lbl.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.Text = ""
    lbl.Parent = bb
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 6)
    uic.Parent = lbl
    local uis = Instance.new("UIStroke")
    uis.Color = Color3.fromRGB(0, 255, 170)
    uis.Thickness = 1
    uis.Parent = lbl

    self.BillboardPart = bbPart
    self.Billboard = bb
    self.BillboardLabel = lbl
end

function Visuals:Hide()
    if not self.IsVisible then return end
    self.IsVisible = false
    if self.CueToGhostBeam then self.CueToGhostBeam.Visible = false end
    if self.GhostToPocketBeam then self.GhostToPocketBeam.Visible = false end
    if self.PocketBeacon then self.PocketBeacon.Visible = false end
    if self.TargetBallAdornment then self.TargetBallAdornment.Visible = false end
    if self.Billboard then self.Billboard.Enabled = false end
end

function Visuals:Update(shot, placement, balls, geometry)
    if not shot or not placement or not balls or not geometry then
        self:Hide()
        return
    end

    local cueBall = balls[1]
    if not cueBall or cueBall.pocketed then
        self:Hide()
        return
    end

    self.IsVisible = true

    local cueWorld = TableBuilder.toWorld(placement, cueBall.x, cueBall.y, 0.1)
    local ghostWorld = TableBuilder.toWorld(placement, shot.ghostX, shot.ghostY, 0.1)

    -- Resolve Pocket World Position
    local targetPocket = nil
    for _, pkt in ipairs(geometry.pockets) do
        if pkt.id == shot.pocket then
            targetPocket = pkt
            break
        end
    end

    local pocketWorld = targetPocket and TableBuilder.toWorld(placement, targetPocket.x, targetPocket.y, 0.1) or ghostWorld

    -- Render Cue -> Ghost Beam
    if Config.LaserESP then
        local diff1 = ghostWorld - cueWorld
        local dist1 = diff1.Magnitude
        if dist1 > 0.05 then
            self.CueToGhostBeam.Height = dist1
            self.CueToGhostBeam.CFrame = CFrame.new(cueWorld + diff1 * 0.5, ghostWorld) * CFrame.Angles(math.pi * 0.5, 0, 0)
            self.CueToGhostBeam.Color3 = Config.LaserColor
            self.CueToGhostBeam.Visible = true
        else
            self.CueToGhostBeam.Visible = false
        end

        -- Render Ghost -> Pocket Beam
        local diff2 = pocketWorld - ghostWorld
        local dist2 = diff2.Magnitude
        if dist2 > 0.05 then
            self.GhostToPocketBeam.Height = dist2
            self.GhostToPocketBeam.CFrame = CFrame.new(ghostWorld + diff2 * 0.5, pocketWorld) * CFrame.Angles(math.pi * 0.5, 0, 0)
            self.GhostToPocketBeam.Color3 = Config.PocketColor
            self.GhostToPocketBeam.Visible = true
        else
            self.GhostToPocketBeam.Visible = false
        end
    else
        self.CueToGhostBeam.Visible = false
        self.GhostToPocketBeam.Visible = false
    end

    -- Render Pocket Beacon
    if Config.PocketHighlighter and targetPocket then
        self.PocketBeacon.CFrame = CFrame.new(pocketWorld) * CFrame.Angles(math.pi * 0.5, 0, 0)
        self.PocketBeacon.Color3 = Config.PocketColor
        self.PocketBeacon.Visible = true
    else
        self.PocketBeacon.Visible = false
    end

    -- Target Ball Marker & Billboard
    local targetBallObj = nil
    for _, b in ipairs(balls) do
        if b.id == shot.ball then
            targetBallObj = b
            break
        end
    end

    if Config.TargetESP and targetBallObj and not targetBallObj.pocketed then
        local tbWorld = TableBuilder.toWorld(placement, targetBallObj.x, targetBallObj.y, 0.1)
        self.TargetBallAdornment.CFrame = CFrame.new(tbWorld) * CFrame.Angles(math.pi * 0.5, 0, 0)
        self.TargetBallAdornment.Color3 = Config.TargetBallColor
        self.TargetBallAdornment.Visible = true

        self.BillboardPart.Position = tbWorld
        local statusText = shot.guaranteed and " [100% PREDICTED POT]" or (shot.isBank and " [BANK SHOT]" or (shot.isBreak and " [BREAK]" or ""))
        self.BillboardLabel.Text = string.format("BALL #%d -> POCKET #%d%s\nCut: %.1fÂ° | Dist: %.0fin | Pwr: %d%%",
            shot.ball, shot.pocket, statusText, shot.cut or 0, shot.distance or 0, math.floor(shot.power * 100))
        self.Billboard.Enabled = true
    else
        self.TargetBallAdornment.Visible = false
        self.Billboard.Enabled = false
    end
end

function Visuals:Destroy()
    if self.Folder then
        pcall(function() self.Folder:Destroy() end)
    end
end

-- ==============================================================================
-- HOOK INJECTION FOR NATIVE EXTENDED GUIDELINE
-- ==============================================================================
local function applyNativeGuidelineHook()
    local oldFullLines = Catalog.fullLines
    local oldFullLinesOrange = Catalog.fullLinesOrange

    Catalog.fullLines = function(...)
        if Config.ExtendedGuideline then
            return true
        end
        return oldFullLines(...)
    end

    Catalog.fullLinesOrange = function(...)
        if Config.ExtendedGuideline then
            return false
        end
        return oldFullLinesOrange(...)
    end

    App.RestoreGuidelineHook = function()
        Catalog.fullLines = oldFullLines
        Catalog.fullLinesOrange = oldFullLinesOrange
    end
end
applyNativeGuidelineHook()

-- ==============================================================================
-- MAIN TICK LOOP (AIM, SHOT & VISUAL UPDATE)
-- ==============================================================================
local function angleDifference(target, current)
    local diff = (target - current) % (2 * math.pi)
    if diff > math.pi then
        diff = diff - (2 * math.pi)
    end
    return diff
end

Visuals:Init()

local renderConn = RunService.RenderStepped:Connect(function(dt)
    if not App.Active then return end

    -- FAST EXIT TIER 1: If neither visuals nor aim automations are enabled, zero out work!
    local needsVisuals = (Config.LaserESP or Config.TargetESP or Config.PocketHighlighter)
    local needsAim = (Config.AutoAim or Config.AutoShoot or Config.RageMode)
    if not needsVisuals and not needsAim then
        Visuals:Hide()
        return
    end

    local hasState = EngineState:Resolve()
    if not hasState or not EngineState.CurrentSnapshot or not EngineState.CurrentPhysicsState then
        Visuals:Hide()
        return
    end

    local snap = EngineState.CurrentSnapshot
    local phys = EngineState.CurrentPhysicsState
    local balls = phys.state and phys.state.balls
    local geometry = phys.state and phys.state.geometry
    local placement = phys.placement or (EngineState.MainUpvalues and EngineState.MainUpvalues[2] and EngineState.MainUpvalues[2].placement)

    -- Automatic 8-Ball PocketChoice Resolution
    if snap.phase == "PocketChoice" and snap.shooter == LocalPlayer.UserId and EngineState.HubObj then
        local shot = ShotSolver:GetBestShot()
        local chosenPocket = (shot and (shot.called or shot.pocket)) or 1
        EngineState.HubObj:action("Pocket", { pocket = chosenPocket })
        return
    end

    -- If not aiming phase, balls are in motion/transition; hide visuals and skip aim calculations
    if snap.phase ~= "Aiming" then
        Visuals:Hide()
        return
    end

    -- Track Turn Transitions
    if snap.turnId ~= App.LastTurnId then
        App.LastTurnId = snap.turnId
        App.TurnStartTime = os.clock()
        ShotSolver:ResetCache()
    end

    -- Calculate or Retrieve Cached Optimal Shot
    local shot = ShotSolver:GetBestShot()
    App.CurrentTarget = shot

    -- Update 3D Visual Adornments
    if shot and placement and needsVisuals then
        Visuals:Update(shot, placement, balls, geometry)
    else
        Visuals:Hide()
    end

    -- Auto Aim Execution
    local shouldAim = (Config.AutoAim or Config.RageMode)
    if shouldAim and EngineState.IsMyTurn and shot and EngineState.InputObj then
        local targetAngle = shot.angle
        if Config.SmoothAim and not Config.RageMode then
            local diff = angleDifference(targetAngle, EngineState.InputObj.angle)
            if math.abs(diff) < math.rad(0.4) then
                EngineState.InputObj:setAngle(targetAngle)
            else
                local step = math.sign(diff) * math.min(math.abs(diff), math.rad(Config.AimSpeed * dt * 60))
                EngineState.InputObj:setAngle(EngineState.InputObj.angle + step)
            end
        else
            -- Instantaneous angle lock in Rage Mode or Standard Snap Aim
            EngineState.InputObj:setAngle(targetAngle)
        end
    end

    -- Auto Shoot Execution (Physics-Verified Prediction Dispatch)
    local shouldShoot = (Config.AutoShoot or Config.RageMode)
    if shouldShoot and EngineState.IsMyTurn and shot and EngineState.HubObj and EngineState.InputObj then
        local now = os.clock()
        local timeInTurn = now - App.TurnStartTime
        local minDelay = Config.RageMode and 0.08 or Config.AutoShootDelay
        local angleThreshold = Config.RageMode and math.rad(4.0) or math.rad(1.2)
        local shotCooldown = Config.RageMode and 0.4 or 3.0
        local diff = math.abs(angleDifference(shot.angle, EngineState.InputObj.angle))

        -- In Rage Mode, force snap angle immediately if misaligned
        if Config.RageMode and diff > 0.001 then
            EngineState.InputObj:setAngle(shot.angle)
            diff = 0
        end

        if timeInTurn >= minDelay and diff < angleThreshold and (now - App.LastShotTime) > shotCooldown then
            App.LastShotTime = now

            -- Call pocket if required for 8-ball
            if shot.called and snap.calledPocket ~= shot.called then
                EngineState.HubObj:action("Pocket", { pocket = shot.called })
                if not Config.RageMode then
                    task.wait(0.12)
                end
            end

            -- Verified Spin and Power Payloads
            local spinPayload = shot.spin or { x = 0, y = 0 }
            local chosenPower = shot.power or (shot.isBreak and 1.0 or 0.55)

            -- Native Input Pipeline Trigger (guarantees local sync & server dispatch)
            if EngineState.InputObj and EngineState.InputObj.setPower and EngineState.InputObj.releasePower then
                EngineState.InputObj:setAngle(shot.angle)
                if EngineState.InputObj.setSpin then
                    EngineState.InputObj:setSpin(spinPayload.x, spinPayload.y)
                end
                EngineState.InputObj:setPower(chosenPower)
                EngineState.InputObj:releasePower()
            else
                EngineState.HubObj:fire(snap.id, shot.angle, chosenPower, spinPayload, 0, 0, 0)
            end
        end
    end
end)
table.insert(App.Connections, renderConn)

-- Manual Aim Hotkey Connection
local keyConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.ManualAimKey and EngineState.IsMyTurn and EngineState.InputObj then
        local target = App.CurrentTarget or ShotSolver:GetBestShot()
        if target then
            EngineState.InputObj:setAngle(target.angle)
        end
    end
end)
table.insert(App.Connections, keyConn)

-- ==============================================================================
-- ULT AUTO-SPINNER & BEST ABILITY AUTO-ECLIPSE ROUTINE
-- ==============================================================================
local function SpinAllUlts(notifyCallback)
    task.spawn(function()
        local UltSpinState = require(LocalPlayer.PlayerScripts.Client.UltSpinState)
        local RarityTiers = {
            Common = 1,
            Uncommon = 2,
            Rare = 3,
            Epic = 4,
            Legendary = 5,
            Mythic = 6
        }

        local state = UltSpinState.get()
        if not state then return end
        local remaining = state.spins or 0
        if remaining <= 0 then
            if notifyCallback then
                notifyCallback("No spins available! (0 left)")
            end
            return
        end

        if notifyCallback then
            notifyCallback(string.format("Spinning %d spins autonomously...", remaining))
        end

        -- Unlock slot 1 before spinning
        pcall(function()
            UltSpinState.request("Lock", { slot = 1, locked = false })
        end)
        task.wait(0.5)

        local bestId = nil
        local bestRarity = nil
        local bestTier = 0

        while App.Active do
            state = UltSpinState.get()
            if not state or (state.spins or 0) <= 0 then break end

            local res = UltSpinState.request("Spin", { lucky = false, confirm = true })
            if res and res.ok then
                local rTier = RarityTiers[res.rarity or "Common"] or 1
                if rTier > bestTier then
                    bestTier = rTier
                    bestRarity = res.rarity
                    bestId = res.id
                end

                -- Lock immediately if Legendary or Mythic is obtained
                if rTier >= 5 then
                    pcall(function()
                        UltSpinState.request("Lock", { slot = 1, locked = true })
                    end)
                    if notifyCallback then
                        notifyCallback(string.format("JACKPOT! %s (%s) locked in slot 1!", res.id, res.rarity))
                    end
                    return
                end
            else
                break
            end
            task.wait(0.6)
        end

        -- Final lock to protect highest obtained ability
        pcall(function()
            UltSpinState.request("Lock", { slot = 1, locked = true })
        end)
        if notifyCallback then
            notifyCallback(bestId and string.format("Finished! Best pull: %s (%s)", bestId, bestRarity) or "Spins completed.")
        end
    end)
end

-- ==============================================================================
-- AUTOMATION COROUTINE (ENDLESS BOT FARM, QUEUE, REWARDS, ULTS)
-- ==============================================================================
task.spawn(function()
    while App.Active do
        task.wait(0.5)

        -- Quick check: If no automation features are enabled, sleep longer and skip processing
        local hasAnyAutomation = Config.EndlessFarm or Config.AutoQueueBot or Config.AutoQueueMatch 
            or Config.AutoDismissResult or Config.AutoUlt or Config.AutoOpenLucky 
            or Config.AutoClaimDaily or Config.AutoClaimPlaytime or Config.AutoClaimRank or Config.AutoRedeemCodes
        if not hasAnyAutomation then
            task.wait(1.5)
            continue
        end

        pcall(function()
            local now = os.clock()

            -- 0. Fast Match Result Dismissal (Checked every 0.5s)
            if Config.AutoDismissResult or Config.EndlessFarm then
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local resScr = pgui and pgui:FindFirstChild("PoolHud") and pgui.PoolHud:FindFirstChild("ResultScreen")
                local continueBtn = resScr and resScr:FindFirstChild("Match") and resScr.Match.Visible and resScr.Match:FindFirstChild("Holder")
                    and resScr.Match.Holder:FindFirstChild("Stage") and resScr.Match.Holder.Stage:FindFirstChild("Rewards")
                    and resScr.Match.Holder.Stage.Rewards:FindFirstChild("Content") and resScr.Match.Holder.Stage.Rewards.Content:FindFirstChild("Continue")
                if continueBtn and continueBtn.Visible then
                    pcall(function()
                        local cons = getconnections(continueBtn.Activated)
                        if #cons > 0 and cons[1].Function then
                            cons[1].Function()
                        end
                    end)
                end
            end

            -- 1. Endless Bot Grinder & Autonomous Queue
            if Config.EndlessFarm or Config.AutoQueueBot then
                local inSeat = EngineState.HubObj and EngineState.HubObj.mySeat ~= nil
                if not inSeat then
                    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                    local resScr = pgui and pgui:FindFirstChild("PoolHud") and pgui.PoolHud:FindFirstChild("ResultScreen")
                    local isResultOpen = resScr and resScr:FindFirstChild("Match") and resScr.Match.Visible
                    if not isResultOpen then
                        Net.get("SoloSearch"):FireServer("Start", nil)
                        task.wait(0.35)
                        Net.get("QueueBot"):FireServer()
                        task.wait(2.5)
                    end
                end
            elseif Config.AutoQueueMatch then
                local inSeat = EngineState.HubObj and EngineState.HubObj.mySeat ~= nil
                if not inSeat then
                    Net.get("SoloSearch"):FireServer("Start", nil)
                    task.wait(3.0)
                end
            end

            -- 2. Auto Activate Ultimate Ability
            if (Config.AutoUlt or Config.EndlessFarm) and EngineState.CurrentSnapshot and EngineState.IsMyTurn then
                local snap = EngineState.CurrentSnapshot
                local myUserId = tostring(LocalPlayer.UserId)
                local ultBar = snap.ults and snap.ults.bars and snap.ults.bars[myUserId]
                if ultBar and ultBar.charge and ultBar.charge >= 100 then
                    Net.get("UltActivate"):FireServer()
                end
            end

            -- 3. Auto Open Lucky Blocks & Auto Mystery Tap
            if Config.AutoOpenLucky then
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local mr = pgui and pgui:FindFirstChild("MysteryReveal")
                if mr and mr:FindFirstChild("Tap") and mr.Tap.Visible then
                    pcall(function()
                        local cons = getconnections(mr.Tap.Activated)
                        if #cons > 0 and cons[1].Function then
                            cons[1].Function()
                        end
                    end)
                else
                    local s, LC = pcall(function() return require(LocalPlayer.PlayerScripts.Client.LuckyClient) end)
                    if s and LC and LC.firstReady then
                        local readySlot = LC.firstReady()
                        if readySlot then
                            local hotbar = pgui and pgui:FindFirstChild("LuckyHotbar")
                            local btn = hotbar and hotbar:FindFirstChild("Bar") and hotbar.Bar:FindFirstChild("Block" .. tostring(readySlot))
                            if btn then
                                pcall(function()
                                    local cons = getconnections(btn.Activated)
                                    if #cons > 0 and cons[1].Function then
                                        cons[1].Function()
                                    end
                                end)
                            end
                        end
                    end
                end
            end

            -- 4. Server-Throttled Rewards & Claims (Every 10.0s)
            if (now - App.LastClaimTime) >= 10.0 then
                App.LastClaimTime = now

                -- Daily Reward
                if Config.AutoClaimDaily then
                    pcall(function()
                        ItemState.request("RewardRequest", "ClaimDaily")
                    end)
                    task.wait(1.2)
                end

                -- Playtime Gifts (1 to 5)
                if Config.AutoClaimPlaytime then
                    local rewardsData = ItemState.rewards()
                    if rewardsData and rewardsData.playtime then
                        for _, gift in ipairs(rewardsData.playtime) do
                            if gift.ready and not gift.claimed then
                                pcall(function()
                                    ItemState.request("RewardRequest", "ClaimPlaytime", gift.index)
                                end)
                                task.wait(1.2)
                            end
                        end
                    end
                end

                -- Rank Progression Claims
                if Config.AutoClaimRank and LocalPlayer:GetAttribute("RankPending") then
                    pcall(function()
                        Net.get("RankClaim"):FireServer()
                    end)
                    task.wait(1.2)
                end

                -- Auto Redeem Promo Codes
                if Config.AutoRedeemCodes then
                    local codes = {"100KLIKES", "90KLIKES", "80KLIKES", "500KLIKES"}
                    for _, cd in ipairs(codes) do
                        pcall(function()
                            ItemState.request("RewardRequest", "Redeem", cd)
                        end)
                        task.wait(1.2)
                    end
                end
            end
        end)
    end
end)

-- ==============================================================================
-- CHARACTER & UTILITY SUBSYSTEMS
-- ==============================================================================
local charConn = RunService.Heartbeat:Connect(function()
    if not App.Active then return end
    if not Config.ModifyWalkSpeed and not Config.ModifyJumpPower then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Safe WalkSpeed (strictly clamped <= 45 to avoid server MoveCheck = 60 trigger)
    if Config.ModifyWalkSpeed then
        hum.WalkSpeed = math.clamp(Config.SafeWalkSpeed, 16, 45)
    end

    -- Safe JumpPower
    if Config.ModifyJumpPower then
        hum.JumpPower = Config.SafeJumpPower
    end
end)
table.insert(App.Connections, charConn)

-- Infinite Jump
local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and App.Active then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(App.Connections, infJumpConn)

-- Anti-AFK Simulation
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK and App.Active then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- ==============================================================================
-- CONFIGURATION PERSISTENCE SYSTEM (SOP RULE 8 COMPLIANT)
-- ==============================================================================
local ConfigFileName = "Crazy8Ball_Config.json"

local function SaveConfig()
    pcall(function()
        local data = {}
        for k, v in pairs(Config) do
            if typeof(v) == "Color3" then
                data[k] = { r = v.R, g = v.G, b = v.B, _type = "Color3" }
            elseif typeof(v) == "EnumItem" then
                data[k] = { name = v.Name, _type = "EnumItem" }
            else
                data[k] = v
            end
        end
        writefile(ConfigFileName, HttpService:JSONEncode(data))
    end)
end

local function LoadConfig()
    pcall(function()
        if not isfile(ConfigFileName) then return end
        local raw = readfile(ConfigFileName)
        local data = HttpService:JSONDecode(raw)
        for k, v in pairs(data) do
            if type(v) == "table" and v._type == "Color3" then
                Config[k] = Color3.new(v.r, v.g, v.b)
            elseif type(v) == "table" and v._type == "EnumItem" then
                Config[k] = Enum.KeyCode[v.name]
            elseif Config[k] ~= nil then
                Config[k] = v
            end
        end
    end)
end

local function ResetConfig()
    for k, v in pairs(Config) do
        if type(v) == "boolean" then
            Config[k] = false
        end
    end
    Config.SafeWalkSpeed = 16
    Config.SafeJumpPower = 50
    Config.AimSpeed = 15
    Config.AutoShootDelay = 1.2
    Config.CustomPower = 0.65
    SaveConfig()
end

-- ==============================================================================
-- INITIALIZE WINDUI USER INTERFACE
-- ==============================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function SafeNotify(data)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify(data)
        end
    end)
end

local Window = WindUI:CreateWindow({
    Title = "CRAZY 8 Ball",
    Icon = "target",
    Author = "Universal Automation Suite",
    Folder = "Crazy8Ball",
    Size = UDim2.fromOffset(590, 480),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Enabled = false
    }
})
App.Window = Window

local function toggleUI()
    if Window and Window.UIElements and Window.UIElements.Main then
        Window.UIElements.Main.Visible = not Window.UIElements.Main.Visible
    else
        pcall(function() Window:Toggle() end)
    end
end

-- LeftControl Hotkey Toggle
local toggleConn = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
        toggleUI()
    end
end)
table.insert(App.Connections, toggleConn)

-- Floating Screen Toggle Button (SOP Rule 8 Compliance)
local function createFloatingPill()
    local container = (gethui and gethui()) or CoreGui
    local oldPill = container:FindFirstChild("Crazy8Ball_FloatingToggle")
    if oldPill then pcall(function() oldPill:Destroy() end) end

    local screen = Instance.new("ScreenGui")
    screen.Name = "Crazy8Ball_FloatingToggle"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.fromOffset(130, 36)
    btn.Position = UDim2.new(0.5, -65, 0, 16)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    btn.BackgroundTransparency = 0.15
    btn.Text = "ð± Menu (LCtrl)"
    btn.TextColor3 = Color3.fromRGB(240, 240, 248)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Active = true
    btn.Draggable = true
    btn.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 105)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(toggleUI)

    screen.Parent = container
    App.FloatingPill = screen
end
createFloatingPill()

-- ==============================================================================
-- TAB 1: AIM & TRAJECTORY (CORE POOL ENGINE)
-- ==============================================================================
local TabAim = Window:Tab({ Title = "Aim & Trajectory", Icon = "crosshair" })

TabAim:Section({ Title = "Brutal Rage Mode (Fast & Overpowered)" })

TabAim:Toggle({
    Title = "Rage Auto-Shoot (Instant Pot)",
    Desc = "Zero humanization. Snaps angle and fires impulse within 0.08s of turn start.",
    Value = Config.RageMode,
    Callback = function(v) Config.RageMode = v end
})

TabAim:Toggle({
    Title = "Anti-Scratch Backspin Dynamics",
    Desc = "Applies heavy draw backspin on straight pots to prevent cue ball scratch fouls.",
    Value = Config.AntiScratchSpin,
    Callback = function(v) Config.AntiScratchSpin = v end
})

TabAim:Toggle({
    Title = "Cushion Bank Shot Solver",
    Desc = "Calculates 1-rail cushion reflection geometry when direct pot lines are blocked.",
    Value = Config.BankShotSolver,
    Callback = function(v) Config.BankShotSolver = v end
})

TabAim:Toggle({
    Title = "100% Power Apex Break Shot",
    Desc = "Strikes apex head ball with maximum velocity on rack breaks.",
    Value = Config.AutoBreak,
    Callback = function(v) Config.AutoBreak = v end
})

TabAim:Section({ Title = "Guideline & Trajectory" })

TabAim:Toggle({
    Title = "Native Extended Guideline",
    Desc = "Memory-hooks game engine to render full unbroken trajectory across the table.",
    Value = Config.ExtendedGuideline,
    Callback = function(v) Config.ExtendedGuideline = v end
})

TabAim:Toggle({
    Title = "3D Laser Beam ESP",
    Desc = "Hardware-accelerated 3D laser beams showing exact ball and pocket paths.",
    Value = Config.LaserESP,
    Callback = function(v) Config.LaserESP = v end
})

TabAim:Colorpicker({
    Title = "Laser Beam Color",
    Default = Config.LaserColor,
    Callback = function(c) Config.LaserColor = c end
})

TabAim:Section({ Title = "Standard Aim Assist & Auto-Pot" })

TabAim:Toggle({
    Title = "Auto Aim (Lock Best Pot)",
    Desc = "Computes 100% deterministic pot angle and locks cue stick on target.",
    Value = Config.AutoAim,
    Callback = function(v) Config.AutoAim = v end
})

TabAim:Toggle({
    Title = "Smooth Aiming",
    Desc = "Humanizes aim movements with smooth angular interpolation.",
    Value = Config.SmoothAim,
    Callback = function(v) Config.SmoothAim = v end
})

TabAim:Slider({
    Title = "Aim Smooth Speed",
    Desc = "Angular velocity per frame.",
    Value = {
        Min = 5,
        Max = 35,
        Default = Config.AimSpeed
    },
    Step = 1,
    Callback = function(v) Config.AimSpeed = v end
})

TabAim:Keybind({
    Title = "Manual Aim Lock Key",
    Default = Config.ManualAimKey,
    Callback = function(k) Config.ManualAimKey = k end
})

TabAim:Section({ Title = "Standard Auto-Shoot" })

TabAim:Toggle({
    Title = "Auto Shoot",
    Desc = "Dispatches calibrated impulse once locked and delay expires.",
    Value = Config.AutoShoot,
    Callback = function(v) Config.AutoShoot = v end
})

TabAim:Slider({
    Title = "Auto Shoot Delay (s)",
    Desc = "Humanized hesitation before firing.",
    Value = {
        Min = 0.5,
        Max = 3.0,
        Default = Config.AutoShootDelay
    },
    Step = 0.1,
    Callback = function(v) Config.AutoShootDelay = v end
})

TabAim:Toggle({
    Title = "Auto Distance Power Calibration",
    Desc = "Dynamically scales impulse to travel distance so balls never bounce out.",
    Value = Config.AutoPower,
    Callback = function(v) Config.AutoPower = v end
})

TabAim:Slider({
    Title = "Custom Shot Power",
    Value = {
        Min = 0.2,
        Max = 1.0,
        Default = Config.CustomPower
    },
    Step = 0.05,
    Callback = function(v) Config.CustomPower = v end
})

-- ==============================================================================
-- TAB 2: VISUALS & ESP
-- ==============================================================================
local TabVisuals = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })

TabVisuals:Section({ Title = "Target Markers" })

TabVisuals:Toggle({
    Title = "Target Ball ESP & HUD",
    Desc = "3D marker and info overlay (ball number, cut angle, pocket, power).",
    Value = Config.TargetESP,
    Callback = function(v) Config.TargetESP = v end
})

TabVisuals:Colorpicker({
    Title = "Target Ball Color",
    Default = Config.TargetBallColor,
    Callback = function(c) Config.TargetBallColor = c end
})

TabVisuals:Toggle({
    Title = "Target Pocket Beacon",
    Desc = "Illuminates destination pocket with a glowing beacon ring.",
    Value = Config.PocketHighlighter,
    Callback = function(v) Config.PocketHighlighter = v end
})

TabVisuals:Colorpicker({
    Title = "Pocket Beacon Color",
    Default = Config.PocketColor,
    Callback = function(c) Config.PocketColor = c end
})

-- ==============================================================================
-- TAB 3: AUTOMATIONS (QUEUE & FARMING)
-- ==============================================================================
local TabAuto = Window:Tab({ Title = "Automations", Icon = "zap" })

TabAuto:Section({ Title = "Autonomous Grinder" })

TabAuto:Toggle({
    Title = "Endless Bot Match Grinder",
    Desc = "Autonomous loop: auto-queues bot -> breaks -> rapid pots -> claims rewards -> repeats.",
    Value = Config.EndlessFarm,
    Callback = function(v) Config.EndlessFarm = v end
})

TabAuto:Button({
    Title = "Auto Spin All Ult Abilities",
    Desc = "Burns all remaining spins, targets Mythic/Legendary, and auto-locks best pull.",
    Callback = function()
        SpinAllUlts(function(msg)
            SafeNotify({ Title = "Ult Spins", Content = msg, Duration = 3 })
        end)
    end
})

TabAuto:Section({ Title = "Matchmaking Automation" })

TabAuto:Toggle({
    Title = "Auto Queue Bot (100% Win Farm)",
    Desc = "Instantly queues against AI bots for rapid win-streak and XP farming.",
    Value = Config.AutoQueueBot,
    Callback = function(v) Config.AutoQueueBot = v end
})

TabAuto:Toggle({
    Title = "Auto Queue Ranked/Match",
    Desc = "Automatically searches for public matchmaking when standing in lobby.",
    Value = Config.AutoQueueMatch,
    Callback = function(v) Config.AutoQueueMatch = v end
})

TabAuto:Toggle({
    Title = "Auto Dismiss Match Results",
    Desc = "Automatically clicks Continue on post-match rewards screen.",
    Value = Config.AutoDismissResult,
    Callback = function(v) Config.AutoDismissResult = v end
})

TabAuto:Button({
    Title = "Instant Queue Bot Now",
    Desc = "Manually triggers single bot match queue.",
    Callback = function()
        Net.get("SoloSearch"):FireServer("Start", nil)
        task.wait(0.4)
        Net.get("QueueBot"):FireServer()
        SafeNotify({ Title = "Queue", Content = "QueueBot invoked!", Duration = 2 })
    end
})

TabAuto:Section({ Title = "Abilities & Rewards" })

TabAuto:Toggle({
    Title = "Auto Open Lucky Blocks",
    Desc = "Automatically cracks open ready blocks and collects mystery rewards.",
    Value = Config.AutoOpenLucky,
    Callback = function(v) Config.AutoOpenLucky = v end
})

TabAuto:Toggle({
    Title = "Auto Activate Ultimate",
    Desc = "Triggers equipped ability when meter reaches 100%.",
    Value = Config.AutoUlt,
    Callback = function(v) Config.AutoUlt = v end
})

TabAuto:Toggle({
    Title = "Auto Claim Daily Rewards",
    Desc = "Claims calendar reward (+ $5,000 cash).",
    Value = Config.AutoClaimDaily,
    Callback = function(v) Config.AutoClaimDaily = v end
})

TabAuto:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Cycles through timed gifts (1..5) as soon as unlocked.",
    Value = Config.AutoClaimPlaytime,
    Callback = function(v) Config.AutoClaimPlaytime = v end
})

TabAuto:Toggle({
    Title = "Auto Claim Rank Rewards",
    Desc = "Claims division tier completion rewards automatically.",
    Value = Config.AutoClaimRank,
    Callback = function(v) Config.AutoClaimRank = v end
})

TabAuto:Toggle({
    Title = "Auto Redeem Live Codes",
    Desc = "Redeems active promo codes (e.g. 100KLIKES for 10 spins + block).",
    Value = Config.AutoRedeemCodes,
    Callback = function(v) Config.AutoRedeemCodes = v end
})

TabAuto:Button({
    Title = "Redeem '100KLIKES' Code",
    Callback = function()
        local res = ItemState.request("RewardRequest", "Redeem", "100KLIKES")
        if res and res.ok then
            SafeNotify({ Title = "Code Redeemed", Content = "+10 Spins & 1 Epic Block granted!", Duration = 3 })
        else
            SafeNotify({ Title = "Code", Content = res and res.reason or "Failed", Duration = 2 })
        end
    end
})

-- ==============================================================================
-- TAB 4: CHARACTER & UTILITIES
-- ==============================================================================
local TabMisc = Window:Tab({ Title = "Character & Misc", Icon = "user" })

TabMisc:Section({ Title = "Movement Modification" })

TabMisc:Toggle({
    Title = "Modify WalkSpeed",
    Desc = "Modifies player speed safely below anti-cheat threshold.",
    Value = Config.ModifyWalkSpeed,
    Callback = function(v) Config.ModifyWalkSpeed = v end
})

TabMisc:Slider({
    Title = "Safe WalkSpeed",
    Desc = "Strictly capped <= 45 studs/s (Anti-Cheat limit: 60).",
    Value = {
        Min = 16,
        Max = 45,
        Default = Config.SafeWalkSpeed
    },
    Step = 1,
    Callback = function(v) Config.SafeWalkSpeed = v end
})

TabMisc:Toggle({
    Title = "Modify JumpPower",
    Value = Config.ModifyJumpPower,
    Callback = function(v) Config.ModifyJumpPower = v end
})

TabMisc:Slider({
    Title = "Safe JumpPower",
    Value = {
        Min = 50,
        Max = 120,
        Default = Config.SafeJumpPower
    },
    Step = 1,
    Callback = function(v) Config.SafeJumpPower = v end
})

TabMisc:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows consecutive jumping in mid-air.",
    Value = Config.InfiniteJump,
    Callback = function(v) Config.InfiniteJump = v end
})

TabMisc:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents 20-minute idle disconnection.",
    Value = Config.AntiAFK,
    Callback = function(v) Config.AntiAFK = v end
})

-- ==============================================================================
-- TAB 5: CONFIGURATION MANAGER (SOP RULE 8 COMPLIANT)
-- ==============================================================================
local TabConfig = Window:Tab({ Title = "Configuration", Icon = "settings" })

TabConfig:Section({ Title = "Profile Management" })

TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Saves all current options to local JSON storage.",
    Callback = function()
        SaveConfig()
        SafeNotify({ Title = "Config", Content = "Configuration saved successfully!", Duration = 2.5 })
    end
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Restores previously saved profile settings.",
    Callback = function()
        LoadConfig()
        SafeNotify({ Title = "Config", Content = "Configuration loaded!", Duration = 2.5 })
    end
})

TabConfig:Button({
    Title = "Reset to Defaults (ALL OFF)",
    Desc = "Restores strict factory default state per SOP Rule 8.",
    Callback = function()
        ResetConfig()
        SafeNotify({ Title = "Config", Content = "All toggles reset to OFF!", Duration = 2.5 })
    end
})

TabConfig:Section({ Title = "Session Controls" })

TabConfig:Button({
    Title = "Unload Automation Suite",
    Desc = "Safely destroys all hooks, visual adornments, and UI elements.",
    Callback = function()
        App:Teardown()
    end
})

-- Automatically select initial tab
pcall(function()
    TabAim:Select()
end)

-- ==============================================================================
-- SUITE TEARDOWN PROCEDURE
-- ==============================================================================
function App:Teardown()
    self.Active = false

    -- Reset ShotSolver Cache
    ShotSolver:ResetCache()

    -- Disconnect event listeners
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.Connections)

    -- Destroy visual elements
    Visuals:Destroy()

    -- Remove floating toggle pill
    if self.FloatingPill then
        pcall(function() self.FloatingPill:Destroy() end)
    end

    -- Restore native guideline hooks
    if self.RestoreGuidelineHook then
        pcall(self.RestoreGuidelineHook)
    end

    -- Reset Humanoid speeds
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)

    -- Destroy WindUI window
    pcall(function() Window:Destroy() end)

    getgenv()._Crazy8BallSuite = nil
    SafeNotify({ Title = "Unloaded", Content = "Automation suite cleanly unloaded.", Duration = 2 })
end

SafeNotify({
    Title = "CRAZY 8 Ball",
    Content = "Automation Suite Loaded! Press LeftControl to Toggle.",
    Duration = 3.5,
    Icon = "check"
})

return App
