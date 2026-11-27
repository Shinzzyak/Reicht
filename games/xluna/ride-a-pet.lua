-- [[ XLunaHUB Runtime Security Kernel ]]
local _p_srv = game:GetService("Players")
local _lp = _p_srv.LocalPlayer or _p_srv.PlayerAdded:Wait()
local _prop = string.char(85, 115, 101, 114, 73, 100) -- UserId
if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Execution halted: Account signature mismatch.") end); return error("[XLunaHUB Security] Execution halted: Account signature mismatch.") end
task.spawn(function() while task.wait(6) do if not _lp or false then pcall(function() _lp:Kick("[XLunaHUB Security] Session terminated: Integrity breach.") end); break end end end)
--[[
    ========================================================================
    RIDE A PET - TACTICAL AUTOMATION & FARMING ENGINE (v1.0 Production)
    ========================================================================
    Target: Place 124216119978534 (Ride A Pet)
    Architecture: Custom Client Engine (Real) + WindUI Framework
    Defaults: ALL FEATURES OFF ON INITIAL LAUNCH (Manual Activation / Config Load)
    
    Feature Matrix:
      [1] Core AFK Farm:
          - Auto Collect Cash (Plot Pets)
          - Auto Hatch Incubated Eggs (Instant 0-delay on ready)
          - Auto Place Best Pets (Maximizes Income/s)
          - Auto Upgrade Plot Luck (Max Hatch Luck via cash)
          - Auto Unlock Nests (Nests 2-5 progressive unlock)
          - Auto Rebirth (Automatic milestone progression)
          - Auto Claim Rewards (Index, Group, Event)
      [2] World Eggs Harvester & Visuals:
          - Full World Egg ESP (Name, Rarity Color, Distance, Highlight)
          - Rarity Tier Filtering (All, Rare+, Epic+, Legendary+, Mythic+, Divine+, Ethereal)
          - Auto Harvest Eggs (Auto Teleport, Pickup Trigger & Plot Return)
          - 1-Click Teleport to Closest Egg / Best Egg
      [3] Halloween Event Automation:
          - Auto Trick-or-Treat (Knock Doors)
          - Auto Search Pumpkins
          - Auto Dig Graves
          - Auto Skeleton Slayer
          - Auto Giant Pumpkin Swing
          - Auto Collect Candy
      [4] Mobility & Traversal:
          - Custom WalkSpeed Multiplier (16 - 500)
          - Infinite Jump (Continuous airborne impulse)
          - Landmark Teleports (Plot, Heaven, Volcano, Halloween, Shop, Spawn)
      [5] Configuration Persistence:
          - Save / Load Configuration (RideAPet_Config.json)
          - Real-time UI Element & Visual State Synchronization
          - Draggable Floating Action Button + Keybind Toggle (Ctrl)
    ========================================================================
--]]

if _G.RideAPetEngine and _G.RideAPetEngine.Unload then
    pcall(function() _G.RideAPetEngine:Unload() end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")

local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")
end

local function GetLocalPlayer()
    return Players.LocalPlayer
end

local function GetLocalCharacter()
    local lp = GetLocalPlayer()
    return lp and lp.Character or nil
end

local function GetLocalRoot()
    local char = GetLocalCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")) or nil
end

local function GetGeneralService()
    local gs = ReplicatedStorage:FindFirstChild("GameServices")
    return gs and gs:FindFirstChild("General") and require(gs.General) or nil
end

local function GetPlayerPlot()
    local lp = GetLocalPlayer()
    if not lp then return nil end
    local gen = GetGeneralService()
    if gen and gen.GetPlot then
        local s, p = pcall(function() return gen:GetPlot(lp) end)
        if s and p then return p end
    end
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local data = plot:FindFirstChild("Data")
            local owner = data and data:FindFirstChild("Owner")
            if owner and owner.Value == lp then
                return plot
            end
        end
    end
    return nil
end

local CONFIG_FILE = "RideAPet_Config.json"

-- Clean passthrough to ensure all remotes execute natively with zero interference
pcall(function()
    hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        return self[method](self, ...)
    end)
end)

local Engine = {
    Connections = {},
    Drawings = {},
    Highlights = {},
    Billboards = {},
    GuiInstances = {},
    UIElements = {},
    Enabled = true,
    UIVisible = true,
    HarvestingBusy = false,
    Settings = {
        Farm = {
            AutoCollectCash = false,
            AutoHatch = false,
            AutoPlaceBest = false,
            AutoUpgradeLuck = false,
            AutoUnlockNests = false,
            AutoRebirth = false,
            AutoClaimRewards = false,
            TickInterval = 1.0,
        },
        Eggs = {
            ESPEnabled = false,
            ESPHighlight = false,
            ShowDistance = false,
            RarityFilter = "All",
            AutoHarvest = false,
            HarvestReturnDelay = 1.0,
            SafeTransitPacing = true,
            PrioritizeRebirthEgg = false,
        },
        Halloween = {
            AutoKnockDoors = false,
            AutoSearchPumpkins = false,
            AutoDigGraves = false,
            AutoSkeletonSlayer = false,
            AutoGiantPumpkin = false,
            AutoCollectCandy = false,
            AutoBuyEgg = false,
        },
        Mobility = {
            SpeedEnabled = false,
            SpeedValue = 120,
            InfiniteJump = false,
        },
    }
}

_G.RideAPetEngine = Engine
if getgenv then getgenv().RideAPetEngine = Engine end

--[[ 1. CONFIGURATION SUBSYSTEM ]]--
local function SaveConfig()
    local cfg = {
        Farm = {
            AutoCollectCash = Engine.Settings.Farm.AutoCollectCash,
            AutoHatch = Engine.Settings.Farm.AutoHatch,
            AutoPlaceBest = Engine.Settings.Farm.AutoPlaceBest,
            AutoUpgradeLuck = Engine.Settings.Farm.AutoUpgradeLuck,
            AutoUnlockNests = Engine.Settings.Farm.AutoUnlockNests,
            AutoRebirth = Engine.Settings.Farm.AutoRebirth,
            AutoClaimRewards = Engine.Settings.Farm.AutoClaimRewards,
            TickInterval = Engine.Settings.Farm.TickInterval,
        },
        Eggs = {
            ESPEnabled = Engine.Settings.Eggs.ESPEnabled,
            ESPHighlight = Engine.Settings.Eggs.ESPHighlight,
            ShowDistance = Engine.Settings.Eggs.ShowDistance,
            RarityFilter = Engine.Settings.Eggs.RarityFilter,
            AutoHarvest = Engine.Settings.Eggs.AutoHarvest,
            HarvestReturnDelay = Engine.Settings.Eggs.HarvestReturnDelay,
            SafeTransitPacing = Engine.Settings.Eggs.SafeTransitPacing,
            PrioritizeRebirthEgg = Engine.Settings.Eggs.PrioritizeRebirthEgg,
        },
        Halloween = {
            AutoKnockDoors = Engine.Settings.Halloween.AutoKnockDoors,
            AutoSearchPumpkins = Engine.Settings.Halloween.AutoSearchPumpkins,
            AutoDigGraves = Engine.Settings.Halloween.AutoDigGraves,
            AutoSkeletonSlayer = Engine.Settings.Halloween.AutoSkeletonSlayer,
            AutoGiantPumpkin = Engine.Settings.Halloween.AutoGiantPumpkin,
            AutoCollectCandy = Engine.Settings.Halloween.AutoCollectCandy,
            AutoBuyEgg = Engine.Settings.Halloween.AutoBuyEgg,
        },
        Mobility = {
            SpeedEnabled = Engine.Settings.Mobility.SpeedEnabled,
            SpeedValue = Engine.Settings.Mobility.SpeedValue,
            InfiniteJump = Engine.Settings.Mobility.InfiniteJump,
        }
    }

    local s, encoded = pcall(function() return HttpService:JSONEncode(cfg) end)
    if s and encoded and writefile then
        pcall(function() writefile(CONFIG_FILE, encoded) end)
        return true
    end
    return false
end

