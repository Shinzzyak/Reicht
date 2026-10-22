if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 10035204815 then game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Ride A Pet only") return end
do
local ok, env = pcall(getgenv)
if ok and type(env) == "table" and type(env.RideAPetUnload) == "function" then
pcall(env.RideAPetUnload)
end
end
if not LPH_OBFUSCATED then
local function Passthrough(fn) return fn end
LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Library
local Reicht = setmetatable({}, {
__newindex = function(self, key, value)
rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
end,
})
Reicht.Config = {
GameId = 10035204815, PlaceId = 124216119978534,
Tag = "[RideAPet]",
Discord = "https://",
UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
LoadTimeout = 30, GameLibDeadline = 8,
AlertTries = 8, AlertGap = 1.5, WarnGap = 5,
PickupReach = 84,
PickupLimit = 90,
PickupRetryStep = 0.04,
PickupReplyTimeout = 0.6,
PickupAckWait = 0.12,
PickupTotalTimeout = 1.5,
TpSettle = 0.1, VolcanoSettle = 0.3, DismountTimeout = 10, DismountToolWindow = 2,
DropOutside = 4,
DropSettle = 0.2,
DropSettleMax = 0.35,
DropEndsSlack = 0.03,
DropAppearTimeout = 1.0,
DropLandMax = 8,
StaleDropDistance = 20,
DepositTimeout = 1.5,
RunBudget = 4.0,
DirectFactor = 2.5,
DirectFactorAfterFail = 2.0,
ReturnBackoff = { 2.0, 1.5 }, ReturnStopCount = 3, ReturnWindow = 300, ReturnDedupe = 3,
UnmountedDirect = 90, WeightPenalty = 0.01, CherubWeightPenalty = 0.0125, WeightPenaltyMax = 0.8,
ContainsSlack = 2, EdgeInset = 1, StandLift = 3,
TripCost = { Plot = 0.35, Direct = 0.62, Drop = 1.25 },
ContestWeight = 1.5, ContestWeightMax = 3, ContestHorizon = 6, UnmountedPlayerSpeed = 36,
CycleLength = 420, CycleOffset = 418.5, WaveSurge = 12, WaveWakeEarly = 2,
GoneBlacklistSec = 2,
MountTimeout = 1.5, MountTries = 3, MountGap = 0.35,
CarryDeferCap = 3,
ReturnHopMax = 400,
EggTick = 0.05, SlowTick = 1, EspTick = 0.25, EspTickMobile = 0.5,
EspRange = 4000, EspRangeMobile = 1500,
FailLimit = 5, FailWindow = 10,
PlantSpacing = 6, PlantCapDefault = 10, HatchGap = 0.3,
CollectMinPending = 60, SellRange = 9, SellBatch = 50, ConfirmWindow = 2,
ShopBuyGap = 0.15, AfkRejoinSec = 1100,
HunterHopsPerCycle = 5, HunterMinLeft = 90,
VolcanoCenter = Vector3.new(-5103, 41406, -3489), VolcanoResultTimeout = 20, VolcanoMinBreakLeft = 3,
PumpTick = 0.5, PlotRetry = 1, MobileViewport = 900,
UnloadCarryTimeout = 2,
JobTick = {
Volcano = 0.25, Halloween = 0.1, Junk = 0.25, Hatch = 1, Plant = 2, Pets = 2,
Feed = 1, Sell = 10, Fusion = 2, Economy = 3, Shop = 5, Rewards = 30, Boosts = 5, Server = 5,
Webhook = 1, Settle = 1, Kaitun = 2,
},
JobBackoff = 40,
HalloweenSettle = 0.55,
CandyPickupSettle = 0.15,
CandyCooldown = 2.1,
CandyPrepAhead = 0.8,
CandyPickupReach = 28,
CandyPickupLimit = 32,
CandyDirectFactor = 2,
CandyDirectMax = 400,
CandyDepositReach = 18,
CandyRangeDefault = 1500,
CandyCarryGoal = 6,
CandySpoilAt = 12,
CandyCollectTimeout = 2.5,
CandyDepositTimeout = 2.5,
CandySkipSec = 16,
CandyStateCache = 3,
CandyReturnFactor = 1,
CandyDepositReserve = 2,
TravelStepMax = 0.1,
TravelStopDistance = 2,
CandyPadLift = 3,
CandyPadPos = Vector3.new(-45839.9, 40368.5, -20118.0),
PortalPos = Vector3.new(-46800, 40390, -20000),
DoorCooldown = 180,
DoorStateCache = 3,
DoorStand = 6,
PumpkinCooldown = 40,
PumpkinStateCache = 3,
HalloweenPrio = 70,
HalloweenPhaseBudget = 12,
HalloweenManualTimeout = 180,
HalloweenEggGap = 3,
HalloweenPurchaseTimeout = 4,
HalloweenShopRange = 20,
HalloweenShopRetry = 8,
HalloweenZoneTries = 5,
HalloweenZoneGap = 2,
RitualRetry = 20,
RitualPrompts = 4,
RitualPromptGap = 0.4,
RitualStand = 8,
EventStreamDist = 512,
EventStreamTimeout = 5,
GroundRayUp = 30,
GroundRayDown = 60,
VolcanoStreamTimeout = 5,
VolcanoTouchEvery = 0.25,
VolcanoStepWait = 5,
VolcanoStandLift = 3,
VolcanoRetry = 30,
VolcanoDipSettle = 0.7,
VolcanoRefire = 0.3,
VolcanoTailEggs = 1,
VolcanoClaimSec = 2,
PlantReplyTimeout = 1.5,
PlantTries = 3,
EquipSettle = 0.1,
HatchPending = 5,
PlotEggsRefresh = 60, PlotFullRecheck = 10,
PlantStandLift = 3,
PlantLongGrow = 3600,
PlantLongShare = 0.5,
JunkEquipSettle = 0.1,
JunkSpacing = 0.2,
JunkSpacingMin = 0.1,
JunkSpacingMax = 1,
JunkSpacingUp = 0.05,
JunkSpacingDown = 0.02,
JunkSpacingEase = 20,
JunkPlantTimeout = 0.9,
JunkPlantFails = 8,
JunkHatchRetry = 0.8,
JunkHatchSlack = 0.02,
JunkHatchSlackMax = 0.3,
JunkHatchGapMax = 0.3,
JunkHatchGapStep = 0.02,
JunkSellEvery = 60,
JunkQueueTtl = 30,
JunkIdleCheck = 5,
JunkResyncIdle = 8,
JunkFullPause = 0.6,
JunkAutoShare = 0.2,
JunkShareSample = 200,
JunkSessionMax = 45,
JunkYieldGap = 3,
JunkBackoff = 10,
JunkRateWindow = 60,
JunkReportGap = 0.5,
JunkAnchorNear = 4,
JunkPlotShare = 0.5,
JunkYieldTo = {
"AutoEquipBest", "AutoCollectCash", "AutoFeed", "AutoFusion", "AutoPlaceEggs",
},
PetReplyTimeout = 1.5,
PetSwapGain = 1.01,
PetSpread = 0.35,
PetStandLift = 3,
PetBaseKg = 10,
PetMaxAge = 100,
CollectGap = 0.15,
FeedGap = 0.36, FeedBurst = 8, FeedMissLimit = 3, FeedReplyTimeout = 1,
TopCacheSec = 1,
AutoCollectPass = { "AutoCollect", "1940707069" },
PetAgeRefresh = 30,
PetWatchedAttrs = {
PetKey = true, PetName = true, Weight = true, BaseWeight = true, Mutation = true,
SpawnMutation = true, Age = true, BirthTime = true, Favorited = true,
},
SellReplyTimeout = 8,
SellRetry = 0.45,
SellTries = 5,
SellNear = 3,
SellPriceMult = 600,
SellStand = 5,
IncomeSettle = 1.5,
SellSettle = 0.6,
FuseSlots = 4,
FuseStand = 3,
FuseLift = 3,
FuseSettle = 0.15,
FuseReplyTimeout = 2,
FuseGap = 0.3,
FusePlaceSettle = 1,
FuseResultTimeout = 5,
WeekSec = 604800,
SellKeepTopRarities = 3,
UpgradePayback = 300,
UpgradeBatch = 25,
UpgradeGap = 0.1,
UpgradeVerify = 1.5,
UpgradeBackoff = 30,
UpgradeMaxBuy = 1000,
RebirthSaveWindow = 1800,
RebirthVerify = 3,
RebirthBackoff = 60,
ShopReplyTimeout = 3,
ShopRecheck = 300,
ClaimVerify = 2,
PromptRetry = 3600,
GroupRewardCooldown = 86400,
BoostAttributes = {
"HatchLuckEventMultiplier", "HatchLuckEventUntil", "HatchMutationEventMultiplier",
"HatchMutationEventUntil", "HatchSpeedBoostAmount", "HatchSpeedBoostUntil", "GlobalCashBoostUntil",
},
KaitunToggles = {
"AutoEggs", "EggHunter", "AutoPlaceEggs", "AutoHatch", "AutoEquipBest",
"AutoCollectCash", "AutoUpgrade", "AutoClaim", "SmartSpend",
},
KaitunHuntRarity = "Mythic",
KaitunSteerEvery = 60,
UpdateLog = {
{ "2026-10-12", "Improved Auto Candy targeting and smoother returns\nAdded Instant E and return speed controls up to 600% (default 350%)\nEvent farming now retries at a lower speed after movement rejection\nImproved Halloween egg buying and purchased egg hatching\nFixed egg delivery, hatch order, fusion claims and Kaitun target handling" },
{ "2026-10-11", "Updated Halloween candy, doors, pumpkins, event ESP and teleports\nImproved fusion eligibility and ground placement" },
},
}
Reicht.State = {
Alive = true, Connections = {}, Halted = {}, Errors = {},
Tune = { DropSettle = 0.2, ContestWeight = 1.5, DirectFactor = 2.5 },
Status = {},
PendingSet = {},
PendingToggleOff = {},
PendingNotify = {},
LastFail = nil,
Stats = { delivered = 0, lost = 0, returned = 0, plot = 0, direct = 0, drop = 0, staleDrops = 0, window = {} },
PlotEggs = {}, PlantCap = 10, Weather = {},
WarnedAt = {},
}
Reicht.Options = {}
local Config, State = Reicht.Config, Reicht.State
Config.JobTick.Eggs, Config.JobTick.Hunter = Config.EggTick, Config.EggTick
State.Tune.DropSettle = Config.DropSettle
State.Tune.ContestWeight = Config.ContestWeight
State.Tune.DirectFactor = Config.DirectFactor
State.PlantCap = Config.PlantCapDefault
Reicht.Util = {}
function Reicht.Util.Try(label, fn, ...)
local ok, err = pcall(fn, ...)
if ok then return true, err end
local now = os.clock()
if now - (State.WarnedAt[label] or -math.huge) >= Config.WarnGap then
State.WarnedAt[label] = now
warn(Config.Tag .. " " .. label .. ":", err)
end
return false, err
end
function Reicht.Util.HttpGet(url)
local ok, body = pcall(game.HttpGet, game, url)
if ok and type(body) == "string" then return body end
local requester = (syn and syn.request) or (http and http.request) or http_request or request
if not requester then return nil, "no http function" end
local sent, response = pcall(requester, { Url = url, Method = "GET" })
if not sent or type(response) ~= "table" then return nil, tostring(response) end
if response.StatusCode ~= 200 or type(response.Body) ~= "string" then
return nil, "HTTP " .. tostring(response.StatusCode)
end
return response.Body
end
function Reicht.Util.Alert(text, detail)
warn(Config.Tag, text, detail or "")
task.spawn(function()
for _ = 1, Config.AlertTries do
local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 })
if shown then return end
task.wait(Config.AlertGap)
end
end)
end
function Reicht.Util.LoadLibrary(url)
local source, why = Reicht.Util.HttpGet(url)
if not source or not source:sub(-64):find("return%s+Library%s*$") then
Reicht.Util.Alert("Could not download the menu. Check your connection and run it again.", why or "truncated download")
return nil
end
local chunk, compileErr = loadstring(source)
if type(chunk) ~= "function" then
Reicht.Util.Alert("The menu failed to load on this executor.", compileErr)
return nil
end
local ok, lib = pcall(chunk)
if not ok or type(lib) ~= "table" then
Reicht.Util.Alert("The menu failed to load on this executor.", lib)
return nil
end
return lib
end
function Reicht.Util.Copy(text)
local copier = setclipboard or toclipboard
if not copier then return false end
return (pcall(copier, text))
end
function Reicht.Util.Queue(src)
if not (Library and Library.Compat and Library.Compat.Caps.Queue) then return false end
local queue = queue_on_teleport or queueonteleport
if not queue then return false end
return (pcall(queue, src))
end
function Reicht.Util.ServerNow()
return Workspace:GetServerTimeNow()
end
function Reicht.Util.Flat(a, b)
local dx, dz = a.X - b.X, a.Z - b.Z
return math.sqrt(dx * dx + dz * dz)
end
function Reicht.Util.Format(n)
n = tonumber(n) or 0
if n ~= n or n == math.huge then return "-" end
local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }
local step = 1
repeat
if math.abs(n) < 1000 then break end
n /= 1000
step += 1
until step == #suffixes
if step == 1 then return tostring(math.floor(n)) end
return string.format("%.2f%s", n, suffixes[step])
end
function Reicht.Util.Opt(idx)
local mirrored = Reicht.Options[idx]
if mirrored ~= nil then return mirrored end
local option = Library and Library.Options and Library.Options[idx]
return option and option.Value
end
function Reicht.Util.Notify(title, text, seconds)
table.insert(State.PendingNotify, { title, text, seconds or 5 })
end
do
local camera = Workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local touch = UserInputService.TouchEnabled
local noKeys = not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
Reicht.Platform = {
Touch = touch,
Mobile = touch and (noKeys or viewport.X < Config.MobileViewport),
Console = GuiService:IsTenFootInterface(),
Viewport = viewport,
}
end
function Reicht.Util.SetFpsCap(fps)
local ok = pcall(function() setfpscap(fps) end)
return ok
end
function Reicht:Connect(signal, handler)
local conn = signal:Connect(handler)
table.insert(self.State.Connections, conn)
return conn
end
Reicht.StopOrder = {
"Kaitun", "Guard", "Eggs", "Hunter", "Volcano", "Halloween", "Prompts", "Junk", "Hatch", "Pets", "Sell", "Fusion",
"Economy", "Shop", "Rewards", "Boosts", "Troll", "Server", "Webhook", "Visual",
}
function Reicht:Unload()
if not State.Alive or State.Unloading then return end
State.Unloading = true
local try = Reicht.Util.Try
try("unload carry", function() Reicht.Eggs.FinishCarry(Config.UnloadCarryTimeout) end)
State.Alive = false
try("unload tasks", function() Reicht.Tasks.ReleaseAll("unload") end)
for _, name in ipairs(Reicht.StopOrder) do
local module = rawget(Reicht, name)
if module and module.Stop then try("unload " .. name, module.Stop) end
end
try("unload character", function() Reicht.Player:Release() end)
try("unload inventory", function() Reicht.Eggs.QuietInventory(false, true) end)
State.TeardownPending = true
if not State.TeardownConn then Reicht.Teardown() end
end
function Reicht.Teardown()
State.TeardownPending = false
if State.TeardownConn then
State.TeardownConn:Disconnect()
State.TeardownConn = nil
end
local try = Reicht.Util.Try
try("unload move", function() Reicht.Move.Restore() end)
try("unload esp", function() Reicht.Esp.Clear() end)
try("unload hooks", function() Library.Compat.RestoreAll() end)
try("unload player", function() Reicht.Player:Unbind() end)
for _, conn in ipairs(State.Connections) do
if type(conn) == "function" then conn() else conn:Disconnect() end
end
table.clear(State.Connections)
try("unload ui", function() Library:Unload() end)
end
function Reicht.BindTeardown(signal)
State.TeardownConn = signal:Connect(function()
if State.TeardownPending then Reicht.Teardown() end
end)
end
do
local ok, env = pcall(getgenv)
if ok and type(env) == "table" then
env.RideAPetUnload = function() Reicht:Unload() end
end
end
Reicht.GameLib = {
Data = {}, Svc = {}, Missing = {},
Cache = {}, NetSearched = false,
EggInfo = {}, PetInfo = {}, RarityOrder = {}, RarityRank = {}, FuseQuality = {},
Foods = {}, FoodOrder = {}, ShopItems = {}, Rebirths = { Cap = 0, Costs = {} }, RebirthReq = {},
IndexStages = {}, Mutations = {},
}
local GameLib = Reicht.GameLib
GameLib.ServiceModules = { "General", "EggCycle", "DayNight", "EggDeliveryRules", "SellValue", "PetAging", "HalloweenEvent" }
GameLib.Denied = {
Restock = true, SetOpenShop = true, RegisterSkipTarget = true, RegisterSkipAllTarget = true,
UpdatePlayerToGift = true, CanGiftGamepass = true, CmdrFunction = true, PetMove = true,
EggTimerPause = true, EggArrivalClaim = true,
["Reusable.Ban"] = true, ["Reusable.GetPlayerData"] = true, ["Reusable.InitiatePlot"] = true,
["Reusable.ClaimGroupReward"] = true, ["Reusable.ClaimEventReward"] = true, ["Reusable.Teleporting"] = true,
}
GameLib.DeniedPrefix = { "SkipGrowth" }
GameLib.ListenOnly = { Restock = true }
GameLib.Needs = {
AutoEggs = { "EggPickup", "BasketDrop", "Mounting", "GameMessage", "ActiveEggs" },
EggHunter = { "EggPickup", "BasketDrop", "ActiveEggs" },
VolcanoDip = { "EggPickup", "BasketDrop", "VolcanoDip", "VolcanoDipResult" },
VolcanoObby = { "EggPickup", "BasketDrop", "ActiveEggs" },
AutoPlaceEggs = { "EggPlaced" },
AutoHatch = { "Hatch" },
ClearJunk = { "EggPlaced", "Hatch", "SellItems", "ConfirmRequest" },
AutoEquipBest = { "PlacePet", "PickupPet" },
AutoCollectCash = { "PetCollect" },
AutoFeed = { "FeedPet" },
AutoSell = { "SellItems", "ConfirmRequest" },
AutoFusion = { "FusionPetPlace", "FusionAction" },
AutoUpgrade = { "Plot.Upgrades" },
AutoRebirth = { "Rebirth" },
AutoShop = { "ShopStock", "BuyWithCash" },
AutoClaim = { "ClaimIndexReward", "OfflineEarnings" },
AutoCandy = { "CollectCandy", "GetCandyState" },
AutoTrickOrTreat = { "KnockDoor", "GetDoorState" },
AutoPumpkin = { "SearchPumpkin", "GetPumpkinState" },
AutoHalloweenEgg = { "BuyHalloweenEgg" },
Kaitun = { "EggPickup", "BasketDrop", "ActiveEggs" },
}
function GameLib.RequireAsGame(module)
local done, ok, loaded = false, false, nil
task.spawn(function()
local switched = pcall(setthreadidentity, 2)
if switched then ok, loaded = pcall(require, module) end
done = true
end)
local deadline = os.clock() + Reicht.Config.LoadTimeout
repeat
if done then break end
task.wait()
until os.clock() > deadline
return ok, loaded
end
function GameLib.Require(module)
if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then return nil end
local ok, loaded
if Library and Library.Compat then
ok, loaded = Library.Compat.Require(module)
else
ok, loaded = pcall(require, module)
if not ok and tostring(loaded):find("non-RobloxScript", 1, true) then
ok, loaded = GameLib.RequireAsGame(module)
end
end
if ok and type(loaded) == "table" then return loaded end
warn(Reicht.Config.Tag, "require " .. module.Name .. ":", loaded)
return nil
end
function GameLib.Call(fn, ...)
if type(fn) ~= "function" then return false, "not a function" end
if Library and Library.Compat then
return pcall(Library.Compat.Call, fn, ...)
end
return pcall(fn, ...)
end
function GameLib.IsDenied(name)
if GameLib.Denied[name] then return true end
for _, prefix in ipairs(GameLib.DeniedPrefix) do
if name:sub(1, #prefix) == prefix then return true end
end
return false
end
function GameLib.NetFolder()
if GameLib.NetSearched then return GameLib.NetFolderRef end
GameLib.NetSearched = true
local packages = ReplicatedStorage:FindFirstChild("packages")
if not packages then return nil end
local direct = packages:FindFirstChild("Net")
if direct then
GameLib.NetFolderRef = direct
return direct
end
for _, node in ipairs(packages:GetDescendants()) do
if node.Name ~= "Net" then continue end
for _, child in ipairs(node:GetChildren()) do
if child.Name:sub(1, 3) == "RE/" then
GameLib.NetFolderRef = node
return node
end
end
end
return nil
end
function GameLib.Remote(name)
if GameLib.IsDenied(name) then return nil end
local cached = GameLib.Cache[name]
if cached and cached.Parent then return cached end
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local gameFolder = remotes and remotes:FindFirstChild("Game")
local reusable = remotes and remotes:FindFirstChild("Reusable")
local found
local folder, leaf = name:match("^(%w+)%.(.+)$")
if folder then
local parent = gameFolder and gameFolder:FindFirstChild(folder)
found = parent and parent:FindFirstChild(leaf)
else
found = gameFolder and gameFolder:FindFirstChild(name)
if not found and reusable and not GameLib.IsDenied("Reusable." .. name) then
found = reusable:FindFirstChild(name)
end
if not found then
local net = GameLib.NetFolder()
found = net and net:FindFirstChild("RE/" .. name)
end
end
GameLib.Cache[name] = found
return found
end
function GameLib.Listen(name)
if not GameLib.ListenOnly[name] then return GameLib.Remote(name) end
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local gameFolder = remotes and remotes:FindFirstChild("Game")
return gameFolder and gameFolder:FindFirstChild(name)
end
Reicht.Net = setmetatable({}, {
__index = function(self, name)
local remote = GameLib.Remote(name)
if remote then rawset(self, name, remote) end
return remote
end,
})
function GameLib.ActiveEggs()
local serverData = ReplicatedStorage:FindFirstChild("ServerData")
return serverData and serverData:FindFirstChild("ActiveEggs")
end
function GameLib.Plot()
local general = GameLib.Svc.General
if general and general.GetPlot then
local ok, plot = GameLib.Call(general.GetPlot, general, LocalPlayer)
if ok and typeof(plot) == "Instance" then return plot end
end
local plots = Workspace:FindFirstChild("Plots")
if not plots then return nil end
for _, plot in ipairs(plots:GetChildren()) do
local data = plot:FindFirstChild("Data")
local owner = data and data:FindFirstChild("Owner")
if owner and owner.Value == LocalPlayer then return plot end
end
return nil
end
function GameLib.Contains(bp, pos)
local rel = bp.CFrame:PointToObjectSpace(pos)
local slack = Reicht.Config.ContainsSlack
return math.abs(rel.X) <= bp.Size.X / 2 + slack and math.abs(rel.Z) <= bp.Size.Z / 2 + slack
end
function GameLib.CycleIndex()
local cycle = GameLib.Svc.EggCycle
if cycle then
local ok, index = GameLib.Call(cycle.Index)
if ok and type(index) == "number" then return index end
end
return math.floor((Reicht.Util.ServerNow() - Reicht.Config.CycleOffset) / Reicht.Config.CycleLength)
end
function GameLib.CycleLeft()
local cycle = GameLib.Svc.EggCycle
if cycle then
local ok, left = GameLib.Call(cycle.SecondsRemaining)
if ok and type(left) == "number" then return left end
end
local length = Reicht.Config.CycleLength
return length - (Reicht.Util.ServerNow() - Reicht.Config.CycleOffset) % length
end
function GameLib.Odds(egg, mult)
local hatchLuck, eggs = GameLib.Data.HatchLuck, GameLib.Data.Eggs
local info = GameLib.EggInfo[egg]
if not (hatchLuck and hatchLuck.GetOdds and eggs and eggs[egg] and info) then return nil end
local ok, odds = GameLib.Call(hatchLuck.GetOdds, info.luck * (mult or 1), eggs[egg])
if not ok or type(odds) ~= "table" then return nil end
local out = {}
for _, row in ipairs(odds) do
if type(row) == "table" and row.PetName then
out[#out + 1] = { row.PetName, tonumber(row.Chance) or 0 }
end
end
return out
end
function GameLib.GrowthSeconds(base, weight)
local general = GameLib.Data.General
if not (general and general.GrowthTimeFor) then return nil end
local ok, total = GameLib.Call(general.GrowthTimeFor, base, weight)
return ok and tonumber(total) or nil
end
function GameLib.GrowthLeft(placeTime, base, weight)
local dayNight = GameLib.Svc.DayNight
local total = GameLib.GrowthSeconds(base, weight)
if not (total and dayNight and dayNight.GrowthElapsed) then return nil end
local ok, elapsed = GameLib.Call(dayNight.GrowthElapsed, placeTime)
if not ok then return nil end
return total - (tonumber(elapsed) or 0)
end
function GameLib.GrowthRealLeft(placeTime, base, weight)
local dayNight = GameLib.Svc.DayNight
local total = GameLib.GrowthSeconds(base, weight)
if not (total and dayNight and dayNight.GrowthRealRemaining) then return nil end
local ok, left = GameLib.Call(dayNight.GrowthRealRemaining, placeTime, total)
return ok and tonumber(left) or nil
end
function GameLib.LoadFolder(folder, names, into, label, stopAt)
for _, name in ipairs(names) do
local module = folder and folder:FindFirstChild(name)
if module and os.clock() < stopAt then into[name] = GameLib.Require(module) end
if not into[name] then GameLib.Missing[label .. "." .. name] = module and "load timeout" or "module not found" end
end
end
function GameLib.LoadDataTree(folder, prefix, stopAt)
for _, child in ipairs(folder:GetChildren()) do
if os.clock() >= stopAt then return end
local key = prefix .. child.Name
if child:IsA("ModuleScript") then
if GameLib.Data[key] == nil then
GameLib.Data[key] = GameLib.Require(child)
if not GameLib.Data[key] then GameLib.Missing["GameData." .. key] = "require failed" end
end
elseif child:IsA("Folder") then
GameLib.LoadDataTree(child, key .. ".", stopAt)
end
end
end
function GameLib.LoadModules()
local deadline = Reicht.Config.GameLibDeadline
local dataFolder = ReplicatedStorage:WaitForChild("GameData", deadline)
local svcFolder = ReplicatedStorage:FindFirstChild("GameServices") or ReplicatedStorage:WaitForChild("GameServices", 1)
local stopAt = os.clock() + deadline
if dataFolder then
GameLib.LoadDataTree(dataFolder, "", stopAt)
local halloween = dataFolder:FindFirstChild("Halloween")
local debuffs = halloween and halloween:FindFirstChild("Debuffs")
if debuffs and GameLib.Data["Halloween.Debuffs"] == nil then
GameLib.Data["Halloween.Debuffs"] = GameLib.Require(debuffs)
end
end
GameLib.LoadFolder(svcFolder, GameLib.ServiceModules, GameLib.Svc, "GameServices", stopAt)
end
local function BuildRarities()
local order, rank = GameLib.RarityOrder, GameLib.RarityRank
table.clear(order)
table.clear(rank)
local general = GameLib.Data.General or {}
local levels = general.RarityLevelRequirementMultiplier or {}
local weight = {}
for rarity, level in pairs(levels) do
weight[rarity] = tonumber(level) or 0
end
local floor = {}
for _, pet in pairs(GameLib.PetInfo) do
floor[pet.rarity] = math.min(floor[pet.rarity] or math.huge, pet.income)
end
for _, egg in pairs(GameLib.EggInfo) do
floor[egg.rarity] = floor[egg.rarity] or math.huge
end
for rarity, income in pairs(floor) do
if not weight[rarity] then weight[rarity] = 1e9 + math.min(income, 1e12) end
end
for rarity in pairs(weight) do
order[#order + 1] = rarity
end
table.sort(order, function(a, b) return weight[a] < weight[b] end)
for index, rarity in ipairs(order) do
rank[rarity] = index
end
end
local function BuildEggsAndPets()
table.clear(GameLib.EggInfo)
table.clear(GameLib.PetInfo)
local breakTimer = (GameLib.Data.General or {}).EggBreakTimer or {}
for name, egg in pairs(GameLib.Data.Eggs or {}) do
if type(egg) ~= "table" then continue end
local rarity = egg.Rarity or "Common"
GameLib.EggInfo[name] = {
rarity = rarity,
luck = tonumber(egg.Luck) or 0,
growth = tonumber(egg.GrowthTime) or 0,
breakSec = tonumber(breakTimer[rarity]) or 0,
ethereal = rarity == "Ethereal",
volcanic = egg.RequiresVolcano == true,
}
end
for name, pet in pairs(GameLib.Data.Pets or {}) do
if type(pet) ~= "table" or not pet.Rarity then continue end
GameLib.PetInfo[name] = {
rarity = pet.Rarity,
speed = tonumber(pet.Speed) or 0,
income = tonumber(pet.Income) or 0,
fusionOnly = pet.FusionOnly == true,
moveSpeed = tonumber(pet.MovementSpeed) or 0,
}
end
end
local function BuildEconomy()
local data = GameLib.Data
table.clear(GameLib.Foods)
table.clear(GameLib.FoodOrder)
for name, food in pairs(data.Foods or {}) do
if type(food) ~= "table" then continue end
GameLib.Foods[name] = { cost = tonumber(food.Cost) or 0, xp = tonumber(food.XP) or 0, rarity = food.Rarity, noFeedAll = food.NoFeedAll == true }
table.insert(GameLib.FoodOrder, name)
end
table.sort(GameLib.FoodOrder, function(a, b) return GameLib.Foods[a].cost < GameLib.Foods[b].cost end)
table.clear(GameLib.ShopItems)
local categories = data.Shop and data.Shop.Categories or {}
for category, items in pairs(categories) do
for item, entry in pairs(items) do
if type(entry) ~= "table" or entry.Source == "Lanterns" then continue end
local price = tonumber(entry.Price) or (GameLib.Foods[item] and GameLib.Foods[item].cost) or 0
GameLib.ShopItems[#GameLib.ShopItems + 1] = { cat = category, item = item, price = price, rarity = entry.Rarity }
end
end
table.sort(GameLib.ShopItems, function(a, b) return a.price < b.price end)
local rebirths = data.Rebirths
GameLib.Rebirths.Cap = rebirths and tonumber(rebirths.Cap) or 0
table.clear(GameLib.Rebirths.Costs)
for n = 1, GameLib.Rebirths.Cap do
local ok, cost = GameLib.Call(rebirths.GetCost, n - 1)
GameLib.Rebirths.Costs[n] = ok and tonumber(cost) or math.huge
end
table.clear(GameLib.RebirthReq)
for index, pet in ipairs((data.General or {}).RebirthRequirements or {}) do
GameLib.RebirthReq[index] = pet
end
table.clear(GameLib.IndexStages)
for _, stage in ipairs(data.IndexRewards and data.IndexRewards.Stages or {}) do
table.insert(GameLib.IndexStages, { goal = tonumber(stage.Goal) or 0, reward = tonumber(stage.Reward) or 0 })
end
table.clear(GameLib.Mutations)
for name, mutation in pairs(data.Mutations or {}) do
if type(mutation) == "table" and mutation.StatMultiplier then
GameLib.Mutations[name] = 1 + (tonumber(mutation.StatMultiplier) or 0) / 100
end
end
end
local function BuildFuseQuality()
table.clear(GameLib.FuseQuality)
local raw = GameLib.Data.WeightedFuseData
if type(raw) ~= "table" then return end
local holders = { raw.Pets, raw.Inputs, raw }
for _, holder in ipairs(holders) do
if type(holder) == "table" then
for key, value in pairs(holder) do
local name = key
local quality = value
if type(value) == "table" then
name = value.Name or value.PetName or value.Pet
quality = value.Quality or value.Value or value.Score
end
if type(name) == "string" and tonumber(quality) and GameLib.PetInfo[name] then
GameLib.FuseQuality[name] = tonumber(quality)
end
end
end
if next(GameLib.FuseQuality) then return end
end
end
function GameLib.Build()
BuildEggsAndPets()
BuildRarities()
BuildEconomy()
BuildFuseQuality()
end
function GameLib.SellMultiplier()
local sellValue = GameLib.Svc.SellValue
local mult = type(sellValue) == "table" and tonumber(sellValue.SellIncomeMultiplier)
return mult or Reicht.Config.SellPriceMult
end
function GameLib.RebirthMultiplier(done)
local rebirths = GameLib.Data.Rebirths
if type(rebirths) == "table" and type(rebirths.GetMultiplier) == "function" then
local ok, mult = GameLib.Call(rebirths.GetMultiplier, done)
if ok and tonumber(mult) then return tonumber(mult) end
end
return 1 + done
end
function GameLib.LuckMult()
local saved = LocalPlayer:FindFirstChild("SavedData")
local upgrades = saved and saved:FindFirstChild("HatchUpgrades")
local bought = upgrades and tonumber(upgrades.Value) or 0
local event = tonumber(ReplicatedStorage:GetAttribute("HatchLuckEventMultiplier")) or 1
return (1 + bought + 4 * math.floor(bought / 5)) * event
end
function GameLib.Blocked(idx)
for _, name in ipairs(GameLib.Needs[idx] or {}) do
local reason = GameLib.Missing[name]
if reason then return reason end
end
return nil
end
function GameLib.Check()
local started = os.clock()
local deadline = Reicht.Config.GameLibDeadline
local seen = {}
for _, names in pairs(GameLib.Needs) do
for _, name in ipairs(names) do
if seen[name] then continue end
seen[name] = true
if os.clock() - started > deadline then
GameLib.Missing[name] = "check timed out"
continue
end
local found
if name == "ActiveEggs" then
found = GameLib.ActiveEggs()
else
found = GameLib.Remote(name)
end
if not found then GameLib.Missing[name] = "not found after a game update" end
end
end
if not GameLib.Data.Eggs or not GameLib.Data.Pets then
GameLib.Missing.ActiveEggs = GameLib.Missing.ActiveEggs or "egg data not readable"
end
end
Reicht.Player = {
Client = LocalPlayer,
Char = nil, Humanoid = nil, Root = nil,
Epoch = 0,
BindVersion = 0,
CharConns = {},
PlotModel = nil, Baseplate = nil, PlotConn = nil, PlotRetryAt = 0,
}
function Reicht.Player:Lose(char)
if self.Char ~= char then return end
if self.LostChar == char then return end
self.LostChar = char
self.BindVersion += 1
self.Humanoid, self.Root = nil, nil
self.Epoch += 1
Reicht.Util.Try("abort on death", function() Reicht.Tasks.Abort("death") end)
Reicht.Util.Try("forget mount", function() Reicht.Mount.Forget() end)
end
function Reicht.Player:Unbind()
self.BindVersion += 1
self.Epoch += 1
self.Char, self.Humanoid, self.Root = nil, nil, nil
for _, conn in ipairs(self.CharConns) do
conn:Disconnect()
end
table.clear(self.CharConns)
if self.PlotConn then
self.PlotConn:Disconnect()
self.PlotConn = nil
end
end
function Reicht.Player:Bind(char)
if not State.Alive or State.Unloading then return end
if self.Char and self.Char ~= char then self:Lose(self.Char) end
self.BindVersion += 1
local version = self.BindVersion
for _, conn in ipairs(self.CharConns) do
conn:Disconnect()
end
table.clear(self.CharConns)
self.Char, self.Humanoid, self.Root = char, nil, nil
task.spawn(function()
local hum = char:WaitForChild("Humanoid", Config.LoadTimeout)
local hrp = char:WaitForChild("HumanoidRootPart", Config.LoadTimeout)
if not State.Alive or State.Unloading or self.Char ~= char or self.BindVersion ~= version then return end
if not hum or not hrp then
warn(Config.Tag, "character parts missing after", Config.LoadTimeout, "s")
return
end
self.Humanoid, self.Root = hum, hrp
table.insert(self.CharConns, hum.Died:Connect(function() self:Lose(char) end))
end)
end
function Reicht.Player:IsAlive()
local hum, hrp = self.Humanoid, self.Root
return hum ~= nil and hum.Health > 0 and hrp ~= nil and hrp.Parent ~= nil
end
function Reicht.Player:Plot()
local plot, bp = self.PlotModel, self.Baseplate
if plot and bp and plot.Parent and bp.Parent then return plot, bp end
local now = os.clock()
if now < self.PlotRetryAt then return nil, nil end
self.PlotRetryAt = now + Config.PlotRetry
plot = Reicht.GameLib.Plot()
bp = plot and plot:FindFirstChild("Baseplate")
if not bp then return nil, nil end
self.PlotModel, self.Baseplate = plot, bp
if self.PlotConn then self.PlotConn:Disconnect() end
local owner = plot:FindFirstChild("Data") and plot.Data:FindFirstChild("Owner")
if owner then
self.PlotConn = owner.Changed:Connect(function()
self.PlotModel, self.Baseplate, self.PlotRetryAt = nil, nil, 0
end)
end
return plot, bp
end
function Reicht.Player:BasketItems()
local basket = LocalPlayer:FindFirstChild("Basket")
return basket and basket:GetChildren() or {}
end
function Reicht.Player:BasketCount()
local basket = LocalPlayer:FindFirstChild("Basket")
return basket and #basket:GetChildren() or 0
end
function Reicht.Player:Riding()
return LocalPlayer:GetAttribute("IsRiding") == true
end
function Reicht.Player:Release()
local hum = self.Humanoid
local remote = self:Riding() and Reicht.GameLib.Remote("PetDismount")
if remote and hum and hum.Parent then
local landed = false
local conn = hum.Parent.ChildAdded:Connect(function(child)
if child:IsA("Tool") then landed = true end
end)
remote:FireServer()
local deadline = os.clock() + Config.DismountTimeout
while self:Riding() and os.clock() < deadline do task.wait() end
local toolBy = os.clock() + Config.DismountToolWindow
while not landed and os.clock() < toolBy and hum.Parent do task.wait() end
conn:Disconnect()
end
if self:BasketCount() > 0 or not hum then return not self:Riding() end
hum:UnequipTools()
return not self:Riding()
end
function Reicht.Player:Flags()
return tonumber(LocalPlayer:GetAttribute("TeleportFlags")) or 0
end
Reicht.Geo = {}
function Reicht.Geo.Lift(minimum)
local hum, root = Reicht.Player.Humanoid, Reicht.Player.Root
return math.max(minimum or Config.StandLift, (hum and hum.HipHeight or 0) + (root and root.Size.Y / 2 or 0))
end
function Reicht.Geo.EdgeInside(bp, target)
local rel = bp.CFrame:PointToObjectSpace(target)
local hx, hz = bp.Size.X / 2 - Config.EdgeInset, bp.Size.Z / 2 - Config.EdgeInset
local clamped = Vector3.new(math.clamp(rel.X, -hx, hx), bp.Size.Y / 2 + Reicht.Geo.Lift(), math.clamp(rel.Z, -hz, hz))
return bp.CFrame:PointToWorldSpace(clamped)
end
function Reicht.Geo.Outside(bp, target, dist)
local rel = bp.CFrame:PointToObjectSpace(target)
local hx, hz = bp.Size.X / 2, bp.Size.Z / 2
local cx, cz = math.clamp(rel.X, -hx, hx), math.clamp(rel.Z, -hz, hz)
local dx, dz = rel.X - cx, rel.Z - cz
local len = math.sqrt(dx * dx + dz * dz)
if len < 1e-3 then dx, dz, len = 1, 0, 1 end
return bp.CFrame:PointToWorldSpace(Vector3.new(cx + dx / len * dist, bp.Size.Y / 2 + Reicht.Geo.Lift(), cz + dz / len * dist))
end
function Reicht.Geo.StandPoint(bp, eggPos)
local edge = Reicht.Geo.EdgeInside(bp, eggPos)
local dir = (edge - eggPos) * Vector3.new(1, 0, 1)
local span = dir.Magnitude
if span < 1e-3 then return Vector3.new(eggPos.X, eggPos.Y + Reicht.Geo.Lift(), eggPos.Z) end
local spot = eggPos + dir.Unit * math.min(Config.PickupReach, span)
return Vector3.new(spot.X, eggPos.Y + Reicht.Geo.Lift(), spot.Z)
end
function Reicht.Geo.Trip(bp, from)
return (from - Reicht.Geo.EdgeInside(bp, from)).Magnitude
end
function Reicht.Geo.InPlot(pos)
local _, bp = Reicht.Player:Plot()
return bp ~= nil and Reicht.GameLib.Contains(bp, pos)
end
if LocalPlayer.Character then Reicht.Player:Bind(LocalPlayer.Character) end
Reicht:Connect(LocalPlayer.CharacterAdded, function(char) Reicht.Player:Bind(char) end)
Reicht:Connect(LocalPlayer.CharacterRemoving, function(char) Reicht.Player:Lose(char) end)
Reicht.Tasks = { Current = nil, Prio = { Recover = 100, Volcano = 80, Hunter = 70, Mount = 65, Eggs = 60, Plot = 40, Travel = 30, Manual = 20 } }
function Reicht.Tasks.Carrying()
if Reicht.Player:BasketCount() > 0 then return true end
return Reicht.Halloween ~= nil and Reicht.Halloween.Carried() > 0
end
function Reicht.Tasks.EggsBusy()
local eggs = Reicht.Eggs
if not eggs or not eggs.Waiting then return false end
return not eggs.Waiting()
end
function Reicht.Tasks.Request(owner, prio)
if not Reicht.State.Alive then return nil end
if Reicht.State.Unloading and owner ~= "Recover" then return nil end
if not Reicht.Player:IsAlive() then return nil end
if prio <= Reicht.Tasks.Prio.Manual and Reicht.Tasks.Carrying() then
table.insert(Reicht.State.PendingNotify, { "Reicht", "Finish the egg delivery first" })
return nil
end
if prio <= Reicht.Tasks.Prio.Plot and prio > Reicht.Tasks.Prio.Manual and Reicht.Tasks.EggsBusy() then return nil end
local cur = Reicht.Tasks.Current
if cur and (cur.dead or cur.epoch ~= Reicht.Player.Epoch) then
cur.dead = true
cur = nil
Reicht.Tasks.Current = nil
end
if cur then
if prio > cur.prio then cur.preempt = true end
return nil
end
local token = { owner = owner, prio = prio, epoch = Reicht.Player.Epoch, thread = coroutine.running(), dead = false, preempt = false }
local hrp = Reicht.Player.Root
if prio <= Reicht.Tasks.Prio.Plot and hrp then token.home = hrp.CFrame end
Reicht.Tasks.Current = token
return token
end
function Reicht.Tasks.Release(token)
if not token or token.dead then return end
token.dead = true
if Reicht.Tasks.Current ~= token then return end
Reicht.Tasks.Current = nil
local opts = Reicht.Options
local back = opts and opts.ReturnAfter
if not token.home or not back or not Reicht.State.Alive or Reicht.State.Unloading or Reicht.Tasks.Carrying() then return end
local hrp = Reicht.Player.Root
if hrp and Reicht.Player:IsAlive() and token.epoch == Reicht.Player.Epoch then
hrp.CFrame = token.home
hrp.AssemblyLinearVelocity = Vector3.zero
end
end
function Reicht.Tasks.Holds(token)
if not token or token.dead or not Reicht.State.Alive then return false end
if Reicht.Tasks.Current ~= token or token.epoch ~= Reicht.Player.Epoch then return false end
if not token.preempt or token.critical then return true end
local delivering = token.owner == "Eggs" or token.owner == "Hunter" or token.owner == "Recover" or token.owner == "Volcano" or token.owner == "Halloween"
if delivering and ((Reicht.Eggs and Reicht.Eggs.CarryCritical) or Reicht.Tasks.Carrying()) then return true end
Reicht.Tasks.Release(token)
return false
end
function Reicht.Tasks.Await(token, cond, timeout)
local deadline = os.clock() + timeout
repeat
if not Reicht.State.Alive then return false, "unload" end
if not token or token.epoch ~= Reicht.Player.Epoch then return false, "death" end
if not Reicht.Tasks.Holds(token) then return false, "preempted" end
if cond and cond() then return true, "ok" end
task.wait()
until os.clock() >= deadline
return false, "timeout"
end
function Reicht.Tasks.Teleport(token, cf)
if not Reicht.Tasks.Holds(token) then return false end
if token.epoch ~= Reicht.Player.Epoch or not Reicht.Player:IsAlive() then return false end
local hrp = Reicht.Player.Root
if not hrp then return false end
hrp.CFrame = cf
hrp.AssemblyLinearVelocity = Vector3.zero
return true
end
function Reicht.Tasks.Abort(why)
local cur = Reicht.Tasks.Current
if not cur then return end
cur.dead, cur.why = true, why
Reicht.Tasks.Current = nil
end
function Reicht.Tasks.Travel(token, cf, speed, timeout, opts)
local deadline = os.clock() + timeout
local collisions, originalCollisions, clipConnections = {}, {}, {}
local root = Reicht.Player.Root
local rotation = root and root.CFrame.Rotation
local hum = Reicht.Player.Humanoid
local autoRotate = hum and hum.AutoRotate
local ok, reached = pcall(function()
if hum then hum.AutoRotate = false end
if opts and opts.noClip and Reicht.Player.Char then
local function addPart(part)
if not part:IsA("BasePart") or originalCollisions[part] ~= nil then return end
originalCollisions[part] = part.CanCollide
collisions[#collisions + 1] = part
part.CanCollide = false
end
local function addModel(model)
for _, part in ipairs(model:GetDescendants()) do addPart(part) end
if model.DescendantAdded then
clipConnections[#clipConnections + 1] = model.DescendantAdded:Connect(function(part)
if Reicht.Tasks.Holds(token) then addPart(part) end
end)
end
end
addModel(Reicht.Player.Char)
local joint = root and root.FindFirstChild and root:FindFirstChild("PetMountJoint")
local mount = joint and joint.Part1 and joint.Part1:FindFirstAncestorOfClass("Model")
if mount and mount ~= Reicht.Player.Char then addModel(mount) end
clipConnections[#clipConnections + 1] = RunService.Stepped:Connect(function()
if not Reicht.Tasks.Holds(token) then return end
for _, part in ipairs(collisions) do
if part.Parent and part.CanCollide then part.CanCollide = false end
end
end)
end
while Reicht.Tasks.Holds(token) and os.clock() < deadline do
if opts and opts.maxFlags ~= nil and Reicht.Player:Flags() > opts.maxFlags then return false end
if opts and opts.done and opts.done() then return true end
local hrp = Reicht.Player.Root
if not hrp or not Reicht.Player:IsAlive() then return false end
local delta = cf.Position - hrp.Position
local reach = opts and opts.reach or Config.TravelStopDistance
if delta.Magnitude <= reach then return true end
if hum then hum:Move(Vector3.zero) end
local elapsed = task.wait()
if not Reicht.Tasks.Holds(token) then return false end
if opts and opts.maxFlags ~= nil and Reicht.Player:Flags() > opts.maxFlags then return false end
if opts and opts.done and opts.done() then return true end
for _, part in ipairs(collisions) do
if part.Parent and part.CanCollide then part.CanCollide = false end
end
delta = cf.Position - hrp.Position
if delta.Magnitude <= reach then return true end
local currentSpeed = type(speed) == "function" and speed() or speed
if type(currentSpeed) ~= "number" or currentSpeed ~= currentSpeed or currentSpeed <= 0 or currentSpeed == math.huge then return false end
local step = math.min(delta.Magnitude, currentSpeed * math.min(elapsed, Config.TravelStepMax))
local pos = hrp.Position + delta.Unit * step
local nextCF = CFrame.new(pos) * rotation
if not Reicht.Tasks.Teleport(token, nextCF) then return false end
end
return false
end)
for _, connection in ipairs(clipConnections) do connection:Disconnect() end
for _, part in ipairs(collisions) do
if part.Parent then part.CanCollide = originalCollisions[part] end
end
if hum and hum.Parent then hum.AutoRotate = autoRotate end
if not ok then error(reached, 0) end
return reached
end
function Reicht.Tasks.ReleaseAll(why)
Reicht.Tasks.Abort(why or "release")
end
function Reicht.Tasks.Owner()
local cur = Reicht.Tasks.Current
return cur and not cur.dead and cur.owner or nil
end
Reicht.Scheduler = { Jobs = {}, Order = {}, Booted = false }
Reicht.Scheduler.Defaults = {
{ "Eggs", "Eggs", "Step", { "AutoEggs" } },
{ "Hunter", "Hunter", "Step", { "EggHunter" } },
{ "Volcano", "Volcano", "Step", { "VolcanoDip", "VolcanoObby" } },
{ "Halloween", "Halloween", "Step", { "AutoCandy", "AutoTrickOrTreat", "AutoPumpkin", "AutoHalloweenEgg", "AutoRitual" }, function() return Reicht.Halloween.AnyActive() end },
{ "Junk", "Junk", "Step", { "ClearJunk" } },
{ "Hatch", "Hatch", "Step", { "AutoHatch" }, function()
return Reicht.Util.Opt("AutoHatch") == true or (Reicht.Util.Opt("HalloweenAutoHatch") ~= false and next(Reicht.Hatch.Purchased) ~= nil)
end },
{ "Plant", "Hatch", "PlantStep", { "AutoPlaceEggs" } },
{ "Pets", "Pets", "Step", { "AutoEquipBest", "AutoCollectCash" } },
{ "Feed", "Pets", "FeedStep", { "AutoFeed" } },
{ "Sell", "Sell", "Step", { "AutoSell" } },
{ "Fusion", "Fusion", "Step", { "AutoFusion" } },
{ "Economy", "Economy", "Step", { "AutoUpgrade", "AutoRebirth", "SmartSpend" } },
{ "Shop", "Shop", "Step", { "AutoShop" } },
{ "Rewards", "Rewards", "Step", { "AutoClaim" } },
{ "Boosts", "Boosts", "Step", nil },
{ "Server", "Server", "Step", nil },
{ "Esp", "Esp", "Step", { "EggEsp" } },
{ "HalloweenEsp", "Halloween", "EspStep", { "HalloweenEsp" } },
{ "Webhook", "Webhook", "Step", nil },
{ "Settle", "Eggs", "SettleStep", nil },
{ "Kaitun", "Kaitun", "Step", { "Kaitun" } },
}
function Reicht.Scheduler.Add(name, interval, fn, enabledFn, toggles)
local job = Reicht.Scheduler.Jobs[name]
if not job then
job = { name = name, due = 0, busy = false }
job.runner = function()
job.thread = coroutine.running()
local ok, err = pcall(function()
if not State.Alive or State.Unloading then return end
job.fn()
end)
job.busy = false
if not ok then Reicht.Scheduler.Fail(job, err) end
job.thread = nil
end
Reicht.Scheduler.Jobs[name] = job
table.insert(Reicht.Scheduler.Order, job)
end
job.interval, job.fn, job.enabledFn, job.toggles = interval, fn, enabledFn, toggles or {}
return job
end
function Reicht.Scheduler.Enabled(job)
if State.Halted[job.name] then return false end
if job.enabledFn then return job.enabledFn() == true end
if #job.toggles == 0 then return true end
for _, idx in ipairs(job.toggles) do
if Reicht.Util.Opt(idx) == true then return true end
end
return false
end
function Reicht.Scheduler.Fail(job, err)
local token = Reicht.Tasks.Current
if token and job.thread and token.thread == job.thread then Reicht.Tasks.Abort("job error: " .. job.name) end
local now = os.clock()
local log = State.Errors[job.name] or {}
State.Errors[job.name] = log
local kept = {}
for _, at in ipairs(log) do
if now - at <= Config.FailWindow then kept[#kept + 1] = at end
end
kept[#kept + 1] = now
State.Errors[job.name] = kept
if #kept == 1 then warn(Config.Tag, job.name .. " failing:", err) end
if #kept < Config.FailLimit then return end
if #job.toggles == 0 then
State.Errors[job.name] = nil
job.due = now + Config.JobBackoff
warn(Config.Tag, job.name .. " backing off:", err)
return
end
State.Halted[job.name] = true
for _, idx in ipairs(job.toggles) do
table.insert(State.PendingToggleOff, idx)
end
local line = tostring(err):match("^[^\n]*") or "unknown error"
Reicht.Util.Notify("Reicht", job.name .. " stopped: " .. line, 8)
end
function Reicht.Scheduler.Run(job)
if job.busy or not State.Alive or State.Unloading then return end
job.busy = true
task.spawn(job.runner)
end
function Reicht.Scheduler.Tick()
if not State.Alive or State.Unloading then return end
local now = os.clock()
for _, job in ipairs(Reicht.Scheduler.Order) do
if job.busy or now < job.due then continue end
job.due = now + job.interval
local ok, enabled = pcall(Reicht.Scheduler.Enabled, job)
if not ok then
Reicht.Scheduler.Fail(job, enabled)
continue
end
if not enabled then continue end
Reicht.Scheduler.Run(job)
end
end
function Reicht.Scheduler.Resume(key)
for name, job in pairs(Reicht.Scheduler.Jobs) do
if name == key or table.find(job.toggles, key) then
State.Halted[name] = nil
State.Errors[name] = nil
job.due = 0
end
end
end
function Reicht.Scheduler.Pump()
if not Library then return end
if #State.PendingToggleOff == 0 and #State.PendingNotify == 0 then return end
local offList = State.PendingToggleOff
State.PendingToggleOff = {}
for _, idx in ipairs(offList) do
local option = Library.Options and Library.Options[idx]
if option and option.Value then option:SetValue(false) end
Reicht.Options[idx] = false
end
local notes = State.PendingNotify
State.PendingNotify = {}
for _, note in ipairs(notes) do
Library:Notify(note[1], note[2], note[3] or 5)
end
end
function Reicht.Scheduler.AddDefaults()
local espTick = Reicht.Platform.Mobile and Config.EspTickMobile or Config.EspTick
for _, row in ipairs(Reicht.Scheduler.Defaults) do
local name, owner, method, toggles, enabledFn = row[1], row[2], row[3], row[4], row[5]
local interval = Config.JobTick[name] or espTick
if Reicht.Scheduler.Jobs[name] then continue end
local module = rawget(Reicht, owner)
local fn = module and module[method]
if type(fn) ~= "function" then
warn(Config.Tag, "no job function " .. owner .. "." .. method)
continue
end
Reicht.Scheduler.Add(name, interval, fn, enabledFn, toggles)
end
end
function Reicht.Scheduler.Boot()
if Reicht.Scheduler.Booted then return end
Reicht.Scheduler.Booted = true
Reicht.Scheduler.AddDefaults()
Reicht:Connect(RunService.Heartbeat, Reicht.Scheduler.Tick)
end
Reicht.Signal = {}
Reicht.Signal.__index = Reicht.Signal
function Reicht.Signal.new()
return setmetatable({ handlers = {} }, Reicht.Signal)
end
function Reicht.Signal:Connect(fn)
local handlers = self.handlers
handlers[#handlers + 1] = fn
return function()
local at = table.find(handlers, fn)
if at then table.remove(handlers, at) end
end
end
function Reicht.Signal:Fire(...)
for _, fn in ipairs(table.clone(self.handlers)) do
Reicht.Util.Try("signal", fn, ...)
end
end
Reicht.EggIndex = {
Entries = {}, Conns = {}, Waiters = {},
Claimed = {}, LocalClaims = {}, Blacklist = {}, Failed = {}, FailCap = 2,
Memo = {}, Mult = nil, Median = nil, ValueEpoch = 0,
Cycle = nil, RolledAt = 0, Started = false,
OnAdded = Reicht.Signal.new(),
OnRemoved = Reicht.Signal.new(),
OnReply = Reicht.Signal.new(),
OnRoll = Reicht.Signal.new(),
}
function Reicht.EggIndex.LuckMult()
return GameLib.LuckMult()
end
function Reicht.EggIndex.Expected(egg, mult)
local key = egg .. "|" .. mult
local memo = Reicht.EggIndex.Memo
if memo[key] then return memo[key] end
local total = 0
for _, pair in ipairs(GameLib.Odds(egg, mult) or {}) do
local pet = GameLib.PetInfo[pair[1]]
total += (tonumber(pair[2]) or 0) * (pet and pet.income or 0)
end
if total <= 0 then
local info = GameLib.EggInfo[egg]
total = (info and info.luck or 0) * mult
end
memo[key] = total
return total
end
function Reicht.EggIndex.Value(entry)
if not entry.egg then return 0 end
local index = Reicht.EggIndex
index.Mult = index.Mult or index.LuckMult()
local factor = entry.mutation and GameLib.Mutations[entry.mutation] or 1
return index.Expected(entry.egg, index.Mult) * (entry.weight or 1) * factor
end
function Reicht.EggIndex.Revalue()
local index = Reicht.EggIndex
table.clear(index.Memo)
index.Mult = nil
for _, entry in pairs(index.Entries) do
entry.value = index.Value(entry)
end
index.Median = nil
index.ValueEpoch += 1
end
function Reicht.EggIndex.Read(inst, entry)
entry = entry or { guid = inst.Name, inst = inst }
entry.egg = inst:GetAttribute("Egg")
entry.pos = inst:GetAttribute("Position")
entry.weight = tonumber(inst:GetAttribute("Weight")) or 1
entry.mutation = inst:GetAttribute("Mutation")
entry.cycle = tonumber(inst:GetAttribute("Cycle"))
entry.privateTo = inst:GetAttribute("PrivateTo")
entry.area = inst:GetAttribute("Area") == true
entry.dropEndsAt = tonumber(inst:GetAttribute("DropEndsAt"))
entry.origin = inst:GetAttribute("OriginPosition")
entry.value = Reicht.EggIndex.Value(entry)
return entry
end
function Reicht.EggIndex.Add(inst)
local index = Reicht.EggIndex
if index.Entries[inst.Name] then return end
local entry = index.Read(inst)
index.Entries[inst.Name] = entry
index.Median = nil
index.Conns[inst.Name] = inst.AttributeChanged:Connect(function(attr)
if attr ~= "Position" and attr ~= "DropEndsAt" and attr ~= "PrivateTo" then return end
local wasDropped = entry.dropEndsAt ~= nil
index.Read(inst, entry)
if attr == "DropEndsAt" and not wasDropped and entry.dropEndsAt then index.OnAdded:Fire(entry) end
end)
index.OnAdded:Fire(entry)
end
function Reicht.EggIndex.Remove(inst)
local index = Reicht.EggIndex
local entry = index.Entries[inst.Name]
if not entry then return end
index.Entries[inst.Name] = nil
entry.removed = true
local conn = index.Conns[inst.Name]
if conn then conn:Disconnect() end
index.Conns[inst.Name] = nil
index.Median = nil
index.OnRemoved:Fire(entry)
end
function Reicht.EggIndex.Expect(key)
local waiter = {}
Reicht.EggIndex.Waiters[key] = waiter
return waiter
end
function Reicht.EggIndex.Deliver(key, kind, text)
local waiter = key and Reicht.EggIndex.Waiters[key]
if not waiter or waiter.kind then return end
waiter.kind, waiter.text = kind, text
end
function Reicht.EggIndex.WaitReply(key, timeout)
local index = Reicht.EggIndex
local waiter = index.Waiters[key] or index.Expect(key)
local deadline = os.clock() + timeout
while not waiter.kind and os.clock() < deadline and State.Alive do
task.wait()
end
if index.Waiters[key] == waiter then index.Waiters[key] = nil end
if not waiter.kind then return "Timeout" end
return waiter.kind, waiter.text
end
function Reicht.EggIndex.Route(kind, first, second)
local index = Reicht.EggIndex
if kind == "PickedUp" then
index.Deliver(second, "PickedUp", first)
index.OnReply:Fire("PickedUp", second, first)
elseif kind == "Refused" then
local text = tostring(first)
local verdict = text:find("already gone", 1, true) and "Gone" or "Refused"
if verdict == "Gone" and second then index.Blacklist[second] = os.clock() + Config.GoneBlacklistSec end
index.Deliver(second, verdict, text)
index.OnReply:Fire(verdict, second, text)
elseif kind == "Deposited" then
index.Deliver("*carry", "Deposited", tostring(first))
index.OnReply:Fire("Deposited", nil, first)
elseif kind == "BasketFull" then
for key in pairs(index.Waiters) do index.Deliver(key, "BasketFull") end
index.OnReply:Fire("BasketFull")
end
end
function Reicht.EggIndex.OnMessage(text)
if type(text) ~= "string" then return end
if text:find("Egg Delivery Failed", 1, true) or text:find("Was Returned", 1, true) then
Reicht.Guard.Trip("message")
end
end
function Reicht.EggIndex.ReadClaims()
local index = Reicht.EggIndex
local raw = LocalPlayer:GetAttribute("CollectedEggCycles")
if type(raw) ~= "string" or raw == "" then return end
local http = game:GetService("HttpService")
local ok, decoded = pcall(http.JSONDecode, http, raw)
if not ok or type(decoded) ~= "table" then
index.ClaimsBroken = true
return
end
table.clear(index.Claimed)
for egg, cycle in pairs(decoded) do
index.Claimed[egg] = tonumber(cycle)
end
index.ClaimsBroken = false
end
function Reicht.EggIndex.ClaimedCycle(egg)
local index = Reicht.EggIndex
return math.max(index.Claimed[egg] or -1, index.LocalClaims[egg] or -1)
end
function Reicht.EggIndex.MarkClaimed(egg, cycle)
if not egg or not cycle then return end
local claims = Reicht.EggIndex.LocalClaims
claims[egg] = math.max(claims[egg] or -1, cycle)
end
function Reicht.EggIndex.MarkGone(guid)
if guid then Reicht.EggIndex.Blacklist[guid] = os.clock() + Config.GoneBlacklistSec end
end
function Reicht.EggIndex.Fail(guid)
local failed = Reicht.EggIndex.Failed
failed[guid] = (failed[guid] or 0) + 1
end
function Reicht.EggIndex.CheckRoll()
local index = Reicht.EggIndex
local cycle = GameLib.CycleIndex()
if cycle == index.Cycle then return false end
local rolled = index.Cycle ~= nil
index.Cycle = cycle
if not rolled then return false end
table.clear(index.Blacklist)
table.clear(index.Failed)
index.RolledAt = os.clock()
index.OnRoll:Fire(cycle)
return true
end
function Reicht.EggIndex.MedianValue()
local index = Reicht.EggIndex
if index.Median then return index.Median end
local values = {}
for _, entry in pairs(index.Entries) do
local info = entry.egg and GameLib.EggInfo[entry.egg]
if info and not info.volcanic then values[#values + 1] = entry.value or 0 end
end
table.sort(values)
index.Median = values[math.max(1, math.ceil(#values / 2))] or 0
return index.Median
end
function Reicht.EggIndex.Blocked(entry, info)
local index = Reicht.EggIndex
if entry.privateTo and entry.privateTo ~= LocalPlayer.UserId then return "private" end
if info.volcanic then return "volcanic" end
if entry.dropEndsAt and Reicht.Util.ServerNow() < entry.dropEndsAt then return "falling" end
if info.ethereal and entry.cycle and entry.cycle <= index.ClaimedCycle(entry.egg) then return "claimed" end
if (index.Blacklist[entry.guid] or 0) > os.clock() then return "taken" end
if (index.Failed[entry.guid] or 0) >= index.FailCap then return "failed" end
return nil
end
function Reicht.EggIndex.Allowed(entry, info)
local opts = Reicht.Options
local rarities, names = opts.EggRarities, opts.EggNames
local floor = GameLib.RarityRank[opts.MinEggRarity or ""]
if floor and (GameLib.RarityRank[info.rarity] or 0) < floor then return false end
if type(rarities) == "table" and next(rarities) and not rarities[info.rarity] then return false end
if type(names) == "table" and next(names) and not names[entry.egg] then return false end
if (info.luck or 0) < (tonumber(opts.MinLuck) or 0) then return false end
return entry.weight >= (tonumber(opts.MinWeight) or 0)
end
function Reicht.EggIndex.Wanted(entry, ignoreFilters)
if entry.removed or not entry.pos or not entry.egg then return false, "gone" end
local info = GameLib.EggInfo[entry.egg]
if not info then return false, "unknown" end
local reason = Reicht.EggIndex.Blocked(entry, info)
if reason then return false, reason end
if ignoreFilters then return true end
if not Reicht.EggIndex.Allowed(entry, info) then return false, "filtered" end
if Reicht.Options.SmartEggs and (entry.value or 0) < Reicht.EggIndex.MedianValue() then return false, "low value" end
return true
end
function Reicht.EggIndex.WatchValues()
local saved = LocalPlayer:FindFirstChild("SavedData")
local upgrades = saved and saved:FindFirstChild("HatchUpgrades")
if upgrades then Reicht:Connect(upgrades.Changed, Reicht.EggIndex.Revalue) end
Reicht:Connect(ReplicatedStorage:GetAttributeChangedSignal("HatchLuckEventMultiplier"), Reicht.EggIndex.Revalue)
Reicht:Connect(LocalPlayer:GetAttributeChangedSignal("CollectedEggCycles"), Reicht.EggIndex.ReadClaims)
end
function Reicht.EggIndex.Start()
local index = Reicht.EggIndex
if index.Started then return true end
local serverData = ReplicatedStorage:FindFirstChild("ServerData")
local folder = serverData and serverData:FindFirstChild("ActiveEggs")
if not folder then return false end
index.Started = true
Reicht:Connect(folder.ChildAdded, Reicht.EggIndex.Add)
Reicht:Connect(folder.ChildRemoved, Reicht.EggIndex.Remove)
for _, inst in ipairs(folder:GetChildren()) do
index.Add(inst)
end
local pickup = GameLib.Remote("EggPickup")
if pickup then Reicht:Connect(pickup.OnClientEvent, Reicht.EggIndex.Route) end
local message = GameLib.Remote("GameMessage")
if message then Reicht:Connect(message.OnClientEvent, Reicht.EggIndex.OnMessage) end
index.WatchValues()
index.ReadClaims()
index.Cycle = GameLib.CycleIndex()
return true
end
function Reicht.EggIndex.Stop()
local index = Reicht.EggIndex
for guid, conn in pairs(index.Conns) do
conn:Disconnect()
index.Conns[guid] = nil
end
table.clear(index.Waiters)
end
local CollectionService = game:GetService("CollectionService")
Reicht.Halloween = {
Enabled = false,
Phase = "Idle",
PhaseAt = 0,
Note = nil,
Token = nil,
Target = nil,
CarriedBefore = 0,
CarriedWas = 0,
FirstPickAt = 0,
NextCollectAt = 0,
LastCollectAt = 0,
GroundRay = nil,
ManualCandy = false,
ManualPass = nil,
ManualUntil = nil,
BuyOnce = false,
BuyTravel = false,
Purchase = nil,
LastBuyAt = 0,
PriceSeen = nil,
PriceFound = nil,
EggsBought = 0,
TokensEarned = 0,
Cycles = 0,
Spoiled = 0,
StartedAt = 0,
Bound = false,
AwaitCarried = false,
Conns = {},
Boards = {},
DoorAt = {},
PumpkinAt = {},
SkipUntil = {},
CandyState = nil,
CandyStateAt = 0,
DoorState = nil,
DoorStateAt = 0,
PumpkinState = nil,
PumpkinStateAt = 0,
RitualAt = 0,
RitualSeenOpen = false,
ZoneTries = 0,
ZoneRetryAt = 0,
PadCache = nil,
DepositCarried = 0,
DepositBankBefore = 0,
DepositRetried = false,
Busy = false,
FlagsBaseline = nil,
Finishing = false,
Stats = { candy = 0, knocks = 0, treats = 0 },
}
function Reicht.Halloween.SetPhase(phase, note)
local halloween = Reicht.Halloween
halloween.Phase, halloween.PhaseAt, halloween.Note = phase, os.clock(), note
Reicht.Halloween.UpdateStatus()
end
function Reicht.Halloween.UpdateStatus()
local halloween = Reicht.Halloween
if not halloween.Enabled and not halloween.ManualCandy and not halloween.ManualPass then
State.Status.Halloween = "Off"
return
end
local mins = halloween.StartedAt > 0 and math.floor((os.clock() - halloween.StartedAt) / 60) or 0
local note = halloween.Note and (halloween.Note .. " | ") or ""
State.Status.Halloween = string.format("%s%s | Carried %d | Bank %s | %dm",
note, halloween.Phase, Reicht.Halloween.Carried(), Reicht.Util.Format(Reicht.Halloween.Tokens()), mins)
end
function Reicht.Halloween.Carried()
local noSave = LocalPlayer:FindFirstChild("NoSaveData")
local node = noSave and noSave:FindFirstChild("CarriedCandy")
return node and tonumber(node.Value) or 0
end
function Reicht.Halloween.Tokens()
local saved = LocalPlayer:FindFirstChild("SavedData")
local node = saved and saved:FindFirstChild("HalloweenCandy")
return node and tonumber(node.Value) or 0
end
function Reicht.Halloween.InZone()
local value = LocalPlayer:GetAttribute("InHalloweenZone")
if value == nil then
local char = Reicht.Player.Char
value = char and char:GetAttribute("InHalloweenZone")
end
if value == nil then
value = Workspace:GetAttribute("InHalloweenZone")
end
return value
end
function Reicht.Halloween.EventLive()
if #CollectionService:GetTagged("HalloweenCandyDeposit") > 0 then return true end
if #CollectionService:GetTagged("HalloweenCandySpawn") > 0 then return true end
return Workspace:FindFirstChild("HeadlessRitual") ~= nil
end
function Reicht.Halloween.PointOf(inst)
if inst:IsA("BasePart") then return inst.Position end
if inst:IsA("Model") then return inst:GetPivot().Position end
if inst:IsA("Attachment") then return inst.WorldPosition end
local holder = inst:FindFirstAncestorOfClass("BasePart") or inst:FindFirstAncestorOfClass("Model")
if holder then
return holder:IsA("BasePart") and holder.Position or holder:GetPivot().Position
end
return nil
end
function Reicht.Halloween.PadPos()
local halloween = Reicht.Halloween
if halloween.PadCache and halloween.PadCache.Parent then
return halloween.PadCache.Position
end
for _, inst in ipairs(CollectionService:GetTagged("HalloweenCandyDeposit")) do
local pos = Reicht.Halloween.PointOf(inst)
if pos then
halloween.PadCache = inst
return pos
end
end
return Config.CandyPadPos
end
function Reicht.Halloween.PadCF()
return CFrame.new(Reicht.Halloween.PadPos() + Vector3.new(0, Reicht.Halloween.StandLift(), 0))
end
function Reicht.Halloween.StandLift()
local hum, hrp = Reicht.Player.Humanoid, Reicht.Player.Root
return math.max(Config.CandyPadLift, (hum and hum.HipHeight or 0) + (hrp and hrp.Size.Y / 2 or 0))
end
function Reicht.Halloween.PickupCF(pos, inst)
local lift = Reicht.Halloween.StandLift()
local pad = Reicht.Halloween.PadPos()
local dir = (pad - pos) * Vector3.new(1, 0, 1)
local reach = math.sqrt(math.max(0, Config.CandyPickupReach * Config.CandyPickupReach - lift * lift))
local spot = pos
if dir.Magnitude > Config.TravelStopDistance then spot += dir.Unit * math.min(reach, dir.Magnitude) end
local ray = Reicht.Halloween.GroundRay
if not ray then
ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Exclude
ray.RespectCanCollide = true
Reicht.Halloween.GroundRay = ray
end
ray.FilterDescendantsInstances = { Reicht.Player.Char or Workspace, inst }
local hit = Workspace:Raycast(spot + Vector3.new(0, Config.GroundRayUp, 0), Vector3.new(0, -(Config.GroundRayUp + Config.GroundRayDown), 0), ray)
local stand = (hit and hit.Position or spot) + Vector3.new(0, lift, 0)
local facing = Vector3.new(pad.X, stand.Y, pad.Z)
return (facing - stand).Magnitude > Config.TravelStopDistance and CFrame.lookAt(stand, facing) or CFrame.new(stand)
end
function Reicht.Halloween.DirectLimit(ignoreStyle)
if not ignoreStyle and Reicht.Halloween.ReturnHopDisabled then return 0 end
if not ignoreStyle and Reicht.Util.Opt("CandyReturnStyle") == "Smooth ride" then return 0 end
local speed = Reicht.Mount.Speed()
return math.min(Config.CandyDirectMax, speed > 0 and speed * Config.CandyDirectFactor or Config.UnmountedDirect)
end
function Reicht.Halloween.PortalCF()
local map = Workspace:FindFirstChild("Map")
local portal = map and map:FindFirstChild("Portal")
local outer = portal and portal:FindFirstChild("Model")
local inner = outer and outer:FindFirstChild("Model")
local part = inner and inner:FindFirstChild("Part")
if part and part:IsA("BasePart") then
return CFrame.new(part.Position + Vector3.new(0, Config.StandLift, 0))
end
if portal and portal:IsA("Model") then
return CFrame.new(portal:GetPivot().Position + Vector3.new(0, Config.StandLift, 0))
end
return CFrame.new(Config.PortalPos)
end
function Reicht.Halloween.Houses()
return CollectionService:GetTagged("TrickOrTreatHouseModel")
end
function Reicht.Halloween.DoorId(house, pivot)
local attr = house:GetAttribute("Id") or house:GetAttribute("DoorId")
if attr then return attr end
return "Door_" .. math.round(pivot.Position.X) .. "_" .. math.round(pivot.Position.Z)
end
function Reicht.Halloween.AskCandy()
local halloween = Reicht.Halloween
local now = os.clock()
if halloween.CandyStateAt > 0 and now - halloween.CandyStateAt < Config.CandyStateCache then
return halloween.CandyState
end
local remote = Reicht.Net.GetCandyState
if not remote then return halloween.CandyState end
local ok, state = GameLib.Call(remote.InvokeServer, remote)
halloween.CandyStateAt = now
if ok and type(state) == "table" then halloween.CandyState = state end
return halloween.CandyState
end
function Reicht.Halloween.SpawnState()
local parsed = {}
local state = Reicht.Halloween.AskCandy()
if type(state) ~= "table" then return parsed end
local raw = state
for _, key in ipairs({ "Spawns", "Candy", "CandySpawns" }) do
if type(state[key]) == "table" then
raw = state[key]
break
end
end
if raw == state and type(state.RespawnAt) == "table" then
local now = workspace:GetServerTimeNow()
for id, at in pairs(state.RespawnAt) do
if type(id) == "string" and tonumber(at) and at > now then
parsed[id] = { respawnAt = tonumber(at), amount = 0, respawning = true }
end
end
for id, amount in pairs(state.Amounts or {}) do
if type(id) == "string" then
local at = tonumber(state.RespawnAt[id])
parsed[id] = {
respawnAt = at and at > now and at or nil,
amount = tonumber(amount) or 0,
tier = tonumber(state.Types and state.Types[id]),
respawning = at ~= nil and (at > now),
}
end
end
return parsed
end
for id, entry in pairs(raw) do
if type(id) == "string" and type(entry) == "table" then
parsed[id] = {
respawnAt = tonumber(entry.RespawnAt),
amount = tonumber(entry.Amounts) or tonumber(entry.Amount),
tier = tonumber(entry.Tier) or tonumber(entry.Type),
respawning = entry.Respawning == true,
}
end
end
return parsed
end
function Reicht.Halloween.CandyLib()
return GameLib.Data.Halloween
end
function Reicht.Halloween.CandyValue(entry, dist)
local count = tonumber(entry.amount) or 1
if count ~= count or count <= 0 or count == math.huge then return 0 end
local returning = math.max(0, dist - Config.CandyPickupReach - Config.CandyDepositReach)
local direct = Reicht.Halloween.DirectLimit()
local mode = Reicht.Util.Opt("CandyMode") or "Most pieces"
if mode == "Fast returns" and returning > Reicht.Halloween.DirectLimit(true) then return 0 end
local speed = Reicht.Halloween.ReturnSpeed() / Reicht.Halloween.ReturnFactor()
local types = Reicht.Halloween.CandyLib()
local kind = types and types.CandyTypes and types.CandyTypes[tonumber(entry.tier)]
local debuffs = GameLib.Data["Halloween.Debuffs"]
local heavy = debuffs and debuffs.HeavyGravity
if Reicht.Util.Opt("CandyAvoidSpoil") ~= false and kind and debuffs and debuffs.Enabled
and debuffs.AffectedModels and debuffs.AffectedModels[kind.Model] and heavy and heavy.Enabled then
speed /= math.max(tonumber(heavy.SpeedDivisor) or 1, 1)
end
local seconds = math.max(0, returning - direct) / math.max(speed, 1)
if seconds + Config.CandyDepositReserve >= Config.CandySpoilAt then return 0 end
if mode == "Most pieces" then return count end
return count / math.max(Config.CandyCooldown, seconds + Config.CandyDepositReserve)
end
function Reicht.Halloween.ReturnFactor()
local percent = tonumber(Reicht.Util.Opt("CandyReturnSpeed"))
local factor = percent and percent / 100 or Config.CandyReturnFactor
if type(factor) ~= "number" or factor ~= factor then return 1 end
factor = math.clamp(factor, 1, 6)
local cap = Reicht.Halloween.ReturnCapPercent
return cap and math.min(factor, cap / 100) or factor
end
function Reicht.Halloween.ReturnSpeed()
local hum = Reicht.Player.Humanoid
local speed = Reicht.Mount.TravelSpeed()
if speed <= 0 then speed = Config.UnmountedPlayerSpeed end
return math.min(speed, hum and hum.WalkSpeed or 0) * Reicht.Halloween.ReturnFactor()
end
function Reicht.Halloween.Respawning(inst, entry)
if entry and entry.respawning then return true end
local at = tonumber(inst:GetAttribute("RespawnAt")) or entry and entry.respawnAt
if not at then return false end
if at > 1e6 then return Reicht.Util.ServerNow() < at end
return os.clock() < at
end
function Reicht.Halloween.NextCandy(dropsOnly)
local halloween = Reicht.Halloween
if os.clock() + Config.CandyPrepAhead < halloween.NextCollectAt then return nil end
local pad = Reicht.Halloween.PadPos()
local states = Reicht.Halloween.SpawnState()
local known = next(states) ~= nil
local now = os.clock()
local best, bestScore, bestDistance = nil, 0, math.huge
for _, inst in ipairs(CollectionService:GetTagged("HalloweenCandySpawn")) do
local id = inst:GetAttribute("Id") or inst.Name
local pos = Reicht.Halloween.PointOf(inst)
if not (id and pos) then continue end
if dropsOnly and not (id:sub(1, 9) == "DoorCandy" or id:sub(1, 11) == "PumpkinDrop") then continue end
if (halloween.SkipUntil[id] or 0) > now then continue end
local entry = states[id]
if Reicht.Halloween.Respawning(inst, entry) then continue end
if known and not entry then continue end
if entry and (entry.amount or 0) <= 0 then continue end
if (entry and entry.amount or 1) < (tonumber(Reicht.Util.Opt("CandyMinAmount")) or 1) then continue end
local dist = (pos - pad).Magnitude
if dist > (tonumber(Reicht.Util.Opt("CandyMaxRange")) or Config.CandyRangeDefault) then continue end
local score = Reicht.Halloween.CandyValue(entry or {}, dist)
if score > bestScore or (score > 0 and score == bestScore and dist < bestDistance) then
bestScore = score
bestDistance = dist
best = { id = id, pos = pos, value = score, instance = inst }
end
end
if best then best.cf = Reicht.Halloween.PickupCF(best.pos, best.instance) end
return best
end
function Reicht.Halloween.NextRespawnIn()
local states = Reicht.Halloween.SpawnState()
local soonest = nil
for _, entry in pairs(states) do
if entry.respawning and entry.respawnAt then
local left = entry.respawnAt - workspace:GetServerTimeNow()
if left > 0 and (not soonest or left < soonest) then
soonest = left
end
end
end
return soonest
end
function Reicht.Halloween.AskDoors()
local halloween = Reicht.Halloween
local now = os.clock()
if halloween.DoorStateAt > 0 and now - halloween.DoorStateAt < Config.DoorStateCache then
return halloween.DoorState
end
local remote = Reicht.Net.GetDoorState
if not remote then return halloween.DoorState end
local ok, state = GameLib.Call(remote.InvokeServer, remote)
halloween.DoorStateAt = now
if ok and type(state) == "table" then halloween.DoorState = state end
return halloween.DoorState
end
function Reicht.Halloween.DoorLit(id)
local state = Reicht.Halloween.AskDoors()
if type(state) ~= "table" then return nil end
local raw = type(state.Doors) == "table" and state.Doors or state
local entry = raw[id]
if type(entry) == "table" then return entry.Lit == true end
if type(entry) == "boolean" then return entry end
return nil
end
function Reicht.Halloween.NextDoor()
local halloween = Reicht.Halloween
local now = os.clock()
for _, house in ipairs(Reicht.Halloween.Houses()) do
if not house:IsA("Model") then continue end
local pivot = house:GetPivot()
local id = Reicht.Halloween.DoorId(house, pivot)
if (halloween.DoorAt[id] or 0) > now then continue end
if Reicht.Halloween.DoorLit(id) ~= true then continue end
return {
id = id,
cf = CFrame.new(pivot.Position + Vector3.new(Config.DoorStand, Config.StandLift, Config.DoorStand)),
}
end
return nil
end
function Reicht.Halloween.PumpkinLooted(state, id)
if type(state) ~= "table" then return false end
local raw = state.Pumpkins or state
local entry = raw[id]
if type(entry) ~= "table" then return false end
local searched = tonumber(entry.SearchedAt)
if not searched then return entry.Looted == true end
local age = searched > 1e6 and (Reicht.Util.ServerNow() - searched) or (os.clock() - searched)
return entry.Looted == true or age < Config.PumpkinCooldown
end
function Reicht.Halloween.NextPumpkin()
local halloween = Reicht.Halloween
local remote = Reicht.Net.GetPumpkinState
local now = os.clock()
if remote and now - halloween.PumpkinStateAt >= Config.PumpkinStateCache then
local ok, state = GameLib.Call(remote.InvokeServer, remote)
halloween.PumpkinStateAt = now
if ok and type(state) == "table" then halloween.PumpkinState = state end
end
for _, inst in ipairs(CollectionService:GetTagged("PumpkinPrompt")) do
local id = inst:GetAttribute("Id") or (inst.Parent and inst.Parent:GetAttribute("Id")) or inst.Name
local pos = Reicht.Halloween.PointOf(inst)
if not (id and pos) then continue end
if (halloween.PumpkinAt[id] or 0) > now then continue end
if Reicht.Halloween.PumpkinLooted(halloween.PumpkinState, id) then continue end
return { id = id, pos = pos }
end
return nil
end
function Reicht.Halloween.RitualInfo()
local ritual = Workspace:FindFirstChild("HeadlessRitual")
if not ritual then return nil end
local phase = ritual:GetAttribute("Phase")
local cooldownUntil = tonumber(ritual:GetAttribute("CooldownUntil")) or 0
return {
model = ritual,
phase = phase,
open = phase == "Open" and Reicht.Util.ServerNow() >= cooldownUntil,
}
end
function Reicht.Halloween.RitualReady()
local halloween = Reicht.Halloween
local info = Reicht.Halloween.RitualInfo()
if not info then
State.Status.Ritual = "Ritual not found"
return nil
end
if not info.open then
State.Status.Ritual = "Ritual: " .. tostring(info.phase)
halloween.RitualSeenOpen = false
return nil
end
if not halloween.RitualSeenOpen then
halloween.RitualSeenOpen = true
Reicht.Util.Notify("Halloween", "The ritual is open", 8)
end
if os.clock() < halloween.RitualAt then return nil end
local pivot = info.model:GetPivot()
return CFrame.new(pivot.Position + pivot.LookVector * Config.RitualStand + Vector3.new(0, Config.StandLift, 0))
end
function Reicht.Halloween.RitualInteract()
local info = Reicht.Halloween.RitualInfo()
if not info then return 0 end
local fired = 0
for _, node in ipairs(info.model:GetDescendants()) do
if fired >= Config.RitualPrompts then break end
if not (node:IsA("ProximityPrompt") and node.Enabled) then continue end
if Reicht.Rewards.TriggerPrompt(node) then fired += 1 end
task.wait(Config.RitualPromptGap)
end
return fired
end
function Reicht.Halloween.WantsMove()
local opt = Reicht.Util.Opt
return Reicht.Halloween.Finishing or Reicht.Halloween.BuyTravel or Reicht.Halloween.Purchase ~= nil or opt("AutoCandy") == true or opt("AutoTrickOrTreat") == true or opt("AutoPumpkin") == true
or opt("AutoRitual") == true or Reicht.Halloween.ManualCandy == true or Reicht.Halloween.ManualPass ~= nil
end
function Reicht.Halloween.AnyActive()
local opt = Reicht.Util.Opt
return Reicht.Halloween.WantsMove() or opt("AutoHalloweenEgg") == true or Reicht.Halloween.BuyOnce == true
end
function Reicht.Halloween.Claim()
local halloween = Reicht.Halloween
if halloween.Token and Reicht.Tasks.Holds(halloween.Token) then return true end
halloween.Token = Reicht.Tasks.Request("Halloween", Config.HalloweenPrio)
return halloween.Token ~= nil
end
function Reicht.Halloween.Release()
local halloween = Reicht.Halloween
local token = halloween.Token
halloween.Token = nil
if token then Reicht.Tasks.Release(token) end
end
function Reicht.Halloween.Reset(note)
local halloween = Reicht.Halloween
halloween.Target = nil
halloween.DepositRetried = false
if halloween.CollectBankBefore ~= nil and Reicht.Halloween.Carried() == 0 then halloween.CollectBankBefore = nil end
Reicht.Halloween.Release()
Reicht.Halloween.SetPhase("Idle", note)
end
function Reicht.Halloween.BeginDeposit()
local halloween = Reicht.Halloween
halloween.DepositCarried = Reicht.Halloween.Carried()
halloween.DepositBankBefore = halloween.CollectBankBefore or Reicht.Halloween.Tokens()
halloween.Target = { kind = "deposit", cf = Reicht.Halloween.PadCF() }
Reicht.Halloween.SetPhase("Travel")
end
function Reicht.Halloween.BeginTarget(kind, id, cf, source)
Reicht.Halloween.Target = { kind = kind, id = id, cf = cf, source = source }
Reicht.Halloween.SetPhase("Travel")
end
function Reicht.Halloween.StepTravel()
local halloween = Reicht.Halloween
local target = halloween.Target
if not target or not target.cf then return Reicht.Halloween.Reset() end
if not Reicht.Halloween.Claim() then return end
if target.kind == "deposit" and Reicht.Halloween.Carried() > 0 then
halloween.Token.critical = true
local hrp = Reicht.Player.Root
local delta = target.cf.Position - hrp.Position
local hop = math.min(Reicht.Halloween.DirectLimit(), delta.Magnitude)
if hop > 0 and not target.hopped then
target.hopped = true
if not Reicht.Tasks.Teleport(halloween.Token, hrp.CFrame + delta.Unit * hop) then
return Reicht.Halloween.Reset("Candy return interrupted")
end
end
local expires = tonumber(LocalPlayer:GetAttribute("CandyExpiresAt"))
local remaining = expires and expires == expires and expires < math.huge
and expires - Reicht.Util.ServerNow() or Config.CandySpoilAt - (os.clock() - halloween.FirstPickAt)
local reached = Reicht.Tasks.Travel(halloween.Token, target.cf, Reicht.Halloween.ReturnSpeed, math.max(0, remaining), {
noClip = true,
maxFlags = halloween.FlagsBaseline or Reicht.Player:Flags(),
reach = Config.CandyDepositReach,
done = function() return Reicht.Halloween.Carried() == 0 end,
})
if not reached then return Reicht.Halloween.Reset("Candy return interrupted") end
return Reicht.Halloween.SetPhase("Deposit")
end
local hrp = Reicht.Player.Root
local loaded = target.source and target.source.instance and target.source.instance.Parent
if not loaded and hrp and (hrp.Position - target.cf.Position).Magnitude > Config.EventStreamDist then
pcall(LocalPlayer.RequestStreamAroundAsync, LocalPlayer, target.cf.Position, Config.EventStreamTimeout)
end
if not Reicht.Tasks.Teleport(halloween.Token, target.cf) then
return Reicht.Halloween.Reset("Could not move")
end
Reicht.Halloween.SetPhase("Settle")
end
function Reicht.Halloween.StepSettle()
local halloween = Reicht.Halloween
local target = halloween.Target
if not target then return Reicht.Halloween.Reset() end
local settle = target.kind == "candy" and Config.CandyPickupSettle or Config.HalloweenSettle
if os.clock() - halloween.PhaseAt < settle then return end
if not Reicht.Halloween.Claim() then return end
if target.kind == "candy" then
if os.clock() < halloween.NextCollectAt then return end
local source = target.source
if source and source.instance and not source.instance.Parent then
return Reicht.Halloween.Reset("Candy disappeared; selecting another spawn")
end
halloween.CandyStateAt = 0
local entry = Reicht.Halloween.SpawnState()[target.id]
if entry and ((entry.amount or 0) <= 0 or entry.respawning) then
return Reicht.Halloween.Reset("Candy is respawning; selecting another spawn")
end
if not Reicht.Tasks.Holds(halloween.Token) then return Reicht.Halloween.Reset("Waiting for a turn") end
local hrp = Reicht.Player.Root
if source and hrp and (hrp.Position - source.pos).Magnitude > Config.CandyPickupLimit then
if target.repositioned then return Reicht.Halloween.Reset("Could not reach the candy") end
target.repositioned = true
target.cf = CFrame.new(source.pos + Vector3.new(0, Reicht.Halloween.StandLift(), 0))
return Reicht.Halloween.SetPhase("Travel")
end
local remote = Reicht.Net.CollectCandy
if not remote then return Reicht.Halloween.Reset("Candy collecting is unavailable") end
halloween.CarriedBefore = Reicht.Halloween.Carried()
halloween.CollectBankBefore = Reicht.Halloween.Tokens()
halloween.LastCollectAt = os.clock()
remote:FireServer(target.id)
return Reicht.Halloween.SetPhase("Collect")
end
if target.kind == "door" then
local remote = Reicht.Net.KnockDoor
if remote then
remote:FireServer(target.id)
halloween.DoorAt[target.id] = os.clock() + Config.DoorCooldown
halloween.Stats.knocks += 1
end
return Reicht.Halloween.Reset("Knocked")
end
if target.kind == "pumpkin" then
local remote = Reicht.Net.SearchPumpkin
if remote then
remote:FireServer(target.id)
halloween.PumpkinAt[target.id] = os.clock() + Config.PumpkinCooldown
end
return Reicht.Halloween.Reset("Searched")
end
if target.kind == "ritual" then
local fired = Reicht.Halloween.RitualInteract()
halloween.RitualAt = os.clock() + Config.RitualRetry
return Reicht.Halloween.Reset(fired > 0 and "Ritual visited" or "Ritual is not ready")
end
if target.kind == "deposit" then
return Reicht.Halloween.SetPhase("Deposit")
end
if target.kind == "shop" then return Reicht.Halloween.BuyAtShop() end
if target.kind == "portal" then
Reicht.Halloween.PortalTries = (Reicht.Halloween.PortalTries or 0) + 1
task.spawn(function()
local tries = Reicht.Halloween.PortalTries
local epoch = Reicht.Player.Epoch
for attempt = 1, 6 do
if not State.Alive or State.Unloading or epoch ~= Reicht.Player.Epoch then return end
if not Reicht.Halloween.WantsMove() then return end
local portal = Workspace:FindFirstChild("Map")
portal = portal and portal:FindFirstChild("Portal")
if not (portal and Reicht.Player:IsAlive()) then break end
if Reicht.Halloween.PortalTries ~= tries then return end
local fired = false
for _, prompt in ipairs(portal:GetDescendants()) do
if prompt:IsA("ProximityPrompt") then
fired = pcall(fireproximityprompt, prompt) or fired
end
end
if LocalPlayer:GetAttribute("InHalloweenZone") == true then return end
task.wait(0.4)
end
end)
return Reicht.Halloween.Reset("Entering the event")
end
Reicht.Halloween.Reset("Entering the event")
end
function Reicht.Halloween.StepCollect()
local halloween = Reicht.Halloween
local target = halloween.Target
if not target then return Reicht.Halloween.Reset() end
local carried = Reicht.Halloween.Carried()
local banked = halloween.CollectBankBefore and Reicht.Halloween.Tokens() - halloween.CollectBankBefore or 0
if carried == 0 and banked > 0 then
halloween.Stats.candy += banked
halloween.NextCollectAt = halloween.LastCollectAt + Config.CandyCooldown
halloween.CandyStateAt = 0
halloween.DepositBankBefore = halloween.CollectBankBefore
return Reicht.Halloween.SetPhase("Deposit")
end
if carried > halloween.CarriedBefore then
if halloween.FirstPickAt == 0 then halloween.FirstPickAt = os.clock() end
halloween.Stats.candy += carried - halloween.CarriedBefore
halloween.NextCollectAt = halloween.LastCollectAt + Config.CandyCooldown
halloween.CandyStateAt = 0
return Reicht.Halloween.BeginDeposit()
end
if halloween.FirstPickAt > 0 and carried > 0 and os.clock() - halloween.FirstPickAt >= Config.CandySpoilAt then
return Reicht.Halloween.BeginDeposit()
end
if os.clock() - halloween.PhaseAt > Config.CandyCollectTimeout then
halloween.SkipUntil[target.id] = os.clock() + Config.CandySkipSec
halloween.CandyStateAt = 0
return Reicht.Halloween.Reset("Candy did not answer")
end
end
function Reicht.Halloween.StepDeposit()
local halloween = Reicht.Halloween
if Reicht.Halloween.Carried() == 0 then
local banked = Reicht.Halloween.Tokens() - halloween.DepositBankBefore
if banked <= 0 then
if os.clock() - halloween.PhaseAt < Config.CandyDepositTimeout then return end
halloween.Spoiled += 1
halloween.FirstPickAt = 0
return Reicht.Halloween.Reset("Candy cleared without a confirmed deposit")
end
halloween.TokensEarned += banked
halloween.Cycles += 1
halloween.FirstPickAt = 0
halloween.DepositDoneAt = os.clock()
if halloween.ManualCandy then halloween.ManualCandy = false end
return Reicht.Halloween.Reset("Cashed in " .. banked)
end
if os.clock() - halloween.PhaseAt <= Config.CandyDepositTimeout then return end
if not halloween.DepositRetried then
halloween.DepositRetried = true
if Reicht.Halloween.Claim() and Reicht.Tasks.Teleport(halloween.Token, Reicht.Halloween.PadCF()) then
return Reicht.Halloween.SetPhase("Deposit")
end
end
Reicht.Halloween.Reset("Could not reach the candy pad")
end
function Reicht.Halloween.StepIdle()
local halloween = Reicht.Halloween
local opt = Reicht.Util.Opt
local carried = Reicht.Halloween.Carried()
local spoiling = carried > 0 and halloween.FirstPickAt > 0 and os.clock() - halloween.FirstPickAt >= Config.CandySpoilAt
if carried > 0 and (carried >= Config.CandyCarryGoal or spoiling) then
return Reicht.Halloween.BeginDeposit()
end
local fullCandy = opt("AutoCandy") == true or halloween.ManualCandy
local dropsOnly = not fullCandy and (opt("AutoTrickOrTreat") == true or opt("AutoPumpkin") == true or halloween.ManualPass ~= nil)
if fullCandy or dropsOnly then
if os.clock() + Config.CandyPrepAhead >= halloween.NextCollectAt then
if not Reicht.Halloween.Claim() then return end
if Reicht.Util.Opt("CandyAutoMount") ~= false then Reicht.Mount.Ensure(halloween.Token) end
end
local candy = Reicht.Halloween.NextCandy(dropsOnly)
if candy then
return Reicht.Halloween.BeginTarget("candy", candy.id,
candy.cf, candy)
end
if carried > 0 then
local waitLeft = Reicht.Halloween.NextRespawnIn()
local spoilLeft = halloween.FirstPickAt > 0 and Config.CandySpoilAt - (os.clock() - halloween.FirstPickAt) or Config.CandySpoilAt
if not (waitLeft and waitLeft < spoilLeft - 2) then
return Reicht.Halloween.BeginDeposit()
end
end
if halloween.ManualCandy then
if carried == 0 then
halloween.ManualCandy = false
else
return Reicht.Halloween.BeginDeposit()
end
end
end
if opt("AutoTrickOrTreat") == true or halloween.ManualPass == "doors" then
local door = Reicht.Halloween.NextDoor()
if door then return Reicht.Halloween.BeginTarget("door", door.id, door.cf) end
end
if opt("AutoPumpkin") == true or halloween.ManualPass == "pumpkins" then
local pumpkin = Reicht.Halloween.NextPumpkin()
if pumpkin then
return Reicht.Halloween.BeginTarget("pumpkin", pumpkin.id,
CFrame.new(pumpkin.pos + Vector3.new(0, Config.StandLift, 0)))
end
end
if opt("AutoRitual") == true then
local altar = Reicht.Halloween.RitualReady()
if altar then return Reicht.Halloween.BeginTarget("ritual", "ritual", altar) end
end
if halloween.ManualPass then halloween.ManualPass = nil end
Reicht.Halloween.Release()
local cooldownLeft = halloween.NextCollectAt - os.clock()
if cooldownLeft > 0 then
return Reicht.Halloween.SetPhase("Idle", string.format("Pickup cooldown %.0fs", cooldownLeft))
end
Reicht.Halloween.SetPhase("Idle", "Waiting for candy to respawn")
end
function Reicht.Halloween.StepZone()
local halloween = Reicht.Halloween
local now = os.clock()
if now < halloween.ZoneRetryAt then return end
halloween.ZoneTries += 1
if halloween.ZoneTries > Config.HalloweenZoneTries then
return Reicht.Halloween.LeaveZone()
end
halloween.ZoneRetryAt = now + Config.HalloweenZoneGap
halloween.Target = { kind = "portal", cf = Reicht.Halloween.PortalCF() }
Reicht.Halloween.SetPhase("Travel")
end
function Reicht.Halloween.LeaveZone()
Reicht.Halloween.StopMovement("Left the event island, event farming stopped")
end
function Reicht.Halloween.StopMovement(note)
local halloween = Reicht.Halloween
halloween.ManualCandy, halloween.ManualPass, halloween.ManualUntil = false, nil, nil
Reicht.Halloween.Reset(note)
for _, idx in ipairs({ "AutoCandy", "AutoTrickOrTreat", "AutoPumpkin", "AutoRitual" }) do
table.insert(State.PendingToggleOff, idx)
end
table.insert(State.PendingNotify, { "Halloween", note })
end
function Reicht.Halloween.RecoverMovement()
local halloween = Reicht.Halloween
local percent = Reicht.Halloween.ReturnFactor() * 100
halloween.ReturnCapPercent = math.max(100, math.min(200, percent * 0.75))
halloween.ReturnHopDisabled = true
halloween.FlagsBaseline = Reicht.Player:Flags()
halloween.RecoveryUntil = os.clock() + (Reicht.Halloween.Carried() > 0 and 0.15 or 1)
halloween.CandyStateAt = 0
Reicht.Halloween.Reset("Retrying at " .. math.floor(halloween.ReturnCapPercent) .. "%")
if Reicht.Halloween.Carried() > 0 then Reicht.Halloween.BeginDeposit() end
end
function Reicht.Halloween.KnownPrice()
local halloween = Reicht.Halloween
if halloween.PriceSeen then return halloween.PriceSeen end
local lib = Reicht.Halloween.CandyLib()
local eggs = lib and lib.Eggs
local egg = eggs and eggs["Halloween Egg"]
halloween.PriceFound = egg and tonumber(egg.Price) or nil
return halloween.PriceFound
end
function Reicht.Halloween.ShopAnchor()
for _, tag in ipairs({ "HalloweenShopGuy", "HalloweenShopPrompt" }) do
for _, inst in ipairs(CollectionService:GetTagged(tag)) do
local pos = Reicht.Halloween.PointOf(inst)
if pos then return inst, pos end
end
end
return nil, nil
end
function Reicht.Halloween.BuyBlocked(reason)
Reicht.Halloween.BuyOnce, Reicht.Halloween.BuyTravel = false, false
State.Status.HalloweenEgg = reason
end
function Reicht.Halloween.CanBuy()
local price = Reicht.Halloween.KnownPrice()
if not price or price <= 0 then
Reicht.Halloween.BuyBlocked("Egg price is unavailable")
return false
end
local keep = math.max(0, tonumber(Reicht.Util.Opt("HalloweenKeepTokens")) or 0)
local tokens = Reicht.Halloween.Tokens()
if tokens < price + keep then
Reicht.Halloween.BuyBlocked("Saving " .. Reicht.Util.Format(tokens) .. " / " .. Reicht.Util.Format(price + keep) .. " tokens")
return false
end
local event = GameLib.Svc and GameLib.Svc.HalloweenEvent
if event and type(event.IsLive) == "function" then
local ok, live = GameLib.Call(event.IsLive)
if not ok or live ~= true then
Reicht.Halloween.BuyBlocked("Halloween egg shop is closed")
return false
end
end
local limit = tonumber(Reicht.Util.Opt("HalloweenBuyLimit")) or 0
if not Reicht.Halloween.BuyOnce and limit > 0 and Reicht.Halloween.EggsBought >= limit then
Reicht.Halloween.BuyBlocked("Egg purchase limit reached")
return false
end
return true
end
function Reicht.Halloween.BuyStep()
local halloween = Reicht.Halloween
local opt = Reicht.Util.Opt
if not (opt("AutoHalloweenEgg") == true or halloween.BuyOnce) then return end
if halloween.Purchase or halloween.Phase ~= "Idle" or Reicht.Tasks.Carrying() then return end
if os.clock() - halloween.LastBuyAt < Config.HalloweenEggGap then return end
local remote = Reicht.Net.BuyHalloweenEgg
if not remote then
State.Status.HalloweenEgg = "Egg shop is unavailable"
return
end
if not Reicht.Halloween.CanBuy() then return end
halloween.BuyTravel = true
if Reicht.Halloween.InZone() ~= true then return end
local inst, pos = Reicht.Halloween.ShopAnchor()
if not pos or not Reicht.Halloween.Claim() then return end
local hrp = Reicht.Player.Root
halloween.ShopHome = { hrp.CFrame, Reicht.Player.Epoch }
State.Status.HalloweenEgg = "Going to the egg shop"
local cf = Reicht.Halloween.PickupCF(pos, inst)
Reicht.Halloween.BeginTarget("shop", nil, cf, { instance = inst, pos = pos })
end
function Reicht.Halloween.BuyAtShop()
local halloween = Reicht.Halloween
if not Reicht.Halloween.CanBuy() then return Reicht.Halloween.FinishShop() end
local target = halloween.Target
local hrp = Reicht.Player.Root
if not target or not target.source or not hrp then return Reicht.Halloween.FinishShop("Could not reach the egg shop") end
local distance = Reicht.Util.Flat(hrp.Position, target.source.pos)
if distance > Config.HalloweenShopRange then
target.cf = CFrame.new(target.source.pos + Vector3.new(0, Reicht.Halloween.StandLift(), 0))
return Reicht.Halloween.SetPhase("Travel")
end
local before = {}
for _, row in ipairs(Reicht.Hatch.EggTools()) do before[row[1]] = true end
local tokens = Reicht.Halloween.Tokens()
local price = Reicht.Halloween.KnownPrice()
local remote = Reicht.Net.BuyHalloweenEgg
halloween.LastBuyAt = os.clock()
local ok, bought = GameLib.Call(remote.InvokeServer, remote, "Halloween Egg")
halloween.BuyOnce = false
if not ok or bought ~= true then
halloween.LastBuyAt = os.clock() + Config.HalloweenShopRetry
return Reicht.Halloween.FinishShop(ok and "Egg shop refused the purchase; retrying later" or "Egg shop did not answer")
end
halloween.Purchase = { before = before, tokens = tokens, price = price, at = os.clock(), epoch = Reicht.Player.Epoch }
State.Status.HalloweenEgg = "Confirming the egg purchase"
Reicht.Halloween.SetPhase("Purchase")
end
function Reicht.Halloween.StepPurchase()
local halloween = Reicht.Halloween
local purchase = halloween.Purchase
if not purchase then return Reicht.Halloween.FinishShop() end
local tool
for _, row in ipairs(Reicht.Hatch.EggTools()) do
if row[2] == "Halloween Egg" and not purchase.before[row[1]] then tool = row[1]; break end
end
local spent = purchase.tokens - Reicht.Halloween.Tokens()
if spent < purchase.price or not tool then
if os.clock() - purchase.at < Config.HalloweenPurchaseTimeout then return end
return Reicht.Halloween.FinishShop("Purchase not confirmed; check the egg inventory")
end
halloween.EggsBought += 1
local note = "Bought " .. halloween.EggsBought .. " eggs"
if Reicht.Util.Opt("HalloweenAutoHatch") ~= false and purchase.epoch == Reicht.Player.Epoch and Reicht.Halloween.Claim() then
halloween.Token.critical = true
local key = Reicht.Hatch.PlantTool(halloween.Token, tool)
if key then
Reicht.Hatch.Purchased[key] = true
local hatched = Reicht.Tasks.Await(halloween.Token, function()
if Reicht.Hatch.Confirmed[key] then return true end
local egg = State.PlotEggs[key]
local left = egg and Reicht.Hatch.Left(egg)
if left and left <= 0 then Reicht.Hatch.HatchNow(key) end
return false
end, Config.HalloweenPurchaseTimeout)
note = hatched and "Bought and hatched the Halloween egg" or "Egg placed; waiting to hatch"
else
note = "Bought egg; no free plot space, kept in inventory"
end
end
Reicht.Halloween.FinishShop(note)
end
function Reicht.Halloween.FinishShop(note)
local halloween = Reicht.Halloween
local home, token = halloween.ShopHome, halloween.Token
if home and token and home[2] == Reicht.Player.Epoch and not Reicht.Tasks.Carrying() then
Reicht.Tasks.Teleport(token, home[1])
end
halloween.ShopHome, halloween.Purchase, halloween.BuyTravel = nil, nil, false
if note then State.Status.HalloweenEgg = note end
Reicht.Halloween.Reset()
end
function Reicht.Halloween.StepOnce()
local halloween = Reicht.Halloween
Reicht.Halloween.Bind()
if halloween.FlagsBaseline and Reicht.Player:Flags() > halloween.FlagsBaseline then
return Reicht.Halloween.RecoverMovement()
end
if os.clock() < (halloween.RecoveryUntil or 0) then return end
if not Reicht.Player:IsAlive() then return Reicht.Halloween.Reset("Waiting for respawn") end
if halloween.Finishing and halloween.Phase == "Idle" and Reicht.Halloween.Carried() == 0 then
return Reicht.Halloween.Stop()
end
if halloween.Token and not Reicht.Tasks.Holds(halloween.Token) then
return Reicht.Halloween.Reset("Waiting for a turn")
end
Reicht.Halloween.BuyStep()
if halloween.ManualUntil and os.clock() > halloween.ManualUntil then
halloween.ManualCandy, halloween.ManualPass, halloween.ManualUntil = false, nil, nil
end
if not Reicht.Halloween.WantsMove() then
if halloween.Phase ~= "Idle" then Reicht.Halloween.Reset() end
return
end
if halloween.Phase ~= "Idle" and os.clock() - halloween.PhaseAt > Config.HalloweenPhaseBudget then
Reicht.Halloween.Reset("Restarting")
end
local phase = halloween.Phase
if phase == "Purchase" then return Reicht.Halloween.StepPurchase() end
if phase == "Travel" then return Reicht.Halloween.StepTravel() end
if phase == "Settle" then return Reicht.Halloween.StepSettle() end
if phase == "Collect" then return Reicht.Halloween.StepCollect() end
if phase == "Deposit" then return Reicht.Halloween.StepDeposit() end
if Reicht.Halloween.InZone() ~= true then return Reicht.Halloween.StepZone() end
halloween.ZoneTries = 0
return Reicht.Halloween.StepIdle()
end
function Reicht.Halloween.Step()
local halloween = Reicht.Halloween
if halloween.Busy then return end
halloween.Busy = true
local ok, err = pcall(Reicht.Halloween.StepOnce)
halloween.Busy = false
if not ok then
Reicht.Halloween.Reset("Restarting after an error")
error(err, 0)
end
end
function Reicht.Halloween.OnCarried(value)
local halloween = Reicht.Halloween
if value > 0 and halloween.CarriedWas == 0 then
halloween.FirstPickAt = os.clock()
elseif value == 0 and halloween.CarriedWas > 0 and not (halloween.Target and halloween.Target.kind == "deposit") then
if os.clock() - (halloween.DepositDoneAt or 0) > 2 then
halloween.FirstPickAt = 0
halloween.Spoiled += 1
end
end
halloween.CarriedWas = value
Reicht.Halloween.UpdateStatus()
end
function Reicht.Halloween.Bind()
local halloween = Reicht.Halloween
if halloween.Bound or halloween.AwaitCarried then return end
local noSave = LocalPlayer:FindFirstChild("NoSaveData")
if not noSave then return end
local carried = noSave:FindFirstChild("CarriedCandy")
if not carried then
halloween.AwaitCarried = true
table.insert(halloween.Conns, noSave.ChildAdded:Connect(function(child)
if child.Name == "CarriedCandy" then
halloween.Bound, halloween.AwaitCarried = false, false
end
end))
return
end
halloween.Bound = true
halloween.CarriedWas = tonumber(carried.Value) or 0
table.insert(halloween.Conns, carried.Changed:Connect(Reicht.Halloween.OnCarried))
local reply = GameLib.Remote("DoorKnocked")
if reply then
table.insert(halloween.Conns, reply.OnClientEvent:Connect(function(id, isTreat, amount)
if isTreat then
halloween.Stats.treats += 1
table.insert(State.PendingNotify, { "Trick-or-Treat", "Treat: " .. tostring(amount) .. " candy dropped" })
end
end))
end
local ritual = Workspace:FindFirstChild("HeadlessRitual")
if ritual then
table.insert(halloween.Conns, ritual:GetAttributeChangedSignal("Phase"):Connect(function()
if ritual:GetAttribute("Phase") ~= "Open" then halloween.RitualSeenOpen = false end
end))
end
end
function Reicht.Halloween.CandyNow()
Reicht.Halloween.Start()
Reicht.Halloween.ManualCandy = true
Reicht.Halloween.ManualUntil = os.clock() + Config.HalloweenManualTimeout
end
function Reicht.Halloween.KnockNow()
Reicht.Halloween.Start()
Reicht.Halloween.ManualPass = "doors"
Reicht.Halloween.ManualUntil = os.clock() + Config.HalloweenManualTimeout
end
function Reicht.Halloween.SearchNow()
Reicht.Halloween.Start()
Reicht.Halloween.ManualPass = "pumpkins"
Reicht.Halloween.ManualUntil = os.clock() + Config.HalloweenManualTimeout
end
function Reicht.Halloween.BuyNow()
Reicht.Halloween.Start()
Reicht.Halloween.BuyOnce = true
end
function Reicht.Halloween.ExitNow()
local halloween = Reicht.Halloween
halloween.ManualCandy, halloween.ManualPass, halloween.ManualUntil, halloween.BuyOnce = false, nil, nil, false
Reicht.Halloween.Reset("Stopped")
end
function Reicht.Halloween.TierOf(id)
if id:sub(1, 9) == "DoorCandy" then return "Door Candy", Config.RarityColors.Legendary end
if id:sub(1, 11) == "PumpkinDrop" then return "Pumpkin Drop", Config.RarityColors.Legendary end
local tier = id:match("^Candy(%d)_")
if tier == "1" then return "Candy", Config.RarityColors.Common end
if tier == "2" then return "Rare Candy", Config.RarityColors.Rare end
if tier == "3" then return "Epic Candy", Config.RarityColors.Epic end
return "Candy", Color3.new(1, 1, 1)
end
function Reicht.Halloween.EspStep()
if not State.Alive or not Reicht.Util.Opt("HalloweenEsp") then return end
Reicht.Halloween.Bind()
local halloween = Reicht.Halloween
local esp = Reicht.Esp
local hrp = Reicht.Player.Root
local range = Reicht.Platform.Mobile and Config.EspRangeMobile or Config.EspRange
local kinds = Reicht.Util.Opt("HalloweenEspTypes")
if type(kinds) ~= "table" or not next(kinds) then
kinds = { Candy = true, Doors = true, Pumpkins = true, Altar = true }
end
local seen = {}
local function Show(key, pos, text, color)
local dist = hrp and (pos - hrp.Position).Magnitude or 0
if dist > range then return end
seen[key] = true
local slot = halloween.Boards[key]
if not slot or not slot.board.Parent then
slot = esp.Take()
halloween.Boards[key] = slot
end
slot.anchor.WorldPosition = pos
slot.board.MaxDistance = range
slot.board.Enabled = true
slot.label.TextColor3 = color
slot.label.Text = type(text) == "function" and text(math.floor(dist)) or text
end
if kinds.Candy then
local states = Reicht.Halloween.SpawnState()
for _, inst in ipairs(CollectionService:GetTagged("HalloweenCandySpawn")) do
local id = inst:GetAttribute("Id") or inst.Name
local pos = Reicht.Halloween.PointOf(inst)
if id and pos and not Reicht.Halloween.Respawning(inst, states[id]) then
local label, color = Reicht.Halloween.TierOf(id)
local amount = states[id] and states[id].amount
Show("candy:" .. id, pos, function(dist)
return string.format("%s%s | %dm", label, amount and (" " .. amount) or "", dist)
end, color)
end
end
end
if kinds.Doors then
for _, house in ipairs(Reicht.Halloween.Houses()) do
if not house:IsA("Model") then continue end
local pivot = house:GetPivot()
local id = Reicht.Halloween.DoorId(house, pivot)
local lit = Reicht.Halloween.DoorLit(id)
Show("door:" .. id, pivot.Position,
lit == true and "Door Lit" or lit == false and "Door Dark" or "Door",
lit == true and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(170, 170, 170))
end
end
if kinds.Pumpkins then
for _, inst in ipairs(CollectionService:GetTagged("PumpkinPrompt")) do
local pos = Reicht.Halloween.PointOf(inst)
if pos then Show("pumpkin:" .. tostring(inst), pos, "Pumpkin", Color3.fromRGB(255, 140, 40)) end
end
end
if kinds.Altar then
local info = Reicht.Halloween.RitualInfo()
if info then
Show("altar", info.model:GetPivot().Position,
"Ritual Altar" .. (info.phase and (" (" .. tostring(info.phase) .. ")") or ""),
Color3.fromRGB(190, 80, 255))
end
Show("pad", Reicht.Halloween.PadPos(), "Candy Pad", Config.RarityColors.Legendary)
end
for key in pairs(halloween.Boards) do
if not seen[key] then esp.Disown(halloween.Boards, key) end
end
end
function Reicht.Halloween.ClearEsp()
local halloween = Reicht.Halloween
for key in pairs(halloween.Boards) do
Reicht.Esp.Disown(halloween.Boards, key)
end
end
function Reicht.Halloween.Places()
local places = {}
if not Reicht.Halloween.EventLive() then return places end
places["Event: Candy Pad"] = function()
return CFrame.new(Reicht.Halloween.PadPos() + Vector3.new(0, Config.CandyPadLift, 0))
end
places["Event: Portal"] = Reicht.Halloween.PortalCF
for index, house in ipairs(Reicht.Halloween.Houses()) do
if house:IsA("Model") then
local pivot = house:GetPivot()
places["Event: House " .. index] = function()
return CFrame.new(pivot.Position + Vector3.new(Config.DoorStand, Config.StandLift, Config.DoorStand))
end
end
end
local ritual = Workspace:FindFirstChild("HeadlessRitual")
if ritual then
places["Event: Ritual Altar"] = function()
local pivot = ritual:GetPivot()
return CFrame.new(pivot.Position + Vector3.new(0, Config.StandLift, 0))
end
end
return places
end
function Reicht.Halloween.Start()
local halloween = Reicht.Halloween
halloween.Finishing = false
if halloween.Enabled then return end
halloween.FlagsBaseline = Reicht.Player:Flags()
halloween.Enabled = true
halloween.ZoneTries = 0
halloween.ZoneRetryAt = 0
if halloween.StartedAt == 0 then halloween.StartedAt = os.clock() end
Reicht.Halloween.Bind()
Reicht.Halloween.SetPhase("Idle")
end
function Reicht.Halloween.Stop()
local halloween = Reicht.Halloween
halloween.Enabled = false
halloween.ManualCandy, halloween.ManualPass, halloween.ManualUntil, halloween.BuyOnce = false, nil, nil, false
if State.Alive and not State.Unloading and halloween.Purchase then return end
halloween.Purchase, halloween.BuyTravel, halloween.ShopHome = nil, false, nil
if State.Alive and not State.Unloading and Reicht.Halloween.Carried() > 0 then
halloween.Finishing = true
if not (halloween.Target and halloween.Target.kind == "deposit") then Reicht.Halloween.BeginDeposit() end
return
end
halloween.Finishing = false
Reicht.Halloween.Reset("Off")
for _, conn in ipairs(halloween.Conns) do
conn:Disconnect()
end
table.clear(halloween.Conns)
halloween.Bound = false
halloween.AwaitCarried = false
end
Reicht.Delivery = {}
function Reicht.Delivery.Mode(entry)
local _, bp = Reicht.Player:Plot()
if not bp or not entry or not entry.pos then return "Drop", math.huge end
local inside = Reicht.Geo.EdgeInside(bp, entry.pos)
if (inside - entry.pos).Magnitude <= Reicht.Config.PickupReach then return "Plot", 0 end
local trip = Reicht.Geo.Trip(bp, Reicht.Geo.StandPoint(bp, entry.pos))
local opts = Reicht.Options
if opts and opts.DeliveryMode == "Safe" then return "Drop", trip end
if Reicht.Delivery.Fits(trip, entry.weight, entry.egg) then return "Direct", trip end
return "Drop", trip
end
function Reicht.Delivery.WeightFactor(weight, eggName)
local cfg = Reicht.Config
local over = math.max(0, (tonumber(weight) or 1) - 1)
local per = eggName == "Cherub" and cfg.CherubWeightPenalty or cfg.WeightPenalty
return 1 - math.min(cfg.WeightPenaltyMax, over * 10 * per)
end
function Reicht.Delivery.Fits(trip, weight, eggName)
local factor = Reicht.Delivery.WeightFactor(weight, eggName)
local speed = Reicht.Mount.Speed()
if speed > 0 then return trip <= Reicht.State.Tune.DirectFactor * speed * factor end
return trip <= Reicht.Config.UnmountedDirect * factor
end
function Reicht.Delivery.Sleep(token, sec)
if sec <= 0 then return true end
local _, why = Reicht.Tasks.Await(token, nil, sec)
return why == "timeout"
end
function Reicht.Delivery.Pickup(token, guid, standPos)
local cfg = Reicht.Config
local remote = Reicht.GameLib.Remote("EggPickup")
local hrp = Reicht.Player.Root
if not remote or not hrp then return false, "missing" end
local flags = Reicht.Player:Flags()
if (hrp.Position - standPos).Magnitude > 1 then
if not Reicht.Tasks.Teleport(token, CFrame.new(standPos)) then return false, "aborted" end
if not Reicht.Delivery.Sleep(token, cfg.TpSettle) then return false, "aborted" end
end
local deadline = os.clock() + cfg.PickupTotalTimeout
local retried = false
repeat
if not Reicht.Tasks.Holds(token) or Reicht.Guard.Tripped or Reicht.Player:Flags() > flags then return false, "aborted" end
Reicht.EggIndex.Expect(guid)
remote:FireServer(guid)
local kind, text = Reicht.EggIndex.WaitReply(guid, cfg.PickupReplyTimeout)
if kind == "PickedUp" then return true, "ok" end
if Reicht.Player:BasketCount() > 0 then return true, "ok" end
if kind == "BasketFull" then return false, "full" end
if kind == "Gone" then
Reicht.EggIndex.MarkGone(guid)
return false, "gone"
end
if kind == "Refused" then
local distanceLag = tostring(text or ""):find("studs", 1, true) ~= nil
if retried or not distanceLag or Reicht.Player:Flags() > flags then return false, "refused" end
retried = true
if not Reicht.Delivery.Sleep(token, cfg.PickupAckWait) then return false, "aborted" end
end
until os.clock() >= deadline
return false, "timeout"
end
function Reicht.Delivery.AwaitDeposit(token, timeout)
local kind = Reicht.EggIndex.WaitReply("*carry", timeout)
return kind == "Deposited" and not Reicht.Guard.Tripped
end
function Reicht.Delivery.StepHome(token, bp)
local hrp = Reicht.Player.Root
if not hrp then return false end
Reicht.EggIndex.Expect("*carry")
return Reicht.Tasks.Teleport(token, CFrame.new(Reicht.Geo.EdgeInside(bp, hrp.Position)))
end
function Reicht.Delivery.FindDrop(eggName, origin, since, before)
local hrp = Reicht.Player.Root
local here = hrp and hrp.Position
local byOrigin, nearest, nearestDist = nil, nil, math.huge
for _, entry in pairs(Reicht.EggIndex.Entries) do
if not entry.dropEndsAt or entry.dropEndsAt < since then continue end
if before[entry.guid or ""] then continue end
if origin and entry.origin and Reicht.Util.Flat(entry.origin, origin) < 1 then
byOrigin = entry
break
end
if entry.egg == eggName and here then
local dist = Reicht.Util.Flat(entry.pos, here)
if dist < nearestDist then nearest, nearestDist = entry, dist end
end
end
return byOrigin or nearest
end
function Reicht.Delivery.Drop(token, eggName, origin)
local cfg = Reicht.Config
local remote = Reicht.GameLib.Remote("BasketDrop")
if not remote then return nil end
local before = {}
for _, entry in pairs(Reicht.EggIndex.Entries) do
if entry.guid then before[entry.guid] = true end
end
local since = Reicht.Util.ServerNow() - 0.5
remote:FireServer()
local drop
Reicht.Tasks.Await(token, function()
drop = Reicht.Delivery.FindDrop(eggName, origin, since, before)
return drop ~= nil
end, cfg.DropAppearTimeout)
return drop
end
function Reicht.Delivery.WaitLanded(token, drop)
local landAt = drop.dropEndsAt + Reicht.Config.DropEndsSlack
local remaining = landAt - Reicht.Util.ServerNow()
if remaining ~= remaining or remaining > Reicht.Config.DropLandMax then return false end
local timeout = math.max(Reicht.Config.DropAppearTimeout, remaining + 0.5)
local ok = Reicht.Tasks.Await(token, function() return Reicht.Util.ServerNow() >= landAt end, timeout)
return ok
end
function Reicht.Delivery.RaiseSettle()
local tune = Reicht.State.Tune
tune.DropSettle = math.min(tune.DropSettle + 0.05, Reicht.Config.DropSettleMax)
Reicht.State.Stats.staleDrops += 1
end
function Reicht.Delivery.LowerSettle()
local tune = Reicht.State.Tune
local floor = math.max(Reicht.Config.DropSettle, tonumber(Reicht.Util.Opt("DropSettle")) or 0)
tune.DropSettle = math.max(floor, tune.DropSettle - 0.01)
end
function Reicht.Delivery.BreakLeft()
local left
for _, egg in ipairs(Reicht.Player:BasketItems()) do
if egg:GetAttribute("Delivering") then continue end
local at = tonumber(egg:GetAttribute("BreakAt"))
if at then left = math.min(left or math.huge, at - Reicht.Util.ServerNow()) end
end
return left
end
function Reicht.Delivery.TravelCarry(token, cf, eggName)
local cfg = Reicht.Config
local root, speed = Reicht.Player.Root, Reicht.Mount.TravelSpeed()
if not root or speed <= 0 or Reicht.Player:BasketCount() == 0 then return false end
if not token.returnHop then
token.returnHop = true
local delta = cf.Position - root.Position
local hopLimit = math.min(cfg.ReturnHopMax, math.max(Reicht.Mount.Speed(), cfg.UnmountedPlayerSpeed) * State.Tune.DirectFactor)
local hop = math.min(hopLimit, math.max(0, delta.Magnitude - cfg.TravelStopDistance))
if hop > 0 then
if not Reicht.Tasks.Teleport(token, CFrame.new(root.Position + delta.Unit * hop) * root.CFrame.Rotation) then return false end
if not Reicht.Delivery.Sleep(token, cfg.TpSettle) then return false end
end
end
local timeout = (cf.Position - root.Position).Magnitude / speed + cfg.RunBudget
token.budget = math.max(token.budget or 0, os.clock() + timeout)
local expired = false
local reached = Reicht.Tasks.Travel(token, cf, Reicht.Mount.TravelSpeed, timeout, {
noClip = true, reach = cfg.TravelStopDistance,
done = function()
local left = Reicht.Delivery.BreakLeft()
expired = left ~= nil and left <= 0
return expired or Reicht.Player:BasketCount() == 0
end,
})
return reached and not expired and Reicht.Player:BasketCount() > 0
end
function Reicht.Delivery.DropCycle(token, bp, eggName, origin)
local cfg = Reicht.Config
for _ = 0, 2 do
local hrp = Reicht.Player.Root
if not hrp or os.clock() > token.budget then return "Aborted" end
local out = Reicht.Geo.Outside(bp, hrp.Position, cfg.DropOutside)
if not Reicht.Delivery.Fits(Reicht.Geo.Trip(bp, hrp.Position), nil, eggName) then
if not Reicht.Delivery.TravelCarry(token, CFrame.new(out), eggName) then return "Aborted" end
elseif not Reicht.Tasks.Teleport(token, CFrame.new(out)) then
return "Aborted"
end
if not Reicht.Delivery.Sleep(token, Reicht.State.Tune.DropSettle) then return "Aborted" end
local drop = Reicht.Delivery.Drop(token, eggName, origin)
if not drop then return Reicht.Player:BasketCount() == 0 and "Gone" or "Aborted" end
origin = drop.origin or origin
local fresh = Reicht.Util.Flat(drop.pos, out) <= cfg.StaleDropDistance
local stand = fresh and out or drop.pos + Vector3.new(0, Reicht.Geo.Lift(), 0)
if fresh then Reicht.Delivery.LowerSettle() end
if not fresh then
Reicht.Delivery.RaiseSettle()
if not Reicht.Tasks.Teleport(token, CFrame.new(stand)) then return "Aborted" end
end
if not Reicht.Delivery.WaitLanded(token, drop) then return "Aborted" end
local got, why = Reicht.Delivery.Pickup(token, drop.guid, stand)
if not got then return why == "gone" and "Gone" or "Aborted" end
if fresh or Reicht.Delivery.Fits(Reicht.Geo.Trip(bp, stand), drop.weight, eggName) then
if not Reicht.Delivery.StepHome(token, bp) then return "Aborted" end
return Reicht.Delivery.AwaitDeposit(token, cfg.DepositTimeout) and "Deposited" or "Aborted"
end
end
return "Aborted"
end
function Reicht.Delivery.DirectHome(token, bp)
local cfg = Reicht.Config
if not Reicht.Delivery.StepHome(token, bp) then return "Aborted" end
if Reicht.Delivery.AwaitDeposit(token, cfg.DepositTimeout) then return "Deposited" end
if Reicht.Player:BasketCount() > 0 and Reicht.Player:Flags() <= token.flags0 then
if Reicht.Delivery.AwaitDeposit(token, cfg.DepositTimeout) then return "Deposited" end
end
return "Aborted"
end
function Reicht.Delivery.Run(token, entry)
local _, bp = Reicht.Player:Plot()
if not bp or not entry then return "Aborted", 0 end
local t0 = os.clock()
token.flags0 = Reicht.Player:Flags()
token.budget = t0 + Reicht.Config.RunBudget
local mode, trip = Reicht.Delivery.Mode(entry)
Reicht.Delivery.LastPlan = { mode = mode, trip = math.floor(trip), speed = Reicht.Mount.Speed(), settle = Reicht.State.Tune.DirectFactor }
local stand = mode == "Plot" and Reicht.Geo.EdgeInside(bp, entry.pos) or Reicht.Geo.StandPoint(bp, entry.pos)
Reicht.EggIndex.Expect("*carry")
local got, why = Reicht.Delivery.Pickup(token, entry.guid, stand)
if not got then
if why == "full" then Reicht.Delivery.Recover(token) end
return why == "gone" and "Gone" or (why == "refused" and "Refused" or "Aborted"), os.clock() - t0
end
Reicht.Eggs.CarryCritical = true
local outcome
if mode == "Plot" then
outcome = Reicht.Delivery.AwaitDeposit(token, Reicht.Config.DepositTimeout) and "Deposited" or "Aborted"
elseif mode == "Direct" then
outcome = Reicht.Delivery.DirectHome(token, bp)
else
outcome = Reicht.Delivery.DropCycle(token, bp, entry.egg, entry.origin or entry.pos)
end
if outcome ~= "Deposited" and Reicht.Player:BasketCount() > 0 then Reicht.Delivery.Recover(token) end
Reicht.Eggs.CarryCritical = false
Reicht.Guard.Check(token.flags0)
local seconds = os.clock() - t0
local stats = Reicht.State.Stats
if outcome == "Deposited" then
local key = string.lower(mode)
stats[key] = (stats[key] or 0) + 1
end
stats.lastRun, stats.lastMode = seconds, mode
return outcome, seconds
end
function Reicht.Delivery.Carried()
local items = Reicht.Player:BasketItems()
local first = items[1]
if not first then return nil, nil end
if first:GetAttribute("Delivering") == true then return first:GetAttribute("Egg"), "Delivering" end
if first:GetAttribute("BreakAt") then return first:GetAttribute("Egg"), "Carry" end
return first:GetAttribute("Egg"), "Unknown"
end
function Reicht.Delivery.Reenter(token, bp, hrp)
local cfg = Reicht.Config
local out = Reicht.Geo.Outside(bp, hrp.Position, cfg.DropOutside)
if not Reicht.Tasks.Teleport(token, CFrame.new(out)) then return false end
if not Reicht.Delivery.Sleep(token, cfg.TpSettle) then return false end
if not Reicht.Delivery.StepHome(token, bp) then return false end
return Reicht.Delivery.AwaitDeposit(token, cfg.DepositTimeout)
end
function Reicht.Delivery.Recover(token)
local eggName, phase = Reicht.Delivery.Carried()
if not phase then return true, "Empty" end
local cfg = Reicht.Config
token.flags0 = token.flags0 or Reicht.Player:Flags()
token.budget = math.max(token.budget or 0, os.clock() + cfg.RunBudget)
if phase ~= "Carry" then
Reicht.Tasks.Await(token, function() return Reicht.Player:BasketCount() == 0 end, cfg.DepositTimeout)
return Reicht.Player:BasketCount() == 0, "Settled"
end
local _, bp = Reicht.Player:Plot()
local hrp = Reicht.Player.Root
if not bp or not hrp then return false end
local wasCritical = Reicht.Eggs.CarryCritical
Reicht.Eggs.CarryCritical = true
local outcome = "Deposited"
if not (Reicht.Geo.InPlot(hrp.Position) and Reicht.Delivery.Reenter(token, bp, hrp)) then
outcome = Reicht.Delivery.DropCycle(token, bp, eggName, nil)
end
Reicht.Eggs.CarryCritical = wasCritical
return Reicht.Player:BasketCount() == 0, outcome
end
Reicht.Mount = { Name = nil, Dirty = true, AutoLabel = "Auto (fastest)" }
function Reicht.Mount.PetName(inst)
local name = inst:GetAttribute("PetName") or inst.Name
if Reicht.GameLib.PetInfo[name] then return name end
return nil
end
function Reicht.Mount.Moving(name)
local pets = Reicht.GameLib.Data and Reicht.GameLib.Data.Pets
local row = pets and pets[name]
return type(row) == "table" and tonumber(row.MovementSpeed) or 0
end
function Reicht.Mount.Tools()
return Reicht.Pets.ToolsByName()
end
function Reicht.Mount.Detect()
local hrp = Reicht.Player.Root
local joint = hrp and hrp:FindFirstChild("PetMountJoint")
local part = joint and joint.Part1
local model = part and part:FindFirstAncestorOfClass("Model")
if not model then return nil end
return Reicht.Mount.PetName(model)
end
function Reicht.Mount.Choice()
local opts = Reicht.Options
local pick = opts and opts.RidePet
if type(pick) ~= "string" or pick == "" or pick == Reicht.Mount.AutoLabel then return nil end
return pick
end
function Reicht.Mount.Best()
local info = Reicht.GameLib.PetInfo
local forced = Reicht.Mount.Choice()
if forced then return forced, info[forced] and info[forced].speed or 0 end
local names = {}
for name in pairs(Reicht.Mount.Tools()) do names[#names + 1] = name end
if Reicht.Player:Riding() and Reicht.Mount.Name then table.insert(names, Reicht.Mount.Name) end
local best, bestSpeed, bestMove = nil, 0, 0
for _, name in ipairs(names) do
local speed = info[name] and info[name].speed or 0
local move = Reicht.Mount.Moving(name)
if speed > bestSpeed or (speed == bestSpeed and speed > 0 and move > bestMove) then
best, bestSpeed, bestMove = name, speed, move
end
end
return best, bestSpeed
end
function Reicht.Mount.Speed()
if not Reicht.Player:Riding() then return 0 end
local name = Reicht.Mount.Name or Reicht.Mount.Detect()
if not name then return 0 end
Reicht.Mount.Name = name
local info = Reicht.GameLib.PetInfo[name]
return info and info.speed or 0
end
function Reicht.Mount.TravelSpeed()
local hum = Reicht.Player.Humanoid
local cap = Reicht.Config.UnmountedPlayerSpeed
if Reicht.Player:Riding() then
cap = Reicht.Mount.Speed()
local root = Reicht.Player.Root
local joint = root and root:FindFirstChild("PetMountJoint")
local model = joint and joint.Part1 and joint.Part1:FindFirstAncestorOfClass("Model")
local aging = Reicht.GameLib.Svc.PetAging
if model and aging and type(aging.RealSpeedFor) == "function" then
local mutations = Reicht.GameLib.Mutations
local factor = (mutations[model:GetAttribute("Mutation") or ""] or 1) * (mutations[model:GetAttribute("SpawnMutation") or ""] or 1)
local ok, actual = Reicht.GameLib.Call(aging.RealSpeedFor, cap, model:GetAttribute("Weight"), factor)
if ok and type(actual) == "number" and actual > 0 and actual < math.huge then cap = actual end
end
end
return math.min(cap, hum and hum.WalkSpeed or 0)
end
function Reicht.Mount.Forget()
Reicht.Mount.Name = nil
Reicht.Mount.Dirty = true
end
function Reicht.Mount.Unplace(token, name)
local remote = Reicht.GameLib.Remote("PickupPet")
if not remote then return nil end
for _, pet in ipairs(Reicht.Pets.Owned()) do
if pet.name == name and pet.placed then
remote:FireServer(pet.key)
break
end
end
local tool
Reicht.Tasks.Await(token, function()
tool = Reicht.Pets.ToolNamed(name)
return tool ~= nil
end, Reicht.Config.MountTimeout)
return tool
end
function Reicht.Mount.Dismount(token)
local remote = Reicht.GameLib.Remote("PetDismount")
if not remote then return false end
remote:FireServer()
Reicht.Mount.Name = nil
return (Reicht.Tasks.Await(token, function() return not Reicht.Player:Riding() end, Reicht.Config.MountTimeout))
end
function Reicht.Mount.Ensure(token)
local cfg = Reicht.Config
if Reicht.Player:BasketCount() > 0 or not Reicht.Player:IsAlive() then return false end
local name = Reicht.Mount.Best()
if not name then return false end
if Reicht.Player:Riding() then
if (Reicht.Mount.Name or Reicht.Mount.Detect()) == name then
Reicht.Mount.Name, Reicht.Mount.Dirty = name, false
return true
end
if not Reicht.Mount.Dismount(token) then return false end
end
local tool = Reicht.Pets.ToolNamed(name)
if not tool and Reicht.Mount.Choice() == name then tool = Reicht.Mount.Unplace(token, name) end
local remote = Reicht.GameLib.Remote("Mounting")
local hum = Reicht.Player.Humanoid
if not tool or not remote or not hum then return false end
hum:EquipTool(tool)
for _ = 1, cfg.MountTries do
remote:FireServer()
local ok, why = Reicht.Tasks.Await(token, function() return Reicht.Player:Riding() end, cfg.MountGap)
if ok then break end
if why ~= "timeout" then return false end
end
Reicht.Tasks.Await(token, function() return Reicht.Player:Riding() end, cfg.MountTimeout)
if not Reicht.Player:Riding() then return false end
Reicht.Mount.Name, Reicht.Mount.Dirty = name, false
return true
end
function Reicht.Mount.Watch(backpack)
if not backpack then return end
Reicht:Connect(backpack.ChildAdded, function(child)
if child:IsA("Tool") and Reicht.Mount.PetName(child) then Reicht.Mount.Dirty = true end
end)
end
task.spawn(function()
Reicht.Mount.Watch(LocalPlayer:WaitForChild("Backpack", Reicht.Config.LoadTimeout))
end)
Reicht:Connect(LocalPlayer.CharacterAdded, function()
task.defer(function()
Reicht.Mount.Watch(LocalPlayer:WaitForChild("Backpack", Reicht.Config.LoadTimeout))
end)
end)
Reicht.Planner = {
Ranked = {}, Contested = {},
Dirty = true, BuiltAt = 0, Epoch = -1, MountName = nil,
RebuildGap = 0.5, MaxAge = 2, ContestStep = 0.25,
Started = false,
}
function Reicht.Planner.PlayerSpeed(player, char)
if player:GetAttribute("IsRiding") ~= true then return Config.UnmountedPlayerSpeed end
for _, child in ipairs(char:GetChildren()) do
local pet = GameLib.PetInfo[child.Name]
if pet and pet.speed then return pet.speed end
end
return Config.UnmountedPlayerSpeed
end
function Reicht.Planner.Riders()
local riders = {}
for _, player in ipairs(Players:GetPlayers()) do
if player == LocalPlayer then continue end
local char = player.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not hrp then continue end
riders[#riders + 1] = { hrp.Position, Reicht.Planner.PlayerSpeed(player, char) }
end
return riders
end
function Reicht.Planner.Contest(entry, riders)
if not entry.pos then return 0 end
local best = 0
for _, rider in ipairs(riders or Reicht.Planner.Riders()) do
local eta = Reicht.Util.Flat(rider[1], entry.pos) / math.max(rider[2], 1)
best = math.max(best, math.clamp(1 - eta / Config.ContestHorizon, 0, 1))
end
return best
end
function Reicht.Planner.Score(entry, riders)
local mode, trip = Reicht.Delivery.Mode(entry)
local contest = Reicht.Planner.Contest(entry, riders)
local cost = Config.TripCost[mode] or Config.TripCost.Drop
if mode == "Drop" then
local hum = Reicht.Player.Humanoid
local speed = math.min(math.max(Reicht.Mount.Speed(), Config.UnmountedPlayerSpeed), hum and hum.WalkSpeed or 0) * 0.9
cost += trip / math.max(speed, 1)
end
local score = (entry.value or 0) * (1 + contest * State.Tune.ContestWeight) / cost
return score, mode, contest
end
function Reicht.Planner.Rebuild()
local planner = Reicht.Planner
local riders = planner.Riders()
local ranked = planner.Ranked
table.clear(ranked)
for _, entry in pairs(Reicht.EggIndex.Entries) do
if not entry.pos or not entry.egg then continue end
if entry.privateTo and entry.privateTo ~= LocalPlayer.UserId then continue end
local score, mode, contest = planner.Score(entry, riders)
table.insert(ranked, { entry, mode, contest, score })
end
table.sort(ranked, function(a, b) return a[4] > b[4] end)
planner.Dirty, planner.BuiltAt = false, os.clock()
planner.Epoch = Reicht.EggIndex.ValueEpoch
planner.MountName = Reicht.Mount.Name
end
function Reicht.Planner.Stale()
local planner = Reicht.Planner
local age = os.clock() - planner.BuiltAt
if planner.Epoch ~= Reicht.EggIndex.ValueEpoch or planner.MountName ~= Reicht.Mount.Name then return true end
if age > planner.MaxAge then return true end
if not planner.Dirty then return false end
local surging = os.clock() - Reicht.EggIndex.RolledAt <= Config.WaveSurge
return surging or age >= planner.RebuildGap
end
function Reicht.Planner.Next(minRank)
local planner = Reicht.Planner
if planner.Stale() then planner.Rebuild() end
for _, pick in ipairs(planner.Ranked) do
local entry = pick[1]
if not minRank and Reicht.Util.Opt("EggRoute") == "Fast nearby" and pick[2] == "Drop" then continue end
if minRank then
local info = GameLib.EggInfo[entry.egg]
if not info or (GameLib.RarityRank[info.rarity] or 0) < minRank then continue end
end
if Reicht.EggIndex.Wanted(entry, minRank ~= nil) then
planner.Contested[entry.guid] = pick[3]
return entry, pick[2]
end
end
return nil
end
function Reicht.Planner.OnReply(kind, guid)
local planner = Reicht.Planner
if kind ~= "Gone" or not guid then return end
local contest = planner.Contested[guid]
planner.Contested[guid] = nil
if not contest or contest <= 0 then return end
local tune = State.Tune
local before = tune.ContestWeight
tune.ContestWeight = math.min(Config.ContestWeightMax, before + planner.ContestStep)
if tune.ContestWeight == before then return end
State.TuneLog = State.TuneLog or {}
table.insert(State.TuneLog, { "ContestWeight", before, tune.ContestWeight, os.time() })
end
function Reicht.Planner.MarkDirty()
Reicht.Planner.Dirty = true
end
function Reicht.Planner.Start()
local planner = Reicht.Planner
if planner.Started then return end
planner.Started = true
local index = Reicht.EggIndex
index.OnAdded:Connect(Reicht.Planner.MarkDirty)
index.OnRemoved:Connect(Reicht.Planner.MarkDirty)
index.OnRoll:Connect(function()
table.clear(planner.Contested)
planner.Dirty = true
end)
index.OnReply:Connect(Reicht.Planner.OnReply)
end
Reicht.Eggs = {
Enabled = false, Manual = false, Phase = "Idle", Note = nil,
Token = nil, CarryCritical = false,
MountRetryAt = 0, RecoverAt = 0,
Prio = { Eggs = 60, Hunter = 70, Recover = 100 },
RateWindow = 60,
}
Reicht.Hunter = { Enabled = false, Hops = 0, HopCycle = nil, HopAt = 0, Seen = {}, Started = false }
Reicht.Guard = {
Baseline = nil, Tripped = false, Watching = false,
Toggles = { "AutoEggs", "EggHunter", "VolcanoDip", "VolcanoObby" },
}
function Reicht.Eggs.PerMinute()
local window = State.Stats.window
local cutoff = os.clock() - Reicht.Eggs.RateWindow
while window[1] and window[1] < cutoff do
table.remove(window, 1)
end
return #window
end
function Reicht.Eggs.Status()
local eggs = Reicht.Eggs
if not eggs.Enabled and not eggs.Manual and not Reicht.Hunter.Enabled then return "Egg farm is off" end
return eggs.Note or eggs.Phase or "Idle"
end
function Reicht.Eggs.SetPhase(phase, note)
local eggs = Reicht.Eggs
eggs.Phase, eggs.Note = phase, note
State.Status.Eggs = eggs.Status()
if not eggs.Enabled and not eggs.Manual and not Reicht.Hunter.Enabled then
State.Status.EggRate, State.Status.WaveAt = nil, nil
return false
end
State.Status.EggRate = eggs.PerMinute() .. "/min"
State.Status.WaveAt = os.clock() + GameLib.CycleLeft()
return false
end
function Reicht.Eggs.Waiting()
local eggs = Reicht.Eggs
local active = eggs.Enabled or eggs.Manual or Reicht.Hunter.Enabled
return not active or eggs.Phase == "WaveWait"
end
function Reicht.Eggs.ReleaseToken()
local eggs = Reicht.Eggs
if not eggs.Token then return end
Reicht.Tasks.Release(eggs.Token)
eggs.Token = nil
end
function Reicht.Eggs.Claim(prio)
local eggs = Reicht.Eggs
local token = eggs.Token
if token and token.prio == prio and Reicht.Tasks.Holds(token) then return true end
eggs.ReleaseToken()
local owner = prio >= eggs.Prio.Hunter and "Hunter" or "Eggs"
eggs.Token = Reicht.Tasks.Request(owner, prio)
return eggs.Token ~= nil
end
function Reicht.Eggs.EnsureMount()
local eggs, mount = Reicht.Eggs, Reicht.Mount
if os.clock() < eggs.MountRetryAt then return end
if Reicht.Player:Riding() and not mount.Dirty and mount.Best() == mount.Name then return end
eggs.SetPhase("Mount", "Mounting")
local ok, mounted = Reicht.Util.Try("Mount.Ensure", mount.Ensure, eggs.Token)
if ok and mounted then
mount.Dirty = false
return
end
eggs.MountRetryAt = os.clock() + Config.FailWindow
end
function Reicht.Eggs.Recover()
local eggs = Reicht.Eggs
if eggs.CarryCritical or os.clock() < eggs.RecoverAt then return false end
eggs.RecoverAt = os.clock() + Config.SlowTick
eggs.ReleaseToken()
local token = Reicht.Tasks.Request("Recover", eggs.Prio.Recover)
if not token then return eggs.SetPhase("Recover", "Waiting to finish the egg") end
eggs.SetPhase("Recover", "Finishing the egg")
Reicht.Util.Try("Delivery.Recover", Reicht.Delivery.Recover, token)
Reicht.Tasks.Release(token)
return Reicht.Player:BasketCount() == 0
end
function Reicht.Eggs.Park()
if not Reicht.Options.ReturnAfter then return end
local _, bp = Reicht.Player:Plot()
local hrp = Reicht.Player.Root
if not bp or not hrp or Reicht.Geo.InPlot(hrp.Position) then return end
local token = Reicht.Tasks.Request("Eggs", Reicht.Eggs.Prio.Eggs)
if not token then return end
Reicht.Tasks.Teleport(token, CFrame.new(Reicht.Geo.EdgeInside(bp, hrp.Position)))
Reicht.Tasks.Release(token)
end
function Reicht.Eggs.WaveWait()
local eggs = Reicht.Eggs
if eggs.Phase ~= "WaveWait" then
eggs.ReleaseToken()
eggs.Park()
end
local left = GameLib.CycleLeft()
return eggs.SetPhase("WaveWait", left <= Config.WaveWakeEarly and "New wave" or nil)
end
function Reicht.Eggs.Record(entry, outcome)
local stats = State.Stats
if outcome == "Gone" then
stats.lost += 1
return
end
if outcome == "Refused" then
Reicht.EggIndex.Fail(entry.guid)
return
end
if outcome ~= "Deposited" then return end
stats.delivered += 1
table.insert(stats.window, os.clock())
local info = GameLib.EggInfo[entry.egg]
if info and info.ethereal then Reicht.EggIndex.MarkClaimed(entry.egg, entry.cycle) end
end
function Reicht.Eggs.Trip(entry)
local eggs = Reicht.Eggs
eggs.SetPhase("Run", entry.egg)
local ok, outcome = Reicht.Util.Try("Delivery.Run", Reicht.Delivery.Run, eggs.Token, entry)
eggs.CarryCritical = false
if not ok then outcome = "Aborted" end
eggs.Record(entry, outcome)
Reicht.Planner.Dirty = true
eggs.SetPhase("Settle")
task.wait(Config.EggTick)
return outcome == "Deposited"
end
function Reicht.Eggs.Tick(minRank)
local eggs = Reicht.Eggs
if eggs.Ticking then return end
eggs.Ticking = true
local ok, err = pcall(eggs.TickOnce, minRank)
eggs.Ticking = false
if not ok then
eggs.CarryCritical = false
eggs.ReleaseToken()
error(err, 0)
end
end
function Reicht.Eggs.TickOnce(minRank)
local eggs = Reicht.Eggs
if Reicht.Halloween.InZone() == true then
eggs.ReleaseToken()
return eggs.SetPhase("Idle", "Leave the Halloween island to farm world eggs")
end
Reicht.EggIndex.CheckRoll()
local _, bp = Reicht.Player:Plot()
if not bp then return eggs.SetPhase("Idle", "Waiting for plot") end
if not Reicht.Player:IsAlive() then return eggs.SetPhase("Idle", "Waiting for respawn") end
if Reicht.Player:BasketCount() > 0 then return eggs.Recover() end
if eggs.Token and not Reicht.Tasks.Holds(eggs.Token) then eggs.ReleaseToken() end
if Reicht.Volcano.Pending() then
eggs.ReleaseToken()
return eggs.SetPhase("Pick", "Volcano dip")
end
local entry = Reicht.Planner.Next(minRank)
if not entry then return eggs.WaveWait() end
if not eggs.Claim(Reicht.Hunter.Priority(entry)) then return eggs.SetPhase("Pick", "Waiting for a turn") end
eggs.EnsureMount()
return eggs.Trip(entry)
end
function Reicht.Eggs.Step()
if not Reicht.Eggs.Enabled or Reicht.Guard.Tripped then return end
Reicht.Eggs.Tick(nil)
end
function Reicht.Eggs.Prepare()
Reicht.Guard.Arm()
Reicht.Planner.Start()
return Reicht.EggIndex.Start()
end
function Reicht.Eggs.QuietInventory(quiet, force)
local eggs = Reicht.Eggs
if quiet then
if eggs.InventoryPaused then return end
eggs.InventoryPaused = true
eggs.InventoryWas = LocalPlayer:GetAttribute("SatchelEnabled")
LocalPlayer:SetAttribute("SatchelEnabled", false)
return
end
if not eggs.InventoryPaused then return end
if not force and (eggs.Enabled or Reicht.Hunter.Enabled or Reicht.Util.Opt("ClearJunk")) then return end
eggs.InventoryPaused = false
LocalPlayer:SetAttribute("SatchelEnabled", eggs.InventoryWas)
end
function Reicht.Eggs.Start()
local eggs = Reicht.Eggs
eggs.QuietInventory(true)
if State.LastFail then State.Tune.DirectFactor = math.min(State.Tune.DirectFactor, Config.DirectFactorAfterFail) end
eggs.Prepare()
eggs.Enabled, eggs.MountRetryAt = true, 0
eggs.SetPhase("Idle")
end
function Reicht.Eggs.Stop()
local eggs = Reicht.Eggs
eggs.Enabled = false
if Reicht.Hunter.Enabled then return end
if eggs.InFlight() then
task.spawn(Reicht.Eggs.FinishCarry, Config.RunBudget * 2)
return
end
eggs.ReleaseToken()
eggs.SetPhase("Idle")
task.spawn(Reicht.Eggs.Settle)
end
function Reicht.Eggs.Settle()
local eggs = Reicht.Eggs
eggs.SettlePending = true
if not eggs.LetGo() then return false end
eggs.SettlePending = false
eggs.QuietInventory(false)
return true
end
function Reicht.Eggs.SettleStep()
local eggs = Reicht.Eggs
if not eggs.SettlePending then return end
if eggs.Enabled or eggs.Manual or Reicht.Hunter.Enabled or Reicht.Util.Opt("ClearJunk") then
eggs.SettlePending = false
return
end
eggs.Settle()
end
function Reicht.Eggs.InFlight()
local eggs = Reicht.Eggs
return eggs.Phase == "Run" or eggs.CarryCritical or Reicht.Player:BasketCount() > 0
end
function Reicht.Eggs.FinishCarry(timeout)
local eggs = Reicht.Eggs
local deadline = os.clock() + (timeout or Config.RunBudget)
while (eggs.CarryCritical or eggs.Phase == "Run") and os.clock() < deadline do
task.wait(Config.EggTick)
end
if Reicht.Player:BasketCount() > 0 then
eggs.RecoverAt = 0
eggs.Recover()
end
eggs.ReleaseToken()
if not eggs.Enabled and not Reicht.Hunter.Enabled then eggs.Settle() end
return Reicht.Player:BasketCount() == 0
end
function Reicht.Eggs.LetGo()
if Reicht.Tasks.Owner() or Reicht.Player:BasketCount() > 0 then return false end
return Reicht.Player:Release()
end
function Reicht.Eggs.ExitNow()
local eggs = Reicht.Eggs
eggs.Enabled = false
table.insert(State.PendingToggleOff, "AutoEggs")
eggs.FinishCarry(Config.RunBudget)
eggs.SetPhase("Idle", "Stopped")
end
function Reicht.Eggs.CollectNow()
local eggs = Reicht.Eggs
if eggs.Enabled or eggs.Manual or Reicht.Hunter.Enabled then return 0 end
if not eggs.Prepare() then return 0 end
eggs.Manual = true
local before = State.Stats.delivered
local limit = 0
for _ in pairs(Reicht.EggIndex.Entries) do limit += 1 end
for _ = 1, limit do
if Reicht.Guard.Tripped or not State.Alive then break end
eggs.Tick(nil)
if eggs.Phase == "WaveWait" or eggs.Phase == "Idle" or eggs.Phase == "Pick" then break end
end
eggs.ReleaseToken()
eggs.Manual = false
eggs.Settle()
local got = State.Stats.delivered - before
table.insert(State.PendingNotify, { "Collect Eggs", "Delivered " .. got .. " eggs" })
return got
end
function Reicht.Hunter.MinRank()
return GameLib.RarityRank[Reicht.Options.HuntMinRarity] or math.huge
end
function Reicht.Hunter.Priority(entry)
local prio = Reicht.Eggs.Prio
if not Reicht.Hunter.Enabled then return prio.Eggs end
local info = GameLib.EggInfo[entry.egg]
local rank = info and GameLib.RarityRank[info.rarity] or 0
return rank >= Reicht.Hunter.MinRank() and prio.Hunter or prio.Eggs
end
function Reicht.Hunter.Spotted(entry)
local hunter = Reicht.Hunter
if not hunter.Enabled or not entry.egg or hunter.Seen[entry.guid] then return end
if entry.privateTo and entry.privateTo ~= LocalPlayer.UserId then return end
local info = GameLib.EggInfo[entry.egg]
if not info or info.volcanic then return end
if (GameLib.RarityRank[info.rarity] or 0) < hunter.MinRank() then return end
hunter.Seen[entry.guid] = true
table.insert(State.PendingNotify, { "Rare Egg", entry.egg .. " (" .. tostring(info.rarity) .. ") spawned" })
local webhook = Reicht.Webhook
if webhook and webhook.EggSpawned and entry.inst then task.defer(webhook.EggSpawned, entry.inst) end
end
function Reicht.Hunter.TryHop()
local hunter = Reicht.Hunter
if not Reicht.Options.HunterHop or os.clock() < hunter.HopAt then return end
if GameLib.CycleLeft() <= Config.HunterMinLeft or Reicht.Player:BasketCount() > 0 then return end
local cycle = GameLib.CycleIndex()
if hunter.HopCycle ~= cycle then hunter.HopCycle, hunter.Hops = cycle, 0 end
if hunter.Hops >= Config.HunterHopsPerCycle then return end
if Reicht.Planner.Next(hunter.MinRank()) then return end
hunter.Hops += 1
hunter.HopAt = os.clock() + Config.LoadTimeout
Reicht.Util.Try("Server.Hop", Reicht.Server.Hop)
end
function Reicht.Hunter.Step()
local hunter, eggs = Reicht.Hunter, Reicht.Eggs
if not hunter.Enabled or eggs.Manual or Reicht.Guard.Tripped then return end
if not eggs.Enabled then eggs.Tick(hunter.MinRank()) end
if eggs.Phase == "WaveWait" then hunter.TryHop() end
end
function Reicht.Hunter.Start()
local hunter = Reicht.Hunter
if State.LastFail then State.Tune.DirectFactor = math.min(State.Tune.DirectFactor, Config.DirectFactorAfterFail) end
Reicht.Eggs.Prepare()
Reicht.Eggs.QuietInventory(true)
hunter.Enabled = true
if hunter.Started then return end
hunter.Started = true
Reicht.EggIndex.OnAdded:Connect(Reicht.Hunter.Spotted)
Reicht.EggIndex.OnRoll:Connect(function() table.clear(hunter.Seen) end)
end
function Reicht.Hunter.Stop()
Reicht.Hunter.Enabled = false
if Reicht.Eggs.Enabled then return end
if Reicht.Eggs.InFlight() then
task.spawn(Reicht.Eggs.FinishCarry, Config.RunBudget * 2)
return
end
Reicht.Eggs.ReleaseToken()
Reicht.Eggs.SetPhase("Idle")
task.spawn(Reicht.Eggs.Settle)
end
function Reicht.Guard.Arm()
local guard = Reicht.Guard
guard.Tripped = false
guard.Baseline = Reicht.Player:Flags()
if guard.Watching then return end
guard.Watching = true
Reicht:Connect(LocalPlayer:GetAttributeChangedSignal("TeleportFlags"), Reicht.Guard.OnFlags)
end
function Reicht.Guard.OnFlags()
local guard = Reicht.Guard
local flags = Reicht.Player:Flags()
if guard.Baseline and flags > guard.Baseline then guard.Trip("flags") end
guard.Baseline = flags
end
function Reicht.Guard.Check(flags0)
if Reicht.Player:Flags() > (flags0 or 0) then Reicht.Guard.Trip("flags") end
end
function Reicht.Guard.Snapshot(why)
local plan = type(Reicht.Delivery.LastPlan) == "table" and Reicht.Delivery.LastPlan or {}
return {
why = why, at = os.time(),
mode = plan.mode, trip = plan.trip, speed = plan.speed, settle = plan.settle, timings = plan.timings,
flagsBefore = Reicht.Guard.Baseline, flagsAfter = Reicht.Player:Flags(),
}
end
function Reicht.Guard.Soften()
local guard = Reicht.Guard
local now = os.clock()
guard.Recent = guard.Recent or {}
while guard.Recent[1] and now - guard.Recent[1] > Config.ReturnWindow do
table.remove(guard.Recent, 1)
end
guard.Recent[#guard.Recent + 1] = now
if #guard.Recent >= Config.ReturnStopCount then return false end
local pace = Config.ReturnBackoff[#guard.Recent] or Config.ReturnBackoff[#Config.ReturnBackoff]
State.Tune.DirectFactor = math.min(State.Tune.DirectFactor, pace)
table.insert(State.PendingNotify, { "Egg Farm", "An egg was returned. Delivering slower and carrying on." })
return true
end
function Reicht.Guard.Trip(why)
local guard = Reicht.Guard
if guard.Tripped or os.clock() - (guard.LastTrip or -math.huge) < Config.ReturnDedupe then return end
guard.LastTrip = os.clock()
State.Stats.returned += 1
State.LastFail = guard.Snapshot(why)
local webhook = Reicht.Webhook
if webhook and webhook.DeliveryFailed then task.defer(webhook.DeliveryFailed, State.LastFail) end
if guard.Soften() then return end
guard.Tripped = true
Reicht.Eggs.Enabled = false
Reicht.Hunter.Enabled = false
local volcano = Reicht.Volcano
if volcano and volcano.Stop then Reicht.Util.Try("Volcano.Stop", volcano.Stop) end
for _, idx in ipairs(guard.Toggles) do
table.insert(State.PendingToggleOff, idx)
end
table.insert(State.PendingNotify, { "Egg Farm", "Eggs keep getting returned. Egg farming stopped, switch Delivery to Safe and turn it back on." })
end
Reicht.Volcano = {
Token = nil,
Reply = nil,
Bound = false,
Skip = {},
ObbyAfter = 0,
Dipped = 0,
Magma = 0,
}
local function Never() return false end
function Reicht.Volcano.Options()
return Reicht.Options or {}
end
function Reicht.Volcano.SetStatus(text)
Reicht.State.Status.Volcano = text
end
function Reicht.Volcano.Sleep(token, sec)
local _, why = Reicht.Tasks.Await(token, Never, sec)
return why == "timeout"
end
local function IsOurs(owner)
return owner == LocalPlayer or owner == LocalPlayer.UserId
end
function Reicht.Volcano.Bind()
if Reicht.Volcano.Bound then return end
Reicht.Volcano.Bound = true
local result = Reicht.GameLib.Remote("VolcanoDipResult")
if result then
Reicht:Connect(result.OnClientEvent, function(reply)
if type(reply) ~= "table" or not IsOurs(reply.Owner) then return end
Reicht.Volcano.Reply = reply
end)
end
local cancelled = Reicht.GameLib.Remote("VolcanoDipCancelled")
if cancelled then
Reicht:Connect(cancelled.OnClientEvent, function(reply)
if type(reply) == "table" and not IsOurs(reply.Owner) then return end
Reicht.Volcano.Reply = { Cancelled = true }
end)
end
end
function Reicht.Volcano.Stream(token)
if Reicht.Volcano.Part("VolcanoTop") then return true end
local ok, err = pcall(LocalPlayer.RequestStreamAroundAsync, LocalPlayer, Reicht.Config.VolcanoCenter, Reicht.Config.VolcanoStreamTimeout)
if not ok then warn("[RideAPet] volcano stream:", err) end
return Reicht.Tasks.Await(token, function() return Reicht.Volcano.Part("VolcanoTop") ~= nil end, Reicht.Config.VolcanoStreamTimeout) == true
end
function Reicht.Volcano.Part(name)
local volcano = workspace:FindFirstChild("Volcano")
local part = volcano and volcano:FindFirstChild(name, true)
if part and part:IsA("BasePart") then return part end
for _, tagged in ipairs(game:GetService("CollectionService"):GetTagged(name)) do
if tagged:IsA("BasePart") then return tagged end
end
return nil
end
function Reicht.Volcano.IsOver(top)
local hrp = Reicht.Player.Root
local info = Reicht.GameLib.Data.Volcano
if not hrp or not top or not info then return false end
local slack = tonumber(info.ServerRangeSlack) or 0
local localPos = top.CFrame:PointToObjectSpace(hrp.Position)
if localPos.Y < 0 then return false end
return math.abs(localPos.X) <= top.Size.X / 2 + slack and math.abs(localPos.Z) <= top.Size.Z / 2 + slack
end
local function SkipsDip(entry, info)
if not info or info.ethereal or info.volcanic then return true end
return entry.mutation == "Magma" or entry.mutation == "Eternal"
end
function Reicht.Volcano.MinimumBreak()
local speed = Reicht.Mount.TravelSpeed()
if speed <= 0 then local _, bestSpeed = Reicht.Mount.Best(); speed = bestSpeed end
speed = math.max(speed, Reicht.Config.UnmountedPlayerSpeed)
local _, bp = Reicht.Player:Plot()
local returning = bp and math.max(0, (Reicht.Config.VolcanoCenter - bp.Position).Magnitude - Reicht.Config.ReturnHopMax) / speed or math.huge
return returning + Reicht.Config.VolcanoMinBreakLeft
end
function Reicht.Volcano.WaveTail()
if Reicht.Eggs.Waiting() then return true end
local free = 0
for _, entry in pairs(Reicht.EggIndex.Entries) do
if Reicht.EggIndex.Wanted(entry) and Reicht.Planner.Contest(entry) == 0 then free += 1 end
if free > Reicht.Config.VolcanoTailEggs then return false end
end
return true
end
function Reicht.Volcano.PickDip()
local rarities = Reicht.Volcano.Options().DipRarities or {}
local minBreak = Reicht.Volcano.MinimumBreak()
local best, bestScore = nil, -math.huge
for guid, entry in pairs(Reicht.EggIndex.Entries) do
local egg = Reicht.GameLib.EggInfo[entry.egg]
if SkipsDip(entry, egg) or (Reicht.Volcano.Skip[guid] or 0) > os.clock() then continue end
if next(rarities) and not rarities[egg.rarity] then continue end
if (egg.breakSec or 0) <= minBreak or not Reicht.EggIndex.Wanted(entry) then continue end
if Reicht.Delivery.Mode(entry) == "Plot" then continue end
local score = Reicht.Planner.Score(entry)
if score > bestScore then best, bestScore = entry, score end
end
return best
end
function Reicht.Volcano.Carried()
local now = Reicht.Util.ServerNow()
local minBreak = (tonumber(Reicht.GameLib.Data.Volcano.BonusSeconds) or math.huge) + Reicht.Config.VolcanoMinBreakLeft
for _, egg in ipairs(Reicht.Player:BasketItems()) do
if egg:GetAttribute("VolcanoDipped") or egg:GetAttribute("Delivering") then continue end
if (tonumber(egg:GetAttribute("VolcanoUntil")) or 0) > now then continue end
local breakAt = tonumber(egg:GetAttribute("BreakAt"))
if breakAt and breakAt - now > minBreak then return egg end
end
return nil
end
function Reicht.Volcano.FireUntilReply(token, remote)
Reicht.Volcano.Reply = nil
local deadline = os.clock() + Reicht.Config.VolcanoResultTimeout
repeat
remote:FireServer()
if Reicht.Tasks.Await(token, function() return Reicht.Volcano.Reply ~= nil end, Reicht.Config.VolcanoRefire) then
return Reicht.Volcano.Reply
end
if not Reicht.Tasks.Holds(token) then return nil end
until os.clock() >= deadline
return nil
end
function Reicht.Volcano.Dip(token)
local remote = Reicht.GameLib.Remote("VolcanoDip")
local info = Reicht.GameLib.Data.Volcano
if not remote or not info or not Reicht.Volcano.Carried() then return false end
if not Reicht.Volcano.Stream(token) then return false end
local top = Reicht.Volcano.Part("VolcanoTop")
if not top then return false end
Reicht.Tasks.Teleport(token, CFrame.new(top.Position + Vector3.yAxis * (tonumber(info.HoverHeight) or 0)))
if not Reicht.Volcano.Sleep(token, Reicht.Config.VolcanoDipSettle) then return false end
if not Reicht.Volcano.IsOver(top) then return false end
Reicht.Volcano.SetStatus("Dipping egg")
local reply = Reicht.Volcano.FireUntilReply(token, remote)
if not reply or reply.Cancelled then return false end
local landAt = tonumber(reply.ArriveAt) or 0
local arrived = Reicht.Tasks.Await(token, function()
return (Reicht.Volcano.Reply and Reicht.Volcano.Reply.Cancelled) or Reicht.Util.ServerNow() >= landAt
end, Reicht.Config.VolcanoResultTimeout)
if not arrived or (Reicht.Volcano.Reply and Reicht.Volcano.Reply.Cancelled) then return false end
Reicht.Volcano.Dipped += 1
if reply.Success then Reicht.Volcano.Magma += 1 end
return true
end
function Reicht.Volcano.DipRun(token, entry)
local _, bp = Reicht.Player:Plot()
if not bp then return "no plot" end
if not Reicht.Mount.Ensure(token) then return "A fast ride pet is needed for the return" end
local ok, why = Reicht.Delivery.Pickup(token, entry.guid, Reicht.Geo.StandPoint(bp, entry.pos))
if not ok then
Reicht.Volcano.Skip[entry.guid] = os.clock() + Reicht.Config.GoneBlacklistSec
return "pickup " .. tostring(why)
end
Reicht.Eggs.CarryCritical = true
local dipped = Reicht.Volcano.Dip(token)
Reicht.Volcano.SetStatus("Returning the dipped egg")
local _, outcome = Reicht.Delivery.Recover(token)
Reicht.Eggs.CarryCritical = false
if outcome ~= "Deposited" then return "Dip finished; egg delivery not confirmed" end
return dipped and "dipped and delivered" or "dip skipped; egg delivered"
end
function Reicht.Volcano.Hold(token, part, canTouch)
local hrp = Reicht.Player.Root
if not hrp or not part.Parent then return end
hrp.AssemblyLinearVelocity = Vector3.zero
if (hrp.Position - part.Position).Magnitude > part.Size.Magnitude / 2 then Reicht.Tasks.Teleport(token, part.CFrame) end
if not canTouch or os.clock() < (Reicht.Volcano.TouchAt or 0) then return end
Reicht.Volcano.TouchAt = os.clock() + Reicht.Config.VolcanoTouchEvery
firetouchinterest(hrp, part, 0)
task.defer(firetouchinterest, hrp, part, 1)
end
function Reicht.Volcano.Climb(token)
if Reicht.Volcano.Done() then return true end
if not Reicht.Volcano.Stream(token) then return false end
local canTouch = Library and Library.Compat and Library.Compat.Caps.Touch == true
for _, step in ipairs({ { "VolcanoEntrance" }, { "VolcanoValidate", "InVolcano" }, { "VolcanoTop", "VolcanoValidated" } }) do
local part = Reicht.Volcano.Part(step[1])
if not part or not Reicht.Tasks.Teleport(token, part.CFrame) then return false end
if not Reicht.Volcano.Sleep(token, Reicht.Config.VolcanoSettle) then return false end
Reicht.Volcano.Hold(token, part, canTouch)
local attr = step[2]
if attr and not Reicht.Tasks.Await(token, function()
if LocalPlayer:GetAttribute(attr) == true then return true end
Reicht.Volcano.Hold(token, part, canTouch)
return false
end, Reicht.Config.VolcanoStepWait) then
return false
end
end
return Reicht.Volcano.Done()
end
function Reicht.Volcano.Done()
return LocalPlayer:GetAttribute("VolcanoValidated") == true
end
function Reicht.Volcano.VolcanicEgg()
for guid, entry in pairs(Reicht.EggIndex.Entries) do
local info = Reicht.GameLib.EggInfo[entry.egg]
if not info or not info.volcanic then continue end
if entry.privateTo and not IsOurs(entry.privateTo) then continue end
if (Reicht.Volcano.Skip[guid] or 0) > os.clock() then continue end
return entry
end
return nil
end
function Reicht.Volcano.ObbyRun(token, entry)
if not Reicht.Volcano.Climb(token) then
Reicht.Volcano.ObbyAfter = os.clock() + Reicht.Config.VolcanoRetry
return "climb failed"
end
if not Reicht.Mount.Ensure(token) then return "A fast ride pet is needed for the return" end
local stand = entry.pos + Vector3.yAxis * Reicht.Geo.Lift(Reicht.Config.VolcanoStandLift)
local ok, why = Reicht.Delivery.Pickup(token, entry.guid, stand)
if not ok then
Reicht.Volcano.Skip[entry.guid] = os.clock() + Reicht.Config.GoneBlacklistSec
return "pickup " .. tostring(why)
end
Reicht.Eggs.CarryCritical = true
Reicht.Volcano.SetStatus("Returning the volcanic egg")
local _, outcome = Reicht.Delivery.Recover(token)
Reicht.Eggs.CarryCritical = false
return outcome == "Deposited" and "volcanic egg delivered" or "Volcanic egg delivery not confirmed"
end
function Reicht.Volcano.Plan()
local opts = Reicht.Volcano.Options()
if opts.VolcanoObby and os.clock() >= Reicht.Volcano.ObbyAfter then
local egg = Reicht.Volcano.VolcanicEgg()
if egg then return egg, Reicht.Volcano.ObbyRun end
end
if opts.VolcanoDip and Reicht.GameLib.Data.Volcano and Reicht.Volcano.WaveTail() then
local egg = Reicht.Volcano.PickDip()
if egg then return egg, Reicht.Volcano.DipRun end
end
return nil
end
function Reicht.Volcano.Pending()
local hold = Reicht.Volcano.Claimed
if not hold then return false end
if os.clock() < hold[2] and Reicht.EggIndex.Entries[hold[1]] then return true end
Reicht.Volcano.Claimed = nil
return false
end
local function Orphaned()
local eggs = Reicht.Eggs
if Reicht.Player:BasketCount() == 0 or eggs.CarryCritical then return false end
return not (eggs.Enabled or eggs.Manual or Reicht.Hunter.Enabled)
end
function Reicht.Volcano.Step()
if not Reicht.State.Alive or not Reicht.Player:IsAlive() or Reicht.Guard.Tripped then return end
if Reicht.Halloween.InZone() == true then
Reicht.Volcano.SetStatus("Leave the Halloween island to farm the volcano")
return
end
if Orphaned() then
Reicht.Volcano.SetStatus("Finishing the egg")
Reicht.Eggs.Recover()
return
end
if not Reicht.Player:Riding() then
local mountToken = Reicht.Tasks.Request("Volcano", Reicht.Tasks.Prio.Volcano)
if not mountToken then return end
Reicht.Volcano.Token = mountToken
local mounted = Reicht.Mount.Ensure(mountToken)
Reicht.Volcano.Token = nil
Reicht.Tasks.Release(mountToken)
if not mounted then
Reicht.Volcano.SetStatus("A fast ride pet is needed for the return")
return
end
end
Reicht.Volcano.Bind()
local entry, runner = Reicht.Volcano.Plan()
if not entry then
Reicht.Volcano.Claimed = nil
Reicht.Volcano.SetStatus("Waiting")
return
end
Reicht.Volcano.Claimed = { entry.guid, os.clock() + Reicht.Config.VolcanoClaimSec }
if Reicht.Player:BasketCount() > 0 then return end
local token = Reicht.Tasks.Request("Volcano", Reicht.Tasks.Prio.Volcano)
if not token then return end
Reicht.Volcano.Claimed = nil
Reicht.Volcano.Token = token
local flags0 = Reicht.Player:Flags()
local ok, outcome = Reicht.Util.Try("volcano", runner, token, entry)
Reicht.Eggs.CarryCritical = false
Reicht.Guard.Check(flags0)
Reicht.Volcano.Token = nil
Reicht.Tasks.Release(token)
Reicht.Volcano.SetStatus(ok and outcome or "error")
end
function Reicht.Volcano.Start()
Reicht.Eggs.Prepare()
Reicht.Volcano.Bind()
Reicht.Volcano.ObbyAfter = 0
end
function Reicht.Volcano.Stop()
Reicht.Volcano.Claimed = nil
local token = Reicht.Volcano.Token
if token and Reicht.Player:BasketCount() == 0 then
Reicht.Volcano.Token = nil
Reicht.Tasks.Release(token)
end
end
function Reicht.Volcano.Status()
return Reicht.State.Status.Volcano or "Off"
end
Reicht.Hatch = {
Bound = false,
Pending = {},
LastPlaced = 0,
LastRequest = 0,
CapHit = false,
Hatched = 0,
Purchased = {},
Confirmed = {},
Planted = 0,
GrowCache = {},
Signal = Reicht.Signal.new(),
}
local function IsOurs(owner)
return owner == nil or owner == LocalPlayer or owner == LocalPlayer.UserId
end
function Reicht.Hatch.Options()
return Reicht.Options or {}
end
function Reicht.Hatch.SetStatus(text)
Reicht.State.Status.Hatch = text
end
function Reicht.Hatch.Store(placement)
if type(placement) ~= "table" or type(placement.EggKey) ~= "string" then return end
Reicht.State.PlotEggs[placement.EggKey] = {
key = placement.EggKey,
egg = placement.EggName,
placeTime = tonumber(placement.PlaceTime),
weight = tonumber(placement.Weight) or 1,
pos = typeof(placement.UpCFrame) == "CFrame" and placement.UpCFrame.Position or placement.Coordinate,
}
Reicht.Hatch.LastPlaced = os.clock()
end
function Reicht.Hatch.OnPlaced(msg)
if type(msg) ~= "table" or not IsOurs(msg.Owner) then return end
if not msg.Snapshot then
Reicht.Hatch.Store(msg)
return
end
table.clear(Reicht.State.PlotEggs)
for _, placement in pairs(type(msg.Placements) == "table" and msg.Placements or {}) do
Reicht.Hatch.Store(placement)
end
end
function Reicht.Hatch.OnHatched(msg)
if type(msg) ~= "table" or not IsOurs(msg.Owner) or not msg.EggKey then return end
Reicht.State.PlotEggs[msg.EggKey] = nil
Reicht.Hatch.Pending[msg.EggKey] = nil
Reicht.Hatch.Hatched += 1
Reicht.Hatch.Confirmed[msg.EggKey] = os.clock()
Reicht.Hatch.Purchased[msg.EggKey] = nil
Reicht.Hatch.Signal:Fire(msg)
end
function Reicht.Hatch.OnMessage(text)
if type(text) ~= "string" then return end
local used, cap = text:match("Max (%d+)/(%d+)")
if not cap then return end
Reicht.State.PlantCap = math.max(tonumber(used), tonumber(cap))
Reicht.Hatch.CapHit = true
Reicht.Hatch.RequestSnapshot()
end
function Reicht.Hatch.Bind()
if Reicht.Hatch.Bound then return end
Reicht.Hatch.Bound = true
local placed = Reicht.GameLib.Remote("EggPlaced")
if placed then Reicht:Connect(placed.OnClientEvent, Reicht.Hatch.OnPlaced) end
local hatch = Reicht.GameLib.Remote("Hatch")
if hatch then Reicht:Connect(hatch.OnClientEvent, Reicht.Hatch.OnHatched) end
local message = Reicht.GameLib.Remote("GameMessage")
if message then Reicht:Connect(message.OnClientEvent, Reicht.Hatch.OnMessage) end
Reicht.Hatch.RequestSnapshot()
end
function Reicht.Hatch.RequestSnapshot()
local remote = Reicht.GameLib.Remote("RequestPlotEggs")
if not remote then return end
Reicht.Hatch.LastRequest = os.clock()
remote:FireServer(true)
end
function Reicht.Hatch.BoostActive()
local rs = game:GetService("ReplicatedStorage")
local mult = tonumber(rs:GetAttribute("HatchLuckEventMultiplier")) or 1
local untilAt = tonumber(rs:GetAttribute("HatchLuckEventUntil"))
if untilAt and untilAt <= Reicht.Util.ServerNow() then return false end
return mult > 1
end
function Reicht.Hatch.Left(plotEgg)
local info = Reicht.GameLib.EggInfo[plotEgg.egg or ""]
if not info or not plotEgg.placeTime then return nil end
return Reicht.GameLib.GrowthLeft(plotEgg.placeTime, info.growth, plotEgg.weight)
end
function Reicht.Hatch.ReadyAt(plotEgg)
if plotEgg.readyAt then return plotEgg.readyAt end
local info = Reicht.GameLib.EggInfo[plotEgg.egg or ""]
if not info or not plotEgg.placeTime then return nil end
local left = Reicht.GameLib.GrowthRealLeft(plotEgg.placeTime, info.growth, plotEgg.weight)
if not left then return nil end
plotEgg.readyAt = os.clock() + left
return plotEgg.readyAt
end
function Reicht.Hatch.HatchNow(onlyKey)
local remote = Reicht.GameLib.Remote("Hatch")
if not remote then return 0 end
Reicht.Hatch.Bind()
local fired, now = 0, os.clock()
for key, plotEgg in pairs(Reicht.State.PlotEggs) do
if onlyKey and key ~= onlyKey then continue end
if (Reicht.Hatch.Pending[key] or 0) > now then continue end
local left = Reicht.Hatch.Left(plotEgg)
if not left or left > 0 then continue end
if fired > 0 then task.wait(Reicht.Config.HatchGap) end
Reicht.Hatch.Pending[key] = os.clock() + Reicht.Config.HatchPending
remote:FireServer({ EggKey = key })
fired += 1
end
return fired
end
function Reicht.Hatch.Step()
local opts = Reicht.Hatch.Options()
local purchased = opts.HalloweenAutoHatch ~= false and next(Reicht.Hatch.Purchased) ~= nil
if not opts.AutoHatch and not purchased then return end
Reicht.Hatch.Bind()
if os.clock() - Reicht.Hatch.LastRequest > Reicht.Config.PlotEggsRefresh then
Reicht.Hatch.RequestSnapshot()
end
if opts.HoldHatchBoost and not Reicht.Hatch.BoostActive() then
Reicht.Hatch.SetStatus("Holding for luck boost")
return
end
if not opts.AutoHatch then
for key in pairs(Reicht.Hatch.Purchased) do
Reicht.Hatch.HatchNow(key)
end
return
end
local fired = Reicht.Hatch.HatchNow()
if fired > 0 then Reicht.Hatch.SetStatus("Hatching " .. fired) end
end
function Reicht.Hatch.ToolEgg(tool)
local name = tool:GetAttribute("Egg") or tool.Name:match("^(.-Egg)")
return Reicht.GameLib.EggInfo[name or ""] and name or nil
end
function Reicht.Hatch.EggTools()
local tools = {}
for _, holder in ipairs({ LocalPlayer:FindFirstChild("Backpack"), Reicht.Player.Char }) do
if not holder then continue end
for _, tool in ipairs(holder:GetChildren()) do
if not tool:IsA("Tool") or not tool:GetAttribute("EggInventoryId") then continue end
local name = Reicht.Hatch.ToolEgg(tool)
if not name then continue end
table.insert(tools, { tool, name, tonumber(tool:GetAttribute("Weight")) or 1, tool:GetAttribute("Mutation") })
end
end
return tools
end
function Reicht.Hatch.Rank(name, weight, order, mutation)
local info = Reicht.GameLib.EggInfo[name]
local key = name .. "|" .. tostring(weight)
local growth = Reicht.Hatch.GrowCache[key]
if growth == nil then
growth = Reicht.GameLib.GrowthSeconds(info.growth or 1, weight) or info.growth or 1
Reicht.Hatch.GrowCache[key] = growth
end
growth = math.max(growth, 0.001)
if order == "Fastest growth" then return -growth end
local value = Reicht.EggIndex.Value({ egg = name, weight = weight, mutation = mutation })
if order == "Value per hour" then return value / growth end
return value
end
function Reicht.Hatch.Queue()
local opts = Reicht.Hatch.Options()
local order = opts.PlantOrder or "Best value"
local tools = Reicht.Hatch.EggTools()
for _, entry in ipairs(tools) do
entry[5] = Reicht.Hatch.Rank(entry[2], entry[3], order, entry[4])
end
local function Better(a, b) return a[5] > b[5] end
table.sort(tools, Better)
local keep = tonumber(opts.PlantKeep) or 0
if keep <= 0 then return tools end
local seen, queue = {}, {}
for i = #tools, 1, -1 do
local name = tools[i][2]
seen[name] = (seen[name] or 0) + 1
if seen[name] > keep then queue[#queue + 1] = tools[i] end
end
table.sort(queue, Better)
return queue
end
function Reicht.Hatch.Count()
local count = 0
for _ in pairs(Reicht.State.PlotEggs) do count += 1 end
return count
end
function Reicht.Hatch.Room()
return math.max(0, (Reicht.State.PlantCap or Reicht.Config.PlantCapDefault) - Reicht.Hatch.Count())
end
function Reicht.Hatch.ValueCap()
local cap = Reicht.State.PlantCap or Reicht.Config.PlantCapDefault
return math.floor(cap * (1 - Reicht.Config.JunkPlotShare))
end
function Reicht.Hatch.ValueRoom()
local room = Reicht.Hatch.Room()
if not Reicht.Util.Opt("ClearJunk") then return room end
local held = Reicht.Hatch.Count() - Reicht.Junk.PlotJunk()
return math.max(0, math.min(room, Reicht.Hatch.ValueCap() - held))
end
function Reicht.Hatch.JunkRoom()
local room = Reicht.Hatch.Room()
if not Reicht.Util.Opt("AutoPlaceEggs") then return room end
local held = Reicht.Hatch.Count() - Reicht.Junk.PlotJunk()
return math.max(0, room - math.max(0, Reicht.Hatch.ValueCap() - held))
end
function Reicht.Hatch.Spots(bp, count)
local spacing = Reicht.Config.PlantSpacing
local taken = {}
for _, plotEgg in pairs(Reicht.State.PlotEggs) do
if typeof(plotEgg.pos) == "Vector3" then taken[#taken + 1] = plotEgg.pos end
end
local top = bp.Size.Y / 2
local halfX = bp.Size.X / 2 - Reicht.Config.EdgeInset - spacing / 2
local halfZ = bp.Size.Z / 2 - Reicht.Config.EdgeInset - spacing / 2
local spots = {}
for x = -halfX, halfX, spacing do
for z = -halfZ, halfZ, spacing do
local pos = (bp.CFrame * CFrame.new(x, top, z)).Position
local clear = true
for _, other in ipairs(taken) do
if Reicht.Util.Flat(other, pos) < spacing then
clear = false
break
end
end
if not clear then continue end
spots[#spots + 1] = pos
taken[#taken + 1] = pos
if #spots >= count then return spots end
end
end
return spots
end
function Reicht.Hatch.FreeNests(plot)
local nests = plot:FindFirstChild("Nests")
local free = {}
for _, nest in ipairs(nests and nests:GetChildren() or {}) do
if nest:GetAttribute("Unlocked") and not nest:GetAttribute("Occupied") then table.insert(free, nest.Name) end
end
return free
end
function Reicht.Hatch.PlantOne(token, tool, args)
local hum = Reicht.Player.Humanoid
if not hum or tool.Parent == nil then return false end
hum:EquipTool(tool)
local _, why = Reicht.Tasks.Await(token, function() return false end, Reicht.Config.EquipSettle)
if why ~= "timeout" then return false end
local before = Reicht.Hatch.LastPlaced
Reicht.Hatch.CapHit = false
local replied = function() return Reicht.Hatch.LastPlaced ~= before or Reicht.Hatch.CapHit end
for _ = 1, Reicht.Config.PlantTries do
if tool.Parent ~= hum.Parent then hum:EquipTool(tool) end
Reicht.GameLib.Remote("EggPlaced"):FireServer(args)
local ok, why = Reicht.Tasks.Await(token, replied, Reicht.Config.PlantReplyTimeout)
if ok then return not Reicht.Hatch.CapHit end
if why ~= "timeout" or tool.Parent == nil then return false end
end
return false
end
function Reicht.Hatch.PlantTool(token, tool)
Reicht.Hatch.Bind()
local plot, bp = Reicht.Player:Plot()
if not plot or not bp or Reicht.Hatch.Room() <= 0 then return nil end
local egg = Reicht.Hatch.ToolEgg(tool)
if not egg then return nil end
local noNest = LocalPlayer:GetAttribute("NoNest") == true
local slots = noNest and Reicht.Hatch.Spots(bp, 1) or Reicht.Hatch.FreeNests(plot)
if not slots[1] then return nil end
local before = {}
for key in pairs(Reicht.State.PlotEggs) do before[key] = true end
local stand = CFrame.new(bp.Position + Vector3.yAxis * (bp.Size.Y / 2 + Reicht.Geo.Lift(Config.PlantStandLift)))
if not Reicht.Tasks.Teleport(token, stand) then return nil end
local args = noNest and { PlantPosition = slots[1] } or { NestId = slots[1] }
if not Reicht.Hatch.PlantOne(token, tool, args) then return nil end
for key, placement in pairs(Reicht.State.PlotEggs) do
if not before[key] and placement.egg == egg then return key end
end
return nil
end
function Reicht.Hatch.IsLong(name, weight)
local cache = Reicht.Hatch.GrowCache
local key = name .. "|" .. weight
if cache[key] == nil then
local info = Reicht.GameLib.EggInfo[name]
local total = info and (Reicht.GameLib.GrowthSeconds(info.growth, weight) or info.growth) or 0
cache[key] = total > Reicht.Config.PlantLongGrow
end
return cache[key]
end
function Reicht.Hatch.LongRoom()
local cap = Reicht.State.PlantCap or Reicht.Config.PlantCapDefault
local held = 0
for _, plotEgg in pairs(Reicht.State.PlotEggs) do
local left = Reicht.Hatch.Left(plotEgg)
if left and left > Reicht.Config.PlantLongGrow then held += 1 end
end
return math.max(0, math.floor(cap * Reicht.Config.PlantLongShare) - held)
end
function Reicht.Hatch.Pick(room)
local longRoom = Reicht.Hatch.LongRoom()
local picked, spare = {}, {}
for _, entry in ipairs(Reicht.Hatch.Queue()) do
if #picked >= room then break end
if Reicht.Hatch.IsLong(entry[2], entry[3]) then
if longRoom <= 0 then
spare[#spare + 1] = entry
continue
end
longRoom -= 1
end
picked[#picked + 1] = entry
end
for _, entry in ipairs(spare) do
if #picked >= room then break end
picked[#picked + 1] = entry
end
return picked
end
function Reicht.Hatch.Plant(token, plot, bp)
local noNest = LocalPlayer:GetAttribute("NoNest") == true
local room = Reicht.Hatch.ValueRoom()
local queue = Reicht.Hatch.Pick(room)
local slots = noNest and Reicht.Hatch.Spots(bp, math.min(room, #queue)) or Reicht.Hatch.FreeNests(plot)
if #slots == 0 or #queue == 0 or room == 0 then return 0 end
Reicht.Tasks.Teleport(token, CFrame.new(bp.Position + Vector3.yAxis * (bp.Size.Y / 2 + Reicht.Geo.Lift(Config.PlantStandLift))))
local planted = 0
for i, slot in ipairs(slots) do
local entry = queue[i]
if i > room or not entry or not Reicht.Tasks.Holds(token) then break end
Reicht.Hatch.SetStatus("Placing " .. entry[2])
local args = noNest and { PlantPosition = slot } or { NestId = slot }
if not Reicht.Hatch.PlantOne(token, entry[1], args) then break end
planted += 1
end
return planted
end
function Reicht.Hatch.CanPlant()
if Reicht.Player:BasketCount() > 0 or not Reicht.Player:IsAlive() then return false end
if not Reicht.GameLib.Remote("EggPlaced") or Reicht.Junk.Running then return false end
return not Reicht.Hatch.Options().AutoEggs or Reicht.Eggs.Phase == "WaveWait"
end
function Reicht.Hatch.PlaceNow()
Reicht.Hatch.Bind()
if not Reicht.Hatch.CanPlant() then return 0 end
local plot, bp = Reicht.Player:Plot()
if not plot or not bp then return 0 end
if Reicht.Hatch.ValueRoom() == 0 then
if os.clock() - Reicht.Hatch.LastRequest > Reicht.Config.PlotFullRecheck then Reicht.Hatch.RequestSnapshot() end
Reicht.Hatch.SetStatus(string.format("Plot full (%d/%d)", Reicht.Hatch.Count(), Reicht.State.PlantCap or Reicht.Config.PlantCapDefault))
return 0
end
local token = Reicht.Tasks.Request("Plant", 40)
if not token then return 0 end
local ok, planted = Reicht.Util.Try("plant", Reicht.Hatch.Plant, token, plot, bp)
local hum = Reicht.Player.Humanoid
if hum and Reicht.Player:BasketCount() == 0 then hum:UnequipTools() end
Reicht.Tasks.Release(token)
planted = ok and planted or 0
Reicht.Hatch.Planted += planted
Reicht.Hatch.SetStatus(planted > 0 and ("Placed " .. planted .. " eggs") or (#Reicht.Hatch.EggTools() == 0 and "No eggs to place" or string.format("Plot %d/%d", Reicht.Hatch.Count(), Reicht.State.PlantCap or Reicht.Config.PlantCapDefault)))
return planted
end
function Reicht.Hatch.PlantStep()
local opts = Reicht.Hatch.Options()
if not opts.AutoPlaceEggs then return end
Reicht.Hatch.PlaceNow()
end
function Reicht.Hatch.Start()
Reicht.Hatch.Bind()
end
function Reicht.Hatch.Stop()
table.clear(Reicht.Hatch.Pending)
end
function Reicht.Hatch.Status()
return Reicht.State.Status.Hatch or "Idle"
end
Reicht.Junk = {
Bound = false,
Running = false,
Queue = {},
Cursor = 1,
BuiltAt = -math.huge,
EmptyUntil = 0,
Growth = {},
Share = {},
Held = nil,
EquippedAt = 0,
Spacing = Reicht.Config.JunkSpacing,
LastFire = -math.huge,
Calm = 0,
Slack = Reicht.Config.JunkHatchSlack,
HatchGap = 0,
Retries = 0,
Anchor = "seller",
PlantFails = 0,
FullUntil = 0,
BackoffUntil = 0,
YieldUntil = 0,
ActiveAt = 0,
ReportAt = 0,
Fresh = 0,
Selling = false,
Planted = 0,
Hatched = 0,
Sold = 0,
Window = {},
}
function Reicht.Junk.SetStatus(text)
Reicht.State.Status.Junk = text
end
function Reicht.Junk.PerMinute()
local window = Reicht.Junk.Window
local cutoff = os.clock() - Reicht.Config.JunkRateWindow
while window[1] and window[1] < cutoff do
table.remove(window, 1)
end
return #window
end
function Reicht.Junk.Report(note)
local junk = Reicht.Junk
junk.ReportAt = os.clock()
local line = string.format("Hatched %d | Sold %d | %d/min", junk.Hatched, junk.Sold, junk.PerMinute())
junk.SetStatus(note and (line .. " | " .. note) or line)
end
function Reicht.Junk.Set()
local picked = Reicht.Util.Opt("JunkRarities")
if type(picked) == "table" and next(picked) then return picked end
return { Common = true, Rare = true }
end
function Reicht.Junk.GrowthOf(name, weight)
local cache = Reicht.Junk.Growth
local key = name .. "|" .. string.format("%.2f", weight)
local known = cache[key]
if known then return known end
local info = Reicht.GameLib.EggInfo[name]
known = info and Reicht.GameLib.GrowthSeconds(info.growth, weight) or math.huge
cache[key] = known
return known
end
function Reicht.Junk.Build()
local junk = Reicht.Junk
local set, queue = junk.Set(), {}
for _, entry in ipairs(Reicht.Hatch.EggTools()) do
local info = Reicht.GameLib.EggInfo[entry[2]]
if info and set[info.rarity] then
queue[#queue + 1] = { entry[1], entry[2], entry[3], junk.GrowthOf(entry[2], entry[3]), info.luck }
end
end
table.sort(queue, function(a, b)
if a[4] ~= b[4] then return a[4] < b[4] end
return a[5] < b[5]
end)
junk.Queue, junk.Cursor, junk.BuiltAt = queue, 1, os.clock()
junk.EmptyUntil = #queue == 0 and os.clock() + Reicht.Config.JunkIdleCheck or 0
if #queue > 0 then junk.Share = junk.Measure(queue) end
return #queue
end
function Reicht.Junk.NextTool()
local junk = Reicht.Junk
local stale = os.clock() - junk.BuiltAt > Reicht.Config.JunkQueueTtl
if junk.Cursor > #junk.Queue or stale then
if os.clock() < junk.EmptyUntil then return nil end
junk.Build()
end
while junk.Cursor <= #junk.Queue do
local tool = junk.Queue[junk.Cursor][1]
junk.Cursor += 1
if tool.Parent ~= nil and tool ~= junk.Held then return tool end
end
return nil
end
function Reicht.Junk.Measure(queue)
local counts, total = {}, math.min(#queue, Reicht.Config.JunkShareSample)
for index = 1, total do
local name = queue[index][2]
counts[name] = (counts[name] or 0) + 1
end
local mult, share = Reicht.EggIndex.LuckMult(), {}
for name, count in pairs(counts) do
for _, pair in ipairs(Reicht.GameLib.Odds(name, mult) or {}) do
local pet = Reicht.GameLib.PetInfo[pair[1]]
if pet then share[pet.rarity] = (share[pet.rarity] or 0) + pair[2] * count / total end
end
end
return share
end
function Reicht.Junk.Distribution()
local junk = Reicht.Junk
if junk.BuiltAt == -math.huge then junk.Build() end
return junk.Share
end
function Reicht.Junk.SellSet()
local picked = Reicht.Util.Opt("JunkSellPets")
if type(picked) == "table" and next(picked) then return picked end
local rank, ceiling = Reicht.GameLib.RarityRank, 0
for rarity, share in pairs(Reicht.Junk.Distribution()) do
if share >= Reicht.Config.JunkAutoShare then ceiling = math.max(ceiling, rank[rarity] or 0) end
end
if ceiling == 0 then return Reicht.Junk.Set() end
local set = {}
for _, rarity in ipairs(Reicht.GameLib.RarityOrder) do
if (rank[rarity] or math.huge) <= ceiling then set[rarity] = true end
end
return set
end
function Reicht.Junk.WarnMismatch()
local picked = Reicht.Util.Opt("JunkSellPets")
if type(picked) ~= "table" or not next(picked) then return end
local share = Reicht.Junk.Distribution()
if not next(share) then return end
for rarity, chance in pairs(share) do
if picked[rarity] and chance >= 0.01 then return end
end
Reicht.Util.Notify("Clear Junk Eggs", "Your junk eggs do not give the pet rarities you picked to sell", 8)
end
function Reicht.Junk.PlotJunk()
local set, count = Reicht.Junk.Set(), 0
for _, plotEgg in pairs(Reicht.State.PlotEggs) do
local info = Reicht.GameLib.EggInfo[plotEgg.egg or ""]
if info and set[info.rarity] then count += 1 end
end
return count
end
function Reicht.Junk.HatchInFlight()
local now = os.clock()
for key in pairs(Reicht.State.PlotEggs) do
if (Reicht.Hatch.Pending[key] or 0) > now then return true end
end
return false
end
function Reicht.Junk.HasWork()
local junk = Reicht.Junk
if junk.PlotJunk() > 0 or junk.Fresh >= Reicht.Config.JunkSellEvery then return true end
if Reicht.Hatch.JunkRoom() == 0 then return false end
if junk.Cursor <= #junk.Queue then return true end
if os.clock() < junk.EmptyUntil then return false end
return junk.Build() > 0
end
local function ValueHatchOpen()
if not Reicht.Util.Opt("HoldHatchBoost") then return true end
return Reicht.Hatch.BoostActive()
end
function Reicht.Junk.Due(key, plotEgg, set, now)
local junk = Reicht.Junk
local info = Reicht.GameLib.EggInfo[plotEgg.egg or ""]
if not info then return false end
if not set[info.rarity] and not ValueHatchOpen() then return false end
if (Reicht.Hatch.Pending[key] or 0) > now then return false end
local readyAt = Reicht.Hatch.ReadyAt(plotEgg)
return readyAt ~= nil and now >= readyAt + junk.Slack
end
function Reicht.Junk.Fire(remote, key, now)
local junk, plotEgg = Reicht.Junk, Reicht.State.PlotEggs[key]
if not plotEgg then return end
if plotEgg.fired then
junk.Retries += 1
junk.Slack = math.min(junk.Slack + 0.01, Reicht.Config.JunkHatchSlackMax)
junk.HatchGap = math.min(junk.HatchGap * 2 + Reicht.Config.JunkHatchGapStep, Reicht.Config.JunkHatchGapMax)
end
plotEgg.fired = true
Reicht.Hatch.Pending[key] = now + Reicht.Config.JunkHatchRetry
remote:FireServer({ EggKey = key })
end
function Reicht.Junk.HatchReady()
local junk, remote = Reicht.Junk, Reicht.GameLib.Remote("Hatch")
if not remote then return 0 end
local set, now, keys = junk.Set(), os.clock(), {}
for key, plotEgg in pairs(Reicht.State.PlotEggs) do
if junk.Due(key, plotEgg, set, now) then keys[#keys + 1] = key end
end
for index, key in ipairs(keys) do
if index > 1 and junk.HatchGap > 0 then task.wait(junk.HatchGap) end
junk.Fire(remote, key, os.clock())
end
return #keys
end
function Reicht.Junk.OnHatched()
local junk = Reicht.Junk
junk.Hatched += 1
junk.Fresh += 1
table.insert(junk.Window, os.clock())
end
function Reicht.Junk.Prime()
local junk, hum = Reicht.Junk, Reicht.Player.Humanoid
local tool = junk.NextTool()
if not tool or not hum then return nil end
hum:EquipTool(tool)
junk.Held, junk.EquippedAt = tool, os.clock()
return tool
end
function Reicht.Junk.HandHolds(tool)
local char = Reicht.Player.Char
if not char or tool.Parent ~= char then return false end
for _, child in ipairs(char:GetChildren()) do
if child ~= tool and child:IsA("Tool") then return false end
end
return true
end
function Reicht.Junk.Ready(token)
local junk, hum = Reicht.Junk, Reicht.Player.Humanoid
local held = junk.Held
if held and held.Parent == nil then
held = nil
junk.Held = nil
end
if held and hum and not junk.HandHolds(held) then
hum:UnequipTools()
hum:EquipTool(held)
junk.EquippedAt = os.clock()
end
held = held or junk.Prime()
if not held then return nil end
local fireAt = math.max(junk.EquippedAt + Reicht.Config.JunkEquipSettle, junk.LastFire + junk.Spacing)
return junk.Pause(token, fireAt, held) and held or nil
end
function Reicht.Junk.Pause(token, untilAt, held)
local junk = Reicht.Junk
while os.clock() < untilAt do
if junk.HatchReady() > 0 or not junk.HandHolds(held) then return false end
if not junk.Frame(token) then return false end
end
return junk.HandHolds(held)
end
function Reicht.Junk.Ease()
local junk, cfg = Reicht.Junk, Reicht.Config
junk.Calm += 1
if junk.Calm < cfg.JunkSpacingEase then return end
junk.Calm = 0
junk.Spacing = math.max(cfg.JunkSpacingMin, junk.Spacing - cfg.JunkSpacingDown)
end
function Reicht.Junk.Harden()
local junk, cfg = Reicht.Junk, Reicht.Config
junk.Calm = 0
junk.PlantFails += 1
junk.Spacing = math.min(cfg.JunkSpacingMax, junk.Spacing + cfg.JunkSpacingUp)
end
function Reicht.Junk.OnFull()
local junk, hatch = Reicht.Junk, Reicht.Hatch
junk.FullUntil = os.clock() + Reicht.Config.JunkFullPause
hatch.RequestSnapshot()
end
function Reicht.Junk.Settled(replied, before, tool)
local junk, hatch = Reicht.Junk, Reicht.Hatch
if replied and hatch.LastPlaced ~= before then
junk.PlantFails = 0
junk.Planted += 1
junk.ActiveAt = os.clock()
junk.Ease()
junk.Held = nil
junk.Prime()
return true
end
if replied then
junk.OnFull()
return false
end
if tool.Parent == nil then
hatch.RequestSnapshot()
elseif not junk.HandHolds(tool) then
junk.Held = tool
else
junk.Harden()
end
return false
end
function Reicht.Junk.PlantOne(token, bp)
local junk, hatch = Reicht.Junk, Reicht.Hatch
local tool, remote = junk.Ready(token), Reicht.GameLib.Remote("EggPlaced")
local spot = hatch.Spots(bp, 1)[1]
if not tool or not remote or not spot then return false end
if not junk.HandHolds(tool) then return false end
local before = hatch.LastPlaced
hatch.CapHit = false
junk.LastFire = os.clock()
remote:FireServer({ PlantPosition = spot })
local replied = function() return hatch.LastPlaced ~= before or hatch.CapHit end
local ok = Reicht.Tasks.Await(token, replied, Reicht.Config.JunkPlantTimeout)
return junk.Settled(ok, before, tool)
end
function Reicht.Junk.Frame(token)
local _, why = Reicht.Tasks.Await(token, nil, 0)
return why == "timeout"
end
function Reicht.Junk.Alive(token)
if not Reicht.Util.Opt("ClearJunk") then return false end
if Reicht.Tasks.Carrying() or not Reicht.Player:IsAlive() then return false end
return Reicht.Tasks.Holds(token)
end
function Reicht.Junk.PlantFree(token, bp)
local junk, planted = Reicht.Junk, 0
while Reicht.Hatch.JunkRoom() > 0 and os.clock() >= junk.FullUntil and not junk.HatchInFlight() and junk.Alive(token) do
if not junk.PlantOne(token, bp) then break end
planted += 1
end
return planted
end
function Reicht.Junk.Goto(token, where)
local junk, hrp = Reicht.Junk, Reicht.Player.Root
local stand
if where == "seller" then
stand = Reicht.Sell.Stand()
else
stand = Reicht.Pets.PlotStand()
end
if not stand or not hrp then return false end
if (hrp.Position - stand.Position).Magnitude <= Reicht.Config.JunkAnchorNear then return true end
if not Reicht.Tasks.Teleport(token, stand) then return false end
local _, why = Reicht.Tasks.Await(token, nil, Reicht.Config.SellSettle)
return why == "timeout"
end
function Reicht.Junk.Enter(token)
local junk = Reicht.Junk
junk.Spacing = Reicht.Config.JunkSpacing
Reicht.Eggs.QuietInventory(true)
if Reicht.Player:Riding() then
Reicht.Player:Release()
Reicht.Tasks.Await(token, function() return not Reicht.Player:Riding() end, Reicht.Config.MountTimeout)
end
if junk.Anchor == "seller" and not Reicht.Sell.Stand() then junk.Anchor = "plot" end
if not junk.Goto(token, junk.Anchor) then return false end
junk.ActiveAt = os.clock()
junk.WarnMismatch()
return true
end
function Reicht.Junk.Sell(token)
local junk = Reicht.Junk
junk.Selling, junk.Fresh = true, 0
local ok, sold = pcall(Reicht.Sell.Run, token, true)
junk.Selling = false
if not ok then error(sold, 0) end
junk.Sold += sold
return sold
end
function Reicht.Junk.Dispatch(token)
local junk = Reicht.Junk
if junk.Anchor == "seller" then
task.spawn(Reicht.Util.Try, "junk sell", junk.Sell, token)
return
end
Reicht.Util.Try("junk sell", junk.Sell, token)
junk.Goto(token, "plot")
end
function Reicht.Junk.Resync()
local junk = Reicht.Junk
if os.clock() - junk.ActiveAt < Reicht.Config.JunkResyncIdle then return end
junk.ActiveAt = os.clock()
Reicht.Hatch.RequestSnapshot()
end
function Reicht.Junk.Progress(token)
local junk = Reicht.Junk
if not junk.Selling and junk.Fresh >= Reicht.Config.JunkSellEvery then junk.Dispatch(token) end
junk.Resync()
if os.clock() - junk.ReportAt >= Reicht.Config.JunkReportGap then junk.Report() end
end
function Reicht.Junk.Stuck(token)
local junk = Reicht.Junk
if junk.PlantFails < Reicht.Config.JunkPlantFails then return false end
junk.PlantFails = 0
if junk.Anchor == "seller" then
junk.Anchor = "plot"
return not junk.Goto(token, "plot")
end
junk.BackoffUntil = os.clock() + Reicht.Config.JunkBackoff
junk.Report("Server is not taking eggs, retrying soon")
return true
end
function Reicht.Junk.Yielding()
for _, idx in ipairs(Reicht.Config.JunkYieldTo) do
if Reicht.Util.Opt(idx) == true then return true end
end
return false
end
function Reicht.Junk.Finished(token, started)
local junk, now = Reicht.Junk, os.clock()
if junk.Stuck(token) then return true end
if now - started > Reicht.Config.JunkSessionMax and junk.Yielding() then
junk.YieldUntil = now + Reicht.Config.JunkYieldGap
return true
end
return not junk.HasWork()
end
function Reicht.Junk.Pulse(token, bp)
local junk = Reicht.Junk
local hatched = junk.HatchReady()
local planted = junk.PlantFree(token, bp)
if hatched + planted > 0 then junk.ActiveAt = os.clock() end
junk.Progress(token)
return hatched + planted > 0
end
function Reicht.Junk.Leave(token)
local junk, hum = Reicht.Junk, Reicht.Player.Humanoid
Reicht.Tasks.Await(token, function() return not junk.Selling end, Reicht.Config.SellReplyTimeout)
if junk.Alive(token) and junk.Fresh > 0 and not junk.HasWork() then
Reicht.Util.Try("junk sell", junk.Sell, token)
end
junk.Held = nil
if hum and hum.Parent and Reicht.Player:BasketCount() == 0 then hum:UnequipTools() end
Reicht.Mount.Dirty = true
junk.Report()
end
function Reicht.Junk.Run(token)
local junk = Reicht.Junk
local _, bp = Reicht.Player:Plot()
if not bp or not junk.Enter(token) then return end
local started = os.clock()
while junk.Alive(token) do
junk.Pulse(token, bp)
if junk.Finished(token, started) or not junk.Frame(token) then break end
end
junk.Leave(token)
end
function Reicht.Junk.Bind()
local junk = Reicht.Junk
if junk.Bound then return end
junk.Bound = true
Reicht.Hatch.Bind()
Reicht.Sell.Bind()
Reicht.Hatch.Signal:Connect(junk.OnHatched)
end
function Reicht.Junk.CanRun()
local junk, now = Reicht.Junk, os.clock()
if now < junk.BackoffUntil or now < junk.YieldUntil then return false end
if Reicht.Tasks.Carrying() or not Reicht.Player:IsAlive() then return false end
return junk.HasWork()
end
function Reicht.Junk.Step()
if not Reicht.Util.Opt("ClearJunk") then return end
local junk = Reicht.Junk
junk.Bind()
junk.HatchReady()
if not junk.CanRun() then
if junk.PlotJunk() > 0 then return end
junk.Report(Reicht.Hatch.Room() == 0 and "Plot is full" or "Nothing to clear right now")
return
end
local token = Reicht.Tasks.Request("Junk", Reicht.Tasks.Prio.Plot)
if not token then
junk.Report("Waiting for the egg run")
return
end
junk.Running = true
local ok, err = pcall(junk.Run, token)
junk.Running = false
Reicht.Tasks.Release(token)
if not ok then error(err, 0) end
end
function Reicht.Junk.SellNow()
Reicht.Junk.Bind()
local sold = Reicht.Pets.WithToken("Sell", Reicht.Tasks.Prio.Travel, function(token)
return Reicht.Sell.Run(token, true)
end) or 0
Reicht.Util.Notify("Clear Junk Eggs", sold > 0 and ("Sold " .. sold .. " pets") or "No junk pets to sell", 4)
return sold
end
function Reicht.Junk.Start()
Reicht.Junk.Bind()
end
function Reicht.Junk.Stop()
local junk = Reicht.Junk
junk.Report("Off")
end
function Reicht.Junk.Status()
return Reicht.State.Status.Junk or "Off"
end
Reicht.Pets = {
Bound = false,
Index = {},
Holders = {},
Placed = {},
Top = {},
TopAt = 0,
Collected = 0,
Swaps = 0,
Fed = 0,
Kept = {},
}
function Reicht.Pets.IsOurs(owner)
return owner == nil or owner == LocalPlayer or owner == LocalPlayer.UserId or owner == LocalPlayer.Name
end
function Reicht.Pets.SetStatus(text)
Reicht.State.Status.Pets = text
end
function Reicht.Pets.Saved(name)
local saved = LocalPlayer:FindFirstChild("SavedData")
local value = saved and saved:FindFirstChild(name)
return value and value.Value
end
function Reicht.Pets.IncomeRate()
local stats = LocalPlayer:FindFirstChild("leaderstats")
local value = stats and stats:FindFirstChild("Income/s")
return value and tonumber(value.Value) or 0
end
function Reicht.Pets.MaxSlots()
local fromAttr = tonumber(LocalPlayer:GetAttribute("MaxPets"))
return fromAttr or tonumber(Reicht.Pets.Saved("MaxPets")) or 5
end
function Reicht.Pets.AgedWeight(kg, age)
local aging = Reicht.GameLib.Svc.PetAging
if not age or type(aging) ~= "table" then return kg end
local ok, aged = Reicht.GameLib.Call(aging.WeightFor, kg, age)
return ok and tonumber(aged) or kg
end
function Reicht.Pets.AgeFrom(row)
local aging = Reicht.GameLib.Svc.PetAging
if not tonumber(row.BirthTime) or type(aging) ~= "table" then return nil end
local ok, age = Reicht.GameLib.Call(aging.StateFrom, row.BirthTime, Reicht.Util.ServerNow(), row)
return ok and tonumber(age) or nil
end
function Reicht.Pets.Income(pet)
local info = Reicht.GameLib.PetInfo[pet.name or ""]
if not info then return 0 end
local mutations = Reicht.GameLib.Mutations
local factor = (mutations[pet.mutation or ""] or 1) * (mutations[pet.spawnMutation or ""] or 1)
local kg = pet.baseWeight and pet.age and Reicht.Pets.AgedWeight(pet.baseWeight, pet.age)
or Reicht.Pets.AgedWeight(pet.weight or Reicht.Config.PetBaseKg, pet.age)
return math.floor(math.floor((info.income or 0) * kg / 10) * factor)
end
function Reicht.Pets.Record(src, placed)
local isTool = typeof(src) == "Instance"
local attrs = isTool and src:GetAttributes() or src
local name = attrs.PetName or (isTool and src.Name) or nil
local pet = {
key = attrs.PetKey,
name = name,
weight = tonumber(attrs.Weight) or tonumber(attrs.BaseWeight),
mutation = attrs.Mutation,
spawnMutation = attrs.SpawnMutation,
baseWeight = tonumber(attrs.BaseWeight),
birthTime = tonumber(attrs.BirthTime),
age = tonumber(attrs.Age),
favorite = attrs.Favorited == true,
placed = placed,
tool = isTool and src or nil,
pos = placed and attrs.Position or nil,
collectTime = tonumber(attrs.CollectTime),
at = os.clock(),
}
if not pet.age and pet.birthTime then
pet.age = Reicht.Pets.AgeFrom({ PetName = name, BaseWeight = pet.baseWeight, Weight = pet.weight, BirthTime = pet.birthTime })
end
pet.ageKnown = pet.age ~= nil
pet.mutated = (pet.mutation ~= nil and pet.mutation ~= "") or (pet.spawnMutation ~= nil and pet.spawnMutation ~= "")
pet.income = Reicht.Pets.Income(pet)
local info = Reicht.GameLib.PetInfo[name or ""]
pet.speed = info and info.speed or 0
pet.rarity = info and info.rarity
return pet
end
function Reicht.Pets.OnPlace(reply)
if type(reply) ~= "table" or not Reicht.Pets.IsOurs(reply.Owner) then return end
if reply.Action == "Remove" then
if type(reply.PetKey) == "string" then
Reicht.Pets.Placed[reply.PetKey] = nil
else
table.clear(Reicht.Pets.Placed)
end
elseif reply.Action == "Place" and reply.PetKey then
Reicht.Pets.Placed[reply.PetKey] = Reicht.Pets.Record(reply, true)
end
Reicht.Pets.TopAt = 0
end
function Reicht.Pets.OnCollect(reply)
if type(reply) ~= "table" or not Reicht.Pets.IsOurs(reply.Owner) then return end
local keys = type(reply.PetKeys) == "table" and reply.PetKeys or { reply.PetKey }
for _, key in pairs(keys) do
local pet = Reicht.Pets.Placed[key]
if pet then pet.collectTime = tonumber(reply.CollectTime) or Reicht.Util.ServerNow() end
end
end
function Reicht.Pets.OnFed(reply)
if type(reply) ~= "table" or not Reicht.Pets.IsOurs(reply.Owner) then return end
Reicht.Pets.FedAt = os.clock()
local pet = Reicht.Pets.Placed[reply.PetKey or ""]
if not pet then return end
pet.weight = tonumber(reply.Weight) or pet.weight
if tonumber(reply.BirthTime) then
pet.birthTime = tonumber(reply.BirthTime)
pet.age = Reicht.Pets.AgeFrom({ PetName = pet.name, BaseWeight = pet.baseWeight, Weight = pet.weight, BirthTime = pet.birthTime }) or pet.age
end
pet.income = Reicht.Pets.Income(pet)
end
function Reicht.Pets.SeedFromRenderer()
local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
local module = scripts and scripts:FindFirstChild("PetRenderer", true)
local renderer = module and Reicht.GameLib.Require(module)
if type(renderer) ~= "table" or type(renderer.GetAll) ~= "function" then return end
local ok, all = Reicht.GameLib.Call(renderer.GetAll)
if not ok or type(all) ~= "table" then return end
for _, entry in pairs(all) do
if type(entry) ~= "table" or not entry.PetKey then continue end
if entry.OwnerUserId ~= LocalPlayer.UserId then continue end
local model = typeof(entry.Model) == "Instance" and entry.Model or nil
local pos = entry.Position
if typeof(pos) ~= "Vector3" and model and model:IsA("Model") then pos = model:GetPivot().Position end
local row = setmetatable({ PetName = entry.PetName or (model and model.Name), Position = pos }, {
__index = function(_, key)
local value = entry[key]
if value == nil and model then value = model:GetAttribute(key) end
return value
end,
})
Reicht.Pets.Placed[entry.PetKey] = Reicht.Pets.Record(row, true)
end
end
function Reicht.Pets.Bind()
if Reicht.Pets.Bound then return end
Reicht.Pets.Bound = true
local place = Reicht.GameLib.Remote("PlacePet")
if place then Reicht:Connect(place.OnClientEvent, Reicht.Pets.OnPlace) end
local collect = Reicht.GameLib.Remote("PetCollect")
if collect then Reicht:Connect(collect.OnClientEvent, Reicht.Pets.OnCollect) end
local fed = Reicht.GameLib.Remote("PetFed")
if fed then Reicht:Connect(fed.OnClientEvent, Reicht.Pets.OnFed) end
Reicht.Util.Try("pets seed", Reicht.Pets.SeedFromRenderer)
table.insert(Reicht.State.Connections, Reicht.Pets.Unbind)
Reicht.Pets.WatchHolders(LocalPlayer.Character)
Reicht:Connect(LocalPlayer.CharacterAdded, function(char)
task.defer(Reicht.Util.Try, "pets rebind", Reicht.Pets.WatchHolders, char)
end)
end
function Reicht.Pets.Unbind()
for _, entry in pairs(Reicht.Pets.Index) do entry.conn:Disconnect() end
table.clear(Reicht.Pets.Index)
table.clear(Reicht.Pets.Holders)
end
function Reicht.Pets.Held(inst)
local parent = inst.Parent
return parent ~= nil and Reicht.Pets.Holders[parent] ~= nil
end
function Reicht.Pets.Track(tool)
local index = Reicht.Pets.Index
if index[tool] or not tool:IsA("Tool") or not tool:GetAttribute("PetKey") then return end
local entry = { name = tool:GetAttribute("PetName") or tool.Name }
entry.conn = tool.AttributeChanged:Connect(function(attr)
if Reicht.Config.PetWatchedAttrs[attr] then entry.rec = nil end
end)
index[tool] = entry
end
function Reicht.Pets.Untrack(tool)
local entry = Reicht.Pets.Index[tool]
if not entry or Reicht.Pets.Held(tool) then return end
entry.conn:Disconnect()
Reicht.Pets.Index[tool] = nil
end
function Reicht.Pets.Watch(holder)
if not holder or Reicht.Pets.Holders[holder] then return end
Reicht.Pets.Holders[holder] = {
Reicht:Connect(holder.ChildAdded, Reicht.Pets.Track),
Reicht:Connect(holder.ChildRemoved, function(child) task.defer(Reicht.Pets.Untrack, child) end),
}
for _, child in ipairs(holder:GetChildren()) do Reicht.Pets.Track(child) end
end
function Reicht.Pets.WatchHolders(char)
local bag = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", Reicht.Config.LoadTimeout)
for holder, conns in pairs(Reicht.Pets.Holders) do
if holder == bag or holder == char then continue end
for _, conn in ipairs(conns) do conn:Disconnect() end
Reicht.Pets.Holders[holder] = nil
end
Reicht.Pets.Watch(bag)
Reicht.Pets.Watch(char)
for tool in pairs(Reicht.Pets.Index) do Reicht.Pets.Untrack(tool) end
end
function Reicht.Pets.ToolRecord(tool, entry)
local rec = entry.rec
if rec and not (rec.birthTime and os.clock() - rec.at > Reicht.Config.PetAgeRefresh) then return rec end
rec = Reicht.Pets.Record(tool, false)
entry.rec = rec
return rec
end
function Reicht.Pets.ToolsByName()
Reicht.Pets.Bind()
local found = {}
for tool, entry in pairs(Reicht.Pets.Index) do
local name = entry.name
if name and not found[name] and Reicht.GameLib.PetInfo[name] then found[name] = tool end
end
return found
end
function Reicht.Pets.ToolNamed(name)
Reicht.Pets.Bind()
for tool, entry in pairs(Reicht.Pets.Index) do
if entry.name == name then return tool end
end
return nil
end
function Reicht.Pets.Owned()
Reicht.Pets.Bind()
local list = {}
for tool, entry in pairs(Reicht.Pets.Index) do
list[#list + 1] = Reicht.Pets.ToolRecord(tool, entry)
end
for _, pet in pairs(Reicht.Pets.Placed) do
table.insert(list, pet)
end
return list
end
function Reicht.Pets.RideKey()
if not Reicht.Player:Riding() then return nil end
local char = Reicht.Player.Char
local tool = char and char:FindFirstChildOfClass("Tool")
return tool and tool:GetAttribute("PetKey") or nil
end
function Reicht.Pets.IsRide(pet)
if pet.tool and pet.tool.Parent == Reicht.Player.Char and Reicht.Player:Riding() then return true end
local rideKey = Reicht.Pets.RideKey()
return rideKey ~= nil and rideKey == pet.key
end
function Reicht.Pets.RebirthNeeds()
local done = tonumber(Reicht.Pets.Saved("Rebirths")) or 0
local needs = {}
for step, req in pairs(Reicht.GameLib.RebirthReq or {}) do
local index = tonumber(step)
if type(step) == "string" and not index then
if (tonumber(req) or math.huge) > done then needs[step] = true end
continue
end
if not index or index <= done then continue end
if type(req) == "string" then needs[req] = true end
if type(req) == "table" then
for _, name in pairs(req) do
if type(name) == "string" then needs[name] = true end
end
end
end
return needs
end
function Reicht.Pets.TopPlaced()
local now = os.clock()
if now - Reicht.Pets.TopAt < Reicht.Config.TopCacheSec then return Reicht.Pets.Top end
local placed = {}
for _, pet in pairs(Reicht.Pets.Placed) do placed[#placed + 1] = pet end
table.sort(placed, function(a, b) return a.income > b.income end)
local top = {}
for i = 1, math.min(#placed, Reicht.Pets.MaxSlots()) do top[placed[i].key] = true end
Reicht.Pets.Top, Reicht.Pets.TopAt = top, now
return top
end
function Reicht.Pets.Protected(pet, needs)
if pet.favorite then return true, "favorite" end
local list = Reicht.Util.Opt("ProtectList")
if type(list) == "table" and (list[pet.name or ""] or list[pet.key or ""]) then return true, "protect list" end
needs = needs or Reicht.Pets.RebirthNeeds()
if needs[pet.name or ""] then return true, "rebirth" end
if Reicht.Pets.IsRide(pet) then return true, "ride pet" end
if pet.name and (Reicht.Mount.Choice() == pet.name or Reicht.Mount.Name == pet.name) then return true, "ride pet" end
local fusion = Reicht.Fusion
if fusion and fusion.Inputs and fusion.Inputs[pet.key or ""] then return true, "fusion" end
if pet.placed and Reicht.Pets.TopPlaced()[pet.key or ""] then return true, "placed" end
return false
end
function Reicht.Pets.PlotStand()
local _, bp = Reicht.Player:Plot()
if not bp then return nil end
return CFrame.new(bp.Position + Vector3.new(0, bp.Size.Y / 2 + Reicht.Geo.Lift(Config.PetStandLift), 0)), bp
end
function Reicht.Pets.Spot(bp)
local spread = Reicht.Config.PetSpread
local offset = Vector3.new((math.random() * 2 - 1) * bp.Size.X * spread, bp.Size.Y / 2 + 1, (math.random() * 2 - 1) * bp.Size.Z * spread)
return (bp.CFrame * CFrame.new(offset)).Position
end
function Reicht.Pets.WithToken(owner, prio, fn)
local token = Reicht.Tasks.Request(owner, prio)
if not token then return nil end
local ok, out = pcall(fn, token)
Reicht.Tasks.Release(token)
if not ok then error(out, 0) end
return out
end
function Reicht.Pets.SwapPlan()
local unplaced, placed = {}, {}
local mount = Reicht.Mount.Best()
local rideKept = false
for _, pet in ipairs(Reicht.Pets.Owned()) do
if pet.placed then
if pet.ageKnown then placed[#placed + 1] = pet end
elseif Reicht.Pets.IsRide(pet) then
rideKept = true
elseif pet.key and pet.income > 0 then
table.insert(unplaced, pet)
elseif pet.name == mount then
rideKept = true
end
end
table.sort(unplaced, function(a, b) return a.income > b.income end)
table.sort(placed, function(a, b) return a.income < b.income end)
if mount and not rideKept then
for i = #unplaced, 1, -1 do
if unplaced[i].name == mount then
table.remove(unplaced, i)
break
end
end
end
return unplaced, placed
end
function Reicht.Pets.AwaitPlaced(token, key, present)
return (Reicht.Tasks.Await(token, function()
return (Reicht.Pets.Placed[key] ~= nil) == present
end, Reicht.Config.PetReplyTimeout))
end
function Reicht.Pets.Swap(token, pet, worst, bp)
local placeRemote, pickRemote = Reicht.GameLib.Remote("PlacePet"), Reicht.GameLib.Remote("PickupPet")
token.critical = true
if worst then
pickRemote:FireServer(worst.key)
if not Reicht.Pets.AwaitPlaced(token, worst.key, false) then
token.critical = false
return false
end
end
placeRemote:FireServer(pet.key, Reicht.Pets.Spot(bp))
local ok = Reicht.Pets.AwaitPlaced(token, pet.key, true)
if not ok and worst then
placeRemote:FireServer(worst.key, worst.pos or Reicht.Pets.Spot(bp))
Reicht.Pets.AwaitPlaced(token, worst.key, true)
end
token.critical = false
return ok
end
function Reicht.Pets.PlaceBest(token)
local placeRemote, pickRemote = Reicht.GameLib.Remote("PlacePet"), Reicht.GameLib.Remote("PickupPet")
local stand, bp = Reicht.Pets.PlotStand()
if not placeRemote or not pickRemote or not stand then return 0 end
local unplaced, placed = Reicht.Pets.SwapPlan()
local free = Reicht.Pets.MaxSlots() - #placed
for i = #placed, 1, -1 do
if Reicht.Pets.Kept[placed[i].key or ""] then table.remove(placed, i) end
end
if not unplaced[1] then return 0 end
if free <= 0 and (not placed[1] or unplaced[1].income <= placed[1].income * Reicht.Config.PetSwapGain) then return 0 end
if not Reicht.Tasks.Teleport(token, stand) then return 0 end
local changed, swapped = 0, {}
local before = Reicht.Pets.IncomeRate()
for _, pet in ipairs(unplaced) do
if not Reicht.Tasks.Holds(token) then break end
local worst
if free <= 0 then
worst = placed[1]
if not worst or pet.income <= worst.income * Reicht.Config.PetSwapGain then break end
end
local ok = Reicht.Pets.Swap(token, pet, worst, bp)
if not ok then break end
if worst then
table.remove(placed, 1)
table.insert(swapped, { pet, worst })
else
free -= 1
end
changed += 1
end
if #swapped > 0 then changed -= Reicht.Pets.GuardIncome(token, before, swapped, bp) end
Reicht.Pets.Swaps += changed
if changed > 0 then Reicht.Mount.Dirty = true end
return changed
end
function Reicht.Pets.GuardIncome(token, before, swapped, bp)
Reicht.Tasks.Await(token, nil, Reicht.Config.IncomeSettle)
local after = Reicht.Pets.IncomeRate()
if after >= before then return 0 end
local undone = 0
for i = #swapped, 1, -1 do
local pair = swapped[i]
Reicht.Pets.Kept[pair[2].key] = true
if not Reicht.Tasks.Holds(token) then break end
if Reicht.Pets.Swap(token, pair[2], Reicht.Pets.Placed[pair[1].key] or pair[1], bp) then undone += 1 end
end
warn(Reicht.Config.Tag, "place best: income " .. before .. " -> " .. after .. ", undid " .. undone)
return undone
end
function Reicht.Pets.GameCollects()
if LocalPlayer:GetAttribute("AutoCollectCash") == true then return true end
local passes = tostring(Reicht.Pets.Saved("OwnedPasses") or "")
for _, mark in ipairs(Reicht.Config.AutoCollectPass) do
if passes:find(mark, 1, true) then return true end
end
return false
end
function Reicht.Pets.PendingSec(pet)
if not pet.collectTime then return math.huge end
return Reicht.Util.ServerNow() - pet.collectTime
end
function Reicht.Pets.Collect(token, force)
local remote = Reicht.GameLib.Remote("PetCollect")
if not remote then return 0 end
local fired = 0
for key, pet in pairs(Reicht.Pets.Placed) do
if not Reicht.Tasks.Holds(token) then break end
if not force and Reicht.Pets.PendingSec(pet) < Reicht.Config.CollectMinPending then continue end
if typeof(pet.pos) ~= "Vector3" then continue end
if not Reicht.Tasks.Teleport(token, CFrame.new(pet.pos + Vector3.new(0, Reicht.Config.PetStandLift, 0))) then break end
local ok, why = Reicht.Tasks.Await(token, nil, Reicht.Config.CollectGap)
if not ok and why ~= "timeout" then break end
remote:FireServer(key)
fired += 1
end
Reicht.Pets.Collected += fired
if fired > 0 then
local stand = Reicht.Pets.PlotStand()
if stand then Reicht.Tasks.Teleport(token, stand) end
end
return fired
end
function Reicht.Pets.FoodTools()
local allowed = Reicht.Util.Opt("FoodTypes")
local foods = Reicht.GameLib.Foods or {}
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local tools = {}
for _, tool in ipairs(backpack and backpack:GetChildren() or {}) do
local row = tool:IsA("Tool") and foods[tool.Name]
if not row then continue end
if type(allowed) == "table" and next(allowed) and not allowed[tool.Name] then continue end
tools[#tools + 1] = { tool, type(row) == "table" and tonumber(row.Price or row.Cost) or 0 }
end
table.sort(tools, function(a, b) return a[2] < b[2] end)
for i, pair in ipairs(tools) do tools[i] = pair[1] end
return tools
end
function Reicht.Pets.FeedTargets()
local mode = Reicht.Util.Opt("FeedTarget") or "Placed"
local targets = {}
if mode ~= "Ride pet" then
for key, pet in pairs(Reicht.Pets.Placed) do
if (pet.age or 0) < Reicht.Config.PetMaxAge then targets[#targets + 1] = { key, false } end
end
end
local rideKey = mode ~= "Placed" and Reicht.Pets.RideKey()
if rideKey then
local tool = Reicht.Player.Char and Reicht.Player.Char:FindFirstChildOfClass("Tool")
local age = tool and tonumber(tool:GetAttribute("Age")) or 0
if age < Reicht.Config.PetMaxAge then table.insert(targets, { rideKey, true }) end
end
return targets
end
function Reicht.Pets.GoHome(token)
local hrp = Reicht.Player.Root
if hrp and Reicht.Geo.InPlot(hrp.Position) then return true end
local stand = Reicht.Pets.PlotStand()
return stand ~= nil and Reicht.Tasks.Teleport(token, stand)
end
function Reicht.Pets.Feed()
local remote = Reicht.GameLib.Remote("FeedPet")
if not remote then return 0 end
Reicht.Pets.Bind()
if not Reicht.Pets.FoodTools()[1] or not Reicht.Pets.FeedTargets()[1] then
Reicht.State.Status.Feed = "No food or nothing to feed"
return 0
end
return Reicht.Pets.WithToken("Feed", Reicht.Tasks.Prio.Plot, function(token)
if not Reicht.Pets.GoHome(token) then
Reicht.State.Status.Feed = "Could not reach the ranch"
return 0
end
return Reicht.Pets.FeedAll(remote, token)
end) or 0
end
local function FoodLeft(tool)
local data = tool and tool.Parent and tool:FindFirstChild("Data")
local amount = data and data:FindFirstChild("Amount")
return amount and tonumber(amount.Value) or 1
end
function Reicht.Pets.FeedAll(remote, token)
local cfg = Reicht.Config
local used, misses, turn = 0, 0, 0
local deadline = os.clock() + cfg.FeedBurst
while os.clock() < deadline and misses < cfg.FeedMissLimit and Reicht.Tasks.Holds(token) do
local targets = Reicht.Pets.FeedTargets()
local food
for _, tool in ipairs(Reicht.Pets.FoodTools()) do
if FoodLeft(tool) > 0 then
food = tool
break
end
end
if not food or #targets == 0 then break end
turn = turn % #targets + 1
local target = targets[turn]
local before, firedAt = Reicht.Pets.FedAt, os.clock()
remote:FireServer(target[1], food.Name, target[2] or nil)
local ok = Reicht.Tasks.Await(token, function() return Reicht.Pets.FedAt ~= before end, cfg.FeedReplyTimeout)
if ok then
used += 1
misses = 0
else
misses += 1
end
local wait = firedAt + cfg.FeedGap - os.clock()
if wait > 0 then Reicht.Tasks.Await(token, function() return false end, wait) end
end
Reicht.Pets.Fed += used
Reicht.State.Status.Feed = used > 0 and ("Fed " .. Reicht.Pets.Fed .. " times") or "No food or nothing to feed"
return used
end
function Reicht.Pets.PlaceNow()
return Reicht.Pets.WithToken("Pets", Reicht.Tasks.Prio.Plot, function(token)
Reicht.Pets.Bind()
local changed = Reicht.Pets.PlaceBest(token)
Reicht.Pets.SetStatus(changed > 0 and ("Placed " .. changed .. " pets") or "Best pets placed")
return changed
end) or 0
end
function Reicht.Pets.CollectNow()
return Reicht.Pets.WithToken("Pets", Reicht.Tasks.Prio.Plot, function(token)
Reicht.Pets.Bind()
return Reicht.Pets.Collect(token, true)
end) or 0
end
function Reicht.Pets.Step()
local equip, collect = Reicht.Util.Opt("AutoEquipBest"), Reicht.Util.Opt("AutoCollectCash")
if not equip and not collect then return end
Reicht.Pets.Bind()
local gameCollects = collect and Reicht.Pets.GameCollects()
Reicht.Pets.WithToken("Pets", Reicht.Tasks.Prio.Plot, function(token)
if equip then Reicht.Pets.PlaceBest(token) end
if collect and not gameCollects then Reicht.Pets.Collect(token, false) end
end)
Reicht.Pets.SetStatus(Reicht.Pets.Status())
end
function Reicht.Pets.FeedStep()
if not Reicht.Util.Opt("AutoFeed") then return end
Reicht.Pets.Feed()
end
function Reicht.Pets.Status()
return string.format("Placed %d/%d | Swaps %d | Collects %d", #Reicht.Pets.PlacedList(), Reicht.Pets.MaxSlots(), Reicht.Pets.Swaps, Reicht.Pets.Collected)
end
function Reicht.Pets.PlacedList()
local list = {}
for _, pet in pairs(Reicht.Pets.Placed) do list[#list + 1] = pet end
return list
end
function Reicht.Pets.Start()
Reicht.Pets.Bind()
end
function Reicht.Pets.Stop()
local hum = Reicht.Player.Humanoid
if hum and not Reicht.Player:Riding() then hum:UnequipTools() end
end
Reicht.Sell = {
Bound = false,
ConfirmUntil = 0,
Reply = nil,
Sold = 0,
Earned = 0,
}
function Reicht.Sell.SetStatus(text)
Reicht.State.Status.Sell = text
end
function Reicht.Sell.OnConfirm(id, question)
if os.clock() > Reicht.Sell.ConfirmUntil then return end
if not tostring(question or ""):lower():find("sell", 1, true) then return end
Reicht.Sell.ConfirmUntil = 0
local remote = Reicht.GameLib.Remote("ConfirmRequest")
if remote then remote:FireServer(id, true) end
end
function Reicht.Sell.Bind()
if Reicht.Sell.Bound then return end
Reicht.Sell.Bound = true
local sell = Reicht.GameLib.Remote("SellItems")
if sell then
Reicht:Connect(sell.OnClientEvent, function(reply) Reicht.Sell.Reply = reply end)
end
local confirm = Reicht.GameLib.Remote("ConfirmRequest")
if confirm then Reicht:Connect(confirm.OnClientEvent, Reicht.Sell.OnConfirm) end
end
function Reicht.Sell.Allowed(pet, keep, under)
if pet.placed or not pet.key or not pet.rarity then return false end
if keep[pet.rarity] then return false end
if pet.mutated and Reicht.Util.Opt("SellKeepMutated") then return false end
if under > 0 and pet.income >= under then return false end
return true
end
function Reicht.Sell.DefaultKeep()
local order = Reicht.GameLib.RarityOrder
local keep = {}
for i = math.max(1, #order - Reicht.Config.SellKeepTopRarities + 1), #order do
keep[order[i]] = true
end
return keep
end
function Reicht.Sell.JunkKeep()
local sell = Reicht.Junk.SellSet()
local keep = {}
for _, rarity in ipairs(Reicht.GameLib.RarityOrder) do
if not sell[rarity] then keep[rarity] = true end
end
return keep
end
function Reicht.Sell.Plan(junkOnly)
local keep = Reicht.Util.Opt("SellRarities")
if type(keep) ~= "table" or next(keep) == nil then keep = Reicht.Sell.DefaultKeep() end
if junkOnly then keep = Reicht.Sell.JunkKeep() end
local under = not junkOnly and tonumber(Reicht.Util.Opt("SellUnderIncome")) or 0
local keepBest = junkOnly and Reicht.Pets.MaxSlots() or tonumber(Reicht.Util.Opt("SellKeepBest")) or 0
local owned = Reicht.Pets.Owned()
table.sort(owned, function(a, b) return a.income > b.income end)
local needs = Reicht.Pets.RebirthNeeds()
local plan, cash = {}, 0
for rank, pet in ipairs(owned) do
if rank <= keepBest then continue end
if not Reicht.Sell.Allowed(pet, keep, under) then continue end
if Reicht.Pets.Protected(pet, needs) then continue end
plan[#plan + 1] = pet
cash += pet.income * GameLib.SellMultiplier()
end
return plan, cash
end
function Reicht.Sell.Preview()
local plan, cash = Reicht.Sell.Plan()
local text = "Will sell " .. #plan .. " for $" .. Reicht.Util.Format(cash)
Reicht.State.Status.SellPreview = text
return text
end
function Reicht.Sell.Stand()
local stalls = Workspace:FindFirstChild("Stalls")
local stall = stalls and stalls:FindFirstChild("Sell")
local richie = stall and stall:FindFirstChild("Richie")
if not richie then return nil end
local pivot = richie:IsA("Model") and richie:GetPivot() or (richie:IsA("BasePart") and richie.CFrame)
if not pivot then return nil end
return CFrame.new(pivot.Position + pivot.LookVector * Reicht.Config.SellStand)
end
function Reicht.Sell.Batch(token, remote, keys)
Reicht.Sell.Reply = nil
Reicht.Sell.ConfirmUntil = os.clock() + Reicht.Config.ConfirmWindow
remote:FireServer({ Pets = keys, Eggs = {} })
Reicht.Tasks.Await(token, function() return Reicht.Sell.Reply ~= nil end, Reicht.Config.SellReplyTimeout)
local reply = Reicht.Sell.Reply
if type(reply) ~= "table" then return nil end
if reply.Reason and reply.Reason ~= "Sold" then return nil, reply.Reason end
return tonumber(reply.Sold) or 0
end
function Reicht.Sell.Send(token, remote, keys)
local cfg = Reicht.Config
for _ = 1, cfg.SellTries do
local got, why = Reicht.Sell.Batch(token, remote, keys)
if got then return got end
if why ~= "TooFar" and why ~= "Busy" then
Reicht.Sell.SetStatus("Seller says: " .. tostring(why or "no answer"))
return nil
end
local _, waited = Reicht.Tasks.Await(token, nil, why == "Busy" and cfg.SellRetry or cfg.SellSettle)
if waited ~= "timeout" then return nil end
end
Reicht.Sell.SetStatus("Seller is busy")
return nil
end
function Reicht.Sell.GuardIncome(before, toggle)
task.wait(Reicht.Config.IncomeSettle)
local after = Reicht.Pets.IncomeRate()
if after >= before then return end
table.insert(Reicht.State.PendingToggleOff, toggle)
Reicht.Util.Notify("Reicht", "Income went down after selling, the sale option was stopped", 8)
warn(Reicht.Config.Tag .. " sell: income " .. before .. " -> " .. after)
end
function Reicht.Sell.Arrive(token, stand)
local hrp = Reicht.Player.Root
if hrp and (hrp.Position - stand.Position).Magnitude <= Reicht.Config.SellNear then return true end
if not Reicht.Tasks.Teleport(token, stand) then return false end
local _, settled = Reicht.Tasks.Await(token, nil, Reicht.Config.SellSettle)
return settled == "timeout"
end
function Reicht.Sell.Run(token, junkOnly)
local remote = Reicht.GameLib.Remote("SellItems")
local stand = Reicht.Sell.Stand()
if not remote or not Reicht.GameLib.Remote("ConfirmRequest") or not stand then
Reicht.Sell.SetStatus("Seller not found")
return 0
end
local plan, cash = Reicht.Sell.Plan(junkOnly)
if #plan == 0 then
Reicht.Sell.SetStatus("Nothing to sell")
return 0
end
if not Reicht.Sell.Arrive(token, stand) then return 0 end
local before, sold = Reicht.Pets.IncomeRate(), 0
for first = 1, #plan, Reicht.Config.SellBatch do
local keys = {}
for i = first, math.min(first + Reicht.Config.SellBatch - 1, #plan) do
table.insert(keys, plan[i].key)
end
local got = Reicht.Sell.Send(token, remote, keys)
if not got then break end
sold += got
end
Reicht.Sell.Sold += sold
if sold > 0 then Reicht.Sell.Earned += cash * sold / #plan end
Reicht.Sell.SetStatus("Sold " .. sold .. " pets")
Reicht.Sell.GuardIncome(before, junkOnly and "ClearJunk" or "AutoSell")
return sold
end
function Reicht.Sell.Now()
Reicht.Sell.Bind()
return Reicht.Pets.WithToken("Sell", Reicht.Tasks.Prio.Travel, Reicht.Sell.Run) or 0
end
function Reicht.Sell.Step()
Reicht.Sell.Preview()
if Reicht.Util.Opt("AutoSell") then Reicht.Sell.Now() end
end
function Reicht.Sell.Status()
return Reicht.State.Status.Sell or ""
end
function Reicht.Sell.Start()
Reicht.Sell.Bind()
end
function Reicht.Sell.Stop()
Reicht.Sell.ConfirmUntil = 0
end
Reicht.Fusion = {
Inputs = {},
Fused = 0,
FiredAt = 0,
}
function Reicht.Fusion.Rarities()
local rank = Reicht.GameLib.RarityRank
local list, seen = {}, {}
if next(Reicht.GameLib.FuseQuality) then
for name in pairs(Reicht.GameLib.FuseQuality) do
local info = Reicht.GameLib.PetInfo[name]
if info and not seen[info.rarity] then
seen[info.rarity] = true
list[#list + 1] = info.rarity
end
end
else
local cfg = Reicht.GameLib.Data.Fusion
local floor = type(cfg) == "table" and rank[cfg.MinimumInputRarity] or 0
for _, rarity in ipairs(Reicht.GameLib.RarityOrder) do
if (rank[rarity] or 0) >= floor then list[#list + 1] = rarity end
end
return list
end
table.sort(list, function(a, b) return (rank[a] or 0) < (rank[b] or 0) end)
return list
end
function Reicht.Fusion.Pace(token)
local cfg = Reicht.GameLib.Data.Fusion
local gap = type(cfg) == "table" and tonumber(cfg.RequestCooldown) or Reicht.Config.FuseGap
local readyAt = Reicht.Fusion.FiredAt + gap
if os.clock() >= readyAt then return true end
return (Reicht.Tasks.Await(token, function() return os.clock() >= readyAt end, gap))
end
function Reicht.Fusion.SetStatus(text)
Reicht.State.Status.Fusion = text
end
function Reicht.Fusion.Active()
local cfg = Reicht.GameLib.Data and Reicht.GameLib.Data.Fusion
if type(cfg) ~= "table" then return false end
local start = tonumber(cfg.StartTime)
local on, off = tonumber(cfg.ActiveWeeks), tonumber(cfg.InactiveWeeks)
if not (start and on and off) then return Reicht.Fusion.Machine() ~= nil end
local now = Reicht.Util.ServerNow()
if now < start then return false end
local period = (on + off) * Reicht.Config.WeekSec
return (now - start) % period < on * Reicht.Config.WeekSec
end
function Reicht.Fusion.Machine()
local functionals = Workspace:FindFirstChild("Functionals")
local machine = functionals and functionals:FindFirstChild("Fusion")
if not machine then return nil, {} end
local slots, console = {}, nil
for _, node in ipairs(machine:GetDescendants()) do
local slot = node:IsA("Attachment") and tonumber(node:GetAttribute("FusionSlot"))
if slot then slots[slot] = node end
if node:IsA("ProximityPrompt") and node.Name == "OpenConsole" and node.Parent:IsA("Attachment") then
console = node.Parent.WorldPosition
end
end
return console, slots
end
function Reicht.Fusion.Near(pos)
return CFrame.new(pos + Vector3.new(0, Reicht.Config.FuseLift, Reicht.Config.FuseStand))
end
function Reicht.Fusion.Candidates(count)
local allowed = Reicht.Util.Opt("FuseRarities")
if type(allowed) ~= "table" or not next(allowed) then return {} end
local floor = Reicht.GameLib.RarityRank[(Reicht.Fusion.Rarities())[1] or ""] or 0
local owned = Reicht.Pets.Owned()
table.sort(owned, function(a, b) return a.income > b.income end)
local keepBest = tonumber(Reicht.Util.Opt("FuseKeepBest")) or 0
local needs = Reicht.Pets.RebirthNeeds()
local picked = {}
for rank = #owned, keepBest + 1, -1 do
if #picked >= count then break end
local pet = owned[rank]
if pet.placed or not pet.tool or not allowed[pet.rarity or ""] then continue end
if (Reicht.GameLib.RarityRank[pet.rarity] or 0) < floor then continue end
if next(Reicht.GameLib.FuseQuality) and not Reicht.GameLib.FuseQuality[pet.name or ""] then continue end
if pet.mutated and Reicht.Util.Opt("FuseKeepMutated") then continue end
if Reicht.Pets.Protected(pet, needs) then continue end
picked[#picked + 1] = pet
end
return picked
end
function Reicht.Fusion.Cost(state)
local raw = state:GetAttribute("FusionPreviewJSON")
if type(raw) ~= "string" or raw == "" then return nil end
local ok, preview = pcall(HttpService.JSONDecode, HttpService, raw)
if not ok or type(preview) ~= "table" then return nil end
return tonumber(preview.FuseCost or preview.Cost or preview.Price)
end
function Reicht.Fusion.PlaceOne(token, state, slot, attach, pet)
local remote = Reicht.GameLib.Remote("FusionPetPlace")
local hum = Reicht.Player.Humanoid
if not remote or not hum or not pet.tool.Parent then return false end
if not Reicht.Tasks.Teleport(token, Reicht.Fusion.Near(attach.WorldPosition)) then return false end
hum:EquipTool(pet.tool)
Reicht.Mount.Dirty = true
local equipped = Reicht.Tasks.Await(token, function() return pet.tool.Parent == Reicht.Player.Char end, Reicht.Config.FuseSettle * 4)
if not equipped then return false end
Reicht.Tasks.Await(token, nil, Reicht.Config.FusePlaceSettle)
if not Reicht.Tasks.Holds(token) or not Reicht.Fusion.Pace(token) then return false end
Reicht.Fusion.Inputs[pet.key] = true
Reicht.Fusion.FiredAt = os.clock()
remote:FireServer(slot)
local filled = Reicht.Tasks.Await(token, function()
return state:FindFirstChild(tostring(slot)) ~= nil
end, Reicht.Config.FuseReplyTimeout)
if not filled then Reicht.Fusion.Inputs[pet.key] = nil end
return filled
end
function Reicht.Fusion.Fill(token, state, slots)
local missing = {}
for index = 1, Reicht.Config.FuseSlots do
if slots[index] and not state:FindFirstChild(tostring(index)) then missing[#missing + 1] = index end
end
if #missing == 0 then return true end
local allowed = Reicht.Util.Opt("FuseRarities")
if type(allowed) ~= "table" or not next(allowed) then
Reicht.Fusion.SetStatus("Pick which rarities to fuse")
return false
end
local pets = Reicht.Fusion.Candidates(#missing)
if #pets < #missing then
Reicht.Fusion.SetStatus("Need " .. (#missing - #pets) .. " more pets to fuse")
return false
end
local done = true
for i, slot in ipairs(missing) do
Reicht.Fusion.SetStatus("Filling slot " .. slot .. " of " .. Reicht.Config.FuseSlots)
if not Reicht.Fusion.PlaceOne(token, state, slot, slots[slot], pets[i]) then
done = false
break
end
end
local hum = Reicht.Player.Humanoid
if hum then hum:UnequipTools() end
return done
end
function Reicht.Fusion.AtConsole(token, console, ...)
local remote = Reicht.GameLib.Remote("FusionAction")
if not remote or select(1, ...) == "SkipPurchase" then return false end
if not Reicht.Tasks.Teleport(token, Reicht.Fusion.Near(console)) then return false end
Reicht.Tasks.Await(token, nil, Reicht.Config.FuseSettle)
if not Reicht.Fusion.Pace(token) then return false end
Reicht.Fusion.FiredAt = os.clock()
remote:FireServer(...)
return true
end
function Reicht.Fusion.ResultKey(state)
if state:GetAttribute("FusionFailed") == true then return state:GetAttribute("FusionResultKey") end
local result = LocalPlayer:FindFirstChild("FusionResult")
local pet = result and result:FindFirstChild("Pet")
return pet and pet:GetAttribute("PetKey") or state:GetAttribute("FusionResultKey")
end
function Reicht.Fusion.Waiting(token, state, console)
local left = (tonumber(state:GetAttribute("EndsAt")) or math.huge) - Reicht.Util.ServerNow()
if left > 0 then
Reicht.Fusion.SetStatus("Fusing, " .. math.ceil(left) .. "s left")
return
end
if Reicht.Fusion.AtConsole(token, console, "Fuse") then Reicht.Fusion.SetStatus("Fusion finished, claiming next") end
end
function Reicht.Fusion.Claim(token, state, console)
local fusion = Reicht.Fusion
local key = fusion.ResultKey(state)
if not key or key == fusion.ClaimedKey then return end
if not fusion.AtConsole(token, console, "Claim", key) then return end
local claimed = Reicht.Tasks.Await(token, function() return state:GetAttribute("FusionStatus") ~= "Result" end, Reicht.Config.FuseResultTimeout)
if not claimed then
fusion.SetStatus("Claim not confirmed; retrying")
return
end
fusion.ClaimedKey = key
fusion.Fused += 1
table.clear(fusion.Inputs)
fusion.SetStatus("Claimed fusion result")
fusion.PutAway(token)
end
function Reicht.Fusion.PutAway(token)
local hum, char = Reicht.Player.Humanoid, Reicht.Player.Char
if not hum or not char or Reicht.Player:Riding() then return false end
Reicht.Tasks.Await(token, function() return char:FindFirstChildOfClass("Tool") ~= nil end, Reicht.Config.DismountToolWindow)
hum:UnequipTools()
return char:FindFirstChildOfClass("Tool") == nil
end
function Reicht.Fusion.StartFuse(token, state, console)
local cost = Reicht.Fusion.Cost(state)
local economy = Reicht.Economy
if cost and economy and economy.Reserve then
economy.Reserve("Fusion", cost)
if economy.Budget("Fusion") < cost then
Reicht.Fusion.SetStatus("Saving $" .. Reicht.Util.Format(cost) .. " to fuse")
return
end
end
local started = Reicht.Fusion.AtConsole(token, console, "Start")
if economy and economy.Reserve then economy.Reserve("Fusion", nil) end
if started then Reicht.Fusion.SetStatus("Fusion started") end
end
function Reicht.Fusion.Run(token)
local state = LocalPlayer:FindFirstChild("FusionSlots")
local console, slots = Reicht.Fusion.Machine()
if not state or not console then
Reicht.Fusion.SetStatus("Fusion machine not found")
return
end
local status = state:GetAttribute("FusionStatus")
if status == "Waiting" then
Reicht.Fusion.Waiting(token, state, console)
return
end
if status == "Result" then
Reicht.Fusion.Claim(token, state, console)
return
end
if not Reicht.Fusion.Fill(token, state, slots) then return end
if state:GetAttribute("Ready") == false then return Reicht.Fusion.SetStatus("Machine is not ready yet") end
Reicht.Fusion.StartFuse(token, state, console)
end
function Reicht.Fusion.Ready()
if (tonumber(Reicht.Pets.Saved("Rebirths")) or 0) < 1 then return false, "Needs one rebirth" end
if not Reicht.Fusion.Active() then return false, "Fusion event is closed" end
return true
end
function Reicht.Fusion.Now()
local ok, why = Reicht.Fusion.Ready()
if not ok then
Reicht.Fusion.SetStatus(why)
return
end
Reicht.Fusion.SetStatus("")
local ran = Reicht.Pets.WithToken("Fusion", Reicht.Tasks.Prio.Plot, function(token)
Reicht.Fusion.Run(token)
if Reicht.Tasks.Holds(token) then Reicht.Pets.GoHome(token) end
return true
end)
if not ran then
Reicht.Fusion.SetStatus("Waiting for a turn")
elseif Reicht.State.Status.Fusion == "" then
Reicht.Fusion.SetStatus("Nothing to fuse")
end
end
function Reicht.Fusion.Step()
if not Reicht.Util.Opt("AutoFusion") then return end
Reicht.Fusion.Now()
end
function Reicht.Fusion.Status()
return Reicht.State.Status.Fusion or ""
end
function Reicht.Fusion.Start() end
function Reicht.Fusion.Stop()
local hum = Reicht.Player.Humanoid
if hum and not Reicht.Player:Riding() then hum:UnequipTools() end
end
Reicht.Economy = {
Reserves = {},
Plan = "",
PendingUpgrade = nil,
PendingRebirth = nil,
UpgradeBlockedUntil = 0,
RebirthBlockedUntil = 0,
}
function Reicht.Economy.Saved(name)
local saved = LocalPlayer:FindFirstChild("SavedData")
local node = saved and saved:FindFirstChild(name)
return node and node.Value
end
function Reicht.Economy.Cash()
return tonumber(Reicht.Economy.Saved("Cash")) or 0
end
function Reicht.Economy.Income()
local stats = LocalPlayer:FindFirstChild("leaderstats")
local node = stats and stats:FindFirstChild("Income/s")
return node and tonumber(node.Value) or 0
end
function Reicht.Economy.Rebirths()
return tonumber(Reicht.Economy.Saved("Rebirths")) or 0
end
function Reicht.Economy.HatchUpgrades()
return tonumber(Reicht.Economy.Saved("HatchUpgrades")) or 0
end
function Reicht.Economy.FreePacks()
local free = tonumber(Reicht.Economy.Saved("FreeHatchUpgrades")) or 0
local used = tonumber(Reicht.Economy.Saved("UsedFreeHatchUpgrades")) or 0
return math.max(free - used, 0)
end
function Reicht.Economy.UpgradePrice(n)
local tier = math.floor(n / 5)
return 5 + 10 * n + 50 * (5 * tier * (tier - 1) / 2 + tier * (n - 5 * tier + 1))
end
function Reicht.Economy.LuckMult()
return GameLib.LuckMult()
end
function Reicht.Economy.Reserve(owner, amount)
if not amount or amount <= 0 then
Reicht.Economy.Reserves[owner] = nil
return
end
Reicht.Economy.Reserves[owner] = amount
end
function Reicht.Economy.Budget(owner)
local budget = Reicht.Economy.Cash() - (tonumber(Reicht.Util.Opt("ShopKeepCash")) or 0)
if not Reicht.Util.Opt("SmartSpend") then return budget end
for holder, amount in pairs(Reicht.Economy.Reserves) do
if holder ~= owner then budget -= amount end
end
return budget
end
function Reicht.Economy.NextRequirement()
local done = Reicht.Economy.Rebirths()
if done >= (Reicht.GameLib.Rebirths.Cap or 0) then return nil end
return Reicht.GameLib.RebirthReq[done + 1]
end
function Reicht.Economy.OwnedPet(name)
if not name then return nil end
for _, pet in ipairs(Reicht.Pets.Owned()) do
if pet.name == name then return pet end
end
return nil
end
function Reicht.Economy.RebirthPlan()
local done = Reicht.Economy.Rebirths()
local target = tonumber(Reicht.Util.Opt("RebirthTarget")) or Reicht.GameLib.Rebirths.Cap or 0
local plan = { cost = math.huge, payback = math.huge }
if done >= math.min(target, Reicht.GameLib.Rebirths.Cap or 0) then
plan.reason = "target reached"
return plan
end
plan.cost = Reicht.GameLib.Rebirths.Costs[done + 1] or math.huge
plan.pet = Reicht.Economy.NextRequirement()
local owned = Reicht.Economy.OwnedPet(plan.pet)
plan.owned = owned ~= nil and Reicht.Pets.Protected(owned) == true
local gain = Reicht.Economy.Income() / GameLib.RebirthMultiplier(done)
if gain > 0 then plan.payback = plan.cost / gain end
if not plan.owned then
plan.reason = "need " .. tostring(plan.pet)
elseif Reicht.Economy.Cash() < plan.cost then
plan.reason = "saving"
else
plan.ready = true
end
return plan
end
function Reicht.Economy.UpgradeCount(budget, income)
local n = Reicht.Economy.HatchUpgrades()
local cap = income * Reicht.Config.UpgradePayback
local count, spent = 0, 0
repeat
local price = Reicht.Economy.UpgradePrice(n + count)
if price >= cap or spent + price > budget then break end
spent += price
count += 1
until count >= Reicht.Config.UpgradeMaxBuy
return count
end
function Reicht.Economy.MaxIsSafe(count)
if Reicht.Util.Opt("SmartSpend") and next(Reicht.Economy.Reserves) then return false end
if (tonumber(Reicht.Util.Opt("ShopKeepCash")) or 0) > 0 then return false end
local n = Reicht.Economy.HatchUpgrades() + count
return Reicht.Economy.UpgradePrice(n) > Reicht.Economy.Cash()
end
function Reicht.Economy.Upgrade()
local remote = Reicht.Net["Plot.Upgrades"]
if not remote then return 0 end
if LocalPlayer:GetAttribute("Setting_LuckMultiplier") == false then
Reicht.State.Status.Upgrade = "Luck upgrades are turned off in game settings"
return 0
end
local before = Reicht.Economy.HatchUpgrades()
if Reicht.Economy.FreePacks() > 0 then remote:FireServer("MaxFree") end
local count = Reicht.Economy.UpgradeCount(Reicht.Economy.Budget("Upgrade"), Reicht.Economy.Income())
if count == 0 then return 0 end
if Reicht.Economy.MaxIsSafe(count) then
remote:FireServer("Max")
else
for i = 1, math.min(count, Reicht.Config.UpgradeBatch) do
remote:FireServer()
if i < count then task.wait(Reicht.Config.UpgradeGap) end
end
end
Reicht.Economy.PendingUpgrade = { before, os.clock() + Reicht.Config.UpgradeVerify }
return count
end
function Reicht.Economy.VerifyUpgrade()
local pending = Reicht.Economy.PendingUpgrade
if not pending then return true end
if os.clock() < pending[2] then return false end
Reicht.Economy.PendingUpgrade = nil
if Reicht.Economy.HatchUpgrades() > pending[1] then return true end
Reicht.Economy.UpgradeBlockedUntil = os.clock() + Reicht.Config.UpgradeBackoff
return false
end
function Reicht.Economy.UpgradeNow()
local count = Reicht.Economy.Upgrade()
Reicht.Util.Notify("Upgrades", count > 0 and ("Buying " .. count .. " luck levels") or "Nothing worth buying now")
end
function Reicht.Economy.Rebirth(plan)
local remote = Reicht.Net.Rebirth
if not (remote and plan.ready) then return false end
if os.clock() < Reicht.Economy.RebirthBlockedUntil or Reicht.Economy.PendingRebirth then return false end
if Reicht.Eggs and Reicht.Eggs.CarryCritical then return false end
Reicht.Economy.PendingRebirth = { Reicht.Economy.Rebirths(), os.clock() + Reicht.Config.RebirthVerify }
remote:FireServer()
return true
end
function Reicht.Economy.VerifyRebirth()
local pending = Reicht.Economy.PendingRebirth
if not pending or os.clock() < pending[2] then return end
Reicht.Economy.PendingRebirth = nil
if Reicht.Economy.Rebirths() > pending[1] then
Reicht.Economy.Reserve("Rebirth", nil)
Reicht.Util.Notify("Rebirth", "Rebirth " .. Reicht.Economy.Rebirths() .. " done")
return
end
Reicht.Economy.RebirthBlockedUntil = os.clock() + Reicht.Config.RebirthBackoff
Reicht.State.Status.Economy = "Rebirth refused, retry in 1 min"
end
function Reicht.Economy.RebirthNow()
local plan = Reicht.Economy.RebirthPlan()
if not Reicht.Economy.Rebirth(plan) then
Reicht.Util.Notify("Rebirth", "Not ready: " .. tostring(plan.reason or "busy"))
end
end
function Reicht.Economy.SaveForRebirth(plan)
if not (Reicht.Util.Opt("AutoRebirth") and Reicht.Util.Opt("SmartSpend")) then
Reicht.Economy.Reserve("Rebirth", nil)
return false
end
if not plan.owned or plan.cost == math.huge then
Reicht.Economy.Reserve("Rebirth", nil)
return false
end
local income = math.max(Reicht.Economy.Income(), 1)
local wait = (plan.cost - Reicht.Economy.Cash()) / income
if wait > Reicht.Config.RebirthSaveWindow then
Reicht.Economy.Reserve("Rebirth", nil)
return false
end
Reicht.Economy.Reserve("Rebirth", plan.cost)
return true
end
function Reicht.Economy.Step()
Reicht.Economy.VerifyRebirth()
local plan = Reicht.Economy.RebirthPlan()
local saving = Reicht.Economy.SaveForRebirth(plan)
if Reicht.Util.Opt("AutoRebirth") and plan.ready then
Reicht.Economy.Rebirth(plan)
Reicht.Economy.Plan = "Rebirthing"
elseif saving then
Reicht.Economy.Plan = "Saving for rebirth (" .. Reicht.Util.Format(plan.cost) .. ")"
else
Reicht.Economy.Plan = plan.reason and ("Rebirth: " .. plan.reason) or ""
end
local upgradeOk = Reicht.Economy.VerifyUpgrade() and os.clock() >= Reicht.Economy.UpgradeBlockedUntil
if Reicht.Util.Opt("AutoUpgrade") and upgradeOk and not saving and not Reicht.Economy.PendingRebirth then
Reicht.Economy.Upgrade()
end
Reicht.State.Status.Economy = Reicht.Economy.Status()
end
function Reicht.Economy.Status()
local luck = "Luck x" .. Reicht.Util.Format(Reicht.Economy.LuckMult())
if Reicht.Economy.Plan == "" then return luck end
return luck .. " | " .. Reicht.Economy.Plan
end
function Reicht.Economy.Stop()
table.clear(Reicht.Economy.Reserves)
Reicht.Economy.PendingUpgrade = nil
Reicht.Economy.PendingRebirth = nil
end
Reicht.Shop = {
Stock = nil,
StockAt = 0,
Signature = nil,
LastCheck = 0,
Conn = nil,
Bought = 0,
}
function Reicht.Shop.Labels()
local labels = {}
for _, entry in ipairs(Reicht.GameLib.ShopItems) do
labels[#labels + 1] = entry.cat .. "/" .. entry.item
end
return labels
end
function Reicht.Shop.Price(category, item)
for _, entry in ipairs(Reicht.GameLib.ShopItems) do
if entry.cat == category and entry.item == item then return entry.price end
end
return math.huge
end
function Reicht.Shop.Bind()
if Reicht.Shop.Conn then return end
local restock = Reicht.GameLib.Listen("Restock")
if not restock then return end
Reicht.Shop.Conn = Reicht:Connect(restock.OnClientEvent, function(stock)
if type(stock) ~= "table" then return end
Reicht.Shop.Stock = stock
Reicht.Shop.StockAt = os.clock()
end)
end
function Reicht.Shop.RestockSignature()
local serverData = ReplicatedStorage:FindFirstChild("ServerData")
if not serverData then return "" end
local parts = {}
for name, value in pairs(serverData:GetAttributes()) do
if name:find("LastRestockTime", 1, true) then table.insert(parts, name .. "=" .. tostring(value)) end
end
for _, child in ipairs(serverData:GetChildren()) do
if child.Name:find("LastRestockTime", 1, true) and child:IsA("ValueBase") then
table.insert(parts, child.Name .. "=" .. tostring(child.Value))
end
end
table.sort(parts)
return table.concat(parts, ";")
end
function Reicht.Shop.ReadStock()
local request = Reicht.Net.ShopStock
if not request then return nil end
Reicht.Shop.Bind()
local asked = os.clock()
request:FireServer()
local deadline = asked + Reicht.Config.ShopReplyTimeout
repeat
if Reicht.Shop.StockAt >= asked then return Reicht.Shop.Stock end
task.wait(0.05)
until os.clock() > deadline
return nil
end
function Reicht.Shop.Buy()
local wanted = Reicht.Util.Opt("ShopItems")
local buy = Reicht.Net.BuyWithCash
if type(wanted) ~= "table" or not next(wanted) or not buy then return 0 end
local stock = Reicht.Shop.ReadStock()
if not stock then return 0 end
local budget, fired = Reicht.Economy.Budget("Shop"), 0
for label, on in pairs(wanted) do
if not on then continue end
local category, item = label:match("^(.-)/(.+)$")
local slot = category and type(stock[category]) == "table" and stock[category][item]
local amount = type(slot) == "table" and tonumber(slot.Amount) or 0
local price = Reicht.Shop.Price(category, item)
for _ = 1, amount do
if budget < price then break end
buy:FireServer(category, item)
budget -= price
fired += 1
task.wait(Reicht.Config.ShopBuyGap)
end
end
Reicht.Shop.Bought += fired
return fired
end
function Reicht.Shop.BuyNow()
local fired = Reicht.Shop.Buy()
Reicht.Util.Notify("Shop", fired > 0 and ("Bought " .. fired .. " items") or "Nothing to buy in stock")
end
function Reicht.Shop.Step()
if not Reicht.Util.Opt("AutoShop") then return end
local signature = Reicht.Shop.RestockSignature()
local stale = os.clock() - Reicht.Shop.LastCheck >= Reicht.Config.ShopRecheck
if signature == Reicht.Shop.Signature and not stale then return end
Reicht.Shop.Signature = signature
Reicht.Shop.LastCheck = os.clock()
Reicht.Shop.Buy()
Reicht.State.Status.Shop = "Bought " .. Reicht.Shop.Bought .. " this session"
end
function Reicht.Shop.Stop()
Reicht.Shop.Signature = nil
Reicht.Shop.LastCheck = 0
end
Reicht.Rewards = {
OfflineDone = false,
PromptAt = {},
PendingIndex = nil,
IndexBlockedUntil = 0,
}
function Reicht.Rewards.IndexCount()
local owned = tostring(Reicht.Economy.Saved("OwnedPets") or "")
if owned == "" then return 0 end
local count = 0
for name in pairs(Reicht.GameLib.PetInfo) do
if owned:find(name .. ",", 1, true) then count += 1 end
end
return count
end
function Reicht.Rewards.IndexReady()
local stage = tonumber(Reicht.Economy.Saved("IndexRewardStage")) or 0
local nextStage = Reicht.GameLib.IndexStages[stage + 1]
if not nextStage then return nil end
if Reicht.Rewards.IndexCount() < nextStage.goal then return nil end
return nextStage
end
function Reicht.Rewards.ClaimIndex()
local remote = Reicht.Net.ClaimIndexReward
if not remote or os.clock() < Reicht.Rewards.IndexBlockedUntil then return false end
if not Reicht.Rewards.IndexReady() then return false end
local stage = tonumber(Reicht.Economy.Saved("IndexRewardStage")) or 0
remote:FireServer()
task.delay(Reicht.Config.ClaimVerify, function()
local now = tonumber(Reicht.Economy.Saved("IndexRewardStage")) or 0
if now <= stage then Reicht.Rewards.IndexBlockedUntil = os.clock() + Reicht.Config.PromptRetry end
end)
return true
end
function Reicht.Rewards.ClaimOffline()
local remote = Reicht.Net.OfflineEarnings
if not remote or Reicht.Rewards.OfflineDone then return false end
if (tonumber(LocalPlayer:GetAttribute("OfflineSeconds")) or 0) <= 0 then return false end
Reicht.Rewards.OfflineDone = true
remote:FireServer()
return true
end
function Reicht.Rewards.FindPrompt(holder)
local functionals = Workspace:FindFirstChild("Functionals")
local model = functionals and functionals:FindFirstChild(holder)
local handle = model and model:FindFirstChild("Handle")
local prompt = handle and handle:FindFirstChild("Claim")
if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then return prompt end
return nil
end
function Reicht.Rewards.TriggerPrompt(prompt)
if Library and Library.Compat and Library.Compat.Caps.Prompt then
return (pcall(fireproximityprompt, prompt))
end
local root = Reicht.Player.Root
local part = prompt.Parent
if not (root and part and part:IsA("BasePart")) then return false end
if (root.Position - part.Position).Magnitude > prompt.MaxActivationDistance then return false end
prompt:InputHoldBegin()
task.wait(prompt.HoldDuration + 0.05)
prompt:InputHoldEnd()
return true
end
function Reicht.Rewards.GroupReady()
local last = tonumber(LocalPlayer:GetAttribute("GroupRewardClaimTime"))
if not last then return true end
return os.time() - last >= Reicht.Config.GroupRewardCooldown
end
function Reicht.Rewards.ClaimPrompts(force)
local fired = 0
local list = {
{ "EventBoost", true },
{ "Meat", Reicht.Rewards.GroupReady() },
}
for _, pair in ipairs(list) do
local holder, ready = pair[1], pair[2]
local due = force or os.clock() - (Reicht.Rewards.PromptAt[holder] or -math.huge) >= Reicht.Config.PromptRetry
if not (ready and due) then continue end
local prompt = Reicht.Rewards.FindPrompt(holder)
if not prompt then continue end
Reicht.Rewards.PromptAt[holder] = os.clock()
if Reicht.Rewards.TriggerPrompt(prompt) then fired += 1 end
end
return fired
end
function Reicht.Rewards.Claim(force)
local fired = 0
if Reicht.Rewards.ClaimIndex() then fired += 1 end
if Reicht.Rewards.ClaimOffline() then fired += 1 end
fired += Reicht.Rewards.ClaimPrompts(force)
return fired
end
function Reicht.Rewards.ClaimNow()
local fired = Reicht.Rewards.Claim(true)
Reicht.Util.Notify("Rewards", fired > 0 and ("Claimed " .. fired .. " rewards") or "Nothing to claim right now")
end
function Reicht.Rewards.Step()
if not Reicht.Util.Opt("AutoClaim") then return end
Reicht.Rewards.Claim(false)
local nextStage = Reicht.GameLib.IndexStages[(tonumber(Reicht.Economy.Saved("IndexRewardStage")) or 0) + 1]
if nextStage then
Reicht.State.Status.Rewards = "Index " .. Reicht.Rewards.IndexCount() .. "/" .. nextStage.goal
else
Reicht.State.Status.Rewards = "Index complete"
end
end
function Reicht.Rewards.Stop()
table.clear(Reicht.Rewards.PromptAt)
end
Reicht.Boosts = {
Last = {},
Lines = {},
Primed = false,
}
function Reicht.Boosts.Describe(name, value)
if value == nil then return nil end
local now = Reicht.Util.ServerNow()
if name:sub(-5) == "Until" then
local left = (tonumber(value) or 0) - now
if left <= 0 then return nil end
return name:gsub("Until$", "") .. ": " .. math.floor(left / 60) .. "m left"
end
local amount = tonumber(value)
if not amount or amount <= 1 then return nil end
return name .. ": x" .. amount
end
function Reicht.Boosts.Read()
local running = {}
for _, name in ipairs(Reicht.Config.BoostAttributes) do
running[name] = Reicht.Boosts.Describe(name, ReplicatedStorage:GetAttribute(name))
end
running.EventBoostUntil = Reicht.Boosts.Describe("EventBoostUntil", LocalPlayer:GetAttribute("EventBoostUntil"))
local serverData = ReplicatedStorage:FindFirstChild("ServerData")
local weather = serverData and serverData:GetAttribute("ActiveWeathers")
local names = Reicht.Boosts.WeatherNames(weather)
if names then running.Weather = "Weather: " .. names end
return running
end
function Reicht.Boosts.WeatherNames(raw)
if type(raw) ~= "string" or raw == "" then return nil end
local ok, list = pcall(HttpService.JSONDecode, HttpService, raw)
if not ok then
warn(Reicht.Config.Tag, "weather decode:", list)
return nil
end
if type(list) ~= "table" then return nil end
local names = {}
for _, entry in pairs(list) do
local kind = type(entry) == "table" and entry.Type or entry
local variant = type(entry) == "table" and entry.Variant
if type(variant) == "string" and variant ~= "" then kind = tostring(kind) .. " (" .. variant .. ")" end
if type(kind) == "string" and not table.find(names, kind) then names[#names + 1] = kind end
end
return #names > 0 and table.concat(names, ", ") or nil
end
function Reicht.Boosts.Announce(name, line)
Reicht.Util.Notify("Boost", line, 8)
local webhook = rawget(Reicht, "Webhook")
if not (webhook and webhook.Push) then return end
Reicht.Util.Try("boost webhook", webhook.Push, { Kind = "Boost", Title = name, Lines = { line } })
end
function Reicht.Boosts.Step()
local running = Reicht.Boosts.Read()
local lines = {}
for name, line in pairs(running) do
table.insert(lines, line)
if Reicht.Boosts.Primed and not Reicht.Boosts.Last[name] then Reicht.Boosts.Announce(name, line) end
end
table.sort(lines)
Reicht.Boosts.Last = running
Reicht.Boosts.Primed = true
Reicht.Boosts.Lines = lines
Reicht.State.Weather = running.Weather and { running.Weather } or {}
Reicht.State.Status.Boosts = #lines > 0 and table.concat(lines, "\n") or "No boosts running"
end
function Reicht.Boosts.Stop()
table.clear(Reicht.Boosts.Last)
Reicht.Boosts.Primed = false
end
Reicht.Prompts = { Active = false, Saved = setmetatable({}, { __mode = "k" }), Connections = {} }
function Reicht.Prompts.Apply(prompt)
local prompts = Reicht.Prompts
if not prompts.Active or not Reicht.State.Alive or not prompt.Parent or not prompt:IsA("ProximityPrompt") then return end
if prompts.Saved[prompt] == nil then prompts.Saved[prompt] = prompt.HoldDuration end
if prompt.HoldDuration ~= 0 then prompt.HoldDuration = 0 end
end
function Reicht.Prompts.Start()
local prompts = Reicht.Prompts
if prompts.Active then return end
prompts.Active = true
local service = game:GetService("ProximityPromptService")
for _, signal in ipairs({ service.PromptShown, service.PromptButtonHoldBegan, Workspace.DescendantAdded }) do
prompts.Connections[#prompts.Connections + 1] = signal:Connect(prompts.Apply)
end
for _, instance in ipairs(Workspace:GetDescendants()) do prompts.Apply(instance) end
end
function Reicht.Prompts.Stop()
local prompts = Reicht.Prompts
prompts.Active = false
for _, connection in ipairs(prompts.Connections) do connection:Disconnect() end
table.clear(prompts.Connections)
for prompt, duration in pairs(prompts.Saved) do
if prompt.Parent then prompt.HoldDuration = duration end
end
table.clear(prompts.Saved)
end
do
local defaults = {
WalkSpeed = 60, JumpPower = 80, FlySpeed = 120,
FlingSpin = 2000, FlingForce = 9e4, StickOffset = 2,
StandLift = 3, StreamTimeout = 5,
EspLift = 4, EspPool = 48,
FloatSize = 52, FloatGap = 8,
ReconnectDelay = 5, ReconnectRetry = 10, ReconnectTries = 6, ReconnectMax = 3, ReconnectWindow = 600,
ReconnectFile = "MarioHub_RideAPet_reconnect.txt",
HopPick = 15, ServerListUrl = "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
ReloadSource = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/loader.lua"))()',
RarityColors = {
Common = Color3.fromRGB(200, 200, 200), Rare = Color3.fromRGB(90, 170, 255), Epic = Color3.fromRGB(190, 110, 255),
Legendary = Color3.fromRGB(255, 200, 60), Mythic = Color3.fromRGB(255, 90, 90), Divine = Color3.fromRGB(120, 255, 220),
Ethereal = Color3.fromRGB(255, 130, 230),
},
}
for key, value in pairs(defaults) do
if Config[key] == nil then Config[key] = value end
end
end
Reicht.World = { Conn = nil, Gui = nil }
function Reicht.World.GuiRoot()
local caps = Library and Library.Compat and Library.Compat.Caps
if caps and caps.Hui then
local ok, hui = pcall(gethui)
if ok and typeof(hui) == "Instance" then return hui end
end
local ok, core = pcall(function() return game:GetService("CoreGui") end)
if ok and core and pcall(function() return core.Name end) then return core end
return LocalPlayer:WaitForChild("PlayerGui", Config.LoadTimeout)
end
function Reicht.World.Screen()
local gui = Reicht.World.Gui
if gui and gui.Parent then return gui end
gui = Instance.new("ScreenGui")
gui.Name = "MarioWorld"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() gui.Parent = Reicht.World.GuiRoot() end)
if not ok then gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end
Reicht.World.Gui = gui
return gui
end
function Reicht.World.NeedsFrame()
local opt = Reicht.Util.Opt
return opt("SpeedOn") or opt("JumpOn") or opt("Fly") or opt("NoClip") or opt("Fling") or opt("Stick") or false
end
function Reicht.World.Sync()
local world = Reicht.World
if world.NeedsFrame() then
if world.Conn then return end
world.Conn = Reicht:Connect(RunService.Heartbeat, function(dt)
Reicht.Util.Try("Move.Frame", Reicht.Move.Frame, dt)
Reicht.Util.Try("Troll.Frame", Reicht.Troll.Frame)
end)
return
end
if world.Conn then
world.Conn:Disconnect()
world.Conn = nil
end
end
function Reicht.World.Carrying()
return Reicht.Tasks.Carrying()
end
Reicht.Teleport = {}
local GroundRay = RaycastParams.new()
GroundRay.FilterType = Enum.RaycastFilterType.Exclude
GroundRay.RespectCanCollide = true
local GroundRayOf = nil
local function GroundCF(pos)
local char = Reicht.Player.Char
if GroundRayOf ~= char then
GroundRayOf = char
GroundRay.FilterDescendantsInstances = { char or Workspace }
end
local origin = pos + Vector3.new(0, Config.GroundRayUp, 0)
local hit = Workspace:Raycast(origin, Vector3.new(0, -(Config.GroundRayUp + Config.GroundRayDown), 0), GroundRay)
if hit then
return CFrame.new(hit.Position + Vector3.new(0, Config.StandLift, 0))
end
return CFrame.new(pos)
end
local function Above(part)
return GroundCF(part.Position + Vector3.new(0, part.Size.Y / 2 + Config.StandLift, 0))
end
function Reicht.Teleport.Places()
local places = {}
places["My Plot"] = function()
local _, bp = Reicht.Player:Plot()
return bp and Above(bp)
end
local spawns = Workspace:FindFirstChild("EggSpawns")
local seen = {}
for _, pad in ipairs(spawns and spawns:GetChildren() or {}) do
if not pad:IsA("BasePart") then continue end
local rarity = pad.Name:gsub("%-+$", "")
seen[rarity] = (seen[rarity] or 0) + 1
places["Eggs: " .. rarity .. " #" .. seen[rarity]] = function() return Above(pad) end
end
for _, folderName in ipairs({ "Stalls", "Functionals" }) do
local folder = Workspace:FindFirstChild(folderName)
for _, spot in ipairs(folder and folder:GetChildren() or {}) do
if not (spot:IsA("Model") or spot:IsA("BasePart")) then continue end
if spot.Name:find("^AlwaysStream") then continue end
places[folderName .. ": " .. spot.Name] = function()
return GroundCF(spot:GetPivot().Position + Vector3.new(0, Config.StandLift, 0))
end
end
end
local plots = Workspace:FindFirstChild("Plots")
for _, plot in ipairs(plots and plots:GetChildren() or {}) do
local owner = plot:FindFirstChild("Data") and plot.Data:FindFirstChild("Owner")
local player = owner and owner.Value
local bp = plot:FindFirstChild("Baseplate")
if not bp or not player or player == LocalPlayer then continue end
places["Plot: " .. player.Name] = function() return Above(bp) end
end
places["Volcano"] = Reicht.Teleport.VolcanoSpot
local halloween = rawget(Reicht, "Halloween")
if halloween and halloween.Places then
for label, getter in pairs(halloween.Places()) do
places[label] = getter
end
end
return places
end
function Reicht.Teleport.VolcanoSpot()
local center = Config.VolcanoCenter
pcall(LocalPlayer.RequestStreamAroundAsync, LocalPlayer, center, Config.StreamTimeout)
local tagged = game:GetService("CollectionService"):GetTagged("VolcanoTop")
for _, part in ipairs(tagged) do
if part:IsA("BasePart") then return Above(part) end
end
return CFrame.new(center)
end
function Reicht.Teleport.PlaceNames()
local rank = GameLib.RarityRank
local names = {}
for name in pairs(Reicht.Teleport.Places()) do
names[#names + 1] = name
end
table.sort(names, function(a, b)
local ra = rank[a:match("^Eggs: (.-) #") or ""] or 0
local rb = rank[b:match("^Eggs: (.-) #") or ""] or 0
if ra ~= rb then return ra < rb end
return a < b
end)
return names
end
function Reicht.Teleport.Go(cf)
if not cf then return false end
if Reicht.World.Carrying() then
Reicht.Util.Notify("Teleport", "Finish the egg delivery first")
return false
end
local token = Reicht.Tasks.Request("Manual", Reicht.Tasks.Prio.Manual)
if not token then
Reicht.Util.Notify("Teleport", "Busy with farming, try again in a moment")
return false
end
token.home = nil
local moved = Reicht.Tasks.Teleport(token, cf)
Reicht.Tasks.Release(token)
return moved
end
function Reicht.Teleport.To(name)
local getter = Reicht.Teleport.Places()[name or ""]
if not getter then return false end
return Reicht.Teleport.Go(getter())
end
function Reicht.Teleport.ToPlayer(name)
local target = Players:FindFirstChild(name or "")
if not target or target == LocalPlayer then return false end
local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
if not hrp then
Reicht.Util.Notify("Teleport", target.Name .. " is too far to see right now")
return false
end
return Reicht.Teleport.Go(hrp.CFrame + Vector3.new(0, Config.StandLift, 0))
end
function Reicht.Teleport.Home()
return Reicht.Teleport.To("My Plot")
end
Reicht.Move = { Saved = {}, Patched = {}, Parts = {}, PartsOf = nil, Conns = {}, Floats = {}, FlyWarned = false }
function Reicht.Move.Set(idx, on)
Reicht.Options[idx] = on
local move = Reicht.Move
local hum = Reicht.Player.Humanoid
if on and hum then
if idx == "SpeedOn" and move.Saved.WalkSpeed == nil then move.Saved.WalkSpeed = hum.WalkSpeed end
if idx == "JumpOn" and move.Saved.JumpPower == nil then
move.Saved.JumpPower, move.Saved.UseJumpPower = hum.JumpPower, hum.UseJumpPower
end
end
if idx == "InfJump" then move.BindJump(on) end
if idx == "AntiAfk" then move.BindIdle(on) end
if not on then move.Restore(idx) end
Reicht.World.Sync()
end
function Reicht.Move.BindJump(on)
local move = Reicht.Move
if move.Conns.Jump then
move.Conns.Jump:Disconnect()
move.Conns.Jump = nil
end
if not on then return end
move.Conns.Jump = Reicht:Connect(UserInputService.JumpRequest, function()
local hum = Reicht.Player.Humanoid
if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
end
function Reicht.Move.BindIdle(on)
local move = Reicht.Move
if move.Conns.Idle then
move.Conns.Idle:Disconnect()
move.Conns.Idle = nil
end
if not on then return end
move.Conns.Idle = Reicht:Connect(LocalPlayer.Idled, function()
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
end)
end
function Reicht.Move.CharParts()
local move, char = Reicht.Move, Reicht.Player.Char
if move.PartsOf == char then return move.Parts end
table.clear(move.Parts)
move.PartsOf = char
for _, part in ipairs(char and char:GetDescendants() or {}) do
if part:IsA("BasePart") then move.Parts[#move.Parts + 1] = part end
end
return move.Parts
end
function Reicht.Move.NoClip(on)
local patched = Reicht.Move.Patched
if not on then
for part in pairs(patched) do
if part.Parent then part.CanCollide = true end
end
table.clear(patched)
return
end
for _, part in ipairs(Reicht.Move.CharParts()) do
if part.Parent and part.CanCollide then
patched[part] = true
part.CanCollide = false
end
end
end
function Reicht.Move.FlyDirection(hum, cam)
local look = cam.CFrame.LookVector
local dir = hum.MoveDirection
if dir.Magnitude > 0 then
local flat = Vector3.new(look.X, 0, look.Z)
local forward = flat.Magnitude > 0 and dir:Dot(flat.Unit) or 0
dir += Vector3.new(0, look.Y * forward, 0)
end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
return dir
end
function Reicht.Move.FlyStep(dt)
local hrp, hum = Reicht.Player.Root, Reicht.Player.Humanoid
local cam = Workspace.CurrentCamera
if not hrp or not hum or not cam then return end
if Reicht.World.Carrying() or Reicht.Tasks.Owner() then
if not Reicht.Move.FlyWarned and Reicht.World.Carrying() then
Reicht.Move.FlyWarned = true
Reicht.Util.Notify("Fly", "Fly pauses while you carry an egg")
end
return
end
Reicht.Move.FlyWarned = false
hrp.AssemblyLinearVelocity = Vector3.zero
local dir = Reicht.Move.FlyDirection(hum, cam)
if dir.Magnitude == 0 then return end
hrp.CFrame += dir.Unit * (tonumber(Reicht.Util.Opt("FlySpeed")) or Config.FlySpeed) * dt
end
function Reicht.Move.Frame(dt)
local opt = Reicht.Util.Opt
local hum = Reicht.Player.Humanoid
if opt("NoClip") or opt("Fly") or opt("Fling") then Reicht.Move.NoClip(true) end
if opt("Fly") then Reicht.Move.FlyStep(dt) end
if not hum then return end
if opt("SpeedOn") then hum.WalkSpeed = tonumber(opt("WalkSpeed")) or Config.WalkSpeed end
if opt("JumpOn") then
hum.UseJumpPower = true
hum.JumpPower = tonumber(opt("JumpPower")) or Config.JumpPower
end
end
function Reicht.Move.Restore(idx)
local move, opt = Reicht.Move, Reicht.Util.Opt
local hum, hrp = Reicht.Player.Humanoid, Reicht.Player.Root
if hum and (idx == nil or idx == "SpeedOn") and move.Saved.WalkSpeed then
hum.WalkSpeed = move.Saved.WalkSpeed
move.Saved.WalkSpeed = nil
end
if hum and (idx == nil or idx == "JumpOn") and move.Saved.JumpPower then
hum.JumpPower = move.Saved.JumpPower
hum.UseJumpPower = move.Saved.UseJumpPower
move.Saved.JumpPower, move.Saved.UseJumpPower = nil, nil
end
if idx == nil or not (opt("NoClip") or opt("Fly") or opt("Fling")) then move.NoClip(false) end
if (idx == nil or idx == "Fly") and hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
if idx == nil then
move.BindJump(false)
move.BindIdle(false)
move.ClearFloats()
Reicht.Esp.Clear()
if Reicht.World.Gui then
Reicht.World.Gui:Destroy()
Reicht.World.Gui = nil
end
if Reicht.World.Conn then
Reicht.World.Conn:Disconnect()
Reicht.World.Conn = nil
end
end
end
function Reicht.Move.BuildFloats(list)
if not Reicht.Platform.Touch then return end
local move = Reicht.Move
move.ClearFloats()
local screen = Reicht.World.Screen()
local size, gap = Config.FloatSize, Config.FloatGap
for i, row in ipairs(list) do
local button = move.FloatButton(screen, row[1], row[2])
button.Position = UDim2.new(1, -(size + gap) * 2, 0.3, (i - 1) * (size + gap))
table.insert(move.Floats, button)
end
end
function Reicht.Move.FloatButton(screen, idx, text)
local button = Instance.new("TextButton")
button.Name = "Float_" .. idx
button.Size = UDim2.fromOffset(Config.FloatSize, Config.FloatSize)
button.BackgroundColor3 = Color3.fromRGB(27, 21, 18)
button.BackgroundTransparency = 0.25
button.TextColor3 = Color3.fromRGB(232, 160, 76)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Text = text
button.Active = true
button.Draggable = true
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
button.Parent = screen
local pressedAt
button.MouseButton1Down:Connect(function() pressedAt = button.AbsolutePosition end)
button.MouseButton1Up:Connect(function()
if pressedAt and (button.AbsolutePosition - pressedAt).Magnitude > 6 then return end
local option = Library and Library.Options and Library.Options[idx]
if option then option:SetValue(not option.Value) end
end)
return button
end
function Reicht.Move.ClearFloats()
for _, button in ipairs(Reicht.Move.Floats) do
button:Destroy()
end
table.clear(Reicht.Move.Floats)
end
Reicht.Troll = { Token = nil, Home = nil }
function Reicht.Troll.TargetRoot()
local target = Players:FindFirstChild(Reicht.Util.Opt("TrollTarget") or "")
if not target or target == LocalPlayer then return nil end
return target.Character and target.Character:FindFirstChild("HumanoidRootPart")
end
function Reicht.Troll.Set(idx, on)
Reicht.Options[idx] = on
if on and Reicht.World.Carrying() then
Reicht.Util.Notify("Troll", "Finish the egg delivery first")
table.insert(State.PendingToggleOff, idx)
Reicht.Options[idx] = false
return
end
if not on then Reicht.Troll.Stop(idx) end
Reicht.World.Sync()
end
function Reicht.Troll.Hold()
local troll = Reicht.Troll
if troll.Token and Reicht.Tasks.Holds(troll.Token) then return troll.Token end
troll.Token = nil
if Reicht.World.Carrying() then return nil end
local token = Reicht.Tasks.Request("Troll", Reicht.Tasks.Prio.Manual)
if not token then return nil end
token.home = nil
troll.Token = token
return token
end
function Reicht.Troll.Frame()
local opt = Reicht.Util.Opt
if not opt("Fling") and not opt("Stick") then return end
local target, hrp = Reicht.Troll.TargetRoot(), Reicht.Player.Root
if not target or not hrp then return end
if not Reicht.Troll.Hold() then return end
Reicht.Troll.Home = Reicht.Troll.Home or hrp.CFrame
if opt("Fling") then
local spin = math.rad(os.clock() * Config.FlingSpin % 360)
hrp.CFrame = target.CFrame * CFrame.Angles(0, spin, 0)
hrp.AssemblyLinearVelocity = Vector3.new(0, Config.FlingForce, 0)
hrp.AssemblyAngularVelocity = Vector3.new(0, Config.FlingForce, 0)
return
end
hrp.CFrame = target.CFrame * CFrame.new(0, 0, Config.StickOffset)
end
function Reicht.Troll.Stop(idx)
local troll, hrp = Reicht.Troll, Reicht.Player.Root
if hrp then
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
end
if idx then Reicht.Move.Restore(idx) end
local opt = Reicht.Util.Opt
if idx and (opt("Fling") or opt("Stick")) then return end
local token = troll.Token
troll.Token = nil
if token and Reicht.Tasks.Holds(token) then
if troll.Home then Reicht.Tasks.Teleport(token, troll.Home) end
Reicht.Tasks.Release(token)
end
troll.Home = nil
if idx == nil then Reicht.Troll.Spectate(nil) end
end
function Reicht.Troll.Spectate(name)
local cam = Workspace.CurrentCamera
if not cam then return end
local target = name and Players:FindFirstChild(name)
local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
cam.CameraSubject = hum or Reicht.Player.Humanoid
local troll = Reicht.Troll
if troll.LeaveConn then
troll.LeaveConn:Disconnect()
troll.LeaveConn = nil
end
if not hum then return end
troll.LeaveConn = Reicht:Connect(Players.PlayerRemoving, function(player)
if player == target then Reicht.Troll.Spectate(nil) end
end)
end
Reicht.Server = { Hopping = false }
function Reicht.Server.QueueReload()
return Reicht.Util.Queue(Config.ReloadSource)
end
function Reicht.Server.Rejoin()
if Reicht.World.Carrying() then
Reicht.Util.Notify("Server", "Finish the egg delivery first")
return false
end
Reicht.Server.QueueReload()
local ok, err = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, LocalPlayer)
if not ok then warn(Config.Tag, "rejoin:", err) end
return ok
end
function Reicht.Server.OpenServers()
local body = Reicht.Util.HttpGet(Config.ServerListUrl:format(game.PlaceId))
local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body or "")
local open = {}
if not ok or type(decoded) ~= "table" then return open end
for _, server in ipairs(decoded.data or {}) do
local playing, cap = tonumber(server.playing) or 0, tonumber(server.maxPlayers) or 0
if server.id ~= game.JobId and playing < cap then table.insert(open, server.id) end
end
return open
end
function Reicht.Server.Hop()
local server = Reicht.Server
if server.Hopping then return false end
if Reicht.World.Carrying() then
Reicht.Util.Notify("Server", "Finish the egg delivery first")
return false
end
server.Hopping = true
task.delay(Config.LoadTimeout, function() server.Hopping = false end)
server.QueueReload()
local open = server.OpenServers()
local ok, err
if #open > 0 then
local pick = open[math.random(1, math.min(#open, Config.HopPick))]
ok, err = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, pick, LocalPlayer)
else
ok, err = pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
end
if not ok then warn(Config.Tag, "hop:", err) end
return ok
end
Reicht.Server.IdleKeepers = { "AntiAfk", "AutoEggs", "EggHunter", "Kaitun" }
function Reicht.Server.ReconnectBudget()
if not (Library and Library.Compat and Library.Compat.Caps.FileSystem) then return true end
local now, recent = os.time(), {}
local ok, raw = pcall(readfile, Config.ReconnectFile)
for stamp in (ok and tostring(raw) or ""):gmatch("%d+") do
if now - tonumber(stamp) < Config.ReconnectWindow then recent[#recent + 1] = stamp end
end
if #recent >= Config.ReconnectMax then return false end
recent[#recent + 1] = tostring(now)
local wrote, err = pcall(writefile, Config.ReconnectFile, table.concat(recent, ","))
if not wrote then warn(Config.Tag, "reconnect log:", err) end
return true
end
function Reicht.Server.OnError()
local server = Reicht.Server
local message = GuiService:GetErrorMessage()
if server.Reconnecting or message == "" or not Reicht.Util.Opt("AutoReconnect") then return end
if message:lower():find("ban") then return end
server.Reconnecting = true
task.delay(Config.ReconnectDelay, function()
if not server.ReconnectBudget() then
warn(Config.Tag, "reconnect: too many disconnects, staying out")
return
end
server.QueueReload()
for _ = 1, Config.ReconnectTries do
local ok, err = pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
if not ok then warn(Config.Tag, "reconnect:", err) end
task.wait(Config.ReconnectRetry)
end
end)
end
function Reicht.Server.Step()
local server = Reicht.Server
if not server.ErrorConn and Reicht.Util.Opt("AutoReconnect") then
server.ErrorConn = Reicht:Connect(GuiService.ErrorMessageChanged, server.OnError)
end
local want = false
for _, idx in ipairs(Reicht.Server.IdleKeepers) do
if Reicht.Util.Opt(idx) then want = true break end
end
if want ~= (Reicht.Move.Conns.Idle ~= nil) then Reicht.Move.BindIdle(want) end
end
function Reicht.Server.Stop()
Reicht.Server.Hopping = false
end
Reicht.Esp = { Boards = {}, Pool = {}, Anchors = {}, Made = {} }
function Reicht.Esp.Color(rarity)
local preset = Config.RarityColors[rarity]
if preset then return preset end
local rank = GameLib.RarityRank[rarity]
if not rank then return Color3.new(1, 1, 1) end
return Color3.fromHSV(rank / math.max(#GameLib.RarityOrder, 1) * 0.85, 0.55, 1)
end
function Reicht.Esp.Take()
local spare = table.remove(Reicht.Esp.Pool)
if spare then return spare end
local anchor = Instance.new("Attachment")
anchor.Name = "MarioEspAnchor"
anchor.Parent = Workspace.Terrain
local board = Instance.new("BillboardGui")
board.Name = "MarioEsp"
board.AlwaysOnTop = true
board.Size = UDim2.fromOffset(Reicht.Platform.Mobile and 150 or 200, Reicht.Platform.Mobile and 30 or 40)
board.StudsOffset = Vector3.new(0, Config.EspLift, 0)
board.Adornee = anchor
local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Size = UDim2.fromScale(1, 1)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.TextStrokeTransparency = 0.3
label.Parent = board
board.Parent = Reicht.World.Screen()
local slot = { board = board, label = label, anchor = anchor }
Reicht.Esp.Made[slot] = true
return slot
end
function Reicht.Esp.Give(guid)
local esp = Reicht.Esp
local slot = esp.Boards[guid]
if not slot then return end
esp.Boards[guid] = nil
if #esp.Pool >= Config.EspPool then
esp.Drop(slot)
return
end
slot.board.Enabled = false
table.insert(esp.Pool, slot)
end
function Reicht.Esp.Disown(boards, key)
local esp = Reicht.Esp
local slot = boards[key]
if not slot then return end
boards[key] = nil
if #esp.Pool >= Config.EspPool then
esp.Drop(slot)
return
end
slot.board.Enabled = false
table.insert(esp.Pool, slot)
end
function Reicht.Esp.Shows(entry, minRank)
if entry.removed or not entry.egg or typeof(entry.pos) ~= "Vector3" then return false end
if entry.privateTo and entry.privateTo ~= LocalPlayer.UserId then return false end
local info = GameLib.EggInfo[entry.egg]
return info ~= nil and (GameLib.RarityRank[info.rarity] or 1) >= minRank
end
function Reicht.Esp.Drop(slot)
Reicht.Esp.Made[slot] = nil
slot.board:Destroy()
slot.anchor:Destroy()
end
function Reicht.Esp.Step()
if not Reicht.State.Alive or not Reicht.Util.Opt("EggEsp") then return end
if not Reicht.EggIndex.Start() then return end
local esp = Reicht.Esp
local hrp = Reicht.Player.Root
local range = Reicht.Platform.Mobile and Config.EspRangeMobile or Config.EspRange
local minRank = GameLib.RarityRank[Reicht.Util.Opt("EspMinRarity") or ""] or 1
local seen = {}
for guid, entry in pairs(Reicht.EggIndex.Entries) do
if not esp.Shows(entry, minRank) then continue end
local dist = hrp and (entry.pos - hrp.Position).Magnitude or 0
if dist > range then continue end
seen[guid] = true
local slot = esp.Boards[guid]
if not slot then
slot = esp.Take()
esp.Boards[guid] = slot
end
local info = GameLib.EggInfo[entry.egg]
local mutation = entry.mutation and entry.mutation ~= "" and (" " .. entry.mutation) or ""
slot.anchor.WorldPosition = entry.pos
slot.board.MaxDistance = range
slot.board.Enabled = true
slot.label.TextColor3 = esp.Color(info.rarity)
slot.label.Text = string.format("%s [%s]%s\n%.2fkg | %dm", entry.egg, info.rarity, mutation, entry.weight or 1, math.floor(dist))
end
for guid in pairs(esp.Boards) do
if not seen[guid] then esp.Give(guid) end
end
end
function Reicht.Esp.Clear()
local esp = Reicht.Esp
for slot in pairs(esp.Made) do
esp.Drop(slot)
end
table.clear(esp.Boards)
table.clear(esp.Pool)
end
function Reicht.Esp.Stop()
Reicht.Esp.Clear()
end
do
local defaults = {
OwnPetReach = 25, BoostBatch = 400, FpsCapDefault = 240, FpsCapRestore = 60,
BoostClasses = { ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true },
}
for key, value in pairs(defaults) do
if Config[key] == nil then Config[key] = value end
end
end
Reicht.Visual = {
Holder = Instance.new("Folder"),
Conns = { Pets = {}, Eggs = {}, Boost = {} },
Hidden = { Pets = {}, Eggs = {} },
Disabled = {}, Props = {},
BoostToken = 0,
PetSetting = nil,
CapOn = false,
}
function Reicht.Visual.Drop(kind)
local list = Reicht.Visual.Conns[kind]
for _, conn in ipairs(list) do conn:Disconnect() end
table.clear(list)
end
function Reicht.Visual.Watch(kind, signal, handler)
table.insert(Reicht.Visual.Conns[kind], Reicht:Connect(signal, handler))
end
function Reicht.Visual.Hide(kind, model)
local hidden = Reicht.Visual.Hidden[kind]
if hidden[model] or not model.Parent then return end
hidden[model] = model.Parent
model.Parent = Reicht.Visual.Holder
end
function Reicht.Visual.Show(kind, model)
local hidden = Reicht.Visual.Hidden[kind]
local home = hidden[model]
if not home then return end
hidden[model] = nil
if model.Parent ~= Reicht.Visual.Holder or not home.Parent then return end
pcall(function() model.Parent = home end)
end
function Reicht.Visual.ShowAll(kind)
local models = {}
for model in pairs(Reicht.Visual.Hidden[kind]) do models[#models + 1] = model end
for _, model in ipairs(models) do Reicht.Visual.Show(kind, model) end
end
function Reicht.Visual.ForeignPet(model)
if not model:IsA("Model") or model:GetAttribute("Ridden") ~= true then return false end
local ownerId = model:GetAttribute("OwnerUserId")
if ownerId ~= nil then return ownerId ~= LocalPlayer.UserId end
local owner = model:GetAttribute("Owner")
if owner ~= nil then return owner ~= LocalPlayer.UserId and owner ~= LocalPlayer.Name end
local char = LocalPlayer.Character
if char and model:IsDescendantOf(char) then return false end
if LocalPlayer:GetAttribute("IsRiding") ~= true then return true end
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not hrp then return false end
return (model:GetPivot().Position - hrp.Position).Magnitude > Config.OwnPetReach
end
function Reicht.Visual.TrackPet(model)
if not model:IsA("Model") then return end
Reicht.Visual.Watch("Pets", model:GetAttributeChangedSignal("Ridden"), function()
if model:GetAttribute("Ridden") == true then
if Reicht.Visual.ForeignPet(model) then Reicht.Visual.Hide("Pets", model) end
else
Reicht.Visual.Show("Pets", model)
end
end)
if Reicht.Visual.ForeignPet(model) then Reicht.Visual.Hide("Pets", model) end
end
function Reicht.Visual.HidePets(on)
Reicht.Visual.Drop("Pets")
local remote = Reicht.GameLib.Remote("UpdateSetting")
if not on then
Reicht.Visual.ShowAll("Pets")
if remote and Reicht.Visual.PetSetting ~= nil then remote:FireServer("ViewOtherPets", Reicht.Visual.PetSetting) end
Reicht.Visual.PetSetting = nil
return
end
if remote and Reicht.Visual.PetSetting == nil then
Reicht.Visual.PetSetting = LocalPlayer:GetAttribute("Setting_ViewOtherPets") ~= false
remote:FireServer("ViewOtherPets", false)
end
local objects = Workspace:FindFirstChild("GameObjects")
if not objects then return end
for _, model in ipairs(objects:GetChildren()) do Reicht.Visual.TrackPet(model) end
Reicht.Visual.Watch("Pets", objects.ChildAdded, Reicht.Visual.TrackPet)
end
function Reicht.Visual.HideEggs(on)
Reicht.Visual.Drop("Eggs")
if not on then return Reicht.Visual.ShowAll("Eggs") end
local plots = Workspace:FindFirstChild("Plots")
if not plots then return end
for _, plot in ipairs(plots:GetChildren()) do
local owner = plot:FindFirstChild("Data") and plot.Data:FindFirstChild("Owner")
local eggs = plot:FindFirstChild("Eggs")
if not owner or not eggs or owner.Value == LocalPlayer then continue end
for _, egg in ipairs(eggs:GetChildren()) do
if egg:IsA("Model") then Reicht.Visual.Hide("Eggs", egg) end
end
Reicht.Visual.Watch("Eggs", eggs.ChildAdded, function(egg)
if egg:IsA("Model") and owner.Value ~= LocalPlayer then Reicht.Visual.Hide("Eggs", egg) end
end)
end
end
function Reicht.Visual.SetProp(target, prop, value)
local key = target:GetFullName() .. "." .. prop
local props = Reicht.Visual.Props
local ok, old = pcall(function() return target[prop] end)
if not ok then return end
if not props[key] then props[key] = { target, prop, old } end
pcall(function() target[prop] = value end)
end
function Reicht.Visual.Mute(inst)
if not Config.BoostClasses[inst.ClassName] or Reicht.Visual.Disabled[inst] ~= nil then return end
local char = LocalPlayer.Character
if char and inst:IsDescendantOf(char) then return end
if not inst.Enabled then return end
Reicht.Visual.Disabled[inst] = true
inst.Enabled = false
end
function Reicht.Visual.Sweep(token)
local list = Workspace:GetDescendants()
for i, inst in ipairs(list) do
if Reicht.Visual.BoostToken ~= token then return end
Reicht.Visual.Mute(inst)
if i % Config.BoostBatch == 0 then task.wait() end
end
end
function Reicht.Visual.Boost(on)
Reicht.Visual.Drop("Boost")
Reicht.Visual.BoostToken += 1
if not on then
for inst in pairs(Reicht.Visual.Disabled) do
if inst.Parent then pcall(function() inst.Enabled = true end) end
end
table.clear(Reicht.Visual.Disabled)
for _, row in pairs(Reicht.Visual.Props) do
pcall(function() row[1][row[2]] = row[3] end)
end
table.clear(Reicht.Visual.Props)
return
end
local lighting = game:GetService("Lighting")
local terrain = Workspace:FindFirstChildOfClass("Terrain")
Reicht.Visual.SetProp(lighting, "GlobalShadows", false)
for _, holder in ipairs({ lighting, Workspace.CurrentCamera }) do
for _, effect in ipairs(holder and holder:GetChildren() or {}) do
if effect:IsA("PostEffect") then Reicht.Visual.SetProp(effect, "Enabled", false) end
end
end
if terrain then
Reicht.Visual.SetProp(terrain, "Decoration", false)
Reicht.Visual.SetProp(terrain, "WaterWaveSize", 0)
Reicht.Visual.SetProp(terrain, "WaterReflectance", 0)
end
pcall(function() Reicht.Visual.SetProp(settings().Rendering, "QualityLevel", Enum.QualityLevel.Level01) end)
Reicht.Visual.Watch("Boost", Workspace.DescendantAdded, Reicht.Visual.Mute)
task.spawn(Reicht.Visual.Sweep, Reicht.Visual.BoostToken)
end
function Reicht.Visual.Cap(on)
local visual = Reicht.Visual
if on and not visual.CapOn then
local ok, before = pcall(function() return getfpscap() end)
visual.CapBefore = ok and tonumber(before) or nil
end
visual.CapOn = on
local fps = on and (tonumber(Reicht.Options.FpsCap) or Config.FpsCapDefault) or (visual.CapBefore or Config.FpsCapRestore)
return Reicht.Util.SetFpsCap(fps)
end
function Reicht.Visual.Render(on)
RunService:Set3dRenderingEnabled(not on)
end
function Reicht.Visual.Stop()
local try = Reicht.Util.Try
try("visual pets", Reicht.Visual.HidePets, false)
try("visual eggs", Reicht.Visual.HideEggs, false)
try("visual boost", Reicht.Visual.Boost, false)
if Reicht.Visual.CapOn then try("visual cap", Reicht.Visual.Cap, false) end
try("visual render", Reicht.Visual.Render, false)
end
do
local defaults = {
WebhookPattern = "^https://[%w%.]*discord[app]*%.com/api/webhooks/%d+/[%w_%-]+$",
WebhookGap = 1.2, WebhookQueueMax = 20,
WebhookAvatarApi = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png",
WebhookIcons = { Egg = "🥚", Server = "📡", Magma = "🌋", Pet = "🐾", Rebirth = "♻️", Kick = "⚠️", Report = "📊", Test = "✅", Fail = "🛑" },
WebhookColors = { Egg = 0xE8A04C, Pet = 0x7DD87D, Magma = 0xFF5A2A, Server = 0xFF82E6, Rebirth = 0x5AB4FF, Kick = 0xE04848, Report = 0x9AA4B0, Test = 0xE8A04C, Fail = 0xE04848 },
}
for key, value in pairs(defaults) do
if Config[key] == nil then Config[key] = value end
end
end
Reicht.Webhook = {
Events = { "Rare Egg Picked", "Rare Egg In Server", "Magma Dip", "Pet Hatched", "Rebirth", "Egg Returned", "Kicked", "Status Report" },
Queue = {}, Sending = false, Booted = false,
SeenPets = {}, SeenEggs = {},
LastReport = os.clock(), StartedAt = os.clock(),
Avatar = nil, Baseline = nil, Conns = {},
Counts = { Eggs = 0, Rare = 0, Dips = 0, Magma = 0, Pets = 0 },
}
function Reicht.Webhook.Valid(url)
return type(url) == "string" and url:match(Config.WebhookPattern) ~= nil
end
function Reicht.Webhook.Wants(event)
local opt = Reicht.Util.Opt
if opt("Webhook") == false then return false end
if not Reicht.Webhook.Valid(opt("WebhookUrl")) then return false end
local events = opt("WebhookEvents")
return type(events) == "table" and events[event] == true
end
function Reicht.Webhook.Color(rarity, kind)
local color = rarity and Config.RarityColors and Config.RarityColors[rarity]
if not color then return Config.WebhookColors[kind] or Config.WebhookColors.Report end
return math.floor(color.R * 255) * 65536 + math.floor(color.G * 255) * 256 + math.floor(color.B * 255)
end
function Reicht.Webhook.Duration(seconds)
seconds = math.max(0, math.floor(seconds))
local hours, minutes = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60)
if hours > 0 then return string.format("%dh %02dm", hours, minutes) end
return string.format("%dm %02ds", minutes, seconds % 60)
end
function Reicht.Webhook.AvatarUrl()
local hook = Reicht.Webhook
if hook.Avatar ~= nil then return hook.Avatar or nil end
hook.Avatar = false
local body = Reicht.Util.HttpGet(Config.WebhookAvatarApi:format(LocalPlayer.UserId))
local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body or "")
local row = ok and type(decoded) == "table" and type(decoded.data) == "table" and decoded.data[1]
if row and type(row.imageUrl) == "string" then hook.Avatar = row.imageUrl end
return hook.Avatar or nil
end
local function SavedNumber(name)
local saved = LocalPlayer:FindFirstChild("SavedData")
local value = saved and saved:FindFirstChild(name)
return value and tonumber(value.Value) or 0
end
function Reicht.Webhook.Income()
local stats = LocalPlayer:FindFirstChild("leaderstats")
local income = stats and stats:FindFirstChild("Income/s")
return income and tonumber(income.Value) or 0
end
function Reicht.Webhook.AccountFields()
local hook = Reicht.Webhook
local counts, stats = hook.Counts, State.Stats
local format = Reicht.Util.Format
return {
{ "💵 Cash", format(SavedNumber("Cash")) },
{ "📈 Income", format(hook.Income()) .. "/s" },
{ "♻️ Rebirths", SavedNumber("Rebirths") },
{ "🥚 Eggs (session)", stats.delivered .. " delivered, " .. counts.Rare .. " rare" },
{ "🌋 Magma (session)", counts.Magma .. " / " .. counts.Dips .. " dips" },
{ "⏱️ Session", hook.Duration(os.clock() - hook.StartedAt) .. " | " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. " players" },
}
end
function Reicht.Webhook.Build(event)
local fields = {}
for _, field in ipairs(event.Fields or {}) do
fields[#fields + 1] = { name = field[1], value = tostring(field[2]), inline = field[3] ~= false }
end
if event.Account ~= false then
table.insert(fields, { name = "\u{200B}", value = "**Account**", inline = false })
for _, field in ipairs(Reicht.Webhook.AccountFields()) do
fields[#fields + 1] = { name = field[1], value = tostring(field[2]), inline = true }
end
end
return HttpService:JSONEncode({
username = "Reicht",
avatar_url = Config.WebhookLogo,
content = event.Ping and Reicht.Util.Opt("WebhookPing") and "@everyone" or nil,
embeds = { {
author = { name = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", icon_url = Reicht.Webhook.AvatarUrl() },
title = (Config.WebhookIcons[event.Kind] or "") .. " " .. event.Title,
description = event.Lines and table.concat(event.Lines, "\n") or nil,
color = Reicht.Webhook.Color(event.Rarity, event.Kind),
fields = fields,
thumbnail = event.Thumbnail and { url = event.Thumbnail } or nil,
footer = { text = "Reicht • Ride A Pet", icon_url = Config.WebhookLogo },
timestamp = DateTime.now():ToIsoDate(),
} },
})
end
function Reicht.Webhook.Post(url, json)
local requester = (syn and syn.request) or (http and http.request) or http_request or request
if not requester then return false, "no http function" end
local ok, response = pcall(requester, { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = json })
if not ok or type(response) ~= "table" then return false, tostring(response) end
local code = tonumber(response.StatusCode) or 0
if code < 200 or code >= 300 then return false, "HTTP " .. code .. " " .. tostring(response.Body):sub(1, 120) end
return true
end
function Reicht.Webhook.Push(event)
local queue = Reicht.Webhook.Queue
if #queue >= Config.WebhookQueueMax then table.remove(queue, 1) end
queue[#queue + 1] = event
Reicht.Webhook.Flush()
end
function Reicht.Webhook.Flush()
local hook = Reicht.Webhook
if hook.Sending then return end
hook.Sending = true
task.spawn(function()
local queue = hook.Queue
for _ = 1, Config.WebhookQueueMax do
if #queue == 0 or not State.Alive then break end
local url = Reicht.Util.Opt("WebhookUrl")
if not hook.Valid(url) then
table.clear(queue)
break
end
local built, json = pcall(hook.Build, table.remove(queue, 1))
local sent, why = false, json
if built then sent, why = hook.Post(url, json) end
if not sent then warn(Config.Tag, "webhook:", why) end
task.wait(Config.WebhookGap)
end
hook.Sending = false
if #queue > 0 and State.Alive then hook.Flush() end
end)
end
function Reicht.Webhook.RareEgg(eggName)
local info = GameLib.EggInfo[eggName or ""]
if not info then return nil end
local floor = GameLib.RarityRank[Reicht.Util.Opt("WebhookEggRarity") or ""] or 1
if (GameLib.RarityRank[info.rarity] or 0) < floor then return nil end
return info
end
function Reicht.Webhook.EggFields(eggName, entry)
local info = GameLib.EggInfo[eggName] or {}
local fields = {
{ "✨ Rarity", tostring(info.rarity or "?") },
{ "🍀 Luck", "1 in " .. Reicht.Util.Format(info.luck or 0) },
}
if entry and entry.weight then fields[#fields + 1] = { "⚖️ Weight", string.format("%.2f", entry.weight) } end
if entry and entry.mutation and entry.mutation ~= "" then fields[#fields + 1] = { "🧬 Mutation", entry.mutation } end
if (info.growth or 0) > 0 then fields[#fields + 1] = { "⏳ Grow time", Reicht.Webhook.Duration(info.growth) } end
if info.volcanic then fields[#fields + 1] = { "🌋 Spawn", "Inside the volcano" } end
return fields
end
function Reicht.Webhook.EggPicked(guid, text)
local hook = Reicht.Webhook
local entry = guid and Reicht.EggIndex.Entries[guid]
local eggName = entry and entry.egg or (type(text) == "string" and text) or nil
hook.Counts.Eggs += 1
local info = hook.RareEgg(eggName)
if not info then return end
hook.Counts.Rare += 1
if not hook.Wants("Rare Egg Picked") then return end
hook.Push({
Kind = "Egg",
Title = "Picked up " .. eggName,
Lines = { "On the way home." },
Fields = hook.EggFields(eggName, entry),
Rarity = info.rarity,
Ping = GameLib.RarityRank[info.rarity] == #GameLib.RarityOrder,
})
end
function Reicht.Webhook.EggSpawned(egg)
local hook = Reicht.Webhook
local entry = type(egg) == "table" and egg or (typeof(egg) == "Instance" and Reicht.EggIndex.Entries[egg.Name])
if not entry or not entry.guid or hook.SeenEggs[entry.guid] then return end
if entry.dropEndsAt then return end
if entry.privateTo and entry.privateTo ~= LocalPlayer.UserId then return end
if not hook.Wants("Rare Egg In Server") then return end
local info = hook.RareEgg(entry.egg)
if not info then return end
hook.SeenEggs[entry.guid] = true
local fields = hook.EggFields(entry.egg, entry)
fields[#fields + 1] = { "🆔 Server", "`" .. game.JobId .. "`", false }
hook.Push({
Kind = "Server",
Title = entry.egg .. " spawned",
Lines = { "A " .. info.rarity .. " egg is on the map in your server." },
Fields = fields,
Rarity = info.rarity,
Ping = true,
})
end
function Reicht.Webhook.Dipped(reply)
local hook = Reicht.Webhook
local counts = hook.Counts
counts.Dips += 1
if reply.Success then counts.Magma += 1 end
if not reply.Success or not hook.Wants("Magma Dip") then return end
local eggName = tostring(reply.Egg)
local info = GameLib.EggInfo[eggName] or {}
hook.Push({
Kind = "Magma",
Title = eggName .. " became " .. tostring(reply.Mutation),
Lines = { "The volcano dip worked." },
Fields = {
{ "✨ Rarity", tostring(info.rarity or "?") },
{ "⚖️ Weight", string.format("%.2f", tonumber(reply.Weight) or 0) },
{ "🎲 Hit rate", string.format("%d / %d (%.0f%%)", counts.Magma, counts.Dips, counts.Magma / counts.Dips * 100) },
},
Rarity = info.rarity,
})
end
function Reicht.Webhook.PetAdded(tool)
local hook = Reicht.Webhook
if not tool:IsA("Tool") then return end
local key = tool:GetAttribute("PetKey")
if not key or hook.SeenPets[key] then return end
hook.SeenPets[key] = true
hook.Counts.Pets += 1
if not hook.Wants("Pet Hatched") then return end
local petName = tool:GetAttribute("PetName") or tool.Name
local info = GameLib.PetInfo[petName]
local rarity = info and info.rarity or "?"
local floor = GameLib.RarityRank[Reicht.Util.Opt("WebhookPetRarity") or ""] or 1
if (GameLib.RarityRank[rarity] or 0) < floor then return end
local fields = {
{ "✨ Rarity", rarity },
{ "💰 Income", Reicht.Util.Format(info and info.income or 0) .. "/s" },
}
local weight = tonumber(tool:GetAttribute("Weight") or tool:GetAttribute("BaseWeight"))
if weight then table.insert(fields, { "⚖️ Weight", string.format("%.2f", weight) }) end
for _, attr in ipairs({ "Mutation", "SpawnMutation" }) do
local mutation = tool:GetAttribute(attr)
if mutation and mutation ~= "" then fields[#fields + 1] = { "🧬 " .. (attr == "Mutation" and "Mutation" or "Spawn Mutation"), mutation } end
end
fields[#fields + 1] = { "🐾 New pets (session)", hook.Counts.Pets }
hook.Push({
Kind = "Pet",
Title = "New pet: " .. petName,
Fields = fields,
Rarity = rarity,
Ping = GameLib.RarityRank[rarity] == #GameLib.RarityOrder,
})
end
function Reicht.Webhook.DeliveryFailed(_plan)
if not Reicht.Webhook.Wants("Egg Returned") then return end
Reicht.Webhook.Push({
Kind = "Fail",
Title = "Egg farming stopped",
Lines = { "An egg was returned, so egg farming switched itself off. Turn it back on in the menu to continue." },
Fields = {
{ "📦 Delivered", State.Stats.delivered },
{ "❌ Lost", State.Stats.lost },
},
Ping = true,
})
end
function Reicht.Webhook.Snapshot()
local counts = Reicht.Webhook.Counts
return { Cash = SavedNumber("Cash"), Eggs = State.Stats.delivered, Magma = counts.Magma, Pets = counts.Pets, At = os.clock() }
end
function Reicht.Webhook.Report()
local hook = Reicht.Webhook
local minutes = tonumber(Reicht.Util.Opt("WebhookReportMins")) or 0
if minutes <= 0 or os.clock() - hook.LastReport < minutes * 60 then return end
if not hook.Wants("Status Report") then return end
hook.LastReport = os.clock()
local now = hook.Snapshot()
local before = hook.Baseline or now
hook.Baseline = now
local span = math.max(now.At - before.At, 1)
local gained = now.Cash - before.Cash
local format = Reicht.Util.Format
hook.Push({
Kind = "Report",
Title = "Status report",
Lines = { "**Doing:** " .. tostring(State.Status.Eggs or "Idle") },
Fields = {
{ "💵 Cash gained", (gained >= 0 and "+" or "") .. format(gained) },
{ "⚡ Cash / hour", format(gained / span * 3600) },
{ "🥚 Eggs", "+" .. (now.Eggs - before.Eggs) },
{ "🌋 Magma", "+" .. (now.Magma - before.Magma) },
{ "🐾 New pets", "+" .. (now.Pets - before.Pets) },
{ "🕒 Window", hook.Duration(span) },
},
})
end
function Reicht.Webhook.Kicked(message)
if not Reicht.Webhook.Wants("Kicked") then return end
local built, json = pcall(Reicht.Webhook.Build, {
Kind = "Kick",
Title = "Disconnected",
Lines = { "```" .. tostring(message):sub(1, 500) .. "```" },
Ping = true,
})
if built then Reicht.Webhook.Post(Reicht.Util.Opt("WebhookUrl"), json) end
end
function Reicht.Webhook.Test()
local url = Reicht.Util.Opt("WebhookUrl")
if not Reicht.Webhook.Valid(url) then return false, "Paste a Discord webhook URL first" end
local built, json = pcall(Reicht.Webhook.Build, { Kind = "Test", Title = "Webhook connected", Lines = { "Alerts from Reicht will show up here." } })
if not built then return false, tostring(json) end
local sent, why = Reicht.Webhook.Post(url, json)
if sent then return true end
if tostring(why):find("HTTP 404", 1, true) then return false, "Discord says this webhook does not exist" end
return false, why
end
function Reicht.Webhook.Listen(signal, fn)
if getmetatable(signal) == Reicht.Signal then
local off = signal:Connect(fn)
table.insert(Reicht.Webhook.Conns, { Disconnect = off })
return
end
local conn = Reicht:Connect(signal, fn)
table.insert(Reicht.Webhook.Conns, conn)
end
function Reicht.Webhook.MarkPets(container)
for _, tool in ipairs(container and container:GetChildren() or {}) do
local key = tool:GetAttribute("PetKey")
if key then Reicht.Webhook.SeenPets[key] = true end
end
end
function Reicht.Webhook.WatchBackpack(backpack)
Reicht.Webhook.MarkPets(backpack)
Reicht.Webhook.Listen(backpack.ChildAdded, Reicht.Webhook.PetAdded)
end
function Reicht.Webhook.WatchGame()
local hook, index = Reicht.Webhook, Reicht.EggIndex
hook.Listen(index.OnReply, function(kind, guid, text)
if kind == "PickedUp" then hook.EggPicked(guid, text) end
end)
hook.Listen(index.OnAdded, function(entry) task.defer(hook.EggSpawned, entry) end)
local dip = GameLib.Remote("VolcanoDipResult")
if dip then
hook.Listen(dip.OnClientEvent, function(reply)
if type(reply) ~= "table" then return end
if reply.Owner ~= LocalPlayer.UserId and reply.Owner ~= LocalPlayer then return end
hook.Dipped(reply)
end)
end
local saved = LocalPlayer:FindFirstChild("SavedData")
local rebirths = saved and saved:FindFirstChild("Rebirths")
if rebirths then
hook.Listen(rebirths.Changed, function(value)
if not hook.Wants("Rebirth") then return end
hook.Push({ Kind = "Rebirth", Title = "Rebirth " .. tostring(value) .. " done", Lines = { "Cash and luck reset, +1 pet slot." } })
end)
end
hook.Listen(GuiService.ErrorMessageChanged, function()
local message = GuiService:GetErrorMessage()
if message ~= "" then task.spawn(hook.Kicked, message) end
end)
end
function Reicht.Webhook.Boot()
local hook = Reicht.Webhook
if hook.Booted then return end
hook.Booted = true
hook.MarkPets(Reicht.Player.Char)
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if backpack then hook.WatchBackpack(backpack) end
hook.Listen(LocalPlayer.ChildAdded, function(child)
if child:IsA("Backpack") then hook.WatchBackpack(child) end
end)
hook.WatchGame()
hook.Baseline = hook.Snapshot()
task.spawn(hook.AvatarUrl)
end
function Reicht.Webhook.Step()
local hook = Reicht.Webhook
if not hook.Booted then hook.Boot() end
hook.Report()
end
function Reicht.Webhook.Stop()
local hook = Reicht.Webhook
for _, conn in ipairs(hook.Conns) do
conn:Disconnect()
end
table.clear(hook.Conns)
table.clear(hook.Queue)
hook.Booted = false
end
Reicht.Kaitun = {
Running = false,
Saved = {},
Steered = nil,
SteerKey = nil,
SteerAt = 0,
}
function Reicht.Kaitun.Set(idx, value)
Reicht.Options[idx] = value
table.insert(Reicht.State.PendingSet, { idx, value })
end
function Reicht.Kaitun.Snapshot(value)
if type(value) ~= "table" then return value end
local copy = {}
for key, entry in pairs(value) do
copy[key] = entry
end
return copy
end
function Reicht.Kaitun.Start()
if Reicht.Kaitun.Running then return end
Reicht.Kaitun.Running = true
table.clear(Reicht.Kaitun.Saved)
local remember = { "HuntMinRarity", "EggRarities", "MinEggRarity" }
for _, idx in ipairs(Reicht.Config.KaitunToggles) do
table.insert(remember, idx)
end
for _, idx in ipairs(remember) do
Reicht.Kaitun.Saved[idx] = { Reicht.Kaitun.Snapshot(Reicht.Util.Opt(idx)) }
end
Reicht.Kaitun.Set("HuntMinRarity", Reicht.Config.KaitunHuntRarity)
Reicht.Kaitun.Set("MinEggRarity", Reicht.GameLib.RarityOrder[1])
for _, idx in ipairs(Reicht.Config.KaitunToggles) do
if not Reicht.GameLib.Blocked(idx) then Reicht.Kaitun.Set(idx, true) end
end
Reicht.Kaitun.SteerAt = 0
end
function Reicht.Kaitun.Stop()
if not Reicht.Kaitun.Running then return end
Reicht.Kaitun.Running = false
for idx, boxed in pairs(Reicht.Kaitun.Saved) do
Reicht.Kaitun.Set(idx, boxed[1] == nil and false or boxed[1])
end
table.clear(Reicht.Kaitun.Saved)
Reicht.Kaitun.Steered = nil
Reicht.Kaitun.SteerKey = nil
Reicht.State.Status.Kaitun = "Off"
end
function Reicht.Kaitun.RaritiesFor(pet)
local mult = Reicht.Economy.LuckMult()
local wanted, any = {}, false
for egg, info in pairs(Reicht.GameLib.EggInfo) do
if info.volcanic then continue end
local odds = Reicht.GameLib.Odds(egg, mult)
for _, row in ipairs(odds or {}) do
if row[1] == pet and row[2] > 0 then
wanted[info.rarity] = true
any = true
break
end
end
end
return any and wanted or nil
end
function Reicht.Kaitun.Steer()
local reached = Reicht.Economy.RebirthPlan().reason == "target reached"
if reached and Reicht.Util.Opt("EggHunter") then Reicht.Kaitun.Set("EggHunter", false) end
local pet = not reached and Reicht.Economy.NextRequirement() or nil
local missing = pet and not Reicht.Economy.OwnedPet(pet)
local key = missing and (pet .. "@" .. math.floor(Reicht.Economy.LuckMult())) or "none"
local due = os.clock() - Reicht.Kaitun.SteerAt >= Reicht.Config.KaitunSteerEvery
if key == Reicht.Kaitun.SteerKey and not due then
return missing and ("Hunting " .. pet) or "Farming"
end
Reicht.Kaitun.SteerKey = key
Reicht.Kaitun.SteerAt = os.clock()
local rarities = missing and Reicht.Kaitun.RaritiesFor(pet)
if rarities then
Reicht.Kaitun.Steered = rarities
Reicht.Kaitun.Set("EggRarities", rarities)
return "Hunting " .. pet
end
if Reicht.Kaitun.Steered then
local saved = Reicht.Kaitun.Saved.EggRarities
Reicht.Kaitun.Set("EggRarities", saved and Reicht.Kaitun.Snapshot(saved[1]) or {})
Reicht.Kaitun.Steered = nil
end
return "Farming"
end
function Reicht.Kaitun.Step()
if not Reicht.Kaitun.Running then return end
local doing = Reicht.Kaitun.Steer()
local plan = Reicht.Economy.Plan
local rebirths = Reicht.Economy.Rebirths() .. "/" .. (Reicht.GameLib.Rebirths.Cap or 0)
Reicht.State.Status.Kaitun = doing .. " | Rebirth " .. rebirths .. (plan ~= "" and (" | " .. plan) or "")
end
function Reicht.Kaitun.Status()
return Reicht.State.Status.Kaitun or "Off"
end
local function T(en, th)
return Library:T(en, th)
end
Reicht.UI = { Labels = {}, Shown = {} }
Reicht.UI.WebhookEvents = {
"Rare Egg Picked", "Rare Egg In Server", "Egg Returned", "Magma Dip", "Pet Hatched",
"Rebirth", "Boost Started", "Kicked", "Status Report",
}
Reicht.UI.Floats = { { "Fly", "Fly" }, { "NoClip", "Clip" }, { "SpeedOn", "Run" }, { "EggEsp", "ESP" } }
function Reicht.UI.Shared(module, group)
return function(on)
local mod = rawget(Reicht, module)
if not mod then return end
if on then
if mod.Start then mod.Start() end
return
end
for _, idx in ipairs(group) do
if Reicht.Options[idx] then return end
end
if mod.Stop then mod.Stop() end
end
end
function Reicht.UI.Switch(module)
return function(on)
local mod = Reicht[module]
if on then mod.Start() else mod.Stop() end
end
end
function Reicht.UI.MoveHook(idx)
return function(on) Reicht.Move.Set(idx, on) end
end
function Reicht.UI.TrollHook(idx)
return function(on) Reicht.Troll.Set(idx, on) end
end
do
local ui, shared = Reicht.UI, Reicht.UI.Shared
local volcano = { "VolcanoDip", "VolcanoObby" }
local hatch = { "AutoPlaceEggs", "AutoHatch" }
local pets = { "AutoEquipBest", "AutoCollectCash", "AutoFeed" }
local economy = { "AutoUpgrade", "AutoRebirth", "SmartSpend" }
local halloween = { "AutoCandy", "AutoTrickOrTreat", "AutoPumpkin", "AutoHalloweenEgg", "AutoRitual" }
ui.Hooks = {
InstantPrompt = ui.Switch("Prompts"),
AutoEggs = ui.Switch("Eggs"),
EggHunter = ui.Switch("Hunter"),
VolcanoDip = shared("Volcano", volcano),
VolcanoObby = shared("Volcano", volcano),
AutoCandy = shared("Halloween", halloween),
AutoTrickOrTreat = shared("Halloween", halloween),
AutoPumpkin = shared("Halloween", halloween),
AutoHalloweenEgg = shared("Halloween", halloween),
AutoRitual = shared("Halloween", halloween),
HalloweenEsp = function(on)
if not on then Reicht.Halloween.ClearEsp() end
end,
AutoPlaceEggs = shared("Hatch", hatch),
AutoHatch = shared("Hatch", hatch),
ClearJunk = function(on)
if on then
Reicht.Eggs.QuietInventory(true)
Reicht.Junk.Start()
return
end
Reicht.Junk.Stop()
task.spawn(Reicht.Eggs.Settle)
end,
AutoEquipBest = shared("Pets", pets),
AutoCollectCash = shared("Pets", pets),
AutoFeed = shared("Pets", pets),
AutoSell = ui.Switch("Sell"),
AutoFusion = ui.Switch("Fusion"),
AutoShop = shared("Shop", { "AutoShop" }),
AutoUpgrade = shared("Economy", economy),
AutoRebirth = shared("Economy", economy),
SmartSpend = shared("Economy", economy),
AutoClaim = shared("Rewards", { "AutoClaim" }),
Kaitun = ui.Switch("Kaitun"),
EggEsp = function(on) if not on then Reicht.Esp.Clear() end end,
Fling = ui.TrollHook("Fling"),
Stick = ui.TrollHook("Stick"),
HideOtherPets = Reicht.Visual.HidePets,
HideOtherEggs = Reicht.Visual.HideEggs,
BoostFps = Reicht.Visual.Boost,
Render3D = Reicht.Visual.Render,
UnlockFps = function(on)
if Reicht.Visual.Cap(on) or not on then return end
Library.Compat.Block("UnlockFps", T("Not supported on this executor", "executor นี้ไม่รองรับ"))
end,
FpsCap = function()
if Reicht.Options.UnlockFps then Reicht.Visual.Cap(true) end
end,
}
for _, idx in ipairs({ "SpeedOn", "JumpOn", "Fly", "NoClip", "InfJump", "AntiAfk" }) do
ui.Hooks[idx] = ui.MoveHook(idx)
end
end
function Reicht.UI.Detach(label, fn)
return function(...)
local args = table.pack(...)
task.spawn(function()
Reicht.Util.Try("ui " .. label, fn, table.unpack(args, 1, args.n))
end)
end
end
function Reicht.UI.Bind(idx, option)
Reicht.Options[idx] = option.Value
option:OnChanged(function(value)
Reicht.Options[idx] = value
if value == true then Reicht.Scheduler.Resume(idx) end
local hook = Reicht.UI.Hooks[idx]
if hook then task.spawn(Reicht.Util.Try, "toggle " .. idx, hook, value == true) end
end)
return option
end
function Reicht.UI.Toggle(group, idx, info)
info.Default = false
return Reicht.UI.Bind(idx, group:AddToggle(idx, info))
end
function Reicht.UI.KeyToggle(group, idx, info)
local toggle = Reicht.UI.Toggle(group, idx, info)
toggle:AddKeyPicker(idx .. "Key", { Default = "None", Mode = "Toggle" })
return toggle
end
function Reicht.UI.CarryGuard(option)
if type(option.AddGuard) ~= "function" then return end
option:AddGuard(function(value)
if value ~= true or Reicht.Player:BasketCount() == 0 then return true end
Library:Notify("Reicht", T("Finish the egg delivery first", "ส่งไข่ให้เสร็จก่อน"), 4, "Warning")
task.defer(option.SetValue, option, false)
return false
end)
end
function Reicht.UI.Status(group, key, fallback)
local label = group:AddLabel(fallback)
table.insert(Reicht.UI.Labels, { label, key, fallback })
return label
end
function Reicht.UI.Values(source)
local ok, list = pcall(source)
return ok and type(list) == "table" and list or {}
end
function Reicht.UI.Rarities()
return table.clone(Reicht.GameLib.RarityOrder)
end
function Reicht.UI.HuntDefault()
local order = Reicht.GameLib.RarityOrder
if Reicht.GameLib.RarityRank.Mythic then return "Mythic" end
return order[#order]
end
function Reicht.UI.Names(source)
local names = {}
for name in pairs(source) do
names[#names + 1] = name
end
table.sort(names)
return names
end
function Reicht.UI.RideNames()
local names = Reicht.UI.Names(Reicht.Mount.Tools())
table.insert(names, 1, Reicht.Mount.AutoLabel)
return names
end
function Reicht.UI.Pump()
local sets = State.PendingSet
if sets and #sets > 0 then
State.PendingSet = {}
for _, row in ipairs(sets) do
local option = Library.Options[row[1]]
if option then option:SetValue(row[2]) end
end
end
Reicht.Scheduler.Pump()
local shown = Reicht.UI.Shown
for _, row in ipairs(Reicht.UI.Labels) do
local text = State.Status[row[2]] or row[3]
if shown[row[1]] == text then continue end
shown[row[1]] = text
row[1]:SetText(text)
end
local stats = State.Stats
local line = string.format("Delivered %d | Lost %d", stats.delivered, stats.lost)
if State.Status.WaveAt then
local left = math.max(0, math.floor(State.Status.WaveAt - os.clock()))
line ..= string.format(" | Wave in %d:%02d | %s", math.floor(left / 60), left % 60, State.Status.EggRate or "0/min")
end
if shown.Rate ~= line and Reicht.UI.RateLabel then
shown.Rate = line
Reicht.UI.RateLabel:SetText(line)
end
end
function Reicht.UI.Gate()
local blocked = 0
for idx in pairs(Reicht.GameLib.Needs) do
local reason = Reicht.GameLib.Blocked(idx)
if not reason or not Library.Options[idx] then continue end
blocked += 1
warn(Config.Tag, idx .. " blocked:", reason)
Library.Compat.Block(idx, T("The game changed, waiting for a script update", "เกมอัปเดต รอสคริปต์อัปเดต"))
end
if blocked == 0 then return end
Library:Notify("Reicht", T(blocked .. " features are off until the next update", "ปิดไว้ " .. blocked .. " ฟีเจอร์ จนกว่าจะอัปเดต"), 8, "Warning")
end
function Reicht.UI.Home(window)
local tab = window:AddTab(T("Home", "หน้าแรก"), "mushroom", T("Status and full auto", "สถานะและโหมดอัตโนมัติ"))
local status = tab:AddLeftGroupbox(T("Status", "สถานะ"), "info")
Reicht.UI.Status(status, "Eggs", "Egg farm is off")
Reicht.UI.RateLabel = status:AddLabel("Delivered 0 | Lost 0 | Wave in 0:00 | 0/min")
Reicht.UI.Status(status, "Economy", "Cash: waiting")
local quick = tab:AddLeftGroupbox(T("Quick", "ด่วน"), "bomb")
quick:AddButton({ Text = T("Collect Eggs Now", "เก็บไข่เดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("collect now", Reicht.Eggs.CollectNow) })
quick:AddButton({ Text = T("Return Home", "กลับบ้าน"), Func = Reicht.UI.Detach("return home", Reicht.Teleport.Home) })
local kaitun = tab:AddLeftGroupbox(T("Kaitun", "ไก่ตัน"), "star")
Reicht.UI.Toggle(kaitun, "Kaitun", {
Text = T("Kaitun", "ไก่ตัน"),
Description = T("Plays the account for you, from eggs to rebirth", "เล่นแทนทั้งบัญชี ตั้งแต่ไข่จนถึงรีเบิร์ธ"),
})
Reicht.UI.Status(kaitun, "Kaitun", "Off")
Reicht.UI.Webhook(tab:AddLeftGroupbox(T("Discord Webhook", "แจ้งเตือนดิสคอร์ด"), "bell"))
local discord = tab:AddRightGroupbox(T("Discord", "ดิสคอร์ด"), "link")
discord:AddLabel(Config.Discord)
discord:AddButton({ Text = T("Copy Discord Link", "คัดลอกลิงก์ดิสคอร์ด"), Func = function()
if Reicht.Util.Copy(Config.Discord) then
Library:Notify("Discord", T("Link copied", "คัดลอกลิงก์แล้ว"), 3, "Success")
else
Library:Notify("Discord", Config.Discord, 6, "Info")
end
end })
local updates = tab:AddRightGroupbox(T("Update Log", "อัปเดตล่าสุด"), "bell")
for i = 1, math.min(2, #Config.UpdateLog) do
local entry = Config.UpdateLog[i]
updates:AddParagraph({ Title = entry[1], Content = entry[2] })
end
end
function Reicht.UI.Webhook(hook)
local rarities = Reicht.UI.Rarities()
Reicht.UI.Toggle(hook, "Webhook", { Text = T("Webhook Alerts", "แจ้งเตือนผ่าน Webhook"), Description = T("Sends what you got to your Discord channel", "ส่งของที่ได้เข้าห้องดิสคอร์ดของคุณ") })
Reicht.UI.Bind("WebhookUrl", hook:AddInput("WebhookUrl", { Text = T("Webhook URL", "ลิงก์ Webhook"), Default = "", Placeholder = T("Paste your webhook link", "วางลิงก์ webhook"), Finished = true }))
Reicht.UI.Bind("WebhookEvents", hook:AddDropdown("WebhookEvents", { Text = T("Alerts", "แจ้งเตือนเรื่อง"), Values = Reicht.UI.WebhookEvents, Multi = true, Default = {} }))
Reicht.UI.Bind("WebhookEggRarity", hook:AddDropdown("WebhookEggRarity", { Text = T("Egg Rarity At Least", "ไข่ความหายากตั้งแต่"), Values = rarities, Default = Reicht.UI.HuntDefault() }))
Reicht.UI.Bind("WebhookPetRarity", hook:AddDropdown("WebhookPetRarity", { Text = T("Pet Rarity At Least", "สัตว์ความหายากตั้งแต่"), Values = rarities, Default = Reicht.UI.HuntDefault() }))
Reicht.UI.Bind("WebhookReportMins", hook:AddSlider("WebhookReportMins", { Text = T("Status Report Every", "รายงานสถานะทุก"), Min = 5, Max = 120, Default = 30, Rounding = 0, Suffix = " min" }))
Reicht.UI.Bind("WebhookPing", hook:AddCheckbox("WebhookPing", { Text = T("Ping @everyone On Top Finds", "แท็ก @everyone เมื่อได้ของสุดยอด"), Default = false }))
hook:AddButton({ Text = T("Send Test", "ส่งทดสอบ"), Func = Reicht.UI.Detach("webhook test", function()
local sent, why = Reicht.Webhook.Test()
Reicht.Util.Notify("Webhook", sent and "Test delivered" or ("Test failed: " .. tostring(why)), 6)
end) })
end
function Reicht.UI.EggFarm(window)
local tab = window:AddTab(T("Egg Farm", "ฟาร์มไข่"), "coin", T("Wild egg collecting", "เก็บไข่ป่า"))
local rarities = Reicht.UI.Rarities()
local farm = tab:AddLeftGroupbox(T("Collect Eggs", "เก็บไข่"), "zap")
Reicht.UI.Toggle(farm, "AutoEggs", { Text = T("Auto Collect Eggs", "เก็บไข่อัตโนมัติ"), Description = T("Brings every wanted egg on the map home", "เก็บไข่ที่เลือกทั่วแมพแล้วพากลับบ้าน") })
farm:AddButton({ Text = T("Collect Now", "เก็บเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("collect now", Reicht.Eggs.CollectNow) })
:AddButton({ Text = T("Exit Now", "ออกทันที"), Style = "Warning", Func = Reicht.UI.Detach("exit now", Reicht.Eggs.ExitNow) })
Reicht.UI.Toggle(farm, "ReturnAfter", { Text = T("Wait At Home", "รอที่บ้าน"), Description = T("Waits at your plot between waves", "รอที่พล็อตระหว่างรอบไข่") })
Reicht.UI.Bind("DeliveryMode", farm:AddDropdown("DeliveryMode", { Text = T("Delivery", "การส่งไข่"), Values = { "Auto", "Safe" }, Default = "Auto" }))
local ride = Reicht.UI.Bind("RidePet", farm:AddDropdown("RidePet", { Text = T("Ride Pet", "สัตว์ที่ขี่"), Values = Reicht.UI.RideNames(), Default = Reicht.Mount.AutoLabel, Searchable = true }))
farm:AddButton({ Text = T("Refresh Ride Pets", "รีเฟรชสัตว์ที่ขี่"), Func = function()
ride:SetValues(Reicht.UI.RideNames())
Reicht.Mount.Dirty = true
end })
Reicht.UI.Bind("EggRoute", farm:AddDropdown("EggRoute", {
Text = T("Collection Route", "เส้นทางเก็บไข่"), Values = { "Fast nearby", "Best yield" }, Default = "Fast nearby",
Description = T("Fast nearby uses short returns; Best yield includes far eggs. Hunter follows rarity.", "เก็บเร็วเลือกจุดใกล้; คุ้มค่าสุดรวมจุดไกล โหมดล่าใช้เป้าหมายความหายาก"),
}))
local settle = Reicht.UI.Bind("DropSettle", farm:AddSlider("DropSettle", { Text = T("Delivery Safety", "ความปลอดภัยการส่ง"), Min = 0.2, Max = 0.45, Default = 0.2, Rounding = 2, Suffix = "s" }))
settle:OnChanged(function(value)
State.Tune.DropSettle = math.clamp(tonumber(value) or Config.DropSettle, Config.DropSettle, 0.45)
end)
local contest = Reicht.UI.Bind("ContestWeight", farm:AddSlider("ContestWeight", { Text = T("Beat Other Players", "แย่งไข่ก่อนคนอื่น"), Min = 0, Max = Config.ContestWeightMax, Default = Config.ContestWeight, Rounding = 1 }))
contest:OnChanged(function(value)
State.Tune.ContestWeight = math.clamp(tonumber(value) or Config.ContestWeight, 0, Config.ContestWeightMax)
end)
local volcano = tab:AddLeftGroupbox(T("Volcano (beta)", "ภูเขาไฟ (ทดลอง)"), "flower")
Reicht.UI.Toggle(volcano, "VolcanoDip", { Text = T("Volcano Dip", "จุ่มไข่ในภูเขาไฟ"), Description = T("Dips eggs in the volcano for a chance at Magma", "จุ่มไข่ในภูเขาไฟ ลุ้นได้ Magma"), Risky = true })
Reicht.UI.Bind("DipRarities", volcano:AddDropdown("DipRarities", { Text = T("Dip Rarities (empty = all)", "ความหายากที่จะจุ่ม (ว่าง = ทั้งหมด)"), Values = rarities, Multi = true, Default = {} }))
Reicht.UI.Toggle(volcano, "VolcanoObby", { Text = T("Auto Volcano Egg", "เก็บไข่ภูเขาไฟอัตโนมัติ"), Description = T("Clears the climb and brings the Volcanic Egg home", "ผ่านด่านแล้วพาไข่ Volcanic กลับบ้าน"), Risky = true })
Reicht.UI.Status(volcano, "Volcano", "Off")
local filters = tab:AddRightGroupbox(T("Egg Filters", "ตัวกรองไข่"), "target")
local minDrop = Reicht.UI.Bind("MinEggRarity", filters:AddDropdown("MinEggRarity", { Text = T("Minimum Egg Rarity", "ความหายากไข่ขั้นต่ำ"), Values = rarities, Default = rarities[1], Description = T("Skips eggs below this rarity", "ข้ามไข่ที่หายากต่ำกว่านี้") }))
local rarityDrop = Reicht.UI.Bind("EggRarities", filters:AddDropdown("EggRarities", { Text = T("Rarities (empty = all)", "ความหายาก (ว่าง = ทั้งหมด)"), Values = rarities, Multi = true, Default = {} }))
local nameDrop = Reicht.UI.Bind("EggNames", filters:AddDropdown("EggNames", { Text = T("Eggs (empty = all)", "ไข่ (ว่าง = ทั้งหมด)"), Values = Reicht.UI.Names(Reicht.GameLib.EggInfo), Multi = true, Searchable = true, Default = {} }))
Reicht.UI.Bind("MinLuck", filters:AddSlider("MinLuck", { Text = T("Minimum Luck (1 in X)", "โชคขั้นต่ำ (1 ใน X)"), Min = 0, Max = 1000000, Default = 0, Rounding = 0 }))
Reicht.UI.Bind("MinWeight", filters:AddSlider("MinWeight", { Text = T("Minimum Weight", "น้ำหนักขั้นต่ำ"), Min = 1, Max = 3, Default = 1, Rounding = 1, Suffix = "x" }))
Reicht.UI.Toggle(filters, "SmartEggs", { Text = T("Top Eggs Of The Wave", "เฉพาะไข่ดีของรอบ"), Description = T("Skips eggs worth less than the wave average", "ข้ามไข่ที่ค่าน้อยกว่าค่ากลางของรอบ") })
filters:AddButton({ Text = T("Refresh Egg List", "รีเฟรชรายการไข่"), Func = function()
Reicht.GameLib.Build()
minDrop:SetValues(Reicht.UI.Rarities())
rarityDrop:SetValues(Reicht.UI.Rarities())
nameDrop:SetValues(Reicht.UI.Names(Reicht.GameLib.EggInfo))
end })
local hunter = tab:AddRightGroupbox(T("Rare Egg Hunter", "ล่าไข่หายาก"), "star")
Reicht.UI.Toggle(hunter, "EggHunter", { Text = T("Rare Egg Hunter", "ล่าไข่หายาก"), Description = T("Goes for rare eggs first and alerts you when one spawns", "รีบไปเก็บไข่หายากก่อน และแจ้งเตือนเมื่อเกิด") })
Reicht.UI.Bind("HuntMinRarity", hunter:AddDropdown("HuntMinRarity", { Text = T("Minimum Rarity", "ความหายากขั้นต่ำ"), Values = rarities, Default = Reicht.UI.HuntDefault() }))
local hop = Reicht.UI.Toggle(hunter, "HunterHop", { Text = T("Hop Servers (beta)", "ย้ายเซิร์ฟหา (ทดลอง)"), Description = T("Moves to another server when none are around", "ย้ายเซิร์ฟเมื่อไม่มีไข่หายาก"), Risky = true })
Library.Compat.NeedCap(hop, "Queue")
end
function Reicht.UI.Hatching(window)
local tab = window:AddTab(T("Hatch", "ฟักไข่"), "flower", T("Placing and hatching", "วางและฟักไข่"))
local place = tab:AddLeftGroupbox(T("Place Eggs", "วางไข่"), "flower")
Reicht.UI.Toggle(place, "AutoPlaceEggs", { Text = T("Auto Place Eggs", "วางไข่อัตโนมัติ"), Description = T("Fills your plot up to the limit", "วางไข่ลงพล็อตจนเต็มลิมิต") })
place:AddButton({ Text = T("Place Now", "วางเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("place now", Reicht.Hatch.PlaceNow) })
Reicht.UI.Bind("PlantOrder", place:AddDropdown("PlantOrder", { Text = T("Place First", "วางก่อน"), Values = { "Best value", "Fastest growth", "Value per hour" }, Default = "Best value" }))
Reicht.UI.Bind("PlantKeep", place:AddSlider("PlantKeep", { Text = T("Keep Per Egg", "เก็บไว้ต่อชนิด"), Min = 0, Max = 20, Default = 0, Rounding = 0 }))
Reicht.UI.Status(place, "Hatch", "Idle")
local hatch = tab:AddLeftGroupbox(T("Hatching", "ฟักไข่"), "star")
Reicht.UI.Toggle(hatch, "AutoHatch", { Text = T("Auto Hatch", "ฟักอัตโนมัติ"), Description = T("Hatches eggs from anywhere once they are grown", "ฟักไข่จากที่ไหนก็ได้เมื่อโตเต็มที่") })
hatch:AddButton({ Text = T("Hatch Now", "ฟักเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("hatch now", Reicht.Hatch.HatchNow) })
Reicht.UI.Toggle(hatch, "HoldHatchBoost", { Text = T("Wait For Luck Boost", "รอบูสต์โชค"), Description = T("Holds grown eggs until a luck boost is running", "เก็บไข่ที่โตแล้วไว้ฟักตอนมีบูสต์โชค") })
local junk = tab:AddRightGroupbox(T("Clear Junk Eggs", "ล้างไข่ขยะ"), "bomb")
local rarities = Reicht.UI.Rarities()
Reicht.UI.Toggle(junk, "ClearJunk", { Text = T("Clear Junk Eggs", "ล้างไข่ขยะ"), Description = T("Hatches your cheap eggs and sells the pets that come out", "ฟักไข่ถูกๆ แล้วขายสัตว์ที่ได้") })
junk:AddButton({ Text = T("Sell Junk Pets Now", "ขายสัตว์ขยะเดี๋ยวนี้"), Style = "Warning", Func = Reicht.UI.Detach("sell junk now", Reicht.Junk.SellNow) })
Reicht.UI.Bind("JunkRarities", junk:AddDropdown("JunkRarities", { Text = T("Eggs To Clear", "ไข่ที่จะล้าง"), Values = rarities, Multi = true, Default = { "Common", "Rare" } }))
Reicht.UI.Bind("JunkSellPets", junk:AddDropdown("JunkSellPets", { Text = T("Pets To Sell (empty = auto)", "สัตว์ที่จะขาย (ว่าง = อัตโนมัติ)"), Values = rarities, Multi = true, Default = {}, Description = T("Auto sells what your junk eggs usually give", "อัตโนมัติ = ขายระดับที่ไข่ขยะมักให้") }))
Reicht.UI.Status(junk, "Junk", "Off")
end
function Reicht.UI.Halloween(window)
local tab = window:AddTab(T("Halloween", "ฮาโลวีน"), "star", T("Halloween event farm", "ฟาร์มอีเวนต์ฮาโลวีน"))
local candy = tab:AddLeftGroupbox(T("Candy", "ลูกกวาด"), "zap", "OP")
Reicht.UI.Toggle(candy, "AutoCandy", {
Text = T("Auto Candy", "เก็บลูกกวาดอัตโนมัติ"),
Description = T("Gathers candy and cashes it in at the pad", "เก็บลูกกวาดรอบเกาะแล้วเอาไปแลกที่แท่น"),
})
Reicht.UI.Bind("CandyMode", candy:AddDropdown("CandyMode", {
Text = T("Farm Mode", "โหมดฟาร์ม"),
Values = { "Most pieces", "Fast returns", "Best yield" }, Default = "Most pieces",
}))
Reicht.UI.Bind("CandyReturnStyle", candy:AddDropdown("CandyReturnStyle", {
Text = T("Return Style", "วิธีกลับไปฝาก"),
Values = { "Quick hops", "Smooth ride" }, Default = "Quick hops",
}))
Reicht.UI.Bind("CandyReturnSpeed", candy:AddSlider("CandyReturnSpeed", {
Text = T("Return Speed (%)", "ความเร็วกลับ (%)"), Min = 100, Max = 600, Default = 350, Rounding = 0,
}))
Reicht.UI.Bind("CandyAutoMount", candy:AddCheckbox("CandyAutoMount", {
Text = T("Use Fastest Ride Pet", "ใช้สัตว์ขี่ที่เร็วที่สุด"), Default = true,
}))
Reicht.UI.Bind("CandyAvoidSpoil", candy:AddCheckbox("CandyAvoidSpoil", {
Text = T("Allow For Candy Slowdown", "เผื่อเวลาตอนลูกกวาดทำให้ช้าลง"), Default = true,
Description = T("Skip cursed candy too far to bank at reduced speed", "ข้ามกองที่ไกลจนฝากไม่ทันเมื่อโดนลดความเร็ว"),
}))
Reicht.UI.Bind("CandyMinAmount", candy:AddSlider("CandyMinAmount", {
Text = T("Minimum Pieces", "จำนวนชิ้นขั้นต่ำ"), Min = 1, Max = 15, Default = 1, Rounding = 0,
}))
Reicht.UI.Bind("CandyMaxRange", candy:AddSlider("CandyMaxRange", {
Text = T("Maximum Range", "ระยะไกลสุด"), Min = 100, Max = 3000, Default = Config.CandyRangeDefault, Rounding = 0,
}))
candy:AddButton({ Text = T("Collect Now", "เก็บเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("candy now", Reicht.Halloween.CandyNow) })
:AddButton({ Text = T("Exit Now", "ออกทันที"), Style = "Warning", Func = Reicht.UI.Detach("halloween exit", Reicht.Halloween.ExitNow) })
Reicht.UI.Status(candy, "Halloween", "Off")
local doors = tab:AddLeftGroupbox(T("Trick-or-Treat", "กวนประตูบ้าน"), "house")
Reicht.UI.Toggle(doors, "AutoTrickOrTreat", {
Text = T("Auto Trick-or-Treat", "กวนประตูบ้านอัตโนมัติ"),
Description = T("Knocks lit doors and picks up the candy they drop", "เคาะประตูที่สว่างแล้วเก็บลูกกวาดที่ตก"),
})
doors:AddButton({ Text = T("Knock Now", "เคาะเดี๋ยวนี้"), Func = Reicht.UI.Detach("knock now", Reicht.Halloween.KnockNow) })
local pumpkins = tab:AddLeftGroupbox(T("Pumpkins", "ฟักทอง"), "flower")
Reicht.UI.Toggle(pumpkins, "AutoPumpkin", {
Text = T("Auto Search Pumpkins", "ค้นฟักทองอัตโนมัติ"),
Description = T("Searches pumpkins for candy", "ค้นฟักทองเอาลูกกวาด"),
})
pumpkins:AddButton({ Text = T("Search Now", "ค้นเดี๋ยวนี้"), Func = Reicht.UI.Detach("search now", Reicht.Halloween.SearchNow) })
local egg = tab:AddRightGroupbox(T("Halloween Egg", "ไข่ฮาโลวีน"), "star", "OP")
Reicht.UI.Toggle(egg, "AutoHalloweenEgg", {
Text = T("Auto Buy Halloween Egg", "ซื้อไข่ฮาโลวีนอัตโนมัติ"),
Description = T("Spends event tokens on the event egg, then places and hatches it", "ใช้โทเกนอีเวนต์ซื้อไข่ แล้ววางกับฟักให้เอง"),
})
Reicht.UI.Bind("HalloweenKeepTokens", egg:AddSlider("HalloweenKeepTokens", {
Text = T("Keep Tokens", "เก็บโทเกนไว้"), Min = 0, Max = 3500, Default = 0, Rounding = 0,
}))
Reicht.UI.Bind("HalloweenBuyLimit", egg:AddSlider("HalloweenBuyLimit", {
Text = T("Purchase Limit (0 = unlimited)", "จำกัดการซื้อ (0 = ไม่จำกัด)"), Min = 0, Max = 100, Default = 0, Rounding = 0,
}))
Reicht.UI.Bind("HalloweenAutoHatch", egg:AddCheckbox("HalloweenAutoHatch", {
Text = T("Place and Hatch Purchased Eggs", "วางและฟักไข่ที่เพิ่งซื้อ"), Default = true,
}))
egg:AddButton({ Text = T("Buy Egg Now", "ซื้อไข่เดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("buy egg now", Reicht.Halloween.BuyNow) })
Reicht.UI.Status(egg, "HalloweenEgg", "Off")
local ritual = tab:AddRightGroupbox(T("Ritual (beta)", "พิธีกรรม (ทดลอง)"), "bomb")
Reicht.UI.Toggle(ritual, "AutoRitual", {
Text = T("Auto Ritual", "พิธีกรรมอัตโนมัติ"),
Description = T("Joins the Headless ritual while it is open", "เข้าร่วมพิธีกรรม Headless ช่วงที่เปิด"),
Risky = true,
})
Reicht.UI.Status(ritual, "Ritual", "Ritual is closed")
local esp = tab:AddRightGroupbox(T("Event ESP", "มองเห็นอีเวนต์"), "eye")
Reicht.UI.KeyToggle(esp, "HalloweenEsp", {
Text = T("Event ESP", "มองเห็นอีเวนต์"),
Description = T("Shows candy, doors, pumpkins and the altar through walls", "แสดงลูกกวาด ประตู ฟักทอง และแท่นพิธีทะลุกำแพง"),
})
Reicht.UI.Bind("HalloweenEspTypes", esp:AddDropdown("HalloweenEspTypes", {
Text = T("Show (empty = all)", "แสดง (ว่าง = ทั้งหมด)"),
Values = { "Candy", "Doors", "Pumpkins", "Altar" },
Multi = true,
Default = {},
}))
end
function Reicht.UI.Ranch(tab)
local ranch = tab:AddLeftGroupbox(T("Ranch", "ฟาร์ม"), "house")
Reicht.UI.Toggle(ranch, "AutoEquipBest", { Text = T("Auto Place Best Pets", "วางสัตว์ตัวดีสุดอัตโนมัติ"), Description = T("Keeps the highest income pets on your plot", "ใส่สัตว์ที่ทำเงินได้มากสุดลงพล็อตเสมอ") })
Reicht.UI.Toggle(ranch, "AutoCollectCash", { Text = T("Auto Collect Cash", "เก็บเงินอัตโนมัติ") })
ranch:AddButton({ Text = T("Place Best Now", "วางตัวดีสุดเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("place pets", Reicht.Pets.PlaceNow) })
:AddButton({ Text = T("Collect Now", "เก็บเดี๋ยวนี้"), Func = Reicht.UI.Detach("collect cash", Reicht.Pets.CollectNow) })
Reicht.UI.Status(ranch, "Pets", "Idle")
local sell = tab:AddLeftGroupbox(T("Sell Pets", "ขายสัตว์เลี้ยง"), "coin")
local rarities = Reicht.UI.Rarities()
Reicht.UI.Toggle(sell, "AutoSell", { Text = T("Auto Sell Pets", "ขายสัตว์อัตโนมัติ"), Description = T("Sells bag pets outside the rarities you keep", "ขายสัตว์ในกระเป๋าที่ไม่อยู่ในความหายากที่เก็บไว้"), Risky = true })
sell:AddButton({ Text = T("Sell Now", "ขายเดี๋ยวนี้"), Style = "Warning", DoubleClick = true, Func = Reicht.UI.Detach("sell now", function()
local sold = Reicht.Sell.Now()
Reicht.Util.Notify("Sell", (sold or 0) > 0 and ("Sold " .. sold .. " pets") or "Nothing to sell with these options", 4)
end) })
Reicht.UI.Bind("SellRarities", sell:AddDropdown("SellRarities", { Text = T("Rarities To Keep", "ความหายากที่เก็บไว้"), Values = rarities, Multi = true, Default = {} }))
Reicht.UI.Bind("SellKeepBest", sell:AddSlider("SellKeepBest", { Text = T("Keep Best Pets", "เก็บตัวดีสุดไว้"), Min = 0, Max = 100, Default = 10, Rounding = 0 }))
Reicht.UI.Bind("SellUnderIncome", sell:AddInput("SellUnderIncome", { Text = T("Only Below Income /s", "ขายเฉพาะรายได้ต่ำกว่า /วิ"), Default = "0", Numeric = true, Finished = true }))
Reicht.UI.Bind("SellKeepMutated", sell:AddCheckbox("SellKeepMutated", { Text = T("Keep Mutated Pets", "ไม่ขายตัวมิวเทชัน"), Default = true }))
Reicht.UI.Status(sell, "SellPreview", "Will sell 0")
end
function Reicht.UI.Care(tab)
local feed = tab:AddRightGroupbox(T("Feeding", "ให้อาหาร"), "heart")
Reicht.UI.Toggle(feed, "AutoFeed", { Text = T("Auto Feed", "ให้อาหารอัตโนมัติ") })
feed:AddButton({ Text = T("Feed Now", "ให้อาหารเดี๋ยวนี้"), Func = Reicht.UI.Detach("feed now", Reicht.Pets.Feed) })
Reicht.UI.Bind("FoodTypes", feed:AddDropdown("FoodTypes", { Text = T("Foods (empty = all)", "อาหาร (ว่าง = ทั้งหมด)"), Values = table.clone(Reicht.GameLib.FoodOrder), Multi = true, Default = {} }))
Reicht.UI.Bind("FeedTarget", feed:AddDropdown("FeedTarget", { Text = T("Feed", "ให้อาหาร"), Values = { "Placed", "Ride pet", "All" }, Default = "Placed" }))
Reicht.UI.Status(feed, "Feed", "Idle")
local protect = tab:AddRightGroupbox(T("Protect", "ป้องกัน"), "shield")
local list = Reicht.UI.Bind("ProtectList", protect:AddDropdown("ProtectList", { Text = T("Never Sell Or Fuse", "ห้ามขายหรือหลอม"), Values = Reicht.UI.Names(Reicht.GameLib.PetInfo), Multi = true, Searchable = true, Default = {} }))
protect:AddButton({ Text = T("Refresh Pets", "รีเฟรชสัตว์"), Func = function()
list:SetValues(Reicht.UI.Names(Reicht.GameLib.PetInfo))
end })
local fuse = tab:AddRightGroupbox(T("Fusion", "หลอมสัตว์"), "bomb")
local rarities = Reicht.Fusion.Rarities()
Reicht.UI.Toggle(fuse, "AutoFusion", { Text = T("Auto Fusion", "หลอมสัตว์อัตโนมัติ"), Description = T("Fuses four matching pets and claims the result", "หลอมสัตว์ 4 ตัวที่ตรงเงื่อนไขแล้วรับผล"), Risky = true })
fuse:AddButton({ Text = T("Fuse Now", "หลอมเดี๋ยวนี้"), Func = Reicht.UI.Detach("fuse now", Reicht.Fusion.Now) })
Reicht.UI.Bind("FuseRarities", fuse:AddDropdown("FuseRarities", { Text = T("Rarities To Fuse", "ความหายากที่จะหลอม"), Values = rarities, Multi = true, Default = {} }))
Reicht.UI.Bind("FuseKeepBest", fuse:AddSlider("FuseKeepBest", { Text = T("Keep Best Pets", "เก็บตัวดีสุดไว้"), Min = 0, Max = 100, Default = 10, Rounding = 0 }))
Reicht.UI.Bind("FuseKeepMutated", fuse:AddCheckbox("FuseKeepMutated", { Text = T("Keep Mutated Pets", "ไม่ใช้ตัวมิวเทชัน"), Default = true }))
Reicht.UI.Status(fuse, "Fusion", "Idle")
end
function Reicht.UI.PetsTab(window)
local tab = window:AddTab(T("Pets", "สัตว์เลี้ยง"), "shell", T("Ranch, selling and fusion", "ฟาร์ม ขาย และหลอม"))
Reicht.UI.Ranch(tab)
Reicht.UI.Care(tab)
end
function Reicht.UI.Upgrades(window)
local tab = window:AddTab(T("Upgrades", "อัปเกรด"), "oneup", T("Luck, rebirth, shop, rewards", "โชค รีเบิร์ธ ร้าน รางวัล"))
local cap = math.max(1, Reicht.GameLib.Rebirths.Cap or 1)
local up = tab:AddLeftGroupbox(T("Upgrades", "อัปเกรด"), "oneup")
Reicht.UI.Toggle(up, "AutoUpgrade", { Text = T("Auto Upgrade Hatch Luck", "อัปโชคฟักอัตโนมัติ"), Description = T("Buys luck upgrades that pay back fast", "ซื้ออัปโชคที่คืนทุนเร็ว") })
up:AddButton({ Text = T("Upgrade Now", "อัปเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Detach("upgrade now", Reicht.Economy.UpgradeNow) })
Reicht.UI.Toggle(up, "SmartSpend", { Text = T("Spend By Payback", "ใช้เงินตามความคุ้ม"), Description = T("Spends on what pays back first and saves for rebirth", "ใช้เงินกับสิ่งที่คืนทุนก่อน และเก็บไว้รีเบิร์ธ") })
Reicht.UI.Toggle(up, "AutoRebirth", { Text = T("Auto Rebirth", "รีเบิร์ธอัตโนมัติ"), Description = T("Rebirths when cash and the needed pet are ready", "รีเบิร์ธเมื่อเงินและสัตว์ที่ต้องใช้พร้อม"), Risky = true })
up:AddButton({ Text = T("Rebirth Now", "รีเบิร์ธเดี๋ยวนี้"), Style = "Warning", DoubleClick = true, Func = Reicht.UI.Detach("rebirth now", Reicht.Economy.RebirthNow) })
Reicht.UI.Bind("RebirthTarget", up:AddSlider("RebirthTarget", { Text = T("Stop At Rebirth", "หยุดที่รีเบิร์ธ"), Min = 1, Max = cap, Default = cap, Rounding = 0 }))
Reicht.UI.Status(up, "Upgrade", "Idle")
local shop = tab:AddRightGroupbox(T("Stock Shop", "ร้านสต็อก"), "shop")
Reicht.UI.Toggle(shop, "AutoShop", { Text = T("Auto Buy Stock", "ซื้อของในร้านอัตโนมัติ"), Description = T("Buys the picked items when they restock", "ซื้อของที่เลือกเมื่อร้านเติมของ") })
shop:AddButton({ Text = T("Buy Now", "ซื้อเดี๋ยวนี้"), Func = Reicht.UI.Detach("buy now", Reicht.Shop.BuyNow) })
Reicht.UI.Bind("ShopItems", shop:AddDropdown("ShopItems", { Text = T("Items To Buy", "ของที่จะซื้อ"), Values = Reicht.UI.Values(Reicht.Shop.Labels), Multi = true, Searchable = true, Default = {} }))
Reicht.UI.Bind("ShopKeepCash", shop:AddInput("ShopKeepCash", { Text = T("Keep Cash", "กันเงินไว้"), Default = "0", Numeric = true, Finished = true }))
Reicht.UI.Status(shop, "Shop", "Idle")
local rewards = tab:AddRightGroupbox(T("Rewards", "รางวัล"), "key")
Reicht.UI.Toggle(rewards, "AutoClaim", { Text = T("Auto Claim Rewards", "รับรางวัลอัตโนมัติ"), Description = T("Index, offline and event rewards", "รางวัลสมุดสะสม ออฟไลน์ และอีเวนต์") })
rewards:AddButton({ Text = T("Claim All Now", "รับทั้งหมดเดี๋ยวนี้"), Func = Reicht.UI.Detach("claim now", Reicht.Rewards.ClaimNow) })
Reicht.UI.Status(rewards, "Rewards", "Idle")
local boosts = tab:AddRightGroupbox(T("Boosts", "บูสต์"), "zap")
Reicht.UI.Status(boosts, "Boosts", "No boosts running")
end
function Reicht.UI.TeleportTab(window)
local tab = window:AddTab(T("Teleport", "วาร์ป"), "pipe", T("Places and players", "สถานที่และผู้เล่น"))
local places = tab:AddLeftGroupbox(T("Places", "สถานที่"), "map")
local placeDrop = Reicht.UI.Bind("TeleportPlace", places:AddDropdown("TeleportPlace", { Text = T("Place", "สถานที่"), Values = Reicht.UI.Values(Reicht.Teleport.PlaceNames), Searchable = true }))
places:AddButton({ Text = T("Teleport", "วาร์ป"), Style = "Primary", Func = Reicht.UI.Detach("teleport", function() Reicht.Teleport.To(placeDrop.Value) end) })
:AddButton({ Text = T("Refresh", "รีเฟรช"), Func = function() placeDrop:SetValues(Reicht.UI.Values(Reicht.Teleport.PlaceNames)) end })
local players = tab:AddRightGroupbox(T("Players", "ผู้เล่น"), "user")
local playerDrop = Reicht.UI.Bind("TeleportPlayer", players:AddDropdown("TeleportPlayer", { Text = T("Player", "ผู้เล่น"), SpecialType = "Player", Searchable = true }))
players:AddButton({ Text = T("Teleport To Player", "วาร์ปไปหาผู้เล่น"), Func = Reicht.UI.Detach("teleport player", function() Reicht.Teleport.ToPlayer(playerDrop.Value) end) })
end
function Reicht.UI.PlayerTab(window)
local tab = window:AddTab(T("Player", "ผู้เล่น"), "user", T("Movement and utility", "การเคลื่อนที่และอรรถประโยชน์"))
local move = tab:AddLeftGroupbox(T("Movement", "การเคลื่อนที่"), "zap")
Reicht.UI.KeyToggle(move, "SpeedOn", { Text = T("Speed", "วิ่งเร็ว") })
Reicht.UI.Bind("WalkSpeed", move:AddSlider("WalkSpeed", { Text = T("Walk Speed", "ความเร็ว"), Min = 16, Max = 300, Default = Config.WalkSpeed, Rounding = 0 }))
Reicht.UI.KeyToggle(move, "JumpOn", { Text = T("Jump Power", "กระโดดสูง") })
Reicht.UI.Bind("JumpPower", move:AddSlider("JumpPower", { Text = T("Jump Power", "แรงกระโดด"), Min = 50, Max = 300, Default = Config.JumpPower, Rounding = 0 }))
Reicht.UI.KeyToggle(move, "InfJump", { Text = T("Infinite Jump", "กระโดดไม่จำกัด") })
local troll = tab:AddLeftGroupbox(T("Troll", "ป่วน"), "troll")
Reicht.UI.Bind("TrollTarget", troll:AddDropdown("TrollTarget", { Text = T("Target", "เป้าหมาย"), SpecialType = "Player", Searchable = true }))
Reicht.UI.Toggle(troll, "Fling", { Text = T("Fling", "เหวี่ยงกระเด็น"), Description = T("Pauses egg farming while on", "หยุดฟาร์มไข่ชั่วคราวระหว่างเปิด"), Risky = true })
Reicht.UI.Toggle(troll, "Stick", { Text = T("Stick To Player", "เกาะติดผู้เล่น"), Description = T("Pauses egg farming while on", "หยุดฟาร์มไข่ชั่วคราวระหว่างเปิด"), Risky = true })
troll:AddButton({ Text = T("Spectate", "ส่องดู"), Func = function() Reicht.Troll.Spectate(Reicht.Options.TrollTarget) end })
:AddButton({ Text = T("Stop", "เลิกส่อง"), Func = function() Reicht.Troll.Spectate(nil) end })
local fly = tab:AddRightGroupbox(T("Fly and Noclip", "บินและเดินทะลุ"), "pipe")
local flyToggle = Reicht.UI.KeyToggle(fly, "Fly", { Text = T("Fly", "บิน") })
Reicht.UI.Bind("FlySpeed", fly:AddSlider("FlySpeed", { Text = T("Fly Speed", "ความเร็วบิน"), Min = 20, Max = 500, Default = Config.FlySpeed, Rounding = 0 }))
Reicht.UI.KeyToggle(fly, "NoClip", { Text = T("Noclip", "เดินทะลุ") })
Reicht.UI.CarryGuard(flyToggle)
local misc = tab:AddRightGroupbox(T("Utility", "อรรถประโยชน์"), "gear")
Reicht.UI.Toggle(misc, "InstantPrompt", {
Text = T("Instant E", "กด E ทันที"),
Description = T("Press to interact without holding the key", "กดเก็บหรือโต้ตอบได้เลย ไม่ต้องค้างปุ่ม"),
})
Reicht.UI.Toggle(misc, "AntiAfk", { Text = T("Anti AFK", "กันหลุด AFK") })
Reicht.UI.Toggle(misc, "AutoReconnect", { Text = T("Auto Reconnect", "เข้าเกมใหม่อัตโนมัติ"), Description = T("Joins back and reloads the hub after a disconnect", "หลุดแล้วเข้าเกมใหม่และโหลดสคริปต์ให้เอง") })
misc:AddButton({ Text = T("Rejoin", "เข้าเซิร์ฟใหม่"), Func = Reicht.UI.Detach("rejoin", Reicht.Server.Rejoin) })
:AddButton({ Text = T("Server Hop", "ย้ายเซิร์ฟ"), Func = Reicht.UI.Detach("hop", Reicht.Server.Hop) })
local esp = tab:AddRightGroupbox(T("Egg ESP", "มองเห็นไข่"), "eye")
Reicht.UI.KeyToggle(esp, "EggEsp", { Text = T("Egg ESP", "มองเห็นไข่"), Description = T("Shows eggs through walls with rarity and distance", "แสดงไข่ทะลุกำแพง พร้อมความหายากและระยะ") })
Reicht.UI.Bind("EspMinRarity", esp:AddDropdown("EspMinRarity", { Text = T("Minimum Rarity", "ความหายากขั้นต่ำ"), Values = Reicht.UI.Rarities(), Default = Reicht.GameLib.RarityOrder[1] }))
local perf = tab:AddRightGroupbox(T("Performance", "ประสิทธิภาพ"), "zap")
Reicht.UI.Toggle(perf, "HideOtherPets", { Text = T("Hide Other Pets", "ซ่อนสัตว์คนอื่น"), Description = T("Only your own pets stay visible", "เห็นแค่สัตว์ของเรา") })
Reicht.UI.Toggle(perf, "HideOtherEggs", { Text = T("Hide Other Eggs", "ซ่อนไข่คนอื่น"), Description = T("Hides eggs on other players' bases", "ซ่อนไข่ในฐานคนอื่น") })
Reicht.UI.Toggle(perf, "BoostFps", { Text = T("Boost FPS", "เพิ่ม FPS"), Description = T("Lower graphics for smoother play", "ลดกราฟิกให้ลื่นขึ้น") })
Reicht.UI.Toggle(perf, "UnlockFps", { Text = T("FPS Cap", "จำกัด FPS") })
Reicht.UI.Bind("FpsCap", perf:AddSlider("FpsCap", { Text = T("Max FPS", "FPS สูงสุด"), Min = 30, Max = 240, Default = Config.FpsCapDefault, Rounding = 0 }))
Reicht.UI.Toggle(perf, "Render3D", { Text = T("Disable 3D Rendering", "ปิดการเรนเดอร์ 3D"), Description = T("Black screen to save power while farming AFK", "จอดำ ประหยัดเครื่องตอนฟาร์ม AFK") })
end
local function BuildTabs()
local window = Library.Window
local try = Reicht.Util.Try
window:AddTabSection(T("Main", "หลัก"))
try("ui home", Reicht.UI.Home, window)
window:AddTabSection(T("Farming", "ฟาร์ม"))
try("ui eggs", Reicht.UI.EggFarm, window)
try("ui hatch", Reicht.UI.Hatching, window)
try("ui halloween", Reicht.UI.Halloween, window)
window:AddTabSection(T("Progression", "พัฒนา"))
try("ui pets", Reicht.UI.PetsTab, window)
try("ui upgrades", Reicht.UI.Upgrades, window)
window:AddTabSection(T("Misc", "อื่นๆ"))
try("ui teleport", Reicht.UI.TeleportTab, window)
try("ui player", Reicht.UI.PlayerTab, window)
try("ui settings", window.AddSettingsTab, window)
try("ui floats", Reicht.Move.BuildFloats, Reicht.UI.Floats)
Library:Every(Config.PumpTick, function() try("ui pump", Reicht.UI.Pump) end)
end
function Reicht.Boot()
Library = Reicht.Util.LoadLibrary(Config.UiSource)
if not Library then return false end
Library:CreateWindow({
Title = "Reicht",
SubTitle = "Ride A Pet by Reicht",
MenuKey = Enum.KeyCode.LeftControl,
ConfigFolder = "Ride A Pet",
Language = "Auto",
Theme = "Overworld",
OnUnlocked = function()
Reicht.Util.Try("gamelib load", Reicht.GameLib.LoadModules)
Reicht.Util.Try("gamelib build", Reicht.GameLib.Build)
Reicht.Util.Try("ui build", BuildTabs)
Reicht.Util.Try("scheduler", Reicht.Scheduler.Boot)
Reicht.Util.Try("autoload config", Library.LoadAutoloadConfig, Library)
task.spawn(function()
Reicht.Util.Try("gamelib check", Reicht.GameLib.Check)
Reicht.Util.Try("ui gate", Reicht.UI.Gate)
end)
end,
})
Reicht.BindTeardown(RunService.Heartbeat)
Library:OnUnload(function() Reicht:Unload() end)
return true
end
Reicht.Util.Try("boot", Reicht.Boot)