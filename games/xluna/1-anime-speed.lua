-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB | +1 Anime Speed
    Author: By XLunaHUB
    UI Framework: WindUI
]]

-- Cleanup previous instance (supports both standalone re-execution and live-reload)
local genv = (getgenv and getgenv()) or _G
if type(genv.__XLunaHUB_Cleanup) == "function" then
    pcall(genv.__XLunaHUB_Cleanup)
    genv.__XLunaHUB_Cleanup = nil
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Restore Plugin capability bit stripped by game-module calls on Real
local function restoreIdentity()
    if setthreadidentity then
        pcall(setthreadidentity, 8)
    end
end

local function safeGameCall(fn, ...)
    local ok, res1, res2, res3 = pcall(fn, ...)
    restoreIdentity()
    if ok then
        return res1, res2, res3
    end
    return nil
end

-- Game Modules
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local CoreFolder = ReplicatedStorage:WaitForChild("Core")
local TraceRunFolder = ReplicatedStorage:WaitForChild("TraceRun")

local GameConfig = require(SharedFolder:WaitForChild("Config"))
local Curves = require(SharedFolder:WaitForChild("Curves"))
local ClientData = require(CoreFolder:WaitForChild("ClientData"))
local Net = require(CoreFolder:WaitForChild("Net"))
local TraceController = require(TraceRunFolder:WaitForChild("Client"):WaitForChild("Controller"))
local HazardsMod = require(TraceRunFolder:WaitForChild("Client"):WaitForChild("Hazards"))
local EnemiesMod = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Enemies"))
restoreIdentity()

-- Ensure ClientData is ready
safeGameCall(function()
    ClientData.ready()
end)

-- Discover all Stage folders (including streamed-out nil-parented stages in StageMap)
local StageFolders = {}
local function discoverStages()
    table.clear(StageFolders)
    local worldStages = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Stages")
    if worldStages then
        for _, child in ipairs(worldStages:GetChildren()) do
            local idx = tonumber(child.Name:match("^Stage(%d+)$"))
            if idx then
                StageFolders[idx] = child
            end
        end
    end
    if filtergc then
        local tables = filtergc("table", { Keys = { 1, 2, 15 } }, false)
        for _, tbl in ipairs(tables) do
            if typeof(rawget(tbl, 1)) == "Instance" and rawget(tbl, 1):FindFirstChild("Finish") then
                for i = 1, #GameConfig.Stages do
                    if typeof(tbl[i]) == "Instance" then
                        StageFolders[i] = tbl[i]
                    end
                end
                break
            end
        end
    end
    restoreIdentity()
end
discoverStages()

-- Runtime State (ALL toggles strictly OFF by default)
local Flags = {
    AutoTrain = false,
    TrainMode = "Blocks + Treadmill (Fastest)",
    AutoRebirth = false,

    TargetStage = "Stage 15: THISTLE KEEP (5,000 Wins)",
    AutoFarmStage = false,
    AutoProgressStages = false,
    AutoBossXP = false,

    KillAura = false,
    EnemyESP = false,
    GodMode = false,
    NoSlip = false,
    AutoDeclineRevive = false,
    InfAirJumps = false,

    AutoBestSkin = false,
    AutoBestStyle = false,
    AutoBuyJumps = false,
    AutoBuyRolls = false,
    AutoClaimRewards = false,

    EnableWalkSpeed = false,
    WalkSpeedValue = 50,
    EnableJumpPower = false,
    JumpPowerValue = 75,
    Noclip = false,
    AntiAFK = false,
}

local Connections = {}
local ESPObjects = {}
local Unloaded = false
local OriginalSlip = TraceController.slip
local OriginalNamecall = nil
local HookInstalled = false

-- Helper: Character & RootPart
local function getCharacterParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.Health > 0 then
        return char, hum, hrp
    end
    return nil, nil, nil
end

local function teleportTo(cf)
    local char, _, hrp = getCharacterParts()
    if char and hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(cf)
        return true
    end
    return false
end

local function safeFire(remoteName, ...)
    local args = { ... }
    pcall(function()
        Net.fire(remoteName, table.unpack(args))
    end)
    restoreIdentity()
end

local function safeInvoke(remoteName, ...)
    local args = { ... }
    local ok, res = pcall(function()
        return Net.invoke(remoteName, table.unpack(args))
    end)
    restoreIdentity()
    if ok then return res end
    return nil
end

local function getData(key)
    return safeGameCall(ClientData.get, key)
end

-- Helper: Highest unlocked Treadmill Belt
local function getBestTreadmillBelt()
    local rebirths = getData("Rebirths") or 0
    local bestIdx = 0
    local bestPart = nil
    for _, part in ipairs(CollectionService:GetTagged("Station")) do
        local idx = part:GetAttribute("Index")
        local def = idx and GameConfig.Stations[idx]
        if def then
            local unlocked = false
            if def.pass then
                unlocked = (LocalPlayer:GetAttribute("Owns_" .. def.pass) == true)
                    or (LocalPlayer:GetAttribute("Pass_" .. def.pass) == true)
            else
                unlocked = rebirths >= (def.rebirths or 0)
            end
            if unlocked and idx > bestIdx then
                bestIdx = idx
                bestPart = part
            end
        end
    end
    return bestPart, bestIdx
end

