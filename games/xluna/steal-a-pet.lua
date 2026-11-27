-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [ð] Steal A Pet And Ride It! â Elite ClientOP Automation Master Script
    Architecture: WindUI v1.6.65 / Modern Luau / Real MCP Execution
    Operating Directive: ZERO TELEPORTATION (Strict Compliance). Full-Featured Ground-Truth Automation.
    Responsiveness: Zero-Delay Instant Execution on Toggle + Event-Driven Background Automation.
]]

-- Anti-double-execution guard
if getgenv()._STEAL_PET_RUNNING then
    if getgenv()._STEAL_PET_UNLOAD then
        pcall(getgenv()._STEAL_PET_UNLOAD)
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

getgenv()._STEAL_PET_RUNNING = true

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Shared Configs & Remotes
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = Shared:WaitForChild("Remotes")
local ConfigFolder = Shared:WaitForChild("Config")
local CageConfig = require(ConfigFolder:WaitForChild("CageConfig"))
local TreadmillConfig = require(ConfigFolder:WaitForChild("TreadmillConfig"))
local RebirthConfig = require(ConfigFolder:WaitForChild("RebirthConfig"))
local TrailConfig = require(ConfigFolder:WaitForChild("TrailConfig"))
local TalismanConfig = require(ConfigFolder:WaitForChild("TalismanConfig"))
local HalloweenConfig = require(ConfigFolder:WaitForChild("HalloweenConfig"))
local PetConfig = require(ConfigFolder:WaitForChild("PetConfig"))
local NumberFormat = require(Shared:WaitForChild("NumberFormat"))

-- Global Automation State Table (Default: ALL OFF as per SOP Rule 8)
local State = {
    -- Treadmill & Speed
    AutoStayOnTreadmill = false,
    AutoTapBoost = false,
    AutoUpgradeTreadmill = false,
    AutoRebirth = false,

    -- Cages & Steal (Zero Teleport)
    InstantStealPrompt = false,
    AutoStealAura = false,
    StealAuraRadius = 50,
    StealTargetFilter = "All Cages",
    AutoPlaceCages = false,
    AutoOpenCages = false,
    AutoEquipBest = false,
    AutoFusePets = false,

    -- Plot & Barn
    AutoUpgradePlot = false,
    AutoUpgradeBarn = false,
    AutoCollectCash = false,
    AutoSellPets = false,

    -- Shops & Items
    AutoBuyTrails = false,
    AutoBuyTalismans = false,
    AutoBuyCandyPotions = false,
    AutoBuySpookyCages = false,
    AutoDrinkPotions = false,

    -- Combat & Skills
    AutoUseAbility = false,
    AutoThrowLasso = false,
    AutoPlantBanana = false,

    -- Rewards & Progression
    AutoClaimFreeGift = false,
    AutoClaimDaily = false,
    AutoClaimTimeRewards = false,
    AutoClaimIndex = false,
    AutoClaimVip = false,
    AutoClaimMastery = false,

    -- Movement & Modifiers (NO TELEPORT)
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = true,
}

-- Cleanup Registry
local Connections = {}
local RunningTasks = {}

local function RegisterConnection(conn)
    table.insert(Connections, conn)
    return conn
end

local function RegisterTask(thread)
    table.insert(RunningTasks, thread)
    return thread
end

-- Helper: Get Player's Owned Plot
local function GetOwnPlot()
    local plotId = LocalPlayer:GetAttribute("PlotId")
    if plotId then
        local p = workspace.Hub.Plots:FindFirstChild("Plot" .. tostring(plotId))
        if p then return p end
    end
    for _, p in ipairs(workspace.Hub.Plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return p
        end
    end
    return nil
end

-- Load WindUI Library
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[ClientOP] Failed to fetch WindUI library.")
    getgenv()._STEAL_PET_RUNNING = false
    return
end

if WindUI.SetParent then
    pcall(WindUI.SetParent, WindUI, gethui and gethui() or game:GetService("CoreGui"))
end

local function SafeNotify(config)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify(config)
        end
    end)
end

-- =========================================================================
-- INSTANT ACTION ROUTINES (DEDICATED ZERO-DELAY LOGIC)
-- =========================================================================

-- 1. Treadmill Upgrade Action
local function Action_UpgradeTreadmill(isManual)
    local plot = GetOwnPlot()
    if not plot then return end
    local currentLevel = plot:GetAttribute("TreadmillLevel") or 1
    local bestWorld = LocalPlayer:GetAttribute("BestWorld")
    local dailyBiome = LocalPlayer:GetAttribute("DailyBiome")
    local cost = TreadmillConfig.GetNextCost(currentLevel, bestWorld, dailyBiome)
    local currentCash = LocalPlayer:GetAttribute("Cash") or 0

    if not cost then
        if isManual then
            SafeNotify({
                Title = "Treadmill Upgrade",
                Content = string.format("Treadmill is already at MAX Level (Level %d)!", currentLevel),
                Duration = 2.5,
                Icon = "shield-check",
            })
        end
        return
    end

    if currentCash >= cost then
        Remotes.UpgradeTreadmill:FireServer()
        task.wait(0.3)
        local newLevel = plot:GetAttribute("TreadmillLevel") or currentLevel
        SafeNotify({
            Title = "Treadmill Upgraded!",
            Content = string.format("Level %d -> Level %d unlocked!", currentLevel, newLevel),
            Duration = 3,
            Icon = "zap",
        })
    else
        if isManual then
            SafeNotify({
                Title = "Insufficient Cash",
                Content = string.format("Level %d costs $%s (You have $%s)", currentLevel + 1, NumberFormat.Abbreviate(cost), NumberFormat.Abbreviate(currentCash)),
                Duration = 3,
                Icon = "alert-circle",
            })
        end
    end
end

