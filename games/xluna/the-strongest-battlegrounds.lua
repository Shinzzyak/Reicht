-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB â The Strongest Battlegrounds
    Author: By XLunaHUB
]]

if getgenv().XLunaHUB_Cleanup then
    pcall(getgenv().XLunaHUB_Cleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if setthreadidentity then
    pcall(setthreadidentity, 8)
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setthreadidentity then
    pcall(setthreadidentity, 8)
end

local State = {
    -- Combat
    AutoCombat = false,
    AutoSkills = false,
    AutoWallCombo = false,
    AutoBlock = false,
    AutoRagdollCancel = false,
    AutoUltimate = false,
    Camlock = false,
    LockPlayer = false,
    LockedPlayerName = "",
    TargetMode = "Nearest",
    ComboFinisher = "Default",
    AttackRange = 16,
    BlockThreatRange = 18,

    -- Auto Farm
    AutoFarm = false,
    FarmTargetFilter = "Weakest Dummy",
    FarmPositionMode = "Behind Target",
    FarmDistance = 5,
    AutoTrashcan = false,
    AutoVoidRecovery = false,

    -- Movement & Defense
    WalkSpeedEnabled = false,
    WalkSpeedValue = 24,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    NoSlow = false,
    InfiniteDash = false,
    DashPower = 85,
    FlyEnabled = false,
    FlySpeed = 70,
    Noclip = false,

    -- Visuals
    ESPEnabled = false,
    ESPDummy = true,
    ESPBoxes = true,
    ESPHealth = true,
    ESPStatus = true,
    TrashESP = false,
    Fullbright = false,
    FOVEnabled = false,
    FOVValue = 70,

    -- Misc
    AutoSkipDeathEmote = false,
    AutoEmoteSpin = false,
    AutoClaimBattlePass = false,
    NoCamShake = false,
    AntiAFK = false,

    -- Internal
    SelectedCharacter = "Bald",
    SelectedLocation = "Arena Center",
    SelectedPlayer = "",
    ConfigName = "default",
    SelectedConfig = "default",
}

local Runtime = {
    Unloaded = false,
    Connections = {},
    DrawingESP = {},
    TrashESP = {},
    SavedPartsCollide = {},
    OriginalLighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
    },
    FlyBV = nil,
    FlyBG = nil,
    LastM1 = 0,
    LastSkill = 0,
    LastBlockState = false,
    LastThreatTime = 0,
    LastEvasive = 0,
    LastUlt = 0,
    LastTrashClick = 0,
    LastSpinCheck = 0,
    LastBPCheck = 0,
    OrbitAngle = 0,
    MouseSeq = { 0, 0, 0, 0 },
}

local function addConn(sig, fn)
    local conn = sig:Connect(fn)
    table.insert(Runtime.Connections, conn)
    return conn
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getCommunicate(char)
    if not char then return nil end
    local rem = char:FindFirstChild("Communicate")
    if rem and rem:IsA("RemoteEvent") then
        return rem
    end
    return nil
end

-- Exact MousePos bit-packed encoder matching CharacterHandler.Client
local function encodeMousePos(cf)
    if typeof(cf) ~= "CFrame" then
        return cf
    end
    local pos = cf.Position
    local ok, encoded = pcall(function()
        local b1 = string.unpack("<I4", string.pack("<f", pos.X))
        local b2 = string.unpack("<I4", string.pack("<f", pos.Y))
        local b3 = string.unpack("<I4", string.pack("<f", pos.Z))
        if bit32.band(b1, 2139095040) ~= 2139095040
            and bit32.band(b2, 2139095040) ~= 2139095040
            and bit32.band(b3, 2139095040) ~= 2139095040 then
            local s1 = bit32.rshift(b1, 8)
            local s2 = bit32.rshift(b2, 8)
            local s3 = bit32.rshift(b3, 8)
            Runtime.MouseSeq[4] = (Runtime.MouseSeq[4] + 1) % 4
            local idx = Runtime.MouseSeq[4]
            local r2 = (idx == 3) and math.random(0, 4095) or math.clamp(math.floor(Runtime.MouseSeq[idx + 1] or 0), 0, 4095)
            local r1 = (idx * 131 + r2 * 17 + s1 % 1009 + s2 % 1013 * 3 + s3 % 1019 * 5) % 1024
            local key = (LocalPlayer.UserId % 16777216 * 40503 + s1 * 2654 + s2 * 7919 + s3 * 104729) % 16777216
            local packed = bit32.bxor(idx * 4194304 + r1 * 4096 + r2, key)
            local nx = string.unpack("<f", string.pack("<I4", bit32.bor(bit32.lshift(s1, 8), bit32.band(packed, 255))))
            local ny = string.unpack("<f", string.pack("<I4", bit32.bor(bit32.lshift(s2, 8), bit32.band(bit32.rshift(packed, 8), 255))))
            local nz = string.unpack("<f", string.pack("<I4", bit32.bor(bit32.lshift(s3, 8), bit32.band(bit32.rshift(packed, 16), 255))))
            return cf.Rotation + Vector3.new(nx, ny, nz)
        end
        return cf
    end)
    return (ok and encoded) or cf
end

local function getOtherPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, "None")
    end
    return names
end

local function isTargetValid(model, allowDummy, allowPlayers)
    if not model or not model:IsA("Model") or not model:IsDescendantOf(workspace) then return false end
    local myChar = getCharacter()
    if model == myChar then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return false end
    if model:FindFirstChild("AbsoluteImmortal") or model:FindFirstChild("FinalDeath") then return false end
    if model:GetAttribute("CircusSpectator") then return false end

    local isNPC = model:GetAttribute("NPC") == true or model.Name == "Weakest Dummy"
    if isNPC and not allowDummy then return false end
    if not isNPC and not allowPlayers then return false end
    return true
end

local function getBestTarget(mode, maxRange)
    local myChar = getCharacter()
    local myRoot = getRoot(myChar)
    if not myRoot then return nil, math.huge end

    local live = workspace:FindFirstChild("Live")
    if not live then return nil, math.huge end

    -- Lock Player overrides target selection exclusively to the chosen player
    if State.LockPlayer and State.LockedPlayerName ~= "" and State.LockedPlayerName ~= "None" then
        local lockedPlayer = Players:FindFirstChild(State.LockedPlayerName)
        local lockedModel = (lockedPlayer and lockedPlayer.Character) or live:FindFirstChild(State.LockedPlayerName)
        if lockedModel and isTargetValid(lockedModel, false, true) then
            local hrp = lockedModel:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if not maxRange or dist <= maxRange then
                    return lockedModel, dist
                end
            end
        end
        return nil, math.huge
    end

    local allowDummy = (mode == "Nearest" or mode == "Lowest HP" or mode == "Dummy Only" or mode == "Weakest Dummy" or mode == "All (Dummy + Players)")
    local allowPlayers = (mode == "Nearest" or mode == "Lowest HP" or mode == "Players Only" or mode == "Lowest HP Player" or mode == "Nearest Player" or mode == "All (Dummy + Players)")
    local preferLowestHP = (mode == "Lowest HP" or mode == "Lowest HP Player")

    local bestModel, bestScore, bestDist = nil, math.huge, math.huge
    for _, m in ipairs(live:GetChildren()) do
        if isTargetValid(m, allowDummy, allowPlayers) then
            local hrp = m:FindFirstChild("HumanoidRootPart")
            local hum = m:FindFirstChildOfClass("Humanoid")
            local dist = (hrp.Position - myRoot.Position).Magnitude
            if not maxRange or dist <= maxRange then
                local score = preferLowestHP and (hum.Health + dist * 0.05) or dist
                if score < bestScore then
                    bestScore = score
                    bestModel = m
                    bestDist = dist
                end
            end
        end
    end
    return bestModel, bestDist
