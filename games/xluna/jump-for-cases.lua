-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- Jump for Casesð² Master Automation Suite
-- Strict SOP Compliance: WindUI, English UI, All-Off Default, Config Support, Zero AI Slop

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)

-- Clean up any prior running session
if _G.JumpForCasesRunning and type(_G.JumpForCasesCleanup) == "function" then
    pcall(_G.JumpForCasesCleanup)
end
_G.JumpForCasesRunning = true

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- State Configuration (ALL OFF BY DEFAULT)
local Settings = {
    -- Auto Jump & Case Loop
    AutoJump = false,
    ReturnDestination = "Continuous (Launch Pad)", -- "Continuous (Launch Pad)", "My Base Plot", "Safezone"
    InstantSafeClaim = true,

    -- Farm & Training
    AutoTrainRush = false,
    AutoCollectCash = false,
    AutoPlacePets = false,
    AutoRebirth = false,

    -- Progression & Upgrades
    AutoSpeedUpgrade = false,
    AutoBaseUpgrade = false,
    AutoMaxSlots = false,
    AutoBuyWeight = false,

    -- Case Opening
    AutoOpenCases = false,
    SelectedCase = "All Owned",
    OpenMulti = true,
    SkipOpeningAnim = false,

    -- Rewards
    AutoFreeSpin = false,
    AutoDailyReward = false,
    AutoIndexGems = false,
    AutoGifts = false,
    AutoForeverReward = false,
    AutoLikeReward = false,
    AutoOfflineClaim = false,

    -- Player Modifiers
    CustomWalkSpeed = false,
    WalkSpeedValue = 35,
    InfiniteJump = false,
}

-- Config System
local ConfigFolder = "JumpForCases"
local ConfigFile = ConfigFolder .. "/config.json"

local function SaveConfig()
    if writefile and makefolder then
        pcall(makefolder, ConfigFolder)
        local data = HttpService:JSONEncode(Settings)
        pcall(writefile, ConfigFile, data)
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Settings successfully saved to storage.",
            Duration = 3,
            Icon = "check",
        })
    end
end

local Toggles = {}

local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, content = pcall(readfile, ConfigFile)
        if success and content then
            local successDecode, decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if successDecode and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Settings[k] ~= nil then
                        Settings[k] = v
                        if Toggles[k] and type(Toggles[k].Set) == "function" then
                            pcall(Toggles[k].Set, Toggles[k], v)
                        end
                    end
                end
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Settings successfully restored.",
                    Duration = 3,
                    Icon = "folder-open",
                })
                return
            end
        end
    end
    WindUI:Notify({
        Title = "Config Notice",
        Content = "No valid saved config found.",
        Duration = 3,
        Icon = "alert-circle",
    })
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Jump for Cases",
    Author = "Master Automation Suite",
    Icon = "dice-5",
    Folder = ConfigFolder,
    Size = UDim2.fromOffset(640, 520),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "Jump for Cases",
        Icon = "dice-5",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromRGB(130, 80, 255),
            Color3.fromRGB(60, 180, 255)
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

-- LeftControl Keybind fallback
local keybindConn = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
        if Window and type(Window.Toggle) == "function" then
            Window:Toggle()
        end
    end
end)

