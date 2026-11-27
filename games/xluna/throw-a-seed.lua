-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--// XLunaHUB | Throw a Seed (placeId: 129081220403721)
--// Author: By XLunaHUB

local env = (getgenv and getgenv()) or _G
if type(env.XLunaHUB_TAS_Cleanup) == "function" then
    pcall(env.XLunaHUB_TAS_Cleanup)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer:GetAttribute("Loaded") do
    task.wait(0.2)
end

local function ensureIdentity()
    if type(setthreadidentity) == "function" then
        pcall(setthreadidentity, 8)
    end
end

--// Game Modules & Remotes
local Balance = require(ReplicatedStorage:WaitForChild("Balance"))
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))
local PlantConfig = require(ReplicatedStorage:WaitForChild("PlantConfig"))
local BigTomPath = require(ReplicatedStorage:WaitForChild("BigTomPath"))
local ClientState = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ClientState"))
ensureIdentity()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteRequest = Remotes:WaitForChild("Request")
local RemoteThrow = Remotes:WaitForChild("Throw")
local RemoteCollect = Remotes:WaitForChild("Collect")
local RemoteAim = Remotes:WaitForChild("Aim")
local RemoteHere = Remotes:WaitForChild("Here")
local RemoteNotify = Remotes:WaitForChild("Notify")
local RemoteClaimAllGifts = Remotes:WaitForChild("ClaimAllGifts")

--// Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
ensureIdentity()

--// Runtime State (ALL automation toggles strictly default to false / OFF)
local Running = true
local Connections = {}
local Loops = {}

local State = {
    -- Farming
    AutoThrow = false,
    ThrowMode = "Instant Remote",
    ThrowPower = 100,
    ThrowDelay = 0.25,
    PauseIfInventoryFull = false,
    AutoTrain = false,
    AutoXPBoost = false,
    AutoCollectOffline = false,

    -- Garden & Economy
    AutoPlaceBest = false,
    AutoSellStored = false,
    AutoSellMaxRarity = "Uncommon",
    KeepMutated = false,
    KeepHarvestPlants = false,
    KeepNewIndex = false,
    AutoFuse = false,
    AutoFuseRarities = { "Common", "Uncommon" },
    FuseUpgradeOnly = false,

    -- Shop & Upgrades
    AutoBuyBestSeed = false,
    AutoUpgradeBar = false,
    AutoUpgradeCapacity = false,
    AutoUseItems = false,
    SelectedItemsToUse = { "Luck2", "Luck5", "Money", "Train" },

    -- Events & Rewards
    AutoClaimGifts = false,
    AutoClaimDaily = false,
    AutoHarvestBasket = false,
    AutoHarvestBuy = false,
    AutoBigTomJoin = false,
    AutoBigTomFire = false,
    AutoBigTomSmash = false,
    AutoBigTomChest = false,
    AutoAbuseGrab = false,

    -- Player & Misc
    WalkSpeedEnabled = false,
    WalkSpeedValue = 28,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,
}

--// Helpers
local function addConn(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function notify(title, content, duration, icon)
    ensureIdentity()
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Icon = icon or "info",
        })
    end)
end

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

local function safeRequest(action, payload)
    local ok, res1, res2 = pcall(function()
        return RemoteRequest:InvokeServer(action, payload or {})
    end)
    ensureIdentity()
    if not ok then
        return false, tostring(res1)
    end
    return res1, res2
end

local function getMyPlot()
    local plotName = LocalPlayer:GetAttribute("Plot")
    local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
    if plotName and plots then
        return plots:FindFirstChild(plotName)
    end
    return nil
end

local function teleportToCFrame(cf)
    local char, hrp = getCharacter()
    if not char or not hrp then return false end
    hrp.AssemblyLinearVelocity = Vector3.zero
    char:PivotTo(cf)
    return true
end

local RarityToIndex = {}
local RarityNames = {}
for idx, info in ipairs(PlantConfig.Rarities) do
    RarityToIndex[info.name] = idx
    table.insert(RarityNames, info.name)
end

local AutoSellRarityNames = {}
for idx = 1, math.min(Balance.AutoSellMaxTier or 9, #PlantConfig.Rarities) do
    table.insert(AutoSellRarityNames, PlantConfig.Rarities[idx].name)
end

local function getItemsTable()
    local raw = LocalPlayer:GetAttribute("Items") or "{}"
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok and type(decoded) == "table" then
        return decoded
    end
    return {}
end

local function hasOwnedSeed(seedIndex)
    for _, owned in ipairs(ClientState.seeds or {}) do
        if owned == seedIndex then
            return true
        end
    end
    return false
end

local function getBestOwnedSeedIndex()
    local owned = ClientState.seeds or { 1 }
    local bestIdx = 1
    local bestLuck = -1
    for _, idx in ipairs(owned) do
        local info = Balance.Seeds[idx]
        if info and not Balance.SeedShut(info) then
            local luck = Balance.SeedLuck(idx, owned)
            if luck > bestLuck then
                bestLuck = luck
                bestIdx = idx
            end
        end
    end
    return bestIdx
end

local function getNextAffordableSeed()
    local money = tonumber(LocalPlayer:GetAttribute("Money")) or 0
    local wtCatches = tonumber(LocalPlayer:GetAttribute("WTCatches")) or 0
    local bestBuy = nil
    local bestLuck = -1
    for idx, info in ipairs(Balance.Seeds) do
        if info.price and not info.robux and not info.hidden and not Balance.SeedShut(info) then
            if not hasOwnedSeed(idx) then
                local catchesOk = (info.catches == nil) or (wtCatches >= info.catches)
                if catchesOk and money >= info.price and info.luck > bestLuck then
                    bestLuck = info.luck
                    bestBuy = idx
                end
            end
        end
    end
    return bestBuy
end

local function getTeleportTargets()
    local targets = {}
    local canyon = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Canyon")
    local launchStrip = canyon and canyon:FindFirstChild("LaunchStrip")
    if launchStrip then
        targets["Launch Strip"] = CFrame.new(launchStrip.Position + Vector3.new(0, 4, 4), launchStrip.Position + Vector3.new(0, 4, -40))
    end
    local plot = getMyPlot()
    if plot then
        local fence = plot:FindFirstChild("Fence")
        if fence then
            local pos = fence:GetBoundingBox().Position
            targets["My Garden"] = CFrame.new(pos.X, 4, pos.Z - 14)
        end
        local barStation = plot:FindFirstChild("BarStation")
        if barStation then
            local trainSpot = barStation:FindFirstChild("Bar") and barStation.Bar:FindFirstChild("TrainSpot")
            if trainSpot and trainSpot:IsA("Attachment") then
                targets["Pull-Up Bar"] = CFrame.new(trainSpot.WorldPosition + Vector3.new(0, 0, 2), trainSpot.WorldPosition)
            else
                targets["Pull-Up Bar"] = CFrame.new(barStation:GetPivot().Position + Vector3.new(0, 3, 4))
            end
        end
        local foodStall = plot:FindFirstChild("FoodStall")
        if foodStall then
            targets["Seed Stall"] = CFrame.new(foodStall:GetPivot().Position + Vector3.new(0, 3, 4))
        end
    end
    local props = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Props")
    if props then
        local sell = props:FindFirstChild("SellStall")
        if sell then
            targets["Sell Stall"] = CFrame.new(sell:GetPivot().Position + Vector3.new(0, 3, 6))
        end
        local fuse = props:FindFirstChild("FuseMachine")
        if fuse then
            targets["Fuse Machine"] = CFrame.new(fuse:GetPivot().Position + Vector3.new(0, 3, 6))
        end
    end
    if Balance.Harvest and Balance.Harvest.StandAt then
        targets["Harvest Stand"] = Balance.Harvest.StandAt * CFrame.new(0, 3, 6)
    end
    return targets
end

--// Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = "XLunaHUB | Throw a Seed",
    Icon = "sprout",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_ThrowASeed",
    Size = UDim2.fromOffset(620, 470),
    MinSize = Vector2.new(540, 360),
    MaxSize = Vector2.new(880, 620),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    SideBarWidth = 190,
    HideSearchBar = true,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "sprout",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("#46E575"), Color3.fromHex("#1BA84F")),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