end

local function isToolOnCooldown(tool)
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local hotbarGui = pgui and pgui:FindFirstChild("Hotbar")
    local backpackFrame = hotbarGui and hotbarGui:FindFirstChild("Backpack")
    local hotbar = backpackFrame and backpackFrame:FindFirstChild("Hotbar")
    if not hotbar then return false end

    local displayName = tool:GetAttribute("Name") or tool.Name
    for _, slot in ipairs(hotbar:GetChildren()) do
        local base = slot:FindFirstChild("Base")
        if base and slot.Visible then
            local tName = base:FindFirstChild("ToolName")
            if tName and tName.Text == displayName then
                if base:FindFirstChild("Cooldown") then
                    return true
                end
            end
        end
    end
    return false
end

local function fireM1(char, targetPos)
    local comm = getCommunicate(char)
    if not comm then return end
    local hitCF = CFrame.new(targetPos)
    local payload = {
        Goal = "LeftClick",
        MousePos = encodeMousePos(hitCF),
        Tick = 1,
    }
    local combo = char:GetAttribute("Combo")
    if combo == 4 then
        if State.ComboFinisher == "Auto Uppercut" then
            comm:FireServer({ Goal = "KeyPress", Key = Enum.KeyCode.Space, Tick = 1 })
            task.delay(0.14, function()
                if comm.Parent then
                    comm:FireServer({ Goal = "KeyRelease", Key = Enum.KeyCode.Space, Tick = 1 })
                end
            end)
        elseif State.ComboFinisher == "Auto Downslam" then
            local hum = getHumanoid(char)
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
    comm:FireServer(payload)
    task.delay(0.06, function()
        if comm.Parent then
            comm:FireServer({ Goal = "LeftClickRelease", Tick = 1 })
        end
    end)
end

local function fireSkill(char, tool)
    local comm = getCommunicate(char)
    if not comm or not tool or not tool.Parent then return end
    local cp = nil
    if shared and type(shared.GetCrushingPullHit) == "function" then
        local ok, res = pcall(shared.GetCrushingPullHit, tool)
        if ok then cp = res end
    end
    comm:FireServer({
        Goal = "Console Move",
        Tool = tool,
        CrushingPull = cp,
        IsAutoActivate = true,
    })
    task.delay(0.14, function()
        if comm.Parent and tool.Parent then
            comm:FireServer({
                Goal = "Console Move End",
                Tool = tool,
            })
        end
    end)
end

local function getReadySkillTools(char)
    local out = {}
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("Skill") == true and not isToolOnCooldown(t) then
                table.insert(out, t)
            end
        end
    end
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("Skill") == true and not isToolOnCooldown(t) then
                table.insert(out, t)
            end
        end
    end
    return out
end

local function isStunnedOrRagdolled(char)
    if not char then return true end
    if char:FindFirstChild("Ragdoll") or char:FindFirstChild("Freeze") or char:FindFirstChild("RootAnchor") then
        return true
    end
    if char:GetAttribute("Stunned") or char:GetAttribute("Finisherd") then
        return true
    end
    return false
end

local function setBlock(char, shouldBlock)
    local comm = getCommunicate(char)
    if not comm then return end
    if shouldBlock and not Runtime.LastBlockState then
        Runtime.LastBlockState = true
        comm:FireServer({ Goal = "KeyPress", Key = Enum.KeyCode.F, Tick = 1 })
    elseif not shouldBlock and Runtime.LastBlockState then
        Runtime.LastBlockState = false
        comm:FireServer({ Goal = "KeyRelease", Key = Enum.KeyCode.F, Tick = 1 })
    end
end

