-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
-- [ZEEDEVENT] Digital Quest: Digimon Worlds | Master Autonomous Suite
-- Framework: WindUI | Author: By XLunaHUB

if getgenv().DQ_MasterCleanup then
    pcall(getgenv().DQ_MasterCleanup)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================================
-- 1. GAME MODULES & REMOTE REFERENCES
-- ============================================================================
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 15)
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts", 15)

local function safeRequire(name)
    local mod = ModuleScripts and ModuleScripts:FindFirstChild(name)
    if mod then
        local ok, res = pcall(require, mod)
        if ok then return res end
    end
    return nil
end

local QuestData = safeRequire("QuestData") or {}
local MapConfig = safeRequire("MapConfig") or {}
local ZeedEventConfig = safeRequire("ZeedEventConfig") or {}
local IncubatorConfig = safeRequire("IncubatorConfig") or {}
local PetHatching = safeRequire("PetHatching") or {}
local EvolutionConfig = safeRequire("EvolutionConfig") or {}
local CloneConfig = safeRequire("CloneConfig") or {}
local HuntConfig = safeRequire("HuntConfig") or {}
local CodeConfig = safeRequire("CodeConfig") or {}
local LootBoxConfig = safeRequire("LootBoxConfig") or {}
local SkillLevelConfig = safeRequire("SkillLevelConfig") or {}
local TerraShopConfig = safeRequire("TerraShopConfig") or {}

local Remotes = {
    EnemyClick = RemoteEvents and RemoteEvents:FindFirstChild("EnemyClickEvent"),
    PetCommand = RemoteEvents and RemoteEvents:FindFirstChild("PetCommandEvent"),
    HotbarSummon = RemoteEvents and RemoteEvents:FindFirstChild("HotbarSummon"),
    EquipRequest = RemoteEvents and RemoteEvents:FindFirstChild("EquipRequestEvent"),
    UnequipRequest = RemoteEvents and RemoteEvents:FindFirstChild("UnequipRequestEvent"),
    RideToggle = RemoteEvents and RemoteEvents:FindFirstChild("RideToggle"),
    Special1 = RemoteEvents and RemoteEvents:FindFirstChild("SpecialAttackEvent"),
    Special2 = RemoteEvents and RemoteEvents:FindFirstChild("SpecialAttackEvent2"),
    Special3 = RemoteEvents and RemoteEvents:FindFirstChild("SpecialAttackEvent3"),
    Special4 = RemoteEvents and RemoteEvents:FindFirstChild("SpecialAttackEvent4"),
    QuestAction = RemoteEvents and RemoteEvents:FindFirstChild("QuestAction"),
    DailyAction = RemoteEvents and RemoteEvents:FindFirstChild("DailyAction"),
    BonusAction = RemoteEvents and RemoteEvents:FindFirstChild("BonusAction"),
    AchievementAction = RemoteEvents and RemoteEvents:FindFirstChild("AchievementAction"),
    HuntAction = RemoteEvents and RemoteEvents:FindFirstChild("HuntAction"),
    BattlePassAction = RemoteEvents and RemoteEvents:FindFirstChild("BattlePassAction"),
    ServiceAction = RemoteEvents and RemoteEvents:FindFirstChild("ServiceAction"),
    IncubatorAction = RemoteEvents and RemoteEvents:FindFirstChild("IncubatorAction"),
    TransferEggForData = RemoteEvents and RemoteEvents:FindFirstChild("TransferEggForData"),
    EvolutionAction = RemoteEvents and RemoteEvents:FindFirstChild("EvolutionAction"),
    DigimonJob = RemoteEvents and RemoteEvents:FindFirstChild("DigimonJob"),
    SealAction = RemoteEvents and RemoteEvents:FindFirstChild("SealAction"),
    MailAction = ReplicatedStorage:FindFirstChild("MailAction"),
    TravelRequest = ReplicatedStorage:FindFirstChild("TravelRequest"),
    ColosseumAction = ReplicatedStorage:FindFirstChild("ColosseumAction"),
    ZhuqiaoAction = ReplicatedStorage:FindFirstChild("ZhuqiaoAction")
}

-- ============================================================================
-- 2. DEFAULT STATE (100% ALL OFF AT STARTUP)
-- ============================================================================
local DefaultState = {
    -- Master & Combat
    MasterGrinder = false,
    AutoFarmEnemies = false,
    TargetSpecies = "All",
    PrioritizeElites = false,
    PrioritizeBosses = false,
    FarmPositionMode = "Behind", -- "Behind", "Above", "Front", "Orbit"
    FarmDistance = 16,
    FarmHeight = 14,
    AutoSummonPartner = false,
    SummonSlot = 1,
    AutoAttackTarget = false,
    AutoSkills = false,
    UseSkill1 = true,
    UseSkill2 = true,
    UseSkill3 = true,
    UseSkill4 = true,
    SyncNativeAutoCombat = false,

    -- Quests & Events
    AutoQuest = false,
    QuestMode = "Auto Best Repeatable", -- "Auto Best Repeatable", "Auto Story Progression", "Selected Quest"
    SelectedQuestId = "AgumonQuest",
    AutoZeedContract = false,
    SelectedZeedMap = "Plains",
    AutoZeedBuyBox = false,
    AutoJoinGuildBoss = false,
    AutoColosseumReplay = false,
    AutoColosseumWaves = false,
    AutoColosseumSkip = false,

    -- Digimon & Progression
    AutoConvertEggs = false,
    ConvertEggType = "All Hatchable Eggs",
    KeepEggReserve = 2,
    AutoIncubator = false,
    IncubatorEggType = "FireDigiEgg",
    IncubatorFocus = "None",
    IncubatorTargetLevel = 3,
    IncubatorRaiseTier = "Low",
    IncubatorUseProtect = false,
    IncubatorDiscardDuplicates = false,
    AutoUnlockEvolutions = false,
    SelectedPetForAction = "Agumon",
    SelectedEvoForm = "Greymon",
    AutoTrainPet = false,
    TrainStat = "Attack",
    TrainDataType = "FireData",
    AutoClonePet = false,
    CloneStat = "Attack",
    CloneAutoBuy = false,
    CloneUseBackup = false,
    AutoDigimonJobs = false,

    -- Rewards, Shop & Bag
    AutoClaimAllRewards = false,
    AutoClaimDaily = false,
    AutoClaimMissions = false,
    AutoClaimPlaytime = false,
    AutoClaimAchievements = false,
    AutoClaimHunts = false,
    AutoClaimPasses = false,
    AutoClaimMail = false,
    AutoOpenLootBoxes = false,
    SelectedLootBox = "All Boxes",
    AutoUseBoosters = false,
    AutoExchangeSeals = false,
    SealExchangeTarget = "Agumon",
    AutoRedeemSealTickets = false,
    AutoSkillDigicode = false,

    -- Player, Visuals & World
    EspEnemies = false,
    EspBossesOnly = false,
    EspNpcs = false,
    EspPlayers = false,
    EnableWalkSpeed = false,
    WalkSpeed = 45,
    EnableJumpPower = false,
    JumpPower = 80,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 65,
    AutoRidePartner = false,
    Fullbright = false,
    CustomFOV = false,
    FOVValue = 80,

    -- System
    AntiAFK = false
}

local State = {}
for k, v in pairs(DefaultState) do
    State[k] = v
end

getgenv().DQ_State = State

local Connections = {}
local Controls = {}
local Unloaded = false
local IsUpdatingUI = false
local OrbitAngle = 0

-- Original Lighting Backup
local OrigLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

-- ============================================================================
-- 3. HELPER & GAMEPLAY AUDIT FUNCTIONS
-- ============================================================================
local function getCharacter()
    local char = LocalPlayer.Character
    if char and char.Parent then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            return char, hrp, hum
        end
    end
    return nil, nil, nil
end

local function getActivePartner()
    local pp = Workspace:FindFirstChild("PlayersPets")
    local myFolder = pp and pp:FindFirstChild(LocalPlayer.Name)
    if myFolder then
        return myFolder:FindFirstChildOfClass("Model")
    end
    return nil
end

local function getPartnerCombatTarget()
    local pet = getActivePartner()
    if pet then
        local ct = pet:FindFirstChild("CombatTarget")
        if ct and ct:IsA("ObjectValue") and ct.Value and ct.Value.Parent then
            local hum = ct.Value:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health > 0 then
                return ct.Value
            end
        end
    end
    return nil
end

local function getBestPartnerLevel()
    local best = 1
    local pets = LocalPlayer:FindFirstChild("Pets")
    if pets then
        for _, p in ipairs(pets:GetChildren()) do
            local lv = tonumber(p:GetAttribute("Level")) or 1
            if lv > best then best = lv end
        end
    end
    return best
end

local function getOwnedPetNames()
    local list = {}
    local pets = LocalPlayer:FindFirstChild("Pets")
    if pets then
        for _, p in ipairs(pets:GetChildren()) do
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    if #list == 0 then table.insert(list, "Agumon") end
    return list
end

local function getEnemySpecies(enemyModel)
    if not enemyModel then return "" end
    local sp = enemyModel:GetAttribute("Species")
    if type(sp) == "string" and sp ~= "" then return sp end
    return (tostring(enemyModel.Name):gsub("%d+$", ""))
end

local function isEnemyAlive(enemyModel)
    if not enemyModel or not enemyModel.Parent then return false end
    local hrp = enemyModel:FindFirstChild("HumanoidRootPart") or enemyModel.PrimaryPart
    if not hrp then return false end
    local hum = enemyModel:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true, hrp, hum
end

local function isBossOrRaid(species)
    if HuntConfig and HuntConfig.IsBoss then
        local ok, res = pcall(HuntConfig.IsBoss, species)
        if ok and res then return true end
    end
    local s = tostring(species):lower()
    if s:find("omnimon") or s:find("kimeramon") or s:find("lillithmon") or s:find("belphemon")
        or s:find("leviamon") or s:find("metalseadramon") or s:find("armageddemon")
        or s:find("gallantmon") or s:find("barbamon") or s:find("lucemon")
        or s:find("ordinemon") or s:find("daemon") or s:find("shakkoumon") then
        return true
    end
    return false
end

local function getDistinctEnemySpecies()
    local seen = {}
    local list = {"All"}
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, e in ipairs(enemies:GetChildren()) do
            if e:IsA("Model") then
                local sp = getEnemySpecies(e)
                if sp ~= "" and not seen[sp] then
                    seen[sp] = true
                    table.insert(list, sp)
                end
            end
        end
    end
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:match("Spawns$") and folder.Name ~= "ExtraSpawns" then
            local sp = folder.Name:gsub("Spawns$", "")
            if sp ~= "" and not seen[sp] then
                seen[sp] = true
                table.insert(list, sp)
            end
        end
    end
    table.sort(list, function(a, b)
        if a == "All" then return true end
        if b == "All" then return false end
        return a < b
    end)
    return list
end

local function getSpawnCenter(species)
    if not species or species == "" or species == "All" then return nil end
    local folder = Workspace:FindFirstChild(species .. "Spawns")
    if not folder then return nil end
    local sum = Vector3.zero
    local count = 0
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("BasePart") then
            sum = sum + d.Position
            count = count + 1
            if count >= 16 then break end
        end
    end
    if count > 0 then
        return sum / count
    end
    return nil
