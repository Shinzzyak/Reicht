-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- ============================================================
-- CLIENT OP v3.7 â +1 Assassin Leveling (Pumpkin Reaper HW Boss & Priority Shield Core Engine)
-- God Mode      : Universal Clean Invulnerability (TakeDamage & MobPega Intercept + Instant Health Restore) [TERVERIFIKASI]
-- Fast Kill     : Instant 1-HP + JefeGolpe destroy + 50 CPS Burst DPS [TERVERIFIKASI]
-- Auto Boss     : Otomatis takeover farm saat BOSS fight buka (VOID COLOSSUS, FALLEN GOD, dll), lawan boss, lalu balik ke farm
-- Auto Boss HW  : Otomatis takeover & masuk event Halloween Boss (PUMPKIN REAPER), burst kill + dano packets, lalu balik ke farm
-- Auto Stage    : Loop Stage 1..93, claim WinPads, auto unlock & travel ke World berikutnya
-- Auto Farm     : TP dekat mob terdekat (auto-attack game jalan via AutoClick)
-- Auto Halloween: Loop Rondas otomatis (Lobby -> Halloween -> Rondas -> Safe Kill -> Repeat)
-- Keys          : B=AutoBoss | J=AutoBossHW | T=AutoStage | H=AutoHalloween | G=God | K=FastKill | F=AutoFarm | N=NoClip | X=Speed | C=Click | Z=Zone | R=Rebirth | P=Panel
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer

local genv = getgenv and getgenv() or _G
if genv.__CLIENTOP2 then pcall(genv.__CLIENTOP2.Stop) end
if genv.__CLIENTOP then pcall(genv.__CLIENTOP.Stop) end

-- Relentless cleanup: Purge orphaned GUI instances and disconnect any leaked executor inputs
pcall(function()
    local cgui = game:GetService("CoreGui")
    for _, c in ipairs(cgui:GetChildren()) do
        if c.Name == "ClientOP_FloatingBtn" or c.Name == "ClientOP_Gui" then
            pcall(function() c:Destroy() end)
        end
    end
    local oldPlat = workspace:FindFirstChild("ClientOP_HWPlatform")
    if oldPlat then pcall(function() oldPlat:Destroy() end) end
    local rgui = cgui:FindFirstChild("RobloxGui")
    if rgui then
        for _, c in ipairs(rgui:GetChildren()) do
            if c.Name:find("WindUI") then
                pcall(function() c:Destroy() end)
            end
        end
    end

    local getconn = getconnections or (debug and debug.getconnections)
    if getconn then
        local uis = game:GetService("UserInputService")
        for _, evt in ipairs({uis.InputBegan, uis.InputChanged, uis.InputEnded}) do
            pcall(function()
                for _, c in ipairs(getconn(evt)) do
                    local scr = nil
                    pcall(function() scr = c.Script end)
                    if scr and tostring(scr.Name):find("ClientOP") then
                        pcall(function() if c.Disconnect then c:Disconnect() elseif c.Disable then c:Disable() end end)
                    end
                end
            end)
        end
    end
end)

local S = {
    God = false,
    FastKill = false,
    AutoBoss = false,
    AutoBossHW = false,
    AntiAFK = false,
    AutoStage = false,
    AutoWorldPush = false,
    AutoStageFlash = false,
    FlashMode = false,
    StageCheckpoint = "VIP", -- "VIP" (Ungu/Kiri) | "FREE" (Kuning/Kanan)
    AutoFarm = false,
    NoClip = false,
    Speed = false,
    AutoClick = false,
    AutoZone = false,
    AutoRebirth = false,
    AutoHalloween = false,
    AutoClaim = false,
}
local CFG = {WalkSpeed = 120, MobHP = 0, FarmDist = 6, SafeDelay = 2.5, PushCadence = 25, FlashMode = false, ZoneRestTime = 0.8, ClickCPS = 50, ClickInterval = 0.02, StageCheckpoint = "VIP"}
local conns = {}
local running = true
local function on(sig, fn) local c = sig:Connect(fn) conns[#conns + 1] = c return c end

local function notify(t, m)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = t, Text = m, Duration = 2.5}) end)
end

-- Remotes & References
local Remotes = RS:WaitForChild("Remotes")
local ClickR = Remotes:WaitForChild("Click")
local RebirthR = Remotes:FindFirstChild("Rebirth")
local RondasR = Remotes:WaitForChild("Rondas")
local MundoR = Remotes:WaitForChild("Mundo")
local JefeR = Remotes:FindFirstChild("Jefe")
local JefeEstado = RS:FindFirstChild("JefeEstado")
local JefeHWDefs = nil
pcall(function()
    local sharedFolder = RS:FindFirstChild("Shared") or RS:WaitForChild("Shared", 2)
    local defs = sharedFolder and (sharedFolder:FindFirstChild("JefeHWDefs") or sharedFolder:WaitForChild("JefeHWDefs", 2))
    if defs then JefeHWDefs = require(defs) end
end)
local JefeHWEstado = RS:FindFirstChild("JefeHWEstado")
local JefeHWR = Remotes:FindFirstChild("JefeHW")
local RevivirR = Remotes:FindFirstChild("Revivir")
local DailyR = Remotes:FindFirstChild("Daily_Reclamar")
local RegalosR = Remotes:FindFirstChild("Regalos_Reclamar")
local MisionesR = Remotes:FindFirstChild("Misiones")
local HalloweenPassR = Remotes:FindFirstChild("HalloweenPass")
local OfflineR = Remotes:FindFirstChild("Offline")
local RegaloR = Remotes:FindFirstChild("Regalo")
local RegaloSalidaR = Remotes:FindFirstChild("RegaloSalida")
local CodigoCanjearR = Remotes:FindFirstChild("Codigo_Canjear")
local RegalosTiempoMod = RS:WaitForChild("Shared"):FindFirstChild("RegalosTiempo") and require(RS.Shared.RegalosTiempo)
local HalloweenPassMod = RS:WaitForChild("Shared"):FindFirstChild("HalloweenPass") and require(RS.Shared.HalloweenPass)
local ArenaFolder = RS:WaitForChild("Arena")
local ArenaRemotos = ArenaFolder:FindFirstChild("Remotos")
local CurarR = ArenaRemotos and ArenaRemotos:FindFirstChild("Curar")
local Areas = require(RS:WaitForChild("Shared"):WaitForChild("Areas"))
local Mundos = require(RS:WaitForChild("Shared"):WaitForChild("Mundos"))
local StageDefs = require(RS:WaitForChild("Arena"):WaitForChild("StageDefs"))
local JefeDefs = require(RS:WaitForChild("Shared"):WaitForChild("JefeDefs"))

-- ============================================================
-- 0. ANTI-AFK & AUTO-RECONNECT GUARDIAN (Mencegah Error Code 278 / 20 Min Idle Kick)
-- ============================================================
local function setupAntiAFK()
    -- 1. Netralkan koneksi bawaan Roblox CoreScript pada LP.Idled
    if getconnections then
        for _, conn in ipairs(getconnections(LP.Idled)) do
            if conn.Disable then
                conn:Disable()
            elseif conn.Disconnect then
                conn:Disconnect()
            end
        end
    end

    -- 2. Sambungkan event LP.Idled kustom: Simulasi klik virtual saat engine mendeteksi idle
    on(LP.Idled, function()
        if S.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end
    end)

    -- 3. Proactive keepalive loop (setiap 90 detik kirim pulsa input agar idle timer server selalu 0)
    task.spawn(function()
        while running do
            task.wait(90)
            if S.AntiAFK then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(10, 10))
                end)
            end
        end
    end)

    -- 4. Auto-Reconnect Watchdog (Otomatis klik tombol 'Reconnect' atau teleportasi ulang jika terputus)
    local reconnecting = false
    local function triggerReconnect()
        if reconnecting then return end
        reconnecting = true
        task.wait(2)
        -- Percobaan A: Tekan tombol Reconnect pada RobloxPromptGui jika ada
        pcall(function()
            local promptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            local po = promptGui and promptGui:FindFirstChild("promptOverlay")
            if po then
                for _, desc in ipairs(po:GetDescendants()) do
                    if desc:IsA("TextButton") and desc.Text:lower():find("reconnect") then
                        local firesignalFn = firesignal or (debug and debug.firesignal)
                        if firesignalFn then
                            firesignalFn(desc.MouseButton1Click)
                            return
                        end
                    end
                end
            end
        end)
        -- Percobaan B: Reconnect via TeleportService
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
    end

    pcall(function()
        on(GuiService.ErrorMessageChanged, triggerReconnect)
    end)
    pcall(function()
        local promptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        local po = promptGui and promptGui:FindFirstChild("promptOverlay")
        if po then
            on(po.ChildAdded, function(ch)
                if ch.Name == "ErrorPrompt" then
                    triggerReconnect()
                end
            end)
        end
    end)
end
setupAntiAFK()

-- Neutralize ArenaMobs 3-second spawn lock on Reinicio to allow ultra-fast stage farming
local function disableSpawnLock()
    pcall(function()
        if getconnections and RS:FindFirstChild("Arena") then
            local ArenaRemotos = RS.Arena:FindFirstChild("Remotos")
            local Reinicio = ArenaRemotos and ArenaRemotos:FindFirstChild("Reinicio")
            if Reinicio then
                for _, conn in ipairs(getconnections(Reinicio.OnClientEvent)) do
                    local scr = nil
                    pcall(function() scr = conn.Script end)
                    if not scr then
                        pcall(function()
                            if conn.Function and getfenv then
                                local ok, env = pcall(getfenv, conn.Function)
                                if ok and type(env) == "table" then
                                    scr = env.script
                                end
                            end
                        end)
                    end
                    if scr and tostring(scr.Name):find("ArenaMobs") then
                        if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
                    end
                end
            end
        end
    end)
end
disableSpawnLock()
on(LP.CharacterAdded, function()
    task.wait(0.5)
    disableSpawnLock()
end)

-- 1. UNIVERSAL GOD MODE: Continuous Health & Server-Replicated Curar Guardian
local function protectHumanoid(hum)
    if not hum then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum.BreakJointsOnDeath = false
end

-- Continuous God Mode Health & Anti-Death Engine (Murni defensif + Replikasi Curar Server)
task.spawn(function()
    while running do
        task.wait(0.08)
        if S.God then
            local c = LP.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then
                protectHumanoid(hum)
                if hum.Health < hum.MaxHealth or LP:GetAttribute("EnJefe") == true or LP:GetAttribute("EnRondas") == true or LP:GetAttribute("EnJefeHW") == true then
                    if CurarR then CurarR:FireServer() end
                    hum.Health = hum.MaxHealth
                end
            end
        end
    end
end)

-- Character Added & Revive suppression
local function protectCharacter(c)
    local hum = c:WaitForChild("Humanoid", 5)
    if hum then
        if S.God then
            protectHumanoid(hum)
        end
        on(hum.HealthChanged, function(h)
            if S.God and h < hum.MaxHealth then
                if CurarR then CurarR:FireServer() end
                hum.Health = hum.MaxHealth
            end
        end)
    end
end
if LP.Character then protectCharacter(LP.Character) end
on(LP.CharacterAdded, protectCharacter)

-- Auto-suppress Revivir UI & Server-side Auto-Revive
pcall(function()
    local rGui = LP.PlayerGui:FindFirstChild("RevivirGui")
    if rGui then
        on(rGui:GetPropertyChangedSignal("Enabled"), function()
            if S.God and rGui.Enabled then
                rGui.Enabled = false
                if CurarR then CurarR:FireServer() end
                if RevivirR then pcall(function() RevivirR:FireServer("revive") end) end
            end
        end)
    end
end)
if RevivirR then
    on(RevivirR.OnClientEvent, function(a1)
        if S.God and a1 == "abrir" then
            if CurarR then CurarR:FireServer() end
            pcall(function() RevivirR:FireServer("revive") end)
            local c = LP.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end)
end

-- Track round start time for safe delay
local roundStartTime = os.clock()
on(RondasR.OnClientEvent, function(a1)
    if a1 == "inicio" or a1 == "cuenta" or a1 == "entrar" then
        roundStartTime = os.clock()
    end
end)
on(LP:GetAttributeChangedSignal("Ronda"), function()
    roundStartTime = os.clock()
end)

-- 2. MOB FINDER (mendukung Tag Enemigo, _RondasMobs, _MobsLocal, _JefeArena & _JefeFX Bintang/Kristal/Minions)
local function allMobs()
    local t = {}
    local seen = {}
    local function add(m)
        if m and not seen[m] and m ~= LP.Character then
            seen[m] = true
            local h = m:FindFirstChildOfClass("Humanoid")
            local r = nil
            if m:IsA("Model") then
                r = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
            elseif m:IsA("BasePart") then
                r = m
            end
            local jg = m:FindFirstChild("JefeGolpe") or (m.Parent and m.Parent:FindFirstChild("JefeGolpe"))
            local bb = m:FindFirstChildOfClass("BillboardGui") or (m.Parent and m.Parent:FindFirstChildOfClass("BillboardGui"))
            if (h and h.Health > 0) or jg or (bb and r) then
                t[#t + 1] = {m = m, h = h, r = r, jg = jg}
            end
        end
    end
    for _, m in ipairs(CS:GetTagged("Enemigo")) do add(m) end
    local rFolder = workspace:FindFirstChild("_RondasMobs")
    if rFolder then
        for _, m in ipairs(rFolder:GetChildren()) do add(m) end
    end
    local mFolder = workspace:FindFirstChild("_MobsLocal")
    if mFolder then
        for _, m in ipairs(mFolder:GetChildren()) do add(m) end
    end
    local jfxFolder = workspace:FindFirstChild("_JefeFX")
    if jfxFolder then
        for _, m in ipairs(jfxFolder:GetChildren()) do
            if m.Name ~= "Jefe" and m.Name ~= "JefeBlanco_jefe" then add(m) end
        end
    end
    local jhwfxFolder = workspace:FindFirstChild("_JefeHWFX")
    if jhwfxFolder then
        for _, m in ipairs(jhwfxFolder:GetChildren()) do add(m) end
    end
    local arenaFolder = workspace:FindFirstChild("_JefeArena")
    if arenaFolder then
        local sacos = arenaFolder:FindFirstChild("Sacos")
        if sacos then
            for _, s in ipairs(sacos:GetChildren()) do add(s) end
        end
    end
    return t
end

-- HELPER: SAFE TELEPORT (ANTI-TUMBLE / STRICT UPRIGHT & GROUND-LOCKED)
local function getBossFloorY(x, z)
    local bCenter = JefeDefs.CENTRO or Vector3.new(-2600, 60, -2600)
    local d = (Vector3.new(x, 0, z) - Vector3.new(bCenter.X, 0, bCenter.Z)).Magnitude
    if d <= (JefeDefs.R_ARENA + 25) then
        return bCenter.Y + 3.4
    end
    local rayOrigin = Vector3.new(x, 110, z)
    local rayDir = Vector3.new(0, -90, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LP.Character then params.FilterDescendantsInstances = {LP.Character} end
    local hit = workspace:Raycast(rayOrigin, rayDir, params)
    if hit then
        return hit.Position.Y + 3.0
    end
    return 63.4
end

local function teleportTo(targetPos, lookTarget)
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not root then return end

    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.GettingUp then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    -- Always keep pitch and roll 0 (strictly upright)
    if lookTarget then
        local flatTarget = Vector3.new(lookTarget.X, targetPos.Y, lookTarget.Z)
        if (flatTarget - targetPos).Magnitude > 0.1 then
            root.CFrame = CFrame.lookAt(targetPos, flatTarget)
        else
            local _, curYaw, _ = root.CFrame:ToOrientation()
            root.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, curYaw, 0)
        end
    else
        local _, curYaw, _ = root.CFrame:ToOrientation()
        root.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, curYaw, 0)
    end

    -- Neutralize linear and angular velocities to prevent physics bouncing or free-fall jerking
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

