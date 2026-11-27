-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    XLunaHUB â Anime Nexus RNG : Eminence in Shadow (Full v2)
    Author: By XLunaHUB
    UI Framework: WindUI
    Note: Every automation toggle defaults strictly to false (OFF) on load.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Clean teardown of any previous running instance
pcall(function()
    if getgenv and type(getgenv().XLunaHUB_Cleanup) == "function" then
        getgenv().XLunaHUB_Cleanup()
    end
end)

local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    VirtualUser = game:GetService("VirtualUser"),
    HttpService = game:GetService("HttpService"),
    TeleportService = game:GetService("TeleportService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace"),
}

local LP = Services.Players.LocalPlayer
local RS = Services.ReplicatedStorage
local RemotesFolder = RS:WaitForChild("Remotes", 20)

local Alive = true
local Connections = {}

local function RestoreIdentity()
    if setthreadidentity then
        pcall(setthreadidentity, 8)
    end
end

local function SafeRequire(mod)
    if not mod or not mod:IsA("ModuleScript") then
        return nil
    end
    local ok, res = pcall(require, mod)
    RestoreIdentity()
    if ok then
        return res
    end
    return nil
end

local function GetClientCache()
    local ps = LP:FindFirstChild("PlayerScripts")
    local ccMod = ps and ps:FindFirstChild("ClientCache")
    if ccMod then
        local cc = SafeRequire(ccMod)
        if type(cc) == "table" and cc.Cache then
            return cc.Cache
        end
    end
    return nil
end

local function GetPlayerData()
    local cc = GetClientCache()
    if cc and cc.ReplicaHandler and cc.ReplicaHandler.RequestPlayerData then
        local ok, pdata = pcall(function()
            return cc.ReplicaHandler:RequestPlayerData(LP)
        end)
        RestoreIdentity()
        if ok and type(pdata) == "table" then
            return pdata
        end
    end
    return nil
end

local function GetNWState()
    local okEnv, env = pcall(function()
        return getrenv and getrenv()._G
    end)
    local envG = (okEnv and type(env) == "table" and env) or _G
    if type(envG) == "table" and type(envG.P2_NWState) == "table" then
        return envG.P2_NWState, envG
    end
    return nil, envG
end

local function GetDataModule(name)
    local modules = RS:FindFirstChild("Modules")
    local shared = modules and modules:FindFirstChild("Shared")
    local data = shared and shared:FindFirstChild("Data")
    local mod = data and data:FindFirstChild(name)
    if not mod and modules then
        for _, desc in ipairs(modules:GetDescendants()) do
            if desc:IsA("ModuleScript") and desc.Name == name then
                mod = desc
                break
            end
        end
    end
    return SafeRequire(mod)
end

local function GetRemote(name)
    if not RemotesFolder or not RemotesFolder.Parent then
        RemotesFolder = RS:FindFirstChild("Remotes")
    end
    return RemotesFolder and RemotesFolder:FindFirstChild(name)
end

local function GetUnitAction()
    local char = LP.Character
    local handler = char and char:FindFirstChild("CharacterHandler")
    local remotes = handler and handler:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("UnitAction")
end

-- Safe timeout wrapper so Lobby-only RemoteFunctions never hang execution in matches
local function TimedInvoke(remote, timeoutSec, ...)
    if not remote or not remote:IsA("RemoteFunction") then
        return false, "Remote unavailable"
    end
    local args = table.pack(...)
    local done, ok, res = false, false, nil
    task.spawn(function()
        ok, res = pcall(function()
            return remote:InvokeServer(table.unpack(args, 1, args.n))
        end)
        done = true
    end)
    local t0 = os.clock()
    local limit = timeoutSec or 3.0
    while not done and Alive and (os.clock() - t0) < limit do
        task.wait(0.05)
    end
    if not done then
        return false, "Server timeout (Lobby-only or busy)"
    end
    return ok, res
end

-- Master Runtime State (ALL booleans strictly false on startup)
local State = {
    -- Match & Combat
    AutoPlace = false,
    PlacementMode = "Spread Around Nexus",
    PlaceInterval = 0.6,
    PlaceFarmsFirst = true,
    AutoUpgrade = false,
    UpgradeStrategy = "Cheapest First",
    MaxUpgradeLevel = 15,
    YenReserve = 0,
    AutoActiveSkills = false,
    AutoPriority = false,
    TargetPriority = "Bosses",
    AutoCardPick = false,
    AutoShinjukuPick = false,
    ShinjukuSide = "Gojo",
    AutoSkipWave = false,
    AutoGameSpeed = false,
    TargetGameSpeed = "2",
    AutoNextStage = false,
    AutoReplay = false,
    AutoLobby = false,
    SelectedWorld = "HiddenGround",
    SelectedAct = "1",
    SelectedDiff = "Normal",
    SelectedMode = "Story",
    HauntedTowerFloor = 1,

    -- Summon & Units
    AutoRoll = false,
    RollBannerType = "Normal Roll",
    FastRoll = false,
    MultiRoll = false,
    RollInterval = 0.35,
    AutoSellRare = false,
    AutoSellEpic = false,
    AutoSellLegendary = false,
    AutoSellMythic = false,
    AutoTraitReroll = false,
    TraitUnitTarget = "",
    TargetTraits = {},
    TraitMaxRolls = 25,
    AutoStatReroll = false,
    StatUnitTarget = "",
    StatRerollMode = "All Stats (SuperStatChip)",
    AutoOpenCapsules = false,
    SelectedPotion = "LuckPotion",

    -- Relics, Tech & Upgrades
    AutoCosmicTech = false,
    AutoGilTreasury = false,
    AutoSkillHunter = false,
    SelectedRelicTarget = "",
    RelicLock1 = false,
    RelicLock2 = false,
    RelicLock3 = false,
    AutoRebirth = false,
    AutoBuyUpgrades = false,
    SelectedCraftKey = "StatChip",
    CraftQuantity = 1,

    -- Shops & Exchange
    SelectedShopSource = "RaidShop",
    SelectedShopItem = "",
    AutoGoldShop = false,
    AutoGemShop = false,
    ExchangeSource = "QuincyMedal",
    ExchangePack = "1",

    -- Farm & Events
    AutoExploration = false,
    ExploreDuration = "Short",
    ExploreDanger = "Normal",
    AutoClaimHwPortals = false,
    AutoBuyHwTree = false,
    AutoWishFountain = false,
    WishCoin = "Bronze",
    WishServant = "Saber",
    AutoGraveBonk = false,
    AutoHwGhosts = false,
    AutoGurrenMine = false,
    AutoSoulDodge = false,

    -- Rewards, Mail & Quests
    AutoClaimRewards = false,
    AutoClaimMail = false,

    -- Teleport & Misc
    SelectedWarp = "Story",
    AntiAFK = false,
    BlockAfkTeleport = false,
    LowGFX = false,

    -- Internal counters
    RollReqId = 1,
}

-- Game Data Lookups
local StageData = GetDataModule("StageData") or {}
local WorldOrderData = GetDataModule("NWWorldOrder") or {}
local TraitsData = GetDataModule("TraitsData") or {}
local PotionsData = GetDataModule("NWPotions") or {}
local WarpConfigData = GetDataModule("NWWarpConfig") or {}
local WishData = GetDataModule("NWWishFountain") or {}
local _, initialEnvG = GetNWState()
local ExplorationData = (initialEnvG and type(initialEnvG.NW_ExploreDataMod) == "table" and initialEnvG.NW_ExploreDataMod)
    or GetDataModule("ExplorationData")
    or GetDataModule("NWExploration")
    or {}

local function BuildWorldOptions()
    local list, seen = {}, {}
    if type(WorldOrderData.Order) == "table" then
        for _, key in ipairs(WorldOrderData.Order) do
            if not seen[key] then
                seen[key] = true
                table.insert(list, key)
            end
        end
    end
    for k, _ in pairs(StageData) do
        if type(k) == "string" and not seen[k] then
            seen[k] = true
            table.insert(list, k)
        end
    end
    if #list == 0 then
        table.insert(list, "HiddenGround")
    end
    return list
end

local function BuildTraitOptions()
    local list = {}
    for k, v in pairs(TraitsData) do
        if type(k) == "string" and type(v) == "table" then
            table.insert(list, k)
        end
    end
    table.sort(list)
    if #list == 0 then
        list = { "Celestial", "Divine", "Golden", "Reaper", "Unique" }
    end
    return list
end

local function BuildPotionOptions()
    local list = {}
    if type(PotionsData.LIST) == "table" then
        for _, p in ipairs(PotionsData.LIST) do
            if type(p) == "table" and p.key then
                table.insert(list, p.key)
            end
        end
    end
    if #list == 0 then
        list = { "LuckPotion", "GreaterLuckPotion", "SuperLuckPotion", "UltraLuckPotion", "SpeedPotion" }
    end
    return list
end

local function BuildWarpOptions()
    local list, seen = {}, {}
    for k, v in pairs(WarpConfigData) do
        if type(k) == "number" and type(v) == "table" and v.key and not seen[v.key] then
            seen[v.key] = true
            table.insert(list, v.key)
        end
    end
    table.sort(list)
    if #list == 0 then
        list = { "Story", "HwIsland", "HauntedTower", "Explore", "Craft", "Evolution", "Codes" }
    end
    return list
end

local function BuildWishCoinOptions()
    local list = {}
    if type(WishData.COINS) == "table" then
        for _, c in ipairs(WishData.COINS) do
            if type(c) == "table" and c.id then
                table.insert(list, c.id)
            end
        end
    end
    if #list == 0 then
        list = { "Bronze", "Silver", "Gold", "Clover", "Star", "Gamble" }
    end
    return list
end

local function BuildWishServantOptions()
    local list = {}
    if type(WishData.SERVANTS) == "table" then
        for _, s in ipairs(WishData.SERVANTS) do
            if type(s) == "table" and s.key then
                table.insert(list, s.key)
            end
        end
    end
    if #list == 0 then
        list = { "Saber", "Jeanne", "Ishtar" }
    end
    return list
end

local function BuildCraftOptions()
    local nw = GetNWState()
    local list = {}
    if nw and type(nw.Craft) == "table" then
        for _, c in ipairs(nw.Craft) do
            if type(c) == "table" and c.key then
                table.insert(list, c.key)
            end
        end
    end
    if #list == 0 then
        list = { "StatChip", "TraitRerolls", "LuckPotion", "SuperStatChip", "GreaterLuckPotion" }
    end
    return list
end

local function GetUnitOptions()
    local pdata = GetPlayerData()
    local options, mapLabelToUuid = {}, {}
    if pdata and pdata.Inventory and type(pdata.Inventory.Units) == "table" then
        local equippedSet = {}
        if type(pdata.EquippedUnits) == "table" then
            for _, uid in pairs(pdata.EquippedUnits) do
                if uid then equippedSet[uid] = true end
            end
        end
        for uuid, u in pairs(pdata.Inventory.Units) do
            if type(u) == "table" then
                local prefix = equippedSet[uuid] and "[EQ] " or ""
                local traitStr = (u.Trait and u.Trait ~= "") and (" (" .. tostring(u.Trait) .. ")") or ""
                local label = string.format("%s%s Lv%d%s [%s]", prefix, tostring(u.Name or "Unit"), tonumber(u.Level) or 1, traitStr, string.sub(tostring(uuid), 1, 6))
                table.insert(options, label)
                mapLabelToUuid[label] = uuid
            end
        end
        table.sort(options, function(a, b)
            local aEq = string.sub(a, 1, 4) == "[EQ]"
            local bEq = string.sub(b, 1, 4) == "[EQ]"
            if aEq ~= bEq then return aEq end
            return a < b
        end)
    end
    if #options == 0 then
        table.insert(options, "No Units Found")
    end
    return options, mapLabelToUuid
end

local function GetRelicOptions()
    local pdata = GetPlayerData()
    local options, mapLabelToId = {}, {}
    if pdata and pdata.Inventory and type(pdata.Inventory.Relics) == "table" then
        for id, rel in pairs(pdata.Inventory.Relics) do
            if type(rel) == "table" then
                local rName = tostring(rel.Name or rel.name or rel.key or id)
                local label = string.format("%s [%s]", rName, string.sub(tostring(id), 1, 8))
                table.insert(options, label)
                mapLabelToId[label] = rel.id or id
            end
        end
        table.sort(options)
    end
    if #options == 0 then
        table.insert(options, "No Relics Owned")
    end
    return options, mapLabelToId
end

local function BuildExchangeSources()
    local exCfg = GetDataModule("NWExchangeConfig")
    local list = {}
    if type(exCfg) == "table" and type(exCfg.SOURCES) == "table" then
        for _, src in ipairs(exCfg.SOURCES) do
            if type(src) == "table" and src.id then
                table.insert(list, src.id)
            end
        end
    end
    if #list == 0 then
        list = { "QuincyMedal", "HollowFragment", "PriestellaCoin", "ShadowCoin", "SBRMedal", "UAToken", "WitchToken" }
    end
    return list
end

