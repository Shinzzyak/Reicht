if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 1202096104 then
    game:GetService("Players").LocalPlayer:Kick("Reicht : this script is for Driving Empire only")
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
        "   DRIVING EMPIRE  //  by Reicht  //  ",
        "   executor: " .. executor .. "   //   player: " .. game:GetService("Players").LocalPlayer.Name,
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
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Reicht = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

Reicht.Config = {
    Discord = "https://",
    UpdateLog = {
        { "2026-10-03", "Classic Reicht UI is back\nBetter executor support\nFixed Noclip restore\nAuto-detect Jobs & Teleports" },
    },
    UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
    SaveFolder = "Driving Empire",
    LoadTimeout = 30,
    AlertTries = 20,
    AlertRetry = 0.5,
    JobFailLimit = 5,
    JobFailWindow = 10,
    SpawnerCacheFile = "Driving Empire/atm_spawners.json",
    TickDelay = 0.5,
    BustWait = 2.6,
    DebounceTimeout = 6,
    StreamWait = 0.5,
    SweepStep = 800,
    SweepHeight = 400,
    SweepDelay = 0.35,
    SweepMin = Vector3.new(-3500, 0, -6500),
    SweepMax = Vector3.new(7500, 0, 5000),
    CashOutCrimes = 5,
    DropOffStage = 8,
    DropOffSettle = 2.5,
    DropOffPayWait = 4,
    DropOffTries = 2,
    WantedSafety = 25,
    CopAvoidRadius = 45,
    RewardInterval = 60,
    EspInterval = 1,
    HopDelay = 4,
    DriveSpeed = 200,
    DriveAlign = 2,
    DriveLift = 3,
    DriveEdge = 120,
    DriveRoadMin = 1200,
    DriveRoadWidth = 30,
    DriveRoadFlat = 0.05,
    DriveRoadSeed = Vector3.new(-822, 21, -487),
    SpawnWait = 10,
    SpawnTries = 2,
    DropOffSeeds = {
        Vector3.new(-2543.3, 11.9, 4030.3),
        Vector3.new(7322.1, 197.8, -2811.6),
    },
    PlaceSeeds = {
        ["Job: Criminal"] = Vector3.new(135.2, 21.5, -1852.0),
        ["Job: Security"] = Vector3.new(148.2, 21.5, -1991.5),
        ["Job: Delivery"] = Vector3.new(122.5, 21.8, -1922.7),
        ["Job: Security HQ"] = Vector3.new(-109.8, 25.1, -956.8),
        ["Spawn Dealership"] = Vector3.new(-482, 14, -1767),
    },
    Codes = {
        "RAMBO", "AIRDROP", "UWU", "RECORD", "USA250", "10KITS", "MARCH2026", "HAPPY2026", "CALL911", "GOBBLEGOBBLE",
        "SPOOKY", "VEGAS2025", "WHOOPS", "RDCNASCAR25", "2MLIKES", "NASCAR100M", "CUSTOMIZATION2025",
        "200KMEMBERS", "NEWYEAR2025", "ZOOM", "HAPPYXMAS",
        "1MILLIONLIKES", "1MILCASH",
    },
    CodeDelay = 1.5,
}

local Config = Reicht.Config

Reicht.State = {
    Alive = true,
    Messages = {},
    Halted = {},
    Busy = false,
    Stats = nil,
    Spawners = {},
    LastReward = 0,
    LastEsp = 0,
    AtmSession = { Busted = 0, Earned = 0, CashedOut = 0, StartCash = 0 },
    AtmWarn = nil,
    Banking = false,
    BankOnStop = false,
    DriveConn = nil,
    DriveRoad = nil,
    CollideBackup = setmetatable({}, { __mode = "k" }),
    Conns = {},
    EspObjects = {},
    LightingBackup = nil,
    Opt = {
        AtmFarm = false,
        HopWhenEmpty = false,
        AvoidCops = false,
        CashOutCrimes = 10,
        DriveFarm = false,
        DriveCar = nil,
        AutoPlaytime = false,
        AutoClaimMisc = false,
        Code = "",
        WalkSpeed = 16,
        JumpPower = 50,
        SpeedEnabled = false,
        Noclip = false,
        InfiniteJump = false,
        Fullbright = false,
        AntiAfk = false,
        AutoRejoin = false,
        EspAtm = false,
        EspCops = false,
        EspDropOff = false,
        CarSpeed = 0,
    },
}

local State = Reicht.State

for _, name in ipairs({ "Util", "Player", "Vehicle", "Jobs", "Atm", "Drive", "Rewards", "Teleport", "Esp", "Movement", "Session", "Scheduler" }) do
    Reicht[name] = {}
end