local function findNearestTrashcan(originPos, maxDist)
    local map = workspace:FindFirstChild("Map")
    local trash = map and map:FindFirstChild("Trash")
    if not trash then return nil, nil, math.huge end

    local bestModel, bestPart, bestDist = nil, nil, maxDist or math.huge
    for _, m in ipairs(trash:GetChildren()) do
        if m:GetAttribute("Broken") ~= true then
            local part = m:FindFirstChild("Trashcan") or (m:IsA("Model") and m.PrimaryPart) or m:FindFirstChildWhichIsA("BasePart")
            if part then
                local d = (part.Position - originPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestModel = m
                    bestPart = part
                end
            end
        end
    end
    return bestModel, bestPart, bestDist
end

local function facePosition(root, targetPos)
    local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
    if (flatTarget - root.Position).Magnitude > 0.05 then
        root.CFrame = CFrame.lookAt(root.Position, flatTarget)
    end
end

-- Integrated Anti-AFK (active when Anti-AFK toggle is enabled; prevents 20-minute idle kick)
addConn(LocalPlayer.Idled, function()
    if Runtime.Unloaded or not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Drawing ESP helpers
local function removeDrawingEntry(entry)
    if not entry then return end
    for _, obj in pairs(entry) do
        if obj and type(obj.Remove) == "function" then
            pcall(function() obj:Remove() end)
        end
    end
end

local function clearAllESP()
    for k, entry in pairs(Runtime.DrawingESP) do
        removeDrawingEntry(entry)
        Runtime.DrawingESP[k] = nil
    end
    for k, entry in pairs(Runtime.TrashESP) do
        removeDrawingEntry(entry)
        Runtime.TrashESP[k] = nil
    end
end

local function getOrCreateESPEntry(model)
    if Runtime.DrawingESP[model] then
        return Runtime.DrawingESP[model]
    end
    local entry = {
        Box = Drawing.new("Square"),
        HealthBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Label = Drawing.new("Text"),
        Status = Drawing.new("Text"),
    }
    entry.Box.Thickness = 1.5
    entry.Box.Filled = false
    entry.Box.Visible = false

    entry.HealthBg.Filled = true
    entry.HealthBg.Color = Color3.fromRGB(20, 20, 20)
    entry.HealthBg.Thickness = 1
    entry.HealthBg.Visible = false

    entry.HealthBar.Filled = true
    entry.HealthBar.Thickness = 1
    entry.HealthBar.Visible = false

    entry.Label.Size = 13
    entry.Label.Center = true
    entry.Label.Outline = true
    entry.Label.Color = Color3.fromRGB(255, 255, 255)
    entry.Label.Visible = false

    entry.Status.Size = 12
    entry.Status.Center = true
    entry.Status.Outline = true
    entry.Status.Color = Color3.fromRGB(255, 200, 75)
    entry.Status.Visible = false

    Runtime.DrawingESP[model] = entry
    return entry
end

local function hideEntry(entry)
    for _, obj in pairs(entry) do
        obj.Visible = false
    end
end

-- Main Render/ESP Loop
addConn(RunService.RenderStepped, function()
    if Runtime.Unloaded then return end
    Camera = workspace.CurrentCamera
    if not Camera then return end

    local myChar = getCharacter()
    local myRoot = getRoot(myChar)

    if State.FOVEnabled then
        Camera.FieldOfView = State.FOVValue
    end

    if State.ESPEnabled then
        local live = workspace:FindFirstChild("Live")
        local activeModels = {}
        if live then
            for _, model in ipairs(live:GetChildren()) do
                local isNPC = model:GetAttribute("NPC") == true or model.Name == "Weakest Dummy"
                if model ~= myChar and (not isNPC or State.ESPDummy) then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    local head = model:FindFirstChild("Head")
                    if hum and hrp and hum.Health > 0 then
                        activeModels[model] = true
                        local entry = getOrCreateESPEntry(model)
                        local topPos = (head and head.Position or hrp.Position) + Vector3.new(0, 2.2, 0)
                        local botPos = hrp.Position - Vector3.new(0, 3.0, 0)
                        local top2D, onScreen1 = Camera:WorldToViewportPoint(topPos)
                        local bot2D, onScreen2 = Camera:WorldToViewportPoint(botPos)
                        local mid2D, onScreenMid = Camera:WorldToViewportPoint(hrp.Position)

                        if (onScreen1 or onScreen2 or onScreenMid) and mid2D.Z > 0 then
                            local height = math.max(math.abs(bot2D.Y - top2D.Y), 14)
                            local width = height * 0.58
                            local x = mid2D.X - width / 2
                            local y = top2D.Y
                            local dist = myRoot and math.floor((hrp.Position - myRoot.Position).Magnitude) or 0
                            local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                            local isUlted = model:GetAttribute("Ulted") == true
                            local isBlocking = model:GetAttribute("Blocking") == true
                            local isLocked = State.LockPlayer and model.Name == State.LockedPlayerName

                            local boxColor = isLocked and Color3.fromRGB(255, 210, 60)
                                or (isNPC and Color3.fromRGB(100, 220, 255))
                                or (isUlted and Color3.fromRGB(255, 85, 85))
                                or Color3.fromRGB(255, 255, 255)

                            entry.Box.Visible = State.ESPBoxes
                            entry.Box.Color = boxColor
                            entry.Box.Size = Vector2.new(width, height)
                            entry.Box.Position = Vector2.new(x, y)

                            if State.ESPHealth then
                                entry.HealthBg.Visible = true
                                entry.HealthBg.Size = Vector2.new(4, height)
                                entry.HealthBg.Position = Vector2.new(x - 7, y)

                                entry.HealthBar.Visible = true
                                entry.HealthBar.Color = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 60)
                                local barH = math.max(height * hpPct, 1)
                                entry.HealthBar.Size = Vector2.new(2, barH)
                                entry.HealthBar.Position = Vector2.new(x - 6, y + (height - barH))
                            else
                                entry.HealthBg.Visible = false
                                entry.HealthBar.Visible = false
                            end

                            local charTag = model:GetAttribute("Character") or (isNPC and "Dummy" or "?")
                            entry.Label.Visible = true
                            entry.Label.Text = string.format("%s [%s] | %d HP | %dm", model.Name, charTag, math.ceil(hum.Health), dist)
                            entry.Label.Position = Vector2.new(mid2D.X, y - 16)

                            if State.ESPStatus then
                                local tags = {}
                                if isLocked then table.insert(tags, "LOCKED") end
                                if isBlocking then table.insert(tags, "BLOCK") end
                                if isUlted then table.insert(tags, "ULT") end
                                if model:FindFirstChild("Ragdoll") then table.insert(tags, "RAGDOLL") end
                                if model:FindFirstChild("Freeze") then table.insert(tags, "STUN") end
                                if #tags > 0 then
                                    entry.Status.Visible = true
                                    entry.Status.Text = "[" .. table.concat(tags, " | ") .. "]"
                                    entry.Status.Position = Vector2.new(mid2D.X, y + height + 3)
                                else
                                    entry.Status.Visible = false
                                end
                            else
                                entry.Status.Visible = false
                            end
                        else
                            hideEntry(entry)
                        end
                    end
                end
            end
        end
        for model, entry in pairs(Runtime.DrawingESP) do
            if not activeModels[model] then
                removeDrawingEntry(entry)
                Runtime.DrawingESP[model] = nil
            end
        end
    else
        for model, entry in pairs(Runtime.DrawingESP) do
            removeDrawingEntry(entry)
            Runtime.DrawingESP[model] = nil
        end
    end

    if State.TrashESP then
        local map = workspace:FindFirstChild("Map")
        local trash = map and map:FindFirstChild("Trash")
        local seen = {}
        if trash then
            for _, m in ipairs(trash:GetChildren()) do
                if m:GetAttribute("Broken") ~= true then
                    local part = m:FindFirstChild("Trashcan") or (m:IsA("Model") and m.PrimaryPart) or m:FindFirstChildWhichIsA("BasePart")
                    if part then
                        seen[m] = true
                        local obj = Runtime.TrashESP[m]
                        if not obj then
                            local txt = Drawing.new("Text")
                            txt.Size = 13
                            txt.Center = true
                            txt.Outline = true
                            txt.Color = Color3.fromRGB(120, 255, 160)
                            obj = { Label = txt }
                            Runtime.TrashESP[m] = obj
                        end
                        local p2d, onScreen = Camera:WorldToViewportPoint(part.Position + Vector3.new(0, 2, 0))
                        if onScreen and p2d.Z > 0 then
                            local d = myRoot and math.floor((part.Position - myRoot.Position).Magnitude) or 0
                            obj.Label.Visible = true
                            obj.Label.Text = string.format("Trashcan [%dm]", d)
                            obj.Label.Position = Vector2.new(p2d.X, p2d.Y)
                        else
                            obj.Label.Visible = false
                        end
                    end
                end
            end
        end
        for m, obj in pairs(Runtime.TrashESP) do
            if not seen[m] then
                removeDrawingEntry(obj)
                Runtime.TrashESP[m] = nil
            end
        end
    else
        for m, obj in pairs(Runtime.TrashESP) do
            removeDrawingEntry(obj)
            Runtime.TrashESP[m] = nil
        end
    end
end)

-- Noclip Stepped Loop
addConn(RunService.Stepped, function()
    if Runtime.Unloaded then return end
    local char = getCharacter()
    if not char then return end

    if State.Noclip then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if Runtime.SavedPartsCollide[part] == nil then
                    Runtime.SavedPartsCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    elseif next(Runtime.SavedPartsCollide) ~= nil then
        for part, orig in pairs(Runtime.SavedPartsCollide) do
            if part and part.Parent then
                part.CanCollide = orig
            end
        end
        table.clear(Runtime.SavedPartsCollide)
    end
end)

-- Infinite Dash Input Handler
addConn(UserInputService.InputBegan, function(input, gp)
    if Runtime.Unloaded or gp then return end
    if not State.InfiniteDash then return end
    if input.KeyCode ~= Enum.KeyCode.Q then return end

    local char = getCharacter()
    local root = getRoot(char)
    local hum = getHumanoid(char)
    if not char or not root or not hum or hum.Health <= 0 then return end
    if char:FindFirstChild("Ragdoll") then return end

    local dir = Vector3.zero
    local camCF = Camera and Camera.CFrame or root.CFrame
    local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
    look = look.Magnitude > 0.01 and look.Unit or Vector3.new(0, 0, -1)
    right = right.Magnitude > 0.01 and right.Unit or Vector3.new(1, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - look end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
    if dir.Magnitude < 0.05 then dir = look end
    dir = dir.Unit

    local old = root:FindFirstChild("XLunaDashBV")
    if old then old:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "XLunaDashBV"
    bv.MaxForce = Vector3.new(60000, 0, 60000)
    bv.Velocity = dir * State.DashPower
    bv.Parent = root
    task.delay(0.18, function()
        if bv and bv.Parent then bv:Destroy() end
    end)
end)

-- Core Heartbeat Automation Loop
addConn(RunService.Heartbeat, function(dt)
    if Runtime.Unloaded then return end
    local char = getCharacter()
    local hum = getHumanoid(char)
    local root = getRoot(char)
    if not char or not char:IsDescendantOf(workspace) or not hum or not root or hum.Health <= 0 then
        Runtime.LastBlockState = false
        return
    end

    local now = os.clock()
    local serverNow = workspace:GetServerTimeNow()
    local comm = getCommunicate(char)

    -- 1. Void Recovery
    if State.AutoVoidRecovery and root.Position.Y < 250 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(150, 446, 20)
    end

    -- 2. Movement Overrides & No Slow
    if State.WalkSpeedEnabled then
        hum.WalkSpeed = State.WalkSpeedValue
    elseif State.NoSlow then
        if char:FindFirstChild("Slowed") or char:FindFirstChild("Freeze") then
            hum.WalkSpeed = 25
        end
    end

    if State.JumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = State.JumpPowerValue
    end

    if State.NoSlow then
        if char:FindFirstChild("Freeze") then
            -- Keep root unanchored & responsive client-side
            if root.Anchored then root.Anchored = false end
        end
    end

    -- 3. Fly
    if State.FlyEnabled then
        if not Runtime.FlyBV or Runtime.FlyBV.Parent ~= root then
            if Runtime.FlyBV then pcall(function() Runtime.FlyBV:Destroy() end) end
            if Runtime.FlyBG then pcall(function() Runtime.FlyBG:Destroy() end) end
            local bv = Instance.new("BodyVelocity")
            bv.Name = "XLunaFlyBV"
            bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
            bv.Velocity = Vector3.zero
            bv.Parent = root
            Runtime.FlyBV = bv

            local bg = Instance.new("BodyGyro")
            bg.Name = "XLunaFlyBG"
            bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            bg.P = 9e4
            bg.CFrame = root.CFrame
            bg.Parent = root
            Runtime.FlyBG = bg
        end

        local camCF = Camera and Camera.CFrame or root.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0.01 then move = move.Unit * State.FlySpeed end
        Runtime.FlyBV.Velocity = move
        Runtime.FlyBG.CFrame = camCF
        hum.PlatformStand = true
    elseif Runtime.FlyBV then
        pcall(function() Runtime.FlyBV:Destroy() end)
        pcall(function() Runtime.FlyBG:Destroy() end)
        Runtime.FlyBV = nil
        Runtime.FlyBG = nil
        hum.PlatformStand = false
    end

    -- 4. Auto Ragdoll Cancel (Evasive)
    if State.AutoRagdollCancel and comm then
        if char:FindFirstChild("Ragdoll") and char:FindFirstChild("CanEscape") and (now - Runtime.LastEvasive) > 1.0 then
            Runtime.LastEvasive = now
            comm:FireServer({ Goal = "KeyPress", Key = Enum.KeyCode.Q, Dash = Enum.KeyCode.W, Tick = 1 })
        end
    end

    -- 5. Auto Ultimate (Awakening)
    if State.AutoUltimate and comm then
        local ultMeter = LocalPlayer:GetAttribute("Ultimate") or 0
        if ultMeter >= 100 and not char:GetAttribute("Ulted") and not isStunnedOrRagdolled(char) and (now - Runtime.LastUlt) > 2.0 then
            Runtime.LastUlt = now
            comm:FireServer({ Goal = "KeyPress", Key = Enum.KeyCode.G, MoveDirection = hum.MoveDirection, Tick = 1 })
        end
    end

    -- 6. Auto Wall Combo
    if State.AutoWallCombo and comm and char:FindFirstChild("WallCombo") then
        comm:FireServer({ Goal = "Wall Combo" })
    end

    -- 7. Auto Block / Parry
    if State.AutoBlock and comm and not isStunnedOrRagdolled(char) then
        local live = workspace:FindFirstChild("Live")
        local threatDetected = false
        if live then
            for _, enemy in ipairs(live:GetChildren()) do
                if enemy ~= char and isTargetValid(enemy, false, true) then
                    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                    if eRoot then
                        local dist = (eRoot.Position - root.Position).Magnitude
                        if dist <= State.BlockThreatRange then
                            local lastM1 = tonumber(enemy:GetAttribute("LastM1Fire")) or 0
                            local lastSkill = tonumber(enemy:GetAttribute("LastSkill")) or 0
                            local lastFDash = tonumber(enemy:GetAttribute("JustForwardDashed")) or 0
                            local isAttacking = (enemy:GetAttribute("HoldingM1") == true)
                                or (enemy:FindFirstChild("M1ing") ~= nil)
                                or ((serverNow - lastM1) < 0.42)
                                or ((serverNow - lastSkill) < 0.50)
                                or ((serverNow - lastFDash) < 0.45)

                            if isAttacking then
                                local toMe = (root.Position - eRoot.Position)
                                local facingMe = toMe.Magnitude < 4 or eRoot.CFrame.LookVector:Dot(toMe.Unit) > 0.25
                                if facingMe then
                                    threatDetected = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        if threatDetected then
            Runtime.LastThreatTime = now
            setBlock(char, true)
        elseif Runtime.LastBlockState and (now - Runtime.LastThreatTime) > 0.25 then
            setBlock(char, false)
        end
    elseif Runtime.LastBlockState then
        setBlock(char, false)
    end

    -- 8. Camlock / Aimbot
    if State.Camlock and Camera then
        local target = getBestTarget(State.TargetMode, 60)
        local tRoot = target and target:FindFirstChild("HumanoidRootPart")
        if tRoot then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
        end
    end

    -- 9. Auto Farm (Positioning + Full Rotation)
    if State.AutoFarm and comm and not char:FindFirstChild("Ragdoll") then
        local target = getBestTarget(State.FarmTargetFilter, nil)
        local tRoot = target and target:FindFirstChild("HumanoidRootPart")
        if tRoot then
            local targetPos = tRoot.Position
            local goalCF
            if State.FarmPositionMode == "Above Target" then
                goalCF = CFrame.lookAt(targetPos + Vector3.new(0, State.FarmDistance + 2, 0), targetPos)
            elseif State.FarmPositionMode == "Orbit Target" then
                Runtime.OrbitAngle = (Runtime.OrbitAngle + dt * 3.5) % (math.pi * 2)
                local offset = Vector3.new(math.cos(Runtime.OrbitAngle) * State.FarmDistance, 0.5, math.sin(Runtime.OrbitAngle) * State.FarmDistance)
                goalCF = CFrame.lookAt(targetPos + offset, targetPos)
            else
                -- Behind Target
                local behindPos = (tRoot.CFrame * CFrame.new(0, 0, State.FarmDistance)).Position
                goalCF = CFrame.lookAt(behindPos, Vector3.new(targetPos.X, behindPos.Y, targetPos.Z))
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = goalCF

            if not Runtime.LastBlockState and not isStunnedOrRagdolled(char) then
                if (now - Runtime.LastM1) >= 0.19 then
                    Runtime.LastM1 = now
                    fireM1(char, targetPos)
                end
                if State.AutoSkills and (now - Runtime.LastSkill) >= 0.35 then
                    local skills = getReadySkillTools(char)
                    if #skills > 0 then
                        Runtime.LastSkill = now
                        fireSkill(char, skills[1])
                    end
                end
            end
        end
    elseif State.AutoTrashcan and comm and not isStunnedOrRagdolled(char) then
        -- 10. Auto Grab & Throw Trashcan
        if char:GetAttribute("HasTrashcan") then
            local target = getBestTarget(State.TargetMode, 600)
            local tRoot = target and target:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local distToTarget = (tRoot.Position - root.Position).Magnitude
                if distToTarget > 18 then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.lookAt(tRoot.Position + Vector3.new(0, 0.5, 10), tRoot.Position)
                elseif (now - Runtime.LastTrashClick) > 0.35 then
                    Runtime.LastTrashClick = now
                    facePosition(root, tRoot.Position)
                    comm:FireServer({
                        Goal = "LeftClick",
                        MousePos = encodeMousePos(tRoot.CFrame),
                        Tick = 1,
                    })
                    task.delay(0.05, function()
                        if comm.Parent then
                            comm:FireServer({ Goal = "LeftClickRelease", Tick = 1 })
                        end
                    end)
                end
            end
        else
            local _, tcPart, tcDist = findNearestTrashcan(root.Position, 1000)
            if tcPart then
                if tcDist > 5.5 then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.lookAt(tcPart.Position + Vector3.new(0, 1.0, 2.8), tcPart.Position)
                elseif (now - Runtime.LastTrashClick) > 0.35 then
                    Runtime.LastTrashClick = now
                    facePosition(root, tcPart.Position)
                    comm:FireServer({
                        Goal = "LeftClick",
                        MousePos = encodeMousePos(tcPart.CFrame),
                        Tick = 1,
                    })
                    task.delay(0.05, function()
                        if comm.Parent then
                            comm:FireServer({ Goal = "LeftClickRelease", Tick = 1 })
                        end
                    end)
                end
            end
        end
    elseif State.AutoCombat and comm and not Runtime.LastBlockState and not isStunnedOrRagdolled(char) then
        -- 11. Auto Combat / Kill Aura
        local target, dist = getBestTarget(State.TargetMode, State.AttackRange)
        local tRoot = target and target:FindFirstChild("HumanoidRootPart")
        if tRoot and dist <= State.AttackRange then
            facePosition(root, tRoot.Position)
            if (now - Runtime.LastM1) >= 0.19 then
                Runtime.LastM1 = now
                fireM1(char, tRoot.Position)
            end
            if State.AutoSkills and (now - Runtime.LastSkill) >= 0.35 then
                local skills = getReadySkillTools(char)
                if #skills > 0 then
                    Runtime.LastSkill = now
                    fireSkill(char, skills[1])
                end
            end
        end
    elseif State.AutoSkills and not State.AutoCombat and not State.AutoFarm and comm and not isStunnedOrRagdolled(char) then
        -- Standalone Auto Skills when target is in range
        local target, dist = getBestTarget(State.TargetMode, State.AttackRange)
        local tRoot = target and target:FindFirstChild("HumanoidRootPart")
        if tRoot and dist <= State.AttackRange and (now - Runtime.LastSkill) >= 0.35 then
            facePosition(root, tRoot.Position)
            local skills = getReadySkillTools(char)
            if #skills > 0 then
                Runtime.LastSkill = now
                fireSkill(char, skills[1])
            end
        end
    end

    -- 12. Misc Automations (Throttled)
    if State.AutoSkipDeathEmote and comm and char:GetAttribute("DiedEmote") then
        comm:FireServer({ Goal = "SkipEmote" })
    end

    if State.AutoEmoteSpin and comm and (now - Runtime.LastSpinCheck) > 3.0 then
        Runtime.LastSpinCheck = now
        local totalKills = LocalPlayer:GetAttribute("TotalKillsFrb") or 0
        local lastSpin = LocalPlayer:GetAttribute("LastEmoteSpin") or -100
        if (totalKills - lastSpin) >= 50 then
            comm:FireServer({ Goal = "Emote Spin" })
        end
    end

    if State.AutoClaimBattlePass and comm and (now - Runtime.LastBPCheck) > 5.0 then
        Runtime.LastBPCheck = now
        comm:FireServer({ Goal = "Claim All Tiers" })
    end

    if State.NoCamShake then
        if LocalPlayer:GetAttribute("S_RemoveCameraShake") ~= true then
            LocalPlayer:SetAttribute("S_RemoveCameraShake", true)
        end
        if LocalPlayer:GetAttribute("S_ReducedCamshake") ~= true then
            LocalPlayer:SetAttribute("S_ReducedCamshake", true)
        end
    end
end)

-- Build WindUI Window
if setthreadidentity then
    pcall(setthreadidentity, 8)
end

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB",
    Icon = "swords",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_TSB",
    Size = UDim2.fromOffset(620, 480),
    MinSize = Vector2.new(540, 380),
    MaxSize = Vector2.new(860, 620),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 190,
    HideSearchBar = true,
    OpenButton = {
        Enabled = false,
    },
})

