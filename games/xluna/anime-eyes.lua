-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- =======================================================
-- +1 ANIME EYES (+1 CHAKRA) - MASTER CLIENT AUTOMATION
-- Universal Multi-World Architecture | WindUI Framework
-- Verified Against Live Game Mechanics & Remotes
-- Multi-World Support (Worlds 1-5) | True God Mode | Fast Kill Burst
-- =======================================================

-- Single Instance Guard
if _G.AnimeEyesActive then
    if typeof(_G.AnimeEyesTeardown) == "function" then
        pcall(_G.AnimeEyesTeardown)
    end
    task.wait(0.3)
end
_G.AnimeEyesActive = true

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteTrain = Remotes:WaitForChild("Train")
local RemoteCast = Remotes:WaitForChild("Cast")
local RemoteUnlockEye = Remotes:WaitForChild("UnlockEye")
local RemoteEquip = Remotes:WaitForChild("Equip")
local RemotePad = Remotes:WaitForChild("Pad")
local RemoteAutoWin = Remotes:WaitForChild("AutoWin")
local RemoteRebirth = Remotes:WaitForChild("Rebirth")
local RemoteBoss = Remotes:WaitForChild("Boss")
local RemoteEquipAura = Remotes:WaitForChild("EquipAura")
local RemotePetAction = Remotes:WaitForChild("PetAction")
local RemoteClaimDaily = Remotes:WaitForChild("ClaimDaily")
local RemoteClaimReward = Remotes:WaitForChild("ClaimReward")
local RemoteExitBonus = Remotes:FindFirstChild("ExitBonus")
local RemoteClaimQuest = Remotes:WaitForChild("ClaimQuest")
local RemoteRedeemCode = Remotes:WaitForChild("RedeemCode")
local RemoteFuse = Remotes:FindFirstChild("Fuse")
local RemoteTeleport = Remotes:WaitForChild("Teleport")
local RemoteRevive = Remotes:WaitForChild("Revive")
local RemoteAutoRebirth = Remotes:FindFirstChild("AutoRebirth")

-- Shared Game Modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Logic = Shared:WaitForChild("Logic")

local EyesModule = require(Config:WaitForChild("Eyes"))
local WorldModule = require(Config:WaitForChild("World"))
local StagesModule = require(Config:WaitForChild("Stages"))
local PetsModule = require(Config:WaitForChild("Pets"))
local AurasModule = require(Config:WaitForChild("Auras"))
local EnemiesConfig = require(Config:WaitForChild("Enemies"))
local LogicHits = require(Logic:WaitForChild("Hits"))
local LogicFuse = require(Logic:WaitForChild("Fuse"))
local LogicPads = require(Logic:WaitForChild("Pads"))
local BossLogic = require(Logic:WaitForChild("Boss"))
local FormatLogic = Logic:FindFirstChild("Format") and require(Logic:FindFirstChild("Format")) or nil

-- Multi-World Training Config Modules
local TrainingModule1 = require(Config:WaitForChild("Training"))
local TrainingModule2 = Config:FindFirstChild("Training2") and require(Config:FindFirstChild("Training2")) or TrainingModule1
local TrainingModule3 = Config:FindFirstChild("Training3") and require(Config:FindFirstChild("Training3")) or TrainingModule1
local TrainingModule4 = Config:FindFirstChild("Training4") and require(Config:FindFirstChild("Training4")) or TrainingModule1
local TrainingModule5 = Config:FindFirstChild("Training5") and require(Config:FindFirstChild("Training5")) or TrainingModule1

local TrainingByWorld = {
    [1] = TrainingModule1,
    [2] = TrainingModule2,
    [3] = TrainingModule3,
    [4] = TrainingModule4,
    [5] = TrainingModule5,
}

-- Client Modules
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local ClientScripts = PlayerScripts:WaitForChild("Client")

local InputClient = nil
local EnemiesClient = nil
local StateClient = nil
local MenusClient = nil
local ReviveClient = nil

pcall(function() InputClient = require(ClientScripts:WaitForChild("Input")) end)
pcall(function() EnemiesClient = require(ClientScripts:WaitForChild("Enemies")) end)
pcall(function() StateClient = require(ClientScripts:WaitForChild("State")) end)
pcall(function() MenusClient = require(ClientScripts:WaitForChild("Menus")) end)
pcall(function() ReviveClient = require(ClientScripts:WaitForChild("Revive")) end)

-- Bulletproof 5-Layer Zero-Robux Revive Suppressor & Prompt Obliterator
local function InstallReviveSuppressor()
    local function executeInstantNo()
        pcall(function()
            RemoteRevive:FireServer("no")
        end)
        pcall(function()
            if ReviveClient and ReviveClient.hide then
                ReviveClient.hide()
            end
        end)
        pcall(function()
            local rGui = PlayerGui:FindFirstChild("Revive")
            if rGui then
                rGui.Enabled = false
                local panel = rGui:FindFirstChild("Panel")
                if panel then
                    local btnRevive = panel:FindFirstChild("Revive")
                    if btnRevive then btnRevive.Visible = false end
                    local btnRevenge = panel:FindFirstChild("Revenge")
                    if btnRevenge then btnRevenge.Visible = false end
                end
            end
        end)
        pcall(function()
            local main = PlayerGui:FindFirstChild("Main")
            if main then main.Enabled = true end
        end)
    end

    -- Layer 1: Hijack Client.Revive module functions
    pcall(function()
        if ReviveClient then
            ReviveClient.show = function(a1)
                executeInstantNo()
            end
            ReviveClient.showBoss = function(a1)
                executeInstantNo()
            end
        end
    end)
    
    -- Layer 2: Intercept RemoteRevive OnClientEvent directly
    pcall(function()
        RemoteRevive.OnClientEvent:Connect(function(action, data)
            if action == "show" or action == "time" then
                executeInstantNo()
            end
        end)
    end)
    
    -- Layer 3: ScreenGui PropertyChanged & Zero-Frame listener
    local function attachToReviveGui(reviveGui)
        if not reviveGui then return end
        reviveGui:GetPropertyChangedSignal("Enabled"):Connect(function()
            if reviveGui.Enabled then
                executeInstantNo()
            end
        end)
        -- Physically disable the Robux buttons permanently
        pcall(function()
            local panel = reviveGui:WaitForChild("Panel", 2)
            if panel then
                local bRev = panel:FindFirstChild("Revive")
                if bRev then bRev.Visible = false end
                local bRevn = panel:FindFirstChild("Revenge")
                if bRevn then bRevn.Visible = false end
            end
        end)
        if reviveGui.Enabled then
            executeInstantNo()
        end
    end
    
    local existingRevive = PlayerGui:FindFirstChild("Revive")
    if existingRevive then
        attachToReviveGui(existingRevive)
    end
    
    -- Layer 4: PlayerGui ChildAdded watcher
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "Revive" then
            attachToReviveGui(child)
        end
    end)
    
    executeInstantNo()
end
pcall(InstallReviveSuppressor)
LocalPlayer.CharacterAdded:Connect(function()
    task.delay(0.1, InstallReviveSuppressor)
end)

-- Cleanup & GC Registry
local CleanupConnections = {}