function Reicht.Util.Try(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[Driving Empire]", err)
    end
    return ok, err
end

---@return string?  body, nil when every way to fetch failed
function Reicht.Util.HttpGet(url)
    local ok, body = pcall(game.HttpGet, game, url)
    if ok and type(body) == "string" then
        return body
    end
    local requestFn = (type(request) == "function" and request) or (type(http_request) == "function" and http_request)
        or (type(syn) == "table" and syn.request)
    if type(requestFn) ~= "function" then
        return nil
    end
    local sent, response = pcall(requestFn, { Url = url, Method = "GET" })
    if not sent or type(response) ~= "table" or tonumber(response.StatusCode) ~= 200 or type(response.Body) ~= "string" then
        return nil
    end
    return response.Body
end

---@param text string  shown as a Roblox notification, works before the menu exists
function Reicht.Util.Alert(text)
    warn("[Driving Empire] " .. text)
    task.spawn(function()
        local starterGui = game:GetService("StarterGui")
        for _ = 1, Config.AlertTries do
            if pcall(starterGui.SetCore, starterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 }) then
                return
            end
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

---@param instance Instance  parented to gethui, then CoreGui, then PlayerGui
function Reicht.Util.Mount(instance)
    local ok, hui = pcall(gethui)
    if ok and typeof(hui) == "Instance" and pcall(function() instance.Parent = hui end) then
        return
    end
    if pcall(function() instance.Parent = game:GetService("CoreGui") end) then
        return
    end
    instance.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", Config.LoadTimeout)
end

function Reicht.Util.Stats()
    if State.Stats and State.Stats.Parent then return State.Stats end
    local folder = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(LocalPlayer.Name .. "'s Stats")
    local data = Reicht.GameLib.Data
    State.Stats = folder or (data and data.GetLoadedStatsFolder(LocalPlayer))
    return State.Stats
end

function Reicht.Util.Cash()
    local stats = Reicht.Util.Stats()
    local cash = stats and stats:FindFirstChild("Cash")
    return cash and cash.Value or 0
end

function Reicht.Util.Commas(number)
    local text = tostring(math.floor(number))
    repeat
        local count
        text, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until count == 0
    return text
end

Reicht.GameLib = {}
local GameLib = Reicht.GameLib

---@return Instance?  child at the end of the path, nil when any step is missing
function GameLib.Find(root, ...)
    local node = root
    for _, name in ipairs({ ... }) do
        node = node and node:FindFirstChild(name)
    end
    return node
end

---@return Instance?  module at the path, else the first ModuleScript with that name anywhere under root
function GameLib.Locate(root, ...)
    local found = GameLib.Find(root, ...)
    if found or not root then return found end
    local name = select(select("#", ...), ...)
    for _, desc in ipairs(root:GetDescendants()) do
        if desc.Name == name and desc:IsA("ModuleScript") then return desc end
    end
    return nil
end

---@return RemoteEvent?  by name in the Remotes folder, else anywhere in ReplicatedStorage
function GameLib.Remote(name)
    local remote = GameLib.RemoteFolder and GameLib.RemoteFolder:FindFirstChild(name)
    remote = remote or ReplicatedStorage:FindFirstChild(name, true)
    return remote and remote:IsA("RemoteEvent") and remote or nil
end

---Plain require first; identity-3 executors get "Cannot require a non-RobloxScript module", so retry once from a fresh identity-2 thread.
---@return table?  module, nil when this executor cannot load it
function GameLib.Require(module)
    if not module or not module:IsA("ModuleScript") then return nil end
    local ok, loaded = pcall(require, module)
    if ok then return loaded end
    local setIdentity = setthreadidentity or setidentity
    local getIdentity = getthreadidentity or getidentity
    if type(setIdentity) ~= "function" or type(getIdentity) ~= "function" then return nil end
    local done, retried = false, nil
    task.spawn(function()
        pcall(setIdentity, 2)
        local switched = select(2, pcall(getIdentity)) == 2
        local again, value = false, nil
        if switched then again, value = pcall(require, module) end
        done, retried = true, again and value or nil
    end)
    local deadline = os.clock() + Config.LoadTimeout
    repeat
        if not done then task.wait() end
    until done or os.clock() > deadline
    return retried
end

do
    local modules = ReplicatedStorage:WaitForChild("Modules", Config.LoadTimeout)
    GameLib.RemoteFolder = ReplicatedStorage:WaitForChild("Remotes", Config.LoadTimeout)
    GameLib.Remotes = GameLib.Require(GameLib.Locate(modules, "Shared", "Remotes"))
    GameLib.Data = GameLib.Require(GameLib.Locate(modules, "Shared", "Data"))
    GameLib.JobsController = GameLib.Require(GameLib.Locate(modules, "Client", "Jobs", "JobsController"))
    GameLib.JobsConstants = GameLib.Require(GameLib.Locate(modules, "Shared", "Jobs", "JobsConstants"))
    GameLib.VehicleController = GameLib.Require(GameLib.Locate(modules, "Client", "Vehicles", "VehicleController"))
    GameLib.TeleportGuard = GameLib.Require(GameLib.Locate(modules, "Client", "Exploit", "VehicleTeleportDetectionController"))
    GameLib.PlayRewardUtil = GameLib.Require(GameLib.Locate(modules, "Shared", "PlayRewards", "PlayRewardUtil"))

    GameLib.VehicleEvent = GameLib.Remote("VehicleEvent")
    GameLib.CodeRemote = GameLib.Remote("Code")
    GameLib.AtmFolder = GameLib.Find(workspace, "Game", "Jobs", "CriminalATMSpawners") or workspace:FindFirstChild("CriminalATMSpawners", true)
end

GameLib.Needs = {
    AtmFarm = { "Remotes", "JobsController", "AtmFolder" },
    DriveFarm = { "VehicleController", "TeleportGuard", "JobsController", "VehicleEvent" },
    AutoPlaytime = { "Remotes", "PlayRewardUtil" },
    AutoClaimMisc = { "Remotes" },
    EspAtm = { "AtmFolder" },
}

GameLib.Parts = {
    VehicleEvent = "remote VehicleEvent",
    CodeRemote = "remote Code",
    AtmFolder = "folder CriminalATMSpawners",
}

---@return string?  first game module the feature needs that did not load
function GameLib.Missing(idx)
    for _, name in ipairs(GameLib.Needs[idx] or {}) do
        if not GameLib[name] then return name end
    end
    return nil
end

---@return Instance[]  ATM spawners, empty when the folder is gone
function GameLib.AtmSpawners()
    local folder = GameLib.AtmFolder
    if not folder or not folder.Parent then
        folder = GameLib.Find(workspace, "Game", "Jobs", "CriminalATMSpawners")
        GameLib.AtmFolder = folder
    end
    return folder and folder:GetChildren() or {}
end

function Reicht.Player.Character()
    local character = LocalPlayer.Character
    if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
        return character
    end
    return nil
end

function Reicht.Player.Humanoid()
    local character = Reicht.Player.Character()
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Reicht.Player.Root()
    local character = Reicht.Player.Character()
    return character and character.HumanoidRootPart
end

function Reicht.Player.TeleportTo(cframe)
    local root = Reicht.Player.Root()
    if not root then
        return false
    end
    if Reicht.Vehicle.IsSeated() then
        Reicht.Vehicle.Despawn()
        task.wait(1)
    end
    root.CFrame = cframe
    root.AssemblyLinearVelocity = Vector3.zero
    return true
end

function Reicht.Vehicle.Current()
    if not GameLib.VehicleController then return nil end
    local vehicle = GameLib.VehicleController.getVehicle()
    return vehicle and vehicle.Object
end

function Reicht.Vehicle.IsSeated()
    local humanoid = Reicht.Player.Humanoid()
    return humanoid ~= nil and humanoid.SeatPart ~= nil
end

function Reicht.Vehicle.Owned()
    local owned = {}
    local stats = Reicht.Util.Stats()
    if not stats then
        return owned
    end
    local vehicles = stats:FindFirstChild("Vehicles")
    if not vehicles then return owned end
    for _, entry in ipairs(vehicles:GetChildren()) do
        if entry.Value == true then
            table.insert(owned, entry.Name)
        end
    end
    table.sort(owned)
    return owned
end

function Reicht.Vehicle.Spawn(vehicleId)
    if not vehicleId or not GameLib.VehicleEvent then
        return nil
    end
    GameLib.VehicleEvent:FireServer("Spawn", vehicleId)
    local deadline = os.clock() + Config.SpawnWait
    repeat
        task.wait(0.25)
    until Reicht.Vehicle.Current() or os.clock() > deadline
    return Reicht.Vehicle.Current()
end

function Reicht.Vehicle.Despawn()
    if not GameLib.VehicleEvent then return end
    GameLib.VehicleEvent:FireServer("Despawn")
end

---@return boolean  moved the car, or the character when on foot
function Reicht.Vehicle.TeleportTo(cframe)
    local car = Reicht.Vehicle.Current()
    if not car or not Reicht.Vehicle.IsSeated() then
        local root = Reicht.Player.Root()
        if root then
            root.CFrame = cframe
        end
        return root ~= nil
    end
    if not GameLib.TeleportGuard then
        return Reicht.Player.TeleportTo(cframe)
    end
    GameLib.TeleportGuard.AuthorizeNextTeleport()
    car:PivotTo(cframe)
    if car.PrimaryPart then
        car.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
    end
    return true
end

function Reicht.Vehicle.ApplySpeed()
    local car = Reicht.Vehicle.Current()
    local boost = State.Opt.CarSpeed
    if not car or not car.PrimaryPart or boost <= 0 or not Reicht.Vehicle.IsSeated() then
        return
    end
    if not UserInputService:IsKeyDown(Enum.KeyCode.W) then
        return
    end
    local root = car.PrimaryPart
    local flat = root.CFrame.LookVector * Vector3.new(1, 0, 1)
    if flat.Magnitude < 0.1 then
        return
    end
    local velocity = root.AssemblyLinearVelocity
    local forward = velocity:Dot(flat.Unit)
    local target = math.max(forward, boost)
    root.AssemblyLinearVelocity = flat.Unit * target + Vector3.new(0, velocity.Y, 0)
end

function Reicht.Jobs.Current()
    return LocalPlayer:GetAttribute("JobId")
end

---@return string[]  job ids the game defines plus any job pad on the map, sorted
function Reicht.Jobs.List()
    local seen, list = {}, {}
    local function Add(jobId)
        if type(jobId) ~= "string" or seen[jobId] then return end
        seen[jobId] = true
        list[#list + 1] = jobId
    end
    local constants = GameLib.JobsConstants
    for _, jobId in pairs(constants and constants.JobIds or {}) do
        Add(jobId)
    end
    for _, pad in ipairs(CollectionService:GetTagged("JobPad")) do
        Add(pad:GetAttribute("JobId"))
    end
    table.sort(list)
    return list
end

function Reicht.Jobs.Start(jobId)
    if Reicht.Jobs.Current() == jobId then
        return true
    end
    if not GameLib.JobsController then
        return false
    end
    GameLib.JobsController.RequestStartJobSession(jobId, "jobPad")
    local deadline = os.clock() + 4
    repeat
        task.wait(0.2)
    until Reicht.Jobs.Current() == jobId or os.clock() > deadline
    return Reicht.Jobs.Current() == jobId
end

function Reicht.Jobs.Leave()
    if Reicht.Jobs.Current() and GameLib.JobsController then
        GameLib.JobsController.RequestEndJobSession("jobPad")
    end
end

function Reicht.Atm.LoadCache()
    local read, text = pcall(function()
        return isfile(Config.SpawnerCacheFile) and readfile(Config.SpawnerCacheFile)
    end)
    if not read or type(text) ~= "string" then
        return
    end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, text)
    if not ok or type(decoded) ~= "table" then
        return
    end
    for id, coords in pairs(decoded) do
        State.Spawners[id] = Vector3.new(coords[1], coords[2], coords[3])
    end
end

function Reicht.Atm.SaveCache()
    local encoded = {}
    for id, position in pairs(State.Spawners) do
        encoded[id] = { position.X, position.Y, position.Z }
    end
    local saved, err = pcall(function()
        if not isfolder("Driving Empire") then
            makefolder("Driving Empire")
        end
        writefile(Config.SpawnerCacheFile, HttpService:JSONEncode(encoded))
    end)
    if not saved then
        warn("[Driving Empire] atm cache:", err)
    end
end

function Reicht.Atm.SpawnerCount()
    local count = 0
    for _ in pairs(State.Spawners) do
        count += 1
    end
    return count
end

local function RecordStreamedSpawners()
    for _, spawner in ipairs(GameLib.AtmSpawners()) do
        local id = spawner:GetAttribute("ComponentServerId")
        if id then
            State.Spawners[id] = spawner.Position
        end
    end
end

function Reicht.Atm.Sweep()
    local root = Reicht.Player.Root()
    if not root then
        return 0
    end
    if Reicht.Vehicle.IsSeated() then
        Reicht.Vehicle.Despawn()
        task.wait(1)
    end
    for x = Config.SweepMin.X, Config.SweepMax.X, Config.SweepStep do
        for z = Config.SweepMin.Z, Config.SweepMax.Z, Config.SweepStep do
            if not State.Alive then
                return Reicht.Atm.SpawnerCount()
            end
            root.CFrame = CFrame.new(x, Config.SweepHeight, z)
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(Config.SweepDelay)
            RecordStreamedSpawners()
        end
    end
    Reicht.Atm.SaveCache()
    return Reicht.Atm.SpawnerCount()
end

local function FindAtm(spawnerId)
    for _, spawner in ipairs(GameLib.AtmSpawners()) do
        if spawner:GetAttribute("ComponentServerId") == spawnerId then
            return spawner:FindFirstChild("CriminalATM")
        end
    end
    return nil
end

function Reicht.Atm.IsAvailable(atm)
    if not atm or atm:GetAttribute("State") ~= "Normal" then
        return false
    end
    local engaging = atm:GetAttribute("EngagingPlayerId")
    return engaging == nil or engaging == LocalPlayer.UserId
end

function Reicht.Atm.CopNearby(position)
    for _, other in ipairs(Players:GetPlayers()) do
        local character = other ~= LocalPlayer and other.Character
        if character and other:GetAttribute("JobId") == "Security" then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - position).Magnitude < Config.CopAvoidRadius then
                return true
            end
        end
    end
    return false
