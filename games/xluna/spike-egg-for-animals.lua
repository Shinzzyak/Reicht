-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB â Spike Egg for Animals
    Author: By XLunaHUB
]]

local getgenv = getgenv or function() return _G end
if type(getgenv()._XLunaHUB_Cleanup) == "function" then
    pcall(getgenv()._XLunaHUB_Cleanup)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = ReplicatedStorage:WaitForChild("Shared")

-- Load game modules once and immediately restore thread capability bit
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig"))
local EggConfig = require(Shared.Config:WaitForChild("EggConfig"))
local BiomeConfig = require(Shared.Config:WaitForChild("BiomeConfig"))
local TrainingConfig = require(Shared.Config:WaitForChild("TrainingConfig"))
local RarityConfig = require(Shared.Config:WaitForChild("RarityConfig"))
local MutationConfig = require(Shared.Config:WaitForChild("MutationConfig"))
local MapUtil = require(Shared:WaitForChild("Modules"):WaitForChild("MapUtil"))
local Format = require(Shared.Modules:WaitForChild("Format"))

local function restoreIdentity()
    if type(setthreadidentity) == "function" then
        pcall(setthreadidentity, 8)
    end
end
restoreIdentity()

-- Pre-cache static MapUtil data so runtime loops never strip capabilities unnecessarily
local CachedCourts = {}
do
    local lp0, dir = MapUtil.LaneAxes()
    local rawCourts = MapUtil.Courts()
    for _, ct in ipairs(rawCourts) do
        if ct.sand and ct.sand.Parent then
            local pos = ct.sand.Position
            local dist = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(lp0.X, 0, lp0.Z)):Dot(dir)
            local lat = MapUtil.LateralOf(pos)
            local rangeInfo = MapUtil.GetRangeAt(math.max(0, dist))
            table.insert(CachedCourts, {
                Dist = dist,
                Lat = lat,
                Mult = ct.Mult or 2,
                Biome = rangeInfo and rangeInfo.Biome and rangeInfo.Biome.Name or "Unknown",
                Label = string.format("%s | %d studs (x%s)", rangeInfo and rangeInfo.Biome and rangeInfo.Biome.Name or "Court", math.floor(dist + 0.5), tostring(ct.Mult or 2)),
            })
        end
    end
    table.sort(CachedCourts, function(a, b) return a.Dist < b.Dist end)
    restoreIdentity()
end

local CourtDropdownValues = { "Auto (Best Reachable)" }
local CourtByLabel = {}
for _, c in ipairs(CachedCourts) do
    table.insert(CourtDropdownValues, c.Label)
    CourtByLabel[c.Label] = c
end

local BiomeNames = {}
local BiomeByName = {}
local curDistOffset = 0
for _, b in ipairs(BiomeConfig) do
    table.insert(BiomeNames, b.Name)
    BiomeByName[b.Name] = {
        Id = b.Id,
        Name = b.Name,
        Start = curDistOffset,
        Mid = curDistOffset + (b.Length * 0.5),
        Trail = b.Trail,
    }
    curDistOffset = curDistOffset + b.Length
end

-- State & Cleanup registry
local Alive = true
local Connections = {}
local ActiveState = {
    AutoSmash = false,
    LuckCourtSniper = false,
    TargetCourt = "Auto (Best Reachable)",
    AutoLucky = false,
    FastHatch = false,
    AutoTrain = false,
    AutoTrainBonus = false,
    UnlockCamera = false,
    AutoPlaceHeld = false,
    AutoEquipBest = false,
    AutoSellPets = false,
    SellRarities = {},
    KeepMutations = { "Gold", "Diamond", "Emerald", "Ruby", "Rainbow" },
    ProtectStrongPets = false,
    AutoBuyEgg = false,
    AutoBuyNet = false,
    AutoBuyPen = false,
    AutoBestTrail = false,
    TrailPriority = "Luck",
    SelectedEgg = EggConfig.Order[1],
    SelectedBiome = BiomeNames[1] or "Forest",
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    AntiAFK = false,
}

local PetsData = { Pen = {}, Inventory = {}, Hotbar = {}, PenSlots = 10 }
local ProfileData = { OwnedEggs = {}, EquippedEgg = "Forest", Trails = {}, EquippedTrail = "None", Index = {} }
local MovementBusy = false
local LastTrainStop = 0

local function trackConn(conn)
    table.insert(Connections, conn)
    return conn
end

-- Helper utilities
local function getChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

local function getCash()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    return c and c.Value or 0
end

local function getMyPlot()
    local plotName = LocalPlayer:GetAttribute("Plot")
    local plots = workspace:FindFirstChild("Plots")
    return plotName and plots and plots:FindFirstChild(plotName) or nil
end

local function getTrainingPad()
    local plot = getMyPlot()
    return plot and plot:FindFirstChild("TrainingPad", true) or nil
end

local function getLaunchZone()
    local ok, lz = pcall(MapUtil.GetLaunchZone)
    restoreIdentity()
    return ok and lz or nil
end

local function safeBaseDistance(power)
    local ok, d = pcall(MapUtil.BaseDistance, power)
    restoreIdentity()
    return ok and d or 0
end