--// Enforce Layered DisplayOrder & Floating Button Position outside Roblox TopBar
local function applyWindUILayering()
    ensureIdentity()
    local orderMap = {
        ["WindUI"] = 110,
        ["WindUI/Notifications"] = 120,
        ["WindUI/Dropdowns"] = 130,
        ["WindUI/Tooltips"] = 140,
    }
    local roots = { CoreGui }
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            table.insert(roots, hui)
        end
    end
    for _, root in ipairs(roots) do
        for _, gui in ipairs(root:GetChildren()) do
            if gui:IsA("ScreenGui") and orderMap[gui.Name] then
                gui.DisplayOrder = orderMap[gui.Name]
                if gui.Name == "WindUI" then
                    for _, child in ipairs(gui:GetDescendants()) do
                        if child:IsA("GuiObject") and (child.Name == "OpenButton" or child.Name == "MobileOpenButton") then
                            child.Position = UDim2.new(0.5, 0, 0, 76)
                        end
                    end
                end
            end
        end
    end
end
task.defer(applyWindUILayering)
pcall(function()
    Window:OnClose(function()
        task.defer(applyWindUILayering)
    end)
end)

--// Clean LeftCTRL Toggle (no double-trigger conflict)
local lastCtrlToggle = 0
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not Running then return end
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        local now = os.clock()
        if now - lastCtrlToggle < 0.18 then return end
        lastCtrlToggle = now
        ensureIdentity()
        if Window.Closed then
            Window:Open()
        else
            Window:Close()
        end
    end
end))

