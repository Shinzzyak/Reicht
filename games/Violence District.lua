if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 6739698191 then
    game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Violence District only")
    return
end

if not LPH_OBFUSCATED then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local environment = getgenv and getgenv() or _G
if type(environment.ViolenceDistrictUnload) == "function" then
    pcall(environment.ViolenceDistrictUnload)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local vector3New, cframeNew, cframeLookAt = Vector3.new, CFrame.new, CFrame.lookAt
local vectorZero = Vector3.zero
local osClock, mathHuge = os.clock, math.huge

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
        "   VIOLENCE DISTRICT  //  by Reicht  //  ",
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

local Reicht = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

Reicht.Config = {
    UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
    Discord = "https://",
    UpdateLog = {
        { "2026-10-03", "Classic Reicht UI is back\nBetter executor support\nBug fixes & better UI" },
    },
    SaveFolder = "Violence District",
    Intro = true,
    LoadTimeout = 30,
    AlertTries = 20,
    AlertRetry = 0.5,
    JobFailLimit = 5,
    JobFailWindow = 10,
    StatusInterval = 1,
    RepairTick = 0.25,
    GenDone = 100,
    SpareGens = 1,
    AttackReach = 2,
    LungeDelay = 0.21,
    AuraCooldown = 1.1,
    CarryDelay = 0.8,
    Settle = 0.55,
    FinishFirst = 85,
    ArriveRadius = 4,
    DriftLimit = 12,
    DangerKeep = 2,
    DangerPick = 2.5,
    DistanceWeight = 0.05,
    HealMax = 15,
    HealMinUseful = 3,
    HelpBan = 8,
    UnhookReach = 10,
    GuardTick = 0.05,
    FarmDodge = 24,
    SwingTail = 0.4,
    LegitReach = 9,
    ServerReach = 4.2,
    ParryRange = 14,
    ParryPanic = 6,
    ParryClosing = 12,
    ParryRetry = 1,
    ParryFast = 0.25,
    ParryScan = 5,
    LegitAngle = 0.5,
    HookRest = 1,
    UnhookHold = 2.5,
    StallTime = 8,
    StallBan = 30,
    HookTween = 0.2,
    GenBreakTime = 2,
    KickRegress = 25,
    SelfUnhookRetry = 1,
    SelfUnhookMax = 12,
    DodgeCooldown = 1.5,
    RolePending = 8,
    JumpVelocity = 50,
    AlertRadius = 60,
    ShopDelay = 0.6,
    FirstLevelCost = 750,
    EscapeRetry = 6,
    ShopInterval = 10,
    SurvivorSpeed = 21,
    KillerSpeed = 18.7,
    ObjectEspRefresh = 1,
    ModelRescan = 10,
}

Reicht.State = {
    Alive = true,
    Connections = {},
}

Reicht.Options = {
    AntiAfk = false,
    RoleMode = "Any",
    Speed = false,
    SpeedValue = 24,
    Noclip = false,
    NoSlow = false,
    NoFall = false,
    FreeTurn = false,
    AntiShake = false,
    AntiBlind = false,
    SmartHitbox = false,
    SlashMode = "Rage",
    InfiniteJump = false,
    Fullbright = false,
    NoFog = false,

    AutoRepair = false,
    PerfectSkillCheck = false,
    InstantEscape = false,
    EscapeDelay = 0,
    AutoHeal = false,
    AutoUnhook = false,
    AutoDodge = false,
    DodgeRadius = 20,
    AutoSelfUnhook = false,
    AutoParry = false,
    NoParryCooldown = false,
    KillerAlert = false,

    AutoBuyPerks = false,
    AutoLevelPerks = false,
    KeepScrews = 0,

    KillAura = false,
    AuraRange = 500,
    AutoHook = false,
    AutoBreakGens = false,
    AntiStun = false,

    EspGenerators = false,
    EspHooks = false,
    EspGates = false,
    EspPallets = false,
    EspWindows = false,
}

Reicht.Util = {}
local Util = Reicht.Util

---@return function?  first argument that is callable
local function Resolve(...)
    for index = 1, select("#", ...) do
        local candidate = select(index, ...)
        if type(candidate) == "function" then return candidate end
    end
    return nil
end

Util.Request = Resolve(request, http_request, type(syn) == "table" and syn.request, type(http) == "table" and http.request)
Util.SetClipboard = Resolve(setclipboard, toclipboard)
Util.GetHui = Resolve(gethui, get_hidden_gui)
Util.GetConnections = Resolve(getconnections, get_signal_cons)
Util.FireSignal = Resolve(firesignal)
Util.FireTouch = Resolve(firetouchinterest)
Util.GetGc = Resolve(getgc, get_gc_objects)
Util.NameCallMethod = Resolve(getnamecallmethod)
Util.HookMetamethod = Resolve(hookmetamethod)
Util.Closure = Resolve(newcclosure) or function(fn) return fn end

Util.RawCaps = {
    Connections = function() return Util.GetConnections ~= nil end,
    Signals = function() return Util.FireSignal ~= nil end,
    Gc = function() return Util.GetGc ~= nil end,
    Namecall = function() return Util.HookMetamethod ~= nil and Util.NameCallMethod ~= nil end,
}

---@param cap string|string[]  Library.Compat cap name(s), false until the menu has loaded
function Util.Can(cap)
    local library = Reicht.Library
    if library == nil then return false end
    if library.Compat then return (library.Compat.Has(cap)) end
    for _, name in ipairs(type(cap) == "table" and cap or { cap }) do
        local probe = Util.RawCaps[name]
        if not (probe and probe()) then return false end
    end
    return true
end

---@return function?  original, nil when the executor refused the hook
---@return function?  restore
function Util.HookMeta(object, method, handler)
    local compat = Reicht.Library and Reicht.Library.Compat
    if compat then return compat.HookMeta(object, method, handler) end
    if not Util.HookMetamethod then return nil end

    local ok, original = pcall(Util.HookMetamethod, object, method, Util.Closure(handler))
    if not ok or type(original) ~= "function" then return nil end
    return original, function()
        Util.HookMetamethod(object, method, original)
    end
end

---@return string?  response body, nil when every transport failed
function Util.HttpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" then return body end
    if not Util.Request then return nil end
    local sent, response = pcall(Util.Request, { Url = url, Method = "GET" })
    if sent and type(response) == "table" and tonumber(response.StatusCode) == 200 and type(response.Body) == "string" then
        return response.Body
    end
    return nil
end

---@param text string  shown as a Roblox notification, works before the menu exists
function Util.Alert(text)
    warn("[ViolenceDistrict] " .. text)
    task.spawn(function()
        local starterGui = game:GetService("StarterGui")
        for _ = 1, Reicht.Config.AlertTries do
            if pcall(starterGui.SetCore, starterGui, "SendNotification", { Title = "Reicht", Text = text, Duration = 10 }) then return end
            task.wait(Reicht.Config.AlertRetry)
        end
    end)
end

---@return table?  UI library, nil after telling the player why
function Util.LoadLibrary()
    local source = Util.HttpGet(Reicht.Config.UiSource)
    if not source or not source:sub(-64):find("return Library%s*$") then
        Util.Alert("Could not download the menu. Check your connection and run it again.")
        return nil
    end
    local chunk, err = loadstring(source)
    if not chunk then
        Util.Alert("The menu failed to load on this executor: " .. tostring(err))
        return nil
    end
    local ok, library = pcall(chunk)
    if not ok or type(library) ~= "table" then
        Util.Alert("The menu failed to load on this executor: " .. tostring(library))
        return nil
    end
    return library
end

function Util.Copy(text)
    if not Util.SetClipboard then return false end
    Util.SetClipboard(text)
    return true
end

