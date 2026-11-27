-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ============================================================================
    ARISE SHADOW HUNT â AUTO CATCH DRAGON BALL AUTOMATION SUITE
    Engineered & Built with Rayfield Interface Suite (Replaced from WindUI)
    Author: By XLunaHUB
    Language: English
    Initial State: STRICTLY ALL OFF
    ============================================================================
--]]

-- Clean previous instance if re-executed
if getgenv()._XLUNA_DRAGONBALL_CLEANUP then
    pcall(getgenv()._XLUNA_DRAGONBALL_CLEANUP)
end

-- ==================== CORE SERVICES ====================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local LP = Players.LocalPlayer

-- Cleanup previous UI ScreenGuis if lingering in CoreGui or gethui
pcall(function()
    local cg = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    for _, name in ipairs({"WindUI", "Rayfield", "XLuna_DB_FloatingToggle"}) do
        if cg and cg:FindFirstChild(name) then
            cg[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then
            gethui()[name]:Destroy()
        end
        if LP and LP.PlayerGui and LP.PlayerGui:FindFirstChild(name) then
            LP.PlayerGui[name]:Destroy()
        end
    end
end)

-- ==================== LOAD RAYFIELD UI LIBRARY ====================
local Rayfield
local okRay, resRay = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if okRay and resRay then
    Rayfield = resRay
else
    Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
end

-- ==================== REMOTES & PROTOCOLS ====================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 20)
if not Remotes then
    warn("[XLunaHUB] Folder Remotes not found in ReplicatedStorage!")
end

local RE = {
    GetDragonBallSpawnState        = Remotes and Remotes:FindFirstChild("GetDragonBallSpawnState"),
    CollectDragonBall              = Remotes and Remotes:FindFirstChild("CollectDragonBall"),
    ClaimDragonBallMilestoneReward = Remotes and Remotes:FindFirstChild("ClaimDragonBallMilestoneReward"),
    UpgradeDragonBallBlessing      = Remotes and Remotes:FindFirstChild("UpgradeDragonBallBlessing"),
    StartLocalPlayerTeleport       = Remotes and Remotes:FindFirstChild("StartLocalPlayerTeleport"),
    UpdateDragonBallSpawn          = Remotes and Remotes:FindFirstChild("UpdateDragonBallSpawn"),
}

-- ==================== CONFIGURATION & STATE (DEFAULT: ALL OFF) ====================
local State = {
    -- Dragon Ball Automation (Default: ALL OFF)
    AutoCatchDragonBall = false,
    AutoReturnMap       = false,
    ReturnMapName       = "Map 1",
    SnatchDelay         = 0.25,
    AutoMilestones      = false,
    AutoBlessing        = false,

    -- Visuals (ESP)
    DragonBallESP       = false,

    -- Player & Utility
    AntiAFK             = false,
    Noclip              = false,
    WalkSpeedEnabled    = false,
    WalkSpeedValue      = 16,
}

local FEATURE_ID = 900001
local SPAWN_INTERVAL = 1200 -- 20 minutes
local SPAWN_LIFETIME = 900  -- 15 minutes

-- Map Name to ID translation table
local MAP_LOOKUP = {
    ["Map 1"]  = 50001,
    ["Map 2"]  = 50002,
    ["Map 3"]  = 50003,
    ["Map 4"]  = 50004,
    ["Map 5"]  = 50005,
    ["Map 6"]  = 50006,
    ["Map 7"]  = 50007,
    ["Map 8"]  = 50008,
    ["Map 9"]  = 50009,
    ["Map 10"] = 50010,
    ["Map 11"] = 50011,
    ["Map 12"] = 50012,
    ["Map 13"] = 50013,
    ["Map 14"] = 50014,
    ["Map 15"] = 50015,
    ["Map 16"] = 50016,
    ["Map 17"] = 50017,
    ["Map 18"] = 50018,
    ["Map 19"] = 50019,
    ["Map 20"] = 50020,
    ["Map 21"] = 50021,
    ["Map 22"] = 50022,
}

local MAP_NAMES = {
    "Map 1", "Map 2", "Map 3", "Map 4", "Map 5", "Map 6", "Map 7", "Map 8", "Map 9", "Map 10",
    "Map 11", "Map 12", "Map 13", "Map 14", "Map 15", "Map 16", "Map 17", "Map 18", "Map 19", "Map 20",
    "Map 21", "Map 22"
}