--// Tabs
local TabMain = Window:Tab({ Title = "Farming", Icon = "tractor" })
local TabGarden = Window:Tab({ Title = "Garden & Fuse", Icon = "flower-2" })
local TabShop = Window:Tab({ Title = "Shop & Boosts", Icon = "shopping-bag" })
local TabEvents = Window:Tab({ Title = "Events & Gifts", Icon = "sparkles" })
local TabPlayer = Window:Tab({ Title = "Player & Misc", Icon = "user" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

--// ==========================================
--// TAB 1: FARMING
--// ==========================================
local StatusParagraph = TabMain:Paragraph({
    Title = "Live Player Telemetry",
    Desc = "Loading stats...",
})

TabMain:Section({ Title = "Seed Throwing Automation" })

local ThrowModeDropdown = TabMain:Dropdown({
    Title = "Throw Execution Mode",
    Desc = "Instant Remote fires packets directly; Legit Launch Strip moves to the cliff.",
    Values = { "Instant Remote", "Legit Launch Strip" },
    Value = "Instant Remote",
    Flag = "ThrowMode",
    Callback = function(val)
        State.ThrowMode = val
    end,
})

local ThrowPowerSlider = TabMain:Slider({
    Title = "Throw Power Meter (%)",
    Desc = "92% or higher guarantees a Perfect +20 Power bonus.",
    Value = { Min = 60, Max = 100, Default = 100 },
    Step = 1,
    Flag = "ThrowPower",
    Callback = function(val)
        State.ThrowPower = val
    end,
})

local ThrowDelaySlider = TabMain:Slider({
    Title = "Throw Loop Delay (s)",
    Desc = "Delay between consecutive throws in Instant Remote mode.",
    Value = { Min = 0.05, Max = 3.0, Default = 0.25 },
    Step = 0.05,
    Flag = "ThrowDelay",
    Callback = function(val)
        State.ThrowDelay = val
    end,
})

local PauseFullToggle = TabMain:Toggle({
    Title = "Pause Throw When Inventory Full",
    Desc = "Avoids hitting the 5,000 plant inventory cap without selling first.",
    Value = false,
    Flag = "PauseIfInventoryFull",
    Callback = function(val)
        State.PauseIfInventoryFull = val
    end,
})

local AutoThrowToggle = TabMain:Toggle({
    Title = "Auto Throw Seeds",
    Desc = "Automatically throws equipped seeds using the selected mode and power.",
    Value = false,
    Flag = "AutoThrow",
    Callback = function(val)
        State.AutoThrow = val
    end,
})

TabMain:Section({ Title = "Strength & Offline Income" })

local AutoTrainToggle = TabMain:Toggle({
    Title = "Auto Pull-Up Training",
    Desc = "Automatically starts and maintains pull-up training at your bar.",
    Value = false,
    Flag = "AutoTrain",
    Callback = function(val)
        State.AutoTrain = val
        if not val then
            local char = LocalPlayer.Character
            if char and char:GetAttribute("Training") then
                task.spawn(safeRequest, "StopTrain")
            end
        end
    end,
})

local AutoXPBoostToggle = TabMain:Toggle({
    Title = "Auto Claim Training XP Boost",
    Desc = "Automatically activates free Training XP boost prompts when offered.",
    Value = false,
    Flag = "AutoXPBoost",
    Callback = function(val)
        State.AutoXPBoost = val
    end,
})

local AutoOfflineToggle = TabMain:Toggle({
    Title = "Auto Collect Offline Cash",
    Desc = "Collects accumulated offline garden earnings automatically.",
    Value = false,
    Flag = "AutoCollectOffline",
    Callback = function(val)
        State.AutoCollectOffline = val
    end,
})

TabMain:Button({
    Title = "Collect Offline Cash Now",
    Icon = "coins",
    Callback = function()
        local ok, msg = safeRequest("CollectOffline")
        notify("Offline Earnings", tostring(msg or (ok and "Collected offline cash." or "Nothing to collect.")), 3, ok and "check" or "info")
    end,
})

--// ==========================================
--// TAB 2: GARDEN & FUSE
--// ==========================================
TabGarden:Section({ Title = "Garden Management" })

local AutoPlaceBestToggle = TabGarden:Toggle({
    Title = "Auto Place Best Plants",
    Desc = "Automatically places your highest-income plants into your garden.",
    Value = false,
    Flag = "AutoPlaceBest",
    Callback = function(val)
        State.AutoPlaceBest = val
    end,
})

TabGarden:Button({
    Title = "Place Best Plants Now",
    Icon = "sparkles",
    Callback = function()
        local ok, msg = safeRequest("PlaceBest")
        notify("Garden Optimizer", tostring(msg or (ok and "Placed best plants!" or "Could not place plants.")), 3, ok and "check" or "alert-circle")
    end,
})

TabGarden:Section({ Title = "Smart Auto Sell (Stored Plants)" })

local AutoSellMaxRarityDropdown = TabGarden:Dropdown({
    Title = "Sell Up To Rarity",
    Desc = "Stored plants at or below this rarity can be sold automatically.",
    Values = AutoSellRarityNames,
    Value = "Uncommon",
    Flag = "AutoSellMaxRarity",
    Callback = function(val)
        State.AutoSellMaxRarity = val
    end,
})

local KeepMutatedToggle = TabGarden:Toggle({
    Title = "Protect Mutated Plants",
    Desc = "Never auto-sell plants with Gold, Diamond, Emerald, Ruby, Rainbow, or Admin mutations.",
    Value = false,
    Flag = "KeepMutated",
    Callback = function(val)
        State.KeepMutated = val
    end,
})

local KeepHarvestToggle = TabGarden:Toggle({
    Title = "Protect Harvest Event Plants",
    Desc = "Never auto-sell Harvest plants or plants with the Harvest Mutation.",
    Value = false,
    Flag = "KeepHarvestPlants",
    Callback = function(val)
        State.KeepHarvestPlants = val
    end,
})

local KeepNewIndexToggle = TabGarden:Toggle({
    Title = "Protect Unindexed / Rare Variants",
    Desc = "Skip plants that are not yet unlocked in your Index.",
    Value = false,
    Flag = "KeepNewIndex",
    Callback = function(val)
        State.KeepNewIndex = val
    end,
})

local AutoSellStoredToggle = TabGarden:Toggle({
    Title = "Auto Sell Filtered Stored Plants",
    Desc = "Batch-sells matching unplaced plants safely via SellMany.",
    Value = false,
    Flag = "AutoSellStored",
    Callback = function(val)
        State.AutoSellStored = val
    end,
})

TabGarden:Button({
    Title = "Sell All Stored Plants Now",
    Icon = "dollar-sign",
    Callback = function()
        local ok, msg = safeRequest("SellStored")
        notify("Sell Stored", tostring(msg or (ok and "Sold all stored plants." or "No stored plants to sell.")), 3, ok and "check" or "info")
    end,
})

TabGarden:Section({ Title = "Smart Fuse Machine" })

local AutoFuseRaritiesDropdown = TabGarden:Dropdown({
    Title = "Allowed Fuse Rarities",
    Desc = "Select which stored plant rarities may be used as fuse material.",
    Values = RarityNames,
    Value = { "Common", "Uncommon" },
    Multi = true,
    AllowNone = true,
    Flag = "AutoFuseRarities",
    Callback = function(val)
        State.AutoFuseRarities = val or {}
    end,
})

local FuseUpgradeOnlyToggle = TabGarden:Toggle({
    Title = "Require Predicted Income Upgrade",
    Desc = "Only fuses 3 plants when Balance.FuseCandidates predicts a higher-income plant.",
    Value = false,
    Flag = "FuseUpgradeOnly",
    Callback = function(val)
        State.FuseUpgradeOnly = val
    end,
})

local AutoFuseToggle = TabGarden:Toggle({
    Title = "Auto Fuse Stored Plants",
    Desc = "Automatically fuses groups of 3 eligible stored plants.",
    Value = false,
    Flag = "AutoFuse",
    Callback = function(val)
        State.AutoFuse = val
    end,
})

--// ==========================================
--// TAB 3: SHOP & BOOSTS
--// ==========================================
TabShop:Section({ Title = "Automatic Progression Upgrades" })

local AutoBuyBestSeedToggle = TabShop:Toggle({
    Title = "Auto Buy & Equip Best Seed",
    Desc = "Buys the highest-luck affordable seed and equips your best owned seed.",
    Value = false,
    Flag = "AutoBuyBestSeed",
    Callback = function(val)
        State.AutoBuyBestSeed = val
    end,
})

local AutoUpgradeBarToggle = TabShop:Toggle({
    Title = "Auto Upgrade Pull-Up Bar",
    Desc = "Purchases the next Pull-Up Bar tier as soon as you have enough cash.",
    Value = false,
    Flag = "AutoUpgradeBar",
    Callback = function(val)
        State.AutoUpgradeBar = val
    end,
})

local AutoUpgradeCapToggle = TabShop:Toggle({
    Title = "Auto Upgrade Garden Capacity",
    Desc = "Expands garden plant slots up to max capacity when affordable.",
    Value = false,
    Flag = "AutoUpgradeCapacity",
    Callback = function(val)
        State.AutoUpgradeCapacity = val
    end,
})

TabShop:Section({ Title = "Manual Seed Shop" })

local SeedDropdownValues = {}
local SeedNameToIndex = {}
for idx, s in ipairs(Balance.Seeds) do
    if not s.robux then
        local label = string.format("%d. %s (x%s Luck)", idx, s.name, tostring(s.luck))
        table.insert(SeedDropdownValues, label)
        SeedNameToIndex[label] = idx
    end
end
local SelectedSeedLabel = SeedDropdownValues[1]

TabShop:Dropdown({
    Title = "Select Seed",
    Values = SeedDropdownValues,
    Value = SelectedSeedLabel,
    Callback = function(val)
        SelectedSeedLabel = val
    end,
})

TabShop:Button({
    Title = "Buy Selected Seed",
    Icon = "shopping-cart",
    Callback = function()
        local idx = SeedNameToIndex[SelectedSeedLabel]
        if idx then
            local ok, msg = safeRequest("BuySeed", { i = idx })
            notify("Seed Shop", tostring(msg or (ok and "Seed purchased!" or "Purchase failed.")), 3, ok and "check" or "alert-circle")
        end
    end,
})

TabShop:Button({
    Title = "Equip Selected Seed",
    Icon = "hand",
    Callback = function()
        local idx = SeedNameToIndex[SelectedSeedLabel]
        if idx then
            local ok, msg = safeRequest("EquipSeed", { i = idx })
            notify("Seed Equipped", tostring(msg or (ok and "Equipped!" or "Not owned.")), 3, ok and "check" or "alert-circle")
        end
    end,
})

TabShop:Section({ Title = "Potions & Lucky Throws" })

local ItemsDropdown = TabShop:Dropdown({
    Title = "Items to Auto-Use",
    Desc = "Boosts are only consumed when not already active.",
    Values = { "Luck2", "Luck5", "Money", "Train", "Lucky", "Lucky10" },
    Value = { "Luck2", "Luck5", "Money", "Train" },
    Multi = true,
    AllowNone = true,
    Flag = "SelectedItemsToUse",
    Callback = function(val)
        State.SelectedItemsToUse = val or {}
    end,
})

local AutoUseItemsToggle = TabShop:Toggle({
    Title = "Auto Use Selected Boosts & Items",
    Desc = "Uses matching inventory items when their boost timer reaches zero.",
    Value = false,
    Flag = "AutoUseItems",
    Callback = function(val)
        State.AutoUseItems = val
    end,
})

--// ==========================================
--// TAB 4: EVENTS & GIFTS
--// ==========================================
TabEvents:Section({ Title = "Playtime & Daily Rewards" })

local AutoClaimGiftsToggle = TabEvents:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Automatically claims ready session playtime gifts.",
    Value = false,
    Flag = "AutoClaimGifts",
    Callback = function(val)
        State.AutoClaimGifts = val
    end,
})

local AutoClaimDailyToggle = TabEvents:Toggle({
    Title = "Auto Claim Daily Reward",
    Desc = "Claims your daily login reward whenever available.",
    Value = false,
    Flag = "AutoClaimDaily",
    Callback = function(val)
        State.AutoClaimDaily = val
    end,
})

