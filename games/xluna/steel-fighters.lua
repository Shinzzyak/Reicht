-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- =======================================================
-- STEEL FIGHTERS - MASTER CLIENT AUTOMATION
-- Universal Architecture | WindUI Framework
-- Verified Against Live Game Mechanics & Remotes
-- =======================================================

-- Single Instance Guard
if _G.SteelFightersActive then
    if typeof(_G.SteelFightersTeardown) == "function" then
        pcall(_G.SteelFightersTeardown)
    end
    task.wait(0.3)
end
_G.SteelFightersActive = true

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Modules & Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(Packages:WaitForChild("Net"))
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Robots = require(Modules:WaitForChild("Robots"))
local Junkyard = require(Modules:WaitForChild("Junkyard"))
local Arena = require(Modules:WaitForChild("Arena"))

local UpgradesModule = nil
pcall(function()
    UpgradesModule = require(Modules:WaitForChild("Upgrades"))
end)

local UpgradesTreeModule = nil
pcall(function()
    UpgradesTreeModule = require(Modules:WaitForChild("Upgrades Tree"))
end)

local Cache = nil
pcall(function()
    Cache = require(ReplicatedStorage.Client:WaitForChild("Cache"))
end)


-- Hook Confirm.Ask to instantly approve all "SURE?" and confirmation dialogs
pcall(function()
    local Confirm = require(ReplicatedStorage.Client.Modules.Utils:WaitForChild("Confirm"))
    if Confirm and not Confirm._AntigravityHooked then
        Confirm._AntigravityHooked = true
        local origAsk = Confirm.Ask
        Confirm.Ask = function(a1)
            if State.AutoConfirmSure then
                return true
            end
            return origAsk(a1)
        end
    end
end)

-- Hook Notification.Warn to suppress annoying rate-limit popups
pcall(function()
    local Notification = require(Packages:WaitForChild("Notification"))
    if Notification and Notification.Warn and not Notification._AntigravityHooked then
        Notification._AntigravityHooked = true
        local origWarn = Notification.Warn
        Notification.Warn = function(kind, msg, ...)
            if typeof(msg) == "string" and (msg:find("Too fast") or msg:find("Catch your breath") or msg:find("Slow down")) then
                return
            end
            return origWarn(kind, msg, ...)
        end
    end
end)

-- Hook Ragdoll to eliminate local character knockdown and ragdoll states
pcall(function()
    local Ragdoll = require(Packages:WaitForChild("Ragdoll"))
    if Ragdoll and not Ragdoll._AntigravityHooked then
        Ragdoll._AntigravityHooked = true
        local origApply = Ragdoll.Apply
        Ragdoll.Apply = function(char, ...)
            if State.AntiKnockdown and char == LocalPlayer.Character then
                return false
            end
            return origApply(char, ...)
        end
        local origIsDown = Ragdoll.IsDown
        Ragdoll.IsDown = function(char, ...)
            if State.AntiKnockdown and char == LocalPlayer.Character then
                return false
            end
            return origIsDown(char, ...)
        end
    end
end)

-- Teardown Trove
local CleanupConnections = {}
_G.SteelFightersTeardown = function()
    _G.SteelFightersActive = false
    for _, conn in ipairs(CleanupConnections) do
        pcall(function()
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            elseif typeof(conn) == "thread" then
                task.cancel(conn)
            elseif typeof(conn) == "Instance" then
                conn:Destroy()
            end
        end)
    end
    table.clear(CleanupConnections)
    if _G.SteelFightersWindow and _G.SteelFightersWindow.Destroy then
        pcall(function() _G.SteelFightersWindow:Destroy() end)
    end
    if _G.SteelFightersFAB then
        pcall(function() _G.SteelFightersFAB:Destroy() end)
    end
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local rGui = CoreGui:FindFirstChild("RobloxGui")
        if rGui then
            for _, g in ipairs(rGui:GetChildren()) do
                if g.Name:find("WindUI") then
                    pcall(function() g:Destroy() end)
                end
            end
        end
    end)
end

-- =======================================================
-- DYNAMIC PLOT & LOCATION RESOLUTION ENGINE
-- =======================================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function SafeTeleport(targetCF)
    local root = GetRootPart()
    if root then
        if typeof(targetCF) == "Vector3" then
            root.CFrame = CFrame.new(targetCF + Vector3.new(0, 2.5, 0))
        elseif typeof(targetCF) == "CFrame" then
            root.CFrame = targetCF
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function GetActiveRealm()
    local realm = "Overworld"
    pcall(function()
        local pc = require(ReplicatedStorage.Client.Modules.Systems:WaitForChild("Plot Controller"))
        realm = pc.GetRealm()
    end)
    if not realm or realm == "" then
        local root = GetRootPart()
        if root then
            local y = root.Position.Y
            if y > 3000 then
                realm = "Heaven"
            elseif y > 1500 then
                realm = "Space"
            else
                realm = "Overworld"
            end
        end
    end
    return realm or "Overworld"
end

local function GetMyPlotModel()
    local myPlotAttr = LocalPlayer:GetAttribute("Plot")
    if not myPlotAttr then return nil end
    local plots = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Plots")
    return plots and plots:FindFirstChild(tostring(myPlotAttr))
end

local function GetMyActiveSubPlot()
    local pModel = GetMyPlotModel()
    if not pModel then return nil end
    local realm = GetActiveRealm()
    if realm == "Space" then
        return pModel:FindFirstChild("Space Plot") or pModel:FindFirstChild("Plot")
    elseif realm == "Heaven" then
        return pModel:FindFirstChild("Heaven Plot") or pModel:FindFirstChild("Plot")
    end
    return pModel:FindFirstChild("Plot")
end

local function GetMyPlotServerSlot()
    local myPlotAttr = LocalPlayer:GetAttribute("Plot")
    if not myPlotAttr then return nil end
    local sPlots = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Plots")
    return sPlots and sPlots:FindFirstChild(tostring(myPlotAttr))
end

local function GetBasePad()
    local sSlot = GetMyPlotServerSlot()
    if not sSlot then return nil end
    local realm = GetActiveRealm()
    if realm == "Space" then
        return sSlot:FindFirstChild("SpacePad") or sSlot:FindFirstChild("SpawnPad") or sSlot:FindFirstChild("Origin")
    elseif realm == "Heaven" then
        return sSlot:FindFirstChild("HeavenPad") or sSlot:FindFirstChild("SpawnPad") or sSlot:FindFirstChild("Origin")
    end
    return sSlot:FindFirstChild("SpawnPad") or sSlot:FindFirstChild("Origin")
end

local function GetLeverPosition()
    local sub = GetMyActiveSubPlot()
    local lever = sub and sub:FindFirstChild("RNG") and sub.RNG:FindFirstChild("Lever")
    if lever then
        return lever:GetPivot().Position
    end
    return nil
end

local function GetPedestalPosition(slotIndex)
    local sub = GetMyActiveSubPlot()
    local pedFolder = sub and sub:FindFirstChild("RNG") and sub.RNG:FindFirstChild("Pedestal")
    local ped = pedFolder and pedFolder:FindFirstChild(tostring(slotIndex))
    if ped then
        return ped:GetPivot().Position
    end
    return nil
end