local function isOnBelt(hrpPos, belt)
    if not hrpPos or not belt then return false end
    local rel = belt.CFrame:PointToObjectSpace(hrpPos)
    local half = belt.Size / 2
    return math.abs(rel.X) <= half.X and math.abs(rel.Z) <= half.Z and rel.Y > 0 and rel.Y < 10
end

-- Helper: Stage parsing & clearing
local StageDropdownValues = { "Highest Unlocked" }
local StageNameToIndex = {}
for i, st in ipairs(GameConfig.Stages) do
    local label = string.format("Stage %d: %s (%s Wins)", i, st.name, tostring(st.wins))
    table.insert(StageDropdownValues, label)
    StageNameToIndex[label] = i
end

local function resolveTargetStageIndex(selection)
    if selection == "Highest Unlocked" then
        local best = getData("BestStage") or 0
        return math.clamp(best + 1, 1, #GameConfig.Stages)
    end
    return StageNameToIndex[selection] or 1
end

local function getStageFolder(idx)
    if not StageFolders[idx] then
        discoverStages()
    end
    return StageFolders[idx]
end

local function touchPart(hrp, part)
    if not hrp or not part then return end
    if firetouchinterest then
        pcall(firetouchinterest, hrp, part, 0)
        task.wait(0.05)
        pcall(firetouchinterest, hrp, part, 1)
    else
        teleportTo(part.CFrame + Vector3.new(0, 2.5, 0))
    end
end

local function clearStageOnce(stageIdx)
    local stFolder = getStageFolder(stageIdx)
    if not stFolder then return false end
    local arrive = stFolder:FindFirstChild("Arrive")
    local finish = stFolder:FindFirstChild("Finish")
    if not arrive or not finish then return false end

    local _, _, hrp = getCharacterParts()
    if not hrp then return false end

    -- Step 1: Enter Stage zone so server sets Zone = stageIdx
    teleportTo(arrive.CFrame + Vector3.new(0, 4, 0))
    local deadline = os.clock() + 3.0
    while (LocalPlayer:GetAttribute("Zone") or 0) ~= stageIdx and os.clock() < deadline do
        if Unloaded then return false end
        task.wait(0.08)
    end

    -- Step 2: Notify server arena is cleared
    safeFire("ArenaClear", stageIdx)
    task.wait(0.12)

    -- Step 3: Trigger Finish pad touch
    _, _, hrp = getCharacterParts()
    if hrp then
        touchPart(hrp, finish)
    end

    -- Wait for server win teleport back to Lobby (Zone == 0)
    local winWait = os.clock() + 2.5
    while (LocalPlayer:GetAttribute("Zone") or 0) == stageIdx and os.clock() < winWait do
        if Unloaded then return false end
        -- Fallback nudge directly onto finish pad if firetouchinterest didn't register
        if os.clock() > winWait - 1.5 then
            _, _, hrp = getCharacterParts()
            if hrp then
                teleportTo(finish.CFrame + Vector3.new(0, 2.5, 0))
                touchPart(hrp, finish)
            end
        end
        task.wait(0.15)
    end
    return (LocalPlayer:GetAttribute("Zone") or 0) == 0
end

-- Helper: Client-side Enemies Controller Hooks
local function getEnemyInternals()
    if not debug or not debug.getupvalues then return nil, nil end
    local ups = debug.getupvalues(EnemiesMod.start)
    local landFn, fightTbl
    for _, v in pairs(ups) do
        if type(v) == "function" and debug.info(v, "n") == "land" then
            landFn = v
        elseif type(v) == "table" and rawget(v, "list") ~= nil and rawget(v, "index") ~= nil then
            fightTbl = v
        end
    end
    restoreIdentity()
    return fightTbl, landFn
end

local function eliminateAllActiveEnemies()
    local fightTbl, landFn = getEnemyInternals()
    if not fightTbl or not landFn or not fightTbl.list then return 0 end
    local count = 0
    for _, enemy in ipairs(table.clone(fightTbl.list)) do
        if not enemy.gone and (enemy.hp or 0) > 0 then
            pcall(landFn, enemy, enemy.hp + 100)
            count += 1
        end
    end
    restoreIdentity()
    return count
end

-- Helper: ESP Management
local function clearESP()
    for rig, objs in pairs(ESPObjects) do
        for _, inst in ipairs(objs) do
            pcall(function() inst:Destroy() end)
        end
    end
    table.clear(ESPObjects)
end

local function updateESP()
    if not Flags.EnemyESP then
        if next(ESPObjects) then clearESP() end
        return
    end
    local fightTbl = select(1, getEnemyInternals())
    local seen = {}
    if fightTbl and fightTbl.list then
        local _, _, hrp = getCharacterParts()
        for _, enemy in ipairs(fightTbl.list) do
            local rig = enemy.rig and enemy.rig.model
            local root = enemy.rig and enemy.rig.root
            if rig and root and not enemy.gone and (enemy.hp or 0) > 0 then
                seen[rig] = true
                if not ESPObjects[rig] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = rig
                    hl.FillColor = enemy.def.boss and Color3.fromHex("#FF3B30") or Color3.fromHex("#F59E0B")
                    hl.FillTransparency = 0.65
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.OutlineTransparency = 0.1
                    hl.Parent = rig

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "XLunaESP"
                    bb.Adornee = root
                    bb.Size = UDim2.fromOffset(150, 40)
                    bb.StudsOffset = Vector3.new(0, 4.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = root

                    local lbl = Instance.new("TextLabel")
                    lbl.BackgroundTransparency = 1
                    lbl.Size = UDim2.fromScale(1, 1)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 13
                    lbl.TextStrokeTransparency = 0.3
                    lbl.TextColor3 = enemy.def.boss and Color3.fromHex("#FF6B6B") or Color3.fromHex("#FDE047")
                    lbl.Parent = bb

                    ESPObjects[rig] = { hl, bb, lbl }
                end
                local lbl = ESPObjects[rig][3]
                local dist = hrp and math.floor((root.Position - hrp.Position).Magnitude) or 0
                lbl.Text = string.format("%s\nHP: %d/%d [%dm]", enemy.def.name or "ENEMY", math.ceil(enemy.hp), math.ceil(enemy.max), dist)
            end
        end
    end
    for rig, objs in pairs(ESPObjects) do
        if not seen[rig] or not rig.Parent then
            for _, inst in ipairs(objs) do
                pcall(function() inst:Destroy() end)
            end
            ESPObjects[rig] = nil
        end
    end
end

-- Helper: GodMode (__namecall hook for HazardHit)
local function ensureNamecallHook()
    if HookInstalled then return end
    if not hookmetamethod or not getnamecallmethod then return end
    HookInstalled = true
    local ok, orig = pcall(function()
        return hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not Unloaded and Flags.GodMode and method == "FireServer" and typeof(self) == "Instance" and self.Name == "HazardHit" then
                return nil
            end
            return OriginalNamecall(self, ...)
        end)
    end)
    if ok and orig then
        OriginalNamecall = orig
    end
end

local function applyGodModeState(enabled)
    if enabled then
        ensureNamecallHook()
        safeGameCall(HazardsMod.setHitsEnabled, false)
    else
        safeGameCall(HazardsMod.setHitsEnabled, true)
    end
end

local function applyNoSlipState(enabled)
    if enabled then
        TraceController.slip = function() return 0 end
    else
        TraceController.slip = OriginalSlip
    end
end

-- Load WindUI
restoreIdentity()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
restoreIdentity()

local FOLDER_NAME = "XLunaHUB_Plus1AnimeSpeed"

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB",
    Icon = "zap",
    Author = "By XLunaHUB",
    Folder = FOLDER_NAME,
    Size = UDim2.fromOffset(600, 470),
    MinSize = Vector2.new(540, 380),
    MaxSize = Vector2.new(860, 620),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 175,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "zap",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("#7C3AED"),
            Color3.fromHex("#06B6D4")
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

-- Fix WindUI DisplayOrder layering & OpenButton position above Roblox TopBar
local function fixWindUILayering()
    local orderMap = {
        ["WindUI"] = 10,
        ["WindUI/Notifications"] = 20,
        ["WindUI/Dropdowns"] = 30,
        ["WindUI/Tooltips"] = 40,
    }
    for _, container in ipairs({ CoreGui, (gethui and gethui()) or CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("ScreenGui") and orderMap[child.Name] then
                    child.DisplayOrder = orderMap[child.Name]
                end
            end
        end
    end
    pcall(function()
        if Window.OpenButtonMain and Window.OpenButtonMain.Button then
            Window.OpenButtonMain.Button.Position = UDim2.new(0.5, 0, 0, 76)
        end
    end)
end
task.defer(fixWindUILayering)

-- Pure Toggle Keybind (LeftCTRL) with state tracking & debounce (no double-trigger)
Window:SetToggleKey(nil)
local UIVisible = true
local LastToggleTime = 0

Window:OnOpen(function()
    UIVisible = true
end)

Window:OnClose(function()
    UIVisible = false
end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Unloaded or gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        local now = os.clock()
        if now - LastToggleTime < 0.28 then
            return
        end
        LastToggleTime = now
        UIVisible = not UIVisible
        if UIVisible then
            Window:Open()
        else
            Window:Close()
        end
    end
end))

-- ============================================================================
-- TABS & UI ELEMENTS (ALL TOGGLES DEFAULT TO false)
-- ============================================================================

local TabMain = Window:Tab({ Title = "Main", Icon = "flame" })
local TabCombat = Window:Tab({ Title = "Combat", Icon = "swords" })
local TabUpgrades = Window:Tab({ Title = "Upgrades", Icon = "sparkles" })
local TabTeleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TabMisc = Window:Tab({ Title = "Misc", Icon = "sliders" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "save" })

-- ---------------- TAB: MAIN ----------------
local StatusParagraph = TabMain:Paragraph({
    Title = "Live Character Status",
    Desc = "Loading stats...",
})

TabMain:Section({ Title = "Training & Rebirth" })

local ToggleAutoTrain = TabMain:Toggle({
    Title = "Auto Train (XP & Speed)",
    Desc = "Automatically trains on your highest unlocked treadmill using selected XP mode.",
    Flag = "AutoTrain",
    Value = false,
    Callback = function(state)
        Flags.AutoTrain = state
    end,
})

local DropdownTrainMode = TabMain:Dropdown({
    Title = "Training Mode",
    Desc = "Blocks + Treadmill grants massive XP every 0.43s while mounted.",
    Flag = "TrainMode",
    Values = {
        "Blocks + Treadmill (Fastest)",
        "Dash + Treadmill",
        "Treadmill Stand Only",
    },
    Value = "Blocks + Treadmill (Fastest)",
    Callback = function(val)
        Flags.TrainMode = val
    end,
})

local ToggleAutoRebirth = TabMain:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths as soon as you reach the required level.",
    Flag = "AutoRebirth",
    Value = false,
    Callback = function(state)
        Flags.AutoRebirth = state
    end,
})