-- Runtime tracking
local Runtime = {
    CurrentRoundId   = 0,
    SpawnAt          = 0,
    ExpireAt         = 0,
    IsVisible        = false,
    RemainingBalls   = 0,
    StarCounts       = { ["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0, ["5"]=0, ["6"]=0, ["7"]=0 },
    StatusMessage    = "Idle / Waiting for instructions",
    IsHunting        = false,
    NextSpawnTime    = 0,
    MapRadarLines    = "No active balls (All collected / In standby)",
    ActiveSpawnMaps  = {},
}

-- ESP Storage
local EspCache = {}

-- Connections Storage for clean unloading
local Connections = {}

-- ==================== ANTI-AFK ENGINE ====================
local function SetupAntiAFK()
    local conn = LP.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
    table.insert(Connections, conn)

    task.spawn(function()
        while true do
            task.wait(45)
            if State.AntiAFK then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end)
            end
        end
    end)
end
SetupAntiAFK()

-- ==================== HELPER UTILITIES ====================
local function GetHrp()
    local char = LP.Character or LP.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function GetCurrentMapId()
    local ok1, mid1 = pcall(function()
        local MM = require(ReplicatedStorage.Scripts.Client.Manager.MapManager)
        if MM and MM.currentMapData and MM.currentMapData.mapSlotInfo then
            local mid = tonumber(MM.currentMapData.mapSlotInfo.mapId)
            if mid and mid > 0 then return mid end
        end
    end)
    if ok1 and mid1 then return mid1 end

    local mapsFolder = workspace:FindFirstChild("Maps")
    if mapsFolder then
        local child = mapsFolder:GetChildren()[1]
        if child and child.Name:match("^Map(%d+)$") then
            local idx = tonumber(child.Name:match("^Map(%d+)$"))
            if idx then return 50000 + idx end
        end
    end
    return 50001
end

local function TeleportToMap(targetMapId, timeout)
    timeout = timeout or 8
    local currentMid = GetCurrentMapId()
    if currentMid == targetMapId then
        return true
    end

    if RE.StartLocalPlayerTeleport then
        pcall(function()
            RE.StartLocalPlayerTeleport:FireServer({ mapId = targetMapId })
        end)
    end

    local t0 = os.clock()
    local mapIndex = targetMapId - 50000
    local targetName = "Map" .. mapIndex
    while os.clock() - t0 < timeout do
        task.wait(0.2)
        local maps = workspace:FindFirstChild("Maps")
        if maps and maps:FindFirstChild(targetName) then
            task.wait(0.6) -- wait for map pivot initialization
            return true
        end
    end
    return false
end

local function FetchSpawnSnapshot()
    if not RE.GetDragonBallSpawnState then return nil end
    local s, r = pcall(function()
        return RE.GetDragonBallSpawnState:InvokeServer(FEATURE_ID)
    end)
    if s and typeof(r) == "table" and r.success == true then
        Runtime.CurrentRoundId = r.roundId or 0
        Runtime.SpawnAt = r.spawnAt or 0
        Runtime.ExpireAt = r.expireAt or 0
        Runtime.IsVisible = r.isVisible or false
        Runtime.RemainingBalls = r.entries and #r.entries or 0
        Runtime.StarCounts = r.counts or Runtime.StarCounts
        Runtime.NextSpawnTime = (r.spawnAt or 0) + SPAWN_INTERVAL

        -- Compute Map Distribution Radar
        local mapGroups = {}
        local activeMaps = {}
        for _, entry in ipairs(r.entries or {}) do
            local mid = entry.mapId
            local mapIndex = mid - 50000
            local mapName = "Map " .. tostring(mapIndex)
            if not mapGroups[mapName] then
                mapGroups[mapName] = {}
                table.insert(activeMaps, mapName)
            end
            table.insert(mapGroups[mapName], "â­" .. tostring(entry.starId))
        end

        local radarLines = {}
        local sortedMapNames = {}
        for mName in pairs(mapGroups) do
            table.insert(sortedMapNames, mName)
        end
        table.sort(sortedMapNames, function(a, b)
            local numA = tonumber(a:match("%d+")) or 0
            local numB = tonumber(b:match("%d+")) or 0
            return numA < numB
        end)

        for _, mName in ipairs(sortedMapNames) do
            local stars = mapGroups[mName]
            table.insert(radarLines, string.format("ðºï¸ %s: %d Balls (%s)", mName, #stars, table.concat(stars, ", ")))
        end

        if #radarLines > 0 then
            Runtime.MapRadarLines = table.concat(radarLines, "\n")
        else
            Runtime.MapRadarLines = "No active balls (All collected / In standby)"
        end
        Runtime.ActiveSpawnMaps = activeMaps

        return r
    end
    return nil
end

-- ==================== ESP ENGINE ====================
local function ClearAllESP()
    for model, espData in pairs(EspCache) do
        if espData.Billboard then pcall(function() espData.Billboard:Destroy() end) end
        if espData.Highlight then pcall(function() espData.Highlight:Destroy() end) end
    end
    table.clear(EspCache)
end

local function UpdateESP()
    if not State.DragonBallESP then
        ClearAllESP()
        return
    end

    local mapsFolder = workspace:FindFirstChild("Maps")
    local curMap = mapsFolder and mapsFolder:GetChildren()[1]
    local dbFolder = curMap and curMap:FindFirstChild("DragonBallSpawn_" .. FEATURE_ID)

    if not dbFolder then
        ClearAllESP()
        return
    end

    local activeModels = {}
    local hrp = GetHrp()
    local myPos = hrp and hrp.Position or Vector3.zero

    for _, ballModel in ipairs(dbFolder:GetChildren()) do
        if ballModel:IsA("Model") then
            activeModels[ballModel] = true
            local starId = ballModel:GetAttribute("StarId") or "?"
            local slotId = ballModel:GetAttribute("SlotId") or "?"
            local pivot = ballModel:GetPivot()
            local dist = math.floor((pivot.Position - myPos).Magnitude)

            local cached = EspCache[ballModel]
            if not cached then
                local bb = Instance.new("BillboardGui")
                bb.Name = "XLuna_DB_ESP"
                bb.Size = UDim2.new(0, 160, 0, 44)
                bb.AlwaysOnTop = true
                bb.ExtentsOffset = Vector3.new(0, 2.5, 0)

                local title = Instance.new("TextLabel")
                title.Name = "StarLabel"
                title.Size = UDim2.new(1, 0, 0.5, 0)
                title.BackgroundTransparency = 1
                title.Font = Enum.Font.GothamBold
                title.TextSize = 14
                title.TextColor3 = Color3.fromRGB(255, 215, 0)
                title.TextStrokeTransparency = 0.2
                title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                title.Text = "â­ [" .. tostring(starId) .. "-Star DB]"
                title.Parent = bb

                local distLabel = Instance.new("TextLabel")
                distLabel.Name = "DistLabel"
                distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                distLabel.BackgroundTransparency = 1
                distLabel.Font = Enum.Font.GothamMedium
                distLabel.TextSize = 12
                distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                distLabel.TextStrokeTransparency = 0.3
                distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                distLabel.Text = tostring(dist) .. " studs"
                distLabel.Parent = bb

                local hl = Instance.new("Highlight")
                hl.Name = "XLuna_DB_Highlight"
                hl.FillColor = Color3.fromRGB(255, 170, 0)
                hl.FillTransparency = 0.4
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0.1
                hl.Adornee = ballModel
                hl.Parent = ballModel

                local basePart = ballModel:FindFirstChildWhichIsA("BasePart", true)
                if basePart then
                    bb.Adornee = basePart
                    bb.Parent = basePart
                else
                    bb.Adornee = ballModel
                    bb.Parent = ballModel
                end

                EspCache[ballModel] = {
                    Billboard = bb,
                    Highlight = hl,
                    DistLabel = distLabel,
                    TitleLabel = title
                }
            else
                if cached.DistLabel then
                    cached.DistLabel.Text = tostring(dist) .. " studs"
                end
            end
        end
    end

    -- Remove stale ESP
    for model, espData in pairs(EspCache) do
        if not activeModels[model] or not model.Parent then
            if espData.Billboard then pcall(function() espData.Billboard:Destroy() end) end
            if espData.Highlight then pcall(function() espData.Highlight:Destroy() end) end
            EspCache[model] = nil
        end
    end
end

-- ==================== AUTO SNATCH ENGINE ====================
local function ExecuteDragonBallSweep(targetEntries, roundId)
    if not targetEntries or #targetEntries == 0 then return end
    Runtime.IsHunting = true

    -- Group entries by mapId
    local mapGroups = {}
    for _, entry in ipairs(targetEntries) do
        local mid = entry.mapId
        if not mapGroups[mid] then
            mapGroups[mid] = {}
        end
        table.insert(mapGroups[mid], entry)
    end

    local initialMapId = GetCurrentMapId()

    for targetMapId, entries in pairs(mapGroups) do
        if not State.AutoCatchDragonBall then break end

        local mapIndex = targetMapId - 50000
        Runtime.StatusMessage = "Teleporting to Map " .. tostring(mapIndex) .. "..."
        local ok = TeleportToMap(targetMapId, 8)
        if not ok then
            Runtime.StatusMessage = "Failed teleporting to Map " .. tostring(mapIndex) .. ", skipping..."
            task.wait(1)
            continue
        end

        local mapInst = workspace.Maps:FindFirstChild("Map" .. tostring(mapIndex))
        if not mapInst then
            task.wait(1)
            mapInst = workspace.Maps:FindFirstChild("Map" .. tostring(mapIndex))
        end

        if not mapInst then continue end

        local pivot = mapInst:GetPivot()

        for _, ballEntry in ipairs(entries) do
            if not State.AutoCatchDragonBall then break end

            local localVec = Vector3.new(ballEntry.x, ballEntry.y, ballEntry.z)
            local worldPos = pivot:PointToWorldSpace(localVec)

            Runtime.StatusMessage = "Snatching â­" .. tostring(ballEntry.starId) .. " (Slot " .. tostring(ballEntry.slotId) .. ") on Map " .. tostring(mapIndex)

            local hrp = GetHrp()
            if hrp then
                -- Position player right above ball coordinates with zero velocity
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(worldPos + Vector3.new(0, 1.8, 0))
                task.wait(State.SnatchDelay)

                if RE.CollectDragonBall then
                    local s, res = pcall(function()
                        return RE.CollectDragonBall:InvokeServer({
                            featureId = FEATURE_ID,
                            roundId   = roundId,
                            slotId    = ballEntry.slotId
                        })
                    end)

                    if s and typeof(res) == "table" and res.success == true then
                        Runtime.StatusMessage = "Successfully Snatched â­" .. tostring(ballEntry.starId) .. "!"
                        if res.snapshot and res.snapshot.counts then
                            Runtime.StarCounts = res.snapshot.counts
                        end
                    end
                end
                task.wait(State.SnatchDelay)
            end
        end
    end

    -- Return to ReturnMap if configured
    if State.AutoReturnMap and State.AutoCatchDragonBall then
        local returnMid = MAP_LOOKUP[State.ReturnMapName] or initialMapId or 50001
        local retIndex = returnMid - 50000
        Runtime.StatusMessage = "Returning to Map " .. tostring(retIndex) .. "..."
        TeleportToMap(returnMid, 8)
    end

    Runtime.IsHunting = false
    FetchSpawnSnapshot()
end

-- ==================== AUTO MILESTONES & BLESSINGS ====================
local function ProcessMilestonesAndBlessings(snapshot)
    if not snapshot then return end

    -- 1. Auto Claim Milestones
    if State.AutoMilestones and RE.ClaimDragonBallMilestoneReward then
        local milestones = snapshot.milestones
        if milestones and milestones.hasPending == true and milestones.rows then
            for _, row in ipairs(milestones.rows) do
                if typeof(row) == "table" and row.isPending == true and row.Id then
                    pcall(function()
                        RE.ClaimDragonBallMilestoneReward:InvokeServer({
                            featureId = FEATURE_ID,
                            id        = row.Id
                        })
                    end)
                    task.wait(0.3)
                end
            end
        end
    end

    -- 2. Auto Upgrade Blessings
    if State.AutoBlessing and RE.UpgradeDragonBallBlessing then
        local ok, PM = pcall(function() return require(ReplicatedStorage.Scripts.Client.Manager.PlayerManager) end)
        if ok and PM and PM.localPlayerData and PM.localPlayerData.dragonBallBlessings then
            local blessings = PM.localPlayerData.dragonBallBlessings
            local rev = blessings.revision or 0
            -- Cycle blessing types 1 through 6
            for bType = 1, 6 do
                pcall(function()
                    RE.UpgradeDragonBallBlessing:InvokeServer({
                        blessingType = bType,
                        revision     = rev
                    })
                end)
                task.wait(0.25)
            end
        end
    end
end

-- ==================== RAYFIELD INTERFACE INITIALIZATION ====================
local Window = Rayfield:CreateWindow({
    Name = "Arise Shadow Hunt",
    Icon = 0,
    LoadingTitle = "Arise Shadow Hunt",
    LoadingSubtitle = "by XLunaHUB",
    Theme = "AmberGlow",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "XLuna_AriseShadowHunt",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- LeftControl Keybind Toggle (Debounced single-handler to guarantee never simultaneous HIDE/SHOW)
local isToggling = false
local function ToggleInterface()
    if isToggling then return end
    isToggling = true
    pcall(function()
        local sg = CoreGui:FindFirstChild("Rayfield") or (gethui and gethui():FindFirstChild("Rayfield")) or LP.PlayerGui:FindFirstChild("Rayfield")
        if sg then
            local main = sg:FindFirstChild("Main")
            if main then
                main.Visible = not main.Visible
            else
                sg.Enabled = not sg.Enabled
            end
        end
    end)
    task.delay(0.25, function()
        isToggling = false
    end)
end

local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleInterface()
    end
end)
table.insert(Connections, keybindConn)

-- Standalone Draggable Floating Action Button
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "XLuna_DB_FloatingToggle"
floatGui.ResetOnSpawn = false
pcall(function()
    if gethui then
        floatGui.Parent = gethui()
    else
        floatGui.Parent = LP:WaitForChild("PlayerGui")
    end
end)

local floatBtn = Instance.new("TextButton")
floatBtn.Name = "ToggleBtn"
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 20, 0.45, 0)
floatBtn.BackgroundColor3 = Color3.fromRGB(24, 20, 30)
floatBtn.Text = "ð"
floatBtn.TextSize = 26
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.AutoButtonColor = true
floatBtn.Parent = floatGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 25)
btnCorner.Parent = floatBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 150, 0)
btnStroke.Thickness = 2
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Parent = floatBtn

do
    local dragging, dragInput, dragStart, startPos
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    floatBtn.MouseButton1Click:Connect(function()
        ToggleInterface()
    end)
end

-- ==================== UI TABS ====================
local TabDragonBall = Window:CreateTab("Dragon Ball", 4483362458)
local TabVisuals    = Window:CreateTab("Visuals (ESP)", 4483362458)
local TabPlayer     = Window:CreateTab("Player & Move", 4483362458)
local TabConfig     = Window:CreateTab("Configuration", 4483362458)

-- ==================== TAB 1: DRAGON BALL ====================
TabDragonBall:CreateSection("Live Telemetry & Event Status")

local StatusPara = TabDragonBall:CreateParagraph({
    Title = "Event Radar Status",
    Content = "Status: Initializing telemetry..."
})

local MapRadarPara = TabDragonBall:CreateParagraph({
    Title = "Active Spawn Maps Radar",
    Content = "Scanning server for active spawn maps..."
})

local StarsPara = TabDragonBall:CreateParagraph({
    Title = "Collected Dragon Ball Inventory",
    Content = "â­1: 0 | â­2: 0 | â­3: 0 | â­4: 0 | â­5: 0 | â­6: 0 | â­7: 0"
})

TabDragonBall:CreateButton({
    Name = "Show Active Spawn Maps (Popup)",
    Callback = function()
        FetchSpawnSnapshot()
        Rayfield:Notify({
            Title = "Dragon Ball Map Radar",
            Content = Runtime.MapRadarLines,
            Duration = 5
        })
    end
})

TabDragonBall:CreateButton({
    Name = "Refresh Event Snapshot",
    Callback = function()
        local snap = FetchSpawnSnapshot()
        if snap then
            Rayfield:Notify({Title = "Snapshot Updated", Content = "Found " .. tostring(Runtime.RemainingBalls) .. " active Dragon Balls.", Duration = 2.5})
        else
            Rayfield:Notify({Title = "Snapshot Failed", Content = "Could not fetch state from server.", Duration = 2.5})
        end
    end
})

TabDragonBall:CreateSection("Autonomous Multi-Map Hopper")

local ToggleAutoCatch = TabDragonBall:CreateToggle({
    Name = "Auto Catch Dragon Ball",
    CurrentValue = false,
    Flag = "AutoCatchDragonBall",
    Callback = function(val)
        State.AutoCatchDragonBall = val
        if val then
            Rayfield:Notify({Title = "Auto Catch Activated", Content = "Monitoring spawn rounds across all maps...", Duration = 3})
        else
            Runtime.StatusMessage = "Auto Catch stopped."
        end
    end
})

local ToggleAutoReturn = TabDragonBall:CreateToggle({
    Name = "Auto Return to Base Map",
    CurrentValue = false,
    Flag = "AutoReturnMap",
    Callback = function(val)
        State.AutoReturnMap = val
    end
})

local DropdownReturnMap = TabDragonBall:CreateDropdown({
    Name = "Base Map Selection",
    Options = MAP_NAMES,
    CurrentOption = {"Map 1"},
    MultipleOptions = false,
    Flag = "BaseMapSelection",
    Callback = function(val)
        local selected = typeof(val) == "table" and val[1] or val
        State.ReturnMapName = selected
    end
})

local SliderSnatchDelay = TabDragonBall:CreateSlider({
    Name = "Snatch Delay (Replication Buffer)",
    Range = {0.15, 1.0},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.25,
    Flag = "SnatchDelay",
    Callback = function(val)
        State.SnatchDelay = val
    end
})

TabDragonBall:CreateButton({
    Name = "Quick Catch Active Balls (1-Time Sweep)",
    Callback = function()
        task.spawn(function()
            local snap = FetchSpawnSnapshot()
            if snap and snap.entries and #snap.entries > 0 then
                Rayfield:Notify({Title = "Manual Sweep Started", Content = "Snatching " .. tostring(#snap.entries) .. " Dragon Balls...", Duration = 3})
                ExecuteDragonBallSweep(snap.entries, snap.roundId)
                Rayfield:Notify({Title = "Manual Sweep Finished", Content = "All available balls processed.", Duration = 3})
            else
                Rayfield:Notify({Title = "No Active Balls", Content = "No uncollected Dragon Balls found in this round.", Duration = 3})
            end
        end)
    end
})

TabDragonBall:CreateSection("Blessing & Milestone Rewards")

local ToggleAutoMilestones = TabDragonBall:CreateToggle({
    Name = "Auto Claim Milestone Rewards",
    CurrentValue = false,
    Flag = "AutoMilestones",
    Callback = function(val)
        State.AutoMilestones = val
    end
})

local ToggleAutoBlessing = TabDragonBall:CreateToggle({
    Name = "Auto Upgrade Dragon Ball Blessing",
    CurrentValue = false,
    Flag = "AutoBlessing",
    Callback = function(val)
        State.AutoBlessing = val
    end
})

-- ==================== TAB 2: VISUALS (ESP) ====================
TabVisuals:CreateSection("World Spatial Overlays")

local ToggleESP = TabVisuals:CreateToggle({
    Name = "Dragon Ball 3D ESP",
    CurrentValue = false,
    Flag = "DragonBallESP",
    Callback = function(val)
        State.DragonBallESP = val
        if not val then
            ClearAllESP()
        end
    end
})

-- ==================== TAB 3: PLAYER & UTILITY ====================
TabPlayer:CreateSection("Safety & Movement Utilities")

local ToggleAntiAFK = TabPlayer:CreateToggle({
    Name = "Anti-AFK (Anti-Idle Engine)",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(val)
        State.AntiAFK = val
    end
})

local ToggleNoclip = TabPlayer:CreateToggle({
    Name = "Noclip Mode",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(val)
        State.Noclip = val
    end
})

local noclipConn = RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end
end)
table.insert(Connections, noclipConn)

local ToggleSpeed = TabPlayer:CreateToggle({
    Name = "Speed Modification",
    CurrentValue = false,
    Flag = "WalkSpeedEnabled",
    Callback = function(val)
        State.WalkSpeedEnabled = val
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and not val then
            hum.WalkSpeed = 16
        end
    end
})

local SliderSpeed = TabPlayer:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 150},
    Increment = 2,
    Suffix = " studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeedValue",
    Callback = function(val)
        State.WalkSpeedValue = val
        if State.WalkSpeedEnabled then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    end
})

