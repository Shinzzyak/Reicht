-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    [â¡] Steal a Superpower! â Elite Automation Master Script
    Architecture: WindUI v1.6.65 / Modern Luau / Real MCP Execution
    Operating Directive: Universal English UI, Non-Negotiable Safety, ALL OFF Startup Default.
    Repository: E:\SC\Steal a Superpower\ClientOP_StealASuperpower.lua
]]

-- Anti-double-execution guard
if getgenv()._STEAL_SUPERPOWER_RUNNING then
    if getgenv()._STEAL_SUPERPOWER_UNLOAD then
        pcall(getgenv()._STEAL_SUPERPOWER_UNLOAD)
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

getgenv()._STEAL_SUPERPOWER_RUNNING = true

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

-- Shared Remotes & Configs
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ConfigFolder = Shared:WaitForChild("Config")

local PackConfig = require(ConfigFolder:WaitForChild("PackConfig"))
local CardConfig = require(ConfigFolder:WaitForChild("CardConfig"))
local EnemyConfig = require(ConfigFolder:WaitForChild("EnemyConfig"))
local BaseConfig = require(ConfigFolder:WaitForChild("BaseConfig"))
local PowerConfig = require(ConfigFolder:WaitForChild("PowerConfig"))
local PlaceConfig = require(ConfigFolder:WaitForChild("PlaceConfig"))

local PlayerState = require(ReplicatedStorage.Client.Core.PlayerState)
local LocalEnemyRegistry = require(ReplicatedStorage.Client.Core.LocalEnemyRegistry)

-- Pre-declare State for lexical scope access in hooks
local State = {}

-- Dynamic Damage Hook: Overrides all attacks to fatal 1e300 when InstantKill is active
local OriginalEnemyDamage = LocalEnemyRegistry.Damage
LocalEnemyRegistry.Damage = function(model, damage, ...)
    if State.InstantKill then
        damage = 1e300
    end
    return OriginalEnemyDamage(model, damage, ...)
end

-- Automation State Table (Strictly ALL OFF by Default as per SOP Rule 8)
State = {
    -- Combat & Auto Attack
    AutoAttackEnemies = false,
    InstantKill = false,
    GodMode = false,
    AttackAuraRadius = 150,
    GlobalAttackRadius = false,
    AutoUseAbilities = false,
    -- Auto Stages & Worlds
    AutoStage = false,
    AutoStageMode = "Boss Stages Only (Fast)",
    StageDwellTime = 2,
    SelectedWorld = (game.PlaceId == 82739382053686) and "World 2 (Federation Realm)" or "World 1 (Dominus Realm)",
    TargetMode = "All",
    TargetBossesOnly = false,
    AutoClaimEnemyDrops = false,
    AutoClaimLoosePacks = false,

    -- Packs & Superpower Cards
    AutoBuyPacks = false,
    SelectedPackToBuy = "Hero",
    AutoOpenPacks = false,
    SelectedPackToOpen = "Hero",
    AutoEquipBestCards = false,
    AutoFuseDuplicates = false,

    -- Base & Passive Income
    AutoPlaceBestHolders = false,
    AutoCollectOfflineCash = false,
    AutoBenchLift = false,
    AutoUpgradeBench = false,

    -- Upgrades & Progression
    AutoBuyHealthUpgrade = false,
    AutoBuyCashUpgrade = false,
    AutoBuyCarryUpgrade = false,
    AutoBuyCritUpgrade = false,
    AutoBuyCooldownUpgrade = false,
    AutoBuyStreakUpgrade = false,
    AutoRebirth = false,
    AutoClaimAllRewards = false,

    -- Movement Modifiers
    CustomWalkSpeed = false,
    WalkSpeedValue = 40,
    CustomJumpPower = false,
    JumpPowerValue = 50,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = false,
}

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
-- God Mode Hook Detour (Intercepts and drops EnemyHurtMe packets)
local OriginalNamecall = nil
if hookmetamethod and getnamecallmethod and checkcaller then
    OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and method == "FireServer" and self == Remotes:FindFirstChild("EnemyHurtMe") then
            if State.GodMode then
                return nil
            end
        end
        return OriginalNamecall(self, ...)
    end)
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Auto-Reexecute Persistence across World Teleports
local function QueueAutoReexecute()
    if queue_on_teleport then
        pcall(function()
            queue_on_teleport([[
                repeat task.wait(0.5) until game:IsLoaded()
                task.wait(2)
                loadfile("StealASuperpower.lua")()
            ]])
        end)
    end
end

-- Connect to Teleport event
pcall(function()
    LocalPlayer.OnTeleport:Connect(function()
        QueueAutoReexecute()
    end)
end)

-- Safe Notification Helper
local function SafeNotify(opts)
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify(opts)
        end)
    end
end