-- 3. FAST KILL + NORMAL AUTO FARM
task.spawn(function()
    while running do
        task.wait(0.1)
        local list = allMobs()
        local inRondas = LP:GetAttribute("EnRondas") == true

        if S.FastKill then
            -- Safe delay HANYA di Rondas (Halloween), di Boss Arena & Stages instan tanpa delay!
            local allowKill = (not inRondas) or ((os.clock() - roundStartTime) >= CFG.SafeDelay)
            if allowKill then
                for _, x in ipairs(list) do
                    if x.h and x.h.Health > 0 then x.h.Health = 0 pcall(function() x.h:TakeDamage(999999) end) end
                    local jg = x.jg or x.m:FindFirstChild("JefeGolpe")
                    if jg and jg:IsA("BindableEvent") then
                        pcall(function() jg:Fire(10) end)
                    end
                end
            end
        end

        if S.AutoFarm and not S.AutoHalloween and not S.AutoStage and not (LP:GetAttribute("EnJefe") == true) and not (LP:GetAttribute("EnJefeHW") == true) then
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if root and #list > 0 then
                local best, bd = nil, math.huge
                for _, x in ipairs(list) do
                    local d = (x.r.Position - root.Position).Magnitude
                    if d < bd then best, bd = x, d end
                end
                if best and bd > CFG.FarmDist then
                    local mobPos = best.r.Position
                    local offsetDir = (root.Position - mobPos)
                    local flatDir = Vector3.new(offsetDir.X, 0, offsetDir.Z)
                    if flatDir.Magnitude < 0.1 then flatDir = Vector3.new(0, 0, 1) end
                    flatDir = flatDir.Unit * math.max(CFG.FarmDist - 1, 2)
                    local targetPos = mobPos + flatDir + Vector3.new(0, 0.5, 0)
                    teleportTo(targetPos, mobPos)
                end
            end
        end
    end
end)

-- 4. AUTO BOSS TAKEOVER & COMBAT ENGINE
local toggles = {}
local updateCheckpointUI = nil
local currentOrbitTarget = nil
local OMEGA_1000RPM = (1000 * 2 * math.pi) / 60 -- 104.7197551 rad/s
local function registerToggle(k, toggleObj)
    toggles[k] = toggleObj
end

local function setToggleSafe(k, v)
    if S[k] ~= nil then
        S[k] = v
        if k == "AutoStage" then
            S.AutoWorldPush = v
            S.AutoStageFlash = v
            S.FlashMode = v
            CFG.FlashMode = v
        end
        if k == "AutoStageFlash" then
            S.FlashMode = v
            CFG.FlashMode = v
        end
        if k == "AutoHalloween" and not v then
            pcall(exitHalloweenToLobby)
        end
        if k == "AutoFarm" and not v then
            pcall(function()
                local c = LP.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                if root then root.AssemblyLinearVelocity = Vector3.zero end
            end)
        end
        local t = toggles[k]
        if t then
            if typeof(t.Set) == "function" then
                pcall(function() t:Set(v) end)
            elseif typeof(t.SetValue) == "function" then
                pcall(function() t:SetValue(v) end)
            end
        end
    end
end

local savedFarmState = nil
local bossJoined = false
local bossJoinAttemptTime = 0
local bossClickerActive = false
local bossDescLabel = nil

local function formatTime(seconds)
    if seconds <= 0 then return "00:00" end
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d", m, s)
end

local function abreviar(a1)
    local v1 = math.max(0, a1)
    if v1 < 1000 then return tostring(math.ceil(v1)) end
    local suffs = {"", "K", "M", "B", "T", "Qa", "Qi"}
    local idx = 1
    while v1 >= 1000 and idx < #suffs do
        v1 = v1 / 1000
        idx = idx + 1
    end
    return string.format("%.1f%s", v1, suffs[idx])
end

-- Helper keluar dari Halloween World kembali ke World Lobby
local function exitHalloweenToLobby()
    if LP:GetAttribute("EnHalloween") ~= true then return end

    -- 1. Keluar dari arena Rondas jika sedang aktif
    if LP:GetAttribute("EnRondas") == true and RondasR then
        RondasR:FireServer("salir")
        local t0 = os.clock()
        while LP:GetAttribute("EnRondas") == true and (os.clock() - t0 < 2) do
            task.wait(0.1)
        end
    end

    -- 2. Sentuh PortalVuelta.Entrada untuk keluar dari Halloween World
    local hwFolder = workspace:FindFirstChild("HalloweenWorld")
    local pv = hwFolder and hwFolder:FindFirstChild("PortalVuelta")
    local entrada = pv and pv:FindFirstChild("Entrada")
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")

    if entrada and root then
        teleportTo(entrada.Position + Vector3.new(0, 1, 0))
        local touchFn = firetouchinterest or (debug and debug.firetouchinterest)
        if touchFn then
            touchFn(root, entrada, 0)
            task.wait(0.05)
            touchFn(root, entrada, 1)
        else
            root.AssemblyLinearVelocity = Vector3.new(0, 0, -5)
        end
        local t0 = os.clock()
        while LP:GetAttribute("EnHalloween") == true and (os.clock() - t0 < 3) do
            task.wait(0.2)
        end
    end
end

-- ============================================================
-- BEST ZONE & TRAINING AREA ENGINE
-- ============================================================
local zonePosCache = {
    -- World 1: A1 (x1.5), A7 (x11)
    ["x1.5"] = { pos = Vector3.new(-56.32, 8.31, -200.33), look = Vector3.new(-61.32, 5.21, -200.33) },
    ["x11"]  = { pos = Vector3.new(-56.32, 8.31, -232.18), look = Vector3.new(-61.33, 6.41, -232.18) },
    -- World 2: B5 (x24)
    ["x24"]  = { pos = Vector3.new(-56.32, 8.31, 3767.82), look = Vector3.new(-61.33, 6.41, 3767.82) },
    -- World 3: C6 (x32)
    ["x32"]  = { pos = Vector3.new(-56.32, 8.31, 7767.82), look = Vector3.new(-61.33, 6.41, 7767.82) },
    -- World 4: D6 (x40)
    ["x40"]  = { pos = Vector3.new(-56.32, 8.31, 11767.82), look = Vector3.new(-60.42, 10.02, 11767.91) },
    -- World 5: E1 (x43) - E6 (x57)
    ["x43"]  = { pos = Vector3.new(-56.32, 8.31, 15799.67), look = Vector3.new(-61.32, 5.21, 15799.67) },
    ["x46"]  = { pos = Vector3.new(-56.32, 8.31, 15783.78), look = Vector3.new(-61.32, 5.31, 15783.78) },
    ["x49"]  = { pos = Vector3.new(-19.47, 8.31, 15782.05), look = Vector3.new(-14.47, 5.21, 15782.05) },
    ["x52"]  = { pos = Vector3.new(-19.47, 8.31, 15765.89), look = Vector3.new(-14.47, 5.21, 15765.89) },
    ["x55"]  = { pos = Vector3.new(-56.25, 8.31, 15750.61), look = Vector3.new(-61.15, 5.51, 15750.61) },
    ["x57"]  = { pos = Vector3.new(-56.32, 8.31, 15767.82), look = Vector3.new(-61.33, 6.41, 15767.82) },
    -- World 6: F6 (x80)
    ["x80"]  = { pos = Vector3.new(-56.32, 8.31, 19767.82), look = Vector3.new(-61.33, 6.41, 19767.82) },
}

local function getZoneCenter(z)
    if not z then return nil end
    local folder = workspace:FindFirstChild(Areas.CARPETA)
    local m = folder and folder:FindFirstChild(z.modelo)
    if m then
        local suelo = m:FindFirstChild("Base") and m.Base:FindFirstChild("Suelo")
        if not suelo then
            suelo = m:FindFirstChild("Suelo", true)
        end
        local diana = m:FindFirstChild("Objetivo", true) or m:FindFirstChild("Diana", true) or m:FindFirstChildWhichIsA("Model")

        if suelo and suelo:IsA("BasePart") then
            local targetPos = suelo.Position + Vector3.new(0, 3.5, 0)
            local lookPos = diana and (diana:IsA("Model") and diana:GetPivot().Position or (diana:IsA("BasePart") and diana.Position))
            zonePosCache[z.nombre] = { pos = targetPos, look = lookPos }
            return targetPos, lookPos
        end

        local fallbackPos = m:GetPivot().Position + Vector3.new(0, 3.5, 0)
        zonePosCache[z.nombre] = { pos = fallbackPos, look = nil }
        return fallbackPos, nil
    end

    -- StreamingEnabled / distance cache
    if zonePosCache[z.nombre] then
        return zonePosCache[z.nombre].pos, zonePosCache[z.nombre].look
    end

    -- Universal mathematical formula relative to World 5 offset
    if z.mundo then
        local dzOffset = (z.mundo - 5) * 4000
        local fallbackPos = Vector3.new(-56.32, 8.31, 15767.82 + dzOffset)
        local fallbackLook = Vector3.new(-61.33, 6.41, 15767.82 + dzOffset)
        return fallbackPos, fallbackLook
    end

    return nil, nil
end

local function bestZone()
    local reb = tonumber(LP:GetAttribute("Rebirths")) or 0
    local maxWorld = tonumber(LP:GetAttribute("MundoMax")) or 1
    local best = nil
    for _, z in ipairs(Areas.LISTA) do
        local zm = z.mundo or 1
        local cost = z.coste or 0
        if (z.tipo == "rebirths" or z.tipo == "libre") and zm <= maxWorld and cost <= reb then
            if not best or z.mult > best.mult then
                best = z
            end
        end
    end
    return best
end

-- ============================================================
-- HELPER: WORLD NAVIGATION & AUTHORITATIVE RETURN ENGINE
-- ============================================================
local function getLobbySpawnPos(worldId)
    local zBase = (worldId - 1) * Mundos.DZ - 160.0
    return Vector3.new(-38.49, 8.4, zBase - 1.4)
end

local function getLobbyDoorPos(worldId)
    local zBase = (worldId - 1) * Mundos.DZ - 160.0
    return Vector3.new(35.0, 8.4, zBase - 1.7)
end

local function returnToHighestWorld()
    local maxW = tonumber(LP:GetAttribute("MundoMax")) or 1
    local inHW = LP:GetAttribute("EnHalloween") == true

    -- 1. Keluar dari Halloween World jika masih berada di dalamnya (kecuali jika sedang farming Halloween)
    if inHW and not S.AutoHalloween then
        exitHalloweenToLobby()
        task.wait(0.6)
    end

    -- 2. Jika sedang AutoZone atau sebelumnya farming Zone:
    -- Langsung teleportasikan ke bestZone di maxW!
    local isZoneFarm = S.AutoZone or (savedFarmState and savedFarmState.Zone) or (savedHWFarmState and savedHWFarmState.Zone)
    if isZoneFarm then
        local targetZone = bestZone()
        if targetZone then
            local centerPos, lookPos = getZoneCenter(targetZone)
            if centerPos then
                teleportTo(centerPos, lookPos)
                task.wait(0.3)
                teleportTo(centerPos, lookPos)
                return
            end
        end
    end

    -- 3. Fallback jika tidak sedang AutoZone:
    -- Pastikan karakter berada di Lobby Spawn world tertinggi (maxW)
    local spawnPos = getLobbySpawnPos(maxW)
    teleportTo(spawnPos)
    task.wait(0.3)
    if MundoR then
        MundoR:FireServer("viajar", maxW)
    end
    local t0 = os.clock()
    while (tonumber(LP:GetAttribute("Mundo")) or 1) < maxW and (os.clock() - t0 < 2.0) do
        task.wait(0.2)
    end
    teleportTo(spawnPos)
    task.wait(0.2)
end