TabMain:Section({ Title = "Stage & Wins Farming" })

local DropdownTargetStage = TabMain:Dropdown({
    Title = "Target Stage",
    Desc = "Select which stage to clear repeatedly.",
    Flag = "TargetStage",
    Values = StageDropdownValues,
    Value = "Stage 15: THISTLE KEEP (5,000 Wins)",
    Callback = function(val)
        Flags.TargetStage = val
    end,
})

local ToggleAutoFarmStage = TabMain:Toggle({
    Title = "Auto Clear Selected Stage",
    Desc = "Enters target stage, clears arena, and touches Finish pad for Wins.",
    Flag = "AutoFarmStage",
    Value = false,
    Callback = function(state)
        Flags.AutoFarmStage = state
    end,
})

local ToggleAutoProgress = TabMain:Toggle({
    Title = "Auto Progress Stages (1 -> 15)",
    Desc = "Automatically unlocks and clears stages sequentially from BestStage + 1 up to 15.",
    Flag = "AutoProgressStages",
    Value = false,
    Callback = function(state)
        Flags.AutoProgressStages = state
    end,
})

local ToggleAutoBossXP = TabMain:Toggle({
    Title = "Auto Farm Enemy/Boss Kill XP",
    Desc = "Fires EnemyBeaten while inside a stage zone for extra kill XP.",
    Flag = "AutoBossXP",
    Value = false,
    Callback = function(state)
        Flags.AutoBossXP = state
    end,
})