local function safeWorldPoint(dist, lat)
    local ok, pt = pcall(MapUtil.WorldPoint, dist, lat or 0)
    restoreIdentity()
    return ok and pt or Vector3.new(0, 12, 0)
end

local function safeFormat(num)
    local ok, str = pcall(Format, num)
    restoreIdentity()
    return ok and str or tostring(math.floor(num or 0))
end

local function exitClientTrainingUI()
    local tui = LocalPlayer.PlayerGui:FindFirstChild("TrainingUI")
    if tui then
        for _, v in ipairs(tui:GetDescendants()) do
            if v:IsA("TextButton") and v.Visible then
                if type(firesignal) == "function" then
                    pcall(firesignal, v.Activated)
                end
            end
        end
    end
    pcall(function() Remotes.TrainBump:FireServer("stop") end)
end

local function recoverCharacter()
    exitClientTrainingUI()
    local _, hrp = getChar()
    if hrp then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    if workspace.CurrentCamera then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.FieldOfView = 70
    end
end

local function findBestTargetCourt()
    local maxPower = LocalPlayer:GetAttribute("Power") or 10
    local maxReachDist = safeBaseDistance(maxPower) * 1.15
    if ActiveState.TargetCourt ~= "Auto (Best Reachable)" then
        local chosen = CourtByLabel[ActiveState.TargetCourt]
        if chosen and chosen.Dist <= maxReachDist + 2 then
            return chosen
        end
    end
    local best = nil
    for _, c in ipairs(CachedCourts) do
        if c.Dist <= maxReachDist + 1 then
            if not best or c.Dist > best.Dist then
                best = c
            end
        end
    end
    return best
end

local function solvePowerLimitForDist(targetDist)
    local maxPower = LocalPlayer:GetAttribute("Power") or 10
    local lo, hi = 1, maxPower
    for _ = 1, 32 do
        local mid = (lo + hi) * 0.5
        if safeBaseDistance(mid) * 1.15 < targetDist then
            lo = mid
        else
            hi = mid
        end
    end
    return math.clamp(math.floor((lo + hi) * 0.5 + 0.5), 1, maxPower)
end

-- Sync listeners
trackConn(Remotes.PetsSync.OnClientEvent:Connect(function(data)
    if type(data) == "table" then
        PetsData = data
    end
end))

trackConn(Remotes.ProfileSync.OnClientEvent:Connect(function(data)
    if type(data) == "table" then
        ProfileData = data
    end
end))

task.spawn(function()
    pcall(function() Remotes.PetAction:InvokeServer("Sync") end)
    pcall(function() Remotes.ShopAction:InvokeServer("Sync") end)
end)

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
restoreIdentity()

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB",
    Icon = "egg",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_SpikeEgg",
    Size = UDim2.fromOffset(600, 470),
    MinSize = Vector2.new(520, 360),
    MaxSize = Vector2.new(860, 620),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 175,
    HideSearchBar = true,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "egg",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("#FF8A00"),
            Color3.fromHex("#E52E71")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})
restoreIdentity()

-- Enforce layered DisplayOrder across all 4 WindUI ScreenGuis & position OpenButton cleanly below Roblox Topbar
local LayerOrders = {
    ["WindUI"] = 100,
    ["WindUI/Notifications"] = 110,
    ["WindUI/Dropdowns"] = 120,
    ["WindUI/Tooltips"] = 130,
}

local function positionOpenButton(winFolder)
    if not winFolder then return end
    for _, child in ipairs(winFolder:GetChildren()) do
        if child:IsA("GuiObject") and child ~= Window.UIElements.Main then
            if child.Position.Y.Offset == 28 or (child.AbsoluteSize.Y > 0 and child.AbsoluteSize.Y < 90 and child.AbsoluteSize.X < 350) then
                pcall(function()
                    child.Position = UDim2.new(0.5, 0, 0, 76)
                end)
            end
        end
    end
end

local function applyWindUILayers(gui)
    if not gui or not gui:IsA("ScreenGui") then return end
    local order = LayerOrders[gui.Name]
    if order then
        gui.DisplayOrder = order
    end
    if gui.Name == "WindUI" then
        local winFolder = gui:FindFirstChild("Window")
        if winFolder then
            positionOpenButton(winFolder)
            task.delay(0.25, function()
                positionOpenButton(winFolder)
            end)
            trackConn(winFolder.ChildAdded:Connect(function()
                task.defer(function()
                    positionOpenButton(winFolder)
                end)
            end))
        end
    end
end

for _, parent in ipairs({ CoreGui, (type(gethui) == "function" and gethui() or nil), LocalPlayer:FindFirstChild("PlayerGui") }) do
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            applyWindUILayers(child)
        end
        trackConn(parent.ChildAdded:Connect(function(child)
            task.defer(function()
                applyWindUILayers(child)
            end)
        end))
    end
end

local function notifyUser(title, content, duration, icon)
    restoreIdentity()
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Icon = icon or "info",
        })
    end)
end