end

local function WaitForDebounce(character)
    local deadline = os.clock() + Config.DebounceTimeout
    while character:GetAttribute("ATMBustDebounce") and os.clock() < deadline do
        task.wait(0.1)
    end
end

---@return boolean, string?  robbed, else the server's reason
function Reicht.Atm.Bust(atm)
    local character = Reicht.Player.Character()
    if not GameLib.Remotes then
        return false, "Not available on this executor"
    end
    if not character or not Reicht.Atm.IsAvailable(atm) then
        return false, "Unavailable"
    end
    local attachment = atm:FindFirstChild("PromptAttachment")
    local target = attachment and attachment.WorldPosition or atm:GetPivot().Position
    if State.Opt.AvoidCops and Reicht.Atm.CopNearby(target) then
        return false, "CopNearby"
    end
    WaitForDebounce(character)
    character.HumanoidRootPart.CFrame = CFrame.lookAt(target + atm:GetPivot().LookVector * 3, target)
    task.wait(0.25)
    local started, reason = GameLib.Remotes.invokeServer("AttemptATMBustStart", atm)
    if not started then
        return false, reason
    end
    task.wait(Config.BustWait)
    local earnedBefore = character:GetAttribute("CurrencyEarned") or 0
    local done, failReason = GameLib.Remotes.invokeServer("AttemptATMBustComplete", atm)
    if not done then
        return false, failReason
    end
    State.AtmSession.Busted += 1
    task.defer(function()
        task.wait(0.5)
        State.AtmSession.Earned += math.max(0, (character:GetAttribute("CurrencyEarned") or 0) - earnedBefore)
    end)
    return true
end

function Reicht.Atm.DropOffPositions()
    local positions = {}
    for _, point in ipairs(CollectionService:GetTagged("CriminalDropOffPoint")) do
        table.insert(positions, point:GetPivot().Position)
    end
    if #positions == 0 then
        return Config.DropOffSeeds
    end
    return positions
end

function Reicht.Atm.NearestDropOff()
    local root = Reicht.Player.Root()
    local best, bestDistance = nil, math.huge
    for _, position in ipairs(Reicht.Atm.DropOffPositions()) do
        local distance = root and (position - root.Position).Magnitude or 0
        if distance < bestDistance then
            best, bestDistance = position, distance
        end
    end
    return best
end

function Reicht.Atm.Crimes()
    local character = Reicht.Player.Character()
    return character and character:GetAttribute("CrimesCommitted") or 0
end

---@return boolean        paid
---@return number|string  cash gained, or why it did not pay
function Reicht.Atm.CashOut()
    if Reicht.Atm.Crimes() < Config.CashOutCrimes then
        return false, "Need 5 stars first"
    end
    local seed = Reicht.Atm.NearestDropOff()
    if not seed then return false, "No drop-off found" end

    local stage = Vector3.new(0, 3, Config.DropOffStage)
    local cashBefore = Reicht.Util.Cash()
    State.Banking = true
    Reicht.Player.TeleportTo(CFrame.new(seed + stage))
    task.wait(Config.StreamWait)
    local target = Reicht.Atm.NearestDropOff() or seed

    for _ = 1, Config.DropOffTries do
        Reicht.Player.TeleportTo(CFrame.new(target + stage))
        task.wait(Config.DropOffSettle)
        Reicht.Player.TeleportTo(CFrame.new(target + Vector3.new(0, 3, 0)))
        local deadline = os.clock() + Config.DropOffPayWait
        repeat
            task.wait(0.25)
        until Reicht.Util.Cash() > cashBefore or os.clock() > deadline
        if Reicht.Util.Cash() > cashBefore or Reicht.Atm.Crimes() < Config.CashOutCrimes then break end
    end
    State.Banking = false

    local gained = Reicht.Util.Cash() - cashBefore
    if gained <= 0 then return false, "The drop-off did not pay" end
    State.AtmSession.CashedOut += gained
    return true, gained
end

function Reicht.Atm.RunPass()
    if not Reicht.Jobs.Start("Criminal") then
        State.AtmWarn = "Could not start the Criminal job"
        error(State.AtmWarn, 0)
    end
    State.AtmWarn = nil
    if Reicht.Atm.SpawnerCount() == 0 then
        Reicht.Atm.Sweep()
    end
    local busted = 0
    for id, position in pairs(State.Spawners) do
        if not State.Opt.AtmFarm or not State.Alive then
            break
        end
        Reicht.Player.TeleportTo(CFrame.new(position + Vector3.new(0, 6, 0)))
        local atm
        local deadline = os.clock() + Config.StreamWait
        repeat
            task.wait(0.1)
            atm = FindAtm(id)
        until atm or os.clock() > deadline
        RecordStreamedSpawners()
        if Reicht.Atm.IsAvailable(atm) and Reicht.Atm.Bust(atm) then
            busted += 1
        end
        local crimes = Reicht.Atm.Crimes()
        if crimes >= State.Opt.CashOutCrimes or (crimes >= Config.CashOutCrimes and Reicht.Atm.WantedLeft() < Config.WantedSafety) then
            Reicht.Atm.CashOut()
        end
    end
    return busted
end