TabEvents:Button({
    Title = "Claim All Ready Gifts Now",
    Icon = "gift",
    Callback = function()
        local ok, res = pcall(function()
            return RemoteClaimAllGifts:InvokeServer()
        end)
        ensureIdentity()
        notify("Gifts", ok and "Claimed ready playtime gifts!" or tostring(res), 3, ok and "check" or "info")
    end,
})

TabEvents:Section({ Title = "Harvest Event & Farmer Hazel" })

local AutoHarvestBasketToggle = TabEvents:Toggle({
    Title = "Auto Deposit Cranberry Basket",
    Desc = "Automatically deposits your Cranberry Basket to Farmer Hazel when held.",
    Value = false,
    Flag = "AutoHarvestBasket",
    Callback = function(val)
        State.AutoHarvestBasket = val
    end,
})

local AutoHarvestBuyToggle = TabEvents:Toggle({
    Title = "Auto Buy Harvest Stand Rewards",
    Desc = "Purchases the next Harvest Stand tier when you have enough Cranberries.",
    Value = false,
    Flag = "AutoHarvestBuy",
    Callback = function(val)
        State.AutoHarvestBuy = val
    end,
})

TabEvents:Section({ Title = "Big Tom Boss & Admin Abuse" })

local AutoBigTomJoinToggle = TabEvents:Toggle({
    Title = "Auto Join Big Tom Fight",
    Desc = "Automatically joins the Big Tom boss fight when boarding opens.",
    Value = false,
    Flag = "AutoBigTomJoin",
    Callback = function(val)
        State.AutoBigTomJoin = val
    end,
})

local AutoBigTomFireToggle = TabEvents:Toggle({
    Title = "Auto Fire Perfect Cannon",
    Desc = "Fires the catapult cannon when your cart aligns within boss range.",
    Value = false,
    Flag = "AutoBigTomFire",
    Callback = function(val)
        State.AutoBigTomFire = val
    end,
})

local AutoBigTomSmashToggle = TabEvents:Toggle({
    Title = "Auto Smash Turkeys",
    Desc = "Automatically smashes nearby turkeys during the smash phase.",
    Value = false,
    Flag = "AutoBigTomSmash",
    Callback = function(val)
        State.AutoBigTomSmash = val
    end,
})

local AutoBigTomChestToggle = TabEvents:Toggle({
    Title = "Auto Claim Big Tom Chest",
    Desc = "Claims the Big Tom reward chest as soon as the chest phase begins.",
    Value = false,
    Flag = "AutoBigTomChest",
    Callback = function(val)
        State.AutoBigTomChest = val
    end,
})

local AutoAbuseGrabToggle = TabEvents:Toggle({
    Title = "Auto Collect Admin Abuse Drops",
    Desc = "Automatically grabs cash stacks, lucky dice, meteors, and treasure drops.",
    Value = false,
    Flag = "AutoAbuseGrab",
    Callback = function(val)
        State.AutoAbuseGrab = val
        if val then
            task.spawn(safeRequest, "AbuseSync")
        end
    end,
})

--// ==========================================
--// TAB 5: PLAYER & MISC
--// ==========================================
TabPlayer:Section({ Title = "Movement & Physics" })

local WalkSpeedToggle = TabPlayer:Toggle({
    Title = "Custom WalkSpeed",
    Value = false,
    Flag = "WalkSpeedEnabled",
    Callback = function(val)
        State.WalkSpeedEnabled = val
        if not val then
            local _, _, hum = getCharacter()
            if hum then
                hum.WalkSpeed = tonumber(LocalPlayer:GetAttribute("SetSpeed")) or 18
            end
        end
    end,
})

local WalkSpeedSlider = TabPlayer:Slider({
    Title = "WalkSpeed Value",
    Value = { Min = 16, Max = 120, Default = 28 },
    Step = 1,
    Flag = "WalkSpeedValue",
    Callback = function(val)
        State.WalkSpeedValue = val
    end,
})

local InfiniteJumpToggle = TabPlayer:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Flag = "InfiniteJump",
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

local NoclipToggle = TabPlayer:Toggle({
    Title = "Noclip",
    Value = false,
    Flag = "Noclip",
    Callback = function(val)
        State.Noclip = val
        if not val then
            local char = LocalPlayer.Character
            if char then
                for _, partName in ipairs({ "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso" }) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

TabPlayer:Section({ Title = "Quick Teleports" })

local SelectedTeleport = "Launch Strip"
TabPlayer:Dropdown({
    Title = "Destination",
    Values = { "Launch Strip", "My Garden", "Pull-Up Bar", "Seed Stall", "Sell Stall", "Fuse Machine", "Harvest Stand" },
    Value = "Launch Strip",
    Callback = function(val)
        SelectedTeleport = val
    end,
})

TabPlayer:Button({
    Title = "Teleport to Destination",
    Icon = "navigation",
    Callback = function()
        local targets = getTeleportTargets()
        local cf = targets[SelectedTeleport]
        if cf and teleportToCFrame(cf) then
            notify("Teleport", "Teleported to " .. SelectedTeleport, 2, "check")
        else
            notify("Teleport", "Destination unavailable right now.", 3, "alert-circle")
        end
    end,
})

TabPlayer:Section({ Title = "Protection & Performance" })

local AntiAFKToggle = TabPlayer:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents 20-minute idle disconnection using VirtualUser and presence pings.",
    Value = false,
    Flag = "AntiAFK",
    Callback = function(val)
        State.AntiAFK = val
    end,
})

TabPlayer:Button({
    Title = "Hide Other Players' Plants",
    Icon = "eye-off",
    Callback = function()
        safeRequest("Settings", { hideOthers = true })
        LocalPlayer:SetAttribute("SetHideOthers", true)
        notify("Performance", "Hidden other players' plants.", 2, "check")
    end,
})

TabPlayer:Button({
    Title = "Enable Short Cutscenes & Low VFX",
    Icon = "zap",
    Callback = function()
        safeRequest("Settings", { skipCine = true, lowGfx = true })
        LocalPlayer:SetAttribute("SetSkipCine", true)
        LocalPlayer:SetAttribute("SetLowGfx", true)
        notify("Performance", "Enabled Short Cutscenes & Low VFX.", 2, "check")
    end,
})