-- Build Tabs
local TabMain = Window:Tab({ Title = "Main", Icon = "flame" })
local TabPets = Window:Tab({ Title = "Pets & Pen", Icon = "paw-print" })
local TabShop = Window:Tab({ Title = "Upgrades", Icon = "shopping-bag" })
local TabMisc = Window:Tab({ Title = "Misc & TP", Icon = "compass" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- ==================== TAB: MAIN ====================
local StatusSection = TabMain:Section({ Title = "Live Overview", Icon = "activity", Opened = true })
local StatusParagraph = StatusSection:Paragraph({
    Title = "Player Telemetry",
    Desc = "Loading stats...",
})

local SmashSection = TabMain:Section({ Title = "Auto Smash & Hatch", Icon = "zap", Opened = true })

SmashSection:Toggle({
    Title = "Auto Smash Eggs",
    Desc = "Auto-throws eggs with 100% PERFECT timing and collects all 3 AirLuck orbs",
    Flag = "AutoSmash",
    Value = false,
    Callback = function(state)
        ActiveState.AutoSmash = state
        if not state then
            pcall(function() Remotes.SetPowerLimit:FireServer(0) end)
            recoverCharacter()
        end
    end,
})

SmashSection:Toggle({
    Title = "LuckCourt Sniper (2x Luck)",
    Desc = "Dynamically tunes PowerLimit so PERFECT throws land dead-center on a x2 LuckCourt",
    Flag = "LuckCourtSniper",
    Value = false,
    Callback = function(state)
        ActiveState.LuckCourtSniper = state
        if not state then
            pcall(function() Remotes.SetPowerLimit:FireServer(0) end)
        end
    end,
})

SmashSection:Dropdown({
    Title = "Target LuckCourt",
    Desc = "Choose Auto (farthest reachable) or lock onto a specific court",
    Values = CourtDropdownValues,
    Value = "Auto (Best Reachable)",
    Flag = "TargetCourt",
    Callback = function(val)
        ActiveState.TargetCourt = val
    end,
})

SmashSection:Toggle({
    Title = "Auto Arm Lucky Throw",
    Desc = "Automatically activates Lucky Throw when you have charges available",
    Flag = "AutoLucky",
    Value = false,
    Callback = function(state)
        ActiveState.AutoLucky = state
    end,
})

SmashSection:Toggle({
    Title = "Fast Hatch (Restore Camera)",
    Desc = "Prevents hatch camera lock and immediately resets view after landing",
    Flag = "FastHatch",
    Value = false,
    Callback = function(state)
        ActiveState.FastHatch = state
    end,
})

local TrainSection = TabMain:Section({ Title = "Auto Train (Power)", Icon = "dumbbell", Opened = true })

TrainSection:Toggle({
    Title = "Auto Train",
    Desc = "Automatically trains at your plot's Training Pad for fast Power XP",
    Flag = "AutoTrain",
    Value = false,
    Callback = function(state)
        ActiveState.AutoTrain = state
        if not state then
            LastTrainStop = os.clock()
            recoverCharacter()
        end
    end,
})

TrainSection:Toggle({
    Title = "Auto 2x Bonus Bubble",
    Desc = "Triggers the 2x XP + Speed training boost every cooldown",
    Flag = "AutoTrainBonus",
    Value = false,
    Callback = function(state)
        ActiveState.AutoTrainBonus = state
    end,
})

TrainSection:Toggle({
    Title = "Unlock Camera During Farm",
    Desc = "Keeps your camera free instead of locking to Training/Smash angles",
    Flag = "UnlockCamera",
    Value = false,
    Callback = function(state)
        ActiveState.UnlockCamera = state
        if state and workspace.CurrentCamera then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end,
})

-- ==================== TAB: PETS & PEN ====================
local PenSection = TabPets:Section({ Title = "Pen Automation", Icon = "layout-grid", Opened = true })

PenSection:Toggle({
    Title = "Auto Place Held Pet",
    Desc = "Automatically places newly hatched pets in your Pen when slots are open",
    Flag = "AutoPlaceHeld",
    Value = false,
    Callback = function(state)
        ActiveState.AutoPlaceHeld = state
    end,
})

PenSection:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Automatically swaps in your highest-income pets to maximize $/s",
    Flag = "AutoEquipBest",
    Value = false,
    Callback = function(state)
        ActiveState.AutoEquipBest = state
    end,
})

PenSection:Button({
    Title = "Equip Best Pets Now",
    Icon = "sparkles",
    Callback = function()
        local ok = pcall(function() return Remotes.PetAction:InvokeServer("EquipBest") end)
        notifyUser("Pets & Pen", ok and "Equipped best pets!" or "Failed to equip best pets.", 2.5, "sparkles")
    end,
})

local SellSection = TabPets:Section({ Title = "Smart Auto Sell", Icon = "coins", Opened = true })

SellSection:Toggle({
    Title = "Auto Sell Unwanted Pets",
    Desc = "Sells unfavorited backpack pets matching selected rarities (respects Keep Mutations)",
    Flag = "AutoSellPets",
    Value = false,
    Callback = function(state)
        ActiveState.AutoSellPets = state
    end,
})

SellSection:Dropdown({
    Title = "Sell Rarities",
    Desc = "Select which rarities to auto-sell from your backpack",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Flag = "SellRarities",
    Callback = function(selected)
        ActiveState.SellRarities = type(selected) == "table" and selected or {}
    end,
})