-- 2. Rebirth Action
local function Action_Rebirth(isManual)
    local currentRebirths = LocalPlayer:GetAttribute("Rebirths") or 0
    local currentCash = LocalPlayer:GetAttribute("Cash") or 0
    local bestWorld = tonumber(LocalPlayer:GetAttribute("BestWorld")) or 1
    local cost = RebirthConfig.GetCost(currentRebirths + 1, bestWorld)
    local carryingCage = LocalPlayer:GetAttribute("CarryingCage")

    if carryingCage then
        if isManual then
            SafeNotify({
                Title = "Cannot Rebirth",
                Content = "Deposit your carried cage into your barn first!",
                Duration = 2.5,
                Icon = "alert-triangle",
            })
        end
        return
    end

    if cost and currentCash >= cost then
        Remotes.Rebirth:FireServer()
        task.wait(0.5)
        local newRebirths = LocalPlayer:GetAttribute("Rebirths") or currentRebirths
        SafeNotify({
            Title = "Rebirth Successful!",
            Content = string.format("Achieved Rebirth %d! Multiplier increased.", newRebirths),
            Duration = 3.5,
            Icon = "sparkles",
        })
    else
        if isManual then
            SafeNotify({
                Title = "Rebirth Requirements",
                Content = string.format("Rebirth %d requires $%s (Current: $%s)", currentRebirths + 1, NumberFormat.Abbreviate(cost or 0), NumberFormat.Abbreviate(currentCash)),
                Duration = 3,
                Icon = "info",
            })
        end
    end
end

-- 3. CashPad Collection Action (Zero Teleport Walk)
local isCollectingCash = false
local function Action_CollectPlotCash(isManual)
    if isCollectingCash then return end
    local plot = GetOwnPlot()
    if not plot or not plot:FindFirstChild("CashPad") then return end
    local btn = plot.CashPad:FindFirstChild("Button")
    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    local waiting = plot:GetAttribute("CashWaiting") or 0

    if not btn or not hum or not hrp then return end

    local dist = (hrp.Position - btn.Position).Magnitude
    if dist > 140 then
        if isManual then
            SafeNotify({
                Title = "Too Far From Plot",
                Content = string.format("You are %.0f studs away from your plot. Head near base to collect cash.", dist),
                Duration = 3,
                Icon = "map-pin",
            })
        end
        return
    end

    if waiting <= 0 and not isManual then return end

    isCollectingCash = true
    local onTM = LocalPlayer:GetAttribute("OnTreadmill") == true

    if onTM then
        Remotes.LeaveTreadmill:FireServer()
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.2)
    end

    local beforeCash = LocalPlayer:GetAttribute("Cash") or 0
    hum.WalkSpeed = math.max(hum.WalkSpeed, 60)
    hum:MoveTo(btn.Position)

    local t0 = os.clock()
    while os.clock() - t0 < 2.5 do
        if (hrp.Position - btn.Position).Magnitude < 6 then
            break
        end
        task.wait(0.08)
    end
    task.wait(0.3)

    local afterCash = LocalPlayer:GetAttribute("Cash") or beforeCash
    local gained = afterCash - beforeCash

    if onTM and plot:FindFirstChild("Treadmill") and plot.Treadmill:FindFirstChild("Belt") then
        local belt = plot.Treadmill.Belt
        hum:MoveTo(belt.Position)
        local t1 = os.clock()
        while os.clock() - t1 < 2.5 do
            if (hrp.Position - belt.Position).Magnitude < 5 then
                break
            end
            task.wait(0.08)
        end
    end

    isCollectingCash = false

    if gained > 0 or isManual then
        SafeNotify({
            Title = "Cash Collected!",
            Content = string.format("Collected +$%s Cash from Plot Pad!", NumberFormat.Abbreviate(gained)),
            Duration = 2.5,
            Icon = "dollar-sign",
        })
    end
end

-- 4. Plot Stalls Upgrade Action
local function Action_UpgradePlot(isManual)
    local plot = GetOwnPlot()
    local currentLevel = plot and plot:GetAttribute("Level") or 1
    if currentLevel >= 10 then
        if isManual then
            SafeNotify({
                Title = "Plot Stalls",
                Content = "Plot is already at MAX Level (Level 10 - 24/48 Stalls)!",
                Duration = 2.5,
                Icon = "shield-check",
            })
        end
        return
    end

    Remotes.UpgradePlot:FireServer()
    task.wait(0.3)
    local newLevel = plot and plot:GetAttribute("Level") or currentLevel
    if newLevel > currentLevel then
        SafeNotify({
            Title = "Plot Upgraded!",
            Content = string.format("Upgraded plot stalls: Level %d -> Level %d!", currentLevel, newLevel),
            Duration = 2.5,
            Icon = "home",
        })
    else
        if isManual then
            SafeNotify({
                Title = "Upgrade Sent",
                Content = "Requested plot stall upgrade.",
                Duration = 2,
                Icon = "info",
            })
        end
    end
end

-- 5. Barn Upgrade Action
local function Action_UpgradeBarn(isManual)
    Remotes.UpgradeBarn2:FireServer()
    if isManual then
        SafeNotify({
            Title = "Barn Upgrade",
            Content = "Requested barn tier & skin upgrade.",
            Duration = 2,
            Icon = "hammer",
        })
    end
end