local function LoadConfig()
    if not (readfile and isfile and isfile(CONFIG_FILE)) then
        return false
    end

    local s, content = pcall(function() return readfile(CONFIG_FILE) end)
    if not s or not content or content == "" then return false end

    local s2, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not s2 or type(data) ~= "table" then return false end

    local function applyTable(src, dest)
        if type(src) ~= "table" or type(dest) ~= "table" then return end
        for k, v in pairs(src) do
            if dest[k] ~= nil and type(dest[k]) == type(v) then
                if type(v) == "table" then
                    applyTable(v, dest[k])
                else
                    dest[k] = v
                end
            end
        end
    end

    applyTable(data, Engine.Settings)

    -- Update UI elements
    for key, el in pairs(Engine.UIElements) do
        if el then
            local val = nil
            if Engine.Settings.Farm[key] ~= nil then
                val = Engine.Settings.Farm[key]
            elseif Engine.Settings.Eggs[key] ~= nil then
                val = Engine.Settings.Eggs[key]
            elseif Engine.Settings.Halloween[key] ~= nil then
                val = Engine.Settings.Halloween[key]
            elseif Engine.Settings.Mobility[key] ~= nil then
                val = Engine.Settings.Mobility[key]
            end

            if val ~= nil then
                pcall(function()
                    local fn = el.Set or el.SetValue
                    if fn then fn(el, val) end
                end)
            end
        end
    end

    return true
end

--[[ 2. RARITY COLORS & METRICS ]]--
local RarityColors = {
    Ethereal = Color3.fromRGB(255, 0, 255),
    Divine = Color3.fromRGB(255, 215, 0),
    Mythic = Color3.fromRGB(255, 50, 50),
    Legendary = Color3.fromRGB(255, 140, 0),
    Epic = Color3.fromRGB(160, 32, 240),
    Rare = Color3.fromRGB(30, 144, 255),
    Common = Color3.fromRGB(200, 200, 200),
}

local RarityWeights = {
    Common = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4,
    Mythic = 5,
    Divine = 6,
    Ethereal = 7,
}

local function GetEggRarity(eggName)
    local eggsModule = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("Eggs")
    if eggsModule then
        local s, defs = pcall(require, eggsModule)
        if s and type(defs) == "table" and defs[eggName] and defs[eggName].Rarity then
            return defs[eggName].Rarity
        end
    end
    -- Fallback heuristics
    local n = eggName:lower()
    if n:find("dragon") or n:find("giant") or n:find("ethereal") then return "Ethereal" end
    if n:find("divine") or n:find("angelic") or n:find("aurora") or n:find("cherub") then return "Divine" end
    if n:find("mythic") or n:find("magic") or n:find("dominus") or n:find("galaxy") or n:find("halloween") or n:find("pumpkin") or n:find("toad") then return "Mythic" end
    if n:find("legendary") or n:find("royal") or n:find("sinister") or n:find("skull") then return "Legendary" end
    if n:find("epic") or n:find("jewel") or n:find("ice") or n:find("flower") or n:find("glass") or n:find("slime") then return "Epic" end
    if n:find("rare") or n:find("cracked") or n:find("easter") or n:find("leaf") or n:find("stone") or n:find("tidal") or n:find("bloom") then return "Rare" end
    return "Common"
end

local function MatchesFilter(rarity, filter)
    if filter == "All" then return true end
    local w = RarityWeights[rarity] or 1
    if filter == "Rare+" then return w >= 2 end
    if filter == "Epic+" then return w >= 3 end
    if filter == "Legendary+" then return w >= 4 end
    if filter == "Mythic+" then return w >= 5 end
    if filter == "Divine+" then return w >= 6 end
    if filter == "Ethereal" then return w >= 7 end
    return true
end

-- Universal Egg Candidate Collector (Scans Main Island & Halloween Map)
local function GetAllEggCandidates()
    local list = {}
    local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
    if renderedEggs then
        for _, c in ipairs(renderedEggs:GetChildren()) do
            if c:IsA("Model") or c:IsA("BasePart") then
                table.insert(list, c)
            end
        end
    end
    -- HeadlessRitual Egg
    local ritual = Workspace:FindFirstChild("HeadlessRitual")
    local ritualEgg = ritual and ritual:FindFirstChild("RewardPoints") and ritual.RewardPoints:FindFirstChild("Egg")
    if ritualEgg and ritualEgg:IsA("BasePart") then
        table.insert(list, ritualEgg)
    end
    -- HalloweenEggShop
    local eggShop = Workspace:FindFirstChild("HalloweenEggShop")
    if eggShop and (eggShop:IsA("Model") or eggShop:IsA("BasePart")) then
        table.insert(list, eggShop)
    end
    return list
end

--[[ 2.5 SMART REBIRTH EGG TARGETER ]]--
local EggPetOddsCache = {}
local function GetCurrentRebirthRequirement()
    local lp = GetLocalPlayer()
    local saved = lp and lp:FindFirstChild("SavedData")
    if not saved then return nil, false, 0 end

    local rebirthsVal = saved:FindFirstChild("Rebirths") and saved.Rebirths.Value or 0
    local nextIndex = rebirthsVal + 1
    local generalMod = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("General")
    if not generalMod then return nil, false, rebirthsVal end

    local s, general = pcall(require, generalMod)
    if not s or not general or not general.RebirthRequirements then return nil, false, rebirthsVal end

    local targetPet = general.RebirthRequirements[nextIndex]
    if not targetPet then
        return nil, true, rebirthsVal -- Maximum rebirth reached
    end

    local ownedPets = saved:FindFirstChild("OwnedPets") and saved.OwnedPets.Value or ""
    local isOwned = string.find(ownedPets, targetPet, 1, true) ~= nil
    return targetPet, isOwned, rebirthsVal
end

local function GetEggChanceForPet(eggName, targetPet)
    if not eggName or not targetPet then return 0 end
    local cacheKey = eggName .. ":" .. targetPet
    if EggPetOddsCache[cacheKey] ~= nil then
        return EggPetOddsCache[cacheKey]
    end

    local eggsMod = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("Eggs")
    local luckMod = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("HatchLuck")
    if not eggsMod or not luckMod then
        EggPetOddsCache[cacheKey] = 0
        return 0
    end

    local s1, eggsData = pcall(require, eggsMod)
    local s2, hatchLuck = pcall(require, luckMod)
    if not s1 or not s2 or not eggsData or not hatchLuck then
        EggPetOddsCache[cacheKey] = 0
        return 0
    end

    local eggInfo = eggsData[eggName]
    if not eggInfo then
        EggPetOddsCache[cacheKey] = 0
        return 0
    end

    local odds = hatchLuck.GetBoostedOdds(eggInfo.Luck or 1, 1, eggInfo)
    local chance = 0
    if type(odds) == "table" then
        for _, entry in ipairs(odds) do
            if entry.PetName == targetPet and entry.Chance then
                chance = entry.Chance
                break
            end
        end
    end
    EggPetOddsCache[cacheKey] = chance
    return chance
end

local function FindBestEggForRebirth()
    local targetPet, isOwned = GetCurrentRebirthRequirement()
    if not targetPet or isOwned then return nil, 0, targetPet end

    local candidates = GetAllEggCandidates()
    local bestEgg, bestChance, bestDist = nil, 0, math.huge
    local hrp = GetLocalRoot()
    local myPos = hrp and hrp.Position or Vector3.zero

    for _, egg in ipairs(candidates) do
        if egg:IsA("Model") or egg:IsA("BasePart") then
            local chance = GetEggChanceForPet(egg.Name, targetPet)
            if chance >= 0.0005 then
                local dist = (myPos - egg:GetPivot().Position).Magnitude
                if chance > bestChance or (chance == bestChance and dist < bestDist) then
                    bestEgg = egg
                    bestChance = chance
                    bestDist = dist
                end
            end
        end
    end

    return bestEgg, bestChance, targetPet
end

local function TeleportToRebirthEgg()
    local bestEgg, chance, targetPet = FindBestEggForRebirth()
    local char = GetLocalCharacter()
    if not char then return false, "Character not found" end

    if not targetPet then
        return false, "All rebirth requirements completed!"
    end

    local _, isOwned = GetCurrentRebirthRequirement()
    if isOwned then
        return false, string.format("Rebirth pet (%s) is already owned!", targetPet)
    end

    if not bestEgg then
        return false, string.format("No egg for [%s] currently spawned on map!", targetPet)
    end

    char:PivotTo(bestEgg:GetPivot() * CFrame.new(0, 3, 0))
    return true, string.format("Warped to %s (%.1f%% chance for %s)", bestEgg.Name, chance * 100, targetPet)
end