-- Use WindUI's native ToggleKey for LeftCTRL (note: Enum.KeyCode.Unknown == None matches mouse clicks in WindUI!)
pcall(function()
    Window:SetToggleKey(Enum.KeyCode.LeftControl)
end)

-- Layered DisplayOrder so WindUI sits cleanly above Roblox Topbar and Dropdowns/Notifications stay on top
pcall(function()
    if WindUI.ScreenGui then WindUI.ScreenGui.DisplayOrder = 100 end
    if WindUI.NotificationGui then WindUI.NotificationGui.DisplayOrder = 110 end
    if WindUI.DropdownGui then WindUI.DropdownGui.DisplayOrder = 120 end
    if WindUI.TooltipGui then WindUI.TooltipGui.DisplayOrder = 130 end
end)

local isUiOpen = true
local lastUiToggle = 0

local function setUiVisible(show)
    if Runtime.Unloaded then return end
    local now = os.clock()
    if (now - lastUiToggle) < 0.35 then return end
    lastUiToggle = now
    isUiOpen = show
    if show then
        Window:Open()
    else
        Window:Close()
    end
end

local function toggleUI()
    setUiVisible(not isUiOpen)
end

Window:OnOpen(function()
    isUiOpen = true
end)

Window:OnClose(function()
    isUiOpen = false
end)