-- 6. Open Ready Cages Action
local function Action_OpenReadyCages(isManual)
    local now = workspace:GetServerTimeNow()
    local readyList = {}
    local nextTimer = math.huge

    if LocalPlayer:FindFirstChild("Cages") then
        for _, c in ipairs(LocalPlayer.Cages:GetChildren()) do
            local readyAt = c:GetAttribute("ReadyAt") or 0
            local stall = c:GetAttribute("Stall")
            if stall then
                if readyAt <= now then
                    table.insert(readyList, c.Name)
                else
                    local left = readyAt - now
                    if left < nextTimer then nextTimer = left end
                end
            end
        end
    end

    if #readyList > 0 then
        for _, name in ipairs(readyList) do
            Remotes.OpenCage:FireServer(name)
            task.wait(0.2)
        end
        task.wait(0.3)
        Remotes.EquipBest:FireServer()
        SafeNotify({
            Title = "Cages Opened!",
            Content = string.format("Hatched %d ready cages & equipped best pets!", #readyList),
            Duration = 3,
            Icon = "unlock",
        })
    else
        if isManual then
            local msg = nextTimer < math.huge and string.format("No cages ready yet. Next cage ready in %ds.", math.ceil(nextTimer)) or "No cages currently hatching in stalls."
            SafeNotify({
                Title = "Cages Status",
                Content = msg,
                Duration = 2.5,
                Icon = "clock",
            })
        end
    end
end

-- 7. Deposit Cages Action
local function Action_DepositCages(isManual)
    local tool = (Character and Character:FindFirstChildOfClass("Tool")) or (LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
    local unplacedCageId = tool and tool:GetAttribute("CageKind") and tool.Name

    if not unplacedCageId and LocalPlayer:FindFirstChild("Cages") then
        for _, c in ipairs(LocalPlayer.Cages:GetChildren()) do
            if not c:GetAttribute("Stall") then
                unplacedCageId = c.Name
                break
            end
        end
    end

    if not unplacedCageId then
        if isManual then
            SafeNotify({
                Title = "No Cages",
                Content = "No carried or unplaced cages to deposit.",
                Duration = 2,
                Icon = "info",
            })
        end
        return
    end

    local occupied = {}
    local totalStalls = LocalPlayer:GetAttribute("PetStalls") or 48

    if LocalPlayer:FindFirstChild("Cages") then
        for _, c in ipairs(LocalPlayer.Cages:GetChildren()) do
            local st = c:GetAttribute("Stall")
            if st then occupied[st] = "Cage" end
        end
    end
    if LocalPlayer:FindFirstChild("Pets") then
        for _, p in ipairs(LocalPlayer.Pets:GetChildren()) do
            local st = p:GetAttribute("Stall")
            if st then occupied[st] = "Pet" end
        end
    end

    -- First search for an unoccupied stall
    local targetStall = nil
    for s = 1, totalStalls do
        if not occupied[s] then
            targetStall = s
            break
        end
    end

    -- If all stalls full, store lowest tier pet
    if not targetStall then
        for s = 1, totalStalls do
            if occupied[s] == "Pet" then
                Remotes.StorePet:FireServer(s)
                task.wait(0.3)
                targetStall = s
                break
            end
        end
    end

    if targetStall then
        Remotes.PlaceCage:FireServer(unplacedCageId, targetStall)
        SafeNotify({
            Title = "Cage Deposited!",
            Content = string.format("Deposited cage into Barn Stall %d.", targetStall),
            Duration = 2.5,
            Icon = "check-circle",
        })
    else
        if isManual then
            SafeNotify({
                Title = "Barn Full",
                Content = string.format("All %d stalls are occupied by cages!", totalStalls),
                Duration = 2.5,
                Icon = "alert-circle",
            })
        end
    end
end

-- 8. Equip Best Pets Action
local function Action_EquipBestPets(isManual)
    Remotes.EquipBest:FireServer()
    if isManual then
        SafeNotify({
            Title = "Pets Equipped!",
            Content = "Equipped highest multiplier riding & income pets.",
            Duration = 2.5,
            Icon = "star",
        })
    end
end

-- 9. Fuse Pets Action
local function Action_FusePets(isManual)
    Remotes.FusePets:FireServer()
    if isManual then
        SafeNotify({
            Title = "Fuse Pets",
            Content = "Executed pet fusion request.",
            Duration = 2,
            Icon = "sparkles",
        })
    end
end

-- 10. Claim All Rewards Action
local function Action_ClaimAllRewards(isManual)
    pcall(function() Remotes.ClaimFreeGift:FireServer(true) end)
    pcall(function() Remotes.ClaimDaily:FireServer() end)
    pcall(function() Remotes.ClaimAllIndexRewards:FireServer() end)
    pcall(function() Remotes.VipDaily:FireServer() end)
    pcall(function() Remotes.ClaimMastery:FireServer("All") end)

    for i = 1, 12 do
        pcall(function() Remotes.ClaimTimeReward:FireServer(i) end)
    end

    local timeGui = LocalPlayer:FindFirstChild("PlayerGui")
        and LocalPlayer.PlayerGui:FindFirstChild("Hud")
        and LocalPlayer.PlayerGui.Hud:FindFirstChild("TimeRewards")
    if timeGui then
        for _, c in ipairs(timeGui:GetDescendants()) do
            if c.Name == "Claim" and c:IsA("GuiButton") then
                local lbl = c:FindFirstChildWhichIsA("TextLabel")
                if lbl and lbl.Text == "CLAIM" and firesignal then
                    pcall(firesignal, c.Activated)
                end
            end
        end
    end

    if isManual then
        SafeNotify({
            Title = "Rewards Claimed!",
            Content = "Swept all playtime, daily, index, and mastery rewards.",
            Duration = 2.5,
            Icon = "gift",
        })
    end
end

-- =========================================================================
-- BUILD MAIN WINDOW & TABS
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Steal A Pet And Ride It!",
    Icon = "cat",
    Author = "Elite Automation Suite",
    Folder = "StealAPetAndRideIt",
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
            Color3.fromHex("FF9900"),
            Color3.fromHex("FF0055")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
    ToggleKey = Enum.KeyCode.LeftControl,
})

local TabSpeed = Window:Tab({ Title = "Speed & Treadmill", Icon = "zap" })
local TabSteal = Window:Tab({ Title = "Cages & Steal", Icon = "lock" })
local TabPlot = Window:Tab({ Title = "Plot & Barn", Icon = "home" })
local TabShops = Window:Tab({ Title = "Shops & Items", Icon = "shopping-cart" })
local TabCombat = Window:Tab({ Title = "Combat & Skills", Icon = "swords" })
local TabRewards = Window:Tab({ Title = "Rewards & Quests", Icon = "gift" })
local TabMovement = Window:Tab({ Title = "Movement Modifiers", Icon = "gauge" })
local TabConfig = Window:Tab({ Title = "Configuration", Icon = "settings" })

getgenv()._STEAL_PET_WINDOW = Window
getgenv()._STEAL_PET_STATE = State
getgenv()._STEAL_PET_TABS = {
    Speed = TabSpeed,
    Steal = TabSteal,
    Plot = TabPlot,
    Shops = TabShops,
    Combat = TabCombat,
    Rewards = TabRewards,
    Movement = TabMovement,
    Config = TabConfig,
}

-- =========================================================================
-- TAB 1: SPEED & TREADMILL
-- =========================================================================
TabSpeed:Section({
    Title = "Speed Training & Rebirth",
    Opened = true,
})

local SpeedStatusLabel = TabSpeed:Paragraph({
    Title = "Live Stats Monitor",
    Desc = "Speed: 0 | Rebirths: 0 | Cash: $0 | Gems: 0 | Candy: 0",
})