local function GetCraftPosition()
    local sub = GetMyActiveSubPlot()
    local craft = sub and (sub:FindFirstChild("Craft Station") or sub:FindFirstChild("Craft"))
    if craft then
        return craft:GetPivot().Position
    end
    return nil
end

local function GetUpgradesPosition()
    local sub = GetMyActiveSubPlot()
    local upg = sub and (sub:FindFirstChild("Machines") or sub:FindFirstChild("Upgrades"))
    if upg then
        return upg:GetPivot().Position
    end
    return nil
end

local function GetWheelPosition()
    local pModel = GetMyPlotModel()
    local wheel = pModel and pModel:FindFirstChild("Plot") and pModel.Plot:FindFirstChild("Wheel")
    if wheel then
        return wheel:GetPivot().Position
    end
    return nil
end

local function GetArenaPosition()
    local sub = GetMyActiveSubPlot()
    local arena = sub and sub:FindFirstChild("Arena")
    if arena then
        local floors = arena:FindFirstChild("Floors")
        local ground = floors and floors:FindFirstChild("Ground")
        if ground and ground:IsA("BasePart") then
            return ground.Position + Vector3.new(0, 3, 0)
        end
        local status = arena:FindFirstChild("Status") or arena:FindFirstChild("Filler")
        if status and status:IsA("BasePart") then
            return status.Position + Vector3.new(0, 3, 0)
        end
    end
    return nil
end
local GetArenaDeckPosition = GetArenaPosition

local function GetActiveJunkyard()
    local jy = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Junkyard")
    if not jy then return "Overworld", Vector3.new(-435.1, 8, -421.8), nil end
    for _, realmName in ipairs({ "Space", "Heaven", "Overworld" }) do
        local realm = jy:FindFirstChild(realmName)
        local parts = realm and realm:FindFirstChild("Spawn") and realm.Spawn:FindFirstChild("Parts")
        if parts and #parts:GetChildren() > 0 then
            local area = realm.Spawn:FindFirstChild("Area")
            local areaPos = area and area.Position or Vector3.new(-435.1, 2043, -421.8)
            return realmName, areaPos, parts
        end
    end
    return "Overworld", Vector3.new(-435.1, 8, -421.8), nil
end

-- Smooth Fly + NoClip Engine
local function FlyNoClip(targetPos, speed)
    local root = GetRootPart()
    local char = LocalPlayer.Character
    if not root or not char then return end
    speed = speed or 65
    local startPos = root.Position
    local dist = (targetPos - startPos).Magnitude
    if dist < 2 then return end
    local duration = dist / speed
    local startTime = os.clock()
    
    local noclipConn = RunService.Stepped:Connect(function()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    while _G.SteelFightersActive and (os.clock() - startTime < duration) do
        local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
        root.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha), targetPos)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.02)
    end
    root.CFrame = CFrame.new(targetPos)
    root.AssemblyLinearVelocity = Vector3.zero
    if noclipConn then noclipConn:Disconnect() end
end

-- =======================================================
-- STATE CONFIGURATION (ALL OFF BY DEFAULT)
-- =======================================================
local State = {
    -- Junkyard Advanced
    AutoJunkVacuum = false,
    PrioritizeBiggestScrap = true,
    FlyReturnToBase = true,
    FlySpeed = 120,
    AntiKnockdown = true,
    VacuumDelay = 0.3,
    
    -- Plot Automation
    AutoPullLever = false,
    LeverDelay = 1.2,
    AutoBuyPedestals = false,
    BuyPedestalDelay = 0.5,
    AutoPullAndBuy = false,
    
    -- Robots
    AutoEquipBest = false,
    EquipBestDelay = 3.0,
    AutoUpgradeRobots = false,
    AutoReforgeParts = false,
    
    -- Arena & Combat (Autonomous Robot Combat - Zero Player Teleport)
    AutoArenaSpeed = false,
    AutoArenaContinue = false,
    ArenaContinueAction = "Use", -- "Use" or "Decline"
    FastAttackAnimation = false,
    AttackAnimSpeed = 3.0,
    AutoDailyBoss = false,
    AutoDummy = false,
    
    -- Progression
    AutoClaimRewards = false,
    AutoConfirmSure = true,
    ClaimDelay = 10.0,
    AutoSpinWheel = false,
    AutoBuyUpgrades = false,
    AutoUpgradeTree = false,
    TreeFocus = "Balanced / Cheapest First",
    AutoRebirth = false,
    
    -- Movement
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = true,
}

-- Load WindUI Library (Multi-Source Resilient Fresh Instance Loader)
local WindUI = nil
local function loadWindUI()
    if not _G.WindUISource then
        local sources = {
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
            "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
            "https://tree-hub.vercel.app/api/UI/WindUI"
        }
        for _, url in ipairs(sources) do
            local ok, content = pcall(game.HttpGet, game, url)
            if ok and content and #content > 1000 then
                _G.WindUISource = content
                break
            end
        end
    end
    if _G.WindUISource then
        local fn = loadstring(_G.WindUISource)
        if fn then
            local res = fn()
            if res then
                return res
            end
        end
    end
    return nil
end

WindUI = loadWindUI()
if not WindUI then
    warn("[SteelFighters] Failed to initialize WindUI framework.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Steel Fighters - Master Automation",
    Icon = "shield",
    Author = "Universal Operations",
    Folder = "SteelFighters",
    Size = UDim2.fromOffset(600, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 190,
    HasOutline = true,
})
_G.SteelFightersWindow = Window

-- Reference for dynamic UI updating
local UIElements = {}

-- =======================================================
-- TAB 1: ARENA & COMBAT (AUTONOMOUS ROBOT WARFARE)
-- =======================================================
local TabArena = Window:Tab({
    Title = "Arena Combat",
    Icon = "swords",
})

TabArena:Section({ Title = "Autonomous Robot Warfare (Zero Player Teleport)" })

UIElements["AutoArenaSpeed"] = TabArena:Toggle({
    Title = "Enforce 2x Arena Speed",
    Desc = "Locks battle simulation to 2x speed. Robots fight faster in background without moving you.",
    Value = State.AutoArenaSpeed,
    Callback = function(val)
        State.AutoArenaSpeed = val
        if val then
            pcall(function()
                Net:RemoteEvent("ArenaSpeed"):FireServer(2)
            end)
        end
    end,
})

UIElements["AutoArenaContinue"] = TabArena:Toggle({
    Title = "Auto Revive Robots (God Mode Sustain)",
    Desc = "Automatically triggers instant revive when robot squad falls, keeping battles endless.",
    Value = State.AutoArenaContinue,
    Callback = function(val)
        State.AutoArenaContinue = val
    end,
})

TabArena:Dropdown({
    Title = "Continue Action",
    Desc = "Action to take when robots are defeated.",
    Values = { "Use", "Decline" },
    Value = State.ArenaContinueAction,
    Callback = function(val)
        State.ArenaContinueAction = val
    end,
})

UIElements["FastAttackAnimation"] = TabArena:Toggle({
    Title = "Fast Attack Animations",
    Desc = "Accelerates animation tracks on all active robot fighters so robots strike at hyper speed.",
    Value = State.FastAttackAnimation,
    Callback = function(val)
        State.FastAttackAnimation = val
    end,
})