local speedConn = RunService.Heartbeat:Connect(function()
    if State.WalkSpeedEnabled then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= State.WalkSpeedValue then
            hum.WalkSpeed = State.WalkSpeedValue
        end
    end
end)
table.insert(Connections, speedConn)

-- ==================== TAB 4: CONFIGURATION ====================
TabConfig:CreateSection("Profile Persistence")

local ConfigFolder = "XLuna_AriseConfigs"
pcall(function()
    if makefolder then makefolder(ConfigFolder) end
end)

local function GetConfigList()
    local list = {}
    pcall(function()
        if listfiles then
            for _, f in ipairs(listfiles(ConfigFolder)) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end)
    if #list == 0 then table.insert(list, "default") end
    return list
end

local activeConfigProfile = "default"

local DropdownProfile = TabConfig:CreateDropdown({
    Name = "Select Profile",
    Options = GetConfigList(),
    CurrentOption = {"default"},
    MultipleOptions = false,
    Flag = "SelectProfile",
    Callback = function(val)
        local selected = typeof(val) == "table" and val[1] or val
        activeConfigProfile = selected
    end
})

TabConfig:CreateInput({
    Name = "New Profile Name",
    PlaceholderText = "e.g. dragonball_farm",
    RemoveTextAfterFocusLost = false,
    Callback = function(val)
        if val and val ~= "" then
            activeConfigProfile = val
        end
    end
})