TabSpeed:Toggle({
    Title = "Auto Stay on Treadmill (Continuous Running)",
    Desc = "Keeps character running on your plot treadmill belt naturally (Zero Teleport)",
    Value = State.AutoStayOnTreadmill,
    Callback = function(val)
        State.AutoStayOnTreadmill = val
        if val then
            local plot = GetOwnPlot()
            local belt = plot and plot:FindFirstChild("Treadmill") and plot.Treadmill:FindFirstChild("Belt")
            if belt and Character and Character:FindFirstChildOfClass("Humanoid") then
                Character:FindFirstChildOfClass("Humanoid"):MoveTo(belt.Position)
                SafeNotify({
                    Title = "Treadmill Training",
                    Content = "Walking to plot treadmill belt...",
                    Duration = 2,
                    Icon = "zap",
                })
            end
        end
    end,
})

TabSpeed:Toggle({
    Title = "Auto Tap Boost (Instant Responder)",
    Desc = "Intercepts server step boost offers and confirms them instantly for 10x+ step multiplier",
    Value = State.AutoTapBoost,
    Callback = function(val)
        State.AutoTapBoost = val
        if val then
            SafeNotify({
                Title = "Tap Boost Active",
                Content = "Auto-confirming all step multiplier offers.",
                Duration = 2,
                Icon = "zap",
            })
        end
    end,
})

TabSpeed:Toggle({
    Title = "Auto Upgrade Treadmill",
    Desc = "Automatically purchases higher treadmill tiers to maximize step multipliers",
    Value = State.AutoUpgradeTreadmill,
    Callback = function(val)
        State.AutoUpgradeTreadmill = val
        if val then
            task.spawn(Action_UpgradeTreadmill, true)
        end
    end,
})

TabSpeed:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths as soon as Cash & requirements are met",
    Value = State.AutoRebirth,
    Callback = function(val)
        State.AutoRebirth = val
        if val then
            task.spawn(Action_Rebirth, true)
        end
    end,
})

TabSpeed:Section({
    Title = "Manual Actions",
    Opened = false,
})

TabSpeed:Button({
    Title = "Upgrade Treadmill Now",
    Callback = function()
        Action_UpgradeTreadmill(true)
    end,
})

TabSpeed:Button({
    Title = "Rebirth Now",
    Callback = function()
        Action_Rebirth(true)
    end,
})

TabSpeed:Button({
    Title = "Step Onto Treadmill (Walks to Belt)",
    Callback = function()
        local plot = GetOwnPlot()
        local belt = plot and plot:FindFirstChild("Treadmill") and plot.Treadmill:FindFirstChild("Belt")
        if belt and Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid"):MoveTo(belt.Position)
            SafeNotify({
                Title = "Treadmill",
                Content = "Walking to plot treadmill belt...",
                Duration = 2,
                Icon = "zap",
            })
        end
    end,
})

TabSpeed:Button({
    Title = "Jump Off Treadmill",
    Callback = function()
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            SafeNotify({
                Title = "Treadmill",
                Content = "Jumped off treadmill.",
                Duration = 1.5,
                Icon = "arrow-down",
            })
        end
    end,
})

-- =========================================================================
-- TAB 2: CAGES & STEAL (STRICTLY ZERO TELEPORT)
-- =========================================================================
TabSteal:Section({
    Title = "Pet Stealing & Cage Automation",
    Opened = true,
})

local StealStatusLabel = TabSteal:Paragraph({
    Title = "Steal Status",
    Desc = "Standby - Running along paths will auto-snatch cages.",
})

TabSteal:Toggle({
    Title = "Fast Proximity Steal (0s Hold)",
    Desc = "Bypasses the 1-second hold requirement so you can steal cages instantly on click",
    Value = State.InstantStealPrompt,
    Callback = function(val)
        State.InstantStealPrompt = val
        if val then
            for _, prompt in ipairs(CollectionService:GetTagged("StealPrompt")) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
            SafeNotify({
                Title = "Fast Steal Active",
                Content = "All cage prompts set to 0s instant hold.",
                Duration = 2,
                Icon = "unlock",
            })
        end
    end,
})

TabSteal:Toggle({
    Title = "Auto Steal Near Cages (Aura)",
    Desc = "Automatically snatches any cage you run past along paths (Zero Teleport)",
    Value = State.AutoStealAura,
    Callback = function(val)
        State.AutoStealAura = val
        if val then
            SafeNotify({
                Title = "Steal Aura Active",
                Content = string.format("Snatching cages within %d studs while running.", State.StealAuraRadius),
                Duration = 2,
                Icon = "target",
            })
        end
    end,
})

TabSteal:Slider({
    Title = "Steal Aura Radius (Studs)",
    Desc = "Detection range around your character to auto-snatch cages",
    Value = {
        Min = 15,
        Max = 120,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        State.StealAuraRadius = val
    end,
})

TabSteal:Dropdown({
    Title = "Steal Cage Priority",
    Desc = "Filter which cages the Steal Aura will target",
    Values = {
        "All Cages",
        "Secret & Above",
        "Cosmic & Above",
        "Divine & Above",
        "Mythic & Above",
        "Legendary & Above",
    },
    Value = State.StealTargetFilter,
    Callback = function(selected)
        State.StealTargetFilter = selected
    end,
})

TabSteal:Toggle({
    Title = "Auto Deposit Cages to Barn",
    Desc = "Instantly places any cage you are holding into an empty plot stall",
    Value = State.AutoPlaceCages,
    Callback = function(val)
        State.AutoPlaceCages = val
        if val then
            task.spawn(Action_DepositCages, true)
        end
    end,
})

TabSteal:Toggle({
    Title = "Auto Open / Hatch Ready Cages",
    Desc = "Automatically hatches cages on your plot once their countdown reaches 0s",
    Value = State.AutoOpenCages,
    Callback = function(val)
        State.AutoOpenCages = val
        if val then
            task.spawn(Action_OpenReadyCages, true)
        end
    end,
})

TabSteal:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Automatically equips and rides highest multiplier pets for max speed & income",
    Value = State.AutoEquipBest,
    Callback = function(val)
        State.AutoEquipBest = val
        if val then
            task.spawn(Action_EquipBestPets, true)
        end
    end,
})

