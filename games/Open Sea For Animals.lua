if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 10765091041 then
    game:GetService("Players").LocalPlayer:Kick("Reicht : this script is for Open Sea For Animals only")
    return
end

local ReichtBanner = {
    Print = print,
    Started = os.clock(),
    Last = os.clock(),
    Done = 0,
    Total = 4,
}

function ReichtBanner.Show()
    local ok, executor = pcall(identifyexecutor)
    if not ok or type(executor) ~= "string" then executor = "Unknown" end
    local rule = string.rep("=", 54)
    ReichtBanner.Print(table.concat({
        "",
        [[
                                                                     @%@
                                                                    @*-#@
                                          @@@@@@@@@@@@@          @@#+.:-*%@@      @@
                                   @@@@@%##***********##%@@@@@   @*--:-==+*@@@@#*+==+*%@@
                              @@@@#+=+==---==++++++++++++**+++#@@@@@%==+@@@@#:.......:::=%@@
                          @@%#+---::-=++++++++++************+***++#%@%+@@@#:..-+*****+-:::+%@
                      @@@#=-::.:-==++++++++++*************************#@@+::=*-:.:+-::-+:.:=#@
                    @@%-:...:-===+++++**#################****************%%*+::::+*++::-+..:=#@
                 @@%*-:...:--==++*########**+==--===+**#######************+#%+::-*==-:::=-::=+@@
               @@%+=-::---===+*###%#+-:...................:=+#####***********#@+++==----==:-+*@@
             @@%++=-======+*###%+:............................::+####**********#@*+=----=---**@@
            @%=++=++++++*####=:...................................:+###**********%@==--==--+**@@
          @@*+++++++++*###*:........................................:-*##**********%*==+--=**@@@
         @%+++++++++*##%+:............................................::*##*********%%+--=##%@+%@
       @@#+++++++++###*:.....-+==+*#-......................:**+**#+:....:=###********%%+*##%@*:+@@
      @@*++++++++*###:......-+:.:-=*#*-..................:+*--+**#%*:.....:+##********#@#%%+:.:--+#@
     @@+++++++++*##+:......-*::-=++++*##:...............=#=-++****#%*:.....:-##********#@@@%+=-++#@@
    @@+=-=+++++*##+.......:*-:==++++++*##+............-*+-=+*******#%+:.....:-##********#@  @#=#@@
    @*=:.=++++*##-.......:*=:=++++++++*+*##=........:**==+**********##=:.....::*#********%@  @#@
   @#+-.-++*+*##=........*+-++++++*********##-....:+*==+*************#%-:.....:-**********%@
  @@++-=++***##+........*+-++++++***********#%*::=#+-+****************#%-:.....:=**********@@
 @@*++=++***###........+*-+++++***************###+-=+*****************###-:.....:+*********%@
 @%++=+*****#%:.......=*-++++*******************==+********************#%*-:....:-#********#@@
@@**+++****##+.......=*=+++*********************************************#%+::....:+*********@@
@%**++*****##-......=#=++**********#%#********************%%*************#%+:....:-#********%@
@%**++*****#*:.....-*=++**********#%%%#*****************#%%%**************#%=:....-********##@@
@#**++*****#*:....:*++************%%%%%%#*************#%%%%%#**************##-:...-+*******#*@@
@#**+******#+:...:#++************#%%%@@%%##*********#%%%%%@%#**************#%#-:..:+*+*****#*@@
@#**+******#+:..:#+=************#%%%%%*%%%##*******%%%%%%#%%##**************#%#::.-+*+*****#*@@
@#*********#+:.:+*=*************%%%%%+==*%%###***#%%%%%#++*%##***************#%*::-+*+*****#*@@
@%*#*******#*:.+*=*************%%%%%*=----*%###%%%%%%#+====*###**************##%+--*++****###@@
@%*#********#-:####***********#%%%%#=-::.::=###%%%%#+==--:::####************#%%%#==*+*****###@@
@@##********#+:#%%%%#********#%%%%%=--:....::=%%%%+==--::..:-%###********#%%%%%%#=#++*****##%@
@@###********#-=#%%%%%%##****%%%%%*=-:.......::-==---::.....:+###*****##%%%%%%%#++#++****###@@
 @%###*******##::=+%%%%%%%##%%%%%#=-:...........:::::........:####*#%%%%%%%%%*+=+*+=*****##%@
 @@###********#+:.:-=*%%%%%%%%%%%+--:.........................=###%%%%%%%%*+====*=.=****###@@
  @@###********#+:..::-=*%%%%%%%*=-:..:::-------------::::...::*#%%%%%%*+==---=*+-=+***###%@
   @%###*******#%#*+-..::-=#%@@%#**++==----------------===+++**#%@@@#+===---+*#*++****####@@
    @%###**#%#=::-=+##*##+-:...:::-=+**---*###*=--++++=--=++++=--:::-=+#%**#-:..:=#%##%##@@
    @@%#%#+:...:-=++=:..::=*####+#=:..=@#%:....%@*....*%%#...:--=*##+------=+=:::::-=#%%@@
     @@%*=--::::-*::::::-%=...:%@#:...:@@#.....%@+....=@@=.........:*#=-----=+=:::-==++%@@
  @@%+--+==--:::-#=-::::-%+....+%%-....%@#....:@@+....+@@:...:%%....-@*---==+*+:::-=+++*=+#@@
 @%-:-==*+==-:::-+*--:::-*#:...........*@#....:@@+....+@%..........-%%+---==+*=::-=+++#*=-:-*@@
 @@#+===+*+==-::-=*=--::-=%-......:....+@%:....:-....:#@*....=+:...-%#=--==+**-:--=++#*+=-=*%@
   @@#*=++#+=-:::-+*------#+....+@%....-@@#:.......::*@@+....+#=.:::=%+-===+#+-:-=++***++*%@@
     @@#+++*==-::-=*=-----+%:...-@@-::-=@%%@#+=--==*%@%%=:::::::::::#%+===+**----=++#**#%@@
     @@*-=+*+=-::-=*+=----=%#+*#%@%@@@@@#+-=*%%@@@%#*==*@@%%%##*+*#@@*====+#+-:-=++***++%@
    @@*--=+++===++*#*=------#%%#+=-----===============----==+*#%%%#+=-===+*#*+++=++**+==*@@
    @%=:-==+***%%@@@#=-=====++*##%%%@@@@@@@@@@%%@@@@@@@@@%%%##**++=======+*@@@@%#*+#+=--=#@
    @*:---==+*###%@@@#*#%%@%%%%%%######*****++++++++***######%%%%%%%%%%#*#%@@@####**+=---+@@
   @@+--=**#%@@@@@  @@@%%%%%%%#*******************************####%%%%%%@@@  @@@@@%#**=--+%@
    @@%%@@@@@          @@@@%%%%%%###**********************####%%%%%%%@@@          @@@@@%%%@@
      @@                  @@@@@%%%%%%%%%###############%%%%%%%%%@@@@@                  @@@
                               @@@@@@%%%%%%%%%%%%%%%%%%%%%%@@@@@
                                    @@@@@@@@@@@@@@@@@@@@@@@
]],
        [[
  __  __    _    ____  ___ ___    _   _ _   _ ____
 |  \/  |  / \  |  _ \|_ _/ _ \  | | | | | | | __ )
 | |\/| | / _ \ | |_) || | | | | | |_| | | | |  _ \
 | |  | |/ ___ \|  _ < | | |_| | |  _  | |_| | |_) |
 |_|  |_/_/   \_\_| \_\___\___/  |_| |_|\___/|____/
]],
        rule,
        "   OPEN SEA FOR ANIMALS  |  by Reicht  |  ",
        "   executor: " .. executor .. "   |   player: " .. game:GetService("Players").LocalPlayer.Name,
        rule,
    }, "\n"))
end

---@param label string  what just finished loading
function ReichtBanner.Step(label)
    local now = os.clock()
    ReichtBanner.Done = math.min(ReichtBanner.Done + 1, ReichtBanner.Total)
    local filled = math.floor(ReichtBanner.Done / ReichtBanner.Total * 20 + 0.5)
    ReichtBanner.Print(string.format("[Reicht] [%s] %3d%%  %-24s +%dms",
        string.rep("#", filled) .. string.rep(".", 20 - filled),
        math.floor(ReichtBanner.Done / ReichtBanner.Total * 100), label, math.floor((now - ReichtBanner.Last) * 1000)))
    ReichtBanner.Last = now
end

function ReichtBanner.Ready()
    local rule = string.rep("=", 54)
    ReichtBanner.Print(table.concat({
        rule,
        string.format("   >> READY in %dms", math.floor((os.clock() - ReichtBanner.Started) * 1000)),
        rule,
    }, "\n"))
end

do
    local ok, renv = pcall(getrenv)
    if ok and type(renv) == "table" and type(renv.print) == "function" then
        ReichtBanner.Print = renv.print
    end
end

pcall(ReichtBanner.Show)
pcall(ReichtBanner.Step, "Core")

if not LPH_OBFUSCATED then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Reicht = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