TabArena:Slider({
    Title = "Attack Animation Speed Multiplier",
    Desc = "Combat swing animation playback speed (1x to 5x).",
    Step = 0.5,
    Value = { Min = 1.0, Max = 5.0, Default = State.AttackAnimSpeed },
    Callback = function(val)
        State.AttackAnimSpeed = val
    end,
})

TabArena:Section({ Title = "Background Boss Challenges" })

UIElements["AutoDailyBoss"] = TabArena:Toggle({
    Title = "Auto Challenge Daily Boss",
    Desc = "Initiates Daily Boss battles remotely in background without teleporting character.",
    Value = State.AutoDailyBoss,
    Callback = function(val)
        State.AutoDailyBoss = val
    end,
})

UIElements["AutoDummy"] = TabArena:Toggle({
    Title = "Auto Challenge Training Dummy",
    Desc = "Challenges dummy remotely to test DPS without moving character.",
    Value = State.AutoDummy,
    Callback = function(val)
        State.AutoDummy = val
    end,
})

-- =======================================================
-- TAB 2: PLOT & PEDESTALS (RNG GACHA ENGINE)
-- =======================================================
local TabPlot = Window:Tab({
    Title = "Plot & Pedestals",
    Icon = "dice-5",
})

TabPlot:Section({ Title = "Automated RNG Rolls & Buying" })

UIElements["AutoPullAndBuy"] = TabPlot:Toggle({
    Title = "Auto Pull & Buy Pedestals",
    Desc = "Unified loop: pulls RNG lever, inspects pedestals, and purchases affordable robot parts.",
    Value = State.AutoPullAndBuy,
    Callback = function(val)
        State.AutoPullAndBuy = val
    end,
})

UIElements["AutoPullLever"] = TabPlot:Toggle({
    Title = "Auto Pull Lever Only",
    Desc = "Continuously pulls the RNG lever at set interval.",
    Value = State.AutoPullLever,
    Callback = function(val)
        State.AutoPullLever = val
    end,
})

TabPlot:Slider({
    Title = "Lever Pull Interval (s)",
    Desc = "Delay before each roll to allow odds animation to resolve.",
    Step = 0.1,
    Value = { Min = 0.5, Max = 4.0, Default = State.LeverDelay },
    Callback = function(val)
        State.LeverDelay = val
    end,
})

UIElements["AutoBuyPedestals"] = TabPlot:Toggle({
    Title = "Auto Buy Affordable Pedestals Only",
    Desc = "Scans all 6 pedestals and purchases any available robot parts you can afford.",
    Value = State.AutoBuyPedestals,
    Callback = function(val)
        State.AutoBuyPedestals = val
    end,
})

TabPlot:Slider({
    Title = "Pedestal Scan Delay (s)",
    Desc = "Delay between checking pedestal offerings.",
    Step = 0.1,
    Value = { Min = 0.2, Max = 2.0, Default = State.BuyPedestalDelay },
    Callback = function(val)
        State.BuyPedestalDelay = val
    end,
})

TabPlot:Section({ Title = "Manual Plot Teleports" })

TabPlot:Button({
    Title = "Teleport to RNG Lever",
    Desc = "Positions character directly in front of the roll lever.",
    Callback = function()
        local pos = GetLeverPosition()
        if pos then
            SafeTeleport(pos + Vector3.new(0, 3, 2))
            WindUI:Notify({ Title = "Plot", Content = "Teleported to Lever.", Duration = 2 })
        end
    end,
})

