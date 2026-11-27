-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB | +1 Crush The Floor!
    Author: By XLunaHUB
    Framework: WindUI
]]

if getgenv and getgenv().XLunaHUB_CTF_Cleanup then
    pcall(getgenv().XLunaHUB_CTF_Cleanup)
end

local function ensureIdentity()
    if setthreadidentity then
        pcall(setthreadidentity, 8)
    end
end

ensureIdentity()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Game Modules (wrap identity after requiring)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ConfigFolder = Shared:WaitForChild("Config")
local UtilityFolder = Shared:WaitForChild("Utility")
local ControllersFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ControllerLoader")

local ZoneConfig = require(ConfigFolder:WaitForChild("ZoneConfig"))
local MineConfig = require(ConfigFolder:WaitForChild("MineConfig"))
local LootConfig = require(ConfigFolder:WaitForChild("LootConfig"))
local FoodConfig = require(ConfigFolder:WaitForChild("FoodConfig"))
local UpgradesConfig = require(ConfigFolder:WaitForChild("UpgradesConfig"))
local RebirthConfig = require(ConfigFolder:WaitForChild("RebirthConfig"))
local TrainingConfig = require(ConfigFolder:WaitForChild("TrainingConfig"))
local PetsConfig = require(ConfigFolder:WaitForChild("PetsConfig"))
local FuseConfig = require(ConfigFolder:WaitForChild("FuseConfig"))
local DailyRewardConfig = require(ConfigFolder:WaitForChild("DailyRewardConfig"))
local OfflineConfig = require(ConfigFolder:WaitForChild("OfflineConfig"))
local WeeklyChallengeConfig = require(ConfigFolder:WaitForChild("WeeklyChallengeConfig"))
local SpecialBlocksConfig = require(ConfigFolder:WaitForChild("SpecialBlocksConfig"))

local RemotesUtil = require(UtilityFolder:WaitForChild("Remotes"))
local MoneyFormat = require(UtilityFolder:WaitForChild("MoneyFormat"))
local Levels = require(UtilityFolder:WaitForChild("Levels"))
local UpgradeMath = require(UtilityFolder:WaitForChild("UpgradeMath"))
local ZoneLuck = require(UtilityFolder:WaitForChild("ZoneLuck"))
local TrainingPads = require(UtilityFolder:WaitForChild("TrainingPads"))
local QuickTeleport = require(UtilityFolder:WaitForChild("QuickTeleport"))
local BlockGrid = require(UtilityFolder:WaitForChild("BlockGrid"))
local MineField = require(UtilityFolder:WaitForChild("MineField"))
local SecretSpawns = require(UtilityFolder:WaitForChild("SecretSpawns"))

local MineFieldController = require(ControllersFolder:WaitForChild("MineFieldController"))
local HatchEggController = require(ControllersFolder:WaitForChild("HatchEggController"))

ensureIdentity()

-- Remotes
local RemotesFolder = Shared:WaitForChild("Remotes")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")

local function getRemote(parent, name)
    return parent:FindFirstChild(name)
end

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
ensureIdentity()

-- Global Runtime State (ALL TOGGLES STRICTLY OFF BY DEFAULT)
local State = {
    Running = true,
    AutoEat = false,
    AutoTrain = false,
    TargetTrainPad = "Auto Best",
    AutoEquipFood = false,

    AutoMine = false,
    TargetMineZone = "Auto Highest",
    SlamPriority = "Smart Value",
    AutoInstantLoot = false,
    AutoSellOres = false,
    AutoSellMinOres = 10,
    AutoRejoinMine = false,

    AutoBuyFood = false,
    AutoEquipBestFood = false,
    AutoBuyUpgrades = false,
    UpgradeTargets = { "ExtraJumps", "WalkSpeed", "MagnetRadius", "CrushRadius" },
    AutoBuyZone = false,
    AutoBuyZoneLuck = false,
    AutoRebirth = false,

    AutoHatchEgg = false,
    EggZone = "Auto Highest",
    SkipHatchAnim = false,
    AutoEquipBestPets = false,
    AutoFusePets = false,
    AutoSellWeakPets = false,
    AutoSellRarities = { "Rare" },

    AutoBlueOres = false,
    AutoEggRain = false,
    AutoClaimRewards = false,
    AutoTitanJump = false,
    SecretEsp = false,

    CustomWalkSpeed = false,
    WalkSpeedValue = 50,
    CustomJumpHeight = false,
    JumpHeightValue = 40,
    InfiniteJump = false,
    NoClip = false,
    RemoveBarriers = false,
    AntiAfk = false,

    SelectedTeleportZone = "Zone 1 - Forest",
    SelectedShopLocation = "Sell Shop",
    ConfigName = "default",
}

local Connections = {}
local EspFolder = nil
local FloatingGui = nil
local PendingLootIds = {}
local BrokenConn = nil

