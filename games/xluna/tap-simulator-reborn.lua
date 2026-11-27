-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ================================================================================
    TAP SIMULATOR REBORN - MASTER AUTOMATION SUITE (ClientOP)
    Target Game: [?] Tap Simulator REBORN (Roblox PlaceId: 72858262610964)
    Framework: WindUI (Enhanced Multi-Source Loader)
    Architecture: Sleitnick Comm + Replica Controller + Native Method Detours
    ================================================================================
]]

-- 1. ENVIRONMENT & SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- 2. NIL-SAFE EXECUTOR COMPATIBILITY LAYER
pcall(function()
    local oldCloneref = cloneref
    if oldCloneref then
        local safeCloneref = function(obj)
            if obj == nil then return nil end
            local ok, res = pcall(oldCloneref, obj)
            return ok and res or obj
        end
        if getgenv then
            getgenv().cloneref = safeCloneref
        else
            cloneref = safeCloneref
        end
    end
end)

-- 3. SLEITNICK COMM CLIENT SERVICES
local ClientComm = require(ReplicatedStorage.Packages.Comm).ClientComm

local TapComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "TapService"):BuildObject()
local RebirthComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "RebirthService"):BuildObject()
local EggComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "EggService"):BuildObject()
local PetComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "PetService"):BuildObject()
local MachineComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "MachineService"):BuildObject()
local PetIndexComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "PetIndexService"):BuildObject()
local QuestComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "QuestService"):BuildObject()
local OfflineRewardsComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "OfflineRewardsService"):BuildObject()
local ColosseumComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "ColosseumService"):BuildObject()
local MiningComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "MiningService"):BuildObject()
local ShrineComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "ShrineService"):BuildObject()
local EventWheelComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "EventWheelService"):BuildObject()
local GiveawayComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "GiveawayService"):BuildObject()
local UpgradeComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "UpgradeService"):BuildObject()
local DoubleJumpComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "DoubleJumpService"):BuildObject()
local TapChestComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "TapChestService"):BuildObject()
local ShinyStarComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "ShinyStarService"):BuildObject()
local LuckyDuckyComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "LuckyDuckyService"):BuildObject()
local CodeComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "CodeService"):BuildObject()
local SkillTreeComm = ClientComm.new(ReplicatedStorage.RemoteServices, false, "SkillTreeService"):BuildObject()

-- Controllers
local TapController = require(ReplicatedStorage.Controllers.Game.TapController)
local DataController = require(ReplicatedStorage.Controllers.Core.DataController)
local UpgradeController = require(ReplicatedStorage.Controllers.Game.UpgradeController)
local LuckyDuckyController = require(ReplicatedStorage.Controllers.Game.LuckyDuckyController)
local QuestController = require(ReplicatedStorage.Controllers.Quests.QuestController)

-- Shared Configs
local RebirthConfig = require(ReplicatedStorage.Shared.Progression.RebirthConfig)
local LaunchEggConfig = require(ReplicatedStorage.Shared.Pets.LaunchEggConfig)
local PetPower = require(ReplicatedStorage.Shared.Pets.PetPower)
local UpgradeConfig = require(ReplicatedStorage.Shared.Progression.UpgradeConfig)
local DoubleJumpConfig = require(ReplicatedStorage.Shared.Progression.DoubleJumpConfig)
local ShinyStarConfig = require(ReplicatedStorage.Shared.Game.ShinyStarConfig)
local BreakableConfig = require(ReplicatedStorage.Shared.Game.BreakableConfig)
local ShrineConfig = require(ReplicatedStorage.Shared.Game.ShrineConfig)
local SkillTreeConfig = require(ReplicatedStorage.Shared.Progression.SkillTreeConfig)
local SkillTreeFormula = require(ReplicatedStorage.Shared.Progression.SkillTreeFormula)
local SkillTreeRequirements = require(ReplicatedStorage.Shared.Progression.SkillTreeRequirements)

-- Format Number Utility
local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

-- 4. MASTER OPERATIONAL STATE
local State = {
    -- Auto Tap & Field
    AutoTap = false,
    TapCPS = 25,
    UncappedTap = false,
    NativeTap = false,
    AutoBreakables = false,
    
    -- Auto Rebirth
    AutoRebirth = false,
    RebirthMode = "Max Affordable",
    RebirthTier = 1,
    RebirthDelay = 0.5,
    
    -- Eggs & Pets
    AutoHatch = false,
    SelectedEgg = "Basic",
    HatchCount = 1,
    HatchTier = "Normal",
    AutoTeleportEgg = false,
    SkipHatchAnim = false,
    AutoEquipBest = false,
    EquipBestMode = "Clicks",
    EquipInterval = 5,
    AutoGoldenCraft = false,
    CraftingActive = false,
    
    -- Auto Delete Pets Engine
    AutoDelete = false,
    DeleteCommon = true,
    DeleteRare = true,
    DeleteEpic = false,
    DeleteLegendary = false,
    DeleteMythical = false,
    DeleteNormalOnly = true,
    ProtectGolden = true,
    ProtectRainbow = true,
    KeepTopBest = 10,
    DeleteInterval = 3,
    
    -- Progression & Quests
    AutoUpgrades = false,
    UpgradeTarget = "All",
    AutoDoubleJump = false,
    AutoClaimQuests = false,
    AutoOfflineRewards = false,
    
    -- Gem Upgrades (Skill Tree Engine)
    AutoGemUpgrades = false,
    GemUpgradeFocus = "All",
    GemUpgradeInterval = 2,
    
    -- Keybind & Profiles
    UIKeybind = Enum.KeyCode.RightControl,
    CurrentConfigName = "default",
    
    -- Minigames & Arena
    AutoColosseum = false,
    AutoMining = false,
    
    -- Events & Shrines
    AutoEventWheel = false,
    AutoShrine = false,
    ShrineBlessing = "Luck",
    AutoGiveaway = false,
    AutoLuckyDucky = false,
    AutoShinyStars = false,
    AutoTapChests = false,
    
    -- Character & QoL
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false,
}

-- 5. UTILITY FUNCTIONS & TELEPORTATION
local function safeTeleport(cframe)
    local char = LocalPlayer.Character or Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or HumanoidRootPart)
    if hrp and hrp:IsA("BasePart") then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = cframe
    end
end

local function getEggStandPosition(eggName)
    local eggsFolder = workspace:FindFirstChild("Eggs")
    if eggsFolder then
        local eggModel = eggsFolder:FindFirstChild(eggName)
        if eggModel then
            return eggModel:GetPivot()
        end
    end
    local fallbackCoords = {
        ["Basic"] = CFrame.new(5.89, -511.31, -1832.66),
        ["Spotted"] = CFrame.new(-4.90, -511.23, -1821.81),
        ["Spiked"] = CFrame.new(-23.03, -512.78, -1707.15),
        ["Sky"] = CFrame.new(-88.32, -47.52, -1904.07),
        ["Nimbus"] = CFrame.new(-96.63, -47.75, -1891.44),
        ["Forest"] = CFrame.new(-4.90, -511.23, -1821.81),
        ["Snowman"] = CFrame.new(-38.8, 871.3, -1727.8),
        ["Pumpkin"] = CFrame.new(-38.8, 871.3, -1727.8),
        ["Mushroom"] = CFrame.new(-200.7, 1999.5, -1939.2),
        ["Mycelium"] = CFrame.new(-200.7, 1999.5, -1939.2),
        ["Cactus"] = CFrame.new(-180, 3615.9, -1819.3),
        ["Crystal"] = CFrame.new(58.6, 5437.5, -2002.8),
        ["Geode"] = CFrame.new(58.6, 5437.5, -2002.8),
        ["Void"] = CFrame.new(150.4, 7667.5, -1985.5),
        ["Volcanic"] = CFrame.new(-149, 11060.1, -1997.7),
        ["Draconic"] = CFrame.new(-149, 11060.1, -1997.7),
        ["Heaven"] = CFrame.new(-174, 15333, -1970)
    }
    return fallbackCoords[eggName] or CFrame.new(5.89, -511.31, -1832.66)
end

-- 5.1 HATCH ANIMATION SUPPRESSION DETOURS
pcall(function()
    local HatchRenderer = require(ReplicatedStorage.Modules.Client.Pets.HatchRenderer)
    if HatchRenderer and HatchRenderer.Play then
        local oldPlay = HatchRenderer.Play
        HatchRenderer.Play = function(self, a2, a3, a4, a5)
            if State.SkipHatchAnim then
                pcall(function() if self.Cancel then self:Cancel() end end)
                if a4 then pcall(a4) end
                return
            end
            return oldPlay(self, a2, a3, a4, a5)
        end
    end
end)

pcall(function()
    local SecretHatchRenderer = require(ReplicatedStorage.Modules.Client.Pets.SecretHatchRenderer)
    if SecretHatchRenderer and SecretHatchRenderer.Play then
        local oldSecretPlay = SecretHatchRenderer.Play
        SecretHatchRenderer.Play = function(self, a2, a3, a4)
            if State.SkipHatchAnim then
                pcall(function() if self.Cancel then self:Cancel() end end)
                return
            end
            return oldSecretPlay(self, a2, a3, a4)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if State.SkipHatchAnim then
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            for _, gName in ipairs({"HatchScreen", "Hatching", "Egg Opening Stuff"}) do
                local g = pgui:FindFirstChild(gName)
                if g and g.Enabled then
                    g.Enabled = false
                end
            end
        end
    end
end)

