-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ============================================================================
    AUTO HALLOWEEN EVENT - STANDALONE SCRIPT (NO WINDUI)
    Game: Arise Shadow Hunt
    Flow:
      1. Enter Halloween Map (50403, Team 937102)
      2. Teleport 20 studs away facing the Boss (Part 4035 / JinWoo)
      3. Rapid attack Boss until dead (SKIP REWARD / NO CHEST CLAIM)
      4. Exit map immediately -> return to Map 1
      5. Cooldown 1-10s (Configurable via Slider) -> Repeat
    ============================================================================
--]]

--  SERVICES
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local VirtualUser       = game:GetService("VirtualUser")
local LP                = Players.LocalPlayer

--  ANTI-AFK / ANTI-IDLE
-- 1. Hook event Idled bawaan engine Roblox (cegah 20-min idle kick)
pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- 2. Periodic background keep-alive (setiap 60s simulasi input VirtualUser)
task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

local PG = LP:WaitForChild("PlayerGui", 30)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then
    warn("[HALLOWEEN] Folder 'Remotes' tidak ditemukan!")
end

--  REMOTES RESOLVER
local RE = {}
RE.StartTp              = Remotes:FindFirstChild("StartLocalPlayerTeleport")
RE.LocalTp              = Remotes:FindFirstChild("LocalPlayerTeleport")
RE.EquipHeroWithData    = Remotes:FindFirstChild("EquipHeroWithData")
RE.HeroStand            = Remotes:FindFirstChild("HeroStandTo")
RE.HeroMove             = Remotes:FindFirstChild("HeroMoveToEnemyPos")
RE.HeroUseSkill         = Remotes:FindFirstChild("HeroUseSkill")
RE.Atk                  = Remotes:FindFirstChild("PlayerClickAttackSkill")
RE.Click                = Remotes:FindFirstChild("ClickEnemy")
RE.PlayerClickAttack    = Remotes:FindFirstChild("PlayerClickAttack")
RE.ChallengeRaidsSuccess= Remotes:FindFirstChild("ChallengeRaidsSuccess")
RE.ChallengeRaidsFail   = Remotes:FindFirstChild("ChallengeRaidsFail")

--  STATE
local HALLOW = {
    running = false,
    delay = 3, -- Default cooldown (1 - 10 detik)
    sukses = 0,
    _thread = nil,
    _freezeConn = nil,
}

--  MAP HELPER
local function GetCurrentMapId()
    local ok1, mid1 = pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local MM = require(RS.Scripts.Client.Manager.MapManager)
        if MM and MM.currentMapData and MM.currentMapData.mapSlotInfo then
            local mid = tonumber(MM.currentMapData.mapSlotInfo.mapId)
            if mid and mid > 0 then return mid end
        end
    end)
    if ok1 and mid1 then return mid1 end

    local ok2, mid2 = pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local RM = require(RS.Scripts.Client.Manager.RaidsManager)
        if RM and RM.raidsMapInfo then
            local mid = tonumber(RM.raidsMapInfo.mapId)
            if mid and mid > 0 then return mid end
        end
    end)
    if ok2 and mid2 then return mid2 end

    local ok3, mid3 = pcall(function()
        local mapsFolder = workspace:FindFirstChild("Maps")
        if mapsFolder then
            if mapsFolder:FindFirstChild("2026HalloweenMap") then
                return 50403
            end
            for _, m in ipairs(mapsFolder:GetChildren()) do
                local mn = m.Name:match("^Map(%d+)$")
                if mn then return 50000 + tonumber(mn) end
            end
        end
    end)
    if ok3 and mid3 then return mid3 end

    local ok4, wm = pcall(function()
        return workspace:GetAttribute("MapId") or workspace:GetAttribute("mapId") or workspace:GetAttribute("CurrentMapId")
    end)
    return (ok4 and type(wm) == "number" and wm > 0) and wm or nil
end