-- Create Tabs
local TabJump = Window:Tab({ Title = "Auto Jump", Icon = "flame" })
local TabFarm = Window:Tab({ Title = "Farming", Icon = "zap" })
local TabUpgrades = Window:Tab({ Title = "Upgrades", Icon = "trending-up" })
local TabCases = Window:Tab({ Title = "Cases", Icon = "package" })
local TabRewards = Window:Tab({ Title = "Rewards", Icon = "gift" })
local TabPlayer = Window:Tab({ Title = "Player & TPs", Icon = "user" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

----------------------------------------------------------------------
-- TAB 1: AUTO JUMP & SAFE CLAIM
----------------------------------------------------------------------
TabJump:Section({ Title = "Jump & Case Loop Settings" })

Toggles.AutoJump = TabJump:Toggle({
    Title = "Enable Auto Jump Cycle",
    Desc = "Auto warps to KickZone, executes Perfect Kick, secures Case at Safezone, and returns",
    Value = Settings.AutoJump,
    Callback = function(val)
        Settings.AutoJump = val
    end,
})

TabJump:Dropdown({
    Title = "After Securing Case",
    Desc = "Choose where to return after securing the case from the jump",
    Values = { "Continuous (Launch Pad)", "My Base Plot", "Safezone" },
    Value = Settings.ReturnDestination,
    Callback = function(val)
        Settings.ReturnDestination = val
    end,
})

Toggles.InstantSafeClaim = TabJump:Toggle({
    Title = "Anti-Tsunami Safe Claim Bypass",
    Desc = "Instantly deposits case at Safezone before the wave can spawn/reach you",
    Value = Settings.InstantSafeClaim,
    Callback = function(val)
        Settings.InstantSafeClaim = val
    end,
})

----------------------------------------------------------------------
-- TAB 2: FARMING
----------------------------------------------------------------------
TabFarm:Section({ Title = "Plot & Training Automation" })

Toggles.AutoTrainRush = TabFarm:Toggle({
    Title = "Auto Train Rush (100% Hit)",
    Desc = "Hits every Training Rush circle on the exact frame it spawns for max multiplier",
    Value = Settings.AutoTrainRush,
    Callback = function(val)
        Settings.AutoTrainRush = val
    end,
})

Toggles.AutoCollectCash = TabFarm:Toggle({
    Title = "Auto Collect Plot Cash",
    Desc = "Collects accumulated cash from all 30 base pet slots headlessly",
    Value = Settings.AutoCollectCash,
    Callback = function(val)
        Settings.AutoCollectCash = val
    end,
})

Toggles.AutoPlacePets = TabFarm:Toggle({
    Title = "Auto Place Best Pets",
    Desc = "Automatically slots your highest multiplier pets onto your base",
    Value = Settings.AutoPlacePets,
    Callback = function(val)
        Settings.AutoPlacePets = val
    end,
})

Toggles.AutoRebirth = TabFarm:Toggle({
    Title = "Auto Rebirth",
    Desc = "Automatically rebirths as soon as the required Jump Power threshold is reached",
    Value = Settings.AutoRebirth,
    Callback = function(val)
        Settings.AutoRebirth = val
    end,
})

----------------------------------------------------------------------
-- TAB 3: UPGRADES
----------------------------------------------------------------------
TabUpgrades:Section({ Title = "Progression Upgrades" })

Toggles.AutoSpeedUpgrade = TabUpgrades:Toggle({
    Title = "Auto Upgrade Speed",
    Desc = "Buys speed upgrades as soon as your cash balance allows",
    Value = Settings.AutoSpeedUpgrade,
    Callback = function(val)
        Settings.AutoSpeedUpgrade = val
    end,
})

Toggles.AutoBaseUpgrade = TabUpgrades:Toggle({
    Title = "Auto Upgrade Base",
    Desc = "Upgrades your base building to unlock upper floors and decor",
    Value = Settings.AutoBaseUpgrade,
    Callback = function(val)
        Settings.AutoBaseUpgrade = val
    end,
})

Toggles.AutoMaxSlots = TabUpgrades:Toggle({
    Title = "Auto Max Slot Levels",
    Desc = "Automatically upgrades all pet slots on your base to their max level",
    Value = Settings.AutoMaxSlots,
    Callback = function(val)
        Settings.AutoMaxSlots = val
    end,
})

Toggles.AutoBuyWeight = TabUpgrades:Toggle({
    Title = "Auto Buy & Equip Best Barbell",
    Desc = "Continuously buys and equips the heaviest affordable barbell for training",
    Value = Settings.AutoBuyWeight,
    Callback = function(val)
        Settings.AutoBuyWeight = val
    end,
})

----------------------------------------------------------------------
-- TAB 4: CASES
----------------------------------------------------------------------
TabCases:Section({ Title = "Case Unboxing" })

local CaseList = { "All Owned" }
pcall(function()
    local cfg = require(ReplicatedStorage:WaitForChild("CasesConfig", 5))
    local temp = {}
    for k, _ in pairs(cfg.Cases or {}) do
        table.insert(temp, tostring(k))
    end
    table.sort(temp)
    for _, c in ipairs(temp) do
        table.insert(CaseList, c)
    end
end)

TabCases:Dropdown({
    Title = "Select Case to Open",
    Desc = "Choose a specific case or open all owned cases",
    Values = CaseList,
    Value = Settings.SelectedCase,
    Callback = function(val)
        Settings.SelectedCase = val
    end,
})

Toggles.OpenMulti = TabCases:Toggle({
    Title = "Multi Open (x3)",
    Desc = "Opens cases 3 at a time for faster unboxing speed",
    Value = Settings.OpenMulti,
    Callback = function(val)
        Settings.OpenMulti = val
    end,
})

Toggles.SkipOpeningAnim = TabCases:Toggle({
    Title = "Fast Open (Skip Animations)",
    Desc = "Bypasses 3D unboxing animation cutscenes",
    Value = Settings.SkipOpeningAnim,
    Callback = function(val)
        Settings.SkipOpeningAnim = val
        LocalPlayer:SetAttribute("_ShowCasesOpening", not val)
    end,
})

Toggles.AutoOpenCases = TabCases:Toggle({
    Title = "Auto Open Cases",
    Desc = "Continuously unboxes cases in the background",
    Value = Settings.AutoOpenCases,
    Callback = function(val)
        Settings.AutoOpenCases = val
    end,
})

----------------------------------------------------------------------
-- TAB 5: REWARDS
----------------------------------------------------------------------
TabRewards:Section({ Title = "Free Rewards & Claims" })

Toggles.AutoFreeSpin = TabRewards:Toggle({
    Title = "Auto Free Wheel Spin",
    Desc = "Spins the lucky wheel whenever a free spin is ready",
    Value = Settings.AutoFreeSpin,
    Callback = function(val)
        Settings.AutoFreeSpin = val
    end,
})

Toggles.AutoDailyReward = TabRewards:Toggle({
    Title = "Auto Claim Daily Reward",
    Desc = "Claims the daily login reward",
    Value = Settings.AutoDailyReward,
    Callback = function(val)
        Settings.AutoDailyReward = val
    end,
})

Toggles.AutoIndexGems = TabRewards:Toggle({
    Title = "Auto Claim Index Gems",
    Desc = "Claims all uncollected index discovery gems",
    Value = Settings.AutoIndexGems,
    Callback = function(val)
        Settings.AutoIndexGems = val
    end,
})

Toggles.AutoGifts = TabRewards:Toggle({
    Title = "Auto Claim Playtime Gifts",
    Desc = "Claims playtime gift boxes (1 through 12)",
    Value = Settings.AutoGifts,
    Callback = function(val)
        Settings.AutoGifts = val
    end,
})

Toggles.AutoForeverReward = TabRewards:Toggle({
    Title = "Auto Claim Forever Reward",
    Desc = "Claims ongoing free rewards from the forever shop",
    Value = Settings.AutoForeverReward,
    Callback = function(val)
        Settings.AutoForeverReward = val
    end,
})

Toggles.AutoLikeReward = TabRewards:Toggle({
    Title = "Auto Claim Like Reward",
    Desc = "Claims the like verification community reward",
    Value = Settings.AutoLikeReward,
    Callback = function(val)
        Settings.AutoLikeReward = val
    end,
})

Toggles.AutoOfflineClaim = TabRewards:Toggle({
    Title = "Auto Claim 10x Offline Earnings",
    Desc = "Claims offline earnings with 10x boost",
    Value = Settings.AutoOfflineClaim,
    Callback = function(val)
        Settings.AutoOfflineClaim = val
    end,
})

TabRewards:Section({ Title = "Code Redemption" })

local PromoCode = "LuckyDuck"
TabRewards:Input({
    Title = "Promo Code",
    Value = PromoCode,
    Callback = function(val)
        PromoCode = val
    end,
})

TabRewards:Button({
    Title = "Redeem Code",
    Callback = function()
        pcall(function()
            local RedeemCode = Remotes:FindFirstChild("RedeemCode")
            if RedeemCode and RedeemCode:IsA("RemoteFunction") then
                local res = RedeemCode:InvokeServer(PromoCode)
                if type(res) == "table" then
                    WindUI:Notify({
                        Title = res.ok and "Code Redeemed" or "Redeem Error",
                        Content = res.message or (res.ok and "Success!" or "Failed"),
                        Duration = 3,
                        Icon = res.ok and "check" or "alert-triangle",
                    })
                end
            end
        end)
    end,
})

----------------------------------------------------------------------
-- TAB 6: PLAYER & TELEPORTS
----------------------------------------------------------------------
TabPlayer:Section({ Title = "Movement Modifiers" })

Toggles.CustomWalkSpeed = TabPlayer:Toggle({
    Title = "Custom WalkSpeed",
    Desc = "Maintains chosen walk speed with automatic reset bypass",
    Value = Settings.CustomWalkSpeed,
    Callback = function(val)
        Settings.CustomWalkSpeed = val
    end,
})

TabPlayer:Slider({
    Title = "WalkSpeed Value",
    Value = {
        Min = 16,
        Max = 120,
        Default = Settings.WalkSpeedValue,
    },
    Step = 1,
    Callback = function(val)
        Settings.WalkSpeedValue = val
    end,
})

Toggles.InfiniteJump = TabPlayer:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump endlessly in mid-air",
    Value = Settings.InfiniteJump,
    Callback = function(val)
        Settings.InfiniteJump = val
    end,
})