local function trackConn(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function getChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hum.Health > 0 and hrp and hrp:IsA("BasePart") then
        return char, hum, hrp
    end
    return char, hum, hrp
end

local function safeNum(attrName, fallback)
    local v = tonumber(LocalPlayer:GetAttribute(attrName))
    if v and v == v then
        return v
    end
    return fallback or 0
end

local function parseZoneChoice(choice)
    if not choice or choice == "Auto Highest" then
        return ZoneConfig.HighestOf(LocalPlayer)
    end
    local idx = tonumber(tostring(choice):match("Zone%s*(%d+)"))
    if idx and ZoneConfig.Get(idx) then
        return math.min(idx, ZoneConfig.HighestOf(LocalPlayer))
    end
    return ZoneConfig.HighestOf(LocalPlayer)
end

local function ownedSet(attrName)
    local set = {}
    local raw = LocalPlayer:GetAttribute(attrName)
    if type(raw) == "string" then
        for token in raw:gmatch("[^,]+") do
            set[token] = true
        end
    end
    return set
end

local function jsonDecodeSafe(raw, fallback)
    if type(raw) ~= "string" or raw == "" then
        return fallback
    end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok and type(decoded) == "table" then
        return decoded
    end
    return fallback
end

local function equipFoodTool()
    local char, hum = getChar()
    if not char or not hum or hum.Health <= 0 then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute(FoodConfig.ToolAttribute) ~= nil then
            return true
        end
    end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute(FoodConfig.ToolAttribute) ~= nil then
                hum:EquipTool(child)
                return true
            end
        end
    end
    return false
end

local function getMineFieldsTable()
    local ok, tbl = pcall(debug.getupvalue, MineFieldController.Slam, 1)
    if ok and type(tbl) == "table" then
        return tbl
    end
    return nil
end

local function getMineCatalogues()
    local ok, cats = pcall(MineFieldController.Catalogues)
    if ok and type(cats) == "table" then
        return cats
    end
    return {}
end

local function tierScore(zone, kind, catalogues)
    if not kind then return 0 end
    if kind == "Eggore" then return 500000 end
    local ore = MineField.OreOf(catalogues, zone, kind)
    local tier = ore and ore.Tier or 1
    if tier == 6 then return 1000000 end -- Secret
    if tier == 5 then return 25000 end   -- Mythic
    if tier == 4 then return 4000 end    -- Legendary
    if tier == 3 then return 600 end     -- Rare
    if tier == 2 then return 100 end     -- Uncommon
    return 15                            -- Common
end

local function pickSlamTarget(zone, priority)
    local fields = getMineFieldsTable()
    local field = fields and fields[zone]
    local data = field and field.Data
    if not data or not data.Grid then
        local center = MineFieldController.CenterOf(zone)
        if center then
            local gy = MineFieldController.GroundAt(center + Vector3.new(0, 60, 0))
            return Vector3.new(center.X, gy or center.Y, center.Z)
        end
        return nil
    end

    local grid = data.Grid
    local counts = grid.Counts
    if priority == "Center Drill" then
        local cx = math.ceil(counts.X / 2)
        local cz = math.ceil(counts.Z / 2)
        local topY = BlockGrid.TopSolid(grid, cx, cz)
        if topY >= 1 then
            local pos = BlockGrid.Position(grid, cx, topY, cz)
            return pos + grid.StepY.Unit * (BlockGrid.Height(grid, topY) / 2)
        end
    end

    local catalogues = getMineCatalogues()
    local power = math.max(safeNum("Strength", 1) * safeNum("SlamPower", 1), 1)
    local bestPos = nil
    local bestScore = -1

    -- If Secret/Eggore Focus, check SecretCells directly first
    if priority == "Secret & Eggore Focus" and data.SecretCells then
        for _, cellKey in pairs(data.SecretCells) do
            local sx, sy, sz = BlockGrid.Unkey(cellKey)
            if BlockGrid.IsSolid(grid, sx, sy, sz) then
                local topY = BlockGrid.TopSolid(grid, sx, sz)
                if topY >= 1 then
                    local hp = BlockGrid.HealthAt(grid, sx, topY, sz) or 1
                    if power >= hp * 0.25 then
                        local pos = BlockGrid.Position(grid, sx, topY, sz)
                        return pos + grid.StepY.Unit * (BlockGrid.Height(grid, topY) / 2)
                    end
                end
            end
        end
    end

    for x = 1, counts.X do
        for z = 1, counts.Z do
            local topY = BlockGrid.TopSolid(grid, x, z)
            if topY >= 1 then
                local score = 0
                local breakableTop = false
                local topHp = BlockGrid.HealthAt(grid, x, topY, z) or 1
                if power >= topHp then
                    breakableTop = true
                end

                local depthScan = math.max(1, topY - 4)
                for y = topY, depthScan, -1 do
                    if BlockGrid.IsSolid(grid, x, y, z) then
                        local kind = BlockGrid.KindAt(grid, x, y, z)
                        local hp = BlockGrid.HealthAt(grid, x, y, z) or 1
                        local s = tierScore(zone, kind, catalogues)
                        if priority == "Secret & Eggore Focus" and (s >= 500000) then
                            s = s * 10
                        end
                        if power >= hp then
                            score = score + s
                        else
                            score = score + s * 0.05
                        end
                    end
                end

                if breakableTop then
                    score = score + 50
                end

                if score > bestScore then
                    bestScore = score
                    local pos = BlockGrid.Position(grid, x, topY, z)
                    bestPos = pos + grid.StepY.Unit * (BlockGrid.Height(grid, topY) / 2)
                end
            end
        end
    end

    if bestPos then
        return bestPos
    end

    local center = MineFieldController.CenterOf(zone)
    return center
end

local function getBestUnlockedTrainingPad()
    local pads = TrainingPads.Published()
    local rebirths = safeNum(RebirthConfig.LevelAttribute, 0)
    local ownedPlats = ownedSet(TrainingConfig.OwnedAttribute)
    local bestPad = nil
    local bestMult = -1

    for _, pad in ipairs(pads) do
        local plat = pad.Platform
        if plat then
            local unlocked = true
            if plat.Rebirths and rebirths < plat.Rebirths then
                unlocked = false
            end
            if plat.Product and not ownedPlats[pad.Name] then
                unlocked = false
            end
            if plat.Event then
                local ge = ReplicatedStorage:FindFirstChild("GlobalEvents")
                if not ge or ge:GetAttribute(plat.Event) ~= true then
                    unlocked = false
                end
            end
            if unlocked and (plat.Multiplier or 0) > bestMult then
                bestMult = plat.Multiplier or 0
                bestPad = pad
            end
        end
    end
    return bestPad
end

local function teleportToCFrame(cf)
    local char, hum, hrp = getChar()
    if char and hrp then
        char:PivotTo(cf)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    return false
end

local function sellAllAtShop(returnCF)
    local oreCount = safeNum(LootConfig.CountAttribute, 0)
    if oreCount <= 0 then return false end

    local shops = workspace:FindFirstChild("Folder") and workspace.Folder:FindFirstChild("Shops")
    local sellShop = shops and shops:FindFirstChild("SellShop")
    local sellRemote = getRemote(RemotesFolder, LootConfig.Remotes.Sell)
    if not sellShop or not sellRemote then return false end

    local sellPos = sellShop:GetPivot().Position + Vector3.new(0, 4, 6)
    teleportToCFrame(CFrame.new(sellPos))
    task.wait(0.18)
    sellRemote:FireServer(nil)
    task.wait(0.25)

    if returnCF then
        teleportToCFrame(returnCF)
    end
    return true
end

local function returnToBaseAndReset()
    local returnRemote = getRemote(RemotesFolder, MineConfig.Trip.ReturnRemote)
    QuickTeleport.Go(MineConfig.Trip.HomeSpot)
    if returnRemote then
        returnRemote:FireServer(true)
    end
    task.wait(0.35)
end

local function flushPendingLoot()
    if #PendingLootIds == 0 then return end
    local collectRemote = getRemote(RemotesFolder, LootConfig.Remotes.Collect)
    if not collectRemote then
        table.clear(PendingLootIds)
        return
    end
    while #PendingLootIds > 0 do
        local batch = {}
        for i = 1, math.min(#PendingLootIds, LootConfig.PickupBatchSize) do
            table.insert(batch, table.remove(PendingLootIds))
        end
        collectRemote:FireServer(batch)
    end
end

-- Persistent Broken listener (only collects when AutoInstantLoot or AutoMine is active)
BrokenConn = trackConn(MineFieldController.Broken:Connect(function(lootId, kind, zone, tier)
    if (State.AutoInstantLoot or State.AutoMine) and tier and tier > 0 and lootId then
        table.insert(PendingLootIds, lootId)
    end
end))

-- Build WindUI Window
local Window = WindUI:CreateWindow({
    Title = "XLunaHUB | +1 Crush The Floor!",
    Icon = "hammer",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_Plus1CrushTheFloor",
    Size = UDim2.fromOffset(600, 440),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 175,
    HideSearchBar = false,
})

ensureIdentity()

-- Pure single-trigger LeftCTRL Toggle (WindUI native handler, zero double-trigger)
Window:SetToggleKey(Enum.KeyCode.LeftControl)

-- Disable WindUI's redundant OpenButton (we provide a unified draggable Floating Toggle Button below)
pcall(function()
    Window:EditOpenButton({
        Enabled = false,
    })
end)

-- Fix layered DisplayOrder across all 4 WindUI ScreenGuis so Dropdowns/Notifications/Tooltips never clip behind Window
local function fixWindUILayers()
    local layers = {
        ["WindUI"] = 10,
        ["WindUI/Notifications"] = 20,
        ["WindUI/Dropdowns"] = 30,
        ["WindUI/Tooltips"] = 40,
    }
    local roots = { CoreGui, LocalPlayer:FindFirstChildOfClass("PlayerGui") }
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            table.insert(roots, hui)
        end
    end
    for _, root in ipairs(roots) do
        if root then
            for _, gui in ipairs(root:GetChildren()) do
                if gui:IsA("ScreenGui") and layers[gui.Name] then
                    gui.DisplayOrder = layers[gui.Name]
                end
            end
        end
    end
end
task.defer(fixWindUILayers)
task.delay(0.35, fixWindUILayers)

-- Always-available compact Floating Toggle Button (toggles both Open & Close cleanly)
local function createFloatingButton()
    local parentGui = CoreGui
    local ok = pcall(function() local _ = parentGui.Name end)
    if not ok then
        parentGui = LocalPlayer:WaitForChild("PlayerGui")
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "XLunaHUB_FloatingToggle"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 50
    sg.Parent = parentGui

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.fromOffset(118, 34)
    btn.Position = UDim2.new(0.5, -59, 0, 72)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    btn.TextColor3 = Color3.fromRGB(240, 244, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = "XLunaHUB"
    btn.AutoButtonColor = true
    btn.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(95, 130, 255)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    -- Smooth Drag + Click detection
    local dragging = false
    local dragStart, startPos
    local moved = false

    trackConn(btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = btn.Position
        end
    end))

    trackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                moved = true
            end
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    trackConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    trackConn(btn.MouseButton1Click:Connect(function()
        if not moved then
            ensureIdentity()
            Window:Toggle()
        end
    end))

    FloatingGui = sg
end
createFloatingButton()

-- Prepare Zone & Pad lists
local ZoneChoices = { "Auto Highest" }
local TeleportZoneChoices = { "Home" }
for i, z in ipairs(ZoneConfig.Zones) do
    local label = string.format("Zone %d - %s", i, z.Name)
    table.insert(ZoneChoices, label)
    table.insert(TeleportZoneChoices, label)
end

local PadChoices = { "Auto Best", "AdminPlatform" }
for name, _ in pairs(TrainingConfig.Platforms) do
    if name ~= "AdminPlatform" then
        table.insert(PadChoices, name)
    end
end
table.sort(PadChoices, function(a, b)
    if a == "Auto Best" then return true end
    if b == "Auto Best" then return false end
    local pa = TrainingConfig.Platforms[a]
    local pb = TrainingConfig.Platforms[b]
    return (pa and pa.Multiplier or 0) < (pb and pb.Multiplier or 0)
end)

local ShopChoices = {
    "Sell Shop",
    "Food Shop",
    "Upgrades Shop",
    "Main Shop",
    "Potion Shop",
    "Fuse Machine",
    "Best Training Pad",
    "Nearest Egg",
}

-- ============================================================================
-- TAB 1: DASHBOARD
-- ============================================================================
local TabDashboard = Window:Tab({ Title = "Dashboard", Icon = "layout-dashboard" })
local SecStats = TabDashboard:Section({ Title = "Live Player Telemetry", Opened = true })

local StatsParagraph = SecStats:Paragraph({
    Title = "Player Status",
    Desc = "Loading telemetry...",
})

local SecQuickActions = TabDashboard:Section({ Title = "Quick Actions", Opened = true })

SecQuickActions:Button({
    Title = "Sell All Ores",
    Desc = "Teleports to Sell Shop, cashes out all carried ores, and returns",
    Callback = function()
        task.spawn(function()
            local _, _, hrp = getChar()
            local prev = hrp and hrp.CFrame
            sellAllAtShop(prev)
        end)
    end,
})

SecQuickActions:Button({
    Title = "Return To Base (Reset Trip)",
    Desc = "Teleports Home and resets SlamsLeft",
    Callback = function()
        task.spawn(returnToBaseAndReset)
    end,
})

SecQuickActions:Button({
    Title = "Claim All Available Rewards",
    Desc = "Claims Offline, Daily, Group, and Weekly Challenge rewards",
    Callback = function()
        task.spawn(function()
            local offRemote = getRemote(RemotesFolder, OfflineConfig.Remote)
            if offRemote and LocalPlayer:GetAttribute(OfflineConfig.StrengthAttribute) then
                offRemote:FireServer()
            end
            local dailyRemote = getRemote(NetworkFolder, DailyRewardConfig.RemoteName)
            if dailyRemote then
                local st = DailyRewardConfig.StateAt(
                    safeNum(DailyRewardConfig.ClaimedAttribute, 0),
                    safeNum(DailyRewardConfig.UnlockAtAttribute, 0),
                    workspace:GetServerTimeNow()
                )
                if st.CanClaim and st.NextDay then
                    dailyRemote:FireServer(st.NextDay)
                end
            end
            local grpRemote = getRemote(RemotesFolder, "GroupReward")
            if grpRemote and LocalPlayer:GetAttribute("GroupRewardClaimed") ~= true then
                grpRemote:FireServer()
            end
            local wkRemote = getRemote(RemotesFolder, WeeklyChallengeConfig.Remote)
            if wkRemote and LocalPlayer:GetAttribute(WeeklyChallengeConfig.Attributes.Claimed) ~= true then
                wkRemote:FireServer(WeeklyChallengeConfig.Actions.Claim)
            end
        end)
    end,
})

SecQuickActions:Button({
    Title = "Activate Blue Titan Jump",
    Desc = "Triggers Blue Titan Jump if ready",
    Callback = function()
        local wkRemote = getRemote(RemotesFolder, WeeklyChallengeConfig.Remote)
        if wkRemote then
            wkRemote:FireServer(WeeklyChallengeConfig.Actions.Activate)
        end
    end,
})

-- ============================================================================
-- TAB 2: AUTO FARM
-- ============================================================================
local TabFarm = Window:Tab({ Title = "Auto Farm", Icon = "pickaxe" })
local SecTrain = TabFarm:Section({ Title = "Strength & Training", Opened = true })

SecTrain:Toggle({
    Title = "Auto Eat (Strength Click)",
    Desc = "Auto-equips food and fires StrengthClick continuously",
    Flag = "AutoEat",
    Value = false,
    Callback = function(v)
        State.AutoEat = v
    end,
})

SecTrain:Toggle({
    Title = "Auto Train (Training Pad)",
    Desc = "Moves onto the selected/best unlocked Training Pad and bites",
    Flag = "AutoTrain",
    Value = false,
    Callback = function(v)
        State.AutoTrain = v
    end,
})

SecTrain:Dropdown({
    Title = "Target Training Pad",
    Flag = "TargetTrainPad",
    Values = PadChoices,
    Value = "Auto Best",
    Callback = function(v)
        State.TargetTrainPad = v
    end,
})

SecTrain:Toggle({
    Title = "Auto Equip Food Tool",
    Desc = "Keeps your equipped food tool held in hand",
    Flag = "AutoEquipFood",
    Value = false,
    Callback = function(v)
        State.AutoEquipFood = v
    end,
})

local SecMine = TabFarm:Section({ Title = "Smart Mine & Slam", Opened = true })

SecMine:Dropdown({
    Title = "Target Mine Zone",
    Flag = "TargetMineZone",
    Values = ZoneChoices,
    Value = "Auto Highest",
    Callback = function(v)
        State.TargetMineZone = v
    end,
})

SecMine:Dropdown({
    Title = "Slam Target Priority",
    Flag = "SlamPriority",
    Values = { "Smart Value", "Secret & Eggore Focus", "Center Drill" },
    Value = "Smart Value",
    Callback = function(v)
        State.SlamPriority = v
    end,
})

SecMine:Toggle({
    Title = "Auto Mine (Full Loop)",
    Desc = "Targets high-value ores, slams, instant-loots, resets & sells automatically",
    Flag = "AutoMine",
    Value = false,
    Callback = function(v)
        State.AutoMine = v
    end,
})

SecMine:Toggle({
    Title = "Auto Instant Loot Collect",
    Desc = "Instantly batches LootCollect on broken ores without waiting for pickup arcs",
    Flag = "AutoInstantLoot",
    Value = false,
    Callback = function(v)
        State.AutoInstantLoot = v
    end,
})

SecMine:Toggle({
    Title = "Auto Sell Ores",
    Desc = "Sells carried ores automatically once threshold is reached",
    Flag = "AutoSellOres",
    Value = false,
    Callback = function(v)
        State.AutoSellOres = v
    end,
})

SecMine:Slider({
    Title = "Auto Sell Min Ores",
    Flag = "AutoSellMinOres",
    Step = 1,
    Value = { Min = 1, Max = 500, Default = 10 },
    Callback = function(v)
        State.AutoSellMinOres = v
    end,
})

-- ============================================================================
-- TAB 3: PROGRESSION
-- ============================================================================
local TabProg = Window:Tab({ Title = "Progression", Icon = "trending-up" })
local SecFood = TabProg:Section({ Title = "Food Shop", Opened = true })

SecFood:Toggle({
    Title = "Auto Buy Best Food",
    Desc = "Automatically purchases the strongest affordable food",
    Flag = "AutoBuyFood",
    Value = false,
    Callback = function(v)
        State.AutoBuyFood = v
    end,
})

SecFood:Toggle({
    Title = "Auto Equip Best Food",
    Desc = "Automatically equips your strongest owned food",
    Flag = "AutoEquipBestFood",
    Value = false,
    Callback = function(v)
        State.AutoEquipBestFood = v
    end,
})

local SecUpgrades = TabProg:Section({ Title = "Upgrades & Zones", Opened = true })

SecUpgrades:Dropdown({
    Title = "Upgrade Targets",
    Flag = "UpgradeTargets",
    Values = { "ExtraJumps", "WalkSpeed", "MagnetRadius", "CrushRadius" },
    Value = { "ExtraJumps", "WalkSpeed", "MagnetRadius", "CrushRadius" },
    Multi = true,
    Callback = function(v)
        State.UpgradeTargets = v
    end,
})

SecUpgrades:Toggle({
    Title = "Auto Buy Upgrades",
    Desc = "Purchases selected upgrades whenever you have enough cash",
    Flag = "AutoBuyUpgrades",
    Value = false,
    Callback = function(v)
        State.AutoBuyUpgrades = v
    end,
})

SecUpgrades:Toggle({
    Title = "Auto Buy Next Zone",
    Desc = "Automatically unlocks the next zone when affordable",
    Flag = "AutoBuyZone",
    Value = false,
    Callback = function(v)
        State.AutoBuyZone = v
    end,
})

SecUpgrades:Toggle({
    Title = "Auto Buy Zone Luck",
    Desc = "Automatically upgrades luck on your highest unlocked zone",
    Flag = "AutoBuyZoneLuck",
    Value = false,
    Callback = function(v)
        State.AutoBuyZoneLuck = v
    end,
})

local SecRebirth = TabProg:Section({ Title = "Rebirth", Opened = true })

SecRebirth:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths as soon as level requirement is met",
    Flag = "AutoRebirth",
    Value = false,
    Callback = function(v)
        State.AutoRebirth = v
    end,
})