-- Utility: Safe Ground Teleportation
local function SafeTeleport(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    pcall(function()
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") then
                p.AssemblyLinearVelocity = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end
        end
        hrp.CFrame = CFrame.new(targetPos)
    end)
    return true
end

-- World Origin Locator (Bulletproof Fallback Engine)
local function GetWorldOrigin(worldId)
    local w = tonumber(worldId) or 1
    if WorldModule and type(WorldModule.origin) == "function" then
        local ok, res = pcall(WorldModule.origin, w)
        if ok and res then return res end
    end
    if WorldModule and WorldModule.ORIGINS and WorldModule.ORIGINS[w] then
        return WorldModule.ORIGINS[w]
    end
    return Vector3.new((w - 1) * 3000, 0, 0)
end

-- =======================================================
-- STATE CONFIGURATION (DEFAULT ALL OFF FOR SAFETY)
-- =======================================================
local State = {
    -- Chakra & Training
    AutoTrain = false,
    AutoTrainPosition = false,
    TrainRate = 50,
    AutoEquipBestAura = false,

    -- Combat & Stages
    GodMode = false,
    InstantKill = false,
    KillBurstRate = 2, -- Attack packets dispatched per enemy per tick
    KillAuraRange = 100,
    AutoCastSkills = false,
    AutoAttack = false,
    AutoTrainInCombat = false,
    AutoAdvanceStages = false,
    ContinuousStageFarm = false, -- Seamlessly repeats stage runs after claiming win pads
    TargetWorld = "Current World (Auto)",
    TargetStage = 8,
    PadPreference = "Gold (1x Wins - Free)", -- Default Gold: zero robux!
    StageStepDelay = 0.25,

    -- Kyubi Raid Boss
    AutoBoss = false,

    -- Eyes & Rebirth
    AutoUnlockEyes = false,
    AutoEquipBestEye = false,
    AutoRebirth = false, -- Instant 0ms Rebirth

    -- Pets, Eggs & Fusion
    AutoHatch = false,
    SelectedEgg = "Lotus Egg (World 2)",
    HatchCount = 1,
    AutoEquipBestPets = false,
    AutoFuse = false, -- Fuse 4 identical pets into higher tier
    AutoDeleteUnused = false, -- Auto delete unequipped pets (all tiers/rarities)
    KeepForFuse = true, -- Preserve sets of 4 for Auto Fuse

    -- Progression & Rewards
    AutoClaimDaily = false,
    AutoClaimGifts = false,
    AutoClaimQuests = false,
    ClaimDelay = 5.0,

    -- Movement & Physics
    WalkSpeed = 26,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,
}
_G.AnimeEyesState = State

-- Helper: Check if a World is Unlocked (Hoisted above ResolveActiveWorld & GetBestTrainingData)
local function IsWorldUnlocked(w)
    if not w or w <= 1 then return true end
    local curWorld = tonumber(LocalPlayer:GetAttribute("World")) or 1
    if w <= curWorld then return true end
    local WorldsConfig = ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("Config") and ReplicatedStorage.Shared.Config:FindFirstChild("Worlds")
    if WorldsConfig then
        local ok, mod = pcall(require, WorldsConfig)
        if ok and mod and mod[w] and mod[w].ready then
            local req = mod[w].needStage or 0
            local bestStage = 0
            if w - 1 == 1 then
                bestStage = tonumber(LocalPlayer:GetAttribute("BestStage")) or 0
            else
                bestStage = tonumber(LocalPlayer:GetAttribute("BestStage" .. tostring(w - 1))) or 0
            end
            return bestStage >= req
        end
    end
    return false
end

-- World Resolution with Unlock Safety Guard
local function ResolveActiveWorld()
    local target = 1
    if State.TargetWorld == "World 1 (Shinobi Lands)" then target = 1
    elseif State.TargetWorld == "World 2 (Celestial Realm)" then target = 2
    elseif State.TargetWorld == "World 3 (Blood Moon)" then target = 3
    elseif State.TargetWorld == "World 4 (Frozen Abyss)" then target = 4
    elseif State.TargetWorld == "World 5 (Cosmic Void)" then target = 5
    else
        target = tonumber(LocalPlayer:GetAttribute("World")) or 1
    end
    
    -- Verify target world is actually unlocked for player
    if not IsWorldUnlocked(target) then
        return tonumber(LocalPlayer:GetAttribute("World")) or 1
    end
    return target
end

-- Universal Cross-World Dynamic Training Spot Evaluator
-- Mathematically matches player's exact Rebirth count against all world training spot tiers
local function GetBestTrainingData(targetWorld)
    local rebirths = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
    local curWorld = targetWorld or tonumber(LocalPlayer:GetAttribute("World")) or 1
    
    local bestInWorld = nil
    local bestInWorldMult = -1
    
    local bestGlobal = nil
    local bestGlobalMult = -1
    
    local nextUnlock = nil
    local lowestRebirthDiff = math.huge
    
    for w = 1, 5 do
        if IsWorldUnlocked(w) then
            local tConfig = TrainingByWorld[w]
            if tConfig then
                for i, spot in ipairs(tConfig) do
                    local spotRebirths = spot.rebirths or 0
                    local spotMult = spot.mult or 1
                    local canUse = false
                    
                    if spot.pass then
                        canUse = LocalPlayer:GetAttribute("Pass_" .. spot.pass) == true
                    elseif spotRebirths <= rebirths then
                        canUse = true
                    end
                    
                    if canUse then
                        local origin = WorldModule.origin(w)
                        local offset = (WorldModule.TRAINING and WorldModule.TRAINING[i]) or Vector3.new(-62, 0, 38)
                        local worldPos = origin + offset + Vector3.new(0, 3.5, 0)
                        local entry = {
                            world = w,
                            index = i,
                            spot = spot,
                            mult = spotMult,
                            pos = worldPos,
                            name = spot.name or ("Training Spot " .. i),
                            rebirths = spotRebirths,
                            id = spot.id or (w .. "_" .. i)
                        }
                        
                        -- Global best
                        if spotMult > bestGlobalMult then
                            bestGlobalMult = spotMult
                            bestGlobal = entry
                        end
                        
                        -- Current world best
                        if w == curWorld and spotMult > bestInWorldMult then
                            bestInWorldMult = spotMult
                            bestInWorld = entry
                        end
                    else
                        if not spot.pass and spotRebirths > rebirths then
                            local diff = spotRebirths - rebirths
                            if diff < lowestRebirthDiff then
                                lowestRebirthDiff = diff
                                nextUnlock = {
                                    world = w,
                                    index = i,
                                    spot = spot,
                                    mult = spotMult,
                                    name = spot.name or ("Training Spot " .. i),
                                    rebirths = spotRebirths,
                                    needed = diff
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestInWorld, bestGlobal, nextUnlock
end

-- Helper: Parse Owned Eyes
local function GetOwnedEyes()
    local owned = {}
    local raw = LocalPlayer:GetAttribute("Eyes")
    if typeof(raw) == "string" then
        pcall(function() owned = HttpService:JSONDecode(raw) end)
    end
    return owned
end

-- Helper: Get Best Owned Eye
local function GetBestOwnedEye()
    local owned = GetOwnedEyes()
    local best = nil
    local bestMult = -1
    local eyeSource = (EyesModule.chain and #EyesModule.chain > 0) and EyesModule.chain or (EyesModule.list or {})
    for _, eye in ipairs(eyeSource) do
        if owned[eye.id] then
            local m = tonumber(eye.mult or eye.power or eye.multiplier) or 0
            if m > bestMult then
                bestMult = m
                best = eye
            end
        end
    end
    return best
end

-- Helper: Get Affordable Unowned Eyes (based on TotalWins / Trophies)
local function GetAffordableEyesToUnlock()
    local owned = GetOwnedEyes()
    local totalWins = tonumber(LocalPlayer:GetAttribute("TotalWins")) or 0
    local affordable = {}
    local eyeSource = (EyesModule.chain and #EyesModule.chain > 0) and EyesModule.chain or (EyesModule.list or {})
    for _, eye in ipairs(eyeSource) do
        if not eye.robux and not eye.pass and not eye.product and not eye.boss then
            local cost = tonumber(eye.wins) or 0
            local eyeWorld = eye.world or 1
            if not owned[eye.id] and cost <= totalWins and IsWorldUnlocked(eyeWorld) then
                table.insert(affordable, eye)
            end
        end
    end
    table.sort(affordable, function(a, b)
        return (tonumber(a.mult or a.power or 0) or 0) < (tonumber(b.mult or b.power or 0) or 0)
    end)
    return affordable
end

-- Helper: Get Next Target Eye Info
local function GetNextEyeInfo()
    local owned = GetOwnedEyes()
    local totalWins = tonumber(LocalPlayer:GetAttribute("TotalWins")) or 0
    for _, eye in ipairs(EyesModule.list or {}) do
        if not eye.robux and not eye.pass and not eye.product and not eye.boss then
            if not owned[eye.id] then
                local cost = tonumber(eye.wins) or 0
                local mult = tonumber(eye.mult or eye.power or eye.multiplier) or 0
                local eyeWorld = eye.world or 1
                local worldUnlocked = IsWorldUnlocked(eyeWorld)
                local needed = math.max(0, cost - totalWins)
                local pct = (cost > 0) and math.clamp((totalWins / cost) * 100, 0, 100) or 100
                return {
                    id = eye.id,
                    name = eye.name or eye.short or eye.id,
                    cost = cost,
                    mult = mult,
                    world = eyeWorld,
                    worldUnlocked = worldUnlocked,
                    needed = needed,
                    pct = pct
                }
            end
        end
    end
    return nil
end

-- Load WindUI Library
local WindUI = nil
local function loadWindUI()
    if not _G.WindUISource then
        local sources = {
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
            "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        }
        for _, url in ipairs(sources) do
            local ok, res = pcall(function() return game:HttpGet(url, true) end)
            if ok and typeof(res) == "string" and #res > 500 then
                _G.WindUISource = res
                break
            end
        end
    end
    if _G.WindUISource then
        local loader, err = loadstring(_G.WindUISource)
        if loader then
            local ok, lib = pcall(loader)
            if ok and lib then
                WindUI = lib
                return true
            end
        end
    end
    return false
end

if not loadWindUI() then
    warn("[+1 Anime Eyes] Failed to load WindUI.")
    return
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "+1 Anime Eyes - Master Automation",
    Icon = "eye",
    Author = "Universal Operations",
    Folder = "AnimeEyesHub",
    Size = UDim2.fromOffset(600, 480),
    Theme = "Dark",
})
_G.AnimeEyesWindow = Window

-- Persistent Floating Action Button (FAB)
local function CreateFloatingButton()
    if _G.AnimeEyesFAB then
        pcall(function() _G.AnimeEyesFAB:Destroy() end)
        _G.AnimeEyesFAB = nil
    end

    local parentGui = nil
    pcall(function()
        if gethui then parentGui = gethui()
        elseif syn and syn.protect_gui then
            parentGui = CoreGui
        else
            parentGui = CoreGui
        end
    end)
    if not parentGui then parentGui = PlayerGui end

    local fabGui = Instance.new("ScreenGui")
    fabGui.Name = "AnimeEyesFloatingButton"
    fabGui.ResetOnSpawn = false
    fabGui.ResetOnSpawn = false
    fabGui.DisplayOrder = 1000

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleFAB"
    btn.Size = UDim2.fromOffset(48, 48)
    btn.Position = UDim2.new(0, 16, 0.45, 0)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    btn.Text = "ðï¸"
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 170, 60)
    btn.AutoButtonColor = true
    btn.Active = true
    btn.Draggable = true
    btn.Parent = fabGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 170, 60)
    stroke.Thickness = 2
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(function()
            if Window.Toggle then
                Window:Toggle()
            elseif Window.SetVisible then
                Window:SetVisible(not Window.Visible)
            end
        end)
    end)

    fabGui.Parent = parentGui
    _G.AnimeEyesFAB = fabGui
end

pcall(CreateFloatingButton)

-- Keybinds: LeftControl and RightShift both toggle the Window
local keyConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightShift) then
        pcall(function()
            if Window.Toggle then
                Window:Toggle()
            elseif Window.SetVisible then
                Window:SetVisible(not Window.Visible)
            end
        end)
    end
end)
table.insert(CleanupConnections, keyConn)

-- Immunity to Respawn for WindUI ScreenGuis
pcall(function()
    for _, g in ipairs(CoreGui:GetDescendants()) do
        if g:IsA("ScreenGui") and g.Name:lower():find("wind") then
            g.ResetOnSpawn = false
        end
    end
    for _, g in ipairs(PlayerGui:GetDescendants()) do
        if g:IsA("ScreenGui") and g.Name:lower():find("wind") then
            g.ResetOnSpawn = false
        end
    end
end)

-- UI Elements Registry
local UIElements = {}

-- =======================================================
-- TAB 1: CHAKRA & TRAINING
-- =======================================================
local TabChakra = Window:Tab({ Title = "Chakra & Training", Icon = "zap" })
TabChakra:Section({ Title = "Autonomous Chakra Generation" })

UIElements["AutoTrain"] = TabChakra:Toggle({
    Title = "Auto Train Chakra (Rapid Click)",
    Desc = "High-speed rapid-fire Chakra training engine. Generates massive pulses continuously.",
    Value = State.AutoTrain,
    Callback = function(val) State.AutoTrain = val end,
})

UIElements["AutoTrainPosition"] = TabChakra:Toggle({
    Title = "Auto Stand at Best Multiplier Zone",
    Desc = "Automatically teleports & keeps character at the highest unlocked Chakra training zone for your Rebirths.",
    Value = State.AutoTrainPosition,
    Callback = function(val)
        State.AutoTrainPosition = val
        if val then
            State.AutoAdvanceStages = false
            if UIElements["AutoAdvanceStages"] and UIElements["AutoAdvanceStages"].Set then
                pcall(function() UIElements["AutoAdvanceStages"]:Set(false) end)
            end
            pcall(function()
                local best = GetBestTrainingData()
                if best and best.pos then
                    SafeTeleport(best.pos)
                    WindUI:Notify({ Title = "Stationed at Best Zone", Content = "Moved to: " .. best.name .. " (x" .. tostring(best.mult) .. " Chakra)", Duration = 2.5 })
                end
            end)
        end
    end,
})

local TrainingTelemetryParagraph = TabChakra:Paragraph({
    Title = "Best Multiplier Zone Status",
    Content = "Evaluating best training spot for your Rebirths..."
})

