-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [ð] Cut a Rock â Elite Automation Master Script
    Architecture: WindUI v1.6.65 / Modern Luau / Real MCP Execution
    Operating Directive: Universal English UI, Non-Negotiable Safety, ALL OFF Startup Default.
    Repository: E:\SC\Cut a Rock\ClientOP_CutARock.lua
]]

-- Anti-double-execution guard
if getgenv()._CUT_A_ROCK_RUNNING then
    if getgenv()._CUT_A_ROCK_UNLOAD then
        pcall(getgenv()._CUT_A_ROCK_UNLOAD)
    end
    task.wait(0.2)
end

-- Clean any stale WindUI ScreenGuis
local targetParent = gethui and gethui() or game:GetService("CoreGui")
for _, c in ipairs(targetParent:GetChildren()) do
    if string.find(c.Name, "WindUI") then
        pcall(c.Destroy, c)
    end
end

getgenv()._CUT_A_ROCK_RUNNING = true

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- LocalPlayer references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)
end)

-- Shared Modules & Remotes
local Remotes = {
    SellEvent = ReplicatedStorage:WaitForChild("SellEvent"),
    KapiVurusu = ReplicatedStorage:WaitForChild("KapiVurusu"),
    OrsVurusu = ReplicatedStorage:WaitForChild("OrsVurusu"),
    PlaceStoneInMachineEvent = ReplicatedStorage:WaitForChild("PlaceStoneInMachineEvent"),
    LevelUpMachineEvent = ReplicatedStorage:WaitForChild("LevelUpMachineEvent"),
    PickaxeBuyEvent = ReplicatedStorage:WaitForChild("PickaxeBuyEvent"),
    PickaxeEquipEvent = ReplicatedStorage:WaitForChild("PickaxeEquipEvent"),
    UpgradeEvent = ReplicatedStorage:WaitForChild("UpgradeEvent"),
    BaseaIsinlanEvent = ReplicatedStorage:WaitForChild("BaseaIsinlanEvent"),
    SatisIsinlanEvent = ReplicatedStorage:WaitForChild("SatisIsinlanEvent"),
    DailyRewardClaim = ReplicatedStorage:WaitForChild("DailyRewardClaim"),
    FreeGiftAl = ReplicatedStorage:WaitForChild("FreeGiftAl"),
    MemoryOyunu = ReplicatedStorage:WaitForChild("MemoryOyunu"),
    AuraTopla = ReplicatedStorage:WaitForChild("AuraTopla"),
    AuraSec = ReplicatedStorage:WaitForChild("AuraSec"),
    PromoKodKullan = ReplicatedStorage:WaitForChild("PromoKodKullan"),
}

local PickaxeListData = nil
pcall(function()
    PickaxeListData = require(ReplicatedStorage:WaitForChild("PickaxeList"))
end)

local UpgradePriceData = nil
pcall(function()
    UpgradePriceData = require(ReplicatedStorage:WaitForChild("UpgradePrice"))
end)

local AuraBonuslariData = nil
pcall(function()
    AuraBonuslariData = require(ReplicatedStorage:WaitForChild("AuraBonuslari"))
end)

local FormatNumberMod = nil
pcall(function()
    FormatNumberMod = require(ReplicatedStorage:WaitForChild("FormatNumber"))
end)

local function FormatNum(num)
    if FormatNumberMod and FormatNumberMod.format_number then
        local s, res = pcall(FormatNumberMod.format_number, num)
        if s and res then return res end
    end
    if type(num) ~= "number" then return tostring(num) end
    if num >= 1e15 then return string.format("%.2fQa", num / 1e15) end
    if num >= 1e12 then return string.format("%.2fT", num / 1e12) end
    if num >= 1e9 then return string.format("%.2fB", num / 1e9) end
    if num >= 1e6 then return string.format("%.2fM", num / 1e6) end
    if num >= 1e3 then return string.format("%.2fK", num / 1e3) end
    return tostring(math.floor(num + 0.5))
end

-- Pre-declare State for lexical scope access in hooks & callbacks
local State = {}

-- Automation State Table (Strictly ALL OFF by Default as per SOP Rule 8)
State = {
    -- Tab 1: Mining & Doors
    AutoMineRocks = false,
    MineSelectedRoom = "Current Room",
    TweenToRock = true,
    MineSpeedDelay = 0.35,
    AutoDepositRocks = false,
    AutoBreakDoors = false,
    TargetDoorFloor = "Auto (Current Floor)",
    DoorHitDelay = 0.3,
    AutoProgressFloors = false,
    RockESP = false,

    -- Tab 2: Anvil & Training
    AutoTrainAnvil = false,
    SelectedAnvilStation = "Best Available",
    AntiAnvilDrift = true,

    -- Tab 3: Machines & Cutting
    AutoCollectCutRocks = false,
    AutoDepositUncutRocks = false,
    AutoUpgradeMachines = false,
    AutoBuyBaseMachines = false,
    AutoSellAllCutStones = false,
    AutoSellInterval = 5,

    -- Tab 4: Upgrades & Gear
    AutoBuyBestPickaxe = false,
    AutoUpgradePocket = false,
    AutoUpgradeSight = false,

    -- Tab 5: Rewards & Progression
    AutoSolveMemoryGame = false,
    AutoClaimDailyReward = false,
    AutoClaimAuras = false,
    AutoEquipBestAura = false,

    -- Tab 7: Movement & Character
    CustomWalkSpeed = false,
    WalkSpeedValue = 40,
    CustomJumpPower = false,
    JumpPowerValue = 50,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = false,
}
getgenv()._CUT_A_ROCK_STATE = State

-- Task Registry & Thread Lifecycle Manager
local ActiveTasks = {}
local function RegisterTask(thread)
    table.insert(ActiveTasks, thread)
    return thread
end

local ActiveConnections = {}
local function RegisterConnection(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

-- Load WindUI Framework
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Helper: Safe Notification
local function SafeNotify(opts)
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify(opts)
        end)
    end
end

-- Helper: Locate Player Personal Base
local function GetMyBase()
    local models = workspace:FindFirstChild("Models")
    local bases = models and models:FindFirstChild("Bases")
    if bases then
        for _, b in ipairs(bases:GetChildren()) do
            if b:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                return b
            end
        end
    end
    return nil
end

-- Helper: Get Player Money
local function GetPlayerMoney()
    local statlar = LocalPlayer:FindFirstChild("Statlar")
    local m = statlar and statlar:FindFirstChild("Money")
    return m and m.Value or 0
end

-- Helper: Get Player Power
local function GetPlayerPower()
    return LocalPlayer:GetAttribute("Power") or 0
end