local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

TabPlayer:Section({ Title = "Teleports" })

local function GetBasePlotPos()
    local plotNum = LocalPlayer:GetAttribute("BasePlot")
    if plotNum then
        local plots = Workspace:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild("Plot" .. plotNum)
        if plot then
            local primary = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
            if primary then
                return primary.Position + Vector3.new(0, 5, 0)
            end
        end
    end
    return Vector3.new(145.44, 34.22, -20.01)
end

local TeleportPoints = {
    ["Launch Pad"] = Vector3.new(207.25, 36.5, 104.95),
    ["Safezone"] = Vector3.new(207.25, 25, 115),
    ["Weight Shop"] = Vector3.new(300.04, 23.87, 82.64),
    ["Speed Shop"] = Vector3.new(276.13, 23.71, 81.73),
    ["Sell Shop"] = Vector3.new(325.32, 23.85, 83.00),
}

local SelectedTp = "Launch Pad"
TabPlayer:Dropdown({
    Title = "Select Destination",
    Values = { "Launch Pad", "My Base Plot", "Safezone", "Weight Shop", "Speed Shop", "Sell Shop" },
    Value = SelectedTp,
    Callback = function(val)
        SelectedTp = val
    end,
})

TabPlayer:Button({
    Title = "Teleport",
    Desc = "Warps immediately to destination",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local dest = nil
        if SelectedTp == "My Base Plot" then
            dest = GetBasePlotPos()
        else
            dest = TeleportPoints[SelectedTp]
        end

        if dest then
            hrp.CFrame = CFrame.new(dest)
        end
    end,
})