-- 6. WINDUI INITIALIZATION (HIGH AVAILABILITY LOADER)
local WindUI = nil
local function loadWindUI()
    if _G.WindUI then return _G.WindUI end
    local sources = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://tree-hub.vercel.app/api/UI/WindUI"
    }
    for _, url in ipairs(sources) do
        local ok, content = pcall(game.HttpGet, game, url)
        if ok and content and #content > 1000 then
            local fn = loadstring(content)
            if fn then
                local res = fn()
                if res then return res end
            end
        end
    end
    return nil
end

WindUI = loadWindUI()
if not WindUI then
    warn("[ClientOP] Failed to initialize WindUI framework.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "â¡ Tap Simulator REBORN - Tactical Hub",
    Icon = "zap",
    Folder = "TapSimulatorRebornConfig",
    Size = UDim2.fromOffset(640, 530),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

Window.IsPC = false
Window.IsOpenButtonEnabled = true
pcall(function()
    if Window.EditOpenButton then
        Window:EditOpenButton({
            Title = "Tap Reborn OP",
            Icon = "zap",
            CornerRadius = UDim.new(0, 10),
            StrokeThickness = 2,
            Color = ColorSequence.new(Color3.fromRGB(0, 220, 255), Color3.fromRGB(150, 0, 255))
        })
    end
end)

-- ZERO AI WATERMARK SANITIZER
pcall(function()
    if Window.SetAuthor then
        pcall(function() Window:SetAuthor("") end)
    end
    task.spawn(function()
        for i = 1, 10 do
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            local cg = game:GetService("CoreGui")
            local gh = (gethui and gethui())
            for _, container in ipairs({ pgui, cg, gh }) do
                if container then
                    for _, desc in ipairs(container:GetDescendants()) do
                        if desc:IsA("TextLabel") then
                            if desc.Name == "Author" or string.find(desc.Text, "Antigravity") or string.find(desc.Text, "AI Assistant") then
                                desc.Text = ""
                                desc.Visible = false
                                pcall(function() desc:Destroy() end)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

-- INDEPENDENT DRAGGABLE FLOATING ACTION BUTTON (Universal Mobile & PC Access)
local floatGuiParent = (gethui and gethui()) or game:GetService("CoreGui") or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
pcall(function()
    if floatGuiParent then
        local old = floatGuiParent:FindFirstChild("ClientOP_FloatingBtn")
        if old then old:Destroy() end
    end
    local coreOld = game:GetService("CoreGui"):FindFirstChild("ClientOP_FloatingBtn")
    if coreOld then coreOld:Destroy() end
end)

local FloatScreenGui = Instance.new("ScreenGui")
FloatScreenGui.Name = "ClientOP_FloatingBtn"
FloatScreenGui.ResetOnSpawn = false
FloatScreenGui.DisplayOrder = 999999
FloatScreenGui.IgnoreGuiInset = true
FloatScreenGui.Parent = floatGuiParent

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatButton"
FloatBtn.Size = UDim2.fromOffset(50, 50)
FloatBtn.Position = UDim2.new(0, 20, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Text = ""
FloatBtn.AutoButtonColor = false
FloatBtn.Active = true
FloatBtn.Parent = FloatScreenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = FloatBtn

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 2
floatStroke.Color = Color3.fromRGB(0, 220, 255)
floatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
floatStroke.Parent = FloatBtn

local floatGrad = Instance.new("UIGradient")
floatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
})
floatGrad.Rotation = 45
floatGrad.Parent = floatStroke

local floatIcon = Instance.new("ImageLabel")
floatIcon.Name = "Icon"
floatIcon.Size = UDim2.fromOffset(28, 28)
floatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
floatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
floatIcon.BackgroundTransparency = 1
floatIcon.Image = "rbxassetid://140045179823870"
floatIcon.ImageColor3 = Color3.fromRGB(0, 220, 255)
floatIcon.Parent = FloatBtn

local function toggleMainWindow()
    pcall(function()
        if Window.Toggle then
            Window:Toggle()
        else
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            local cg = game:GetService("CoreGui")
            local gui = (pgui and pgui:FindFirstChild("WindUI")) or (cg and cg:FindFirstChild("WindUI"))
            if gui then gui.Enabled = not gui.Enabled end
        end
    end)
end

local dragging = false
local dragStart = Vector3.zero
local startPos = FloatBtn.Position
local wasDragged = false

FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        wasDragged = false
        dragStart = input.Position
        startPos = FloatBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then
            wasDragged = true
        end
        FloatBtn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

FloatBtn.Activated:Connect(function()
    if not wasDragged then
        toggleMainWindow()
    end
    wasDragged = false
end)

FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.15), { Size = UDim2.fromOffset(54, 54) }):Play()
end)

FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.15), { Size = UDim2.fromOffset(50, 50) }):Play()
end)

-- Global Show/Hide UI Keybind
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == (State.UIKeybind or Enum.KeyCode.RightControl) then
        toggleMainWindow()
    end
end)

-- 7. TABS CONFIGURATION (9 MASTER PILLARS)
local TabFarm = Window:Tab({ Title = "â¡ Auto Tap", Icon = "mouse-pointer-click" })
local TabRebirth = Window:Tab({ Title = "ð Auto Rebirth", Icon = "refresh-cw" })
local TabEggs = Window:Tab({ Title = "ð¥ Eggs & Pets", Icon = "egg" })
local TabProgress = Window:Tab({ Title = "ð Progression", Icon = "trending-up" })
local TabArena = Window:Tab({ Title = "âï¸ Minigames", Icon = "swords" })
local TabEvents = Window:Tab({ Title = "ð World Events", Icon = "sparkles" })
local TabTeleports = Window:Tab({ Title = "ð Teleports", Icon = "map-pin" })
local TabQoL = Window:Tab({ Title = "âï¸ Player & QoL", Icon = "sliders" })
local TabConfigs = Window:Tab({ Title = "ð¾ Configs", Icon = "folder" })

-- ============================================================================
-- UI COMPONENT REGISTRY & RESTORATION ENGINE
-- ============================================================================
local UIElements = {}

local function restoreUIComponent(key, value)
    local comp = UIElements[key]
    if not comp then return end
    pcall(function()
        if type(value) == "boolean" then
            if type(comp.Set) == "function" then
                comp:Set(value)
            end
        elseif type(value) == "number" then
            if key == "HatchCount" then
                if type(comp.Select) == "function" then
                    comp:Select(tostring(value) .. "x")
                end
            elseif key == "RebirthTier" then
                if type(comp.Select) == "function" then
                    comp:Select("Tier " .. tostring(value))
                end
            else
                if type(comp.Set) == "function" then
                    comp:Set(value)
                end
            end
        elseif type(value) == "string" then
            if key == "HatchCount" and not value:find("x$") then
                if type(comp.Select) == "function" then
                    comp:Select(value .. "x")
                end
            elseif key == "RebirthTier" and not value:find("^Tier ") then
                if type(comp.Select) == "function" then
                    comp:Select("Tier " .. value)
                end
            elseif type(comp.Select) == "function" then
                comp:Select(value)
            elseif type(comp.Set) == "function" then
                comp:Set(value)
            end
        end
    end)
end

-- ============================================================================
-- TAB 1: AUTO TAP & FIELD HARVESTER
-- ============================================================================
TabFarm:Section({ Title = "â¡ Ultra-Fast Auto Tap Engine" })

local StatsPara = TabFarm:Paragraph({
    Title = "ð Live Player Statistics",
    Desc = "Loading data..."
})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local data = DataController:GetReplica().Data
            local coins = data.Currencies.Coins or 0
            local gems = data.Currencies.Gems or 0
            local taps = data.Statistics.ActualTaps or 0
            local rebirths = data.Statistics.Rebirths or 0
            StatsPara:SetDesc(string.format("ð° Coins: %s | ð Gems: %s\nð Total Taps: %s | ð Rebirths: %s", 
                tostring(coins), tostring(gems), tostring(taps), tostring(rebirths)))
        end)
    end
end)

UIElements["AutoTap"] = TabFarm:Toggle({
    Title = "â¡ Enable Auto Tap",
    Desc = "Executes rapid taps directly synchronized with the server",
    Value = State.AutoTap,
    Callback = function(v) State.AutoTap = v end
})

UIElements["TapCPS"] = TabFarm:Slider({
    Title = "â¡ Tap Speed (CPS)",
    Desc = "Target clicks per second (5 - 50 CPS)",
    Value = { Min = 5, Max = 50, Default = State.TapCPS },
    Step = 1,
    Callback = function(v) State.TapCPS = v end
})

UIElements["UncappedTap"] = TabFarm:Toggle({
    Title = "ð¥ Uncapped Heartbeat Speed",
    Desc = "Taps on every game engine frame for extreme speed",
    Value = State.UncappedTap,
    Callback = function(v) State.UncappedTap = v end
})