-- Helper: Get Current Room Player is In
local function GetCurrentRoom()
    if not HumanoidRootPart then return nil end
    local pos = HumanoidRootPart.Position
    local rooms = workspace:FindFirstChild("Rooms")
    if not rooms then return nil end
    local closestRoom = nil
    local closestDist = math.huge
    for _, r in ipairs(rooms:GetChildren()) do
        local zemin = r:FindFirstChild("Zemin")
        if zemin and zemin:IsA("BasePart") then
            local dist = (zemin.Position - pos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestRoom = r
            end
        end
    end
    return closestRoom
end

-- Helper: Extract Room Number
local function GetRoomNumber(roomInstance)
    if not roomInstance then return 0 end
    local num = string.match(roomInstance.Name, "%d+")
    return tonumber(num) or 0
end

-- Helper: Get Active / Lowest Unbroken DigBlock
local function GetActiveDigBlock(targetRoomNum)
    local cs = game:GetService("CollectionService")
    local blocks = cs:GetTagged("DigBlock")
    if targetRoomNum and targetRoomNum >= 0 then
        local expectedName = "Room_" .. tostring(targetRoomNum)
        for _, b in ipairs(blocks) do
            if b.Parent and b.Parent.Parent and b.Parent.Parent.Name == expectedName then
                return b
            end
        end
    end
    -- Fallback: Find lowest unbroken door
    local sorted = {}
    for _, b in ipairs(blocks) do
        local rName = b.Parent and b.Parent.Parent and b.Parent.Parent.Name or ""
        local rNum = tonumber(string.match(rName, "%d+")) or 0
        table.insert(sorted, { block = b, roomNum = rNum })
    end
    table.sort(sorted, function(a, b) return a.roomNum < b.roomNum end)
    for _, entry in ipairs(sorted) do
        if entry.block.CanCollide then
            return entry.block
        end
    end
    return sorted[1] and sorted[1].block or nil
end

-- Helper: List of All Rooms
local AvailableRooms = { "Current Room" }
for i = 0, 39 do
    table.insert(AvailableRooms, "Room " .. i)
end

-- Helper: List of Anvil Stations
local AnvilStations = {
    "Best Available",
    "Ors_200x",
    "Ors_100x",
    "Ors_50x",
    "Ors_25x",
    "Ors_15x",
    "Ors_10x",
    "Ors_5x",
    "Ors_3x",
    "Ors_2x"
}

-- =========================================================================
-- BUILD MAIN WINDOW & TABS
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Cut a Rock",
    Icon = "gem",
    Author = "Elite Automation Suite",
    Folder = "CutARock",
    Size = UDim2.fromOffset(620, 500),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    OpenButton = {
        Title = "Open Script",
        Icon = "crosshair",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("00D2FF"),
            Color3.fromHex("00FF88")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
    ToggleKey = Enum.KeyCode.LeftControl,
})

local TabMining    = Window:Tab({ Title = "Mining & Doors", Icon = "pickaxe" })
local TabAnvil     = Window:Tab({ Title = "Anvil & Training", Icon = "flame" })
local TabMachines  = Window:Tab({ Title = "Machines & Cutting", Icon = "wrench" })
local TabGear      = Window:Tab({ Title = "Upgrades & Gear", Icon = "shield" })
local TabRewards   = Window:Tab({ Title = "Minigames & Rewards", Icon = "gift" })
local TabTeleports = Window:Tab({ Title = "World & Teleports", Icon = "map-pin" })
local TabMovement  = Window:Tab({ Title = "Movement", Icon = "gauge" })
local TabConfig    = Window:Tab({ Title = "Configuration", Icon = "settings" })

getgenv()._CUT_A_ROCK_WINDOW = Window

-- =========================================================================
-- TAB 1: MINING & DOORS
-- =========================================================================
TabMining:Section({
    Title = "Rock Vein Excavation",
    Opened = true,
})

local MiningStatusLabel = TabMining:Paragraph({
    Title = "Mining Status",
    Desc = "Standby - Auto rock sweep and floor door destruction are idle.",
})

TabMining:Toggle({
    Title = "Auto Mine Rock Veins",
    Desc = "Continuously sweeps and harvests rock veins in the target room, bypassing prompt hold duration",
    Value = State.AutoMineRocks,
    Callback = function(val)
        State.AutoMineRocks = val
    end,
})

TabMining:Dropdown({
    Title = "Mining Room Target",
    Desc = "Select whether to harvest the current room or target a specific floor room",
    Values = AvailableRooms,
    Value = State.MineSelectedRoom,
    Callback = function(val)
        State.MineSelectedRoom = val
    end,
})

TabMining:Toggle({
    Title = "Auto Deposit Rocks on Full Bag",
    Desc = "Teleports to spawn when pocket capacity is reached to transfer rocks to inventory, then returns",
    Value = State.AutoDepositRocks,
    Callback = function(val)
        State.AutoDepositRocks = val
    end,
})

TabMining:Slider({
    Title = "Rock Mining Delay",
    Desc = "Adjust dwell delay per rock harvest (seconds)",
    Value = {
        Min = 0.1,
        Max = 1.0,
        Default = 0.35,
    },
    Step = 0.05,
    Callback = function(val)
        State.MineSpeedDelay = val
    end,
})

TabMining:Section({
    Title = "Floor Door Demolition",
    Opened = true,
})

TabMining:Toggle({
    Title = "Auto Break Floor Doors",
    Desc = "Rapidly strikes active room exit doors (DigBlock) with maximum server-registered hit packets",
    Value = State.AutoBreakDoors,
    Callback = function(val)
        State.AutoBreakDoors = val
    end,
})

TabMining:Dropdown({
    Title = "Target Floor Door",
    Desc = "Select specific floor door to target or automatically target lowest unbroken door",
    Values = { "Auto (Current Floor)", "Room 0 Exit", "Room 1 Exit", "Room 2 Exit", "Room 3 Exit", "Room 4 Exit", "Room 5 Exit", "Room 6 Exit", "Room 7 Exit", "Room 8 Exit", "Room 9 Exit", "Room 10 Exit", "Room 11 Exit", "Room 12 Exit", "Room 13 Exit", "Room 14 Exit", "Room 15 Exit" },
    Value = State.TargetDoorFloor,
    Callback = function(val)
        State.TargetDoorFloor = val
    end,
})

TabMining:Toggle({
    Title = "Auto Progress Floors",
    Desc = "Automatically drops down to subsequent floor doors as each exit barrier breaks",
    Value = State.AutoProgressFloors,
    Callback = function(val)
        State.AutoProgressFloors = val
    end,
})

TabMining:Toggle({
    Title = "Rock Vein ESP",
    Desc = "Highlights rock veins with rarity tags and distance indicators",
    Value = State.RockESP,
    Callback = function(val)
        State.RockESP = val
        if not val then
            for _, r in ipairs(workspace:GetDescendants()) do
                local esp = r:FindFirstChild("CutARock_ESP")
                if esp then pcall(esp.Destroy, esp) end
            end
        end
    end,
})