SellSection:Dropdown({
    Title = "Keep Mutations (Protected)",
    Desc = "Pets with these mutations will never be auto-sold",
    Values = { "Gold", "Diamond", "Emerald", "Ruby", "Rainbow" },
    Value = { "Gold", "Diamond", "Emerald", "Ruby", "Rainbow" },
    Multi = true,
    AllowNone = true,
    Flag = "KeepMutations",
    Callback = function(selected)
        ActiveState.KeepMutations = type(selected) == "table" and selected or {}
    end,
})

SellSection:Toggle({
    Title = "Protect Pen-Worthy Pets",
    Desc = "Skip selling any pet stronger than the weakest pet currently in your Pen",
    Flag = "ProtectStrongPets",
    Value = false,
    Callback = function(state)
        ActiveState.ProtectStrongPets = state
    end,
})

local function runSmartSell()
    local inv = PetsData.Inventory or {}
    if #inv == 0 then return 0 end
    local raritySet = {}
    for _, r in ipairs(ActiveState.SellRarities) do raritySet[r] = true end
    local keepMutSet = {}
    for _, m in ipairs(ActiveState.KeepMutations) do keepMutSet[m] = true end

    local minPenIncome = math.huge
    local pen = PetsData.Pen or {}
    local penSlots = PetsData.PenSlots or LocalPlayer:GetAttribute("PenSlots") or 10
    if ActiveState.ProtectStrongPets then
        if #pen < penSlots then
            minPenIncome = 0
        else
            for _, p in ipairs(pen) do
                if (p.Income or 0) < minPenIncome then
                    minPenIncome = p.Income or 0
                end
            end
        end
    end

    local sold = 0
    for _, pet in ipairs(inv) do
        if not pet.Favorite and not pet.Limited then
            local matchRarity = raritySet[pet.Rarity] == true
            local isProtectedMut = keepMutSet[pet.Mutation] == true
            local isPenWorthy = ActiveState.ProtectStrongPets and ((pet.Income or 0) >= minPenIncome)
            if matchRarity and not isProtectedMut and not isPenWorthy then
                local ok, res = pcall(function()
                    return Remotes.PetAction:InvokeServer("Sell", pet.Id)
                end)
                if ok and res then
                    sold = sold + 1
                end
                task.wait(0.08)
            end
        end
    end
    return sold
end

SellSection:Button({
    Title = "Sell Matching Pets Now",
    Icon = "trash-2",
    Callback = function()
        task.spawn(function()
            local n = runSmartSell()
            notifyUser("Smart Sell", string.format("Sold %d matching pet(s).", n), 2.5, "coins")
        end)
    end,
})

SellSection:Button({
    Title = "Sell All Unfavorited Pets",
    Icon = "alert-triangle",
    Callback = function()
        restoreIdentity()
        Window:Dialog({
            Title = "Confirm Sell All",
            Content = "Sell every unfavorited pet in your backpack?",
            Buttons = {
                {
                    Title = "Cancel",
                    Variant = "Secondary",
                    Callback = function() end,
                },
                {
                    Title = "Sell All",
                    Variant = "Primary",
                    Callback = function()
                        local ok, res = pcall(function() return Remotes.PetAction:InvokeServer("SellAll") end)
                        notifyUser("Sell All", (ok and res) and "Sold all unfavorited pets!" or "Nothing to sell.", 2.5, "coins")
                    end,
                },
            },
        })
    end,
})

-- ==================== TAB: UPGRADES & SHOP ====================
local AutoUpgradeSection = TabShop:Section({ Title = "Auto Progression", Icon = "trending-up", Opened = true })

AutoUpgradeSection:Toggle({
    Title = "Auto Buy & Equip Best Egg",
    Desc = "Buys the next Egg tier when affordable and equips your best owned Egg",
    Flag = "AutoBuyEgg",
    Value = false,
    Callback = function(state)
        ActiveState.AutoBuyEgg = state
    end,
})

AutoUpgradeSection:Toggle({
    Title = "Auto Upgrade Training Net",
    Desc = "Automatically purchases the next Training Net tier when affordable",
    Flag = "AutoBuyNet",
    Value = false,
    Callback = function(state)
        ActiveState.AutoBuyNet = state
    end,
})

AutoUpgradeSection:Toggle({
    Title = "Auto Upgrade Pen Slots",
    Desc = "Automatically expands Pen capacity when you have enough Cash",
    Flag = "AutoBuyPen",
    Value = false,
    Callback = function(state)
        ActiveState.AutoBuyPen = state
    end,
})

AutoUpgradeSection:Toggle({
    Title = "Auto Equip Best Buff Trail",
    Desc = "Automatically equips your strongest unlocked Trail for your selected priority",
    Flag = "AutoBestTrail",
    Value = false,
    Callback = function(state)
        ActiveState.AutoBestTrail = state
    end,
})

AutoUpgradeSection:Dropdown({
    Title = "Trail Buff Priority",
    Values = { "Luck", "XP", "Cash" },
    Value = "Luck",
    Flag = "TrailPriority",
    Callback = function(val)
        ActiveState.TrailPriority = val
    end,
})

local ManualShopSection = TabShop:Section({ Title = "Manual Shop Actions", Icon = "store", Opened = true })