-- ============================================================================
-- TAB 4: PETS & EGGS
-- ============================================================================
local TabPets = Window:Tab({ Title = "Pets & Eggs", Icon = "egg" })
local SecEggs = TabPets:Section({ Title = "Egg Hatching", Opened = true })

SecEggs:Dropdown({
    Title = "Target Egg Zone",
    Flag = "EggZone",
    Values = ZoneChoices,
    Value = "Auto Highest",
    Callback = function(v)
        State.EggZone = v
    end,
})

SecEggs:Toggle({
    Title = "Auto Hatch Egg",
    Desc = "Hatches eggs using Eggore while storage has room",
    Flag = "AutoHatchEgg",
    Value = false,
    Callback = function(v)
        State.AutoHatchEgg = v
    end,
})

SecEggs:Toggle({
    Title = "Skip Hatch Animation",
    Desc = "Immediately cancels the 3D egg reveal animation for fast hatching",
    Flag = "SkipHatchAnim",
    Value = false,
    Callback = function(v)
        State.SkipHatchAnim = v
    end,
})

local SecPetMgmt = TabPets:Section({ Title = "Pet Bag & Fuse Machine", Opened = true })

SecPetMgmt:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Periodically equips your highest multiplier pets",
    Flag = "AutoEquipBestPets",
    Value = false,
    Callback = function(v)
        State.AutoEquipBestPets = v
    end,
})