local function GetShopItemsForSource(shopKey)
    local nw = GetNWState()
    local labels, mapLabelToKey = {}, {}
    if shopKey == "StandardShop" then
        if nw and type(nw.Shop) == "table" then
            for k, item in pairs(nw.Shop) do
                if type(item) == "table" then
                    local itemName = type(item.item) == "table" and (tostring(item.item[1]) .. " x" .. tostring(item.item[2] or 1)) or tostring(k)
                    local costStr = item.cost and (" | Cost: " .. tostring(item.cost)) or ""
                    local lbl = string.format("%s (%s)%s", itemName, tostring(k), costStr)
                    table.insert(labels, lbl)
                    mapLabelToKey[lbl] = tostring(k)
                end
            end
            table.sort(labels)
        end
    elseif nw and type(nw[shopKey]) == "table" then
        for _, item in ipairs(nw[shopKey]) do
            if type(item) == "table" and item.key then
                local costStr = item.cost and (" | Cost: " .. tostring(item.cost)) or ""
                local stockStr = item.stock and (" | Stock: " .. tostring(item.stock)) or ""
                local lbl = string.format("%s (%s)%s%s", tostring(item.name or item.key), tostring(item.key), costStr, stockStr)
                table.insert(labels, lbl)
                mapLabelToKey[lbl] = item.key
            end
        end
    end
    if #labels == 0 then
        table.insert(labels, "No Items Loaded")
    end
    return labels, mapLabelToKey
end

-- Load WindUI
RestoreIdentity()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "XLunaHUB | Anime Nexus RNG",
    Icon = "sparkles",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_AnimeNexusRNG",
    Size = UDim2.fromOffset(660, 520),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.LeftControl,
    OpenButton = {
        Title = "XLunaHUB",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("6E45E2"), Color3.fromHex("88D3CE")),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
        Position = UDim2.new(0.5, 0, 0, 76),
    },
})

local function ApplyWindUIDisplayOrder()
    RestoreIdentity()
    local orderMap = {
        ["WindUI"] = 10,
        ["WindUI/Notifications"] = 20,
        ["WindUI/Dropdowns"] = 30,
        ["WindUI/Tooltips"] = 40,
    }
    local roots = {}
    pcall(function() table.insert(roots, Services.CoreGui) end)
    pcall(function()
        local rg = Services.CoreGui:FindFirstChild("RobloxGui")
        if rg then table.insert(roots, rg) end
    end)
    pcall(function() table.insert(roots, LP:FindFirstChild("PlayerGui")) end)
    pcall(function()
        if gethui then table.insert(roots, gethui()) end
    end)
    for _, root in ipairs(roots) do
        if typeof(root) == "Instance" then
            for _, child in ipairs(root:GetChildren()) do
                if child:IsA("ScreenGui") and orderMap[child.Name] then
                    child.DisplayOrder = orderMap[child.Name]
                    child.IgnoreGuiInset = true
                end
            end
        end
    end
end
task.defer(ApplyWindUIDisplayOrder)
task.delay(1, ApplyWindUIDisplayOrder)

local function Notify(title, content, duration)
    pcall(function()
        RestoreIdentity()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
        })
    end)
end

-- Core Gameplay & Automation Implementations --

local function GetMyPlacedUnits()
    local list, seen = {}, {}
    local function consider(m)
        if typeof(m) == "Instance" and m:IsA("Model") and not seen[m] and m:GetAttribute("Type") == "Unit" then
            local uid = m:GetAttribute("UserId")
            local owner = m:GetAttribute("Owner")
            local isMine = false
            if uid ~= nil then
                isMine = (tonumber(uid) == LP.UserId)
            elseif owner ~= nil then
                isMine = (tostring(owner) == LP.Name)
            end
            if isMine then
                seen[m] = true
                table.insert(list, m)
            end
        end
    end
    local entities = Services.Workspace:FindFirstChild("Entities")
    if entities then
        for _, m in ipairs(entities:GetChildren()) do
            consider(m)
        end
    end
    local cc = GetClientCache()
    if cc and cc.UnitHandler and type(cc.UnitHandler.Profiles) == "table" then
        for k, _ in pairs(cc.UnitHandler.Profiles) do
            consider(k)
        end
    end
    return list
end

local function GetBaseAnchor()
    local baseIdx = LP:GetAttribute("NWBaseIndex")
    local nwBases = RS:FindFirstChild("NW_Bases")
    if nwBases and baseIdx then
        local bVal = nwBases:FindFirstChild("Base" .. tostring(baseIdx))
        if bVal and bVal.Value and bVal.Value:IsA("BasePart") then
            return bVal.Value
        end
    end
    local curNexus = RS:FindFirstChild("CurrentNexus")
    if curNexus and curNexus.Value and curNexus.Value:IsA("BasePart") then
        return curNexus.Value
    end
    local nexusFolder = Services.Workspace:FindFirstChild("Nexus")
    if nexusFolder then
        for _, d in ipairs(nexusFolder:GetDescendants()) do
            if d:IsA("BasePart") then
                return d
            end
        end
    end
    return nil
end

local function ComputeSmartPlacementPos()
    if State.PlacementMode == "Server Auto" then
        return "server"
    end
    local anchor = GetBaseAnchor()
    if not anchor then
        return "server"
    end
    local cc = GetClientCache()
    local rayFn = cc and cc.Util and cc.Util.UnitTowerRaycast
    if type(rayFn) ~= "function" then
        return "server"
    end

    local pos = anchor.Position
    local minRad = math.max((anchor.Size.X / 2) + 2.5, 6)
    local maxRad = State.PlacementMode == "Tight Ring Near Nexus" and 24 or 55

    local placedPositions = {}
    local entities = Services.Workspace:FindFirstChild("Entities")
    if entities then
        for _, m in ipairs(entities:GetChildren()) do
            if m:GetAttribute("Type") == "Unit" then
                local tp = m:GetAttribute("TowerPosition")
                if typeof(tp) ~= "Vector3" then
                    local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    tp = hrp and hrp.Position
                end
                if typeof(tp) == "Vector3" then
                    table.insert(placedPositions, Vector2.new(tp.X, tp.Z))
                end
            end
        end
    end

    for attempt = 1, 60 do
        local angle = (attempt / 12) * math.pi * 2 + math.random() * 0.45
        local radius = minRad + math.random() * (maxRad - minRad)
        local x = pos.X + math.cos(angle) * radius
        local z = pos.Z + math.sin(angle) * radius
        local okRay, rayHit = pcall(rayFn, Vector3.new(x, pos.Y + 90, z), Vector3.new(0, -180, 0))
        if okRay and rayHit and rayHit.Position then
            local p2 = Vector2.new(rayHit.Position.X, rayHit.Position.Z)
            local free = true
            local minSpacing = attempt > 40 and 4.8 or 6.2
            for _, other in ipairs(placedPositions) do
                if (other - p2).Magnitude < minSpacing then
                    free = false
                    break
                end
            end
            if free then
                return rayHit.Position
            end
        end
    end
    return "server"
end

local function RunSmartAutoPlace()
    if LP:GetAttribute("NWLive") ~= true and LP:GetAttribute("NWGameActive") ~= true then
        return
    end
    local unitAction = GetUnitAction()
    if not unitAction then return end
    local pdata = GetPlayerData()
    if not pdata or not pdata.EquippedUnits or not pdata.Inventory or not pdata.Inventory.Units then
        return
    end
    local cc = GetClientCache()
    local unitDataTbl = (cc and cc.UnitData) or GetDataModule("UnitData") or {}

    local trackerRaw = LP:GetAttribute("UnitPlacementTracker")
    local placedCounts = {}
    if type(trackerRaw) == "string" and trackerRaw ~= "" then
        local okDec, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, trackerRaw)
        if okDec and type(decoded) == "table" then
            placedCounts = decoded
        end
    end

    local gameCfg = RS:FindFirstChild("GameConfig")
    local allowedVal = gameCfg and gameCfg:FindFirstChild("AllowedUnits")
    local allowedAnime = allowedVal and allowedVal.Value or ""
    local _, envG = GetNWState()

    local candidates = {}
    for _, uuid in pairs(pdata.EquippedUnits) do
        if uuid and uuid ~= false then
            local inst = pdata.Inventory.Units[uuid]
            if inst and inst.Name then
                local base = unitDataTbl[inst.Name]
                if base then
                    local isAllowed = (base.AnimeName or "None") == allowedAnime or allowedAnime == "" or base.Farm == true
                    if isAllowed then
                        local maxPlace = math.min(base.MaxPlacements or 1, base.NWPlaceCapExempt and 99 or 3)
                        if envG and type(envG.P2_MaxPlaceFor) == "function" then
                            local okM, mVal = pcall(envG.P2_MaxPlaceFor, inst, base)
                            if okM and type(mVal) == "number" then maxPlace = mVal end
                        end
                        if (placedCounts[inst.Name] or 0) < maxPlace then
                            local cdLeft = 0
                            if envG and type(envG.NW_PlaceCDLeft) == "function" then
                                local okCd, cd = pcall(envG.NW_PlaceCDLeft, uuid)
                                if okCd and type(cd) == "number" then cdLeft = cd end
                            end
                            if cdLeft <= 0 then
                                local costMult = 1
                                if envG and type(envG.P2_PlaceCostMult) == "function" then
                                    local okC, cVal = pcall(envG.P2_PlaceCostMult, inst)
                                    if okC and type(cVal) == "number" then costMult = cVal end
                                end
                                local cost = ((base.BaseStats and base.BaseStats.Cost) or 0) * costMult
                                local score = 0
                                if envG and type(envG.P2_AutoScore) == "function" then
                                    local okS, sVal = pcall(envG.P2_AutoScore, inst)
                                    if okS and type(sVal) == "number" then score = sVal end
                                end
                                table.insert(candidates, {
                                    uuid = uuid,
                                    cost = cost,
                                    isFarm = base.Farm == true,
                                    score = score,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if State.PlaceFarmsFirst and a.isFarm ~= b.isFarm then
            return a.isFarm
        end
        return a.score > b.score
    end)

    local yen = tonumber(LP:GetAttribute("Yen")) or 0
    for _, cand in ipairs(candidates) do
        if yen >= cand.cost then
            local pos = ComputeSmartPlacementPos()
            -- Pass 4 args (no "auto" flag) so placement works independently of group gate
            unitAction:FireServer("Place", cand.uuid, pos, 0)
            break
        end
    end
end

local function RunSmartAutoUpgrade()
    local unitAction = GetUnitAction()
    if not unitAction then return end
    local yen = tonumber(LP:GetAttribute("Yen")) or 0
    if yen <= State.YenReserve then return end
    local cc = GetClientCache()
    local unitDataTbl = (cc and cc.UnitData) or GetDataModule("UnitData") or {}

    local upgradables = {}
    for _, m in ipairs(GetMyPlacedUnits()) do
        local isMax = m:GetAttribute("MaxUpgrade") == true
        local curUpg = tonumber(m:GetAttribute("Upgrades")) or 0
        local cost = tonumber(m:GetAttribute("UpgradeCost"))
        if not isMax and curUpg < State.MaxUpgradeLevel and cost and (yen - cost) >= State.YenReserve then
            local baseName = m:GetAttribute("Unit") or m.Name
            local base = unitDataTbl[baseName]
            table.insert(upgradables, {
                model = m,
                cost = cost,
                isFarm = base and base.Farm == true,
                dps = tonumber(m:GetAttribute("Damage")) or 0,
            })
        end
    end
    if #upgradables == 0 then return end

    table.sort(upgradables, function(a, b)
        if State.UpgradeStrategy == "Farms First" and a.isFarm ~= b.isFarm then
            return a.isFarm
        elseif State.UpgradeStrategy == "Highest DPS First" and a.dps ~= b.dps then
            return a.dps > b.dps
        end
        return a.cost < b.cost
    end)

    unitAction:FireServer("Upgrade", upgradables[1].model)
end

local function RunAutoActiveSkills()
    if LP:GetAttribute("NWLive") ~= true and LP:GetAttribute("NWGameActive") ~= true then
        return
    end
    local unitAction = GetUnitAction()
    if not unitAction then return end
    local cc = GetClientCache()
    local unitDataTbl = (cc and cc.UnitData) or GetDataModule("UnitData") or {}
    local cdMod = cc and cc.UIHandler and cc.UIHandler.ActiveSkillCooldowns

    for _, m in ipairs(GetMyPlacedUnits()) do
        local uName = tostring(m:GetAttribute("Unit") or m.Name)
        local base = unitDataTbl[uName]
        local upg = tonumber(m:GetAttribute("Upgrades")) or 0
        local guid = m:GetAttribute("GUID") or m:GetAttribute("Guid") or tostring(m:GetDebugId())
        local firedFromData = false
        if base and type(base.ActiveSkills) == "table" and #base.ActiveSkills > 0 then
            firedFromData = true
            for idx, skill in ipairs(base.ActiveSkills) do
                if type(skill) == "table" and not skill.PlacementSkill then
                    local reqLvl = tonumber(skill.Level) or 0
                    if upg >= reqLvl then
                        local onCd = false
                        if cdMod and type(cdMod.GetCD) == "function" then
                            local okCd, cdLeft = pcall(cdMod.GetCD, guid, idx)
                            if okCd and type(cdLeft) == "number" and cdLeft > 0 then
                                onCd = true
                            end
                        end
                        if not onCd then
                            unitAction:FireServer("Active", m, tostring(idx))
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        if not firedFromData then
            local skillsRaw = m:GetAttribute("SkillsInfo")
            if type(skillsRaw) == "string" and skillsRaw ~= "" then
                local okDec, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, skillsRaw)
                if okDec and type(decoded) == "table" then
                    firedFromData = true
                    for idx, s in ipairs(decoded) do
                        if type(s) == "table" and upg >= (tonumber(s.req) or 0) then
                            unitAction:FireServer("Active", m, tostring(idx))
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        if not firedFromData and upg >= 1 then
            unitAction:FireServer("Active", m, "1")
        end
    end