TabChakra:Button({
    Title = "Teleport to Best Training Zone Now",
    Desc = "Instantly teleports you to your highest unlocked training multiplier spot.",
    Callback = function()
        State.AutoAdvanceStages = false
        if UIElements["AutoAdvanceStages"] and UIElements["AutoAdvanceStages"].Set then
            pcall(function() UIElements["AutoAdvanceStages"]:Set(false) end)
        end
        local best = GetBestTrainingData()
        if best and best.pos then
            local curWorld = tonumber(LocalPlayer:GetAttribute("World")) or 1
            if curWorld ~= best.world then
                RemoteTeleport:FireServer(best.world)
                task.wait(1.0)
            end
            SafeTeleport(best.pos)
            local multStr = FormatLogic and FormatLogic.short(best.mult) or tostring(best.mult)
            WindUI:Notify({ Title = "Stationed at Best Zone", Content = "Moved to: " .. best.name .. " (x" .. multStr .. " Chakra)", Duration = 2.5 })
        end
    end,
})

TabChakra:Slider({
    Title = "Train Pulse Rate (Pulses/sec)",
    Desc = "Speed of Chakra training requests (10 - 100 pulses/sec).",
    Value = {
        Min = 10,
        Max = 100,
        Default = State.TrainRate,
    },
    Callback = function(val) State.TrainRate = math.floor(val) end,
})

TabChakra:Section({ Title = "Aura Multipliers" })

UIElements["AutoEquipBestAura"] = TabChakra:Toggle({
    Title = "Auto Equip Strongest Aura",
    Desc = "Continuously monitors trophy unlocks and equips the highest multiplier Aura.",
    Value = State.AutoEquipBestAura,
    Callback = function(val) State.AutoEquipBestAura = val end,
})

TabChakra:Button({
    Title = "Equip Best Aura Now",
    Desc = "Scans available auras by trophy thresholds and equips the strongest one.",
    Callback = function()
        pcall(function()
            local totalWins = tonumber(LocalPlayer:GetAttribute("TotalWins")) or 0
            local ownedAuras = HttpService:JSONDecode(LocalPlayer:GetAttribute("OwnedAuras") or "{}")
            local bestAura = nil
            local bestMult = 0
            for _, a in ipairs(AurasModule.list or {}) do
                local unlocked = false
                if a.pass then
                    unlocked = LocalPlayer:GetAttribute("Pass_" .. a.pass) == true
                elseif a.skip and LocalPlayer:GetAttribute("Pass_" .. a.skip) == true then
                    unlocked = true
                elseif a.exclusive then
                    unlocked = ownedAuras[a.id] == true
                elseif a.trophies and a.trophies <= totalWins then
                    unlocked = true
                end
                if unlocked and (a.mult or 0) > bestMult then
                    bestMult = a.mult
                    bestAura = a
                end
            end
            if bestAura then
                RemoteEquipAura:InvokeServer(bestAura.id)
                WindUI:Notify({ Title = "Aura", Content = "Equipped: " .. (bestAura.name or bestAura.id) .. " (x" .. bestMult .. ")", Duration = 2 })
            end
        end)
    end,
})

-- =======================================================
-- TAB 2: COMBAT & STAGES (MASTER RECONSTRUCTED ENGINE)
-- =======================================================
local TabCombat = Window:Tab({ Title = "Combat & Stages", Icon = "swords" })

TabCombat:Section({ Title = "Live Combat Telemetry" })

local CombatTelemetryParagraph = TabCombat:Paragraph({
    Title = "Combat Status",
    Content = "Evaluating active stage and enemy telemetry..."
})

TabCombat:Section({ Title = "Survival & True God Mode" })

UIElements["GodMode"] = TabCombat:Toggle({
    Title = "True God Mode (Zero Damage, Zero Robux)",
    Desc = "Engine-level death immunity + instant health recovery + auto-dismiss Robux revive prompt.",
    Value = State.GodMode,
    Callback = function(val)
        State.GodMode = val
        if val then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum.BreakJointsOnDeath = false
                hum.Health = hum.MaxHealth
            end
        end
    end,
})

TabCombat:Section({ Title = "Instant Kill Aura" })

UIElements["AutoAttack"] = TabCombat:Toggle({
    Title = "Auto Attack / Kill Aura",
    Desc = "Engages foes automatically when roaming stages or doing wave runs.",
    Value = State.AutoAttack,
    Callback = function(val) State.AutoAttack = val end,
})

UIElements["InstantKill"] = TabCombat:Toggle({
    Title = "Instant Kill Burst",
    Desc = "Dispatches multiple attack packets per tick for instant 1-frame wipe of any wave.",
    Value = State.InstantKill,
    Callback = function(val) State.InstantKill = val end,
})

TabCombat:Slider({
    Title = "Kill Aura Range (Studs)",
    Desc = "Maximum distance to target and destroy enemies (30 - 200 studs).",
    Value = {
        Min = 30,
        Max = 200,
        Default = State.KillAuraRange or 100,
    },
    Step = 5,
    Callback = function(val) State.KillAuraRange = math.floor(val) end,
})

TabCombat:Slider({
    Title = "Attack Burst Packets",
    Desc = "Number of attack packets fired per enemy per tick (1 - 5).",
    Value = {
        Min = 1,
        Max = 5,
        Default = State.KillBurstRate or 2,
    },
    Step = 1,
    Callback = function(val) State.KillBurstRate = math.floor(val) end,
})

UIElements["AutoCastSkills"] = TabCombat:Toggle({
    Title = "Auto Cast Eye Abilities (E & R)",
    Desc = "Triggers special eye skills off cooldown for massive AoE clearing.",
    Value = State.AutoCastSkills,
    Callback = function(val) State.AutoCastSkills = val end,
})

UIElements["AutoTrainInCombat"] = TabCombat:Toggle({
    Title = "Auto Train Chakra in Combat",
    Desc = "Spams Chakra train remote while fighting to gain Chakra simultaneously.",
    Value = State.AutoTrainInCombat,
    Callback = function(val) State.AutoTrainInCombat = val end,
})

TabCombat:Section({ Title = "Autonomous Multi-World Stage Runner" })

TabCombat:Dropdown({
    Title = "Target World",
    Desc = "Select world to run stages in, or use current active world.",
    Values = {
        "Current World (Auto)",
        "World 1 (Shinobi Lands)",
        "World 2 (Celestial Realm)",
        "World 3 (Blood Moon)",
        "World 4 (Frozen Abyss)",
        "World 5 (Cosmic Void)"
    },
    Value = State.TargetWorld,
    Callback = function(val) State.TargetWorld = val end,
})

local stageTargetOptions = {}
for i = 1, 15 do table.insert(stageTargetOptions, "Stage " .. tostring(i)) end

TabCombat:Dropdown({
    Title = "Target Stage to Farm",
    Desc = "Select which stage to clear and claim the Win Pad from (Recommended: Stage 7 or 8 for 100+ Octillion Trophies).",
    Values = stageTargetOptions,
    Value = "Stage " .. tostring(State.TargetStage or 8),
    Callback = function(val)
        local num = tonumber(val:match("(%d+)"))
        if num then
            State.TargetStage = num
        end
    end,
})

UIElements["AutoAdvanceStages"] = TabCombat:Toggle({
    Title = "Auto Stage Runner (Synced Multi-World)",
    Desc = "Runs stages sequentially up to Target Stage -> Steps physically on that stage's Win Pad -> Server Claims Trophies -> Server Returns to Base -> Auto Loops.",
    Value = State.AutoAdvanceStages,
    Callback = function(val)
        State.AutoAdvanceStages = val
        if val then
            State.AutoTrainPosition = false
            if UIElements["AutoTrainPosition"] and UIElements["AutoTrainPosition"].Set then
                pcall(function() UIElements["AutoTrainPosition"]:Set(false) end)
            end
        end
    end,
})

TabCombat:Dropdown({
    Title = "Win Pad Selection",
    Desc = "Gold is 100% Free (1x Wins). Purple provides 3x Wins.",
    Values = {
        "Gold (1x Wins - Free)",
        "Purple (3x Wins)"
    },
    Value = State.PadPreference,
    Callback = function(val) State.PadPreference = val end,
})

TabCombat:Slider({
    Title = "Stage Step Delay",
    Desc = "Delay in seconds between claiming pad and advancing (0.1 - 1.0s).",
    Value = {
        Min = 0.1,
        Max = 1.0,
        Default = State.StageStepDelay,
    },
    Step = 0.05,
    Callback = function(val) State.StageStepDelay = val end,
})

TabCombat:Section({ Title = "Manual Stage Teleportation & Controls" })

local manualStageChoice = "Stage 1"
local manualStageList = {}
for i = 1, 15 do table.insert(manualStageList, "Stage " .. tostring(i)) end

TabCombat:Dropdown({
    Title = "Select Stage",
    Desc = "Choose any stage in current world.",
    Values = manualStageList,
    Value = manualStageChoice,
    Callback = function(val) manualStageChoice = val end,
})

TabCombat:Button({
    Title = "Teleport to Selected Stage Entrance",
    Desc = "Teleports character to the entrance of chosen stage.",
    Callback = function()
        local stageNum = tonumber(manualStageChoice:match("(%d+)")) or 1
        local activeWorld = ResolveActiveWorld()
        local worldOrigin = GetWorldOrigin(activeWorld)
        local sStart = WorldModule.stageStart(stageNum)
        local targetPos = worldOrigin + Vector3.new(0, 3.5, sStart - 6)
        SafeTeleport(targetPos)
        WindUI:Notify({ Title = "Teleported", Content = "Moved to " .. manualStageChoice .. " entrance", Duration = 2.5 })
    end,
})

TabCombat:Button({
    Title = "Teleport to Selected Stage Win Pad",
    Desc = "Teleports directly onto the chosen stage Win Pad.",
    Callback = function()
        local stageNum = tonumber(manualStageChoice:match("(%d+)")) or 1
        local activeWorld = ResolveActiveWorld()
        local worldOrigin = GetWorldOrigin(activeWorld)
        local padLocal = WorldModule.padPosition(stageNum, "gold")
        local padPos = worldOrigin + padLocal
        SafeTeleport(Vector3.new(padPos.X, padPos.Y + 1.8, padPos.Z))
        WindUI:Notify({ Title = "Win Pad", Content = "At " .. manualStageChoice .. " Win Pad", Duration = 2.5 })
    end,
})

TabCombat:Button({
    Title = "Claim Current Stage Win Pad Now",
    Desc = "Teleports to and claims the win pad for currently cleared stage.",
    Callback = function()
        local runCleared = tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0
        if runCleared > 0 then
            local activeWorld = ResolveActiveWorld()
            local worldOrigin = GetWorldOrigin(activeWorld)
            local padLocal = WorldModule.padPosition(runCleared, "gold")
            local padPos = worldOrigin + padLocal
            SafeTeleport(Vector3.new(padPos.X, padPos.Y + 1.8, padPos.Z))
            pcall(function() RemotePad:FireServer(runCleared, "gold") end)
            WindUI:Notify({ Title = "Pad Claimed", Content = "Claimed Stage " .. tostring(runCleared) .. " Gold Pad!", Duration = 3 })
        else
            WindUI:Notify({ Title = "No Cleared Stage", Content = "You haven't cleared any stage yet.", Duration = 2.5 })
        end
    end,
})