--  ATTEMPTS & INVENTORY KEY
local function GetHalloweenAttempts()
    local loaded = 0
    local keys = 0
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local PM = require(RS.Scripts.Client.Manager.PlayerManager)
        local ProtoM = require(RS.Scripts.Share.Manager.ProtocolManager)

        local ok, res = pcall(function()
            return ProtoM.SendMessage(ProtoM.Protocols.GetActivityRaidRewardCount.Name, 937102)
        end)
        if ok and res and res.remainCount ~= nil then
            loaded = tonumber(res.remainCount) or 0
            if PM and PM.localPlayerData then
                if not PM.localPlayerData.activityRaidRewardCounts then
                    PM.localPlayerData.activityRaidRewardCounts = {}
                end
                PM.localPlayerData.activityRaidRewardCounts["937102"] = loaded
            end
        elseif PM and PM.localPlayerData and PM.localPlayerData.activityRaidRewardCounts then
            loaded = tonumber(PM.localPlayerData.activityRaidRewardCounts["937102"]) or 0
        end

        if PM and PM.localPlayerData and PM.localPlayerData.items then
            for _, it in pairs(PM.localPlayerData.items) do
                local id = tonumber(it.itemId or it.id)
                if id == 10850 or id == 691 then
                    keys = keys + (tonumber(it.count) or tonumber(it.itemCount) or 0)
                end
            end
        end
    end)
    return loaded, keys
end

local function ConsumeCemeteryKey()
    local success = false
    local newRemain = 0
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local PM = require(RS.Scripts.Share.Manager.ProtocolManager)
        local res = PM.SendMessage(PM.Protocols.UseItem.Name, { useCount = 1, itemId = 10850 })
        if not (res and res.success) then
            res = PM.SendMessage(PM.Protocols.UseItem.Name, { useCount = 1, itemId = 691 })
        end
        if res and res.success then
            success = true
            if res.raidEntryInfo and res.raidEntryInfo.remainCount then
                newRemain = tonumber(res.raidEntryInfo.remainCount) or 1
            else
                newRemain = 1
            end
            local PlM = require(RS.Scripts.Client.Manager.PlayerManager)
            if PlM and PlM.localPlayerData then
                if not PlM.localPlayerData.activityRaidRewardCounts then
                    PlM.localPlayerData.activityRaidRewardCounts = {}
                end
                PlM.localPlayerData.activityRaidRewardCounts["937102"] = newRemain
            end
        end
    end)
    return success, newRemain
end

--  HERO DATA
local function GetEquippedHeroData()
    local list = {}
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local PM = require(RS.Scripts.Client.Manager.PlayerManager)
        if PM and PM.localPlayerData and PM.localPlayerData.heros then
            for _, h in pairs(PM.localPlayerData.heros) do
                if h.isEquip == true then
                    table.insert(list, { guid = h.guid, id = h.id })
                end
            end
        end
    end)
    return list
end

--  BOSS POS & SCAN
local function GetHalloweenBossCFrame()
    local targetCF = nil
    pcall(function()
        local maps = workspace:FindFirstChild("Maps")
        local hMap = maps and maps:FindFirstChild("2026HalloweenMap")
        local p4035 = hMap and hMap:FindFirstChild("Map") and hMap.Map:FindFirstChild("RaidsEnemys") and hMap.Map.RaidsEnemys:FindFirstChild("4035")
        if p4035 then
            targetCF = p4035.CFrame
        end
    end)
    return targetCF
end

local function ScanHalloweenBoss(centerPos)
    local enemys = workspace:FindFirstChild("Enemys")
    if not enemys then return nil end
    local best, bestDist = nil, 65
    for _, e in ipairs(enemys:GetChildren()) do
        if e:IsA("Model") then
            local hrp = e:FindFirstChild("HumanoidRootPart") or e.PrimaryPart or e:FindFirstChildWhichIsA("BasePart")
            if hrp then
                local d = (hrp.Position - centerPos).Magnitude
                if d <= bestDist then
                    local g = e:GetAttribute("EnemyGuid") or e:GetAttribute("BossGuid") or e:GetAttribute("Guid") or e:GetAttribute("GUID")
                    local hum = e:FindFirstChildOfClass("Humanoid")
                    best = { model = e, hrp = hrp, hum = hum, guid = g }
                    bestDist = d
                end
            end
        end
    end
    if not best then
        for _, e in ipairs(enemys:GetChildren()) do
            if e:IsA("Model") and e.Name:lower():find("jinwoo") then
                local hrp = e:FindFirstChild("HumanoidRootPart") or e.PrimaryPart or e:FindFirstChildWhichIsA("BasePart")
                local g = e:GetAttribute("EnemyGuid") or e:GetAttribute("BossGuid") or e:GetAttribute("Guid") or e:GetAttribute("GUID")
                local hum = e:FindFirstChildOfClass("Humanoid")
                return { model = e, hrp = hrp, hum = hum, guid = g }
            end
        end
    end
    return best