end

local function RunAutoPriority()
    local unitAction = GetUnitAction()
    if not unitAction then return end
    for _, m in ipairs(GetMyPlacedUnits()) do
        if tostring(m:GetAttribute("Priority") or "Closest") ~= State.TargetPriority then
            unitAction:FireServer("Priority", m, State.TargetPriority)
            task.wait(0.04)
        end
    end
end

local function RedeemAllWikiCodes()
    local wikiRemote = GetRemote("NWWikiCodes")
    local redeemRemote = GetRemote("RedeemCode")
    local resRemote = GetRemote("RedeemCodeResult")
    if not wikiRemote or not redeemRemote then
        Notify("Codes Error", "Code remotes are not ready.", 3)
        return
    end
    local ok, res = TimedInvoke(wikiRemote, 4.0)
    if not ok or type(res) ~= "table" or type(res.codes) ~= "table" then
        Notify("Codes Error", "Failed to fetch live codes from server.", 3)
        return
    end
    local okCnt, failCnt, lastMsg = 0, 0, nil
    local conn = resRemote and resRemote:IsA("RemoteEvent") and resRemote.OnClientEvent:Connect(function(success, msg)
        if success then
            okCnt = okCnt + 1
        else
            failCnt = failCnt + 1
            if type(msg) == "string" and msg ~= "" then lastMsg = msg end
        end
    end)
    local submitted = 0
    for _, entry in ipairs(res.codes) do
        if type(entry) == "table" and entry.code and not entry.used and entry.expired ~= true then
            redeemRemote:FireServer(entry.code)
            submitted = submitted + 1
            task.wait(0.25)
        end
    end
    task.wait(0.4)
    if conn then conn:Disconnect() end
    if submitted == 0 then
        Notify("Codes", "All active wiki codes are already redeemed.", 3)
    elseif failCnt > 0 and okCnt == 0 then
        Notify("Codes Rejected", lastMsg or ("Server rejected all " .. tostring(submitted) .. " codes."), 4)
    else
        Notify("Codes Result", string.format("Submitted: %d | Accepted: %d | Rejected: %d%s", submitted, okCnt, failCnt, lastMsg and (" (" .. lastMsg .. ")") or ""), 4)
    end
end

local function ClaimAllMailRewards()
    local mailRem = GetRemote("NWMail")
    if not mailRem then return false, "NWMail unavailable" end
    local okGet, box = TimedInvoke(mailRem, 3.0, "Get")
    if not okGet or type(box) ~= "table" then
        return false, "Mail unavailable here"
    end
    local okClaim, res = TimedInvoke(mailRem, 3.0, "ClaimAll", nil)
    return okClaim and type(res) == "table", res
end

local lastSlowRewardClaimAt = 0

local function ClaimAllAvailableRewards(fromLoop)
    local nwAction = GetRemote("NWAction")
    local lvlRemote = GetRemote("NWLevelRewards")
    local bp4Remote = GetRemote("NWBattlePass4")
    local hwPassRemote = GetRemote("NWHwPass")
    local hwBoardRemote = GetRemote("NWHwQuestBoard")
    local now = os.clock()
    local doSlow = (not fromLoop) or (now - lastSlowRewardClaimAt >= 20)
    if doSlow then lastSlowRewardClaimAt = now end

    if nwAction then
        nwAction:FireServer({ type = "Sync" })
        task.wait(0.1)
        local nw, envG = GetNWState()
        if nw then
            if type(nw.Playtime) == "table" then
                for i, slot in ipairs(nw.Playtime) do
                    if type(slot) == "table" and slot.ready and not slot.claimed then
                        nwAction:FireServer({ type = "ClaimPlaytime", idx = i })
                        task.wait(0.06)
                    end
                end
            end
            if nw.CanClaimDaily == true then
                nwAction:FireServer({ type = "ClaimDaily" })
                task.wait(0.06)
            end
            if type(nw.Battlepass) == "table" and nw.Battlepass.hasClaimable then
                nwAction:FireServer({ type = "ClaimBPAll" })
                task.wait(0.06)
            end
            if type(nw.Quests) == "table" then
                for _, q in ipairs(nw.Quests) do
                    if type(q) == "table" and q.id and not q.claimed and (tonumber(q.progress) or 0) >= (tonumber(q.goal) or 1) then
                        nwAction:FireServer({ type = "ClaimQuest", id = q.id })
                        task.wait(0.06)
                    end
                end
            end
            if type(nw.BPQuests) == "table" then
                for _, q in ipairs(nw.BPQuests) do
                    if type(q) == "table" and q.id and not q.claimed and (tonumber(q.progress) or 0) >= (tonumber(q.goal) or 1) then
                        nwAction:FireServer({ type = "ClaimQuest", id = q.id })
                        task.wait(0.06)
                    end
                end
            end
            if doSlow and type(nw.RaidQuests) == "table" and #nw.RaidQuests > 0 then
                nwAction:FireServer({ type = "ClaimRaidQuest", all = true })
                task.wait(0.06)
            end
            if nw.StayReady == true then
                nwAction:FireServer({ type = "StayReward" })
                task.wait(0.06)
            end
        end

        if doSlow then
            nwAction:FireServer({ type = "UnitIndex", op = "ClaimAll" })
            -- Only claim special NPC questlines that were actually started (prevents screen spam)
            local charQuests = {
                { t = "EnkiduQuest", g = "P2_EnkiduQuestState" },
                { t = "FamiliarQuest", g = "P2_FamiliarQuestState" },
                { t = "FrierenQuest", g = "P2_FrierenQuestState" },
                { t = "GokunaQuest", g = "P2_GokunaQuestState" },
                { t = "JohnnyQuest", g = "P2_JohnnyQuestState" },
                { t = "MadaraQuest", g = "P2_MadaraQuestState" },
                { t = "WhitebeardQuest", g = "P2_WhitebeardQuestState" },
            }
            for _, cq in ipairs(charQuests) do
                local st = envG and envG[cq.g]
                local active = type(st) == "table" and (st.Started == true or st.Accepted == true or (tonumber(st.Step) or 0) > 1) and st.Retired ~= true
                if active then
                    nwAction:FireServer({ type = cq.t, op = "Claim" })
                    task.wait(0.05)
                end
            end
        end
        if not fromLoop then
            nwAction:FireServer({ type = "GurrenQuests", op = "ClaimAllN" })
            nwAction:FireServer({ type = "Tower", op = "ClaimAll", npc = true })
        end
    end

    if lvlRemote and LP:GetAttribute("NWLevelRewardReady") == true then
        lvlRemote:FireServer({ op = "ClaimAll" })
    end
    if doSlow and bp4Remote then
        bp4Remote:FireServer("claimall")
    end
    if doSlow and hwPassRemote then
        hwPassRemote:FireServer("claimall")
    end
    if doSlow and hwBoardRemote then
        hwBoardRemote:FireServer("claimall")
    end
end

local function OpenAllCapsules()
    local pdata = GetPlayerData()
    local useItem = GetRemote("UseItem")
    if not pdata or not useItem or not pdata.Inventory or type(pdata.Inventory.Items) ~= "table" then
        return 0
    end
    local itemsData = GetDataModule("ItemsData") or {}
    local opened = 0
    for _, item in pairs(pdata.Inventory.Items) do
        if type(item) == "table" and (tonumber(item.Amount) or 0) > 0 and item.Id then
            local ref = tostring(item.BaseDataRef or item.Id)
            local info = itemsData[ref]
            local nameLower = string.lower(tostring(info and info.Name or ref))
            if string.find(nameLower, "capsule") then
                local qty = math.min(tonumber(item.Amount) or 1, 1000)
                useItem:FireServer(item.Id, qty)
                opened = opened + qty
                task.wait(0.2)
            end
        end
    end
    return opened
end

local function RunAutoExploration()
    local rem = GetRemote("NWExploration")
    if not rem then return end
    local okGet, resGet = TimedInvoke(rem, 3.0, { op = "Get" })
    if not okGet or type(resGet) ~= "table" then return end

    local state = type(resGet.state) == "table" and resGet.state or resGet
    local now = tonumber(state.now) or Services.Workspace:GetServerTimeNow()
    local islandsMap = type(state.islands) == "table" and state.islands or {}

    local anyReady = false
    for _, islData in pairs(islandsMap) do
        if type(islData) == "table" and type(islData.active) == "table" then
            local endsAt = tonumber(islData.active.ends) or math.huge
            if endsAt <= now then
                anyReady = true
                break
            end
        end
    end

    if anyReady then
        local okC, resC = TimedInvoke(rem, 3.0, { op = "ClaimAll" })
        if okC and type(resC) == "table" and type(resC.state) == "table" then
            state = resC.state
            islandsMap = type(state.islands) == "table" and state.islands or {}
            now = tonumber(state.now) or Services.Workspace:GetServerTimeNow()
        end
        task.wait(0.25)
    end

    local pdata = GetPlayerData()
    if not pdata or not pdata.Inventory or type(pdata.Inventory.Units) ~= "table" then return end

    local busyUnits, activeIslands = {}, {}
    for islKey, islData in pairs(islandsMap) do
        if type(islData) == "table" and type(islData.active) == "table" then
            activeIslands[islKey] = true
            if type(islData.active.units) == "table" then
                for _, uid in ipairs(islData.active.units) do
                    busyUnits[uid] = true
                end
            end
        end
    end

    local equippedSet = {}
    if type(pdata.EquippedUnits) == "table" then
        for _, uid in pairs(pdata.EquippedUnits) do
            if uid then equippedSet[uid] = true end
        end
    end

    local serverNow = Services.Workspace:GetServerTimeNow()
    local spare = {}
    for uuid, u in pairs(pdata.Inventory.Units) do
        if not equippedSet[uuid] and not busyUnits[uuid] and type(u) == "table" then
            local exh = tonumber(u.ExhaustedUntil) or 0
            if not u.Exploring and serverNow >= exh then
                table.insert(spare, { uuid = uuid, lvl = tonumber(u.Level) or 1 })
            end
        end
    end
    table.sort(spare, function(a, b) return a.lvl > b.lvl end)
    if #spare == 0 then return end

    local islands = (type(ExplorationData.ISLANDS) == "table" and ExplorationData.ISLANDS) or {}
    local idx = 1
    for _, isl in ipairs(islands) do
        if type(isl) == "table" and isl.key and not activeIslands[isl.key] then
            local squad = {}
            for _ = 1, 5 do
                if spare[idx] then
                    table.insert(squad, spare[idx].uuid)
                    idx = idx + 1
                end
            end
            if #squad > 0 then
                TimedInvoke(rem, 3.0, {
                    op = "Send",
                    island = isl.key,
                    dur = State.ExploreDuration,
                    units = squad,
                    danger = State.ExploreDanger,
                })
                task.wait(0.2)
            else
                break
            end
        end
    end
end

local function RunAutoWishOnce()
    local rem = GetRemote("NWWish")
    if not rem or type(WishData.BarPos) ~= "function" then
        return false, "Wish remote/module unavailable"
    end
    local okBegin, res = TimedInvoke(rem, 3.0, "begin", State.WishCoin, State.WishServant)
    if not okBegin or type(res) ~= "table" or not res.ok then
        return false, (type(res) == "table" and res.msg) or tostring(res)
    end
    local speed = tonumber(res.speed) or 1
    local phase = tonumber(res.phase) or 0

    local bestT, bestDist = 0.25, math.huge
    for stepT = 0.05, 3.0, 0.002 do
        local okPos, pos = pcall(WishData.BarPos, stepT, speed, phase)
        if okPos and type(pos) == "number" then
            local dist = math.abs(pos - 0.5)
            if dist < bestDist then
                bestDist = dist
                bestT = stepT
                if dist < 0.0015 then break end
            end
        end
    end

    task.wait(math.clamp(bestT, 0.05, 1.5))
    local okThrow, throwRes = TimedInvoke(rem, 3.0, "throw", bestT)
    return okThrow and type(throwRes) == "table" and throwRes.ok, throwRes
end