TabCombat:Button({
    Title = "Wipe Active Stage Enemies Now",
    Desc = "Instantly clears all active foes in current stage.",
    Callback = function()
        pcall(function()
            local EnemiesMod = require(LocalPlayer.PlayerScripts.Client.Enemies)
            local list = EnemiesMod.list and EnemiesMod.list() or {}
            for _, e in ipairs(list) do
                RemoteCast:FireServer("attack", e.pos, e.id)
                RemoteCast:FireServer("E", e.pos, e.id)
                RemoteCast:FireServer("R", e.pos, e.id)
            end
            local wsEnemies = Workspace:FindFirstChild("MyEnemies")
            if wsEnemies then
                for _, c in ipairs(wsEnemies:GetChildren()) do
                    if c:IsA("Model") and string.find(c.Name, "Foe") then
                        local fId = tonumber(string.match(c.Name, "%d+"))
                        local fPos = c:GetPivot().Position
                        RemoteCast:FireServer("attack", fPos, fId)
                        RemoteCast:FireServer("E", fPos, fId)
                        RemoteCast:FireServer("R", fPos, fId)
                    end
                end
            end
            WindUI:Notify({ Title = "Wave Wiped", Content = "Dispatched attack bursts to all foes", Duration = 2 })
        end)
    end,
})

TabCombat:Section({ Title = "Kyubi Raid Boss (World Event)" })

UIElements["AutoBoss"] = TabCombat:Toggle({
    Title = "Auto Raid Boss (Kyubi)",
    Desc = "Enters rift via JoinZone portal when fight phase begins, eliminates Kyubi with full God Mode.",
    Value = State.AutoBoss,
    Callback = function(val) State.AutoBoss = val end,
})

TabCombat:Button({
    Title = "Join Kyubi Boss Arena Now",
    Desc = "Forces character to enter the Kyubi boss fight arena immediately.",
    Callback = function()
        pcall(function()
            RemoteBoss:FireServer("join")
            local bossCentre = BossLogic.CENTRE or Vector3.new(-3000, 0, 300)
            SafeTeleport(bossCentre + Vector3.new(0, 16.0, 78.0))
            WindUI:Notify({ Title = "Kyubi Boss", Content = "Entered boss arena", Duration = 2.5 })
        end)
    end,
})