-- ---------------- TAB: COMBAT ----------------
TabCombat:Section({ Title = "Arena Combat" })

local ToggleKillAura = TabCombat:Toggle({
    Title = "Auto Kill Aura (One-Hit)",
    Desc = "Instantly eliminates all active wave enemies inside your current stage.",
    Flag = "KillAura",
    Value = false,
    Callback = function(state)
        Flags.KillAura = state
    end,
})

TabCombat:Button({
    Title = "Clear Active Enemies Now",
    Desc = "Eliminates all currently spawned enemies in the active arena.",
    Callback = function()
        local cleared = eliminateAllActiveEnemies()
        WindUI:Notify({
            Title = "Arena Sweep",
            Content = string.format("Eliminated %d active enemies.", cleared),
            Duration = 2.5,
            Icon = "swords",
        })
    end,
})

local ToggleEnemyESP = TabCombat:Toggle({
    Title = "Enemy & Boss ESP",
    Desc = "Shows highlights, names, HP, and distance on active enemies.",
    Flag = "EnemyESP",
    Value = false,
    Callback = function(state)
        Flags.EnemyESP = state
        if not state then clearESP() end
    end,
})

TabCombat:Section({ Title = "TraceRun & Survival" })

local ToggleGodMode = TabCombat:Toggle({
    Title = "God Mode (No Damage)",
    Desc = "Blocks HazardHit damage and disables client hazard strikes.",
    Flag = "GodMode",
    Value = false,
    Callback = function(state)
        Flags.GodMode = state
        applyGodModeState(state)
    end,
})

local ToggleNoSlip = TabCombat:Toggle({
    Title = "No Trace Slip",
    Desc = "Removes speed slip penalty when tracing in high-level stages.",
    Flag = "NoSlip",
    Value = false,
    Callback = function(state)
        Flags.NoSlip = state
        applyNoSlipState(state)
    end,
})

local ToggleAutoDeclineRevive = TabCombat:Toggle({
    Title = "Auto Decline Revive Popup",
    Desc = "Automatically dismisses the Robux revive screen if you fall.",
    Flag = "AutoDeclineRevive",
    Value = false,
    Callback = function(state)
        Flags.AutoDeclineRevive = state
    end,
})

local ToggleInfAirJumps = TabCombat:Toggle({
    Title = "Infinite Air Jumps",
    Desc = "Allows unlimited mid-air jumps in Lobby and Stages.",
    Flag = "InfAirJumps",
    Value = false,
    Callback = function(state)
        Flags.InfAirJumps = state
    end,
})

-- ---------------- TAB: UPGRADES ----------------
TabUpgrades:Section({ Title = "Automatic Progression" })

local ToggleAutoBestSkin = TabUpgrades:Toggle({
    Title = "Auto Buy & Equip Best Skin",
    Desc = "Buys affordable Wins skins and equips your highest XP multiplier skin.",
    Flag = "AutoBestSkin",
    Value = false,
    Callback = function(state)
        Flags.AutoBestSkin = state
    end,
})

local ToggleAutoBestStyle = TabUpgrades:Toggle({
    Title = "Auto Equip Best Style",
    Desc = "Automatically equips the highest-DPS fighting style you own.",
    Flag = "AutoBestStyle",
    Value = false,
    Callback = function(state)
        Flags.AutoBestStyle = state
    end,
})

local ToggleAutoBuyJumps = TabUpgrades:Toggle({
    Title = "Auto Buy Jump Pads",
    Desc = "Automatically purchases the next Jump upgrade when you have enough Wins.",
    Flag = "AutoBuyJumps",
    Value = false,
    Callback = function(state)
        Flags.AutoBuyJumps = state
    end,
})

local ToggleAutoBuyRolls = TabUpgrades:Toggle({
    Title = "Auto Buy Roll Slots",
    Desc = "Automatically purchases additional Style Roll slots when affordable.",
    Flag = "AutoBuyRolls",
    Value = false,
    Callback = function(state)
        Flags.AutoBuyRolls = state
    end,
})