TabPlayer:Button({
    Title = "Rejoin Current Server",
    Icon = "refresh-cw",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

--// ==========================================
--// TAB 6: CONFIG
--// ==========================================
local ConfigManager = Window.ConfigManager
local ConfigNameInput = "default"
local SelectedConfigName = "default"

TabConfig:Section({ Title = "Configuration Manager" })

TabConfig:Input({
    Title = "Config Profile Name",
    Desc = "Enter a name before creating or saving a profile.",
    Value = "default",
    Placeholder = "default",
    Callback = function(val)
        if type(val) == "string" and val ~= "" then
            ConfigNameInput = val
        end
    end,
})

local function getAllConfigNames()
    ensureIdentity()
    local ok, list = pcall(function()
        return ConfigManager:AllConfigs()
    end)
    if ok and type(list) == "table" and #list > 0 then
        return list
    end
    return { "default" }
end

local ConfigListDropdown = TabConfig:Dropdown({
    Title = "Saved Profiles",
    Values = getAllConfigNames(),
    Value = "default",
    Callback = function(val)
        SelectedConfigName = val
    end,
})

local function refreshConfigDropdown()
    ensureIdentity()
    local list = getAllConfigNames()
    pcall(function()
        if ConfigListDropdown.Refresh then
            ConfigListDropdown:Refresh(list)
        end
    end)
end

local function registerAllFlags(cfg)
    local allControls = {
        ThrowModeDropdown, ThrowPowerSlider, ThrowDelaySlider, PauseFullToggle,
        AutoThrowToggle, AutoTrainToggle, AutoXPBoostToggle, AutoOfflineToggle,
        AutoPlaceBestToggle, AutoSellMaxRarityDropdown, KeepMutatedToggle,
        KeepHarvestToggle, KeepNewIndexToggle, AutoSellStoredToggle,
        AutoFuseRaritiesDropdown, FuseUpgradeOnlyToggle, AutoFuseToggle,
        AutoBuyBestSeedToggle, AutoUpgradeBarToggle, AutoUpgradeCapToggle,
        ItemsDropdown, AutoUseItemsToggle,
        AutoClaimGiftsToggle, AutoClaimDailyToggle, AutoHarvestBasketToggle,
        AutoHarvestBuyToggle, AutoBigTomJoinToggle, AutoBigTomFireToggle,
        AutoBigTomSmashToggle, AutoBigTomChestToggle, AutoAbuseGrabToggle,
        WalkSpeedToggle, WalkSpeedSlider, InfiniteJumpToggle, NoclipToggle, AntiAFKToggle,
    }
    for _, ctrl in ipairs(allControls) do
        if ctrl and ctrl.Flag then
            pcall(function()
                cfg:Register(ctrl.Flag, ctrl)
            end)
        end
    end
end

TabConfig:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        ensureIdentity()
        local name = (ConfigNameInput ~= "" and ConfigNameInput) or SelectedConfigName or "default"
        local cfg = ConfigManager:CreateConfig(name)
        registerAllFlags(cfg)
        local ok, err = pcall(function()
            cfg:Save()
        end)
        refreshConfigDropdown()
        notify("Config Saved", ok and ("Saved profile '" .. name .. "'") or tostring(err), 3, ok and "check" or "alert-circle")
    end,
})

TabConfig:Button({
    Title = "Load Selected Config",
    Icon = "folder-open",
    Callback = function()
        ensureIdentity()
        local name = SelectedConfigName or ConfigNameInput or "default"
        local cfg = ConfigManager:CreateConfig(name)
        registerAllFlags(cfg)
        local ok, err = pcall(function()
            cfg:Load()
        end)
        notify("Config Loaded", ok and ("Loaded profile '" .. name .. "'") or tostring(err), 3, ok and "check" or "alert-circle")
    end,
})

TabConfig:Button({
    Title = "Delete Selected Config",
    Icon = "trash-2",
    Callback = function()
        ensureIdentity()
        local name = SelectedConfigName or "default"
        local ok, err = pcall(function()
            ConfigManager:DeleteConfig(name)
        end)
        refreshConfigDropdown()
        notify("Config Deleted", ok and ("Deleted profile '" .. name .. "'") or tostring(err), 3, ok and "check" or "info")
    end,
})

TabConfig:Button({
    Title = "Refresh Profile List",
    Icon = "refresh-cw",
    Callback = function()
        refreshConfigDropdown()
        notify("Config List", "Profile list refreshed.", 2, "info")
    end,
})

TabConfig:Section({ Title = "Hub Controls & Safety" })

TabConfig:Paragraph({
    Title = "Hotkeys & Attribution",
    Desc = "Press LeftCTRL anytime to cleanly Show / Hide the menu.\nUse the floating XLunaHUB button for quick access.\nAuthor: By XLunaHUB",
})

TabConfig:Button({
    Title = "Turn OFF All Automation",
    Icon = "power",
    Callback = function()
        local toggleObjects = {
            AutoThrowToggle, AutoTrainToggle, AutoXPBoostToggle, AutoOfflineToggle,
            AutoPlaceBestToggle, AutoSellStoredToggle, AutoFuseToggle,
            AutoBuyBestSeedToggle, AutoUpgradeBarToggle, AutoUpgradeCapToggle,
            AutoUseItemsToggle, AutoClaimGiftsToggle, AutoClaimDailyToggle,
            AutoHarvestBasketToggle, AutoHarvestBuyToggle,
            AutoBigTomJoinToggle, AutoBigTomFireToggle, AutoBigTomSmashToggle,
            AutoBigTomChestToggle, AutoAbuseGrabToggle,
            WalkSpeedToggle, InfiniteJumpToggle, NoclipToggle, AntiAFKToggle,
        }
        for _, tog in ipairs(toggleObjects) do
            if tog and tog.Set then
                pcall(function() tog:Set(false) end)
            end
        end
        notify("Safety Reset", "All automation toggles have been turned OFF.", 3, "shield")
    end,
})

--// Select Tab 1 explicitly
pcall(function()
    Window:SelectTab(1)
end)

--// ==========================================
--// REALTIME EVENT TRACKERS (XPBoost, Abuse, BigTom)
--// ==========================================
local PendingXPOffer = nil
local ActiveAbuseDrops = {}
local ActiveBigTomTurkeys = {}

addConn(ClientState.Event.Event:Connect(function(evName, payload)
    if not Running then return end
    if evName == "XPOffer" and type(payload) == "table" and payload.id ~= nil then
        PendingXPOffer = { id = payload.id, receivedAt = os.clock(), ttl = tonumber(payload.ttl) or 3.6 }
    end
end))

addConn(RemoteNotify.OnClientEvent:Connect(function(evName, payload)
    if not Running or type(payload) ~= "table" then return end
    if evName == "AbuseEvent" and payload.kind and payload.id then
        for _, drop in ipairs(payload.drops or {}) do
            local key = tostring(payload.kind) .. ":" .. tostring(payload.id) .. ":" .. tostring(drop[1])
            ActiveAbuseDrops[key] = {
                kind = payload.kind,
                id = payload.id,
                drop = drop[1],
                pos = Vector3.new(drop[2] or 0, drop[3] or 0, drop[4] or 0),
                at = tonumber(drop[5]) or 0,
                path = drop[6],
                step = 2.5,
                lastTry = 0,
            }
        end
    elseif evName == "AbuseTaken" and payload.kind and payload.id and payload.drop then
        local key = tostring(payload.kind) .. ":" .. tostring(payload.id) .. ":" .. tostring(payload.drop)
        ActiveAbuseDrops[key] = nil
    elseif evName == "AbuseEnd" and payload.kind and payload.id then
        for key, item in pairs(ActiveAbuseDrops) do
            if item.kind == payload.kind and item.id == payload.id then
                ActiveAbuseDrops[key] = nil
            end
        end
    elseif evName == "BigTom" then
        local data = payload.data or {}
        if payload.kind == "turkeys" and type(data.turkeys) == "table" then
            ActiveBigTomTurkeys = {}
            for k, coord in pairs(data.turkeys) do
                ActiveBigTomTurkeys[k] = Vector3.new(coord[1], Balance.BigTom.Boss.Y, coord[2])
            end
        elseif payload.kind == "smash" and data.id ~= nil then
            ActiveBigTomTurkeys[data.id] = nil
        end
    end
end))

--// ==========================================
--// AUTOMATION ENGINE LOOPS
--// ==========================================