TabConfig:CreateButton({
    Name = "Save Profile",
    Callback = function()
        pcall(function()
            if writefile then
                local json = HttpService:JSONEncode(State)
                writefile(ConfigFolder .. "/" .. activeConfigProfile .. ".json", json)
                if DropdownProfile and DropdownProfile.Refresh then
                    DropdownProfile:Refresh(GetConfigList())
                end
                Rayfield:Notify({Title = "Config Saved", Content = "Saved profile: " .. activeConfigProfile, Duration = 2.5})
            end
        end)
    end
})

TabConfig:CreateButton({
    Name = "Load Profile",
    Callback = function()
        pcall(function()
            local path = ConfigFolder .. "/" .. activeConfigProfile .. ".json"
            if isfile and isfile(path) then
                local raw = readfile(path)
                local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
                if ok and type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        if State[k] ~= nil then
                            State[k] = v
                        end
                    end
                    pcall(function()
                        if ToggleAutoCatch and ToggleAutoCatch.Set then ToggleAutoCatch:Set(State.AutoCatchDragonBall) end
                        if ToggleAutoReturn and ToggleAutoReturn.Set then ToggleAutoReturn:Set(State.AutoReturnMap) end
                        if DropdownReturnMap and DropdownReturnMap.Set then DropdownReturnMap:Set({State.ReturnMapName}) end
                        if SliderSnatchDelay and SliderSnatchDelay.Set then SliderSnatchDelay:Set(State.SnatchDelay) end
                        if ToggleAutoMilestones and ToggleAutoMilestones.Set then ToggleAutoMilestones:Set(State.AutoMilestones) end
                        if ToggleAutoBlessing and ToggleAutoBlessing.Set then ToggleAutoBlessing:Set(State.AutoBlessing) end
                        if ToggleESP and ToggleESP.Set then ToggleESP:Set(State.DragonBallESP) end
                        if ToggleAntiAFK and ToggleAntiAFK.Set then ToggleAntiAFK:Set(State.AntiAFK) end
                        if ToggleNoclip and ToggleNoclip.Set then ToggleNoclip:Set(State.Noclip) end
                        if ToggleSpeed and ToggleSpeed.Set then ToggleSpeed:Set(State.WalkSpeedEnabled) end
                        if SliderSpeed and SliderSpeed.Set then SliderSpeed:Set(State.WalkSpeedValue) end
                    end)
                    Rayfield:Notify({Title = "Config Loaded", Content = "Profile '" .. activeConfigProfile .. "' loaded successfully.", Duration = 2.5})
                end
            else
                Rayfield:Notify({Title = "Profile Missing", Content = "No file found at: " .. path, Duration = 2.5})
            end
        end)
    end
})