-- =========================================================================
-- TAB 2: ANVIL & TRAINING
-- =========================================================================
TabAnvil:Section({
    Title = "Power Anvil Training (AFK Farm)",
    Opened = true,
})

local AnvilStatusLabel = TabAnvil:Paragraph({
    Title = "Training Status",
    Desc = "Standby - Auto anvil power generation is idle.",
})

TabAnvil:Toggle({
    Title = "Auto Train on Anvil",
    Desc = "Teleports to the best available Anvil in AFK Farm and maintains alignment for maximum Power scaling",
    Value = State.AutoTrainAnvil,
    Callback = function(val)
        State.AutoTrainAnvil = val
    end,
})

TabAnvil:Dropdown({
    Title = "Select Anvil Station",
    Desc = "Choose station multiplier or let the script auto-select the highest available",
    Values = AnvilStations,
    Value = State.SelectedAnvilStation,
    Callback = function(val)
        State.SelectedAnvilStation = val
    end,
})

TabAnvil:Toggle({
    Title = "Anti-Drift Lock",
    Desc = "Locks player CFrame on the anvil pad to prevent server push-out or physics drift",
    Value = State.AntiAnvilDrift,
    Callback = function(val)
        State.AntiAnvilDrift = val
    end,
})

-- =========================================================================
-- TAB 3: MACHINES & CUTTING
-- =========================================================================
TabMachines:Section({
    Title = "Base Cutting Automation",
    Opened = true,
})

local MachineStatusLabel = TabMachines:Paragraph({
    Title = "Machine Status",
    Desc = "Standby - Ready to process stones and sell cut gems.",
})

TabMachines:Toggle({
    Title = "Auto Collect Cut Rocks",
    Desc = "Automatically sweeps finished base machines and collects cut gems from trays (Durum: Hazir)",
    Value = State.AutoCollectCutRocks,
    Callback = function(val)
        State.AutoCollectCutRocks = val
    end,
})

TabMachines:Toggle({
    Title = "Auto Deposit Uncut Rocks",
    Desc = "Scans personal base machines (Yuva 1-6) and immediately deposits uncut rocks from inventory into idle machines",
    Value = State.AutoDepositUncutRocks,
    Callback = function(val)
        State.AutoDepositUncutRocks = val
    end,
})

TabMachines:Toggle({
    Title = "Auto Upgrade Machines",
    Desc = "Automatically buys next level upgrades for base machines when Money is available",
    Value = State.AutoUpgradeMachines,
    Callback = function(val)
        State.AutoUpgradeMachines = val
    end,
})

TabMachines:Button({
    Title = "Buy All Available Base Machines",
    Desc = "Instantly purchases any unowned machine slots in player base without continuous teleport spam",
    Callback = function()
        local myBase = GetMyBase()
        if not (myBase and HumanoidRootPart) then return end
        local buyable = {}
        for _, desc in ipairs(myBase:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Name == "BuyMachinePrompt" and desc.Enabled then
                table.insert(buyable, desc)
            end
        end
        if #buyable == 0 then
            SafeNotify({
                Title = "Machines Owned",
                Content = "All base machine slots are already owned!",
                Duration = 2.5,
                Icon = "check"
            })
            return
        end
        local originalCF = HumanoidRootPart.CFrame
        for _, p in ipairs(buyable) do
            local part = p.Parent
            if part and part:IsA("BasePart") then
                HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 2.5, 0)
                task.wait(0.15)
                p.HoldDuration = 0
                fireproximityprompt(p)
                task.wait(0.25)
            end
        end
        HumanoidRootPart.CFrame = originalCF
        SafeNotify({
            Title = "Machines Purchased",
            Content = "Successfully purchased unowned machine slots.",
            Duration = 2.5,
            Icon = "shopping-cart"
        })
    end,
})

TabMachines:Toggle({
    Title = "Auto Buy Base Machines",
    Desc = "Purchases unowned machine slots once when available and automatically turns off (No teleport spam)",
    Value = State.AutoBuyBaseMachines,
    Callback = function(val)
        State.AutoBuyBaseMachines = val
    end,
})

TabMachines:Toggle({
    Title = "Auto Sell Cut Stones (Instant Cash)",
    Desc = "Fires SellAll remote whenever cut gems/stones are ready, converting inventory to instant millions/billions",
    Value = State.AutoSellAllCutStones,
    Callback = function(val)
        State.AutoSellAllCutStones = val
    end,
})

TabMachines:Button({
    Title = "Instant Sell All Cut Stones Now",
    Desc = "Immediately executes SellAll remote to convert all cut gems to Cash",
    Callback = function()
        pcall(function()
            Remotes.SellEvent:FireServer("SellAll")
            SafeNotify({
                Title = "Sold Inventory",
                Content = "All cut stones sold for instant cash!",
                Duration = 2.5,
                Icon = "dollar-sign"
            })
        end)
    end,
})

-- =========================================================================
-- TAB 4: UPGRADES & PICKAXES
-- =========================================================================
TabGear:Section({
    Title = "Pickaxes & Stat Upgrades",
    Opened = true,
})

local GearStatusLabel = TabGear:Paragraph({
    Title = "Gear Overview",
    Desc = "Equipped Pickaxe: Loading... | Pocket: Loading... | Sight: Loading...",
})

TabGear:Toggle({
    Title = "Auto Buy & Equip Best Pickaxe",
    Desc = "Evaluates Pickaxe 1 to 38, automatically buying the highest affordable pickaxe and equipping it",
    Value = State.AutoBuyBestPickaxe,
    Callback = function(val)
        State.AutoBuyBestPickaxe = val
    end,
})

TabGear:Toggle({
    Title = "Auto Upgrade Pocket Capacity",
    Desc = "Continuously upgrades bag storage capacity as Money accumulates",
    Value = State.AutoUpgradePocket,
    Callback = function(val)
        State.AutoUpgradePocket = val
    end,
})

TabGear:Toggle({
    Title = "Auto Upgrade Sight",
    Desc = "Continuously upgrades vision / discovery sight range as Money accumulates",
    Value = State.AutoUpgradeSight,
    Callback = function(val)
        State.AutoUpgradeSight = val
    end,
})

-- =========================================================================
-- TAB 5: MINIGAMES & REWARDS
-- =========================================================================
TabRewards:Section({
    Title = "Minigame Exploits & Free Power",
    Opened = true,
})

local RewardStatusLabel = TabRewards:Paragraph({
    Title = "Reward Overview",
    Desc = "Daily Rewards & Memory Minigame standby.",
})

TabRewards:Toggle({
    Title = "Auto Solve Memory Game (Free Power)",
    Desc = "Automatically plays and solves the memory game both visually on-screen and headless in the background for massive Power",
    Value = State.AutoSolveMemoryGame,
    Callback = function(val)
        State.AutoSolveMemoryGame = val
    end,
})