TabSteal:Toggle({
    Title = "Auto Fuse Pets",
    Desc = "Automatically fuses duplicate pets into stronger tier variants",
    Value = State.AutoFusePets,
    Callback = function(val)
        State.AutoFusePets = val
        if val then
            task.spawn(Action_FusePets, true)
        end
    end,
})

TabSteal:Section({
    Title = "Manual Cage Actions",
    Opened = false,
})

TabSteal:Button({
    Title = "Deposit Carried Cage Now",
    Callback = function()
        Action_DepositCages(true)
    end,
})

TabSteal:Button({
    Title = "Open All Ready Cages Now",
    Callback = function()
        Action_OpenReadyCages(true)
    end,
})

TabSteal:Button({
    Title = "Equip Best Pets Now",
    Callback = function()
        Action_EquipBestPets(true)
    end,
})

TabSteal:Button({
    Title = "Fuse Pets Now",
    Callback = function()
        Action_FusePets(true)
    end,
})

-- =========================================================================
-- TAB 3: PLOT & BARN
-- =========================================================================
TabPlot:Section({
    Title = "Barn & Plot Automation",
    Opened = true,
})

TabPlot:Toggle({
    Title = "Auto Upgrade Plot (More Stalls)",
    Desc = "Upgrades plot capacity to hold more pets and cages (up to 48 Stalls)",
    Value = State.AutoUpgradePlot,
    Callback = function(val)
        State.AutoUpgradePlot = val
        if val then
            task.spawn(Action_UpgradePlot, true)
        end
    end,
})

TabPlot:Toggle({
    Title = "Auto Upgrade Barn",
    Desc = "Upgrades barn structure whenever cash allows",
    Value = State.AutoUpgradeBarn,
    Callback = function(val)
        State.AutoUpgradeBarn = val
        if val then
            task.spawn(Action_UpgradeBarn, true)
        end
    end,
})

TabPlot:Toggle({
    Title = "Auto Collect Plot Cash (Natural Walk)",
    Desc = "Steps off treadmill, walks to CashPad Button, absorbs waiting cash, and walks back",
    Value = State.AutoCollectCash,
    Callback = function(val)
        State.AutoCollectCash = val
        if val then
            task.spawn(Action_CollectPlotCash, true)
        end
    end,
})

TabPlot:Toggle({
    Title = "Auto Sell Extra Pets",
    Desc = "Automatically sells unequipped/unlocked pets to clear barn storage",
    Value = State.AutoSellPets,
    Callback = function(val)
        State.AutoSellPets = val
    end,
})

TabPlot:Section({
    Title = "Manual Plot Actions",
    Opened = false,
})

TabPlot:Button({
    Title = "Collect Plot Cash Now",
    Callback = function()
        Action_CollectPlotCash(true)
    end,
})

TabPlot:Button({
    Title = "Upgrade Plot Now",
    Callback = function()
        Action_UpgradePlot(true)
    end,
})

TabPlot:Button({
    Title = "Upgrade Barn Now",
    Callback = function()
        Action_UpgradeBarn(true)
    end,
})