SecPetMgmt:Toggle({
    Title = "Auto Fuse Pets",
    Desc = "Automatically fuses 3 identical pets (Base -> Golden -> Diamond -> Toxic -> Ruby)",
    Flag = "AutoFusePets",
    Value = false,
    Callback = function(v)
        State.AutoFusePets = v
    end,
})

SecPetMgmt:Dropdown({
    Title = "Auto Sell Rarities",
    Flag = "AutoSellRarities",
    Values = { "Rare", "Epic", "Legendary", "Mythic" },
    Value = { "Rare" },
    Multi = true,
    Callback = function(v)
        State.AutoSellRarities = v
    end,
})

SecPetMgmt:Toggle({
    Title = "Auto Sell Weak Pets",
    Desc = "Sells unequipped pets matching selected rarities (protects Limited & top pets)",
    Flag = "AutoSellWeakPets",
    Value = false,
    Callback = function(v)
        State.AutoSellWeakPets = v
    end,
})

-- ============================================================================
-- TAB 5: EVENTS & ESP
-- ============================================================================
local TabEvents = Window:Tab({ Title = "Events & ESP", Icon = "sparkles" })
local SecEvents = TabEvents:Section({ Title = "World Events & Auto Claims", Opened = true })

SecEvents:Toggle({
    Title = "Auto Collect Blue Ores",
    Desc = "Claims Blue Ore Rain drops automatically",
    Flag = "AutoBlueOres",
    Value = false,
    Callback = function(v)
        State.AutoBlueOres = v
    end,
})

SecEvents:Toggle({
    Title = "Auto Collect Egg Rain",
    Desc = "Claims Egg Rain drops automatically",
    Flag = "AutoEggRain",
    Value = false,
    Callback = function(v)
        State.AutoEggRain = v
    end,
})

SecEvents:Toggle({
    Title = "Auto Claim Rewards",
    Desc = "Automatically claims Offline, Daily, Group & Weekly Challenge rewards",
    Flag = "AutoClaimRewards",
    Value = false,
    Callback = function(v)
        State.AutoClaimRewards = v
    end,
})

SecEvents:Toggle({
    Title = "Auto Activate Blue Titan Jump",
    Desc = "Triggers Blue Titan Jump whenever ready",
    Flag = "AutoTitanJump",
    Value = false,
    Callback = function(v)
        State.AutoTitanJump = v
    end,
})