UIElements["NativeTap"] = TabFarm:Toggle({
    Title = "ð¯ Native Client Emulation",
    Desc = "Calls TapController directly for 100% native perk/critical sync",
    Value = State.NativeTap,
    Callback = function(v) State.NativeTap = v end
})

UIElements["AutoBreakables"] = TabFarm:Toggle({
    Title = "ð¥ Auto Hit World Breakables",
    Desc = "Directs clicks and pet attacks towards nearest crates, chests, and meteors",
    Value = State.AutoBreakables,
    Callback = function(v) State.AutoBreakables = v end
})

-- Auto Tap Loop
task.spawn(function()
    local lastTap = 0
    while true do
        if State.AutoTap then
            if State.UncappedTap then
                pcall(function()
                    if State.NativeTap then
                        TapController:Tap()
                    else
                        TapComm.TapRequested:Fire({Auto = false, ClientSequence = 1, Source = "screen"})
                    end
                end)
                RunService.Heartbeat:Wait()
            else
                local now = os.clock()
                local interval = 1 / math.clamp(State.TapCPS, 1, 50)
                if now - lastTap >= interval then
                    lastTap = now
                    pcall(function()
                        if State.NativeTap then
                            TapController:Tap()
                        else
                            TapComm.TapRequested:Fire({Auto = false, ClientSequence = 1, Source = "screen"})
                        end
                    end)
                end
                task.wait(0.005)
            end
        else
            task.wait(0.1)
        end
    end
end)