--// 1. Live Telemetry Loop
table.insert(Loops, task.spawn(function()
    while Running do
        local money = tonumber(LocalPlayer:GetAttribute("Money")) or 0
        local strength = tonumber(LocalPlayer:GetAttribute("Strength")) or 10
        local level = tonumber(LocalPlayer:GetAttribute("Level")) or 1
        local income = tonumber(LocalPlayer:GetAttribute("Income")) or 0
        local zoneIdx = tonumber(LocalPlayer:GetAttribute("ZoneReach")) or 1
        local zoneName = (ZoneConfig.List[zoneIdx] and ZoneConfig.List[zoneIdx].name) or "Meadow"
        local placed = ClientState.PlacedCount()
        local cap = ClientState.capacity or 8
        local invCount = #(ClientState.plants or {})
        local seedInfo = Balance.Seeds[ClientState.seed or 1]
        local barInfo = Balance.Bars[ClientState.bar or 1]

        local desc = string.format(
            "Money: $%s | Income: $%s/s\nStrength: %s (Lv.%d) | Zone: %s\nGarden: %d/%d | Inventory: %d/%d\nSeed: %s | Bar: %s",
            Balance.Short(money),
            Balance.Short(income),
            Balance.Short(strength),
            level,
            zoneName,
            placed,
            cap,
            invCount,
            Balance.PlantCap or 5000,
            seedInfo and seedInfo.name or "Plain Seed",
            barInfo and barInfo.name or "Wood Bar"
        )
        ensureIdentity()
        pcall(function()
            StatusParagraph:SetDesc(desc)
        end)
        task.wait(0.8)
    end
end))

--// 2. Auto Throw Loop
table.insert(Loops, task.spawn(function()
    local lastThrowAt = 0
    local throwCooldown = 6.45

    while Running do
        if State.AutoThrow then
            local invCount = #(ClientState.plants or {})
            if State.PauseIfInventoryFull and invCount >= (Balance.PlantCap or 5000) then
                task.wait(0.5)
            else
                local meter = math.clamp(State.ThrowPower / 100, Balance.MeterMin or 0.6, Balance.MeterMax or 1.0)
                local canyon = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Canyon")
                local ls = canyon and canyon:FindFirstChild("LaunchStrip")
                if State.ThrowMode == "Instant Remote" then
                    local waitRemain = (lastThrowAt > 0) and math.max(0, throwCooldown - (os.clock() - lastThrowAt)) or 0
                    if waitRemain > 0 then
                        task.wait(math.min(waitRemain, 0.25))
                    else
                        if ls then
                            local char, hrp = getCharacter()
                            local targetPos = Vector3.new(ls.Position.X, ls.Position.Y + 4, ls.Position.Z + ls.Size.Z / 2 + 2.5)
                            if char and hrp and (hrp.Position - targetPos).Magnitude > 10 then
                                teleportToCFrame(CFrame.lookAt(targetPos, targetPos + Vector3.new(0, 0, ZoneConfig.Direction or -1)))
                                task.wait(0.1)
                            end
                        end
                        local aimWait = math.clamp(math.acos(math.clamp(1 - 2 * meter, -1, 1)) * 1.5 / (2 * math.pi), 0.05, 0.76)
                        pcall(function()
                            RemoteAim:FireServer()
                        end)
                        task.wait(aimWait)
                        if State.AutoThrow and Running then
                            local res = nil
                            pcall(function()
                                RemoteHere:FireServer()
                                res = RemoteThrow:InvokeServer(meter)
                            end)
                            ensureIdentity()
                            if type(res) == "table" then
                                lastThrowAt = os.clock()
                                throwCooldown = math.max(Balance.ThrowFloor or 0.9, throwCooldown - 0.15)
                                task.wait(0.06)
                                pcall(function()
                                    RemoteCollect:FireServer()
                                end)
                                task.wait(math.max(0.1, State.ThrowDelay))
                            else
                                pcall(function()
                                    RemoteCollect:FireServer(true)
                                end)
                                throwCooldown = math.min(7.5, throwCooldown + 0.35)
                                task.wait(0.5)
                            end
                        end
                    end
                else
                    -- Legit Launch Strip Mode: step onto LaunchStrip and time Space input
                    local ThrowFX = LocalPlayer.PlayerGui:FindFirstChild("ThrowFX")
                    local throwState = ThrowFX and ThrowFX:GetAttribute("State") or "idle"
                    if throwState == "idle" and ls then
                        teleportToCFrame(CFrame.new(ls.Position + Vector3.new(0, 3.5, 0)))
                        task.wait(0.25)
                    elseif throwState == "aiming" then
                        local aimWait = math.clamp(math.acos(math.clamp(1 - 2 * meter, -1, 1)) * 1.5 / (2 * math.pi), 0.05, 0.75)
                        task.wait(aimWait)
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                        task.wait(0.4)
                    elseif throwState == "result" then
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                        task.wait(0.35)
                    else
                        task.wait(0.2)
                    end
                end
            end
        else
            task.wait(0.25)
        end
    end
end))

--// 3. Auto Train (Pull-Ups) & XP Boost Loop
table.insert(Loops, task.spawn(function()
    while Running do
        if State.AutoTrain then
            local char, hrp = getCharacter()
            if char and hrp and not char:GetAttribute("Training") then
                local plot = getMyPlot()
                local trainSpot = plot and plot:FindFirstChild("BarStation")
                    and plot.BarStation:FindFirstChild("Bar")
                    and plot.BarStation.Bar:FindFirstChild("TrainSpot")
                local prompt = trainSpot and trainSpot:FindFirstChild("TrainPrompt")
                if trainSpot and prompt then
                    local spotPos = trainSpot:IsA("Attachment") and trainSpot.WorldPosition or trainSpot.Position
                    local dist = (hrp.Position - spotPos).Magnitude
                    if dist > 7 then
                        teleportToCFrame(CFrame.new(spotPos + Vector3.new(0, 0, 2), spotPos))
                        task.wait(0.18)
                    end
                    if type(fireproximityprompt) == "function" then
                        pcall(fireproximityprompt, prompt)
                        task.wait(0.4)
                    end
                end
            end
        end
        if State.AutoXPBoost and PendingXPOffer then
            local offer = PendingXPOffer
            local age = os.clock() - offer.receivedAt
            if age > offer.ttl then
                PendingXPOffer = nil
            elseif age >= 0.18 then
                PendingXPOffer = nil
                safeRequest("XPBoost", { id = offer.id })
            end
        end
        task.wait(0.2)
    end
end))

--// 4. Garden Optimizer & Offline Cash Loop
table.insert(Loops, task.spawn(function()
    local lastOfflineAttempt = 0
    while Running do
        if State.AutoPlaceBest then
            local plants = ClientState.plants or {}
            local cap = ClientState.capacity or 8
            local placedCount = ClientState.PlacedCount()
            if #plants > 0 and (placedCount < cap or #plants > placedCount) then
                local minPlaced = math.huge
                local maxStored = -1
                for _, p in ipairs(plants) do
                    if p.placed then
                        minPlaced = math.min(minPlaced, p.income or 0)
                    else
                        maxStored = math.max(maxStored, p.income or 0)
                    end
                end
                if placedCount < cap or maxStored > minPlaced then
                    safeRequest("PlaceBest")
                end
            end
        end
        if State.AutoCollectOffline and os.clock() - lastOfflineAttempt >= 15 then
            lastOfflineAttempt = os.clock()
            safeRequest("CollectOffline")
        end
        task.wait(1.5)
    end
end))