end

local function findNearestEnemy(speciesFilter)
    local _, myHrp = getCharacter()
    local myPos = myHrp and myHrp.Position or Vector3.zero
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil, nil end

    local bestEnemy, bestHrp = nil, nil
    local bestScore = math.huge

    for _, e in ipairs(enemies:GetChildren()) do
        if e:IsA("Model") then
            local alive, eHrp = isEnemyAlive(e)
            if alive and eHrp then
                local sp = getEnemySpecies(e)
                local match = false
                if not speciesFilter or speciesFilter == "" or speciesFilter == "All" then
                    match = true
                elseif QuestData and QuestData.SameSpecies then
                    local ok, same = pcall(QuestData.SameSpecies, sp, speciesFilter)
                    match = (ok and same) or (sp:lower() == speciesFilter:lower())
                else
                    match = (sp:lower() == speciesFilter:lower())
                end

                if match then
                    local dist = (eHrp.Position - myPos).Magnitude
                    local score = dist
                    if State.PrioritizeElites and (e:GetAttribute("Elite") == true or e:FindFirstChild("EliteHighlight", true)) then
                        score = score - 5000
                    end
                    if State.PrioritizeBosses and (isBossOrRaid(sp) or e:GetAttribute("Boss") == true) then
                        score = score - 3000
                    end
                    if score < bestScore then
                        bestScore = score
                        bestEnemy = e
                        bestHrp = eHrp
                    end
                end
            end
        end
    end

    return bestEnemy, bestHrp
end

local function teleportCharacterTo(targetPos, lookAtPos)
    local char, hrp = getCharacter()
    if not char or not hrp or not targetPos then return false end
    local cf
    if lookAtPos then
        local flatLook = Vector3.new(lookAtPos.X, targetPos.Y, lookAtPos.Z)
        if (flatLook - targetPos).Magnitude > 0.05 then
            cf = CFrame.lookAt(targetPos, flatLook)
        elseif (lookAtPos - targetPos).Magnitude > 0.05 then
            cf = CFrame.new(targetPos)
        else
            cf = CFrame.new(targetPos)
        end
    else
        cf = CFrame.new(targetPos)
    end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function positionNearEnemy(eHrp)
    if not eHrp or not eHrp.Parent then return end
    local eCF = eHrp.CFrame
    local ePos = eCF.Position
    local dist = tonumber(State.FarmDistance) or 16
    local height = tonumber(State.FarmHeight) or 14
    local mode = State.FarmPositionMode or "Behind"
    local targetPos

    if mode == "Above" then
        targetPos = ePos + Vector3.new(0, height, 0)
    elseif mode == "Front" then
        targetPos = (eCF * CFrame.new(0, 2, -dist)).Position
    elseif mode == "Orbit" then
        OrbitAngle = (OrbitAngle + 0.18) % (math.pi * 2)
        targetPos = ePos + Vector3.new(math.cos(OrbitAngle) * dist, 3, math.sin(OrbitAngle) * dist)
    else -- "Behind"
        targetPos = (eCF * CFrame.new(0, 2, dist)).Position
    end

    teleportCharacterTo(targetPos, ePos)
end

-- ============================================================================
-- 4. QUEST & EVENT RESOLUTION ENGINE
-- ============================================================================
local function getLocalNpcSet()
    local set = {}
    local npcsFolder = Workspace:FindFirstChild("NPC's")
    if npcsFolder then
        for _, m in ipairs(npcsFolder:GetChildren()) do
            set[m.Name] = m
        end
    end
    return set
end

local function getQuestDropdownList()
    local list = {}
    local order = QuestData.Order or {}
    for _, qId in ipairs(order) do
        local q = QuestData[qId]
        if type(q) == "table" then
            local minLv = (QuestData.MinLevelOf and QuestData.MinLevelOf(q)) or q.MinLevel or 1
            local tag = q.Story and "[STORY]" or "[REP]"
            table.insert(list, string.format("%s | %s (Lv.%d - %s)", qId, q.Title or qId, minLv, tag))
        end
    end
    if #list == 0 then
        table.insert(list, "AgumonQuest | Agumon Hunt (Lv.0 - [REP])")
    end
    return list
end

local function parseQuestIdFromDropdown(val)
    if type(val) ~= "string" then return "AgumonQuest" end
    return val:match("^([^|]+)%s*|") and val:match("^([^|%s]+)") or val
end

local function pickBestQuestForCurrentMap()
    local localNpcs = getLocalNpcSet()
    local storyDone = LocalPlayer:GetAttribute("StoryDone") or ""
    local bestRepId, bestRepLv = nil, -1

    if State.QuestMode == "Selected Quest" then
        local qId = parseQuestIdFromDropdown(State.SelectedQuestId)
        if QuestData[qId] then return qId, QuestData[qId] end
    end

    if State.QuestMode == "Auto Story Progression" then
        for _, qId in ipairs(QuestData.Order or {}) do
            local q = QuestData[qId]
            if type(q) == "table" and q.Story and localNpcs[q.npcName] then
                local done = QuestData.HasFinished and QuestData.HasFinished(storyDone, qId)
                if not done then
                    local reqOk = not q.Requires or (QuestData.HasFinished and QuestData.HasFinished(storyDone, q.Requires))
                    local formOk = (not QuestData.MeetsForm or QuestData.MeetsForm(LocalPlayer, q))
                        and (not QuestData.MeetsForms or QuestData.MeetsForms(LocalPlayer, q))
                    local myLv = (QuestData.LevelOf and QuestData.LevelOf(LocalPlayer, q)) or getBestPartnerLevel()
                    local minLv = (QuestData.MinLevelOf and QuestData.MinLevelOf(q)) or 1
                    if reqOk and formOk and myLv >= minLv then
                        return qId, q
                    end
                end
            end
        end
    end

    -- Fallback / "Auto Best Repeatable"
    for _, qId in ipairs(QuestData.Order or {}) do
        local q = QuestData[qId]
        if type(q) == "table" and not q.Story and not q.Line and localNpcs[q.npcName] then
            local myLv = (QuestData.LevelOf and QuestData.LevelOf(LocalPlayer, q)) or getBestPartnerLevel()
            local minLv = (QuestData.MinLevelOf and QuestData.MinLevelOf(q)) or 0
            local targetSp = (QuestData.TargetOf and QuestData.TargetOf(q)) or q.enemyName or ""
            -- Ensure target enemy exists on this map (either alive or has spawn folder)
            local hasTargetHere = (Workspace:FindFirstChild(targetSp .. "Spawns") ~= nil) or (findNearestEnemy(targetSp) ~= nil)
            if myLv >= minLv and hasTargetHere and minLv >= bestRepLv then
                bestRepLv = minLv
                bestRepId = qId
            end
        end
    end

    if bestRepId then
        return bestRepId, QuestData[bestRepId]
    end
    return "AgumonQuest", QuestData["AgumonQuest"]
end

local LastQuestInvoke = 0
local function stepAutoQuest()
    if os.clock() - LastQuestInvoke < 1.2 then return nil end
    local curId = LocalPlayer:GetAttribute("CurrentQuestId")
    local curComp = LocalPlayer:GetAttribute("QuestCompleted") == true
    local desiredId, desiredQ = pickBestQuestForCurrentMap()

    if not curId or curId == "" then
        if desiredId and Remotes.QuestAction then
            LastQuestInvoke = os.clock()
            pcall(function()
                Remotes.QuestAction:InvokeServer("Start", desiredId)
            end)
        end
    else
        local activeQ = QuestData[curId]
        if curComp then
            LastQuestInvoke = os.clock()
            if activeQ and activeQ.Story then
                -- Story quests finish automatically or need abandon/next quest
                if desiredId and desiredId ~= curId then
                    pcall(function()
                        Remotes.QuestAction:InvokeServer("Start", desiredId)
                    end)
                else
                    pcall(function()
                        Remotes.QuestAction:InvokeServer("Abandon", nil)
                    end)
                end
            else
                -- Repeatable quest completed: repeat or switch to better quest
                local nextId = (State.QuestMode == "Selected Quest" and desiredId) or desiredId or curId
                pcall(function()
                    Remotes.QuestAction:InvokeServer("Start", nextId)
                end)
            end
        elseif State.QuestMode == "Selected Quest" and desiredId and curId ~= desiredId then
            LastQuestInvoke = os.clock()
            pcall(function()
                Remotes.QuestAction:InvokeServer("Abandon", nil)
                Remotes.QuestAction:InvokeServer("Start", desiredId)
            end)
        end
    end

    local activeId = LocalPlayer:GetAttribute("CurrentQuestId")
    local q = activeId and QuestData[activeId]
    if q and not (LocalPlayer:GetAttribute("QuestCompleted") == true) then
        return (QuestData.TargetOf and QuestData.TargetOf(q)) or q.enemyName
    end
    return nil
end

-- Zeed Event Parser
local function getZeedState()
    local raw = LocalPlayer:GetAttribute("ZeedEvent")
    if type(raw) == "string" and raw ~= "" then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(data) == "table" then return data end
    end
    return nil
end

local LastZeedInvoke = 0
local function stepAutoZeed()
    if not Remotes.ServiceAction then return nil end
    local zState = getZeedState()
    local mapId = State.SelectedZeedMap or (MapConfig.Current and MapConfig.Current()) or "Plains"
    local questSpec = ZeedEventConfig.Quest and ZeedEventConfig.Quest(mapId)

    if os.clock() - LastZeedInvoke >= 2.5 then
        if not zState then
            LastZeedInvoke = os.clock()
            pcall(function() Remotes.ServiceAction:InvokeServer("ZeedInfo") end)
            zState = getZeedState()
        end

        if zState then
            local activeId = zState.a or ""
            if activeId == "" then
                LastZeedInvoke = os.clock()
                pcall(function() Remotes.ServiceAction:InvokeServer("ZeedAccept", mapId) end)
            else
                local activeSpec = ZeedEventConfig.Quest and ZeedEventConfig.Quest(activeId)
                if activeSpec and type(activeSpec.Goals) == "table" then
                    local allDone = true
                    local prog = type(zState.p) == "table" and zState.p or {}
                    for _, g in ipairs(activeSpec.Goals) do
                        if (tonumber(prog[g.Enemy]) or 0) < g.Need then
                            allDone = false
                            break
                        end
                    end
                    if allDone then
                        LastZeedInvoke = os.clock()
                        pcall(function() Remotes.ServiceAction:InvokeServer("ZeedClaim", activeId) end)
                    end
                end
            end

            if State.AutoZeedBuyBox and (tonumber(zState.coins) or 0) >= 1 and (tonumber(zState.b) or 0) < (ZeedEventConfig.BoxDaily or 5) then
                LastZeedInvoke = os.clock()
                pcall(function() Remotes.ServiceAction:InvokeServer("ZeedBuy", "Box", 1) end)
            end
        end
    end

    zState = getZeedState()
    if zState and type(zState.a) == "string" and zState.a ~= "" then
        local activeSpec = ZeedEventConfig.Quest and ZeedEventConfig.Quest(zState.a)
        if activeSpec and type(activeSpec.Goals) == "table" then
            local prog = type(zState.p) == "table" and zState.p or {}
            for _, g in ipairs(activeSpec.Goals) do
                if (tonumber(prog[g.Enemy]) or 0) < g.Need then
                    return g.Enemy
                end
            end
        end
    end
    return nil