TabRewards:Button({
    Title = "Open In-Game Memory Menu",
    Desc = "Opens the native in-game Memory Menu GUI on your screen to watch the auto-solver live",
    Callback = function()
        pcall(function()
            local mm = LocalPlayer.PlayerGui:FindFirstChild("MemoryMenu")
            if mm then
                mm.Enabled = not mm.Enabled
            end
        end)
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Daily Login Rewards",
    Desc = "Automatically claims daily calendar reward and 2x boosters",
    Value = State.AutoClaimDailyReward,
    Callback = function(val)
        State.AutoClaimDailyReward = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Discovered Auras",
    Desc = "Automatically claims auras once all 5 materials of a stone tier are indexed",
    Value = State.AutoClaimAuras,
    Callback = function(val)
        State.AutoClaimAuras = val
    end,
})

TabRewards:Toggle({
    Title = "Auto Equip Best Aura",
    Desc = "Automatically equips the aura providing the highest money multiplier (up to 12x)",
    Value = State.AutoEquipBestAura,
    Callback = function(val)
        State.AutoEquipBestAura = val
    end,
})

TabRewards:Button({
    Title = "Redeem All Active Promo Codes",
    Desc = "Submits known promotional codes for rewards and tickets",
    Callback = function()
        pcall(function()
            local codes = { "RELEASE", "ROCK", "POWER", "DUALITY", "UPDATE1" }
            for _, c in ipairs(codes) do
                pcall(Remotes.PromoKodKullan.InvokeServer, Remotes.PromoKodKullan, c)
                task.wait(0.2)
            end
            SafeNotify({
                Title = "Promo Codes",
                Content = "Attempted all promo codes redemption.",
                Duration = 3,
                Icon = "tag"
            })
        end)
    end,
})

-- =========================================================================
-- TAB 6: WORLD & TELEPORTS
-- =========================================================================
TabTeleports:Section({
    Title = "Essential Hub Teleports",
    Opened = true,
})

TabTeleports:Button({
    Title = "Teleport to My Base",
    Desc = "Transports character to your cutting base entrance",
    Callback = function()
        local base = GetMyBase()
        if base and HumanoidRootPart then
            local p = base:GetPivot()
            HumanoidRootPart.CFrame = p + Vector3.new(0, 3, 0)
            pcall(Remotes.BaseaIsinlanEvent.FireServer, Remotes.BaseaIsinlanEvent, true)
        end
    end,
})

TabTeleports:Button({
    Title = "Teleport to Sell Stand",
    Desc = "Transports character directly to the market sell stand",
    Callback = function()
        local mp = workspace:FindFirstChild("MarketsPoint")
        if mp and HumanoidRootPart then
            HumanoidRootPart.CFrame = mp.CFrame + Vector3.new(0, 3, 0)
            pcall(Remotes.SatisIsinlanEvent.FireServer, Remotes.SatisIsinlanEvent, true)
        end
    end,
})

TabTeleports:Button({
    Title = "Teleport to Spawn Location",
    Desc = "Transports character to spawn and empties pocket rocks into inventory",
    Callback = function()
        local sp = workspace:FindFirstChild("SpawnLocation", true)
        if sp and HumanoidRootPart then
            HumanoidRootPart.CFrame = sp.CFrame + Vector3.new(0, 5, 0)
        end
    end,
})

TabTeleports:Section({
    Title = "AFK Farm Anvil Teleports",
    Opened = false,
})

for _, stName in ipairs(AnvilStations) do
    if stName ~= "Best Available" then
        TabTeleports:Button({
            Title = "Anvil Station: " .. stName,
            Desc = "Teleport to " .. stName .. " in AFK Farm",
            Callback = function()
                local afk = workspace:FindFirstChild("Models") and workspace.Models:FindFirstChild("World") and workspace.Models.World:FindFirstChild("AfkFarm")
                local ist = afk and afk:FindFirstChild("Istasyonlar")
                local target = ist and ist:FindFirstChild(stName)
                local train = target and target:FindFirstChild("TrainAlani")
                if train and HumanoidRootPart then
                    HumanoidRootPart.CFrame = train.CFrame + Vector3.new(0, 2, 0)
                end
            end,
        })
    end
end

TabTeleports:Section({
    Title = "Floor Room Teleports (Rooms 0 - 15)",
    Opened = false,
})

for i = 0, 15 do
    TabTeleports:Button({
        Title = "Teleport to Room " .. i,
        Desc = "Transports character to Room " .. i .. " floor",
        Callback = function()
            local r = workspace:FindFirstChild("Rooms") and workspace.Rooms:FindFirstChild("Room_" .. i)
            local zemin = r and r:FindFirstChild("Zemin")
            if zemin and HumanoidRootPart then
                HumanoidRootPart.CFrame = zemin.CFrame + Vector3.new(0, 4, 0)
            end
        end,
    })
end

-- =========================================================================
-- TAB 7: MOVEMENT & CHARACTER
-- =========================================================================
TabMovement:Section({
    Title = "Player Movement Modifiers",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Custom WalkSpeed",
    Desc = "Enforces custom movement speed",
    Value = State.CustomWalkSpeed,
    Callback = function(val)
        State.CustomWalkSpeed = val
        if not val and Humanoid then
            Humanoid.WalkSpeed = 16
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Desc = "Adjust walking velocity",
    Value = {
        Min = 16,
        Max = 150,
        Default = 40,
    },
    Step = 1,
    Callback = function(val)
        State.WalkSpeedValue = val
        if State.CustomWalkSpeed and Humanoid then
            Humanoid.WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Custom JumpPower",
    Desc = "Enforces custom jump power",
    Value = State.CustomJumpPower,
    Callback = function(val)
        State.CustomJumpPower = val
        if not val and Humanoid then
            Humanoid.JumpPower = 50
        end
    end,
})