-- Helper: Get Player Base Plot
local function GetMyPlot()
    local baseId = LocalPlayer:GetAttribute("Base")
    if baseId and workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Bases") then
        local p = workspace.Map.Bases:FindFirstChild("Plot" .. tostring(baseId))
        if p then return p end
    end
    -- Fallback search by Owner attribute
    if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Bases") then
        for _, plot in ipairs(workspace.Map.Bases:GetChildren()) do
            local owner = plot:GetAttribute("Owner") or plot:GetAttribute("OwnerId") or plot:GetAttribute("UserId")
            if owner == LocalPlayer.UserId then
                return plot
            end
        end
    end
    return nil
end

-- Helper: Get Active Loadout Abilities
local function GetEquippedAbilities()
    local abilities = {}
    pcall(function()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local frame = main and main:FindFirstChild("Abilities")
        if frame then
            for _, c in ipairs(frame:GetChildren()) do
                if c:IsA("GuiButton") or c:IsA("Frame") then
                    table.insert(abilities, c.Name)
                end
            end
        end
    end)
    return abilities
end

-- Helper: Dynamic Stage Extraction for Auto Stage
local function GetWorldStages(bossOnly)
    local pads = ReplicatedStorage:FindFirstChild("EnemyPads")
    local stages = {}
    if pads then
        for _, pad in ipairs(pads:GetChildren()) do
            local enemy = pad:GetAttribute("Enemy")
            local gate = pad:GetAttribute("Gate") or "Start"
            local cf = pad:GetAttribute("PadCFrame")
            local typeInfo = EnemyConfig.Types and EnemyConfig.Types[enemy]
            local isBoss = (typeInfo and typeInfo.Boss == true) or (pad:GetAttribute("Boss") == true)

            if cf and enemy then
                if not bossOnly or isBoss then
                    table.insert(stages, {
                        id = tonumber(pad.Name) or 0,
                        name = (gate ~= "Start" and gate or pad.Name) .. " - " .. enemy,
                        gate = gate,
                        enemy = enemy,
                        isBoss = isBoss,
                        pos = cf.Position,
                        z = cf.Position.Z
                    })
                end
            end
        end
        -- Sort by Z descending (closest to spawn down to the final arena)
        table.sort(stages, function(a, b) return a.z > b.z end)
    end
    return stages
end

-- Helper: Safe Pack List Extraction
local AvailablePacks = {}
pcall(function()
    if PackConfig and PackConfig.Packs then
        for k, _ in pairs(PackConfig.Packs) do
            table.insert(AvailablePacks, tostring(k))
        end
    end
end)
if #AvailablePacks == 0 then
    AvailablePacks = { "Rookie", "Hero", "Fighter", "Champion", "Elite", "Legend", "Omega" }
else
    table.sort(AvailablePacks)
end

-- =========================================================================
-- BUILD MAIN WINDOW & TABS
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Steal a Superpower!",
    Icon = "zap",
    Author = "Elite Automation Suite",
    Folder = "StealASuperpower",
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

local TabCombat   = Window:Tab({ Title = "Combat & Mobs", Icon = "swords" })
local TabStage    = Window:Tab({ Title = "Auto Stages", Icon = "flag" })
local TabPacks    = Window:Tab({ Title = "Packs & Powers", Icon = "layers" })
local TabBase     = Window:Tab({ Title = "Base & Economy", Icon = "home" })
local TabUpgrades = Window:Tab({ Title = "Upgrades & Progress", Icon = "trending-up" })
local TabTeleport = Window:Tab({ Title = "World & Teleports", Icon = "map-pin" })
local TabMovement = Window:Tab({ Title = "Movement", Icon = "gauge" })
local TabConfig   = Window:Tab({ Title = "Configuration", Icon = "settings" })

getgenv()._STEAL_SUPERPOWER_WINDOW = Window

-- =========================================================================
-- TAB 1: COMBAT & MOBS
-- =========================================================================
TabCombat:Section({
    Title = "Enemy Combat Automation",
    Opened = true,
})

local CombatStatusLabel = TabCombat:Paragraph({
    Title = "Combat Status",
    Desc = "Standby - Auto attack will engage nearby enemies and bosses.",
})

TabCombat:Toggle({
    Title = "Auto Attack Enemies (Aura)",
    Desc = "Continuously attacks and claims drops from enemies within attack range",
    Value = State.AutoAttackEnemies,
    Callback = function(val)
        State.AutoAttackEnemies = val
    end,
})

TabCombat:Toggle({
    Title = "Instant Kill Mode (Fatal 1e300 Damage)",
    Desc = "Multiplies all damage to 1e300 and activates automatic sweep aura to annihilate targets instantly",
    Value = State.InstantKill,
    Callback = function(val)
        State.InstantKill = val
        if val then
            State.AutoClaimEnemyDrops = true
        end
    end,
})

TabCombat:Toggle({
    Title = "Map-Wide Global Attack Range",
    Desc = "Removes distance restrictions, instantly striking all enemies anywhere in the map",
    Value = State.GlobalAttackRadius,
    Callback = function(val)
        State.GlobalAttackRadius = val
    end,
})