end

-- ============================================================================
-- 5. COMBAT, SUMMON & SKILL AUTOMATION ENGINE
-- ============================================================================
local LastSummonAttempt = 0
local LastAttackAttempt = 0
local LastSkillAttempt = {0, 0, 0, 0}

local function ensurePartnerSummoned()
    local activePet = getActivePartner()
    if activePet then return activePet end
    if os.clock() - LastSummonAttempt < 1.2 then return nil end
    LastSummonAttempt = os.clock()

    local slot = tonumber(State.SummonSlot) or 1
    if Remotes.HotbarSummon then
        pcall(function() Remotes.HotbarSummon:FireServer(slot) end)
    end
    return getActivePartner()
end

local function castReadySkills()
    local target = getPartnerCombatTarget()
    if not target then return end
    local nowServer = Workspace:GetServerTimeNow()
    local nowClock = os.clock()

    local slots = {
        {enabled = State.UseSkill1, attr = "SkillReadyAt_Special1", remote = Remotes.Special1},
        {enabled = State.UseSkill2, attr = "SkillReadyAt_Special2", remote = Remotes.Special2},
        {enabled = State.UseSkill3, attr = "SkillReadyAt_Special3", remote = Remotes.Special3},
        {enabled = State.UseSkill4, attr = "SkillReadyAt_Special4", remote = Remotes.Special4}
    }

    for idx, s in ipairs(slots) do
        if s.enabled and s.remote and (nowClock - LastSkillAttempt[idx] >= 0.45) then
            local readyAt = tonumber(LocalPlayer:GetAttribute(s.attr)) or 0
            if nowServer >= readyAt then
                LastSkillAttempt[idx] = nowClock
                pcall(function() s.remote:FireServer() end)
            end
        end
    end
end

local function stepCombatAndFarm()
    local master = State.MasterGrinder
    local doSummon = master or State.AutoSummonPartner
    local doQuest = master or State.AutoQuest
    local doZeed = State.AutoZeedContract
    local doFarm = master or State.AutoFarmEnemies
    local doAttack = master or doFarm or State.AutoAttackTarget
    local doSkills = master or State.AutoSkills

    if doSummon then
        ensurePartnerSummoned()
    end

    local questTargetSpecies = nil
    if doQuest then
        questTargetSpecies = stepAutoQuest()
    end

    local zeedTargetSpecies = nil
    if doZeed then
        zeedTargetSpecies = stepAutoZeed()
    end

    local targetSpecies = State.TargetSpecies
    if master or (doQuest and targetSpecies == "All") then
        if questTargetSpecies and questTargetSpecies ~= "" then
            targetSpecies = questTargetSpecies
        elseif zeedTargetSpecies and zeedTargetSpecies ~= "" then
            targetSpecies = zeedTargetSpecies
        end
    elseif doZeed and targetSpecies == "All" and zeedTargetSpecies then
        targetSpecies = zeedTargetSpecies
    end

    -- Check if partner is already fighting a valid target
    local currentTarget = getPartnerCombatTarget()
    local targetEnemy, targetHrp = nil, nil

    if currentTarget then
        local alive, hrp = isEnemyAlive(currentTarget)
        if alive and hrp then
            local sp = getEnemySpecies(currentTarget)
            local match = false
            if not targetSpecies or targetSpecies == "All" then
                match = true
            elseif QuestData and QuestData.SameSpecies then
                local ok, same = pcall(QuestData.SameSpecies, sp, targetSpecies)
                match = (ok and same) or (sp:lower() == targetSpecies:lower())
            else
                match = (sp:lower() == targetSpecies:lower())
            end
            if match then
                targetEnemy = currentTarget
                targetHrp = hrp
            end
        end
    end

    if not targetEnemy then
        targetEnemy, targetHrp = findNearestEnemy(targetSpecies)
    end

    if targetEnemy and targetHrp then
        local activePet = getActivePartner()

        if doFarm then
            positionNearEnemy(targetHrp)

            -- INSTANT PARTNER TELEPORTSYNC:
            -- If partner is >28 studs away from the target enemy, pull partner via PetCommand('follow')
            -- so client regains PetDrive network ownership, PivotTo next to the enemy, and immediately attack!
            if activePet then
                local petRoot = activePet.PrimaryPart or activePet:FindFirstChild("HumanoidRootPart")
                if petRoot and (petRoot.Position - targetHrp.Position).Magnitude > 28 then
                    if activePet:GetAttribute("PetDrive") ~= LocalPlayer.UserId and Remotes.PetCommand then
                        pcall(function() Remotes.PetCommand:FireServer("follow") end)
                        task.wait(0.18)
                    end
                    if activePet.Parent and targetHrp.Parent then
                        pcall(function()
                            activePet:PivotTo(targetHrp.CFrame * CFrame.new(0, 1.5, 5))
                            if petRoot then
                                petRoot.AssemblyLinearVelocity = Vector3.zero
                                petRoot.AssemblyAngularVelocity = Vector3.zero
                            end
                        end)
                        task.wait(0.08)
                        LastAttackAttempt = 0
                    end
                end
            end
        end

        if doAttack and Remotes.EnemyClick then
            local _, myHrp = getCharacter()
            local dist = myHrp and (targetHrp.Position - myHrp.Position).Magnitude or 999
            if dist <= 165 and (getPartnerCombatTarget() ~= targetEnemy or (os.clock() - LastAttackAttempt >= 0.65)) then
                LastAttackAttempt = os.clock()
                pcall(function() Remotes.EnemyClick:FireServer(targetEnemy) end)
            end
        end
    elseif doFarm and targetSpecies and targetSpecies ~= "All" then
        local spawnCenter = getSpawnCenter(targetSpecies)
        if spawnCenter then
            local _, myHrp = getCharacter()
            if myHrp and (myHrp.Position - spawnCenter).Magnitude > 35 then
                teleportCharacterTo(spawnCenter + Vector3.new(0, 6, 0))
            end
        end
    end

    if doSkills then
        castReadySkills()
    end
end

-- ============================================================================
-- 6. REWARDS, INCUBATOR, PROGRESSION & BAG AUTOMATION
-- ============================================================================
local LastRewardClaimPass = 0
local function claimAllRewardsPass()
    if os.clock() - LastRewardClaimPass < 2.0 then return end
    LastRewardClaimPass = os.clock()
    local all = State.AutoClaimAllRewards

    if (all or State.AutoClaimDaily) and Remotes.DailyAction then
        pcall(function()
            local st = Remotes.DailyAction:InvokeServer("Status")
            if type(st) == "table" and st.data and st.data.Claimed == false then
                task.wait(0.35)
                Remotes.DailyAction:InvokeServer("Claim")
            end
        end)
        task.wait(0.4)
    end

    if (all or State.AutoClaimMissions) and Remotes.BonusAction then
        pcall(function() Remotes.BonusAction:InvokeServer("ClaimAllMissions") end)
        task.wait(0.45)
    end

    if (all or State.AutoClaimPlaytime) and Remotes.BonusAction then
        pcall(function() Remotes.BonusAction:InvokeServer("ClaimAllPlaytime") end)
        task.wait(0.45)
    end

    if (all or State.AutoClaimAchievements) and Remotes.AchievementAction then
        pcall(function() Remotes.AchievementAction:InvokeServer("ClaimAll") end)
        task.wait(0.45)
    end

    if (all or State.AutoClaimHunts) and Remotes.HuntAction then
        pcall(function()
            if (tonumber(LocalPlayer:GetAttribute("HuntReady")) or 0) > 0 then
                Remotes.HuntAction:InvokeServer("ClaimAll")
            end
        end)
        task.wait(0.45)
    end

    if (all or State.AutoClaimPasses) then
        if Remotes.BattlePassAction then
            pcall(function() Remotes.BattlePassAction:InvokeServer("ClaimAll") end)
            task.wait(0.45)
        end
        if Remotes.ColosseumAction then
            pcall(function() Remotes.ColosseumAction:InvokeServer("PassClaimAll") end)
            task.wait(0.45)
            pcall(function() Remotes.ColosseumAction:InvokeServer("HardPassClaimAll") end)
            task.wait(0.45)
        end
        if Remotes.ZhuqiaoAction then
            pcall(function() Remotes.ZhuqiaoAction:InvokeServer("ClaimAll") end)
            task.wait(0.45)
        end
    end

    if (all or State.AutoClaimMail) and Remotes.MailAction then
        pcall(function() Remotes.MailAction:InvokeServer("ClaimAll") end)
    end
end

local function redeemAllKnownCodes()
    if not Remotes.ServiceAction then return 0 end
    local count = 0
    local codes = (CodeConfig and CodeConfig.Codes) or {
        ["100discord"] = true,
        ["200discord"] = true,
        ["100concurrent"] = true
    }
    for code, _ in pairs(codes) do
        pcall(function()
            Remotes.ServiceAction:InvokeServer("RedeemCode", code)
            count = count + 1
        end)
    end
    return count
end

local function stepAutoConverter()
    if not State.AutoConvertEggs or not Remotes.TransferEggForData then return end
    local eggData = LocalPlayer:FindFirstChild("EggData")
    if not eggData then return end
    local reserve = math.max(0, tonumber(State.KeepEggReserve) or 0)
    local targetType = State.ConvertEggType or "All Hatchable Eggs"

    for _, valObj in ipairs(eggData:GetChildren()) do
        if valObj:IsA("IntValue") and valObj.Name:find("Egg") then
            if targetType == "All Hatchable Eggs" or valObj.Name == targetType then
                local spare = valObj.Value - reserve
                if spare > 0 then
                    pcall(function()
                        Remotes.TransferEggForData:FireServer(valObj.Name, spare)
                    end)
                end
            end
        end
    end
end

local function stepAutoIncubator()
    if not State.AutoIncubator or not Remotes.IncubatorAction then return end
    local eggData = LocalPlayer:FindFirstChild("EggData")
    if not eggData then return end

    local selected = eggData:FindFirstChild("Selected") and eggData.Selected.Value or ""
    local selectedLv = eggData:FindFirstChild("SelectedLevel") and eggData.SelectedLevel.Value or 0
    local pendingHatch = eggData:GetAttribute("PendingHatch")
    local currentFocus = eggData:FindFirstChild("HatchFocus") and eggData.HatchFocus.Value or ""

    if type(pendingHatch) == "string" and pendingHatch ~= "" then
        local pets = LocalPlayer:FindFirstChild("Pets")
        local alreadyOwned = pets and (pets:FindFirstChild(pendingHatch) ~= nil)
        if State.IncubatorDiscardDuplicates and alreadyOwned then
            pcall(function() Remotes.IncubatorAction:InvokeServer("Discard") end)
        else
            pcall(function() Remotes.IncubatorAction:InvokeServer("Hatch") end)
        end
        return
    end

    if selected == "" then
        local eggName = State.IncubatorEggType or "FireDigiEgg"
        local eggObj = eggData:FindFirstChild(eggName)
        if eggObj and eggObj:IsA("IntValue") and eggObj.Value > 0 then
            pcall(function() Remotes.IncubatorAction:InvokeServer("Select", eggName) end)
        end
        return
    end

    if State.IncubatorFocus and State.IncubatorFocus ~= "None" and State.IncubatorFocus ~= "" and currentFocus ~= State.IncubatorFocus then
        pcall(function() Remotes.IncubatorAction:InvokeServer("Focus", State.IncubatorFocus) end)
    end

    local dispLv = (IncubatorConfig.DisplayLevel and IncubatorConfig.DisplayLevel(selected, selectedLv)) or selectedLv
    local targetLv = math.clamp(tonumber(State.IncubatorTargetLevel) or 3, 3, 5)

    if dispLv >= targetLv or (IncubatorConfig.IsLocked and IncubatorConfig.IsLocked(selected, selectedLv)) then
        pcall(function() Remotes.IncubatorAction:InvokeServer("Preview") end)
    else
        local tier = State.IncubatorRaiseTier or "Low"
        if selectedLv < 2 and (tier == "Mid" or tier == "High") then
            tier = "Low"
        end
        pcall(function()
            Remotes.IncubatorAction:InvokeServer("Raise", {
                Tier = tier,
                Protect = State.IncubatorUseProtect == true
            })
        end)
    end
