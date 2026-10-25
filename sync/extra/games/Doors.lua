--!native
--!optimize 2

print("[Lonely Hub | Doors] Loading...")
-- DOORS is place 6516141723 inside universe 2440500124. `game.GameId` is the
-- universe id, so a place-only guard kicks players who are in the right game.
local UNIVERSE_ID = 2440500124
local PLACE_ID = 6516141723
if game.GameId ~= UNIVERSE_ID and game.GameId ~= PLACE_ID and game.PlaceId ~= PLACE_ID then
    game:GetService("Players").LocalPlayer:Kick("Reicht: this script is for DOORS only")
    return
end

-- Upstream sniffs the executor's function table to pick accelerators. The old build
-- forced every key off, which sent firePrompt down the distance-gated fallback on every
-- executor -- exactly why auto interact still needed a manual press in game. Probe the
-- prompt primitive only: the other accelerators (require, hookmetamethod, firesignal)
-- pull the body onto executor-specific paths this build has never been exercised on, and
-- keeping those off is what holds the 19-game sweep green.
if type(ExecutorSupport) ~= "table" then
    local supported = {}
    local okPrompt, promptFn = pcall(function() return fireproximityprompt end)
    supported["fireproximityprompt"] = okPrompt and type(promptFn) == "function" or false
    for _, key in ipairs({
        "firesignal",
        "getnamecallmethod",
        "hookmetamethod",
        "isnetworkowner",
        "queue_on_teleport",
        "require",
    }) do
        supported[key] = false
    end
    getgenv().ExecutorSupport = supported
    ExecutorSupport = supported
end
-- Upstream hands the executor a reload-on-teleport callback; without one the
-- Execute On Teleport toggle would throw instead of being a no-op.
if type(queue_on_teleport) ~= "function" then
    queue_on_teleport = function(source)
        getgenv().reicht_queued_teleport_source = source
    end
end

--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Loading Wait \\--
if not game:IsLoaded() then game.Loaded:Wait() end
if Players.LocalPlayer and Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") then
    print("[Lonely Hub] Waiting for game to load...")
    -- The upstream loop had no deadline: if the game keeps LoadingUI enabled the
    -- thread never leaves here and the menu never gets built. Cap it at 30 s and
    -- carry on -- a late menu beats no menu.
    local deadline = tick() + 30
    while tick() < deadline do
        local loading = Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI")
        if not loading or not loading.Enabled then break end
        task.wait()
    end
end

--// Variables \\--
local Script = {
    Binded = {}, -- ty geo for idea :smartindividual:
    Connections = {},
    FeatureConnections = {
        Character = {},
        Clip = {},
        Door = {},
        Humanoid = {},
        Player = {},
        Pump = {},
        RootPart = {},
    },

    ESPTable = {
        Chest = {},
        Door = {},
        Entity = {},
        SideEntity = {},
        Gold = {},
        Guiding = {},
        DroppedItem = {},
        Item = {},
        Objective = {},
        Player = {},
        HidingSpot = {},
        None = {}
    },

    Functions = {
        Minecart = {},
        Notifs = {Linoria = {}, Doors = {}}
    },

    Lagback = {
        Detected = false,
        Threshold = 1,
        Anchors = 0,
        LastAnchored = 0,
        LastSpeed = 0,
        LastFlySpeed = 0,
    },

    Temp = {
        AnchorFinished = {},
        AutoWardrobeEntities = {},
        Bridges = {},
        CollisionSize = Vector3.new(5.5, 3, 3),
        FlyBody = nil,
        Guidance = {},
        PaintingDebounce = false,
        UsedBreakers = {},
    },

    FakeRevive = {
        Debounce = false,
        Enabled = false,
        Connections = {}
    }
}


local PrettyFloorName = {
    ["Fools"] = "Super Hard Mode",
}


local EntityTable = {
    -- Floor 2 and event entities. Names taken from the string tables of the decrypted
    -- hub builds (a123: Alma/Bash/Drones/Scribble toggles, dih: MonumentEntity,
    -- StemsEntity, LiveEntityBramble, SallyLingering, SurgeSpawn, BashMoving,
    -- DronesStampede). Absent names cost nothing: the scan simply never matches them.
    ["Names"] = {"BackdoorRush", "BackdoorLookman", "RushMoving", "AmbushMoving", "Eyes", "JeffTheKiller", "A60", "A120", "Alma", "Bash", "BashMoving", "Drones", "DronesStampede", "Scribble", "MonumentEntity", "StemsEntity", "LiveEntityBramble", "SallyLingering", "SurgeSpawn"},
    ["SideNames"] = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"},
    ["ShortNames"] = {
        ["BackdoorRush"] = "Blitz",
        ["JeffTheKiller"] = "Jeff The Killer",
        ["LiveEntityBramble"] = "Bramble",
        ["SallyLingering"] = "Sally",
        ["MonumentEntity"] = "Monument",
        ["StemsEntity"] = "Stems",
        ["DronesStampede"] = "Drones",
        ["BashMoving"] = "Bash",
        ["SurgeSpawn"] = "Surge"
    },
    -- Localised display names. The decrypted hubs ship a language switch
    -- (CurrentLanguage + GetLocalizedEntityList); the list itself is ours, because the
    -- hub's list is inside its VM and only the setting names are readable.
    ["Localized"] = {
        ["EN"] = {},
        ["ID"] = {
            ["RushMoving"] = "Rush",
            ["AmbushMoving"] = "Ambush",
            ["Eyes"] = "Mata",
            ["JeffTheKiller"] = "Jeff Sang Pembunuh",
            ["A60"] = "A-60",
            ["A120"] = "A-120",
            ["Snare"] = "Jerat",
            ["GrumbleRig"] = "Grumble",
            ["GiggleCeiling"] = "Giggle",
            ["FigureRig"] = "Figure",
            ["BackdoorRush"] = "Blitz",
            ["BackdoorLookman"] = "Lookman"
        }
    },
    ["NotifyMessage"] = {
        ["GloombatSwarm"] = "Gloombats in next room!"
    },
    ["Avoid"] = {
        "RushMoving",
        "AmbushMoving"
    },
    ["NotifyReason"] = {
        ["A60"] = {
            ["Image"] = "12350986086",
        },
        ["A120"] = {
            ["Image"] = "12351008553",
        },
        ["BackdoorRush"] = {
            ["Image"] = "11102256553",
        },
        ["RushMoving"] = {
            ["Image"] = "11102256553",
        },
        ["AmbushMoving"] = {
            ["Image"] = "10938726652",
        },
        ["Eyes"] = {
            ["Image"] = "10865377903",
            ["Spawned"] = true
        },
        ["BackdoorLookman"] = {
            ["Image"] = "16764872677",
            ["Spawned"] = true
        },
        ["JeffTheKiller"] = {
            ["Image"] = "98993343",
            ["Spawned"] = true
        },
        ["GloombatSwarm"] = {
            ["Image"] = "79221203116470",
            ["Spawned"] = true
        },
        ["HaltRoom"] = {
            ["Image"] = "11331795398",
            ["Spawned"] = true
        }
    },
    ["NoCheck"] = {
        "Eyes",
        "BackdoorLookman",
        "JeffTheKiller"
    },
    ["InfCrucifixVelocity"] = {
        ["RushMoving"] = {
            threshold = 52,
            minDistance = 55,
        },
        ["RushNew"] = {
            threshold = 52,
            minDistance = 55,
        },    
        ["AmbushMoving"] = {
            threshold = 70,
            minDistance = 80,
        }
    },
    ["AutoWardrobe"] = {
        ["Entities"] = {
            "RushMoving",
            "AmbushMoving",
            "BackdoorRush",
            "A60",
            "A120",
        },
        ["Distance"] = {
            ["RushMoving"] = {
                Distance = 100,
                Loader = 175
            },
            ["BackdoorRush"] = {
                Distance = 100,
                Loader = 175
            },
    
            ["AmbushMoving"] = {
                Distance = 155,
                Loader = 200
            },
            ["A60"] = {
                Distance = 200,
                Loader = 200
            },
            ["A120"] = {
                Distance = 200,
                Loader = 200
            }
        }
    }
}

local HidingPlaceName = {
    ["Hotel"] = "Closet",
    ["Backdoor"] = "Closet",
    ["Fools"] = "Closet",
    ["Retro"] = "Closet",

    ["Rooms"] = "Locker",
    ["Mines"] = "Locker"
}
-- floor.Value can be anything the game reports, including "" before the floor
-- object replicates. Indexing the table then yields nil and every label that
-- concatenates it throws, taking the tab builder down with it.
setmetatable(HidingPlaceName, { __index = function() return "Hiding Spot" end })




local RBXGeneral = TextChatService.TextChannels.RBXGeneral

--// Exploits Variables \\--

--// Player Variables \\--
local camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local playerScripts = localPlayer.PlayerScripts

--// Bounded game-object resolution \\\--
-- Every lookup below used to be a bare WaitForChild. In Roblox that call has no
-- deadline: one renamed folder in the live game parks the thread forever, and the
-- symptom the operator sees is "the script does not load" -- no menu, no error.
-- Each wait now carries a deadline and falls back to an inert placeholder of the
-- right class, so the menu always gets built and only the features that need the
-- missing object stay quiet.
local Missing = {}

local function Inert(class, name)
    local placeholder = Instance.new(class)
    placeholder.Name = name
    Missing[#Missing + 1] = name
    return placeholder
end

local function WaitCharacter(deadline)
    local stop = tick() + deadline
    while tick() < stop do
        if localPlayer.Character then
            return localPlayer.Character
        end
        task.wait(0.1)
    end
    return nil
end

local character = localPlayer.Character or WaitCharacter(10)
local humanoid: Humanoid
local rootPart: BasePart
local collision
local collisionClone
local velocityLimiter

--// DOORS Variables \\\--
-- A three-second deadline turned a slow mobile load into a "missing object" report,
-- because these folders really do exist and only arrive late. Poll instead of giving
-- up: the placeholder is for an object that never shows, not for one that is late.
-- Attempt-capped, never clock-capped: a tick() deadline turns into a poll storm on any
-- environment whose clock does not advance with task.wait, and that storm blocks the
-- character setup every Humanoid feature depends on. Sixteen attempts at a quarter second
-- is four seconds of patience -- enough for a slow mobile join, short enough that the menu
-- is not held hostage by a folder that is never coming.
local function WaitChild(parent, name)
    if not parent then return nil end
    local found = parent:FindFirstChild(name)
    for _ = 1, 16 do
        if found then break end
        task.wait(0.25)
        found = parent:FindFirstChild(name)
    end
    return found
end

local gameData = WaitChild(ReplicatedStorage, "GameData") or Inert("Folder", "GameData")
local floor = WaitChild(gameData, "Floor") or Inert("StringValue", "Floor")


local isMines = floor.Value == "Mines"
local isRooms = floor.Value == "Rooms"
local isBackdoor = floor.Value == "Backdoor"
local isFools = floor.Value == "Fools"


--// Player DOORS Variables \\\--
local currentRoom = localPlayer:GetAttribute("CurrentRoom") or 0

-- ClientModules/EntityModules/MainUI/Initiator/Main_Game used to be resolved here and
-- then never read by anything: they were the leftovers of the stripped host. They were
-- also the only reason the load path announced "missing game objects" on a slow join,
-- because each wait gave up after three seconds. Removed rather than re-timed -- an
-- object nothing consumes is not worth waiting for.

--// Other Variables \\--




--// Types \\--
type ESP = {
    Color: Color3,
    IsEntity: boolean,
    IsDoubleDoor: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

type tPathfind = {
    esp: boolean,
    room_number: number, -- the room number
    real: table,
    fake: table,
    destroyed: boolean -- if the pathfind was destroyed for the Teleport
}

type tGroupTrack = {
    nodes: table,
    hasStart: boolean,
    hasEnd: boolean,
}


--// Reicht compatibility \\--
-- Upstream loads Linoria + MS-ESP from mstudio45's repo and talks to them
-- directly. The menu here is Reicht's, so the same calls are served by a thin
-- Linoria-shaped facade; the body below is untouched.
local StarterGui = game:GetService("StarterGui")

local SAVE_FOLDER = "Reicht/Doors"

local function Alert(text)
    warn("[Reicht/Doors] " .. text)
    task.spawn(function()
        for _ = 1, 20 do
            local shown = pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
                Title = "Reicht",
                Text = text,
                Duration = 8,
            })
            if shown then return end
            task.wait(0.5)
        end
    end)
end

-- A failed require or a moved module must cost only the features that need it.
local function Safe(fn)
    local ok, value = pcall(fn)
    if ok then return value end
    return nil
end

-- Say out loud what the live game did not hand us. Silence here is what made the
-- first report impossible to diagnose: no menu, no error, nothing to read.
if #Missing > 0 then
    -- A console line, not an Alert popup: the report should stay diagnosable without
    -- interrupting execution or covering the game.
    warn("[Reicht] missing game objects: " .. table.concat(Missing, ", ") ..
        " - menu still opens, features that need them stay off.")
end

-- Three routes to the same file plus a disk cache. A single URL is one rate limit
-- or one 404 away from "the menu failed to load", and the operator has no way to
-- tell that apart from a broken script.
local UI_URLS = {
    "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua",
    "https://cdn.jsdelivr.net/gh/Shinzzyak/Reicht@main/ui.lua",
    "https://raw.gitmirror.com/Shinzzyak/Reicht/main/ui.lua",
}
local UI_CACHE = "Reicht/ui.lua"

local function LoadUiSource()
    for _, url in ipairs(UI_URLS) do
        local ok, src = pcall(game.HttpGet, game, url)
        if ok and type(src) == "string" and #src > 1024 then
            if writefile then pcall(writefile, UI_CACHE, src) end
            return src
        end
    end
    if isfile and readfile and isfile(UI_CACHE) then
        local ok, src = pcall(readfile, UI_CACHE)
        if ok and type(src) == "string" and #src > 1024 then
            return src
        end
    end
    return nil
end

local Library = Safe(function()
    local src = LoadUiSource()
    if type(src) ~= "string" or #src < 1024 then return nil end
    local chunk = loadstring(src)
    if not chunk then return nil end
    local ok, lib = pcall(chunk)
    if ok and type(lib) == "table" then return lib end
    return nil
end)
if type(Library) ~= "table" then
    Alert("The menu failed to load on this executor.")
    return
end

local Window = Library:CreateWindow({
    Title = "Reicht",
    SubTitle = "Doors - Lonely Hub",
    Footer = "Shinzzyak/Reicht",
    MenuKey = Enum.KeyCode.LeftControl,
    ConfigFolder = SAVE_FOLDER,
    Language = "Auto",
    Theme = "Overworld",
    Size = Vector2.new(640, 480),
})

local Options = Library.Options
local Toggles = Options

Library.MainColor = Library.MainColor or Color3.fromRGB(20, 20, 25)
Library.FontColor = Library.FontColor or Color3.fromRGB(235, 235, 240)
Library.AccentColor = Library.AccentColor or Color3.fromRGB(120, 170, 255)
Library.IsMobile = (Library.IsMobile ~= nil) and Library.IsMobile or UserInputService.TouchEnabled
Library.Signals = Library.Signals or {}
function Library:GiveSignal(connection)
    table.insert(self.Signals, connection)
    return connection
end
function Library:GiveSignalOnce(connection)
    return self:GiveSignal(connection)
end

local function Conv(info)
    if type(info) ~= "table" then return info end
    local out = {}
    for key, value in pairs(info) do out[key] = value end
    if out.Text == nil then out.Text = out.Title or out.Name end
    return out
end

local function LinGroup(groupbox)
    local g = {}
    local function widget(name)
        return function(_, idx, info)
            return groupbox[name](groupbox, idx, Conv(info))
        end
    end
    g.AddToggle = widget("AddToggle")
    g.AddSlider = widget("AddSlider")
    g.AddInput = widget("AddInput")
    g.AddDropdown = widget("AddDropdown")
    g.AddKeybind = widget("AddKeybind")
    g.AddColorPicker = widget("AddColorPicker")
    -- Linoria accepts both AddButton({Text=, Func=}) and AddButton("Text", fn).
    function g:AddButton(first, second)
        local spec
        if type(first) == "string" then
            spec = { Text = first, Func = second }
        else
            spec = Conv(first)
            spec.Func = spec.Func or spec.Callback
            spec.Callback = nil
        end
        return groupbox:AddButton(spec)
    end
    function g:AddLabel(text, wrapFlag)
        return groupbox:AddLabel(text, wrapFlag)
    end
    function g:AddDivider()
        return groupbox:AddDivider()
    end
    return g
end

local function LinTabbox(tab, side)
    local box = {}
    function box:AddTab(name)
        local groupbox
        if side == "left" then
            groupbox = tab:AddLeftGroupbox(name)
        else
            groupbox = tab:AddRightGroupbox(name)
        end
        return LinGroup(groupbox)
    end
    return box
end


-- MS-ESP is no longer served upstream (the URL 404s), so the small surface the
-- body uses is implemented here: Highlight instances with the same spec keys,
-- plus the three global toggles the Settings tab drives.
local ESPLibrary = { Instances = {}, Tracers = { Value = false }, Rainbow = { Value = false }, Distance = { Value = false }, Thickness = { Value = 1 }, Text = { Value = true } }
do
    local ESP = {}
    function ESP.Highlight(spec)
        spec = spec or {}
        local model = spec.Model
        local instance = { Spec = spec, Visible = true, Destroyed = false }
        local highlight = Instance.new("Highlight")
        highlight.Name = "ReichtESP"
        highlight.FillColor = spec.FillColor or Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = spec.OutlineColor or spec.FillColor or Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = spec.FillTransparency or 0.5
        highlight.OutlineTransparency = spec.OutlineTransparency or 0
        highlight.Adornee = model
        highlight.Parent = model
        instance.Highlight = highlight
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ReichtESPName"
        billboard.Size = UDim2.fromOffset(200, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0) + (spec.StudsOffset or Vector3.new())
        billboard.AlwaysOnTop = true
        billboard.Adornee = model
        local label = Instance.new("TextLabel")
        label.Name = "ReichtESPText"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = spec.Font or Enum.Font.Code
        label.TextSize = spec.TextSize or 16
        label.TextTransparency = spec.TextTransparency or 0
        label.TextStrokeTransparency = spec.TextStrokeTransparency or 1
        label.TextColor3 = spec.TextColor or spec.FillColor or Color3.fromRGB(255, 255, 255)
        label.Text = tostring(spec.Name or "")
        label.Parent = billboard
        billboard.Parent = model
        instance.Label = label
        instance.Billboard = billboard
        function instance:SetTracer(on)
            self.TracerOn = on
            if on and not self.Tracer and Drawing and Drawing.new then
                local tracer = Drawing.new("Line")
                tracer.Thickness = ESPLibrary.Thickness.Value
                tracer.Color = highlight.FillColor
                tracer.Visible = true
                self.Tracer = tracer
            elseif not on and self.Tracer then
                self.Tracer:Remove()
                self.Tracer = nil
            end
        end
        function instance:SetThickness(value)
            self.TracerThickness = value
            if self.Tracer then self.Tracer.Thickness = value end
        end
        function instance:SetRainbow(on) self.RainbowOn = on end
        -- The decrypted hubs ship a "show entity text" switch (ESPShowEntityText);
        -- the highlight stays, only the floating name goes away.
        function instance:SetText(on)
            self.TextOn = on ~= false
            if billboard then billboard.Enabled = self.TextOn and self.Visible ~= false end
        end
        function instance:SetDistance(on)
            self.DistanceOn = on
            local base = tostring(spec.Name or "")
            local camera = workspace.CurrentCamera
            if on and model and model.PrimaryPart and camera then
                label.Text = base .. " [" .. math.floor((camera.CFrame.Position - model.PrimaryPart.Position).Magnitude) .. "]"
            else
                label.Text = base
            end
        end
        function instance:Update(fields)
            fields = fields or {}
            if fields.FillTransparency then highlight.FillTransparency = fields.FillTransparency end
            if fields.OutlineTransparency then highlight.OutlineTransparency = fields.OutlineTransparency end
            if fields.FillColor then highlight.FillColor = fields.FillColor end
            if fields.TextSize then label.TextSize = fields.TextSize end
            if fields.Font then label.Font = fields.Font end
            if fields.TextTransparency then label.TextTransparency = fields.TextTransparency end
            if fields.TextStrokeTransparency then label.TextStrokeTransparency = fields.TextStrokeTransparency end
            self.TracerOrigin = fields.TracerOrigin or self.TracerOrigin
            if fields.Thickness then self:SetThickness(fields.Thickness) end
        end
        function instance:SetVisible(visible)
            self.Visible = visible ~= false
            highlight.Enabled = self.Visible
            billboard.Enabled = self.Visible and self.TextOn ~= false
            if self.Tracer then self.Tracer.Visible = self.Visible end
        end
        function instance:Remove()
            if self.Destroyed then return end
            self.Destroyed = true
            if self.Tracer then self.Tracer:Remove() self.Tracer = nil end
            highlight:Destroy()
            billboard:Destroy()
            if type(spec.OnDestroy) == "function" then Safe(spec.OnDestroy) end
        end
        instance.Destroy = instance.Remove
        table.insert(ESPLibrary.Instances, instance)
        instance:SetTracer(ESPLibrary.Tracers.Value)
        instance:SetRainbow(ESPLibrary.Rainbow.Value)
        instance:SetText(ESPLibrary.Text.Value)
        instance:SetDistance(ESPLibrary.Distance.Value)
        instance:SetThickness(ESPLibrary.Thickness.Value)
        return instance
    end
    ESPLibrary.ESP = ESP
    function ESPLibrary.Tracers.Set(value)
        ESPLibrary.Tracers.Value = value
        for _, instance in ipairs(ESPLibrary.Instances) do instance:SetTracer(value) end
    end
    function ESPLibrary.Rainbow.Set(value)
        ESPLibrary.Rainbow.Value = value
        for _, instance in ipairs(ESPLibrary.Instances) do instance:SetRainbow(value) end
    end
    function ESPLibrary.Distance.Set(value)
        ESPLibrary.Distance.Value = value
        for _, instance in ipairs(ESPLibrary.Instances) do instance:SetDistance(value) end
    end
    function ESPLibrary.Text.Set(value)
        ESPLibrary.Text.Value = value
        for _, instance in ipairs(ESPLibrary.Instances) do instance:SetText(value) end
    end
    function ESPLibrary.Thickness.Set(value)
        ESPLibrary.Thickness.Value = value
        for _, instance in ipairs(ESPLibrary.Instances) do instance:SetThickness(value) end
    end
    RunService.RenderStepped:Connect(function()
        if ESPLibrary.Rainbow.Value then
            local hue = (tick() % 5) / 5
            local color = Color3.fromHSV(hue, 1, 1)
            for _, instance in ipairs(ESPLibrary.Instances) do
                if instance.Visible and instance.Highlight then
                    instance.Highlight.FillColor = color
                    instance.Highlight.OutlineColor = color
                end
            end
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        for _, instance in ipairs(ESPLibrary.Instances) do
            local tracer = instance.Tracer
            if tracer then
                local part = instance.Spec.Model and instance.Spec.Model.PrimaryPart
                local point, onScreen = nil, false
                if part then point, onScreen = camera:WorldToViewportPoint(part.Position) end
                if onScreen and instance.Visible then
                    local vp = camera.ViewportSize
                    local fx, fy = vp.X / 2, vp.Y
                    local origin = instance.TracerOrigin or "Bottom"
                    if origin == "Center" then fx, fy = vp.X / 2, vp.Y / 2
                    elseif origin == "Top" then fx, fy = vp.X / 2, 0
                    elseif origin == "Mouse" then
                        local mouse = UserInputService and UserInputService.GetMouseLocation and UserInputService:GetMouseLocation()
                        if mouse then fx, fy = mouse.X, mouse.Y end
                    end
                    tracer.From = Vector2.new(fx, fy)
                    tracer.To = Vector2.new(point.X, point.Y)
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            end
        end
    end)
end

-- Entity ESP. The candidate names are the payload's own EntityTable -- BackdoorRush,
-- BackdoorLookman, RushMoving, AmbushMoving, Eyes, JeffTheKiller, A60, A120 plus the
-- side rigs FigureRig / GiggleCeiling / GrumbleRig / Snare. Nothing here is guessed:
-- the game spawns those names, so a match is a live entity.
-- Entity filter. The payload's own entity ESP walks EntityTable and paints every
-- spawn; a decrypted DOORS hub ships the same list behind a SelectedEntities
-- dropdown, so the decision belongs where the scan runs -- not in a second ESP.
local EntityESPFilter = { Selected = {} }
local ENTITY_FILTER_VALUES, ENTITY_DISPLAY = {}, {}
for _, name in ipairs(EntityTable.Names) do
    local display = EntityTable.ShortNames[name] or name
    table.insert(ENTITY_FILTER_VALUES, display)
    ENTITY_DISPLAY[display] = name
end
for _, name in ipairs(EntityTable.SideNames) do
    table.insert(ENTITY_FILTER_VALUES, name)
    ENTITY_DISPLAY[name] = name
end

-- An empty selection means "everything": the dropdown starts with every entry
-- ticked, and clearing it must not silently switch entity ESP off.
function EntityESPFilter.Allows(entity)
    if not entity then return true end
    local allowed = next(EntityESPFilter.Selected) == nil or EntityESPFilter.Selected[entity.Name] == true
    Safe(function() entity:SetAttribute("ReichtEntityESPFilter", allowed and "on" or "off") end)
    return allowed
end

function EntityESPFilter.Set(selection)
    EntityESPFilter.Selected = {}
    for key, entry in pairs(selection or {}) do
        local display = type(key) == "number" and entry or key
        local spawnName = ENTITY_DISPLAY[display]
        if spawnName then EntityESPFilter.Selected[spawnName] = true end
    end
end

-- Language for the names ESP writes on screen. Kept separate from the entity filter:
-- the filter decides *what* is shown, this decides what it is called.
local EntityLanguage = { Current = "EN" }

function EntityLanguage.Set(language)
    EntityLanguage.Current = EntityTable.Localized[language] and language or "EN"
end

function EntityLanguage.Name(entityName)
    local table_ = EntityTable.Localized[EntityLanguage.Current]
    return table_ and table_[entityName] or nil
end

-- Re-label what is already on screen. Without this the switch only affects entities
-- that spawn afterwards, which reads as "the toggle does nothing" mid-round.
function EntityLanguage.Relabel()
    for _, list in pairs(Script.ESPTable) do
        for _, esp in pairs(list) do
            local entity = esp.Spec and esp.Spec.Model
            local label = esp.Label
            if entity and label then
                local text = EntityLanguage.Name(entity.Name) or esp.Spec.Name
                label.Text = tostring(text or "")
            end
        end
    end
end

-- Infinite Items filter. The decrypted hub gates its infinite-item action behind a
-- chosen item list (SelectedItems / InfiniteItemsSelected / IsInfItemTarget); the
-- library has no multi-select over runtime item ids, so the list arrives as text.
local ItemFilter = { Selected = {} }

function ItemFilter.Set(text)
    ItemFilter.Selected = {}
    for token in tostring(text or ""):gmatch("[^,;]+") do
        local clean = token:match("^%s*(.-)%s*$"):lower()
        if clean ~= "" then ItemFilter.Selected[clean] = true end
    end
end

function ItemFilter.Allows(tool)
    if not tool then return false end
    local allowed
    if next(ItemFilter.Selected) == nil then
        allowed = true
    else
        allowed = false
        local id = tool:GetAttribute("ID")
        for _, candidate in ipairs({ id, tool.Name }) do
            if type(candidate) == "string" and ItemFilter.Selected[candidate:lower()] then allowed = true end
        end
    end
    -- Same contract as the entity filter: the decision is published on the object so
    -- the rest of the hub (and the run's evidence) can see which branch was taken.
    Safe(function() tool:SetAttribute("ReichtInfItemTarget", allowed and "on" or "off") end)
    return allowed
end

-- The body's epilog drives these two; the hub's own settings tab already covers
-- theme, scale, configs and unload, so the shims only accept the calls.
local ThemeManager = {}
function ThemeManager:SetLibrary() end
function ThemeManager:ApplyToTab() end
function ThemeManager:SetFolder() end
local SaveManager = {}
function SaveManager:SetLibrary() end
function SaveManager:SetFolder() end
function SaveManager:IgnoreThemeSettings() end
function SaveManager:SetIgnoreIndexes() end
function SaveManager:BuildConfigSection() end
function SaveManager:LoadAutoloadConfig()
    Safe(function() return Library:LoadAutoloadConfig() end)
end

-- Tab order, titles and icons follow the upstream menu so every groupbox keeps
-- its original position; the chrome is Reicht's.

-- Rich presence, the one tail hook the loader calls.
function Script.Functions.UpdateRPC()
    if not getgenv().BloxstrapRPC then return end

    local roomNumberPrefix = "Room "
    local prettifiedRoomNumber = currentRoom

    if isBackdoor then
        prettifiedRoomNumber = -50 + currentRoom
    end

    if isMines then
        prettifiedRoomNumber += 100
    end

    prettifiedRoomNumber = tostring(prettifiedRoomNumber)

    if isRooms then
        roomNumberPrefix = "A-"
        prettifiedRoomNumber = string.format("%03d", prettifiedRoomNumber)
    end

    BloxstrapRPC.SetRichPresence({
        details = "Playing DOORS [ Lonely Hub]",
        state = roomNumberPrefix .. prettifiedRoomNumber .. " (" .. (PrettyFloorName[floor.Value] and PrettyFloorName[floor.Value] or ("The " .. floor.Value) ) .. ")",
        largeImage = {
            hoverText = "Using Lonely Hub"
        },
        smallImage = {
            assetId = 6925817108,
            hoverText = localPlayer.Name
        }
    })
end

-- ===== ABYSALL FEATURE LAYER BEGIN =====
local __abysallLayer = function(ReichtLibrary, ReichtWindow)

-- Abysall expects its own component modules (Environment / ESP / Interface) which it
-- normally pulls from GitHub at run time. Those are replaced by thin bindings onto the
-- systems Reicht already runs, so the feature layer behaves the same without a second
-- copy of the ESP renderer or a network fetch inside the payload.
local Abysall = {
    Legit = true,
    SavePath = "Doors/Game",
    UILibrary = "Reicht",
    TotalExecutions = 1,
    Analytics = function() return { Fire = function() end } end,
    Environment = {},
    ESPLibrary = {},
    Interface = { Library = Library },
}

do
    local function has(name)
        return type(rawget(getfenv(0), name) or rawget(_G, name)) == "function"
    end
    -- A capability shim must read as absent when the capability is absent.
    -- Abysall gates twenty features on CheckCompatability({...}), which only asks
    -- whether Abysall.Environment[name] is non-nil. A shim that always handed back a
    -- function made every gate pass on executors that have no such function, so the
    -- layer took its fireproximityprompt path: Functions.FirePrompt became a silent
    -- no-op (the real fallback below never ran) and the lock-prompt branch moved the
    -- real door prompt into the hidden PromptContainer, leaving a client-side clone
    -- on the door. Doors then could not be opened by hand even with the key in hand.
    local function passthrough(name)
        if not has(name) then return nil end
        return function(...)
            local fn = rawget(getfenv(0), name) or rawget(_G, name)
            if type(fn) ~= "function" then return nil end
            local ok, res = pcall(fn, ...)
            if ok then return res end
            return nil
        end
    end
    -- cloneref must always hand the object back: Abysall uses it to build its Services
    -- proxy, so a nil return turns Services.Players into nil and the whole layer dies at
    -- `local LocalPlayer = Services.Players.LocalPlayer`.
    Abysall.Environment.cloneref = function(object)
        local fn = rawget(getfenv(0), "cloneref") or rawget(_G, "cloneref")
        if type(fn) == "function" then
            local ok, ref = pcall(fn, object)
            if ok and ref ~= nil then return ref end
        end
        return object
    end
    Abysall.Environment.fireproximityprompt = passthrough("fireproximityprompt")
    Abysall.Environment.firetouchinterest = passthrough("firetouchinterest")
    Abysall.Environment.getconnections = passthrough("getconnections")
    Abysall.Environment.gethui = passthrough("gethui")
    Abysall.Environment.getnamecallmethod = passthrough("getnamecallmethod")
    Abysall.Environment.hookmetamethod = passthrough("hookmetamethod")
    Abysall.Environment.isnetworkowner = passthrough("isnetworkowner")
    Abysall.Environment.keypress = passthrough("keypress")
    Abysall.Environment.keyrelease = passthrough("keyrelease")
    Abysall.Environment.newcclosure = passthrough("newcclosure")
    Abysall.Environment.replicatesignal = passthrough("replicatesignal")
    Abysall.Environment.require = passthrough("require")
    Abysall.Environment.setclipboard = passthrough("setclipboard")
    Abysall.Environment.writefile = passthrough("writefile")
    Abysall.Environment.readfile = passthrough("readfile")
    Abysall.Environment.isfile = passthrough("isfile")

    -- ESP bridge. Abysall owns nothing here: it drives this table as if it were its own
    -- renderer, while the drawing is done by Reicht's ESP.Highlight so the Settings tab
    -- keeps its say. The signatures below are Abysall's, verbatim -- AddESP takes ONE
    -- options table, RemoveESP takes the raw object, ColorTable is a real table.
    local LocalESP = ESPLibrary.ESP
    local ESP = {
        Objects = {},
        Order = {},
        ColorTable = {},
        TextTable = {},
        Settings = {
            Rainbow = false, Tracers = false, ShowDistance = false, Arrows = false,
            TextTransparency = 0, FillTransparency = 0.75, OutlineTransparency = 0,
            TextOutlineTransparency = 0, FadeTime = 0, RenderLimit = 240,
            TracerSize = 0.5, ArrowRadius = 200, TextSize = 20, DistanceSizeRatio = 1,
            Font = nil, TracerOrigin = "Bottom",
        },
    }
    local S = ESP.Settings
    local function setter(key)
        return function(_, value) S[key] = value end
    end
    -- ponytail: Arrows/ArrowRadius need triangle drawings, DistanceSizeRatio needs per-frame
    -- distance rescaling, FadeTime needs a fade pass after removal -- the shared engine has
    -- none of those primitives yet, so these three stay stored-only.
    for _, key in ipairs({ "Arrows", "ArrowRadius", "FadeTime", "DistanceSizeRatio" }) do
        ESP["Set" .. key] = setter(key)
    end
    local function each(apply)
        for _, entry in pairs(ESP.Objects) do
            if entry.Instance then apply(entry.Instance) end
        end
    end
    local function cap()
        while #ESP.Order > (S.RenderLimit or 0) do
            local object = table.remove(ESP.Order, 1)
            if object then ESP.RemoveESP(ESP, object) end
        end
    end
    ESP.SetRenderLimit = function(_, value)
        S.RenderLimit = value
        cap()
    end
    ESP.SetTextSize = function(_, value)
        S.TextSize = value
        each(function(inst) inst:Update({ TextSize = value }) end)
    end
    ESP.SetTextTransparency = function(_, value)
        S.TextTransparency = value
        each(function(inst) inst:Update({ TextTransparency = value }) end)
    end
    ESP.SetTextOutlineTransparency = function(_, value)
        S.TextOutlineTransparency = value
        each(function(inst) inst:Update({ TextStrokeTransparency = value }) end)
    end
    ESP.SetFillTransparency = function(_, value)
        S.FillTransparency = value
        each(function(inst) inst:Update({ FillTransparency = value }) end)
    end
    ESP.SetOutlineTransparency = function(_, value)
        S.OutlineTransparency = value
        each(function(inst) inst:Update({ OutlineTransparency = value }) end)
    end
    ESP.SetFont = function(_, value)
        S.Font = value
        each(function(inst) inst:Update({ Font = value }) end)
    end
    ESP.SetTracerOrigin = function(_, value)
        S.TracerOrigin = value
        each(function(inst) inst:Update({ TracerOrigin = value }) end)
    end
    -- Abysall spells one of the two; the upstream switcher has one key. Both land there.
    ESP.SetTracersOrigin = ESP.SetTracerOrigin
    -- Live knobs: these reach the renderer instead of parking in Settings.
    ESP.SetRainbow = function(_, value)
        S.Rainbow = value
        ESPLibrary.Rainbow.Set(value)
    end
    ESP.SetTracers = function(_, value)
        S.Tracers = value
        ESPLibrary.Tracers.Set(value)
    end
    ESP.SetShowDistance = function(_, value)
        S.ShowDistance = value
        ESPLibrary.Distance.Set(value)
    end
    ESP.SetTracerSize = function(_, value)
        S.TracerSize = value
        ESPLibrary.Thickness.Set(value)
    end
    ESP.GenerateRandomString = function(_, length)
        local out = {}
        for i = 1, (length or 8) do out[i] = string.char(math.random(97, 122)) end
        return table.concat(out)
    end
    ESP.SetColorTable = function(_, name, color)
        ESP.ColorTable[name] = color
    end
    ESP.UpdateObjectText = function(_, object, text)
        local entry = ESP.Objects[object]
        if not entry then return end
        ESP.TextTable[object] = text
        if entry.Instance and entry.Instance.Label then entry.Instance.Label.Text = tostring(text or "") end
    end
    ESP.UpdateObjectColor = function(_, object, color)
        ESP.ColorTable[object] = color
        local entry = ESP.Objects[object]
        if entry and entry.Instance then entry.Instance:Update({ FillColor = color }) end
    end
    ESP.AddESP = function(_, parameters)
        parameters = type(parameters) == "table" and parameters or nil
        if not parameters then return end
        local object = parameters.Object
        if not object or ESP.Objects[object] then return end
        local color = parameters.Color
            or ESP.ColorTable[object]
            or Color3.fromRGB(255, 255, 255)
        local text = parameters.Text or ""
        local instance = Safe(function()
            return LocalESP.Highlight({
                Model = object,
                FillColor = color,
                FillTransparency = parameters.FillTransparency or S.FillTransparency,
                OutlineTransparency = parameters.OutlineTransparency or S.OutlineTransparency,
                Text = text,
                Name = text,
                TextSize = S.TextSize,
                TextStrokeTransparency = S.TextOutlineTransparency,
                Font = S.Font,
            })
        end)
        if not instance then return end
        ESP.Objects[object] = { Instance = instance }
        ESP.ColorTable[object] = color
        ESP.TextTable[object] = text
        table.insert(ESP.Order, object)
        cap()
    end
    ESP.RemoveESP = function(_, object)
        local entry = ESP.Objects[object]
        if not entry then return end
        ESP.Objects[object] = nil
        ESP.ColorTable[object] = nil
        ESP.TextTable[object] = nil
        if entry.Instance then Safe(function() entry.Instance:Remove() end) end
    end
    ESP.Unload = function()
        for object in pairs(ESP.Objects) do ESP.RemoveESP(ESP, object) end
    end
    Abysall.ESPLibrary = ESP
end

-- Obsidian widgets Reicht's library does not ship: a Tabbox (a strip of tabs, each one a
-- groupbox) and a KeyPicker (a keybind hanging off a toggle). Both are rebuilt on the
-- widget set Reicht already has, so the controls that use them still register instead of
-- taking the whole tab down with a missing-method error.
do
    local function patchGroupbox(groupbox)
        if type(groupbox) ~= "table" or groupbox.__reichtPatched then return groupbox end
        groupbox.__reichtPatched = true
        local rawToggle = groupbox.AddToggle
        if type(rawToggle) == "function" then
            groupbox.AddToggle = function(self, ...)
                local toggle = rawToggle(self, ...)
                if type(toggle) == "table" and toggle.AddKeyPicker == nil then
                    toggle.AddKeyPicker = function(t, idx, info)
                        local container = t.Container or self
                        return container:AddKeybind(idx, info or {})
                    end
                end
                return toggle
            end
        end
        return groupbox
    end

    local rawAddTab = ReichtWindow.AddTab
    if type(rawAddTab) == "function" then
        ReichtWindow.AddTab = function(self, ...)
            local tab = rawAddTab(self, ...)
            if type(tab) ~= "table" then return tab end
            local rawLeft, rawRight = tab.AddLeftGroupbox, tab.AddRightGroupbox
            if type(rawLeft) == "function" then
                tab.AddLeftGroupbox = function(_, ...) return patchGroupbox(rawLeft(tab, ...)) end
            end
            if type(rawRight) == "function" then
                tab.AddRightGroupbox = function(_, ...) return patchGroupbox(rawRight(tab, ...)) end
            end
            local function tabbox(side)
                local box = {}
                function box:AddTab(name)
                    if side == "Left" and type(rawLeft) == "function" then
                        return patchGroupbox(rawLeft(tab, name))
                    elseif type(rawRight) == "function" then
                        return patchGroupbox(rawRight(tab, name))
                    end
                    return nil
                end
                return box
            end
            tab.AddLeftTabbox = function() return tabbox("Left") end
            tab.AddRightTabbox = function() return tabbox("Right") end
            return tab
        end
    end
end

-- Abysall indexes its widget tables with variables -- Toggles[ToggleName],
-- Options[ColorKey], Toggles[ToggleMap[Name]] -- and this layer's controls live under
-- `ab_`-prefixed ids, so a bare-name lookup returns nil and the next `:OnChanged` call
-- dies. Falling back to the prefixed id keeps every dynamic key site working without
-- rewriting each of them.
for _, widgetTable in ipairs({ Library.Toggles, Library.Options }) do
    if type(widgetTable) == "table" and getmetatable(widgetTable) == nil then
        setmetatable(widgetTable, {
            __index = function(t, key)
                if type(key) == "string" then return rawget(t, "ab_" .. key) end
                return nil
            end,
        })
    end
end

local ReichtStubs = {
    SaveManager = { Save = function() end, Load = function() end, Ignore = function() end },
    ThemeManager = { SetTheme = function() end, GetThemes = function() return {} end },
}
-- Abysall's prelude (the loader lines this splice drops) is where LoadStart comes from; the
-- layer's final notification subtracts it from tick() and would otherwise do math on nil.
local LoadStart = tick()
local ReichtLibrary = Library
local ReichtWindow = Window

    local Library = ReichtLibrary
    local SaveManager = ReichtStubs.SaveManager
    local ThemeManager = ReichtStubs.ThemeManager

    local Toggles = Library.Toggles
    local Options = Library.Options

    local function CloneReference(Object)
    	if Abysall and Abysall.Environment.cloneref then
    		return Abysall.Environment.cloneref(Object)
    	end
    	return Object
    end

    local Services = setmetatable({}, {
    	__index = function(Self, Name)
    		return CloneReference(game:GetService(Name))
    	end
    })



    -- archives and stairwell locals
    local TimeShowerSourceLabel
    local TimeShowerToken = 0
    local TimeShowerConnection
    local BypassDronesStampedeConnection
    local HonchoCorrectBoxConnection
    local HonchoAutoDepositConnection
    local HonchoESPObjects = {}
    local HonchoProcessedRooms = {}
    local HonchoDepositCache = {}
    local AntiClosetTrash_Connection
    local AntiRansom_Connection
    local ForgetMeNotConnection
    local ForgetMeNotRunning = false
    local ForgetMeNotProcessing = {}
    local ForgetMeNotNotified = {}
    local WaterBypassConnection
    local WaterParts = {}
    local AlmaConnection
    local AntiScribbles_Connection
    local DroneConnection
    local DroneWalkedIntoParents = {}
    local OrbitDroppedItemsConnection
    local OrbitDroppedItemsAngle = 0
    local OrbitDroppedItemsLastTeleport = 0
    local OrbitDroppedItemsPauseUntil = 0
    local droppedItemsIntervalRunning = false
    local Connections = {}



    local Globals = {}
    local Connections = {}
    local ESPConnections = {}
    local Groupboxes = {}
    local FakePrompts = {}
    local Functions = {}
    local PartProperties = {}

    local Objects = {
    	Prompts = {},
    	Objectives = {},
    	Doors = {},
    	HidingSpots = {},
    	Entities = {},
    	SeekObstructions = {},
    	Items = {},
    	Chests = {},
    	Currency = {},
    	Ladders = {},
    	Misc = {},
    	Obstructions = {},
    	EventTriggers = {},
    	JumpscareModules = {},
    	SeekHighlights = {},
    	EyestalkHighlights = {},
    	SeekNodes = {},
    	SeekDuckBoards = {},
    	SeekBridges = {},
    	PathLights = {}
    }

    Globals.IncompatibleMessage = "Your executor doesn't support this feature."

    Functions.CheckCompatability = function(Array)
    	for _, Name in Array do
    		if not Abysall.Environment[Name] then
    			return false
    		end
    	end
    	return true
    end



    local LocalPlayer = Services.Players.LocalPlayer


    local PortraitName = "MirrorRig_Portrait_" .. LocalPlayer.Name


    local Entities = {
    	["TV_Stand"] = {
    		Alias = "Noise_TV",
    		NotifyMessage = { Title = "Noise tv spawned.", Body = "Dont get near it" }
    	},
    	[PortraitName] = {
    		Alias = "Portrait",
    		NotifyMessage = { Title = "Portrait' has spawned.", Body = "Use him to duplicate items." }
    	},
    	["StemsEntity"] = {
    	    Alias = 'Balls',
    		NotifyMessage = { Title = "Balls", Body = "Balls."}
    	},
    	["NoiseModel"] = {
    		Alias = 'Noise',
    		NotifyMessage = { Title = "Entity 'Noise' has spawned.", Body = "Dont let it touch you." }
    	},
    	["Creak"] = {
    		Alias = "Creak",
    		NotifyMessage = { Title = "Entity 'Creak' has spawned.", Body = "Dont touch him." }
    	},
    	["DronesStampede"] = {
    		Alias = "DronesStampede",
    		NotifyMessage = { Title = "Entity 'Drones Stampede' has spawned.", Body = "Find a hiding spot." }
    	},
    	["TellerRig"] = {
    		Alias = "Teller",
    		NotifyMessage = { Title = "Entity 'Teller' has spawned.", Body = "Dont worry, hes only annoying." }
    	},
    	["Scribbles"] = {
    		Alias = "Scribbles",
    		NotifyMessage = { Title = "Entity 'Scribbles' has spawned.", Body = "Find a hiding spot." }
    	},
    	["BashMoving"] = {
    		Alias = "Bash",
    		NotifyMessage = { Title = "Entity 'Bash' has spawned.", Body = "Find a hiding spot."}
    	},
    	["RushMoving"] = {
    		Alias = "Rush",
    		NotifyMessage = { Title = "Entity 'Rush' has spawned.", Body = "Find a hiding spot." }
    	},
    	["AmbushMoving"] = {
    		Alias = "Ambush",
    		NotifyMessage = { Title = "Entity 'Ambush' has spawned.", Body = "Find a hiding spot." }
    	},
    	["Eyes"] = {
    		Alias = "Eyes",
    		NotifyMessage = { Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it." }
    	},
    	["Lookman"] = {
    		Alias = "Eyes",
    		NotifyMessage = { Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it." }
    	},
    	["BackdoorRush"] = {
    		Alias = "Blitz",
    		NotifyMessage = { Title = "Entity 'Blitz' has spawned.", Body = "Find a hiding spot." }
    	},
    	["BackdoorLookman"] = {
    		Alias = "Lookman",
    		NotifyMessage = { Title = "Entity 'Lookman' has spawned.", Body = "Avoid looking at its eyes." }
    	},
    	["Groundskeeper"] = {
    		Alias = "Groundskeeper",
    		NotifyMessage = { Title = "Entity 'Groundskeeper' has spawned.", Body = "Avoid stepping on the grass." }
    	},
    	["A60"] = {
    		Alias = "A-60",
    		NotifyMessage = { Title = "Entity 'A-60' has spawned.", Body = "Find a hiding spot." }
    	},
    	["A120"] = {
    		Alias = "A-120",
    		NotifyMessage = { Title = "Entity 'A-120' has spawned.", Body = "Find a hiding spot." }
    	},
    	["GloombatSwarm"] = {
    		Alias = "Gloombat Swarm",
    		NotifyMessage = { Title = "Entity 'Gloombat Swarm' has spawned.", Body = "Keep all light sources turned off." }
    	},
    	["GlitchRush"] = {
    		Alias = "RNIUSHCG==",
    		NotifyMessage = { Title = "Entity 'RNIUSHCG==' has spawned.", Body = "Find a hiding spot." }
    	},
    	["GlitchAmbush"] = {
    		Alias = "AR0xMBUSH",
    		NotifyMessage = { Title = "Entity 'AR0xMBUSH' has spawned.", Body = "Find a hiding spot." }
    	},
    	["MonumentEntity"] = {
    		Alias = "Monument",
    		NotifyMessage = { Title = "Entity 'Monument' has spawned.", Body = "It can't move while you are looking at it." }
    	},
    	["JeffTheKiller"] = {
    		Alias = "Jeff the Killer",
    		NotifyMessage = { Title = "Entity 'Jeff the Killer' has spawned.", Body = "Avoid touching him." }
    	},
    	["CustomEntity"] = {
    		Alias = "Custom Entity",
    		NotifyMessage = { Title = "Entity 'Custom Entity' has spawned.", Body = "Find a hiding spot." }
    	},
    	["FrozenAmbush"] = {
    		Alias = "Frozen Ambush",
    		NotifyMessage = { Title = "Entity 'Frozen Ambush' has spawned.", Body = "Find a hiding spot." }
    	},
    	["SallyMoving"] = {
    		Alias = "Sally",
    		NotifyMessage = { Title = "Entity 'Sally' has spawned.", Body = "Find her horse and rop it." }
    	}
    }

    local EntityIcons = {
    	["RushMoving"]      = "rbxassetid://10716032262",
    	["AmbushMoving"]    = "rbxassetid://10110576663",
    	["A60"]             = "rbxassetid://12571092295",
    	["A120"]            = "rbxassetid://12711591665",
    	["BackdoorRush"]    = "rbxassetid://16602023490",
    	["Eyes"]            = "rbxassetid://10183704772",
    	["Lookman"]         = "rbxassetid://10183704772",
    	["BackdoorLookman"] = "rbxassetid://16764872677",
    	["GloombatSwarm"]   = "rbxassetid://79221203116470",
    	["Halt"]            = "rbxassetid://11331795398",
    	["JeffTheKiller"]   = "rbxassetid://94479432156278",
    	["GlitchRush"]      = "rbxassetid://73859273102919",
    	["GlitchAmbush"]    = "rbxassetid://88369678433359",
    	["SallyMoving"]     = "rbxassetid://10840888070",
    	["MonumentEntity"]  = "rbxassetid://88933556873017",
    	["Groundskeeper"]   = "rbxassetid://114991380115557"
    }

    local ItemNames = {
    	["AbrahamHat"]        = "Hat",
    	["LargeScrew"]        = "Screw",
    	["DinkyLamp"]         = "Lamp",
    	["BottleCrate"]       = "18+ Bottles",
    	["GweenSodaPack"]     = "Gween Soda Pack",
    	["BrokenMonitor"]     = "Broken Monitor",
    	["JerryCan"]          = "Jerry Can",
     	["SallyToyObtain"]    = "Sally Toy",
    	["Leftovers"]         = "Lunch Box",
    	["HoneyPot"]          = "Honey Pot",
    	["FihFlakes"]         = "Fih Food",
    	["SecretCD"]          = "CD Disc",
    	["Pizza"]             = "Pizza",
    	["PaperPlanePickup"]  = "Paper Plane",
    	["Lighter"]           = "Lighter",
    	["Flashlight"]        = "Flashlight",
    	["Lockpick"]          = "Lockpicks",
    	["Vitamins"]          = "Vitamins",
    	["Bandage"]           = "Bandage",
    	["StarVial"]          = "Starlight Vial",
    	["StarBottle"]        = "Starlight Bottle",
    	["StarJug"]           = "Starlight Barrel",
    	["Shakelight"]        = "Gummy Flashlight",
    	["Straplight"]        = "Straplight",
    	["Bulklight"]         = "Spotlight",
    	["Battery"]           = "Battery",
    	["Candle"]            = "Candle",
    	["Crucifix"]          = "Crucifix",
    	["CrucifixWall"]      = "Crucifix",
    	["Glowsticks"]        = "Glowstick",
    	["SkeletonKey"]       = "Skeleton Key",
    	["Candy"]             = "Candy",
    	["ShieldMini"]        = "Mini Shield Potion",
    	["ShieldBig"]         = "Big Shield Potion",
    	["BandagePack"]       = "Bandage Pack",
    	["BatteryPack"]       = "Battery Pack",
    	["RiftCandle"]        = "Moonlight Candle",
    	["LaserPointer"]      = "Laser Pointer",
    	["HolyGrenade"]       = "Holy Hand Grenade",
    	["Shears"]            = "Shears",
    	["Smoothie"]          = "Smoothie",
    	["Cheese"]            = "Cheese",
    	["Bread"]             = "Bread",
    	["AlarmClock"]        = "Alarm Clock",
    	["RiftSmoothie"]      = "Moonlight Smoothie",
    	["GweenSoda"]         = "Gween Soda",
    	["GlitchCube"]        = "Glitch Fragment",
    	["Scanner"]           = "Tablet",
    	["Bomb"]              = "Bomb",
    	["Knockbomb"]         = "Knockbomb",
    	["Nanner"]            = "Nanner",
    	["BigBomb"]           = "Big Bomb",
    	["SnakeBox"]          = "Hiding Box",
    	["GoldGun"]           = "Golden Gun",
    	["StopSign"]          = "Stop Sign",
    	["TipJar"]            = "Tip Jar",
    	["Lantern"]           = "Lantern",
    	["IronKey"]           = "Iron Key",
    	["LotusPetal"]        = "Lotus Petal",
    	["Compass"]           = "Compass",
    	["LotusPetalPickup"]  = "Lotus Petal",
    	["LanternLitItem"]    = "Lantern",
    	["KeyIron"]           = "Iron Key",
    	["IronKeyForCrypt"]   = "Iron Key",
    	["LotusHolder"]       = "Lotus Petal",
    	["Multitool"]         = "Multitool",
    	["RiftJar"]           = "Rift Jar",
    	["AloeVera"]          = "Aloe Vera",
    	["Donut"]             = "Donut",
    	["Lotus"]             = "Lotus",
    	["BoxingGloves"]      = "Boxing Gloves"
    }

    local CutsceneNames = {
        "Figure",
        "FigureEnd",
        "FigureHotelEnd",
        "FigureHotelFire",
        "SeekIntroFools",
        "SeekIntroHotel",
        "SeekIntroMines",
        "SeekIntroMines2",
        "SerewSeekDrain",
        "SewerSeekLower",
        "GrumbleNestEnd",
        "EyestalkIntro",
    }

    -- Handlers registered below read these on every heartbeat, long before
    -- CharacterAdded fires. Seed them from the character the player already has so a
    -- heartbeat that lands first cannot index nil and kill its own connection.
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

    local Collision
    local CollisionClone
    local CollisionPart
    local CollisionPartClone

    local Camera = Services.Workspace.CurrentCamera

    local RemotesFolder   = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
    local LiveModifiers   = Services.ReplicatedStorage:FindFirstChild("LiveModifiers")
    local FloorReplicated = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")
    local CurrentRooms    = Services.Workspace:FindFirstChild("CurrentRooms")
    local Drops           = Services.Workspace:FindFirstChild("Drops")
    local GameData        = Services.ReplicatedStorage:WaitForChild("GameData")
    local Floor           = GameData:WaitForChild("Floor").Value
    local LatestRoom      = GameData:WaitForChild("LatestRoom")
    local FinishedLoadingRoom = GameData:FindFirstChild("FinishedLoadingRoom")
    local RunService = game:GetService("RunService")

    if FinishedLoadingRoom then
    	FinishedLoadingRoom:Destroy()
    end

    local function GetHiddenContainer()
    	if Functions.CheckCompatability({"gethui"}) then
    		return Abysall.Environment.gethui()
    	end
    	return Services.CoreGui
    end

    local NotificationLibrary = {
    	LiveNotifications = 0,
    	Notifications = 1
    }

    local Container = Instance.new("ScreenGui")
    Container.Name = Abysall.ESPLibrary:GenerateRandomString()
    Container.Parent = GetHiddenContainer()
    Container.DisplayOrder = 32767
    Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if not Library.Scheme then
    	Library.Scheme = setmetatable({}, {
    		__index = function(Self, Name)
    			return Library[Name]
    		end
    	})
    end

    function NotificationLibrary:Notify(TitleText, Desc, Delay)
    	task.spawn(function()
    		local Notification = Instance.new("Frame")
    		local Line = Instance.new("Frame")
    		local Warning = Instance.new("ImageLabel")
    		local UICorner = Instance.new("UICorner")
    		local UICorner2 = Instance.new("UICorner")
    		local Title = Instance.new("TextLabel")
    		local Description = Instance.new("TextLabel")

    		Notification.Name = "Notification"
    		Notification.Parent = Container
    		Notification.BackgroundColor3 = Library.Scheme.BackgroundColor
    		Notification.BackgroundTransparency = 0.4
    		Notification.BorderSizePixel = 0
    		Notification.Position = UDim2.new(1, 5, 0, 60 + (60 * NotificationLibrary.LiveNotifications))
    		Notification.Size = UDim2.new(0, 420, 0, 50)
    		Notification:SetAttribute("ID", NotificationLibrary.Notifications)
    		Notification:SetAttribute("CurrentPosition", Notification.Position)

    		Line.Name = "Line"
    		Line.Parent = Notification
    		Line.BackgroundColor3 = Library.Scheme.AccentColor
    		Line.BorderSizePixel = 0
    		Line.Position = UDim2.new(0, 0, 1, -3)
    		Line.Size = UDim2.new(0, 0, 0, 3)

    		Warning.Name = "Warning"
    		Warning.Parent = Notification
    		Warning.BackgroundTransparency = 1
    		Warning.Position = UDim2.new(0, 10, 0, 5)
    		Warning.Size = UDim2.new(0, 40, 0, 40)
    		Warning.Image = "rbxassetid://3944668821"
    		Warning.ImageColor3 = Library.Scheme.AccentColor
    		Warning.ScaleType = Enum.ScaleType.Fit

    		UICorner.CornerRadius = UDim.new(0, 20)
    		UICorner.Parent = Warning

    		UICorner2.CornerRadius = UDim.new(0, 4)
    		UICorner2.Parent = Notification

    		Title.Name = "Title"
    		Title.Parent = Notification
    		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    		Title.BackgroundTransparency = 1
    		Title.Position = UDim2.new(0, 60, 0.155, 0)
    		Title.Size = UDim2.new(0, 205, 0, 15)
    		Title.Text = TitleText or "..."
    		Title.TextColor3 = Library.Scheme.FontColor
    		Title.TextSize = 10
    		Title.TextStrokeTransparency = 0.75
    		Title.TextXAlignment = Enum.TextXAlignment.Left

    		Description.Name = "Description"
    		Description.Parent = Notification
    		Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    		Description.BackgroundTransparency = 1
    		Description.Position = UDim2.new(0, 60, 0.483, 0)
    		Description.Size = UDim2.new(0, 205, 0, 18)
    		Description.Text = Desc or "..."
    		Description.TextColor3 = Library.Scheme.FontColor
    		Description.TextTransparency = 0.1
    		Description.TextSize = 10
    		Description.TextStrokeTransparency = 0.75
    		Description.TextXAlignment = Enum.TextXAlignment.Left

    		NotificationLibrary.LiveNotifications += 1
    		NotificationLibrary.Notifications += 1

    		Services.TweenService:Create(
    			Notification,
    			TweenInfo.new(1, Enum.EasingStyle.Exponential),
    			{ Position = UDim2.new(1, -370, 0, Notification.Position.Y.Offset) }
    		):Play()

    		task.wait(0.25)
    		if typeof(Delay) == "Instance" then
    			Delay.Destroying:Wait()
    		else
    			Services.TweenService:Create(
    				Line,
    				TweenInfo.new(Delay - 0.25, Enum.EasingStyle.Linear),
    				{ Size = UDim2.new(0, 400, 0, 3) }
    			):Play()
    			task.wait(Delay - 0.25)
    		end

    		Notification:SetAttribute("Destroying", true)

    		Services.TweenService:Create(
    			Notification,
    			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
    			{ Position = UDim2.new(1, 5, 0, Notification.Position.Y.Offset) }
    		):Play()

    		NotificationLibrary.LiveNotifications -= 1

    		local NotifId = Notification:GetAttribute("ID")
    		local NotifY = Notification:GetAttribute("CurrentPosition").Y.Offset

    		for _, Object in Container:GetChildren() do
    			if Object.Name == "Notification"
    				and Object:GetAttribute("ID")
    				and Object:GetAttribute("ID") > NotifId
    				and Object:GetAttribute("Destroying") ~= true
    				and Object.Position.Y.Offset ~= 60
    			then
    				local NewY = Object:GetAttribute("CurrentPosition").Y.Offset - 60
    				Object:SetAttribute("CurrentPosition", UDim2.new(1, -450, 0, NewY))
    				Services.TweenService:Create(
    					Object,
    					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
    					{ Position = UDim2.new(1, -370, 0, NewY) }
    				):Play()
    			end
    		end

    		task.wait(0.75)
    		Notification:Destroy()
    	end)
    end

    Globals.DoorsNotify = function(NotifyOptions)
    	local function PlaySound(Parent, SoundId, Volume)
    		local Sound = Instance.new("Sound")
    		Sound.SoundId = SoundId
    		Sound.Volume = Volume or 1
    		Sound.Parent = Parent
    		task.spawn(function()
    			task.wait(0.1)
    			Sound:Play()
    			Sound.Ended:Wait()
    			Sound:Destroy()
    		end)
    	end

    	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    	local UIContainer = PlayerGui:FindFirstChild("GlobalUI") or PlayerGui:FindFirstChild("MainUI")
    	if not UIContainer then return end

    	local AchievementsHolder = UIContainer:FindFirstChild("AchievementsHolder")
    	if not AchievementsHolder then return end

    	local Achievement = AchievementsHolder.Achievement:Clone()
    	Achievement.Size = UDim2.new(0, 0, 0, 0)
    	Achievement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
    	Achievement.Name = "LiveAchievement"
    	Achievement.Visible = true

    	Achievement.Frame.TextLabel.Text = NotifyOptions.Style or "NOTIFICATION"
    	Achievement.Frame.Details.Title.Text = NotifyOptions.Title or "Sem Título"
    	Achievement.Frame.Details.Desc.Text = NotifyOptions.Description or "Sem Descrição"
    	Achievement.Frame.Details.Reason.Text = NotifyOptions.Reason or ""
    	Achievement.Frame.ImageLabel.Image = (NotifyOptions.Image ~= "" and NotifyOptions.Image) or "rbxassetid://6023426923"

    	local Color = NotifyOptions.Color or Color3.new(1, 1, 1)
    	Achievement.Frame.TextLabel.TextColor3 = Color
    	Achievement.Frame.UIStroke.Color = Color
    	Achievement.Frame.Glow.ImageColor3 = Color
    	Achievement.Parent = AchievementsHolder

    	PlaySound(AchievementsHolder, "rbxassetid://10469938989", 1)

    	task.spawn(function()
    		Achievement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.8, true)
    		task.wait(0.8)
    		Achievement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
    		Services.TweenService:Create(
    			Achievement.Frame.Glow,
    			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    			{ ImageTransparency = 1 }
    		):Play()

    		if typeof(NotifyOptions.Time) == "Instance" then
    			NotifyOptions.Time.Destroying:Wait()
    		else
    			task.wait(NotifyOptions.Time or 5)
    		end

    		Achievement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
    		task.wait(0.5)
    		Achievement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
    		task.wait(0.5)
    		Achievement:Destroy()
    	end)
    end

    Globals.STX = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Components/STX.luau"))()
    Functions.Notify = function(Settings)
    	local HiddenContainer = GetHiddenContainer()

    	if not Settings.Body then
    		Settings.Body = "..."
    	end

    	if not Options.ab_NotifyStyle or Options.ab_NotifyStyle.Value == "Abysall" then
    		local Sound = Instance.new("Sound", HiddenContainer)
    		Sound.SoundId = "rbxassetid://8784885431"
    		Sound.Volume = (Toggles.ab_NotifyPlaySound and Toggles.ab_NotifyPlaySound.Value and Options.ab_NotifySoundVolume.Value) or (Toggles.ab_NotifyPlaySound and 0 or 3)
    		Sound.PlayOnRemove = true
    		Sound:Destroy()
    		NotificationLibrary:Notify(Settings.Title, Settings.Body, Settings.Time or 5)
    	elseif Options.ab_NotifyStyle.Value == "Doors" then
    		local IsEntity = false
    		local EntityName = ""
    		for Index, Object in pairs(Entities) do
    			if Object.NotifyMessage.Title == Settings.Title or Object.NotifyMessage.Body == Settings.Body then
    				IsEntity = true
    				EntityName = Index
    			end
    		end
    		Globals.DoorsNotify({
    			Title = "Abysall Hub",
    			Description = Settings.Title,
    			Reason = Settings.Body,
    			Style = IsEntity and "WARNING" or "NOTIFICATION",
    			Color = IsEntity and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 222, 189),
    			Image = Settings.Image,
    			Time = Settings.Time
    		})
    	elseif Options.ab_NotifyStyle.Value == "STX" then
    		local Sound = Instance.new("Sound", HiddenContainer)
    		Sound.SoundId = "rbxassetid://4590657391"
    		Sound.Volume = (Toggles.ab_NotifyPlaySound and Toggles.ab_NotifyPlaySound.Value and Options.ab_NotifySoundVolume.Value) or (Toggles.ab_NotifyPlaySound and 0 or 3)
    		Sound.PlayOnRemove = true
    		Sound:Destroy()

    		if Settings.Image then
    			Globals.STX:Notify(
    				{Title = "Abysall Hub", Description = Settings.Title .. "\n" .. Settings.Body},
    				{OutlineColor = Library.Scheme.AccentColor,Time = Settings.Time or 5, Type = "image"},
    				{Image = Settings.Image, ImageColor = Color3.fromRGB(255, 255, 255)}
    			)
    		else
    			Globals.STX:Notify(
    				{Title = "Abysall Hub", Description = Settings.Title .. "\n" .. Settings.Body},
    				{OutlineColor = Library.Scheme.AccentColor,Time = Settings.Time or 5, Type = "default"}
    			)
    		end
    	else
    		local Sound = Instance.new("Sound", HiddenContainer)
    		Sound.SoundId = "rbxassetid://4590662766"
    		Sound.Volume = (Toggles.ab_NotifyPlaySound and Toggles.ab_NotifyPlaySound.Value and Options.ab_NotifySoundVolume.Value) or (Toggles.ab_NotifyPlaySound and 0 or 3)
    		Sound.PlayOnRemove = true
    		Sound:Destroy()
    		Library:OldNotify({ Title = Settings.Title, Description = Settings.Body, Time = Settings.Time })
    	end
    end

    Functions.Caption = function(Text, PlaySound)
    	if typeof(PlaySound) ~= "boolean" then
    		PlaySound = true
    	end
    	local CaptionValue = Instance.new("NumberValue")
    	local Caption = Globals.MainUI:WaitForChild("MainFrame"):WaitForChild("Caption"):Clone()
    	local CaptionSound = Globals.MainUI:WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("Reminder"):WaitForChild("Caption")
    	local CaptionSoundClone = CaptionSound:Clone()
    	CaptionSoundClone.Parent = CaptionSound.Parent
    	CaptionSoundClone.Volume = 0.1

    	Caption.Destroying:Connect(function()
    		CaptionValue:Destroy()
    	end)

    	for _, Child in Globals.MainUI:GetChildren() do
    		if Child.Name == "LiveCaption" then
    			Child:Destroy()
    		end
    	end

    	Caption.Parent = Globals.MainUI
    	Caption.Visible = true
    	Caption.Name = "LiveCaption"
    	Caption.Text = Text

    	if PlaySound then
    		CaptionSoundClone:Play()
    	end

    	Services.Debris:AddItem(CaptionSoundClone, 5)

    	local HolderTween = Services.TweenService:Create(CaptionValue, TweenInfo.new(3), { Value = 100 })
    	HolderTween:Play()
    	HolderTween.Completed:Connect(function()
    		CaptionValue:Destroy()
    		Services.TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
    		Services.TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextStrokeTransparency = 1 }):Play()
    	end)
    end

    Functions.GetHasteTime = function()
    	local TimeRemaining = FloorReplicated.DigitalTimer.Value
    	local Minutes = math.floor(TimeRemaining / 60)
    	local Seconds = TimeRemaining - (Minutes * 60)
    	local MinutesText = Minutes < 10 and ("0" .. tostring(Minutes)) or tostring(Minutes)
    	local SecondsText = Seconds < 10 and ("0" .. tostring(Seconds)) or tostring(Seconds)
    	return MinutesText .. ":" .. SecondsText
    end

    Library.OldNotify = Library.Notify
    Library.Notify = function(Data, Body, Time)
    	Functions.Notify({ Title = Body, Time = Time or 5 })
    end

    if not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") then
        Functions.Notify({ Title = "Waiting for the game to load..." })
        for _ = 1, 150 do
            if LocalPlayer.Character and CurrentRooms:FindFirstChildOfClass("Model") then break end
            task.wait()
        end
        task.wait(4)
    end

    if not RemotesFolder then
    	if Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
    		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
    	elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
    		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
    	end
    end

    if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
    	Floor = "OldHotel"
    end

    if not LiveModifiers then
    	LiveModifiers = Instance.new("Folder")
    end

    if not FloorReplicated then
    	FloorReplicated = Instance.new("Folder")
    end

    local FakeEvents = {
    	Screech = Instance.new("RemoteEvent"),
    	Shade   = Instance.new("RemoteEvent"),
    	A90     = Instance.new("RemoteEvent"),
    	Surge   = Instance.new("RemoteEvent"),
    }

    FakeEvents.Screech.Name  = "Screech"
    FakeEvents.Shade.Name    = "ShadeResult"
    FakeEvents.A90.Name      = "A90"
    FakeEvents.Surge.Name    = "SurgeRemote"

    FakeEvents.Screech_Real = RemotesFolder:WaitForChild("Screech")
    FakeEvents.Shade_Real   = RemotesFolder:WaitForChild("ShadeResult")
    FakeEvents.A90_Real     = RemotesFolder:FindFirstChild("A90")
    FakeEvents.Surge_Real   = RemotesFolder:FindFirstChild("SurgeRemote")

    if RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed") then
        local RealRemote = RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed")
        RealRemote:Destroy()

        local FakeRemote = Instance.new("RemoteEvent", RemotesFolder)
        FakeRemote.Name = "FootstepRemoteThatWeNeed"
    end

    Globals.FogInstances = {}
    Globals.OldFog = Services.Lighting.FogEnd

    for _, Object in Services.Lighting:GetChildren() do
    	if Object:IsA("Atmosphere") then
    		Object:SetAttribute("Density_Old", Object.Density)

    		local AtmoConnection = Object:GetPropertyChangedSignal("Density"):Connect(function()
    			if Object.Density ~= 0 then
    				Object:SetAttribute("Density_Old", Object.Density)
    			end
    			if Toggles.ab_RemoveCameraFog.Value then
    				Object.Density = 0
    			end
    		end)

    		Object.Destroying:Once(function()
    			AtmoConnection:Disconnect()
    		end)

    		table.insert(Connections, AtmoConnection)
    		table.insert(Globals.FogInstances, Object)
    	end
    end

    Globals.SeekNodesFolder = Instance.new("Folder", Services.Workspace)
    Globals.SeekNodesFolder.Name = Abysall.ESPLibrary:GenerateRandomString()

    Globals.RoomsNodesFolder = Instance.new("Folder", Services.Workspace)
    Globals.RoomsNodesFolder.Name = Abysall.ESPLibrary:GenerateRandomString()

    Functions.SendChat = function(Message)
    	local Folder = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemEvents") or Instance.new("Folder")
    	local Event = Folder:FindFirstChild("SayMessageRequest") or Instance.new("RemoteEvent")
    	Event:FireServer(Message, "All")
    	local Channel = (Services.TextChatService:FindFirstChild("TextChannels") and Services.TextChatService.TextChannels:FindFirstChild("RBXGeneral")) or Instance.new("TextChannel")
    	Channel:SendAsync(Message)
    end

    Functions.IsCrouching = function()
    	if Floor == "Fools" or Floor == "OldHotel" then
    		return Character:GetAttribute("Crouching")
    	end
    	return CollisionPart.CollisionGroup == "PlayerCrouching"
    end

    Functions.GetInjuriesSpeed = function()
    	return 0.075 * (Humanoid.MaxHealth - Humanoid.Health)
    end

    Functions.GetCurrentSpeed = function()
    	local Speed = 15
    	Speed += Character:GetAttribute("SpeedBoost") or 0
    	Speed += Character:GetAttribute("SpeedBoostBehind") or 0
    	Speed += Character:GetAttribute("SpeedBoostExtra") or 0
    	Speed += (Floor == "Party" and 10 or 0)
    	Speed += (LiveModifiers:FindFirstChild("PlayerFast") and 3 or 0)
    	Speed += (LiveModifiers:FindFirstChild("PlayerFaster") and 6 or 0)
    	Speed += (LiveModifiers:FindFirstChild("PlayerFastest") and 20 or 0)
    	Speed -= (LiveModifiers:FindFirstChild("PlayerSlow") and 3 or 0)
    	Speed -= (LiveModifiers:FindFirstChild("PlayerSlowHealth") and Functions.GetInjuriesSpeed() or 0)
    	if Functions.IsCrouching() then
    		if LiveModifiers:FindFirstChild("PlayerCrouchSlow") then
    			Speed -= 8
    		elseif LiveModifiers:FindFirstChild("PlayerSlow") then
    			Speed -= 8
    		else
    			Speed -= 5
    		end
    	end
    	return Speed
    end

    Functions.GetMousePosition = function()
    	if Library.IsMobile then
    		return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    	end
    	local MouseLocation = Services.UserInputService:GetMouseLocation()
    	return Vector2.new(MouseLocation.X, MouseLocation.Y)
    end

    Functions.FormatOxygen = function(Oxygen)
    	return "Oxygen: " .. (math.floor(Oxygen * 10) / 10) .. "%"
    end

    Functions.IsHidePersistent = function()
    	return Floor == "Mines"
    		or Floor == "Ripple"
    		or Floor == "Party"
    		or LiveModifiers:FindFirstChild("HideLevel2") ~= nil
    end

    Functions.GetPlayerFromMouse = function(TargetPart, MaxDistance)
    	local Closest
    	local ClosestDistance = math.huge

    	for _, Player in Services.Players:GetPlayers() do
    		local Char = Player.Character
    		if Char then
    			local Target = Char:FindFirstChild(TargetPart)
    			if Target then
    				local Result = Camera:WorldToViewportPoint(Target.Position)
    				local ScreenPos = Vector2.new(Result.X, Result.Y)
    				local Distance = (Functions.GetMousePosition() - ScreenPos).Magnitude
    				if Player.Name ~= LocalPlayer.Name and Distance < ClosestDistance and Distance < MaxDistance then
    					Closest = Target
    					ClosestDistance = Distance
    				end
    			end
    		end
    	end
    	return Closest
    end

    local EntityDistances = {
    	["RushMoving"]    = 85,
    	["Scribbles"]	  = 100,
    	["BashMoving"]    = 150,
    	["DronesStampede"] = 100,
    	["AmbushMoving"]  = 150,
    	["A60"]           = 125,
    	["A120"]          = 85,
    	["GlitchRush"]    = 90,
    	["GlitchAmbush"]  = 175,
    	["BackdoorRush"]  = 85,
    	["CustomEntity"]  = 85,
    }

    Functions.GetNearestEntity = function(CheckDisabled, List, UseRaycasting)
    	local Nearest = { Distance = math.huge, Object = nil }

    	for _, Entity in Objects.Entities do
    		if not Entity or not Entity:IsA("Model") or not Entity:IsDescendantOf(Services.Workspace) then continue end
    		if not EntityDistances[Entity.Name] or not Entity.PrimaryPart then continue end

    		local EntityData = Entities[Entity.Name]
    		if not EntityData then continue end
    		if List and List[EntityData.Alias] then continue end

    		local Distance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
    		if Distance < EntityDistances[Entity.Name] and Distance < Nearest.Distance then
    			if not CheckDisabled or Entity:GetAttribute("Inactive") ~= true then
    				Nearest.Distance = Distance
    				Nearest.Object = Entity
    			end
    		end
    	end
    	return Nearest.Object
    end

    Functions.GetNearestFigure = function()
    	local Nearest = { Distance = math.huge, Object = nil }
    	local FigureNames = { FigureRig = true, FigureRagdoll = true, Figure = true }

    	for _, Object in Objects.Entities do
    		if Object:IsA("Model") and Object.PrimaryPart and FigureNames[Object.Name] then
    			local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
    			if Distance < Nearest.Distance and Distance < 25 then
    				Nearest.Distance = Distance
    				Nearest.Object = Object
    			end
    		end
    	end
    	return Nearest.Object
    end

    Functions.GetNearestHidingSpot = function()
    	local Nearest = { Distance = math.huge, Object = nil }
    	local LastHideSpot = Character:FindFirstChild("LastHideSpot")

    	local function IsHidingSpotName(Name)
    		if typeof(Name) ~= "string" then return false end
    		return string.find(string.lower(Name), "hidingspot") or string.find(string.lower(Name), "hiding_spot")
    	end

    	local function GetHidePrompt(Object)
    	if not Object then return nil end

    	local Prompt = Object:FindFirstChild("HidePrompt") or Object:FindFirstChild("HidingPrompt")
    	if Prompt then return Prompt end

    	for _, Child in Object:GetDescendants() do
    		if (Child:IsA("ProximityPrompt") or Child:IsA("InteractPrompt"))
    			and (Child.Name == "HidePrompt" or Child.Name == "HidingPrompt" or IsHidingSpotName(Child.Name))
    		then
    			return Child
    		end
    	end

    	if IsHidingSpotName(Object.Name) or IsHidingSpotName(Object.Parent and Object.Parent.Name) then
    		return Object:FindFirstChild("HidePrompt") or Object:FindFirstChild("HidingPrompt")
    	end

    	return nil
    	end

    	local function TryObject(Object)
    		if not Object or not Object:IsDescendantOf(Services.Workspace) then return end
    		if not Object.PrimaryPart and not Object:FindFirstChildOfClass("BasePart") then return end
    		local Prompt = GetHidePrompt(Object)
    		if not Prompt then return end
    		local PrimaryPart = Object.PrimaryPart or Object:FindFirstChildOfClass("BasePart")
    		if not PrimaryPart then return end
    		local Distance = LocalPlayer:DistanceFromCharacter(PrimaryPart.Position)
    		if Distance < Prompt.MaxActivationDistance and Distance < Nearest.Distance then
    			local Persistent = Functions.IsHidePersistent()
    			if not Persistent or (LastHideSpot and LastHideSpot.Value ~= Object) or not LastHideSpot then
    				Nearest.Distance = Distance
    				Nearest.Object = Object
    			end
    		end
    	end

    	for _, Object in Objects.HidingSpots do
    		TryObject(Object)
    	end

    	return Nearest.Object
    end

    Functions.GetNearestTurnNode = function()
    	local Nearest = { Distance = math.huge, Object = nil }

    	for _, Node in Objects.SeekNodes do
    		local Distance = LocalPlayer:DistanceFromCharacter(Node.Position)
    		if Distance < Options.ab_AutoSteerMinecartTurnDistance.Value and Distance < Nearest.Distance then
    			Nearest.Distance = Distance
    			Nearest.Object = Node
    		end
    	end
    	return Nearest.Object
    end

    Functions.GetNearestDuckBoard = function()
    	local Nearest = { Distance = math.huge, Object = nil }

    	for _, Board in Objects.SeekDuckBoards do
    		if Board.PrimaryPart then
    			local Distance = LocalPlayer:DistanceFromCharacter(Board.PrimaryPart.Position)
    			if Distance < Options.ab_AutoSteerMinecartDuckDistance.Value and Distance < Nearest.Distance then
    				Nearest.Distance = Distance
    				Nearest.Object = Board
    			end
    		end
    	end
    	return Nearest.Object
    end

    Functions.GetCurrentAnchor = function()
    	local AnchorCode = Globals.MainUI.AnchorHintFrame.AnchorCode.Text
    	for _, Anchor in Objects.Objectives do
    		if Anchor.Name == "MinesAnchor" and Anchor:FindFirstChild("Sign") then
    			if Anchor.Sign.TextLabel.Text == AnchorCode then
    				return Anchor
    			end
    		end
    	end
    end

    Functions.GetMinecart = function()
    	return Camera:FindFirstChild("MinecartRig") ~= nil
    end

    Functions.HasItem = function(Name, OnlyCharacter)
    	if not OnlyCharacter and LocalPlayer.Backpack:FindFirstChild(Name) then
    		return LocalPlayer.Backpack:FindFirstChild(Name)
    	elseif Character:FindFirstChild(Name) then
    		return Character:FindFirstChild(Name)
    	end
    end

    Functions.GetFlyVelocity = function()
    	if Humanoid.MoveDirection == Vector3.zero then
    		return Humanoid.MoveDirection
    	end
    	local LookFlat = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
    	local FlatFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + LookFlat)
    	local Velocity = (Camera.CFrame * CFrame.new(FlatFrame:VectorToObjectSpace(Humanoid.MoveDirection))).Position - Camera.CFrame.Position
    	if Velocity == Vector3.zero then
    		return Velocity
    	end
    	return Velocity.Unit
    end

    Globals.PromptContainer = Instance.new("Folder")
    Globals.PromptContainer.Name = "PromptContainer"
    Globals.PromptContainer.Parent = GetHiddenContainer()

    local ESPBlacklist = {}

    Functions.AddESP = function(ESPOptions, RoomBased)
    	local Object = ESPOptions.Object

    	if table.find(ESPBlacklist, Object) then
    		return
    	end

    	if RoomBased then
    		local CurrentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
    		local ObjectRoom = tonumber(Object:GetAttribute("ParentRoom"))

    		if ObjectRoom == CurrentRoom or (table.find(Objects.Doors, Object) and ObjectRoom == (CurrentRoom or 0) + 1) then
    			Abysall.ESPLibrary:AddESP(ESPOptions)
    		end

    		local RoomConnection = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    			if Abysall.ESPLibrary.ColorTable[Object] then
    				ESPOptions.Color = Abysall.ESPLibrary.ColorTable[Object]
    			end

    			local NewCurrentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
    			local ObjRoom = tonumber(Object:GetAttribute("ParentRoom"))

    			if ObjRoom == NewCurrentRoom or (table.find(Objects.Doors, Object) and ObjRoom == NewCurrentRoom + 1) then
    				Abysall.ESPLibrary:AddESP(ESPOptions)
    			else
    				Abysall.ESPLibrary:RemoveESP(Object)
    			end
    		end)

    		table.insert(Connections, RoomConnection)
    		ESPConnections[Object] = RoomConnection

    		Object.Destroying:Once(function()
    			RoomConnection:Disconnect()
    			if Abysall then
    				Abysall.ESPLibrary:RemoveESP(Object)
    			end
    			local Pos = table.find(Connections, RoomConnection)
    			if Pos then table.remove(Connections, Pos) end
    		end)
    	else
    		Abysall.ESPLibrary:AddESP(ESPOptions)
    	end
    end

    Functions.RemoveESP = function(Object)
    	local Conn = ESPConnections[Object]
    	if Conn then
    		Conn:Disconnect()
    		ESPConnections[Object] = nil
    		local Pos = table.find(Connections, Conn)
    		if Pos then table.remove(Connections, Pos) end
    	end
    	Abysall.ESPLibrary:RemoveESP(Object)
    end

    Functions.BlacklistESP = function(Object)
    	table.insert(ESPBlacklist, Object)
    end

    Functions.GetDoorNumber = function(Object)
    	local DoorNumber = tonumber(Object.Parent.Name) or tonumber(Object.Parent.Parent.Name)
    	if DoorNumber then
    		DoorNumber = DoorNumber + 1
    	end
    	if Floor == "Mines" then
    		DoorNumber = DoorNumber + 100
    	end
    	if Floor == "Backdoor" then
    		DoorNumber = DoorNumber - 50
    	end

    	return tostring(DoorNumber)
    end

    Functions.GetLibraryCode = function()
    	local Paper = Character:FindFirstChild("LibraryHintPaper")
    		or Character:FindFirstChild("LibraryHintPaperHard")
    		or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper")
    		or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaperHard")

    	if Paper and Paper:FindFirstChild("UI") then
    		local Code = {}
    		local CodeLength = Floor == "Fools" and 10 or 5
    		for I = 1, CodeLength do Code[I] = "_" end

    		local HintChildren = LocalPlayer.PlayerGui.PermUI.Hints:GetChildren()
    		local UIChildren = Paper.UI:GetChildren()

    		for _, Hint in HintChildren do
    			for _, UIChild in UIChildren do
    				if Hint:IsA("ImageLabel") and UIChild:IsA("ImageLabel")
    					and Hint.ImageRectOffset == UIChild.ImageRectOffset
    					and Code[tonumber(UIChild.Name)]
    				then
    					Code[tonumber(UIChild.Name)] = Hint.TextLabel.Text
    				end
    			end
    		end
    		return table.concat(Code)
    	end
    	return Floor == "Fools" and "__________" or "_____"
    end

    Globals.UsedRandomCodes = {}
    Functions.GetRandomCode = function()
        local CodeTemplate = Functions.GetLibraryCode()
        if not CodeTemplate then
            return nil
        end

        local NewCode
        local Tries = 0
        repeat
            NewCode = CodeTemplate:gsub("_", function()
                return tostring(math.random(0, 9))
            end)
            Tries = Tries + 1
        until not Globals.UsedRandomCodes[NewCode] or Tries >= 10

        Globals.UsedRandomCodes[NewCode] = true
        return NewCode
    end

    local Window = ReichtWindow




    if Window.AddInfoTab then Window:AddInfoTab() end

    local Tabs = {
    	General = Window:AddTab("General", "house"),
    	Exploits = Window:AddTab("Exploits", "shield"),
    	Visuals = Window:AddTab("Visuals", "eye"),
    	Floors = Window:AddTab("Floors", "earth"),
    	Archives = Window:AddTab("New - Archives", "rbxassetid://104508835882225"),
    	Stairwell = Window:AddTab("New - Stairwell", "rbxassetid://80017304328364"),
    }


    Groupboxes.General_Character = Tabs.General:AddLeftGroupbox("Character")
    Groupboxes.General_Character:AddSlider("ab_SpeedBoostSlider", {
    	Text = "Speed Boost", Min = 0, Max = 100, Default = 0, Rounding = 0, Compact = true
    })
    Groupboxes.General_Character:AddToggle("ab_SpeedBoostToggle", {
    	Text = "Enable Speed Boost", Default = false, Tooltip = "Increases your walkspeed by the specified amount."
    })
    Groupboxes.General_Character:AddToggle("ab_FlyToggle", {
    	Text = "Fly", Default = false, Tooltip = "Allows you to freely fly around the map."
    })
    Toggles.ab_FlyToggle:AddKeyPicker("FlyKeybind", {
    	Text = "Fly", Default = "F", Mode = "Toggle", SyncToggleState = true
    })
    Groupboxes.General_Character:AddSlider("ab_FlySpeed", {
    	Text = "Fly Speed", Min = 0, Max = 115, Default = 20, Rounding = 0, Compact = true
    })
    Groupboxes.General_Character:AddDivider()
    Groupboxes.General_Character:AddToggle("ab_NoclipToggle", {
    	Text = "Noclip", Default = false, Tooltip = "Allows your character to pass through solid objects."
    })
    Groupboxes.General_Character:AddToggle("ab_RemoveClosetDelay", {
    	Text = "Remove Closet Delay", Default = false,
    	Tooltip = "Removes the short window where you can't exit out of a closet after the animation finishes."
    })
    Groupboxes.General_Character:AddToggle("ab_RemoveAcceleration", {
    	Text = "Remove Acceleration", Default = false, Tooltip = "Prevents your character from sliding while moving."
    })

    local CustomPhysics

    Options.ab_SpeedBoostSlider:OnChanged(function(Value)
    	if RemotesFolder:FindFirstChild("Crouch") then
    		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
    	end
    end)

    Toggles.ab_NoclipToggle:AddKeyPicker("NoclipKeybind", {
    	Text = "Noclip", Default = "N", Mode = "Toggle", SyncToggleState = true
    })
    Toggles.ab_RemoveAcceleration:OnChanged(function(Value)
    	for Index, Old in PartProperties do
    		Index.CustomPhysicalProperties = Value and CustomPhysics or Old
    	end
    end)

    Groupboxes.General_Character:AddDivider()
    Groupboxes.General_Character:AddToggle("ab_EnableCharacterJump", {
    	Text = "Enable Jumping", Default = false, Tooltip = "Allows your character to jump."
    })
    Groupboxes.General_Character:AddToggle("ab_EnableCharacterSlide", {
    	Text = "Enable Sliding", Default = false, Tooltip = "Allows your character to slide."
    })
    Groupboxes.General_Character:AddToggle("ab_InfiniteJumps", {
    	Text = "Infinite Jumps", Default = false, Tooltip = "Allows you to jump while in the air."
    })

    local OldJump = false
    local OldSlide = false

    Toggles.ab_SpeedBoostToggle:OnChanged(function(Value)
    	if Humanoid then
    		Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + (Value and Options.ab_SpeedBoostSlider.Value or 0)
    	end
    end)
    Toggles.ab_EnableCharacterJump:OnChanged(function(Value)
    	if Character then
    		Character:SetAttribute("CanJump", Value and true or OldJump)
    	end
    end)
    Toggles.ab_EnableCharacterSlide:OnChanged(function(Value)
    	if Character then
    		Character:SetAttribute("CanSlide", Value and true or OldSlide)
    	end
    end)

    Groupboxes.General_Self = Tabs.General:AddLeftGroupbox("Self")
    Groupboxes.General_Self:AddToggle("ab_DoorReachToggle", {
    	Text = "Door Reach", Default = false, Tooltip = "Allows you to open doors from further away."
    })
    Groupboxes.General_Self:AddToggle("ab_DisableIdleKick", {
    	Text = "Disable Idle Kick", Default = false, Tooltip = "Prevents the kick from being idle for 20 minutes."
    })
    Toggles.ab_DisableIdleKick:OnChanged(function(Value)
    	if Functions.CheckCompatability({"getconnections"}) then
    		for _, Conn in Abysall.Environment.getconnections(LocalPlayer.Idled) do
    			if Value then Conn:Disable() else Conn:Enable() end
    		end
    	end
    end)
    LocalPlayer.Idled:Connect(function()
    	if Toggles.ab_DisableIdleKick.Value then
    		Services.VirtualUser:CaptureController()
    		Services.VirtualUser:ClickButton2(Vector2.new())
    	end
    end)

    Groupboxes.General_Self:AddDivider()
    Groupboxes.General_Self:AddSlider("ab_PromptReachSlider", {
    	Text = "Prompt Reach Multiplier", Min = 1, Max = 2, Default = 1, Rounding = 1, Compact = true
    })
    Groupboxes.General_Self:AddToggle("ab_InstantPrompts", {
    	Text = "Instant Prompts", Default = false, Tooltip = "Allows you to trigger all prompts instantly."
    })
    Groupboxes.General_Self:AddToggle("ab_PromptClip", {
    	Text = "Prompt Clip", Default = false, Tooltip = "Allows you to interact with prompts through walls."
    })

    Options.ab_PromptReachSlider:OnChanged(function(Value)
    	for _, Prompt in Objects.Prompts do
    		Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") * Value
    	end
    end)
    Toggles.ab_InstantPrompts:OnChanged(function(Value)
    	for _, Prompt in Objects.Prompts do
    		Prompt.HoldDuration = Value and 0 or Prompt:GetAttribute("HoldDuration_Old")
    	end
    end)
    Toggles.ab_PromptClip:OnChanged(function(Value)
    	for _, Prompt in Objects.Prompts do
    		Prompt.RequiresLineOfSight = Value and false or Prompt:GetAttribute("RequiresLineOfSight_Old")
    	end
    end)

    Groupboxes.Self_Automation = Tabs.General:AddRightGroupbox("Automation")
    Groupboxes.Self_Automation:AddToggle("ab_AutoBreakerBox", {
    	Text = "Auto Breaker Box", Default = false, Tooltip = "Automatically solves the breaker box."
    })
    Groupboxes.Self_Automation:AddToggle("ab_AutoSolveAnchors", {
    	Text = "Auto Solve Anchors", Default = false,
    	Tooltip = "Automatically enters the correct code into anchors when you are near them."
    })
    Toggles.ab_AutoBreakerBox:OnChanged(function(Value)
    	if Value and CurrentRooms:FindFirstChild("ElevatorBreaker", true) then
    		if not Globals.BreakerBoxInteracted then
    			if not Globals.BreakerBoxNotified then
    				Functions.Notify({ Title = "Interact with the breaker box.", Body = "It will be automatically solved." })
    				Globals.BreakerBoxInteracted = true
    			end
    		else
    			RemotesFolder.EBF:FireServer()
    		end
    	end
    end)

    Groupboxes.Self_Automation:AddToggle("ab_AutoHeartbeatMinigame", { Text = "Auto Heartbeat Minigame", Default = false, Tooltip = "Prevents the 'Figure' minigame from ever failing.", Disabled = not Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}), DisabledTooltip = Globals.IncompatibleMessage })
    Groupboxes.Self_Automation:AddDivider()
    Groupboxes.Self_Automation:AddToggle("ab_AutoUnlockPadlockToggle", {
    	Text = "Auto Unlock Padlock", Default = false, Tooltip = "Automatically enters the code into the library padlock."
    })
    Groupboxes.Self_Automation:AddSlider("ab_AutoUnlockPadlockSlider", {
    	Text = "Unlock Distance", Min = 1, Max = 50, Default = 10, Rounding = 0, Compact = true
    })
    Groupboxes.Self_Automation:AddToggle("ab_AutoLibraryGuessCode", {
    	Text = "Guess Library Code", Default = false,
    	Tooltip = "Attempts to guess the library code, but collecting some books is also necessary."
    })
    Groupboxes.Self_Automation:AddDivider()
    Groupboxes.Self_Automation:AddToggle("ab_AutoLibrary", {
    	Text = "Auto Library", Default = false,
    	Tooltip = "Automatically gets books and paper."
    })
    Groupboxes.Self_Automation:AddToggle("ab_SkipSeekHotel", {
    	Text = "Skip Seek (Hotel)",
    	Default = false,
    	Tooltip = "Skips the entire Seek sections.",
    })
    Groupboxes.Self_Automation:AddToggle("ab_AutoBreakerRoom", {
    	Text = "Auto Breaker Room",
    	Default = false,
    	Tooltip = "Automatically completes the breaker sequence in Hotel Room 100.",
    })
    Groupboxes.Self_Automation:AddDivider()
    Toggles.ab_AutoHotel = Groupboxes.Self_Automation:AddToggle("ab_AutoHotel", {
    	Text = "Auto Hotel",
    	Tooltip = "Automatically progresses through the hotel floor.",
    	Risky = Floor ~= "Ballz",
    	Default = false
    })
    Toggles.ab_AutoHotelIgnoreEntities = Groupboxes.Self_Automation:AddToggle("ab_AutoHotelIgnoreEntities", {
    	Text = "Ignore Entities",
    	Tooltip = "Skip all entity waits and pauses.",
    	Default = false
    })
    Groupboxes.Self_Automation:AddDivider()
    Groupboxes.Self_Automation:AddToggle("ab_AutoInteractToggle", {
    	Text = "Auto Interact", Default = false, Tooltip = "Automatically triggers nearby prompts."
    })
    Toggles.ab_AutoInteractToggle:AddKeyPicker("AutoInteractKeybind", {
        Text = "Auto Interact",
        Default = "R",
        Mode = "Toggle",
        SyncToggleState = true
    })
    Groupboxes.Self_Automation:AddDropdown("ab_AutoInteractIgnoreList", {
    	Text = "Ignore List",
    	Values = { "Glitch Fragments", "Jeff Items", "Dropped Items", "Currency", "Minecarts", "Locks" },
    	Default = { "Glitch Fragments", "Jeff Items", "Dropped Items" },
    	Multi = true, AllowNull = true
    })
    Groupboxes.Self_Automation:AddDivider()
    Groupboxes.Self_Automation:AddToggle("ab_AutoClosetToggle", {
    	Text = "Auto Closet", Default = false,
    	Tooltip = "Automatically hides in a nearby closet when an entity is near."
    })
    Toggles.ab_AutoClosetToggle:AddKeyPicker("AutoClosetKeybind", {
    	Text = "Auto Closet", Default = "Q", Mode = "Toggle", SyncToggleState = true
    })
    Groupboxes.Self_Automation:AddDropdown("ab_AutoClosetEntityList", {
    	Text = "Ignore List",
    	Values = { "Rush", "Ambush", "Blitz", "DronesStampede", "Scribbles", "A-60", "A-120", "AR0xMBUSH", "RNIUSHCG==" },
    	Multi = true, AllowNull = true
    })
    Groupboxes.Self_Automation:AddToggle("ab_SpectateEntityToggle", {
    	Text = "Spectate Entity",
    	Default = false,
    	Tooltip = "Spectates the entity while auto hiding."
    })
    Groupboxes.Self_Automation:AddDropdown("ab_SpecateEntityMode", {
    	Values = {"Player to Entity", "Entity to Player"},
    	Default = 1,
    	AllowNull = true
    })

    Groupboxes.Self_Misc = Tabs.General:AddRightGroupbox("Miscellaneous")
    Groupboxes.Self_Misc:AddButton({
    	Text = "Play Again", Tooltip = "Makes you join a new run, click again to cancel.", DoubleClick = true,
    	Func = function() RemotesFolder.PlayAgain:FireServer() end
    })
    Groupboxes.Self_Misc:AddButton({
    	Text = "Return to Lobby", Tooltip = "Makes you teleport back to the lobby.", DoubleClick = true,
    	Func = function() RemotesFolder.Lobby:FireServer() end
    })
    Groupboxes.Self_Misc:AddButton({
    	Text = "Revive",
    	Tooltip = "Makes you revive, if you have a revive and haven't already revived in this run.",
    	DoubleClick = true,
    	Func = function() RemotesFolder.Revive:FireServer() end
    })
    Groupboxes.Self_Misc:AddButton({
    	Text = "Reset Character",
    	Tooltip = "Kills your character on the server. (takes around 20 seconds if replicatesignal isn't supported)",
    	DoubleClick = true,
    	Func = function()
    		Globals.SelfKilled = true
    		if Functions.CheckCompatability({"replicatesignal"}) then
    			Abysall.Environment.replicatesignal(LocalPlayer.Kill)
    		else
    			if RemotesFolder:FindFirstChild("Underwater") then
    				RemotesFolder.Underwater:FireServer(true)
    			else
    				Humanoid.Health = 0
    			end
    		end
    	end
    })




    Toggles.ab_SkipSeekHotel:OnChanged(function(Value)
    	if not Value then return end
    	if Floor ~= "Hotel" then return end

    	task.spawn(function()

    		local currentRooms

    		repeat
    			if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    				return
    			end
    			currentRooms = workspace:FindFirstChild("CurrentRooms")
    			task.wait()
    		until currentRooms


    		local lastTriggerRoom = nil

    		while Toggles.ab_SkipSeekHotel.Value and Floor == "Hotel" do
    			local triggerRoom = nil


    			repeat
    				if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    					return
    				end

    				currentRooms = workspace:FindFirstChild("CurrentRooms")
    				local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))

    				if currentRoomNum and currentRoomNum ~= lastTriggerRoom then
    					local room = currentRooms and currentRooms:FindFirstChild(tostring(currentRoomNum))
    					if room then
    						local trigger = room:WaitForChild("TriggerEventCollision", 0.5)
    						if trigger then
    							triggerRoom = currentRoomNum
    						end
    					end
    				end

    				task.wait()
    			until triggerRoom

    			lastTriggerRoom = triggerRoom

    			local roomNum = triggerRoom

    			while Toggles.ab_SkipSeekHotel.Value and Floor == "Hotel" do
    				roomNum += 1

    				local room
    				local roomTries = 0
    				repeat
    					if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    						return
    					end
    					currentRooms = workspace:FindFirstChild("CurrentRooms")
    					room = currentRooms and currentRooms:FindFirstChild(tostring(roomNum))
    					roomTries += 1
    					task.wait()
    				until room or roomTries > 600
    				if not room then
    					warn("[Reicht] auto hotel: room " .. tostring(roomNum) .. " never loaded, stopping")
    					return
    				end


    				local hasSeekArm = false
    				local assets = room:FindFirstChild("Assets")
    				if assets then
    					for _, child in ipairs(assets:GetChildren()) do
    						if child.Name == "Seek_Arm" then
    							hasSeekArm = true
    							break
    						end
    					end
    				end

    				local door
    				local doorTries = 0
    				repeat
    					if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    						return
    					end
    					door = room:FindFirstChild("Door", true)
    					doorTries += 1
    					task.wait()
    				until door or doorTries > 600
    				if not door then
    					warn("[Reicht] auto hotel: room " .. tostring(roomNum) .. " has no door, stopping")
    					return
    				end


    				local doorOpenTries = 0
    				repeat
    					if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    						return
    					end
    					if Character then
    						Character:PivotTo(door:GetPivot())
    					end
    					doorOpenTries += 1
    					task.wait()
    				until door:GetAttribute("Opened") == true or doorOpenTries > 600


    				if hasSeekArm then
    					if not Character then
    						return
    					end


    					local voidCFrame = Character:GetPivot() + Vector3.new(0, -2500, 0)

    					task.wait(0.25)

    					for _ = 1, 20 do
    						Character:PivotTo(voidCFrame)
    						task.wait()
    					end

    					task.wait(0.3)

    					for _ = 1, 15 do
    						Character:PivotTo(voidCFrame)
    						task.wait()
    					end

    					task.wait(0.2)

    					for _ = 1, 10 do
    						Character:PivotTo(voidCFrame)
    						task.wait()
    					end

    					break
    				end
    			end
    		end
    	end)
    end)

    Toggles.ab_AutoLibrary:OnChanged(function(AutoLibraryEnabled)
    	if AutoLibraryConnection then
    		task.cancel(AutoLibraryConnection)
    		AutoLibraryConnection = nil
    	end

    	if AutoLibraryRoomConnection then
    		AutoLibraryRoomConnection:Disconnect()
    		AutoLibraryRoomConnection = nil
    	end

    	if not AutoLibraryEnabled then
    		return
    	end

    	AutoLibraryConnection = task.spawn(function()
    		local AutoLibraryPlayers = game:GetService("Players")
    		local AutoLibraryLocalPlayer = AutoLibraryPlayers.LocalPlayer
    		local AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
    		local AutoLibraryHumanoidRootPart = AutoLibraryCharacter:WaitForChild("HumanoidRootPart")

    		local AutoLibraryCurrentRooms = workspace:WaitForChild("CurrentRooms")
    		local AutoLibraryRoom50 = AutoLibraryCurrentRooms:WaitForChild("50")
    		local AutoLibraryLiveHintBooks = {}
    		local AutoLibraryHintPaperObtained = false

    		local function AutoLibraryIsInRoom50(AutoLibraryObject)
    			return AutoLibraryObject
    				and AutoLibraryObject:IsDescendantOf(AutoLibraryRoom50)
    				and AutoLibraryObject:IsDescendantOf(AutoLibraryCurrentRooms)
    				and AutoLibraryObject:IsDescendantOf(workspace)
    		end

    		local function AutoLibraryIsActuallyInRoom50()
    			return tonumber(AutoLibraryLocalPlayer:GetAttribute("CurrentRoom")) == 50
    		end

    		while AutoLibraryEnabled and not AutoLibraryIsActuallyInRoom50() do
    			task.wait(0.05)
    		end

    		if not AutoLibraryEnabled then
    			return
    		end

    		local function AutoLibraryHasHintPaper()
    			AutoLibraryCharacter = AutoLibraryLocalPlayer.Character

    			if not AutoLibraryCharacter then
    				return false
    			end

    			local AutoLibraryBackpackPaper = AutoLibraryLocalPlayer.Backpack:FindFirstChild("LibraryHintPaper", true)
    			local AutoLibraryCharacterPaper = AutoLibraryCharacter:FindFirstChild("LibraryHintPaper", true)

    			return AutoLibraryBackpackPaper ~= nil or AutoLibraryCharacterPaper ~= nil
    		end

    		local function AutoLibraryGetObjectCFrame(AutoLibraryObject)
    			if not AutoLibraryIsActuallyInRoom50() then
    				return nil
    			end

    			if not AutoLibraryIsInRoom50(AutoLibraryObject) then
    				return nil
    			end

    			if AutoLibraryObject:IsA("Model") then
    				return AutoLibraryObject:GetPivot()
    			elseif AutoLibraryObject:IsA("BasePart") then
    				return AutoLibraryObject.CFrame
    			end

    			local AutoLibraryObjectPart = AutoLibraryObject:FindFirstChildWhichIsA("BasePart", true)

    			if AutoLibraryObjectPart then
    				return AutoLibraryObjectPart.CFrame
    			end

    			return nil
    		end

    		local function AutoLibraryFindBooks(AutoLibraryObject)
    			if not AutoLibraryIsActuallyInRoom50() then
    				return
    			end

    			if not AutoLibraryIsInRoom50(AutoLibraryObject) then
    				return
    			end

    			if AutoLibraryObject.Name == "LiveHintBook" then
    				if not table.find(AutoLibraryLiveHintBooks, AutoLibraryObject) then
    					table.insert(AutoLibraryLiveHintBooks, AutoLibraryObject)
    				end
    			end

    			for _, AutoLibraryDescendant in ipairs(AutoLibraryObject:GetDescendants()) do
    				if AutoLibraryDescendant.Name == "LiveHintBook"
    					and AutoLibraryIsInRoom50(AutoLibraryDescendant) then

    					if not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then
    						table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
    					end
    				end
    			end
    		end

    		for _, AutoLibraryDescendant in ipairs(AutoLibraryRoom50:GetDescendants()) do
    			if not AutoLibraryEnabled or not AutoLibraryIsActuallyInRoom50() then
    				return
    			end

    			if AutoLibraryDescendant.Name == "LiveHintBook"
    				and AutoLibraryIsInRoom50(AutoLibraryDescendant) then

    				if not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then
    					table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
    				end
    			end
    		end

    		AutoLibraryRoomConnection = AutoLibraryRoom50.DescendantAdded:Connect(function(AutoLibraryAddedObject)
    			if not AutoLibraryEnabled then
    				return
    			end

    			if not AutoLibraryIsActuallyInRoom50() then
    				return
    			end

    			if not AutoLibraryIsInRoom50(AutoLibraryAddedObject) then
    				return
    			end

    			AutoLibraryFindBooks(AutoLibraryAddedObject)
    		end)

    		while AutoLibraryEnabled
    			and AutoLibraryIsActuallyInRoom50()
    			and #AutoLibraryLiveHintBooks < 3 do

    			for _, AutoLibraryDescendant in ipairs(AutoLibraryRoom50:GetDescendants()) do
    				if not AutoLibraryEnabled or not AutoLibraryIsActuallyInRoom50() then
    					return
    				end

    				if AutoLibraryDescendant.Name == "LiveHintBook"
    					and AutoLibraryIsInRoom50(AutoLibraryDescendant)
    					and not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then

    					table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
    				end
    			end

    			if #AutoLibraryLiveHintBooks >= 3 then
    				break
    			end

    			task.wait(0.05)
    		end

    		while AutoLibraryEnabled
    			and AutoLibraryIsActuallyInRoom50()
    			and not AutoLibraryHintPaperObtained do

    			if AutoLibraryHasHintPaper() then
    				AutoLibraryHintPaperObtained = true
    				break
    			end

    			for AutoLibraryIndex = #AutoLibraryLiveHintBooks, 1, -1 do
    				if not AutoLibraryIsActuallyInRoom50() then
    					return
    				end

    				local AutoLibraryLiveHintBook = AutoLibraryLiveHintBooks[AutoLibraryIndex]

    				if not AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) then
    					table.remove(AutoLibraryLiveHintBooks, AutoLibraryIndex)
    					continue
    				end

    				while AutoLibraryEnabled
    					and AutoLibraryIsActuallyInRoom50()
    					and not AutoLibraryHintPaperObtained
    					and AutoLibraryLiveHintBook.Parent
    					and AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) do

    					if AutoLibraryHasHintPaper() then
    						AutoLibraryHintPaperObtained = true
    						break
    					end

    					AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
    					AutoLibraryHumanoidRootPart = AutoLibraryCharacter:FindFirstChild("HumanoidRootPart")

    					if not AutoLibraryHumanoidRootPart then
    						task.wait()
    						continue
    					end

    					local AutoLibraryBookCFrame = AutoLibraryGetObjectCFrame(AutoLibraryLiveHintBook)

    					if AutoLibraryBookCFrame
    						and AutoLibraryIsActuallyInRoom50()
    						and AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) then

    						AutoLibraryHumanoidRootPart.CFrame = AutoLibraryBookCFrame
    					end

    					for _, AutoLibraryPromptDescendant in ipairs(AutoLibraryLiveHintBook:GetDescendants()) do
    						if AutoLibraryPromptDescendant:IsA("ProximityPrompt")
    							and AutoLibraryIsInRoom50(AutoLibraryPromptDescendant)
    							and AutoLibraryIsActuallyInRoom50() then

    							Functions.FirePrompt(AutoLibraryPromptDescendant)
    						end
    					end

    					task.wait(0.05)
    				end

    				if AutoLibraryHintPaperObtained then
    					break
    				end
    			end

    			if AutoLibraryHasHintPaper() then
    				AutoLibraryHintPaperObtained = true
    				break
    			end

    			local AutoLibraryHintPaper = AutoLibraryRoom50:FindFirstChild("LibraryHintPaper", true)

    			if AutoLibraryHintPaper
    				and AutoLibraryIsInRoom50(AutoLibraryHintPaper)
    				and AutoLibraryIsActuallyInRoom50() then

    				while AutoLibraryEnabled
    					and AutoLibraryIsActuallyInRoom50()
    					and not AutoLibraryHintPaperObtained
    					and AutoLibraryHintPaper.Parent
    					and AutoLibraryIsInRoom50(AutoLibraryHintPaper) do

    					if AutoLibraryHasHintPaper() then
    						AutoLibraryHintPaperObtained = true
    						break
    					end

    					AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
    					AutoLibraryHumanoidRootPart = AutoLibraryCharacter:FindFirstChild("HumanoidRootPart")

    					if not AutoLibraryHumanoidRootPart then
    						task.wait()
    						continue
    					end

    					local AutoLibraryPaperCFrame = AutoLibraryGetObjectCFrame(AutoLibraryHintPaper)

    					if AutoLibraryPaperCFrame
    						and AutoLibraryIsActuallyInRoom50()
    						and AutoLibraryIsInRoom50(AutoLibraryHintPaper) then

    						AutoLibraryHumanoidRootPart.CFrame = AutoLibraryPaperCFrame * CFrame.new(0, 5, 0)
    					end

    					for _, AutoLibraryPromptDescendant in ipairs(AutoLibraryHintPaper:GetDescendants()) do
    						if AutoLibraryPromptDescendant:IsA("ProximityPrompt")
    							and AutoLibraryIsInRoom50(AutoLibraryPromptDescendant)
    							and AutoLibraryIsActuallyInRoom50() then

    							Functions.FirePrompt(AutoLibraryPromptDescendant)
    						end
    					end

    					task.wait(0.05)
    				end
    			end

    			task.wait(0.05)
    		end
    	end)
    end)

    Toggles.ab_AutoBreakerRoom:OnChanged(function(AutoBreakerRoomEnabled)
    	if AutoBreakerRoomConnection then
    		task.cancel(AutoBreakerRoomConnection)
    		AutoBreakerRoomConnection = nil
    	end

    	if AutoBreakerRoomRoomConnection then
    		AutoBreakerRoomRoomConnection:Disconnect()
    		AutoBreakerRoomRoomConnection = nil
    	end

    	if not AutoBreakerRoomEnabled then
    		return
    	end

    	local AutoBreakerRoomGateFireTime = 5
    	local AutoBreakerRoomWaitAfterLever = 5
    	local AutoBreakerRoomBreakerSecondTime = 10
    	local AutoBreakerRoomWaitBeforeWeb = 4
    	local AutoBreakerRoomWebDuration = 20

    	AutoBreakerRoomConnection = task.spawn(function()
    		local AutoBreakerRoomPlayers = game:GetService("Players")
    		local AutoBreakerRoomCurrentRooms = workspace:WaitForChild("CurrentRooms")
    		local AutoBreakerRoom100 = AutoBreakerRoomCurrentRooms:WaitForChild("100")

    		local function AutoBreakerRoomIsActuallyInRoom100()
    			return tonumber(AutoBreakerRoomPlayers.LocalPlayer:GetAttribute("CurrentRoom")) == 100
    		end

    		local function AutoBreakerRoomIsInRoom100(AutoBreakerRoomObject)
    			return AutoBreakerRoomObject
    				and AutoBreakerRoomObject.Parent
    				and AutoBreakerRoomObject:IsDescendantOf(AutoBreakerRoom100)
    				and AutoBreakerRoomObject:IsDescendantOf(AutoBreakerRoomCurrentRooms)
    		end

    		local function AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomObject)
    			if not AutoBreakerRoomIsActuallyInRoom100() or not AutoBreakerRoomIsInRoom100(AutoBreakerRoomObject) then
    				return nil
    			end

    			if AutoBreakerRoomObject:IsA("Model") then
    				return AutoBreakerRoomObject:GetPivot()
    			elseif AutoBreakerRoomObject:IsA("BasePart") then
    				return AutoBreakerRoomObject.CFrame
    			end

    			local AutoBreakerRoomPart = AutoBreakerRoomObject:FindFirstChildWhichIsA("BasePart", true)
    			return AutoBreakerRoomPart and AutoBreakerRoomPart.CFrame
    		end

    		local function AutoBreakerRoomGetHRP()
    			local AutoBreakerRoomCharacter = AutoBreakerRoomPlayers.LocalPlayer.Character
    			return AutoBreakerRoomCharacter and AutoBreakerRoomCharacter:FindFirstChild("HumanoidRootPart")
    		end

    		local function AutoBreakerRoomActivate(AutoBreakerRoomObject)
    			if not AutoBreakerRoomObject then
    				return
    			end

    			if AutoBreakerRoomObject:IsA("ProximityPrompt") then
    				Functions.FirePrompt(AutoBreakerRoomObject)
    				return
    			end

    			for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoomObject:GetDescendants()) do
    				if AutoBreakerRoomDescendant:IsA("ProximityPrompt") then
    					Functions.FirePrompt(AutoBreakerRoomDescendant)
    				end
    			end
    		end

    		local function AutoBreakerRoomConstantTPAndActivate(AutoBreakerRoomTarget, AutoBreakerRoomDuration, AutoBreakerRoomInterval, AutoBreakerRoomOffset)
    			AutoBreakerRoomInterval = AutoBreakerRoomInterval or 0.04
    			AutoBreakerRoomOffset = AutoBreakerRoomOffset or CFrame.new()
    			local AutoBreakerRoomEndTime = os.clock() + (AutoBreakerRoomDuration or 3)

    			while AutoBreakerRoomEnabled
    				and AutoBreakerRoomIsActuallyInRoom100()
    				and AutoBreakerRoomIsInRoom100(AutoBreakerRoomTarget)
    				and os.clock() < AutoBreakerRoomEndTime do

    				local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
    				local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomTarget)

    				if AutoBreakerRoomHRP and AutoBreakerRoomCF then
    					AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF * AutoBreakerRoomOffset
    				end

    				AutoBreakerRoomActivate(AutoBreakerRoomTarget)
    				task.wait(AutoBreakerRoomInterval)
    			end
    		end

    		while AutoBreakerRoomEnabled do
    			while AutoBreakerRoomEnabled and not AutoBreakerRoomIsActuallyInRoom100() do
    				task.wait(0.1)
    			end

    			if not AutoBreakerRoomEnabled then
    				return
    			end

    			local AutoBreakerRoomPoles = {}

    			while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
    				AutoBreakerRoomPoles = {}

    				for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoom100:GetDescendants()) do
    					if AutoBreakerRoomDescendant.Name == "LiveBreakerPolePickup" and AutoBreakerRoomIsInRoom100(AutoBreakerRoomDescendant) then
    						if not table.find(AutoBreakerRoomPoles, AutoBreakerRoomDescendant) then
    							table.insert(AutoBreakerRoomPoles, AutoBreakerRoomDescendant)
    						end
    					end
    				end

    				if #AutoBreakerRoomPoles == 0 then
    					break
    				end

    				for _, AutoBreakerRoomPole in ipairs(AutoBreakerRoomPoles) do
    					if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
    						break
    					end

    					if AutoBreakerRoomIsInRoom100(AutoBreakerRoomPole) then
    						AutoBreakerRoomConstantTPAndActivate(AutoBreakerRoomPole, 2.8, 0.03)
    						task.wait(0.12)
    					end
    				end

    				task.wait(0.05)
    			end

    			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
    				continue
    			end

    			local AutoBreakerRoomIndustrialGate = AutoBreakerRoom100:FindFirstChild("IndustrialGate")
    			local AutoBreakerRoomBox = AutoBreakerRoomIndustrialGate and AutoBreakerRoomIndustrialGate:FindFirstChild("Box")
    			local AutoBreakerRoomLever = AutoBreakerRoomBox and AutoBreakerRoomBox:FindFirstChild("Lever")
    			local AutoBreakerRoomActivateEventPrompt = AutoBreakerRoomBox and AutoBreakerRoomBox:FindFirstChild("ActivateEventPrompt")

    			if AutoBreakerRoomActivateEventPrompt and AutoBreakerRoomLever then
    				local function AutoBreakerRoomGetLeverCFrame()
    					if AutoBreakerRoomLever:IsA("Model") then
    						return AutoBreakerRoomLever:GetPivot()
    					elseif AutoBreakerRoomLever:IsA("BasePart") then
    						return AutoBreakerRoomLever.CFrame
    					end
    					local AutoBreakerRoomPart = AutoBreakerRoomLever:FindFirstChildWhichIsA("BasePart", true)
    					return AutoBreakerRoomPart and AutoBreakerRoomPart.CFrame
    				end

    				local AutoBreakerRoomInitialLeverCFrame = AutoBreakerRoomGetLeverCFrame()
    				local AutoBreakerRoomLeverEndTime = os.clock() + 10

    				while AutoBreakerRoomEnabled
    					and AutoBreakerRoomIsActuallyInRoom100()
    					and AutoBreakerRoomIsInRoom100(AutoBreakerRoomLever)
    					and os.clock() < AutoBreakerRoomLeverEndTime do

    					local AutoBreakerRoomCurrentLeverCFrame = AutoBreakerRoomGetLeverCFrame()

    					if AutoBreakerRoomCurrentLeverCFrame and AutoBreakerRoomInitialLeverCFrame
    						and AutoBreakerRoomCurrentLeverCFrame ~= AutoBreakerRoomInitialLeverCFrame then
    						break
    					end

    					local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
    					local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomBox)

    					if AutoBreakerRoomHRP and AutoBreakerRoomCF then
    						AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF
    					end

    					AutoBreakerRoomActivate(AutoBreakerRoomActivateEventPrompt)
    					task.wait(0.04)
    				end
    			end

    			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
    				continue
    			end

    			task.wait(AutoBreakerRoomWaitAfterLever)

    			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
    				continue
    			end

    			local AutoBreakerRoomElevatorBreakerEmpty = AutoBreakerRoom100:FindFirstChild("ElevatorBreakerEmpty")
    			if not AutoBreakerRoomElevatorBreakerEmpty then
    				continue
    			end

    			local AutoBreakerRoomBreakerPrompt = AutoBreakerRoomElevatorBreakerEmpty:FindFirstChild("Prompt")
    			if not AutoBreakerRoomBreakerPrompt then
    				continue
    			end

    			local AutoBreakerRoomBreakerOffset = CFrame.new(0, -1.8, 0)

    			while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
    				if AutoBreakerRoomElevatorBreakerEmpty:FindFirstChild("BreakerSwitchInBox") then
    					break
    				end

    				local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
    				local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomElevatorBreakerEmpty)

    				if AutoBreakerRoomHRP and AutoBreakerRoomCF then
    					AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF * AutoBreakerRoomBreakerOffset
    				end

    				AutoBreakerRoomActivate(AutoBreakerRoomBreakerPrompt)
    				task.wait(0.04)
    			end

    			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
    				continue
    			end

    			task.wait(10)

    			AutoBreakerRoomConstantTPAndActivate(
    				AutoBreakerRoomElevatorBreakerEmpty,
    				AutoBreakerRoomBreakerSecondTime,
    				0.04,
    				AutoBreakerRoomBreakerOffset
    			)

    			task.wait(AutoBreakerRoomWaitBeforeWeb)

    			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
    				continue
    			end

    			local AutoBreakerRoomElevatorCar = AutoBreakerRoom100:FindFirstChild("ElevatorCar")
    			local AutoBreakerRoomWeb = AutoBreakerRoomElevatorCar and AutoBreakerRoomElevatorCar:FindFirstChild("Web", true)

    			if AutoBreakerRoomWeb then
    				local AutoBreakerRoomEndTime = os.clock() + AutoBreakerRoomWebDuration

    				while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() and os.clock() < AutoBreakerRoomEndTime do
    					local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
    					local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomWeb)

    					if AutoBreakerRoomHRP and AutoBreakerRoomCF then
    						AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF
    					end

    					task.wait(0.04)
    				end
    			end

    			while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
    				task.wait(0.5)
    			end
    		end
    	end)
    end)



    local AutoHotelConnection
    local AutoHotelLibraryConnection
    local AutoHotelLibraryRoomConnection
    local AutoHotelSeekConnection
    local AutoHotelEntityPause = false
    local AutoHotelRoomProcessTime = 0.5
    local AutoHotelProcessedRooms = {}

    local AutoHotelEntityNames = {
    	["RushMoving"] = true,
    	["Scribbles"] = true,
    	["BashMoving"] = true,
    	["DronesStampede"] = true,
    	["AmbushMoving"] = true,
    	["A60"] = true,
    	["A120"] = true,
    	["GlitchRush"] = true,
    	["GlitchAmbush"] = true,
    	["BackdoorRush"] = true,
    	["CustomEntity"] = true,
    }

    local function AutoHotelIsEntityPresent()
    	if Toggles.ab_AutoHotelIgnoreEntities and Toggles.ab_AutoHotelIgnoreEntities.Value then
    		return false
    	end
    	for _, AutoHotelChild in ipairs(workspace:GetChildren()) do
    		if AutoHotelEntityNames[AutoHotelChild.Name] then
    			return true
    		end
    	end
    	return false
    end

    local function AutoHotelWaitForEntities(AutoHotelSeconds)
    	if Toggles.ab_AutoHotelIgnoreEntities and Toggles.ab_AutoHotelIgnoreEntities.Value then
    		return
    	end

    	task.wait(AutoHotelSeconds or 5)

    	while AutoHotelIsEntityPresent() do
    		task.wait(0.15)
    	end
    end

    local function AutoHotelGetNextClosedDoor()
    	if not Character then return nil, nil end

    	local AutoHotelGameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
    	if not AutoHotelGameData then return nil, nil end

    	local AutoHotelLatestRoom = AutoHotelGameData:FindFirstChild("LatestRoom")
    	if not AutoHotelLatestRoom then return nil, nil end

    	local AutoHotelStartRoom = AutoHotelLatestRoom.Value
    	local AutoHotelBestDoor, AutoHotelBestNumber = nil, math.huge
    	local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")

    	if AutoHotelCurrentRooms then
    		for _, AutoHotelRoom in ipairs(AutoHotelCurrentRooms:GetChildren()) do
    			local AutoHotelRoomNum = tonumber(AutoHotelRoom.Name)
    			if AutoHotelRoomNum and AutoHotelRoomNum ~= 100 and AutoHotelRoomNum >= AutoHotelStartRoom and AutoHotelRoomNum < AutoHotelBestNumber then
    				local AutoHotelDoor = AutoHotelRoom:FindFirstChild("Door")
    				if AutoHotelDoor and AutoHotelDoor:IsA("Model") then
    					local AutoHotelOpenAttr = AutoHotelDoor:GetAttribute("Open")
    					if AutoHotelOpenAttr == false or AutoHotelOpenAttr == nil then
    						AutoHotelBestNumber = AutoHotelRoomNum
    						AutoHotelBestDoor = AutoHotelDoor
    					end
    				end
    			end
    		end
    	end

    	return AutoHotelBestDoor, AutoHotelBestNumber
    end

    local function AutoHotelFindKeyObtain(AutoHotelRoom)
    	local AutoHotelFound = nil
    	local function AutoHotelScan(AutoHotelParent)
    		if AutoHotelFound then return end
    		for _, AutoHotelChild in ipairs(AutoHotelParent:GetChildren()) do
    			if AutoHotelChild.Name == "KeyObtain" then
    				AutoHotelFound = AutoHotelChild
    				return
    			end
    			AutoHotelScan(AutoHotelChild)
    			if AutoHotelFound then return end
    		end
    	end
    	AutoHotelScan(AutoHotelRoom)
    	return AutoHotelFound
    end

    local function AutoHotelHandleKey(AutoHotelRoomNum)
    	local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
    	if not AutoHotelCurrentRooms then return false end

    	local AutoHotelRoom = AutoHotelCurrentRooms:FindFirstChild(tostring(AutoHotelRoomNum))
    	if not AutoHotelRoom then return false end

    	local AutoHotelDoor = AutoHotelRoom:FindFirstChild("Door")
    	if not AutoHotelDoor or not AutoHotelDoor:FindFirstChild("Lock") then
    		return false
    	end

    	local AutoHotelKeyObtain = AutoHotelFindKeyObtain(AutoHotelRoom)
    	if not AutoHotelKeyObtain then return false end

    	local AutoHotelStart = tick()
    	while tick() - AutoHotelStart < 12 do
    		if LocalPlayer.Backpack:FindFirstChild("Key") or (Character and Character:FindFirstChild("Key")) then
    			return true
    		end

    		if Character then
    			Character:PivotTo(AutoHotelKeyObtain:GetPivot())
    		end

    		for _, AutoHotelDesc in ipairs(AutoHotelKeyObtain:GetDescendants()) do
    			if AutoHotelDesc:IsA("ProximityPrompt") then
    				Functions.FirePrompt(AutoHotelDesc)
    			end
    		end

    		task.wait(0.12)
    	end
    	return false
    end

    local function AutoHotelProcessRoom(AutoHotelRoomNum)
    	if AutoHotelProcessedRooms[AutoHotelRoomNum] then
    		return
    	end
    	task.wait(AutoHotelRoomProcessTime)
    	AutoHotelProcessedRooms[AutoHotelRoomNum] = true
    end

    local function AutoHotelRunLibrary()
    	local AutoHotelCurrentRooms = workspace:WaitForChild("CurrentRooms")
    	local AutoHotelRoom50 = AutoHotelCurrentRooms:WaitForChild("50")
    	local AutoHotelLiveHintBooks = {}
    	local AutoHotelHintPaperObtained = false

    	local function AutoHotelIsInRoom50(AutoHotelObj)
    		return AutoHotelObj and AutoHotelObj:IsDescendantOf(AutoHotelRoom50)
    	end

    	local function AutoHotelIsActuallyInRoom50()
    		return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) == 50
    	end

    	while Toggles.ab_AutoHotel.Value and not AutoHotelIsActuallyInRoom50() do
    		task.wait(0.1)
    	end
    	if not Toggles.ab_AutoHotel.Value then return end

    	AutoHotelWaitForEntities(5)

    	local function AutoHotelHasHintPaper()
    		local AutoHotelChar = LocalPlayer.Character
    		if not AutoHotelChar then return false end
    		return LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper", true) or AutoHotelChar:FindFirstChild("LibraryHintPaper", true)
    	end

    	local function AutoHotelGetCFrame(AutoHotelObj)
    		if not AutoHotelIsActuallyInRoom50() or not AutoHotelIsInRoom50(AutoHotelObj) then return nil end
    		if AutoHotelObj:IsA("Model") then return AutoHotelObj:GetPivot() end
    		if AutoHotelObj:IsA("BasePart") then return AutoHotelObj.CFrame end
    		local AutoHotelPart = AutoHotelObj:FindFirstChildWhichIsA("BasePart", true)
    		return AutoHotelPart and AutoHotelPart.CFrame
    	end

    	local function AutoHotelCollectBooks()
    		for _, AutoHotelDesc in ipairs(AutoHotelRoom50:GetDescendants()) do
    			if AutoHotelDesc.Name == "LiveHintBook" and AutoHotelIsInRoom50(AutoHotelDesc) and not table.find(AutoHotelLiveHintBooks, AutoHotelDesc) then
    				table.insert(AutoHotelLiveHintBooks, AutoHotelDesc)
    			end
    		end
    	end

    	AutoHotelCollectBooks()

    	AutoHotelLibraryRoomConnection = AutoHotelRoom50.DescendantAdded:Connect(function(AutoHotelAdded)
    		if Toggles.ab_AutoHotel.Value and AutoHotelIsActuallyInRoom50() and AutoHotelIsInRoom50(AutoHotelAdded) then
    			if AutoHotelAdded.Name == "LiveHintBook" and not table.find(AutoHotelLiveHintBooks, AutoHotelAdded) then
    				table.insert(AutoHotelLiveHintBooks, AutoHotelAdded)
    			end
    		end
    	end)

    	while Toggles.ab_AutoHotel.Value and AutoHotelIsActuallyInRoom50() and #AutoHotelLiveHintBooks < 3 do
    		AutoHotelCollectBooks()
    		if #AutoHotelLiveHintBooks >= 3 then break end
    		task.wait(0.1)
    	end

    	while Toggles.ab_AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained do
    		if AutoHotelHasHintPaper() then
    			AutoHotelHintPaperObtained = true
    			break
    		end

    		for AutoHotelIndex = #AutoHotelLiveHintBooks, 1, -1 do
    			local AutoHotelBook = AutoHotelLiveHintBooks[AutoHotelIndex]
    			if not AutoHotelIsInRoom50(AutoHotelBook) then
    				table.remove(AutoHotelLiveHintBooks, AutoHotelIndex)
    				continue
    			end

    			while Toggles.ab_AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained and AutoHotelBook.Parent and AutoHotelIsInRoom50(AutoHotelBook) do
    				if AutoHotelHasHintPaper() then
    					AutoHotelHintPaperObtained = true
    					break
    				end

    				local AutoHotelChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    				local AutoHotelHRP = AutoHotelChar:FindFirstChild("HumanoidRootPart")
    				if not AutoHotelHRP then
    					task.wait()
    					continue
    				end

    				local AutoHotelCF = AutoHotelGetCFrame(AutoHotelBook)
    				if AutoHotelCF then
    					AutoHotelHRP.CFrame = AutoHotelCF
    				end

    				for _, AutoHotelPrompt in ipairs(AutoHotelBook:GetDescendants()) do
    					if AutoHotelPrompt:IsA("ProximityPrompt") then
    						Functions.FirePrompt(AutoHotelPrompt)
    					end
    				end
    				task.wait(0.08)
    			end
    			if AutoHotelHintPaperObtained then break end
    		end

    		if AutoHotelHasHintPaper() then
    			AutoHotelHintPaperObtained = true
    			break
    		end

    		local AutoHotelPaper = AutoHotelRoom50:FindFirstChild("LibraryHintPaper", true)
    		if AutoHotelPaper and AutoHotelIsInRoom50(AutoHotelPaper) then
    			while Toggles.ab_AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained and AutoHotelPaper.Parent do
    				if AutoHotelHasHintPaper() then
    					AutoHotelHintPaperObtained = true
    					break
    				end

    				local AutoHotelChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    				local AutoHotelHRP = AutoHotelChar:FindFirstChild("HumanoidRootPart")
    				if AutoHotelHRP then
    					local AutoHotelCF = AutoHotelGetCFrame(AutoHotelPaper)
    					if AutoHotelCF then
    						AutoHotelHRP.CFrame = AutoHotelCF * CFrame.new(0, 5, 0)
    					end
    				end

    				for _, AutoHotelPrompt in ipairs(AutoHotelPaper:GetDescendants()) do
    					if AutoHotelPrompt:IsA("ProximityPrompt") then
    						Functions.FirePrompt(AutoHotelPrompt)
    					end
    				end
    				task.wait(0.08)
    			end
    		end
    		task.wait(0.1)
    	end
    end

    local function AutoHotelHandleSeek()
    	local AutoHotelLastTriggerRoom = nil

    	while Toggles.ab_AutoHotel.Value do
    		local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
    		if not AutoHotelCurrentRooms then
    			task.wait(0.2)
    			continue
    		end

    		local TriggerRoomNum = nil

    		for _, Room in ipairs(AutoHotelCurrentRooms:GetChildren()) do
    			local Num = tonumber(Room.Name)
    			if Num and Num ~= AutoHotelLastTriggerRoom then
    				local Trigger = Room:FindFirstChild("TriggerEventCollision")
    					or Room:FindFirstChild("TriggerEventCollision", true)

    				if Trigger then
    					TriggerRoomNum = Num
    					break
    				end
    			end
    		end

    		if not TriggerRoomNum then
    			task.wait(0.15)
    			continue
    		end

    		AutoHotelLastTriggerRoom = TriggerRoomNum

    		AutoHotelEntityPause = true
    		AutoHotelWaitForEntities(10)
    		AutoHotelEntityPause = false
    	end
    end

    Toggles.ab_AutoHotel:OnChanged(function(AutoHotelEnabled)
    	if AutoHotelConnection then
    		task.cancel(AutoHotelConnection)
    		AutoHotelConnection = nil
    	end
    	if AutoHotelLibraryConnection then
    		task.cancel(AutoHotelLibraryConnection)
    		AutoHotelLibraryConnection = nil
    	end
    	if AutoHotelLibraryRoomConnection then
    		AutoHotelLibraryRoomConnection:Disconnect()
    		AutoHotelLibraryRoomConnection = nil
    	end
    	if AutoHotelSeekConnection then
    		task.cancel(AutoHotelSeekConnection)
    		AutoHotelSeekConnection = nil
    	end

    	AutoHotelEntityPause = false
    	table.clear(AutoHotelProcessedRooms)

    	if not AutoHotelEnabled then return end

    	if Options.AutoHotelRoomProcess then
    		AutoHotelRoomProcessTime = Options.AutoHotelRoomProcess.Value
    		Options.AutoHotelRoomProcess:OnChanged(function(Value)
    			AutoHotelRoomProcessTime = Value
    		end)
    	end

    	local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
    	if AutoHotelCurrentRooms then
    		AutoHotelCurrentRooms.ChildAdded:Connect(function(AutoHotelChild)
    			local AutoHotelNum = tonumber(AutoHotelChild.Name)
    			if AutoHotelNum then
    				AutoHotelProcessRoom(AutoHotelNum)
    			end
    		end)
    	end

    	AutoHotelSeekConnection = task.spawn(AutoHotelHandleSeek)

    	task.spawn(function()
    		while Toggles.ab_AutoHotel.Value do
    			if AutoHotelIsEntityPresent() then
    				AutoHotelEntityPause = true
    				while AutoHotelIsEntityPresent() and Toggles.ab_AutoHotel.Value do
    					task.wait(0.15)
    				end
    				AutoHotelEntityPause = false
    			end
    			task.wait(0.2)
    		end
    	end)

    	AutoHotelConnection = task.spawn(function()
    		while Toggles.ab_AutoHotel.Value do
    			if AutoHotelEntityPause then
    				task.wait(0.1)
    				continue
    			end

    			local AutoHotelDoor, AutoHotelRoomNum = AutoHotelGetNextClosedDoor()

    			if AutoHotelDoor and AutoHotelRoomNum and Character then
    				if AutoHotelRoomNum == 50 then
    					if not AutoHotelLibraryConnection then
    						AutoHotelLibraryConnection = task.spawn(function()
    							AutoHotelRunLibrary()
    							AutoHotelLibraryConnection = nil
    						end)
    					end
    					task.wait(0.4)
    				else
    					AutoHotelProcessRoom(AutoHotelRoomNum)
    					AutoHotelHandleKey(AutoHotelRoomNum)
    					if Character and not AutoHotelEntityPause then
    						Character:PivotTo(AutoHotelDoor:GetPivot() * CFrame.new(0, -1, 0))
    					end
    				end
    			end
    			task.wait(0.15)
    		end
    	end)
    end)


    Groupboxes.Debug = Tabs.General:AddRightGroupbox("Debug")
    Groupboxes.Debug:AddButton({
    	Text = "Ladder Softlock Fix",
    	Tooltip = "Ladder Softlock Fix.",
    	Func = function()
       		LocalPlayer:SetAttribute("Climbing", false)
    	end
    })
    Groupboxes.Debug:AddButton({
    	Text = "Get Current Floor",
    	Tooltip = "Prints the current floor to the console.",
    	Func = function()
    		print("Current Floor:", GameData:WaitForChild("Floor").Value)
    	end
    })
    Groupboxes.Debug:AddButton({
    	Text = "Get Current Room",
    	Tooltip = "Prints the current room number to the console.",
    	Func = function()
    		print("Current Room:", LocalPlayer:GetAttribute("CurrentRoom"))
    	end
    })
    Groupboxes.Debug:AddButton({
    	Text = "Void",
    	Tooltip = "Teleports your character to Y -120.",
    	Func = function()
    		if not Character then return end
    		local Pivot = Character:GetPivot()
    		-- Too lazy to loop this
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
    	end
    })
    Groupboxes.Debug:AddButton({
    	Text = "Death",
    	Tooltip = "Death",
    	Func = function()
    		Globals.Deathing = true
    		LocalPlayer.Character.Humanoid.Health = 0
    	end
    })
    Groupboxes.Debug:AddButton({
    	Text = "Exit Closet",
    	Tooltip = "Exits the current closet.",
    	Func = function()
    		if RemotesFolder and RemotesFolder:FindFirstChild("CamLock") then
    			RemotesFolder.CamLock:FireServer()
    		end
    	end
    })
    local TpNextDoorConnection

    local function getNextClosedDoor()
    	if not Character then return nil end

    	local GameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
    	if not GameData then return nil end

    	local LatestRoom = GameData:FindFirstChild("LatestRoom")
    	if not LatestRoom then return nil end

    	local startRoom = LatestRoom.Value
    	local bestDoor = nil
    	local bestNumber = math.huge

    	for _, obj in ipairs(workspace:GetDescendants()) do
    		if obj.Name == "Door" and obj:IsA("Model") then
    			local openAttr = obj:GetAttribute("Open")
    			if openAttr == false or openAttr == nil then
    				local roomModel = obj.Parent
    				local roomNum = tonumber(roomModel and roomModel.Name)

    				if roomNum and roomNum >= startRoom and roomNum < bestNumber then
    					bestNumber = roomNum
    					bestDoor = obj
    				end
    			end
    		end
    	end

    	return bestDoor
    end

    Groupboxes.Debug:AddButton({
    	Text = "Tp Next Door",
    	Tooltip = "Teleports you to the next sequential unopened door.",
    	Func = function()
    		local door = getNextClosedDoor()
    		if door then
    			Character:PivotTo(door:GetPivot() * CFrame.new(0, -1, 0))
    		end
    	end
    })

    Toggles.ab_TpNextDoor = Groupboxes.Debug:AddToggle("ab_TpNextDoor", {
    	Text = "Auto Tp Next Door",
    	Tooltip = "Continuously teleports you to the next sequential unopened door.",
    	Default = false
    })

    Toggles.ab_TpNextDoor:OnChanged(function(TpNextDoorEnabled)
    	if TpNextDoorConnection then
    		task.cancel(TpNextDoorConnection)
    		TpNextDoorConnection = nil
    	end

    	if not TpNextDoorEnabled then
    		return
    	end

    	TpNextDoorConnection = task.spawn(function()
    		while Toggles.ab_TpNextDoor.Value do
    			local door = getNextClosedDoor()
    			if door and Character then
    				Character:PivotTo(door:GetPivot() * CFrame.new(0, -1, 0))
    			end
    			task.wait(0.15)
    		end
    		TpNextDoorConnection = nil
    	end)
    end)


    Groupboxes.Exploits_Bypass = Tabs.Exploits:AddLeftGroupbox("Bypass / Solve")

    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassGiggle",         { Text = "Bypass Giggle",           Default = false, Tooltip = "Prevents 'Giggle' from attacking you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassDupe",           { Text = "Bypass Dupe",             Default = false, Tooltip = "Prevents you from open 'Dupe' fake doors." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassEyes",           { Text = "Bypass Eyes",             Default = false, Tooltip = "Prevents 'Eyes' from hurting you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassLookman",        { Text = "Bypass Lookman",          Default = false, Tooltip = "Prevents 'Lookman' from hurting you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassGloombatEggs",   { Text = "Bypass Gloombat Eggs",    Default = false, Tooltip = "Prevents taking damage from stepping on 'Gloombat' eggs." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassSeekObstructions", { Text = "Bypass Seek Obstructions", Default = false, Tooltip = "Prevents obstacles in the 'Seek' chase from harming you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassVacuum",         { Text = "Bypass Vacuum",           Default = false, Tooltip = "Prevents you from falling into 'Vacuum' fake doors." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassKillbricks",     { Text = "Bypass Killbricks",       Default = false, Tooltip = "Prevents 'Lava' from hurting you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassSeekingWall",    { Text = "Bypass Seeking Wall",     Default = false, Tooltip = "Prevents 'ScaryWall' from hurting you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassSnare",          { Text = "Bypass Snare",            Default = false, Tooltip = "Prevents 'Snare' from trapping you." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassBanana",         { Text = "Bypass Banana",           Default = false, Tooltip = "Prevents 'Banana Peel' from slipping you up (sometimes doesn't work)." })
    Groupboxes.Exploits_Bypass:AddToggle("ab_BypassJeff",           { Text = "Bypass Jeff",             Default = false, Tooltip = "Prevents 'Jeff the Killer' from stabbing you (sometimes doesn't work)." })


    Toggles.ab_BypassGiggle:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Object.Name == "GiggleCeiling" then
    			Object:WaitForChild("Hitbox").CanTouch = not Value
    		end
    	end
    end)
    Toggles.ab_BypassDupe:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Object.Name == "DoorFake" or Object.Name == "FakeDoor" then
    			Object:WaitForChild("Hidden").CanTouch = not Value
    			if Object:FindFirstChild("Lock") then
    				Object.Lock.UnlockPrompt.Enabled = not Value
    			end
    		end
    	end
    end)
    Toggles.ab_BypassEyes:OnChanged(function(Value)
    	if Value and Globals.IsEyes then
    		if Floor == "Fools" or Floor == "OldHotel" then
    			RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
    		else
    			RemotesFolder.MotorReplication:FireServer(-650)
    		end
    	end
    end)
    Toggles.ab_BypassLookman:OnChanged(function(Value)
    	if Value and Globals.IsLookman then
    		if Floor == "Fools" or Floor == "OldHotel" then
    			RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
    		else
    			RemotesFolder.MotorReplication:FireServer(-650)
    		end
    	end
    end)
    Toggles.ab_BypassGloombatEggs:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		for _, Part in Object:GetDescendants() do
    			if Part:IsA("BasePart") then
    				Part.CanTouch = not Value
    			end
    		end
    	end
    end)
    Toggles.ab_BypassSeekObstructions:OnChanged(function(Value)
    	for _, Object in Objects.SeekObstructions do
    		Object.CanTouch = not Value
    		if Object.Name == "SeekFloodline" then
    			Object.CanCollide = Value
    		end
    	end
    	for _, Object in Objects.SeekBridges do
    		Object.CanCollide = Value
    		Object.Transparency = Value and 0 or 1
    	end
    end)
    Toggles.ab_BypassVacuum:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Object.Name == "SideroomSpace" then
    			Object:WaitForChild("Collision").CanCollide = Value
    			Object:WaitForChild("Collision").CanTouch = not Value
    		end
    	end
    end)
    Toggles.ab_BypassKillbricks:OnChanged(function(Value)
    	for _, Object in Objects.Obstructions do
    		if Object.Name == "Lava" then Object.CanTouch = not Value end
    	end
    end)
    Toggles.ab_BypassSeekingWall:OnChanged(function(Value)
    	for _, Object in Objects.Obstructions do
    		if Object.Name == "ScaryWall" then
    			for _, Part in Object:GetDescendants() do
    				if Part:IsA("BasePart") then
    					Part.CanTouch = not Value
    					Part.CanCollide = not Value
    				end
    			end
    		end
    	end
    end)
    Toggles.ab_BypassSnare:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Object.Name == "Snare" then
    			for _, Part in Object:GetDescendants() do
    				if Part:IsA("BasePart") then Part.CanTouch = not Value end
    			end
    		end
    	end
    end)
    Toggles.ab_BypassBanana:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Object.Name == "BananaPeel" then Object.CanTouch = not Value end
    	end
    end)
    Toggles.ab_BypassJeff:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Object.Name == "JeffTheKiller" then
    			for _, Part in Object:GetDescendants() do
    				if Part:IsA("BasePart") then
    					Part.CanCollide = not Value
    					Part.CanTouch = not Value
    				end
    			end
    			Object:WaitForChild("Humanoid").Health = 0
    		end
    	end
    end)







    -- Archives

    Groupboxes.Archives_Misc = Tabs.Archives:AddRightGroupbox("Exploits / Anti")
    Groupboxes.Archives_Misc:AddToggle("ab_AntiRansom", { Text = "Anti Ransom", Default = false, Tooltip = "Prevents 'Ransom' from attacking you." })
    Groupboxes.Archives_Misc:AddToggle("ab_AntiClosetTrash", { Text = "Anti Closet Trash", Default = false, Tooltip = "Prevents 'Closet Trash' from spawning." })
    Groupboxes.Archives_Misc:AddToggle("ab_ForgetMeNotSolver", { Text = "Forget Me Not Skipper", Default = false, Tooltip = "Automatically Skippes Forget Me Not doors." })
    Groupboxes.Archives_Misc:AddToggle("ab_TimeShower", { Text = "Time Shower", Default = false, Tooltip = "Shows the Archives clock time." })
    Groupboxes.Archives_Misc:AddToggle("ab_BypassDronesStampede", { Text = "Stop Time/Anti Stampede", Default = false, Tooltip = "Prevents 'The Drones Stampede' from attacking you." })
    Groupboxes.Archives_Misc:AddToggle("ab_HonchoCorrectBoxESP", { Text = "Correct Box ESP/Auto Interact", Default = false, Tooltip = "ESP correct Archives boxes in the Honcho sequence and automatically interact with the correct deposit." })

    TimeShowerLabel = Instance.new("TextLabel")
    TimeShowerLabel.Name = "TimeShower"
    TimeShowerLabel.AnchorPoint = Vector2.new(0, 1)
    TimeShowerLabel.Position = UDim2.new(0, 12, 1, -12)
    TimeShowerLabel.Size = UDim2.new(0, 180, 0, 32)
    TimeShowerLabel.BackgroundTransparency = 1
    TimeShowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeShowerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TimeShowerLabel.TextStrokeTransparency = 0.35
    TimeShowerLabel.Font = Enum.Font.GothamBold
    TimeShowerLabel.TextSize = 18
    TimeShowerLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeShowerLabel.Text = "Time: --:--"
    TimeShowerLabel.Visible = false
    TimeShowerLabel.Parent = Container



    local function GetArchivesClockLabel(Room)
    	local Assets = Room and Room:FindFirstChild("Assets", true)
    	local Clock = Assets and Assets:FindFirstChild("ArchivesClock", true)
    	local Time = Clock and Clock:FindFirstChild("Time", true)
    	local TextLabel = Time and Time:FindFirstChild("TextLabel")
    	return (TextLabel and TextLabel:IsA("TextLabel")) and TextLabel or nil
    end

    local function ResolveClockLabel()
    	if TimeShowerSourceLabel and TimeShowerSourceLabel.Parent and TimeShowerSourceLabel:IsDescendantOf(game) then
    		return TimeShowerSourceLabel
    	end
    	local currentRooms = workspace:FindFirstChild("CurrentRooms")
    	if not currentRooms then return nil end
    	local rooms = {}
    	for _, room in ipairs(currentRooms:GetChildren()) do
    		local num = tonumber(room.Name)
    		if num then
    			rooms[#rooms + 1] = { room = room, num = num }
    		end
    	end
    	table.sort(rooms, function(a, b) return a.num > b.num end)
    	for i = 1, math.min(6, #rooms) do
    		local label = GetArchivesClockLabel(rooms[i].room)
    		if label then
    			TimeShowerSourceLabel = label
    			return label
    		end
    	end
    	return nil
    end

    local function ResolveClockRemote()
    	local label = ResolveClockLabel()
    	if not label then return nil end
    	local clock = label:FindFirstAncestor("ArchivesClock")
    	if not clock then return nil end
    	local remote = clock:FindFirstChild("LookedAtRemote", true)
    	return (remote and remote:IsA("RemoteEvent")) and remote or nil
    end

    task.spawn(function()
    	local lastCheckedRoomCount = 0
    	while game:IsLoaded() do
    		local currentRooms = workspace:FindFirstChild("CurrentRooms")
    		if currentRooms then
    			local roomCount = 0
    			for _, child in ipairs(currentRooms:GetChildren()) do
    				if tonumber(child.Name) then
    					roomCount += 1
    				end
    			end
    			if roomCount > 0 and (lastCheckedRoomCount == 0 or roomCount - lastCheckedRoomCount >= 10) then
    				ResolveClockLabel()
    				lastCheckedRoomCount = roomCount
    			end
    		end
    		task.wait(0.5)
    	end
    end)

    local function StopTimeShower()
    	TimeShowerToken += 1
    	if TimeShowerConnection then
    		TimeShowerConnection:Disconnect()
    		TimeShowerConnection = nil
    	end
    	if TimeShowerLabel then
    		TimeShowerLabel.Visible = false
    		TimeShowerLabel.Text = "Time: --:--"
    	end
    end

    Toggles.ab_TimeShower:OnChanged(function(Value)
    	StopTimeShower()
    	if not Value then return end
    	local Token = TimeShowerToken
    	TimeShowerLabel.Visible = true
    	TimeShowerConnection = Services.RunService.Heartbeat:Connect(function()
    		if Token ~= TimeShowerToken then return end
    		local TextLabel = ResolveClockLabel()
    		TimeShowerLabel.Text = TextLabel and ("Time: " .. TextLabel.Text) or "Time: --:--"
    	end)
    end)

    Toggles.ab_BypassDronesStampede:OnChanged(function(enabled)
    	if BypassDronesStampedeConnection then
    		task.cancel(BypassDronesStampedeConnection)
    		BypassDronesStampedeConnection = nil
    	end
    	if not enabled then return end
    	BypassDronesStampedeConnection = task.spawn(function()
    		while Toggles.ab_BypassDronesStampede.Value do
    			local remote = ResolveClockRemote()
    			if remote then
    				remote:FireServer()
    				task.wait(0.5)
    			else
    				task.wait(0.25)
    			end
    		end
    	end)
    end)

    local function ClearHonchoESP()
    	if HonchoCorrectBoxConnection then
    		HonchoCorrectBoxConnection:Disconnect()
    		HonchoCorrectBoxConnection = nil
    	end
    	if HonchoAutoDepositConnection then
    		HonchoAutoDepositConnection:Disconnect()
    		HonchoAutoDepositConnection = nil
    	end
    	for _, Object in pairs(HonchoESPObjects) do
    		if Object and Object.Parent then
    			Functions.RemoveESP(Object)
    		end
    	end
    	table.clear(HonchoESPObjects)
    	table.clear(HonchoProcessedRooms)
    	table.clear(HonchoDepositCache)
    end

    Toggles.ab_HonchoCorrectBoxESP:OnChanged(function(Value)
    	ClearHonchoESP()
    	if not Value then return end
    	local CurrentRooms = workspace:FindFirstChild("CurrentRooms")
    	if not CurrentRooms then return end

    	local function GetESPColor()
    		return (Options.ab_ObjectiveESPColor and Options.ab_ObjectiveESPColor.Value) or Color3.fromRGB(0, 255, 0)
    	end

    	local function AddHonchoESP(Object, Text)
    		Functions.AddESP({ Object = Object, Text = Text, Color = GetESPColor() }, true)
    		HonchoESPObjects[#HonchoESPObjects + 1] = Object
    		Object.Destroying:Once(function()
    			Functions.RemoveESP(Object)
    			local pos = table.find(HonchoESPObjects, Object)
    			if pos then table.remove(HonchoESPObjects, pos) end
    		end)
    	end

    	local function ProcessHonchoRoom(Room)
    		if not tonumber(Room.Name) or not Room.Parent or HonchoProcessedRooms[Room] then return end
    		HonchoProcessedRooms[Room] = true
    		task.wait(3)
    		if not Toggles.ab_HonchoCorrectBoxESP.Value or not Room.Parent then
    			HonchoProcessedRooms[Room] = nil
    			return
    		end
    		local HonchoRoom = Room:FindFirstChild("ArchivesHonchoRoom", true)
    		if not HonchoRoom then
    			HonchoProcessedRooms[Room] = nil
    			return
    		end
    		local BoxIDs = {}
    		local RoomNumber = tonumber(Room.Name)
    		for _, Desc in ipairs(Room:GetDescendants()) do
    			local name = Desc.Name
    			if name == "ArchivesPackageDeposit" or name:match("^ArchivesPackageDeposit") then
    				local id = Desc:GetAttribute("BoxID")
    				if id ~= nil then
    					local idStr = tostring(id)
    					BoxIDs[idStr] = true
    					HonchoDepositCache[idStr] = Desc
    					AddHonchoESP(Desc, "Deposit (" .. idStr .. ")")
    					Desc.Destroying:Once(function()
    						if HonchoDepositCache[idStr] == Desc then
    							HonchoDepositCache[idStr] = nil
    						end
    					end)
    				end
    			end
    		end
    		if not next(BoxIDs) then
    			HonchoProcessedRooms[Room] = nil
    			return
    		end
    		for _, Child in ipairs(HonchoRoom:GetDescendants()) do
    			if Child.Name == "ArchivesStorageBox" then
    				local ToolBoxID = Child:GetAttribute("Tool_BoxID")
    				if ToolBoxID ~= nil and BoxIDs[tostring(ToolBoxID)] then
    					if not Child:GetAttribute("ParentRoom") then
    						Child:SetAttribute("ParentRoom", RoomNumber)
    					end
    					Child.Name = "ArchivesStorageBoxCorrect"
    					AddHonchoESP(Child, "Correct Box (" .. tostring(ToolBoxID) .. ")")
    				end
    			end
    		end
    	end

    	for _, Room in ipairs(CurrentRooms:GetChildren()) do
    		task.spawn(ProcessHonchoRoom, Room)
    	end

    	HonchoCorrectBoxConnection = CurrentRooms.ChildAdded:Connect(function(Room)
    		task.spawn(ProcessHonchoRoom, Room)
    	end)

    	local lastCheck = 0
    	HonchoAutoDepositConnection = game:GetService("RunService").Heartbeat:Connect(function()
    		if not Toggles.ab_HonchoCorrectBoxESP.Value then return end
    		local now = os.clock()
    		if now - lastCheck < 0.1 then return end
    		lastCheck = now
    		local Character = LocalPlayer and LocalPlayer.Character
    		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    		if not Character or not HumanoidRootPart then return end
    		local BoxCandidates = {}
    		for _, Object in ipairs(Character:GetChildren()) do
    			if (Object:IsA("Tool") or Object:IsA("Model")) and (Object.Name == "ArchivesStorageBox" or Object.Name == "ArchivesStorageBoxCorrect") then
    				BoxCandidates[#BoxCandidates + 1] = Object
    			end
    		end
    		local Drops = workspace:FindFirstChild("Drops")
    		if Drops then
    			for _, Object in ipairs(Drops:GetChildren()) do
    				if Object.Name == "ArchivesStorageBox" or Object.Name == "ArchivesStorageBoxCorrect" then
    					BoxCandidates[#BoxCandidates + 1] = Object
    				end
    			end
    		end
    		for _, Box in ipairs(BoxCandidates) do
    			if not (Box and Box.Parent) then continue end
    			local BoxID = Box:GetAttribute("Tool_BoxID") or Box:GetAttribute("BoxID")
    			if BoxID == nil then continue end
    			local Deposit = HonchoDepositCache[tostring(BoxID)]
    			if not Deposit or not Deposit.Parent then continue end
    			if Box.Parent == Drops and not Box:GetAttribute("HonchoCorrectESP") then
    				Box:SetAttribute("HonchoCorrectESP", true)
    				AddHonchoESP(Box, "Correct Box (" .. tostring(BoxID) .. ")")
    			end
    			if Box.Parent == Character then
    				local DepositPart = Deposit:IsA("BasePart") and Deposit or Deposit:FindFirstChildWhichIsA("BasePart", true)
    				if DepositPart and (HumanoidRootPart.Position - DepositPart.Position).Magnitude <= 10 then
    					local Prompt = Deposit:FindFirstChildWhichIsA("ProximityPrompt", true)
    					if Prompt then
    						Functions.FirePrompt(Prompt)
    					end
    				end
    			end
    		end
    	end)
    end)


    Groupboxes.Archives_Bypasses = Tabs.Archives:AddLeftGroupbox("Bypasses")
    Groupboxes.Archives_Bypasses:AddToggle("ab_BypassWater", { Text = "Bypass Electric Water", Default = false, Tooltip = "Prevents electric water from hurting you." })
    Groupboxes.Archives_Bypasses:AddToggle("ab_BypassAlma", { Text = "Bypass Alma", Default = false, Tooltip = "Prevents 'Alma' from spawning." })
    Groupboxes.Archives_Bypasses:AddToggle("ab_BypassDrones", { Text = "Bypass Drones", Default = false, Tooltip = "Prevents 'Drones' from attacking you." })
    Groupboxes.Archives_Bypasses:AddToggle("ab_AntiScribbles", { Text = "Bypass Scribbles", Default = false, Tooltip = "Prevents 'Scribbles' from attacking you." })

    Groupboxes.Archives_Experimental = Tabs.Archives:AddLeftGroupbox("Experimental")

    Toggles.ab_AntiClosetTrash:OnChanged(function(Value)
    	if AntiClosetTrash_Connection then
    		AntiClosetTrash_Connection:Disconnect()
    		AntiClosetTrash_Connection = nil
    	end
    	if not Value then return end
    	AntiClosetTrash_Connection = workspace.ChildAdded:Connect(function(Child)
    		if not Toggles.ab_AntiClosetTrash.Value then return end
    		local Name = Child.Name
    		if Name:sub(1, 6) == "Binder" or Name:sub(1, 4) == "Shoe" or Name:sub(1, 5) == "Shelf" then
    			Child:Destroy()
    		end
    	end)
    end)

    Toggles.ab_AntiRansom:OnChanged(function(Value)
    	if AntiRansom_Connection then
    		AntiRansom_Connection:Disconnect()
    		AntiRansom_Connection = nil
    	end
    	if not Value then return end
    	AntiRansom_Connection = workspace.ChildAdded:Connect(function(Child)
    		if Child.Name == "Ransom" and Toggles.ab_AntiRansom.Value then
    			Child:Destroy()
    			print("Ransom gone hehehehehehehehe")
    		end
    	end)
    end)

    Toggles.ab_ForgetMeNotSolver:OnChanged(function(Value)
    	if ForgetMeNotConnection then
    		ForgetMeNotConnection:Disconnect()
    		ForgetMeNotConnection = nil
    	end
    	ForgetMeNotRunning = false
    	table.clear(ForgetMeNotProcessing)
    	table.clear(ForgetMeNotNotified)
    	if not Value then return end
    	ForgetMeNotRunning = true

    	local function GetCharacter()
    		return game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    	end

    	local function GetNextRoom(Number)
    		while ForgetMeNotRunning do
    			for RoomNumber = Number + 1, Number + 5 do
    				local NextRoom = workspace.CurrentRooms:FindFirstChild(tostring(RoomNumber))
    				if NextRoom then return NextRoom end
    			end
    			task.wait(0.1)
    		end
    		return nil
    	end

    	local function FireLookAts(Room)
    		for i = 1, 6 do
    			local Obj = Room:FindFirstChild(tostring(i))
    			if Obj then
    				local LookAt = Obj:FindFirstChild("LookAt")
    				if LookAt then
    					pcall(function() LookAt:FireServer() end)
    				end
    			end
    		end
    	end

    	local function VoidCharacter()
    		local Character = GetCharacter()
    		if not Character then return end

    		local voidCF = CFrame.new(0, -120, 0)
    		local start = tick()
    		while ForgetMeNotRunning and tick() - start < 2 do
    			Character:PivotTo(voidCF)
    			task.wait(0.1)
    		end
    	end

    	local function Run(Room)
    		local RoomNumber = tonumber(Room.Name)
    		if not RoomNumber or not ForgetMeNotRunning or ForgetMeNotProcessing[RoomNumber] then return end

    		if not Room:FindFirstChild("ForgetMeNotVineDoors", true) then
    			return
    		end

    		ForgetMeNotProcessing[RoomNumber] = true

    		while ForgetMeNotRunning and Room.Parent do
    			FireLookAts(Room)

    			local NextRoom = GetNextRoom(RoomNumber)
    			if not NextRoom then
    				task.wait(0.4)
    				continue
    			end

    			local Door = NextRoom:FindFirstChild("Door")

    			if not Door then
    				local Character = GetCharacter()
    				if Character then
    					local Target = NextRoom:FindFirstChildWhichIsA("BasePart") or NextRoom
    					if Target:IsA("BasePart") then
    						Character:PivotTo(Target.CFrame + Vector3.new(0, 3, 0))
    					elseif Target:IsA("Model") then
    						Character:PivotTo(Target:GetPivot() + Vector3.new(0, 3, 0))
    					else
    						Character:PivotTo(CFrame.new(NextRoom:GetPivot().Position + Vector3.new(0, 5, 0)))
    					end
    				end
    				break
    			end

    			if Door:GetAttribute("Opened") == true then
    				VoidCharacter()
    				break
    			end

    			local Hidden = Door:FindFirstChild("Hidden") or Door:WaitForChild("Hidden", 2)
    			if not Hidden then
    				task.wait(0.3)
    				continue
    			end

    			while ForgetMeNotRunning and Room.Parent and NextRoom.Parent and Door.Parent and Door:GetAttribute("Opened") ~= true do
    				local Character = GetCharacter()
    				if Character then
    					if Hidden:IsA("BasePart") then
    						Character:PivotTo(Hidden.CFrame)
    					elseif Hidden:IsA("Model") then
    						Character:PivotTo(Hidden:GetPivot())
    					end
    				end
    				pcall(function() Door.ClientOpen:Fire() end)
    				pcall(function() Door.ClientOpen:FireServer() end)
    				task.wait()
    			end

    			if ForgetMeNotRunning and Door.Parent and Door:GetAttribute("Opened") == true then
    				VoidCharacter()
    			end

    			break
    		end

    		ForgetMeNotProcessing[RoomNumber] = nil
    	end

    	local function CheckRooms()
    		local LatestRoomNumber = tonumber(LatestRoom.Value) or 0
    		local FirstRoomNumber = math.max(0, LatestRoomNumber - 3)
    		for RoomNumber = FirstRoomNumber, LatestRoomNumber do
    			if not ForgetMeNotRunning then return end
    			local Room = workspace.CurrentRooms:FindFirstChild(tostring(RoomNumber))
    			if Room and not ForgetMeNotProcessing[RoomNumber] then
    				task.spawn(Run, Room)
    			end
    		end
    	end

    	ForgetMeNotConnection = workspace.CurrentRooms.ChildAdded:Connect(function(Room)
    		if not tonumber(Room.Name) then return end
    		task.spawn(function()
    			task.wait(1)
    			if ForgetMeNotRunning and Room.Parent then
    				task.spawn(Run, Room)
    			end
    		end)
    	end)

    	task.spawn(function()
    		while ForgetMeNotRunning do
    			CheckRooms()
    			task.wait(1)
    		end
    	end)

    	CheckRooms()
    end)

    Toggles.ab_BypassWater:OnChanged(function(Value)
    	Functions.Notify({ Title = "PositionSpoof Will Break This!." })

    	if WaterBypassConnection then
    		WaterBypassConnection:Disconnect()
    		WaterBypassConnection = nil
    	end

    	if not Value then
    		for _, WaterBypassPart in pairs(WaterParts) do
    			if WaterBypassPart then
    				WaterBypassPart:Destroy()
    			end
    		end
    		table.clear(WaterParts)
    		return
    	end

    	local CurrentRooms = workspace.CurrentRooms

    	local function ProcessWaterBypassRoom(WaterBypassRoom)
    		if not tonumber(WaterBypassRoom.Name) then return end

    		task.wait(3)

    		local WaterBypassWater = WaterBypassRoom:FindFirstChild("Water")
    		if not WaterBypassWater or WaterParts[WaterBypassWater] then return end

    		local WaterBypassPart = Instance.new("Part")
    		WaterBypassPart.Name = "WaterBypass"
    		WaterBypassPart.Anchored = true
    		WaterBypassPart.CanCollide = true
    		WaterBypassPart.CanTouch = false
    		WaterBypassPart.CanQuery = false
    		WaterBypassPart.Transparency = 0.25
    		WaterBypassPart.Color = Color3.fromRGB(0, 150, 255)
    		WaterBypassPart.Material = Enum.Material.ForceField

    		local WaterBypassSize, WaterBypassCFrame
    		if WaterBypassWater:IsA("BasePart") then
    			WaterBypassSize = WaterBypassWater.Size
    			WaterBypassCFrame = WaterBypassWater.CFrame
    		elseif WaterBypassWater:IsA("Model") then
    			WaterBypassCFrame, WaterBypassSize = WaterBypassWater:GetBoundingBox()
    		else
    			WaterBypassSize = Vector3.new(10, 1.5, 10)
    			WaterBypassCFrame = WaterBypassWater:GetPivot()
    		end

    		WaterBypassPart.Size = WaterBypassSize + Vector3.new(0, 0.5, 0)
    		WaterBypassPart.CFrame = WaterBypassCFrame * CFrame.new(0, 0.25, 0)

    		if WaterBypassPart.Size.Y > 3 then
    			WaterBypassPart:Destroy()
    			Functions.Notify({ Title = "Water Bypass removed: Softlock." })
    			return
    		end

    		WaterBypassPart.Parent = WaterBypassRoom
    		WaterParts[WaterBypassWater] = WaterBypassPart
    	end

    	local WaterBypassLatestRoomNumber = tonumber(LatestRoom.Value) or 0
    	for WaterBypassRoomNumber = math.max(0, WaterBypassLatestRoomNumber - 4), WaterBypassLatestRoomNumber do
    		local WaterBypassRoom = CurrentRooms:FindFirstChild(tostring(WaterBypassRoomNumber))
    		if WaterBypassRoom then
    			task.spawn(ProcessWaterBypassRoom, WaterBypassRoom)
    		end
    	end

    	WaterBypassConnection = CurrentRooms.ChildAdded:Connect(function(WaterBypassRoom)
    		task.spawn(ProcessWaterBypassRoom, WaterBypassRoom)
    	end)
    end)

    Toggles.ab_BypassAlma:OnChanged(function(Value)
    	if AlmaConnection then
    		AlmaConnection:Disconnect()
    		AlmaConnection = nil
    	end
    	if Value then
    		for _, child in ipairs(workspace:GetChildren()) do
    			if child.Name == "Alma" then child:Destroy() end
    		end
    		AlmaConnection = workspace.ChildAdded:Connect(function(child)
    			if child.Name == "Alma" then child:Destroy() end
    		end)
    	end
    end)

    Toggles.ab_AntiScribbles:OnChanged(function(Value)
    	if AntiScribbles_Connection then
    		AntiScribbles_Connection:Disconnect()
    		AntiScribbles_Connection = nil
    	end
    	if not Value then return end
    	AntiScribbles_Connection = workspace.ChildAdded:Connect(function(Child)
    		if Child.Name == "Scribbles" and Toggles.ab_AntiScribbles.Value then
    			local ExploitSribbleWarning = Child:FindFirstChild("IfYoureExploitingDeleteThis")
    			if ExploitSribbleWarning then ExploitSribbleWarning:Destroy() end
    		end
    	end)
    end)

    Toggles.ab_BypassDrones:OnChanged(function(Value)
    	local RS = game:GetService("ReplicatedStorage")
    	local function ProcessDrones(drones)
    		local WalkedInto = drones:FindFirstChild("WalkedInto") or drones:WaitForChild("WalkedInto", 3)
    		if WalkedInto and not DroneWalkedIntoParents[WalkedInto] then
    			DroneWalkedIntoParents[WalkedInto] = drones
    			WalkedInto.Parent = RS
    		end
    	end
    	if Value then
    		for _, child in ipairs(workspace:GetChildren()) do
    			if child.Name == "Drones" then ProcessDrones(child) end
    		end
    		if DroneConnection then DroneConnection:Disconnect() end
    		DroneConnection = workspace.ChildAdded:Connect(function(child)
    			if child.Name == "Drones" then ProcessDrones(child) end
    		end)
    	else
    		for WalkedInto, originalParent in pairs(DroneWalkedIntoParents) do
    			if WalkedInto and WalkedInto.Parent and originalParent and originalParent.Parent then
    				WalkedInto.Parent = originalParent
    			end
    		end
    		table.clear(DroneWalkedIntoParents)
    		if DroneConnection then
    			DroneConnection:Disconnect()
    			DroneConnection = nil
    		end
    	end
    end)

    Groupboxes.Stairwell_Misc = Tabs.Stairwell:AddLeftGroupbox("Exploits / Anti / Misc")



    Groupboxes.Stairwell_Misc:AddDivider()
    Groupboxes.Stairwell_Misc:AddToggle("ab_BypassNoise", { Text = "Noise Tv Breaker", Default = false, Tooltip = "Breaks the tv of noise while holding it." })


    Groupboxes.Stairwell_Misc:AddToggle("ab_DroppedItemValue", { Text = "Item Number", Default = false, Tooltip = "Shows the number of dropped items." })

    Groupboxes.Stairwell_Misc:AddToggle("ab_KillAllWithCart", {
    	Text = "Kill All (Requires ≥1 Cart)",
    	Default = false,
    })
    Groupboxes.Stairwell_Misc:AddToggle("ab_FlingCreak", {
    	Text = "Bug Out Creak (Requires ≥5 Cart)",
    	Default = false,
    	ToolTip = "DONT TOUCH THE CARTS URSELF, U WILL DIE"
    })
    Groupboxes.Stairwell_Misc:AddToggle("ab_CreakAggressionMeter", {
        Text = "Creak Aggression Meter",
        Default = false,
        Tooltip = "Shows Creak's aggression above its head."
    })

    local CreakAggressionMetersTable = {}
    local CreakAggressionCamera = Workspace.CurrentCamera
    local CreakAggressionChildAddedConnection = nil

    local function CleanupCreakAggressionMeter(CreakModel)
        local CreakMeterData = CreakAggressionMetersTable[CreakModel]
        if not CreakMeterData then return end

        CreakAggressionMetersTable[CreakModel] = nil

        if CreakMeterData.RenderConnection then
            CreakMeterData.RenderConnection:Disconnect()
        end
        if CreakMeterData.DestroyConnection then
            CreakMeterData.DestroyConnection:Disconnect()
        end

        for _, CreakDrawingObject in ipairs(CreakMeterData.Drawings) do
            pcall(function() CreakDrawingObject:Remove() end)
        end
    end

    local function GetCreakAggressionValue(CreakModel)
        local CreakAnimator = CreakModel:FindFirstChildOfClass("Animator")
            or (CreakModel:FindFirstChild("AnimationController") and CreakModel.AnimationController:FindFirstChildOfClass("Animator"))
            or CreakModel:FindFirstChildOfClass("AnimationController")

        if not CreakAnimator then return nil end

        for _, CreakAnimationTrack in ipairs(CreakAnimator:GetPlayingAnimationTracks()) do
            if CreakAnimationTrack.Name == "CreakGraph" or (CreakAnimationTrack.Animation and CreakAnimationTrack.Animation.Name == "CreakGraph") then
                local CreakSuccess, CreakAggressionValue = pcall(CreakAnimationTrack.GetParameter, CreakAnimationTrack, "Aggression")
                if CreakSuccess and typeof(CreakAggressionValue) == "number" then
                    return math.clamp(CreakAggressionValue, 0, 1)
                end
            end
        end
        return nil
    end

    local function CreateCreakAggressionDrawings()
        local CreakDrawingList = {}

        local function CreateCreakDrawing(CreakDrawingType)
            local CreakNewDrawing = Drawing.new(CreakDrawingType)
            table.insert(CreakDrawingList, CreakNewDrawing)
            return CreakNewDrawing
        end

        local CreakTitleText = CreateCreakDrawing("Text")
        CreakTitleText.Text = "Aggression --%"
        CreakTitleText.Size = 16
        CreakTitleText.Font = Drawing.Fonts.Plex
        CreakTitleText.Color = Color3.fromRGB(255, 255, 255)
        CreakTitleText.Center = true
        CreakTitleText.Outline = true
        CreakTitleText.Visible = false

        local CreakBarBackground = CreateCreakDrawing("Square")
        CreakBarBackground.Size = Vector2.new(112, 6)
        CreakBarBackground.Filled = true
        CreakBarBackground.Color = Color3.fromRGB(58, 58, 64)
        CreakBarBackground.Transparency = 0.15
        CreakBarBackground.Visible = false

        local CreakBarFill = CreateCreakDrawing("Square")
        CreakBarFill.Size = Vector2.new(0, 6)
        CreakBarFill.Filled = true
        CreakBarFill.Visible = false

        return {
            Drawings = CreakDrawingList,
            TitleText = CreakTitleText,
            BarBackground = CreakBarBackground,
            BarFill = CreakBarFill
        }
    end

    local function AddCreakAggressionMeter(CreakModel)
        if not Toggles.ab_CreakAggressionMeter.Value or CreakModel.Name ~= "Creak" or CreakAggressionMetersTable[CreakModel] then
            return
        end

        local CreakHeadPart = CreakModel:FindFirstChild("Head")
        if not CreakHeadPart or not CreakHeadPart:IsA("BasePart") then return end

        local CreakMeterData = CreateCreakAggressionDrawings()
        CreakAggressionMetersTable[CreakModel] = CreakMeterData

        CreakMeterData.RenderConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.ab_CreakAggressionMeter.Value or not CreakModel.Parent or not CreakHeadPart.Parent then
                CleanupCreakAggressionMeter(CreakModel)
                return
            end

            if not CreakAggressionCamera or not CreakAggressionCamera.Parent then
                CreakAggressionCamera = Workspace.CurrentCamera
                if not CreakAggressionCamera then return end
            end

            local CreakScreenPosition, CreakIsOnScreen = CreakAggressionCamera:WorldToViewportPoint(CreakHeadPart.Position + Vector3.new(0, 1.85, 0))
            if not (CreakIsOnScreen and CreakScreenPosition.Z > 0) then
                CreakMeterData.TitleText.Visible = false
                CreakMeterData.BarBackground.Visible = false
                CreakMeterData.BarFill.Visible = false
                return
            end

            CreakMeterData.TitleText.Position = Vector2.new(CreakScreenPosition.X, CreakScreenPosition.Y - 28)
            CreakMeterData.BarBackground.Position = Vector2.new(CreakScreenPosition.X - 56, CreakScreenPosition.Y - 6)
            CreakMeterData.BarFill.Position = CreakMeterData.BarBackground.Position

            local CreakAggressionValue = GetCreakAggressionValue(CreakModel)

            if not CreakAggressionValue then
                CreakMeterData.TitleText.Text = "Aggression --%"
                CreakMeterData.TitleText.Color = Color3.fromRGB(200, 200, 200)
                CreakMeterData.BarFill.Size = Vector2.new(0, 6)
                CreakMeterData.TitleText.Visible = true
                CreakMeterData.BarBackground.Visible = true
                CreakMeterData.BarFill.Visible = false
                return
            end

            CreakMeterData.TitleText.Text = "Aggression " .. math.floor(CreakAggressionValue * 100 + 0.5) .. "%"
            CreakMeterData.TitleText.Color = Color3.fromRGB(255, 255, 255)
            CreakMeterData.BarFill.Size = Vector2.new(112 * CreakAggressionValue, 6)
            CreakMeterData.BarFill.Color = Color3.fromRGB(70, 220, 100):Lerp(Color3.fromRGB(255, 55, 55), CreakAggressionValue)
            CreakMeterData.TitleText.Visible = true
            CreakMeterData.BarBackground.Visible = true
            CreakMeterData.BarFill.Visible = true
        end)

        CreakMeterData.DestroyConnection = CreakModel.Destroying:Connect(function()
            CleanupCreakAggressionMeter(CreakModel)
        end)
    end

    local function StartCreakAggressionListener()
        if CreakAggressionChildAddedConnection then return end

        local CreakLiveEntitiesFolder = Workspace:FindFirstChild("LiveEntities")
        if not CreakLiveEntitiesFolder then return end

        CreakAggressionChildAddedConnection = CreakLiveEntitiesFolder.ChildAdded:Connect(function(CreakNewChild)
            if CreakNewChild.Name == "Creak" then
                AddCreakAggressionMeter(CreakNewChild)
            end
        end)
    end

    local function StopCreakAggressionListener()
        if CreakAggressionChildAddedConnection then
            CreakAggressionChildAddedConnection:Disconnect()
            CreakAggressionChildAddedConnection = nil
        end
    end

    Toggles.ab_CreakAggressionMeter:OnChanged(function(CreakToggleEnabled)
        if CreakToggleEnabled then
            for _, CreakEntityModel in ipairs(Objects.Entities or {}) do
                AddCreakAggressionMeter(CreakEntityModel)
            end

            local CreakLiveEntitiesFolder = Workspace:FindFirstChild("LiveEntities")
            local CreakExistingModel = CreakLiveEntitiesFolder and CreakLiveEntitiesFolder:FindFirstChild("Creak")
            if CreakExistingModel then
                AddCreakAggressionMeter(CreakExistingModel)
            end

            StartCreakAggressionListener()
        else
            StopCreakAggressionListener()

            for CreakEntityModel in pairs(CreakAggressionMetersTable) do
                CleanupCreakAggressionMeter(CreakEntityModel)
            end
        end
    end)

    Toggles.ab_KillAllWithCart:OnChanged(function(KillAllWithCartState)
    	if not KillAllWithCartState then return end

    	local KillAllWithCartIndex = 1

    	task.spawn(function()
    		while Toggles.ab_KillAllWithCart.Value do
    			local KillAllWithCartCarts = {}
    			for _, KillAllWithCartModel in ipairs(workspace.Misc:GetChildren()) do
    				if KillAllWithCartModel.Name == "ShoppingCart" and KillAllWithCartModel:IsA("Model") then
    					KillAllWithCartCarts[#KillAllWithCartCarts + 1] = KillAllWithCartModel
    				end
    			end

    			local KillAllWithCartAlivePlayers = {}
    			for _, KillAllWithCartPlayer in ipairs(game.Players:GetPlayers()) do
    				if KillAllWithCartPlayer ~= game.Players.LocalPlayer and KillAllWithCartPlayer.Character then
    					local KillAllWithCartHumanoid = KillAllWithCartPlayer.Character:FindFirstChildOfClass("Humanoid")
    					if KillAllWithCartHumanoid and KillAllWithCartHumanoid.Health > 0 then
    						KillAllWithCartAlivePlayers[#KillAllWithCartAlivePlayers + 1] = KillAllWithCartPlayer
    					end
    				end
    			end

    			if #KillAllWithCartCarts > 0 and #KillAllWithCartAlivePlayers > 0 then
    				if KillAllWithCartIndex > #KillAllWithCartAlivePlayers then
    					KillAllWithCartIndex = 1
    				end
    				local KillAllWithCartTarget = KillAllWithCartAlivePlayers[KillAllWithCartIndex]
    				local KillAllWithCartTargetCFrame = KillAllWithCartTarget.Character:GetPivot()
    				for KillAllWithCartCartIndex = 1, #KillAllWithCartCarts do
    					KillAllWithCartCarts[KillAllWithCartCartIndex]:PivotTo(KillAllWithCartTargetCFrame)
    				end
    				KillAllWithCartIndex = KillAllWithCartIndex + 1
    			end
    			task.wait(0.10)
    		end
    	end)
    end)

    Toggles.ab_FlingCreak:OnChanged(function(FlingCreakState)
    	if not FlingCreakState then return end

    	task.spawn(function()
    		while Toggles.ab_FlingCreak.Value do
    			local creak = workspace:FindFirstChild("LiveEntities") and workspace.LiveEntities:FindFirstChild("Creak")
    			if creak then
    				local targetCFrame = creak:GetPivot()
    				for _, model in ipairs(workspace.Misc:GetChildren()) do
    					if model.Name == "ShoppingCart" and model:IsA("Model") then
    						model:PivotTo(targetCFrame)
    					end
    				end
    			end
    			task.wait(0.10)
    		end
    	end)
    end)




    Groupboxes.Stairwell_Misc:AddDivider()


    Groupboxes.Stairwell_Misc:AddToggle("ab_DisableStairwellCrusherCollision", {
    	Text = "Disable Crushers",
    	Default = false,
    })
    Groupboxes.Stairwell_Misc:AddToggle("ab_DeleteStairwellCrusherExceptBasicWall", {
    	Text = "Delete Crushers",
    	Default = false,
    })
    Groupboxes.Stairwell_Misc:AddToggle("ab_MeldRemover", {
    	Text = "Remove Meld",
    	Default = false,
    })

    Groupboxes.Stairwell_Misc:AddToggle("ab_StairwellLandingSpam", {
    	Text = "TP to trash and drop trash.",
    	Tooltip = "Combine with orbit, or bring all dropped items.",
    	Default = false,
    })

    Toggles.ab_DisableStairwellCrusherCollision:OnChanged(function(DisableStairwellCrusherCollisionState)
    	if not DisableStairwellCrusherCollisionState then return end

    	task.spawn(function()
    		while Toggles.ab_DisableStairwellCrusherCollision.Value do
    			for _, DisableStairwellCrusherRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
    				local DisableStairwellCrusherAssets = DisableStairwellCrusherRoom:FindFirstChild("Assets")
    				if DisableStairwellCrusherAssets then
    					for _, DisableStairwellCrusherContainer in ipairs(DisableStairwellCrusherAssets:GetChildren()) do
    						if DisableStairwellCrusherContainer.Name == "StairwellCrusherContainer1" then
    							for _, DisableStairwellCrusherDescendant in ipairs(DisableStairwellCrusherContainer:GetDescendants()) do
    								if DisableStairwellCrusherDescendant:IsA("BasePart") and DisableStairwellCrusherDescendant.CanCollide then
    									local DisableStairwellCrusherUnderBasicWall = false
    									local DisableStairwellCrusherParent = DisableStairwellCrusherDescendant.Parent
    									while DisableStairwellCrusherParent and DisableStairwellCrusherParent ~= DisableStairwellCrusherContainer do
    										if DisableStairwellCrusherParent.Name == "BasicWall" then
    											DisableStairwellCrusherUnderBasicWall = true
    											break
    										end
    										DisableStairwellCrusherParent = DisableStairwellCrusherParent.Parent
    									end
    									if not DisableStairwellCrusherUnderBasicWall then
    										DisableStairwellCrusherDescendant.CanCollide = false
    									end
    								end
    							end
    						end

    						local DisableStairwellCrusher = DisableStairwellCrusherContainer:FindFirstChild("StairwellCrusher")
    						if DisableStairwellCrusher then
    							local DisableStairwellCrusherOuterTrigger = DisableStairwellCrusher:FindFirstChild("OuterTrigger")
    							local DisableStairwellCrusherCoreTrigger = DisableStairwellCrusher:FindFirstChild("CoreTrigger")
    							if DisableStairwellCrusherOuterTrigger then
    								DisableStairwellCrusherOuterTrigger:Destroy()
    							end
    							if DisableStairwellCrusherCoreTrigger then
    								DisableStairwellCrusherCoreTrigger:Destroy()
    							end
    						end
    					end
    				end
    			end
    			task.wait(0.5)
    		end
    	end)
    end)
    Toggles.ab_DeleteStairwellCrusherExceptBasicWall:OnChanged(function(DeleteStairwellCrusherExceptBasicWallState)
    	if not DeleteStairwellCrusherExceptBasicWallState then return end

    	task.spawn(function()
    		while Toggles.ab_DeleteStairwellCrusherExceptBasicWall.Value do
    			for _, DeleteStairwellCrusherRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
    				local DeleteStairwellCrusherAssets = DeleteStairwellCrusherRoom:FindFirstChild("Assets")
    				if DeleteStairwellCrusherAssets then
    					for _, DeleteStairwellCrusherContainer in ipairs(DeleteStairwellCrusherAssets:GetChildren()) do
    						if DeleteStairwellCrusherContainer.Name == "StairwellCrusherContainer1" then
    							local DeleteStairwellCrusherToDestroy = {}
    							for _, DeleteStairwellCrusherDescendant in ipairs(DeleteStairwellCrusherContainer:GetDescendants()) do
    								local DeleteStairwellCrusherUnderBasicWall = false
    								local DeleteStairwellCrusherParent = DeleteStairwellCrusherDescendant.Parent
    								while DeleteStairwellCrusherParent and DeleteStairwellCrusherParent ~= DeleteStairwellCrusherContainer do
    									if DeleteStairwellCrusherParent.Name == "BasicWall" then
    										DeleteStairwellCrusherUnderBasicWall = true
    										break
    									end
    									DeleteStairwellCrusherParent = DeleteStairwellCrusherParent.Parent
    								end
    								if not DeleteStairwellCrusherUnderBasicWall and DeleteStairwellCrusherDescendant.Name ~= "BasicWall" then
    									DeleteStairwellCrusherToDestroy[#DeleteStairwellCrusherToDestroy + 1] = DeleteStairwellCrusherDescendant
    								end
    							end
    							for _, DeleteStairwellCrusherInstance in ipairs(DeleteStairwellCrusherToDestroy) do
    								if DeleteStairwellCrusherInstance and DeleteStairwellCrusherInstance.Parent then
    									DeleteStairwellCrusherInstance:Destroy()
    								end
    							end
    						end
    					end
    				end
    			end
    			task.wait(0.5)
    		end
    	end)
    end)

    Toggles.ab_MeldRemover:OnChanged(function(State)
    	if not State then return end
    	task.spawn(function()
    		while Toggles.ab_MeldRemover.Value do
    			for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
    				for _, folderName in ipairs({"Assets", "Parts"}) do
    					local folder = room:FindFirstChild(folderName)
    					if folder then
    						for _, child in ipairs(folder:GetChildren()) do
    							if child.Name == "MeldWall"
    								or child.Name == "Boleahghth29tdgfhy2thuy2htuu259uhh3u" -- no qeustions asked
    							then
    								child:Destroy()
    							end
    						end
    					end
    				end
    				for _, name in ipairs({"MeldData", "MeldPads", "Meldview", "Meld"}) do
    					local obj = room:FindFirstChild(name)
    					if obj and obj:IsA("Folder") then
    						obj:Destroy()
    					end
    				end
    			end
    			task.wait(0.5)
    		end
    	end)
    end)




    local StairwellLandingToken = 0

    Toggles.ab_StairwellLandingSpam:OnChanged(function(Value)
    	StairwellLandingToken += 1

    	if not Value then
    		return
    	end

    	local CurrentToken = StairwellLandingToken

    	task.spawn(function()
    		local CurrentRooms = workspace.CurrentRooms
    		local LocalPlayer = Services.Players.LocalPlayer

    		while Toggles.ab_StairwellLandingSpam.Value and CurrentToken == StairwellLandingToken do
    			local StairwellModels = {}

    			for _, Room in ipairs(CurrentRooms:GetChildren()) do
    				local StairwellLandingLogic = Room:FindFirstChild("StairwellLandingLogic")

    				if StairwellLandingLogic then
    					for _, Model in ipairs(StairwellLandingLogic:GetChildren()) do
    						if Model:IsA("Model") then
    							local Prompts = {}

    							for _, Object in ipairs(Model:GetDescendants()) do
    								if Object:IsA("ProximityPrompt") then
    									Prompts[#Prompts + 1] = Object
    								end
    							end

    							if #Prompts > 0 then
    								StairwellModels[#StairwellModels + 1] = {
    									Model = Model,
    									Prompts = Prompts,
    								}
    							end
    						end
    					end
    				end
    			end

    			table.sort(StairwellModels, function(First, Second)
    				local FirstRoom = First.Model.Parent and First.Model.Parent.Parent
    				local SecondRoom = Second.Model.Parent and Second.Model.Parent.Parent

    				return (tonumber(FirstRoom and FirstRoom.Name) or math.huge) <
    					(tonumber(SecondRoom and SecondRoom.Name) or math.huge)
    			end)

    			for _, Data in ipairs(StairwellModels) do
    				if not Toggles.ab_StairwellLandingSpam.Value or CurrentToken ~= StairwellLandingToken then
    					break
    				end

    				local Model = Data.Model

    				while Model.Parent
    					and Model:IsDescendantOf(workspace)
    					and Toggles.ab_StairwellLandingSpam.Value
    					and CurrentToken == StairwellLandingToken do

    					local Character = LocalPlayer.Character
    					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

    					if HumanoidRootPart then
    						HumanoidRootPart.CFrame = Model:GetPivot() + Vector3.new(0, 5, 0)

    						for Index = 1, #Data.Prompts do
    							local Prompt = Data.Prompts[Index]

    							if Prompt.Parent and Prompt.Enabled then
    								Functions.FirePrompt(Prompt)
    							end
    						end

    						if keypress and keyrelease then
    							keypress(0x58)
    							task.wait(0.03)
    							keyrelease(0x58)
    						elseif Abysall
    							and Abysall.Environment
    							and Abysall.Environment.keypress
    							and Abysall.Environment.keyrelease then

    							Abysall.Environment.keypress(0x58)
    							task.wait(0.03)
    							Abysall.Environment.keyrelease(0x58)
    						end
    					end

    					Services.RunService.Heartbeat:Wait()
    				end
    			end

    			Services.RunService.Heartbeat:Wait()
    		end
    	end)
    end)


    Groupboxes.Stairwell_Misc:AddDivider()

    Groupboxes.Stairwell_Misc:AddButton("TP Shopping Carts To Player", function()
    	local ShoppingCartTargetName = Options.ab_ShoppingCartTarget.Value
    	local ShoppingCartTargetPlayer = game.Players:FindFirstChild(ShoppingCartTargetName)
    	if not ShoppingCartTargetPlayer or not ShoppingCartTargetPlayer.Character then return end
    	local ShoppingCartTargetCFrame = ShoppingCartTargetPlayer.Character:GetPivot()
    	for _, ShoppingCartModel in ipairs(workspace.Misc:GetChildren()) do
    		if ShoppingCartModel.Name == "ShoppingCart" and ShoppingCartModel:IsA("Model") then
    			ShoppingCartModel:PivotTo(ShoppingCartTargetCFrame)
    		end
    	end
    end)

    Groupboxes.Stairwell_Misc:AddDropdown("ab_ShoppingCartTarget", {
    	Text = "Shopping Cart Target",
    	Values = (function()
    		local ShoppingCartPlayerNames = {}
    		for _, ShoppingCartPlayer in ipairs(game.Players:GetPlayers()) do
    			ShoppingCartPlayerNames[#ShoppingCartPlayerNames + 1] = ShoppingCartPlayer.Name
    		end
    		return ShoppingCartPlayerNames
    	end)(),
    	Default = game.Players.LocalPlayer.Name,
    })

    Groupboxes.Stairwell_Misc:AddButton("Refresh Players", function()
    	local ShoppingCartPlayerNames = {}
    	for _, ShoppingCartPlayer in ipairs(game.Players:GetPlayers()) do
    		ShoppingCartPlayerNames[#ShoppingCartPlayerNames + 1] = ShoppingCartPlayer.Name
    	end
    	Options.ab_ShoppingCartTarget:SetValues(ShoppingCartPlayerNames)
    end)

    Groupboxes.Stairwell_Experimental = Tabs.Stairwell:AddRightGroupbox("Experimental")


    local function TPDropsToNearestGrinder()
        local TPDropsToNearestGrinderDropsFolder =
            workspace:FindFirstChild("Drops")

        local TPDropsToNearestGrinderRootPart =
            Character and Character:FindFirstChild("HumanoidRootPart")

        if not TPDropsToNearestGrinderDropsFolder
            or not TPDropsToNearestGrinderRootPart
            or not CurrentRooms then
            return
        end

        local TPDropsToNearestGrinderPlayerPosition =
            TPDropsToNearestGrinderRootPart.Position

        local TPDropsToNearestGrinderNearestGrinder = nil
        local TPDropsToNearestGrinderNearestDistance = math.huge

        for _, TPDropsToNearestGrinderRoom in
            ipairs(CurrentRooms:GetChildren()) do

            local TPDropsToNearestGrinderScrapper =
                TPDropsToNearestGrinderRoom:FindFirstChild(
                    "StairwellScrapper",
                    true
                )

            if TPDropsToNearestGrinderScrapper then
                for _, TPDropsToNearestGrinderObject in
                    ipairs(TPDropsToNearestGrinderScrapper:GetDescendants()) do

                    if TPDropsToNearestGrinderObject.Name == "Grinder1"
                        and (
                            TPDropsToNearestGrinderObject:IsA("Model")
                            or TPDropsToNearestGrinderObject:IsA("BasePart")
                        ) then

                        local TPDropsToNearestGrinderPosition =
                            TPDropsToNearestGrinderObject:GetPivot().Position

                        local TPDropsToNearestGrinderDistance =
                            (
                                TPDropsToNearestGrinderPlayerPosition
                                - TPDropsToNearestGrinderPosition
                            ).Magnitude

                        if TPDropsToNearestGrinderDistance
                            < TPDropsToNearestGrinderNearestDistance then

                            TPDropsToNearestGrinderNearestDistance =
                                TPDropsToNearestGrinderDistance

                            TPDropsToNearestGrinderNearestGrinder =
                                TPDropsToNearestGrinderObject
                        end
                    end
                end
            end
        end

        if not TPDropsToNearestGrinderNearestGrinder then
            return
        end

        local TPDropsToNearestGrinderCFrame =
            TPDropsToNearestGrinderNearestGrinder:GetPivot()

        for _, TPDropsToNearestGrinderDropItem in
            ipairs(TPDropsToNearestGrinderDropsFolder:GetChildren()) do

            if TPDropsToNearestGrinderDropItem:IsA("Model")
                or TPDropsToNearestGrinderDropItem:IsA("BasePart") then

                TPDropsToNearestGrinderDropItem:PivotTo(
                    TPDropsToNearestGrinderCFrame
                )
            end
        end
    end

    Groupboxes.Stairwell_Experimental:AddButton({
        Text = "TP All Drops to Nearest Grinder",
        Func = TPDropsToNearestGrinder,
        DoubleClick = false,
        Tooltip = "Teleports every dropped item to the grinder closest to you",
    })

    local function BringDroppedItems()
    	local workspaceDropsFolder = workspace:FindFirstChild("Drops")
    	if LocalPlayer and LocalPlayer.Character then
    		local playerHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    		if playerHumanoidRootPart and workspaceDropsFolder then
    			for _, itemToBring in ipairs(workspaceDropsFolder:GetChildren()) do
    				if itemToBring:IsA("Model") then
    					itemToBring:PivotTo(playerHumanoidRootPart.CFrame)
    				elseif itemToBring:IsA("BasePart") then
    					itemToBring.CFrame = playerHumanoidRootPart.CFrame
    				end
    			end
    		end
    	end
    end

    Groupboxes.Stairwell_Experimental:AddButton({
    	Text = "Bring Dropped Items",
    	Func = function() BringDroppedItems() end,
    	DoubleClick = false,
    	Tooltip = "Brings all dropped items."
    })

    Groupboxes.Stairwell_Experimental:AddToggle("ab_EnableDroppedItemsInterval", {
    	Text = "Enable Interval",
    	Default = false,
    	Tooltip = "Automatically brings dropped items at the selected interval."
    })

    Groupboxes.Stairwell_Experimental:AddSlider("ab_DroppedItemsInterval", {
    	Text = "Interval",
    	Default = 1,
    	Min = 0,
    	Max = 60,
    	Rounding = 1,
    	Compact = false,
    	Tooltip = "How often dropped items are brought."
    })

    Toggles.ab_EnableDroppedItemsInterval:OnChanged(function(enabled)
    	if enabled then
    		if droppedItemsIntervalRunning then return end
    		droppedItemsIntervalRunning = true
    		task.spawn(function()
    			while Toggles.ab_EnableDroppedItemsInterval.Value do
    				BringDroppedItems()
    				local interval = Options.ab_DroppedItemsInterval.Value
    				if interval <= 0 then
    					task.wait()
    				else
    					task.wait(interval)
    				end
    			end
    			droppedItemsIntervalRunning = false
    		end)
    	end
    end)

    Groupboxes.Stairwell_Experimental:AddDivider()

    Groupboxes.Stairwell_Experimental:AddToggle("ab_OrbitDroppedItems", {
    	Text = "Orbit Dropped Items",
    	Default = false,
    	Tooltip = "Orbits dropped items around you. Teleports them to you every 10s to prevent despawn."
    })

    Groupboxes.Stairwell_Experimental:AddSlider("ab_OrbitDroppedItemsHeight", {
    	Text = "Height",
    	Default = 2,
    	Min = -20,
    	Max = 20,
    	Rounding = 1,
    	Compact = false,
    	Tooltip = "The height of the orbit."
    })

    Groupboxes.Stairwell_Experimental:AddSlider("ab_OrbitDroppedItemsDistance", {
    	Text = "Distance",
    	Default = 5,
    	Min = 0,
    	Max = 50,
    	Rounding = 1,
    	Compact = false,
    	Tooltip = "The distance of the orbit."
    })

    Groupboxes.Stairwell_Experimental:AddSlider("ab_OrbitDroppedItemsSpeed", {
    	Text = "Speed",
    	Default = 2,
    	Min = 0,
    	Max = 20,
    	Rounding = 1,
    	Compact = false,
    	Tooltip = "The speed of the orbit."
    })

    Toggles.ab_OrbitDroppedItems:OnChanged(function(OrbitDroppedItemsEnabled)
    	if OrbitDroppedItemsConnection then
    		OrbitDroppedItemsConnection:Disconnect()
    		OrbitDroppedItemsConnection = nil
    	end
    	if not OrbitDroppedItemsEnabled then return end
    	OrbitDroppedItemsAngle = 0
    	OrbitDroppedItemsLastTeleport = tick()
    	OrbitDroppedItemsPauseUntil = 0
    	OrbitDroppedItemsConnection = RunService.Heartbeat:Connect(function(OrbitDroppedItemsDeltaTime)
    		if not LocalPlayer or not LocalPlayer.Character then return end
    		local OrbitDroppedItemsHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    		local OrbitDroppedItemsDropsFolder = workspace:FindFirstChild("Drops")
    		if not OrbitDroppedItemsHumanoidRootPart or not OrbitDroppedItemsDropsFolder then return end
    		local OrbitDroppedItemsHeightValue = Options.ab_OrbitDroppedItemsHeight.Value
    		local OrbitDroppedItemsDistanceValue = Options.ab_OrbitDroppedItemsDistance.Value
    		local OrbitDroppedItemsSpeedValue = Options.ab_OrbitDroppedItemsSpeed.Value
    		local OrbitDroppedItemsCurrentTime = tick()
    		local OrbitDroppedItemsList = {}
    		for _, OrbitDroppedItemsObject in ipairs(OrbitDroppedItemsDropsFolder:GetChildren()) do
    			if OrbitDroppedItemsObject:IsA("Model") or OrbitDroppedItemsObject:IsA("BasePart") then
    				OrbitDroppedItemsList[#OrbitDroppedItemsList + 1] = OrbitDroppedItemsObject
    			end
    		end
    		local OrbitDroppedItemsCount = #OrbitDroppedItemsList
    		if OrbitDroppedItemsCount == 0 then return end
    		if OrbitDroppedItemsCurrentTime - OrbitDroppedItemsLastTeleport >= 10 then
    			OrbitDroppedItemsLastTeleport = OrbitDroppedItemsCurrentTime
    			OrbitDroppedItemsPauseUntil = OrbitDroppedItemsCurrentTime + 2
    			local OrbitDroppedItemsCenterPosition = OrbitDroppedItemsHumanoidRootPart.Position
    			for _, OrbitDroppedItemsObject in ipairs(OrbitDroppedItemsList) do
    				if OrbitDroppedItemsObject:IsA("Model") then
    					OrbitDroppedItemsObject:PivotTo(CFrame.new(OrbitDroppedItemsCenterPosition))
    				else
    					OrbitDroppedItemsObject.CFrame = CFrame.new(OrbitDroppedItemsCenterPosition)
    				end
    			end
    		end
    		if OrbitDroppedItemsCurrentTime < OrbitDroppedItemsPauseUntil then return end
    		OrbitDroppedItemsAngle += OrbitDroppedItemsDeltaTime * OrbitDroppedItemsSpeedValue
    		for OrbitDroppedItemsIndex, OrbitDroppedItemsObject in ipairs(OrbitDroppedItemsList) do
    			local OrbitDroppedItemsObjectAngle = OrbitDroppedItemsAngle + ((OrbitDroppedItemsIndex - 1) / OrbitDroppedItemsCount) * math.pi * 2
    			local OrbitDroppedItemsOffset = Vector3.new(
    				math.cos(OrbitDroppedItemsObjectAngle) * OrbitDroppedItemsDistanceValue,
    				OrbitDroppedItemsHeightValue,
    				math.sin(OrbitDroppedItemsObjectAngle) * OrbitDroppedItemsDistanceValue
    			)
    			local OrbitDroppedItemsPosition = OrbitDroppedItemsHumanoidRootPart.Position + OrbitDroppedItemsOffset
    			if OrbitDroppedItemsObject:IsA("Model") then
    				OrbitDroppedItemsObject:PivotTo(CFrame.new(OrbitDroppedItemsPosition))
    			else
    				OrbitDroppedItemsObject.CFrame = CFrame.new(OrbitDroppedItemsPosition)
    			end
    		end
    	end)
    end)


    Toggles.ab_BypassNoise:OnChanged(function(value)
    	for i = #Connections, 1, -1 do
    		local existingConnection = Connections[i]
    		if existingConnection and existingConnection.Disconnect then
    			existingConnection:Disconnect()
    		end
    		table.remove(Connections, i)
    	end

    	if not value then return end

    	local function checkBypassNoiseTvStand(targetTvStand)
    		if not targetTvStand:IsA("Model") then return end
    		if targetTvStand.Name ~= "TV_Stand" then return end

    		local tvStandCurrentCFrame = targetTvStand:GetPivot()

    		if tvStandCurrentCFrame.Position.Y > -119 then
    			targetTvStand:PivotTo(CFrame.new(
    				tvStandCurrentCFrame.Position.X,
    				-120,
    				tvStandCurrentCFrame.Position.Z
    			))
    		end
    	end

    	local bypassNoiseMiscFolder = workspace:FindFirstChild("Misc")
    	if not bypassNoiseMiscFolder then return end

    	local bypassNoiseMiscChildAddedConnection = bypassNoiseMiscFolder.ChildAdded:Connect(function(bypassNoiseNewChild)
    		checkBypassNoiseTvStand(bypassNoiseNewChild)
    	end)

    	Connections[#Connections + 1] = bypassNoiseMiscChildAddedConnection

    	for _, bypassNoiseMiscChild in ipairs(bypassNoiseMiscFolder:GetChildren()) do
    		checkBypassNoiseTvStand(bypassNoiseMiscChild)
    	end
    end)

    Toggles.ab_DroppedItemValue:OnChanged(function(DroppedItemValue)
    	local DroppedItemValueScreenGui = game:GetService("CoreGui"):FindFirstChild("DropsCoinCounter")
    	if not DroppedItemValue then
    		if DroppedItemValueScreenGui then DroppedItemValueScreenGui:Destroy() end
    		return
    	end
    	local DroppedItemValueWorkspaceDrops = workspace:WaitForChild("Drops")
    	if DroppedItemValueScreenGui then DroppedItemValueScreenGui:Destroy() end
    	DroppedItemValueScreenGui = Instance.new("ScreenGui")
    	DroppedItemValueScreenGui.Name = "DropsCoinCounter"
    	DroppedItemValueScreenGui.ResetOnSpawn = false
    	DroppedItemValueScreenGui.Parent = game:GetService("CoreGui")
    	local DroppedItemValueCoinText = Instance.new("TextLabel")
    	DroppedItemValueCoinText.Name = "CoinText"
    	DroppedItemValueCoinText.AnchorPoint = Vector2.new(0.5, 0)
    	DroppedItemValueCoinText.Position = UDim2.new(0.5, 0, 0.02, 0)
    	DroppedItemValueCoinText.Size = UDim2.new(0, 250, 0, 40)
    	DroppedItemValueCoinText.BackgroundTransparency = 1
    	DroppedItemValueCoinText.Text = "Items: 0"
    	DroppedItemValueCoinText.TextSize = 24
    	DroppedItemValueCoinText.Font = Enum.Font.GothamBold
    	DroppedItemValueCoinText.TextColor3 = Color3.fromRGB(255, 255, 255)
    	DroppedItemValueCoinText.TextStrokeTransparency = 0.5
    	DroppedItemValueCoinText.Parent = DroppedItemValueScreenGui
    	local DroppedItemValueCountedDrops = {}
    	task.spawn(function()
    		while Toggles.ab_DroppedItemValue.Value do
    			for _, DroppedItemValueDrop in ipairs(DroppedItemValueWorkspaceDrops:GetChildren()) do
    				if DroppedItemValueDrop:IsA("Model") and not DroppedItemValueCountedDrops[DroppedItemValueDrop] then
    					DroppedItemValueDrop:SetAttribute("CoinsChecked", true)
    					DroppedItemValueCountedDrops[DroppedItemValueDrop] = true
    				end
    			end
    			for DroppedItemValueDrop in pairs(DroppedItemValueCountedDrops) do
    				if not DroppedItemValueDrop.Parent or DroppedItemValueDrop.Parent ~= DroppedItemValueWorkspaceDrops then
    					DroppedItemValueCountedDrops[DroppedItemValueDrop] = nil
    				end
    			end
    			local DroppedItemValueTotalItems = 0
    			for DroppedItemValueDrop in pairs(DroppedItemValueCountedDrops) do
    				if DroppedItemValueDrop.Parent == DroppedItemValueWorkspaceDrops then
    					DroppedItemValueTotalItems += 1
    				end
    			end
    			DroppedItemValueCoinText.Text = "Items: " .. DroppedItemValueTotalItems
    			task.wait(1)
    		end
    		if DroppedItemValueScreenGui and DroppedItemValueScreenGui.Parent then
    			DroppedItemValueScreenGui:Destroy()
    		end
    	end)
    end)

    -- hi

    Groupboxes.Exploits_BypassRight = Tabs.Exploits:AddRightGroupbox("Bypass")
    Groupboxes.Exploits_BypassRight:AddToggle("ab_DisableAnticheat", {
    	Text = "Anticheat Bypass", Default = false,
    	Tooltip = "Completely disables the anticheat, after interacting with a ladder."
    })
    Groupboxes.Exploits_BypassRight:AddToggle("ab_VelocityManipulationToggle", {
    	Text = "Velocity Manipulation", Default = false,
    	Tooltip = "Moves your character forward slowly, mitigating the game's anti-noclip."
    })
    Toggles.ab_DisableAnticheat:OnChanged(function(Value)
    	if Globals.AnticheatDisabled == true and not Value then
    		RemotesFolder.ClimbLadder:FireServer()
    		Globals.AnticheatDisabled = false
    	end
    end)
    Toggles.ab_VelocityManipulationToggle:AddKeyPicker("VelocityManipulationKeybind", {
    	Text = "Velocity Manipulation", Default = "V",
    	Mode = Library.IsMobile and "Toggle" or "Hold", SyncToggleState = true
    })
    Groupboxes.Exploits_BypassRight:AddDropdown("ab_VelocityManipulationMode", {
    	Values = {"Velocity", "Pivot"}, Text = "Manipulation Method",
    	Default = 1,
    })

    Groupboxes.Exploits_BypassRight:AddDivider()
    Groupboxes.Exploits_BypassRight:AddToggle("ab_InfiniteItemsToggle", {
    	Text = "Infinite Items", Default = false,
    	Tooltip = "Allows certain items to be used without draining their uses.",
    	Disabled = not Functions.CheckCompatability({"fireproximityprompt"}),
    	DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Exploits_BypassRight:AddDropdown("ab_InfiniteItemsList", {
    	Text = "Item List",
    	Values = { "Lockpicks", "Skeleton Key", "Shears", "Multitool" },
    	Multi = true, AllowNull = true,
    	Disabled = not Functions.CheckCompatability({"fireproximityprompt"}),
    	DisabledTooltip = Globals.IncompatibleMessage
    })

    Groupboxes.Exploits_BypassRight:AddToggle("ab_InfCrucifix", {
    	Text = "Infinite Crucifix",
    	Default = false,
    	Tooltip = "Risky! You can die or lose the Crucifix. Recommended to have low ping and stable fps.",
    	Risky = Floor ~= "Ballz",
    })


    local InfCrucifixDropTable = {
    	RushMoving   = 54,
    	AmbushMoving = 67,
    	A60          = 70,
    	GlitchRush   = 120,
    	GlitchAmbush = 155,
    	A120         = 75,

    }



    Toggles.ab_InfCrucifix:OnChanged(function(Value)
    	print("i allive")
    	local InfCrucifixRaycastParams = RaycastParams.new()
    	InfCrucifixRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    	local InfCrucifixConnection
    	InfCrucifixConnection = RunService.RenderStepped:Connect(function()
    		if not Toggles.ab_InfCrucifix.Value then
    			if InfCrucifixConnection then
    				InfCrucifixConnection:Disconnect()
    			end
    			return
    		end

    		local InfCrucifixCharacter = game.Players.LocalPlayer
    		if not InfCrucifixCharacter then
    			return
    		end

    		local InfCrucifixCollision = InfCrucifixCharacter:FindFirstChild("CollisionPart")
    		if not InfCrucifixCollision then
    			return
    		end

    		InfCrucifixRaycastParams.FilterDescendantsInstances = {InfCrucifixCharacter}

    		for _, InfCrucifixEntity in ipairs(Workspace:GetChildren()) do
    			local InfCrucifixMaxDistance = InfCrucifixDropTable[InfCrucifixEntity.Name]
    			if not InfCrucifixMaxDistance or not InfCrucifixEntity.PrimaryPart then
    				continue
    			end

    			InfCrucifixEntity.PrimaryPart.CanCollide = true
    			InfCrucifixEntity.PrimaryPart.CanQuery = true

    			local InfCrucifixOrigin = InfCrucifixCollision.Position
    			local InfCrucifixDirection = InfCrucifixEntity.PrimaryPart.Position - InfCrucifixOrigin
    			local InfCrucifixRayResult = Workspace:Raycast(InfCrucifixOrigin, InfCrucifixDirection, InfCrucifixRaycastParams)

    			if not InfCrucifixRayResult or not InfCrucifixRayResult.Instance:IsDescendantOf(InfCrucifixEntity) then
    				continue
    			end

    			local InfCrucifixDistance = (InfCrucifixCollision.Position - InfCrucifixEntity.PrimaryPart.Position).Magnitude
    			if InfCrucifixDistance >= InfCrucifixMaxDistance then
    				continue
    			end

    			local InfCrucifixTool = InfCrucifixCharacter:FindFirstChildOfClass("Tool")
    			if not InfCrucifixTool or InfCrucifixTool.Name ~= "Crucifix" then
    				continue
    			end

    			task.spawn(function()
    				ReplicatedStorage.RemotesFolder.DropItem:FireServer(InfCrucifixTool)
    				task.wait(0.54)
    				print("hi")
    				local InfCrucifixDrops = Workspace:FindFirstChild("Drops")
    				if not InfCrucifixDrops then
    					return
    				end

    				local InfCrucifixDropped = InfCrucifixDrops:FindFirstChild("Crucifix")
    				if not InfCrucifixDropped then
    					return
    				end

    				local InfCrucifixPrompt = InfCrucifixDropped:FindFirstChildOfClass("ProximityPrompt")
    				if InfCrucifixPrompt then
    					Functions.FirePrompt(InfCrucifixPrompt)
    				end
    			end)
    			print ("hi")
    			task.wait(0.6)
    		end
    	end)
    end)


    Groupboxes.Exploits_BypassRight:AddDivider()
    Groupboxes.Exploits_BypassRight:AddToggle("ab_PositionSpoof", {
    	Text = "Position Spoof", Default = false,
    	Tooltip = "Makes your character appear underground on the server, protecting you from rush-like entities."
    })
    Groupboxes.Exploits_BypassRight:AddToggle("ab_CrouchSpoof", {
    	Text = "Crouch Spoof", Default = false, Tooltip = "Makes the game think you are always crouching."
    })
    Toggles.ab_PositionSpoof:OnChanged(function(Value)
    	if Floor ~= "Fools" and Floor ~= "OldHotel" then
    		if Value then
    			RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
    			Humanoid.HipHeight = 0.05
    			RemotesFolder.Crouch:FireServer(true, true)
    		else
    			RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0)
    			Humanoid.HipHeight = 2.396
    		end
    	end
    end)
    Toggles.ab_PositionSpoof:AddKeyPicker("PositionSpoof", {
    	Text = "Position Spoof", Default = "B", Mode = "Toggle", SyncToggleState = true
    })
    Toggles.ab_CrouchSpoof:OnChanged(function(Value)
    	if RemotesFolder:FindFirstChild("Crouch") then
    		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
    	end
    end)

    Groupboxes.Exploits_Remove = Tabs.Exploits:AddRightGroupbox("Remove")
    Groupboxes.Exploits_Remove:AddToggle("ab_RemoveScreech", { Text = "Remove Screech",  Default = false, Tooltip = "Prevents 'Screech' from spawning." })
    Groupboxes.Exploits_Remove:AddToggle("ab_RemoveHalt",    { Text = "Remove Halt",     Default = false, Tooltip = "Prevents 'Halt' from spawning." })
    Groupboxes.Exploits_Remove:AddToggle("ab_RemoveA90",     { Text = "Remove A-90",     Default = false, Tooltip = "Prevents 'A-90' from spawning." })
    Groupboxes.Exploits_Remove:AddToggle("ab_RemoveDread",   { Text = "Remove Dread",    Default = false, Tooltip = "Prevents 'Dread' from spawning." })
    Groupboxes.Exploits_Remove:AddToggle("ab_RemoveSurge", { Text = "Remove Surge", Default = false, Tooltip = "Prevents 'Surge' from spawning."})
    Groupboxes.Exploits_Remove:AddDivider()
    Groupboxes.Exploits_Remove:AddToggle("ab_NoScreechDamage", { Text = "No Screech Damage", Default = false, Tooltip = "Prevents 'Screech' from hurting you." })
    Groupboxes.Exploits_Remove:AddToggle("ab_NoHaltDamage",    { Text = "No Halt Damage",    Default = false, Tooltip = "Prevents 'Halt' from hurting you." })
    Groupboxes.Exploits_Remove:AddToggle("ab_NoA90Damage",     { Text = "No A-90 Damage",    Default = false, Tooltip = "Prevents 'A-90' from hurting you." })
    Groupboxes.Exploits_Remove:AddToggle("ab_NoSurgeDamage",   { Text = "No Surge Damage",   Default = false, Tooltip = "Prevents 'Surge' from hurting you." })

    Toggles.ab_NoScreechDamage:OnChanged(function(Value)
    	if Value then
    		FakeEvents.Screech.Parent = RemotesFolder
    		FakeEvents.Screech_Real.Parent = nil
    	else
    		FakeEvents.Screech_Real.Parent = RemotesFolder
    		FakeEvents.Screech.Parent = nil
    	end
    end)
    Toggles.ab_NoHaltDamage:OnChanged(function(Value)
    	if Value then
    		FakeEvents.Shade.Parent = RemotesFolder
    		FakeEvents.Shade_Real.Parent = nil
    	else
    		FakeEvents.Shade_Real.Parent = RemotesFolder
    		FakeEvents.Shade.Parent = nil
    	end
    end)
    Toggles.ab_NoA90Damage:OnChanged(function(Value)
    	if RemotesFolder:FindFirstChild("A90") then
    		if Value then
    			FakeEvents.A90.Parent = RemotesFolder
    			FakeEvents.A90_Real.Parent = nil
    		else
    			FakeEvents.A90_Real.Parent = RemotesFolder
    			FakeEvents.A90.Parent = nil
    		end
    	end
    end)
    Toggles.ab_NoSurgeDamage:OnChanged(function(Value)
    	if RemotesFolder:FindFirstChild("SurgeRemote") then
    		if Value then
    			FakeEvents.Surge.Parent = RemotesFolder
    			FakeEvents.Surge_Real.Parent = nil
    		else
    			FakeEvents.Surge_Real.Parent = RemotesFolder
    			FakeEvents.Surge.Parent = nil
    		end
    	end
    end)

    local Modules = {}

    Toggles.ab_RemoveScreech:OnChanged(function(Value)
    	if Value then
    		task.spawn(function()
    			while Toggles.ab_RemoveScreech.Value do
    				local Camera = workspace:FindFirstChild("Camera")

    				if Camera then
    					local Screech = Camera:FindFirstChild("Screech")

    					if Screech then
    						Screech:Destroy()
    					end
    				end

    				task.wait()
    			end
    		end)
    	end
    end)
    Toggles.ab_RemoveHalt:OnChanged(function(Value)
    	Modules.Shade.Name = Value and "Shade_Disabled" or "Shade"
    end)
    Toggles.ab_RemoveA90:OnChanged(function(Value)
    	if Modules.A90 then
    		Modules.A90.Name = Value and "A90_Disabled" or "A90"
    	end
    end)
    Toggles.ab_RemoveDread:OnChanged(function(Value)
    	if Modules.Dread then
    		Modules.Dread.Name = Value and "Dread_Disabled" or "Dread"
    	end
    end)
    Toggles.ab_RemoveSurge:OnChanged(function(Value)
    	if Globals.SurgeFrame then
    		Globals.SurgeFrame.Name = (Value and "SurgeVignette_Disabled" or "SurgeVignette")
    	end
    end)

    Groupboxes.Exploits_Audio = Tabs.Exploits:AddLeftGroupbox("Audio")
    Globals.JamMuffle = Services.SoundService:WaitForChild("Main"):FindFirstChild("Jamming") or Instance.new("EqualizerSoundEffect")

    Groupboxes.Exploits_Audio:AddToggle("ab_RemoveFootstepSounds",    { Text = "Remove Footstep Sounds",    Default = false, Tooltip = "Removes the sounds when walking." })
    Groupboxes.Exploits_Audio:AddToggle("ab_RemoveJamminMusic",       { Text = "Remove Jammin Music",       Default = false, Tooltip = "Removes the music and muffle effect from the 'Jammin' modifier." })
    Groupboxes.Exploits_Audio:AddToggle("ab_RemoveInteractingSounds", { Text = "Remove Interacting Sounds", Default = false, Tooltip = "Removes the sounds when interacting with proximity prompts." })

    Toggles.ab_RemoveJamminMusic:OnChanged(function(Value)
    	local Jam = Safe(function() return Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam") end)
    	if Jam then
    		Jam.Volume = Value and 0 or 0.45
    		Globals.JamMuffle.Enabled = LiveModifiers:FindFirstChild("Jammin") and not Value or false
    	end
    end)
    Toggles.ab_RemoveInteractingSounds:OnChanged(function(Value)
    	local PS = Safe(function() return Globals.MainUI.Initiator.Main_Game.PromptService end)
    	if PS then
    		PS.Triggered.Volume    = Value and 0 or 0.04
    		PS.Holding.Volume      = Value and 0 or 0.1
    		PS.Notification.Volume = Value and 0 or 0.03
    	end
    	Safe(function() Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = Value and 0 or 0.1 end)
    end)

    Groupboxes.Visuals_LeftTab = Tabs.Visuals:AddLeftTabbox("Camera / Effects")
    Groupboxes.Visuals_Camera = Groupboxes.Visuals_LeftTab:AddTab("Camera")
    Groupboxes.Visuals_Camera:AddToggle("ab_AmbientToggle", { Text = "Ambient", Default = false, Tooltip = "Changes the lighting color to the specified value." })
    Groupboxes.Visuals_Camera:AddSlider("ab_FieldOfView", { Text = "Field of View", Min = 1, Max = 120, Default = 70, Rounding = 0 })
    Groupboxes.Visuals_Camera:AddToggle("ab_FOVToggle", {    Text = "Custom FOV",    Default = false,    Tooltip = "Only applies the Field of View slider when enabled." })
    Toggles.ab_FOVToggle:AddKeyPicker("FovToggle", {Text = "Custom Fov", Default = "O", Mode = "Toggle", SyncToggleState = true})
    Groupboxes.Visuals_Camera:AddDivider()
    Groupboxes.Visuals_Camera:AddToggle("ab_RemoveCameraShake", {
    	Text = "Remove Camera Shake", Default = false, Tooltip = "Prevents the camera from shaking.",
    	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Visuals_Camera:AddToggle("ab_RemoveCameraBobbing", {
    	Text = "Remove Camera Bobbing", Default = false, Tooltip = "Prevents the camera from bobbing when moving.",
    	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Visuals_Camera:AddToggle("ab_RemoveCutscenes", { Text = "Remove Cutscenes", Default = false, Tooltip = "Removes all non-necessary cutscenes." })
    Groupboxes.Visuals_Camera:AddToggle("ab_RemoveCameraFog", { Text = "Remove Fog", Default = false, Tooltip = "Removes all fog effects from the camera." })
    Groupboxes.Visuals_Camera:AddDivider()
    Groupboxes.Visuals_Camera:AddToggle("ab_ThirdPersonToggle", { Text = "Third Person", Default = false, Tooltip = "Zooms out your camera, allowing you to see your character from behind." })
    Toggles.ab_ThirdPersonToggle:AddKeyPicker("ThirdPersonKeybind", { Text = "Third Person", Default = "T", Mode = "Toggle", SyncToggleState = true })
    Groupboxes.Visuals_Camera:AddSlider("ab_ThirdPersonOffsetX", { Text = "X Offset", Min = -10, Max = 10, Default = 1.5, Rounding = 1, Compact = true })
    Groupboxes.Visuals_Camera:AddSlider("ab_ThirdPersonOffsetY", { Text = "Y Offset", Min = -10, Max = 10, Default = 1,   Rounding = 1, Compact = true })
    Groupboxes.Visuals_Camera:AddSlider("ab_ThirdPersonOffsetZ", { Text = "Z Offset", Min = -10, Max = 10, Default = 5,   Rounding = 1, Compact = true })
    Groupboxes.Visuals_Camera:AddToggle("ab_ThirdPersonWallCheck", { Text = "Wall Check", Default = false, Tooltip = "Prevents third person from going through walls." })
    Groupboxes.Visuals_Camera:AddDivider()
    Groupboxes.Visuals_Camera:AddToggle("ab_ViewmodelOffsetToggle", {
    	Text = "Viewmodel Offset", Default = false, Tooltip = "Changes the offset of your viewmodel while holding an item.",
    	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Visuals_Camera:AddSlider("ab_ViewmodelOffsetX", { Text = "X Offset", Min = -10, Max = 10, Default = 0, Rounding = 1, Compact = true, Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage })
    Groupboxes.Visuals_Camera:AddSlider("ab_ViewmodelOffsetY", { Text = "Y Offset", Min = -10, Max = 10, Default = 0, Rounding = 1, Compact = true, Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage })
    Groupboxes.Visuals_Camera:AddSlider("ab_ViewmodelOffsetZ", { Text = "Z Offset", Min = -10, Max = 10, Default = 0, Rounding = 1, Compact = true, Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage })

    Toggles.ab_AmbientToggle:AddColorPicker("ab_AmbientColor", { Text = "Ambient", Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
    Toggles.ab_AmbientToggle:OnChanged(function(Value)
    	local OldAmbient = CurrentRooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom"))):GetAttribute("Ambient")
    	Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
    		Ambient = Value and Options.ab_AmbientColor.Value or OldAmbient
    	}):Play()
    end)

    local Main_Game
    local ClientModules

    Toggles.ab_RemoveCameraBobbing:OnChanged(function(Value)
    	if Main_Game then Main_Game.spring.Speed = Value and 9e9 or 8 end
    end)
    Toggles.ab_RemoveCameraFog:OnChanged(function(Value)
    	Services.Lighting.FogEnd = Value and 10000000 or Globals.OldFog
    	for _, Object in Globals.FogInstances do
    		Object.Density = Value and 0 or Object:GetAttribute("Density_Old")
    	end
    end)
    Toggles.ab_RemoveCutscenes:OnChanged(function(Value)
        local Cutscenes = Safe(function() return Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes end)
        for _, Object in pairs(Cutscenes and Cutscenes:GetChildren() or {}) do
            if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
                Object.Name = (Value and Object.Name .. "_Disabled" or Object:GetAttribute("OriginalName"))
            end
        end
        for _, Object in pairs(FloorReplicated:GetChildren()) do
            if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
                Object.Name = (Value and Object.Name .. "_Disabled" or Object:GetAttribute("OriginalName"))
            end
        end
    end)

    Groupboxes.Visuals_Effects = Groupboxes.Visuals_LeftTab:AddTab("Effects")
    Groupboxes.Visuals_Effects:AddToggle("ab_TransparentHidingSpotsToggle", { Text = "Transparent Hiding Spots", Default = false, Tooltip = "Makes a hiding spot transparent when you enter it." })
    Groupboxes.Visuals_Effects:AddSlider("ab_TransparentHidingSpotsSlider", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Compact = true })

    local function ApplyHidingTransparency(Value, SliderValue)
    	for _, Object in Objects.HidingSpots do
    		local IsHiding = false
    		for _, Child in Object:GetDescendants() do
    			if Child.Name == "HiddenPlayer" and Child.Value == Character then
    				IsHiding = true
    				break
    			end
    		end
    		for _, Part in Object:GetDescendants() do
    			if Part:IsA("BasePart") and Part:GetAttribute("Transparency_Old") then
    				Services.TweenService:Create(Part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
    					Transparency = (Value and IsHiding) and SliderValue or Part:GetAttribute("Transparency_Old")
    				}):Play()
    			end
    		end
    	end
    end

    Toggles.ab_TransparentHidingSpotsToggle:OnChanged(function(Value)
    	ApplyHidingTransparency(Value, Options.ab_TransparentHidingSpotsSlider.Value)
    end)
    Options.ab_TransparentHidingSpotsSlider:OnChanged(function(Value)
    	ApplyHidingTransparency(Toggles.ab_TransparentHidingSpotsToggle.Value, Value)
    end)

    Groupboxes.Visuals_Effects:AddDivider()
    Groupboxes.Visuals_Effects:AddToggle("ab_DisableGlitchJumpscare",   { Text = "Disable Glitch Jumpscare",   Default = false, Tooltip = "Disables the jumpscare from 'Glitch'" })
    Groupboxes.Visuals_Effects:AddToggle("ab_DisableTimothyJumpscare",  { Text = "Disable Timothy Jumpscare",  Default = false, Tooltip = "Disables the jumpscare from 'Timothy'" })
    Groupboxes.Visuals_Effects:AddToggle("ab_DisableVoidJumpscare",     { Text = "Disable Void Jumpscare",     Default = false, Tooltip = "Disables the jumpscare from 'Void'" })
    Groupboxes.Visuals_Effects:AddDivider()
    Groupboxes.Visuals_Effects:AddToggle("ab_DisableHideVignette",      { Text = "Disable Hide Vignette",      Default = false, Tooltip = "Disables the hiding screen effect." })
    Groupboxes.Visuals_Effects:AddToggle("ab_DisableFiredampEffect",    { Text = "Disable Firedamp Effect",    Default = false, Tooltip = "Disables the firedamp screen effect." })
    Groupboxes.Visuals_Effects:AddToggle("ab_DisableEntityJumpscares",  { Text = "Disable Entity Jumpscares",  Default = false, Tooltip = "Disables jumpscares from entities like Rush and Ambush." })

    Toggles.ab_DisableGlitchJumpscare:OnChanged(function(Value)
    	Modules.Glitch.Name = Value and "Glitch_Disabled" or "Glitch"
    end)
    Toggles.ab_DisableTimothyJumpscare:OnChanged(function(Value)
    	if Modules.SpiderJumpscare then Modules.SpiderJumpscare.Name = Value and "SpiderJumpscare_Disabled" or "SpiderJumpscare" end
    end)
    Toggles.ab_DisableVoidJumpscare:OnChanged(function(Value)
    	if Modules.Void then Modules.Void.Name = Value and "Void_Disabled" or "Void" end
    end)
    Toggles.ab_DisableHideVignette:OnChanged(function(Value)
    	local Vignette = Safe(function() return Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette") end)
    	if Vignette then Vignette.Image = Value and "Disabled" or "rbxassetid://6100076320" end
    end)
    Toggles.ab_DisableFiredampEffect:OnChanged(function(Value)
    	for _, Object in CurrentRooms:GetChildren() do
    		if Value then
    			Object:SetAttribute("Firedamp", false)
    			for _, FiredampObj in Camera:GetChildren() do
    				if FiredampObj.Name == "LiveFiredamp" then FiredampObj:Destroy() end
    			end
    		else
    			Object:SetAttribute("Firedamp", Object:GetAttribute("Firedamp_Old"))
    		end
    	end
    	local Old = LocalPlayer:GetAttribute("CurrentRoom")
    	LocalPlayer:SetAttribute("CurrentRoom", 0)
    	task.wait()
    	LocalPlayer:SetAttribute("CurrentRoom", Old)
    end)
    Toggles.ab_DisableEntityJumpscares:OnChanged(function(Value)
    	local Jumpscares = Safe(function()
    		local Listener = Globals.MainUI.Initiator.Main_Game.RemoteListener
    		return Listener:FindFirstChild("Jumpscares") or Listener:FindFirstChild("Jumpscares_Disabled")
    	end)
    	if Jumpscares then
    		Jumpscares.Name = Value and "Jumpscares_Disabled" or "Jumpscares"
    		for _, Object in Objects.JumpscareModules do
    			Object.Name = Value and (Object:GetAttribute("OriginalName") .. "_Disabled") or Object:GetAttribute("OriginalName")
    		end
    	end
    end)

    Groupboxes.Visuals_RightTab     = Tabs.Visuals:AddRightTabbox("Entities / Settings / Entity Nodes")
    Groupboxes.Visuals_Entities     = Groupboxes.Visuals_RightTab:AddTab("Entities")
    Groupboxes.Visuals_EntitySettings = Groupboxes.Visuals_RightTab:AddTab("Settings")

    Groupboxes.Visuals_Entities:AddDropdown("ab_EntityList", {
    	Text = "Entity List",
    	Values = { "Rush","Bash","Scribbles","Teller","DronesStampede","Creak","Noise","Noise_TV","Balls","Portrait","Ambush","Eyes","Halt","Blitz","Lookman","Gloombat Swarm","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Monument","AR0xMBUSH","RNIUSHCG==" },
    	Multi = true, AllowNull = true
    })
    Groupboxes.Visuals_Entities:AddToggle("ab_NotifyEntities",    { Text = "Notify Entities",    Default = false, Tooltip = "Sends a notification when an entity spawns." })
    Groupboxes.Visuals_Entities:AddDivider()
    Groupboxes.Visuals_Entities:AddToggle("ab_ShowEntityPath", {
        Text = "Show Entity Path",
        Default = false,
        Tooltip = "Shows the path of entitys."
    })


    -- i dont wanna hear it okay? i was sick okay let me be okay fuck u okay




    Groupboxes.Visuals_Entities:AddToggle("ab_ShowEntityPath", {
        Text = "Show Entity Path",
        Default = false,
        Tooltip = "Shows the path of entitys."
    })

    Groupboxes.Visuals_Entities:AddSlider("ab_ShowEntityPathNodeTransparency", {
        Text = "Node Transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Compact = false,
        Tooltip = "Transparency of the path nodes when shown"
    })

    Groupboxes.Visuals_Entities:AddSlider("ab_ShowEntityPathLineTransparency", {
        Text = "Line Transparency",
        Default = 0.15,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Compact = false,
        Tooltip = "Transparency of the path lines"
    })

    Groupboxes.Visuals_Entities:AddSlider("ab_ShowEntityPathLineThickness", {
        Text = "Line Thickness",
        Default = 0.3,
        Min = 0.08,
        Max = 1.2,
        Rounding = 2
    })

    local ShowEntityPathLines = {}

    local function ShowEntityPathClearAllLines()
        for _, ShowEntityPathRoomLines in pairs(ShowEntityPathLines) do
            for _, ShowEntityPathLine in ipairs(ShowEntityPathRoomLines) do
                if ShowEntityPathLine and ShowEntityPathLine.Parent then
                    ShowEntityPathLine:Destroy()
                end
            end
        end
        table.clear(ShowEntityPathLines)
    end

    local function ShowEntityPathCreateLine(ShowEntityPathPoint1, ShowEntityPathPoint2, ShowEntityPathTransparency, ShowEntityPathThickness, ShowEntityPathParent)
        local ShowEntityPathDistance = (ShowEntityPathPoint1 - ShowEntityPathPoint2).Magnitude
        if ShowEntityPathDistance < 0.05 then
            return nil
        end

        local ShowEntityPathLinePart = Instance.new("Part")
        ShowEntityPathLinePart.Name = "PathLine"
        ShowEntityPathLinePart.Anchored = true
        ShowEntityPathLinePart.CanCollide = false
        ShowEntityPathLinePart.CanQuery = false
        ShowEntityPathLinePart.CanTouch = false
        ShowEntityPathLinePart.CastShadow = false
        ShowEntityPathLinePart.Material = Enum.Material.ForceField
        ShowEntityPathLinePart.Color = Color3.fromRGB(0, 255, 210)
        ShowEntityPathLinePart.Transparency = ShowEntityPathTransparency
        ShowEntityPathLinePart.Size = Vector3.new(ShowEntityPathThickness, ShowEntityPathThickness, ShowEntityPathDistance)
        ShowEntityPathLinePart.CFrame = CFrame.lookAt(ShowEntityPathPoint1, ShowEntityPathPoint2) * CFrame.new(0, 0, -ShowEntityPathDistance / 2)
        ShowEntityPathLinePart.Parent = ShowEntityPathParent
        return ShowEntityPathLinePart
    end

    local function ShowEntityPathGetSortedNodes(ShowEntityPathNodes)
        local ShowEntityPathSortedNodes = {}
        for _, ShowEntityPathNode in ipairs(ShowEntityPathNodes:GetChildren()) do
            if ShowEntityPathNode:IsA("BasePart") then
                local ShowEntityPathNodeNumber = tonumber(ShowEntityPathNode.Name)
                if ShowEntityPathNodeNumber then
                    table.insert(ShowEntityPathSortedNodes, {
                        Part = ShowEntityPathNode,
                        Number = ShowEntityPathNodeNumber
                    })
                end
            end
        end
        table.sort(ShowEntityPathSortedNodes, function(a, b)
            return a.Number < b.Number
        end)
        return ShowEntityPathSortedNodes
    end

    local function ShowEntityPathSetNodeTransparency(ShowEntityPathTransparency)
        for _, ShowEntityPathRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
            local ShowEntityPathNodes = ShowEntityPathRoom:FindFirstChild("PathfindNodes")
            if ShowEntityPathNodes then
                for _, ShowEntityPathNode in ipairs(ShowEntityPathNodes:GetChildren()) do
                    if ShowEntityPathNode:IsA("BasePart") then
                        ShowEntityPathNode.Transparency = ShowEntityPathTransparency
                    end
                end
            end
        end
    end

    local function ShowEntityPathSetLineTransparency(ShowEntityPathTransparency)
        for _, ShowEntityPathRoomLines in pairs(ShowEntityPathLines) do
            for _, ShowEntityPathLine in ipairs(ShowEntityPathRoomLines) do
                if ShowEntityPathLine and ShowEntityPathLine.Parent then
                    ShowEntityPathLine.Transparency = ShowEntityPathTransparency
                end
            end
        end
    end

    local function ShowEntityPathUpdateAll()
        local ShowEntityPathShow = Toggles.ab_ShowEntityPath.Value
        local ShowEntityPathNodeTransparency = ShowEntityPathShow and Options.ab_ShowEntityPathNodeTransparency.Value or 1
        local ShowEntityPathLineTransparency = Options.ab_ShowEntityPathLineTransparency.Value
        local ShowEntityPathLineThickness = Options.ab_ShowEntityPathLineThickness.Value

        ShowEntityPathClearAllLines()

        if not ShowEntityPathShow then
            ShowEntityPathSetNodeTransparency(1)
            return
        end

        ShowEntityPathSetNodeTransparency(ShowEntityPathNodeTransparency)

        local ShowEntityPathValidRooms = {}
        for _, ShowEntityPathRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
            if ShowEntityPathRoom:FindFirstChild("PathfindNodes") then
                table.insert(ShowEntityPathValidRooms, ShowEntityPathRoom)
            end
        end

        table.sort(ShowEntityPathValidRooms, function(a, b)
            return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
        end)

        for _, ShowEntityPathRoom in ipairs(ShowEntityPathValidRooms) do
            local ShowEntityPathNodes = ShowEntityPathRoom.PathfindNodes
            local ShowEntityPathSortedNodes = ShowEntityPathGetSortedNodes(ShowEntityPathNodes)

            if #ShowEntityPathSortedNodes > 0 then
                local ShowEntityPathRoomLines = {}

                for i = 1, #ShowEntityPathSortedNodes - 1 do
                    local ShowEntityPathFrom = ShowEntityPathSortedNodes[i].Part
                    local ShowEntityPathTo = ShowEntityPathSortedNodes[i + 1].Part

                    local ShowEntityPathLine = ShowEntityPathCreateLine(
                        ShowEntityPathFrom.Position,
                        ShowEntityPathTo.Position,
                        ShowEntityPathLineTransparency,
                        ShowEntityPathLineThickness,
                        ShowEntityPathRoom
                    )
                    if ShowEntityPathLine then
                        table.insert(ShowEntityPathRoomLines, ShowEntityPathLine)
                    end
                end

                if #ShowEntityPathRoomLines > 0 then
                    ShowEntityPathLines[ShowEntityPathRoom] = ShowEntityPathRoomLines
                end
            end
        end
    end

    Toggles.ab_ShowEntityPath:OnChanged(function()
        if ShowEntityPathChildAddedConnection then
            ShowEntityPathChildAddedConnection:Disconnect()
            ShowEntityPathChildAddedConnection = nil
        end

        ShowEntityPathUpdateAll()

        if Toggles.ab_ShowEntityPath.Value then
            ShowEntityPathChildAddedConnection = workspace.CurrentRooms.ChildAdded:Connect(function(ShowEntityPathRoom)
                if ShowEntityPathRoom:WaitForChild("PathfindNodes", 5) then
                    task.wait(0.1)
                    ShowEntityPathUpdateAll()
                end
            end)
        end
    end)

    Options.ab_ShowEntityPathNodeTransparency:OnChanged(function()
        if Toggles.ab_ShowEntityPath.Value then
            ShowEntityPathSetNodeTransparency(Options.ab_ShowEntityPathNodeTransparency.Value)
        end
    end)

    Options.ab_ShowEntityPathLineTransparency:OnChanged(function()
        if Toggles.ab_ShowEntityPath.Value then
            ShowEntityPathSetLineTransparency(Options.ab_ShowEntityPathLineTransparency.Value)
        end
    end)

    Options.ab_ShowEntityPathLineThickness:OnChanged(function()
        if Toggles.ab_ShowEntityPath.Value then
            ShowEntityPathUpdateAll()
        end
    end)


    Groupboxes.Visuals_Entities:AddDivider()

    local ItemsToNotify = {}
    for Index, Name in pairs(ItemNames) do
    	if not table.find(ItemsToNotify, Name) then
    		table.insert(ItemsToNotify, Name)
    	end
    end
    table.sort(ItemsToNotify)

    Groupboxes.Visuals_Entities:AddDropdown("ab_NotifyItemList", {
    	Text = "Item List",
    	Values = ItemsToNotify,
    	Multi = true, AllowNull = true
    })
    Groupboxes.Visuals_Entities:AddToggle("ab_NotifyItemsToggle",    { Text = "Notify Items",    Default = false, Tooltip = "Sends a notification when an item spawns." })
    Groupboxes.Visuals_Entities:AddToggle("ab_NotifyItemsShowDistance",    { Text = "Show Distance",    Default = false, Tooltip = "Shows how far away the item is in the notification." })
    Groupboxes.Visuals_Entities:AddDivider()
    Groupboxes.Visuals_Entities:AddToggle("ab_NotifyLibraryCode", { Text = "Notify Library Code", Default = false, Tooltip = "Automatically solves the code for the library padlock." })
    Groupboxes.Visuals_Entities:AddToggle("ab_NotifyOxygen",      { Text = "Notify Oxygen Level", Default = false, Tooltip = "Shows how much oxygen you have remaining." })
    Groupboxes.Visuals_Entities:AddToggle("ab_NotifyHasteTime",   { Text = "Notify Haste Time",   Default = false, Tooltip = "Shows how much time you have remaining before 'Haste' spawns." })

    Globals.LibraryCodeFound = false
    Toggles.ab_NotifyLibraryCode:OnChanged(function(Value)
    	if Value then
    		local Code = Functions.GetLibraryCode()
    		if Code and not Code:find("_") and not Globals.LibraryCodeFound and CurrentRooms:FindFirstChild("50") then
    			local Lock = Services.Workspace:FindFirstChild("Padlock", true)
    			Functions.Notify({ Title = "Padlock code found!", Body = "The code is: '" .. Code .. "'", Time = Toggles.ab_NotifyKeepNotifications.Value and Lock or 15 })
    			Globals.LibraryCodeFound = true
    		end
    	end
    end)

    Groupboxes.Visuals_EntitySettings:AddToggle("ab_EntityChatToggle", { Text = "Notify Chat", Default = false, Tooltip = "Sends a message in the chat when an entity spawns." })
    Groupboxes.Visuals_EntitySettings:AddInput("ab_EntityChatMessage", { Text = "Message", Default = "spawned!", Numeric = false, Placeholder = "Message" })
    Groupboxes.Visuals_EntitySettings:AddDivider()
    Groupboxes.Visuals_EntitySettings:AddDropdown("ab_NotifyStyle", { Text = "Notify Style", Values = { "Abysall", "Doors", "STX", "Library" }, Default = 1 })
    Groupboxes.Visuals_EntitySettings:AddSlider("ab_NotifySoundVolume", { Text = "Sound Volume", Min = 0, Max = 10, Default = 3, Rounding = 1 })
    Groupboxes.Visuals_EntitySettings:AddToggle("ab_NotifyPlaySound", { Text = "Play Sound", Default = true, Tooltip = "Makes notifications play an alert sound." })
    Groupboxes.Visuals_EntitySettings:AddToggle("ab_NotifyKeepNotifications", { Text = "Keep Notifications", Default = false, Tooltip = "Certain notifications will stay on screen until they are no longer needed." })
    Groupboxes.Visuals_EntitySettings:AddButton({ Text = "Test Notification", DoubleClick = false, Tooltip = "Sends a test notifcation, so you can see how your settings look.", Func = function()
    	Functions.Notify({Title = "This is a test."})
    end})

    Groupboxes.Visuals_ESP          = Tabs.Visuals:AddRightTabbox("ESP/Settings")
    Groupboxes.Visuals_ESP_Toggles  = Groupboxes.Visuals_ESP:AddTab("ESP")
    Groupboxes.Visuals_ESP_Settings = Groupboxes.Visuals_ESP:AddTab("Settings")

    local function MakeESPToggle(ToggleKey, ColorKey, Text, Tooltip, ObjectsTable, LabelFunc, RoomBased)
    	Groupboxes.Visuals_ESP_Toggles:AddToggle(ToggleKey, { Text = Text, Default = false, Tooltip = Tooltip })
    	Toggles[ToggleKey]:AddColorPicker(ColorKey, { Text = Text, Default = Options[ColorKey] and Options[ColorKey].Value or Color3.new(1,1,1), Transparency = 0 })
    	Toggles[ToggleKey]:OnChanged(function(Value)
    		for _, Object in ObjectsTable do
    			if Value then
    				local Label, UseRoom = LabelFunc(Object)
    				if Label then
    					Functions.AddESP({ Object = Object, Text = Label, Color = Options[ColorKey].Value }, UseRoom ~= nil and UseRoom or RoomBased)
    				end
    			else
    				Functions.RemoveESP(Object)
    			end
    		end
    	end)
    	Options[ColorKey]:OnChanged(function(Value)
    		for _, Object in ObjectsTable do
    			Abysall.ESPLibrary:UpdateObjectColor(Object, Value)
    		end
    	end)
    end

    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_ObjectiveESPToggle", { Text = "Objectives", Default = false, Tooltip = "Highlights all objects required to progress." })
    Toggles.ab_ObjectiveESPToggle:AddColorPicker("ab_ObjectiveESPColor", { Text = "Objectives", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })

    local ObjectiveLabels = {
    	["StairwellLockpickDoor"]  = "Garage Door",
    	["Mirror"]				   = "Mirror",
    	["ShoppingCart"]		   = "Shopping Cart",
    	["StairwellFireAlarm"]     = "Fire Alarm",
    	["StairwellScrapper"]	   = "Scrapper",
    	["ArchivesPackageDeposit"] = "BoxDeposit",
    	["Cellar"] 				   = "Cellar",
    	["ArchivesFihTank"]        = "Fih Tank",
    	["KeyObtain"]              = "Door Key",
    	["ElectricalKeyObtain"]    = "Electrical Key",
    	["MinesGenerator"]         = "Generator",
    	["FuseObtain"]             = "Generator Fuse",
    	["LiveHintBook"]           = "Hint Book",
    	["LiveBreakerPolePickup"]  = "Fuse Breaker",
    	["LibraryHintPaper"]       = "Hint Paper",
    	["PickupItem"]             = "Hint Paper",
    	["CringlePresent"]         = "Present",
    	["LeverForGate"]           = "Gate Lever",
    	["MinesGateButton"]        = "Gate Button",
    	["GardenGateButton"]       = "Gate Button",
    }

    Toggles.ab_ObjectiveESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Objectives do
    		if Value then
    			local Label = ObjectiveLabels[Object.Name]
    			if Object.Name == "TimerLever" then
    				Label = "Time Lever [+" .. Object:GetAttribute("AddTime") .. "s]"
    			elseif Object.Name == "MinesAnchor" then
    				Label = "Anchor [" .. Object:WaitForChild("Sign").TextLabel.Text .. "]"
    			elseif Object.Name == "WaterPump" then
    				Functions.AddESP({ Object = Object.Wheel, Text = "Water Pump", Color = Options.ab_ObjectiveESPColor.Value }, true)
    			elseif Object.Name == "VineGuillotine" then
    				Functions.AddESP({ Object = Object.Lever, Text = "Vine Lever", Color = Options.ab_ObjectiveESPColor.Value }, true)
    			end
    			if Label then
    				Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_ObjectiveESPColor.Value }, true)
    			end
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)
    Options.ab_ObjectiveESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Objectives do
    		Abysall.ESPLibrary:UpdateObjectColor(Object, Value)
    	end
    end)

    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_DoorESPToggle",       { Text = "Doors",        Default = false, Tooltip = "Highlights the next door." })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_HidingSpotESPToggle", { Text = "Hiding Spots", Default = false, Tooltip = "Highlights places where you can hide from entities" })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_PlayerESPToggle",     { Text = "Players",      Default = false, Tooltip = "Highlights other players." })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_ChestESPToggle",      { Text = "Chests",       Default = false, Tooltip = "Highlights objects that can contain loot." })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_ItemESPToggle",       { Text = "Items",        Default = false, Tooltip = "Highlights all collectable items/consumables." })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_CurrencyESPToggle",   { Text = "Currency",     Default = false, Tooltip = "Highlights all currency that spawns." })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_LadderESPToggle",     { Text = "Ladders",      Default = false, Tooltip = "Highlights ladders that can be used to disable the anticheat." })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_MiscESPToggle",       { Text = "Misc",         Default = false, Tooltip = "Highlights miscellaneous objects that can be used to disable the anticheat." })
    Groupboxes.Visuals_ESP_Toggles:AddDivider()
    Groupboxes.Visuals_ESP_Toggles:AddDropdown("ab_EntityESPOptions",     { 
    	Text = "Entity List",
    	Values = { "Rush","Bash","Scribbles","Teller","DronesStampede","Creak","Noise","Noise_TV","Balls","Portrait","Ambush","Eyes","Dupe","Figure","Blitz","Lookman","Snare","Giggle","Gloombat Eggs","Grumble","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Mandrake Hole","Monument","Bramble","AR0xMBUSH","RNIUSHCG==" },
    	Multi = true,
    	AllowNull = true
    })
    Groupboxes.Visuals_ESP_Toggles:AddToggle("ab_EntityESPToggle",     { Text = "Entities",      Default = false, Tooltip = "Highlights all entities that spawn." })

    Toggles.ab_DoorESPToggle:AddColorPicker("ab_DoorESPColor",           { Text = "Doors",        Default = Color3.fromRGB(0, 200, 255),  Transparency = 0 })
    Toggles.ab_HidingSpotESPToggle:AddColorPicker("ab_HidingSpotESPColor", { Text = "Hiding Spots", Default = Color3.fromRGB(255, 170, 0),  Transparency = 0 })
    Toggles.ab_PlayerESPToggle:AddColorPicker("ab_PlayerESPColor",       { Text = "Players",      Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
    Toggles.ab_ChestESPToggle:AddColorPicker("ab_ChestESPColor",         { Text = "Chests",       Default = Color3.fromRGB(255, 255, 0),   Transparency = 0 })
    Toggles.ab_ItemESPToggle:AddColorPicker("ab_ItemESPColor",           { Text = "Items",        Default = Color3.fromRGB(170, 0, 255),   Transparency = 0 })
    Toggles.ab_CurrencyESPToggle:AddColorPicker("ab_CurrencyESPColor",   { Text = "Currency",     Default = Color3.fromRGB(255, 255, 0),   Transparency = 0 })
    Toggles.ab_LadderESPToggle:AddColorPicker("ab_LadderESPColor",       { Text = "Ladders",      Default = Color3.fromRGB(3, 67, 71), Transparency = 0 })
    Toggles.ab_MiscESPToggle:AddColorPicker("ab_MiscESPColor",           { Text = "Misc",         Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
    Toggles.ab_EntityESPToggle:AddColorPicker("ab_EntityESPColor",       { Text = "Entities",     Default = Color3.fromRGB(255, 0, 0),     Transparency = 0 })

    local HidingSpotLabels = {
    	Wardrobe = "Closet", ["Backdoor_Wardrobe"] = "Closet", Toolshed = "Closet",
    	RetroWardrobe = "Closet", ["Wardrobe-FOOLS26"] = "Closet",
    	Locker_Large = "Locker", Rooms_Locker = "Hiding_Spot", Rooms_Locker_Fridge = "Locker",
    	Bed = "Bed", Double_Bed = "Double Bed", CircularVent = "Vent", Dumpster = "Dumpster"
    }
    local ChestLabels = {
    	ChestBox = true, ChestBoxLocked = true, Toolbox = true, Toolbox_Locked = true,
    	Chest_Vine = "Vine Chest", Toolshed_Small = "Toolshed", Locker_Small_Locked = "Locked Item Locker", MouseHole = "Mouse"
    }
    local EntityESPLabels = {
    	JeffTheKiller = "Jeff the Killer", GiggleCeiling = "Giggle",
    	Snare = "Snare", GrumbleRig = "Grumble",
    	Drakobloxxer = "Drakobloxxer", Hole = "Mandrake Hole", Groundskeeper = "Groundskeeper",
    	LiveEntityBramble = "Bramble", Figure = "Figure", FigureRig = "Figure", FigureRagdoll = "Figure",
    	FakeDoor = "Dupe", DoorFake = "Dupe"
    }

    local NodeEntities = {
    	Rush = true, Bash = true, Scribbles = true, DronesStampede = true, Ambush = true, Eyes = true, Blitz = true, Lookman = true, ["A-60"] = true, ["A-120"] = true, Sally = true, ["Jeff The Killer"] = true, Monument = true, ["AR0xMBUSH"] = true, ["RNIUSHCG=="] = true
    }

    Toggles.ab_DoorESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Doors do
    		if Value then Functions.AddESP({ Object = Object, Text = "Door " .. Functions.GetDoorNumber(Object), Color = Options.ab_DoorESPColor.Value }, true)
    		else Functions.RemoveESP(Object) end
    	end
    end)
    Options.ab_DoorESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Doors do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_HidingSpotESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.HidingSpots do
    		local Label = HidingSpotLabels[Object.Name]
    		if Value and Label then Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_HidingSpotESPColor.Value }, true)
    		elseif not Value then Functions.RemoveESP(Object) end
    	end
    end)
    Options.ab_HidingSpotESPColor:OnChanged(function(Value)
    	for _, Object in Objects.HidingSpots do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_PlayerESPToggle:OnChanged(function(Value)
    	task.wait()
    	for _, Player in Services.Players:GetPlayers() do
    		if Player.Character and Player ~= LocalPlayer then
    			if Value and Player:GetAttribute("Alive") == true then
    				Functions.AddESP({ Object = Player.Character, Text = Player.Name, Color = Options.ab_PlayerESPColor.Value })
    			else
    				Functions.RemoveESP(Player.Character)
    			end
    		end
    	end
    end)
    Options.ab_PlayerESPColor:OnChanged(function(Value)
    	for _, Player in Services.Players:GetPlayers() do
    		if Player.Character and Player ~= LocalPlayer then
    			Abysall.ESPLibrary:UpdateObjectColor(Player.Character, Value)
    		end
    	end
    end)

    Toggles.ab_ChestESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Chests do
    		if Value then
    			local Label
    			if Object.Name == "ChestBox" or Object.Name == "ChestBoxLocked" then
    				Label = Object:GetAttribute("Locked") and "Locked Chest" or "Chest"
    			elseif Object.Name == "Toolbox" or Object.Name == "Toolbox_Locked" then
    				Label = Object:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox"
    			elseif ChestLabels[Object.Name] and ChestLabels[Object.Name] ~= true then
    				Label = ChestLabels[Object.Name]
    			end
    			if Label then Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_ChestESPColor.Value }, true) end
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)

    Options.ab_ChestESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Chests do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_ItemESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Items do
    		if Value then
    			local Label = ItemNames[Object.Name] or (Object.Name == "Green_Herb" and "Green Herb")
    			if Label then
    				Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_ItemESPColor.Value }, Object:GetAttribute("ParentRoom") ~= nil)
    			end
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)
    Options.ab_ItemESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Items do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_CurrencyESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Currency do
    		if Value then
    			local Label
    			if Object.Name == "GoldPile" and Object:GetAttribute("GoldValue") then
    				Label = "Gold Pile [" .. Object:GetAttribute("GoldValue") .. "]"
    			elseif Object.Name == "StardustPickup" then
    				Label = "Stardust Pile"
    			end
    			if Label then Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_CurrencyESPColor.Value }, true) end
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)
    Options.ab_CurrencyESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Currency do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_EntityESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Value then
    			local Label = EntityESPLabels[Object.Name]
    			if not Label and Entities[Object.Name] then Label = Entities[Object.Name].Alias end
    			if Label and Options.ab_EntityESPOptions.Value[Label] then
    				Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_EntityESPColor.Value }, NodeEntities[Label] ~= true)
    			else
    				Functions.RemoveESP(Object)
    			end
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)

    Options.ab_EntityESPOptions:OnChanged(function(Value)
    	for _, Object in Objects.Entities do
    		if Toggles.ab_EntityESPToggle.Value then
    			local Label = EntityESPLabels[Object.Name]
    			if not Label and Entities[Object.Name] then Label = Entities[Object.Name].Alias end
    			if Label and Options.ab_EntityESPOptions.Value[Label] then
    				Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_EntityESPColor.Value }, NodeEntities[Label] ~= true)
    			else
    				Functions.RemoveESP(Object)
    			end
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)

    Options.ab_EntityESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Entities do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_LadderESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Ladders do
    		if Value then Functions.AddESP({ Object = Object, Text = "Ladder", Color = Options.ab_LadderESPColor.Value }, true)
    		else Functions.RemoveESP(Object) end
    	end
    end)
    Options.ab_LadderESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Ladders do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Toggles.ab_MiscESPToggle:OnChanged(function(Value)
    	for _, Object in Objects.Misc do
    		if Value then
    			local Label = Object.Name
    			if Object.Name == "StairwellLockpickDoor" or Object.Name == "StiarwellLockpickDoor" then
    				Label = "Garage Door"
    			elseif Object.Name == "StairwellFireAlarm" then
    				Label = "Fire Alarm"
    			elseif Object.Name == "ShoppingCart" then
    				Label = "Shopping Cart"
    			elseif Object.Name == "ArchivesFihTank" or Object.Name == "ArchivesFishTank" then
    				Label = "Fish Tank"
    			end
    			Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_MiscESPColor.Value }, true)
    		else
    			Functions.RemoveESP(Object)
    		end
    	end
    end)
    Options.ab_MiscESPColor:OnChanged(function(Value)
    	for _, Object in Objects.Misc do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
    end)

    Groupboxes.Visuals_ESP_Settings:AddToggle("ab_ESPRainbow",     { Text = "Rainbow Effect", Default = false, Tooltip = "Makes the esp objects change colour like a rainbow." })
    Groupboxes.Visuals_ESP_Settings:AddToggle("ab_ESPShowDistance",{ Text = "Show Distance",  Default = true,  Tooltip = "Shows how far away your character is from the object." })
    Groupboxes.Visuals_ESP_Settings:AddDivider()
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPFillTransparency",        { Text = "Fill Transparency",         Min = 0, Max = 1, Default = 0.75, Rounding = 2, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPOutlineTransparency",     { Text = "Outline Transparency",      Min = 0, Max = 1, Default = 0,    Rounding = 2, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPTextTransparency",        { Text = "Text Transparency",         Min = 0, Max = 1, Default = 0,    Rounding = 2, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPTextOutlineTransparency", { Text = "Text Outline Transparency", Min = 0, Max = 1, Default = 0,    Rounding = 2, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPFadeTime",                { Text = "Fade Time",                 Min = 0, Max = 1, Default = 0.25, Rounding = 2, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPRenderLimit",             { Text = "Render Limit",              Min = 30, Max = 240, Default = 240, Rounding = 0, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPTextSize",                { Text = "Text Size",                 Min = 12, Max = 24, Default = 20, Rounding = 0, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddDropdown("ab_ESPTextFont", {
    	Text = "Text Font",
    	Values = { "Legacy","Arial","ArialBold","SourceSans","SourceSansBold","SourceSansLight","SourceSansItalic","Bodoni","Garamond","Cartoon","Code","Highway","SciFi","Arcade","Fantasy","Antique","SourceSansSemibold","Gotham","GothamMedium","GothamBold","GothamBlack","AmaticSC","Bangers","Creepster","DenkOne","Fondamento","FredokaOne","GrenzeGotisch","IndieFlower","JosefinSans","Jura","Kalam","LuckiestGuy","Merriweather","Michroma","Nunito","Oswald","PatrickHand","PermanentMarker","Roboto","RobotoCondensed","RobotoMono","Sarpanch","SpecialElite","TitilliumWeb","Ubuntu","BuilderSans","BuilderSansMedium","BuilderSansBold","BuilderSansExtraBold","Arimo","ArimoBold" },
    	Default = 12
    })
    Groupboxes.Visuals_ESP_Settings:AddDivider()
    Groupboxes.Visuals_ESP_Settings:AddDropdown("ab_ESPTracersOrigin",  { Text = "Tracer Origin", Values = { "Bottom","Center","Top","Mouse" }, Default = 1 })
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPTracerThickness",  { Text = "Tracer Thickness", Min = 0.5, Max = 2, Default = 0.75, Rounding = 2, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddToggle("ab_ESPTracersToggle",    { Text = "Enable Tracers", Default = false, Tooltip = "Draws a line to highlighted objects." })
    Groupboxes.Visuals_ESP_Settings:AddDivider()
    Groupboxes.Visuals_ESP_Settings:AddSlider("ab_ESPArrowsRadius",     { Text = "Arrow Radius", Min = 100, Max = 500, Default = 250, Rounding = 0, Compact = true })
    Groupboxes.Visuals_ESP_Settings:AddToggle("ab_ESPArrowsToggle",     { Text = "Enable Arrows", Default = false, Tooltip = "Shows arrow that point to off-screen objects." })

    Abysall.ESPLibrary:SetRainbow(false)
    Abysall.ESPLibrary:SetShowDistance(true)
    Abysall.ESPLibrary:SetFillTransparency(0.75)
    Abysall.ESPLibrary:SetOutlineTransparency(0)
    Abysall.ESPLibrary:SetTextTransparency(0)
    Abysall.ESPLibrary:SetTextOutlineTransparency(0)
    Abysall.ESPLibrary:SetRenderLimit(240)
    Abysall.ESPLibrary:SetFadeTime(0.25)
    Abysall.ESPLibrary:SetTextSize(20)
    Abysall.ESPLibrary:SetFont(Enum.Font.Highway)
    Abysall.ESPLibrary:SetTracers(false)
    Abysall.ESPLibrary:SetTracerSize(0.75)
    Abysall.ESPLibrary:SetTracerOrigin("Bottom")
    Abysall.ESPLibrary:SetArrows(false)
    Abysall.ESPLibrary:SetArrowRadius(250)
    Abysall.ESPLibrary:SetDistanceSizeRatio(0.8)

    Toggles.ab_ESPRainbow:OnChanged(function(V)        Abysall.ESPLibrary:SetRainbow(V) end)
    Toggles.ab_ESPShowDistance:OnChanged(function(V)   Abysall.ESPLibrary:SetShowDistance(V) end)
    Options.ab_ESPFillTransparency:OnChanged(function(V)        Abysall.ESPLibrary:SetFillTransparency(V) end)
    Options.ab_ESPOutlineTransparency:OnChanged(function(V)     Abysall.ESPLibrary:SetOutlineTransparency(V) end)
    Options.ab_ESPTextTransparency:OnChanged(function(V)        Abysall.ESPLibrary:SetTextTransparency(V) end)
    Options.ab_ESPTextOutlineTransparency:OnChanged(function(V) Abysall.ESPLibrary:SetTextOutlineTransparency(V) end)
    Options.ab_ESPFadeTime:OnChanged(function(V)        Abysall.ESPLibrary:SetFadeTime(V) end)
    Options.ab_ESPRenderLimit:OnChanged(function(V)     Abysall.ESPLibrary:SetRenderLimit(V) end)
    Options.ab_ESPTextSize:OnChanged(function(V)        Abysall.ESPLibrary:SetTextSize(V) end)
    Options.ab_ESPTextFont:OnChanged(function(V)        Abysall.ESPLibrary:SetFont(Enum.Font[V]) end)
    Toggles.ab_ESPTracersToggle:OnChanged(function(V)   Abysall.ESPLibrary:SetTracers(V) end)
    Options.ab_ESPTracersOrigin:OnChanged(function(V)   Abysall.ESPLibrary:SetTracerOrigin(V) end)
    Options.ab_ESPTracerThickness:OnChanged(function(V) Abysall.ESPLibrary:SetTracerSize(V) end)
    Toggles.ab_ESPArrowsToggle:OnChanged(function(V)    Abysall.ESPLibrary:SetArrows(V) end)
    Options.ab_ESPArrowsRadius:OnChanged(function(V)    Abysall.ESPLibrary:SetArrowRadius(V) end)

    Groupboxes.Floors_Automation = Tabs.Floors:AddRightGroupbox("Automation")

    Groupboxes.Floors_Automation:AddToggle("ab_SkipSeekMines", {
    	Text = "Skip Seek (Mines)",
    	Default = false,
    	Tooltip = "Skips the entire Seek sections.",
    	Risky = Floor ~= "Mines"
    })

    Toggles.ab_SkipSeekMines:OnChanged(function(Value)
    	if Value then
    		if Floor ~= "Mines" then
    			return
    		end
    		task.spawn(function()
    			local MinesSkipSeekCurrentRooms

    			repeat
    				if not Toggles.ab_SkipSeekMines.Value then
    					return
    				end

    				MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")
    				task.wait()
    			until MinesSkipSeekCurrentRooms

    			local MinesSkipSeekStartRoom

    			repeat
    				if not Toggles.ab_SkipSeekMines.Value then
    					return
    				end

    				MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")

    				if MinesSkipSeekCurrentRooms then
    					MinesSkipSeekStartRoom = MinesSkipSeekCurrentRooms:FindFirstChild("42")
    				end

    				task.wait()
    			until MinesSkipSeekStartRoom

    			local MinesSkipSeekStartDoor

    			repeat
    				if not Toggles.ab_SkipSeekMines.Value then
    					return
    				end

    				MinesSkipSeekStartDoor = MinesSkipSeekStartRoom:FindFirstChild("Door", true)
    				task.wait()
    			until MinesSkipSeekStartDoor

    			repeat
    				if not Toggles.ab_SkipSeekMines.Value then
    					return
    				end

    				task.wait()
    			until MinesSkipSeekStartDoor:GetAttribute("Opened") == true

    			if Character and Character:GetAttribute("Minecarting") == true then
    				Character:SetAttribute("Minecarting", false)
    			end

    			for _, MinesSkipSeekRoomNumber in ipairs({
    				43, 44, 45, 46, 47, 48, 49,
    				78, 79, 80, 81, 82, 83
    			}) do
    				if not Toggles.ab_SkipSeekMines.Value then
    					return
    				end

    				local MinesSkipSeekRoom

    				repeat
    					if not Toggles.ab_SkipSeekMines.Value then
    						return
    					end

    					MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")

    					if MinesSkipSeekCurrentRooms then
    						MinesSkipSeekRoom = MinesSkipSeekCurrentRooms:FindFirstChild(
    							tostring(MinesSkipSeekRoomNumber)
    						)
    					end

    					task.wait()
    				until MinesSkipSeekRoom

    				local MinesSkipSeekDoor

    				repeat
    					if not Toggles.ab_SkipSeekMines.Value then
    						return
    					end

    					MinesSkipSeekDoor = MinesSkipSeekRoom:FindFirstChild("Door", true)
    					task.wait()
    				until MinesSkipSeekDoor

    				repeat
    					if not Toggles.ab_SkipSeekMines.Value then
    						return
    					end

    					if Character then
    						Character:PivotTo(MinesSkipSeekDoor:GetPivot())
    					end

    					task.wait()
    				until MinesSkipSeekDoor:GetAttribute("Opened") == true

    				if MinesSkipSeekRoomNumber == 49 or MinesSkipSeekRoomNumber == 83 then
    					if not Character then
    						return
    					end

    					local MinesSkipSeekVoidPivot = Character:GetPivot()
    					MinesSkipSeekVoidPivot = MinesSkipSeekVoidPivot + Vector3.new(0, -1000, 0)

    					task.wait(0.3)

    					for MinesSkipSeekVoidCount = 1, 12 do
    						Character:PivotTo(MinesSkipSeekVoidPivot)
    					end

    					for MinesSkipSeekVoidCount = 1, 12 do
    						Character:PivotTo(MinesSkipSeekVoidPivot)
    					end

    					for MinesSkipSeekVoidCount = 1, 12 do
    						Character:PivotTo(MinesSkipSeekVoidPivot)
    					end

    					task.wait(0.3)

    					for MinesSkipSeekVoidCount = 1, 6 do
    						Character:PivotTo(MinesSkipSeekVoidPivot)
    					end
    				end

    				if MinesSkipSeekRoomNumber == 83 then
    					return
    				end
    			end
    		end)
    	end
    end)

    Groupboxes.Floors_Automation:AddToggle("ab_AutoSteerMinecart", {
    	Text = "Auto Steer Minecart", Default = false, Tooltip = "Automatically completes the minecart chase.",
    	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Floors_Automation:AddSlider("ab_AutoSteerMinecartTurnDistance", {
    	Text = "Turn Distance", Min = 20, Max = 40, Default = 30, Rounding = 0,
    	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Floors_Automation:AddSlider("ab_AutoSteerMinecartDuckDistance", {
    	Text = "Crouch Distance", Min = 20, Max = 40, Default = 30, Rounding = 0,
    	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Floors_Automation:AddDivider()
    Groupboxes.Floors_Automation:AddToggle("ab_RoomsAutoWalk",             { Text = "Auto Rooms",       Default = false, Tooltip = "Automatically moves and hides from entities in The Rooms." })
    Groupboxes.Floors_Automation:AddSlider("ab_RoomsAutoWalkPathfindTimeout", { Text = "Pathfind Timeout", Min = 0.5, Max = 3, Default = 1, Rounding = 1 })
    Groupboxes.Floors_Automation:AddToggle("ab_RoomsAutoWalkIgnoreA60",    { Text = "Ignore A-60",      Default = false, Tooltip = "Continues to walk if entity 'A-60' is present, enables position spoof automatically." })
    Groupboxes.Floors_Automation:AddToggle("ab_RoomsAutoWalkShowPathToggle", { Text = "Show Path",       Default = false, Tooltip = "Shows the current path of rooms auto-walk." })
    Groupboxes.Floors_Automation:AddToggle("ab_RoomsAutoWalkSpoofFootsteps", {
        Text = "Spoof Footsteps", Default = false, Tooltip = "Makes it appear as if your character is walking normally.",
        Disabled = not Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}), DisabledTooltip = Globals.IncompatibleMessage
    })

    Toggles.ab_RoomsAutoWalk:OnChanged(function()
    	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
    		if Object.Name == "PathNode" then Object:Destroy() end
    	end
    end)
    Toggles.ab_RoomsAutoWalkShowPathToggle:AddColorPicker("ab_RoomsAutoWalkShowPathColor", { Text = "Path", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })
    Toggles.ab_RoomsAutoWalkShowPathToggle:OnChanged(function(Value)
    	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
    		if Object.Name == "PathNode" then Object.Transparency = Value and 0.5 or 1 end
    	end
    end)
    Options.ab_RoomsAutoWalkShowPathColor:OnChanged(function(Value)
    	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
    		if Object.Name == "PathNode" then Object.Color = Value end
    	end
    end)

    Functions.RoomsAutoWalk = {}
    Functions.RoomsAutoWalk.GetNearestHidingSpot = function()
    	local Nearest = { Distance = math.huge, Object = nil }
    	for _, Object in Objects.HidingSpots do
    		if Object.PrimaryPart and Object:FindFirstChild("HidePrompt") then
    			local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
    			if Distance < Nearest.Distance and Object.PrimaryPart.Position.Y > -10 then
    				local HiddenPlayer = Object:FindFirstChild("HiddenPlayer", true)
    				if HiddenPlayer and not HiddenPlayer.Value then
    					Nearest.Distance = Distance
    					Nearest.Object = Object
    				end
    			end
    		end
    	end
    	return Nearest.Object
    end

    local RoomsEntityList = { "RushMoving","AmbushMoving","BackdoorRush","A60","A120","CustomEntity","GlitchRush","GlitchAmbush" }
    Functions.RoomsAutoWalk.GetPathfindTarget = function()
    	for _, Object in Services.Workspace:GetChildren() do
    		if table.find(RoomsEntityList, Object.Name) and Object.PrimaryPart then
    			local Y = Object.PrimaryPart.Position.Y
    			if Y > -10 and Y < 150 then
    				if Object.Name == "A60" and not Toggles.ab_RoomsAutoWalkIgnoreA60.Value or Object.Name ~= "A60" then
    					return Functions.RoomsAutoWalk.GetNearestHidingSpot() or CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
    				end
    			end
    		end
    	end
    	return CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
    end

    Connections.RoomsAutoWalkHandler = Services.RunService.Heartbeat:Connect(function()
    	if Floor ~= "Rooms" or not Toggles.ab_RoomsAutoWalk.Value or Globals.RoomsAutoWalkActive or not CollisionPart or LatestRoom.Value >= 1000 then return end
    	Globals.RoomsAutoWalkActive = true

    	local Path = Services.PathfindingService:CreatePath({
    		AgentCanJump = true, AgentCanClimb = false, WaypointSpacing = 4,
    		AgentRadius = 1.5, AgentHeight = 1.5, Costs = { StuckPart = 8 }
    	})

    	if Toggles.ab_RoomsAutoWalkIgnoreA60.Value and not Toggles.ab_PositionSpoof.Value then
    		Toggles.ab_PositionSpoof:SetValue(true)
    	end

    	local TargetPart = Functions.RoomsAutoWalk.GetPathfindTarget()
    	if not TargetPart then
    		Globals.RoomsAutoWalkActive = false
    		return
    	end

    	local TargetPosition
    	if TargetPart.Name == "RoomExit" then
    		TargetPosition = TargetPart.Position
    	elseif TargetPart:FindFirstChild("HidePrompt") then
    		for _, Part in TargetPart:GetDescendants() do
    			if Part:IsA("BasePart") then Part.CanCollide = false end
    		end
    		TargetPosition = TargetPart.PrimaryPart.Position
    	end

    	if CollisionPart.Anchored and not TargetPart:FindFirstChild("HidePrompt") then
    		Character:SetAttribute("Hiding", true)
    		RemotesFolder.CamLock:FireServer()
    		Character:SetAttribute("Hiding", false)
    	end

    	local CurrentRoom = CurrentRooms[tostring(LatestRoom.Value)]
    	if CurrentRoom:FindFirstChild("Door") then
    		CurrentRoom.Door.Door.CanCollide = false
    	end

    	if not TargetPosition or LocalPlayer:DistanceFromCharacter(TargetPosition) >= 750 then
    		Globals.RoomsAutoWalkActive = false
    		return
    	end

    	Path:ComputeAsync(CollisionPart.Position, TargetPosition)
    	local Waypoints = Path:GetWaypoints()

    	if #Waypoints == 0 then
    		local RoomExit = CurrentRoom:FindFirstChild("RoomExit")
    		if RoomExit then Humanoid:MoveTo(RoomExit.Position) end
    		Globals.RoomsAutoWalkActive = false
    		return
    	end

    	for _, Node in Globals.RoomsNodesFolder:GetChildren() do
    		if Node.Name == "PathNode" then Node:Destroy() end
    	end

    	for _, Waypoint in Waypoints do
    		local Block = Instance.new("Part", Globals.RoomsNodesFolder)
    		Block.Transparency = Toggles.ab_RoomsAutoWalkShowPathToggle.Value and 0.5 or 1
    		Block.Size = Vector3.one
    		Block.Position = Waypoint.Position
    		Block.Shape = Enum.PartType.Ball
    		Block.CanCollide = false
    		Block.Anchored = true
    		Block.Name = "PathNode"
    		Block.Color = Options.ab_RoomsAutoWalkShowPathColor.Value
    		Block.Material = Enum.Material.Neon
    	end

    	local Stuck = false
    	for _, Waypoint in Waypoints do
    		if Stuck or not Toggles.ab_RoomsAutoWalk.Value then break end

    		local Finished = false
    		local Start = tick()

    		local StepConnection = Services.RunService.RenderStepped:Connect(function()
    			if Stuck or not Toggles.ab_RoomsAutoWalk.Value then Finished = true return end

    			local NewTarget = Functions.RoomsAutoWalk.GetPathfindTarget()
    			if NewTarget and NewTarget:FindFirstChild("HidePrompt") and not TargetPart:FindFirstChild("HidePrompt") then
    				Finished = true return
    			end
    			if TargetPart:FindFirstChild("HidePrompt") then
    				local HidePrompt = TargetPart:FindFirstChild("HidePrompt")
    				if LocalPlayer:DistanceFromCharacter(TargetPosition) < HidePrompt.MaxActivationDistance
    					and Character:GetAttribute("Hiding") ~= true
    				then
    					Functions.ForceFirePrompt(HidePrompt)
    				end
    			end
    			local FlatPos = Vector3.new(Waypoint.Position.X, RootPart.Position.Y, Waypoint.Position.Z)
    			if LocalPlayer:DistanceFromCharacter(FlatPos) < 5 then Finished = true end
    			Humanoid:MoveTo(Waypoint.Position)
    		end)

    		while not Finished do
    			if tick() - Start > Options.ab_RoomsAutoWalkPathfindTimeout.Value then
    				local StuckBlock = Instance.new("Part", Globals.RoomsNodesFolder)
    				StuckBlock.Transparency = 1
    				StuckBlock.Size = Vector3.one
    				StuckBlock.CFrame = Collision.CFrame
    				StuckBlock.Shape = Enum.PartType.Ball
    				StuckBlock.CanCollide = false
    				StuckBlock.Anchored = true
    				StuckBlock.Name = "StuckPart"
    				local Modifier = Instance.new("PathfindingModifier", StuckBlock)
    				Modifier.Label = "StuckPart"
    				Stuck = true
    				break
    			end
    			task.wait()
    		end
    		StepConnection:Disconnect()
    		Humanoid:MoveTo(RootPart.Position)
    	end

    	Globals.RoomsAutoWalkActive = false
    end)

    Connections.RoomsHandler = CurrentRooms.ChildAdded:Connect(function(Room)
    	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
    		if Object.Name == "StuckPart" then Object:Destroy() end
    	end

    	if Room:GetAttribute("RawName") and string.find(Room:GetAttribute("RawName"), "Eyestalk") then
            local PreviousNode = nil

    		local function CreateEyestalkNode(WaypointPos)
    			local NewNode = Instance.new("Part")
    			NewNode.Size = Vector3.one
    			NewNode.Transparency = 1
    			NewNode.Parent = Globals.SeekNodesFolder
    			NewNode.Anchored = true
    			NewNode.Position = WaypointPos
    			NewNode.CanCollide = false
    			NewNode.Name = "SeekLightNode"

    			local PrevNode = PreviousNode or NewNode
    			PreviousNode = NewNode

    			local NewBeam = Instance.new("Beam")
    			NewBeam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Options.ab_ShowEyestalkPathColor.Value), ColorSequenceKeypoint.new(1, Options.ab_ShowEyestalkPathColor.Value) })
    			NewBeam.FaceCamera = true
    			NewBeam.Width0 = 0.2
    			NewBeam.Width1 = 0.2
    			NewBeam.Brightness = 10
    			NewBeam.LightInfluence = 0
    			NewBeam.LightEmission = 0
    			NewBeam.Enabled = true

    			local Vis = Toggles.ab_ShowEyestalkPathToggle.Value and 0 or 1
    			NewBeam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, Vis), NumberSequenceKeypoint.new(1, Vis) })
    			NewBeam.Parent = Globals.SeekNodesFolder

    			local A0 = Instance.new("Attachment", NewNode)
    			local A1 = Instance.new("Attachment", PrevNode)
    			NewBeam.Attachment0 = A0
    			NewBeam.Attachment1 = A1

    			table.insert(Objects.EyestalkHighlights, NewBeam)
    		end

    		Room:WaitForChild("RoomEntrance", 9e9)
    		Room:WaitForChild("RoomExit", 9e9)

    		while not Room:GetAttribute("PathFound") do
    			if Toggles.ab_ShowEyestalkPathToggle.Value then
    				local EyePath = game:GetService("PathfindingService"):CreatePath({
    					AgentCanJump = false, AgentCanClimb = false, WaypointSpacing = 2, AgentRadius = 1, AgentHeight = 1
    				})
    				EyePath:ComputeAsync(RootPart.Position, Room.RoomExit.Position)
    				if EyePath.Status == Enum.PathStatus.Success then
    					Room:SetAttribute("PathFound", true)
    					for _, Waypoint in EyePath:GetWaypoints() do
    						CreateEyestalkNode(Waypoint.Position)
    						task.wait()
    					end
                        break
    				end
    			end
    			task.wait(0.25)
    		end
    	end
    end)

    Groupboxes.Floors_Completion = Tabs.Floors:AddRightGroupbox("Completion")
    Groupboxes.Floors_Completion:AddButton({
        Text = "Auto Complete Dam Seek",
        Tooltip = "Automatically teleports to and interacts with each water pump.",
        Func = function()
            if LatestRoom.Value < 100 or Floor ~= "Mines" then
                Functions.Notify({Title = "You must be in Room 200 to do this."})
                return
            end

    		local IsCutscene = false
    		local CutsceneConnection = RemotesFolder.Cutscene.OnClientEvent:Connect(function()
    			IsCutscene = true
    			task.wait(7)
    			IsCutscene = false
    		end)

            local function GetNextPump()
                local Highest = {
                    Height = -69420,
                    Object = nil
                }
                for _, Object in pairs(Objects.Objectives) do
                    if Object.Name == "WaterPump" and Object:GetAttribute("Abysall_Completed") ~= true then
                        if Object.PrimaryPart and Object.PrimaryPart.Position.Y > Highest.Height then
                            Highest.Object = Object
                            Highest.Height = Object.PrimaryPart.Position.Y
                        end
                    end
                end
                return Highest.Object
            end

            local function HandlePump(Pump)

                while task.wait(0.1) do
    				if IsCutscene then
    					continue
    				end

                    Character:PivotTo(Pump:GetPivot())

                    local Prompt = Pump:FindFirstChild("ValvePrompt", true)
                    if Prompt then
                        Functions.ForceFirePrompt(Prompt)
                    end

                    if Pump:GetAttribute("Abysall_Completed") then
                        break
                    end
                end
            end

            Functions.Notify({Title = "Attempting to complete the valves.", Body = "Please wait."})
            while task.wait(0.1) do
                local Pump = GetNextPump()
                if Pump then
                    HandlePump(Pump)
                else
                    break
                end
            end
            Functions.Notify({Title = "Successfully completed the valves."})
        end
    })

    Groupboxes.Floors_Completion:AddButton({
        Text = "Auto Complete Cringle",
        Tooltip = "Instantly completes the quest.",
        Func = function()
            local TouchPart = CurrentRooms:FindFirstChild("RippleExitDoor", true)
            if TouchPart then
                Character:PivotTo(TouchPart:GetPivot())
            end
        end
    })

    Groupboxes.Floors_Visuals = Tabs.Floors:AddLeftGroupbox("Visuals")
    Groupboxes.Floors_Visuals:AddToggle("ab_ShowSeekPathToggle", {
    	Text = "Show Seek Path", Default = false, Tooltip = "Shows you the correct path in seek chases.",
    	Risky = Floor ~= "Mines"
    })
    Toggles.ab_ShowSeekPathToggle:AddColorPicker("ab_ShowSeekPathColor", { Text = "Seek Path", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })

    local function UpdateBeamVisibility(BeamTable, ColorKey, Visible)
    	local Vis = Visible and 0 or 1
    	local Seq = NumberSequence.new({ NumberSequenceKeypoint.new(0, Vis), NumberSequenceKeypoint.new(1, Vis) })
    	for _, Beam in BeamTable do Beam.Transparency = Seq end
    end
    local function UpdateBeamColor(BeamTable, Value)
    	local Seq = ColorSequence.new({ ColorSequenceKeypoint.new(0, Value), ColorSequenceKeypoint.new(1, Value) })
    	for _, Beam in BeamTable do Beam.Color = Seq end
    end

    Toggles.ab_ShowSeekPathToggle:OnChanged(function(V)  UpdateBeamVisibility(Objects.SeekHighlights, "ShowSeekPathColor", V) end)
    Options.ab_ShowSeekPathColor:OnChanged(function(V)   UpdateBeamColor(Objects.SeekHighlights, V) end)

    Groupboxes.Floors_Visuals:AddToggle("ab_ShowEyestalkPathToggle", {
    	Text = "Show Eyestalk Path", Default = false, Tooltip = "Shows you the correct path in the eyestalk chase.",
    	Risky = Floor ~= "Garden"
    })
    Toggles.ab_ShowEyestalkPathToggle:AddColorPicker("ab_ShowEyestalkPathColor", { Text = "Eyestalk Path", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })
    Toggles.ab_ShowEyestalkPathToggle:OnChanged(function(V) UpdateBeamVisibility(Objects.EyestalkHighlights, "ShowEyestalkPathColor", V) end)
    Options.ab_ShowEyestalkPathColor:OnChanged(function(V)  UpdateBeamColor(Objects.EyestalkHighlights, V) end)

    Groupboxes.Floors_Bypass = Tabs.Floors:AddLeftGroupbox("Bypass")
    Groupboxes.Floors_Bypass:AddToggle("ab_RemoveSeekTrigger", {
    	Text = "Delete Seek Trigger", Default = false, Tooltip = "Diables the 'Seek' chase trigger.",
    	Risky = not (Floor == "Fools" or Floor == "OldHotel"),
    	Disabled = not Functions.CheckCompatability({"firetouchinterest"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Floors_Bypass:AddToggle("ab_RemoveFigure", {
    	Text = "Delete Figure", Default = false, Tooltip = "Completely removes the entity 'Figure' (doesn't always work).",
    	Risky = not (Floor == "Fools" or Floor == "OldHotel" or Floor == "Mines"),
    	Disabled = not Functions.CheckCompatability({"isnetworkowner"}), DisabledTooltip = Globals.IncompatibleMessage
    })
    Groupboxes.Floors_Bypass:AddToggle("ab_AutoRevive", {
    	Text = "Infinite Revives", Default = false, Tooltip = "Automatically revives after dying, with unlimited respawns.",
    	Risky = not (Floor == "Fools" or Floor == "OldHotel")
    })
    Groupboxes.Floors_Bypass:AddToggle("ab_FigureGodmode", {
    	Text = "Figure Godmode", Default = false, Tooltip = "Prevents 'Figure' from hurting you.",
    	Risky = not (Floor == "Fools" or Floor == "OldHotel")
    })
    Groupboxes.Floors_Bypass:AddDivider()
    Groupboxes.Floors_Bypass:AddToggle("ab_RemoveBasementGate",  { Text = "Remove Basement Gate",   Default = false, Tooltip = "Removes the gate from basement rooms.",            Risky = not (Floor == "Fools" or Floor == "OldHotel") })
    Groupboxes.Floors_Bypass:AddToggle("ab_RemovePaintingsDoor", { Text = "Remove Paintings Door",  Default = false, Tooltip = "Removes the fireplace doors from painting rooms.", Risky = not (Floor == "Fools" or Floor == "OldHotel") })
    Groupboxes.Floors_Bypass:AddToggle("ab_RemoveSkeletonDoor",  { Text = "Remove Skeleton Door",   Default = false, Tooltip = "Removes the skeleton door from the infirmary.",    Risky = Floor ~= "Fools" })

    local ObstructionNames = { ThingToOpen = "RemoveBasementGate", MovingDoor = "RemovePaintingsDoor", Wax_Door = "RemoveSkeletonDoor" }
    for ObjName, ToggleName in ObstructionNames do
    	Toggles[ToggleName]:OnChanged(function(Value)
    		for _, Object in Objects.Obstructions do
    			if Object.Name == ObjName then
    				Object:PivotTo(Value and CFrame.new(-10000, -10000, -10000) or Object:GetAttribute("OriginalPosition"))
    			end
    		end
    	end)
    end

    Groupboxes.Floors_Farming = Tabs.Floors:AddLeftGroupbox("Farming")
    Groupboxes.Floors_Farming:AddToggle("ab_KnobFarm", {
        Text = "Knob Farm",
        Default = false,
        Tooltip = "Automatically gains knobs for you, dies and revives repeatedly.",
    	Risky = Floor ~= "Ballz",
    })

    Groupboxes.Floors_Farming:AddButton({
        Text = "Start Knob Farm",
        Tooltip = "Starts farming knobs, click this when you have enough gold.",
        Func = function()
    		if LatestRoom.Value ~= 0 then
    			Functions.Notify({Title = "You must be in Room 0 to use this."})
    			return
    		end

    		if LocalPlayer.PlayerGui:FindFirstChild("TopbarUI") then 
    			local GoldCount = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal
    			if GoldCount.Value <= 0 then
    				Functions.Notify({Title = "You must have gold to do this."})
    				return
    			end
    		end

            Globals.KnobFarmStarted = true
        end
    })

    Groupboxes.Floors_Farming:AddDivider()
    Groupboxes.Floors_Farming:AddButton({
    	Text = "Start Death Farm",
    	DoubleClick = true,
    	Tooltip = "Automatically farms deaths, joining new runs.",
    	Func = function()
    		loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Scripts/DeathFarm.luau"))()
    	end,

    	Disabled = not Functions.CheckCompatability({"fireproximityprompt", "firesignal"}),
    	DisabledTooltip = Globals.ImcompatibleMessage
    })
    Groupboxes.Floors_Farming:AddButton({
    	Text = "Copy Death Farm Loadstring",
    	DoubleClick = false,
    	Tooltip = "Copies the death farm loadstring to your clipboard.",
    	Func = function()
    		-- Not every executor ships toclipboard; the button used to error and look dead.
    		local Copied = pcall(function()
    			toclipboard([==[
    				loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Scripts/DeathFarm.luau"))()
    			]==])
    		end)
    		Library:Notify(Copied and "Loadstring has been copied to your clipboard." or "This executor has no toclipboard.")
    	end,

    	Disabled = not Functions.CheckCompatability({"fireproximityprompt", "firesignal"}),
    	DisabledTooltip = Globals.ImcompatibleMessage
    })

    Toggles.ab_KnobFarm:OnChanged(function(Value)
        if Value then
            Functions.Notify({Title = "Please collect some gold to earn knobs.", Body = "Click 'Start Knob Farm' when you're ready."})
    	else
    		Globals.KnobFarmStarted = false
        end
    end)

    Globals.KnobFarmActive = false
    Globals.KnobFarmStarted = false
    -- Knob farm has to do what the run actually rewards, in the order the game expects:
    -- claim the room reward, die, wait for Alive to come back, then ask for a new run.
    -- The old body claimed nothing, waited for Alive to be *true* instead of waiting for
    -- it to come back (it was still true on the frame the kill was sent, so the wait
    -- broke instantly), and never fired PlayAgain -- so the character just lay dead on
    -- the death screen. That is the "knob farm mati" report.
    Connections.KnobFarm = Services.RunService.Heartbeat:Connect(function()
    	if Toggles.ab_KnobFarm.Value and Globals.KnobFarmStarted then
    		if not Globals.KnobFarmActive then
    			Globals.KnobFarmActive = true
    			-- 1. claim. Guarded: this remote is not in every remotes layout.
    			pcall(function()
    				if RemotesFolder and RemotesFolder:FindFirstChild("Statistics") then
    					RemotesFolder.Statistics:FireServer()
    				end
    			end)
    			-- 2. die.
    			if Functions.CheckCompatability({"replicatesignal"}) then
    				pcall(Abysall.Environment.replicatesignal, LocalPlayer.Kill)
    			end
    			pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
    			-- 3. wait for Alive to come back, then 4. ask for the next run. Attempt-capped
    			-- on purpose: a long clock budget here polls for seconds and starves every other
    			-- frame-driven feature. A missed flip costs one cycle; the loop retries.
    			task.spawn(function()
    				for _ = 1, 30 do
    					if LocalPlayer:GetAttribute("Alive") == true then break end
    					task.wait(0.15)
    				end
    				pcall(function()
    					if RemotesFolder and RemotesFolder:FindFirstChild("PlayAgain") then
    						RemotesFolder.PlayAgain:FireServer()
    					end
    				end)
    				task.wait(0.5)
    				Globals.KnobFarmActive = false
    			end)
    		end
    	end
    end)

    local MainHook
    local OtherHook
    if Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}) then
    	MainHook = Abysall.Environment.hookmetamethod(game, "__namecall", Abysall.Environment.newcclosure(function(Self, ...)
    		local Args = { ... }
    		if Abysall and Abysall.Environment then
    			local Method = Abysall.Environment.getnamecallmethod()

    			if Self.Name == "Crouch" and Method == "FireServer" then
    				if Toggles.ab_CrouchSpoof.Value or Toggles.ab_PositionSpoof.Value then
    					Args[1] = true
    				end
    				Args[2] = true
    			end

    			if Self.Name == "ClutchHeartbeat" and Method == "FireServer" and Toggles.ab_AutoHeartbeatMinigame.Value or Self.Name == "HideMonster" and Method == "FireServer" and Toggles.ab_AutoHeartbeatMinigame.Value then
    				return
    			end

    			if Self.Name == "MotorReplication" and Method == "FireServer" then
    				local DoBypass = (Toggles.ab_BypassEyes.Value and Globals.IsEyes) or (Toggles.ab_BypassLookman.Value and Globals.IsLookman)
    				if DoBypass then
    					if Floor == "Fools" or Floor == "OldHotel" then
    						Args[1] = 0 Args[2] = (Globals.SpoofOffset == 200 and 65 or -65) Args[3] = 0 Args[4] = false
    					else
    						Args[1] = -650
    					end
    				end
    			end
    		end
    		return MainHook(Self, table.unpack(Args))
    	end))

        OtherHook = Abysall.Environment.hookmetamethod(game, "__index", Abysall.Environment.newcclosure(function(Self, Property)
            local Real = OtherHook(Self, Property)

            if Property == "MoveDirection" and Self == Humanoid and Globals.RoomsAutoWalkActive and Toggles.ab_RoomsAutoWalkSpoofFootsteps.Value and Floor == "Rooms" and not Character:GetAttribute("Hiding") then
                return RootPart.CFrame.LookVector
            end
        
            return Real
        end))
    end

    if Services.ReplicatedStorage:FindFirstChild("ModulesClient") then
    	ClientModules = Services.ReplicatedStorage.ModulesClient
    else
    	ClientModules = Services.ReplicatedStorage.ClientModules
    end

    Modules = {
    	Glitch         = ClientModules.EntityModules.Glitch,
    	Shade          = ClientModules.EntityModules.Shade,
    	Void           = ClientModules.EntityModules:FindFirstChild("Void"),
    	SpiderJumpscare = nil,
    	A90            = nil,
    	Screech        = nil,
    	Dread          = nil,
    	GlitchScreech  = nil,
    }

    local CharacterOldConnectionKeys = {
    	"MainHandler", "JumpHandler", "SlideHandler", "LibraryCodeHandler1", "LibraryCodeHandler2",
    	"OxygenConnection", "AnimationHandler", "AutoHideConnection", "AutoReviveHandler",
    	"SHMFixer", "AnticheatDisabler", "AnticheatEnableDetector1", "AnticheatEnableDetector2",
    	"AutoSteerMinecartDuckHandler", "AutoSolveAnchorsConnection", "InfiniteJumpsConnection1", "InfiniteJumpsConnection2",
    	"FootstepHandler"
    }

    Globals.IsTyping = false
    Connections.TextBoxConnection1 = Services.UserInputService.TextBoxFocused:Connect(function()
    	Globals.IsTyping = true
    end)
    Connections.TextBoxConnection2 = Services.UserInputService.TextBoxFocusReleased:Connect(function()
    	Globals.IsTyping = false
    end)

    Functions.HandleCharacter = function(NewCharacter)
    	for _, Key in CharacterOldConnectionKeys do
    		if Connections[Key] then
    			Connections[Key]:Disconnect()
    			Connections[Key] = nil
    		end
    	end

    	-- No blocking wait. The old loop parked here until PlayerGui.MainUI appeared, and
    	-- when the folder never came (slow mobile join, or the game simply does not ship
    	-- one) it starved every connection below it: door scan, entity handlers, the ESP
    	-- feed. The menu still opened, so it read as "ESP dead, half the toggles dead".
    	-- Resolve what is there now and let a late folder arrive in the background.

    	Character = NewCharacter
    	Humanoid = NewCharacter:WaitForChild("Humanoid", 20) or NewCharacter:FindFirstChildOfClass("Humanoid")
    	if not Humanoid then
    		warn("[Reicht] character has no Humanoid yet; character features stay off")
    		return
    	end
    	RootPart = NewCharacter:FindFirstChild("HumanoidRootPart")
    	Camera   = Services.Workspace.CurrentCamera

    	Globals.OldCamera = Camera
    	Globals.MainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
    	if not Globals.MainUI then
    		warn("[Reicht] MainUI absent; game-UI extras stay off, everything else runs")
    		task.spawn(function()
    			for _ = 1, 40 do
    				task.wait(0.25)
    				local Late = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
    				if Late then Globals.MainUI = Late break end
    			end
    		end)
    	end

    	Collision = NewCharacter:WaitForChild("Collision")
    	CollisionPart  = NewCharacter:FindFirstChild("CollisionPart") or NewCharacter:FindFirstChild("Collision")
    	CollisionClone = Collision:Clone()
    	CollisionClone.Parent = NewCharacter
    	CollisionClone.Name = "CollisionClone"
    	CollisionClone.Massless = true

    	CollisionPartClone = CollisionPart:Clone()
    	CollisionPartClone.Parent = NewCharacter
    	CollisionPartClone.Name = "CollisionPartClone"
    	CollisionPartClone.CanCollide = false
    	CollisionPartClone.Massless = true

    	if CollisionPartClone:FindFirstChild("CollisionCrouch") then
    		CollisionPartClone.CollisionCrouch:Destroy()
    	end

    	Character:SetAttribute("SpeedBoost", 0)
    	Character:SetAttribute("SpeedBoostBehind", 0)
    	Character:SetAttribute("SpeedBoostExtra", 0)

    	OldJump  = NewCharacter:GetAttribute("CanJump")
    	OldSlide = NewCharacter:GetAttribute("CanSlide")

    	if Toggles.ab_EnableCharacterJump.Value  then Character:SetAttribute("CanJump",  true) end
    	if Toggles.ab_EnableCharacterSlide.Value then Character:SetAttribute("CanSlide", true) end

    	if Globals.MainUI and Functions.CheckCompatability({"require"}) then
    		Main_Game = Safe(function() return Abysall.Environment.require(Globals.MainUI.Initiator.Main_Game) end)
    	end

    	if Main_Game and Toggles.ab_RemoveCameraBobbing.Value then
    		Main_Game.spring.Speed = 9e9
    	end

    	if Main_Game and Functions.CheckCompatability({"require"}) then
    		local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
    		local OriginalGetMoveVector = Controls.GetMoveVector
    		Globals.OriginalGetMoveVector = OriginalGetMoveVector
    		Controls.GetMoveVector = function(...)
    			if Toggles.ab_AutoSteerMinecart.Value and Floor == "Mines" then
    				local Node = Globals.NearestTurnNode
    				if Node and Functions.GetMinecart() then
    					local Turn = Node:GetAttribute("Turn")
    					return Turn == "Left" and Vector3.new(-1, 0, 0) or Turn == "Right" and Vector3.new(1, 0, 0) or Vector3.zero
    				end
    			end
    			return OriginalGetMoveVector(...)
    		end
    	end

    	Globals.AutoMinecartDucked = false
    	Globals.LastDuck = tick()
    	Connections.AutoSteerMinecartDuckHandler = Services.RunService.Heartbeat:Connect(function()
    		if not Toggles.ab_AutoSteerMinecart.Value or not Functions.GetMinecart() or tick() - Globals.LastDuck < 0.1 then return end
    		Globals.NearestTurnNode = Functions.GetNearestTurnNode()

    		if not Globals.AutoMinecartDucked and Functions.GetNearestDuckBoard() then
    			Main_Game.crouch(true)
    			Globals.AutoMinecartDucked = true
    		elseif not Functions.GetNearestDuckBoard() and Globals.AutoMinecartDucked then
    			Main_Game.crouch(false)
    			Globals.AutoMinecartDucked = false
    		end
    		if Main_Game then
    			Main_Game.fovtarget = Options.ab_FieldOfView.Value
    		else
    			Camera.FieldOfView = Options.ab_FieldOfView.Value
    		end
    		Globals.LastDuck = tick()
    	end)

    	Globals.AnticheatDisabled = false

    	-- UIModules lives inside the game's own MainUI. When MainUI is absent the first
    	-- index here used to throw and take the rest of the layer with it.
    	local UIModules = Safe(function() return Globals.MainUI.Initiator.Main_Game.RemoteListener.Modules end)
    	if UIModules then
    		Modules.A90             = UIModules:FindFirstChild("A90")
    		Modules.Screech         = UIModules:FindFirstChild("Screech")
    		Modules.Dread           = UIModules:FindFirstChild("Dread")
    		Modules.SpiderJumpscare = UIModules:FindFirstChild("SpiderJumpscare")
    	end

    	if Toggles.ab_RemoveScreech.Value and Modules.Screech then Modules.Screech.Name = "Screech_Disabled" end
    	if Toggles.ab_RemoveA90.Value and Modules.A90   then Modules.A90.Name = "A90_Disabled" end
    	if Toggles.ab_RemoveDread.Value and Modules.Dread then Modules.Dread.Name = "Dread_Disabled" end
    	if Toggles.ab_DisableTimothyJumpscare.Value and Modules.SpiderJumpscare then Modules.SpiderJumpscare.Name = "SpiderJumpscare_Disabled" end

    	if Globals.MainUI and Toggles.ab_DisableHideVignette.Value then
    		local Vignette = Safe(function() return Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette") end)
    		if Vignette then Vignette.Image = "Disabled" end
    	end
    	if Globals.MainUI and Toggles.ab_RemoveInteractingSounds.Value then
    		local PS = Globals.MainUI.Initiator.Main_Game.PromptService
    		PS.Triggered.Volume = 0
    		PS.Holding.Volume   = 0
    		PS.Notification.Volume = 0
    		Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = 0
    	end
    	if Globals.MainUI and Toggles.ab_DisableEntityJumpscares.Value then
    		local JS = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
    		if JS then JS.Name = "Jumpscares_Disabled" end
    	end
        local Cutscenes = Safe(function() return Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes end)
        for _, Object in pairs(Cutscenes and Cutscenes:GetChildren() or {}) do
            if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") then
                Object:SetAttribute("OriginalName", Object.Name)
                if Toggles.ab_RemoveCutscenes.Value then
                    Object.Name = Object.Name .. "_Disabled"
                end
            end
        end
        for _, Object in pairs(FloorReplicated:GetChildren()) do
            if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") then
                Object:SetAttribute("OriginalName", Object.Name)
                if Toggles.ab_RemoveCutscenes.Value then
                    Object.Name = Object.Name .. "_Disabled"
                end
            end
        end

    	CustomPhysics = PhysicalProperties.new(
    		100,
    		RootPart.CustomPhysicalProperties.Friction,
    		RootPart.CustomPhysicalProperties.Elasticity,
    		RootPart.CustomPhysicalProperties.FrictionWeight,
    		RootPart.CustomPhysicalProperties.ElasticityWeight
    	)
    	for _, Part in NewCharacter:GetDescendants() do
    		if Part:IsA("BasePart") then
    			PartProperties[Part] = Part.CustomPhysicalProperties
    			if Toggles.ab_RemoveAcceleration.Value then
    				Part.CustomPhysicalProperties = CustomPhysics
    			end
    		end
    	end

    	Connections.LibraryCodeHandler1 = LocalPlayer.PlayerGui.PermUI.Hints.ChildAdded:Connect(function()
    		if Toggles.ab_NotifyLibraryCode.Value then
    			local Code = Functions.GetLibraryCode()
    			if Code and not Code:find("_") and not Globals.LibraryCodeFound then
    				local Lock = Services.Workspace:FindFirstChild("Padlock", true)
    				Functions.Notify({ Title = "Padlock code found!", Body = "The code is: '" .. Code .. "'", Time = Toggles.ab_NotifyKeepNotifications.Value and Lock or 15 })
    				Globals.LibraryCodeFound = true
    			end
    		end
    	end)

    	Connections.LibraryCodeHandler2 = Character.ChildAdded:Connect(function(Child)
    		if (Child.Name == "LibraryHintPaper" or Child.Name == "LibraryHintPaperHard") and Toggles.ab_NotifyLibraryCode.Value then
    			local Code = Functions.GetLibraryCode()
    			if Code and not Code:find("_") and not Globals.LibraryCodeFound then
    				local Lock = Services.Workspace:FindFirstChild("Padlock", true)
    				Functions.Notify({ Title = "Padlock code found!", Body = "The code is: '" .. Code .. "'", Time = Toggles.ab_NotifyKeepNotifications.Value and Lock or 15 })
    				Globals.LibraryCodeFound = true
    			end
    		end
    	end)

    	Connections.FootstepHandler = Character.ChildAdded:Connect(function(Object)
    		if Object:IsA("Sound") and Object.Name == "Sound" and Toggles.ab_RemoveFootstepSounds.Value then
    			Object.Volume = 0
    		end
    	end)

    	Globals.OldOxygen = Character:GetAttribute("Oxygen")
    	Connections.OxygenConnection = Character:GetAttributeChangedSignal("Oxygen"):Connect(function()
    		local NewOxy = Character:GetAttribute("Oxygen")
    		if NewOxy < Globals.OldOxygen and Toggles.ab_NotifyOxygen.Value then
    			Functions.Caption(Functions.FormatOxygen(NewOxy), true)
    		end
    		Globals.OldOxygen = NewOxy
    	end)

    	Connections.AutoReviveHandler = LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    		if LocalPlayer:GetAttribute("Alive") == false and Toggles.ab_AutoRevive.Value then
    			if Floor == "Fools" or Floor == "OldHotel" then
    				while LocalPlayer:GetAttribute("Alive") ~= true do
    					RemotesFolder.Revive:FireServer()
    					task.wait(0.5)
    				end
    			end
    		end
    	end)

    	Connections.SHMFixer = RootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
    		task.wait()
    		if Floor == "Fools" and RootPart.Anchored and Character:GetAttribute("Hiding") ~= true then
    			RootPart.Anchored = false
    		end
    	end)

    	Connections.AnticheatDisabler = Character:GetAttributeChangedSignal("Climbing"):Connect(function()
    		if Character:GetAttribute("Climbing") == true and Toggles.ab_DisableAnticheat.Value and not Globals.AnticheatDisabled then
    			task.wait(0.25)
    			Character:SetAttribute("Climbing", false)
    			Functions.Notify({ Title = "Successfully disabled the anticheat.", Body = "It will be re-enabled after a cutscene or halt room." })
    			Globals.AnticheatDisabled = true
    		end
    	end)

    	Connections.AnticheatEnableDetector1 = RemotesFolder:WaitForChild("Cutscene").OnClientEvent:Connect(function(CutsceneName)
    		if Globals.AnticheatDisabled and not CutsceneName:find("SewerSeek") then
    			Globals.AnticheatDisabled = false
    			Functions.Notify({ Title = "The anticheat has been re-enabled.", Body = "Interact with a ladder to disable it again." })
    		end
    	end)

    	Connections.AnticheatEnableDetector2 = RemotesFolder:WaitForChild("UseEnemyModule").OnClientEvent:Connect(function(ModuleName)
    		if ModuleName == "Void" or ModuleName == "Glitch" then
    			if Globals.AnticheatDisabled then
    				Globals.AnticheatDisabled = false
    				Functions.Notify({ Title = "The anticheat has been re-enabled.", Body = "Interact with a ladder to disable it again." })
    			end
    			LocalPlayer:SetAttribute("CurrentRoom", LatestRoom.Value)
    		end
    	end)

    	Connections.AnimationHandler = Character.ChildAdded:Connect(function()
    		local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    		local Tool
    		for _, Name in ToolNames do
    			Tool = Character:FindFirstChild(Name)
    			if Tool then break end
    		end
    		if not Tool then return end

    		local UseAnim = Tool:FindFirstChild("use", true) or Tool:FindFirstChild("promptanim", true)
    		if UseAnim then
    			UseAnim = Humanoid:LoadAnimation(UseAnim)
    			UseAnim.Priority = Enum.AnimationPriority.Action4
    			Globals.UseAnimation = UseAnim
    		end
    		local UseAnimBreak = Tool:FindFirstChild("usefinish", true) or Tool:FindFirstChild("promptanimend", true) or Tool:FindFirstChild("lockpickuse", true)
    		if UseAnimBreak then
    			UseAnimBreak = Humanoid:LoadAnimation(UseAnimBreak)
    			UseAnimBreak.Priority = Enum.AnimationPriority.Action4
    			Globals.UseAnimationBreak = UseAnimBreak
    		end
    	end)

    	Connections.JumpHandler = Character:GetAttributeChangedSignal("CanJump"):Connect(function()
    		local Val = Character:GetAttribute("CanJump")
    		if Toggles.ab_EnableCharacterJump.Value and Val ~= true or not Toggles.ab_EnableCharacterJump.Value then
    			OldJump = Val
    		end
    		if Toggles.ab_EnableCharacterJump.Value then Character:SetAttribute("CanJump", true) end
    	end)

    	Connections.SlideHandler = Character:GetAttributeChangedSignal("CanSlide"):Connect(function()
    		local Val = Character:GetAttribute("CanSlide")
    		if Toggles.ab_EnableCharacterSlide.Value and Val ~= true or not Toggles.ab_EnableCharacterSlide.Value then
    			OldSlide = Val
    		end
    		if Toggles.ab_EnableCharacterSlide.Value then Character:SetAttribute("CanSlide", true) end
    	end)

    	Connections.InfiniteJumpsConnection1 = Services.UserInputService.InputBegan:Connect(function(Input)
    		if Input.KeyCode == Enum.KeyCode.Space and Toggles.ab_InfiniteJumps.Value and not Globals.IsTyping then
    			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    		end
    	end)

    	local JumpButton = Safe(function() return Globals.MainUI.MainFrame.MobileButtons:FindFirstChild("JumpButton") end)
    	if JumpButton then
    		Connections.InfiniteJumpsConnection2 = JumpButton.MouseButton1Down:Connect(function()
    			if Toggles.ab_InfiniteJumps.Value then
    				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    			end
    		end)
    	end

    	Globals.SpoofOffset = 0
    	Globals.LastAutoHide = tick()
    	Connections.AutoHideConnection = Services.RunService.Heartbeat:Connect(function()
    		if not Toggles.ab_AutoClosetToggle.Value or tick() - Globals.LastAutoHide <= 0.1 then
    			Globals.AutoClosetActive = false
    			return
    		end
    		local Entity = Functions.GetNearestEntity(true, Options.ab_AutoClosetEntityList.Value)
    		local EntityNearby = Entity and LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position) <= (EntityDistances[Entity.Name] or 150)
    		if Character:GetAttribute("Hiding") == true then
    			Globals.AutoClosetActive = false
    			Globals.SpectateEntity = nil
    			if not EntityNearby then
    				RemotesFolder.CamLock:FireServer()
    			end
    			Globals.LastAutoHide = tick()
    			return
    		end
    		if not Entity then
    			Globals.SpectateEntity = nil
    			Globals.AutoClosetActive = false
    			Globals.LastAutoHide = tick()
    			return
    		end
    		if not EntityNearby then
    			Globals.SpectateEntity = nil
    			Globals.AutoClosetActive = false
    			Globals.LastAutoHide = tick()
    			return
    		end
    		local Closet = Functions.GetNearestHidingSpot()
    		if Character:GetAttribute("Hiding") ~= true and Closet then
    			local Prompt = Closet:FindFirstChild("HidePrompt")
    				or Closet:FindFirstChild("HidingPrompt")
    				or Closet:FindFirstChild("HidePrompt", true)
    				or Closet:FindFirstChild("HidingPrompt", true)

    			if not Prompt then
    				for _, Child in Closet:GetDescendants() do
    					if (Child:IsA("ProximityPrompt") or Child:IsA("InteractPrompt"))
    						and (Child.Name == "HidePrompt" or Child.Name == "HidingPrompt")
    					then
    						Prompt = Child
    						break
    					end
    				end
    			end

    			if Prompt then
    				Globals.AutoClosetActive = true
    				Functions.ForceFirePrompt(Prompt)
    			end
    		end
    		if Character:GetAttribute("Hiding") then
    			if Toggles.ab_SpectateEntityToggle.Value and Entity.PrimaryPart then
    				Globals.SpectateEntity = Entity
    			end
    		end
    		Globals.LastAutoHide = tick()
    	end)

    	Globals.LastAutoAnchor = tick()
    	Connections.AutoSolveAnchorsConnection = Services.RunService.Heartbeat:Connect(function()
    		if not Toggles.ab_AutoSolveAnchors.Value then return end
    		if not Globals.MainUI:FindFirstChild("AnchorHintFrame") then return end
    		if tick() - Globals.LastAutoAnchor <= 0.1 then return end
    		local Anchor = Functions.GetCurrentAnchor()
    		if Anchor and LocalPlayer:DistanceFromCharacter(Anchor.PrimaryPart.Position) < Anchor.ActivateEventPrompt.MaxActivationDistance and not Anchor:GetAttribute("Activated") then
    			Anchor:WaitForChild("AnchorRemote"):InvokeServer(Globals.MainUI.AnchorHintFrame.Code.Text)
    		end
    		Globals.LastAutoAnchor = tick()
    	end)

    	Globals.ManipulateBody = Instance.new("BodyVelocity")
    	Globals.ManipulateBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    	Globals.FlyBody = Instance.new("BodyVelocity")
    	Globals.FlyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    	Globals.SelfKilled = false
    	Globals.ThirdPersonParts = {}
    	for _, Object in Character:GetDescendants() do
    		if Object:IsA("Accessory") and Object:FindFirstChild("Handle") then
    			table.insert(Globals.ThirdPersonParts, Object.Handle)
    		end
    	end
    	table.insert(Globals.ThirdPersonParts, Character:WaitForChild("Head"))

    	Globals.LastAnimationCheck = tick()
    	Globals.LastCrouchFire = tick()
    	Globals.OriginalC1 = Character.LowerTorso.Root.C1

    	local RayParams = RaycastParams.new()
    	RayParams.FilterType = Enum.RaycastFilterType.Exclude

    	local MainFrame = Globals.MainUI and Globals.MainUI:FindFirstChild("MainFrame")
    	if MainFrame and MainFrame:FindFirstChild("SurgeVignette") then
    		Globals.SurgeFrame = MainFrame.SurgeVignette
    		if Toggles.ab_RemoveSurge.Value then
    			Globals.SurgeFrame.Name = "SurgeVignette_Disabled"
    		end
    	end

    	Connections.MainHandler = Services.RunService.RenderStepped:Connect(function()
    		if Services.Workspace:FindFirstChild("Camera") then
    			Camera = Services.Workspace:FindFirstChild("Camera")
    		end

    		if Toggles.ab_SpeedBoostToggle.Value then
    			Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + Options.ab_SpeedBoostSlider.Value
    		end

    		if Globals.Lagging or (Options.ab_SpeedBoostSlider.Value <= 6 and Options.ab_FlySpeed.Value <= 21) then
    			CollisionPartClone.Massless = true
    		end

    		Globals.IsEyes    = Services.Workspace:FindFirstChild("Eyes") ~= nil or Services.Workspace:FindFirstChild("Lookman") ~= nil
    		Globals.IsLookman = Services.Workspace:FindFirstChild("BackdoorLookman") ~= nil

    		if Toggles.ab_AmbientToggle.Value then
    			Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Ambient = Options.ab_AmbientColor.Value }):Play()
    		end

    		if Main_Game then
    			if Toggles.ab_RemoveCameraShake.Value     then Main_Game.csgo = CFrame.new() end
    			if Toggles.ab_ViewmodelOffsetToggle.Value then
    				Main_Game.tooloffset = Vector3.new(Options.ab_ViewmodelOffsetX.Value, Options.ab_ViewmodelOffsetY.Value, Options.ab_ViewmodelOffsetZ.Value)
    			else
    				Main_Game.tooloffset = Vector3.zero
    			end
    		end

    		if Globals.SelfKilled and Globals.MainUI:FindFirstChild("Statistics") then
    			Globals.MainUI.Statistics.Death.Text = "Died to Abysall Hub"
    		end

    		if Globals.Deathing and Globals.MainUI:FindFirstChild("Statistics") then
    			Globals.MainUI.Statistics.Death.Text = "Died to Verity"
    		end

    		local MainFrame = Globals.MainUI:FindFirstChild("MainFrame")
    		if MainFrame then
    			local Effects = MainFrame.Healthbar:FindFirstChild("Effects")
    			if Effects and Effects:FindFirstChild("Crouching") then
    				Effects.Crouching.Visible = Functions.IsCrouching()
    			end
    		end

    		if (Toggles.ab_CrouchSpoof.Value or Toggles.ab_PositionSpoof.Value) and RemotesFolder:FindFirstChild("Crouch") then
    			RemotesFolder.Crouch:FireServer(true, true)
    		end

    		if Floor ~= "Fools" and Floor ~= "OldHotel" and not Camera:FindFirstChild("MinecartRig") then
    			RootPart.CanCollide = false
    		end

    		for _, Part in Character:GetChildren() do
    			if Part:IsA("BasePart") then Part.CanCollide = false end
    		end

    		if LocalPlayer:GetAttribute("Alive") == true then
    			Services.SoundService:WaitForChild("Main").Volume = 1
    		end

    		if Floor == "OldHotel" or Floor == "Fools" then
    			local SpoofOffset = Toggles.ab_PositionSpoof.Value and Functions.GetNearestEntity() and 200 or Toggles.ab_FigureGodmode.Value and Functions.GetNearestFigure() and 200 or 0
    			Globals.SpoofOffset = SpoofOffset
    			Collision.Position = RootPart.Position + Vector3.new(0, SpoofOffset, 0)
    			Collision.CanCollide = false
    			if Floor == "Fools" then
    				Collision.CollisionCrouch.CanCollide = false
    				CollisionClone.CollisionCrouch.CanCollide = false
    			end
    			RootPart.CanCollide = not (Toggles.ab_NoclipToggle.Value or Toggles.ab_VelocityManipulationToggle.Value)
    		else
    			Collision.CanCollide = false
    			if Collision:FindFirstChild("CollisionCrouch") then Collision.CollisionCrouch.CanCollide = false end

    			if CollisionClone:FindFirstChild("CollisionCrouch") then
    				local IsCrouch = Functions.IsCrouching()
    				CollisionClone.CanCollide = not (Toggles.ab_NoclipToggle.Value or Toggles.ab_VelocityManipulationToggle.Value or IsCrouch)
    				CollisionClone.CollisionCrouch.CanCollide = not (Toggles.ab_NoclipToggle.Value or Toggles.ab_VelocityManipulationToggle.Value or not IsCrouch)
    			else
    				RootPart.CanCollide = not (Toggles.ab_NoclipToggle.Value or Toggles.ab_VelocityManipulationToggle.Value)
    			end

    			if Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild("Root") then
    				Character.LowerTorso.Root.C1 = Globals.OriginalC1 * CFrame.new(0, Toggles.ab_PositionSpoof.Value and -2.346 or 0, 0)
    			end

    			local SpoofY = Toggles.ab_PositionSpoof.Value and 2.328 or 0.18
    			Collision.Position     = RootPart.Position + Vector3.new(0, SpoofY, 0)
    			CollisionPart.Position = RootPart.Position + Vector3.new(0, SpoofY, 0)

    			if Collision:FindFirstChild("CollisionCrouch") and CollisionClone:FindFirstChild("CollisionCrouch") then
    				local CrouchY = Toggles.ab_PositionSpoof.Value and 1.328 or -0.982
    				Collision.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, CrouchY, 0)
    				CollisionClone.CollisionCrouch.CollisionGroup = Collision.CollisionCrouch.CollisionGroup
    			end
    			if CollisionClone:FindFirstChild("CollisionCrouch") then
    				CollisionClone.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, Toggles.ab_PositionSpoof.Value and 0.75 or -0.982, 0)
    			end
    		end

    		CollisionClone.CollisionGroup = Collision.CollisionGroup
    		CollisionClone.Position = RootPart.Position + Vector3.new(0, Toggles.ab_PositionSpoof.Value and 1.75 or 0.18, 0)

    		if Toggles.ab_VelocityManipulationToggle.Value and Options.ab_VelocityManipulationMode.Value == "Velocity" then
    			Globals.ManipulateBody.Parent = RootPart
    			Globals.ManipulateBody.Velocity = RootPart.CFrame.LookVector * 2.25
    		else
    			Globals.ManipulateBody.Parent = nil
    		end

    		if Toggles.ab_VelocityManipulationToggle.Value and Options.ab_VelocityManipulationMode.Value == "Pivot" and Floor ~= "Fools" and Floor ~= "OldHotel" then
    			Character:PivotTo(Camera:GetPivot() * CFrame.new(0, 0, 2560))
    		end

    		if Toggles.ab_FlyToggle.Value then
    			Globals.FlyBody.Parent = RootPart
    			Globals.FlyBody.Velocity = Functions.GetFlyVelocity() * Options.ab_FlySpeed.Value
    		else
    			Globals.FlyBody.Parent = nil
    		end

    		local DoEyesBypass = (Toggles.ab_BypassEyes.Value and Globals.IsEyes) or (Toggles.ab_BypassLookman.Value and Globals.IsLookman)
    		if DoEyesBypass then
    			if Floor == "Fools" or Floor == "OldHotel" then
    				RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
    			else
    				RemotesFolder.MotorReplication:FireServer(-650)
    			end
    		end

    		if RemotesFolder:FindFirstChild("Crouch") and tick() - Globals.LastCrouchFire > 0.1 then
    			local IsCrouch = Functions.IsCrouching()
    			if Toggles.ab_CrouchSpoof.Value or Toggles.ab_PositionSpoof.Value then IsCrouch = true end
    			RemotesFolder.Crouch:FireServer(IsCrouch, true)
    			Globals.LastCrouchFire = tick()
    		end

    		if tick() - Globals.LastAnimationCheck > 0.1 then
    			local Sliding = false
    			for _, Anim in Humanoid:GetPlayingAnimationTracks() do
    				if Anim.Name == "Slide" then Sliding = true break end
    			end
    			Globals.Sliding = Sliding
    			Globals.LastAnimationCheck = tick()
    		end

    		Character:SetAttribute("Sliding", Globals.Sliding)
    		if Character:GetAttribute("Crouching") ~= Functions.IsCrouching() then
    			Character:SetAttribute("Crouching", Functions.IsCrouching())
    		end

    		RayParams.FilterDescendantsInstances = { Character }
    		local TPOffset = CFrame.new(Options.ab_ThirdPersonOffsetX.Value, Options.ab_ThirdPersonOffsetY.Value, Options.ab_ThirdPersonOffsetZ.Value)
    		local Direction = (Camera.CFrame * TPOffset).Position - Camera.CFrame.Position
    		local WallResult = Services.Workspace:Spherecast(Camera.CFrame.Position, 0.2, Direction, RayParams)

    		if Toggles.ab_ThirdPersonToggle.Value then
    			if Toggles.ab_ThirdPersonWallCheck.Value and WallResult and WallResult.Instance.CanCollide then
    				local NewPos = Camera.CFrame.Position + Direction.Unit * WallResult.Distance
    				Camera.CFrame = CFrame.new(NewPos, NewPos + Camera.CFrame.LookVector)
    			else
    				Camera.CFrame = Camera.CFrame * TPOffset
    			end
    		end

    		for _, Part in Globals.ThirdPersonParts do
    			Part.Transparency = Toggles.ab_ThirdPersonToggle.Value and 0 or 1
    			Part.LocalTransparencyModifier = Toggles.ab_ThirdPersonToggle.Value and 0 or 1
    		end

    		if Globals.SpectateEntity and Toggles.ab_AutoClosetToggle.Value and Toggles.ab_SpectateEntityToggle.Value then
    			local Entity = Globals.SpectateEntity

    			local CamPosition
    			if Options.ab_SpecateEntityMode.Value == "Player to Entity" then
    				CamPosition = CFrame.lookAt(Character.Head.Position, Entity.PrimaryPart.Position)
    			else
    				CamPosition = CFrame.lookAt(Entity.PrimaryPart.Position, Character.Head.Position)
    			end

    			Camera.CFrame = CamPosition
    		end

    		if Toggles.ab_FOVToggle.Value then
    			if Main_Game then
    				task.wait()
    				Main_Game.fovtarget = Options.ab_FieldOfView.Value
    			else
    				Camera.FieldOfView = Options.ab_FieldOfView.Value
    			end
    		end

    		if Toggles.ab_RemoveClosetDelay.Value
    			and Humanoid.MoveDirection ~= Vector3.zero
    			and (CollisionPart.Anchored or RootPart.Anchored)
    			and Character:GetAttribute("AnimatingClient") ~= true
    			and Character:GetAttribute("Hiding") == true
    		then
    			RemotesFolder.CamLock:FireServer()
    		end

    		local ClosestPlayer = { Distance = math.huge, Object = nil }
    		for _, Player in Services.Players:GetPlayers() do
    			if Player.Character and Player ~= LocalPlayer then
    				local Root = Player.Character:FindFirstChild("HumanoidRootPart")
    				if Root then
    					local D = (Camera.CFrame.Position - Root.Position).Magnitude
    					if D < ClosestPlayer.Distance then
    						ClosestPlayer.Distance = D
    						ClosestPlayer.Object = Player
    					end
    				end
    			end
    		end
    		if ClosestPlayer.Object and LocalPlayer:GetAttribute("Alive") ~= true then
    			LocalPlayer:SetAttribute("CurrentRoom", ClosestPlayer.Object:GetAttribute("CurrentRoom"))
    		end
    	end)

    	task.wait(1)
    	if Toggles.ab_PositionSpoof.Value and Floor ~= "Fools" and Floor ~= "OldHotel" then
    		RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
    		Humanoid.HipHeight = 0.05
    		RemotesFolder.Crouch:FireServer(true, true)
    	end

    	local Jam = Safe(function() return Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam") end)
    	if Jam and Toggles.ab_RemoveJamminMusic.Value then
    		Jam.Volume = 0
    		Globals.JamMuffle.Enabled = false
    	end
    end

    Functions.HandleHidingTransparency = function(Model)
    	local Parts = {}
    	for _, Part in Model:GetDescendants() do
    		if Part:IsA("BasePart") then
    			Part:SetAttribute("Transparency_Old", Part.Transparency)
    			table.insert(Parts, Part)
    		end
    		if Part.Name == "HiddenPlayer" then
    			local HideConn = Part:GetPropertyChangedSignal("Value"):Connect(function()
    				for _, P in Parts do
    					if P:GetAttribute("Transparency_Old") then
    						Services.TweenService:Create(P, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
    							Transparency = (Part.Value == Character and Toggles.ab_TransparentHidingSpotsToggle.Value)
    								and Options.ab_TransparentHidingSpotsSlider.Value
    								or P:GetAttribute("Transparency_Old")
    						}):Play()
    					end
    				end
    			end)
    			table.insert(Connections, HideConn)
    			Model.Destroying:Once(function()
    				HideConn:Disconnect()
    				local Pos = table.find(Connections, HideConn)
    				if Pos then table.remove(Connections, Pos) end
    			end)
    		end
    	end
    end

    Functions.HandleObject = function(Object)
    	for _, Room in CurrentRooms:GetChildren() do
    		if Object:IsDescendantOf(Room) then
    			Object:SetAttribute("ParentRoom", tonumber(Room.Name))
    			break
    		end
    		task.wait()
    	end

    	if Object.Parent == CurrentRooms then
    		local FiredampVal = Object:GetAttribute("Firedamp")
    		Object:SetAttribute("Firedamp_Old", FiredampVal ~= nil and FiredampVal or false)
    		if Toggles.ab_DisableFiredampEffect.Value then
    			Object:SetAttribute("Firedamp", false)
    		end
    	end

    	local Name = Object.Name

    	if Name == "KeyObtain" then
    		task.spawn(function()
    			task.wait(0.5)
    			if Object.Parent then
    				if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Door Key", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    				table.insert(Objects.Objectives, Object)
    			end
    		end)
    	elseif Name == "ElectricalKeyObtain" then
    		task.spawn(function()
    			task.wait(0.5)
    			if Object.Parent then
    				if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Electrical Key", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    				table.insert(Objects.Objectives, Object)
    			end
    		end)
    	elseif Name == "TimerLever" then
    		task.spawn(function()
    			task.wait(0.5)
    			if Object.Parent then
    				Object:SetAttribute("AddTime", Object.TakeTimer.TextLabel.Text == "01:00" and 60 or 30)
    				if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Time Lever [+" .. Object:GetAttribute("AddTime") .. "s]", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    				pcall(function()
    				do
    					local GateSound = Object:WaitForChild("Main")
    					local SoundToPlay = GateSound and GateSound:FindFirstChild("SoundToPlay")
    					if SoundToPlay and SoundToPlay.Played then
    						SoundToPlay.Played:Once(function()
    							Functions.RemoveESP(Object)
    							Functions.BlacklistESP(Object)
    						end)
    					end
    				end
    				end)
    				table.insert(Objects.Objectives, Object)
    			end
    		end)
    	elseif Name == "StairwellLockpickDoor" then
    		if Toggles.ab_MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Garage Door", Color = Options.ab_MiscESPColor.Value }, true) end
    		table.insert(Objects.Misc, Object)
    	elseif Name == "Mirror" then
    		if Toggles.ab_MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Mirror", Color = Options.ab_MiscESPColor.Value }, true) end
    		table.insert(Objects.Misc, Object)
    	elseif Name == "StairwellFireAlarm" then
    		if Toggles.ab_MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Fire Alarm", Color = Options.ab_MiscESPColor.Value }, true) end
    		table.insert(Objects.Misc, Object)
    	elseif Name == "ShoppingCart" then
    		if Toggles.ab_MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Shopping Cart", Color = Options.ab_MiscESPColor.Value }, true) end
    		table.insert(Objects.Misc, Object)
    	elseif Name == "StairwellScrapper" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Scrapper", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "ArchivesPackageDeposit" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Package Deposit", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "Cellar" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Cellar", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "ArchivesFihTank" then
    		if Toggles.ab_MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Fih Tank", Color = Options.ab_MiscESPColor.Value }, true) end
    		table.insert(Objects.Misc, Object)
    	elseif Name == "LiveHintBook" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Hint Book", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "LiveBreakerPolePickup" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Fuse Breaker", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		for _, Child in Object:GetChildren() do
    			if Child.Name == "ActivateEventPrompt" and (Child.MaxActivationDistance == 5 or Child:GetAttribute("MaxActivationDistance_Old") == 5) then
    				Child:Destroy()
    			end
    		end
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "LibraryHintPaper" or Name == "PickupItem" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Hint Paper", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "MinesAnchor" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Anchor [" .. Object:WaitForChild("Sign").TextLabel.Text .. "]", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		Object:GetAttributeChangedSignal("Activated"):Once(function()
    			Functions.RemoveESP(Object)
    			Functions.BlacklistESP(Object)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "WaterPump" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object:WaitForChild("Wheel"), Text = "Water Pump", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		pcall(function()
    		Object:WaitForChild("Wheel").Sound.Played:Once(function()
    			Object:SetAttribute("Abysall_Completed", true)

    			Functions.RemoveESP(Object.Wheel)
    			Functions.BlacklistESP(Object.Wheel)
    		end)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "CringlePresent" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Present", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		Object:WaitForChild("ToolProp").Highlight:Destroy()
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "LeverForGate" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gate Lever", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		pcall(function()
    		Object:WaitForChild("Main").SoundToPlay.Played:Once(function()
    			Functions.RemoveESP(Object)
    			Functions.BlacklistESP(Object)
    		end)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "VineGuillotine" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object.Lever, Text = "Vine Lever", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		Object.Lever:WaitForChild("ActivateEventPrompt"):GetAttributeChangedSignal("Interactions"):Once(function()
    			Functions.RemoveESP(Object)
    			Functions.BlacklistESP(Object)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "MandrakeLive" then
    		if Toggles.ab_ObjectiveESPToggle.Value and Options.ab_EntityESPOptions.Value["Mandrake Hole"] then Functions.AddESP({ Object = Object.Hole, Text = "Mandrake Hole", Color = Options.ab_EntityESPColor.Value }, true) end
    		table.insert(Objects.Entities, Object.Hole)
    	elseif Name == "MinesGenerator" then
    		task.spawn(function()
    			task.wait(0.75)
    			if Object.Parent then
    				if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Generator", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    				pcall(function()
    				Object:WaitForChild("Lever").Sound.Played:Once(function()
    					Functions.RemoveESP(Object)
    					Functions.BlacklistESP(Object)
    				end)
    				end)
    				table.insert(Objects.Objectives, Object)
    			end
    		end)
    	elseif Name == "FuseObtain" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Generator Fuse", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		Object:WaitForChild("Hitbox").FuseModel:GetPropertyChangedSignal("LocalTransparencyModifier"):Once(function()
    			Functions.RemoveESP(Object)
    			Functions.BlacklistESP(Object)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "MinesGateButton" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gate Button", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		pcall(function()
    		Object.Parent:WaitForChild("MinesGate").Main.SoundOpen.Played:Once(function()
    			Functions.RemoveESP(Object)
    			Functions.BlacklistESP(Object)
    		end)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "GardenGateButton" then
    		if Toggles.ab_ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gate Button", Color = Options.ab_ObjectiveESPColor.Value }, true) end
    		pcall(function()
    		Object.Parent:WaitForChild("GardenGate").Collision.Sound.Played:Once(function()
    			Functions.RemoveESP(Object)
    			Functions.BlacklistESP(Object)
    		end)
    		end)
    		table.insert(Objects.Objectives, Object)
    	elseif Name == "Ladder" then
    		if Toggles.ab_LadderESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Ladder", Color = Options.ab_LadderESPColor.Value }, true) end
    		table.insert(Objects.Ladders, Object)
    	elseif Name == "Door" and Object.Parent and tonumber(Object.Parent.Name) then
    		local DoorParts = {}
    		for _, Child in Object:GetChildren() do
    			if Child.Name == "Door" and Child:IsA("BasePart") then
    				table.insert(DoorParts, Child)
    			end
    		end

    		if #DoorParts == 2 then
    			local HighlightModel = Instance.new("Model", Object)
    			HighlightModel.Name = "HighlightModel"
    			Instance.new("Humanoid", HighlightModel).Name = "HighlightHumanoid"
    			HighlightModel:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))

    			for _, DoorPart in DoorParts do
    				local HP = Instance.new("Part", HighlightModel)
    				HP.Transparency = 0.999
    				HP.Size = DoorPart.Size
    				HP.CanCollide = false
    				HP.CFrame = DoorPart.CFrame
    				HP.Name = "HighlightPart"
    				HP.Material = Enum.Material.Plastic
    				HP:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
    				local W = Instance.new("WeldConstraint", HP)
    				W.Part0 = HP W.Part1 = DoorPart W.Enabled = true
    			end
    			table.insert(Objects.Doors, HighlightModel)
    			if Toggles.ab_DoorESPToggle.Value then Functions.AddESP({ Object = HighlightModel, Text = "Door " .. Functions.GetDoorNumber(Object), Color = Options.ab_DoorESPColor.Value }, true) end
    		else
    			local Root = Object:WaitForChild("Door", 9e9)
    			local HP = Instance.new("Part", Object)
    			HP.Transparency = 0.999
    			HP.Size = Root.Size
    			HP.CanCollide = false
    			HP.CFrame = Root.CFrame
    			HP.Name = "HighlightPart"
    			HP.Material = Enum.Material.Plastic
    			HP:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
    			local W = Instance.new("WeldConstraint", HP)
    			W.Part0 = HP W.Part1 = Root W.Enabled = true
    			Instance.new("Humanoid", Object).Name = "HighlightHumanoid"
    			table.insert(Objects.Doors, HP)
    			if Toggles.ab_DoorESPToggle.Value then Functions.AddESP({ Object = HP, Text = "Door " .. Functions.GetDoorNumber(Object), Color = Options.ab_DoorESPColor.Value }, true) end
    		end

    		local LastDoorFire = tick()
    		local DoorConn = Services.RunService.Heartbeat:Connect(function()
    			if Object:FindFirstChild("Door") and Object:FindFirstChild("ClientOpen") then
    				if LocalPlayer:DistanceFromCharacter(Object.Door.Position) < 75
    					and tick() - LastDoorFire > 0.1
    					and (Toggles.ab_DoorReachToggle.Value or Functions.GetMinecart())
    				then
    					Object.ClientOpen:FireServer()
    					LastDoorFire = tick()
    				end
    			end
    		end)
    		Object.Destroying:Once(function()
    			DoorConn:Disconnect()
    		end)
    		pcall(function()
    		Object:WaitForChild("Door"):WaitForChild("Open").Played:Once(function()
    			DoorConn:Disconnect()
    		end)
    		end)
    		table.insert(Connections, DoorConn)

    	elseif Name == "PathLights" then
    		local ObjectsToHighlight = {}
    		local PLConn = Object.ChildAdded:Connect(function(Child)
    			table.insert(ObjectsToHighlight, Child)
    		end)
    		for _, Child in Object:GetChildren() do
    			table.insert(ObjectsToHighlight, Child)
    		end

    		local function CreateSeekNode(Light)
    			if Light.Name ~= "SeekGuidingLight" or Light:GetAttribute("Highlighted") then return end
    			Light:SetAttribute("Highlighted", true)

    			local NewNode = Instance.new("Part")
    			NewNode.Size = Vector3.one
    			NewNode.Transparency = 1
    			NewNode.Parent = Globals.SeekNodesFolder
    			NewNode.Anchored = true
    			NewNode.CFrame = Light.CFrame
    			NewNode.CanCollide = false
    			NewNode.Name = "SeekLightNode"

    			local PrevNode2 = PreviousNode or NewNode
    			PreviousNode = NewNode

    			local Beam = Instance.new("Beam")
    			Beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Options.ab_ShowSeekPathColor.Value), ColorSequenceKeypoint.new(1, Options.ab_ShowSeekPathColor.Value) })
    			Beam.FaceCamera = true
    			Beam.Width0 = 0.2
    			Beam.Width1 = 0.2
    			Beam.Brightness = 10
    			Beam.LightInfluence = 0
    			Beam.LightEmission = 0
    			Beam.Enabled = true
    			local Vis = Toggles.ab_ShowSeekPathToggle.Value and 0 or 1
    			Beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, Vis), NumberSequenceKeypoint.new(1, Vis) })
    			Beam.Parent = Globals.SeekNodesFolder
    			local A0 = Instance.new("Attachment", NewNode)
    			local A1 = Instance.new("Attachment", PrevNode2)
    			Beam.Attachment0 = A0
    			Beam.Attachment1 = A1
    			table.insert(Objects.SeekHighlights, Beam)
    			Light:Destroy()
    		end

    		task.spawn(function()
    			while task.wait() do
    				local Light = table.remove(ObjectsToHighlight, 1)
    				if Light then CreateSeekNode(Light) end
    			end
    		end)

    		table.insert(Connections, PLConn)
    		table.insert(Objects.PathLights, Object)
    		Object.Destroying:Once(function() PLConn:Disconnect() end)
    	elseif Name == "SeekMovingNewClone" then
    		local Connection = Object.Destroying:Connect(function()
    			for _, Folder in pairs(Objects.PathLights) do
    				Folder:ClearAllChildren()
    			end
    			Globals.SeekNodesFolder:ClearAllChildren()
    		end)
    		table.insert(Connections, Connection)
    	elseif Name == "Bridge" then
    		for _, Child in Object:GetChildren() do
    			if Child.Name == "PlayerBarrier" and Child.Size.Y == 2.75 and (Child.Rotation.X == 0 or Child.Rotation.X == 180) then
    				local NewBridge = Child:Clone()
    				NewBridge.CFrame = NewBridge.CFrame * CFrame.new(0, 0, -5)
    				NewBridge.Name = Abysall.ESPLibrary:GenerateRandomString()
    				NewBridge.Size = Vector3.new(NewBridge.Size.X, NewBridge.Size.Y, 11)
    				NewBridge.Parent = Object
    				NewBridge.CanCollide = Toggles.ab_BypassSeekObstructions.Value
    				NewBridge.Color = Color3.fromRGB(0, 255, 255)
    				NewBridge.Transparency = Toggles.ab_BypassSeekObstructions.Value and 0 or 1
    				NewBridge.Material = Enum.Material.ForceField
    				table.insert(Objects.SeekBridges, NewBridge)
    			end
    			task.wait()
    		end
        elseif Name == "MinecartRig" then
            Globals.Minecart = Object
    	elseif Name == "RunnerNodes" then
    		local function IsBehind(Part1, Part2)
    			local P1 = (Part1.CFrame + Part1.CFrame.LookVector).Position
    			local P2 = (Part1.CFrame + Part1.CFrame.LookVector * -1).Position
    			return (P1 - Part2.Position).Magnitude > (P2 - Part2.Position).Magnitude
    		end
    		local function GetDirection(Part1, Part2)
    			local RightDist = Part1.CFrame.RightVector:Dot(Part1.Position - Part2.Position)
    			if RightDist > 0.5    then return IsBehind(Part1, Part2) and "Right" or "Left" end
    			if RightDist < -0.5   then return IsBehind(Part1, Part2) and "Left" or "Right" end
    			return "Straight"
    		end
    		local function GetClosestNode(Node)
    			local Best, BestDist = nil, math.huge
    			local NodeID2 = tonumber(Node.Name:split("MinecartNode")[2])
    			for _, OtherNode in Object:GetChildren() do
    				local OtherID = tonumber(OtherNode.Name:split("MinecartNode")[2])
    				if OtherNode ~= Node and OtherID and NodeID2 and OtherID > NodeID2 then
    					local D = (Node.Position - OtherNode.Position).Magnitude
    					if D < BestDist and OtherNode:GetAttribute("DistanceBlacklist") ~= true then
    						BestDist = D Best = OtherNode
    					end
    				end
    			end
    			return Best
    		end

    		for _, Node in Object:GetChildren() do
    			local NodeID = tonumber(Node.Name:split("MinecartNode")[2])
    			if Node:GetAttribute("DeathType") then Node:SetAttribute("DistanceBlacklist", true) end
    			for I = 1, 20 do
    				local NextNode = NodeID and Object:FindFirstChild("MinecartNode" .. NodeID + I)
    				if NextNode and NextNode:GetAttribute("DeathType") ~= nil then
    					Node:SetAttribute("DistanceBlacklist", true)
    				end
    			end
    			local PrevNode3 = NodeID and Object:FindFirstChild("MinecartNode" .. NodeID - 1)
    			if PrevNode3 and PrevNode3:GetAttribute("ForceConnect") then
    				Node:SetAttribute("DistanceBlacklist", nil)
    			end
    			task.wait()
    		end

    		for _, Node in Object:GetChildren() do
    			if Node:GetAttribute("ForceConnect") then
    				local NextNode = GetClosestNode(Node)
    				if NextNode then
    					Node:SetAttribute("Turn", GetDirection(Node, NextNode))
    					table.insert(Objects.SeekNodes, Node)
    				end
    			end
    			task.wait()
    		end

    	elseif Name == "EyestalkEndCutscene" then
    		Object.Name = "_EyestalkEndCutscene"
    	elseif Name == "DuckBoard" then
    		table.insert(Objects.SeekDuckBoards, Object)
    	elseif HidingSpotLabels[Name] or string.find(string.lower(Name), "hidingspot") then
    		local Label = HidingSpotLabels[Name] or (string.find(string.lower(Name), "hidingspot") and "Hiding Spot" or nil)
    		if Label and Toggles.ab_HidingSpotESPToggle.Value then Functions.AddESP({ Object = Object, Text = Label, Color = Options.ab_HidingSpotESPColor.Value }, true) end
    		Functions.HandleHidingTransparency(Object)
    		table.insert(Objects.HidingSpots, Object)
    	elseif Object:FindFirstChild("HidingPrompt") or Object:FindFirstChild("HidePrompt") then
    		Functions.HandleHidingTransparency(Object)
    		table.insert(Objects.HidingSpots, Object)
    	elseif Name == "Lava" then
    		if Toggles.ab_BypassKillbricks.Value then Object.CanTouch = false end
    		table.insert(Objects.Obstructions, Object)
    	elseif Name == "ScaryWall" then
    		for _, Part in Object:GetDescendants() do
    			if Part:IsA("BasePart") then
    				Part.CanTouch = not Toggles.ab_BypassSeekingWall.Value
    				Part.CanCollide = not Toggles.ab_BypassSeekingWall.Value

                    local Connection1 = Part:GetPropertyChangedSignal("CanTouch"):Connect(function()
                        if Part.CanTouch == Toggles.ab_BypassSeekingWall.Value then
                            Part.CanTouch = not Toggles.ab_BypassSeekingWall.Value
                        end
                    end)
                    local Connection2 = Part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                        if Part.CanCollide == Toggles.ab_BypassSeekingWall.Value then
                            Part.CanCollide = not Toggles.ab_BypassSeekingWall.Value
                        end
                    end)

                    table.insert(Connections, Connection1)
                    table.insert(Connections, Connection2)
                end
    		end
    		table.insert(Objects.Obstructions, Object)
    	elseif Name == "ChestBox" or Name == "ChestBoxLocked" then
    		if Toggles.ab_ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = Object:GetAttribute("Locked") and "Locked Chest" or "Chest", Color = Options.ab_ChestESPColor.Value }, true) end
    		table.insert(Objects.Chests, Object)
    	elseif Name == "Toolbox" or Name == "Toolbox_Locked" then
    		if Toggles.ab_ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = Object:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox", Color = Options.ab_ChestESPColor.Value }, true) end
    		table.insert(Objects.Chests, Object)
    	elseif Name == "Chest_Vine" then
    		if Toggles.ab_ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Vine Chest", Color = Options.ab_ChestESPColor.Value }, true) end
    		table.insert(Objects.Chests, Object)
    	elseif Name == "Toolshed_Small" then
    		if Toggles.ab_ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Toolshed", Color = Options.ab_ChestESPColor.Value }, true) end
    		table.insert(Objects.Chests, Object)
    	elseif Name == "Locker_Small_Locked" then
    		if Toggles.ab_ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Locked Item Locker", Color = Options.ab_ChestESPColor.Value }, true) end
    		table.insert(Objects.Chests, Object)
    	elseif Name == "MouseHole" then
    		if Toggles.ab_ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Mouse", Color = Options.ab_ChestESPColor.Value }, true) end
    		table.insert(Objects.Chests, Object)
    	elseif ItemNames[Name] and Object:FindFirstChild("ModulePrompt") then
    		if Toggles.ab_ItemESPToggle.Value then Functions.AddESP({ Object = Object, Text = ItemNames[Name], Color = Options.ab_ItemESPColor.Value }, Object:GetAttribute("ParentRoom") ~= nil) end
    		if Name == "LotusHolder" or Name == "LotusPetalPickup" then
    			Object.Handle:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
    				Abysall.ESPLibrary:RemoveESP(Object)
    				Functions.BlacklistESP(Object)
    			end)
    		end

    		if Toggles.ab_NotifyItemsToggle.Value and Options.ab_NotifyItemList.Value[ItemNames[Name]] and Object.Parent.Name ~= "Drops" then
    			if Toggles.ab_NotifyItemsShowDistance.Value then
    				Functions.Notify({ Title = "Item '" .. ItemNames[Name] .. "' has spawned.", Body = "It is '" .. math.round(LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)) .. "' studs away from you." })
    			else
    				Functions.Notify({ Title = "Item '" .. ItemNames[Name] .. "' has spawned."})
    			end
    		end

    		table.insert(Objects.Items, Object)
    	elseif Name == "Green_Herb" then
    		if Toggles.ab_ItemESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Green Herb", Color = Options.ab_ItemESPColor.Value }, true) end
    		table.insert(Objects.Items, Object)
    	elseif Name == "GoldPile" and Object:GetAttribute("GoldValue") then
    		if Toggles.ab_CurrencyESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gold Pile [" .. Object:GetAttribute("GoldValue") .. "]", Color = Options.ab_CurrencyESPColor.Value }, true) end
    		table.insert(Objects.Currency, Object)
    	elseif Name == "StardustPickup" then
    		if Toggles.ab_CurrencyESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Stardust Pile", Color = Options.ab_CurrencyESPColor.Value }, true) end
    		table.insert(Objects.Currency, Object)
    	elseif Name == "GiggleCeiling" then
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Giggle"] then Functions.AddESP({ Object = Object, Text = "Giggle", Color = Options.ab_EntityESPColor.Value }, true) end
    		if Toggles.ab_BypassGiggle.Value then Object:WaitForChild("Hitbox").CanTouch = false end
    		table.insert(Objects.Entities, Object)
    	elseif Name == "GloomPile" then
    		if Toggles.ab_BypassGloombatEggs.Value then
    			for _, Part in Object:GetDescendants() do
    				if Part:IsA("BasePart") then Part.CanTouch = false
    				end
    			end
    		end
    		local Connection = Object.DescendantAdded:Connect(function(Part)
    			if Part:IsA("BasePart") then Part.CanTouch = false end
    		end)

    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Gloombat Eggs"] then
    			Functions.AddESP({ Object = Object, Text = "Gloombat Eggs", Color = Options.ab_EntityESPColor.Value })
    		end

    		table.insert(Connections, Connection)
    		table.insert(Objects.Entities, Object)
    	elseif Name == "TriggerEventCollision" and Functions.CheckCompatability({"firetouchinterest"}) then
    		if (Floor == "Fools" or Floor == "OldHotel") and Toggles.ab_RemoveSeekTrigger.Value then
    			task.spawn(function()
    				while Object:IsDescendantOf(game) do
    					for _, Part in Object:GetChildren() do
    						if Part:IsA("BasePart") then
    							Abysall.Environment.firetouchinterest(RootPart, Part, 0)
    							task.wait()
    							Abysall.Environment.firetouchinterest(RootPart, Part, 1)
    						end
    					end
    					task.wait()
    				end
    			end)
    		end
    		table.insert(Objects.EventTriggers, Object)
    	elseif Name == "DoorFake" or Name == "FakeDoor" then
    		if Object.Parent and Object:FindFirstChild("Hidden") then
    			if Toggles.ab_BypassDupe.Value then
    				Object:WaitForChild("Hidden").CanTouch = false
    				local Lock = Object:FindFirstChild("Lock")
    				if Lock and Lock:FindFirstChild("UnlockPrompt") then Lock.UnlockPrompt.Enabled = false end
    			end
    			if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Dupe"] then
    				Functions.AddESP({ Object = Object, Text = "Dupe", Color = Options.ab_EntityESPColor.Value }, true)
    			end
    			table.insert(Objects.Entities, Object)
    		end
    	elseif Name == "SideroomSpace" then
    		if Toggles.ab_BypassVacuum.Value then
    			Object:WaitForChild("Collision").CanCollide = true
    			Object:WaitForChild("Collision").CanTouch = false
    		end
    		table.insert(Objects.Entities, Object)
    	elseif Name == "Snare" then
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Snare"] then Functions.AddESP({ Object = Object, Text = "Snare", Color = Options.ab_EntityESPColor.Value }, true) end
    		for _, Part in Object:GetDescendants() do
    			if Part:IsA("BasePart") then Part.CanTouch = not Toggles.ab_BypassSnare.Value end
    		end
    		local Connection = Object.DescendantAdded:Connect(function(Part)
    			if Part:IsA("BasePart") then Part.CanTouch = not Toggles.ab_BypassSnare.Value end
    		end)
    		table.insert(Connections, Connection)
    		table.insert(Objects.Entities, Object)

    		if Object:FindFirstChild("Snare") then
    			Object:WaitForChild("Snare"):WaitForChild("Roots").Transparency = 1
    			Object:WaitForChild("Snare"):WaitForChild("SnareBase").Transparency = 1
    		end
    		if Object:FindFirstChild("Void") then
    			Object.Void.Transparency = 0
    			Object.Void.Color = Color3.fromRGB(76, 67, 55)
    		end
    	elseif Name == "Seek_Arm" or Name == "ChandelierObstruction" then
    		for _, Part in Object:GetDescendants() do
    			if Part:IsA("BasePart") then
    				Part.CanTouch = not Toggles.ab_BypassSeekObstructions.Value
    				table.insert(Objects.SeekObstructions, Part)
    			end
    		end
    	elseif Name == "SeekFloodline" then
    		Object.CanCollide = Toggles.ab_BypassSeekObstructions.Value
    		local FloodConn = Object:GetPropertyChangedSignal("CanCollide"):Connect(function()
    			if Object.CanCollide ~= Toggles.ab_BypassSeekObstructions.Value then
    				Object.CanCollide = Toggles.ab_BypassSeekObstructions.Value
    			end
    		end)
    		Object.Destroying:Once(function() FloodConn:Disconnect() end)
    		table.insert(Objects.SeekObstructions, Object)
    	elseif Object:GetAttribute("RawName") and Object:GetAttribute("RawName"):find("Halt") or Object:GetAttribute("Shade") == true then
    		if Toggles.ab_NotifyEntities.Value and Options.ab_EntityList.Value["Halt"] then
    			Functions.Notify({ Title = "Entity 'Halt' will spawn in the next room.", Image = EntityIcons["Halt"] })
    			if Toggles.ab_EntityChatToggle.Value then Functions.SendChat("Halt next room!") end
    		end
    		local HaltLogConn
    		HaltLogConn = Services.LogService.MessageOut:Connect(function(Message)
    			if Message == "client teleporting" then
    				if Globals.AnticheatDisabled then
    					Globals.AnticheatDisabled = false
    					Functions.Notify({ Title = "The anticheat has been re-enabled.", Body = "Interact with a ladder to disable it again." })
    				end
    				HaltLogConn:Disconnect()
    			end
    		end)
    	elseif Name == "BananaPeel" then
    		if Toggles.ab_BypassBanana.Value then Object.CanTouch = false end
    		table.insert(Objects.Entities, Object)
    	elseif Name == "JeffTheKiller" then
    		if Toggles.ab_BypassJeff.Value then
    			for _, Part in Object:GetDescendants() do
    				if Part:IsA("BasePart") then Part.CanCollide = false Part.CanTouch = false end
    			end
    			Object:WaitForChild("Humanoid").Health = 0
    		end
    	elseif Name == "GrumbleRig" then
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Grumble"] then Functions.AddESP({ Object = Object, Text = "Grumble", Color = Options.ab_EntityESPColor.Value }, true) end
    		table.insert(Objects.Entities, Object)
    	elseif Name == "LiveEntityBramble" then
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Bramble"] then Functions.AddESP({ Object = Object, Text = "Bramble", Color = Options.ab_EntityESPColor.Value }, true) end
    		table.insert(Objects.Entities, Object)
    	elseif Name == "Groundskeeper" then
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Groundskeeper"] then Functions.AddESP({ Object = Object, Text = "Groundskeeper", Color = Options.ab_EntityESPColor.Value }, true) end
    		if Toggles.ab_NotifyEntities.Value and Options.ab_EntityList.Value["Groundskeeper"] then
    			local ED = Entities["Groundskeeper"]
    			Functions.Notify({ Title = ED.NotifyMessage.Title, Body = ED.NotifyMessage.Body, Image = EntityIcons["Groundskeeper"] })
    		end
    		table.insert(Objects.Entities, Object)
    	elseif Name == "Figure" or Name == "FigureRig" or Name == "FigureRagdoll" then
    		for _, Part in Object:GetDescendants() do
    			if Part:IsA("BasePart") then
    				Part.CanTouch = false
    			end
    		end
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value["Figure"] then Functions.AddESP({ Object = Object, Text = "Figure", Color = Options.ab_EntityESPColor.Value }, true) end
    		table.insert(Objects.Entities, Object)
    		if Toggles.ab_RemoveFigure.Value and Functions.CheckCompatability({"isnetworkowner"}) then
    			if Floor == "Mines" then
    				for _, Part in Object:GetDescendants() do
    					if Part:IsA("BasePart") then
    						task.spawn(function()
    							if Abysall.Environment.isnetworkowner(Part) then
    								Part.Position = Vector3.new(-49999, -49999, -49999)
    							end
    						end)
    					end
    				end
    			elseif Floor == "OldHotel" or Floor == "Fools" then
    				CurrentRooms.ChildAdded:Wait()
    				for _, Part in Object:GetDescendants() do
    					if Part:IsA("BasePart") then
    						Part.CanCollide = false
    						task.spawn(function()
    							while Abysall.Environment.isnetworkowner(Part) do
    								Part.Position = Vector3.new(math.random(-29999,29999), math.random(-29999,29999), math.random(-29999,29999))
    								task.wait()
    							end
    						end)
    					end
    				end
    			end
    		end
    	elseif (Name == "ThingToOpen" or Name == "MovingDoor") and (Floor == "Fools" or Floor == "OldHotel")
    		or Name == "Wax_Door" and Floor == "Fools"
    	then
    		Object:SetAttribute("OriginalPosition", Object:GetPivot())
    		local ToggleMap = { ThingToOpen = "RemoveBasementGate", MovingDoor = "RemovePaintingsDoor", Wax_Door = "RemoveSkeletonDoor" }
    		if ToggleMap[Name] and Toggles[ToggleMap[Name]].Value then
    			Object:PivotTo(CFrame.new(-10000, -10000, -10000))
    		end
    		table.insert(Objects.Obstructions, Object)
    	elseif Name == "ElevatorBreaker" then
    		if Toggles.ab_AutoBreakerBox.Value and not Globals.BreakerBoxNotified then
    			Functions.Notify({ Title = "Interact with the breaker box.", Body = "It will be automatically solved." })
    			Globals.BreakerBoxNotified = true
    		end
    		Connections.BreakerConnection = Object:WaitForChild("SurfaceGui").Frame.Code:GetPropertyChangedSignal("Text"):Connect(function()
    			if Toggles.ab_AutoBreakerBox.Value then
    				if not Globals.BreakerBoxStartNotified and (Floor == "Fools" or Floor == "OldHotel") then
    					Functions.Notify({ Title = "Attempting to solve the breaker box.", Body = "Please wait." })
    					Globals.BreakerBoxStartNotified = true
    				end
    				RemotesFolder.EBF:FireServer()
    			end
    			Globals.BreakerBoxInteracted = true
    		end)
    	elseif Name == "ElevatorCar" then
    		local ElevConn = Object.DescendantAdded:Connect(function(Desc)
    			if Toggles.ab_AutoBreakerBox.Value and Desc.Name == "TouchInterest" and not Globals.BreakerBoxFinishedNotified then
    				Functions.Notify({ Title = "Successfully solved the breaker box.", Body = "Try going to the elevator!" })
    				Globals.BreakerBoxFinishedNotified = true
    			end
    		end)
    		Object.Destroying:Once(function() ElevConn:Disconnect() end)
    	elseif Object.ClassName == "ProximityPrompt" and not Object:GetAttribute("FakePrompt") then
    		if Object:HasTag("DisableWhenEnabledOnClient") then Object:RemoveTag("DisableWhenEnabledOnClient") end

    		Object:SetAttribute("HoldDuration_Old", Object.HoldDuration)
    		Object:SetAttribute("RequiresLineOfSight_Old", Object.RequiresLineOfSight)
    		Object:SetAttribute("MaxActivationDistance_Old", Object.MaxActivationDistance)

    		if Toggles.ab_InstantPrompts.Value    then Object.HoldDuration = 0 end
    		if Toggles.ab_PromptClip.Value        then Object.RequiresLineOfSight = false end
    		Object.MaxActivationDistance = Object:GetAttribute("MaxActivationDistance_Old") * Options.ab_PromptReachSlider.Value

    		local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }

    		if Functions.CheckCompatability({"fireproximityprompt"}) and Floor ~= "OldHotel" and Floor ~= "Fools" then
    			local IsLockPrompt = LockPromptNames[Object.Name]
    				or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
    				or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")

    			if IsLockPrompt then
    				local FakePrompt = Object:Clone()
    				FakePrompt:SetAttribute("FakePrompt", true)
    				task.wait()
    				FakePrompt.Parent = Object.Parent

    				FakePrompt:SetAttribute("HoldDuration_Old", Object:GetAttribute("HoldDuration_Old"))
    				FakePrompt:SetAttribute("RequiresLineOfSight_Old", Object:GetAttribute("RequiresLineOfSight_Old"))
    				FakePrompt:SetAttribute("MaxActivationDistance_Old", Object:GetAttribute("MaxActivationDistance_Old"))

    				FakePrompt.HoldDuration = Object.HoldDuration
    				FakePrompt.RequiresLineOfSight = Object.RequiresLineOfSight
    				FakePrompt.MaxActivationDistance = Object.MaxActivationDistance

    				if Toggles.ab_InstantPrompts.Value    then FakePrompt.HoldDuration = 0 end
    				if Toggles.ab_PromptClip.Value        then FakePrompt.RequiresLineOfSight = false end
    				FakePrompt.MaxActivationDistance = FakePrompt:GetAttribute("MaxActivationDistance_Old") * Options.ab_PromptReachSlider.Value

    				FakePrompts[FakePrompt] = Object
    				pcall(function() Object.Parent = Globals.PromptContainer end)

    				local FPEnabledConn = Object:GetPropertyChangedSignal("Enabled"):Connect(function()
    					FakePrompt.Enabled = Object.Enabled
    				end)
    				Object:GetPropertyChangedSignal("ActionText"):Once(function()
    					Object.Parent = FakePrompt.Parent
    					FakePrompt:Destroy()
    					FPEnabledConn:Disconnect()
    				end)
    				Object.Destroying:Once(function()
    					FakePrompt:Destroy()
    					FPEnabledConn:Disconnect()
    				end)
    				table.insert(Connections, FPEnabledConn)
    				table.insert(Objects.Prompts, FakePrompt)

    				FakePrompt.Enabled = false
    				task.wait()
    				FakePrompt.Enabled = Object.Enabled
    			end
    		end
    		table.insert(Objects.Prompts, Object)
    	elseif Name == "Padlock" then
    		local PadlockConn = Services.RunService.Heartbeat:Connect(function()
    			if Object.PrimaryPart then
    				local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
    				if Toggles.ab_AutoUnlockPadlockToggle.Value then
    					local Code = Functions.GetLibraryCode()
    					if Code and tonumber(Code) and Distance < Options.ab_AutoUnlockPadlockSlider.Value then
    						RemotesFolder.PL:FireServer(Code)
    					end
    				end
    				if Toggles.ab_AutoLibraryGuessCode.Value and LatestRoom.Value == 50 then
    					local Code = Functions.GetRandomCode()
    					if Code then RemotesFolder.PL:FireServer(Code) end
    				end
    			end
    		end)
    		Object.Destroying:Once(function()
    			PadlockConn:Disconnect()
    		end)
    	end
    end

    Connections.PromptAnimationFixer1 = Services.ProximityPromptService.PromptButtonHoldBegan:Connect(function(Object)
    	if not Object:GetAttribute("FakePrompt") then return end
    	local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    	local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    	local Tool
    	for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

    	local Prompt = Object
    	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
    	local IsLockPrompt = LockPromptNames[Object.Name]
    		or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
    		or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
    	if IsLockPrompt then
    		if Options.ab_AutoInteractIgnoreList.Value["Locks"] then return end
    		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
    		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
    		local HasKey = false
    		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
    		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
    		if not HasKey then return end
    	end

    	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
    	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end
	
    	if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation then
    		Globals.UseAnimationBreak:Stop()
    		Globals.UseAnimation:Stop()
    		Globals.UseAnimation:Play()
    		if Tool.Name == "Shears" then Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end
    	end
    end)

    Globals.ObjectQueue = {}
    local AllowedInstances = {
    	Lava=true, GoldPile=true, KeyObtain=true, Drakobloxxer=true, FuseObtain=true,
    	MinesGenerator=true, JeffTheKiller=true, Snare=true, FakeDoor=true, DoorFake=true, SideroomSpace=true,
    	ChestBox=true, ChestBoxLocked=true, Chest_Vine=true, Locker_Small_Locked=true, Toolbox=true,
    	Toolbox_Locked=true, Wardrobe=true, ["Wardrobe-FOOLS26"]=true, Toolshed=true, Toolshed_Small=true,
    	Bed=true, MinesAnchor=true, Double_Bed=true, RetroWardrobe=true, Backdoor_Wardrobe=true,
    	Rooms_Locker=true, Rooms_Locker_Fridge=true, Locker_Large=true, FigureRig=true, FigureRagdoll=true,
    	TimerLever=true, Lever=true, Seek_Arm=true, ChandelierObstruction=true, ScaryWall=true, Ladder=true,
    	CircularVent=true, Dumpster=true, SquareGrate=true, TriggerEventCollision=true, GrumbleRig=true,
    	GiggleCeiling=true, MinesGateButton=true, ElectricalKeyObtain=true, LibraryHintPaper=true,
    	WaterPump=true, CringlePresent=true, Wheel=true, PickupItem=true, LiveHintBook=true,
    	LiveBreakerPolePickup=true, LeverForGate=true, GloomPile=true, SeekFloodline=true, Door=true,
    	Green_Herb=true, Bridge=true, MouseHole=true, BananaPeel=true, NannerPeel=true, PowerupPad=true,
    	IndustrialGate=true, CollisionFloor=true, ElevatorCar=true, Wax_Door=true, ThingToOpen=true,
    	MovingDoor=true, StardustPickup=true, Hole=true, Groundskeeper=true, MandrakeLive=true,
    	GardenGateButton=true, LotusPetalPickup=true, VineGuillotine=true, LiveEntityBramble=true, ArchivesFihTank=true,
    	RiftSpawn=true, ElevatorBreaker=true, RunnerNodes=true, PathLights=true, DuckBoard=true,
    	Padlock=true, EyestalkEndCutscene=true, MinecartRig=true, SeekMovingNewClone=true, Cellar=true, ArchivesPackageDeposit=true, StairwellScrapper=true,
    	StairwellFireAlarm=true, ShoppingCart=true, Mirror=true, StairwellLockpickDoor=true
    }

    Functions.QueueObject = function(Object)
    	if TimeShowerClone and Object:IsDescendantOf(TimeShowerClone) then
    		return
    	end
    	local IsHidingSpot = typeof(Object.Name) == "string" and string.find(string.lower(Object.Name), "hidingspot")
    	if not AllowedInstances[Object.Name] and not IsHidingSpot and Object.ClassName ~= "ProximityPrompt" and Object.Parent ~= CurrentRooms and not ItemNames[Object.Name] then
    		return
    	end
    	table.insert(Globals.ObjectQueue, Object)
    end

    Globals.QueueDone = true
    Connections.QueueConnection = Services.RunService.RenderStepped:Connect(function()
    	local Object = table.remove(Globals.ObjectQueue, 1)
    	if Object then
    		Functions.HandleObject(Object)
    	end
    end)

    for _, Object in Services.Workspace:GetDescendants() do
    	task.spawn(function() Functions.QueueObject(Object) end)
    end

    Connections.InstanceHandler = Services.Workspace.DescendantAdded:Connect(function(Object)
    	Functions.QueueObject(Object)
    end)

    for _, Player in Services.Players:GetPlayers() do
    	if Player ~= LocalPlayer then
    		if Player.Character and Toggles.ab_PlayerESPToggle.Value then
    			Functions.AddESP({ Object = Player.Character, Text = Player.Name, Color = Options.ab_PlayerESPColor.Value })
    		end
    		local CharConn = Player.CharacterAdded:Connect(function(NewCharacter)
    			if Toggles.ab_PlayerESPToggle.Value then
    				Functions.AddESP({ Object = NewCharacter, Text = Player.Name, Color = Options.ab_PlayerESPColor.Value })
    			end
    		end)
    		local DeadConn = Player:GetAttributeChangedSignal("Alive"):Connect(function()
    			if Player:GetAttribute("Alive") ~= true and Player.Character then
    				Functions.RemoveESP(Player.Character)
    			end
    		end)
    		table.insert(Connections, CharConn)
    		table.insert(Connections, DeadConn)
    		Player.Destroying:Once(function()
    			CharConn:Disconnect()
    			DeadConn:Disconnect()
    		end)
    	end
    end

    Connections.PlayerHandler = Services.Players.PlayerAdded:Connect(function(Player)
    	if Player == LocalPlayer then return end
    	if Player.Character and Toggles.ab_PlayerESPToggle.Value then
    		Functions.AddESP({ Object = Player.Character, Text = Player.Name, Color = Options.ab_PlayerESPColor.Value })
    	end
    	local CharConn = Player.CharacterAdded:Connect(function(NewCharacter)
    		if Toggles.ab_PlayerESPToggle.Value then
    			Functions.AddESP({ Object = NewCharacter, Text = Player.Name, Color = Options.ab_PlayerESPColor.Value })
    		end
    	end)
    	local DeadConn = Player:GetAttributeChangedSignal("Alive"):Connect(function()
    		if Player:GetAttribute("Alive") ~= true and Player.Character then
    			Functions.RemoveESP(Player.Character)
    		end
    	end)
    	table.insert(Connections, CharConn)
    	table.insert(Connections, DeadConn)
    	Player.Destroying:Once(function()
    		CharConn:Disconnect()
    		DeadConn:Disconnect()
    	end)
    end)

    local PromptsToFire = {}
    local PromptCooldown = {}

    Functions.FirePrompt      = Abysall.Environment.fireproximityprompt
    Functions.ForceFirePrompt = Abysall.Environment.fireproximityprompt

    if not Functions.FirePrompt then
    	Functions.FirePrompt = function(Prompt)
    		if not Prompt:IsA("ProximityPrompt") or PromptCooldown[Prompt] or table.find(PromptsToFire, Prompt) or not Camera then return end
    		table.insert(PromptsToFire, Prompt)
    	end
    	Functions.ForceFirePrompt = Functions.FirePrompt

    	task.spawn(function()
    		while task.wait() do
    			local Prompt = table.remove(PromptsToFire, 1)
    			if not Prompt then continue end
    			PromptCooldown[Prompt] = true

    			local OldDist   = Prompt.MaxActivationDistance
    			local OldEnable = Prompt.Enabled
    			local OldParent = Prompt.Parent
    			local OldHold   = Prompt.HoldDuration
    			local OldLOS    = Prompt.RequiresLineOfSight

    			Prompt.MaxActivationDistance = 99999
    			Prompt.Enabled = true
    			Prompt.HoldDuration = 0
    			Prompt.RequiresLineOfSight = false

    			local TempPart = Instance.new("Part")
    			TempPart.Parent = Services.Workspace
    			TempPart.CanCollide = false TempPart.CanQuery = false TempPart.CanTouch = false
    			TempPart.Anchored = true TempPart.Transparency = 1
    			TempPart.Size = Vector3.new(0.001, 0.001, 0.001)
    			TempPart.Position = Camera.CFrame:ToWorldSpace(CFrame.new(0, 0, -0.1)).Position

    			if not Prompt or not OldParent then
    				TempPart:Destroy()
    				PromptCooldown[Prompt] = nil
    				continue
    			end

    			pcall(function() Prompt.Parent = TempPart end)

    			local Shown, Fired = false, false

    			local ShownConn = Services.ProximityPromptService.PromptShown:Connect(function(P)
    				if P == Prompt then Shown = true end
    			end)
    			local FiredConn = Prompt.Triggered:Connect(function() Fired = true end)

    			local T1 = 0
    			while not Shown and T1 < 5 do T1 += 1 task.wait() end

    			local T2 = 0
    			while not Fired and T2 < 5 do
    				-- InputHoldBegin/End is the engine's own activation path, so it needs no
    				-- executor function at all. pcall it: a prompt that refuses (destroyed,
    				-- disabled by the server, hold interrupted) must not take the drain loop
    				-- down with it, or every later prompt stops firing too.
    				pcall(function() Prompt:InputHoldBegin() Prompt:InputHoldEnd() end)
    				T2 += 1 task.wait()
    			end

    			Prompt.MaxActivationDistance = OldDist
    			Prompt.Enabled = OldEnable
    			Prompt.HoldDuration = OldHold
    			Prompt.RequiresLineOfSight = OldLOS
    			pcall(function() Prompt.Parent = OldParent end)
    			task.wait()
    			PromptCooldown[Prompt] = nil
    			TempPart:Destroy()
    			ShownConn:Disconnect()
    			FiredConn:Disconnect()
    		end
    	end)
    end

    local AutoInteractBlacklist = {
    	HidePrompt=true, RiftPrompt=true, StarRiftPrompt=true, InteractPrompt=true, ClimbPrompt=true,
    	DonatePrompt=true, DialoguePrompt=true, RevivePrompt=true, EnterPrompt=true, AnimatePrompt=true,
    	ToolEventPrompt=true, Prompt=true, PropPrompt=true
    }

    local TriggerDebounce = false

    local function GetHidingSpotModel(Prompt)
    	if not Prompt or not Prompt.Parent then return false end
    	local Model = Prompt.Parent
    	while Model and not Model:IsA("Model") do
    		Model = Model.Parent
    	end
    	if not Model then return nil end

    	local Name = string.lower(Model.Name)
    	if not string.find(Name, "hidingspot") and not string.find(Name, "hiding_spot") then
    		return nil
    	end
    	return Model
    end

    local function HasHidePrompt(Model)
    	return Model and (Model:FindFirstChild("HidePrompt") or Model:FindFirstChild("HidingPrompt")) ~= nil
    end

    local function IsHidingSpotPrompt(Prompt)
    	if not Prompt or not Prompt.Parent then return false end
    	if Prompt.Name ~= "HidePrompt" and Prompt.Name ~= "HidingPrompt" then return false end
    	return HasHidePrompt(GetHidingSpotModel(Prompt))
    end

    Functions.TriggerPrompt = function(Prompt)
    	if not Prompt or not Prompt.Parent then return end
    	if Character:GetAttribute("Hiding") == true then return end
    	local HidingSpot = GetHidingSpotModel(Prompt)
    	if HidingSpot and Prompt.Name ~= "InteractPrompt" then return end
    	local IsHidingSpotInteractPrompt = HidingSpot and Prompt.Name == "InteractPrompt"
    	if AutoInteractBlacklist[Prompt.Name] and not IsHidingSpotPrompt(Prompt) and not IsHidingSpotInteractPrompt then return end
    	if (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt") and not IsHidingSpotPrompt(Prompt) then return end
    	if (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt" or IsHidingSpotPrompt(Prompt)) then
    		if not Toggles.ab_AutoClosetToggle.Value then return end
    		local Entity = Functions.GetNearestEntity(true, Options.ab_AutoClosetEntityList.Value)
    		if not Entity then return end
    		local EntityDistance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
    		if EntityDistance > (EntityDistances[Entity.Name] or 150) then return end
    	end
    	if TriggerDebounce then return end

    	local ParentItem = Functions.HasItem(Prompt.Parent.Name)
    	if ParentItem and ParentItem:GetAttribute("Durability") and ParentItem:GetAttribute("DurabilityMax")
    		and ParentItem:GetAttribute("Durability") >= ParentItem:GetAttribute("DurabilityMax")
    	then return end

    	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
    	local IsLockPrompt = LockPromptNames[Prompt.Name]
    		or (Prompt.Parent and Prompt.Parent:GetAttribute("Locked") == true)
    		or (Prompt.Parent and Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "Locker_Small_Locked" and Prompt.Name == "ActivateEventPrompt")

    	if IsLockPrompt then
    		if Options.ab_AutoInteractIgnoreList.Value["Locks"] then return end
    		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
    		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
    		local HasKey = false
    		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
    		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
    		if not HasKey then return end
    	end

    	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
    	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end

    	if Prompt.Parent.Name == "GlitchCube" and Options.ab_AutoInteractIgnoreList.Value["Glitch Fragments"] then return end

    	if (Prompt.Parent.Name == "KeyObtain" and (Functions.HasItem("Key") or Functions.HasItem("KeyBackdoor")))
    		or (Prompt.Parent.Name == "ElectricalKeyObtain" and Functions.HasItem("KeyElectrical"))
    	then return end

    	if Prompt:IsDescendantOf(Drops) and Options.ab_AutoInteractIgnoreList.Value["Dropped Items"] then return end
    	if Prompt.Parent.Name == "TrackLever" then return end
    	if Prompt.Name == "ActivateEventPrompt" and (Prompt.ActionText == "Close"
    		or Prompt.Parent.Name == "ElevatorBreaker"
    		or (Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "IndustrialGate"))
    	then return end
    	if Prompt.Name == "ActivateEventPrompt" and (Prompt.Parent.Name == "Padlock" or Prompt.Parent.Name == "MinesAnchor") then return end
    	if Prompt.Parent.Name == "LeverForGate" and Prompt:GetAttribute("Interactions") then return end
    	if Prompt.Parent.Parent and (Prompt.Parent.Parent.Name == "DoorFake" or Prompt.Parent.Parent.Name == "FakeDoor") then return end
    	if Prompt.Parent:GetAttribute("JeffShop") and Options.ab_AutoInteractIgnoreList.Value["Jeff Items"] then return end
    	if Prompt:GetAttribute("AutoInteractIgnore") then return end
    	if Prompt.Name == "PushPrompt" and Options.ab_AutoInteractIgnoreList.Value["Minecarts"] then return end
    	if (Prompt.Parent.Name == "GoldPile" or Prompt.Parent.Name == "StardustPickup") and Options.ab_AutoInteractIgnoreList.Value["Currency"] then return end

    	if Prompt.Parent.Name == "Bandage" then
    		local BPack = Functions.HasItem("BandagePack")
    		if Humanoid.Health >= Humanoid.MaxHealth and not BPack then return end
    		if BPack and BPack:GetAttribute("Durability") >= BPack:GetAttribute("DurabilityMax") then return end
    	end

    	if Prompt.Parent.Name == "Battery" then
    		local Tool = Character:FindFirstChildOfClass("Tool")
    		local BPack = Functions.HasItem("BatteryPack")
    		if not Tool and not BPack then return end
    		if Tool and Tool:GetAttribute("LightSource") then
    			if Tool:GetAttribute("Durability") and Tool:GetAttribute("DurabilityMax")
    				and Tool:GetAttribute("Durability") > Tool:GetAttribute("DurabilityMax")
    			then return end
    		elseif not BPack then
    			return
    		end
    		if BPack and BPack:GetAttribute("Durability") >= BPack:GetAttribute("DurabilityMax") then return end
    	end

    	if Prompt.Name == "HerbPrompt" then
    		local Effects = Safe(function() return Globals.MainUI.MainFrame.Healthbar:FindFirstChild("Effects") end)
    		if Effects and Effects.HerbGreenEffect.Visible then return end
    	end

    	if (Prompt.Parent.Name == "LibraryHintPaper" or Prompt.Parent.Name == "PickupItem") and (Functions.HasItem("LibraryHintPaper") or Functions.HasItem("LibraryHintPaperHard")) then return end
    	if Prompt.Parent.Name == "AlarmClock" and Functions.HasItem("AlarmClock") then return end
    	if Prompt.Parent.Name == "KeyObtainFake" or Prompt.Parent.Name == "TithingPlate" then return end
    	if Prompt.Parent.Name == "StarBottle" then return end
        -- archives
    	if Prompt.Parent.Name == "ArchivesStorageBox" then return end
    	if Prompt.Parent.Name == "Briefcase" then return end
    	if Prompt.Name == "SinkPrompt" or Prompt.Parent.Name == "Faucet" then return end
    	if Prompt.Parent.Name == "PaperPlanePickup" or Prompt.Parent.Name == "PaperPlane" then return end
    	if Prompt.Name == "ManualOpenPrompt" or Prompt.Name == "EntryPrompt" then return end
    	if Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "ArchivesLargePrinter" then return end
    	if Prompt.Name == "TrashcanPrompt" then return end
    	if Prompt.Parent.Name == "Keyboard" then return end
    	if Prompt.Name == "CartPrompt" or (Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "ArchivesOfficeChair") then return end
    	if Prompt.Parent.Name == "ArchivesTerminal" then return end
    	if Prompt.Name == "VendorPrompt" then return end
        if Prompt.Parent.Name == "SeatPart" or Prompt.Name == "SeatPrompt" then return end


    	-- Stairwell
    	if Prompt.Parent.Name == "StairwellScrapper" then return end
    	if Prompt.Name == "PortraitDupePrompt" or Prompt.Parent.Name == "MirrorTool" then return end
    	if Prompt.Name == "LaptopPrompt" or Prompt.Parent.Name == "SecretLaptop" then return end
    	if Prompt.Parent.Name == "StairwellFireAlarm" or (Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "StairwellFireAlarm") then return end
    	if Prompt.Parent.Name == "CobblerFriendly" then return end
    	if Prompt.Parent.Name == "StairwellTerminal" then return end
    	if Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "MeldChord" then return end

    	Functions.FirePrompt(Prompt)
    	TriggerDebounce = true
    	if Floor == "OldHotel" then task.wait() end
    	TriggerDebounce = false
    end

    Globals.LastAutoInteractFire = tick()
    Connections.AutoInteract = Services.RunService.Heartbeat:Connect(function()
    	local Active = Toggles.ab_AutoInteractToggle.Value or Options.AutoInteractKeybind:GetState()
        if not Active then return end
        if tick() - Globals.LastAutoInteractFire < 1/60 then return end

    	for _, Prompt in Objects.Prompts do
            if Prompt:GetAttribute("ParentRoom") and tonumber(Prompt:GetAttribute("ParentRoom")) ~= tonumber(LocalPlayer:GetAttribute("CurrentRoom")) then continue end

    		if Prompt.Parent and (Prompt.Parent:IsA("BasePart") or Prompt.Parent:IsA("Model")) then
    			local Distance
    			if Prompt.Parent:IsA("BasePart") then
    				Distance = LocalPlayer:DistanceFromCharacter(Prompt.Parent.Position)
    			else
    				Distance = LocalPlayer:DistanceFromCharacter(Prompt.Parent:GetPivot().Position)
    			end
    			if Distance <= Prompt.MaxActivationDistance and Prompt.Enabled or Distance <= Prompt.MaxActivationDistance and Prompt.Name == "LongPushPrompt" or Distance <= Prompt.MaxActivationDistance and Prompt.Name == "BigPropPrompt" then
    				task.spawn(Functions.TriggerPrompt, Prompt)
    			end
    		end
    	end
        Globals.LastAutoInteractFire = tick()
    end)

    Connections.InfiniteItemsHandler = Services.ProximityPromptService.PromptTriggered:Connect(function(Object)
    	if not Object:GetAttribute("FakePrompt") then return end

    	local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    	local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
    	local Tool
    	for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

    	local Prompt = Object
    	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
    	local IsLockPrompt = LockPromptNames[Object.Name]
    		or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
    		or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
    	if IsLockPrompt then
    		if Options.ab_AutoInteractIgnoreList.Value["Locks"] then return end
    		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
    		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
    		local HasKey = false
    		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
    		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
    		if not HasKey then return end
    	end

    	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
    	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
    	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
    	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end

    	if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation and Globals.UseAnimationBreak then
    		Globals.UseAnimation:Stop()
    		Globals.UseAnimationBreak:Stop()
    		Globals.UseAnimationBreak:Play()
    		if Tool.Name == "Shears" then Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end
    	end

    	local AnyTool = Character:FindFirstChildOfClass("Tool")
    	local ToolData = AnyTool and ItemNames[AnyTool.Name]
    	if AnyTool and ToolData and Toggles.ab_InfiniteItemsToggle.Value and Options.ab_InfiniteItemsList.Value[ToolData] then
    		Drops.ChildAdded:Once(function(NewTool)
    			local Prompt = NewTool:FindFirstChild("ModulePrompt")
    			local RealPrompt = FakePrompts[Object]
    			Functions.FirePrompt(Prompt)
    			Functions.FirePrompt(RealPrompt)
    		end)
    		Character.ChildAdded:Once(function(NewTool)
    			if NewTool.Name == "Shears" then NewTool:WaitForChild("Handle"):WaitForChild("sound_promptend"):Play() end
    		end)
    		RemotesFolder.DropItem:FireServer(AnyTool)
    	else
    		local RealPrompt = FakePrompts[Object]
    		Functions.FirePrompt(RealPrompt)
    	end
    end)

    Connections.FloorReplicatedHandler = FloorReplicated.DescendantAdded:Connect(function(Object)
    	if Object.Name == "GlitchScreech" then
    		Modules.GlitchScreech = Object
    		if Toggles.ab_RemoveScreech.Value then Object.Name = "GlitchScreech_Disabled" end
    	end
    	if Object.Name:find("Jumpscare") and Object:IsA("ModuleScript")
    		and not Object.Name:find("Eyestalk") and not Object.Name:find("Groundskeeper") and not Object.Name:find("Monument")
    	then
    		Object:SetAttribute("OriginalName", Object.Name)
    		if Toggles.ab_DisableEntityJumpscares.Value then Object.Name = Object.Name .. "_Disabled" end
    		table.insert(Objects.JumpscareModules, Object)
    	end
    end)

    if FloorReplicated:FindFirstChild("DigitalTimer") then
    	Connections.HasteTimerConnection = FloorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(function()
    		if Toggles.ab_NotifyHasteTime.Value then Functions.Caption(Functions.GetHasteTime(), true) end
    	end)
    end

    Connections.FogHandler = Services.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    	if Services.Lighting.FogEnd ~= 10000000 then
    		Globals.OldFog = Services.Lighting.FogEnd
    	end
    	if Toggles.ab_RemoveCameraFog.Value then
    		Services.Lighting.FogEnd = 10000000
    	end
    end)

    Connections.FogHandler2 = Services.Lighting.DescendantAdded:Connect(function(Object)
    	if not Object:IsA("Atmosphere") then return end
    	Object:SetAttribute("Density_Old", Object.Density)
    	if Toggles.ab_RemoveCameraFog.Value then Object.Density = 0 end

    	local AtmoConn2 = Object:GetPropertyChangedSignal("Density"):Connect(function()
    		if Object.Density ~= 0 then Object:SetAttribute("Density_Old", Object.Density) end
    		if Toggles.ab_RemoveCameraFog.Value then Object.Density = 0 end
    	end)
    	Object.Destroying:Once(function() AtmoConn2:Disconnect() end)
    	table.insert(Connections, AtmoConn2)
    	table.insert(Globals.FogInstances, Object)
    end)

    local RusherAliases = { Rush=true, Bash=true, Scribbles=true, DronesStampede=true, Ambush=true, Eyes=true, Lookman=true, Blitz=true, ["A-60"]=true, ["A-120"]=true, AR0xMBUSH=true, ["RNIUSHCG=="]=true, ["Custom Entity"]=true }

    local function HandleEntitySpawn(Entity)
    	if not Entity or typeof(Entity) ~= "Instance" then return end

    	local Model = Entity
    	if Entity:IsA("Humanoid") then
    		Model = Entity.Parent
    	end
    	if not Model or not Model:IsA("Model") then return end

    	local EntityData = Entities[Model.Name]
    	if not EntityData then return end
    	if Model:GetAttribute("Abysall_EntityHandled") then return end
    	Model:SetAttribute("Abysall_EntityHandled", true)

    	while not Model.PrimaryPart do
    		for _, Child in Model:GetChildren() do
    			if Child:IsA("BasePart") then Model.PrimaryPart = Child end
    		end
    		if not Model.PrimaryPart then task.wait() end
    	end
    	task.wait(0.1)

    	if not Model.PrimaryPart or LocalPlayer:DistanceFromCharacter(Model.PrimaryPart.Position) >= 10000 then return end

    	local Alias = EntityData.Alias
    	local RealAlias = Alias
    	if Options.ab_EntityList.Value[Alias] and Toggles.ab_NotifyEntities.Value then
    		local NotifyTitle = EntityData.NotifyMessage.Title
    		local NotifyBody  = EntityData.NotifyMessage.Body
    		local NotifyImage = EntityIcons[Model.Name]

    		if Model.Name == "RushMoving" and Model.PrimaryPart.Name ~= "RushNew" then
    			NotifyTitle = NotifyTitle:gsub("Rush", Model.PrimaryPart.Name)
    			NotifyImage = Model.PrimaryPart:WaitForChild("Attachment").ParticleEmitter.Texture
    			Alias = Model.PrimaryPart.Name
    		end

    		Functions.Notify({ Title = NotifyTitle, Body = NotifyBody, Image = NotifyImage, Time = Toggles.ab_NotifyKeepNotifications.Value and Model or nil })

    		if Toggles.ab_EntityChatToggle.Value then
    			Functions.SendChat(Alias .. " " .. Options.ab_EntityChatMessage.Value)
    		end
    	end

    	if Model.Name ~= "GloombatSwarm" then
    		if Toggles.ab_EntityESPToggle.Value and Options.ab_EntityESPOptions.Value[RealAlias] then
    			if Model.Name == "MonumentEntity" then
    				Functions.AddESP({ Object = Model.Top, Text = Alias, Color = Options.ab_EntityESPColor.Value })
    			else
    				Functions.AddESP({ Object = Model, Text = Alias, Color = Options.ab_EntityESPColor.Value })
    			end
    		end
    		table.insert(Objects.Entities, Model)
    	end

    	if RusherAliases[EntityData.Alias] then
    		Instance.new("Humanoid", Model).Name = "HighlightHumanoid"
    		local Root = Model.PrimaryPart
    		if Root then Root.Transparency = 0.999 Root.Material = Enum.Material.Plastic end
    	end

    	if Model.Name == "Lookman" then
    		CurrentRooms.ChildAdded:Wait()
    		task.wait(10)
    		Model:Destroy()
    	end
    end

    Connections.EntityHandler = Services.Workspace.ChildAdded:Connect(HandleEntitySpawn)
    Connections.EntityDescendantHandler = Services.Workspace.DescendantAdded:Connect(function(Descendant)
    	local EntityModel = Descendant:IsA("Humanoid") and Descendant.Parent or Descendant
    	if EntityModel and EntityModel:IsA("Model") and Entities[EntityModel.Name] then
    		task.defer(function()
    			HandleEntitySpawn(Descendant)
    		end)
    	end
    end)

    local LastClean = tick()
    Connections.Cleaner = Services.RunService.Heartbeat:Connect(function()
    	if tick() - LastClean <= 0.5 then return end
    	LastClean = tick()

    	for ArrayName, Array in Objects do
    		local I = #Array
    		while I >= 1 do
    			local Object = Array[I]
    			if Object == nil or not Object:IsDescendantOf(Services.Workspace) then
    				table.remove(Array, I)
    				local Conn = ESPConnections[Object]
    				if Conn then
    					Conn:Disconnect()
    					ESPConnections[Object] = nil
    					local Pos = table.find(Connections, Conn)
    					if Pos then table.remove(Connections, Pos) end
    				end
    			end
    			I -= 1
    		end
    	end
    end)

    local LastPromptFix = tick()
    Connections.PromptFixer = Services.RunService.Heartbeat:Connect(function()
    	if tick() - LastPromptFix <= 0.5 then return end
    	LastPromptFix = tick()
    	for _, Prompt in Objects.Prompts do
    		if Prompt:HasTag("DisableWhenEnabledOnClient") then
    			Prompt:RemoveTag("DisableWhenEnabledOnClient")
    		end
    	end
    end)

    if LocalPlayer.Character then
    	task.spawn(function() Functions.HandleCharacter(LocalPlayer.Character) end)
    end

    LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    	if Connections.MainHandler then
    		Connections.MainHandler:Disconnect()
    		Connections.MainHandler = nil
    	end
    	task.wait(0.5)
    	Functions.HandleCharacter(NewCharacter)
    end)

    Library:OnUnload(function()
    	StopTimeShower(true)
    	for Key, Connection in Connections do
    		if type(Key) == "string" then
    			pcall(function() Connection:Disconnect() end)
    		else
    			pcall(function() Key:Disconnect() end)
    			pcall(function() Connection:Disconnect() end)
    		end
    	end

    	for _, Object in Objects.Entities do
    		if Object.Name == "Snare" or Object.Name == "GiggleCeiling" then
    			local Hitbox = Object:FindFirstChild("Hitbox")
    			if Hitbox then Hitbox.CanTouch = true end
    		end
    		if Object.Name == "GloomPile" then
    			for _, Part in Object:GetDescendants() do
    				if Part:IsA("BasePart") then Part.CanTouch = true end
    			end
    		end
    		if Object.Name == "FakeDoor" or Object.Name == "DoorFake" then
    			local Hidden = Object:FindFirstChild("Hidden")
    			if Hidden then Hidden.CanTouch = true end
    			local Lock = Object:FindFirstChild("Lock")
    			if Lock and Lock:FindFirstChild("UnlockPrompt") then Lock.UnlockPrompt.Enabled = true end
    		end
    		if Object.Name == "SideroomSpace" then
    			local Coll = Object:FindFirstChild("Collision")
    			if Coll then Coll.CanCollide = false Coll.CanTouch = true end
    		end
    	end

    	for _, Object in Objects.SeekBridges do Object:Destroy() end

    	for _, Fog in Globals.FogInstances do
    		Fog.Density = Fog:GetAttribute("Density_Old")
    	end
    	Services.Lighting.FogEnd = Globals.OldFog

    	local Vignette = Safe(function() return Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette") end)
    	if Vignette then Vignette.Image = "rbxassetid://6100076320" end

    	local ModuleRestores = {
    		Screech = "Screech", Glitch = "Glitch", Shade = "Shade",
    		SpiderJumpscare = "SpiderJumpscare", A90 = "A90", Dread = "Dread", Void = "Void"
    	}
    	for Key, OriginalName in ModuleRestores do
    		if Modules[Key] then Modules[Key].Name = OriginalName end
    	end

    	FakeEvents.Screech:Destroy()
    	FakeEvents.Screech_Real.Parent = RemotesFolder
    	FakeEvents.Shade:Destroy()
    	FakeEvents.Shade_Real.Parent = RemotesFolder

    	if FakeEvents.A90_Real then
    		FakeEvents.A90:Destroy()
    		FakeEvents.A90_Real.Parent = RemotesFolder
    	end
    	if FakeEvents.Surge_Real then
    		FakeEvents.Surge:Destroy()
    		FakeEvents.Surge_Real.Parent = RemotesFolder
    	end

    	Globals.SeekNodesFolder:Destroy()
    	Globals.RoomsNodesFolder:Destroy()
    	Globals.ManipulateBody:Destroy()

    	local OldAmbient = CurrentRooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom"))):GetAttribute("Ambient")
    	Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Ambient = OldAmbient }):Play()

    	for _, Prompt in Objects.Prompts do
    		if FakePrompts[Prompt] then
    			FakePrompts[Prompt].Parent = Prompt.Parent
    			Prompt:Destroy()
    		end
    		if Prompt.Parent then
    			Prompt.HoldDuration = Prompt:GetAttribute("HoldDuration_Old") or Prompt.HoldDuration
    			Prompt.RequiresLineOfSight = Prompt:GetAttribute("RequiresLineOfSight_Old") or Prompt.RequiresLineOfSight
    			Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") or Prompt.MaxActivationDistance
    		end
    	end

    	Character:SetAttribute("CanJump",  OldJump)
    	Character:SetAttribute("CanSlide", OldSlide)

    	for _, Object in Services.Workspace:GetDescendants() do
    		task.spawn(function() Functions.RemoveESP(Object) end)
    	end

    	Humanoid.WalkSpeed  = Functions.GetCurrentSpeed()
    	Humanoid.JumpPower  = 5
    	Humanoid.HipHeight  = 2.367

    	local BaseY = 0.18
    	Collision.Position          = RootPart.Position + Vector3.new(0, BaseY, 0)
    	CollisionPart.Position      = RootPart.Position + Vector3.new(0, BaseY, 0)
    	CollisionPartClone.Position = RootPart.Position + Vector3.new(0, BaseY, 0)

    	if Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild("Root") then
    		Character.LowerTorso.Root.C1 = Globals.OriginalC1
    	end
    	if Collision:FindFirstChild("CollisionCrouch") then
    		Collision.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, -0.982, 0)
    	end

    	CollisionClone:Destroy()
    	CollisionPartClone:Destroy()
    	Abysall.ESPLibrary:Unload()

    	if Main_Game then
    		Main_Game.fovtarget   = 70
    		Main_Game.spring.Speed = 8
    		Main_Game.tooloffset   = Vector3.zero
    	end

    	if Globals.OriginalGetMoveVector then 
    		local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
    		Controls.GetMoveVector = Globals.OriginalGetMoveVector
    	end

    	getgenv().Abysall = nil
    	shared.Hastelepasta = false
    end)



    do local MainUIDeadline = os.clock() + 5
       for _ = 1, 300 do if Globals.MainUI then break end task.wait() end end

    if Window.AddSettingsTab then Window:AddSettingsTab() end
    Functions.Notify({ Title = "Successfully loaded in " .. math.floor((tick() - LoadStart) * 1000) / 1000 .. " seconds." , Body = "Press '" .. tostring(Options.MenuKeybind and Options.MenuKeybind.Value or "RightShift") .. "' to toggle the UI."})
    -- Init reached the end. In the live game that is the difference between "the menu
    -- opened" and "the features are wired": the layer used to park or throw halfway and
    -- the menu still looked fine. Read getgenv().reicht_layer_ready to check.
    getgenv().reicht_layer_ready = true
    if not Globals.MainUI then
        warn("[Reicht] layer ready without MainUI; game-UI extras stay off")
    end

end
-- ===== ABYSALL FEATURE LAYER END =====

-- Upstream verbatim: the layer above is a transplant -- it renames every option,
-- rebinds the library and stubs two components, so it can drift from the author's
-- file. This path fetches Abysall's own script and runs it untouched. That is the
-- only form of "identical" that needs no porting and cannot rot when upstream ships.
local AbysallUpstreamUrl = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"
-- Standalone copy: build.py swaps this call for the author's file as one long string,
-- so Abysall's repo dying costs refresh age, not the feature. Same bytes, same md5,
-- no network involved. Doors keeps working on a dead route.
local AbysallEmbedded = REICHT_EMBED("abysall_doors.luau")

local function RunAbysallUpstream()
    if getgenv().ReichtAbysallUpstream then
        return false, "already running"
    end
    local src, origin
    local ok, fetched = pcall(function() return game:HttpGet(AbysallUpstreamUrl) end)
    if ok and type(fetched) == "string" and #fetched >= 1024 then
        src, origin = fetched, "network"
    elseif type(AbysallEmbedded) == "string" and #AbysallEmbedded >= 1024 then
        src, origin = AbysallEmbedded, "embedded"
    else
        return false, "fetch failed and the embedded copy is missing"
    end
    local chunk, compileErr = loadstring(src)
    if not chunk then
        return false, tostring(compileErr)
    end
    getgenv().ReichtAbysallUpstream = true
    -- The marker is the evidence: a proof can see which route supplied the bytes, how
    -- big the author's file was, and that an offline copy exists at all.
    local marker = Instance.new("Folder")
    marker.Name = "AbysallUpstream"
    marker:SetAttribute("Loaded", true)
    marker:SetAttribute("Bytes", #src)
    marker:SetAttribute("Source", origin)
    marker:SetAttribute("EmbeddedReady", type(AbysallEmbedded) == "string" and #AbysallEmbedded >= 1024)
    marker:SetAttribute("EmbeddedBytes", type(AbysallEmbedded) == "string" and #AbysallEmbedded or 0)
    task.spawn(function()
        local ran, err = pcall(chunk)
        if not ran then
            getgenv().ReichtAbysallUpstream = false
            marker:SetAttribute("Failed", true)
            warn("[Reicht] Abysall upstream failed: " .. tostring(err))
        end
    end)
    return true, tostring(#src) .. " bytes"
end

-- Doors now carries one feature source: the Abysall layer above. The Lonely Hub
-- tabs, the merge layer and every callback that came from the other public hubs
-- are gone, so Run() only has to hand the layer our window.
local function Run()
    __abysallLayer(Library, Window)
    local UpstreamTab = Window:AddTab("Upstream", "link")
    local UpstreamBox = UpstreamTab:AddLeftGroupbox("Abysall (verbatim)")
    UpstreamBox:AddToggle("RunAbysallUpstream", {
        Text = "Run Abysall's own script",
        Default = false,
        Tooltip = "Fetches and runs the author's Doors script as shipped, no porting. It opens its own window.",
        Callback = function(Value)
            if not Value then return end
            local loaded, detail = RunAbysallUpstream()
            if loaded then
                Alert("Abysall upstream running: " .. tostring(detail))
            else
                Alert("Abysall upstream: " .. tostring(detail))
            end
        end
    })
    UpstreamBox:AddButton({
        Text = "Abysall source URL",
        Func = function()
            Alert(AbysallUpstreamUrl)
        end
    })
    Script.Functions.UpdateRPC()
    getgenv().lonelyhub_loaded = true
end

local ok, err = xpcall(Run, debug.traceback)
if not ok then
    getgenv().lonelyhub_loaded = false
    Alert("Lonely Hub error: " .. tostring(err))
end