function Reicht.Atm.WantedLeft()
    local character = Reicht.Player.Character()
    local expire = character and character:GetAttribute("CriminalExpireEpoch")
    return expire and expire - workspace:GetServerTimeNow() or math.huge
end

function Reicht.Atm.FarmStep()
    local busted = Reicht.Atm.RunPass()
    if not State.Opt.AtmFarm then
        return
    end
    if Reicht.Atm.Crimes() >= State.Opt.CashOutCrimes then
        Reicht.Atm.CashOut()
    end
    if busted == 0 and State.Opt.HopWhenEmpty and Reicht.Atm.Crimes() == 0 then
        Reicht.Session.Hop()
    end
end

function Reicht.Atm.NearestAvailable()
    local root = Reicht.Player.Root()
    if not root then return nil end
    local best, bestDistance
    for _, spawner in ipairs(GameLib.AtmSpawners()) do
        local atm = spawner:FindFirstChild("CriminalATM")
        if Reicht.Atm.IsAvailable(atm) then
            local distance = (spawner.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = atm, distance
            end
        end
    end
    return best
end

---@return boolean, string?  robbed, else why not
function Reicht.Atm.RobNearest()
    if not Reicht.Jobs.Start("Criminal") then
        return false, "Could not start the Criminal job"
    end
    local atm = Reicht.Atm.NearestAvailable()
    if not atm then
        return false, "No ATM nearby"
    end
    return Reicht.Atm.Bust(atm)
end

---@return table?  Center, Axis, Half, Top of the longest flat asphalt road; nil if none is loaded
function Reicht.Drive.FindRoad()
    local road = State.DriveRoad
    if road and road.Part.Parent then return road end
    local best, bestLength = nil, Config.DriveRoadMin
    for _, part in ipairs((workspace:FindFirstChild("Map") or workspace):GetDescendants()) do
        if not part:IsA("BasePart") or part.Material ~= Enum.Material.Asphalt or not part.CanCollide then continue end
        local size = part.Size
        local length, width = math.max(size.X, size.Z), math.min(size.X, size.Z)
        local axis = size.X >= size.Z and part.CFrame.RightVector or part.CFrame.LookVector
        if length > bestLength and width >= Config.DriveRoadWidth and math.abs(axis.Y) < Config.DriveRoadFlat then
            best, bestLength = { Part = part, Axis = (axis * Vector3.new(1, 0, 1)).Unit, Length = length }, length
        end
    end
    if not best then return nil end
    local part = best.Part
    State.DriveRoad = {
        Part = part,
        Center = part.Position,
        Axis = best.Axis,
        Half = best.Length / 2 - Config.DriveEdge,
        Top = part.Position.Y + part.Size.Y / 2 + Config.DriveLift,
    }
    return State.DriveRoad
end

---@return table?  road, streamed in when it is not loaded yet
function Reicht.Drive.LoadRoad()
    local road = Reicht.Drive.FindRoad()
    if road then return road end
    pcall(LocalPlayer.RequestStreamAroundAsync, LocalPlayer, Config.DriveRoadSeed, Config.LoadTimeout)
    task.wait(Config.StreamWait)
    return Reicht.Drive.FindRoad()
end

function Reicht.Drive.Warp(road)
    local start = road.Center - road.Axis * road.Half
    local spot = Vector3.new(start.X, road.Top, start.Z)
    Reicht.Vehicle.TeleportTo(CFrame.lookAt(spot, spot + road.Axis))
end

function Reicht.Drive.Step(road)
    local car = Reicht.Vehicle.Current()
    local root = car and car.PrimaryPart
    if not root or not Reicht.Vehicle.IsSeated() then return end
    local offset = root.Position - road.Center
    local along = offset:Dot(road.Axis)
    if along > road.Half then
        Reicht.Drive.Warp(road)
        return
    end
    local side = offset - road.Axis * along
    side = Vector3.new(side.X, 0, side.Z)
    local fall = math.min(root.AssemblyLinearVelocity.Y, 0)
    root.AssemblyLinearVelocity = road.Axis * Config.DriveSpeed - side * Config.DriveAlign + Vector3.new(0, fall, 0)
end

function Reicht.Drive.Board()
    local carId = State.Opt.DriveCar or Reicht.Vehicle.Owned()[1]
    for _ = 1, Config.SpawnTries do
        local car = Reicht.Vehicle.Spawn(carId)
        if car then return car end
    end
    return nil
end

---@return boolean, string?  started, else why not
function Reicht.Drive.Start()
    if State.DriveConn then return true end
    Reicht.Jobs.Leave()
    local road = Reicht.Drive.LoadRoad()
    if not road then return false, "No paved road found" end
    local car = Reicht.Vehicle.Current()
    if not car or not Reicht.Vehicle.IsSeated() then
        car = Reicht.Drive.Board()
    end
    if not car then return false, "No car to drive" end
    task.wait(1)
    Reicht.Drive.Warp(road)
    task.wait(1)
    if not State.Opt.DriveFarm or State.DriveConn then return true end
    State.DriveConn = RunService.Heartbeat:Connect(function()
        Reicht.Drive.Step(road)
    end)
    return true
end

function Reicht.Drive.Stop()
    if State.DriveConn then
        State.DriveConn:Disconnect()
        State.DriveConn = nil
    end
    local car = Reicht.Vehicle.Current()
    if car and car.PrimaryPart then
        car.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
    end
end

function Reicht.Rewards.ClaimPlaytime()
    local ok, unclaimed = pcall(function()
        local pending = GameLib.PlayRewardUtil.getUnclaimedRewards(LocalPlayer)
        if type(pending) == "table" and pending.expect then
            pending = pending:expect()
        end
        return pending
    end)
    if not ok or type(unclaimed) ~= "table" then
        return 0
    end
    local count = 0
    for index in pairs(unclaimed) do
        GameLib.Remotes.fireServer("PlayRewards", tonumber(index) or index, false)
        count += 1
        task.wait(0.5)
    end
    return count
end

function Reicht.Rewards.ClaimMisc()
    if not GameLib.Remotes then return end
    GameLib.Remotes.fireServer("ClaimRewards")
    GameLib.Remotes.fireServer("RaceLeaderboardClaimRewards")
end

function Reicht.Rewards.Redeemed()
    local stats = Reicht.Util.Stats()
    local codes = stats and stats:FindFirstChild("Codes")
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, codes and codes.Value or "")
    return ok and type(decoded) == "table" and decoded or {}
end

---@return number, number  new codes redeemed, cash gained
function Reicht.Rewards.RedeemCodes(codes)
    if not GameLib.CodeRemote then return 0, 0 end
    local redeemedBefore = Reicht.Rewards.Redeemed()
    local cashBefore = Reicht.Util.Cash()
    local success = 0
    for _, code in ipairs(codes) do
        if not redeemedBefore[code] then
            GameLib.CodeRemote:FireServer(code)
            task.wait(Config.CodeDelay)
            if Reicht.Rewards.Redeemed()[code] then
                success += 1
            end
        end
    end
    return success, Reicht.Util.Cash() - cashBefore
end

function Reicht.Teleport.Destinations()
    local destinations = {}
    local names = {}
    local function Add(name, position)
        if position and not destinations[name] then
            destinations[name] = position
            table.insert(names, name)
        end
    end
    local padCount = {}
    for _, pad in ipairs(CollectionService:GetTagged("JobPad")) do
        local jobId = pad:GetAttribute("JobId")
        if jobId and pad:IsA("BasePart") then
            padCount[jobId] = (padCount[jobId] or 0) + 1
            Add(padCount[jobId] == 1 and "Job: " .. jobId or ("Job: %s %d"):format(jobId, padCount[jobId]), pad.Position)
        end
    end
    for name, position in pairs(Config.PlaceSeeds) do
        Add(name, position)
    end
    for index, position in ipairs(Reicht.Atm.DropOffPositions()) do
        Add(("Criminal Drop-off %d"):format(index), position)
    end
    local heist = GameLib.Find(workspace, "Game", "Heists", "BankHeist")
    local heistStart = heist and heist:FindFirstChild("HeistStartTeleport", true)
    if heistStart then
        Add("Bank Heist", heistStart.Position)
    end
    local dealerships = workspace.Game:FindFirstChild("Dealerships")
    dealerships = dealerships and dealerships:FindFirstChild("Dealerships")
    if dealerships then
        for _, dealership in ipairs(dealerships:GetChildren()) do
            local part = dealership:FindFirstChildWhichIsA("BasePart", true)
            if part then
                Add("Dealership: " .. dealership.Name, part.Position)
            end
        end
    end
    table.sort(names)
    return names, destinations