end

--  NATIVE HUD WITH COOLDOWN SLIDER
local StatusCallback = nil
local CounterCallback = nil
local SliderUpdateCallback = nil

local function CreateHalloweenHUD()
    if getgenv and getgenv()._HalloweenHUD then
        pcall(function() getgenv()._HalloweenHUD:Destroy() end)
    end

    local guiParent = (gethui and gethui()) or CoreGui or PG
    local sg = Instance.new("ScreenGui")
    sg.Name = "HalloweenEventStandaloneHUD"
    sg.ResetOnSpawn = false
    pcall(function() sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)

    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 280, 0, 245)
    main.Position = UDim2.new(0, 20, 0, 80)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 120, 30)
    stroke.Thickness = 1.5
    stroke.Parent = main

    -- Header Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 0, 24)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255, 150, 40)
    title.Text = "AUTO HALLOWEEN (STANDALONE)"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -26, 0, 6)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
    closeBtn.Text = "X"
    closeBtn.Parent = main

    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)

    -- Status Label
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -20, 0, 20)
    statusLbl.Position = UDim2.new(0, 10, 0, 32)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.GothamMedium
    statusLbl.TextSize = 11
    statusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLbl.Text = "Status: Idle"
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.TextTruncate = Enum.TextTruncate.AtEnd
    statusLbl.Parent = main

    -- Counter Label
    local counterLbl = Instance.new("TextLabel")
    counterLbl.Size = UDim2.new(1, -20, 0, 32)
    counterLbl.Position = UDim2.new(0, 10, 0, 52)
    counterLbl.BackgroundTransparency = 1
    counterLbl.Font = Enum.Font.Gotham
    counterLbl.TextSize = 11
    counterLbl.TextColor3 = Color3.fromRGB(180, 220, 255)
    counterLbl.Text = "Attempts: 0 | Keys: 0\nSukses Selesai: 0"
    counterLbl.TextXAlignment = Enum.TextXAlignment.Left
    counterLbl.Parent = main

    --  COOLDOWN SLIDER CONTAINER (1 - 10s)
    local sliderBox = Instance.new("Frame")
    sliderBox.Name = "SliderBox"
    sliderBox.Size = UDim2.new(1, -20, 0, 42)
    sliderBox.Position = UDim2.new(0, 10, 0, 88)
    sliderBox.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    sliderBox.BorderSizePixel = 0
    sliderBox.Parent = main

    local sBoxCorner = Instance.new("UICorner")
    sBoxCorner.CornerRadius = UDim.new(0, 6)
    sBoxCorner.Parent = sliderBox

    local sliderTitle = Instance.new("TextLabel")
    sliderTitle.Size = UDim2.new(1, -12, 0, 18)
    sliderTitle.Position = UDim2.new(0, 6, 0, 2)
    sliderTitle.BackgroundTransparency = 1
    sliderTitle.Font = Enum.Font.GothamBold
    sliderTitle.TextSize = 10
    sliderTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    sliderTitle.Text = "Cooldown Next Run: " .. tostring(HALLOW.delay) .. "s"
    sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    sliderTitle.Parent = sliderBox

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 18, 0, 18)
    minusBtn.Position = UDim2.new(0, 6, 0, 20)
    minusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 12
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Text = "-"
    minusBtn.BorderSizePixel = 0
    minusBtn.Parent = sliderBox
    local mCorn = Instance.new("UICorner")
    mCorn.CornerRadius = UDim.new(0, 4)
    mCorn.Parent = minusBtn

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 18, 0, 18)
    plusBtn.Position = UDim2.new(1, -24, 0, 20)
    plusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 12
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Text = "+"
    plusBtn.BorderSizePixel = 0
    plusBtn.Parent = sliderBox
    local pCorn = Instance.new("UICorner")
    pCorn.CornerRadius = UDim.new(0, 4)
    pCorn.Parent = plusBtn

    local trackBtn = Instance.new("TextButton")
    trackBtn.Size = UDim2.new(1, -56, 0, 8)
    trackBtn.Position = UDim2.new(0, 28, 0, 25)
    trackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    trackBtn.Text = ""
    trackBtn.AutoButtonColor = false
    trackBtn.BorderSizePixel = 0
    trackBtn.Parent = sliderBox
    local trkCorn = Instance.new("UICorner")
    trkCorn.CornerRadius = UDim.new(0, 4)
    trkCorn.Parent = trackBtn

    local pctInit = math.clamp((HALLOW.delay - 1) / 9, 0, 1)

    local trackFill = Instance.new("Frame")
    trackFill.Size = UDim2.new(pctInit, 0, 1, 0)
    trackFill.BackgroundColor3 = Color3.fromRGB(255, 140, 30)
    trackFill.BorderSizePixel = 0
    trackFill.Parent = trackBtn
    local fillCorn = Instance.new("UICorner")
    fillCorn.CornerRadius = UDim.new(0, 4)
    fillCorn.Parent = trackFill

    local trackKnob = Instance.new("Frame")
    trackKnob.Size = UDim2.new(0, 12, 0, 12)
    trackKnob.Position = UDim2.new(pctInit, -6, 0.5, -6)
    trackKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    trackKnob.BorderSizePixel = 0
    trackKnob.Parent = trackBtn
    local knobCorn = Instance.new("UICorner")
    knobCorn.CornerRadius = UDim.new(1, 0)
    knobCorn.Parent = trackKnob

    local function SetSliderVal(val)
        val = math.clamp(math.round(val), 1, 10)
        HALLOW.delay = val
        sliderTitle.Text = "Cooldown Next Run: " .. tostring(val) .. "s"
        local pct = math.clamp((val - 1) / 9, 0, 1)
        trackFill.Size = UDim2.new(pct, 0, 1, 0)
        trackKnob.Position = UDim2.new(pct, -6, 0.5, -6)
    end
    SliderUpdateCallback = SetSliderVal

    minusBtn.MouseButton1Click:Connect(function()
        SetSliderVal(HALLOW.delay - 1)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        SetSliderVal(HALLOW.delay + 1)
    end)

    local dragging = false
    trackBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = math.clamp((input.Position.X - trackBtn.AbsolutePosition.X) / trackBtn.AbsoluteSize.X, 0, 1)
            SetSliderVal(1 + rel * 9)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - trackBtn.AbsolutePosition.X) / trackBtn.AbsoluteSize.X, 0, 1)
            SetSliderVal(1 + rel * 9)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Toggle Button (Manual START/STOP via user)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 34)
    toggleBtn.Position = UDim2.new(0, 10, 0, 138)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "START AUTO HALLOWEEN"
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = main

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn

    -- Key Consume Button
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(1, -20, 0, 24)
    keyBtn.Position = UDim2.new(0, 10, 0, 180)
    keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    keyBtn.Font = Enum.Font.GothamMedium
    keyBtn.TextSize = 11
    keyBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
    keyBtn.Text = "USE 1 CEMETERY KEY NOW"
    keyBtn.BorderSizePixel = 0
    keyBtn.Parent = main

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyBtn

    StatusCallback = function(text, color)
        pcall(function()
            statusLbl.Text = text
            if color then
                statusLbl.TextColor3 = color
            end
        end)
    end

    CounterCallback = function()
        pcall(function()
            local loaded, keys = GetHalloweenAttempts()
            counterLbl.Text = string.format("Attempts: %d | Keys: %d\nSukses Selesai: %d", loaded, keys, HALLOW.sukses)
        end)
    end

    toggleBtn.MouseButton1Click:Connect(function()
        if HALLOW.running then
            _G.StopHalloween("Stopped via HUD")
            toggleBtn.Text = "START AUTO HALLOWEEN"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
        else
            toggleBtn.Text = "STOP AUTO HALLOWEEN"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            _G.StartHalloween()
        end
    end)

    keyBtn.MouseButton1Click:Connect(function()
        local okUse, newRem = ConsumeCemeteryKey()
        if okUse then
            StatusCallback(string.format("[OK] Key dipakai! Attempts: %d", newRem), Color3.fromRGB(100, 255, 150))
        else
            StatusCallback("[!] Gagal memakai key", Color3.fromRGB(255, 100, 100))
        end
        CounterCallback()
    end)

    sg.Parent = guiParent
    if getgenv then getgenv()._HalloweenHUD = sg end
    return sg