TabMovement:Slider({
    Title = "JumpPower Value",
    Desc = "Adjust jumping force",
    Value = {
        Min = 50,
        Max = 250,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        State.JumpPowerValue = val
        if State.CustomJumpPower and Humanoid then
            Humanoid.JumpPower = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Disables character body part collisions to move through walls and doors freely",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping repeatedly in mid-air",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents Roblox 20-minute idle disconnection",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =========================================================================
-- TAB 8: CONFIGURATION
-- =========================================================================
TabConfig:Section({
    Title = "Profile & Storage",
    Opened = true,
})

local ConfigFilePath = "CutARock_Config.json"

TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Saves active toggles, sliders, and preferences to local JSON",
    Callback = function()
        pcall(function()
            local serialized = HttpService:JSONEncode(State)
            if writefile then
                writefile(ConfigFilePath, serialized)
                SafeNotify({
                    Title = "Config Saved",
                    Content = "Configuration saved to " .. ConfigFilePath,
                    Duration = 2.5,
                    Icon = "check"
                })
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Loads saved preferences from local JSON",
    Callback = function()
        pcall(function()
            if readfile and isfile and isfile(ConfigFilePath) then
                local data = HttpService:JSONDecode(readfile(ConfigFilePath))
                for k, v in pairs(data) do
                    if State[k] ~= nil then
                        State[k] = v
                    end
                end
                SafeNotify({
                    Title = "Config Loaded",
                    Content = "Configuration applied successfully.",
                    Duration = 2.5,
                    Icon = "upload"
                })
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Reset Defaults (ALL OFF)",
    Desc = "Disables all automation features and resets modifiers",
    Callback = function()
        for k, v in pairs(State) do
            if type(v) == "boolean" then
                State[k] = false
            end
        end
        if Humanoid then
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end
        SafeNotify({
            Title = "Defaults Restored",
            Content = "All automation toggles turned OFF.",
            Duration = 2.5,
            Icon = "rotate-ccw"
        })
    end,
})

TabConfig:Button({
    Title = "Unload Script Cleanly",
    Desc = "Safely cancels all threads, unhooks connections, and destroys UI",
    Callback = function()
        if getgenv()._CUT_A_ROCK_UNLOAD then
            getgenv()._CUT_A_ROCK_UNLOAD()
        end
    end,
})

-- =========================================================================
-- WORKER 1: AUTO MINE ROCK VEINS (POCKET CAPACITY AWARE & RESILIENT)
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        local ok, err = pcall(function()
            if not (State.AutoMineRocks and HumanoidRootPart and HumanoidRootPart.Parent) then
                task.wait(0.4)
                return
            end

            -- 1. Determine Target Room
            local roomToMine = nil
            local targetSetting = State.MineSelectedRoom
            if targetSetting == "Current Room" then
                roomToMine = GetCurrentRoom()
            else
                local rNum = tonumber(string.match(targetSetting, "%d+"))
                if rNum then
                    roomToMine = workspace:FindFirstChild("Rooms") and workspace.Rooms:FindFirstChild("Room_" .. rNum)
                end
            end

            if not (roomToMine and roomToMine:FindFirstChild("Rocks")) then
                pcall(function()
                    if MiningStatusLabel and MiningStatusLabel.SetDesc then
                        MiningStatusLabel:SetDesc("Waiting for room to load: " .. tostring(targetSetting))
                    end
                end)
                task.wait(0.6)
                return
            end

            -- 2. Scan available rock veins in room
            local rocks = roomToMine.Rocks:GetChildren()
            local unmined = {}
            for _, r in ipairs(rocks) do
                local p = r:FindFirstChildWhichIsA("ProximityPrompt", true)
                if p and p.Enabled then
                    table.insert(unmined, { model = r, prompt = p })
                end
            end

            if #unmined == 0 then
                pcall(function()
                    if MiningStatusLabel and MiningStatusLabel.SetDesc then
                        MiningStatusLabel:SetDesc(string.format("All rocks cleared in %s. Waiting for respawn...", roomToMine.Name))
                    end
                end)
                task.wait(0.6)
                return
            end

            pcall(function()
                if MiningStatusLabel and MiningStatusLabel.SetDesc then
                    MiningStatusLabel:SetDesc(string.format("Mining %s: %d rock veins found.", roomToMine.Name, #unmined))
                end
            end)

            -- 3. Iterate unmined rocks with dynamic safety and fast room-switch detection
            for idx, item in ipairs(unmined) do
                if not State.AutoMineRocks then break end
                -- Break immediately if user switched target room dropdown or changed floor
                if State.MineSelectedRoom ~= targetSetting then break end

                -- Check instance existence before indexing (Prevents 'attempt to index nil with IsA' crash)
                if not (item.model and item.model.Parent and item.prompt and item.prompt.Parent and item.prompt.Enabled) then
                    continue
                end

                -- Safe BasePart resolution
                local part = nil
                if item.prompt.Parent:IsA("BasePart") then
                    part = item.prompt.Parent
                elseif item.model:FindFirstChildWhichIsA("BasePart") then
                    part = item.model:FindFirstChildWhichIsA("BasePart")
                end

                if not (part and part.Parent) then
                    continue
                end

                -- Pocket capacity check & guaranteed auto-deposit (Prevents getting stuck on full bag)
                local cep = LocalPlayer:FindFirstChild("Cep")
                local cepCount = cep and #cep:GetChildren() or 0
                local maxPocket = 8
                pcall(function()
                    local kb = require(ReplicatedStorage.KaliciBonuslar)
                    maxPocket = kb.CepKapasitesi(LocalPlayer)
                end)

                if cepCount >= maxPocket then
                    pcall(function()
                        if MiningStatusLabel and MiningStatusLabel.SetDesc then
                            MiningStatusLabel:SetDesc(string.format("Pocket full (%d/%d)! Depositing rocks...", cepCount, maxPocket))
                        end
                    end)

                    local spawnLoc = workspace:FindFirstChild("SpawnAlani") and workspace.SpawnAlani:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("SpawnLocation", true)
                    if spawnLoc and HumanoidRootPart then
                        if firetouchinterest then
                            firetouchinterest(HumanoidRootPart, spawnLoc, 0)
                            task.wait(0.05)
                            firetouchinterest(HumanoidRootPart, spawnLoc, 1)
                            task.wait(0.1)
                        end

                        -- Physical fallback only if bag is still full after touch
                        if cep and #cep:GetChildren() >= maxPocket then
                            local savedCF = HumanoidRootPart.CFrame
                            HumanoidRootPart.CFrame = spawnLoc.CFrame + Vector3.new(0, 4, 0)
                            task.wait(0.3)
                            HumanoidRootPart.CFrame = savedCF
                            task.wait(0.15)
                        end
                    end
                end

                -- Re-verify prompt & part validity post-deposit
                if not (item.prompt and item.prompt.Parent and item.prompt.Enabled and part and part.Parent) then
                    continue
                end

                -- Move to rock with safe vertical clearance
                if State.TweenToRock and HumanoidRootPart then
                    HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.08)
                end

                -- Fire proximity prompt safely
                pcall(function()
                    item.prompt.HoldDuration = 0
                    item.prompt.MaxActivationDistance = 999
                    fireproximityprompt(item.prompt)
                end)

                pcall(function()
                    if MiningStatusLabel and MiningStatusLabel.SetDesc then
                        MiningStatusLabel:SetDesc(string.format("Mining %s [%d/%d veins]", roomToMine.Name, idx, #unmined))
                    end
                end)

                task.wait(State.MineSpeedDelay or 0.35)
            end
        end)

        if not ok then
            warn("[Worker 1 Resilient Catch]:", err)
            task.wait(0.5)
        end
    end
end))
-- =========================================================================
-- WORKER 2: AUTO BREAK FLOOR DOORS (KAPIVURUSU)
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        if State.AutoBreakDoors and HumanoidRootPart then
            local targetRoomNum = nil
            if State.TargetDoorFloor ~= "Auto (Current Floor)" then
                targetRoomNum = tonumber(string.match(State.TargetDoorFloor, "%d+"))
            else
                local curRoom = GetCurrentRoom()
                targetRoomNum = curRoom and GetRoomNumber(curRoom) or 0
            end

            local digBlock = GetActiveDigBlock(targetRoomNum)
            if digBlock and digBlock.Parent then
                if digBlock.CanCollide then
                    HumanoidRootPart.CFrame = digBlock.CFrame + Vector3.new(0, 2.5, 0)
                    local sTime = workspace:GetServerTimeNow()
                    pcall(Remotes.KapiVurusu.FireServer, Remotes.KapiVurusu, digBlock, sTime, HumanoidRootPart.Position)

                    local maxHp = digBlock:GetAttribute("MaxHealth") or "???"
                    pcall(function()
                        if MiningStatusLabel and MiningStatusLabel.SetDesc then
                            local roomName = digBlock.Parent and digBlock.Parent.Parent and digBlock.Parent.Parent.Name or "Door"
                            MiningStatusLabel:SetDesc(string.format("Smashing %s Door! Max HP: %s", roomName, FormatNum(maxHp)))
                        end
                    end)
                    task.wait(State.DoorHitDelay or 0.3)
                else
                    -- Door broken!
                    if State.AutoProgressFloors then
                        local curNum = targetRoomNum or 0
                        local nextNum = curNum + 1
                        local nextRoom = workspace:FindFirstChild("Rooms") and workspace.Rooms:FindFirstChild("Room_" .. nextNum)
                        if nextRoom and nextRoom:FindFirstChild("Zemin") then
                            HumanoidRootPart.CFrame = nextRoom.Zemin.CFrame + Vector3.new(0, 5, 0)
                            pcall(function()
                                if MiningStatusLabel and MiningStatusLabel.SetDesc then
                                    MiningStatusLabel:SetDesc("Door broken! Progressed to Room " .. nextNum)
                                end
                            end)
                            task.wait(1.0)
                        else
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            else
                task.wait(1.0)
            end
        else
            task.wait(0.5)
        end
    end
end))

-- =========================================================================
-- WORKER 3: ANVIL & TRAINING (AFK FARM)
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        if State.AutoTrainAnvil and HumanoidRootPart then
            local afk = workspace:FindFirstChild("Models") and workspace.Models:FindFirstChild("World") and workspace.Models.World:FindFirstChild("AfkFarm")
            local ist = afk and afk:FindFirstChild("Istasyonlar")
            local targetStation = nil

            if ist then
                if State.SelectedAnvilStation == "Best Available" then
                    -- Priority: 200x down to 2x
                    for _, sName in ipairs({ "Ors_200x", "Ors_100x", "Ors_50x", "Ors_25x", "Ors_15x", "Ors_10x", "Ors_5x", "Ors_3x", "Ors_2x" }) do
                        local s = ist:FindFirstChild(sName)
                        if s and s:FindFirstChild("TrainAlani") then
                            targetStation = s
                            break
                        end
                    end
                else
                    targetStation = ist:FindFirstChild(State.SelectedAnvilStation)
                end
            end

            if targetStation and targetStation:FindFirstChild("TrainAlani") then
                local trainPart = targetStation.TrainAlani
                local dist = (HumanoidRootPart.Position - trainPart.Position).Magnitude
                if dist > 8 then
                    HumanoidRootPart.CFrame = trainPart.CFrame + Vector3.new(0, 1.5, 0)
                    task.wait(0.3)
                end

                if State.AntiAnvilDrift then
                    HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                end

                pcall(Remotes.OrsVurusu.FireServer, Remotes.OrsVurusu)
                pcall(function()
                    if AnvilStatusLabel and AnvilStatusLabel.SetDesc then
                        local curPower = GetPlayerPower()
                        AnvilStatusLabel:SetDesc(string.format("Training on %s | Total Power: %s", targetStation.Name, FormatNum(curPower)))
                    end
                end)
                task.wait(0.5)
            else
                task.wait(1.0)
            end
        else
            task.wait(0.5)
        end
    end
end))