local SecEsp = TabEvents:Section({ Title = "Secret & Eggore Radar / ESP", Opened = true })

local function clearEsp()
    if EspFolder then
        EspFolder:Destroy()
        EspFolder = nil
    end
end

SecEsp:Toggle({
    Title = "Secret & Eggore ESP",
    Desc = "Highlights active Secret & Eggore cells inside unlocked mines",
    Flag = "SecretEsp",
    Value = false,
    Callback = function(v)
        State.SecretEsp = v
        if not v then
            clearEsp()
        end
    end,
})

SecEsp:Button({
    Title = "Teleport To Nearest Secret / Eggore",
    Desc = "Positions you directly above the nearest active Secret or Eggore",
    Callback = function()
        local fields = getMineFieldsTable()
        if not fields then return end
        local _, _, hrp = getChar()
        local myPos = hrp and hrp.Position or Vector3.zero
        local highest = ZoneConfig.HighestOf(LocalPlayer)
        local bestPos, bestDist = nil, math.huge

        for z = 1, highest do
            local field = fields[z]
            local data = field and field.Data
            if data and data.Grid then
                local grid = data.Grid
                if data.SecretCells then
                    for _, cellKey in pairs(data.SecretCells) do
                        local x, y, zc = BlockGrid.Unkey(cellKey)
                        if BlockGrid.IsSolid(grid, x, y, zc) then
                            local pos = BlockGrid.Position(grid, x, BlockGrid.TopSolid(grid, x, zc), zc)
                            local d = (pos - myPos).Magnitude
                            if d < bestDist then
                                bestDist = d
                                bestPos = pos
                            end
                        end
                    end
                end
            end
        end

        if bestPos then
            teleportToCFrame(CFrame.new(bestPos + Vector3.new(0, 6, 0)))
        else
            WindUI:Notify({ Title = "XLunaHUB", Content = "No active Secret Ore found in unlocked mines.", Duration = 3 })
        end
    end,
})

-- ============================================================================
-- TAB 6: TELEPORTS & MISC
-- ============================================================================
local TabMisc = Window:Tab({ Title = "Teleports & Misc", Icon = "compass" })
local SecTele = TabMisc:Section({ Title = "Teleports", Opened = true })

SecTele:Dropdown({
    Title = "Zone Destination",
    Flag = "SelectedTeleportZone",
    Values = TeleportZoneChoices,
    Value = "Zone 1 - Forest",
    Callback = function(v)
        State.SelectedTeleportZone = v
    end,
})

SecTele:Button({
    Title = "Teleport To Zone",
    Callback = function()
        if State.SelectedTeleportZone == "Home" then
            QuickTeleport.Go("Home")
            return
        end
        local idx = tonumber(tostring(State.SelectedTeleportZone):match("Zone%s*(%d+)"))
        if idx then
            local spot = QuickTeleport.Spot("Zone" .. idx)
            if spot then
                teleportToCFrame(spot + Vector3.new(0, 4, 0))
            end
        end
    end,
})

SecTele:Dropdown({
    Title = "Shop / Facility",
    Flag = "SelectedShopLocation",
    Values = ShopChoices,
    Value = "Sell Shop",
    Callback = function(v)
        State.SelectedShopLocation = v
    end,
})

SecTele:Button({
    Title = "Teleport To Facility",
    Callback = function()
        local choice = State.SelectedShopLocation
        local shops = workspace:FindFirstChild("Folder") and workspace.Folder:FindFirstChild("Shops")
        if choice == "Sell Shop" and shops and shops:FindFirstChild("SellShop") then
            teleportToCFrame(CFrame.new(shops.SellShop:GetPivot().Position + Vector3.new(0, 4, 6)))
        elseif choice == "Food Shop" and shops and shops:FindFirstChild("FoodShop") then
            teleportToCFrame(CFrame.new(shops.FoodShop:GetPivot().Position + Vector3.new(0, 4, 6)))
        elseif choice == "Upgrades Shop" and shops and shops:FindFirstChild("UpgradesShop") then
            teleportToCFrame(CFrame.new(shops.UpgradesShop:GetPivot().Position + Vector3.new(0, 4, 6)))
        elseif choice == "Main Shop" and shops and shops:FindFirstChild("Shop") then
            teleportToCFrame(CFrame.new(shops.Shop:GetPivot().Position + Vector3.new(0, 4, 6)))
        elseif choice == "Potion Shop" and workspace:FindFirstChild("RedPotion") then
            teleportToCFrame(CFrame.new(workspace.RedPotion:GetPivot().Position + Vector3.new(0, 4, 6)))
        elseif choice == "Fuse Machine" and workspace:FindFirstChild("FuseMachine") then
            teleportToCFrame(CFrame.new(workspace.FuseMachine:GetPivot().Position + Vector3.new(0, 4, 6)))
        elseif choice == "Best Training Pad" then
            local pad = getBestUnlockedTrainingPad()
            if pad then
                teleportToCFrame(pad.CFrame + Vector3.new(0, 4, 0))
            end
        elseif choice == "Nearest Egg" then
            local targetZone = ZoneConfig.HighestOf(LocalPlayer)
            for _, c in ipairs(workspace:GetChildren()) do
                if c.Name == PetsConfig.EggModelName and c:GetAttribute(PetsConfig.ZoneAttribute) == targetZone then
                    teleportToCFrame(CFrame.new(c:GetPivot().Position + Vector3.new(0, 4, 6)))
                    break
                end
            end
        end
    end,
})

local SecMove = TabMisc:Section({ Title = "Movement & Client QOL", Opened = true })

SecMove:Toggle({
    Title = "Custom WalkSpeed",
    Flag = "CustomWalkSpeed",
    Value = false,
    Callback = function(v)
        State.CustomWalkSpeed = v
    end,
})

SecMove:Slider({
    Title = "WalkSpeed",
    Flag = "WalkSpeedValue",
    Step = 1,
    Value = { Min = 16, Max = 250, Default = 50 },
    Callback = function(v)
        State.WalkSpeedValue = v
    end,
})

SecMove:Toggle({
    Title = "Custom JumpHeight",
    Flag = "CustomJumpHeight",
    Value = false,
    Callback = function(v)
        State.CustomJumpHeight = v
    end,
})

SecMove:Slider({
    Title = "JumpHeight",
    Flag = "JumpHeightValue",
    Step = 1,
    Value = { Min = 7, Max = 150, Default = 40 },
    Callback = function(v)
        State.JumpHeightValue = v
    end,
})

SecMove:Toggle({
    Title = "Infinite Jump",
    Flag = "InfiniteJump",
    Value = false,
    Callback = function(v)
        State.InfiniteJump = v
    end,
})

SecMove:Toggle({
    Title = "NoClip",
    Flag = "NoClip",
    Value = false,
    Callback = function(v)
        State.NoClip = v
        if not v and LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.CanCollide = true
                end
            end
        end
    end,
})

SecMove:Toggle({
    Title = "Remove Zone Barriers & Fog",
    Desc = "Disables ZoneBarrier collision and hides ZoneFog locally",
    Flag = "RemoveBarriers",
    Value = false,
    Callback = function(v)
        State.RemoveBarriers = v
    end,
})

SecMove:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents 20-minute idle disconnect automatically",
    Flag = "AntiAfk",
    Value = false,
    Callback = function(v)
        State.AntiAfk = v
    end,
})