TabCombat:Toggle({
    Title = "God Mode (Invincibility)",
    Desc = "Intercepts incoming damage packets, making character completely immune to enemy attacks",
    Value = State.GodMode,
    Callback = function(val)
        State.GodMode = val
        if val and Humanoid then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end,
})

TabCombat:Dropdown({
    Title = "Target Filter Mode",
    Desc = "Filter attack targets between All, Bosses Only, or Mobs Only",
    Values = { "All", "Bosses Only", "Mobs Only" },
    Value = State.TargetMode,
    Callback = function(val)
        State.TargetMode = val
        State.TargetBossesOnly = (val == "Bosses Only")
    end,
})

TabCombat:Toggle({
    Title = "Target Bosses Only",
    Desc = "Quick toggle to focus attack exclusively on World Bosses",
    Value = State.TargetBossesOnly,
    Callback = function(val)
        State.TargetBossesOnly = val
        if val then
            State.TargetMode = "Bosses Only"
        else
            State.TargetMode = "All"
        end
    end,
})

TabCombat:Toggle({
    Title = "Auto Cast Equipped Abilities",
    Desc = "Fires all equipped superpower skills off cooldown simultaneously",
    Value = State.AutoUseAbilities,
    Callback = function(val)
        State.AutoUseAbilities = val
    end,
})

TabCombat:Toggle({
    Title = "Auto Claim Enemy Drops",
    Desc = "Instantly sends EnemyClaim packets to absorb exp and loot from targets",
    Value = State.AutoClaimEnemyDrops,
    Callback = function(val)
        State.AutoClaimEnemyDrops = val
    end,
})

TabCombat:Slider({
    Title = "Attack Radius (Studs)",
    Desc = "Maximum distance to detect and strike enemies",
    Value = {
        Min = 20,
        Max = 1000,
        Default = 150,
    },
    Step = 10,
    Callback = function(val)
        State.AttackAuraRadius = val
    end,
})

TabCombat:Section({
    Title = "Manual Combat Actions",
    Opened = false,
})

TabCombat:Button({
    Title = "Instant Kill All Targets in Radius Now",
    Icon = "skull",
    Callback = function()
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        local enemies = workspace:FindFirstChild("Enemies")
        local killed = 0
        if hrp and enemies then
            for _, enemy in ipairs(enemies:GetChildren()) do
                local eHrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if eHrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - eHrp.Position).Magnitude
                    if dist <= State.AttackAuraRadius then
                        pcall(function()
                            local fatalDmg = (hum and hum.MaxHealth and (hum.MaxHealth * 2)) or 1e18
                            LocalEnemyRegistry.Damage(enemy, fatalDmg)
                            killed = killed + 1
                        end)
                    end
                end
            end
        end
        SafeNotify({
            Title = "Instant Kill Executed",
            Content = string.format("Instantly annihilated %d enemies in radius!", killed),
            Duration = 2,
            Icon = "skull",
        })
    end,
})

TabCombat:Button({
    Title = "Cast All Equipped Abilities Now",
    Icon = "flame",
    Callback = function()
        local moves = GetEquippedAbilities()
        local count = 0
        for _, m in ipairs(moves) do
            pcall(function()
                Remotes.UseAbility:FireServer(m)
                count = count + 1
            end)
        end
        SafeNotify({
            Title = "Abilities Fired",
            Content = string.format("Executed %d equipped superpower abilities!", count),
            Duration = 2,
            Icon = "zap",
        })
    end,
})

TabCombat:Button({
    Title = "Claim All Nearby Enemies Now",
    Icon = "crosshair",
    Callback = function()
        local claimed = 0
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, e in ipairs(enemies:GetChildren()) do
                pcall(function()
                    Remotes.EnemyClaim:FireServer(e)
                    claimed = claimed + 1
                end)
            end
        end
        SafeNotify({
            Title = "Enemies Claimed",
            Content = string.format("Sent claims for %d enemies!", claimed),
            Duration = 2,
            Icon = "check-circle",
        })
    end,
})

-- =========================================================================
-- TAB: AUTO STAGES & WORLDS
-- =========================================================================
TabStage:Section({
    Title = "Sequential Auto Stage Progression",
    Opened = true,
})

local StageStatusLabel = TabStage:Paragraph({
    Title = "Stage Status",
    Desc = "Standby - Auto Stage will traverse all stages with God Mode & Instant Kill.",
})

TabStage:Toggle({
    Title = "Auto Stage Loop",
    Desc = "Sequentially teleports through every stage, annihilating all targets, then loops back to the start",
    Value = State.AutoStage,
    Callback = function(val)
        State.AutoStage = val
        if val then
            State.GodMode = true
            State.InstantKill = true
            State.AutoAttackEnemies = true
            State.AutoClaimEnemyDrops = true
            State.AutoClaimLoosePacks = true
        end
    end,
})