TabCombat:Button({
    Title = "Leave Kyubi Boss Arena",
    Desc = "Exits boss arena and returns to current world spawn.",
    Callback = function()
        pcall(function()
            RemoteBoss:FireServer("leave")
            local curWorld = ResolveActiveWorld()
            local worldOrigin = GetWorldOrigin(curWorld)
            SafeTeleport(worldOrigin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
            WindUI:Notify({ Title = "Kyubi Boss", Content = "Returned to world hub", Duration = 2.5 })
        end)
    end,
})

-- =======================================================
-- TAB 3: EYES & REBIRTH
-- =======================================================
local TabEyes = Window:Tab({ Title = "Eyes & Rebirth", Icon = "refresh-cw" })
TabEyes:Section({ Title = "Autonomous Eye Progression (Zero Robux)" })

UIElements["AutoUnlockEyes"] = TabEyes:Toggle({
    Title = "Auto Unlock Affordable Eyes",
    Desc = "Automatically purchases the highest multiplier affordable eye with TotalWins (Trophies). Completely avoids Robux spam.",
    Value = State.AutoUnlockEyes,
    Callback = function(val) State.AutoUnlockEyes = val end,
})

UIElements["AutoEquipBestEye"] = TabEyes:Toggle({
    Title = "Auto Equip Best Owned Eye",
    Desc = "Always keeps your highest multiplier eye equipped in inventory.",
    Value = State.AutoEquipBestEye,
    Callback = function(val) State.AutoEquipBestEye = val end,
})

local EyeProgressionParagraph = TabEyes:Paragraph({
    Title = "Eye Progression Telemetry",
    Content = "Evaluating eye unlocks and progression..."
})

TabEyes:Button({
    Title = "Unlock & Equip Highest Eye Now",
    Desc = "Scans affordable eyes by TotalWins, unlocks all available tiers, and equips the strongest eye.",
    Callback = function()
        pcall(function()
            local affordable = GetAffordableEyesToUnlock()
            local unlockedCount = 0
            local lastUnlocked = nil
            for _, eye in ipairs(affordable) do
                RemoteUnlockEye:FireServer(eye.id)
                task.wait(0.2)
                RemoteEquip:FireServer(eye.id)
                task.wait(0.1)
                unlockedCount = unlockedCount + 1
                lastUnlocked = eye
            end
            
            local bestOwned = GetBestOwnedEye()
            local curEyeId = LocalPlayer:GetAttribute("Eye") or ""
            if bestOwned and bestOwned.id ~= curEyeId then
                RemoteEquip:FireServer(bestOwned.id)
            end
            
            if unlockedCount > 0 and lastUnlocked then
                WindUI:Notify({
                    Title = "Eyes Unlocked & Equipped",
                    Content = "Successfully unlocked " .. unlockedCount .. " eyes! Equipped: " .. (lastUnlocked.name or lastUnlocked.id),
                    Duration = 3
                })
            else
                local nextInfo = GetNextEyeInfo()
                if nextInfo then
                    WindUI:Notify({
                        Title = "Best Eye Equipped",
                        Content = "Highest owned eye (" .. (bestOwned and (bestOwned.name or bestOwned.id) or curEyeId) .. ") is equipped. Next: " .. nextInfo.name .. " needs " .. tostring(nextInfo.needed) .. " more Trophies.",
                        Duration = 3
                    })
                else
                    WindUI:Notify({
                        Title = "Max Eyes Reached",
                        Content = "All non-robux eyes are unlocked! Equipped: " .. (bestOwned and (bestOwned.name or bestOwned.id) or curEyeId),
                        Duration = 2.5
                    })
                end
            end
        end)
    end,
})

TabEyes:Section({ Title = "Instant Auto Rebirth" })

UIElements["AutoRebirth"] = TabEyes:Toggle({
    Title = "Instant Auto Rebirth (0ms Delay)",
    Desc = "Triggers Rebirth immediately the moment required level is reached or progress reaches 100%.",
    Value = State.AutoRebirth,
    Callback = function(val) State.AutoRebirth = val end,
})

TabEyes:Button({
    Title = "Rebirth Now",
    Desc = "Forces manual rebirth invocation.",
    Callback = function()
        pcall(function()
            RemoteRebirth:InvokeServer()
        end)
    end,
})

-- =======================================================
-- TAB 4: PETS, EGGS & FUSION (MULTI-WORLD)
-- =======================================================
local TabPets = Window:Tab({ Title = "Pets & Fusion", Icon = "sparkles" })
TabPets:Section({ Title = "Background Auto Hatch (Zero Screen Disruption)" })

local eggIdMapping = {
    ["Normal Egg (World 1)"] = "normal",
    ["Shinobi Egg (World 1)"] = "shinobi",
    ["Akatsuki Egg (World 1)"] = "akatsuki",
    ["Divine Egg (World 1)"] = "divine",
    ["Lotus Egg (World 2)"] = "lotus",
    ["Celestial Egg (World 2)"] = "celestial",
    ["Blood Moon Egg (World 3)"] = "bloodmoon",
    ["Demon Egg (World 3)"] = "demon",
    ["Frost Egg (World 4)"] = "frost",
    ["Abyss Egg (World 4)"] = "abyss",
    ["Nebula Egg (World 5)"] = "nebula",
    ["Void Egg (World 5)"] = "void",
}

local eggNamesList = {
    "Lotus Egg (World 2)", "Celestial Egg (World 2)",
    "Normal Egg (World 1)", "Shinobi Egg (World 1)", "Akatsuki Egg (World 1)", "Divine Egg (World 1)",
    "Blood Moon Egg (World 3)", "Demon Egg (World 3)",
    "Frost Egg (World 4)", "Abyss Egg (World 4)",
    "Nebula Egg (World 5)", "Void Egg (World 5)"
}

TabPets:Dropdown({
    Title = "Select Target Egg",
    Desc = "Choose which egg to hatch automatically in the background.",
    Values = eggNamesList,
    Value = "Lotus Egg (World 2)",
    Callback = function(val) State.SelectedEgg = val end,
})

TabPets:Dropdown({
    Title = "Hatch Quantity Per Pulse",
    Desc = "1x Hatch or 3x Hatch.",
    Values = { "1", "3" },
    Value = tostring(State.HatchCount),
    Callback = function(val) State.HatchCount = tonumber(val) or 1 end,
})

UIElements["AutoHatch"] = TabPets:Toggle({
    Title = "Auto Hatch Egg (Silent Background)",
    Desc = "Hatches selected egg in background without any camera lock, cutscene, or screen disruption.",
    Value = State.AutoHatch,
    Callback = function(val) State.AutoHatch = val end,
})

UIElements["AutoEquipBestPets"] = TabPets:Toggle({
    Title = "Auto Equip Best Pets",
    Desc = "Continuously keeps your highest multiplier pets equipped.",
    Value = State.AutoEquipBestPets,
    Callback = function(val) State.AutoEquipBestPets = val end,
})

TabPets:Section({ Title = "Auto Fuse & Pet Inventory Management" })

UIElements["AutoFuse"] = TabPets:Toggle({
    Title = "Auto Fuse (4-of-a-Kind Auto Fill)",
    Desc = "Scans inventory for sets of 4 identical pets (exact same pet, same tier) and fuses them automatically.",
    Value = State.AutoFuse,
    Callback = function(val) State.AutoFuse = val end,
})

UIElements["AutoDeleteUnused"] = TabPets:Toggle({
    Title = "Auto Delete Unused Pets",
    Desc = "Deletes all unequipped pets (all tiers/rarities) to prevent inventory full warnings.",
    Value = State.AutoDeleteUnused,
    Callback = function(val) State.AutoDeleteUnused = val end,
})

UIElements["KeepForFuse"] = TabPets:Toggle({
    Title = "Preserve Sets of 4 for Fusion",
    Desc = "When deleting unused pets, spares identical groups of 4 so they can be upgraded.",
    Value = State.KeepForFuse,
    Callback = function(val) State.KeepForFuse = val end,
})

TabPets:Button({
    Title = "Fuse Available Pets Now",
    Desc = "Immediately checks inventory and triggers fusion on all valid 4-pet sets.",
    Callback = function()
        pcall(function()
            local pets = HttpService:JSONDecode(LocalPlayer:GetAttribute("Pets") or "{}")
            local tiers = HttpService:JSONDecode(LocalPlayer:GetAttribute("PetTiers") or "{}")
            local locked = HttpService:JSONDecode(LocalPlayer:GetAttribute("LockedPets") or "[]")
            local equipped = HttpService:JSONDecode(LocalPlayer:GetAttribute("Equipped") or "[]")
            
            local lockedMap = {}
            for _, id in ipairs(locked) do lockedMap[id] = true end
            local equippedMap = {}
            for _, id in ipairs(equipped) do equippedMap[id] = true end
            
            local groups = {}
            for uid, kind in pairs(pets) do
                if not lockedMap[uid] and not equippedMap[uid] then
                    local tier = tiers[uid] or 0
                    local key = kind .. "_" .. tostring(tier)
                    if not groups[key] then
                        groups[key] = { kind = kind, tier = tier, uids = {} }
                    end
                    table.insert(groups[key].uids, uid)
                end
            end
            
            local fusedCount = 0
            for _, g in pairs(groups) do
                while #g.uids >= 4 and LogicFuse.canFuse(g.kind, g.tier) do
                    local fuseSet = { g.uids[1], g.uids[2], g.uids[3], g.uids[4] }
                    RemoteFuse:InvokeServer("fuse", fuseSet)
                    fusedCount = fusedCount + 1
                    for i = 1, 4 do table.remove(g.uids, 1) end
                    task.wait(0.2)
                end
            end
            WindUI:Notify({ Title = "Auto Fuse", Content = "Fused " .. fusedCount .. " pet sets successfully.", Duration = 2.5 })
        end)
    end,
})

TabPets:Button({
    Title = "Delete All Unequipped Pets Now",
    Desc = "Deletes all unequipped pets in inventory immediately.",
    Callback = function()
        pcall(function()
            local pets = HttpService:JSONDecode(LocalPlayer:GetAttribute("Pets") or "{}")
            local equipped = HttpService:JSONDecode(LocalPlayer:GetAttribute("Equipped") or "[]")
            local locked = HttpService:JSONDecode(LocalPlayer:GetAttribute("LockedPets") or "[]")
            
            local equippedMap = {}
            for _, id in ipairs(equipped) do equippedMap[id] = true end
            local lockedMap = {}
            for _, id in ipairs(locked) do lockedMap[id] = true end
            
            local toDelete = {}
            for uid, _ in pairs(pets) do
                if not equippedMap[uid] and not lockedMap[uid] then
                    table.insert(toDelete, uid)
                end
            end
            
            if #toDelete > 0 then
                RemotePetAction:InvokeServer("delete", toDelete)
                WindUI:Notify({ Title = "Pets Deleted", Content = "Deleted " .. #toDelete .. " unequipped pets.", Duration = 2.5 })
            else
                WindUI:Notify({ Title = "Clean Inventory", Content = "No unequipped pets to delete.", Duration = 2 })
            end
        end)
    end,
})

-- =======================================================
-- TAB 5: PROGRESSION & REWARDS
-- =======================================================
local TabProgression = Window:Tab({ Title = "Progression & Rewards", Icon = "gift" })
TabProgression:Section({ Title = "Automated Reward Collection" })

UIElements["AutoClaimDaily"] = TabProgression:Toggle({
    Title = "Auto Claim Daily Rewards",
    Desc = "Claims available daily login rewards automatically.",
    Value = State.AutoClaimDaily,
    Callback = function(val) State.AutoClaimDaily = val end,
})

UIElements["AutoClaimGifts"] = TabProgression:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Collects timed playtime gifts off cooldown.",
    Value = State.AutoClaimGifts,
    Callback = function(val) State.AutoClaimGifts = val end,
})

UIElements["AutoClaimQuests"] = TabProgression:Toggle({
    Title = "Auto Claim Quests (Daily & Weekly)",
    Desc = "Sweeps completed daily and weekly quest rewards.",
    Value = State.AutoClaimQuests,
    Callback = function(val) State.AutoClaimQuests = val end,
})

TabProgression:Section({ Title = "Live Reward Status" })
local labelDailyStatus = TabProgression:Paragraph({ Title = "Daily Login Reward", Desc = "Checking..." })
local labelGiftsStatus = TabProgression:Paragraph({ Title = "Free Playtime Gifts", Desc = "Checking..." })
local labelQuestsStatus = TabProgression:Paragraph({ Title = "Quest Progression", Desc = "Checking..." })

local rewardTelemetry = task.spawn(function()
    while _G.AnimeEyesActive do
        pcall(function()
            -- Daily Reward status
            local dailyLast = LocalPlayer:GetAttribute("DailyLast")
            local today = LocalPlayer:GetAttribute("Today")
            if dailyLast and today and dailyLast == today then
                labelDailyStatus:SetDesc("Claimed Today (Available Tomorrow)")
            else
                labelDailyStatus:SetDesc("READY TO CLAIM!")
            end
            
            -- Gifts status
            local claimedStr = tostring(LocalPlayer:GetAttribute("RewardsClaimed") or "0,0,0")
            local c1, c2, c3 = claimedStr:match("(%d+),(%d+),(%d+)")
            labelGiftsStatus:SetDesc(string.format("5m Gift: %s/9 | 15m Gift: %s/4 | 60m Gift: %s/1", c1 or "0", c2 or "0", c3 or "0"))
            
            -- Quests status
            local dq = HttpService:JSONDecode(LocalPlayer:GetAttribute("QuestDaily") or "{}")
            local dqDone = 0
            if dq and dq.claimed then
                for _, _ in pairs(dq.claimed) do dqDone = dqDone + 1 end
            end
            local wq = HttpService:JSONDecode(LocalPlayer:GetAttribute("QuestWeekly") or "{}")
            local wqDone = 0
            if wq and wq.claimed then
                for _, _ in pairs(wq.claimed) do wqDone = wqDone + 1 end
            end
            labelQuestsStatus:SetDesc(string.format("Daily Quests: %d/5 Claimed | Weekly Quests: %d/5 Claimed", dqDone, wqDone))
            
            -- Training Zone telemetry update
            if TrainingTelemetryParagraph then
                local best, nextUnlock = GetBestTrainingData()
                local rebirths = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local isStationed = false
                if hrp and best and best.pos then
                    isStationed = (Vector2.new(hrp.Position.X - best.pos.X, hrp.Position.Z - best.pos.Z)).Magnitude <= 6
                end
                
                local multStr = FormatLogic and FormatLogic.short(best.mult) or tostring(best.mult)
                local nextStr = "Max Zone Reached!"
                if nextUnlock then
                    local nextMultStr = FormatLogic and FormatLogic.short(nextUnlock.mult) or tostring(nextUnlock.mult)
                    nextStr = string.format("%s (W%d) | Req: %d (+%d needed) | x%s", nextUnlock.name, nextUnlock.world, nextUnlock.rebirths, nextUnlock.needed, nextMultStr)
                end
                
                TrainingTelemetryParagraph:SetDesc(
                    string.format("Current Best: %s (World %d, Spot #%d)\nMultiplier: x%s Chakra\nRebirth Requirement: %d (Your Rebirths: %d)\nStationed Active: %s\n\nNext Unlock Milestone:\n%s",
                        best.name, best.world, best.index, multStr, best.rebirths, rebirths, isStationed and ("YES (x" .. multStr .. " Active)") or "NO (Moving / In Stage)", nextStr)
                )
            end
        end)
        task.wait(4.0)
    end
end)
table.insert(CleanupConnections, rewardTelemetry)

TabProgression:Section({ Title = "Manual Reward Dispatch" })

TabProgression:Button({
    Title = "Claim All Rewards Now",
    Desc = "Executes immediate claim on Daily, Gifts, Quests, and notifies server result.",
    Callback = function()
        pcall(function()
            local messages = {}
            -- Daily
            local dOk, dSuccess, dP1, dMsg = pcall(function() return RemoteClaimDaily:InvokeServer() end)
            if dOk then
                if dSuccess then
                    table.insert(messages, "Daily: Claimed Day " .. tostring(dP1) .. "!")
                else
                    table.insert(messages, "Daily: " .. tostring(dMsg or "Already claimed"))
                end
            end
            
            -- Free Gifts (Slots 1, 2, 3)
            local giftsClaimed = 0
            for i = 1, 3 do
                local gOk, gSuccess, gP1, gMsg = pcall(function() return RemoteClaimReward:InvokeServer(i) end)
                if gOk and gSuccess then
                    giftsClaimed = giftsClaimed + 1
                end
            end
            if giftsClaimed > 0 then
                table.insert(messages, "Gifts: " .. giftsClaimed .. " slot(s) claimed!")
            else
                table.insert(messages, "Gifts: None ready yet.")
            end
            
            -- Quests
            local questsClaimed = 0
            for i = 1, 5 do
                local qOk, qSuccess = pcall(function() return RemoteClaimQuest:InvokeServer("daily", i) end)
                if qOk and qSuccess then questsClaimed = questsClaimed + 1 end
                local wOk, wSuccess = pcall(function() return RemoteClaimQuest:InvokeServer("weekly", i) end)
                if wOk and wSuccess then questsClaimed = questsClaimed + 1 end
            end
            if questsClaimed > 0 then
                table.insert(messages, "Quests: " .. questsClaimed .. " claimed!")
            else
                table.insert(messages, "Quests: All claimed or in progress.")
            end
            
            WindUI:Notify({
                Title = "Reward Claim Results",
                Content = table.concat(messages, "\n"),
                Duration = 4,
            })
        end)
    end,
})

-- =======================================================
-- TAB 6: MOVEMENT & PHYSICS
-- =======================================================
local TabMovement = Window:Tab({ Title = "Movement", Icon = "activity" })
TabMovement:Section({ Title = "Character Attributes" })

UIElements["WalkSpeedEnabled"] = TabMovement:Toggle({
    Title = "Enable Custom WalkSpeed",
    Desc = "Modifies character movement speed.",
    Value = State.WalkSpeedEnabled,
    Callback = function(val) State.WalkSpeedEnabled = val end,
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Desc = "Player WalkSpeed (16 - 150).",
    Value = {
        Min = 16,
        Max = 150,
        Default = State.WalkSpeed,
    },
    Step = 1,
    Callback = function(val) State.WalkSpeed = math.floor(val) end,
})

UIElements["JumpPowerEnabled"] = TabMovement:Toggle({
    Title = "Enable Custom JumpPower",
    Desc = "Modifies vertical jump height.",
    Value = State.JumpPowerEnabled,
    Callback = function(val) State.JumpPowerEnabled = val end,
})

TabMovement:Slider({
    Title = "JumpPower Value",
    Desc = "Player JumpPower (50 - 250).",
    Value = {
        Min = 50,
        Max = 250,
        Default = State.JumpPower,
    },
    Step = 1,
    Callback = function(val) State.JumpPower = math.floor(val) end,
})

UIElements["InfiniteJump"] = TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air.",
    Value = State.InfiniteJump,
    Callback = function(val) State.InfiniteJump = val end,
})

UIElements["Noclip"] = TabMovement:Toggle({
    Title = "Noclip",
    Desc = "Phase through walls and stage barriers.",
    Value = State.Noclip,
    Callback = function(val) State.Noclip = val end,
})

UIElements["AntiAFK"] = TabMovement:Toggle({
    Title = "Anti-AFK (20m Kick Bypass)",
    Desc = "Bypasses Roblox 20-minute idle disconnect timer using VirtualUser simulation.",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
        if val then
            WindUI:Notify({ Title = "Anti-AFK Active", Content = "20-minute idle kick protection enabled.", Duration = 2.5 })
        end
    end,
})