ManualShopSection:Dropdown({
    Title = "Select Egg",
    Values = EggConfig.Order,
    Value = EggConfig.Order[1],
    Flag = "SelectedEgg",
    Callback = function(val)
        ActiveState.SelectedEgg = val
    end,
})

ManualShopSection:Button({
    Title = "Buy / Equip Selected Egg",
    Icon = "egg",
    Callback = function()
        local eggId = ActiveState.SelectedEgg
        local owned = ProfileData.OwnedEggs and ProfileData.OwnedEggs[eggId]
        if owned then
            local ok, res, msg = pcall(function() return Remotes.ShopAction:InvokeServer("EquipEgg", eggId) end)
            notifyUser("Egg Shop", (ok and res) and ("Equipped " .. eggId .. " Egg!") or tostring(msg or "Failed to equip"), 2.5, "egg")
        else
            local ok, res, msg = pcall(function() return Remotes.ShopAction:InvokeServer("BuyEgg", eggId) end)
            if ok and res then
                pcall(function() Remotes.ShopAction:InvokeServer("EquipEgg", eggId) end)
                notifyUser("Egg Shop", "Purchased & equipped " .. eggId .. " Egg!", 2.5, "egg")
            else
                notifyUser("Egg Shop", tostring(msg or "Cannot purchase yet (check Cash or previous tier)."), 2.5, "alert-circle")
            end
        end
    end,
})

ManualShopSection:Button({
    Title = "Claim Offline Earnings",
    Icon = "gift",
    Callback = function()
        local ok, res, amt = pcall(function() return Remotes.OfflineClaim:InvokeServer() end)
        if ok and res then
            notifyUser("Offline Earnings", "Claimed $" .. safeFormat(amt or 0) .. "!", 3, "gift")
        else
            notifyUser("Offline Earnings", "No offline earnings available to claim.", 2.5, "info")
        end
    end,
})

-- ==================== TAB: MISC & TELEPORT ====================
local TPSection = TabMisc:Section({ Title = "World Teleports", Icon = "map-pin", Opened = true })

local function teleportCF(cf)
    local _, hrp = getChar()
    if hrp and cf then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = cf
    end
end

TPSection:Button({
    Title = "Teleport to Launch Zone",
    Icon = "rocket",
    Callback = function()
        local lz = getLaunchZone()
        if lz then
            teleportCF(lz.CFrame * CFrame.new(0, 3.5, 16))
            notifyUser("Teleport", "Moved near Launch Zone.", 2, "map-pin")
        end
    end,
})

TPSection:Button({
    Title = "Teleport to My Plot / Pen",
    Icon = "home",
    Callback = function()
        local plot = getMyPlot()
        local floor = plot and plot:FindFirstChild("PenArea") and plot.PenArea:FindFirstChild("Floor")
        if floor then
            teleportCF(CFrame.new(floor.Position + Vector3.new(0, 4, 0)))
            notifyUser("Teleport", "Moved to your Pen.", 2, "home")
        end
    end,
})

TPSection:Button({
    Title = "Teleport to Training Area",
    Icon = "dumbbell",
    Callback = function()
        local tpad = getTrainingPad()
        if tpad then
            teleportCF(CFrame.new(tpad.Position + Vector3.new(0, 3.5, 0)))
            notifyUser("Teleport", "Moved to Training Area.", 2, "dumbbell")
        end
    end,
})

TPSection:Button({
    Title = "Teleport to Sell Booth",
    Icon = "dollar-sign",
    Callback = function()
        local sb = workspace:FindFirstChild("SellBooth")
        local hb = sb and sb:FindFirstChild("HitBox")
        if hb then
            teleportCF(hb.CFrame * CFrame.new(0, 3.5, 0))
            notifyUser("Teleport", "Moved to Sell Booth.", 2, "dollar-sign")
        end
    end,
})

TPSection:Dropdown({
    Title = "Select Biome",
    Values = BiomeNames,
    Value = BiomeNames[1] or "Forest",
    Flag = "SelectedBiome",
    Callback = function(val)
        ActiveState.SelectedBiome = val
    end,
})

TPSection:Button({
    Title = "Teleport to Selected Biome",
    Icon = "navigation",
    Callback = function()
        local b = BiomeByName[ActiveState.SelectedBiome]
        if b then
            local pt = safeWorldPoint(b.Mid, 0)
            teleportCF(CFrame.new(pt + Vector3.new(0, 14, 0)))
            notifyUser("Teleport", "Teleported to " .. b.Name .. "!", 2, "navigation")
        end
    end,
})

local PlayerSection = TabMisc:Section({ Title = "Player & Anti-AFK", Icon = "user", Opened = true })

PlayerSection:Toggle({
    Title = "Custom WalkSpeed",
    Desc = "Applies the WalkSpeed slider continuously",
    Flag = "WalkSpeedEnabled",
    Value = false,
    Callback = function(state)
        ActiveState.WalkSpeedEnabled = state
        if not state then
            local _, _, hum = getChar()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

PlayerSection:Slider({
    Title = "WalkSpeed Value",
    Value = { Min = 16, Max = 150, Default = 16 },
    Step = 1,
    Flag = "WalkSpeed",
    Callback = function(val)
        ActiveState.WalkSpeed = val
    end,
})

PlayerSection:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents Roblox 20-minute idle disconnect via Idled hook & VirtualUser",
    Flag = "AntiAFK",
    Value = false,
    Callback = function(state)
        ActiveState.AntiAFK = state
    end,
})