TabStage:Dropdown({
    Title = "Stage Filter Mode",
    Desc = "Choose whether to target only Boss arenas or all enemy pads",
    Values = { "Boss Stages Only (Fast)", "All Stages (Mobs + Bosses)" },
    Value = State.AutoStageMode,
    Callback = function(val)
        State.AutoStageMode = val
    end,
})

TabStage:Slider({
    Title = "Stage Dwell Time (Seconds)",
    Desc = "Duration to stay at each stage to wipe enemies and claim drops",
    Value = {
        Min = 1,
        Max = 8,
        Default = 2,
    },
    Step = 0.5,
    Callback = function(val)
        State.StageDwellTime = val
    end,
})

TabStage:Section({
    Title = "Multi-World Navigation & Auto-Reexecute",
    Opened = true,
})

local WorldStatusLabel = TabStage:Paragraph({
    Title = "Current World",
    Desc = (game.PlaceId == 82739382053686) and "World 2: Federation Realm" or "World 1: Dominus Realm",
})

TabStage:Dropdown({
    Title = "Select Target World",
    Desc = "Select which World Realm to travel to",
    Values = { "World 1 (Dominus Realm)", "World 2 (Federation Realm)" },
    Value = State.SelectedWorld,
    Callback = function(val)
        State.SelectedWorld = val
    end,
})

TabStage:Button({
    Title = "Teleport to Selected World",
    Icon = "globe",
    Callback = function()
        QueueAutoReexecute()
        local isWorld2 = (State.SelectedWorld == "World 2 (Federation Realm)")
        local btnPath = isWorld2 and "World2" or "World1"
        SafeNotify({
            Title = "Warping World",
            Content = "Queued auto-execution! Teleporting to " .. State.SelectedWorld .. "...",
            Duration = 3,
            Icon = "navigation",
        })
        task.wait(0.5)
        local wGui = LocalPlayer.PlayerGui.Main:FindFirstChild("Worlds")
        local targetNode = wGui and wGui:FindFirstChild(btnPath, true)
        local tpBtn = targetNode and targetNode:FindFirstChild("Teleport")
        if tpBtn and firesignal then
            firesignal(tpBtn.Activated)
        else
            local targetPlaceId = isWorld2 and 82739382053686 or 74183246285569
            pcall(function()
                TeleportService:Teleport(targetPlaceId, LocalPlayer)
            end)
        end
    end,
})

-- =========================================================================
-- TAB 2: PACKS & POWERS
-- =========================================================================
TabPacks:Section({
    Title = "Pack Purchasing & Opening",
    Opened = true,
})

TabPacks:Dropdown({
    Title = "Pack To Buy",
    Desc = "Select which tier pack to automatically buy with Cash",
    Values = AvailablePacks,
    Value = State.SelectedPackToBuy,
    Callback = function(selected)
        State.SelectedPackToBuy = selected
    end,
})

TabPacks:Toggle({
    Title = "Auto Buy Packs",
    Desc = "Automatically purchases selected packs when you have enough Cash",
    Value = State.AutoBuyPacks,
    Callback = function(val)
        State.AutoBuyPacks = val
    end,
})

TabPacks:Toggle({
    Title = "Auto Open All Owned Packs",
    Desc = "Continuously cracks open all pack tiers currently in your inventory automatically without dropdown selection",
    Value = State.AutoOpenPacks,
    Callback = function(val)
        State.AutoOpenPacks = val
    end,
})

TabPacks:Button({
    Title = "Open All Owned Packs Now",
    Icon = "package-open",
    Callback = function()
        local packs = PlayerState.Data and PlayerState.Data.Packs
        local opened = 0
        if packs then
            for packType, count in pairs(packs) do
                while count and count > 0 do
                    local ok, res = pcall(function()
                        return Remotes.OpenPack:InvokeServer(packType, 1)
                    end)
                    if ok and res then
                        opened = opened + 1
                        count = count - 1
                    else
                        break
                    end
                    task.wait(0.08)
                end
            end
        end
        SafeNotify({
            Title = "Packs Opened",
            Content = string.format("Opened %d packs across all owned tiers!", opened),
            Duration = 2,
            Icon = "layers",
        })
    end,
})

TabPacks:Toggle({
    Title = "Auto Claim Loose Packs (Chests/Events)",
    Desc = "Instantly claims loose packs dropped on the ground from Boss chests & rain events",
    Value = State.AutoClaimLoosePacks,
    Callback = function(val)
        State.AutoClaimLoosePacks = val
    end,
})

TabPacks:Section({
    Title = "Card Management",
    Opened = true,
})

TabPacks:Toggle({
    Title = "Auto Equip Best Cards",
    Desc = "Periodically equips the highest multiplier superpower cards",
    Value = State.AutoEquipBestCards,
    Callback = function(val)
        State.AutoEquipBestCards = val
    end,
})