-- Custom Draggable Floating Button (Show / Hide UI)
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "XLunaHUB_FloatingButton"
FloatingGui.DisplayOrder = 150
FloatingGui.ResetOnSpawn = false
FloatingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = (gethui and gethui()) or CoreGui
FloatingGui.Parent = guiParent

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "ToggleButton"
FloatBtn.Size = UDim2.fromOffset(124, 34)
FloatBtn.Position = UDim2.new(0.5, -62, 0, 74)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
FloatBtn.BackgroundTransparency = 0.1
FloatBtn.Text = "XLunaHUB"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 13
FloatBtn.TextColor3 = Color3.fromRGB(240, 244, 255)
FloatBtn.AutoButtonColor = true
FloatBtn.Parent = FloatingGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 10)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(115, 135, 255)
FloatStroke.Thickness = 1.5
FloatStroke.Parent = FloatBtn

do
    local dragging = false
    local dragStart, startPos, moved = nil, nil, false

    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = FloatBtn.Position
        end
    end)

    addConn(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                moved = true
            end
            FloatBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    addConn(UserInputService.InputEnded, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved then
                toggleUI()
            end
        end
    end)
end

-- Tabs
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "bot" })
local MovementTab = Window:Tab({ Title = "Movement", Icon = "zap" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "wrench" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "save" })