-- =========================================================================
-- WORKER 4: BASE MACHINES & CUTTING AUTOMATION
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        local myBase = GetMyBase()
        if myBase and HumanoidRootPart then
            -- 0. Auto Collect Finished Cut Rocks from Machines
            if State.AutoCollectCutRocks then
                local readyPrompts = {}
                for _, desc in ipairs(myBase:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Name == "CutMachinePrompt" then
                        if desc:GetAttribute("Durum") == "Hazir" or desc.ActionText == "Collect" then
                            table.insert(readyPrompts, desc)
                        end
                    end
                end

                if #readyPrompts > 0 then
                    local originalCF = HumanoidRootPart.CFrame
                    for _, p in ipairs(readyPrompts) do
                        if not State.AutoCollectCutRocks then break end
                        local part = p.Parent
                        if part and part:IsA("BasePart") then
                            HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.12)
                            p.HoldDuration = 0
                            p.MaxActivationDistance = 50
                            fireproximityprompt(p)
                            task.wait(0.15)
                        end
                    end
                    -- Return to previous position if player was mining or training
                    if State.AutoMineRocks or State.AutoTrainAnvil or State.AutoBreakDoors then
                        HumanoidRootPart.CFrame = originalCF
                        task.wait(0.2)
                    end
                end
            end

            -- 1. Auto Deposit Uncut Rocks into Idle Machines
            if State.AutoDepositUncutRocks then
                local env = LocalPlayer:FindFirstChild("Envanter")
                if env then
                    local uncutRocks = {}
                    for _, stone in ipairs(env:GetChildren()) do
                        if not stone:GetAttribute("Kesildi") and not stone:GetAttribute("Kesimde") then
                            table.insert(uncutRocks, stone)
                        end
                    end

                    if #uncutRocks > 0 then
                        for _, m in ipairs(myBase:GetChildren()) do
                            if m:IsA("Model") and m:GetAttribute("YuvaNo") then
                                local isWorking = m:GetAttribute("Calisiyor")
                                if not isWorking and #uncutRocks > 0 then
                                    local rockToCut = table.remove(uncutRocks, 1)
                                    pcall(Remotes.PlaceStoneInMachineEvent.FireServer, Remotes.PlaceStoneInMachineEvent, m, rockToCut.Name)
                                    rockToCut:SetAttribute("Kesimde", true)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end

            -- 2. Auto Upgrade Machines
            if State.AutoUpgradeMachines then
                local curMoney = GetPlayerMoney()
                for _, m in ipairs(myBase:GetChildren()) do
                    if m:IsA("Model") and m:GetAttribute("YuvaNo") then
                        local price = m:GetAttribute("SonrakiSeviyeFiyati")
                        if price and curMoney >= price then
                            pcall(Remotes.LevelUpMachineEvent.FireServer, Remotes.LevelUpMachineEvent, m, 1)
                            task.wait(0.2)
                        end
                    end
                end
            end

            -- 3. Auto Buy Unowned Machines (Non-Disruptive: Only triggers if an unowned machine actually exists)
            if State.AutoBuyBaseMachines and HumanoidRootPart then
                local buyable = {}
                for _, desc in ipairs(myBase:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Name == "BuyMachinePrompt" and desc.Enabled then
                        table.insert(buyable, desc)
                    end
                end

                if #buyable > 0 then
                    local originalCF = HumanoidRootPart.CFrame
                    for _, p in ipairs(buyable) do
                        if not State.AutoBuyBaseMachines then break end
                        local part = p.Parent
                        if part and part:IsA("BasePart") then
                            HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 2.5, 0)
                            task.wait(0.15)
                            p.HoldDuration = 0
                            fireproximityprompt(p)
                            task.wait(0.25)
                        end
                    end
                    HumanoidRootPart.CFrame = originalCF
                    task.wait(0.2)
                else
                    -- All machines are already owned, immediately turn off toggle so zero teleports happen!
                    State.AutoBuyBaseMachines = false
                end
            end
        end

        -- 4. Auto Sell Cut Stones
        if State.AutoSellAllCutStones then
            local env = LocalPlayer:FindFirstChild("Envanter")
            if env then
                local hasCut = false
                for _, stone in ipairs(env:GetChildren()) do
                    if stone:GetAttribute("Kesildi") == true then
                        hasCut = true
                        break
                    end
                end
                if hasCut then
                    pcall(Remotes.SellEvent.FireServer, Remotes.SellEvent, "SellAll")
                end
            end
        end

        pcall(function()
            if MachineStatusLabel and MachineStatusLabel.SetDesc then
                local env = LocalPlayer:FindFirstChild("Envanter")
                local totalItems = env and #env:GetChildren() or 0
                MachineStatusLabel:SetDesc(string.format("Base Machines active | Envanter Items: %d | Money: %s", totalItems, FormatNum(GetPlayerMoney())))
            end
        end)

        task.wait(1.0)
    end