local function SweepLobbyCollectibles()
    if not fireproximityprompt then
        Notify("Unsupported", "Your executor does not support fireproximityprompt.", 3)
        return
    end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local origCF = hrp and hrp.CFrame
    local prompts = {}
    for _, fname in ipairs({ "NW_TYBWFinds", "NW_EnkiduTablets", "NW_BangNotes" }) do
        local f = Services.Workspace:FindFirstChild(fname)
        if f then
            for _, d in ipairs(f:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    table.insert(prompts, d)
                end
            end
        end
    end
    for _, parts in ipairs({
        { "NW_HalloweenIsland", "NW_CursedBlade" },
        { "NW_HalloweenIsland", "NW_HwClaimPumpkin" },
    }) do
        local cur = Services.Workspace
        for _, p in ipairs(parts) do cur = cur and cur:FindFirstChild(p) end
        if cur then
            for _, d in ipairs(cur:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    table.insert(prompts, d)
                end
            end
        end
    end

    local count = 0
    for _, prompt in ipairs(prompts) do
        if hrp and prompt.Parent and prompt.Parent:IsA("BasePart") then
            hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.08)
        end
        pcall(fireproximityprompt, prompt)
        count = count + 1
        task.wait(0.1)
    end
    if hrp and origCF then
        hrp.CFrame = origCF
    end
    Notify("Collectibles Sweep", string.format("Interacted with %d lobby collectibles.", count), 3)
end

-- Build WindUI Tabs & Controls --
local TabMatch = Window:Tab({ Title = "Match & Combat", Icon = "swords" })
local TabSummon = Window:Tab({ Title = "Summon & Units", Icon = "sparkles" })
local TabTech = Window:Tab({ Title = "Relics & Upgrades", Icon = "cpu" })
local TabShops = Window:Tab({ Title = "Shops & Exchange", Icon = "shopping-bag" })
local TabFarm = Window:Tab({ Title = "Farm & Events", Icon = "compass" })
local TabRewards = Window:Tab({ Title = "Rewards & Mail", Icon = "gift" })
local TabMisc = Window:Tab({ Title = "Teleport & Misc", Icon = "settings" })
local TabConfig = Window:Tab({ Title = "Config", Icon = "save" })

-- TAB 1: MATCH & COMBAT
local StatusPara = TabMatch:Paragraph({
    Title = "Live Player & Match Telemetry",
    Desc = "Loading telemetry...",
})

local SecCombat = TabMatch:Section({ Title = "Unit Placement & Combat Automation", Icon = "crosshair", Opened = true })

SecCombat:Toggle({
    Title = "Smart Auto Place Units",
    Desc = "Places equipped units cleanly with Nexus spacing (works without Group requirement)",
    Flag = "AutoPlace",
    Value = false,
    Callback = function(v) State.AutoPlace = v end,
})

SecCombat:Dropdown({
    Title = "Placement Pattern",
    Flag = "PlacementMode",
    Values = { "Spread Around Nexus", "Tight Ring Near Nexus", "Server Auto" },
    Value = "Spread Around Nexus",
    Callback = function(v) State.PlacementMode = v end,
})

SecCombat:Toggle({
    Title = "Prioritize Farm Units First",
    Flag = "PlaceFarmsFirst",
    Value = false,
    Callback = function(v) State.PlaceFarmsFirst = v end,
})

SecCombat:Slider({
    Title = "Place Check Interval (s)",
    Flag = "PlaceInterval",
    Step = 0.1,
    Value = { Min = 0.2, Max = 3.0, Default = 0.6 },
    Callback = function(v) State.PlaceInterval = v end,
})

SecCombat:Toggle({
    Title = "Smart Auto Upgrade Units",
    Flag = "AutoUpgrade",
    Value = false,
    Callback = function(v) State.AutoUpgrade = v end,
})

SecCombat:Dropdown({
    Title = "Upgrade Priority",
    Flag = "UpgradeStrategy",
    Values = { "Cheapest First", "Highest DPS First", "Farms First" },
    Value = "Cheapest First",
    Callback = function(v) State.UpgradeStrategy = v end,
})

SecCombat:Slider({
    Title = "Max Upgrade Level Cap",
    Flag = "MaxUpgradeLevel",
    Step = 1,
    Value = { Min = 1, Max = 15, Default = 15 },
    Callback = function(v) State.MaxUpgradeLevel = v end,
})

SecCombat:Slider({
    Title = "Minimum Yen Reserve",
    Flag = "YenReserve",
    Step = 250,
    Value = { Min = 0, Max = 20000, Default = 0 },
    Callback = function(v) State.YenReserve = v end,
})

SecCombat:Toggle({
    Title = "Auto Active Skills",
    Flag = "AutoActiveSkills",
    Value = false,
    Callback = function(v) State.AutoActiveSkills = v end,
})

SecCombat:Toggle({
    Title = "Auto Apply Target Priority",
    Flag = "AutoPriority",
    Value = false,
    Callback = function(v) State.AutoPriority = v end,
})

SecCombat:Dropdown({
    Title = "Target Priority Mode",
    Flag = "TargetPriority",
    Values = { "Closest", "First", "Last", "Strongest", "Weakest", "Bosses" },
    Value = "Bosses",
    Callback = function(v) State.TargetPriority = v end,
})

local SecStageFlow = TabMatch:Section({ Title = "Waves, Speed, Cards & Stage Loop", Icon = "fast-forward", Opened = true })

SecStageFlow:Toggle({
    Title = "Auto Card Priority Pick (Rogue / Portals)",
    Flag = "AutoCardPick",
    Value = false,
    Callback = function(v)
        State.AutoCardPick = v
        local r = GetRemote("NWRogue")
        if r then r:FireServer({ op = "Auto", on = v }) end
        local cs = GetRemote("ChangeSetting")
        if cs then cs:FireServer("AutoCards", v) end
    end,
})

SecStageFlow:Toggle({
    Title = "Auto Shinjuku Pick (Gojo / Sukuna)",
    Flag = "AutoShinjukuPick",
    Value = false,
    Callback = function(v)
        State.AutoShinjukuPick = v
        local nwA = GetRemote("NWAction")
        if nwA and v then
            nwA:FireServer({ type = "Shinjuku", op = "SetAuto", side = State.ShinjukuSide })
        end
    end,
})

SecStageFlow:Dropdown({
    Title = "Shinjuku Auto Side",
    Flag = "ShinjukuSide",
    Values = { "Gojo", "Sukuna", "Ask" },
    Value = "Gojo",
    Callback = function(v) State.ShinjukuSide = v end,
})

SecStageFlow:Toggle({
    Title = "Auto Skip Waves",
    Flag = "AutoSkipWave",
    Value = false,
    Callback = function(v) State.AutoSkipWave = v end,
})

SecStageFlow:Toggle({
    Title = "Auto Set Game Speed",
    Flag = "AutoGameSpeed",
    Value = false,
    Callback = function(v) State.AutoGameSpeed = v end,
})

SecStageFlow:Dropdown({
    Title = "Target Game Speed",
    Flag = "TargetGameSpeed",
    Values = { "1", "1.5", "2" },
    Value = "2",
    Callback = function(v) State.TargetGameSpeed = v end,
})

SecStageFlow:Toggle({
    Title = "Auto Next Stage / Portal (On End)",
    Flag = "AutoNextStage",
    Value = false,
    Callback = function(v) State.AutoNextStage = v end,
})

SecStageFlow:Toggle({
    Title = "Auto Replay Stage (On End)",
    Flag = "AutoReplay",
    Value = false,
    Callback = function(v) State.AutoReplay = v end,
})

SecStageFlow:Toggle({
    Title = "Auto Return To Lobby (On End)",
    Flag = "AutoLobby",
    Value = false,
    Callback = function(v) State.AutoLobby = v end,
})

SecStageFlow:Button({
    Title = "Skip Wave Now",
    Callback = function()
        local r = GetRemote("StageEnd")
        if r then r:FireServer("SkipWave") end
    end,
})

SecStageFlow:Button({
    Title = "Replay Current Stage",
    Callback = function()
        local r = GetRemote("StageEnd")
        if r then r:FireServer("Replay") end
    end,
})

SecStageFlow:Button({
    Title = "Return To Lobby",
    Callback = function()
        task.spawn(function()
            local r = GetRemote("StageEnd")
            if r then
                if LP:GetAttribute("NWLive") == true then
                    r:FireServer("EndMatch")
                    task.wait(0.4)
                end
                r:FireServer("Lobby")
            end
        end)
    end,
})

local SecLauncher = TabMatch:Section({ Title = "Stage & Special Mode Launchers", Icon = "map", Opened = true })

SecLauncher:Dropdown({
    Title = "Select Map / World",
    Flag = "SelectedWorld",
    Values = BuildWorldOptions(),
    Value = "HiddenGround",
    Callback = function(v) State.SelectedWorld = v end,
})

SecLauncher:Dropdown({
    Title = "Select Act",
    Flag = "SelectedAct",
    Values = { "1", "2", "3", "4", "5", "6" },
    Value = "1",
    Callback = function(v) State.SelectedAct = v end,
})

SecLauncher:Dropdown({
    Title = "Select Difficulty",
    Flag = "SelectedDiff",
    Values = { "Normal", "Hard", "Nightmare" },
    Value = "Normal",
    Callback = function(v) State.SelectedDiff = v end,
})

SecLauncher:Dropdown({
    Title = "Launch Mode",
    Flag = "SelectedMode",
    Values = { "Story", "Raid" },
    Value = "Story",
    Callback = function(v) State.SelectedMode = v end,
})

SecLauncher:Button({
    Title = "Launch Selected Story / Raid Stage",
    Callback = function()
        local r = GetRemote("StageEnd")
        if r then
            if State.SelectedMode == "Raid" then
                r:FireServer("PrepareRaid", State.SelectedAct, State.SelectedDiff, nil, State.SelectedWorld)
            else
                r:FireServer("StartMatch", State.SelectedAct, State.SelectedDiff, "Go", State.SelectedWorld, "Auto")
            end
            Notify("Stage Launcher", "Launching " .. tostring(State.SelectedWorld) .. " Act " .. tostring(State.SelectedAct), 3)
        end
    end,
})

SecLauncher:Slider({
    Title = "Haunted Tower Floor",
    Flag = "HauntedTowerFloor",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = 1 },
    Callback = function(v) State.HauntedTowerFloor = v end,
})

local modeQuickButtons = {
    { "Start Daily Challenge", { type = "Challenge", op = "Start", period = "daily" } },
    { "Start Weekly Challenge", { type = "Challenge", op = "Start", period = "weekly" } },
    { "Resume Infinity Tower", { type = "Tower", op = "Resume" } },
    { "Start Rogue (Titan Gauntlet)", { type = "Rogue", op = "Start" } },
    { "Start Seireitei Invasion", { type = "Invasion", op = "Start" } },
    { "Start Gem Rush", { type = "GemRush", op = "Start" } },
    { "Start Steel Ball Run (SBR)", { type = "SBRRace", op = "Start" } },
    { "Start Anti-Spiral (Solo)", { type = "GurrenAntiSpiral", op = "Solo" } },
}

for _, spec in ipairs(modeQuickButtons) do
    SecLauncher:Button({
        Title = spec[1],
        Callback = function()
            local nwA = GetRemote("NWAction")
            if nwA then
                nwA:FireServer(spec[2])
                Notify("Mode Launcher", "Requested: " .. spec[1], 3)
            end
        end,
    })
end

SecLauncher:Button({
    Title = "Start Haunted Tower (Selected Floor)",
    Callback = function()
        local nwA = GetRemote("NWAction")
        if nwA then
            nwA:FireServer({ type = "HauntedTower", op = "Start", floor = State.HauntedTowerFloor })
            Notify("Haunted Tower", "Starting floor " .. tostring(State.HauntedTowerFloor), 3)
        end
    end,
})

-- TAB 2: SUMMON & UNITS
local SecRoll = TabSummon:Section({ Title = "Normal Roll & Event Banners", Icon = "dices", Opened = true })

SecRoll:Dropdown({
    Title = "Roll Banner Source",
    Flag = "RollBannerType",
    Values = { "Normal Roll", "Halloween Banner", "Spiral Banner" },
    Value = "Normal Roll",
    Callback = function(v) State.RollBannerType = v end,
})

SecRoll:Toggle({
    Title = "Auto Roll / Summon",
    Flag = "AutoRoll",
    Value = false,
    Callback = function(v) State.AutoRoll = v end,
})

SecRoll:Toggle({
    Title = "Use Fast Roll",
    Flag = "FastRoll",
    Value = false,
    Callback = function(v) State.FastRoll = v end,
})

SecRoll:Toggle({
    Title = "Use Multi Roll (Normal x2 / Banner x10)",
    Flag = "MultiRoll",
    Value = false,
    Callback = function(v) State.MultiRoll = v end,
})

SecRoll:Slider({
    Title = "Roll Interval (s)",
    Flag = "RollInterval",
    Step = 0.05,
    Value = { Min = 0.1, Max = 2.0, Default = 0.35 },
    Callback = function(v) State.RollInterval = v end,
})

local function HasInventoryItem(baseRef, minAmt)
    local pdata = GetPlayerData()
    if not pdata or not pdata.Inventory or type(pdata.Inventory.Items) ~= "table" then
        return false, 0
    end
    local total = 0
    for _, it in pairs(pdata.Inventory.Items) do
        if type(it) == "table" and (it.BaseDataRef == baseRef or it.Id == baseRef) then
            total = total + (tonumber(it.Amount) or 0)
        end
    end
    return total >= (minAmt or 1), total
end

local function SyncAutoSellSetting(rarityKey, val)
    local pdata = GetPlayerData()
    local cur = pdata and pdata.ClientData and (pdata.ClientData["AutoSell" .. rarityKey] == true)
    if cur == val then
        return
    end
    local rSell = GetRemote("AutoSellToggle")
    if rSell then
        rSell:FireServer(rarityKey)
    end
end

for _, rar in ipairs({ "Rare", "Epic", "Legendary", "Mythic", "Secret" }) do
    local flagName = "AutoSell" .. rar
    SecRoll:Toggle({
        Title = "Auto Sell " .. rar,
        Flag = flagName,
        Value = false,
        Callback = function(v)
            State[flagName] = v
            SyncAutoSellSetting(rar, v)
        end,
    })
end

local SecUnits = TabSummon:Section({ Title = "Unit Loadout, Evolution, Traits & Stats", Icon = "users", Opened = true })

