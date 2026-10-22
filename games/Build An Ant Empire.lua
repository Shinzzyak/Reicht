if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 10436530264 then
    game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Build An Ant Empire only")
    return
end

do
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" and type(env.AntEmpireUnload) == "function" then
        pcall(env.AntEmpireUnload)
    end
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
        "   BUILD AN ANT EMPIRE  //  by Reicht  //  ",
        "   executor: " .. executor .. "   //   player: " .. game:GetService("Players").LocalPlayer.Name,
        rule,
    }, "\n"))
end

---@param label string
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
    local function Passthrough(fn)
        return fn
    end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local Reicht = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

Reicht.Config = {
    SaveFolder = "Build An Ant Empire",
    Discord = "https://",
    GameId = 10436530264,
    PlaceId = 78490532994307,
    UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
    UpdateLog = {
        { "2026-10-15", "Added Build An Ant Empire support\nKaitun, food farming and auto sell\nAuto roll, rarity filters and best ants\nPool and stat upgrades with a cash reserve\nReichtBanner and reliable Stop All" },
    },
    LoadTimeout = 30,
    RemoteTimeout = 20,
    RequireTimeout = 3,
    AlertTries = 12,
    AlertDelay = 0.5,
    TickDelay = 0.08,
    StatusInterval = 1.2,
    PumpInterval = 0.2,
    ReplyTimeout = 4,
    RollSlack = 0.08,
    MaxJobTime = 10,
    CodeGap = 10.2,
    Codes = { "10000members", "cyberants", "wnixh2", "9hcb2s" },
    Needs = {
        AutoSell = { "Packages.EventBus.RemoteEvent" },
        AutoPool = { "Packages.EventBus.RemoteEvent", "_genConfigs.battle_tbpoollevelupgrade" },
        AutoAttr = { "Packages.EventBus.RemoteEvent", "_genConfigs.battle_tbattribute" },
        AutoRoll = { "Packages.EventBus.RemoteEvent", "_genConfigs.battle_tbraritypool" },
        AutoEquipBest = { "UI.Backpack.Model.BackpackModel" },
        AutoOnlineAward = { "UI.OnlineReward.Model.OnlineState" },
        AutoActivity = { "Packages.EventBus.RemoteEvent", "_genConfigs.battle_tbactivityshop" },
        CodeRedeem = { "Packages.CodeService" },
    },
}

local Config = Reicht.Config

Reicht.State = {
    Alive = true,
    StopGen = 0,
    ThreadGenerations = setmetatable({}, { __mode = "k" }),
    Conns = {},
    Replies = {},
    InFlight = {},
    PendingRolls = {},
    Collision = {},
    Actions = {},
    UiQueue = {},
    Buttons = {},
    Metrics = { Rolls = 0, Claims = 0, Sales = 0, Gold = 0 },
    ChildThreads = {},
    Failures = {},
    Halted = {},
    StatusLines = {},
    FoodPrice = 0,
    PriceTime = 0,
    GearShop = nil,
    BossActive = false,
    SeenCodes = {},
    CodeResults = {},
    Opt = {
        KeepGold = 1000,
        SellMinPrice = 0,
        Kaitun = false,
        AutoSell = false,
        SellDelay = 1.5,
        AutoCollectFood = false,
        AutoWorkerFood = false,
        AutoAntRewards = false,
        UpgradePriority = "Pool first",
        ClaimRarities = {},
        AutoPool = false,
        PoolBurst = 5,
        AutoAttr = false,
        AttrTarget = "Ant Attack Power",
        UpgradeAllAttr = false,
        AutoRoll = false,
        AutoClaimRolled = false,
        RollDelay = 3.1,
        AutoEquipBest = false,
        AutoPlaceAnts = false,
        AutoCompostPull = false,
        AutoCompostUpgrade = false,
        AutoOnlineAward = false,
        AutoActivity = false,
        AutoLootBossCoins = false,
        SpeedOn = false,
        WalkSpeed = 200,
        FlyOn = false,
        FlySpeed = 120,
        NoclipOn = false,
        InfJump = false,
        AntiAfk = false,
        Fullbright = false,
        EspPlayers = false,
        EspBoss = false,
        EspDungeon = false,
        EspDist = 800,
    },
}

local State = Reicht.State
local Library
local GuiService = game:GetService("GuiService")
Reicht.Platform = {
    Touch = UserInputService.TouchEnabled,
    Mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    Console = GuiService:IsTenFootInterface(),
    Viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720),
}

Reicht.GameLib = { Loaded = {}, Failed = {}, Apis = {}, Deferred = {} }

---@param module Instance
---@return boolean, any
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

---@param module Instance
---@return table?
function Reicht.GameLib.Require(module)
    if not module or not module:IsA("ModuleScript") then return nil end
    local cached = Reicht.GameLib.Loaded[module]
    if cached ~= nil or Reicht.GameLib.Failed[module] then
        return cached
    end

    local result
    local thread = Reicht.Util.Child(function()
        result = table.pack(pcall(require, module))
    end)
    local deadline = os.clock() + Config.RequireTimeout
    while not result and os.clock() < deadline do
        task.wait()
    end
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
            warn("[AntEmpire] require", module:GetFullName(), firstErr)
            return nil
        end
    end
    Reicht.GameLib.Loaded[module] = loaded
    return loaded
end

---@param fn function
---@return boolean, any ...
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

---@param fn function
---@return any ...
function Reicht.GameLib.Call(fn, ...)
    if not Reicht.GameLib.Deferred[fn] then
        local result = table.pack(pcall(fn, ...))
        if result[1] or not tostring(result[2]):find("non-RobloxScript", 1, true) then
            if not result[1] then
                error(result[2], 0)
            end
            return table.unpack(result, 2, result.n)
        end
        Reicht.GameLib.Deferred[fn] = true
    end
    local result = table.pack(Reicht.GameLib.CallAsGame(fn, ...))
    if not result[1] then
        error(result[2], 0)
    end
    return table.unpack(result, 2, result.n)
end

---@param module Instance
---@return table
function Reicht.GameLib.Need(module)
    local loaded = Reicht.GameLib.Require(module)
    if loaded == nil then
        error(("game data %s.%s can't be read on this executor"):format(module.Parent.Name, module.Name), 0)
    end
    return loaded
end

---@param path string
---@return Instance?
function Reicht.GameLib.Find(path)
    local node = ReplicatedStorage
    for part in path:gmatch("[^%.]+") do
        node = node and node:FindFirstChild(part)
    end
    if node then
        return node
    end
    return nil
end

---@return table
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

for _, name in ipairs({ "Util", "Data", "Player", "Colony", "Farm", "Economy", "Progression", "Shop", "Boss", "Rewards", "Movement", "Esp", "Scheduler", "Collect", "Teleport" }) do
    Reicht[name] = {}
end

---@param fn function
---@return thread
function Reicht.Util.Child(fn)
    for thread in pairs(State.ChildThreads) do
        if coroutine.status(thread) == "dead" then State.ChildThreads[thread] = nil end
    end
    local generation = State.StopGen
    local thread = task.defer(function()
        State.ThreadGenerations[coroutine.running()] = generation
        fn()
    end)
    State.ChildThreads[thread] = true
    return thread
end