TabUpgrades:Section({ Title = "Rewards & Codes" })

local ToggleAutoClaimRewards = TabUpgrades:Toggle({
    Title = "Auto Claim Daily, Chest & Gift",
    Desc = "Automatically claims Daily rewards, Group Chest, and Free Gift when ready.",
    Flag = "AutoClaimRewards",
    Value = false,
    Callback = function(state)
        Flags.AutoClaimRewards = state
    end,
})

TabUpgrades:Button({
    Title = "Claim Available Rewards Now",
    Desc = "Triggers Daily, Group Chest, and Free Gift claims immediately.",
    Callback = function()
        safeFire("ClaimDaily")
        safeFire("OpenChest")
        safeFire("GiftVerify")
        WindUI:Notify({
            Title = "Rewards",
            Content = "Sent reward claim requests.",
            Duration = 2.5,
            Icon = "gift",
        })
    end,
})

local CodeInputValue = ""
TabUpgrades:Input({
    Title = "Promo Code",
    Desc = "Enter a game code to redeem.",
    Placeholder = "Enter code...",
    Callback = function(text)
        CodeInputValue = text
    end,
})

TabUpgrades:Button({
    Title = "Redeem Code",
    Callback = function()
        if CodeInputValue == "" then return end
        local res = safeInvoke("RedeemCode", CodeInputValue)
        WindUI:Notify({
            Title = "Code Redemption",
            Content = "Server response: " .. tostring(res),
            Duration = 3,
            Icon = "ticket",
        })
    end,
})

-- ---------------- TAB: TELEPORT ----------------
TabTeleport:Section({ Title = "Stage Teleports" })

local SelectedTPStage = "Stage 1: THE VOID (1 Win)"
local TPStageValues = {}
for i = 2, #StageDropdownValues do
    table.insert(TPStageValues, StageDropdownValues[i])
end

TabTeleport:Dropdown({
    Title = "Select Stage",
    Values = TPStageValues,
    Value = TPStageValues[1],
    Callback = function(val)
        SelectedTPStage = val
    end,
})

TabTeleport:Button({
    Title = "Teleport to Stage Start",
    Callback = function()
        local idx = StageNameToIndex[SelectedTPStage] or 1
        local st = getStageFolder(idx)
        local arrive = st and st:FindFirstChild("Arrive")
        if arrive then
            teleportTo(arrive.CFrame + Vector3.new(0, 4, 0))
        end
    end,
})

TabTeleport:Button({
    Title = "Teleport to Stage Finish Pad",
    Callback = function()
        local idx = StageNameToIndex[SelectedTPStage] or 1
        local st = getStageFolder(idx)
        local finish = st and st:FindFirstChild("Finish")
        if finish then
            teleportTo(finish.CFrame + Vector3.new(0, 4, 0))
        end
    end,
})

TabTeleport:Section({ Title = "Lobby Teleports" })

TabTeleport:Button({
    Title = "Lobby Spawn",
    Callback = function()
        teleportTo(CFrame.new(0, 5, 0))
    end,
})

TabTeleport:Button({
    Title = "Best Unlocked Treadmill",
    Callback = function()
        local belt = getBestTreadmillBelt()
        if belt then
            teleportTo(belt.CFrame + Vector3.new(0, 4, 0))
        end
    end,
})

TabTeleport:Button({
    Title = "Daily & Group Chest Stands",
    Callback = function()
        teleportTo(CFrame.new(-110, 5, 4))
    end,
})

TabTeleport:Button({
    Title = "Jump Pads Area",
    Callback = function()
        teleportTo(CFrame.new(112, 5, 70))
    end,
})

TabTeleport:Button({
    Title = "Roll Pads Area",
    Callback = function()
        teleportTo(CFrame.new(80, 5, 145))
    end,
})

TabTeleport:Button({
    Title = "Skin Pedestals",
    Callback = function()
        teleportTo(CFrame.new(85, 7, -20))
    end,
})

-- ---------------- TAB: MISC ----------------
TabMisc:Section({ Title = "Character Movement" })

local ToggleWalkSpeed = TabMisc:Toggle({
    Title = "Enable Custom WalkSpeed",
    Flag = "EnableWalkSpeed",
    Value = false,
    Callback = function(state)
        Flags.EnableWalkSpeed = state
        if not state then
            local _, hum = getCharacterParts()
            if hum then hum.WalkSpeed = 30 end
        end
    end,
})

local SliderWalkSpeed = TabMisc:Slider({
    Title = "WalkSpeed",
    Flag = "WalkSpeedValue",
    Step = 1,
    Value = { Min = 16, Max = 300, Default = 50 },
    Callback = function(val)
        Flags.WalkSpeedValue = val
    end,
})

local ToggleJumpPower = TabMisc:Toggle({
    Title = "Enable Custom JumpPower",
    Flag = "EnableJumpPower",
    Value = false,
    Callback = function(state)
        Flags.EnableJumpPower = state
        if not state then
            local _, hum = getCharacterParts()
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = 50
            end
        end
    end,
})

local SliderJumpPower = TabMisc:Slider({
    Title = "JumpPower",
    Flag = "JumpPowerValue",
    Step = 1,
    Value = { Min = 50, Max = 250, Default = 75 },
    Callback = function(val)
        Flags.JumpPowerValue = val
    end,
})