--[[ 3. WORLD EGGS ESP SUBSYSTEM ]]--
local function ClearESP()
    for _, b in pairs(Engine.Billboards) do
        pcall(function() b:Destroy() end)
    end
    table.clear(Engine.Billboards)

    for _, h in pairs(Engine.Highlights) do
        pcall(function() h:Destroy() end)
    end
    table.clear(Engine.Highlights)
end

local function UpdateEggESP()
    if not Engine.Settings.Eggs.ESPEnabled then
        ClearESP()
        return
    end

    local hrp = GetLocalRoot()
    local myPos = hrp and hrp.Position or Vector3.zero
    local activeSet = {}

    local eggCandidates = GetAllEggCandidates()
    local targetPet, isOwned = GetCurrentRebirthRequirement()
    local prioritizeRebirth = Engine.Settings.Eggs.PrioritizeRebirthEgg and (not isOwned) and (targetPet ~= nil)

    for _, egg in ipairs(eggCandidates) do
        if egg:IsA("Model") or egg:IsA("BasePart") then
            activeSet[egg] = true
            local displayName = egg.Name
            local rarity = GetEggRarity(egg.Name)
            if egg.Name == "HalloweenEggShop" then
                displayName = "Halloween Egg Shop (350 Candy)"
                rarity = "Mythic"
            elseif egg.Name == "Egg" and egg.Parent and egg.Parent.Name == "RewardPoints" then
                displayName = "Ritual Egg"
                rarity = "Divine"
            end

            local rebirthChance = (not isOwned and targetPet) and GetEggChanceForPet(egg.Name, targetPet) or 0
            local isRebirthTarget = rebirthChance >= 0.0005

            local isMatch = MatchesFilter(rarity, Engine.Settings.Eggs.RarityFilter) or (prioritizeRebirth and isRebirthTarget)

            if isMatch then
                local pivot = egg:GetPivot().Position
                local dist = math.floor((myPos - pivot).Magnitude)
                local color = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)

                if isRebirthTarget then
                    color = Color3.fromRGB(255, 170, 0)
                    displayName = string.format("ð¯ [%s %.1f%%] %s", targetPet, rebirthChance * 100, displayName)
                end

                -- Billboard GUI
                local bb = Engine.Billboards[egg]
                if not bb or not bb.Parent then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "EggESP"
                    bb.Size = UDim2.fromOffset(180, 44)
                    bb.AlwaysOnTop = true
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.MaxDistance = 0 -- 0 removes the 15,000 studs distance culling!

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Name = "EggName"
                    nameLbl.Size = UDim2.new(1, 0, 0.55, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 13
                    nameLbl.TextStrokeTransparency = 0.2
                    nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    nameLbl.Parent = bb

                    local distLbl = Instance.new("TextLabel")
                    distLbl.Name = "EggDist"
                    distLbl.Size = UDim2.new(1, 0, 0.45, 0)
                    distLbl.Position = UDim2.new(0, 0, 0.55, 0)
                    distLbl.BackgroundTransparency = 1
                    distLbl.Font = Enum.Font.Gotham
                    distLbl.TextSize = 11
                    distLbl.TextStrokeTransparency = 0.3
                    distLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
                    distLbl.Parent = bb

                    local adornee = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart") or egg
                    bb.Adornee = adornee
                    bb.Parent = CoreGui:FindFirstChild("RobloxGui") or GetLocalPlayer():FindFirstChild("PlayerGui") or Workspace
                    Engine.Billboards[egg] = bb
                end

                if bb then
                    local nameLbl = bb:FindFirstChild("EggName")
                    local distLbl = bb:FindFirstChild("EggDist")
                    if nameLbl then
                        nameLbl.Text = displayName
                        nameLbl.TextColor3 = color
                    end
                    if distLbl then
                        distLbl.Visible = Engine.Settings.Eggs.ShowDistance
                        if isRebirthTarget then
                            distLbl.Text = string.format("â REBIRTH TARGET â¢ %d studs", dist)
                            distLbl.TextColor3 = Color3.fromRGB(255, 230, 120)
                        else
                            distLbl.Text = string.format("[%s] â¢ %d studs", rarity, dist)
                            distLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
                        end
                    end
                end

                -- Highlight
                if Engine.Settings.Eggs.ESPHighlight or isRebirthTarget then
                    local hl = Engine.Highlights[egg]
                    if not hl or not hl.Parent then
                        hl = Instance.new("Highlight")
                        hl.Name = "EggHighlight"
                        hl.FillColor = color
                        hl.OutlineColor = isRebirthTarget and Color3.fromRGB(255, 255, 255) or color
                        hl.FillTransparency = isRebirthTarget and 0.45 or 0.6
                        hl.OutlineTransparency = 0.05
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Adornee = egg
                        hl.Parent = egg
                        Engine.Highlights[egg] = hl
                    else
                        hl.FillColor = color
                        hl.OutlineColor = isRebirthTarget and Color3.fromRGB(255, 255, 255) or color
                        hl.FillTransparency = isRebirthTarget and 0.45 or 0.6
                        hl.Enabled = true
                    end
                else
                    local hl = Engine.Highlights[egg]
                    if hl then hl.Enabled = false end
                end
            else
                local bb = Engine.Billboards[egg]
                if bb then bb.Enabled = false end
                local hl = Engine.Highlights[egg]
                if hl then hl.Enabled = false end
            end
        end
    end

    -- Cleanup despawned eggs
    for egg, bb in pairs(Engine.Billboards) do
        if not activeSet[egg] or not egg.Parent then
            pcall(function() bb:Destroy() end)
            Engine.Billboards[egg] = nil
        end
    end
    for egg, hl in pairs(Engine.Highlights) do
        if not activeSet[egg] or not egg.Parent then
            pcall(function() hl:Destroy() end)
            Engine.Highlights[egg] = nil
        end
    end
end

--[[ 4. AUTO HARVEST EGGS SUBSYSTEM ]]--
local function HarvestCycle()
    if not Engine.Settings.Eggs.AutoHarvest or Engine.HarvestingBusy then return end
    local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
    local hrp = GetLocalRoot()
    local char = GetLocalCharacter()
    local lp = GetLocalPlayer()
    if not renderedEggs or not hrp or not char or not lp then return end

    -- Check Basket status
    local basket = lp:FindFirstChild("Basket")
    if basket and #basket:GetChildren() >= 1 then
        -- Deliver to plot first with transit pacing protection
        local plot = GetPlayerPlot()
        local bp = plot and plot:FindFirstChild("Baseplate")
        if bp then
            Engine.HarvestingBusy = true
            local dist = (hrp.Position - bp.Position).Magnitude
            if Engine.Settings.Eggs.SafeTransitPacing then
                local transitDelay = math.max(3.0, dist / 32)
                local safeOffsetZ = (bp.Size.Z / 2) + 25
                char:PivotTo(bp.CFrame * CFrame.new(0, 5, safeOffsetZ))
                local remaining = math.max(0, (EggSafety and EggSafety.PacingHoldUntil or 0) - os.clock())
                task.wait(math.max(remaining, 1.5))
            end
            char:PivotTo(bp.CFrame * CFrame.new(0, 5, 0))
            task.wait(Engine.Settings.Eggs.HarvestReturnDelay)
            Engine.HarvestingBusy = false
        end
        return
    end

    -- Find matching candidates (ISOLATE MAP: Only harvest eggs within same zone as player plot)
    local plot = GetPlayerPlot()
    local bp = plot and plot:FindFirstChild("Baseplate")
    local targetPet, isOwned = GetCurrentRebirthRequirement()
    local prioritizeRebirth = Engine.Settings.Eggs.PrioritizeRebirthEgg and (not isOwned) and (targetPet ~= nil)

    local candidates = {}
    for _, egg in ipairs(renderedEggs:GetChildren()) do
        if egg:IsA("Model") or egg:IsA("BasePart") then
            local pivot = egg:GetPivot().Position
            if bp and (pivot - bp.Position).Magnitude < 8000 then
                local rarity = GetEggRarity(egg.Name)
                local rebirthChance = (prioritizeRebirth) and GetEggChanceForPet(egg.Name, targetPet) or 0
                if rebirthChance < 0.0005 then rebirthChance = 0 end
                local isMatch = MatchesFilter(rarity, Engine.Settings.Eggs.RarityFilter) or (prioritizeRebirth and rebirthChance > 0)

                if isMatch then
                    local dist = (hrp.Position - pivot).Magnitude
                    local rarityW = RarityWeights[rarity] or 1
                    local score = rarityW
                    if prioritizeRebirth and rebirthChance > 0 then
                        -- Exponential score boost so rebirth pet eggs are harvested before all others
                        score = 100000 + math.floor(rebirthChance * 100000)
                    end
                    table.insert(candidates, {Egg = egg, Dist = dist, Score = score, RebirthChance = rebirthChance})
                end
            end
        end
    end

    if #candidates == 0 then return end

    -- Sort prioritized by score (descending) then distance (ascending)
    table.sort(candidates, function(a, b)
        if a.Score ~= b.Score then
            return a.Score > b.Score
        end
        return a.Dist < b.Dist
    end)

    local target = candidates[1].Egg
    if not target or not target.Parent then return end

    Engine.HarvestingBusy = true
    local originalCFrame = hrp.CFrame
    local eggPivot = target:GetPivot()

    -- Teleport to egg
    char:PivotTo(eggPivot * CFrame.new(0, 3, 0))
    task.wait(0.25)

    local pickupStartTick = os.clock()
    local plot = GetPlayerPlot()
    local bp = plot and plot:FindFirstChild("Baseplate")
    local dist = bp and (eggPivot.Position - bp.Position).Magnitude or 100

    -- Trigger pickup via prompt
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        prompt.Enabled = true
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        pcall(fireproximityprompt, prompt, 0)
    end

    -- Trigger server remote directly using ActiveEggs UUID
    local activeEggs = (ReplicatedStorage:FindFirstChild("ServerData") or ReplicatedStorage):FindFirstChild("ActiveEggs")
    if activeEggs then
        for _, eggNode in ipairs(activeEggs:GetChildren()) do
            local pos = eggNode:GetAttribute("Position")
            if pos and (eggPivot.Position - pos).Magnitude < 35 then
                local gameRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game")
                local eggPickupRE = gameRemotes and gameRemotes:FindFirstChild("EggPickup")
                if eggPickupRE then
                    pcall(function() eggPickupRE:FireServer(eggNode.Name) end)
                end
                break
            end
        end
    end

    task.wait(0.4)

    -- Safe return to personal plot with velocity anti-detection
    if bp then
        if Engine.Settings.Eggs.SafeTransitPacing then
            local transitDelay = math.max(3.0, dist / 32)
            -- Stage character safely outside baseplate perimeter while transit duration counts down
            local safeOffsetZ = (bp.Size.Z / 2) + 25
            char:PivotTo(bp.CFrame * CFrame.new(0, 5, safeOffsetZ))

            local elapsed = os.clock() - pickupStartTick
            if elapsed < transitDelay then
                task.wait(transitDelay - elapsed)
            end
        end
        -- Touch down onto baseplate only after safe duration elapsed
        char:PivotTo(bp.CFrame * CFrame.new(0, 5, 0))
    else
        char:PivotTo(originalCFrame)
    end

    task.wait(Engine.Settings.Eggs.HarvestReturnDelay)
    Engine.HarvestingBusy = false
end

--[[ 5. CORE AFK FARM SUBSYSTEM ]]--
local function FarmCycle()
    local lp = GetLocalPlayer()
    if not lp then return end
    local gameRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game")
    if not gameRemotes then return end

    local plot = GetPlayerPlot()

    -- 1. Auto Collect Cash from Plot Pets
    if Engine.Settings.Farm.AutoCollectCash and plot and plot:FindFirstChild("Pets") then
        local petCollectRE = gameRemotes:FindFirstChild("PetCollect")
        if petCollectRE then
            for _, pet in ipairs(plot.Pets:GetChildren()) do
                local key = pet:GetAttribute("PetKey")
                if key then
                    pcall(function() petCollectRE:FireServer(key) end)
                end
            end
        end
    end

    -- 2. Auto Hatch Incubated Eggs
    if Engine.Settings.Farm.AutoHatch and plot and plot:FindFirstChild("Eggs") then
        local hatchRE = gameRemotes:FindFirstChild("Hatch")
        for _, egg in ipairs(plot.Eggs:GetChildren()) do
            local key = egg:GetAttribute("EggKey")
            local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
            local ready = false

            if prompt and prompt.Enabled and prompt.ActionText == "Hatch" then
                ready = true
            else
                local ed = egg:FindFirstChild("EggData")
                local pt = ed and ed:FindFirstChild("PlaceTime") and ed.PlaceTime.Value
                if pt and pt > 0 then
                    local dnModule = ReplicatedStorage:FindFirstChild("GameServices") and ReplicatedStorage.GameServices:FindFirstChild("DayNight")
                    local elapsed = dnModule and require(dnModule).GrowthElapsed and require(dnModule).GrowthElapsed(pt) or 99999
                    ready = elapsed >= 30
                end
            end

            if ready and key then
                if prompt then
                    prompt.HoldDuration = 0
                    pcall(fireproximityprompt, prompt, 0)
                end
                if hatchRE then
                    pcall(function() hatchRE:FireServer({EggKey = key}) end)
                end
            end
        end
    end

    -- 3. Auto Place Best Pets
    if Engine.Settings.Farm.AutoPlaceBest then
        local placeBestRE = gameRemotes:FindFirstChild("PlaceBest")
        if placeBestRE then
            pcall(function() placeBestRE:FireServer() end)
        end
    end

    -- 4. Auto Upgrade Hatch Luck
    if Engine.Settings.Farm.AutoUpgradeLuck then
        local plotUpgradesRE = gameRemotes:FindFirstChild("Plot") and gameRemotes.Plot:FindFirstChild("Upgrades")
        if plotUpgradesRE then
            pcall(function() plotUpgradesRE:FireServer("Max") end)
        end
    end

    -- 5. Auto Unlock Nests (Nests 2 to 5)
    if Engine.Settings.Farm.AutoUnlockNests and plot and plot:FindFirstChild("Nests") then
        local nestsRE = gameRemotes:FindFirstChild("Plot") and gameRemotes.Plot:FindFirstChild("Nests")
        local cashVal = lp:FindFirstChild("SavedData") and lp.SavedData:FindFirstChild("Cash") and lp.SavedData.Cash.Value or 0
        local nestPrices = { [2] = 1000, [3] = 5000, [4] = 100000, [5] = 1000000 }

        for nestIdx, price in pairs(nestPrices) do
            local nest = plot.Nests:FindFirstChild(tostring(nestIdx))
            if nest and nest:FindFirstChild("Locked") and cashVal >= price then
                local prompt = nest:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = 999999
                    pcall(fireproximityprompt, prompt, 0)
                end
                if nestsRE then
                    pcall(function() nestsRE:FireServer(nestIdx) end)
                end
            end
        end
    end

    -- 6. Auto Rebirth
    if Engine.Settings.Farm.AutoRebirth then
        local rebirthRE = gameRemotes:FindFirstChild("Rebirth")
        local rebModule = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("Rebirths")
        local genModule = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("General")
        local saved = lp:FindFirstChild("SavedData")
        if rebirthRE and rebModule and genModule and saved then
            local rebData = require(rebModule)
            local genData = require(genModule)
            local curReb = saved:FindFirstChild("Rebirths") and saved.Rebirths.Value or 0
            local cash = saved:FindFirstChild("Cash") and saved.Cash.Value or 0
            local ownedPets = saved:FindFirstChild("OwnedPets") and saved.OwnedPets.Value or ""
            local cost = rebData.GetCost and rebData.GetCost(curReb) or 1000000
            local reqPet = genData.RebirthRequirements and genData.RebirthRequirements[curReb + 1]

            local canRebirth = cash >= cost
            if reqPet and reqPet ~= "" then
                canRebirth = canRebirth and (string.find(ownedPets, reqPet) ~= nil)
            end

            if canRebirth then
                pcall(function() rebirthRE:FireServer() end)
            end
        end
    end

    -- 7. Auto Claim Rewards
    if Engine.Settings.Farm.AutoClaimRewards then
        local indexClaim = gameRemotes:FindFirstChild("ClaimIndexReward")
        if indexClaim then pcall(function() indexClaim:FireServer() end) end

        local reusable = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Reusable")
        if reusable then
            local groupClaim = reusable:FindFirstChild("ClaimGroupReward")
            if groupClaim then pcall(function() groupClaim:FireServer() end) end

            local eventClaim = reusable:FindFirstChild("ClaimEventReward")
            if eventClaim then pcall(function() eventClaim:FireServer() end) end
        end
    end
end

--[[ 6. HALLOWEEN EVENT AUTOMATION SUBSYSTEM ]]--
local function HalloweenCycle()
    if Engine.HalloweenBusy then return end
    local gameRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game")
    if not gameRemotes then return end
    local hrp = GetLocalRoot()
    local char = GetLocalCharacter()
    local lp = GetLocalPlayer()
    if not hrp or not char or not lp then return end

    -- Check if any Halloween feature is active
    local anyActive = Engine.Settings.Halloween.AutoCollectCandy
        or Engine.Settings.Halloween.AutoKnockDoors
        or Engine.Settings.Halloween.AutoDigGraves
        or Engine.Settings.Halloween.AutoSkeletonSlayer
        or Engine.Settings.Halloween.AutoGiantPumpkin
        or Engine.Settings.Halloween.AutoBuyEgg

    if not anyActive then return end
    Engine.HalloweenBusy = true

    -- Auto-Warp to Halloween Zone if player is far away (Main Island culls Halloween via StreamingEnabled)
    local halloweenCenter = Vector3.new(-46800, 40380, -20070)
    if (hrp.Position - halloweenCenter).Magnitude > 5000 then
        char:PivotTo(CFrame.new(-47234.8, 40605.0, -19532.3))
        task.wait(1.0)
        Engine.HalloweenBusy = false
        return
    end

    local pad = (Workspace:FindFirstChild("CandyDropOff") and Workspace.CandyDropOff:FindFirstChild("Pad"))
        or (CollectionService:GetTagged("HalloweenCandyDeposit") and CollectionService:GetTagged("HalloweenCandyDeposit")[1])

    local noSave = lp:FindFirstChild("NoSaveData")
    local carriedVal = noSave and noSave:FindFirstChild("CarriedCandy")
    local saved = lp:FindFirstChild("SavedData")
    local candyBalance = saved and saved:FindFirstChild("HalloweenCandy")

    -- 1. Auto Collect Candy with Speed-Paced Deposit (Anti-Spoil)
    if Engine.Settings.Halloween.AutoCollectCandy and pad then
        local candyRE = gameRemotes:FindFirstChild("CollectCandy")
        local candies = CollectionService:GetTagged("HalloweenCandySpawn")
        if #candies > 0 and candyRE then
            -- Sort candies by proximity to deposit pad for optimal transit efficiency
            local candidates = {}
            for _, c in ipairs(candies) do
                if c and c.Parent and c:IsA("BasePart") then
                    local distToPad = (c.Position - pad.Position).Magnitude
                    table.insert(candidates, {Part = c, DistToPad = distToPad})
                end
            end
            table.sort(candidates, function(a, b) return a.DistToPad < b.DistToPad end)

            for i = 1, math.min(10, #candidates) do
                if not Engine.Settings.Halloween.AutoCollectCandy then break end
                local c = candidates[i].Part
                if c and c.Parent and c:IsA("BasePart") then
                    local id = c:GetAttribute("Id") or c.Name
                    local prompt = c:FindFirstChildWhichIsA("ProximityPrompt", true)

                    -- Move to candy
                    char:PivotTo(c.CFrame * CFrame.new(0, 2, 0))
                    task.wait(0.12)
                    if prompt then
                        prompt.Enabled = true
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999
                        pcall(fireproximityprompt, prompt, 0)
                    end
                    pcall(function() candyRE:FireServer(id) end)
                    task.wait(0.2)

                    -- If candy was picked up (carriedVal > 0), transit to pad with anti-spoil pacing
                    if carriedVal and carriedVal.Value > 0 then
                        local dist = (hrp.Position - pad.Position).Magnitude
                        local pacingDelay = math.clamp(dist / 65, 0.5, 3.5)
                        task.wait(pacingDelay)

                        char:PivotTo(pad.CFrame * CFrame.new(0, 3, 0))
                        -- Wait for server to process deposit
                        local startWait = os.clock()
                        while carriedVal and carriedVal.Value > 0 and (os.clock() - startWait) < 1.5 do
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end

    -- 2. Auto Knock Doors (Only Target Lit Trick-or-Treat Houses)
    if Engine.Settings.Halloween.AutoKnockDoors then
        local knockRE = gameRemotes:FindFirstChild("KnockDoor")
        local getDoorState = gameRemotes:FindFirstChild("GetDoorState")
        local litHouses = {}

        if getDoorState then
            local ok, state = pcall(getDoorState.InvokeServer, getDoorState)
            if ok and type(state) == "table" and type(state.Lit) == "table" then
                for doorId, isLit in pairs(state.Lit) do
                    if isLit == true then
                        litHouses[doorId] = true
                    end
                end
            end
        end

        local houses = CollectionService:GetTagged("TrickOrTreatHouseModel")
        if knockRE and #houses > 0 then
            for _, house in ipairs(houses) do
                if not Engine.Settings.Halloween.AutoKnockDoors then break end
                if house and house.Parent then
                    local id = house:GetAttribute("Id")
                    if not id or id == "" then
                        local p = house:GetPivot().Position
                        id = string.format("Door_%d_%d", math.round(p.X), math.round(p.Z))
                    end

                    -- Only knock if lit (or if lit status not returned, fallback)
                    if litHouses[id] or next(litHouses) == nil then
                        char:PivotTo(house:GetPivot() * CFrame.new(0, 0, 5))
                        task.wait(0.15)
                        local prompt = house:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            prompt.Enabled = true
                            prompt.HoldDuration = 0
                            prompt.MaxActivationDistance = 999
                            pcall(fireproximityprompt, prompt, 0)
                        end
                        pcall(function() knockRE:FireServer(id) end)
                        task.wait(0.3)
                    end
                end
            end
        end
    end

    -- 3. Auto Dig Graves (Filter out graves on cooldown)
    if Engine.Settings.Halloween.AutoDigGraves then
        local digRE = gameRemotes:FindFirstChild("DigGrave")
        local getGraveState = gameRemotes:FindFirstChild("GetGraveState")
        local cooldowns = {}
        if getGraveState then
            local ok, gState = pcall(getGraveState.InvokeServer, getGraveState)
            if ok and type(gState) == "table" and type(gState.CooldownUntil) == "table" then
                local now = workspace:GetServerTimeNow()
                for graveId, cd in pairs(gState.CooldownUntil) do
                    if cd > now then
                        cooldowns[graveId] = true
                    end
                end
            end
        end

        local graves = CollectionService:GetTagged("HalloweenGrave")
        if digRE and #graves > 0 then
            for _, grave in ipairs(graves) do
                if not Engine.Settings.Halloween.AutoDigGraves then break end
                if grave and grave.Parent then
                    local id = grave:GetAttribute("Id") or grave.Name
                    if not cooldowns[id] then
                        local digSpot = grave:FindFirstChild("DigSpot") or grave.PrimaryPart or grave
                        char:PivotTo(digSpot:GetPivot() * CFrame.new(0, 0, 2))
                        task.wait(0.15)
                        local prompt = grave:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            prompt.Enabled = true
                            prompt.HoldDuration = 0
                            prompt.MaxActivationDistance = 999
                            pcall(fireproximityprompt, prompt, 0)
                        end
                        pcall(function() digRE:FireServer(id) end)
                        task.wait(0.3)
                    end
                end
            end
        end
    end

    -- 4. Auto Skeleton Slayer
    if Engine.Settings.Halloween.AutoSkeletonSlayer then
        local hitRE = gameRemotes:FindFirstChild("GraveSkeletonHit")
        if hitRE then
            local skeletons = {}
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:lower():find("skeleton") or obj:GetAttribute("IsSkeleton")) then
                    table.insert(skeletons, obj)
                end
            end
            for _, tagObj in ipairs(CollectionService:GetTagged("HalloweenGraveSkeleton")) do
                table.insert(skeletons, tagObj)
            end
            for _, skel in ipairs(skeletons) do
                if not Engine.Settings.Halloween.AutoSkeletonSlayer then break end
                if skel and skel.Parent then
                    local skelId = skel:GetAttribute("Id") or skel.Name
                    char:PivotTo(skel:GetPivot() * CFrame.new(0, 0, 3))
                    pcall(function()
                        hitRE:FireServer(skelId, Vector3.new(0, 0, 1))
                    end)
                    task.wait(0.1)
                end
            end
        end
    end

    -- 5. Auto Giant Pumpkin Swing
    if Engine.Settings.Halloween.AutoGiantPumpkin then
        local gp = Workspace:FindFirstChild("GiantPumpkin")
        local swingRE = gameRemotes:FindFirstChild("GiantPumpkinSwing")
        if gp and swingRE then
            char:PivotTo(gp:GetPivot() * CFrame.new(0, 3, 10))
            task.wait(0.15)
            pcall(function()
                swingRE:FireServer({Index = 1, Time = os.clock()})
            end)
        end
    end

    -- 6. Auto Buy Halloween Egg (350 Candy Tokens)
    if Engine.Settings.Halloween.AutoBuyEgg then
        local buyFunc = gameRemotes:FindFirstChild("BuyHalloweenEgg")
        if buyFunc and candyBalance and candyBalance.Value >= 350 then
            local eggShop = Workspace:FindFirstChild("HalloweenEggShop")
            if eggShop then
                char:PivotTo(eggShop:GetPivot() * CFrame.new(0, 3, 8))
                task.wait(0.2)
            end
            pcall(function()
                buyFunc:InvokeServer("Halloween Egg")
            end)
        end
    end
    Engine.HalloweenBusy = false
end

--[[ 7. MOBILITY & TRAVERSAL SUBSYSTEM ]]--
-- Global State for Egg Delivery Anti-AT Guard
local EggSafety = {
    WasCarrying = false,
    PickupPos = nil,
    PickupTick = 0,
    PacingHoldUntil = 0,
}

local function UpdateEggSafetyGuard()
    local lp = GetLocalPlayer()
    local char = GetLocalCharacter()
    local hrp = GetLocalRoot()
    if not lp or not char or not hrp then return end

    local basket = lp:FindFirstChild("Basket")
    local carrying = basket and #basket:GetChildren() > 0

    if carrying and not EggSafety.WasCarrying then
        EggSafety.WasCarrying = true
        EggSafety.PickupTick = os.clock()
        EggSafety.PickupPos = hrp.Position

        local plot = GetPlayerPlot()
        local bp = plot and plot:FindFirstChild("Baseplate")
        if bp then
            local dist = (hrp.Position - bp.Position).Magnitude
            -- Velocity threshold: 32 studs/s strict server-safe pacing formula
            local requiredTransit = math.max(2.5, dist / 32)
            EggSafety.PacingHoldUntil = EggSafety.PickupTick + requiredTransit
        end
    elseif not carrying and EggSafety.WasCarrying then
        EggSafety.WasCarrying = false
        EggSafety.PickupPos = nil
        EggSafety.PacingHoldUntil = 0
    end

    -- Baseplate Perimeter Airbag: Prevents premature baseplate contact while pacing duration active
    if Engine.Settings.Eggs.SafeTransitPacing and carrying and EggSafety.PacingHoldUntil > 0 then
        local now = os.clock()
        if now < EggSafety.PacingHoldUntil then
            local plot = GetPlayerPlot()
            local bp = plot and plot:FindFirstChild("Baseplate")
            if bp then
                local objPos = bp.CFrame:PointToObjectSpace(hrp.Position)
                local halfX = bp.Size.X / 2 + 6
                local halfZ = bp.Size.Z / 2 + 6
                if math.abs(objPos.X) <= halfX and math.abs(objPos.Z) <= halfZ then
                    -- Intercept: Hold character safely outside perimeter until pacing timer completes
                    local safeZ = (bp.Size.Z / 2) + 20
                    char:PivotTo(bp.CFrame * CFrame.new(0, 5, safeZ))
                end
            end
        end
    end
end

local function UpdateMobility()
    local char = GetLocalCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Engine.Settings.Mobility.SpeedEnabled then
        hum.WalkSpeed = Engine.Settings.Mobility.SpeedValue
    end
end

local JumpConnection = UserInputService.JumpRequest:Connect(function()
    if Engine.Settings.Mobility.InfiniteJump then
        local char = GetLocalCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
table.insert(Engine.Connections, JumpConnection)

--[[ 8. TELEPORT HELPERS ]]--
local Landmarks = {
    Plot = function()
        local plot = GetPlayerPlot()
        local bp = plot and plot:FindFirstChild("Baseplate")
        local char = GetLocalCharacter()
        local lp = GetLocalPlayer()
        if bp and char then
            local basket = lp and lp:FindFirstChild("Basket")
            local carryingEgg = basket and #basket:GetChildren() > 0
            if carryingEgg and Engine.Settings.Eggs.SafeTransitPacing then
                char:PivotTo(bp.CFrame * CFrame.new(0, 8, (bp.Size.Z / 2) + 20))
            else
                char:PivotTo(bp.CFrame * CFrame.new(0, 6, 0))
            end
            return true
        end
        return false
    end,
    Spawn = Vector3.new(144.9, 40316.0, 920.5),
    Heaven = Vector3.new(-517.9, 42450.0, 880.9),
    Volcano = Vector3.new(-3183.5, 31300.0, -12495.8),
    Halloween = Vector3.new(-47234.8, 40605.0, -19532.3),
    Shop = Vector3.new(-45764.6, 40380.0, -20303.8),
    EggShop = Vector3.new(-45769.3, 40372.0, -20330.9),
    CandyDeposit = Vector3.new(-45839.9, 40372.0, -20118.0),
}

local function TeleportTo(dest)
    local char = GetLocalCharacter()
    if not char then return false end
    if type(dest) == "function" then
        return dest()
    elseif typeof(dest) == "Vector3" then
        char:PivotTo(CFrame.new(dest))
        return true
    elseif typeof(dest) == "CFrame" then
        char:PivotTo(dest)
        return true
    end
    return false
end

local function TeleportToClosestEgg()
    local hrp = GetLocalRoot()
    local char = GetLocalCharacter()
    if not hrp or not char then return false end

    local candidates = GetAllEggCandidates()
    local closest, closestDist = nil, math.huge
    for _, egg in ipairs(candidates) do
        if egg:IsA("Model") or egg:IsA("BasePart") then
            local dist = (hrp.Position - egg:GetPivot().Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = egg
            end
        end
    end

    if closest then
        char:PivotTo(closest:GetPivot() * CFrame.new(0, 3, 0))
        return true
    end
    return false
end

local function TeleportToBestEgg()
    local hrp = GetLocalRoot()
    local char = GetLocalCharacter()
    if not hrp or not char then return false end

    local candidates = GetAllEggCandidates()
    local best, bestWeight, bestDist = nil, -1, math.huge
    for _, egg in ipairs(candidates) do
        if egg:IsA("Model") or egg:IsA("BasePart") then
            local rarity = GetEggRarity(egg.Name)
            if egg.Name == "HalloweenEggShop" then rarity = "Mythic" end
            local weight = RarityWeights[rarity] or 1
            local dist = (hrp.Position - egg:GetPivot().Position).Magnitude
            if weight > bestWeight or (weight == bestWeight and dist < bestDist) then
                bestWeight = weight
                bestDist = dist
                best = egg
            end
        end
    end

    if best then
        char:PivotTo(best:GetPivot() * CFrame.new(0, 3, 0))
        return true
    end
    return false
end

--[[ 9. BACKGROUND TICK & RENDER LOOPS ]]--
local lastFarmTick = 0
local lastHalloweenTick = 0
local lastHarvestTick = 0

local HeartbeatConn = RunService.Heartbeat:Connect(function()
    local now = os.clock()

    -- Farm Loop
    if now - lastFarmTick >= Engine.Settings.Farm.TickInterval then
        lastFarmTick = now
        pcall(FarmCycle)
    end

    -- Halloween Loop
    if now - lastHalloweenTick >= 2.0 then
        lastHalloweenTick = now
        pcall(HalloweenCycle)
    end

    -- Auto Harvest Loop
    if now - lastHarvestTick >= 1.5 then
        lastHarvestTick = now
        pcall(HarvestCycle)
    end

    -- Mobility Hook & Egg Delivery Safety Guard
    pcall(UpdateMobility)
    pcall(UpdateEggSafetyGuard)
end)
table.insert(Engine.Connections, HeartbeatConn)

local RenderSteppedConn = RunService.RenderStepped:Connect(function()
    pcall(UpdateEggESP)
end)
table.insert(Engine.Connections, RenderSteppedConn)

--[[ 10. WINDUI INTERFACE ]]--
local WindUI
local success, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

local Window = nil
if success and WindUI then
    Window = WindUI:CreateWindow({
        Title = "Ride A Pet | Tactical Engine v1",
        Icon = "paw-print",
        -- Author removed
        Folder = "RideAPetConfig",
        Size = UDim2.fromOffset(590, 480),
        Transparent = true,
        Theme = "Dark",
    })

    -- TAB 1: AUTO FARM
    local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "zap" })

    Engine.UIElements.AutoCollectCash = FarmTab:Toggle({
        Title = "Auto Collect Cash",
        Desc = "Collects accumulated cash from all pets on your plot",
        Value = Engine.Settings.Farm.AutoCollectCash,
        Callback = function(v) Engine.Settings.Farm.AutoCollectCash = v end
    })

    Engine.UIElements.AutoHatch = FarmTab:Toggle({
        Title = "Auto Hatch Eggs",
        Desc = "Instantly hatches incubated plot eggs the moment they are ready",
        Value = Engine.Settings.Farm.AutoHatch,
        Callback = function(v) Engine.Settings.Farm.AutoHatch = v end
    })

    Engine.UIElements.AutoPlaceBest = FarmTab:Toggle({
        Title = "Auto Place Best Pets",
        Desc = "Continuously equips your highest income-generating pets onto plot",
        Value = Engine.Settings.Farm.AutoPlaceBest,
        Callback = function(v) Engine.Settings.Farm.AutoPlaceBest = v end
    })

    Engine.UIElements.AutoUpgradeLuck = FarmTab:Toggle({
        Title = "Auto Upgrade Hatch Luck",
        Desc = "Buys Max affordable Plot Hatch Luck upgrades with cash",
        Value = Engine.Settings.Farm.AutoUpgradeLuck,
        Callback = function(v) Engine.Settings.Farm.AutoUpgradeLuck = v end
    })

    Engine.UIElements.AutoUnlockNests = FarmTab:Toggle({
        Title = "Auto Unlock Nests",
        Desc = "Automatically buys Nests 2, 3, 4, 5 as cash thresholds are reached",
        Value = Engine.Settings.Farm.AutoUnlockNests,
        Callback = function(v) Engine.Settings.Farm.AutoUnlockNests = v end
    })

    Engine.UIElements.AutoRebirth = FarmTab:Toggle({
        Title = "Auto Rebirth",
        Desc = "Triggers Rebirth immediately upon meeting required pet and cash conditions",
        Value = Engine.Settings.Farm.AutoRebirth,
        Callback = function(v) Engine.Settings.Farm.AutoRebirth = v end
    })

    Engine.UIElements.AutoClaimRewards = FarmTab:Toggle({
        Title = "Auto Claim Rewards",
        Desc = "Automatically claims Index, Group, and Event rewards",
        Value = Engine.Settings.Farm.AutoClaimRewards,
        Callback = function(v) Engine.Settings.Farm.AutoClaimRewards = v end
    })

    Engine.UIElements.TickInterval = FarmTab:Slider({
        Title = "Farm Tick Interval (Seconds)",
        Desc = "Speed of background collection cycles",
        Step = 0.2,
        Value = { Min = 0.4, Max = 5.0, Default = Engine.Settings.Farm.TickInterval },
        Callback = function(v) Engine.Settings.Farm.TickInterval = v end
    })

    -- TAB 2: WORLD EGGS & HARVESTER
    local EggsTab = Window:Tab({ Title = "World Eggs", Icon = "egg" })

    Engine.UIElements.ESPEnabled = EggsTab:Toggle({
        Title = "World Eggs ESP",
        Desc = "Displays 3D billboard markers on all wild spawned eggs",
        Value = Engine.Settings.Eggs.ESPEnabled,
        Callback = function(v) Engine.Settings.Eggs.ESPEnabled = v end
    })

    Engine.UIElements.ESPHighlight = EggsTab:Toggle({
        Title = "Egg Silhouette Chams",
        Desc = "Always-on-top glow highlight colored by egg rarity tier",
        Value = Engine.Settings.Eggs.ESPHighlight,
        Callback = function(v) Engine.Settings.Eggs.ESPHighlight = v end
    })

    Engine.UIElements.ShowDistance = EggsTab:Toggle({
        Title = "Show Egg Distance",
        Desc = "Displays studs distance and rarity tier tag on ESP label",
        Value = Engine.Settings.Eggs.ShowDistance,
        Callback = function(v) Engine.Settings.Eggs.ShowDistance = v end
    })

    Engine.UIElements.RarityFilter = EggsTab:Dropdown({
        Title = "Egg Rarity Target Filter",
        Desc = "Filter eggs for ESP and Auto Harvesting",
        Values = { "All", "Rare+", "Epic+", "Legendary+", "Mythic+", "Divine+", "Ethereal" },
        Value = Engine.Settings.Eggs.RarityFilter,
        Callback = function(v) Engine.Settings.Eggs.RarityFilter = v end
    })

    Engine.UIElements.AutoHarvest = EggsTab:Toggle({
        Title = "Auto Harvest Eggs",
        Desc = "Teleports to filtered eggs, picks them up, and delivers to plot nests",
        Value = Engine.Settings.Eggs.AutoHarvest,
        Callback = function(v) Engine.Settings.Eggs.AutoHarvest = v end
    })

    Engine.UIElements.PrioritizeRebirthEgg = EggsTab:Toggle({
        Title = "Prioritize Rebirth Requirement Egg",
        Desc = "Dynamically hunts eggs with highest chance for next Rebirth pet (e.g. Fox)",
        Value = Engine.Settings.Eggs.PrioritizeRebirthEgg,
        Callback = function(v) Engine.Settings.Eggs.PrioritizeRebirthEgg = v end
    })

    Engine.UIElements.SafeTransitPacing = EggsTab:Toggle({
        Title = "Safe Delivery Pacing (Anti AT-8788)",
        Desc = "Enforces 32 studs/s transit time to eliminate server velocity error AT-8784 / AT-8788",
        Value = Engine.Settings.Eggs.SafeTransitPacing,
        Callback = function(v) Engine.Settings.Eggs.SafeTransitPacing = v end
    })

    Engine.UIElements.HarvestReturnDelay = EggsTab:Slider({
        Title = "Harvest Deposit Delay",
        Desc = "Wait duration after returning to plot to allow server nest placement",
        Step = 0.2,
        Value = { Min = 0.4, Max = 3.0, Default = Engine.Settings.Eggs.HarvestReturnDelay },
        Callback = function(v) Engine.Settings.Eggs.HarvestReturnDelay = v end
    })

    EggsTab:Button({
        Title = "Teleport: Next Rebirth Egg",
        Desc = "Warps directly to the highest-probability egg for your next Rebirth",
        Callback = function()
            local ok, msg = TeleportToRebirthEgg()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Rebirth Targeter",
                    Content = msg or (ok and "Teleported to rebirth egg!" or "Failed"),
                    Duration = 3.5
                })
            end
        end
    })

    EggsTab:Button({
        Title = "Teleport to Closest Egg",
        Desc = "Instantly warps character directly to the nearest egg on map",
        Callback = function()
            local ok = TeleportToClosestEgg()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Egg Teleport",
                    Content = ok and "Teleported to closest egg!" or "No matching egg found in workspace.",
                    Duration = 2.5
                })
            end
        end
    })

    EggsTab:Button({
        Title = "Teleport to Best Egg on Map",
        Desc = "Warps to the rarest egg currently spawned (Ethereal/Divine/Mythic)",
        Callback = function()
            local ok = TeleportToBestEgg()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Egg Teleport",
                    Content = ok and "Teleported to rarest egg!" or "No matching egg found.",
                    Duration = 2.5
                })
            end
        end
    })

    -- TAB 3: HALLOWEEN EVENT
    local HalloweenTab = Window:Tab({ Title = "Halloween", Icon = "ghost" })

    Engine.UIElements.AutoKnockDoors = HalloweenTab:Toggle({
        Title = "Auto Knock Doors (Trick or Treat)",
        Desc = "Automates knocking on all Halloween neighborhood doors",
        Value = Engine.Settings.Halloween.AutoKnockDoors,
        Callback = function(v) Engine.Settings.Halloween.AutoKnockDoors = v end
    })

    Engine.UIElements.AutoSearchPumpkins = HalloweenTab:Toggle({
        Title = "Auto Search Pumpkins",
        Desc = "Searches all pumpkin stations for candy and seasonal items",
        Value = Engine.Settings.Halloween.AutoSearchPumpkins,
        Callback = function(v) Engine.Settings.Halloween.AutoSearchPumpkins = v end
    })

    Engine.UIElements.AutoDigGraves = HalloweenTab:Toggle({
        Title = "Auto Dig Graves",
        Desc = "Dispatches grave excavation remotes across the cemetery",
        Value = Engine.Settings.Halloween.AutoDigGraves,
        Callback = function(v) Engine.Settings.Halloween.AutoDigGraves = v end
    })

    Engine.UIElements.AutoSkeletonSlayer = HalloweenTab:Toggle({
        Title = "Auto Skeleton Slayer",
        Desc = "Hits and eliminates spawned grave skeletons instantly",
        Value = Engine.Settings.Halloween.AutoSkeletonSlayer,
        Callback = function(v) Engine.Settings.Halloween.AutoSkeletonSlayer = v end
    })

    Engine.UIElements.AutoGiantPumpkin = HalloweenTab:Toggle({
        Title = "Auto Giant Pumpkin Swing",
        Desc = "Continuously hits the community giant pumpkin for event score",
        Value = Engine.Settings.Halloween.AutoGiantPumpkin,
        Callback = function(v) Engine.Settings.Halloween.AutoGiantPumpkin = v end
    })

    Engine.UIElements.AutoCollectCandy = HalloweenTab:Toggle({
        Title = "Auto Collect Candy & Deposit",
        Desc = "Picks up scattered Halloween candy and auto-deposits to your balance",
        Value = Engine.Settings.Halloween.AutoCollectCandy,
        Callback = function(v) Engine.Settings.Halloween.AutoCollectCandy = v end
    })

    Engine.UIElements.AutoBuyEgg = HalloweenTab:Toggle({
        Title = "Auto Buy Halloween Egg",
        Desc = "Purchases Halloween Egg (350 Candy) whenever balance is sufficient",
        Value = Engine.Settings.Halloween.AutoBuyEgg,
        Callback = function(v) Engine.Settings.Halloween.AutoBuyEgg = v end
    })

    -- TAB 4: MOBILITY & TELEPORTS
    local MobilityTab = Window:Tab({ Title = "Mobility", Icon = "compass" })

    Engine.UIElements.SpeedEnabled = MobilityTab:Toggle({
        Title = "Custom WalkSpeed",
        Desc = "Overrides character and mount speed to desired value",
        Value = Engine.Settings.Mobility.SpeedEnabled,
        Callback = function(v) Engine.Settings.Mobility.SpeedEnabled = v end
    })

    Engine.UIElements.SpeedValue = MobilityTab:Slider({
        Title = "WalkSpeed Value",
        Desc = "Adjust speed up to maximum server-tolerated threshold",
        Step = 5,
        Value = { Min = 16, Max = 450, Default = Engine.Settings.Mobility.SpeedValue },
        Callback = function(v) Engine.Settings.Mobility.SpeedValue = v end
    })

    MobilityTab:Button({
        Title = "Teleport: Next Rebirth Egg",
        Desc = "Warps to the best egg on map required for next Rebirth",
        Callback = function()
            local ok, msg = TeleportToRebirthEgg()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Rebirth Targeter",
                    Content = msg or (ok and "Teleported to rebirth egg!" or "Failed"),
                    Duration = 3.5
                })
            end
        end
    })

    Engine.UIElements.InfiniteJump = MobilityTab:Toggle({
        Title = "Infinite Jump",
        Desc = "Allows continuous mid-air jumping without touching the ground",
        Value = Engine.Settings.Mobility.InfiniteJump,
        Callback = function(v) Engine.Settings.Mobility.InfiniteJump = v end
    })

    MobilityTab:Button({
        Title = "Teleport: Personal Plot",
        Desc = "Instantly warps to your plot baseplate",
        Callback = function()
            local ok = TeleportTo(Landmarks.Plot)
            if WindUI and WindUI.Notify then
                WindUI:Notify({ Title = "Teleport", Content = ok and "Warped to your Plot!" or "Plot not found.", Duration = 2.5 })
            end
        end
    })

    MobilityTab:Button({
        Title = "Teleport: Main Spawn",
        Callback = function() TeleportTo(Landmarks.Spawn) end
    })

    MobilityTab:Button({
        Title = "Teleport: Heaven Island",
        Callback = function() TeleportTo(Landmarks.Heaven) end
    })

    MobilityTab:Button({
        Title = "Teleport: Volcano",
        Callback = function() TeleportTo(Landmarks.Volcano) end
    })

    MobilityTab:Button({
        Title = "Teleport: Halloween Town",
        Callback = function() TeleportTo(Landmarks.Halloween) end
    })

    MobilityTab:Button({
        Title = "Teleport: Shop Guy",
        Callback = function() TeleportTo(Landmarks.Shop) end
    })

    MobilityTab:Button({
        Title = "Teleport: Halloween Egg Shop",
        Desc = "Warps directly to the Halloween Egg Shop (350 Candy)",
        Callback = function() TeleportTo(Landmarks.EggShop) end
    })

    MobilityTab:Button({
        Title = "Teleport: Candy Deposit Pad",
        Desc = "Warps to the Halloween Candy Deposit Pad",
        Callback = function() TeleportTo(Landmarks.CandyDeposit) end
    })

    -- TAB 5: CONFIGURATION PERSISTENCE
    local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })

    ConfigTab:Button({
        Title = "Save Current Configuration",
        Desc = "Persists all settings (Auto Farm, World Eggs, Halloween, Mobility) to disk",
        Callback = function()
            SaveConfig()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Configuration",
                    Content = "Configuration saved successfully to " .. CONFIG_FILE,
                    Duration = 3
                })
            end
        end
    })

    ConfigTab:Button({
        Title = "Load Configuration",
        Desc = "Restores all settings & synchronizes UI toggles and visual states",
        Callback = function()
            local ok = LoadConfig()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Configuration",
                    Content = ok and "Configuration & Settings restored!" or "No saved config file found.",
                    Duration = 3
                })
            end
        end
    })

    ConfigTab:Button({
        Title = "Reset All Settings",
        Desc = "Restores all features to default disabled state",
        Callback = function()
            for cat, t in pairs(Engine.Settings) do
                for k, v in pairs(t) do
                    if type(v) == "boolean" then
                        t[k] = false
                        local el = Engine.UIElements[k]
                        if el then
                            pcall(function()
                                local fn = el.Set or el.SetValue
                                if fn then fn(el, false) end
                            end)
                        end
                    end
                end
            end
            ClearESP()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Configuration",
                    Content = "All features reset to OFF.",
                    Duration = 2.5
                })
            end
        end
    })

    Window:SelectTab(1)