function Reicht:Connect(signal, fn)
    for index = #State.Conns, 1, -1 do
        if not State.Conns[index].Connected then table.remove(State.Conns, index) end
    end
    local conn = signal:Connect(fn)
    State.Conns[#State.Conns + 1] = conn
    return conn
end

function Reicht.Util.Later(fn)
    State.UiQueue[#State.UiQueue + 1] = fn
end

function Reicht.Util.Pump()
    local queued = State.UiQueue
    State.UiQueue = {}
    for _, fn in ipairs(queued) do Reicht.Util.Try(fn) end
    if State.ActivityDropdown then Reicht.Util.ActivityIcons() end
end

function Reicht.Util.ActivityIcons()
    local dropdown = State.ActivityDropdown
    local sprites = Reicht.Data.ActivitySprites
    if not dropdown or not sprites then return end
    local sprite = sprites[dropdown.Value]
    if dropdown.Thumb and sprite then
        dropdown.Thumb.ImageRectOffset = sprite.ImageRectOffset or Vector2.zero
        dropdown.Thumb.ImageRectSize = sprite.ImageRectSize or Vector2.zero
    end
    if dropdown.List == State.ActivityPopup then return end
    State.ActivityPopup = dropdown.List
    if not dropdown.List or not Library.Window or not Library.Window.Root.Parent then return end
    for _, image in ipairs(Library.Window.Root.Parent:QueryDescendants("ImageLabel")) do
        if image.Name == "Thumb" and image.Parent:IsA("TextButton") then
            local label = image.Parent:FindFirstChildWhichIsA("TextLabel")
            local entry = label and sprites[label.Text]
            if entry then
                image.ImageRectOffset = entry.ImageRectOffset or Vector2.zero
                image.ImageRectSize = entry.ImageRectSize or Vector2.zero
            end
        end
    end
end

function Reicht.Util.Await(check, timeout)
    local deadline = os.clock() + (timeout or Config.ReplyTimeout)
    repeat
        if not State.Alive or not Reicht.Util.Current() then return false end
        local value = check()
        if value then return value end
        task.wait(0.04)
    until os.clock() >= deadline
    return false
end

function Reicht.Util.Current()
    local generation = State.ThreadGenerations[coroutine.running()]
    return generation == nil or generation == State.StopGen
end

function Reicht.Util.Action(key, fn)
    if not State.Alive or not Reicht.Util.Current() then return false end
    local owner = State.Actions[key]
    if owner and coroutine.status(owner) ~= "dead" then return false end
    State.Actions[key] = coroutine.running()
    local result = table.pack(pcall(fn))
    State.Actions[key] = nil
    if not result[1] then error(result[2], 0) end
    return table.unpack(result, 2, result.n)
end

function Reicht.Util.Bounded(fn, timeout, ...)
    local args = table.pack(...)
    local result
    local thread = Reicht.Util.Child(function()
        result = table.pack(pcall(fn, table.unpack(args, 1, args.n)))
    end)
    if not Reicht.Util.Await(function() return result ~= nil end, timeout) then
        pcall(task.cancel, thread)
        return false, "Timed out"
    end
    return table.unpack(result, 1, result.n)
end

function Reicht.Util.Button(group, info)
    local callback = info.Func
    local busy = false
    info.Func = function()
        if busy or not State.Alive then return end
        busy = true
        Reicht.Util.Child(function()
            local ok, result = Reicht.Util.Bounded(callback, Config.MaxJobTime)
            busy = false
            if not ok then
                Reicht.Util.PushStatus("Action", tostring(result))
                Reicht.Util.Later(function() Library:Notify("Reicht", tostring(result), 4, "Error") end)
            end
        end)
    end
    local button = group:AddButton(info)
    State.Buttons[#State.Buttons + 1] = button
    return button
end

---@param url string
---@return string?, string?
function Reicht.Util.HttpGet(url)
    local ok, body = Reicht.Util.Bounded(function()
        return game:HttpGet(url)
    end, Config.RemoteTimeout)
    if ok and type(body) == "string" and #body > 100 then
        return body, nil
    end

    local send = request or http_request or (syn and syn.request) or (http and http.request)
    if not send then
        return nil, tostring(body)
    end
    local sent, response = Reicht.Util.Bounded(send, Config.RemoteTimeout, { Url = url, Method = "GET" })
    if not sent then
        return nil, tostring(response)
    end
    if type(response) ~= "table" or response.StatusCode ~= 200 or type(response.Body) ~= "string" then
        return nil, "HTTP " .. tostring(type(response) == "table" and response.StatusCode)
    end
    return response.Body, nil
end

---@param text string
---@param detail string?
function Reicht.Util.Alert(text, detail)
    warn("[AntEmpire] menu:", text, detail or "")
    task.spawn(function()
        for _ = 1, Config.AlertTries do
            local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
                Title = "Reicht",
                Text = text,
                Duration = 8,
            })
            if shown then return end
            task.wait(Config.AlertDelay)
        end
    end)
end

---@return table?
function Reicht.Util.LoadLibrary()
    local body, err = Reicht.Util.HttpGet(Config.UiSource)
    if not body or not body:sub(-64):find("return Library%s*$") then
        Reicht.Util.Alert("Could not download menu. Check network connection.", err or "truncated body")
        return nil
    end
    local chunk, compileErr = loadstring(body)
    if not chunk then
        Reicht.Util.Alert("The menu failed to load on this executor: " .. tostring(compileErr))
        return nil
    end
    local ok, library = pcall(chunk)
    if not ok or type(library) ~= "table" then
        Reicht.Util.Alert("The menu failed to initialize: " .. tostring(library))
        return nil
    end
    return library
end

---@param key string
---@param err any
function Reicht.Util.WarnJob(key, err)
    State.Failures[key] = (State.Failures[key] or 0) + 1
    if State.Failures[key] >= 5 and not State.Halted[key] then
        State.Halted[key] = true
        local option = key == "Kaitun" and "KaitunMaster" or key
        State.Opt[key] = false
        if key == "AutoCompost" then State.Opt.AutoCompostPull, State.Opt.AutoCompostUpgrade = false, false end
        warn(string.format("[AntEmpire] %s stopped: %s", key, tostring(err)))
        Reicht.Util.Later(function()
            if Library and Library.Options[option] then Library.Options[option]:SetValue(false) end
            if Library then Library:Notify("Reicht", key .. " stopped: " .. tostring(err), 5, "Error") end
        end)
    end
end

---@param fn function
---@return boolean, any
function Reicht.Util.Try(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[AntEmpire]", err)
    end
    return ok, err
end

---@param key string
---@param text string?
function Reicht.Util.PushStatus(key, text)
    State.StatusLines[key] = (text and text ~= "") and text or nil
end

---@return string
function Reicht.Util.StatusText()
    local parts = {}
    for _, v in pairs(State.StatusLines) do
        parts[#parts + 1] = v
    end
    table.sort(parts)
    return #parts > 0 and table.concat(parts, "  |  ") or "Colony Active"
end

---@param text string
function Reicht.Util.Clipboard(text)
    pcall(function()
        if setclipboard then
            setclipboard(text)
        elseif toclipboard then
            toclipboard(text)
        end
    end)
end

---@return Model?
function Reicht.Util.GetChar()
    return LocalPlayer.Character
end

---@return BasePart?
function Reicht.Util.GetHRP()
    if State.Root and State.Root.Parent then return State.Root end
    return nil
end

---@return Humanoid?
function Reicht.Util.GetHum()
    if State.Humanoid and State.Humanoid.Parent then return State.Humanoid end
    return nil
end

local EventRE = Reicht.GameLib.Find("Packages.EventBus.RemoteEvent")
if not EventRE then
    Reicht.Util.Alert("Game connection is unavailable. Rejoin and try again.")
    return
end

Reicht.GameLib.Apis.Context = Reicht.GameLib.Require(Reicht.GameLib.Find("UI._global.Ecs"))
Reicht.GameLib.Apis.Context = Reicht.GameLib.Apis.Context and Reicht.GameLib.Apis.Context.Context
Reicht.GameLib.Apis.PlayerData = Reicht.GameLib.Require(Reicht.GameLib.Find("UI._global.PlayerData"))
Reicht.GameLib.Apis.Backpack = Reicht.GameLib.Require(Reicht.GameLib.Find("UI.Backpack.Model.BackpackModel"))
Reicht.GameLib.Apis.Carry = Reicht.GameLib.Require(Reicht.GameLib.Find("Battle.Game.Helper.RoomHelper.FoodSellCarryState"))
Reicht.GameLib.Apis.WuKong = Reicht.GameLib.Require(Reicht.GameLib.Find("WuKong"))
Reicht.GameLib.Apis.Compost = Reicht.GameLib.Require(Reicht.GameLib.Find("UI.Compost.Model.CompostModel"))
Reicht.GameLib.Apis.Activity = Reicht.GameLib.Require(Reicht.GameLib.Find("UI.ActivityEvent.Model.State"))
Reicht.GameLib.Apis.Online = Reicht.GameLib.Require(Reicht.GameLib.Find("UI.OnlineReward.Model.OnlineState"))
Reicht.GameLib.Apis.SevenDay = Reicht.GameLib.Require(Reicht.GameLib.Find("UI.7DAY.Model.SevenDayState"))

function Reicht.Data.Snapshot()
    local playerData = Reicht.GameLib.Apis.PlayerData
    return {
        Gold = playerData and tonumber(playerData.Gold) or 0,
        Food = playerData and tonumber(playerData.Food) or 0,
        PoolLevel = playerData and tonumber(playerData.PoolLevel) or 1,
        RollCount = playerData and tonumber(playerData.RollCount) or 0,
    }
end

function Reicht.Colony.Room()
    local ctx = Reicht.GameLib.Apis.Context
    return ctx and Reicht.GameLib.Call(ctx.Helper.RoomHelper.GetLocalClientRoomObject)
end

function Reicht.Util.Command(action, params, resultEvent)
    return Reicht.Util.Action(action, function()
        local previous = State.Replies[resultEvent]
        Reicht.Util.FireEcs(action, params)
        local reply = Reicht.Util.Await(function()
            local current = State.Replies[resultEvent]
            return current ~= previous and current
        end)
        if not reply then
            Reicht.Util.PushStatus(action, action .. ": no reply")
            return false, "No server reply"
        end
        local payload = reply.Payload
        local success = type(payload) == "table" and payload.Success == true
        local reason = type(payload) == "table" and (payload.Reason or (type(payload.Result) == "table" and payload.Result.Reason))
        if success then
            Reicht.Util.PushStatus(action, nil)
        else
            Reicht.Util.PushStatus(action, action .. ": " .. tostring(reason or "Rejected"))
        end
        return success, payload
    end)
end

do
    Reicht.Data.Attributes = {}
    Reicht.Data.AttributeNames = {}
    Reicht.Data.AttributeMap = {}
    Reicht.Data.PoolLevels = {}
    Reicht.Data.PoolMaxLevel = 0
    Reicht.Data.OnlineAwardCount = 0
    Reicht.Data.GearShopRequestEvent = "GearShopRequest"
    Reicht.Data.GearShopResultEvent = "GearShopResult"
    Reicht.Data.GearShopSnapshotEvent = "GearShopSnapshot"

    local gen = ReplicatedStorage:FindFirstChild("_genConfigs")

    local attrMod = gen and gen:FindFirstChild("battle_tbattribute")
    if attrMod then
        local rawAttrs = Reicht.GameLib.Require(attrMod)
        if type(rawAttrs) == "table" then
            local friendlyNames = {
                ["巢穴层数"] = "Nest Layers",
                ["单抽数量"] = "Roll Amount",
                ["蚂蚁攻击力"] = "Ant Attack Power",
                ["蚁后等级"] = "Ant Queen Level",
                ["蚂蚁移速"] = "Ant Move Speed",
                ["幸运值"] = "Lucky Value",
            }
            for key, attrDef in pairs(rawAttrs) do
                if type(attrDef) == "table" and attrDef.AttributeName then
                    local attrKey = attrDef.AttributeName
                    local friendly = friendlyNames[attrKey] or tostring(attrKey)
                    local maxLvl = type(attrDef.Info) == "table" and #attrDef.Info or 1
                    table.insert(Reicht.Data.Attributes, {
                        Key = attrKey,
                        Name = friendly,
                        MaxLevel = maxLvl,
                    })
                    table.insert(Reicht.Data.AttributeNames, friendly)
                    Reicht.Data.AttributeMap[friendly] = attrKey
                end
            end
        end
    end
    local poolUpgradeMod = gen and gen:FindFirstChild("battle_tbpoollevelupgrade")
    if poolUpgradeMod then
        local rawLevels = Reicht.GameLib.Require(poolUpgradeMod)
        if type(rawLevels) == "table" then
            local maxLvl = 1
            for _, v in pairs(rawLevels) do
                if type(v) == "table" and v.Level then
                    maxLvl = math.max(maxLvl, v.Level)
                end
            end
            Reicht.Data.PoolMaxLevel = maxLvl
            Reicht.Data.PoolLevels = rawLevels
        end
    end

    local awardMod = gen and gen:FindFirstChild("battle_tbonlineaward")
    if awardMod then
        local rawAwards = Reicht.GameLib.Require(awardMod)
        if type(rawAwards) == "table" then
            local count = 0
            for _ in pairs(rawAwards) do
                count = count + 1
            end
            Reicht.Data.OnlineAwardCount = count
        end
    end

    local gearShopCfg = ReplicatedStorage:FindFirstChild("Configs") and ReplicatedStorage.Configs:FindFirstChild("GearShopConfig")
    if gearShopCfg then
        local rawCfg = Reicht.GameLib.Require(gearShopCfg)
        if type(rawCfg) == "table" then
            Reicht.Data.GearShopRequestEvent = rawCfg.RequestEvent or "GearShopRequest"
            Reicht.Data.GearShopResultEvent = rawCfg.ResultEvent or "GearShopResult"
            Reicht.Data.GearShopSnapshotEvent = rawCfg.SnapshotEvent or "GearShopSnapshot"
        end
    end
end


do
    Reicht.Data.ClaimRarities = {}
    local ctx = Reicht.GameLib.Apis.Context
    local seen = {}
    for _, entry in pairs(ctx and ctx.Config.UnitConfig or {}) do
        if type(entry) == "table" and type(entry.Rarity) == "string" and not seen[entry.Rarity] then
            seen[entry.Rarity] = true
            Reicht.Data.ClaimRarities[#Reicht.Data.ClaimRarities + 1] = entry.Rarity
        end
    end
    table.sort(Reicht.Data.ClaimRarities)
end

do
    local activity = Reicht.GameLib.Apis.Activity
    Reicht.Data.ActivityLabels, Reicht.Data.ActivityIds = {}, {}
    Reicht.Data.ActivityImages, Reicht.Data.ActivityColors, Reicht.Data.ActivitySprites = {}, {}, {}
    local spriteGroups = {}
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local sprites = assets and assets:FindFirstChild("sprites")
    if activity and sprites then
        for _, module in ipairs(sprites:GetChildren()) do
            if module:IsA("ModuleScript") then
                for group, entries in pairs(Reicht.GameLib.Require(module) or {}) do
                    if type(entries) == "table" then
                        spriteGroups[group] = spriteGroups[group] or {}
                        for name, sprite in pairs(entries) do spriteGroups[group][name] = sprite end
                    end
                end
            end
        end
    end
    if activity then
        Reicht.GameLib.Call(activity.Init, activity)
        for _, entry in ipairs(Reicht.GameLib.Call(activity.GetShopCatalog, activity)) do
            local label = tostring(entry.DisplayName) .. " (" .. tostring(entry.Price) .. ")"
            Reicht.Data.ActivityLabels[#Reicht.Data.ActivityLabels + 1] = label
            Reicht.Data.ActivityIds[label] = entry.ProductId
            local sprite = spriteGroups[entry.IconSpriteGroup] and spriteGroups[entry.IconSpriteGroup][entry.IconSpriteId]
            if type(sprite) == "table" and type(sprite.Image) == "string" then
                Reicht.Data.ActivityImages[label] = sprite.Image
                Reicht.Data.ActivitySprites[label] = sprite
            end
            local ui = assets and assets:FindFirstChild("UI")
            local gradient = ui and ui:FindFirstChild(tostring(entry.Rarity) .. "Gradient")
            if gradient and gradient:IsA("UIGradient") then Reicht.Data.ActivityColors[label] = gradient.Color.Keypoints[1].Value end
        end
    end
end

---@param char Model
function Reicht.Player.Bind(char)
    if State.CharacterConn then State.CharacterConn:Disconnect() end
    State.Character = char
    State.CharacterParts = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then State.CharacterParts[part] = true end
    end
    State.CharacterConn = Reicht:Connect(char.DescendantAdded, function(part)
        if part:IsA("BasePart") then State.CharacterParts[part] = true end
    end)
    State.Humanoid = char:WaitForChild("Humanoid", Config.LoadTimeout)
    State.Root = char:WaitForChild("HumanoidRootPart", Config.LoadTimeout)
    State.SpeedApplied, State.FlyApplied = false, false
    if State.Character ~= char then return end
    table.clear(State.Collision)
    if State.Humanoid then
        State.WalkSpeed = State.Humanoid.WalkSpeed
        State.PlatformStand = State.Humanoid.PlatformStand
        if State.Opt.SpeedOn then Reicht.Movement.ApplySpeed() end
        if State.Opt.FlyOn then Reicht.Movement.ApplyFly() end
    end
end

Reicht:Connect(LocalPlayer.CharacterAdded, function(char)
    Reicht.Util.Child(function() Reicht.Player.Bind(char) end)
end)
if LocalPlayer.Character then Reicht.Player.Bind(LocalPlayer.Character) end

---@param action string
---@param params table?
function Reicht.Util.FireEcs(action, params)
    if not State.Alive or not Reicht.Util.Current() or not EventRE or not EventRE.Parent then return false end
    local payload = table.clone(params or {})
    payload.UserId = payload.UserId or LocalPlayer.UserId
    EventRE:FireServer("ECS_COMMAND", action, payload)
    return true
end

---@return number
function Reicht.Colony.GetRoomIndex()
    return LocalPlayer:GetAttribute("RoomIndex") or 1
end

function Reicht.Colony.RollAnt()
    local ctx = Reicht.GameLib.Apis.Context
    if not ctx then return false end
    local interval = Reicht.GameLib.Call(ctx.Helper.PlayerDataHelper.GetPlayerRollInterval, ctx, LocalPlayer.UserId)
    local now = os.clock()
    if now < (State.NextRoll or 0) then return false end
    if next(State.PendingRolls) and (State.Opt.AutoClaimRolled or State.Opt.Kaitun) then
        Reicht.Colony.ClaimPending()
    end
    if Reicht.Colony.ClaimsInFlight() then return false end
    State.NextRoll = now + math.max(tonumber(interval) or 3, Config.RollSlack) + Config.RollSlack
    return Reicht.Util.FireEcs("RollAnt", { Source = "RollModel" })
end

function Reicht.Colony.ClaimsInFlight()
    for claimId, started in pairs(State.InFlight) do
        if os.clock() - started > Config.ReplyTimeout then State.InFlight[claimId] = nil end
    end
    return next(State.InFlight) ~= nil
end

function Reicht.Colony.ClaimRolled(claimId)
    if not claimId or Reicht.Colony.ClaimsInFlight() then return false end
    local spending = State.Actions.Spend
    if spending and coroutine.status(spending) ~= "dead" then return false end
    local offer = State.PendingRolls[claimId]
    if not offer then return false end
    if next(State.Opt.ClaimRarities) and not State.Opt.ClaimRarities[offer.Rarity] then return false end
    local gold = Reicht.Data.Snapshot().Gold
    local cost = tonumber(offer.Cost)
    if not cost or cost ~= cost or cost < 0 or cost == math.huge then return false end
    if offer.Currency and offer.Currency ~= "金币" then return false end
    if cost > math.max(0, gold - State.Opt.KeepGold) then return false end
    State.InFlight[claimId] = os.clock()
    return Reicht.Util.FireEcs("ClaimRolledAnt", { ClaimId = claimId })
end

function Reicht.Colony.ClaimPending()
    if Reicht.Colony.ClaimsInFlight() or not next(State.PendingRolls) then return end
    local offers = {}
    for claimId, offer in pairs(State.PendingRolls) do
        local backpack = Reicht.GameLib.Apis.Backpack
        local entry = backpack and Reicht.GameLib.Call(backpack.BuildEntry, backpack, {
            Ecs = { Context = Reicht.GameLib.Apis.Context },
        }, "Backpack", offer.V, 1, 0)
        offers[#offers + 1] = { Id = claimId, Offer = offer, Attack = entry and entry.Attack or 0 }
    end
    table.sort(offers, function(a, b)
        if a.Attack ~= b.Attack then return a.Attack > b.Attack end
        return (a.Offer.Cost or 0) < (b.Offer.Cost or 0)
    end)
    for _, entry in ipairs(offers) do
        if Reicht.Colony.ClaimRolled(entry.Id) then break end
    end
end

function Reicht.Colony.QueueClaims()
    if not State.Alive or not (State.Opt.AutoClaimRolled or State.Opt.Kaitun) then return end
    local queued = State.ClaimThread
    if queued and coroutine.status(queued) ~= "dead" then return end
    State.ClaimThread = Reicht.Util.Child(function()
        if not State.Alive or not Reicht.Util.Current() then return end
        if State.Opt.AutoClaimRolled or State.Opt.Kaitun then
            Reicht.Util.Try(Reicht.Colony.ClaimPending)
        end
    end)
end

function Reicht.Colony.EquipBest()
    return Reicht.Util.Action("EquipBest", function()
        local backpack = Reicht.GameLib.Apis.Backpack
        if not backpack then return false end
        return Reicht.GameLib.Call(backpack.EquipBest, backpack)
    end)
end

function Reicht.Colony.PlaceAnts()
    return Reicht.Colony.EquipBest()
end

function Reicht.Colony.CompostState()
    local model = Reicht.GameLib.Apis.Compost
    if not model then return nil end
    return Reicht.GameLib.Call(model.GetState, model, {
        PlayerData = Reicht.GameLib.Apis.PlayerData,
        Ecs = { Context = Reicht.GameLib.Apis.Context },
    })
end

function Reicht.Colony.CompostPull()
    local info = Reicht.Colony.CompostState()
    if not info or not info.CanPull then return false end
    return Reicht.Util.Action("Compost", function()
        return Reicht.Util.Command("CompostPullLever", {}, "CompostMachineResult")
    end)
end

function Reicht.Colony.CompostUpgrade()
    local info = Reicht.Colony.CompostState()
    if not info or not info.CanUpgrade or info.UpgradePrice > Reicht.Data.Snapshot().Gold - State.Opt.KeepGold then return false end
    return Reicht.Util.Action("Compost", function()
        return Reicht.Util.Command("CompostUpgrade", {}, "CompostMachineResult")
    end)
end

function Reicht.Farm.SellFood()
    return Reicht.Util.Action("Sell", function()
        local carry = Reicht.GameLib.Apis.Carry
        if not carry or (tonumber(carry.GetSnapshot().FoodAmount) or 0) <= 0 then return false end
        if State.Opt.SellMinPrice > 0 and (State.FoodPrice <= 0 or State.FoodPrice < State.Opt.SellMinPrice) then return false end
        local amount = carry.GetSnapshot().FoodAmount
        return Reicht.Util.Command("SellPlayerFood", { FoodAmount = amount, Source = "PlayerFoodPrompt" }, "SellResuit")
    end)
end

function Reicht.Farm.CollectFood()
    local carry = Reicht.GameLib.Apis.Carry
    local food = Reicht.Data.Snapshot().Food
    if not carry or food <= (tonumber(carry.GetSnapshot().FoodAmount) or 0) then return false end
    local room = Reicht.Colony.Room()
    if not room then return false end
    return Reicht.GameLib.Call(carry.SetSnapshot, {
        Source = "PlayerFoodPrompt", FoodAmount = food, RoomIndex = room.RoomIndex,
    })
end

function Reicht.Farm.RequestPrice()
    return Reicht.Util.FireEcs("RequestSellFoodPrice", { Source = "SellShopModel" })
end

function Reicht.Progression.PoolCost()
    local current = Reicht.Data.Snapshot().PoolLevel
    local info = Reicht.Data.PoolLevels[current] or Reicht.Data.PoolLevels[tostring(current)]
    if not info or not info.NextLevel then return nil end
    return tonumber(info.CostFood or info.Cost or info.FoodCost)
end

function Reicht.Progression.UpgradePool()
    if Reicht.Colony.ClaimsInFlight() then return false end
    local cost = Reicht.Progression.PoolCost()
    if not cost or cost > Reicht.Data.Snapshot().Gold - State.Opt.KeepGold then return false end
    return Reicht.Util.Action("Spend", function()
        return Reicht.Util.Command("PoolLevelUpgrade", {}, "PoolLevelUpgradeResult")
    end)
end

function Reicht.Progression.AttributeInfo(attrName)
    local ctx = Reicht.GameLib.Apis.Context
    if not ctx then return nil end
    local key = Reicht.Data.AttributeMap[attrName] or attrName
    return Reicht.GameLib.Call(ctx.Helper.PlayerDataHelper.GetPlayerUpgradeAttributeInfo, ctx, LocalPlayer.UserId, key)
end

function Reicht.Progression.UpgradeAttribute(attrName)
    if Reicht.Colony.ClaimsInFlight() then return false end
    return Reicht.Util.Action("Spend", function()
        local info = Reicht.Progression.AttributeInfo(attrName)
        if not info or info.IsMax or info.Price > Reicht.Data.Snapshot().Gold - State.Opt.KeepGold then return false end
        return Reicht.Util.Command("UpgradePlayerAttribute", { AttributeName = info.AttributeName }, "UpgradePlayerAttributeResult")
    end)
end

function Reicht.Progression.UpgradeAll()
    local best, score
    for _, attr in ipairs(Reicht.Data.Attributes) do
        local info = Reicht.Progression.AttributeInfo(attr.Key)
        if info and not info.IsMax and info.Price <= Reicht.Data.Snapshot().Gold - State.Opt.KeepGold then
            local gain = math.max(0, (tonumber(info.NextValue) or 0) - (tonumber(info.Value) or 0))
            local value = gain / math.max(1, math.abs(tonumber(info.Value) or 0)) / math.max(1, info.Price)
            if not score or value > score then best, score = attr.Key, value end
        end
    end
    if best then return Reicht.Progression.UpgradeAttribute(best) end
    return false
end

function Reicht.Rewards.ClaimOnline()
    return Reicht.Util.Action("Online", function()
        local model = Reicht.GameLib.Apis.Online
        if not model then return false end
        local index = Reicht.GameLib.Call(model.GetFirstClaimableRewardIndex, model)
        if not index then return false end
        local before = LocalPlayer:GetAttribute("onlineaward")
        Reicht.GameLib.Call(model.GetReward, model, index)
        return Reicht.Util.Await(function() return LocalPlayer:GetAttribute("onlineaward") ~= before end)
    end)
end

function Reicht.Shop.PurchaseActivity(id)
    return Reicht.Util.Action("Activity", function()
        local model = Reicht.GameLib.Apis.Activity
        if not model then return false end
        Reicht.GameLib.Call(model.Init, model)
        local selected = id or State.Opt.ActivityItem
        if not selected then return false end
        local entry = Reicht.GameLib.Call(model.GetShopEntry, model, selected)
        if not entry or entry.Price > (tonumber(model.WishCurrencyBalance) or 0) then return false end
        local previous = State.Replies.ActivityShopResult
        local sent = Reicht.GameLib.Call(model.PurchaseShopItem, model, entry.ProductId)
        if not sent then return false end
        local reply = Reicht.Util.Await(function()
            local current = State.Replies.ActivityShopResult
            return current ~= previous and current
        end)
        return reply and reply.Payload.Success == true or false
    end)
end

function Reicht.Shop.RefreshGearSnapshot()
    EventRE:FireServer(Reicht.Data.GearShopRequestEvent, { Action = "Snapshot" })
end

function Reicht.Boss.LootCoins()
    local count = 0
    for prompt in pairs(State.CoinPrompts or {}) do
        if not prompt.Parent then
            State.CoinPrompts[prompt] = nil
        elseif Library and Library.Compat and Library.Compat.Has("Prompt") then
            pcall(fireproximityprompt, prompt, 0)
            count += 1
        end
    end
    return count
end

---@param codeStr string
---@return boolean, string
function Reicht.Rewards.RedeemCode(codeStr)
    local clean = string.lower(codeStr):gsub("^%s*(.-)%s*$", "%1")
    if clean == "" or State.SeenCodes[clean] then return false, "Already attempted" end
    local module = Reicht.GameLib.Find("Packages.CodeService")
    local remote = module and module:FindFirstChild("RemoteFunction")
    if not remote then return false, "Code service unavailable" end
    local ok, success, message = Reicht.Util.Bounded(function()
        return remote:InvokeServer("Redeem", clean)
    end, Config.RemoteTimeout)
    if not ok then return false, tostring(success) end
    if message == nil and type(success) == "string" then message, success = success, false end
    message = tostring(message or (success == true and "Redeemed" or "Rejected"))
    local retry = message:lower():match("try again in (%d+)")
    if not retry then State.SeenCodes[clean] = true end
    State.CodeResults[clean] = { Success = success == true, Message = message }
    return success == true, message, tonumber(retry)
end

function Reicht.Rewards.RedeemAll()
    if State.Redeeming then return false end
    State.Redeeming = true
    State.CodeThread = Reicht.Util.Child(function()
        for _, code in ipairs(Config.Codes) do
            if not State.Alive or not Reicht.Util.Current() then break end
            local ok, message, retry = Reicht.Rewards.RedeemCode(code)
            if retry then
                task.wait(retry + 0.2)
                if State.Alive and Reicht.Util.Current() then ok, message = Reicht.Rewards.RedeemCode(code) end
            end
            Reicht.Util.PushStatus("Codes", code .. ": " .. tostring(message))
            if ok then State.Metrics.Codes = (State.Metrics.Codes or 0) + 1 end
            task.wait(Config.CodeGap)
        end
        State.Redeeming = false
    end)
    return true
end

function Reicht.Movement.ApplySpeed()
    local hum = Reicht.Util.GetHum()
    if hum then
        if State.Opt.SpeedOn then
            if not State.SpeedApplied then State.WalkSpeed = hum.WalkSpeed end
            hum.WalkSpeed = State.Opt.WalkSpeed
        elseif State.SpeedApplied then
            hum.WalkSpeed = State.WalkSpeed
        end
        State.SpeedApplied = State.Opt.SpeedOn
    end
end

local flyBodyVel, flyBodyGyro

function Reicht.Movement.ApplyFly()
    local hrp = Reicht.Util.GetHRP()
    local hum = Reicht.Util.GetHum()
    if not hrp or not hum then return end

    if State.Opt.FlyOn then
        if not flyBodyVel or flyBodyVel.Parent ~= hrp then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Velocity = Vector3.zero
            flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or flyBodyGyro.Parent ~= hrp then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.CFrame = hrp.CFrame
            flyBodyGyro.Parent = hrp
        end
        if not State.FlyApplied then State.PlatformStand = hum.PlatformStand end
        State.FlyApplied = true
        hum.PlatformStand = true
    else
        if flyBodyVel then
            flyBodyVel:Destroy()
            flyBodyVel = nil
        end
        if flyBodyGyro then
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end
        if State.FlyApplied then hum.PlatformStand = State.PlatformStand == true end
        State.FlyApplied = false
    end
end

Reicht:Connect(RunService.RenderStepped, function()
    if not State.Alive then return end
    if State.Opt.FlyOn and flyBodyVel and flyBodyGyro then
        local hrp = Reicht.Util.GetHRP()
        local cam = workspace.CurrentCamera
        if hrp and cam then
            local hum = Reicht.Util.GetHum()
            local move = Reicht.Platform.Touch and hum and hum.MoveDirection or Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end

            flyBodyVel.Velocity = move.Magnitude > 0 and (move.Unit * State.Opt.FlySpeed) or Vector3.zero
            flyBodyGyro.CFrame = cam.CFrame
        end
    end
end)

Reicht:Connect(RunService.Stepped, function()
    if not State.Alive then return end
    if State.Opt.NoclipOn then
        local char = Reicht.Util.GetChar()
        if char then
            for part in pairs(State.CharacterParts or {}) do
                if part.Parent and part.CanCollide then
                    if State.Collision[part] == nil then State.Collision[part] = part.CanCollide end
                    part.CanCollide = false
                end
            end
        end
    end
end)

Reicht:Connect(UserInputService.JumpRequest, function()
    if State.Opt.InfJump then
        local hum = Reicht.Util.GetHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd
local originalShadows = Lighting.GlobalShadows

function Reicht.Movement.ApplyFullbright()
    if State.Opt.Fullbright then
        if not State.LightApplied then
            originalBrightness, originalClockTime = Lighting.Brightness, Lighting.ClockTime
            originalFogEnd, originalShadows = Lighting.FogEnd, Lighting.GlobalShadows
        end
        State.LightApplied = true
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    elseif State.LightApplied then
        State.LightApplied = false
        Lighting.Brightness = originalBrightness
        Lighting.ClockTime = originalClockTime
        Lighting.GlobalShadows = originalShadows
        Lighting.FogEnd = originalFogEnd
    end
end

State.CoinPrompts = {}
function Reicht.Boss.TrackPrompt(instance)
    if instance:IsA("ProximityPrompt") and instance.Name:lower():find("coin") then
        State.CoinPrompts[instance] = true
    end
end
for _, prompt in ipairs(workspace:QueryDescendants("ProximityPrompt")) do Reicht.Boss.TrackPrompt(prompt) end
Reicht:Connect(workspace.DescendantAdded, Reicht.Boss.TrackPrompt)
Reicht:Connect(workspace.DescendantRemoving, function(instance) State.CoinPrompts[instance] = nil end)
Reicht:Connect(LocalPlayer.Idled, function()
    if not State.Alive or not State.Opt.AntiAfk then return end
    local virtualUser = game:GetService("VirtualUser")
    local ok, err = pcall(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.zero)
    end)
    if not ok then Reicht.Util.WarnJob("AntiAfk", err) end
end)

function Reicht.Teleport.Refresh()
    local points = {}
    local room = Reicht.Colony.Room()
    if room and room.BaseGround then points["My Nest"] = room.BaseGround end
    for _, object in ipairs(workspace:GetChildren()) do
        if object.Name == "GearShop" or object.Name == "PetShop" or object.Name == "StrawberryKingPart" then
            points[object.Name] = object
        end
    end
    local entrances = workspace:FindFirstChild("DungeonEntrances")
    if entrances then
        for _, entry in ipairs(entrances:GetChildren()) do
            local target = entry:IsA("BasePart") and entry or entry:FindFirstChildWhichIsA("BasePart", true)
            if target then points["Dungeon " .. entry.Name] = target end
        end
    end
    State.TravelPoints = points
    local names = {}
    for name in pairs(points) do names[#names + 1] = name end
    table.sort(names)
    return names
end

function Reicht.Teleport.Travel(name)
    return Reicht.Util.Action("Travel", function()
        local hrp = Reicht.Util.GetHRP()
        local target = State.TravelPoints and State.TravelPoints[name]
        if not hrp or not target or not target.Parent then return false end
        local pos = target:GetPivot().Position
        if workspace.StreamingEnabled then
            Reicht.Util.Bounded(function() LocalPlayer:RequestStreamAroundAsync(pos) end, Config.RequireTimeout)
        end
        if not State.Alive or hrp ~= Reicht.Util.GetHRP() then return false end
        State.ReturnCFrame = hrp.CFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        return true
    end)
end

function Reicht.Teleport.Return()
    local hrp = Reicht.Util.GetHRP()
    if not hrp or not State.ReturnCFrame then return false end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = State.ReturnCFrame
    State.ReturnCFrame = nil
    return true
end

function Reicht.Esp.CreateHighlight(inst, color, fill)
    local highlight = Instance.new("Highlight")
    highlight.Name = "MarioEsp"
    highlight.Adornee = inst
    highlight.OutlineColor = color
    highlight.FillColor = fill
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = inst
    return highlight
end

function Reicht.Esp.Clear()
    for target, highlight in pairs(State.EspObjects or {}) do
        highlight:Destroy()
        State.EspObjects[target] = nil
    end
end

function Reicht.Esp.Update()
    local wanted = {}
    State.EspObjects = State.EspObjects or {}
    local myHrp = Reicht.Util.GetHRP()
    local myPos = myHrp and myHrp.Position or Vector3.zero

    if State.Opt.EspBoss then
        local boss = workspace:FindFirstChild("StrawberryKing") or workspace:FindFirstChild("StrawberryKingPart")
        if boss then
            wanted[boss] = Color3.fromRGB(255, 60, 60)
        end
    end

    if State.Opt.EspDungeon then
        local entrances = workspace:FindFirstChild("DungeonEntrances")
        if entrances then
            for _, ent in ipairs(entrances:GetChildren()) do
                wanted[ent] = Color3.fromRGB(80, 200, 255)
            end
        end
    end

    if State.Opt.EspPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local pHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if pHrp and (pHrp.Position - myPos).Magnitude <= State.Opt.EspDist then
                    wanted[plr.Character] = Color3.fromRGB(100, 255, 100)
                end
            end
        end
    end
    for target, highlight in pairs(State.EspObjects) do
        if not target.Parent or not wanted[target] then
            highlight:Destroy()
            State.EspObjects[target] = nil
        end
    end
    for target, color in pairs(wanted) do
        if not State.EspObjects[target] then
            State.EspObjects[target] = Reicht.Esp.CreateHighlight(target, color, color)
        end
    end
end

function Reicht.Collect.ClaimDailyEvents()
    local model = Reicht.GameLib.Apis.SevenDay
    if not model or not Reicht.GameLib.Call(model.IsAward, model) then return false end
    return Reicht.GameLib.Call(model.GetReward, model) == true
end

function Reicht.Collect.ClaimAllOnlineAwards()
    local claimed = 0
    for _ = 1, Reicht.Data.OnlineAwardCount do
        if not State.Alive or not Reicht.Rewards.ClaimOnline() then break end
        claimed += 1
    end
    return claimed
end

function Reicht.Collect.ClaimAllAntRewards()
    local room = Reicht.Colony.Room()
    if not room then return false end
    local indices = {}
    for slot, ant in pairs(room.AntObjects or {}) do
        if ant.HasCarriedRewards and Reicht.GameLib.Call(ant.HasCarriedRewards, ant) then
            indices[#indices + 1] = slot
        end
    end
    if #indices == 0 then return false end
    return Reicht.Util.FireEcs("ClaimAntReward", { AntIndices = indices })
end

function Reicht.Collect.ClaimAllWorkerFood()
    local room = Reicht.Colony.Room()
    if not room then return false end
    local claims = {}
    for slot, ant in pairs(room.AntObjects or {}) do
        local amount = ant.info and tonumber(ant.info.Food) or 0
        if amount > 0 then claims[#claims + 1] = { SlotIndex = slot, Amount = math.floor(amount) } end
    end
    if #claims == 0 then return false end
    return Reicht.Util.FireEcs("ClaimWorkerAntFood", { SubmissionId = HttpService:GenerateGUID(false), Claims = claims })
end

function Reicht.Collect.UpgradeAllEquippedAnts()
    local room = Reicht.Colony.Room()
    if not room then return 0 end
    local count = 0
    for slot in pairs(room.AntObjects or {}) do
        if not State.Alive then break end
        Reicht.Util.FireEcs("UpgradeEquippedAnt", { AntIndex = slot })
        count += 1
    end
    return count
end

function Reicht.Economy.Step()
    if State.Actions.Economy then return false end
    local auto = State.Opt.Kaitun
    return Reicht.Util.Action("Economy", function()
        Reicht.Collect.ClaimAllWorkerFood()
        Reicht.Farm.CollectFood()
        if not State.Alive then return false end
        Reicht.Farm.SellFood()
        if not State.Alive then return false end
        local poolCost = Reicht.Progression.PoolCost()
        local balance = Reicht.Data.Snapshot().Gold - State.Opt.KeepGold
        if auto and not State.Opt.Kaitun then return false end
        if State.Opt.UpgradePriority == "Stats first" and Reicht.Progression.UpgradeAll() then
            Reicht.Util.PushStatus("Progression", "Upgraded an affordable stat")
        elseif poolCost and balance >= poolCost then
            Reicht.Progression.UpgradePool()
        elseif State.Opt.UpgradeAllAttr then
            Reicht.Progression.UpgradeAll()
        else
            Reicht.Progression.UpgradeAttribute(State.Opt.AttrTarget)
        end
        if not State.Alive or (auto and not State.Opt.Kaitun) then return false end
        Reicht.Colony.ClaimPending()
        Reicht.Colony.RollAnt()
        Reicht.Colony.EquipBest()
        Reicht.Rewards.ClaimOnline()
        return true
    end)
end

Reicht:Connect(EventRE.OnClientEvent, function(event, data)
    if not State.Alive then return end
    State.Replies[event] = { At = os.clock(), Payload = data }
    if event == "RollAntResult" and type(data) == "table" and type(data.Results) == "table" then
        State.PendingRolls = {}
        State.Metrics.Rolls += 1
        for _, offer in ipairs(data.Results or {}) do
            if type(offer) == "table" and type(offer.ClaimId) == "string" then State.PendingRolls[offer.ClaimId] = offer end
        end
        Reicht.Colony.QueueClaims()
    elseif event == "ClaimRolledAntResult" and type(data) == "table" and type(data.ClaimId) == "string" then
        local requested = State.InFlight[data.ClaimId] ~= nil
        State.InFlight[data.ClaimId] = nil
        if data.Success then
            State.PendingRolls[data.ClaimId] = nil
            if requested then State.Metrics.Claims += 1 end
            Reicht.Colony.QueueClaims()
        elseif data.Reason == "Expired" or data.Reason == "Replaced" then
            State.PendingRolls[data.ClaimId] = nil
        elseif requested then
            State.InFlight[data.ClaimId] = os.clock()
        end
    elseif event == "SellResuit" and type(data) == "table" and data.Success then
        State.Metrics.Sales += 1
        State.Metrics.Gold += type(data.Result) == "table" and tonumber(data.Result.GoldAmount) or 0
    elseif event == "SellFoodPriceUpdate" and type(data) == "table" then
        if data.GoldPerFood then
            State.FoodPrice = data.GoldPerFood
            State.PriceTime = os.clock()
        end
    elseif event == "StrawberryKingState" and type(data) == "table" then
        State.BossActive = data.Active == true
    end
end)

local jobs = {
    { name = "AutoWorkerFood", interval = 0.5, last = 0, run = Reicht.Collect.ClaimAllWorkerFood },
    { name = "AutoAntRewards", interval = 1, last = 0, run = Reicht.Collect.ClaimAllAntRewards },
    {
        name = "Kaitun",
        interval = 1.0,
        last = 0,
        run = function()
            if not State.Opt.Kaitun then return end
            Reicht.Economy.Step()
        end,
    },
    {
        name = "AutoSell",
        interval = 1.5,
        last = 0,
        run = function()
            if State.Opt.AutoSell and not State.Opt.Kaitun then
                Reicht.Farm.SellFood()
            end
        end,
    },
    {
        name = "AutoCollectFood",
        interval = 2.0,
        last = 0,
        run = function()
            if State.Opt.AutoCollectFood and not State.Opt.Kaitun then
                Reicht.Farm.CollectFood()
            end
        end,
    },
    {
        name = "AutoPool",
        interval = 4.0,
        last = 0,
        run = function()
            if State.Opt.AutoPool and not State.Opt.Kaitun then
                for _ = 1, State.Opt.PoolBurst do
                    if not State.Opt.AutoPool or not State.Alive then break end
                    if not Reicht.Progression.UpgradePool() then break end
                end
            end
        end,
    },
    {
        name = "AutoAttr",
        interval = 2.0,
        last = 0,
        run = function()
            if State.Opt.AutoAttr and not State.Opt.Kaitun then
                if State.Opt.UpgradeAllAttr then
                    Reicht.Progression.UpgradeAll()
                else
                    Reicht.Progression.UpgradeAttribute(State.Opt.AttrTarget)
                end
            end
        end,
    },
    {
        name = "AutoRoll",
        interval = 0.15,
        last = 0,
        run = function()
            if State.Opt.AutoRoll and not State.Opt.Kaitun then
                Reicht.Colony.RollAnt(nil)
            end
        end,
    },
    {
        name = "AutoEquipBest",
        interval = 5.0,
        last = 0,
        run = function()
            if State.Opt.AutoEquipBest and not State.Opt.Kaitun then
                Reicht.Colony.EquipBest()
            end
        end,
    },
    {
        name = "AutoPlaceAnts",
        interval = 8.0,
        last = 0,
        run = function()
            if State.Opt.AutoPlaceAnts and not State.Opt.Kaitun then
                Reicht.Colony.PlaceAnts()
            end
        end,
    },
    {
        name = "AutoCompost",
        interval = 5.0,
        last = 0,
        run = function()
            if State.Opt.AutoCompostPull then
                Reicht.Colony.CompostPull()
            end
            if State.Opt.AutoCompostUpgrade then
                Reicht.Colony.CompostUpgrade()
            end
        end,
    },
    {
        name = "AutoOnlineAward",
        interval = 30.0,
        last = 0,
        run = function()
            if State.Opt.AutoOnlineAward and not State.Opt.Kaitun then
                Reicht.Collect.ClaimAllOnlineAwards()
            end
        end,
    },
    {
        name = "AutoActivity",
        interval = 60.0,
        last = 0,
        run = function()
            if State.Opt.AutoActivity and not State.Opt.Kaitun then
                Reicht.Shop.PurchaseActivity(State.Opt.ActivityItem)
            end
        end,
    },
    {
        name = "AutoLootBossCoins",
        interval = 1.0,
        last = 0,
        run = function()
            if State.Opt.AutoLootBossCoins then
                Reicht.Boss.LootCoins()
            end
        end,
    },
    {
        name = "EspUpdate",
        interval = 2.0,
        last = 0,
        run = function()
            if State.Opt.EspBoss or State.Opt.EspDungeon or State.Opt.EspPlayers then
                Reicht.Esp.Update()
            end
        end,
    },
    {
        name = "PriceMonitor",
        interval = 10.0,
        last = 0,
        run = function()
            Reicht.Farm.RequestPrice()
        end,
    },
    {
        name = "ClaimPending", interval = 0.15, last = 0,
        run = Reicht.Colony.ClaimPending,
    },
}

local JobIndex = {}
for i, job in ipairs(jobs) do
    JobIndex[job.name] = job
end

function Reicht.Scheduler.Enabled(name)
    if name == "Kaitun" then return State.Opt.Kaitun end
    if name == "ClaimPending" then return State.Opt.AutoClaimRolled or State.Opt.Kaitun end
    if name == "AutoCompost" then return State.Opt.AutoCompostPull or State.Opt.AutoCompostUpgrade end
    if name == "EspUpdate" then return State.Opt.EspBoss or State.Opt.EspDungeon or State.Opt.EspPlayers end
    if name == "PriceMonitor" then return State.Opt.AutoSell or State.Opt.Kaitun end
    return State.Opt[name] == true
end

function Reicht.Scheduler.Boot()
    if State.SchedulerStarted then return end
    State.SchedulerStarted = true
    local acc = 0
    Reicht:Connect(RunService.Heartbeat, function(dt)
        if not State.Alive then return end
        acc += dt
        if acc < Config.TickDelay then return end
        acc = 0
        local now = os.clock()
        for _, job in ipairs(jobs) do
            if job.busy and now - job.started > Config.MaxJobTime then
                if job.thread then pcall(task.cancel, job.thread) end
                job.busy = false
                Reicht.Util.WarnJob(job.name, "deadline exceeded")
            end
            if Reicht.Scheduler.Enabled(job.name) and not job.busy and not State.Halted[job.name] and now - job.last >= job.interval then
                job.last, job.started, job.busy = now, now, true
                job.thread = Reicht.Util.Child(function()
                    local ok, err = pcall(job.run)
                    job.busy = false
                    if ok then
                        State.Failures[job.name] = 0
                    else
                        Reicht.Util.WarnJob(job.name, err)
                    end
                end)
            end
        end
    end)
end

function Reicht.Scheduler.Stop()
    State.StopGen += 1
    if State.ClaimThread and coroutine.status(State.ClaimThread) ~= "dead" then pcall(task.cancel, State.ClaimThread) end
    State.ClaimThread = nil
    if State.CodeThread and coroutine.status(State.CodeThread) ~= "dead" then pcall(task.cancel, State.CodeThread) end
    State.CodeThread, State.Redeeming = nil, false
    for key, value in pairs(State.Opt) do
        if type(value) == "boolean" then State.Opt[key] = false end
    end
    local current = coroutine.running()
    for _, job in ipairs(jobs) do
        if job.thread and job.thread ~= current and coroutine.status(job.thread) ~= "dead" then pcall(task.cancel, job.thread) end
        job.busy = false
    end
    Reicht.Movement.ApplySpeed()
    Reicht.Movement.ApplyFly()
    Reicht.Movement.ApplyFullbright()
    for part, collide in pairs(State.Collision) do
        if part.Parent then part.CanCollide = collide end
    end
    table.clear(State.Collision)
    Reicht.Esp.Clear()
    Reicht.Util.Later(function()
        for index, option in pairs(Library.Options) do
            if (type(State.Opt[index]) == "boolean" or index == "KaitunMaster") and option.Value == true then option:SetValue(false) end
        end
    end)
end

local function BuildInterface()
    Library = Reicht.Util.LoadLibrary()
    State.Library = Library
    if not Library then return end
    pcall(ReichtBanner.Step, "UI library")

    local T = function(en, th)
        return Library:T(en, th)
    end

    Library:OnUnload(Reicht.Unload)
    Library:CreateWindow({
        Title = "Reicht",
        SubTitle = "Build An Ant Empire by Reicht",
        MenuKey = Enum.KeyCode.LeftControl,
        ConfigFolder = Config.SaveFolder,
        Language = "Auto",
        Theme = "Overworld",
        OnUnlocked = function()
            local win = Library.Window
            win.Root:SetAttribute("MarioGameId", Config.GameId)
            win.Root:SetAttribute("MarioBuild", "2026-10-15.2")

            win:AddTabSection(T("Main", "หน้าหลัก"))
            local mainTab = win:AddTab(T("Main", "หน้าหลัก"), "home", T("Colony overview & Kaitun", "ภาพรวมอาณาจักรและไก่ตัน"))

            local statusGroup = mainTab:AddLeftGroupbox(T("Colony Status", "สถานะอาณาจักร"), "activity")
            local statusPara = statusGroup:AddLabel(T("Connecting to colony systems...", "กำลังเชื่อมต่อระบบ..."))

            local kaitunGroup = mainTab:AddLeftGroupbox(T("Kaitun Automation", "บอตไก่ตันอัตโนมัติ"), "bot", "OP")
            kaitunGroup:AddToggle("KaitunMaster", {
                Text = T("Autonomous Kaitun", "เปิดบอตไก่ตันครบวงจร"),
                Default = false,
                Description = T("Orchestrates food, summons, upgrades, and claims", "คุมการขายอาหาร สุ่มมด อัปเกรด และรับรางวัลอัตโนมัติ"),
                Callback = function(v) State.Opt.Kaitun = v end,
            })
            Reicht.Util.Button(kaitunGroup, {
                Text = T("Run Kaitun Cycle Now", "รันไก่ตัน 1 รอบทันที"),
                Func = function()
                    Reicht.Util.Child(Reicht.Economy.Step)
                end,
            })

            Reicht.Util.Button(kaitunGroup, { Text = T("Stop All", "หยุดทั้งหมด"), Func = Reicht.Scheduler.Stop })

            local discordGroup = mainTab:AddRightGroupbox("Discord", "link")
            discordGroup:AddLabel(Config.Discord)
            Reicht.Util.Button(discordGroup, {
                Text = T("Copy Discord Link", "คัดลอกลิงก์ Discord"),
                Func = function()
                    Reicht.Util.Clipboard(Config.Discord)
                    Reicht.Util.Later(function() Library:Notify("Reicht", "Discord link copied to clipboard", 5) end)
                end,
            })

            local updateGroup = mainTab:AddRightGroupbox(T("Update Log", "บันทึกอัปเดต"), "bell")
            for i = 1, math.min(2, #Config.UpdateLog) do
                updateGroup:AddParagraph({
                    Title = Config.UpdateLog[i][1],
                    Content = Config.UpdateLog[i][2],
                })
            end

            local actions = mainTab:AddRightGroupbox(T("Colony Actions", "จัดการรังมด"), "star")
            Reicht.Util.Button(actions, { Text = T("Claim Ready Rewards Now", "รับรางวัลที่พร้อมทันที"), Func = function()
                Reicht.Util.Child(function()
                    Reicht.Collect.ClaimDailyEvents()
                    Reicht.Collect.ClaimAllOnlineAwards()
                end)
            end })
            Reicht.Util.Button(actions, { Text = T("Collect Ant Food Now", "เก็บอาหารจากมดทันที"), Func = function()
                Reicht.Util.Child(Reicht.Collect.ClaimAllWorkerFood)
            end })
            actions:AddToggle("AutoAntRewards", {
                Text = T("Auto Collect Ant Rewards", "เก็บรางวัลจากมดอัตโนมัติ"), Default = false,
                Callback = function(value) State.Opt.AutoAntRewards = value end,
            })
            Reicht.Util.Button(actions, { Text = T("Collect Ant Rewards Now", "เก็บรางวัลจากมดทันที"), Func = function()
                Reicht.Util.Child(Reicht.Collect.ClaimAllAntRewards)
            end })
            kaitunGroup:AddDropdown("UpgradePriority", {
                Text = T("Upgrade Priority", "ลำดับการอัปเกรด"), Values = { "Pool first", "Stats first" }, Default = "Pool first",
                Callback = function(value) State.Opt.UpgradePriority = value end,
            })
            kaitunGroup:AddInput("KeepGold", {
                Text = T("Keep Cash", "เก็บเงินสำรอง"), Default = "1000", Numeric = true, Finished = true,
                Callback = function(value)
                    local amount = tonumber(value)
                    if amount and amount == amount and amount >= 0 and amount < math.huge then State.Opt.KeepGold = math.floor(amount) end
                end,
            })

            win:AddTabSection(T("Farming", "ฟาร์ม"))
            local farmTab = win:AddTab(T("Farm & Colony", "ฟาร์มและรังมด"), "leaf", T("Food production and ant recruitment", "การผลิตอาหารและการสุ่มมด"))

            local foodGroup = farmTab:AddLeftGroupbox(T("Food Economy", "เศรษฐกิจอาหาร"), "coins", "OP")
            foodGroup:AddToggle("AutoWorkerFood", {
                Text = T("Auto Collect Ant Food", "เก็บอาหารจากมดอัตโนมัติ"), Default = false,
                Callback = function(value) State.Opt.AutoWorkerFood = value end,
            })
            Reicht.Util.Button(foodGroup, { Text = T("Collect Ant Food Now", "เก็บอาหารจากมดทันที"),
                Func = Reicht.Collect.ClaimAllWorkerFood,
            })
            foodGroup:AddToggle("AutoSell", {
                Text = T("Auto Sell Food", "ขายอาหารอัตโนมัติ"),
                Default = false,
                Description = T("Exchanges carried food for gold automatically", "ขายอาหารที่ถือเป็นเงินอัตโนมัติ"),
                Callback = function(v) State.Opt.AutoSell = v end,
            })
            foodGroup:AddSlider("SellDelay", {
                Text = T("Sell Interval", "ระยะห่างการขาย"),
                Min = 0.5,
                Max = 10,
                Default = 1.5,
                Rounding = 1,
                Suffix = "s",
                Callback = function(v)
                    State.Opt.SellDelay = v
                    local sellJob = JobIndex["AutoSell"]
                    if sellJob then sellJob.interval = v end
                end,
            })
            foodGroup:AddSlider("SellMinPrice", {
                Text = T("Minimum Sell Price", "ราคาขายขั้นต่ำ"), Min = 0, Max = 2, Default = 0, Rounding = 2,
                Callback = function(value) State.Opt.SellMinPrice = value end,
            })
            Reicht.Util.Button(foodGroup, {
                Text = T("Sell Food Now", "ขายอาหารทันที"),
                Func = function()
                    Reicht.Farm.SellFood()

                end,
            })
            foodGroup:AddToggle("AutoCollectFood", {
                Text = T("Auto Collect Nest Food", "เก็บอาหารจากรังอัตโนมัติ"),
                Default = false,
                Description = T("Collects accumulated food from room storage", "เก็บอาหารสะสมจากจุดเก็บอาหารในห้อง"),
                Callback = function(v) State.Opt.AutoCollectFood = v end,
            })
            Reicht.Util.Button(foodGroup, {
                Text = T("Collect Nest Food Now", "เก็บอาหารทันที"),
                Func = function()
                    Reicht.Farm.CollectFood()

                end,
            })

            local compostGroup = farmTab:AddLeftGroupbox(T("Compost Machine", "เครื่องหมักปุ๋ย"), "recycle")
            compostGroup:AddToggle("AutoCompostPull", {
                Text = T("Auto Pull Compost Lever", "โยกคันโยกหมักปุ๋ยอัตโนมัติ"),
                Default = false,
                Description = T("Pulls compost lever to convert and claim rewards", "ดึงคันโยกเพื่อหมักปุ๋ยและรับเหรียญ"),
                Callback = function(v) State.Opt.AutoCompostPull = v end,
            })
            Reicht.Util.Button(compostGroup, {
                Text = T("Pull Compost Lever Now", "โยกคันโยกทันที"),
                Func = function()
                    Reicht.Colony.CompostPull()

                end,
            })
            compostGroup:AddToggle("AutoCompostUpgrade", {
                Text = T("Auto Upgrade Compost", "อัปเกรดเครื่องหมักปุ๋ยอัตโนมัติ"),
                Default = false,
                Description = T("Upgrades compost when eligible", "อัปเกรดขั้นเครื่องหมักปุ๋ยเมื่อเหรียญพอ"),
                Callback = function(v) State.Opt.AutoCompostUpgrade = v end,
            })
            Reicht.Util.Button(compostGroup, {
                Text = T("Upgrade Compost Now", "อัปเกรดเครื่องหมักปุ๋ยทันที"),
                Func = function()
                    Reicht.Colony.CompostUpgrade()
                    Reicht.Util.Later(function() Library:Notify("Reicht", "Compost upgrade requested", 3) end)
                end,
            })

            local rollGroup = farmTab:AddRightGroupbox(T("Ant Summoning", "อัญเชิญมด"), "sparkles", "OP")
            rollGroup:AddToggle("AutoRoll", {
                Text = T("Auto Roll Ants", "สุ่มมดอัตโนมัติ"),
                Default = false,
                Description = T("Rolls when the next summon is ready", "สุ่มมดเมื่อพร้อมสุ่มครั้งต่อไป"),
                Callback = function(v) State.Opt.AutoRoll = v end,
            })
            rollGroup:AddDropdown("ClaimRarities", {
                Text = T("Claim Rarities (Empty = All)", "ระดับที่รับ (ว่าง = ทั้งหมด)"), Values = Reicht.Data.ClaimRarities or {}, Multi = true, Default = {},
                Callback = function(value) State.Opt.ClaimRarities = value end,
            })
            rollGroup:AddToggle("AutoClaimRolled", {
                Text = T("Auto Claim Rolled Ants", "รับมดที่สุ่มได้ทันที"),
                Default = false,
                Description = T("Instantly claims ant without walking to pedestal", "รับมดเข้ากระเป๋าโดยไม่ต้องเดินไปกดที่แท่น"),
                Callback = function(v) State.Opt.AutoClaimRolled = v end,
            })
            Reicht.Util.Button(rollGroup, { Text = T("Claim Rolled Ants Now", "รับมดที่สุ่มได้ทันที"),
                Func = function() Reicht.Util.Child(Reicht.Colony.ClaimPending) end,
            })
            rollGroup:AddSlider("RollDelay", {
                Text = T("Roll Delay", "คูลดาวน์การสุ่ม"),
                Min = 0.5,
                Max = 10,
                Default = 3.1,
                Rounding = 1,
                Suffix = "s",
                Callback = function(v)
                    State.Opt.RollDelay = v
                    local rollJob = JobIndex["AutoRoll"]
                    if rollJob then rollJob.interval = math.max(0.15, v) end
                end,
            })
            Reicht.Util.Button(rollGroup, {
                Text = T("Roll Ant Now", "สุ่มมดทันที"),
                Func = function()
                    Reicht.Colony.RollAnt(nil)

                end,
            })

            local colonyGroup = farmTab:AddRightGroupbox(T("Colony Management", "จัดการรังมด"), "users")
            colonyGroup:AddToggle("AutoEquipBest", {
                Text = T("Auto Equip Best Ants", "ใส่มดที่ดีที่สุดอัตโนมัติ"),
                Default = false,
                Description = T("Continuously optimizes equipped ants via game evaluator", "คัดเลือกและใส่มดพลังสูงสุดอัตโนมัติ"),
                Callback = function(v) State.Opt.AutoEquipBest = v end,
            })
            Reicht.Util.Button(colonyGroup, {
                Text = T("Equip Best Ants Now", "ใส่มดที่ดีที่สุดทันที"),
                Func = function()
                    Reicht.Colony.EquipBest()

                end,
            })
            colonyGroup:AddToggle("AutoPlaceAnts", {
                Text = T("Auto Place Ants into Nest", "วางมดลงรังอัตโนมัติ"),
                Default = false,
                Description = T("Fills empty nest slots with owned ants", "บรรจุมดลงในช่องรังที่ยังว่าง"),
                Callback = function(v) State.Opt.AutoPlaceAnts = v end,
            })
            Reicht.Util.Button(colonyGroup, {
                Text = T("Place Ants into Nest Now", "วางมดลงรังทันที"),
                Func = function()
                    Reicht.Colony.PlaceAnts()

                end,
            })

            win:AddTabSection(T("Progression", "พัฒนา"))
            local progTab = win:AddTab(T("Progression & Shop", "อัปเกรดและร้านค้า"), "trending-up", T("Stat upgrades, shops, and rewards", "อัปสเตตัส ร้านค้า และรางวัล"))

            local poolGroup = progTab:AddLeftGroupbox(T("Ant Pool Upgrade", "อัปเกรดตู้สุ่มมด"), "arrow-up-circle", "OP")
            poolGroup:AddToggle("AutoPool", {
                Text = T("Auto Upgrade Pool", "อัปเกรดตู้สุ่มอัตโนมัติ"),
                Default = false,
                Description = T("Upgrades the pool when cash allows", "เพิ่มระดับตู้สุ่มอัตโนมัติเมื่ออาหารพอ"),
                Callback = function(v) State.Opt.AutoPool = v end,
            })
            poolGroup:AddSlider("PoolBurst", {
                Text = T("Upgrade Burst", "จำนวนครั้งต่อรอบ"),
                Min = 1,
                Max = 10,
                Default = 5,
                Rounding = 0,
                Callback = function(v) State.Opt.PoolBurst = v end,
            })
            Reicht.Util.Button(poolGroup, {
                Text = T("Upgrade Pool Now", "อัปเกรดตู้สุ่มทันที"),
                Func = function()
                    for _ = 1, State.Opt.PoolBurst do
                        Reicht.Progression.UpgradePool()
                    end

                end,
            })

            local attrGroup = progTab:AddLeftGroupbox(T("Player Attributes", "อัปเกรดสเตตัสตัวละคร"), "shield")
            attrGroup:AddToggle("AutoAttr", {
                Text = T("Auto Upgrade Attributes", "อัปเกรดสเตตัสอัตโนมัติ"),
                Default = false,
                Description = T("Automatically buys stat upgrades using gold", "ใช้เงินอัปเกรดค่าพลังอัตโนมัติ"),
                Callback = function(v) State.Opt.AutoAttr = v end,
            })
            attrGroup:AddDropdown("AttrTarget", {
                Text = T("Target Stat", "สเตตัสเป้าหมาย"),
                Values = Reicht.Data.AttributeNames,
                Default = Reicht.Data.AttributeNames[1] or "Ant Attack Power",
                Callback = function(v) State.Opt.AttrTarget = v end,
            })
            attrGroup:AddToggle("UpgradeAllAttr", {
                Text = T("Auto Select Stat", "อัปเกรดทุกสเตตัสพร้อมกัน"),
                Default = false,
                Description = T("Selects the next affordable stat", "อัปเกรดสเตตัสครบทุกสาย"),
                Callback = function(v) State.Opt.UpgradeAllAttr = v end,
            })
            Reicht.Util.Button(attrGroup, {
                Text = T("Upgrade Stat Now", "อัปเกรดสเตตัสทันที"),
                Func = function()
                    if State.Opt.UpgradeAllAttr then
                        Reicht.Progression.UpgradeAll()
                    else
                        Reicht.Progression.UpgradeAttribute(State.Opt.AttrTarget)
                    end

                end,
            })

            local shopGroup = progTab:AddRightGroupbox(T("Shops & Vendors", "ร้านค้าและกิจกรรม"), "shopping-bag")
            local activityDropdown = shopGroup:AddDropdown("ActivityItem", {
                Text = T("Activity Item", "สินค้ากิจกรรม"), Values = Reicht.Data.ActivityLabels, Searchable = true,
                Callback = function(value) State.Opt.ActivityItem = Reicht.Data.ActivityIds[value] end,
            })
            if activityDropdown.SetImages then
                activityDropdown:SetImages(Reicht.Data.ActivityImages, Reicht.Data.ActivityColors)
                State.ActivityDropdown = activityDropdown
            end
            shopGroup:AddToggle("AutoActivity", {
                Text = T("Auto Buy Activity Shop", "ซื้อร้านกิจกรรมอัตโนมัติ"),
                Default = false,
                Description = T("Purchases available stock from activity shop", "ซื้อไอเทมร้านกิจกรรมอัตโนมัติ"),
                Callback = function(v) State.Opt.AutoActivity = v end,
            })
            Reicht.Util.Button(shopGroup, {
                Text = T("Buy Activity Items Now", "ซื้อไอเทมกิจกรรมทันที"),
                Func = function()
                    Reicht.Shop.PurchaseActivity(State.Opt.ActivityItem)

                end,
            })
            Reicht.Util.Button(shopGroup, {
                Text = T("Refresh Gear Shop Stock", "รีเฟรชสต็อกร้านอุปกรณ์"),
                Func = function()
                    Reicht.Shop.RefreshGearSnapshot()

                end,
            })

            local rewardsGroup = progTab:AddRightGroupbox(T("Rewards & Codes", "รางวัลและโค้ด"), "gift")
            rewardsGroup:AddToggle("AutoOnlineAward", {
                Text = T("Auto Claim Online Awards", "รับรางวัลออนไลน์อัตโนมัติ"),
                Default = false,
                Description = T("Claims all eligible timed online reward slots", "กดรับของรางวัลตามเวลาออนไลน์อัตโนมัติ"),
                Callback = function(v) State.Opt.AutoOnlineAward = v end,
            })
            Reicht.Util.Button(rewardsGroup, {
                Text = T("Claim Online Awards Now", "รับรางวัลออนไลน์ทันที"),
                Func = function()
                    Reicht.Collect.ClaimAllOnlineAwards()

                end,
            })
            Reicht.Util.Button(rewardsGroup, {
                Text = T("Redeem All Codes", "แลกโค้ดทั้งหมดทันที"),
                Func = function()
                    Reicht.Rewards.RedeemAll()
                    Reicht.Util.Later(function() Library:Notify("Reicht", "Checking code responses...", 5) end)
                end,
            })


            win:AddTabSection(T("Misc", "อื่นๆ"))
            local worldTab = win:AddTab(T("World & Visuals", "โลกและสายตา"), "swords", T("Bosses, teleports, and visual ESP", "บอส วาร์ป และระบบมองทะลุ"))

            local bossGroup = worldTab:AddLeftGroupbox(T("World Boss", "บอสโลก"), "flame", "OP")
            bossGroup:AddToggle("AutoLootBossCoins", {
                Text = T("Auto Loot Strawberry Coins", "เก็บเหรียญสตรอว์เบอร์รี่อัตโนมัติ"),
                Default = false,
                Description = T("Collects available strawberry coins", "เก็บเหรียญที่ดรอปจากบอสอัตโนมัติ"),
                Callback = function(v) State.Opt.AutoLootBossCoins = v end,
            })
            Reicht.Util.Button(bossGroup, {
                Text = T("Loot Boss Coins Now", "เก็บเหรียญบอสทันที"),
                Func = function()
                    Reicht.Boss.LootCoins()

                end,
            })
            local tpGroup = worldTab:AddLeftGroupbox(T("Teleports", "จุดวาร์ป"), "map-pin")
            local destination = tpGroup:AddDropdown("Destination", {
                Text = T("Destination", "จุดหมาย"), Values = {}, Searchable = true,
                Callback = function(value) State.Opt.Destination = value end,
            })
            Reicht.Util.Button(tpGroup, { Text = T("Refresh Destinations", "รีเฟรชจุดวาร์ป"), Func = function()
                local names = Reicht.Teleport.Refresh()
                Reicht.Util.Later(function() destination:SetValues(names) end)
            end })
            Reicht.Util.Button(tpGroup, { Text = T("Teleport Now", "วาร์ปทันที"), Func = function()
                return Reicht.Teleport.Travel(State.Opt.Destination)
            end })
            Reicht.Util.Button(tpGroup, { Text = T("Return Now", "กลับจุดเดิมทันที"), Func = Reicht.Teleport.Return })
            Reicht.Util.Child(function()
                local names = Reicht.Teleport.Refresh()
                Reicht.Util.Later(function() destination:SetValues(names) end)
            end)

            local espGroup = worldTab:AddRightGroupbox(T("Visuals & ESP", "สายตาและอีเอสพี"), "eye")
            espGroup:AddToggle("EspBoss", {
                Text = T("Boss ESP", "มองทะลุบอส"),
                Default = false,
                Description = T("Highlights Strawberry King boss and indicators", "แสดงกรอบเรืองแสงบอส Strawberry King"),
                Callback = function(v)
                    State.Opt.EspBoss = v
                    if not v then Reicht.Esp.Clear() end
                end,
            })
            espGroup:AddToggle("EspDungeon", {
                Text = T("Dungeon ESP", "มองทะลุดันเจียน"),
                Default = false,
                Description = T("Highlights dungeon portal entrances", "แสดงประตูดันเจียน"),
                Callback = function(v)
                    State.Opt.EspDungeon = v
                    if not v then Reicht.Esp.Clear() end
                end,
            })
            espGroup:AddToggle("EspPlayers", {
                Text = T("Player ESP", "มองทะลุผู้เล่น"),
                Default = false,
                Description = T("Highlights other players in range", "แสดงกรอบผู้เล่นคนอื่นในแมพ"),
                Callback = function(v)
                    State.Opt.EspPlayers = v
                    if not v then Reicht.Esp.Clear() end
                end,
            })
            espGroup:AddSlider("EspDist", {
                Text = T("ESP Max Distance", "ระยะสูงสุด ESP"),
                Min = 100,
                Max = 2000,
                Default = 800,
                Rounding = 0,
                Suffix = " studs",
                Callback = function(v) State.Opt.EspDist = v end,
            })

            local perfGroup = worldTab:AddRightGroupbox(T("Utilities", "เครื่องมือช่วยเหลือ"), "sliders")
            perfGroup:AddToggle("Fullbright", {
                Text = T("Fullbright", "แสงสว่างเต็มที่"),
                Default = false,
                Description = T("Eliminates darkness and fog globally", "ปรับแสงให้สว่างทั่วแมพไม่มีหมอก"),
                Callback = function(v)
                    State.Opt.Fullbright = v
                    Reicht.Movement.ApplyFullbright()
                end,
            })
            perfGroup:AddToggle("AntiAfk", {
                Text = T("Anti-AFK", "ป้องกันการหลุด AFK"),
                Default = false,
                Description = T("Prevents client disconnection from 20-minute idle", "ป้องกัน Roblox เตะเมื่อเปิดทิ้งไว้"),
                Callback = function(v) State.Opt.AntiAfk = v end,
            })
            Reicht.Util.Button(perfGroup, {
                Text = T("Rejoin Server", "เข้าเซิร์ฟเดิมใหม่"),
                Func = function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end,
            })


            local playerTab = win:AddTab(T("Movement & Physics", "การเคลื่อนที่"), "user", T("Walkspeed, flying, and collision", "ความเร็วเดิน บิน และทะลุกำแพง"))

            local speedGroup = playerTab:AddLeftGroupbox(T("Walk & Sprint", "ความเร็วเดิน"), "zap")
            local speedToggle = speedGroup:AddToggle("SpeedOn", {
                Text = T("Walk Speed", "เพิ่มความเร็วการเดิน"),
                Default = false,
                Description = T("Modifies humanoid walk speed", "เพิ่มความเร็วเดินของตัวละคร"),
                Callback = function(v)
                    State.Opt.SpeedOn = v
                    Reicht.Movement.ApplySpeed()
                end,
            })
            speedToggle:AddKeyPicker("SpeedKey", {
                Default = "None",
                SyncToggleState = true,
                Mode = "Toggle",
                Text = T("Speed Keybind", "ปุ่มความเร็ว"),
            })
            speedGroup:AddSlider("WalkSpeed", {
                Text = T("Speed Value", "ค่าความเร็ว"),
                Min = 16,
                Max = 350,
                Default = 200,
                Rounding = 0,
                Suffix = " ws",
                Callback = function(v)
                    State.Opt.WalkSpeed = v
                    Reicht.Movement.ApplySpeed()
                end,
            })

            local flyGroup = playerTab:AddRightGroupbox(T("Flight", "การบิน"), "wind")
            local flyToggle = flyGroup:AddToggle("FlyOn", {
                Text = T("Fly Mode", "โหมดบิน"),
                Default = false,
                Description = T("Fly freely in all directions", "บินได้อย่างอิสระทุกทิศทาง"),
                Callback = function(v)
                    State.Opt.FlyOn = v
                    Reicht.Movement.ApplyFly()
                end,
            })
            flyToggle:AddKeyPicker("FlyKey", {
                Default = "None",
                SyncToggleState = true,
                Mode = "Toggle",
                Text = T("Fly Keybind", "ปุ่มบิน"),
            })
            flyGroup:AddSlider("FlySpeed", {
                Text = T("Fly Speed", "ความเร็วบิน"),
                Min = 20,
                Max = 300,
                Default = 120,
                Rounding = 0,
                Suffix = " studs/s",
                Callback = function(v) State.Opt.FlySpeed = v end,
            })

            local physicsGroup = playerTab:AddLeftGroupbox(T("Physics & Collision", "ฟิสิกส์และการชน"), "shield")
            local noclipToggle = physicsGroup:AddToggle("NoclipOn", {
                Text = T("Noclip", "เดินทะลุกำแพง"),
                Default = false,
                Description = T("Pass through obstacles and walls", "เดินทะลุสิ่งกีดขวางและกำแพง"),
                Callback = function(v)
                    State.Opt.NoclipOn = v
                    if not v then
                        for part, collide in pairs(State.Collision) do
                            if part.Parent then part.CanCollide = collide end
                        end
                        table.clear(State.Collision)
                    end
                end,
            })
            noclipToggle:AddKeyPicker("NoclipKey", {
                Default = "None",
                SyncToggleState = true,
                Mode = "Toggle",
                Text = T("Noclip Keybind", "ปุ่มทะลุ"),
            })

            local infJumpToggle = physicsGroup:AddToggle("InfJump", {
                Text = T("Infinite Jump", "กระโดดไม่จำกัด"),
                Default = false,
                Description = T("Jump indefinitely in mid-air", "กระโดดกลางอากาศได้ตลอดเวลา"),
                Callback = function(v) State.Opt.InfJump = v end,
            })
            infJumpToggle:AddKeyPicker("InfJumpKey", {
                Default = "None",
                SyncToggleState = true,
                Mode = "Toggle",
                Text = T("Jump Keybind", "ปุ่มกระโดด"),
            })

            local charGroup = playerTab:AddRightGroupbox(T("Character Actions", "การจัดการตัวละคร"), "rotate-ccw")
            Reicht.Util.Button(charGroup, {
                Text = T("Respawn Character", "เกิดใหม่ทันที"),
                Func = function()
                    local hum = Reicht.Util.GetHum()
                    if hum then
                        hum.Health = 0
                    end
                end,
            })

            if Library.Compat then
                for index, paths in pairs(Reicht.GameLib.Missing()) do
                    local option = Library.Options[index]
                    if option then Library.Compat.Block(option, "Missing game dependency: " .. table.concat(paths, ", ")) end
                end
                Library.Compat.NeedCap(Library.Options.AutoLootBossCoins, "Prompt")
                local dependencies = {
                    KaitunMaster = "Context", AutoRoll = "Context", AutoClaimRolled = "Context", AutoCollectFood = "Carry", AutoWorkerFood = "Context", AutoAntRewards = "Context",
                    AutoSell = "Carry", AutoEquipBest = "Backpack", AutoPlaceAnts = "Backpack",
                    AutoPool = "PlayerData", AutoAttr = "Context", AutoActivity = "Activity",
                    AutoOnlineAward = "Online", AutoCompostPull = "Compost", AutoCompostUpgrade = "Compost",
                }
                for index, api in pairs(dependencies) do
                    if not Reicht.GameLib.Apis[api] then Library.Compat.Block(Library.Options[index], "Game data unavailable on this executor") end
                end
            end

            win:AddSettingsTab()

            Reicht.Util.Try(Reicht.Scheduler.Boot)
            pcall(ReichtBanner.Step, "Interface")
            pcall(ReichtBanner.Ready)
            Library:Every(Config.PumpInterval, Reicht.Util.Pump)
            pcall(function() Library:LoadAutoloadConfig() end)

            Reicht.Util.Child(function()
                while State.Alive and Library and Library.Window do
                    pcall(function()
                        local carriedFood = LocalPlayer:GetAttribute("CarriedSellFoodAmount") or 0
                        local maxSlots = LocalPlayer:GetAttribute("MaxAntSlots") or 1
                        local roomIdx = LocalPlayer:GetAttribute("RoomIndex") or 1
                        local nestLayer = LocalPlayer:GetAttribute("NestLayer") or 1
                        local txt = string.format("Room: %s  |  Nest Layer: %s  |  Ant Slots: %s  |  Carried Food: %s  |  Price: %s Gold",
                            tostring(roomIdx), tostring(nestLayer), tostring(maxSlots), tostring(carriedFood), tostring(State.FoodPrice))
                        local snapshot = Reicht.Data.Snapshot()
                        txt = txt .. string.format("\nCash: %.0f | Food: %.0f | Earned: %.0f | Sales: %d | Claims: %d\n%s", snapshot.Gold, snapshot.Food, State.Metrics.Gold, State.Metrics.Sales, State.Metrics.Claims, Reicht.Util.StatusText())
                        Reicht.Util.Later(function() statusPara:SetText(txt) end)
                    end)
                    task.wait(Config.StatusInterval)
                end
            end)
        end,
    })

end

function Reicht.Unload()
    if not State.Alive then return end
    State.Alive = false
    for _, conn in ipairs(State.Conns) do conn:Disconnect() end
    table.clear(State.Conns)
    local current = coroutine.running()
    for thread in pairs(State.ChildThreads) do
        if thread ~= current and coroutine.status(thread) ~= "dead" then pcall(task.cancel, thread) end
    end
    table.clear(State.ChildThreads)
    State.Opt.SpeedOn, State.Opt.FlyOn, State.Opt.NoclipOn, State.Opt.Fullbright = false, false, false, false
    Reicht.Movement.ApplySpeed()
    Reicht.Movement.ApplyFly()
    Reicht.Movement.ApplyFullbright()
    for part, collide in pairs(State.Collision) do
        if part.Parent then part.CanCollide = collide end
    end
    Reicht.Esp.Clear()
    if Library then pcall(Library.Unload, Library) end
    local ok, env = pcall(getgenv)
    if ok and env.AntEmpireUnload == Reicht.Unload then env.AntEmpireUnload = nil end
end

do
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" then env.AntEmpireUnload = Reicht.Unload end
end

pcall(ReichtBanner.Step, "Systems")
BuildInterface()