TabPlot:Button({
    Title = "Sell Extra Duplicate Pets Now",
    Callback = function()
        if LocalPlayer:FindFirstChild("Pets") then
            local toSell = {}
            for _, p in ipairs(LocalPlayer.Pets:GetChildren()) do
                if not p:GetAttribute("Locked") and not p:GetAttribute("Stall") and p.Name ~= LocalPlayer:GetAttribute("RidingPet") then
                    table.insert(toSell, p.Name)
                end
            end
            if #toSell > 0 then
                Remotes.SellItems:FireServer(toSell, nil)
                SafeNotify({
                    Title = "Sold Pets",
                    Content = string.format("Sold %d unplaced/unlocked pets.", #toSell),
                    Duration = 2.5,
                    Icon = "dollar-sign",
                })
            else
                SafeNotify({
                    Title = "No Pets to Sell",
                    Content = "No unequipped duplicate pets available to sell.",
                    Duration = 2,
                    Icon = "alert-circle",
                })
            end
        end
    end,
})

-- =========================================================================
-- TAB 4: SHOPS & ITEMS
-- =========================================================================
TabShops:Section({
    Title = "Automated Store Purchasing",
    Opened = true,
})

TabShops:Toggle({
    Title = "Auto Buy & Equip Best Trails",
    Desc = "Scans available trails and purchases the highest affordable tier with Cash",
    Value = State.AutoBuyTrails,
    Callback = function(val)
        State.AutoBuyTrails = val
    end,
})

TabShops:Toggle({
    Title = "Auto Buy & Equip Best Talismans",
    Desc = "Purchases highest affordable stat talismans with Gems and equips them",
    Value = State.AutoBuyTalismans,
    Callback = function(val)
        State.AutoBuyTalismans = val
    end,
})

TabShops:Toggle({
    Title = "Auto Buy Halloween Potions (2x Boost)",
    Desc = "Buys 2x Money & Treadmill Potions with Candy (25,000 Candy)",
    Value = State.AutoBuyCandyPotions,
    Callback = function(val)
        State.AutoBuyCandyPotions = val
    end,
})

TabShops:Toggle({
    Title = "Auto Buy Spooky Cages",
    Desc = "Purchases your best biome's Spooky Cage with Candy (40,000 Candy)",
    Value = State.AutoBuySpookyCages,
    Callback = function(val)
        State.AutoBuySpookyCages = val
    end,
})

TabShops:Toggle({
    Title = "Auto Drink Potions",
    Desc = "Automatically consumes potions from inventory to keep 2x boosts active",
    Value = State.AutoDrinkPotions,
    Callback = function(val)
        State.AutoDrinkPotions = val
    end,
})

TabShops:Section({
    Title = "Manual Store Actions",
    Opened = false,
})

TabShops:Button({
    Title = "Drink Potion Now",
    Callback = function()
        Remotes.DrinkPotion:FireServer()
        SafeNotify({
            Title = "Potion Consumed",
            Content = "Activated 2x boost potion.",
            Duration = 2,
            Icon = "sparkles",
        })
    end,
})

TabShops:Button({
    Title = "Buy 1x Spooky Cage (40k Candy)",
    Callback = function()
        Remotes.BuyCandyItem:FireServer("SpookyCage")
        SafeNotify({
            Title = "Spooky Cage",
            Content = "Purchased 1x Spooky Cage.",
            Duration = 2,
            Icon = "shopping-bag",
        })
    end,
})

-- =========================================================================
-- TAB 5: COMBAT & SKILLS
-- =========================================================================
TabCombat:Section({
    Title = "Abilities & Track Defense",
    Opened = true,
})

TabCombat:Toggle({
    Title = "Auto Cast Equipped Ability",
    Desc = "Continuously casts your equipped ability (PumpkinToss, Dash, etc.) on cooldown",
    Value = State.AutoUseAbility,
    Callback = function(val)
        State.AutoUseAbility = val
    end,
})

TabCombat:Toggle({
    Title = "Auto Drop Banana Traps",
    Desc = "Drops banana peels along the track to slip other players/thieves",
    Value = State.AutoPlantBanana,
    Callback = function(val)
        State.AutoPlantBanana = val
    end,
})

TabCombat:Toggle({
    Title = "Auto Throw Lasso",
    Desc = "Throws lasso forward to capture nearby targets",
    Value = State.AutoThrowLasso,
    Callback = function(val)
        State.AutoThrowLasso = val
    end,
})

-- =========================================================================
-- TAB 6: REWARDS & PROGRESSION
-- =========================================================================
TabRewards:Section({
    Title = "Passive Reward Collectors",
    Opened = true,
})

TabRewards:Toggle({
    Title = "Auto Claim Free Gifts",
    Desc = "Collects recurring free gifts as soon as timer expires",
    Value = State.AutoClaimFreeGift,
    Callback = function(val)
        State.AutoClaimFreeGift = val
        if val then
            pcall(function() Remotes.ClaimFreeGift:FireServer(true) end)
        end
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Daily Reward",
    Desc = "Claims daily login reward automatically",
    Value = State.AutoClaimDaily,
    Callback = function(val)
        State.AutoClaimDaily = val
        if val then
            pcall(function() Remotes.ClaimDaily:FireServer() end)
        end
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim Time Rewards (1-12)",
    Desc = "Claims all play-time milestone rewards automatically",
    Value = State.AutoClaimTimeRewards,
    Callback = function(val)
        State.AutoClaimTimeRewards = val
        if val then
            task.spawn(Action_ClaimAllRewards, true)
        end
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim All Index Rewards",
    Desc = "Claims cash and gem rewards for newly discovered pets in index",
    Value = State.AutoClaimIndex,
    Callback = function(val)
        State.AutoClaimIndex = val
        if val then
            pcall(function() Remotes.ClaimAllIndexRewards:FireServer() end)
        end
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim VIP Daily",
    Desc = "Claims VIP daily bonus if pass is owned",
    Value = State.AutoClaimVip,
    Callback = function(val)
        State.AutoClaimVip = val
        if val then
            pcall(function() Remotes.VipDaily:FireServer() end)
        end
    end,
})

TabRewards:Toggle({
    Title = "Auto Claim All Mastery Rewards",
    Desc = "Automatically sweeps and claims all boss-kill mastery milestones",
    Value = State.AutoClaimMastery,
    Callback = function(val)
        State.AutoClaimMastery = val
        if val then
            pcall(function() Remotes.ClaimMastery:FireServer("All") end)
        end
    end,
})

TabRewards:Section({
    Title = "Manual Reward Sweeps",
    Opened = false,
})

TabRewards:Button({
    Title = "Claim All Rewards Now",
    Callback = function()
        Action_ClaimAllRewards(true)
    end,
})

-- =========================================================================
-- TAB 7: MOVEMENT MODIFIERS (STRICTLY ZERO TELEPORT)
-- =========================================================================
TabMovement:Section({
    Title = "Physics & Movement Modifiers",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Custom WalkSpeed",
    Desc = "Enhances your natural running speed across the map",
    Value = State.WalkSpeedEnabled,
    Callback = function(val)
        State.WalkSpeedEnabled = val
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val and State.WalkSpeed or 16
        end
    end,
})

TabMovement:Slider({
    Title = "Speed Multiplier",
    Value = {
        Min = 16,
        Max = 250,
        Default = 16,
    },
    Step = 2,
    Callback = function(val)
        State.WalkSpeed = val
        if State.WalkSpeedEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Custom JumpPower",
    Value = State.JumpPowerEnabled,
    Callback = function(val)
        State.JumpPowerEnabled = val
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            Character:FindFirstChildOfClass("Humanoid").JumpPower = val and State.JumpPower or 50
        end
    end,
})

TabMovement:Slider({
    Title = "JumpPower",
    Value = {
        Min = 50,
        Max = 250,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        State.JumpPower = val
        if State.JumpPowerEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            Character:FindFirstChildOfClass("Humanoid").JumpPower = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Walk through all collision barriers and cage fences smoothly",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping continuously mid-air",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents client from being disconnected after 20 minutes of inactivity",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =========================================================================
-- TAB 8: CONFIG & SYSTEM PROFILES
-- =========================================================================
TabConfig:Section({
    Title = "Profile Persistence",
    Opened = true,
})

local ConfigFileName = "StealAPetAndRideIt_Config.json"

local function SaveProfile()
    local payload = HttpService:JSONEncode(State)
    if writefile then
        writefile(ConfigFileName, payload)
        SafeNotify({
            Title = "Config Saved",
            Content = "Settings successfully saved to disk.",
            Duration = 2.5,
            Icon = "save",
        })
    end
end

local function LoadProfile()
    if isfile and readfile and isfile(ConfigFileName) then
        local content = readfile(ConfigFileName)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                State[k] = v
            end
            SafeNotify({
                Title = "Config Loaded",
                Content = "Settings successfully restored.",
                Duration = 2.5,
                Icon = "folder-check",
            })
        end
    end
end

TabConfig:Button({
    Title = "Save Current Config",
    Icon = "save",
    Callback = SaveProfile,
})

TabConfig:Button({
    Title = "Load Saved Config",
    Icon = "download",
    Callback = LoadProfile,
})

TabConfig:Section({
    Title = "Interface Control",
    Opened = false,
})

TabConfig:Keybind({
    Title = "Toggle UI Keybind",
    Value = Enum.KeyCode.LeftControl,
    Callback = function(key)
        Window:SetToggleKey(key)
    end,
})

TabConfig:Button({
    Title = "Unload Automation Script",
    Icon = "power",
    Callback = function()
        if getgenv()._STEAL_PET_UNLOAD then
            getgenv()._STEAL_PET_UNLOAD()
        end
    end,
})

-- Focus Default Initial Tab
pcall(function()
    TabSpeed:Select()
end)

-- =========================================================================
-- UNLOAD LIFECYCLE HANDLER
-- =========================================================================
getgenv()._STEAL_PET_UNLOAD = function()
    for _, conn in ipairs(Connections) do
        pcall(conn.Disconnect, conn)
    end
    for _, thr in ipairs(RunningTasks) do
        pcall(task.cancel, thr)
    end

    State.AutoTapBoost = false
    State.AutoUpgradeTreadmill = false
    State.AutoStealAura = false

    if Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
    end

    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    getgenv()._STEAL_PET_RUNNING = nil
    getgenv()._STEAL_PET_UNLOAD = nil
end

-- =========================================================================
-- WORKER THREADS & BACKGROUND LOOPS (RESPONSIVE, ZERO-DELAY)
-- =========================================================================

-- Movement Listeners
RegisterConnection(RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if State.WalkSpeedEnabled and Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid").WalkSpeed = State.WalkSpeed
    end
end))

RegisterConnection(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Character and Character:FindFirstChildOfClass("Humanoid") then
        Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

RegisterConnection(LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end))

-- Live Stats Monitor Loop (1.0s)
RegisterTask(task.spawn(function()
    while true do
        local spd = LocalPlayer:GetAttribute("Speed") or 0
        local reb = LocalPlayer:GetAttribute("Rebirths") or 0
        local csh = LocalPlayer:GetAttribute("Cash") or 0
        local gems = LocalPlayer:GetAttribute("Gems") or 0
        local cnd = LocalPlayer:GetAttribute("Candy") or 0
        SpeedStatusLabel:SetDesc(string.format("Speed: %s | Rebirths: %d | Cash: $%s | Gems: %d | Candy: %d", NumberFormat.Abbreviate(spd), reb, NumberFormat.Abbreviate(csh), gems, cnd))
        task.wait(1.0)
    end
end))

-- Auto Tap Boost (Real Server-Client Event Responder + Native GUI Trigger)
RegisterConnection(Remotes.TapBoost.OnClientEvent:Connect(function(event, offerId)
    if State.AutoTapBoost and event == "Offer" and typeof(offerId) == "number" then
        Remotes.TapBoost:FireServer(offerId)
    end
end))

local tapBoostGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TapBoost", 5)
if tapBoostGui then
    RegisterConnection(tapBoostGui.DescendantAdded:Connect(function(child)
        if State.AutoTapBoost and child.Name == "Offer" and child:IsA("GuiButton") then
            task.defer(function()
                if firesignal then
                    firesignal(child.Activated)
                end
            end)
        end
    end))
end

-- Auto Stay on Treadmill (Continuous Training, Zero Teleport)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoStayOnTreadmill then
            local onTM = LocalPlayer:GetAttribute("OnTreadmill") == true
            local carrying = LocalPlayer:GetAttribute("CarryingCage") ~= nil
            if not onTM and not carrying and not isCollectingCash then
                local plot = GetOwnPlot()
                local belt = plot and plot:FindFirstChild("Treadmill") and plot.Treadmill:FindFirstChild("Belt")
                if belt and Character and Character:FindFirstChildOfClass("Humanoid") then
                    local hum = Character:FindFirstChildOfClass("Humanoid")
                    local hrp = Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - belt.Position).Magnitude < 140 then
                        hum:MoveTo(belt.Position)
                    end
                end
            end
        end
        task.wait(1.2)
    end
end))

