-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    STORAGE HUNTERS: OPEN WORLD â MASTER AUTOMATION SUITE
    Author: By XLunaHUB
    UI Framework: WindUI | Language: English
    Keybind: LeftControl (Show/Hide) | Floating Button: Enabled (Draggable)
    Default State: ALL OFF (All toggles disabled at startup)
    Stealth: GUI & ESP parented to gethui()/CoreGui (PlayerGui untouched)
    ========================================================================
]]

-- -------------------------------------------------------------------------
-- 1. SERVICES & PREVIOUS INSTANCE CLEANUP
-- -------------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if getgenv().XLunaSHOW_Unload then
    pcall(getgenv().XLunaSHOW_Unload)
end

local setIdentityFn = setthreadidentity or (syn and syn.set_thread_identity) or setidentity

local function ensureElevatedIdentity()
    if type(setIdentityFn) == "function" then
        pcall(setIdentityFn, 8)
    end
end

local function safeWait(sec)
    local dt = task.wait(sec)
    ensureElevatedIdentity()
    return dt
end

ensureElevatedIdentity()

local Connections = {}
local Threads = {}
local Cleanups = {}

local function trackConn(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function trackThread(fn)
    local co = task.spawn(function()
        ensureElevatedIdentity()
        fn()
    end)
    table.insert(Threads, co)
    return co
end

local function getStealthContainerParent()
    ensureElevatedIdentity()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then
            return hui
        end
    end
    return CoreGui
end

-- -------------------------------------------------------------------------
-- 2. SAFE MODULE & REMOTE RESOLVERS
-- -------------------------------------------------------------------------
local function safeRequire(inst)
    if not inst or not inst:IsA("ModuleScript") then
        return nil
    end
    local ok, mod = pcall(require, inst)
    ensureElevatedIdentity()
    return ok and mod or nil
end

local function findChildPath(root, ...)
    local cur = root
    for _, name in ipairs({...}) do
        if not cur then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end

local ModulesFolder = ReplicatedStorage:FindFirstChild("Modules")
local EventsFolder = ReplicatedStorage:FindFirstChild("Events")

local ItemsMod = safeRequire(findChildPath(ModulesFolder, "Items"))
local GaragesMod = safeRequire(findChildPath(ModulesFolder, "Garages"))
local MutatorModule = safeRequire(findChildPath(ModulesFolder, "MutatorModule"))
local GameConfigMod = safeRequire(findChildPath(ModulesFolder, "GameConfig"))
local SafesMod = safeRequire(findChildPath(ModulesFolder, "Safes"))
local PicklockMod = safeRequire(findChildPath(ModulesFolder, "Picklock"))
local WrenchMod = safeRequire(findChildPath(ModulesFolder, "Wrench"))
local CleaningConfigMod = safeRequire(findChildPath(ModulesFolder, "CleaningConfig"))
local CollectionsMod = safeRequire(findChildPath(ModulesFolder, "Collections"))
local ShopUpgradesConfigMod = safeRequire(findChildPath(ModulesFolder, "ShopUpgradesConfig"))
local FishingBaitConfigMod = safeRequire(findChildPath(ModulesFolder, "FishingBaitConfig"))
local StockSaleRulesMod = safeRequire(findChildPath(ModulesFolder, "StockSaleRules"))
local ItemGridPanelMod = safeRequire(findChildPath(ModulesFolder, "Utils", "ItemGridPanel"))
local GradingUtil = GameConfigMod and GameConfigMod.Grading or nil

-- Remotes
local AuctionEvents = findChildPath(EventsFolder, "Auction")
local PlotEvents = findChildPath(EventsFolder, "Plot")
local NPCEvents = findChildPath(EventsFolder, "NPCShopper")
local PawnEvents = findChildPath(EventsFolder, "Pawn")
local VehicleEvents = findChildPath(EventsFolder, "Vehicles")
local InventoryEvents = findChildPath(EventsFolder, "Inventory")
local LocksmithEvents = findChildPath(EventsFolder, "Locksmith")
local CleaningEvents = findChildPath(EventsFolder, "Cleaning")
local WashEvents = findChildPath(EventsFolder, "Wash")
local RepairEvents = findChildPath(EventsFolder, "Repair")
local GradingEvents = findChildPath(EventsFolder, "Grading")
local AuthEvents = findChildPath(EventsFolder, "Authentication")
local MuseumEvents = findChildPath(EventsFolder, "Museum")
local TimeCapsuleEvents = findChildPath(EventsFolder, "TimeCapsule")
local WrenchEvents = findChildPath(EventsFolder, "WrenchShop")
local CollectionsEvents = findChildPath(EventsFolder, "Collections")
local AchievementEvents = findChildPath(EventsFolder, "Achievements")
local DailyEvents = findChildPath(EventsFolder, "DailyReward")
local UpgradeEvents = findChildPath(EventsFolder, "Upgrades")
local GPSEvents = findChildPath(EventsFolder, "GPS")
local UIEvents = findChildPath(EventsFolder, "UI")
local MiscEvents = findChildPath(EventsFolder, "Misc")
local LostItemsEvents = findChildPath(EventsFolder, "LostItems") -- fallback via UIEvents
local FreightEvents = findChildPath(EventsFolder, "MissingFreight")
local NuggetEvents = findChildPath(EventsFolder, "GoldNuggetDrops")
local BaitEvents = findChildPath(EventsFolder, "FishingBait")
local WarehouseEvents = findChildPath(EventsFolder, "WarehouseOrders")
local MiningEvents = findChildPath(EventsFolder, "MiningSeason")

local FullbrightActive = false
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- -------------------------------------------------------------------------
-- 3. STATE STORE (STRICTLY ALL OFF ON STARTUP) & CONFIG PERSISTENCE
-- -------------------------------------------------------------------------
local CONFIG_DIR = "XLunaHUB_StorageHuntersOW"
local CONFIG_PATH = CONFIG_DIR .. "/config.json"

local State = {
    -- Auctions, Auto-Play & Sniper
    AutoPlayLoop = false,
    AutoPlayAreaFilter = "Best Unlocked (Auto)",
    AutoPlaySellMode = "Stock Shelves + Pawn Overflow",
    AutoBidSniper = false,
    AutoBidMode = "Smart Profit Cap",
    MaxBidValuePct = 110,
    MinNetProfit = 0,
    BidReactionDelay = 0.18,
    RequireSafeOrMut = false,
    AlwaysPerfectBidBar = false,
    AutoSkipCinematics = false,
    AutoLootWonItems = false,
    InstantPrompts = false,
    AutoWrenchRepairWon = false,

    -- Shop, Stock & Pawn
    AutoStockShelves = false,
    AutoOptimizePrices = false,
    TargetPriceMult = 1.45,
    AutoRespondOffers = false,
    MinOfferMarkupPct = 0,
    AutoUnloadVehicle = false,
    AutoPawnSell = false,
    MinPawnRatePct = 85,
    AutoBuyUpgrades = false,
    SelectedUpgradeId = "InventorySpace",

    -- Safes & Value Multipliers
    AutoCrackInventorySafes = false,
    AutoCrackAuctionSafes = false,
    AutoLocksmithService = false,
    AutoInstantClean = false,
    AutoWashService = false,
    AutoRepairService = false,
    AutoGradingService = false,
    AutoAuthenticate = false,
    AutoMuseumCollectDonate = false,
    AutoTimeCapsuleCollect = false,
    AllowStandMicroBlink = false,

    -- World Loot, Minigames & Quests
    AutoCollectLostItems = false,
    AutoCollectFreightNuggets = false,
    AutoFishPerfect = false,
    AutoSelectBestBait = false,
    AutoMiningCrack = false,
    AutoWarehouseOrders = false,
    AutoClaimProgression = false,

    -- Vehicle, Teleport & Movement
    AntiAfk = false,
    AutoAcceptOverweight = false,
    VehicleSpeedBoost = false,
    VehicleSpeedMult = 1.5,
    CustomWalkSpeed = false,
    WalkSpeed = 32,
    CustomJumpPower = false,
    JumpPower = 75,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 80,
    SelectedAreaPOI = "Junk Yard",
    SelectedShopPOI = "Quick Sell Shop",
    SelectedPlayerPOI = "None",

    -- Visuals & X-Ray ESP
    GarageXRayESP = false,
    RareItemHighlightESP = false,
    LostItemESP = false,
    CustomerOfferESP = false,
    Fullbright = false,

    -- Config & Lifecycle
    AutoReExecuteOnTeleport = false,
}

local UI_Elements = {}

-- -------------------------------------------------------------------------
-- 4. LOAD WINDUI & INITIALIZE WINDOW
-- -------------------------------------------------------------------------
local WindUI = nil
do
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    }
    for _, url in ipairs(urls) do
        local ok, src = pcall(function() return game:HttpGet(url, true) end)
        if ok and type(src) == "string" and #src > 500 then
            local fn = loadstring(src)
            if fn then
                local okLib, lib = pcall(fn)
                if okLib and lib then
                    WindUI = lib
                    break
                end
            end
        end
    end
end

if not WindUI then
    warn("[XLunaHUB] Failed to load WindUI library.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Storage Hunters: Open World",
    Icon = "warehouse",
    Author = "By XLunaHUB",
    Folder = "XLunaSHOW",
    Size = UDim2.fromOffset(660, 520),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 1.5,
        Color = ColorSequence.new(Color3.fromRGB(255, 130, 20), Color3.fromRGB(255, 40, 110)),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    },
})

local function notify(title, msg, duration)
    ensureElevatedIdentity()
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = msg,
            Duration = duration or 3,
        })
    end)
end

local function safeSetDesc(para, text)
    if not para or not para.SetDesc then return end
    ensureElevatedIdentity()
    para.Desc = text
    para:SetDesc(text)
end

-- -------------------------------------------------------------------------
-- 5. SHARED HELPERS (APPRAISAL, GEOMETRY, PLOT, POIs, SERVICE STATIONS)
-- -------------------------------------------------------------------------
local function getRootAndHum()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function safeTeleportCF(cf)
    local _, hrp = getRootAndHum()
    if not hrp or typeof(cf) ~= "CFrame" then return false end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = cf
    return true
end

local function safeTeleportPos(pos)
    return safeTeleportCF(CFrame.new(pos))
end

local function getModelPivotPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, cf = pcall(function() return obj:GetPivot() end)
        if ok and typeof(cf) == "CFrame" then return cf.Position end
    end
    local bp = obj:FindFirstChildWhichIsA("BasePart", true)
    return bp and bp.Position or nil
end

local function formatMoney(n)
    local num = tonumber(n) or 0
    local sign = num < 0 and "-" or ""
    num = math.abs(num)
    local whole = math.floor(num)
    local cents = math.floor((num - whole) * 100 + 0.5)
    local s = tostring(whole):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    if cents > 0 then
        return string.format("%s$%s.%02d", sign, s, cents)
    end
    return string.format("%s$%s", sign, s)
end

local OrigHoldDurations = setmetatable({}, { __mode = "k" })
local PromptHoldInFlight = setmetatable({}, { __mode = "k" })

local function getPlayerCashNumber()
    local c = tonumber(LocalPlayer:GetAttribute("Cash"))
    if c then return c end
    local ccu = LocalPlayer:FindFirstChild("CCUStats")
    local cVal = ccu and ccu:FindFirstChild("Cash")
    return (cVal and tonumber(cVal.Value)) or 0
end

local function getPlayerDiamondsNumber()
    local d = tonumber(LocalPlayer:GetAttribute("Diamonds"))
    if d then return d end
    local ccu = LocalPlayer:FindFirstChild("CCUStats")
    local dVal = ccu and ccu:FindFirstChild("Diamonds")
    return (dVal and tonumber(dVal.Value)) or 0
end

local function getPlayerNetWorthNumber()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local nw = ls and ls:FindFirstChild("Net Worth")
    local raw = nw and tonumber(nw:GetAttribute("RawValue"))
    if raw then return raw end
    local s = nw and tostring(nw.Value or "0"):gsub("[^%d%.%-]", "") or "0"
    return tonumber(s) or 0
end

local function fireGuiButtonClick(btn)
    if not btn then return false end
    if type(getconnections) == "function" then
        local fired = false
        for _, sigName in ipairs({ "MouseButton1Click", "Activated" }) do
            local ok, list = pcall(getconnections, btn[sigName])
            if ok and type(list) == "table" and #list > 0 then
                for _, conn in ipairs(list) do
                    pcall(function() conn:Fire() end)
                    fired = true
                end
            end
        end
        if fired then return true end
    end
    if type(firesignal) == "function" then
        pcall(firesignal, btn.MouseButton1Click)
        return true
    end
    return false
end

local function handleConfirmPrompts(allowStartAuction)
    local handled = false
    for _, sg in ipairs(PlayerGui:GetChildren()) do
        if sg.Name == "ConfirmPromptHost" and sg.Enabled then
            local cp = sg:FindFirstChild("ConfirmPrompt")
            if cp and cp.Visible then
                local confirmBtn = cp:FindFirstChild("ConfirmButton", true)
                local cancelBtn = cp:FindFirstChild("CancelButton", true)
                if allowStartAuction and confirmBtn and tostring(confirmBtn.Text):find("Start Auction", 1, true) then
                    if fireGuiButtonClick(confirmBtn) then
                        handled = true
                    end
                elseif cancelBtn then
                    if fireGuiButtonClick(cancelBtn) then
                        handled = true
                    end
                end
            end
        end
    end
    return handled
end

