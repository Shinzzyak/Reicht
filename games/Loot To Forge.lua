if not game:IsLoaded() then
game.Loaded:Wait()
end
if game.GameId ~= 10684750879 then
game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Loot To Forge only")
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
if ok and type(renv) == "table" and type(renv.print) == "function" then
ReichtBanner.Print = renv.print
end
end
function ReichtBanner.Show()
local ok, executor = pcall(identifyexecutor)
if not ok or type(executor) ~= "string" then
executor = "Unknown"
end
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
"   LOOT TO FORGE  //  by Reicht  //  ",
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
if not LPH_OBFUSCATED then
local function Passthrough(fn) return fn end
LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Reicht = setmetatable({}, {
__newindex = function(self, key, value)
rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
end,
})
Reicht.Config = {
SaveFolder = "Loot To Forge",
Discord = "https://",
UpdateLog = {
{ "2026-10-20 (V6.0)", "Insane OP World-Class Exploits Suite\n• God Power Burst: 1.5 - 3.0 Trillion Power/sec via parallel 500-token stream engine\n• 0ms Instant Mob Wipe: Client-authoritative instant map clear with zero delay\n• World Boss Hop Sniper: Auto-scans, instant-nukes, claims cards for infinite 15% Protect Scrolls & 50% Tickets\n• Remote Instant Bulk Forge: Forge up to 100 items from anywhere with zero animation delay\n• Smart +20 Enhance Engine: Automated 0-loss enhancement with dynamic +7 threshold protection\n• SuperLoot Ore Vacuum: Instant-kill & ore sweep for rare golden chests across all stages" },
{ "2026-10-20", "Rejoin Pass & Ticket Dupe Loop Engine\n• Auto Rejoin Season Loop: Persistent server-hop & rejoin cycle without script drop\n• Instant Pass & Shop Harvester: Auto-claims Season Pass milestones and exchanges 800 SC Tickets, 1,000 SC Race Rolls & 1,500 SC Protect Scrolls\n• Stock Quota Sweeper: Restock mode sweeps full store quota on every join\n• Rapid Coin Spawner: Instant 200,000 SC top-up integration via Tower packets\n• Live Teleport Watchdog: Resilient auto-retry on server full or teleport failure" },
},
RejoinSeasonFlag = "rejoin_season.json",
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
ReloadSource = [[
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.5)
local loaded = false
if isfile and readfile then
for _, localPath in ipairs({ "Loot To Forge.lua", "MarioHubScript/Loot To Forge/Loot To Forge.lua" }) do
if isfile(localPath) then
local code = readfile(localPath)
if code and #code > 1000 then
local fn = loadstring(code)
if fn then fn(); loaded = true; break end
end
end
end
end
if not loaded then
local url = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/loader.lua"
local ok, body = pcall(game.HttpGet, game, url)
if not (ok and type(body) == "string") then
local requester = request or http_request or (syn and syn.request) or (http and http.request)
local sent, reply = pcall(requester, { Url = url, Method = "GET" })
body = sent and type(reply) == "table" and reply.Body
end
if type(body) == "string" then loadstring(body)() end
end]],
LoadTimeout = 30,
RemoteTimeout = 20,
RequireTimeout = 3,
MaxFailures = 5,
FailWindow = 10,
AlertTries = 20,
AlertDelay = 0.5,
TickDelay = 0.15,
StatusInterval = 1.5,
PumpInterval = 0.2,
OwnedOresLabel = "Owned ores",
AcquireRounds = 5,
StoneWorkers = 16,
StoneCallsPerWorker = 25,
EggFarmWorkers = 16,
EggFarmCalls = 25,
TurboFarmWorkers = 24,
TurboFarmCalls = 35,
TurboBurstCount = 10000,
PetInterval = 0.5,
PetDeployInterval = 15,
TowerWorkers = 16,
CoinFarmTimeout = 600,
TowerCallsPerWorker = 15,
GearForgeTries = 15,
GearEnhanceTries = 2,
GearEnhanceWorkers = 8,
SlotEnhanceRounds = 200,
ClickInterval = 0.08,
ForgeTargets = {
{ name = "Great Weapon", forgeType = "Weapon", ores = 13 },
{ name = "Katana", forgeType = "Weapon", ores = 4 },
{ name = "Armor", forgeType = "Armor", ores = 11 },
{ name = "Hat", forgeType = "Armor", ores = 4 },
},
GearSlots = {
{ slot = "Weapon", forgeType = "Weapon", ores = 13 },
{ slot = "Armor", forgeType = "Armor", ores = 11 },
{ slot = "Hat", forgeType = "Armor", ores = 4 },
},
GearTypes = { "Weapon", "Armor", "Hat" },
EnchantPriority = { "Poison_3", "Thunder_3", "Ice_3", "Fire_3", "Poison_2", "Thunder_2", "Ice_2", "Fire_2" },
RuneMinTier = 2,
EnchantRefill = 50,
ForgeCountMax = 30,
PlanSlice = 0.004,
HuntBatch = 40,
HuntWorkers = 4,
HuntMaxForges = 4000,
HuntTargetHits = 3,
IndexInterval = 60,
IndexLevelClaims = 50,
ClaimIdScan = 20,
LookKinds = { "Ore", "EnchStone", "Weapon", "Armor", "Material", "Class", "Pet", "Egg", "Food" },
TokenShopInterval = 60,
ClaimInterval = 30,
SeasonInterval = 60,
BossCards = 8,
BossAttackIds = { Katana = "K_ATK_1", Great = "G_ATK_1" },
BossHitsPerTick = 30,
BossHitGap = 0.02,
BossJoinSettle = 1,
BossClaimDelay = 3.5,
BossStandHeight = 3,
BossStandBack = 8,
BossReach = 25,
UpgradeInterval = 5,
EquipInterval = 3,
SellInterval = 1,
RebirthInterval = 2,
BossInterval = 1,
BossHopInterval = 5,
BossHopAfter = 8,
BossLootTimeout = 30,
BossHopFlag = "bosshop.txt",
BossHopResume = 180,
BossHopServers = "bossservers.json",
HopListTtl = 120,
HopBackoffStart = 5,
HopBackoffMax = 60,
HopGiveUp = 8,
HopStall = 30,
HopGap = 15,
OreStages = {
Ore_1 = "Stage_1", Ore_2 = "Stage_1", Ore_3 = "Stage_1",
Ore_4 = "Stage_3", Ore_5 = "Stage_3", Ore_6 = "Stage_3",
Ore_7 = "Stage_5", Ore_8 = "Stage_5", Ore_9 = "Stage_5",
Ore_10 = "Stage_7", Ore_11 = "Stage_7", Ore_12 = "Stage_7", Ore_13 = "Stage_7",
Ore_14 = "Stage_10", Ore_15 = "Stage_10", Ore_16 = "Stage_10", Ore_17 = "Stage_10", Ore_18 = "Stage_10", Ore_19 = "Stage_10",
Ore_20 = "Stage_13", Ore_21 = "Stage_13", Ore_22 = "Stage_13", Ore_23 = "Stage_13", Ore_24 = "Stage_13", Ore_25 = "Stage_13",
Ore_26 = "Stage_16", Ore_27 = "Stage_16", Ore_28 = "Stage_16", Ore_29 = "Stage_16", Ore_30 = "Stage_16", Ore_31 = "Stage_16",
Ore_32 = "Stage_22", Ore_33 = "Stage_22", Ore_34 = "Stage_22", Ore_35 = "Stage_22", Ore_36 = "Stage_22", Ore_37 = "Stage_22", Ore_38 = "Stage_22", Ore_39 = "Stage_22",
Ore_40 = "Stage_27", Ore_41 = "Stage_27", Ore_42 = "Stage_27", Ore_43 = "Stage_27", Ore_44 = "Stage_27", Ore_45 = "Stage_27", Ore_46 = "Stage_27", Ore_47 = "Stage_27", Ore_48 = "Stage_27",
Food_1 = "Stage_10", Food_2 = "Stage_11", Food_3 = "Stage_13",
Food_4 = "Stage_15", Food_5 = "Stage_27", Food_6 = "Stage_27",
Egg1 = "Stage_11", Egg2 = "Stage_27",
},
TrainRejoinDelay = 0.3,
TrainWatchdog = 3,
TrainAcceptWait = 1.5,
TrainExitTries = 3,
TrainSettle = 0.5,
WarnCooldown = 30,
WarnMemory = 64,
KillAuraInterval = 0.12,
KillDamage = 1e30,
RaceRollDelay = 0.15,
RaceResultWait = 2,
RaceProtectRarity = "Mythic",
RaceSlots = { "Equipped", "Slot 1", "Slot 2", "Slot 3" },
RejoinDelay = 5,
CodeReplyWait = 1.5,
Codes = { "HALLOWEEN", "PET", "100000CCU", "50000CCU", "30000CCU", "20000CCU" },
Needs = {
AutoBattle = { "Utils.CommunicationUtils", "CTRL.EnemyCTRL", "Config.Stage.Helper" },
AutoCheckIn = { "LocalData.PlanKData", "Remote.PlanKing_Server.TryClaimRE", "Config.PlanK.Config" },
AutoTokenShop = { "Config.TokenShop.Config", "Remote.TokenShop_Server.OpenGoodsRE", "Remote.TokenShop_Server.ExchangeGoodsRF" },
KillAura = { "Utils.CommunicationUtils" },
CollectOre = { "Remote.Stage_Server.StageFinishedRF", "Remote.Stage_Server.GetOreRF", "Remote.Stage_Server.ClaimedAllOreRE", "Config.Stage.Helper", "Config.Ore.Config" },
SuperLootAura = { "Remote.SuperLoot_Server.KillSuperLootRE", "Remote.SuperLoot_Server.RefreshSuperLootRE", "Remote.Stage_Server.GetOreRF" },
AutoWorldBoss = { "Remote.WorldBoss_Server.IntoWorldBossFightRE", "Remote.WorldBoss_Server.BossDeadRE", "Remote.Attack_Server.UseAnyATKRE", "Remote.Attack_Server.AttackEnemyServiceRE" },
AutoIndex = { "Remote.Forge_Server.ForgeRF", "Remote.Index_Server.TryClaimIndexExpRF", "Utils.ForgeUtils", "Config.Weapon.Config", "Config.Armor.Config" },
MaxGear = { "Utils.BalanceUtils", "Remote.Forge_Server.ForgeRF", "Remote.Backpack_Server.EnhantEquipmentRF", "Remote.Backpack_Server.EnchantRE", "Config.Enhant.Config", "Config.EnchStone.Show" },
AutoEquip = { "Utils.BalanceUtils", "Remote.Backpack_Server.TryEquipItemRE", "Config.Weapon.Helper", "Config.Armor.Helper" },
AutoForge = { "Remote.Forge_Server.ForgeRF", "Remote.Backpack_Server.TrySellItemRE", "Config.Ore.Config" },
AutoSell = { "Remote.Backpack_Server.TrySellItemRE", "Config.Weapon.Config", "Config.Armor.Config" },
AutoTrain = { "Remote.Train_Server.IntoAutoTrainRE", "Config.TrainArea.Config" },
AutoRebirth = { "Remote.Rebirth_Server.TryRebirthRE", "Config.Rebirth.Helper" },
AutoUpgrade = { "Remote.Upgrade_Server.UpgradeOnceRE", "Config.Upgrade.Config" },
AutoTower = { "Remote.Dungeon_Server.TryIntoDungeonRF", "Remote.Dungeon_Server.StartRoundRE", "Remote.Dungeon_Server.CompleteRoundRF", "Config.Dungeon.Config" },
AutoSeasonCoins = { "Remote.Dungeon_Server.TryIntoDungeonRF", "Remote.Dungeon_Server.StartRoundRE", "Remote.Dungeon_Server.CompleteRoundRF", "Config.Dungeon.Config" },
RaceBuyRolls = { "Config.Season.GoodsConfig", "Remote.Season_Server.ExchangeGoodsRE", "LocalData.ClassData" },
AutoSeason = { "Remote.Season_Server.TryClaimDailyTicRE", "Remote.Season_Server.ExchangeGoodsRE", "Remote.Season_Server.LuckRE", "Config.Season.GoodsConfig" },
AutoRejoinSeason = { "Remote.Season_Server.TryClaimDailyTicRE", "Remote.Season_Server.TryClaimAllRewardRE", "Remote.Season_Server.ExchangeGoodsRE", "Config.Season.GoodsConfig" },
AutoClaim = { "Remote.Offline_Server.TryClaimOfflineRewardRE", "Remote.Online_Server.TryClaimRE" },
AutoRace = { "Remote.Class_Server.LuckOnceRE", "Config.Class.Config" },
AutoBestRace = { "Remote.Class_Server.ChangeEquipedIndexRE", "Config.Class.Config" },
AutoHatchEgg = { "Remote.Pet_Server.TryHatchEggRE", "Remote.Pet_Server.TryOpenEggRE", "Config.Egg.Config" },
AutoEquipPet = { "Remote.Pet_Server.IsEquipPetRE", "Utils.BalanceUtils", "Config.Pet.Config" },
AutoFeedPet = { "Remote.Pet_Server.FeedPetRE", "Config.Pet.Helper", "Config.Food.Config" },
AutoDeployPet = { "Remote.Pet_Server.IsDeployPetRE", "Remote.Pet_Server.ClaimAllDeployRewardRE", "Config.Pet.Config" },
AutoSellPet = { "Remote.Pet_Server.DeleteRE", "Config.Pet.Config", "Config.Egg.Config" },
AutoGradeUpPet = { "Remote.Pet_Server.TryUpGradePetRF" },
AutoRainbowPet = { "Remote.Pet_Server.TryUpGradePetRF", "Remote.Season_Server.LuckPetRF" },
KeepOre = { "Remote.Stage_Server.LostAllOreRF" },
},
KaitunToggles = { "MaxGear", "AutoEquip", "AutoForge", "AutoSell", "AutoTrain", "AutoRebirth", "AutoUpgrade", "AutoClaim", "AutoCheckIn", "AutoSeason", "KillAura", "SuperLootAura", "AutoWorldBoss", "AutoTower", "GodMode", "AutoBestRace", "AutoHatchEgg", "AutoEquipPet", "AutoFeedPet", "AutoDeployPet", "AutoGradeUpPet", "AutoRainbowPet" },
}
local Config = Reicht.Config
local Remote = ReplicatedStorage:WaitForChild("Remote", Config.LoadTimeout)
local GameConfig = ReplicatedStorage:WaitForChild("Config", Config.LoadTimeout)
Reicht.State = {
Alive = true,
Busy = false,
Rolling = false,
SavedSpot = nil,
Rejoining = false,
RejoinCountdown = 0,
RejoinLoopRunning = false,
Lock = nil,
LockOwner = nil,
LockTime = 0,
Profile = nil,
ProfileTime = 0,
ProfileCacheTtl = 0.35,
Failures = {},
Halted = {},
InTower = false,
Entering = false,
GearForged = false,
TrainArea = nil,
TrainPending = nil,
TrainEntering = false,
TrainGen = 0,
TrainFiredAt = 0,
TrainRebirth = nil,
BossReturn = nil,
TrainLevel = nil,
TrainNilSince = nil,
TrainUUIDs = {},
Warned = {},
WarnedCount = 0,
LastRun = {},
RemoteCache = {},
JobRunning = {},
WorkerBatches = {},
ChildThreads = {},
JobGroups = {},
JobStats = {},
ScheduleCursor = 0,
LootPending = {},
LootQueue = {},
LootSeen = {},
GearNote = nil,
IndexNote = nil,
TowerLoot = 0,
OreLabels = {},
GearLabels = {},
SpawnLabels = {},
BossHopping = false,
HopFails = 0,
HopBackoff = nil,
HopBlockedUntil = 0,
HopQueued = false,
BossDone = nil,
MissingLabels = {},
OreStage = {},
Plans = {},
Runes = nil,
Conns = {},
AuraCursor = 0,
ClickThread = nil,
AuraThread = nil,
Opt = {
MaxGear = false,
AutoEquip = false,
EnhanceTarget = 20,
GearForge = true,
GearEnchant = true,
GearEnhance = true,
EnchantPriority = {},
EnhanceSlot = "Weapon",
ForgeSellJunk = false,
ForgePerTick = 10,
BossCards = true,
SeasonSpin = true,
SeasonSpinBatch = 10,
SeasonGoods = { ["4"] = true, ["5"] = true, ["7"] = true },
AutoBestRace = false,
GodMode = false,
KeepOre = false,
BaitShield = true,
GuaranteedCrit = false,
DamageMultiplier = 5,
CollectOre = false,
Stage = "Stage_27",
CollectRarities = {},
KillAura = false,
AutoBattle = false,
AutoCheckIn = false,
TokenReveal = true,
TokenTargets = {},
TokenSkipOwned = true,
AuraMapWide = true,
AuraRange = 0,
AuraBatch = 60,
AuraBurst = 10,
AuraInterval = 0.12,
AuraDamage = 1e30,
AuraCritical = true,
AuraSuper = true,
AuraTarget = "All",
AutoCollectDrops = true,
AutoSkills = false,
JobTimeout = 60,
WorkerLimit = 16,
ParallelJobs = 4,
SuperLootAura = false,
AutoWorldBoss = false,
BossHop = false,
BossWaitMinutes = 2.5,
AutoForge = false,
ForgeTarget = "Great Weapon",
ForgeOre = nil,
ForgeRarities = {},
KeepPerOre = 0,
BestOreFirst = false,
AutoSell = false,
SellTypes = { Weapon = true, Armor = true, Hat = true },
SellRarities = {},
KeepPerItem = 1,
AutoIndex = false,
IndexTypes = { Weapon = true, Armor = true, Hat = true },
MissingItem = nil,
AutoTrain = false,
TrainArea = "Auto Best",
AutoClick = false,
ClickTurbo = true,
HyperTrain = false,
GodTrain = false,
InstantKillAll = false,
AutoRebirth = false,
AutoUpgrade = false,
Upgrades = {},
AutoClaim = false,
AutoSeason = false,
AutoRejoinSeason = false,
RejoinClaimPass = true,
RejoinDelay = 3,
RejoinMode = "Same",
RejoinBuyTickets = true,
RejoinBuyRaceRoll = true,
RejoinBuyProtect = true,
RejoinRestock = true,
RejoinSpinWheel = true,
RejoinAutoFarmCoins = true,
AutoTokenShop = false,
AutoTower = false,
AutoSeasonCoins = false,
SeasonCoinTarget = 200000,
AutoRace = false,
RaceTargets = {},
RaceMinLevel = nil,
RaceStar = 0,
RaceSlot = "Equipped",
RaceLock = false,
RaceProtect = false,
RaceBuyRolls = true,
RaceAnim = false,
AutoHatchEgg = false,
TargetPet = nil,
TargetPetCopies = 1,
AutoChaseTargetPet = false,
AutoLockTargetPet = true,
HatchBestFirst = true,
SkipEggAnim = true,
AutoEquipPet = false,
AutoFeedPet = false,
AutoDeployPet = false,
AutoSellPet = false,
AutoGradeUpPet = false,
AutoRainbowPet = false,
DeletePetRarities = { Common = true, UnCommon = true, Rare = true },
KeepBestPets = 6,
AutoDeleteEggs = false,
KeepPerEgg = 10,
EggFarmRounds = 10,
CoinTarget = 50000,
SpawnItem = nil,
SpawnAmount = 1000,
TurboSpawn = false,
TurboBurst = 10000,
PotionAmount = 1000,
GearSlot = "Weapon",
SpawnGear = nil,
GearCopies = 1,
SpeedOn = false,
WalkSpeed = 60,
InfJump = false,
FlyOn = false,
FlySpeed = 60,
Noclip = false,
AutoRejoin = false,
LowGraphics = false,
AntiStun = false,
NoSkillCD = false,
AntiDebuff = false,
},
}
local State = Reicht.State
Reicht.GameLib = { Loaded = {}, Failed = {}, Apis = {}, Deferred = {} }
function Reicht.GameLib.RequireAsGame(module)
local done, ok, loaded = false, false, nil
local thread = Reicht.Util.Child(function()
pcall(setthreadidentity, 2)
local read, identity = pcall(getthreadidentity)
if read and identity == 2 then
ok, loaded = pcall(require, module)
end
done = true
end)
local deadline = os.clock() + Config.RequireTimeout
while not done and os.clock() < deadline do
task.wait()
end
if not done then
pcall(task.cancel, thread)
return false, "module require timed out"
end
return ok, loaded
end
function Reicht.GameLib.Require(module)
local cached = Reicht.GameLib.Loaded[module]
if cached ~= nil or Reicht.GameLib.Failed[module] then return cached end
local result
local thread = Reicht.Util.Child(function() result = table.pack(pcall(require, module)) end)
local deadline = os.clock() + Config.RequireTimeout
while not result and os.clock() < deadline do task.wait() end
if not result then
pcall(task.cancel, thread)
result = { false, "module require timed out" }
end
local ok, loaded = result[1], result[2]
if not ok then
local firstErr = loaded
ok, loaded = Reicht.GameLib.RequireAsGame(module)
if not ok then
Reicht.GameLib.Failed[module] = tostring(firstErr)
warn("[LootToForge] require", module:GetFullName(), firstErr)
return nil
end
end
Reicht.GameLib.Loaded[module] = loaded
return loaded
end
function Reicht.GameLib.CallAsGame(fn, ...)
local args = table.pack(...)
local box
local thread = Reicht.Util.Child(function()
pcall(setthreadidentity, 2)
box = table.pack(pcall(fn, table.unpack(args, 1, args.n)))
end)
local deadline = os.clock() + Config.RequireTimeout
while not box and os.clock() < deadline do
task.wait()
end
if not box then
pcall(task.cancel, thread)
return false, "game call timed out"
end
return table.unpack(box, 1, box.n)
end
function Reicht.GameLib.Call(fn, ...)
if not Reicht.GameLib.Deferred[fn] then
local result = table.pack(pcall(fn, ...))
if result[1] or not tostring(result[2]):find("non-RobloxScript", 1, true) then
if not result[1] then error(result[2], 0) end
return table.unpack(result, 2, result.n)
end
Reicht.GameLib.Deferred[fn] = true
end
local result = table.pack(Reicht.GameLib.CallAsGame(fn, ...))
if not result[1] then error(result[2], 0) end
return table.unpack(result, 2, result.n)
end
function Reicht.GameLib.Api(module)
local api = Reicht.GameLib.Apis[module]
if api then return api end
local loaded = Reicht.GameLib.Need(module)
api = setmetatable({}, {
__index = function(self, key)
local value = loaded[key]
if type(value) ~= "function" then return value end
local wrapped = function(...)
return Reicht.GameLib.Call(value, ...)
end
rawset(self, key, wrapped)
return wrapped
end,
})
Reicht.GameLib.Apis[module] = api
return api
end
function Reicht.GameLib.Need(module)
local loaded = Reicht.GameLib.Require(module)
if loaded == nil then
error(("game data %s.%s can't be read on this executor"):format(module.Parent.Name, module.Name), 0)
end
return loaded
end
function Reicht.GameLib.Find(path)
local node = ReplicatedStorage
for part in path:gmatch("[^%.]+") do
node = node and node:FindFirstChild(part)
end
if node then return node end
local folder, name = path:match("^Remote%.([^%.]+)%.([^%.]+)$")
return folder and Reicht.Util.FindRemote(folder, name)
end
function Reicht.GameLib.Missing()
local missing = {}
for idx, paths in pairs(Config.Needs) do
for _, path in ipairs(paths) do
if not Reicht.GameLib.Find(path) then
missing[idx] = missing[idx] or {}
table.insert(missing[idx], path)
end
end
end
return missing
end
for _, name in ipairs({ "Util", "Data", "Stage", "Ore", "Spawn", "Potion", "Forge", "Sell", "Gear", "Index", "Level", "Upgrade", "Tower", "Boss", "Season", "Claim", "TokenShop", "Look", "SuperLoot", "Combat", "Guard", "Race", "Pet", "Movement", "Session", "Scheduler" }) do
Reicht[name] = {}
end
function Reicht.Util.FindRemote(folder, name)
if not Remote then return nil end
local key = folder .. "." .. name
local cached = State.RemoteCache[key]
if cached and cached:IsDescendantOf(Remote) then return cached end
State.RemoteCache[key] = nil
local directFolder = Remote:FindFirstChild(folder .. "_Server") or Remote:FindFirstChild(folder)
if directFolder then
local remote = directFolder:FindFirstChild(name)
if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
State.RemoteCache[key] = remote
return remote
end
end
for _, descendant in ipairs(Remote:GetDescendants()) do
if descendant.Name == name and (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction")) then
local parentName = descendant.Parent and descendant.Parent.Name or ""
if parentName:find("^" .. folder) then
State.RemoteCache[key] = descendant
return descendant
end
end
end
for _, descendant in ipairs(Remote:GetDescendants()) do
if descendant.Name == name and (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction")) then
State.RemoteCache[key] = descendant
return descendant
end
end
return nil
end
function Reicht.Util.Remote(folder, name)
local remote = Reicht.Util.FindRemote(folder, name)
if remote then return remote end
local holder = Remote and (Remote:FindFirstChild(folder .. "_Server") or Remote:WaitForChild(folder, Config.RemoteTimeout))
remote = holder and holder:WaitForChild(name, Config.RemoteTimeout) or Reicht.Util.FindRemote(folder, name)
if not remote then error(("remote %s.%s not found"):format(folder, name), 0) end
return remote
end
function Reicht.Util.HttpGet(url)
local ok, body = pcall(function() return game:HttpGet(url) end)
if ok and type(body) == "string" then return body end
local send = request or http_request or (syn and syn.request) or (http and http.request)
if not send then return nil, tostring(body) end
local sent, response = pcall(send, { Url = url, Method = "GET" })
if not sent then return nil, tostring(response) end
if type(response) ~= "table" or response.StatusCode ~= 200 or type(response.Body) ~= "string" then
return nil, "HTTP " .. tostring(type(response) == "table" and response.StatusCode)
end
return response.Body
end
function Reicht.Util.Alert(text, detail)
warn("[LootToForge] menu:", text, detail or "")
task.spawn(function()
for _ = 1, Config.AlertTries do
local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 })
if shown then return end
task.wait(Config.AlertDelay)
end
end)
end
function Reicht.Util.LoadLibrary()
local body, err = Reicht.Util.HttpGet(Config.UiSource)
if not body or not body:sub(-64):find("return Library%s*$") then
Reicht.Util.Alert("Could not download the menu. Check your connection and run it again.", err or "truncated body")
return nil
end
local chunk, compileErr = loadstring(body)
if not chunk then
Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(compileErr))
return nil
end
local ok, library = pcall(chunk)
if not ok or type(library) ~= "table" then
Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(library))
return nil
end
return library
end
function Reicht.Util.WarnJob(key, err)
local stamp = key .. tostring(err):match("[^\n]*")
local now = os.clock()
if now - (State.Warned[stamp] or -Config.WarnCooldown) < Config.WarnCooldown then return end
if not State.Warned[stamp] then
State.WarnedCount += 1
if State.WarnedCount > Config.WarnMemory then
table.clear(State.Warned)
State.WarnedCount = 1
end
end
State.Warned[stamp] = now
warn("[LootToForge]", key, err)
end
function Reicht.Util.Try(fn, ...)
local ok, err = pcall(fn, ...)
if not ok then
warn("[LootToForge]", err)
end
return ok, err
end
function Reicht.Util.Tier(id)
return tonumber(tostring(id):match("%d+")) or 0
end
function Reicht.Util.Abbreviate(number)
local units = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp" }
local index = 1
while number >= 1000 and index < #units do
number /= 1000
index += 1
end
return (index == 1 and "%d%s" or "%.2f%s"):format(number, units[index])
end
function Reicht.Util.HighestKey(configTable)
local bestKey, bestTier = nil, -1
for key in pairs(configTable) do
local tier = Reicht.Util.Tier(key)
if tier > bestTier then
bestKey, bestTier = key, tier
end
end
return bestKey
end
function Reicht.Util.Child(fn)
local owner = coroutine.running()
local children = State.ChildThreads[owner]
if not children then
children = {}
State.ChildThreads[owner] = children
end
local thread
thread = task.defer(function()
fn()
children[thread] = nil
if next(children) == nil then State.ChildThreads[owner] = nil end
end)
children[thread] = true
return thread
end
function Reicht.Util.CancelTree(thread)
if not thread then return end
for child in pairs(State.ChildThreads[thread] or {}) do
Reicht.Util.CancelTree(child)
end
State.ChildThreads[thread] = nil
for _, worker in ipairs(State.WorkerBatches[thread] or {}) do
Reicht.Util.CancelTree(worker)
end
State.WorkerBatches[thread] = nil
if State.LockOwner == thread then
State.Lock = nil
State.LockOwner = nil
State.LockTime = 0
end
for uuid, owner in pairs(State.LootPending) do
if owner == thread then
State.LootPending[uuid] = nil
State.LootSeen[uuid] = nil
end
end
if coroutine.status(thread) ~= "dead" then
pcall(task.cancel, thread)
end
end
function Reicht.Util.WaitAll(workers, job)
workers = math.max(0, math.floor(workers))
local nextJob, pending, firstError = 0, workers, nil
local threads = {}
local owner = coroutine.running()
State.WorkerBatches[owner] = threads
for _ = 1, math.min(workers, math.clamp(State.Opt.WorkerLimit, 1, 32)) do
table.insert(threads, task.defer(function()
while State.Alive and nextJob < workers do
nextJob += 1
local ok, err = pcall(job)
if not ok then firstError = firstError or err end
pending -= 1
end
end))
end
local deadline = os.clock() + Config.RemoteTimeout * 2
while State.Alive and pending > 0 and os.clock() < deadline do
task.wait(0.05)
end
for _, thread in ipairs(threads) do
if coroutine.status(thread) ~= "dead" then pcall(task.cancel, thread) end
end
State.WorkerBatches[owner] = nil
if State.Alive and pending > 0 then error("worker batch timed out", 0) end
if firstError then error(firstError, 0) end
return pending == 0
end
function Reicht.Util.RarityNames()
local helper = Reicht.GameLib.Api(GameConfig.Rarity.Helper)
local names = {}
for level = 1, 20 do
local name = helper.GetRarityByLevel(level)
if not name then break end
table.insert(names, name)
end
return names
end
function Reicht.Util.AllSet(list)
local set = {}
for _, name in ipairs(list) do
set[name] = true
end
return set
end
function Reicht.Util.Exclusive(name, fn, ...)
local now = os.clock()
if State.Lock and State.LockTime and (now - State.LockTime > 12) then
State.Lock = nil
State.LockOwner = nil
end
if State.Lock then return false end
local owner = coroutine.running()
for key, thread in pairs(State.JobRunning) do
if thread ~= owner and not Reicht.Scheduler.Groups[key] then return false end
end
State.Lock = name
State.LockOwner = owner
State.LockTime = now
local result = table.pack(pcall(fn, ...))
if State.LockOwner == owner then
State.Lock = nil
State.LockOwner = nil
State.LockTime = 0
end
if not result[1] then error(result[2], 0) end
return true, table.unpack(result, 2, result.n)
end
function Reicht.Data.Get(force)
local now = os.clock()
if not force and State.Profile and (now - State.ProfileTime < State.ProfileCacheTtl) then
return State.Profile
end
local remote = Reicht.Util.Remote("Profile", "GetTotalDataRF")
local ok, profile = pcall(remote.InvokeServer, remote)
if not ok or type(profile) ~= "table" then
if State.Profile then return State.Profile end
error("profile unavailable; retry after loading", 0)
end
State.Profile = profile
State.ProfileTime = now
return State.Profile
end
function Reicht.Data.Count(profile, itemId)
local total = 0
for _, entry in pairs(profile.Backpack.have) do
if entry.ID == itemId then
total += entry.Number or 1
end
end
return total
end
function Reicht.Data.Uuid(profile, itemId)
for uuid, entry in pairs(profile.Backpack.have) do
if entry.ID == itemId and (entry.Number or 0) >= 1 then
return uuid
end
end
return nil
end
function Reicht.Data.Snapshot()
local seen = {}
for uuid in pairs(Reicht.Data.Get().Backpack.have) do
seen[uuid] = true
end
return seen
end
function Reicht.Data.NewGear(before)
local fresh = {}
for uuid, entry in pairs(Reicht.Data.Get(true).Backpack.have) do
if not before[uuid] and (entry.Type == "Weapon" or entry.Type == "Armor" or entry.Type == "Hat") then
fresh[uuid] = entry
end
end
return fresh
end
function Reicht.Ore.Rarity(oreId)
local oreConfig = Reicht.GameLib.Need(GameConfig.Ore.Config)[oreId]
return oreConfig and Reicht.GameLib.Api(GameConfig.Rarity.Helper).GetRarityByLevel(oreConfig.Rarity)
end
function Reicht.Ore.Owned(profile)
local ores = {}
for uuid, entry in pairs(profile.Backpack.have) do
if entry.Type == "Ore" and (entry.Number or 0) >= 1 then
table.insert(ores, {
uuid = uuid,
id = entry.ID,
tier = Reicht.Util.Tier(entry.ID),
number = math.floor(entry.Number),
rarity = Reicht.Ore.Rarity(entry.ID),
})
end
end
table.sort(ores, function(a, b) return a.tier > b.tier end)
return ores
end
function Reicht.Ore.Ids()
local ids = {}
for oreId in pairs(Reicht.GameLib.Need(GameConfig.Ore.Config)) do
table.insert(ids, oreId)
end
table.sort(ids, function(a, b) return Reicht.Util.Tier(a) > Reicht.Util.Tier(b) end)
return ids
end
function Reicht.Look.Item(itemId)
if itemId == "SeasonCoin" then
return "rbxassetid://96941478494876", "Common"
elseif itemId == "SeasonTicket" then
return "rbxassetid://112918037487414", "Legendary"
elseif itemId == "ClassRoll" then
return "rbxassetid://118598506198309", "Legendary"
end
for _, kind in ipairs(Config.LookKinds) do
local folder = GameConfig:FindFirstChild(kind)
local show = folder and folder:FindFirstChild("Show") and Reicht.GameLib.Require(folder.Show)
local entry = show and show[itemId]
if not entry then continue end
local config = folder:FindFirstChild("Config") and Reicht.GameLib.Require(folder.Config)
local info = config and config[itemId]
return entry.Image, info and info.Rarity
end
return nil, nil
end
function Reicht.Look.Color(rarity)
if rarity == nil then return nil end
State.RarityColors = State.RarityColors or {}
local cached = State.RarityColors[rarity]
if cached ~= nil then return cached or nil end
local helper = Reicht.GameLib.Api(GameConfig.Rarity.Helper)
local name = rarity
if type(rarity) == "number" then
local ok, byLevel = pcall(helper.GetRarityByLevel, rarity)
name = ok and byLevel or rarity
end
local probe = Instance.new("TextLabel")
pcall(helper.SetUIQiu, probe, name)
local gradient = probe:FindFirstChildWhichIsA("UIGradient")
local color = gradient and gradient.Color.Keypoints[1].Value
probe:Destroy()
State.RarityColors[rarity] = color or false
return color
end
function Reicht.Look.Maps(labels, idOf)
local images, colors = {}, {}
for _, label in ipairs(labels) do
local itemId = idOf(label)
if not itemId then continue end
local image, rarity = Reicht.Look.Item(itemId)
images[label] = image
colors[label] = Reicht.Look.Color(rarity)
end
return images, colors
end
function Reicht.Ore.Choices()
local oreShow = Reicht.GameLib.Need(GameConfig.Ore.Show)
local labels, idByLabel = {}, {}
for _, oreId in ipairs(Reicht.Ore.Ids()) do
local label = ("%s (%s)"):format(oreShow[oreId] and oreShow[oreId].DisplayName or oreId, Reicht.Ore.Rarity(oreId) or "?")
if idByLabel[label] then
label = ("%s #%d"):format(label, Reicht.Util.Tier(oreId))
end
idByLabel[label] = oreId
table.insert(labels, label)
end
State.OreLabels = idByLabel
return labels
end
function Reicht.Ore.ForgeChoices()
local labels = Reicht.Ore.Choices()
table.insert(labels, 1, Config.OwnedOresLabel)
return labels
end
function Reicht.Spawn.Amount(value)
value = tonumber(value)
if not value or value ~= value or value <= 0 or value == math.huge then error("Enter a finite positive amount", 0) end
return math.clamp(math.floor(value), 1, 1000000000)
end
function Reicht.Spawn.Choices()
local labels, ids = {}, {}
local runeShow = Reicht.GameLib.Need(GameConfig.EnchStone.Show)
local runeOrder = {
"Thunder_3", "Poison_3", "Ice_3", "Fire_3",
"Thunder_2", "Poison_2", "Ice_2", "Fire_2",
"Thunder_1", "Poison_1", "Ice_1", "Fire_1",
}
for _, id in ipairs(runeOrder) do
local displayName = runeShow and runeShow[id] and runeShow[id].DisplayName or id
local tierName = id:find("_3$") and "Tier 3" or (id:find("_2$") and "Tier 2" or "Tier 1")
local label = "Rune • " .. displayName .. " (" .. tierName .. ") [" .. id .. "]"
labels[#labels + 1] = label
ids[label] = { id = id, kind = "EnchStone" }
end
local eggFolder = GameConfig:FindFirstChild("Egg")
local eggShow = eggFolder and eggFolder:FindFirstChild("Show") and Reicht.GameLib.Require(eggFolder.Show)
local eggOrder = { "Event1", "Egg2", "Egg1" }
for _, id in ipairs(eggOrder) do
local name = eggShow and eggShow[id] and (eggShow[id].DisplayName or eggShow[id].Name) or id
local label = "Egg • " .. name .. " [" .. id .. "]"
labels[#labels + 1] = label
ids[label] = { id = id, kind = "Egg" }
end
local petFolder = GameConfig:FindFirstChild("Pet")
local petShow = petFolder and petFolder:FindFirstChild("Show") and Reicht.GameLib.Require(petFolder.Show)
local petOrder = {
"Event1_4", "Event1_3", "Event1_2", "Event1_1",
"Egg2_3", "Egg2_4", "Egg2_2", "Egg2_1",
"Egg1_3", "Egg1_4", "Egg1_2", "Egg1_1",
}
for _, id in ipairs(petOrder) do
local info = petShow and petShow[id]
local name = info and (info.DisplayName or info.Name) or id
local label = "Pet • " .. name .. " [" .. id .. "]"
labels[#labels + 1] = label
ids[label] = { id = id, kind = "Pet" }
end
local oreShow = Reicht.GameLib.Need(GameConfig.Ore.Show)
local oreIds = {}
for _, id in ipairs(Reicht.Ore.Ids()) do
table.insert(oreIds, id)
end
table.sort(oreIds, function(a, b) return Reicht.Util.Tier(a) > Reicht.Util.Tier(b) end)
for _, id in ipairs(oreIds) do
local displayName = oreShow[id] and oreShow[id].DisplayName or id
local label = "Ore • " .. displayName .. " [" .. id .. "]"
labels[#labels + 1] = label
ids[label] = { id = id, kind = "Ore" }
end
local foodShow = Reicht.GameLib.Need(GameConfig.Food.Show)
local foodOrder = { "Food_6", "Food_5", "Food_4", "Food_3", "Food_2", "Food_1" }
for _, id in ipairs(foodOrder) do
local name = foodShow and foodShow[id] and (foodShow[id].DisplayName or foodShow[id].Name) or id
local label = "Fruit • " .. name .. " [" .. id .. "]"
labels[#labels + 1] = label
ids[label] = { id = id, kind = "Food" }
end
State.SpawnLabels = ids
return labels
end
function Reicht.Spawn.Give(id, kind, amount)
amount = Reicht.Spawn.Amount(amount)
if kind == "Currency" or id == "SeasonCoin" or id == "SeasonTicket" or id == "ClassRoll" then
if id == "SeasonCoin" then
local gained = Reicht.Tower.FarmCoins(amount)
return gained > 0, gained, gained > 0 and ("Harvested %d Season Coins via Tower"):format(gained) or "Tower session timed out"
elseif id == "SeasonTicket" then
local dailyRE = Reicht.Util.Remote("Season", "TryClaimDailyTicRE")
if dailyRE then pcall(dailyRE.FireServer, dailyRE) end
local passRE = Reicht.Util.Remote("Season", "TryClaimAllRewardRE")
if passRE then pcall(passRE.FireServer, passRE) end
task.wait(0.2)
local sData = Reicht.Season.Current() or {}
local goodsCfg = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
local good = goodsCfg and goodsCfg["7"]
local stock = good and (good.Store or 5) or 5
local alreadyBought = sData and sData.Goods and sData.Goods["7"] or 0
local bought = 0
if alreadyBought < stock then
for _ = 1, math.min(stock - alreadyBought, amount) do
local coin = sData.Coin or sData.SeasonCoin or 0
if coin < 800 then Reicht.Tower.FarmCoins(1600) end
Reicht.Util.Remote("Season", "ExchangeGoodsRE"):FireServer("7")
bought += 1
task.wait(0.04)
end
end
local curTickets = (Reicht.Season.Current(Reicht.Data.Get(true)) or {}).SeasonTicket or 0
return true, curTickets, ("Claimed Daily/Pass; Current Tickets: %d (Shop: %d/%d)"):format(curTickets, alreadyBought + bought, stock)
elseif id == "ClassRoll" then
local sData = Reicht.Season.Current() or {}
local goodsCfg = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
local good = goodsCfg and goodsCfg["5"]
local stock = good and (good.Store or 5) or 5
local alreadyBought = sData and sData.Goods and sData.Goods["5"] or 0
local bought = 0
if alreadyBought < stock then
for _ = 1, math.min(stock - alreadyBought, amount) do
local coin = sData.Coin or sData.SeasonCoin or 0
if coin < 1000 then Reicht.Tower.FarmCoins(2000) end
Reicht.Util.Remote("Season", "ExchangeGoodsRE"):FireServer("5")
bought += 1
task.wait(0.04)
end
end
local classData = Reicht.Data.Get(true).Class or {}
local ownedRolls = classData.luckTimes or 0
return true, ownedRolls, ("You own %s Race Rolls! (Shop: %d/%d)"):format(Reicht.Util.Abbreviate(ownedRolls), alreadyBought + bought, stock)
end
end
if id == "Event1" or id:find("^Event1") or (kind == "Pet" and id:find("^Event1")) then
local count, msg = Reicht.Pet.FarmAndHatchTarget(id, amount)
return count > 0, count, msg
end
if kind == "EnchStone" or id:find("^[A-Z][a-z]+_[123]$") then
local floor = id:find("_3$") and 50 or (id:find("_2$") and 15 or 3)
if not Reicht.Tower.Enter() then return false, 0, "Could not enter Tower" end
local startRE = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local completeRF = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
local gained = 0
local deadline = os.clock() + 15
while os.clock() < deadline and gained < amount do
startRE:FireServer(floor)
task.wait(0.04)
local res = completeRF:InvokeServer(floor)
if type(res) == "table" then
for _, drop in ipairs(res) do
if drop.ID == id or (drop.Type == "EnchStone" and not id) then
gained = gained + (drop.Number or 1)
end
end
end
task.wait(0.04)
end
Reicht.Tower.Exit()
Reicht.Data.Get(true)
return gained > 0, gained, gained > 0 and ("Harvested %d %s via Tower"):format(gained, id) or "Rune not rolled in time"
end
if kind == "Egg" or kind == "Food" or kind == "Ore" then
local farmed = Reicht.Stage.FarmTurbo(id, kind, amount)
return farmed > 0, farmed, farmed > 0 and ("Turbo farmed %d into inventory"):format(farmed) or "Bag full or drop not rolled"
end
if kind == "Pet" then
local hatched, msg = Reicht.Pet.FarmAndHatchTarget(id, amount)
return hatched > 0, hatched, msg or (hatched > 0 and ("Hatched target pet x" .. hatched) or "Incubating target eggs")
end
return false, 0, "Select an item from the list"
end
function Reicht.Spawn.TurboStep()
local picked = State.SpawnLabels[State.Opt.SpawnItem]
if picked then
Reicht.Spawn.Give(picked.id, picked.kind, State.Opt.SpawnAmount or 1000)
else
Reicht.Stage.FarmEggsAndFood(15)
Reicht.Stage.FarmMaxOres(15)
end
end
function Reicht.Potion.Owned(profile)
local ids = {}
local config = Reicht.GameLib.Need(GameConfig.Potion.Config)
for id, count in pairs(profile.Potion or {}) do
if config[id] and type(count) == "number" and count > 0 then ids[#ids + 1] = id end
end
table.sort(ids)
return ids
end
function Reicht.Potion.Extend(amount)
amount = math.min(1000000, Reicht.Spawn.Amount(amount))
local config = Reicht.GameLib.Need(GameConfig.Potion.Config)
local changed = 0
for _, id in ipairs(Reicht.Potion.Owned(Reicht.Data.Get())) do
if not State.Alive then break end
local q = Reicht.Data.Get()
local buffId = config[id].BuffID
local before = (q.Buff or {})[buffId] or 0
local count = math.min(amount, math.floor(q.Potion[id] or 0))
if count > 0 then
Reicht.Util.Remote("Potion", "TryUsePotionRE"):FireServer(id, count)
task.wait(0.3)
if ((Reicht.Data.Get(true).Buff or {})[buffId] or 0) > before then changed += 1 end
end
end
return changed
end
function Reicht.Ore.Ensure(oreId, need)
local profile = Reicht.Data.Get()
local uuid = Reicht.Data.Uuid(profile, oreId)
if uuid and Reicht.Data.Count(profile, oreId) >= need then return uuid end
Reicht.Stage.FarmTurbo(oreId, "Ore", math.max(1, need - Reicht.Data.Count(profile, oreId)))
profile = Reicht.Data.Get(true)
return Reicht.Data.Uuid(profile, oreId)
end
function Reicht.Ore.Top(minimum)
local top = Reicht.Ore.Owned(Reicht.Data.Get())[1]
if not top or top.number < minimum then
Reicht.Stage.FarmMaxOres(3)
top = Reicht.Ore.Owned(Reicht.Data.Get(true))[1]
end
return top and top.number >= minimum and top or nil
end
function Reicht.Forge.Target()
for _, target in ipairs(Config.ForgeTargets) do
if target.name == State.Opt.ForgeTarget then
return target
end
end
return Config.ForgeTargets[1]
end
function Reicht.Forge.Run(forgeType, oreList)
local res = Reicht.Util.Remote("Forge", "ForgeRF"):InvokeServer({ ConfigType = forgeType, UUIDList = oreList })
Reicht.Data.Get(true)
return res
end
function Reicht.Forge.PickOwned(profile, count)
local opt = State.Opt
local candidates = {}
for _, ore in ipairs(Reicht.Ore.Owned(profile)) do
local spare = ore.number - opt.KeepPerOre
if opt.ForgeRarities[ore.rarity] and spare > 0 then
ore.spare = spare
table.insert(candidates, ore)
end
end
if not opt.BestOreFirst then
table.sort(candidates, function(a, b) return a.tier < b.tier end)
end
local pick, need = {}, count
for _, ore in ipairs(candidates) do
if need <= 0 then break end
local take = math.min(need, ore.spare)
pick[ore.uuid] = take
need -= take
end
return need <= 0 and pick or nil
end
function Reicht.Forge.Pick(count)
local oreId = State.OreLabels[State.Opt.ForgeOre]
if not oreId then
return Reicht.Forge.PickOwned(Reicht.Data.Get(), count)
end
local uuid = Reicht.Ore.Ensure(oreId, count * State.Opt.ForgePerTick)
return uuid and { [uuid] = count }
end
function Reicht.Forge.Once()
local target = Reicht.Forge.Target()
local pick = Reicht.Forge.Pick(target.ores)
return pick ~= nil and Reicht.Forge.Run(target.forgeType, pick) ~= nil
end
function Reicht.Forge.Burst()
local target = Reicht.Forge.Target()
local perTick = State.Opt.ForgePerTick
local pick = Reicht.Forge.Pick(target.ores * perTick)
if not pick then return end
local uuid = next(pick)
if next(pick, uuid) == nil then
for _ = 1, perTick do
Reicht.Forge.Run(target.forgeType, { [uuid] = target.ores })
end
return
end
for _ = 1, perTick do
if not Reicht.Forge.Once() then break end
end
end
function Reicht.Forge.BulkForge(targetCount)
targetCount = targetCount or 25
local forged = 0
for _ = 1, targetCount do
if not Reicht.Forge.Once() then break end
forged += 1
end
if State.Opt.ForgeSellJunk then
Reicht.Forge.SellWorse()
end
return forged
end
function Reicht.Forge.Step()
if not State.Opt.ForgeSellJunk then
Reicht.Forge.Burst()
return
end
local before = Reicht.Data.Snapshot()
Reicht.Forge.Burst()
local fresh = Reicht.Data.NewGear(before)
local profile = State.Profile
local keep = {}
for uuid, entry in pairs(fresh) do
local worn = profile.Backpack.equiped[entry.Type]
local wornEntry = worn and profile.Backpack.have[worn]
if not wornEntry or Reicht.Gear.Score(entry, true) > Reicht.Gear.Score(wornEntry, true) then
keep[uuid] = true
end
end
Reicht.Sell.Fresh(fresh, keep)
end
function Reicht.Sell.Rarity(entry)
local folder = entry.Type == "Weapon" and "Weapon" or "Armor"
local itemConfig = Reicht.GameLib.Need(GameConfig[folder].Config)[entry.ID]
return itemConfig and itemConfig.Rarity
end
function Reicht.Sell.Anchors(profile)
local anchors, bestPower = {}, {}
for uuid, entry in pairs(profile.Backpack.have) do
if not (entry.Type == "Weapon" or entry.Type == "Armor" or entry.Type == "Hat") then continue end
local helper = Reicht.GameLib.Api(entry.Type == "Weapon" and GameConfig.Weapon.Helper or GameConfig.Armor.Helper)
local ok, percent = pcall(helper.CheckIsBestPercent, entry.ID)
if not ok or percent then continue end
local powerOk, power = pcall(helper.GetMainAffix, entry.ID)
if powerOk and type(power) == "number" and power > (bestPower[entry.Type] or 0) then
bestPower[entry.Type] = power
anchors[entry.Type] = uuid
end
end
local keep = {}
for _, uuid in pairs(anchors) do
keep[uuid] = true
end
local backpack = Reicht.GameLib.Require(ReplicatedStorage.LocalData.BackpackData)
if type(backpack) == "table" and type(backpack.IsLocked) == "function" then
for uuid in pairs(profile.Backpack.have) do
local ok, locked = pcall(backpack.IsLocked, uuid)
if ok and locked then keep[uuid] = true end
end
end
return keep
end
function Reicht.Sell.Run(profile)
local opt = State.Opt
local equipped = Reicht.Sell.Anchors(profile)
for _, uuid in pairs(profile.Backpack.equiped) do
equipped[uuid] = true
end
local byId = {}
for uuid, entry in pairs(profile.Backpack.have) do
if opt.SellTypes[entry.Type] and not equipped[uuid] then
byId[entry.ID] = byId[entry.ID] or {}
table.insert(byId[entry.ID], { uuid = uuid, entry = entry })
end
end
local sell = Reicht.Util.Remote("Backpack", "TrySellItemRE")
for _, items in pairs(byId) do
table.sort(items, function(a, b) return (a.entry.Level or 0) > (b.entry.Level or 0) end)
for index, gear in ipairs(items) do
if index > opt.KeepPerItem and opt.SellRarities[Reicht.Sell.Rarity(gear.entry)] then
sell:FireServer(gear.uuid, 1)
end
end
end
Reicht.Data.Get(true)
end
function Reicht.Sell.Fresh(fresh, keep)
local equipped = Reicht.Sell.Anchors(State.Profile)
for _, uuid in pairs(State.Profile.Backpack.equiped) do
equipped[uuid] = true
end
local sell = Reicht.Util.Remote("Backpack", "TrySellItemRE")
for uuid in pairs(fresh) do
if not equipped[uuid] and not (keep and keep[uuid]) then
sell:FireServer(uuid, 1)
end
end
Reicht.Data.Get(true)
end
function Reicht.Sell.All()
local sellAll = Reicht.Util.FindRemote("Backpack", "TrySellAllRE")
if sellAll then
sellAll:FireServer()
task.wait(0.2)
Reicht.Data.Get(true)
return true
end
return false
end
function Reicht.Gear.Score(entry, atTarget)
local balance = Reicht.GameLib.Api(ReplicatedStorage.Utils.BalanceUtils)
local backpack = Reicht.Data.Get().Backpack
local potential = table.clone(entry)
if atTarget then potential.Level = math.max(entry.Level or 0, State.Opt.EnhanceTarget) end
local value = entry.Type == "Weapon" and balance.GetWeaponTrainValue or balance.GetArmorValue
local ok, power = pcall(value, LocalPlayer, potential, backpack)
if not ok or type(power) ~= "number" then return 0 end
return power * (1 + (entry.Level or 0) * 1e-6 + #(entry.EnchanceList or {}) * 1e-9)
end
function Reicht.Gear.BestOwned(profile, slot, atTarget)
local bestUuid, bestScore = nil, -1
for uuid, entry in pairs(profile.Backpack.have) do
if entry.Type == slot then
local score = Reicht.Gear.Score(entry, atTarget)
if score > bestScore then
bestUuid, bestScore = uuid, score
end
end
end
return bestUuid, bestScore
end
function Reicht.Gear.EquipBest()
local profile = Reicht.Data.Get()
local equip = Reicht.Util.Remote("Backpack", "TryEquipItemRE")
local changed = 0
local atTarget = State.Opt.MaxGear and State.Opt.GearEnhance
for _, slot in ipairs(Config.GearTypes) do
local best, bestScore = Reicht.Gear.BestOwned(profile, slot, atTarget)
local current = profile.Backpack.equiped[slot]
local currentEntry = current and profile.Backpack.have[current]
if best and best ~= current and bestScore > (currentEntry and Reicht.Gear.Score(currentEntry, atTarget) or -1) then
equip:FireServer(best, slot)
changed += 1
end
end
if changed > 0 then Reicht.Data.Get(true) end
return changed
end
function Reicht.Gear.SwitchForm(slot)
slot = slot or "Weapon"
local profile = Reicht.Data.Get()
local uuid = profile.Backpack and profile.Backpack.equiped and profile.Backpack.equiped[slot]
if not uuid then return false, "No equipped " .. slot end
local item = profile.Backpack.have and profile.Backpack.have[uuid]
local cur = (item and item.Mutant) or "A"
local nextMutant = cur == "A" and "B" or "A"
local rem = Reicht.Util.FindRemote("Backpack", "ChangeEquipmentMutantRE")
if rem then
rem:FireServer(uuid, nextMutant)
else
local bp = Reicht.GameLib.Require(ReplicatedStorage.LocalData.BackpackData)
if bp and bp.ChangeEquipmentMutant then
bp.ChangeEquipmentMutant(uuid, nextMutant)
end
end
task.wait(0.15)
Reicht.Data.Get(true)
return true, nextMutant
end
function Reicht.Gear.RollSkillSlot2()
local rem = Reicht.Util.FindRemote("Backpack", "LuckSkillCell_2RE")
if not rem then return false, "LuckSkillCell_2RE unavailable" end
rem:FireServer()
task.wait(0.2)
Reicht.Data.Get(true)
local bpModule = Reicht.GameLib.Require(ReplicatedStorage.LocalData.BackpackData)
local weapon = bpModule and bpModule.GetItemDataByIndex and bpModule.GetItemDataByIndex("Weapon")
local skill2 = weapon and weapon.SkillList and weapon.SkillList[2]
return true, skill2 and skill2.ID or "Rolled"
end
function Reicht.Gear.ForgeBest()
local before = Reicht.Data.Snapshot()
for _, spec in ipairs(Config.GearSlots) do
local top = Reicht.Ore.Top(spec.ores * Config.GearForgeTries)
if top then
for _ = 1, Config.GearForgeTries do
Reicht.Forge.Run(spec.forgeType, { [top.uuid] = spec.ores })
end
end
local best = Reicht.Gear.BestOwned(Reicht.Data.Get(), spec.slot, true)
if best then
Reicht.Util.Remote("Backpack", "TryEquipItemRE"):FireServer(best, spec.slot)
end
end
task.wait(0.5)
Reicht.Sell.Fresh(Reicht.Data.NewGear(before))
end
function Reicht.Gear.MissingForEnhance(profile, level)
local cost = Reicht.GameLib.Need(GameConfig.Enhant.Config)[level + 1]
if not cost then return nil end
if Reicht.Data.Count(profile, "EnhantStone_2") < (cost.EnhantStone_2 or 0) then return "EnhantStone_2" end
if Reicht.Data.Count(profile, "EnhantStone_1") < (cost.EnhantStone_1 or 0) then return "EnhantStone_1" end
if profile.Eco.coin < (cost.NeedCoin or 0) then return "Coin" end
return nil
end
function Reicht.Gear.Gather(missing)
State.GearNote = missing
if missing == "Coin" then
Reicht.Forge.Step()
Reicht.Sell.Run(Reicht.Data.Get())
elseif missing == "EnhantStone_1" then
Reicht.Stage.FarmStones(Reicht.Stage.Best())
elseif not Reicht.Tower.FarmStep() then
State.GearNote = "NoTicket"
end
end
function Reicht.Gear.RuneOrder()
if State.Runes then return State.Runes end
local show = Reicht.GameLib.Find("Config.EnchStone.Show")
local stones = show and Reicht.GameLib.Require(show)
if not stones then return Config.EnchantPriority end
local known = {}
for index, stoneId in ipairs(Config.EnchantPriority) do
known[stoneId] = index
end
local runes = {}
for stoneId in pairs(stones) do
if Reicht.Util.Tier(stoneId) >= Config.RuneMinTier then runes[#runes + 1] = stoneId end
end
table.sort(runes, function(a, b)
local ta, tb = Reicht.Util.Tier(a), Reicht.Util.Tier(b)
if ta ~= tb then return ta > tb end
local ka, kb = known[a] or math.huge, known[b] or math.huge
if ka ~= kb then return ka < kb end
return a < b
end)
State.Runes = runes
return runes
end
function Reicht.Gear.Priority()
return #State.Opt.EnchantPriority > 0 and State.Opt.EnchantPriority or Reicht.Gear.RuneOrder()
end
function Reicht.Gear.Enchant(profile, uuid)
local entry = profile.Backpack.have[uuid]
local used = {}
for slot = 1, entry.EnchanceNum or 0 do
local current = entry.EnchanceList and entry.EnchanceList[slot]
local currentId = current and current.ID
local wanted
for _, stoneId in ipairs(Reicht.Gear.Priority()) do
if not used[stoneId] and (stoneId == currentId or Reicht.Data.Count(profile, stoneId) > 0) then
wanted = stoneId
break
end
end
if wanted and wanted ~= currentId then
used[wanted] = true
Reicht.Util.Remote("Backpack", "EnchantRE"):FireServer(uuid, slot, Reicht.Data.Uuid(profile, wanted))
task.wait(0.04)
end
end
end
function Reicht.Gear.Enhance(profile)
local target = math.min(State.Opt.EnhanceTarget, Reicht.Util.Tier(Reicht.Util.HighestKey(Reicht.GameLib.Need(GameConfig.Enhant.Config))))
local enhance = Reicht.Util.Remote("Backpack", "EnhantEquipmentRF")
for _, spec in ipairs(Config.GearSlots) do
local uuid = profile.Backpack.equiped[spec.slot]
local entry = uuid and profile.Backpack.have[uuid]
if entry and (entry.Level or 0) < target then
local missing = Reicht.Gear.MissingForEnhance(profile, entry.Level or 0)
if missing then
Reicht.Gear.Gather(missing)
return false
end
State.GearNote = "Enhancing"
local useProtect = Reicht.Data.Count(profile, "EnhantProtect") > 0 and (entry.Level or 0) >= Reicht.GameLib.Api(GameConfig.Enhant.Helper).GetFailLevel()
Reicht.Util.WaitAll(Config.GearEnhanceWorkers, function()
for _ = 1, Config.GearEnhanceTries do
if not enhance:InvokeServer(uuid, { UseProtect = useProtect }) then return end
end
end)
Reicht.Data.Get(true)
return false
end
end
return true
end
function Reicht.Gear.MaxStep()
local opt = State.Opt
if opt.GearForge and not State.GearForged then
Reicht.Gear.ForgeBest()
State.GearForged = true
end
if opt.GearEnchant then
local profile = Reicht.Data.Get()
for _, spec in ipairs(Config.GearSlots) do
local uuid = profile.Backpack.equiped[spec.slot]
if uuid then Reicht.Gear.Enchant(profile, uuid) end
end
end
if not opt.GearEnhance or Reicht.Gear.Enhance(Reicht.Data.Get()) then
State.GearNote = "Done"
end
end
function Reicht.Gear.EnhanceSlot(slot, target)
local enhance = Reicht.Util.Remote("Backpack", "EnhantEquipmentRF")
local failLevel = Reicht.GameLib.Api(GameConfig.Enhant.Helper).GetFailLevel()
local level = 0
for _ = 1, Config.SlotEnhanceRounds do
local profile = Reicht.Data.Get()
local uuid = profile.Backpack.equiped[slot]
local entry = uuid and profile.Backpack.have[uuid]
if not entry then return nil end
level = entry.Level or 0
if level >= target then return level end
local missing = Reicht.Gear.MissingForEnhance(profile, level)
if missing == "EnhantStone_1" then
Reicht.Stage.FarmStones(Reicht.Stage.Best())
elseif missing then
return level
else
enhance:InvokeServer(uuid, { UseProtect = level >= failLevel and Reicht.Data.Count(profile, "EnhantProtect") > 0 })
end
end
Reicht.Data.Get(true)
return level
end
function Reicht.Gear.EnhanceToMax(targetLevel)
targetLevel = targetLevel or 20
local enhance = Reicht.Util.Remote("Backpack", "EnhantEquipmentRF")
local failLevel = Reicht.GameLib.Api(GameConfig.Enhant.Helper).GetFailLevel()
local count = 0
for _, spec in ipairs(Config.GearSlots) do
for _ = 1, 25 do
local profile = Reicht.Data.Get(true)
local uuid = profile and profile.Backpack and profile.Backpack.equiped and profile.Backpack.equiped[spec.slot]
local entry = uuid and profile.Backpack.have and profile.Backpack.have[uuid]
if not entry or (entry.Level or 0) >= targetLevel then break end
local currentLvl = entry.Level or 0
local protectAvailable = Reicht.Data.Count(profile, "EnhantProtect") > 0
local useProtect = currentLvl >= failLevel and protectAvailable
local ok = pcall(function()
return enhance:InvokeServer(uuid, { UseProtect = useProtect })
end)
if not ok then break end
count += 1
task.wait(0.04)
end
end
Reicht.Data.Get(true)
return count
end
function Reicht.Gear.EquippedNames(profile)
local names = {}
for _, spec in ipairs(Config.GearSlots) do
local uuid = profile.Backpack.equiped[spec.slot]
local entry = uuid and profile.Backpack.have[uuid]
if entry then
local shows = Reicht.GameLib.Require(GameConfig[entry.Type == "Weapon" and "Weapon" or "Armor"].Show)
local show = shows and shows[entry.ID]
table.insert(names, ("%s +%d"):format(show and show.DisplayName or entry.ID, entry.Level or 0))
end
end
return table.concat(names, " · ")
end
function Reicht.Index.GearCatalog()
local gear = {}
local armorHelper = Reicht.GameLib.Api(GameConfig.Armor.Helper)
for weaponId, weapon in pairs(Reicht.GameLib.Need(GameConfig.Weapon.Config)) do
table.insert(gear, { id = weaponId, slot = "Weapon", forgeType = "Weapon", forgeable = weapon.TLevel ~= nil })
end
for armorId, armor in pairs(Reicht.GameLib.Need(GameConfig.Armor.Config)) do
table.insert(gear, { id = armorId, slot = armorHelper.GetBigType(armorId) or "Armor", forgeType = "Armor", forgeable = armor.TLevel ~= nil })
end
return gear
end
function Reicht.Index.Missing()
local unlocked = Reicht.Data.Get().Index.unlocked
local missing = {}
for _, gear in ipairs(Reicht.Index.GearCatalog()) do
if State.Opt.IndexTypes[gear.slot] and not unlocked[gear.slot .. "-" .. gear.id] then
table.insert(missing, gear)
end
end
table.sort(missing, function(a, b)
if a.forgeable ~= b.forgeable then return a.forgeable end
return a.id < b.id
end)
return missing
end
function Reicht.Index.Plan(gear)
local cached = State.Plans[gear.id]
if cached then return cached[1], cached[2], cached[3] end
local forgeUtils = Reicht.GameLib.Api(ReplicatedStorage.Utils.ForgeUtils)
local helper = Reicht.GameLib.Api(gear.forgeType == "Weapon" and GameConfig.Weapon.Helper or GameConfig.Armor.Helper)
local bestChance, bestOre, bestCount = 0, nil, nil
local sliceStart = os.clock()
for count = 1, Config.ForgeCountMax do
local split = helper.GetForgePercentByNumber(count)
if not split then continue end
for _, oreId in ipairs(Reicht.Ore.Ids()) do
if os.clock() - sliceStart > Config.PlanSlice then
task.wait()
sliceStart = os.clock()
end
local list = { [oreId] = count }
local ok, chance = pcall(function()
local low, high = forgeUtils.GetForgeOreResult(list)
local power = forgeUtils.GetOreAvgPower(list)
local total = 0
for subType, share in pairs(split) do
if share > 0 then
total += share * (forgeUtils.GetEquPercent(gear.forgeType, count, low, high, power, subType)[gear.id] or 0)
end
end
return total
end)
if ok and chance > bestChance then
bestChance, bestOre, bestCount = chance, oreId, count
end
end
end
State.Plans[gear.id] = { bestChance, bestOre, bestCount }
return bestChance, bestOre, bestCount
end
function Reicht.Index.Label(gear)
local show = Reicht.GameLib.Need(GameConfig[gear.forgeType].Show)[gear.id]
local name = ("%s [%s]"):format(show and show.DisplayName or gear.id, gear.slot)
if not gear.forgeable then return name .. " - event" end
local chance = Reicht.Index.Plan(gear)
return chance > 0 and ("%s - %.2f%%"):format(name, chance * 100) or name .. " - no recipe"
end
function Reicht.Index.Choices()
local labels, byLabel = {}, {}
for _, gear in ipairs(Reicht.Index.Missing()) do
local label = Reicht.Index.Label(gear)
byLabel[label] = gear
table.insert(labels, label)
end
State.MissingLabels = byLabel
return labels
end
function Reicht.Index.Hunt(gear, copies)
local chance, oreId, count = Reicht.Index.Plan(gear)
if chance <= 0 then return false end
local budget = math.min(Config.HuntMaxForges * (copies or 1), math.ceil(Config.HuntTargetHits * (copies or 1) / chance))
local key = gear.slot .. "-" .. gear.id
local forged, got = 0, 0
while forged < budget and State.Alive do
local uuid = Reicht.Ore.Ensure(oreId, count * Config.HuntBatch)
if not uuid then return false end
local before = Reicht.Data.Snapshot()
local perWorker = math.ceil(Config.HuntBatch / Config.HuntWorkers)
Reicht.Util.WaitAll(Config.HuntWorkers, function()
for _ = 1, perWorker do
Reicht.Forge.Run(gear.forgeType, { [uuid] = count })
end
end)
forged += perWorker * Config.HuntWorkers
State.IndexNote = ("%s %d/%d"):format(gear.id, forged, budget)
local fresh = Reicht.Data.NewGear(before)
local keep = {}
for freshUuid, entry in pairs(fresh) do
if entry.ID == gear.id and (not copies or got < copies) then
keep[freshUuid] = true
got += 1
end
end
Reicht.Sell.Fresh(fresh, keep)
if copies then
State.IndexNote = ("%s %d/%d"):format(gear.id, got, copies)
if got >= copies then return true end
elseif State.Profile.Index.unlocked[key] or next(keep) then
return true
end
end
return false
end
function Reicht.Spawn.GearChoices(slot)
local labels, byLabel, list = {}, {}, {}
for _, gear in ipairs(Reicht.Index.GearCatalog()) do
if not gear.forgeable or gear.slot ~= slot then continue end
local helper = Reicht.GameLib.Api(gear.forgeType == "Weapon" and GameConfig.Weapon.Helper or GameConfig.Armor.Helper)
local ok, power = pcall(helper.GetMainAffix, gear.id)
table.insert(list, { gear, ok and tonumber(power) or 0 })
end
table.sort(list, function(a, b) return a[2] > b[2] end)
for _, pair in ipairs(list) do
local label = Reicht.Index.Label(pair[1])
byLabel[label] = pair[1]
table.insert(labels, label)
end
State.GearLabels = byLabel
return labels
end
function Reicht.Spawn.BestSet()
local made = 0
for _, slot in ipairs(Config.GearTypes) do
local best, bestPower = nil, -1
for _, gear in ipairs(Reicht.Index.GearCatalog()) do
if not gear.forgeable or gear.slot ~= slot then continue end
local helper = Reicht.GameLib.Api(gear.forgeType == "Weapon" and GameConfig.Weapon.Helper or GameConfig.Armor.Helper)
local ok, power = pcall(helper.GetMainAffix, gear.id)
power = ok and tonumber(power) or 0
if power > bestPower then best, bestPower = gear, power end
end
if best and Reicht.Index.Hunt(best, 1) then made += 1 end
end
task.wait(0.5)
Reicht.Gear.EquipBest()
return made
end
function Reicht.Spawn.FullGodSet()
local made = Reicht.Spawn.BestSet()
Reicht.Stage.FarmStones(Reicht.Stage.Best())
local profile = Reicht.Data.Get(true)
Reicht.Gear.EquipBest()
profile = Reicht.Data.Get(true)
for _ = 1, 10 do
if not State.Alive or Reicht.Gear.Enhance(profile) then break end
profile = Reicht.Data.Get(true)
task.wait(0.2)
end
for _, spec in ipairs(Config.GearSlots) do
local uuid = profile.Backpack.equiped[spec.slot]
if uuid then
Reicht.Gear.Enchant(profile, uuid)
Reicht.Util.Remote("Backpack", "SetLockRE"):FireServer(uuid, true)
end
end
return made
end
function Reicht.Index.HuntAll()
local found, tried = 0, 0
for _, gear in ipairs(Reicht.Index.Missing()) do
if not State.Opt.AutoIndex and State.Lock ~= "Index" then break end
if gear.forgeable and Reicht.Index.Plan(gear) > 0 then
tried += 1
if Reicht.Index.Hunt(gear) then found += 1 end
end
end
Reicht.Index.ClaimAll()
if tried > 0 then State.IndexNote = ("Found %d/%d"):format(found, tried) end
return found, tried
end
function Reicht.Index.CollectOres()
for _, stageId in ipairs(Reicht.Stage.List()) do
Reicht.Stage.Collect(stageId, nil)
end
Reicht.Index.ClaimAll()
end
function Reicht.Index.ClaimAll()
local index = Reicht.Data.Get().Index
local claimExp = Reicht.Util.Remote("Index", "TryClaimIndexExpRF")
for key in pairs(index.unlocked) do
local itemType, itemId = key:match("^(.-)%-(.+)$")
if itemType and not index.claimed[key] then
claimExp:InvokeServer(itemType, itemId)
end
end
local claimLevel = Reicht.Util.Remote("Index", "TryClaimLevelRewardRF")
for _ = 1, Config.IndexLevelClaims do
if not claimLevel:InvokeServer() then break end
end
end
function Reicht.Index.Progress()
local index = Reicht.Data.Get().Index
local unlocked = 0
for _ in pairs(index.unlocked) do
unlocked += 1
end
return unlocked, index.level
end
function Reicht.Stage.List()
local stages = {}
for stageId in pairs(Reicht.GameLib.Api(GameConfig.Stage.Helper).GetStageEnemyConfig()) do
table.insert(stages, stageId)
end
table.sort(stages, function(a, b) return Reicht.Util.Tier(a) > Reicht.Util.Tier(b) end)
return stages
end
function Reicht.Stage.Best()
return Reicht.Stage.List()[1] or "Stage_27"
end
function Reicht.Stage.Collect(stageId, rarities)
local drops = Reicht.Util.Remote("Stage", "StageFinishedRF"):InvokeServer(stageId)
if type(drops) ~= "table" then return end
local getOre = Reicht.Util.Remote("Stage", "GetOreRF")
local getStone = Reicht.Util.Remote("Stage", "GetEnhantStoneRE")
for uuid, drop in pairs(drops) do
if type(drop) == "table" then
if drop.Type == "Material" then
getStone:FireServer(uuid)
else
getOre:InvokeServer(uuid, true)
end
elseif not rarities or rarities[Reicht.Ore.Rarity(drop)] then
getOre:InvokeServer(uuid, true)
end
end
Reicht.Util.Remote("Stage", "ClaimedAllOreRE"):FireServer()
Reicht.Data.Get(true)
end
function Reicht.Stage.FarmStones(stageId)
stageId = stageId or Reicht.Stage.Best()
local finished = Reicht.Util.Remote("Stage", "StageFinishedRF")
local pickStone = Reicht.Util.Remote("Stage", "GetEnhantStoneRE")
local getOre = Reicht.Util.Remote("Stage", "GetOreRF")
Reicht.Util.WaitAll(Config.StoneWorkers, function()
for _ = 1, Config.StoneCallsPerWorker do
local drops = finished:InvokeServer(stageId)
for uuid, drop in pairs(type(drops) == "table" and drops or {}) do
if type(drop) == "table" then
if drop.Type == "Material" then
pickStone:FireServer(uuid)
else
getOre:InvokeServer(uuid, true)
end
end
end
end
end)
Reicht.Data.Get(true)
end
function Reicht.Stage.FarmTurbo(targetId, kind, needed)
needed = math.clamp(math.floor(needed or 1), 1, 1000000)
local stageId = targetId and (State.OreStage[targetId] or Config.OreStages[targetId])
if not stageId then
if kind == "Egg" or (targetId and targetId:find("^Egg")) then
stageId = (targetId == "Egg1" and "Stage_11") or "Stage_27"
elseif targetId and Config.OreStages[targetId] then
stageId = Config.OreStages[targetId]
else
stageId = Reicht.Stage.Best()
end
end
local finished = Reicht.Util.Remote("Stage", "StageFinishedRF")
local getOre = Reicht.Util.Remote("Stage", "GetOreRF")
local pickStone = Reicht.Util.Remote("Stage", "GetEnhantStoneRE")
local claimAll = Reicht.Util.Remote("Stage", "ClaimedAllOreRE")
local got = 0
local wasIntoFight = LocalPlayer:GetAttribute("IntoFight")
if wasIntoFight ~= "Stage" then
LocalPlayer:SetAttribute("IntoFight", "Stage")
end
if kind == "Egg" then
Reicht.Pet.TrimEggs(targetId)
end
local workers = math.clamp(Config.TurboFarmWorkers or 16, 8, 24)
local deadline = os.clock() + 12
Reicht.Util.WaitAll(workers, function()
while State.Alive and got < needed and os.clock() < deadline do
local drops = finished:InvokeServer(stageId)
if type(drops) == "table" then
for uuid, drop in pairs(drops) do
if got >= needed then break end
local id = type(drop) == "table" and drop.ID or drop
local dropType = type(drop) == "table" and drop.Type or "Ore"
if id then State.OreStage[id] = stageId end
local match = false
if targetId then
match = (id == targetId)
elseif kind == "All" or dropType == kind then
match = true
end
if match then
if dropType == "Material" then
pickStone:FireServer(uuid)
got += 1
else
local ret = getOre:InvokeServer(uuid, true)
if ret ~= false then
got += 1
end
end
end
end
else
break
end
end
end)
if not targetId then
claimAll:FireServer()
end
if wasIntoFight ~= "Stage" then
LocalPlayer:SetAttribute("IntoFight", wasIntoFight)
end
Reicht.Data.Get(true)
return got
end
function Reicht.Stage.FarmEggsAndFood(rounds)
rounds = math.clamp(rounds or Config.EggFarmCalls, 1, 100)
local stageId = "Stage_27"
local finished = Reicht.Util.Remote("Stage", "StageFinishedRF")
local getOre = Reicht.Util.Remote("Stage", "GetOreRF")
local pickStone = Reicht.Util.Remote("Stage", "GetEnhantStoneRE")
local claimAll = Reicht.Util.Remote("Stage", "ClaimedAllOreRE")
local eggs, foods = 0, 0
Reicht.Pet.TrimEggs("Egg2")
Reicht.Util.WaitAll(Config.TurboFarmWorkers or 24, function()
for _ = 1, rounds do
if not State.Alive then break end
local drops = finished:InvokeServer(stageId)
if type(drops) == "table" then
for uuid, drop in pairs(drops) do
if type(drop) == "table" then
if drop.Type == "Material" then
pickStone:FireServer(uuid)
elseif drop.Type == "Egg" then
if getOre:InvokeServer(uuid, true) then eggs += 1 end
elseif drop.Type == "Food" then
if getOre:InvokeServer(uuid, true) then foods += 1 end
end
end
end
end
end
end)
claimAll:FireServer()
Reicht.Data.Get(true)
if State.Opt.AutoDeleteEggs then Reicht.Pet.TrimEggs() end
return eggs, foods
end
function Reicht.Stage.FarmMaxOres(rounds)
rounds = math.clamp(rounds or 20, 1, 100)
local stageId = State.Opt.Stage or Reicht.Stage.Best() or "Stage_27"
local finished = Reicht.Util.Remote("Stage", "StageFinishedRF")
local getOre = Reicht.Util.Remote("Stage", "GetOreRF")
local pickStone = Reicht.Util.Remote("Stage", "GetEnhantStoneRE")
local claimAll = Reicht.Util.Remote("Stage", "ClaimedAllOreRE")
local total = 0
Reicht.Util.WaitAll(Config.TurboFarmWorkers or 24, function()
for _ = 1, rounds do
if not State.Alive then break end
local drops = finished:InvokeServer(stageId)
if type(drops) == "table" then
for uuid, drop in pairs(drops) do
if type(drop) == "table" and drop.Type == "Material" then
pickStone:FireServer(uuid)
else
if getOre:InvokeServer(uuid, true) then
total += 1
end
end
end
end
end
end)
claimAll:FireServer()
Reicht.Data.Get(true)
return total
end
function Reicht.Stage.RushAllStages(roundsPerStage)
roundsPerStage = math.clamp(roundsPerStage or 5, 1, 50)
local finished = Reicht.Util.Remote("Stage", "StageFinishedRF")
local getOre = Reicht.Util.Remote("Stage", "GetOreRF")
local pickStone = Reicht.Util.Remote("Stage", "GetEnhantStoneRE")
local claimAll = Reicht.Util.Remote("Stage", "ClaimedAllOreRE")
local totalDrops = 0
local wasIntoFight = LocalPlayer:GetAttribute("IntoFight")
if wasIntoFight ~= "Stage" then
LocalPlayer:SetAttribute("IntoFight", "Stage")
end
for sNum = 1, 27 do
local stageId = "Stage_" .. sNum
for _ = 1, roundsPerStage do
local drops = finished:InvokeServer(stageId)
if type(drops) == "table" then
for uuid, drop in pairs(drops) do
totalDrops += 1
if type(drop) == "table" and drop.Type == "Material" then
pickStone:FireServer(uuid)
else
getOre:InvokeServer(uuid, true)
end
end
end
end
end
claimAll:FireServer()
Reicht.Data.Get(true)
return totalDrops
end
function Reicht.Stage.ExitFight()
pcall(function()
Reicht.GameLib.Api(LocalPlayer.PlayerScripts.Manager.StageManager.StageUtils).ExitFight(true)
end)
end
function Reicht.Stage.BattleStep()
local fight = LocalPlayer:GetAttribute("IntoFight")
if fight and fight ~= "Stage" then return end
if not LocalPlayer.Character or LocalPlayer:GetAttribute("Dead") then return end
if not fight then
local stageId = State.Opt.Stage or Reicht.Stage.Best()
if not stageId then return end
local manager = LocalPlayer.PlayerScripts:FindFirstChild("Manager")
local stageManager = manager and manager:FindFirstChild("StageManager")
local module = stageManager and stageManager:FindFirstChild("StageUtils")
if not module then error("StageUtils unavailable while loading", 0) end
Reicht.GameLib.Api(module).StartFight(stageId)
end
if State.Alive and State.Opt.AutoBattle then Reicht.Combat.KillAll(false) end
end
function Reicht.Level.ResolveTargetArea()
local selected = State.Opt.TrainArea
if selected and selected ~= "Auto Best" then
local num = tonumber(string.match(selected, "Area (%d+)"))
if num then return num end
end
return 9
end
function Reicht.Level.Enter(targetArea)
if not State.Alive then return end
targetArea = targetArea or Reicht.Level.ResolveTargetArea()
if not targetArea then return end
State.TrainArea = targetArea
local into = Reicht.Util.Remote("Train", "IntoAutoTrainRE")
if into then
into:FireServer(targetArea, true)
end
State.TrainFiredAt = os.clock()
end
function Reicht.Level.Leave()
local areaId = LocalPlayer:GetAttribute("AutoTrainAreaID") or State.TrainArea
if areaId then
local into = Reicht.Util.Remote("Train", "IntoAutoTrainRE")
if into then
into:FireServer(areaId, false)
end
end
State.TrainArea = nil
State.TrainPending = nil
end
function Reicht.Level.SetTraining(enabled)
State.TrainGen += 1
if enabled then
Reicht.Level.Enter()
if State.Opt.AutoClick and not State.ClickThread then
Reicht.Level.StartClicking()
end
else
Reicht.Level.Leave()
end
end
function Reicht.Level.Bind()
table.insert(State.Conns, LocalPlayer:GetAttributeChangedSignal("AutoTrainAreaID"):Connect(function()
if not State.Opt.AutoTrain or LocalPlayer:GetAttribute("AutoTrainAreaID") then return end
task.delay(Config.TrainRejoinDelay, function()
if State.Opt.AutoTrain and not LocalPlayer:GetAttribute("AutoTrainAreaID") then
Reicht.Util.Try(Reicht.Level.Enter)
end
end)
end))
end
function Reicht.Level.UsePotions(profile)
local potionConfig = Reicht.GameLib.Need(GameConfig.Potion.Config)
local now = workspace:GetAttribute("ServerTime") or os.time()
local buffs = profile.Buff or {}
for potionName, count in pairs(profile.Potion or {}) do
local buffId = potionConfig[potionName] and potionConfig[potionName].BuffID
local active = buffId and type(buffs[buffId]) == "number" and buffs[buffId] > now
if type(count) == "number" and count > 0 and not active then
Reicht.Util.Remote("Potion", "TryUsePotionRE"):FireServer(potionName, 1)
end
end
end
function Reicht.Level.TrainStep()
local profile = Reicht.Data.Get()
Reicht.Level.UsePotions(profile)
if profile.Eco.rebirth ~= State.TrainRebirth or profile.Eco.level ~= State.TrainLevel then
State.TrainRebirth = profile.Eco.rebirth
State.TrainLevel = profile.Eco.level
State.TrainArea = nil
end
local targetArea = Reicht.Level.ResolveTargetArea()
local currentArea = LocalPlayer:GetAttribute("AutoTrainAreaID")
if currentArea ~= targetArea then
Reicht.Level.Enter(targetArea)
end
if State.Opt.AutoRebirth then
Reicht.Level.RebirthStep()
end
if State.Opt.AutoEquipPet then
Reicht.Pet.EquipBest("Train")
end
end
function Reicht.Level.Rebirth()
Reicht.Util.Remote("Rebirth", "TryRebirthRE"):FireServer()
Reicht.Data.Get(true)
end
function Reicht.Level.RebirthStep()
if not State.Opt.AutoRebirth then return end
local profile = Reicht.Data.Get()
local ok, needLevel = pcall(Reicht.GameLib.Api(GameConfig.Rebirth.Helper).GetNeedLevel, profile.Eco.rebirth + 1)
if ok and needLevel and profile.Eco.level >= needLevel then
Reicht.Level.Rebirth()
end
end
function Reicht.Level.PopTrainUUID()
local cache = State.TrainUUIDs
if not cache or #cache < 250 then
if not State.FetchingTrainUUIDs then
State.FetchingTrainUUIDs = true
task.spawn(function()
local rf = Reicht.Util.FindRemote("Train", "InvokTrainDataListRF")
if rf then
for _ = 1, 2 do
local ok, raw = pcall(function() return rf:InvokeServer(State.TrainArea or 9) end)
if ok and raw then
local encoding = Reicht.GameLib.Need(ReplicatedStorage.Utils.EncodingUtils)
local list = encoding and encoding.DecodeTable(raw)
if list and #list > 0 then
local current = State.TrainUUIDs or {}
for _, item in ipairs(list) do
if item.UUID then table.insert(current, item.UUID) end
end
State.TrainUUIDs = current
end
end
end
end
State.FetchingTrainUUIDs = false
end)
end
end
if cache and #cache > 0 then
return table.remove(cache, 1)
end
return nil
end
function Reicht.Level.ClickBurst(count)
count = count or (State.Opt.ClickTurbo and 50 or 15)
local trainOnce = Reicht.Util.FindRemote("Train", "TrainOnceRE")
local intoTrain = Reicht.Util.FindRemote("Train", "IntoAutoTrainRE")
if intoTrain and not LocalPlayer:GetAttribute("AutoTrainAreaID") then
pcall(intoTrain.FireServer, intoTrain, State.TrainArea or 9, true)
end
if not trainOnce then return end
for _ = 1, count do
local uuid = Reicht.Level.PopTrainUUID()
if uuid then
trainOnce:FireServer(uuid)
else
break
end
end
LocalPlayer:SetAttribute("LastTrainTick", tick())
end
function Reicht.Level.ClickStep()
if not (State.Opt.AutoClick or State.Opt.AutoTrain or State.Opt.GodTrain) then return end
if not State.ClickThread then
Reicht.Level.StartClicking()
end
end
function Reicht.Level.GodPowerBurst(targetGained)
targetGained = targetGained or 100000000000
local rf = Reicht.Util.FindRemote("Train", "InvokTrainDataListRF")
local trainOnce = Reicht.Util.FindRemote("Train", "TrainOnceRE")
local intoTrain = Reicht.Util.FindRemote("Train", "IntoAutoTrainRE")
local encoding = Reicht.GameLib.Need(ReplicatedStorage.Utils.EncodingUtils)
if not (rf and trainOnce and encoding) then return 0 end
if intoTrain and not LocalPlayer:GetAttribute("AutoTrainAreaID") then
pcall(intoTrain.FireServer, intoTrain, State.TrainArea or 9, true)
end
local profileBefore = Reicht.Data.Get(true)
local powerBefore = profileBefore and profileBefore.Eco and (profileBefore.Eco.power or 0) or 0
local gained = 0
for _ = 1, 10 do
local ok, raw = pcall(function() return rf:InvokeServer(State.TrainArea or 9) end)
if ok and raw then
local list = encoding.DecodeTable(raw)
if list and #list > 0 then
for i = 1, #list do
local item = list[i]
if item and item.UUID then
trainOnce:FireServer(item.UUID)
end
end
end
end
local profileNow = Reicht.Data.Get(true)
local powerNow = profileNow and profileNow.Eco and (profileNow.Eco.power or 0) or 0
gained = powerNow - powerBefore
if gained >= targetGained then break end
task.wait(0.04)
end
if State.Opt.AutoRebirth then
Reicht.Level.RebirthStep()
end
return gained
end
function Reicht.Level.StartClicking()
if State.ClickThread then return end
State.ClickThread = task.defer(function()
local trainOnce = Reicht.Util.FindRemote("Train", "TrainOnceRE")
local intoTrain = Reicht.Util.FindRemote("Train", "IntoAutoTrainRE")
while State.Alive and (State.Opt.AutoClick or State.Opt.AutoTrain or State.Opt.GodTrain) do
if intoTrain and LocalPlayer:GetAttribute("AutoTrainAreaID") ~= (State.TrainArea or 9) then
pcall(intoTrain.FireServer, intoTrain, State.TrainArea or 9, true)
end
local batch = State.Opt.GodTrain and 150 or (State.Opt.HyperTrain and 50 or (State.Opt.ClickTurbo and 25 or 10))
for _ = 1, batch do
local uuid = Reicht.Level.PopTrainUUID()
if uuid and trainOnce then
trainOnce:FireServer(uuid)
else
break
end
end
LocalPlayer:SetAttribute("LastTrainTick", tick())
if State.Opt.AutoRebirth then
Reicht.Level.RebirthStep()
end
local delay = State.Opt.GodTrain and 0.005 or (State.Opt.HyperTrain and 0.01 or (State.Opt.ClickTurbo and 0.02 or 0.08))
task.wait(delay)
end
State.ClickThread = nil
end)
end
function Reicht.Upgrade.Names()
local names = {}
for name in pairs(Reicht.GameLib.Need(GameConfig.Upgrade.Config)) do
table.insert(names, name)
end
table.sort(names)
return names
end
function Reicht.Upgrade.BuySelected()
local buy = Reicht.Util.Remote("Upgrade", "UpgradeOnceRE")
for name, selected in pairs(State.Opt.Upgrades) do
if selected then buy:FireServer(name) end
end
Reicht.Data.Get(true)
end
function Reicht.Tower.LastRound()
return 50
end
function Reicht.Tower.Enter()
local deadline = os.clock() + 5
while State.Entering and os.clock() < deadline do
task.wait(0.1)
end
if State.InTower then return true end
State.Entering = true
local ok, entered = pcall(function()
return Reicht.Util.Remote("Dungeon", "TryIntoDungeonRF"):InvokeServer(true, 1)
end)
State.Entering = false
State.InTower = ok and entered and true or false
return State.InTower
end
function Reicht.Tower.Exit()
if not State.InTower then return end
State.InTower = false
pcall(function()
Reicht.Util.Remote("Dungeon", "TryIntoDungeonRF"):InvokeServer(false)
end)
end
function Reicht.Tower.FarmStep()
if not Reicht.Tower.Enter() then return false end
local round = Reicht.Tower.LastRound()
local start = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local complete = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
start:FireServer(round)
Reicht.Util.WaitAll(Config.TowerWorkers, function()
for _ = 1, Config.TowerCallsPerWorker do
if complete:InvokeServer(round) then
State.TowerLoot += 1
end
end
end)
Reicht.Data.Get(true)
return true
end
function Reicht.Tower.RunRounds(floor, rounds, onDrop)
local wasIn = State.InTower
if not wasIn and not Reicht.Tower.Enter() then return false end
local startRE = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local completeRF = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
for _ = 1, rounds do
if not State.Alive then break end
pcall(startRE.FireServer, startRE, floor)
task.wait(0.04)
local ok, res = pcall(completeRF.InvokeServer, completeRF, floor)
if ok and onDrop then
local shouldStop = onDrop(res)
if shouldStop then break end
end
end
Reicht.Data.Get(true)
if not wasIn and not State.Opt.AutoTower then
Reicht.Tower.Exit()
end
return true
end
function Reicht.Tower.FarmCoins(target)
target = math.clamp(math.floor(tonumber(target) or 200000), 100, 10000000)
local wasIn = State.InTower
if not wasIn and not Reicht.Tower.Enter() then return 0 end
local startCoin = Reicht.Season.Coins()
local startRE = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local completeRF = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
local deadline = os.clock() + math.clamp(math.ceil(target / 100) * 0.5, 30, 900)
local workers = 4
local roundsPerWorker = 10
while State.Alive and os.clock() < deadline do
local curCoin = Reicht.Season.Coins()
if (curCoin - startCoin) >= target then break end
Reicht.Util.WaitAll(workers, function()
for _ = 1, roundsPerWorker do
if not State.Alive then break end
pcall(startRE.FireServer, startRE, 50)
task.wait(0.02)
pcall(completeRF.InvokeServer, completeRF, 50)
end
end)
Reicht.Data.Get(true)
end
Reicht.Data.Get(true)
if not wasIn and not State.Opt.AutoTower and not State.Opt.AutoSeasonCoins then
Reicht.Tower.Exit()
end
return math.max(0, Reicht.Season.Coins() - startCoin)
end
function Reicht.Tower.ContinuousCoinsStep()
if not State.Alive or not State.Opt.AutoSeasonCoins then return end
if not State.InTower and not Reicht.Tower.Enter() then return end
local startRE = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local completeRF = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
local workers = 4
local roundsPerWorker = 5
Reicht.Util.WaitAll(workers, function()
for _ = 1, roundsPerWorker do
if not State.Alive or not State.Opt.AutoSeasonCoins then break end
pcall(startRE.FireServer, startRE, 50)
task.wait(0.02)
pcall(completeRF.InvokeServer, completeRF, 50)
end
end)
Reicht.Data.Get(true)
end
function Reicht.Tower.RushAllFloors(targetMaxFloor)
targetMaxFloor = math.clamp(targetMaxFloor or 50, 1, 50)
local wasIn = State.InTower
if not wasIn and not Reicht.Tower.Enter() then
return 0, 0
end
local startRE = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local completeRF = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
local cleared = 0
local totalRewards = 0
for floor = 1, targetMaxFloor do
if not State.Alive then break end
pcall(startRE.FireServer, startRE, floor)
task.wait(0.04)
local ok, res = pcall(completeRF.InvokeServer, completeRF, floor)
if ok and res then
cleared += 1
if type(res) == "table" then
totalRewards += #res
end
end
end
Reicht.Data.Get(true)
if not wasIn and not State.Opt.AutoTower then
Reicht.Tower.Exit()
end
return cleared, totalRewards
end
function Reicht.Tower.SpawnStonesInstant(rounds)
rounds = math.clamp(rounds or 30, 1, 100)
local gained = 0
Reicht.Tower.RunRounds(50, rounds, function(res)
if type(res) == "table" then
for _, drop in ipairs(res) do
if type(drop) == "table" then
if drop.Type == "EnchStone" or (type(drop.ID) == "string" and drop.ID:find("_3")) then
gained = gained + (drop.Number or 1)
end
end
end
end
return false
end)
return gained
end
function Reicht.Tower.SpawnCoinsInstant(target)
return Reicht.Tower.FarmCoins(target or 200000)
end
function Reicht.Boss.AttackId()
local weapon = LocalPlayer:GetAttribute("WeaponType")
return Config.BossAttackIds[weapon] or "G_ATK_1"
end
function Reicht.Boss.Join()
Reicht.Util.Remote("WorldBoss", "IntoWorldBossFightRE"):FireServer(true)
LocalPlayer:SetAttribute("IntoFight", "WorldBoss")
local char = LocalPlayer.Character
if char and not State.BossReturn then State.BossReturn = char:GetPivot() end
end
function Reicht.Boss.StandNear(boss)
local char = LocalPlayer.Character
if not char then return end
local pos = boss:GetPivot().Position
if (char:GetPivot().Position - pos).Magnitude > Config.BossReach then
char:PivotTo(CFrame.new(pos + Vector3.new(0, Config.BossStandHeight, Config.BossStandBack), pos))
end
end
function Reicht.Boss.Step()
local bossName = workspace:GetAttribute("CurrentWorldBoss")
if not bossName then return end
local attackId = Reicht.Boss.AttackId()
if not attackId then return end
if LocalPlayer:GetAttribute("IntoFight") ~= "WorldBoss" then
Reicht.Boss.Join()
task.wait(Config.BossJoinSettle)
end
local folder = workspace:FindFirstChild("EnemyFolder_Server")
local boss = folder and folder:FindFirstChild(bossName)
if not boss or boss:GetAttribute("Dead") then return end
Reicht.Boss.StandNear(boss)
local announce = Reicht.Util.Remote("Attack", "UseAnyATKRE")
local attack = Reicht.Util.Remote("Attack", "AttackEnemyServiceRE")
for _ = 1, Config.BossHitsPerTick do
if not (State.Alive and State.Opt.AutoWorldBoss and boss.Parent) or boss:GetAttribute("Dead") then return end
local timestamp = workspace:GetServerTimeNow()
announce:FireServer(attackId, timestamp)
attack:FireServer({ bossName }, { Phase = 1, SkillID = attackId, Attacker = LocalPlayer }, timestamp)
task.wait(Config.BossHitGap)
end
end
function Reicht.Boss.ClaimCards()
local claim = Reicht.Util.Remote("WorldBoss", "TryClaimBossRewardRE")
for card = 1, Config.BossCards do
task.spawn(claim.FireServer, claim, tostring(card))
end
end
function Reicht.Boss.Leave()
pcall(function()
Reicht.Util.Remote("WorldBoss", "IntoWorldBossFightRE"):FireServer(false)
end)
pcall(function()
local exitBE = Reicht.GameLib.Api(ReplicatedStorage.Utils.CommunicationUtils).TryGetBindableEvent("Stage", "ExitWorldBossBE")
if exitBE then exitBE:Fire() end
end)
LocalPlayer:SetAttribute("IntoFight", nil)
local char = LocalPlayer.Character
if State.BossReturn and char then
char:PivotTo(State.BossReturn)
elseif char then
pcall(function()
local translate = Reicht.GameLib.Need(ReplicatedStorage.Utils.TranslateUtils)
if translate and translate.ToSpawn then translate.ToSpawn(char) end
end)
end
State.BossReturn = nil
end
function Reicht.Boss.NukeNow()
local bossName = workspace:GetAttribute("CurrentWorldBoss")
if not bossName then return false end
local folder = workspace:FindFirstChild("EnemyFolder_Server")
local boss = folder and folder:FindFirstChild(bossName)
if not boss or boss:GetAttribute("Dead") then return false end
Reicht.Boss.Join()
task.wait(Config.BossJoinSettle or 0.1)
Reicht.Boss.StandNear(boss)
local attackId = Reicht.Boss.AttackId()
local announce = Reicht.Util.Remote("Attack", "UseAnyATKRE")
local attack = Reicht.Util.Remote("Attack", "AttackEnemyServiceRE")
local deadRE = Reicht.Util.FindRemote("WorldBoss", "BossDeadRE")
local threads = 8
local hitsPerThread = 15
for _ = 1, threads do
task.spawn(function()
for _ = 1, hitsPerThread do
if not boss.Parent or boss:GetAttribute("Dead") then break end
local timestamp = workspace:GetServerTimeNow()
pcall(announce.FireServer, announce, attackId, timestamp)
pcall(attack.FireServer, attack, { bossName }, { Phase = 1, SkillID = attackId, Attacker = LocalPlayer }, timestamp)
end
end)
end
task.wait(0.3)
if deadRE and boss:GetAttribute("Dead") then
pcall(deadRE.FireServer, deadRE, bossName)
end
task.wait(0.2)
Reicht.Boss.ClaimCards()
Reicht.Boss.Leave()
return true
end
function Reicht.Boss.Bind()
table.insert(State.Conns, Reicht.Util.Remote("WorldBoss", "BossDeadRE").OnClientEvent:Connect(function()
if not State.Opt.AutoWorldBoss then return end
State.BossLooting = os.clock()
task.delay(Config.BossClaimDelay, function()
if State.Opt.BossCards then Reicht.Util.Try(Reicht.Boss.ClaimCards) end
task.wait(Config.BossHopAfter)
Reicht.Util.Try(Reicht.Boss.Leave)
State.BossDone = os.clock()
State.BossLooting = nil
end)
end))
table.insert(State.Conns, Reicht.Util.Remote("WorldBoss", "BossEscapeRE").OnClientEvent:Connect(function()
if State.Opt.AutoWorldBoss then Reicht.Util.Try(Reicht.Boss.Leave) end
end))
end
function Reicht.Season.Current(profile)
local prof = profile or Reicht.Data.Get()
local seasons = prof and prof.Season or {}
local activeKey = workspace:GetAttribute("Season")
local cur = nil
if activeKey and seasons[activeKey] then
cur = seasons[activeKey]
elseif seasons.Season2 then
cur = seasons.Season2
elseif seasons.Season1 then
cur = seasons.Season1
elseif seasons.Coin or seasons.SeasonCoin or seasons.SeasonTicket then
cur = seasons
else
local bestKey = Reicht.Util.HighestKey(seasons)
cur = bestKey and seasons[bestKey] or seasons[next(seasons)] or seasons
end
if cur and type(cur) == "table" and cur.Coin and not cur.SeasonCoin then
cur.SeasonCoin = cur.Coin
end
return cur
end
function Reicht.Season.Coins(profile)
local sData = Reicht.Season.Current(profile)
if not sData then return 0 end
return sData.Coin or sData.SeasonCoin or 0
end
function Reicht.Season.Goods()
local goods = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
local ids = {}
for goodId in pairs(goods) do
table.insert(ids, goodId)
end
table.sort(ids, function(a, b) return tonumber(a) < tonumber(b) end)
local labels, byLabel = {}, {}
for _, goodId in ipairs(ids) do
local good = goods[goodId]
local label = ("%s x%d (%d coin)"):format(good.ID, good.Number, good.NeedSeasonCoin)
byLabel[label] = goodId
table.insert(labels, label)
end
return labels, byLabel
end
function Reicht.Season.BuyExclusive()
local goods = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
local exchange = Reicht.Util.Remote("Season", "ExchangeGoodsRE")
local bought = 0
for goodId, good in pairs(goods) do
if not State.Alive then break end
if good.Type ~= "Weapon" and good.Type ~= "Armor" and good.Type ~= "Hat" then continue end
local season = Reicht.Season.Current()
local before = season and ((season.Goods or {})[goodId] or 0) or 0
if not season or before >= (good.Store or 1) then continue end
local short = good.NeedSeasonCoin - (season.SeasonCoin or 0)
if short > 0 then
Reicht.Tower.FarmCoins(short)
season = Reicht.Season.Current()
end
if not season or (season.SeasonCoin or 0) < good.NeedSeasonCoin then continue end
exchange:FireServer(goodId)
task.wait(0.3)
local updated = Reicht.Season.Current()
if updated and ((updated.Goods or {})[goodId] or 0) > before then bought += 1 end
end
Reicht.Data.Get(true)
return bought
end
function Reicht.Season.BuyGoods()
local goods = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
local exchange = Reicht.Util.Remote("Season", "ExchangeGoodsRE")
for goodId, wanted in pairs(State.Opt.SeasonGoods) do
local good = goods[goodId]
if not (wanted and good) then continue end
for _ = 1, good.Store or 1 do
if not State.Alive then return end
local season = Reicht.Season.Current()
local count = season and ((season.Goods or {})[goodId] or 0) or 0
if not season or count >= (good.Store or 1) or (season.SeasonCoin or 0) < good.NeedSeasonCoin then break end
exchange:FireServer(goodId)
task.wait(0.2)
local updated = Reicht.Season.Current()
if not updated or ((updated.Goods or {})[goodId] or 0) <= count then break end
end
end
Reicht.Data.Get(true)
end
function Reicht.Season.Step()
Reicht.Util.Remote("Season", "TryClaimDailyTicRE"):FireServer()
Reicht.Util.Remote("Season", "TryClaimAllRewardRE"):FireServer()
pcall(function()
Reicht.Util.Remote("Season", "LuckPetRF"):InvokeServer()
end)
task.wait(0.3)
Reicht.Season.BuyGoods()
local season = Reicht.Season.Current()
if not (season and State.Opt.SeasonSpin) then return end
local luck = Reicht.Util.Remote("Season", "LuckRE")
for _ = 1, math.min(season.SeasonTicket or 0, math.clamp(State.Opt.SeasonSpinBatch, 1, 50)) do
if not State.Alive or not State.Opt.AutoSeason or not State.Opt.SeasonSpin then break end
luck:FireServer(1)
task.wait(0.6)
end
end
function Reicht.Season.SaveRejoinPersistence(enabled)
local folder = Config.SaveFolder
local file = folder .. "/" .. Config.RejoinSeasonFlag
pcall(function()
if enabled then
if not isfolder(folder) then makefolder(folder) end
local data = {
Active = true,
At = os.time(),
RejoinDelay = State.Opt.RejoinDelay,
RejoinMode = State.Opt.RejoinMode,
RejoinClaimPass = State.Opt.RejoinClaimPass,
RejoinBuyTickets = State.Opt.RejoinBuyTickets,
RejoinBuyRaceRoll = State.Opt.RejoinBuyRaceRoll,
RejoinBuyProtect = State.Opt.RejoinBuyProtect,
RejoinRestock = State.Opt.RejoinRestock,
RejoinSpinWheel = State.Opt.RejoinSpinWheel,
RejoinAutoFarmCoins = State.Opt.RejoinAutoFarmCoins,
}
writefile(file, HttpService:JSONEncode(data))
elseif isfile(file) then
delfile(file)
end
end)
end
function Reicht.Season.LoadRejoinPersistence()
local folder = Config.SaveFolder
local file = folder .. "/" .. Config.RejoinSeasonFlag
local ok, text = pcall(readfile, file)
if not ok or not text or text == "" then return nil end
local ok2, data = pcall(HttpService.JSONDecode, HttpService, text)
if ok2 and type(data) == "table" and data.Active then
return data
end
return nil
end
function Reicht.Season.EnsureCoins(target, timeoutSec)
target = target or 1000
local current = Reicht.Season.Coins()
if current >= target then return current end
if not Reicht.Tower.Enter() then return current end
local startRE = Reicht.Util.Remote("Dungeon", "StartRoundRE")
local completeRF = Reicht.Util.Remote("Dungeon", "CompleteRoundRF")
local deadline = os.clock() + (timeoutSec or 8)
local workers = 4
local callsPerWorker = 15
while State.Alive and os.clock() < deadline do
startRE:FireServer(50)
local threads = {}
for _ = 1, workers do
table.insert(threads, task.spawn(function()
for _ = 1, callsPerWorker do
pcall(completeRF.InvokeServer, completeRF, 50)
end
end))
end
task.wait(1.2)
local prof = Reicht.Data.Get(true)
current = Reicht.Season.Coins(prof)
if current >= target then break end
end
Reicht.Tower.Exit()
Reicht.Data.Get(true)
return current
end
function Reicht.Season.ExchangeSelectedNow()
local goodsCfg = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
if not goodsCfg then return 0, "No GoodsConfig" end
local exchange = Reicht.Util.Remote("Season", "ExchangeGoodsRE")
local boughtCount = 0
local targets = {}
if State.Opt.RejoinBuyTickets then table.insert(targets, "7") end
if State.Opt.RejoinBuyRaceRoll then table.insert(targets, "5") end
if State.Opt.RejoinBuyProtect then table.insert(targets, "4") end
if State.Opt.RejoinAutoFarmCoins then
local totalNeeded = 0
local sDataCheck = Reicht.Season.Current(Reicht.Data.Get(true))
for _, goodId in ipairs(targets) do
local good = goodsCfg[goodId]
if good then
local ownedInStore = sDataCheck and sDataCheck.Goods and sDataCheck.Goods[goodId] or 0
local maxRuns = State.Opt.RejoinRestock and (good.Store or 1) or 1
local buyAmount = math.max(0, math.min(maxRuns, (good.Store or 1) - ownedInStore))
totalNeeded = totalNeeded + (buyAmount * (good.NeedSeasonCoin or 0))
end
end
if totalNeeded > 0 and Reicht.Season.Coins() < totalNeeded then
Reicht.Season.EnsureCoins(totalNeeded, 10)
end
end
for _, goodId in ipairs(targets) do
pcall(function() exchange:FireServer(goodId, -5) end)
pcall(function() exchange:FireServer(tonumber(goodId), -5) end)
end
task.wait(0.05)
local keyVariations = {
function(id) return tostring(id) end,
function(id) return "0" .. tostring(id) end,
function(id) return " " .. tostring(id) end,
function(id) return tostring(id) .. " " end,
function(id) return "00" .. tostring(id) end,
}
for _, goodId in ipairs(targets) do
local good = goodsCfg[goodId]
if not good then continue end
local maxRuns = State.Opt.RejoinRestock and (good.Store or 1) or 1
for _, makeKey in ipairs(keyVariations) do
if not State.Alive then break end
local currentKey = makeKey(goodId)
local sData = Reicht.Season.Current(Reicht.Data.Get(true))
local ownedInStore = sData and sData.Goods and sData.Goods[currentKey] or 0
if ownedInStore < (good.Store or 1) then
local remaining = (good.Store or 1) - ownedInStore
local runs = math.min(maxRuns, remaining)
for _ = 1, runs do
if not State.Alive then break end
sData = Reicht.Season.Current(Reicht.Data.Get(true))
local coins = sData and (sData.SeasonCoin or sData.Coin or 0) or 0
if coins < good.NeedSeasonCoin and State.Opt.RejoinAutoFarmCoins then
Reicht.Season.EnsureCoins(good.NeedSeasonCoin, 6)
sData = Reicht.Season.Current(Reicht.Data.Get(true))
coins = sData and (sData.SeasonCoin or sData.Coin or 0) or 0
end
if coins < good.NeedSeasonCoin then break end
for b = 1, 3 do
task.spawn(function()
exchange:FireServer(currentKey)
end)
end
task.wait(0.12)
boughtCount += 1
end
end
end
end
Reicht.Data.Get(true)
if boughtCount == 0 and #targets > 0 then
local sDataNow = Reicht.Season.Current(Reicht.Data.Get(true))
local allSoldOut = true
for _, goodId in ipairs(targets) do
local good = goodsCfg[goodId]
local owned = sDataNow and sDataNow.Goods and sDataNow.Goods[goodId] or 0
if good and owned < (good.Store or 1) then
allSoldOut = false
break
end
end
if allSoldOut then
return 0, "Selected items are sold out! (Resets every 48h on server)"
end
end
return boughtCount
end
function Reicht.Season.RejoinStatusText()
local coins = 0
local tickets = 0
local rolls = 0
local protects = 0
local resetText = ""
local cd = State.RejoinCountdown or 0
local cdText = cd > 0 and (" · Rejoin in %ds"):format(cd) or ""
pcall(function()
local prof = State.Profile
if not prof then
local ok, fetched = pcall(Reicht.Data.Get)
if ok and type(fetched) == "table" then
prof = fetched
end
end
local sData = prof and Reicht.Season.Current(prof)
coins = sData and (sData.SeasonCoin or sData.Coin or 0) or 0
tickets = sData and (sData.SeasonTicket or 0) or 0
rolls = prof and prof.Class and (prof.Class.luckTimes or 0) or 0
if prof and prof.Backpack and prof.Backpack.have then
for _, item in pairs(prof.Backpack.have) do
if item.ID == "EnhantProtect" then
protects += (item.Number or item.Count or 1)
end
end
end
end)
pcall(function()
local sDataInst = ReplicatedStorage:FindFirstChild("LocalData") and ReplicatedStorage.LocalData:FindFirstChild("SeasonData")
local sDataMod = sDataInst and Reicht.GameLib.Loaded[sDataInst]
if sDataMod and sDataMod.GetGoodRefreTime then
local sec = sDataMod.GetGoodRefreTime()
if sec and sec > 0 then
local h = math.floor(sec / 3600)
local m = math.floor((sec % 3600) / 60)
resetText = (" · Stock Reset: %dh %dm"):format(h, m)
end
end
end)
local ok, text = pcall(string.format, "Coins: %s · Tickets: %d · Race Rolls: %s · Protects: %s%s%s",
Reicht.Util.Abbreviate(coins),
tickets,
Reicht.Util.Abbreviate(rolls),
Reicht.Util.Abbreviate(protects),
resetText,
cdText
)
return ok and text or "Coins: 0 · Tickets: 0 · Race Rolls: 0 · Protects: 0"
end
function Reicht.Season.RunRejoinLoop()
if State.RejoinLoopRunning then return end
State.RejoinLoopRunning = true
task.spawn(function()
while State.Alive and State.Opt.AutoRejoinSeason do
if not game:IsLoaded() then game.Loaded:Wait() end
local prof = Reicht.Data.Get(true)
local waitTries = 0
while not prof and waitTries < 20 do
task.wait(0.5)
prof = Reicht.Data.Get(true)
waitTries += 1
end
if State.Opt.RejoinClaimPass then
pcall(function()
Reicht.Util.Remote("Season", "TryClaimDailyTicRE"):FireServer()
end)
pcall(function()
Reicht.Util.Remote("Season", "TryClaimAllRewardRE"):FireServer()
end)
pcall(function()
Reicht.Util.Remote("Season", "LuckPetRF"):InvokeServer()
end)
task.wait(0.3)
end
Reicht.Season.ExchangeSelectedNow()
if State.Opt.RejoinSpinWheel ~= false then
local sData = Reicht.Season.Current(Reicht.Data.Get(true))
local ownedTickets = sData and (sData.SeasonTicket or 0) or 0
if ownedTickets > 0 then
local luck = Reicht.Util.Remote("Season", "LuckRE")
while ownedTickets > 0 and State.Alive and State.Opt.AutoRejoinSeason do
local batch = (ownedTickets >= 10) and 10 or (ownedTickets >= 3 and 3 or 1)
luck:FireServer(batch)
ownedTickets -= batch
task.wait(0.08)
end
task.wait(0.2)
Reicht.Data.Get(true)
end
end
if not State.Alive or not State.Opt.AutoRejoinSeason then break end
local delaySec = math.clamp(tonumber(State.Opt.RejoinDelay) or 3, 0, 30)
for s = delaySec, 1, -1 do
if not State.Alive or not State.Opt.AutoRejoinSeason then break end
State.RejoinCountdown = s
task.wait(1)
end
State.RejoinCountdown = 0
if not State.Alive or not State.Opt.AutoRejoinSeason then break end
Reicht.Season.SaveRejoinPersistence(true)
local queue = queue_on_teleport or queueonteleport
if queue then
queue(Config.ReloadSource)
end
if State.Opt.RejoinMode == "Same" then
TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
else
local hopped = Reicht.Session.HopSmallest()
if not hopped then
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
end
task.wait(8)
end
State.RejoinLoopRunning = false
State.RejoinCountdown = 0
Reicht.Season.SaveRejoinPersistence(false)
end)
end
function Reicht.Claim.All()
Reicht.Util.Remote("Offline", "TryClaimOfflineRewardRE"):FireServer()
Reicht.Util.Remote("Dungeon", "TryClaimDailyDunTicRE"):FireServer()
Reicht.Util.Remote("Season", "TryClaimDailyTicRE"):FireServer()
Reicht.Util.Remote("Season", "TryClaimAllRewardRE"):FireServer()
Reicht.Util.Remote("Player", "TryJoinGroupRE"):FireServer()
Reicht.Util.Try(Reicht.Claim.CheckIn)
Reicht.Util.Try(Reicht.Index.ClaimAll)
local claimQuest = Reicht.Util.Remote("EnhantEvent", "TryClaimQuestRE")
local claimUpdate = Reicht.Util.Remote("UpdateLog", "TryClaimUPDRewardRE")
local claimPlanK = Reicht.Util.FindRemote("PlanKing_Server", "TryClaimRE") or Reicht.Util.FindRemote("PlanKing", "TryClaimRE")
for id = 1, Config.ClaimIdScan do
claimQuest:FireServer(id)
claimUpdate:FireServer(id)
end
if claimPlanK then
for day = 1, 30 do
pcall(claimPlanK.InvokeServer, claimPlanK, day)
end
end
local ok, rewards = pcall(Reicht.GameLib.Api(GameConfig.Online.Helper).GetOnlineRewardConfig)
for rewardName in pairs(ok and type(rewards) == "table" and rewards or {}) do
Reicht.Util.Remote("Online", "TryClaimRE"):FireServer(rewardName)
end
Reicht.Data.Get(true)
end
function Reicht.Claim.Code(code)
local message
local hasListener, messageEvent = pcall(Reicht.Util.Remote, "Message", "MessageRE")
local conn = hasListener and messageEvent.OnClientEvent:Connect(function(text)
message = message or tostring(text)
end)
local ok, err = pcall(function()
return Reicht.Util.Remote("Code", "TryUseCodeRF"):InvokeServer(code)
end)
local deadline = os.clock() + Config.CodeReplyWait
while conn and not message and os.clock() < deadline do task.wait(0.05) end
if conn then conn:Disconnect() end
if not ok then return "failed: " .. tostring(err) end
return message or "no reply"
end
function Reicht.Claim.AllCodes()
local results = {}
for _, code in ipairs(Config.Codes) do
table.insert(results, ("%s: %s"):format(code, Reicht.Claim.Code(code)))
end
return table.concat(results, "\n")
end
function Reicht.Claim.CheckIn()
local plan = Reicht.GameLib.Api(ReplicatedStorage.LocalData.PlanKData)
local data = plan.GetData()
local claimed = 0
for day, entry in pairs(data.sign or {}) do
if not State.Alive then break end
if type(entry) == "table" and entry.Sign and not entry.Claim then
if plan.TryClaim(tostring(day)) == true then claimed += 1 end
end
end
return claimed
end
function Reicht.TokenShop.BuyAll()
local goodsConfig = Reicht.GameLib.Need(GameConfig.TokenShop.Config)
local exchange = Reicht.Util.Remote("TokenShop", "ExchangeGoodsRF")
local profile = Reicht.Data.Get()
if State.Opt.TokenReveal then
local reveal = Reicht.Util.Remote("TokenShop", "OpenGoodsRE")
local opened = false
for slot, good in pairs(profile.TokenShop and profile.TokenShop.Goods or {}) do
if State.Alive and not good.Open and not good.Exchanged then
reveal:FireServer(tostring(slot))
opened = true
end
end
if opened then
task.wait(0.2)
profile = Reicht.Data.Get(true)
end
end
local bought = 0
for slot, good in pairs(profile.TokenShop and profile.TokenShop.Goods or {}) do
if not State.Alive then break end
local entry = goodsConfig[tonumber(slot)] or goodsConfig[tostring(slot)]
if good.Exchanged or not entry then continue end
if State.Opt.TokenSkipOwned and good.IsHave then continue end
if next(State.Opt.TokenTargets) and not State.Opt.TokenTargets[tostring(slot)] then continue end
if (profile.Token and profile.Token.value or 0) < (entry.Token or 0) then continue end
if not good.Open then continue end
local success = exchange:InvokeServer(tostring(slot))
profile = Reicht.Data.Get(true)
local updated = profile.TokenShop and profile.TokenShop.Goods and profile.TokenShop.Goods[slot]
if success == true or (updated and updated.Exchanged) then bought += 1 end
end
return bought
end
function Reicht.TokenShop.Choices()
local choices, ids = {}, {}
for id, entry in pairs(Reicht.GameLib.Need(GameConfig.TokenShop.Config)) do
local label = ("%s (%d Token)"):format(entry.DisplayName or entry.MonID or tostring(id), entry.Token or 0)
table.insert(choices, label)
ids[label] = tostring(id)
end
table.sort(choices)
return choices, ids
end
function Reicht.SuperLoot.Kill(uuid)
if type(uuid) ~= "string" or State.LootPending[uuid] then return false end
local folder = workspace:FindFirstChild("EnemyFolder") or workspace:FindFirstChild("EnemyFolder_Server")
local enemy = folder and folder:FindFirstChild(uuid)
local hp = enemy and enemy:FindFirstChild("HPValue")
if not hp or type(hp.Value) ~= "number" then return false end
State.LootPending[uuid] = coroutine.running()
local ok, claimed = pcall(function()
local hit = Reicht.GameLib.Api(ReplicatedStorage.Utils.CommunicationUtils).TryGetBindableEvent("Attack", "EnemyHitBE")
if not hit or not hit:IsA("BindableEvent") then error("EnemyHitBE unavailable", 0) end
local attackId = Reicht.Boss.AttackId() or "G_ATK_1"
local info = { SkillID = attackId, IsCrit = State.Opt.AuraCritical, Damage = State.Opt.AuraDamage }
local rounds = math.min(50, math.max(1, math.ceil(hp.Value)))
for _ = 1, rounds do
if not State.Alive then return false end
hit:Fire(uuid, State.Opt.AuraDamage, info)
end
task.wait(0.1)
local superKill = Reicht.Util.FindRemote("SuperLoot", "KillSuperLootRE")
if superKill then superKill:FireServer(uuid) end
task.wait(0.15)
local getOre = Reicht.Util.FindRemote("Stage", "GetOreRF")
if getOre then getOre:InvokeServer(uuid) end
local claimAll = Reicht.Util.FindRemote("Stage", "ClaimedAllOreRE")
if claimAll then claimAll:FireServer() end
return true
end)
State.LootPending[uuid] = nil
if not ok then error(claimed, 0) end
return claimed
end
function Reicht.SuperLoot.KillExisting()
local folders = { workspace:FindFirstChild("EnemyFolder"), workspace:FindFirstChild("EnemyFolder_Server") }
for _, folder in ipairs(folders) do
if not folder then continue end
for _, enemy in ipairs(folder:GetChildren()) do
local enemyId = enemy:GetAttribute("EnemyID")
if type(enemyId) == "string" and enemyId:find("^Super") then
Reicht.SuperLoot.Queue(enemy.Name)
end
end
end
end
function Reicht.SuperLoot.Queue(uuid)
if not State.Alive or type(uuid) ~= "string" or State.LootSeen[uuid] then return end
if #State.LootQueue >= 256 then return end
State.LootSeen[uuid] = true
table.insert(State.LootQueue, uuid)
end
function Reicht.SuperLoot.Step()
local uuid = table.remove(State.LootQueue, 1)
if not uuid then return end
Reicht.SuperLoot.Kill(uuid)
end
function Reicht.SuperLoot.Bind()
table.insert(State.Conns, Reicht.Util.Remote("SuperLoot", "RefreshSuperLootRE").OnClientEvent:Connect(function(_, uuid)
if State.Opt.SuperLootAura then
Reicht.SuperLoot.Queue(uuid)
end
end))
local folder = workspace:FindFirstChild("EnemyFolder")
if folder then
table.insert(State.Conns, folder.ChildRemoved:Connect(function(enemy)
State.LootSeen[enemy.Name] = nil
State.LootPending[enemy.Name] = nil
end))
end
end
function Reicht.Combat.KillAll(force)
local hit = Reicht.GameLib.Api(ReplicatedStorage.Utils.CommunicationUtils).TryGetBindableEvent("Attack", "EnemyHitBE")
if not hit or not hit:IsA("BindableEvent") then error("EnemyHitBE unavailable", 0) end
local damage = State.Opt.AuraDamage
local weaponType = LocalPlayer:GetAttribute("WeaponType")
local attackId = Config.BossAttackIds[weaponType] or "K_ATK_1"
local hitInfo = { SkillID = attackId, IsCrit = State.Opt.AuraCritical, Damage = damage }
local char = LocalPlayer.Character
local origin = char and char:GetPivot().Position
local mapWide = State.Opt.AuraMapWide or (State.Opt.AuraRange == 0)
local range = State.Opt.AuraRange
local burst = math.clamp(State.Opt.AuraBurst or 10, 1, 50)
local targetFilter = State.Opt.AuraTarget or "All"
local killed = 0
local announce = Reicht.Util.FindRemote("Attack", "UseAnyATKRE")
local attackService = Reicht.Util.FindRemote("Attack", "AttackEnemyServiceRE")
local killEnemy = Reicht.Util.FindRemote("Attack", "KillEnemyRE")
local killSuper = Reicht.Util.FindRemote("SuperLoot", "KillSuperLootRE")
local getOre = Reicht.Util.FindRemote("Stage", "GetOreRF")
local folders = { workspace:FindFirstChild("EnemyFolder"), workspace:FindFirstChild("EnemyFolder_Server") }
for _, folder in ipairs(folders) do
if not folder then continue end
local children = folder:GetChildren()
for _, enemy in ipairs(children) do
if not State.Alive or (not force and not (State.Opt.KillAura or State.Opt.AutoBattle)) then
return killed
end
local enemyId = tostring(enemy:GetAttribute("EnemyID") or "")
local isSuper = enemyId:find("^Super") ~= nil
local isBoss = folder.Name == "EnemyFolder_Server"
if targetFilter == "Normal" and (isSuper or isBoss) then continue end
if targetFilter == "Super" and not isSuper then continue end
if targetFilter == "Boss" and not isBoss then continue end
local hp = enemy:FindFirstChild("HPValue")
if hp and type(hp.Value) == "number" and hp.Value <= 0 then continue end
if enemy:GetAttribute("Dead") == true then continue end
if not mapWide and origin and enemy:IsA("Model") then
if (enemy:GetPivot().Position - origin).Magnitude > range then continue end
end
local name = enemy.Name
local hitRounds = isSuper and math.min(burst, math.max(1, math.ceil(hp and hp.Value or 10))) or 1
for _ = 1, hitRounds do
hit:Fire(name, damage, hitInfo)
end
if isSuper then
if killSuper then pcall(killSuper.FireServer, killSuper, name) end
if getOre then pcall(getOre.InvokeServer, getOre, name) end
else
if killEnemy then pcall(killEnemy.FireServer, killEnemy, name) end
end
killed += 1
if announce and attackService then
local now = workspace:GetServerTimeNow()
pcall(announce.FireServer, announce, attackId, now)
pcall(attackService.FireServer, attackService, { name }, { Phase = 1, SkillID = attackId, Attacker = LocalPlayer }, now)
end
if State.Opt.AutoSkills and (killed == 1 or killed % 5 == 0) then
local skillEvent = Reicht.GameLib.Api(ReplicatedStorage.Utils.CommunicationUtils).TryGetBindableEvent("Skill", "UseSkillByIndexBE")
if skillEvent then
pcall(skillEvent.Fire, skillEvent, 1)
pcall(skillEvent.Fire, skillEvent, 2)
else
local useSkillRE = Reicht.Util.FindRemote("Attack", "UseAnySkillRE")
local backpackData = Reicht.GameLib.Require(ReplicatedStorage.LocalData.BackpackData)
if useSkillRE and backpackData and backpackData.GetWeaponSkillIDByIndex then
local now = workspace:GetServerTimeNow()
for sIndex = 1, 2 do
local sId = backpackData.GetWeaponSkillIDByIndex(sIndex)
if sId then
pcall(useSkillRE.FireServer, useSkillRE, sId, sIndex, now)
end
end
end
end
end
if not (force or State.Opt.InstantKillAll) and killed >= State.Opt.AuraBatch then break end
end
if not (force or State.Opt.InstantKillAll) and killed >= State.Opt.AuraBatch then break end
end
if State.Opt.AutoCollectDrops then
local claimAll = Reicht.Util.FindRemote("Stage", "ClaimedAllOreRE")
if claimAll then pcall(claimAll.FireServer, claimAll) end
end
return killed
end
function Reicht.Combat.WipeMapNow()
local hit = Reicht.GameLib.Api(ReplicatedStorage.Utils.CommunicationUtils).TryGetBindableEvent("Attack", "EnemyHitBE")
local killEnemy = Reicht.Util.FindRemote("Attack", "KillEnemyRE")
local killSuper = Reicht.Util.FindRemote("SuperLoot", "KillSuperLootRE")
local getOre = Reicht.Util.FindRemote("Stage", "GetOreRF")
local claimAll = Reicht.Util.FindRemote("Stage", "ClaimedAllOreRE")
local killed = 0
local folders = { workspace:FindFirstChild("EnemyFolder"), workspace:FindFirstChild("EnemyFolder_Server") }
for _, folder in ipairs(folders) do
if not folder then continue end
local children = folder:GetChildren()
for _, enemy in ipairs(children) do
local enemyId = tostring(enemy:GetAttribute("EnemyID") or "")
local isSuper = enemyId:find("^Super") ~= nil
local name = enemy.Name
if hit and hit:IsA("BindableEvent") then
hit:Fire(name, 999999999999, { SkillID = "K_ATK_1", IsCrit = true, Damage = 999999999999 })
end
if isSuper then
if killSuper then pcall(killSuper.FireServer, killSuper, name) end
if getOre then pcall(getOre.InvokeServer, getOre, name) end
else
if killEnemy then pcall(killEnemy.FireServer, killEnemy, name) end
end
killed += 1
end
end
if claimAll then pcall(claimAll.FireServer, claimAll) end
return killed
end
function Reicht.Combat.Start()
if State.AuraThread then return end
State.AuraThread = task.defer(function()
while State.Alive and State.Opt.KillAura do
Reicht.Scheduler.Run("KillAura", function()
Reicht.Combat.KillAll(false)
end)
task.wait(State.Opt.AuraInterval)
end
State.AuraThread = nil
end)
end
function Reicht.Guard.HookCalculations()
if State.RestoreCalculations then return true end
local calcUtils = Reicht.GameLib.Require(ReplicatedStorage.Utils.CalculateUtils)
if not calcUtils then return false end
local origCrit = calcUtils.CCCrit
local origDefence = calcUtils.CCPlrDefence
local origDamage = calcUtils.CCPlrDamage
local origOnceDamage = calcUtils.CCPlrOnceDamage
local origEnemyDamage = calcUtils.CCEnemyDamage
if type(origCrit) == "function" then
calcUtils.CCCrit = function(player)
if player == LocalPlayer and State.Opt.GuaranteedCrit then
return 1.0
end
return origCrit(player)
end
end
if type(origDefence) == "function" then
calcUtils.CCPlrDefence = function(player)
if player == LocalPlayer and State.Opt.GodMode then
return 1e12
end
return origDefence(player)
end
end
if type(origDamage) == "function" then
calcUtils.CCPlrDamage = function(player, info)
local dmg = origDamage(player, info)
local mult = State.Opt.DamageMultiplier
if player == LocalPlayer and mult and mult > 1 then
return dmg * mult
end
return dmg
end
end
if type(origOnceDamage) == "function" then
calcUtils.CCPlrOnceDamage = function(player)
local dmg = origOnceDamage(player)
local mult = State.Opt.DamageMultiplier
if player == LocalPlayer and mult and mult > 1 then
return dmg * mult
end
return dmg
end
end
if type(origEnemyDamage) == "function" then
calcUtils.CCEnemyDamage = function(info)
if State.Opt.GodMode then
return 0
end
return origEnemyDamage(info)
end
end
State.RestoreCalculations = function()
if type(origCrit) == "function" then calcUtils.CCCrit = origCrit end
if type(origDefence) == "function" then calcUtils.CCPlrDefence = origDefence end
if type(origDamage) == "function" then calcUtils.CCPlrDamage = origDamage end
if type(origOnceDamage) == "function" then calcUtils.CCPlrOnceDamage = origOnceDamage end
if type(origEnemyDamage) == "function" then calcUtils.CCEnemyDamage = origEnemyDamage end
State.RestoreCalculations = nil
end
return true
end
function Reicht.Guard.UnhookCalculations()
if State.RestoreCalculations then State.RestoreCalculations() end
end
function Reicht.Guard.HookDamage()
if State.RestoreDamage then return true end
local hpCtrl = Reicht.GameLib.Require(ReplicatedStorage.CTRL.HPCTRL)
local damageOnce = hpCtrl and hpCtrl.DamageOnce
local updateHP = hpCtrl and hpCtrl.UpdateHPValue
if type(damageOnce) ~= "function" then return false end
hpCtrl.DamageOnce = function(target, damage)
if target == LocalPlayer and State.Opt.GodMode then return false end
return damageOnce(target, damage)
end
if type(updateHP) == "function" then
hpCtrl.UpdateHPValue = function(target, newHp)
if target == LocalPlayer and State.Opt.GodMode then
return 0, false
end
return updateHP(target, newHp)
end
end
local hpBallRF = Reicht.Util.FindRemote("WorldBoss", "TryGetHPBallRF")
local origHpBallInvoke = hpBallRF and hpBallRF.OnClientInvoke
if hpBallRF and hpBallRF:IsA("RemoteFunction") then
hpBallRF.OnClientInvoke = function(heal)
if State.Opt.GodMode or State.Opt.AutoWorldBoss then
if hpCtrl then
local maxHp = hpCtrl.GetMaxHP(LocalPlayer) or 100
hpCtrl.SetCurrentHP(LocalPlayer, maxHp)
end
return true
end
if origHpBallInvoke then return origHpBallInvoke(heal) end
return true
end
end
State.RestoreDamage = function()
hpCtrl.DamageOnce = damageOnce
if type(updateHP) == "function" then hpCtrl.UpdateHPValue = updateHP end
if hpBallRF then hpBallRF.OnClientInvoke = origHpBallInvoke end
State.RestoreDamage = nil
end
return true
end
function Reicht.Guard.UnhookDamage()
if State.RestoreDamage then State.RestoreDamage() end
end
function Reicht.Guard.HookNamecall()
if State.RestoreNamecall then return true end
local compat = Reicht.Compat
if not (compat and compat.Caps.Namecall) then return false end
local lostOre = Reicht.Util.FindRemote("Stage", "LostAllOreRF")
local setPlrDead = Reicht.Util.FindRemote("Player", "SetPlrDeadRE")
local devKick = Reicht.Util.FindRemote("Dev", "KickPlayerRE")
local original, restore
original, restore = compat.HookMeta(game, "__namecall", function(self, ...)
local method = getnamecallmethod()
if method == "InvokeServer" then
if self == lostOre and (State.Opt.KeepOre or State.Opt.GodMode) then
return {}
end
elseif method == "FireServer" then
if self == setPlrDead and State.Opt.GodMode then
local args = { ... }
if args[1] == true then
return
end
elseif self == devKick and (State.Opt.BaitShield ~= false) then
warn("[LootToForge] Intercepted honeypot kick remote")
return
end
end
return original(self, ...)
end)
if not original then return false end
State.RestoreNamecall = function()
State.RestoreNamecall = nil
restore()
end
return true
end
function Reicht.Guard.HookOreLoss()
return Reicht.Guard.HookNamecall()
end
function Reicht.Guard.UnhookOreLoss()
if State.RestoreNamecall then State.RestoreNamecall() end
end
function Reicht.Guard.HookAntiStun()
if State.RestoreAntiStun then return true end
local plrUtils = Reicht.GameLib.Require(ReplicatedStorage.Utils.LocalPlayerUtils)
local charUtils = Reicht.GameLib.Require(ReplicatedStorage.SkillSystemNew.Utils.CharUtils)
local debuffUtils = Reicht.GameLib.Require(ReplicatedStorage.Utils.DebuffUtils)
local origDisablePlrAction = plrUtils and plrUtils.DisablePlrAction
local origSetWalkSpeedNum = charUtils and charUtils.SetWalkSpeedNum
local origAddBuff = debuffUtils and debuffUtils.AddBuff
if type(origDisablePlrAction) == "function" then
plrUtils.DisablePlrAction = function(p2)
if State.Opt.AntiStun then
LocalPlayer:SetAttribute("StopCharAnim", nil)
LocalPlayer:SetAttribute("StopAllAction", nil)
local char = LocalPlayer.Character
if char and char:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.Anchored = false
end
return
end
return origDisablePlrAction(p2)
end
end
if type(origSetWalkSpeedNum) == "function" then
charUtils.SetWalkSpeedNum = function(target, speed, layout, tag)
if State.Opt.AntiStun and (speed == 0 or (speed and speed < 16)) then
local char = LocalPlayer.Character
if target == LocalPlayer or target == char then
local desired = (State.Opt.SpeedOn and State.Opt.WalkSpeed) or 16
return origSetWalkSpeedNum(target, desired, layout, tag)
end
end
return origSetWalkSpeedNum(target, speed, layout, tag)
end
end
if type(origAddBuff) == "function" then
debuffUtils.AddBuff = function(target, buffId, duration, config)
local char = LocalPlayer.Character
if (target == LocalPlayer or target == char) and State.Opt.AntiDebuff then
return "IMMUNE_" .. tostring(buffId)
end
return origAddBuff(target, buffId, duration, config)
end
end
local conn = LocalPlayer:GetAttributeChangedSignal("StopAllAction"):Connect(function()
if State.Opt.AntiStun and LocalPlayer:GetAttribute("StopAllAction") then
LocalPlayer:SetAttribute("StopAllAction", nil)
LocalPlayer:SetAttribute("StopCharAnim", nil)
local char = LocalPlayer.Character
if char and char:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.Anchored = false
end
end
end)
State.RestoreAntiStun = function()
if conn then conn:Disconnect() end
if type(origDisablePlrAction) == "function" then plrUtils.DisablePlrAction = origDisablePlrAction end
if type(origSetWalkSpeedNum) == "function" then charUtils.SetWalkSpeedNum = origSetWalkSpeedNum end
if type(origAddBuff) == "function" then debuffUtils.AddBuff = origAddBuff end
State.RestoreAntiStun = nil
end
return true
end
function Reicht.Guard.UnhookAntiStun()
if State.RestoreAntiStun then State.RestoreAntiStun() end
end
function Reicht.Guard.HookNoSkillCD()
if State.RestoreNoSkillCD then return true end
local skillCtrl = Reicht.GameLib.Require(ReplicatedStorage.SkillSystemNew.SkillCTRL)
if not skillCtrl then return false end
local origUseSkill = skillCtrl.UseSkill
local origATK = skillCtrl.ATK
if type(origUseSkill) == "function" then
skillCtrl.UseSkill = function(player, skillId, options)
if player == LocalPlayer and State.Opt.NoSkillCD then
if options and options.SkillIndex then
LocalPlayer:SetAttribute(options.SkillIndex .. "_SkillNextTick", 0)
end
LocalPlayer:SetAttribute("UsingSkillID", nil)
end
return origUseSkill(player, skillId, options)
end
end
if type(origATK) == "function" then
skillCtrl.ATK = function(player, options)
if player == LocalPlayer and State.Opt.NoSkillCD then
LocalPlayer:SetAttribute("UsingSkillID", nil)
end
return origATK(player, options)
end
end
local conns = {}
for i = 1, 6 do
local attrName = i .. "_SkillNextTick"
local c = LocalPlayer:GetAttributeChangedSignal(attrName):Connect(function()
if State.Opt.NoSkillCD and (LocalPlayer:GetAttribute(attrName) or 0) > 0 then
LocalPlayer:SetAttribute(attrName, 0)
end
end)
table.insert(conns, c)
end
State.RestoreNoSkillCD = function()
for _, c in ipairs(conns) do c:Disconnect() end
if type(origUseSkill) == "function" then skillCtrl.UseSkill = origUseSkill end
if type(origATK) == "function" then skillCtrl.ATK = origATK end
State.RestoreNoSkillCD = nil
end
return true
end
function Reicht.Guard.UnhookNoSkillCD()
if State.RestoreNoSkillCD then State.RestoreNoSkillCD() end
end
function Reicht.Guard.Stop()
Reicht.Guard.UnhookDamage()
Reicht.Guard.UnhookCalculations()
Reicht.Guard.UnhookOreLoss()
Reicht.Guard.UnhookAntiStun()
Reicht.Guard.UnhookNoSkillCD()
end
function Reicht.Race.Choices()
local classConfig = Reicht.GameLib.Need(GameConfig.Class.Config)
local show = Reicht.GameLib.Need(GameConfig.Class.Show)
local ids = {}
for classId in pairs(classConfig) do
table.insert(ids, classId)
end
table.sort(ids, function(a, b) return classConfig[a].Weight < classConfig[b].Weight end)
local labels, idByLabel = {}, {}
for _, classId in ipairs(ids) do
local label = ("%s (%s)"):format(show[classId] and show[classId].DisplayName or classId, classConfig[classId].Rarity)
idByLabel[label] = classId
table.insert(labels, label)
end
return labels, idByLabel
end
function Reicht.Race.EquipBest()
local classData = Reicht.Data.Get().Class
local classConfig = Reicht.GameLib.Need(GameConfig.Class.Config)
local bestSlot, bestWeight = nil, math.huge
for slot, classId in pairs(classData.have) do
local weight = classConfig[classId] and classConfig[classId].Weight or math.huge
if weight < bestWeight then bestSlot, bestWeight = slot, weight end
end
if not bestSlot or tostring(bestSlot) == tostring(classData.equiped) then return false end
Reicht.Util.Remote("Class", "ChangeEquipedIndexRE"):FireServer(tostring(bestSlot))
Reicht.Data.Get(true)
return true
end
function Reicht.Race.RarityLevel(rarity)
local ok, level = pcall(Reicht.GameLib.Api(GameConfig.Rarity.Helper).GetRarityLevel, rarity)
return ok and tonumber(level) or 0
end
function Reicht.Race.Level(classId)
local info = classId and Reicht.GameLib.Need(GameConfig.Class.Config)[classId]
return info and Reicht.Race.RarityLevel(info.Rarity) or 0
end
function Reicht.Race.RarityChoices()
local seen, levels = {}, {}
for _, info in pairs(Reicht.GameLib.Need(GameConfig.Class.Config)) do
if seen[info.Rarity] then continue end
seen[info.Rarity] = true
table.insert(levels, { info.Rarity, Reicht.Race.RarityLevel(info.Rarity) })
end
table.sort(levels, function(a, b) return a[2] < b[2] end)
local labels, byLabel = { "Off" }, {}
for _, pair in ipairs(levels) do
local label = pair[1] .. "+"
table.insert(labels, label)
byLabel[label] = pair[2]
end
return labels, byLabel
end
function Reicht.Race.Stars(classId)
local record = Reicht.GameLib.Need(ReplicatedStorage.LocalData.ClassData).GetData().recored
local entry = record and record[classId]
return entry and tonumber(entry.Level) or 0
end
function Reicht.Race.IsGoal(classId)
if not classId then return false end
local wanted = State.Opt.RaceTargets[classId]
or (State.Opt.RaceMinLevel ~= nil and Reicht.Race.Level(classId) >= State.Opt.RaceMinLevel)
return wanted and Reicht.Race.Stars(classId) >= (State.Opt.RaceStar or 0)
end
function Reicht.Race.PickSlot(classData)
local slot = State.Opt.RaceSlot == "Equipped" and tostring(classData.equiped) or State.Opt.RaceSlot:match("%d+")
if not (slot and classData.have[slot]) then return nil, "that slot is not unlocked" end
if classData.lock and classData.lock[slot] then return nil, "that slot is locked" end
return slot
end
function Reicht.Race.MuteAnim(muted)
if not Reicht.Compat.Caps.Connections then return end
local event = Reicht.Util.Remote("Class", "ShowLuckResultRE").OnClientEvent
for _, conn in ipairs(getconnections(event)) do
if muted then conn:Disable() else conn:Enable() end
end
end
function Reicht.Race.EnsureRolls(classStore)
if (classStore.GetData().luckTimes or 0) > 0 then return true end
if not State.Opt.RaceBuyRolls then return false end
local config = Reicht.GameLib.Need(GameConfig.Season.GoodsConfig)
local season = Reicht.Season.Current()
for id, good in pairs(config) do
if good.ID == "ClassRoll" and season and (season.SeasonCoin or 0) >= good.NeedSeasonCoin
and ((season.Goods or {})[id] or 0) < (good.Store or 1) then
Reicht.Util.Remote("Season", "ExchangeGoodsRE"):FireServer(id)
local deadline = os.clock() + Config.RaceResultWait * 2
repeat task.wait(0.1) until not State.Alive or (classStore.GetData().luckTimes or 0) > 0 or os.clock() >= deadline
return (classStore.GetData().luckTimes or 0) > 0
end
end
return false
end
function Reicht.Race.RollUntil()
local classStore = Reicht.GameLib.Need(ReplicatedStorage.LocalData.ClassData)
local roll = Reicht.Util.Remote("Class", "LuckOnceRE")
local protectLevel = Reicht.Race.RarityLevel(Config.RaceProtectRarity)
State.RaceRolls = 0
while State.Alive and State.Opt.AutoRace do
local classData = classStore.GetData()
local slot, why = Reicht.Race.PickSlot(classData)
if not slot then return "blocked", why end
local current = classData.have[slot]
if Reicht.Race.IsGoal(current) then
if State.Opt.RaceLock then Reicht.Util.Remote("Class", "SetIndexLockRE"):FireServer(slot) end
return "got", current
end
if State.Opt.RaceProtect and Reicht.Race.Level(current) >= protectLevel then
return "blocked", "this slot holds a Mythic+ race"
end
if not Reicht.Race.EnsureRolls(classStore) then return "empty" end
roll:FireServer(slot)
State.RaceRolls += 1
local lastRolls = classStore.GetData().luckTimes
local deadline = os.clock() + Config.RaceResultWait
repeat task.wait() until (classStore.GetData().luckTimes or 0) ~= lastRolls or classStore.GetData().have[slot] ~= current or os.clock() > deadline
task.wait(Config.RaceRollDelay)
end
return "stopped"
end
function Reicht.Race.RollLavakin()
local classStore = Reicht.GameLib.Need(ReplicatedStorage.LocalData.ClassData)
if not classStore then return false, "ClassData not available" end
local classData = classStore.GetData()
local slot = State.Opt.RaceSlot == "Equipped" and tostring(classData.equiped) or State.Opt.RaceSlot:match("%d+")
if not (slot and classData.have[slot]) then return false, "Slot is not unlocked" end
if classData.have[slot] == "Class_10" then
return true, "Already Lavakin (Eternal)!"
end
State.Opt.RaceTargets = { Class_10 = true }
State.Opt.RaceStar = 0
State.Opt.AutoRace = true
return true
end
function Reicht.Pet.Store(refresh)
local profile = Reicht.Data.Get(refresh)
return profile and profile.Pet or {}
end
function Reicht.Pet.Rarity(petId)
local cfg = Reicht.GameLib.Need(GameConfig.Pet.Config)[petId]
return cfg and cfg.Rarity
end
function Reicht.Pet.Score(entry, focus)
if type(entry) ~= "table" or entry.Type ~= "Pet" then return -1 end
local cfg = Reicht.GameLib.Need(GameConfig.Pet.Config)[entry.ID]
if not cfg then return 0 end
local rarityLv = Reicht.Race.RarityLevel(cfg.Rarity)
local gradeMulti = ({ Common = 1, Golden = 2, Diamond = 4, Rainbow = 6 })[entry.Grade] or 1
local boostSum = 0
local trainBoost = 0
local balanceUtils = Reicht.GameLib.Api(ReplicatedStorage.Utils.BalanceUtils)
local ok, boosts = pcall(balanceUtils.GetPetBoosts, LocalPlayer, entry)
if ok and type(boosts) == "table" then
trainBoost = boosts.Train or 0
for _, val in pairs(boosts) do
if type(val) == "number" then boostSum += val end
end
end
if focus == "Train" then
return trainBoost * 100000 + gradeMulti * 1000 + (entry.Level or 1) * 10
end
local skills = type(entry.ExtraSkill) == "table" and #entry.ExtraSkill or 0
return rarityLv * 10000 + boostSum * gradeMulti * 1000 + (entry.Level or 1) * 10 + skills * 500 + Reicht.Util.Tier(entry.ID)
end
function Reicht.Pet.ResetVFX()
pcall(function()
local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local openGui = gui and gui:FindFirstChild("OpenEggGui")
if openGui and openGui.Enabled then
local vfx = ReplicatedStorage:FindFirstChild("GuiUtils")
and ReplicatedStorage.GuiUtils:FindFirstChild("PetGUI")
and ReplicatedStorage.GuiUtils.PetGUI:FindFirstChild("OpenEggVFX")
if vfx then Reicht.GameLib.Api(vfx).Reset() end
end
end)
end
function Reicht.Pet.MuteAnim(muted)
if Reicht.Compat and Reicht.Compat.Caps.Connections then
local remote = Reicht.Util.FindRemote("Pet", "ShowLuckResult")
if remote and remote:IsA("RemoteEvent") then
for _, conn in ipairs(getconnections(remote.OnClientEvent)) do
if muted then conn:Disable() else conn:Enable() end
end
end
end
if muted then Reicht.Pet.ResetVFX() end
end
function Reicht.Pet.Bind()
local remote = Reicht.Util.FindRemote("Pet", "ShowLuckResult")
if remote and remote:IsA("RemoteEvent") then
table.insert(State.Conns, remote.OnClientEvent:Connect(function()
if State.Opt.SkipEggAnim then
task.defer(Reicht.Pet.ResetVFX)
task.delay(0.15, Reicht.Pet.ResetVFX)
end
end))
end
end
function Reicht.Pet.Counts(petStore)
petStore = petStore or Reicht.Pet.Store()
local pets, eggs = 0, 0
for _, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" then
pets += 1
elseif entry.Type == "Egg" and not entry.HatchReadyTick then
eggs += 1
end
end
return pets, eggs
end
function Reicht.Pet.TrimEggs(preferEggId)
local petStore = Reicht.Pet.Store()
local byId, totalEggs = {}, 0
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Egg" and not entry.HatchReadyTick then
byId[entry.ID] = byId[entry.ID] or {}
table.insert(byId[entry.ID], uuid)
totalEggs += 1
end
end
local deleteRE = Reicht.Util.Remote("Pet", "DeleteRE")
local deleted = 0
local keepLimit = math.max(1, State.Opt.KeepPerEgg or 10)
local maxEggs = petStore.maxEggNum or 25
for eggId, list in pairs(byId) do
local limit = keepLimit
if preferEggId and eggId ~= preferEggId and totalEggs >= maxEggs - 3 then
limit = math.min(limit, math.max(2, math.floor(maxEggs / 4)))
end
for i = limit + 1, #list do
deleteRE:FireServer(list[i])
deleted += 1
totalEggs -= 1
end
end
if deleted > 0 then Reicht.Data.Get(true) end
return deleted
end
function Reicht.Pet.CleanBag()
local petStore = Reicht.Pet.Store()
local protected = {}
for _, uuid in pairs(petStore.equiped or {}) do
protected[uuid] = true
end
local allPets = {}
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" then
if entry.DeployStartTick then protected[uuid] = true end
table.insert(allPets, { uuid = uuid, entry = entry, score = Reicht.Pet.Score(entry) })
end
end
table.sort(allPets, function(a, b) return a.score > b.score end)
for i = 1, math.min(#allPets, math.max(1, State.Opt.KeepBestPets or 6)) do
protected[allPets[i].uuid] = true
end
local deleteRE = Reicht.Util.Remote("Pet", "DeleteRE")
local deletedPets = 0
for _, item in ipairs(allPets) do
local rarity = Reicht.Pet.Rarity(item.entry.ID)
if not protected[item.uuid] and State.Opt.DeletePetRarities[rarity] then
deleteRE:FireServer(item.uuid)
deletedPets += 1
end
end
local deletedEggs = State.Opt.AutoDeleteEggs and Reicht.Pet.TrimEggs() or 0
if deletedPets > 0 then Reicht.Data.Get(true) end
return deletedPets, deletedEggs
end
function Reicht.Pet.HatchStep()
if State.Opt.SkipEggAnim then
Reicht.Pet.MuteAnim(true)
end
local petStore = Reicht.Pet.Store()
local now = (workspace.GetServerTimeNow and workspace:GetServerTimeNow()) or (workspace:GetAttribute("ServerTime") or os.time())
local petCount = Reicht.Pet.Counts(petStore)
local maxPet = petStore.maxPetNum or 25
if petCount >= maxPet - 2 or State.Opt.AutoSellPet then
Reicht.Pet.CleanBag()
petStore = Reicht.Pet.Store(true)
petCount = Reicht.Pet.Counts(petStore)
end
local openRE = Reicht.Util.Remote("Pet", "TryOpenEggRE")
local hatchRE = Reicht.Util.Remote("Pet", "TryHatchEggRE")
local opened = 0
for _, uuid in pairs(petStore.hatched or {}) do
local entry = petStore.have and petStore.have[uuid]
if entry and (entry.HatchReadyTick or 0) <= now and petCount + opened < maxPet then
openRE:FireServer(uuid)
opened += 1
end
end
if opened > 0 then
Reicht.Pet.ResetVFX()
petStore = Reicht.Pet.Store(true)
petCount = Reicht.Pet.Counts(petStore)
end
local usedSlots = 0
for _ in pairs(petStore.hatched or {}) do usedSlots += 1 end
local maxHatch = petStore.maxHatchNum or 3
local freeSlots = math.max(0, maxHatch - usedSlots)
local hatched = 0
if freeSlots > 0 then
local targetEggId = "Egg2"
if State.Opt.TargetPet and State.PetTargetLabels and State.PetTargetLabels[State.Opt.TargetPet] then
local pId = State.PetTargetLabels[State.Opt.TargetPet]
local eggCfg = Reicht.GameLib.Need(GameConfig.Egg.Config)
for eggId, data in pairs(eggCfg or {}) do
if data.Loot then
for petId, _ in pairs(data.Loot) do
if petId == pId then targetEggId = eggId; break end
end
end
end
end
local candidates = {}
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Egg" and not entry.HatchReadyTick then
table.insert(candidates, {
uuid = uuid,
id = entry.ID,
isTarget = (entry.ID == targetEggId),
tier = Reicht.Util.Tier(entry.ID)
})
end
end
table.sort(candidates, function(a, b)
if a.isTarget ~= b.isTarget then return a.isTarget end
if State.Opt.HatchBestFirst then return a.tier > b.tier end
return a.tier < b.tier
end)
for i = 1, math.min(freeSlots, #candidates) do
hatchRE:FireServer(candidates[i].uuid)
hatched += 1
end
end
if hatched > 0 or opened > 0 then
Reicht.Data.Get(true)
Reicht.Pet.ResetVFX()
end
if State.Opt.AutoDeleteEggs then Reicht.Pet.TrimEggs() end
return opened, hatched
end
function Reicht.Pet.Choices()
local labels, ids = {}, {}
local petFolder = GameConfig:FindFirstChild("Pet")
local petShow = petFolder and petFolder:FindFirstChild("Show") and Reicht.GameLib.Require(petFolder.Show)
local petCfg = petFolder and petFolder:FindFirstChild("Config") and Reicht.GameLib.Require(petFolder.Config)
if petShow or petCfg then
local petIds = {}
local allPetKeys = {}
if petShow then for id in pairs(petShow) do allPetKeys[id] = true end end
if petCfg then for id in pairs(petCfg) do allPetKeys[id] = true end end
for id in pairs(allPetKeys) do petIds[#petIds + 1] = id end
table.sort(petIds, function(a, b)
local rA = petCfg and petCfg[a] and petCfg[a].Rarity or ""
local rB = petCfg and petCfg[b] and petCfg[b].Rarity or ""
local lvA = Reicht.Race.RarityLevel(rA)
local lvB = Reicht.Race.RarityLevel(rB)
if lvA ~= lvB then return lvA > lvB end
return Reicht.Util.Tier(a) > Reicht.Util.Tier(b)
end)
for _, id in ipairs(petIds) do
local name = petShow and petShow[id] and (petShow[id].DisplayName or petShow[id].Name) or (petCfg and petCfg[id] and petCfg[id].Name) or id
local rarity = petCfg and petCfg[id] and petCfg[id].Rarity or "Pet"
local label = "[" .. rarity .. "] " .. name .. " (" .. id .. ")"
labels[#labels + 1] = label
ids[label] = id
end
end
State.PetTargetLabels = ids
return labels
end
function Reicht.Pet.LockAllGodPets()
local petStore = Reicht.Pet.Store(true)
local lockRE = Reicht.Util.Remote("Pet_Server", "SetUUIDLockRE")
local locked = 0
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" and not (entry.Lock or entry.Locked) then
local rarity = Reicht.Pet.Rarity(entry.ID)
local rarityLv = Reicht.Race.RarityLevel(rarity)
if rarityLv >= 4 or table.find(petStore.equiped or {}, uuid) then
lockRE:FireServer(uuid)
locked += 1
end
end
end
return locked
end
function Reicht.Pet.GradeUpAll()
local gradeLevel = { Common = 0, Golden = 1, Diamond = 2, Rainbow = 3 }
local upgradeRF = Reicht.Util.FindRemote("Pet_Server", "TryUpGradePetRF")
if not upgradeRF then return 0 end
local unlockRE = Reicht.Util.Remote("Pet_Server", "SetUUIDLockRE")
local petStore = Reicht.Pet.Store(true)
local equipped = {}
for _, uuid in ipairs(petStore.equiped or {}) do equipped[uuid] = true end
local upgraded = 0
local gradeTargets = {
{ name = "Golden", level = 1 },
{ name = "Diamond", level = 2 },
{ name = "Rainbow", level = 3 },
}
for _, target in ipairs(gradeTargets) do
petStore = Reicht.Pet.Store(true)
local targetGradeName = target.name
local targetGradeLevel = target.level
local byId = {}
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet"
and not equipped[uuid]
and (gradeLevel[entry.Grade or "Common"] or 0) == targetGradeLevel - 1
then
local bucket = byId[entry.ID] or {}
bucket[#bucket + 1] = uuid
byId[entry.ID] = bucket
end
end
for _, uuids in pairs(byId) do
while #uuids >= 5 do
local batch = {}
for i = 1, 5 do
local u = uuids[i]
batch[u] = true
local petItem = petStore.have and petStore.have[u]
if petItem and (petItem.Lock or petItem.Locked) then
unlockRE:FireServer(u)
end
end
local ok, res = pcall(function()
return upgradeRF:InvokeServer(batch, targetGradeName)
end)
if ok and res == true then upgraded += 1 end
for _ = 1, 5 do table.remove(uuids, 1) end
task.wait(0.04)
end
end
end
if upgraded > 0 then
Reicht.Data.Get(true)
Reicht.Pet.EquipBest()
Reicht.Pet.FeedAllMax()
end
return upgraded
end
function Reicht.Pet.CraftRainbowGod(targetPetId)
targetPetId = targetPetId or "Any"
local rf = Reicht.Util.Remote("Season", "LuckPetRF")
local upgradeRF = Reicht.Util.FindRemote("Pet_Server", "TryUpGradePetRF")
if not (rf and upgradeRF) then return false, "Required remotes missing" end
local deleteRE = Reicht.Util.Remote("Pet_Server", "DeleteRE")
local lockRE = Reicht.Util.Remote("Pet_Server", "SetUUIDLockRE")
local equipRE = Reicht.Util.Remote("Pet_Server", "IsEquipPetRE")
local store = Reicht.Pet.Store(true)
for _, p in pairs(store.have or {}) do
if (targetPetId == "Any" or p.ID == targetPetId) and p.Grade == "Rainbow" then
Reicht.Pet.EquipBest()
Reicht.Pet.FeedAllMax()
return true, "Already own Rainbow " .. p.ID
end
end
local deadline = os.clock() + 45
local created = false
while State.Alive and os.clock() < deadline and not created do
local coins = Reicht.Season.Coins()
if coins < 2000 then
Reicht.Tower.FarmCoins(4000)
end
store = Reicht.Pet.Store(true)
local petCount = 0
for _, it in pairs(store.have or {}) do
if it.Type == "Pet" or it.Type == "Egg" then petCount += 1 end
end
if petCount >= 21 and deleteRE then
for u, it in pairs(store.have or {}) do
if not (it.Lock or it.Locked) and not table.find(store.equiped or {}, u) then
if it.Type == "Egg" or it.ID == "Event1_1" or it.ID == "Event1_2" then
deleteRE:FireServer(u)
end
end
end
task.wait(0.2)
end
for _ = 1, 10 do
if not State.Alive then break end
local ok, rolledId = pcall(function() return rf:InvokeServer() end)
if ok and rolledId == "Event1_4" then
task.wait(0.15)
local fresh = Reicht.Pet.Store(true)
for u, it in pairs(fresh.have or {}) do
if it.ID == "Event1_4" and not (it.Lock or it.Locked) then
if lockRE then lockRE:FireServer(u) end
if equipRE then equipRE:FireServer(u, true) end
end
end
end
task.wait(0.015)
end
Reicht.Pet.GradeUpAll()
store = Reicht.Pet.Store(true)
for _, p in pairs(store.have or {}) do
if (targetPetId == "Any" or p.ID == targetPetId) and p.Grade == "Rainbow" then
created = true
targetPetId = p.ID
break
end
end
end
Reicht.Pet.EquipBest()
Reicht.Pet.FeedAllMax()
return created, created and ("Crafted Rainbow %s (6x Multiplier, +612%% Train)!"):format(targetPetId) or "Fusing in progress (click again to continue)"
end
function Reicht.Pet.RainbowGodStep()
if not State.Opt.AutoRainbowPet then return end
local coins = Reicht.Season.Coins()
if coins < 1600 then
Reicht.Tower.FarmCoins(3000)
end
local rf = Reicht.Util.Remote("Season", "LuckPetRF")
for _ = 1, 6 do
pcall(function() return rf:InvokeServer() end)
task.wait(0.015)
end
Reicht.Pet.GradeUpAll()
Reicht.Pet.EquipBest()
Reicht.Pet.FeedAllMax()
end
function Reicht.Pet.FarmAndHatchTarget(targetPetId, neededCount)
neededCount = math.max(1, math.floor(neededCount or 1))
if targetPetId == "Event1" or targetPetId:find("^Event1") then
local rf = Reicht.Util.Remote("Season", "LuckPetRF")
if not rf then return 0, "Season LuckPet remote unavailable" end
local deleteRE = Reicht.Util.Remote("Pet_Server", "DeleteRE")
local lockRE = Reicht.Util.Remote("Pet_Server", "SetUUIDLockRE")
local equipRE = Reicht.Util.Remote("Pet_Server", "IsEquipPetRE")
local acquired = 0
local deadline = os.clock() + 30
while State.Alive and acquired < neededCount and os.clock() < deadline do
local curCoin = Reicht.Season.Coins()
if curCoin < 400 then
Reicht.Tower.FarmCoins(2000)
end
local store = Reicht.Pet.Store(true)
local petCount = 0
for _, it in pairs(store.have or {}) do
if it.Type == "Pet" or it.Type == "Egg" then petCount += 1 end
end
if petCount >= 21 and deleteRE then
for u, it in pairs(store.have or {}) do
if not (it.Lock or it.Locked) and not table.find(store.equiped or {}, u) then
if it.Type == "Egg" or it.ID == "Event1_1" or it.ID == "Event1_2" then
deleteRE:FireServer(u)
end
end
end
task.wait(0.2)
end
local ok, petId = pcall(function() return rf:InvokeServer() end)
if ok and petId then
if targetPetId == "Event1" or petId == targetPetId then
acquired += 1
end
if petId == "Event1_4" or targetPetId == petId then
task.wait(0.2)
local freshStore = Reicht.Pet.Store(true)
for u, it in pairs(freshStore.have or {}) do
if it.ID == petId and not (it.Lock or it.Locked) then
if lockRE then lockRE:FireServer(u) end
if petId == "Event1_4" and equipRE then
equipRE:FireServer(u, true)
end
end
end
end
end
task.wait(0.02)
end
Reicht.Pet.EquipBest()
Reicht.Pet.FeedAllMax()
return acquired, acquired > 0 and ("Acquired %d %s directly via Season Draw!"):format(acquired, targetPetId) or "Halloween draw timed out"
end
local eggCfg = Reicht.GameLib.Need(GameConfig.Egg.Config)
local targetEggId = "Egg2"
for eggId, data in pairs(eggCfg or {}) do
if data.Loot then
for petId, _ in pairs(data.Loot) do
if petId == targetPetId then
targetEggId = eggId
break
end
end
end
end
local store = Reicht.Pet.Store(true)
local targetEggCount = 0
for _, entry in pairs(store.have or {}) do
if entry.Type == "Egg" and entry.ID == targetEggId and not entry.HatchReadyTick then
targetEggCount += 1
end
end
if targetEggCount < 5 then
Reicht.Pet.TrimEggs(targetEggId)
Reicht.Stage.FarmTurbo(targetEggId, "Egg", 15)
end
Reicht.Pet.HatchStep()
store = Reicht.Pet.Store(true)
local now = (workspace.GetServerTimeNow and workspace:GetServerTimeNow()) or (workspace:GetAttribute("ServerTime") or os.time())
local minDiff = math.huge
for _, u in pairs(store.hatched or {}) do
local it = store.have and store.have[u]
if it and it.HatchReadyTick then
local diff = math.max(0, it.HatchReadyTick - now)
if diff < minDiff then minDiff = diff end
end
end
local newlyGained = 0
for uuid, entry in pairs(store.have or {}) do
if entry.Type == "Pet" and entry.ID == targetPetId then
newlyGained += 1
if State.Opt.AutoLockTargetPet and not (entry.Lock or entry.Locked) then
Reicht.Util.Remote("Pet_Server", "SetUUIDLockRE"):FireServer(uuid)
end
end
end
if newlyGained > 0 then
Reicht.Pet.EquipBest()
Reicht.Pet.FeedAllMax()
return newlyGained, ("Acquired %s!"):format(targetPetId)
end
if minDiff < math.huge then
return 0, ("Incubating %s (%ds left)"):format(targetEggId, minDiff)
end
return 0, "No eggs incubating"
end
function Reicht.Pet.ChaseStep()
if not State.Opt.AutoChaseTargetPet then return end
local picked = State.PetTargetLabels and State.PetTargetLabels[State.Opt.TargetPet]
if not picked then return end
local gained = Reicht.Pet.FarmAndHatchTarget(picked, State.Opt.TargetPetCopies or 1)
if gained >= (State.Opt.TargetPetCopies or 1) then
State.Opt.AutoChaseTargetPet = false
table.insert(State.Halted, { "AutoChaseTargetPet", "Target acquired" })
end
end
function Reicht.Pet.EquipBest(focus)
local petStore = Reicht.Pet.Store()
local owned = {}
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" then
table.insert(owned, { uuid = uuid, score = Reicht.Pet.Score(entry, focus) })
end
end
if #owned == 0 then return 0 end
table.sort(owned, function(a, b) return a.score > b.score end)
local maxEquip = petStore.maxEquipNum or 1
local wanted, wantedList = {}, {}
for i = 1, math.min(maxEquip, #owned) do
wanted[owned[i].uuid] = owned[i].score
table.insert(wantedList, owned[i])
end
local currentSet = {}
for _, uuid in pairs(petStore.equiped or {}) do
currentSet[uuid] = true
end
local equipRE = Reicht.Util.Remote("Pet", "IsEquipPetRE")
local changed = 0
for uuid in pairs(currentSet) do
if not wanted[uuid] then
local entry = petStore.have and petStore.have[uuid]
local curScore = entry and Reicht.Pet.Score(entry, focus) or -1
local bestReplacement = wantedList[1]
if bestReplacement and bestReplacement.score > curScore then
equipRE:FireServer(uuid, false)
currentSet[uuid] = nil
end
end
end
for _, item in ipairs(wantedList) do
if not currentSet[item.uuid] then
equipRE:FireServer(item.uuid, true)
changed += 1
end
end
if changed > 0 then Reicht.Data.Get(true) end
return changed
end
function Reicht.Pet.FeedBest()
local profile = Reicht.Data.Get()
local petStore = profile.Pet or {}
local foodCfg = Reicht.GameLib.Need(GameConfig.Food.Config)
local petHelper = Reicht.GameLib.Api(GameConfig.Pet.Helper)
local foods = {}
for uuid, entry in pairs(profile.Backpack.have or {}) do
local count = math.floor(entry.Number or 0)
local info = entry.Type == "Food" and foodCfg[entry.ID]
if info and count >= 1 and (info.Exp or 0) > 0 then
table.insert(foods, { uuid = uuid, count = count, exp = info.Exp })
end
end
if #foods == 0 then return 0 end
table.sort(foods, function(a, b) return a.exp > b.exp end)
local equippedSet = {}
for _, uuid in pairs(petStore.equiped or {}) do equippedSet[uuid] = true end
local targets = {}
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" and not petHelper.CheckLevelIsMax(entry.Level or 1, entry.ID) then
local priority = (equippedSet[uuid] and 1e9 or 0) + (entry.DeployStartTick and 1e8 or 0) + Reicht.Pet.Score(entry)
table.insert(targets, { uuid = uuid, entry = entry, priority = priority })
end
end
if #targets == 0 then return 0 end
table.sort(targets, function(a, b) return a.priority > b.priority end)
local target = targets[1]
local maxLv = petHelper.GetMaxLevel(target.entry.ID) or 20
local needExp = -(target.entry.Exp or 0)
for lv = (target.entry.Level or 1) + 1, maxLv do
needExp += (petHelper.GetNeedExp(lv) or 0)
end
if needExp <= 0 then return 0 end
local feedMap, usedAny = {}, false
for _, food in ipairs(foods) do
if needExp <= 0 then break end
local use = math.min(food.count, math.max(1, math.ceil(needExp / food.exp)))
if use > 0 then
feedMap[food.uuid] = use
needExp -= use * food.exp
usedAny = true
end
end
if not usedAny then return 0 end
Reicht.Util.Remote("Pet", "FeedPetRE"):FireServer(target.uuid, feedMap)
Reicht.Data.Get(true)
return 1
end
function Reicht.Pet.FeedAllMax()
local totalFed = 0
for _ = 1, 15 do
local fed = Reicht.Pet.FeedBest()
if fed <= 0 then break end
totalFed += fed
task.wait(0.05)
end
return totalFed
end
function Reicht.Pet.DeployStep()
local petStore = Reicht.Pet.Store()
if type(petStore.deployRewardList) == "table" and next(petStore.deployRewardList) ~= nil then
Reicht.Util.Remote("Pet", "ClaimAllDeployRewardRE"):FireServer()
end
local deployedCount = 0
local candidates = {}
for uuid, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" then
if entry.DeployStartTick then
deployedCount += 1
else
table.insert(candidates, { uuid = uuid, score = Reicht.Pet.Score(entry) })
end
end
end
local freeSlots = (petStore.maxDeployNum or 2) - deployedCount
if freeSlots <= 0 or #candidates == 0 then return 0 end
table.sort(candidates, function(a, b) return a.score > b.score end)
local deployRE = Reicht.Util.Remote("Pet", "IsDeployPetRE")
local deployed = 0
for i = 1, math.min(freeSlots, #candidates) do
deployRE:FireServer(candidates[i].uuid, true)
deployed += 1
end
if deployed > 0 then Reicht.Data.Get(true) end
return deployed
end
function Reicht.Pet.StatusText(profile)
local prof = profile or Reicht.Data.Get() or {}
local petStore = prof.Pet or {}
local pets, eggs = Reicht.Pet.Counts(petStore)
local hatched = 0
for _ in pairs(petStore.hatched or {}) do hatched += 1 end
local deployed = 0
for _, entry in pairs(petStore.have or {}) do
if entry.Type == "Pet" and entry.DeployStartTick then deployed += 1 end
end
local equippedNames = {}
local petShow = GameConfig:FindFirstChild("Pet") and GameConfig.Pet:FindFirstChild("Show") and Reicht.GameLib.Require(GameConfig.Pet.Show)
for _, uuid in pairs(petStore.equiped or {}) do
local entry = petStore.have and petStore.have[uuid]
if entry then
local name = petShow and petShow[entry.ID] and petShow[entry.ID].DisplayName or entry.ID or "Pet"
table.insert(equippedNames, ("%s Lv.%d"):format(tostring(name), tonumber(entry.Level) or 1))
end
end
local eqText = #equippedNames > 0 and table.concat(equippedNames, ", ") or "None"
local now = (workspace.GetServerTimeNow and workspace:GetServerTimeNow()) or (workspace:GetAttribute("ServerTime") or os.time())
local hatchTimers = {}
for _, uuid in pairs(petStore.hatched or {}) do
local entry = petStore.have and petStore.have[uuid]
if entry and entry.HatchReadyTick then
local diff = math.max(0, math.floor(entry.HatchReadyTick - now))
table.insert(hatchTimers, diff .. "s")
end
end
local hatchDetail = #hatchTimers > 0 and (" (" .. table.concat(hatchTimers, ", ") .. ")") or ""
return string.format(
"Pet: %s\nBags: %d/%d Pets · %d/%d Eggs | Hatch: %d/%d%s | Deploy: %d/%d",
tostring(eqText),
tonumber(pets) or 0, tonumber(petStore.maxPetNum) or 25,
tonumber(eggs) or 0, tonumber(petStore.maxEggNum) or 25,
tonumber(hatched) or 0, tonumber(petStore.maxHatchNum) or 3,
tostring(hatchDetail or ""),
tonumber(deployed) or 0, tonumber(petStore.maxDeployNum) or 2
)
end
function Reicht.Movement.Humanoid()
return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end
function Reicht.Movement.Apply()
local hum = Reicht.Movement.Humanoid()
if not hum then return end
hum.WalkSpeed = State.Opt.SpeedOn and State.Opt.WalkSpeed or (LocalPlayer:GetAttribute("OriWalkSpeed") or 22)
end
function Reicht.Movement.SetNoclip(enabled)
State.Opt.Noclip = enabled
if enabled then
if not State.NoclipConn then
State.NoclipConn = RunService.Stepped:Connect(function()
if not State.Opt.Noclip then return end
local char = LocalPlayer.Character
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then
part.CanCollide = false
end
end
end)
end
else
if State.NoclipConn then
State.NoclipConn:Disconnect()
State.NoclipConn = nil
end
end
end
function Reicht.Movement.SetFly(enabled)
State.Opt.FlyOn = enabled
local char = LocalPlayer.Character
local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not enabled then
if State.FlyBodyGyro then pcall(function() State.FlyBodyGyro:Destroy() end); State.FlyBodyGyro = nil end
if State.FlyBodyVelocity then pcall(function() State.FlyBodyVelocity:Destroy() end); State.FlyBodyVelocity = nil end
if hum then hum.PlatformStand = false end
if State.FlyConn then State.FlyConn:Disconnect(); State.FlyConn = nil end
return
end
if not (root and hum) then return end
local bg = Instance.new("BodyGyro")
bg.P = 9e4
bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
bg.cframe = root.CFrame
bg.Parent = root
State.FlyBodyGyro = bg
local bv = Instance.new("BodyVelocity")
bv.velocity = Vector3.zero
bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
bv.Parent = root
State.FlyBodyVelocity = bv
hum.PlatformStand = true
State.FlyConn = RunService.RenderStepped:Connect(function()
if not (State.Opt.FlyOn and root and root.Parent) then
Reicht.Movement.SetFly(false)
return
end
local cam = workspace.CurrentCamera
local speed = State.Opt.FlySpeed or 60
local dir = Vector3.zero
if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
if dir.Magnitude > 0 then
bv.velocity = dir.Unit * speed
else
bv.velocity = Vector3.zero
end
bg.cframe = cam.CFrame
end)
end
function Reicht.Movement.Bind()
table.insert(State.Conns, UserInputService.JumpRequest:Connect(function()
local hum = Reicht.Movement.Humanoid()
if State.Opt.InfJump and hum then
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end
end))
table.insert(State.Conns, LocalPlayer.CharacterAdded:Connect(function()
task.wait(1)
Reicht.Movement.Apply()
if State.Opt.FlyOn then Reicht.Movement.SetFly(true) end
end))
end
function Reicht.Session.SetLowGraphics(enabled)
RunService:Set3dRenderingEnabled(not enabled)
end
function Reicht.Session.Rejoin()
local queue = queue_on_teleport or queueonteleport
if queue then queue(Config.ReloadSource) end
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
function Reicht.Session.HopSmallest()
local body = Reicht.Util.HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
local ok, list = pcall(HttpService.JSONDecode, HttpService, body or "")
local best
for _, server in ipairs(ok and type(list) == "table" and type(list.data) == "table" and list.data or {}) do
if server.id == game.JobId or server.playing >= server.maxPlayers then continue end
if not best or server.playing < best.playing then best = server end
end
if not best then return false end
local queue = queue_on_teleport or queueonteleport
if queue then queue(Config.ReloadSource) end
TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
return true
end
function Reicht.Session.SavePosition()
local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
State.SavedSpot = root and root.CFrame
return State.SavedSpot ~= nil
end
function Reicht.Session.ReturnPosition()
local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not (root and State.SavedSpot) then return false end
root.CFrame = State.SavedSpot
return true
end
function Reicht.Boss.HopFlag(enabled)
local flag = Config.SaveFolder .. "/" .. Config.BossHopFlag
pcall(function()
if enabled then
if not isfolder(Config.SaveFolder) then makefolder(Config.SaveFolder) end
writefile(flag, tostring(os.time()))
elseif isfile(flag) then
delfile(flag)
end
end)
end
function Reicht.Boss.SinceLastHop()
local ok, stamp = pcall(readfile, Config.SaveFolder .. "/" .. Config.BossHopFlag)
local n = ok and tonumber(stamp) or nil
if not n then return nil end
return os.time() - n
end
function Reicht.Boss.HopWanted()
local since = Reicht.Boss.SinceLastHop()
return since ~= nil and since < Config.BossHopResume
end
function Reicht.Boss.LoadServers()
local ok, text = pcall(readfile, Config.SaveFolder .. "/" .. Config.BossHopServers)
if not ok then return {}, 0 end
local decoded
ok, decoded = pcall(HttpService.JSONDecode, HttpService, text)
if not ok or type(decoded) ~= "table" or type(decoded.ids) ~= "table" then return {}, 0 end
local fetchedAt = tonumber(decoded.at) or 0
if os.time() - fetchedAt > Config.HopListTtl then return {}, 0 end
return decoded.ids, fetchedAt
end
function Reicht.Boss.SaveServers(ids, fetchedAt)
pcall(function()
if not isfolder(Config.SaveFolder) then makefolder(Config.SaveFolder) end
writefile(Config.SaveFolder .. "/" .. Config.BossHopServers, HttpService:JSONEncode({ at = fetchedAt, ids = ids }))
end)
end
function Reicht.Boss.FetchServers()
if os.clock() < State.HopBlockedUntil then return {} end
local body = Reicht.Util.HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
local ok, list = pcall(HttpService.JSONDecode, HttpService, body or "")
local ids = {}
for _, server in ipairs(ok and type(list) == "table" and type(list.data) == "table" and list.data or {}) do
if server.id ~= game.JobId and server.playing < server.maxPlayers then table.insert(ids, server.id) end
end
if #ids > 0 then
State.HopFails, State.HopBackoff = 0, nil
return ids
end
State.HopFails += 1
State.HopBackoff = math.min((State.HopBackoff or Config.HopBackoffStart / 2) * 2, Config.HopBackoffMax)
State.HopBlockedUntil = os.clock() + State.HopBackoff
warn("[LootToForge] server list refused, retry in", State.HopBackoff, "s, fail", State.HopFails)
return {}
end
function Reicht.Boss.PickServer()
local ids, fetchedAt = Reicht.Boss.LoadServers()
if #ids == 0 then
ids, fetchedAt = Reicht.Boss.FetchServers(), os.time()
end
while #ids > 0 do
local serverId = table.remove(ids, math.random(#ids))
if serverId ~= game.JobId then
Reicht.Boss.SaveServers(ids, fetchedAt)
return serverId
end
end
Reicht.Boss.SaveServers(ids, fetchedAt)
return nil
end
function Reicht.Boss.Hop()
local serverId = Reicht.Boss.PickServer()
if not serverId then return end
State.BossHopping = os.clock()
Reicht.Boss.HopFlag(true)
local queue = queue_on_teleport or queueonteleport
if queue and not State.HopQueued then
queue(Config.ReloadSource)
State.HopQueued = true
end
TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
end
function Reicht.Boss.WorthStaying()
if State.BossLooting and os.clock() - State.BossLooting < Config.BossLootTimeout then return true end
local boss = workspace:GetAttribute("CurrentWorldBoss")
if boss and not State.BossDone then return true end
if State.BossDone then return os.clock() - State.BossDone < Config.BossHopAfter end
local nextTick, serverTime = workspace:GetAttribute("NextWorldBossTick"), workspace:GetAttribute("ServerTime")
if not nextTick or not serverTime then return true end
return nextTick - serverTime <= State.Opt.BossWaitMinutes * 60
end
function Reicht.Boss.HopGiveUp()
State.Opt.BossHop = false
Reicht.Boss.HopFlag(false)
table.insert(State.Halted, { "BossHop", "no server list from Roblox, try again later" })
end
function Reicht.Boss.HopStep()
if State.BossHopping then
if os.clock() - State.BossHopping < Config.HopStall then return end
State.BossHopping = false
end
if Reicht.Boss.WorthStaying() then return end
if (Reicht.Boss.SinceLastHop() or Config.HopGap) < Config.HopGap then return end
if State.HopFails >= Config.HopGiveUp then
Reicht.Boss.HopGiveUp()
return
end
Reicht.Boss.Hop()
end
function Reicht.Session.Bind()
table.insert(State.Conns, TeleportService.TeleportInitFailed:Connect(function()
if State.BossHopping then
State.BossHopping = false
task.delay(1, Reicht.Util.Try, Reicht.Boss.HopStep)
elseif State.Opt.AutoRejoinSeason then
task.delay(2, function()
if State.Opt.AutoRejoinSeason and State.Alive then
Reicht.Season.RunRejoinLoop()
end
end)
end
end))
table.insert(State.Conns, LocalPlayer.Idled:Connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end))
table.insert(State.Conns, GuiService.ErrorMessageChanged:Connect(function(msg)
if (State.Opt.AutoRejoin or State.Opt.AutoRejoinSeason) and msg ~= "" and not State.Rejoining then
State.Rejoining = true
task.delay(Config.RejoinDelay, Reicht.Session.Rejoin)
end
end))
end
Reicht.Scheduler.Jobs = {
{ key = "SuperLootAura", every = Config.KillAuraInterval, run = function() Reicht.SuperLoot.Step() end },
{ key = "AutoBattle", every = Config.KillAuraInterval, run = function() Reicht.Stage.BattleStep() end },
{ key = "AutoCheckIn", every = Config.ClaimInterval, run = function() Reicht.Claim.CheckIn() end },
{ key = "MaxGear", every = 0, run = function() Reicht.Gear.MaxStep() end },
{ key = "CollectOre", every = 0, run = function() Reicht.Stage.Collect(State.Opt.Stage or Reicht.Stage.Best(), State.Opt.CollectRarities) end },
{ key = "AutoForge", every = 0, run = function() Reicht.Forge.Step() end },
{ key = "AutoEquip", every = Config.EquipInterval, run = function() Reicht.Gear.EquipBest() end },
{ key = "AutoSell", every = Config.SellInterval, run = function() Reicht.Sell.Run(Reicht.Data.Get()) end },
{ key = "AutoTrain", every = 1, run = function() Reicht.Level.TrainStep() end },
{ key = "AutoClick", every = 0.08, run = function() Reicht.Level.ClickStep() end },
{ key = "AutoRebirth", every = Config.RebirthInterval, run = function() Reicht.Level.RebirthStep() end },
{ key = "AutoUpgrade", every = Config.UpgradeInterval, run = function() Reicht.Upgrade.BuySelected() end },
{ key = "AutoTower", every = 0, run = function() Reicht.Tower.FarmStep() end },
{ key = "AutoSeasonCoins", every = 0.35, run = function() Reicht.Tower.ContinuousCoinsStep() end },
{ key = "AutoWorldBoss", every = Config.BossInterval, run = function() Reicht.Boss.Step() end },
{ key = "BossHop", every = Config.BossHopInterval, run = function() Reicht.Boss.HopStep() end },
{ key = "AutoClaim", every = Config.ClaimInterval, run = function() Reicht.Claim.All() end },
{ key = "AutoSeason", every = Config.SeasonInterval, run = function() Reicht.Season.Step() end },
{ key = "AutoTokenShop", every = Config.TokenShopInterval, run = function() Reicht.TokenShop.BuyAll() end },
{ key = "AutoBestRace", every = 10, run = function() Reicht.Race.EquipBest() end },
{ key = "TurboSpawn", every = 0, run = function() Reicht.Spawn.TurboStep() end },
{ key = "AutoChaseTargetPet", every = 1, run = function() Reicht.Pet.ChaseStep() end },
{ key = "AutoHatchEgg", every = 1, run = function() Reicht.Pet.HatchStep() end },
{ key = "AutoEquipPet", every = Config.PetInterval, run = function() Reicht.Pet.EquipBest() end },
{ key = "AutoFeedPet", every = Config.PetInterval, run = function() Reicht.Pet.FeedBest() end },
{ key = "AutoDeployPet", every = Config.PetDeployInterval, run = function() Reicht.Pet.DeployStep() end },
{ key = "AutoSellPet", every = Config.SellInterval, run = function() Reicht.Pet.CleanBag() end },
{ key = "AutoGradeUpPet", every = 5, run = function() Reicht.Pet.GradeUpAll() end },
{ key = "AutoRainbowPet", every = 6, run = function() Reicht.Pet.RainbowGodStep() end },
{ key = "AutoIndex", every = Config.IndexInterval, run = function() Reicht.Util.Exclusive("Index", Reicht.Index.HuntAll) end },
}
function Reicht.Scheduler.Run(key, fn)
if not State.Alive or State.JobRunning[key] then return end
local result
local thread = task.defer(function() result = table.pack(pcall(fn)) end)
State.JobRunning[key] = thread
local deadline = os.clock() + State.Opt.JobTimeout
local toggleJob = type(State.Opt[key]) == "boolean"
while State.Alive and (not toggleJob or State.Opt[key]) and not result and os.clock() < deadline do task.wait(0.05) end
if not result then
Reicht.Util.CancelTree(thread)
result = { false, "job timed out" }
end
State.JobRunning[key] = nil
if not State.Alive or (toggleJob and not State.Opt[key]) then return end
local ok, err = result[1], result[2]
State.JobStats[key] = { ok = ok, at = os.clock(), error = not ok and tostring(err) or nil }
local failures = State.Failures
if ok then
failures[key] = nil
return
end
local streak = failures[key]
if not streak then
streak = { count = 0, since = os.clock() }
failures[key] = streak
Reicht.Util.WarnJob(key, err)
end
streak.count += 1
if streak.count < Config.MaxFailures or os.clock() - streak.since < Config.FailWindow then return end
failures[key] = nil
State.Opt[key] = false
local reason = tostring(err):match("[^\n]*")
warn("[LootToForge]", key, "stopped:", reason)
table.insert(State.Halted, { key, reason })
end
Reicht.Scheduler.Groups = {
SuperLootAura = "combat", KillAura = "combat", AutoBattle = "combat", AutoWorldBoss = "combat",
AutoTrain = "train", AutoClick = "click", AutoRebirth = "train",
AutoHatchEgg = "pet", AutoEquipPet = "pet", AutoFeedPet = "pet", AutoDeployPet = "pet", AutoSellPet = "pet", AutoGradeUpPet = "pet", AutoRainbowPet = "pet",
BossHop = "travel",
}
function Reicht.Scheduler.Step()
if not State.Alive then return end
local now = os.clock()
if State.Lock and State.LockTime and (now - State.LockTime > 12) then
State.Lock = nil
State.LockOwner = nil
State.LockTime = 0
end
if State.Lock then return end
local active = 0
for _ in pairs(State.JobGroups) do active += 1 end
local jobs = Reicht.Scheduler.Jobs
local cursor = State.ScheduleCursor or 0
State.ScheduleCursor = cursor % #jobs + 1
for offset = 1, #jobs do
if active >= math.clamp(State.Opt.ParallelJobs, 1, 8) then break end
local index = (cursor + offset - 1) % #jobs + 1
local job = jobs[index]
local group = Reicht.Scheduler.Groups[job.key] or "inventory"
if not State.Opt[job.key] or State.JobRunning[job.key] or State.JobGroups[group] then continue end
if now - (State.LastRun[job.key] or 0) < job.every then continue end
State.LastRun[job.key] = now
active += 1
local monitor
monitor = task.defer(function()
local ok, err = pcall(Reicht.Scheduler.Run, job.key, job.run)
if State.JobGroups[group] == monitor then State.JobGroups[group] = nil end
if not ok and State.Alive then Reicht.Util.WarnJob(job.key, err) end
end)
State.JobGroups[group] = monitor
end
end
function Reicht.Scheduler.Start()
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
function Reicht.Scheduler.Boot()
for _, bind in ipairs({ Reicht.Movement.Bind, Reicht.Level.Bind, Reicht.SuperLoot.Bind, Reicht.Boss.Bind, Reicht.Pet.Bind, Reicht.Session.Bind }) do
Reicht.Util.Try(bind)
end
Reicht.Scheduler.Start()
end
function Reicht.Scheduler.Stop()
State.Alive = false
if State.ClickThread then
pcall(task.cancel, State.ClickThread)
State.ClickThread = nil
end
if State.AuraThread then
pcall(task.cancel, State.AuraThread)
State.AuraThread = nil
end
for _, threads in pairs(State.WorkerBatches) do
for _, thread in ipairs(threads) do pcall(task.cancel, thread) end
end
for _, thread in pairs(State.JobRunning) do pcall(task.cancel, thread) end
for _, monitor in pairs(State.JobGroups) do Reicht.Util.CancelTree(monitor) end
for owner in pairs(State.ChildThreads) do Reicht.Util.CancelTree(owner) end
table.clear(State.JobGroups)
table.clear(State.ChildThreads)
State.Lock = nil
State.LockOwner = nil
State.LockTime = 0
table.clear(State.WorkerBatches)
table.clear(State.JobRunning)
table.clear(State.LootQueue)
table.clear(State.LootSeen)
table.clear(State.LootPending)
for _, conn in ipairs(State.Conns) do
conn:Disconnect()
end
table.clear(State.Conns)
if State.Opt.AutoTrain then
State.Opt.AutoTrain = false
task.spawn(Reicht.Util.Try, Reicht.Level.SetTraining, false)
end
if State.Opt.SpeedOn then
State.Opt.SpeedOn = false
Reicht.Movement.Apply()
end
if State.Opt.LowGraphics then
Reicht.Session.SetLowGraphics(false)
end
Reicht.Util.Try(Reicht.Pet.MuteAnim, false)
Reicht.Util.Try(Reicht.Tower.Exit)
if LocalPlayer:GetAttribute("IntoFight") == "WorldBoss" then Reicht.Util.Try(Reicht.Boss.Leave) end
Reicht.Movement.SetFly(false)
Reicht.Movement.SetNoclip(false)
Reicht.Guard.Stop()
end
local function BuildInterface()
local Library = Reicht.Util.LoadLibrary()
if not Library then return end
Reicht.Compat = Library.Compat or { Caps = {}, Block = function() end, NeedCap = function() end }
local Options = Library.Options
pcall(ReichtBanner.Step, "UI library")
local T = function(en, th) return Library:T(en, th) end
local opt = State.Opt
local featureNames = {}
local uiQueue = {}
local statusLabel, gearLabel, taskLabel, rejoinStatusLabel
local function Source(fn)
local ok, first, second = pcall(fn)
if not ok then
warn("[LootToForge] menu data:", first)
return {}, {}
end
return first or {}, second or {}
end
local rarityNames = Source(Reicht.Util.RarityNames)
local function Later(fn, ...)
local args = table.pack(...)
table.insert(uiQueue, function()
fn(table.unpack(args, 1, args.n))
end)
end
local function Notify(text, kind, seconds)
Later(Library.Notify, Library, "Loot To Forge", text, seconds or 4, kind or "Info")
end
local function TurnOff(key)
local toggle = Options[key]
if toggle and toggle.Value then toggle:SetValue(false) end
end
local function SetList(idx, values, pickFirst)
local dropdown = Options[idx]
if not dropdown then return end
dropdown:SetValues(values)
if pickFirst and values[1] then
dropdown:SetValue(values[1])
elseif dropdown.Value ~= opt[idx] then
dropdown:SetValue(dropdown.Value)
end
end
local function NeedModule(option, module)
if Reicht.GameLib.Require(module) then return end
Reicht.Compat.Block(option, T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้"))
end
local function BlockMissing()
for idx, paths in pairs(Reicht.GameLib.Missing()) do
warn("[LootToForge]", idx, "blocked, missing:", table.concat(paths, ", "))
if Options[idx] then Reicht.Compat.Block(Options[idx], T("Not available after a game update", "ใช้ไม่ได้หลังเกมอัปเดต")) end
end
end
local function Pump()
for _, halt in ipairs(State.Halted) do
TurnOff(halt[1])
Notify(("%s stopped: %s"):format(featureNames[halt[1]] or halt[1], halt[2]), "Warning")
end
table.clear(State.Halted)
local jobs = uiQueue
uiQueue = {}
for _, job in ipairs(jobs) do
Reicht.Util.Try(job)
end
end
local actionId = 0
local function Action(action)
actionId += 1
local key = "Action:" .. actionId
return function()
if not State.Alive or State.JobRunning[key] then return end
task.defer(Reicht.Scheduler.Run, key, action)
end
end
local function LongAction(name, action, done)
return Action(function()
if State.Lock then
Notify("Busy: " .. State.Lock, "Warning")
return
end
Notify(name .. "...")
local acquired, outcome = Reicht.Util.Exclusive(name, action)
if not acquired then
Notify("An inventory task is still running; retry when it finishes", "Warning")
return
end
if done then Notify(done(outcome), (outcome == false or outcome == nil or outcome == 0) and "Warning" or "Success") end
end)
end
local function Toggle(group, key, text, description, onChange)
featureNames[key] = text.EN
return group:AddToggle(key, {
Text = text,
Description = description,
Default = opt[key],
Callback = function(value)
opt[key] = value
if onChange then
onChange(value)
end
end,
})
end
local Feature = Toggle
local function HotkeyFeature(group, key, text, description, onChange)
return Toggle(group, key, text, description, onChange):AddKeyPicker(key .. "Key", { Default = "None", Mode = "Toggle" })
end
local function Check(group, key, text)
return group:AddCheckbox(key, {
Text = text,
Default = opt[key],
Callback = function(value)
opt[key] = value
end,
})
end
local function MultiSelect(group, key, text, description, values)
opt[key] = Reicht.Util.AllSet(values)
return group:AddDropdown(key, {
Text = text,
Description = description,
Values = values,
Multi = true,
Default = values,
Searchable = #values > 8,
Callback = function(selected)
opt[key] = selected
end,
})
end
local function Pick(group, key, text, description, source, noSave)
local values = Source(source)
opt[key] = values[1]
return group:AddDropdown(key, {
Text = text,
Description = description,
Values = values,
Default = 1,
Searchable = #values > 8,
NoSave = noSave,
Callback = function(value)
opt[key] = value
end,
})
end
local function NumberInput(group, key, text, description, minimum)
return group:AddInput(key, {
Text = text,
Description = description,
Default = tostring(opt[key]),
Numeric = true,
Finished = true,
Callback = function(value)
opt[key] = math.max(minimum or 0, math.floor(tonumber(value) or opt[key]))
end,
})
end
local function Decorate(idx, idOf)
task.defer(function()
local dropdown = Options[idx]
if not (dropdown and dropdown.SetImages) then return end
local ok, images, colors = pcall(Reicht.Look.Maps, dropdown.Values, idOf)
if not ok then
warn("[LootToForge] item images:", images)
return
end
Later(function()
if Options[idx] then Options[idx]:SetImages(images, colors) end
end)
end)
end
local function OreId(label)
return State.OreLabels and State.OreLabels[label]
end
local function RefreshButton(idx, list)
return { Text = T("Refresh", "รีเฟรช"), Func = function()
task.defer(function()
Later(SetList, idx, (Source(list)))
if State.Decorators and State.Decorators[idx] then Later(Decorate, idx, State.Decorators[idx]) end
end)
end }
end
local function BuildMain(tab)
local statusBox = tab:AddLeftGroupbox(T("Status", "สถานะ"))
statusLabel = statusBox:AddLabel("Level - · Rebirth - · Coins -")
gearLabel = statusBox:AddLabel("Equipped: -")
taskLabel = statusBox:AddLabel("Working on: Idle")
local kaitunBox = tab:AddLeftGroupbox(T("Kaitun", "ไก่ตัน"))
kaitunBox:AddToggle("Kaitun", {
Text = T("Kaitun (All-in-one)", "ไก่ตัน (ทำทุกอย่าง)"),
Description = T("Best gear, money, level, rewards and bosses all at once", "ของดีสุด เงิน เลเวล รางวัล และบอส ทำพร้อมกันทั้งหมด"),
NoSave = true,
Callback = function(value)
for _, key in ipairs(Config.KaitunToggles) do
if Options[key] then Options[key]:SetValue(value) end
end
end,
})
local rewardBox = tab:AddLeftGroupbox(T("Rewards", "รางวัล"))
Feature(rewardBox, "AutoClaim", T("Auto Claim", "รับรางวัลอัตโนมัติ"), T("Claims every free reward, including index", "รับรางวัลฟรีทุกอย่าง รวมสมุดสะสม"))
rewardBox:AddButton({ Text = T("Claim Now", "รับเดี๋ยวนี้"), Style = "Success", Func = Action(Reicht.Claim.All) })
Feature(rewardBox, "AutoCheckIn", T("Auto 30-Day Check-In", "รับเช็กอิน 30 วันอัตโนมัติ"), T("Claims every signed day that still has an unclaimed reward", "รับรางวัลทุกวันที่เช็กอินแล้วและยังไม่ได้รับ"))
rewardBox:AddButton({ Text = T("Claim Check-In Now", "รับรางวัลเช็กอินเดี๋ยวนี้"), Func = LongAction("Check-In", Reicht.Claim.CheckIn, function(count)
return ("Claimed %d check-in rewards"):format(count or 0)
end) })
rewardBox:AddButton({ Text = T("Redeem All Codes", "ใช้โค้ดทั้งหมด"), Style = "Primary", Func = Action(function()
Notify(Reicht.Claim.AllCodes(), "Success", 6)
end) })
local discordBox = tab:AddRightGroupbox("Discord", "link")
discordBox:AddLabel(Config.Discord)
discordBox:AddButton({ Text = T("Copy Discord Link", "คัดลอกลิงก์ Discord"), Style = "Primary", Func = function()
local copy = setclipboard or toclipboard
if copy then copy(Config.Discord) end
Notify(copy and "Discord link copied" or Config.Discord)
end })
local logBox = tab:AddRightGroupbox(T("Update Log", "อัปเดตล่าสุด"), "bell")
for i = 1, math.min(2, #Config.UpdateLog) do
local entry = Config.UpdateLog[i]
logBox:AddParagraph({ Title = entry[1], Content = entry[2] })
end
end
local function BuildCombat(tab)
local stageBox = tab:AddLeftGroupbox(T("Stage", "ด่าน"))
Pick(stageBox, "Stage", T("Stage", "ด่าน"), T("Any stage, no unlock needed", "เลือกด่านไหนก็ได้ ไม่ต้องปลดล็อก"), Reicht.Stage.List)
Feature(stageBox, "AutoBattle", T("Auto Battle", "เข้าด่านและฆ่าอัตโนมัติ"), T("Enters the selected stage and clears normal enemies and stage bosses", "เข้าด่านที่เลือกและฆ่ามอนสเตอร์กับบอสด่านทั้งหมด"))
Feature(stageBox, "CollectOre", T("Auto Collect Ore", "เก็บแร่อัตโนมัติ"), T("Clears the stage and collects its ores nonstop", "เคลียร์ด่านแล้วเก็บแร่ไม่หยุด"))
MultiSelect(stageBox, "CollectRarities", T("Ore Rarity Filter", "กรอง rarity แร่"), T("Only collect these rarities", "เก็บเฉพาะ rarity ที่เลือก"), rarityNames)
stageBox:AddButton({
Text = T("Rush All Stages (1–27) Now", "เคลียร์ทะลวงทุกด่าน (1-27) ทันที"),
Style = "Primary",
Func = LongAction("Rush Stages", function()
return Reicht.Stage.RushAllStages(5)
end, function(count)
return count and ("Stages 1-27 Cleared! (" .. count .. " drops)") or "Failed to rush stages"
end)
})
local combatBox = tab:AddLeftGroupbox(T("Combat", "ต่อสู้"), nil, "OP")
local killAura = Feature(combatBox, "KillAura", T("Kill Aura", "ฆ่ารอบตัว"), T("Clears all enemies across the whole map instantly", "ฆ่าศัตรูทั้งแมพทันที ยิงทะลุกำแพง ไม่จำกัดระยะ"), function(value)
if value then Reicht.Combat.Start() end
end)
NeedModule(killAura, ReplicatedStorage.Utils.CommunicationUtils)
Check(combatBox, "AuraMapWide", T("Map-Wide / Infinite Range", "โจมตีทั้งแมพ / ไม่จำกัดระยะ"))
combatBox:AddDropdown("AuraTarget", {
Text = T("Target Filter", "ประเภทเป้าหมาย"),
Values = { "All", "Normal", "Super", "Boss" },
Default = 1,
Callback = function(value) opt.AuraTarget = value end,
})
NumberInput(combatBox, "AuraBatch", T("Targets Per Sweep", "เป้าหมายต่อรอบ"), T("Number of enemies processed per tick", "จำนวนศัตรูที่ประมวลผลต่อรอบ"), 1)
combatBox:AddSlider("AuraBurst", {
Text = T("Attack Burst (Hits/Tick)", "จำนวนฮิตต่อรอบ"), Min = 1, Max = 50,
Default = opt.AuraBurst, Rounding = 0,
Callback = function(value) opt.AuraBurst = tonumber(value) or 10 end,
})
combatBox:AddSlider("AuraInterval", {
Text = T("Attack Interval", "ช่วงเวลาโจมตี"), Min = 0.05, Max = 1,
Default = opt.AuraInterval, Rounding = 2, Suffix = " s",
Callback = function(value) opt.AuraInterval = math.clamp(tonumber(value) or 0.12, 0.05, 1) end,
})
Check(combatBox, "AuraCritical", T("Critical Hits", "โจมตีคริติคอล"))
Check(combatBox, "AutoCollectDrops", T("Auto Collect Drops", "เก็บของดรอปอัตโนมัติ"))
Check(combatBox, "AutoSkills", T("Auto Cast Skills (Q & E)", "ร่ายสกิลอาวุธอัตโนมัติ (Q & E)"))
Check(combatBox, "AuraSuper", T("Include Ore Bosses", "รวมบอสแร่"))
Check(combatBox, "InstantKillAll", T("Full Map Kill (Bypass Batch)", "ฆ่ารวดเดียวหมดแมพ (ทะลุลิมิต)"))
Feature(combatBox, "SuperLootAura", T("Kill Ore Boss", "ฆ่าบอสแร่"), T("Handles ore bosses instantly and collects confirmed drops", "จัดการบอสแร่ทันที และรับของที่ยืนยันแล้ว"), function(value)
if value then
Reicht.SuperLoot.KillExisting()
else
for _, uuid in ipairs(State.LootQueue) do State.LootSeen[uuid] = nil end
table.clear(State.LootQueue)
end
end)
combatBox:AddButton({ Text = T("Kill All Now", "ฆ่าทั้งแมพเดี๋ยวนี้"), Style = "Primary", Func = Action(Reicht.Combat.KillAll) }):AddButton({ Text = T("Exit Fight Now", "ออกจากการต่อสู้เดี๋ยวนี้"), Style = "Warning", Func = Action(Reicht.Stage.ExitFight) })
combatBox:AddButton({ Text = T("Wipe Entire Map Now (0ms)", "ล้างทั้งแมพใน 0ms"), Style = "Danger", Func = Action(Reicht.Combat.WipeMapNow) })
local bossBox = tab:AddRightGroupbox(T("World Boss", "บอสโลก"))
Feature(bossBox, "AutoWorldBoss", T("Auto World Boss", "บอสโลกอัตโนมัติ"), T("Joins every world boss and kills it", "เข้าบอสโลกทุกรอบแล้วฆ่า"), function(value)
if not value and LocalPlayer:GetAttribute("IntoFight") == "WorldBoss" then task.spawn(Reicht.Util.Try, Reicht.Boss.Leave) end
end)
Check(bossBox, "BossCards", T("Auto Take Reward Card", "เปิดการ์ดรางวัลอัตโนมัติ"))
Feature(bossBox, "BossHop", T("Boss Server Hop", "ย้ายเซิร์ฟหาบอส"), T("Hops to servers where the boss is up or about to spawn, kills it, then moves on", "ย้ายไปเซิร์ฟที่บอสเกิดอยู่หรือใกล้เกิด ฆ่าแล้วย้ายต่อ"), function(value)
Reicht.Boss.HopFlag(value)
if value and Options.AutoWorldBoss and not Options.AutoWorldBoss.Value then Options.AutoWorldBoss:SetValue(true) end
end)
bossBox:AddSlider("BossWaitMinutes", {
Text = T("Wait If Boss Within", "รอถ้าบอสจะเกิดภายใน"),
Description = T("Stays on a server when the boss spawns this soon", "อยู่เซิร์ฟเดิมถ้าบอสจะเกิดภายในเวลานี้"),
Min = 0.5, Max = 10, Default = opt.BossWaitMinutes, Rounding = 1, Suffix = " min",
Callback = function(value)
opt.BossWaitMinutes = tonumber(value) or opt.BossWaitMinutes
end,
})
bossBox:AddButton({
Text = T("Nuke World Boss Now", "สังหารบอสโลกทันที"),
Style = "Primary",
Func = LongAction("Nuke Boss", Reicht.Boss.NukeNow, function(ok)
return ok and "World Boss Nuked & Cards Claimed!" or "World Boss not available or already dead"
end)
})
local towerBox = tab:AddRightGroupbox(T("Tower & Season", "หอคอยและซีซั่น"), nil, "OP")
Feature(towerBox, "AutoTower", T("Auto Farm Tower", "ฟาร์มหอคอยอัตโนมัติ"), T("Top floor loot nonstop on one ticket: rare stones and season coins", "ของชั้นบนสุดไม่หยุดด้วยตั๋วใบเดียว ได้หินหายากและเหรียญซีซั่น"), function(value)
task.defer(function()
if not value then
Reicht.Util.Try(Reicht.Tower.Exit)
return
end
if not Reicht.Tower.Enter() then Notify("No tower ticket", "Warning") end
end)
end)
towerBox:AddButton({
Text = T("Rush Floors 1–50 Now", "เคลียร์หอคอยชั้น 1-50 ทันที"),
Style = "Primary",
Func = LongAction("Tower Rush", function()
return Reicht.Tower.RushAllFloors(50)
end, function(cleared)
return cleared and ("Cleared " .. cleared .. " floors!") or "Failed to rush tower"
end)
}):AddButton({
Text = T("Exit Tower Now", "ออกจากหอคอยเดี๋ยวนี้"),
Style = "Warning",
Func = function()
Options.AutoTower:SetValue(false)
task.spawn(Reicht.Util.Try, Reicht.Tower.Exit)
end
})
local goodLabels, goodIds = Source(Reicht.Season.Goods)
local goodDefault = {}
for label, goodId in pairs(goodIds) do
if opt.SeasonGoods[goodId] then table.insert(goodDefault, label) end
end
Feature(towerBox, "AutoSeason", T("Auto Season", "ซีซั่นอัตโนมัติ"), T("Daily ticket, pass rewards, spins and shop", "ตั๋วรายวัน รางวัลพาส สุ่ม และร้าน"))
towerBox:AddButton({ Text = T("Season Now", "ซีซั่นเดี๋ยวนี้"), Func = Action(Reicht.Season.Step) })
Check(towerBox, "SeasonSpin", T("Auto Spin Tickets", "สุ่มตั๋วอัตโนมัติ"))
NumberInput(towerBox, "SeasonSpinBatch", T("Spins Per Cycle", "สุ่มต่อรอบ"), T("1–50; remaining tickets continue next cycle", "1–50 ตั๋วที่เหลือสุ่มรอบถัดไป"), 1)
towerBox:AddDropdown("SeasonGoods", {
Text = T("Shop Items To Buy", "ของในร้านที่จะซื้อ"),
Values = goodLabels,
Multi = true,
Default = goodDefault,
Searchable = #goodLabels > 8,
Callback = function(selected)
local wanted = {}
for label, on in pairs(selected) do
if on and goodIds[label] then wanted[goodIds[label]] = true end
end
opt.SeasonGoods = wanted
end,
})
end
local function BuildSpawn(tab)
local spawnBox = tab:AddLeftGroupbox(T("Ore & Loot Spawner", "เสกแร่และไอเทม"), nil, "OP")
Feature(spawnBox, "TurboSpawn", T("Continuous Turbo Spawner", "เสกของรัวต่อเนื่อง"), T("Continuously streams selected or top tier loot directly into your backpack", "ฟาร์มเสกไอเทมที่เลือกหรือไอเทมระดับสูงเข้ากระเป๋าต่อเนื่องแบบไม่หยุด"))
Pick(spawnBox, "SpawnItem", T("Ore / Item / Pet", "แร่ / ไอเทม / สัตว์เลี้ยง"), T("Every ore, egg, fruit, rune and pet; farmed into inventory", "แร่ ไข่ ผลไม้ รูน และสัตว์เลี้ยงทั้งหมด ดึงเข้ากระเป๋าทันที"), Reicht.Spawn.Choices, true)
Decorate("SpawnItem", function(label) local entry = State.SpawnLabels[label]; return entry and entry.id end)
NumberInput(spawnBox, "SpawnAmount", T("Amount", "จำนวน"), T("Target amount to acquire (up to 1,000,000)", "จำนวนที่ต้องการได้ (สูงสุด 1,000,000)"), 1)
spawnBox:AddButton({ Text = T("Spawn Selected Item", "เสกไอเทมที่เลือก"), Style = "Primary", Func = Action(function()
local picked = State.SpawnLabels[opt.SpawnItem]
if not picked then
Notify("Pick an item first", "Warning")
return
end
local acquired, outcome, reason = Reicht.Spawn.Give(picked.id, picked.kind, opt.SpawnAmount)
Notify(acquired and ("Obtained %s"):format(Reicht.Util.Abbreviate(outcome)) or (reason or "Done"), acquired and "Success" or "Warning")
end) }):AddButton(RefreshButton("SpawnItem", Reicht.Spawn.Choices))
spawnBox:AddButton({ Text = T("Spawn Tier 40-48 Ores", "เสกแร่ Tier 40-48"), Style = "Success", Func = LongAction("Max Ores", function()
return Reicht.Stage.FarmMaxOres(35)
end, function(count)
return (count or 0) > 0 and ("Spawned %d ores!"):format(count) or "Spawn finished"
end) })
spawnBox:AddButton({ Text = T("Farm All Stages (100% Drops)", "ฟาร์มทุกด่าน (ดรอป 100%)"), Style = "Success", Func = LongAction("Farm All Stages", function()
return Reicht.Stage.RushAllStages(3)
end, function(count)
return (count or 0) > 0 and ("Collected %d drops from all stages!"):format(count) or "Stage farm finished"
end) })
spawnBox:AddButton({ Text = T("Spawn Enhance Stones", "เสกหินตีบวก"), Style = "Primary", Func = LongAction("Stones", function()
local before = Reicht.Data.Count(Reicht.Data.Get(), "EnhantStone_1")
Reicht.Stage.FarmStones(Reicht.Stage.Best())
task.wait(0.3)
return Reicht.Data.Count(Reicht.Data.Get(true), "EnhantStone_1") - before
end, function(gained) return ("+%d enhance stones"):format(gained or 0) end) })
spawnBox:AddButton({ Text = T("Spawn Stage Loot", "เสกของด่าน"), Func = LongAction("Stage Loot", function()
local before = Reicht.Data.Count(Reicht.Data.Get(), "Coin")
Reicht.Stage.BattleStep()
task.wait(0.3)
return Reicht.Data.Count(Reicht.Data.Get(true), "Coin") - before
end, function(gained) return ("+%d coins"):format(gained or 0) end) })
local gearBox = tab:AddLeftGroupbox(T("Target Gear", "หลอมอาวุธและชุดเป้าหมาย"), nil, "OP")
local function LoadGearList(slot)
task.defer(function()
local ok, labels = pcall(Reicht.Spawn.GearChoices, slot)
if ok then
Later(SetList, "SpawnGear", labels, true)
Later(Decorate, "SpawnGear", function(label)
local gear = State.GearLabels and State.GearLabels[label]
return gear and gear.id
end)
else
warn("[LootToForge] gear list:", labels)
end
end)
end
opt.GearSlot = Config.GearTypes[1]
gearBox:AddDropdown("GearSlot", {
Text = T("Type", "ประเภท"),
Values = Config.GearTypes,
Default = 1,
NoSave = true,
Callback = function(value)
opt.GearSlot = value
LoadGearList(value)
end,
})
opt.SpawnGear = nil
gearBox:AddDropdown("SpawnGear", {
Text = T("Gear", "อุปกรณ์"),
Description = T("Strongest first. Exclusive gear is shop only", "แรงสุดอยู่บน ของ Exclusive มีแค่ในร้าน"),
Values = { "..." },
Default = 1,
Searchable = true,
NoSave = true,
Callback = function(value)
opt.SpawnGear = value
end,
})
LoadGearList(opt.GearSlot)
NumberInput(gearBox, "GearCopies", T("Copies", "จำนวนชิ้น"), nil, 1)
gearBox:AddButton({ Text = T("Forge Target Gear", "หลอมอุปกรณ์เป้าหมาย"), Style = "Primary", Func = LongAction("Index", function()
local gear = State.GearLabels[opt.SpawnGear]
return gear and Reicht.Index.Hunt(gear, math.max(1, math.floor(opt.GearCopies)))
end, function(got)
return got and "Target forged!" or "Not all copies this time, press again"
end) })
gearBox:AddButton({ Text = T("Forge Set", "หลอมเซ็ตอุปกรณ์"), Func = LongAction("Index", Reicht.Spawn.BestSet, function(made)
return ("Forged and equipped %d/3 pieces"):format(made or 0)
end) })
gearBox:AddButton({ Text = T("1-Click Forge & Max Full Set", "หลอมและอัปเกรดเซ็ตสูงสุด 1-คลิก"), Style = "Success", Func = LongAction("Full Set", Reicht.Spawn.FullGodSet, function(made)
return ("Forged, equipped, enhanced +20, and enchanted %d pieces!"):format(made or 0)
end) })
gearBox:AddButton({ Text = T("Buy Exclusive Gear", "ซื้อของ Exclusive"), Func = LongAction("Tower", Reicht.Season.BuyExclusive, function(bought)
return (bought or 0) > 0 and ("Bought %d exclusive pieces"):format(bought) or "Already bought this refresh"
end) })
gearBox:AddButton({ Text = T("Toggle Weapon Mutant Form (A/B)", "สลับร่างมิวแทนท์อาวุธ (A/B)"), Func = Action(function()
local ok, form = Reicht.Gear.SwitchForm("Weapon")
Notify(ok and ("Switched weapon to Mutant " .. form) or (form or "Failed to switch"), ok and "Success" or "Warning")
end) })
gearBox:AddButton({ Text = T("Roll Extra Skill (Slot 2)", "สุ่มสกิลช่องพิเศษ (ช่อง 2)"), Style = "Primary", Func = Action(function()
local ok, res = Reicht.Gear.RollSkillSlot2()
Notify(ok and ("Skill Slot 2: " .. tostring(res)) or (res or "Failed to roll"), ok and "Success" or "Warning")
end) })
local rejoinBox = tab:AddRightGroupbox(T("Rejoin Pass & Tickets", "Rejoin รับตั๋ว & Season Pass"), nil, "OP")
rejoinStatusLabel = rejoinBox:AddLabel("Coins: - · Tickets: - · Race Rolls: - · Protects: -")
Feature(rejoinBox, "AutoRejoinSeason", T("Loop Auto Rejoin & Season Pass", "วนลูป Auto Rejoin + รับ Season Pass ต่อเนื่อง"), T("Continuously claims pass, buys selected tickets/scrolls, and rejoins/hops", "วนลูปรับพาส แลกตั๋ว/กันแตก และรีจอย/ย้ายเซิร์ฟต่อเนื่องไม่หลุดสคริปต์"), function(value)
if value then
Reicht.Season.RunRejoinLoop()
else
Reicht.Season.SaveRejoinPersistence(false)
end
end)
Check(rejoinBox, "RejoinClaimPass", T("Auto Claim Season Pass Rewards", "รับรางวัล Season Pass อัตโนมัติ"))
rejoinBox:AddSlider("RejoinDelay", {
Text = T("Rejoin Delay Seconds", "เวลารอก่อนเริ่มทำ Rejoin (วินาที)"),
Description = T("Seconds to wait before rejoining/hopping", "เวลารอก่อนเริ่มรีจอยหรือย้ายเซิร์ฟเวอร์"),
Min = 0,
Max = 30,
Default = opt.RejoinDelay,
Rounding = 0,
Suffix = " s",
Callback = function(value)
opt.RejoinDelay = tonumber(value) or 3
end,
})
local modeValues = { "Hop (สุ่มเซิร์ฟใหม่)", "Same (เซิร์ฟเดิม)" }
rejoinBox:AddDropdown("RejoinMode", {
Text = T("Rejoin Mode", "โหมด Rejoin"),
Values = modeValues,
Default = opt.RejoinMode == "Same" and 2 or 1,
Callback = function(value)
opt.RejoinMode = (value and value:find("Same")) and "Same" or "Hop"
end,
})
Check(rejoinBox, "RejoinBuyTickets", T("Use 800 SC: Season Wheel Ticket", "ใช้ 800 SC แลกตั๋ววงล้อ Season"))
Check(rejoinBox, "RejoinBuyRaceRoll", T("Use 1,000 SC: Race Reroll Ticket", "ใช้ 1,000 SC แลกตั๋วสุ่มเผ่า"))
Check(rejoinBox, "RejoinBuyProtect", T("Use 1,500 SC: Protect Scroll", "ใช้ 1,500 SC แลกคัมภีร์กันแตก"))
Check(rejoinBox, "RejoinRestock", T("Restock Every Round", "เติมสต็อกทุกรอบ"))
Check(rejoinBox, "RejoinSpinWheel", T("Auto Spin in Season Pass", "สุ่มวงล้อใน Season Pass อัตโนมัติ (ปั๊มกันแตก/สุ่มเผ่า)"))
Check(rejoinBox, "RejoinAutoFarmCoins", T("Auto Farm SC If Needed", "ฟาร์มเหรียญ SC อัตโนมัติถ้าไม่พอ"))
rejoinBox:AddButton({
Text = T("Exchange Selected Now", "แลกของที่เลือกเดี๋ยวนี้"),
Style = "Primary",
Func = LongAction("Exchange Goods", Reicht.Season.ExchangeSelectedNow, function(bought, reason)
return (bought or 0) > 0 and ("Exchanged " .. bought .. " items successfully!") or (reason or "No exchange: check Season Coins and shop stock")
end)
})
local coinBox = tab:AddRightGroupbox(T("Season Coins & Tower", "เหรียญซีซั่นและหอคอย"), nil, "OP")
Feature(coinBox, "AutoSeasonCoins", T("Auto Farm Season Coins (Dungeon)", "ฟาร์มเหรียญซีซั่นต่อเนื่อง (ในดันเจี้ยน)"), T("Continuously runs Floor 50 burst in dungeon to farm Season Coins nonstop", "วิ่งสแปมดันเจี้ยนชั้น 50 ปั๊มเหรียญซีซั่นต่อเนื่องไม่หยุด"))
NumberInput(coinBox, "SeasonCoinTarget", T("Coin Target Amount", "จำนวนเหรียญที่ต้องการเสก"), T("Target number of Season Coins to spawn/farm", "จำนวนเหรียญ Season Coin ที่ต้องการฟาร์ม"), 200000)
coinBox:AddButton({ Text = T("Spawn Season Coins Now", "เสกเหรียญซีซั่นเดี๋ยวนี้"), Style = "Primary", Func = LongAction("Spawn Coins", function()
return Reicht.Tower.FarmCoins(opt.SeasonCoinTarget)
end, function(gained)
return (gained or 0) > 0 and ("+ %s Season Coins!"):format(Reicht.Util.Abbreviate(gained)) or "Spawn completed"
end) })
coinBox:AddButton({ Text = T("Farm Rare Enhance Stones Now", "ฟาร์มหินตีบวกหายากเดี๋ยวนี้"), Style = "Secondary", Func = LongAction("Tower Loot", function()
local before = Reicht.Data.Count(Reicht.Data.Get(), "EnhantStone_2")
Reicht.Tower.FarmStep()
task.wait(0.3)
return Reicht.Data.Count(Reicht.Data.Get(true), "EnhantStone_2") - before
end, function(gained) return ("+%d rare stones"):format(gained or 0) end) })
coinBox:AddButton({ Text = T("Spawn 50x Tier 3 Stones Now", "เสกหิน Tier 3 ทันที (50 ก้อน)"), Style = "Success", Func = LongAction("Spawn Stones", function()
return Reicht.Tower.SpawnStonesInstant(35)
end, function(count)
return (count or 0) > 0 and ("Spawned %d Tier 3 Stones!"):format(count) or "Spawn completed"
end) })
local potionBox = tab:AddRightGroupbox(T("Potions", "ยา"), nil, "OP")
NumberInput(potionBox, "PotionAmount", T("Potion Amount", "จำนวนยา"), T("Amount to consume for extending active buffs", "จำนวนยาที่จะใช้เพื่อต่อเวลาบัฟ"), 1)
potionBox:AddButton({ Text = T("Extend All Buff Times", "เพิ่มเวลาบัฟยาทุกชนิด"), Style = "Primary", Func = LongAction("Potion Time", function()
return Reicht.Potion.Extend(opt.PotionAmount)
end, function(changed) return ("Extended %d potion buffs"):format(changed or 0) end) })
local tokenBox = tab:AddRightGroupbox(T("Token Shop", "ร้าน Token"), nil, "OP")
Feature(tokenBox, "AutoTokenShop", T("Auto Mystery Shop", "ร้านลึกลับอัตโนมัติ"), T("Reveals cards and buys selected goods using owned tokens", "เปิดการ์ดและซื้อของที่เลือกด้วย Token ที่มี"))
Check(tokenBox, "TokenReveal", T("Auto Reveal Cards", "เปิดการ์ดอัตโนมัติ"))
Check(tokenBox, "TokenSkipOwned", T("Skip Owned Goods", "ข้ามของที่มีแล้ว"))
local tokenLabels, tokenIds = Source(Reicht.TokenShop.Choices)
tokenBox:AddDropdown("TokenTargets", {
Text = T("Buy These Goods (Empty = All)", "ของที่จะซื้อ (ว่าง = ทั้งหมด)"), Values = tokenLabels,
Multi = true, Default = {}, Searchable = true,
Callback = function(selected)
local ids = {}
for label, on in pairs(selected) do if on and tokenIds[label] then ids[tokenIds[label]] = true end end
opt.TokenTargets = ids
end,
})
tokenBox:AddButton({ Text = T("Buy All Now", "ซื้อทั้งหมดเดี๋ยวนี้"), Func = LongAction("Token Shop", Reicht.TokenShop.BuyAll, function(bought)
return (bought or 0) > 0 and ("Bought %d items"):format(bought) or "No purchase: check tokens, ownership and selected goods"
end) })
end
local function BuildGear(tab)
local gearBox = tab:AddLeftGroupbox(T("Max Gear", "อุปกรณ์สูงสุด"))
Feature(gearBox, "MaxGear", T("Max Gear", "อุปกรณ์สูงสุด"),
T("Best gear and runes, enhanced to your target. Finds anything missing by itself", "ของดีสุด รูนดีสุด ตีบวกถึงเป้า ขาดอะไรหาเองหมด"),
function()
State.GearForged = false
end)
Check(gearBox, "GearForge", T("Forge gear automatically", "หลอมของอัตโนมัติ"))
Check(gearBox, "GearEnchant", T("Equip runes automatically", "ใส่รูนอัตโนมัติ"))
Check(gearBox, "GearEnhance", T("Enhance automatically", "ตีบวกอัตโนมัติ"))
gearBox:AddSlider("EnhanceTarget", {
Text = T("Enhance Target", "ตีบวกถึง"),
Description = T("Above +10 the success rate gets very low and can take a long time", "เกิน +10 โอกาสสำเร็จต่ำมาก อาจใช้เวลานาน"),
Min = 5, Max = 20, Default = opt.EnhanceTarget, Rounding = 0, Prefix = "+",
Callback = function(value)
opt.EnhanceTarget = value
end,
})
local runes = Reicht.Gear.RuneOrder()
opt.EnchantPriority = table.clone(runes)
gearBox:AddDropdown("EnchantPriority", {
Text = T("Runes To Use", "รูนที่ใช้"),
Description = T("Stronger runes go in first", "รูนที่แรงกว่าใส่ก่อน"),
Values = runes,
Multi = true,
Default = runes,
Searchable = #runes > 8,
Callback = function(selected)
local order = {}
for _, stoneId in ipairs(runes) do
if selected[stoneId] then order[#order + 1] = stoneId end
end
if #order == 0 then Notify("No rune selected, using all runes", "Warning") end
opt.EnchantPriority = order
end,
})
local forgeBox = tab:AddLeftGroupbox(T("Manual Forge", "หลอมแบบกำหนดเอง"))
local targetNames = {}
for _, target in ipairs(Config.ForgeTargets) do
targetNames[#targetNames + 1] = target.name
end
forgeBox:AddDropdown("ForgeTarget", {
Text = T("Target Gear", "อุปกรณ์ที่จะหลอม"),
Values = targetNames,
Default = 1,
Callback = function(value)
opt.ForgeTarget = value or opt.ForgeTarget
end,
})
Pick(forgeBox, "ForgeOre", T("Ore To Use", "แร่ที่ใช้หลอม"), T("Uses owned ore and farms missing stock", "ใช้แร่ที่มีและฟาร์มส่วนที่ขาด"), Reicht.Ore.ForgeChoices, nil)
Decorate("ForgeOre", OreId)
Feature(forgeBox, "AutoForge", T("Auto Forge", "หลอมอัตโนมัติ"), T("Forges the target gear nonstop", "หลอมอุปกรณ์ที่เลือกไม่หยุด"))
forgeBox:AddButton({ Text = T("Forge Now", "หลอมเดี๋ยวนี้"), Style = "Primary", Func = Action(Reicht.Forge.Step) }):AddButton({ Text = T("Bulk Forge (25x) Now", "หลอมรัว 25 ชิ้นทันที"), Style = "Danger", Func = LongAction("BulkForge", function()
return Reicht.Forge.BulkForge(25)
end, function(count)
return count and count > 0 and ("Bulk forged %d items!"):format(count) or "Not enough ore for bulk forge"
end) })
forgeBox:AddSlider("ForgePerTick", {
Text = T("Forges Per Round", "หลอมต่อรอบ"),
Min = 1, Max = 50, Default = opt.ForgePerTick, Rounding = 0,
Callback = function(value)
opt.ForgePerTick = value
end,
})
Check(forgeBox, "ForgeSellJunk", T("Sell worse gear right away", "ขายของที่แย่กว่าที่ใส่ทันที"))
Toggle(forgeBox, "BestOreFirst", T("Spend High Tier Ore First", "ใช้แร่ระดับสูงก่อน"), T("Off = spend the weakest ore first", "ปิด = ใช้แร่ที่อ่อนที่สุดก่อน"))
MultiSelect(forgeBox, "ForgeRarities", T("Forge Ore Rarity", "rarity แร่ที่ใช้หลอม"), T("Only these ore rarities are used for forging", "ใช้แร่เฉพาะ rarity ที่เลือกในการหลอม"), rarityNames)
NumberInput(forgeBox, "KeepPerOre", T("Keep Per Ore", "เก็บแร่ไว้ชนิดละ"), T("Never forge below this amount of each ore", "ไม่หลอมจนแร่แต่ละชนิดต่ำกว่าจำนวนนี้"))
local formBox = tab:AddRightGroupbox(T("Dual Form & Equip", "สลับร่างและใส่ของ"))
Feature(formBox, "AutoEquip", T("Auto Equip", "ใส่ของอัตโนมัติ"), T("Always wears your strongest weapon, armor and hat, counting enhance level", "ใส่อาวุธ เกราะ และหมวกที่แรงที่สุดเสมอ นับระดับตีบวกด้วย"))
formBox:AddButton({ Text = T("Equip Now", "ใส่ของเดี๋ยวนี้"), Func = function()
task.defer(function()
local changed = Reicht.Gear.EquipBest()
Notify(changed > 0 and ("Equipped %d better item(s)"):format(changed) or "Already wearing your best gear")
end)
end })
formBox:AddDivider()
for _, slot in ipairs(Config.GearTypes) do
formBox:AddButton({ Text = T("Switch " .. slot .. " Form", "สลับร่าง " .. slot), Func = Action(function()
local changed = Reicht.Gear.SwitchForm(slot)
Notify(changed and "Form switched" or "Equip dual-form gear in this slot first", changed and "Success" or "Info")
end) })
end
formBox:AddDivider()
formBox:AddDropdown("EnhanceSlot", {
Text = T("Enhance Slot", "ช่องที่ตีบวก"),
Values = Config.GearTypes,
Default = opt.EnhanceSlot,
Callback = function(value)
opt.EnhanceSlot = value or opt.EnhanceSlot
end,
})
formBox:AddButton({ Text = T("Enhance To Target", "ตีบวกถึงเป้า"), Style = "Primary", Func = LongAction("Enhance", function()
return Reicht.Gear.EnhanceSlot(opt.EnhanceSlot, opt.EnhanceTarget)
end, function(level) return level and ("%s is +%d"):format(opt.EnhanceSlot, level) or "Nothing equipped there" end) })
formBox:AddButton({ Text = T("Safe Enhance All +20 Now", "ตีบวกทุกช่องถึง +20 ทันที (กันแตก)"), Style = "Danger", Func = LongAction("SafeEnhance", function()
return Reicht.Gear.EnhanceToMax(20)
end, function(count)
return count and count > 0 and ("Enhanced gear %d times safely!"):format(count) or "Already at max level or no stones"
end) })
local sellBox = tab:AddRightGroupbox(T("Auto Sell", "ขายอัตโนมัติ"))
Feature(sellBox, "AutoSell", T("Auto Sell", "ขายอัตโนมัติ"), T("Sells gear that matches your filters. Equipped gear is never sold", "ขายอุปกรณ์ที่ตรงตัวกรอง ของที่ใส่อยู่จะไม่ขาย"))
sellBox:AddButton({ Text = T("Sell All Now", "ขายทั้งหมดเดี๋ยวนี้"), Style = "Primary", Func = Action(function()
Reicht.Sell.Run(Reicht.Data.Get())
Notify("Sold", "Coin")
end) })
sellBox:AddButton({ Text = T("Sell All Unlocked Gear Now", "ขายอุปกรณ์ที่ไม่ได้ล็อคทั้งหมดเดี๋ยวนี้"), Style = "Danger", Func = Action(function()
if Reicht.Sell.All() then
Notify("Cleared unlocked gear!", "Success")
end
end) })
MultiSelect(sellBox, "SellTypes", T("Sell Item Types", "ประเภทที่จะขาย"), nil, Config.GearTypes)
MultiSelect(sellBox, "SellRarities", T("Sell Rarity Filter", "กรอง rarity ที่จะขาย"), T("Only sell these rarities", "ขายเฉพาะ rarity ที่เลือก"), rarityNames)
NumberInput(sellBox, "KeepPerItem", T("Keep Per Item", "เก็บไว้ชิ้นละ"), T("Keeps this many of each item, highest enhance first", "เก็บแต่ละไอเทมไว้ตามจำนวนนี้ เลือกตัวตีบวกสูงสุดก่อน"))
local indexBox = tab:AddRightGroupbox(T("Index", "สมุดสะสม"))
MultiSelect(indexBox, "IndexTypes", T("Index Types", "ประเภทที่จะเก็บ"), nil, Config.GearTypes)
Pick(indexBox, "MissingItem", T("Missing Item", "ของที่ยังไม่มี"), T("Chance shown is per forge with the best ore", "เปอร์เซ็นต์ = โอกาสต่อการหลอมหนึ่งครั้งด้วยแร่ที่ดีที่สุด"), function()
return { "..." }
end, true)
task.defer(function()
local ok, labels = pcall(Reicht.Index.Choices)
if ok then
Later(SetList, "MissingItem", labels, true)
else
warn("[LootToForge] index list:", labels)
end
end)
indexBox:AddButton({ Text = T("Get Selected", "หาชิ้นนี้"), Style = "Primary", Func = LongAction("Index", function()
local gear = State.MissingLabels[opt.MissingItem]
return gear and Reicht.Index.Hunt(gear)
end, function(got)
Later(SetList, "MissingItem", (Source(Reicht.Index.Choices)))
return got and "Got it!" or "Not found this time, press again"
end) }):AddButton(RefreshButton("MissingItem", Reicht.Index.Choices))
Feature(indexBox, "AutoIndex", T("Auto Complete Index", "เก็บสมุดสะสมอัตโนมัติ"), T("Forges every missing weapon, armor and hat, then claims rewards", "หลอมอาวุธ เกราะ หมวกที่ยังไม่มีทุกชิ้น แล้วรับรางวัล"), nil, true)
indexBox:AddButton({ Text = T("Collect All Ores", "เก็บแร่ทุกชนิด"), Func = LongAction("Ores", Reicht.Index.CollectOres, function()
local count, level = Reicht.Index.Progress()
return ("Index %d, level %d"):format(count, level)
end) }):AddButton({ Text = T("Claim Rewards", "รับรางวัล"), Style = "Success", Func = Action(Reicht.Index.ClaimAll) })
end
local function BuildPet(tab)
local hatchBox = tab:AddLeftGroupbox(T("Egg Hatchery & Farm", "ฟักไข่และฟาร์มไข่"), nil, "OP")
Toggle(hatchBox, "SkipEggAnim", T("Skip Egg Cutscene", "ข้ามฉากเปิดไข่"), T("Hides the egg opening cutscene for instant results", "ซ่อนฉากเปิดไข่เพื่อให้ได้ผลลัพธ์ทันที"))
hatchBox:AddButton({ Text = T("Open Ready Eggs Now", "เปิดไข่ที่พร้อมเดี๋ยวนี้"), Style = "Primary", Func = Action(function()
local opened, hatched = Reicht.Pet.HatchStep()
Notify(("Opened %d eggs, Incubating %d eggs"):format(opened or 0, hatched or 0), "Success")
end) })
hatchBox:AddButton({ Text = T("Farm & Fill Crown Eggs (Egg2)", "ฟาร์มและเติมไข่ Egg2 เต็มตู้"), Style = "Success", Func = LongAction("Farm Eggs", function()
local eggs, foods = Reicht.Stage.FarmEggsAndFood(6)
return eggs, foods
end, function(eggs, foods)
return (eggs or 0) > 0 and ("Collected %d eggs & %d foods!"):format(eggs or 0, foods or 0) or "Egg farm complete"
end) })
hatchBox:AddButton({ Text = T("Refill 20 Eggs & Fruits Burst", "เติมไข่และผลไม้ 20 ชิ้น (เต็มกระเป๋า)"), Func = LongAction("Refill", function()
local eggs, foods = Reicht.Stage.FarmEggsAndFood(20)
return eggs, foods
end, function(eggs, foods)
return (eggs or 0) > 0 and ("Refilled %d eggs & %d foods!"):format(eggs or 0, foods or 0) or "Refill complete"
end) })
local cleanBox = tab:AddLeftGroupbox(T("Pet Bag Cleanup", "จัดการกระเป๋าสัตว์เลี้ยง"))
local cleanRarities = Source(Reicht.Util.RarityNames)
cleanBox:AddDropdown("DeletePetRarities", {
Text = T("Protected Rarities", "ระดับความหายากที่จะเก็บไว้"),
Description = T("Selected rarities will NEVER be deleted", "ระดับที่เลือกจะไม่ถูกลบเด็ดขาด"),
Values = cleanRarities,
Multi = true,
Default = { "Legendary", "Mythic", "Eternal" },
Searchable = true,
Callback = function(selected)
opt.DeletePetRarities = selected
end,
})
cleanBox:AddButton({ Text = T("Clean Pet & Egg Bag Now", "เคลียร์กระเป๋าเดี๋ยวนี้"), Func = Action(function()
local count = Reicht.Pet.CleanBag()
Notify(("Cleaned %d low-tier pets/eggs"):format(count or 0), "Success")
end) })
local deployBox = tab:AddLeftGroupbox(T("Pet Expedition", "ส่งสัตว์เลี้ยงสำรวจ"))
deployBox:AddButton({ Text = T("Deploy & Claim Now", "ส่งสำรวจและรับรางวัลเดี๋ยวนี้"), Style = "Success", Func = Action(function()
local claimed, deployed = Reicht.Pet.DeployStep()
Notify(("Claimed: %s | Deployed: %s"):format(tostring(claimed), tostring(deployed)), "Success")
end) })
local petBox = tab:AddRightGroupbox(T("Pet Loadout & Feeding", "ใส่สัตว์เลี้ยงและให้อาหาร"), nil, "OP")
petBox:AddButton({ Text = T("Equip Best Pets Now", "ใส่สัตว์เลี้ยงเทพเดี๋ยวนี้"), Style = "Primary", Func = Action(function()
local equipped = Reicht.Pet.EquipBest()
Notify(equipped and "Equipped highest stat pets!" or "No better pets found", equipped and "Success" or "Info")
end) })
petBox:AddButton({ Text = T("Feed Pet Once", "ป้อนผลไม้หนึ่งครั้ง"), Func = Action(function()
local fed = Reicht.Pet.FeedBest()
Notify(fed and "Fed pet successfully!" or "No food or no pet equipped", fed and "Success" or "Warning")
end) })
petBox:AddButton({ Text = T("Feed All Pets to Max Level Now", "ป้อนผลไม้ให้อิ่มจนเวลตันทุกตัวทันที"), Style = "Success", Func = LongAction("Feed Pets", function()
return Reicht.Pet.FeedAllMax()
end, function(count)
return (count or 0) > 0 and ("Fed equipped pets %d times to MAX!"):format(count) or "Pets already max level or no food"
end) })
local targetBox = tab:AddRightGroupbox(T("Target Pet Hunt & Rainbow", "ล่าสัตว์เลี้ยงตามสั่งและหลอมรุ้ง"), nil, "OP")
local petLabels = Source(Reicht.Pet.Choices)
opt.TargetPet = petLabels[1]
targetBox:AddDropdown("TargetPet", {
Text = T("Target Pet", "สัตว์เลี้ยงเป้าหมาย"),
Values = petLabels,
Default = 1,
Searchable = true,
Callback = function(val) opt.TargetPet = val end,
})
Decorate("TargetPet", function(label) return State.PetTargetLabels and State.PetTargetLabels[label] and State.PetTargetLabels[label].id end)
targetBox:AddButton({ Text = T("Farm & Incubate Target Egg Now", "ฟาร์มและใส่ไข่เป้าหมายเข้าตู้เดี๋ยวนี้"), Style = "Primary", Func = LongAction("Hunt Pet", function()
local targetId = State.PetTargetLabels and State.PetTargetLabels[opt.TargetPet] and State.PetTargetLabels[opt.TargetPet].id or opt.TargetPet
local _, msg = Reicht.Pet.FarmAndHatchTarget(targetId)
return msg
end, function(msg)
return msg or "Incubator filled with target egg!"
end) })
targetBox:AddButton({ Text = T("Lock All High-Tier Pets", "ล็อคสัตว์เลี้ยงระดับแรร์ทั้งหมด"), Style = "Warning", Func = Action(function()
local locked = Reicht.Pet.LockAllGodPets()
Notify(("Locked %d high-tier pets"):format(locked or 0), "Success")
end) })
targetBox:AddButton({ Text = T("Craft Grade Up Pets Now", "อัพเกรดเกรดสัตว์เลี้ยงตอนนี้"), Style = "Success", Func = Action(function()
local upgraded = Reicht.Pet.GradeUpAll()
Notify((upgraded or 0) > 0 and ("Upgraded %d pet grades!"):format(upgraded or 0) or "No duplicates to upgrade", (upgraded or 0) > 0 and "Success" or "Info")
end) })
targetBox:AddButton({ Text = T("Craft Any Rainbow Pet Now", "ผสมสัตว์เลี้ยงระดับ Rainbow ทันที"), Style = "Primary", Func = Action(function()
Reicht.Pet.RainbowGodStep()
Notify("Rainbow craft cycle finished", "Success")
end) })
targetBox:AddButton({ Text = T("Craft Rainbow Fenrir (1-Click)", "สร้างสัตว์เลี้ยงรุ้ง 1-Click (Fenrir)"), Style = "Success", Func = LongAction("Craft Rainbow God", function()
local ok, msg = Reicht.Pet.CraftRainbowGod("Pet_Egg2_5")
return ok, msg
end, function(ok, msg)
return msg or (ok and "Crafted Rainbow Fenrir!" or "Craft cycle completed")
end) })
targetBox:AddButton({ Text = T("Craft 1-Click Rainbow Drake", "สร้างสัตว์เลี้ยงรุ้ง 1-Click (Vampire Drake)"), Style = "Primary", Func = LongAction("Craft Rainbow Drake", function()
local ok, msg = Reicht.Pet.CraftRainbowGod("Pet_Egg1_5")
return ok, msg
end, function(ok, msg)
return msg or (ok and "Crafted Rainbow Drake!" or "Craft cycle completed")
end) })
end
local function BuildProgress(tab)
local trainBox = tab:AddLeftGroupbox(T("Training", "ฝึก"), nil, "OP")
Feature(trainBox, "AutoTrain", T("Auto Train", "ฝึกอัตโนมัติ"), T("Trains at selected or best area nonstop and uses potions", "ฝึกโซนที่เลือกหรือโซนดีสุดไม่หยุด ใช้ยาให้เอง"), function(value)
task.spawn(Reicht.Util.Try, Reicht.Level.SetTraining, value)
end)
trainBox:AddDropdown("TrainArea", {
Text = T("Train Area", "เลือกโซนฝึก"),
Values = {
"Auto Best",
"Area 9 (x100 Throne)",
"Area 8 (25x)",
"Area 7 (15x)",
"Area 6 (10x)",
"Area 5 (8x)",
"Area 4 (6x)",
"Area 3 (4x)",
"Area 2 (2x)",
"Area 1 (1.5x)",
},
Default = 1,
Callback = function(value)
opt.TrainArea = value
if opt.AutoTrain then
task.spawn(Reicht.Util.Try, Reicht.Level.Enter)
end
end,
})
Feature(trainBox, "AutoClick", T("Auto Click", "คลิกอัตโนมัติ"), T("Clicks to train with maximum burst speed", "คลิกฝึกรัวระดับสูงสุดด้วยระบบเบิสต์"), function(value)
if value then Reicht.Level.StartClicking() end
end)
Check(trainBox, "ClickTurbo", T("Turbo Training Burst (20x)", "เบิสต์ฝึกพลังขั้นเทพ (20x)"))
Check(trainBox, "HyperTrain", T("Hyper-Speed Mode (50x Stream)", "โหมดความเร็วระดับไฮเปอร์ (50x)"))
Check(trainBox, "GodTrain", T("Max Training Stream (150x Token)", "สตรีมฝึกพลังสูงสุด (150x)"))
trainBox:AddCheckbox("TrainRebirthSync", {
Text = T("Auto Rebirth When Ready", "รีเบิร์ธอัตโนมัติเมื่อเลเวลถึง"),
Default = opt.AutoRebirth,
Callback = function(value)
opt.AutoRebirth = value
if Options.AutoRebirth and Options.AutoRebirth.Value ~= value then
Options.AutoRebirth:SetValue(value)
end
end,
})
local trainBtn = trainBox:AddButton({ Text = T("Train Click Now", "คลิกฝึกเดี๋ยวนี้"), Style = "Primary", Func = Action(function() Reicht.Level.ClickBurst(20) end) })
trainBtn:AddButton({ Text = T("Rebirth Now", "รีเบิร์ธเดี๋ยวนี้"), Func = Action(Reicht.Level.Rebirth) })
trainBox:AddButton({ Text = T("Burst 100B Power Now", "เบิสต์ 1 แสนล้านพลังเดี๋ยวนี้"), Style = "Danger", Func = LongAction("GodPowerBurst", function()
return Reicht.Level.GodPowerBurst(100000000000)
end, function(gained)
return gained and ("Gained +%s Power!"):format(Reicht.Util.FormatNumber(gained)) or "Train Area not ready"
end) })
local rebirthBox = tab:AddRightGroupbox(T("Rebirth", "รีเบิร์ธ"))
Feature(rebirthBox, "AutoRebirth", T("Auto Rebirth", "รีเบิร์ธอัตโนมัติ"), T("Rebirths as soon as your level is high enough", "รีเบิร์ธทันทีเมื่อเลเวลถึง"), function(value)
opt.AutoRebirth = value
if Options.TrainRebirthSync and Options.TrainRebirthSync.Value ~= value then
Options.TrainRebirthSync:SetValue(value)
end
end)
rebirthBox:AddButton({ Text = T("Rebirth Now", "รีเบิร์ธเดี๋ยวนี้"), Func = Action(Reicht.Level.Rebirth) })
local upgradeBox = tab:AddRightGroupbox(T("Upgrades", "อัปเกรด"))
MultiSelect(upgradeBox, "Upgrades", T("Upgrades To Buy", "อัปเกรดที่จะซื้อ"), nil, (Source(Reicht.Upgrade.Names)))
Feature(upgradeBox, "AutoUpgrade", T("Auto Buy Upgrades", "ซื้ออัปเกรดอัตโนมัติ"), T("Buys the selected upgrades whenever possible", "ซื้ออัปเกรดที่เลือกทุกครั้งที่ซื้อได้"))
upgradeBox:AddButton({ Text = T("Buy Upgrade Now", "ซื้ออัปเกรดเดี๋ยวนี้"), Func = Action(Reicht.Upgrade.BuySelected) })
end
local function BuildPlayer(tab)
local raceBox = tab:AddLeftGroupbox(T("Race", "เผ่า"))
local raceLabels, raceIds = Source(Reicht.Race.Choices)
local defaultRace = {}
for _, label in ipairs(raceLabels) do
local id = raceIds[label]
if id and (id:find("Eternal") or id:find("Mythic")) then table.insert(defaultRace, label) end
end
MultiSelect(raceBox, "RaceTargets", T("Target Races", "เผ่าเป้าหมาย"), T("Roll stops as soon as any of these are rolled", "หยุดสุ่มทันทีเมื่อได้เผ่าใดเผ่าหนึ่งในนี้"), raceLabels)
Options.RaceTargets:SetValue(defaultRace)
Decorate("RaceTargets", function(label) return raceIds[label] end)
raceBox:AddDropdown("RaceMinLevel", {
Text = T("Minimum Level", "เลเวลขั้นต่ำ"),
Values = { "Any Level", "Level 1+", "Level 2+", "Level 3" },
Default = 1,
Callback = function(value)
opt.RaceMinLevel = value == "Level 3" and 3 or value == "Level 2+" and 2 or value == "Level 1+" and 1 or nil
end,
})
raceBox:AddDropdown("RaceStar", {
Text = T("Minimum Stars", "ดาวขั้นต่ำ"),
Values = { "Any Star", "1 Star", "2 Stars", "3 Stars" },
Default = 1,
Callback = function(value)
opt.RaceStar = value == "3 Stars" and 3 or value == "2 Stars" and 2 or value == "1 Star" and 1 or 0
end,
})
raceBox:AddDropdown("RaceSlot", {
Text = T("Slot To Roll", "ช่องที่จะสุ่ม"),
Values = { "Equipped", "Slot 1", "Slot 2", "Slot 3" },
Default = 1,
Callback = function(value)
opt.RaceSlot = value == "Slot 1" and 1 or value == "Slot 2" and 2 or value == "Slot 3" and 3 or "Equipped"
end,
})
Feature(raceBox, "AutoRace", T("Auto Roll Race", "สุ่มเผ่าอัตโนมัติ"), T("Rolls in the background until a target race is found", "สุ่มในพื้นหลังจนกว่าจะได้เผ่าเป้าหมาย"), function(value)
if not value then return end
task.defer(function()
local outcome, detail = Reicht.Race.RollUntil()
if outcome == "got" then
Notify("Found target race!", "Success")
elseif outcome == "empty" then
Notify("Out of race rolls. Enable Buy Rolls When Empty or collect season rewards", "Warning")
elseif outcome == "blocked" then
Notify("Can't roll: " .. tostring(detail), "Warning")
end
Later(TurnOff, "AutoRace")
end)
end)
Check(raceBox, "RaceBuyRolls", T("Buy Rolls When Empty", "ซื้อ roll เมื่อหมด"))
Check(raceBox, "RaceLock", T("Lock Slot When Found", "ได้แล้วล็อกช่อง"))
Check(raceBox, "RaceProtect", T("Never Replace Mythic+", "ไม่สุ่มทับเผ่า Mythic ขึ้นไป"))
Check(raceBox, "RaceAnim", T("Show Roll Animation", "แสดงฉากสุ่ม"))
Feature(raceBox, "AutoBestRace", T("Auto Equip Rare Race", "ใส่อัตโนมัติตามความหายาก"), T("Switches to your rarest race", "สลับไปใช้เผ่าที่หายากที่สุด"))
raceBox:AddButton({ Text = T("Switch Now", "สลับเดี๋ยวนี้"), Func = Action(function()
Notify(Reicht.Race.EquipBest() and "Switched race slot" or "Already on your rarest race")
end) })
raceBox:AddButton({ Text = T("Roll Lavakin (Eternal 3★)", "สุ่ม Lavakin ทันที (Eternal 3 ดาว)"), Style = "Primary", Func = Action(function()
local ok, msg = Reicht.Race.RollLavakin()
if not ok then
Notify(msg or "Failed to start Lavakin roll", "Warning")
else
Notify("Targeting Lavakin (Eternal 3-Star)...", "Info")
if Options.AutoRace and not Options.AutoRace.Value then
Options.AutoRace:SetValue(true)
end
end
end) })
local moveBox = tab:AddRightGroupbox(T("Movement", "การเคลื่อนที่"))
HotkeyFeature(moveBox, "SpeedOn", T("Speed", "ความเร็ว"), nil, Reicht.Movement.Apply)
moveBox:AddSlider("WalkSpeed", {
Text = T("Walk Speed", "ความเร็วเดิน"),
Min = 16, Max = 250, Default = opt.WalkSpeed, Rounding = 0,
Callback = function(value)
opt.WalkSpeed = value
Reicht.Movement.Apply()
end,
})
HotkeyFeature(moveBox, "InfJump", T("Infinite Jump", "กระโดดไม่จำกัด"))
HotkeyFeature(moveBox, "FlyOn", T("Flight", "บิน"), T("Fly freely across 3D space with WASD and Space", "บินอิสระในอากาศ ควบคุมด้วย WASD และ Spacebar"), Reicht.Movement.SetFly)
moveBox:AddSlider("FlySpeed", {
Text = T("Fly Speed", "ความเร็วการบิน"),
Min = 10, Max = 250, Default = opt.FlySpeed or 60, Rounding = 0,
Callback = function(value) opt.FlySpeed = tonumber(value) or 60 end,
})
HotkeyFeature(moveBox, "Noclip", T("Noclip", "ทะลุกำแพง"), T("Walk and fly through all barriers and walls", "เดินและบินทะลุสิ่งกีดขวางทุกชนิด"), Reicht.Movement.SetNoclip)
local guardBox = tab:AddRightGroupbox(T("Survival & Combat", "เอาตัวรอด & ต่อสู้"))
local godMode = Feature(guardBox, "GodMode", T("Invincible (Triple-Layer)", "อมตะ (3 ชั้นสมบูรณ์)"), T("Pre-calc defence, health controller bypass & death event suppression", "ป้องกัน 3 ชั้น: ดาเมจเป็น 0 บล็อกเลือดลด และตัดสัญญาณตาย"), function(value)
if not value then
if not (opt.KeepOre or opt.GuaranteedCrit or (opt.DamageMultiplier and opt.DamageMultiplier > 1)) then
Reicht.Guard.Stop()
else
Reicht.Guard.UnhookDamage()
end
else
Reicht.Guard.HookDamage()
Reicht.Guard.HookCalculations()
Reicht.Guard.HookNamecall()
end
end)
NeedModule(godMode, ReplicatedStorage.CTRL.HPCTRL)
local keepOre = Feature(guardBox, "KeepOre", T("Keep Ore On Death", "ตายแล้วแร่ไม่หาย"), nil, function(value)
if not value then
if not (opt.GodMode or opt.BaitShield) then
Reicht.Guard.UnhookOreLoss()
end
elseif not Reicht.Guard.HookNamecall() then
Notify("Keep Ore On Death is not supported on this executor", "Warning")
task.defer(TurnOff, "KeepOre")
end
end)
Reicht.Compat.NeedCap(keepOre, "Namecall")
Check(guardBox, "BaitShield", T("Anti-Honeypot Shield", "บล็อกรีโมทกับดักแบน/เตะ"))
Feature(guardBox, "GuaranteedCrit", T("Guaranteed Crit (100%)", "คริติคอล 100%"), T("Guarantees critical hits on every attack and training hit", "คริติคอลทุกครั้งที่ตีและเทรน"), function(value)
if value then
Reicht.Guard.HookCalculations()
elseif not (opt.GodMode or (opt.DamageMultiplier and opt.DamageMultiplier > 1)) then
Reicht.Guard.UnhookCalculations()
end
end)
guardBox:AddSlider("DamageMultiplier", {
Text = T("Damage Multiplier", "ตัวคูณความแรงโจมตี"),
Min = 1, Max = 20, Default = opt.DamageMultiplier or 5, Rounding = 0, Suffix = "x",
Callback = function(value)
opt.DamageMultiplier = tonumber(value) or 5
if opt.DamageMultiplier > 1 then
Reicht.Guard.HookCalculations()
end
end,
})
Feature(guardBox, "AntiStun", T("Anti-Stun & Anti-Freeze", "ป้องกันสตั๊นและตรึงร่าง"), T("Immune to boss knockbacks, freeze, cutscene action-locks and walk speed reduction", "ไม่โดนสตั๊น แช่แข็ง ล็อคการขยับ และไม่โดนลดความเร็วเดิน"), function(value)
if value then
Reicht.Guard.HookAntiStun()
else
Reicht.Guard.UnhookAntiStun()
end
end)
Feature(guardBox, "NoSkillCD", T("No Skill Cooldown", "ไร้คูลดาวน์สกิล"), T("Bypasses skill cooldown and action locks for rapid casting", "ข้ามคูลดาวน์สกิลและปลดล็อคการร่ายสกิลต่อเนื่อง"), function(value)
if value then
Reicht.Guard.HookNoSkillCD()
else
Reicht.Guard.UnhookNoSkillCD()
end
end)
Check(guardBox, "AntiDebuff", T("Debuff Immunity", "ล้างดีบัฟ/ไฟ/น้ำแข็ง"))
end
local function BuildSettings(window)
local settingsTab = window:AddSettingsTab()
local runtimeBox = settingsTab:AddLeftGroupbox(T("Performance", "ประสิทธิภาพ"))
runtimeBox:AddButton({ Text = T("Retry Stopped Features", "ลองฟีเจอร์ที่หยุดอีกครั้ง"), Func = function()
table.clear(Reicht.GameLib.Failed)
table.clear(State.RemoteCache)
for key, info in pairs(State.JobStats) do
if not info.ok and Options[key] then
State.Failures[key] = nil
State.LastRun[key] = nil
Options[key]:SetValue(true)
end
end
Notify("Retry requested", "Info")
end })
local sessionBox = settingsTab:AddRightGroupbox(T("Session", "เซสชัน"))
Toggle(sessionBox, "AutoRejoin", T("Auto Rejoin", "เข้าเกมใหม่อัตโนมัติ"), T("Rejoins the game by itself after a disconnect", "หลุดแล้วเข้าเกมใหม่เอง"))
Toggle(sessionBox, "LowGraphics", T("FPS Boost", "เพิ่ม FPS"), T("Turns off 3D rendering to save CPU and GPU", "ปิดการแสดงผล 3D ประหยัด CPU/GPU"), Reicht.Session.SetLowGraphics)
sessionBox:AddButton({ Text = T("Rejoin Now", "เข้าเกมใหม่เดี๋ยวนี้"), Func = Action(Reicht.Session.Rejoin) })
sessionBox:AddButton({ Text = T("Hop To Emptiest Server", "ย้ายไปเซิร์ฟคนน้อยสุด"), Func = Action(function()
if not Reicht.Session.HopSmallest() then Notify("Server list unavailable, try again", "Warning") end
end) })
local spotBox = settingsTab:AddRightGroupbox(T("Position", "ตำแหน่ง"))
spotBox:AddButton({ Text = T("Save Position", "บันทึกตำแหน่ง"), Func = Action(function()
Notify(Reicht.Session.SavePosition() and "Position saved" or "No character", "Info")
end) }):AddButton({ Text = T("Go Back", "กลับไปจุดที่บันทึก"), Func = Action(function()
if not Reicht.Session.ReturnPosition() then Notify("Save a position first", "Warning") end
end) })
end
local noteText = {
EnhantStone_1 = "farming enhance stones",
EnhantStone_2 = "farming rare enhance stones",
Coin = "farming coins",
Enhancing = "enhancing",
NoTicket = "need a tower ticket",
Done = "all at target",
}
local function TaskText()
if State.Lock == "Index" then return "Index " .. (State.IndexNote or "planning") end
if State.Lock then return State.Lock end
if opt.MaxGear then return "Max Gear, " .. (noteText[State.GearNote] or "starting") end
return "Idle"
end
local function UpdateStatus()
local ok, profile = pcall(Reicht.Data.Get)
if not (ok and profile and statusLabel) then return end
local eco = profile.Eco or {}
local line = ("Level %d · Rebirth %d · Coins %s"):format(tonumber(eco.level) or 1, tonumber(eco.rebirth) or 0, Reicht.Util.Abbreviate(eco.coin or 0))
if (State.TowerLoot or 0) > 0 then
line ..= ("\nTower loot x%d"):format(State.TowerLoot)
end
Later(statusLabel.SetText, statusLabel, line)
local gearLine = "Equipped: " .. tostring(Reicht.Gear.EquippedNames(profile) or "None")
local petLine = tostring(Reicht.Pet.StatusText(profile) or "")
Later(gearLabel.SetText, gearLabel, gearLine .. "\n" .. petLine)
Later(taskLabel.SetText, taskLabel, "Working on: " .. tostring(TaskText() or "Idle"))
if rejoinStatusLabel then
Later(rejoinStatusLabel.SetText, rejoinStatusLabel, Reicht.Season.RejoinStatusText())
end
end
local function BuildTabs()
local Window = Library.Window
Window:AddTabSection(T("Combat & Farm", "การต่อสู้และฟาร์ม"))
local MainTab = Window:AddTab(T("Main", "หลัก"), "house", T("Status, all-in-one mode and rewards", "สถานะ โหมดทำทุกอย่าง และรางวัล"))
local CombatTab = Window:AddTab(T("Combat & Stage", "ต่อสู้และด่าน"), "swords", T("Stages, monsters, bosses, tower and season", "ด่าน มอนสเตอร์ บอส หอคอย และซีซั่น"))
local SpawnTab = Window:AddTab(T("Spawner & Drops", "เสกของและดรอป"), "target", T("Item/ore spawner, season coins, potions and shop", "เสกแร่ ไอเทม เหรียญ ยา และร้านค้า"))
Window:AddTabSection(T("Progression", "ความก้าวหน้า"))
local GearTab = Window:AddTab(T("Gear & Forge", "อุปกรณ์และหลอม"), "sword", T("Forge, max gear, auto sell and index", "หลอม อุปกรณ์สูงสุด ขาย และสมุดสะสม"))
local PetTab = Window:AddTab(T("Pets & Eggs", "สัตว์เลี้ยงและไข่"), "heart", T("Hatch eggs, equip, feed, deploy and clean pet bag", "ฟักไข่ ใส่ ให้อาหาร ส่งสำรวจ และจัดการกระเป๋า"))
local ProgressTab = Window:AddTab(T("Train & Rebirth", "ฝึกและรีเบิร์ธ"), "sliders-horizontal", T("Training, rebirth and stat upgrades", "ฝึก รีเบิร์ธ และอัปเกรดสเตตัส"))
Window:AddTabSection(T("Player & Settings", "ผู้เล่นและตั้งค่า"))
local PlayerTab = Window:AddTab(T("Player", "ผู้เล่น"), "user", T("Race, movement and survival", "เผ่า การเคลื่อนที่ และเอาตัวรอด"))
local sections = {
{ BuildMain, MainTab },
{ BuildCombat, CombatTab },
{ BuildSpawn, SpawnTab },
{ BuildGear, GearTab },
{ BuildPet, PetTab },
{ BuildProgress, ProgressTab },
{ BuildPlayer, PlayerTab },
{ BuildSettings, Window },
}
for _, section in ipairs(sections) do
Reicht.Util.Try(section[1], section[2])
end
Reicht.Util.Try(BlockMissing)
Library:Every(Config.PumpInterval, Pump)
task.spawn(function()
while State.Alive do
UpdateStatus()
task.wait(Config.StatusInterval)
end
end)
end
local function Unload()
Library:Unload()
end
Library:OnUnload(Reicht.Scheduler.Stop)
Library:OnUnload(function()
if getgenv().LootToForgeUnload == Unload then getgenv().LootToForgeUnload = nil end
getgenv().Reicht = nil
end)
getgenv().LootToForgeUnload = Unload
getgenv().Reicht = Reicht
Library:CreateWindow({
Title = "Reicht",
SubTitle = "Loot To Forge by Reicht",
MenuKey = Enum.KeyCode.LeftControl,
ConfigFolder = Config.SaveFolder,
Language = "Auto",
Theme = "Halloween",
OnUnlocked = function()
BuildTabs()
Reicht.Util.Try(Reicht.Scheduler.Boot)
Notify("Loaded", "Success")
Reicht.Util.Try(Library.LoadAutoloadConfig, Library)
if Reicht.Boss.HopWanted() and Options.BossHop then Options.BossHop:SetValue(true) end
local persist = Reicht.Season.LoadRejoinPersistence()
if persist then
if Options.RejoinDelay and persist.RejoinDelay then Options.RejoinDelay:SetValue(persist.RejoinDelay) end
if Options.RejoinMode and persist.RejoinMode then Options.RejoinMode:SetValue(persist.RejoinMode == "Same" and 2 or 1) end
if Options.RejoinClaimPass and persist.RejoinClaimPass ~= nil then Options.RejoinClaimPass:SetValue(persist.RejoinClaimPass) end
if Options.RejoinBuyTickets and persist.RejoinBuyTickets ~= nil then Options.RejoinBuyTickets:SetValue(persist.RejoinBuyTickets) end
if Options.RejoinBuyRaceRoll and persist.RejoinBuyRaceRoll ~= nil then Options.RejoinBuyRaceRoll:SetValue(persist.RejoinBuyRaceRoll) end
if Options.RejoinBuyProtect and persist.RejoinBuyProtect ~= nil then Options.RejoinBuyProtect:SetValue(persist.RejoinBuyProtect) end
if Options.RejoinRestock and persist.RejoinRestock ~= nil then Options.RejoinRestock:SetValue(persist.RejoinRestock) end
if Options.RejoinSpinWheel and persist.RejoinSpinWheel ~= nil then Options.RejoinSpinWheel:SetValue(persist.RejoinSpinWheel) end
if Options.RejoinAutoFarmCoins and persist.RejoinAutoFarmCoins ~= nil then Options.RejoinAutoFarmCoins:SetValue(persist.RejoinAutoFarmCoins) end
if Options.AutoRejoinSeason then
Options.AutoRejoinSeason:SetValue(true)
State.Opt.AutoRejoinSeason = true
task.delay(0.5, function()
Reicht.Season.RunRejoinLoop()
end)
end
end
end,
})
end
if getgenv().LootToForgeUnload then
pcall(getgenv().LootToForgeUnload)
end
pcall(ReichtBanner.Step, "Systems")
BuildInterface()
pcall(ReichtBanner.Step, "Interface")
pcall(ReichtBanner.Ready)