-- Breakables Targeter Loop
task.spawn(function()
    while true do
        if State.AutoBreakables then
            pcall(function()
                local breakables = CollectionService:GetTagged(BreakableConfig.Tag)
                if #breakables > 0 and HumanoidRootPart then
                    local nearest, minDist = nil, 60
                    for _, b in ipairs(breakables) do
                        local pos = b:GetPivot().Position
                        local dist = (HumanoidRootPart.Position - pos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = b
                        end
                    end
                    if nearest then
                        TapController:Tap()
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- ============================================================================
-- TAB 2: AUTONOMOUS REBIRTH ENGINE
-- ============================================================================
TabRebirth:Section({ Title = "ð Smart Rebirth Automation" })

local RebirthPara = TabRebirth:Paragraph({
    Title = "ð Rebirth Status",
    Desc = "Calculating..."
})

UIElements["AutoRebirth"] = TabRebirth:Toggle({
    Title = "ð Enable Auto Rebirth",
    Desc = "Automatically purchases rebirths upon reaching coin requirement",
    Value = State.AutoRebirth,
    Callback = function(v) State.AutoRebirth = v end
})

UIElements["RebirthMode"] = TabRebirth:Dropdown({
    Title = "ð¯ Rebirth Mode",
    Desc = "Highest affordable tier or targeted fixed tier",
    Values = { "Max Affordable", "Fixed Tier" },
    Value = State.RebirthMode,
    Callback = function(v) State.RebirthMode = v end
})

local tierOptions = {}
for i = 1, 20 do table.insert(tierOptions, "Tier " .. tostring(i)) end

UIElements["RebirthTier"] = TabRebirth:Dropdown({
    Title = "ð¢ Target Rebirth Tier",
    Desc = "Used when Rebirth Mode is 'Fixed Tier'",
    Values = tierOptions,
    Value = "Tier " .. tostring(State.RebirthTier),
    Callback = function(v)
        local num = tonumber(string.match(v, "%d+"))
        if num then State.RebirthTier = num end
    end
})

UIElements["RebirthDelay"] = TabRebirth:Slider({
    Title = "â±ï¸ Rebirth Check Interval",
    Desc = "Delay in seconds between rebirth checks",
    Value = { Min = 0.2, Max = 3.0, Default = State.RebirthDelay },
    Step = 0.1,
    Callback = function(v) State.RebirthDelay = v end
})

-- Auto Rebirth Loop
task.spawn(function()
    while true do
        if State.AutoRebirth then
            pcall(function()
                local data = DataController:GetReplica().Data
                local coins = data.Currencies.Coins or 0
                local currentRebirths = data.Statistics.Rebirths or 0
                
                if State.RebirthMode == "Max Affordable" then
                    local targetIndex = 1
                    for i = 1, 20 do
                        local amt = RebirthConfig.GetAmountFromIndex(i)
                        local price = RebirthConfig.GetPrice(amt, currentRebirths, LocalPlayer)
                        if coins >= price then
                            targetIndex = i
                        else
                            break
                        end
                    end
                    local reqAmt = RebirthConfig.GetAmountFromIndex(targetIndex)
                    local reqPrice = RebirthConfig.GetPrice(reqAmt, currentRebirths, LocalPlayer)
                    if coins >= reqPrice then
                        RebirthComm.RebirthRequested:Fire({Index = targetIndex})
                    end
                else
                    local reqAmt = RebirthConfig.GetAmountFromIndex(State.RebirthTier)
                    local reqPrice = RebirthConfig.GetPrice(reqAmt, currentRebirths, LocalPlayer)
                    if coins >= reqPrice then
                        RebirthComm.RebirthRequested:Fire({Index = State.RebirthTier})
                    end
                end
            end)
            task.wait(State.RebirthDelay)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local data = DataController:GetReplica().Data
            local coins = data.Currencies.Coins or 0
            local currentRebirths = data.Statistics.Rebirths or 0
            local maxTier = 1
            for i = 1, 20 do
                local amt = RebirthConfig.GetAmountFromIndex(i)
                local price = RebirthConfig.GetPrice(amt, currentRebirths, LocalPlayer)
                if coins >= price then maxTier = i else break end
            end
            local nextAmt = RebirthConfig.GetAmountFromIndex(maxTier + 1)
            local nextPrice = RebirthConfig.GetPrice(nextAmt, currentRebirths, LocalPlayer)
            RebirthPara:SetDesc(string.format("Current Rebirths: %s\nHighest Affordable: Tier %d (+%s)\nNext Tier %d Cost: %s coins",
                tostring(currentRebirths), maxTier, tostring(RebirthConfig.GetAmountFromIndex(maxTier)), maxTier + 1, tostring(nextPrice)))
        end)
    end
end)

-- ============================================================================
-- TAB 3: COMPLETE EGGS & PET FACTORY
-- ============================================================================
TabEggs:Section({ Title = "ð¥ Egg Hatching & Auto Farm" })

local eggList = {
    "Basic", "Spotted", "Spiked", "Sky", "Nimbus", "Forest", "Snowman",
    "Pumpkin", "Mushroom", "Mycelium", "Cactus", "Crystal", "Geode",
    "Void", "Volcanic", "Draconic", "Heaven"
}

UIElements["SelectedEgg"] = TabEggs:Dropdown({
    Title = "ð¥ Select Target Egg",
    Desc = "Choose which egg to hatch automatically",
    Values = eggList,
    Value = State.SelectedEgg,
    Callback = function(v) State.SelectedEgg = v end
})

UIElements["HatchCount"] = TabEggs:Dropdown({
    Title = "ð¦ Hatch Count",
    Desc = "Number of eggs to open per request",
    Values = { "1x", "3x" },
    Value = tostring(State.HatchCount) .. "x",
    Callback = function(v) State.HatchCount = (v == "3x") and 3 or 1 end
})

UIElements["AutoTeleportEgg"] = TabEggs:Toggle({
    Title = "ð Auto Teleport to Egg Stand",
    Desc = "Positions character next to stand to satisfy server proximity validation",
    Value = State.AutoTeleportEgg,
    Callback = function(v) State.AutoTeleportEgg = v end
})

UIElements["AutoHatch"] = TabEggs:Toggle({
    Title = "ð¥ Enable Auto Hatch",
    Desc = "Continuously opens the selected egg",
    Value = State.AutoHatch,
    Callback = function(v)
        State.AutoHatch = v
        if v and State.AutoTeleportEgg then
            local cf = getEggStandPosition(State.SelectedEgg)
            safeTeleport(cf + Vector3.new(0, 3, 5))
        end
    end
})

UIElements["HatchTier"] = TabEggs:Dropdown({
    Title = "ð Target Buy / Hatch Tier",
    Desc = "Target hatch variant (Normal, Golden, Diamond, Rainbow)",
    Values = { "Normal", "Golden", "Diamond", "Rainbow" },
    Value = State.HatchTier,
    Callback = function(v) State.HatchTier = v end
})

UIElements["SkipHatchAnim"] = TabEggs:Toggle({
    Title = "â¡ Hide / Skip Hatch Animation",
    Desc = "Completely disables hatch screens, camera locks and reveal cutscenes",
    Value = State.SkipHatchAnim,
    Callback = function(v) State.SkipHatchAnim = v end
})

-- Auto Hatch Loop
task.spawn(function()
    local hatchSeq = 1
    while true do
        if State.AutoHatch then
            pcall(function()
                if State.AutoTeleportEgg and not State.CraftingActive then
                    local standCF = getEggStandPosition(State.SelectedEgg)
                    if HumanoidRootPart and (HumanoidRootPart.Position - standCF.Position).Magnitude > 20 then
                        safeTeleport(standCF + Vector3.new(0, 3, 5))
                        task.wait(0.3)
                    end
                end
                hatchSeq = hatchSeq + 1
                local isGodly = (State.HatchTier == "Godly" or State.HatchTier == "Rainbow") and true or nil
                EggComm.EggHatchRequested:Fire({
                    Egg = State.SelectedEgg,
                    Count = State.HatchCount,
                    Auto = false,
                    Tier = State.HatchTier,
                    Godly = isGodly,
                    Seq = hatchSeq
                })
            end)
            task.wait(0.4)
        else
            task.wait(0.5)
        end
    end
end)

TabEggs:Section({ Title = "ð¾ Evolution & Pet Team Management" })

UIElements["EquipBestMode"] = TabEggs:Dropdown({
    Title = "ð¯ Auto Equip Priority",
    Desc = "Priority metric for Best Pets calculation",
    Values = { "Clicks", "Gems", "Luck" },
    Value = State.EquipBestMode,
    Callback = function(v) State.EquipBestMode = v end
})

UIElements["AutoEquipBest"] = TabEggs:Toggle({
    Title = "ð Auto Equip Best Pets",
    Desc = "Continuously equips the strongest pets in inventory",
    Value = State.AutoEquipBest,
    Callback = function(v) State.AutoEquipBest = v end
})

TabEggs:Button({
    Title = "â¡ Instant Equip Best Now",
    Desc = "Forces an immediate team equip",
    Callback = function()
        pcall(function()
            PetComm.PetActionRequested:Fire({ Action = "EquipBest", Mode = State.EquipBestMode })
            WindUI:Notify({ Title = "Pets", Content = "Equipped best pets by " .. State.EquipBestMode, Duration = 2.5 })
        end)
    end
})

TabEggs:Button({
    Title = "â Unequip All Pets",
    Desc = "Unequips all currently active pets",
    Callback = function()
        pcall(function()
            PetComm.PetActionRequested:Fire({ Action = "UnequipAll" })
            WindUI:Notify({ Title = "Pets", Content = "Unequipped all pets", Duration = 2.5 })
        end)
    end
})

local isCraftingGolden = false

local function getGoldenMachineCFrame()
    local char = LocalPlayer.Character or Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or HumanoidRootPart)
    local myPos = hrp and hrp.Position or Vector3.new(0, 0, 0)
    
    local candidates = {}
    
    -- 1. Check InteractionPoints with tag
    for _, pt in ipairs(CollectionService:GetTagged("InteractionPoint")) do
        if pt.Name == "Golden" or string.find(string.lower(pt.Name), "golden") then
            local cf = pt:IsA("BasePart") and pt.CFrame or pt:GetPivot()
            table.insert(candidates, { Object = pt, CF = cf, Dist = (myPos - cf.Position).Magnitude })
        end
    end
    
    -- 2. Check workspace.InteractionPoints
    local ipFolder = workspace:FindFirstChild("InteractionPoints")
    if ipFolder then
        local g = ipFolder:FindFirstChild("Golden")
        if g then
            local cf = g:IsA("BasePart") and g.CFrame or g:GetPivot()
            table.insert(candidates, { Object = g, CF = cf, Dist = (myPos - cf.Position).Magnitude })
        end
    end
    
    -- 3. Check workspace.GoldenMachine
    local gmFolder = workspace:FindFirstChild("GoldenMachine")
    if gmFolder then
        local cf = gmFolder:IsA("BasePart") and gmFolder.CFrame or gmFolder:GetPivot()
        table.insert(candidates, { Object = gmFolder, CF = cf, Dist = (myPos - cf.Position).Magnitude })
    end
    
    -- 4. Known verified locations fallback
    table.insert(candidates, { CF = CFrame.new(14.47, -515.97, -1885.65), Dist = (myPos - Vector3.new(14.47, -515.97, -1885.65)).Magnitude })
    table.insert(candidates, { CF = CFrame.new(-110.18, -50.44, -1854.49), Dist = (myPos - Vector3.new(-110.18, -50.44, -1854.49)).Magnitude })
    
    -- Sort by distance to player to choose the nearest Golden Machine
    table.sort(candidates, function(a, b) return a.Dist < b.Dist end)
    
    return candidates[1].CF
end

local function performGoldenCraftAll(isManual)
    if isCraftingGolden then return end
    isCraftingGolden = true
    State.CraftingActive = true
    
    task.spawn(function()
        local success, err = pcall(function()
            local char = LocalPlayer.Character or Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or HumanoidRootPart)
            if not hrp then return end
            
            local replica = DataController:GetReplica()
            local data = replica and replica.Data
            if not data or not data.Pets or not data.Pets.Owned then return end
            
            local mastery = data.Mastery and data.Mastery.Goldens or {}
            local masteryLv = tonumber(mastery.Level) or 0
            local canCraftAll = masteryLv >= 4
            
            local speciesGroups = {}
            for id, pet in pairs(data.Pets.Owned) do
                if pet.Tier == "Normal" and pet.Locked ~= true and not pet.Frozen then
                    if not speciesGroups[pet.Name] then
                        speciesGroups[pet.Name] = {}
                    end
                    table.insert(speciesGroups[pet.Name], id)
                end
            end
            
            local batches = {}
            for speciesName, petIds in pairs(speciesGroups) do
                local batchCount = math.floor(#petIds / 6)
                for b = 1, batchCount do
                    local chunk = {}
                    for i = 1, 6 do
                        table.insert(chunk, petIds[(b - 1) * 6 + i])
                    end
                    table.insert(batches, { Name = speciesName, Ids = chunk })
                end
            end
            
            if #batches == 0 and not canCraftAll then
                if isManual then
                    WindUI:Notify({ Title = "Golden Machine", Content = "No normal pets with 6+ copies available to craft.", Duration = 3 })
                end
                return
            end
            
            local goldenCF = getGoldenMachineCFrame()
            local origCF = hrp.CFrame
            local dist = (origCF.Position - goldenCF.Position).Magnitude
            
            if dist > 8 then
                safeTeleport(goldenCF + Vector3.new(0, 1.2, 0))
                task.wait(0.6) -- Allow server physics replication
            end
            
            local craftedCount = 0
            if canCraftAll then
                MachineComm.MachineCraftRequested:Fire({ Action = "CraftAll", Machine = "Golden", Names = nil })
                craftedCount = #batches
                task.wait(0.6)
            else
                for _, batch in ipairs(batches) do
                    MachineComm.MachineCraftRequested:Fire({ Action = "Craft", Machine = "Golden", PetIds = batch.Ids })
                    craftedCount = craftedCount + 1
                    task.wait(0.4)
                end
            end
            
            task.wait(0.5)
            
            if dist > 8 then
                safeTeleport(origCF)
                task.wait(0.2)
            end
            
            if isManual then
                WindUI:Notify({
                    Title = "Golden Machine",
                    Content = string.format("Successfully crafted %d Golden pet batch(es)!", craftedCount),
                    Duration = 3.5
                })
            end
        end)
        if not success and err then
            warn("[ClientOP] performGoldenCraftAll error: " .. tostring(err))
        end
        isCraftingGolden = false
        State.CraftingActive = false
    end)
end

TabEggs:Button({
    Title = "â¨ Craft All Golden Pets Now",
    Desc = "Instantly crafts all eligible pets into Golden tier (Auto-proximity verify)",
    Callback = function()
        performGoldenCraftAll(true)
    end
})

UIElements["AutoGoldenCraft"] = TabEggs:Toggle({
    Title = "â¨ Auto Craft Golden Pets",
    Desc = "Periodically crafts all Golden pets with server proximity verification",
    Value = State.AutoGoldenCraft,
    Callback = function(v) State.AutoGoldenCraft = v end
})

TabEggs:Button({
    Title = "ð Claim All Pet Index Rewards",
    Desc = "Claims all uncollected rewards in the Pet Index",
    Callback = function()
        pcall(function()
            PetIndexComm.ClaimAllRequested:Fire()
            WindUI:Notify({ Title = "Pet Index", Content = "Claimed all Pet Index rewards!", Duration = 3 })
        end)
    end
})

-- ============================================================================
-- PET AUTO DELETE ENGINE & TIER MANAGEMENT
-- ============================================================================
local function executePetCleanup(isManual)
    local data = DataController:GetReplica().Data
    if not data or not data.Pets or not data.Pets.Owned then return 0 end
    
    local powers = PetPower.GetOwnedPowers(data.Pets.Owned)
    local petList = {}
    for id, pet in pairs(data.Pets.Owned) do
        table.insert(petList, {
            id = id,
            power = powers[id] or 0,
            name = pet.Name,
            rarity = pet.Rarity or "Common",
            tier = pet.Tier or "Normal",
            locked = pet.Locked == true
        })
    end
    
    table.sort(petList, function(a, b) return a.power > b.power end)
    
    local protected = {}
    for _, eqId in ipairs(data.Pets.Equipped or {}) do protected[eqId] = true end
    if data.PetTeams then
        for _, team in pairs(data.PetTeams) do
            if type(team) == "table" and team.Pets then
                for _, tId in ipairs(team.Pets) do protected[tId] = true end
            end
        end
    end
    
    local topN = math.clamp(State.KeepTopBest or 10, 0, #petList)
    for i = 1, topN do
        if petList[i] then protected[petList[i].id] = true end
    end
    
    local toDelete = {}
    for _, p in ipairs(petList) do
        local id = p.id
        if not protected[id] and not p.locked then
            local isSecret = string.find(string.lower(p.rarity), "secret") ~= nil
            if not isSecret then
                local tierAllowed = true
                if State.ProtectGolden and p.tier == "Golden" then tierAllowed = false end
                if State.ProtectRainbow and (p.tier == "Shiny" or p.tier == "Diamond") then tierAllowed = false end
                if State.DeleteNormalOnly and p.tier ~= "Normal" then tierAllowed = false end
                
                if tierAllowed then
                    local r = p.rarity
                    local shouldDelete = false
                    if (r == "Common" or r == "Basic") and State.DeleteCommon then shouldDelete = true
                    elseif r == "Rare" and State.DeleteRare then shouldDelete = true
                    elseif r == "Epic" and State.DeleteEpic then shouldDelete = true
                    elseif r == "Legendary" and State.DeleteLegendary then shouldDelete = true
                    elseif r == "Mythical" and State.DeleteMythical then shouldDelete = true end
                    
                    if shouldDelete then table.insert(toDelete, id) end
                end
            end
        end
    end
    
    if #toDelete > 0 then
        local chunkSize = 200
        for i = 1, #toDelete, chunkSize do
            local chunk = {}
            for j = i, math.min(i + chunkSize - 1, #toDelete) do
                table.insert(chunk, toDelete[j])
            end
            pcall(function()
                PetComm.PetActionRequested:Fire({
                    Action = "Delete",
                    PetIds = chunk,
                    Batch = 1
                })
            end)
            if #toDelete > chunkSize then task.wait(0.25) end
        end
        if isManual then
            WindUI:Notify({ Title = "Pet Cleanup", Content = string.format("Deleted %d unused pets!", #toDelete), Duration = 3 })
        end
    elseif isManual then
        WindUI:Notify({ Title = "Pet Cleanup", Content = "No deletable pets found (All protected).", Duration = 2.5 })
    end
    return #toDelete
end

TabEggs:Section({ Title = "ðï¸ Smart Auto Delete Pets (By Tier / Rarity)" })

local PetStatsPara = TabEggs:Paragraph({
    Title = "ð Pet Inventory Stats",
    Desc = "Calculating inventory counts..."
})

UIElements["AutoDelete"] = TabEggs:Toggle({
    Title = "ðï¸ Enable Auto Delete Unused Pets",
    Desc = "Periodically deletes unwanted unequipped pets based on tier/rarity filters",
    Value = State.AutoDelete,
    Callback = function(v) State.AutoDelete = v end
})

UIElements["KeepTopBest"] = TabEggs:Slider({
    Title = "ð Keep Top N Best Pets",
    Desc = "Never deletes your highest power pets, regardless of rarity/tier",
    Value = { Min = 0, Max = 50, Default = State.KeepTopBest },
    Step = 1,
    Callback = function(v) State.KeepTopBest = v end
})

UIElements["DeleteInterval"] = TabEggs:Slider({
    Title = "â±ï¸ Delete Sweep Interval",
    Desc = "Delay in seconds between auto-delete sweeps",
    Value = { Min = 1, Max = 10, Default = State.DeleteInterval },
    Step = 1,
    Callback = function(v) State.DeleteInterval = v end
})

UIElements["DeleteCommon"] = TabEggs:Toggle({
    Title = "ðï¸ Delete Common / Basic Pets",
    Desc = "Deletes normal Common / Basic pets",
    Value = State.DeleteCommon,
    Callback = function(v) State.DeleteCommon = v end
})

UIElements["DeleteRare"] = TabEggs:Toggle({
    Title = "ðï¸ Delete Rare Pets",
    Desc = "Deletes normal Rare pets",
    Value = State.DeleteRare,
    Callback = function(v) State.DeleteRare = v end
})

UIElements["DeleteEpic"] = TabEggs:Toggle({
    Title = "ðï¸ Delete Epic Pets",
    Desc = "Deletes normal Epic pets",
    Value = State.DeleteEpic,
    Callback = function(v) State.DeleteEpic = v end
})

UIElements["DeleteLegendary"] = TabEggs:Toggle({
    Title = "ðï¸ Delete Legendary Pets",
    Desc = "Deletes normal Legendary pets",
    Value = State.DeleteLegendary,
    Callback = function(v) State.DeleteLegendary = v end
})

UIElements["DeleteMythical"] = TabEggs:Toggle({
    Title = "ðï¸ Delete Mythical Pets",
    Desc = "Deletes normal Mythical pets",
    Value = State.DeleteMythical,
    Callback = function(v) State.DeleteMythical = v end
})

UIElements["DeleteNormalOnly"] = TabEggs:Toggle({
    Title = "ð¡ï¸ Normal Tier Only (Protect Evolved)",
    Desc = "Only deletes Normal tier pets, preserves all evolved variants",
    Value = State.DeleteNormalOnly,
    Callback = function(v) State.DeleteNormalOnly = v end
})

UIElements["ProtectGolden"] = TabEggs:Toggle({
    Title = "ð¡ï¸ Protect Golden Pets",
    Desc = "Never deletes Golden tier pets",
    Value = State.ProtectGolden,
    Callback = function(v) State.ProtectGolden = v end
})

UIElements["ProtectRainbow"] = TabEggs:Toggle({
    Title = "ð¡ï¸ Protect Rainbow / Shiny Pets",
    Desc = "Never deletes Shiny or Rainbow tier pets",
    Value = State.ProtectRainbow,
    Callback = function(v) State.ProtectRainbow = v end
})

TabEggs:Button({
    Title = "ðï¸ Clean Up & Delete Unused Pets Now",
    Desc = "Forces an immediate sweep and deletion of all unequipped matching pets",
    Callback = function()
        executePetCleanup(true)
    end
})

-- Auto Delete Background Loop
task.spawn(function()
    while true do
        if State.AutoDelete then
            pcall(executePetCleanup, false)
            task.wait(State.DeleteInterval or 3)
        else
            task.wait(1)
        end
    end
end)

-- Pet Inventory Stats Background Loop
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local data = DataController:GetReplica().Data
            if data and data.Pets and data.Pets.Owned then
                local totalOwned = 0
                for _ in pairs(data.Pets.Owned) do totalOwned = totalOwned + 1 end
                local totalEquipped = #(data.Pets.Equipped or {})
                PetStatsPara:SetDesc(string.format("ð¦ Total Owned: %d | â¡ Equipped: %d | ð Protected Top: %d", 
                    totalOwned, totalEquipped, State.KeepTopBest or 10))
            end
        end)
    end
end)

-- Auto Equip & Golden Loops
task.spawn(function()
    while true do
        if State.AutoEquipBest then
            pcall(function()
                PetComm.PetActionRequested:Fire({ Action = "EquipBest", Mode = State.EquipBestMode })
            end)
            task.wait(State.EquipInterval)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoGoldenCraft then
            pcall(function()
                performGoldenCraftAll(false)
            end)
            task.wait(15)
        else
            task.wait(2)
        end
    end
end)

-- ============================================================================
-- TAB 4: PROGRESSION, SKILLS & QUESTS
-- ============================================================================
TabProgress:Section({ Title = "ð Automatic Upgrades & Skills" })

UIElements["AutoUpgrades"] = TabProgress:Toggle({
    Title = "ð Enable Auto Buy Upgrades",
    Desc = "Automatically buys affordable upgrades when unlocked",
    Value = State.AutoUpgrades,
    Callback = function(v) State.AutoUpgrades = v end
})

UIElements["UpgradeTarget"] = TabProgress:Dropdown({
    Title = "ð¯ Target Upgrade Category",
    Desc = "Filter which upgrade to prioritize",
    Values = { "All", "ClickMultiplier", "CriticalChance", "AutoClickerSpeed", "HatchSpeed", "Teleport" },
    Value = State.UpgradeTarget,
    Callback = function(v) State.UpgradeTarget = v end
})

UIElements["AutoDoubleJump"] = TabProgress:Toggle({
    Title = "ð¦ Auto Buy Double Jump",
    Desc = "Automatically unlocks additional double jump abilities",
    Value = State.AutoDoubleJump,
    Callback = function(v) State.AutoDoubleJump = v end
})

TabProgress:Button({
    Title = "â¡ Purchase All Affordable Now",
    Desc = "Sweeps every currently unlocked and affordable upgrade",
    Callback = function()
        pcall(function()
            local list = { "ClickMultiplier", "CriticalChance", "AutoClickerSpeed", "HatchSpeed", "Teleport" }
            for _, upg in ipairs(list) do
                UpgradeController:Purchase(upg)
                task.wait(0.05)
            end
            WindUI:Notify({ Title = "Upgrades", Content = "Purchased available upgrades!", Duration = 2.5 })
        end)
    end
})

TabProgress:Section({ Title = "ð Gem Upgrades (Skill Tree Engine)" })

local function getReadyGemUpgrades()
    local data = DataController:GetReplica().Data
    if not data or not data.Currencies or not data.SkillTree then return {} end
    
    local unlocked = data.SkillTree.Unlocked or {}
    local gems = tonumber(data.Currencies.Gems) or 0
    local readyList = {}
    local visited = {}
    local directions = { "N", "S", "NE", "NW", "SE", "SW" }
    
    local function traverse(node, parentUnlocked, category)
        if not node or not node.Name or visited[node.Name] then return end
        visited[node.Name] = true
        
        local isNodeUnlocked = unlocked[node.Name] == true or node.Origin == true
        
        if not isNodeUnlocked and parentUnlocked and not node.Category and not node.Origin then
            local price = SkillTreeFormula.GetPrice(data, node.Name)
            if price and price <= gems then
                local shopLocked = SkillTreeRequirements.GetLockedShop(data, node)
                local islandLocked = SkillTreeRequirements.GetLockedIsland(data, node)
                local withheld = SkillTreeFormula.IsWithheld(data, node.Name)
                if not shopLocked and not islandLocked and not withheld then
                    if State.GemUpgradeFocus == "All" or State.GemUpgradeFocus == category then
                        table.insert(readyList, {
                            Name = node.Name,
                            Price = price,
                            Category = category
                        })
                    end
                end
            end
        end
        
        for _, dir in ipairs(directions) do
            if node[dir] then
                traverse(node[dir], isNodeUnlocked, category)
            end
        end
    end
    
    for treeKey, treeRoot in pairs(SkillTreeConfig) do
        traverse(treeRoot, true, treeKey)
    end
    
    table.sort(readyList, function(a, b) return a.Price < b.Price end)
    return readyList
end

local function buyAffordableGemUpgrades(isManual)
    local ready = getReadyGemUpgrades()
    local bought = 0
    for _, upg in ipairs(ready) do
        local ok, res = pcall(function()
            return SkillTreeComm:Unlock({ Name = upg.Name })
        end)
        if ok and type(res) == "table" and res.Success == true then
            bought = bought + 1
            task.wait(0.08)
        end
    end
    if isManual then
        if bought > 0 then
            WindUI:Notify({ Title = "Gem Upgrades", Content = string.format("Unlocked %d Gem Upgrades!", bought), Duration = 3 })
        else
            WindUI:Notify({ Title = "Gem Upgrades", Content = "No affordable Gem Upgrades available right now.", Duration = 2.5 })
        end
    end
    return bought
end

local GemUpgPara = TabProgress:Paragraph({
    Title = "ð Gem Upgrades Overview",
    Desc = "Calculating unlocked nodes and gems..."
})

UIElements["AutoGemUpgrades"] = TabProgress:Toggle({
    Title = "ð Auto Buy Gem Upgrades",
    Desc = "Automatically purchases affordable Skill Tree Gem nodes as soon as gems allow",
    Value = State.AutoGemUpgrades,
    Callback = function(v) State.AutoGemUpgrades = v end
})

UIElements["GemUpgradeFocus"] = TabProgress:Dropdown({
    Title = "ð¯ Gem Upgrade Tree Focus",
    Desc = "Choose which tree branch to prioritize",
    Values = { "All", "Clicking", "Eggs", "Pets" },
    Value = State.GemUpgradeFocus,
    Callback = function(v) State.GemUpgradeFocus = v end
})

TabProgress:Button({
    Title = "ð Buy All Affordable Gem Upgrades Now",
    Desc = "Immediately purchases all accessible nodes in the Gem Upgrade Skill Tree",
    Callback = function()
        buyAffordableGemUpgrades(true)
    end
})

-- Gem Upgrade Background Task Loop
task.spawn(function()
    while true do
        if State.AutoGemUpgrades then
            pcall(buyAffordableGemUpgrades, false)
            task.wait(State.GemUpgradeInterval or 2)
        else
            task.wait(1)
        end
    end
end)

-- Gem Upgrade Stats HUD Loop
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local data = DataController:GetReplica().Data
            if data and data.SkillTree and data.Currencies then
                local unlockedCount = 0
                for _ in pairs(data.SkillTree.Unlocked or {}) do unlockedCount = unlockedCount + 1 end
                local gems = tonumber(data.Currencies.Gems) or 0
                local ready = getReadyGemUpgrades()
                GemUpgPara:SetDesc(string.format("ð Gems: %s | ð Unlocked: %d/61 Nodes\nâ¡ Ready to Buy: %d affordable nodes", 
                    formatNumber(gems), unlockedCount, #ready))
            end
        end)
    end
end)

TabProgress:Section({ Title = "ð Quests & Idle Rewards" })

UIElements["AutoClaimQuests"] = TabProgress:Toggle({
    Title = "ð Auto Claim Completed Quests",
    Desc = "Continuously sweeps data for finished quests and collects rewards",
    Value = State.AutoClaimQuests,
    Callback = function(v) State.AutoClaimQuests = v end
})

TabProgress:Button({
    Title = "ð Claim All Finished Quests Now",
    Desc = "Forces an immediate claim of all completed quests",
    Callback = function()
        pcall(function()
            local data = DataController:GetReplica().Data
            local count = 0
            for qId, qData in pairs(data.Quests or {}) do
                if qData.Completed == true and qData.Claimed ~= true then
                    QuestController:Claim(qId)
                    count = count + 1
                    task.wait(0.05)
                end
            end
            WindUI:Notify({ Title = "Quests", Content = string.format("Claimed %d quests!", count), Duration = 3 })
        end)
    end
})

UIElements["AutoOfflineRewards"] = TabProgress:Toggle({
    Title = "ð¤ Auto Claim Offline Rewards",
    Desc = "Automatically claims idle offline earnings upon availability",
    Value = State.AutoOfflineRewards,
    Callback = function(v) State.AutoOfflineRewards = v end
})

-- Progression Loops
task.spawn(function()
    while true do
        if State.AutoUpgrades then
            pcall(function()
                local targets = (State.UpgradeTarget == "All") and 
                    { "ClickMultiplier", "CriticalChance", "AutoClickerSpeed", "HatchSpeed", "Teleport" } or 
                    { State.UpgradeTarget }
                for _, name in ipairs(targets) do
                    UpgradeController:Purchase(name)
                    task.wait(0.1)
                end
            end)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoDoubleJump then
            pcall(function()
                for i = 1, 14 do
                    DoubleJumpComm:Purchase({ Index = i })
                    task.wait(0.1)
                end
            end)
            task.wait(6)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoClaimQuests then
            pcall(function()
                local data = DataController:GetReplica().Data
                for qId, qData in pairs(data.Quests or {}) do
                    if qData.Completed == true and qData.Claimed ~= true then
                        QuestController:Claim(qId)
                        task.wait(0.1)
                    end
                end
            end)
            task.wait(3)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoOfflineRewards then
            pcall(function()
                OfflineRewardsComm:Claim()
            end)
            task.wait(30)
        else
            task.wait(2)
        end
    end
end)

-- ============================================================================
-- TAB 5: MINIGAMES & COMBAT ARENA
-- ============================================================================
TabArena:Section({ Title = "âï¸ Colosseum Wave Defense" })

UIElements["AutoColosseum"] = TabArena:Toggle({
    Title = "âï¸ Auto Farm Wave Defense",
    Desc = "Automatically starts wave defense, attacks opponents, and collects drops",
    Value = State.AutoColosseum,
    Callback = function(v) State.AutoColosseum = v end
})

TabArena:Button({
    Title = "âï¸ Start Wave Defense Now",
    Desc = "Initiates a new round in the Colosseum Arena",
    Callback = function()
        pcall(function()
            local res = ColosseumComm:StartWaveDefense()
            WindUI:Notify({ Title = "Colosseum", Content = "Wave defense initiated!", Duration = 3 })
        end)
    end
})

TabArena:Button({
    Title = "ð Claim Colosseum Minigame Rewards",
    Desc = "Claims all pending rewards from Colosseum defense runs",
    Callback = function()
        pcall(function()
            ColosseumComm:ClaimMinigameReward()
            WindUI:Notify({ Title = "Colosseum", Content = "Claimed arena rewards!", Duration = 3 })
        end)
    end
})

TabArena:Section({ Title = "âï¸ Mining Pit Automation" })

UIElements["AutoMining"] = TabArena:Toggle({
    Title = "âï¸ Auto Mine Pit Blocks",
    Desc = "Sends pet hits and collects drops in the Mining Pit",
    Value = State.AutoMining,
    Callback = function(v) State.AutoMining = v end
})

TabArena:Button({
    Title = "ð° Sell All Mined Ore Now",
    Desc = "Sells all excavated ore inventory for maximum currency",
    Callback = function()
        pcall(function()
            MiningComm:Sell()
            WindUI:Notify({ Title = "Mining", Content = "Sold all ore inventory!", Duration = 3 })
        end)
    end
})

-- Minigame Loops
task.spawn(function()
    while true do
        if State.AutoColosseum then
            pcall(function()
                ColosseumComm:StartWaveDefense()
                ColosseumComm:ClaimMinigameReward()
            end)
            task.wait(5)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoMining then
            pcall(function()
                MiningComm:Sell()
            end)
            task.wait(10)
        else
            task.wait(2)
        end
    end
end)

-- ============================================================================
-- TAB 6: WORLD EVENTS, SHRINES & RAFFLES
-- ============================================================================
TabEvents:Section({ Title = "ð° Daily Spin & Autumn Shrine" })

UIElements["AutoEventWheel"] = TabEvents:Toggle({
    Title = "ð¡ Auto Spin Daily Event Wheel",
    Desc = "Automatically spins the wheel when free spins or tickets are available",
    Value = State.AutoEventWheel,
    Callback = function(v) State.AutoEventWheel = v end
})

TabEvents:Button({
    Title = "ð¡ Spin Wheel Now",
    Desc = "Forces an immediate wheel spin attempt",
    Callback = function()
        pcall(function()
            local res = EventWheelComm:Spin({ WheelType = "Daily" })
            WindUI:Notify({ Title = "Wheel", Content = "Event Wheel spin executed!", Duration = 3 })
        end)
    end
})

UIElements["ShrineBlessing"] = TabEvents:Dropdown({
    Title = "â©ï¸ Shrine Blessing Target",
    Desc = "Multipliers: Luck (1.1x-1.5x), Golden (1.1x-1.5x), AutoClicker (1.1x-1.5x)",
    Values = { "Luck", "Golden", "AutoClicker" },
    Value = State.ShrineBlessing,
    Callback = function(v) State.ShrineBlessing = v end
})

UIElements["AutoShrine"] = TabEvents:Toggle({
    Title = "â©ï¸ Auto Activate Shrine Blessing",
    Desc = "Maintains chosen shrine blessing when on Autumn Island",
    Value = State.AutoShrine,
    Callback = function(v) State.AutoShrine = v end
})

TabEvents:Button({
    Title = "â©ï¸ Activate Shrine Blessing Now",
    Desc = "Applies chosen blessing (requires standing near Autumn Shrine)",
    Callback = function()
        pcall(function()
            local res = ShrineComm:Choose(State.ShrineBlessing)
            if res and res.Success then
                WindUI:Notify({ Title = "Shrine", Content = "Activated " .. State.ShrineBlessing .. " blessing!", Duration = 3 })
            else
                WindUI:Notify({ Title = "Shrine", Content = res and res.Reason or "Stand near Autumn Shrine!", Duration = 3 })
            end
        end)
    end
})

TabEvents:Section({ Title = "ð Server Giveaways & Collectibles" })

UIElements["AutoGiveaway"] = TabEvents:Toggle({
    Title = "ðï¸ Auto Enter Server Giveaways",
    Desc = "Automatically registers into active server giveaways",
    Value = State.AutoGiveaway,
    Callback = function(v) State.AutoGiveaway = v end
})

UIElements["AutoLuckyDucky"] = TabEvents:Toggle({
    Title = "ð¦ Auto Catch Lucky Ducky",
    Desc = "Instantly catches the Lucky Ducky whenever it flies across screen",
    Value = State.AutoLuckyDucky,
    Callback = function(v) State.AutoLuckyDucky = v end
})

TabEvents:Button({
    Title = "â­ Collect All 5 Shiny Stars Now",
    Desc = "Finds and claims all 5 hidden Shiny Stars instantly across worlds",
    Callback = function()
        pcall(function()
            local count = 0
            local tagged = CollectionService:GetTagged(ShinyStarConfig.Tag)
            for _, star in ipairs(tagged) do
                local id = star:GetAttribute("ShinyStarId") or star.Name
                local res = ShinyStarComm:Collect(id)
                if res and res.Success then count = count + 1 end
                task.wait(0.1)
            end
            WindUI:Notify({ Title = "Shiny Stars", Content = string.format("Collected %d new Shiny Stars!", count), Duration = 3 })
        end)
    end
})

UIElements["AutoShinyStars"] = TabEvents:Toggle({
    Title = "â­ Auto Collect Shiny Stars",
    Desc = "Monitors workspace and auto-claims any spawned Shiny Star",
    Value = State.AutoShinyStars,
    Callback = function(v) State.AutoShinyStars = v end
})

UIElements["AutoTapChests"] = TabEvents:Toggle({
    Title = "ð Auto Claim Tap Chests",
    Desc = "Sweeps and claims all island timed Tap Chests",
    Value = State.AutoTapChests,
    Callback = function(v) State.AutoTapChests = v end
})

TabEvents:Button({
    Title = "ðï¸ Redeem All Working Promo Codes",
    Desc = "Sequentially redeems known promotion codes with anti-rate-limit spacing",
    Callback = function()
        task.spawn(function()
            local promoCodes = {
                "RELEASE", "WELCOME", "TAP", "REBORN", "50KLIKES",
                "100KLIKES", "HALLOWEEN", "CANDY", "UPDATE1", "UPDATE2",
                "SECRET", "TOY", "ISLANDS", "GEMS"
            }
            local successCount = 0
            for _, code in ipairs(promoCodes) do
                pcall(function()
                    local res = CodeComm:Redeem(code)
                    if res and res.Success then successCount = successCount + 1 end
                end)
                task.wait(1.2)
            end
            WindUI:Notify({ Title = "Promo Codes", Content = string.format("Redemption finished! (%d valid)", successCount), Duration = 4 })
        end)
    end
})

-- Event Loops
task.spawn(function()
    while true do
        if State.AutoEventWheel then
            pcall(function()
                EventWheelComm:Spin({ WheelType = "Daily" })
            end)
            task.wait(60)
        else
            task.wait(2)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoShrine then
            pcall(function()
                ShrineComm:Choose(State.ShrineBlessing)
            end)
            task.wait(30)
        else
            task.wait(2)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoGiveaway then
            pcall(function()
                GiveawayComm:Enter()
            end)
            task.wait(15)
        else
            task.wait(2)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoLuckyDucky then
            pcall(function()
                LuckyDuckyController:CatchShown()
            end)
            task.wait(0.2)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoShinyStars then
            pcall(function()
                local tagged = CollectionService:GetTagged(ShinyStarConfig.Tag)
                for _, star in ipairs(tagged) do
                    local id = star:GetAttribute("ShinyStarId") or star.Name
                    ShinyStarComm:Collect(id)
                    task.wait(0.05)
                end
            end)
            task.wait(10)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoTapChests then
            pcall(function()
                for _, chestId in ipairs({ "Desert", "SkyIsland" }) do
                    TapChestComm:Claim(chestId)
                    task.wait(0.2)
                end
            end)
            task.wait(15)
        else
            task.wait(1)
        end
    end
end)

-- ============================================================================
-- TAB 7: OMNIPRESENT REALM & MACHINE TELEPORTS
-- ============================================================================
TabTeleports:Section({ Title = "ð Island Realms" })

local locations = {
    { Name = "Spawn Ground (Main)", CF = CFrame.new(0, -514, -1830) },
    { Name = "Sky Island (1 Jump)", CF = CFrame.new(1, -61.8, -1915.8) },
    { Name = "Autumn Island (2 Jumps)", CF = CFrame.new(-38.8, 871.3, -1727.8) },
    { Name = "Mushroom Island (3 Jumps)", CF = CFrame.new(-200.7, 1999.5, -1939.2) },
    { Name = "Desert Island (4 Jumps)", CF = CFrame.new(-180, 3615.9, -1819.3) },
    { Name = "Crystal Cave (5 Jumps)", CF = CFrame.new(58.6, 5437.5, -2002.8) },
    { Name = "Shadow Realm (6 Jumps)", CF = CFrame.new(150.4, 7667.5, -1985.5) },
    { Name = "Volcano Island (7 Jumps)", CF = CFrame.new(-149, 11060.1, -1997.7) },
    { Name = "Heaven Island (8 Jumps)", CF = CFrame.new(-174, 15333, -1970) }
}

for _, loc in ipairs(locations) do
    TabTeleports:Button({
        Title = "ð " .. loc.Name,
        Desc = "Instantly teleports to " .. loc.Name,
        Callback = function()
            safeTeleport(loc.CF + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Teleport", Content = "Arrived at " .. loc.Name, Duration = 2 })
        end
    })
end

TabTeleports:Section({ Title = "âï¸ Machines & Arena POIs" })

local machineLocations = {
    { Name = "Golden Machine (Spawn)", CF = CFrame.new(14.5, -515.9, -1885.6) },
    { Name = "Golden Machine (Sky)", CF = CFrame.new(-110.2, -50.4, -1854.5) },
    { Name = "Skill Tree Terminal", CF = CFrame.new(-159.1, 1999.6, -1959.0) },
    { Name = "Pet Index Terminal", CF = CFrame.new(89.2, 2031.7, -1965.8) },
    { Name = "Autumn Shrine", CF = CFrame.new(-51.4, 871.3, -1727.8) },
    { Name = "Colosseum Wave Arena", CF = CFrame.new(-169.7, 2020.3, -1794.7) },
    { Name = "Mining Pit Entrance", CF = CFrame.new(-100.0, -515.0, -1850.0) }
}

for _, mach in ipairs(machineLocations) do
    TabTeleports:Button({
        Title = "ð§ " .. mach.Name,
        Desc = "Teleports in front of " .. mach.Name,
        Callback = function()
            safeTeleport(mach.CF + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Teleport", Content = "Arrived at " .. mach.Name, Duration = 2 })
        end
    })
end

-- ============================================================================
-- TAB 8: PLAYER PHYSICS & ENGINE OPTIMIZATION
-- ============================================================================
TabQoL:Section({ Title = "ð Physical Enhancements" })

UIElements["WalkSpeed"] = TabQoL:Slider({
    Title = "ð WalkSpeed",
    Desc = "Adjust character movement velocity (16 - 250)",
    Value = { Min = 16, Max = 250, Default = State.WalkSpeed },
    Step = 1,
    Callback = function(v)
        State.WalkSpeed = v
        if Humanoid then Humanoid.WalkSpeed = v end
    end
})

UIElements["JumpPower"] = TabQoL:Slider({
    Title = "ð¦ JumpPower",
    Desc = "Adjust vertical jump propulsion (50 - 300)",
    Value = { Min = 50, Max = 300, Default = State.JumpPower },
    Step = 1,
    Callback = function(v)
        State.JumpPower = v
        if Humanoid then Humanoid.JumpPower = v end
    end
})

UIElements["InfiniteJump"] = TabQoL:Toggle({
    Title = "ðï¸ Infinite Jump",
    Desc = "Allows jumping continuously in mid-air",
    Value = State.InfiniteJump,
    Callback = function(v) State.InfiniteJump = v end
})

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

UIElements["Noclip"] = TabQoL:Toggle({
    Title = "ð» Noclip",
    Desc = "Walk freely through walls and barriers",
    Value = State.Noclip,
    Callback = function(v) State.Noclip = v end
})

RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

TabQoL:Section({ Title = "ð¡ï¸ Anti-AFK & Performance" })

UIElements["AntiAFK"] = TabQoL:Toggle({
    Title = "ð¡ï¸ Anti-AFK Disconnect Guard",
    Desc = "Prevents Roblox from kicking you after 20 minutes of inactivity",
    Value = State.AntiAFK,
    Callback = function(v) State.AntiAFK = v end
})

LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

TabQoL:Button({
    Title = "â¡ FPS Booster / Potato Graphics",
    Desc = "Disables heavy shaders, particles, and lighting for maximum frame rates",
    Callback = function()
        pcall(function()
            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled = false end
            end
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Smoke") or desc:IsA("Fire") then
                    desc.Enabled = false
                end
            end
            WindUI:Notify({ Title = "Performance", Content = "Potato Graphics mode active!", Duration = 3 })
        end)
    end
})

TabQoL:Section({ Title = "â¨ï¸ UI Keybind & Controls" })

UIElements["UIKeybind"] = TabQoL:Dropdown({
    Title = "â¨ï¸ Show / Hide UI Keybind",
    Desc = "Choose key to toggle GUI visibility (Default: RightControl)",
    Values = { "RightControl", "RightShift", "Insert", "LeftControl", "F4", "F8" },
    Value = State.UIKeybind and State.UIKeybind.Name or "RightControl",
    Callback = function(v)
        if Enum.KeyCode[v] then
            State.UIKeybind = Enum.KeyCode[v]
            WindUI:Notify({ Title = "Keybind", Content = "UI Toggle key set to " .. v, Duration = 2.5 })
        end
    end
})

-- ============================================================================
-- TAB 9: SAVE & LOAD CONFIGURATION MANAGER
-- ============================================================================
TabConfigs:Section({ Title = "ð Profile Management" })

local CONFIG_DIR = "TapSimulatorRebornConfig"
pcall(function()
    if makefolder and not isfolder(CONFIG_DIR) then
        makefolder(CONFIG_DIR)
    end
end)

local function getSavedConfigs()
    local configs = { "default" }
    pcall(function()
        if listfiles and isfolder and isfolder(CONFIG_DIR) then
            local files = listfiles(CONFIG_DIR)
            for _, f in ipairs(files) do
                local name = f:match("([^/\\]+)%.json$")
                if name and not table.find(configs, name) then
                    table.insert(configs, name)
                end
            end
        end
    end)
    return configs
end

local ConfigDropdown

UIElements["CurrentConfigName"] = TabConfigs:Input({
    Title = "ð Profile Name",
    Desc = "Enter profile name to save new or overwrite",
    Value = State.CurrentConfigName,
    Placeholder = "e.g. default, farm_overnight, egg_hunt",
    Callback = function(v)
        if v and #v > 0 then
            State.CurrentConfigName = v
        end
    end
})

ConfigDropdown = TabConfigs:Dropdown({
    Title = "ð Select Configuration Profile",
    Desc = "Choose an existing profile to load or manage",
    Values = getSavedConfigs(),
    Value = State.CurrentConfigName,
    Callback = function(v)
        State.CurrentConfigName = v
        if UIElements["CurrentConfigName"] and type(UIElements["CurrentConfigName"].Set) == "function" then
            UIElements["CurrentConfigName"]:Set(v)
        end
    end
})

TabConfigs:Button({
    Title = "ð¾ Save Current Configuration",
    Desc = "Serializes and saves all toggles, sliders, and parameters to disk",
    Callback = function()
        pcall(function()
            if writefile then
                local path = CONFIG_DIR .. "/" .. State.CurrentConfigName .. ".json"
                local cleanState = {}
                for k, v in pairs(State) do
                    if typeof(v) == "boolean" or typeof(v) == "number" or typeof(v) == "string" then
                        cleanState[k] = v
                    elseif typeof(v) == "EnumItem" then
                        cleanState[k] = v.Name
                    end
                end
                writefile(path, HttpService:JSONEncode(cleanState))
                ConfigDropdown:Refresh(getSavedConfigs(), false)
                ConfigDropdown:Select(State.CurrentConfigName)
                WindUI:Notify({ Title = "Config Manager", Content = "Saved profile: " .. State.CurrentConfigName, Duration = 2.5 })
            else
                WindUI:Notify({ Title = "Config Manager", Content = "writefile not supported by executor", Duration = 2.5 })
            end
        end)
    end
})

TabConfigs:Button({
    Title = "ð Load Selected Configuration",
    Desc = "Restores all saved values and dynamically re-renders every UI component",
    Callback = function()
        pcall(function()
            if readfile then
                local path = CONFIG_DIR .. "/" .. State.CurrentConfigName .. ".json"
                if isfile and not isfile(path) then
                    WindUI:Notify({ Title = "Config Manager", Content = "Profile not found: " .. State.CurrentConfigName, Duration = 2.5 })
                    return
                end
                local content = readfile(path)
                local loaded = HttpService:JSONDecode(content)
                if loaded and type(loaded) == "table" then
                    for k, v in pairs(loaded) do
                        if k == "UIKeybind" and type(v) == "string" and Enum.KeyCode[v] then
                            State.UIKeybind = Enum.KeyCode[v]
                            restoreUIComponent(k, v)
                        else
                            State[k] = v
                            restoreUIComponent(k, v)
                        end
                    end
                    WindUI:Notify({
                        Title = "Config Manager",
                        Content = string.format("Restored profile '%s' with full visual UI synchronization!", State.CurrentConfigName),
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({ Title = "Config Manager", Content = "readfile not supported by executor", Duration = 2.5 })
            end
        end)
    end
})

TabConfigs:Button({
    Title = "ð Refresh Profile List",
    Desc = "Scans disk for updated configuration files",
    Callback = function()
        ConfigDropdown:Refresh(getSavedConfigs(), false)
        WindUI:Notify({ Title = "Config Manager", Content = "Refreshed config files!", Duration = 2 })
    end
})

TabConfigs:Button({
    Title = "ðï¸ Delete Selected Profile",
    Desc = "Permanently deletes the selected configuration file",
    Callback = function()
        pcall(function()
            if State.CurrentConfigName == "default" then
                WindUI:Notify({ Title = "Config Manager", Content = "Cannot delete default profile", Duration = 2.5 })
                return
            end
            if delfile then
                local path = CONFIG_DIR .. "/" .. State.CurrentConfigName .. ".json"
                if isfile and isfile(path) then
                    delfile(path)
                    State.CurrentConfigName = "default"
                    ConfigDropdown:Refresh(getSavedConfigs(), false)
                    ConfigDropdown:Select("default")
                    if UIElements["CurrentConfigName"] and type(UIElements["CurrentConfigName"].Set) == "function" then
                        UIElements["CurrentConfigName"]:Set("default")
                    end
                    WindUI:Notify({ Title = "Config Manager", Content = "Deleted profile!", Duration = 2.5 })
                end
            end
        end)
    end
})

-- Continuous Humanoid State Enforcement
task.spawn(function()
    while task.wait(0.2) do
        if Humanoid then
            if State.WalkSpeed ~= 16 and Humanoid.WalkSpeed ~= State.WalkSpeed then
                Humanoid.WalkSpeed = State.WalkSpeed
            end
            if State.JumpPower ~= 50 and Humanoid.JumpPower ~= State.JumpPower then
                Humanoid.JumpPower = State.JumpPower
            end
        end
    end
end)

-- Initial Startup Notification
WindUI:Notify({
    Title = "â¡ Tap Simulator REBORN",
    Content = "Master Suite loaded! 9 Automation Pillars active.",
    Duration = 5
})