end

function Reicht.Teleport.Go(position)
    if not position then
        return
    end
    LocalPlayer:RequestStreamAroundAsync(position, 5)
    Reicht.Vehicle.TeleportTo(CFrame.new(position + Vector3.new(0, 5, 0)))
end

function Reicht.Teleport.ToPlayer(name)
    local target = Players:FindFirstChild(name)
    local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root then
        Reicht.Teleport.Go(root.Position + Vector3.new(0, 0, 4))
    end
end

function Reicht.Movement.Step()
    local opt = State.Opt
    local character = Reicht.Player.Character()
    local humanoid = Reicht.Player.Humanoid()
    if not character or not humanoid then
        return
    end
    if opt.SpeedEnabled and not Reicht.Vehicle.IsSeated() then
        humanoid.WalkSpeed = opt.WalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = opt.JumpPower
    end
    if opt.Noclip then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                State.CollideBackup[part] = true
                part.CanCollide = false
            end
        end
    end
    Reicht.Vehicle.ApplySpeed()
end

function Reicht.Movement.SetNoclip(enabled)
    if enabled then return end
    for part, original in pairs(State.CollideBackup) do
        if part.Parent then
            part.CanCollide = original
        end
    end
    table.clear(State.CollideBackup)
end

function Reicht.Movement.ResetSpeed()
    local humanoid = Reicht.Player.Humanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

function Reicht.Movement.SetFullbright(enabled)
    if enabled then
        State.LightingBackup = State.LightingBackup or {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient,
        }
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        return
    end
    if State.LightingBackup then
        for property, value in pairs(State.LightingBackup) do
            Lighting[property] = value
        end
        State.LightingBackup = nil
    end
end