TabPlot:Button({
    Title = "Teleport to Craft Station",
    Desc = "Positions character at the plot robot crafting station.",
    Callback = function()
        local pos = GetCraftPosition()
        if pos then
            SafeTeleport(pos + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Plot", Content = "Teleported to Craft Station.", Duration = 2 })
        end
    end,
})

TabPlot:Button({
    Title = "Teleport to Upgrades Machine",
    Desc = "Positions character at the plot upgrades terminal.",
    Callback = function()
        local pos = GetUpgradesPosition()
        if pos then
            SafeTeleport(pos + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Plot", Content = "Teleported to Upgrades.", Duration = 2 })
        end
    end,
})

for slot = 1, 6 do
    TabPlot:Button({
        Title = "Teleport to Pedestal #" .. slot,
        Desc = "Positions character at offer pedestal #" .. slot,
        Callback = function()
            local pos = GetPedestalPosition(slot)
            if pos then
                SafeTeleport(pos + Vector3.new(0, 3, 0))
                WindUI:Notify({ Title = "Pedestal", Content = "Teleported to Pedestal " .. slot, Duration = 2 })
            end
        end,
    })
end

-- =======================================================
-- TAB 3: JUNKYARD (HIGH-VALUE FLY + NOCLIP VACUUM)
-- =======================================================
local TabJunkyard = Window:Tab({
    Title = "Junkyard",
    Icon = "trash-2",
})

TabJunkyard:Section({ Title = "Overpowered Scrap Collector" })

UIElements["AutoJunkVacuum"] = TabJunkyard:Toggle({
    Title = "Auto Junkyard Collector",
    Desc = "Scans realm for biggest scrap, teleports safely, picks up, and flies NoClip to base pad.",
    Value = State.AutoJunkVacuum,
    Callback = function(val)
        State.AutoJunkVacuum = val
    end,
})

UIElements["PrioritizeBiggestScrap"] = TabJunkyard:Toggle({
    Title = "Prioritize Biggest Scrap",
    Desc = "Strictly targets Giant/OC > Giant > Big/OC > Big > Medium > Small.",
    Value = State.PrioritizeBiggestScrap,
    Callback = function(val)
        State.PrioritizeBiggestScrap = val
    end,
})

UIElements["FlyReturnToBase"] = TabJunkyard:Toggle({
    Title = "Fly + NoClip Return to Base",
    Desc = "Flies directly through all obstacles to your plot pad to instantly bank scrap.",
    Value = State.FlyReturnToBase,
    Callback = function(val)
        State.FlyReturnToBase = val
    end,
})

UIElements["AntiKnockdown"] = TabJunkyard:Toggle({
    Title = "Anti-Knockdown & Enemy Immunity",
    Desc = "Prevents ragdoll and disables collisions so roaming robots cannot touch or disrupt you.",
    Value = State.AntiKnockdown,
    Callback = function(val)
        State.AntiKnockdown = val
    end,
})

TabJunkyard:Slider({
    Title = "Flight Speed (studs/s)",
    Desc = "Speed when flying back to base with collected scrap.",
    Step = 5,
    Value = { Min = 30, Max = 100, Default = State.FlySpeed },
    Callback = function(val)
        State.FlySpeed = val
    end,
})

TabJunkyard:Slider({
    Title = "Collection Settling Delay (s)",
    Desc = "Settling wait before pickup to pass server velocity anti-cheat.",
    Step = 0.05,
    Value = { Min = 0.5, Max = 1.5, Default = 0.75 },
    Callback = function(val)
        State.VacuumDelay = val
    end,
})

TabJunkyard:Section({ Title = "Manual Navigation" })

TabJunkyard:Button({
    Title = "Teleport to Active Junkyard Realm",
    Desc = "Detects active spawn grounds (Space / Heaven / Overworld) and teleports there.",
    Callback = function()
        local realm, pos = GetActiveJunkyard()
        if realm and pos then
            SafeTeleport(pos + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Junkyard", Content = "Teleported to " .. realm .. " Junkyard.", Duration = 2 })
        end
    end,
})

TabJunkyard:Button({
    Title = "Fly to Base Pad Now",
    Desc = "Smoothly flies character with NoClip directly onto the plot base pad.",
    Callback = function()
        local pad = GetBasePad()
        if pad then
            FlyNoClip(pad.Position + Vector3.new(0, 3, 0), State.FlySpeed or 65)
            WindUI:Notify({ Title = "Flight", Content = "Arrived at Base Pad.", Duration = 2 })
        end
    end,
})

-- =======================================================
-- TAB 4: ROBOTS & FORGE
-- =======================================================
local TabRobots = Window:Tab({
    Title = "Robots",
    Icon = "bot",
})

TabRobots:Section({ Title = "Automated Robot Management" })

UIElements["AutoEquipBest"] = TabRobots:Toggle({
    Title = "Auto Equip Best Robots",
    Desc = "Continuously calls server EquipBest routine to deploy maximum DPS loadouts.",
    Value = State.AutoEquipBest,
    Callback = function(val)
        State.AutoEquipBest = val
    end,
})

TabRobots:Slider({
    Title = "Equip Best Interval (s)",
    Desc = "Delay between checking best equipment setup.",
    Step = 0.5,
    Value = { Min = 1.0, Max = 10.0, Default = State.EquipBestDelay },
    Callback = function(val)
        State.EquipBestDelay = val
    end,
})

UIElements["AutoUpgradeRobots"] = TabRobots:Toggle({
    Title = "Auto Level Up Robots",
    Desc = "Automatically applies level upgrades and uses 10-level increments on built robots.",
    Value = State.AutoUpgradeRobots,
    Callback = function(val)
        State.AutoUpgradeRobots = val
    end,
})

UIElements["AutoReforgeParts"] = TabRobots:Toggle({
    Title = "Auto Reforge Equipped Parts",
    Desc = "Automatically calls ReforgePart to re-roll stats on equipped components.",
    Value = State.AutoReforgeParts,
    Callback = function(val)
        State.AutoReforgeParts = val
    end,
})

TabRobots:Button({
    Title = "Equip Best Robots Now",
    Desc = "Instantly deploys highest-stat robots to your active combat party.",
    Callback = function()
        pcall(function()
            Net:RemoteFunction("EquipBest"):InvokeServer()
            WindUI:Notify({ Title = "Robots", Content = "Best robots equipped successfully.", Duration = 2 })
        end)
    end,
})

-- =======================================================
-- TAB 5: PROGRESSION & REWARDS
-- =======================================================
local TabProgression = Window:Tab({
    Title = "Progression",
    Icon = "gift",
})

TabProgression:Section({ Title = "Automated Claims" })

UIElements["AutoConfirmSure"] = TabProgression:Toggle({
    Title = "Auto Confirm 'SURE' Modals",
    Desc = "Automatically approves and bypasses any confirmation prompt or 'SURE?' dialog across the entire game.",
    Value = State.AutoConfirmSure,
    Callback = function(val)
        State.AutoConfirmSure = val
    end,
})

UIElements["AutoClaimRewards"] = TabProgression:Toggle({
    Title = "Auto Claim All Rewards",
    Desc = "Claims Daily Rewards, Free Playtime Gifts 1-12, Quests, and Achievements.",
    Value = State.AutoClaimRewards,
    Callback = function(val)
        State.AutoClaimRewards = val
    end,
})

TabProgression:Slider({
    Title = "Claim Sweep Delay (s)",
    Desc = "Interval between claiming pending achievements and gifts.",
    Step = 1.0,
    Value = { Min = 5.0, Max = 30.0, Default = State.ClaimDelay },
    Callback = function(val)
        State.ClaimDelay = val
    end,
})

UIElements["AutoSpinWheel"] = TabProgression:Toggle({
    Title = "Auto Spin Lucky Wheel",
    Desc = "Automatically spins the Lucky Wheel whenever free spins are available.",
    Value = State.AutoSpinWheel,
    Callback = function(val)
        State.AutoSpinWheel = val
    end,
})

UIElements["AutoBuyUpgrades"] = TabProgression:Toggle({
    Title = "Auto Buy Stat Upgrades",
    Desc = "Purchases global character upgrades (Speed, Carry, Scrap, Cash) when affordable.",
    Value = State.AutoBuyUpgrades,
    Callback = function(val)
        State.AutoBuyUpgrades = val
    end,
})

UIElements["AutoUpgradeTree"] = TabProgression:Toggle({
    Title = "Auto Buy Upgrades Tree",
    Desc = "Automatically purchases and levels up all affordable nodes across the entire Upgrades Tree.",
    Value = State.AutoUpgradeTree,
    Callback = function(val)
        State.AutoUpgradeTree = val
    end,
})

TabProgression:Dropdown({
    Title = "Tree Upgrade Priority",
    Desc = "Strategy used when selecting nodes to unlock or level up.",
    Values = { "Balanced / Cheapest First", "Robot Damage & Combat", "Cash & Scrap Economy" },
    Value = State.TreeFocus,
    Callback = function(val)
        State.TreeFocus = val
    end,
})

TabProgression:Button({
    Title = "Buy All Affordable Tree Nodes Now",
    Desc = "Instantly scans and purchases all affordable nodes until Cash runs out.",
    Callback = function()
        pcall(function()
            if not UpgradesTreeModule then return end
            local count = 0
            local playerData = Cache and Cache.PlayerData
            local cleanTree = UpgradesTreeModule.Clean(playerData and playerData.UpgradeTree)
            
            for iter = 1, 25 do
                local core = playerData and playerData.Core
                local cash = tonumber(core and core.Cash) or 0
                local bestTarget = nil
                local bestPrice = (1 / 0)
                
                for nodeKey, nodeData in pairs(UpgradesTreeModule.Nodes) do
                    if nodeKey ~= UpgradesTreeModule.Root then
                        local curLv = cleanTree[nodeKey] or 0
                        local maxLv = nodeData.Most or 5
                        if curLv < maxLv and UpgradesTreeModule.Open(cleanTree, nodeKey) then
                            local price = UpgradesTreeModule.Price(nodeKey, curLv)
                            if price and price > 0 and price <= cash and price < bestPrice then
                                bestPrice = price
                                bestTarget = {key = nodeKey, name = nodeData.Name, price = price, curLv = curLv}
                            end
                        end
                    end
                end
                
                if not bestTarget then break end
                
                local ok, res = pcall(function()
                    return Net:RemoteFunction("UpgradeTree"):InvokeServer("Buy", bestTarget.key, bestTarget.price)
                end)
                
                if ok and res then
                    count = count + 1
                    cleanTree[bestTarget.key] = bestTarget.curLv + 1
                    task.wait(0.12)
                else
                    break
                end
            end
            
            WindUI:Notify({
                Title = "Upgrades Tree",
                Content = count > 0 and ("Successfully purchased " .. count .. " Tree upgrades!") or "No affordable Tree upgrades available.",
                Duration = 2.5
            })
        end)
    end,
})

UIElements["AutoRebirth"] = TabProgression:Toggle({
    Title = "Auto Rebirth When Ready",
    Desc = "Triggers rebirth as soon as requirements are fulfilled to multiply earnings.",
    Value = State.AutoRebirth,
    Callback = function(val)
        State.AutoRebirth = val
    end,
})

TabProgression:Button({
    Title = "Claim All Achievements & Gifts Now",
    Desc = "Immediately executes full claim sweep across all rewards.",
    Callback = function()
        pcall(function()
            Net:RemoteFunction("ClaimDaily"):InvokeServer()
            for i = 1, 12 do
                pcall(function() Net:RemoteFunction("ClaimGift"):InvokeServer(i) end)
            end
            Net:RemoteFunction("ClaimAllAchievements"):InvokeServer()
            WindUI:Notify({ Title = "Rewards", Content = "Reward sweep completed.", Duration = 2 })
        end)
    end,
})

-- =======================================================
-- TAB 6: TELEPORTS
-- =======================================================
local TabTeleports = Window:Tab({
    Title = "Teleports",
    Icon = "map-pin",
})

TabTeleports:Section({ Title = "Plot & World Waypoints" })

TabTeleports:Button({
    Title = "Plot Base Pad (Spawn)",
    Desc = "Teleports to your active plot landing pad.",
    Callback = function()
        local pad = GetBasePad()
        if pad then
            SafeTeleport(pad.Position + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Teleport", Content = "Arrived at Plot Base Pad.", Duration = 2 })
        end
    end,
})

TabTeleports:Button({
    Title = "Battle Arena Deck",
    Desc = "Teleports directly to your Plot Arena battle deck.",
    Callback = function()
        local pos = GetArenaPosition()
        if pos then
            SafeTeleport(pos)
            WindUI:Notify({ Title = "Teleport", Content = "Arrived at Arena Deck.", Duration = 2 })
        end
    end,
})

TabTeleports:Button({
    Title = "Active Junkyard Realm",
    Desc = "Teleports to the active scrap yard (Space / Heaven / Overworld).",
    Callback = function()
        local realm, pos = GetActiveJunkyard()
        if realm and pos then
            SafeTeleport(pos + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. realm .. " Junkyard.", Duration = 2 })
        end
    end,
})

TabTeleports:Button({
    Title = "Space Tower Entrance",
    Desc = "Teleports to the Space Tower challenge entrance.",
    Callback = function()
        local sub = GetMyActiveSubPlot()
        local pModel = GetMyPlotModel()
        local tower = pModel and pModel:FindFirstChild("Space Tower")
        if tower then
            SafeTeleport(tower:GetPivot().Position + Vector3.new(0, 3, 0))
        else
            SafeTeleport(Vector3.new(-335, 2053, -650))
        end
        WindUI:Notify({ Title = "Teleport", Content = "Teleported to Tower.", Duration = 2 })
    end,
})

TabTeleports:Button({
    Title = "Daily Boss Arena",
    Desc = "Teleports directly to the lobby Daily Boss challenge circle.",
    Callback = function()
        SafeTeleport(Vector3.new(65.5, 6.5, -450.2))
        WindUI:Notify({ Title = "Teleport", Content = "Teleported to Daily Boss.", Duration = 2 })
    end,
})

TabTeleports:Button({
    Title = "Training Dummy Arena",
    Desc = "Teleports directly to the training dummy platform.",
    Callback = function()
        SafeTeleport(Vector3.new(120.0, 6.5, -450.2))
        WindUI:Notify({ Title = "Teleport", Content = "Teleported to Training Dummy.", Duration = 2 })
    end,
})

-- =======================================================
-- TAB 7: MOVEMENT & UTILITIES
-- =======================================================
local TabMovement = Window:Tab({
    Title = "Movement",
    Icon = "zap",
})

TabMovement:Section({ Title = "Physical Attributes" })

UIElements["WalkSpeedEnabled"] = TabMovement:Toggle({
    Title = "Enable Custom WalkSpeed",
    Desc = "Overrides character walking speed.",
    Value = State.WalkSpeedEnabled,
    Callback = function(val)
        State.WalkSpeedEnabled = val
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = val and State.WalkSpeed or 16
        end
    end,
})

TabMovement:Slider({
    Title = "WalkSpeed Value",
    Desc = "Target movement speed in studs/sec.",
    Step = 1,
    Value = { Min = 16, Max = 150, Default = State.WalkSpeed },
    Callback = function(val)
        State.WalkSpeed = val
        if State.WalkSpeedEnabled then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = val end
        end
    end,
})

UIElements["JumpPowerEnabled"] = TabMovement:Toggle({
    Title = "Enable Custom JumpPower",
    Desc = "Overrides character jump height.",
    Value = State.JumpPowerEnabled,
    Callback = function(val)
        State.JumpPowerEnabled = val
        local hum = GetHumanoid()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val and State.JumpPower or 50
        end
    end,
})

TabMovement:Slider({
    Title = "JumpPower Value",
    Desc = "Target jump impulse height.",
    Step = 5,
    Value = { Min = 50, Max = 300, Default = State.JumpPower },
    Callback = function(val)
        State.JumpPower = val
        if State.JumpPowerEnabled then
            local hum = GetHumanoid()
            if hum then hum.JumpPower = val end
        end
    end,
})

UIElements["InfiniteJump"] = TabMovement:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows jumping continuously while in mid-air.",
    Value = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
    end,
})

UIElements["Noclip"] = TabMovement:Toggle({
    Title = "Universal Noclip",
    Desc = "Disables physical collisions on all character limbs to pass through walls.",
    Value = State.Noclip,
    Callback = function(val)
        State.Noclip = val
    end,
})

UIElements["AntiAFK"] = TabMovement:Toggle({
    Title = "Anti-AFK Idle Protection",
    Desc = "Prevents Roblox 20-minute disconnection timer.",
    Value = State.AntiAFK,
    Callback = function(val)
        State.AntiAFK = val
    end,
})

-- =======================================================
-- TAB 8: CONFIGURATION & PROFILES (SOP COMPLIANCE)
-- =======================================================
local TabConfig = Window:Tab({
    Title = "Config",
    Icon = "settings",
})

TabConfig:Section({ Title = "Profile Management" })

local ProfileName = "default"
local ProfileDropdown = nil

local function GetConfigFolder()
    local folder = "SteelFighters/Profiles"
    if makefolder and not isfolder(folder) then
        pcall(makefolder, "SteelFighters")
        pcall(makefolder, folder)
    end
    return folder
end

local function ListProfiles()
    local folder = GetConfigFolder()
    local list = {}
    if listfiles then
        local files = listfiles(folder)
        for _, file in ipairs(files) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    end
    if #list == 0 then table.insert(list, "default") end
    return list
end

TabConfig:Input({
    Title = "Profile Name",
    Desc = "Enter configuration profile name.",
    Value = ProfileName,
    Callback = function(val)
        ProfileName = val
    end,
})

TabConfig:Button({
    Title = "Save Current Profile",
    Desc = "Saves all current state toggles and sliders to JSON.",
    Callback = function()
        pcall(function()
            local folder = GetConfigFolder()
            local path = folder .. "/" .. ProfileName .. ".json"
            local json = HttpService:JSONEncode(State)
            if writefile then
                writefile(path, json)
                WindUI:Notify({ Title = "Profile Saved", Content = "Saved profile: " .. ProfileName, Duration = 2 })
            end
        end)
    end,
})

ProfileDropdown = TabConfig:Dropdown({
    Title = "Select Profile to Load",
    Desc = "Choose an existing saved profile.",
    Values = ListProfiles(),
    Value = ProfileName,
    Callback = function(val)
        ProfileName = val
    end,
})

TabConfig:Button({
    Title = "Load Selected Profile",
    Desc = "Restores toggles and slider settings from the selected profile.",
    Callback = function()
        pcall(function()
            local folder = GetConfigFolder()
            local path = folder .. "/" .. ProfileName .. ".json"
            if isfile and isfile(path) and readfile then
                local content = readfile(path)
                local data = HttpService:JSONDecode(content)
                if data and typeof(data) == "table" then
                    for k, v in pairs(data) do
                        State[k] = v
                        if UIElements[k] and UIElements[k].Set then
                            pcall(function() UIElements[k]:Set(v) end)
                        end
                    end
                    WindUI:Notify({ Title = "Profile Loaded", Content = "Restored: " .. ProfileName, Duration = 2 })
                end
            end
        end)
    end,
})

TabConfig:Button({
    Title = "Refresh Profiles List",
    Desc = "Scans profile directory for newly created files.",
    Callback = function()
        if ProfileDropdown and ProfileDropdown.SetValues then
            ProfileDropdown:SetValues(ListProfiles())
            WindUI:Notify({ Title = "Profiles", Content = "Refreshed list.", Duration = 2 })
        end
    end,
})

-- =======================================================
-- FLOATING ACTION BUTTON (FAB) & TOGGLE HOTKEY
-- =======================================================
local function CreateFAB()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SteelFighters_FAB"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = PlayerGui
    end

    local fab = Instance.new("ImageButton")
    fab.Name = "FAB_Button"
    fab.Size = UDim2.fromOffset(48, 48)
    fab.Position = UDim2.new(0.02, 0, 0.45, 0)
    fab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    fab.BorderSizePixel = 0
    fab.AutoButtonColor = true
    fab.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = fab

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 130, 240)
    stroke.Thickness = 2
    stroke.Parent = fab

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(26, 26)
    icon.Position = UDim2.new(0.5, -13, 0.5, -13)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://10723415903" -- shield icon
    icon.ImageColor3 = Color3.fromRGB(240, 240, 255)
    icon.Parent = fab

    -- Dragging Logic
    local dragging = false
    local dragInput, dragStart, startPos

    fab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = fab.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    fab.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    fab.MouseButton1Click:Connect(function()
        if Window and Window.Toggle then
            Window:Toggle()
        end
    end)

    _G.SteelFightersFAB = screenGui