end

local function LogStatus(text, color)
    print("[HALLOWEEN] " .. tostring(text))
    if StatusCallback then
        StatusCallback(text, color)
    end
end

local function LogCounter()
    if CounterCallback then
        CounterCallback()
    end
end

--  CORE AUTOMATION
local function StopHalloween(reason)
    HALLOW.running = false
    if HALLOW._thread then
        pcall(function() task.cancel(HALLOW._thread) end)
        HALLOW._thread = nil
    end
    if HALLOW._freezeConn then
        pcall(function() HALLOW._freezeConn:Disconnect() end)
        HALLOW._freezeConn = nil
    end
    pcall(function()
        local char = LP and LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
    end)
    if reason then
        LogStatus("[STOP] " .. reason, Color3.fromRGB(255, 80, 80))
    else
        LogStatus("[OFF] Auto Halloween Disabled", Color3.fromRGB(160, 160, 160))
    end
end

local function StartHalloweenLoop()
    if HALLOW.running then return end
    HALLOW.running = true
    LogStatus("[..] Initializing Auto Halloween...", Color3.fromRGB(255, 200, 60))

    HALLOW._thread = task.spawn(function()
        while HALLOW.running do
            --  STEP 1: Check Attempts / Keys
            local loaded, keys = GetHalloweenAttempts()
            LogCounter()

            if loaded <= 0 and keys <= 0 then
                StopHalloween("Attempt & Key Halloween Habis!")
                break
            end

            -- Konsumsi Cemetery Key jika attempt habis tapi masih punya tiket
            if loaded <= 0 and keys > 0 then
                LogStatus(string.format("[..] Memakai 1 Cemetery Key (Sisa: %d)...", keys), Color3.fromRGB(255, 180, 60))
                local okUse, newRem = ConsumeCemeteryKey()
                task.wait(0.5)
                if okUse then
                    loaded = math.max(1, newRem or 1)
                    LogStatus(string.format("[OK] Key berhasil dipakai! Attempts: %d", loaded), Color3.fromRGB(100, 255, 150))
                else
                    LogStatus("[!] Gagal memakai key, mencoba lagi...", Color3.fromRGB(255, 100, 100))
                    task.wait(1)
                    continue
                end
                LogCounter()
                task.wait(0.3)
            end

            -- Pastikan player di Map 1 sebelum start raid (50001)
            local curMid = GetCurrentMapId()
            if curMid and curMid ~= 50001 and curMid ~= 50403 then
                LogStatus("[..] Teleporting to Map 1...", Color3.fromRGB(100, 200, 255))
                pcall(function()
                    if RE.StartTp then RE.StartTp:FireServer({ mapId = 50001 }) end
                end)
                local waitMap1 = 0
                while HALLOW.running and waitMap1 < 10 do
                    task.wait(1)
                    waitMap1 = waitMap1 + 1
                    if GetCurrentMapId() == 50001 then break end
                end
            end
            if not HALLOW.running then break end

            --  STEP 1: Masuk ke dalam Map Halloween
            LogStatus("[..] Creating Halloween Team (937102)...", Color3.fromRGB(255, 200, 60))
            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local RM = require(RS.Scripts.Client.Manager.RaidsManager)
                local PM = require(RS.Scripts.Share.Manager.ProtocolManager)
                pcall(function() RM.LeaveTeam() end)
                pcall(function() PM.SendMessage(PM.Protocols.LeaveRaidTeam.Name, game:GetService("Players").LocalPlayer.UserId) end)
            end)
            task.wait(0.3)

            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local RM = require(RS.Scripts.Client.Manager.RaidsManager)
                if RM and RM.CreateTeam then
                    RM.CreateTeam(937102)
                end
            end)
            task.wait(0.4)

            LogStatus("[..] Entering Halloween Map (50403)...", Color3.fromRGB(255, 200, 60))
            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local RM = require(RS.Scripts.Client.Manager.RaidsManager)
                if RM and RM.StartRaid then
                    RM.StartRaid()
                end
            end)

            -- Tunggu map 2026HalloweenMap di workspace.Maps
            local inHallow = false
            local waitEntry = 0
            while HALLOW.running and waitEntry < 15 do
                task.wait(1)
                waitEntry = waitEntry + 1
                local maps = workspace:FindFirstChild("Maps")
                if maps and maps:FindFirstChild("2026HalloweenMap") then
                    inHallow = true
                    break
                end
            end

            if not inHallow then
                LogStatus("[!] Timeout entering Halloween Map, retry...", Color3.fromRGB(255, 100, 100))
                task.wait(2)
                continue
            end

            LogStatus("[OK] In Halloween Map! Menunggu render...", Color3.fromRGB(100, 255, 150))
            task.wait(2)

            --  STEP 2: Teleport ke BOSS dengan JARAK 20 STUDS di SAMPING BOSS
            -- (Posisi samping kiri/kanan agar TIDAK berada di tengah tempat spawn reward/chest)
            local bossCF = GetHalloweenBossCFrame()
            local waitBossCF = 0
            while not bossCF and waitBossCF < 8 and HALLOW.running do
                task.wait(0.5)
                waitBossCF = waitBossCF + 0.5
                bossCF = GetHalloweenBossCFrame()
            end

            if not bossCF then
                LogStatus("[!] Part 4035 tidak ditemukan, retry...", Color3.fromRGB(255, 100, 100))
                task.wait(2)
                continue
            end

            local bossPos = bossCF.Position
            -- Offset 20 studs di samping Boss (RightVector) + 2 studs di atas lantai, menghadap Boss
            local sidePos = (bossCF * CFrame.new(20, 2, 0)).Position
            local safePlayerCF = CFrame.lookAt(sidePos, bossPos)

            -- Teleport Player ke posisi 20 studs di samping boss
            pcall(function()
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = safePlayerCF end
            end)

            -- Equip & Teleport Heros
            local equippedHeros = GetEquippedHeroData()
            if #equippedHeros > 0 and RE.EquipHeroWithData and LP and LP.UserId then
                for _, h in ipairs(equippedHeros) do
                    pcall(function()
                        RE.EquipHeroWithData:FireServer({
                            heroGuid = h.guid,
                            userId = LP.UserId,
                            heroId = h.id,
                        })
                    end)
                end
            end

            pcall(function()
                local herosFolder = workspace:FindFirstChild("Heros")
                if herosFolder then
                    for _, h in ipairs(herosFolder:GetChildren()) do
                        local hHrp = h:FindFirstChild("HumanoidRootPart") or h.PrimaryPart
                        if hHrp then
                            hHrp.CFrame = bossCF * CFrame.new(math.random(-2, 2), 2, math.random(-2, 2))
                        end
                    end
                end
            end)

            if RE.HeroStand and LP and LP.UserId and #equippedHeros > 0 then
                for _, h in ipairs(equippedHeros) do
                    pcall(function()
                        RE.HeroStand:FireServer({
                            heroGuid = h.guid,
                            userId = LP.UserId,
                            standPos = bossPos,
                        })
                    end)
                end
            end

            -- Kunci posisi player 20 studs dari boss via Heartbeat
            local freezeFrame = 0
            local frozenCFrame = safePlayerCF
            pcall(function()
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = true
                    hrp.CFrame = frozenCFrame
                    if HALLOW._freezeConn then
                        pcall(function() HALLOW._freezeConn:Disconnect() end)
                        HALLOW._freezeConn = nil
                    end
                    HALLOW._freezeConn = RunService.Heartbeat:Connect(function()
                        freezeFrame = freezeFrame + 1
                        if freezeFrame % 2 ~= 0 then return end
                        if not HALLOW.running then
                            if hrp and hrp.Parent then hrp.Anchored = false end
                            if HALLOW._freezeConn then HALLOW._freezeConn:Disconnect(); HALLOW._freezeConn = nil end
                            return
                        end
                        if hrp and hrp.Parent and frozenCFrame then
                            hrp.CFrame = frozenCFrame
                        end
                    end)
                end
            end)

            -- Scan target entity JinWoo
            LogStatus("[..] Scanning Boss Monster...", Color3.fromRGB(255, 200, 60))
            local target = ScanHalloweenBoss(bossPos)
            local waitScan = 0
            while not target and waitScan < 10 and HALLOW.running do
                task.wait(0.5)
                waitScan = waitScan + 0.5
                target = ScanHalloweenBoss(bossPos)
            end

            if not target then
                LogStatus("[!] Boss belum spawn (timeout 10s), retry...", Color3.fromRGB(255, 100, 100))
                task.wait(2)
                continue
            end

            -- Jika target ditemukan, update posisi jarak 20 studs di samping target fisik
            if target.hrp then
                local tPos = target.hrp.Position
                local tSidePos = (target.hrp.CFrame * CFrame.new(20, 2, 0)).Position
                frozenCFrame = CFrame.lookAt(tSidePos, tPos)
            end

            --  STEP 3: Serang BOSS sampai mati (JANGAN AMBIL REWARD)
            local targetGuid = target.guid
            LogStatus("[RAPID ATK (20 studs)] " .. target.model.Name, Color3.fromRGB(255, 60, 40))

            local _raidServerSuccess = false
            local _raidServerFail = false
            local connS, connF
            if RE.ChallengeRaidsSuccess then
                connS = RE.ChallengeRaidsSuccess.OnClientEvent:Connect(function()
                    _raidServerSuccess = true
                end)
            end
            if RE.ChallengeRaidsFail then
                connF = RE.ChallengeRaidsFail.OnClientEvent:Connect(function()
                    _raidServerFail = true
                end)
            end

            local atkStart = tick()
            local attackCycles = 0
            local ATK_TIMEOUT = 90

            while HALLOW.running do
                if _raidServerSuccess then break end
                if _raidServerFail then break end
                if tick() - atkStart >= ATK_TIMEOUT then break end

                -- Cek eliminasi fisik boss
                if attackCycles >= 5 then
                    if not target.model or not target.model.Parent then
                        _raidServerSuccess = true
                        break
                    end
                    local hum = target.hum or (target.model:FindFirstChildOfClass("Humanoid"))
                    if hum and hum.Health <= 0 then
                        _raidServerSuccess = true
                        break
                    end
                end

                attackCycles = attackCycles + 1

                -- 1. Serangan jarak jauh Player
                if targetGuid then
                    if RE.Atk then
                        pcall(function() RE.Atk:FireServer({ attackEnemyGUID = targetGuid }) end)
                    end
                    if RE.Click then
                        task.spawn(function()
                            pcall(function() RE.Click:InvokeServer({ enemyGuid = targetGuid }) end)
                        end)
                    end
                    if RE.PlayerClickAttack then
                        pcall(function() RE.PlayerClickAttack:FireServer({ enemyGuid = targetGuid }) end)
                    end
                end

                -- 2. Serangan Heros (Skills 1, 2, 3)
                if targetGuid and #equippedHeros > 0 and RE.HeroUseSkill and LP and LP.UserId then
                    for _, h in ipairs(equippedHeros) do
                        for at = 1, 3 do
                            pcall(function()
                                RE.HeroUseSkill:FireServer({
                                    heroGuid = h.guid,
                                    attackType = at,
                                    userId = LP.UserId,
                                    enemyGuid = targetGuid,
                                    targetPos = bossPos,
                                })
                            end)
                        end
                    end
                end

                -- Reposisi heros di sekitar boss
                if attackCycles % 10 == 0 then
                    pcall(function()
                        local herosFolder = workspace:FindFirstChild("Heros")
                        if herosFolder then
                            for _, h in ipairs(herosFolder:GetChildren()) do
                                local hHrp = h:FindFirstChild("HumanoidRootPart") or h.PrimaryPart
                                if hHrp then
                                    hHrp.CFrame = bossCF * CFrame.new(math.random(-2, 2), 1, math.random(-2, 2))
                                end
                            end
                        end
                    end)
                end

                task.wait(0.05)
            end

            if connS then pcall(function() connS:Disconnect() end) end
            if connF then pcall(function() connF:Disconnect() end) end

            -- Player tetap terkunci di posisi 20 studs samping Boss (tidak unfreeze sebelum Map 1)
            -- untuk menjamin karakter TIDAK bergerak/menyentuh area tengah reward
            if not HALLOW.running then
                if HALLOW._freezeConn then
                    pcall(function() HALLOW._freezeConn:Disconnect() end)
                    HALLOW._freezeConn = nil
                end
                pcall(function()
                    local char = LP.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Anchored = false end
                end)
                break
            end

            -- Evaluasi hasil: NO REWARD CLAIM, tetap di samping 20 studs, langsung lanjut exit
            if not _raidServerSuccess then
                LogStatus("[FAIL] Boss belum tereliminasi - Keluar...", Color3.fromRGB(255, 80, 80))
            else
                HALLOW.sukses = HALLOW.sukses + 1
                LogCounter()
                LogStatus("[OK] Boss Mati! (Skip Reward, tetap di samping 20 studs)", Color3.fromRGB(100, 255, 150))
            end

            --  STEP 4: Exit / Keluar dari Map Halloween
            LogStatus("[..] Exiting Halloween -> Map 1...", Color3.fromRGB(200, 100, 100))
            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local UIManager = require(RS.Scripts.Client.Manager.UIManager)
                local pGui = LP:FindFirstChild("PlayerGui")
                if pGui and pGui:FindFirstChild("RewardPanel") and pGui.RewardPanel.Enabled then
                    local confBtn = pGui.RewardPanel:FindFirstChild("ButtonFrame") and pGui.RewardPanel.ButtonFrame:FindFirstChild("ConfirmButton")
                    if confBtn and confBtn.Visible and firesignal then firesignal(confBtn.MouseButton1Click) end
                end
                local rfpGui = pGui and pGui:FindFirstChild("RaidsFightPanel")
                if rfpGui and rfpGui.Enabled and rfpGui:FindFirstChild("SettlementFrame") and rfpGui.SettlementFrame.Visible then
                    local cBtn = rfpGui.SettlementFrame:FindFirstChild("CloseBtn")
                    if cBtn and cBtn.Visible and firesignal then firesignal(cBtn.MouseButton1Click) end
                end
                local rfp = UIManager.GetPanel and UIManager.GetPanel(UIManager.UIPanelName.RaidsFightPanel)
                if rfp and rfp.OnCloseBtnClick and rfp.settlementFrame and rfp.settlementFrame.Visible then
                    rfp:OnCloseBtnClick()
                else
                    local RM = require(RS.Scripts.Client.Manager.RaidsManager)
                    if RM and RM.QuitRaidMap then RM.QuitRaidMap() end
                end
            end)

            local exitTry = 0
            while HALLOW.running and exitTry < 10 do
                task.wait(0.5)
                exitTry = exitTry + 0.5
                local mid = GetCurrentMapId()
                local maps = workspace:FindFirstChild("Maps")
                local inMap1 = (mid == 50001) or (maps and maps:FindFirstChild("Map1") ~= nil and maps:FindFirstChild("2026HalloweenMap") == nil)
                if inMap1 then break end
            end

            -- Putus freeze connection dan pulihkan state player setelah konfirmasi kembali di Map 1
            if HALLOW._freezeConn then
                pcall(function() HALLOW._freezeConn:Disconnect() end)
                HALLOW._freezeConn = nil
            end

            -- Reset state player di Map 1
            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local PM = require(RS.Scripts.Client.Manager.PlayerManager)
                local MM = require(RS.Scripts.Client.Manager.MapManager)
                local RM = require(RS.Scripts.Client.Manager.RaidsManager)
                MM.isTeleportSuccess = true
                MM.isLoadFinish = true
                if RM then RM.raidsMapInfo = nil end
                if PM and PM.localPlayerData and PM.localPlayerData.activityRaidRewardCounts then
                    PM.localPlayerData.activityRaidRewardCounts["937102"] = 0
                end
                local pInst = PM.PlayerInstances and PM.PlayerInstances[LP.UserId]
                if pInst then pInst.isHeroCanMove = true end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end)

            if not HALLOW.running then break end

            --  STEP 5: Cooldown sebelum Masuk Kembali (Slider: 1 - 10 Detik)
            local cd = math.clamp(tonumber(HALLOW.delay) or 3, 1, 10)
            for s = cd, 1, -1 do
                if not HALLOW.running then break end
                LogStatus("[..] Cooldown next run: " .. s .. "s...", Color3.fromRGB(200, 200, 100))
                task.wait(1)
            end
        end
    end)
end

--  GLOBAL EXPORTS
_G.StartHalloween = StartHalloweenLoop
_G.StopHalloween  = StopHalloween
_G.HALLOW         = HALLOW

if getgenv then
    getgenv()._StartHalloweenLoop = StartHalloweenLoop
    getgenv()._StopHalloween      = StopHalloween
    getgenv()._HALLOW             = HALLOW
end

-- Initialize HUD & counter
CreateHalloweenHUD()
task.spawn(function()
    task.wait(1)
    LogCounter()
end)

print("[AUTO HALLOWEEN] Standalone siap. Anti-AFK aktif permanen. Tekan START di HUD untuk mulai.")