TabConfig:CreateButton({
    Name = "Reset to Default (ALL OFF)",
    Callback = function()
        for k, v in pairs(State) do
            if type(v) == "boolean" then
                State[k] = false
            end
        end
        ClearAllESP()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        pcall(function()
            if ToggleAutoCatch and ToggleAutoCatch.Set then ToggleAutoCatch:Set(false) end
            if ToggleAutoReturn and ToggleAutoReturn.Set then ToggleAutoReturn:Set(false) end
            if ToggleAutoMilestones and ToggleAutoMilestones.Set then ToggleAutoMilestones:Set(false) end
            if ToggleAutoBlessing and ToggleAutoBlessing.Set then ToggleAutoBlessing:Set(false) end
            if ToggleESP and ToggleESP.Set then ToggleESP:Set(false) end
            if ToggleAntiAFK and ToggleAntiAFK.Set then ToggleAntiAFK:Set(false) end
            if ToggleNoclip and ToggleNoclip.Set then ToggleNoclip:Set(false) end
            if ToggleSpeed and ToggleSpeed.Set then ToggleSpeed:Set(false) end
        end)
        Rayfield:Notify({Title = "Config Reset", Content = "All features restored to OFF.", Duration = 2.5})
    end
})

-- ==================== BACKGROUND DAEMON & TELEMETRY ====================
local lastTelemetryPoll = 0