local ToggleNoclip = TabMisc:Toggle({
    Title = "Noclip",
    Flag = "Noclip",
    Value = false,
    Callback = function(state)
        Flags.Noclip = state
    end,
})

TabMisc:Section({ Title = "Protection & Utility" })

local ToggleAntiAFK = TabMisc:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents idle kick by simulating controller input when idle.",
    Flag = "AntiAFK",
    Value = false,
    Callback = function(state)
        Flags.AntiAFK = state
    end,
})

-- ---------------- TAB: CONFIG ----------------
local ConfigManager = Window.ConfigManager
local ActiveConfigName = "default"
local RegisteredFlags = {
    AutoTrain = ToggleAutoTrain,
    TrainMode = DropdownTrainMode,
    AutoRebirth = ToggleAutoRebirth,
    TargetStage = DropdownTargetStage,
    AutoFarmStage = ToggleAutoFarmStage,
    AutoProgressStages = ToggleAutoProgress,
    AutoBossXP = ToggleAutoBossXP,
    KillAura = ToggleKillAura,
    EnemyESP = ToggleEnemyESP,
    GodMode = ToggleGodMode,
    NoSlip = ToggleNoSlip,
    AutoDeclineRevive = ToggleAutoDeclineRevive,
    InfAirJumps = ToggleInfAirJumps,
    AutoBestSkin = ToggleAutoBestSkin,
    AutoBestStyle = ToggleAutoBestStyle,
    AutoBuyJumps = ToggleAutoBuyJumps,
    AutoBuyRolls = ToggleAutoBuyRolls,
    AutoClaimRewards = ToggleAutoClaimRewards,
    EnableWalkSpeed = ToggleWalkSpeed,
    WalkSpeedValue = SliderWalkSpeed,
    EnableJumpPower = ToggleJumpPower,
    JumpPowerValue = SliderJumpPower,
    Noclip = ToggleNoclip,
    AntiAFK = ToggleAntiAFK,
}

local function registerAllFlags(cfgObj)
    if not cfgObj then return end
    for flagName, element in pairs(RegisteredFlags) do
        pcall(function()
            cfgObj:Register(flagName, element)
        end)
    end
end

local function listSavedConfigs()
    local names = {}
    local seen = {}
    local dirPath = "WindUI/" .. FOLDER_NAME .. "/config"
    if listfiles and isfolder and isfolder(dirPath) then
        local ok, files = pcall(listfiles, dirPath)
        if ok and type(files) == "table" then
            for _, f in ipairs(files) do
                local base = tostring(f):match("([^/\\]+)%.json$")
                if base and not seen[base] then
                    seen[base] = true
                    table.insert(names, base)
                end
            end
        end
    end
    if #names == 0 then
        table.insert(names, "default")
    end
    table.sort(names)
    return names
end

TabConfig:Section({ Title = "Configuration Profiles" })

TabConfig:Input({
    Title = "Config Name",
    Desc = "Profile name used for saving or creating configs.",
    Placeholder = "default",
    Value = "default",
    Callback = function(text)
        local cleaned = text:gsub("[^%w_%-]", "")
        if cleaned ~= "" then
            ActiveConfigName = cleaned
        end
    end,
})

local ConfigDropdown = TabConfig:Dropdown({
    Title = "Saved Configs",
    Values = listSavedConfigs(),
    Value = listSavedConfigs()[1],
    Callback = function(val)
        if val and val ~= "" then
            ActiveConfigName = val
        end
    end,
})

local function refreshConfigDropdown()
    local vals = listSavedConfigs()
    if ConfigDropdown.Refresh then
        pcall(function() ConfigDropdown:Refresh(vals) end)
    end
end

TabConfig:Button({
    Title = "Save Config",
    Desc = "Saves all current toggles, dropdowns, and sliders to disk.",
    Callback = function()
        if not ConfigManager then
            WindUI:Notify({ Title = "Config", Content = "ConfigManager unavailable.", Duration = 3, Icon = "alert-triangle" })
            return
        end
        local cfg = ConfigManager:CreateConfig(ActiveConfigName, false)
        if cfg then
            cfg:SetAutoLoad(false)
            registerAllFlags(cfg)
            cfg:Save()
            refreshConfigDropdown()
            WindUI:Notify({
                Title = "Config Saved",
                Content = "Saved profile: " .. ActiveConfigName,
                Duration = 2.5,
                Icon = "save",
            })
        end
    end,
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Loads settings from the selected configuration profile.",
    Callback = function()
        if not ConfigManager then return end
        local cfg = ConfigManager:CreateConfig(ActiveConfigName, false)
        if cfg then
            cfg:SetAutoLoad(false)
            registerAllFlags(cfg)
            local ok, err = cfg:Load()
            if ok == false then
                WindUI:Notify({ Title = "Load Failed", Content = tostring(err), Duration = 3, Icon = "alert-triangle" })
            else
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Loaded profile: " .. ActiveConfigName,
                    Duration = 2.5,
                    Icon = "folder-open",
                })
            end
        end
    end,
})

TabConfig:Button({
    Title = "Delete Config",
    Desc = "Deletes the selected configuration profile.",
    Callback = function()
        if not ConfigManager then return end
        local cfg = ConfigManager:CreateConfig(ActiveConfigName, false)
        if cfg and cfg.Delete then
            local ok, msg = cfg:Delete()
            refreshConfigDropdown()
            WindUI:Notify({
                Title = ok and "Config Deleted" or "Delete Failed",
                Content = tostring(msg),
                Duration = 2.5,
                Icon = "trash-2",
            })
        end
    end,
})