function Reicht.Movement.Bind()
    table.insert(State.Conns, RunService.Stepped:Connect(function()
        Reicht.Scheduler.Run(Reicht.Scheduler.MovementJob)
    end))
    table.insert(State.Conns, UserInputService.JumpRequest:Connect(function()
        local humanoid = Reicht.Player.Humanoid()
        if State.Opt.InfiniteJump and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

local function EspMark(key, adornee, text, color)
    local entry = State.EspObjects[key]
    if entry and entry.Highlight.Parent and entry.Highlight.Adornee == adornee then
        entry.Label.Text = text
        return
    end
    if entry then
        entry.Highlight:Destroy()
        entry.Billboard:Destroy()
    end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = color
    highlight.Adornee = adornee
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Reicht.Util.Mount(highlight)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(160, 28)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = adornee
    Reicht.Util.Mount(billboard)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Text = text
    label.Parent = billboard
    State.EspObjects[key] = { Highlight = highlight, Billboard = billboard, Label = label }
end

function Reicht.Esp.Refresh()
    local opt = State.Opt
    local root = Reicht.Player.Root()
    local alive = {}
    local function Distance(position)
        return root and math.floor((position - root.Position).Magnitude) or 0
    end
    if opt.EspAtm then
        for _, spawner in ipairs(GameLib.AtmSpawners()) do
            local atm = spawner:FindFirstChild("CriminalATM")
            if Reicht.Atm.IsAvailable(atm) then
                local key = "atm" .. tostring(spawner:GetAttribute("ComponentServerId"))
                alive[key] = true
                EspMark(key, atm, ("ATM %s · %dm"):format(tostring(atm:GetAttribute("Rarity")), Distance(spawner.Position)), Color3.fromRGB(90, 220, 120))
            end
        end
    end
    if opt.EspCops then
        for _, other in ipairs(Players:GetPlayers()) do
            local character = other.Character
            local job = other:GetAttribute("JobId")
            if other ~= LocalPlayer and character and character:FindFirstChild("HumanoidRootPart") and job then
                local key = "plr" .. other.UserId
                alive[key] = true
                local color = job == "Security" and Color3.fromRGB(80, 140, 255) or job == "Criminal" and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(232, 160, 76)
                EspMark(key, character, ("%s [%s] · %dm"):format(other.DisplayName, job, Distance(character.HumanoidRootPart.Position)), color)
            end
        end
    end
    if opt.EspDropOff then
        for index, point in ipairs(CollectionService:GetTagged("CriminalDropOffPoint")) do
            local key = "drop" .. index
            alive[key] = true
            EspMark(key, point, ("Drop-off · %dm"):format(Distance(point:GetPivot().Position)), Color3.fromRGB(255, 210, 80))
        end
    end
    for key, entry in pairs(State.EspObjects) do
        if not alive[key] then
            entry.Highlight:Destroy()
            entry.Billboard:Destroy()
            State.EspObjects[key] = nil
        end
    end
end

function Reicht.Session.Bind()
    table.insert(State.Conns, LocalPlayer.Idled:Connect(function()
        if State.Opt.AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end
    end))
    table.insert(State.Conns, GuiService.ErrorMessageChanged:Connect(function()
        if not State.Opt.AutoRejoin then
            return
        end
        task.wait(Config.HopDelay)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end))
end

function Reicht.Session.Hop()
    local body = Reicht.Util.HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(game.PlaceId))
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body or "")
    if not ok or type(decoded) ~= "table" then
        return false
    end
    local candidates = {}
    for _, server in ipairs(decoded.data or {}) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers - 1 then
            table.insert(candidates, server.id)
        end
    end
    if #candidates == 0 then
        return false
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[math.random(#candidates)], LocalPlayer)
    return true
end

function Reicht.Scheduler.AtmStep()
    if State.Opt.AtmFarm then
        Reicht.Atm.FarmStep()
        return
    end
    if not State.BankOnStop then return end
    State.BankOnStop = false
    if Reicht.Atm.Crimes() < Config.CashOutCrimes then return end

    local ok, got = Reicht.Atm.CashOut()
    if ok then
        Reicht.UI.Notify("Banked $" .. Reicht.Util.Commas(got) .. " before stopping", "Success")
    else
        Reicht.UI.Notify("Wanted cash not banked: " .. got, "Warning")
    end
end

function Reicht.Scheduler.RewardStep()
    local opt = State.Opt
    local now = os.clock()
    if not (opt.AutoPlaytime or opt.AutoClaimMisc) or now - State.LastReward <= Config.RewardInterval then
        return
    end
    State.LastReward = now
    if opt.AutoPlaytime then
        Reicht.Rewards.ClaimPlaytime()
    end
    if opt.AutoClaimMisc then
        Reicht.Rewards.ClaimMisc()
    end
end

function Reicht.Scheduler.EspStep()
    local now = os.clock()
    if now - State.LastEsp > Config.EspInterval then
        State.LastEsp = now
        Reicht.Esp.Refresh()
    end
end

Reicht.Scheduler.Jobs = {
    { "ATM Farm", Reicht.Scheduler.AtmStep, { "AtmFarm" } },
    { "Rewards", Reicht.Scheduler.RewardStep, { "AutoPlaytime", "AutoClaimMisc" } },
    { "ESP", Reicht.Scheduler.EspStep, { "EspAtm", "EspCops", "EspDropOff" }, Core = true },
}

Reicht.Scheduler.MovementJob = { "Movement", Reicht.Movement.Step, { "SpeedEnabled", "Noclip" } }

---@param job table  { label, step, toggle idxs }
---@return boolean   any of the job's features is on
function Reicht.Scheduler.Wanted(job)
    for _, idx in ipairs(job[3]) do
        if State.Opt[idx] then return true end
    end
    return false
end

---Turns the job's features off after Config.JobFailLimit errors spanning Config.JobFailWindow seconds; the UI pump flips the toggles (this thread has touched game modules) and their callbacks restore.
---@param job table  { label, step, toggle idxs, Core = never rests }
function Reicht.Scheduler.Run(job)
    if job.Stopped then
        if not Reicht.Scheduler.Wanted(job) then return end
        job.Stopped = nil
    end
    local ok, err = pcall(job[2])
    if ok then
        job.Streak = nil
        return
    end

    local streak = job.Streak
    if not streak then
        streak = { count = 0, since = os.clock() }
        job.Streak = streak
        warn("[Driving Empire] " .. job[1] .. ":", err)
    end
    streak.count += 1
    if streak.count < Config.JobFailLimit or os.clock() - streak.since < Config.JobFailWindow then return end

    local switched = Reicht.Scheduler.Wanted(job)
    if job.Core and not switched then return end
    job.Streak = nil
    job.Stopped = not job.Core and not switched
    for _, idx in ipairs(job[3]) do
        if State.Opt[idx] then
            State.Opt[idx] = false
            table.insert(State.Halted, idx)
        end
    end

    local reason = tostring(err):match("^[^\n]*")
    warn("[Driving Empire] " .. job[1] .. " stopped:", reason)
    if switched then Reicht.UI.Notify(job[1] .. " stopped: " .. reason, "Warning") end
end

function Reicht.Scheduler.Boot()
    Reicht.Atm.LoadCache()
    Reicht.Movement.Bind()
    Reicht.Session.Bind()
    task.spawn(function()
        while State.Alive do
            if not State.Busy then
                State.Busy = true
                for _, job in ipairs(Reicht.Scheduler.Jobs) do
                    Reicht.Scheduler.Run(job)
                end
                State.Busy = false
            end
            task.wait(Config.TickDelay)
        end
    end)
end

function Reicht.Scheduler.Stop()
    State.Alive = false
    for key in pairs(State.Opt) do
        if type(State.Opt[key]) == "boolean" and key ~= "AntiAfk" then
            State.Opt[key] = false
        end
    end
    Reicht.Drive.Stop()
    Reicht.Movement.SetNoclip(false)
    Reicht.Movement.ResetSpeed()
    Reicht.Movement.SetFullbright(false)
    for _, conn in ipairs(State.Conns) do
        conn:Disconnect()
    end
    table.clear(State.Conns)
    Reicht.Esp.Refresh()
end

Reicht.UI = {}
local Library, T

---@param kind string?  Info, Success, Warning or Error
function Reicht.UI.Notify(text, kind)
    State.Messages[#State.Messages + 1] = { text, kind }
end

function Reicht.UI.Spawn(action)
    return function()
        task.spawn(Reicht.Util.Try, action)
    end
end

function Reicht.UI.StartDrive()
    local started, reason = Reicht.Drive.Start()
    if started then return end
    State.Opt.DriveFarm = false
    table.insert(State.Halted, "DriveFarm")
    Reicht.UI.Notify(reason or "Could not start driving", "Warning")
end

---@param onChange function?  runs after State.Opt is updated
function Reicht.UI.Toggle(group, key, text, description, onChange, risky)
    return group:AddToggle(key, {
        Text = text,
        Description = description,
        Default = State.Opt[key],
        Risky = risky,
        Callback = function(value)
            State.Opt[key] = value
            if onChange then
                Reicht.Util.Try(onChange, value)
            end
        end,
    })
end

function Reicht.UI.Slider(group, key, text, description, min, max)
    local opt = State.Opt
    return group:AddSlider(key, {
        Text = text,
        Description = description,
        Min = min, Max = max, Default = opt[key], Rounding = 0,
        Callback = function(value)
            opt[key] = tonumber(value) or opt[key]
        end,
    })
end

function Reicht.UI.Panic()
    for idx, toggle in pairs(Library.Toggles) do
        if type(State.Opt[idx]) == "boolean" and toggle.Value == true then
            toggle:SetValue(false)
        end
    end
end

---@return string  one line for the status label
function Reicht.UI.AtmStatus()
    if State.Banking then return "Cashing out" end
    if State.AtmWarn then return "Warn: " .. State.AtmWarn end
    if not State.Opt.AtmFarm then return "Off" end
    return ("Robbing · %d stars"):format(Reicht.Atm.Crimes())
end

function Reicht.UI.StatusText()
    local session = State.AtmSession
    local char = Reicht.Player.Character()
    local carried = char and char:GetAttribute("CurrencyEarned") or 0
    return ("ATM Farm: %s · Drive: %s\nCash $%s · Job %s · Stars %d\nATMs robbed %d · Wanted cash $%s · Cashed out $%s\nATM spots known %d"):format(
        Reicht.UI.AtmStatus(), State.Opt.DriveFarm and "Driving" or "Off",
        Reicht.Util.Commas(Reicht.Util.Cash()), tostring(Reicht.Jobs.Current() or "Citizen"), Reicht.Atm.Crimes(),
        session.Busted, Reicht.Util.Commas(carried), Reicht.Util.Commas(session.CashedOut), Reicht.Atm.SpawnerCount())
end

function Reicht.UI.BuildAtm(farmTab)
    local atmBox = farmTab:AddLeftGroupbox(T("ATM Farm", "ฟาร์ม ATM"))
    local wasOn = false
    Reicht.UI.Toggle(atmBox, "AtmFarm", T("Auto ATM Farm", "ฟาร์ม ATM อัตโนมัติ"), T("Robs every ATM on the map with the full crime bonus, then cashes out", "ปล้น ATM ทุกตู้ในแมพพร้อมโบนัสอาชญากรรมเต็ม แล้วส่งเงิน"), function(on)
        if on then State.AtmWarn = nil end
        State.BankOnStop = wasOn and not on and Reicht.Atm.Crimes() >= Config.CashOutCrimes
        wasOn = on
    end, true):AddKeyPicker("AtmFarmKey", { Default = "None", Mode = "Toggle" })
    Reicht.UI.Slider(atmBox, "CashOutCrimes", T("Cash Out At Robberies", "ส่งเงินเมื่อปล้นครบ"), T("Banks the loot after this many robberies (higher = more risk)", "ส่งเงินหลังปล้นครบจำนวนนี้ (ยิ่งมากยิ่งเสี่ยง)"), 5, 30)

    atmBox:AddButton({ Text = T("Rob Nearest ATM", "ปล้น ATM ที่ใกล้ที่สุด"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        local ok, reason = Reicht.Atm.RobNearest()
        Reicht.UI.Notify(ok and "ATM robbed" or ("Failed: " .. tostring(reason)), ok and "Success" or "Warning")
    end) }):AddButton({ Text = T("Cash Out Now", "ส่งเงินเดี๋ยวนี้"), Func = Reicht.UI.Spawn(function()
        local ok, got = Reicht.Atm.CashOut()
        Reicht.UI.Notify(ok and ("Cashed out $" .. Reicht.Util.Commas(got)) or got, ok and "Success" or "Warning")
    end) })
    atmBox:AddButton({ Text = T("Scan Map For ATMs", "สแกนหา ATM ทั้งแมพ"), Func = Reicht.UI.Spawn(function()
        Reicht.UI.Notify(("Found %d ATM spots"):format(Reicht.Atm.Sweep()))
    end) })
end

function Reicht.UI.BuildAtmSafety(farmTab)
    local safetyBox = farmTab:AddRightGroupbox(T("ATM Safety", "ความปลอดภัย ATM"))
    Reicht.UI.Toggle(safetyBox, "HopWhenEmpty", T("Server Hop When Empty", "ย้ายเซิร์ฟเมื่อ ATM หมด"), T("Moves to a new server once every ATM is taken", "ย้ายไปเซิร์ฟใหม่เมื่อ ATM ถูกปล้นหมดแล้ว"))
    Reicht.UI.Toggle(safetyBox, "AvoidCops", T("Avoid Police", "หลบตำรวจ"), T("Skips ATMs with police standing close", "ข้าม ATM ที่มีตำรวจอยู่ใกล้"))
end

function Reicht.UI.BuildFarm(window)
    local farmTab = window:AddTab(T("Farm", "ฟาร์ม"), "zap", T("Money farming", "ฟาร์มเงิน"))

    local statusBox = farmTab:AddLeftGroupbox(T("Status", "สถานะ"))
    Reicht.UI.StatusLabel = statusBox:AddLabel("Loading...", true)
    statusBox:AddButton({ Text = T("Panic - All Off", "ฉุกเฉิน ปิดทั้งหมด"), Style = "Danger", Func = Reicht.UI.Panic })

    Reicht.UI.BuildAtm(farmTab)

    local discordBox = farmTab:AddRightGroupbox(T("Discord", "Discord"), "link")
    discordBox:AddLabel(Config.Discord)
    discordBox:AddButton({ Text = T("Copy Discord Link", "คัดลอกลิงก์ Discord"), Style = "Primary", Func = function()
        local copy = setclipboard or toclipboard
        local copied = type(copy) == "function" and pcall(copy, Config.Discord)
        Reicht.UI.Notify(copied and "Discord link copied" or Config.Discord)
    end })

    local logBox = farmTab:AddRightGroupbox(T("Update Log", "อัปเดตล่าสุด"), "bell")
    for i = 1, math.min(2, #Config.UpdateLog) do
        local entry = Config.UpdateLog[i]
        logBox:AddParagraph({ Title = entry[1], Content = entry[2] })
    end

    Reicht.UI.BuildAtmSafety(farmTab)

    local jobBox = farmTab:AddRightGroupbox(T("Jobs", "อาชีพ"))
    local jobDropdown = jobBox:AddDropdown("JobPick", {
        Text = T("Switch Job", "เปลี่ยนอาชีพ"),
        Values = Reicht.Jobs.List(),
        Default = 1,
        Callback = function(value)
            State.Opt.JobPick = value
        end,
    })
    jobBox:AddButton({ Text = T("Start Job", "เริ่มงาน"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        Reicht.UI.Notify(Reicht.Jobs.Start(State.Opt.JobPick or "Criminal") and "Job started" or "Could not start job")
    end) }):AddButton({ Text = T("Quit Job", "ออกจากงาน"), Func = Reicht.UI.Spawn(Reicht.Jobs.Leave) })
        :AddButton({ Text = T("Refresh", "รีเฟรช"), Func = function()
            jobDropdown:SetValues(Reicht.Jobs.List())
        end })

    local driveBox = farmTab:AddRightGroupbox(T("Drive Farm", "ฟาร์มขับรถ"))
    Reicht.UI.Toggle(driveBox, "DriveFarm", T("Auto Drive", "ขับรถอัตโนมัติ"), T("Drives nonstop for passive cash", "ขับไม่หยุดเพื่อรับเงินจากการขับ"), function(on)
        if not on then
            Reicht.Drive.Stop()
            return
        end
        task.spawn(Reicht.Util.Try, Reicht.UI.StartDrive)
    end):AddKeyPicker("DriveFarmKey", { Default = "None", Mode = "Toggle" })
end

function Reicht.UI.BuildRewards(window)
    local rewardTab = window:AddTab(T("Rewards", "รางวัล"), "bell", T("Codes and claims", "โค้ดและรับรางวัล"))

    local codeBox = rewardTab:AddLeftGroupbox(T("Codes", "โค้ด"))
    codeBox:AddButton({ Text = T("Redeem All Codes", "ใช้โค้ดทั้งหมด"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        if not GameLib.CodeRemote then
            Reicht.UI.Notify("The code box was not found in this game version", "Warning")
            return
        end
        local count, cash = Reicht.Rewards.RedeemCodes(Config.Codes)
        Reicht.UI.Notify(("Redeemed %d new codes (+$%s)"):format(count, Reicht.Util.Commas(cash)))
    end) })
    codeBox:AddInput("Code", {
        Text = T("Custom Code", "ใส่โค้ดเอง"),
        Default = "",
        Finished = true,
        NoSave = true,
        Callback = function(value)
            State.Opt.Code = value
        end,
    })
    codeBox:AddButton({ Text = T("Redeem", "ใช้โค้ด"), Func = Reicht.UI.Spawn(function()
        local count = Reicht.Rewards.RedeemCodes({ State.Opt.Code })
        Reicht.UI.Notify(count > 0 and "Code redeemed" or "Code invalid or already used")
    end) })

    local claimBox = rewardTab:AddRightGroupbox(T("Claims", "รับรางวัล"))
    Reicht.UI.Toggle(claimBox, "AutoPlaytime", T("Auto Playtime Rewards", "รับรางวัลเวลาเล่นอัตโนมัติ"), T("Claims cash, cars and packs as soon as they unlock", "รับเงิน รถ และแพ็กทันทีที่ปลดล็อก"))
        :AddKeyPicker("AutoPlaytimeKey", { Default = "None", Mode = "Toggle" })
    Reicht.UI.Toggle(claimBox, "AutoClaimMisc", T("Auto Claim Pending", "รับรางวัลค้างอัตโนมัติ"), T("Claims pending race and event rewards", "รับรางวัลแข่งและอีเวนต์ที่ค้างอยู่"))
    claimBox:AddButton({ Text = T("Claim All Now", "รับทั้งหมดเดี๋ยวนี้"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        local count = Reicht.Rewards.ClaimPlaytime()
        Reicht.Rewards.ClaimMisc()
        Reicht.UI.Notify(("Claimed %d playtime rewards"):format(count))
    end) })
end

function Reicht.UI.BuildVehicle(window)
    local carTab = window:AddTab(T("Vehicle", "รถ"), "play", T("Cars and driving", "รถและการขับ"))
    local read, owned = pcall(Reicht.Vehicle.Owned)
    owned = read and owned or {}
    State.Opt.DriveCar = owned[1]

    local carBox = carTab:AddLeftGroupbox(T("Garage", "โรงรถ"))
    local carDropdown = carBox:AddDropdown("DriveCar", {
        Text = T("Car", "รถ"),
        Values = owned,
        Default = 1,
        Searchable = true,
        Callback = function(value)
            State.Opt.DriveCar = value
        end,
    })
    carBox:AddButton({ Text = T("Spawn Car", "เรียกรถ"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        Reicht.UI.Notify(Reicht.Vehicle.Spawn(State.Opt.DriveCar) and "Car spawned" or "Spawn failed")
    end) }):AddButton({ Text = T("Despawn", "เก็บรถ"), Func = Reicht.UI.Spawn(Reicht.Vehicle.Despawn) })
        :AddButton({ Text = T("Refresh", "รีเฟรช"), Func = function()
            carDropdown:SetValues(Reicht.Vehicle.Owned())
        end })

    local tuneBox = carTab:AddRightGroupbox(T("Performance", "สมรรถนะ"))
    Reicht.UI.Slider(tuneBox, "CarSpeed", T("Car Speed Boost", "เร่งความเร็วรถ"), T("Holds this speed while pressing W (0 = off)", "คงความเร็วนี้ขณะกด W (0 = ปิด)"), 0, 600)
end

local function PlayerNames()
    local names = {}
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= LocalPlayer then table.insert(names, other.Name) end
    end
    return names
end

function Reicht.UI.BuildTeleport(window)
    local teleportTab = window:AddTab(T("Teleport", "วาร์ป"), "globe", T("Go anywhere", "ไปได้ทุกที่"))
    local read, destNames, destinations = pcall(Reicht.Teleport.Destinations)
    if not read then destNames, destinations = {}, {} end

    local placeBox = teleportTab:AddLeftGroupbox(T("Places", "สถานที่"))
    local placeDropdown = placeBox:AddDropdown("Place", {
        Text = T("Destination", "จุดหมาย"),
        Values = destNames,
        Default = 1,
        Searchable = true,
        Callback = function(value)
            State.Opt.Place = value
        end,
    })
    placeBox:AddButton({ Text = T("Teleport", "วาร์ป"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        Reicht.Teleport.Go(destinations[State.Opt.Place or destNames[1]])
    end) }):AddButton({ Text = T("Refresh", "รีเฟรช"), Func = function()
        destNames, destinations = Reicht.Teleport.Destinations()
        placeDropdown:SetValues(destNames)
    end })

    local playerBox = teleportTab:AddRightGroupbox(T("Players", "ผู้เล่น"))
    local playerDropdown = playerBox:AddDropdown("TargetPlayer", {
        Text = T("Player", "ผู้เล่น"),
        Values = PlayerNames(),
        Searchable = true,
        AllowNull = true,
        NoSave = true,
        Callback = function(value)
            State.Opt.TargetPlayer = value
        end,
    })
    playerBox:AddButton({ Text = T("Teleport To Player", "วาร์ปไปหาผู้เล่น"), Style = "Primary", Func = Reicht.UI.Spawn(function()
        Reicht.Teleport.ToPlayer(State.Opt.TargetPlayer)
    end) }):AddButton({ Text = T("Refresh", "รีเฟรช"), Func = function()
        playerDropdown:SetValues(PlayerNames())
    end })
end

function Reicht.UI.BuildPlayer(window)
    local playerTab = window:AddTab(T("Player", "ผู้เล่น"), "user", T("Movement", "การเคลื่อนที่"))

    local moveBox = playerTab:AddLeftGroupbox(T("Movement", "การเคลื่อนที่"))
    Reicht.UI.Toggle(moveBox, "SpeedEnabled", T("Custom Speed", "ปรับความเร็วเอง"), T("Uses the speed and jump below while on foot", "ใช้ความเร็วและแรงกระโดดด้านล่างตอนเดิน"), function(on)
        if not on then Reicht.Movement.ResetSpeed() end
    end):AddKeyPicker("SpeedEnabledKey", { Default = "None", Mode = "Toggle" })
    Reicht.UI.Slider(moveBox, "WalkSpeed", T("Walk Speed", "ความเร็วเดิน"), nil, 16, 200)
    Reicht.UI.Slider(moveBox, "JumpPower", T("Jump Power", "แรงกระโดด"), nil, 50, 300)

    local abilityBox = playerTab:AddRightGroupbox(T("Abilities", "ความสามารถ"))
    Reicht.UI.Toggle(abilityBox, "Noclip", T("Noclip", "ทะลุวัตถุ"), T("Walk through walls", "เดินทะลุกำแพง"), Reicht.Movement.SetNoclip)
    Reicht.UI.Toggle(abilityBox, "InfiniteJump", T("Infinite Jump", "กระโดดไม่จำกัด"), T("Jump again in mid air", "กระโดดซ้ำกลางอากาศได้"))

    local worldBox = playerTab:AddRightGroupbox(T("World", "โลก"))
    Reicht.UI.Toggle(worldBox, "Fullbright", T("Fullbright", "สว่างเต็มจอ"), T("Always daylight", "กลางวันตลอด"), Reicht.Movement.SetFullbright)
end

function Reicht.UI.BuildVisuals(window)
    local visualTab = window:AddTab(T("Visuals", "ภาพ"), "eye", T("ESP", "ESP"))
    local espBox = visualTab:AddLeftGroupbox(T("Robbery", "การปล้น"))
    Reicht.UI.Toggle(espBox, "EspAtm", T("ATMs", "ATM"), T("Shows every ATM you can rob with its rarity", "โชว์ ATM ที่ปล้นได้ทุกตู้พร้อมระดับ"))
    Reicht.UI.Toggle(espBox, "EspDropOff", T("Drop-off Points", "จุดส่งเงิน"), T("Where outlaws cash out", "จุดที่โจรไปส่งเงิน"))

    local peopleBox = visualTab:AddRightGroupbox(T("Players", "ผู้เล่น"))
    Reicht.UI.Toggle(peopleBox, "EspCops", T("Players By Job", "ผู้เล่นตามอาชีพ"), T("Blue = police, red = outlaw, orange = delivery", "น้ำเงิน = ตำรวจ, แดง = โจร, ส้ม = ส่งของ"))
end

function Reicht.UI.BuildSettings(window)
    local settingsTab = window:AddSettingsTab()
    local sessionBox = settingsTab:AddRightGroupbox(T("Session", "เซสชัน"))
    Reicht.UI.Toggle(sessionBox, "AntiAfk", T("Anti AFK", "กันหลุด AFK"), T("Never get kicked for idling", "ไม่โดนเตะเพราะยืนนิ่ง"))
    Reicht.UI.Toggle(sessionBox, "AutoRejoin", T("Auto Rejoin", "เข้าเกมใหม่อัตโนมัติ"), T("Rejoins after a disconnect", "หลุดแล้วเข้าเกมใหม่เอง"))
    sessionBox:AddButton({ Text = T("Server Hop", "ย้ายเซิร์ฟ"), Func = Reicht.UI.Spawn(Reicht.Session.Hop) })
end

---Features whose game module or remote is missing refuse to turn on and say why, instead of erroring every tick.
function Reicht.UI.GateModules()
    local noExecutor = T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้")
    local changed = T("Not found after a game update", "หาไม่เจอหลังเกมอัปเดต")
    local en, th = {}, {}
    for idx in pairs(GameLib.Needs) do
        local option = Library.Options[idx]
        local missing = option and GameLib.Missing(idx)
        if missing then
            Library.Compat.Block(option, GameLib.Parts[missing] and changed or noExecutor)
            warn("[Driving Empire] " .. idx .. " off, missing " .. (GameLib.Parts[missing] or "module " .. missing))
            en[#en + 1] = option.Info.Text.EN
            table.insert(th, option.Info.Text.TH)
        end
    end
    if not GameLib.CodeRemote then warn("[Driving Empire] Redeem off, missing remote Code") end
    if #en == 0 then return end

    Library:Notify("Driving Empire", T("Not available on this executor: " .. table.concat(en, ", "), "ใช้กับ executor นี้ไม่ได้: " .. table.concat(th, ", ")), 8, "Warning")
end

---Runs on the UI's own thread: game-module threads cannot touch widgets, so halts and messages wait here.
function Reicht.UI.Pump()
    while #State.Messages > 0 do
        local msg = table.remove(State.Messages, 1)
        Library:Notify("Driving Empire", msg[1], 5, msg[2])
    end
    while #State.Halted > 0 do
        local toggle = Library.Toggles[table.remove(State.Halted, 1)]
        if toggle and toggle.Value then toggle:SetValue(false) end
    end
    local label = Reicht.UI.StatusLabel
    if label then label:SetText(Reicht.UI.StatusText()) end
end

function Reicht.UI.Build()
    local window = Library.Window
    local try = Reicht.Util.Try
    window:AddTabSection(T("Main", "หลัก"))
    for _, build in ipairs({ Reicht.UI.BuildFarm, Reicht.UI.BuildRewards, Reicht.UI.BuildVehicle, Reicht.UI.BuildTeleport, Reicht.UI.BuildPlayer, Reicht.UI.BuildVisuals, Reicht.UI.BuildSettings }) do
        try(build, window)
    end
    try(Reicht.UI.GateModules)
    Library:Every(1, Reicht.UI.Pump)
end

---@return boolean  false when the menu could not load
local function BuildInterface()
    Library = Reicht.Util.LoadLibrary()
    if not Library then return false end
    Reicht.Library = Library
    pcall(ReichtBanner.Step, "UI library")
    T = function(en, th) return Library:T(en, th) end

    Library:OnUnload(function()
        Reicht.Scheduler.Stop()
        getgenv().DrivingEmpireUnload = nil
    end)
    getgenv().DrivingEmpireUnload = function()
        Library:Unload()
    end

    Library:CreateWindow({
        Title = "Reicht",
        SubTitle = "Driving Empire by Reicht",
        MenuKey = Enum.KeyCode.LeftControl,
        ConfigFolder = Config.SaveFolder,
        Language = "Auto",
        Theme = "Overworld",
        Intro = true,
        OnUnlocked = function()
            Reicht.UI.Build()
            Reicht.Util.Try(Reicht.Scheduler.Boot)
            Reicht.UI.Notify("Loaded", "Success")
            Reicht.Util.Try(Library.LoadAutoloadConfig, Library)
        end,
    })
    return true
end

if getgenv().DrivingEmpireUnload then
    pcall(getgenv().DrivingEmpireUnload)
end

pcall(ReichtBanner.Step, "Systems")
if BuildInterface() then
    pcall(ReichtBanner.Step, "Interface")
    pcall(ReichtBanner.Ready)
end