task.spawn(function()
    while true do
        task.wait(1)

        local now = workspace:GetServerTimeNow()

        -- Periodic poll to keep Radar & Telemetry always live (every 3s or when new round starts)
        if (os.clock() - lastTelemetryPoll >= 3 or now >= Runtime.NextSpawnTime) and not Runtime.IsHunting then
            lastTelemetryPoll = os.clock()
            FetchSpawnSnapshot()
        end

        local nextSpawnSec = math.max(0, math.ceil(Runtime.NextSpawnTime - now))
        local expireSec = math.max(0, math.ceil(Runtime.ExpireAt - now))

        local minNext = math.floor(nextSpawnSec / 60)
        local secNext = nextSpawnSec % 60
        local minExp = math.floor(expireSec / 60)
        local secExp = expireSec % 60

        local countdownStr = string.format("%02d:%02d", minNext, secNext)
        local expStr = string.format("%02d:%02d", minExp, secExp)

        local statusText = ""
        if Runtime.IsHunting then
            statusText = "[ACTIVE HUNT] " .. Runtime.StatusMessage
        elseif Runtime.RemainingBalls > 0 and expireSec > 0 then
            statusText = string.format("Round %d Active | %d Balls Left (Despawns in %s)", Runtime.CurrentRoundId, Runtime.RemainingBalls, expStr)
        else
            statusText = string.format("Round %d Concluded | Next Round in: %s", Runtime.CurrentRoundId, countdownStr)
        end

        pcall(function()
            StatusPara:Set({
                Title = "Event Radar Status",
                Content = statusText
            })
            MapRadarPara:Set({
                Title = "Active Spawn Maps Radar",
                Content = Runtime.MapRadarLines
            })
            local c = Runtime.StarCounts
            StarsPara:Set({
                Title = "Collected Dragon Ball Inventory",
                Content = string.format("â­1: %d | â­2: %d | â­3: %d | â­4: %d | â­5: %d | â­6: %d | â­7: %d",
                    c["1"] or 0, c["2"] or 0, c["3"] or 0, c["4"] or 0, c["5"] or 0, c["6"] or 0, c["7"] or 0)
            })
        end)

        -- 2. ESP Updates
        pcall(UpdateESP)

        -- 3. Autonomous Hunting Loop
        if State.AutoCatchDragonBall and not Runtime.IsHunting then
            local snapshot = FetchSpawnSnapshot()
            if snapshot and snapshot.isVisible and snapshot.entries and #snapshot.entries > 0 then
                if now < (snapshot.expireAt or 0) then
                    ExecuteDragonBallSweep(snapshot.entries, snapshot.roundId)
                end
            end

            -- Process milestones and blessings
            if snapshot then
                ProcessMilestonesAndBlessings(snapshot)
            end
        end
    end
end)