end

local function stepAutoDigimonProgression()
    local pets = LocalPlayer:FindFirstChild("Pets")
    if not pets then return end

    -- 1. Auto 1-Hour Digimon Jobs
    if State.AutoDigimonJobs and Remotes.DigimonJob then
        pcall(function() Remotes.DigimonJob:InvokeServer("Check") end)
        local now = Workspace:GetServerTimeNow()
        for _, p in ipairs(pets:GetChildren()) do
            if p:GetAttribute("HotbarSlot") == nil then
                local untilTime = tonumber(p:GetAttribute("JobUntil")) or 0
                if untilTime <= now then
                    pcall(function() Remotes.DigimonJob:InvokeServer("Send", p.Name) end)
                end
            end
        end
    end

    -- 2. Auto Unlock Evolutions
    if State.AutoUnlockEvolutions and Remotes.EvolutionAction and EvolutionConfig.GetTree then
        local eggData = LocalPlayer:FindFirstChild("EggData")
        local evoluters = eggData and eggData:FindFirstChild("Evoluter") and eggData.Evoluter.Value or 0
        if evoluters > 0 then
            for _, p in ipairs(pets:GetChildren()) do
                local baseName = p:GetAttribute("OriginalForm") or p.Name
                local tree = EvolutionConfig.GetTree(baseName)
                local pLv = tonumber(p:GetAttribute("Level")) or 1
                local unlockedStr = tostring(p:GetAttribute("UnlockedForms") or "")
                if tree and type(tree.Nodes) == "table" then
                    for _, node in ipairs(tree.Nodes) do
                        if not node.ComingSoon and pLv >= (node.Level or 1) and not unlockedStr:find(node.Form, 1, true) then
                            if evoluters >= (node.Cost or 1) then
                                pcall(function()
                                    Remotes.EvolutionAction:InvokeServer("Unlock", p.Name, node.Form)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    -- 3. Auto Train Selected Pet
    if State.AutoTrainPet and Remotes.ServiceAction then
        local petName = State.SelectedPetForAction or "Agumon"
        local stat = State.TrainStat or "Attack"
        local dType = State.TrainDataType or "FireData"
        local eggData = LocalPlayer:FindFirstChild("EggData")
        local dCount = eggData and eggData:FindFirstChild(dType) and eggData[dType].Value or 0
        if dCount >= 1000 then
            pcall(function()
                Remotes.ServiceAction:InvokeServer("Train", petName, stat, dType)
            end)
        end
    end

    -- 4. Auto Clone Selected Pet
    if State.AutoClonePet and Remotes.ServiceAction then
        local petName = State.SelectedPetForAction or "Agumon"
        local stat = State.CloneStat or "Attack"
        if State.CloneAutoBuy then
            for _, cItem in ipairs({"CloneD", "CloneC", "CloneB", "CloneA"}) do
                local eggData = LocalPlayer:FindFirstChild("EggData")
                local cnt = eggData and eggData:FindFirstChild(cItem) and eggData[cItem].Value or 0
                if cnt <= 0 then
                    pcall(function() Remotes.ServiceAction:InvokeServer("Buy", cItem) end)
                end
            end
        end
        pcall(function()
            Remotes.ServiceAction:InvokeServer("Clone", petName, stat, State.CloneUseBackup == true)
        end)
    end
end

local function stepAutoBagAndSeals()
    local eggData = LocalPlayer:FindFirstChild("EggData")
    if not eggData then return end

    if State.AutoOpenLootBoxes and Remotes.ServiceAction then
        local boxes = (LootBoxConfig and LootBoxConfig.Boxes) or {TreasureBox = true, AncientBox = true}
        for boxName, _ in pairs(boxes) do
            if State.SelectedLootBox == "All Boxes" or State.SelectedLootBox == boxName then
                local bObj = eggData:FindFirstChild(boxName)
                if bObj and bObj:IsA("IntValue") and bObj.Value > 0 then
                    local amt = math.min(bObj.Value, (LootBoxConfig and LootBoxConfig.MaxOpenAtOnce) or 25)
                    pcall(function()
                        Remotes.ServiceAction:InvokeServer("OpenBox", boxName, amt)
                    end)
                end
            end
        end
    end

    if State.AutoUseBoosters and Remotes.ServiceAction then
        local activeBoostEnd = tonumber(LocalPlayer:GetAttribute("BoosterEndsAt")) or 0
        if Workspace:GetServerTimeNow() >= activeBoostEnd then
            for _, item in ipairs(eggData:GetChildren()) do
                if item:IsA("IntValue") and item.Value > 0 and item.Name:find("Booster") then
                    pcall(function()
                        Remotes.ServiceAction:InvokeServer("UseBooster", item.Name)
                    end)
                    break
                end
            end
        end
    end

    if State.AutoRedeemSealTickets and Remotes.SealAction then
        local tObj = eggData:FindFirstChild("SealExchangeTicket")
        if tObj and tObj:IsA("IntValue") and tObj.Value > 0 then
            pcall(function()
                Remotes.SealAction:InvokeServer("Redeem", State.SealExchangeTarget or "Agumon", "Max")
            end)
        end
    end

    if State.AutoExchangeSeals and Remotes.SealAction then
        local rawOverflow = LocalPlayer:GetAttribute("SealOverflow")
        if type(rawOverflow) == "string" and rawOverflow ~= "" then
            for sp, cntStr in string.gmatch(rawOverflow, "([%w_]+):(%d+)") do
                local cnt = tonumber(cntStr) or 0
                if cnt >= 10 and sp ~= (State.SealExchangeTarget or "Agumon") then
                    pcall(function()
                        Remotes.SealAction:InvokeServer("Exchange", sp, State.SealExchangeTarget or "Agumon", "Max")
                    end)
                end
            end
        end
    end

    if State.AutoSkillDigicode and Remotes.ServiceAction then
        local petName = State.SelectedPetForAction or "Agumon"
        for _, item in ipairs(eggData:GetChildren()) do
            if item:IsA("IntValue") and item.Value > 0 and item.Name:find("Code%d+$") then
                for _, slot in ipairs({"Special1", "Special2", "Special3", "Special4"}) do
                    pcall(function()
                        Remotes.ServiceAction:InvokeServer("SkillUseCode", petName, slot, item.Name)
                    end)
                end
            end
        end
    end
end

-- ============================================================================
-- 7. STEALTH ESP ENGINE
-- ============================================================================
local EspContainer = Instance.new("Folder")
EspContainer.Name = "DQ_VisualOverlay"
pcall(function()
    local parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    EspContainer.Parent = parent
end)

local EspCache = {}

local function clearAllEsp()
    for k, v in pairs(EspCache) do
        if v.Billboard then pcall(function() v.Billboard:Destroy() end) end
        if v.Highlight then pcall(function() v.Highlight:Destroy() end) end
    end
    table.clear(EspCache)
end

local function createOrUpdateEsp(targetModel, category, labelText, color)
    if not targetModel or not targetModel.Parent then return end
    local entry = EspCache[targetModel]
    local adornee = targetModel:FindFirstChild("HumanoidRootPart") or targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then return end

    if not entry then
        local bb = Instance.new("BillboardGui")
        bb.Name = "DQ_ESP_BB"
        bb.Adornee = adornee
        bb.Size = UDim2.fromOffset(180, 36)
        bb.StudsOffset = Vector3.new(0, 4.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = EspContainer

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextStrokeTransparency = 0.2
        lbl.TextColor3 = color
        lbl.Text = labelText
        lbl.Parent = bb

        local hl = Instance.new("Highlight")
        hl.Name = "DQ_ESP_HL"
        hl.Adornee = targetModel
        hl.FillColor = color
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.FillTransparency = 0.65
        hl.OutlineTransparency = 0.15
        hl.Parent = EspContainer

        entry = {Billboard = bb, Label = lbl, Highlight = hl, Category = category}
        EspCache[targetModel] = entry
    else
        entry.Billboard.Adornee = adornee
        entry.Label.Text = labelText
        entry.Label.TextColor3 = color
        entry.Highlight.FillColor = color
    end
end

local function stepEsp()
    local anyEsp = State.EspEnemies or State.EspNpcs or State.EspPlayers
    if not anyEsp then
        if next(EspCache) ~= nil then clearAllEsp() end
        return
    end

    local _, myHrp = getCharacter()
    local myPos = myHrp and myHrp.Position or Vector3.zero
    local activeTargets = {}

    if State.EspEnemies then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, e in ipairs(enemies:GetChildren()) do
                if e:IsA("Model") then
                    local alive, hrp, hum = isEnemyAlive(e)
                    if alive and hrp then
                        local sp = getEnemySpecies(e)
                        local isBoss = isBossOrRaid(sp) or e:GetAttribute("Boss") == true
                        local isElite = e:GetAttribute("Elite") == true
                        if not State.EspBossesOnly or isBoss or isElite then
                            activeTargets[e] = true
                            local lv = tonumber(e:GetAttribute("Level")) or 1
                            local hp = hum and math.floor(hum.Health) or 0
                            local dist = math.floor((hrp.Position - myPos).Magnitude)
                            local tag = isBoss and "[BOSS] " or (isElite and "[ELITE] " or "")
                            local col = isBoss and Color3.fromRGB(255, 75, 75) or (isElite and Color3.fromRGB(255, 215, 50) or Color3.fromRGB(90, 210, 255))
                            createOrUpdateEsp(e, "Enemy", string.format("%s%s [Lv.%d]\nHP: %d | %dm", tag, sp, lv, hp, dist), col)
                        end
                    end
                end
            end
        end
    end

    if State.EspNpcs then
        local npcs = Workspace:FindFirstChild("NPC's")
        if npcs then
            for _, n in ipairs(npcs:GetChildren()) do
                if n:IsA("Model") then
                    local p = n:FindFirstChild("HumanoidRootPart") or n.PrimaryPart or n:FindFirstChildWhichIsA("BasePart", true)
                    if p then
                        activeTargets[n] = true
                        local dist = math.floor((p.Position - myPos).Magnitude)
                        createOrUpdateEsp(n, "NPC", string.format("[NPC] %s (%dm)", n.Name, dist), Color3.fromRGB(120, 255, 140))
                    end
                end
            end
        end
    end

    if State.EspPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    activeTargets[plr.Character] = true
                    local dist = math.floor((hrp.Position - myPos).Magnitude)
                    local lv = tonumber(plr:GetAttribute("Level")) or 1
                    createOrUpdateEsp(plr.Character, "Player", string.format("%s [Tamer Lv.%d] (%dm)", plr.Name, lv, dist), Color3.fromRGB(255, 165, 255))
                end
            end
        end
    end

    for model, entry in pairs(EspCache) do
        if not activeTargets[model] or not model.Parent then
            if entry.Billboard then pcall(function() entry.Billboard:Destroy() end) end
            if entry.Highlight then pcall(function() entry.Highlight:Destroy() end) end
            EspCache[model] = nil
        end
    end
end

-- ============================================================================
-- 8. MOVEMENT, FLY, NOCLIP & WORLD UTILITY
-- ============================================================================
local FlyBV, FlyBG = nil, nil

local function cleanupFly()
    if FlyBV then pcall(function() FlyBV:Destroy() end) FlyBV = nil end
    if FlyBG then pcall(function() FlyBG:Destroy() end) FlyBG = nil end
end

local function applyFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(175, 175, 175)
    else
        Lighting.Brightness = OrigLighting.Brightness
        Lighting.ClockTime = OrigLighting.ClockTime
        Lighting.FogEnd = OrigLighting.FogEnd
        Lighting.GlobalShadows = OrigLighting.GlobalShadows
        Lighting.Ambient = OrigLighting.Ambient
    end
end

local function applyNativeCombatSettings(enabled)
    LocalPlayer:SetAttribute("Setting_AutoLock", enabled)
    LocalPlayer:SetAttribute("Setting_AutoBattle", enabled)
    LocalPlayer:SetAttribute("Setting_AutoSkill", enabled)
    LocalPlayer:SetAttribute("Setting_AutoRetryQuest", enabled)
end

-- ============================================================================
-- 9. WINDUI INITIALIZATION & FLOATING BUTTON / KEYBIND
-- ============================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Digital Quest: Digimon Worlds",
    Icon = "cpu",
    Author = "By XLunaHUB",
    Folder = "XLunaHUB_DigitalQuest",
    Size = UDim2.fromOffset(650, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 185,
    HasOutline = true
    -- NOTE: Do NOT pass ToggleKey here while also binding LeftControl or WindUI + custom listener will double-toggle.
    -- We bind a single debounced LeftControl handler below that cleanly calls Window:Toggle().
})

Window:EditOpenButton({
    Title = "XLunaHUB | Digital Quest",
    Icon = "cpu",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("3B82F6"), Color3.fromHex("F59E0B")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true
})

-- Clean Single Toggle Keybind (LeftControl) â guarantees SHOW or HIDE without double-firing
local LastToggleTime = 0
Connections.KeybindToggle = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Unloaded then return end
    if gameProcessed or UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        if os.clock() - LastToggleTime < 0.25 then return end
        LastToggleTime = os.clock()
        pcall(function()
            Window:Toggle()
        end)
    end
end)