-- ============================================================================
-- TAB 7: CONFIG
-- ============================================================================
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })
local SecConfig = TabConfig:Section({ Title = "Configuration Manager", Opened = true })

local ConfigManager = Window.ConfigManager
local SavedConfigsDropdown = nil

local function refreshConfigsList()
    if not ConfigManager or not SavedConfigsDropdown then return end
    local list = ConfigManager:AllConfigs()
    if #list == 0 then
        list = { "default" }
    end
    SavedConfigsDropdown:Refresh(list)
end

SecConfig:Input({
    Title = "Config Name",
    Placeholder = "default",
    Value = "default",
    Flag = "ConfigNameInput",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            State.ConfigName = v
        end
    end,
})

SavedConfigsDropdown = SecConfig:Dropdown({
    Title = "Saved Configs",
    Values = (ConfigManager and #ConfigManager:AllConfigs() > 0) and ConfigManager:AllConfigs() or { "default" },
    Value = "default",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            State.ConfigName = v
        end
    end,
})

SecConfig:Button({
    Title = "Save Config",
    Desc = "Saves all current toggles, sliders, and dropdowns",
    Callback = function()
        if not ConfigManager then
            WindUI:Notify({ Title = "XLunaHUB", Content = "ConfigManager unavailable.", Duration = 3 })
            return
        end
        local name = (State.ConfigName and State.ConfigName ~= "") and State.ConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        cfg:Save()
        refreshConfigsList()
        WindUI:Notify({ Title = "XLunaHUB", Content = "Saved config: " .. name, Duration = 2.5 })
    end,
})

SecConfig:Button({
    Title = "Load Config",
    Desc = "Loads selected configuration",
    Callback = function()
        if not ConfigManager then
            WindUI:Notify({ Title = "XLunaHUB", Content = "ConfigManager unavailable.", Duration = 3 })
            return
        end
        local name = (State.ConfigName and State.ConfigName ~= "") and State.ConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        local ok = cfg:Load()
        if ok then
            WindUI:Notify({ Title = "XLunaHUB", Content = "Loaded config: " .. name, Duration = 2.5 })
        else
            WindUI:Notify({ Title = "XLunaHUB", Content = "Config not found: " .. name, Duration = 2.5 })
        end
    end,
})

SecConfig:Button({
    Title = "Refresh Config List",
    Callback = refreshConfigsList,
})

SecConfig:Button({
    Title = "Delete Config",
    Callback = function()
        local name = (State.ConfigName and State.ConfigName ~= "") and State.ConfigName or "default"
        if ConfigManager and delfile and isfile then
            local path = ConfigManager.Path .. name .. ".json"
            if isfile(path) then
                pcall(delfile, path)
                refreshConfigsList()
                WindUI:Notify({ Title = "XLunaHUB", Content = "Deleted config: " .. name, Duration = 2.5 })
            end
        end
    end,
})

local SecSystem = TabConfig:Section({ Title = "Hub System", Opened = true })

local function cleanupAll()
    State.Running = false
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    clearEsp()
    if FloatingGui then
        pcall(function() FloatingGui:Destroy() end)
        FloatingGui = nil
    end
    pcall(function()
        Window:Destroy()
    end)
end

if getgenv then
    getgenv().XLunaHUB_CTF_Cleanup = cleanupAll
end

SecSystem:Button({
    Title = "Unload XLunaHUB",
    Desc = "Cleanly stops all loops and removes the UI",
    Callback = cleanupAll,
})

Window:SelectTab(1)
task.defer(fixWindUILayers)

-- ============================================================================
-- BACKGROUND AUTOMATION LOOPS
-- ============================================================================

-- 1. Anti-AFK (only acts when State.AntiAfk == true)
trackConn(LocalPlayer.Idled:Connect(function()
    if State.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

-- 2. Infinite Jump
trackConn(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local _, hum = getChar()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- 3. Heartbeat Movement / NoClip / Barrier Removal
trackConn(RunService.Heartbeat:Connect(function()
    if not State.Running then return end
    local char, hum = getChar()
    if char and hum and hum.Health > 0 then
        if State.CustomWalkSpeed then
            hum.WalkSpeed = State.WalkSpeedValue
        end
        if State.CustomJumpHeight then
            hum.UseJumpPower = false
            hum.JumpHeight = State.JumpHeightValue
        end
        if State.NoClip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end
    if State.RemoveBarriers then
        local zb = workspace:FindFirstChild("ZoneBarrier")
        if zb then
            for _, p in ipairs(zb:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    p.CanTouch = false
                end
            end
        end
        local zf = workspace:FindFirstChild("ZoneFog")
        if zf then
            for _, e in ipairs(zf:GetDescendants()) do
                if e:IsA("ParticleEmitter") then
                    e.Enabled = false
                end
            end
        end
    end
end))

-- 4. Fast Eat / Auto Train Loop
task.spawn(function()
    while State.Running do
        if State.AutoEquipFood or State.AutoEat or State.AutoTrain then
            equipFoodTool()
        end

        if State.AutoEat then
            local clickRemote = getRemote(RemotesFolder, "StrengthClick")
            if clickRemote then
                clickRemote:FireServer()
            end
        end

        if State.AutoTrain then
            local pad = nil
            if State.TargetTrainPad == "Auto Best" then
                pad = getBestUnlockedTrainingPad()
            else
                for _, p in ipairs(TrainingPads.Published()) do
                    if p.Name == State.TargetTrainPad then
                        pad = p
                        break
                    end
                end
            end

            if pad then
                local _, _, hrp = getChar()
                if hrp and not TrainingPads.Contains(pad, TrainingPads.FeetOf(LocalPlayer.Character) or hrp.Position, 0) then
                    teleportToCFrame(pad.CFrame + Vector3.new(0, 4, 0))
                    task.wait(0.15)
                end
                local biteRemote = getRemote(RemotesFolder, TrainingConfig.Remote)
                if biteRemote then
                    biteRemote:FireServer()
                end
            end
        end

        task.wait(0.06)
    end
end)

-- 5. Smart Auto Mine + Auto Sell + Instant Loot Loop
task.spawn(function()
    while State.Running do
        if State.AutoInstantLoot and #PendingLootIds > 0 then
            flushPendingLoot()
        end

        if State.AutoMine then
            local zone = parseZoneChoice(State.TargetMineZone)
            local slamsLeft = safeNum(MineConfig.Slam.LeftAttribute, 0)
            local inTrip = LocalPlayer:GetAttribute(MineConfig.Trip.Attribute) == true
            local tripZone = safeNum(MineConfig.Trip.ZoneAttribute, zone)

            -- If already in a trip in a different zone or out of jumps, return home & sell first
            if slamsLeft <= 0 or (inTrip and tripZone ~= zone) then
                flushPendingLoot()
                returnToBaseAndReset()
                sellAllAtShop(nil)
            else
                local targetPos = pickSlamTarget(zone, State.SlamPriority)
                if targetPos then
                    teleportToCFrame(CFrame.new(targetPos + Vector3.new(0, 5.5, 0)))
                    task.wait(0.08)

                    local power = math.max(safeNum("Strength", 1) * safeNum(MineConfig.Slam.PowerAttribute, 1), 1)
                    local radiusScale = UpgradeMath.ValueOf(LocalPlayer, UpgradesConfig.Keys.CrushRadius) or 1
                    local broken = MineFieldController.Slam(zone, targetPos, power, radiusScale)
                    local slamRemote = getRemote(RemotesFolder, MineConfig.Slam.Remote)
                    if slamRemote then
                        slamRemote:FireServer(zone, targetPos, power, broken, false)
                    end
                    task.wait(0.12)
                    flushPendingLoot()
                    task.wait(0.15)
                else
                    task.wait(0.3)
                end
            end
        elseif State.AutoSellOres then
            local oreCount = safeNum(LootConfig.CountAttribute, 0)
            if oreCount >= State.AutoSellMinOres then
                local _, _, hrp = getChar()
                local prev = hrp and hrp.CFrame
                sellAllAtShop(prev)
            end
            task.wait(0.4)
        else
            task.wait(0.25)
        end
    end
end)

-- 6. Progression Loop (Food, Upgrades, Zones, Luck, Rebirth)
task.spawn(function()
    while State.Running do
        local money = safeNum("Money", 0)
        local ownedFoods = ownedSet(FoodConfig.OwnedAttribute)
        local equippedFood = LocalPlayer:GetAttribute(FoodConfig.EquippedAttribute) or FoodConfig.Default

        if State.AutoBuyFood then
            local foodRemote = getRemote(RemotesFolder, "FoodShop")
            if foodRemote then
                for _, food in ipairs(FoodConfig.Foods) do
                    if food.InShop ~= false and not FoodConfig.IsFree(food) and not ownedFoods[food.Id] then
                        if money >= food.Price then
                            foodRemote:FireServer("Buy", food.Id)
                            money = money - food.Price
                            ownedFoods[food.Id] = true
                            task.wait(0.1)
                        end
                    end
                end
            end
        end

        if State.AutoEquipBestFood then
            local foodRemote = getRemote(RemotesFolder, "FoodShop")
            if foodRemote then
                local bestFoodId = nil
                local bestGain = -1
                local ownsFn = function(id) return ownedFoods[id] == true end
                for _, food in ipairs(FoodConfig.Foods) do
                    if FoodConfig.IsFree(food) or ownedFoods[food.Id] then
                        local gain = FoodConfig.StrengthPerClickFor(food, ownsFn)
                        if gain > bestGain then
                            bestGain = gain
                            bestFoodId = food.Id
                        end
                    end
                end
                if bestFoodId and bestFoodId ~= equippedFood then
                    foodRemote:FireServer("Equip", bestFoodId)
                end
            end
        end

        if State.AutoBuyUpgrades then
            local upgRemote = getRemote(RemotesFolder, UpgradesConfig.Remote)
            if upgRemote then
                local targets = type(State.UpgradeTargets) == "table" and State.UpgradeTargets or {}
                local lookup = {}
                for _, t in ipairs(targets) do lookup[t] = true end
                for _, upg in ipairs(UpgradesConfig.Upgrades) do
                    if lookup[upg.Key] then
                        local lvl = UpgradeMath.LevelOf(LocalPlayer, upg)
                        local price = UpgradeMath.PriceAt(upg, lvl)
                        if price and money >= price then
                            upgRemote:FireServer(upg.Key)
                            money = money - price
                            task.wait(0.08)
                        end
                    end
                end
            end
        end

        if State.AutoBuyZone then
            local highest = ZoneConfig.HighestOf(LocalPlayer)
            local nextZone = ZoneConfig.Get(highest + 1)
            local buyZoneRemote = getRemote(RemotesFolder, ZoneConfig.Remote)
            if nextZone and buyZoneRemote and money >= nextZone.Price then
                buyZoneRemote:FireServer()
                money = money - nextZone.Price
            end
        end

        if State.AutoBuyZoneLuck then
            local highest = ZoneConfig.HighestOf(LocalPlayer)
            local luckRemote = getRemote(RemotesFolder, "ZoneLuck")
            local lvl = ZoneLuck.LevelOf(LocalPlayer, highest)
            local price = ZoneLuck.PriceAt(highest, lvl)
            if luckRemote and price and money >= price then
                luckRemote:FireServer("Buy", highest)
            end
        end

        if State.AutoRebirth then
            local rebirths = safeNum(RebirthConfig.LevelAttribute, 0)
            local curLevel = Levels.Of(safeNum("Strength", 1))
            local reqLevel = RebirthConfig.LevelRequirementFor(rebirths)
            local rebRemote = getRemote(NetworkFolder, RebirthConfig.RemoteName)
            if rebRemote and curLevel >= reqLevel then
                rebRemote:FireServer()
            end
        end

        task.wait(0.45)
    end
end)

-- 7. Pets & Eggs Loop (Auto Hatch, Skip Hatch, Equip Best, Auto Fuse, Auto Sell Weak)
task.spawn(function()
    while State.Running do
        if State.SkipHatchAnim and HatchEggController.IsBusy() then
            pcall(HatchEggController.CallOff)
        end

        local ownedPets = jsonDecodeSafe(LocalPlayer:GetAttribute(PetsConfig.Attributes.Owned), {})
        local equippedList = jsonDecodeSafe(LocalPlayer:GetAttribute(PetsConfig.Attributes.Equipped), {})
        local equippedSet = {}
        for _, id in ipairs(equippedList) do
            equippedSet[id] = true
        end

        if State.AutoHatchEgg then
            local zone = parseZoneChoice(State.EggZone)
            local eggSpec = PetsConfig.Eggs[zone]
            local eggore = safeNum("Eggore", 0)
            local petCount = 0
            for _ in pairs(ownedPets) do petCount = petCount + 1 end
            local hatchRemote = getRemote(RemotesFolder, PetsConfig.Remotes.Hatch)
            if hatchRemote and eggSpec and eggore >= eggSpec.Price and petCount < PetsConfig.Storage then
                if not HatchEggController.IsBusy() or State.SkipHatchAnim then
                    hatchRemote:FireServer(zone)
                end
            end
        end

        if State.AutoEquipBestPets then
            local bestRemote = getRemote(RemotesFolder, PetsConfig.Remotes.EquipBest)
            if bestRemote then
                bestRemote:FireServer()
            end
        end

        if State.AutoFusePets then
            local fuseRemote = getRemote(RemotesFolder, FuseConfig.Remotes.Fuse)
            if fuseRemote then
                local groups = {}
                for petId, petKey in pairs(ownedPets) do
                    local spec = PetsConfig.Pets[petKey]
                    if spec and spec.FusesInto and not equippedSet[petId] then
                        groups[petKey] = groups[petKey] or {}
                        table.insert(groups[petKey], petId)
                    end
                end
                for _, ids in pairs(groups) do
                    if #ids >= FuseConfig.Count then
                        local bundle = { ids[1], ids[2], ids[3] }
                        fuseRemote:FireServer(bundle)
                        break
                    end
                end
            end
        end

        if State.AutoSellWeakPets then
            local sellPetRemote = getRemote(RemotesFolder, PetsConfig.Remotes.Sell)
            if sellPetRemote then
                local sellRaritySet = {}
                if type(State.AutoSellRarities) == "table" then
                    for _, r in ipairs(State.AutoSellRarities) do
                        sellRaritySet[r] = true
                    end
                end
                for petId, petKey in pairs(ownedPets) do
                    if not equippedSet[petId] then
                        local spec = PetsConfig.Pets[petKey]
                        if spec and spec.Sellable ~= false and sellRaritySet[spec.Rarity] then
                            sellPetRemote:FireServer(petId)
                            task.wait(0.08)
                        end
                    end
                end
            end
        end

        task.wait(0.5)
    end
end)

-- 8. World Events, Rewards & ESP Loop + Dashboard Telemetry
task.spawn(function()
    while State.Running do
        -- Auto Collect Blue Ore Rain
        if State.AutoBlueOres then
            local blueRemote = getRemote(RemotesFolder, "BlueOreRain")
            local holder = workspace:FindFirstChild("BlueOreRain")
            if blueRemote and holder then
                for _, obj in ipairs(holder:GetChildren()) do
                    local dropId = obj:GetAttribute("OreRainId")
                    if dropId then
                        blueRemote:FireServer("claim", dropId)
                    end
                end
            end
        end

        -- Auto Collect Egg Rain
        if State.AutoEggRain then
            local eggRainRemote = getRemote(RemotesFolder, "EggRain")
            for _, holderName in ipairs({ "EggRain", "EggRainGlowing" }) do
                local holder = workspace:FindFirstChild(holderName)
                if eggRainRemote and holder then
                    for _, obj in ipairs(holder:GetChildren()) do
                        local dropId = obj:GetAttribute("EggRainId")
                        if dropId then
                            eggRainRemote:FireServer("claim", dropId)
                        end
                    end
                end
            end
        end

        -- Auto Claim Rewards
        if State.AutoClaimRewards then
            local offRemote = getRemote(RemotesFolder, OfflineConfig.Remote)
            if offRemote and LocalPlayer:GetAttribute(OfflineConfig.StrengthAttribute) then
                offRemote:FireServer()
            end
            local dailyRemote = getRemote(NetworkFolder, DailyRewardConfig.RemoteName)
            if dailyRemote then
                local st = DailyRewardConfig.StateAt(
                    safeNum(DailyRewardConfig.ClaimedAttribute, 0),
                    safeNum(DailyRewardConfig.UnlockAtAttribute, 0),
                    workspace:GetServerTimeNow()
                )
                if st.CanClaim and st.NextDay then
                    dailyRemote:FireServer(st.NextDay)
                end
            end
            local grpRemote = getRemote(RemotesFolder, "GroupReward")
            if grpRemote and LocalPlayer:GetAttribute("GroupRewardClaimed") ~= true then
                grpRemote:FireServer()
            end
            local wkRemote = getRemote(RemotesFolder, WeeklyChallengeConfig.Remote)
            if wkRemote and LocalPlayer:GetAttribute(WeeklyChallengeConfig.Attributes.Claimed) ~= true then
                local line = WeeklyChallengeConfig.LineOf(safeNum(WeeklyChallengeConfig.Attributes.Line, 1))
                local allDone = true
                for k, req in pairs(line.Quests) do
                    if safeNum(WeeklyChallengeConfig.Attributes[k], 0) < req then
                        allDone = false
                        break
                    end
                end
                if allDone then
                    wkRemote:FireServer(WeeklyChallengeConfig.Actions.Claim)
                end
            end
        end

        -- Auto Blue Titan Jump
        if State.AutoTitanJump then
            if LocalPlayer:GetAttribute(WeeklyChallengeConfig.Attributes.JumpReady) == true then
                local wkRemote = getRemote(RemotesFolder, WeeklyChallengeConfig.Remote)
                if wkRemote then
                    wkRemote:FireServer(WeeklyChallengeConfig.Actions.Activate)
                end
            end
        end

        -- Secret & Eggore ESP
        if State.SecretEsp then
            clearEsp()
            local fields = getMineFieldsTable()
            if fields then
                EspFolder = Instance.new("Folder")
                EspFolder.Name = "XLunaHUB_SecretESP"
                EspFolder.Parent = CoreGui

                local highest = ZoneConfig.HighestOf(LocalPlayer)
                local _, _, hrp = getChar()
                local myPos = hrp and hrp.Position or Vector3.zero

                for z = 1, highest do
                    local field = fields[z]
                    local data = field and field.Data
                    if data and data.Grid and data.SecretCells then
                        local grid = data.Grid
                        for _, cellKey in pairs(data.SecretCells) do
                            local x, y, zc = BlockGrid.Unkey(cellKey)
                            if BlockGrid.IsSolid(grid, x, y, zc) then
                                local pos = BlockGrid.Position(grid, x, y, zc)
                                local marker = Instance.new("Part")
                                marker.Name = "SecretMarker"
                                marker.Anchored = true
                                marker.CanCollide = false
                                marker.CanQuery = false
                                marker.CanTouch = false
                                marker.Transparency = 0.55
                                marker.Color = Color3.fromRGB(255, 65, 190)
                                marker.Material = Enum.Material.Neon
                                marker.Size = grid.BlockSize
                                marker.CFrame = CFrame.new(pos)
                                marker.Parent = EspFolder

                                local bb = Instance.new("BillboardGui")
                                bb.Size = UDim2.fromOffset(140, 40)
                                bb.AlwaysOnTop = true
                                bb.Adornee = marker
                                bb.Parent = marker

                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.fromScale(1, 1)
                                lbl.BackgroundTransparency = 1
                                lbl.TextColor3 = Color3.fromRGB(255, 215, 110)
                                lbl.TextStrokeTransparency = 0.2
                                lbl.Font = Enum.Font.GothamBold
                                lbl.TextSize = 12
                                lbl.Text = string.format("SECRET [Z%d | %.0fm]", z, (pos - myPos).Magnitude)
                                lbl.Parent = bb
                            end
                        end
                    end
                end
            end
        end

        -- Update Dashboard Telemetry
        pcall(function()
            local strength = safeNum("Strength", 1)
            local level = Levels.Of(strength)
            local rebirths = safeNum("Rebirths", 0)
            local reqLv = RebirthConfig.LevelRequirementFor(rebirths)
            local money = safeNum("Money", 0)
            local zone = ZoneConfig.HighestOf(LocalPlayer)
            local zInfo = ZoneConfig.Get(zone)
            local slamsL = safeNum(MineConfig.Slam.LeftAttribute, 0)
            local slamsM = safeNum(MineConfig.Slam.MaxAttribute, 3)
            local oreCount = safeNum(LootConfig.CountAttribute, 0)
            local eggore = safeNum("Eggore", 0)
            local activePad = LocalPlayer:GetAttribute(TrainingConfig.PadAttribute) or "None"

            ensureIdentity()
            StatsParagraph:SetDesc(string.format(
                "Strength (KG): %s  |  Level: %d (Rebirth @ %d)\nRebirths: %d  |  Money: %s  |  Eggore: %s\nZone: %d (%s)  |  Slams: %d/%d  |  Ores: %d\nActive Training Pad: %s",
                MoneyFormat.Abbreviate(strength),
                level,
                reqLv,
                rebirths,
                MoneyFormat.Price(money),
                MoneyFormat.Abbreviate(eggore),
                zone,
                zInfo and zInfo.Name or "Unknown",
                slamsL,
                slamsM,
                oreCount,
                tostring(activePad)
            ))
        end)

        task.wait(0.6)
    end
end)

ensureIdentity()
WindUI:Notify({
    Title = "XLunaHUB",
    Content = "+1 Crush The Floor! loaded. Press LeftCTRL or use the floating button.",
    Duration = 4,
})