-- Server Event Broadcast Listener
if RE.UpdateDragonBallSpawn then
    local evConn = RE.UpdateDragonBallSpawn.OnClientEvent:Connect(function(snap)
        if typeof(snap) == "table" and snap.success == true then
            Runtime.CurrentRoundId = snap.roundId or Runtime.CurrentRoundId
            Runtime.SpawnAt = snap.spawnAt or Runtime.SpawnAt
            Runtime.ExpireAt = snap.expireAt or Runtime.ExpireAt
            Runtime.IsVisible = snap.isVisible or false
            Runtime.RemainingBalls = snap.entries and #snap.entries or 0
            Runtime.StarCounts = snap.counts or Runtime.StarCounts
            Runtime.NextSpawnTime = (snap.spawnAt or 0) + SPAWN_INTERVAL
            pcall(UpdateESP)
        end
    end)
    table.insert(Connections, evConn)
end

-- ==================== CLEANUP REGISTRATION ====================
getgenv()._XLUNA_DRAGONBALL_CLEANUP = function()
    ClearAllESP()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if floatGui then
        pcall(function() floatGui:Destroy() end)
    end
    pcall(function() Rayfield:Destroy() end)
end

-- Initial snapshot fetch
task.spawn(function()
    task.wait(0.5)
    FetchSpawnSnapshot()
    pcall(UpdateESP)
end)

Rayfield:Notify({
    Title = "XLunaHUB Activated",
    Content = "Dragon Ball Suite loaded. All features default to OFF.",
    Duration = 3.5
})