--// 5. Smart Auto Sell & Auto Fuse Loop
table.insert(Loops, task.spawn(function()
    while Running do
        -- Auto Sell Stored
        if State.AutoSellStored then
            local maxTier = RarityToIndex[State.AutoSellMaxRarity] or 2
            local toSell = {}
            for _, p in ipairs(ClientState.plants or {}) do
                if not p.placed then
                    local tier = tonumber(p.rarity) or 1
                    local mutated = (tonumber(p.mutation) or 1) > 1
                    local isHarvest = Balance.HarvestKeep(p)
                    local isNew = not (ClientState.index and ClientState.index[p.plant])
                    if tier <= maxTier
                        and (not State.KeepMutated or not mutated)
                        and (not State.KeepHarvestPlants or not isHarvest)
                        and (not State.KeepNewIndex or not isNew) then
                        table.insert(toSell, p.id)
                        if #toSell >= 100 then break end
                    end
                end
            end
            if #toSell > 0 then
                safeRequest("SellMany", { ids = toSell })
            end
        end

        -- Auto Fuse Stored (server requires proximity to FuseMachine)
        if State.AutoFuse then
            local allowedMap = {}
            if type(State.AutoFuseRarities) == "table" then
                for _, rName in ipairs(State.AutoFuseRarities) do
                    if RarityToIndex[rName] then
                        allowedMap[RarityToIndex[rName]] = true
                    end
                end
            end
            local pool = {}
            for _, p in ipairs(ClientState.plants or {}) do
                if not p.placed and Balance.FuseBlock(p) == nil then
                    local tier = tonumber(p.rarity) or 1
                    local mutated = (tonumber(p.mutation) or 1) > 1
                    if allowedMap[tier] and (not State.KeepMutated or not mutated) then
                        table.insert(pool, p)
                    end
                end
            end
            if #pool >= (Balance.FuseCount or 3) then
                table.sort(pool, function(a, b)
                    return (a.income or 0) < (b.income or 0)
                end)
                local triplet = { pool[1], pool[2], pool[3] }
                local canFuse = true
                if State.FuseUpgradeOnly then
                    local candidates = Balance.FuseCandidates(triplet)
                    if not candidates or #candidates == 0 then
                        canFuse = false
                    else
                        local maxIn = math.max(triplet[1].income or 0, triplet[2].income or 0, triplet[3].income or 0)
                        local maxOut = 0
                        for _, c in ipairs(candidates) do
                            maxOut = math.max(maxOut, c.inc or 0)
                        end
                        if maxOut <= maxIn then
                            canFuse = false
                        end
                    end
                end
                if canFuse then
                    local props = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Props")
                    local fuseMachine = props and props:FindFirstChild("FuseMachine")
                    local _, hrp = getCharacter()
                    local prevCF = hrp and hrp.CFrame or nil
                    if fuseMachine and hrp then
                        local machinePos = fuseMachine:GetPivot().Position
                        if (hrp.Position - machinePos).Magnitude > 12 then
                            teleportToCFrame(CFrame.new(machinePos + Vector3.new(0, 3, 4)))
                            task.wait(0.18)
                        end
                    end
                    safeRequest("Fuse", { ids = { triplet[1].id, triplet[2].id, triplet[3].id } })
                    if prevCF and not State.AutoTrain and not State.AutoThrow then
                        task.wait(0.1)
                        teleportToCFrame(prevCF)
                    end
                end
            end
        end
        task.wait(1.0)
    end
end))

--// 6. Auto Shop, Upgrades & Boost Items Loop
table.insert(Loops, task.spawn(function()
    while Running do
        if State.AutoBuyBestSeed then
            local buyIdx = getNextAffordableSeed()
            if buyIdx then
                safeRequest("BuySeed", { i = buyIdx })
                task.wait(0.2)
            end
            local bestOwned = getBestOwnedSeedIndex()
            if bestOwned and (ClientState.seed or 1) ~= bestOwned then
                safeRequest("EquipSeed", { i = bestOwned })
            end
        end

        if State.AutoUpgradeBar then
            local curBar = ClientState.bar or 1
            if curBar < Balance.BarMax() then
                local nextBar = Balance.Bars[curBar + 1]
                local money = tonumber(LocalPlayer:GetAttribute("Money")) or 0
                if nextBar and nextBar.price and money >= nextBar.price then
                    safeRequest("BuyBar")
                end
            end
        end

        if State.AutoUpgradeCapacity then
            local capBase = ClientState.capacityBase or ClientState.capacity or Balance.CapacityStart
            if capBase < (Balance.CapacityMax or 30) then
                local cost = Balance.CapacityCost(capBase)
                local money = tonumber(LocalPlayer:GetAttribute("Money")) or 0
                if money >= cost then
                    safeRequest("BuyCapacity")
                end
            end
        end

        if State.AutoUseItems then
            local selectedSet = {}
            for _, itemName in ipairs(State.SelectedItemsToUse or {}) do
                selectedSet[itemName] = true
            end
            local invItems = getItemsTable()
            for itemKey, count in pairs(invItems) do
                if (tonumber(count) or 0) > 0 then
                    local baseKind = itemKey:match("^(%w+):%d+$") or itemKey
                    if selectedSet[baseKind] then
                        local activeAttr = nil
                        if baseKind == "Luck2" then activeAttr = LocalPlayer:GetAttribute("Boost_Luck2")
                        elseif baseKind == "Luck5" then activeAttr = LocalPlayer:GetAttribute("Boost_Luck5")
                        elseif baseKind == "Money" then activeAttr = LocalPlayer:GetAttribute("Boost_Money")
                        elseif baseKind == "Train" then activeAttr = LocalPlayer:GetAttribute("Boost_Train")
                        elseif baseKind == "Lucky" then activeAttr = LocalPlayer:GetAttribute("LuckyThrows")
                        elseif baseKind == "Lucky10" then activeAttr = LocalPlayer:GetAttribute("LuckyThrows10")
                        end
                        if (tonumber(activeAttr) or 0) <= 0 then
                            safeRequest("UseItem", { key = itemKey })
                            task.wait(0.25)
                        end
                    end
                end
            end
        end
        task.wait(1.0)
    end
end))