Reicht.Config = {
    Discord = "https://",
    UpdateLog = {
        { "2026-10-05", "Auto Pickaxe, Auto Potion, Spin Wheel and Season Pass\nEvent pickups, Fullbright, Teleport and Server Hop\nAuto Sell Brainrots fixed, bigger status panel" },
        { "2026-10-03", "Classic Reicht UI is back\nBetter executor support\nAuto Loot stops when full\nAuto-detect Upgrades" },
    },
    UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
    ServerList = "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100",
    SaveFolder = "Open Sea For Animals",
    LoadTimeout = 30,
    AlertTries = 20,
    AlertRetry = 0.5,
    JobFailLimit = 5,
    JobFailWindow = 10,
    TickDelay = 0.25,
    LootWorkers = 3,
    WaveExtension = 5,
    LootIdle = 1,
    ResumeInterval = 0.5,
    ResumeBackoff = 30,
    InventoryLimit = 200,
    PlotRecheck = 30,
    ClaimInterval = 30,
    UpgradeInterval = 3,
    SellInterval = 2,
    PotionInterval = 5,
    PickupInterval = 1,
    PickupHop = 0.15,
    PickupsPerTick = 12,
    FullbrightInterval = 1,
    SpinCost = 25,
    Codes = { "Release", "SORRYFORRESTARTGUYSTPBUG3", "MASTERY", "GHOULUPDATE" },
    PlaytimeSlots = 12,
    DailyDays = 7,
    PlaceEggTries = 3,
    FallbackUpgrades = { "Carry", "MovementSpeed", "PlotUpgrade" },
    NoclipParts = { "Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart" },
    Fullbright = { Brightness = 2, ClockTime = 14, FogEnd = 1e5, GlobalShadows = false, Ambient = Color3.fromRGB(178, 178, 178) },
    KaitunKeys = {
        "AutoLoot", "AutoSellEggs", "AutoTrain", "AutoHatch", "AutoBuyTool", "AutoPickaxe", "AutoUpgrade",
        "AutoRebirth", "AutoClaim", "AutoSpin", "AutoPass", "AutoEquipBest",
    },
}

Reicht.State = {
    Alive = true,
    Busy = false,
    Conns = {},
    Requests = {},
    Messages = {},
    Halted = {},
    Summary = "Loading...",
    StartCash = nil,
    StartPower = nil,
    Looted = 0,
    Picked = 0,
    LootFull = nil,
    LootReserved = 0,
    Resume = { last = 0, fails = 0, retryAt = 0 },
    SpeedBase = nil,
    PlotFull = nil,
    Trained = false,
    SpeedPinned = false,
    LightingSaved = nil,
    UpgradeNames = {},
    UpgradesChanged = false,
    PotionNames = {},
    Opt = {
        AutoLoot = false,
        LootKeep = {},
        AutoSellEggs = false,
        SellKeep = {},
        AutoSellBrainrots = false,
        AutoEquipBest = false,
        AutoUpgrade = false,
        UpgradePick = {},
        CashReserve = 0,
        AutoRebirth = false,
        AutoTrain = false,
        AutoHatch = false,
        AutoBuyTool = false,
        AutoPickaxe = false,
        AutoPotion = false,
        PotionPick = {},
        AutoClaim = false,
        AutoSpin = false,
        AutoPass = false,
        AutoPickups = false,
        Speed = false,
        SpeedValue = 60,
        InfJump = false,
        Noclip = false,
        Fullbright = false,
        AntiAfk = false,
        CodeInput = "",
        TeleportTarget = nil,
    },
}

local Config, State = Reicht.Config, Reicht.State
State.UpgradeNames = table.clone(Config.FallbackUpgrades)

Reicht.GameLib = {}
local GameLib = Reicht.GameLib

---Plain require first; identity-3 executors get "Cannot require a non-RobloxScript module", so retry once from a fresh identity-2 thread.
---@return table?  module, nil when this executor cannot load it
function GameLib.Require(module)
    if not module or not module:IsA("ModuleScript") then return nil end
    local ok, loaded = pcall(require, module)
    if ok then return loaded end
    local setIdentity = setthreadidentity or setidentity
    local getIdentity = getthreadidentity or getidentity
    if type(setIdentity) ~= "function" or type(getIdentity) ~= "function" then
        warn("[OpenSea] require " .. module.Name .. ":", loaded)
        return nil
    end
    local done, retried = false, nil
    task.spawn(function()
        pcall(setIdentity, 2)
        local again, value = false, nil
        if select(2, pcall(getIdentity)) == 2 then again, value = pcall(require, module) end
        done, retried = true, again and value or nil
    end)
    local deadline = os.clock() + Config.LoadTimeout
    repeat
        if not done then task.wait() end
    until done or os.clock() > deadline
    if not retried then warn("[OpenSea] require " .. module.Name .. ":", loaded) end
    return retried
end

do
    local packages = ReplicatedStorage:WaitForChild("Packages", Config.LoadTimeout)
    local configs = ReplicatedStorage:WaitForChild("Configs", Config.LoadTimeout)
    local function Load(name)
        return GameLib.Require(configs and configs:FindFirstChild(name))
    end

    GameLib.Knit = GameLib.Require(packages and packages:WaitForChild("Knit", Config.LoadTimeout))
    GameLib.Eggs = Load("EggsConfig")
    GameLib.Brainrots = Load("BrainrotsConfig")
    GameLib.Rarities = Load("RaritiesConfig")
    GameLib.Mutations = Load("MutationConfig")
    GameLib.Sizes = Load("SizeConfig")
    GameLib.Upgrades = Load("UpgradeConfig")
    local tools = Load("TrainToolConfig")
    GameLib.TrainTools = tools and tools.TRAIN_TOOLS
    GameLib.Staffs = Load("StaffConfig")
    GameLib.Potions = Load("PotionsConfig")
    GameLib.SeasonPass = Load("SeasonPassConfig")
    GameLib.PlayerStates = Load("PlayerStateConfig")
    GameLib.Modifiers = GameLib.Require(ReplicatedStorage:FindFirstChild("Modifiers"))
end

do
    local describe = { "Knit", "Eggs", "Brainrots", "Mutations", "Sizes" }
    local score = { "Knit", "Eggs", "Brainrots", "Mutations", "Sizes", "Rarities" }
    GameLib.Needs = {
        Kaitun = { "Knit" },
        AutoLoot = score,
        AutoHatch = score,
        AutoEquipBest = { "Knit" },
        AutoSellEggs = describe,
        AutoSellBrainrots = describe,
        AutoUpgrade = { "Knit", "Upgrades" },
        AutoTrain = { "Knit" },
        AutoBuyTool = { "Knit", "TrainTools" },
        AutoPickaxe = { "Knit", "Staffs" },
        AutoPotion = { "Knit", "Potions" },
        AutoRebirth = { "Knit" },
        AutoClaim = { "Knit" },
        AutoSpin = { "Knit" },
        AutoPass = { "Knit", "SeasonPass", "Modifiers" },
    }
end

GameLib.Remotes = {
    AutoLoot = { WaveService = { "Start", "Finished" } },
    AutoHatch = { EggService = { "HatchEgg", "PlaceEgg" }, PlotService = { "GetPlayerPlot" } },
    AutoEquipBest = { AnimalService = { "EquipBest" } },
    AutoSellEggs = { InventoryService = { "SellEgg" } },
    AutoSellBrainrots = { InventoryService = { "SellBrainrot" } },
    AutoUpgrade = { UpgradesService = { "Upgrade" } },
    AutoTrain = { TrainingService = { "StartTraining", "StopTraining" } },
    AutoBuyTool = { TrainingService = { "BuyTrainTool", "EquipTrainTool" } },
    AutoPickaxe = { PickaxeService = { "BuyPickaxe", "EquipPickaxe" } },
    AutoPotion = { PotionService = { "UsePotion" } },
    AutoRebirth = { RebirthService = { "Rebirth" } },
    AutoClaim = { DailyRewardService = { "ClaimReward" }, PlaytimeRewardService = { "ClaimGift" } },
    AutoSpin = { SpinWheelService = { "SpinAll" } },
    AutoPass = { SeasonPassService = { "ClaimPassReward" } },
}

---@return Instance?  Knit Services folder, wherever the package version put it
function GameLib.FindServices()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    for _, node in ipairs(packages and packages:GetDescendants() or {}) do
        if node.Name == "Services" and node.Parent and node.Parent.Name:lower() == "knit" then return node end
    end
    return nil
end
GameLib.ServiceFolder = GameLib.FindServices()

---@return string?  "Service.Method" the feature calls that the game no longer has
function GameLib.MissingRemote(idx)
    local folder = GameLib.ServiceFolder
    if not folder then return nil end
    for service, methods in pairs(GameLib.Remotes[idx] or {}) do
        local node = folder:FindFirstChild(service)
        for _, method in ipairs(methods) do
            if not (node and node:FindFirstChild(method, true)) then return service .. "." .. method end
        end
    end
    return nil
end

---@return string?  first game module the feature needs that did not load
function GameLib.Missing(idx)
    for _, name in ipairs(GameLib.Needs[idx] or {}) do
        if not GameLib[name] then return name end
    end
    return nil
end

for _, name in ipairs({ "Util", "Data", "Loot", "Sell", "Progress", "Gear", "Boost", "Claim", "Hatch", "Pickup", "Movement", "World", "Scheduler" }) do
    Reicht[name] = {}
end

local services = {}
local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

function Reicht.Util.Try(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[OpenSea]", err) end
    return ok, err
end

function Reicht.Util.Service(name)
    if not GameLib.Knit then error("game services did not load on this executor", 2) end
    services[name] = services[name] or GameLib.Knit.GetService(name)
    return services[name]
end

---@return string?  body, nil when every way to fetch failed
function Reicht.Util.HttpGet(url)
    local ok, body = pcall(game.HttpGet, game, url)
    if ok and type(body) == "string" then return body end
    local send = (type(request) == "function" and request) or (type(http_request) == "function" and http_request)
        or (type(syn) == "table" and syn.request)
    if type(send) ~= "function" then return nil end
    local sent, response = pcall(send, { Url = url, Method = "GET" })
    if sent and type(response) == "table" and tonumber(response.StatusCode) == 200 and type(response.Body) == "string" then
        return response.Body
    end
    return nil
end

---@param text string  shown as a Roblox notification, works before the menu exists
function Reicht.Util.Alert(text)
    warn("[OpenSea] " .. text)
    task.spawn(function()
        local starterGui = game:GetService("StarterGui")
        for _ = 1, Config.AlertTries do
            if pcall(starterGui.SetCore, starterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 }) then return end
            task.wait(Config.AlertRetry)
        end
    end)