-- Auto Upgrade Treadmill Loop (Responsive 1.0s)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoUpgradeTreadmill then
            Action_UpgradeTreadmill(false)
        end
        task.wait(1.0)
    end
end))

-- Auto Rebirth Loop (Responsive 1.0s)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoRebirth then
            Action_Rebirth(false)
        end
        task.wait(1.0)
    end
end))

-- Cage Tier Rank Helper
local CageRank = {
    ["Common Cage"] = 1, ["Common"] = 1,
    ["Rare Cage"] = 2, ["Rare"] = 2,
    ["Epic Cage"] = 3, ["Epic"] = 3,
    ["Legendary Cage"] = 4, ["Legendary"] = 4,
    ["Mythic Cage"] = 5, ["Mythic"] = 5,
    ["Cosmic Cage"] = 6, ["Cosmic"] = 6,
    ["Secret Cage"] = 7, ["Secret"] = 7,
    ["Eternal Cage"] = 8, ["Eternal"] = 8,
    ["Divine Cage"] = 9, ["Divine"] = 9,
    ["Infinity Cage"] = 10, ["Infinity"] = 10,
    ["Astral Cage"] = 11, ["Astral"] = 11,
    ["Omega Cage"] = 12, ["Omega"] = 12,
    ["Halloween Cage"] = 13, ["Halloween"] = 13,
}

local function MatchesFilter(cageName)
    local filter = State.StealTargetFilter
    if filter == "All Cages" then return true end
    local r = CageRank[cageName] or 0
    if filter == "Legendary & Above" then return r >= 4 end
    if filter == "Mythic & Above" then return r >= 5 end
    if filter == "Cosmic & Above" then return r >= 6 end
    if filter == "Secret & Above" then return r >= 7 end
    if filter == "Divine & Above" then return r >= 9 end
    return true
end

-- Fast Proximity Steal & Auto Steal Aura Loop (Fast 0.1s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.InstantStealPrompt or State.AutoStealAura then
            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, prompt in ipairs(CollectionService:GetTagged("StealPrompt")) do
                    if prompt:IsA("ProximityPrompt") then
                        if State.InstantStealPrompt and prompt.HoldDuration > 0 then
                            prompt.HoldDuration = 0
                        end

                        if State.AutoStealAura and prompt.Parent and prompt.Parent:IsA("BasePart") then
                            if MatchesFilter(prompt.ObjectText) then
                                local dist = (hrp.Position - prompt.Parent.Position).Magnitude
                                if dist <= State.StealAuraRadius then
                                    if fireproximityprompt then
                                        prompt.HoldDuration = 0
                                        fireproximityprompt(prompt)
                                        StealStatusLabel:SetDesc("Snatching cage: " .. prompt.ObjectText)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end))