----------------------------------------------------------------------
-- TAB 7: CONFIG
----------------------------------------------------------------------
TabConfig:Section({ Title = "Profile Management" })

TabConfig:Button({
    Title = "Save Config",
    Desc = "Saves active settings to JSON storage",
    Callback = SaveConfig,
})

TabConfig:Button({
    Title = "Load Config",
    Desc = "Restores settings from JSON storage",
    Callback = LoadConfig,
})

----------------------------------------------------------------------
-- ADVANCED BACKGROUND AUTOMATION ENGINE
----------------------------------------------------------------------

-- 1. Training Rush Auto-Hit (Hooks OsuTrain remote)
pcall(function()
    local OsuTrain = Remotes:WaitForChild("OsuTrain", 5)
    if OsuTrain then
        OsuTrain.OnClientEvent:Connect(function(data)
            if Settings.AutoTrainRush and type(data) == "table" and data.kind == "spawn" and data.id then
                pcall(function()
                    OsuTrain:FireServer({ kind = "hit", id = data.id })
                end)
            end
        end)
    end
end)

-- 2. MASTER AUTO JUMP & SAFE RETURN ENGINE
task.spawn(function()
    local renv = getrenv()
    local remKick = Remotes:WaitForChild("RequestKick", 10)
    local remFall = Remotes:WaitForChild("FallRewardEvent", 10)
    local remRespawn = Remotes:WaitForChild("RespawnPrompt", 10)

    local lastJumpAttempt = 0
    local jumpState = "IDLE" -- "IDLE", "LAUNCHING", "FLYING", "LANDED_CLAIMING", "RETURNING"

    while _G.JumpForCasesRunning do
        task.wait(0.2)

        if Settings.AutoJump then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Always clear any respawn offer that blocks jump logic
                if LocalPlayer:GetAttribute("_RespawnOffer") == true and remRespawn then
                    remRespawn:FireServer({ kind = "decline" })
                end

                local isKicking = LocalPlayer:GetAttribute("_IsKicking") == true
                local inSession = LocalPlayer:GetAttribute("_InKickSession") == true
                local holding = LocalPlayer:GetAttribute("_HoldingCase")
                local hasCase = (type(holding) == "string" and holding ~= "")

                -- CASE CLAIM & SAFE RETURN PHASE
                if hasCase then
                    jumpState = "LANDED_CLAIMING"

                    if Settings.InstantSafeClaim then
                        -- Teleport directly to Safezone (Z = 115 < Safezone Z=122.75)
                        hrp.CFrame = CFrame.new(207.25, 25, 115)
                        task.wait(0.1)
                        for i = 1, 5 do
                            if remFall then
                                remFall:FireServer({ kind = "safeClaim" })
                            end
                            task.wait(0.08)
                        end
                    else
                        -- Path smoothly to CollectZone
                        local zones = Workspace:FindFirstChild("Zones")
                        local collectZone = zones and zones:FindFirstChild("CollectZone")
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if collectZone and hum then
                            hum:MoveTo(Vector3.new(collectZone.Position.X, hrp.Position.Y, collectZone.Position.Z))
                        end
                    end

                    -- Check if case deposited
                    task.wait(0.2)
                    local afterHold = LocalPlayer:GetAttribute("_HoldingCase")
                    if afterHold == nil or afterHold == "" then
                        -- Case is secured! Execute Return Destination
                        jumpState = "RETURNING"
                        task.wait(0.3)

                        if Settings.ReturnDestination == "My Base Plot" then
                            hrp.CFrame = CFrame.new(GetBasePlotPos())
                            task.wait(1.5)
                        elseif Settings.ReturnDestination == "Safezone" then
                            hrp.CFrame = CFrame.new(207.25, 25, 115)
                            task.wait(1.5)
                        elseif Settings.ReturnDestination == "Continuous (Launch Pad)" then
                            hrp.CFrame = CFrame.new(207.25, 36.5, 104.95)
                            task.wait(0.4)
                        end

                        jumpState = "IDLE"
                    end
                    return
                end

                -- FLIGHT PHASE
                if isKicking then
                    jumpState = "FLYING"
                    return
                end

                -- LAUNCH PHASE
                if jumpState == "IDLE" or jumpState == "RETURNING" then
                    -- Watchdog: clear session if stuck
                    if inSession and os.clock() - lastJumpAttempt > 15 then
                        if remKick then remKick:FireServer({ action = "cancel" }) end
                        task.wait(0.3)
                    end

                    local ka = renv._G.KickAuto
                    local inZone = (ka and type(ka.state) == "function" and ka.state().inZone)

                    if not inZone then
                        -- Teleport directly into KickZone
                        hrp.CFrame = CFrame.new(207.25, 36.5, 104.95)
                        task.wait(0.35)
                        return
                    end

                    -- Execute kick when ready in KickZone
                    if os.clock() - lastJumpAttempt > 2.0 then
                        lastJumpAttempt = os.clock()
                        jumpState = "LAUNCHING"

                        if ka and type(ka.press) == "function" then
                            ka.press()
                        end

                        task.wait(0.55) -- Wait for maximum oscillation (Perfect tier)

                        local locked = false
                        if ka and type(ka.lock) == "function" then
                            locked = pcall(ka.lock)
                        end

                        if not locked and remKick then
                            remKick:FireServer({ tier = "Perfect" })
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Collect Plot Cash Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(1.5)
        if Settings.AutoCollectCash then
            pcall(function()
                local plotIndex = LocalPlayer:GetAttribute("BasePlot")
                local RequestCollect = Remotes:FindFirstChild("RequestCollect")
                if plotIndex and RequestCollect then
                    for slotId = 1, 30 do
                        RequestCollect:FireServer(plotIndex, slotId)
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Place Best Pets Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(4)
        if Settings.AutoPlacePets then
            pcall(function()
                local RequestAutoPlace = Remotes:FindFirstChild("RequestAutoPlace")
                if RequestAutoPlace then
                    RequestAutoPlace:FireServer()
                end
            end)
        end
    end
end)

-- 5. Auto Rebirth Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(2)
        if Settings.AutoRebirth then
            pcall(function()
                local currentRebirths = LocalPlayer:GetAttribute("Rebirths") or 0
                local currentPower = LocalPlayer:GetAttribute("KickPower") or 0
                local r = math.max(0, math.floor(currentRebirths))

                local req = 15000
                if r == 1 then
                    req = 50000
                elseif r <= 6 then
                    req = 10 ^ r * 1000
                elseif r <= 8 then
                    req = 5 ^ (r - 6) * 1000000000
                else
                    req = 2 ^ (r - 8) * 25000000000
                end

                if currentPower >= req then
                    local RequestRebirth = Remotes:FindFirstChild("RequestRebirth")
                    if RequestRebirth then
                        RequestRebirth:FireServer({ mode = "rebirth" })
                    end
                end
            end)
        end
    end
end)