local ConfigManager = Window.ConfigManager
local ActiveConfig = ConfigManager:CreateConfig("default")

local function reg(flag, element)
    if ActiveConfig and flag then
        pcall(function()
            ActiveConfig:Register(flag, element)
        end)
    end
    return element
end

-- ==================== COMBAT TAB ====================
reg("AutoCombat", CombatTab:Toggle({
    Title = "Auto Combat (Kill Aura)",
    Desc = "Automatically punches and tracks nearest target in range",
    Value = false,
    Flag = "AutoCombat",
    Callback = function(v) State.AutoCombat = v end,
}))

reg("AutoSkills", CombatTab:Toggle({
    Title = "Auto Use Skills",
    Desc = "Automatically casts off-cooldown skills without equipping",
    Value = false,
    Flag = "AutoSkills",
    Callback = function(v) State.AutoSkills = v end,
}))

reg("AutoWallCombo", CombatTab:Toggle({
    Title = "Auto Wall Combo",
    Desc = "Instantly executes Wall Combo when available",
    Value = false,
    Flag = "AutoWallCombo",
    Callback = function(v) State.AutoWallCombo = v end,
}))

reg("AutoBlock", CombatTab:Toggle({
    Title = "Auto Block / Parry",
    Desc = "Automatically blocks incoming melee attacks and front dashes",
    Value = false,
    Flag = "AutoBlock",
    Callback = function(v)
        State.AutoBlock = v
        if not v then
            local char = getCharacter()
            if char then setBlock(char, false) end
        end
    end,
}))

reg("AutoRagdollCancel", CombatTab:Toggle({
    Title = "Auto Ragdoll Cancel",
    Desc = "Automatically triggers Evasive (Q) when ragdolled and escapable",
    Value = false,
    Flag = "AutoRagdollCancel",
    Callback = function(v) State.AutoRagdollCancel = v end,
}))

reg("AutoUltimate", CombatTab:Toggle({
    Title = "Auto Awakening (Ultimate)",
    Desc = "Automatically activates Awakening when Ultimate reaches 100%",
    Value = false,
    Flag = "AutoUltimate",
    Callback = function(v) State.AutoUltimate = v end,
}))

reg("Camlock", CombatTab:Toggle({
    Title = "Camlock (Target Lock)",
    Desc = "Locks camera smoothly onto the selected combat target",
    Value = false,
    Flag = "Camlock",
    Callback = function(v) State.Camlock = v end,
}))

local initialPlayers = getOtherPlayerNames()
State.LockedPlayerName = initialPlayers[1] or ""
State.SelectedPlayer = initialPlayers[1] or ""

reg("LockPlayer", CombatTab:Toggle({
    Title = "Lock Player Target",
    Desc = "Locks all combat, skills, camlock, trashcan throw, and farm onto the selected player",
    Value = false,
    Flag = "LockPlayer",
    Callback = function(v) State.LockPlayer = v end,
}))

local LockPlayerDropdown = reg("LockedPlayerName", CombatTab:Dropdown({
    Title = "Select Locked Player",
    Values = initialPlayers,
    Value = initialPlayers[1] or "None",
    Flag = "LockedPlayerName",
    Callback = function(v) State.LockedPlayerName = v end,
}))

reg("TargetMode", CombatTab:Dropdown({
    Title = "Target Priority",
    Values = { "Nearest", "Lowest HP", "Dummy Only", "Players Only" },
    Value = "Nearest",
    Flag = "TargetMode",
    Callback = function(v) State.TargetMode = v end,
}))

reg("ComboFinisher", CombatTab:Dropdown({
    Title = "4th M1 Finisher Mode",
    Values = { "Default", "Auto Uppercut", "Auto Downslam" },
    Value = "Default",
    Flag = "ComboFinisher",
    Callback = function(v) State.ComboFinisher = v end,
}))

reg("AttackRange", CombatTab:Slider({
    Title = "Combat Range",
    Value = { Min = 8, Max = 35, Default = 16 },
    Step = 1,
    Flag = "AttackRange",
    Callback = function(v) State.AttackRange = v end,
}))

reg("BlockThreatRange", CombatTab:Slider({
    Title = "Auto Block Threat Range",
    Value = { Min = 10, Max = 30, Default = 18 },
    Step = 1,
    Flag = "BlockThreatRange",
    Callback = function(v) State.BlockThreatRange = v end,
}))

-- ==================== AUTO FARM TAB ====================
reg("AutoFarm", FarmTab:Toggle({
    Title = "Auto Farm Targets",
    Desc = "Teleports around target and executes full M1 + Skill rotation",
    Value = false,
    Flag = "AutoFarm",
    Callback = function(v) State.AutoFarm = v end,
}))

reg("FarmTargetFilter", FarmTab:Dropdown({
    Title = "Farm Target Filter",
    Values = { "Weakest Dummy", "Lowest HP Player", "Nearest Player", "All (Dummy + Players)" },
    Value = "Weakest Dummy",
    Flag = "FarmTargetFilter",
    Callback = function(v) State.FarmTargetFilter = v end,
}))

reg("FarmPositionMode", FarmTab:Dropdown({
    Title = "Farm Position Mode",
    Values = { "Behind Target", "Above Target", "Orbit Target" },
    Value = "Behind Target",
    Flag = "FarmPositionMode",
    Callback = function(v) State.FarmPositionMode = v end,
}))

reg("FarmDistance", FarmTab:Slider({
    Title = "Farm Distance",
    Value = { Min = 3, Max = 14, Default = 5 },
    Step = 0.5,
    Flag = "FarmDistance",
    Callback = function(v) State.FarmDistance = v end,
}))

reg("AutoTrashcan", FarmTab:Toggle({
    Title = "Auto Grab & Throw Trashcan",
    Desc = "Grabs nearest unbroken trashcan and throws it at targets",
    Value = false,
    Flag = "AutoTrashcan",
    Callback = function(v) State.AutoTrashcan = v end,
}))

reg("AutoVoidRecovery", FarmTab:Toggle({
    Title = "Auto Void Recovery",
    Desc = "Returns character to arena if knocked below map bounds",
    Value = false,
    Flag = "AutoVoidRecovery",
    Callback = function(v) State.AutoVoidRecovery = v end,
}))

-- ==================== MOVEMENT TAB ====================
reg("WalkSpeedEnabled", MovementTab:Toggle({
    Title = "WalkSpeed Override",
    Value = false,
    Flag = "WalkSpeedEnabled",
    Callback = function(v)
        State.WalkSpeedEnabled = v
        if not v then
            local hum = getHumanoid(getCharacter())
            if hum then hum.WalkSpeed = 16 end
        end
    end,
}))

reg("WalkSpeedValue", MovementTab:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 150, Default = 24 },
    Step = 1,
    Flag = "WalkSpeedValue",
    Callback = function(v) State.WalkSpeedValue = v end,
}))

reg("JumpPowerEnabled", MovementTab:Toggle({
    Title = "JumpPower Override",
    Value = false,
    Flag = "JumpPowerEnabled",
    Callback = function(v)
        State.JumpPowerEnabled = v
        if not v then
            local hum = getHumanoid(getCharacter())
            if hum then hum.JumpPower = 50 end
        end
    end,
}))