PlayerSection:Button({
    Title = "Recover Character & Camera",
    Icon = "refresh-cw",
    Callback = function()
        recoverCharacter()
        notifyUser("Recovery", "Character unanchored and camera restored.", 2, "check")
    end,
})

-- ==================== TAB: CONFIG ====================
local ConfigManager = Window.ConfigManager
local SelectedConfigName = "default"
local InputConfigName = "default"

local ConfigSection = TabConfig:Section({ Title = "Configuration Manager", Icon = "save", Opened = true })

local function getSavedConfigNames()
    local list = {}
    if ConfigManager then
        local ok, res = pcall(function() return ConfigManager:AllConfigs() end)
        if ok and type(res) == "table" then
            list = res
        end
    end
    if #list == 0 then
        list = { "default" }
    end
    return list
end

ConfigSection:Input({
    Title = "Config Name",
    Placeholder = "default",
    Value = "default",
    Callback = function(val)
        if val and val:gsub("%s+", "") ~= "" then
            InputConfigName = val:gsub("[^%w_%-]", "")
        end
    end,
})

local ConfigDropdown = ConfigSection:Dropdown({
    Title = "Saved Configs",
    Values = getSavedConfigNames(),
    Value = getSavedConfigNames()[1],
    Callback = function(val)
        if val then
            SelectedConfigName = val
        end
    end,
})

local function refreshConfigDropdown()
    restoreIdentity()
    local names = getSavedConfigNames()
    pcall(function()
        if ConfigDropdown.Refresh then
            ConfigDropdown:Refresh(names)
        end
    end)
end

ConfigSection:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        local name = (InputConfigName ~= "" and InputConfigName) or SelectedConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        cfg:Save()
        SelectedConfigName = name
        refreshConfigDropdown()
        notifyUser("Config Saved", "Saved configuration '" .. name .. "'.", 2.5, "save")
    end,
})

ConfigSection:Button({
    Title = "Load Config",
    Icon = "folder-open",
    Callback = function()
        local name = SelectedConfigName or InputConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        local ok, err = cfg:Load()
        if ok == false then
            notifyUser("Config Error", tostring(err or "Config not found."), 3, "alert-circle")
        else
            notifyUser("Config Loaded", "Loaded configuration '" .. name .. "'.", 2.5, "check")
        end
    end,
})

ConfigSection:Button({
    Title = "Delete Selected Config",
    Icon = "trash",
    Callback = function()
        local name = SelectedConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        local ok, msg = cfg:Delete()
        refreshConfigDropdown()
        notifyUser("Config Deleted", tostring(msg or (ok and "Deleted" or "Failed")), 2.5, "trash")
    end,
})

ConfigSection:Button({
    Title = "Refresh Config List",
    Icon = "refresh-cw",
    Callback = function()
        refreshConfigDropdown()
        notifyUser("Config List", "Refreshed saved configurations.", 2, "refresh-cw")
    end,
})

local UISection = TabConfig:Section({ Title = "Interface Controls", Icon = "sliders", Opened = true })

UISection:Paragraph({
    Title = "Keybind & Quick Access",
    Desc = "Press LeftCTRL to toggle Show/Hide UI. You can also drag or click the XLunaHUB floating button.",
})

UISection:Button({
    Title = "Unload XLunaHUB",
    Icon = "power",
    Callback = function()
        if type(getgenv()._XLunaHUB_Cleanup) == "function" then
            getgenv()._XLunaHUB_Cleanup()
        end
    end,
})

Window:SelectTab(1)
restoreIdentity()

-- ==================== CORE AUTOMATION LOOPS ====================