local function registerControl(key, ctrl)
    Controls[key] = ctrl
    return ctrl
end

-- ============================================================================
-- 10. UI TABS & CONTROLS
-- ============================================================================
local Tabs = {
    Combat = Window:Tab({ Title = "Auto & Combat", Icon = "swords" }),
    Quests = Window:Tab({ Title = "Quests & Events", Icon = "scroll" }),
    Digimon = Window:Tab({ Title = "Digimon & Lab", Icon = "sparkles" }),
    Rewards = Window:Tab({ Title = "Rewards & Bag", Icon = "gift" }),
    Teleport = Window:Tab({ Title = "Teleports", Icon = "map-pin" }),
    Visuals = Window:Tab({ Title = "Player & ESP", Icon = "eye" }),
    Config = Window:Tab({ Title = "Config & System", Icon = "settings" })
}

-- ----------------------------------------------------------------------------
-- TAB 1: AUTO & COMBAT ("LIAR" FULL AUTOMATION)
-- ----------------------------------------------------------------------------
Tabs.Combat:Section({ Title = "Master Autonomous Grinder (Full Auto)" })

registerControl("MasterGrinder", Tabs.Combat:Toggle({
    Title = "Master Autonomous Grinder (All-In-One)",
    Desc = "Automatically summons partner, picks & repeats best local quest, teleports to quest targets, attacks & casts skills.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.MasterGrinder = v
    end
}))

Tabs.Combat:Section({ Title = "Auto Farm Enemies & Positioning" })

registerControl("AutoFarmEnemies", Tabs.Combat:Toggle({
    Title = "Auto Farm Enemies (Teleport & Attack)",
    Desc = "Positions your character near the target enemy (within attack lock range) and commands your partner to attack.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoFarmEnemies = v
    end
}))

local SpeciesDropdown = registerControl("TargetSpecies", Tabs.Combat:Dropdown({
    Title = "Target Enemy Species",
    Desc = "Select 'All' or a specific Digimon species on the current map.",
    Values = getDistinctEnemySpecies(),
    Value = "All",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.TargetSpecies = v or "All"
    end
}))