-- =======================================================
-- TAB 7: PROFILE & CONFIG
-- =======================================================
local TabProfile = Window:Tab({ Title = "Profile", Icon = "user" })
TabProfile:Section({ Title = "Live Player Telemetry" })

local labelChakra = TabProfile:Paragraph({ Title = "Chakra", Desc = "Loading..." })
local labelWins = TabProfile:Paragraph({ Title = "Wins", Desc = "Loading..." })
local labelLevel = TabProfile:Paragraph({ Title = "Level & Rebirth", Desc = "Loading..." })
local labelStage = TabProfile:Paragraph({ Title = "Stage State", Desc = "Loading..." })

local telemetryWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        pcall(function()
            local chakra = LocalPlayer:GetAttribute("Chakra") or 0
            local wins = LocalPlayer:GetAttribute("Wins") or 0
            local level = LocalPlayer:GetAttribute("Level") or 0
            local rebirths = LocalPlayer:GetAttribute("Rebirths") or 0
            local curWorld = LocalPlayer:GetAttribute("World") or 1
            local runStage = LocalPlayer:GetAttribute("RunStage") or 0
            local runCleared = LocalPlayer:GetAttribute("RunCleared") or 0
            
            labelChakra:SetDesc(tostring(chakra))
            labelWins:SetDesc(tostring(wins))
            labelLevel:SetDesc("Level: " .. level .. " | Rebirths: " .. rebirths)
            labelStage:SetDesc("World: " .. curWorld .. " | Stage: " .. runStage .. " (Cleared: " .. runCleared .. ")")

            if CombatTelemetryParagraph then
                pcall(function()
                    local inWave = LocalPlayer:GetAttribute("InWave") == true
                    local bossPhase = Workspace:GetAttribute("BossPhase") or "wait"
                    local wsEnemies = Workspace:FindFirstChild("MyEnemies")
                    local foeCount = wsEnemies and #wsEnemies:GetChildren() or 0

                    CombatTelemetryParagraph:SetDesc(string.format(
                        "Active World: World %s | Target World: %s\nRun Stage: %d | Cleared: %d / %d\nIn Wave: %s | Foes Remaining: %d\nKyubi Boss Phase: %s | God Mode: %s",
                        tostring(curWorld), tostring(State.TargetWorld),
                        runStage, runCleared, State.TargetStage or 15,
                        inWave and "YES" or "NO", foeCount,
                        tostring(bossPhase):upper(), State.GodMode and "ACTIVE" or "OFF"
                    ))
                end)
            end
            
            if EyeProgressionParagraph then
                pcall(function()
                    local curEye = LocalPlayer:GetAttribute("Eye") or "none"
                    local eyeMult = LocalPlayer:GetAttribute("EyeMult") or 1
                    local totalWins = tonumber(LocalPlayer:GetAttribute("TotalWins")) or 0
                    local nextInfo = GetNextEyeInfo()
                    local nextStr = "All Non-Robux Eyes Unlocked!"
                    if nextInfo then
                        nextStr = string.format("%s (World %d)\nReq: %s Trophies\nProgress: %s / %s (%.1f%%)\nRemaining: %s Trophies Needed",
                            nextInfo.name, nextInfo.world, tostring(nextInfo.cost),
                            tostring(totalWins), tostring(nextInfo.cost), nextInfo.pct,
                            tostring(nextInfo.needed))
                    end
                    EyeProgressionParagraph:SetDesc(string.format(
                        "Equipped Eye: %s (x%s Multiplier)\nTotal Lifetime Trophies: %s\n\nNext Unlock Target:\n%s",
                        tostring(curEye), tostring(eyeMult), tostring(totalWins), nextStr
                    ))
                end)
            end
        end)
        task.wait(3.0)
    end
end)
table.insert(CleanupConnections, telemetryWorker)

TabProfile:Section({ Title = "Automation Management" })

TabProfile:Button({
    Title = "Unload Automation & Destroy UI",
    Desc = "Safely terminates all background threads, removes hooks, and cleans up UI.",
    Callback = function()
        if typeof(_G.AnimeEyesTeardown) == "function" then
            _G.AnimeEyesTeardown()
        end
    end,
})

-- =======================================================
-- TAB 8: CONFIGURATION & PROFILES
-- =======================================================
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })
TabConfig:Section({ Title = "Profile Management" })

local ConfigFolder = "AnimeEyes_Configs"
local function EnsureConfigFolder()
    if makefolder and not isfolder(ConfigFolder) then
        pcall(function() makefolder(ConfigFolder) end)
    end
end
EnsureConfigFolder()

local function ListProfiles()
    local files = { "default" }
    if listfiles and isfolder and isfolder(ConfigFolder) then
        pcall(function()
            for _, f in ipairs(listfiles(ConfigFolder)) do
                local name = f:match("([^/\\]+)%.json$")
                if name and name ~= "default" then
                    table.insert(files, name)
                end
            end
        end)
    end
    return files
end

local CurrentProfileName = "default"
local ProfileDropdown = nil

TabConfig:Input({
    Title = "Profile Name",
    Desc = "Enter profile name to save.",
    Value = CurrentProfileName,
    Callback = function(val)
        if val and val ~= "" then
            CurrentProfileName = val
        end
    end,
})

TabConfig:Button({
    Title = "Save Current Profile",
    Desc = "Saves all current state toggles and settings to JSON.",
    Callback = function()
        pcall(function()
            EnsureConfigFolder()
            local filePath = ConfigFolder .. "/" .. CurrentProfileName .. ".json"
            local data = HttpService:JSONEncode(State)
            if writefile then
                writefile(filePath, data)
                WindUI:Notify({ Title = "Config Saved", Content = "Saved profile: " .. CurrentProfileName, Duration = 3 })
            end
            if ProfileDropdown and ProfileDropdown.SetValues then
                ProfileDropdown:Refresh(ListProfiles(), true)
            end
        end)
    end,
})

ProfileDropdown = TabConfig:Dropdown({
    Title = "Select Profile to Load",
    Desc = "Choose an existing saved profile.",
    Values = ListProfiles(),
    Value = CurrentProfileName,
    Callback = function(val)
        CurrentProfileName = val
    end,
})

TabConfig:Button({
    Title = "Load Selected Profile",
    Desc = "Applies settings from the selected profile file.",
    Callback = function()
        pcall(function()
            local filePath = ConfigFolder .. "/" .. CurrentProfileName .. ".json"
            if isfile and isfile(filePath) and readfile then
                local content = readfile(filePath)
                local loaded = HttpService:JSONDecode(content)
                if loaded then
                    for k, v in pairs(loaded) do
                        State[k] = v
                        if UIElements[k] and UIElements[k].SetValue then
                            pcall(function() UIElements[k]:SetValue(v) end)
                        end
                    end
                    WindUI:Notify({ Title = "Config Loaded", Content = "Loaded profile: " .. CurrentProfileName, Duration = 3 })
                end
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Refresh Profiles List",
    Desc = "Refreshes dropdown with newly saved profiles.",
    Callback = function()
        if ProfileDropdown and ProfileDropdown.SetValues then
            ProfileDropdown:Refresh(ListProfiles(), true)
            WindUI:Notify({ Title = "Profiles Refreshed", Content = "Refreshed profile list", Duration = 2 })
        end
    end,
})

TabConfig:Section({ Title = "Emergency & Teardown" })

TabConfig:Button({
    Title = "Reset All (ALL OFF)",
    Desc = "Safely turns off all automation features immediately.",
    Callback = function()
        for k, v in pairs(State) do
            if typeof(v) == "boolean" and k ~= "AntiAFK" then
                State[k] = false
                if UIElements[k] and UIElements[k].SetValue then
                    pcall(function() if UIElements[k].Set then UIElements[k]:Set(false) end end)
                end
            end
        end
        WindUI:Notify({ Title = "All Features OFF", Content = "All automation toggles turned off safely.", Duration = 3 })
    end,
})

TabConfig:Button({
    Title = "Unload Automation & Destroy UI",
    Desc = "Safely terminates all background threads, removes hooks, and cleans up UI.",
    Callback = function()
        if typeof(_G.AnimeEyesTeardown) == "function" then
            _G.AnimeEyesTeardown()
        end
    end,
})

-- =======================================================
-- BACKGROUND AUTOMATION WORKERS
-- =======================================================

-- Helper: High-Speed Native Combat Execution Burst
local function ExecuteCombatBurst(targetPos, targetFoeId, modifyCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and targetPos and modifyCFrame then
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
    end

    if State.AutoTrain then
        pcall(function() RemoteTrain:FireServer() end)
    end

    pcall(function()
        if InputClient and InputClient.autoClick then
            InputClient.autoClick()
        end
    end)

    if targetPos then
        local bursts = State.KillBurstRate or 2
        for _ = 1, bursts do
            pcall(function()
                RemoteCast:FireServer("attack", targetPos, targetFoeId)
                if State.AutoCastSkills or State.InstantKill then
                    RemoteCast:FireServer("E", targetPos, targetFoeId)
                    RemoteCast:FireServer("R", targetPos, targetFoeId)
                end
            end)
        end
    end
end

-- Shared Predicate: Check if Kyubi Raid Boss is active (Hoisted for all workers)
local function IsKyubiActive()
    if not State.AutoBoss then return false end
    local bossPhase = Workspace:GetAttribute("BossPhase")
    return bossPhase == "fight" or bossPhase == "coming"
end

-- WORKER 1: Calibrated Chakra Training Engine (Zero Network Lag)
local trainWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoTrain then
            pcall(function()
                RemoteTrain:FireServer()
            end)
            local cps = math.clamp(State.TrainRate or 15, 5, 25)
            task.wait(1 / cps)
        else
            task.wait(0.3)
        end
    end
end)
table.insert(CleanupConnections, trainWorker)

-- WORKER 1B: Autonomous Training Spot Stationing Sentinel (Non-Interfering)
local lastStationCheck = 0
local lastStationedSpotId = nil
local lastWorldTeleport = 0

local stationWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoTrainPosition then
            pcall(function()
                -- Strict Guard: NEVER station if running stages, in wave, in stage lane, or stage cleared
                if State.AutoAdvanceStages or IsKyubiActive() then return end
                if (LocalPlayer:GetAttribute("InWave") == true) or (LocalPlayer:GetAttribute("InStages") == true) then return end
                if (tonumber(LocalPlayer:GetAttribute("RunStage")) or 0) > 0 then return end
                if (tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0) > 0 then return end

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local curWorld = tonumber(LocalPlayer:GetAttribute("World")) or 1
                local origin = GetWorldOrigin(curWorld)
                local localZ = hrp and (hrp.Position.Z - origin.Z) or 0

                if localZ < -10 then
                    return
                end

                local bestInWorld, bestGlobal, nextUnlock = GetBestTrainingData(curWorld)
                local rebirths = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0

                if hrp and bestInWorld and bestInWorld.pos then
                    local dist = (Vector2.new(hrp.Position.X - bestInWorld.pos.X, hrp.Position.Z - bestInWorld.pos.Z)).Magnitude
                    if dist > 4 and (os.clock() - lastStationCheck > 1.0) then
                        SafeTeleport(bestInWorld.pos)
                        lastStationCheck = os.clock()

                        if lastStationedSpotId and lastStationedSpotId ~= bestInWorld.id then
                            local multFormatted = FormatLogic and FormatLogic.short(bestInWorld.mult) or tostring(bestInWorld.mult)
                            WindUI:Notify({
                                Title = "Training Zone Upgraded!",
                                Content = string.format("Stationed at: %s (World %d)\nMultiplier: x%s Chakra", bestInWorld.name, curWorld, multFormatted),
                                Duration = 3,
                            })
                        end
                        lastStationedSpotId = bestInWorld.id
                    end
                elseif hrp and (not bestInWorld) then
                    if bestGlobal and bestGlobal.world ~= curWorld then
                        if os.clock() - lastWorldTeleport > 5.0 then
                            lastWorldTeleport = os.clock()
                            pcall(function() RemoteTeleport:FireServer(bestGlobal.world) end)
                        end
                    else
                        local spawnPos = origin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0)
                        local dist = (Vector2.new(hrp.Position.X - spawnPos.X, hrp.Position.Z - spawnPos.Z)).Magnitude
                        if dist > 8 and (os.clock() - lastStationCheck > 1.5) then
                            SafeTeleport(spawnPos)
                            lastStationCheck = os.clock()
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)
table.insert(CleanupConnections, stationWorker)