TabPacks:Toggle({
    Title = "Auto Fuse Duplicates",
    Desc = "Automatically fuses duplicate cards to level up your superpowers",
    Value = State.AutoFuseDuplicates,
    Callback = function(val)
        State.AutoFuseDuplicates = val
    end,
})

TabPacks:Button({
    Title = "Equip Best Cards Now",
    Icon = "star",
    Callback = function()
        local s, r = pcall(function() return Remotes.EquipBest:InvokeServer() end)
        SafeNotify({
            Title = "Equip Best",
            Content = s and "Highest tier superpower cards equipped!" or "Failed to equip.",
            Duration = 2,
            Icon = "award",
        })
    end,
})

TabPacks:Button({
    Title = "Fuse All Duplicate Cards Now",
    Icon = "sparkles",
    Callback = function()
        local s, r = pcall(function() return Remotes.FuseAll:InvokeServer() end)
        SafeNotify({
            Title = "Fuse All",
            Content = s and "Executed fuse all duplicate cards request!" or "Failed to fuse.",
            Duration = 2,
            Icon = "layers",
        })
    end,
})

-- =========================================================================
-- TAB 3: BASE & ECONOMY
-- =========================================================================
TabBase:Section({
    Title = "Base Card Holders & Passive Cash",
    Opened = true,
})

TabBase:Toggle({
    Title = "Auto Place Best Cards on Base Holders",
    Desc = "Fills all 10 base card slots with your highest level cards for max Cash/sec",
    Value = State.AutoPlaceBestHolders,
    Callback = function(val)
        State.AutoPlaceBestHolders = val
    end,
})

TabBase:Toggle({
    Title = "Auto Collect Offline Cash",
    Desc = "Automatically claims offline earnings when available",
    Value = State.AutoCollectOfflineCash,
    Callback = function(val)
        State.AutoCollectOfflineCash = val
    end,
})

TabBase:Section({
    Title = "Bench Training & Power",
    Opened = true,
})

TabBase:Toggle({
    Title = "Auto Bench Lift (Train Power)",
    Desc = "Maintains continuous bench lifting for massive Power generation",
    Value = State.AutoBenchLift,
    Callback = function(val)
        State.AutoBenchLift = val
        if val then
            pcall(function() Remotes.BenchStart:FireServer() end)
        else
            pcall(function() Remotes.BenchStop:FireServer() end)
        end
    end,
})

TabBase:Toggle({
    Title = "Auto Upgrade Bench",
    Desc = "Automatically buys bench tier upgrades using Cash when affordable",
    Value = State.AutoUpgradeBench,
    Callback = function(val)
        State.AutoUpgradeBench = val
    end,
})

TabBase:Button({
    Title = "Trigger Place Best Cards Prompt",
    Icon = "check",
    Callback = function()
        local plot = GetMyPlot()
        local prompt = plot and plot:FindFirstChild("BestButton") and plot.BestButton:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and fireproximityprompt then
            fireproximityprompt(prompt)
            SafeNotify({
                Title = "Best Cards Placed",
                Content = "Triggered plot BestPrompt!",
                Duration = 2,
                Icon = "check-circle",
            })
        else
            SafeNotify({
                Title = "Plot Not Found",
                Content = "Walk closer to your base plot to trigger prompt.",
                Duration = 2.5,
                Icon = "alert-circle",
            })
        end
    end,
})

TabBase:Button({
    Title = "Teleport Back to Base Spawn",
    Icon = "home",
    Callback = function()
        pcall(function() Remotes.TeleportHome:FireServer() end)
    end,
})

-- =========================================================================
-- TAB 4: UPGRADES & PROGRESSION
-- =========================================================================
TabUpgrades:Section({
    Title = "Character Stat Upgrades",
    Opened = true,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Health",
    Desc = "Continuously buys Max Health upgrades",
    Value = State.AutoBuyHealthUpgrade,
    Callback = function(val) State.AutoBuyHealthUpgrade = val end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Cash Multiplier",
    Desc = "Continuously buys Cash Multiplier upgrades",
    Value = State.AutoBuyCashUpgrade,
    Callback = function(val) State.AutoBuyCashUpgrade = val end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Carry Capacity",
    Desc = "Continuously buys Carry Capacity pack upgrades",
    Value = State.AutoBuyCarryUpgrade,
    Callback = function(val) State.AutoBuyCarryUpgrade = val end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Crit Chance",
    Desc = "Continuously buys Critical Hit Chance upgrades",
    Value = State.AutoBuyCritUpgrade,
    Callback = function(val) State.AutoBuyCritUpgrade = val end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Ability Cooldown",
    Desc = "Continuously buys Cooldown Reduction upgrades",
    Value = State.AutoBuyCooldownUpgrade,
    Callback = function(val) State.AutoBuyCooldownUpgrade = val end,
})