Tabs.Combat:Button({
    Title = "Refresh Map Enemy Species List",
    Desc = "Re-scans Workspace.Enemies and Spawn folders for available Digimon species.",
    Callback = function()
        local list = getDistinctEnemySpecies()
        pcall(function() SpeciesDropdown:Refresh(list) end)
        WindUI:Notify({ Title = "Species Refreshed", Content = string.format("Found %d species entries.", #list), Duration = 2 })
    end
})

registerControl("PrioritizeElites", Tabs.Combat:Toggle({
    Title = "Prioritize Elite Enemies (Gold Glow)",
    Desc = "Targets Elite enemies first for weekly/daily bounties and bonus drops.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.PrioritizeElites = v
    end
}))

registerControl("PrioritizeBosses", Tabs.Combat:Toggle({
    Title = "Prioritize Bosses & Raids",
    Desc = "Targets Boss and Raid Digimon first when farming.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.PrioritizeBosses = v
    end
}))

registerControl("FarmPositionMode", Tabs.Combat:Dropdown({
    Title = "Farm Positioning Mode",
    Values = { "Behind", "Above", "Front", "Orbit" },
    Value = "Behind",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.FarmPositionMode = v or "Behind"
    end
}))

registerControl("FarmDistance", Tabs.Combat:Slider({
    Title = "Farm Horizontal Distance (Studs)",
    Desc = "Must stay under 90 studs for battle targeting lock.",
    Step = 1,
    Value = { Min = 6, Max = 60, Default = 16 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.FarmDistance = tonumber(v) or 16
    end
}))

registerControl("FarmHeight", Tabs.Combat:Slider({
    Title = "Farm Above Height (Studs)",
    Step = 1,
    Value = { Min = 5, Max = 45, Default = 14 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.FarmHeight = tonumber(v) or 14
    end
}))

Tabs.Combat:Section({ Title = "Partner Summon & Skill Casting" })

registerControl("AutoSummonPartner", Tabs.Combat:Toggle({
    Title = "Auto Summon Partner Digimon",
    Desc = "Automatically keeps your partner Digimon summoned from the selected hotbar slot.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoSummonPartner = v
    end
}))

registerControl("SummonSlot", Tabs.Combat:Dropdown({
    Title = "Hotbar Slot to Summon",
    Values = { "1", "2", "3" },
    Value = "1",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SummonSlot = tonumber(v) or 1
    end
}))

registerControl("AutoAttackTarget", Tabs.Combat:Toggle({
    Title = "Auto Command Partner Attack (No Teleport)",
    Desc = "Commands partner to attack the nearest matching enemy within range without moving your character.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoAttackTarget = v
    end
}))

registerControl("AutoSkills", Tabs.Combat:Toggle({
    Title = "Auto Cast Partner Skills (1-4)",
    Desc = "Fires SpecialAttackEvent 1-4 the instant cooldowns finish while partner is in battle.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoSkills = v
    end
}))

registerControl("UseSkill1", Tabs.Combat:Toggle({
    Title = "Use Skill 1",
    Value = true,
    Callback = function(v) if not IsUpdatingUI then State.UseSkill1 = v end end
}))

registerControl("UseSkill2", Tabs.Combat:Toggle({
    Title = "Use Skill 2",
    Value = true,
    Callback = function(v) if not IsUpdatingUI then State.UseSkill2 = v end end
}))

registerControl("UseSkill3", Tabs.Combat:Toggle({
    Title = "Use Skill 3 (Jogress / Burst)",
    Value = true,
    Callback = function(v) if not IsUpdatingUI then State.UseSkill3 = v end end
}))

registerControl("UseSkill4", Tabs.Combat:Toggle({
    Title = "Use Skill 4 (Lillithmon)",
    Value = true,
    Callback = function(v) if not IsUpdatingUI then State.UseSkill4 = v end end
}))

registerControl("SyncNativeAutoCombat", Tabs.Combat:Toggle({
    Title = "Enable Native Game Auto-Lock / Auto-Battle / Auto-Skill",
    Desc = "Toggles the game's built-in Setting_AutoLock, Setting_AutoBattle, Setting_AutoSkill, and Setting_AutoRetryQuest attributes.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SyncNativeAutoCombat = v
        applyNativeCombatSettings(v)
    end
}))

-- ----------------------------------------------------------------------------
-- TAB 2: QUESTS & EVENTS
-- ----------------------------------------------------------------------------
Tabs.Quests:Section({ Title = "Remote Quest Automation" })

registerControl("AutoQuest", Tabs.Quests:Toggle({
    Title = "Auto Accept & Repeat Quests",
    Desc = "Starts and repeats quests remotely via QuestAction without walking back to NPCs.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoQuest = v
    end
}))

registerControl("QuestMode", Tabs.Quests:Dropdown({
    Title = "Quest Selection Mode",
    Values = { "Auto Best Repeatable", "Auto Story Progression", "Selected Quest" },
    Value = "Auto Best Repeatable",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.QuestMode = v or "Auto Best Repeatable"
    end
}))

local QuestListValues = getQuestDropdownList()
registerControl("SelectedQuestId", Tabs.Quests:Dropdown({
    Title = "Specific Quest (When Mode = Selected Quest)",
    Values = QuestListValues,
    Value = QuestListValues[1],
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SelectedQuestId = parseQuestIdFromDropdown(v)
    end
}))

Tabs.Quests:Button({
    Title = "Force Start Selected Quest Now",
    Desc = "Invokes QuestAction('Start', questId) immediately.",
    Callback = function()
        local qId = parseQuestIdFromDropdown(State.SelectedQuestId)
        if Remotes.QuestAction then
            local ok, res = pcall(function()
                return Remotes.QuestAction:InvokeServer("Start", qId)
            end)
            local msg = (ok and type(res) == "table" and res.message) or tostring(res)
            WindUI:Notify({ Title = "Quest Action", Content = msg ~= "" and msg or ("Requested: " .. qId), Duration = 3 })
        end
    end
})

Tabs.Quests:Button({
    Title = "Abandon Current Quest",
    Desc = "Invokes QuestAction('Abandon') immediately.",
    Callback = function()
        if Remotes.QuestAction then
            pcall(function() Remotes.QuestAction:InvokeServer("Abandon", nil) end)
            WindUI:Notify({ Title = "Quest Abandoned", Content = "Abandoned active quest.", Duration = 2 })
        end
    end
})

Tabs.Quests:Section({ Title = "Zeed Event Automation" })

registerControl("AutoZeedContract", Tabs.Quests:Toggle({
    Title = "Auto Accept & Claim Zeed Contracts",
    Desc = "Automatically accepts the Zeed Event contract for the chosen map, tracks targets, and claims Zeed Coins on completion.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoZeedContract = v
    end
}))

registerControl("SelectedZeedMap", Tabs.Quests:Dropdown({
    Title = "Zeed Contract Map",
    Values = { "Plains", "IceCaps", "Beach", "XForest", "Pyramid", "Graveyard" },
    Value = "Plains",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SelectedZeedMap = v or "Plains"
    end
}))

registerControl("AutoZeedBuyBox", Tabs.Quests:Toggle({
    Title = "Auto Buy Daily Zeed Boxes (1 Coin)",
    Desc = "Automatically buys up to 5 daily Fragmented Zeed Boxes whenever you have Zeed Coins.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoZeedBuyBox = v
    end
}))

Tabs.Quests:Section({ Title = "Colosseum, Raids & Trials" })

registerControl("AutoJoinGuildBoss", Tabs.Quests:Toggle({
    Title = "Auto Join Guild Boss Calls",
    Desc = "Automatically invokes GuildBossGo when a guild boss rally is active.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoJoinGuildBoss = v
    end
}))

registerControl("AutoColosseumWaves", Tabs.Quests:Toggle({
    Title = "Auto Start Colosseum Waves",
    Desc = "Enables Setting_AutoStartWave so Colosseum waves start automatically.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoColosseumWaves = v
        LocalPlayer:SetAttribute("Setting_AutoStartWave", v)
    end
}))

registerControl("AutoColosseumReplay", Tabs.Quests:Toggle({
    Title = "Auto Replay Colosseum Runs",
    Desc = "Toggles ColosseumAction('AutoReplay', true).",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoColosseumReplay = v
        if Remotes.ColosseumAction then
            pcall(function() Remotes.ColosseumAction:InvokeServer("AutoReplay", v) end)
        end
    end
}))

Tabs.Quests:Button({
    Title = "Start Wave Trial (Must Be Near Trial Master)",
    Callback = function()
        if Remotes.ServiceAction then
            local ok, res = pcall(function() return Remotes.ServiceAction:InvokeServer("Trial") end)
            WindUI:Notify({ Title = "Wave Trial", Content = (ok and type(res) == "table" and res.message) or "Sent Trial request.", Duration = 3 })
        end
    end
})

Tabs.Quests:Button({
    Title = "Enter / Exit Timed Rift (Near Rift Gate)",
    Callback = function()
        if Remotes.ServiceAction then
            local ok, info = pcall(function() return Remotes.ServiceAction:InvokeServer("RiftInfo") end)
            local act = (ok and type(info) == "table" and info.active) and "RiftExit" or "RiftEnter"
            local ok2, res = pcall(function() return Remotes.ServiceAction:InvokeServer(act, false) end)
            WindUI:Notify({ Title = "Timed Rift", Content = (ok2 and type(res) == "table" and res.message) or ("Invoked " .. act), Duration = 3 })
        end
    end
})

-- ----------------------------------------------------------------------------
-- TAB 3: DIGIMON & LAB (INCUBATOR, CONVERTER, EVOLVE, CLONE, TRAIN, JOBS)
-- ----------------------------------------------------------------------------
Tabs.Digimon:Section({ Title = "Remote Egg-to-Data Converter (Anywhere)" })

registerControl("AutoConvertEggs", Tabs.Digimon:Toggle({
    Title = "Auto Convert Spare Eggs to Data",
    Desc = "Fires TransferEggForData remotely from anywhere to convert spare eggs into 10x DigiData.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoConvertEggs = v
    end
}))

local EggTypesList = {
    "All Hatchable Eggs",
    "FireDigiEgg",
    "AquaticDigiEgg",
    "BeastDigiEgg",
    "DragonDigiEgg",
    "DevilDigiEgg",
    "PlantDigiEgg",
    "InsectDigiEgg"
}

registerControl("ConvertEggType", Tabs.Digimon:Dropdown({
    Title = "Egg Type to Convert",
    Values = EggTypesList,
    Value = "All Hatchable Eggs",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.ConvertEggType = v or "All Hatchable Eggs"
    end
}))

registerControl("KeepEggReserve", Tabs.Digimon:Slider({
    Title = "Keep Egg Reserve Count",
    Desc = "Only converts eggs above this count so you don't run out.",
    Step = 1,
    Value = { Min = 0, Max = 50, Default = 2 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.KeepEggReserve = tonumber(v) or 2
    end
}))

Tabs.Digimon:Button({
    Title = "Convert 1 Selected Egg Now",
    Callback = function()
        local eggName = State.ConvertEggType
        if eggName == "All Hatchable Eggs" then eggName = "FireDigiEgg" end
        if Remotes.TransferEggForData then
            Remotes.TransferEggForData:FireServer(eggName, 1)
            WindUI:Notify({ Title = "Data Converter", Content = "Converted 1x " .. eggName .. " into 10x Data.", Duration = 2 })
        end
    end
})

Tabs.Digimon:Section({ Title = "Auto Incubator & Hatching" })

registerControl("AutoIncubator", Tabs.Digimon:Toggle({
    Title = "Auto Incubator (Place, Raise & Hatch)",
    Desc = "Automatically places eggs, raises egg level to target, and confirms hatch.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoIncubator = v
    end
}))

registerControl("IncubatorEggType", Tabs.Digimon:Dropdown({
    Title = "Egg to Incubate",
    Values = {
        "FireDigiEgg", "AquaticDigiEgg", "BeastDigiEgg", "DragonDigiEgg",
        "DevilDigiEgg", "PlantDigiEgg", "InsectDigiEgg",
        "MysteriousMagicEgg", "MysteriousRareEgg", "MysteriousTopQualityEgg",
        "GazimonMillLevel5Egg", "AgumonMillLevel5Egg", "BelphemonSleepLevel5Egg"
    },
    Value = "FireDigiEgg",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.IncubatorEggType = v or "FireDigiEgg"
    end
}))

registerControl("IncubatorTargetLevel", Tabs.Digimon:Slider({
    Title = "Target Hatch Egg Level (3 to 5)",
    Step = 1,
    Value = { Min = 3, Max = 5, Default = 3 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.IncubatorTargetLevel = tonumber(v) or 3
    end
}))

registerControl("IncubatorRaiseTier", Tabs.Digimon:Dropdown({
    Title = "Data Injection Tier (At Lv.2+)",
    Values = { "Low", "Mid", "High" },
    Value = "Low",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.IncubatorRaiseTier = v or "Low"
    end
}))

registerControl("IncubatorUseProtect", Tabs.Digimon:Toggle({
    Title = "Use Terra Protection on Raise",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.IncubatorUseProtect = v
    end
}))

registerControl("IncubatorDiscardDuplicates", Tabs.Digimon:Toggle({
    Title = "Auto Discard Already-Owned Digimon",
    Desc = "Prevents overwriting leveled Digimon with a fresh Lv.1 duplicate.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.IncubatorDiscardDuplicates = v
    end
}))

Tabs.Digimon:Section({ Title = "Digivolution, Jobs, Training & Cloning" })

registerControl("AutoDigimonJobs", Tabs.Digimon:Toggle({
    Title = "Auto 1-Hour Digimon Expeditions (Jobs)",
    Desc = "Automatically claims finished expeditions and sends all unslotted Digimon on 1-hour jobs.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoDigimonJobs = v
    end
}))

registerControl("AutoUnlockEvolutions", Tabs.Digimon:Toggle({
    Title = "Auto Unlock Available Evolutions",
    Desc = "Automatically unlocks evolution forms for your Digimon when level and Evoluter requirements are met.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoUnlockEvolutions = v
    end
}))

local OwnedPetsDropdown = registerControl("SelectedPetForAction", Tabs.Digimon:Dropdown({
    Title = "Select Owned Digimon",
    Values = getOwnedPetNames(),
    Value = getOwnedPetNames()[1],
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SelectedPetForAction = v or "Agumon"
    end
}))

Tabs.Digimon:Button({
    Title = "Refresh Owned Digimon List",
    Callback = function()
        local list = getOwnedPetNames()
        pcall(function() OwnedPetsDropdown:Refresh(list) end)
    end
})

registerControl("SelectedEvoForm", Tabs.Digimon:Input({
    Title = "Target Evolution Form Name",
    Desc = "e.g., Greymon, MetalGreymon, WarGreymon, Omnimon (or base name to revert).",
    Value = "Greymon",
    Placeholder = "Greymon",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SelectedEvoForm = v
    end
}))

Tabs.Digimon:Button({
    Title = "Digivolve Selected Digimon Now",
    Callback = function()
        if Remotes.EvolutionAction then
            local petName = State.SelectedPetForAction or "Agumon"
            local form = State.SelectedEvoForm or "Greymon"
            local ok, res = pcall(function()
                return Remotes.EvolutionAction:InvokeServer("Digivolve", petName, form)
            end)
            WindUI:Notify({ Title = "Digivolve", Content = (ok and type(res) == "table" and res.message) or ("Requested " .. form), Duration = 3 })
        end
    end
})

registerControl("AutoTrainPet", Tabs.Digimon:Toggle({
    Title = "Auto Train Selected Digimon (+1% to +5%)",
    Desc = "Spends 1,000 Data per step to train the selected stat.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoTrainPet = v
    end
}))

registerControl("TrainStat", Tabs.Digimon:Dropdown({
    Title = "Stat to Train / Clone",
    Values = { "Attack", "Defence", "HP" },
    Value = "Attack",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.TrainStat = v or "Attack"
        State.CloneStat = v or "Attack"
    end
}))

registerControl("TrainDataType", Tabs.Digimon:Dropdown({
    Title = "Data Type for Training",
    Values = { "FireData", "AquaticData", "BeastData", "DragonData", "DevilData", "PlantData", "InsectData" },
    Value = "FireData",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.TrainDataType = v or "FireData"
    end
}))

registerControl("AutoClonePet", Tabs.Digimon:Toggle({
    Title = "Auto DigiClone Selected Digimon",
    Desc = "Automatically applies DigiClones to the selected Digimon and stat.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoClonePet = v
    end
}))

registerControl("CloneAutoBuy", Tabs.Digimon:Toggle({
    Title = "Auto Buy Clones (D / C / B / A)",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.CloneAutoBuy = v end end
}))

registerControl("CloneUseBackup", Tabs.Digimon:Toggle({
    Title = "Use Backup Disk When Cloning",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.CloneUseBackup = v end end
}))

-- ----------------------------------------------------------------------------
-- TAB 4: REWARDS, SHOP & BAG
-- ----------------------------------------------------------------------------
Tabs.Rewards:Section({ Title = "100% Remote Auto-Claim Suite" })

registerControl("AutoClaimAllRewards", Tabs.Rewards:Toggle({
    Title = "Master Auto-Claim ALL Rewards",
    Desc = "Automatically claims Daily Login, Daily Missions, Playtime, Achievements, Hunt Bounties/Bestiary, Passes, and Mail.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoClaimAllRewards = v
        if v then task.spawn(claimAllRewardsPass) end
    end
}))

registerControl("AutoClaimDaily", Tabs.Rewards:Toggle({
    Title = "Auto Claim Daily Login Reward",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimDaily = v end end
}))

registerControl("AutoClaimMissions", Tabs.Rewards:Toggle({
    Title = "Auto Claim Daily Missions",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimMissions = v end end
}))

registerControl("AutoClaimPlaytime", Tabs.Rewards:Toggle({
    Title = "Auto Claim Playtime Rewards",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimPlaytime = v end end
}))

registerControl("AutoClaimAchievements", Tabs.Rewards:Toggle({
    Title = "Auto Claim Achievements / Goals",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimAchievements = v end end
}))

registerControl("AutoClaimHunts", Tabs.Rewards:Toggle({
    Title = "Auto Claim Hunt Bounties & Bestiary Tiers",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimHunts = v end end
}))

registerControl("AutoClaimPasses", Tabs.Rewards:Toggle({
    Title = "Auto Claim Battle / Colosseum / Zhuqiao Passes",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimPasses = v end end
}))

registerControl("AutoClaimMail", Tabs.Rewards:Toggle({
    Title = "Auto Claim All Mailbox Items",
    Value = false,
    Callback = function(v) if not IsUpdatingUI then State.AutoClaimMail = v end end
}))

Tabs.Rewards:Button({
    Title = "Redeem All Promo Codes Now",
    Desc = "Redeems all codes in CodeConfig (100discord, 200discord, 100concurrent).",
    Callback = function()
        local n = redeemAllKnownCodes()
        WindUI:Notify({ Title = "Promo Codes", Content = string.format("Attempted redemption of %d promo codes.", n), Duration = 3 })
    end
})

Tabs.Rewards:Section({ Title = "Bag, Boxes, Boosters & Seals" })

registerControl("AutoOpenLootBoxes", Tabs.Rewards:Toggle({
    Title = "Auto Open LootBoxes (Up to 25x at Once)",
    Desc = "Automatically opens Fragmented Boxes, Ancient Boxes, Burst Boxes, and Zhuqiaomon Boxes.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoOpenLootBoxes = v
    end
}))

registerControl("SelectedLootBox", Tabs.Rewards:Dropdown({
    Title = "LootBox Filter",
    Values = { "All Boxes", "TreasureBox", "AncientBox" },
    Value = "All Boxes",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SelectedLootBox = v or "All Boxes"
    end
}))

registerControl("AutoUseBoosters", Tabs.Rewards:Toggle({
    Title = "Auto Use XP Boosters When Expired",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoUseBoosters = v
    end
}))

registerControl("AutoRedeemSealTickets", Tabs.Rewards:Toggle({
    Title = "Auto Redeem Seal Exchange Tickets",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoRedeemSealTickets = v
    end
}))

registerControl("AutoExchangeSeals", Tabs.Rewards:Toggle({
    Title = "Auto Exchange Spare Seals (10:1)",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoExchangeSeals = v
    end
}))

registerControl("SealExchangeTarget", Tabs.Rewards:Input({
    Title = "Target Seal Species",
    Value = "Agumon",
    Placeholder = "Agumon",
    Callback = function(v)
        if IsUpdatingUI then return end
        State.SealExchangeTarget = v
    end
}))

registerControl("AutoSkillDigicode", Tabs.Rewards:Toggle({
    Title = "Auto Apply Skill Digicodes (Raise Cap)",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoSkillDigicode = v
    end
}))

-- ----------------------------------------------------------------------------
-- TAB 5: TELEPORTS & WORLD TRAVEL
-- ----------------------------------------------------------------------------
Tabs.Teleport:Section({ Title = "Local Map NPCs & Service Stations" })

local function getLocalTeleports()
    local map = {}
    local names = {}
    local npcs = Workspace:FindFirstChild("NPC's")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do
            local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("TalkPoint") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
            if p then
                local label = "[NPC] " .. m.Name
                map[label] = p.Position + Vector3.new(0, 3, 4)
                table.insert(names, label)
            end
        end
    end
    for _, stName in ipairs({"Incubator", "Frigimon", "XShop"}) do
        local st = Workspace:FindFirstChild(stName)
        if st then
            local p = st:IsA("BasePart") and st or st:FindFirstChildWhichIsA("BasePart", true)
            if p then
                local label = "[Service] " .. stName
                map[label] = p.Position + Vector3.new(0, 3, 4)
                table.insert(names, label)
            end
        end
    end
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:match("Spawns$") and folder.Name ~= "ExtraSpawns" then
            local sp = folder.Name:gsub("Spawns$", "")
            local center = getSpawnCenter(sp)
            if center then
                local label = "[Zone] " .. sp .. " Spawns"
                map[label] = center + Vector3.new(0, 5, 0)
                table.insert(names, label)
            end
        end
    end
    table.sort(names)
    if #names == 0 then
        names = {"[Spawn] Default"}
        map["[Spawn] Default"] = Vector3.new(70, 26, -47)
    end
    return names, map
end

local LocalTpNames, LocalTpMap = getLocalTeleports()
local SelectedLocalTp = LocalTpNames[1]

local LocalTpDropdown = Tabs.Teleport:Dropdown({
    Title = "Select Local Destination",
    Values = LocalTpNames,
    Value = LocalTpNames[1],
    Callback = function(v)
        SelectedLocalTp = v
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to Selected Local Destination",
    Callback = function()
        LocalTpNames, LocalTpMap = getLocalTeleports()
        local pos = LocalTpMap[SelectedLocalTp]
        if pos then
            teleportCharacterTo(pos)
            WindUI:Notify({ Title = "Teleported", Content = "Moved to " .. tostring(SelectedLocalTp), Duration = 2 })
        end
    end
})

Tabs.Teleport:Button({
    Title = "Refresh Local Destinations",
    Callback = function()
        LocalTpNames, LocalTpMap = getLocalTeleports()
        pcall(function() LocalTpDropdown:Refresh(LocalTpNames) end)
    end
})

Tabs.Teleport:Section({ Title = "Cross-Map World Travel (TravelRequest)" })

local WorldDestinations = {
    { Name = "Digital Plains (Lv.1)", PlaceId = 15998696145 },
    { Name = "DATS Center Hub (Tamer Lv.10)", PlaceId = 16116441002 },
    { Name = "Digital Ice Caps (Lv.30)", PlaceId = 16116498541 },
    { Name = "DATS Underground (Lv.30)", PlaceId = 119219964313348 },
    { Name = "Digital Beach (Lv.50)", PlaceId = 16304762513 },
    { Name = "X Forest (Lv.80)", PlaceId = 16456355341 },
    { Name = "Pyramid (Lv.100)", PlaceId = 107035659511988 },
    { Name = "Four Holy Beasts / Zhuqiaomon (Lv.100)", PlaceId = 135290092597922 },
    { Name = "Graveyard (Lv.135)", PlaceId = 84784646543467 }
}

local WorldNames = {}
local WorldPlaceMap = {}
for _, w in ipairs(WorldDestinations) do
    table.insert(WorldNames, w.Name)
    WorldPlaceMap[w.Name] = w.PlaceId
end
local SelectedWorldName = WorldNames[1]

Tabs.Teleport:Dropdown({
    Title = "Select World Map",
    Values = WorldNames,
    Value = WorldNames[1],
    Callback = function(v)
        SelectedWorldName = v
    end
})

Tabs.Teleport:Button({
    Title = "Travel to Selected World Map",
    Desc = "Invokes ReplicatedStorage.TravelRequest:InvokeServer(PlaceId).",
    Callback = function()
        local pid = WorldPlaceMap[SelectedWorldName]
        if pid and Remotes.TravelRequest then
            local ok, res = pcall(function()
                return Remotes.TravelRequest:InvokeServer(pid)
            end)
            local msg = (ok and type(res) == "table" and res.message) or ("Travel requested to " .. tostring(SelectedWorldName))
            WindUI:Notify({ Title = "World Travel", Content = msg, Duration = 3 })
        end
    end
})

-- ----------------------------------------------------------------------------
-- TAB 6: PLAYER & ESP
-- ----------------------------------------------------------------------------
Tabs.Visuals:Section({ Title = "ESP Visuals (Stealth Overlay)" })

registerControl("EspEnemies", Tabs.Visuals:Toggle({
    Title = "Enemy & Boss ESP",
    Desc = "Highlights enemies with Species, Level, HP, Rank ([BOSS]/[ELITE]), and distance.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.EspEnemies = v
        if not v then stepEsp() end
    end
}))

registerControl("EspBossesOnly", Tabs.Visuals:Toggle({
    Title = "Filter Enemy ESP to Bosses & Elites Only",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.EspBossesOnly = v
    end
}))

registerControl("EspNpcs", Tabs.Visuals:Toggle({
    Title = "Quest & Service NPC ESP",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.EspNpcs = v
        if not v then stepEsp() end
    end
}))

registerControl("EspPlayers", Tabs.Visuals:Toggle({
    Title = "Tamer Player ESP",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.EspPlayers = v
        if not v then stepEsp() end
    end
}))

Tabs.Visuals:Section({ Title = "Character Movement & Flight" })

registerControl("EnableWalkSpeed", Tabs.Visuals:Toggle({
    Title = "Enable Custom WalkSpeed",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.EnableWalkSpeed = v
        if not v then
            local _, _, hum = getCharacter()
            if hum then hum.WalkSpeed = 16 end
        end
    end
}))

registerControl("WalkSpeed", Tabs.Visuals:Slider({
    Title = "WalkSpeed Value",
    Step = 1,
    Value = { Min = 16, Max = 150, Default = 45 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.WalkSpeed = tonumber(v) or 45
    end
}))

registerControl("EnableJumpPower", Tabs.Visuals:Toggle({
    Title = "Enable Custom JumpPower",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.EnableJumpPower = v
        if not v then
            local _, _, hum = getCharacter()
            if hum then hum.JumpPower = 50 end
        end
    end
}))

registerControl("JumpPower", Tabs.Visuals:Slider({
    Title = "JumpPower Value",
    Step = 1,
    Value = { Min = 50, Max = 200, Default = 80 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.JumpPower = tonumber(v) or 80
    end
}))

registerControl("InfiniteJump", Tabs.Visuals:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.InfiniteJump = v
    end
}))

registerControl("NoClip", Tabs.Visuals:Toggle({
    Title = "NoClip (Walk Through Walls)",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.NoClip = v
    end
}))

registerControl("Fly", Tabs.Visuals:Toggle({
    Title = "Camera-Directed Flight",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.Fly = v
        if not v then cleanupFly() end
    end
}))

registerControl("FlySpeed", Tabs.Visuals:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 20, Max = 200, Default = 65 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.FlySpeed = tonumber(v) or 65
    end
}))

registerControl("AutoRidePartner", Tabs.Visuals:Toggle({
    Title = "Auto Mount / Ride Partner",
    Desc = "Automatically mounts your summoned Digimon when not riding.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AutoRidePartner = v
    end
}))

Tabs.Visuals:Section({ Title = "Camera & World Lighting" })

registerControl("Fullbright", Tabs.Visuals:Toggle({
    Title = "Fullbright (Clear Vision)",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.Fullbright = v
        applyFullbright(v)
    end
}))

registerControl("CustomFOV", Tabs.Visuals:Toggle({
    Title = "Enable Custom Camera FOV",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.CustomFOV = v
    end
}))

registerControl("FOVValue", Tabs.Visuals:Slider({
    Title = "Camera FOV",
    Step = 1,
    Value = { Min = 50, Max = 120, Default = 80 },
    Callback = function(v)
        if IsUpdatingUI then return end
        State.FOVValue = tonumber(v) or 80
    end
}))

-- ----------------------------------------------------------------------------
-- TAB 7: CONFIG & SYSTEM
-- ----------------------------------------------------------------------------
Tabs.Config:Section({ Title = "Anti-AFK & Session Protection" })

registerControl("AntiAFK", Tabs.Config:Toggle({
    Title = "Anti-AFK Protection",
    Desc = "Prevents 20-minute idle disconnect via VirtualUser & disables AfkRejoin forced teleports.",
    Value = false,
    Callback = function(v)
        if IsUpdatingUI then return end
        State.AntiAFK = v
        if v then
            LocalPlayer:SetAttribute("Setting_AutoRejoin", false)
            if getconnections then
                for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
                    if conn.Disable then pcall(function() conn:Disable() end) end
                end
            end
        end
    end
}))

Tabs.Config:Section({ Title = "Configuration Persistence" })

local ConfigFolder = "XLunaHUB_DigitalQuest_Configs"
local CurrentConfigName = "default"

local function ensureConfigFolder()
    if makefolder and isfolder and not isfolder(ConfigFolder) then
        pcall(makefolder, ConfigFolder)
    end
end

local function listSavedConfigs()
    ensureConfigFolder()
    local out = {"default"}
    if listfiles and isfolder and isfolder(ConfigFolder) then
        local ok, files = pcall(listfiles, ConfigFolder)
        if ok and type(files) == "table" then
            for _, f in ipairs(files) do
                local name = f:match("([^/\\]+)%.json$")
                if name and name ~= "default" then
                    table.insert(out, name)
                end
            end
        end
    end
    return out
end

local function applyStateToUI()
    IsUpdatingUI = true
    for k, ctrl in pairs(Controls) do
        local val = State[k]
        if val ~= nil and ctrl then
            pcall(function()
                if ctrl.Set then
                    ctrl:Set(val)
                elseif ctrl.SetValue then
                    ctrl:SetValue(val)
                end
            end)
        end
    end
    IsUpdatingUI = false
end

local function saveConfigToDisk(name)
    ensureConfigFolder()
    if not writefile then return false, "writefile not supported" end
    local path = ConfigFolder .. "/" .. (name or "default") .. ".json"
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, State)
    if not ok then return false, "JSONEncode failed" end
    local okW, errW = pcall(writefile, path, encoded)
    return okW, errW
end

local function loadConfigFromDisk(name)
    ensureConfigFolder()
    if not readfile or not isfile then return false, "readfile not supported" end
    local path = ConfigFolder .. "/" .. (name or "default") .. ".json"
    if not isfile(path) then return false, "Config file not found" end
    local okR, raw = pcall(readfile, path)
    if not okR or type(raw) ~= "string" then return false, "Failed to read file" end
    local okJ, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
    if not okJ or type(decoded) ~= "table" then return false, "Corrupt JSON" end

    for k, v in pairs(DefaultState) do
        if decoded[k] ~= nil and type(decoded[k]) == type(v) then
            State[k] = decoded[k]
        end
    end
    applyStateToUI()
    applyFullbright(State.Fullbright)
    if not State.Fly then cleanupFly() end
    return true
end

local function resetAllToDefaultOff()
    for k, v in pairs(DefaultState) do
        State[k] = v
    end
    applyStateToUI()
    cleanupFly()
    clearAllEsp()
    applyFullbright(false)
    local _, _, hum = getCharacter()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

getgenv().DQ_SaveConfig = saveConfigToDisk
getgenv().DQ_LoadConfig = loadConfigFromDisk
getgenv().DQ_ResetAll = resetAllToDefaultOff

Tabs.Config:Input({
    Title = "Config Name",
    Value = "default",
    Placeholder = "default",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            CurrentConfigName = v:gsub("[^%w_%-]", "")
        end
    end
})

local ConfigDropdown = Tabs.Config:Dropdown({
    Title = "Saved Configs",
    Values = listSavedConfigs(),
    Value = "default",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            CurrentConfigName = v
        end
    end
})

Tabs.Config:Button({
    Title = "Save Config",
    Callback = function()
        local ok, err = saveConfigToDisk(CurrentConfigName)
        pcall(function() ConfigDropdown:Refresh(listSavedConfigs()) end)
        WindUI:Notify({
            Title = ok and "Config Saved" or "Save Failed",
            Content = ok and ("Saved '" .. CurrentConfigName .. ".json'") or tostring(err),
            Duration = 3
        })
    end
})

Tabs.Config:Button({
    Title = "Load Config",
    Callback = function()
        local ok, err = loadConfigFromDisk(CurrentConfigName)
        WindUI:Notify({
            Title = ok and "Config Loaded" or "Load Failed",
            Content = ok and ("Loaded '" .. CurrentConfigName .. ".json'") or tostring(err),
            Duration = 3
        })
    end
})

Tabs.Config:Button({
    Title = "Delete Config",
    Callback = function()
        local path = ConfigFolder .. "/" .. CurrentConfigName .. ".json"
        if isfile and delfile and isfile(path) then
            pcall(delfile, path)
            pcall(function() ConfigDropdown:Refresh(listSavedConfigs()) end)
            WindUI:Notify({ Title = "Config Deleted", Content = "Deleted " .. CurrentConfigName, Duration = 2 })
        else
            WindUI:Notify({ Title = "Delete Failed", Content = "File does not exist.", Duration = 2 })
        end
    end
})

Tabs.Config:Button({
    Title = "Reset All Features to OFF",
    Desc = "Immediately disables all toggles and restores default player state.",
    Callback = function()
        resetAllToDefaultOff()
        WindUI:Notify({ Title = "All Reset", Content = "Every feature has been turned OFF.", Duration = 2 })
    end
})

Tabs.Config:Button({
    Title = "Unload Script",
    Callback = function()
        if getgenv().DQ_MasterCleanup then
            getgenv().DQ_MasterCleanup()
        end
    end
})

-- ============================================================================
-- 11. BACKGROUND RUNTIME LOOPS (GUARDED BY TOGGLE STATES)
-- ============================================================================

-- Anti-AFK Idled Hook
Connections.Idled = LocalPlayer.Idled:Connect(function()
    if Unloaded or not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end)
end)

-- Infinite Jump Hook
Connections.JumpRequest = UserInputService.JumpRequest:Connect(function()
    if Unloaded or not State.InfiniteJump then return end
    local _, _, hum = getCharacter()
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Frame-rate Stepped Loop (NoClip, WalkSpeed, JumpPower, Fly, FOV)
Connections.Stepped = RunService.Stepped:Connect(function()
    if Unloaded then return end
    local char, hrp, hum = getCharacter()
    if not char or not hrp or not hum then return end

    if State.NoClip or State.MasterGrinder or State.AutoFarmEnemies then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if State.EnableWalkSpeed then
        hum.WalkSpeed = State.WalkSpeed
    end

    if State.EnableJumpPower then
        hum.UseJumpPower = true
        hum.JumpPower = State.JumpPower
    end

    if State.CustomFOV and Camera then
        Camera.FieldOfView = State.FOVValue
    end

    if State.Fly then
        if not FlyBV or FlyBV.Parent ~= hrp then
            cleanupFly()
            FlyBV = Instance.new("BodyVelocity")
            FlyBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            FlyBV.Velocity = Vector3.zero
            FlyBV.Parent = hrp

            FlyBG = Instance.new("BodyGyro")
            FlyBG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            FlyBG.P = 9e4
            FlyBG.CFrame = hrp.CFrame
            FlyBG.Parent = hrp
        end

        local camCF = Camera and Camera.CFrame or hrp.CFrame
        local moveDir = Vector3.zero
        if not UserInputService:GetFocusedTextBox() then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * (tonumber(State.FlySpeed) or 65)
        end
        FlyBV.Velocity = moveDir
        FlyBG.CFrame = camCF
    elseif FlyBV or FlyBG then
        cleanupFly()
    end
end)

-- Fast Combat & ESP Loop (0.15s)
task.spawn(function()
    while not Unloaded do
        task.wait(0.15)
        if Unloaded then break end

        if State.MasterGrinder or State.AutoFarmEnemies or State.AutoSummonPartner
            or State.AutoAttackTarget or State.AutoSkills or State.AutoQuest or State.AutoZeedContract then
            pcall(stepCombatAndFarm)
        end

        if State.AutoRidePartner and Remotes.RideToggle then
            if getActivePartner() and LocalPlayer:GetAttribute("Riding") ~= true then
                pcall(function() Remotes.RideToggle:FireServer() end)
            end
        end

        pcall(stepEsp)
    end
end)

-- Medium Progression & Incubator Loop (1.5s)
task.spawn(function()
    while not Unloaded do
        task.wait(1.5)
        if Unloaded then break end

        if State.AutoConvertEggs then pcall(stepAutoConverter) end
        if State.AutoIncubator then pcall(stepAutoIncubator) end
        if State.AutoDigimonJobs or State.AutoUnlockEvolutions or State.AutoTrainPet or State.AutoClonePet then
            pcall(stepAutoDigimonProgression)
        end
        if State.AutoOpenLootBoxes or State.AutoUseBoosters or State.AutoRedeemSealTickets
            or State.AutoExchangeSeals or State.AutoSkillDigicode then
            pcall(stepAutoBagAndSeals)
        end
    end
end)

-- Slow Rewards & Raid Check Loop (5.0s)
task.spawn(function()
    while not Unloaded do
        task.wait(5.0)
        if Unloaded then break end

        if State.AutoClaimAllRewards or State.AutoClaimDaily or State.AutoClaimMissions
            or State.AutoClaimPlaytime or State.AutoClaimAchievements or State.AutoClaimHunts
            or State.AutoClaimPasses or State.AutoClaimMail then
            pcall(claimAllRewardsPass)
        end

        if State.AutoJoinGuildBoss and Remotes.ServiceAction then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local gbc = pg and pg:FindFirstChild("GuildBossCall")
            if gbc and gbc.Enabled then
                pcall(function() Remotes.ServiceAction:InvokeServer("GuildBossGo") end)
            end
        end
    end
end)

-- ============================================================================
-- 12. CLEANUP / UNLOAD HANDLER
-- ============================================================================
getgenv().DQ_MasterCleanup = function()
    Unloaded = true
    resetAllToDefaultOff()
    for _, conn in pairs(Connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(Connections)
    if EspContainer then
        pcall(function() EspContainer:Destroy() end)
    end
    pcall(function() Window:Destroy() end)
end

getgenv().DQ_Window = Window