-- 6. Auto Upgrade Speed Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(2)
        if Settings.AutoSpeedUpgrade then
            pcall(function()
                local cfg = require(ReplicatedStorage:WaitForChild("SpeedUpgradesConfig", 2))
                local cur = LocalPlayer:GetAttribute("SpeedUpgrades") or 0
                local cost = cfg and cfg.UnitCost and cfg.UnitCost(cur) or 500
                local cash = LocalPlayer:GetAttribute("Cash") or 0

                if cash >= cost then
                    local RequestSpeedUpgrade = Remotes:FindFirstChild("RequestSpeedUpgrade")
                    if RequestSpeedUpgrade then
                        RequestSpeedUpgrade:FireServer({ index = 1, introFree = false })
                    end
                end
            end)
        end
    end
end)

-- 7. Auto Upgrade Base & Max Slots Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(2.5)
        pcall(function()
            if Settings.AutoBaseUpgrade then
                local RequestBaseUpgrade = Remotes:FindFirstChild("RequestBaseUpgrade")
                if RequestBaseUpgrade then
                    RequestBaseUpgrade:FireServer({ kind = "base" })
                end
            end

            if Settings.AutoMaxSlots then
                local RequestSlotLevelMax = Remotes:FindFirstChild("RequestSlotLevelMax")
                if RequestSlotLevelMax then
                    for slot = 1, 30 do
                        RequestSlotLevelMax:FireServer({ slot = slot })
                    end
                end
            end
        end)
    end