reg("JumpPowerValue", MovementTab:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 180, Default = 50 },
    Step = 1,
    Flag = "JumpPowerValue",
    Callback = function(v) State.JumpPowerValue = v end,
}))

reg("NoSlow", MovementTab:Toggle({
    Title = "No Slow / Anti-Freeze",
    Desc = "Maintains movement responsiveness while slowed or stunned",
    Value = false,
    Flag = "NoSlow",
    Callback = function(v) State.NoSlow = v end,
}))

reg("InfiniteDash", MovementTab:Toggle({
    Title = "Infinite Dash (Q)",
    Desc = "Directional velocity dash bypassing cooldowns",
    Value = false,
    Flag = "InfiniteDash",
    Callback = function(v) State.InfiniteDash = v end,
}))

reg("DashPower", MovementTab:Slider({
    Title = "Infinite Dash Power",
    Value = { Min = 40, Max = 180, Default = 85 },
    Step = 5,
    Flag = "DashPower",
    Callback = function(v) State.DashPower = v end,
}))

reg("FlyEnabled", MovementTab:Toggle({
    Title = "Flight",
    Desc = "Camera-relative flight (WASD + Space/LeftShift)",
    Value = false,
    Flag = "FlyEnabled",
    Callback = function(v) State.FlyEnabled = v end,
}))

reg("FlySpeed", MovementTab:Slider({
    Title = "Flight Speed",
    Value = { Min = 20, Max = 220, Default = 70 },
    Step = 5,
    Flag = "FlySpeed",
    Callback = function(v) State.FlySpeed = v end,
}))

reg("Noclip", MovementTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls and map obstacles",
    Value = false,
    Flag = "Noclip",
    Callback = function(v) State.Noclip = v end,
}))

-- ==================== VISUALS TAB ====================
reg("ESPEnabled", VisualsTab:Toggle({
    Title = "Player ESP",
    Desc = "Displays box, health, character moveset, and distance",
    Value = false,
    Flag = "ESPEnabled",
    Callback = function(v) State.ESPEnabled = v end,
}))

reg("ESPDummy", VisualsTab:Toggle({
    Title = "Include Weakest Dummy in ESP",
    Value = false,
    Flag = "ESPDummy",
    Callback = function(v) State.ESPDummy = v end,
}))

reg("ESPBoxes", VisualsTab:Toggle({
    Title = "ESP Boxes",
    Value = false,
    Flag = "ESPBoxes",
    Callback = function(v) State.ESPBoxes = v end,
}))

reg("ESPHealth", VisualsTab:Toggle({
    Title = "ESP Health Bars",
    Value = false,
    Flag = "ESPHealth",
    Callback = function(v) State.ESPHealth = v end,
}))

reg("ESPStatus", VisualsTab:Toggle({
    Title = "ESP Status Badges",
    Desc = "Shows [BLOCK], [ULT], [RAGDOLL], [STUN] tags",
    Value = false,
    Flag = "ESPStatus",
    Callback = function(v) State.ESPStatus = v end,
}))

reg("TrashESP", VisualsTab:Toggle({
    Title = "Trashcan ESP",
    Desc = "Highlights unbroken trashcans across the map",
    Value = false,
    Flag = "TrashESP",
    Callback = function(v) State.TrashESP = v end,
}))

reg("Fullbright", VisualsTab:Toggle({
    Title = "Fullbright & No Fog",
    Value = false,
    Flag = "Fullbright",
    Callback = function(v)
        State.Fullbright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        else
            Lighting.Brightness = Runtime.OriginalLighting.Brightness
            Lighting.ClockTime = Runtime.OriginalLighting.ClockTime
            Lighting.FogEnd = Runtime.OriginalLighting.FogEnd
            Lighting.GlobalShadows = Runtime.OriginalLighting.GlobalShadows
            Lighting.Ambient = Runtime.OriginalLighting.Ambient
        end
    end,
}))

reg("FOVEnabled", VisualsTab:Toggle({
    Title = "Custom FOV",
    Value = false,
    Flag = "FOVEnabled",
    Callback = function(v)
        State.FOVEnabled = v
        if not v and Camera then
            Camera.FieldOfView = LocalPlayer:GetAttribute("S_FOV") or 70
        end
    end,
}))

reg("FOVValue", VisualsTab:Slider({
    Title = "Field of View",
    Value = { Min = 70, Max = 120, Default = 70 },
    Step = 1,
    Flag = "FOVValue",
    Callback = function(v) State.FOVValue = v end,
}))

-- ==================== MISC TAB ====================
local CharacterList = { "Bald", "Hunter", "Cyborg", "Ninja", "Batter", "Blade", "Esper", "Purple", "Tech", "Zombie" }
MiscTab:Dropdown({
    Title = "Select Character",
    Values = CharacterList,
    Value = "Bald",
    Callback = function(v) State.SelectedCharacter = v end,
})

MiscTab:Button({
    Title = "Switch Character",
    Desc = "Instantly switches to the selected character moveset",
    Callback = function()
        local comm = getCommunicate(getCharacter())
        if comm then
            comm:FireServer({ Goal = "Change Character", Character = State.SelectedCharacter })
        end
    end,
})

local Locations = {
    ["Arena Center"] = Vector3.new(150, 445, 20),
    ["Mountain High Ground"] = Vector3.new(370, 520, -65),
    ["Outer Park"] = Vector3.new(-70, 445, 89),
    ["Map Edge"] = Vector3.new(377, 445, -65),
}

MiscTab:Dropdown({
    Title = "Teleport Location",
    Values = { "Arena Center", "Weakest Dummy", "Nearest Trashcan", "Mountain High Ground", "Outer Park", "Map Edge" },
    Value = "Arena Center",
    Callback = function(v) State.SelectedLocation = v end,
})

MiscTab:Button({
    Title = "Teleport to Location",
    Callback = function()
        local root = getRoot(getCharacter())
        if not root then return end
        if State.SelectedLocation == "Weakest Dummy" then
            local live = workspace:FindFirstChild("Live")
            local d = live and live:FindFirstChild("Weakest Dummy")
            local dRoot = d and d:FindFirstChild("HumanoidRootPart")
            if dRoot then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = dRoot.CFrame * CFrame.new(0, 0, 5)
            end
        elseif State.SelectedLocation == "Nearest Trashcan" then
            local _, tcPart = findNearestTrashcan(root.Position, 5000)
            if tcPart then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = tcPart.CFrame * CFrame.new(0, 3, 3)
            end
        elseif Locations[State.SelectedLocation] then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(Locations[State.SelectedLocation])
        end
    end,
})

local PlayerDropdown

local function refreshAllPlayerDropdowns()
    local names = getOtherPlayerNames()
    if LockPlayerDropdown and LockPlayerDropdown.Refresh then
        pcall(function() LockPlayerDropdown:Refresh(names) end)
    end
    if PlayerDropdown and PlayerDropdown.Refresh then
        pcall(function() PlayerDropdown:Refresh(names) end)
    end
end

PlayerDropdown = MiscTab:Dropdown({
    Title = "Target Player",
    Values = initialPlayers,
    Value = initialPlayers[1] or "None",
    Callback = function(v) State.SelectedPlayer = v end,
})

CombatTab:Button({
    Title = "Refresh Locked Player List",
    Callback = refreshAllPlayerDropdowns,
})