--// 7. Auto Events, Gifts, Harvest & Big Tom Loop
table.insert(Loops, task.spawn(function()
    local lastGiftClaim = 0
    local lastDailyClaim = 0
    local lastTomJoin = 0
    local lastTomChest = 0
    local lastTomFire = 0
    local lastTomSync = 0

    while Running do
        local nowServer = workspace:GetServerTimeNow()

        if State.AutoClaimGifts and os.clock() - lastGiftClaim >= 5 then
            local sessionStart = tonumber(LocalPlayer:GetAttribute("SessionStart")) or nowServer
            local elapsed = nowServer - sessionStart
            local claimedStr = tostring(LocalPlayer:GetAttribute("GiftsClaimed") or "")
            local claimedMap = {}
            for num in claimedStr:gmatch("%d+") do
                claimedMap[tonumber(num)] = true
            end
            local anyReady = false
            for idx, gift in ipairs(Balance.Gifts or {}) do
                if not claimedMap[idx] and elapsed >= (gift.at - 1) then
                    anyReady = true
                    break
                end
            end
            if anyReady then
                lastGiftClaim = os.clock()
                pcall(function()
                    RemoteClaimAllGifts:InvokeServer()
                end)
                ensureIdentity()
            end
        end

        if State.AutoClaimDaily and os.clock() - lastDailyClaim >= 10 then
            if LocalPlayer:GetAttribute("DailyReady") == true then
                lastDailyClaim = os.clock()
                safeRequest("ClaimDaily")
            end
        end

        if State.AutoHarvestBasket and (tonumber(LocalPlayer:GetAttribute("BasketHeld")) or 0) > 0 then
            local standAt = Balance.Harvest and Balance.Harvest.StandAt
            local _, hrp = getCharacter()
            local prevCF = hrp and hrp.CFrame or nil
            if standAt and hrp and (hrp.Position - standAt.Position).Magnitude > 14 then
                teleportToCFrame(standAt * CFrame.new(0, 3, 4))
                task.wait(0.18)
            end
            safeRequest("HarvestHazel")
            if prevCF and not State.AutoTrain and not State.AutoThrow then
                task.wait(0.1)
                teleportToCFrame(prevCF)
            end
        end

        if State.AutoHarvestBuy then
            local step = tonumber(LocalPlayer:GetAttribute("HarvestStep")) or 0
            local standItem = Balance.Harvest and Balance.Harvest.Stand and Balance.Harvest.Stand[step + 1]
            local cranberries = tonumber(LocalPlayer:GetAttribute("Cranberries")) or 0
            if standItem and cranberries >= standItem.price then
                local standAt = Balance.Harvest and Balance.Harvest.StandAt
                local _, hrp = getCharacter()
                local prevCF = hrp and hrp.CFrame or nil
                if standAt and hrp and (hrp.Position - standAt.Position).Magnitude > 14 then
                    teleportToCFrame(standAt * CFrame.new(0, 3, 4))
                    task.wait(0.18)
                end
                safeRequest("HarvestBuy")
                if prevCF and not State.AutoTrain and not State.AutoThrow then
                    task.wait(0.1)
                    teleportToCFrame(prevCF)
                end
            end
        end

        local tomState = workspace:GetAttribute("BigTomState")
        if tomState then
            if State.AutoBigTomJoin and tomState == "board" and not LocalPlayer:GetAttribute("BigTomCart") and os.clock() - lastTomJoin >= 2 then
                lastTomJoin = os.clock()
                safeRequest("BigTom", { what = "join" })
            end

            if State.AutoBigTomFire and tomState == "fight" and LocalPlayer:GetAttribute("BigTomCart") then
                local cartIdx = tonumber(LocalPlayer:GetAttribute("BigTomCart"))
                local t0 = tonumber(workspace:GetAttribute("BigTomT0"))
                if cartIdx and t0 and os.clock() - lastTomFire >= (Balance.BigTom.Reload or 1) then
                    local s = BigTomPath.CartS(cartIdx, math.max(0, nowServer - t0))
                    if s then
                        local okPos, cartCF = pcall(BigTomPath.At, s)
                        if okPos and cartCF then
                            local flatDist = ((cartCF.Position - Balance.BigTom.Boss) * Vector3.new(1, 0, 1)).Magnitude
                            if flatDist >= Balance.BigTom.Range[1] and flatDist <= Balance.BigTom.Range[2] then
                                local charge = BigTomPath.ChargeFor(cartCF.Position)
                                lastTomFire = os.clock()
                                safeRequest("BigTom", { what = "fire", charge = charge })
                            end
                        end
                    end
                end
            end

            if State.AutoBigTomSmash and tomState == "smash" and LocalPlayer:GetAttribute("BigTomSmash") == true then
                if next(ActiveBigTomTurkeys) == nil and os.clock() - lastTomSync >= 2 then
                    lastTomSync = os.clock()
                    local okSync, syncData = safeRequest("BigTom", { what = "sync" })
                    if okSync and type(syncData) == "table" and type(syncData.turkeys) == "table" then
                        local aliveSet = {}
                        if type(syncData.alive) == "table" then
                            for _, id in ipairs(syncData.alive) do aliveSet[id] = true end
                        end
                        for id, coord in pairs(syncData.turkeys) do
                            if not syncData.alive or aliveSet[id] then
                                ActiveBigTomTurkeys[id] = Vector3.new(coord[1], Balance.BigTom.Boss.Y, coord[2])
                            end
                        end
                    end
                end
                local _, hrp = getCharacter()
                if hrp then
                    for turkeyId, pos in pairs(ActiveBigTomTurkeys) do
                        local dist = ((pos - hrp.Position) * Vector3.new(1, 0, 1)).Magnitude
                        if dist > (Balance.BigTom.SmashReach or 16) - 6 then
                            teleportToCFrame(CFrame.new(pos + Vector3.new(0, 3, 2)))
                            task.wait(0.12)
                        end
                        local okSmash = safeRequest("BigTom", { what = "smash", id = turkeyId })
                        if okSmash then
                            ActiveBigTomTurkeys[turkeyId] = nil
                        end
                        break
                    end
                end
            elseif tomState ~= "smash" and next(ActiveBigTomTurkeys) ~= nil then
                table.clear(ActiveBigTomTurkeys)
            end

            if State.AutoBigTomChest and tomState == "chest" and os.clock() - lastTomChest >= 2 then
                lastTomChest = os.clock()
                safeRequest("BigTom", { what = "chest" })
            end
        end

        if State.AutoAbuseGrab then
            local _, hrp = getCharacter()
            for key, item in pairs(ActiveAbuseDrops) do
                if nowServer >= item.at and os.clock() - item.lastTry >= 0.7 then
                    local dropPos = item.pos
                    if item.path and #item.path > 0 then
                        local stepIdx = math.min(math.floor(math.max(nowServer - item.at, 0) / item.step) + 1, #item.path)
                        local pt = item.path[stepIdx]
                        if pt then
                            dropPos = Vector3.new(pt[1], item.pos.Y, pt[2])
                        end
                    end
                    if hrp and ((hrp.Position - dropPos) * Vector3.new(1, 0, 1)).Magnitude > 6 then
                        teleportToCFrame(CFrame.new(dropPos + Vector3.new(0, 3, 0)))
                        task.wait(0.12)
                    end
                    item.lastTry = os.clock()
                    local okGrab, resGrab = safeRequest("AbuseGrab", { kind = item.kind, id = item.id, drop = item.drop })
                    if okGrab or resGrab == "full" then
                        ActiveAbuseDrops[key] = nil
                    end
                end
            end
        end

        task.wait(0.25)
    end
end))

--// 8. Movement, Noclip & Anti-AFK Connections
addConn(RunService.Stepped:Connect(function()
    if not Running then return end
    local char, _, hum = getCharacter()
    if not char then return end

    if State.WalkSpeedEnabled and hum then
        hum.WalkSpeed = State.WalkSpeedValue
    end

    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

addConn(UserInputService.JumpRequest:Connect(function()
    if not Running or not State.InfiniteJump then return end
    local _, _, hum = getCharacter()
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

addConn(LocalPlayer.Idled:Connect(function()
    if not Running or not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    pcall(function()
        RemoteHere:FireServer()
    end)
end))

--// Register Cleanup Handler
env.XLunaHUB_TAS_Cleanup = function()
    Running = false
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    for _, th in ipairs(Loops) do
        pcall(task.cancel, th)
    end
    table.clear(Loops)
    ensureIdentity()
    pcall(function() Window:Destroy() end)
    local roots = { CoreGui }
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then table.insert(roots, hui) end
    end
    for _, root in ipairs(roots) do
        for _, gui in ipairs(root:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:sub(1, 6) == "WindUI" then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end

notify("XLunaHUB", "Loaded Throw a Seed hub. Press LeftCTRL to toggle.", 4, "check")
