if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 9534705677 then
    game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for Sniper Arena only")
    return
end

if not LPH_OBFUSCATED then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local environment = getgenv and getgenv() or _G
if type(environment.SniperArenaUnload) == "function" then
    pcall(environment.SniperArenaUnload)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local osClock = os.clock

local Reicht = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

Reicht.Config = {
    UiSource = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
    Discord = "https://",
    UpdateLog = {
        { "2026-10-10", "Auto Join Round: joins the next round from the lobby\nSkin pictures and rarity colors\nSmoother ESP, cleaner and faster menu\nAuto Sell never sells the guns you hold\nFixed Aimbot key and unloading" },
        { "2026-10-03", "Classic Reicht UI is back\nBetter executor support\nImproved Combat & Movement" },
    },
    SaveFolder = "Sniper Arena",
    LoadTimeout = 30,
    AlertTries = 20,
    AlertGap = 0.5,
    RequireTimeout = 5,
    RequireBudget = 15,
    MaxFails = 5,
    FailWindow = 10,
    FovColor = Color3.fromRGB(232, 160, 76),
    BannerCaps = { "HookFunction", "Namecall", "Gc", "Upvalues", "Drawing", "Connections", "FileSystem" },
    CombatToggles = { "Aimbot", "SilentAim", "Ragebot", "TriggerBot", "NoRecoil", "NoSpread", "InstantScope", "FullAuto", "InstantReload", "InfiniteAmmo", "HitboxExpander", "AntiAim", "KnifeAura", "NoScopeOverlay", "FastSwitch" },
    ModuleFeatures = {
        EntityService = { "Aimbot", "SilentAim", "Ragebot", "TriggerBot" },
        CombatService = { "SilentAim", "Ragebot", "TriggerBot", "NoRecoil", "NoSpread", "InstantScope", "FullAuto", "InstantReload", "SkinChanger" },
        CameraController = { "SilentAim", "Ragebot" },
        WeaponConfig = { "SkinChanger" },
        GachaService = { "AutoOpenCases" },
        WeaponService = { "AutoSell" },
        QuestService = { "AutoClaimQuest" },
        GameService = { "FastRespawn" },
    },
    SkinMainRows = 4,
    SkinGroupRows = 3,
    EconomyInterval = 1,
    JoinText = "Touch to Join",
    JoinRange = 400,
    JoinRetry = 3,
    StatusInterval = 1,
    OpenDelay = 0.6,
    ClaimDelay = 0.5,
    FireInterval = 0.12,
    LookSettle = 0.1,
    TriggerRange = 2000,
    EspInterval = 0.15,
    EspGrace = 1,
    ResultWait = 3,
    AimRenderPriority = Enum.RenderPriority.Camera.Value + 5,
}

Reicht.State = {
    Alive = true,
    Connections = {},
    Halted = {},
    Notices = {},
    EspSnapshot = {},
}

Reicht.Options = {
    AntiAfk = false,

    InfiniteDash = false,
    InfiniteAirJump = false,
    AutoBhop = false,
    SpeedMultiplier = 1,
    CustomFov = 70,
    FastRespawn = false,
    AutoJoin = false,
    AutoFlag = false,
    SkinChanger = false,
    SkinRarities = {},

    AutoOpenCases = false,
    OpenCount = 1,
    AutoSell = false,
    SellRarities = {},
    MaxSellPrice = 500,
    KeepPerRarity = 0,
    AutoClaimQuest = false,

    Aimbot = false,
    SilentAim = false,
    Ragebot = false,
    InstantScope = false,
    FullAuto = false,
    InstantReload = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    HitboxSize = 6,
    HitboxPart = "Head",
    HitboxTransparency = 0.6,
    AntiAim = false,
    AntiAimMode = "Spinbot",
    SpinSpeed = 1080,
    KnifeAura = false,
    KnifeAuraRange = 16,
    NoScopeOverlay = false,
    FastSwitch = false,
    HitChance = 100,
    HeadChance = 100,
    TriggerBot = false,
    NoRecoil = false,
    NoSpread = false,
    AntiFlash = false,
    AntiSmoke = false,
    EnemyChams = false,
    AntiPeekBypass = false,
    AimTeamCheck = true,
    AimWallCheck = true,
    AimSmooth = 1,
    AimPrediction = 60,
    ShowFov = false,
    AimFov = 150,
    AimPriority = "Crosshair",
    AimMaxDistance = 1000,
    AimBone = "Head",
}

Reicht.Util = {}
local Util = Reicht.Util

---@return function?  first argument that is callable
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
Util.GetHui = Resolve(gethui, get_hidden_gui)
Util.GetUpvalue = Resolve(getupvalue, debug.getupvalue)
Util.GetUpvalues = Resolve(getupvalues, debug.getupvalues)
Util.GetRawMetatable = Resolve(getrawmetatable)

Reicht.Probes = {}

---@return boolean  getrawmetatable and getupvalues both answer for real
function Reicht.Probes.LookSpoof()
    if not (Util.GetRawMetatable and Util.GetUpvalues) then return false end
    local marker, meta = {}, { __metatable = "locked" }
    local proxy = setmetatable({}, meta)
    local function Holder() return marker end

    local ok, found = pcall(function()
        if Util.GetRawMetatable(proxy) ~= meta then return false end
        for _, value in pairs(Util.GetUpvalues(Holder)) do
            if value == marker then return true end
        end
        return false
    end)
    return ok and found == true
end

Reicht.Caps = setmetatable({}, {
    __index = function(caps, name)
        local probe = Reicht.Probes[name]
        if probe then
            local has = probe()
            rawset(caps, name, has)
            return has
        end
        local lib = Reicht.Library
        if not (lib and lib.Compat) then return false end
        return lib.Compat.Caps[name] == true
    end,
})

---@return string  response body, throws if every transport fails
function Util.HttpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" then
        return body
    end
    if not Util.Request then
        error("HttpGet failed: " .. url)
    end

    local sent, response = pcall(Util.Request, { Url = url, Method = "GET" })
    if not sent then error(response) end
    local status = type(response) == "table" and tonumber(response.StatusCode) or nil
    if status == 200 and type(response.Body) == "string" then
        return response.Body
    end
    error("HttpGet " .. url .. ": status " .. tostring(status))
end

---@param detail any  goes to the console, the player only sees text
function Util.Alert(text, detail)
    warn("[SniperArena] menu: " .. tostring(detail or text))
    task.spawn(function()
        for _ = 1, Reicht.Config.AlertTries do
            local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
                Title = "Reicht",
                Text = text,
                Duration = 10,
            })
            if shown then return end
            task.wait(Reicht.Config.AlertGap)
        end
    end)
end

---@return table?  UI library, nil after the player was told why
function Util.LoadLibrary(url)
    local fetched, source = pcall(Util.HttpGet, url)
    if not fetched or type(source) ~= "string" or not source:sub(-64):find("return Library%s*$") then
        Util.Alert("Could not download the menu. Check your connection and run it again.", fetched and "response is not the full menu" or source)
        return nil
    end

    local chunk, problem = loadstring(source)
    if type(chunk) ~= "function" then
        Util.Alert("The menu failed to load on this executor: " .. tostring(problem))
        return nil
    end
    local ran, lib = pcall(chunk)
    if not ran or type(lib) ~= "table" then
        Util.Alert("The menu failed to load on this executor: " .. tostring(lib))
        return nil
    end
    if type(lib.Compat) ~= "table" then
        Util.Alert("The menu is out of date. Run the script again in a few minutes.", "ui.lua has no Compat layer")
        return nil
    end
    return lib
end

---@return boolean  false after warning with context
function Util.Try(label, callback, ...)
    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[SniperArena] " .. label .. ": " .. tostring(err))
    end
    return ok
end

function Util.Copy(text)
    if Util.SetClipboard then
        Util.SetClipboard(text)
        return true
    end
    return false
end

---@return ScreenGui  script-owned layer, hidden gui first, PlayerGui last
function Util.Overlay()
    local screen = Reicht.State.Overlay
    if screen and screen.Parent then return screen end

    screen = Instance.new("ScreenGui")
    screen.Name = "MarioHubOverlay"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 50
    local mounts = { function() return game:GetService("CoreGui") end }
    if Util.GetHui then table.insert(mounts, 1, Util.GetHui) end
    for _, mount in ipairs(mounts) do
        if pcall(function() screen.Parent = mount() end) and screen.Parent then break end
    end
    if not screen.Parent then
        screen.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", Reicht.Config.LoadTimeout)
    end
    Reicht.State.Overlay = screen
    return screen
end

---@return string[]  sorted keys, stable dropdown order
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

Reicht.GameLib = { Config = {}, Service = {}, Missing = {}, LoadEnds = nil }
local GameLib = Reicht.GameLib

---@param asGame boolean     retry from an identity-2 thread, skipped when the executor can't switch
---@return boolean, boolean, any  finished before the deadline, require ok, module
function GameLib.RequireWithin(module, asGame)
    local done, ok, loaded = false, false, nil
    task.spawn(function()
        if asGame then
            pcall(setthreadidentity, 2)
            local read, identity = pcall(getthreadidentity)
            if not (read and identity == 2) then
                done = true
                return
            end
        end
        ok, loaded = pcall(require, module)
        done = true
    end)

    local deadline = osClock() + Reicht.Config.RequireTimeout
    if GameLib.LoadEnds then deadline = math.min(deadline, GameLib.LoadEnds) end
    while not done and osClock() < deadline do
        task.wait()
    end
    return done, ok, loaded
end

---@return any  nil when this executor can't require it (never throws)
function GameLib.Require(module)
    if GameLib.LoadEnds and osClock() >= GameLib.LoadEnds then
        GameLib.Missing[module.Name] = true
        warn("[SniperArena] require " .. module.Name .. ": load budget spent")
        return nil
    end

    local finished, ok, loaded = GameLib.RequireWithin(module, false)
    if ok then return loaded end
    if finished then
        local _, again, retried = GameLib.RequireWithin(module, true)
        if again then return retried end
    end
    GameLib.Missing[module.Name] = true
    warn("[SniperArena] require " .. module.Name .. ": " .. (finished and tostring(loaded) or "timed out"))
    return nil
end

---@param parent Instance?  expected folder; a moved module is still found anywhere in ReplicatedStorage
local function RequireChild(parent, name)
    local child = parent and parent:FindFirstChild(name)
    if not (child and child:IsA("ModuleScript")) then
        child = ReplicatedStorage:FindFirstChild(name, true)
    end
    if not (child and child:IsA("ModuleScript")) then
        GameLib.Missing[name] = "Absent"
        warn("[SniperArena] module " .. name .. " not found, features that need it are blocked")
        return nil
    end
    return GameLib.Require(child)
end

do
    local configFolder = ReplicatedStorage:FindFirstChild("Config")
    local remoteFolder = ReplicatedStorage:FindFirstChild("Remote")
    local constantFolder = ReplicatedStorage:FindFirstChild("Constant")
    GameLib.LoadEnds = osClock() + Reicht.Config.RequireBudget

    for _, name in ipairs({ "Config", "WeaponConfig", "WrapConfig", "QuestConfig" }) do
        GameLib.Config[name] = RequireChild(configFolder, name)
    end
    GameLib.RarityColor = RequireChild(constantFolder, "RarityColor")

    local serviceNames = {
        "StatusService", "GachaService", "WeaponService", "QuestService", "EntityService",
        "CombatService", "GameService",
    }
    for _, name in ipairs(serviceNames) do
        GameLib.Service[name] = RequireChild(remoteFolder, name)
    end
    GameLib.CameraController = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "CameraController")
    GameLib.WeaponController = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "WeaponController")
    GameLib.LocalCharacterController = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "LocalCharacterController")
    GameLib.HighlightController = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "HighlightController")
    GameLib.AntiPeekController = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "AntiPeekController")
    GameLib.Effects = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "Effects")
    GameLib.Settings = RequireChild(ReplicatedStorage:FindFirstChild("Client"), "Settings")
    local gameService = remoteFolder and remoteFolder:FindFirstChild("GameService")
    GameLib.RoomManager = RequireChild(gameService, "RoomManager")
    GameLib.Status = RequireChild(constantFolder, "Status")
    GameLib.LoadEnds = nil
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

---@return number?  coin the server last replicated, nil when unreadable
function Reicht.Player:Coin()
    local service = GameLib.Service.StatusService
    if not service then return nil end
    local key = GameLib.Status and GameLib.Status.Eco_Coin or "Eco_Coin"
    local ok, value = pcall(function() return service.GetStatus(key) end)
    return ok and tonumber(value) or nil
end

Reicht.Entity = {}

function Reicht.Entity.Service()
    return GameLib.Service.EntityService
end