end)

-- 8. Auto Buy & Equip Best Barbell Loop
task.spawn(function()
    local WeightsCache = nil
    pcall(function()
        local cfg = require(ReplicatedStorage:WaitForChild("WeightsConfig", 2))
        local temp = {}
        for k, v in pairs(cfg.Weights or cfg) do
            if type(v) == "table" and (v.Price or v.Cost) then
                table.insert(temp, { name = tostring(k), price = tonumber(v.Price or v.Cost) or 0 })
            end
        end
        table.sort(temp, function(a, b) return a.price < b.price end)
        WeightsCache = temp
    end)

    while _G.JumpForCasesRunning do
        task.wait(4)
        if Settings.AutoBuyWeight and WeightsCache then
            pcall(function()
                local cash = LocalPlayer:GetAttribute("Cash") or 0
                local equipped = LocalPlayer:GetAttribute("EquippedWeight")
                local target = nil

                for _, w in ipairs(WeightsCache) do
                    if cash >= w.price then
                        target = w.name
                    end
                end

                if target and target ~= equipped then
                    local RequestBuyWeight = Remotes:FindFirstChild("RequestBuyWeight")
                    local RequestEquipWeight = Remotes:FindFirstChild("RequestEquipWeight")
                    if RequestBuyWeight then
                        RequestBuyWeight:FireServer({ key = target })
                    end
                    task.wait(0.2)
                    if RequestEquipWeight then
                        RequestEquipWeight:FireServer({ key = target })
                    end
                end
            end)
        end
    end
end)