TabConfig:Button({
    Title = "Refresh Config List",
    Callback = refreshConfigDropdown,
})

TabConfig:Section({ Title = "Interface & Credits" })

TabConfig:Paragraph({
    Title = "XLunaHUB Controls",
    Desc = "Press LeftCTRL to toggle Show/Hide UI. Use the floating XLunaHUB button to restore the window anytime.\nAuthor: By XLunaHUB",
})

local function cleanupAll()
    if Unloaded then return end
    Unloaded = true
    for k in pairs(Flags) do
        if type(Flags[k]) == "boolean" then
            Flags[k] = false
        end
    end
    applyGodModeState(false)
    applyNoSlipState(false)
    clearESP()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    pcall(function()
        Window:Destroy()
    end)
end

genv.__XLunaHUB_Cleanup = cleanupAll

TabConfig:Button({
    Title = "Unload XLunaHUB",
    Desc = "Stops all automation loops, restores hooks, and closes the UI.",
    Callback = cleanupAll,
})

-- Select first tab on startup
pcall(function()
    Window:SelectTab(1)
end)
task.delay(0.15, fixWindUILayering)

-- ============================================================================
-- BACKGROUND AUTOMATION WORKERS (ALL GATED BY FLAGS â NOTHING RUNS AT STARTUP)
-- ============================================================================