---@return table  all combatant entities (focused + all server players)
function Reicht.Entity.List()
    local service = Reicht.Entity.Service()
    if not service then return {} end
    local list = {}
    local seen = {}

    local ok, focused = pcall(function() return service.WorldManager:GetFocusedEntities() end)
    if ok and type(focused) == "table" then
        local items = focused._items or focused.Items or focused
        for _, ent in pairs(items) do
            if type(ent) == "table" and ent.Instance and not seen[ent.Instance] then
                seen[ent.Instance] = true
                list[#list + 1] = ent
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not seen[plr] and not seen[plr.Character] then
            local ent = (service.GetEntity and service.GetEntity(plr))
                or (service.FetchEntity and service.FetchEntity(plr.Character))
            if ent and type(ent) == "table" then
                seen[plr] = true
                seen[plr.Character] = true
                list[#list + 1] = ent
            end
        end
    end

    return list
end

function Reicht.Entity.Local()
    local service = Reicht.Entity.Service()
    if not service then return nil end
    local ok, entity = pcall(function() return service.GetLocalEntity() end)
    if ok and entity then return entity end
    ok, entity = pcall(function() return service:GetLocalEntity() end)
    return ok and entity or nil
end

local function TryCall(object, method)
    if type(object) ~= "table" and typeof(object) ~= "Instance" then return nil, false end
    local call = object[method]
    if type(call) ~= "function" then return nil, false end
    local ok, value = pcall(call, object)
    if ok then return value, true end
    return nil, false
end

function Reicht.Entity.IsLocal(entity)
    local value, called = TryCall(entity, "IsLocalEntity")
    if called then return value == true end
    return entity == Reicht.Entity.Local()
end

---@return string?  per-round team tag, unique per player in FFA/Duel
function Reicht.Entity.Team(entity)
    local inst = entity and entity.Instance
    if typeof(inst) == "Instance" then
        local team = inst:GetAttribute("Team")
        if team ~= nil then return tostring(team) end
    end
    local char = Reicht.Entity.Character(entity)
    local team = char and char:GetAttribute("Team")
    return team ~= nil and tostring(team) or nil
end

function Reicht.Entity.Friendly(entity)
    if type(entity) ~= "table" and typeof(entity) ~= "Instance" then return false end
    local service = Reicht.Entity.Service()
    local localEnt = Reicht.Entity.Local()
    if localEnt and type(entity) == "table" and type(localEnt.IsFriendly) == "function" then
        local ok, friendly = pcall(localEnt.IsFriendly, localEnt, entity)
        if ok and friendly ~= nil then return friendly == true end
    end
    if service and type(service.IsFriendly) == "function" then
        local target = type(entity) == "table" and (entity.Instance or Reicht.Entity.Character(entity)) or entity
        local ok, friendly = pcall(service.IsFriendly, target, LocalPlayer)
        if ok and friendly ~= nil then return friendly == true end
    end
    local targetChar = type(entity) == "table" and Reicht.Entity.Character(entity) or (typeof(entity) == "Instance" and entity)
    local targetPlayer = targetChar and Players:GetPlayerFromCharacter(targetChar)
    if targetPlayer and targetPlayer.Team and LocalPlayer.Team then
        return targetPlayer.Team == LocalPlayer.Team
    end
    return false
end

function Reicht.Entity.Health(entity)
    if not entity then return 0, 0 end
    local health = entity.Health or select(1, TryCall(entity, "GetHealth")) or 0
    local maxHealth = entity.MaxHealth or select(1, TryCall(entity, "GetMaxHealth")) or 0
    return health, maxHealth
end

function Reicht.Entity.Character(entity)
    if typeof(entity) == "Instance" then
        if entity:IsA("Player") then return entity.Character end
        if entity:FindFirstChildOfClass("Humanoid") then return entity end
        if entity.Parent and entity.Parent:FindFirstChildOfClass("Humanoid") then return entity.Parent end
        return entity
    end
    local humanoid = entity and entity.Humanoid
    if humanoid and humanoid.Parent then return humanoid.Parent end
    if entity and entity.Instance then
        if entity.Instance:IsA("Player") then return entity.Instance.Character end
        return entity.Instance
    end
    return entity and entity.Character or nil
end

function Reicht.Entity.Root(entity)
    local character = Reicht.Entity.Character(entity)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") or character.PrimaryPart
end

Reicht.Match = {}

---@return string?, string?  mode, map — nil outside a room
function Reicht.Match.Info()
    local rooms = GameLib.RoomManager
    local ok, room = pcall(function() return rooms and rooms.GetFocusedRoom() end)
    if not ok or type(room) ~= "table" then return nil, nil end
    return room.Mode, room.Map
end

---@return string?  FFA / TDM / Duel / Boss
function Reicht.Match.ModeSet()
    local rooms = GameLib.RoomManager
    local ok, room = pcall(function() return rooms and rooms.GetFocusedRoom() end)
    return ok and type(room) == "table" and room.ModeSet or nil
end

function Reicht.Match.InRound()
    return LocalPlayer:GetAttribute("combatPaused") == false
end

Reicht.Faults = { Streaks = {}, Said = {} }

---@param err any  the same error again stays quiet for FailWindow
function Reicht.Faults.Say(name, err)
    local text, now = tostring(err), osClock()
    local last = Reicht.Faults.Said[name]
    if last and last[1] == text and now - last[2] < Reicht.Config.FailWindow then return end
    Reicht.Faults.Said[name] = { text, now }
    warn("[SniperArena] " .. name .. ": " .. text)
end

function Reicht.Faults.Clear(name)
    Reicht.Faults.Streaks[name] = nil
end

function Reicht.Faults.Wanted(toggles)
    for _, key in ipairs(toggles) do
        if Reicht.Options[key] then return true end
    end
    return false
end

---@param restore function?  the feature's own off path
function Reicht.Faults.Stop(name, err, toggles, restore)
    warn("[SniperArena] " .. name .. " stopped: " .. tostring(err))
    for _, key in ipairs(toggles) do
        Reicht.Options[key] = false
    end
    if restore then Util.Try(name .. " restore", restore) end
    table.insert(Reicht.State.Halted, { name, tostring(err):match("^[^\n]*"), toggles })
end

---@param toggles string[]   switched off when the feature keeps failing; empty = never stops, warns once per streak
---@param restore function?  run once when the feature is stopped
---@return boolean           true while the feature is stopped
function Reicht.Faults.Report(name, err, toggles, restore)
    local now = osClock()
    local streak = Reicht.Faults.Streaks[name]
    if not streak or (streak.Halted and Reicht.Faults.Wanted(toggles)) then
        streak = { Count = 0, First = now, Warned = false, Halted = false }
        Reicht.Faults.Streaks[name] = streak
    end
    streak.Count += 1
    if streak.Count == 1 then Reicht.Faults.Say(name, err) end
    if streak.Warned then return streak.Halted end
    if streak.Count < Reicht.Config.MaxFails or now - streak.First < Reicht.Config.FailWindow then return false end

    streak.Warned = true
    if #toggles == 0 then
        warn("[SniperArena] " .. name .. " keeps failing: " .. tostring(err))
        return false
    end
    streak.Halted = true
    Reicht.Faults.Stop(name, err, toggles, restore)
    return true
end

Reicht.Scheduler = { Jobs = {}, Booted = false }

---@param toggles string[]?  options the job serves; turned off if it keeps failing
---@param restore function?  the job's off path, run once if it gets stopped
function Reicht.Scheduler.Every(name, interval, work, toggles, restore)
    Reicht.Scheduler.Jobs[name] = { Interval = interval, Fn = work, Last = 0, Running = false, Toggles = toggles or {}, Restore = restore }
end

---@return boolean  a stopped job comes back once one of its toggles is on again
function Reicht.Scheduler.Revive(name, job)
    if not Reicht.Faults.Wanted(job.Toggles) then return false end
    job.Halted = false
    Reicht.Faults.Clear(name)
    return true
end

function Reicht.Scheduler.Settle(name, job)
    local err = job.Error
    job.Error = nil
    if err then
        job.Halted = Reicht.Faults.Report(name, err, job.Toggles, job.Restore)
    else
        Reicht.Faults.Clear(name)
    end
end

function Reicht.Scheduler.Step()
    if not Reicht.State.Alive then return end
    local now = osClock()
    for name, job in pairs(Reicht.Scheduler.Jobs) do
        if job.Running then continue end
        if job.Error ~= nil then Reicht.Scheduler.Settle(name, job) end
        if job.Halted and not Reicht.Scheduler.Revive(name, job) then continue end
        if now - job.Last < job.Interval then continue end

        job.Last = now
        job.Running = true
        task.spawn(function()
            local ok, err = pcall(job.Fn)
            job.Error = (not ok) and tostring(err) or false
            job.Running = false
        end)
    end
end

function Reicht.Scheduler.Boot()
    if Reicht.Scheduler.Booted then return end
    Reicht.Scheduler.Booted = true
    Reicht:Connect(RunService.Heartbeat, Reicht.Scheduler.Step)
end

Reicht.Banner = {
    Print = print,
    Started = osClock(),
    Last = osClock(),
    Done = 0,
    Total = 5,
    Art = [[
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
    Title = [[
  __  __    _    ____  ___ ___    _   _ _   _ ____
 |  \/  |  / \  |  _ \|_ _/ _ \  | | | | | | | __ )
 | |\/| | / _ \ | |_) || | | | | | |_| | | | |  _ \
 | |  | |/ ___ \|  _ < | | |_| | |  _  | |_| | |_) |
 |_|  |_/_/   \_\_| \_\___\___/  |_| |_|\___/|____/
]],
}

pcall(function()
    local renv = getrenv()
    if type(renv.print) == "function" then Reicht.Banner.Print = renv.print end
end)

function Reicht.Banner.Show()
    local ok, executor = pcall(identifyexecutor)
    if not ok or type(executor) ~= "string" then executor = "Unknown" end
    local rule = string.rep("=", 54)
    Reicht.Banner.Print(table.concat({
        "",
        Reicht.Banner.Art,
        Reicht.Banner.Title,
        rule,
        "   SNIPER ARENA  //  by Reicht  //  ",
        "   executor: " .. tostring(executor) .. "   //   player: " .. LocalPlayer.Name,
        rule,
    }, "\n"))
end

---@param label string  what just finished loading
function Reicht.Banner.Step(label)
    local banner = Reicht.Banner
    local now = osClock()
    banner.Done = math.min(banner.Done + 1, banner.Total)
    local filled = math.floor(banner.Done / banner.Total * 20 + 0.5)
    local bar = string.rep("#", filled) .. string.rep(".", 20 - filled)
    Reicht.Banner.Print(string.format("[Reicht] [%s] %3d%%  %-24s +%dms",
        bar, math.floor(banner.Done / banner.Total * 100), label, math.floor((now - banner.Last) * 1000)))
    banner.Last = now
end

function Reicht.Banner.Ready()
    local names = Reicht.Config.BannerCaps
    local caps = 0
    for _, name in ipairs(names) do
        if Reicht.Caps[name] then caps += 1 end
    end
    local rule = string.rep("=", 54)
    Reicht.Banner.Print(table.concat({
        rule,
        string.format("   >> READY in %dms  //  caps %d/%d  //  LeftCtrl = menu",
            math.floor((osClock() - Reicht.Banner.Started) * 1000), caps, #names),
        rule,
    }, "\n"))
end

pcall(Reicht.Banner.Show)
pcall(Reicht.Banner.Step, "Core")

Reicht.Player.AntiAfk = { Connection = nil, Status = "Off" }

function Reicht.Player.AntiAfk.OnIdled()
    if not Reicht.Options.AntiAfk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end

function Reicht.Player.AntiAfk.Start()
    Reicht.Options.AntiAfk = true
    if not Reicht.Player.AntiAfk.Connection then
        Reicht.Player.AntiAfk.Connection = Reicht:Connect(LocalPlayer.Idled, Reicht.Player.AntiAfk.OnIdled)
    end
    Reicht.Player.AntiAfk.Status = "Armed"
end

function Reicht.Player.AntiAfk.Stop()
    Reicht.Options.AntiAfk = false
    local conn = Reicht.Player.AntiAfk.Connection
    Reicht.Player.AntiAfk.Connection = nil
    if conn then conn:Disconnect() end
    Reicht.Player.AntiAfk.Status = "Off"
end

function Reicht.Player.AntiAfk.GetStatus()
    return Reicht.Player.AntiAfk.Status
end

Reicht.Player.Respawn = { Status = "Off", Count = 0, Fired = false }

function Reicht.Player.Respawn.IsDead()
    local state = LocalPlayer:GetAttribute("State")
    if state == "Dead" or state == "Died" then return true end
    local hum = Reicht.Player.Humanoid
    return hum ~= nil and hum.Health <= 0
end

function Reicht.Player.Respawn.Fire()
    local gameService = Reicht.GameLib.Service.GameService
    if gameService and gameService.CanFastRespawn and gameService.CanFastRespawn() then
        gameService.FastRespawn()
        return
    end
    local folder = ReplicatedStorage:FindFirstChild("Remote")
    local service = folder and folder:FindFirstChild("GameService")
    local remote = service and service:FindFirstChild("Respawn")
    if remote then remote:FireServer() end
end

function Reicht.Player.Respawn.Reset()
    Reicht.Player.Respawn.Fired = false
end

function Reicht.Player.Respawn.Step()
    local respawn = Reicht.Player.Respawn
    if not Reicht.Options.FastRespawn then
        respawn.Status = "Off"
        return
    end
    local gameService = Reicht.GameLib.Service.GameService
    if not (gameService and gameService.IsJoined and gameService.IsJoined()) then
        respawn.Status = "Not in game"
        return
    end
    if not respawn.IsDead() then
        respawn.Fired = false
        respawn.Status = "Alive · respawns " .. respawn.Count
        return
    end

    respawn.Status = "Respawning"
    if respawn.Fired then return end
    respawn.Fired = true
    respawn.Count += 1
    respawn.Fire()
end

function Reicht.Player.Respawn.GetStatus()
    return Reicht.Player.Respawn.Status
end

Reicht.Player.Join = { Status = "Off", LastTry = 0 }

---@return BasePart?  the lobby pad that puts you in a round, while it says the round can be joined
function Reicht.Player.Join.Pad()
    local lobby = Workspace:FindFirstChild("Lobby")
    local start = lobby and lobby:FindFirstChild("Start")
    local pad = start and start:FindFirstChild("Touch", true)
    if not (pad and pad:IsA("BasePart")) then return nil end
    for _, label in ipairs(start:GetDescendants()) do
        if label:IsA("TextLabel") and label.Text:find(Reicht.Config.JoinText, 1, true) then return pad end
    end
    return nil
end

---Touches the lobby pad from where you stand, so you drop into the next round without walking there.
function Reicht.Player.Join.Step()
    local join = Reicht.Player.Join
    local root = Reicht.Player.Root
    local pad = join.Pad()
    if not (root and root.Parent and pad) then
        join.Status = pad and "Waiting for character" or "In a round"
        return
    end
    if (root.Position - pad.Position).Magnitude > Reicht.Config.JoinRange then
        join.Status = "In a round"
        return
    end
    if osClock() - join.LastTry < Reicht.Config.JoinRetry then return end
    join.LastTry = osClock()
    join.Status = "Joining"
    firetouchinterest(root, pad, 0)
    task.wait(0.1)
    firetouchinterest(root, pad, 1)
end

Reicht.Movement = { Booted = false, Dash = nil, Resolving = false, SavedAirJump = nil, HookedAirJump = false }

---@return ModuleScript?  dash helper, searched by name if CombatHelper moved
function Reicht.Movement.FindDash()
    local client = ReplicatedStorage:FindFirstChild("Client")
    local helper = client and client:FindFirstChild("CombatHelper")
    local dash = helper and helper:FindFirstChild("Dash")
    if dash and dash:IsA("ModuleScript") then return dash end
    helper = ReplicatedStorage:FindFirstChild("CombatHelper", true)
    dash = helper and helper:FindFirstChild("Dash")
    return dash and dash:IsA("ModuleScript") and dash or nil
end

function Reicht.Movement.ResolveDash()
    local found = Reicht.Movement.FindDash()
    Reicht.Movement.Dash = found and GameLib.Require(found) or false
    Reicht.Movement.Resolving = false
end

---@return table?  dash module once resolved, nil while the single require is still running
function Reicht.Movement.DashHelper()
    local dash = Reicht.Movement.Dash
    if dash ~= nil then return dash or nil end
    if Reicht.Movement.Resolving then return nil end
    Reicht.Movement.Resolving = true
    task.spawn(Reicht.Movement.ResolveDash)
    return nil
end

function Reicht.Movement.ApplyAirJump()
    if Reicht.Movement.HookedAirJump then return end
    local lcc = Reicht.GameLib.LocalCharacterController
    if not (lcc and type(lcc.CanAirJump) == "function" and hookfunction) then return end
    Reicht.Movement.SavedAirJump = lcc.CanAirJump
    Reicht.Movement.HookedAirJump = true
    hookfunction(lcc.CanAirJump, function(...)
        if Reicht.Options.InfiniteAirJump then return true end
        return Reicht.Movement.SavedAirJump(...)
    end)
end

function Reicht.Movement.RestoreAirJump()
    if not Reicht.Movement.HookedAirJump then return end
    local lcc = Reicht.GameLib.LocalCharacterController
    if lcc and lcc.CanAirJump and restorefunction then
        pcall(restorefunction, lcc.CanAirJump)
    end
    Reicht.Movement.SavedAirJump = nil
    Reicht.Movement.HookedAirJump = false
end

function Reicht.Movement.OnStepped()
    if Reicht.Options.InfiniteDash then
        local dash = Reicht.Movement.DashHelper()
        if dash and dash.RefreshNextDashTime then pcall(dash.RefreshNextDashTime) end
    end

    if Reicht.Options.InfiniteAirJump then
        Reicht.Movement.ApplyAirJump()
    elseif Reicht.Movement.HookedAirJump then
        Reicht.Movement.RestoreAirJump()
    end

    local localEnt = Reicht.Entity.Local()
    if localEnt and localEnt.SetWalkSpeedMultiplier then
        local mult = tonumber(Reicht.Options.SpeedMultiplier) or 1
        if mult > 1 then
            localEnt:SetWalkSpeedMultiplier("MarioSpeed", mult)
        elseif localEnt.WalkSpeedMultipliers and localEnt.WalkSpeedMultipliers.MarioSpeed then
            localEnt:SetWalkSpeedMultiplier("MarioSpeed", nil)
        end
    end

    if Reicht.Options.AutoBhop then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 and hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    local fov = tonumber(Reicht.Options.CustomFov) or 70
    local cam = Workspace.CurrentCamera
    if cam and fov > 70 then
        cam.FieldOfView = fov
    end
end

function Reicht.Movement.Start()
    if Reicht.Movement.Booted then return end
    Reicht.Movement.Booted = true
    Reicht:Connect(RunService.Stepped, Reicht.Movement.OnStepped)
end

function Reicht.Movement.Restore()
    Reicht.Movement.RestoreAirJump()
    local localEnt = Reicht.Entity.Local()
    if localEnt and localEnt.SetWalkSpeedMultiplier and localEnt.WalkSpeedMultipliers and localEnt.WalkSpeedMultipliers.MarioSpeed then
        localEnt:SetWalkSpeedMultiplier("MarioSpeed", nil)
    end
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = 70 end
end

function Reicht.Movement.GetStatus()
    local parts = {}
    if Reicht.Options.InfiniteDash then table.insert(parts, "Dash") end
    if Reicht.Options.InfiniteAirJump then table.insert(parts, "AirJump") end
    local mult = tonumber(Reicht.Options.SpeedMultiplier) or 1
    if mult > 1 then table.insert(parts, string.format("Speed x%.1f", mult)) end
    return #parts > 0 and table.concat(parts, " · ") or "Off"
end

Reicht.Esp = { Count = 0, Rows = {}, Chammed = {}, AntiPeekHooked = false, SavedAntiPeek = nil }

function Reicht.Esp.Enabled()
    local visuals = Reicht.Library and Reicht.Library.Visuals
    return visuals ~= nil and visuals:Get("Enabled") == true
end

---@return any  stays the same while the entity lives, even when its model streams out
function Reicht.Esp.KeyOf(entity, char)
    local inst = entity.Instance
    if typeof(inst) == "Instance" then return inst end
    return char or entity
end

---@return table?  row for Library.Visuals, nil for dead, local or missing entities
function Reicht.Esp.Row(entity)
    if type(entity) ~= "table" or Reicht.Entity.IsLocal(entity) then return nil end
    local char = Reicht.Entity.Character(entity)
    local health, maxHealth = Reicht.Entity.Health(entity)
    if not char or health <= 0 then return nil end

    local player = Players:GetPlayerFromCharacter(char)
    return {
        Model = char,
        Name = player and player.DisplayName or char.Name,
        Health = health,
        MaxHealth = maxHealth > 0 and maxHealth or 100,
        Friendly = Reicht.Entity.Friendly(entity),
        Root = Reicht.Entity.Root(entity),
    }
end

---@param now number  rows unseen for longer than EspGrace are dropped
function Reicht.Esp.Expire(seen, now)
    local grace = Reicht.Config.EspGrace
    for key, held in pairs(Reicht.Esp.Rows) do
        if seen[key] then continue end
        local row = held.Row
        local alive = row.Model.Parent and row.Root and row.Root.Parent
        if now - held.Seen > grace or not alive then Reicht.Esp.Rows[key] = nil end
    end
end

function Reicht.Esp.ApplyAntiPeek()
    local apc = Reicht.GameLib.AntiPeekController
    if not apc then return end
    pcall(apc.SetActive, false)
    if Reicht.Esp.AntiPeekHooked or not (hookfunction and type(apc.SetActive) == "function") then return end
    Reicht.Esp.SavedAntiPeek = apc.SetActive
    Reicht.Esp.AntiPeekHooked = true
    hookfunction(apc.SetActive, function(...)
        if Reicht.Options.AntiPeekBypass then return end
        return Reicht.Esp.SavedAntiPeek(...)
    end)
end

function Reicht.Esp.RestoreAntiPeek()
    if not Reicht.Esp.AntiPeekHooked then return end
    local apc = Reicht.GameLib.AntiPeekController
    if apc and apc.SetActive and restorefunction then
        pcall(restorefunction, apc.SetActive)
    end
    Reicht.Esp.SavedAntiPeek = nil
    Reicht.Esp.AntiPeekHooked = false
end

function Reicht.Esp.UpdateChams()
    local hc = Reicht.GameLib.HighlightController
    if not hc or type(hc.Set) ~= "function" then return end

    if not Reicht.Options.EnemyChams then
        if next(Reicht.Esp.Chammed) then
            for model in pairs(Reicht.Esp.Chammed) do
                pcall(hc.Cancel, model, "EnemyXRay")
            end
            table.clear(Reicht.Esp.Chammed)
        end
        return
    end

    local current = {}
    for _, entity in pairs(Reicht.Entity.List()) do
        if Reicht.Entity.IsLocal(entity) or Reicht.Entity.Friendly(entity) then continue end
        local health = Reicht.Entity.Health(entity)
        local char = Reicht.Entity.Character(entity)
        if not (char and char.Parent and health > 0) then continue end
        current[char] = true
        if not Reicht.Esp.Chammed[char] then
            pcall(hc.Set, char, "EnemyXRay", -1)
            Reicht.Esp.Chammed[char] = true
        end
    end

    for model in pairs(Reicht.Esp.Chammed) do
        if not current[model] then
            pcall(hc.Cancel, model, "EnemyXRay")
            Reicht.Esp.Chammed[model] = nil
        end
    end
end

function Reicht.Esp.Step()
    if Reicht.Options.AntiPeekBypass then
        Reicht.Esp.ApplyAntiPeek()
    elseif Reicht.Esp.AntiPeekHooked then
        Reicht.Esp.RestoreAntiPeek()
    end

    Reicht.Esp.UpdateChams()

    if not Reicht.Esp.Enabled() then
        table.clear(Reicht.Esp.Rows)
        Reicht.State.EspSnapshot = {}
        Reicht.Esp.Count = 0
        return
    end

    local now, seen = osClock(), {}
    for _, entity in pairs(Reicht.Entity.List()) do
        local row = Reicht.Esp.Row(entity)
        if not row then continue end
        local key = Reicht.Esp.KeyOf(entity, row.Model)
        local held = Reicht.Esp.Rows[key]
        if not row.Root and held then row.Root = held.Row.Root end
        seen[key] = true
        Reicht.Esp.Rows[key] = { Row = row, Seen = now }
    end
    Reicht.Esp.Expire(seen, now)

    local snapshot = {}
    for _, held in pairs(Reicht.Esp.Rows) do
        table.insert(snapshot, held.Row)
    end
    Reicht.State.EspSnapshot = snapshot
    Reicht.Esp.Count = #snapshot
end

function Reicht.Esp.Restore()
    Reicht.Esp.RestoreAntiPeek()
    local hc = Reicht.GameLib.HighlightController
    if hc and type(hc.Cancel) == "function" then
        for model in pairs(Reicht.Esp.Chammed) do
            pcall(hc.Cancel, model, "EnemyXRay")
        end
    end
    table.clear(Reicht.Esp.Chammed)
end

---@return table[]  last snapshot from the scheduler, never touches game modules
function Reicht.Esp.Targets()
    return Reicht.State.EspSnapshot
end

function Reicht.Esp.GetStatus()
    local list = {}
    if Reicht.Esp.Enabled() then table.insert(list, Reicht.Esp.Count .. " ESP") end
    if Reicht.Options.EnemyChams then table.insert(list, "Chams") end
    if Reicht.Options.AntiPeekBypass then table.insert(list, "Anti-Peek") end
    return #list > 0 and table.concat(list, " · ") or "Off"
end

---@param probe function  re-read until it differs from before or ResultWait runs out
---@return any             value after the wait
local function AwaitChange(before, probe)
    local deadline = osClock() + Reicht.Config.ResultWait
    local now = probe()
    while now == before and osClock() < deadline do
        task.wait(0.2)
        now = probe()
    end
    return now
end

Reicht.Shop = { Status = "Off", LastResult = "" }

---@return string[]  case keys the player actually owns (from the gacha store)
function Reicht.Shop.Cases()
    local service = GameLib.Service.GachaService
    local store = service and service.LocalGachaStore
    local cases = store and store.Data
    if type(cases) ~= "table" then return {} end
    local keys = {}
    for key, entry in pairs(cases) do
        local owned = type(entry) == "table" and entry.Owned or entry
        if tonumber(owned) and owned > 0 then keys[#keys + 1] = tostring(key) end
    end
    table.sort(keys)
    return keys
end

function Reicht.Shop.Owned(caseKey)
    local service = GameLib.Service.GachaService
    if not service then return 0 end
    local ok, owned = pcall(function() return service.GetGachaCount(caseKey) end)
    return ok and tonumber(owned) or 0
end

---@return number  cases the owned count really dropped by
function Reicht.Shop.Open(caseKey, count)
    local service = GameLib.Service.GachaService
    if not service then return 0 end
    local before = Reicht.Shop.Owned(caseKey)
    count = math.min(count, before)
    if count < 1 then return 0 end

    local ok, err = pcall(function() return service.Gacha(caseKey, count) end)
    if not ok then
        warn("[SniperArena] open " .. caseKey .. ": " .. tostring(err))
        return 0
    end
    local after = AwaitChange(before, function() return Reicht.Shop.Owned(caseKey) end)
    return math.max(before - after, 0)
end

function Reicht.Shop.OpenAllNow()
    local opened = 0
    for _, caseKey in ipairs(Reicht.Shop.Cases()) do
        local owned = Reicht.Shop.Owned(caseKey)
        if owned < 1 then continue end
        opened += Reicht.Shop.Open(caseKey, math.min(owned, math.max(Reicht.Options.OpenCount, 1)))
        task.wait(Reicht.Config.OpenDelay)
    end
    Reicht.Shop.LastResult = opened > 0 and (opened .. " cases opened") or "no case opened"
    return Reicht.Shop.LastResult
end

function Reicht.Shop.Step()
    if not Reicht.Options.AutoOpenCases then Reicht.Shop.Status = "Off" return end
    Reicht.Shop.Status = "Opening owned cases"
    Reicht.Shop.OpenAllNow()
end

function Reicht.Shop.GetStatus()
    return Reicht.Options.AutoOpenCases and Reicht.Shop.Status or "Off"
end

Reicht.Sell = { Status = "Off", LastResult = "" }

---@return string?  skin rarity from WrapConfig, nil for base/unknown skins
function Reicht.Sell.RarityOf(weaponName)
    local skin = tostring(weaponName):match("%.(.+)$")
    local wraps = GameLib.Config.WrapConfig
    local entry = skin and type(wraps) == "table" and wraps[skin]
    return type(entry) == "table" and entry.Rarity or nil
end

---@return string[]  rarity names present in WrapConfig
function Reicht.Sell.Rarities()
    local wraps = GameLib.Config.WrapConfig
    if type(wraps) ~= "table" then return {} end
    local seen = {}
    for _, entry in pairs(wraps) do
        if type(entry) == "table" and entry.Rarity then seen[tostring(entry.Rarity)] = true end
    end
    return Util.SortedKeys(seen)
end

---@return table[]  owned weapons with uid, rarity, price, wear
function Reicht.Sell.Inventory()
    local service = GameLib.Service.WeaponService
    local ok, content = pcall(function() return service and service.GetContent() end)
    if not ok or type(content) ~= "table" then return {} end

    local list = {}
    for uid, weapon in pairs(content) do
        if type(weapon) == "table" then
            list[#list + 1] = {
                Uid = uid,
                Name = weapon.Name or tostring(uid),
                Rarity = Reicht.Sell.RarityOf(weapon.Name),
                Price = tonumber(weapon.Price) or 0,
                Wear = tonumber(weapon.WearFactor) or 0,
            }
        end
    end
    return list
end

---@return table?  skin names of the weapons you hold (the loadout has no inventory id), nil when unknown
function Reicht.Sell.Equipped()
    local combat = GameLib.Service.CombatService
    if not combat then return nil end
    local ok, weapons = pcall(function() return combat.GetWeapons() end)
    if not ok or type(weapons) ~= "table" then return nil end

    local set, count = {}, 0
    for _, weapon in pairs(weapons) do
        if type(weapon) == "table" and type(weapon.Name) == "string" then
            set[weapon.Name] = true
            count += 1
        end
    end
    return count > 0 and set or nil
end

---@return string[]?  uids to sell, the priciest KeepPerRarity of each rarity stay; nil when equipped is unknown
function Reicht.Sell.Pick()
    local equipped = Reicht.Sell.Equipped()
    if not equipped then return nil end
    local wanted = Util.SetFromList(Reicht.Options.SellRarities)
    local ceiling = Reicht.Options.MaxSellPrice

    local owned = Reicht.Sell.Inventory()
    table.sort(owned, function(left, right) return left.Price > right.Price end)

    local kept, uids = {}, {}
    for _, weapon in ipairs(owned) do
        if not (weapon.Rarity and wanted[weapon.Rarity]) or equipped[weapon.Name] then continue end
        kept[weapon.Rarity] = (kept[weapon.Rarity] or 0) + 1
        if kept[weapon.Rarity] <= Reicht.Options.KeepPerRarity then continue end
        if ceiling <= 0 or weapon.Price <= ceiling then table.insert(uids, weapon.Uid) end
    end
    return uids
end

function Reicht.Sell.SellNow()
    local service = GameLib.Service.WeaponService
    if not service then Reicht.Sell.LastResult = "no service" return Reicht.Sell.LastResult end

    local uids = Reicht.Sell.Pick()
    if not uids then
        Reicht.Sell.LastResult = "equipped weapons unknown, nothing sold"
        return Reicht.Sell.LastResult
    end
    if #uids == 0 then
        Reicht.Sell.LastResult = "nothing to sell"
        return Reicht.Sell.LastResult
    end

    local countBefore, coinBefore = #Reicht.Sell.Inventory(), Reicht.Player:Coin()
    local ok, err = pcall(function() return service.Sell(uids) end)
    if not ok then
        Reicht.Sell.LastResult = "sell failed: " .. tostring(err)
        return Reicht.Sell.LastResult
    end

    local countAfter = AwaitChange(countBefore, function() return #Reicht.Sell.Inventory() end)
    local coinAfter = Reicht.Player:Coin()
    local gained = (coinBefore and coinAfter) and (" · +" .. (coinAfter - coinBefore) .. " coin") or ""
    Reicht.Sell.LastResult = math.max(countBefore - countAfter, 0) .. " sold" .. gained
    return Reicht.Sell.LastResult
end

function Reicht.Sell.Step()
    if not Reicht.Options.AutoSell then Reicht.Sell.Status = "Off" return end
    Reicht.Sell.Status = Reicht.Sell.SellNow()
end

function Reicht.Sell.GetStatus()
    return Reicht.Options.AutoSell and Reicht.Sell.Status or "Off"
end

Reicht.Collect = { Status = "Off", LastResult = "" }

---@return boolean  false when the game can't answer
function Reicht.Collect.IsClaimed(questId)
    local service = GameLib.Service.QuestService
    local ok, claimed = pcall(function() return service.IsClaimed(questId) end)
    return ok and claimed == true
end

---@return any[]  quest ids the game marks finished and not yet claimed
function Reicht.Collect.Claimable()
    local service = GameLib.Service.QuestService
    local quests = GameLib.Config.QuestConfig
    if not (service and type(quests) == "table") then return {} end

    local list = {}
    for questId in pairs(quests) do
        local asked, finished = pcall(function() return service.IsFinished(questId) end)
        if asked and finished and not Reicht.Collect.IsClaimed(questId) then
            list[#list + 1] = questId
        end
    end
    return list
end

function Reicht.Collect.ClaimNow()
    local service = GameLib.Service.QuestService
    if not service then Reicht.Collect.LastResult = "no service" return Reicht.Collect.LastResult end

    local ids = Reicht.Collect.Claimable()
    if #ids == 0 then
        Reicht.Collect.LastResult = "nothing to claim"
        return Reicht.Collect.LastResult
    end

    local claimed = 0
    for _, questId in ipairs(ids) do
        local ok, err = pcall(function() return service.ClaimReward(questId) end)
        if not ok then
            warn("[SniperArena] claim " .. tostring(questId) .. ": " .. tostring(err))
        elseif AwaitChange(false, function() return Reicht.Collect.IsClaimed(questId) end) then
            claimed += 1
        end
        task.wait(Reicht.Config.ClaimDelay)
    end
    Reicht.Collect.LastResult = claimed .. "/" .. #ids .. " quests claimed"
    return Reicht.Collect.LastResult
end

function Reicht.Collect.Step()
    if not Reicht.Options.AutoClaimQuest then Reicht.Collect.Status = "Off" return end
    Reicht.Collect.Status = Reicht.Collect.ClaimNow()
end

function Reicht.Collect.GetStatus()
    return Reicht.Options.AutoClaimQuest and Reicht.Collect.Status or "Off"
end

Reicht.Code = {
    Codes = {
        "freecase", "dreamcase", "FREELIKE1", "FREELIKE2", "FREELIKE3", "FREELIKE4", "FREELIKE5",
        "140mvisit", "EASTER2026", "weaponfix", "50mvisit", "3mvisit"
    },
    LastResult = "",
}

function Reicht.Code.RedeemAll()
    local folder = ReplicatedStorage:FindFirstChild("Remote")
    local anyFolder = folder and folder:FindFirstChild("Any")
    local remote = anyFolder and anyFolder:FindFirstChild("Code")
    if not remote then
        Reicht.Code.LastResult = "no code remote"
        return Reicht.Code.LastResult
    end

    local redeemed, skipped = 0, 0
    for _, code in ipairs(Reicht.Code.Codes) do
        local ok, result = pcall(function() return remote:InvokeServer(code) end)
        if ok and result ~= nil and result ~= false and result ~= -2 then
            redeemed += 1
        else
            skipped += 1
        end
        task.wait(0.25)
    end
    Reicht.Code.LastResult = redeemed > 0 and (redeemed .. " codes redeemed") or "All codes already claimed"
    return Reicht.Code.LastResult
end

Reicht.Flag = { Status = "Off" }

function Reicht.Flag.Step()
    if not Reicht.Options.AutoFlag then Reicht.Flag.Status = "Off" return end
    if not Reicht.Match.InRound() then Reicht.Flag.Status = "Waiting round" return end

    local remote = ReplicatedStorage:FindFirstChild("Remote")
    local gameService = remote and remote:FindFirstChild("GameService")
    local gameMode = gameService and gameService:FindFirstChild("GameMode")
    local ffa = gameMode and gameMode:FindFirstChild("FFA")
    local ctf = ffa and ffa:FindFirstChild("FFA_CaptureFlag")
    local pickRemote = ctf and ctf:FindFirstChild("PickFlag")

    if pickRemote then
        pcall(function() pickRemote:FireServer() end)
    end

    local root = Reicht.Player.Root
    if root and root.Parent then
        local CollectionService = game:GetService("CollectionService")
        for _, flagPart in ipairs(CollectionService:GetTagged("CTF_PickFlag_FFA")) do
            if flagPart:IsA("BasePart") and (root.Position - flagPart.Position).Magnitude < 30 then
                firetouchinterest(root, flagPart, 0)
                task.wait(0.05)
                firetouchinterest(root, flagPart, 1)
            end
        end
    end
    Reicht.Flag.Status = "Active"
end

function Reicht.Flag.GetStatus()
    return Reicht.Options.AutoFlag and Reicht.Flag.Status or "Off"
end

Reicht.Combat = { State = "Idle", Status = "Off", Target = nil, Part = nil, Look = nil, Bound = false, LastShot = 0, Circle = nil, OriginFn = nil, OriginParams = nil, LookSource = nil, LookHolders = nil, LockedSince = 0 }

local aimParams = RaycastParams.new()
aimParams.FilterType = Enum.RaycastFilterType.Exclude

function Reicht.Combat.AimActive()
    return Reicht.Options.Aimbot == true
end

function Reicht.Combat.SilentActive()
    return Reicht.Options.SilentAim == true or Reicht.Options.Ragebot == true
end

function Reicht.Combat.Active()
    local opts = Reicht.Options
    return opts.Aimbot or opts.SilentAim or opts.Ragebot or opts.TriggerBot or opts.ShowFov
        or opts.NoRecoil or opts.NoSpread or opts.InstantScope or opts.FullAuto or opts.InstantReload
        or opts.InfiniteAmmo or opts.HitboxExpander or opts.AntiFlash or opts.AntiSmoke
        or opts.AntiAim or opts.KnifeAura or opts.NoScopeOverlay or opts.FastSwitch
end

---@return BasePart?  server hitbox for the chosen bone
function Reicht.Combat.BonePart(entity, bone)
    local char = Reicht.Entity.Character(entity)
    if not char then return nil end
    local collider = char:FindFirstChild("Collider")
    bone = bone or Reicht.Options.AimBone or "Head"
    local bonePart = (collider and (collider:FindFirstChild(bone) or collider:FindFirstChild("Head")))
        or char:FindFirstChild(bone)
        or char:FindFirstChild("Head")
        or Reicht.Entity.Root(entity)
    return bonePart
end

function Reicht.Combat.Filter()
    local cam = Workspace.CurrentCamera
    aimParams.FilterDescendantsInstances = { cam, Reicht.Entity.Character(Reicht.Entity.Local()) }
    return cam
end

---@return CFrame, any  where the game fires bullets from, detect tag
function Reicht.Combat.Origin()
    local originFn = Reicht.Combat.OriginFn
    if not originFn then
        local camCtrl = Reicht.GameLib.CameraController
        originFn = camCtrl and camCtrl.GetCombatOriginFn and camCtrl.GetCombatOriginFn()
        Reicht.Combat.OriginFn = originFn
    end
    if originFn then
        local ok, origin, detect = pcall(originFn)
        if ok and typeof(origin) == "CFrame" then return origin, detect end
    end
    return Workspace.CurrentCamera.CFrame, nil
end

function Reicht.Combat.Visible(part, char)
    Reicht.Combat.Filter()
    local origin = Reicht.Combat.Origin().Position
    local hit = Workspace:Raycast(origin, part.Position - origin, aimParams)
    return hit ~= nil and hit.Instance:IsDescendantOf(char)
end

function Reicht.Combat.IsEnemy(entity)
    if type(entity) ~= "table" or Reicht.Entity.IsLocal(entity) then return false end
    if Reicht.Options.AimTeamCheck and Reicht.Entity.Friendly(entity) then return false end
    local inst = entity.Instance
    if typeof(inst) == "Instance" and inst:GetAttribute("State") == "Dead" then return false end
    return Reicht.Entity.Health(entity) > 0
end

---@return Vector3  part position led by its velocity
function Reicht.Combat.Predict(part)
    local lead = (Reicht.Options.AimPrediction or 0) / 1000
    if lead <= 0 then return part.Position end
    return part.Position + part.AssemblyLinearVelocity * lead
end

---@return Vector2  screen point the FOV circle is centred on
function Reicht.Combat.AimCenter(cam)
    if Reicht.Options.AimPriority == "Mouse" then return UserInputService:GetMouseLocation() end
    return cam.ViewportSize / 2
end

function Reicht.Combat.UsesFov()
    if Reicht.Options.Ragebot then return false end
    local mode = Reicht.Options.AimPriority
    return mode == "Crosshair" or mode == "Mouse"
end

---@return number?  lower is better, nil when the target is filtered out
function Reicht.Combat.Score(entity, part, cam, center, origin)
    local dist = (part.Position - origin).Magnitude
    if dist > Reicht.Options.AimMaxDistance then return nil end

    if Reicht.Combat.UsesFov() then
        local screen, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then return nil end
        local gap = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        if gap > Reicht.Options.AimFov then return nil end
        return gap
    end
    if Reicht.Options.AimPriority == "Health" then
        return Reicht.Entity.Health(entity) * 10000 + dist
    end
    return dist
end

---@return table?, BasePart?  best target for the chosen priority mode
function Reicht.Combat.SelectTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local center = Reicht.Combat.AimCenter(cam)
    local origin = cam.CFrame.Position
    local best, bestPart, bestScore

    for _, entity in pairs(Reicht.Entity.List()) do
        if not Reicht.Combat.IsEnemy(entity) then continue end
        local part = Reicht.Combat.BonePart(entity)
        if not part then continue end
        local score = Reicht.Combat.Score(entity, part, cam, center, origin)
        if not score or (bestScore and score >= bestScore) then continue end
        if Reicht.Options.AimWallCheck and not Reicht.Combat.Visible(part, Reicht.Entity.Character(entity)) then continue end
        best, bestPart, bestScore = entity, part, score
    end
    return best, bestPart
end

function Reicht.Combat.BindCamera()
    if Reicht.Combat.Bound then return end
    Reicht.Combat.Bound = true
    RunService:BindToRenderStep("ReichtAim", Reicht.Config.AimRenderPriority, function()
        local cam = Workspace.CurrentCamera
        local part = Reicht.Combat.Part
        if not (Reicht.Combat.AimActive() and part and part.Parent) then
            Reicht.Combat.Look = nil
            return
        end
        local origin = cam.CFrame.Position
        local want = (Reicht.Combat.Predict(part) - origin).Unit
        local smooth = math.max(Reicht.Options.AimSmooth or 1, 1)
        local look = Reicht.Combat.Look or cam.CFrame.LookVector
        look = smooth <= 1 and want or look:Lerp(want, 1 / smooth).Unit
        Reicht.Combat.Look = look
        cam.CFrame = CFrame.lookAt(origin, origin + look)
    end)
end

function Reicht.Combat.UnbindCamera()
    if not Reicht.Combat.Bound then return end
    Reicht.Combat.Bound = false
    RunService:UnbindFromRenderStep("ReichtAim")
end

---@return boolean  crosshair currently on an enemy hitbox
function Reicht.Combat.CrosshairOnEnemy()
    Reicht.Combat.Filter()
    local origin = Reicht.Combat.Origin()
    local hit = Workspace:Raycast(origin.Position, origin.LookVector * Reicht.Config.TriggerRange, aimParams)
    if not hit then return false end
    for _, entity in pairs(Reicht.Entity.List()) do
        local char = Reicht.Entity.Character(entity)
        if char and hit.Instance:IsDescendantOf(char) then return Reicht.Combat.IsEnemy(entity) end
    end
    return false
end

function Reicht.Combat.TriggerFastSwitch()
    local combat = Reicht.GameLib.Service.CombatService
    if not combat or type(combat.SwitchSlot) ~= "function" then return end
    task.spawn(function()
        combat.SwitchSlot("Secondary")
        task.wait(0.02)
        combat.SwitchSlot("Primary")
    end)
end

---@return boolean  true when the weapon accepted the shot
function Reicht.Combat.Fire()
    local weapon, shooter = Reicht.Combat.Shooter()
    if not shooter or not weapon then return false end

    if weapon.CanActionNow and not weapon:CanActionNow() then return false end

    local now = os.clock()
    local rate = (weapon.GetCurrentAttackRate and weapon:GetCurrentAttackRate()) or (weapon.GetAttackRate and weapon:GetAttackRate()) or 0.8
    local baseInterval = 1 / math.max(rate, 0.1)
    local interval = math.max(baseInterval, Reicht.Config.FireInterval)

    if now - Reicht.Combat.LastShot < interval then return false end
    Reicht.Combat.LastShot = now

    local ok, fired = pcall(shooter.LocalShoot, shooter)
    if not ok then warn("[SniperArena] shoot:", fired) end

    if ok and fired ~= nil and Reicht.Options.FastSwitch then
        Reicht.Combat.TriggerFastSwitch()
    end

    return ok and fired ~= nil
end

function Reicht.Combat.Shooter()
    local combat = Reicht.GameLib.Service.CombatService
    local weapon = combat and combat.GetCurrentWeapon()
    return weapon, weapon and weapon._Shootable
end

Reicht.Combat.SilentSaved = setmetatable({}, { __mode = "k" })

---@return table?  the game's combat-origin override table
function Reicht.Combat.OriginOverride()
    if Reicht.Combat.OriginParams ~= nil then return Reicht.Combat.OriginParams or nil end
    if not Reicht.Caps.Upvalues then return nil end
    local camCtrl = Reicht.GameLib.CameraController
    local ok, holder = pcall(function() return Util.GetUpvalue(camCtrl.GetCombatOriginFn(), 1) end)
    local params = ok and type(holder) == "table" and type(holder.TempParams) == "table" and holder.TempParams
    Reicht.Combat.OriginParams = params or false
    return params or nil
end

---@return any  what the game's Shoot returns
function Reicht.Combat.ShootAt(shooter, entity, part, opts)
    local params = Reicht.Combat.OriginOverride()
    local start = Reicht.Combat.Origin().Position
    local aim = Reicht.Combat.Predict(part)
    opts = type(opts) == "table" and opts or {}
    opts.Target = entity.Instance
    opts.TargetHeadshot = part.Name == "Head" or nil
    local ok, localPos = pcall(function() return entity:GetPivot(true):PointToObjectSpace(aim) end)
    if ok then opts.TargetPos = localPos end

    local saved = { params.CameraCFrame, params.SubjectDistance, params.MouseLockOffset }
    params.CameraCFrame, params.SubjectDistance, params.MouseLockOffset = CFrame.lookAt(start, aim), 0, Vector3.zero
    local fired, shot = pcall(shooter.Shoot, shooter, start, (aim - start).Unit, opts)
    params.CameraCFrame, params.SubjectDistance, params.MouseLockOffset = saved[1], saved[2], saved[3]
    if not fired then warn("[SniperArena] silent:", shot) end
    return fired and shot or nil
end

---@return any, BasePart?  entity and bone when crosshair hits an enemy (including expanded hitbox)
function Reicht.Combat.FindHitboxTarget()
    local camCtrl = Reicht.GameLib.CameraController
    local targetingFn = camCtrl and camCtrl.GetTargetingFn and camCtrl.GetTargetingFn()
    if targetingFn then
        local ok, _, inst = pcall(targetingFn)
        if ok and inst and inst:IsA("BasePart") then
            for _, entity in pairs(Reicht.Entity.List()) do
                if Reicht.Entity.IsLocal(entity) or Reicht.Entity.Friendly(entity) then continue end
                local char = Reicht.Entity.Character(entity)
                if char and inst:IsDescendantOf(char) then
                    local bone = (inst.Name == "Head" or Reicht.Options.HitboxPart == "Head") and "Head" or "Body"
                    local realBone = Reicht.Combat.BonePart(entity, bone)
                    return entity, realBone
                end
            end
        end
    end

    local origin = Reicht.Combat.Origin()
    local cam = Workspace.CurrentCamera
    local start = origin.Position
    local dir = origin.LookVector * 1000

    local params = RaycastParams.new()
    params.RespectCanCollide = false
    params.CollisionGroup = "LookDet"
    local localChar = Reicht.Entity.Character(Reicht.Entity.Local())
    params.FilterDescendantsInstances = localChar and { cam, localChar } or { cam }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local hit = Workspace:Raycast(start, dir, params)
    if not hit or not hit.Instance then return nil, nil end

    for _, entity in pairs(Reicht.Entity.List()) do
        if Reicht.Entity.IsLocal(entity) or Reicht.Entity.Friendly(entity) then continue end
        local char = Reicht.Entity.Character(entity)
        if char and hit.Instance:IsDescendantOf(char) then
            local bone = (hit.Instance.Name == "Head" or Reicht.Options.HitboxPart == "Head") and "Head" or "Body"
            local realBone = Reicht.Combat.BonePart(entity, bone)
            return entity, realBone
        end
    end
    return nil, nil
end

function Reicht.Combat.ApplyActionHook()
    local combat = Reicht.GameLib.Service.CombatService
    if not combat or Reicht.Combat.OldInvokeAction or combat.InvokeAction == Reicht.Combat.ActionHook then return end
    Reicht.Combat.OldInvokeAction = combat.InvokeAction
    combat.InvokeAction = Reicht.Combat.ActionHook
end

function Reicht.Combat.ActionHook(weap, action, args)
    if action == "Shoot" and type(args) == "table" and args.Target then
        args.CustomStart = nil
        args.CustomFPStart = nil
        local targetChar = args.Target
        local col = targetChar:FindFirstChild("Collider")
        local head = (col and col:FindFirstChild("Head")) or targetChar:FindFirstChild("Head")
        local aimPos = head and head.Position or targetChar:GetPivot().Position
        args.Direction = (aimPos - args.Start).Unit
        local ok, localPos = pcall(function() return targetChar:GetPivot():PointToObjectSpace(aimPos) end)
        if ok then args.TargetPos = localPos end
        if head then args.TargetHeadshot = true end
    end
    local old = Reicht.Combat.OldInvokeAction
    if old and old ~= Reicht.Combat.ActionHook then
        return old(weap, action, args)
    end
    return nil
end

function Reicht.Combat.RestoreActionHook()
    local combat = Reicht.GameLib.Service.CombatService
    local old = Reicht.Combat.OldInvokeAction
    if combat and old then
        combat.InvokeAction = old
        Reicht.Combat.OldInvokeAction = nil
    end
end

---@return any  same as the game's LocalShoot, bullet sent at the locked target or expanded hitbox
function Reicht.Combat.SilentShoot(shooter, opts)
    local saved = Reicht.Combat.SilentSaved[shooter]
    if not saved then return end

    if Reicht.Combat.SilentActive() and Reicht.Combat.Target and Reicht.Combat.OriginOverride() then
        if math.random(100) <= Reicht.Options.HitChance then
            local bone = math.random(100) <= Reicht.Options.HeadChance and "Head" or "Body"
            local part = Reicht.Combat.BonePart(Reicht.Combat.Target, bone)
            if part and part.Parent then
                return Reicht.Combat.ShootAt(shooter, Reicht.Combat.Target, part, opts)
            end
        end
    end

    if Reicht.Options.HitboxExpander and Reicht.Combat.OriginOverride() then
        local targetEnt, targetPart = Reicht.Combat.FindHitboxTarget()
        if targetEnt and targetPart then
            return Reicht.Combat.ShootAt(shooter, targetEnt, targetPart, opts)
        end
    end

    return saved.Fn(shooter, opts)
end

---@return CFrame  camera the server is told we look through
function Reicht.Combat.ReportedLook(...)
    local look = Reicht.Combat.LookSource(...)
    local part = Reicht.Combat.Part
    if typeof(look) ~= "CFrame" or not (Reicht.Combat.SilentActive() and Reicht.Combat.Target and part and part.Parent) then return look end
    return CFrame.lookAt(look.Position, Reicht.Combat.Predict(part))
end

---@return table[]  tables that really hold CameraController's functions
function Reicht.Combat.LookTables()
    local camCtrl = Reicht.GameLib.CameraController
    local tables = {}
    if type(camCtrl) ~= "table" then return tables end
    if rawget(camCtrl, "GetCFrame") and not table.isfrozen(camCtrl) then tables[1] = camCtrl end
    local meta = Util.GetRawMetatable and Util.GetRawMetatable(camCtrl)
    local index = type(meta) == "table" and rawget(meta, "__index")
    if type(index) == "table" then index = { index } elseif type(index) == "function" and Util.GetUpvalues then index = Util.GetUpvalues(index) else index = {} end
    for _, holder in pairs(index) do
        if type(holder) == "table" and type(rawget(holder, "GetCFrame")) == "function" and not table.isfrozen(holder) then
            tables[#tables + 1] = holder
        end
    end
    return tables
end

function Reicht.Combat.ApplyLook()
    if Reicht.Combat.LookSource ~= nil then return end
    local tables = Reicht.Combat.LookTables()
    if #tables == 0 then
        Reicht.Combat.LookSource = false
        return
    end
    Reicht.Combat.LookSource = rawget(tables[1], "GetCFrame")
    Reicht.Combat.LookHolders = tables
    for _, holder in ipairs(tables) do rawset(holder, "GetCFrame", Reicht.Combat.ReportedLook) end
end

function Reicht.Combat.RestoreLook()
    local source = Reicht.Combat.LookSource
    if not source then
        Reicht.Combat.LookSource = nil
        return
    end
    for _, holder in ipairs(Reicht.Combat.LookHolders or {}) do
        if rawget(holder, "GetCFrame") == Reicht.Combat.ReportedLook then rawset(holder, "GetCFrame", source) end
    end
    Reicht.Combat.LookSource, Reicht.Combat.LookHolders = nil, nil
end

function Reicht.Combat.ApplySilent()
    local _, shooter = Reicht.Combat.Shooter()
    if type(shooter) ~= "table" or rawget(shooter, "LocalShoot") == Reicht.Combat.SilentShoot then return end
    if type(shooter.Shoot) ~= "function" then return end
    Reicht.Combat.SilentSaved[shooter] = { Raw = rawget(shooter, "LocalShoot"), Fn = shooter.LocalShoot }
    rawset(shooter, "LocalShoot", Reicht.Combat.SilentShoot)
end

function Reicht.Combat.RestoreSilent()
    for shooter, saved in pairs(Reicht.Combat.SilentSaved) do
        rawset(shooter, "LocalShoot", saved.Raw)
    end
    table.clear(Reicht.Combat.SilentSaved)
end

Reicht.Combat.ScopeSaved = setmetatable({}, { __mode = "k" })

function Reicht.Combat.ApplyInstantScope()
    local weapon = Reicht.Combat.Shooter()
    local cfg = weapon and weapon.Config
    if type(cfg) ~= "table" or rawget(cfg, "AimTime") == 0 then return end
    if not Reicht.Combat.ScopeSaved[cfg] then
        Reicht.Combat.ScopeSaved[cfg] = { rawget(cfg, "AimTime"), rawget(cfg, "DelayTime") }
    end
    rawset(cfg, "AimTime", 0)
    rawset(cfg, "DelayTime", 0)
end

function Reicht.Combat.RestoreScope()
    for cfg, saved in pairs(Reicht.Combat.ScopeSaved) do
        rawset(cfg, "AimTime", saved[1])
        rawset(cfg, "DelayTime", saved[2])
    end
    table.clear(Reicht.Combat.ScopeSaved)
end

Reicht.Combat.AutoSaved = setmetatable({}, { __mode = "k" })

function Reicht.Combat.ApplyFullAuto()
    local weapon = Reicht.Combat.Shooter()
    local cfg = weapon and weapon.Config
    if type(cfg) ~= "table" or rawget(cfg, "FullAuto") == true then return end
    if Reicht.Combat.AutoSaved[cfg] == nil then
        Reicht.Combat.AutoSaved[cfg] = rawget(cfg, "FullAuto") or false
    end
    rawset(cfg, "FullAuto", true)
end

function Reicht.Combat.RestoreFullAuto()
    for cfg, saved in pairs(Reicht.Combat.AutoSaved) do
        rawset(cfg, "FullAuto", saved)
    end
    table.clear(Reicht.Combat.AutoSaved)
end

Reicht.Combat.ReloadSaved = setmetatable({}, { __mode = "k" })

function Reicht.Combat.ApplyInstantReload()
    local weapon = Reicht.Combat.Shooter()
    local cfg = weapon and weapon.Config
    if type(cfg) ~= "table" or rawget(cfg, "ReloadTime") == 0.01 then return end
    if not Reicht.Combat.ReloadSaved[cfg] then
        Reicht.Combat.ReloadSaved[cfg] = {
            rawget(cfg, "ReloadTime"),
            rawget(cfg, "ReloadFinishTime"),
            rawget(cfg, "ReloadTimeEmpty"),
        }
    end
    rawset(cfg, "ReloadTime", 0.01)
    rawset(cfg, "ReloadFinishTime", 0.01)
    rawset(cfg, "ReloadTimeEmpty", 0.01)
end

function Reicht.Combat.RestoreInstantReload()
    for cfg, saved in pairs(Reicht.Combat.ReloadSaved) do
        rawset(cfg, "ReloadTime", saved[1])
        rawset(cfg, "ReloadFinishTime", saved[2])
        rawset(cfg, "ReloadTimeEmpty", saved[3])
    end
    table.clear(Reicht.Combat.ReloadSaved)
end

Reicht.Combat.AntiAimHooked = false
Reicht.Combat.OriginalPitchYawInvoke = nil

function Reicht.Combat.ApplyAntiAim()
    if Reicht.Combat.AntiAimHooked then return end
    local service = Reicht.GameLib.Service.EntityService
    local py = service and service.Common and service.Common.Network and service.Common.Network.Packets
        and service.Common.Network.Packets.queries and service.Common.Network.Packets.queries.PitchYaw
    if not py or type(py.invoke) ~= "function" then return end

    Reicht.Combat.OriginalPitchYawInvoke = py.invoke
    Reicht.Combat.AntiAimHooked = true

    py.invoke = function(data)
        if Reicht.Options.AntiAim and type(data) == "table" and data.Yaw ~= nil then
            local mode = Reicht.Options.AntiAimMode or "Spinbot"
            if mode == "Spinbot" then
                local speed = tonumber(Reicht.Options.SpinSpeed) or 1080
                data.Yaw = (os.clock() * speed) % 360
                data.Pitch = -85
            elseif mode == "Jitter" then
                data.Yaw = ((data.Yaw or 0) + (math.random(0, 1) == 0 and 90 or -90)) % 360
                data.Pitch = math.random(-85, 85)
            end
        end
        return Reicht.Combat.OriginalPitchYawInvoke(data)
    end
end

function Reicht.Combat.RestoreAntiAim()
    if not Reicht.Combat.AntiAimHooked then return end
    local service = Reicht.GameLib.Service.EntityService
    local py = service and service.Common and service.Common.Network and service.Common.Network.Packets
        and service.Common.Network.Packets.queries and service.Common.Network.Packets.queries.PitchYaw
    if py and Reicht.Combat.OriginalPitchYawInvoke then
        py.invoke = Reicht.Combat.OriginalPitchYawInvoke
    end
    Reicht.Combat.OriginalPitchYawInvoke = nil
    Reicht.Combat.AntiAimHooked = false
end

function Reicht.Combat.StepKnifeAura()
    if not Reicht.Options.KnifeAura then return end
    local combat = Reicht.GameLib.Service.CombatService
    local localEnt = Reicht.Entity.Local()
    if not combat or not localEnt then return end

    local cont = combat.GetCombatDataContainer(localEnt)
    local secondary = cont and cont.Weapons and cont.Weapons["Secondary"]
    local melee = secondary and secondary._Meleeable
    if not melee or not melee:CanMelee() or not melee:CanMeleeNow() then return end

    local myRoot = Reicht.Entity.Root(localEnt)
    local myPos = myRoot and myRoot.Position
    if not myPos then return end

    local range = tonumber(Reicht.Options.KnifeAuraRange) or 16
    local foundEnemy = false

    for _, entity in pairs(Reicht.Entity.List()) do
        if Reicht.Entity.IsLocal(entity) or Reicht.Entity.Friendly(entity) then continue end
        local health = Reicht.Entity.Health(entity)
        if health <= 0 then continue end
        local root = Reicht.Entity.Root(entity)
        if root and (root.Position - myPos).Magnitude <= range then
            foundEnemy = true
            break
        end
    end

    if foundEnemy then
        pcall(melee.Melee, melee)
    end
end

Reicht.Combat.ScopeOverlaySaved = nil

function Reicht.Combat.ApplyNoScopeOverlay()
    local settingsMod = Reicht.GameLib.Settings
    local cfg = Reicht.GameLib.Config and Reicht.GameLib.Config.Config
    if settingsMod and settingsMod.ScopeOverlay and Reicht.Combat.ScopeOverlaySaved == nil then
        Reicht.Combat.ScopeOverlaySaved = settingsMod.ScopeOverlay.Value
        settingsMod.ScopeOverlay.Value = false
    end
    if cfg then
        cfg.KeepCrosshairInAim = true
    end
end

function Reicht.Combat.RestoreNoScopeOverlay()
    local settingsMod = Reicht.GameLib.Settings
    if settingsMod and settingsMod.ScopeOverlay and Reicht.Combat.ScopeOverlaySaved ~= nil then
        settingsMod.ScopeOverlay.Value = Reicht.Combat.ScopeOverlaySaved
        Reicht.Combat.ScopeOverlaySaved = nil
    end
end

Reicht.Combat.FlashSaved = nil
Reicht.Combat.SmokeSaved = nil

function Reicht.Combat.ApplyAntiFlash()
    local effects = Reicht.GameLib.Effects
    local flash = effects and effects.Flash
    if not (flash and hookfunction and not Reicht.Combat.FlashSaved) then return end
    Reicht.Combat.FlashSaved = {
        Flash = flash.Flash,
        GetAlpha = flash.GetFlashingAlpha,
    }
    hookfunction(flash.Flash, function() end)
    hookfunction(flash.GetFlashingAlpha, function() return 0 end)
    local Lighting = game:GetService("Lighting")
    if Lighting then Lighting.ExposureCompensation = 0 end
end

function Reicht.Combat.RestoreAntiFlash()
    if not Reicht.Combat.FlashSaved then return end
    local effects = Reicht.GameLib.Effects
    local flash = effects and effects.Flash
    if flash and restorefunction then
        pcall(restorefunction, flash.Flash)
        pcall(restorefunction, flash.GetFlashingAlpha)
    end
    Reicht.Combat.FlashSaved = nil
end

function Reicht.Combat.ApplyAntiSmoke()
    local effects = Reicht.GameLib.Effects
    local smoke = effects and effects.Smoke
    if not (smoke and hookfunction and not Reicht.Combat.SmokeSaved) then return end
    Reicht.Combat.SmokeSaved = {
        InSmoke = smoke.InSmoke,
        PosInSmoke = smoke.PosInSmoke,
    }
    hookfunction(smoke.InSmoke, function() return false end)
    hookfunction(smoke.PosInSmoke, function() return false end)
end

function Reicht.Combat.RestoreAntiSmoke()
    if not Reicht.Combat.SmokeSaved then return end
    local effects = Reicht.GameLib.Effects
    local smoke = effects and effects.Smoke
    if smoke and restorefunction then
        pcall(restorefunction, smoke.InSmoke)
        pcall(restorefunction, smoke.PosInSmoke)
    end
    Reicht.Combat.SmokeSaved = nil
end

Reicht.Combat.AmmoSaved = setmetatable({}, { __mode = "k" })

function Reicht.Combat.ApplyInfiniteAmmo()
    local weapon = Reicht.Combat.Shooter()
    local ammo = weapon and weapon._Ammo
    if type(ammo) ~= "table" or rawget(ammo, "InfAmmo") == true then return end
    if not Reicht.Combat.AmmoSaved[ammo] then
        Reicht.Combat.AmmoSaved[ammo] = { rawget(ammo, "InfAmmo"), rawget(ammo, "InfAmmoStore") }
    end
    rawset(ammo, "InfAmmo", true)
    rawset(ammo, "InfAmmoStore", true)
end

function Reicht.Combat.RestoreInfiniteAmmo()
    for ammo, saved in pairs(Reicht.Combat.AmmoSaved) do
        rawset(ammo, "InfAmmo", saved[1])
        rawset(ammo, "InfAmmoStore", saved[2])
    end
    table.clear(Reicht.Combat.AmmoSaved)
end

function Reicht.Combat.ApplyAsyncPatch()
    if Reicht.Combat.AsyncPatched then return end
    local asyncMod = ReplicatedStorage:FindFirstChild("Common") and ReplicatedStorage.Common:FindFirstChild("AsyncService")
    local asyncRaycast = asyncMod and asyncMod:FindFirstChild("AsyncRaycast")
    if not asyncRaycast then return end
    local ok, rayLib = pcall(require, asyncRaycast)
    if not (ok and type(rayLib) == "table") then return end

    Reicht.Combat.AsyncPatched = true
    Reicht.Combat.OrigAsyncRaycast = rayLib.Raycast
    rayLib.Raycast = function(origin, dir, params, ...)
        local succ, res = pcall(Reicht.Combat.OrigAsyncRaycast, origin, dir, params, ...)
        if succ and res ~= nil then return res end
        return Workspace:Raycast(origin, dir, params)
    end
end

function Reicht.Combat.RestoreAsyncPatch()
    if not Reicht.Combat.AsyncPatched then return end
    local asyncMod = ReplicatedStorage:FindFirstChild("Common") and ReplicatedStorage.Common:FindFirstChild("AsyncService")
    local asyncRaycast = asyncMod and asyncMod:FindFirstChild("AsyncRaycast")
    if asyncRaycast and Reicht.Combat.OrigAsyncRaycast then
        local ok, rayLib = pcall(require, asyncRaycast)
        if ok and type(rayLib) == "table" then
            rayLib.Raycast = Reicht.Combat.OrigAsyncRaycast
        end
    end
    Reicht.Combat.OrigAsyncRaycast = nil
    Reicht.Combat.AsyncPatched = false
end

Reicht.Combat.HitboxSaved = {}

function Reicht.Combat.ApplyHitbox()
    if not Reicht.Options.HitboxExpander then
        if next(Reicht.Combat.HitboxSaved) then
            Reicht.Combat.RestoreHitbox()
        end
        return
    end

    local size = math.clamp(tonumber(Reicht.Options.HitboxSize) or 8, 2, 20)
    local targetSize = Vector3.new(size, size, size)
    local partChoice = Reicht.Options.HitboxPart or "Head"
    local trans = tonumber(Reicht.Options.HitboxTransparency) or 0.6

    for _, entity in pairs(Reicht.Entity.List()) do
        if Reicht.Entity.IsLocal(entity) or Reicht.Entity.Friendly(entity) then continue end
        local health = Reicht.Entity.Health(entity)
        if health <= 0 then continue end
        local char = Reicht.Entity.Character(entity)
        if not char then continue end

        local col = char:FindFirstChild("Collider")
        local partsToExpand = {}

        if partChoice == "Head" or partChoice == "Both" then
            local head = (col and col:FindFirstChild("Head")) or char:FindFirstChild("Head")
            if head and head:IsA("BasePart") then partsToExpand[#partsToExpand + 1] = head end
        end

        if partChoice == "RootPart" or partChoice == "Both" then
            local hrp = (col and col:FindFirstChild("HumanoidRootPart")) or char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then partsToExpand[#partsToExpand + 1] = hrp end
        end

        for _, part in ipairs(partsToExpand) do
            if not Reicht.Combat.HitboxSaved[part] then
                Reicht.Combat.HitboxSaved[part] = {
                    Size = part.Size,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide,
                    CanQuery = part.CanQuery,
                }
            end
            part.Size = targetSize
            part.CanCollide = false
            part.CanQuery = true
            part.Transparency = trans
        end
    end
end

function Reicht.Combat.RestoreHitbox()
    for part, saved in pairs(Reicht.Combat.HitboxSaved) do
        if part and part.Parent then
            part.Size = saved.Size
            part.Transparency = saved.Transparency
            part.CanCollide = saved.CanCollide
            part.CanQuery = saved.CanQuery
        end
    end
    table.clear(Reicht.Combat.HitboxSaved)
end

---@return table  { Drawing = circle }, or { Frame = ring } as a Gui circle when Drawing is missing
function Reicht.Combat.MakeCircle()
    local color = Reicht.Config.FovColor
    if Reicht.Caps.Drawing then
        local circle = Drawing.new("Circle")
        circle.Thickness, circle.NumSides, circle.Filled = 1.5, 64, false
        circle.Color = color
        return { Drawing = circle }
    end

    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.5
    stroke.Parent = ring
    ring.Parent = Util.Overlay()
    return { Frame = ring }
end

function Reicht.Combat.SetCircleVisible(visible)
    local circle = Reicht.Combat.Circle
    if not circle then return end
    if circle.Drawing then circle.Drawing.Visible = visible else circle.Frame.Visible = visible end
end

function Reicht.Combat.UpdateCircle()
    if not Reicht.Options.ShowFov then
        Reicht.Combat.SetCircleVisible(false)
        return
    end
    local circle = Reicht.Combat.Circle
    if not circle then
        circle = Reicht.Combat.MakeCircle()
        Reicht.Combat.Circle = circle
    end

    local center = Reicht.Combat.AimCenter(Workspace.CurrentCamera)
    local radius = Reicht.Options.AimFov
    if circle.Drawing then
        circle.Drawing.Position, circle.Drawing.Radius, circle.Drawing.Visible = center, radius, true
        return
    end
    circle.Frame.Position = UDim2.fromOffset(center.X, center.Y)
    circle.Frame.Size = UDim2.fromOffset(radius * 2, radius * 2)
    circle.Frame.Visible = true
end

function Reicht.Combat.DrawCircle()
    local ok, err = pcall(Reicht.Combat.UpdateCircle)
    if ok then
        Reicht.Faults.Clear("FOV circle")
    else
        Reicht.Faults.Report("FOV circle", err, { "ShowFov" })
    end
end

Reicht.Combat.RecoilSaved = setmetatable({}, { __mode = "k" })
Reicht.Combat.ZoomSaved = setmetatable({}, { __mode = "k" })

function Reicht.Combat.ApplyNoRecoil()
    local weapon = Reicht.Combat.Shooter()
    local cfg = weapon and weapon.Config
    if type(cfg) ~= "table" then return end
    if type(cfg.RecoilZoom) == "number" and cfg.RecoilZoom ~= 0 then
        Reicht.Combat.ZoomSaved[cfg] = Reicht.Combat.ZoomSaved[cfg] or cfg.RecoilZoom
        cfg.RecoilZoom = 0
    end
    for _, key in ipairs({ "Recoil", "RecoilAiming" }) do
        local recoil = cfg[key]
        if type(recoil) == "table" and recoil.Degree ~= 0 then
            if Reicht.Combat.RecoilSaved[recoil] == nil then Reicht.Combat.RecoilSaved[recoil] = recoil.Degree end
            recoil.Degree = 0
        end
    end
end

Reicht.Combat.SpreadSaved = setmetatable({}, { __mode = "k" })

function Reicht.Combat.ZeroSpread()
    return 0
end

function Reicht.Combat.ApplyNoSpread()
    local _, shooter = Reicht.Combat.Shooter()
    if type(shooter) ~= "table" or rawget(shooter, "GetCurrentSpread") == Reicht.Combat.ZeroSpread then return end
    Reicht.Combat.SpreadSaved[shooter] = { rawget(shooter, "GetCurrentSpread") }
    rawset(shooter, "GetCurrentSpread", Reicht.Combat.ZeroSpread)
end

function Reicht.Combat.RestoreSpread()
    for shooter, original in pairs(Reicht.Combat.SpreadSaved) do
        rawset(shooter, "GetCurrentSpread", original[1])
    end
    table.clear(Reicht.Combat.SpreadSaved)
end

function Reicht.Combat.RestoreRecoil()
    for recoil, degree in pairs(Reicht.Combat.RecoilSaved) do recoil.Degree = degree end
    for cfg, zoom in pairs(Reicht.Combat.ZoomSaved) do cfg.RecoilZoom = zoom end
    table.clear(Reicht.Combat.RecoilSaved)
    table.clear(Reicht.Combat.ZoomSaved)
end

function Reicht.Combat.Patches()
    if not Reicht.State.Alive then return end
    local opts = Reicht.Options

    if opts.NoRecoil then
        Reicht.Combat.ApplyNoRecoil()
    elseif next(Reicht.Combat.RecoilSaved) or next(Reicht.Combat.ZoomSaved) then
        Reicht.Combat.RestoreRecoil()
    end
    if opts.NoSpread then
        Reicht.Combat.ApplyNoSpread()
    elseif next(Reicht.Combat.SpreadSaved) then
        Reicht.Combat.RestoreSpread()
    end
    if opts.InstantScope or opts.Ragebot or opts.SilentAim then
        Reicht.Combat.ApplyInstantScope()
    elseif next(Reicht.Combat.ScopeSaved) then
        Reicht.Combat.RestoreScope()
    end
    if opts.FullAuto then
        Reicht.Combat.ApplyFullAuto()
    elseif next(Reicht.Combat.AutoSaved) then
        Reicht.Combat.RestoreFullAuto()
    end
    if opts.InstantReload then
        Reicht.Combat.ApplyInstantReload()
    elseif next(Reicht.Combat.ReloadSaved) then
        Reicht.Combat.RestoreInstantReload()
    end
    if opts.InfiniteAmmo then
        Reicht.Combat.ApplyInfiniteAmmo()
    elseif next(Reicht.Combat.AmmoSaved) then
        Reicht.Combat.RestoreInfiniteAmmo()
    end
    Reicht.Combat.ApplyHitbox()
    if opts.AntiFlash then
        Reicht.Combat.ApplyAntiFlash()
    elseif Reicht.Combat.FlashSaved then
        Reicht.Combat.RestoreAntiFlash()
    end
    if opts.AntiSmoke then
        Reicht.Combat.ApplyAntiSmoke()
    elseif Reicht.Combat.SmokeSaved then
        Reicht.Combat.RestoreAntiSmoke()
    end
    if opts.AntiAim then
        Reicht.Combat.ApplyAntiAim()
    elseif Reicht.Combat.AntiAimHooked then
        Reicht.Combat.RestoreAntiAim()
    end
    if opts.NoScopeOverlay then
        Reicht.Combat.ApplyNoScopeOverlay()
    elseif Reicht.Combat.ScopeOverlaySaved ~= nil then
        Reicht.Combat.RestoreNoScopeOverlay()
    end
    Reicht.Combat.ApplyAsyncPatch()

    if Reicht.Combat.SilentActive() or opts.HitboxExpander or opts.Ragebot or opts.TriggerBot then
        Reicht.Combat.ApplySilent()
        Reicht.Combat.ApplyLook()
        Reicht.Combat.ApplyActionHook()
        return
    end
    if next(Reicht.Combat.SilentSaved) then Reicht.Combat.RestoreSilent() end
    Reicht.Combat.RestoreLook()
    Reicht.Combat.RestoreActionHook()
end

function Reicht.Combat.Aim(mode)
    local target, part = Reicht.Combat.SelectTarget()
    if target ~= Reicht.Combat.Target then Reicht.Combat.LockedSince = os.clock() end
    Reicht.Combat.Target, Reicht.Combat.Part = target, part
    Reicht.Combat.State = target and "Locked" or "Acquire"
    local char = target and Reicht.Entity.Character(target)
    Reicht.Combat.Status = mode .. " · " .. (char and char.Name or "no target")
end

function Reicht.Combat.Step()
    Reicht.Combat.Patches()
    Reicht.Combat.StepKnifeAura()
    if not Reicht.Combat.Active() then
        if Reicht.Combat.State ~= "Idle" then Reicht.Combat.Stop() end
        return
    end
    if not Reicht.Match.InRound() then
        Reicht.Combat.Target, Reicht.Combat.Part = nil, nil
        Reicht.Combat.State, Reicht.Combat.Status = "Wait", "Waiting for round"
        return
    end

    local mode = Reicht.Match.Info() or "?"
    if Reicht.Combat.AimActive() then Reicht.Combat.BindCamera() else Reicht.Combat.UnbindCamera() end
    if Reicht.Combat.AimActive() or Reicht.Combat.SilentActive() then
        Reicht.Combat.Aim(mode)
    else
        Reicht.Combat.Target, Reicht.Combat.Part = nil, nil
        Reicht.Combat.State, Reicht.Combat.Status = "Ready", mode .. " · aim idle"
    end

    local settled = Reicht.Combat.Target ~= nil and os.clock() - Reicht.Combat.LockedSince >= Reicht.Config.LookSettle
    local shoot = (Reicht.Options.Ragebot and settled) or (Reicht.Options.TriggerBot and Reicht.Combat.CrosshairOnEnemy())
    if shoot and Reicht.Combat.Fire() then Reicht.Combat.State = "Fired" end
end

function Reicht.Combat.Stop()
    Reicht.Combat.UnbindCamera()
    Reicht.Combat.Target, Reicht.Combat.Part = nil, nil
    Reicht.Combat.State, Reicht.Combat.Status = "Idle", "Off"
end

function Reicht.Combat.Rest()
    local undo = {
        Reicht.Combat.Stop, Reicht.Combat.RestoreRecoil, Reicht.Combat.RestoreSpread,
        Reicht.Combat.RestoreScope, Reicht.Combat.RestoreSilent, Reicht.Combat.RestoreLook,
        Reicht.Combat.RestoreFullAuto, Reicht.Combat.RestoreInstantReload,
        Reicht.Combat.RestoreInfiniteAmmo, Reicht.Combat.RestoreHitbox,
        Reicht.Combat.RestoreAntiFlash, Reicht.Combat.RestoreAntiSmoke,
        Reicht.Combat.RestoreAntiAim, Reicht.Combat.RestoreNoScopeOverlay,
        Reicht.Combat.RestoreActionHook, Reicht.Combat.RestoreAsyncPatch,
    }
    for _, restore in ipairs(undo) do
        Util.Try("combat restore", restore)
    end
end

function Reicht.Combat.Unload()
    Reicht.Combat.Rest()
    local circle = Reicht.Combat.Circle
    Reicht.Combat.Circle = nil
    if not circle then return end
    if circle.Frame then
        circle.Frame:Destroy()
    else
        pcall(function() circle.Drawing:Remove() end)
    end
end

function Reicht.Combat.GetStatus()
    return Reicht.Combat.Status
end

Reicht.Skin = {
    Catalog = {},
    Types = {},
    Rarities = {},
    Labels = {},
    Images = {},
    Colors = {},
    Chosen = {},
    Saved = setmetatable({}, { __mode = "k" }),
    Status = "Off",
    RarityRank = { Common = 1, UnCommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mystic = 6 },
    Hidden = { Charm = true },
}

---@return string?, string?  weapon type and family, nil for non-weapons
function Reicht.Skin.Classify(cfg)
    if type(cfg) ~= "table" then return nil end
    local ok, kind, family = pcall(function() return cfg.WeaponType, cfg.Family end)
    if not ok or type(kind) ~= "string" or type(family) ~= "string" then return nil end
    if Reicht.Skin.Hidden[kind] or family:find("^Base") then return nil end
    return kind, family
end

do
    local configs = Reicht.GameLib.Config.WeaponConfig or {}
    for key, cfg in pairs(configs) do
        if type(key) ~= "string" then continue end
        local kind, family = Reicht.Skin.Classify(cfg)
        if not kind then continue end
        local byFamily = Reicht.Skin.Catalog[kind]
        if not byFamily then
            byFamily = {}
            Reicht.Skin.Catalog[kind] = byFamily
            table.insert(Reicht.Skin.Types, kind)
        end
        byFamily[family] = byFamily[family] or {}
        local rarity = tostring(cfg.Rarity or "Common")
        table.insert(byFamily[family], { key, rarity, type(cfg.Display) == "string" and cfg.Display or key, type(cfg.Image) == "string" and cfg.Image or nil })
        if not table.find(Reicht.Skin.Rarities, rarity) then table.insert(Reicht.Skin.Rarities, rarity) end
    end
    table.sort(Reicht.Skin.Types)
    table.sort(Reicht.Skin.Rarities, function(left, right)
        local rankLeft, rankRight = Reicht.Skin.RarityRank[left] or 0, Reicht.Skin.RarityRank[right] or 0
        if rankLeft ~= rankRight then return rankLeft > rankRight end
        return left < right
    end)
    for _, byFamily in pairs(Reicht.Skin.Catalog) do
        for _, list in pairs(byFamily) do
            table.sort(list, function(left, right)
                local rankLeft, rankRight = Reicht.Skin.RarityRank[left[2]] or 0, Reicht.Skin.RarityRank[right[2]] or 0
                if rankLeft ~= rankRight then return rankLeft > rankRight end
                return left[3] < right[3]
            end)
        end
    end
end

function Reicht.Skin.Families(kind)
    return Util.SortedKeys(Reicht.Skin.Catalog[kind])
end

---@param rarities table?  set of rarities to show, empty = all
---@return string[]  labels for the dropdown, best rarity first
function Reicht.Skin.List(kind, family, rarities)
    local list = Reicht.Skin.Catalog[kind] and Reicht.Skin.Catalog[kind][family]
    local names = {}
    if not list then return names end
    local filter = rarities and next(rarities) ~= nil and rarities or nil
    for _, skin in ipairs(list) do
        if filter and not filter[skin[2]] then continue end
        local label = string.format("[%s] %s", skin[2], skin[3])
        if Reicht.Skin.Labels[label] and Reicht.Skin.Labels[label] ~= skin[1] then label = label .. " · " .. skin[1] end
        Reicht.Skin.Labels[label] = skin[1]
        Reicht.Skin.Images[label] = skin[4]
        local colors = Reicht.GameLib.RarityColor
        Reicht.Skin.Colors[label] = type(colors) == "table" and typeof(colors[skin[2]]) == "Color3" and colors[skin[2]] or nil
        names[#names + 1] = label
    end
    return names
end

function Reicht.Skin.Choose(family, label)
    Reicht.Skin.Chosen[family] = label and Reicht.Skin.Labels[label] or nil
end

function Reicht.Skin.ClearAll()
    table.clear(Reicht.Skin.Chosen)
end

---@return table[]  every weapon the local player carries
function Reicht.Skin.Carried()
    local combat = Reicht.GameLib.Service.CombatService
    local ok, weapons = pcall(function() return combat.GetWeapons() end)
    local list = {}
    if ok and type(weapons) == "table" then
        for _, weapon in pairs(weapons) do
            if type(weapon) == "table" and weapon.Name then list[#list + 1] = weapon end
        end
    end
    local held = combat and combat.GetCurrentWeapon()
    if held and not table.find(list, held) then list[#list + 1] = held end
    return list
end

function Reicht.Skin.Rebuild(weapon)
    local controllers = Reicht.GameLib.WeaponController
    local entity = Reicht.GameLib.Service.EntityService.LocalEntity
    if not (controllers and entity and weapon.Controller) then return end
    weapon.Controller:Destroy()
    controllers.Create(entity, weapon)
end

function Reicht.Skin.Apply(weapon, key)
    local cfg = Reicht.GameLib.Config.WeaponConfig[key]
    if not cfg then return end
    if not Reicht.Skin.Saved[weapon] then Reicht.Skin.Saved[weapon] = { weapon.Name, weapon.Config } end
    weapon.Name, weapon.Config = key, cfg
    Reicht.Skin.Rebuild(weapon)
end

function Reicht.Skin.Revert(weapon)
    local saved = Reicht.Skin.Saved[weapon]
    if not saved then return end
    weapon.Name, weapon.Config = saved[1], saved[2]
    Reicht.Skin.Saved[weapon] = nil
    Reicht.Skin.Rebuild(weapon)
end

function Reicht.Skin.Restore()
    for weapon in pairs(Reicht.Skin.Saved) do Reicht.Skin.Revert(weapon) end
end

function Reicht.Skin.Step()
    if not Reicht.Options.SkinChanger then
        if next(Reicht.Skin.Saved) then Reicht.Skin.Restore() end
        Reicht.Skin.Status = "Off"
        return
    end

    local applied = 0
    for _, weapon in ipairs(Reicht.Skin.Carried()) do
        local saved = Reicht.Skin.Saved[weapon]
        local originalCfg = saved and saved[2] or weapon.Config
        local _, family = Reicht.Skin.Classify(originalCfg)
        local key = family and Reicht.Skin.Chosen[family]
        if key then
            if weapon.Name ~= key then Reicht.Skin.Apply(weapon, key) end
            applied += 1
        elseif saved then
            Reicht.Skin.Revert(weapon)
        end
    end
    Reicht.Skin.Status = applied > 0 and (applied .. " weapon(s) skinned") or "Pick a skin"
end

function Reicht.Skin.GetStatus()
    return Reicht.Skin.Status
end

Reicht.UI = { Labels = {}, Shown = {}, Stats = { Cases = 0, Quests = 0 } }
local Library, T

function Reicht.UI.Detach(handler)
    return function(...)
        local packed = table.pack(...)
        task.defer(function()
            local ok, err = pcall(handler, table.unpack(packed, 1, packed.n))
            if not ok then warn("[SniperArena] ui: " .. tostring(err)) end
        end)
    end
end

---@param module table  feature with Start/Stop
function Reicht.UI.StartStop(module)
    return Reicht.UI.Detach(function(on)
        if on then module.Start() else module.Stop() end
    end)
end

---@param widget table  option whose value mirrors an Options key
function Reicht.UI.Bind(widget, key, transform)
    local function Apply(value)
        if transform then value = transform(value) end
        Reicht.Options[key] = value
    end
    Apply(widget.Value)
    widget:OnChanged(Apply)
    return widget
end

function Reicht.UI.SampleStats()
    local cases = 0
    for _, caseKey in ipairs(Reicht.Shop.Cases()) do
        cases += Reicht.Shop.Owned(caseKey)
    end
    Reicht.UI.Stats.Cases = cases
    Reicht.UI.Stats.Quests = #Reicht.Collect.Claimable()
end

---@param title table  T() pair; the UI pump shows it, game-module threads can't
function Reicht.UI.Notice(title, text, kind)
    table.insert(Reicht.State.Notices, { title, tostring(text), kind })
end

function Reicht.UI.BuildMain(window)
    window:AddTabSection(T("Main", "หลัก"))
    local tab = window:AddTab(T("Main", "หลัก"), "mushroom", T("Status and links", "สถานะและลิงก์"))

    local status = tab:AddLeftGroupbox(T("Status", "สถานะ"), "star")
    Reicht.UI.Labels.Esp = status:AddParagraph({ Title = T("ESP", "ESP"), Content = "-" })
    Reicht.UI.Labels.Combat = status:AddParagraph({ Title = T("Combat", "การต่อสู้"), Content = "-" })
    Reicht.UI.Labels.Skin = status:AddParagraph({ Title = T("Skin", "สกิน"), Content = "-" })
    Reicht.UI.Labels.Economy = status:AddParagraph({ Title = T("Economy", "เศรษฐกิจ"), Content = "-" })

    local live = tab:AddRightGroupbox(T("Live", "ตัวเลขสด"), "coin")
    Reicht.UI.Labels.Targets = live:AddParagraph({ Title = T("Enemies seen", "ศัตรูที่เห็น"), Content = "0" })
    Reicht.UI.Labels.Cases = live:AddParagraph({ Title = T("Cases owned", "กล่องที่มี"), Content = "0" })
    Reicht.UI.Labels.Quests = live:AddParagraph({ Title = T("Quests ready", "เควสต์รอรับ"), Content = "0" })

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
end

function Reicht.UI.GuardSilent()
    local reason = T("Not supported on this executor", "ใช้กับ executor นี้ไม่ได้")
    for _, idx in ipairs({ "SilentAim", "Ragebot" }) do
        Library.Compat.NeedCap(idx, "Upvalues")
        if not Reicht.Caps.LookSpoof then Library.Compat.Block(idx, reason) end
    end
end

function Reicht.UI.BuildCombat(window)
    window:AddTabSection(T("Combat", "การต่อสู้"))
    local tab = window:AddTab(T("Combat", "การต่อสู้"), "target", T("Aimbot and firing", "เล็งอัตโนมัติและยิง"))

    local aim = tab:AddLeftGroupbox(T("Aimbot", "เล็งอัตโนมัติ"), "crosshair")
    aim:AddToggle("Aimbot", {
        Text = T("Aimbot", "เล็งอัตโนมัติ"),
        Description = T("Locks onto the enemy nearest your crosshair", "ล็อคศัตรูที่ใกล้เป้าเล็งที่สุด"),
    }):AddKeyPicker("AimbotKey", { Default = "MB2", Mode = "Hold" })
    aim:AddDropdown("AimPriority", { Text = T("Target priority", "เลือกเป้าตาม"), Values = { "Crosshair", "Mouse", "Distance", "Health" }, Default = "Crosshair" })
    aim:AddDropdown("AimBone", { Text = T("Aim part", "จุดเล็ง"), Values = { "Head", "Body", "Arm", "Leg" }, Default = "Head" })
    aim:AddSlider("AimSmooth", { Text = T("Smoothness", "ความนุ่ม"), Min = 1, Max = 20, Default = 1, Rounding = 0 })
    aim:AddSlider("AimPrediction", { Text = T("Prediction", "เล็งดักหน้า"), Min = 0, Max = 200, Default = 60, Suffix = "ms", Rounding = 0 })
    aim:AddSlider("AimFov", { Text = T("FOV", "ระยะมอง"), Min = 20, Max = 600, Default = 150, Suffix = "px" })
    aim:AddToggle("ShowFov", { Text = T("Show FOV circle", "แสดงวงระยะมอง") })
    aim:AddCheckbox("AimWallCheck", { Text = T("Visible only", "เฉพาะที่มองเห็น"), Default = true })
    aim:AddCheckbox("AimTeamCheck", { Text = T("Team check", "เช็คทีม"), Default = true })

    local hitbox = tab:AddLeftGroupbox(T("Hitbox Expander", "ขยายฮิตบ็อกซ์"), "shield")
    hitbox:AddToggle("HitboxExpander", { Text = T("Hitbox expander", "ขยายเป้าฮิตบ็อกซ์"), Description = T("Expands enemy body and head hitboxes for 100% easy hits", "ขยายขนาดหัวและตัวศัตรูให้ยิงโดนง่าย 100%") })
    hitbox:AddDropdown("HitboxPart", { Text = T("Target part", "ส่วนที่ขยาย"), Values = { "Head", "RootPart", "Both" }, Default = "Head" })
    hitbox:AddSlider("HitboxSize", { Text = T("Hitbox size", "ขนาดฮิตบ็อกซ์"), Min = 2, Max = 20, Default = 8, Suffix = " studs" })
    hitbox:AddSlider("HitboxTransparency", { Text = T("Transparency", "ความโปร่งใส"), Min = 0.1, Max = 1, Default = 0.6, Float = 0.05 })

    local melee = tab:AddLeftGroupbox(T("Melee Aura", "ออร่ามีด"), "swords")
    melee:AddToggle("KnifeAura", { Text = T("Knife aura", "ออร่าฟันมีดอัตโนมัติ"), Description = T("Swings knife automatically when enemies are in range", "ฟันมีดใส่อัตโนมัติเมื่อศัตรูเข้าใกล้") })
    melee:AddSlider("KnifeAuraRange", { Text = T("Aura range", "ระยะออร่า"), Min = 5, Max = 25, Default = 16, Suffix = " studs" })

    local rage = tab:AddRightGroupbox(T("Rage & Desync", "เรจและดีซิงก์"), "bomb")
    rage:AddToggle("Ragebot", { Text = T("Ragebot", "เรจบอท"), Description = T("Shoots every visible enemy on its own, view stays still", "ยิงศัตรูทุกตัวที่มองเห็นเอง กล้องไม่ขยับ") })
        :AddKeyPicker("RagebotKey", { Default = "None", Mode = "Toggle" })
    rage:AddToggle("SilentAim", { Text = T("Silent aim", "ไซเลนต์เอม"), Description = T("Shots land on the target inside the FOV, your view never moves", "กระสุนเข้าเป้าในวง FOV กล้องไม่ขยับเลย") })
        :AddKeyPicker("SilentAimKey", { Default = "None", Mode = "Toggle" })
    rage:AddSlider("HitChance", { Text = T("Hit chance", "โอกาสยิงโดน"), Min = 0, Max = 100, Default = 100, Suffix = "%", Rounding = 0 })
    rage:AddSlider("HeadChance", { Text = T("Headshot chance", "โอกาสเข้าหัว"), Min = 0, Max = 100, Default = 100, Suffix = "%", Rounding = 0 })
    rage:AddToggle("AntiAim", { Text = T("Anti-Aim (Spinbot)", "แอนตี้เอม สปินบอท"), Description = T("Spoofs pitch and yaw packet to spin wildly on enemy screens", "หลอกมุมหมุนบนจอศัตรูให้หมุนติ้ว ป้องกันการโดนยิงหัว") })
    rage:AddDropdown("AntiAimMode", { Text = T("Anti-Aim mode", "โหมดแอนตี้เอม"), Values = { "Spinbot", "Jitter" }, Default = "Spinbot" })
    rage:AddSlider("SpinSpeed", { Text = T("Spin speed", "ความเร็วหมุน"), Min = 360, Max = 2160, Default = 1080, Suffix = "°/s" })

    local fire = tab:AddRightGroupbox(T("Weapon Mods", "ม็อดอาวุธ"), "zap")
    fire:AddToggle("FullAuto", { Text = T("Full auto", "ยิงรัวอัตโนมัติ"), Description = T("Turns weapons into automatic fire, removes scope pause", "ยิงต่อเนื่องอัตโนมัติ ไม่ดีดหลุดสโคป") })
    fire:AddToggle("InstantReload", { Text = T("Fast reload", "รีโหลดเร็วพิเศษ"), Description = T("Cuts reload delay to 0 seconds", "ลดเวลารีโหลดกระสุนเหลือ 0 วิ") })
    fire:AddToggle("FastSwitch", { Text = T("Fast switch", "สลับอาวุธยกเลิกอนิเมชัน"), Description = T("Quick-switches knife and sniper to cancel bolt-action animation", "สลับมีดแล้วกลับสไนเปอร์ทันทีเพื่อข้ามอนิเมชันชักกระสุน") })
    fire:AddToggle("InstantScope", { Text = T("Fast scope", "เปิดสโคปเร็ว"), Description = T("Cuts the wait before the scope is ready", "ลดเวลารอก่อนสโคปพร้อมยิง") })
    fire:AddToggle("NoScopeOverlay", { Text = T("No scope overlay", "ปิดขอบดำสโคป"), Description = T("Removes black sniper scope mask, keeps crosshair visible in aim", "ลบขอบดำสโคปออก มองเห็นเต็มจอและคงเป้าเล็งไว้") })
    fire:AddToggle("InfiniteAmmo", { Text = T("Infinite ammo", "กระสุนไม่จำกัด"), Description = T("Freezes ammo clip, never run out of bullets", "กระสุนไม่ลด ไม่ต้องรีโหลด") })
    fire:AddToggle("NoSpread", { Text = T("No spread", "ยิงไม่กระจาย"), Description = T("Shots stay accurate while moving or jumping", "ยิงแม่นแม้ตอนเดินหรือกระโดด") })
    fire:AddToggle("NoRecoil", { Text = T("No recoil", "ไม่มีแรงถีบ"), Description = T("Camera no longer kicks when firing", "กล้องไม่เด้งตอนยิง") })
    fire:AddToggle("TriggerBot", { Text = T("Trigger bot", "ยิงอัตโนมัติ"), Description = T("Fires the moment your crosshair is on an enemy", "ยิงทันทีเมื่อเป้าเล็งทับศัตรู") })
        :AddKeyPicker("TriggerBotKey", { Default = "None", Mode = "Toggle" })

    Reicht.UI.GuardSilent()
end

function Reicht.UI.BuildPlayer(window)
    window:AddTabSection(T("Player", "ผู้เล่น"))
    local tab = window:AddTab(T("Player", "ผู้เล่น"), "oneup", T("Respawn and utility", "เกิดใหม่และอรรถประโยชน์"))

    local util = tab:AddLeftGroupbox(T("Utility", "อรรถประโยชน์"), "gear")
    util:AddToggle("FastRespawn", { Text = T("Fast respawn", "เกิดใหม่เร็ว"), Description = T("Back in the fight the moment you die", "กลับเข้าสนามทันทีที่ตาย") })
    util:AddToggle("AutoJoin", { Text = T("Auto join round", "เข้ารอบอัตโนมัติ"), Description = T("Joins the next round from the lobby by itself", "เข้ารอบถัดไปจากล็อบบี้เอง") })
    Library.Compat.NeedCap("AutoJoin", "Touch")
    util:AddToggle("AutoFlag", { Text = T("Auto pick flag", "เก็บธงอัตโนมัติ"), Description = T("Grabs flags instantly in CTF rounds", "เก็บธงทันทีในรอบชิงธง") })
    util:AddToggle("AntiAfk", { Text = T("Anti AFK", "กันหลุด AFK"), Callback = Reicht.UI.StartStop(Reicht.Player.AntiAfk) })

    local vision = tab:AddLeftGroupbox(T("Vision Mods", "การมองเห็นพิเศษ"), "eye")
    vision:AddToggle("AntiFlash", { Text = T("Anti flash", "กันแฟลชขาว"), Description = T("Immune to flashbang blindness", "จอไม่ขาวเมื่อโดนระเบิดแฟลช") })
    vision:AddToggle("AntiSmoke", { Text = T("Anti smoke", "มองทะลุควัน"), Description = T("See and target clearly through smoke", "มองและเล็งทะลุหมอกควันได้ 100%") })

    local move = tab:AddRightGroupbox(T("Movement", "การเคลื่อนที่"), "zap")
    move:AddToggle("InfiniteDash", { Text = T("Infinite dash", "พุ่งไม่จำกัด"), Description = T("Dash again without waiting (FFA/TDM)", "พุ่งซ้ำได้ไม่ต้องรอ (FFA/TDM)") })
    move:AddToggle("InfiniteAirJump", { Text = T("Infinite air jump", "กระโดดกลางอากาศไม่จำกัด"), Description = T("Jump continuously in mid-air", "กระโดดบนอากาศซ้ำได้ไม่จำกัด") })
    move:AddToggle("AutoBhop", { Text = T("Auto bunny hop", "กระโดดต่อเนื่อง"), Description = T("Jumps automatically while moving", "กระโดดต่อเนื่องอัตโนมัติขณะเดิน") })
    move:AddSlider("SpeedMultiplier", { Text = T("Speed multiplier", "ตัวคูณความเร็ว"), Min = 1, Max = 3, Default = 1, Float = 0.1, Suffix = "x" })
    move:AddSlider("CustomFov", { Text = T("Camera FOV", "มุมมองกล้อง FOV"), Min = 70, Max = 120, Default = 70, Suffix = "°" })

    local wall = tab:AddRightGroupbox(T("Wallhack & Chams", "มองทะลุกำแพง"), "shield")
    wall:AddToggle("EnemyChams", { Text = T("Enemy chams (X-Ray)", "แชมส์ศัตรู X-Ray"), Description = T("Engine-level highlight glowing through walls", "เรืองแสงสีแดงทะลุกำแพงด้วยเอนจินเกม") })
    wall:AddToggle("AntiPeekBypass", { Text = T("Bypass occlusion", "ปิดการซ่อนตัวหลังกำแพง"), Description = T("Prevents the game from hiding enemies behind walls", "ไม่ให้เกมซ่อนโมเดลศัตรูหลังสิ่งกีดขวาง") })
end

Reicht.UI.SkinKinds = {
    Sniper = { "Snipers", "สไนเปอร์", "crosshair" },
    Rifle = { "Rifles", "ไรเฟิล", "target" },
    Melee = { "Knives", "มีด", "swords" },
    Glove = { "Gloves", "ถุงมือ", "shield" },
}

---@param kind string  WeaponType from the game config
function Reicht.UI.BuildSkinGroup(tab, kind, left)
    local meta = Reicht.UI.SkinKinds[kind] or { kind, kind, "star" }
    local group = left and tab:AddLeftGroupbox(T(meta[1], meta[2]), meta[3]) or tab:AddRightGroupbox(T(meta[1], meta[2]), meta[3])
    local families = Reicht.Skin.Families(kind)
    local weaponIdx, skinIdx = "Skin" .. kind .. "Weapon", "Skin" .. kind .. "Pick"

    local function Family()
        local picker = Library.Options[weaponIdx]
        return picker and picker.Value
    end

    local function Refill()
        local picker = Library.Options[skinIdx]
        if picker then picker:SetValues(Reicht.Skin.List(kind, Family(), Util.SetFromList(Reicht.Options.SkinRarities))) end
    end
    table.insert(Reicht.UI.SkinRefill, Refill)

    group:AddDropdown(weaponIdx, { Text = T("Weapon", "อาวุธ"), Values = families, Default = families[1], Searchable = true, Callback = function() Refill() end })
    group:AddDropdown(skinIdx, {
        Text = T("Skin", "สกิน"),
        Values = Reicht.Skin.List(kind, families[1], {}),
        Images = Reicht.Skin.Images,
        Colors = Reicht.Skin.Colors,
        Searchable = true,
        AllowNull = true,
        Callback = function(label)
            if Family() then Reicht.Skin.Choose(Family(), label) end
        end,
    })
    group:AddButton({ Text = T("Use default skin", "ใช้สกินเดิม"), Func = function()
        if Family() then Reicht.Skin.Choose(Family(), nil) end
        Library.Options[skinIdx]:SetValue(nil)
    end })
end

function Reicht.UI.BuildSkins(window)
    Reicht.UI.SkinRefill = {}
    local tab = window:AddTab(T("Skins", "สกิน"), "star", T("Every weapon, knife and glove skin", "สกินปืน มีด และถุงมือทุกแบบ"))

    local main = tab:AddLeftGroupbox(T("Skin Changer", "เปลี่ยนสกิน"), "star")
    main:AddToggle("SkinChanger", { Text = T("Skin changer", "เปลี่ยนสกิน"), Description = T("Pick any skin per weapon, only you see it", "เลือกสกินรายอาวุธได้ทุกแบบ เห็นแค่ตัวเอง") })
    local filter = main:AddDropdown("SkinRarities", {
        Text = T("Show rarities", "แสดงเฉพาะ rarity"),
        Description = T("Empty shows everything", "ไม่เลือก = แสดงทั้งหมด"),
        Values = Reicht.Skin.Rarities,
        Multi = true,
        Default = {},
        AllowNull = true,
    })
    Reicht.UI.Bind(filter, "SkinRarities")
    filter:OnChanged(function()
        for _, refill in ipairs(Reicht.UI.SkinRefill) do refill() end
    end)
    main:AddButton({ Text = T("Reset all skins", "คืนสกินเดิมทั้งหมด"), Style = "Warning", Func = function()
        Reicht.Skin.ClearAll()
        for _, kind in ipairs(Reicht.Skin.Types) do
            local picker = Library.Options["Skin" .. kind .. "Pick"]
            if picker then picker:SetValue(nil) end
        end
    end })

    local leftRows, rightRows = Reicht.Config.SkinMainRows, 0
    for _, kind in ipairs(Reicht.Skin.Types) do
        local left = leftRows < rightRows
        Util.Try("skins " .. kind, Reicht.UI.BuildSkinGroup, tab, kind, left)
        if left then
            leftRows += Reicht.Config.SkinGroupRows
        else
            rightRows += Reicht.Config.SkinGroupRows
        end
    end
end

function Reicht.UI.BuildVisuals(window)
    window:AddTabSection(T("Visuals", "การมองเห็น"))
    Util.Try("visuals tab", function()
        window:AddVisualsTab({ Provider = Reicht.Esp.Targets, Preview = true })
    end)
    Util.Try("skins tab", Reicht.UI.BuildSkins, window)
end

---@return table  rarities to sell: every known rarity not kept
function Reicht.UI.SellSet(keep)
    local kept, sell = Util.SetFromList(keep), {}
    for _, rarity in ipairs(Reicht.Sell.Rarities()) do
        if not kept[rarity] then sell[rarity] = true end
    end
    return sell
end

---@param sold table  rarity list an older save picked to sell
---@return string[]   the same choice as rarities to keep
function Reicht.UI.KeepFromSold(sold)
    local selling, keep = Util.SetFromList(sold), {}
    for _, rarity in ipairs(Reicht.Sell.Rarities()) do
        if not selling[rarity] then table.insert(keep, rarity) end
    end
    return keep
end

---@param keep table  KeepRarities dropdown; old saves that only have SellRarities load into it
function Reicht.UI.AdoptOldSellSave(group, keep)
    local old = group:AddDropdown("SellRarities", {
        Text = T("Sell rarities", "rarity ที่จะขาย"),
        Values = Reicht.Sell.Rarities(),
        Multi = true,
        Default = {},
        AllowNull = true,
    })
    old:SetVisible(false)
    old.Serialize = false
    old.Deserialize = function(_, saved)
        keep:SetValue(Reicht.UI.KeepFromSold(saved))
    end
end

function Reicht.UI.BuildEconomy(window)
    window:AddTabSection(T("Economy", "เศรษฐกิจ"))
    local tab = window:AddTab(T("Economy", "เศรษฐกิจ"), "coin", T("Cases, selling, quests", "เปิดกล่อง ขาย เควสต์"))

    local cases = tab:AddLeftGroupbox(T("Cases & Codes", "กล่องสุ่มและโค้ด"), "qblock")
    cases:AddToggle("AutoOpenCases", { Text = T("Auto open owned cases", "เปิดกล่องที่มีอัตโนมัติ") })
    cases:AddSlider("OpenCount", { Text = T("Open per case", "เปิดต่อกล่อง"), Min = 1, Max = 10, Default = 1 })
    cases:AddButton({ Text = T("Open All Now", "เปิดทั้งหมดตอนนี้"), Style = "Primary", Func = Reicht.UI.Detach(function()
        Reicht.UI.Notice(T("Cases", "กล่องสุ่ม"), Reicht.Shop.OpenAllNow(), "Coin")
    end) })
    cases:AddButton({ Text = T("Redeem All Codes", "แลกโค้ดทั้งหมด"), Style = "Success", Func = Reicht.UI.Detach(function()
        Reicht.UI.Notice(T("Codes", "โค้ด"), Reicht.Code.RedeemAll(), "Success")
    end) })

    local sell = tab:AddRightGroupbox(T("Sell", "ขาย"), "shop")
    local keep = sell:AddDropdown("KeepRarities", {
        Text = T("Never sell", "ไม่ขาย"),
        Description = T("Selected rarities are always kept", "rarity ที่เลือกจะเก็บไว้เสมอ"),
        Values = Reicht.Sell.Rarities(),
        Multi = true,
        Default = {},
        AllowNull = true,
    })
    Reicht.UI.Bind(keep, "SellRarities", Reicht.UI.SellSet)
    Reicht.UI.AdoptOldSellSave(sell, keep)
    sell:AddToggle("AutoSell", { Text = T("Auto sell", "ขายอัตโนมัติ") })
    sell:AddSlider("MaxSellPrice", { Text = T("Max price to sell", "ราคาสูงสุดที่ขาย"), Description = T("Keeps anything worth more (0 = no limit)", "ของแพงกว่านี้จะเก็บไว้ (0 = ไม่จำกัด)"), Min = 0, Max = 100000, Default = 500 })
    sell:AddSlider("KeepPerRarity", { Text = T("Keep per rarity", "เก็บต่อ rarity"), Min = 0, Max = 20, Default = 0 })
    sell:AddButton({ Text = T("Sell Now", "ขายตอนนี้"), Style = "Warning", Func = Reicht.UI.Detach(function()
        Reicht.UI.Notice(T("Sell", "ขาย"), Reicht.Sell.SellNow(), "Coin")
    end) })
    sell:AddButton({ Text = T("Refresh rarities", "รีเฟรช rarity"), Func = Reicht.UI.Detach(function()
        keep:SetValues(Reicht.Sell.Rarities())
        Reicht.Options.SellRarities = Reicht.UI.SellSet(keep.Value)
    end) })

    local quest = tab:AddLeftGroupbox(T("Quests", "เควสต์"), "key")
    quest:AddToggle("AutoClaimQuest", { Text = T("Auto claim quests", "รับรางวัลเควสต์อัตโนมัติ") })
    quest:AddButton({ Text = T("Claim Now", "รับตอนนี้"), Style = "Success", Func = Reicht.UI.Detach(function()
        Reicht.UI.Notice(T("Quests", "เควสต์"), Reicht.Collect.ClaimNow(), "Success")
    end) })
end

---@param key string  entry in UI.Labels, only redrawn when the text changes
function Reicht.UI.Show(key, text)
    local label = Reicht.UI.Labels[key]
    text = tostring(text)
    if not label or Reicht.UI.Shown[key] == text then return end
    Reicht.UI.Shown[key] = text
    label:SetContent(text)
end

function Reicht.UI.RefreshStatus()
    Reicht.UI.Show("Skin", Reicht.Skin.GetStatus())
    Reicht.UI.Show("Esp", Reicht.Esp.GetStatus())
    Reicht.UI.Show("Combat", Reicht.Combat.GetStatus())
    Reicht.UI.Show("Economy", string.format("%s | %s | %s", Reicht.Shop.GetStatus(), Reicht.Sell.GetStatus(), Reicht.Collect.GetStatus()))

    Reicht.UI.Show("Targets", Reicht.Esp.Count)
    Reicht.UI.Show("Cases", Reicht.UI.Stats.Cases)
    Reicht.UI.Show("Quests", Reicht.UI.Stats.Quests)
end

function Reicht.UI.ShowHalted()
    local queue = Reicht.State.Halted
    if #queue == 0 then return end
    local stopped = table.clone(queue)
    table.clear(queue)

    for _, halt in ipairs(stopped) do
        local name, reason, toggles = halt[1], halt[2], halt[3]
        for _, key in ipairs(toggles) do
            local toggle = Library.Options[key]
            if toggle and toggle.Value == true then
                Util.Try("halt " .. key, toggle.SetValue, toggle, false)
            end
        end
        Library:Notify("Reicht", name .. " stopped: " .. reason, 6, "Error")
    end
end

function Reicht.UI.ShowNotices()
    local queue = Reicht.State.Notices
    if #queue == 0 then return end
    local pending = table.clone(queue)
    table.clear(queue)
    for _, notice in ipairs(pending) do
        Library:Notify(notice[1], notice[2], 4, notice[3])
    end
end

function Reicht.UI.Pump()
    Util.Try("status", Reicht.UI.RefreshStatus)
    Util.Try("halts", Reicht.UI.ShowHalted)
    Util.Try("notices", Reicht.UI.ShowNotices)
end

function Reicht.UI.BlockMissing()
    local unsupported = T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้")
    local outdated = T("Changed by a game update, wait for a script update", "เกมอัปเดตแล้ว รอสคริปต์อัปเดต")
    for module, features in pairs(Reicht.Config.ModuleFeatures) do
        local missing = GameLib.Missing[module]
        if not missing then continue end
        for _, idx in ipairs(features) do
            Library.Compat.Block(idx, missing == "Absent" and outdated or unsupported)
        end
    end

    if not Reicht.Movement.FindDash() then
        warn("[SniperArena] module CombatHelper.Dash not found, Infinite dash is blocked")
        Library.Compat.Block("InfiniteDash", outdated)
    end
end

function Reicht.UI.Build()
    local window = Library.Window
    Util.Try("main tab", Reicht.UI.BuildMain, window)
    Util.Try("combat tab", Reicht.UI.BuildCombat, window)
    Util.Try("player tab", Reicht.UI.BuildPlayer, window)
    Util.Try("visuals tabs", Reicht.UI.BuildVisuals, window)
    Util.Try("economy tab", Reicht.UI.BuildEconomy, window)
    Util.Try("settings tab", function()
        window:AddTabSection(T("Other", "อื่นๆ"))
        window:AddSettingsTab()
    end)

    for _, key in ipairs({
        "AimFov", "AimBone", "AimPriority", "AimMaxDistance",
        "Aimbot", "AimSmooth", "AimPrediction", "ShowFov", "AimWallCheck", "AimTeamCheck",
        "SilentAim", "Ragebot", "InstantScope", "FullAuto", "InstantReload",
        "HitChance", "HeadChance", "TriggerBot", "NoRecoil", "NoSpread",
        "AntiAim", "AntiAimMode", "SpinSpeed", "KnifeAura", "KnifeAuraRange",
        "FastSwitch", "NoScopeOverlay",
        "FastRespawn", "AutoJoin", "AutoFlag", "AntiAfk",
        "InfiniteDash", "InfiniteAirJump", "AutoBhop", "SpeedMultiplier", "CustomFov",
        "AntiFlash", "AntiSmoke", "EnemyChams", "AntiPeekBypass",
        "InfiniteAmmo", "HitboxExpander", "HitboxPart", "HitboxSize", "HitboxTransparency",
        "SkinChanger", "OpenCount", "MaxSellPrice", "KeepPerRarity",
        "AutoOpenCases", "AutoSell", "AutoClaimQuest",
    }) do
        local widget = Library.Options[key]
        if widget then Util.Try("bind " .. key, Reicht.UI.Bind, widget, key) end
    end
    Util.Try("missing modules", Reicht.UI.BlockMissing)
    Reicht:Connect(RunService.RenderStepped, Reicht.Combat.DrawCircle)

    Reicht.Scheduler.Every("Live stats", Reicht.Config.EconomyInterval, Reicht.UI.SampleStats)
    Library:Every(Reicht.Config.StatusInterval, Reicht.UI.Pump)
end

---@return boolean  false when the menu could not be opened
local function BuildInterface()
    Library = Util.LoadLibrary(Reicht.Config.UiSource)
    if not Library then return false end
    Reicht.Library = Library
    pcall(Reicht.Banner.Step, "UI library")
    T = function(en, th) return Library:T(en, th) end
    local opened, err = pcall(Library.CreateWindow, Library, {
        Title = "Reicht",
        SubTitle = "Sniper Arena by Reicht",
        MenuKey = Enum.KeyCode.LeftControl,
        ConfigFolder = Reicht.Config.SaveFolder,
        Language = "Auto",
        Theme = "Overworld",
        Intro = true,
        OnUnlocked = function()
            Reicht.UI.Build()
            pcall(Reicht.Banner.Step, "Interface")
            task.defer(Util.Try, "boot", Reicht.Boot)
            task.defer(Util.Try, "autoload config", function() Library:LoadAutoloadConfig() end)
        end,
    })
    if not opened then
        Util.Alert("The menu failed to load on this executor: " .. tostring(err):match("^[^\n]*"), err)
        return false
    end
    Library:OnUnload(function()
        Reicht:Unload()
    end)
    return true
end

function Reicht.Boot()
    Reicht:Connect(LocalPlayer.CharacterAdded, function(character)
        Reicht.Player.Respawn.Reset()
        Reicht.Player:Bind(character)
    end)

    Util.Try("movement", Reicht.Movement.Start)

    Reicht.Scheduler.Every("Combat", 0.03, Reicht.Combat.Step, Reicht.Config.CombatToggles, Reicht.Combat.Rest)
    Reicht.Scheduler.Every("ESP", Reicht.Config.EspInterval, Reicht.Esp.Step)
    Reicht.Scheduler.Every("Fast Respawn", 0.1, Reicht.Player.Respawn.Step, { "FastRespawn" })
    Reicht.Scheduler.Every("Auto Join", 1, Reicht.Player.Join.Step, { "AutoJoin" })
    Reicht.Scheduler.Every("Skin Changer", 0.5, Reicht.Skin.Step, { "SkinChanger" }, Reicht.Skin.Restore)
    Reicht.Scheduler.Every("Auto Open Cases", Reicht.Config.EconomyInterval, Reicht.Shop.Step, { "AutoOpenCases" })
    Reicht.Scheduler.Every("Auto Sell", Reicht.Config.EconomyInterval, Reicht.Sell.Step, { "AutoSell" })
    Reicht.Scheduler.Every("Auto Claim Quests", Reicht.Config.EconomyInterval, Reicht.Collect.Step, { "AutoClaimQuest" })
    Reicht.Scheduler.Every("Auto Flag", 0.2, Reicht.Flag.Step, { "AutoFlag" })
    Util.Try("scheduler", Reicht.Scheduler.Boot)
    pcall(Reicht.Banner.Step, "Combat + economy online")
    pcall(Reicht.Banner.Ready)
end

function Reicht:Unload()
    self.State.Alive = false
    for key, value in pairs(self.Options) do
        if value == true then self.Options[key] = false end
    end
    Reicht.Movement.Restore()
    Reicht.Esp.Restore()
    Reicht.Combat.Unload()
    Reicht.Skin.Restore()
    for _, connection in ipairs(self.State.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self.State.Connections)

    local overlay = self.State.Overlay
    self.State.Overlay = nil
    if overlay then overlay:Destroy() end
    if environment.SniperArenaUnload == Reicht.UnloadHook then environment.SniperArenaUnload = nil end
end

function Reicht.UnloadHook()
    if Reicht.Library and not Reicht.Library.Unloaded then
        Reicht.Library:Unload()
    else
        Reicht:Unload()
    end
end

environment.SniperArenaUnload = Reicht.UnloadHook

if LocalPlayer.Character then
    Reicht.Player:Bind(LocalPlayer.Character)
end

pcall(Reicht.Banner.Step, "Character bound")
BuildInterface()