-- 9. Auto Open Cases Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(0.5)
        if Settings.AutoOpenCases then
            pcall(function()
                local RequestOpenCase = Remotes:FindFirstChild("RequestOpenCase")
                local RequestOpenCaseMulti = Remotes:FindFirstChild("RequestOpenCaseMulti")

                if Settings.SelectedCase == "All Owned" then
                    for _, c in ipairs(CaseList) do
                        if c ~= "All Owned" then
                            local count = tonumber(LocalPlayer:GetAttribute("Cases_" .. c)) or 0
                            if count > 0 then
                                if Settings.OpenMulti and count >= 2 and RequestOpenCaseMulti then
                                    RequestOpenCaseMulti:FireServer({ case = c, count = math.min(count, 3) })
                                elseif RequestOpenCase then
                                    RequestOpenCase:FireServer(c)
                                end
                                task.wait(0.35)
                            end
                        end
                    end
                else
                    local c = Settings.SelectedCase
                    local count = tonumber(LocalPlayer:GetAttribute("Cases_" .. c)) or 0
                    if count > 0 then
                        if Settings.OpenMulti and count >= 2 and RequestOpenCaseMulti then
                            RequestOpenCaseMulti:FireServer({ case = c, count = math.min(count, 3) })
                        elseif RequestOpenCase then
                            RequestOpenCase:FireServer(c)
                        end
                    end
                end
            end)
        end
    end
end)

-- 10. Auto Claim Rewards Loop
task.spawn(function()
    while _G.JumpForCasesRunning do
        task.wait(3)
        pcall(function()
            if Settings.AutoFreeSpin then
                local RequestSpinWheel = Remotes:FindFirstChild("RequestSpinWheel")
                if RequestSpinWheel then
                    RequestSpinWheel:FireServer({ mode = "free" })
                end
            end

            if Settings.AutoDailyReward then
                local RequestDailyClaim = Remotes:FindFirstChild("RequestDailyClaim")
                if RequestDailyClaim then
                    RequestDailyClaim:FireServer()
                end
            end

            if Settings.AutoIndexGems then
                local RequestClaimAllIndexGems = Remotes:FindFirstChild("RequestClaimAllIndexGems")
                if RequestClaimAllIndexGems then
                    RequestClaimAllIndexGems:FireServer()
                end
            end

            if Settings.AutoGifts then
                local RequestOpenGift = Remotes:FindFirstChild("RequestOpenGift")
                if RequestOpenGift then
                    for giftId = 1, 12 do
                        RequestOpenGift:FireServer(giftId)
                    end
                end
            end

            if Settings.AutoForeverReward then
                local RequestCollectForeverReward = Remotes:FindFirstChild("RequestCollectForeverReward")
                if RequestCollectForeverReward then
                    RequestCollectForeverReward:FireServer(1)
                end
            end

            if Settings.AutoLikeReward then
                local RequestClaimLikeReward = Remotes:FindFirstChild("RequestClaimLikeReward")
                if RequestClaimLikeReward and RequestClaimLikeReward:IsA("RemoteFunction") then
                    RequestClaimLikeReward:InvokeServer()
                end
            end

            if Settings.AutoOfflineClaim then
                local RequestClaim10xOffline = Remotes:FindFirstChild("RequestClaim10xOffline")
                if RequestClaim10xOffline then
                    RequestClaim10xOffline:FireServer()
                end
            end
        end)
    end
end)

-- 11. WalkSpeed Heartbeat Enforcer
RunService.Heartbeat:Connect(function()
    if Settings.CustomWalkSpeed then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= Settings.WalkSpeedValue then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end
    end
end)

-- Cleanup Handler
_G.JumpForCasesCleanup = function()
    _G.JumpForCasesRunning = false
    pcall(function() keybindConn:Disconnect() end)
    pcall(function() infJumpConn:Disconnect() end)
    if Window and type(Window.Destroy) == "function" then
        pcall(Window.Destroy, Window)
    end
end

WindUI:Notify({
    Title = "Jump for Cases",
    Content = "Master Suite Ready. LeftControl to toggle.",
    Duration = 4,
    Icon = "check-circle",
})