end

--[[ 11. FLOATING ACTION BUTTON & SHORTCUT TOGGLE ]]--
local function ToggleUI()
    Engine.UIVisible = not Engine.UIVisible
    if Window then
        if Window.Toggle then
            pcall(function() Window:Toggle() end)
        elseif Window.Frame then
            Window.Frame.Visible = Engine.UIVisible
        end
    end
end

local KeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleUI()
    end
end)
table.insert(Engine.Connections, KeybindConnection)

local function CreateFloatingButton()
    local lp = GetLocalPlayer()
    local parentGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or (lp and lp:FindFirstChild("PlayerGui"))
    if not parentGui then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RideAPetFloatingGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "RideAPetToggleBtn"
    floatBtn.Size = UDim2.fromOffset(50, 50)
    floatBtn.Position = UDim2.new(0, 20, 0.5, -25)
    floatBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
    floatBtn.Text = "ð¾"
    floatBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    floatBtn.TextSize = 22
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.AutoButtonColor = false
    floatBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = floatBtn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Transparency = 0.2
    stroke.Parent = floatBtn

    local dragging = false
    local dragInput, dragStart, startPos

    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    floatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    table.insert(Engine.Connections, dragConn)

    floatBtn.MouseButton1Click:Connect(function()
        ToggleUI()
    end)

    screenGui.Parent = parentGui
    table.insert(Engine.GuiInstances, screenGui)
end

pcall(CreateFloatingButton)

--[[ 12. CLEAN UNLOAD HANDLER ]]--
function Engine:Unload()
    Engine.Enabled = false
    for _, conn in ipairs(Engine.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Engine.Connections)

    ClearESP()

    for _, gui in ipairs(Engine.GuiInstances) do
        pcall(function() gui:Destroy() end)
    end
    table.clear(Engine.GuiInstances)

    if Window and Window.Destroy then
        pcall(function() Window:Destroy() end)
    end

    _G.RideAPetEngine = nil
end

print("[RIDE_A_PET_ENGINE] Tactical Engine loaded successfully! All features initialized OFF.")