task.spawn(function()
    while running do
        task.wait(0.2)
        if JefeEstado and JefeR then
            local fase = JefeEstado:GetAttribute("Fase")
            local hasta = tonumber(JefeEstado:GetAttribute("Hasta")) or 0
            local now = workspace:GetServerTimeNow()
            local rem = hasta - now
            local enJefe = LP:GetAttribute("EnJefe") == true
            local inHW = LP:GetAttribute("EnHalloween") == true
            local isHWBossActive = (LP:GetAttribute("EnJefeHW") == true) or hwBossJoined
            local bossName = tostring(JefeEstado:GetAttribute("Siguiente") or JefeEstado:GetAttribute("Nombre") or "BOSS")

            -- 1. PEMANTAU REALTIME + PRE-EXIT PROAKTIF (Khusus saat di Halloween World)
            -- Bila AutoBoss ON dan waktu menuju Boss tersisa <= 12 detik (DAN TIDAK sedang bertarung di Halloween Boss):
            if S.AutoBoss and not enJefe and not isHWBossActive and inHW and ((rem <= 12 and fase == "espera") or fase == "union") then
                -- Simpan status Halloween untuk di-resume kembali nanti
                if not savedFarmState then
                    savedFarmState = {
                        Stage = S.AutoStage,
                        Halloween = true,
                        Zone = S.AutoZone,
                    }
                end
                -- Matikan AutoHalloween agar tidak teleport masuk Rondas lagi
                if S.AutoHalloween then
                    setToggleSafe("AutoHalloween", false)
                end

                notify("Auto Boss", "Boss Preparation (" .. bossName .. "): Exiting Halloween World...")
                exitHalloweenToLobby()
            end

            -- 2. DETEKSI FASE UNION (PINTU DAFTAR BOSS DIBUKA)
            if S.AutoBoss and fase == "union" and not enJefe and not bossJoined and not isHWBossActive then
                -- Jika belum sempat tersimpan, simpan status farm saat ini
                if not savedFarmState and (S.AutoStage or S.AutoHalloween or S.AutoZone) then
                    savedFarmState = {
                        Stage = S.AutoStage,
                        Halloween = S.AutoHalloween,
                        Zone = S.AutoZone,
                    }
                    if S.AutoStage then
                        setToggleSafe("AutoStage", false)
                    end
                    if S.AutoHalloween then
                        setToggleSafe("AutoHalloween", false)
                    end
                    if S.AutoZone then
                        setToggleSafe("AutoZone", false)
                    end
                end

                -- Pastikan sudah berada di luar Halloween
                if LP:GetAttribute("EnHalloween") == true then
                    exitHalloweenToLobby()
                end

                notify("Auto Boss", "Joining BOSS Fight: " .. bossName .. "!")
                JefeR:FireServer("unirse")
                bossJoined = true
                bossJoinAttemptTime = os.clock()
                task.wait(1.5)
            end

            -- 3. TIMEOUT GUARD: Jika join gagal / boss penuh
            if bossJoined and not enJefe and (os.clock() - bossJoinAttemptTime > 15) and fase ~= "union" and fase ~= "preparando" then
                bossJoined = false
                returnToHighestWorld()
                if savedFarmState then
                    notify("Auto Boss", "Failed to join boss (full/closed). Restoring farm...")
                    if savedFarmState.Stage then
                        setToggleSafe("AutoStage", true)
                    elseif savedFarmState.Halloween then
                        setToggleSafe("AutoHalloween", true)
                    elseif savedFarmState.Zone then
                        setToggleSafe("AutoZone", true)
                    elseif savedFarmState.Farm then
                        setToggleSafe("AutoFarm", true)
                    end
                    savedFarmState = nil
                end
            end

            -- 4. COMBAT LOOP SAAT DI DALAM ARENA BOSS (enJefe == true)
            if enJefe then
                bossJoined = true
                local c = LP.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                if root then
                    local bCenter = JefeDefs.CENTRO or Vector3.new(-2600, 60.8, -2600)

                    -- Dedicated high-frequency auto-clicker (50 CPS burst DPS)
                    if not bossClickerActive then
                        bossClickerActive = true
                        task.spawn(function()
                            while running and (LP:GetAttribute("EnJefe") == true) do
                                if ClickR then ClickR:FireServer() end
                                task.wait(0.02)
                            end
                            bossClickerActive = false
                        end)
                    end

                    -- FUNGSI NAVIGASI PANAH & DETEKSI TARGET AKTIF
                    local function getShieldPos(var, i, now)
                        local floorY = bCenter.Y + 3.4
                        local jfx = workspace:FindFirstChild("_JefeFX")
                        local pModel = jfx and jfx:FindFirstChild("JefeBlanco_p" .. i)
                        if pModel and pModel:IsA("Model") then
                            local p = pModel:GetPivot().Position
                            return Vector3.new(p.X, floorY, p.Z), pModel
                        end

                        if var == 1 then
                            -- Void Colossus: Void Shards (deriva orbit)
                            local fa = tonumber(JefeEstado:GetAttribute("FA" .. i))
                            local ft = tonumber(JefeEstado:GetAttribute("FT" .. i))
                            local p = JefeDefs.puntoDeriva(1, i, fa, ft, now)
                            if p then return Vector3.new(p.X, floorY, p.Z), pModel or ("shard_" .. i) end
                        elseif var == 5 then
                            -- Fallen God: Fallen Star (SX / SZ)
                            local sx = tonumber(JefeEstado:GetAttribute("SX" .. i))
                            local sz = tonumber(JefeEstado:GetAttribute("SZ" .. i))
                            if sx and sz then return Vector3.new(sx, floorY, sz), pModel or ("star_" .. i) end
                        elseif var == 4 then
                            -- Crystal Arachne: Egg Sacs
                            local arena = workspace:FindFirstChild("_JefeArena")
                            local sacos = arena and arena:FindFirstChild("Sacos")
                            local s = sacos and sacos:FindFirstChild("Saco" .. i)
                            if s and s:IsA("Model") then
                                local p = s:GetPivot().Position
                                return Vector3.new(p.X, floorY, p.Z), s
                            end
                            local p = JefeDefs.puntoEscudo(4, i)
                            if p then return Vector3.new(p.X, floorY, p.Z), pModel or ("saco_" .. i) end
                        else
                            -- Frost Serpent (var 2) & Inferno Golem (var 3): Pilar kristal emas
                            local p = JefeDefs.puntoEscudo(var, i)
                            if p then return Vector3.new(p.X, floorY, p.Z), pModel or ("pillar_" .. i) end
                        end

                        return nil, nil
                    end

                    local function getBossActiveTarget()
                        local var = tonumber(JefeEstado:GetAttribute("Variante")) or 1
                        local now = workspace:GetServerTimeNow()
                        local escudoCount = tonumber(JefeEstado:GetAttribute("Escudo")) or 0
                        local ventana = JefeEstado:GetAttribute("Ventana")
                        local jfx = workspace:FindFirstChild("_JefeFX")
                        local floorY = bCenter.Y + 3.4
                        local nEscudo = tonumber(JefeEstado:GetAttribute("NEscudo")) or JefeDefs.nEscudo(var)

                        -- TAHAP 1: KUMPULKAN SEMUA PERISAI / KRISTAL AKTIF
                        local activeShields = {}
                        for i = 1, nEscudo do
                            local pVal = tonumber(JefeEstado:GetAttribute("P" .. i))
                            local pModel = jfx and jfx:FindFirstChild("JefeBlanco_p" .. i)
                            local isTagged = pModel and CS:HasTag(pModel, "Enemigo")

                            local isActive = false
                            if pVal ~= nil and pVal > 0 then
                                if var == 5 then
                                    local st = tonumber(JefeEstado:GetAttribute("ST" .. i)) or 0
                                    local sf = tonumber(JefeEstado:GetAttribute("SF" .. i)) or 0
                                    if now >= st and now < sf then isActive = true end
                                else
                                    isActive = true
                                end
                            elseif isTagged then
                                isActive = true
                            elseif (pVal == nil or pVal > 0) and escudoCount > 0 and pModel then
                                isActive = true
                            end

                            if isActive then
                                local pos, obj = getShieldPos(var, i, now)
                                if pos then
                                    table.insert(activeShields, {pos = pos, obj = obj or pModel or ("shield_" .. i), index = i})
                                end
                            end
                        end

                        -- JIKA ADA PERISAI AKTIF: Hancurkan perisai terdekat lebih dulu!
                        if #activeShields > 0 then
                            local myPos = (LP.Character and LP.Character:GetPivot().Position) or bCenter
                            local bestPos, bestObj, bestDist = nil, nil, math.huge
                            for _, s in ipairs(activeShields) do
                                local d = (Vector3.new(s.pos.X, 0, s.pos.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
                                if d < bestDist then
                                    bestDist = d
                                    bestPos = s.pos
                                    bestObj = s.obj
                                end
                            end
                            return bestPos, bestObj
                        end

                        -- TAHAP 2: MINION MOBS (JefeMob_*)
                        if jfx then
                            for _, m in ipairs(jfx:GetChildren()) do
                                if m:IsA("Model") and (m.Name:sub(1, 8) == "JefeMob_" or m.Name:find("Caballero") or m.Name:find("Mob")) then
                                    local p = m:GetPivot().Position
                                    return Vector3.new(p.X, floorY, p.Z), m
                                end
                            end
                        end

                        -- TAHAP 3: SEMUA PERISAI & KROCO HANCUR -> SERANG BOSS UTAMA DI TENGAH!
                        return nil, "boss_center"
                    end

                    -- A. SERVER-SIDE HEAL PULSE (100% Absolute Invulnerability)
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if S.God and CurarR then
                        CurarR:FireServer()
                        if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
                    end

                    -- B. AUTO-DISSOLVE BOSS MINION MOBS (JefeMob_*) via JefeGolpe
                    local jfx = workspace:FindFirstChild("_JefeFX")
                    if jfx then
                        for _, m in ipairs(jfx:GetChildren()) do
                            if m:IsA("Model") and (m.Name:sub(1, 8) == "JefeMob_" or m.Name:find("Caballero") or m.Name:find("Mob")) then
                                local jg = m:FindFirstChild("JefeGolpe")
                                if jg and jg:IsA("BindableEvent") then
                                    pcall(function() jg:Fire(10) end)
                                end
                            end
                        end
                    end

                    -- C. DETEKSI TARGET PANAH / KROCO vs BOSS UTAMA
                    local arrowTargetPos, targetObj = getBossActiveTarget()

                    if arrowTargetPos then
                        -- TAHAP 1: ADA PERISAI/KROCO AKTIF (HANCURKAN PERISAI TERLEBIH DAHULU)
                        if typeof(targetObj) == "Instance" then
                            local jg = targetObj:FindFirstChild("JefeGolpe") or (targetObj.Parent and targetObj.Parent:FindFirstChild("JefeGolpe"))
                            if jg and jg:IsA("BindableEvent") then
                                pcall(function() jg:Fire(10) end)
                            end
                        end
                        if jfx then
                            for _, desc in ipairs(jfx:GetChildren()) do
                                if desc:IsA("Model") and desc.Name ~= "JefeBlanco_jefe" then
                                    local pPos = desc:GetPivot().Position
                                    if (pPos - arrowTargetPos).Magnitude < 18 then
                                        local jg = desc:FindFirstChild("JefeGolpe")
                                        if jg and jg:IsA("BindableEvent") then
                                            pcall(function() jg:Fire(10) end)
                                        end
                                    end
                                end
                            end
                        end

                        -- 1000 RPM ORBIT COMBAT: Menempel dan berputar mengelilingi target perisai/kroco
                        local floorY = bCenter.Y + 3.4
                        currentOrbitTarget = { pos = arrowTargetPos, radius = 3.5, floorY = floorY }
                    else
                        -- TAHAP 2: KROCO & PERISAI SUDAH MATI SEMUA -> SERANG BOSS UTAMA DI TENGAH!
                        if jfx then
                            local bjefe = jfx:FindFirstChild("JefeBlanco_jefe")
                            local jg = bjefe and bjefe:FindFirstChild("JefeGolpe")
                            if jg and jg:IsA("BindableEvent") then
                                pcall(function() jg:Fire(10) end)
                            end
                        end

                        -- 1000 RPM ORBIT COMBAT: Menempel dan berputar mengelilingi BOSS utama
                        local floorY = bCenter.Y + 3.4
                        currentOrbitTarget = { pos = bCenter, radius = 15.0, floorY = floorY }
                    end
                end
            end

            -- 5. DETEKSI SELESAI PERTARUNGAN BOSS (Boss mati / fase kembali ke espera/fin)
            if bossJoined and not enJefe and (fase == "espera" or fase == "fin") then
                bossJoined = false
                currentOrbitTarget = nil
                notify("Auto Boss", "Boss " .. bossName .. " DEFEATED! Waiting for exit...")
                task.wait(2.5) -- Beri waktu server memindahkan player kembali ke lobby

                -- SELALU KEMBALIKAN KE WORLD TERTINGGI (WORLD MAX) SECARA OTORITATIF SERVER / TRAINING ZONE
                returnToHighestWorld()

                -- Restore farm yang aktif sebelum diambil alih
                if savedFarmState then
                    if savedFarmState.Stage then
                        setToggleSafe("AutoStage", true)
                        notify("Auto Boss", "Resuming Auto Stage...")
                    elseif savedFarmState.Halloween then
                        setToggleSafe("AutoHalloween", true)
                        notify("Auto Boss", "Resuming Auto Halloween...")
                    elseif savedFarmState.Zone then
                        setToggleSafe("AutoZone", true)
                        notify("Auto Boss", "Resuming Auto Zone...")
                    elseif savedFarmState.Farm then
                        setToggleSafe("AutoFarm", true)
                        notify("Auto Boss", "Resuming Auto Farm...")
                    end
                    savedFarmState = nil
                elseif S.AutoZone then
                    returnToHighestWorld()
                end
            end
        end
    end
end)

-- ============================================================
-- HELPER: TARGET PORTAL HALLOWEEN EVENT
-- ============================================================
local function getHalloweenPortalTarget()
    -- 1. Cek apakah model portal sudah dimuat di workspace (HalloweenEvent)
    local hwEvent = workspace:FindFirstChild("HalloweenEvent")
    if hwEvent then
        for _, c in ipairs(hwEvent:GetChildren()) do
            if c.Name:find("HalloweenPortal") or c.Name:find("Portal") then
                local ent = c:FindFirstChild("Entrada", true)
                if ent and ent:IsA("BasePart") then
                    return ent.Position, ent
                end
                local p = c:FindFirstChildWhichIsA("BasePart")
                if p then return p.Position, p end
            end
        end
    end

    -- 2. Koordinat presisi: Langsung ke gerbang HalloweenWorld atau Portal World 1 Lobby
    local hwWorld = workspace:FindFirstChild("HalloweenWorld")
    if hwWorld and hwWorld:GetAttribute("Centro") then
        local hwEntrada = (JefeHWDefs and JefeHWDefs.ENTRADA) or Vector3.new(-1301, 4.3, -1810)
        return hwEntrada + Vector3.new(0, 0.5, 0), nil
    end
    local fallbackPos = Vector3.new(-99.88, 10.58, -113.87)
    return fallbackPos, nil
end

-- ============================================================
-- 4.5 AUTO HALLOWEEN BOSS (PUMPKIN REAPER EVENT BOSS ENGINE)
-- ============================================================
local savedHWFarmState = nil
local hwBossJoined = false
local hwBossJoinAttemptTime = 0
local hwClickerActive = false
local hwDescLabel = nil

-- Ground Stabilization Platform: Creates/maintains an invisible solid collision platform directly beneath feet
local function updateHWPlatform(pos)
    local pf = workspace:FindFirstChild("ClientOP_HWPlatform")
    if not pf then
        pf = Instance.new("Part")
        pf.Name = "ClientOP_HWPlatform"
        pf.Size = Vector3.new(24, 1.2, 24)
        pf.Anchored = true
        pf.CanCollide = true
        pf.Transparency = 1
        pf.CastShadow = false
        pf.Parent = workspace
    end
    pf.CFrame = CFrame.new(pos.X, pos.Y - 2.6, pos.Z)
    return pf
end

local function cleanupHWPlatform()
    local pf = workspace:FindFirstChild("ClientOP_HWPlatform")
    if pf then pcall(function() pf:Destroy() end) end
end

-- Dynamic Red Floor Hazard Scanner (Zero-Damage Immunity against all telegraphed ground attacks)
local function isPositionInDanger(testPos)
    local jhwfx = workspace:FindFirstChild("_JefeHWFX")
    if not jhwfx then return false end
    local tx, tz = testPos.X, testPos.Z

    for _, part in ipairs(jhwfx:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "ClientOP_HWPlatform" and part.Transparency < 0.95 then
            local c = part.Color
            -- Red warning indicators: Kit.ROJO (255, 36, 48), Kit.ROJO_BORDE (255, 140, 140), Kit.SANGRE, Kit.FUEGO
            local isRed = (c.R > 0.7 and c.G < 0.4) or (c.R > 0.85 and c.G < 0.6 and c.B < 0.6)
            if isRed then
                local px, pz = part.Position.X, part.Position.Z
                local dx = tx - px
                local dz = tz - pz
                local d2 = dx * dx + dz * dz
                local isCyl = (part:IsA("Part") and part.Shape == Enum.PartType.Cylinder)

                if isCyl then
                    -- In Roblox Cylinders, diameter is max of Size.Y and Size.Z
                    local r = math.max(part.Size.Y, part.Size.Z) * 0.5 + 4.0
                    if d2 <= (r * r) then
                        return true
                    end
                else
                    -- Wedge / Box / Line parts
                    local halfExt = math.max(part.Size.X, part.Size.Z) * 0.5 + 4.0
                    if d2 <= (halfExt * halfExt) then
                        local lp = part.CFrame:PointToObjectSpace(testPos)
                        if math.abs(lp.X) <= (part.Size.X * 0.5 + 3.5) and math.abs(lp.Z) <= (part.Size.Z * 0.5 + 3.5) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while running do
        task.wait(0.2)
        if JefeHWEstado and JefeHWDefs then
            local fase = JefeHWEstado:GetAttribute("Fase") or "espera"
            local hasta = tonumber(JefeHWEstado:GetAttribute("Hasta")) or 0
            local now = workspace:GetServerTimeNow()
            local rem = hasta - now
            local enJefeHW = LP:GetAttribute("EnJefeHW") == true
            local inHW = LP:GetAttribute("EnHalloween") == true
            local inRondas = LP:GetAttribute("EnRondas") == true
            local isRegularBossActive = (LP:GetAttribute("EnJefe") == true) or bossJoined
            local bossName = tostring(JefeHWEstado:GetAttribute("Nombre") or "PUMPKIN REAPER")
            local hwCentro = JefeHWDefs.CENTRO or Vector3.new(-1250, 4.3, -1810)
            local hwEntrada = JefeHWDefs.ENTRADA or Vector3.new(-1301, 4.3, -1810)
            local hwFuera = JefeHWDefs.FUERA or Vector3.new(-1352, 4.6, -1810)

            -- Jangan interupsi jika sedang berada di dalam regular rotation boss fight (Mutual-Exclusion Guard)
            if S.AutoBossHW and not isRegularBossActive then

                -- 1. PRE-ENTRY COUNTDOWN TRANSITION (rem <= 22s pada fase espera)
                if not enJefeHW and fase == "espera" and rem <= 22 and rem > 0 then
                    -- Simpan state farm jika belum tersimpan
                    if not savedHWFarmState and (S.AutoStage or S.AutoHalloween or S.AutoFarm or S.AutoZone) then
                        savedHWFarmState = {
                            Stage = S.AutoStage,
                            Halloween = S.AutoHalloween,
                            Farm = S.AutoFarm,
                            Zone = S.AutoZone,
                        }
                        if S.AutoStage then setToggleSafe("AutoStage", false) end
                        if S.AutoHalloween then setToggleSafe("AutoHalloween", false) end
                        if S.AutoFarm then setToggleSafe("AutoFarm", false) end
                        if S.AutoZone then setToggleSafe("AutoZone", false) end
                        notify("Auto Boss HW", "Event Preparation: " .. bossName .. " (" .. math.ceil(rem) .. "s)...")
                    end

                    -- A. Jika di dalam Rondas, keluar ke area bebas Halloween
                    if inRondas and RondasR then
                        RondasR:FireServer("salir")
                        local t0 = os.clock()
                        while LP:GetAttribute("EnRondas") == true and (os.clock() - t0 < 2) do
                            task.wait(0.1)
                        end
                    end

                    -- B. Jika belum berada di HalloweenWorld, masuk melalui Portal
                    if not inHW then
                        local portalPos, entradaPart = getHalloweenPortalTarget()
                        teleportTo(portalPos)
                        if not entradaPart then
                            local hwEvent = workspace:FindFirstChild("HalloweenEvent")
                            if hwEvent then entradaPart = hwEvent:FindFirstChild("Entrada", true) end
                        end
                        local touchFn = firetouchinterest or (debug and debug.firetouchinterest)
                        local c = LP.Character
                        local root = c and c:FindFirstChild("HumanoidRootPart")
                        if entradaPart and root and touchFn then
                            touchFn(root, entradaPart, 0)
                            task.wait(0.04)
                            touchFn(root, entradaPart, 1)
                        elseif root then
                            root.AssemblyLinearVelocity = Vector3.new(0, 0, -4)
                        end
                        local t0 = os.clock()
                        while not LP:GetAttribute("EnHalloween") and (os.clock() - t0 < 3) do
                            task.wait(0.15)
                        end
                    else
                        -- Sudah di HalloweenWorld: posisikan standby tepat di depan gerbang boss (ENTRADA)
                        local c = LP.Character
                        local root = c and c:FindFirstChild("HumanoidRootPart")
                        if root and (root.Position - hwEntrada).Magnitude > 6 then
                            teleportTo(hwEntrada + Vector3.new(0, 0.5, 0), hwCentro)
                        end
                    end
                end

                -- 2. FASE GERBANG TERBUKA (fase == "abierta") -> MASUK LANGSUNG KE DALAM ARENA!
                if fase == "abierta" and not enJefeHW then
                    if not savedHWFarmState and (S.AutoStage or S.AutoHalloween or S.AutoFarm or S.AutoZone) then
                        savedHWFarmState = {
                            Stage = S.AutoStage,
                            Halloween = S.AutoHalloween,
                            Farm = S.AutoFarm,
                            Zone = S.AutoZone,
                        }
                        if S.AutoStage then setToggleSafe("AutoStage", false) end
                        if S.AutoHalloween then setToggleSafe("AutoHalloween", false) end
                        if S.AutoFarm then setToggleSafe("AutoFarm", false) end
                        if S.AutoZone then setToggleSafe("AutoZone", false) end
                    end

                    -- Pastikan di HalloweenWorld
                    if not inHW then
                        local portalPos, entradaPart = getHalloweenPortalTarget()
                        teleportTo(portalPos)
                        local touchFn = firetouchinterest or (debug and debug.firetouchinterest)
                        local c = LP.Character
                        local root = c and c:FindFirstChild("HumanoidRootPart")
                        if entradaPart and root and touchFn then
                            touchFn(root, entradaPart, 0)
                            task.wait(0.04)
                            touchFn(root, entradaPart, 1)
                        end
                        task.wait(1.0)
                    else
                        -- Teleport langsung ke dalam arena di dekat pusat arena (radius 20 stud dari CENTRO)
                        local insidePos = hwCentro + Vector3.new(-15, 0.5, 0)
                        local c = LP.Character
                        local root = c and c:FindFirstChild("HumanoidRootPart")
                        if root and (root.Position - insidePos).Magnitude > 5 then
                            teleportTo(insidePos, hwCentro)
                            notify("Auto Boss HW", "Gate Open! Entering " .. bossName .. " arena!")
                        end
                    end
                    hwBossJoined = true
                    hwBossJoinAttemptTime = os.clock()
                end

                -- 3. COMBAT ENGINE SAAT DI DALAM ARENA (enJefeHW == true ATAU fase == "pelea")
                if enJefeHW or (fase == "pelea" and inHW and (LP.Character and LP.Character:GetPivot().Position and (LP.Character:GetPivot().Position - hwCentro).Magnitude <= (JefeHWDefs.R_ARENA + 10))) then
                    hwBossJoined = true
                    local c = LP.Character
                    local root = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")

                    if root and hum then
                        -- A. Continuous Health & Anti-Ragdoll Lockdown (Prevents trips, ragdolls, and death)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                        if hum.Health < hum.MaxHealth then
                            hum.Health = hum.MaxHealth
                            if CurarR then CurarR:FireServer() end
                        end

                        -- B. Burst Auto-Clicker (50 CPS burst DPS)
                        if not hwClickerActive then
                            hwClickerActive = true
                            task.spawn(function()
                                while running and (LP:GetAttribute("EnJefeHW") == true or (JefeHWEstado:GetAttribute("Fase") == "pelea")) do
                                    if ClickR then ClickR:FireServer() end
                                    task.wait(0.02)
                                end
                                hwClickerActive = false
                            end)
                        end

                        -- C. Detect Boss, Minions, and Safe Cylinder in _JefeHWFX
                        local jhwfx = workspace:FindFirstChild("_JefeHWFX")
                        local bossTargetPos = hwCentro
                        local bossLook = Vector3.new(0, 0, 1)
                        local targetFound = false
                        local safeCylinderPos = nil

                        if jhwfx then
                            -- Detect Safe Cylinder (Kit.VERDE) for Tumbas room-wide wipe
                            for _, part in ipairs(jhwfx:GetChildren()) do
                                if part:IsA("BasePart") and part.Transparency < 0.95 then
                                    local col = part.Color
                                    -- Kit.VERDE: Color3.fromRGB(60, 235, 90) -> (0.235, 0.922, 0.353)
                                    if math.abs(col.R - 0.235) < 0.15 and col.G > 0.75 and math.abs(col.B - 0.353) < 0.15 then
                                        safeCylinderPos = part.Position
                                        pcall(function() LP:SetAttribute("EnZonaSegura", true) end)
                                        break
                                    end
                                end
                            end

                            -- Priority 1: Instant dissolve minion HWMob_*
                            for _, m in ipairs(jhwfx:GetChildren()) do
                                if m:IsA("Model") and m.Name:sub(1, 6) == "HWMob_" then
                                    local jg = m:FindFirstChild("JefeGolpe")
                                    if jg and jg:IsA("BindableEvent") then
                                        pcall(function() jg:Fire(10) end)
                                    end
                                    local pPos = m:GetPivot().Position
                                    bossTargetPos = Vector3.new(pPos.X, hwCentro.Y + 0.5, pPos.Z)
                                    targetFound = true
                                    break
                                end
                            end

                            -- Priority 2: Target main boss (JefeBlanco_hw)
                            if not targetFound then
                                local bjefe = jhwfx:FindFirstChild("JefeBlanco_hw")
                                if bjefe and bjefe:IsA("Model") then
                                    local jg = bjefe:FindFirstChild("JefeGolpe")
                                    if jg and jg:IsA("BindableEvent") then
                                        pcall(function() jg:Fire(10) end)
                                    end
                                    local pPivot = bjefe:GetPivot()
                                    bossTargetPos = Vector3.new(pPivot.Position.X, hwCentro.Y + 0.5, pPivot.Position.Z)
                                    local look = pPivot.LookVector
                                    local flatLook = Vector3.new(look.X, 0, look.Z)
                                    if flatLook.Magnitude > 0.1 then bossLook = flatLook.Unit end
                                    targetFound = true
                                end
                            end
                        end

                        -- Fallback from JefeHWDefs.posMov
                        if not targetFound and JefeHWDefs then
                            if typeof(JefeHWDefs.movDe) == "function" and typeof(JefeHWDefs.posMov) == "function" then
                                local mov = JefeHWDefs.movDe(JefeHWEstado:GetAttribute("Mov"))
                                if mov then
                                    local calcPos = JefeHWDefs.posMov(mov, workspace:GetServerTimeNow())
                                    if calcPos then
                                        bossTargetPos = Vector3.new(calcPos.X, hwCentro.Y + 0.5, calcPos.Z)
                                        bossLook = Vector3.new(math.cos(mov.yaw), 0, math.sin(mov.yaw)).Unit
                                    end
                                end
                            end
                        end

                        -- D. ZERO-DAMAGE DYNAMIC POSITIONING ENGINE
                        local hwFloorY = hwCentro.Y + 0.5
                        local targetPos = nil
                        local ventana = JefeHWEstado:GetAttribute("Ventana")

                        if safeCylinderPos then
                            -- 1. FASE TUMBAS: Stand directly inside the official green safe circle
                            targetPos = Vector3.new(safeCylinderPos.X, hwFloorY, safeCylinderPos.Z)
                        elseif ventana == "cielo" then
                            -- 2. FASE CIELO (Boss flies & meteor shower): Safe outer perimeter away from bombardment
                            local safeSky = hwCentro + Vector3.new(48.0, 0, 0)
                            if JefeHWDefs and typeof(JefeHWDefs.alCirculo) == "function" then
                                safeSky = JefeHWDefs.alCirculo(safeSky, 8)
                            end
                            targetPos = Vector3.new(safeSky.X, hwFloorY, safeSky.Z)
                        else
                            -- 3. FASE TEMPUR NORMAL (GROUND COMBAT):
                            -- Default stance: 21.0 studs directly BEHIND the boss
                            -- In 180Â° dead-zone for guadana (160Â° front), aliento (130Â° front), zarpazos (110Â° front), laser, raices, embestida
                            local baseRear = bossTargetPos - bossLook * 21.0
                            if JefeHWDefs and typeof(JefeHWDefs.alCirculo) == "function" then
                                baseRear = JefeHWDefs.alCirculo(baseRear, 6)
                            end
                            local rearPos = Vector3.new(baseRear.X, hwFloorY, baseRear.Z)

                            -- Check if this rear position is currently covered by any red telegraph (salto, barrido, calabazas, rayos, etc.)
                            if isPositionInDanger(rearPos) then
                                -- STEP BACK TO 34.0 STUDS (Outside Salto rOut=30 and Barrido r2b=30)
                                local retreat = bossTargetPos - bossLook * 34.0
                                if JefeHWDefs and typeof(JefeHWDefs.alCirculo) == "function" then
                                    retreat = JefeHWDefs.alCirculo(retreat, 4)
                                end
                                local retreatPos = Vector3.new(retreat.X, hwFloorY, retreat.Z)

                                if isPositionInDanger(retreatPos) then
                                    -- Secondary evasive sweep: search 8 perimeter points for clean ground
                                    local foundClean = false
                                    for ang = 0, 315, 45 do
                                        local rad = math.rad(ang)
                                        local cand = hwCentro + Vector3.new(math.cos(rad) * 44, 0, math.sin(rad) * 44)
                                        if JefeHWDefs and typeof(JefeHWDefs.alCirculo) == "function" then
                                            cand = JefeHWDefs.alCirculo(cand, 6)
                                        end
                                        cand = Vector3.new(cand.X, hwFloorY, cand.Z)
                                        if not isPositionInDanger(cand) then
                                            targetPos = cand
                                            foundClean = true
                                            break
                                        end
                                    end
                                    if not foundClean then targetPos = retreatPos end
                                else
                                    targetPos = retreatPos
                                end
                            else
                                targetPos = rearPos
                            end
                        end

                        -- E. APPLY TELEPORT & SOLID GROUND STABILIZATION (ZERO BOUNCE)
                        if targetPos then
                            if (root.Position - targetPos).Magnitude > 1.2 then
                                teleportTo(targetPos, bossTargetPos)
                            end
                            updateHWPlatform(targetPos)
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end

                -- 4. FASE FIN / SELESAI (Boss mati / kemenangan): TUNGGU DI DALAM ARENA SAMPAI SERVER BAGI REWARD PENUH!
                -- Server membutuhkan FIN_SEG = 8 detik di fase fin untuk drop hadiah kemenangan penuh
                if hwBossJoined and fase == "fin" then
                    local c = LP.Character
                    local root = c and c:FindFirstChild("HumanoidRootPart")
                    if root then
                        local hwFloorY = hwCentro.Y + 0.5
                        local safePos = Vector3.new(hwCentro.X, hwFloorY, hwCentro.Z)
                        if (root.Position - safePos).Magnitude > 2.0 then
                            teleportTo(safePos, hwCentro)
                        end
                        updateHWPlatform(safePos)
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end
                end

                -- 5. KELUAR ARENA HANYA SETELAH FASE KEMBALI KE "espera" DAN SUDAH TIDAK DI DALAM BOSS
                if hwBossJoined and (fase == "espera") and not enJefeHW then
                    hwBossJoined = false
                    cleanupHWPlatform()
                    notify("Auto Boss HW", "Event " .. bossName .. " DEFEATED! Full rewards secured. Restoring farm...")
                    task.wait(2.0)

                    -- Pindahkan ke luar arena jika masih di dalam
                    local c = LP.Character
                    local root = c and c:FindFirstChild("HumanoidRootPart")
                    if root and (root.Position - hwCentro).Magnitude < (JefeHWDefs.R_ARENA + 15) then
                        teleportTo(hwFuera)
                    end

                    -- Keluar dari Halloween dan SELALU kembali ke World tertinggi secara otoritatif server
                    local wasFarmingHW = savedHWFarmState and savedHWFarmState.Halloween
                    if not wasFarmingHW then
                        exitHalloweenToLobby()
                        task.wait(0.5)
                        returnToHighestWorld()
                    end

                    -- Pulihkan farm yang sebelumnya aktif
                    if savedHWFarmState then
                        if savedHWFarmState.Stage then
                            setToggleSafe("AutoStage", true)
                            notify("Auto Boss HW", "Resuming Auto Stage...")
                        elseif savedHWFarmState.Halloween then
                            setToggleSafe("AutoHalloween", true)
                            notify("Auto Boss HW", "Resuming Auto Halloween (Rounds)...")
                        elseif savedHWFarmState.Zone then
                            setToggleSafe("AutoZone", true)
                            notify("Auto Boss HW", "Resuming Auto Zone...")
                        elseif savedHWFarmState.Farm then
                            setToggleSafe("AutoFarm", true)
                            notify("Auto Boss HW", "Resuming Auto Farm...")
                        end
                        savedHWFarmState = nil
                    elseif S.AutoZone then
                        returnToHighestWorld()
                    end
                end
            end
        end
    end
end)

-- 5. AUTO HALLOWEEN (LOOP RONDAS OTOMATIS)

local RONDAS_ENTRADA = Vector3.new(-1400, 10.5, -1895)
local RONDAS_CENTRO = Vector3.new(-1400, 9.0, -1972)

task.spawn(function()
    while running do
        task.wait(0.25)
        if S.AutoHalloween and not S.AutoStage and not (LP:GetAttribute("EnJefe") == true) and not (LP:GetAttribute("EnJefeHW") == true) and not hwBossJoined then
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if root then
                local inRondas = LP:GetAttribute("EnRondas") == true
                local inHW = LP:GetAttribute("EnHalloween") == true

                if not inRondas then
                    if not inHW then
                        -- Di Lobby: Teleport ke Portal Halloween Event World saat ini
                        local portalPos, entradaPart = getHalloweenPortalTarget()
                        teleportTo(portalPos)

                        -- Cari part Entrada jika sebelumnya belum streamed-in
                        if not entradaPart then
                            local hwEvent = workspace:FindFirstChild("HalloweenEvent")
                            if hwEvent then
                                entradaPart = hwEvent:FindFirstChild("Entrada", true)
                            end
                        end

                        -- Trigger sentuhan portal via firetouchinterest agar server langsung teleportasi
                        local touchFn = firetouchinterest or (debug and debug.firetouchinterest)
                        if entradaPart and touchFn then
                            touchFn(root, entradaPart, 0)
                            task.wait(0.05)
                            touchFn(root, entradaPart, 1)
                        else
                            -- Fallback fisika: dorongan gerak mikro agar physics solver memicu Touched
                            root.AssemblyLinearVelocity = Vector3.new(0, 0, -4)
                        end
                        task.wait(1.5)
                    else
                        -- Di Halloween World: Teleport ke Pintu Masuk Rondas
                        local dist = (root.Position - RONDAS_ENTRADA).Magnitude
                        if dist > 6 then
                            teleportTo(RONDAS_ENTRADA)
                            task.wait(1.5)
                        end
                    end
                else
                    -- Sedang di dalam Arena Rondas
                    local list = allMobs()
                    if #list == 0 then
                        -- Menunggu gelombang spawn: posisikan aman di tengah arena
                        local dist = (root.Position - RONDAS_CENTRO).Magnitude
                        if dist > 20 then
                            teleportTo(RONDAS_CENTRO)
                        end
                    else
                        -- Ada musuh di arena
                        local elapsed = os.clock() - roundStartTime
                        if elapsed >= CFG.SafeDelay then
                            -- Safe delay tercapai: dekati musuh terdekat agar serangan AutoClick/senjata mengenainya
                            local best, bd = nil, math.huge
                            for _, x in ipairs(list) do
                                local d = (x.r.Position - root.Position).Magnitude
                                if d < bd then best, bd = x, d end
                            end
                            if best then
                                local mobPos = best.r.Position
                                local offsetDir = (root.Position - mobPos)
                                local flatDir = Vector3.new(offsetDir.X, 0, offsetDir.Z)
                                if flatDir.Magnitude < 0.1 then flatDir = Vector3.new(0, 0, 1) end
                                flatDir = flatDir.Unit * 3.5
                                local targetPos = mobPos + flatDir + Vector3.new(0, 0.5, 0)
                                teleportTo(targetPos, mobPos)
                            end
                        else
                            -- Masa countdown / safe delay: tetap berada di tengah arena
                            local dist = (root.Position - RONDAS_CENTRO).Magnitude
                            if dist > 25 then
                                teleportTo(RONDAS_CENTRO)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 6. AUTO CLICK / AUTO ZONE / AUTO REBIRTH (50 CPS Flat Cadence)
task.spawn(function()
    while running do
        task.wait(CFG.ClickInterval or 0.02)
        if S.AutoClick then ClickR:FireServer() end
    end
end)

task.spawn(function()
    while running do
        task.wait(1.5)
        if S.AutoZone and not S.AutoStage and not S.AutoHalloween and not (LP:GetAttribute("EnJefe") == true) and not (LP:GetAttribute("EnJefeHW") == true) and not hwBossJoined and not bossJoined and LP:GetAttribute("EnHalloween") ~= true then
            local z = bestZone()
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if z and root and LP:GetAttribute("Zona") ~= z.nombre then
                local centerPos, lookPos = getZoneCenter(z)
                if centerPos then
                    if lookPos then
                        teleportTo(centerPos, lookPos)
                    else
                        teleportTo(centerPos)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while running do
        task.wait(1)
        if S.AutoRebirth and RebirthR then
            local nivel = tonumber(LP:GetAttribute("Nivel")) or 0
            local meta = tonumber(LP:GetAttribute("RebirthMeta")) or math.huge
            if nivel >= meta then RebirthR:FireServer() task.wait(3) end
        end
    end
end)

-- ============================================================
-- 6.5 AUTO CLAIM ENGINE (Comprehensive Autonomous Reward Claimer)
-- ============================================================
local lastQuestSync = 0
local questState = nil

if MisionesR then
    on(MisionesR.OnClientEvent, function(action, data)
        if action == "estado" and type(data) == "table" then
            questState = data
        elseif action == "prog" and type(data) == "table" and questState then
            for side, list in pairs(data) do
                for k, pVal in pairs(list) do
                    local q = questState[side] and questState[side][tonumber(k)]
                    if q then
                        q.p = pVal
                    end
                end
            end
        end
    end)
end

local function claimAllRewards()
    local claimedCount = 0

    -- 1. Daily Login Rewards
    if DailyR and LP:GetAttribute("DailyListo") == true then
        pcall(function()
            DailyR:FireServer()
            claimedCount = claimedCount + 1
        end)
    end

    -- 2. Playtime Gifts (Every 5m, 15m, 60m)
    if RegalosR and RegalosTiempoMod and RegalosTiempoMod.estado then
        for i = 1, 3 do
            pcall(function()
                local listo, _, quedan = RegalosTiempoMod.estado(LP, i)
                local qAttr = LP:GetAttribute("Regalo" .. i .. "Quedan")
                local hasUses = (qAttr == nil or (quedan and quedan > 0))
                if listo and hasUses then
                    RegalosR:FireServer(i)
                    claimedCount = claimedCount + 1
                    task.wait(0.2)
                end
            end)
        end
    end

    -- 3. Halloween Event Pass Tiers
    if HalloweenPassR then
        pcall(function()
            HalloweenPassR:FireServer("reclamarTodo")
            claimedCount = claimedCount + 1
        end)
        if HalloweenPassMod and HalloweenPassMod.nivelDe and HalloweenPassMod.reclamado then
            pcall(function()
                local dulces = tonumber(LP:GetAttribute("PaseDulces")) or 0
                local reclamados = tostring(LP:GetAttribute("PaseReclamados") or "")
                local lvl = HalloweenPassMod.nivelDe(dulces)
                local isPrem = LP:GetAttribute("PasePremium") == true
                for i = 1, lvl do
                    if not HalloweenPassMod.reclamado(reclamados, "g", i) then
                        HalloweenPassR:FireServer("reclamar", "g", i)
                        claimedCount = claimedCount + 1
                        task.wait(0.1)
                    end
                    if isPrem and not HalloweenPassMod.reclamado(reclamados, "p", i) then
                        HalloweenPassR:FireServer("reclamar", "p", i)
                        claimedCount = claimedCount + 1
                        task.wait(0.1)
                    end
                end
            end)
        end
    end

    -- 4. Daily & Weekly Quests
    if MisionesR then
        pcall(function()
            local now = os.time()
            if not questState or (now - lastQuestSync) > 15 then
                MisionesR:FireServer("pedir")
                lastQuestSync = now
                task.wait(0.4)
            end

            if questState then
                local allDailyDone = true
                if questState.d then
                    for i, q in ipairs(questState.d) do
                        if not q.c then
                            if (tonumber(q.p) or 0) >= (tonumber(q.meta) or math.huge) then
                                MisionesR:FireServer("reclamar", "d", i)
                                q.c = true
                                claimedCount = claimedCount + 1
                                task.wait(0.15)
                            else
                                allDailyDone = false
                            end
                        end
                    end
                end

                if questState.s then
                    for i, q in ipairs(questState.s) do
                        if not q.c and (tonumber(q.p) or 0) >= (tonumber(q.meta) or math.huge) then
                            MisionesR:FireServer("reclamar", "s", i)
                            q.c = true
                            claimedCount = claimedCount + 1
                            task.wait(0.15)
                        end
                    end
                end

                if allDailyDone and not questState.bonusCobrado then
                    MisionesR:FireServer("reclamar", "b", nil)
                    questState.bonusCobrado = true
                    claimedCount = claimedCount + 1
                end
            end
        end)
    end

    -- 5. Offline Accumulated Rewards
    if OfflineR and (tonumber(LP:GetAttribute("OfflinePendiente")) or 0) > 0 then
        pcall(function()
            OfflineR:FireServer("reclamar")
            claimedCount = claimedCount + 1
        end)
    end

    -- 6. Free Group / Like Gift Chest
    if RegaloR and LP:GetAttribute("RegaloReclamado") ~= true then
        pcall(function()
            if LP:GetAttribute("InGroup") ~= true then
                RegaloR:FireServer("check")
            end
            RegaloR:FireServer("reclamar")
            claimedCount = claimedCount + 1
        end)
    end

    -- 7. Session / Salida Gift
    if RegaloSalidaR then
        pcall(function()
            RegaloSalidaR:FireServer("reclamar")
        end)
    end

    return claimedCount
end

-- ============================================================
-- AUTO EGG CRACKING GUARDIAN (Auto-taps egg sessions until broken)
-- ============================================================
local function handleEggCracking()
    local eggUI = LP.PlayerGui:FindFirstChild("EggWindowUI")
    if not eggUI then return end

    local eggPreview = eggUI:FindFirstChild("EggPreview")
    local multiEggs = eggUI:FindFirstChild("MultiEggs")

    -- 1. Single Egg Tap
    if eggPreview and eggPreview.Visible then
        if getconnections then
            for _, conn in ipairs(getconnections(eggPreview.MouseButton1Click)) do
                if conn.Function then pcall(conn.Function) elseif conn.Fire then pcall(function() conn:Fire() end) end
            end
        end
        if firesignal then
            pcall(function() firesignal(eggPreview.MouseButton1Click) end)
            pcall(function() firesignal(eggPreview.Activated) end)
        end
    end

    -- 2. Multi Eggs Tap
    if multiEggs and multiEggs.Visible then
        if getconnections then
            for _, conn in ipairs(getconnections(multiEggs.MouseButton1Click)) do
                if conn.Function then pcall(conn.Function) elseif conn.Fire then pcall(function() conn:Fire() end) end
            end
        end
        if firesignal then
            pcall(function() firesignal(multiEggs.MouseButton1Click) end)
            pcall(function() firesignal(multiEggs.Activated) end)
        end
    end

    -- 3. Dismiss Reveal Modal if egg cracked and waiting for tap
    if LP:GetAttribute("EggModalOpen") == true then
        if (not eggPreview or not eggPreview.Visible) and (not multiEggs or not multiEggs.Visible) then
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                if VIM then
                    VIM:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    task.wait(0.04)
                    VIM:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
            end)
        end
    end
end

-- Fast egg-tapping daemon (80ms loop whenever EggModalOpen is detected)
task.spawn(function()
    while running do
        task.wait(0.08)
        if S.AutoClaim and LP:GetAttribute("EggModalOpen") == true then
            pcall(handleEggCracking)
        end
    end
end)

-- ============================================================
-- PROMO CODE REDEEMER ENGINE
-- ============================================================
local PROMO_CODES = {
    "THANKYOU",
    "14KCCU",
    "WORLD5",
    "LEVELING",
    "HALLOWEEN",
    "WORLD6",
    "20KCCU",
    "AUTUMN",
    "50KLIKES",
    "BOSS",
    "WORLD4",
    "7KCCU",
    "RELEASE",
    "ASSASSIN",
}

local function redeemAllCodes()
    if not CodigoCanjearR then
        warn("[ClientOP] Codigo_Canjear remote not found!")
        return 0, 0
    end

    local redeemedCount = 0
    local skippedCount = 0

    for _, code in ipairs(PROMO_CODES) do
        local ok, success, extra = pcall(function()
            return CodigoCanjearR:InvokeServer(code)
        end)

        if ok and success == true then
            redeemedCount = redeemedCount + 1
            notify("Code Redeemed", "Claimed code: " .. code)
        else
            skippedCount = skippedCount + 1
        end

        task.wait(1.6) -- Respect server debounce to prevent 'WAIT A MOMENT'
    end

    return redeemedCount, skippedCount
end

task.spawn(function()
    while running do
        task.wait(4.0)
        if S.AutoClaim then
            pcall(claimAllRewards)
        end
    end
end)

-- 7. AUTO STAGE & AUTO WORLD PROGRESSION ENGINE (Direct Mob Spawn Blitz Sequence)
local function getStageCoords(worldId, stageNum)
    local def = Mundos.get(worldId)
    local first = def and def.primero or 1
    local k = stageNum - first
    local zBase = (worldId - 1) * Mundos.DZ - 160.0
    local floorPos = Vector3.new(59.2 + k * 100, 8.4, zBase)
    local tunelPos = Vector3.new(106.7 + k * 100, 8.4, zBase)
    local isVIP = (S.StageCheckpoint == "VIP")
    local wpZ = zBase + (isVIP and -19.17 or 15.75)
    local wpPos = Vector3.new(107.02 + k * 100, 8.4, wpZ)
    return floorPos, tunelPos, wpPos
end

-- (getLobbySpawnPos dan getLobbyDoorPos telah didefinisikan secara global/upvalue di atas)

local function claimWinPad(curWorld, s)
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local isVIP = (S.StageCheckpoint == "VIP")
    local targetPadName = isVIP and ("Stage" .. s .. "_x2WinPad") or ("Stage" .. s .. "_WinPad")

    -- 1. Prediksi koordinat presisi WinPad dan teleport karakter ke sana untuk memicu StreamingEnabled
    local _, _, wpPos = getStageCoords(curWorld, s)
    teleportTo(wpPos)
    root.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
    task.wait(CFG.FlashMode and 0.04 or 0.15)

    -- 2. Cari Tunel dan WinPad yang sekarang sudah di-stream in
    local tunelModel = workspace:FindFirstChild("Tunel" .. s, true)
    local wpFolder = tunelModel and tunelModel:FindFirstChild("WinPads", true)

    if not wpFolder then
        local t0 = os.clock()
        while not wpFolder and (os.clock() - t0 < 1.5) do
            task.wait(0.03)
            tunelModel = workspace:FindFirstChild("Tunel" .. s, true)
            wpFolder = tunelModel and tunelModel:FindFirstChild("WinPads", true)
        end
    end

    local padModel = nil
    if wpFolder then
        if isVIP then
            padModel = wpFolder:FindFirstChild(targetPadName) or wpFolder:FindFirstChild("Stage" .. s .. "_WinPad") or wpFolder:FindFirstChildWhichIsA("Model")
        else
            -- Free Player: prioritaskan pad normal (kuning / kanan) tanpa x2
            padModel = wpFolder:FindFirstChild(targetPadName)
            if not padModel then
                for _, m in ipairs(wpFolder:GetChildren()) do
                    if m:IsA("Model") and not m.Name:lower():find("x2") then
                        padModel = m
                        break
                    end
                end
            end
            if not padModel then
                padModel = wpFolder:FindFirstChildWhichIsA("Model")
            end
        end
    end

    if not padModel then
        -- Streaming fallback: cari pad di seluruh workspace
        local t0 = os.clock()
        while not padModel and (os.clock() - t0 < 1.5) do
            task.wait(0.03)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:GetAttribute("Stage") == s and v:GetAttribute("WinValue") ~= nil then
                    local isX2 = v.Name:lower():find("x2") ~= nil
                    if (isVIP and isX2) or (not isVIP and not isX2) then
                        padModel = v
                        break
                    end
                end
            end
            if not padModel and (os.clock() - t0 > 1.0) then
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:GetAttribute("Stage") == s and v:GetAttribute("WinValue") ~= nil then
                        padModel = v
                        break
                    end
                end
            end
        end
    end

    if not padModel then return false end

    -- 3. Cari hitbox fisik dengan toleransi streaming
    local hitbox = padModel:FindFirstChild("WinPadHitbox") or padModel:FindFirstChild("Touch")
    if not hitbox then
        local t0 = os.clock()
        while not hitbox and (os.clock() - t0 < 1.5) do
            task.wait(0.03)
            hitbox = padModel:FindFirstChild("WinPadHitbox") or padModel:FindFirstChild("Touch")
        end
    end

    local targetPos = hitbox and (hitbox.Position + Vector3.new(0, 1.5, 0)) or (padModel:GetPivot().Position + Vector3.new(0, 1.5, 0))
    teleportTo(targetPos)
    root.AssemblyLinearVelocity = Vector3.new(0, -5, 0)

    if hitbox then
        local touchFn = firetouchinterest or (debug and debug.firetouchinterest)
        if touchFn then
            touchFn(root, hitbox, 0)
            task.wait(0.02)
            touchFn(root, hitbox, 1)
        end
    end

    pcall(function()
        RS.Arena.Remotos.WinPadToque:FireServer(padModel)
    end)
    task.wait(CFG.FlashMode and 0.05 or 0.25)
    return true
end

local function resetWorldRun(worldId)
    local worldDef = Mundos.get(worldId)
    if not worldDef then return end
    local spawnPos = getLobbySpawnPos(worldId)
    local doorPos = getLobbyDoorPos(worldId)

    -- 1. Reset client stage instances so superado = false
    pcall(function()
        local StageMod = require(RS.Arena.Cliente.Stage)
        for _, stg in pairs(StageMod.vivos) do
            pcall(function() stg:reiniciarRun() end)
        end
    end)

    -- 2. Teleport ke BEST ZONE di Lobby untuk validasi server, serap sisa loot, dan training strength
    local bz = bestZone()
    local bzPos, bzLook = getZoneCenter(bz)
    if not bzPos then
        teleportTo(spawnPos)
        task.wait(0.2)
        bzPos, bzLook = getZoneCenter(bz)
    end
    if bzPos then
        teleportTo(bzPos, bzLook)
        if ZonaEntroR and bz then ZonaEntroR:FireServer(bz.nombre) end
    else
        teleportTo(spawnPos)
    end

    task.wait(0.35)
    teleportTo(doorPos)
    task.wait(0.28)
end

-- ==============================================================
-- UNIFIED ADAPTIVE STAGE SWEEP & HARVEST ENGINE
-- ==============================================================
-- Sweeps sequentially from primero up to ultimo (or maximum validated).
-- Automatically cashes out at the highest validated WinPad (e.g. Stage 73 in World 5 -> +126 Trillion Wins).
-- Adapts automatically as player strength unlocks higher stages.
local function runStageFarm(curWorld, primero, ultimo)
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    disableSpawnLock()

    -- 1. Pre-run cleanup: Hapus orphaned mobs lokal dari siklus sebelumnya
    pcall(function()
        local mobsFolder = workspace:FindFirstChild("_MobsLocal")
        if mobsFolder then
            mobsFolder:ClearAllChildren()
        end
    end)

    local StageMod = nil
    pcall(function()
        StageMod = require(RS.Arena.Cliente.Stage)
        if StageMod and StageMod.vivos then
            for _, stg in pairs(StageMod.vivos) do
                pcall(function() stg:reiniciarRun() end)
            end
        end
    end)

    -- 2. Lobby handshake: Pastikan server & ArenaMobs mengonfirmasi enElLobby == true
    local spawnPos = getLobbySpawnPos(curWorld)
    local doorPos = getLobbyDoorPos(curWorld)

    teleportTo(spawnPos)
    task.wait(CFG.FlashMode and 0.30 or 0.40)

    -- 3. Pass Door: Melangkah keluar gerbang (X = 35) agar enElLobby == false
    teleportTo(doorPos)
    task.wait(CFG.FlashMode and 0.22 or 0.30)

    -- Tentukan target sweep: Jika AutoWorldPush aktif, sweep ke ultimo; jika nonaktif, farm primero saja
    local targetEndStage = S.AutoWorldPush and ultimo or primero
    local lastValidatedStage = nil

    -- 4. Sequential Stage Progression
    for s = primero, targetEndStage do
        if not running or not S.AutoStage or (LP:GetAttribute("EnJefe") == true) or (LP:GetAttribute("EnJefeHW") == true) then
            return false
        end

        local fPos, tPos, wpPos = getStageCoords(curWorld, s)

        -- Teleport ke titik stage floor
        teleportTo(fPos)
        local stageObj = StageMod and StageMod.vivos and StageMod.vivos[s]
        if stageObj and not stageObj.activo and not stageObj.superado then
            pcall(function() stageObj:arrancar(StageDefs) end)
        end
        task.wait(CFG.FlashMode and 0.05 or 0.08)

        -- Wipe mobs di stage ini
        local mobs = workspace:FindFirstChild("_MobsLocal") and workspace._MobsLocal:GetChildren() or {}
        local enem = CS:GetTagged("Enemigo")
        if #mobs > 0 or #enem > 0 then
            for _, m in ipairs(mobs) do
                local h = m:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    h.Health = 0
                    pcall(function() h:TakeDamage(h.MaxHealth) end)
                end
            end
            for _, m in ipairs(enem) do
                local h = m:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    h.Health = 0
                    pcall(function() h:TakeDamage(h.MaxHealth) end)
                end
            end
        end

        if ClickR and S.AutoClick then ClickR:FireServer() end
        if stageObj then pcall(function() stageObj:abrirBloqueo() end) end
        pcall(function() RS.Arena.Remotos.Limpio:FireServer(s, true) end)

        -- Vacuum loot drops
        local botinFolder = workspace:FindFirstChild("_BotinLocal")
        if botinFolder then
            for _, b in ipairs(botinFolder:GetChildren()) do
                if b:IsA("BasePart") then b.Position = root.Position end
            end
        end

        -- Injak tunnel floor untuk validasi keluar stage
        teleportTo(tPos)
        task.wait(CFG.FlashMode and 0.20 or 0.28)

        -- Verifikasi validasi otoritatif server via LimpioHasta
        local limp = tonumber(LP:GetAttribute("LimpioHasta")) or 0
        if limp >= s then
            lastValidatedStage = s
        else
            -- Short retry check (0.15s) jika paket jaringan server sedikit tertunda
            task.wait(0.15)
            limp = tonumber(LP:GetAttribute("LimpioHasta")) or 0
            if limp >= s then
                lastValidatedStage = s
            else
                -- Server menolak/membatasi validasi stage ini (misal batas HP/stats mob terlalu tinggi)
                -- Langsung hentikan sweep maju dan cash out di milestone tertinggi yang telah divalidasi!
                break
            end
        end
    end

    -- 5. Klaim Cash Out di WinPad Milestone Tertinggi yang Tervalidasi
    local cashOutStage = lastValidatedStage or primero
    claimWinPad(curWorld, cashOutStage)

    -- 6. Tunggu konfirmasi server Reinicio mendarat di Lobby
    local tWait = os.clock()
    while (os.clock() - tWait < 1.5) do
        if LP:GetAttribute("EnLobby") == true then break end
        task.wait(0.05)
    end

    -- 7. Periksa apakah MundoMax naik dan auto-teleport
    local maxWorld = tonumber(LP:GetAttribute("MundoMax")) or 1
    if maxWorld > curWorld then
        notify("Auto Stage", "UNLOCKED! World " .. maxWorld .. " Opened! Traveling...")
        MundoR:FireServer("viajar", maxWorld)
        task.wait(1.5)
        return true
    end

    -- 8. Singgah sejenak di Best Zone untuk training strength & server sync
    local restTime = CFG.FlashMode and (CFG.ZoneRestTime or 0.8) or 1.2
    if restTime > 0 then
        local bz = bestZone()
        local bzPos, bzLook = getZoneCenter(bz)
        if bzPos then
            teleportTo(bzPos, bzLook)
            if ZonaEntroR and bz then ZonaEntroR:FireServer(bz.nombre) end
            local tZ = os.clock()
            while (os.clock() - tZ < restTime) do
                if ClickR and S.AutoClick then ClickR:FireServer() end
                task.wait(0.02)
            end
        else
            task.wait(restTime)
        end
    end

    return true
end

-- SCHEDULER: UNIFIED CONTINUOUS STAGE HARVEST LOOP
task.spawn(function()
    while running do
        task.wait(CFG.FlashMode and 0.02 or 0.1)
        if S.AutoStage and not (LP:GetAttribute("EnJefe") == true) and not (LP:GetAttribute("EnJefeHW") == true) then
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if root then
                local maxWorld = tonumber(LP:GetAttribute("MundoMax")) or 1
                local curWorld = tonumber(LP:GetAttribute("Mundo")) or 1
                if curWorld < maxWorld then
                    notify("Auto Stage", "Advancing to highest world: World " .. maxWorld)
                    local spawnPos = getLobbySpawnPos(maxWorld)
                    teleportTo(spawnPos)
                    task.wait(0.5)
                    MundoR:FireServer("viajar", maxWorld)
                    task.wait(1.0)
                    curWorld = tonumber(LP:GetAttribute("Mundo")) or maxWorld
                end

                local worldDef = Mundos.get(curWorld)
                if worldDef then
                    runStageFarm(curWorld, worldDef.primero, worldDef.ultimo)
                end
            end
        end
    end
end)

-- 8. SPEED / NOCLIP / ANTI-TUMBLE GYROSCOPE & 1000 RPM ORBIT COMBAT RUNNER
on(RunService.Heartbeat, function()
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if S.Speed and h then
        h.WalkSpeed = math.max(h.WalkSpeed, CFG.WalkSpeed)
    end

    -- 1000 RPM HIGH-SPEED ORBIT COMBAT ENGINE
    if currentOrbitTarget and root then
        local inJefe = (LP:GetAttribute("EnJefe") == true)
        local inJefeHW = (LP:GetAttribute("EnJefeHW") == true) or (JefeHWEstado and JefeHWEstado:GetAttribute("Fase") == "pelea")
        if inJefe or inJefeHW then
            local tPos = currentOrbitTarget.pos
            local rad = currentOrbitTarget.radius or 3.5
            local fY = currentOrbitTarget.floorY or tPos.Y
            local angle = (os.clock() * OMEGA_1000RPM) % (2 * math.pi)
            local ox = math.cos(angle) * rad
            local oz = math.sin(angle) * rad
            local orbitPos = Vector3.new(tPos.X + ox, fY, tPos.Z + oz)
            local lookCenter = Vector3.new(tPos.X, fY, tPos.Z)

            root.CFrame = CFrame.lookAt(orbitPos, lookCenter)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero

            if currentOrbitTarget.isHW and updateHWPlatform then
                updateHWPlatform(orbitPos)
            end
        else
            currentOrbitTarget = nil
        end
    end
end)
on(RunService.Stepped, function()
    local c = LP.Character
    if not c then return end

    -- Disable collisions on limbs when NoClip, AutoHalloween, AutoStage, AutoFarm, or Boss Fight is active
    if S.NoClip or S.AutoHalloween or S.AutoFarm or S.AutoStage or (LP:GetAttribute("EnJefe") == true) or (LP:GetAttribute("EnJefeHW") == true) then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = false
            end
        end
    end

    -- Gyroscopic Stabilization & Anti-Ragdoll / Anti-Trip
    local root = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if root and hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

        local state = hum:GetState()
        if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.GettingUp then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end

        -- Anti-Tumble Gyroscope: ONLY check tilt on Pitch (X) and Roll (Z), NEVER on Yaw / Turning (Y)
        local rx, ry, rz = root.CFrame:ToOrientation()
        local tiltAngVel = Vector2.new(root.AssemblyAngularVelocity.X, root.AssemblyAngularVelocity.Z).Magnitude
        if math.abs(rx) > 0.45 or math.abs(rz) > 0.45 or tiltAngVel > 2.5 then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, ry, 0)
            -- Preserve turning yaw and horizontal running velocity!
            root.AssemblyAngularVelocity = Vector3.new(0, root.AssemblyAngularVelocity.Y, 0)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, math.min(root.AssemblyLinearVelocity.Y, 0), root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- 9. MODERN GUI ENGINE (WindUI Edition) ------------------------
local TweenService = game:GetService("TweenService")
local WindUI = nil
local success, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    warn("[ClientOP] Failed to load WindUI: " .. tostring(err))
    notify("ClientOP Error", "Failed to load WindUI from GitHub!")
    return
end

local Window = WindUI:CreateWindow({
    Title = "FLa ProjecT +1 Assasin Leveling",
    SubTitle = "v4.2 - WindUI Ultimate",
    TabWidth = 140,
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(520, 380),
    MaxSize = Vector2.new(850, 600),
    Resizable = true,
    Transparent = true,
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Enabled = false, -- Disable native WindUI pill to avoid colliding with game topbar
    },
})

-- TAB DEFINITIONS
local TabFarm = Window:Tab({
    Title = "Auto Farm",
    Icon = "swords",
})

local TabCombat = Window:Tab({
    Title = "Combat & Boss",
    Icon = "skull",
})

local TabPlayer = Window:Tab({
    Title = "Player & Misc",
    Icon = "user",
})

local TabConfig = Window:Tab({
    Title = "Config",
    Icon = "save",
})

local TabTelemetry = Window:Tab({
    Title = "Telemetry",
    Icon = "activity",
})

-- TOGGLE STORAGE FOR BIDIRECTIONAL SYNC (HOTKEY <-> UI)
local sliderWalkSpeed = nil
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "ClientOP_Config.json"

-- ==============================================================
-- FILE SYSTEM PERSISTENCE (SAVE / LOAD CONFIG)
-- ==============================================================
local function getFileFuncs()
    local wf = writefile or (getgenv and getgenv().writefile) or (debug and debug.writefile)
    local rf = readfile or (getgenv and getgenv().readfile) or (debug and debug.readfile)
    local isf = isfile or (getgenv and getgenv().isfile) or (debug and debug.isfile)
    return wf, rf, isf
end

local function saveConfigToFile(fileName)
    fileName = (fileName and fileName ~= "") and fileName or CONFIG_FILE
    if not fileName:find("%.json$") then fileName = fileName .. ".json" end

    local wf = getFileFuncs()
    if not wf then
        notify("Config Error", "writefile not supported by executor")
        return false, "writefile not supported"
    end

    local data = {
        Version = "v4.6",
        SavedAt = os.date("%Y-%m-%d %H:%M:%S"),
        Player = LP.Name,
        S = {},
        CFG = {
            WalkSpeed = CFG.WalkSpeed,
            MobHP = CFG.MobHP,
            FarmDist = CFG.FarmDist,
            SafeDelay = CFG.SafeDelay,
            PushCadence = CFG.PushCadence,
            FlashMode = CFG.FlashMode,
            ZoneRestTime = CFG.ZoneRestTime,
            StageCheckpoint = S.StageCheckpoint or "VIP",
        }
    }

    for k, v in pairs(S) do
        data.S[k] = v
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if not success or not encoded then
        notify("Config Error", "JSON encoding failed")
        return false, encoded
    end

    local writeOk, writeErr = pcall(function()
        wf(fileName, encoded)
    end)

    if not writeOk then
        notify("Config Error", "Failed to write file: " .. tostring(writeErr))
        return false, writeErr
    end

    notify("Config Saved", "Settings saved to " .. fileName)
    return true, data
end

local function loadConfigFromFile(fileName)
    fileName = (fileName and fileName ~= "") and fileName or CONFIG_FILE
    if not fileName:find("%.json$") then fileName = fileName .. ".json" end

    local wf, rf, isf = getFileFuncs()
    if not rf then
        notify("Config Error", "readfile not supported by executor")
        return false, "readfile not supported"
    end

    if isf then
        local exists = false
        pcall(function() exists = isf(fileName) end)
        if not exists then
            notify("Config Not Found", "No config file: " .. fileName)
            return false, "file not found"
        end
    end

    local readOk, raw = pcall(function()
        return rf(fileName)
    end)

    if not readOk or not raw or raw == "" then
        notify("Config Error", "Failed to read file: " .. tostring(raw))
        return false, raw
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not decodeOk or typeof(decoded) ~= "table" then
        notify("Config Error", "Invalid JSON format in " .. fileName)
        return false, decoded
    end

    -- 1. Apply CFG options
    if decoded.CFG and typeof(decoded.CFG) == "table" then
        for k, v in pairs(decoded.CFG) do
            if CFG[k] ~= nil and typeof(v) == typeof(CFG[k]) then
                CFG[k] = v
            end
        end
        if decoded.CFG.StageCheckpoint and updateCheckpointUI then
            pcall(function() updateCheckpointUI(decoded.CFG.StageCheckpoint) end)
        end
        local sObj = sliderWalkSpeed
        if sObj and CFG.WalkSpeed then
            if typeof(sObj.Set) == "function" then
                pcall(function() sObj:Set(CFG.WalkSpeed) end)
            elseif typeof(sObj.SetValue) == "function" then
                pcall(function() sObj:SetValue(CFG.WalkSpeed) end)
            end
        end
    end

    -- 2. Apply S toggles and sync UI elements
    local count = 0
    if decoded.S and typeof(decoded.S) == "table" then
        for k, v in pairs(decoded.S) do
            if S[k] ~= nil and typeof(v) == "boolean" then
                setToggleSafe(k, v)
                count = count + 1
            end
        end
    end

    local timeStr = decoded.SavedAt or "earlier"
    notify("Config Loaded", "Loaded " .. count .. " settings (" .. timeStr .. ")")
    return true, decoded
end

-- ==============================================================
-- TAB 1: AUTO FARM
-- ==============================================================
TabFarm:Section({ Title = "Stages & Progression" })

local tAutoStage = TabFarm:Toggle({
    Title = "Auto Stage (Instant Blitz)",
    Desc = "Full blitz stage loop + auto world push & flash speed [T]",
    Value = S.AutoStage,
    Callback = function(v)
        setToggleSafe("AutoStage", v)
        notify("Auto Stage", v and "ENABLED (Blitz Mode Active)" or "DISABLED")
    end,
})
registerToggle("AutoStage", tAutoStage)

local pCheckpoint = TabFarm:Paragraph({
    Title = "Target Checkpoint",
    Desc = "Status: " .. ((S.StageCheckpoint == "VIP") and "ð£ VIP (Sebelah Kiri / Ungu)" or "ð¡ FREE PLAYER (Sebelah Kanan / Kuning)")
})

updateCheckpointUI = function(mode)
    S.StageCheckpoint = mode
    CFG.StageCheckpoint = mode
    local isV = (mode == "VIP")
    if pCheckpoint and typeof(pCheckpoint.SetDesc) == "function" then
        pcall(function()
            pCheckpoint:SetDesc("Status: " .. (isV and "ð£ VIP (Sebelah Kiri / Ungu)" or "ð¡ FREE PLAYER (Sebelah Kanan / Kuning)"))
        end)
    end
    notify("Checkpoint", "Mode: " .. (isV and "VIP (Ungu / Kiri)" or "FREE PLAYER (Kuning / Kanan)"))
end

local hsCheckpoint = TabFarm:HStack()
hsCheckpoint:Button({
    Title = "ð£ VIP (Kiri)",
    Desc = "Pad ungu kiri (x2/x3)",
    Callback = function()
        updateCheckpointUI("VIP")
    end,
})
hsCheckpoint:Button({
    Title = "ð¡ FREE PLAYER (Kanan)",
    Desc = "Pad kuning kanan",
    Callback = function()
        updateCheckpointUI("FREE")
    end,
})

TabFarm:Section({ Title = "Standard Combat Farm" })

local tAutoFarm = TabFarm:Toggle({
    Title = "Auto Farm Normal",
    Desc = "Continuous teleport to nearest alive mob [F]",
    Value = S.AutoFarm,
    Callback = function(v)
        S.AutoFarm = v
        notify("Auto Farm", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoFarm", tAutoFarm)

local tAutoHW = TabFarm:Toggle({
    Title = "Auto Halloween (Rounds)",
    Desc = "Automated Halloween Waves & Rondas farming [H]",
    Value = S.AutoHalloween,
    Callback = function(v)
        S.AutoHalloween = v
        notify("Auto Halloween", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoHalloween", tAutoHW)

-- ==============================================================
-- TAB 2: COMBAT & BOSS
-- ==============================================================
TabCombat:Section({ Title = "Boss Takeovers" })

local regBossParagraph = TabCombat:Paragraph({
    Title = "Rotation: Checking...",
    Desc = "Waiting for game boss status...",
    Image = "swords",
})

local tAutoBoss = TabCombat:Toggle({
    Title = "Auto Boss Fight",
    Desc = "Auto takeover rotation boss fights (Void/Fallen/etc) [B]",
    Value = S.AutoBoss,
    Callback = function(v)
        S.AutoBoss = v
        notify("Auto Boss", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoBoss", tAutoBoss)

local hwBossParagraph = TabCombat:Paragraph({
    Title = "Event: Checking...",
    Desc = "Waiting for Halloween event status...",
    Image = "flame",
})

local tAutoBossHW = TabCombat:Toggle({
    Title = "Auto Boss Halloween (Event)",
    Desc = "Auto teleport to Pumpkin Reaper event boss when open [J]",
    Value = S.AutoBossHW,
    Callback = function(v)
        S.AutoBossHW = v
        notify("Auto Boss HW", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoBossHW", tAutoBossHW)

TabCombat:Section({ Title = "Combat Mechanics" })

local tGod = TabCombat:Toggle({
    Title = "God Mode (Universal)",
    Desc = "Immunity to mob damage via namecall detour [G]",
    Value = S.God,
    Callback = function(v)
        S.God = v
        notify("God Mode", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("God", tGod)

local tFastKill = TabCombat:Toggle({
    Title = "Fast Kill",
    Desc = "Instant elimination of local mobs [K]",
    Value = S.FastKill,
    Callback = function(v)
        S.FastKill = v
        notify("Fast Kill", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("FastKill", tFastKill)

-- ==============================================================
-- TAB 3: PLAYER & MISC
-- ==============================================================
TabPlayer:Section({ Title = "Stat Training" })

local tAutoClick = TabPlayer:Toggle({
    Title = "Auto Click",
    Desc = "Exploit Click remote (50 CPS / 20ms cadence) to gain Strength [C]",
    Value = S.AutoClick,
    Callback = function(v)
        S.AutoClick = v
        notify("Auto Click", v and "ENABLED (50 CPS)" or "DISABLED")
    end,
})
registerToggle("AutoClick", tAutoClick)

local tAutoZone = TabPlayer:Toggle({
    Title = "Auto Best Zone",
    Desc = "Teleport and idle at highest unlocked training zone [Z]",
    Value = S.AutoZone,
    Callback = function(v)
        S.AutoZone = v
        notify("Auto Zone", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoZone", tAutoZone)

local tAutoRebirth = TabPlayer:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirth when level requirement is met [R]",
    Value = S.AutoRebirth,
    Callback = function(v)
        S.AutoRebirth = v
        notify("Auto Rebirth", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoRebirth", tAutoRebirth)

TabPlayer:Section({ Title = "Reward Claiming" })

local tAutoClaim = TabPlayer:Toggle({
    Title = "Auto Claim Rewards",
    Desc = "Auto-claim Gifts, Pass, Quests & Auto-Tap Eggs [O]",
    Value = S.AutoClaim,
    Callback = function(v)
        S.AutoClaim = v
        notify("Auto Claim", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AutoClaim", tAutoClaim)

TabPlayer:Button({
    Title = "Claim All Rewards Now",
    Desc = "Instantly force-claim all pending gifts, pass, quests & offline",
    Callback = function()
        local count = claimAllRewards and claimAllRewards() or 0
        notify("Claim Engine", "Reward claim sweep triggered!")
    end,
})

TabPlayer:Button({
    Title = "Redeem All Promo Codes",
    Desc = "Redeem all working game promo codes (THANKYOU, 14KCCU, etc)",
    Callback = function()
        task.spawn(function()
            notify("Code Redeemer", "Redeeming all promo codes...")
            if redeemAllCodes then
                local red, skp = redeemAllCodes()
                notify("Code Redeemer", string.format("Complete! %d redeemed, %d skipped", red, skp))
            end
        end)
    end,
})

TabPlayer:Section({ Title = "Movement & Utilities" })

local tNoClip = TabPlayer:Toggle({
    Title = "NoClip",
    Desc = "Pass through walls and collision barriers [N]",
    Value = S.NoClip,
    Callback = function(v)
        S.NoClip = v
        notify("NoClip", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("NoClip", tNoClip)

local tSpeed = TabPlayer:Toggle({
    Title = "Speed Boost",
    Desc = "Boost Humanoid walk speed [X]",
    Value = S.Speed,
    Callback = function(v)
        S.Speed = v
        notify("Speed Boost", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("Speed", tSpeed)

sliderWalkSpeed = TabPlayer:Slider({
    Title = "WalkSpeed Multiplier",
    Desc = "Adjust speed boost multiplier limit",
    Value = {
        Min = 60,
        Max = 300,
        Default = CFG.WalkSpeed,
    },
    Callback = function(val)
        CFG.WalkSpeed = val
    end,
})

local tAntiAFK = TabPlayer:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevent Roblox 20-minute idle disconnect [U]",
    Value = S.AntiAFK,
    Callback = function(v)
        S.AntiAFK = v
        notify("Anti-AFK", v and "ENABLED" or "DISABLED")
    end,
})
registerToggle("AntiAFK", tAntiAFK)

-- ==============================================================
-- TAB 4: CONFIGURATION & PROFILE MANAGER
-- ==============================================================
TabConfig:Section({ Title = "Profile Management" })

local currentConfigProfile = "ClientOP_Config.json"

local configStatusParagraph = TabConfig:Paragraph({
    Title = "Configuration Profile: " .. currentConfigProfile,
    Desc = "Default on execution: ALL OFF\nStatus: Clean / Manual session\nFile System: Ready",
    Image = "file-text",
})

TabConfig:Input({
    Title = "Config File Name",
    Desc = "Target configuration file name (.json)",
    Value = "ClientOP_Config.json",
    Callback = function(val)
        if val and val ~= "" then
            if not val:find("%.json$") then val = val .. ".json" end
            currentConfigProfile = val
            pcall(function()
                configStatusParagraph:SetTitle("Configuration Profile: " .. currentConfigProfile)
            end)
        end
    end,
})

TabConfig:Section({ Title = "Config Actions" })

TabConfig:Button({
    Title = "SAVE CONFIG",
    Desc = "Save all current toggles and slider settings to file",
    Icon = "save",
    Callback = function()
        local ok, data = saveConfigToFile(currentConfigProfile)
        if ok and configStatusParagraph then
            pcall(function()
                configStatusParagraph:SetDesc(string.format("Last Saved: %s\nProfile: %s\nStatus: Saved successfully!", os.date("%X"), currentConfigProfile))
            end)
        end
    end,
})

TabConfig:Button({
    Title = "LOAD CONFIG",
    Desc = "Load and apply saved configuration profile to all features",
    Icon = "download",
    Callback = function()
        local ok, data = loadConfigFromFile(currentConfigProfile)
        if ok and configStatusParagraph then
            pcall(function()
                configStatusParagraph:SetDesc(string.format("Last Loaded: %s\nProfile: %s\nSaved Timestamp: %s", os.date("%X"), currentConfigProfile, data.SavedAt or "N/A"))
            end)
        end
    end,
})

TabConfig:Button({
    Title = "RESET ALL (Turn Everything OFF)",
    Desc = "Immediately deactivate all active features to clean state",
    Icon = "rotate-ccw",
    Callback = function()
        for k, _ in pairs(S) do
            setToggleSafe(k, false)
        end
        notify("Config Reset", "All features turned OFF")
        if configStatusParagraph then
            pcall(function()
                configStatusParagraph:SetDesc(string.format("Last Action: Reset All OFF at %s\nStatus: All features disabled", os.date("%X")))
            end)
        end
    end,
})

-- ==============================================================
-- TAB 5: TELEMETRY & STATS
-- ==============================================================
TabTelemetry:Section({ Title = "Player Telemetry" })

local statsParagraph = TabTelemetry:Paragraph({
    Title = "Loading data...",
    Desc = "Fetching player attributes from server...",
    Image = "database",
})

TabTelemetry:Button({
    Title = "Teleport to Current World Spawn",
    Desc = "Return to current world safe spawn point",
    Callback = function()
        local curM = tonumber(LP:GetAttribute("Mundo")) or 1
        teleportTo(getLobbySpawnPos(curM))
        notify("Teleport", "Returned to World " .. curM .. " Spawn")
    end,
})

-- ==============================================================
-- FLOATING TOGGLE BUTTON ENGINE (Floating Action Widget)
-- ==============================================================
-- Suppress WindUI's default internal pill button so there are no duplicates
pcall(function()
    if Window.OpenButtonMain and Window.OpenButtonMain.Button and Window.OpenButtonMain.Button.Parent then
        Window.OpenButtonMain.Button.Parent:Destroy()
    end
end)

local floatGuiParent = game:GetService("CoreGui") or LP.PlayerGui
pcall(function()
    local oldF = floatGuiParent:FindFirstChild("ClientOP_FloatingBtn")
    if oldF then oldF:Destroy() end
end)

local FloatScreenGui = Instance.new("ScreenGui")
FloatScreenGui.Name = "ClientOP_FloatingBtn"
FloatScreenGui.ResetOnSpawn = false
FloatScreenGui.DisplayOrder = 999999
FloatScreenGui.IgnoreGuiInset = true
FloatScreenGui.Parent = floatGuiParent

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatButton"
FloatBtn.Size = UDim2.fromOffset(48, 48)
FloatBtn.Position = UDim2.new(0, 18, 0, 120)
FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Text = ""
FloatBtn.AutoButtonColor = false
FloatBtn.Active = true
FloatBtn.Parent = FloatScreenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = FloatBtn

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 2
floatStroke.Color = Color3.fromRGB(0, 220, 255)
floatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
floatStroke.Parent = FloatBtn

local floatGrad = Instance.new("UIGradient")
floatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 70, 255))
})
floatGrad.Rotation = 45
floatGrad.Parent = floatStroke

local floatIcon = Instance.new("ImageLabel")
floatIcon.Name = "Icon"
floatIcon.Size = UDim2.fromOffset(26, 26)
floatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
floatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
floatIcon.BackgroundTransparency = 1
floatIcon.Image = "rbxassetid://81872698913435" -- Lucide swords icon
floatIcon.ImageColor3 = Color3.fromRGB(0, 240, 255)
floatIcon.Parent = FloatBtn

local function toggleMainWindow()
    if Window.Closed then
        Window:Open()
    else
        Window:Close()
    end
end

local function updateFloatVisual()
    if Window.Closed then
        -- Window HIDDEN / CLOSED: Glowing neon cyan/purple
        floatStroke.Color = Color3.fromRGB(0, 240, 255)
        floatIcon.ImageColor3 = Color3.fromRGB(0, 240, 255)
        FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        FloatBtn.BackgroundTransparency = 0.1
    else
        -- Window OPEN: Softer docked look
        floatStroke.Color = Color3.fromRGB(90, 105, 130)
        floatIcon.ImageColor3 = Color3.fromRGB(150, 165, 190)
        FloatBtn.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
        FloatBtn.BackgroundTransparency = 0.35
    end
end

Window:OnOpen(updateFloatVisual)
Window:OnClose(updateFloatVisual)
updateFloatVisual()

-- Smooth Dragging System (Distinguishes Tap vs Drag)
local dragging = false
local dragStart = Vector3.zero
local startPos = FloatBtn.Position
local dragThreshold = 6

on(FloatBtn.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatBtn.Position
    end
end)

on(UIS.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

on(FloatBtn.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            local delta = (input.Position - dragStart).Magnitude
            if delta < dragThreshold then
                toggleMainWindow()
            end
        end
    end
end)

-- Hover Animation
on(FloatBtn.MouseEnter, function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.12), { Size = UDim2.fromOffset(52, 52) }):Play()
end)
on(FloatBtn.MouseLeave, function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.12), { Size = UDim2.fromOffset(48, 48) }):Play()
end)

-- ==============================================================
-- KEYBOARD SHORTCUTS INTEGRATION
-- ==============================================================
on(UIS.InputBegan, function(input, gpe)
    if gpe then return end
    local k = input.KeyCode

    if k == Enum.KeyCode.RightControl then
        toggleMainWindow()
    elseif k == Enum.KeyCode.B then
        setToggleSafe("AutoBoss", not S.AutoBoss)
        notify("Auto Boss", S.AutoBoss and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.J then
        setToggleSafe("AutoBossHW", not S.AutoBossHW)
        notify("Auto Boss HW", S.AutoBossHW and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.T then
        setToggleSafe("AutoStage", not S.AutoStage)
        notify("Auto Stage", S.AutoStage and "ENABLED (Blitz Mode Active)" or "DISABLED")
    elseif k == Enum.KeyCode.Y then
        local newMode = (S.StageCheckpoint == "VIP") and "FREE" or "VIP"
        if updateCheckpointUI then updateCheckpointUI(newMode) end
    elseif k == Enum.KeyCode.V then
        local newMode = (S.StageCheckpoint == "VIP") and "FREE" or "VIP"
        if updateCheckpointUI then updateCheckpointUI(newMode) end
    elseif k == Enum.KeyCode.H then
        setToggleSafe("AutoHalloween", not S.AutoHalloween)
        notify("Auto Halloween", S.AutoHalloween and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.G then
        setToggleSafe("God", not S.God)
        notify("God Mode", S.God and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.K then
        setToggleSafe("FastKill", not S.FastKill)
        notify("Fast Kill", S.FastKill and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.F then
        setToggleSafe("AutoFarm", not S.AutoFarm)
        notify("Auto Farm", S.AutoFarm and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.N then
        setToggleSafe("NoClip", not S.NoClip)
        notify("NoClip", S.NoClip and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.X then
        setToggleSafe("Speed", not S.Speed)
        notify("Speed Boost", S.Speed and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.C then
        setToggleSafe("AutoClick", not S.AutoClick)
        notify("Auto Click", S.AutoClick and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.Z then
        setToggleSafe("AutoZone", not S.AutoZone)
        notify("Auto Zone", S.AutoZone and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.R then
        setToggleSafe("AutoRebirth", not S.AutoRebirth)
        notify("Auto Rebirth", S.AutoRebirth and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.U then
        setToggleSafe("AntiAFK", not S.AntiAFK)
        notify("Anti-AFK", S.AntiAFK and "ENABLED" or "DISABLED")
    elseif k == Enum.KeyCode.O then
        setToggleSafe("AutoClaim", not S.AutoClaim)
        notify("Auto Claim", S.AutoClaim and "ENABLED" or "DISABLED")
    end
end)

-- ==============================================================
-- LIVE TELEMETRY & COUNTDOWN UPDATE LOOP (1 SEC INTERVAL)
-- ==============================================================
task.spawn(function()
    while running do
        task.wait(1.0)
        local now = os.time()

        -- Update Rotation Boss Paragraph
        if regBossParagraph and JefeEstado then
            local hasta = tonumber(JefeEstado:GetAttribute("Hasta")) or 0
            local fase = tostring(JefeEstado:GetAttribute("Fase") or "cerrada")
            local rem = math.max(0, hasta - now)
            local bName = tostring(JefeEstado:GetAttribute("Nombre") or "BOSS")

            if LP:GetAttribute("EnJefe") == true then
                local hp = tonumber(JefeEstado:GetAttribute("Vida")) or 0
                regBossParagraph:SetTitle("FIGHTING: " .. bName)
                regBossParagraph:SetDesc(string.format("Boss HP: %s", abreviar(hp)))
            elseif fase == "abierta" then
                regBossParagraph:SetTitle("GATE OPEN! " .. bName)
                regBossParagraph:SetDesc(string.format("Enter arena now (%ds)!", math.ceil(rem)))
            elseif rem <= 22 then
                regBossParagraph:SetTitle("GET READY! " .. bName)
                regBossParagraph:SetDesc(string.format("Gate opens in %ds", math.ceil(rem)))
            else
                regBossParagraph:SetTitle("Rotation: " .. bName)
                regBossParagraph:SetDesc(string.format("Starts in: %s", formatTime(rem)))
            end
        end

        -- Update Halloween Boss Paragraph
        if hwBossParagraph and JefeHWEstado then
            local hasta = tonumber(JefeHWEstado:GetAttribute("Hasta")) or 0
            local fase = tostring(JefeHWEstado:GetAttribute("Fase") or "cerrada")
            local rem = math.max(0, hasta - now)
            local bName = tostring(JefeHWEstado:GetAttribute("Nombre") or "PUMPKIN REAPER")

            if LP:GetAttribute("EnJefeHW") == true then
                local hp = tonumber(JefeHWEstado:GetAttribute("Vida")) or 0
                hwBossParagraph:SetTitle("FIGHTING: " .. bName)
                hwBossParagraph:SetDesc(string.format("Boss HP: %s", abreviar(hp)))
            elseif fase == "abierta" then
                hwBossParagraph:SetTitle("GATE OPEN! " .. bName)
                hwBossParagraph:SetDesc(string.format("Enter arena now (%ds)!", math.ceil(rem)))
            elseif rem <= 22 then
                hwBossParagraph:SetTitle("GET READY! " .. bName)
                hwBossParagraph:SetDesc(string.format("Gate opens in %ds", math.ceil(rem)))
            else
                hwBossParagraph:SetTitle("Event: " .. bName)
                hwBossParagraph:SetDesc(string.format("Starts in: %s", formatTime(rem)))
            end
        end

        -- Update Telemetry Stats Paragraph
        if statsParagraph then
            local wins = tonumber(LP:GetAttribute("Wins")) or 0
            local str = tonumber(LP:GetAttribute("Fuerza")) or 0
            local lvl = tonumber(LP:GetAttribute("Nivel")) or 0
            local reb = tonumber(LP:GetAttribute("Rebirths")) or 0
            local meta = tonumber(LP:GetAttribute("RebirthMeta")) or 0
            local curM = tonumber(LP:GetAttribute("Mundo")) or 1
            local maxM = tonumber(LP:GetAttribute("MundoMax")) or 1
            local zona = tostring(LP:GetAttribute("Zona") or "None")

            statsParagraph:SetTitle(string.format("World %d (Max: %d) | Rebirth %d", curM, maxM, reb))
            statsParagraph:SetDesc(string.format("Wins: %s\nStrength: %s\nLevel: %d / %s\nTraining Zone: %s",
                abreviar(wins), abreviar(str), lvl, tostring(meta), zona))
        end
    end
end)

-- PUBLIC API INTERFACE & CLEANUP HOOK
genv.__CLIENTOP2 = {
    Stop = function()
        genv.__CLIENTOP2 = nil
        running = false
        S.God = false
        for _, c in ipairs(conns) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(conns)
        pcall(function() FloatScreenGui:Destroy() end)
        pcall(function() Window:Destroy() end)
        pcall(function()
            local pf = workspace:FindFirstChild("ClientOP_HWPlatform")
            if pf then pf:Destroy() end
        end)
        pcall(function()
            local rgui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
            if rgui then
                for _, c in ipairs(rgui:GetChildren()) do
                    if c.Name:find("WindUI") then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end)
    end,
    S = S,
    CFG = CFG,
    Set = function(k, v)
        setToggleSafe(k, v)
    end,
    SaveConfig = function(name)
        return saveConfigToFile(name)
    end,
    LoadConfig = function(name)
        return loadConfigFromFile(name)
    end,
    ResetAll = function()
        for k, _ in pairs(S) do
            setToggleSafe(k, false)
        end
    end,
    ClaimAll = claimAllRewards,
    RedeemAll = redeemAllCodes,
    CrackEgg = handleEggCracking,
    Window = Window,
    WindUI = WindUI,
    Toggles = toggles,
    SliderWalkSpeed = sliderWalkSpeed,
    FloatingBtn = FloatBtn,
    FloatGui = FloatScreenGui,
}

Window:SelectTab(1)
WindUI:Notify({
    Title = "FLa ProjecT +1 Assasin Leveling",
    Content = "All features are OFF by default. Enable manually or load your profile from the Config tab.",
    Duration = 4.0,
})