-- WORKER 2: Auto Aura Evaluator
local auraWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoEquipBestAura then
            pcall(function()
                local totalWins = tonumber(LocalPlayer:GetAttribute("TotalWins")) or 0
                local ownedAuras = HttpService:JSONDecode(LocalPlayer:GetAttribute("OwnedAuras") or "{}")
                local curAuraId = LocalPlayer:GetAttribute("Aura") or ""
                local bestAura = nil
                local bestMult = 0
                for _, a in ipairs(AurasModule.list or {}) do
                    local unlocked = false
                    if a.pass then
                        unlocked = LocalPlayer:GetAttribute("Pass_" .. a.pass) == true
                    elseif a.skip and LocalPlayer:GetAttribute("Pass_" .. a.skip) == true then
                        unlocked = true
                    elseif a.exclusive then
                        unlocked = ownedAuras[a.id] == true
                    elseif a.trophies and a.trophies <= totalWins then
                        unlocked = true
                    end
                    if unlocked and (a.mult or 0) > bestMult then
                        bestMult = a.mult
                        bestAura = a
                    end
                end
                if bestAura and bestAura.id ~= curAuraId then
                    RemoteEquipAura:InvokeServer(bestAura.id)
                end
            end)
            task.wait(3.0)
        else
            task.wait(1.0)
        end
    end
end)
table.insert(CleanupConnections, auraWorker)

-- WORKER 3: High-Speed Combat & Kill Aura Engine
local combatWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if (State.AutoAttack or State.InstantKill or State.AutoCastSkills) and not State.AutoAdvanceStages and not IsKyubiActive() then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local range = State.KillAuraRange or 100
                local bursts = State.KillBurstRate or 2

                -- 1. Target Foes in Workspace.MyEnemies
                local wsEnemies = Workspace:FindFirstChild("MyEnemies")
                if wsEnemies then
                    for _, c in ipairs(wsEnemies:GetChildren()) do
                        if c:IsA("Model") and string.find(c.Name, "Foe") then
                            local fPos = c:GetPivot().Position
                            local dist = (hrp.Position - fPos).Magnitude
                            if dist <= range then
                                local fId = tonumber(string.match(c.Name, "%d+"))
                                for _ = 1, bursts do
                                    RemoteCast:FireServer("attack", fPos, fId)
                                    if State.AutoCastSkills or State.InstantKill then
                                        RemoteCast:FireServer("E", fPos, fId)
                                        RemoteCast:FireServer("R", fPos, fId)
                                    end
                                end
                            end
                        end
                    end
                end

                -- 2. Target Foes streamed in Client.Enemies
                if EnemiesClient and EnemiesClient.count and EnemiesClient.count() > 0 then
                    for _, enemy in ipairs(EnemiesClient.list()) do
                        if enemy.pos and enemy.id then
                            local dist = (hrp.Position - enemy.pos).Magnitude
                            if dist <= range then
                                for _ = 1, bursts do
                                    RemoteCast:FireServer("attack", enemy.pos, enemy.id)
                                    if State.AutoCastSkills or State.InstantKill then
                                        RemoteCast:FireServer("E", enemy.pos, enemy.id)
                                        RemoteCast:FireServer("R", enemy.pos, enemy.id)
                                    end
                                end
                            end
                        end
                    end
                end

                -- 3. Concurrent Chakra Training
                if State.AutoTrainInCombat then
                    pcall(function() RemoteTrain:FireServer() end)
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end)
table.insert(CleanupConnections, combatWorker)