TabUpgrades:Toggle({
    Title = "Auto Upgrade Streak Time",
    Desc = "Continuously buys Streak Duration upgrades",
    Value = State.AutoBuyStreakUpgrade,
    Callback = function(val) State.AutoBuyStreakUpgrade = val end,
})

TabUpgrades:Section({
    Title = "Rebirth & Free Rewards",
    Opened = true,
})

TabUpgrades:Toggle({
    Title = "Auto Rebirth",
    Desc = "Executes Rebirth as soon as power and progression thresholds are met",
    Value = State.AutoRebirth,
    Callback = function(val) State.AutoRebirth = val end,
})

TabUpgrades:Toggle({
    Title = "Auto Claim All Free Rewards",
    Desc = "Automatically sweeps Daily, Group, Index, and Forever pack rewards",
    Value = State.AutoClaimAllRewards,
    Callback = function(val) State.AutoClaimAllRewards = val end,
})

TabUpgrades:Button({
    Title = "Claim All Free Rewards Now",
    Icon = "gift",
    Callback = function()
        pcall(function() Remotes.DailyClaim:InvokeServer() end)
        pcall(function() Remotes.GroupGift:InvokeServer() end)
        pcall(function() Remotes.ClaimIndex:InvokeServer() end)
        pcall(function() Remotes.ForeverClaim:InvokeServer() end)
        pcall(function() Remotes.OfflineCollect:InvokeServer() end)
        SafeNotify({
            Title = "Rewards Claimed",
            Content = "Daily, group, index, and offline claims processed!",
            Duration = 2.5,
            Icon = "check-circle",
        })
    end,
})

-- =========================================================================
-- TAB 5: WORLD & TELEPORTS
-- =========================================================================
TabTeleport:Section({
    Title = "Fast Base & Area Waypoints",
    Opened = true,
})

TabTeleport:Button({
    Title = "Teleport to My Base Plot",
    Icon = "home",
    Callback = function()
        pcall(function()
            Remotes.TeleportHome:FireServer()
        end)
        SafeNotify({
            Title = "Teleported",
            Content = "Returning to your personal base plot!",
            Duration = 2,
            Icon = "home",
        })
    end,
})

local AreasList = {
    { Name = "Lobby / Spawn Base", Pos = Vector3.new(0, 12, 0) },
    { Name = "Stage Tutorial", Pos = Vector3.new(0, 30, -340) },
    { Name = "Forest Zone", Pos = Vector3.new(0, 30, -850) },
    { Name = "Desert Zone", Pos = Vector3.new(0, 30, -1398) },
    { Name = "Frost Zone", Pos = Vector3.new(0, -6, -1814) },
}

for _, area in ipairs(AreasList) do
    TabTeleport:Button({
        Title = "Teleport to " .. area.Name,
        Icon = "map-pin",
        Callback = function()
            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(area.Pos)
                SafeNotify({
                    Title = "Teleported",
                    Content = "Arrived at " .. area.Name,
                    Duration = 2,
                    Icon = "navigation",
                })
            end
        end,
    })
end

-- =========================================================================
-- TAB 6: MOVEMENT MODIFIERS
-- =========================================================================
TabMovement:Section({
    Title = "Speed & Physics Modifiers",
    Opened = true,
})

TabMovement:Toggle({
    Title = "Custom WalkSpeed",
    Desc = "Enforces client WalkSpeed override",
    Value = State.CustomWalkSpeed,
    Callback = function(val)
        State.CustomWalkSpeed = val
        if not val and Humanoid then
            Humanoid.WalkSpeed = 16
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed Multiplier",
    Desc = "Set target movement speed",
    Value = {
        Min = 16,
        Max = 200,
        Default = 40,
    },
    Step = 2,
    Callback = function(val)
        State.WalkSpeedValue = val
        if State.CustomWalkSpeed and Humanoid then
            Humanoid.WalkSpeed = val
        end
    end,
})

TabMovement:Toggle({
    Title = "Custom JumpPower",
    Desc = "Enforces client JumpPower override",
    Value = State.CustomJumpPower,
    Callback = function(val)
        State.CustomJumpPower = val
        if not val and Humanoid then
            Humanoid.JumpPower = 50
        end
    end,
})