end))

-- =========================================================================
-- WORKER 5: GEAR, PICKAXES & STAT UPGRADES
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        local curMoney = GetPlayerMoney()

        -- Auto Buy Best Pickaxe
        if State.AutoBuyBestPickaxe and PickaxeListData and PickaxeListData.Normal then
            local curPickaxe = LocalPlayer:GetAttribute("KusanilanKazma") or 1
            for i = #PickaxeListData.Normal, curPickaxe + 1, -1 do
                local pick = PickaxeListData.Normal[i]
                if pick and pick.Fiyat and curMoney >= pick.Fiyat then
                    pcall(Remotes.PickaxeBuyEvent.FireServer, Remotes.PickaxeBuyEvent, i)
                    task.wait(0.1)
                    pcall(Remotes.PickaxeEquipEvent.FireServer, Remotes.PickaxeEquipEvent, i)
                    task.wait(0.2)
                    break
                end
            end
        end

        -- Auto Upgrade Pocket
        if State.AutoUpgradePocket and UpgradePriceData and UpgradePriceData.pocket_price then
            local curPocket = LocalPlayer:GetAttribute("PocketLevel") or 1
            local nextPocketCost = UpgradePriceData.pocket_price[curPocket + 1]
            if nextPocketCost and curMoney >= nextPocketCost then
                pcall(Remotes.UpgradeEvent.FireServer, Remotes.UpgradeEvent, "Pocket", 1)
                task.wait(0.2)
            end
        end

        -- Auto Upgrade Sight
        if State.AutoUpgradeSight and UpgradePriceData and UpgradePriceData.sight_price then
            local curSight = LocalPlayer:GetAttribute("Sight") or 1
            local nextSightCost = UpgradePriceData.sight_price[curSight + 1]
            if nextSightCost and curMoney >= nextSightCost then
                pcall(Remotes.UpgradeEvent.FireServer, Remotes.UpgradeEvent, "Eyesight", 1)
                task.wait(0.2)
            end
        end

        pcall(function()
            if GearStatusLabel and GearStatusLabel.SetDesc then
                local pick = LocalPlayer:GetAttribute("KusanilanKazma") or 1
                local pLvl = LocalPlayer:GetAttribute("PocketLevel") or 1
                local sLvl = LocalPlayer:GetAttribute("Sight") or 1
                GearStatusLabel:SetDesc(string.format("Pickaxe: #%d | Pocket Lv: %d | Sight Lv: %d | Money: %s", pick, pLvl, sLvl, FormatNum(curMoney)))
            end
        end)

        task.wait(1.5)
    end
end))