---@return boolean, any  pcall result, warns with the label when it fails
function Util.Try(label, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[ViolenceDistrict] " .. label .. ": " .. tostring(err)) end
    return ok, err
end

---@param instance Instance  parented to gethui, then CoreGui, then PlayerGui
function Util.Mount(instance)
    local ok, hui = pcall(Util.GetHui or error)
    if ok and typeof(hui) == "Instance" and pcall(function() instance.Parent = hui end) then return end
    if pcall(function() instance.Parent = game:GetService("CoreGui") end) then return end
    instance.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", Reicht.Config.LoadTimeout)
end

function Reicht:Connect(signal, handler)
    local connection = signal:Connect(handler)
    table.insert(self.State.Connections, connection)
    return connection
end

Reicht.GameLib = {}
local GameLib = Reicht.GameLib

GameLib.Folder = ReplicatedStorage:WaitForChild("Remotes", Reicht.Config.LoadTimeout)

---@return Instance?  remote at the path under Remotes, else the only remote with that name anywhere under it
function GameLib.FindRemote(...)
    local root = GameLib.Folder
    if not root then return nil end
    local node = root
    for _, step in ipairs({ ... }) do
        node = node and node:FindFirstChild(step)
    end
    if node then return node end

    local name, found = select(select("#", ...), ...), nil
    for _, desc in ipairs(root:GetDescendants()) do
        if desc.Name ~= name or not (desc:IsA("BaseRemoteEvent") or desc:IsA("RemoteFunction")) then continue end
        if found then return nil end
        found = desc
    end
    return found
end

GameLib.RemotePaths = {
    Repair = { "Generator", "RepairEvent" },
    GenCheck = { "Generator", "SkillCheckEvent" },
    GenResult = { "Generator", "SkillCheckResultEvent" },
    Heal = { "Healing", "HealEvent" },
    HealCheck = { "Healing", "SkillCheckEvent" },
    HealResult = { "Healing", "SkillCheckResultEvent" },
    Unhook = { "Carry", "UnHookEvent" },
    SelfUnhook = { "Carry", "SelfUnHookEvent" },
    Fall = { "Mechanics", "Fall" },
    Carry = { "Carry", "CarrySurvivorEvent" },
    Hook = { "Carry", "HookEvent" },
    HookCommit = { "Carry", "HookCommit" },
    BreakGen = { "Generator", "BreakGenEvent" },
    BreakGenCommit = { "Generator", "BreakGenCommit" },
    Lunge = { "Attacks", "Lunge" },
    Stun = { "Pallet", "Jason", "Stun" },
    StunOver = { "Pallet", "Jason", "Stunover" },
    Attack = { "Attacks", "BasicAttack" },
    BuyPerk = { "Shop", "PurchasePerk" },
    LevelPerk = { "Shop", "LevelUpPerk" },
    PerkInfo = { "Shop", "GetPerkInfo" },
}

GameLib.Remote = {}
for key, path in pairs(GameLib.RemotePaths) do
    GameLib.Remote[key] = GameLib.FindRemote(table.unpack(path))
end

GameLib.Needs = {
    AutoRepair = { "Repair" },
    PerfectSkillCheck = { "GenCheck", "HealCheck", "GenResult", "HealResult" },
    AutoHeal = { "Heal" },
    AutoUnhook = { "Unhook" },
    AutoSelfUnhook = { "SelfUnhook" },
    NoFall = { "Fall" },
    KillAura = { "Lunge", "Attack" },
    AutoHook = { "Carry", "Hook", "HookCommit" },
    AutoBreakGens = { "BreakGen", "BreakGenCommit" },
    AntiStun = { "Stun", "StunOver" },
    AutoBuyPerks = { "BuyPerk", "PerkInfo" },
    AutoLevelPerks = { "LevelPerk", "PerkInfo" },
}

---@return string?  "Folder/Name" of the first remote the toggle needs that is gone
function GameLib.Missing(idx)
    for _, key in ipairs(GameLib.Needs[idx] or {}) do
        if not GameLib.Remote[key] then return table.concat(GameLib.RemotePaths[key], "/") end
    end
    return nil
end

Reicht.Player = { Client = LocalPlayer }

function Reicht.Player:Bind(character)
    self.Character = character
    self.Humanoid = character:WaitForChild("Humanoid", Reicht.Config.LoadTimeout)
    self.Root = character:WaitForChild("HumanoidRootPart", Reicht.Config.LoadTimeout)
end

function Reicht.Player:IsAlive()
    return self.Humanoid ~= nil and self.Humanoid.Health > 0 and self.Root ~= nil and self.Root.Parent ~= nil
end

---@return string?  "Survivors" / "Killer" / "Spectator"
function Reicht.Player.Role(player)
    local team = (player or LocalPlayer).Team
    return team and team.Name or nil
end

---@return boolean  downed, hooked or carried
function Reicht.Player.Disabled(character)
    if not character then return true end
    return character:GetAttribute("Knocked") == true
        or character:GetAttribute("IsHooked") == true
        or character:GetAttribute("IsCarried") == true
end

function Reicht.Player.Killer()
    local team = Teams:FindFirstChild("Killer")
    local killer = team and team:GetPlayers()[1]
    return killer and killer.Character
end

function Reicht.Player.Survivors()
    local team = Teams:FindFirstChild("Survivors")
    local list = {}
    if not team then return list end
    for _, player in ipairs(team:GetPlayers()) do
        local char = player.Character
        if player ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") then
            list[#list + 1] = char
        end
    end
    return list
end

function Reicht.Player.Teleport(cframe)
    local hrp = Reicht.Player.Root
    if not hrp then return end
    hrp.CFrame = cframe
    hrp.AssemblyLinearVelocity = vectorZero
end

Reicht.Map = {}

function Reicht.Map.Root()
    return Workspace:FindFirstChild("Map")
end

function Reicht.Map.Tagged(tag)
    local map = Reicht.Map.Root()
    local list = {}
    if not map then return list end
    for _, part in ipairs(CollectionService:GetTagged(tag)) do
        if part:IsA("BasePart") and part:IsDescendantOf(map) then
            list[#list + 1] = part
        end
    end
    return list
end

Reicht.Map.Cache = { Map = nil, Models = {}, Scanned = {}, Total = 0 }

---@return Model[]  every model with this name in the current map, cached per round
function Reicht.Map.Models(name)
    local map = Reicht.Map.Root()
    local cache = Reicht.Map.Cache
    if not map then return {} end
    if cache.Map ~= map then
        cache.Map, cache.Models, cache.Scanned = map, {}, {}
    end
    local list = cache.Models[name]
    local fresh = osClock() - (cache.Scanned[name] or 0) < Reicht.Config.ModelRescan
    if list and fresh and (not list[1] or list[1]:IsDescendantOf(map)) then return list end
    cache.Scanned[name] = osClock()
    list = {}
    for _, inst in ipairs(map:GetDescendants()) do
        if inst.Name == name and inst:IsA("Model") then list[#list + 1] = inst end
    end
    cache.Models[name] = list
    return list
end

---@return Model[]  every generator on the map, finished ones included
function Reicht.Map.Generators()
    return Reicht.Map.Models("Generator")
end

---@return BasePart[]  GeneratorPoint parts of one generator, cached per round
function Reicht.Map.PointsOf(gen)
    local cache = Reicht.Map.Cache
    cache.Points = cache.Points or setmetatable({}, { __mode = "k" })
    local list = cache.Points[gen]
    if list and list[1] and list[1].Parent then return list end
    list = {}
    for _, point in ipairs(Reicht.Map.Tagged("GeneratorPoint")) do
        if point:IsDescendantOf(gen) then list[#list + 1] = point end
    end
    cache.Points[gen] = list
    return list
end

function Reicht.Map.GenProgress(model)
    return tonumber(model:GetAttribute("RepairProgress")) or 0
end

---@return number  gens still needed before the exits power (one gen is spare)
function Reicht.Map.GensLeft()
    local gens = Reicht.Map.Generators()
    local cache = Reicht.Map.Cache
    local map = Reicht.Map.Root()
    if cache.TotalMap ~= map then cache.TotalMap, cache.Total = map, 0 end
    cache.Total = math.max(cache.Total, #gens)
    local done = 0
    for _, gen in ipairs(gens) do
        if Reicht.Map.GenProgress(gen) >= Reicht.Config.GenDone then done += 1 end
    end
    return math.max(cache.Total - Reicht.Config.SpareGens - done, 0)
end

---@return BasePart?, number  closest part to pos
function Reicht.Map.Nearest(parts, pos, filter)
    local best, bestDist = nil, mathHuge
    for _, part in ipairs(parts) do
        if filter and not filter(part) then continue end
        local dist = (part.Position - pos).Magnitude
        if dist < bestDist then best, bestDist = part, dist end
    end
    return best, bestDist
end

Reicht.Scheduler = { Jobs = {}, Halts = {}, Booted = false }

---@param toggles string[]?  switched off when the job keeps failing
---@param extra table?       { Core = keeps running whatever fails, Restore = run once when it halts }
function Reicht.Scheduler.Every(name, interval, fn, toggles, extra)
    extra = extra or {}
    Reicht.Scheduler.Jobs[name] = {
        Interval = interval, Fn = fn, Last = 0, Running = false, Toggles = toggles or {},
        Core = extra.Core or toggles == nil, Restore = extra.Restore,
    }
end

---Turns the job's options off for the logic right away; the menu toggles follow on the next UI pump.
---@return string[]  idx of every toggle that was on
function Reicht.Scheduler.SwitchOff(job)
    local switched = {}
    for _, idx in ipairs(job.Toggles) do
        if Reicht.Options[idx] then
            Reicht.Options[idx] = false
            switched[#switched + 1] = idx
        end
    end
    return switched
end

---Warns once per failure streak. Config.JobFailLimit errors spanning Config.JobFailWindow seconds switch the job's toggles off and run its restore; a non-core job with nothing to switch off rests until one turns back on.
function Reicht.Scheduler.Fail(name, job, err)
    local streak = job.Streak
    if not streak then
        streak = { count = 0, since = osClock() }
        job.Streak = streak
        warn("[ViolenceDistrict] job " .. name .. ":", err)
    end
    streak.count += 1
    if streak.count < Reicht.Config.JobFailLimit or osClock() - streak.since < Reicht.Config.JobFailWindow then return end

    local switched = Reicht.Scheduler.SwitchOff(job)
    if job.Core and #switched == 0 then return end
    job.Streak = nil
    job.Stopped = not job.Core and #switched == 0
    if job.Restore then Util.Try("restore " .. name, job.Restore) end

    local reason = tostring(err):match("^[^\n]*")
    warn("[ViolenceDistrict] job " .. name .. " stopped: " .. reason)
    if #switched > 0 then
        table.insert(Reicht.Scheduler.Halts, { Toggles = switched, Message = name .. " stopped: " .. reason })
    end
end

---@return boolean  a resting job may run again
function Reicht.Scheduler.Wakes(job)
    for _, idx in ipairs(job.Toggles) do
        if Reicht.Options[idx] then
            job.Stopped = nil
            return true
        end
    end
    return false
end

function Reicht.Scheduler.Step()
    local now = osClock()
    for name, job in pairs(Reicht.Scheduler.Jobs) do
        if job.Running or now - job.Last < job.Interval then continue end
        if job.Stopped and not Reicht.Scheduler.Wakes(job) then continue end
        job.Last = now
        job.Running = true
        task.spawn(function()
            local ok, err = pcall(job.Fn)
            job.Running = false
            if ok then
                job.Streak = nil
            else
                Reicht.Scheduler.Fail(name, job, err)
            end
        end)
    end
end

function Reicht.Scheduler.Boot()
    if Reicht.Scheduler.Booted then return end
    Reicht.Scheduler.Booted = true
    Reicht:Connect(RunService.Heartbeat, Reicht.Scheduler.Step)
end

Reicht.Player.AntiAfk = { Connection = nil }

function Reicht.Player.AntiAfk.OnIdled()
    if not Reicht.Options.AntiAfk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end

function Reicht.Player.AntiAfk.Arm()
    if Reicht.Player.AntiAfk.Connection then return end
    Reicht.Player.AntiAfk.Connection = Reicht:Connect(LocalPlayer.Idled, Reicht.Player.AntiAfk.OnIdled)
end

Reicht.Role = { Pending = 0 }

function Reicht.Role.Step()
    local mode = Reicht.Options.RoleMode
    if mode ~= "Survivor only" and mode ~= "Prefer killer" then return end
    if LocalPlayer:GetAttribute("AllowKiller") == (mode == "Prefer killer") or osClock() < Reicht.Role.Pending then return end
    local settings = LocalPlayer.PlayerGui:FindFirstChild("Settings", true)
    local button = settings and settings:FindFirstChild("chance", true)
    button = button and button:FindFirstChildWhichIsA("GuiButton")
    if not button or not Reicht.Role.Supported() then return end
    Reicht.Role.Pending = osClock() + Reicht.Config.RolePending
    if not Util.Can("Connections") then
        Util.FireSignal(button.MouseButton1Click)
        return
    end
    for _, conn in ipairs(Util.GetConnections(button.MouseButton1Click)) do
        conn:Fire()
    end
end

---@return boolean  the executor can press the game's killer-chance button
function Reicht.Role.Supported()
    return Util.Can("Connections") or Util.Can("Signals")
end

Reicht.Movement = { Collide = {}, JumpConn = nil, Walk = nil, Lifted = nil, LiftedTo = nil }

function Reicht.Movement.Frame()
    local hum, char = Reicht.Player.Humanoid, Reicht.Player.Character
    if not hum or not char then return end

    if Reicht.Options.Speed then
        if not Reicht.Movement.Walk then
            Reicht.Movement.Walk = Reicht.Movement.Lifted or hum.WalkSpeed
            Reicht.Movement.Lifted, Reicht.Movement.LiftedTo = nil, nil
        end
        hum.WalkSpeed = Reicht.Options.SpeedValue
    elseif Reicht.Movement.Walk then
        hum.WalkSpeed = Reicht.Movement.Walk
        Reicht.Movement.Walk = nil
    end
    if Reicht.Options.NoSlow and not Reicht.Options.Speed and hum.WalkSpeed > 0 then
        local base = Reicht.Movement.BaseSpeed(char)
        if hum.WalkSpeed < base then
            Reicht.Movement.Lifted = hum.WalkSpeed
            Reicht.Movement.LiftedTo = base
            hum.WalkSpeed = base
        end
    elseif Reicht.Movement.Lifted then
        Reicht.Movement.DropLift(hum, char)
    end

    if Reicht.Options.FreeTurn and not hum.AutoRotate and not char:GetAttribute("overridelookscript") and not char:GetAttribute("Immobile") then
        local root = Reicht.Player.Root
        local look = Workspace.CurrentCamera.CFrame.LookVector
        local flat = vector3New(look.X, 0, look.Z)
        if root and flat.Magnitude > 0 then root.CFrame = cframeLookAt(root.Position, root.Position + flat) end
    end

    if Reicht.Options.Noclip then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                Reicht.Movement.Collide[part] = true
                part.CanCollide = false
            end
        end
    elseif next(Reicht.Movement.Collide) then
        Reicht.Movement.RestoreCollide()
    end
end

---@return number  normal run speed for the current role
function Reicht.Movement.BaseSpeed(char)
    if Reicht.Player.Role() == "Killer" then
        return tonumber(char:GetAttribute("Speed")) or Reicht.Config.KillerSpeed
    end
    return Reicht.Config.SurvivorSpeed
end

---skipped when the game has since changed the speed itself
---@param hum  Humanoid
---@param char Model
function Reicht.Movement.DropLift(hum, char)
    local before, wrote = Reicht.Movement.Lifted, Reicht.Movement.LiftedTo
    Reicht.Movement.Lifted, Reicht.Movement.LiftedTo = nil, nil
    if char:GetAttribute("Sprinting") or hum.WalkSpeed ~= wrote then return end
    hum.WalkSpeed = before
end

function Reicht.Movement.RestoreCollide()
    for part in pairs(Reicht.Movement.Collide) do
        if part.Parent then part.CanCollide = true end
    end
    table.clear(Reicht.Movement.Collide)
end

function Reicht.Movement.OnJump()
    if not Reicht.Options.InfiniteJump then return end
    local hrp = Reicht.Player.Root
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = vector3New(vel.X, Reicht.Config.JumpVelocity, vel.Z)
end

function Reicht.Movement.Start()
    Reicht:Connect(RunService.Stepped, Reicht.Movement.Frame)
    Reicht:Connect(UserInputService.JumpRequest, Reicht.Movement.OnJump)
end

function Reicht.Movement.Release()
    Reicht.Movement.RestoreCollide()
    local hum = Reicht.Player.Humanoid
    local char = Reicht.Player.Character
    if hum and hum.Parent and char and Reicht.Movement.Lifted then Reicht.Movement.DropLift(hum, char) end
    if hum and hum.Parent and Reicht.Movement.Walk then hum.WalkSpeed = Reicht.Movement.Walk end
    Reicht.Movement.Walk = nil
    Reicht.Movement.Lifted, Reicht.Movement.LiftedTo = nil, nil
end

Reicht.World = { Saved = nil }

function Reicht.World.Save()
    if Reicht.World.Saved then return end
    Reicht.World.Saved = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Atmosphere = {},
    }
    for _, atmo in ipairs(Lighting:GetChildren()) do
        if atmo:IsA("Atmosphere") then Reicht.World.Saved.Atmosphere[atmo] = atmo.Density end
    end
end

function Reicht.World.Step()
    local bright, fog = Reicht.Options.Fullbright, Reicht.Options.NoFog
    if not bright and not fog then
        Reicht.World.Restore()
        return
    end
    Reicht.World.Save()
    local saved = Reicht.World.Saved

    if bright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness, Lighting.ClockTime = saved.Brightness, saved.ClockTime
        Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = saved.GlobalShadows, saved.Ambient, saved.OutdoorAmbient
    end

    Lighting.FogEnd = fog and 1e6 or saved.FogEnd
    Lighting.FogStart = fog and 1e6 or saved.FogStart
    for atmo, density in pairs(saved.Atmosphere) do
        if atmo.Parent then atmo.Density = fog and 0 or density end
    end
end

function Reicht.World.Restore()
    local saved = Reicht.World.Saved
    if not saved then return end
    Reicht.World.Saved = nil
    Lighting.Brightness, Lighting.ClockTime = saved.Brightness, saved.ClockTime
    Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = saved.GlobalShadows, saved.Ambient, saved.OutdoorAmbient
    Lighting.FogEnd, Lighting.FogStart = saved.FogEnd, saved.FogStart
    for atmo, density in pairs(saved.Atmosphere) do
        if atmo.Parent then atmo.Density = density end
    end
end

Reicht.Block = { Muted = {}, Own = {}, Restore = nil }

---@return RBXScriptSignal?  game signal a rule silences
local function RemoteSignal(folder, ...)
    local node = ReplicatedStorage:FindFirstChild("Remotes")
    for _, name in ipairs({ folder, ... }) do
        node = node and node:FindFirstChild(name)
    end
    if not node then return nil end
    return node:IsA("BindableEvent") and node.Event or node.OnClientEvent
end

Reicht.Block.Rules = {
    { Option = "PerfectSkillCheck", Signals = { RemoteSignal("Generator", "SkillCheckEvent"), RemoteSignal("Healing", "SkillCheckEvent") } },
    { Option = "AntiStun", Signals = { RemoteSignal("Pallet", "Jason", "Stun") } },
    { Option = "AntiBlind", Signals = { RemoteSignal("Items", "Flashlight", "GotBlinded") } },
    { Option = "AntiShake", Signals = { RemoteSignal("Game", "shake") } },
}

function Reicht.Block.Keep(fn)
    Reicht.Block.Own[fn] = true
end

function Reicht.Block.Mute(rule)
    local muted = Reicht.Block.Muted[rule] or {}
    Reicht.Block.Muted[rule] = muted
    for _, signal in ipairs(rule.Signals) do
        for _, conn in ipairs(Util.GetConnections(signal)) do
            if conn.Enabled and not Reicht.Block.Own[conn.Function] then
                pcall(function() conn:Disable() end)
                muted[#muted + 1] = conn
            end
        end
    end
end

function Reicht.Block.Unmute(rule)
    local muted = Reicht.Block.Muted[rule]
    if not muted then return end
    for _, conn in ipairs(muted) do pcall(function() conn:Enable() end) end
    Reicht.Block.Muted[rule] = nil
end

function Reicht.Block.Step()
    Reicht.Block.SyncFall()
    if not Util.Can("Connections") then return end
    for _, rule in ipairs(Reicht.Block.Rules) do
        if Reicht.Options[rule.Option] then Reicht.Block.Mute(rule) else Reicht.Block.Unmute(rule) end
    end
end

function Reicht.Block.Release()
    Reicht.Block.SyncFall()
    for _, rule in ipairs(Reicht.Block.Rules) do Reicht.Block.Unmute(rule) end
end

---Fall hook lives only while No Fall is on; the original namecall goes back when it turns off or on unload.
function Reicht.Block.SyncFall()
    local wanted = Reicht.Options.NoFall and Reicht.State.Alive
    if wanted and not Reicht.Block.Restore then
        Reicht.Block.HookFall()
    elseif not wanted and Reicht.Block.Restore then
        local restore = Reicht.Block.Restore
        Reicht.Block.Restore = nil
        pcall(restore)
    end
end

function Reicht.Block.HookFall()
    local fall = GameLib.Remote.Fall
    if not (fall and Util.Can("Namecall")) then return end
    local original, restore
    original, restore = Util.HookMeta(game, "__namecall", function(self, ...)
        if self == fall and Reicht.Options.NoFall and Reicht.State.Alive and Util.NameCallMethod() == "FireServer" then return nil end
        return original(self, ...)
    end)
    Reicht.Block.Restore = restore
end

Reicht.Survivor = {
    Job = nil,
    Gen = nil,
    Banned = {},
    Map = nil,
    Status = "Off",
    RoundStart = 0,
    Escapes = 0,
    LastEscape = 0,
}

Reicht.Survivor.Rank = { Unhook = 3, Heal = 2, Repair = 1 }

---@param kind string    Repair / Heal / Unhook
---@param target Instance  point or teammate root the remote takes
function Reicht.Survivor.NewJob(kind, target, remote)
    return { Kind = kind, Target = target, Remote = remote, Since = osClock(), Fired = false, Progress = 0, Checked = osClock() }
end

function Reicht.Survivor.Finish()
    local job = Reicht.Survivor.Job
    Reicht.Survivor.Job = nil
    if not (job and job.Fired) or job.Kind == "Unhook" or not job.Target.Parent then return end
    pcall(function() job.Remote:FireServer(job.Target, false) end)
end

---@param locked boolean  action already started, only re-warp if we drifted far
function Reicht.Survivor.Hold(target, locked)
    local hrp = Reicht.Player.Root
    if not hrp then return end
    local teammate = target.Name == "HumanoidRootPart"
    local spot = teammate and (target.CFrame * cframeNew(0, 0, 2.5)).Position or target.Position
    local flat = vector3New(hrp.Position.X - spot.X, 0, hrp.Position.Z - spot.Z).Magnitude
    if flat <= (locked and Reicht.Config.DriftLimit or Reicht.Config.ArriveRadius) then return end
    local look = teammate and target.Position or spot + target.CFrame.LookVector
    Reicht.Player.Teleport(cframeLookAt(spot, look))
end

---@param scale number?  radius multiplier, larger when picking new work
---@return boolean        too close to the killer while Auto Dodge is on
function Reicht.Survivor.Danger(pos, scale)
    local opts = Reicht.Options
    if not opts.AutoDodge then return false end
    local killer = Reicht.Player.Killer()
    local root = killer and killer:FindFirstChild("HumanoidRootPart")
    return root ~= nil and (root.Position - pos).Magnitude <= opts.DodgeRadius * (scale or Reicht.Config.DangerKeep)
end

function Reicht.Survivor.GenUsable(gen)
    if not gen or not gen.Parent then return false end
    if Reicht.Map.GenProgress(gen) >= Reicht.Config.GenDone then return false end
    return osClock() >= (Reicht.Survivor.Banned[gen] or 0)
end

---@return BasePart?  a free, safe point on this generator
function Reicht.Survivor.PointOn(gen)
    local job = Reicht.Survivor.Job
    for _, point in ipairs(Reicht.Map.PointsOf(gen)) do
        local mine = job and job.Target == point
        if not mine and CollectionService:HasTag(point, "doing action") then continue end
        if Reicht.Survivor.Danger(point.Position, Reicht.Config.DangerPick) then continue end
        return point
    end
    return nil
end

---@param peek boolean?  don't change the committed generator
---@return BasePart?      keeps the committed generator until it is done or unsafe
function Reicht.Survivor.PickGenPoint(pos, peek)
    local gen = Reicht.Survivor.Gen
    local point = Reicht.Survivor.GenUsable(gen) and Reicht.Survivor.PointOn(gen)
    if point then return point end

    local best, bestScore = nil, mathHuge
    for _, candidate in ipairs(Reicht.Map.Generators()) do
        if not Reicht.Survivor.GenUsable(candidate) then continue end
        local spot = Reicht.Survivor.PointOn(candidate)
        if not spot then continue end
        local score = (Reicht.Config.GenDone - Reicht.Map.GenProgress(candidate)) + (spot.Position - pos).Magnitude * Reicht.Config.DistanceWeight
        if score < bestScore then best, bestScore = spot, score end
    end
    if not peek then Reicht.Survivor.Gen = best and best:FindFirstAncestor("Generator") end
    return best
end

---@param downedOnly boolean  only teammates who are on the floor
---@return BasePart?            closest teammate worth healing, downed first
function Reicht.Survivor.HealTarget(downedOnly)
    local me = Reicht.Player.Root
    local best, bestScore = nil, mathHuge
    for _, char in ipairs(Reicht.Player.Survivors()) do
        local hrp = char.HumanoidRootPart
        if hrp:GetAttribute("CanGetHealed") ~= true or char:GetAttribute("IsHooked") or char:GetAttribute("IsCarried") then continue end
        if char:GetAttribute("IsBeingHealed") or osClock() < (Reicht.Survivor.Banned[char] or 0) then continue end
        local downed = char:GetAttribute("Knocked") == true
        if downedOnly and not downed then continue end
        if Reicht.Survivor.Danger(hrp.Position, Reicht.Config.DangerPick) then continue end
        local score = (downed and 0 or 1000) + (me and (hrp.Position - me.Position).Magnitude or 0)
        if score < bestScore then best, bestScore = hrp, score end
    end
    return best
end

function Reicht.Survivor.UnhookTarget()
    local points = Reicht.Map.Tagged("UnhookPoint")
    for _, char in ipairs(Reicht.Player.Survivors()) do
        if char:GetAttribute("IsHooked") ~= true or osClock() < (Reicht.Survivor.Banned[char] or 0) then continue end
        local point, dist = Reicht.Map.Nearest(points, char.HumanoidRootPart.Position)
        if point and dist < Reicht.Config.UnhookReach and not Reicht.Survivor.Danger(point.Position, Reicht.Config.DangerPick) then
            return point, char
        end
    end
    return nil
end

---@return boolean  current job still has something to do
function Reicht.Survivor.JobAlive(job)
    local target = job.Target
    if not target.Parent or Reicht.Survivor.Danger(target.Position) then return false end
    local age = osClock() - job.Since
    if job.Kind == "Heal" then
        local ok = age <= Reicht.Config.HealMax and target:GetAttribute("CanGetHealed") == true
        if not ok and age < Reicht.Config.HealMinUseful then
            Reicht.Survivor.Banned[target.Parent] = osClock() + Reicht.Config.HelpBan
        end
        return ok
    end
    if job.Kind == "Unhook" then
        if age < Reicht.Config.UnhookHold then return true end
        if job.Char then Reicht.Survivor.Banned[job.Char] = osClock() + Reicht.Config.HelpBan end
        return false
    end
    return Reicht.Survivor.GenUsable(target:FindFirstAncestor("Generator")) and Reicht.Map.GensLeft() > 0
end

---@return table?  best new job, only if it should replace the current one
function Reicht.Survivor.Candidate(pos)
    local opts, remote = Reicht.Options, GameLib.Remote
    local job = Reicht.Survivor.Job
    local rank = job and Reicht.Survivor.Rank[job.Kind] or 0
    local finishing = job and job.Kind == "Repair"
        and Reicht.Map.GenProgress(job.Target:FindFirstAncestor("Generator")) >= Reicht.Config.FinishFirst

    if opts.AutoUnhook and rank < 3 and not finishing then
        local point, char = Reicht.Survivor.UnhookTarget()
        if point then
            local unhook = Reicht.Survivor.NewJob("Unhook", point, remote.Unhook)
            unhook.Char = char
            return unhook
        end
    end
    if opts.AutoHeal and rank < 2 and not finishing then
        local hrp = Reicht.Survivor.HealTarget(true)
        if hrp then return Reicht.Survivor.NewJob("Heal", hrp, remote.Heal) end
    end
    if job then return nil end
    if opts.AutoRepair and Reicht.Map.GensLeft() > 0 then
        local point = Reicht.Survivor.PickGenPoint(pos)
        if point then return Reicht.Survivor.NewJob("Repair", point, remote.Repair) end
    end
    if opts.AutoHeal then
        local hrp = Reicht.Survivor.HealTarget(false)
        if hrp then return Reicht.Survivor.NewJob("Heal", hrp, remote.Heal) end
    end
    return nil
end

function Reicht.Survivor.Watchdog(job)
    if job.Kind ~= "Repair" or osClock() - job.Checked < Reicht.Config.StallTime then return end
    local gen = job.Target:FindFirstAncestor("Generator")
    local progress = Reicht.Map.GenProgress(gen)
    job.Checked = osClock()
    if progress > job.Progress then
        job.Progress = progress
        return
    end
    Reicht.Survivor.Banned[gen] = osClock() + Reicht.Config.StallBan
    Reicht.Survivor.Gen = nil
    Reicht.Survivor.Finish()
end

function Reicht.Survivor.Run(job)
    Reicht.Survivor.Hold(job.Target, job.Fired and job.Kind ~= "Heal")
    if not job.Fired and osClock() - job.Since >= Reicht.Config.Settle then
        job.Fired = true
        job.Progress = job.Kind == "Repair" and Reicht.Map.GenProgress(job.Target:FindFirstAncestor("Generator")) or 0
        job.Checked = osClock()
        if job.Kind == "Unhook" then job.Remote:FireServer(job.Target) else job.Remote:FireServer(job.Target, true) end
    end
    if job.Fired then Reicht.Survivor.Watchdog(job) end
    Reicht.Survivor.Status = (job.Fired and job.Kind or "Moving to " .. job.Kind) .. " · gens left " .. Reicht.Map.GensLeft()
end

---@return BasePart?  walk-through floor of the finish line
function Reicht.Survivor.FinishLine()
    local hrp = Reicht.Player.Root
    if not hrp then return nil end
    return Reicht.Map.Nearest(Reicht.Map.Tagged("EscapePart"), hrp.Position, function(part)
        return not part.CanCollide
    end)
end

function Reicht.Survivor.EscapeNow()
    local line = Reicht.Survivor.FinishLine()
    if not line then return false end
    Reicht.Survivor.Finish()
    Reicht.Player.Teleport(line.CFrame + vector3New(0, 3, 0))
    local hrp = Reicht.Player.Root
    if Util.FireTouch and hrp then
        Util.FireTouch(hrp, line, 0)
        Util.FireTouch(hrp, line, 1)
    end
    return true
end

function Reicht.Survivor.Enabled()
    local opts = Reicht.Options
    return opts.AutoRepair or opts.AutoHeal or opts.AutoUnhook or opts.InstantEscape
end

---@return boolean  escaped this tick
function Reicht.Survivor.TryEscape()
    local opts = Reicht.Options
    local ready = opts.InstantEscape and (osClock() - Reicht.Survivor.RoundStart >= opts.EscapeDelay or Reicht.Map.GensLeft() == 0)
    if not ready then return false end
    if osClock() - Reicht.Survivor.LastEscape < Reicht.Config.EscapeRetry then return true end
    if not Reicht.Survivor.EscapeNow() then return false end
    Reicht.Survivor.LastEscape = osClock()
    Reicht.Survivor.Escapes += 1
    Reicht.Survivor.Status = "Escaped"
    return true
end

function Reicht.Survivor.Step()
    if not Reicht.Survivor.Enabled() then
        Reicht.Survivor.Finish()
        Reicht.Survivor.Status = "Off"
        return
    end
    local map = Reicht.Map.Root()
    if map ~= Reicht.Survivor.Map then
        Reicht.Survivor.Map = map
        Reicht.Survivor.RoundStart = osClock()
    end
    if not Reicht.State.Alive or Reicht.Player.Role() ~= "Survivors" or not Reicht.Player:IsAlive() then
        Reicht.Survivor.Gen = nil
        table.clear(Reicht.Survivor.Banned)
        Reicht.Survivor.Finish()
        Reicht.Survivor.Status = "Not a survivor"
        return
    end
    if Reicht.Player.Disabled(Reicht.Player.Character) then
        Reicht.Survivor.Finish()
        Reicht.Survivor.Status = "Downed / hooked"
        return
    end
    if Reicht.Survivor.TryEscape() then return end

    local job = Reicht.Survivor.Job
    if job and not Reicht.Survivor.JobAlive(job) then
        Reicht.Survivor.Finish()
        job = nil
    end
    local better = Reicht.Survivor.Candidate(Reicht.Player.Root.Position)
    if better then
        Reicht.Survivor.Finish()
        Reicht.Survivor.Job = better
        job = better
    end
    if not job then
        Reicht.Survivor.Status = "Waiting · gens left " .. Reicht.Map.GensLeft()
        return
    end
    Reicht.Survivor.Run(job)
end

Reicht.Guard = { Dodges = 0, LastUnhook = 0, UnhookTries = 0, LastDodge = 0 }

---@return BasePart?  free point on the unfinished generator farthest from the killer
function Reicht.Guard.SafeSpot(killerPos)
    local best, bestDist = nil, 0
    for _, gen in ipairs(Reicht.Map.Generators()) do
        if not Reicht.Survivor.GenUsable(gen) then continue end
        local point = Reicht.Survivor.PointOn(gen)
        local dist = point and (point.Position - killerPos).Magnitude or 0
        if dist > bestDist then best, bestDist = point, dist end
    end
    return best
end

function Reicht.Guard.Step()
    local opts = Reicht.Options
    if not (opts.AutoDodge or opts.AutoSelfUnhook) or not Reicht.State.Alive then return end
    if Reicht.Player.Role() ~= "Survivors" or not Reicht.Player:IsAlive() then return end
    local char, hrp = Reicht.Player.Character, Reicht.Player.Root

    if not char:GetAttribute("IsHooked") then Reicht.Guard.UnhookTries = 0 end
    if opts.AutoSelfUnhook and char:GetAttribute("IsHooked") and Reicht.Guard.UnhookTries < Reicht.Config.SelfUnhookMax
        and osClock() - Reicht.Guard.LastUnhook >= Reicht.Config.SelfUnhookRetry then
        Reicht.Guard.LastUnhook = osClock()
        Reicht.Guard.UnhookTries += 1
        GameLib.Remote.SelfUnhook:FireServer()
        return
    end
    if not opts.AutoDodge or Reicht.Player.Disabled(char) or osClock() - Reicht.Guard.LastDodge < Reicht.Config.DodgeCooldown then return end

    local killer = Reicht.Player.Killer()
    local root = killer and killer:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - hrp.Position).Magnitude > opts.DodgeRadius then return end
    local spot = Reicht.Guard.SafeSpot(root.Position)
    if not spot or (spot.Position - root.Position).Magnitude <= opts.DodgeRadius then return end
    Reicht.Guard.LastDodge = osClock()
    Reicht.Survivor.Finish()
    Reicht.Survivor.Gen = spot:FindFirstAncestor("Generator")
    Reicht.Player.Teleport(spot.CFrame + vector3New(0, 3, 0))
    Reicht.Guard.Dodges += 1
end

Reicht.Alert = { Near = false, Distance = nil }

function Reicht.Alert.Step()
    local hrp = Reicht.Player.Root
    local killer = Reicht.Player.Killer()
    local root = killer and killer:FindFirstChild("HumanoidRootPart")
    if not (hrp and root) or Reicht.Player.Role() ~= "Survivors" then
        Reicht.Alert.Near, Reicht.Alert.Distance = false, nil
        return
    end
    local dist = (root.Position - hrp.Position).Magnitude
    Reicht.Alert.Distance = dist
    local near = dist <= Reicht.Config.AlertRadius
    if near and not Reicht.Alert.Near and Reicht.Options.KillerAlert and Reicht.Library then
        Reicht.Library:Notify("Killer nearby", ("%d m away"):format(dist), 3, "Warning")
    end
    Reicht.Alert.Near = near
end

Reicht.SkillCheck = { Started = false, Checks = 0 }

function Reicht.SkillCheck.OnGen(point, checkId)
    if not Reicht.Options.PerfectSkillCheck then return end
    Reicht.SkillCheck.Checks += 1
    GameLib.Remote.GenResult:FireServer("success", 1, point, checkId)
end

function Reicht.SkillCheck.OnHeal(point)
    if not Reicht.Options.PerfectSkillCheck then return end
    Reicht.SkillCheck.Checks += 1
    GameLib.Remote.HealResult:FireServer("success", 1, point)
end

function Reicht.SkillCheck.Start()
    local remote = GameLib.Remote
    if Reicht.SkillCheck.Started or not (remote.GenCheck and remote.HealCheck and remote.GenResult and remote.HealResult) then return end
    Reicht.SkillCheck.Started = true
    Reicht.Block.Keep(Reicht.SkillCheck.OnGen)
    Reicht.Block.Keep(Reicht.SkillCheck.OnHeal)
    Reicht:Connect(remote.GenCheck.OnClientEvent, Reicht.SkillCheck.OnGen)
    Reicht:Connect(remote.HealCheck.OnClientEvent, Reicht.SkillCheck.OnHeal)
end

function Reicht.Survivor.Sacrifice()
    local hum = Reicht.Player.Humanoid
    if not hum or Reicht.Player.Role() ~= "Survivors" then return false end
    Reicht.Survivor.Finish()
    hum.Health = 0
    return true
end

Reicht.Parry = { Last = 0, Count = 0, Clients = setmetatable({}, { __mode = "k" }), Scanned = 0 }

function Reicht.Parry.Remote()
    return GameLib.FindRemote("Items", "Parrying Dagger", "parry")
end

function Reicht.Parry.Holding()
    return LocalPlayer:GetAttribute("EquippedItem") == "Parrying Dagger"
end

---@return boolean  killer is close and closing in fast
function Reicht.Parry.Threat()
    local hrp = Reicht.Player.Root
    local killer = Reicht.Player.Killer()
    local root = killer and killer:FindFirstChild("HumanoidRootPart")
    if not (hrp and root) then return false end
    local offset = hrp.Position - root.Position
    if offset.Magnitude > Reicht.Config.ParryRange then return false end
    local closing = root.AssemblyLinearVelocity:Dot(offset.Unit)
    return closing >= Reicht.Config.ParryClosing or offset.Magnitude <= Reicht.Config.ParryPanic
end

function Reicht.Parry.FindClients()
    if not Util.Can("Gc") or osClock() - Reicht.Parry.Scanned < Reicht.Config.ParryScan then return end
    Reicht.Parry.Scanned = osClock()
    for _, obj in ipairs(Util.GetGc(true)) do
        if type(obj) == "table" and rawget(obj, "isParryOnCooldown") ~= nil and rawget(obj, "parryEvent") then
            Reicht.Parry.Clients[obj] = true
        end
    end
end

function Reicht.Parry.ClearCooldowns()
    Reicht.Parry.FindClients()
    for client in pairs(Reicht.Parry.Clients) do
        client.isParryOnCooldown = false
        client.isParryResolving = false
        client.cooldownToken = (client.cooldownToken or 0) + 1
    end
end

function Reicht.Parry.Step()
    local opts = Reicht.Options
    if not (opts.AutoParry or opts.NoParryCooldown) or not Reicht.State.Alive then return end
    if Reicht.Player.Role() ~= "Survivors" or not Reicht.Parry.Holding() then return end
    if opts.NoParryCooldown then Reicht.Parry.ClearCooldowns() end
    if not opts.AutoParry or Reicht.Player.Disabled(Reicht.Player.Character) then return end

    local retry = opts.NoParryCooldown and Reicht.Config.ParryFast or Reicht.Config.ParryRetry
    if osClock() - Reicht.Parry.Last < retry or not Reicht.Parry.Threat() then return end
    local remote = Reicht.Parry.Remote()
    if not remote then return end
    Reicht.Parry.Last = osClock()
    Reicht.Parry.Count += 1
    remote:FireServer()
end

Reicht.Killer = { Status = "Off", LastSwing = 0, Hits = 0, Breaks = 0, Kicked = {} }

function Reicht.Killer.Behind(targetRoot)
    local pos = targetRoot.Position - targetRoot.CFrame.LookVector * Reicht.Config.AttackReach
    return cframeLookAt(pos, targetRoot.Position)
end

---@return Model?  nearest survivor matching state, inside range
function Reicht.Killer.Pick(knocked, range)
    local hrp = Reicht.Player.Root
    local best, bestDist = nil, range
    for _, char in ipairs(Reicht.Player.Survivors()) do
        if (char:GetAttribute("Knocked") == true) ~= knocked then continue end
        if char:GetAttribute("IsHooked") or char:GetAttribute("IsCarried") then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
        if dist < bestDist then best, bestDist = char, dist end
    end
    return best
end

function Reicht.Killer.Swing(target)
    local root = target.HumanoidRootPart
    local remote = GameLib.Remote
    local stop = osClock() + Reicht.Config.LungeDelay + Reicht.Config.SwingTail
    local fired = false
    remote.Lunge:FireServer()
    local start = osClock()
    while osClock() < stop and root.Parent and Reicht.State.Alive and Reicht.Options.KillAura do
        Reicht.Player.Teleport(Reicht.Killer.Behind(root))
        if not fired and osClock() - start >= Reicht.Config.LungeDelay then
            fired = true
            remote.Attack:FireServer()
        end
        RunService.Heartbeat:Wait()
    end
    if target:GetAttribute("Knocked") then Reicht.Killer.Hits += 1 end
end

---@return boolean  still allowed to act after a yield
function Reicht.Killer.Live(option, hrp)
    return Reicht.State.Alive and Reicht.Options[option] and Reicht.Player:IsAlive() and Reicht.Player.Root == hrp
end

function Reicht.Killer.Carry(target)
    local hrp = Reicht.Player.Root
    Reicht.Player.Teleport(Reicht.Killer.Behind(target.HumanoidRootPart))
    task.wait(Reicht.Config.Settle)
    if not Reicht.Killer.Live("AutoHook", hrp) or not target:GetAttribute("Knocked") then return end
    GameLib.Remote.Carry:FireServer(target)
    task.wait(Reicht.Config.CarryDelay)
end

---@param offset Vector3  where the game stands you relative to the point
---@return boolean  false if the action was abandoned
function Reicht.Killer.Commit(option, point, offset, remote, commit)
    local hrp = Reicht.Player.Root
    if not hrp then return false end
    local seat = point.CFrame * cframeNew(offset)
    Reicht.Player.Teleport(seat * cframeNew(0, 0, 3))
    task.wait(Reicht.Config.Settle)
    if not Reicht.Killer.Live(option, hrp) then return false end
    remote:FireServer(point)
    local tween = TweenService:Create(hrp, TweenInfo.new(Reicht.Config.HookTween), { CFrame = seat })
    tween:Play()
    tween.Completed:Wait()
    if not Reicht.Killer.Live(option, hrp) then return false end
    commit:FireServer(point)
    return true
end

function Reicht.Killer.Hook()
    local hrp = Reicht.Player.Root
    local point = hrp and Reicht.Map.Nearest(Reicht.Map.Tagged("HookPoint"), hrp.Position)
    if not point then return end
    if Reicht.Killer.Commit("AutoHook", point, vector3New(0, 0.6, 0), GameLib.Remote.Hook, GameLib.Remote.HookCommit) then
        task.wait(Reicht.Config.HookRest)
    end
end

---@return BasePart?  point on the most-repaired unfinished generator
function Reicht.Killer.GenToBreak()
    local best, bestProgress = nil, 0
    for _, point in ipairs(Reicht.Map.Tagged("GeneratorPoint")) do
        local gen = point:FindFirstAncestor("Generator")
        local progress = gen and Reicht.Map.GenProgress(gen) or 0
        local fresh = gen and osClock() - (Reicht.Killer.Kicked[gen] or 0) > Reicht.Config.KickRegress
        if fresh and progress > bestProgress and progress < Reicht.Config.GenDone then
            best, bestProgress = point, progress
        end
    end
    return best
end

function Reicht.Killer.BreakGen(point)
    if not Reicht.Killer.Commit("AutoBreakGens", point, vector3New(0, 0, 1), GameLib.Remote.BreakGen, GameLib.Remote.BreakGenCommit) then return end
    task.wait(Reicht.Config.GenBreakTime)
    Reicht.Killer.Kicked[point:FindFirstAncestor("Generator")] = osClock()
    Reicht.Killer.Breaks += 1
end

Reicht.AntiStun = { Count = 0 }

function Reicht.AntiStun.OnStun()
    if not Reicht.Options.AntiStun or Reicht.Player.Role() ~= "Killer" then return end
    Reicht.AntiStun.Count += 1
    GameLib.Remote.StunOver:FireServer()
end

function Reicht.AntiStun.Start()
    if not (GameLib.Remote.Stun and GameLib.Remote.StunOver) then return end
    Reicht.Block.Keep(Reicht.AntiStun.OnStun)
    Reicht:Connect(GameLib.Remote.Stun.OnClientEvent, Reicht.AntiStun.OnStun)
end

---@return Model?  survivor right in front of us inside lunge reach
function Reicht.Killer.InFront()
    local hrp = Reicht.Player.Root
    local look = hrp.CFrame.LookVector
    for _, char in ipairs(Reicht.Player.Survivors()) do
        if char:GetAttribute("Knocked") or char:GetAttribute("IsHooked") or char:GetAttribute("IsCarried") then continue end
        local offset = char.HumanoidRootPart.Position - hrp.Position
        if offset.Magnitude <= Reicht.Config.LegitReach and look:Dot(offset.Unit) >= Reicht.Config.LegitAngle then return char end
    end
    return nil
end

---@param target Model  survivor in front; closed in on when Smart Hitbox is on
function Reicht.Killer.LegitSwing(target)
    local remote = GameLib.Remote
    local root = target.HumanoidRootPart
    local function Close()
        local hrp = Reicht.Player.Root
        if not (Reicht.Options.SmartHitbox and hrp and root.Parent) then return end
        local offset = root.Position - hrp.Position
        if offset.Magnitude <= Reicht.Config.ServerReach then return end
        local spot = root.Position - offset.Unit * Reicht.Config.AttackReach
        Reicht.Player.Teleport(cframeLookAt(vector3New(spot.X, hrp.Position.Y, spot.Z), vector3New(root.Position.X, hrp.Position.Y, root.Position.Z)))
    end
    Close()
    remote.Lunge:FireServer()
    task.wait(Reicht.Config.LungeDelay)
    Close()
    remote.Attack:FireServer()
end

function Reicht.Killer.Enabled()
    local opts = Reicht.Options
    return opts.KillAura or opts.AutoHook or opts.AutoBreakGens
end

function Reicht.Killer.Step()
    if not Reicht.Killer.Enabled() then
        Reicht.Killer.Status = "Off"
        return
    end
    if not Reicht.State.Alive or Reicht.Player.Role() ~= "Killer" or not Reicht.Player:IsAlive() then
        Reicht.Killer.Status = "Not the killer"
        return
    end
    local char, opts = Reicht.Player.Character, Reicht.Options

    if char:GetAttribute("CarriedSurvivorId") then
        if opts.AutoHook then Reicht.Killer.Hook() end
        Reicht.Killer.Status = "Carrying"
        return
    end

    if opts.AutoHook then
        local downed = Reicht.Killer.Pick(true, opts.AuraRange)
        if downed then
            Reicht.Killer.Status = "Picking up " .. downed.Name
            Reicht.Killer.Carry(downed)
            return
        end
    end

    if opts.KillAura and GameLib.Remote.Lunge and GameLib.Remote.Attack and osClock() - Reicht.Killer.LastSwing >= Reicht.Config.AuraCooldown then
        local legit = opts.SlashMode == "Legit"
        local target = legit and Reicht.Killer.InFront() or not legit and Reicht.Killer.Pick(false, opts.AuraRange)
        if target then
            Reicht.Killer.LastSwing = osClock()
            Reicht.Killer.Status = "Hitting " .. target.Name
            if legit then Reicht.Killer.LegitSwing(target) else Reicht.Killer.Swing(target) end
            return
        end
    end
    if opts.AutoBreakGens then
        local point = Reicht.Killer.GenToBreak()
        if point then
            Reicht.Killer.Status = "Breaking generator"
            Reicht.Killer.BreakGen(point)
            return
        end
    end
    Reicht.Killer.Status = ("Hunting · downs %d · gens kicked %d"):format(Reicht.Killer.Hits, Reicht.Killer.Breaks)
end

Reicht.Teleport = {}

function Reicht.Teleport.Places()
    local names = { "Nearest Generator", "Best Generator", "Exit Gate", "Nearest Hook", "Killer", "Farthest From Killer" }
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then names[#names + 1] = player.Name end
    end
    return names
end

---@return CFrame?  stand spot for a teleport choice
function Reicht.Teleport.Resolve(choice)
    local hrp = Reicht.Player.Root
    if not hrp then return nil end
    local pos = hrp.Position
    local function At(part) return part and part.CFrame + vector3New(0, 3, 0) end

    if choice == "Nearest Generator" then
        return At(Reicht.Map.Nearest(Reicht.Map.Tagged("GeneratorPoint"), pos, function(point)
            local gen = point:FindFirstAncestor("Generator")
            return gen and Reicht.Map.GenProgress(gen) < Reicht.Config.GenDone
        end))
    elseif choice == "Best Generator" then
        return At(Reicht.Survivor.PickGenPoint(pos, true))
    elseif choice == "Exit Gate" then
        local gate = Reicht.Map.Models("Gate")[1]
        local part = gate and (gate:FindFirstChild("ExitLever", true) or gate:FindFirstChildWhichIsA("BasePart", true))
        return part and (part:IsA("Model") and part:GetPivot() or part.CFrame) + vector3New(0, 3, 0)
    elseif choice == "Nearest Hook" then
        return At(Reicht.Map.Nearest(Reicht.Map.Tagged("HookPoint"), pos))
    elseif choice == "Killer" then
        local killer = Reicht.Player.Killer()
        return killer and At(killer:FindFirstChild("HumanoidRootPart"))
    elseif choice == "Farthest From Killer" then
        local killer = Reicht.Player.Killer()
        local root = killer and killer:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local best, bestDist = nil, 0
        for _, point in ipairs(Reicht.Map.Tagged("GeneratorPoint")) do
            local dist = (point.Position - root.Position).Magnitude
            if dist > bestDist then best, bestDist = point, dist end
        end
        return At(best)
    end
    local player = Players:FindFirstChild(choice)
    return player and player.Character and At(player.Character:FindFirstChild("HumanoidRootPart"))
end

function Reicht.Teleport.Go(choice)
    local cframe = Reicht.Teleport.Resolve(choice)
    if not cframe then return false end
    Reicht.Player.Teleport(cframe)
    return true
end

Reicht.Esp = { Count = 0, Marks = {}, Folder = nil }

---@return table[]  players in the shape Library.Visuals expects
function Reicht.Esp.Targets()
    local list = {}
    local mine = Reicht.Player.Role()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local role = Reicht.Player.Role(player)
        if player == LocalPlayer or not char or (role ~= "Survivors" and role ~= "Killer") then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local tag = role == "Killer" and "KILLER" or char:GetAttribute("IsHooked") and "Hooked"
            or char:GetAttribute("Knocked") and "Downed" or nil
        list[#list + 1] = {
            Model = char,
            Name = tag and (player.DisplayName .. " [" .. tag .. "]") or player.DisplayName,
            Health = hum.Health,
            MaxHealth = hum.MaxHealth > 0 and hum.MaxHealth or 100,
            Friendly = mine == role,
            Root = char:FindFirstChild("HumanoidRootPart"),
        }
    end
    Reicht.Esp.Count = #list
    return list
end

Reicht.Esp.Kinds = {
    { Option = "EspGenerators", Glow = true, Color = Color3.fromRGB(255, 196, 64), Find = Reicht.Map.Generators, Label = function(model)
        local progress = Reicht.Map.GenProgress(model)
        if progress >= Reicht.Config.GenDone then return "Gen DONE" end
        return ("Gen %d%%"):format(progress)
    end },
    { Option = "EspHooks", Glow = true, Color = Color3.fromRGB(235, 70, 70), Find = function()
        local list = {}
        for _, point in ipairs(Reicht.Map.Tagged("HookPoint")) do list[#list + 1] = point.Parent end
        return list
    end, Label = function() return "Hook" end },
    { Option = "EspGates", Glow = true, Color = Color3.fromRGB(90, 220, 120), Find = function() return Reicht.Map.Models("Gate") end, Label = function() return "Exit Gate" end },
    { Option = "EspPallets", Color = Color3.fromRGB(200, 150, 90), Find = function()
        local list = {}
        for _, point in ipairs(Reicht.Map.Tagged("PalletPoint")) do list[#list + 1] = point.Parent end
        return list
    end, Label = function() return "Pallet" end },
    { Option = "EspWindows", Color = Color3.fromRGB(110, 170, 255), Find = function()
        local list = {}
        for _, point in ipairs(Reicht.Map.Tagged("VaultPoint")) do
            local model = point.Parent
            if model and model.Name == "Window" and not table.find(list, model) then list[#list + 1] = model end
        end
        return list
    end, Label = function() return "Window" end },
}

function Reicht.Esp.Holder()
    local folder = Reicht.Esp.Folder
    if folder and folder.Parent then return folder end
    folder = Instance.new("Folder")
    folder.Name = "MarioObjectEsp"
    Util.Mount(folder)
    Reicht.Esp.Folder = folder
    return folder
end

function Reicht.Esp.Make(model, kind)
    local holder = Reicht.Esp.Holder()
    local light
    if kind.Glow then
        light = Instance.new("Highlight")
        light.Adornee = model
        light.FillColor = kind.Color
        light.FillTransparency = 0.75
        light.OutlineColor = kind.Color
        light.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        light.Parent = holder
    end

    local board = Instance.new("BillboardGui")
    board.Adornee = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or model
    board.Size = UDim2.fromOffset(120, 22)
    board.StudsOffset = vector3New(0, 3, 0)
    board.AlwaysOnTop = true
    board.Parent = holder

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 13
    text.TextColor3 = kind.Color
    text.TextStrokeTransparency = 0.3
    text.Parent = board
    return { Light = light, Board = board, Text = text }
end

function Reicht.Esp.Drop(model)
    local mark = Reicht.Esp.Marks[model]
    if not mark then return end
    if mark.Light then mark.Light:Destroy() end
    mark.Board:Destroy()
    Reicht.Esp.Marks[model] = nil
end

function Reicht.Esp.Step()
    local map = Reicht.Map.Root()
    local seen = {}
    local hrp = Reicht.Player.Root
    if map then
        for _, kind in ipairs(Reicht.Esp.Kinds) do
            if not Reicht.Options[kind.Option] then continue end
            for _, model in ipairs(kind.Find()) do
                seen[model] = true
                local mark = Reicht.Esp.Marks[model] or Reicht.Esp.Make(model, kind)
                Reicht.Esp.Marks[model] = mark
                local label = kind.Label(model)
                local part = mark.Board.Adornee
                if hrp and part then label ..= (" · %dm"):format((part.Position - hrp.Position).Magnitude) end
                mark.Text.Text = label
            end
        end
    end
    for model in pairs(Reicht.Esp.Marks) do
        if not seen[model] or not model.Parent then Reicht.Esp.Drop(model) end
    end
end

function Reicht.Esp.Clear()
    for model in pairs(Reicht.Esp.Marks) do Reicht.Esp.Drop(model) end
    if Reicht.Esp.Folder then Reicht.Esp.Folder:Destroy() end
    Reicht.Esp.Folder = nil
end

function Reicht.Esp.GetStatus()
    local visuals = Reicht.Library and Reicht.Library.Visuals
    local players = visuals and visuals:Get("Enabled") and (Reicht.Esp.Count .. " players") or "players off"
    local objects = 0
    for _ in pairs(Reicht.Esp.Marks) do objects += 1 end
    return players .. " · " .. objects .. " objects"
end

Reicht.Shop = { Status = "Off", Maxed = {}, Owned = {}, LevelCost = {}, Bought = 0, Leveled = 0, Busy = false, LastWallet = nil }

function Reicht.Shop.Remote(name)
    return GameLib.FindRemote("Shop", name)
end

---@return string[]  folder names under ReplicatedStorage.<folder>, dev entries skipped
function Reicht.Shop.Names(folder)
    local list = {}
    local root = ReplicatedStorage:FindFirstChild(folder)
    for _, child in ipairs(root and root:GetChildren() or {}) do
        if not child.Name:find("^!") then list[#list + 1] = child.Name end
    end
    table.sort(list)
    return list
end

function Reicht.Shop.Wallet()
    return tonumber(LocalPlayer:GetAttribute("Screws")) or 0, tonumber(LocalPlayer:GetAttribute("Gears")) or 0
end

---@return table?  { owned, level, price } from the server
function Reicht.Shop.Info(getter, name)
    local remote = Reicht.Shop.Remote(getter)
    if not remote then return nil end
    local ok, info = pcall(remote.InvokeServer, remote, name)
    return ok and type(info) == "table" and info or nil
end

---@return any  whatever fn returns, nil while another shop run is active
function Reicht.Shop.Locked(fn, ...)
    if Reicht.Shop.Busy then return 0 end
    Reicht.Shop.Busy = true
    local ok, got = pcall(fn, ...)
    Reicht.Shop.Busy = false
    if not ok then
        warn("[ViolenceDistrict] shop: " .. tostring(got))
        return 0
    end
    return got
end

function Reicht.Shop.BuyPerks()
    local buy = Reicht.Shop.Remote("PurchasePerk")
    if not buy then return 0 end
    local count = 0
    local _, gears = Reicht.Shop.Wallet()
    for _, name in ipairs(Reicht.Shop.Names("Perks")) do
        if not Reicht.State.Alive then break end
        if Reicht.Shop.Owned[name] then continue end
        local info = Reicht.Shop.Info("GetPerkInfo", name)
        if info and info.owned then Reicht.Shop.Owned[name] = true end
        if not info or info.owned or gears < (info.price or mathHuge) then continue end
        buy:FireServer(name)
        gears -= info.price
        count += 1
        task.wait(Reicht.Config.ShopDelay)
    end
    Reicht.Shop.Bought += count
    return count
end

function Reicht.Shop.LevelPerks()
    local level = Reicht.Shop.Remote("LevelUpPerk")
    if not level then return 0 end
    local count = 0
    for _, name in ipairs(Reicht.Shop.Names("Perks")) do
        if Reicht.Shop.Maxed[name] then continue end
        local screws = Reicht.Shop.Wallet()
        local before = Reicht.Shop.Info("GetPerkInfo", name)
        if not before or not before.owned then continue end
        if not Reicht.State.Alive then break end
        local cost = Reicht.Shop.LevelCost[name] or Reicht.Shop.MaxCost()
        if screws - cost < Reicht.Options.KeepScrews then continue end
        level:FireServer(name)
        task.wait(Reicht.Config.ShopDelay)
        local after = Reicht.Shop.Info("GetPerkInfo", name)
        local spent = screws - Reicht.Shop.Wallet()
        if after and after.level ~= before.level then
            Reicht.Shop.LevelCost[name] = math.max(spent, cost or 0)
            count += 1
        elseif spent == 0 and cost and screws > cost * 2 then
            Reicht.Shop.Maxed[name] = true
        end
    end
    Reicht.Shop.Leveled += count
    return count
end

---@param kind string  "Item" or "Killer"
function Reicht.Shop.BuyList(kind, names)
    local buy = Reicht.Shop.Remote("Purchase" .. kind)
    if not buy then return 0 end
    local count = 0
    for key, picked in pairs(names or {}) do
        local name = type(key) == "number" and picked or key
        if not picked or type(name) ~= "string" then continue end
        local owned
        if kind == "Killer" then
            local check = Reicht.Shop.Remote("CheckKillerOwnership")
            local ok, got = pcall(function() return check and check:InvokeServer(name) end)
            owned = ok and got == true
        else
            local info = Reicht.Shop.Info("GetItemInfo", name)
            owned = info and info.owned
        end
        local price = kind == "Killer" and Reicht.Shop.KillerPrice(name) or (Reicht.Shop.Info("GetItemInfo", name) or {}).price
        if owned or not price or Reicht.Shop.Wallet() - price < Reicht.Options.KeepScrews then continue end
        buy:FireServer(name)
        count += 1
        task.wait(Reicht.Config.ShopDelay)
    end
    return count
end

---@return number  highest level-up cost seen so far, a safe guess for unknown perks
function Reicht.Shop.MaxCost()
    local most = Reicht.Config.FirstLevelCost
    for _, cost in pairs(Reicht.Shop.LevelCost) do most = math.max(most, cost) end
    return most
end

function Reicht.Shop.KillerPrice(name)
    local remote = Reicht.Shop.Remote("GetKillerPrice")
    local ok, price = pcall(function() return remote and remote:InvokeServer(name) end)
    return ok and tonumber(price) or nil
end

function Reicht.Shop.Step()
    local opts = Reicht.Options
    if not (opts.AutoBuyPerks or opts.AutoLevelPerks) then
        Reicht.Shop.Status = "Off"
        Reicht.Shop.LastWallet = nil
        return
    end
    local wallet = table.concat({ Reicht.Shop.Wallet() }, "/")
    if wallet == Reicht.Shop.LastWallet then return end
    Reicht.Shop.LastWallet = wallet
    if opts.AutoBuyPerks then Reicht.Shop.Locked(Reicht.Shop.BuyPerks) end
    if opts.AutoLevelPerks then Reicht.Shop.Locked(Reicht.Shop.LevelPerks) end
    local screws, gears = Reicht.Shop.Wallet()
    Reicht.Shop.Status = ("bought %d · leveled %d · %d screws · %d gears"):format(Reicht.Shop.Bought, Reicht.Shop.Leveled, screws, gears)
end

Reicht.UI = { Labels = {}, FarmSaved = nil }
local Library, T

function Reicht.UI.Detach(fn)
    return function(...)
        local packed = table.pack(...)
        task.defer(function()
            local ok, err = pcall(fn, table.unpack(packed, 1, packed.n))
            if not ok then warn("[ViolenceDistrict] ui: " .. tostring(err)) end
        end)
    end
end

---@return table  list read from the game, empty when reading failed
function Reicht.UI.List(read, ...)
    local ok, list = pcall(read, ...)
    return ok and type(list) == "table" and list or {}
end

---@param allow    fun(value: any): boolean
---@param refusal  table  { title, message, value the widget snaps back to }
function Reicht.UI.Guard(widget, allow, refusal)
    local function Refuse()
        Library:Notify(refusal[1], refusal[2], 4, "Warning")
        task.defer(widget.SetValue, widget, refusal[3])
    end

    if type(widget.AddGuard) == "function" then
        widget:AddGuard(function(value)
            if allow(value) then return true end
            Refuse()
            return false
        end)
        return widget
    end

    widget:OnChanged(function(value)
        if not allow(value) then Refuse() end
    end)
    return widget
end

---@param cap string|string[]  needed before the toggle may turn on
function Reicht.UI.NeedCap(idx, cap)
    if Library.Compat then
        Library.Compat.NeedCap(idx, cap)
        return
    end
    local toggle = Library.Toggles[idx]
    if not toggle then return end
    local title = toggle.Info and toggle.Info.Text or "Reicht"
    Reicht.UI.Guard(toggle, function(value)
        return value ~= true or Util.Can(cap)
    end, { title, T("Not supported on this executor", "ใช้กับ executor นี้ไม่ได้"), false })
end

---@param role table  RoleMode widget, kept on "Any" when the executor cannot press the game's button
function Reicht.UI.GuardRole(role)
    return Reicht.UI.Guard(role, function(value)
        return value == "Any" or Reicht.Role.Supported()
    end, { "Reicht", T("Role choice is not supported on this executor", "เลือกบทบาทใช้กับ executor นี้ไม่ได้"), "Any" })
end

---@param widget table  option whose value mirrors an Options key
function Reicht.UI.Bind(widget, key)
    Reicht.Options[key] = widget.Value
    widget:OnChanged(function(value) Reicht.Options[key] = value end)
    return widget
end

function Reicht.UI.BuildMain(window)
    window:AddTabSection(T("Main", "หลัก"))
    local tab = window:AddTab(T("Main", "หลัก"), "mushroom", T("Status and links", "สถานะและลิงก์"))

    local farm = tab:AddLeftGroupbox(T("Auto Farm", "ฟาร์มอัตโนมัติ"), "star")
    farm:AddToggle("AutoFarm", { Text = T("Auto Farm", "ฟาร์มอัตโนมัติ"), Description = T("Plays both roles for you: repairs, escapes, hunts and hooks", "เล่นให้ทั้งสองฝั่ง ซ่อม หนี ล่า แขวน"), Risky = true, Callback = Reicht.UI.Detach(Reicht.UI.SetFarm) }):AddKeyPicker("AutoFarmKey", { Default = "None", Mode = "Toggle" })
    Reicht.UI.GuardRole(farm:AddDropdown("RoleMode", { Text = T("Role", "บทบาท"), Description = T("Survivor only never gets killer; Prefer killer keeps you in the killer pool", "Survivor only ไม่ถูกสุ่มเป็นฆาตกร / Prefer killer อยู่ในกลุ่มสุ่มฆาตกรเสมอ"), Values = { "Any", "Survivor only", "Prefer killer" }, Default = "Any" }))
    farm:AddSlider("FarmEscapeAfter", { Text = T("Survivor: escape after", "ผู้รอด: หนีหลัง"), Description = T("0 = never escape, stay and farm the whole round", "0 = ไม่หนี อยู่ฟาร์มจนจบรอบ"), Min = 0, Max = 900, Default = 0, Suffix = "s" })

    local status = tab:AddLeftGroupbox(T("Round", "รอบนี้"), "star")
    local labels = Reicht.UI.Labels
    labels.Role = status:AddParagraph({ Title = T("Role", "บทบาท"), Content = "-" })
    labels.Survivor = status:AddParagraph({ Title = T("Survivor", "ผู้รอดชีวิต"), Content = "-" })
    labels.Killer = status:AddParagraph({ Title = T("Killer", "ฆาตกร"), Content = "-" })

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

    local panic = tab:AddRightGroupbox(T("Quick", "ด่วน"), "bomb")
    panic:AddButton({ Text = T("Panic — all off", "ฉุกเฉิน ปิดทั้งหมด"), Style = "Danger", Func = Reicht.UI.Detach(function()
        Reicht.UI.FarmSaved = nil
        for _, toggle in pairs(Library.Toggles) do
            if toggle.Value == true then toggle:SetValue(false) end
        end
    end) })

    local activity = tab:AddRightGroupbox(T("Activity", "กิจกรรม"), "eye")
    labels.Esp = activity:AddParagraph({ Title = T("ESP", "ESP"), Content = "-" })
    labels.Shop = activity:AddParagraph({ Title = T("Shop", "ร้านค้า"), Content = "-" })
end

Reicht.UI.FarmKeys = {
    "AutoRepair", "PerfectSkillCheck", "AutoHeal", "AutoUnhook", "AutoDodge", "AutoSelfUnhook", "InstantEscape", "NoSlow",
    "KillAura", "AutoHook", "AutoBreakGens", "AntiStun", "AntiAfk",
}

function Reicht.UI.SetFarm(on)
    local options = Library.Options
    local tuned = { EscapeDelay = options.FarmEscapeAfter.Value, DodgeRadius = Reicht.Config.FarmDodge }
    if on then
        if Reicht.UI.FarmSaved then return end
        Reicht.UI.FarmSaved = {}
        for key in pairs(tuned) do Reicht.UI.FarmSaved[key] = options[key].Value end
        for _, key in ipairs(Reicht.UI.FarmKeys) do Reicht.UI.FarmSaved[key] = options[key].Value end
        for key, value in pairs(tuned) do options[key]:SetValue(value) end
        for _, key in ipairs(Reicht.UI.FarmKeys) do options[key]:SetValue(true) end
        if options.FarmEscapeAfter.Value <= 0 then options.InstantEscape:SetValue(false) end
        return
    end
    local saved = Reicht.UI.FarmSaved
    Reicht.UI.FarmSaved = nil
    if not saved then return end
    for key, value in pairs(saved) do
        if options[key] then options[key]:SetValue(value) end
    end
end

function Reicht.UI.BuildSurvivor(window)
    window:AddTabSection(T("Roles", "บทบาท"))
    local tab = window:AddTab(T("Survivor", "ผู้รอดชีวิต"), "heart", T("Generators, team and escape", "เครื่องปั่นไฟ ทีม และการหนี"))

    local work = tab:AddLeftGroupbox(T("Objectives", "ภารกิจ"), "gear")
    work:AddToggle("AutoRepair", { Text = T("Auto repair", "ซ่อมอัตโนมัติ"), Description = T("Repairs the best generator hands-free", "ซ่อมเครื่องที่ดีที่สุดให้เอง"), Risky = true })
    work:AddToggle("PerfectSkillCheck", { Text = T("Auto Skill Check", "สกิลเช็คอัตโนมัติ") })
    work:AddToggle("AutoHeal", { Text = T("Auto heal teammates", "รักษาเพื่อนอัตโนมัติ"), Risky = true })
    work:AddToggle("AutoUnhook", { Text = T("Auto unhook teammates", "ปลดเพื่อนจากตะขอ"), Risky = true })

    local escape = tab:AddLeftGroupbox(T("Escape", "หนี"), "flag")
    escape:AddToggle("InstantEscape", { Text = T("Instant escape", "หนีออกทันที"), Description = T("Leaves the round without repairing anything", "ออกจากรอบโดยไม่ต้องซ่อม"), Risky = true })
    escape:AddSlider("EscapeDelay", { Text = T("Escape after", "หนีหลังเริ่มรอบ"), Min = 0, Max = 900, Default = 0, Suffix = "s" })
    escape:AddButton({ Text = T("Escape Now", "หนีออกตอนนี้"), Style = "Warning", Func = Reicht.UI.Detach(function()
        if not Reicht.Survivor.EscapeNow() then
            Library:Notify(T("Escape", "หนี"), T("No exit found this round", "ไม่พบทางออกในรอบนี้"), 3, "Warning")
        end
    end) })

    local safety = tab:AddRightGroupbox(T("Safety", "ความปลอดภัย"), "boo")
    safety:AddToggle("AutoDodge", { Text = T("Auto dodge killer", "หลบฆาตกรอัตโนมัติ"), Description = T("Teleports away when the killer gets close and keeps other jobs away from him", "วาร์ปหนีเมื่อฆาตกรเข้าใกล้ และไม่ไปทำงานใกล้ฆาตกร"), Risky = true })
    safety:AddSlider("DodgeRadius", { Text = T("Dodge distance", "ระยะหลบ"), Min = 6, Max = 40, Default = 20, Suffix = "m" })
    safety:AddToggle("AutoSelfUnhook", { Text = T("Auto self-unhook", "ปลดตัวเองจากตะขอ"), Risky = true })
    safety:AddToggle("AutoParry", { Text = T("Auto parry (beta)", "ปัดป้องอัตโนมัติ (beta)"), Description = T("Needs the Parrying Dagger equipped", "ต้องใส่ Parrying Dagger") })
    safety:AddToggle("NoParryCooldown", { Text = T("No parry cooldown (beta)", "ปัดป้องไม่มีคูลดาวน์ (beta)") })
    Reicht.UI.NeedCap("NoParryCooldown", "Gc")
    safety:AddToggle("KillerAlert", { Text = T("Killer alert", "เตือนฆาตกรเข้าใกล้") })
    safety:AddButton({ Text = T("Sacrifice Self", "สละชีพตัวเอง"), Style = "Danger", Func = Reicht.UI.Detach(function()
        if not Reicht.Survivor.Sacrifice() then
            Library:Notify(T("Sacrifice", "สละชีพ"), T("Only works as a survivor", "ใช้ได้ตอนเป็นผู้รอดเท่านั้น"), 3, "Warning")
        end
    end) })
end

function Reicht.UI.BuildKiller(window)
    local tab = window:AddTab(T("Killer", "ฆาตกร"), "swords", T("Hunting and hooking", "ล่าและแขวน"))

    local hunt = tab:AddLeftGroupbox(T("Hunt", "ล่า"), "target")
    hunt:AddToggle("KillAura", { Text = T("Auto slash", "ฟันอัตโนมัติ"), Description = T("Rage jumps behind anyone in range, Legit only swings at whoever is in front of you", "Rage วาร์ปไปฟันทุกคนในระยะ / Legit ฟันเฉพาะคนตรงหน้า"), Risky = true }):AddKeyPicker("KillAuraKey", { Default = "None", Mode = "Toggle" })
    hunt:AddToggle("SmartHitbox", { Text = T("Reach Assist", "ช่วยเพิ่มระยะฟัน"), Description = T("Legit swings still land on targets a few studs out of reach", "โหมด Legit ฟันโดนแม้เป้าอยู่เกินระยะนิดหน่อย"), Risky = true })
    hunt:AddDropdown("SlashMode", { Text = T("Slash mode", "โหมดฟัน"), Values = { "Rage", "Legit" }, Default = "Rage" })
    hunt:AddSlider("AuraRange", { Text = T("Range", "ระยะ"), Min = 10, Max = 500, Default = 500, Suffix = "m" })

    local chores = tab:AddRightGroupbox(T("Hooks & Generators", "ตะขอและเครื่องปั่นไฟ"), "gear")
    chores:AddToggle("AutoHook", { Text = T("Auto carry + hook", "แบกและแขวนอัตโนมัติ"), Description = T("Picks up anyone downed and hooks them", "แบกคนล้มแล้วแขวนตะขอให้"), Risky = true })
    chores:AddToggle("AutoBreakGens", { Text = T("Auto kick generators", "เตะเครื่องปั่นไฟอัตโนมัติ"), Description = T("Kicks the most repaired generator when nobody is in range", "เตะเครื่องที่ซ่อมไปเยอะสุดตอนไม่มีเป้า"), Risky = true })

    local defense = tab:AddRightGroupbox(T("Defense", "ป้องกัน"), "shield")
    defense:AddToggle("AntiStun", { Text = T("Anti pallet stun (beta)", "กันพาเลทสตัน (beta)") })
    Reicht.UI.NeedCap("AntiStun", "Connections")
    defense:AddToggle("AntiBlind", { Text = T("Anti blind (beta)", "กันแสงไฟฉาย (beta)"), Description = T("Flashlights no longer blind you", "ไม่โดนไฟฉายแยงตา") })
    Reicht.UI.NeedCap("AntiBlind", "Connections")
    defense:AddToggle("FreeTurn", { Text = T("No turn limit", "หมุนตัวได้อิสระ"), Description = T("Keep turning while attacking or lunging", "หันตัวได้ตอนฟันและพุ่ง") })
end

function Reicht.UI.BuildPlayer(window)
    window:AddTabSection(T("Player", "ผู้เล่น"))
    local tab = window:AddTab(T("Player", "ผู้เล่น"), "player", T("Movement, world and teleport", "การเคลื่อนที่ โลก และวาร์ป"))

    local move = tab:AddLeftGroupbox(T("Movement", "การเคลื่อนที่"), "zap")
    move:AddToggle("Speed", { Text = T("Speed", "วิ่งเร็ว"), Risky = true }):AddKeyPicker("SpeedKey", { Default = "None", Mode = "Toggle" })
    move:AddSlider("SpeedValue", { Text = T("Walk speed", "ความเร็ว"), Min = 16, Max = 60, Default = 24 })
    move:AddToggle("NoSlow", { Text = T("No slow", "ไม่โดนสโลว์"), Description = T("Never drops below your normal run speed", "ความเร็วไม่ต่ำกว่าวิ่งปกติ") })
    move:AddToggle("NoFall", { Text = T("No fall (beta)", "ไม่เซตอนตก (beta)"), Description = T("No landing stumble after a drop", "ลงพื้นแล้วไม่เซ") })
    Reicht.UI.NeedCap("NoFall", "Namecall")
    move:AddToggle("Noclip", { Text = T("Noclip", "เดินทะลุ") }):AddKeyPicker("NoclipKey", { Default = "None", Mode = "Toggle" })
    move:AddToggle("InfiniteJump", { Text = T("Infinite jump", "กระโดดไม่จำกัด"), Description = T("Jump anywhere, even mid-air", "กระโดดได้ทุกที่ แม้กลางอากาศ") })

    local world = tab:AddRightGroupbox(T("World", "โลก"), "star")
    world:AddToggle("Fullbright", { Text = T("Fullbright", "สว่างทั้งแมพ") })
    world:AddToggle("AntiShake", { Text = T("Anti camera shake", "กันจอสั่น") })
    Reicht.UI.NeedCap("AntiShake", "Connections")
    world:AddToggle("NoFog", { Text = T("No fog", "ไม่มีหมอก") })
    world:AddToggle("AntiAfk", { Text = T("Anti AFK", "กันหลุด AFK"), Callback = Reicht.UI.Detach(Reicht.Player.AntiAfk.Arm) })

    Reicht.UI.BuildTeleport(tab)
end

function Reicht.UI.BuildShop(window)
    local tab = window:AddTab(T("Shop", "ร้านค้า"), "shop", T("Perks, items and killers", "เพิร์ค ไอเทม ฆาตกร"))

    local perks = tab:AddLeftGroupbox(T("Perks", "เพิร์ค"), "star")
    perks:AddToggle("AutoBuyPerks", { Text = T("Auto buy perks", "ซื้อเพิร์คอัตโนมัติ"), Description = T("Unlocks every perk you can afford with Gears", "ปลดล็อกเพิร์คทุกตัวที่ Gears พอ") })
    perks:AddToggle("AutoLevelPerks", { Text = T("Auto level perks", "อัปเลเวลเพิร์คอัตโนมัติ"), Description = T("Spends Screws to level owned perks", "ใช้ Screws อัปเลเวลเพิร์คที่มี") })
    perks:AddSlider("KeepScrews", { Text = T("Keep Screws", "เก็บ Screws ไว้"), Description = T("Never spends below this", "ไม่ใช้ต่ำกว่าจำนวนนี้"), Min = 0, Max = 20000, Default = 0 })
    perks:AddButton({ Text = T("Buy + Level Now", "ซื้อ + อัปตอนนี้"), Style = "Primary", Func = Reicht.UI.Detach(function()
        local bought, leveled = Reicht.Shop.Locked(Reicht.Shop.BuyPerks), Reicht.Shop.Locked(Reicht.Shop.LevelPerks)
        Library:Notify(T("Perks", "เพิร์ค"), ("Bought %d, leveled %d"):format(bought, leveled), 4, "Success")
    end) })

    local store = tab:AddRightGroupbox(T("Items & Killers", "ไอเทมและฆาตกร"), "coin")
    local items = store:AddDropdown("ShopItems", { Text = T("Items", "ไอเทม"), Values = Reicht.UI.List(Reicht.Shop.Names, "Items"), Multi = true, Default = {}, AllowNull = true, Searchable = true })
    store:AddButton({ Text = T("Buy Selected Items", "ซื้อไอเทมที่เลือก"), Func = Reicht.UI.Detach(function()
        Library:Notify(T("Shop", "ร้านค้า"), ("Bought %d items"):format(Reicht.Shop.Locked(Reicht.Shop.BuyList, "Item", items.Value)), 4, "Coin")
    end) })
    local killers = store:AddDropdown("ShopKillers", { Text = T("Killers", "ฆาตกร"), Values = Reicht.UI.List(Reicht.Shop.Names, "Killers"), Multi = true, Default = {}, AllowNull = true, Searchable = true })
    store:AddButton({ Text = T("Buy Selected Killers", "ซื้อฆาตกรที่เลือก"), Func = Reicht.UI.Detach(function()
        Library:Notify(T("Shop", "ร้านค้า"), ("Bought %d killers"):format(Reicht.Shop.Locked(Reicht.Shop.BuyList, "Killer", killers.Value)), 4, "Coin")
    end) })
    store:AddButton({ Text = T("Refresh lists", "รีเฟรชรายการ"), Func = Reicht.UI.Detach(function()
        items:SetValues(Reicht.Shop.Names("Items"))
        killers:SetValues(Reicht.Shop.Names("Killers"))
    end) })
end

---@param tab table  Player tab, the teleport group sits on its right side
function Reicht.UI.BuildTeleport(tab)
    local box = tab:AddRightGroupbox(T("Teleport", "วาร์ป"), "pipe")
    local places = box:AddDropdown("TeleportTarget", { Text = T("Destination", "ปลายทาง"), Values = Reicht.UI.List(Reicht.Teleport.Places), Default = "Nearest Generator", Searchable = true })
    box:AddButton({ Text = T("Teleport Now", "วาร์ปตอนนี้"), Style = "Primary", Func = Reicht.UI.Detach(function()
        if not Reicht.Teleport.Go(places.Value) then
            Library:Notify(T("Teleport", "วาร์ป"), T("Destination not found this round", "ไม่พบปลายทางในรอบนี้"), 3, "Warning")
        end
    end) }):AddButton({ Text = T("Refresh", "รีเฟรช"), Func = Reicht.UI.Detach(function()
        places:SetValues(Reicht.Teleport.Places())
    end) })
end

function Reicht.UI.BuildVisuals(window)
    window:AddTabSection(T("Visuals", "การมองเห็น"))
    local tab = window:AddVisualsTab({ Provider = Reicht.Esp.Targets, Preview = true })
    local objects = tab:AddLeftGroupbox(T("Objects", "วัตถุ"), "eye")
    objects:AddToggle("EspGenerators", { Text = T("Generators + progress", "เครื่องปั่นไฟ + ความคืบหน้า") })
    objects:AddToggle("EspHooks", { Text = T("Hooks", "ตะขอ") })
    objects:AddToggle("EspGates", { Text = T("Exit gates", "ประตูทางออก") })
    objects:AddToggle("EspPallets", { Text = T("Pallets", "พาเลท") })
    objects:AddToggle("EspWindows", { Text = T("Windows", "หน้าต่าง") })
end

function Reicht.UI.RefreshStatus()
    local labels = Reicht.UI.Labels
    if not (labels.Role and labels.Survivor and labels.Killer and labels.Esp and labels.Shop) then return end
    local dist = Reicht.Alert.Distance
    labels.Role:SetContent((Reicht.Player.Role() or "-") .. " · gens left " .. Reicht.Map.GensLeft() .. (dist and (" · killer %dm"):format(dist) or ""))
    labels.Survivor:SetContent(("%s · checks %d · dodges %d · escapes %d"):format(Reicht.Survivor.Status, Reicht.SkillCheck.Checks, Reicht.Guard.Dodges, Reicht.Survivor.Escapes))
    labels.Killer:SetContent(Reicht.Killer.Status .. " · stuns dodged " .. Reicht.AntiStun.Count)
    labels.Esp:SetContent(Reicht.Esp.GetStatus())
    labels.Shop:SetContent(Reicht.Shop.Status)
end

---Flips the menu toggles of jobs the scheduler halted and says why; runs on the library's own clean thread.
function Reicht.UI.DrainHalts()
    local halts = Reicht.Scheduler.Halts
    if not halts[1] then return end
    Reicht.Scheduler.Halts = {}
    for _, halt in ipairs(halts) do
        Util.Try("halt", function()
            for _, idx in ipairs(halt.Toggles) do
                local toggle = Library.Toggles[idx]
                if toggle and toggle.Value then toggle:SetValue(false) end
            end
            Library:Notify("Violence District", halt.Message, 6, "Warning")
        end)
    end
end

function Reicht.UI.Pump()
    Reicht.UI.DrainHalts()
    Reicht.UI.RefreshStatus()
end

function Reicht.UI.Build()
    local window = Library.Window
    for _, section in ipairs({ "BuildMain", "BuildSurvivor", "BuildKiller", "BuildPlayer", "BuildShop", "BuildVisuals" }) do
        Util.Try("ui " .. section, Reicht.UI[section], window)
    end
    window:AddTabSection(T("Other", "อื่นๆ"))
    Util.Try("ui settings", window.AddSettingsTab, window)

    for key in pairs(Reicht.Options) do
        local widget = Library.Options[key] or Library.Toggles[key]
        if widget then Reicht.UI.Bind(widget, key) end
    end
    Util.Try("ui gate", Reicht.UI.GateRemotes)
end

---Toggles whose game remote is gone refuse to turn on and say why, instead of erroring every tick.
function Reicht.UI.GateRemotes()
    if not Library.Compat then return end
    local reason = T("Not found after a game update", "หาไม่เจอหลังเกมอัปเดต")
    for idx in pairs(GameLib.Needs) do
        local missing = GameLib.Missing(idx)
        if missing and Library.Toggles[idx] then
            Library.Compat.Block(idx, reason)
            warn("[ViolenceDistrict] " .. idx .. " off, missing remote " .. missing)
        end
    end
end

---@return boolean  false when the menu could not load
local function BuildInterface()
    Library = Util.LoadLibrary()
    if not Library then return false end
    pcall(ReichtBanner.Step, "UI library")
    Reicht.Library = Library
    T = function(en, th) return Library:T(en, th) end
    Library:CreateWindow({
        Title = "Reicht",
        SubTitle = "Violence District by Reicht",
        MenuKey = Enum.KeyCode.LeftControl,
        ConfigFolder = Reicht.Config.SaveFolder,
        Language = "Auto",
        Theme = "Overworld",
        Intro = Reicht.Config.Intro,
        OnUnlocked = function()
            Reicht.UI.Build()
            task.defer(Util.Try, "boot", Reicht.Boot)
            Library:Every(Reicht.Config.StatusInterval, Reicht.UI.Pump)
            task.defer(Util.Try, "autoload", Library.LoadAutoloadConfig, Library)
        end,
    })
    Library:OnUnload(function()
        Reicht:Unload()
    end)
    return true
end

function Reicht.Boot()
    Reicht:Connect(LocalPlayer.CharacterAdded, function(character)
        Reicht.Survivor.Job = nil
        Reicht.Movement.Release()
        Reicht.Player:Bind(character)
    end)

    Reicht.Movement.Start()
    Reicht.SkillCheck.Start()
    Reicht.AntiStun.Start()

    Reicht.Scheduler.Every("Survivor", Reicht.Config.RepairTick, Reicht.Survivor.Step, { "AutoRepair", "AutoHeal", "AutoUnhook", "InstantEscape" }, { Core = true, Restore = Reicht.Survivor.Finish })
    Reicht.Scheduler.Every("Guard", Reicht.Config.GuardTick, Reicht.Guard.Step, { "AutoDodge", "AutoSelfUnhook" })
    Reicht.Scheduler.Every("Block", 1, Reicht.Block.Step, { "PerfectSkillCheck", "AntiStun", "AntiBlind", "AntiShake", "NoFall" }, { Restore = Reicht.Block.Release })
    Reicht.Scheduler.Every("Parry", Reicht.Config.GuardTick, Reicht.Parry.Step, { "AutoParry", "NoParryCooldown" })
    Reicht.Scheduler.Every("Killer", 0.1, Reicht.Killer.Step, { "KillAura", "AutoHook", "AutoBreakGens" })
    Reicht.Scheduler.Every("World", 0.5, Reicht.World.Step, { "Fullbright", "NoFog" }, { Restore = Reicht.World.Restore })
    Reicht.Scheduler.Every("Role", 3, Reicht.Role.Step)
    Reicht.Scheduler.Every("Alert", 0.5, Reicht.Alert.Step, { "KillerAlert" }, { Core = true })
    Reicht.Scheduler.Every("Shop", Reicht.Config.ShopInterval, Reicht.Shop.Step, { "AutoBuyPerks", "AutoLevelPerks" })
    Reicht.Scheduler.Every("ObjectEsp", Reicht.Config.ObjectEspRefresh, Reicht.Esp.Step, { "EspGenerators", "EspHooks", "EspGates", "EspPallets", "EspWindows" }, { Core = true })
    Reicht.Scheduler.Boot()
end

function Reicht:Unload()
    self.State.Alive = false
    if environment.ViolenceDistrictUnload == self.UnloadFn then environment.ViolenceDistrictUnload = nil end
    table.clear(Reicht.Scheduler.Jobs)
    Reicht.Survivor.Finish()
    Reicht.Block.Release()
    Reicht.Movement.Release()
    Reicht.World.Restore()
    Reicht.Esp.Clear()
    for _, connection in ipairs(self.State.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self.State.Connections)
end

Reicht.UnloadFn = function()
    if Reicht.Library and not Reicht.Library.Unloaded then
        Reicht.Library:Unload()
    else
        Reicht:Unload()
    end
end
environment.ViolenceDistrictUnload = Reicht.UnloadFn

if LocalPlayer.Character then
    Reicht.Player:Bind(LocalPlayer.Character)
end

pcall(ReichtBanner.Step, "Systems")
if BuildInterface() then
    pcall(ReichtBanner.Step, "Interface")
    pcall(ReichtBanner.Ready)
end