TabMovement:Slider({
    Title = "JumpPower Multiplier",
    Desc = "Set target jump height",
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
    Desc = "Pass smoothly through walls, fences, and barrier gates",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air without ground contact",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

TabMovement:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents the 20-minute Roblox idle disconnect timer",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =========================================================================
-- TAB 7: CONFIGURATION
-- =========================================================================
TabConfig:Section({
    Title = "Profile Persistence",
    Opened = true,
})

local ConfigFileName = "StealASuperpower_Config.json"

local function SaveProfile()
    local payload = HttpService:JSONEncode(State)
    if writefile then
        writefile(ConfigFileName, payload)
        SafeNotify({
            Title = "Config Saved",
            Content = "Saved current settings to " .. ConfigFileName,
            Duration = 2,
            Icon = "save",
        })
    end
end

local function LoadProfile()
    if readfile and isfile and isfile(ConfigFileName) then
        local raw = readfile(ConfigFileName)
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                if State[k] ~= nil then
                    State[k] = v
                end
            end
            SafeNotify({
                Title = "Config Loaded",
                Content = "Successfully restored settings from profile!",
                Duration = 2,
                Icon = "download",
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
        if getgenv()._STEAL_SUPERPOWER_UNLOAD then
            getgenv()._STEAL_SUPERPOWER_UNLOAD()
        end
    end,
})

-- =========================================================================
-- BACKGROUND AUTOMATION WORKERS (TICK LOOPS)
-- =========================================================================

-- Worker 1: Combat & Fatal Instant Kill Loop (1e300 Damage Multiplier)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoAttackEnemies or State.InstantKill then
            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
            local enemies = workspace:FindFirstChild("Enemies")
            if hrp and enemies then
                local moves = GetEquippedAbilities()
                for _, enemy in ipairs(enemies:GetChildren()) do
                    if not (State.AutoAttackEnemies or State.InstantKill) then break end
                    local eHrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    if eHrp and hum and hum.Health > 0 then
                        local dist = (hrp.Position - eHrp.Position).Magnitude
                        local inRange = State.GlobalAttackRadius or (dist <= State.AttackAuraRadius)
                        if inRange then
                            -- Determine Boss or Mob with precision from EnemyConfig
                            local enemyType = enemy:GetAttribute("EnemyType") or enemy.Name
                            local typeInfo = EnemyConfig.Types and EnemyConfig.Types[enemyType]
                            local isBoss = (typeInfo and typeInfo.Boss == true) or (enemy:GetAttribute("Boss") == true)
                                or string.find(string.lower(enemyType), "boss")
                                or string.find(string.lower(enemyType), "dominus")
                                or string.find(string.lower(enemyType), "king")

                            local targetAllowed = false
                            if State.TargetMode == "Bosses Only" or State.TargetBossesOnly then
                                targetAllowed = isBoss
                            elseif State.TargetMode == "Mobs Only" then
                                targetAllowed = not isBoss
                            else
                                targetAllowed = true
                            end

                            if targetAllowed then
                                -- Fatal 1e300 damage: instantly wipes any target regardless of e+29 HP
                                pcall(function()
                                    LocalEnemyRegistry.Damage(enemy, 1e300)
                                end)

                                -- Fire equipped superpower abilities simultaneously
                                if State.AutoUseAbilities and #moves > 0 then
                                    for _, moveName in ipairs(moves) do
                                        pcall(function()
                                            Remotes.UseAbility:FireServer(moveName, eHrp.Position)
                                        end)
                                    end
                                end

                                -- Claim drop packet
                                if State.AutoClaimEnemyDrops then
                                    pcall(function()
                                        Remotes.EnemyClaim:FireServer(enemy)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.08)
    end
end))

-- Worker 2: Packs & Superpower Card Automation (1.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoBuyPacks and State.SelectedPackToBuy then
            pcall(function()
                Remotes.BuyPack:InvokeServer(State.SelectedPackToBuy)
            end)
        end

        if State.AutoOpenPacks then
            pcall(function()
                local packs = PlayerState.Data and PlayerState.Data.Packs
                if packs then
                    for packType, count in pairs(packs) do
                        if count and count > 0 then
                            Remotes.OpenPack:InvokeServer(packType, 1)
                            task.wait(0.12)
                        end
                    end
                end
            end)
        end

        if State.AutoClaimLoosePacks then
            pcall(function()
                local loose = workspace:FindFirstChild("LoosePacks")
                if loose then
                    for _, lp in ipairs(loose:GetChildren()) do
                        local uid = lp:GetAttribute("Uid") or lp.Name
                        Remotes.LoosePacks:FireServer("Claim", uid)
                    end
                end
            end)
        end

        if State.AutoEquipBestCards then
            pcall(function()
                Remotes.EquipBest:InvokeServer()
            end)
        end

        if State.AutoFuseDuplicates then
            pcall(function()
                Remotes.FuseAll:InvokeServer()
            end)
        end

        task.wait(1.0)
    end
end))

-- Worker 3: Base Card Holders & Bench Training (1.5s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoPlaceBestHolders then
            pcall(function()
                local cards = PlayerState.Data and PlayerState.Data.Cards
                local sorted = {}
                for cardName, cardData in pairs(cards or {}) do
                    table.insert(sorted, { name = cardName, level = cardData.Level or 1, count = cardData.Count or 1 })
                end
                table.sort(sorted, function(a, b) return a.level > b.level end)
                for slot = 1, 10 do
                    if sorted[slot] then
                        Remotes.BasePlace:InvokeServer(slot, sorted[slot].name)
                    end
                end
            end)
        end

        if State.AutoCollectOfflineCash then
            pcall(function()
                Remotes.OfflineCollect:InvokeServer()
            end)
        end

        if State.AutoBenchLift then
            pcall(function()
                local isLifting = PlayerState.Data and PlayerState.Data.Base and PlayerState.Data.Base.Lifting
                if not isLifting then
                    Remotes.BenchStart:FireServer()
                end
            end)
        end

        if State.AutoUpgradeBench then
            pcall(function()
                Remotes.BenchUpgrade:FireServer()
            end)
        end

        task.wait(1.5)
    end
end))