MiscTab:Button({
    Title = "Refresh Player List",
    Callback = refreshAllPlayerDropdowns,
})

addConn(Players.PlayerAdded, function()
    task.defer(refreshAllPlayerDropdowns)
end)

addConn(Players.PlayerRemoving, function()
    task.defer(refreshAllPlayerDropdowns)
end)

MiscTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        local targetP = Players:FindFirstChild(State.SelectedPlayer)
        local tRoot = targetP and getRoot(targetP.Character)
        local myRoot = getRoot(getCharacter())
        if tRoot and myRoot then
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 5)
        end
    end,
})

reg("AutoSkipDeathEmote", MiscTab:Toggle({
    Title = "Auto Skip Death Emote",
    Value = false,
    Flag = "AutoSkipDeathEmote",
    Callback = function(v) State.AutoSkipDeathEmote = v end,
}))

reg("AutoEmoteSpin", MiscTab:Toggle({
    Title = "Auto Claim Emote Spins",
    Desc = "Automatically spins when 50 kills milestone is reached",
    Value = false,
    Flag = "AutoEmoteSpin",
    Callback = function(v) State.AutoEmoteSpin = v end,
}))

reg("AutoClaimBattlePass", MiscTab:Toggle({
    Title = "Auto Claim BattlePass Tiers",
    Value = false,
    Flag = "AutoClaimBattlePass",
    Callback = function(v) State.AutoClaimBattlePass = v end,
}))

reg("NoCamShake", MiscTab:Toggle({
    Title = "Disable Camera Shake",
    Value = false,
    Flag = "NoCamShake",
    Callback = function(v) State.NoCamShake = v end,
}))

reg("AntiAFK", MiscTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents idle disconnect kick while AFK",
    Value = false,
    Flag = "AntiAFK",
    Callback = function(v) State.AntiAFK = v end,
}))

MiscTab:Button({
    Title = "Clear Arena Debris",
    Desc = "Removes client-side debris models in workspace.Thrown",
    Callback = function()
        local thrown = workspace:FindFirstChild("Thrown")
        if thrown then
            for _, c in ipairs(thrown:GetChildren()) do
                if c.Name == "Debris" or c.Name == "Part" then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end,
})

-- ==================== CONFIG TAB ====================
local function refreshConfigs()
    local list = {}
    pcall(function()
        list = ConfigManager:AllConfigs() or {}
    end)
    if #list == 0 then
        list = { "default" }
    end
    return list
end

ConfigTab:Input({
    Title = "Config Name",
    Placeholder = "Enter config name...",
    Value = "default",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            State.ConfigName = v
        end
    end,
})

local ConfigDropdown = ConfigTab:Dropdown({
    Title = "Saved Configs",
    Values = refreshConfigs(),
    Value = refreshConfigs()[1],
    Callback = function(v)
        State.SelectedConfig = v
        State.ConfigName = v
    end,
})

ConfigTab:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        local name = (State.ConfigName ~= "" and State.ConfigName) or "default"
        local cfg = ConfigManager:CreateConfig(name)
        for flag, elem in pairs(ActiveConfig.Elements or {}) do
            pcall(function() cfg:Register(flag, elem) end)
        end
        local ok = pcall(function() cfg:Save() end)
        if ConfigDropdown and ConfigDropdown.Refresh then
            ConfigDropdown:Refresh(refreshConfigs())
        end
        WindUI:Notify({
            Title = "XLunaHUB Config",
            Content = ok and ("Saved configuration: " .. name) or "Failed to save configuration",
            Duration = 3,
            Icon = "save",
        })
    end,
})

ConfigTab:Button({
    Title = "Load Config",
    Icon = "folder-open",
    Callback = function()
        local name = State.SelectedConfig or State.ConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        for flag, elem in pairs(ActiveConfig.Elements or {}) do
            pcall(function() cfg:Register(flag, elem) end)
        end
        local ok = pcall(function() cfg:Load() end)
        WindUI:Notify({
            Title = "XLunaHUB Config",
            Content = ok and ("Loaded configuration: " .. name) or "Failed to load configuration",
            Duration = 3,
            Icon = "folder-open",
        })
    end,
})

ConfigTab:Button({
    Title = "Delete Config",
    Icon = "trash",
    Callback = function()
        local name = State.SelectedConfig or State.ConfigName
        if not name or name == "" then return end
        local cfg = ConfigManager:CreateConfig(name)
        pcall(function() cfg:Delete() end)
        if ConfigDropdown and ConfigDropdown.Refresh then
            ConfigDropdown:Refresh(refreshConfigs())
        end
        WindUI:Notify({
            Title = "XLunaHUB Config",
            Content = "Deleted configuration: " .. name,
            Duration = 3,
            Icon = "trash",
        })
    end,
})

ConfigTab:Button({
    Title = "Refresh Config List",
    Icon = "refresh-cw",
    Callback = function()
        if ConfigDropdown and ConfigDropdown.Refresh then
            ConfigDropdown:Refresh(refreshConfigs())
        end
    end,
})

ConfigTab:Button({
    Title = "Disable All Features",
    Icon = "power",
    Callback = function()
        for _, elem in pairs(ActiveConfig.Elements or {}) do
            if type(elem.Value) == "boolean" and elem.Set then
                pcall(function() elem:Set(false) end)
            end
        end
        WindUI:Notify({
            Title = "XLunaHUB",
            Content = "All features disabled.",
            Duration = 2,
            Icon = "power",
        })
    end,
})

Window:SelectTab(1)

-- Cleanup handler
local function cleanup()
    if Runtime.Unloaded then return end
    Runtime.Unloaded = true
    local char = getCharacter()
    if char then setBlock(char, false) end
    for _, conn in ipairs(Runtime.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Runtime.Connections)
    clearAllESP()
    if Runtime.FlyBV then pcall(function() Runtime.FlyBV:Destroy() end) end
    if Runtime.FlyBG then pcall(function() Runtime.FlyBG:Destroy() end) end
    for part, orig in pairs(Runtime.SavedPartsCollide) do
        if part and part.Parent then part.CanCollide = orig end
    end
    pcall(function() FloatingGui:Destroy() end)
    pcall(function() Window:Destroy() end)
    if getconnections then
        pcall(function()
            for _, c in ipairs(getconnections(UserInputService.InputBegan)) do
                local f = c.Function
                if f then
                    for _, up in pairs(debug.getupvalues(f)) do
                        if up == Window or (type(up) == "table" and rawget(up, "Destroyed") == true and rawget(up, "ToggleKey") ~= nil) then
                            c:Disconnect()
                            break
                        end
                    end
                end
            end
        end)
    end
    pcall(function() if WindUI.ScreenGui then WindUI.ScreenGui:Destroy() end end)
    pcall(function() if WindUI.NotificationGui then WindUI.NotificationGui:Destroy() end end)
    pcall(function() if WindUI.DropdownGui then WindUI.DropdownGui:Destroy() end end)
    pcall(function() if WindUI.TooltipGui then WindUI.TooltipGui:Destroy() end end)
end

Window:OnDestroy(cleanup)
getgenv().XLunaHUB_Cleanup = cleanup

WindUI:Notify({
    Title = "XLunaHUB Loaded",
    Content = "The Strongest Battlegrounds ready. Press LeftCTRL or use the floating button.",
    Duration = 4,
    Icon = "swords",
})