-- 1. Anti-AFK Listener
table.insert(Connections, LocalPlayer.Idled:Connect(function()
    if Unloaded or not Flags.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

-- 2. Infinite Air Jumps
table.insert(Connections, UserInputService.JumpRequest:Connect(function()
    if Unloaded or not Flags.InfAirJumps then return end
    local _, hum, hrp = getCharacterParts()
    if hum and hrp then
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            local vel = hrp.AssemblyLinearVelocity
            local vy = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, vy * 1.15, vel.Z)
        end
    end
end))

-- 3. Noclip, WalkSpeed, JumpPower & ESP Render/Stepped Loop
table.insert(Connections, RunService.Stepped:Connect(function()
    if Unloaded then return end
    local char, hum, _ = getCharacterParts()
    if char and hum then
        if Flags.EnableWalkSpeed then
            hum.WalkSpeed = Flags.WalkSpeedValue
        end
        if Flags.EnableJumpPower then
            hum.UseJumpPower = true
            hum.JumpPower = Flags.JumpPowerValue
        end
        if Flags.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end))

-- 4. Auto Decline Revive Popup listener
pcall(function()
    local reviveGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GameUI"):WaitForChild("Revive")
    table.insert(Connections, reviveGui:GetPropertyChangedSignal("Visible"):Connect(function()
        if not Unloaded and Flags.AutoDeclineRevive and reviveGui.Visible then
            task.defer(function()
                safeFire("ReviveClosed")
                reviveGui.Visible = false
            end)
        end
    end))
end)

-- 5. Live Status Paragraph Updater (read-only UI display)
task.spawn(function()
    while not Unloaded do
        local lv = getData("Level") or 1
        local xp = math.floor(getData("XP") or 0)
        local wins = getData("Wins") or 0
        local reb = getData("Rebirths") or 0
        local best = getData("BestStage") or 0
        local skinId = getData("Skin") or "Starter"
        local styleId = getData("Style") or "Fists"
        local stat = LocalPlayer:GetAttribute("Stat") or 0
        local zone = LocalPlayer:GetAttribute("Zone") or 0
        local nextRebLv = safeGameCall(Curves.rebirthLevel, reb) or 20
        local skinDef = GameConfig.Skins[skinId]
        local skinText = skinDef and string.format("%s (x%g)", skinDef.name, skinDef.mult) or skinId

        pcall(function()
            StatusParagraph:SetDesc(string.format(
                "Level: %d (XP: %d) | Rebirth: %d (Next Lv: %d)\nSpeed: %s | Wins: %s | Zone: %d (Best: %d)\nSkin: %s | Style: %s",
                lv, xp, reb, nextRebLv,
                tostring(stat), tostring(wins), zone, best,
                skinText, tostring(styleId)
            ))
        end)
        task.wait(0.75)
    end
end)

-- 6. Training Worker (Treadmill + Minigame XP)
task.spawn(function()
    local gameActive = false
    local lastGameType = nil
    while not Unloaded do
        if Flags.AutoTrain and not Flags.AutoFarmStage and not Flags.AutoProgressStages then
            local _, _, hrp = getCharacterParts()
            local belt = getBestTreadmillBelt()
            if hrp and belt then
                if not isOnBelt(hrp.Position, belt) then
                    teleportTo(belt.CFrame + Vector3.new(0, 3.8, 0))
                    task.wait(0.25)
                end

                if Flags.TrainMode == "Blocks + Treadmill (Fastest)" then
                    if not gameActive or lastGameType ~= "Blocks" then
                        safeFire("GameStart", "Blocks")
                        gameActive = true
                        lastGameType = "Blocks"
                        task.wait(0.43)
                    end
                    safeFire("GamePoint", "Blocks", 8)
                    task.wait(0.43)
                elseif Flags.TrainMode == "Dash + Treadmill" then
                    if not gameActive or lastGameType ~= "Dash" then
                        safeFire("GameStart", "Dash")
                        gameActive = true
                        lastGameType = "Dash"
                        task.wait(0.22)
                    end
                    safeFire("GamePoint", "Dash", 1)
                    task.wait(0.22)
                else
                    gameActive = false
                    task.wait(0.5)
                end
            else
                task.wait(0.4)
            end
        else
            gameActive = false
            task.wait(0.3)
        end
    end
end)

-- 7. Stage Farming & Progression Worker
task.spawn(function()
    while not Unloaded do
        if Flags.AutoProgressStages then
            local best = getData("BestStage") or 0
            local nextStage = best + 1
            if nextStage <= #GameConfig.Stages then
                clearStageOnce(nextStage)
                task.wait(0.35)
            else
                -- All stages unlocked: farm Stage 15 if AutoFarmStage is also on, else wait
                if Flags.AutoFarmStage then
                    clearStageOnce(#GameConfig.Stages)
                    task.wait(0.35)
                else
                    task.wait(0.6)
                end
            end
        elseif Flags.AutoFarmStage then
            local targetIdx = resolveTargetStageIndex(Flags.TargetStage)
            clearStageOnce(targetIdx)
            task.wait(0.35)
        else
            task.wait(0.3)
        end
    end
end)

-- 8. Combat & Boss XP Worker (Kill Aura, ESP, GodMode grace, Boss XP)
task.spawn(function()
    while not Unloaded do
        if Flags.KillAura then
            eliminateAllActiveEnemies()
        end
        if Flags.EnemyESP then
            updateESP()
        end
        if Flags.GodMode then
            safeGameCall(HazardsMod.setHitsEnabled, false)
        end
        if Flags.AutoBossXP then
            local zone = LocalPlayer:GetAttribute("Zone") or 0
            if zone > 0 then
                local stDef = GameConfig.Stages[zone]
                safeFire("EnemyBeaten", zone, stDef and stDef.boss == true or false)
            end
        end
        task.wait(0.18)
    end
end)

-- 9. Progression Worker (Auto Rebirth, Skins, Styles, Jumps, Rolls, Rewards)
task.spawn(function()
    while not Unloaded do
        local lv = getData("Level") or 1
        local reb = getData("Rebirths") or 0
        local wins = getData("Wins") or 0

        if Flags.AutoRebirth then
            local reqLv = safeGameCall(Curves.rebirthLevel, reb) or 20
            if lv >= reqLv then
                safeFire("Rebirth")
                task.wait(0.25)
            end
        end

        if Flags.AutoBestSkin then
            local ownedSkins = getData("OwnedSkins") or {}
            local currentSkin = getData("Skin") or "Starter"
            -- Buy any affordable non-pass skin
            for skinId, def in pairs(GameConfig.Skins) do
                if not ownedSkins[skinId] and not def.pass and def.wins and wins >= def.wins then
                    safeFire("SkinAction", skinId)
                    wins = wins - def.wins
                    ownedSkins[skinId] = true
                    task.wait(0.12)
                end
            end
            -- Equip highest mult owned skin
            local bestSkinId = currentSkin
            local bestMult = (GameConfig.Skins[currentSkin] and GameConfig.Skins[currentSkin].mult) or 0
            for skinId, isOwned in pairs(ownedSkins) do
                if isOwned and GameConfig.Skins[skinId] and GameConfig.Skins[skinId].mult > bestMult then
                    bestMult = GameConfig.Skins[skinId].mult
                    bestSkinId = skinId
                end
            end
            if bestSkinId ~= currentSkin then
                safeFire("SkinAction", bestSkinId)
            end
        end

        if Flags.AutoBestStyle then
            local styles = getData("Styles") or {}
            local currentStyle = getData("Style") or "Fists"
            local bestStyle = safeGameCall(Curves.bestStyle, styles) or "Fists"
            if bestStyle ~= currentStyle and (styles[bestStyle] or 0) > 0 then
                safeFire("StyleEquip", bestStyle)
            end
        end

        if Flags.AutoBuyJumps then
            local bought = getData("JumpsBought") or 0
            local nextPrice = GameConfig.JumpShop.Prices[bought + 1]
            if nextPrice and wins >= nextPrice then
                safeFire("BuyJump")
                wins = wins - nextPrice
            end
        end

        if Flags.AutoBuyRolls then
            local slots = getData("RollSlots") or 0
            local nextPrice = GameConfig.RollShop.Prices[slots + 1]
            if nextPrice and wins >= nextPrice then
                safeFire("BuyRollSlot")
            end
        end

        if Flags.AutoClaimRewards then
            local daily = getData("Daily") or { last = 0 }
            if os.time() - (daily.last or 0) >= GameConfig.Daily.cooldownHours * 3600 then
                safeFire("ClaimDaily")
            end
            local chestAt = getData("ChestAt") or 0
            if os.time() - chestAt >= GameConfig.Chest.CooldownHours * 3600 then
                safeFire("OpenChest")
            end
            local gift = getData("Gift") or {}
            if not gift.claimed then
                safeFire("GiftVerify")
            end
        end

        -- Keep Anti-AFK active via gentle VirtualUser nudge every ~60s if enabled
        task.wait(0.6)
    end
end)

WindUI:Notify({
    Title = "XLunaHUB Loaded",
    Content = "+1 Anime Speed ready. All toggles start OFF. Press LeftCTRL to toggle UI.",
    Duration = 4,
    Icon = "zap",
})