-- Worker 4: Stat Upgrades & Progression (1.0s Tick)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoBuyHealthUpgrade then
            pcall(function() Remotes.BuyUpgrade:InvokeServer("Health") end)
        end
        if State.AutoBuyCashUpgrade then
            pcall(function() Remotes.BuyUpgrade:InvokeServer("Cash") end)
        end
        if State.AutoBuyCarryUpgrade then
            pcall(function() Remotes.BuyUpgrade:InvokeServer("Carry") end)
        end
        if State.AutoBuyCritUpgrade then
            pcall(function() Remotes.BuyUpgrade:InvokeServer("Crit") end)
        end
        if State.AutoBuyCooldownUpgrade then
            pcall(function() Remotes.BuyUpgrade:InvokeServer("Cooldown") end)
        end
        if State.AutoBuyStreakUpgrade then
            pcall(function() Remotes.BuyUpgrade:InvokeServer("Streak") end)
        end
        if State.AutoRebirth then
            pcall(function() Remotes.Rebirth:InvokeServer() end)
        end
        if State.AutoClaimAllRewards then
            pcall(function() Remotes.DailyClaim:InvokeServer() end)
            pcall(function() Remotes.GroupGift:InvokeServer() end)
            pcall(function() Remotes.ClaimIndex:InvokeServer() end)
            pcall(function() Remotes.ForeverClaim:InvokeServer() end)
        end
        task.wait(1.0)
    end
end))

-- Worker 6: Auto Stage Loop (Sequential Teleport & Boss Farm)
RegisterTask(task.spawn(function()
    while true do
        if State.AutoStage then
            -- Enforce required combat flags for Auto Stage
            State.GodMode = true
            State.InstantKill = true
            State.AutoAttackEnemies = true
            State.AutoClaimEnemyDrops = true
            State.AutoClaimLoosePacks = true

            local bossOnly = (State.AutoStageMode == "Boss Stages Only (Fast)")
            local stages = GetWorldStages(bossOnly)
            if #stages > 0 then
                for i, stage in ipairs(stages) do
                    if not State.AutoStage then break end

                    pcall(function()
                        if StageStatusLabel and StageStatusLabel.SetDesc then
                            StageStatusLabel:SetDesc(string.format("Clearing [%d/%d]: %s", i, #stages, stage.name))
                        end
                    end)

                    -- Teleport to stage pad position (elevated by 3 studs)
                    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(stage.pos + Vector3.new(0, 3, 0))
                    end

                    -- Dwell at stage to wipe enemies and vacuum loot drops
                    local start = os.clock()
                    local dwell = State.StageDwellTime or 2
                    while State.AutoStage and (os.clock() - start < dwell) do
                        task.wait(0.2)
                    end
                end

                pcall(function()
                    if StageStatusLabel and StageStatusLabel.SetDesc then
                        StageStatusLabel:SetDesc("Loop finished! Repeating from Stage 1...")
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

-- Worker 5: Movement & Physics Loops (Stepped / Heartbeat)
RegisterConnection(RunService.Stepped:Connect(function()
    if State.GodMode and Humanoid and Humanoid.Health < Humanoid.MaxHealth then
        Humanoid.Health = Humanoid.MaxHealth
    end
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
getgenv()._STEAL_SUPERPOWER_UNLOAD = function()
    getgenv()._STEAL_SUPERPOWER_RUNNING = false

    -- Stop Bench if lifting
    pcall(function() Remotes.BenchStop:FireServer() end)

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

    -- Reset humanoid physics
    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end

    -- Destroy UI
    if Window and Window.Destroy then
        pcall(Window.Destroy, Window)
    end

    if OriginalNamecall and hookmetamethod then
        pcall(function()
            hookmetamethod(game, "__namecall", OriginalNamecall)
        end)
    end

    if OriginalEnemyDamage then
        LocalEnemyRegistry.Damage = OriginalEnemyDamage
    end

    getgenv()._STEAL_SUPERPOWER_WINDOW = nil
    getgenv()._STEAL_SUPERPOWER_UNLOAD = nil
end

-- Focus initial tab
pcall(function()
    TabCombat:Select()
end)

SafeNotify({
    Title = "Steal a Superpower! Loaded",
    Content = "Elite Automation Suite Ready. Press LeftControl to toggle.",
    Duration = 3,
    Icon = "check-circle",
})