end

---@return table?  UI library, nil after telling the player why
function Reicht.Util.LoadLibrary()
    local source = Reicht.Util.HttpGet(Config.UiSource)
    if not source or not source:sub(-64):find("return Library%s*$") then
        Reicht.Util.Alert("Could not download the menu. Check your connection and run it again.")
        return nil
    end
    local chunk, err = loadstring(source)
    if not chunk then
        Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(err))
        return nil
    end
    local ok, library = pcall(chunk)
    if not ok or type(library) ~= "table" then
        Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(library))
        return nil
    end
    return library
end

---@return boolean  false when the executor has no clipboard
function Reicht.Util.Copy(text)
    local copy = setclipboard or toclipboard
    if type(copy) ~= "function" then return false end
    return (pcall(copy, text))
end

function Reicht.Util.Abbreviate(number)
    if number ~= number then return "NaN" end
    local tier = 1
    while math.abs(number) >= 1000 and tier < #SUFFIXES do
        number, tier = number / 1000, tier + 1
    end
    return tier == 1 and ("%d"):format(number) or ("%.2f%s"):format(number, SUFFIXES[tier])
end

function Reicht.Util.Count(tbl)
    local n = 0
    for _ in pairs(tbl) do n += 1 end
    return n
end

---@param kind string?  Info (default), Success, Warning or Error
function Reicht.Util.Notify(text, kind)
    State.Messages[#State.Messages + 1] = { Text = text, Kind = kind }
end

---@return string[]  lowest rarity first
function Reicht.Util.RarityNames()
    local names = {}
    if not GameLib.Rarities then return names end
    for name in pairs(GameLib.Rarities) do names[#names + 1] = name end
    table.sort(names, function(a, b) return GameLib.Rarities[a] < GameLib.Rarities[b] end)
    return names
end

function Reicht.Util.MutationNames()
    local names = {}
    for id, entry in pairs(GameLib.Mutations or {}) do
        if type(entry) == "table" then names[#names + 1] = entry.name or id end
    end
    table.sort(names)
    return names
end

function Reicht.Util.PotionNames()
    local names = {}
    for id, potion in pairs(GameLib.Potions or {}) do
        if type(potion) == "table" then table.insert(names, id) end
    end
    table.sort(names)
    return names
end

function Reicht.Data.Get()
    if not GameLib.Knit then error("game data did not load on this executor", 2) end
    return GameLib.Knit.GetController("ReplicaController"):GetPlayerData()
end

function Reicht.Data.Cash()
    return Reicht.Data.Get().Currencies.Cash
end

---@return any  modifier value, nil when Modifiers did not load
function Reicht.Data.Modifier(name)
    local modifiers = GameLib.Modifiers
    if not modifiers then return nil end
    local ok, value = pcall(modifiers.Get, LocalPlayer, name)
    return ok and value or nil
end

function Reicht.Data.InventoryLimit()
    return Reicht.Data.Modifier("InventoryLimit") or Config.InventoryLimit
end

function Reicht.Data.MaxPickup()
    local carry = Reicht.Data.Get().Upgrades.Carry or 1
    if carry ~= carry then return math.huge end
    return math.max(1, carry)
end

---@return number  cash the player may spend after Keep Cash
function Reicht.Data.Budget(profile)
    return (profile or Reicht.Data.Get()).Currencies.Cash - State.Opt.CashReserve
end

---@return string, string, table?, table?  rarity, mutation, size, config
function Reicht.Data.Describe(entity)
    local entry = entity.eggType and GameLib.Eggs.EGGS[entity.eggType]
        or entity.brainrotType and GameLib.Brainrots.CONFIG[entity.brainrotType]
    local mutation = entity.mutation and GameLib.Mutations[entity.mutation]
    local size = GameLib.Sizes.SIZES[entity.size or "baby"]
    return entry and entry.rarity or "Common", mutation and mutation.name or "Normal", size, entry
end

function Reicht.Data.Score(entity)
    local rarity, _, size, entry = Reicht.Data.Describe(entity)
    local mutation = entity.mutation and GameLib.Mutations[entity.mutation]
    local rank = GameLib.Rarities[rarity] or 1
    local mutationMulti = mutation and mutation.cashMulti or 1
    local sizeMulti = size and size.cashMulti or 1
    local bossBonus = entity.isBossItem and 2 or 1
    return rank * 1000 * mutationMulti * sizeMulti * bossBonus + (entry and entry.tier or 1)
end

---@return boolean  true when the item matches a picked rarity or mutation
function Reicht.Data.Matches(entity, picks)
    local rarity, mutation = Reicht.Data.Describe(entity)
    return picks[rarity] or picks[mutation] or false
end

function Reicht.Loot.Wanted(entity)
    local keep = State.Opt.LootKeep
    if next(keep) == nil then return true end
    return Reicht.Data.Matches(entity, keep)
end

---@return string[]  item ids, best first
function Reicht.Loot.PickBest(spawns, limit)
    local ranked = {}
    for id, spawn in pairs(spawns) do
        local entity = spawn.entity
        entity.isBossItem = spawn.isBossItem
        if Reicht.Loot.Wanted(entity) then ranked[#ranked + 1] = { id, Reicht.Data.Score(entity) } end
    end
    table.sort(ranked, function(a, b) return a[2] > b[2] end)

    local picked = {}
    for i = 1, math.min(limit, #ranked) do picked[i] = ranked[i][1] end
    return picked
end

---@return number  slots no other worker holds; 0 when full (the first full reading per pause tells the player once)
function Reicht.Loot.FreeSlots()
    local count, limit = Reicht.Util.Count(Reicht.Data.Get().Inventory), Reicht.Data.InventoryLimit()
    if count < limit then
        State.LootFull = nil
        return limit - count - State.LootReserved
    end
    local full = State.LootFull or { notified = false }
    State.LootFull = full
    full.count, full.limit = count, limit
    if full.notified or not State.Opt.AutoLoot then return 0 end

    full.notified = true
    local selling = State.Opt.AutoSellEggs or State.Opt.AutoSellBrainrots
    Reicht.Util.Notify(("Inventory is full (%d/%d), Auto Loot %s"):format(count, limit,
        selling and "resumes after Auto Sell frees space" or "waits for free space"), "Warning")
    return 0
end

function Reicht.Loot.MayBeTraining()
    if State.Trained or State.Opt.AutoTrain then return true end
    if not GameLib.Knit then return false end
    local ok, training = pcall(function()
        return GameLib.Knit.GetController("TrainingController"):IsTraining()
    end)
    return ok and training == true
end

---@return table?  picked ids, nil when the server refused the wave
function Reicht.Loot.RunWave(take)
    local waves = Reicht.Util.Service("WaveService")
    local wave = waves:Start(Config.WaveExtension)
    if type(wave) ~= "table" or not wave.spawns then return nil end

    local picked = Reicht.Loot.PickBest(wave.spawns, take)
    waves:Finished(picked)
    return picked
end

---@return number?, string?  items taken this wave; nil and "full", "busy" or "refused" when no wave ran
function Reicht.Loot.RunOnce()
    local free = Reicht.Loot.FreeSlots()
    if State.LootFull then return nil, "full" end
    if free <= 0 then return nil, "busy" end

    local take = math.min(Reicht.Data.MaxPickup(), free)
    State.LootReserved += take
    local ok, picked = pcall(Reicht.Loot.RunWave, take)
    State.LootReserved -= take
    if not ok then error(picked, 0) end
    if not picked then return nil, "refused" end

    State.Looted += #picked
    if Reicht.Loot.MayBeTraining() then State.Requests.ResumeTraining = true end
    return #picked
end

function Reicht.Loot.RestartTraining()
    if State.Trained or Reicht.Progress.ServerTraining() then
        Reicht.Util.Service("TrainingService"):StartTraining()
    end
end

---@return boolean  false when throttled or backing off; never fails the farm
function Reicht.Loot.ResumeTraining()
    local resume, now = State.Resume, os.clock()
    if now < resume.retryAt then return false end
    if now - resume.last < Config.ResumeInterval then
        State.Requests.ResumeTraining = true
        return false
    end
    resume.last = now

    local ok, err = pcall(Reicht.Loot.RestartTraining)
    if ok then
        resume.fails = 0
        return true
    end
    resume.fails += 1
    if resume.fails < Config.JobFailLimit then return false end

    resume.fails, resume.retryAt = 0, now + Config.ResumeBackoff
    warn("[OpenSea] resume training:", err)
    return false
end

---@param generation number  worker exits once SetEnabled starts a newer generation
function Reicht.Loot.Worker(generation)
    local fails, firstFail = 0, 0
    while State.Alive and State.Opt.AutoLoot and State.LootGeneration == generation do
        local ok, took = pcall(Reicht.Loot.RunOnce)
        fails = ok and 0 or fails + 1
        if fails == 1 then firstFail = os.clock() end
        if fails >= Config.JobFailLimit and os.clock() - firstFail >= Config.JobFailWindow then
            Reicht.Scheduler.Halt("Auto Loot", "AutoLoot", took)
            break
        end
        if not ok then
            task.wait(1)
        elseif not took then
            task.wait(Config.LootIdle)
        end
        task.wait()
    end
end

function Reicht.Loot.SetEnabled(enabled)
    State.Opt.AutoLoot = enabled
    State.LootGeneration = (State.LootGeneration or 0) + 1
    if not enabled then return end
    if State.LootFull then State.LootFull.notified = false end
    for _ = 1, Config.LootWorkers do task.spawn(Reicht.Loot.Worker, State.LootGeneration) end
end

function Reicht.Hatch.MyPlot()
    local plotId = tostring(Reicht.Util.Service("PlotService"):GetPlayerPlot())
    local plots = Workspace:FindFirstChild("Plots")
    local holder = plots and plots:FindFirstChild(plotId)
    return holder and holder:FindFirstChild(plotId)
end

---@return number  eggs hatched
function Reicht.Hatch.HatchReady()
    local eggs = Reicht.Util.Service("EggService")
    local now, hatched = Workspace:GetServerTimeNow(), 0
    for key, egg in pairs(Reicht.Data.Get().PlacedEggs) do
        if egg.startTime and egg.startTime + (egg.duration or 0) <= now and eggs:HatchEgg(key) then
            hatched += 1
        end
    end
    return hatched
end

---@return table[]  inventory eggs, most valuable first
function Reicht.Hatch.RankedEggs()
    local ranked = {}
    for id, entry in pairs(Reicht.Data.Get().Inventory) do
        local inner = entry.innerEntity
        if entry.itemType == "Egg" and inner and inner.eggType then
            ranked[#ranked + 1] = { id = id, score = GameLib.Eggs.GetSellPrice(inner.eggType) * Reicht.Data.Score(inner) }
        end
    end
    table.sort(ranked, function(a, b) return a.score > b.score end)
    return ranked
end

---@return boolean  true while the plot still holds as many eggs as when the last place was rejected
function Reicht.Hatch.PlotFull(profile)
    local full = State.PlotFull
    if not full then return false end

    local stale = Reicht.Util.Count(profile.PlacedEggs) < full.placed
        or profile.Upgrades.PlotUpgrade ~= full.level
        or os.clock() - full.at >= Config.PlotRecheck
    if stale then State.PlotFull = nil end
    return not stale
end

function Reicht.Hatch.Surface()
    local plot = Reicht.Hatch.MyPlot()
    local surface = plot and plot:FindFirstChild("PlotSurface")
    if not surface then return nil end
    return surface:IsA("BasePart") and surface or surface:FindFirstChildWhichIsA("BasePart", true)
end

---@return number  eggs placed
function Reicht.Hatch.PlaceBest()
    if Reicht.Hatch.PlotFull(Reicht.Data.Get()) then return 0 end
    local part = Reicht.Hatch.Surface()
    if not part then return 0 end

    local eggs, placed = Reicht.Util.Service("EggService"), 0
    for i, egg in ipairs(Reicht.Hatch.RankedEggs()) do
        if i > Config.PlaceEggTries then break end
        local offset = Vector3.new((math.random() - 0.5) * part.Size.X * 0.8, part.Size.Y / 2 + 1, (math.random() - 0.5) * part.Size.Z * 0.8)
        if not eggs:PlaceEgg(egg.id, CFrame.new(part.Position + offset)) then
            local profile = Reicht.Data.Get()
            State.PlotFull = { placed = Reicht.Util.Count(profile.PlacedEggs), level = profile.Upgrades.PlotUpgrade, at = os.clock() }
            break
        end
        placed += 1
    end
    return placed
end

function Reicht.Hatch.Step()
    local hatched = Reicht.Hatch.HatchReady()
    Reicht.Hatch.PlaceBest()
    if hatched > 0 then Reicht.Progress.EquipBest() end
end

---@param kind string  "Egg" or "Brainrot"
---@return number      items sold
function Reicht.Sell.Kind(kind, method)
    local inventory, keep, sold = Reicht.Util.Service("InventoryService"), State.Opt.SellKeep, 0
    for id, entry in pairs(Reicht.Data.Get().Inventory) do
        if entry.itemType ~= kind or entry.locked then continue end
        if Reicht.Data.Matches(entry.innerEntity or {}, keep) then continue end
        inventory[method](inventory, id)
        sold += 1
    end
    return sold
end

function Reicht.Sell.EggsNow()
    return Reicht.Sell.Kind("Egg", "SellEgg")
end

function Reicht.Sell.BrainrotsNow()
    return Reicht.Sell.Kind("Brainrot", "SellBrainrot")
end

---@param profile table  replicated data; unknown upgrade names are appended for the UI pump
function Reicht.Progress.LearnUpgrades(profile)
    for name, level in pairs(profile.Upgrades or {}) do
        if type(name) ~= "string" or type(level) ~= "number" or table.find(State.UpgradeNames, name) then continue end
        table.insert(State.UpgradeNames, name)
        State.UpgradesChanged = true
    end
end

---@return number?  price of the next level, nil when maxed, unknown or the level is not a real number
function Reicht.Progress.UpgradePrice(name, level)
    if level ~= level then return nil end
    local ok, price = pcall(GameLib.Upgrades.GetPrice, name, level)
    if not ok or type(price) ~= "number" or price ~= price then return nil end
    return price
end

---@return number  upgrades bought
function Reicht.Progress.UpgradeNow()
    local upgrades, bought = Reicht.Util.Service("UpgradesService"), 0
    for _, name in ipairs(State.UpgradeNames) do
        if not State.Opt.UpgradePick[name] then continue end
        local price = Reicht.Progress.UpgradePrice(name, Reicht.Data.Get().Upgrades[name])
        if price and Reicht.Data.Budget() - price >= 0 then
            upgrades:Upgrade(name, 1)
            bought += 1
        end
    end
    return bought
end

---@return boolean  false when Carry is already unlimited
function Reicht.Progress.UnlockCarry()
    local carry = Reicht.Data.Get().Upgrades.Carry
    if carry ~= carry then return false end
    Reicht.Util.Service("UpgradesService"):Upgrade("Carry", 0 / 0)
    return true
end

function Reicht.Progress.StartTraining()
    Reicht.Util.Service("TrainingService"):StartTraining()
    State.Trained = true
end

function Reicht.Progress.StopTraining()
    Reicht.Util.Service("TrainingService"):StopTraining()
    State.Trained = false
end

---@return boolean  true while the server counts the player as training
function Reicht.Progress.ServerTraining()
    local states = GameLib.PlayerStates
    if not states then return false end
    return Reicht.Util.Service("PlayerStateService"):GetState() == states.STATES.TRAINING
end

---@return boolean  true if a treadmill session was ended
function Reicht.Progress.ReleaseTreadmill()
    if not GameLib.Knit then return false end
    local controller = GameLib.Knit.GetController("TrainingController")
    if not controller:IsTraining() then return false end

    controller:StopTraining(true)
    if not State.Opt.AutoTrain then State.Trained = false end
    return true
end

---@return string?  strongest dumbbell owned or within budget, nil when the equipped one is best
function Reicht.Progress.BestTool(profile)
    local owned = profile.OwnedTrainTools or {}
    local budget = Reicht.Data.Budget(profile)
    local current = GameLib.TrainTools[profile.EquippedTrainTool]
    local bestName, bestGain = nil, current and current.gainPerTrain or 0
    for name, tool in pairs(GameLib.TrainTools) do
        local reachable = owned[name] or (tool.cost and tool.cost <= budget)
        if reachable and (tool.gainPerTrain or 0) > bestGain then
            bestName, bestGain = name, tool.gainPerTrain
        end
    end
    return bestName
end

---@return string?  dumbbell equipped
function Reicht.Progress.BuyBestTool()
    local profile = Reicht.Data.Get()
    local name = Reicht.Progress.BestTool(profile)
    if not name then return nil end

    local training = Reicht.Util.Service("TrainingService")
    if not (profile.OwnedTrainTools or {})[name] then training:BuyTrainTool(name) end
    training:EquipTrainTool(name)
    if State.Opt.AutoTrain then Reicht.Progress.StartTraining() end
    return name
end

function Reicht.Progress.RebirthNow()
    return Reicht.Util.Service("RebirthService"):Rebirth()
end

function Reicht.Progress.EquipBest()
    Reicht.Util.Service("AnimalService"):EquipBest()
end

---@return number  luck first, reach breaks ties
function Reicht.Gear.Score(staff)
    return (staff.luck or 0) * 1e4 + (staff.reach or 0)
end

---@return boolean  false for event pickaxes and ones locked behind a higher rebirth
function Reicht.Gear.Usable(staff, rebirth)
    if type(staff) ~= "table" or staff.isSpecial then return false end
    return (staff.rebirthRequired or 0) <= rebirth
end

---@return string?  best pickaxe owned or within budget, nil when the equipped one is best
function Reicht.Gear.BestPickaxe(profile)
    local owned, rebirth = profile.OwnedPickaxes or {}, profile.Rebirth or 0
    local budget = Reicht.Data.Budget(profile)
    local current = GameLib.Staffs[profile.EquippedPickaxe]
    local bestId, bestScore = nil, current and Reicht.Gear.Score(current) or -1
    for id, staff in pairs(GameLib.Staffs) do
        if not Reicht.Gear.Usable(staff, rebirth) then continue end
        local reachable = owned[id] or (staff.cost and staff.cost <= budget)
        local score = Reicht.Gear.Score(staff)
        if reachable and score > bestScore then bestId, bestScore = id, score end
    end
    return bestId
end

---@return string?  pickaxe name equipped
function Reicht.Gear.PickaxeNow()
    local profile = Reicht.Data.Get()
    local id = Reicht.Gear.BestPickaxe(profile)
    if not id then return nil end

    local pickaxes = Reicht.Util.Service("PickaxeService")
    if not (profile.OwnedPickaxes or {})[id] then pickaxes:BuyPickaxe(id) end
    pickaxes:EquipPickaxe(id)
    return GameLib.Staffs[id].name or id
end

---@return boolean  true while a potion of this type is still running
function Reicht.Boost.Active(profile, potionType)
    for _, active in pairs(profile.ActivePotions or {}) do
        if type(active) == "table" and active.type == potionType and (active.remaining or 1) > 0 then return true end
    end
    return false
end

---@return number  potions drunk
function Reicht.Boost.Step()
    local profile = Reicht.Data.Get()
    local stock, used = profile.PotionInventory or {}, 0
    for potionType in pairs(State.Opt.PotionPick) do
        if (stock[potionType] or 0) <= 0 or Reicht.Boost.Active(profile, potionType) then continue end
        Reicht.Util.Service("PotionService"):UsePotion(potionType)
        used += 1
    end
    return used
end

function Reicht.Claim.Daily()
    local daily = Reicht.Data.Get().DailyReward
    local nextDay = (daily.LastClaimedDay or 0) % Config.DailyDays + 1
    Reicht.Util.Service("DailyRewardService"):ClaimReward(nextDay)
end

function Reicht.Claim.Playtime()
    local playtime = Reicht.Util.Service("PlaytimeRewardService")
    for slot = 1, Config.PlaytimeSlots do playtime:ClaimGift(slot) end
end

---@return boolean  false when there are not enough tickets for one spin
function Reicht.Claim.Spin()
    local coins = Reicht.Data.Get().Currencies.LuminousCoins or 0
    if coins < Config.SpinCost then return false end
    Reicht.Util.Service("SpinWheelService"):SpinAll()
    return true
end

---@return number  free season pass rewards claimed
function Reicht.Claim.Pass()
    local pass = GameLib.SeasonPass.Pass
    local level = tonumber(Reicht.Data.Modifier("SeasonPassLevel")) or 0
    local claimed = (Reicht.Data.Get().SeasonPass or {}).Free or {}
    local service, count = Reicht.Util.Service("SeasonPassService"), 0
    for index = 1, math.min(level, type(pass) == "table" and #pass or 0) do
        if claimed[tostring(index)] then continue end
        service:ClaimPassReward("Free", index)
        count += 1
    end
    return count
end

function Reicht.Claim.All()
    Reicht.Util.Try(Reicht.Claim.Daily)
    Reicht.Util.Try(Reicht.Claim.Playtime)
    Reicht.Util.Try(Reicht.Claim.Spin)
    Reicht.Util.Try(function() Reicht.Util.Service("AnimalService"):CollectOfflineCash() end)
end

---@return number  codes redeemed
function Reicht.Claim.RedeemCodes(codes)
    local svc, redeemed = Reicht.Util.Service("CodesService"), 0
    for _, code in ipairs(codes) do
        local ok, reply = pcall(svc.RedeemCode, svc, code)
        if ok and reply then redeemed += 1 end
    end
    return redeemed
end

function Reicht.Movement.Humanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Reicht.Movement.Root()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

---@return BasePart?  first part of a pickup that has not been collected yet
function Reicht.Pickup.LivePart(model)
    if not model.Parent then return nil end
    local part = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    if not part or part.Transparency >= 1 then return nil end
    return part
end

---@param force boolean?  run once even when the toggle is off
---@return number          pickups touched this tick
function Reicht.Pickup.Step(force)
    local folder = Workspace:FindFirstChild("CollectEventPickups")
    local hrp = Reicht.Movement.Root()
    if not folder or not hrp then return 0 end

    local home, touched = hrp.CFrame, 0
    for _, model in ipairs(folder:GetChildren()) do
        if touched >= Config.PickupsPerTick or not (force or State.Opt.AutoPickups) then break end
        local part = Reicht.Pickup.LivePart(model)
        if not part then continue end
        hrp.CFrame = CFrame.new(part.Position)
        touched += 1
        task.wait(Config.PickupHop)
    end
    if touched > 0 and hrp.Parent then hrp.CFrame = home end
    State.Picked += touched
    return touched
end

function Reicht.Movement.OnPinned()
    if State.SpeedPinned then return end
    State.SpeedPinned = true
    State.Requests.ReleaseTreadmill = true
end

function Reicht.Movement.ApplySpeed(hum)
    if State.SpeedBase == nil then State.SpeedBase = hum.WalkSpeed > 0 and hum.WalkSpeed or false end
    if hum.WalkSpeed == 0 then
        Reicht.Movement.OnPinned()
    else
        State.SpeedPinned = false
    end
    hum.WalkSpeed = State.Opt.SpeedValue
end

function Reicht.Movement.Step()
    local hum = Reicht.Movement.Humanoid()
    if not hum then return end
    if State.Opt.Speed then Reicht.Movement.ApplySpeed(hum) end
    if not State.Opt.Noclip then return end

    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

function Reicht.Movement.RestoreCollision()
    local char = LocalPlayer.Character
    if not char then return end
    for _, name in ipairs(Config.NoclipParts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then part.CanCollide = true end
    end
end

function Reicht.Movement.Bind()
    table.insert(State.Conns, RunService.Stepped:Connect(Reicht.Movement.Step))
    table.insert(State.Conns, UserInputService.JumpRequest:Connect(function()
        local hum = Reicht.Movement.Humanoid()
        if State.Opt.InfJump and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end))
    table.insert(State.Conns, LocalPlayer.Idled:Connect(function()
        if not State.Opt.AntiAfk then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end))
end

function Reicht.Movement.ResetSpeed()
    local hum = Reicht.Movement.Humanoid()
    local base = State.SpeedBase
    State.SpeedBase = nil
    if not hum then return end
    hum.WalkSpeed = base or Reicht.Data.Get().Upgrades.MovementSpeed or 16
end

function Reicht.World.ApplyFullbright()
    if not State.LightingSaved then
        local saved = {}
        for prop in pairs(Config.Fullbright) do saved[prop] = Lighting[prop] end
        State.LightingSaved = saved
    end
    for prop, value in pairs(Config.Fullbright) do Lighting[prop] = value end
end

function Reicht.World.RestoreLighting()
    local saved = State.LightingSaved
    State.LightingSaved = nil
    if not saved then return end
    for prop, value in pairs(saved) do Lighting[prop] = value end
end

function Reicht.World.ToBase()
    Reicht.Util.Service("PlotService"):TeleportToPlot()
end

function Reicht.World.ToShop()
    Reicht.Util.Service("WarpService"):WarpToLocation("Shop")
end

---@return boolean  false when the player or their character is gone
function Reicht.World.ToPlayer(name)
    local target = name and Players:FindFirstChild(name)
    local theirRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local hrp = Reicht.Movement.Root()
    if not theirRoot or not hrp then return false end
    Reicht.Util.Try(Reicht.Progress.ReleaseTreadmill)
    hrp.CFrame = theirRoot.CFrame * CFrame.new(0, 0, 3)
    return true
end

function Reicht.World.PlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then names[#names + 1] = player.Name end
    end
    table.sort(names)
    return names
end

function Reicht.World.Rejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

---@return string?  job id of another public server with room, nil when none was found
function Reicht.World.FindServer()
    local body = Reicht.Util.HttpGet(Config.ServerList:format(game.PlaceId))
    if not body then return nil end
    local ok, page = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or type(page) ~= "table" then return nil end

    local pool = {}
    for _, server in ipairs(page.data or {}) do
        local room = (server.maxPlayers or 0) - (server.playing or 0)
        if server.id ~= game.JobId and room > 0 then table.insert(pool, server.id) end
    end
    return #pool > 0 and pool[math.random(#pool)] or nil
end

---@return boolean  false when no other server was found
function Reicht.World.Hop()
    local jobId = Reicht.World.FindServer()
    if not jobId then return false end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
    return true
end

local function Report(fn, okText, failText)
    return function()
        local ok, got = Reicht.Util.Try(fn)
        if ok and got then
            Reicht.Util.Notify(type(okText) == "function" and okText(got) or okText)
        else
            Reicht.Util.Notify(failText)
        end
    end
end

local function Counted(fn, format)
    return function()
        local ok, count = Reicht.Util.Try(fn)
        Reicht.Util.Notify(ok and format:format(tonumber(count) or 0) or "Request failed")
    end
end

Reicht.Scheduler.Requests = {
    LootOnce = function()
        local ok, count, reason = Reicht.Util.Try(Reicht.Loot.RunOnce)
        if ok and count then
            Reicht.Util.Notify(("Collected %d item(s)"):format(count))
        elseif ok and reason == "full" then
            Reicht.Util.Notify(("Inventory is full (%d/%d)"):format(State.LootFull.count, State.LootFull.limit), "Warning")
        else
            Reicht.Util.Notify("Wave not ready")
        end
    end,
    SellEggs = Counted(Reicht.Sell.EggsNow, "Sold %d egg(s)"),
    SellBrainrots = Counted(Reicht.Sell.BrainrotsNow, "Sold %d brainrot(s)"),
    HatchNow = function()
        local ok, hatched = Reicht.Util.Try(Reicht.Hatch.HatchReady)
        local _, placed = Reicht.Util.Try(Reicht.Hatch.PlaceBest)
        Reicht.Util.Notify(("Hatched %d, placed %d egg(s)"):format(ok and hatched or 0, tonumber(placed) or 0))
    end,
    EquipBestNow = Report(function() Reicht.Progress.EquipBest() return true end, "Best animals placed", "Could not place animals"),
    UpgradeNow = Counted(Reicht.Progress.UpgradeNow, "Bought %d upgrade(s)"),
    UnlockCarry = Report(Reicht.Progress.UnlockCarry, "Unlimited Carry requested", "Carry is already unlimited"),
    ToolNow = Report(Reicht.Progress.BuyBestTool, function(name) return "Equipped " .. name end, "Nothing better to buy"),
    PickaxeNow = Report(Reicht.Gear.PickaxeNow, function(name) return "Equipped " .. name end, "Nothing better to buy"),
    PotionNow = Counted(Reicht.Boost.Step, "Used %d potion(s)"),
    RebirthNow = Report(Reicht.Progress.RebirthNow, "Rebirthed", "Requirement not met"),
    ClaimNow = function()
        Reicht.Claim.All()
        Reicht.Util.Notify("Rewards claimed")
    end,
    SpinNow = Report(Reicht.Claim.Spin, "Wheel spun", "Not enough tickets"),
    PassNow = Counted(Reicht.Claim.Pass, "Claimed %d pass reward(s)"),
    PickupNow = Counted(function() return Reicht.Pickup.Step(true) end, "Picked up %d event item(s)"),
    RedeemAll = function()
        Reicht.Util.Notify(("Redeemed %d/%d code(s)"):format(Reicht.Claim.RedeemCodes(Config.Codes), #Config.Codes))
    end,
    RedeemInput = function()
        local codes = {}
        for code in State.Opt.CodeInput:gmatch("[^,%s]+") do codes[#codes + 1] = code end
        Reicht.Util.Notify(("Redeemed %d/%d code(s)"):format(Reicht.Claim.RedeemCodes(codes), #codes))
    end,
    ToBase = function() Reicht.Util.Try(Reicht.World.ToBase) end,
    ToShop = function() Reicht.Util.Try(Reicht.World.ToShop) end,
    ToPlayer = Report(function() return Reicht.World.ToPlayer(State.Opt.TeleportTarget) end, "Teleported", "Player not found"),
    Hop = Report(Reicht.World.Hop, "Joining another server", "No other server found"),
    RestoreLighting = function() Reicht.Util.Try(Reicht.World.RestoreLighting) end,
    ResetSpeed = function() Reicht.Util.Try(Reicht.Movement.ResetSpeed) end,
    StopTrain = function() Reicht.Util.Try(Reicht.Progress.StopTraining) end,
    ReleaseTreadmill = function()
        local ok, released = Reicht.Util.Try(Reicht.Progress.ReleaseTreadmill)
        if not (ok and released) then
            State.SpeedPinned = false
            return
        end
        Reicht.Util.Notify("Left the treadmill so Speed works")
    end,
    ResumeTraining = function() Reicht.Loot.ResumeTraining() end,
}

---@return string  equipped pickaxe and dumbbell names
function Reicht.Scheduler.GearLine(profile)
    local staff = GameLib.Staffs and GameLib.Staffs[profile.EquippedPickaxe]
    local pickaxe = staff and staff.name or tostring(profile.EquippedPickaxe or "-")
    return ("Pickaxe %s · Dumbbell %s"):format(pickaxe, tostring(profile.EquippedTrainTool or "-"))
end

function Reicht.Scheduler.Summarize()
    local profile = Reicht.Data.Get()
    local cash, power = profile.Currencies.Cash, profile.Power or 0
    Reicht.Progress.LearnUpgrades(profile)
    State.StartCash = State.StartCash or cash
    State.StartPower = State.StartPower or power

    local abbr = Reicht.Util.Abbreviate
    local lines = {
        ("Cash %s (+%s)"):format(abbr(cash), abbr(cash - State.StartCash)),
        ("Power %s (+%s)"):format(abbr(power), abbr(power - State.StartPower)),
        ("Rebirth %d · Carry %s"):format(profile.Rebirth or 0, abbr(profile.Upgrades.Carry or 1)),
        Reicht.Scheduler.GearLine(profile),
        ("Inventory %d/%d · Looted %d"):format(Reicht.Util.Count(profile.Inventory), Reicht.Data.InventoryLimit(), State.Looted),
    }
    if State.Picked > 0 then lines[#lines + 1] = ("Event pickups %d"):format(State.Picked) end
    if State.Opt.AutoLoot and State.LootFull then lines[#lines + 1] = "WARNING: inventory full, Auto Loot paused" end
    State.Summary = table.concat(lines, "\n")
end

Reicht.Scheduler.Jobs = {
    { "Status", nil, Reicht.Scheduler.Summarize, 0 },
    { "Fullbright", "Fullbright", Reicht.World.ApplyFullbright, Config.FullbrightInterval },
    { "Auto Hatch", "AutoHatch", Reicht.Hatch.Step, Config.SellInterval },
    { "Auto Sell Eggs", "AutoSellEggs", Reicht.Sell.EggsNow, Config.SellInterval },
    { "Auto Sell Brainrots", "AutoSellBrainrots", Reicht.Sell.BrainrotsNow, Config.SellInterval },
    { "Auto Place Best", "AutoEquipBest", Reicht.Progress.EquipBest, Config.SellInterval },
    { "Auto Upgrade", "AutoUpgrade", Reicht.Progress.UpgradeNow, Config.UpgradeInterval },
    { "Auto Rebirth", "AutoRebirth", Reicht.Progress.RebirthNow, Config.UpgradeInterval },
    { "Auto Buy Dumbbell", "AutoBuyTool", Reicht.Progress.BuyBestTool, Config.UpgradeInterval },
    { "Auto Pickaxe", "AutoPickaxe", Reicht.Gear.PickaxeNow, Config.UpgradeInterval },
    { "Auto Train", "AutoTrain", Reicht.Progress.StartTraining, Config.UpgradeInterval },
    { "Auto Potion", "AutoPotion", Reicht.Boost.Step, Config.PotionInterval },
    { "Event Pickups", "AutoPickups", Reicht.Pickup.Step, Config.PickupInterval },
    { "Auto Spin", "AutoSpin", Reicht.Claim.Spin, Config.ClaimInterval },
    { "Season Pass", "AutoPass", Reicht.Claim.Pass, Config.ClaimInterval },
    { "Auto Claim", "AutoClaim", Reicht.Claim.All, Config.ClaimInterval },
}

---Switches a failing feature off from the scheduler thread; the UI pump flips the toggle (this thread has touched game modules).
function Reicht.Scheduler.Halt(label, idx, err)
    if idx and not State.Opt[idx] then return end
    local reason = tostring(err):match("^[^\n]*")
    if idx then
        State.Opt[idx] = false
        State.Halted[#State.Halted + 1] = idx
    end
    warn("[OpenSea] " .. label .. " stopped:", reason)
    Reicht.Util.Notify(label .. " stopped: " .. reason)
end

---@param job table  { label, toggle idx, step, interval }; a feature halts after Config.JobFailLimit errors spanning Config.JobFailWindow seconds, the status job only goes quiet
function Reicht.Scheduler.Run(job, now)
    if job[2] and not State.Opt[job[2]] then
        job.Streak = nil
        return
    end
    if now - (job.Last or 0) < job[4] then return end
    job.Last = now

    local ok, err = pcall(job[3])
    if ok then
        job.Streak = nil
        return
    end
    local streak = job.Streak
    if not streak then
        streak = { count = 0, since = now }
        job.Streak = streak
        warn("[OpenSea] " .. job[1] .. ":", err)
    end
    streak.count += 1
    if not job[2] or streak.count < Config.JobFailLimit or now - streak.since < Config.JobFailWindow then return end
    job.Streak = nil
    Reicht.Scheduler.Halt(job[1], job[2], err)
end

function Reicht.Scheduler.Step()
    for name, handler in pairs(Reicht.Scheduler.Requests) do
        if State.Requests[name] then
            State.Requests[name] = nil
            Reicht.Util.Try(handler)
        end
    end

    local now = os.clock()
    for _, job in ipairs(Reicht.Scheduler.Jobs) do
        Reicht.Scheduler.Run(job, now)
    end
end

function Reicht.Scheduler.Boot()
    Reicht.Movement.Bind()
    task.spawn(function()
        while State.Alive do
            if not State.Busy then
                State.Busy = true
                Reicht.Util.Try(Reicht.Scheduler.Step)
                State.Busy = false
            end
            task.wait(Config.TickDelay)
        end
    end)
end

function Reicht.Scheduler.Stop()
    State.Alive = false
    getgenv().OpenSeaUnload = nil
    State.Opt.AutoLoot = false
    State.Opt.AutoPickups = false
    for _, conn in ipairs(State.Conns) do conn:Disconnect() end
    table.clear(State.Conns)
    if State.Opt.Noclip then Reicht.Movement.RestoreCollision() end
    if State.Opt.Speed then Reicht.Util.Try(Reicht.Movement.ResetSpeed) end
    Reicht.Util.Try(Reicht.World.RestoreLighting)
    if State.Trained then task.spawn(Reicht.Util.Try, Reicht.Progress.StopTraining) end
end

---@return boolean  false when the menu could not load
local function BuildInterface()
    local Library = Reicht.Util.LoadLibrary()
    if not Library then return false end
    pcall(ReichtBanner.Step, "UI library")
    local Options = Library.Options
    local T = function(en, th) return Library:T(en, th) end
    local opt = State.Opt
    local widgets = {}

    local keepValues = {}
    Reicht.Util.Try(function()
        for _, name in ipairs(Reicht.Util.RarityNames()) do keepValues[#keepValues + 1] = name end
        for _, name in ipairs(Reicht.Util.MutationNames()) do table.insert(keepValues, name) end
    end)

    local function Notify(text, kind)
        Library:Notify("Open Sea For Animals", text, 4, kind or "Info")
    end

    ---@param idx string?  feature whose game modules the request needs
    local function Request(name, idx)
        return function()
            if idx and GameLib.Missing(idx) then
                Notify("Not available on this executor", "Warning")
                return
            end
            State.Requests[name] = true
        end
    end

    local function Toggle(group, key, text, description, onChange, risky)
        return group:AddToggle(key, {
            Text = text,
            Description = description,
            Default = false,
            Risky = risky,
            Callback = function(value)
                opt[key] = value
                if onChange then onChange(value) end
            end,
        })
    end

    local function Live(group, key, text, description, onChange)
        return Toggle(group, key, text, description, onChange):AddKeyPicker(key .. "Key", { Default = "None", Mode = "Toggle" })
    end

    local function MultiSelect(group, key, text, description, values, default)
        return group:AddDropdown(key, {
            Text = text,
            Description = description,
            Values = values,
            Multi = true,
            Default = default or {},
            Searchable = #values > 8,
            Callback = function(selected) opt[key] = selected end,
        })
    end

    local function NowButton(group, text, request, idx)
        return group:AddButton({ Text = text, Style = "Primary", Func = Request(request, idx) })
    end

    local function BuildMain(window)
        window:AddTabSection(T("Farm", "ฟาร์ม"))
        local tab = window:AddTab(T("Main", "หลัก"), "house", T("Loot farm and status", "ฟาร์มของและสถานะ"))

        local statusBox = tab:AddLeftGroupbox(T("Status", "สถานะ"))
        widgets.Status = statusBox:AddLabel("Loading...")

        local lootBox = tab:AddLeftGroupbox(T("Sea Loot", "เก็บของในทะเล"))
        Toggle(lootBox, "AutoLoot", T("Auto Loot", "เก็บของอัตโนมัติ"),
            T("Collects the top eggs and brainrots from every wave", "เก็บไข่และ brainrot ที่ดีที่สุดทุกคลื่น"),
            Reicht.Loot.SetEnabled)
        NowButton(lootBox, T("Loot Once", "เก็บหนึ่งรอบ"), "LootOnce", "AutoLoot")
        MultiSelect(lootBox, "LootKeep", T("Only Collect", "เก็บเฉพาะ"),
            T("Empty takes the top item, otherwise only these", "เว้นว่าง = เอาชิ้นดีสุด ถ้าเลือกจะเก็บเฉพาะที่เลือก"), keepValues)

        local discordBox = tab:AddRightGroupbox(T("Discord", "ดิสคอร์ด"), "link")
        discordBox:AddLabel(Config.Discord)
        discordBox:AddButton({ Text = T("Copy Discord Link", "คัดลอกลิงก์ Discord"), Style = "Primary", Func = function()
            local copied = Reicht.Util.Copy(Config.Discord)
            Notify(copied and "Discord link copied" or Config.Discord)
        end })

        local logBox = tab:AddRightGroupbox(T("Update Log", "อัปเดตล่าสุด"), "bell")
        for i = 1, math.min(2, #Config.UpdateLog) do
            local entry = Config.UpdateLog[i]
            logBox:AddParagraph({ Title = entry[1], Content = entry[2] })
        end

        local kaitunBox = tab:AddRightGroupbox(T("Kaitun", "ไก่ตัน"))
        kaitunBox:AddToggle("Kaitun", {
            Text = T("Kaitun", "ไก่ตัน"),
            Description = T("Loot, sell, gear, upgrades, rebirth and rewards together", "เก็บของ ขาย อุปกรณ์ อัปเกรด รีเบิร์ธ และรางวัลพร้อมกัน"),
            Default = false,
            NoSave = true,
            Callback = function(value)
                for _, key in ipairs(Config.KaitunKeys) do
                    local toggle = Options[key]
                    if toggle then toggle:SetValue(value) end
                end
            end,
        })
    end

    local function BuildAnimals(window)
        local tab = window:AddTab(T("Animals", "สัตว์"), "heart", T("Sell, hatch and place", "ขาย ฟัก และวาง"))

        local sellBox = tab:AddLeftGroupbox(T("Sell", "ขาย"))
        Toggle(sellBox, "AutoSellEggs", T("Auto Sell Eggs", "ขายไข่อัตโนมัติ"), T("Sells eggs as they come in, except kept ones", "ขายไข่ที่ได้มาทันที ยกเว้นที่เลือกเก็บไว้"))
        NowButton(sellBox, T("Sell Eggs Now", "ขายไข่เดี๋ยวนี้"), "SellEggs", "AutoSellEggs")
        Toggle(sellBox, "AutoSellBrainrots", T("Auto Sell Brainrots", "ขาย brainrot อัตโนมัติ"), T("Sells unlocked brainrots, except kept ones", "ขาย brainrot ที่ไม่ได้ล็อก ยกเว้นที่เลือกเก็บไว้"))
        NowButton(sellBox, T("Sell Brainrots Now", "ขาย brainrot เดี๋ยวนี้"), "SellBrainrots", "AutoSellBrainrots")
        MultiSelect(sellBox, "SellKeep", T("Keep", "เก็บไว้"), T("Rarities and mutations that are never sold", "rarity และ mutation ที่จะไม่ขาย"), keepValues)

        local hatchBox = tab:AddRightGroupbox(T("Hatching", "ฟักไข่"))
        Toggle(hatchBox, "AutoHatch", T("Auto Hatch", "ฟักไข่อัตโนมัติ"), T("Places your most valuable eggs and hatches them", "วางไข่ที่มีค่าที่สุดแล้วฟักให้"))
        NowButton(hatchBox, T("Hatch Now", "ฟักเดี๋ยวนี้"), "HatchNow", "AutoHatch")

        local placeBox = tab:AddRightGroupbox(T("Animals", "สัตว์"))
        Toggle(placeBox, "AutoEquipBest", T("Auto Equip Best", "ใส่ตัวดีสุดอัตโนมัติ"), T("Keeps your top animals placed on your plot", "วางสัตว์ตัวที่ดีที่สุดบนพื้นที่เสมอ"))
        NowButton(placeBox, T("Equip Best Now", "ใส่ตัวดีสุดเดี๋ยวนี้"), "EquipBestNow", "AutoEquipBest")
    end

    local function BuildUpgrade(window)
        window:AddTabSection(T("Progress", "ความคืบหน้า"))
        local tab = window:AddTab(T("Upgrade", "อัปเกรด"), "sliders-horizontal", T("Upgrades, rebirth and potions", "อัปเกรด รีเบิร์ธ และยา"))

        local upgradeBox = tab:AddLeftGroupbox(T("Upgrades", "อัปเกรด"))
        Toggle(upgradeBox, "AutoUpgrade", T("Auto Upgrade", "อัปเกรดอัตโนมัติ"), T("Buys the selected upgrades when you can afford them", "ซื้ออัปเกรดที่เลือกทุกครั้งที่เงินพอ"))
        NowButton(upgradeBox, T("Upgrade Now", "อัปเกรดเดี๋ยวนี้"), "UpgradeNow", "AutoUpgrade")
        widgets.Upgrades = MultiSelect(upgradeBox, "UpgradePick", T("Upgrades", "อัปเกรด"), T("Carry brings back more items per wave", "Carry ทำให้ขนของกลับได้มากขึ้นต่อคลื่น"), table.clone(State.UpgradeNames), table.clone(State.UpgradeNames))
        for _, name in ipairs(State.UpgradeNames) do opt.UpgradePick[name] = true end
        upgradeBox:AddInput("CashReserve", {
            Text = T("Keep Cash", "กันเงินไว้"),
            Description = T("Never spend below this amount", "ไม่ใช้เงินจนต่ำกว่าจำนวนนี้"),
            Default = "0",
            Numeric = true,
            Finished = true,
            Callback = function(value) opt.CashReserve = math.max(0, tonumber(value) or 0) end,
        })
        upgradeBox:AddButton({ Text = T("Unlimited Carry", "ขนของไม่จำกัด"), Risky = true, Func = Request("UnlockCarry", "AutoUpgrade") })

        local rebirthBox = tab:AddRightGroupbox(T("Rebirth", "รีเบิร์ธ"))
        Toggle(rebirthBox, "AutoRebirth", T("Auto Rebirth", "รีเบิร์ธอัตโนมัติ"), T("Rebirths as soon as you meet the requirement", "รีเบิร์ธทันทีเมื่อครบเงื่อนไข"))
        NowButton(rebirthBox, T("Rebirth Now", "รีเบิร์ธเดี๋ยวนี้"), "RebirthNow", "AutoRebirth")

        local potionBox = tab:AddRightGroupbox(T("Potions", "ยา"))
        Toggle(potionBox, "AutoPotion", T("Auto Potion", "ใช้ยาอัตโนมัติ"), T("Drinks the selected potions you own when they run out", "ดื่มยาที่เลือกเมื่อหมดเวลา ใช้ของที่มีอยู่"))
        NowButton(potionBox, T("Use Potions Now", "ใช้ยาเดี๋ยวนี้"), "PotionNow", "AutoPotion")
        MultiSelect(potionBox, "PotionPick", T("Potions", "ยา"), nil, Reicht.Util.PotionNames())
    end

    local function BuildGear(window)
        local tab = window:AddTab(T("Gear", "อุปกรณ์"), "zap", T("Power, dumbbells and pickaxes", "พลัง ดัมเบลล์ และพลั่ว"))

        local powerBox = tab:AddLeftGroupbox(T("Power", "พลัง"))
        Toggle(powerBox, "AutoTrain", T("Auto Train", "ฝึกอัตโนมัติ"), T("Gains power anywhere, more power reaches further out", "เพิ่มพลังได้ทุกที่ พลังยิ่งเยอะยิ่งเอื้อมได้ไกล"), function(value)
            if not value and State.Trained then State.Requests.StopTrain = true end
        end)
        Toggle(powerBox, "AutoBuyTool", T("Auto Dumbbell", "ดัมเบลล์อัตโนมัติ"), T("Buys and equips the strongest dumbbell you can get", "ซื้อและใส่ดัมเบลล์ที่แรงที่สุดที่ได้"))
        NowButton(powerBox, T("Dumbbell Now", "ดัมเบลล์เดี๋ยวนี้"), "ToolNow", "AutoBuyTool")

        local pickBox = tab:AddRightGroupbox(T("Pickaxe", "พลั่ว"))
        Toggle(pickBox, "AutoPickaxe", T("Auto Pickaxe", "พลั่วอัตโนมัติ"), T("Buys and equips the luckiest pickaxe you can get", "ซื้อและใส่พลั่วที่โชคดีที่สุดที่ได้"))
        NowButton(pickBox, T("Pickaxe Now", "พลั่วเดี๋ยวนี้"), "PickaxeNow", "AutoPickaxe")
    end

    local function BuildRewards(window)
        local tab = window:AddTab(T("Rewards", "รางวัล"), "shop", T("Rewards, codes and events", "รางวัล โค้ด และอีเวนต์"))

        local claimBox = tab:AddLeftGroupbox(T("Rewards", "รางวัล"))
        Toggle(claimBox, "AutoClaim", T("Auto Claim", "รับรางวัลอัตโนมัติ"), T("Daily, playtime, free shop, packs and offline cash", "รายวัน เวลาเล่น ร้านฟรี แพ็ก และเงินตอนออฟไลน์"))
        NowButton(claimBox, T("Claim All Now", "รับทั้งหมดเดี๋ยวนี้"), "ClaimNow", "AutoClaim")
        claimBox:AddButton({ Text = T("Redeem All Codes", "ใช้โค้ดทั้งหมด"), Func = Request("RedeemAll", "AutoClaim") })
        claimBox:AddInput("CodeBox", {
            Text = T("Redeem Codes", "ใส่โค้ด"),
            Description = T("Separate codes with commas", "คั่นโค้ดด้วยจุลภาค"),
            Default = "",
            Placeholder = T("CODE1, CODE2", "โค้ด1, โค้ด2"),
            Finished = true,
            Callback = function(value)
                opt.CodeInput = value
                if value ~= "" then State.Requests.RedeemInput = true end
            end,
        })

        local spinBox = tab:AddRightGroupbox(T("Wheel and Pass", "วงล้อและพาส"))
        Toggle(spinBox, "AutoSpin", T("Auto Spin", "หมุนวงล้ออัตโนมัติ"), T("Spins the wheel whenever you have tickets", "หมุนวงล้อทุกครั้งที่มีตั๋ว"))
        NowButton(spinBox, T("Spin Now", "หมุนเดี๋ยวนี้"), "SpinNow", "AutoSpin")
        Toggle(spinBox, "AutoPass", T("Auto Season Pass", "รับรางวัลพาสอัตโนมัติ"), T("Claims every free pass reward you reached", "รับรางวัลพาสฟรีทุกขั้นที่ถึงแล้ว"))
        NowButton(spinBox, T("Claim Pass Now", "รับพาสเดี๋ยวนี้"), "PassNow", "AutoPass")

        local eventBox = tab:AddRightGroupbox(T("Event", "อีเวนต์"))
        Toggle(eventBox, "AutoPickups", T("Auto Event Pickups", "เก็บของอีเวนต์อัตโนมัติ"), T("Grabs event items around the map, then returns", "เก็บของอีเวนต์รอบแมพแล้วกลับที่เดิม"), nil, true)
        NowButton(eventBox, T("Pick Up Now", "เก็บเดี๋ยวนี้"), "PickupNow")
    end

    local function BuildPlayer(window)
        window:AddTabSection(T("Other", "อื่นๆ"))
        local tab = window:AddTab(T("Player", "ผู้เล่น"), "user", T("Movement and visuals", "การเคลื่อนที่และภาพ"))

        local moveBox = tab:AddLeftGroupbox(T("Movement", "การเคลื่อนที่"))
        Live(moveBox, "Speed", T("Speed", "ความเร็ว"), nil, function(value)
            State.SpeedPinned = false
            if not value then State.Requests.ResetSpeed = true end
        end)
        moveBox:AddSlider("SpeedValue", {
            Text = T("Walk Speed", "ความเร็วเดิน"),
            Default = opt.SpeedValue,
            Min = 16,
            Max = 300,
            Rounding = 0,
            Callback = function(value) opt.SpeedValue = tonumber(value) or opt.SpeedValue end,
        })
        Live(moveBox, "InfJump", T("Infinite Jump", "กระโดดไม่จำกัด"))

        local bodyBox = tab:AddRightGroupbox(T("Body and World", "ตัวละครและโลก"))
        Live(bodyBox, "Noclip", T("Noclip", "ทะลุวัตถุ"), nil, function(value)
            if not value then Reicht.Movement.RestoreCollision() end
        end)
        Toggle(bodyBox, "Fullbright", T("Fullbright", "สว่างทั้งแมพ"), nil, function(value)
            if not value then State.Requests.RestoreLighting = true end
        end)
    end

    local function BuildTeleport(window)
        local tab = window:AddTab(T("Teleport", "วาร์ป"), "teleport", T("Places and players", "สถานที่และผู้เล่น"))

        local placeBox = tab:AddLeftGroupbox(T("Places", "สถานที่"))
        placeBox:AddButton({ Text = T("My Base", "ฐานของฉัน"), Style = "Primary", Func = Request("ToBase", "AutoClaim") })
        placeBox:AddButton({ Text = T("Shop", "ร้านค้า"), Func = Request("ToShop", "AutoClaim") })

        local playerBox = tab:AddRightGroupbox(T("Players", "ผู้เล่น"))
        widgets.Players = playerBox:AddDropdown("TeleportTarget", {
            Text = T("Player", "ผู้เล่น"),
            Values = Reicht.World.PlayerNames(),
            Searchable = true,
            Callback = function(value) opt.TeleportTarget = value end,
        })
        playerBox:AddButton({ Text = T("Teleport", "วาร์ป"), Style = "Primary", Func = Request("ToPlayer") })
            :AddButton({ Text = T("Refresh", "รีเฟรช"), Func = function()
                widgets.Players:SetValues(Reicht.World.PlayerNames())
            end })
    end

    local function BuildSettings(window)
        local tab = window:AddSettingsTab()
        local sessionBox = tab:AddRightGroupbox(T("Session", "เซสชัน"))
        Toggle(sessionBox, "AntiAfk", T("Anti AFK", "กันหลุด AFK"), T("Stay in the server while idle", "อยู่ในเซิร์ฟต่อได้แม้ไม่ได้ขยับ"))
        sessionBox:AddButton({ Text = T("Rejoin", "เข้าเซิร์ฟเดิมใหม่"), Func = function() Reicht.Util.Try(Reicht.World.Rejoin) end })
        sessionBox:AddButton({ Text = T("Server Hop", "ย้ายเซิร์ฟ"), Func = Request("Hop") })
    end

    ---Features whose game module or remote is gone refuse to turn on instead of erroring every tick.
    local function GateModules()
        for idx in pairs(GameLib.Needs) do
            if not Options[idx] then continue end
            local missing = GameLib.Missing(idx)
            if missing then
                warn("[OpenSea] " .. idx .. " disabled, module missing: " .. missing)
                Library.Compat.Block(idx, T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้"))
                continue
            end
            local gone = GameLib.MissingRemote(idx)
            if gone then
                warn("[OpenSea] " .. idx .. " disabled, remote missing: " .. gone)
                Library.Compat.Block(idx, T("The game changed, waiting for a script update", "เกมอัปเดต รอสคริปต์อัปเดต"))
            end
        end
        if not GameLib.ServiceFolder then warn("[OpenSea] knit Services folder not found, remote check skipped") end
        if not GameLib.Knit then State.Summary = "Game data is not available on this executor" end
    end

    local function RefreshUpgrades()
        local drop = widgets.Upgrades
        if not State.UpgradesChanged or not drop then return end
        State.UpgradesChanged = false
        local picked = table.clone(drop.Value or {})
        drop:SetValues(table.clone(State.UpgradeNames))
        drop:SetValue(picked)
    end

    local function Pump()
        while #State.Messages > 0 do
            local message = table.remove(State.Messages, 1)
            Notify(message.Text, message.Kind)
        end

        while #State.Halted > 0 do
            local toggle = Library.Toggles[table.remove(State.Halted, 1)]
            if toggle and toggle.Value then toggle:SetValue(false) end
        end

        if widgets.Status then widgets.Status:SetText(State.Summary) end
        RefreshUpgrades()
    end

    local function BuildTabs()
        local window = Library.Window
        local try = Reicht.Util.Try
        try(BuildMain, window)
        try(BuildAnimals, window)
        try(BuildUpgrade, window)
        try(BuildGear, window)
        try(BuildRewards, window)
        try(BuildPlayer, window)
        try(BuildTeleport, window)
        try(BuildSettings, window)
        try(GateModules)

        Library:Every(1, Pump)
    end

    Library:OnUnload(Reicht.Scheduler.Stop)
    getgenv().OpenSeaUnload = function()
        Library:Unload()
    end

    Library:CreateWindow({
        Title = "Reicht",
        SubTitle = "Open Sea For Animals by Reicht",
        MenuKey = Enum.KeyCode.LeftControl,
        ConfigFolder = Config.SaveFolder,
        Language = "Auto",
        Theme = "Overworld",
        OnUnlocked = function()
            BuildTabs()
            Reicht.Util.Try(Reicht.Scheduler.Boot)
            Notify("Loaded")
            Reicht.Util.Try(Library.LoadAutoloadConfig, Library)
        end,
    })
    return true
end

if getgenv().OpenSeaUnload then
    pcall(getgenv().OpenSeaUnload)
end

pcall(ReichtBanner.Step, "Systems")
if BuildInterface() then
    pcall(ReichtBanner.Step, "Interface")
    pcall(ReichtBanner.Ready)
end