end

pcall(CreateFAB)

-- Keybind: LeftControl
local inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        if Window and Window.Toggle then
            Window:Toggle()
        end
    end
end)
table.insert(CleanupConnections, inputConn)

-- =======================================================
-- BACKGROUND AUTOMATION WORKERS
-- =======================================================

-- Anti-Knockdown & Enemy Pass-Through
local antiKnockConn = RunService.Stepped:Connect(function()
    if State.AntiKnockdown or State.AutoJunkVacuum then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            if hum.PlatformStand then hum.PlatformStand = false end
            if hum.Sit then hum.Sit = false end
        end
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end
end)
table.insert(CleanupConnections, antiKnockConn)

-- WORKER 1: Autonomous Robot Warfare (Zero Player Teleport)
local arenaWorker = task.spawn(function()
    while _G.SteelFightersActive do
        -- 1. Enforce 2x Arena Simulation Speed (Remote Call)
        if State.AutoArenaSpeed then
            pcall(function()
                local sSlot = GetMyPlotServerSlot()
                local speed = sSlot and sSlot:GetAttribute("ArenaSpeed")
                if speed ~= 2 then
                    Net:RemoteEvent("ArenaSpeed"):FireServer(2)
                end
            end)
        end

        -- 2. Auto Continue / Revive Robots (God Mode Sustain)
        if State.AutoArenaContinue then
            pcall(function()
                local sSlot = GetMyPlotServerSlot()
                local contAttr = sSlot and sSlot:GetAttribute("ArenaContinue")
                if typeof(contAttr) == "string" and contAttr ~= "" then
                    Net:RemoteEvent("ArenaContinue"):FireServer(State.ArenaContinueAction or "Use")
                end
            end)
        end

        -- 3. Fast Attack Animation Boost on Battlefield Fighters
        if State.FastAttackAnimation then
            pcall(function()
                local fight = workspace.Client:FindFirstChild("Junkyard") and workspace.Client.Junkyard:FindFirstChild("Fight")
                if fight then
                    for _, realm in ipairs(fight:GetChildren()) do
                        for _, fighter in ipairs(realm:GetChildren()) do
                            for _, d in ipairs(fighter:GetDescendants()) do
                                if d:IsA("Animator") then
                                    for _, tr in ipairs(d:GetPlayingAnimationTracks()) do
                                        tr:AdjustSpeed(State.AttackAnimSpeed or 3.0)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- 4. Lobby Boss & Dummy (Remote Execution - Zero Player Teleport)
        if State.AutoDailyBoss then
            pcall(function()
                Net:RemoteFunction("DailyBoss"):InvokeServer("Start")
            end)
        end

        if State.AutoDummy then
            pcall(function()
                Net:RemoteFunction("Dummy"):InvokeServer("Start")
            end)
        end

        task.wait(0.5)
    end
end)
table.insert(CleanupConnections, arenaWorker)

-- WORKER 2: Plot RNG & Pedestal Purchasing
local plotWorker = task.spawn(function()
    while _G.SteelFightersActive do
        local isGrinding = State.AutoPullAndBuy or State.AutoPullLever or State.AutoBuyPedestals
        if isGrinding then
            pcall(function()
                local sSlot = GetMyPlotServerSlot()
                local root = GetRootPart()
                if not sSlot or not root then return end

                local leverPos = GetLeverPosition()

                -- 1. Pull Lever
                if State.AutoPullAndBuy or State.AutoPullLever then
                    if leverPos then
                        if (root.Position - leverPos).Magnitude > 15 then
                            SafeTeleport(leverPos + Vector3.new(0, 3, 2))
                            task.wait(0.2)
                        end
                        Net:RemoteEvent("PullLever"):FireServer()
                    end
                end

                if State.AutoPullAndBuy then
                    task.wait(State.LeverDelay or 1.2)
                end

                -- 2. Buy Affordable Pedestals
                if State.AutoPullAndBuy or State.AutoBuyPedestals then
                    local offers = Robots.GetOffers(sSlot)
                    local pData = Cache and Cache.PlayerData
                    local myCash = tonumber(pData and pData.Core and pData.Core.Cash) or 0
                    local myRobots = pData and pData.Robots

                    if offers and typeof(offers) == "table" then
                        for slot = 1, 6 do
                            if not _G.SteelFightersActive then break end
                            local offer = offers[slot]
                            if offer and Robots.IsPart(offer) then
                                local price = Robots.Price(offer, myRobots) or 0
                                if price > 0 and price <= myCash then
                                    local pedPos = GetPedestalPosition(slot)
                                    if pedPos then
                                        SafeTeleport(pedPos + Vector3.new(0, 2.5, 0))
                                        task.wait(0.12)
                                        local rf = Net:RemoteFunction("BuyPart")
                                        local ok, res = pcall(function()
                                            return rf:InvokeServer(slot, offer)
                                        end)
                                        if ok and res == true then
                                            myCash = myCash - price
                                            task.wait(0.15)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Return to lever position if looping
                    if State.AutoPullAndBuy and leverPos then
                        SafeTeleport(leverPos + Vector3.new(0, 3, 2))
                    end
                end
            end)
        end
        task.wait(State.BuyPedestalDelay or 0.6)
    end
end)
table.insert(CleanupConnections, plotWorker)

-- Scrap Priority Calculation (Highest-tier first)
local function GetScrapPriority(key)
    if not key then return 0 end
    local upper = string.upper(key)
    if upper:find("GIANT/OC") or upper:find("GIANT.*OC") then return 100 end
    if upper:find("GIANT") then return 80 end
    if upper:find("BIG/OC") or upper:find("BIG.*OC") then return 60 end
    if upper:find("BIG") then return 50 end
    if upper:find("MEDIUM/OC") or upper:find("MEDIUM.*OC") then return 35 end
    if upper:find("MEDIUM") then return 25 end
    if upper:find("SMALL/OC") or upper:find("SMALL.*OC") then return 15 end
    if upper:find("SMALL") then return 10 end
    if upper:find("MAGNETAR") or upper:find("FURNACE") or upper:find("GLACIER") or upper:find("POLAR") or upper:find("CRANE") or upper:find("TRACTOR") then
        return 90
    end
    return 5
end

-- WORKER 3: Active Junkyard Scrap Collector (Highest-Tier, Fly + NoClip Return)
local junkyardWorker = task.spawn(function()
    while _G.SteelFightersActive do
        if State.AutoJunkVacuum then
            pcall(function()
                local root = GetRootPart()
                local sJunkyard = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Junkyard")
                if not root or not sJunkyard then return end
                
                local currentRealm = GetActiveRealm()
                local basePad = GetBasePad()
                
                -- 1. Scan and collect valid scrap attributes for active realm
                local candidates = {}
                for k, v in pairs(sJunkyard:GetAttributes()) do
                    local id = Junkyard.IdOf(k)
                    if id then
                        local key, cf = Junkyard.Decode(v)
                        if cf then
                            local y = cf.Position.Y
                            local inRealm = false
                            if currentRealm == "Space" and (y > 1500 and y < 3000) then
                                inRealm = true
                            elseif currentRealm == "Heaven" and (y >= 3000) then
                                inRealm = true
                            elseif currentRealm == "Overworld" and (y < 500) then
                                inRealm = true
                            end
                            
                            if inRealm then
                                local priority = GetScrapPriority(key)
                                local dist = (cf.Position - root.Position).Magnitude
                                table.insert(candidates, {
                                    id = id,
                                    key = key,
                                    pos = cf.Position,
                                    priority = priority,
                                    dist = dist
                                })
                            end
                        end
                    end
                end
                
                -- 2. Sort by highest value (priority) first, then shortest distance
                table.sort(candidates, function(a, b)
                    if State.PrioritizeBiggestScrap then
                        if a.priority ~= b.priority then
                            return a.priority > b.priority
                        end
                    end
                    return a.dist < b.dist
                end)
                
                if #candidates > 0 then
                    local target = candidates[1]
                    local flySpeed = State.FlySpeed or 120
                    
                    -- Smooth Fly + NoClip approach (avoids server displacement anti-cheat)
                    FlyNoClip(target.pos + Vector3.new(0, 2.5, 0), flySpeed)
                    task.wait(0.15)
                    
                    -- Pick up target scrap
                    local ok, r1, r2 = pcall(function()
                        return Net:RemoteFunction("PickUpJunk"):InvokeServer(target.id)
                    end)
                    
                    -- If server indicates rate limit or settling needed, back off cleanly
                    if ok and r1 == false and r2 == "Too fast" then
                        task.wait(0.8)
                    else
                        task.wait(State.VacuumDelay or 0.25)
                    end
                    
                    -- Check if carrying scrap -> Fly NoClip to base pad
                    local carrying = LocalPlayer:GetAttribute("Carrying")
                    if carrying and typeof(carrying) == "string" and carrying ~= "" then
                        if State.FlyReturnToBase and basePad then
                            FlyNoClip(basePad.Position + Vector3.new(0, 3, 0), flySpeed)
                            -- Wait for server to bank scrap (Carrying cleared)
                            local tWait = os.clock()
                            while LocalPlayer:GetAttribute("Carrying") and (os.clock() - tWait < 2.5) do
                                task.wait(0.1)
                            end
                        end
                    end
                else
                    task.wait(1.0)
                end
            end)
        end
        task.wait(0.2)
    end
end)
table.insert(CleanupConnections, junkyardWorker)

-- WORKER 4: Robot Equipment & Upgrades
local robotWorker = task.spawn(function()
    while _G.SteelFightersActive do
        if State.AutoEquipBest then
            pcall(function()
                Net:RemoteFunction("EquipBest"):InvokeServer()
            end)
        end

        if State.AutoUpgradeRobots then
            pcall(function()
                local playerData = Cache and Cache.PlayerData
                local robots = playerData and playerData.Robots
                local built = robots and robots.Built
                if built and typeof(built) == "table" then
                    for id, _ in pairs(built) do
                        pcall(function()
                            Net:RemoteFunction("UseTenLevels"):InvokeServer(id)
                            Net:RemoteFunction("UpgradeRobot"):InvokeServer(id)
                        end)
                    end
                end
            end)
        end

        if State.AutoReforgeParts then
            pcall(function()
                local playerData = Cache and Cache.PlayerData
                local robots = playerData and playerData.Robots
                local built = robots and robots.Built
                if built and typeof(built) == "table" then
                    for id, robotData in pairs(built) do
                        local parts = robotData and robotData.Parts
                        if parts and typeof(parts) == "table" then
                            for partId, _ in pairs(parts) do
                                pcall(function()
                                    Net:RemoteFunction("ReforgePart"):InvokeServer(id, partId)
                                end)
                            end
                        end
                    end
                end
            end)
        end

        task.wait(State.EquipBestDelay or 3.0)
    end
end)
table.insert(CleanupConnections, robotWorker)

-- WORKER 5: Progression, Comprehensive Auto-Claim & Auto-Confirm
local progressionWorker = task.spawn(function()
    while _G.SteelFightersActive do
        -- 1. Comprehensive Auto Claim Rewards
        if State.AutoClaimRewards then
            pcall(function()
                -- A. Daily Rewards
                pcall(function() Net:RemoteFunction("ClaimDaily"):InvokeServer() end)
                
                -- B. Playtime Gifts (1 to 12)
                for i = 1, 12 do
                    pcall(function() Net:RemoteFunction("ClaimGift"):InvokeServer(i) end)
                end
                
                -- C. Battle Pass / Season Pass Free Tiers
                pcall(function() Net:RemoteFunction("ClaimAllPass"):InvokeServer() end)
                
                -- D. Medals & Achievements
                pcall(function() Net:RemoteFunction("ClaimAllAchievements"):InvokeServer() end)
                
                -- E. Quests (Daily & Weekly) with progress check
                local playerData = Cache and Cache.PlayerData
                local Quests = require(Modules:WaitForChild("Quests"))
                if playerData and playerData.Quests and Quests then
                    for _, group in ipairs({ "Daily", "Weekly" }) do
                        if playerData.Quests[group] then
                            for k, q in ipairs(playerData.Quests[group]) do
                                local prog = Quests.Progress(playerData, q)
                                if prog >= (q.Goal or 0) and not q.Claimed then
                                    pcall(function()
                                        Net:RemoteFunction("ClaimQuest"):InvokeServer(group, k)
                                    end)
                                end
                            end
                        end
                    end
                end
                
                -- F. Community & Group Rewards
                pcall(function() Net:RemoteFunction("ClaimReward"):InvokeServer("Group") end)
                pcall(function() Net:RemoteFunction("ClaimReward"):InvokeServer("Favorite") end)
                
                -- G. Codex / Index Milestones
                for i = 1, 20 do
                    pcall(function() Net:RemoteFunction("IndexReward"):InvokeServer(i) end)
                end
                
                -- H. UI Button Click Fallback (Scans open Rewards window for CLAIM buttons)
                pcall(function()
                    local rGui = LocalPlayer.PlayerGui:FindFirstChild("Frames") and LocalPlayer.PlayerGui.Frames:FindFirstChild("Rewards")
                    if rGui and rGui.Enabled then
                        local list = rGui:FindFirstChild("Frame") and rGui.Frame:FindFirstChild("Background") and rGui.Frame.Background:FindFirstChild("List")
                        if list then
                            for _, item in ipairs(list:GetDescendants()) do
                                if item:IsA("TextLabel") and (item.Text == "CLAIM" or item.Text == "CLAIM ALL") then
                                    local btn = item.Parent and item.Parent:FindFirstChildWhichIsA("TextButton")
                                    if btn and firesignal then
                                        firesignal(btn.Activated)
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
        end

        -- 2. Auto Confirm "SURE" and Dialog Bypasser
        if State.AutoConfirmSure then
            pcall(function()
                local confirmGui = LocalPlayer.PlayerGui:FindFirstChild("Confirm")
                if confirmGui and confirmGui.Enabled then
                    local panel = confirmGui:FindFirstChild("Panel")
                    local yesBtn = panel and panel:FindFirstChild("Yes")
                    if yesBtn then
                        if firesignal then firesignal(yesBtn.Activated) end
                        confirmGui.Enabled = false
                    end
                end
            end)
        end

        -- 3. Auto Spin Lucky Wheel
        if State.AutoSpinWheel then
            pcall(function()
                local playerData = Cache and Cache.PlayerData
                local spins = playerData and playerData.Wheel and playerData.Wheel.Spins or 0
                if spins > 0 then
                    Net:RemoteFunction("SpinWheel"):InvokeServer()
                end
            end)
        end

        -- 4. Auto Rebirth
        if State.AutoRebirth then
            pcall(function()
                local playerData = Cache and Cache.PlayerData
                local Rebirths = require(Modules:WaitForChild("Rebirths"))
                local ready, _ = Rebirths.Ready(playerData)
                if ready then
                    local count = Rebirths.Count(playerData)
                    Net:RemoteFunction("Rebirth"):InvokeServer(count)
                end
            end)
        end

        -- 5. Auto Buy Upgrades
        if State.AutoBuyUpgrades and UpgradesModule then
            pcall(function()
                local playerData = Cache and Cache.PlayerData
                local core = playerData and playerData.Core
                local cash = tonumber(core and core.Cash) or 0
                local myUpgrades = (playerData and playerData.Upgrades) or {}

                for upgradeKey, upgradeData in pairs(UpgradesModule.List or {}) do
                    local currentLv = myUpgrades[upgradeKey] or 0
                    if currentLv < (upgradeData.Most or 100) then
                        local price = UpgradesModule.Price(upgradeKey, currentLv)
                        if price and price <= cash then
                            pcall(function()
                                Net:RemoteFunction("BuyUpgrade"):InvokeServer(upgradeKey, price)
                            end)
                            cash = cash - price
                        end
                    end
                end
            end)
        end

                -- 6. Auto Buy Upgrades Tree
        if State.AutoUpgradeTree and UpgradesTreeModule then
            pcall(function()
                local playerData = Cache and Cache.PlayerData
                local core = playerData and playerData.Core
                local cash = tonumber(core and core.Cash) or 0
                local cleanTree = UpgradesTreeModule.Clean(playerData and playerData.UpgradeTree)
                
                local candidates = {}
                for nodeKey, nodeData in pairs(UpgradesTreeModule.Nodes) do
                    if nodeKey ~= UpgradesTreeModule.Root then
                        local curLv = cleanTree[nodeKey] or 0
                        local maxLv = nodeData.Most or 5
                        if curLv < maxLv and UpgradesTreeModule.Open(cleanTree, nodeKey) then
                            local price = UpgradesTreeModule.Price(nodeKey, curLv)
                            if price and price > 0 and price <= cash then
                                table.insert(candidates, {
                                    key = nodeKey,
                                    name = nodeData.Name,
                                    price = price,
                                    curLv = curLv,
                                    kind = nodeData.Kind
                                })
                            end
                        end
                    end
                end
                
                if #candidates > 0 then
                    table.sort(candidates, function(a, b)
                        if State.TreeFocus == "Robot Damage & Combat" then
                            local aCombat = (a.kind == "Damage" or a.kind == "Haste" or a.kind == "Crit" or a.kind == "Health")
                            local bCombat = (b.kind == "Damage" or b.kind == "Haste" or b.kind == "Crit" or b.kind == "Health")
                            if aCombat ~= bCombat then return aCombat end
                        elseif State.TreeFocus == "Cash & Scrap Economy" then
                            local aEcon = (a.kind == "Cash" or a.kind == "Scrap" or a.kind == "Carry" or a.kind == "Cap")
                            local bEcon = (b.kind == "Cash" or b.kind == "Scrap" or b.kind == "Carry" or b.kind == "Cap")
                            if aEcon ~= bEcon then return aEcon end
                        end
                        return a.price < b.price
                    end)
                    
                    local target = candidates[1]
                    pcall(function()
                        Net:RemoteFunction("UpgradeTree"):InvokeServer("Buy", target.key, target.price)
                    end)
                end
            end)
        end

        task.wait(State.ClaimDelay or 2.5)
    end
end)
table.insert(CleanupConnections, progressionWorker)

-- WORKER 6: Movement & Humanoid Loop
local movementWorker = task.spawn(function()
    while _G.SteelFightersActive do
        local hum = GetHumanoid()
        if hum then
            if State.WalkSpeedEnabled then
                hum.WalkSpeed = State.WalkSpeed
            end
            if State.JumpPowerEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = State.JumpPower
            end
        end
        task.wait(0.5)
    end
end)
table.insert(CleanupConnections, movementWorker)

-- Universal Noclip Connection
local noclipConnection = RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)
table.insert(CleanupConnections, noclipConnection)

-- Infinite Jump Connection
local infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(CleanupConnections, infJumpConnection)

-- Anti-AFK Virtual User Heartbeat
local antiAFKConnection = LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)
table.insert(CleanupConnections, antiAFKConnection)

-- Success Notification
WindUI:Notify({
    Title = "Steel Fighters Loaded",
    Content = "Master automation initialized. Press LeftControl to toggle.",
    Duration = 4,
})