-- Auto Deposit Stolen Cages into Empty Barn Stalls (Fast 0.5s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoPlaceCages then
            Action_DepositCages(false)
        end
        task.wait(0.5)
    end
end))

-- Auto Open Ready Cages Loop (Fast 1.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoOpenCages then
            Action_OpenReadyCages(false)
        end
        task.wait(1.0)
    end
end))

-- Auto Equip Best Pets Loop (Fast 2.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoEquipBest then
            pcall(function()
                Remotes.EquipBest:FireServer()
            end)
        end
        task.wait(2.0)
    end
end))

-- Auto Fuse Pets Loop (Fast 3.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoFusePets then
            pcall(function()
                Remotes.FusePets:FireServer()
            end)
        end
        task.wait(3.0)
    end
end))

-- Auto Plot & Barn Upgrades Loop (Fast 1.5s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoUpgradePlot then
            Action_UpgradePlot(false)
        end
        if State.AutoUpgradeBarn then
            Action_UpgradeBarn(false)
        end
        task.wait(1.5)
    end
end))

-- Auto Collect Cash from Plot CashPad (Fast 2.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoCollectCash then
            Action_CollectPlotCash(false)
        end
        task.wait(2.0)
    end
end))

-- Auto Sell Safe Low-Tier Duplicate Pets (Protects Locked and High Tier)
local SafeSellRarities = {
    ["Common"] = true,
    ["Uncommon"] = true,
    ["Rare"] = true,
    ["Epic"] = true,
}

RegisterTask(task.spawn(function()
    while true do
        if State.AutoSellPets and LocalPlayer:FindFirstChild("Pets") then
            local toSell = {}
            for _, p in ipairs(LocalPlayer.Pets:GetChildren()) do
                if not p:GetAttribute("Locked") and not p:GetAttribute("Stall") and p.Name ~= LocalPlayer:GetAttribute("RidingPet") then
                    local kind = p:GetAttribute("Kind")
                    local data = PetConfig.Pets[kind]
                    local rarity = data and data.Rarity or "Unknown"
                    if SafeSellRarities[rarity] then
                        table.insert(toSell, p.Name)
                    end
                end
            end
            if #toSell > 0 then
                Remotes.SellItems:FireServer(toSell, nil)
            end
        end
        task.wait(3.0)
    end
end))

-- Auto Buy Trails & Talismans & Candy Items Loop (Fast 2.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoBuyTrails then
            local currentCash = LocalPlayer:GetAttribute("Cash") or 0
            if TrailConfig and TrailConfig.Trails then
                for _, t in ipairs(TrailConfig.Trails) do
                    if t.Price and t.Price > 0 and t.Price <= currentCash then
                        Remotes.BuyTrail:FireServer(t.Key)
                        Remotes.EquipTrail:FireServer(t.Key)
                    end
                end
            end
        end

        if State.AutoBuyTalismans then
            local currentGems = LocalPlayer:GetAttribute("Gems") or 0
            if TalismanConfig and TalismanConfig.Talismans then
                for k, tal in pairs(TalismanConfig.Talismans) do
                    if tal.Price and tal.Price > 0 and tal.Price <= currentGems then
                        Remotes.BuyTalisman:FireServer(k)
                        Remotes.EquipTalisman:FireServer(k, true)
                    end
                end
            end
        end

        if State.AutoBuyCandyPotions then
            local currentCandy = LocalPlayer:GetAttribute("Candy") or 0
            if currentCandy >= 25000 then
                Remotes.BuyCandyItem:FireServer("HalloweenPotion")
            end
        end

        if State.AutoBuySpookyCages then
            local currentCandy = LocalPlayer:GetAttribute("Candy") or 0
            if currentCandy >= 40000 then
                Remotes.BuyCandyItem:FireServer("SpookyCage")
            end
        end

        if State.AutoDrinkPotions then
            Remotes.DrinkPotion:FireServer()
        end

        task.wait(2.0)
    end
end))

-- Combat & Skills Loop (Fast 0.8s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoUseAbility then
            pcall(function()
                Remotes.UseAbility:FireServer()
            end)
        end

        if State.AutoPlantBanana and Character and Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Character.HumanoidRootPart
            pcall(function()
                Remotes.PlantBanana:FireServer(hrp.Position)
            end)
        end

        if State.AutoThrowLasso and Character and Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Character.HumanoidRootPart
            pcall(function()
                Remotes.ThrowLasso:FireServer(hrp.CFrame.LookVector)
            end)
        end

        task.wait(0.8)
    end
end))

-- Auto Rewards Progression Loop (Fast 2.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoClaimFreeGift then
            pcall(function() Remotes.ClaimFreeGift:FireServer(true) end)
        end

        if State.AutoClaimDaily then
            pcall(function() Remotes.ClaimDaily:FireServer() end)
        end

        if State.AutoClaimTimeRewards then
            for i = 1, 12 do
                pcall(function() Remotes.ClaimTimeReward:FireServer(i) end)
            end
            local timeGui = LocalPlayer:FindFirstChild("PlayerGui")
                and LocalPlayer.PlayerGui:FindFirstChild("Hud")
                and LocalPlayer.PlayerGui.Hud:FindFirstChild("TimeRewards")
            if timeGui then
                for _, c in ipairs(timeGui:GetDescendants()) do
                    if c.Name == "Claim" and c:IsA("GuiButton") then
                        local lbl = c:FindFirstChildWhichIsA("TextLabel")
                        if lbl and lbl.Text == "CLAIM" and firesignal then
                            pcall(firesignal, c.Activated)
                        end
                    end
                end
            end
        end

        if State.AutoClaimIndex then
            pcall(function() Remotes.ClaimAllIndexRewards:FireServer() end)
        end

        if State.AutoClaimVip then
            pcall(function() Remotes.VipDaily:FireServer() end)
        end

        if State.AutoClaimMastery then
            pcall(function() Remotes.ClaimMastery:FireServer("All") end)
        end

        task.wait(2.0)
    end
end))

SafeNotify({
    Title = "Steal A Pet And Ride It!",
    Content = "ClientOP Automation Suite Loaded (Zero-Delay Architecture Active).",
    Duration = 4,
    Icon = "zap",
})