-- WORKER 4: Dedicated Autonomous Multi-World Stage Runner
local stageRunnerWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoAdvanceStages and not IsKyubiActive() then
            local success, err = pcall(function()
                if LocalPlayer.GameplayPaused then
                    task.wait(0.5)
                    return
                end

                local activeWorld = ResolveActiveWorld()
                local worldOrigin = GetWorldOrigin(activeWorld)
                local targetStage = math.clamp(State.TargetStage or 1, 1, 15)

                local function ResolveValidPadType()
                    local pref = tostring(State.PadPreference or ""):lower()
                    if pref:find("purple") and LocalPlayer:GetAttribute("Pass_winsPad") == true then
                        return "purple"
                    end
                    return "gold"
                end
                local padType = ResolveValidPadType()

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then
                    task.wait(0.3)
                    return
                end

                -- World check: ensure in correct world
                local currentWorldId = WorldModule.worldAt(hrp.Position)
                if currentWorldId ~= activeWorld then
                    pcall(function() RemoteTeleport:FireServer(activeWorld) end)
                    task.wait(0.5)
                    SafeTeleport(worldOrigin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
                    task.wait(0.5)
                    return
                end

                -- STEP 1: Wait until previous run is cleared and character is ready at Base
                local tWait0 = os.clock()
                while (tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0) > 0 and (os.clock() - tWait0 < 2.0) do
                    task.wait(0.05)
                end

                local distToSpawn = (hrp.Position - (worldOrigin + WorldModule.SPAWN)).Magnitude
                if distToSpawn > 30 and (tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0) == 0 then
                    SafeTeleport(worldOrigin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
                    task.wait(0.2)
                end

                -- STEP 2: Clear stages sequentially from 1 up to targetStage
                local lastCleared = 0
                for stg = 1, targetStage do
                    if not State.AutoAdvanceStages or not _G.AnimeEyesActive or IsKyubiActive() then
                        break
                    end

                    local sStart = WorldModule.stageStart(stg)
                    local sCentre = WorldModule.spawnCentre(stg)
                    local standPos = worldOrigin + Vector3.new(0, 3.5, sStart - 6)
                    local lookTarget = worldOrigin + sCentre

                    -- Teleport to stage entrance
                    SafeTeleport(standPos)
                    hrp.CFrame = CFrame.lookAt(standPos, lookTarget)
                    hrp.AssemblyLinearVelocity = Vector3.zero

                    -- Combat loop until this stage is cleared
                    local t0 = os.clock()
                    local stgClear = false
                    while State.AutoAdvanceStages and _G.AnimeEyesActive and not IsKyubiActive() do
                        local rC = tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0
                        if rC >= stg then
                            lastCleared = rC
                            stgClear = true
                            break
                        end

                        if os.clock() - t0 > 15.0 then
                            break
                        end

                        -- Attack foes with full skill burst for instant wipe
                        local list = EnemiesClient and EnemiesClient.list and EnemiesClient.list() or {}
                        for _, foe in ipairs(list) do
                            if foe.pos and foe.id then
                                for _ = 1, (State.KillBurstRate or 2) do
                                    RemoteCast:FireServer("attack", foe.pos, foe.id)
                                    RemoteCast:FireServer("E", foe.pos, foe.id)
                                    RemoteCast:FireServer("R", foe.pos, foe.id)
                                end
                            end
                        end
                        RemoteCast:FireServer("attack", lookTarget, nil)
                        RemoteCast:FireServer("E", lookTarget, nil)

                        if State.AutoTrainInCombat then
                            RemoteTrain:FireServer()
                        end

                        task.wait(0.04)
                    end

                    if not stgClear then
                        break
                    end
                    task.wait(0.04)
                end

                -- STEP 3: Wave is Clear! Teleport near Win Pad and physically walk onto it!
                local curClr = tonumber(LocalPlayer:GetAttribute("RunCleared")) or lastCleared
                if curClr > 0 then
                    local claimStage = math.clamp(curClr, 1, 15)
                    local padLocal = WorldModule.padPosition(claimStage, padType)
                    local nearPad = worldOrigin + Vector3.new(padLocal.X, 3.5, padLocal.Z + 8)
                    local onPad = worldOrigin + Vector3.new(padLocal.X, 3.5, padLocal.Z)

                    -- 1. Teleport 8 studs in front of pad
                    SafeTeleport(nearPad)
                    task.wait(0.15)

                    -- 2. Take physical walking steps directly across the pad boundary!
                    hum:MoveTo(onPad)

                    -- STEP 4: Wait on pad for Gates.luau & server to detect physical touch, award trophies, and teleport player to Base
                    local t1 = os.clock()
                    local returned = false
                    while State.AutoAdvanceStages and _G.AnimeEyesActive and (os.clock() - t1 < 4.0) do
                        local rC = tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0
                        local dist = (hrp.Position - (worldOrigin + WorldModule.SPAWN)).Magnitude
                        if rC == 0 or dist < 20 then
                            returned = true
                            break
                        end
                        task.wait(0.08)
                    end

                    if not returned then
                        SafeTeleport(worldOrigin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
                    end

                    -- STEP 5: Ensure RunCleared is reset to 0 before next loop
                    local tWait1 = os.clock()
                    while (tonumber(LocalPlayer:GetAttribute("RunCleared")) or 0) > 0 and (os.clock() - tWait1 < 2.0) do
                        task.wait(0.05)
                    end

                    task.wait(State.StageStepDelay or 0.25)
                else
                    SafeTeleport(worldOrigin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
                    task.wait(0.4)
                end
            end)
            if not success and err then
                warn("[StageRunner] " .. tostring(err))
                task.wait(0.5)
            end
        else
            task.wait(0.3)
        end
    end
end)
table.insert(CleanupConnections, stageRunnerWorker)

-- WORKER 5: Kyubi Raid Boss Engine (Direct Remote Join & Safe Perimeter Attack)
local bossWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoBoss then
            pcall(function()
                local bossPhase = Workspace:GetAttribute("BossPhase")
                local bossCentre = BossLogic.CENTRE or Vector3.new(-3000, 0, 300)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local inBossArena = hrp and (Vector2.new(hrp.Position.X - bossCentre.X, hrp.Position.Z - bossCentre.Z).Magnitude < 160)

                if bossPhase == "fight" or bossPhase == "coming" then
                    pcall(function()
                        RemoteBoss:FireServer("join")
                    end)

                    local foeId = BossLogic.FOE_ID or 2000000000
                    local bx = Workspace:GetAttribute("BossX") or bossCentre.X
                    local bz = Workspace:GetAttribute("BossZ") or bossCentre.Z
                    local bossTargetPos = Vector3.new(bx, bossCentre.Y + (BossLogic.CHEST or 14), bz)
                    local safeCombatPos = bossCentre + Vector3.new(0, 16.0, 78.0)

                    if hrp and (not inBossArena or (hrp.Position - safeCombatPos).Magnitude > 12) then
                        SafeTeleport(safeCombatPos)
                    end

                    -- Attack Kyubi
                    for _ = 1, 2 do
                        RemoteCast:FireServer("attack", bossTargetPos, foeId)
                        RemoteCast:FireServer("E", bossTargetPos, foeId)
                        RemoteCast:FireServer("R", bossTargetPos, foeId)
                    end
                elseif bossPhase == "over" or bossPhase == "wait" then
                    if inBossArena then
                        pcall(function()
                            RemoteBoss:FireServer("leave")
                        end)
                        local curWorld = ResolveActiveWorld()
                        local worldOrigin = GetWorldOrigin(curWorld)
                        SafeTeleport(worldOrigin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
                        task.wait(0.5)
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)
table.insert(CleanupConnections, bossWorker)

-- WORKER 6: Auto Unlock & Equip Eyes (Throttled & Non-Spamming)
local attemptedEyes = {}

local eyesWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoUnlockEyes or State.AutoEquipBestEye then
            pcall(function()
                if State.AutoUnlockEyes then
                    local affordable = GetAffordableEyesToUnlock()
                    for _, eye in ipairs(affordable) do
                        if not attemptedEyes[eye.id] then
                            attemptedEyes[eye.id] = true
                            RemoteUnlockEye:FireServer(eye.id)
                            task.wait(0.4)
                            RemoteEquip:FireServer(eye.id)
                            task.wait(0.2)
                            break
                        end
                    end
                end

                if State.AutoEquipBestEye then
                    local curEye = LocalPlayer:GetAttribute("Eye") or ""
                    local bestOwned = GetBestOwnedEye()
                    if bestOwned and bestOwned.id ~= curEye then
                        RemoteEquip:FireServer(bestOwned.id)
                    end
                end
            end)
            task.wait(2.5)
        else
            task.wait(2.5)
        end
    end
end)
table.insert(CleanupConnections, eyesWorker)

-- WORKER 7: Safe Auto Rebirth Engine (Guarded Against Mid-Stage Interruption)
local lastRebirthAttempt = 0

local function TriggerRebirthCheck()
    if not State.AutoRebirth or not _G.AnimeEyesActive then return end
    if State.AutoAdvanceStages or LocalPlayer:GetAttribute("InStages") == true or LocalPlayer:GetAttribute("InWave") == true then
        return
    end
    if os.clock() - lastRebirthAttempt < 3.0 then return end

    pcall(function()
        local level = tonumber(LocalPlayer:GetAttribute("Level")) or 0
        local reqLevel = tonumber(LocalPlayer:GetAttribute("RebirthLevel")) or 10
        local progress = tonumber(LocalPlayer:GetAttribute("RebirthProgress")) or 0
        if progress >= 0.99 or level >= reqLevel then
            lastRebirthAttempt = os.clock()
            RemoteRebirth:InvokeServer()
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            local r = pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Frames") and pgui.Main.Frames:FindFirstChild("Rebirths")
            if r then r.Visible = false end
        end
    end)
end

local rebirthWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoRebirth then
            TriggerRebirthCheck()
        end
        task.wait(1.0)
    end
end)
table.insert(CleanupConnections, rebirthWorker)

-- WORKER 8: Background Auto Hatch, Auto Fuse & Auto Delete (Fully Async & Non-Blocking)
local petWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AutoHatch then
            pcall(function()
                local eggId = eggIdMapping[State.SelectedEgg] or "lotus"
                local count = State.HatchCount or 1
                RemotePetAction:InvokeServer("hatch", { egg = eggId, count = count })
            end)
            task.wait(1.2)
        end

        if State.AutoEquipBestPets then
            pcall(function()
                RemotePetAction:InvokeServer("equipBest")
            end)
            task.wait(2.0)
        end

        if State.AutoFuse and RemoteFuse and LogicFuse then
            pcall(function()
                local pets = HttpService:JSONDecode(LocalPlayer:GetAttribute("Pets") or "{}")
                local tiers = HttpService:JSONDecode(LocalPlayer:GetAttribute("PetTiers") or "{}")
                local locked = HttpService:JSONDecode(LocalPlayer:GetAttribute("LockedPets") or "[]")
                local equipped = HttpService:JSONDecode(LocalPlayer:GetAttribute("Equipped") or "[]")

                local lockedMap = {}
                for _, id in ipairs(locked) do lockedMap[id] = true end
                local equippedMap = {}
                for _, id in ipairs(equipped) do equippedMap[id] = true end

                local groups = {}
                for uid, kind in pairs(pets) do
                    if not lockedMap[uid] and not equippedMap[uid] then
                        local tier = tiers[uid] or 0
                        local key = kind .. "_" .. tostring(tier)
                        groups[key] = groups[key] or { kind = kind, tier = tier, uids = {} }
                        table.insert(groups[key].uids, uid)
                    end
                end

                for _, g in pairs(groups) do
                    if #g.uids >= 4 and LogicFuse.canFuse(g.kind, g.tier) then
                        local fuseSet = { g.uids[1], g.uids[2], g.uids[3], g.uids[4] }
                        RemoteFuse:InvokeServer("fuse", fuseSet)
                        break
                    end
                end
            end)
            task.wait(3.0)
        end

        if State.AutoDeleteUnused then
            pcall(function()
                local pets = HttpService:JSONDecode(LocalPlayer:GetAttribute("Pets") or "{}")
                local equipped = HttpService:JSONDecode(LocalPlayer:GetAttribute("Equipped") or "[]")
                local locked = HttpService:JSONDecode(LocalPlayer:GetAttribute("LockedPets") or "[]")

                local equippedMap = {}
                for _, id in ipairs(equipped) do equippedMap[id] = true end
                local lockedMap = {}
                for _, id in ipairs(locked) do lockedMap[id] = true end

                local toDelete = {}
                for uid, _ in pairs(pets) do
                    if not equippedMap[uid] and not lockedMap[uid] then
                        table.insert(toDelete, uid)
                    end
                end

                if #toDelete > 0 then
                    RemotePetAction:InvokeServer("delete", toDelete)
                end
            end)
            task.wait(4.0)
        end

        task.wait(0.5)
    end
end)
table.insert(CleanupConnections, petWorker)

-- Screen Cutscene Suppressor for Background Hatch
local hatchSuppressConn = RunService.Heartbeat:Connect(function()
    pcall(function()
        local overlay = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("HUD") and PlayerGui.Main.HUD:FindFirstChild("Overlay")
        local hatch = overlay and overlay:FindFirstChild("Hatch")
        if hatch and hatch.Visible then
            hatch.Visible = false
            if firesignal then
                pcall(function() firesignal(hatch.Activated) end)
            end
        end
    end)
end)
table.insert(CleanupConnections, hatchSuppressConn)

-- WORKER 9: Progression & Reward Sweeper (Throttled 10s Interval)
local sweepWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        pcall(function()
            if State.AutoClaimDaily then
                RemoteClaimDaily:InvokeServer()
            end
            if State.AutoClaimGifts then
                for slot = 1, 3 do
                    RemoteClaimReward:InvokeServer(slot)
                    task.wait(0.2)
                end
            end
            if State.AutoClaimQuests then
                for i = 1, 5 do
                    RemoteClaimQuest:InvokeServer("daily", i)
                    task.wait(0.1)
                end
            end
        end)
        task.wait(10.0)
    end
end)
table.insert(CleanupConnections, sweepWorker)

-- WORKER 10: Character Physics, True God Mode & Zero-Robux Shield
local physicsConn = RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        -- WalkSpeed & JumpPower
        if hum then
            if State.WalkSpeedEnabled then
                hum.WalkSpeed = State.WalkSpeed
            end
            if State.JumpPowerEnabled then
                hum.JumpPower = State.JumpPower
            end
        end
        
        -- Noclip
        if State.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        
        -- True God Mode Engine (Predictive Red-Circle Repulsion + Engine State Immunity)
        if State.GodMode and hrp and hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum.BreakJointsOnDeath = false
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end

            -- Void fall protection (only clamp if falling below map)
            if hrp.Position.Y < -80 then
                local curWorld = ResolveActiveWorld()
                local origin = GetWorldOrigin(curWorld)
                SafeTeleport(origin + WorldModule.SPAWN + Vector3.new(0, 3.5, 0))
            end
        end

        -- Absolute Zero-Robux Auto-Revive & Screen Suppressor (Never Surrenders)
        local reviveGui = PlayerGui:FindFirstChild("Revive")
        if reviveGui and reviveGui.Enabled then
            reviveGui.Enabled = false
            pcall(function()
                local bossPhase = Workspace:GetAttribute("BossPhase")
                if bossPhase == "fight" then
                    RemoteBoss:FireServer("revive")
                else
                    RemoteRevive:FireServer("no")
                end
            end)
            pcall(function() if ReviveClient and ReviveClient.hide then ReviveClient.hide() end end)
            local main = PlayerGui:FindFirstChild("Main")
            if main then main.Enabled = true end
        end
    end)
end)
table.insert(CleanupConnections, physicsConn)

-- Infinite Jump Hook
local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(CleanupConnections, infJumpConn)

-- Anti-AFK Hook & Proactive 10-Minute Activity Pulse
local afkConn = LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)
table.insert(CleanupConnections, afkConn)

local afkKeepAliveWorker = task.spawn(function()
    while _G.AnimeEyesActive do
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
            task.wait(600)
        else
            task.wait(2.0)
        end
    end
end)
table.insert(CleanupConnections, afkKeepAliveWorker)

-- =======================================================
-- TEARDOWN HANDLER
-- =======================================================
_G.AnimeEyesTeardown = function()
    _G.AnimeEyesActive = false
    for _, conn in ipairs(CleanupConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        elseif typeof(conn) == "thread" then
            pcall(function() task.cancel(conn) end)
        end
    end
    table.clear(CleanupConnections)
    if _G.AnimeEyesFAB then
        pcall(function() _G.AnimeEyesFAB:Destroy() end)
        _G.AnimeEyesFAB = nil
    end
    pcall(function() Window:Destroy() end)
    print("[+1 Anime Eyes] All background workers and UI unloaded cleanly.")
end

WindUI:Notify({
    Title = "+1 Anime Eyes Loaded",
    Content = "Master automation initialized. Draggable FAB & LeftControl active.",
    Duration = 3,
})