local function getServerHoldDuration(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return 0 end
    local recorded = OrigHoldDurations[prompt]
    if recorded == nil then
        local h = tonumber(prompt.HoldDuration) or 0
        if prompt.Name == "EnterAuction" and h <= 0 then
            h = 1
        end
        OrigHoldDurations[prompt] = h
        recorded = h
    end
    if prompt.Name == "EnterAuction" then
        local rushExp = tonumber(LocalPlayer:GetAttribute("ActiveLuckDrinkExpireAt_11")) or 0
        if rushExp > Workspace:GetServerTimeNow() then
            return 0
        end
        return math.max(recorded, 1)
    end
    return recorded
end

local function activatePromptServerSafe(prompt, blockerContainer)
    if not prompt or not prompt.Parent or not prompt.Enabled then
        return false
    end
    local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstAncestorWhichIsA("BasePart")
    local serverHold = getServerHoldDuration(prompt)

    local savedQuery = {}
    if blockerContainer then
        for _, d in ipairs(blockerContainer:GetDescendants()) do
            if d:IsA("BasePart") then
                savedQuery[d] = d.CanQuery
                d.CanQuery = false
            end
        end
    end

    pcall(function()
        prompt.HoldDuration = serverHold
        prompt.RequiresLineOfSight = false
    end)

    local cam = Workspace.CurrentCamera
    if cam and promptPart then
        local _, onScreen = cam:WorldToViewportPoint(promptPart.Position)
        if not onScreen then
            cam.CFrame = CFrame.lookAt(promptPart.Position + Vector3.new(0, 4.5, 10), promptPart.Position)
        end
    end

    local ppGui = PlayerGui:FindFirstChild("ProximityPrompts")
    local waitShownStart = os.clock()
    while os.clock() - waitShownStart < 0.75 do
        local shown = false
        if ppGui and prompt.Parent then
            for _, ch in ipairs(ppGui:GetChildren()) do
                if ch.Name == "Prompt" and ch.Adornee == prompt.Parent then
                    shown = true
                    break
                end
            end
        end
        if shown then break end
        safeWait(0.05)
    end
    safeWait(0.10)

    if not prompt.Parent or not prompt.Enabled then
        for part, q in pairs(savedQuery) do
            if part and part.Parent then part.CanQuery = q end
        end
        return false
    end

    PromptHoldInFlight[prompt] = true
    pcall(function() prompt:InputHoldBegin() end)
    local holdWait = math.max(0.08, serverHold + 0.18)
    local h0 = os.clock()
    while os.clock() - h0 < holdWait do
        safeWait(0.06)
        if not prompt.Parent then break end
        if prompt.Name == "EnterAuction" and State.AutoPlayLoop then
            handleConfirmPrompts(true)
        end
    end
    pcall(function() prompt:InputHoldEnd() end)
    PromptHoldInFlight[prompt] = nil

    if serverHold <= 0.02 and prompt.Parent and prompt.Enabled and type(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
    end

    for part, q in pairs(savedQuery) do
        if part and part.Parent then
            part.CanQuery = q
        end
    end
    return true
end

--- Computes exact game-accurate cash value for either a workspace Model or inventory entry table.
local function computeItemValue(source)
    if not source then return 0, nil end
    local entry = source
    if typeof(source) == "Instance" and MutatorModule and type(MutatorModule.BuildEntryFromAttributes) == "function" then
        entry = MutatorModule:BuildEntryFromAttributes(source)
        ensureElevatedIdentity()
    end
    if type(entry) ~= "table" then return 0, nil end

    local itemId = tostring(entry.ItemId or "")
    local def = ItemsMod and (ItemsMod[itemId] or ItemsMod[entry.ItemId])
    local base = def and tonumber(def.BasePrice) or 0

    local price = base
    if MutatorModule and type(MutatorModule.CalculatePriceForEntry) == "function" then
        local ok, val = pcall(function() return MutatorModule:CalculatePriceForEntry(base, entry) end)
        if ok and type(val) == "number" then price = val end
    elseif ItemGridPanelMod and type(ItemGridPanelMod.ComputeEntryPrice) == "function" then
        local ok, val = pcall(function() return ItemGridPanelMod.ComputeEntryPrice(entry) end)
        if ok and type(val) == "number" then price = val end
    end

    if GradingUtil and type(GradingUtil.GradeCashMultForEntry) == "function" then
        local ok, mult = pcall(function() return GradingUtil.GradeCashMultForEntry(entry) end)
        if ok and type(mult) == "number" and mult ~= 1 then
            price = math.floor(price * mult * 100 + 0.5) / 100
        end
    end
    ensureElevatedIdentity()
    return price, entry, def
end

local function extractBestMutatorFromModel(model)
    local bestName, bestMult = nil, 0
    local mutAttr = model:GetAttribute("Mutators")
    if MutatorModule and type(MutatorModule.ParseMutatorsAttr) == "function" then
        local ok, list = pcall(function() return MutatorModule:ParseMutatorsAttr(mutAttr) end)
        if ok and type(list) == "table" then
            for _, m in ipairs(list) do
                local mName = type(m) == "table" and m.name or tostring(m)
                local def = MutatorModule.GetDefByName and MutatorModule:GetDefByName(mName)
                local mult = (def and tonumber(def.Multiplier)) or 1.1
                if mult >= bestMult then
                    bestMult = mult
                    bestName = mName
                end
            end
        end
    end
    for _, attrName in ipairs({ "GavelForcedMutator", "GavelAssistMutator" }) do
        local gMut = model:GetAttribute(attrName)
        if type(gMut) == "string" and gMut ~= "" and MutatorModule and MutatorModule.GetDefByName then
            local def = MutatorModule:GetDefByName(gMut)
            local mult = (def and tonumber(def.Multiplier)) or 1.1
            if mult >= bestMult then
                bestMult = mult
                bestName = gMut
            end
        end
    end
    ensureElevatedIdentity()
    return bestName, bestMult
end

--- Checks whether a world position falls inside or immediately inside a garage's Floorspace/AuctionZone.
local function isPointInsideGarage(garageModel, worldPos)
    local zone = garageModel:FindFirstChild("Floorspace") or garageModel:FindFirstChild("AuctionZone")
    if zone and zone:IsA("BasePart") then
        local localPt = zone.CFrame:PointToObjectSpace(worldPos)
        local halfX = (zone.Size.X * 0.5) + 6
        local halfZ = (zone.Size.Z * 0.5) + 6
        if math.abs(localPt.X) <= halfX and math.abs(localPt.Z) <= halfZ and math.abs(localPt.Y) <= 30 then
            return true
        end
    end
    local gPos = getModelPivotPos(garageModel)
    return gPos ~= nil and (gPos - worldPos).Magnitude <= 34
end

--- Free Locker X-Ray Appraiser: collects items in active garageModel OR workspace._Carryables belonging to that garage.
--- Avoids scanning static building descendants (O(Carryables) zero-lag design).
local function appraiseGarage(garageModel, carryablesEntries)
    if not garageModel then
        return { itemCount = 0, safeCount = 0, totalValue = 0, entryCost = 0, bestMutator = nil, bestMult = 0, items = {} }
    end

    local seen = {}
    local items = {}
    local totalValue = 0
    local safeCount = 0
    local bestMutator, bestMult = nil, 0

    local function considerModel(m)
        if seen[m] or not m:IsA("Model") then return end
        local itemId = m:GetAttribute("ItemId")
        if not itemId then return end
        seen[m] = true
        local val, _, def = computeItemValue(m)
        local isSafe = def and def.SafeId ~= nil
        if isSafe then safeCount += 1 end
        local mutName, mutMult = extractBestMutatorFromModel(m)
        if mutName and mutMult >= bestMult then
            bestMult = mutMult
            bestMutator = mutName
        end
        totalValue += val
        table.insert(items, { model = m, name = (def and def.Name) or m.Name, value = val, isSafe = isSafe, mutator = mutName })
    end

    local inAuction = garageModel:GetAttribute("InAuction") == true
    if inAuction then
        for _, d in ipairs(garageModel:GetChildren()) do
            if d:IsA("Model") and d:GetAttribute("ItemId") then
                considerModel(d)
            elseif d:IsA("Folder") and (d.Name == "Items" or d.Name == "Carryables") then
                for _, sub in ipairs(d:GetChildren()) do
                    if sub:IsA("Model") and sub:GetAttribute("ItemId") then
                        considerModel(sub)
                    end
                end
            end
        end
    end

    local pool = carryablesEntries
    if not pool then
        pool = {}
        local carFolder = Workspace:FindFirstChild("_Carryables")
        if carFolder then
            for _, c in ipairs(carFolder:GetChildren()) do
                if c:IsA("Model") and c:GetAttribute("ItemId") then
                    local p = getModelPivotPos(c)
                    if p then
                        table.insert(pool, { model = c, pos = p })
                    end
                end
            end
        end
    end

    for _, entry in ipairs(pool) do
        local c = entry.model or entry
        local p = entry.pos or getModelPivotPos(c)
        if c and c.Parent and p and isPointInsideGarage(garageModel, p) then
            considerModel(c)
        end
    end

    local entryCost = tonumber(garageModel:GetAttribute("EntryCost")) or 0
    local areaName = tostring(garageModel:GetAttribute("AreaName") or "Unknown")
    local garageId = tostring(garageModel:GetAttribute("GarageId") or garageModel.Name)
    ensureElevatedIdentity()

    return {
        garage = garageModel,
        name = garageId,
        area = areaName,
        inAuction = inAuction,
        entryCost = entryCost,
        itemCount = #items,
        safeCount = safeCount,
        totalValue = math.floor(totalValue * 100 + 0.5) / 100,
        bestMutator = bestMutator,
        bestMult = bestMult,
        items = items,
        pos = getModelPivotPos(garageModel),
    }
end

local function scanAllActiveGarages()
    local deb = findChildPath(Workspace, "_Debris", "Garages")
    if not deb then return {} end

    local carryablesEntries = {}
    local carFolder = Workspace:FindFirstChild("_Carryables")
    if carFolder then
        for _, c in ipairs(carFolder:GetChildren()) do
            if c:IsA("Model") and c:GetAttribute("ItemId") then
                local p = getModelPivotPos(c)
                if p then
                    table.insert(carryablesEntries, { model = c, pos = p })
                end
            end
        end
    end

    local hasCarryables = #carryablesEntries > 0
    local results = {}
    for _, g in ipairs(deb:GetChildren()) do
        if hasCarryables or g:GetAttribute("InAuction") == true then
            local report = appraiseGarage(g, carryablesEntries)
            if report.itemCount > 0 or report.inAuction then
                table.insert(results, report)
            end
        end
    end
    table.sort(results, function(a, b)
        local netA = a.totalValue - a.entryCost
        local netB = b.totalValue - b.entryCost
        if netA ~= netB then return netA > netB end
        return a.itemCount > b.itemCount
    end)
    ensureElevatedIdentity()
    return results
end

-- Plot & Unpack Zone Helpers
local function getMyPlot()
    local plots = Workspace:FindFirstChild("_Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return p
        end
    end
    return nil
end

local function getPlotUnpackCFrame(plot)
    if not plot then return nil end
    local ox = tonumber(plot:GetAttribute("OriginX"))
    local oy = tonumber(plot:GetAttribute("OriginY"))
    local oz = tonumber(plot:GetAttribute("OriginZ"))
    local ry = tonumber(plot:GetAttribute("RotationY")) or 0
    if not ox or not oy or not oz then return nil end
    return CFrame.new(ox, oy, oz) * CFrame.Angles(0, math.rad(ry), 0) * CFrame.new(0, 4, -100)
end

local function getPlotUnpackPosition(plot)
    local cf = getPlotUnpackCFrame(plot)
    return cf and cf.Position or nil
end

-- POIs Cache & Resolver
local POICache = {
    all = {},
    areas = {},
    shops = {},
    players = {},
    byName = {},
    lastFetch = 0,
}

local function refreshPOIs(force)
    if not force and os.clock() - POICache.lastFetch < 12 and #POICache.all > 0 then
        return POICache
    end
    local getPOIs = findChildPath(GPSEvents, "GetPOIs")
    if not getPOIs then return POICache end
    local ok, res = pcall(function() return getPOIs:InvokeServer() end)
    if not ok or type(res) ~= "table" or type(res.pois) ~= "table" then
        return POICache
    end
    POICache.lastFetch = os.clock()
    POICache.all = {}
    POICache.areas = {}
    POICache.shops = {}
    POICache.players = {}
    POICache.byName = {}

    for _, poi in ipairs(res.pois) do
        if type(poi) == "table" and typeof(poi.position) == "Vector3" then
            local rawName = tostring(poi.name or "POI"):match("^%s*(.-)%s*$")
            local entry = { name = rawName, rawName = tostring(poi.name), category = tostring(poi.category or ""), pos = poi.position }
            table.insert(POICache.all, entry)
            POICache.byName[rawName] = entry
            if entry.category == "Area" then
                table.insert(POICache.areas, rawName)
            elseif entry.category == "Shop" then
                table.insert(POICache.shops, rawName)
            elseif entry.category == "Player Shop" then
                table.insert(POICache.players, rawName)
            end
        end
    end
    if #POICache.players == 0 then
        table.insert(POICache.players, "None")
    end
    return POICache
end

local function findPOIPosition(targetName)
    refreshPOIs(false)
    local exact = POICache.byName[targetName]
    if exact then return exact.pos end
    local low = targetName:lower()
    for name, entry in pairs(POICache.byName) do
        if name:lower():find(low, 1, true) then
            return entry.pos
        end
    end
    return nil
end

--- Runs an optional Stand Micro-Blink wrapper when AllowStandMicroBlink is active.
local function runWithOptionalStandBlink(poiName, fn)
    local ok, a, b, c = pcall(fn)
    local errStr = type(a) == "table" and tostring(a.error or a.Error or a.Message or "") or tostring(a or b or "")
    local needWarp = ok and ((type(a) == "table" and (a.Status == "Far" or errStr:lower():find("closer") or errStr:lower():find("far") or errStr:lower():find("near")))
        or (not ok and errStr:lower():find("far")))
    if needWarp and State.AllowStandMicroBlink and poiName then
        local standPos = findPOIPosition(poiName)
        local _, hrp = getRootAndHum()
        if standPos and hrp then
            local savedCF = hrp.CFrame
            safeTeleportPos(standPos + Vector3.new(0, 4, 0))
            task.wait(0.18)
            ok, a, b, c = pcall(fn)
            task.wait(0.05)
            if hrp.Parent then
                safeTeleportCF(savedCF)
            end
        end
    end
    return ok, a, b, c
end

-- Live Runtime State Trackers
local AuctionRuntime = {
    inAuction = false,
    inZone = false,
    garageModel = nil,
    currentBid = 0,
    winnerName = "None",
    nextBid = 0,
    appraisal = nil,
    lastBidAt = 0,
    auctionStartedAt = 0,
    sniperStatus = "Idle",
    winsSession = 0,
    lastWinCount = tonumber(LocalPlayer:GetAttribute("AuctionsWon")) or 0,
}

local AutoPlayRuntime = {
    status = "Idle (OFF)",
    wins = 0,
    looted = 0,
    stocked = 0,
    sold = 0,
    skippedUntil = {},
}

local EconomyRuntime = {
    pawnRate = 0.75,
    pawnSecondsLeft = 0,
    offersAccepted = 0,
    offersDeclined = 0,
    lastOfferText = "None",
    inventoryCache = {},
    lastInvFetch = 0,
}

-- Vehicle Spawn & Cargo Helpers
local function getMySpawnedVehicle()
    local eqGuid = LocalPlayer:GetAttribute("EquippedVehicle")
    local fallback = nil
    for _, inst in ipairs(Workspace:GetChildren()) do
        if inst:IsA("Model") and inst:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            if inst:FindFirstChild("DriveSeat") or inst:GetAttribute("VehicleGUID") then
                if eqGuid and inst:GetAttribute("VehicleGUID") == eqGuid then
                    return inst
                end
                fallback = fallback or inst
            end
        end
    end
    return fallback
end

local function ensureEquippedVehicleSpawned()
    local existing = getMySpawnedVehicle()
    if existing then return existing end
    local eqGuid = LocalPlayer:GetAttribute("EquippedVehicle")
    local reqSpawn = findChildPath(VehicleEvents, "RequestSpawn")
    if not reqSpawn or type(eqGuid) ~= "string" or eqGuid == "" then
        return nil
    end
    pcall(function() reqSpawn:FireServer(eqGuid) end)
    local t0 = os.clock()
    while os.clock() - t0 < 1.25 do
        task.wait(0.15)
        local v = getMySpawnedVehicle()
        if v then return v end
    end
    return getMySpawnedVehicle()
end

local function getVehicleCargoCount()
    local eqGuid = LocalPlayer:GetAttribute("EquippedVehicle")
    local getCntRF = findChildPath(VehicleEvents, "GetVehicleItemCount")
    if not getCntRF or type(eqGuid) ~= "string" or eqGuid == "" then
        return 0
    end
    local ok, res = pcall(function() return getCntRF:InvokeServer(eqGuid) end)
    return (ok and tonumber(res)) or 0
end

-- Live Bidding HUD Reader & Zero-Miss classifyCursor Hook
local BidUI = {
    hookedTarget = nil,
    origClassify = nil,
    hookMode = nil,
    connFn = nil,
    upvIdx = nil,
    visualActive = false,
}

local function restoreBidBarPerfectHook()
    if BidUI.hookMode == "hookfunction" and BidUI.hookedTarget and BidUI.origClassify and type(hookfunction) == "function" then
        pcall(hookfunction, BidUI.hookedTarget, BidUI.origClassify)
    elseif BidUI.hookMode == "setupvalue" and BidUI.connFn and BidUI.upvIdx and BidUI.origClassify and debug and debug.setupvalue then
        pcall(debug.setupvalue, BidUI.connFn, BidUI.upvIdx, BidUI.origClassify)
    end
    BidUI.hookedTarget = nil
    BidUI.origClassify = nil
    BidUI.hookMode = nil
    BidUI.connFn = nil
    BidUI.upvIdx = nil
end

table.insert(Cleanups, restoreBidBarPerfectHook)

local function installBidBarPerfectHook()
    if BidUI.hookMode then
        return true
    end
    local abc = findChildPath(PlayerGui, "UIControllerGui", "AuctionBiddingContainer")
    local bidBtn = abc and abc:FindFirstChild("BidButton")
    if not bidBtn or type(getconnections) ~= "function" then
        return false
    end
    local okConns, conns = pcall(getconnections, bidBtn.MouseButton1Down)
    if not okConns or type(conns) ~= "table" then
        return false
    end
    for _, c in ipairs(conns) do
        local fn = c.Function
        if type(fn) == "function" and debug and debug.getupvalues then
            local ups = debug.getupvalues(fn)
            for idx, upv in pairs(ups) do
                if type(upv) == "function" and tostring(debug.info(upv, "n")) == "classifyCursor" then
                    if type(hookfunction) == "function" then
                        local origFn
                        origFn = hookfunction(upv, function(cursorPos, ...)
                            if State.AlwaysPerfectBidBar or State.AutoBidSniper or State.AutoPlayLoop then
                                return "perfect"
                            end
                            return origFn(cursorPos, ...)
                        end)
                        BidUI.hookedTarget = upv
                        BidUI.origClassify = origFn
                        BidUI.hookMode = "hookfunction"
                        return true
                    elseif debug.setupvalue then
                        local origFn = upv
                        local wrapper = function(cursorPos, ...)
                            if State.AlwaysPerfectBidBar or State.AutoBidSniper or State.AutoPlayLoop then
                                return "perfect"
                            end
                            return origFn(cursorPos, ...)
                        end
                        local okSet = pcall(debug.setupvalue, fn, idx, wrapper)
                        if okSet then
                            BidUI.origClassify = origFn
                            BidUI.connFn = fn
                            BidUI.upvIdx = idx
                            BidUI.hookMode = "setupvalue"
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function updateBidBarVisual(forceRestore)
    local abc = findChildPath(PlayerGui, "UIControllerGui", "AuctionBiddingContainer")
    local bidBarRow = abc and abc:FindFirstChild("BidBarRow")
    local track = bidBarRow and bidBarRow:FindFirstChild("Track")
    local bidZone = track and track:FindFirstChild("BidZone")
    if not bidZone or not bidZone:IsA("GuiObject") then return end

    local active = (not forceRestore) and (State.AlwaysPerfectBidBar or State.AutoBidSniper or State.AutoPlayLoop) and abc.Visible and bidBarRow.Visible
    if active then
        if bidZone.Size.X.Scale < 0.95 then
            bidZone.Size = UDim2.fromScale(0.98, 0.9)
            bidZone.Position = UDim2.fromScale(0.01, 0.5)
        end
        BidUI.visualActive = true
    elseif forceRestore or BidUI.visualActive then
        BidUI.visualActive = false
        if not active then
            bidZone.Size = UDim2.fromScale(0.23, 0.9)
        end
    end
end

local function getLiveBiddingHUDState()
    local abc = findChildPath(PlayerGui, "UIControllerGui", "AuctionBiddingContainer")
    local isOpen = abc ~= nil and abc.Visible == true
    local bidBarRow = abc and abc:FindFirstChild("BidBarRow")
    local canBidNow = isOpen and bidBarRow ~= nil and bidBarRow.Visible == true
    local bidText = abc and findChildPath(abc, "BidButton", "BidText")
    local bidTextStr = (bidText and bidText:IsA("TextLabel") and bidText.Text) or ""
    local isWinning = bidTextStr == "WINNING"

    local nextBidHUD, curBidHUD = nil, nil
    local priceLabel = bidBarRow and bidBarRow:FindFirstChild("BidPriceLabel")
    if priceLabel and priceLabel:IsA("TextLabel") and type(priceLabel.Text) == "string" then
        local stripped = priceLabel.Text:gsub("<[^>]+>", "")
        local nbStr = stripped:match("NEXT%s*%$([%d,%.]+)")
        local cbStr = stripped:match("CURRENT%s*%$([%d,%.]+)")
        if nbStr then nextBidHUD = tonumber((nbStr:gsub(",", ""))) end
        if cbStr then curBidHUD = tonumber((cbStr:gsub(",", ""))) end
    end

    local _, hrp = getRootAndHum()
    local myPos = hrp and hrp.Position
    local activeGarage = nil
    if AuctionRuntime.garageModel and AuctionRuntime.garageModel.Parent then
        local gPos = getModelPivotPos(AuctionRuntime.garageModel)
        if AuctionRuntime.garageModel:GetAttribute("InAuction") == true or (myPos and gPos and (myPos - gPos).Magnitude <= 85) then
            activeGarage = AuctionRuntime.garageModel
        end
    end
    if not activeGarage then
        local deb = findChildPath(Workspace, "_Debris", "Garages")
        if deb then
            local bestDist = 90
            for _, g in ipairs(deb:GetChildren()) do
                local gp = getModelPivotPos(g)
                if gp then
                    local d = myPos and (myPos - gp).Magnitude or math.huge
                    if g:GetAttribute("InAuction") == true and d < bestDist then
                        bestDist = d
                        activeGarage = g
                    end
                end
            end
            if not activeGarage and myPos then
                bestDist = 65
                for _, g in ipairs(deb:GetChildren()) do
                    local gp = getModelPivotPos(g)
                    if gp then
                        local d = (myPos - gp).Magnitude
                        if d < bestDist then
                            bestDist = d
                            activeGarage = g
                        end
                    end
                end
            end
        end
    end

    if activeGarage then
        AuctionRuntime.garageModel = activeGarage
    end

    return {
        isOpen = isOpen,
        canBidNow = canBidNow,
        isWinning = isWinning,
        bidText = bidTextStr,
        nextBid = nextBidHUD or AuctionRuntime.nextBid,
        curBid = curBidHUD or AuctionRuntime.currentBid,
        garage = activeGarage,
    }
end

local function refreshInventory(force)
    local getInv = findChildPath(InventoryEvents, "GetPlayerInventory")
    if not getInv then return EconomyRuntime.inventoryCache end
    if not force and os.clock() - EconomyRuntime.lastInvFetch < 2.5 then
        return EconomyRuntime.inventoryCache
    end
    EconomyRuntime.lastInvFetch = os.clock()
    local ok, res = pcall(function() return getInv:InvokeServer() end)
    if ok and type(res) == "table" then
        EconomyRuntime.inventoryCache = res
    end
    return EconomyRuntime.inventoryCache
end

-- Picklock & Wrench Tool Helpers
local function getBestOwnedPicklockTier()
    if not PicklockMod then return -1 end
    local bestTier = -1
    local containers = { LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack") }
    for _, cont in ipairs(containers) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local okId, toolId = pcall(PicklockMod.GetToolIdFromTool, t)
                    if okId and toolId and PicklockMod.IsAllowedToolId(toolId) then
                        local def = PicklockMod.GetToolDef and PicklockMod.GetToolDef(toolId)
                        local tier = (def and tonumber(def.tier or def.Tier)) or 0
                        if tier > bestTier then bestTier = tier end
                    end
                end
            end
        end
    end
    if LocalPlayer:GetAttribute("HasOwnedLockpick") and bestTier < 0 then
        bestTier = 0
    end
    ensureElevatedIdentity()
    return bestTier
end

local function getBestWrenchStats()
    if not WrenchMod then return nil, 0 end
    local containers = { LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack") }
    local bestId, bestMax = nil, 0
    for _, cont in ipairs(containers) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local okId, toolId = pcall(WrenchMod.GetToolIdFromTool, t)
                    if okId and toolId and WrenchMod.IsAllowedToolId(toolId) then
                        local def = WrenchMod.GetToolDef and WrenchMod.GetToolDef(toolId)
                        local cap = (def and tonumber(def.maxRepairValue)) or 150
                        if cap >= bestMax then
                            bestMax = cap
                            bestId = toolId
                        end
                    end
                end
            end
        end
    end
    ensureElevatedIdentity()
    return bestId, bestMax
end

local IsLootingWonNow = false
local function lootAllWonItemsNow(restoreOrigin)
    if IsLootingWonNow then return 0 end
    IsLootingWonNow = true
    local totalLooted = 0
    local ok, err = pcall(function()
        local carFolder = Workspace:FindFirstChild("_Carryables")
        local _, hrp, hum = getRootAndHum()
        if not carFolder or not hrp or not hum then
            return
        end

        local hasAny = false
        for _, m in ipairs(carFolder:GetChildren()) do
            if m:IsA("Model") and m:GetAttribute("Owner") == LocalPlayer.UserId then
                hasAny = true
                break
            end
        end
        if not hasAny then return end

        local savedCF = hrp.CFrame
        if hum.SeatPart then
            hum.Sit = false
            safeWait(0.12)
        end
        pcall(function() hum:UnequipTools() end)

        ensureEquippedVehicleSpawned()

        local repairWonRF = findChildPath(WrenchEvents, "RepairWonItem")
        local wrenchId, wrenchMax = getBestWrenchStats()
        local startSess = LocksmithEvents and LocksmithEvents:FindFirstChild("StartPicklockSession")
        local crackWorld = LocksmithEvents and LocksmithEvents:FindFirstChild("PicklockSafe")
        local ownedTier = getBestOwnedPicklockTier()

        for _ = 1, 4 do
            local passCount = 0
            local models = {}
            for _, m in ipairs(carFolder:GetChildren()) do
                if m:IsA("Model") and m:GetAttribute("Owner") == LocalPlayer.UserId then
                    table.insert(models, m)
                end
            end
            if #models == 0 then break end

            for _, model in ipairs(models) do
                if model.Parent and model:GetAttribute("Owner") == LocalPlayer.UserId then
                    if State.AutoWrenchRepairWon and repairWonRF and wrenchId then
                        local cond = tonumber(model:GetAttribute("Condition")) or 100
                        local wonGuid = model:GetAttribute("ItemsWonGUID")
                        if cond < 50 and type(wonGuid) == "string" and wonGuid ~= "" then
                            local val = computeItemValue(model)
                            if val <= wrenchMax then
                                pcall(function() repairWonRF:InvokeServer(wonGuid, wrenchId) end)
                            end
                        end
                    end

                    if State.AutoCrackAuctionSafes and startSess and crackWorld and ownedTier >= 0 and ItemsMod and SafesMod then
                        local def = ItemsMod[tostring(model:GetAttribute("ItemId") or "")]
                        local safeDef = def and def.SafeId and SafesMod[tostring(def.SafeId)]
                        local reqTier = (safeDef and tonumber(safeDef.MinPickTier)) or 0
                        local wonGuid = model:GetAttribute("ItemsWonGUID")
                        if safeDef and ownedTier >= reqTier and type(wonGuid) == "string" and wonGuid ~= "" then
                            local okS, res = pcall(function() return startSess:InvokeServer("Auction", wonGuid) end)
                            if okS and type(res) == "table" and res.success and res.sessionId then
                                safeWait(1.88)
                                pcall(function() crackWorld:InvokeServer(wonGuid, res.sessionId) end)
                            end
                        end
                    end

                    local openPrompt = model:FindFirstChild("OpenBoxPrompt", true)
                    local pickPrompt = model:FindFirstChild("PickupPrompt", true)
                    local prompt = (openPrompt and openPrompt:IsA("ProximityPrompt") and openPrompt.Enabled and openPrompt)
                        or (pickPrompt and pickPrompt:IsA("ProximityPrompt") and pickPrompt.Enabled and pickPrompt)
                    if not prompt then
                        for _, d in ipairs(model:GetDescendants()) do
                            if d:IsA("ProximityPrompt") and d.Enabled then
                                prompt = d
                                break
                            end
                        end
                    end

                    if prompt and model.Parent then
                        local targetPos = (prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Parent.Position) or getModelPivotPos(model)
                        if targetPos then
                            if (targetPos - hrp.Position).Magnitude > 6.5 then
                                safeTeleportPos(targetPos + Vector3.new(0, 1.5, 0))
                                safeWait(0.16)
                            end
                            if activatePromptServerSafe(prompt, nil) then
                                passCount += 1
                                totalLooted += 1
                            end
                            safeWait(0.22)
                        end
                    end
                end
            end

            if passCount == 0 then break end
            safeWait(0.26)
        end

        if restoreOrigin and totalLooted > 0 and hrp.Parent then
            safeTeleportCF(savedCF)
        end
    end)
    IsLootingWonNow = false
    if not ok and err then
        warn("[XLunaHUB] Loot error: " .. tostring(err))
    end
    return totalLooted
end

-- Lighting Fullbright Helper
local function applyFullbright(enabled)
    if enabled then
        if not FullbrightActive then
            OriginalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
            FullbrightActive = true
        end
        Lighting.Brightness = 2.4
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(220, 220, 220)
        Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    elseif FullbrightActive then
        FullbrightActive = false
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

-- Dynamic Movement Baseline Trackers & Restoration Helpers
local MovementOrig = {
    hum = nil,
    walkSpeed = nil,
    jumpPower = nil,
    jumpHeight = nil,
    useJumpPower = nil,
}
local NoClipModifiedParts = {}
local WasFlying = false

local function restoreWalkSpeed()
    local _, _, hum = getRootAndHum()
    if hum and MovementOrig.hum == hum and MovementOrig.walkSpeed ~= nil then
        pcall(function() hum.WalkSpeed = MovementOrig.walkSpeed end)
    end
    MovementOrig.walkSpeed = nil
end

local function restoreJumpPower()
    local _, _, hum = getRootAndHum()
    if hum and MovementOrig.hum == hum and MovementOrig.jumpPower ~= nil then
        pcall(function()
            if MovementOrig.useJumpPower ~= nil then
                hum.UseJumpPower = MovementOrig.useJumpPower
            end
            hum.JumpPower = MovementOrig.jumpPower
            if MovementOrig.jumpHeight ~= nil then
                hum.JumpHeight = MovementOrig.jumpHeight
            end
        end)
    end
    MovementOrig.jumpPower = nil
    MovementOrig.jumpHeight = nil
    MovementOrig.useJumpPower = nil
end

local function restoreNoClip()
    for part in pairs(NoClipModifiedParts) do
        if part and part.Parent and part:IsA("BasePart") then
            pcall(function() part.CanCollide = true end)
        end
    end
    NoClipModifiedParts = {}
end

local function restoreFly()
    if WasFlying then
        WasFlying = false
        local _, hrp = getRootAndHum()
        if hrp then
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
        end
    end
end

-- Config Save / Load / Reset Helpers
local function saveConfig()
    ensureElevatedIdentity()
    local ok, err = pcall(function()
        if isfolder and makefolder and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
        writefile(CONFIG_PATH, HttpService:JSONEncode(State))
    end)
    if ok then
        notify("Config", "Saved configuration to " .. CONFIG_PATH, 2.5)
    else
        notify("Config Error", tostring(err), 3.5)
    end
end

local function applyLoadedValue(key, val)
    if State[key] == nil or type(State[key]) ~= type(val) then return end
    State[key] = val
    local elem = UI_Elements[key]
    if not elem then return end
    ensureElevatedIdentity()
    pcall(function()
        if (type(val) == "boolean" or type(val) == "number") and elem.Set then
            elem:Set(val)
        elseif type(val) == "string" then
            if elem.Select then
                elem:Select(val)
            elseif elem.Set then
                elem:Set(val)
            end
        end
    end)
end

local function loadConfig()
    ensureElevatedIdentity()
    local ok, msg = pcall(function()
        if not isfile or not isfile(CONFIG_PATH) then
            error("No saved config found at " .. CONFIG_PATH)
        end
        local data = HttpService:JSONDecode(readfile(CONFIG_PATH))
        if type(data) ~= "table" then
            error("Invalid configuration format")
        end
        for k, v in pairs(data) do
            applyLoadedValue(k, v)
        end
    end)
    if ok then
        notify("Config", "Configuration loaded and synchronized!", 2.5)
    else
        notify("Config", tostring(msg), 3)
    end
end

local function resetAllToOff()
    ensureElevatedIdentity()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
            local elem = UI_Elements[k]
            if elem and elem.Set then
                pcall(function() elem:Set(false) end)
            end
        end
    end
    applyFullbright(false)
    pcall(updateBidBarVisual, true)
    restoreWalkSpeed()
    restoreJumpPower()
    restoreNoClip()
    restoreFly()
    notify("Config", "All features reset to OFF.", 2.5)
end

-- -------------------------------------------------------------------------
-- 6. BUILD 8 WINDUI TABS & ELEMENTS (100% ENGLISH, ALL DEFAULTS OFF)
-- -------------------------------------------------------------------------
local TabTelemetry = Window:Tab({ Title = "Telemetry", Icon = "activity" })
local TabAuction = Window:Tab({ Title = "Auctions", Icon = "gavel" })
local TabShop = Window:Tab({ Title = "Shop & Pawn", Icon = "store" })
local TabServices = Window:Tab({ Title = "Safes & Value", Icon = "gem" })
local TabWorld = Window:Tab({ Title = "World & Farm", Icon = "compass" })
local TabMovement = Window:Tab({ Title = "Teleport & Move", Icon = "navigation" })
local TabVisuals = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "settings" })

-- =========================================================================
-- TAB 1: TELEMETRY & APPRAISER
-- =========================================================================
TabTelemetry:Section({ Title = "Live Game Telemetry" })
local AuctionDashboard = TabTelemetry:Paragraph({
    Title = "Active Auction & True Profit X-Ray",
    Desc = "Scanning workspace garages...",
})

local ShopDashboard = TabTelemetry:Paragraph({
    Title = "Shop Empire & Pawn Rate Monitor",
    Desc = "Reading plot stock and PawnShop rate...",
})

local AccountDashboard = TabTelemetry:Paragraph({
    Title = "Inventory, Vehicle & Safe Tracker",
    Desc = "Reading Cash, Diamonds, and cargo...",
})

local WorldDashboard = TabTelemetry:Paragraph({
    Title = "World Scavenger & Progression Status",
    Desc = "Checking _LostItems, Freight, and Collections...",
})

TabTelemetry:Section({ Title = "Live Active Garage Ranker" })
local TopGaragesPara = TabTelemetry:Paragraph({
    Title = "Top Profitable Active Garages",
    Desc = "Click 'Scan Active Garages' below to rank all live auctions across the map.",
})

local function formatRankedGaragesDesc(ranked)
    if not ranked or #ranked == 0 then
        return "No garages currently have spawned items (walk up to any garage to start an auction)."
    end
    local lines = {}
    for i = 1, math.min(5, #ranked) do
        local r = ranked[i]
        local mutTxt = r.bestMutator and (" | Mut: " .. r.bestMutator) or ""
        local safeTxt = r.safeCount > 0 and (" | Safes: " .. r.safeCount) or ""
        table.insert(lines, string.format(
            "%d. [%s] %s â Worth: %s (Entry: %s, Items: %d%s%s)",
            i, r.area, r.name, formatMoney(r.totalValue), formatMoney(r.entryCost), r.itemCount, safeTxt, mutTxt
        ))
    end
    return table.concat(lines, "\n")
end

local function updateGarageRankingCard(precomputedRanked)
    ensureElevatedIdentity()
    local ranked = precomputedRanked or scanAllActiveGarages()
    safeSetDesc(TopGaragesPara, formatRankedGaragesDesc(ranked))
    return ranked
end

TabTelemetry:Button({
    Title = "Scan & Rank Active Garages",
    Desc = "Appraises all 76+ garages across all 11 areas using live item & mutator formulas",
    Callback = function()
        local ranked = updateGarageRankingCard()
        notify("Garage X-Ray", string.format("Scanned %d active garage(s) with items.", #ranked), 2.5)
    end,
})

-- =========================================================================
-- TAB 2: AUCTIONS, AUTO-PLAY & SNIPER
-- =========================================================================
TabAuction:Section({ Title = "Autonomous Full Gameplay Loop (Zero Manual Walking)" })
local AutoPlayStatusPara = TabAuction:Paragraph({
    Title = "Auto-Play Tycoon Status",
    Desc = "Idle (OFF) â Enable below to automate Auctions -> Loot -> Unload -> Stock/Sell.",
})

UI_Elements.AutoPlayLoop = TabAuction:Toggle({
    Title = "Full Auto-Play Gameplay Loop",
    Desc = "Automatically warps to garages, starts auctions, bids/wins, loots items & boxes, unloads vehicle, and stocks/sells",
    Value = false,
    Callback = function(v)
        State.AutoPlayLoop = v
        if v then
            installBidBarPerfectHook()
            AutoPlayRuntime.status = "Starting Autonomous Loop..."
        else
            AutoPlayRuntime.status = "Idle (OFF)"
        end
        updateBidBarVisual(not v)
    end,
})

UI_Elements.AutoPlayAreaFilter = TabAuction:Dropdown({
    Title = "Auto-Play Target Area",
    Values = { "Best Unlocked (Auto)", "Junk Yard", "Back Alley", "Farmyard", "Shipyard", "Power Plant", "The Mines", "Lucky Beach", "Business Bay", "Military Base" },
    Value = State.AutoPlayAreaFilter,
    Callback = function(v) State.AutoPlayAreaFilter = tostring(v) end,
})

UI_Elements.AutoPlaySellMode = TabAuction:Dropdown({
    Title = "Auto-Play Profit Pipeline",
    Values = { "Stock Shelves + Pawn Overflow", "Pawn Quick-Sell All Immediately", "Stock Shelves Only" },
    Value = State.AutoPlaySellMode,
    Callback = function(v) State.AutoPlaySellMode = tostring(v) end,
})

TabAuction:Section({ Title = "Skill-Bar Bypass & Sniper Bidding" })
UI_Elements.AutoBidSniper = TabAuction:Toggle({
    Title = "Auto-Bid Profit Sniper",
    Desc = "Reads live AuctionBidding HUD & _Carryables X-Ray to auto-bid cleanly without using the moving cursor bar",
    Value = false,
    Callback = function(v)
        State.AutoBidSniper = v
        if v then
            installBidBarPerfectHook()
        end
        updateBidBarVisual(not v)
    end,
})

UI_Elements.AutoBidMode = TabAuction:Dropdown({
    Title = "Auto-Bid Strategy",
    Values = { "Smart Profit Cap", "Always Win (Uncapped)" },
    Value = State.AutoBidMode,
    Callback = function(v) State.AutoBidMode = tostring(v) end,
})

UI_Elements.MaxBidValuePct = TabAuction:Slider({
    Title = "Max Bid % Of True Garage Value",
    Desc = "Stops bidding once NextBid exceeds this percentage of exact X-Ray value (Smart Profit Cap mode)",
    Value = { Min = 25, Max = 200, Default = 110 },
    Step = 5,
    Callback = function(v) State.MaxBidValuePct = tonumber(v) or State.MaxBidValuePct end,
})

UI_Elements.MinNetProfit = TabAuction:Slider({
    Title = "Minimum Expected Net Profit ($)",
    Desc = "Won't place a bid unless (TrueValue - NextBid - EntryCost) >= this amount (Smart Profit Cap mode)",
    Value = { Min = 0, Max = 5000, Default = 0 },
    Step = 20,
    Callback = function(v) State.MinNetProfit = tonumber(v) or State.MinNetProfit end,
})

UI_Elements.BidReactionDelay = TabAuction:Slider({
    Title = "Human Reaction Delay (Seconds)",
    Desc = "Brief natural delay before sending sniper bid when outbid",
    Value = { Min = 0.05, Max = 1.5, Default = 0.18 },
    Step = 0.05,
    Callback = function(v) State.BidReactionDelay = tonumber(v) or State.BidReactionDelay end,
})

UI_Elements.RequireSafeOrMut = TabAuction:Toggle({
    Title = "Only Snipe Garages With Safe Or Mutator",
    Desc = "Skips bidding unless appraised locker contains at least 1 Safe or Mutated item",
    Value = false,
    Callback = function(v) State.RequireSafeOrMut = v end,
})

UI_Elements.AlwaysPerfectBidBar = TabAuction:Toggle({
    Title = "Zero-Miss Manual Bid Bar Assist",
    Desc = "Hooks AuctionBidding classifyCursor so every manual Bid click/key always lands PERFECT (0s miss penalty)",
    Value = false,
    Callback = function(v)
        State.AlwaysPerfectBidBar = v
        if v then
            installBidBarPerfectHook()
        end
        updateBidBarVisual(not v)
    end,
})

TabAuction:Button({
    Title = "Bid Once Now (Bypass Skill Bar)",
    Desc = "Fires Events.Auction.Bid immediately if inside an active auction",
    Callback = function()
        local bidEv = findChildPath(AuctionEvents, "Bid")
        if bidEv then
            pcall(function() bidEv:FireServer() end)
            notify("Auction", "Direct bid packet sent!", 2)
        end
    end,
})

TabAuction:Section({ Title = "Post-Win Loot & Quality Of Life" })
UI_Elements.AutoSkipCinematics = TabAuction:Toggle({
    Title = "Auto Skip Auction Cinematics",
    Desc = "Automatically finishes PlayCinematicSequence to regain movement immediately",
    Value = false,
    Callback = function(v) State.AutoSkipCinematics = v end,
})

UI_Elements.AutoLootWonItems = TabAuction:Toggle({
    Title = "Auto Loot Won Locker Items & Boxes",
    Desc = "Automatically warps near won _Carryables items, unboxes crates, and fires PickupPrompt",
    Value = false,
    Callback = function(v) State.AutoLootWonItems = v end,
})

TabAuction:Button({
    Title = "Loot All Won Items Now",
    Desc = "Unboxes & collects all currently owned _Carryables items in the world",
    Callback = function()
        local n = lootAllWonItemsNow(true)
        notify("Auto Loot", n > 0 and ("Triggered pickup/unbox " .. n .. " time(s)!") or "No won _Carryables items owned right now.", 2.5)
    end,
})

UI_Elements.InstantPrompts = TabAuction:Toggle({
    Title = "Instant ProximityPrompts (0s Hold)",
    Desc = "Completes any held ProximityPrompt immediately without waiting",
    Value = false,
    Callback = function(v) State.InstantPrompts = v end,
})

UI_Elements.AutoWrenchRepairWon = TabAuction:Toggle({
    Title = "Auto Wrench-Repair Won Items (<50% Cond)",
    Desc = "Repairs damaged won items directly via WrenchShop.RepairWonItem using your best owned Wrench",
    Value = false,
    Callback = function(v) State.AutoWrenchRepairWon = v end,
})

TabAuction:Section({ Title = "Smart Garage Warps" })
TabAuction:Button({
    Title = "Warp To Highest True-Value Garage",
    Desc = "Teleports directly to the highest-value active garage found by X-Ray",
    Callback = function()
        local ranked = updateGarageRankingCard()
        if ranked[1] and ranked[1].pos then
            safeTeleportPos(ranked[1].pos + Vector3.new(0, 5, 0))
            notify("Warp", string.format("Warped to %s [%s] (%s)!", ranked[1].name, ranked[1].area, formatMoney(ranked[1].totalValue)), 3)
        else
            notify("Warp", "No active populated garages found right now.", 2.5)
        end
    end,
})

TabAuction:Button({
    Title = "Warp To Nearest Idle Garage (Free Entry)",
    Desc = "Teleports to the closest $0 EntryCost garage ready to start an auction",
    Callback = function()
        local deb = findChildPath(Workspace, "_Debris", "Garages")
        local _, hrp = getRootAndHum()
        if not deb then return end
        local ref = hrp and hrp.Position or Vector3.zero
        local bestPos, bestDist, bestName = nil, math.huge, ""
        for _, g in ipairs(deb:GetChildren()) do
            if not g:GetAttribute("InAuction") and (tonumber(g:GetAttribute("EntryCost")) or 0) == 0 then
                local p = getModelPivotPos(g)
                if p then
                    local d = (p - ref).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPos = p
                        bestName = g.Name
                    end
                end
            end
        end
        if bestPos then
            safeTeleportPos(bestPos + Vector3.new(0, 5, 0))
            notify("Warp", "Warped to idle " .. bestName, 2.5)
        else
            notify("Warp", "No free idle garages found.", 2.5)
        end
    end,
})

-- =========================================================================
-- TAB 3: SHOP, STOCK & PAWN
-- =========================================================================
TabShop:Section({ Title = "Autonomous Shop Stocking & Pricing" })
local function runRemoteAutoStock()
    local autoStockRF = findChildPath(PlotEvents, "ShelfAutoStock")
    if not autoStockRF then return 0, "Missing ShelfAutoStock remote" end
    local okPrev, prev = pcall(function() return autoStockRF:InvokeServer("preview") end)
    if not okPrev or type(prev) ~= "table" or prev.Ok ~= true then
        return 0, type(prev) == "table" and tostring(prev.Error or "Preview failed") or "Preview failed"
    end
    local cap = math.max(0, math.min(tonumber(prev.FreeSlots) or 0, tonumber(prev.SpaceLeft) or 0))
    if cap <= 0 or type(prev.Fits) ~= "table" then
        return 0, "No free slots or space left"
    end
    local inv = refreshInventory(true)
    local candidates = {}
    for guid, entry in pairs(inv) do
        local g = type(entry) == "table" and (entry.Guid or entry.GUID or guid) or guid
        if type(entry) == "table" and entry.Favorited ~= true and prev.Fits[g] == true then
            local val = computeItemValue(entry)
            table.insert(candidates, { guid = g, value = val })
        end
    end
    table.sort(candidates, function(a, b) return a.value > b.value end)
    local guids = {}
    for i = 1, math.min(cap, #candidates) do
        table.insert(guids, candidates[i].guid)
    end
    if #guids == 0 then return 0, "No fitting unfavorited items" end
    local okApply, res = pcall(function() return autoStockRF:InvokeServer("apply", guids) end)
    if okApply and type(res) == "table" and res.Ok == true then
        return tonumber(res.Placed) or #guids, "Stocked"
    end
    return 0, type(res) == "table" and tostring(res.Error or "Apply failed") or "Apply failed"
end

local function optimizePlotShelfPrices()
    local plot = getMyPlot()
    local changeRE = findChildPath(PlotEvents, "ChangeStockPrice")
    if not plot or not changeRE then return 0 end
    local stockFolder = plot:FindFirstChild("Stock")
    if not stockFolder then return 0 end
    local updated = 0
    local mult = math.clamp(tonumber(State.TargetPriceMult) or 1.45, 0.5, 1.5)
    for _, item in ipairs(stockFolder:GetChildren()) do
        local guid = item:GetAttribute("GUID")
        local curPrice = tonumber(item:GetAttribute("StockPrice")) or 0
        if type(guid) == "string" and guid ~= "" then
            local trueVal = computeItemValue(item)
            if trueVal > 0 then
                local minP = math.max(0.01, math.floor(trueVal * 0.5 * 100 + 0.5) / 100)
                local maxP = math.floor(trueVal * 1.5 * 100 + 0.5) / 100
                local target = math.clamp(math.floor(trueVal * mult * 100 + 0.5) / 100, minP, maxP)
                if math.abs(curPrice - target) > 0.02 then
                    pcall(function() changeRE:FireServer(guid, target) end)
                    updated += 1
                end
            end
        end
    end
    return updated
end

UI_Elements.AutoStockShelves = TabShop:Toggle({
    Title = "Remote Auto-Stock Shelves",
    Desc = "Automatically stocks highest-value unfavorited inventory onto empty shop shelves anywhere",
    Value = false,
    Callback = function(v) State.AutoStockShelves = v end,
})

TabShop:Button({
    Title = "Auto-Stock Shelves Now",
    Desc = "Runs ShelfAutoStock preview -> apply immediately",
    Callback = function()
        local count, msg = runRemoteAutoStock()
        notify("Shop Stock", count > 0 and ("Stocked " .. count .. " item(s)!") or tostring(msg), 3)
    end,
})

UI_Elements.AutoOptimizePrices = TabShop:Toggle({
    Title = "Auto Optimize Shelf Prices",
    Desc = "Continuously updates all Stock items to your Target Price Multiplier (0.50x - 1.50x)",
    Value = false,
    Callback = function(v) State.AutoOptimizePrices = v end,
})

UI_Elements.TargetPriceMult = TabShop:Slider({
    Title = "Target Stock Price Multiplier",
    Desc = "Game allows up to 1.50x true item value on shop shelves",
    Value = { Min = 0.50, Max = 1.50, Default = 1.45 },
    Step = 0.05,
    Callback = function(v) State.TargetPriceMult = tonumber(v) or State.TargetPriceMult end,
})

TabShop:Button({
    Title = "Apply Optimal Shelf Prices Now",
    Desc = "Immediately re-prices all stocked items on your plot",
    Callback = function()
        local n = optimizePlotShelfPrices()
        notify("Pricing", "Updated price on " .. n .. " stocked item(s).", 2.5)
    end,
})

TabShop:Section({ Title = "Cross-Map Customer Offers & Vehicle Unload" })
UI_Elements.AutoRespondOffers = TabShop:Toggle({
    Title = "Cross-Map Auto-Respond Customer Offers",
    Desc = "Bypasses 55-stud NPC UI gate and auto-accepts/declines offers anywhere on the map",
    Value = false,
    Callback = function(v) State.AutoRespondOffers = v end,
})

UI_Elements.MinOfferMarkupPct = TabShop:Slider({
    Title = "Min Acceptable Offer Markup (%)",
    Desc = "Accepts if offer >= Base * (1 + Markup%/100), otherwise declines",
    Value = { Min = -25, Max = 50, Default = 0 },
    Step = 5,
    Callback = function(v) State.MinOfferMarkupPct = tonumber(v) or State.MinOfferMarkupPct end,
})

local function unloadVehicleItems(allowWarp, restorePos)
    local getVehItems = findChildPath(VehicleEvents, "GetVehicleItems")
    local transferRE = findChildPath(VehicleEvents, "TransferVehicleItemsToInventory")
    if not getVehItems or not transferRE then return 0, "Missing Vehicle remotes" end

    local eqGuid = LocalPlayer:GetAttribute("EquippedVehicle")
    if type(eqGuid) ~= "string" or eqGuid == "" then
        return 0, "No vehicle equipped"
    end

    local okV, items = pcall(function() return getVehItems:InvokeServer(eqGuid) end)
    if not okV or type(items) ~= "table" then return 0, "Failed to read vehicle cargo" end

    local invCap = tonumber(LocalPlayer:GetAttribute("InventoryCap")) or 10
    local invCnt = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0
    local freeSlots = math.max(0, invCap - invCnt)
    if freeSlots <= 0 then return 0, "Player inventory full" end

    local list = {}
    for guid, entry in pairs(items) do
        local g = type(entry) == "table" and (entry.Guid or entry.GUID or guid) or guid
        table.insert(list, { guid = g, value = computeItemValue(entry) })
    end
    if #list == 0 then return 0, "Vehicle cargo empty" end
    table.sort(list, function(a, b) return a.value > b.value end)

    local pick = {}
    for i = 1, math.min(freeSlots, #list) do
        table.insert(pick, list[i].guid)
    end

    local _, hrp, hum = getRootAndHum()
    local plot = getMyPlot()
    local unpackCF = getPlotUnpackCFrame(plot)
    local unpackPos = unpackCF and unpackCF.Position or nil
    local savedCF = hrp and hrp.CFrame
    local warped = false
    local satTemporarily = false

    if allowWarp and hrp and hum and unpackCF and unpackPos then
        if (hrp.Position - unpackPos).Magnitude > 13 then
            safeTeleportCF(unpackCF)
            warped = true
            safeWait(0.18)
        end
        local veh = ensureEquippedVehicleSpawned()
        if veh then
            local seat = veh:FindFirstChild("DriveSeat")
            if hum.SeatPart ~= seat then
                pcall(function() veh:PivotTo(unpackCF) end)
                if seat and seat:IsA("VehicleSeat") then
                    pcall(function() seat:Sit(hum) end)
                    satTemporarily = true
                    safeWait(0.30)
                end
            elseif (veh:GetPivot().Position - unpackPos).Magnitude > 13 then
                pcall(function() veh:PivotTo(unpackCF) end)
                safeWait(0.20)
            end
        end
    end

    pcall(function() transferRE:FireServer(pick) end)
    safeWait(0.30)

    if satTemporarily and hum and hum.SeatPart then
        pcall(function() hum.Sit = false end)
        safeWait(0.12)
    end

    if (restorePos ~= false) and warped and savedCF and hrp and hrp.Parent then
        safeTeleportCF(savedCF)
    end
    return #pick, "Unloaded"
end

UI_Elements.AutoUnloadVehicle = TabShop:Toggle({
    Title = "Auto Unload Vehicle When Near Unpack Zone",
    Desc = "Transfers top-value cargo from vehicle to inventory whenever in your plot unpack zone",
    Value = false,
    Callback = function(v) State.AutoUnloadVehicle = v end,
})

TabShop:Button({
    Title = "Smart Warp & Unload Vehicle Now",
    Desc = "Micro-warps to your plot UnpackZone, transfers best cargo, and restores position",
    Callback = function()
        local n, msg = unloadVehicleItems(true, true)
        notify("Vehicle Unload", n > 0 and ("Transferred " .. n .. " item(s) to inventory!") or tostring(msg), 3)
    end,
})

TabShop:Section({ Title = "Peak-Rate Pawn Shop & Upgrades" })
local function sellToPawnShopNow()
    local getSell = findChildPath(PawnEvents, "GetSellableItems")
    local sellItems = findChildPath(PawnEvents, "SellItems")
    if not getSell or not sellItems then return 0, "Missing Pawn remotes" end
    local ok, items = pcall(function() return getSell:InvokeServer() end)
    if not ok or type(items) ~= "table" then return 0, "Could not fetch sellable items" end
    local guids = {}
    for guid, entry in pairs(items) do
        local g = type(entry) == "table" and (entry.Guid or entry.GUID or guid) or guid
        if type(entry) == "table" and entry.Favorited ~= true then
            table.insert(guids, g)
        end
    end
    if #guids == 0 then return 0, "No unfavorited sellable items" end
    local okS, res = runWithOptionalStandBlink("Quick Sell Shop", function()
        return sellItems:InvokeServer(guids)
    end)
    if okS and type(res) == "table" and res.success ~= false then
        return #guids, "Sold!"
    end
    return 0, tostring(type(res) == "table" and (res.error or res.Message) or res)
end

UI_Elements.AutoPawnSell = TabShop:Toggle({
    Title = "Peak-Rate Pawn Auto-Seller",
    Desc = "Automatically sells unfavorited items when Rick Harrison's Pawn Rate >= slider threshold",
    Value = false,
    Callback = function(v) State.AutoPawnSell = v end,
})

UI_Elements.MinPawnRatePct = TabShop:Slider({
    Title = "Minimum Pawn Rate (%)",
    Desc = "Waits for Rick Harrison's 5-min rate roll to reach this % (max ~100%+)",
    Value = { Min = 50, Max = 110, Default = 85 },
    Step = 5,
    Callback = function(v) State.MinPawnRatePct = tonumber(v) or State.MinPawnRatePct end,
})

TabShop:Button({
    Title = "Quick Sell All Unfavorited Now",
    Desc = "Invokes Pawn.SellItems (uses Stand Micro-Blink if enabled and out of range)",
    Callback = function()
        local n, msg = sellToPawnShopNow()
        notify("Pawn Shop", n > 0 and ("Sold " .. n .. " item(s)!") or tostring(msg), 3)
    end,
})

local upgradeOptions = {}
if ShopUpgradesConfigMod and type(ShopUpgradesConfigMod.Upgrades) == "table" then
    for _, u in pairs(ShopUpgradesConfigMod.Upgrades) do
        if type(u) == "table" and u.id then
            table.insert(upgradeOptions, u.id)
        end
    end
    table.sort(upgradeOptions)
end
if #upgradeOptions == 0 then
    upgradeOptions = { "InventorySpace", "SellingSlots", "Advertising", "TipJar", "PriceTags", "PlotItemLimit", "StorageBoxCapacity" }
end

UI_Elements.SelectedUpgradeId = TabShop:Dropdown({
    Title = "Target Shop Upgrade",
    Values = upgradeOptions,
    Value = "InventorySpace",
    Callback = function(v) State.SelectedUpgradeId = v end,
})

UI_Elements.AutoBuyUpgrades = TabShop:Toggle({
    Title = "Auto Buy Selected Shop Upgrade",
    Desc = "Automatically purchases next tier of SelectedUpgradeId when Diamonds & Net Worth allow",
    Value = false,
    Callback = function(v) State.AutoBuyUpgrades = v end,
})

-- =========================================================================
-- TAB 4: SAFES & VALUE MULTIPLIERS
-- =========================================================================
TabServices:Section({ Title = "100%-Success Safe Cracking (Zero Failures)" })
UI_Elements.AutoCrackInventorySafes = TabServices:Toggle({
    Title = "Auto Crack Inventory Safes (100% Picklock)",
    Desc = "Starts picklock session & submits clean unlock after 1.9s on safes within your lockpick tier",
    Value = false,
    Callback = function(v) State.AutoCrackInventorySafes = v end,
})

UI_Elements.AutoCrackAuctionSafes = TabServices:Toggle({
    Title = "Auto Crack Won Auction Safes",
    Desc = "Automatically cracks won safes in _Carryables without opening the timing ring",
    Value = false,
    Callback = function(v) State.AutoCrackAuctionSafes = v end,
})

TabServices:Section({ Title = "Cleaning, Repair, Grading & Locksmith Pipelines" })
UI_Elements.AutoInstantClean = TabServices:Toggle({
    Title = "Auto Instant-Clean Dirty Items",
    Desc = "Uses owned Cleaning Bottle to start & cleanly finish Dirty item wash sessions",
    Value = false,
    Callback = function(v) State.AutoInstantClean = v end,
})

UI_Elements.AutoLocksmithService = TabServices:Toggle({
    Title = "Auto Locksmith Shop Queue & Claim",
    Desc = "Automatically claims unlocked Locksmith safes and submits remaining safes",
    Value = false,
    Callback = function(v) State.AutoLocksmithService = v end,
})

UI_Elements.AutoWashService = TabServices:Toggle({
    Title = "Auto Wash Shop Queue & Claim",
    Desc = "Automatically claims washed items and queues Dirty/Rusty items",
    Value = false,
    Callback = function(v) State.AutoWashService = v end,
})

UI_Elements.AutoRepairService = TabServices:Toggle({
    Title = "Auto Repair Shop Queue & Claim",
    Desc = "Automatically claims repaired items and queues low-condition items",
    Value = false,
    Callback = function(v) State.AutoRepairService = v end,
})

UI_Elements.AutoGradingService = TabServices:Toggle({
    Title = "Auto Grading Store Queue & Claim",
    Desc = "Automatically claims graded items and submits high-value ungraded items",
    Value = false,
    Callback = function(v) State.AutoGradingService = v end,
})

UI_Elements.AutoAuthenticate = TabServices:Toggle({
    Title = "Auto Authenticate Certificates & Accessories",
    Desc = "Automatically applies unused Certificates to uncertified Accessories",
    Value = false,
    Callback = function(v) State.AutoAuthenticate = v end,
})

UI_Elements.AutoMuseumCollectDonate = TabServices:Toggle({
    Title = "Auto Collect & Donate Museum Exhibits",
    Desc = "Collects pending Museum rewards & fills empty Museum slots",
    Value = false,
    Callback = function(v) State.AutoMuseumCollectDonate = v end,
})

UI_Elements.AutoTimeCapsuleCollect = TabServices:Toggle({
    Title = "Auto Collect Time Capsule Slots",
    Desc = "Automatically collects matured Time Capsule slots when ready",
    Value = false,
    Callback = function(v) State.AutoTimeCapsuleCollect = v end,
})

UI_Elements.AllowStandMicroBlink = TabServices:Toggle({
    Title = "Allow Service Stand Micro-Blink",
    Desc = "If a service/shop remote requires proximity, warps briefly to its GPS POI and restores CFrame",
    Value = false,
    Callback = function(v) State.AllowStandMicroBlink = v end,
})

-- =========================================================================
-- TAB 5: WORLD LOOT, MINIGAMES & QUESTS
-- =========================================================================
TabWorld:Section({ Title = "World Scavengers" })
local function collectPersonalLostItemsOnce(maxPerPass)
    local lostFolder = Workspace:FindFirstChild("_LostItems")
    local _, hrp = getRootAndHum()
    if not lostFolder or not hrp then return 0 end
    local savedCF = hrp.CFrame
    local collected = 0
    for _, model in ipairs(lostFolder:GetChildren()) do
        if model:GetAttribute("LostOwnerId") == LocalPlayer.UserId then
            local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
            local pos = getModelPivotPos(model)
            if prompt and pos then
                safeTeleportPos(pos + Vector3.new(0, 1.5, 0))
                safeWait(0.16)
                if activatePromptServerSafe(prompt, nil) then
                    collected += 1
                end
                safeWait(0.14)
                if collected >= (maxPerPass or 5) then break end
            end
        end
    end
    if collected > 0 and hrp.Parent then
        safeTeleportCF(savedCF)
    end
    return collected
end

UI_Elements.AutoCollectLostItems = TabWorld:Toggle({
    Title = "Auto Collect Personal Lost Items (_LostItems)",
    Desc = "Micro-blinks to your LostOwnerId items across the map and fires PickupPrompt",
    Value = false,
    Callback = function(v) State.AutoCollectLostItems = v end,
})

TabWorld:Button({
    Title = "Collect Up To 5 Personal Lost Items Now",
    Desc = "Gathers up to 5 of your active _LostItems immediately and restores position",
    Callback = function()
        local n = collectPersonalLostItemsOnce(5)
        notify("Lost Items", n > 0 and ("Triggered pickup on " .. n .. " Lost Item(s)!") or "No personal Lost Items available / inventory full.", 3)
    end,
})

UI_Elements.AutoCollectFreightNuggets = TabWorld:Toggle({
    Title = "Auto Claim Missing Freight & Gold Nuggets",
    Desc = "Automatically claims spawned MissingFreight parcels and GoldNuggetDrops when available",
    Value = false,
    Callback = function(v) State.AutoCollectFreightNuggets = v end,
})

TabWorld:Section({ Title = "Minigame Bypass (Fishing & Mining)" })
UI_Elements.AutoFishPerfect = TabWorld:Toggle({
    Title = "100% Perfect Catch Auto-Fishing",
    Desc = "Auto-casts Fishing Rod at nearest water and submits caught=true (Perfect Catch) on reel",
    Value = false,
    Callback = function(v) State.AutoFishPerfect = v end,
})

UI_Elements.AutoSelectBestBait = TabWorld:Toggle({
    Title = "Auto Select Best Owned Fishing Bait",
    Desc = "Automatically selects your highest-tier in-stock bait via FishingBait.Select",
    Value = false,
    Callback = function(v) State.AutoSelectBestBait = v end,
})

UI_Elements.AutoMiningCrack = TabWorld:Toggle({
    Title = "Auto Perfect Mining Crack-Bar",
    Desc = "Hits MiningSeason CrackHit automatically when cracking rock nodes",
    Value = false,
    Callback = function(v) State.AutoMiningCrack = v end,
})

TabWorld:Section({ Title = "Warehouse & Progression Claimers" })
UI_Elements.AutoWarehouseOrders = TabWorld:Toggle({
    Title = "Auto Complete Warehouse Orders",
    Desc = "Accepts matching Easy/Medium/Hard Warehouse orders when items are ready & delivers",
    Value = false,
    Callback = function(v) State.AutoWarehouseOrders = v end,
})

local function claimAllProgressionNow()
    local count = 0
    -- 1. Daily Reward
    local claimDaily = findChildPath(DailyEvents, "ClaimDailyReward")
    if claimDaily and LocalPlayer:GetAttribute("DailyRewardClaimable") == true then
        local ok, res = pcall(function() return claimDaily:InvokeServer() end)
        if ok and type(res) == "table" and res.ok then count += 1 end
    end

    -- 2. Collection Milestones
    local getCol = findChildPath(CollectionsEvents, "GetCollectionState")
    local claimCol = findChildPath(CollectionsEvents, "ClaimMilestoneReward")
    if getCol and claimCol and CollectionsMod and type(CollectionsMod.Areas) == "table" then
        local okState, st = pcall(function() return getCol:InvokeServer() end)
        if okState and type(st) == "table" then
            local catalog = st.areaCatalog or (CollectionsMod.BuildAreaCatalog and CollectionsMod.BuildAreaCatalog()) or {}
            local foundMap = st.discovered or st.itemFirstFound or {}
            local claimedMap = st.milestones or {}
            for _, areaDef in ipairs(CollectionsMod.Areas) do
                local areaName = areaDef.Name
                local list = catalog[areaName]
                if type(list) == "table" and #list > 0 and CollectionsMod.GetEligibleMilestoneCount then
                    local okCnt, eligible = pcall(function()
                        local found = 0
                        for _, id in ipairs(list) do
                            if foundMap[tostring(id) .. ":Base"] or foundMap[tostring(id)] or foundMap[id] then
                                found += 1
                            end
                        end
                        return CollectionsMod.GetEligibleMilestoneCount(found, #list, areaName)
                    end)
                    local key = CollectionsMod.ClaimKey and CollectionsMod.ClaimKey(areaName, "Base") or (areaName .. ":Base")
                    local claimed = tonumber(claimedMap[key]) or 0
                    if okCnt and type(eligible) == "number" and eligible > claimed then
                        local okC, resC = pcall(function() return claimCol:InvokeServer(areaName) end)
                        if okC and type(resC) == "table" and resC.success then
                            count += 1
                        end
                    end
                end
            end
        end
    end

    -- 3. Achievements
    local getAch = findChildPath(AchievementEvents, "GetAchievementStatus")
    local claimAch = findChildPath(AchievementEvents, "ClaimAchievementReward")
    if getAch and claimAch then
        local okA, statuses = pcall(function() return getAch:InvokeServer() end)
        if okA and type(statuses) == "table" then
            for badgeKey, info in pairs(statuses) do
                if type(info) == "table" and info.Status == "claimable" then
                    local okC, resC = pcall(function() return claimAch:InvokeServer(badgeKey) end)
                    if okC and type(resC) == "table" and resC.ok then
                        count += 1
                    end
                end
            end
        end
    end
    ensureElevatedIdentity()
    return count
end

UI_Elements.AutoClaimProgression = TabWorld:Toggle({
    Title = "Auto Claim Daily, Milestones & Achievements",
    Desc = "Periodically claims unlocked Daily Rewards, Collection Book milestones & Badges",
    Value = false,
    Callback = function(v) State.AutoClaimProgression = v end,
})

TabWorld:Button({
    Title = "Claim All Progression Rewards Now",
    Desc = "Immediately checks & claims Daily Reward, Collection Milestones & Achievements",
    Callback = function()
        local n = claimAllProgressionNow()
        notify("Progression", n > 0 and ("Claimed " .. n .. " reward(s)!") or "No pending rewards claimable right now.", 3)
    end,
})

-- =========================================================================
-- TAB 6: VEHICLE, TELEPORT & MOVEMENT
-- =========================================================================
TabMovement:Section({ Title = "AFK Guard & Vehicle Enhancements" })
UI_Elements.AntiAfk = TabMovement:Toggle({
    Title = "Anti-AFK (Dual-Layer IdleRejoin Guard)",
    Desc = "Defeats both Roblox 20m timeout (VirtualUser) AND game's 900s IdleRejoin teleport script",
    Value = false,
    Callback = function(v) State.AntiAfk = v end,
})

UI_Elements.AutoAcceptOverweight = TabMovement:Toggle({
    Title = "Auto Accept Vehicle Overweight Prompts",
    Desc = "Confirms SetOverweightAddIntent automatically when loading heavy loot",
    Value = false,
    Callback = function(v) State.AutoAcceptOverweight = v end,
})

UI_Elements.VehicleSpeedBoost = TabMovement:Toggle({
    Title = "Vehicle Speed Multiplier",
    Desc = "Smoothly boosts seated vehicle acceleration along driving heading",
    Value = false,
    Callback = function(v) State.VehicleSpeedBoost = v end,
})

UI_Elements.VehicleSpeedMult = TabMovement:Slider({
    Title = "Vehicle Speed Multiplier",
    Value = { Min = 1.0, Max = 4.0, Default = 1.5 },
    Step = 0.1,
    Callback = function(v) State.VehicleSpeedMult = tonumber(v) or State.VehicleSpeedMult end,
})

TabMovement:Button({
    Title = "Spawn Equipped Vehicle",
    Desc = "Invokes Vehicles.RequestSpawn for your currently equipped vehicle",
    Callback = function()
        local reqSpawn = findChildPath(VehicleEvents, "RequestSpawn")
        local guid = LocalPlayer:GetAttribute("EquippedVehicle")
        if reqSpawn then
            pcall(function() reqSpawn:FireServer(guid) end)
            notify("Vehicle", "Requested spawn for " .. tostring(guid or "equipped vehicle"), 2.5)
        end
    end,
})

TabMovement:Button({
    Title = "Teleport Home (My Shop Plot)",
    Desc = "Fires Events.Plot.TeleportToPlot (with direct CFrame fallback)",
    Callback = function()
        local tpRemote = findChildPath(PlotEvents, "TeleportToPlot")
        if tpRemote then
            pcall(function() tpRemote:FireServer() end)
        end
        local plot = getMyPlot()
        local upPos = getPlotUnpackPosition(plot)
        if upPos then safeTeleportPos(upPos) end
        notify("Teleport", "Returned to your Shop Plot!", 2)
    end,
})

TabMovement:Section({ Title = "Character Movement" })
UI_Elements.CustomWalkSpeed = TabMovement:Toggle({
    Title = "Custom WalkSpeed",
    Value = false,
    Callback = function(v)
        State.CustomWalkSpeed = v
        if not v then
            restoreWalkSpeed()
        end
    end,
})

UI_Elements.WalkSpeed = TabMovement:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 140, Default = 32 },
    Step = 2,
    Callback = function(v) State.WalkSpeed = tonumber(v) or State.WalkSpeed end,
})

UI_Elements.CustomJumpPower = TabMovement:Toggle({
    Title = "Custom JumpPower",
    Value = false,
    Callback = function(v)
        State.CustomJumpPower = v
        if not v then
            restoreJumpPower()
        end
    end,
})

UI_Elements.JumpPower = TabMovement:Slider({
    Title = "JumpPower",
    Value = { Min = 50, Max = 200, Default = 75 },
    Step = 2,
    Callback = function(v) State.JumpPower = tonumber(v) or State.JumpPower end,
})

UI_Elements.InfiniteJump = TabMovement:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v) State.InfiniteJump = v end,
})

UI_Elements.NoClip = TabMovement:Toggle({
    Title = "NoClip",
    Value = false,
    Callback = function(v)
        State.NoClip = v
        if not v then
            restoreNoClip()
        end
    end,
})

UI_Elements.Fly = TabMovement:Toggle({
    Title = "Flight Mode (WASD + Space / LShift)",
    Value = false,
    Callback = function(v)
        State.Fly = v
        if not v then
            restoreFly()
        end
    end,
})

UI_Elements.FlySpeed = TabMovement:Slider({
    Title = "Fly Speed",
    Value = { Min = 25, Max = 220, Default = 80 },
    Step = 5,
    Callback = function(v) State.FlySpeed = tonumber(v) or State.FlySpeed end,
})

TabMovement:Section({ Title = "34-POI GPS Teleporter" })
refreshPOIs(true)
ensureElevatedIdentity()

UI_Elements.SelectedAreaPOI = TabMovement:Dropdown({
    Title = "Auction Areas (11 Areas)",
    Values = #POICache.areas > 0 and POICache.areas or { "Junk Yard", "Back Alley", "Farmyard", "Shipyard", "Shopping Mall", "Lucky Beach", "Power Plant", "Business Bay", "The Mines", "Military Base", "Carnival" },
    Value = State.SelectedAreaPOI,
    Callback = function(v) State.SelectedAreaPOI = v end,
})

TabMovement:Button({
    Title = "Teleport To Selected Area",
    Callback = function()
        local pos = findPOIPosition(State.SelectedAreaPOI)
        if pos and safeTeleportPos(pos + Vector3.new(0, 5, 0)) then
            notify("GPS Teleport", "Warped to " .. State.SelectedAreaPOI, 2)
        else
            notify("GPS Teleport", "Could not resolve coordinates for " .. tostring(State.SelectedAreaPOI), 2.5)
        end
    end,
})

UI_Elements.SelectedShopPOI = TabMovement:Dropdown({
    Title = "Service Shops & Locations",
    Values = #POICache.shops > 0 and POICache.shops or { "Quick Sell Shop", "Locksmith", "Repair Shop", "Grading Store", "Item Cleaning Services", "Authenticator", "Museum", "Warehouse", "Lake", "Tackle Stall" },
    Value = State.SelectedShopPOI,
    Callback = function(v) State.SelectedShopPOI = v end,
})

TabMovement:Button({
    Title = "Teleport To Selected Shop",
    Callback = function()
        local pos = findPOIPosition(State.SelectedShopPOI)
        if pos and safeTeleportPos(pos + Vector3.new(0, 5, 0)) then
            notify("GPS Teleport", "Warped to " .. State.SelectedShopPOI, 2)
        else
            notify("GPS Teleport", "Could not resolve coordinates for " .. tostring(State.SelectedShopPOI), 2.5)
        end
    end,
})

UI_Elements.SelectedPlayerPOI = TabMovement:Dropdown({
    Title = "Player Shops",
    Values = POICache.players,
    Value = POICache.players[1] or "None",
    Callback = function(v) State.SelectedPlayerPOI = v end,
})

TabMovement:Button({
    Title = "Teleport To Player Shop",
    Callback = function()
        local pos = findPOIPosition(State.SelectedPlayerPOI)
        if pos and safeTeleportPos(pos + Vector3.new(0, 5, 0)) then
            notify("GPS Teleport", "Warped to " .. State.SelectedPlayerPOI, 2)
        else
            notify("GPS Teleport", "Select a valid Player Shop first.", 2.5)
        end
    end,
})

-- =========================================================================
-- TAB 7: VISUALS & X-RAY ESP (PARENTED IN GETHUI / COREGUI FOR STEALTH)
-- =========================================================================
TabVisuals:Section({ Title = "Stealth Tactical ESP & Lighting" })
UI_Elements.GarageXRayESP = TabVisuals:Toggle({
    Title = "Garage True-Value & Best Mutator ESP",
    Desc = "Displays exact $Value, Safe count & Mutator tags above populated garages in the world",
    Value = false,
    Callback = function(v) State.GarageXRayESP = v end,
})

UI_Elements.RareItemHighlightESP = TabVisuals:Toggle({
    Title = "Safe & High-Value Item Highlight X-Ray",
    Desc = "Highlights Safes and rare/mutated items in _Carryables through closed garage doors",
    Value = false,
    Callback = function(v) State.RareItemHighlightESP = v end,
})

UI_Elements.LostItemESP = TabVisuals:Toggle({
    Title = "Personal Lost Items ESP",
    Desc = "Marks all your _LostItems across the map with distance labels & highlights",
    Value = false,
    Callback = function(v) State.LostItemESP = v end,
})

UI_Elements.CustomerOfferESP = TabVisuals:Toggle({
    Title = "Shop NPC Customers ESP",
    Desc = "Highlights active shoppers browsing your plot",
    Value = false,
    Callback = function(v) State.CustomerOfferESP = v end,
})

UI_Elements.Fullbright = TabVisuals:Toggle({
    Title = "Fullbright & No Fog",
    Desc = "Removes night shadows & fog (restores original Lighting on disable)",
    Value = false,
    Callback = function(v)
        State.Fullbright = v
        applyFullbright(v)
    end,
})

-- =========================================================================
-- TAB 8: CONFIG & LIFECYCLE
-- =========================================================================
TabConfig:Section({ Title = "Profile Persistence" })
TabConfig:Button({
    Title = "Save Configuration",
    Desc = "Saves all toggles, sliders & dropdowns to disk",
    Callback = saveConfig,
})

TabConfig:Button({
    Title = "Load Configuration",
    Desc = "Restores saved configuration from disk",
    Callback = loadConfig,
})

TabConfig:Button({
    Title = "Reset All Settings (All OFF)",
    Desc = "Disables every active feature and restores game defaults",
    Callback = resetAllToOff,
})

TabConfig:Section({ Title = "Session Lifecycle" })
UI_Elements.AutoReExecuteOnTeleport = TabConfig:Toggle({
    Title = "Auto Re-Execute On Teleport",
    Desc = "Queues script reload across server teleports via queue_on_teleport",
    Value = false,
    Callback = function(v) State.AutoReExecuteOnTeleport = v end,
})

TabConfig:Button({
    Title = "Unload XLunaHUB",
    Desc = "Cleanly disconnects all threads, ESP, Lighting & destroys UI",
    Callback = function()
        if getgenv().XLunaSHOW_Unload then
            getgenv().XLunaSHOW_Unload()
        end
    end,
})

TabConfig:Paragraph({
    Title = "XLunaHUB Compliance Summary",
    Desc = "Toggle UI: LeftControl or Floating Button | Startup: ALL OFF | PlayerGui Stealth: Active",
})

pcall(function() Window:SelectTab(1) end)

-- -------------------------------------------------------------------------
-- 7. BACKGROUND ENGINES & SIGNAL LISTENERS
-- -------------------------------------------------------------------------

-- Dual-Layer Anti-AFK (VirtualUser + IdleRejoin 900s Timestamp Refresh)
trackConn(LocalPlayer.Idled:Connect(function()
    if State.AntiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

trackThread(function()
    while true do
        safeWait(120)
        if State.AntiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            if type(getconnections) == "function" then
                pcall(function()
                    for _, conn in ipairs(getconnections(UserInputService.InputEnded)) do
                        if conn.Function and type(debug) == "table" and type(debug.info) == "function" then
                            local src = debug.info(conn.Function, "s")
                            if type(src) == "string" and src:find("IdleRejoin") then
                                pcall(conn.Function)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- Infinite Jump
trackConn(UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local _, _, hum = getRootAndHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- Instant ProximityPrompts (Server-Hold Safe)
trackConn(ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if not State.InstantPrompts or PromptHoldInFlight[prompt] then return end
    local h = getServerHoldDuration(prompt)
    if h <= 0.02 then
        if type(fireproximityprompt) == "function" then
            pcall(fireproximityprompt, prompt)
        end
        return
    end
    PromptHoldInFlight[prompt] = true
    task.spawn(function()
        ensureElevatedIdentity()
        safeWait(h + 0.15)
        if prompt and prompt.Parent then
            pcall(function() prompt:InputHoldEnd() end)
        end
        PromptHoldInFlight[prompt] = nil
    end)
end))

-- Auction Listeners (Area Enter, Bid Updates, Toggle UI, Cinematic Skip, Lost & Found Override)
if AuctionEvents then
    local toggleAreaRE = AuctionEvents:FindFirstChild("ToggleAuctionArea")
    local updateBidRE = AuctionEvents:FindFirstChild("UpdateCurrentWinningBid")
    local toggleUIRE = AuctionEvents:FindFirstChild("ToggleBiddingUI")
    local playCineRE = AuctionEvents:FindFirstChild("PlayCinematicSequence")
    local cineCompleteRE = AuctionEvents:FindFirstChild("CinematicSequenceComplete")
    local lfOverrideRE = AuctionEvents:FindFirstChild("LostFoundOverride")

    if lfOverrideRE then
        trackConn(lfOverrideRE.OnClientEvent:Connect(function()
            if State.AutoPlayLoop then
                task.delay(0.12, function()
                    ensureElevatedIdentity()
                    handleConfirmPrompts(true)
                end)
            end
        end))
    end

    if toggleAreaRE then
        trackConn(toggleAreaRE.OnClientEvent:Connect(function(inZone, garageModel)
            AuctionRuntime.inZone = inZone == true
            if garageModel then
                AuctionRuntime.garageModel = garageModel
                AuctionRuntime.appraisal = appraiseGarage(garageModel)
            end
        end))
    end

    if toggleUIRE then
        trackConn(toggleUIRE.OnClientEvent:Connect(function(isOpen)
            local wasOpen = AuctionRuntime.inAuction
            AuctionRuntime.inAuction = isOpen == true
            if isOpen then
                if not wasOpen then
                    AuctionRuntime.auctionStartedAt = os.clock()
                    AuctionRuntime.sniperStatus = "Auction Opened"
                end
                if State.AlwaysPerfectBidBar or State.AutoBidSniper or State.AutoPlayLoop then
                    task.defer(installBidBarPerfectHook)
                end
                if AuctionRuntime.garageModel then
                    AuctionRuntime.appraisal = appraiseGarage(AuctionRuntime.garageModel)
                end
            else
                AuctionRuntime.winnerName = "None"
                AuctionRuntime.currentBid = 0
                AuctionRuntime.nextBid = 0
                AuctionRuntime.sniperStatus = "Idle"
                updateBidBarVisual(true)
            end
        end))
    end

    if playCineRE and cineCompleteRE then
        trackConn(playCineRE.OnClientEvent:Connect(function()
            if State.AutoSkipCinematics or State.AutoPlayLoop then
                task.delay(0.15, function()
                    pcall(function() cineCompleteRE:FireServer() end)
                end)
            end
        end))
    end

    if updateBidRE then
        trackConn(updateBidRE.OnClientEvent:Connect(function(curBid, winnerName, _, nextBid, garageModel)
            if garageModel then
                AuctionRuntime.garageModel = garageModel
            end
            if AuctionRuntime.garageModel then
                AuctionRuntime.appraisal = appraiseGarage(AuctionRuntime.garageModel)
            end
            AuctionRuntime.inAuction = true
            if AuctionRuntime.auctionStartedAt == 0 then
                AuctionRuntime.auctionStartedAt = os.clock()
            end
            AuctionRuntime.currentBid = tonumber(curBid) or 0
            AuctionRuntime.winnerName = tostring(winnerName or "None")
            if tonumber(nextBid) then
                AuctionRuntime.nextBid = tonumber(nextBid)
            elseif AuctionRuntime.nextBid <= AuctionRuntime.currentBid then
                AuctionRuntime.nextBid = AuctionRuntime.currentBid + 5
            end
        end))
    end
end

trackConn(LocalPlayer:GetAttributeChangedSignal("AuctionsWon"):Connect(function()
    local cur = tonumber(LocalPlayer:GetAttribute("AuctionsWon")) or 0
    if cur > AuctionRuntime.lastWinCount then
        AuctionRuntime.winsSession += (cur - AuctionRuntime.lastWinCount)
        if State.AutoPlayLoop then
            AutoPlayRuntime.wins += (cur - AuctionRuntime.lastWinCount)
        end
    end
    AuctionRuntime.lastWinCount = cur
end))

-- Cross-Map Customer Offers Handler (Bypasses 55-Stud UI Distance Limit)
if NPCEvents then
    local showOfferRE = NPCEvents:FindFirstChild("ShowOffer")
    local presentedRE = NPCEvents:FindFirstChild("OfferPresented")
    local respondRE = NPCEvents:FindFirstChild("RespondOffer")
    if showOfferRE and respondRE then
        trackConn(showOfferRE.OnClientEvent:Connect(function(offerId, npcModel, itemName, offerPrice, basePrice)
            local oPrice = tonumber(offerPrice) or 0
            local bPrice = tonumber(basePrice) or oPrice
            local markupPct = bPrice > 0 and ((oPrice - bPrice) / bPrice) * 100 or 0
            EconomyRuntime.lastOfferText = string.format("%s: %s (%+.0f%%)", tostring(itemName), formatMoney(oPrice), markupPct)

            if not State.AutoRespondOffers then return end
            task.delay(0.15, function()
                if not State.AutoRespondOffers then return end
                if presentedRE then
                    pcall(function() presentedRE:FireServer(offerId, offerPrice, npcModel) end)
                end
                local accept = markupPct >= (tonumber(State.MinOfferMarkupPct) or 0)
                pcall(function() respondRE:FireServer(offerId, accept) end)
                if accept then
                    EconomyRuntime.offersAccepted += 1
                else
                    EconomyRuntime.offersDeclined += 1
                end
            end)
        end))
    end
end

-- Pawn Rate Live Signal
if PawnEvents then
    local rateRE = PawnEvents:FindFirstChild("RateChanged")
    if rateRE then
        trackConn(rateRE.OnClientEvent:Connect(function(newRate)
            if type(newRate) == "number" then
                EconomyRuntime.pawnRate = newRate
            end
        end))
    end
end

-- 100% Perfect Catch Auto-Fishing Reel Hook
if MiscEvents then
    local fishStateRE = MiscEvents:FindFirstChild("FishingState")
    local fishResultRE = MiscEvents:FindFirstChild("FishingResult")
    if fishStateRE and fishResultRE then
        trackConn(fishStateRE.OnClientEvent:Connect(function(stateName)
            if stateName == "reel" and State.AutoFishPerfect then
                task.delay(1.85, function()
                    if State.AutoFishPerfect then
                        pcall(function() fishResultRE:FireServer("caught", true) end)
                    end
                end)
            end
        end))
    end
end

-- Auto Accept Vehicle Overweight Prompt
if UIEvents then
    local offerOverRE = UIEvents:FindFirstChild("OfferOverweightAdd")
    local setOverRF = UIEvents:FindFirstChild("SetOverweightAddIntent")
    if offerOverRE and setOverRF then
        trackConn(offerOverRE.OnClientEvent:Connect(function()
            if State.AutoAcceptOverweight then
                pcall(function() setOverRF:InvokeServer(true) end)
            end
        end))
    end
end

-- Teleport Queue Hook
trackConn(LocalPlayer.OnTeleport:Connect(function(tpState)
    if State.AutoReExecuteOnTeleport and tpState == Enum.TeleportState.Started and queue_on_teleport then
        pcall(function()
            local src = getgenv().XLunaSHOW_Source
            if type(src) ~= "string" and isfile and isfile("StorageHuntersOpenWorld_Master.lua") then
                src = readfile("StorageHuntersOpenWorld_Master.lua")
            end
            if type(src) == "string" and #src > 100 then
                queue_on_teleport(src)
            end
        end)
    end
end))

-- Fast Frame Physics & Bid Bar Zero-Miss Assist Loop
trackConn(RunService.Stepped:Connect(function(_, dt)
    local char, hrp, hum = getRootAndHum()
    if not char or not hrp or not hum then return end

    if MovementOrig.hum ~= hum then
        MovementOrig = { hum = hum }
        NoClipModifiedParts = {}
        WasFlying = false
    end

    if State.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                NoClipModifiedParts[part] = true
                part.CanCollide = false
            end
        end
    end

    if State.CustomWalkSpeed then
        if MovementOrig.walkSpeed == nil then
            MovementOrig.walkSpeed = hum.WalkSpeed
        end
        if hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end

    if State.CustomJumpPower then
        if MovementOrig.jumpPower == nil then
            MovementOrig.jumpPower = hum.JumpPower
            MovementOrig.jumpHeight = hum.JumpHeight
            MovementOrig.useJumpPower = hum.UseJumpPower
        end
        hum.UseJumpPower = true
        if hum.JumpPower ~= State.JumpPower then
            hum.JumpPower = State.JumpPower
        end
    end

    if State.Fly then
        WasFlying = true
        local cam = Workspace.CurrentCamera
        if cam then
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
            hrp.AssemblyLinearVelocity = move.Magnitude > 0 and (move.Unit * State.FlySpeed) or Vector3.new(0, 0.25, 0)
        end
    end

    if State.VehicleSpeedBoost and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        local seat = hum.SeatPart
        if math.abs(seat.ThrottleFloat) > 0.05 then
            local mult = math.max(1, State.VehicleSpeedMult)
            local dir = seat.CFrame.LookVector * (seat.ThrottleFloat > 0 and 1 or -1)
            local flatDir = Vector3.new(dir.X, 0, dir.Z)
            if flatDir.Magnitude > 0.1 then
                local boostSpeed = (seat.MaxSpeed or 55) * mult
                local vel = seat.AssemblyLinearVelocity
                local horiz = Vector3.new(vel.X, 0, vel.Z)
                if horiz.Magnitude < boostSpeed then
                    local nextHoriz = horiz:Lerp(flatDir.Unit * boostSpeed, math.clamp(dt * 4, 0, 1))
                    seat.AssemblyLinearVelocity = Vector3.new(nextHoriz.X, vel.Y, nextHoriz.Z)
                end
            end
        end
    end
end))

-- Throttled Zero-Miss Bid Bar Visual + Hook Enforcer (0.15s)
trackThread(function()
    while true do
        safeWait(0.15)
        if State.AlwaysPerfectBidBar or State.AutoBidSniper or State.AutoPlayLoop then
            pcall(installBidBarPerfectHook)
            pcall(updateBidBarVisual, false)
        elseif BidUI.visualActive then
            pcall(updateBidBarVisual, true)
        end
    end
end)

-- Active Live-HUD Auction Sniper Loop (0.20s â Zero Stale Cache)
trackThread(function()
    local leaveCooldownUntil = 0
    while true do
        safeWait(0.20)
        if State.AutoBidSniper or State.AutoPlayLoop then
            pcall(function()
                local bidRE = AuctionEvents and AuctionEvents:FindFirstChild("Bid")
                if not bidRE then return end
                local hud = getLiveBiddingHUDState()
                AuctionRuntime.inAuction = hud.isOpen
                if not hud.isOpen then
                    AuctionRuntime.sniperStatus = "Waiting for auction"
                    return
                end
                if AuctionRuntime.auctionStartedAt == 0 then
                    AuctionRuntime.auctionStartedAt = os.clock()
                end
                local activeG = hud.garage
                if activeG then
                    AuctionRuntime.appraisal = appraiseGarage(activeG)
                end
                if hud.isWinning then
                    AuctionRuntime.sniperStatus = "WINNING CURRENT BID"
                    return
                end
                if not hud.canBidNow then
                    AuctionRuntime.sniperStatus = "Bid bar paused / resolving..."
                    return
                end

                local bidCost = tonumber(hud.nextBid) or 0
                local cash = getPlayerCashNumber()
                if bidCost <= 0 then
                    AuctionRuntime.sniperStatus = "Reading NextBid..."
                    return
                end
                if cash < bidCost then
                    AuctionRuntime.sniperStatus = string.format("LOW CASH ($%.0f < $%.0f)", cash, bidCost)
                    return
                end

                if State.AutoBidMode ~= "Always Win (Uncapped)" then
                    local ap = AuctionRuntime.appraisal
                    if not ap or ap.itemCount == 0 then
                        if os.clock() - AuctionRuntime.auctionStartedAt < 4.5 then
                            AuctionRuntime.sniperStatus = "Waiting for locker items to spawn..."
                            return
                        end
                    end
                    if ap then
                        if State.RequireSafeOrMut and ap.safeCount == 0 and not ap.bestMutator then
                            AuctionRuntime.sniperStatus = "SKIP: No Safe/Mutator inside locker"
                            return
                        end
                        local maxAllowed = ap.totalValue * ((tonumber(State.MaxBidValuePct) or 110) / 100)
                        local minNet = tonumber(State.MinNetProfit) or 0
                        local netProfit = ap.totalValue - bidCost - ap.entryCost
                        if ap.itemCount > 0 and (bidCost > maxAllowed or netProfit < minNet) then
                            AuctionRuntime.sniperStatus = string.format(
                                "HOLD: Next %s > Cap %s (Val %s)",
                                formatMoney(bidCost), formatMoney(maxAllowed), formatMoney(ap.totalValue)
                            )
                            if State.AutoPlayLoop and activeG and bidCost > maxAllowed and os.clock() > leaveCooldownUntil then
                                local leaveRF = AuctionEvents:FindFirstChild("LeaveAuction")
                                if leaveRF then
                                    leaveCooldownUntil = os.clock() + 3.0
                                    AutoPlayRuntime.skippedUntil[activeG] = os.clock() + 30
                                    pcall(function() leaveRF:InvokeServer() end)
                                end
                            end
                            return
                        end
                    end
                end

                local delaySec = math.clamp(tonumber(State.BidReactionDelay) or 0.18, 0.05, 1.5)
                if os.clock() - AuctionRuntime.lastBidAt < delaySec then
                    return
                end
                safeWait(math.min(delaySec, 0.25))
                if not (State.AutoBidSniper or State.AutoPlayLoop) then return end
                local hudAfter = getLiveBiddingHUDState()
                if not hudAfter.isOpen or not hudAfter.canBidNow or hudAfter.isWinning then return end
                local costAfter = tonumber(hudAfter.nextBid) or bidCost
                if getPlayerCashNumber() < costAfter then return end

                AuctionRuntime.lastBidAt = os.clock()
                AuctionRuntime.nextBid = costAfter
                pcall(function() bidRE:FireServer() end)
                AuctionRuntime.sniperStatus = "BID SENT @ " .. formatMoney(costAfter)
            end)
        end
    end
end)

-- Full Autonomous Gameplay Progression Loop (Garage -> Bid -> Loot -> Unload -> Stock/Pawn -> Repeat)
trackThread(function()
    local wasInAuction = false
    local initialFlushDone = false
    while true do
        safeWait(0.55)
        if not State.AutoPlayLoop then
            initialFlushDone = false
        else
            pcall(function()
                local _, hrp, hum = getRootAndHum()
                if not hrp or not hum then
                    AutoPlayRuntime.status = "Waiting for character..."
                    return
                end
                if LocalPlayer:GetAttribute("DialogNPC") then
                    AutoPlayRuntime.status = "Waiting for NPC dialog to close..."
                    return
                end

                handleConfirmPrompts(true)

                local hud = getLiveBiddingHUDState()
                local lpInAuc = LocalPlayer:GetAttribute("InAuction") == true
                if hud.isOpen or lpInAuc then
                    wasInAuction = true
                    if hud.isOpen and hud.garage then
                        local zone = hud.garage:FindFirstChild("AuctionZone") or hud.garage:FindFirstChild("EntrySquare")
                        local zonePos = (zone and getModelPivotPos(zone)) or getModelPivotPos(hud.garage)
                        if zonePos and (zonePos - hrp.Position).Magnitude > 14 then
                            safeTeleportPos(zonePos + Vector3.new(0, 2.5, 0))
                        end
                    elseif lpInAuc and not hud.isOpen then
                        local cineCompleteRE = AuctionEvents and AuctionEvents:FindFirstChild("CinematicSequenceComplete")
                        if cineCompleteRE then
                            pcall(function() cineCompleteRE:FireServer() end)
                        end
                    end
                    AutoPlayRuntime.status = string.format(
                        "In Auction (%s) | %s",
                        hud.garage and hud.garage.Name or "Active",
                        AuctionRuntime.sniperStatus
                    )
                    return
                end

                local justFinishedAuction = false
                if wasInAuction then
                    wasInAuction = false
                    justFinishedAuction = true
                    AutoPlayRuntime.status = "Auction ended â waiting for won items..."
                    safeWait(1.25)
                end

                -- Stage A: Collect any owned _Carryables items in world
                local carFolder = Workspace:FindFirstChild("_Carryables")
                local hasWonCarryables = false
                if carFolder then
                    for _, m in ipairs(carFolder:GetChildren()) do
                        if m:IsA("Model") and m:GetAttribute("Owner") == LocalPlayer.UserId then
                            hasWonCarryables = true
                            break
                        end
                    end
                end
                local lootedThisTick = 0
                if hasWonCarryables or justFinishedAuction then
                    AutoPlayRuntime.status = "Looting won boxes & items..."
                    lootedThisTick = lootAllWonItemsNow(false)
                    AutoPlayRuntime.looted += lootedThisTick
                    safeWait(0.35)
                end

                -- Stage B: Unload vehicle & Stock Shelves / Sell Overflow
                local invCap = tonumber(LocalPlayer:GetAttribute("InventoryCap")) or 25
                local invCnt = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0
                local vehCnt = getVehicleCargoCount()

                if vehCnt > 0 or invCnt >= math.max(1, invCap - 3) or ((justFinishedAuction or lootedThisTick > 0 or not initialFlushDone) and invCnt > 0) then
                    initialFlushDone = true
                    if vehCnt > 0 and invCnt < invCap then
                        AutoPlayRuntime.status = string.format("Unloading %d vehicle cargo items at Plot...", vehCnt)
                        unloadVehicleItems(true, false)
                        safeWait(0.30)
                        invCnt = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0
                    end

                    if invCnt > 0 then
                        local sellMode = State.AutoPlaySellMode
                        if sellMode ~= "Pawn Quick-Sell All Immediately" then
                            AutoPlayRuntime.status = "Auto-stocking plot shelves & optimizing 1.45x prices..."
                            local stocked = runRemoteAutoStock()
                            if stocked > 0 then
                                AutoPlayRuntime.stocked += stocked
                                safeWait(0.25)
                                optimizePlotShelfPrices()
                            end
                            safeWait(0.25)
                            invCnt = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0
                        end

                        if invCnt > 0 and sellMode ~= "Stock Shelves Only" then
                            AutoPlayRuntime.status = string.format("Selling %d item(s) at Pawn Shop...", invCnt)
                            local pawnPos = findPOIPosition("Quick Sell Shop")
                            if pawnPos then
                                safeTeleportPos(pawnPos + Vector3.new(0, 4, 0))
                                safeWait(0.25)
                            end
                            local sold = sellToPawnShopNow()
                            if sold > 0 then
                                AutoPlayRuntime.sold += sold
                            end
                            safeWait(0.25)
                        end
                    end

                    invCnt = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0
                    vehCnt = getVehicleCargoCount()
                    if invCnt >= invCap and vehCnt > 0 then
                        AutoPlayRuntime.status = "PAUSED: Inventory & Vehicle full (check favorited items)"
                        safeWait(2.0)
                        return
                    end
                else
                    initialFlushDone = true
                end

                -- Stage C: Find best unlocked & affordable idle garage
                local deb = findChildPath(Workspace, "_Debris", "Garages")
                if not deb then
                    AutoPlayRuntime.status = "Waiting for _Debris.Garages..."
                    return
                end

                local now = os.clock()
                local cash = getPlayerCashNumber()
                local netWorth = getPlayerNetWorthNumber()
                local areaFilter = State.AutoPlayAreaFilter
                local bestGarage, bestScore, bestPrompt = nil, -math.huge, nil

                for _, g in ipairs(deb:GetChildren()) do
                    if g:IsA("Model") and g:GetAttribute("InAuction") ~= true then
                        local skipUntil = AutoPlayRuntime.skippedUntil[g]
                        if not skipUntil or now >= skipUntil then
                            local currency = tostring(g:GetAttribute("EntryCurrency") or "Cash")
                            local areaName = tostring(g:GetAttribute("AreaName") or "")
                            local garageId = tostring(g:GetAttribute("GarageId") or g.Name)
                            local entryCost = tonumber(g:GetAttribute("EntryCost")) or 0
                            local garDef = GaragesMod and GaragesMod[garageId]
                            local minNW = garDef and tonumber(garDef.MinNetWorth) or 0
                            local isEvent = garDef and garDef.EventOnly == true

                            local areaMatch = (areaFilter == "Best Unlocked (Auto)") or (areaName == areaFilter)
                            local affordable = (entryCost == 0) or (cash >= entryCost and (cash < 25 and entryCost == 0 or entryCost <= cash * 0.45))
                            local unlocked = (areaFilter ~= "Best Unlocked (Auto)") or (not isEvent and netWorth >= minNW)

                            if currency == "Cash" and areaMatch and affordable and unlocked then
                                local prompt = findChildPath(g, "EntrySquare", "PromptPart", "EnterAuction") or g:FindFirstChild("EnterAuction", true)
                                local pos = getModelPivotPos(g)
                                if pos and (prompt == nil or prompt.Enabled == true) then
                                    local dist = (pos - hrp.Position).Magnitude
                                    local score = (prompt and prompt.Enabled and 10000 or 0) + (entryCost * 25) - dist * 0.01
                                    if score > bestScore then
                                        bestScore = score
                                        bestGarage = g
                                        bestPrompt = prompt
                                    end
                                end
                            end
                        end
                    end
                end

                if not bestGarage then
                    -- If current cash was low for non-free areas, fall back to $0 Junk Yard garages
                    for _, g in ipairs(deb:GetChildren()) do
                        if g:IsA("Model") and g:GetAttribute("InAuction") ~= true and (tonumber(g:GetAttribute("EntryCost")) or 0) == 0 then
                            local skipUntil = AutoPlayRuntime.skippedUntil[g]
                            if not skipUntil or now >= skipUntil then
                                local prompt = findChildPath(g, "EntrySquare", "PromptPart", "EnterAuction") or g:FindFirstChild("EnterAuction", true)
                                if prompt == nil or prompt.Enabled == true then
                                    bestGarage = g
                                    bestPrompt = prompt
                                    break
                                end
                            end
                        end
                    end
                end

                if not bestGarage then
                    AutoPlayRuntime.status = "No eligible idle garages available right now â retrying..."
                    return
                end

                ensureEquippedVehicleSpawned()

                local targetPart = (bestPrompt and bestPrompt.Parent and bestPrompt.Parent:IsA("BasePart") and bestPrompt.Parent)
                    or findChildPath(bestGarage, "EntrySquare", "PromptPart")
                    or bestGarage:FindFirstChild("EntrySquare")
                    or bestGarage:FindFirstChild("AuctionZone")
                    or bestGarage
                local destPos = getModelPivotPos(targetPart)
                if not destPos then return end

                if hum.SeatPart then
                    hum.Sit = false
                    safeWait(0.12)
                end

                AutoPlayRuntime.status = string.format("Warping to [%s] %s...", tostring(bestGarage:GetAttribute("AreaName") or "?"), bestGarage.Name)
                safeTeleportPos(destPos + Vector3.new(0, 0.35, 0))
                safeWait(0.24)

                if not bestPrompt or not bestPrompt.Parent then
                    bestPrompt = findChildPath(bestGarage, "EntrySquare", "PromptPart", "EnterAuction") or bestGarage:FindFirstChild("EnterAuction", true)
                end

                if bestPrompt and bestPrompt:IsA("ProximityPrompt") and bestPrompt.Enabled then
                    local blocker = bestGarage:FindFirstChild("Blocker")
                    local promptPos = (bestPrompt.Parent and bestPrompt.Parent:IsA("BasePart") and bestPrompt.Parent.Position) or destPos
                    if (promptPos - hrp.Position).Magnitude > 4.5 then
                        safeTeleportPos(promptPos + Vector3.new(0, 0.35, 0))
                        safeWait(0.18)
                    end
                    AuctionRuntime.garageModel = bestGarage
                    AuctionRuntime.auctionStartedAt = 0
                    AutoPlayRuntime.status = string.format("Holding EnterAuction on %s...", bestGarage.Name)
                    activatePromptServerSafe(bestPrompt, blocker)

                    local opened = false
                    local retriedHold = false
                    local sentCine = false
                    local waitStart = os.clock()
                    local cineCompleteRE = AuctionEvents and AuctionEvents:FindFirstChild("CinematicSequenceComplete")
                    while os.clock() - waitStart < 7.5 and State.AutoPlayLoop do
                        handleConfirmPrompts(true)
                        if not sentCine and os.clock() - waitStart >= 1.2 and cineCompleteRE then
                            sentCine = true
                            pcall(function() cineCompleteRE:FireServer() end)
                        end
                        if getLiveBiddingHUDState().isOpen or bestGarage:GetAttribute("InAuction") == true or LocalPlayer:GetAttribute("InAuction") == true then
                            opened = true
                            break
                        end
                        if not retriedHold and os.clock() - waitStart >= 3.8 and bestPrompt.Parent and bestPrompt.Enabled then
                            retriedHold = true
                            AutoPlayRuntime.status = string.format("Retrying EnterAuction on %s...", bestGarage.Name)
                            activatePromptServerSafe(bestPrompt, blocker)
                        else
                            safeWait(0.22)
                        end
                    end
                    if not opened then
                        AutoPlayRuntime.skippedUntil[bestGarage] = os.clock() + 18
                    end
                else
                    AutoPlayRuntime.skippedUntil[bestGarage] = os.clock() + 25
                end
            end)
        end
    end
end)

-- Uniform Service Station Processor (Locksmith / Wash / Repair / Grading)
local ServiceDefinitions = {
    {
        stateKey = "AutoLocksmithService",
        events = LocksmithEvents,
        stateRF = "GetSlotState",
        itemsRF = "GetLockableItems",
        startRF = "StartLocksmith",
        claimRF = "ClaimItem",
        poi = "Locksmith",
    },
    {
        stateKey = "AutoWashService",
        events = WashEvents,
        stateRF = "GetSlotState",
        itemsRF = "GetWashableItems",
        startRF = "StartWash",
        claimRF = "ClaimWashedItem",
        poi = "Item Cleaning Services",
    },
    {
        stateKey = "AutoRepairService",
        events = RepairEvents,
        stateRF = "GetSlotState",
        itemsRF = "GetRepairableItems",
        startRF = "StartRepair",
        claimRF = "ClaimRepairedItem",
        poi = "Repair Shop",
    },
    {
        stateKey = "AutoGradingService",
        events = GradingEvents,
        stateRF = "GetSlotState",
        itemsRF = "GetGradableItems",
        startRF = "StartGrading",
        claimRF = "ClaimGradedItem",
        poi = "Grading Store",
    },
}

local function processServiceStation(def)
    if not State[def.stateKey] or not def.events then return end
    local getSlot = def.events:FindFirstChild(def.stateRF)
    local getItems = def.events:FindFirstChild(def.itemsRF)
    local startFn = def.events:FindFirstChild(def.startRF)
    local claimFn = def.events:FindFirstChild(def.claimRF)
    if not getSlot or not getItems or not startFn or not claimFn then return end

    local okS, st = pcall(function() return getSlot:InvokeServer() end)
    if not okS or type(st) ~= "table" then return end

    local unlocked = tonumber(st.unlockedCount) or 1
    local slots = type(st.slots) == "table" and st.slots or {}
    local nowSrv = Workspace:GetServerTimeNow()
    local freeSlots = {}

    for i = 1, unlocked do
        local s = slots[i] or slots[tostring(i)]
        if s and type(s) == "table" then
            local ready = s.ready == true or (type(s.readyAt) == "number" and nowSrv >= s.readyAt) or (type(s.unlockAt) == "number" and nowSrv >= s.unlockAt)
            if ready then
                runWithOptionalStandBlink(def.poi, function() return claimFn:InvokeServer(i) end)
                table.insert(freeSlots, i)
            end
        else
            table.insert(freeSlots, i)
        end
    end

    if #freeSlots == 0 then return end
    local okI, items = pcall(function() return getItems:InvokeServer() end)
    if not okI or type(items) ~= "table" then return end

    local queue = {}
    for guid, entry in pairs(items) do
        if type(entry) == "table" and entry.Favorited ~= true then
            local g = entry.Guid or entry.GUID or entry.guid or guid
            table.insert(queue, { guid = g, source = entry.source or "Inventory", vehicleGUID = entry.vehicleGUID, val = computeItemValue(entry) })
        end
    end
    table.sort(queue, function(a, b) return a.val > b.val end)

    for idx, slotIdx in ipairs(freeSlots) do
        local item = queue[idx]
        if not item then break end
        runWithOptionalStandBlink(def.poi, function()
            return startFn:InvokeServer(slotIdx, item.guid, item.source, item.vehicleGUID)
        end)
    end
end

-- Fast Automation Loop (0.55s): Loot Won Items, Picklock Safes, Instant Clean, Fishing Cast, Mining Crack
trackThread(function()
    local activePicklock = false
    local nextCastAt = 0
    local nextCleanAt = 0
    local nextRepairAt = 0
    while true do
        safeWait(0.55)
        local now = os.clock()
        local char, hrp, hum = getRootAndHum()

        -- Auto Loot Won Locker Items & Boxes
        if State.AutoLootWonItems and not State.AutoPlayLoop and not AuctionRuntime.inAuction and hrp then
            pcall(lootAllWonItemsNow, true)
        end

        -- Auto Wrench-Repair Won Items (< 50% Condition)
        if State.AutoWrenchRepairWon and now >= nextRepairAt then
            local repairWonRF = findChildPath(WrenchEvents, "RepairWonItem")
            local wrenchId, maxVal = getBestWrenchStats()
            local carFolder = Workspace:FindFirstChild("_Carryables")
            if repairWonRF and wrenchId and carFolder then
                for _, model in ipairs(carFolder:GetChildren()) do
                    if model:GetAttribute("Owner") == LocalPlayer.UserId then
                        local cond = tonumber(model:GetAttribute("Condition")) or 100
                        local wonGuid = model:GetAttribute("ItemsWonGUID")
                        if cond < 50 and type(wonGuid) == "string" and wonGuid ~= "" then
                            local val = computeItemValue(model)
                            if val <= maxVal then
                                nextRepairAt = now + 1.5
                                pcall(function() repairWonRF:InvokeServer(wonGuid, wrenchId) end)
                                break
                            end
                        end
                    end
                end
            end
        end

        -- 100%-Success Safe Cracking (Inventory + Won Auction Safes)
        if (State.AutoCrackInventorySafes or State.AutoCrackAuctionSafes) and not activePicklock and LocksmithEvents then
            local startSess = LocksmithEvents:FindFirstChild("StartPicklockSession")
            local crackInv = LocksmithEvents:FindFirstChild("PicklockInventorySafe")
            local crackWorld = LocksmithEvents:FindFirstChild("PicklockSafe")
            local ownedTier = getBestOwnedPicklockTier()

            if startSess and ownedTier >= 0 then
                if State.AutoCrackInventorySafes and crackInv and ItemsMod and SafesMod then
                    local inv = refreshInventory(false)
                    for guid, entry in pairs(inv) do
                        if type(entry) == "table" and entry.ItemId then
                            local def = ItemsMod[tostring(entry.ItemId)]
                            local safeDef = def and def.SafeId and SafesMod[tostring(def.SafeId)]
                            local reqTier = (safeDef and tonumber(safeDef.MinPickTier)) or 0
                            if safeDef and ownedTier >= reqTier then
                                activePicklock = true
                                local g = entry.Guid or entry.GUID or guid
                                task.spawn(function()
                                    local okS, res = pcall(function() return startSess:InvokeServer("Inventory", g) end)
                                    if okS and type(res) == "table" and res.success and res.sessionId then
                                        task.wait(1.85)
                                        pcall(function() crackInv:InvokeServer(g, res.sessionId) end)
                                    end
                                    task.wait(0.3)
                                    activePicklock = false
                                end)
                                break
                            end
                        end
                    end
                end

                if not activePicklock and State.AutoCrackAuctionSafes and crackWorld and ItemsMod and SafesMod then
                    local carFolder = Workspace:FindFirstChild("_Carryables")
                    if carFolder then
                        for _, model in ipairs(carFolder:GetChildren()) do
                            if model:GetAttribute("Owner") == LocalPlayer.UserId then
                                local def = ItemsMod[tostring(model:GetAttribute("ItemId") or "")]
                                local safeDef = def and def.SafeId and SafesMod[tostring(def.SafeId)]
                                local reqTier = (safeDef and tonumber(safeDef.MinPickTier)) or 0
                                local wonGuid = model:GetAttribute("ItemsWonGUID")
                                if safeDef and ownedTier >= reqTier and type(wonGuid) == "string" and wonGuid ~= "" then
                                    activePicklock = true
                                    task.spawn(function()
                                        local okS, res = pcall(function() return startSess:InvokeServer("Auction", wonGuid) end)
                                        if okS and type(res) == "table" and res.success and res.sessionId then
                                            task.wait(1.85)
                                            pcall(function() crackWorld:InvokeServer(wonGuid, res.sessionId) end)
                                        end
                                        task.wait(0.3)
                                        activePicklock = false
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Auto Instant-Clean Dirty Items
        if State.AutoInstantClean and now >= nextCleanAt and CleaningEvents then
            local getDirty = CleaningEvents:FindFirstChild("GetDirtyItems")
            local startClean = CleaningEvents:FindFirstChild("StartCleaning")
            local cleanAct = CleaningEvents:FindFirstChild("CleaningAction")
            local bottleTool = CleaningConfigMod and char and CleaningConfigMod.GetHeldBottleTool and CleaningConfigMod.GetHeldBottleTool(char)
            local bottleGuid = bottleTool and (bottleTool:GetAttribute("GUID") or bottleTool:GetAttribute("Guid"))
            if getDirty and startClean and cleanAct and bottleGuid then
                local okD, dirty = pcall(function() return getDirty:InvokeServer() end)
                if okD and type(dirty) == "table" then
                    for guid, entry in pairs(dirty) do
                        local g = (type(entry) == "table" and (entry.Guid or entry.GUID or entry.guid)) or guid
                        if type(g) == "string" and g ~= "" then
                            nextCleanAt = now + 2.5
                            task.spawn(function()
                                local okS, res = pcall(function() return startClean:InvokeServer(g, bottleGuid) end)
                                if okS and type(res) == "table" and res.success and res.sessionId then
                                    task.wait(1.6)
                                    pcall(function() cleanAct:FireServer("finish", res.sessionId, { elapsed = 1.6 }) end)
                                end
                            end)
                            break
                        end
                    end
                end
            end
        end

        -- 100% Perfect Auto-Fishing Auto-Cast
        if State.AutoFishPerfect and hrp and now >= nextCastAt and MiscEvents then
            local castRE = MiscEvents:FindFirstChild("FishingCast")
            local heldTool = char and char:FindFirstChildOfClass("Tool")
            if castRE and heldTool and heldTool.Name:lower():find("rod") then
                local bestWater, bestHitPos, bestDist = nil, nil, 240
                for _, inst in ipairs(Workspace:GetDescendants()) do
                    if inst:IsA("BasePart") and inst.Name:lower() == "water" then
                        local p = inst.Position
                        local clampX = math.clamp(hrp.Position.X, p.X - inst.Size.X * 0.45, p.X + inst.Size.X * 0.45)
                        local clampZ = math.clamp(hrp.Position.Z, p.Z - inst.Size.Z * 0.45, p.Z + inst.Size.Z * 0.45)
                        local hitPos = Vector3.new(clampX, p.Y + inst.Size.Y * 0.5, clampZ)
                        local d = (hitPos - hrp.Position).Magnitude
                        if d < bestDist then
                            bestDist = d
                            bestWater = inst
                            bestHitPos = hitPos
                        end
                    end
                end
                if bestWater and bestHitPos then
                    nextCastAt = now + 4.5
                    pcall(function() castRE:FireServer(bestWater, bestHitPos) end)
                end
            end
        end

        -- Auto Perfect Mining Crack-Bar
        if State.AutoMiningCrack and MiningEvents and hrp then
            local crackHitRE = MiningEvents:FindFirstChild("CrackHit")
            local mineNodes = findChildPath(Workspace, "Areas", "The Mines")
            if crackHitRE and mineNodes then
                for _, d in ipairs(mineNodes:GetDescendants()) do
                    local key = d:GetAttribute("NodeKey") or d:GetAttribute("MiningKey")
                    if key then
                        local pos = getModelPivotPos(d)
                        if pos and (pos - hrp.Position).Magnitude <= 16 then
                            pcall(function() crackHitRE:FireServer(key) end)
                        end
                    end
                end
            end
        end
    end
end)

-- Throttled Slow Automation Loop (Shop, Pawn, Services, World Scavengers, Progression)
trackThread(function()
    local nextProgAt = 0
    local nextShopAt = 0
    local nextUpgAt = 0
    local nextServicesAt = 0
    local nextLostAt = 0
    local nextFreightAt = 0
    local lastUpgDiamonds = -1
    local lastUpgTarget = nil
    while true do
        safeWait(1.0)
        local now = os.clock()
        local invCntNow = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0

        if now >= nextShopAt then
            nextShopAt = now + 3.5
            if State.AutoStockShelves and not State.AutoPlayLoop and invCntNow > 0 then
                pcall(runRemoteAutoStock)
            end

            if State.AutoOptimizePrices then
                pcall(optimizePlotShelfPrices)
            end

            if State.AutoUnloadVehicle and not State.AutoPlayLoop then
                local _, hrp = getRootAndHum()
                local plot = getMyPlot()
                local unpackPos = getPlotUnpackPosition(plot)
                if hrp and unpackPos and (hrp.Position - unpackPos).Magnitude <= 16 and getVehicleCargoCount() > 0 then
                    pcall(unloadVehicleItems, false, false)
                end
            end

            if State.AutoPawnSell and not State.AutoPlayLoop and invCntNow > 0 and (EconomyRuntime.pawnRate * 100) >= State.MinPawnRatePct then
                pcall(sellToPawnShopNow)
            end
        end

        if State.AutoBuyUpgrades and UpgradeEvents and now >= nextUpgAt then
            nextUpgAt = now + 6.0
            local diamondsNow = tonumber(LocalPlayer:GetAttribute("Diamonds")) or 0
            if diamondsNow ~= lastUpgDiamonds or State.SelectedUpgradeId ~= lastUpgTarget then
                lastUpgDiamonds = diamondsNow
                lastUpgTarget = State.SelectedUpgradeId
                local buyUpg = UpgradeEvents:FindFirstChild("BuyUpgrade")
                if buyUpg and State.SelectedUpgradeId then
                    pcall(function() buyUpg:InvokeServer(State.SelectedUpgradeId) end)
                end
            end
        end

        -- Uniform Service Stations & Museum/Auth/TimeCapsule every 4s
        if now >= nextServicesAt then
            nextServicesAt = now + 4.0
            for _, def in ipairs(ServiceDefinitions) do
                if State[def.stateKey] then
                    pcall(processServiceStation, def)
                end
            end

            if State.AutoAuthenticate and AuthEvents then
                local getAuth = AuthEvents:FindFirstChild("GetState")
                local doAuth = AuthEvents:FindFirstChild("Authenticate")
                if getAuth and doAuth then
                    local okA, st = pcall(function() return getAuth:InvokeServer() end)
                    if okA and type(st) == "table" and type(st.certificates) == "table" and type(st.accessories) == "table" then
                        local cert = st.certificates[1]
                        if cert and cert.guid then
                            for _, acc in ipairs(st.accessories) do
                                if acc.guid and not acc.certified then
                                    runWithOptionalStandBlink("Authenticator", function()
                                        return doAuth:InvokeServer(cert.guid, acc.guid)
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if State.AutoMuseumCollectDonate and MuseumEvents then
                local getM = MuseumEvents:FindFirstChild("GetState")
                local colM = MuseumEvents:FindFirstChild("Collect")
                local donM = MuseumEvents:FindFirstChild("Donate")
                if getM and colM then
                    local okM, st = pcall(function() return getM:InvokeServer() end)
                    if okM and type(st) == "table" then
                        for idx, slot in pairs(st.Slots or {}) do
                            if type(slot) == "table" and slot.Pending then
                                pcall(function() colM:InvokeServer(tonumber(idx) or idx) end)
                            end
                        end
                        if donM and type(st.Eligible) == "table" and #st.Eligible > 0 then
                            local maxSlot = tonumber(st.Unlocked) or 1
                            for i = 1, maxSlot do
                                if not (st.Slots and (st.Slots[i] or st.Slots[tostring(i)])) then
                                    local elig = st.Eligible[1]
                                    if elig and elig.guid then
                                        pcall(function() donM:InvokeServer(i, elig.guid) end)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if State.AutoTimeCapsuleCollect and TimeCapsuleEvents then
                local getTC = TimeCapsuleEvents:FindFirstChild("GetSlotStates")
                local colTC = TimeCapsuleEvents:FindFirstChild("CollectItem")
                if getTC and colTC then
                    local okT, st = pcall(function() return getTC:InvokeServer() end)
                    if okT and type(st) == "table" and type(st.slots) == "table" then
                        for idx, slot in pairs(st.slots) do
                            if type(slot) == "table" and slot.ready == true then
                                pcall(function() colTC:InvokeServer(tonumber(idx) or idx) end)
                            end
                        end
                    end
                end
            end
        end

        -- World Collectibles (Lost Items, Freight, Nuggets)
        if State.AutoCollectLostItems and now >= nextLostAt then
            nextLostAt = now + 2.0
            pcall(collectPersonalLostItemsOnce, 2)
        end

        if State.AutoCollectFreightNuggets and now >= nextFreightAt then
            nextFreightAt = now + 3.0
            if FreightEvents then
                local getF = FreightEvents:FindFirstChild("GetWorldState")
                local claimF = FreightEvents:FindFirstChild("ClaimWorldParcel")
                if getF and claimF then
                    local okF, st = pcall(function() return getF:InvokeServer() end)
                    if okF and type(st) == "table" and type(st.Parcels) == "table" then
                        for _, parcel in ipairs(st.Parcels) do
                            if type(parcel) == "table" and parcel.Id then
                                pcall(function() claimF:InvokeServer(parcel.Id) end)
                            end
                        end
                    end
                end
            end
            if NuggetEvents then
                local getN = NuggetEvents:FindFirstChild("GetState")
                local claimN = NuggetEvents:FindFirstChild("Claim")
                if getN and claimN then
                    local okN, st = pcall(function() return getN:InvokeServer() end)
                    if okN and type(st) == "table" and type(st.Drops) == "table" then
                        for _, drop in ipairs(st.Drops) do
                            if type(drop) == "table" and drop.Index and drop.Token then
                                pcall(function() claimN:InvokeServer(drop.Index, drop.Token) end)
                            end
                        end
                    end
                end
            end
        end

        -- Best Fishing Bait, Warehouse Orders, Progression Claims (every 5s)
        if now >= nextProgAt then
            nextProgAt = now + 5.0
            if State.AutoSelectBestBait and BaitEvents then
                local getB = BaitEvents:FindFirstChild("GetState")
                local selB = BaitEvents:FindFirstChild("Select")
                if getB and selB and FishingBaitConfigMod then
                    local okB, st = pcall(function() return getB:InvokeServer() end)
                    if okB and type(st) == "table" and type(st.Stock) == "table" then
                        local order = FishingBaitConfigMod.Order or { "Squid", "Minnow", "Shrimp", "Worm" }
                        for i = #order, 1, -1 do
                            local bName = order[i]
                            if (tonumber(st.Stock[bName]) or 0) > 0 and st.Selected ~= bName then
                                pcall(function() selB:InvokeServer(bName) end)
                                break
                            end
                        end
                    end
                end
            end

            if State.AutoWarehouseOrders and WarehouseEvents then
                local getW = WarehouseEvents:FindFirstChild("GetState")
                local accW = WarehouseEvents:FindFirstChild("AcceptOrder")
                local delW = WarehouseEvents:FindFirstChild("DeliverOrder")
                if getW and accW and delW then
                    local okW, st = pcall(function() return getW:InvokeServer() end)
                    if okW and type(st) == "table" then
                        if st.Status == "Active" and st.Active and st.Active.ReadyToDeliver then
                            pcall(function() delW:InvokeServer() end)
                        elseif st.Status == "Available" and type(st.Options) == "table" then
                            local inv = refreshInventory(false)
                            local itemCounts = {}
                            for _, e in pairs(inv) do
                                if type(e) == "table" and e.ItemId then
                                    local idStr = tostring(e.ItemId)
                                    itemCounts[idStr] = (itemCounts[idStr] or 0) + 1
                                end
                            end
                            for _, diff in ipairs({ "Hard", "Medium", "Easy" }) do
                                local opt = st.Options[diff]
                                if opt and (itemCounts[tostring(opt.ItemId)] or 0) >= (tonumber(opt.Count) or 1) then
                                    pcall(function() accW:InvokeServer(diff) end)
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if State.AutoClaimProgression then
                pcall(claimAllProgressionNow)
            end

            if PawnEvents then
                local getP = PawnEvents:FindFirstChild("GetPawnState")
                if getP then
                    local okP, st = pcall(function() return getP:InvokeServer() end)
                    if okP and type(st) == "table" then
                        EconomyRuntime.pawnRate = tonumber(st.rate) or EconomyRuntime.pawnRate
                        EconomyRuntime.pawnSecondsLeft = tonumber(st.secondsUntilNext) or 0
                    end
                end
            end
        end
    end
end)

-- -------------------------------------------------------------------------
-- 8. LIVE TELEMETRY & STEALTH ESP LOOP (PARENTED IN GETHUI / COREGUI)
-- -------------------------------------------------------------------------
local StealthParent = getStealthContainerParent()
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "XLuna_SHOW_ESP"
ESPFolder.Parent = StealthParent

local function ensureESPFolder()
    ensureElevatedIdentity()
    if not ESPFolder or not ESPFolder.Parent then
        ESPFolder = Instance.new("Folder")
        ESPFolder.Name = "XLuna_SHOW_ESP"
        ESPFolder.Parent = getStealthContainerParent()
    end
    return ESPFolder
end

local function addESPLabel(adornee, name, text, color, offsetY, maxDist)
    ensureElevatedIdentity()
    local folder = ensureESPFolder()
    local bb = Instance.new("BillboardGui")
    bb.Name = name
    bb.Adornee = adornee
    bb.Size = UDim2.fromOffset(240, 44)
    bb.StudsOffsetWorldSpace = Vector3.new(0, offsetY or 6, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = maxDist or 2500
    bb.Parent = folder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.1
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.Parent = bb
    return bb
end

local function addESPHighlight(adornee, color)
    ensureElevatedIdentity()
    local folder = ensureESPFolder()
    local hl = Instance.new("Highlight")
    hl.Adornee = adornee
    hl.FillColor = color
    hl.FillTransparency = 0.55
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.OutlineTransparency = 0.1
    hl.Parent = folder
    return hl
end

local function runTelemetryAndESPOnce()
    local _, hrp = getRootAndHum()
    local myPos = hrp and hrp.Position
    local ranked = nil

    -- Block A: Telemetry Dashboards & Live Garage Ranker
    pcall(function()
        ensureElevatedIdentity()
        ranked = scanAllActiveGarages()
        local hud = getLiveBiddingHUDState()
        local activeRep = AuctionRuntime.appraisal or (hud.garage and appraiseGarage(hud.garage)) or ranked[1]
        if activeRep then
            local nextB = hud.isOpen and (tonumber(hud.nextBid) or AuctionRuntime.nextBid) or activeRep.entryCost
            local net = activeRep.totalValue - nextB - activeRep.entryCost
            safeSetDesc(AuctionDashboard, string.format(
                "Target: [%s] %s (%s) | Items: %d | Safes: %d | Mut: %s\nTrue Value: %s | Next/Entry: %s | Est. Net: %s | Sniper: %s",
                activeRep.area, activeRep.name, hud.isOpen and "LIVE BIDDING" or "X-RAY",
                activeRep.itemCount, activeRep.safeCount, tostring(activeRep.bestMutator or "None"),
                formatMoney(activeRep.totalValue), formatMoney(nextB), formatMoney(net), AuctionRuntime.sniperStatus
            ))
        else
            safeSetDesc(AuctionDashboard, "No active auction or populated locker nearby. Walk up to any garage to X-Ray.")
        end

        safeSetDesc(AutoPlayStatusPara, string.format(
            "State: %s\nSession Stats â Wins: %d | Looted: %d | Stocked: %d | Pawn Sold: %d",
            State.AutoPlayLoop and AutoPlayRuntime.status or "Idle (OFF)",
            AutoPlayRuntime.wins, AutoPlayRuntime.looted, AutoPlayRuntime.stocked, AutoPlayRuntime.sold
        ))

        updateGarageRankingCard(ranked)

        local plot = getMyPlot()
        local stockFolder = plot and plot:FindFirstChild("Stock")
        local stockCnt = stockFolder and #stockFolder:GetChildren() or 0
        safeSetDesc(ShopDashboard, string.format(
            "Plot: %s | Stocked Items: %d | Pawn Rate: %.1f%% (%ds)\nOffers Auto-Handled: +%d / -%d | Last Offer: %s",
            plot and plot.Name or "None", stockCnt, EconomyRuntime.pawnRate * 100, math.floor(EconomyRuntime.pawnSecondsLeft),
            EconomyRuntime.offersAccepted, EconomyRuntime.offersDeclined, EconomyRuntime.lastOfferText
        ))

        local cash = getPlayerCashNumber()
        local diamonds = getPlayerDiamondsNumber()
        local invCnt = tonumber(LocalPlayer:GetAttribute("InventoryCount")) or 0
        local invCap = tonumber(LocalPlayer:GetAttribute("InventoryCap")) or 0
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        local netWorth = ls and ls:FindFirstChild("Net Worth") and ls["Net Worth"].Value or "$0"
        safeSetDesc(AccountDashboard, string.format(
            "Cash: %s | Diamonds: %d | Net Worth: %s\nInventory: %d / %d | Picklock Tier: %d | Eq. Vehicle: %s",
            formatMoney(cash), diamonds, tostring(netWorth),
            invCnt, invCap, getBestOwnedPicklockTier(), tostring(LocalPlayer:GetAttribute("EquippedVehicle") or "None")
        ))

        local lostFolder = Workspace:FindFirstChild("_LostItems")
        local myLost = 0
        if lostFolder then
            for _, m in ipairs(lostFolder:GetChildren()) do
                if m:GetAttribute("LostOwnerId") == LocalPlayer.UserId then myLost += 1 end
            end
        end
        local claimableDaily = LocalPlayer:GetAttribute("DailyRewardClaimable") == true and "READY" or "Cooldown"
        safeSetDesc(WorldDashboard, string.format(
            "Personal Lost Items In World: %d | Populated Garages: %d\nDaily Reward: %s | WalkSpeed: %s",
            myLost, #ranked, claimableDaily, State.CustomWalkSpeed and tostring(State.WalkSpeed) or "Default"
        ))

        if State.Fullbright then
            applyFullbright(true)
        end
    end)

    -- Block B: Stealth ESP Renderer (Parented in gethui() / CoreGui)
    pcall(function()
        ensureElevatedIdentity()
        local folder = ensureESPFolder()
        folder:ClearAllChildren()

        if not (State.GarageXRayESP or State.RareItemHighlightESP or State.LostItemESP or State.CustomerOfferESP) then
            return
        end

        if State.GarageXRayESP then
            local espRanked = ranked or scanAllActiveGarages()
            for _, r in ipairs(espRanked) do
                local adornee = r.garage:FindFirstChild("Door") or r.garage:FindFirstChild("Floorspace") or r.garage
                local dist = myPos and r.pos and math.floor((r.pos - myPos).Magnitude) or 0
                local col = r.bestMutator and Color3.fromRGB(255, 195, 50) or (r.safeCount > 0 and Color3.fromRGB(100, 225, 255) or Color3.fromRGB(115, 255, 130))
                addESPLabel(adornee, "GarageESP", string.format("[%s] %s\nWorth %s | Items %d | Mut: %s [%dm]", r.area, r.name, formatMoney(r.totalValue), r.itemCount, tostring(r.bestMutator or "-"), dist), col, 10, 4000)
            end
        end

        if State.RareItemHighlightESP then
            local carFolder = Workspace:FindFirstChild("_Carryables")
            if carFolder then
                for _, model in ipairs(carFolder:GetChildren()) do
                    if model:IsA("Model") and model:GetAttribute("ItemId") then
                        local val, _, def = computeItemValue(model)
                        local isSafe = def and def.SafeId ~= nil
                        local mutName = extractBestMutatorFromModel(model)
                        if isSafe or mutName or val >= 200 then
                            local col = isSafe and Color3.fromRGB(0, 225, 255) or (mutName and Color3.fromRGB(255, 180, 40) or Color3.fromRGB(130, 255, 130))
                            addESPHighlight(model, col)
                            addESPLabel(model, "RareESP", string.format("%s (%s)%s", (def and def.Name) or model.Name, formatMoney(val), mutName and (" [" .. mutName .. "]") or ""), col, 2.5, 1200)
                        end
                    end
                end
            end
        end

        if State.LostItemESP then
            local lostFolder = Workspace:FindFirstChild("_LostItems")
            if lostFolder then
                for _, model in ipairs(lostFolder:GetChildren()) do
                    if model:GetAttribute("LostOwnerId") == LocalPlayer.UserId then
                        local pos = getModelPivotPos(model)
                        local dist = (myPos and pos) and math.floor((pos - myPos).Magnitude) or 0
                        addESPHighlight(model, Color3.fromRGB(255, 120, 255))
                        addESPLabel(model, "LostESP", string.format("[LOST] %s [%dm]", model.Name, dist), Color3.fromRGB(255, 140, 255), 3, 5000)
                    end
                end
            end
        end

        if State.CustomerOfferESP then
            local npcFolder = Workspace:FindFirstChild("_NPCShoppers")
            if npcFolder then
                for _, npc in ipairs(npcFolder:GetChildren()) do
                    if npc:IsA("Model") then
                        addESPHighlight(npc, Color3.fromRGB(80, 255, 180))
                    end
                end
            end
        end
    end)
end

task.defer(runTelemetryAndESPOnce)

trackThread(function()
    while true do
        safeWait(0.85)
        runTelemetryAndESPOnce()
    end
end)

-- -------------------------------------------------------------------------
-- 9. REGISTER UNLOAD & EXPOSE RUNTIME HANDLES
-- -------------------------------------------------------------------------
getgenv().XLunaSHOW_Unload = function()
    ensureElevatedIdentity()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, t in ipairs(Threads) do
        pcall(function() task.cancel(t) end)
    end
    for _, fn in ipairs(Cleanups) do
        pcall(fn)
    end
    pcall(applyFullbright, false)
    pcall(restoreWalkSpeed)
    pcall(restoreJumpPower)
    pcall(restoreNoClip)
    pcall(restoreFly)
    pcall(function() ESPFolder:Destroy() end)
    pcall(function()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end)
    getgenv().XLunaSHOW_Window = nil
    getgenv().XLunaSHOW_State = nil
    getgenv().XLunaSHOW_Elements = nil
    getgenv().XLunaSHOW_Actions = nil
    getgenv().XLunaSHOW_Unload = nil
end

getgenv().XLunaSHOW_Window = Window
getgenv().XLunaSHOW_State = State
getgenv().XLunaSHOW_Elements = UI_Elements
getgenv().XLunaSHOW_Actions = {
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,
    ResetAllToOff = resetAllToOff,
    ScanGarages = updateGarageRankingCard,
    ClaimProgression = claimAllProgressionNow,
    LootWonItems = lootAllWonItemsNow,
    UnloadVehicle = unloadVehicleItems,
    StockShelves = runRemoteAutoStock,
    SellPawn = sellToPawnShopNow,
    InstallBidHook = installBidBarPerfectHook,
    GetAuctionHUD = getLiveBiddingHUDState,
    GetAutoPlayRuntime = function() return AutoPlayRuntime end,
    GetAuctionRuntime = function() return AuctionRuntime end,
}

notify("XLunaHUB", "Storage Hunters: Open World loaded (ALL OFF). Toggle with LeftControl or Floating Button.", 3.5)