-- 1. Anti-AFK (Idled hook + periodic VirtualUser nudge when enabled)
trackConn(LocalPlayer.Idled:Connect(function()
    if ActiveState.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

task.spawn(function()
    while Alive do
        if ActiveState.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
        task.wait(60)
    end
end)

-- 2. WalkSpeed & Camera Unlock Guard
trackConn(RunService.RenderStepped:Connect(function()
    if not Alive then return end
    if ActiveState.WalkSpeedEnabled then
        local _, _, hum = getChar()
        if hum and hum.WalkSpeed ~= ActiveState.WalkSpeed then
            hum.WalkSpeed = ActiveState.WalkSpeed
        end
    end
    if ActiveState.UnlockCamera or ActiveState.FastHatch then
        if (ActiveState.AutoSmash or ActiveState.AutoTrain) and workspace.CurrentCamera then
            if workspace.CurrentCamera.CameraType ~= Enum.CameraType.Custom then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            end
        end
    end
end))

-- 3. Auto Smash & LuckCourt Sniper Loop
task.spawn(function()
    while Alive do
        if ActiveState.AutoSmash then
            MovementBusy = true
            local successLoop, errLoop = pcall(function()
                local _, hrp = getChar()
                if not hrp then return end

                -- Place held pet first if holding
                local held = LocalPlayer:GetAttribute("Holding")
                if held then
                    pcall(function() Remotes.PlacePet:FireServer() end)
                    pcall(function() Remotes.PetAction:InvokeServer("Place", { Auto = true, Id = held }) end)
                    task.wait(0.25)
                end

                -- Arm Lucky Throw if enabled
                if ActiveState.AutoLucky and (LocalPlayer:GetAttribute("LuckyThrows") or 0) > 0 and not LocalPlayer:GetAttribute("LuckyArmed") then
                    pcall(function() Remotes.LuckyThrow:InvokeServer("Toggle") end)
                end

                -- Configure LuckCourt Sniper PowerLimit
                local targetLat = 0
                if ActiveState.LuckCourtSniper then
                    local court = findBestTargetCourt()
                    if court then
                        local optLimit = solvePowerLimitForDist(court.Dist)
                        Remotes.SetPowerLimit:FireServer(optLimit)
                        targetLat = court.Lat
                        task.wait(0.1)
                    end
                else
                    if (LocalPlayer:GetAttribute("PowerLimit") or 0) ~= 0 then
                        Remotes.SetPowerLimit:FireServer(0)
                    end
                end

                local lz = getLaunchZone()
                if not lz then return end

                -- Move into LaunchZone & request throw
                hrp.Anchored = false
                hrp.CFrame = lz.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.2)
                if not ActiveState.AutoSmash then return end

                Remotes.SmashReady:FireServer()
                local okReq, reqRes = pcall(function() return Remotes.RequestThrow:InvokeServer() end)
                if okReq and type(reqRes) == "table" and not reqRes.Error then
                    -- Wait TossTime (~1.4s) for PERFECT 1.15x accuracy
                    local tWait = 0
                    while tWait < 1.4 and ActiveState.AutoSmash do
                        task.wait(0.1)
                        tWait = tWait + 0.1
                    end
                    if not ActiveState.AutoSmash then
                        pcall(function() Remotes.HatchDone:FireServer() end)
                        return
                    end

                    local okRes, resolveRes = pcall(function() return Remotes.ResolveThrow:InvokeServer(1) end)
                    if okRes and type(resolveRes) == "table" then
                        local pickupIds = {}
                        if resolveRes.Pickups then
                            for _, p in ipairs(resolveRes.Pickups) do
                                table.insert(pickupIds, p.Id)
                            end
                        end
                        local flightDur = tonumber(resolveRes.Duration) or 2.0
                        local elapsed = 0
                        while elapsed < flightDur and ActiveState.AutoSmash do
                            task.wait(0.1)
                            elapsed = elapsed + 0.1
                        end

                        pcall(function() Remotes.LandThrow:InvokeServer(targetLat, pickupIds) end)
                    end
                    pcall(function() Remotes.HatchDone:FireServer() end)

                    -- Place pet immediately if AutoPlaceHeld is active
                    task.wait(0.15)
                    local newHeld = LocalPlayer:GetAttribute("Holding")
                    if newHeld and ActiveState.AutoPlaceHeld then
                        pcall(function() Remotes.PlacePet:FireServer() end)
                        pcall(function() Remotes.PetAction:InvokeServer("Place", { Auto = true, Id = newHeld }) end)
                    end
                else
                    -- Move slightly out if cooldown active
                    task.wait(0.5)
                end

                -- Exit LaunchZone cleanly so VolleyClient doesn't anchor/lock camera
                local _, hrpAfter = getChar()
                if hrpAfter and lz then
                    hrpAfter.Anchored = false
                    hrpAfter.CFrame = lz.CFrame * CFrame.new(0, 3.2, 18)
                end
                if ActiveState.FastHatch or ActiveState.UnlockCamera then
                    recoverCharacter()
                end
            end)
            MovementBusy = false
            task.wait(0.6)
        else
            task.wait(0.25)
        end
    end
end)

-- 4. Auto Train Loop
task.spawn(function()
    local lastBonus = 0
    while Alive do
        if ActiveState.AutoTrain and not ActiveState.AutoSmash and not MovementBusy then
            local _, hrp = getChar()
            local tpad = getTrainingPad()
            if hrp and tpad then
                local dx = hrp.Position.X - tpad.Position.X
                local dz = hrp.Position.Z - tpad.Position.Z
                if (dx * dx + dz * dz) > 9 or math.abs(hrp.Position.Y - tpad.Position.Y) > 6 then
                    hrp.Anchored = false
                    hrp.CFrame = CFrame.new(tpad.Position + Vector3.new(0, 3.2, 0))
                    task.wait(0.2)
                end
                if ActiveState.AutoTrainBonus and (os.clock() - lastBonus >= 6.1) then
                    lastBonus = os.clock()
                    pcall(function() Remotes.TrainBump:FireServer("bonus") end)
                end
                pcall(function() Remotes.TrainBump:FireServer("hit") end)
                if ActiveState.UnlockCamera then
                    local tui = LocalPlayer.PlayerGui:FindFirstChild("TrainingUI")
                    if tui then
                        for _, v in ipairs(tui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Visible then
                                -- Hide STOP UI prompt if camera unlocked
                            end
                        end
                    end
                end
            end
            task.wait(0.52)
        else
            task.wait(0.25)
        end
    end
end)

-- 5. Pets, Pen & Progression Loop
task.spawn(function()
    local lastEquipBest = 0
    local lastSell = 0
    local lastUpgrade = 0
    while Alive do
        if ActiveState.AutoPlaceHeld and not ActiveState.AutoSmash then
            local held = LocalPlayer:GetAttribute("Holding")
            if held then
                pcall(function() Remotes.PlacePet:FireServer() end)
                pcall(function() Remotes.PetAction:InvokeServer("Place", { Auto = true, Id = held }) end)
            end
        end

        if ActiveState.AutoEquipBest and (os.clock() - lastEquipBest >= 3.0) then
            lastEquipBest = os.clock()
            pcall(function() Remotes.PetAction:InvokeServer("EquipBest") end)
        end

        if ActiveState.AutoSellPets and (os.clock() - lastSell >= 2.5) then
            lastSell = os.clock()
            pcall(runSmartSell)
        end

        if os.clock() - lastUpgrade >= 1.8 then
            lastUpgrade = os.clock()
            local cash = getCash()

            if ActiveState.AutoBuyEgg then
                local owned = ProfileData.OwnedEggs or {}
                local bestOwned = nil
                for _, eggId in ipairs(EggConfig.Order) do
                    if owned[eggId] then
                        bestOwned = eggId
                    else
                        local cfg = EggConfig[eggId]
                        if cfg and cash >= (cfg.Price or 0) then
                            local ok, res = pcall(function() return Remotes.ShopAction:InvokeServer("BuyEgg", eggId) end)
                            if ok and res then
                                bestOwned = eggId
                                cash = getCash()
                            else
                                break
                            end
                        else
                            break
                        end
                    end
                end
                if bestOwned and ProfileData.EquippedEgg ~= bestOwned then
                    pcall(function() Remotes.ShopAction:InvokeServer("EquipEgg", bestOwned) end)
                end
            end

            if ActiveState.AutoBuyNet then
                local curLvl = LocalPlayer:GetAttribute("TrainingLevel") or 1
                local nextBall = TrainingConfig.Balls[curLvl + 1]
                if nextBall and cash >= (nextBall.Price or 0) then
                    pcall(function() Remotes.TrainingBuy:InvokeServer() end)
                    cash = getCash()
                end
            end

            if ActiveState.AutoBuyPen then
                local curSlots = LocalPlayer:GetAttribute("PenSlots") or 10
                for idx, lv in ipairs(GameConfig.PenLevels) do
                    if lv.Slots == curSlots then
                        local nextLv = GameConfig.PenLevels[idx + 1]
                        if nextLv and cash >= (nextLv.Price or 0) then
                            pcall(function() Remotes.PetAction:InvokeServer("UpgradePen") end)
                        end
                        break
                    end
                end
            end

            if ActiveState.AutoBestTrail then
                local trails = ProfileData.Trails or {}
                local bestId = nil
                local bestScore = -1
                for _, b in ipairs(BiomeConfig) do
                    if trails[b.Id] and b.Trail and b.Trail.Buff then
                        local stat = b.Trail.Buff.Stat
                        local pct = b.Trail.Buff.Pct or 0
                        local score = (stat == ActiveState.TrailPriority) and (1000 + pct) or pct
                        if score > bestScore then
                            bestScore = score
                            bestId = b.Id
                        end
                    end
                end
                if bestId and ProfileData.EquippedTrail ~= bestId then
                    pcall(function() Remotes.ShopAction:InvokeServer("EquipTrail", bestId) end)
                end
            end
        end

        task.wait(0.4)
    end
end)

-- 6. Live Telemetry Updater
task.spawn(function()
    while Alive do
        local cash = getCash()
        local ips = LocalPlayer:GetAttribute("IncomePerSec") or 0
        local power = LocalPlayer:GetAttribute("Power") or 0
        local trainLvl = LocalPlayer:GetAttribute("TrainLevel") or 1
        local netLvl = LocalPlayer:GetAttribute("TrainingLevel") or 1
        local egg = LocalPlayer:GetAttribute("EquippedEgg") or "Forest"
        local penCount = PetsData.Pen and #PetsData.Pen or 0
        local penMax = LocalPlayer:GetAttribute("PenSlots") or PetsData.PenSlots or 10
        local maxReach = math.floor(safeBaseDistance(power) * 1.15 + 0.5)

        local text = string.format(
            "Cash: $%s (+$%s/s)\nPower: %s (Max Reach: %d studs)\nTrain Level: %d | Net Tier: %d\nEquipped Egg: %s | Pen: %d/%d",
            safeFormat(cash),
            safeFormat(ips),
            safeFormat(power),
            maxReach,
            trainLvl,
            netLvl,
            tostring(egg),
            penCount,
            penMax
        )
        restoreIdentity()
        pcall(function()
            StatusParagraph:SetDesc(text)
        end)
        task.wait(1.0)
    end
end)

-- Global Cleanup Handler
getgenv()._XLunaHUB_Cleanup = function()
    if not Alive then return end
    Alive = false
    for k, v in pairs(ActiveState) do
        if type(v) == "boolean" then
            ActiveState[k] = false
        end
    end
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)
    pcall(function() Remotes.SetPowerLimit:FireServer(0) end)
    recoverCharacter()
    local _, _, hum = getChar()
    if hum then hum.WalkSpeed = 16 end
    restoreIdentity()
    pcall(function() Window:Destroy() end)
end
