if not game:IsLoaded() then
game.Loaded:Wait()
end
if not LPH_OBFUSCATED then
local function Passthrough(fn) return fn end
LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end
local environment = getgenv and getgenv() or _G
if type(environment.AnimeDiceUnload) == "function" then
pcall(environment.AnimeDiceUnload)
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local osClock = os.clock
if game.GameId ~= 10708913337 then
LocalPlayer:Kick("Reicht: this script is for Anime Dice only")
return
end
local ReichtBanner = {
Print = print,
Started = os.clock(),
Last = os.clock(),
Done = 0,
Total = 4,
}
do
local ok, renv = pcall(getrenv)
if ok and type(renv) == "table" and type(renv.print) == "function" then ReichtBanner.Print = renv.print end
end
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
"   ANIME DICE  //  by Reicht  //  ",
"   executor: " .. executor .. "   //   player: " .. game:GetService("Players").LocalPlayer.Name,
rule,
}, "\n"))
end
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
pcall(ReichtBanner.Show)
pcall(ReichtBanner.Step, "Core")
local Reicht = setmetatable({}, {
__newindex = function(self, key, value)
rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
end,
})
Reicht.Config = {
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
Discord = "https://",
UpdateLog = {
{ "2026-10-05", "Added Rebirth Stats: auto spend points on the stat you pick\nAdded Reset Stats with Reset Token\nAdded auto use of gamepass items" },
{ "2026-10-03", "Classic Reicht UI is back\nBetter executor support\nAuto Roll stops at full storage\nFixed Group Reward\nImproved Fast Roll" },
},
ReloadSource = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/loader.lua"))()',
RejoinDelay = 5,
RejoinRetry = 30,
WebhookColor = 0xE8A04C,
GroupId = 33017480,
SaveFolder = "Anime Dice",
LoadTimeout = 30,
AlertTries = 20,
AlertGap = 0.5,
JobFailLimit = 5,
JobFailWindow = 10,
StatusInterval = 1,
RollLead = 0.1,
GradeDelay = 0.3,
TraitDelay = 0.3,
FuseDelay = 0.55,
BuyDelay = 0.3,
LevelDelay = 0.2,
RedeemDelay = 0.6,
ClaimDelay = 0.25,
TowerTick = 0.25,
TowerRetry = 0.5,
TowerStartCooldown = 3.2,
ItemDelay = 0.6,
StatDelay = 0.12,
RewardsInterval = 5,
SnapshotTtl = 0.4,
StorageHeadroom = 6,
StorageRefill = 0.7,
TowerDemoteFloor = 5,
RollStats = { Luck = true, ["Roll Duration"] = true, Rolls = true },
UtilitySeconds = { Default = 120, Walkspeed = 10, ["Sell Multiplier"] = 60, ["Unit Storage"] = 180, Luck = 600, ["Roll Duration"] = 600 },
UtilityFallbackShare = 0.05,
SwapMargin = 1.15,
FuseGain = 1.25,
FuseMoneyShare = 0.05,
SwapsPerPass = 4,
PlaceDelay = 0.55,
TowerActionTime = {
floorStarted = 0.76,
damageEnemy = 0.62,
damagePlayer = 0.62,
memberDefeated = 0.32,
floorCompleted = 0.24,
},
}
Reicht.State = {
Alive = true,
Connections = {},
Halted = {},
Notices = {},
}
Reicht.Options = {
AntiAfk = false,
DisableCutscene = false,
WalkSpeed = false,
WalkSpeedValue = 32,
InfiniteJump = false,
NoClip = false,
Fly = false,
FlySpeed = 60,
AutoRoll = false,
RollInterval = 0.02,
AutoCollect = false,
CollectInterval = 1,
EquipBestUnitsAuto = false,
EquipInterval = 5,
PlacementMode = "Potential",
AutoLevelUp = false,
LevelMinRarity = "Common",
LevelTarget = 10,
AutoBuyDice = false,
AutoEquipBestDice = false,
AutoBuyUpgrades = false,
UpgradeFilter = {},
AutoSell = false,
SellRarities = {},
SellKeepMutations = {},
KeepPerRarity = 0,
SellInterval = 2,
AutoClearStorage = false,
ClearKeepRarity = "Mythical",
LevelPayback = 180,
UpgradePayback = 1800,
AutoRebirth = false,
AutoRebirthStats = false,
RebirthStat = "Money",
AutoGrade = false,
GradeTarget = "S",
GradeOverwrite = false,
AutoTrait = false,
TraitTarget = "Samurai",
TraitOverwrite = false,
AutoFuse = false,
FuseRarities = {},
AutoTower = false,
TowerName = "Dragon Tower",
TowerStopFloor = 100,
TowerReequip = false,
TowerSmart = false,
AutoGear = false,
AutoPotion = false,
PotionFilter = {},
AutoSpin = false,
AutoGamepass = false,
AutoTicketShop = false,
TicketShopItems = {},
AutoDaily = false,
AutoGroup = false,
AutoOffline = false,
AutoQuest = false,
RareNotify = false,
NotifyRarities = {},
NotifyMutations = {},
WebhookUrl = "",
AutoLock = false,
LockRarity = "Secret I",
LockMutations = {},
AutoRejoin = false,
Kaitun = false,
}
Reicht.Util = {}
local Util = Reicht.Util
local function Resolve(...)
for index = 1, select("#", ...) do
local candidate = select(index, ...)
if type(candidate) == "function" then
return candidate
end
end
return nil
end
Util.Request = Resolve(request, http_request, syn and syn.request, http and http.request)
Util.SetClipboard = Resolve(setclipboard, toclipboard)
Util.QueueTeleport = Resolve(queue_on_teleport, queueonteleport, syn and syn.queue_on_teleport)
function Util.HttpGet(url)
local ok, body = pcall(function() return game:HttpGet(url) end)
if ok and type(body) == "string" then
return body
end
if not Util.Request then return nil, "no http function" end
local sent, response = pcall(Util.Request, { Url = url, Method = "GET" })
if not sent or type(response) ~= "table" then return nil, tostring(response) end
if response.StatusCode ~= 200 or type(response.Body) ~= "string" then
return nil, "HTTP " .. tostring(response.StatusCode)
end
return response.Body
end
function Util.Alert(text, detail)
warn("[AnimeDice] " .. text, detail or "")
task.spawn(function()
local starterGui = game:GetService("StarterGui")
for _ = 1, Reicht.Config.AlertTries do
if pcall(starterGui.SetCore, starterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 }) then return end
task.wait(Reicht.Config.AlertGap)
end
end)
end
function Util.Copy(text)
if not Util.SetClipboard then return false end
return (pcall(Util.SetClipboard, text))
end
function Util.Try(label, fn, ...)
local ok, err = pcall(fn, ...)
if not ok then warn("[AnimeDice] " .. label .. ":", err) end
return ok
end
function Util.LoadLibrary(url)
local source, why = Util.HttpGet(url)
if not source or not source:sub(-64):find("return%s+Library%s*$") then
warn("[AnimeDice] ui download:", why or "truncated or not the library")
return nil, "Could not download the menu. Check your connection and run it again."
end
local chunk, compileErr = loadstring(source)
if not chunk then
return nil, "The menu failed to load on this executor: " .. tostring(compileErr)
end
local ok, lib = pcall(chunk)
if not ok or type(lib) ~= "table" then
return nil, "The menu failed to load on this executor: " .. tostring(lib)
end
return lib
end
function Util.FormatNumber(value)
value = tonumber(value) or 0
if value >= 1e6 then
local suffixes = { "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
local tier = math.clamp(math.floor(math.log(value, 1000)) - 1, 1, #suffixes)
return string.format("%.2f%s", value / (1000 ^ (tier + 1)), suffixes[tier])
end
local text = tostring(math.floor(value))
local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
return (formatted:gsub("^,", ""))
end
function Util.SortedKeys(map)
local keys = {}
for key in pairs(map or {}) do
keys[#keys + 1] = tostring(key)
end
table.sort(keys)
return keys
end
function Util.SetFromList(list)
local set = {}
for key, value in pairs(list or {}) do
if type(key) == "number" then
set[value] = true
elseif value then
set[key] = true
end
end
return set
end
function Reicht:Connect(signal, handler)
local connection = signal:Connect(handler)
table.insert(self.State.Connections, connection)
return connection
end
Reicht.GameLib = {}
local GameLib = Reicht.GameLib
function GameLib.Find(root, path)
local node = root
for part in path:gmatch("[^.]+") do
if not node then return nil end
node = node:FindFirstChild(part)
end
return node
end
function GameLib.RequireAsGame(module)
if GameLib.CanSwitch == false then return false, nil end
local done, ok, loaded = false, false, nil
task.spawn(function()
local switched = pcall(setthreadidentity, 2)
local read, identity = pcall(getthreadidentity)
if switched and read and identity == 2 then
ok, loaded = pcall(require, module)
else
GameLib.CanSwitch = false
end
done = true
end)
local deadline = osClock() + Reicht.Config.LoadTimeout
while not done and osClock() < deadline do task.wait() end
return ok, loaded
end
function GameLib.Require(module)
if not (module and module:IsA("ModuleScript")) then return nil end
local ok, loaded = pcall(require, module)
if ok then return loaded end
local retried, again = GameLib.RequireAsGame(module)
if retried then return again end
warn("[AnimeDice] require " .. module:GetFullName() .. ":", loaded)
return nil
end
do
local framework = ReplicatedStorage:WaitForChild("Framework", Reicht.Config.LoadTimeout)
local features = framework and framework:WaitForChild("Features", Reicht.Config.LoadTimeout)
local function Load(path) return GameLib.Require(GameLib.Find(features, path)) end
GameLib.Dice = Load("Rolling.Dice")
GameLib.Rebirths = Load("Rebirth.Rebirths")
GameLib.Upgrades = Load("Upgrades.Upgrades")
GameLib.Tree = Load("Upgrades.TreeStructure")
GameLib.Grades = Load("Grades.Grades")
GameLib.Traits = Load("Traits.Traits")
GameLib.Towers = Load("Towers.Towers")
GameLib.Rarities = GameLib.Require(GameLib.Find(framework, "Other.Rarities"))
GameLib.Entry = Load("Inventory.EntryRegistry")
GameLib.Mutations = Load("Inventory.Kinds.Unit.Mutations")
GameLib.UnitUtil = Load("Inventory.Kinds.Unit.UnitUtil")
GameLib.Codes = Load("Codes.CodesConfig")
GameLib.Quests = Load("Quests.QuestConfig")
GameLib.RollController = Load("Rolling.RollController")
GameLib.Buffs = Load("Buffs.BuffController")
GameLib.BuffsConfig = Load("Buffs.BuffsConfig")
GameLib.FusingConfig = Load("Fusing.FusingConfig")
GameLib.RebirthStats = Load("Rebirth.RebirthStatsConfig")
local rewards = GameLib.Find(features, "Rewards")
GameLib.Daily = GameLib.Require(rewards and rewards:FindFirstChild("DailyRewardConfig", true))
GameLib.Group = GameLib.Require(rewards and rewards:FindFirstChild("GroupRewardConfig", true))
GameLib.DataClient = GameLib.Require(GameLib.Find(ReplicatedStorage, "Packages.Data.Client"))
end
GameLib.EntryCache = {}
function GameLib.EntryOf(name)
local registry = GameLib.Entry
if not registry or not name then return nil end
local cached = GameLib.EntryCache[name]
if cached ~= nil then return cached or nil end
local ok, config = pcall(registry.getEntryConfig, name)
GameLib.EntryCache[name] = ok and config or false
return ok and config or nil
end
function GameLib.GradeOrder(gradeName)
local grade = gradeName and GameLib.Grades and GameLib.Grades[gradeName]
return type(grade) == "table" and tonumber(grade.order) or 0
end
function GameLib.TraitPower(traitName)
local trait = traitName and GameLib.Traits and GameLib.Traits[traitName]
if type(trait) ~= "table" then return 0 end
local best = math.max(tonumber(trait.incomeMultiplier) or 0, tonumber(trait.damageMultiplier) or 0,
tonumber(trait.healthMultiplier) or 0)
return best + (tonumber(trait.order) or 0) / 1000
end
function GameLib.RarityOrder(rarityName)
local rarities = GameLib.Rarities
if not rarities or not rarityName then return 0 end
local ok, entry = pcall(rarities.Get, rarityName)
return ok and type(entry) == "table" and tonumber(entry.sortOrder) or 0
end
function GameLib.NamesOfKind(kind)
local registry = GameLib.Entry
local names = {}
if not registry then return names end
local ok, entries = pcall(registry.entriesOfKind, kind)
if ok and type(entries) == "table" then
for name in pairs(entries) do names[#names + 1] = tostring(name) end
end
table.sort(names)
return names
end
function GameLib.RebirthStatNames()
local names = {}
local config = GameLib.RebirthStats
if not (config and type(config.Stats) == "table") then return names end
for _, stat in ipairs(config.Stats) do names[#names + 1] = tostring(stat.name) end
return names
end
function GameLib.GradeNames()
local names = Util.SortedKeys(GameLib.Grades or {})
table.sort(names, function(a, b) return GameLib.GradeOrder(a) < GameLib.GradeOrder(b) end)
return names
end
function GameLib.TraitNames()
local names = {}
for name, trait in pairs(GameLib.Traits or {}) do
if type(trait) == "table" and GameLib.TraitPower(name) > 0 then names[#names + 1] = name end
end
table.sort(names, function(a, b) return GameLib.TraitPower(a) < GameLib.TraitPower(b) end)
return names
end
function GameLib.MutationNames()
local names = {}
for name, mutation in pairs(GameLib.Mutations or {}) do
if type(mutation) == "table" then names[#names + 1] = name end
end
table.sort(names, function(a, b)
return (tonumber(GameLib.Mutations[a].chance) or 0) < (tonumber(GameLib.Mutations[b].chance) or 0)
end)
return names
end
function GameLib.UnitRarities()
local seen = {}
local registry = GameLib.Entry
if registry then
local ok, units = pcall(registry.entriesOfKind, "Unit")
if ok and type(units) == "table" then
for _, config in pairs(units) do
if type(config) == "table" and config.rarity then seen[config.rarity] = true end
end
end
end
local list = {}
for rarity in pairs(seen) do list[#list + 1] = rarity end
table.sort(list, function(a, b) return GameLib.RarityOrder(a) < GameLib.RarityOrder(b) end)
return list
end
function GameLib.ShopNames()
local names = {}
local shop = GameLib.Quests and GameLib.Quests.Shop
for _, item in ipairs(type(shop) == "table" and shop or {}) do
if type(item) == "table" and item.name and not item.gamepass then names[#names + 1] = item.name end
end
return names
end
Reicht.Net = { Cache = {} }
local Network = ReplicatedStorage:WaitForChild("Network", Reicht.Config.LoadTimeout)
function Reicht.Net.Search(path)
if not Network then return nil end
local parts = string.split(path, ".")
local name, parent = parts[#parts], parts[#parts - 1]
for _, node in ipairs(Network:GetDescendants()) do
if node.Name == name and (not parent or (node.Parent and node.Parent.Name == parent)) then return node end
end
return nil
end
function Reicht.Net.Get(path)
local cached = Reicht.Net.Cache[path]
if cached and cached.Parent then return cached end
local remote = GameLib.Find(Network, path) or Reicht.Net.Search(path)
Reicht.Net.Cache[path] = remote
return remote
end
function Reicht.Net.Fire(path, ...)
local remote = Reicht.Net.Get(path)
if remote then remote:FireServer(...) end
end
function Reicht.Net.Invoke(path, ...)
local remote = Reicht.Net.Get(path)
if not remote then return false, "no remote" end
return pcall(remote.InvokeServer, remote, ...)
end
Reicht.Data = {}
function Reicht.Data.Read(field)
local client = GameLib.DataClient
if not client then return nil end
local ok, proxy = pcall(function() return client:get({ field }) end)
if not ok then return nil end
if type(proxy) == "table" then
local okCall, value = pcall(proxy)
if okCall then return value end
end
return proxy
end
function Reicht.Data.Table(field)
local value = Reicht.Data.Read(field)
return type(value) == "table" and value or {}
end
function Reicht.Data.Money()
return tonumber(Reicht.Data.Read("Money")) or 0
end
function Reicht.Data.Rebirth()
return tonumber(Reicht.Data.Read("Rebirth")) or 0
end
function Reicht.Data.Rolls()
return tonumber(Reicht.Data.Read("Rolls")) or 0
end
function Reicht.Data.Token(name)
local total = 0
for _, entry in pairs(Reicht.Data.Table("Inventory")) do
if type(entry) == "table" and entry.name == name then
total += tonumber(entry.amount) or 0
end
end
return total
end
function Reicht.Data.BusyKeys()
local busy = {}
for _, slot in pairs(Reicht.Data.Table("Slots")) do
if type(slot) == "table" and slot.unitId then busy[tostring(slot.unitId)] = true end
end
for _, key in pairs(Reicht.Data.Table("TowerTeam")) do
if type(key) == "string" then busy[key] = true end
end
return busy
end
function Reicht.Data.ItemsOfKind(kind)
local items = {}
for key, entry in pairs(Reicht.Data.Table("Inventory")) do
if type(entry) == "table" and entry.name then
local config = GameLib.EntryOf(entry.name)
if config and config.kind == kind then
items[#items + 1] = { Key = tostring(key), Name = entry.name, Amount = tonumber(entry.amount) or 1 }
end
end
end
return items
end
function Reicht.Data.UnitCount()
local count = 0
for _, entry in pairs(Reicht.Data.Table("Inventory")) do
local config = type(entry) == "table" and entry.name and GameLib.EntryOf(entry.name)
if config and config.kind == "Unit" then count += 1 end
end
local trade = Reicht.Data.Read("PendingTrade")
if type(trade) == "table" and not trade.applied then count += tonumber(trade.reservedUnits) or 0 end
return count
end
Reicht.Data.UnitCache = { At = -1, List = {} }
function Reicht.Data.Units()
local cache = Reicht.Data.UnitCache
local now = osClock()
if now - cache.At < Reicht.Config.SnapshotTtl then return cache.List end
cache.List = Reicht.Data.ScanUnits()
cache.At = now
return cache.List
end
function Reicht.Data.Invalidate()
Reicht.Data.UnitCache.At = -1
end
function Reicht.Data.IncomeAt(config, attrs, level)
local probe = table.clone(attrs)
probe.level = level
local ok, value = pcall(config.income, probe)
return ok and tonumber(value) or 0
end
function Reicht.Data.LevelPrice(unit, level)
local probe = table.clone(unit.Attr)
probe.level = level
local ok, price = pcall(GameLib.UnitUtil.GetLevelPrice, unit.Name, probe)
return ok and tonumber(price) or math.huge
end
function Reicht.Data.ScanUnits()
local busy = Reicht.Data.BusyKeys()
local units = {}
for key, entry in pairs(Reicht.Data.Table("Inventory")) do
if type(entry) == "table" and entry.name then
local config = GameLib.EntryOf(entry.name)
if config and config.kind == "Unit" then
local attrs = type(entry.attributes) == "table" and entry.attributes or {}
local rarity = config.rarity
if type(config.getRarity) == "function" then
local ok, dynamic = pcall(config.getRarity, attrs)
if ok and dynamic then rarity = dynamic end
end
local income, potential = 0, 0
if type(config.income) == "function" then
local ok, value = pcall(config.income, attrs)
if ok then income = tonumber(value) or 0 end
potential = Reicht.Data.IncomeAt(config, attrs, 1)
end
local chance
if type(config.chance) == "function" and not config.limited and (tonumber(entry.amount) or 1) == 1 then
local ok, value = pcall(config.chance, attrs)
chance = ok and tonumber(value) or nil
end
key = tostring(key)
units[#units + 1] = {
Key = key,
Name = entry.name,
Attr = attrs,
Rarity = rarity,
Grade = attrs.grade,
Trait = attrs.trait,
Mutation = attrs.mutation,
Level = tonumber(attrs.level) or 1,
Locked = attrs.locked == true,
Busy = busy[key] == true,
Value = income,
Potential = potential,
Chance = chance,
}
end
end
end
table.sort(units, function(a, b)
if a.Busy ~= b.Busy then return a.Busy end
return a.Value > b.Value
end)
return units
end
Reicht.Player = { Client = LocalPlayer }
function Reicht.Player:Bind(character)
self.Character = character
self.Humanoid = character:WaitForChild("Humanoid", Reicht.Config.LoadTimeout)
self.Root = character:WaitForChild("HumanoidRootPart", Reicht.Config.LoadTimeout)
end
Reicht.Scheduler = { Jobs = {}, Booted = false }
function Reicht.Scheduler.Every(name, interval, fn, toggles)
Reicht.Scheduler.Jobs[name] = { Interval = interval, Fn = fn, Last = 0, Running = false, Fails = 0, Toggles = toggles or {} }
end
function Reicht.Scheduler.Wanted(job)
for _, idx in ipairs(job.Toggles) do
if Reicht.Options[idx] == true then return true end
end
return false
end
function Reicht.Scheduler.Run(name, job)
local ok, err = pcall(job.Fn)
job.Running = false
if ok then
job.Fails, job.FailSince = 0, nil
return
end
job.Fails += 1
job.FailSince = job.FailSince or osClock()
if job.Fails == 1 then warn("[AnimeDice] job " .. name .. " failing:", err) end
local config = Reicht.Config
if job.Fails < config.JobFailLimit or osClock() - job.FailSince < config.JobFailWindow then return end
if not Reicht.Scheduler.Wanted(job) then return end
job.Halted = true
table.insert(Reicht.State.Halted, { name, job.Toggles, tostring(err):match("^[^\n]*") })
end
function Reicht.Scheduler.Step()
local now = osClock()
for name, job in pairs(Reicht.Scheduler.Jobs) do
local interval = type(job.Interval) == "function" and job.Interval() or job.Interval
if not job.Running and not job.Halted and now - job.Last >= interval then
job.Last = now
job.Running = true
task.spawn(Reicht.Scheduler.Run, name, job)
end
end
end
function Reicht.Scheduler.Resume(idx)
for _, job in pairs(Reicht.Scheduler.Jobs) do
if table.find(job.Toggles, idx) then
job.Halted, job.Fails, job.FailSince = false, 0, nil
end
end
end
function Reicht.Scheduler.Boot()
if Reicht.Scheduler.Booted then return end
Reicht.Scheduler.Booted = true
Reicht:Connect(RunService.Heartbeat, Reicht.Scheduler.Step)
end
Reicht.AntiAfk = { Connection = nil }
function Reicht.AntiAfk.OnIdled()
if not Reicht.Options.AntiAfk then return end
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.zero)
end
function Reicht.AntiAfk.Start()
Reicht.Options.AntiAfk = true
if not Reicht.AntiAfk.Connection then
Reicht.AntiAfk.Connection = Reicht:Connect(LocalPlayer.Idled, Reicht.AntiAfk.OnIdled)
end
end
function Reicht.AntiAfk.Stop()
Reicht.Options.AntiAfk = false
end
Reicht.Cutscene = { Saved = nil }
function Reicht.Cutscene.Skip() end
function Reicht.Cutscene.Apply()
local controller = GameLib.RollController
if type(controller) ~= "table" or table.isfrozen(controller) or Reicht.Cutscene.Saved then return end
local original = rawget(controller, "PlayCutscene")
if type(original) ~= "function" then return end
Reicht.Cutscene.Saved = original
rawset(controller, "PlayCutscene", Reicht.Cutscene.Skip)
end
function Reicht.Cutscene.Restore()
local controller = GameLib.RollController
local original = Reicht.Cutscene.Saved
if not original then return end
if rawget(controller, "PlayCutscene") == Reicht.Cutscene.Skip then rawset(controller, "PlayCutscene", original) end
Reicht.Cutscene.Saved = nil
end
function Reicht.Cutscene.Step()
if Reicht.Options.DisableCutscene then Reicht.Cutscene.Apply() else Reicht.Cutscene.Restore() end
end
Reicht.Move = { NoClipConnection = nil, FlyConnection = nil, FlyForce = nil, JumpConnection = nil }
function Reicht.Move.ApplyWalkSpeed()
local hum = Reicht.Player.Humanoid
if hum and Reicht.Options.WalkSpeed then hum.WalkSpeed = Reicht.Options.WalkSpeedValue end
end
function Reicht.Move.SpeedStart()
Reicht.Options.WalkSpeed = true
Reicht.Move.ApplyWalkSpeed()
end
function Reicht.Move.SpeedStop()
Reicht.Options.WalkSpeed = false
local hum = Reicht.Player.Humanoid
if hum then hum.WalkSpeed = 16 end
end
function Reicht.Move.JumpStart()
Reicht.Options.InfiniteJump = true
if Reicht.Move.JumpConnection then return end
Reicht.Move.JumpConnection = Reicht:Connect(UserInputService.JumpRequest, function()
local hum = Reicht.Player.Humanoid
if Reicht.Options.InfiniteJump and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
end
function Reicht.Move.JumpStop()
Reicht.Options.InfiniteJump = false
end
function Reicht.Move.NoClipStart()
Reicht.Options.NoClip = true
if Reicht.Move.NoClipConnection then return end
Reicht.Move.NoClipConnection = Reicht:Connect(RunService.Stepped, function()
local char = Reicht.Player.Character
if not (Reicht.Options.NoClip and char) then return end
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
end
end)
end
function Reicht.Move.NoClipStop()
Reicht.Options.NoClip = false
local char = Reicht.Player.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if hrp then hrp.CanCollide = true end
end
function Reicht.Move.FlyStart()
if Reicht.Move.FlyForce then return end
local hrp = Reicht.Player.Root
if not hrp then return end
Reicht.Options.Fly = true
local force = Instance.new("BodyVelocity")
force.MaxForce = Vector3.one * 9e9
force.Velocity = Vector3.zero
force.Parent = hrp
Reicht.Move.FlyForce = force
if Reicht.Move.FlyConnection then return end
Reicht.Move.FlyConnection = Reicht:Connect(RunService.RenderStepped, function()
local bv = Reicht.Move.FlyForce
if not (Reicht.Options.Fly and bv) then return end
local look = Workspace.CurrentCamera.CFrame
local dir = Vector3.zero
if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += look.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= look.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= look.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += look.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
bv.Velocity = dir.Magnitude > 0 and dir.Unit * Reicht.Options.FlySpeed or Vector3.zero
end)
end
function Reicht.Move.FlyStop()
Reicht.Options.Fly = false
if Reicht.Move.FlyForce then
Reicht.Move.FlyForce:Destroy()
Reicht.Move.FlyForce = nil
end
end
function Reicht.Move.Rebind()
Reicht.Move.ApplyWalkSpeed()
if Reicht.Options.Fly then
Reicht.Move.FlyForce = nil
Reicht.Move.FlyStart()
end
end
Reicht.Roll = { Status = "Off", Session = 0, LastRolls = nil, StorageFull = false, NextAt = 0 }
function Reicht.Roll.Duration()
local buffs = GameLib.Buffs
if not buffs then return 0 end
local ok, duration = pcall(buffs.GetBuff, "Roll Duration")
return ok and tonumber(duration) or 0
end
function Reicht.Roll.Room()
local buffs = GameLib.Buffs
if not buffs then return true, 0, 0 end
local okStorage, storage = pcall(buffs.GetBuff, "Unit Storage")
local okRolls, rolls = pcall(buffs.GetBuff, "Rolls")
storage, rolls = tonumber(okStorage and storage), tonumber(okRolls and rolls)
if not storage or not rolls then return true, 0, 0 end
local limit = storage + rolls - 1
local held = Reicht.Data.UnitCount()
return held < limit, held, limit
end
function Reicht.Roll.SetStorageFull(full, held, limit)
if full == Reicht.Roll.StorageFull then return end
Reicht.Roll.StorageFull = full
if not full then return end
table.insert(Reicht.State.Notices, {
"Unit storage full",
string.format("%d/%d units. Rolling paused until you sell or clear some.", held, limit),
})
end
function Reicht.Roll.Once()
return Reicht.Net.Invoke("RollService.RF.RollDice")
end
function Reicht.Roll.ResetCounter()
Reicht.Roll.Session = 0
Reicht.Roll.LastRolls = Reicht.Data.Rolls()
end
function Reicht.Roll.Track()
local rolls = Reicht.Data.Rolls()
if Reicht.Roll.LastRolls and rolls > Reicht.Roll.LastRolls then
Reicht.Roll.Session += rolls - Reicht.Roll.LastRolls
end
Reicht.Roll.LastRolls = rolls
end
function Reicht.Roll.Step()
Reicht.Roll.Track()
if not Reicht.Options.AutoRoll then
Reicht.Roll.Status = "Off"
Reicht.Roll.StorageFull = false
return
end
local hasRoom, held, limit = Reicht.Roll.Room()
Reicht.Roll.SetStorageFull(not hasRoom, held, limit)
if not hasRoom then
Reicht.Roll.Status = string.format("Storage full %d/%d, paused", held, limit)
return
end
Reicht.Roll.Status = "Rolling"
if osClock() < Reicht.Roll.NextAt then return end
local ok, reply = Reicht.Roll.Once()
if ok and reply ~= nil then
Reicht.Roll.NextAt = osClock() + math.max(Reicht.Roll.Duration() - Reicht.Config.RollLead, 0)
end
end
function Reicht.Roll.GetStatus()
return string.format("%s · session %s · total %s", Reicht.Roll.Status,
Util.FormatNumber(Reicht.Roll.Session), Util.FormatNumber(Reicht.Data.Rolls()))
end
Reicht.Plot = { Status = "Off" }
function Reicht.Plot.CollectNow()
for index, slot in pairs(Reicht.Data.Table("Slots")) do
local balance = type(slot) == "table" and tonumber(slot.balance) or 0
if balance > 0 then
Reicht.Net.Fire("PlotService.RE.CollectBalance", tonumber(index))
Reicht.Economy.Collected += balance
end
end
end
function Reicht.Plot.WorthLevel(unit, mult)
local config = GameLib.EntryOf(unit.Name)
if not config then return unit.Level end
local gain = (Reicht.Data.IncomeAt(config, unit.Attr, 2) - unit.Potential) * mult
if gain <= 0 then return unit.Level end
local cap = math.min(Reicht.Options.LevelTarget, 500)
local level = 1
while level < cap and Reicht.Data.LevelPrice(unit, level) / gain <= Reicht.Options.LevelPayback do
level += 1
end
return level
end
function Reicht.Plot.Score(unit, mult)
local config = GameLib.EntryOf(unit.Name)
if not config then return unit.Value end
local level = math.max(unit.Level, Reicht.Plot.WorthLevel(unit, mult))
return level == unit.Level and unit.Value or Reicht.Data.IncomeAt(config, unit.Attr, level)
end
function Reicht.Plot.PlanSwaps()
local slots = Reicht.Data.Table("Slots")
local byKey = {}
for _, unit in ipairs(Reicht.Data.Units()) do byKey[unit.Key] = unit end
local mult = Reicht.Economy.Multiplier()
local current, placed = {}, {}
for index, slot in pairs(slots) do
if type(slot) ~= "table" then continue end
local unit = slot.unitId and byKey[tostring(slot.unitId)]
current[#current + 1] = { tonumber(index), unit and Reicht.Plot.Score(unit, mult) or 0 }
if unit then placed[unit.Key] = true end
end
table.sort(current, function(a, b) return a[2] < b[2] end)
local bench = {}
for _, unit in ipairs(Reicht.Data.Units()) do
if not placed[unit.Key] then bench[#bench + 1] = unit end
end
table.sort(bench, function(a, b) return a.Potential > b.Potential end)
for index = #bench, #current * 2 + 1, -1 do bench[index] = nil end
for _, unit in ipairs(bench) do unit.Score = Reicht.Plot.Score(unit, mult) end
table.sort(bench, function(a, b) return a.Score > b.Score end)
local swaps = {}
for index, slot in ipairs(current) do
local candidate = bench[index]
if not candidate or candidate.Score < slot[2] * Reicht.Config.SwapMargin then break end
swaps[#swaps + 1] = { slot[1], candidate.Key }
end
return swaps
end
function Reicht.Plot.EquipBest()
if Reicht.Options.PlacementMode ~= "Potential" then
Reicht.Net.Fire("PlotService.RE.EquipBest")
return 0
end
local moved = 0
for _, swap in ipairs(Reicht.Plot.PlanSwaps()) do
if moved >= Reicht.Config.SwapsPerPass then break end
Reicht.Net.Fire("PlotService.RE.CollectBalance", swap[1])
local ok, held = Reicht.Net.Invoke("UnitService.RF.Equip", swap[2])
if not (ok and held) then break end
task.wait(Reicht.Config.PlaceDelay)
Reicht.Net.Fire("PlotService.RE.InteractSlot", swap[1])
moved += 1
task.wait(Reicht.Config.PlaceDelay)
end
if moved > 0 then Reicht.Data.Invalidate() end
Reicht.Plot.Status = moved > 0 and (moved .. " better units placed") or "Best units placed"
return moved
end
function Reicht.Plot.CollectStep()
if Reicht.Options.AutoCollect then Reicht.Plot.CollectNow() end
end
function Reicht.Plot.EquipStep()
if Reicht.Options.EquipBestUnitsAuto then Reicht.Plot.EquipBest() end
end
function Reicht.Plot.LevelCandidates()
local byKey = {}
for _, unit in ipairs(Reicht.Data.Units()) do byKey[unit.Key] = unit end
local minRarity = GameLib.RarityOrder(Reicht.Options.LevelMinRarity)
local mult = Reicht.Economy.Multiplier()
local list = {}
for index, slot in pairs(Reicht.Data.Table("Slots")) do
local unit = type(slot) == "table" and slot.unitId and byKey[tostring(slot.unitId)]
if not unit or unit.Level >= Reicht.Options.LevelTarget or GameLib.RarityOrder(unit.Rarity) < minRarity then continue end
local config = GameLib.EntryOf(unit.Name)
local okPrice, price = pcall(GameLib.UnitUtil.GetLevelPrice, unit.Name, unit.Attr)
local nextAttrs = table.clone(unit.Attr)
nextAttrs.level = unit.Level + 1
local okGain, nextIncome = pcall(config.income, nextAttrs)
local gain = okGain and ((tonumber(nextIncome) or 0) - unit.Value) * mult or 0
if okPrice and tonumber(price) and gain > 0 then
list[#list + 1] = { tonumber(index), price, price / gain }
end
end
table.sort(list, function(a, b) return a[3] < b[3] end)
return list
end
function Reicht.Plot.LevelPass(ignoreGoal)
local money = Reicht.Data.Money()
local goal = not ignoreGoal and Reicht.Economy.Goal()
local levelled = 0
for _, pick in ipairs(Reicht.Plot.LevelCandidates()) do
local slot, price, payback = pick[1], pick[2], pick[3]
if payback > Reicht.Options.LevelPayback then break end
if price > money then continue end
if goal and money - price < goal.Cost and payback >= Reicht.Economy.Eta(goal.Cost, money - price) then continue end
Reicht.Net.Fire("PlotService.RE.LevelUpSlot", slot)
money -= price
levelled += 1
task.wait(Reicht.Config.LevelDelay)
end
Reicht.Plot.Status = levelled > 0 and (levelled .. " levelled") or (goal and ("Saving for " .. goal.Name) or "No level worth it")
return levelled
end
Reicht.Economy = { Rate = 0, Collected = 0, LastTotal = nil, LastAt = 0, Earned = 0 }
function Reicht.Economy.Sample()
local total = 0
for _, slot in pairs(Reicht.Data.Table("Slots")) do
if type(slot) == "table" then total += tonumber(slot.balance) or 0 end
end
local economy, now = Reicht.Economy, osClock()
if economy.LastTotal and now > economy.LastAt then
local earned = total + economy.Collected - economy.LastTotal
local sample = earned / (now - economy.LastAt)
if sample >= 0 then
economy.Rate = economy.Rate == 0 and sample or economy.Rate * 0.8 + sample * 0.2
economy.Earned += earned
end
end
economy.LastTotal, economy.LastAt, economy.Collected = total, now, 0
end
function Reicht.Economy.Multiplier()
local plotted = {}
for _, slot in pairs(Reicht.Data.Table("Slots")) do
if type(slot) == "table" and slot.unitId then plotted[tostring(slot.unitId)] = true end
end
local raw = 0
for _, unit in ipairs(Reicht.Data.Units()) do
if plotted[unit.Key] then raw += unit.Value end
end
return (raw > 0 and Reicht.Economy.Rate > 0) and Reicht.Economy.Rate / raw or 1
end
function Reicht.Economy.Goal()
local goals = {}
if Reicht.Options.AutoRebirth then
local rebirth = Reicht.Rebirth.Next()
if rebirth then goals[#goals + 1] = { Name = "rebirth", Cost = tonumber(rebirth.cost) or math.huge } end
end
if Reicht.Options.AutoBuyDice then
local name, price = Reicht.Dice.NextTarget()
if name then goals[#goals + 1] = { Name = name .. " dice", Cost = price } end
end
table.sort(goals, function(a, b) return a.Cost < b.Cost end)
return goals[1]
end
function Reicht.Economy.Eta(cost, money)
local rate = Reicht.Economy.Rate
if cost <= money then return 0 end
return rate > 0 and (cost - money) / rate or math.huge
end
function Reicht.Economy.Step()
Reicht.Economy.Sample()
local options = Reicht.Options
if options.AutoBuyDice or options.AutoEquipBestDice then Reicht.Dice.Step() end
if options.AutoRebirth then Reicht.Rebirth.RebirthNow() end
if options.AutoRebirthStats then Reicht.Rebirth.SpendPoints() end
if options.AutoBuyUpgrades then Reicht.Upgrade.BuyAll() end
if options.AutoLevelUp then Reicht.Plot.LevelPass() end
end
function Reicht.Economy.GetStatus()
local goal = Reicht.Economy.Goal()
local text = "Income " .. Util.FormatNumber(Reicht.Economy.Rate) .. "/s"
if not goal then return text end
local eta = Reicht.Economy.Eta(goal.Cost, Reicht.Data.Money())
local etaText = eta == math.huge and "?" or (eta < 60 and string.format("%ds", eta) or string.format("%dm", math.floor(eta / 60)))
return string.format("%s · %s in %s", text, goal.Name, etaText)
end
Reicht.Dice = { Status = "Off" }
function Reicht.Dice.Starter()
local name, price, luck = "Basic", math.huge, 1
for diceName, info in pairs(GameLib.Dice and GameLib.Dice.GetAll() or {}) do
local cost = tonumber(info.price) or 0
if cost < price then name, price, luck = diceName, cost, tonumber(info.luck) or 1 end
end
return name, luck
end
function Reicht.Dice.OwnedSet()
local owned = { [Reicht.Dice.Starter()] = true }
for key, value in pairs(Reicht.Data.Table("OwnedDice")) do
if type(key) == "number" then owned[value] = true elseif value then owned[key] = true end
end
return owned
end
function Reicht.Dice.BestOwned()
local owned = Reicht.Dice.OwnedSet()
local bestName, bestLuck = Reicht.Dice.Starter()
for name, info in pairs(GameLib.Dice and GameLib.Dice.GetAll() or {}) do
local luck = tonumber(info.luck) or 0
if owned[name] and luck > bestLuck then bestName, bestLuck = name, luck end
end
return bestName, bestLuck
end
function Reicht.Dice.NextBuy()
local owned = Reicht.Dice.OwnedSet()
local money = Reicht.Data.Money()
local _, pickLuck = Reicht.Dice.BestOwned()
local pick
for name, info in pairs(GameLib.Dice and GameLib.Dice.GetAll() or {}) do
local luck = tonumber(info.luck) or 0
if not owned[name] and (tonumber(info.price) or math.huge) <= money and luck > pickLuck then
pick, pickLuck = name, luck
end
end
return pick
end
function Reicht.Dice.NextTarget()
local owned = Reicht.Dice.OwnedSet()
local _, bestLuck = Reicht.Dice.BestOwned()
local pick, pickPrice = nil, math.huge
for name, info in pairs(GameLib.Dice and GameLib.Dice.GetAll() or {}) do
local price = tonumber(info.price) or math.huge
if not owned[name] and (tonumber(info.luck) or 0) > bestLuck and price < pickPrice then pick, pickPrice = name, price end
end
return pick, pickPrice
end
function Reicht.Dice.EquipBest()
local best = Reicht.Dice.BestOwned()
if best ~= Reicht.Data.Read("Dice") then Reicht.Net.Fire("DiceShopService.RE.EquipDice", best) end
end
function Reicht.Dice.Step()
if Reicht.Options.AutoBuyDice then
local buy = Reicht.Dice.NextBuy()
if buy then
Reicht.Net.Fire("DiceShopService.RE.BuyDice", buy)
Reicht.Dice.Status = "Bought " .. buy
task.wait(Reicht.Config.BuyDelay)
end
end
if Reicht.Options.AutoEquipBestDice or Reicht.Options.AutoBuyDice then Reicht.Dice.EquipBest() end
end
Reicht.Upgrade = { Status = "Off" }
function Reicht.Upgrade.Branch(name)
return (name:gsub("%s+[IVXLC]+$", ""))
end
function Reicht.Upgrade.Branches()
local seen = {}
for name in pairs(GameLib.Upgrades or {}) do
if type(name) == "string" and name ~= "Start" then seen[Reicht.Upgrade.Branch(name)] = true end
end
return Util.SortedKeys(seen)
end
function Reicht.Upgrade.OwnedBuffs(owned)
local sums = {}
for name in pairs(owned) do
local info = GameLib.Upgrades and GameLib.Upgrades[name]
for stat, buff in pairs(type(info) == "table" and info.buffs or {}) do
sums[stat] = sums[stat] or { base = 0, percentage = 0 }
if sums[stat][buff.bucket] then sums[stat][buff.bucket] += tonumber(buff.amount) or 0 end
end
end
return sums
end
function Reicht.Upgrade.Gain(stat, buff, sums)
local amount = tonumber(buff.amount) or 0
local sum = sums[stat] or { base = 0, percentage = 0 }
if stat == "Roll Duration" then
local ok, duration = pcall(GameLib.Buffs.GetBuff, stat)
duration = ok and tonumber(duration) or 0
return duration + amount > 0 and duration / (duration + amount) - 1 or 0
end
if buff.bucket == "percentage" then return amount / (1 + sum.percentage) end
if buff.bucket == "multiplier" then return amount - 1 end
local ok, config = pcall(GameLib.BuffsConfig.GetBuff, stat)
local default = ok and type(config) == "table" and tonumber(config.default) or 1
return amount / math.max(default + sum.base, 1e-3)
end
function Reicht.Upgrade.DiceDeal()
local name, price = Reicht.Dice.NextTarget()
if not name then return nil end
local _, bestLuck = Reicht.Dice.BestOwned()
local luck = tonumber(GameLib.Dice.GetAll()[name].luck) or bestLuck
return price / math.max(luck / bestLuck - 1, 1e-3)
end
function Reicht.Upgrade.Cheap(stat, price, money, rate)
local seconds = Reicht.Config.UtilitySeconds
if rate > 0 then return price <= rate * (seconds[stat] or seconds.Default) end
return price <= money * Reicht.Config.UtilityFallbackShare
end
function Reicht.Upgrade.Worth()
local owned = Reicht.Data.Table("Upgrades")
local sums = Reicht.Upgrade.OwnedBuffs(owned)
local money, rate = Reicht.Data.Money(), Reicht.Economy.Rate
local goal = Reicht.Economy.Goal()
local diceDeal = Reicht.Upgrade.DiceDeal()
local filter = Util.SetFromList(Reicht.Options.UpgradeFilter)
local anyBranch = next(filter) == nil
local tree = GameLib.Tree
local picks = {}
for name, info in pairs(GameLib.Upgrades or {}) do
if type(info) ~= "table" or name == "Start" or owned[name] then continue end
local price = tonumber(info.price) or math.huge
if price > money or not (anyBranch or filter[Reicht.Upgrade.Branch(name)]) then continue end
local parent = tree.GetParent(name)
if parent and parent ~= "Start" and not owned[parent] then continue end
local rank
for stat, buff in pairs(info.buffs or {}) do
local gain = Reicht.Upgrade.Gain(stat, buff, sums)
if gain <= 0 then continue end
if stat == "Money Multiplier" and rate > 0 then
local payback = price / (rate * gain)
local etaAfter = goal and Reicht.Economy.Eta(goal.Cost, money - price) or math.huge
if payback <= Reicht.Options.UpgradePayback or payback < etaAfter then rank = payback end
elseif Reicht.Config.RollStats[stat] and diceDeal then
if price / (gain * 100) <= diceDeal / 100 then rank = 1e6 + price / money end
elseif Reicht.Upgrade.Cheap(stat, price, money, rate) then
rank = 2e6 + price / money
end
end
if rank then picks[#picks + 1] = { name, price, rank } end
end
table.sort(picks, function(a, b) return a[3] < b[3] end)
return picks
end
function Reicht.Upgrade.NextHint()
local owned = Reicht.Data.Table("Upgrades")
local pick, price = nil, math.huge
for name, info in pairs(GameLib.Upgrades or {}) do
if type(info) ~= "table" or name == "Start" or owned[name] then continue end
local parent = GameLib.Tree.GetParent(name)
if parent and parent ~= "Start" and not owned[parent] then continue end
if (tonumber(info.price) or math.huge) < price then pick, price = name, tonumber(info.price) end
end
return pick and string.format("Next: %s at %s", pick, Util.FormatNumber(price)) or "All upgrades owned"
end
function Reicht.Upgrade.BuyAll()
local bought, spent = 0, 0
for _, pick in ipairs(Reicht.Upgrade.Worth()) do
if pick[2] + spent > Reicht.Data.Money() then continue end
Reicht.Net.Fire("RE.BuyUpgrade", pick[1])
spent += pick[2]
bought += 1
task.wait(Reicht.Config.BuyDelay)
end
Reicht.Upgrade.Status = bought > 0 and (bought .. " bought") or Reicht.Upgrade.NextHint()
return bought
end
Reicht.Sell = { Status = "Off" }
function Reicht.Sell.Pick()
local wanted = Util.SetFromList(Reicht.Options.SellRarities)
if next(wanted) == nil then return {} end
local keepMutation = Util.SetFromList(Reicht.Options.SellKeepMutations)
local keep = math.max(Reicht.Options.KeepPerRarity, 0)
local byRarity = {}
for _, unit in ipairs(Reicht.Data.Units()) do
if unit.Busy or unit.Locked or not wanted[unit.Rarity] then continue end
if unit.Mutation and keepMutation[unit.Mutation] then continue end
byRarity[unit.Rarity] = byRarity[unit.Rarity] or {}
table.insert(byRarity[unit.Rarity], unit)
end
local keys = {}
for _, list in pairs(byRarity) do
for index = keep + 1, #list do keys[#keys + 1] = list[index].Key end
end
return keys
end
function Reicht.Sell.SellNow()
local keys = Reicht.Sell.Pick()
if #keys == 0 then Reicht.Sell.Status = "Nothing to sell" return Reicht.Sell.Status end
local before = Reicht.Data.Money()
Reicht.Net.Invoke("SellService.RF.SellInventory", keys)
Reicht.Data.Invalidate()
Reicht.Sell.Status = string.format("%d sold (+%s)", #keys, Util.FormatNumber(Reicht.Data.Money() - before))
return Reicht.Sell.Status
end
function Reicht.Sell.Step()
if Reicht.Options.AutoSell then Reicht.Sell.SellNow() end
end
Reicht.Storage = { Status = "-" }
function Reicht.Storage.Cap()
local buffs = GameLib.Buffs
local ok, cap = pcall(function() return buffs.GetBuff("Unit Storage") end)
return ok and tonumber(cap) or math.huge
end
function Reicht.Storage.Clear()
local units = Reicht.Data.Units()
local cap = Reicht.Storage.Cap()
Reicht.Storage.Status = string.format("%d/%s", #units, cap == math.huge and "?" or tostring(cap))
if #units < cap - Reicht.Config.StorageHeadroom then return 0 end
local keepRank = GameLib.RarityOrder(Reicht.Options.ClearKeepRarity)
local keepMutation = Util.SetFromList(Reicht.Options.SellKeepMutations)
local spare = {}
for _, unit in ipairs(units) do
if unit.Busy or unit.Locked or (unit.Mutation and keepMutation[unit.Mutation]) then continue end
if keepRank > 0 and GameLib.RarityOrder(unit.Rarity) >= keepRank then continue end
spare[#spare + 1] = unit
end
table.sort(spare, function(a, b) return a.Potential < b.Potential end)
local excess = #units - math.floor(cap * Reicht.Config.StorageRefill)
local keys = {}
for index = 1, math.min(excess, #spare) do keys[index] = spare[index].Key end
if #keys == 0 then Reicht.Storage.Status ..= " · full, nothing sellable" return 0 end
Reicht.Net.Invoke("SellService.RF.SellInventory", keys)
Reicht.Data.Invalidate()
return #keys
end
function Reicht.Storage.Step()
if Reicht.Options.AutoClearStorage then Reicht.Storage.Clear() end
end
Reicht.Rebirth = { Status = "Off" }
function Reicht.Rebirth.Next()
local rebirths = GameLib.Rebirths
if not rebirths then return nil end
local ok, info = pcall(rebirths.GetNext, Reicht.Data.Rebirth())
return ok and type(info) == "table" and info or nil
end
function Reicht.Rebirth.RebirthNow()
local info = Reicht.Rebirth.Next()
if not info then Reicht.Rebirth.Status = "Max rebirth" return false end
if Reicht.Data.Money() < (tonumber(info.cost) or math.huge) then
Reicht.Rebirth.Status = "Need " .. Util.FormatNumber(info.cost)
return false
end
Reicht.Net.Fire("RebirthService.RE.Rebirth")
Reicht.Rebirth.Status = "Rebirthed"
return true
end
function Reicht.Rebirth.PointsLeft()
local config = GameLib.RebirthStats
if not config then return 0 end
local ok, left = pcall(config.GetRemaining, Reicht.Data.Rebirth(), Reicht.Data.Table("RebirthStats"))
return ok and tonumber(left) or 0
end
function Reicht.Rebirth.SpendPoints()
local stat = Reicht.Options.RebirthStat
local spent = 0
while Reicht.Rebirth.PointsLeft() > 0 and spent < 200 do
local before = Reicht.Rebirth.PointsLeft()
Reicht.Net.Fire("RebirthService.RE.AddStat", stat)
task.wait(Reicht.Config.StatDelay)
if Reicht.Rebirth.PointsLeft() >= before then
task.wait(Reicht.Config.StatDelay * 3)
if Reicht.Rebirth.PointsLeft() >= before then break end
end
spent += 1
end
return spent
end
function Reicht.Rebirth.ResetStats()
local config = GameLib.RebirthStats
if not config then return false, "Stats not found" end
if config.GetSpent(Reicht.Data.Table("RebirthStats")) <= 0 then return false, "No points spent" end
if Reicht.Data.Token("Reset Token") < 1 then return false, "No Reset Token" end
Reicht.Net.Fire("RebirthService.RE.UseResetToken")
return true
end
Reicht.Grade = { Status = "Off" }
function Reicht.Grade.Pick()
local target = GameLib.GradeOrder(Reicht.Options.GradeTarget)
local protected = Reicht.Data.Table("ProtectedGrades")
for _, unit in ipairs(Reicht.Data.Units()) do
if not unit.Busy or unit.Locked or GameLib.GradeOrder(unit.Grade) >= target then continue end
if unit.Grade and protected[unit.Grade] and not Reicht.Options.GradeOverwrite then continue end
return unit
end
return nil
end
function Reicht.Grade.RollOne()
if Reicht.Data.Token("Gems") < 1 then Reicht.Grade.Status = "No Gems" return false end
local unit = Reicht.Grade.Pick()
if not unit then Reicht.Grade.Status = "All at target" return false end
Reicht.Net.Fire("GradeService.RE.Roll", unit.Key)
Reicht.Grade.Status = string.format("%s [%s]", unit.Name, unit.Grade or "-")
return true
end
function Reicht.Grade.Step()
if Reicht.Options.AutoGrade then Reicht.Grade.RollOne() end
end
Reicht.Trait = { Status = "Off" }
function Reicht.Trait.Pick()
local target = GameLib.TraitPower(Reicht.Options.TraitTarget)
local protected = Reicht.Data.Table("ProtectedTraits")
for _, unit in ipairs(Reicht.Data.Units()) do
if not unit.Busy or unit.Locked or GameLib.TraitPower(unit.Trait) >= target then continue end
if unit.Trait and protected[unit.Trait] and not Reicht.Options.TraitOverwrite then continue end
return unit
end
return nil
end
function Reicht.Trait.RollOne()
if Reicht.Data.Token("Trait Reroll") < 1 then Reicht.Trait.Status = "No Trait Reroll" return false end
local unit = Reicht.Trait.Pick()
if not unit then Reicht.Trait.Status = "All at target" return false end
Reicht.Net.Fire("TraitService.RE.Roll", unit.Key)
Reicht.Trait.Status = string.format("%s [%s]", unit.Name, unit.Trait or "-")
return true
end
function Reicht.Trait.Step()
if Reicht.Options.AutoTrait then Reicht.Trait.RollOne() end
end
Reicht.Fuse = { Status = "Off" }
function Reicht.Fuse.Pool()
local wanted = Util.SetFromList(Reicht.Options.FuseRarities)
local anyRarity = next(wanted) == nil
local keepRank = GameLib.RarityOrder(Reicht.Options.ClearKeepRarity)
local keepMutation = Util.SetFromList(Reicht.Options.SellKeepMutations)
local pool = {}
for _, unit in ipairs(Reicht.Data.Units()) do
if unit.Busy or unit.Locked or not unit.Chance then continue end
if unit.Mutation and keepMutation[unit.Mutation] then continue end
if anyRarity and keepRank > 0 and GameLib.RarityOrder(unit.Rarity) >= keepRank then continue end
if anyRarity or wanted[unit.Rarity] then pool[#pool + 1] = unit end
end
table.sort(pool, function(a, b) return a.Chance > b.Chance end)
return pool
end
function Reicht.Fuse.PickTrio()
local pool = Reicht.Fuse.Pool()
local config = GameLib.FusingConfig
local average = tonumber(config.AverageMultiplier) or 0.667
local budget = Reicht.Data.Money() * Reicht.Config.FuseMoneyShare
for index = 1, #pool - 2 do
local a, b, c = pool[index], pool[index + 1], pool[index + 2]
local sum = a.Chance + b.Chance + c.Chance
local ok, cost = pcall(config.GetCost, sum)
if sum * average >= a.Chance * Reicht.Config.FuseGain and ok and cost <= budget then
return { a.Key, b.Key, c.Key, a.Name }
end
end
return nil
end
function Reicht.Fuse.FuseNow()
local trio = Reicht.Fuse.PickTrio()
if not trio then Reicht.Fuse.Status = "No worthwhile trio" return false end
Reicht.Net.Fire("FusingService.RE.Fuse", trio[1], trio[2], trio[3])
Reicht.Data.Invalidate()
Reicht.Fuse.Status = "Fused " .. trio[4] .. " +2"
return true
end
function Reicht.Fuse.Step()
if Reicht.Options.AutoFuse then Reicht.Fuse.FuseNow() end
end
Reicht.Tower = { Status = "Off", State = "Idle", NextAt = 0, Floor = 0, Best = 0, Runs = 0, Misses = 0, Ending = false }
function Reicht.Tower.Labels()
local towers = GameLib.Towers and GameLib.Towers.GetAll() or {}
local names = {}
for name in pairs(towers) do names[#names + 1] = name end
table.sort(names, function(a, b) return (tonumber(towers[a].order) or 0) < (tonumber(towers[b].order) or 0) end)
local labels = {}
for _, name in ipairs(names) do
local difficulty = type(towers[name].difficulty) == "table" and towers[name].difficulty.name or "?"
labels[#labels + 1] = string.format("%s (%s)", name, difficulty)
end
return labels
end
function Reicht.Tower.NameFromLabel(label)
return (tostring(label):gsub("%s*%b()$", ""))
end
function Reicht.Tower.EquipTeam()
Reicht.Net.Fire("Towers.RE.EquipBestTowerTeam")
end
function Reicht.Tower.Duration(actions)
local total = 0
for _, action in ipairs(actions) do
total += Reicht.Config.TowerActionTime[action.action] or 0.3
end
return total
end
function Reicht.Tower.Order()
local towers = GameLib.Towers and GameLib.Towers.GetAll() or {}
local names = {}
for name in pairs(towers) do names[#names + 1] = name end
table.sort(names, function(a, b) return (tonumber(towers[a].order) or 0) < (tonumber(towers[b].order) or 0) end)
return names
end
function Reicht.Tower.Adapt(floor)
if not Reicht.Options.TowerSmart then return end
local order = Reicht.Tower.Order()
local index = table.find(order, Reicht.Options.TowerName) or 1
local info = GameLib.Towers.Get(Reicht.Options.TowerName)
local top = math.min(tonumber(info and info.maxFloors) or math.huge, Reicht.Options.TowerStopFloor)
if floor and floor >= top and order[index + 1] then
index += 1
elseif (not floor or floor < Reicht.Config.TowerDemoteFloor) and index > 1 then
index -= 1
end
Reicht.Options.TowerName = order[index]
end
function Reicht.Tower.Leave()
if Reicht.Tower.Ending then return end
Reicht.Tower.Ending = true
Reicht.Net.Invoke("Towers.RF.CancelTower")
end
function Reicht.Tower.Start()
local now = osClock()
if Reicht.Options.TowerReequip or Reicht.Tower.Runs == 0 then
Reicht.Tower.EquipTeam()
task.wait(0.4)
end
local _, started = Reicht.Net.Invoke("Towers.RF.PlayTower", Reicht.Options.TowerName)
Reicht.Tower.State = "Climbing"
Reicht.Tower.Floor = 0
Reicht.Tower.Ending = not started
Reicht.Tower.NextAt = now
Reicht.Tower.Status = started and ("Entered " .. Reicht.Options.TowerName) or "Finishing previous run"
end
function Reicht.Tower.Climb()
local ok, actions = Reicht.Net.Invoke("Towers.RF.CompleteTowerFloor")
local now = osClock()
if not ok or type(actions) ~= "table" or #actions == 0 then
Reicht.Tower.Misses += 1
Reicht.Tower.NextAt = now + Reicht.Config.TowerRetry
if Reicht.Tower.Misses >= 20 then
Reicht.Tower.Misses = 0
Reicht.Tower.Adapt(nil)
Reicht.Tower.State = "Idle"
Reicht.Tower.NextAt = now + Reicht.Config.TowerStartCooldown
end
return
end
Reicht.Tower.Misses = 0
for _, action in ipairs(actions) do
if tonumber(action.floor) then Reicht.Tower.Floor = math.max(Reicht.Tower.Floor, action.floor) end
end
Reicht.Tower.Best = math.max(Reicht.Tower.Best, Reicht.Tower.Floor)
Reicht.Tower.NextAt = now + Reicht.Tower.Duration(actions)
if actions[#actions].action == "ended" then
Reicht.Tower.Runs += 1
Reicht.Tower.State = "Idle"
Reicht.Tower.Ending = false
Reicht.Tower.NextAt += Reicht.Config.TowerStartCooldown
Reicht.Tower.Status = string.format("Run %d ended at floor %d", Reicht.Tower.Runs, Reicht.Tower.Floor)
Reicht.Tower.Adapt(Reicht.Tower.Floor)
return
end
if Reicht.Tower.Floor >= Reicht.Options.TowerStopFloor then Reicht.Tower.Leave() end
Reicht.Tower.Status = string.format("%s · floor %d", Reicht.Options.TowerName, Reicht.Tower.Floor)
end
function Reicht.Tower.Step()
local tower = Reicht.Tower
if osClock() < tower.NextAt then return end
if not Reicht.Options.AutoTower then
if tower.State == "Idle" then tower.Status = "Off" return end
tower.Leave()
tower.Climb()
return
end
if tower.State == "Idle" then tower.Start() else tower.Climb() end
end
function Reicht.Tower.GetStatus()
if not Reicht.Options.AutoTower then return "Off" end
return string.format("%s · best %d · runs %d", Reicht.Tower.Status, Reicht.Tower.Best, Reicht.Tower.Runs)
end
Reicht.Gear = { Status = "Off" }
function Reicht.Gear.EquipBest()
local best = {}
for _, item in ipairs(Reicht.Data.ItemsOfKind("Gear")) do
local config = GameLib.EntryOf(item.Name)
local slot = config and config.slot
if not slot then continue end
local rank = GameLib.RarityOrder(config.rarity)
if not best[slot] or rank > best[slot][2] then best[slot] = { item.Name, rank } end
end
local equipped = Reicht.Data.Table("EquippedGear")
local changed = 0
for slot, pick in pairs(best) do
if equipped[slot] ~= pick[1] then
Reicht.Net.Fire("GearService.RE.Equip", slot, pick[1])
changed += 1
task.wait(Reicht.Config.GradeDelay)
end
end
Reicht.Gear.Status = changed > 0 and (changed .. " slots upgraded") or "Best gear on"
return changed
end
function Reicht.Gear.Step()
if Reicht.Options.AutoGear then Reicht.Gear.EquipBest() end
end
Reicht.Items = { Status = "Off" }
function Reicht.Items.PotionUseful(name)
local towerWord = name:match("^(%a+)%s+%a+%s+[IVX]+$")
if towerWord then
return Reicht.Options.AutoTower and Reicht.Tower.State == "Climbing" and Reicht.Options.TowerName:find(towerWord) ~= nil
end
if name:find("Luck") then return Reicht.Options.AutoRoll end
if name:find("Damage") then return Reicht.Options.AutoTower end
if name:find("Income") then return Reicht.Economy.Rate > 0 end
return true
end
function Reicht.Items.UsePotions(force)
local filter = Util.SetFromList(Reicht.Options.PotionFilter)
local anyPotion = next(filter) == nil
local active = Reicht.Data.Table("ActiveEntries")
local used = 0
for _, item in ipairs(Reicht.Data.ItemsOfKind("Boost")) do
if not (force or Reicht.Items.PotionUseful(item.Name)) then continue end
if (anyPotion or filter[item.Name]) and not active[item.Name] then
Reicht.Net.Fire("BoostService.RE.Use", item.Key)
used += 1
task.wait(Reicht.Config.ItemDelay)
end
end
return used
end
function Reicht.Items.UseSpins()
local used = 0
for _, item in ipairs(Reicht.Data.ItemsOfKind("Spin")) do
for _ = 1, math.min(item.Amount, 10) do
Reicht.Net.Fire("SpinService.RE.Use", item.Key)
used += 1
task.wait(Reicht.Config.ItemDelay)
end
end
return used
end
function Reicht.Items.UseGamepasses()
local owned = Reicht.Data.Table("OwnedGamepasses")
local used = 0
for _, item in ipairs(Reicht.Data.ItemsOfKind("Gamepass")) do
local config = GameLib.EntryOf(item.Name)
if config and config.gamepass and owned[config.gamepass] then continue end
Reicht.Net.Fire("GamepassService.RE.Use", item.Key)
used += 1
task.wait(Reicht.Config.ItemDelay)
end
return used
end
function Reicht.Items.BuyTicketShop()
local wanted = Util.SetFromList(Reicht.Options.TicketShopItems)
if next(wanted) == nil then return 0 end
local shop = GameLib.Quests and GameLib.Quests.Shop or {}
local bought = 0
for _, item in ipairs(shop) do
if type(item) ~= "table" or not wanted[item.name] then continue end
local cost = tonumber(item.tickets) or math.huge
while Reicht.Data.Token("Tickets") >= cost and bought < 50 do
local before = Reicht.Data.Token("Tickets")
Reicht.Net.Fire("QuestService.RE.Buy", item.name)
bought += 1
task.wait(Reicht.Config.ItemDelay)
if Reicht.Data.Token("Tickets") >= before then break end
end
end
return bought
end
function Reicht.Items.Step()
if Reicht.Options.AutoPotion then Reicht.Items.UsePotions() end
if Reicht.Options.AutoSpin then Reicht.Items.UseSpins() end
if Reicht.Options.AutoGamepass then Reicht.Items.UseGamepasses() end
if Reicht.Options.AutoTicketShop then Reicht.Items.BuyTicketShop() end
end
Reicht.Watch = { Seen = nil, Best = nil, Pulls = 0, StartAt = osClock(), StartGems = nil }
function Reicht.Watch.Describe(unit)
return string.format("%s [%s]%s", unit.Name, unit.Rarity or "?", unit.Mutation and (" · " .. unit.Mutation) or "")
end
function Reicht.Watch.Alert(unit)
local text = Reicht.Watch.Describe(unit)
pcall(function() Reicht.Library:Notify("Rare pull", text, 8, "Success") end)
local url = Reicht.Options.WebhookUrl
if type(url) ~= "string" or not url:find("^https://") or not Util.Request then return end
local body = HttpService:JSONEncode({
username = "Reicht",
embeds = { { title = "Anime Dice · rare pull", description = text, color = Reicht.Config.WebhookColor } },
})
local ok, err = pcall(Util.Request, { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
if not ok then warn("[AnimeDice] webhook:", err) end
end
function Reicht.Watch.OnNew(unit)
local watch = Reicht.Watch
watch.Pulls += 1
if not watch.Best or unit.Potential > watch.Best.Potential then watch.Best = unit end
if not Reicht.Options.RareNotify then return end
local rarities = Util.SetFromList(Reicht.Options.NotifyRarities)
local mutations = Util.SetFromList(Reicht.Options.NotifyMutations)
if rarities[unit.Rarity] or (unit.Mutation and mutations[unit.Mutation]) then watch.Alert(unit) end
end
function Reicht.Watch.Step()
local watch = Reicht.Watch
local units = Reicht.Data.Units()
if not watch.Seen then
watch.Seen, watch.StartGems = {}, Reicht.Data.Token("Gems")
for _, unit in ipairs(units) do watch.Seen[unit.Key] = true end
return
end
for _, unit in ipairs(units) do
if not watch.Seen[unit.Key] then
watch.Seen[unit.Key] = true
watch.OnNew(unit)
end
end
end
function Reicht.Watch.Stats()
local watch = Reicht.Watch
local hours = math.max(osClock() - watch.StartAt, 1) / 3600
return {
string.format("Money %s/h · Rolls %s/h", Util.FormatNumber(Reicht.Economy.Earned / hours), Util.FormatNumber(Reicht.Roll.Session / hours)),
string.format("Pulls %d · Gems %+d · Tower runs %d", watch.Pulls, Reicht.Data.Token("Gems") - (watch.StartGems or 0), Reicht.Tower.Runs),
"Best pull: " .. (watch.Best and Reicht.Watch.Describe(watch.Best) or "-"),
}
end
Reicht.Lock = { Status = "Off" }
function Reicht.Lock.Step()
if not Reicht.Options.AutoLock then return 0 end
local rank = GameLib.RarityOrder(Reicht.Options.LockRarity)
local mutations = Util.SetFromList(Reicht.Options.LockMutations)
local keys, count = {}, 0
for _, unit in ipairs(Reicht.Data.Units()) do
if unit.Locked then continue end
if (rank > 0 and GameLib.RarityOrder(unit.Rarity) >= rank) or (unit.Mutation and mutations[unit.Mutation]) then
keys[unit.Key] = true
count += 1
end
end
if count > 0 then
Reicht.Net.Fire("UnitService.RE.SetLocked", keys)
Reicht.Data.Invalidate()
end
Reicht.Lock.Status = count > 0 and (count .. " locked") or "Nothing new to lock"
return count
end
Reicht.Rejoin = { Hooked = false, Busy = false }
function Reicht.Rejoin.Now()
if Reicht.Rejoin.Busy then return end
Reicht.Rejoin.Busy = true
if Util.QueueTeleport then
local resume = Reicht.Options.Kaitun and "getgenv().AnimeDiceResume = true " or ""
pcall(Util.QueueTeleport, resume .. Reicht.Config.ReloadSource)
end
local ok, err = pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
if not ok then warn("[AnimeDice] rejoin:", err) end
task.delay(Reicht.Config.RejoinRetry, function() Reicht.Rejoin.Busy = false end)
end
function Reicht.Rejoin.Start()
Reicht.Options.AutoRejoin = true
if Reicht.Rejoin.Hooked then return end
Reicht.Rejoin.Hooked = true
Reicht:Connect(GuiService.ErrorMessageChanged, function(message)
if Reicht.Options.AutoRejoin and message ~= "" then task.delay(Reicht.Config.RejoinDelay, Reicht.Rejoin.Now) end
end)
end
function Reicht.Rejoin.Stop()
Reicht.Options.AutoRejoin = false
end
Reicht.Rewards = { Status = "Off", DailyRetryAt = 0, Member = nil }
function Reicht.Rewards.RedeemAll()
local redeemed = Reicht.Data.Table("RedeemedCodes")
local sent = 0
for code in pairs(GameLib.Codes or {}) do
if type(code) == "string" and not redeemed[code] then
Reicht.Net.Fire("CodesService.RE.RedeemCode", code)
sent += 1
task.wait(Reicht.Config.RedeemDelay)
end
end
return sent > 0 and (sent .. " codes redeemed") or "All codes already redeemed"
end
function Reicht.Rewards.ClaimQuests()
local periods = GameLib.Quests and GameLib.Quests.Periods
local records = Reicht.Data.Table("Quests")
if type(periods) ~= "table" then return 0 end
local claimedCount = 0
for period, def in pairs(periods) do
local record = records[period]
if type(record) ~= "table" or type(def) ~= "table" then continue end
local progress = type(record.progress) == "table" and record.progress or {}
local claimed = type(record.claimed) == "table" and record.claimed or {}
for _, quest in ipairs(def.quests or {}) do
if not claimed[quest.id] and (tonumber(progress[quest.id]) or 0) >= (tonumber(quest.target) or math.huge) then
Reicht.Net.Fire("QuestService.RE.Claim", period, quest.id, record.expiresAt)
claimedCount += 1
task.wait(Reicht.Config.ClaimDelay)
end
end
end
return claimedCount
end
function Reicht.Rewards.ClaimOffline()
if (tonumber(Reicht.Data.Read("PendingOfflineEarnings")) or 0) > 0 then
Reicht.Net.Fire("OfflineEarningsService.RE.Claim")
end
end
function Reicht.Rewards.DailyReady()
local cooldown = GameLib.Daily and tonumber(GameLib.Daily.Cooldown) or 82800
local last = tonumber(Reicht.Data.Read("LastDailyRewardClaim")) or 0
return os.time() - last >= cooldown and osClock() >= Reicht.Rewards.DailyRetryAt
end
function Reicht.Rewards.InGroup()
if Reicht.Rewards.Member == nil then
local groupId = GameLib.Group and tonumber(GameLib.Group.GroupId) or Reicht.Config.GroupId
local ok, member = pcall(LocalPlayer.IsInGroup, LocalPlayer, groupId)
Reicht.Rewards.Member = ok and member == true
end
return Reicht.Rewards.Member
end
function Reicht.Rewards.Step()
if Reicht.Options.AutoDaily and Reicht.Rewards.DailyReady() then
Reicht.Rewards.DailyRetryAt = osClock() + 60
Reicht.Net.Fire("DailyRewardService.RE.Claim")
end
if Reicht.Options.AutoGroup and not Reicht.Data.Read("ClaimedGroupReward") and Reicht.Rewards.InGroup() then
Reicht.Net.Fire("GroupRewardService.RE.Claim")
end
if Reicht.Options.AutoOffline then Reicht.Rewards.ClaimOffline() end
if Reicht.Options.AutoQuest then Reicht.Rewards.ClaimQuests() end
end
Reicht.Kaitun = { Status = "Off", Members = {
"AntiAfk", "AutoRejoin", "RareNotify", "AutoLock", "TowerSmart", "AutoFuse", "DisableCutscene", "AutoRoll", "AutoCollect", "EquipBestUnitsAuto", "AutoLevelUp",
"AutoBuyDice", "AutoEquipBestDice", "AutoBuyUpgrades", "AutoSell", "AutoRebirth", "AutoRebirthStats", "AutoGrade",
"AutoTrait", "AutoTower", "AutoPotion", "AutoSpin", "AutoGamepass", "AutoTicketShop", "AutoDaily", "AutoGroup",
"AutoOffline", "AutoQuest", "AutoGear", "AutoClearStorage",
} }
function Reicht.Kaitun.Slice(list, count, fromTop)
local picked = {}
local first = fromTop and math.max(#list - count + 1, 1) or 1
for index = first, math.min(first + count - 1, #list) do
table.insert(picked, list[index])
end
return picked
end
function Reicht.Kaitun.SetMembers(on)
local toggles = Reicht.Library and Reicht.Library.Toggles or {}
for _, idx in ipairs(Reicht.Kaitun.Members) do
if toggles[idx] then toggles[idx]:SetValue(on) else Reicht.Options[idx] = on end
end
end
function Reicht.Kaitun.Start()
Reicht.Options.Kaitun = true
local options = Reicht.Library and Reicht.Library.Options or {}
local function Default(idx, value)
if next(Util.SetFromList(Reicht.Options[idx])) ~= nil then return end
if options[idx] then options[idx]:SetValue(Util.SetFromList(value)) end
Reicht.Options[idx] = value
end
local slice = Reicht.Kaitun.Slice
local lists = Reicht.UI.Lists
local rarities, mutations = lists.Rarities, lists.Mutations
if table.find(GameLib.ShopNames(), "Gems") then Default("TicketShopItems", { "Gems" }) end
Default("SellRarities", slice(rarities, 2))
Default("LockMutations", slice(mutations, 3, true))
Default("NotifyRarities", slice(rarities, 4, true))
Default("NotifyMutations", slice(mutations, 2, true))
if options.LevelTarget then options.LevelTarget:SetValue(200) end
Reicht.Options.LevelTarget = 200
Reicht.Kaitun.SetMembers(true)
task.defer(function() Reicht.Rewards.RedeemAll() end)
end
function Reicht.Kaitun.Stop()
Reicht.Options.Kaitun = false
Reicht.Kaitun.SetMembers(false)
end
function Reicht.Kaitun.GetStatus()
return string.format("R%d · %s", Reicht.Data.Rebirth(), Reicht.Economy.GetStatus())
end
Reicht.UI = { Labels = {}, Lists = { Rarities = {}, Mutations = {} } }
local Library, T
function Reicht.UI.Detach(fn)
return function(...)
local packed = table.pack(...)
task.defer(function()
local ok, err = pcall(fn, table.unpack(packed, 1, packed.n))
if not ok then warn("[AnimeDice] ui: " .. tostring(err)) end
end)
end
end
function Reicht.UI.StartStop(module)
return Reicht.UI.Detach(function(on)
if on then module.Start() else module.Stop() end
end)
end
function Reicht.UI.Notify(title, text, kind)
Library:Notify(title, tostring(text), 4, kind or "Info")
end
function Reicht.UI.Values(source, ...)
local ok, list = pcall(source, ...)
return ok and type(list) == "table" and list or {}
end
function Reicht.UI.Prefer(values, preferred, fallback)
if table.find(values, preferred) then return preferred end
return values[math.clamp(fallback, 1, math.max(#values, 1))]
end
function Reicht.UI.MultiDropdown(group, idx, text, desc, values)
return group:AddDropdown(idx, {
Text = text,
Description = desc,
Values = values,
Multi = true,
Default = {},
AllowNull = true,
Searchable = true,
})
end
Reicht.UI.Needs = {
Kaitun = { "DataClient", "Entry" },
AutoCollect = { "DataClient" },
EquipBestUnitsAuto = { "DataClient", "Entry" },
AutoLevelUp = { "DataClient", "Entry", "UnitUtil" },
AutoTower = { "Towers" },
AutoSell = { "DataClient", "Entry" },
AutoClearStorage = { "DataClient", "Entry", "Buffs" },
AutoBuyDice = { "DataClient", "Dice" },
AutoEquipBestDice = { "DataClient", "Dice" },
AutoBuyUpgrades = { "DataClient", "Upgrades", "Tree", "Buffs", "BuffsConfig" },
AutoRebirth = { "DataClient", "Rebirths" },
AutoRebirthStats = { "DataClient", "RebirthStats" },
AutoGamepass = { "DataClient", "Entry" },
AutoGrade = { "DataClient", "Entry", "Grades" },
AutoTrait = { "DataClient", "Entry", "Traits" },
AutoFuse = { "DataClient", "Entry", "FusingConfig" },
AutoGear = { "DataClient", "Entry" },
AutoLock = { "DataClient", "Entry" },
AutoPotion = { "DataClient", "Entry" },
AutoSpin = { "DataClient", "Entry" },
AutoTicketShop = { "DataClient", "Quests" },
AutoQuest = { "DataClient", "Quests" },
AutoDaily = { "DataClient" },
AutoGroup = { "DataClient" },
AutoOffline = { "DataClient" },
RareNotify = { "DataClient", "Entry" },
}
Reicht.UI.Remotes = {
AutoRoll = { "RollService.RF.RollDice" },
AutoCollect = { "PlotService.RE.CollectBalance" },
EquipBestUnitsAuto = { "PlotService.RE.EquipBest", "PlotService.RE.InteractSlot", "UnitService.RF.Equip" },
AutoLevelUp = { "PlotService.RE.LevelUpSlot" },
AutoTower = { "Towers.RF.PlayTower", "Towers.RF.CompleteTowerFloor", "Towers.RF.CancelTower" },
AutoSell = { "SellService.RF.SellInventory" },
AutoClearStorage = { "SellService.RF.SellInventory" },
AutoBuyDice = { "DiceShopService.RE.BuyDice" },
AutoEquipBestDice = { "DiceShopService.RE.EquipDice" },
AutoBuyUpgrades = { "RE.BuyUpgrade" },
AutoRebirth = { "RebirthService.RE.Rebirth" },
AutoRebirthStats = { "RebirthService.RE.AddStat" },
AutoGamepass = { "GamepassService.RE.Use" },
AutoGrade = { "GradeService.RE.Roll" },
AutoTrait = { "TraitService.RE.Roll" },
AutoFuse = { "FusingService.RE.Fuse" },
AutoGear = { "GearService.RE.Equip" },
AutoLock = { "UnitService.RE.SetLocked" },
AutoPotion = { "BoostService.RE.Use" },
AutoSpin = { "SpinService.RE.Use" },
AutoTicketShop = { "QuestService.RE.Buy" },
AutoQuest = { "QuestService.RE.Claim" },
AutoDaily = { "DailyRewardService.RE.Claim" },
AutoGroup = { "GroupRewardService.RE.Claim" },
AutoOffline = { "OfflineEarningsService.RE.Claim" },
}
function Reicht.UI.MissingFor(idx)
for _, key in ipairs(Reicht.UI.Needs[idx] or {}) do
if GameLib[key] == nil then return key, false end
end
for _, path in ipairs(Reicht.UI.Remotes[idx] or {}) do
if not Reicht.Net.Get(path) then return path, true end
end
return nil, false
end
function Reicht.UI.Gate()
local blocked = 0
local seen = {}
for idx in pairs(Reicht.UI.Needs) do seen[idx] = true end
for idx in pairs(Reicht.UI.Remotes) do seen[idx] = true end
for idx in pairs(seen) do
local missing, isRemote = Reicht.UI.MissingFor(idx)
if not Library.Options[idx] or not missing then continue end
blocked += 1
warn("[AnimeDice] " .. idx .. " blocked, missing " .. (isRemote and "remote " or "module ") .. missing)
local reason = isRemote and T("The game changed, waiting for a script update", "เกมอัปเดต รอสคริปต์อัปเดต")
or T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้")
Library.Compat.Block(idx, reason)
end
if blocked == 0 then return end
Library:Notify("Reicht", T(blocked .. " features are turned off for now", "ปิดไว้ก่อน " .. blocked .. " ฟีเจอร์"), 8, "Warning")
end
function Reicht.UI.DrainHalted()
local halted = Reicht.State.Halted
while #halted > 0 do
local entry = table.remove(halted, 1)
local stopKaitun = false
for _, idx in ipairs(entry[2]) do
local toggle = Library.Toggles[idx]
if toggle and toggle.Value == true then toggle:SetValue(false) end
stopKaitun = stopKaitun or table.find(Reicht.Kaitun.Members, idx) ~= nil
end
local kaitun = Library.Toggles.Kaitun
if stopKaitun and kaitun and kaitun.Value == true then kaitun:SetValue(false) end
Library:Notify("Reicht", entry[1] .. " stopped: " .. tostring(entry[3]), 8, "Error")
end
end
function Reicht.UI.DrainNotices()
local notices = Reicht.State.Notices
while #notices > 0 do
local notice = table.remove(notices, 1)
Library:Notify(notice[1], notice[2], 8, "Warning")
end
end
function Reicht.UI.BuildMain(window)
local tab = window:AddTab(T("Home", "หน้าแรก"), "mushroom", T("Status and full auto", "สถานะและโหมดอัตโนมัติ"))
local status = tab:AddLeftGroupbox(T("Status", "สถานะ"), "star")
Reicht.UI.Labels.Economy = status:AddParagraph({ Title = T("Economy", "เศรษฐกิจ"), Content = "-" })
Reicht.UI.Labels.Roll = status:AddParagraph({ Title = T("Rolling", "การทอย"), Content = "-" })
Reicht.UI.Labels.Units = status:AddParagraph({ Title = T("Units", "ตัวละคร"), Content = "-" })
Reicht.UI.Labels.Tower = status:AddParagraph({ Title = T("Tower", "หอคอย"), Content = "-" })
local stats = tab:AddLeftGroupbox(T("Session Stats", "สถิติรอบนี้"), "flag")
Reicht.UI.Labels.Stats = stats:AddParagraph({ Title = T("This session", "รอบนี้"), Content = "-" })
local discord = tab:AddRightGroupbox(T("Discord", "ดิสคอร์ด"), "link")
discord:AddLabel(Reicht.Config.Discord)
discord:AddButton({ Text = T("Copy Discord Link", "คัดลอกลิงก์ดิสคอร์ด"), Func = Reicht.UI.Detach(function()
if Util.Copy(Reicht.Config.Discord) then
Library:Notify(T("Discord", "ดิสคอร์ด"), T("Link copied", "คัดลอกลิงก์แล้ว"), 3, "Success")
else
Library:Notify(T("Discord", "ดิสคอร์ด"), Reicht.Config.Discord, 6, "Info")
end
end) })
local logBox = tab:AddRightGroupbox(T("Update Log", "อัปเดตล่าสุด"), "bell")
for i = 1, math.min(2, #Reicht.Config.UpdateLog) do
local entry = Reicht.Config.UpdateLog[i]
logBox:AddParagraph({ Title = entry[1], Content = entry[2] })
end
local master = tab:AddRightGroupbox(T("Kaitun", "ไคตุน"), "qblock")
master:AddToggle("Kaitun", {
Text = T("Kaitun (full auto)", "ไคตุน (อัตโนมัติทั้งหมด)"),
Description = T("Rolls, levels, upgrades, grades, climbs towers and rebirths on its own", "ทอย อัปเลเวล อัปเกรด รีเกรด ไต่หอคอย และรีเบิร์ธเองทั้งหมด"),
Callback = Reicht.UI.StartStop(Reicht.Kaitun),
})
Reicht.UI.Labels.Kaitun = master:AddParagraph({ Title = T("Progress", "ความคืบหน้า"), Content = "-" })
end
function Reicht.UI.BuildFarm(window)
local tab = window:AddTab(T("Auto Farm", "ฟาร์มอัตโนมัติ"), "coin", T("Rolling, plot and levels", "ทอย ฐาน และเลเวล"))
local rarities = Reicht.UI.Values(GameLib.UnitRarities)
local roll = tab:AddLeftGroupbox(T("Rolling", "การทอย"), "star")
roll:AddToggle("AutoRoll", { Text = T("Fast roll", "ทอยเร็ว"), Description = T("Rolls non-stop with no roll animation", "ทอยต่อเนื่องไม่มีแอนิเมชัน") })
roll:AddSlider("RollInterval", { Text = T("Roll interval", "ความถี่ทอย"), Min = 0.02, Max = 0.5, Default = 0.02, Rounding = 2, Suffix = "s" })
roll:AddButton({ Text = T("Roll Once", "ทอย 1 ครั้ง"), Func = Reicht.UI.Detach(function() Reicht.Roll.Once() end) })
roll:AddButton({ Text = T("Reset roll counter", "รีเซ็ตตัวนับการทอย"), Func = Reicht.UI.Detach(Reicht.Roll.ResetCounter) })
local plot = tab:AddLeftGroupbox(T("Placement", "วางตัว"), "castle")
plot:AddToggle("EquipBestUnitsAuto", { Text = T("Auto equip best", "วางตัวดีสุดอัตโนมัติ") })
plot:AddDropdown("PlacementMode", {
Text = T("Pick units by", "เลือกตัวตาม"),
Description = T("Potential places your strongest units even at level 1", "ศักยภาพ = วางตัวที่เก่งจริงแม้ยังเลเวล 1"),
Values = { "Potential", "Current income" },
Default = "Potential",
})
plot:AddSlider("EquipInterval", { Text = T("Equip interval", "ความถี่วางตัว"), Min = 1, Max = 120, Default = 5, Rounding = 0, Suffix = "s" })
plot:AddButton({ Text = T("Equip Best Now", "วางตัวดีสุดตอนนี้"), Func = Reicht.UI.Detach(Reicht.Plot.EquipBest) })
local collect = tab:AddRightGroupbox(T("Collect", "เก็บเงิน"), "coin")
collect:AddToggle("AutoCollect", { Text = T("Auto collect", "เก็บเงินอัตโนมัติ") })
collect:AddSlider("CollectInterval", { Text = T("Collect interval", "ความถี่เก็บเงิน"), Min = 0.5, Max = 60, Default = 1, Rounding = 1, Suffix = "s" })
collect:AddButton({ Text = T("Collect Now", "เก็บเงินตอนนี้"), Func = Reicht.UI.Detach(Reicht.Plot.CollectNow) })
local level = tab:AddRightGroupbox(T("Level Up", "อัปเลเวล"), "oneup")
level:AddToggle("AutoLevelUp", { Text = T("Auto level up", "อัปเลเวลอัตโนมัติ"), Description = T("Levels plotted units when you can afford it", "อัปเลเวลตัวบนฐานเมื่อเงินพอ") })
level:AddDropdown("LevelMinRarity", { Text = T("Minimum rarity (plotted units)", "rarity ขั้นต่ำ (ตัวบนฐาน)"), Values = rarities, Default = Reicht.UI.Prefer(rarities, "Common", 1), Searchable = true })
level:AddSlider("LevelTarget", { Text = T("Target level", "เลเวลเป้าหมาย"), Min = 2, Max = 200, Default = 10, Rounding = 0 })
level:AddSlider("LevelPayback", { Text = T("Max payback time", "คืนทุนไม่เกิน"), Description = T("Buys levels that pay back fast without delaying dice or rebirth", "อัปเฉพาะเลเวลที่คืนทุนเร็ว ไม่ทำให้เต๋า/รีเบิร์ธช้าลง"), Min = 10, Max = 3600, Default = 180, Rounding = 0, Suffix = "s" })
level:AddButton({ Text = T("Run a pass", "อัปเลเวล 1 รอบ"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Level Up", "อัปเลเวล"), Reicht.Plot.LevelPass(true) .. " levelled", "Success")
end) })
end
function Reicht.UI.BuildEconomy(window)
local tab = window:AddTab(T("Economy", "เศรษฐกิจ"), "shop", T("Dice, upgrades, selling, rebirth", "เต๋า อัปเกรด ขาย รีเบิร์ธ"))
local rarities = Reicht.UI.Values(GameLib.UnitRarities)
local dice = tab:AddLeftGroupbox(T("Dice", "เต๋า"), "qblock")
dice:AddToggle("AutoBuyDice", { Text = T("Auto buy dice", "ซื้อเต๋าอัตโนมัติ"), Description = T("Buys the luckiest dice you can afford", "ซื้อเต๋าที่ดวงดีสุดเท่าที่เงินถึง") })
dice:AddToggle("AutoEquipBestDice", { Text = T("Equip best owned dice", "ใส่เต๋าดีสุดที่มี") })
dice:AddButton({ Text = T("Equip Best Now", "ใส่เต๋าดีสุดตอนนี้"), Func = Reicht.UI.Detach(Reicht.Dice.EquipBest) })
local upgrade = tab:AddRightGroupbox(T("Upgrades", "อัปเกรด"), "star")
upgrade:AddToggle("AutoBuyUpgrades", { Text = T("Auto upgrades", "อัปเกรดอัตโนมัติ") })
Reicht.UI.MultiDropdown(upgrade, "UpgradeFilter", T("Branches to upgrade", "สายที่จะอัปเกรด"),
T("Empty buys every branch", "ไม่เลือก = ซื้อทุกสาย"), Reicht.UI.Values(Reicht.Upgrade.Branches))
upgrade:AddSlider("UpgradePayback", { Text = T("Max income payback", "คืนทุนรายได้ไม่เกิน"), Description = T("Buys money and luck upgrades only when they are worth it", "ซื้ออัปเกรดเงินและดวงเฉพาะตอนคุ้ม"), Min = 30, Max = 7200, Default = 1800, Rounding = 0, Suffix = "s" })
upgrade:AddButton({ Text = T("Buy available upgrades", "ซื้ออัปเกรดที่ซื้อได้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Upgrades", "อัปเกรด"), Reicht.Upgrade.BuyAll() .. " bought", "Success")
end) })
local sell = tab:AddLeftGroupbox(T("Sell", "ขาย"), "coin")
sell:AddToggle("AutoSell", { Text = T("Auto sell", "ขายอัตโนมัติ"), Description = T("Never sells units on your plot or tower team", "ไม่ขายตัวที่อยู่บนฐานหรือในทีมหอคอย") })
Reicht.UI.MultiDropdown(sell, "SellRarities", T("Rarities to sell", "rarity ที่จะขาย"), nil, rarities)
Reicht.UI.MultiDropdown(sell, "SellKeepMutations", T("Mutations to keep", "mutation ที่เก็บไว้"), nil, Reicht.UI.Values(GameLib.MutationNames))
sell:AddSlider("KeepPerRarity", { Text = T("Keep best per rarity", "เก็บตัวดีสุดต่อ rarity"), Min = 0, Max = 20, Default = 0, Rounding = 0 })
sell:AddSlider("SellInterval", { Text = T("Interval", "ความถี่"), Min = 0.5, Max = 60, Default = 2, Rounding = 1, Suffix = "s" })
sell:AddButton({ Text = T("Sell Now", "ขายตอนนี้"), Style = "Warning", Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Sell", "ขาย"), Reicht.Sell.SellNow(), "Coin")
end) })
local storage = tab:AddRightGroupbox(T("Full Storage", "กระเป๋าเต็ม"), "bomb")
storage:AddToggle("AutoClearStorage", { Text = T("Auto clear full storage", "เคลียร์กระเป๋าเมื่อเต็ม"), Description = T("Sells your weakest spare units so rolling never stops", "ขายตัวสำรองที่อ่อนสุดเพื่อให้ทอยได้ไม่หยุด") })
storage:AddDropdown("ClearKeepRarity", { Text = T("Never clear rarity and above", "ไม่เคลียร์ rarity นี้ขึ้นไป"), Values = rarities, Default = Reicht.UI.Prefer(rarities, "Mythical", math.ceil(#rarities / 2)), Searchable = true })
local rebirth = tab:AddRightGroupbox(T("Rebirth", "รีเบิร์ธ"), "flag")
rebirth:AddToggle("AutoRebirth", { Text = T("Auto rebirth", "รีเบิร์ธอัตโนมัติ"), Description = T("Rebirths the moment you can afford it", "รีเบิร์ธทันทีที่เงินถึง") })
rebirth:AddButton({ Text = T("Rebirth Now", "รีเบิร์ธตอนนี้"), Style = "Primary", Func = Reicht.UI.Detach(function()
Reicht.Rebirth.RebirthNow()
Reicht.UI.Notify(T("Rebirth", "รีเบิร์ธ"), Reicht.Rebirth.Status)
end) })
local statNames = Reicht.UI.Values(GameLib.RebirthStatNames)
local stats = tab:AddLeftGroupbox(T("Rebirth Stats", "สเตตัสรีเบิร์ธ"), "oneup")
stats:AddToggle("AutoRebirthStats", { Text = T("Auto spend points", "ลงแต้มอัตโนมัติ"), Description = T("Puts every new rebirth point into the stat below", "ลงแต้มรีเบิร์ธใหม่ทุกแต้มที่สเตตัสด้านล่าง") })
stats:AddDropdown("RebirthStat", { Text = T("Stat", "สเตตัส"), Values = statNames, Default = Reicht.UI.Prefer(statNames, "Money", 1) })
stats:AddButton({ Text = T("Spend Points Now", "ลงแต้มตอนนี้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Rebirth Stats", "สเตตัสรีเบิร์ธ"), Reicht.Rebirth.SpendPoints() .. " points spent")
end) }):AddButton({ Text = T("Reset Stats", "รีเซ็ตสเตตัส"), Func = Reicht.UI.Detach(function()
local ok, why = Reicht.Rebirth.ResetStats()
Reicht.UI.Notify(T("Rebirth Stats", "สเตตัสรีเบิร์ธ"), ok and "Reset Token used" or why)
end) })
end
function Reicht.UI.BuildUnits(window)
local tab = window:AddTab(T("Units", "ตัวละคร"), "heart", T("Grades, traits, fusing", "เกรด trait หลอมรวม"))
local rarities = Reicht.UI.Values(GameLib.UnitRarities)
local mutations = Reicht.UI.Values(GameLib.MutationNames)
local grades, traits = Reicht.UI.Values(GameLib.GradeNames), Reicht.UI.Values(GameLib.TraitNames)
local grade = tab:AddLeftGroupbox(T("Grades", "เกรด"), "star")
grade:AddToggle("AutoGrade", { Text = T("Auto grade", "รีเกรดอัตโนมัติ"), Description = T("Rerolls units on your plot and tower team up to the minimum", "รีเกรดตัวบนฐานและในทีมหอคอยจนถึงขั้นต่ำ") })
grade:AddDropdown("GradeTarget", { Text = T("Minimum grade", "เกรดขั้นต่ำ"), Values = grades, Default = Reicht.UI.Prefer(grades, "S", math.ceil(#grades / 2)) })
grade:AddToggle("GradeOverwrite", { Text = T("Overwrite protected tiers (S+)", "ยอมทับเกรดที่ป้องกันไว้ (S+)"), Risky = true })
grade:AddButton({ Text = T("Grade Once", "รีเกรด 1 ครั้ง"), Func = Reicht.UI.Detach(Reicht.Grade.RollOne) })
local trait = tab:AddLeftGroupbox(T("Traits", "trait"), "shell")
trait:AddToggle("AutoTrait", { Text = T("Auto trait", "รี trait อัตโนมัติ"), Description = T("Rerolls units on your plot and tower team up to the minimum", "รี trait ตัวบนฐานและในทีมหอคอยจนถึงขั้นต่ำ") })
trait:AddDropdown("TraitTarget", { Text = T("Minimum trait", "trait ขั้นต่ำ"), Values = traits, Default = Reicht.UI.Prefer(traits, "Samurai", math.ceil(#traits / 2)), Searchable = true })
trait:AddToggle("TraitOverwrite", { Text = T("Overwrite protected tiers (Samurai/Shogun)", "ยอมทับ trait ที่ป้องกันไว้ (Samurai/Shogun)"), Risky = true })
trait:AddButton({ Text = T("Trait Once", "รี trait 1 ครั้ง"), Func = Reicht.UI.Detach(Reicht.Trait.RollOne) })
local lock = tab:AddRightGroupbox(T("Auto Lock", "ล็อกอัตโนมัติ"), "key")
lock:AddToggle("AutoLock", { Text = T("Auto lock rare units", "ล็อกตัวหายากอัตโนมัติ"), Description = T("Locked units are never sold or fused", "ตัวที่ล็อกจะไม่ถูกขายหรือหลอม") })
lock:AddDropdown("LockRarity", { Text = T("Lock rarity and above", "ล็อก rarity นี้ขึ้นไป"), Values = rarities, Default = Reicht.UI.Prefer(rarities, "Secret I", #rarities - 3), Searchable = true })
Reicht.UI.MultiDropdown(lock, "LockMutations", T("Lock mutations", "ล็อก mutation"), nil, mutations)
local gear = tab:AddRightGroupbox(T("Gear", "อุปกรณ์"), "shield")
gear:AddToggle("AutoGear", { Text = T("Auto equip best gear", "ใส่อุปกรณ์ดีสุดอัตโนมัติ"), Description = T("Wears your rarest gear in every slot", "ใส่ชิ้นที่หายากสุดทุกช่อง") })
gear:AddButton({ Text = T("Equip Best Now", "ใส่ดีสุดตอนนี้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Gear", "อุปกรณ์"), Reicht.Gear.EquipBest() .. " slots upgraded", "Success")
end) })
local fuse = tab:AddRightGroupbox(T("Fusing", "หลอมรวม"), "bomb")
fuse:AddToggle("AutoFuse", { Text = T("Auto Fuse", "หลอมอัตโนมัติ"), Description = T("Fuses spare trios only when the result is expected to be rarer and the cost is small", "หลอมตัวสำรองเฉพาะเมื่อผลที่คาดไว้หายากกว่าเดิมและค่าหลอมถูก"), Risky = true })
Reicht.UI.MultiDropdown(fuse, "FuseRarities", T("Rarities to fuse", "rarity ที่จะหลอม"), T("Empty uses any spare below the never-clear rarity", "ไม่เลือก = ใช้ตัวสำรองที่ต่ำกว่า rarity ที่ไม่เคลียร์"), rarities)
fuse:AddButton({ Text = T("Fuse Now", "หลอมตอนนี้"), Func = Reicht.UI.Detach(Reicht.Fuse.FuseNow) })
end
function Reicht.UI.BuildTower(window)
local tab = window:AddTab(T("Tower", "หอคอย"), "castle", T("Tower climbing for Gems", "ไต่หอคอยเก็บ Gems"))
local group = tab:AddLeftGroupbox(T("Auto Tower", "ไต่หอคอยอัตโนมัติ"), "castle")
group:AddToggle("AutoTower", { Text = T("Auto tower", "ไต่หอคอยอัตโนมัติ"), Description = T("Climbs, restarts after each run and keeps going", "ไต่ จบรอบแล้วเริ่มใหม่ต่อเนื่อง") })
local labels = Reicht.UI.Values(Reicht.Tower.Labels)
group:AddDropdown("TowerDifficulty", {
Text = T("Difficulty", "ความยาก"),
Values = labels,
Default = labels[1],
Callback = function(label) Reicht.Options.TowerName = Reicht.Tower.NameFromLabel(label) end,
})
group:AddToggle("TowerSmart", { Text = T("Auto Difficulty", "ปรับความยากอัตโนมัติ"), Description = T("Moves up after a full clear and down when the team falls early", "ขึ้นหอยากขึ้นเมื่อผ่านหมด ลดลงเมื่อแพ้เร็ว") })
if labels[1] then Reicht.Options.TowerName = Reicht.Tower.NameFromLabel(labels[1]) end
local run = tab:AddRightGroupbox(T("Run Settings", "ตั้งค่ารอบ"), "flag")
run:AddSlider("TowerStopFloor", { Text = T("Stop at floor", "หยุดที่ชั้น"), Min = 1, Max = 500, Default = 100, Rounding = 0 })
run:AddToggle("TowerReequip", { Text = T("Re-equip before each run", "จัดทีมใหม่ก่อนทุกรอบ") })
run:AddButton({ Text = T("Equip best team", "จัดทีมดีสุด"), Func = Reicht.UI.Detach(Reicht.Tower.EquipTeam) })
end
function Reicht.UI.BuildItems(window)
local tab = window:AddTab(T("Items", "ไอเทม"), "flower", T("Potions, spins, ticket shop", "ยา สปิน ร้านตั๋ว"))
local potion = tab:AddLeftGroupbox(T("Potions", "ยาบัฟ"), "flower")
potion:AddToggle("AutoPotion", { Text = T("Auto potion", "ใช้ยาอัตโนมัติ"), Description = T("Uses each boost only when it helps", "ใช้บัฟแต่ละตัวเฉพาะตอนมีประโยชน์") })
Reicht.UI.MultiDropdown(potion, "PotionFilter", T("Potions to use", "ยาที่จะใช้"), T("Empty uses every potion", "ไม่เลือก = ใช้ทุกชนิด"), Reicht.UI.Values(GameLib.NamesOfKind, "Boost"))
potion:AddButton({ Text = T("Use Now", "ใช้ตอนนี้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Potions", "ยาบัฟ"), Reicht.Items.UsePotions(true) .. " used", "Power")
end) })
local spin = tab:AddRightGroupbox(T("Spins", "สปิน"), "star")
spin:AddToggle("AutoSpin", { Text = T("Auto use spins", "ใช้สปินอัตโนมัติ"), Description = T("Uses Lucky and Jackpot spins", "ใช้ Lucky และ Jackpot spin") })
spin:AddButton({ Text = T("Use Spins Now", "ใช้สปินตอนนี้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Spins", "สปิน"), Reicht.Items.UseSpins() .. " used")
end) })
spin:AddToggle("AutoGamepass", { Text = T("Auto use gamepass items", "ใช้ไอเทมเกมพาสอัตโนมัติ"), Description = T("Unlocks gamepasses you got from codes and rewards", "ปลดล็อกเกมพาสที่ได้จากโค้ดและรางวัล") })
local shop = tab:AddRightGroupbox(T("Ticket Shop", "ร้านตั๋ว"), "shop")
shop:AddToggle("AutoTicketShop", { Text = T("Auto buy with tickets", "ซื้อด้วยตั๋วอัตโนมัติ"), Description = T("Spends quest tickets on what you pick", "ใช้ตั๋วเควสต์ซื้อของที่เลือก") })
Reicht.UI.MultiDropdown(shop, "TicketShopItems", T("Items to buy", "ของที่จะซื้อ"), nil, Reicht.UI.Values(GameLib.ShopNames))
shop:AddButton({ Text = T("Buy Now", "ซื้อตอนนี้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Ticket Shop", "ร้านตั๋ว"), Reicht.Items.BuyTicketShop() .. " bought", "Coin")
end) })
end
function Reicht.UI.BuildRewards(window)
local tab = window:AddTab(T("Rewards", "รางวัล"), "key", T("Codes, daily, quests", "โค้ด รายวัน เควสต์"))
local codes = tab:AddLeftGroupbox(T("Codes", "โค้ด"), "qblock")
codes:AddButton({ Text = T("Redeem All Codes", "แลกโค้ดทั้งหมด"), Style = "Primary", Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Codes", "โค้ด"), Reicht.Rewards.RedeemAll(), "Success")
end) })
local quest = tab:AddLeftGroupbox(T("Quests", "เควสต์"), "flag")
quest:AddToggle("AutoQuest", { Text = T("Auto claim quests", "รับรางวัลเควสต์อัตโนมัติ") })
quest:AddButton({ Text = T("Claim now", "รับตอนนี้"), Func = Reicht.UI.Detach(function()
Reicht.UI.Notify(T("Quests", "เควสต์"), Reicht.Rewards.ClaimQuests() .. " claimed", "Success")
end) })
local claims = tab:AddRightGroupbox(T("Claims", "รับรางวัล"), "coin")
claims:AddToggle("AutoDaily", { Text = T("Auto daily reward", "รับรางวัลรายวันอัตโนมัติ") })
claims:AddToggle("AutoGroup", { Text = T("Auto group reward", "รับรางวัลกลุ่มอัตโนมัติ") })
claims:AddToggle("AutoOffline", { Text = T("Auto offline earnings", "รับรายได้ออฟไลน์อัตโนมัติ") })
end
function Reicht.UI.BuildPlayer(window)
local tab = window:AddTab(T("Player", "ผู้เล่น"), "oneup", T("Movement and utility", "การเคลื่อนที่และอรรถประโยชน์"))
local move = tab:AddLeftGroupbox(T("Movement", "การเคลื่อนที่"), "gear")
move:AddToggle("WalkSpeed", { Text = T("Walk speed", "ความเร็วเดิน"), Callback = Reicht.UI.Detach(function(on)
if on then Reicht.Move.SpeedStart() else Reicht.Move.SpeedStop() end
end) })
move:AddSlider("WalkSpeedValue", { Text = T("Speed", "ความเร็ว"), Min = 16, Max = 200, Default = 32, Rounding = 0 })
move:AddToggle("InfiniteJump", { Text = T("Infinite jump", "กระโดดไม่จำกัด"), Callback = Reicht.UI.Detach(function(on)
if on then Reicht.Move.JumpStart() else Reicht.Move.JumpStop() end
end) })
local util = tab:AddLeftGroupbox(T("Utility", "อรรถประโยชน์"), "star")
util:AddToggle("AntiAfk", { Text = T("Anti-AFK", "กันหลุด AFK"), Callback = Reicht.UI.StartStop(Reicht.AntiAfk) })
util:AddToggle("AutoRejoin", { Text = T("Auto rejoin", "รีจอยน์อัตโนมัติ"), Description = T("Rejoins after a disconnect and resumes Kaitun", "เข้าเกมใหม่เมื่อหลุดและทำไคตุนต่อ"), Callback = Reicht.UI.StartStop(Reicht.Rejoin) })
util:AddToggle("DisableCutscene", { Text = T("Disable cutscenes", "ปิดคัตซีน"), Description = T("Skips roll and fuse reveal cutscenes", "ข้ามคัตซีนตอนทอยและหลอม"), Callback = function(on)
if not on then Reicht.Cutscene.Restore() end
end })
local air = tab:AddRightGroupbox(T("Fly and No Clip", "บินและทะลุกำแพง"), "pipe")
air:AddToggle("NoClip", { Text = T("No clip", "ทะลุกำแพง"), Callback = Reicht.UI.Detach(function(on)
if on then Reicht.Move.NoClipStart() else Reicht.Move.NoClipStop() end
end) }):AddKeyPicker("NoClipKey", { Default = "None", Mode = "Toggle" })
air:AddToggle("Fly", { Text = T("Fly", "บิน"), Callback = Reicht.UI.Detach(function(on)
if on then Reicht.Move.FlyStart() else Reicht.Move.FlyStop() end
end) }):AddKeyPicker("FlyKey", { Default = "None", Mode = "Toggle" })
air:AddSlider("FlySpeed", { Text = T("Fly speed", "ความเร็วบิน"), Min = 20, Max = 300, Default = 60, Rounding = 0 })
local alerts = tab:AddRightGroupbox(T("Rare Alerts", "แจ้งเตือนของหายาก"), "bell")
alerts:AddToggle("RareNotify", { Text = T("Alert on rare pulls", "แจ้งเตือนเมื่อได้ของหายาก") })
Reicht.UI.MultiDropdown(alerts, "NotifyRarities", T("Rarities", "rarity"), nil, Reicht.UI.Values(GameLib.UnitRarities))
Reicht.UI.MultiDropdown(alerts, "NotifyMutations", T("Mutations", "mutation"), nil, Reicht.UI.Values(GameLib.MutationNames))
alerts:AddInput("WebhookUrl", { Text = T("Discord webhook", "Discord webhook"), Default = "", Placeholder = T("Optional webhook URL", "ลิงก์ webhook (ไม่ใส่ก็ได้)"), Finished = true })
alerts:AddButton({ Text = T("Send test alert", "ทดสอบแจ้งเตือน"), Func = Reicht.UI.Detach(function()
local rarities, mutations = Reicht.UI.Lists.Rarities, Reicht.UI.Lists.Mutations
Reicht.Watch.Alert({ Name = "Test", Rarity = rarities[#rarities] or "?", Mutation = mutations[#mutations] })
end) })
end
function Reicht.UI.RefreshStatus()
local labels = Reicht.UI.Labels
if not labels.Kaitun then return end
labels.Economy:SetContent(string.format("$%s · R%d · Gems %s · Tickets %s",
Util.FormatNumber(Reicht.Data.Money()), Reicht.Data.Rebirth(),
Util.FormatNumber(Reicht.Data.Token("Gems")), Util.FormatNumber(Reicht.Data.Token("Tickets"))))
labels.Roll:SetContent(Reicht.Roll.GetStatus())
labels.Units:SetContent(string.format("Storage %s · Grade: %s · Trait: %s", Reicht.Storage.Status, Reicht.Grade.Status, Reicht.Trait.Status))
labels.Tower:SetContent(Reicht.Tower.GetStatus())
labels.Kaitun:SetContent(Reicht.Kaitun.GetStatus() .. "\nUpgrades: " .. Reicht.Upgrade.Status .. "\nLevels: " .. Reicht.Plot.Status)
labels.Stats:SetContent(table.concat(Reicht.Watch.Stats(), "\n"))
end
function Reicht.UI.BindOptions()
for key in pairs(Reicht.Options) do
local widget = Library.Options[key]
if widget and widget.OnChanged then
Reicht.Options[key] = widget.Value
widget:OnChanged(function(value)
Reicht.Options[key] = value
if value == true then Reicht.Scheduler.Resume(key) end
end)
end
end
end
function Reicht.UI.Build()
local window = Library.Window
Reicht.UI.Lists = { Rarities = Reicht.UI.Values(GameLib.UnitRarities), Mutations = Reicht.UI.Values(GameLib.MutationNames) }
local layout = {
{ T("Main", "หลัก"), "Main", Reicht.UI.BuildMain },
{ T("Farming", "ฟาร์ม"), "Farm", Reicht.UI.BuildFarm },
{ nil, "Tower", Reicht.UI.BuildTower },
{ T("Progression", "พัฒนา"), "Units", Reicht.UI.BuildUnits },
{ nil, "Economy", Reicht.UI.BuildEconomy },
{ nil, "Items", Reicht.UI.BuildItems },
{ nil, "Rewards", Reicht.UI.BuildRewards },
{ T("Misc", "อื่นๆ"), "Player", Reicht.UI.BuildPlayer },
}
for _, section in ipairs(layout) do
if section[1] then window:AddTabSection(section[1]) end
Util.Try("ui " .. section[2], section[3], window)
end
Util.Try("ui settings", window.AddSettingsTab, window)
Util.Try("ui bind", Reicht.UI.BindOptions)
Util.Try("ui gate", Reicht.UI.Gate)
Library:Every(Reicht.Config.StatusInterval, Reicht.UI.RefreshStatus)
Library:Every(Reicht.Config.StatusInterval, Reicht.UI.DrainHalted)
Library:Every(Reicht.Config.StatusInterval, Reicht.UI.DrainNotices)
end
local function BuildInterface()
local lib, problem = Util.LoadLibrary(Reicht.Config.UiSource)
if not lib then
Util.Alert(problem)
return
end
Library = lib
pcall(ReichtBanner.Step, "UI library")
Reicht.Library = Library
T = function(en, th) return Library:T(en, th) end
Library:CreateWindow({
Title = "Reicht",
SubTitle = "Anime Dice by Reicht",
MenuKey = Enum.KeyCode.LeftControl,
ConfigFolder = Reicht.Config.SaveFolder,
Language = "Auto",
Theme = "Overworld",
Intro = true,
OnUnlocked = function()
Reicht.UI.Build()
task.defer(Util.Try, "boot", Reicht.Boot)
task.defer(function()
Util.Try("autoload config", Library.LoadAutoloadConfig, Library)
if environment.AnimeDiceResume then
environment.AnimeDiceResume = nil
if Library.Toggles.Kaitun then Library.Toggles.Kaitun:SetValue(true) end
end
end)
end,
})
Library:OnUnload(function()
Reicht:Unload()
end)
return true
end
function Reicht.Boot()
Reicht:Connect(LocalPlayer.CharacterAdded, function(character)
Reicht.Player:Bind(character)
task.defer(Reicht.Move.Rebind)
end)
Reicht.Roll.ResetCounter()
local options, config = Reicht.Options, Reicht.Config
local every = Reicht.Scheduler.Every
every("Roll", function() return options.RollInterval end, Reicht.Roll.Step, { "AutoRoll" })
every("Collect", function() return options.CollectInterval end, Reicht.Plot.CollectStep, { "AutoCollect" })
every("Equip", function() return options.EquipInterval end, Reicht.Plot.EquipStep, { "EquipBestUnitsAuto" })
every("Economy", 1, Reicht.Economy.Step, { "AutoBuyDice", "AutoEquipBestDice", "AutoRebirth", "AutoRebirthStats", "AutoBuyUpgrades", "AutoLevelUp" })
every("Sell", function() return options.SellInterval end, Reicht.Sell.Step, { "AutoSell" })
every("Storage", 1, Reicht.Storage.Step, { "AutoClearStorage" })
every("Grade", config.GradeDelay, Reicht.Grade.Step, { "AutoGrade" })
every("Trait", config.TraitDelay, Reicht.Trait.Step, { "AutoTrait" })
every("Fuse", config.FuseDelay, Reicht.Fuse.Step, { "AutoFuse" })
every("Tower", config.TowerTick, Reicht.Tower.Step, { "AutoTower" })
every("Items", config.RewardsInterval, Reicht.Items.Step, { "AutoPotion", "AutoSpin", "AutoGamepass", "AutoTicketShop" })
every("Gear", config.RewardsInterval, Reicht.Gear.Step, { "AutoGear" })
every("Watch", 1, Reicht.Watch.Step, { "RareNotify" })
every("Lock", config.RewardsInterval, Reicht.Lock.Step, { "AutoLock" })
every("Rewards", config.RewardsInterval, Reicht.Rewards.Step, { "AutoDaily", "AutoGroup", "AutoOffline", "AutoQuest" })
every("Speed", 1, Reicht.Move.ApplyWalkSpeed, { "WalkSpeed" })
every("Cutscene", 1, Reicht.Cutscene.Step, { "DisableCutscene" })
Reicht.Scheduler.Boot()
end
function Reicht:Unload()
self.State.Alive = false
if environment.AnimeDiceUnload == self.State.UnloadEntry then environment.AnimeDiceUnload = nil end
self.Options.AutoTower = false
if Reicht.Tower.State ~= "Idle" then Reicht.Tower.Leave() end
Reicht.Move.SpeedStop()
Reicht.Move.NoClipStop()
Reicht.Move.FlyStop()
Reicht.Cutscene.Restore()
for _, connection in ipairs(self.State.Connections) do
pcall(function() connection:Disconnect() end)
end
table.clear(self.State.Connections)
end
Reicht.State.UnloadEntry = function()
if Reicht.Library and not Reicht.Library.Unloaded then
Reicht.Library:Unload()
else
Reicht:Unload()
end
end
environment.AnimeDiceUnload = Reicht.State.UnloadEntry
if LocalPlayer.Character then
Reicht.Player:Bind(LocalPlayer.Character)
end
pcall(ReichtBanner.Step, "Systems")
if BuildInterface() then
pcall(ReichtBanner.Step, "Interface")
pcall(ReichtBanner.Ready)
end