local unitOpts, unitUuidMap = GetUnitOptions()
State.TraitUnitTarget = unitOpts[1] or ""
State.StatUnitTarget = unitOpts[1] or ""

local UnitSelectDropdown = SecUnits:Dropdown({
    Title = "Target Unit",
    Flag = "TraitUnitTarget",
    Values = unitOpts,
    Value = unitOpts[1],
    Callback = function(v)
        State.TraitUnitTarget = v
        State.StatUnitTarget = v
    end,
})

SecUnits:Button({
    Title = "Refresh Unit Inventory List",
    Callback = function()
        unitOpts, unitUuidMap = GetUnitOptions()
        pcall(function() UnitSelectDropdown:Refresh(unitOpts) end)
        Notify("Units Refreshed", string.format("Loaded %d units.", #unitOpts), 2)
    end,
})

SecUnits:Button({
    Title = "Auto Equip Best Units (Top 6)",
    Callback = function()
        local pdata = GetPlayerData()
        local unitsRem = GetRemote("Units")
        if not pdata or not unitsRem or not pdata.Inventory or not pdata.Inventory.Units then return end
        local _, envG = GetNWState()
        local scored = {}
        for uuid, inst in pairs(pdata.Inventory.Units) do
            if type(inst) == "table" then
                local sc = (tonumber(inst.Level) or 1) * 10
                if envG and type(envG.P2_AutoScore) == "function" then
                    local okS, s = pcall(envG.P2_AutoScore, inst)
                    if okS and type(s) == "number" then sc = s end
                end
                table.insert(scored, { uuid = uuid, score = sc })
            end
        end
        table.sort(scored, function(a, b) return a.score > b.score end)
        unitsRem:FireServer("UnequipAll")
        task.wait(0.25)
        for slot = 1, math.min(6, #scored) do
            unitsRem:FireServer("Equip", tostring(slot), scored[slot].uuid)
            task.wait(0.12)
        end
        Notify("Auto Equip", "Equipped top " .. math.min(6, #scored) .. " units.", 3)
    end,
})

SecUnits:Button({
    Title = "Evolve Selected Unit",
    Callback = function()
        local uuid = unitUuidMap[State.TraitUnitTarget]
        local nwA = GetRemote("NWAction")
        if uuid and nwA then
            nwA:FireServer({ type = "Evolve", uuid = uuid })
            Notify("Evolve", "Sent evolution request for selected unit.", 3)
        else
            Notify("Evolve Error", "Please select a valid unit first.", 3)
        end
    end,
})

SecUnits:Button({
    Title = "Sell Unlocked Low-Rarity Duplicates (Rare/Epic)",
    Desc = "Safely sells non-equipped, unlocked Rare & Epic units using pick dictionary format",
    Callback = function()
        local pdata = GetPlayerData()
        local unitsRem = GetRemote("Units")
        if not pdata or not unitsRem or not pdata.Inventory or not pdata.Inventory.Units then return end
        local cc = GetClientCache()
        local ud = (cc and cc.UnitData) or GetDataModule("UnitData") or {}
        local equippedSet = {}
        for _, uid in pairs(pdata.EquippedUnits or {}) do
            if uid then equippedSet[uid] = true end
        end
        local pickMap, count = {}, 0
        for uuid, inst in pairs(pdata.Inventory.Units) do
            if type(inst) == "table" and not equippedSet[uuid] and inst.Locked ~= true then
                local base = ud[inst.Name]
                local rar = base and base.Rarity
                if rar == "Rare" or rar == "Epic" then
                    pickMap[uuid] = true
                    count = count + 1
                end
            end
        end
        if count > 0 then
            unitsRem:FireServer("Sold", pickMap, "pick")
            Notify("Bulk Sell", string.format("Sold %d unlocked Rare/Epic units.", count), 3)
        else
            Notify("Bulk Sell", "No unlocked unequipped Rare/Epic units found.", 3)
        end
    end,
})

SecUnits:Button({
    Title = "Upgrade Unit Storage Capacity (+Slots)",
    Callback = function()
        local cc = GetClientCache()
        if cc and cc.Network and type(cc.Network.Fire) == "function" then
            pcall(cc.Network.Fire, "UpgradeInv")
            Notify("Storage", "Requested inventory storage expansion.", 3)
        else
            local r = GetRemote("UpgradeInv")
            if r then r:FireServer() end
        end
    end,
})

SecUnits:Button({
    Title = "Convert 3 Stat Chips -> 1 Super Stat Chip",
    Callback = function()
        local r = GetRemote("ConvertChips")
        if r then
            r:FireServer("Up", 1)
            Notify("Convert Chips", "Converted 3 Stat Chips -> 1 Super Stat Chip.", 2)
        end
    end,
})

SecUnits:Dropdown({
    Title = "Desired Traits (Stop On Roll)",
    Flag = "TargetTraits",
    Values = BuildTraitOptions(),
    Multi = true,
    AllowNone = true,
    Value = {},
    Callback = function(v) State.TargetTraits = v or {} end,
})

SecUnits:Slider({
    Title = "Trait Reroll Safety Cap",
    Flag = "TraitMaxRolls",
    Step = 1,
    Value = { Min = 1, Max = 200, Default = 25 },
    Callback = function(v) State.TraitMaxRolls = v end,
})

SecUnits:Toggle({
    Title = "Auto Reroll Trait (Selected Unit)",
    Flag = "AutoTraitReroll",
    Value = false,
    Callback = function(v) State.AutoTraitReroll = v end,
})

SecUnits:Dropdown({
    Title = "Stat Reroll Mode",
    Flag = "StatRerollMode",
    Values = { "All Stats (SuperStatChip)", "Single DMG (StatChip)", "Single RNG (StatChip)", "Single HEA (StatChip)", "Single CDR (StatChip)" },
    Value = "All Stats (SuperStatChip)",
    Callback = function(v) State.StatRerollMode = v end,
})

SecUnits:Toggle({
    Title = "Auto Reroll Stats (Selected Unit)",
    Flag = "AutoStatReroll",
    Value = false,
    Callback = function(v) State.AutoStatReroll = v end,
})

local SecConsumables = TabSummon:Section({ Title = "Capsules & Potions", Icon = "flask-conical", Opened = true })

SecConsumables:Toggle({
    Title = "Auto Open All Capsules",
    Flag = "AutoOpenCapsules",
    Value = false,
    Callback = function(v) State.AutoOpenCapsules = v end,
})

SecConsumables:Button({
    Title = "Open All Capsules Now",
    Callback = function()
        local opened = OpenAllCapsules()
        Notify("Capsules", string.format("Opened %d capsules.", opened), 3)
    end,
})

SecConsumables:Dropdown({
    Title = "Select Potion",
    Flag = "SelectedPotion",
    Values = BuildPotionOptions(),
    Value = "LuckPotion",
    Callback = function(v) State.SelectedPotion = v end,
})

SecConsumables:Button({
    Title = "Use Selected Potion (x1)",
    Callback = function()
        local useItem = GetRemote("UseItem")
        local pdata = GetPlayerData()
        if not useItem or not pdata or not pdata.Inventory or type(pdata.Inventory.Items) ~= "table" then
            return
        end
        local itemId = nil
        for _, it in pairs(pdata.Inventory.Items) do
            if type(it) == "table" and (tonumber(it.Amount) or 0) > 0 and (it.BaseDataRef == State.SelectedPotion or it.Id == State.SelectedPotion) then
                itemId = it.Id
                break
            end
        end
        if itemId then
            useItem:FireServer(itemId)
            Notify("Potion Used", "Used 1x " .. tostring(State.SelectedPotion), 2)
        else
            Notify("Potion Unavailable", "You do not own any " .. tostring(State.SelectedPotion) .. ".", 3)
        end
    end,
})

-- TAB 3: RELICS, TECH & UPGRADES
local SecPowerTech = TabTech:Section({ Title = "Server-Side Special Unit Techniques", Icon = "zap", Opened = true })

SecPowerTech:Toggle({
    Title = "Auto Cosmic Techniques (Garou)",
    Flag = "AutoCosmicTech",
    Value = false,
    Callback = function(v)
        State.AutoCosmicTech = v
        task.spawn(function()
            local r = GetRemote("NWCosmicTech")
            if r then TimedInvoke(r, 3.0, "auto", v) end
        end)
    end,
})

SecPowerTech:Toggle({
    Title = "Auto Gilgamesh Treasury",
    Flag = "AutoGilTreasury",
    Value = false,
    Callback = function(v)
        State.AutoGilTreasury = v
        task.spawn(function()
            local r = GetRemote("NWGilTreasury")
            if r then TimedInvoke(r, 3.0, "auto", v) end
        end)
    end,
})

SecPowerTech:Toggle({
    Title = "Auto Skill Hunter (Chrollo)",
    Flag = "AutoSkillHunter",
    Value = false,
    Callback = function(v)
        State.AutoSkillHunter = v
        task.spawn(function()
            local r = GetRemote("NWSkillHunter")
            if r then TimedInvoke(r, 3.0, "auto", v) end
        end)
    end,
})

local SecRelics = TabTech:Section({ Title = "Relic Manager & Stat Rerolls", Icon = "gem", Opened = true })

local relicOpts, relicIdMap = GetRelicOptions()
State.SelectedRelicTarget = relicOpts[1] or ""

local RelicDropdown = SecRelics:Dropdown({
    Title = "Select Owned Relic",
    Flag = "SelectedRelicTarget",
    Values = relicOpts,
    Value = relicOpts[1],
    Callback = function(v) State.SelectedRelicTarget = v end,
})

SecRelics:Button({
    Title = "Refresh Relics List",
    Callback = function()
        relicOpts, relicIdMap = GetRelicOptions()
        pcall(function() RelicDropdown:Refresh(relicOpts) end)
        Notify("Relics", string.format("Loaded %d relic entries.", #relicOpts), 2)
    end,
})

SecRelics:Toggle({ Title = "Lock Relic Stat 1", Flag = "RelicLock1", Value = false, Callback = function(v) State.RelicLock1 = v end })
SecRelics:Toggle({ Title = "Lock Relic Stat 2", Flag = "RelicLock2", Value = false, Callback = function(v) State.RelicLock2 = v end })
SecRelics:Toggle({ Title = "Lock Relic Stat 3", Flag = "RelicLock3", Value = false, Callback = function(v) State.RelicLock3 = v end })

SecRelics:Button({
    Title = "Reroll Selected Relic Stats",
    Callback = function()
        local rid = relicIdMap[State.SelectedRelicTarget]
        local r = GetRemote("NWRelicAction")
        if rid and r then
            local locks = {}
            if State.RelicLock1 then table.insert(locks, 1) end
            if State.RelicLock2 then table.insert(locks, 2) end
            if State.RelicLock3 then table.insert(locks, 3) end
            r:FireServer({ op = "Reroll", id = rid, locks = locks })
            Notify("Relic Reroll", "Rerolled selected relic.", 2)
        else
            Notify("Relic Reroll", "No valid relic selected.", 2)
        end
    end,
})

local SecTreeRebirth = TabTech:Section({ Title = "Rebirth, Upgrade Tree & Crafting", Icon = "trending-up", Opened = true })

SecTreeRebirth:Toggle({
    Title = "Auto Rebirth (When Gems Sufficient)",
    Flag = "AutoRebirth",
    Value = false,
    Callback = function(v) State.AutoRebirth = v end,
})

SecTreeRebirth:Button({
    Title = "Rebirth Now",
    Callback = function()
        local nw = GetNWState()
        local pdata = GetPlayerData()
        local gems = (pdata and pdata.ClientData and tonumber(pdata.ClientData.Gems)) or 0
        local cost = (nw and tonumber(nw.RebirthCost)) or 0
        if cost > 0 and gems < cost then
            Notify("Rebirth Denied", string.format("Need %d Gems (have %d).", cost, gems), 3)
            return
        end
        local r = GetRemote("NWAction")
        if r then
            r:FireServer({ type = "Rebirth" })
            task.delay(0.45, function()
                if r then r:FireServer({ type = "Sync" }) end
            end)
        end
    end,
})

SecTreeRebirth:Toggle({
    Title = "Auto Buy Tree Upgrades",
    Flag = "AutoBuyUpgrades",
    Value = false,
    Callback = function(v) State.AutoBuyUpgrades = v end,
})

SecTreeRebirth:Button({
    Title = "Buy All Affordable Upgrades Once",
    Callback = function()
        local r = GetRemote("NWAction")
        local nw = GetNWState()
        local pdata = GetPlayerData()
        local gems = (pdata and pdata.ClientData and tonumber(pdata.ClientData.Gems)) or 0
        local yen = tonumber(LP:GetAttribute("Yen")) or (pdata and pdata.ClientData and tonumber(pdata.ClientData.Yen)) or 0
        if not r or not nw or type(nw.Upgrades) ~= "table" then return end
        local bought = 0
        for _, upg in ipairs(nw.Upgrades) do
            if type(upg) == "table" and upg.key then
                local lvl = tonumber(upg.level or upg.lvl) or 0
                local mx = tonumber(upg.max) or 1
                local cost = tonumber(upg.cost) or 0
                local usesYen = (upg.storyMap ~= nil)
                local bal = usesYen and yen or gems
                if lvl < mx and (cost <= 0 or bal >= cost) then
                    r:FireServer({ type = "BuyUpgrade", key = upg.key })
                    if usesYen then yen = yen - cost else gems = gems - cost end
                    bought = bought + 1
                    task.wait(0.08)
                end
            end
        end
        if bought > 0 then r:FireServer({ type = "Sync" }) end
        Notify("Tree Upgrades", string.format("Requested %d available upgrades.", bought), 3)
    end,
})

SecTreeRebirth:Dropdown({
    Title = "Craft Recipe",
    Flag = "SelectedCraftKey",
    Values = BuildCraftOptions(),
    Value = "StatChip",
    Callback = function(v) State.SelectedCraftKey = v end,
})

SecTreeRebirth:Slider({
    Title = "Craft Quantity",
    Flag = "CraftQuantity",
    Step = 1,
    Value = { Min = 1, Max = 25, Default = 1 },
    Callback = function(v) State.CraftQuantity = v end,
})

SecTreeRebirth:Button({
    Title = "Craft Selected Item",
    Callback = function()
        local r = GetRemote("NWAction")
        if r then
            r:FireServer({ type = "Craft", key = State.SelectedCraftKey, count = State.CraftQuantity })
            Notify("Craft", string.format("Crafted %dx %s", State.CraftQuantity, State.SelectedCraftKey), 2)
        end
    end,
})

-- TAB 4: SHOPS & EXCHANGE
local SecEventShops = TabShops:Section({ Title = "All World & Event Shops (Raid / Explore / Event Hubs)", Icon = "store", Opened = true })

local shopOpts, shopItemMap = GetShopItemsForSource("RaidShop")
State.SelectedShopItem = shopOpts[1] or ""

local ShopItemDropdown

SecEventShops:Dropdown({
    Title = "Select Shop Catalog",
    Flag = "SelectedShopSource",
    Values = { "RaidShop", "StandardShop", "ExploreShop", "HuecoShop", "ShanksShop", "UAShop" },
    Value = "RaidShop",
    Callback = function(v)
        State.SelectedShopSource = v
        shopOpts, shopItemMap = GetShopItemsForSource(v)
        State.SelectedShopItem = shopOpts[1] or ""
        if ShopItemDropdown then
            pcall(function() ShopItemDropdown:Refresh(shopOpts) end)
        end
    end,
})

ShopItemDropdown = SecEventShops:Dropdown({
    Title = "Select Shop Item",
    Flag = "SelectedShopItem",
    Values = shopOpts,
    Value = shopOpts[1],
    Callback = function(v) State.SelectedShopItem = v end,
})

SecEventShops:Button({
    Title = "Refresh Selected Shop Stock",
    Callback = function()
        local nwA = GetRemote("NWAction")
        if nwA then nwA:FireServer({ type = "Sync" }) end
        task.wait(0.25)
        shopOpts, shopItemMap = GetShopItemsForSource(State.SelectedShopSource)
        State.SelectedShopItem = shopOpts[1] or ""
        pcall(function() ShopItemDropdown:Refresh(shopOpts) end)
        Notify("Shop Synced", string.format("Loaded %d items from %s.", #shopOpts, State.SelectedShopSource), 2)
    end,
})

SecEventShops:Button({
    Title = "Buy Selected Item (x1)",
    Callback = function()
        local key = shopItemMap[State.SelectedShopItem]
        local nwA = GetRemote("NWAction")
        if key and nwA then
            if State.SelectedShopSource == "StandardShop" then
                nwA:FireServer({ type = "BuyShop", id = key })
            else
                nwA:FireServer({ type = "BuyRaidShop", key = key, qty = 1 })
            end
            Notify("Shop Purchase", "Requested x1 " .. tostring(key), 2)
        end
    end,
})

SecEventShops:Button({
    Title = "Buy Selected Item (x10)",
    Callback = function()
        local key = shopItemMap[State.SelectedShopItem]
        local nwA = GetRemote("NWAction")
        if key and nwA then
            if State.SelectedShopSource == "StandardShop" then
                for _ = 1, 10 do
                    nwA:FireServer({ type = "BuyShop", id = key })
                    task.wait(0.05)
                end
            else
                nwA:FireServer({ type = "BuyRaidShop", key = key, qty = 10 })
            end
            Notify("Shop Purchase", "Requested x10 " .. tostring(key), 2)
        end
    end,
})

local SecAutoShops = TabShops:Section({ Title = "Yen/Gold Shop, Gem Shop & Exchange", Icon = "coins", Opened = true })

SecAutoShops:Toggle({
    Title = "Auto Buy Yen Shop Stock (Sakamoto)",
    Flag = "AutoGoldShop",
    Value = false,
    Callback = function(v)
        State.AutoGoldShop = v
        task.spawn(function()
            local r = GetRemote("NWGoldShop")
            if r then TimedInvoke(r, 2.5, { op = "SetAuto", on = v }) end
        end)
    end,
})

SecAutoShops:Toggle({
    Title = "Auto Buy Gem Shop Units (Speedwagon)",
    Flag = "AutoGemShop",
    Value = false,
    Callback = function(v) State.AutoGemShop = v end,
})

SecAutoShops:Dropdown({
    Title = "Exchange Source Currency",
    Flag = "ExchangeSource",
    Values = BuildExchangeSources(),
    Value = "QuincyMedal",
    Callback = function(v) State.ExchangeSource = v end,
})

SecAutoShops:Dropdown({
    Title = "Exchange Pack Size (1..4)",
    Flag = "ExchangePack",
    Values = { "1", "2", "3", "4" },
    Value = "1",
    Callback = function(v) State.ExchangePack = v end,
})

SecAutoShops:Button({
    Title = "Convert Currency via NWExchange",
    Callback = function()
        task.spawn(function()
            local r = GetRemote("NWExchange")
            local packIdx = tonumber(State.ExchangePack) or 1
            local ok, res = TimedInvoke(r, 3.0, "trade", State.ExchangeSource, "ShowdownToken", packIdx)
            if ok and type(res) == "table" then
                Notify("NWExchange", res.ok and "Exchange trade succeeded." or tostring(res.msg or "Trade declined (insufficient currency or closed)."), 3)
            else
                Notify("NWExchange", tostring(res), 3)
            end
        end)
    end,
})

SecAutoShops:Button({
    Title = "Check Exchange Balances (NWExchange)",
    Callback = function()
        task.spawn(function()
            local r = GetRemote("NWExchange")
            local ok, res = TimedInvoke(r, 3.0, "state")
            if ok and type(res) == "table" and type(res.state) == "table" then
                Notify("NWExchange", res.state.Open and "Exchange desk is OPEN." or "Exchange desk is closed.", 3)
            else
                Notify("NWExchange", tostring(res), 3)
            end
        end)
    end,
})

-- TAB 5: FARM & EVENTS
local SecExplore = TabFarm:Section({ Title = "Auto Exploration", Icon = "compass", Opened = true })

SecExplore:Toggle({
    Title = "Auto Claim & Dispatch Explorations",
    Flag = "AutoExploration",
    Value = false,
    Callback = function(v) State.AutoExploration = v end,
})

SecExplore:Dropdown({
    Title = "Exploration Duration",
    Flag = "ExploreDuration",
    Values = { "Short", "Medium", "Long" },
    Value = "Short",
    Callback = function(v) State.ExploreDuration = v end,
})

SecExplore:Dropdown({
    Title = "Exploration Danger Level",
    Flag = "ExploreDanger",
    Values = { "Normal", "Hard", "Nightmare" },
    Value = "Normal",
    Callback = function(v) State.ExploreDanger = v end,
})

SecExplore:Button({
    Title = "Claim & Send Expeditions Now",
    Callback = function()
        task.spawn(RunAutoExploration)
        Notify("Exploration", "Claiming completed expeditions and dispatching spare squads.", 3)
    end,
})

local SecHalloween = TabFarm:Section({ Title = "Halloween Part 2, Portals & Skill Tree", Icon = "flame", Opened = true })

SecHalloween:Toggle({
    Title = "Auto Claim Free Pumpkin Portals",
    Flag = "AutoClaimHwPortals",
    Value = false,
    Callback = function(v) State.AutoClaimHwPortals = v end,
})

SecHalloween:Button({
    Title = "Claim Free Pumpkin Portals Now",
    Callback = function()
        task.spawn(function()
            local r = GetRemote("NWHwPortal")
            local ok, res = TimedInvoke(r, 3.0, "claim")
            Notify("Halloween Portals", (ok and type(res) == "table" and res.msg) or "Submitted free portal claim.", 3)
        end)
    end,
})

SecHalloween:Toggle({
    Title = "Auto Buy Halloween Skill Tree Nodes",
    Flag = "AutoBuyHwTree",
    Value = false,
    Callback = function(v) State.AutoBuyHwTree = v end,
})

SecHalloween:Toggle({
    Title = "Auto Grave Bonk Minigame (Zero Granny)",
    Flag = "AutoGraveBonk",
    Value = false,
    Callback = function(v) State.AutoGraveBonk = v end,
})

SecHalloween:Toggle({
    Title = "Auto Halloween Ghosts",
    Flag = "AutoHwGhosts",
    Value = false,
    Callback = function(v) State.AutoHwGhosts = v end,
})

local SecMinigames = TabFarm:Section({ Title = "Wish Fountain, Gurren Mine, Soul Dodge & Finds", Icon = "sparkles", Opened = true })

SecMinigames:Dropdown({
    Title = "Wish Coin Type",
    Flag = "WishCoin",
    Values = BuildWishCoinOptions(),
    Value = "Bronze",
    Callback = function(v) State.WishCoin = v end,
})

SecMinigames:Dropdown({
    Title = "Wish Target Servant",
    Flag = "WishServant",
    Values = BuildWishServantOptions(),
    Value = "Saber",
    Callback = function(v) State.WishServant = v end,
})

SecMinigames:Toggle({
    Title = "Auto Wish Fountain (Perfect BarPos Solver)",
    Flag = "AutoWishFountain",
    Value = false,
    Callback = function(v) State.AutoWishFountain = v end,
})

SecMinigames:Button({
    Title = "Perform Single Perfect Wish",
    Callback = function()
        task.spawn(function()
            local ok, res = RunAutoWishOnce()
            Notify("Wish Fountain", ok and "Wish completed (Perfect target)." or tostring(res), 3)
        end)
    end,
})

SecMinigames:Toggle({
    Title = "Auto Gurren Mine Ores",
    Flag = "AutoGurrenMine",
    Value = false,
    Callback = function(v) State.AutoGurrenMine = v end,
})

SecMinigames:Toggle({
    Title = "Auto Soul Dodge (Lobby Only)",
    Flag = "AutoSoulDodge",
    Value = false,
    Callback = function(v) State.AutoSoulDodge = v end,
})

SecMinigames:Button({
    Title = "Sweep All Lobby Collectibles",
    Desc = "Collects Auswahlen Eyes, Enkidu Tablets, Bang Notes, Cursed Blade & Pumpkins",
    Callback = function()
        task.spawn(SweepLobbyCollectibles)
    end,
})

-- TAB 6: REWARDS, MAIL & QUESTS
local SecRewards = TabRewards:Section({ Title = "All Claims, Mailbox, Index & Codes", Icon = "award", Opened = true })

SecRewards:Toggle({
    Title = "Auto Claim All Rewards (Comprehensive Loop)",
    Desc = "Playtime, Daily, BP/BP4, Quests, Raid/Gurren Quests, Tower, Level, HwPass, Index & Special Quests",
    Flag = "AutoClaimRewards",
    Value = false,
    Callback = function(v) State.AutoClaimRewards = v end,
})

SecRewards:Button({
    Title = "Claim All Available Rewards Now",
    Callback = function()
        task.spawn(function()
            ClaimAllAvailableRewards()
            Notify("Rewards Claimed", "Triggered all ready reward, quest, pass & index claims.", 3)
        end)
    end,
})

SecRewards:Toggle({
    Title = "Auto Claim Mailbox Rewards",
    Flag = "AutoClaimMail",
    Value = false,
    Callback = function(v) State.AutoClaimMail = v end,
})

SecRewards:Button({
    Title = "Claim All Mailbox & Delete Read",
    Callback = function()
        task.spawn(function()
            local ok = ClaimAllMailRewards()
            local mailRem = GetRemote("NWMail")
            if ok and mailRem then
                TimedInvoke(mailRem, 3.0, "DeleteRead", nil)
            end
            Notify("Mailbox", ok and "Claimed all mailbox rewards." or "No claimable mail or unavailable.", 3)
        end)
    end,
})

SecRewards:Button({
    Title = "Claim All Unit Index Discoveries",
    Callback = function()
        local nwA = GetRemote("NWAction")
        if nwA then
            nwA:FireServer({ type = "UnitIndex", op = "ClaimAll" })
            Notify("Unit Index", "Claimed all ready discovered Unit Index rewards.", 3)
        end
    end,
})

SecRewards:Button({
    Title = "Redeem All Active Codes",
    Desc = "Fetches unredeemed codes dynamically from NWWikiCodes and redeems them",
    Callback = function()
        task.spawn(RedeemAllWikiCodes)
    end,
})

-- TAB 7: TELEPORT & MISC
local SecTeleport = TabMisc:Section({ Title = "World & NPC Teleports", Icon = "map-pin", Opened = true })

SecTeleport:Dropdown({
    Title = "Select Warp Destination",
    Flag = "SelectedWarp",
    Values = BuildWarpOptions(),
    Value = "Story",
    Callback = function(v) State.SelectedWarp = v end,
})

SecTeleport:Button({
    Title = "Warp To Selected Destination",
    Callback = function()
        task.spawn(function()
            local key = tostring(State.SelectedWarp or "Story")
            local _, envG = GetNWState()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local posBefore = hrp and hrp.Position
            local entry = nil
            for _, v in ipairs(WarpConfigData) do
                if type(v) == "table" and v.key == key then
                    entry = v
                    break
                end
            end
            local r = GetRemote("NWWarp")
            if r then r:FireServer(key) end
            task.wait(0.35)
            local posAfter = hrp and hrp.Position
            local moved = posBefore and posAfter and (posAfter - posBefore).Magnitude > 3
            if not moved and hrp and entry then
                local targetObj = (entry.spot and Services.Workspace:FindFirstChild(entry.spot, true))
                    or (entry.npc and Services.Workspace:FindFirstChild(entry.npc))
                if targetObj then
                    local cf = nil
                    if targetObj:IsA("BasePart") then
                        cf = targetObj.CFrame
                    elseif targetObj:IsA("Model") then
                        cf = targetObj:GetPivot()
                    end
                    if cf then
                        hrp.CFrame = cf * CFrame.new(0, 3, -5)
                        moved = true
                    end
                end
            end
            if key == "GurrenMine" and envG and type(envG.P2_OpenGurrenMine) == "function" then
                pcall(envG.P2_OpenGurrenMine)
            elseif key == "GurrenHangar" and envG and type(envG.NW_GHangarTravel) == "function" then
                pcall(envG.NW_GHangarTravel)
            end
            Notify("Teleport", moved and ("Warped to " .. key) or ("Requested warp to " .. key), 2)
        end)
    end,
})

local SecMisc = TabMisc:Section({ Title = "Anti-AFK, Performance & Utilities", Icon = "shield", Opened = true })

SecMisc:Toggle({
    Title = "Anti-AFK (Prevent 20-Min Idle Kick)",
    Flag = "AntiAFK",
    Value = false,
    Callback = function(v) State.AntiAFK = v end,
})

SecMisc:Toggle({
    Title = "Block Idle AFK Farm Teleport",
    Flag = "BlockAfkTeleport",
    Value = false,
    Callback = function(v)
        State.BlockAfkTeleport = v
        local r = GetRemote("ChangeSetting")
        if r and v then r:FireServer("P2_AfkFarm", false) end
    end,
})

SecMisc:Toggle({
    Title = "Low Detail & Disable Combat VFX",
    Flag = "LowGFX",
    Value = false,
    Callback = function(v)
        State.LowGFX = v
        local r = GetRemote("ChangeSetting")
        if r then
            r:FireServer("DisableAttackVFX", v)
            r:FireServer("DisableVisualEffects", v)
            r:FireServer("DisableDamageIndicators", v)
            r:FireServer("LowDetailMode", v)
        end
    end,
})

SecMisc:Button({
    Title = "Rejoin Current Server",
    Callback = function()
        Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end,
})

-- TAB 8: CONFIG MANAGER
local ConfigManager = Window.ConfigManager
local SecConfig = TabConfig:Section({ Title = "Configuration Manager", Icon = "folder", Opened = true })
local CurrentConfigName = "default"
local SelectedConfigName = "default"

local function GetSavedConfigs()
    local ok, list = pcall(function() return ConfigManager:AllConfigs() end)
    if ok and type(list) == "table" and #list > 0 then
        return list
    end
    return { "default" }
end

SecConfig:Input({
    Title = "Config Name",
    Placeholder = "Enter config name...",
    Value = "default",
    Callback = function(v)
        if v and v ~= "" then CurrentConfigName = v end
    end,
})

local ConfigDropdown = SecConfig:Dropdown({
    Title = "Saved Configs",
    Values = GetSavedConfigs(),
    Value = GetSavedConfigs()[1],
    Callback = function(v)
        SelectedConfigName = v
        CurrentConfigName = v
    end,
})

SecConfig:Button({
    Title = "Save Config",
    Callback = function()
        local name = (CurrentConfigName ~= "" and CurrentConfigName) or "default"
        local cfg = ConfigManager:CreateConfig(name)
        if cfg then
            cfg:Save()
            SelectedConfigName = name
            pcall(function() ConfigDropdown:Refresh(GetSavedConfigs()) end)
            Notify("Config Saved", "Saved configuration '" .. name .. "'", 3)
        end
    end,
})

SecConfig:Button({
    Title = "Load Selected Config",
    Callback = function()
        local name = SelectedConfigName or CurrentConfigName
        local cfg = ConfigManager:CreateConfig(name)
        if cfg then
            cfg:Load()
            Notify("Config Loaded", "Loaded configuration '" .. name .. "'", 3)
        end
    end,
})

SecConfig:Button({
    Title = "Set Selected as AutoLoad",
    Callback = function()
        local name = SelectedConfigName or CurrentConfigName
        local cfg = ConfigManager:CreateConfig(name)
        if cfg then
            cfg:SetAutoLoad(true)
            Notify("AutoLoad Set", "'" .. name .. "' will auto-load on next execution.", 3)
        end
    end,
})

SecConfig:Button({
    Title = "Refresh Configs List",
    Callback = function()
        pcall(function() ConfigDropdown:Refresh(GetSavedConfigs()) end)
    end,
})

SecConfig:Button({
    Title = "Delete Selected Config",
    Callback = function()
        local name = SelectedConfigName
        if name and name ~= "" then
            pcall(function() ConfigManager:DeleteConfig(name) end)
            pcall(function() ConfigDropdown:Refresh(GetSavedConfigs()) end)
            Notify("Config Deleted", "Deleted '" .. name .. "'", 3)
        end
    end,
})

-- Background Listeners & Workers --

table.insert(Connections, LP.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            Services.VirtualUser:CaptureController()
            Services.VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end))

do
    local ghostRem = GetRemote("NWGhostCatch")
    if ghostRem and ghostRem:IsA("RemoteEvent") then
        table.insert(Connections, ghostRem.OnClientEvent:Connect(function(op, data)
            if not State.AutoHwGhosts or op ~= "open" or type(data) ~= "table" then return end
            task.delay(0.18, function()
                if State.AutoHwGhosts and ghostRem then
                    ghostRem:FireServer("hit", { k = data.k or data.shown, t = Services.Workspace:GetServerTimeNow() })
                end
            end)
        end))
    end

    local bonkRem = GetRemote("NWGraveBonk")
    if bonkRem and bonkRem:IsA("RemoteEvent") then
        table.insert(Connections, bonkRem.OnClientEvent:Connect(function(op, data)
            if not State.AutoGraveBonk or op ~= "pop" or type(data) ~= "table" then return end
            if data.kind ~= "granny" and data.head then
                task.delay(0.08, function()
                    if State.AutoGraveBonk and bonkRem then
                        bonkRem:FireServer("bonk", data.id, data.head)
                    end
                end)
            end
        end))
    end

    -- Server response & error relay so Rebirth / Evolve / Roll / Craft never fail silently
    local lastFeedbackAt, lastFeedbackMsg = 0, ""
    local function RelayServerMsg(title, msg, kind)
        if type(msg) ~= "string" or msg == "" then return end
        local now = os.clock()
        if msg == lastFeedbackMsg and (now - lastFeedbackAt) < 2.0 then return end
        lastFeedbackAt, lastFeedbackMsg = now, msg
        if State.AutoRebirth and string.find(string.lower(msg), "rebirth") and kind == false then
            State.AutoRebirth = false
        end
        Notify(title, msg, 4)
    end

    local codeResRem = GetRemote("RedeemCodeResult")
    if codeResRem and codeResRem:IsA("RemoteEvent") then
        table.insert(Connections, codeResRem.OnClientEvent:Connect(function(ok, msg)
            if type(msg) == "string" and (string.find(msg:lower(), "rebirth") or string.find(msg:lower(), "craft") or string.find(msg:lower(), "upgrade")) then
                RelayServerMsg(ok and "Action Succeeded" or "Action Notice", msg, ok)
            end
        end))
    end

    local nwNotifRem = GetRemote("NWNotify")
    if nwNotifRem and nwNotifRem:IsA("RemoteEvent") then
        table.insert(Connections, nwNotifRem.OnClientEvent:Connect(function(data)
            if type(data) == "table" and type(data.text) == "string" and data.kind == "deny" then
                if State.AutoRoll and string.find(data.text:lower(), "inventory is full") then
                    State.AutoRoll = false
                    RelayServerMsg("Roll Stopped", data.text, false)
                elseif State.AutoStatReroll or State.AutoTraitReroll then
                    RelayServerMsg("Notice", data.text, false)
                end
            end
        end))
    end
end

-- Loop 1: Telemetry & AFK Teleport Guard
task.spawn(function()
    while Alive do
        pcall(function()
            local mapName = tostring(LP:GetAttribute("NWMap") or "Lobby")
            local wave = tonumber(LP:GetAttribute("NWWave")) or 0
            local yen = tonumber(LP:GetAttribute("Yen")) or 0
            local mobs = tonumber(LP:GetAttribute("NWMobsAlive")) or 0
            local mailCount = tonumber(LP:GetAttribute("NWMailBadge")) or 0
            local pdata = GetPlayerData()
            local gems = (pdata and pdata.ClientData and tonumber(pdata.ClientData.Gems)) or 0
            local placedCount = #GetMyPlacedUnits()
            RestoreIdentity()
            StatusPara:SetDesc(string.format(
                "Map: %s | Wave: %d | Mobs: %d\nPlaced: %d | Yen: %d | Gems: %d | Mail: %d",
                mapName, wave, mobs, placedCount, yen, gems, mailCount
            ))

            if State.BlockAfkTeleport then
                local cc = GetClientCache()
                if cc and cc.AFKHandler and type(cc.AFKHandler.StillActive) == "function" then
                    pcall(cc.AFKHandler.StillActive)
                end
            end
        end)
        task.wait(1.5)
    end
end)

-- Loop 2: Combat & Match Lifecycle
task.spawn(function()
    local lastStageEndFire = 0
    while Alive do
        if State.AutoPlace then pcall(RunSmartAutoPlace) end
        if State.AutoUpgrade then pcall(RunSmartAutoUpgrade) end
        if State.AutoActiveSkills then pcall(RunAutoActiveSkills) end
        if State.AutoPriority then pcall(RunAutoPriority) end

        if State.AutoCardPick then
            local pGui = LP:FindFirstChild("PlayerGui")
            local rogueSel = pGui and pGui:FindFirstChild("NW_RogueSelect")
            if rogueSel and rogueSel.Enabled then
                local r = GetRemote("NWRogue")
                if r then pcall(function() r:FireServer({ op = "Pick", i = 1 }) end) end
            end
        end

        if State.AutoShinjukuPick then
            local pGui = LP:FindFirstChild("PlayerGui")
            local shinjukuGui = pGui and pGui:FindFirstChild("NW_ShinjukuPick")
            if shinjukuGui and shinjukuGui.Enabled then
                local nwA = GetRemote("NWAction")
                if nwA then
                    pcall(function()
                        nwA:FireServer({ type = "Shinjuku", op = "Pick", side = State.ShinjukuSide, remember = true })
                    end)
                end
            end
        end

        if State.AutoSkipWave then
            local r = GetRemote("StageEnd")
            if r and (LP:GetAttribute("NWLive") == true or LP:GetAttribute("NWGameActive") == true) then
                pcall(function() r:FireServer("SkipWave") end)
            end
        end

        if State.AutoGameSpeed then
            local r = GetRemote("GameSpeed")
            local gameCfg = RS:FindFirstChild("GameConfig")
            local gsVal = Services.Workspace:FindFirstChild("GameSpeed")
            local curSpeed = (gameCfg and tonumber(gameCfg:GetAttribute("GameSpeed"))) or (gsVal and tonumber(gsVal.Value)) or 1
            local targetNum = tonumber(State.TargetGameSpeed) or 2

            local bestUnlocked = 1
            for sToken in tostring(LP:GetAttribute("NWSpeeds") or "1"):gmatch("[^,]+") do
                local n = tonumber(sToken)
                if n and n <= targetNum and n > bestUnlocked then
                    bestUnlocked = n
                end
            end
            if r and math.abs(curSpeed - bestUnlocked) > 0.05 then
                pcall(function() r:FireServer(bestUnlocked) end)
            end
        end

        local pGui = LP:FindFirstChild("PlayerGui")
        local resUi = pGui and pGui:FindFirstChild("NW_AV_ResultsUI")
        local matchEnded = (LP:GetAttribute("NWLastResult") ~= nil and LP:GetAttribute("NWLive") == false)
            or (resUi and resUi.Enabled == true)
        if matchEnded and (os.clock() - lastStageEndFire) >= 3.0 then
            local r = GetRemote("StageEnd")
            if State.AutoNextStage then
                lastStageEndFire = os.clock()
                local hwPortal = GetRemote("NWHwPortal")
                local okP, resP = false, nil
                if hwPortal and tostring(LP:GetAttribute("NWStageType") or "") == "HwPortal" then
                    okP, resP = TimedInvoke(hwPortal, 2.5, "next")
                end
                if (not okP or not (type(resP) == "table" and resP.ok)) and r then
                    pcall(function() r:FireServer("Next") end)
                end
            elseif State.AutoReplay and r then
                lastStageEndFire = os.clock()
                pcall(function() r:FireServer("Replay") end)
            elseif State.AutoLobby and r then
                lastStageEndFire = os.clock()
                pcall(function() r:FireServer("Lobby") end)
            end
        end

        task.wait(math.clamp(tonumber(State.PlaceInterval) or 0.6, 0.2, 3.0))
    end
end)

-- Loop 3: Summon Roll & Event Banners
local nextNormalRollAt = 0
do
    local rollResRem = GetRemote("RollResult")
    if rollResRem and rollResRem:IsA("RemoteEvent") then
        table.insert(Connections, rollResRem.OnClientEvent:Connect(function(res)
            if type(res) ~= "table" then return end
            if type(res.cooldown) == "number" and res.cooldown > 0 then
                nextNormalRollAt = os.clock() + res.cooldown
            end
            if res.error == "StorageFull" and State.AutoRoll then
                State.AutoRoll = false
                Notify("Roll Stopped", "Unit storage is full. Sell units or expand storage first.", 4)
            end
        end))
    end
end

task.spawn(function()
    while Alive do
        if State.AutoRoll then
            if State.RollBannerType == "Halloween Banner" then
                local r = GetRemote("NWHwBanner")
                local qty = State.MultiRoll and 10 or 1
                if r then TimedInvoke(r, 3.0, "pull", qty) end
                task.wait(math.clamp(tonumber(State.RollInterval) or 0.35, 0.2, 2.5))
            elseif State.RollBannerType == "Spiral Banner" then
                local r = GetRemote("NWSpiralBanner")
                local qty = State.MultiRoll and 10 or 1
                if r then TimedInvoke(r, 3.0, "pull", qty) end
                task.wait(math.clamp(tonumber(State.RollInterval) or 0.35, 0.2, 2.5))
            else
                if os.clock() >= nextNormalRollAt then
                    local r = GetRemote("RequestRoll")
                    if r then
                        local qty = State.MultiRoll and 2 or 1
                        State.RollReqId = State.RollReqId + 1
                        nextNormalRollAt = os.clock() + math.clamp(tonumber(State.RollInterval) or 0.35, 0.15, 2.5)
                        pcall(function()
                            r:FireServer({
                                reqId = State.RollReqId,
                                count = qty,
                                auto = true,
                                fast = State.FastRoll,
                            })
                        end)
                    end
                end
                task.wait(0.15)
            end
        else
            task.wait(0.4)
        end
    end
end)

-- Loop 4: Trait / Stat Rerolls & Capsules
task.spawn(function()
    local traitRollsCount = 0
    while Alive do
        if State.AutoTraitReroll then
            local uuid = unitUuidMap[State.TraitUnitTarget]
            local pdata = GetPlayerData()
            local unitInst = uuid and pdata and pdata.Inventory and pdata.Inventory.Units and pdata.Inventory.Units[uuid]
            if unitInst then
                local curTrait = tostring(unitInst.Trait or "")
                local matched = false
                if type(State.TargetTraits) == "table" then
                    if State.TargetTraits[curTrait] then
                        matched = true
                    else
                        for _, tName in ipairs(State.TargetTraits) do
                            if tName == curTrait then
                                matched = true
                                break
                            end
                        end
                    end
                end
                if matched or traitRollsCount >= (tonumber(State.TraitMaxRolls) or 25) then
                    State.AutoTraitReroll = false
                    traitRollsCount = 0
                    Notify("Trait Reroll Stopped", matched and ("Rolled desired trait: " .. curTrait) or "Reached safety roll limit.", 4)
                else
                    local r = GetRemote("TraitReroll")
                    if r then
                        r:FireServer("RollTrait", nil, uuid)
                        traitRollsCount = traitRollsCount + 1
                    end
                end
            else
                State.AutoTraitReroll = false
            end
            task.wait(0.35)
        else
            traitRollsCount = 0
        end

        if State.AutoStatReroll then
            local uuid = unitUuidMap[State.StatUnitTarget ~= "" and State.StatUnitTarget or State.TraitUnitTarget]
            local r = GetRemote("StatReroll")
            local mode = tostring(State.StatRerollMode or "All Stats (SuperStatChip)")
            if not uuid or not r then
                State.AutoStatReroll = false
            elseif mode == "All Stats (SuperStatChip)" then
                if HasInventoryItem("SuperStatChip", 1) then
                    r:FireServer("All", uuid)
                else
                    State.AutoStatReroll = false
                    Notify("Stat Reroll Stopped", "Out of Super Stat Chips.", 3)
                end
            else
                local statCode = string.match(mode, "Single (%u+)") or "DMG"
                if HasInventoryItem("StatChip", 1) then
                    r:FireServer("Single", uuid, statCode)
                else
                    State.AutoStatReroll = false
                    Notify("Stat Reroll Stopped", "Out of Stat Chips.", 3)
                end
            end
            task.wait(0.4)
        end

        if State.AutoOpenCapsules then
            pcall(OpenAllCapsules)
            task.wait(1.5)
        end
        task.wait(0.4)
    end
end)

-- Loop 5: Progression, Shops, Exploration, Events, Mail & Rewards
task.spawn(function()
    while Alive do
        if State.AutoRebirth then
            local r = GetRemote("NWAction")
            local nw = GetNWState()
            local pdata = GetPlayerData()
            local gems = pdata and pdata.ClientData and tonumber(pdata.ClientData.Gems) or 0
            local cost = nw and tonumber(nw.RebirthCost) or math.huge
            if r and gems >= cost then r:FireServer({ type = "Rebirth" }) end
        end

        if State.AutoBuyUpgrades then
            local r = GetRemote("NWAction")
            local nw = GetNWState()
            local pdata = GetPlayerData()
            local gems = (pdata and pdata.ClientData and tonumber(pdata.ClientData.Gems)) or 0
            local yen = tonumber(LP:GetAttribute("Yen")) or (pdata and pdata.ClientData and tonumber(pdata.ClientData.Yen)) or 0
            if r and nw and type(nw.Upgrades) == "table" then
                local didBuy = false
                for _, upg in ipairs(nw.Upgrades) do
                    if not State.AutoBuyUpgrades then break end
                    if type(upg) == "table" and upg.key then
                        local lvl = tonumber(upg.level or upg.lvl) or 0
                        local mx = tonumber(upg.max) or 1
                        local cost = tonumber(upg.cost) or 0
                        local usesYen = (upg.storyMap ~= nil)
                        local bal = usesYen and yen or gems
                        if lvl < mx and (cost <= 0 or bal >= cost) then
                            r:FireServer({ type = "BuyUpgrade", key = upg.key })
                            if usesYen then yen = yen - cost else gems = gems - cost end
                            didBuy = true
                            task.wait(0.08)
                        end
                    end
                end
                if didBuy then r:FireServer({ type = "Sync" }) end
            end
        end

        if State.AutoGoldShop then
            local r = GetRemote("NWGoldShop")
            local okG, res = TimedInvoke(r, 2.5, { op = "Get" })
            if okG and type(res) == "table" and type(res.items) == "table" then
                local bal = tonumber(res.balance) or tonumber(LP:GetAttribute("Yen")) or 0
                for _, it in ipairs(res.items) do
                    if not State.AutoGoldShop then break end
                    local left = tonumber(it.left)
                    if left == nil then left = tonumber(it.stock) or 0 end
                    local price = tonumber(it.price) or math.huge
                    if type(it) == "table" and it.key and left > 0 and it.owned ~= true and it.lvLocked ~= true and bal >= price then
                        TimedInvoke(r, 2.5, { op = "Buy", key = it.key, qty = 1 })
                        bal = bal - price
                        task.wait(0.12)
                    end
                end
            end
        end

        if State.AutoGemShop then
            local r = GetRemote("NWGemUnitShop")
            local okG, res = TimedInvoke(r, 2.5, { op = "Get" })
            if okG and type(res) == "table" and type(res.items) == "table" then
                local pdata = GetPlayerData()
                local gems = (pdata and pdata.ClientData and tonumber(pdata.ClientData.Gems)) or tonumber(res.balance) or 0
                for _, it in ipairs(res.items) do
                    if not State.AutoGemShop then break end
                    local left = tonumber(it.left)
                    if left == nil then left = tonumber(it.stock) or 0 end
                    local price = tonumber(it.price) or math.huge
                    if type(it) == "table" and it.key and left > 0 and it.owned ~= true and it.lvLocked ~= true and gems >= price then
                        TimedInvoke(r, 2.5, { op = "Buy", key = it.key, qty = 1 })
                        gems = gems - price
                        task.wait(0.12)
                    end
                end
            end
        end

        if State.AutoExploration then pcall(RunAutoExploration) end

        if State.AutoClaimHwPortals then
            local r = GetRemote("NWHwPortal")
            local okP, res = TimedInvoke(r, 2.5, "state")
            if okP and type(res) == "table" and type(res.state) == "table" and (tonumber(res.state.FreeLeft) or 0) > 0 then
                TimedInvoke(r, 2.5, "claim")
            end
        end

        if State.AutoBuyHwTree then
            local r = GetRemote("NWHwTree")
            local okT, res = TimedInvoke(r, 2.5, "state")
            if okT and type(res) == "table" and type(res.Upgrades) == "table" then
                for _, node in ipairs(res.Upgrades) do
                    if not State.AutoBuyHwTree then break end
                    local lvl = tonumber(node.level) or 0
                    local mx = tonumber(node.max) or 1
                    if node.key and lvl < mx then
                        local nextCost = type(node.costs) == "table" and tonumber(node.costs[lvl + 1]) or math.huge
                        local haveCur = type(res.have) == "table" and tonumber(res.have[node.cur]) or 0
                        if haveCur >= nextCost then
                            TimedInvoke(r, 2.5, "buy", node.key)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end

        if State.AutoWishFountain then
            local okW = pcall(RunAutoWishOnce)
            if not okW then task.wait(2) end
        end

        if State.AutoSoulDodge then
            local r = GetRemote("NWSoulDodge")
            local okS, st = TimedInvoke(r, 2.0, "start")
            if okS and type(st) == "table" and st.ok and st.token then
                local waitDur = math.clamp(tonumber(st.dur) or 30, 5, 60)
                local t0 = os.clock()
                while Alive and State.AutoSoulDodge and (os.clock() - t0) < (waitDur + 0.3) do
                    task.wait(0.5)
                end
                if State.AutoSoulDodge then
                    TimedInvoke(r, 2.5, "finish", st.token, true)
                end
            end
        end

        if State.AutoGurrenMine then
            local mineRem = GetRemote("NWGMineEv")
            local rocks = Services.Workspace:FindFirstChild("NW_GMineRocks")
            if mineRem and rocks then
                for _, rock in ipairs(rocks:GetChildren()) do
                    if not State.AutoGurrenMine then break end
                    if not rock:IsA("Sound") and (rock:IsA("Model") or rock:IsA("BasePart")) then
                        local rid = rock:GetAttribute("Id") or rock:GetAttribute("RockId") or rock.Name
                        pcall(function() mineRem:FireServer("h", rid) end)
                        task.wait(0.15)
                    end
                end
            end
        end

        if State.AutoHwGhosts and fireproximityprompt then
            local island = Services.Workspace:FindFirstChild("NW_HalloweenIsland")
            local ghosts = island and island:FindFirstChild("NW_HwGhosts")
            if ghosts then
                for _, g in ipairs(ghosts:GetDescendants()) do
                    if not State.AutoHwGhosts then break end
                    if g:IsA("ProximityPrompt") and g.Enabled then
                        pcall(fireproximityprompt, g)
                        task.wait(0.25)
                    end
                end
            end
        end

        if State.AutoClaimRewards then pcall(ClaimAllAvailableRewards, true) end
        if State.AutoClaimMail and (tonumber(LP:GetAttribute("NWMailBadge")) or 0) > 0 then
            pcall(ClaimAllMailRewards)
        end

        task.wait(2.0)
    end
end)

-- Register Cleanup Hook
if getgenv then
    getgenv().XLunaHUB_Cleanup = function()
        Alive = false
        for k, v in pairs(State) do
            if type(v) == "boolean" then
                State[k] = false
            end
        end
        for _, conn in ipairs(Connections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(Connections)
        pcall(function() Window:Destroy() end)
        local roots = { Services.CoreGui }
        pcall(function()
            local rg = Services.CoreGui:FindFirstChild("RobloxGui")
            if rg then table.insert(roots, rg) end
        end)
        pcall(function() table.insert(roots, LP:FindFirstChild("PlayerGui")) end)
        if gethui then pcall(function() table.insert(roots, gethui()) end) end
        for _, root in ipairs(roots) do
            if typeof(root) == "Instance" then
                for _, c in ipairs(root:GetChildren()) do
                    if c:IsA("ScreenGui") and string.find(c.Name, "WindUI") then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
    end
end

RestoreIdentity()
Window:SelectTab(1)
task.delay(0.8, function()
    if Alive then
        local nwA = GetRemote("NWAction")
        if nwA then nwA:FireServer({ type = "Sync" }) end
        task.wait(0.25)
        shopOpts, shopItemMap = GetShopItemsForSource(State.SelectedShopSource)
        State.SelectedShopItem = shopOpts[1] or ""
        pcall(function() ShopItemDropdown:Refresh(shopOpts) end)
    end
end)
Notify("XLunaHUB v2 Loaded", "All systems ready & defaulted OFF. Toggle UI anytime with LeftCTRL.", 4)