-- =========================================================================
-- WORKER 6: MINIGAMES, AURAS & REWARDS
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        -- Auto Solve Memory Game (Interactive UI + Headless Mode)
        if State.AutoSolveMemoryGame and not State.AutoTrainAnvil then
            local mm = LocalPlayer.PlayerGui:FindFirstChild("MemoryMenu")
            local isGuiActive = mm and mm.Enabled

            if isGuiActive then
                -- Visual UI Solver Mode: Solves the in-game puzzle directly on screen
                pcall(function()
                    local mf = mm:FindFirstChild("MainFrame")
                    local alt = mf and mf:FindFirstChild("AltKutu")
                    local playBtn = alt and alt:FindFirstChild("PlayButonu")
                    local durum = alt and alt:FindFirstChild("Durum")
                    local izgara = mf and mf:FindFirstChild("Izgara")

                    if izgara and playBtn and durum then
                        local sampleBtn = nil
                        for _, c in ipairs(izgara:GetChildren()) do
                            if c:IsA("GuiButton") then sampleBtn = c; break end
                        end

                        local conns = sampleBtn and getconnections and getconnections(sampleBtn.MouseButton1Click)
                        local clickFn = conns and conns[1] and conns[1].Function

                        if clickFn and getupvalue and firesignal then
                            local state = getupvalue(clickFn, 1)

                            -- Step 1: Start round if idle or finished
                            if state == "bekle" or state == "bitti" then
                                firesignal(playBtn.MouseButton1Click)
                                task.wait(0.5)
                                state = getupvalue(clickFn, 1)
                            end

                            -- Step 2: Wait for pattern display to finish and transition to 'dokun'
                            local waitTimer = os.clock()
                            while getgenv()._CUT_A_ROCK_RUNNING and State.AutoSolveMemoryGame and os.clock() - waitTimer < 8 do
                                state = getupvalue(clickFn, 1)
                                if state == "dokun" then break end
                                task.wait(0.1)
                            end

                            -- Step 3: Tap correct stones in exact order
                            if state == "dokun" then
                                local sira = getupvalue(clickFn, 2)
                                if sira and type(sira) == "table" then
                                    for _, num in ipairs(sira) do
                                        if not State.AutoSolveMemoryGame or not mm.Enabled then break end
                                        local targetBtn = nil
                                        for _, c in ipairs(izgara:GetChildren()) do
                                            if c:IsA("GuiButton") and (c:GetAttribute("Sira") == num or c.Name == "Tas" .. tostring(num)) then
                                                targetBtn = c
                                                break
                                            end
                                        end
                                        if targetBtn then
                                            firesignal(targetBtn.MouseButton1Click)
                                            task.wait(0.12)
                                        end
                                    end
                                    task.wait(0.6)
                                end
                            end
                        end
                    end
                end)
            else
                -- Headless Mode: Fast background remote exploit
                pcall(function()
                    local startRes = Remotes.MemoryOyunu:InvokeServer("Basla")
                    if startRes and type(startRes) == "table" and startRes.ok and startRes.sira then
                        task.wait(0.25)
                        local win = Remotes.MemoryOyunu:InvokeServer("Cevap", startRes.sira)
                        if win and type(win) == "table" and win.durum == "basarili" and win.odul then
                            pcall(function()
                                if RewardStatusLabel and RewardStatusLabel.SetDesc then
                                    RewardStatusLabel:SetDesc("Memory Solved! +" .. FormatNum(win.odul) .. " Power gained!")
                                end
                            end)
                        end
                        task.wait(1.0)
                    end
                end)
            end
        end

        -- Auto Claim Daily Reward
        if State.AutoClaimDailyReward then
            local today = LocalPlayer:GetAttribute("DailyRewardToday") or 1
            pcall(Remotes.DailyRewardClaim.InvokeServer, Remotes.DailyRewardClaim, today)
        end

        -- Auto Claim & Equip Auras
        if State.AutoClaimAuras or State.AutoEquipBestAura then
            local auralarFolder = ReplicatedStorage:FindFirstChild("Auralar")
            if auralarFolder then
                for _, a in ipairs(auralarFolder:GetChildren()) do
                    if State.AutoClaimAuras then
                        pcall(Remotes.AuraTopla.FireServer, Remotes.AuraTopla, a.Name)
                    end
                end
            end

            if State.AutoEquipBestAura and AuraBonuslariData and AuraBonuslariData.Carpanlar then
                local collected = LocalPlayer:GetAttribute("ToplananAuralar") or ""
                local list = string.split(collected, ",")
                local bestAura = nil
                local bestMult = 0
                for _, aName in ipairs(list) do
                    local mult = AuraBonuslariData.Carpan(aName) or 1
                    if mult > bestMult then
                        bestMult = mult
                        bestAura = aName
                    end
                end
                if bestAura and bestAura ~= "" and LocalPlayer:GetAttribute("SeciliAura") ~= bestAura then
                    pcall(Remotes.AuraSec.FireServer, Remotes.AuraSec, bestAura)
                end
            end
        end

        pcall(function()
            if RewardStatusLabel and RewardStatusLabel.SetDesc then
                local aura = LocalPlayer:GetAttribute("SeciliAura") or "None"
                local power = GetPlayerPower()
                RewardStatusLabel:SetDesc(string.format("Equipped Aura: %s | Total Power: %s", aura, FormatNum(power)))
            end
        end)

        task.wait(3.0)
    end
end))

-- =========================================================================
-- WORKER 7: ROCK VEIN ESP
-- =========================================================================
RegisterTask(task.spawn(function()
    while getgenv()._CUT_A_ROCK_RUNNING do
        if State.RockESP and HumanoidRootPart then
            local curRoom = GetCurrentRoom()
            if curRoom and curRoom:FindFirstChild("Rocks") then
                for _, rock in ipairs(curRoom.Rocks:GetChildren()) do
                    local prompt = rock:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local part = prompt and prompt.Parent or rock:FindFirstChildWhichIsA("BasePart")
                    if part and not part:FindFirstChild("CutARock_ESP") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "CutARock_ESP"
                        bb.Adornee = part
                        bb.Size = UDim2.fromOffset(120, 40)
                        bb.AlwaysOnTop = true
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)

                        local tl = Instance.new("TextLabel")
                        tl.Size = UDim2.fromScale(1, 1)
                        tl.BackgroundTransparency = 1
                        tl.Text = rock.Name:gsub("_vein", ""):upper()
                        tl.TextColor3 = Color3.fromRGB(0, 255, 200)
                        tl.TextStrokeTransparency = 0.2
                        tl.Font = Enum.Font.FredokaOne
                        tl.TextSize = 13
                        tl.Parent = bb
                        bb.Parent = part
                    end
                end
            end
        end
        task.wait(2.0)
    end
end))

-- =========================================================================
-- WORKER 8: MOVEMENT & PHYSICS LOOPS
-- =========================================================================
RegisterConnection(RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if State.CustomWalkSpeed and Humanoid then
        Humanoid.WalkSpeed = State.WalkSpeedValue
    end
    if State.CustomJumpPower and Humanoid then
        Humanoid.JumpPower = State.JumpPowerValue
    end
end))

-- Infinite Jump Listener
RegisterConnection(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- Anti-AFK Listener
RegisterConnection(LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

-- =========================================================================
-- CLEAN UNLOAD LIFECYCLE
-- =========================================================================
getgenv()._CUT_A_ROCK_UNLOAD = function()
    getgenv()._CUT_A_ROCK_RUNNING = false

    -- Cancel all active worker threads
    for _, t in ipairs(ActiveTasks) do
        pcall(task.cancel, t)
    end
    ActiveTasks = {}

    -- Disconnect all active connections
    for _, conn in ipairs(ActiveConnections) do
        pcall(conn.Disconnect, conn)
    end
    ActiveConnections = {}

    -- Remove ESP
    for _, r in ipairs(workspace:GetDescendants()) do
        local esp = r:FindFirstChild("CutARock_ESP")
        if esp then pcall(esp.Destroy, esp) end
    end

    -- Reset humanoid physics
    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end

    -- Destroy UI
    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    getgenv()._CUT_A_ROCK_WINDOW = nil
    getgenv()._CUT_A_ROCK_UNLOAD = nil
end

-- Focus initial tab
pcall(function()
    TabMining:Select()
end)

SafeNotify({
    Title = "Cut a Rock Master Script Loaded",
    Content = "Elite Automation Suite Ready. Press LeftControl to toggle.",
    Duration = 3,
    Icon = "check-circle",
})
