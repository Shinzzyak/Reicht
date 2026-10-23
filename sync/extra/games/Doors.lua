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

local WhitelistConfig = {
    [45] = {firstKeep = 3, lastKeep = 2},
    [46] = {firstKeep = 2, lastKeep = 2},
    [47] = {firstKeep = 2, lastKeep = 2},
    [48] = {firstKeep = 2, lastKeep = 2},
    [49] = {firstKeep = 2, lastKeep = 4},
}

local SuffixPrefixes = {
    ["Backdoor"] = "",
    ["Ceiling"] = "",
    ["Moving"] = "",
    ["Ragdoll"] = "",
    ["Rig"] = "",
    ["Wall"] = "",
    ["Clock"] = " Clock",
    ["Key"] = " Key",
    ["Pack"] = " Pack",
    ["Pointer"] = " Pointer",
    ["Swarm"] = " Swarm",
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
local CutsceneExclude = {
    "FigureHotelChase",
    "Elevator1",
    "MinesFinale"
}
local SlotsName = {
    "Oval",
    "Square",
    "Tall",
    "Wide"
}

local PromptTable = {
    GamePrompts = {},

    Aura = {
        ["ActivateEventPrompt"] = false,
        ["AwesomePrompt"] = true,
        ["FusesPrompt"] = true,
        ["HerbPrompt"] = false,
        ["LeverPrompt"] = true,
        ["LootPrompt"] = false,
        ["ModulePrompt"] = true,
        ["SkullPrompt"] = false,
        ["UnlockPrompt"] = true,
        ["ValvePrompt"] = false,
        ["PropPrompt"] = true
    },
    AuraObjects = {
        "Lock",
        "Button"
    },

    Clip = {
        "AwesomePrompt",
        "FusesPrompt",
        "HerbPrompt",
        "HidePrompt",
        "LeverPrompt",
        "LootPrompt",
        "ModulePrompt",
        "Prompt",
        "PushPrompt",
        "SkullPrompt",
        "UnlockPrompt",
        "ValvePrompt"
    },
    ClipObjects = {
        "LeverForGate",
        "LiveBreakerPolePickup",
        "LiveHintBook",
        "Button",
    },

    Excluded = {
        Prompt = {
            "HintPrompt",
            "InteractPrompt"
        },

        Parent = {
            "KeyObtainFake",
            "Padlock"
        },

        ModelAncestor = {
            "DoorFake"
        }
    }
}

local HideTimeValues = {
    {min = 1, max = 5, a = -1/6, b = 1, c = 20},
    {min = 6, max = 19, a = -1/13, b = 6, c = 19},
    {min = 19, max = 22, a = -1/4, b = 19, c = 18},
    {min = 23, max = 26, a = 1/3, b = 23, c = 18},
    {min = 26, max = 30, a = -1/4, b = 26, c = 19},
    {min = 30, max = 35, a = -1/3, b = 30, c = 18},
    {min = 36, max = 60, a = -1/12, b = 36, c = 18},
    {min = 60, max = 90, a = -1/30, b = 60, c = 16},
    {min = 90, max = 99, a = -1/6, b = 90, c = 15}
}


local RBXGeneral = TextChatService.TextChannels.RBXGeneral

--// Exploits Variables \\--
local fireTouch = firetouchinterest or firetouchtransmitter
local firePrompt = ExecutorSupport["fireproximityprompt"] and fireproximityprompt or _fireproximityprompt
local forceFirePrompt = ExecutorSupport["fireproximityprompt"] and fireproximityprompt or _forcefireproximityprompt
local isnetowner = ExecutorSupport["isnetworkowner"] and isnetworkowner or _isnetworkowner

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
local alive = localPlayer:GetAttribute("Alive")
local humanoid: Humanoid
local rootPart: BasePart
local collision
local collisionClone
local velocityLimiter

--// DOORS Variables \\\--
local entityModules = ReplicatedStorage:WaitForChild("ClientModules", 3) or Inert("Folder", "ClientModules")
entityModules = entityModules:WaitForChild("EntityModules", 3) or Inert("Folder", "EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData", 3) or Inert("Folder", "GameData")
local floor = gameData:WaitForChild("Floor", 3) or Inert("StringValue", "Floor")
local latestRoom = gameData:WaitForChild("LatestRoom", 3) or Inert("IntValue", "LatestRoom")

local liveModifiers = ReplicatedStorage:WaitForChild("LiveModifiers", 3) or Inert("Folder", "LiveModifiers")

local isMines = floor.Value == "Mines"
local isRooms = floor.Value == "Rooms"
local isHotel = floor.Value == "Hotel"
local isBackdoor = floor.Value == "Backdoor"
local isFools = floor.Value == "Fools"
local isRetro = floor.Value == "Retro"

local floorReplicated = if not isFools then ReplicatedStorage:WaitForChild("FloorReplicated", 3) or Inert("Folder", "FloorReplicated") else nil
local remotesFolder = if not isFools then ReplicatedStorage:WaitForChild("RemotesFolder", 3) or Inert("Folder", "RemotesFolder") else ReplicatedStorage:WaitForChild("EntityInfo", 3) or Inert("Folder", "EntityInfo")

--// Player DOORS Variables \\\--
local currentRoom = localPlayer:GetAttribute("CurrentRoom") or 0
local nextRoom = currentRoom + 1

local mainUI = playerGui:WaitForChild("MainUI", 3) or Inert("Folder", "MainUI")
local mainGame = mainUI:WaitForChild("Initiator", 3) or Inert("Folder", "Initiator")
mainGame = mainGame:WaitForChild("Main_Game", 3) or Inert("ModuleScript", "Main_Game")
-- Only require something that really is a module: an inert placeholder would raise
-- and take the whole script down with it.
local mainGameSrc = if ExecutorSupport["require"] and mainGame:IsA("ModuleScript") then require(mainGame) else nil
local controlModule = if ExecutorSupport["require"] then require((playerScripts:WaitForChild("PlayerModule", 3) or Inert("Folder", "PlayerModule")):WaitForChild("ControlModule", 3) or Inert("ModuleScript", "ControlModule")) else nil

--// Other Variables \\--
local speedBypassing = false

local lastSpeed = 0
local bypassed = false

local MinecartPathNodeColor = {
    Disabled = nil,
    Red = Color3.new(1, 0, 0),
    Yellow = Color3.new(1, 1, 0),
    Purple = Color3.new(1, 0, 1),
    Green = Color3.new(0, 1, 0),
    Cyan = Color3.new(0, 1, 1),
    Orange = Color3.new(1, 0.5, 0),
    White = Color3.new(1, 1, 1),
}

local MinecartPathfind = {
    -- ground chase [41 to 44]
    -- minecart chase [45 to 49]
}

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

local UI_URL = "https://raw.githubusercontent.com/Shinzzyak/Reicht/refs/heads/main/ui.lua"
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
    Alert("Missing game objects: " .. table.concat(Missing, ", ") .. " - menu still opens, features that need them stay off.")
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

local function LinTab(tab)
    local t = {}
    function t:AddLeftGroupbox(name) return LinGroup(tab:AddLeftGroupbox(name)) end
    function t:AddRightGroupbox(name) return LinGroup(tab:AddRightGroupbox(name)) end
    function t:AddLeftTabbox() return LinTabbox(tab, "left") end
    function t:AddRightTabbox() return LinTabbox(tab, "right") end
    return t
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
        label.Font = Enum.Font.Code
        label.TextSize = spec.TextSize or 16
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
                    tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
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
local TAB_ORDER = {
    { "Main", "Main", "rbxassetid://10734975692" },
    { "Exploits", "Exploits", "rbxassetid://7733960981" },
    { "Visuals", "Visuals", "rbxassetid://10709819149" },
    { "Floor", "Floor", "rbxassetid://10723415903" },
    { "UI Settings", "UI Settings", "rbxassetid://7734052335" },
    -- Merged sources: entity modules, item givers and the survival toggles the
    -- other public DOORS hubs ship. Payload tabs above keep their positions.
    { "Spawner", "Spawner", "rbxassetid://11372950109" },
    { "Items", "Items", "rbxassetid://4483345998" },
    { "Survival", "Survival", "rbxassetid://10734975692" },
}

local Tabs = {}
for _, spec in ipairs(TAB_ORDER) do
    Tabs[spec[1]] = LinTab(Window:AddTab(spec[2], spec[3]))
end
Window:AddSettingsTab()

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
    local function passthrough(name)
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

    -- ESP bridge. Abysall drives one shared renderer through Set*/AddESP/RemoveESP; the
    -- same knobs already exist on Reicht's ESPLibrary, so the setters write there and
    -- AddESP/RemoveESP own a Highlight + label pair per object.
    local ESP = {
        Objects = {},
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
    ESP.SetRainbow = setter("Rainbow")
    ESP.SetTracers = setter("Tracers")
    ESP.SetShowDistance = setter("ShowDistance")
    ESP.SetArrows = setter("Arrows")
    ESP.SetTextTransparency = setter("TextTransparency")
    ESP.SetFillTransparency = setter("FillTransparency")
    ESP.SetOutlineTransparency = setter("OutlineTransparency")
    ESP.SetTextOutlineTransparency = setter("TextOutlineTransparency")
    ESP.SetFadeTime = setter("FadeTime")
    ESP.SetRenderLimit = setter("RenderLimit")
    ESP.SetTracerSize = setter("TracerSize")
    ESP.SetArrowRadius = setter("ArrowRadius")
    ESP.SetTextSize = setter("TextSize")
    ESP.SetDistanceSizeRatio = setter("DistanceSizeRatio")
    ESP.SetFont = setter("Font")
    ESP.SetTracerOrigin = setter("TracerOrigin")
    ESP.SetTracersOrigin = setter("TracerOrigin")
    ESP.GenerateRandomString = function(_, len)
        local out = {}
        for i = 1, (len or 8) do out[i] = string.char(math.random(97, 122)) end
        return table.concat(out)
    end
    ESP.ColorTable = function(_, color)
        return { Color = color, Rainbow = false, Transparency = 0 }
    end
    ESP.UpdateObjectColor = function(_, object, color)
        local entry = ESP.Objects[object]
        if not entry then return end
        if entry.Highlight then entry.Highlight.FillColor = color; entry.Highlight.OutlineColor = color end
        if entry.Label then entry.Label.TextColor3 = color end
    end
    ESP.AddESP = function(_, object, options)
        if not object or ESP.Objects[object] then return end
        options = options or {}
        local entry = {}
        local okHighlight, highlight = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "ReichtAbysallESP"
            h.FillColor = options.Color or Color3.fromRGB(255, 255, 255)
            h.OutlineColor = options.Color or Color3.fromRGB(255, 255, 255)
            h.FillTransparency = options.FillTransparency or S.FillTransparency
            h.OutlineTransparency = options.OutlineTransparency or S.OutlineTransparency
            h.Adornee = object
            h.Parent = object
            return h
        end)
        if okHighlight then entry.Highlight = highlight end
        ESP.Objects[object] = entry
        return entry
    end
    ESP.RemoveESP = function(_, object)
        local entry = ESP.Objects[object]
        if not entry then return end
        if entry.Highlight then pcall(function() entry.Highlight:Destroy() end) end
        if entry.Label then pcall(function() entry.Label:Destroy() end) end
        ESP.Objects[object] = nil
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

    local Character
    local Humanoid
    local RootPart

    local Collision
    local CollisionClone
    local CollisionPart
    local CollisionPartClone

    local Camera

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




    -- info tab: Reicht ships its own

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
    		print("started")

    		local currentRooms

    		repeat
    			if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    				return
    			end
    			currentRooms = workspace:FindFirstChild("CurrentRooms")
    			task.wait()
    		until currentRooms

    		print("got currentrooms")

    		local lastTriggerRoom = nil

    		while Toggles.ab_SkipSeekHotel.Value and Floor == "Hotel" do
    			local triggerRoom = nil

    			print("waiting for trigger")

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
    							print("found trigger in", triggerRoom)
    						end
    					end
    				end

    				task.wait()
    			until triggerRoom

    			lastTriggerRoom = triggerRoom

    			local roomNum = triggerRoom

    			while Toggles.ab_SkipSeekHotel.Value and Floor == "Hotel" do
    				roomNum += 1
    				print("looking for room", roomNum)

    				local room
    				repeat
    					if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    						return
    					end
    					currentRooms = workspace:FindFirstChild("CurrentRooms")
    					room = currentRooms and currentRooms:FindFirstChild(tostring(roomNum))
    					task.wait()
    				until room

    				print("found room", roomNum)

    				local hasSeekArm = false
    				local assets = room:FindFirstChild("Assets")
    				if assets then
    					for _, child in ipairs(assets:GetChildren()) do
    						if child.Name == "Seek_Arm" then
    							hasSeekArm = true
    							print("found seek arm")
    							break
    						end
    					end
    				end

    				local door
    				repeat
    					if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    						return
    					end
    					door = room:FindFirstChild("Door", true)
    					task.wait()
    				until door

    				print("found door, teleporting")

    				repeat
    					if not Toggles.ab_SkipSeekHotel.Value or Floor ~= "Hotel" then
    						return
    					end
    					if Character then
    						Character:PivotTo(door:GetPivot())
    					end
    					task.wait()
    				until door:GetAttribute("Opened") == true

    				print("door opened")

    				if hasSeekArm then
    					if not Character then
    						return
    					end

    					print("voiding")

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

    					print("done voiding")
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

    							fireproximityprompt(AutoLibraryPromptDescendant)
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

    							fireproximityprompt(AutoLibraryPromptDescendant)
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
    				fireproximityprompt(AutoBreakerRoomObject)
    				return
    			end

    			for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoomObject:GetDescendants()) do
    				if AutoBreakerRoomDescendant:IsA("ProximityPrompt") then
    					fireproximityprompt(AutoBreakerRoomDescendant)
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
    				fireproximityprompt(AutoHotelDesc)
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
    						fireproximityprompt(AutoHotelPrompt)
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
    						fireproximityprompt(AutoHotelPrompt)
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
    						fireproximityprompt(Prompt)
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

    							if Prompt.Parent and Prompt.Enabled and fireproximityprompt then
    								fireproximityprompt(Prompt)
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
    					fireproximityprompt(InfCrucifixPrompt)
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
    	local Jam = Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam")
    	if Jam then
    		Jam.Volume = Value and 0 or 0.45
    		Globals.JamMuffle.Enabled = LiveModifiers:FindFirstChild("Jammin") and not Value or false
    	end
    end)
    Toggles.ab_RemoveInteractingSounds:OnChanged(function(Value)
    	local PS = Globals.MainUI.Initiator.Main_Game.PromptService
    	PS.Triggered.Volume   = Value and 0 or 0.04
    	PS.Holding.Volume     = Value and 0 or 0.1
    	PS.Notification.Volume = Value and 0 or 0.03
    	Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = Value and 0 or 0.1
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
        local Cutscenes = Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes
        for _, Object in pairs(Cutscenes:GetChildren()) do
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
    	Modules.SpiderJumpscare.Name = Value and "SpiderJumpscare_Disabled" or "SpiderJumpscare"
    end)
    Toggles.ab_DisableVoidJumpscare:OnChanged(function(Value)
    	if Modules.Void then Modules.Void.Name = Value and "Void_Disabled" or "Void" end
    end)
    Toggles.ab_DisableHideVignette:OnChanged(function(Value)
    	local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
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
    	local Jumpscares = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
    		or Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares_Disabled")
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
    		toclipboard([==[
    			loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Scripts/DeathFarm.luau"))()
    		]==])
    		Library:Notify("Loadstring has been copied to your clipboard.")
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
    Connections.KnobFarm = Services.RunService.Heartbeat:Connect(function()
    	if Toggles.ab_KnobFarm.Value and Globals.KnobFarmStarted then
    		if not Globals.KnobFarmActive then
    			Globals.KnobFarmActive = true
    			if Functions.CheckCompatability({"replicatesignal"}) then
    				Abysall.Environment.replicatesignal(LocalPlayer.Kill)
    			else
    				LocalPlayer.Character.Humanoid.Health = 0
    			end
    			while task.wait() do
    				if LocalPlayer:GetAttribute("Alive") then
    					break
    				end
    			end
    			RemotesFolder.Statistics:FireServer()
    			task.wait(0.25)
    			Globals.KnobFarmActive = false
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

    	while not LocalPlayer.PlayerGui:FindFirstChild("MainUI") do
    		task.wait()
    	end

    	Character = NewCharacter
    	Humanoid = NewCharacter:WaitForChild("Humanoid", 9e9)
    	RootPart = NewCharacter:FindFirstChild("HumanoidRootPart")
    	Camera   = Services.Workspace.CurrentCamera

    	Globals.OldCamera = Camera
    	Globals.MainUI = LocalPlayer.PlayerGui.MainUI

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

    	if Functions.CheckCompatability({"require"}) then
    		Main_Game = Abysall.Environment.require(Globals.MainUI.Initiator.Main_Game)
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

    	local UIModules = Globals.MainUI.Initiator.Main_Game.RemoteListener.Modules
    	Modules.A90             = UIModules:FindFirstChild("A90")
    	Modules.Screech         = UIModules.Screech
    	Modules.Dread           = UIModules:FindFirstChild("Dread")
    	Modules.SpiderJumpscare = UIModules.SpiderJumpscare

    	if Toggles.ab_RemoveScreech.Value    then Modules.Screech.Name = "Screech_Disabled" print ("screech gone") end
    	if Toggles.ab_RemoveA90.Value and Modules.A90   then Modules.A90.Name = "A90_Disabled" end
    	if Toggles.ab_RemoveDread.Value and Modules.Dread then Modules.Dread.Name = "Dread_Disabled" end
    	if Toggles.ab_DisableTimothyJumpscare.Value then Modules.SpiderJumpscare.Name = "SpiderJumpscare_Disabled" end

    	if Toggles.ab_DisableHideVignette.Value then
    		local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
    		if Vignette then Vignette.Image = "Disabled" end
    	end
    	if Toggles.ab_RemoveInteractingSounds.Value then
    		local PS = Globals.MainUI.Initiator.Main_Game.PromptService
    		PS.Triggered.Volume = 0
    		PS.Holding.Volume   = 0
    		PS.Notification.Volume = 0
    		Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = 0
    	end
    	if Toggles.ab_DisableEntityJumpscares.Value then
    		local JS = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
    		if JS then JS.Name = "Jumpscares_Disabled" end
    	end
        local Cutscenes = Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes
        for _, Object in pairs(Cutscenes:GetChildren()) do
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

    	local JumpButton = Globals.MainUI.MainFrame.MobileButtons:FindFirstChild("JumpButton")
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

    	local MainFrame = Globals.MainUI:FindFirstChild("MainFrame")
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

    	local Jam = Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam")
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
    				Prompt:InputHoldBegin()
    				Prompt:InputHoldEnd()
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
    		local Effects = Globals.MainUI.MainFrame.Healthbar:FindFirstChild("Effects")
    		if Effects and Effects.HerbGreenEffect.Visible then return end
    	end

    	if (Prompt.Parent.Name == "LibraryHintPaper" or Prompt.Parent.Name == "PickupItem") and (Functions.HasItem("LibraryHintPaper") or Functions.HasItem("LibraryHintPaperHard")) then return end
    	if Prompt.Parent.Name == "AlarmClock" and Functions.HasItem("AlarmClock") then return end
    	if Prompt.Parent.Name == "KeyObtainFake" or Prompt.Parent.Name == "TithingPlate" then return end
    	if Prompt.Parent.Name == "StarBottle" then return end
        -- archives
    	if Prompt.parent.Name == "ArchivesStorageBox" then return end
    	if Prompt.Parent.Name == "Briefcase" then return end
    	if Prompt.Name == "SinkPrompt" or Prompt.Parent.Name == "Faucet" then return end
    	if Prompt.Parent.Name == "PaperPlanePickup" or Prompt.Parent.Name == "PaperPlane" then return end
    	if Prompt.Name == "ManualOpenPrompt" or Prompt.Name == "EntryPrompt" then return end
    	if Prompt.Parent.Parent.Name == "ArchivesLargePrinter" then return end
    	if Prompt.Name == "TrashcanPrompt" then return end
    	if Prompt.Parent.Name == "Keyboard" then return end
    	if Prompt.Name == "CartPrompt" or Prompt.Parent.Parent.Name == "ArchivesOfficeChair" then return end
    	if Prompt.Parent.Name == "ArchivesTerminal" then return end
    	if Prompt.Name == "VendorPrompt" then return end
        if Prompt.Parent.Name == "SeatPart" or Prompt.Name == "SeatPrompt" then return end


    	-- Stairwell
    	if Prompt.Parent.Name == "StairwellScrapper" then return end
    	if Prompt.Name == "PortraitDupePrompt" or Prompt.Parent.Name == "MirrorTool" then return end
    	if Prompt.Name == "LaptopPrompt" or Prompt.Parent.Name == "SecretLaptop" then return end
    	if Prompt.Parent.Name == "StairwellFireAlarm" or Prompt.Parent.Parent.Name == "StairwellFireAlarm" then return end
    	if Prompt.Parent.name == "CobblerFriendly" then return end
    	if Prompt.Parent.Name == "StairwellTerminal" then return end
    	if Prompt.Parent.Parent.Name == "MeldChord" then return end

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

    	local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
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

    -- settings tab: Reicht ships its own
    Functions.Notify({ Title = "Successfully loaded in " .. math.floor((tick() - LoadStart) * 1000) / 1000 .. " seconds." , Body = "Press '" .. tostring(Options.MenuKeybind.Value) .. "' to toggle the UI."})

end
-- ===== ABYSALL FEATURE LAYER END =====

local function Run()
--// Captions \\--
local _lonelyhub_custom_captions = Instance.new("ScreenGui") do
    local Frame = Instance.new("Frame", _lonelyhub_custom_captions)
    local TextLabel = Instance.new("TextLabel", Frame)
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint", TextLabel)

    _lonelyhub_custom_captions.Parent = ReplicatedStorage
    _lonelyhub_custom_captions.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Library.MainColor
    Frame.BorderColor3 = Library.AccentColor
    Frame.BorderSizePixel = 2
    Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
    Frame.Size = UDim2.new(0, 200, 0, 75)

    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.Code
    TextLabel.Text = ""
    TextLabel.TextColor3 = Library.FontColor
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true

    UITextSizeConstraint.MaxTextSize = 35

    function Script.Functions.HideCaptions()
        _lonelyhub_custom_captions.Parent = ReplicatedStorage
    end

    local CaptionsLastUsed = os.time()
    function Script.Functions.Captions(caption: string)
        CaptionsLastUsed = os.time()
        if _lonelyhub_custom_captions.Parent == ReplicatedStorage then _lonelyhub_custom_captions.Parent = gethui() or game:GetService("CoreGui") or playerGui end
        
        TextLabel.Text = caption

        task.spawn(function()
            task.wait(5)
            if os.time() - CaptionsLastUsed >= 5 then
                Script.Functions.HideCaptions()
            end
        end)
    end
end

--// Functions \\--
getgenv()._internal_unload_lonelyhub = function()
    Library:Unload()
end

function Script.Functions.CalculateHideTime(room: number)
    for _, range in ipairs(HideTimeValues) do
        if room >= range.min and room <= range.max then
            return math.round(range.a * (room - range.b) + range.c)
        end
    end    

    return nil
end

function Script.Functions.RandomString()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

function Script.Functions.EnforceTypes(args, template)
    args = type(args) == "table" and args or {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or (value ~= nil and type(argValue) ~= type(value)) then
            args[key] = value
        elseif type(value) == "table" then
            args[key] = Script.Functions.EnforceTypes(argValue, value)
        end
    end

    return args
end

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

--// Notification Functions \\--
do
    function Script.Functions.Warn(message: string)
        warn("WARN - Lonely Hub:", message)
    end

    function Script.Functions.Notifs.Doors.Notify(unsafeOptions)
        assert(typeof(unsafeOptions) == "table", "Expected a table as options argument but got " .. typeof(unsafeOptions))
        if not mainUI then return end
        
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Title = "No Title",
            Description = "No Text",
            Reason = "",
            NotificationType = "NOTIFICATION",
            Image = "6023426923",
            Color = nil,
            Time = nil,
    
            TweenDuration = 0.8
        })
    
    
        local acheivement = mainUI.AchievementsHolder.Achievement:Clone()
        acheivement.Size = UDim2.new(0, 0, 0, 0)
        acheivement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
        acheivement.Name = "LiveAchievement"
        acheivement.Visible = true
    
        acheivement.Frame.TextLabel.Text = options.NotificationType
    
        if options.Color ~= nil then
            acheivement.Frame.TextLabel.TextColor3 = options.Color
            acheivement.Frame.UIStroke.Color = options.Color
            acheivement.Frame.Glow.ImageColor3 = options.Color
        end
        
        acheivement.Frame.Details.Desc.Text = tostring(options.Description)
        acheivement.Frame.Details.Title.Text = tostring(options.Title)
        acheivement.Frame.Details.Reason.Text = tostring(options.Reason or "")
    
        if options.Image:match("rbxthumb://") or options.Image:match("rbxassetid://") then
            acheivement.Frame.ImageLabel.Image = tostring(options.Image or "rbxassetid://0")
        else
            acheivement.Frame.ImageLabel.Image = "rbxassetid://" .. tostring(options.Image or "0")
        end
    
        acheivement.Parent = mainUI.AchievementsHolder
        acheivement.Sound.SoundId = "rbxassetid://10469938989"
    
        acheivement.Sound.Volume = 1
    
        if Toggles.NotifySound.Value then
            acheivement.Sound:Play()
        end
    
        task.spawn(function()
            acheivement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", options.TweenDuration, true)
        
            task.wait(0.8)
        
            acheivement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
        
            TweenService:Create(acheivement.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{
                ImageTransparency = 1
            }):Play()
        
            if options.Time ~= nil then
                if typeof(options.Time) == "number" then
                    task.wait(options.Time)
                elseif typeof(options.Time) == "Instance" then
                    options.Time.Destroying:Wait()
                end
            else
                task.wait(5)
            end
        
            acheivement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
            task.wait(0.5)
            acheivement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
            task.wait(0.5)
            acheivement:Destroy()
        end)
    end
    
    function Script.Functions.Notifs.Doors.Warn(options)
        assert(typeof(options) == "table", "Expected a table as options argument but got " .. typeof(options))
    
        options["NotificationType"] = "WARNING"
        options["Color"] = Color3.new(1, 0, 0)
        options["TweenDuration"] = 0.3
    
        Script.Functions.Notifs.Doors.Notify(options)
    end
    
    function Script.Functions.Notifs.Linoria.Notify(unsafeOptions)
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Description = "No Message",
            Time = nil
        })
    
        Library:Notify(options.Description, options.Time or 5)
    
        if Toggles.NotifySound.Value then
            local sound = Instance.new("Sound", SoundService) do
                sound.SoundId = "rbxassetid://4590662766"
                sound.Volume = 2
                sound.PlayOnRemove = true
                sound:Destroy()
            end
        end
    end
    
    function Script.Functions.Notifs.Linoria.Log(unsafeOptions, condition: boolean | nil)
        local options = Script.Functions.EnforceTypes(unsafeOptions, {
            Description = "No Message",
            Time = nil
        })
    
        if condition ~= nil and not condition then return end
        Library:Notify(options.Description, options.Time or 5)
    end
    
    function Script.Functions.Alert(options)
        repeat task.wait() until getgenv().lonelyhub_loaded
    
        if Options.NotifyStyle.Value == "Linoria" then
            local linoriaMessage = options["LinoriaMessage"] or options.Description
            options.Description = linoriaMessage
            
            Script.Functions.Notifs.Linoria.Notify(options)
        elseif Options.NotifyStyle.Value == "Doors" and not options.Warning then
            Script.Functions.Notifs.Doors.Notify(options)
        elseif Options.NotifyStyle.Value == "Doors" and options.Warning then
            options["Warning"] = nil
    
            Script.Functions.Notifs.Doors.Warn(options)
        end
    end
    
    function Script.Functions.Log(options, condition: boolean | nil)
        repeat task.wait() until getgenv().lonelyhub_loaded
        
        if Options.NotifyStyle.Value == "Linoria" then
            local linoriaMessage = options["LinoriaMessage"] or options.Description
            options.Description = linoriaMessage
            
            Script.Functions.Notifs.Linoria.Log(options, condition)
        elseif Options.NotifyStyle.Value == "Doors" then
            if not condition and typeof(condition) == "boolean" then return end
    
            options["NotificationType"] = "LOGGING"
            options["Color"] = Color3.fromRGB(0, 102, 255)
    
            Script.Functions.Notifs.Doors.Notify(options)
        end
    end
end

--// Player Functions \\--
do
    function Script.Functions.DistanceFromCharacter(position: Instance | Vector3, getPositionFromCamera: boolean | nil)
        if not position then return 9e9 end
        if typeof(position) == "Instance" then
            position = position:GetPivot().Position
        end
    
        if getPositionFromCamera and (camera or workspace.CurrentCamera) then
            local cameraPosition = camera and camera.CFrame.Position or workspace.CurrentCamera.CFrame.Position
    
            return (cameraPosition - position).Magnitude
        end
    
        if rootPart then
            return (rootPart.Position - position).Magnitude
        elseif camera then
            return (camera.CFrame.Position - position).Magnitude
        end
    
        return 9e9
    end

    function Script.Functions.IsInViewOfPlayer(instance: Instance, range: number | nil, exclude: table | nil)
        if not instance then return false end
        if not collision then return false end
    
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
        local filter = exclude or {}
        table.insert(filter, character)
    
        raycastParams.FilterDescendantsInstances = filter
    
        local direction = (instance:GetPivot().Position - collision.Position).unit * (range or 9e9)
        local raycast = workspace:Raycast(collision.Position, direction, raycastParams)
    
        if raycast and raycast.Instance then
            if raycast.Instance:IsDescendantOf(instance) or raycast.Instance == instance then
                return true
            end
    
            return false
        end
    
        return false
    end
end

--// ESP Functions \\--
do
    function Script.Functions.ESP(args: ESP)
        if not args.Object then return Script.Functions.Warn("ESP Object is nil") end
    
        local ESPManager = {
            Object = args.Object,
            Text = args.Text or "No Text",
            Color = args.Color or Color3.new(),
            Offset = args.Offset or Vector3.zero,
            IsEntity = args.IsEntity or false,
            IsDoubleDoor = args.IsDoubleDoor or false,
            Type = args.Type or "None",
            OnDestroy = args.OnDestroy or nil,
    
            Invisible = false,
            Humanoid = nil
        }
    
        if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
            if ESPManager.Object.PrimaryPart.Transparency == 1 then
                ESPManager.Invisible = true
                ESPManager.Object.PrimaryPart.Transparency = 0.99
            end
    
            local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
            if not humanoid then humanoid = Instance.new("Humanoid", ESPManager.Object) end
            ESPManager.Humanoid = humanoid
        end
    
        local ESPInstance = ESPLibrary.ESP.Highlight({
            Name = ESPManager.Text,
            Model = ESPManager.Object,
            StudsOffset = ESPManager.Offset,
    
            FillColor = ESPManager.Color,
            OutlineColor = ESPManager.Color,
            TextColor = ESPManager.Color,
            TextSize = Options.ESPTextSize.Value or 16,

            FillTransparency = Options.ESPFillTransparency.Value,
            OutlineTransparency = Options.ESPOutlineTransparency.Value,
    
            Tracer = {
                Enabled = Toggles.ESPTracer.Value,
                From = Options.ESPTracerStart.Value,
                Color = ESPManager.Color
            },
    
            OnDestroy = ESPManager.OnDestroy or function()
                if ESPManager.Object.PrimaryPart and ESPManager.Invisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
                if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
            end
        })
    
        table.insert(Script.ESPTable[args.Type], ESPInstance)
    
        return ESPInstance
    end
    
    function Script.Functions.DoorESP(room)
        local door = room:WaitForChild("Door", 5)
    
        if door then
            local doorNumber = tonumber(room.Name) + 1
            if isMines then
                doorNumber += 100
            end
    
            local opened = door:GetAttribute("Opened")
            local locked = room:GetAttribute("RequiresKey")
    
            local doorState = if opened then "[Opened]" elseif locked then "[Locked]" else ""
            local doorIdx = Script.Functions.RandomString()
    
            local doorEsp = Script.Functions.ESP({
                Type = "Door",
                Object = door:WaitForChild("Door"),
                Text = string.format("Door %s %s", doorNumber, doorState),
                Color = Options.DoorEspColor.Value,
    
                OnDestroy = function()
                    if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
                end
            })
    
            Script.FeatureConnections.Door[doorIdx] = door:GetAttributeChangedSignal("Opened"):Connect(function()
                if doorEsp then doorEsp.SetText(string.format("Door %s [Opened]", doorNumber)) end
                if Script.FeatureConnections.Door[doorIdx] then Script.FeatureConnections.Door[doorIdx]:Disconnect() end
            end)
        end
    end 
    
    function Script.Functions.ObjectiveESP(child)
        -- Backdoor
        if child.Name == "TimerLever" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = string.format("Timer Lever [+%s]", child.TakeTimer.TextLabel.Text),
                Color = Options.ObjectiveEspColor.Value
            })
        -- Backdoor + Hotel
        elseif child.Name == "KeyObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Key",
                Color = Options.ObjectiveEspColor.Value
            })
        -- Hotel
        elseif child.Name == "ElectricalKeyObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Electrical Key",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LeverForGate" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Gate Lever",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LiveHintBook" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Book",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "LiveBreakerPolePickup" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Breaker",
                Color = Options.ObjectiveEspColor.Value
            })
        -- Mines
        elseif child.Name == "MinesGenerator" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Generator",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "MinesGateButton" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Gate Power Button",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "FuseObtain" then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = "Fuse",
                Color = Options.ObjectiveEspColor.Value
            })
        elseif child.Name == "MinesAnchor" then
            local sign = child:WaitForChild("Sign", 5)
    
            if sign and sign:FindFirstChild("TextLabel") then
                Script.Functions.ESP({
                    Type = "Objective",
                    Object = child,
                    Text = string.format("Anchor %s", sign.TextLabel.Text),
                    Color = Options.ObjectiveEspColor.Value
                })
            end
        elseif child.Name == "WaterPump" then
            local wheel = child:WaitForChild("Wheel", 5)
            local onFrame = child:FindFirstChild("OnFrame", true)
    
            if wheel and (onFrame and onFrame.Visible) then
                local pumpIdx = Script.Functions.RandomString()

                local pumpEsp = Script.Functions.ESP({
                    Type = "Objective",
                    Object = wheel,
                    Text = "Water Pump",
                    Color = Options.ObjectiveEspColor.Value,

                    OnDestroy = function()
                        if Script.FeatureConnections.Pump[pumpIdx] then Script.FeatureConnections.Pump[pumpIdx]:Disconnect() end
                    end
                })

                Script.FeatureConnections.Pump[pumpIdx] = onFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                    if pumpEsp then pumpEsp.Destroy() end
                end)
            end
        end
    end
    
    function Script.Functions.EntityESP(entity)
        if not EntityESPFilter.Allows(entity) then return end
        Script.Functions.ESP({
            Type = "Entity",
            Object = entity,
            Text = Script.Functions.GetEntityName(entity.Name),
            Color = Options.EntityEspColor.Value,
            IsEntity = entity.Name ~= "JeffTheKiller",
        })
    end
    
    function Script.Functions.SideEntityESP(entity)
        if not EntityESPFilter.Allows(entity) then return end
        if entity.Name == "Snare" and not entity:FindFirstChild("Hitbox") then return end
    
        Script.Functions.ESP({
            Type = "SideEntity",
            Object = entity,
            Text = Script.Functions.GetEntityName(entity.Name),
            TextParent = entity.PrimaryPart,
            Color = Options.EntityEspColor.Value,
        })
    end
    
    function Script.Functions.ItemESP(item, dropped)
        Script.Functions.ESP({
            Type = dropped and "DroppedItem" or "Item",
            Object = item,
            Text = Script.Functions.GetShortName(item.Name),
            Color = Options.ItemEspColor.Value
        })
    end
    
    function Script.Functions.ChestESP(chest)
        local text = chest.Name:gsub("Box", ""):gsub("_Vine", ""):gsub("_Small", ""):gsub("Locked", "")
        local locked = chest:GetAttribute("Locked")
        local state = if locked then "[Locked]" else ""
    
        Script.Functions.ESP({
            Type = "Chest",
            Object = chest,
            Text = string.format("%s %s", text, state),
            Color = Options.ChestEspColor.Value
        })
    end
    
    function Script.Functions.PlayerESP(player: Player)
        if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end
    
        local playerEsp = Script.Functions.ESP({
            Type = "Player",
            Object = player.Character,
            Text = string.format("%s [%.1f]", player.DisplayName, humanoid.Health),
            TextParent = player.Character.PrimaryPart,
            Color = Options.PlayerEspColor.Value
        })
    
        Script.FeatureConnections.Player[player.Name] = player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth > 0 then
                playerEsp.SetText(string.format("%s [%.1f]", player.DisplayName, newHealth))
            else
                if Script.FeatureConnections.Player[player.Name] then Script.FeatureConnections.Player[player.Name]:Disconnect() end
                playerEsp.Destroy()
            end
        end)
    end
    
    function Script.Functions.HidingSpotESP(spot)
        Script.Functions.ESP({
            Type = "HidingSpot",
            Object = spot,
            Text = if spot:GetAttribute("LoadModule") == "Bed" then "Bed" else HidingPlaceName[floor.Value],
            Color = Options.HidingSpotEspColor.Value
        })
    end
    
    function Script.Functions.GoldESP(gold)
        Script.Functions.ESP({
            Type = "Gold",
            Object = gold,
            Text = string.format("Gold [%s]", gold:GetAttribute("GoldValue")),
            Color = Options.GoldEspColor.Value
        })
    end
    
    function Script.Functions.GuidingLightEsp(guidance)
        local part = guidance:Clone()
        part.Anchored = true
        part.Size = Vector3.new(3, 3, 3)
        part.Transparency = 0.5
        part.Name = "_Guidance"
    
        part:ClearAllChildren()
        part.Parent = Workspace
    
        Script.Temp.Guidance[guidance] = part
    
        local guidanceEsp = Script.Functions.ESP({
            Type = "Guiding",
            Object = part,
            Text = "Guidance",
            Color = Options.GuidingLightEspColor.Value
        })
    
        guidance.AncestryChanged:Connect(function()
            if not guidance:IsDescendantOf(workspace) then
                if Script.Temp.Guidance[guidance] then Script.Temp.Guidance[guidance] = nil end
                if part then part:Destroy() end
                if guidanceEsp then guidanceEsp.Destroy() end
            end
        end)
    end
end

--// Assets Functions \\--
do
    -- Language-aware name for on-screen labels; falls back to the short name so the
    -- English build and every non-entity string behave exactly as before.
    function Script.Functions.GetEntityName(entityName: string)
        return EntityLanguage.Name(entityName) or Script.Functions.GetShortName(entityName)
    end

    function Script.Functions.GetShortName(entityName: string)
        if EntityTable.ShortNames[entityName] then
            return EntityTable.ShortNames[entityName]
        end
    
        for suffix, fix in pairs(SuffixPrefixes) do
            entityName = entityName:gsub(suffix, fix)
        end
    
        return entityName
    end

    function Script.Functions.PromptCondition(prompt)
        local modelAncestor = prompt:FindFirstAncestorOfClass("Model")
        return 
            prompt:IsA("ProximityPrompt") and (
                not table.find(PromptTable.Excluded.Prompt, prompt.Name) 
                and not table.find(PromptTable.Excluded.Parent, prompt.Parent and prompt.Parent.Name or "") 
                and not (table.find(PromptTable.Excluded.ModelAncestor, modelAncestor and modelAncestor.Name or ""))
            )
    end

    function Script.Functions.ItemCondition(item)
        return item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID")
    end

    function Script.Functions.ChildCheck(child)
        -- optimization (ty lsplash)
        if (child.Name == "AnimSaves" or child.Name == "Keyframe" or child:IsA("KeyframeSequence")) then
            child:Destroy()
            return
        end
        
        -- skip
        if not (child:IsA("ProximityPrompt") or child:IsA("Model") or child:IsA("BasePart") or child:IsA("Decal")) then
            return
        end
                
        if Script.Functions.PromptCondition(child) then
            task.defer(function()
                if not child:GetAttribute("Hold") then child:SetAttribute("Hold", child.HoldDuration) end
                if not child:GetAttribute("Distance") then child:SetAttribute("Distance", child.MaxActivationDistance) end
                if not child:GetAttribute("Enabled") then child:SetAttribute("Enabled", child.Enabled) end
                if not child:GetAttribute("Clip") then child:SetAttribute("Clip", child.RequiresLineOfSight) end
            end)
    
            task.defer(function()
                child.MaxActivationDistance = child:GetAttribute("Distance") * Options.PromptReachMultiplier.Value
        
                if Toggles.InstaInteract.Value then
                    child.HoldDuration = 0
                end
        
                if Toggles.PromptClip.Value and Script.Functions.PromptCondition(child) then
                    child.RequiresLineOfSight = false
                end
            end)
    
            table.insert(PromptTable.GamePrompts, child)
        end
    
        if child:IsA("Model") then
            if child.Name == "ElevatorBreaker" and Toggles.AutoBreakerSolver.Value then
                Script.Functions.SolveBreakerBox(child)
            end
    
            if isMines and Toggles.TheMinesAnticheatBypass.Value and child.Name == "Ladder" then
                Script.Functions.ESP({
                    Type = "None",
                    Object = child,
                    Text = "Ladder",
                    Color = Color3.new(0, 0, 1)
                })
            end
    
            if child.Name == "Snare" and Toggles.AntiSnare.Value then
                child:WaitForChild("Hitbox", 5).CanTouch = false
            elseif child.Name == "GiggleCeiling" and Toggles.AntiGiggle.Value then
                child:WaitForChild("Hitbox", 5).CanTouch = false
            elseif (child:GetAttribute("LoadModule") == "DupeRoom" or child:GetAttribute("LoadModule") == "SpaceSideroom") and Toggles.AntiDupe.Value then
                Script.Functions.DisableDupe(child, true, child:GetAttribute("LoadModule") == "SpaceSideroom")
            end
    
            if (isHotel or isFools) and (child.Name == "ChandelierObstruction" or child.Name == "Seek_Arm") and Toggles.AntiSeekObstructions.Value then
                for i,v in pairs(child:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanTouch = false end
                end
            end
    
            if isFools then
                if Toggles.FigureGodmodeFools.Value and child.Name == "FigureRagdoll" then
                    for i, v in pairs(child:GetDescendants()) do
                        if v:IsA("BasePart") then
                            if not v:GetAttribute("Clip") then v:SetAttribute("Clip", v.CanCollide) end
    
                            v.CanTouch = false
    
                            -- woudn't want figure to just dip into the ground
                            task.spawn(function()
                                repeat task.wait() until (latestRoom.Value == 50 or latestRoom.Value == 100)
                                task.wait(5)
                                v.CanCollide = false
                            end)
                        end
                    end
                end
            end
        elseif child:IsA("BasePart") then        
            if child.Name == "Egg" and Toggles.AntiGloomEgg.Value then
                child.CanTouch = false
            end
    
            if Toggles.AntiLag.Value then
                if not child:GetAttribute("Material") then child:SetAttribute("Material", child.Material) end
                if not child:GetAttribute("Reflectance") then child:SetAttribute("Reflectance", child.Reflectance) end
        
                child.Material = Enum.Material.Plastic
                child.Reflectance = 0
            end
    
            if isMines then
                if Toggles.AntiBridgeFall.Value and child.Name == "PlayerBarrier" and child.Size.Y == 2.75 and (child.Rotation.X == 0 or child.Rotation.X == 180) then
                    local clone = child:Clone()
                    clone.CFrame = clone.CFrame * CFrame.new(0, 0, -5)
                    clone.Color = Color3.new(1, 1, 1)
                    clone.Name = "AntiBridge"
                    clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, 11)
                    clone.Transparency = 0
                    clone.Parent = child.Parent
                    
                    table.insert(Script.Temp.Bridges, clone)
                elseif Toggles.AntiSeekFlood.Value and child.Name == "SeekFloodline" then
                    child.CanCollide = true
                end
            end
        elseif child:IsA("Decal") and Toggles.AntiLag.Value then
            if not child:GetAttribute("Transparency") then child:SetAttribute("Transparency", child.Transparency) end
    
            if not table.find(SlotsName, child.Name) then
                child.Transparency = 1
            end
        end
    end

    function Script.Functions.IsPromptInRange(prompt: ProximityPrompt)
        return Script.Functions.DistanceFromCharacter(prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model") or prompt.Parent) <= prompt.MaxActivationDistance
    end
    
    function Script.Functions.GetNearestAssetWithCondition(condition: () -> ())
        local nearestDistance = math.huge
        local nearest
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if not room:FindFirstChild("Assets") then continue end
    
            for i, v in pairs(room.Assets:GetChildren()) do
                if condition(v) and Script.Functions.DistanceFromCharacter(v) < nearestDistance then
                    nearestDistance = Script.Functions.DistanceFromCharacter(v)
                    nearest = v
                end
            end
        end
    
        return nearest
    end

    function Script.Functions.GetAllPromptsWithCondition(condition)
        assert(typeof(condition) == "function", "Expected a function as condition argument but got " .. typeof(condition))
        
        local validPrompts = {}
        for _, prompt in pairs(PromptTable.GamePrompts) do
            if not prompt or not prompt:IsDescendantOf(workspace) then continue end
    
            local success, returnData = pcall(function()
                return condition(prompt)
            end)
    
            assert(success, "An error has occured while running condition function.\n" .. tostring(returnData))
            assert(typeof(returnData) == "boolean", "Expected condition function to return a boolean")
            
            if returnData then
                table.insert(validPrompts, prompt)
            end
        end
    
        return validPrompts
    end
    
    function Script.Functions.GetNearestPromptWithCondition(condition)
        local prompts = Script.Functions.GetAllPromptsWithCondition(condition)
    
        local nearestPrompt = nil
        local oldHighestDistance = math.huge
        for _, prompt in pairs(prompts) do
            local promptParent = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt:FindFirstAncestorWhichIsA("Model")
    
            if promptParent and Script.Functions.DistanceFromCharacter(promptParent) < oldHighestDistance then
                nearestPrompt = prompt
                oldHighestDistance = Script.Functions.DistanceFromCharacter(promptParent)
            end
        end
    
        return nearestPrompt
    end
end

--// Entities Functions \\--
do
    function Script.Functions.DisableDupe(dupeRoom, value, isSpaceRoom)
        if isSpaceRoom then
            local collision = dupeRoom:WaitForChild("Collision", 5)
            
            if collision then
                collision.CanCollide = value
                collision.CanTouch = not value
            end
        else
            local doorFake = dupeRoom:WaitForChild("DoorFake", 5)
            
            if doorFake then
                doorFake:WaitForChild("Hidden", 5).CanTouch = not value
        
                local lock = doorFake:WaitForChild("Lock", 5)
                if lock and lock:FindFirstChild("UnlockPrompt") then
                    lock.UnlockPrompt.Enabled = not value
                end
            end
        end
    end

    function Script.Functions.DeleteSeek(collision: BasePart)
        if not rootPart then return end
    
        task.spawn(function()
            local attemps = 0
            repeat task.wait() attemps += 1 until collision.Parent or attemps > 200
            
            if collision:IsDescendantOf(workspace) and (collision.Parent and collision.Parent.Name == "TriggerEventCollision") then
                Script.Functions.Alert({
                    Title = "Delete Seek FE",
                    Description = "Deleting Seek trigger...",
                    Reason = "",
                })
    
                task.delay(4, function()
                    if collision:IsDescendantOf(workspace) then
                        Script.Functions.Alert({
                            Title = "Delete Seek FE",
                            Description = "Failed to delete Seek trigger!",
                            Reason = "",
                        })
                    end
                end)
                
                if fireTouch then
                    rootPart.Anchored = true
                    task.delay(0.25, function() rootPart.Anchored = false end)
    
                    repeat
                        if collision:IsDescendantOf(workspace) then fireTouch(collision, rootPart, 1) end
                        task.wait()
                        if collision:IsDescendantOf(workspace) then fireTouch(collision, rootPart, 0) end
                        task.wait()
                    until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                else
                    collision:PivotTo(CFrame.new(rootPart.Position))
                    rootPart.Anchored = true
                    repeat task.wait() until not collision:IsDescendantOf(workspace) or not Toggles.DeleteSeek.Value
                    rootPart.Anchored = false
                end
                
                if not collision:IsDescendantOf(workspace) then
                    Script.Functions.Log({
                        Title = "Delete Seek FE",
                        Description = "Deleted Seek trigger successfully!",
                    })
                end
            end
        end)
    end

    function Script.Functions.AvoidEntity(value: boolean, oldNoclip: boolean)
        if not rootPart or not collision then return end
    
        local lastCFrame = rootPart.CFrame
        task.wait()
        if value then
            Toggles.Noclip:SetValue(true)
            collision.Position += Vector3.new(0, 24, 0)
            task.wait()
            character:PivotTo(lastCFrame)
        else
            collision.Position -= Vector3.new(0, 24, 0)
            task.wait()
            character:PivotTo(lastCFrame)
            Toggles.Noclip:SetValue(oldNoclip or false)
        end
    end
end

--// Automatization Functions \\--
do
    function Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt: ProximityPrompt)
        if not workspace.CurrentRooms:FindFirstChild(currentRoom) then return {targetWardrobePrompt.Parent} end
    
        local ignore = { targetWardrobePrompt.Parent }
    
        if workspace.CurrentRooms[currentRoom]:FindFirstChild("Assets") then
            for _, asset in pairs(workspace.CurrentRooms[currentRoom].Assets:GetChildren()) do
                if asset.Name == "Pillar" then table.insert(ignore, asset) end
            end
        end
    
        return ignore
    end
    
    function Script.Functions.AutoWardrobe(child, index: number | nil) -- child = entity, ty upio
        if not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace) then
            index = index or table.find(Script.Temp.AutoWardrobeEntities, child)
            if index then
                table.remove(Script.Temp.AutoWardrobeEntities, index)
            end
    
            return
        end
    
        local NotifPrefix = "Auto " .. HidingPlaceName[floor.Value];
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Looking for a hiding place",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Looking for a hiding spot..."
            }, Toggles.AutoWardrobeNotif.Value)
        end)
    
        local entityIndex = #Script.Temp.AutoWardrobeEntities + 1
        Script.Temp.AutoWardrobeEntities[entityIndex] = child
    
        -- Get wardrobe
        local distance = EntityTable.AutoWardrobe.Distance[child.Name].Distance;
        local targetWardrobeChecker = function(prompt)
            if not prompt.Parent then return false end
            if not prompt.Parent:FindFirstChild("HiddenPlayer") then return false end
            if prompt.Parent:FindFirstChild("Main") and prompt.Parent.Main:FindFirstChild("HideEntityOnSpot") then
                if prompt.Parent.Main.HideEntityOnSpot.Whispers.Playing == true then return false end -- Hide
            end
    
            return prompt.Name == "HidePrompt" and (prompt.Parent:GetAttribute("LoadModule") == "Wardrobe" or prompt.Parent:GetAttribute("LoadModule") == "Bed" or prompt.Parent.Name == "Rooms_Locker") and not prompt.Parent.HiddenPlayer.Value and (Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance * Options.PromptReachMultiplier.Value)
        end
        local targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
        local getPrompt = function()
            if not targetWardrobePrompt or Script.Functions.DistanceFromCharacter(targetWardrobePrompt:FindFirstAncestorWhichIsA("Model"):GetPivot().Position) > 15 then
                repeat task.wait()
                    targetWardrobePrompt = Script.Functions.GetNearestPromptWithCondition(targetWardrobeChecker)
                until targetWardrobePrompt ~= nil or character:GetAttribute("Hiding") or (not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace)) or Library.Unloaded
    
                if (not Toggles.AutoWardrobe.Value or not alive or not child or not child:IsDescendantOf(workspace)) or Library.Unloaded then
                    return
                end
            end
        end
        getPrompt()
    
        -- Hide Checks
        if character:GetAttribute("Hiding") then return end
        if not Toggles.AutoWardrobe.Value or not alive or Library.Unloaded then return end  
    
        -- Hide
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Starting...",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Starting..."
            }, Toggles.AutoWardrobeNotif.Value)
        end)
        
        local exclusion = Script.Functions.GenerateAutoWardrobeExclusions(targetWardrobePrompt)
        local atempts, maxAtempts = 0, 60
        local isSafeCheck = function(addMoreDist)
            local isSafe = true
            for _, entity in pairs(Script.Temp.AutoWardrobeEntities) do
                if isSafe == false then break end
    
                local distanceEntity = EntityTable.AutoWardrobe.Distance[child.Name].Distance;

                local entityDeleted = (entity == nil or entity.Parent == nil)
                local inView = Script.Functions.IsInViewOfPlayer(entity.PrimaryPart, distanceEntity + (addMoreDist == true and 15 or 0), exclusion)
                local isClose = Script.Functions.DistanceFromCharacter(entity:GetPivot().Position) < distanceEntity + (addMoreDist == true and 15 or 0);
    
                isSafe = entityDeleted == true and true or (inView == false and isClose == false);
                if isSafe == false then break end
            end
    
            return isSafe
        end
        local waitForSafeExit; waitForSafeExit = function()
            if child.Name == "A120" then
                repeat task.wait() until not child:IsDescendantOf(workspace) or (child.PrimaryPart and child.PrimaryPart.Position.Y < -10) or (not alive or not character:GetAttribute("Hiding"))
            else   
                local didPlayerSeeEntity = false
                task.spawn(function()
                    repeat task.wait()
                        if not alive or not child or not child:IsDescendantOf(workspace) then break end
    
                        if character:GetAttribute("Hiding") and Script.Functions.IsInViewOfPlayer(child.PrimaryPart, distance, exclusion) then
                            didPlayerSeeEntity = true
                            break
                        end
                    until false == true
                end)
    
                repeat task.wait(.15)
                    local isSafe = isSafeCheck()
                    if didPlayerSeeEntity == true and isSafe == true then
                        task.spawn(function() 
                            Script.Functions.Log({
                                Title = NotifPrefix,
                                Description = "Exiting the locker, entity is far away.",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is far away."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)
    
                        break
                    else
                        if isSafe == true and not child:IsDescendantOf(workspace) then 
                            task.spawn(function() 
                                Script.Functions.Log({
                                    Title = NotifPrefix,
                                    Description = "Exiting the locker, entity is deleted.",
                                    
                                    LinoriaMessage = "[" .. NotifPrefix .. "] Exiting the locker, entity is deleted."
                                }, Toggles.AutoWardrobeNotif.Value)
                            end)
    
                            break 
                        end          
                    end
    
                    if not alive then  
                        if Toggles.AutoWardrobeNotif.Value then Script.Functions.Log("[" .. NotifPrefix .. "] Stopping (you died).") end             
                        task.spawn(function() 
                            Script.Functions.Log({
                                Title = NotifPrefix,
                                Description = "Stopping (you died)",
                                
                                LinoriaMessage = "[" .. NotifPrefix .. "] Stopping (you died)."
                            }, Toggles.AutoWardrobeNotif.Value)
                        end)

                        break 
                    end                             
                until false == true          
            end
    
            return true
        end
        local hide = function()
            if (character:GetAttribute("Hiding") and rootPart.Anchored) then return false end
    
            getPrompt()
            repeat task.wait()
                atempts += 1
    
                forceFirePrompt(targetWardrobePrompt)
            until atempts > maxAtempts or not alive or (character:GetAttribute("Hiding") and rootPart.Anchored)
    
            if atempts > maxAtempts or not alive then return false end
            return true
        end
    
        if child.Name == "AmbushMoving" then
            local LastPos = child:GetPivot().Position
            local IsMoving = false
            task.spawn(function()
                repeat task.wait(0.01)
                    local diff = (LastPos - child:GetPivot().Position) / 0.01
                    LastPos = child:GetPivot().Position
                    IsMoving = diff.Magnitude > 0
                until not child or not child:IsDescendantOf(workspace)
            end)
    
            repeat task.wait()
                task.spawn(function() 
                    Script.Functions.Log({
                        Title = NotifPrefix,
                        Description = "Waiting for Ambush to be close enough...",
        
                        LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for Ambush to be close enough...",
                    }, Toggles.AutoWardrobeNotif.Value)
                end)
    
                repeat task.wait() until (IsMoving == true and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) <= distance) or (not child or not child:IsDescendantOf(workspace))
                if not child or not child:IsDescendantOf(workspace) then break end
                
                local success = hide()
                if success then
                    task.spawn(function() 
                        Script.Functions.Log({
                            Title = NotifPrefix,
                            Description = "Waiting for it to be safe to exit...",
        
                            LinoriaMessage = "[" .. NotifPrefix .. "] Waiting for it to be safe to exit...",
                        }, Toggles.AutoWardrobeNotif.Value)
                    end)
    
                    repeat task.wait() until (IsMoving == false and Script.Functions.DistanceFromCharacter(child:GetPivot().Position) >= distance) or (not child or not child:IsDescendantOf(workspace));
                    if not child or not child:IsDescendantOf(workspace) then break end
    
                    remotesFolder.CamLock:FireServer()
                end
            until (not child or not child:IsDescendantOf(workspace)) or not alive
        else
            repeat task.wait() until isSafeCheck(true, true) == false
    
            repeat
                local success = hide()
                if success then
                    local finished = waitForSafeExit()
                    repeat task.wait() until finished == true        
                    remotesFolder.CamLock:FireServer()
                end
                
                task.wait()
            until isSafeCheck()
        end
    
        table.remove(Script.Temp.AutoWardrobeEntities, entityIndex)
        task.spawn(function() 
            Script.Functions.Log({
                Title = NotifPrefix,
                Description = "Finished.",
        
                LinoriaMessage = "[" .. NotifPrefix .. "] Finished.",
            }, Toggles.AutoWardrobeNotif.Value)
        end)
    end

    --// Breakers \\--
    function Script.Functions.EnableBreaker(breaker, value)
        breaker:SetAttribute("Enabled", value)
    
        if value then
            breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = -0.2
            breaker.Light.Material = Enum.Material.Neon
            breaker.Light.Attachment.Spark:Emit(1)
            breaker.Sound.Pitch = 1.3
        else
            breaker:FindFirstChild("PrismaticConstraint", true).TargetPosition = 0.2
            breaker.Light.Material = Enum.Material.Glass
            breaker.Sound.Pitch = 1.2
        end
    
        breaker.Sound:Play()
    end

    function Script.Functions.SolveBreakerBox(breakerBox)
        if not breakerBox then return end
    
        local code = breakerBox:FindFirstChild("Code", true)
        local correct = breakerBox:FindFirstChild("Correct", true)
    
        repeat task.wait() until code.Text ~= "..." or not breakerBox:IsDescendantOf(workspace)
        if not breakerBox:IsDescendantOf(workspace) then return end
    
        Script.Functions.Alert({
            Title = "Auto Breaker Solver",
            Description = "Solving the breaker box...",
            Reason = ""
        })
    
        if Options.AutoBreakerSolverMethod.Value == "Legit" then
            Script.Temp.UsedBreakers = {}
            if Script.Connections["Reset"] then Script.Connections["Reset"]:Disconnect() end
            if Script.Connections["Code"] then Script.Connections["Code"]:Disconnect() end
    
            local breakers = {}
            for _, breaker in pairs(breakerBox:GetChildren()) do
                if breaker.Name == "BreakerSwitch" then
                    local id = string.format("%02d", breaker:GetAttribute("ID"))
                    breakers[id] = breaker
                end
            end
    
            if code:FindFirstChild("Frame") then
                Script.Functions.AutoBreaker(code, breakers)
    
                Script.Connections["Reset"] = correct:GetPropertyChangedSignal("Playing"):Connect(function()
                    if correct.Playing then table.clear(Script.Temp.UsedBreakers) end
                end)
    
                Script.Connections["Code"] = code:GetPropertyChangedSignal("Text"):Connect(function()
                    task.delay(0.1, Script.Functions.AutoBreaker, code, breakers)
                end)
            end
        else
            repeat task.wait(0.1)
                remotesFolder.EBF:FireServer()
            until not workspace.CurrentRooms["100"]:FindFirstChild("DoorToBreakDown")
    
            Script.Functions.Alert({
                Title = "Auto Breaker Solver",
                Description = "The breaker box has been successfully solved.",
            })
        end
    end
    
    function Script.Functions.AutoBreaker(code, breakers)
        local newCode = code.Text
        if not tonumber(newCode) and newCode ~= "??" then return end
    
        local isEnabled = code.Frame.BackgroundTransparency == 0
    
        local breaker = breakers[newCode]
    
        if newCode == "??" and #Script.Temp.UsedBreakers == 9 then
            for i = 1, 10 do
                local id = string.format("%02d", i)
    
                if not table.find(Script.Temp.UsedBreakers, id) then
                    breaker = breakers[id]
                end
            end
        end
    
        if breaker then
            table.insert(Script.Temp.UsedBreakers, newCode)
            if breaker:GetAttribute("Enabled") ~= isEnabled then
                Script.Functions.EnableBreaker(breaker, isEnabled)
            end
        end
    end

    --// Padlocks \\--
    function Script.Functions.GetPadlockCode(paper: Tool)
        if paper:FindFirstChild("UI") then
            local code = {}
    
            for _, image: ImageLabel in pairs(paper.UI:GetChildren()) do
                if image:IsA("ImageLabel") and tonumber(image.Name) then
                    code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] = {tonumber(image.Name), "_"}
                end
            end
    
            for _, image: ImageLabel in pairs(playerGui.PermUI.Hints:GetChildren()) do
                if image.Name == "Icon" then
                    if code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] then
                        code[image.ImageRectOffset.X .. image.ImageRectOffset.Y][2] = image.TextLabel.Text
                    end
                end
            end
    
            local normalizedCode = {}
            for _, num in pairs(code) do
                normalizedCode[num[1]] = num[2]
            end
    
            return table.concat(normalizedCode)
        end
    
        return "_____"
    end
end

--// Minecarts \\--
do
    local function changeNodeColor(node: Model, color: Color3): Model
        if color == nil then
            node.Color = MinecartPathNodeColor.Yellow
            node.Transparency = 1
            node.Size = Vector3.new(1.0, 1.0, 1.0)
            return
        end
        node.Color = color
        node.Material = Enum.Material.Neon
        node.Transparency = 0
        node.Shape = Enum.PartType.Ball
        node.Size = Vector3.new(0.7, 0.7, 0.7)
        return node
    end
    
    local function tPathfindNew(n: number)
        local create: tPathfind = {
            esp = false,
            room_number = n,
            real = {},
            fake = {},
            destroyed = false
        }
        return create
    end
    
    local function tGroupTrackNew(startNode: Part | nil): tGroupTrack
        local create: tGroupTrack = {
            nodes = startNode and {startNode} or {},
            hasStart = false,
            hasEnd   = false,
        }
        return create
    end
    
    function Script.Functions.Minecart.Pathfind(room: Model, lastRoom: number)
        if not (lastRoom >= 40 and lastRoom <= 49) and not (lastRoom >= 95 and lastRoom <= 100) then return end
        
        local nodes = room:WaitForChild("RunnerNodes", 5.0) --well, skill issue ig
        if (nodes == nil) then return end
    
        nodes = nodes:GetChildren()
    
        local numOfNodes = #nodes
        if numOfNodes <= 1 then return end --This is literally impossible but... umm. acutally, yea why not.
    
        --[[
            Pathfind is a computational expensive process to make, 
            however we don't have node loops, 
            so we can ignore a few verifications.
            If you want to understand how this is working, search for "Pathfiding Algorithms"
    
            The shortest explanation i can give is that, this is a custom pathfinding to find "gaps" between
            nodes and creating "path" groups. With the groups estabilished we can make the correct validations.
        ]]
        --Distance weights [DO NOT EDIT, unless something breaks...]
        local _shortW = 4
        local _longW = 24
    
        local doorModel = room:WaitForChild("Door", 5) -- Will be used to find the correct last node.
    
        local _startNode = nodes[1]
        local _lastNode = nil --we need to find this node.
    
        local _gpID = 1
        local stackNode = {} --Group all track groups here.
        stackNode[_gpID] = tGroupTrackNew()
        
        --Ensure sort all nodes properly (reversed)
        table.sort(nodes, function(a, b)
            local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
            local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
            return tonumber(_Asub) > tonumber(_Bsub)
        end)
    
        local _last = 1
        for i= _last + 1, numOfNodes, 1 do
            local nodeA: Part = nodes[_last]
            local nodeB: Part = _lastNode and nodes[i] or doorModel
    
            local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude
    
            local isEndNode = distance <= _shortW
            local isNodeNear = (distance > _shortW and distance <= _longW)
    
            local _currNodeTask = "Track"
            if isNodeNear or isEndNode then
                if not _lastNode then -- this will only be true, once.
                    _currNodeTask = "End"
                    _lastNode = nodeA
                end
            else
                _currNodeTask = "Fake"
            end
    
            --check if group is diff, ignore "End" or "Start" tasks
            if (_currNodeTask == "Fake" or _currNodeTask == "End") and _lastNode then
                _gpID += 1
                stackNode[_gpID] = tGroupTrackNew()
                if _currNodeTask == "End" then
                    stackNode[_gpID].hasEnd = true
                end
            end
            table.insert(stackNode[_gpID].nodes, nodeA)
    
            _last = i
        end
        stackNode[_gpID].hasStart = true --after the reversed path finding, the last group has the start node.
        table.insert(stackNode[_gpID].nodes, _startNode)
        local hasMoreThanOneGroup = _gpID > 1
    
        local _closestNodes = {} --unwanted nodes if any
        local hasIncorrectPath = false -- if this is true, we're cooked. No path for you ):
        if hasMoreThanOneGroup then
            for _gpI, v: tGroupTrack in ipairs(stackNode) do
                _closestNodes[_gpI] = {}
                if _gpI <= 1 then continue end
    
                table.sort(v.nodes, function(a,b)
                    local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
                    local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
                    return tonumber(_Asub) < tonumber(_Bsub)
                end)
    
                local _gplast = 1
                local hasNodeJump = false
                for _gpS=_gplast+1, #v.nodes, 1 do
                    local nodeA: Part = v.nodes[_gplast]
                    local nodeB: Part = v.nodes[_gpS]
    
                    local distance = (nodeA:GetPivot().Position - nodeB:GetPivot().Position).Magnitude
    
                    hasNodeJump = (distance >= _longW)
                    if not hasNodeJump then _gplast = _gpS continue end

                    local nodeSearchPath = nodeB
    
                    --Search again with the nodeSearchPath
                    local closestDistance = math.huge
    
                    local _gpFlast = #v.nodes
                    for i = _gpFlast - 1, 1, -1 do
                        local fnode = v.nodes[_gpFlast]
                        local Sdistance = (nodeSearchPath:GetPivot().Position - fnode:GetPivot().Position).Magnitude
                        _gpFlast = i
    
                        if Sdistance == 0.00 then continue end --node is self
    
                        if Sdistance <= closestDistance then
                            closestDistance = Sdistance
                            table.insert(_closestNodes[_gpI], fnode)
                            table.remove(v.nodes, _gpFlast + 1)
                            continue
                        end
                        break
                    end
    
                    local _FoundAmount = #_closestNodes[_gpI]
                    if _FoundAmount < 1 then 
                        hasIncorrectPath = true
                    end
                    break
                end
            end
        end
    
        if hasIncorrectPath then return end
    
        --finally, draw the correct path. gg
        local realNodes = {} --our precious nodes finally here :pray:
        local fakeNodes = {} --we hate you but ok
        for _gpFI, v: tGroupTrack in ipairs(stackNode) do
            local finalWrongNode = false
            if _gpFI == 1 and hasMoreThanOneGroup then
                finalWrongNode = true 
            end
    
            for _, vfinal in ipairs(v.nodes) do
                if finalWrongNode then
                    table.insert(fakeNodes, vfinal)
                    continue
                end
                table.insert(realNodes, vfinal)
            end
    
            --Draw wrong path calculated on DeepPath.
            for _, nfinal in ipairs(_closestNodes[_gpFI]) do
                table.insert(fakeNodes, nfinal)
            end
        end
    
        table.sort(realNodes, function(a, b)
            local _Asub, _ = string.gsub(a.Name, "MinecartNode", "")
            local _Bsub, _ = string.gsub(b.Name, "MinecartNode", "")
            return tonumber(_Asub) < tonumber(_Bsub)
        end)
    
        --build pathfind
        local buildPathfind = tPathfindNew(lastRoom)
        buildPathfind.real = realNodes
        buildPathfind.fake = fakeNodes
        table.insert(MinecartPathfind, buildPathfind) --add to table
    
        Script.Functions.Minecart.DrawNodes()
    
        if Toggles.MinecartTeleport.Value and (lastRoom >= 45 and lastRoom <= 49) then
            Script.Functions.Minecart.NodeDestroy(tonumber(room.Name))
            Script.Functions.Minecart.Teleport(tonumber(room.Name))
        end
    end
    
    function Script.Functions.Minecart.NodeDestroy(roomNum: number)
        local roomConfig = WhitelistConfig[roomNum]
        if not roomConfig then return end
    
        local _firstKeep = roomConfig.firstKeep
        local _lastKeep  = roomConfig.lastKeep
    
        local realNodes = nil
        local fakeNodes = nil
        for _, path: tPathfind in ipairs(MinecartPathfind) do
            if path.room_number ~= roomNum then continue end
            if path.destroyed then continue end
    
            realNodes = path.real
            fakeNodes = path.fake
        end
    
        if realNodes then
            local _removeTotal = #realNodes - (_firstKeep + _lastKeep) --remove nodes that arent in the first or last
            for _ = 1, _removeTotal do
                local node = realNodes[_firstKeep + 1]
                node:Destroy()
                
                table.remove(realNodes, _firstKeep + 1)
            end
        else
            print("[NodeDestroy] Unable to destroy REAL nodes.")
        end
    
        if fakeNodes then
            --Destroy all the fake nodes
            for _, node in ipairs(fakeNodes) do
                node:Destroy()
            end
            fakeNodes = {} --if we now all the nodes will be destroyed then just make that.
        else
            print("[NodeDestroy] Unable to destroy FAKE nodes.")
        end
    
        print(string.format("[NodeDestroy] Task completed, remaining: Real nodes: %d | Fake nodes %s", #realNodes, #fakeNodes))
    end
    
    local isMinecartTeleporting = false --for debug purpouses.
    function Script.Functions.Minecart.Teleport(roomNum: number)
        if roomNum == 45 and not isMinecartTeleporting then
            isMinecartTeleporting = true
            task.spawn(function()
                local progressPart = Instance.new("Part", workspace) do
                    progressPart.Anchored = true
                    progressPart.CanCollide = false
                    progressPart.Name = "_internal_lonelyhub_minecart_teleport"
                    progressPart.Transparency = 1
                end
                Script.Functions.Alert({
                    Title = "Minecart Teleport",
                    Description = "Minecart teleport is ready! Waiting for the minecart...",
    
                    Time = progressPart
                })

                local minecartRig
                local minecartRoot
                repeat task.wait(0.1) 
                    minecartRig = camera:FindFirstChild("MinecartRig")
                    if not minecartRig then continue end
                    minecartRoot = minecartRig:FindFirstChild("Root")
                until minecartRig and minecartRoot

                if workspace:FindFirstChild("_internal_lonelyhub_minecart_teleport") then workspace:FindFirstChild("_internal_lonelyhub_minecart_teleport"):Destroy() end
                task.wait(3)

                for _, path: tPathfind in ipairs(MinecartPathfind) do
                    local roomOfThePath = path.room_number
    
                    if roomOfThePath >= 45 then -- ignore ground chase
                        local getLastNode = path.real[#path.real]
    
                        repeat 
                            task.wait()
                            minecartRoot.CFrame = getLastNode.CFrame
                        until workspace.CurrentRooms[tostring(currentRoom)]:WaitForChild("Door"):GetAttribute("Opened")
                        task.wait(2)
                        if currentRoom == 49 then break end
                    end
                end
            end)
        end
    end
    
    
    --If ESP Toggle is changed, you can call this function directly.
    function Script.Functions.Minecart.DrawNodes()
        local pathESP_enabled = Toggles.MinecartPathVisualiser.Value
        local espRealColor = pathESP_enabled and MinecartPathNodeColor.Green or MinecartPathNodeColor.Disabled
        
        for idx, path: tPathfind in ipairs(MinecartPathfind) do
            if path.esp and pathESP_enabled then continue end -- if status is unchanged.
    
            --[ESP] Draw the real path
            local realPath = path.real
            for _, _real in pairs(realPath) do
                changeNodeColor(_real, espRealColor)
            end
    
            path.esp = pathESP_enabled --update if path esp status was changed.
        end
    end
end

--// Connections Functions \\--
do
    function Script.Functions.CameraCheck(child)
        if child:IsA("BasePart") and child.Name == "Guidance" and Toggles.GuidingLightESP.Value then
            Script.Functions.GuidingLightEsp(child)
        end
    end

    function Script.Functions.SetupCameraConnection(camera)
        for _, child in pairs(camera:GetChildren()) do
            task.spawn(Script.Functions.CameraCheck, child)
        end
    
        Script.Connections["CameraChildAdded"] = camera.ChildAdded:Connect(function(child)
            task.spawn(Script.Functions.CameraCheck, child)
        end)
    end
    
    function Script.Functions.SetupCurrentRoomConnection(room)
        if Script.Connections["CurrentRoom"] then
            Script.Connections["CurrentRoom"]:Disconnect()
        end
    
        Script.Connections["CurrentRoom"] = room.DescendantAdded:Connect(function(child)
            if Toggles.ItemESP.Value and Script.Functions.ItemCondition(child) then
                Script.Functions.ItemESP(child)
            elseif Toggles.GoldESP.Value and child.Name == "GoldPile" then
                Script.Functions.GoldESP(child)
            end
        end)
    end
    
    function Script.Functions.SetupRoomConnection(room)
        if Options.NotifyEntity.Value["Halt Room"] and room:GetAttribute("RawName") == "HaltHallway" then
            Script.Functions.Alert({
                Title = "ENTITIES",
                Description = "Halt will spawn in next room!",
                Image = EntityTable.NotifyReason["HaltRoom"].Image,

                Warning = true
            })
        end

        for _, child in pairs(room:GetDescendants()) do
            task.spawn(function()
                if Toggles.DeleteSeek.Value and rootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
    
            task.spawn(Script.Functions.ChildCheck, child)
        end
    
        Script.Connections[room.Name .. "DescendantAdded"] = room.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if Toggles.DeleteSeek.Value and rootPart and child.Name == "Collision" then
                    Script.Functions.DeleteSeek(child)
                end
            end)
    
            task.delay(0.1, Script.Functions.ChildCheck, child)
        end)
    end
    
    function Script.Functions.SetupDropConnection(drop)
        if Toggles.ItemESP.Value then
            Script.Functions.ItemESP(drop, true)
        end
    
        task.spawn(function()
            local prompt = drop:WaitForChild("ModulePrompt", 3)
    
            if prompt then
                table.insert(PromptTable.GamePrompts, prompt)
            end
        end)
    end
    
    function Script.Functions.SetupCharacterConnection(newCharacter)
        character = newCharacter
        if character then
            if Toggles.EnableJump.Value then
                character:SetAttribute("CanJump", true)
            end
    
            for _, oldConnection in pairs(Script.FeatureConnections.Character) do
                oldConnection:Disconnect()
            end
    
            Script.FeatureConnections.Character["ChildAdded"] = character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                    task.wait(0.1)
                    local code = Script.Functions.GetPadlockCode(child)
                    local output, count = string.gsub(code, "_", "x")
                    local padlock = workspace:FindFirstChild("Padlock", true)
    
                    if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                        remotesFolder.PL:FireServer(code)
                    end
    
                    if Toggles.NotifyPadlock.Value and count < 5 then
                        Script.Functions.Alert({
                            Title = "Library Code",
                            Description = string.format("Library Code: %s", output),
                        })
    
                        if Toggles.NotifyChat.Value and count == 0 then
                            RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                        end
                    end
                end
            end)
    
            Script.FeatureConnections.Character["CanJump"] = character:GetAttributeChangedSignal("CanJump"):Connect(function()
                if not character:GetAttribute("CanJump") and Toggles.EnableJump.Value then
                    character:SetAttribute("CanJump", true)
                end
            end)
    
            Script.FeatureConnections.Character["Crouching"] = character:GetAttributeChangedSignal("Crouching"):Connect(function()
                if not character:GetAttribute("Crouching") and Toggles.AntiHearing.Value then
                    remotesFolder.Crouch:FireServer(true)
                end
            end)
    
            Script.FeatureConnections.Character["Hiding"] = character:GetAttributeChangedSignal("Hiding"):Connect(function()
                if not character:GetAttribute("Hiding") then return end
        
                if Toggles.TranslucentHidingSpot.Value then
                    for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                        if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end
        
                        if obj.Value == character then
                            task.spawn(function()
                                local affectedParts = {}
                                for _, part in pairs(obj.Parent:GetChildren()) do
                                    if not part:IsA("BasePart") or part.Name:match("Collision") then continue end
        
                                    part.Transparency = Options.HidingTransparency.Value
                                    table.insert(affectedParts, part)
                                end
        
                                repeat task.wait()
                                    for _, part in pairs(affectedParts) do
                                        task.wait()
                                        part.Transparency = Options.HidingTransparency.Value
                                    end
                                until not character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                                
                                for _, part in pairs(affectedParts) do
                                    part.Transparency = 0
                                end
                            end)
        
                            break
                        end
                    end
                end
            end)
    
            Script.FeatureConnections.Character["Oxygen"] = character:GetAttributeChangedSignal("Oxygen"):Connect(function()
                if character:GetAttribute("Oxygen") < 100 and Toggles.NotifyOxygen.Value then
                    if ExecutorSupport["firesignal"] then
                        firesignal(remotesFolder.Caption.OnClientEvent, string.format("Oxygen: %.1f", character:GetAttribute("Oxygen")))
                    else
                        Script.Functions.Captions(string.format("Oxygen: %.1f", character:GetAttribute("Oxygen")))
                    end
                end
            end)
        end
    
        humanoid = character:WaitForChild("Humanoid")
        if humanoid then
            for _, oldConnection in pairs(Script.FeatureConnections.Humanoid) do
                oldConnection:Disconnect()
            end
    
            Script.FeatureConnections.Humanoid["Move"] = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                if Toggles.FastClosetExit.Value and humanoid.MoveDirection.Magnitude > 0 and character:GetAttribute("Hiding") then
                    remotesFolder.CamLock:FireServer()
                end
            end)
    
            Script.FeatureConnections.Humanoid["Jump"] = humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                if not Toggles.SpeedBypass.Value and latestRoom.Value < 100 and not Script.FakeRevive.Enabled then
                    if humanoid.JumpHeight > 0 then
                        lastSpeed = Options.SpeedSlider.Value
                        Options.SpeedSlider:SetMax(3)
                    elseif lastSpeed > 0 then
                        Options.SpeedSlider:SetMax(7)
                        Options.SpeedSlider:SetValue(lastSpeed)
                        lastSpeed = 0
                    end
                end
            end)
    
            Script.FeatureConnections.Humanoid["Died"] = humanoid.Died:Connect(function()
                if collisionClone then
                    collisionClone:Destroy()
                end
    
                if velocityLimiter then
                    velocityLimiter:Destroy()
                end
            end)
    
            if isFools then
                local HoldingAnimation = Instance.new("Animation") do
                    HoldingAnimation.AnimationId = "rbxassetid://10479585177"
                    Script.Temp.ItemHoldTrack = humanoid:LoadAnimation(HoldingAnimation)
                end
    
                local ThrowAnimation = Instance.new("Animation") do
                    ThrowAnimation.AnimationId = "rbxassetid://10482563149"
                    Script.Temp.ItemThrowTrack = humanoid:LoadAnimation(ThrowAnimation)
                end
            end
        end
    
        rootPart = character:WaitForChild("HumanoidRootPart")
        if rootPart then
            local flyBody = Instance.new("BodyVelocity")
            flyBody.Velocity = Vector3.zero
            flyBody.MaxForce = Vector3.one * 9e9
    
            Script.Temp.FlyBody = flyBody
    
            if Toggles.NoAccel.Value then
                Script.Temp.NoAccelValue = rootPart.CustomPhysicalProperties.Density
                
                local existingProperties = rootPart.CustomPhysicalProperties
                rootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
            end
    
            velocityLimiter = Instance.new("LinearVelocity", character)
            velocityLimiter.Enabled = false
            velocityLimiter.MaxForce = math.huge
            velocityLimiter.VectorVelocity = Vector3.new(0, 0, 0)
            velocityLimiter.RelativeTo = Enum.ActuatorRelativeTo.World
            velocityLimiter.Attachment0 = rootPart:WaitForChild("RootAttachment")
    
            Script.FeatureConnections.RootPart["Anchored"] = rootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
                local lastAnchoredDelta = os.time() - Script.Lagback.LastAnchored
    
                if rootPart.Anchored and Toggles.LagbackDetection.Value and Toggles.SpeedBypass.Value and not Script.Lagback.Detected then
                    Script.Lagback.Anchors += 1
                    Script.Lagback.LastAnchored = os.time()
    
                    if Script.Lagback.Anchors >= 2 and lastAnchoredDelta <= Script.Lagback.Threshold then
                        Script.Lagback.Detected = true
                        Script.Lagback.Anchors = 0
                        Script.Lagback.LastSpeed = Options.SpeedSlider.Value
                        Script.Lagback.LastFlySpeed = Options.FlySpeed.Value
    
                        Script.Functions.Alert({
                            Title = "Lagback Detection",
                            Description = "Fixing Lagback...",
                        })
                        Toggles.SpeedBypass:SetValue(false)
                        local cframeChanged = false
    
                        if rootPart.Anchored == true then lastCheck = os.time(); repeat task.wait() until rootPart.Anchored == false or (os.time() - lastCheck) > 5 end
                        task.spawn(function() lastCheck = os.time(); rootPart:GetPropertyChangedSignal("CFrame"):Wait(); cframeChanged = true; end)
                        repeat task.wait() until cframeChanged or (os.time() - lastCheck) > 5
                        if rootPart.Anchored == true then lastCheck = os.time(); repeat task.wait() until rootPart.Anchored == false or (os.time() - lastCheck) > 5 end
    
                        Toggles.SpeedBypass:SetValue(true)
                        Options.SpeedSlider:SetValue(Script.Lagback.LastSpeed)
                        Options.FlySpeed:SetValue(Script.Lagback.LastFlySpeed)
                        Script.Lagback.Detected = false
                        Script.Functions.Alert({
                            Title = "Lagback Detection",
                            Description = "Fixed Lagback!"
                        })
                    end
                end
            end)
        end
    
        collision = character:WaitForChild("Collision")
        if collision then
            if Toggles.UpsideDown.Value then
                collision.Rotation = Vector3.new(collision.Rotation.X, collision.Rotation.Y, -90)
            end
    
            collisionClone = collision:Clone()
            collisionClone.CanCollide = false
            collisionClone.Massless = true
            collisionClone.Name = "CollisionClone"
            if collisionClone:FindFirstChild("CollisionCrouch") then
                collisionClone.CollisionCrouch:Destroy()
            end
    
            Script.Temp.CollisionSize = collisionClone.Size
            collisionClone.Parent = character
        end
    
        if isMines then
            if character then
                Script.Connections["AnticheatBypassTheMines"] = character:GetAttributeChangedSignal("Climbing"):Connect(function()                                
                    if Toggles.TheMinesAnticheatBypass.Value and character:GetAttribute("Climbing") then
                        task.wait(1)
                        character:SetAttribute("Climbing", false)
        
                        bypassed = true
    
                        for _, ladderEsp in pairs(Script.ESPTable.None) do
                            ladderEsp.Destroy()
                        end
    
                        Options.SpeedSlider:SetMax(45)
                        Options.FlySpeed:SetMax(75)
    
                        Script.Functions.Alert({
                            Title = "Anticheat Bypass",
                            Description = "Bypassed the anticheat successfully!",
                            Reason = "This will only last until the next cutscene!",
    
                            LinoriaMessage = "Bypassed the anticheat successfully! This will only last until the next cutscene",
    
                            Time = 7
                        })
                        if workspace:FindFirstChild("_internal_lonelyhub_acbypassprogress") then workspace:FindFirstChild("_internal_lonelyhub_acbypassprogress"):Destroy() end
                    end
                end)
            end
    
            if humanoid then
                humanoid.MaxSlopeAngle = Options.MaxSlopeAngle.Value
            end
        end
    end
    
    function Script.Functions.SetupOtherPlayerConnection(player: Player)
        if player.Character then
            if Toggles.PlayerESP.Value then
                Script.Functions.PlayerESP(player)
            end
        end
    
        Library:GiveSignal(player.CharacterAdded:Connect(function(newCharacter)
            task.delay(0.1, function()
                if Toggles.PlayerESP.Value then
                    Script.Functions.PlayerESP(player)
                end
            end)
    
            Script.Connections[player.Name .. "ChildAdded"] = newCharacter.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name:match("LibraryHintPaper") then
                    task.wait(0.1)
                    local code = Script.Functions.GetPadlockCode(child)
                    local output, count = string.gsub(code, "_", "x")
                    local padlock = workspace:FindFirstChild("Padlock", true)
    
                    if Toggles.AutoLibrarySolver.Value and tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                        remotesFolder.PL:FireServer(code)
                    end
    
                    if Toggles.NotifyPadlock.Value and count < 5 then
                        Script.Functions.Alert({
                            Title = "Padlock Code",
                            Description = string.format("Library Code: %s", output),
                            Reason = (tonumber(code) and "Solved the library padlock code" or "You are still missing some books"),
                        })
    
                        if Toggles.NotifyChat.Value and count == 0 then
                            RBXGeneral:SendAsync(string.format("Library Code: %s", output))
                        end
                    end
                end
            end)
        end))
    end
end

--// Main \\--

local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player") do
    PlayerGroupBox:AddSlider("SpeedSlider", {
        Text = "Speed Boost",
        Default = 0,
        Min = 0,
        Max = 7,
        Rounding = 1
    })

    PlayerGroupBox:AddSlider("VelocityLimiter", {
        Text = "Velocity Limiter",
        Default = 25,
        Min = 0,
        Max = 25,
        Rounding = 1
    })

    PlayerGroupBox:AddToggle("NoAccel", {
        Text = "No Acceleration",
        Default = false
    })

    PlayerGroupBox:AddToggle("InstaInteract", {
        Text = "Instant Interact",
        Default = false
    })

    PlayerGroupBox:AddToggle("FastClosetExit", {
        Text = "Fast Closet Exit",
        Default = false
    })

    PlayerGroupBox:AddDivider()

    PlayerGroupBox:AddToggle("EnableJump", {
        Text = "Enable Jump",
        Default = false,
        Visible = not isFools,
    })

    PlayerGroupBox:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false
    }):AddKeyPicker("NoclipKey", {
        Mode = "Toggle",
        Default = "N",
        Text = "Noclip",
        SyncToggleState = true
    })

    PlayerGroupBox:AddToggle("Fly", {
        Text = "Fly",
        Default = false
    }):AddKeyPicker("FlyKey", {
        Mode = "Toggle",
        Default = "F",
        Text = "Fly",
        SyncToggleState = true
    })
    
    PlayerGroupBox:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = 15,
        Min = 10,
        Max = 22,
        Rounding = 1,
        Compact = true,
    })
end

local ReachGroupBox = Tabs.Main:AddLeftGroupbox("Reach") do
    ReachGroupBox:AddToggle("DoorReach", {
        Text = "Door Reach",
        Default = false
    })

    ReachGroupBox:AddToggle("PromptClip", {
        Text = "Prompt Clip",
        Default = false
    })

    -- This is the grab/collect-from-anywhere control: every pickup in Doors (lighter,
    -- flashlight, gold, keys, vitamins) and every door unlock is a ProximityPrompt, and
    -- the multiplier is applied to MaxActivationDistance for each one. It was capped at
    -- 2, which reads as "no such feature" because 2x is still arm's length.
    ReachGroupBox:AddSlider("PromptReachMultiplier", {
        Text = "Grab / Interact Reach (x)",
        Default = 1,
        Min = 1,
        Max = 100,
        Rounding = 0
    })
end

local AutomationGroupBox = Tabs.Main:AddRightGroupbox("Automation") do
    AutomationGroupBox:AddToggle("AutoInteract", {
        Text = "Auto Interact",
        Default = false
    }):AddKeyPicker("AutoInteractKey", {
        Mode = Library.IsMobile and "Toggle" or "Hold",
        Default = "R",
        Text = "Auto Interact",
        SyncToggleState = Library.IsMobile
    })

    AutomationGroupBox:AddToggle("RemoteGrab", {
        Text = "Remote Grab (walk, fire, walk back)",
        Default = false,
        Tooltip = "Files the character to a key, gold pile, chest or lever within range, fires the prompt, returns."
    })

    AutomationGroupBox:AddSlider("GrabRange", {
        Text = "Remote Grab Range (studs)",
        Default = 250,
        Min = 25,
        Max = 2000,
        Rounding = 0
    })

    AutomationGroupBox:AddDivider()
    AutomationGroupBox:AddToggle("AutoWardrobeNotif", {
        Text = "Auto " .. HidingPlaceName[floor.Value] .. " Notifications",
        Default = false
    })

    AutomationGroupBox:AddToggle("AutoWardrobe", {
        Text = "Auto " .. HidingPlaceName[floor.Value],
        Default = false,
        Tooltip = "Might fail with multiple entities (Rush & Ambush, 3+ Rush spawns)",
        Visible = not isRetro
    }):AddKeyPicker("AutoWardrobeKey", {
        Mode = "Toggle",
        Default = "Q",
        Text = "Auto " .. HidingPlaceName[floor.Value],
        SyncToggleState = true
    })
    AutomationGroupBox:AddDivider()

    AutomationGroupBox:AddToggle("AutoHeartbeat", {
        Text = "Auto Heartbeat Minigame",
        Default = false,
        Visible = ExecutorSupport["getnamecallmethod"]
    })

    if isHotel or isFools then
        AutomationGroupBox:AddToggle("AutoLibrarySolver", {
            Text = "Auto Library Code",
            Default = false
        })

        AutomationGroupBox:AddSlider("AutoLibraryDistance", {
            Text = "Unlock Distance",
            Default = 20,
            Min = 1,
            Max = 100,
            Rounding = 0,
            Compact = true
        })

        AutomationGroupBox:AddDivider()
        AutomationGroupBox:AddDropdown("AutoBreakerSolverMethod", {
            AllowNull = false,
            Values = {"Legit", "Exploit"},
            Default = "Legit",
            Multi = false,

            Text = "Auto Breaker Solver Method"
        })

        AutomationGroupBox:AddToggle("AutoBreakerSolver", {
            Text = "Auto Breaker Box",
            Default = false
        })

        Toggles.AutoLibrarySolver:OnChanged(function(value)
            if value then
                for _, player in pairs(Players:GetPlayers()) do
                    if not player.Character then continue end
                    local tool = player.Character:FindFirstChildOfClass("Tool")

                    if tool and tool.Name:match("LibraryHintPaper") then
                        local code = Script.Functions.GetPadlockCode(tool)
                        local padlock = workspace:FindFirstChild("Padlock", true)

                        if tonumber(code) and Script.Functions.DistanceFromCharacter(padlock) <= Options.AutoLibraryDistance.Value then
                            remotesFolder.PL:FireServer(code)
                        end
                    end
                end
            end
        end)

        Toggles.AutoBreakerSolver:OnChanged(function(value)
            if value then
                local elevatorBreaker = workspace.CurrentRooms:FindFirstChild("ElevatorBreaker", true)
                if not elevatorBreaker then return end
    
                Script.Functions.SolveBreakerBox(elevatorBreaker)
            end
        end)
    elseif isMines then
        AutomationGroupBox:AddToggle("AutoAnchorSolver", {
            Text = "Auto Anchor Solver",
            Default = false
        })
    end
end

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
    MiscGroupBox:AddButton({
        Text = "Revive",
        Func = function()
            remotesFolder.Revive:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Play Again",
        Func = function()
            remotesFolder.PlayAgain:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Lobby",
        Func = function()
            remotesFolder.Lobby:FireServer()
        end,
        DoubleClick = true
    })
end

--// Exploits \\--

local AntiEntityGroupBox = Tabs.Exploits:AddLeftGroupbox("Anti-Entity") do
    AntiEntityGroupBox:AddToggle("AntiHalt", {
        Text = "Anti-Halt",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiScreech", {
        Text = "Anti-Screech",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiDupe", {
        Text = "Anti-" .. (isBackdoor and "Vacuum" or "Dupe"),
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiEyes", {
        Text = "Anti-" .. (isBackdoor and "Lookman" or "Eyes"),
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiSnare", {
        Text = "Anti-Snare",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiHearing", {
        Text = "Anti-Figure Hearing",
        Default = false,
        Visible = not isFools
    })
end

local TrollingGroupBox = Tabs.Exploits:AddLeftGroupbox("Trolling") do
    TrollingGroupBox:AddToggle("SpamOtherTools", {
        Text = "Spam Other Tools",
        Default = false
    }):AddKeyPicker("SpamOtherTools", {
        Default = "X",
        Text = "Spam Other Tools",
        Mode = Library.IsMobile and "Toggle" or "Hold",
        SyncToggleState = Library.IsMobile
    })

    TrollingGroupBox:AddToggle("UpsideDown", {
        Text = "Upside Down",
        Default = false
    })
end

local BypassGroupBox = Tabs.Exploits:AddRightGroupbox("Bypass") do
    BypassGroupBox:AddDropdown("SpeedBypassMethod", {
        AllowNull = false,
        Values = {"Massless", --[["Size"]]},
        Default = "Massless",
        Multi = false,

        Text = "Speed Bypass Method"
    })
    
    BypassGroupBox:AddSlider("SpeedBypassDelay", {
        Text = "Bypass Delay",
        Default = 0.21,
        Min = 0.2,
        Max = 0.22,
        Rounding = 2,
        Compact = true
    })

    BypassGroupBox:AddToggle("SpeedBypass", {
        Text = "Speed Bypass",
        Default = false
    })

    BypassGroupBox:AddToggle("LagbackDetection", {
        Text = "Lagback Detection",
        Default = false
    })

    BypassGroupBox:AddDivider()
    
    BypassGroupBox:AddToggle("InfItems", {
        Text = "Infinite Items",
        Default = false,
        Visible = not isFools
    })

    BypassGroupBox:AddInput("InfItemsFilter", {
        Text = "Infinite Items Filter",
        Placeholder = "candle, lockpick (empty = all)",
        Default = "",
        Visible = not isFools
    })

    BypassGroupBox:AddToggle("InfCrucifix", {
        Text = "Infinite Crucifix",
        Default = false,
        Visible = not isFools,
        Tooltip = "Very risky, you might die/lose the crucifix",
        Risky = true
    })

    BypassGroupBox:AddDivider()

    BypassGroupBox:AddToggle("FakeRevive", {
        Text = "Fake Revive",
        Default = false
    })

    BypassGroupBox:AddToggle("DeleteSeek", {
        Text = "Delete Seek (FE)",
        Default = false
    })
end


--// Visuals \\--

local ESPTabBox = Tabs.Visuals:AddLeftTabbox() do
    local ESPTab = ESPTabBox:AddTab("ESP") do
        ESPTab:AddToggle("DoorESP", {
            Text = "Door",
            Default = false,
        }):AddColorPicker("DoorEspColor", {
            Default = Color3.new(0, 1, 1),
        })
    
        ESPTab:AddToggle("ObjectiveESP", {
            Text = "Objective",
            Default = false,
        }):AddColorPicker("ObjectiveEspColor", {
            Default = Color3.new(0, 1, 0),
        })
    
        ESPTab:AddToggle("EntityESP", {
            Text = "Entity",
            Default = false,
        }):AddColorPicker("EntityEspColor", {
            Default = Color3.new(1, 0, 0),
        })
    
        ESPTab:AddToggle("ItemESP", {
            Text = "Item",
            Default = false,
        }):AddColorPicker("ItemEspColor", {
            Default = Color3.new(1, 0, 1),
        })
    
        ESPTab:AddToggle("ChestESP", {
            Text = "Chest",
            Default = false,
        }):AddColorPicker("ChestEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("PlayerESP", {
            Text = "Player",
            Default = false,
        }):AddColorPicker("PlayerEspColor", {
            Default = Color3.new(1, 1, 1),
        })
    
        ESPTab:AddToggle("HidingSpotESP", {
            Text = HidingPlaceName[floor.Value],
            Default = false,
        }):AddColorPicker("HidingSpotEspColor", {
            Default = Color3.new(0, 0.5, 0),
        })
    
        ESPTab:AddToggle("GoldESP", {
            Text = "Gold",
            Default = false,
        }):AddColorPicker("GoldEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("GuidingLightESP", {
            Text = "Guiding Light",
            Default = false,
        }):AddColorPicker("GuidingLightEspColor", {
            Default = Color3.new(0, 0.5, 1),
        })

        -- The payload already ships the Entity toggle; the decrypted hub's value is
        -- the SelectedEntities dropdown, so only the filter is added here.
        ESPTab:AddDropdown("EntityESPFilter", {
            AllowNull = false,
            Values = ENTITY_FILTER_VALUES,
            Default = ENTITY_FILTER_VALUES,
            Multi = true,
            Text = "Entity Filter",
        })
    end

    local ESPSettingsTab = ESPTabBox:AddTab("Settings") do
        ESPSettingsTab:AddToggle("ESPHighlight", {
            Text = "Enable Highlight",
            Default = true,
        })

        ESPSettingsTab:AddToggle("ESPTracer", {
            Text = "Enable Tracer",
            Default = true,
        })
    
        ESPSettingsTab:AddToggle("ESPRainbow", {
            Text = "Rainbow ESP",
            Default = false,
        })
    
        ESPSettingsTab:AddToggle("ESPDistance", {
            Text = "Show Distance",
            Default = true
        })
    
        ESPSettingsTab:AddToggle("ESPShowEntityText", {
            Text = "Show Entity Text",
            Default = true
        })

        ESPSettingsTab:AddDropdown("EntityLanguage", {
            Text = "Entity Names",
            Values = { "EN", "ID" },
            Default = "EN"
        })
    
        ESPSettingsTab:AddSlider("ESPFillTransparency", {
            Text = "Fill Transparency",
            Default = 0.75,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPOutlineTransparency", {
            Text = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPTextSize", {
            Text = "Text Size",
            Default = 22,
            Min = 16,
            Max = 26,
            Rounding = 0
        })

        ESPSettingsTab:AddSlider("ESPTracerThickness", {
            Text = "Tracer Thickness",
            Default = 1,
            Min = 1,
            Max = 4,
            Rounding = 0
        })

        ESPSettingsTab:AddDropdown("ESPTracerStart", {
            AllowNull = false,
            Values = {"Bottom", "Center", "Top", "Mouse"},
            Default = "Bottom",
            Multi = false,

            Text = "Tracer Start Position"
        })
    end
end

local AmbientGroupBox = Tabs.Visuals:AddLeftGroupbox("Ambient") do
    AmbientGroupBox:AddSlider("Brightness", {
        Text = "Brightness",
        Default = 0,
        Min = 0,
        Max = 3,
        Rounding = 1,
    })

    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })

    AmbientGroupBox:AddToggle("NoFog", {
        Text = "No Fog",
        Default = false,
    })

    AmbientGroupBox:AddToggle("AntiLag", {
        Text = "Anti-Lag",
        Default = false,
    })
end

local NotifyTabBox = Tabs.Visuals:AddRightTabbox() do
    local NotifyTab = NotifyTabBox:AddTab("Notifier") do
        NotifyTab:AddDropdown("NotifyEntity", {
            AllowNull = true,
            Values = {"Blitz", "Lookman", "Rush", "Ambush", "Eyes", "Halt Room", "A60", "A120", "Jeff The Killer", "Gloombat Swarm"},
            Default = {},
            Multi = true,

            Text = "Notify Entities"
        })

        NotifyTab:AddToggle("NotifyPadlock", {
            Text = "Notify Library Code",
            Default = false,
        })

        NotifyTab:AddToggle("NotifyOxygen", {
            Text = "Notify Oxygen",
            Default = false,
        })

        NotifyTab:AddToggle("NotifyHideTime", {
            Text = "Notify Hide Time",
            Default = false,
        })
    end

    local NotifySettingsTab = NotifyTabBox:AddTab("Settings") do
        NotifySettingsTab:AddToggle("NotifyChat", {
            Text = "Notify Chat",
            Tooltip = "Entity and Padlock Code",
            Default = false,
        })

        NotifySettingsTab:AddDivider()
        
        NotifySettingsTab:AddToggle("NotifySound", {
            Text = "Play Alert Sound",
            Default = true,
        })

        NotifySettingsTab:AddDropdown("NotifySide", {
            AllowNull = false,
            Values = {"Left", "Right"},
            Default = "Right",
            Multi = false,

            Text = "Notification Side"
        })

        NotifySettingsTab:AddDropdown("NotifyStyle", {
            AllowNull = false,
            Values = {"Linoria", "Doors"},
            Default = "Linoria",
            Multi = false,

            Text = "Notification Style"
        })
    end
end

local SelfGroupBox = Tabs.Visuals:AddRightGroupbox("Self") do
    SelfGroupBox:AddToggle("ThirdPerson", {
        Text = "Third Person",
        Default = false
    }):AddKeyPicker("ThirdPersonKey", {
        Default = "V",
        Text = "Third Person",
        Mode = "Toggle",
        SyncToggleState = not Library.IsMobile -- ????
    })
    
    SelfGroupBox:AddSlider("FOV", {
        Text = "Field of View",
        Default = 70,
        Min = 70,
        Max = 120,
        Rounding = 0
    })
    
    SelfGroupBox:AddToggle("NoCamBob", {
        Text = "No Camera Bobbing",
        Default = false,
        Visible = ExecutorSupport["require"]
    })

    SelfGroupBox:AddToggle("NoCamShake", {
        Text = "No Camera Shake",
        Default = false,
        Visible = ExecutorSupport["require"]
    })

    SelfGroupBox:AddToggle("NoCutscenes", {
        Text = "No Cutscenes",
        Default = false,
    })

    SelfGroupBox:AddToggle("TranslucentHidingSpot", {
        Text = "Translucent " .. HidingPlaceName[floor.Value],
        Default = false
    })
    
    SelfGroupBox:AddSlider("HidingTransparency", {
        Text = "Hiding Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Compact = true,
    })
end

--// Floor \\--
task.spawn(function()
    if isHotel then
        local Hotel_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
            Hotel_AntiEntityGroupBox:AddToggle("AntiSeekObstructions", {
                Text = "Anti-Seek Obstructions",
                Default = false
            })
        end

        local Hotel_BypassGroupBox = Tabs.Floor:AddLeftGroupbox("Bypass") do
            Hotel_BypassGroupBox:AddToggle("AvoidRushAmbush", {
                Text = "Avoid Rush/Ambush",
                Tooltip = "Doesn't work for greenhouse :(",
                Default = false,
                Risky = true
            })
        end

        local Hotel_ModifiersGroupBox = Tabs.Floor:AddRightGroupbox("Modifiers") do
            Hotel_ModifiersGroupBox:AddToggle("AntiA90", {
                Text = "Anti-A90",
                Default = false
            })

            Hotel_ModifiersGroupBox:AddToggle("NoJammin", {
                Text = "No Jammin",
                Default = false
            })
        end

        Toggles.AntiSeekObstructions:OnChanged(function(value)
            for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                    for _, obj in pairs(v:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanTouch = not value end
                    end
                end
            end
        end)

        Toggles.AntiA90:OnChanged(function(value)
            if not mainGame then return end
            local module = mainGame:FindFirstChild("A90", true) or mainGame:FindFirstChild("_A90", true)
        
            if module then
                module.Name = value and "_A90" or "A90"
            end
        end)

        Toggles.NoJammin:OnChanged(function(value)
            if not liveModifiers:FindFirstChild("Jammin") then return end

            if mainGame then
                local jamSound = mainGame:FindFirstChild("Jam", true)
                if jamSound then jamSound.Playing = not value end
            end

            local jamminEffect = SoundService:FindFirstChild("Jamming", true)
            if jamminEffect then jamminEffect.Enabled = not value end
        end)
    elseif isMines then
        local Mines_MovementGroupBox = Tabs.Floor:AddLeftGroupbox("Movement") do
            Mines_MovementGroupBox:AddToggle("FastLadder", {
                Text = "Fast Ladder",
                Default = false
            })

            Mines_MovementGroupBox:AddSlider("MaxSlopeAngle", {
                Text = "Max Floor Angle",
                Default = 45,
                Min = 0,
                Max = 90,
                Rounding = 0
            })
        end

        local Mines_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
            Mines_AntiEntityGroupBox:AddToggle("AntiGiggle", {
                Text = "Anti-Giggle",
                Default = false
            })

            Mines_AntiEntityGroupBox:AddToggle("AntiGloomEgg", {
                Text = "Anti-Gloom Egg",
                Default = false
            })

            Mines_AntiEntityGroupBox:AddToggle("AntiBridgeFall", {
                Text = "Anti-Bridge Fall",
                Default = false
            })

            Mines_AntiEntityGroupBox:AddToggle("AntiSeekFlood", {
                Text = "Anti-Seek Flood",
                Default = false
            })
        end

        local Mines_AutomationGroupBox = Tabs.Floor:AddRightGroupbox("Automation") do
            Mines_AutomationGroupBox:AddButton({
                Text = "Beat Door 200",
                Func = function()
                    if latestRoom.Value < 99 then
                        Script.Functions.Alert({
                            Title = "Beat Door 200",
                            Description = "You haven't reached door 200...",
                            Time = 5
                        })

                        return
                    end

                    local bypassing = Toggles.SpeedBypass.Value
                    local startPos = rootPart.CFrame

                    Toggles.SpeedBypass:SetValue(false)

                    local damHandler = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("_DamHandler")

                    if damHandler then
                        if damHandler:FindFirstChild("PlayerBarriers1") then
                            for _, pump in pairs(damHandler.Flood1.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                forceFirePrompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            task.wait(8)
                        end

                        if damHandler:FindFirstChild("PlayerBarriers2") then
                            for _, pump in pairs(damHandler.Flood2.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                forceFirePrompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            task.wait(8)
                        end

                        if damHandler:FindFirstChild("PlayerBarriers3") then
                            for _, pump in pairs(damHandler.Flood3.Pumps:GetChildren()) do
                                character:PivotTo(pump.Wheel.CFrame)
                                task.wait(0.25)
                                forceFirePrompt(pump.Wheel.ValvePrompt)
                                task.wait(0.25)
                            end

                            task.wait(10)
                        end
                    end

                    local generator = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("MinesGenerator", true)

                    if generator then
                        character:PivotTo(generator.PrimaryPart.CFrame)
                        task.wait(0.25)
                        forceFirePrompt(generator.Lever.LeverPrompt)
                        task.wait(0.25)
                    end

                    Toggles.SpeedBypass:SetValue(bypassing)
                    character:PivotTo(startPos)
                end
            })

            Mines_AutomationGroupBox:AddToggle("TheMinesAnticheatBypass", {
                Text = "Anticheat Bypass",
                Default = false
            })
        end

        local Mines_BypassGroupBox = Tabs.Floor:AddRightGroupbox("Bypass") do
            Mines_BypassGroupBox:AddToggle("MinecartTeleport", {
                Text = "Minecart Teleport",
                Default = false
            })

            Mines_BypassGroupBox:AddToggle("MinecartTeleportDebug", {
                Text = "Minecart Teleport Debug",
                Default = false,
                Visible = false,
            })
        end
        
        local Mines_VisualGroupBox = Tabs.Floor:AddRightGroupbox("Visuals") do
            Mines_VisualGroupBox:AddToggle("MinecartPathVisualiser", {
                Text = "Visualize Correct Seek Path",
                Default = false
            })
        end

        Toggles.TheMinesAnticheatBypass:OnChanged(function(value)
            if value then
                local progressPart = Instance.new("Part", Workspace) do
                    progressPart.Anchored = true
                    progressPart.CanCollide = false
                    progressPart.Name = "_internal_lonelyhub_acbypassprogress"
                    progressPart.Transparency = 1
                end

                if Library.IsMobile then
                    Script.Functions.Alert({
                        Title = "Anticheat bypass",
                        Description = "To bypass the ac, you must interact with a ladder.",
                        Reason = "Ladder ESP has been enabled, do not move while on the ladder.",

                        LinoriaMessage = "To bypass the anticheat, you must interact with a ladder. Ladder ESP has been enabled.\nDo not move while on the ladder.",
                        Time = progressPart
                    })
                else
                    Script.Functions.Alert({
                        Title = "Anticheat bypass",
                        Description = "To bypass the ac, you must interact with a ladder.",
                        Reason = "Ladder ESP has been enabled, do not move while on the ladder.",

                        LinoriaMessage = "To bypass the anticheat, you must interact with a ladder. Ladder ESP has been enabled.\nDo not move while on the ladder.",
                        Time = progressPart
                    })
                end
                

                -- Ladder ESP
                for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "Ladder" then
                        Script.Functions.ESP({
                            Type = "None",
                            Object = v,
                            Text = "Ladder",
                            Color = Color3.new(0, 0, 1)
                        })
                    end
                end
            else
                if workspace:FindFirstChild("_internal_lonelyhub_acbypassprogress") then workspace:FindFirstChild("_internal_lonelyhub_acbypassprogress"):Destroy() end

                for _, ladderEsp in pairs(Script.ESPTable.None) do
                    ladderEsp.Destroy()
                end

                if bypassed and not Script.FakeRevive.Enabled then
                    remotesFolder.ClimbLadder:FireServer()
                    bypassed = false
                    
                    Options.SpeedSlider:SetMax(Toggles.SpeedBypass.Value and 45 or (Toggles.EnableJump.Value and 3 or 7))
                    Options.FlySpeed:SetMax(Toggles.SpeedBypass.Value and 75 or 22)
                end
            end
        end)

        Options.MaxSlopeAngle:OnChanged(function(value)
            if humanoid then
                humanoid.MaxSlopeAngle = value
            end
        end)

        Toggles.AntiGiggle:OnChanged(function(value)
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, giggle in pairs(room:GetChildren()) do
                    if giggle.Name == "GiggleCeiling" then
                        giggle:WaitForChild("Hitbox", 5).CanTouch = not value
                    end
                end
            end
        end)

        -- this shits bad, but it doesnt go through all parts, so its optimized :cold_face:
        Toggles.AntiGloomEgg:OnChanged(function(value)
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, gloomPile in pairs(room:GetChildren()) do
                    if gloomPile.Name == "GloomPile" then
                        for _, gloomEgg in pairs(gloomPile:GetDescendants()) do
                            if gloomEgg.Name == "Egg" then
                                gloomEgg.CanTouch = not value
                            end
                        end
                    end
                end
            end
        end)

        Toggles.AntiBridgeFall:OnChanged(function(value)
            if value then
                for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                    if not room:FindFirstChild("Parts") then continue end
    
                    for _, bridge in pairs(room.Parts:GetChildren()) do
                        if bridge.Name == "Bridge" then
                            for _, barrier in pairs(bridge:GetChildren()) do
                                if not (barrier.Name == "PlayerBarrier" and barrier.Size.Y == 2.75 and (barrier.Rotation.X == 0 or barrier.Rotation.X == 180)) then continue end

                                local clone = barrier:Clone()
                                clone.CFrame = clone.CFrame * CFrame.new(0, 0, -5)
                                clone.Color = Color3.new(1, 1, 1)
                                clone.Name = "AntiBridge"
                                clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, 11)
                                clone.Transparency = 0
                                clone.Parent = bridge
                                
                                table.insert(Script.Temp.Bridges, clone)
                            end
                        end
                    end
                end
            else
                for _, bridge in pairs(Script.Temp.Bridges) do
                    bridge:Destroy()
                end
            end
        end)

        Toggles.AntiSeekFlood:OnChanged(function(value)
            local room = workspace.CurrentRooms:FindFirstChild("100")
            
            if room and room:FindFirstChild("_DamHandler") then
                local seekFlood = room._DamHandler:FindFirstChild("SeekFloodline")
                if seekFlood then
                    seekFlood.CanCollide = value
                end
            end
        end)

        Toggles.MinecartPathVisualiser:OnChanged(function(value)
            Script.Functions.Minecart.DrawNodes()
        end)
    elseif isBackdoor then
        local Backdoors_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
            Backdoors_AntiEntityGroupBox:AddToggle("AntiHasteJumpscare", {
                Text = "Anti Haste Jumpscare",
                Default = false
            })
        end

        local Backdoors_VisualGroupBox = Tabs.Floor:AddRightGroupbox("Visual") do
            Backdoors_VisualGroupBox:AddToggle("HasteClock", {
                Text = "Haste Clock",
                Default = true
            })
        end

        Toggles.AntiHasteJumpscare:OnChanged(function(value)
            local clientRemote = ReplicatedStorage.FloorReplicated.ClientRemote
            local internal_temp_lonelyhub = clientRemote:FindFirstChild("_lonelyhub")
            
            if not internal_temp_lonelyhub then internal_temp_lonelyhub = Instance.new("Folder", clientRemote); internal_temp_lonelyhub.Name = "_lonelyhub" end

            if value then
                for i,v in pairs(clientRemote.Haste:GetChildren()) do
                    if v:IsA("RemoteEvent") then continue end

                    v.Parent = internal_temp_lonelyhub
                end
            else
                for i,v in pairs(internal_temp_lonelyhub:GetChildren()) do
                    v.Parent = clientRemote.Haste
                end
            end
        end)

        Toggles.HasteClock:OnChanged(function(value)
            if not value then
                Script.Functions.HideCaptions()
            end
        end)

        function Script.Functions.TimerFormat(seconds: number)
            local minutes = math.floor(seconds / 60)
            local remainingSeconds = seconds % 60
            return string.format("%02d:%02d", minutes, remainingSeconds)
        end

        Library:GiveSignal(floorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(function()
            if Toggles.HasteClock.Value and floorReplicated.ScaryStartsNow.Value then
                Script.Functions.Captions(Script.Functions.TimerFormat(floorReplicated.DigitalTimer.Value))
            end
        end))
    elseif isRooms then
        local Rooms_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
            Rooms_AntiEntityGroupBox:AddToggle("AntiA90", {
                Text = "Anti-A90",
                Default = false
            })
        end

        local Rooms_AutomationGroupBox = Tabs.Floor:AddRightGroupbox("Automation") do
            Rooms_AutomationGroupBox:AddToggle("AutoRooms", {
                Text = "Auto Rooms",
                Default = false
            })

            Rooms_AutomationGroupBox:AddLabel("Recommended Settings:\nSpeed Bypass and Noclip disabled", true)

            Rooms_AutomationGroupBox:AddDivider()

            Rooms_AutomationGroupBox:AddToggle("AutoRoomsDebug", { 
                Text = "Show Debug Info",
                Default = false
            })
            
            Rooms_AutomationGroupBox:AddToggle("ShowAutoRoomsPathNodes", { 
                Text = "Show Pathfinding Nodes",
                Default = false
            })

        end

        Toggles.AntiA90:OnChanged(function(value)
            if Toggles.AutoRooms.Value and not value then
                Script.Functions.Alert({
                    Title = "Auto Rooms",
                    Description = "Anti A-90 is required for Auto Rooms to work!",
                    Reason = "Anti A-90 has been enabled",
                })
                
                Toggles.AntiA90:SetValue(true)
            end

            if not mainGame then return end
            local module = mainGame:FindFirstChild("A90", true) or mainGame:FindFirstChild("_A90", true)
        
            if module then
                module.Name = value and "_A90" or "A90"
            end
        end)

        function Script.Functions.GetAutoRoomsPathfindingGoal(): BasePart
            local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
            if entity and entity.PrimaryPart.Position.Y > -10 then
                local GoalLocker = Script.Functions.GetNearestAssetWithCondition(function(asset)
                    return asset.Name == "Rooms_Locker" and not asset.HiddenPlayer.Value and asset.PrimaryPart.Position.Y > -10
                end)

                return GoalLocker.PrimaryPart
            end

            return workspace.CurrentRooms[latestRoom.Value].Door.Door
        end

        local _internal_lonelyhub_pathfinding_nodes = Instance.new("Folder", Workspace) do
            _internal_lonelyhub_pathfinding_nodes.Name = "_internal_lonelyhub_pathfinding_nodes"
        end

        local _internal_lonelyhub_pathfinding_block = Instance.new("Folder", Workspace) do
            _internal_lonelyhub_pathfinding_block.Name = "_internal_lonelyhub_pathfinding_block"
        end

        Toggles.ShowAutoRoomsPathNodes:OnChanged(function(value)
            for _, node in pairs(_internal_lonelyhub_pathfinding_nodes:GetChildren()) do
                node.Transparency = value and 0.5 or 1
            end
            for _, nodeBlock in pairs(_internal_lonelyhub_pathfinding_block:GetChildren()) do
                nodeBlock.Transparency = value and 0.9 or 1
            end
        end)

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not Toggles.AutoRooms.Value then return end

            local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
            local isEntitySpawned = (entity and entity.PrimaryPart.Position.Y > -10)
            
            if isEntitySpawned and not rootPart.Anchored then
                local pathfindingGoal = Script.Functions.GetAutoRoomsPathfindingGoal()

                if Script.Functions.IsPromptInRange(pathfindingGoal.Parent.HidePrompt) then
                    forceFirePrompt(pathfindingGoal.Parent.HidePrompt)
                end
            elseif not isEntitySpawned and rootPart.Anchored then
                for i = 1, 10 do
                    remotesFolder.CamLock:FireServer()
                end
            end
        end))

        Toggles.AutoRooms:OnChanged(function(value)
            local hasResetFailsafe = false

            local function nodeCleanup()
                _internal_lonelyhub_pathfinding_nodes:ClearAllChildren()
                _internal_lonelyhub_pathfinding_block:ClearAllChildren()
                hasResetFailsafe = true
            end

            local function moveToCleanup()
                if humanoid then
                    humanoid:Move(rootPart.Position)
                    humanoid.WalkToPart = nil
                    humanoid.WalkToPoint = rootPart.Position
                end
                nodeCleanup()
            end

            if value then
                Toggles.AntiA90:SetValue(true)
                local lastRoomValue = 0

                local function createNewBlockedPoint(point: PathWaypoint)
                    local block = Instance.new("Part", _internal_lonelyhub_pathfinding_block)
                    local pathMod = Instance.new("PathfindingModifier", block)
                    pathMod.Label = "_ms_pathBlock"

                    block.Name = "_lonelyhub_blocked_path"
                    block.Shape = Enum.PartType.Block

                    local sizeY = 10
                    
                    block.Size = Vector3.new(1, sizeY, 1)
                    block.Color = Color3.fromRGB(255, 130, 30)
                    block.Material = Enum.Material.Neon
                    block.Position = point.Position + Vector3.new(0, sizeY / 2, 0)
                    block.Anchored = true
                    block.CanCollide = false
                    block.Transparency = Toggles.ShowAutoRoomsPathNodes.Value and 0.9 or 1
                end

                local function doAutoRooms()
                    local pathfindingGoal = Script.Functions.GetAutoRoomsPathfindingGoal()

                    if latestRoom.Value ~= lastRoomValue then
                        _internal_lonelyhub_pathfinding_block:ClearAllChildren()
                        lastRoomValue = latestRoom.Value
                    end
                    
                    Script.Functions.Log({
                        Title = "Auto Rooms",
                        Description = "Calculated Objective Successfully!\nObjective: " .. pathfindingGoal.Parent.Name .. "\nCreating path...",
                    }, Toggles.AutoRoomsDebug.Value)

                    local path = PathfindingService:CreatePath({
                        AgentCanJump = false,
                        AgentCanClimb = false,
                        WaypointSpacing = 2,
                        AgentRadius = 1,
                        Costs = {
                            _ms_pathBlock = 8 --cost will increase the more stuck you get.
                        }
                    })

                    Script.Functions.Log({
                        Title = "Auto Rooms",
                        Description = "Computing Path to " .. pathfindingGoal.Parent.Name .. "...",
                    }, Toggles.AutoRoomsDebug.Value)

                    path:ComputeAsync(rootPart.Position - Vector3.new(0, 2.5, 0), pathfindingGoal.Position)
                    local waypoints = path:GetWaypoints()
                    local waypointAmount = #waypoints

                    if path.Status == Enum.PathStatus.Success then
                        hasResetFailsafe = true
                        task.spawn(function()
                            task.wait(0.1)
                            hasResetFailsafe = false
                            if humanoid and collision then
                                local checkFloor = humanoid.FloorMaterial
                                local isStuck = checkFloor == Enum.Material.Air or checkFloor == Enum.Material.Concrete
                                if isStuck then
                                    repeat task.wait()
                                        collision.CanCollide = false
                                        collision.CollisionCrouch.CanCollide = true
                                    until not isStuck or hasResetFailsafe
                                    collision.CanCollide = true
                                end
                                hasResetFailsafe = true
                            end
                        end)

                        Script.Functions.Log({
                            Title = "Auto Rooms",
                            Description = "Computed path successfully with " .. waypointAmount .. " waypoints!",
                        }, Toggles.AutoRoomsDebug.Value)

                        _internal_lonelyhub_pathfinding_nodes:ClearAllChildren()

                        for i, waypoint in pairs(waypoints) do
                            local node = Instance.new("Part", _internal_lonelyhub_pathfinding_nodes) do
                                node.Name = "_internal_node_" .. i
                                node.Size = Vector3.new(1, 1, 1)
                                node.Position = waypoint.Position
                                node.Anchored = true
                                node.CanCollide = false
                                node.Shape = Enum.PartType.Ball
                                node.Color = Color3.new(1, 0, 0)
                                node.Transparency = Toggles.ShowAutoRoomsPathNodes.Value and 0.5 or 1
                            end
                        end

                        local lastWaypoint = nil
                        for i, waypoint in pairs(waypoints) do
                            local moveToFinished = false
                            local recalculate = false
                            local waypointConnection = humanoid.MoveToFinished:Connect(function() moveToFinished = true end)
                            if not moveToFinished or not Toggles.AutoRooms.Value then
                                humanoid:MoveTo(waypoint.Position)
                                
                                local entity = (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
                                local isEntitySpawned = (entity and entity.PrimaryPart.Position.Y > -10)

                                if isEntitySpawned and not rootPart.Anchored and pathfindingGoal.Parent.Name ~= "Rooms_Locker" then
                                    waypointConnection:Disconnect()

                                    if not Toggles.AutoRooms.Value then
                                        nodeCleanup()
                                        break
                                    else
                                        if _internal_lonelyhub_pathfinding_nodes:FindFirstChild("_internal_node_" .. i) then
                                            _internal_lonelyhub_pathfinding_nodes:FindFirstChild("_internal_node_" .. i):Destroy()
                                        end
                                    end

                                    break
                                end

                                task.delay(1.5, function()
                                    if moveToFinished then return end
                                    if (not Toggles.AutoRooms.Value or Library.Unloaded) then return moveToCleanup() end

                                    repeat task.wait(.25) until (not character:GetAttribute("Hiding") and not character.PrimaryPart.Anchored)

                                    Script.Functions.Alert({
                                        Title = "Auto Rooms",
                                        Description = "Seems like you are stuck, trying to recalculate path...",
                                        Reason = "Failed to move to waypoint",
                                    })

                                    recalculate = true
                                    if lastWaypoint == nil and waypointAmount > 1 then
                                        waypoint = waypoints[i+1]
                                    else
                                        waypoint = waypoints[i-1]
                                    end

                                    createNewBlockedPoint(waypoint)
                                end)
                            end

                            repeat task.wait() until moveToFinished or not Toggles.AutoRooms.Value or recalculate or Library.Unloaded
                            lastWaypoint = waypoint

                            waypointConnection:Disconnect()

                            if not Toggles.AutoRooms.Value then
                                nodeCleanup()
                                break
                            else
                                if _internal_lonelyhub_pathfinding_nodes:FindFirstChild("_internal_node_" .. i) then
                                    _internal_lonelyhub_pathfinding_nodes:FindFirstChild("_internal_node_" .. i):Destroy()
                                end
                            end

                            if recalculate then break end
                        end
                    else
                        Script.Functions.Log({
                            Title = "Auto Rooms",
                            Description = "Pathfinding failed with status " .. tostring(path.Status)   
                        }, Toggles.AutoRoomsDebug.Value)
                    end
                end

                -- Movement
                while Toggles.AutoRooms.Value and not Library.Unloaded do
                    if latestRoom.Value == 1000 then
                        Script.Functions.Alert({
                            Title = "Auto Rooms",
                            Description = "You have reached A-1000",
                            Reason = "A-1000 reached by lonelyhub autorooms",
                        })

                        break
                    end

                    doAutoRooms()
                end
                
                -- Unload Auto Rooms
                moveToCleanup()
            end
        end)
    elseif isFools then
        local Fools_TrollingGroupBox = Tabs.Floor:AddLeftGroupbox("Trolling") do
            Fools_TrollingGroupBox:AddToggle("GrabBananaJeffToggle",{
                Text = "Grab Banana / Jeff",
                Default = false
            }):AddKeyPicker("GrabBananaJeff", {
                Default = "H",
                Mode = "Hold",
                Text = "Grab Banana / Jeff",
            })
        
            Fools_TrollingGroupBox:AddLabel("Throw"):AddKeyPicker("ThrowBananaJeff", {
                Default = "G",
                Mode = "Hold",
                Text = "Throw"
            })

            Fools_TrollingGroupBox:AddSlider("ThrowStrength", {
                Text = "Throw Strength",
                Default = 1,
                Min = 1,
                Max = 10,
                Rounding = 1,
                Compact = true
            })

            function Script.Functions.ThrowBananaJeff()
                local target = Script.Temp.HoldingItem

                Script.Temp.ItemHoldTrack:Stop()
                Script.Temp.ItemThrowTrack:Play()

                task.wait(0.35)

                if target:FindFirstChildWhichIsA("BodyGyro") then
                    target:FindFirstChildWhichIsA("BodyGyro"):Destroy()
                end

                local velocity = localPlayer:GetMouse().Hit.LookVector * 0.5 * 200 * Options.ThrowStrength.Value
                local spawnPos = camera.CFrame:ToWorldSpace(CFrame.new(0,0,-3) * CFrame.lookAt(Vector3.new(0, 0, 0), camera.CFrame.LookVector))
                
                target.CFrame = spawnPos
                target.Velocity = velocity

                if target:FindFirstAncestorWhichIsA("Model").Name == "JeffTheKiller" then
                    for _,i in ipairs(target:FindFirstAncestorWhichIsA("Model"):GetDescendants()) do
                        if i:IsA("BasePart") then
                            i.CanTouch = not Toggles.AntiJeffClient.Value
                            i.CanCollide = i:GetAttribute("Clip") or true
                        end
                    end
                else
                    target.CanTouch = not Toggles.AntiBananaPeel.Value
                    target.CanCollide = target:GetAttribute("Clip") or true
                end

                Script.Temp.HoldingItem = nil
            end
        end

        local Fools_AntiEntityGroupBox = Tabs.Floor:AddRightGroupbox("Anti-Entity") do
            Fools_AntiEntityGroupBox:AddToggle("AntiSeekObstructions", {
                Text = "Anti-Seek Obstructions",
                Default = false
            })

            Fools_AntiEntityGroupBox:AddToggle("AntiBananaPeel", {
                Text = "Anti-Banana",
                Default = false
            })

            Fools_AntiEntityGroupBox:AddToggle("AntiJeffClient", {
                Text = "Anti-Jeff",
                Default = false
            })
        end

        local Fools_BypassGroupBox = Tabs.Floor:AddRightGroupbox("Bypass") do
            Fools_BypassGroupBox:AddToggle("InfRevives", {
                Text = "Infinite Revives",
                Default = false
            })

            Fools_BypassGroupBox:AddToggle("AntiJeffServer", {
                Text = "Anti-Jeff (FE)",
                Default = false
            })

            Fools_BypassGroupBox:AddDivider()

            Fools_BypassGroupBox:AddToggle("GodmodeNoclipBypassFools", {
                Text = "Godmode",
                Default = false
            })

            Fools_BypassGroupBox:AddToggle("FigureGodmodeFools", {
                Text = "Figure Godmode",
                Default = false
            })
        end

        Toggles.AntiSeekObstructions:OnChanged(function(value)
            for i, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                if v.Name == "ChandelierObstruction" or v.Name == "Seek_Arm" then
                    for _, obj in pairs(v:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanTouch = not value end
                    end
                end
            end
        end)
        
        Toggles.AntiBananaPeel:OnChanged(function(value)
            for _, peel in pairs(workspace:GetChildren()) do
                if peel.Name == "BananaPeel" then
                    peel.CanTouch = not value
                end
            end
        end)

        Toggles.AntiJeffClient:OnChanged(function(value)
            for _, jeff in pairs(workspace:GetChildren()) do
                if jeff:IsA("Model") and jeff.Name == "JeffTheKiller" then
                    for i, v in pairs(jeff:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanTouch = not value
                        end
                    end
                end
            end
        end)

        Toggles.AntiJeffServer:OnChanged(function(value)
            if value then
                for _, jeff in pairs(workspace:GetChildren()) do
                    if jeff:IsA("Model") and jeff.Name == "JeffTheKiller" then
                        task.spawn(function()
                            repeat task.wait() until isnetowner(jeff.PrimaryPart)
                            jeff:FindFirstChildOfClass("Humanoid").Health = 0
                        end)
                    end
                end
            end
        end)

        Toggles.InfRevives:OnChanged(function(value)
            if value and not localPlayer:GetAttribute("Alive") then
                remotesFolder.Revive:FireServer()
            end
        end)

        Toggles.GodmodeNoclipBypassFools:OnChanged(function(value)
            if value and humanoid and collision then
                humanoid.HipHeight = 3.01
                task.wait()
                collision.Position = collision.Position - Vector3.new(0, 8, 0)
                task.wait()
                humanoid.HipHeight = 3
                
                -- don't want to put collision up when you load the script 
                -- im sorry deivid
                task.spawn(function()
                    repeat task.wait() until not Toggles.GodmodeNoclipBypassFools.Value
                    humanoid.HipHeight = 3.01
                    task.wait()
                    collision.Position = collision.Position + Vector3.new(0, 8, 0)
                    task.wait()
                    humanoid.HipHeight = 3
                end)
            end
        end)

        Toggles.FigureGodmodeFools:OnChanged(function(value)
            if value and not Toggles.GodmodeNoclipBypassFools.Value then Toggles.GodmodeNoclipBypassFools:SetValue(true); Script.Functions.Alert({Title = "Figure Godmode", Description = "Godmode/Noclip Bypass is required to use figure godmode", Reason = "Godmode/Noclip Bypass not enabled"}) end
            if latestRoom.Value ~= 50 or latestRoom.Value ~= 100 then return end

            for _, figure in pairs(workspace.CurrentRooms:GetDescendants()) do
                if figure:IsA("Model") and figure.Name == "FigureRagdoll" then
                    for i, v in pairs(figure:GetDescendants()) do
                        if v:IsA("BasePart") then
                            if not v:GetAttribute("Clip") then v:SetAttribute("Clip", v.CanCollide) end

                            v.CanTouch = not value
                            v.CanCollide = not value
                        end
                    end
                end
            end
        end)
    end
end)

--// Features Callback \\--
Toggles.InstaInteract:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if value then
                if not prompt:GetAttribute("Hold") then prompt:SetAttribute("Hold", prompt.HoldDuration) end
                prompt.HoldDuration = 0
            else
                prompt.HoldDuration = prompt:GetAttribute("Hold") or 0
            end
        end
    end
end)

Toggles.NoAccel:OnChanged(function(value)
    if not rootPart then return end

    if value then
        Script.Temp.NoAccelValue = rootPart.CustomPhysicalProperties.Density
        
        local existingProperties = rootPart.CustomPhysicalProperties
        rootPart.CustomPhysicalProperties = PhysicalProperties.new(100, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    else
        local existingProperties = rootPart.CustomPhysicalProperties
        rootPart.CustomPhysicalProperties = PhysicalProperties.new(Script.Temp.NoAccelValue, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    end
end)

Toggles.EnableJump:OnChanged(function(value)
    if isFools then return end

    if character then
        character:SetAttribute("CanJump", value)
    end

    if not value and not Toggles.SpeedBypass.Value and Options.SpeedSlider.Max ~= 7 and not Script.FakeRevive.Enabled then
        Options.SpeedSlider:SetMax(7)
    end
end)

Toggles.Fly:OnChanged(function(value)
    if not rootPart then return end

    if humanoid then
        humanoid.PlatformStand = value
    end

    Script.Temp.FlyBody.Parent = value and rootPart or nil

    if value then
        Script.Connections["Fly"] = RunService.RenderStepped:Connect(function()
            local velocity = Vector3.zero

            if controlModule then
                local moveVector = controlModule:GetMoveVector()
                velocity = -((camera.CFrame.LookVector * moveVector.Z) - (camera.CFrame.RightVector * moveVector.X))
            else
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity += camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity -= camera.CFrame.RightVector end
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity += camera.CFrame.UpVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity -= camera.CFrame.UpVector end
            
            Script.Temp.FlyBody.Velocity = velocity * Options.FlySpeed.Value
        end)
    else
        if Script.Connections["Fly"] then
            Script.Connections["Fly"]:Disconnect()
        end
    end
end)

Toggles.PromptClip:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do        
        if Script.Functions.PromptCondition(prompt) then
            if value then
                prompt.RequiresLineOfSight = false
            else
                if prompt:GetAttribute("Enabled") and prompt:GetAttribute("Clip") then
                    prompt.Enabled = prompt:GetAttribute("Enabled")
                    prompt.RequiresLineOfSight = prompt:GetAttribute("Clip")
                end
            end
        end
    end
end)

Options.PromptReachMultiplier:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if Script.Functions.PromptCondition(prompt) then
            if not prompt:GetAttribute("Distance") then prompt:SetAttribute("Distance", prompt.MaxActivationDistance) end

            prompt.MaxActivationDistance = prompt:GetAttribute("Distance") * value
        end
    end
end)

Toggles.AntiHalt:OnChanged(function(value)
    if not entityModules then return end
    local module = entityModules:FindFirstChild("Shade") or entityModules:FindFirstChild("_Shade")

    if module then
        module.Name = value and "_Shade" or "Shade"
    end
end)

Toggles.AntiScreech:OnChanged(function(value)
    if not mainGame then return end
    local module = mainGame:FindFirstChild("Screech", true) or mainGame:FindFirstChild("_Screech", true)

    if module then
        module.Name = value and "_Screech" or "Screech"
    end
end)

Toggles.AntiDupe:OnChanged(function(value)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        for _, dupeRoom in pairs(room:GetChildren()) do
            if dupeRoom:GetAttribute("LoadModule") == "DupeRoom" or dupeRoom:GetAttribute("LoadModule") == "SpaceSideroom" then
                task.spawn(function() Script.Functions.DisableDupe(dupeRoom, value, dupeRoom:GetAttribute("LoadModule") == "SpaceSideroom") end)
            end
        end
    end
end)

Toggles.AntiSnare:OnChanged(function(value)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if not room:FindFirstChild("Assets") then continue end

        for _, snare in pairs(room.Assets:GetChildren()) do
            if snare.Name == "Snare" then
                snare:WaitForChild("Hitbox", 5).CanTouch = not value
            end
        end
    end
end)

Toggles.AntiHearing:OnChanged(function(value)
    if isFools then return end
    remotesFolder.Crouch:FireServer(value)
end)

Toggles.UpsideDown:OnChanged(function(value)
    if not collision then return end
    
    -- im sorry deivid
    if value then
        local rotation = collision.Rotation
        collision.Rotation = Vector3.new(rotation.X, rotation.Y, -90)

        task.spawn(function()
            repeat task.wait() until not Toggles.UpsideDown.Value or Library.Unloaded
            
            if collision then
                rotation = collision.Rotation
    
                collision.Rotation = Vector3.new(rotation.X, rotation.Y, 90)
            end
        end)
    end
end)

function Script.Functions.SpeedBypass()
    if speedBypassing then return end
    speedBypassing = true

    task.spawn(function()
        while Toggles.SpeedBypass.Value and collisionClone and not Library.Unloaded and not Script.FakeRevive.Enabled do
            if Options.SpeedBypassMethod.Value == "Massless" then
                collisionClone.Massless = not collisionClone.Massless
            elseif Options.SpeedBypassMethod.Value == "Size" then
                collisionClone.Size = Script.Temp.CollisionSize / 2
                task.wait(Options.SpeedBypassDelay.Value)
                collisionClone.Size = Script.Temp.CollisionSize
            end

            task.wait(Options.SpeedBypassDelay.Value)
        end

        speedBypassing = false
        if collisionClone then
            collisionClone.Massless = true
            collisionClone.Size = Script.Temp.CollisionSize
        end
    end)
end

Options.SpeedBypassMethod:OnChanged(function()
    if collisionClone then
        collisionClone.Massless = true
        collisionClone.Size = Script.Temp.CollisionSize
    end
end)

Toggles.SpeedBypass:OnChanged(function(value)
    if value then
        Options.SpeedSlider:SetMax(45)
        Options.FlySpeed:SetMax(75)
        
        Script.Functions.SpeedBypass()
    else
        if Script.FakeRevive.Enabled then return end

        local speed = if bypassed then 45 elseif Toggles.EnableJump.Value then 3 else 7

        Options.SpeedSlider:SetMax(speed)
        Options.FlySpeed:SetMax((isMines and Toggles.TheMinesAnticheatBypass.Value and bypassed) and 75 or 22)
    end
end)

Toggles.FakeRevive:OnChanged(function(value)
    if value and alive and character and not Script.FakeRevive.Enabled then
        if latestRoom and latestRoom.Value == 0 then
            Script.Functions.Alert({
                Title = "Fake Revive",
                Description = "You have to open the next door to use fake revive",
                Reason = "You are in the first room"
            })
            repeat task.wait() until latestRoom.Value > 0
        end

        Script.Functions.Alert({
            Title = "Fake Revive",
            Description = "Please find a way to die or wait for around 20 seconds\nfor fake revive to work.",
            Reason = "You are not yet dead",
            Time = 20
        })
        
        local oxygenModule = mainGame:FindFirstChild("Oxygen")
        local healthModule = mainGame:FindFirstChild("Health")
        local cameraModule = mainGame:FindFirstChild("Camera")
        local inventoryModule = mainGame:FindFirstChild("Inventory")

        if oxygenModule and healthModule then
            task.delay(0.5, function()
                if not Toggles.FakeRevive.Value then return end

                oxygenModule.Enabled = false
                healthModule.Enabled = false
                inventoryModule.Enabled = false
            end)
        end

        repeat task.wait(.25)
            remotesFolder.Underwater:FireServer(true)
        until not alive or not Toggles.FakeRevive.Value

        if alive and not Toggles.FakeRevive.Value then
            remotesFolder.Underwater:FireServer(false)
            Script.Functions.Alert({
                Title = "Fake Revive",
                Description = "Fake revive has been disabled, was unable to kill player.",
                Reason = "You are not yet dead",
            })
            oxygenModule.Enabled = true
            healthModule.Enabled = true
            return
        end

        Toggles.SpeedBypass:SetValue(false)
        Options.SpeedSlider:SetMax(45)
        Options.FlySpeed:SetMax(75)

        Script.FakeRevive.Enabled = true
        workspace.Gravity = 0

        if cameraModule then
            cameraModule.Enabled = false
        end

        task.wait(0.1)
        for _, hotbarItem in pairs(mainUI.MainFrame.Hotbar:GetChildren()) do
            if not hotbarItem:IsA("TextButton") then continue end
            hotbarItem.Visible = false
        end

        local tool = Instance.new("Tool") do
            tool.RequiresHandle = false
            tool.Name = "AttachTool"
            tool.Parent = character

            humanoid.Name = "old_Humanoid"
            local newHumanoid = humanoid:Clone()
            newHumanoid.Parent = character
            newHumanoid.Name = "Humanoid"

            task.wait()

            humanoid:Destroy()
            camera.CameraSubject = character
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

            local determined_cframe = rootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
            rootPart.CFrame = determined_cframe
            
            local atempts = 0
            repeat task.wait()
                atempts = atempts + 1
                rootPart.CFrame = determined_cframe
            until (tool.Parent ~= character or not rootPart or not rootPart.Parent or atempts > 250) and atempts > 2
            tool:Destroy()
        end

        -- setup character
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "UpperTorso" and part.Name ~= "Collision" and part.Parent.Name ~= "Collision" then 
                --v.CanCollide = false
                part.Massless = true
                part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 1, 1)
            end
        end

        for _, weld in pairs(character:GetChildren()) do
            if weld:IsA("Weld") then
                weld:Destroy()
            end
        end

        camera:Destroy()
        task.wait(.1)
        workspace.CurrentCamera.CameraSubject = character:FindFirstChildWhichIsA('Humanoid')
        workspace.CurrentCamera.CameraType = "Custom"
        localPlayer.CameraMinZoomDistance = 0.5
        localPlayer.CameraMaxZoomDistance = 400
        localPlayer.CameraMode = "Classic"
        character.Head.Anchored = false
        camera = workspace.CurrentCamera

        -- setup fake char
        local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
        humanoidDescription.HeightScale = 1.2

        local previewCharacter = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15) do
            previewCharacter.Parent = Workspace
            previewCharacter.Name = "PreviewCharacter"

            previewCharacter.HumanoidRootPart.Anchored = true
            character.UpperTorso.CanCollide = false
        end

        Script.FakeRevive.Connections["HidingFix"] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if UserInputService:GetFocusedTextBox() then return end
            if gameProcessed then return end

            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
                if character:GetAttribute("Hiding") then
                    for i = 1, 50 do
                        task.wait()
                        remotesFolder.CamLock:FireServer()
                    end
                end
            end
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["HidingFix"])

        -- animation setup
        task.spawn(function()
            local anims = character:WaitForChild("Animations", 10) or previewCharacter:WaitForChild("Animations", 10);
            local crouch, oldCrouchSpeed = previewCharacter.Humanoid:LoadAnimation(anims.Crouch), 0;
            local walk, idle = previewCharacter.Humanoid:LoadAnimation(anims.Forward), previewCharacter.Humanoid:LoadAnimation(anims.Idle);
            local interact = previewCharacter.Humanoid:LoadAnimation(anims.Interact);
            oldCrouchSpeed = crouch.Speed;

            local function playWalkingAnim(key)
                repeat
                    if idle.isPlaying then idle:Stop() end

                    if character:GetAttribute("Crouching") then
                        if not crouch.isPlaying then crouch:Play() crouch:AdjustSpeed(oldCrouchSpeed) end
                        if walk.isPlaying then walk:Stop() end
                    else
                        if crouch.isPlaying then crouch:Stop() end
                        if not walk.isPlaying then walk:Play() end
                    end

                    task.wait(.5)
                until not UserInputService:IsKeyDown(key) and not UserInputService:GetFocusedTextBox()
            end

            Script.FakeRevive.Connections["AnimationHandler"] = UserInputService.InputBegan:Connect(function(input)
                if UserInputService:GetFocusedTextBox() then return end
                if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
                    playWalkingAnim(input.KeyCode)
                end
            end)

            Library:GiveSignal(Script.FakeRevive.Connections["AnimationHandler"])

            Script.FakeRevive.Connections["AnimationHandler2"] = UserInputService.InputEnded:Connect(function(input)
                if UserInputService:GetFocusedTextBox() then return end

                if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
                    task.wait(.1)
                    if walk.isPlaying then walk:Stop() end
                    if character:GetAttribute("Crouching") then 
                        if not crouch.isPlaying then crouch:Play() end
                        crouch:AdjustSpeed(0)
                    else 
                        if crouch.isPlaying then crouch:Stop() end 
                    end
                    if not idle.isPlaying then idle:Play() end
                end
            end)

            Library:GiveSignal(Script.FakeRevive.Connections["AnimationHandler2"])

            -- Tool Handler (kinda broken) --
            if character:WaitForChild("RightHand", math.huge) then
                local rightGrip = Instance.new("Weld", character.RightHand)
                rightGrip.C0 = CFrame.new(0, -0.15, -1.5, 1, 0, -0, 0, 0, 1, 0, -1, 0)
                rightGrip.Part0 = character.RightHand
        
                local toolsAnim = {}
                local currentTool = nil
                local doorInteractables = { "Key", "Lockpick" }

                Script.FakeRevive.Connections["ToolAnimHandler"] = character.ChildAdded:Connect(function(tool)
                    if tool:IsA("Tool") then
                        for _, anim in pairs(toolsAnim) do
                            anim:Stop()
                        end
        
                        table.clear(toolsAnim)
        
                        local anims = tool:WaitForChild("Animations")
                        currentTool = tool
        
                        for i, v in pairs(anims:GetChildren()) do
                            if v:IsA("Animation") then
                                toolsAnim[v.Name] = previewCharacter.Humanoid:LoadAnimation(v)
                            end
                        end
        
                        if toolsAnim.idle then toolsAnim.idle:Play(0.4, 1, 1) end
                        if toolsAnim.equip then toolsAnim.equip:Play(0.05, 1, 1) end
        
                        local toolHandle = tool:WaitForChild("Handle", 3)
                        if toolHandle and character:FindFirstChild("RightHand") then
                            rightGrip.Parent = character.RightHand
                            rightGrip.C1 = tool.Grip
                            rightGrip.Part1 = toolHandle        
                        end
        
                        local animation_state = false
                        tool.Activated:Connect(function()
                            if table.find(doorInteractables, tool.Name) then return end
        
                            local anim = toolsAnim.use or (tool:GetAttribute("LightSource") and toolsAnim.open)
        
                            if anim then
                                if ExecutorSupport["require"] then require(tool.ToolModule).fire() end
                                local toolRemote = tool:FindFirstChild("Remote")
                                if toolRemote then
                                    toolRemote:FireServer()
                                end

                                if tool:GetAttribute("LightSource") then
                                    if animation_state then
                                        anim:Stop()
                                    else
                                        anim:Play()
                                    end
                                    
                                    animation_state = not animation_state
                                    return
                                end
        
                                anim:Play()
                            end
                        end)
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimHandler"])
        
                -- Prompts handler
                local holding, holdStart, startDurability = false, 0, 0
                Script.FakeRevive.Connections["ToolAnimHandler2"] = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                    if (currentTool and table.find(doorInteractables, currentTool.Name)) and (prompt.Name == "UnlockPrompt" and prompt.Parent.Name == "Lock") then
                        holding = true; holdStart = tick(); startDurability = currentTool:GetAttribute("Durability")
                        
                        toolsAnim.use:Play()
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimHandler2"])

                Script.FakeRevive.Connections["ToolAnimInteractHandler"] = ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
                    if (currentTool and table.find(doorInteractables, currentTool.Name)) and (prompt.Name == "UnlockPrompt" and prompt.Parent.Name == "Lock") then
                        if holdStart == 0 then return end
        
                        if startDurability and currentTool:GetAttribute("Durability") < startDurability then
                            toolsAnim.use:Stop()
                            toolsAnim.usebreak:Play()
        
                            return
                        end
                        
                        if holding and tick() - holdStart > prompt.HoldDuration then
                            holding = false; holdStart = 0
        
                            toolsAnim.use:Stop()
                            toolsAnim.usefinish:Play()
                            
                            return
                        end
        
                        holding = false; holdStart = 0
        
                        toolsAnim.use:Stop()
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimInteractHandler"])
                
                Script.FakeRevive.Connections["ToolAnimUnequipHandler"] = character.ChildRemoved:Connect(function(v)
                    if v:IsA("Tool") then
                        rightGrip.Part1 = nil
                        rightGrip.C1 = CFrame.new()
                        rightGrip.Parent = nil
        
                        for _, anim in pairs(toolsAnim) do
                            anim:Stop()
                        end
        
                        currentTool = nil
                    end
                end)

                Library:GiveSignal(Script.FakeRevive.Connections["ToolAnimUnequipHandler"])
            end
        end)

        -- movement code
        local function generateCharacterCFrame(obj)
            local obj_pos = obj.Position
            return CFrame.new(obj_pos, obj_pos - (Vector3.new(camera.CFrame.Position.X, obj_pos.Y, camera.CFrame.Position.Z) - obj_pos).unit)
        end

        local function usePreviewCharacter(doStepped)
            -- fuck you roblox for using head instead of primarypart or char:GetPivot() 
            -- mstudio45 2023 ^^
            if ExecutorSupport["hookmetamethod"] and ExecutorSupport["getnamecallmethod"] then
                _fixDistanceFromCharacter = hookmetamethod(localPlayer, "__namecall", function(self, ...)
                    local method = getnamecallmethod();
                    local args = {...}
                
                    if method == "DistanceFromCharacter" then
                        if typeof(args[1]) == "Vector3" then
                            return Script.Functions.DistanceFromCharacter(args[1])
                        end
                        
                        return 9999;
                    end
                
                    return _fixDistanceFromCharacter(self, ...)
                end)
            end

            if doStepped ~= false then
                Library:Notify("You are not longer visible to others because you have lost Network Ownership of your character.", 5);

                for _,v in pairs(previewCharacter:GetDescendants()) do
                    if v:IsA("BasePart") then 
                        v.CanCollide = false
                    end
                end

                for _, connection in pairs(Script.FakeRevive.Connections) do
                    connection:Disconnect()
                end
                
                table.clear(Script.FakeRevive.Connections)
            end

            if previewCharacter:FindFirstChild("Humanoid") then previewCharacter.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
            
            Toggles.Fly:SetValue(true)

            Library:GiveSignal(RunService.RenderStepped:Connect(function()
                if doStepped ~= false then previewCharacter:PivotTo(generateCharacterCFrame(character:GetPivot())) end
                if rootPart then 
                    rootPart.Transparency = (doStepped ~= false) and 1 or 0
                    rootPart.CanCollide = false
                end
            end))
        end

        if character:FindFirstChild("LeftFoot") then character.LeftFoot.CanCollide = true end
        if character:FindFirstChild("RightFoot") then character.RightFoot.CanCollide = true end
        
        Script.FakeRevive.Connections["mainStepped"] = RunService.RenderStepped:Connect(function()
            -- deivid gonna get mad at this line :content:
            if character:FindFirstChild("Humanoid") then character.Humanoid.WalkSpeed = 15 + Options.SpeedSlider.Value end
            

            if rootPart and rootPart.Position.Y < -150 then
                rootPart.Position = workspace.SpawnLocation.Position
            end

            if character:FindFirstChild("UpperTorso") then
                character.UpperTorso.CanCollide = false 
            else
                if character:FindFirstChild("HumanoidRootPart") then 
                    local totalParts = 0
                    for _, v in pairs(character:GetChildren()) do if v:IsA("BasePart") then totalParts = totalParts + 1 end end
                    if totalParts <= 2 then
                        task.spawn(usePreviewCharacter)
                        Script.FakeRevive.Connections["mainStepped"]:Disconnect()

                        for _, connection in pairs(Script.FakeRevive.Connections) do
                            connection:Disconnect()
                        end
                        
                        table.clear(Script.FakeRevive.Connections)
                        return
                    end
                end
            end

            if not character:FindFirstChild("HumanoidRootPart") then
                Library:Notify("You have completely lost Network Ownership of your character which resulted of breaking Fake Death.", 5);
                task.spawn(usePreviewCharacter, false)
                Script.FakeRevive.Connections["mainStepped"]:Disconnect()

                for _, connection in pairs(Script.FakeRevive.Connections) do
                    connection:Disconnect()
                end
                
                table.clear(Script.FakeRevive.Connections)
                return
            end
            
            previewCharacter:PivotTo(generateCharacterCFrame(rootPart.CFrame * CFrame.new(0,1000,0)))

            local charPartCFrames = {}
            for _, part in ipairs(previewCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    charPartCFrames[part.Name..part.ClassName] = part.CFrame
                end
            end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "RagdollCollision" then
                        part.CFrame = (charPartCFrames[part.Parent.Name .. part.Parent.ClassName] - Vector3.new(0,1000,0))
                        part.CanCollide = true
                    else
                        if charPartCFrames[part.Name..part.ClassName] then
                            part.CFrame = (charPartCFrames[part.Name..part.ClassName] - Vector3.new(0,1000,0))
                        end
                    end
                    
                    if part.Name ~= "HumanoidRootPart" then
                        if part.Parent == character or part.Parent:IsA("Accessory") then
                            part.LocalTransparencyModifier = 0
                        end

                        part.AssemblyAngularVelocity = Vector3.zero
                        part.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["mainStepped"])

        task.wait(0.1)
        local function fixUI()
            local setComponentVisibility = {
                mainUI.HodlerRevive,
                mainUI.Statistics,
                
                mainUI.DeathPanelDead,
                mainUI.DeathPanel,

                mainUI.MainFrame.Healthbar,

                ["visible_real"] = mainUI.MainFrame.PromptFrame.CenterImage,
                ["deivid_ballers_fake"] = mainUI.MainFrame.PromptFrame.Holder,

                mainUI.MainFrame.Hotbar,
                mainUI.MainFrame.InventoryCap,
                mainUI.MainFrame.InventoryLeftArrow,
                mainUI.MainFrame.InventoryRightArrow,
            }

            for i,v in pairs(setComponentVisibility) do
                local target_visibility = (typeof(i) == "string" and true or false)

                v:GetPropertyChangedSignal("Visible"):Connect(function()
                    v.Visible = target_visibility
                end)

                v.Visible = target_visibility
            end

            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        end

        task.spawn(fixUI)

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseIcon = "rbxassetid://2833720882"

        task.wait()
        character.HumanoidRootPart.Anchored = false

        if mainGameSrc then mainGameSrc.dead = false end
        
        ProximityPromptService.Enabled = true
        Script.FakeRevive.Connections["ProximityPromptEnabler"] = ProximityPromptService:GetPropertyChangedSignal("Enabled"):Connect(function()
            ProximityPromptService.Enabled = true
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["ProximityPromptEnabler"])

        workspace.Gravity = 90

        -- ESP Fix :smartindividual:
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            task.spawn(function()
                local roomDetectPart = room:WaitForChild(room.Name, math.huge)
                if roomDetectPart then
                    roomDetectPart.Size = Vector3.new(roomDetectPart.Size.X, roomDetectPart.Size.Y * 250, roomDetectPart.Size.Z)

                    local touchEvent = roomDetectPart.Touched:Connect(function(hit)
                        if hit.Parent == localPlayer.Character and not Script.FakeRevive.Debounce then
                            Script.FakeRevive.Debounce = true
                            localPlayer:SetAttribute("CurrentRoom", tonumber(room.Name))
                            
                            task.wait(0.075)
                            Script.FakeRevive.Debounce = false
                        end
                    end)
                    
                    table.insert(Script.FakeRevive.Connections, touchEvent)
                    Library:GiveSignal(touchEvent)
                end
            end)
        end

        Script.FakeRevive.Connections["CurrentRoomFix"] = workspace.CurrentRooms.ChildAdded:Connect(function(room)
            local roomDetectPart = room:WaitForChild(room.Name, math.huge)

            if roomDetectPart then
                roomDetectPart.Size = Vector3.new(roomDetectPart.Size.X, roomDetectPart.Size.Y * 100, roomDetectPart.Size.Z)

                local touchEvent = roomDetectPart.Touched:Connect(function(hit)
                    if hit.Parent == localPlayer.Character and not Script.FakeRevive.Debounce then
                        Script.FakeRevive.Debounce = true
                        localPlayer:SetAttribute("CurrentRoom", tonumber(room.Name))

                        task.wait(0.075)
                        Script.FakeRevive.Debounce = false
                    end
                end)
                
                table.insert(Script.FakeRevive.Connections, touchEvent)
                Library:GiveSignal(touchEvent)
            end
        end)

        Library:GiveSignal(Script.FakeRevive.Connections["CurrentRoomFix"])

        Script.Functions.Alert({
            Title = "Fake Revive",
            Description = "Fake Revive is now initialized, have fun!",
            Reason = 'You are now "dead"',
        })
    end
end)

Toggles.DoorESP:OnChanged(function(value)
    if value then
        if workspace.CurrentRooms[currentRoom]:FindFirstChild("Door") then
            Script.Functions.DoorESP(workspace.CurrentRooms[currentRoom])
        end

        if workspace.CurrentRooms[nextRoom]:FindFirstChild("Door") then
            Script.Functions.DoorESP(workspace.CurrentRooms[nextRoom])
        end
    else
        for _, connection in pairs(Script.FeatureConnections.Door) do
            connection:Disconnect()
        end

        for _, esp in pairs(Script.ESPTable.Door) do
            esp.Destroy()
        end
    end
end)

Options.DoorEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Door) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ObjectiveESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, asset in pairs(currentRoomModel:GetDescendants()) do
                task.spawn(Script.Functions.ObjectiveESP, asset)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Objective) do
            esp.Destroy()
        end
    end
end)

Options.ObjectiveEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Objective) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.EntityESP:OnChanged(function(value)
    if value then
        for _, entity in pairs(workspace:GetChildren()) do
            if table.find(EntityTable.Names, entity.Name) then
                Script.Functions.EntityESP(entity)
            end
        end

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, entity in pairs(currentRoomModel:GetDescendants()) do
                if table.find(EntityTable.SideNames, entity.Name) then
                    Script.Functions.SideEntityESP(entity)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Entity) do
            esp.Destroy()
        end
        for _, esp in pairs(Script.ESPTable.SideEntity) do
            esp.Destroy()
        end
    end
end)

Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ItemESP:OnChanged(function(value)
    if value then
        for _, item in pairs(workspace.Drops:GetChildren()) do
            if Script.Functions.ItemCondition(item) then
                Script.Functions.ItemESP(item, true)
            end
        end

        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, item in pairs(currentRoomModel:GetDescendants()) do
                if Script.Functions.ItemCondition(item) then
                    Script.Functions.ItemESP(item)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.DroppedItem) do
            esp.Destroy()
        end

        for _, esp in pairs(Script.ESPTable.Item) do
            esp.Destroy()
        end
    end
end)

Options.ItemEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.DroppedItem) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end

    for _, esp in pairs(Script.ESPTable.Item) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ChestESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, chest in pairs(currentRoomModel:GetDescendants()) do
                if chest:GetAttribute("Storage") == "ChestBox" or chest.Name == "Toolshed_Small" then
                    Script.Functions.ChestESP(chest)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Chest) do
            esp.Destroy()
        end
    end
end)

Options.ChestEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Chest) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.PlayerESP:OnChanged(function(value)
    if value then
        for _, player in pairs(Players:GetPlayers()) do
            if player == localPlayer or not player.Character then continue end
            
            Script.Functions.PlayerESP(player)
        end
    else
        for _, connection in pairs(Script.FeatureConnections.Player) do
            connection:Disconnect()
        end
        for _, esp in pairs(Script.ESPTable.Player) do
            esp.Destroy()
        end
    end
end)

Options.PlayerEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Player) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.HidingSpotESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, wardrobe in pairs(currentRoomModel:GetDescendants()) do
                if wardrobe:GetAttribute("LoadModule") == "Wardrobe" or wardrobe:GetAttribute("LoadModule") == "Bed" or wardrobe.Name == "Rooms_Locker" or wardrobe.Name == "RetroWardrobe" then
                    Script.Functions.HidingSpotESP(wardrobe)
                end
            end
        end 
    else
        for _, esp in pairs(Script.ESPTable.HidingSpot) do
            esp.Destroy()
        end
    end
end)

Options.HidingSpotEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.HidingSpot) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.GoldESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, gold in pairs(currentRoomModel:GetDescendants()) do
                if gold.Name == "GoldPile" then
                    Script.Functions.GoldESP(gold)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Gold) do
            esp.Destroy()
        end
    end
end)

Options.GoldEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Gold) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.GuidingLightESP:OnChanged(function(value)
    if value then
        for _, guidance in pairs(camera:GetChildren()) do
            if guidance:IsA("BasePart") and guidance.Name == "Guidance" then
                Script.Functions.GuidingLightEsp(guidance)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Guiding) do
            esp.Destroy()
        end
    end
end)

Options.GuidingLightEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Guiding) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.ESPHighlight:OnChanged(function(value)
    warn("changing highlight to", value)

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.SetVisible(value, false)
        end
    end
end)

Toggles.ESPTracer:OnChanged(function(value)
    ESPLibrary.Tracers.Set(value)
end)

Toggles.ESPRainbow:OnChanged(function(value)
    ESPLibrary.Rainbow.Set(value)
end)

Toggles.ESPDistance:OnChanged(function(value)
    ESPLibrary.Distance.Set(value)
end)

Toggles.ESPShowEntityText:OnChanged(function(value)
    ESPLibrary.Text.Set(value)
end)

Options.EntityLanguage:OnChanged(function(value)
    EntityLanguage.Set(value)
    EntityLanguage.Relabel()
end)

Options.InfItemsFilter:OnChanged(function(value)
    ItemFilter.Set(value)
end)

Options.ESPTracerThickness:OnChanged(function(value)
    ESPLibrary.Thickness.Set(value)
end)

Options.EntityESPFilter:OnChanged(function(selection)
    EntityESPFilter.Set(selection)
    -- Narrowing the filter has to take effect on what is already on screen, not on
    -- the next spawn: clear the entity ESPs and re-decide every entity in the world.
    for _, esp in pairs(Script.ESPTable.Entity or {}) do
        Safe(function() esp.Destroy() end)
    end
    Script.ESPTable.Entity = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if table.find(EntityTable.Names, model.Name) then
            Safe(function() Script.Functions.EntityESP(model) end)
        end
    end

end)

Options.ESPFillTransparency:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ FillTransparency = value })
        end
    end
end)

Options.ESPOutlineTransparency:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ OutlineTransparency = value })
        end
    end
end)

Options.ESPTextSize:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ TextSize = value })
        end
    end
end)

Options.ESPTracerStart:OnChanged(function(value)
    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Update({ Tracer = { From = value } })
        end
    end
end)

Options.Brightness:OnChanged(function(value)
    Lighting.Brightness = value
end)

Toggles.Fullbright:OnChanged(function(value)
    if value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        if alive then
            Lighting.Ambient = workspace.CurrentRooms[localPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
end)

Toggles.NoFog:OnChanged(function(value)
    if not Lighting:GetAttribute("FogStart") then Lighting:SetAttribute("FogStart", Lighting.FogStart) end
    if not Lighting:GetAttribute("FogEnd") then Lighting:SetAttribute("FogEnd", Lighting.FogEnd) end

    Lighting.FogStart = value and 0 or Lighting:GetAttribute("FogStart")
    Lighting.FogEnd = value and math.huge or Lighting:GetAttribute("FogEnd")

    local fog = Lighting:FindFirstChildOfClass("Atmosphere")
    if fog then
        if not fog:GetAttribute("Density") then fog:SetAttribute("Density", fog.Density) end

        fog.Density = value and 0 or fog:GetAttribute("Density")
    end
end)

Toggles.AntiLag:OnChanged(function(value)
    for _, object in pairs(workspace.CurrentRooms:GetDescendants()) do
        if object:IsA("BasePart") then
            if not object:GetAttribute("Material") then object:SetAttribute("Material", object.Material) end
            if not object:GetAttribute("Reflectance") then object:SetAttribute("Reflectance", object.Reflectance) end

            object.Material = value and Enum.Material.Plastic or object:GetAttribute("Material")
            object.Reflectance = value and 0 or object:GetAttribute("Reflectance")
        elseif object:IsA("Decal") then
            if not object:GetAttribute("Transparency") then object:SetAttribute("Transparency", object.Transparency) end

            if not table.find(SlotsName, object.Name) then
                object.Transparency = value and 1 or object:GetAttribute("Transparency")
            end
        end
    end

    workspace.Terrain.WaterReflectance = value and 0 or 1
    workspace.Terrain.WaterTransparency = value and 0 or 1
    workspace.Terrain.WaterWaveSize = value and 0 or 0.05
    workspace.Terrain.WaterWaveSpeed = value and 0 or 8
    Lighting.GlobalShadows = not value
end)

Options.NotifySide:OnChanged(function(value)
    Library.NotifySide = value
end)

Toggles.NoCutscenes:OnChanged(function(value)
    if mainGame then
        local cutscenes = mainGame:FindFirstChild("Cutscenes", true)
        if cutscenes then
            for _, cutscene in pairs(cutscenes:GetChildren()) do
                if table.find(CutsceneExclude, cutscene.Name) then continue end
    
                local defaultName = cutscene.Name:gsub("_", "")
                cutscene.Name = value and "_" .. defaultName or defaultName
            end
        end
    end

    if floorReplicated then
        for _, cutscene in pairs(floorReplicated:GetChildren()) do
            if not cutscene:IsA("ModuleScript") or table.find(CutsceneExclude, cutscene.Name) then continue end

            local defaultName = cutscene.Name:gsub("_", "")
            cutscene.Name = value and "_" .. defaultName or defaultName
        end
    end
end)

Toggles.TranslucentHidingSpot:OnChanged(function(value)
    if value and character:GetAttribute("Hiding") then
        for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
            if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end

            if obj.Value == character then
                task.spawn(function()
                    local affectedParts = {}
                    for _, v in pairs(obj.Parent:GetChildren()) do
                        if not v:IsA("BasePart") then continue end

                        v.Transparency = Options.HidingTransparency.Value
                        table.insert(affectedParts, v)
                    end

                    repeat task.wait()
                        for _, part in pairs(affectedParts) do
                            task.wait()
                            part.Transparency = Options.HidingTransparency.Value
                        end
                    until not character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                    
                    for _, v in pairs(affectedParts) do
                        v.Transparency = 0
                    end
                end)

                break
            end
        end
    end
end)

--// Connections \\--

if ExecutorSupport["hookmetamethod"] and ExecutorSupport["getnamecallmethod"] then
    mtHook = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local namecallMethod = getnamecallmethod()
    
        if namecallMethod == "FireServer" then
            if self.Name == "ClutchHeartbeat" and Toggles.AutoHeartbeat.Value then
                return
            elseif self.Name == "Crouch" and Toggles.AntiHearing.Value then
                args[1] = true
                return mtHook(self, unpack(args))
            end
        elseif namecallMethod == "Destroy" and self.Name == "RunnerNodes" then
            return
        end
    
        return mtHook(self, ...)
    end)
end

if isBackdoor then
    local clientRemote = floorReplicated.ClientRemote
    local haste_incoming_progress = nil

    Library:GiveSignal(clientRemote.Haste.Remote.OnClientEvent:Connect(function(value)
        if not value and Toggles.NotifyEntity.Value then
            haste_incoming_progress = Instance.new("Part", Workspace) do
                haste_incoming_progress.Anchored = true
                haste_incoming_progress.CanCollide = false
                haste_incoming_progress.Name = "_internal_lonelyhub_haste"
                haste_incoming_progress.Transparency = 1
            end

            Script.Functions.Alert({
                Title = "ENTITIES",
                Description = "Haste is incoming, please find a lever ASAP!",
                Time = haste_incoming_progress,

                Warning = true
            })

            repeat task.wait() until not haste_incoming_progress or not Toggles.NotifyEntity.Value or not character:GetAttribute("Alive")
            if haste_incoming_progress then haste_incoming_progress:Destroy() end
        end
        
        if value and haste_incoming_progress then
            haste_incoming_progress:Destroy()
        end
    end))
end

Library:GiveSignal(remotesFolder.HideMonster.OnClientEvent:Connect(function()
    if isBackdoor or isRooms or isRetro then return end

    local hideTime = Script.Functions.CalculateHideTime(currentRoom) or math.huge
    local finalTime = tick() + math.round(hideTime)

    if Toggles.NotifyHideTime.Value and hideTime ~= math.huge then
        while character:GetAttribute("Hiding") and alive and not Library.Unloaded and Toggles.NotifyHideTime.Value do
            local remainingTime = math.max(0, finalTime - tick())

            if ExecutorSupport["firesignal"] then
                firesignal(remotesFolder.Caption.OnClientEvent, string.format("%.1f", remainingTime))
            else
                Script.Functions.Captions(string.format("%.1f", remainingTime))
            end

            task.wait()
        end
    end
end))

Library:GiveSignal(ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player ~= localPlayer or not character or isFools then return end
    
    local isDoorLock = prompt.Name == "UnlockPrompt" and prompt.Parent.Name == "Lock" and not prompt.Parent.Parent:GetAttribute("Opened")
    local isSkeletonDoor = prompt.Name == "SkullPrompt" and prompt.Parent.Name == "SkullLock" and not (prompt.Parent:FindFirstChild("Door") and prompt.Parent.Door.Transparency == 1)
    local isChestBox = prompt.Name == "ActivateEventPrompt" and prompt.Parent.Name == "ChestBoxLocked" and prompt.Parent:GetAttribute("Locked")
    local isRoomsDoorLock = prompt.Parent.Parent.Parent.Name == "RoomsDoor_Entrance" and prompt.Enabled
    
    if isDoorLock or isSkeletonDoor or isChestBox or isRoomsDoorLock then
        local equippedTool = character:FindFirstChildOfClass("Tool")
        local toolId = equippedTool and equippedTool:GetAttribute("ID")

        if Toggles.InfItems.Value and equippedTool and equippedTool:GetAttribute("UniversalKey")
            and ItemFilter.Allows(equippedTool) then
            task.wait(isChestBox and 0.05 or 0)
            remotesFolder.DropItem:FireServer(equippedTool)

            task.spawn(function()
                equippedTool.Destroying:Wait() 
                task.wait(0.15)

                local itemPickupPrompt = Script.Functions.GetNearestPromptWithCondition(function(prompt)
                    return prompt.Name == "ModulePrompt" and prompt.Parent:GetAttribute("Tool_ID") == toolId
                end)

                if itemPickupPrompt then
                    firePrompt(itemPickupPrompt)
                end
            end)
        end
    end
end))

-- Entity metadata. NotifyReason only carries the entities the upstream hub shipped
-- artwork for; every other name in EntityTable.Names indexed nil. That throw happened
-- inside the spawn handler, so the alert died and took the ESP, the avoid logic and
-- the auto-wardrobe checks below it with it -- the whole reaction to a spawn was gone.
local function entityMeta(name)
    return EntityTable.NotifyReason[name] or {}
end

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        local shortName = Script.Functions.GetShortName(child.Name)

        if table.find(EntityTable.Names, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 750 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    if isHotel and Toggles.AvoidRushAmbush.Value and table.find(EntityTable.Avoid, child.Name) then
                        local oldNoclip = Toggles.Noclip.Value
                        local distance = Script.Functions.DistanceFromCharacter(child)

                        task.spawn(function()
                            repeat 
                                RunService.Heartbeat:Wait()
                                distance = Script.Functions.DistanceFromCharacter(child)
                            until distance <= 150 or not child:IsDescendantOf(workspace)

                            if child:IsDescendantOf(workspace) then
                                Script.Functions.AvoidEntity(true)
                                repeat task.wait() until not child:IsDescendantOf(workspace)
                                Script.Functions.AvoidEntity(false, oldNoclip)
                            end
                        end)
                    end

                    if table.find(EntityTable.AutoWardrobe.Entities, child.Name) then
                        local distance = EntityTable.AutoWardrobe.Distance[child.Name].Loader

                        task.spawn(function()
                            repeat RunService.Heartbeat:Wait() until not child:IsDescendantOf(workspace) or Script.Functions.DistanceFromCharacter(child) <= distance

                            if child:IsDescendantOf(workspace) and Toggles.AutoWardrobe.Value then
                                Script.Functions.AutoWardrobe(child)
                            end
                        end)
                    end
                    
                    if isFools and child.Name == "RushMoving" then
                        shortName = child.PrimaryPart.Name:gsub("New", "")
                    end

                    if Toggles.EntityESP.Value then
                        Script.Functions.EntityESP(child)  
                    end

                    if Options.NotifyEntity.Value[shortName] then
                        Script.Functions.Alert({
                            Title = "ENTITIES",
                            Description = shortName .. " has spawned!",
                            Reason = (not entityMeta(child.Name).Spawned and "Go find a hiding place!" or nil),
                            Image = entityMeta(child.Name).Image,

                            Warning = true
                        })

                        if Toggles.NotifyChat.Value then
                            RBXGeneral:SendAsync(shortName .. " has spawned!")
                        end
                    end
                end
            end)
        elseif EntityTable.NotifyMessage[child.Name] and Options.NotifyEntity.Value[shortName] then
            Script.Functions.Alert({
                Title = "ENTITIES",
                Description = shortName .. " has spawned!",
                Reason = (not entityMeta(child.Name).Spawned and "Go find a hiding place!" or nil),
                Image = entityMeta(child.Name).Image,

                Warning = true
            })

            if Toggles.NotifyChat.Value then
                RBXGeneral:SendAsync(EntityTable.NotifyMessage[child.Name])     
            end
        end

        if isFools then
            if Toggles.AntiBananaPeel.Value and child.Name == "BananaPeel" then
                child.CanTouch = false
            end

            if Toggles.AntiJeffClient.Value and child.Name == "JeffTheKiller" then
                for i, v in pairs(child:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = false
                    end
                end
            end

            if Toggles.AntiJeffServer.Value and child.Name == "JeffTheKiller" then
                task.spawn(function()
                    repeat task.wait() until isnetowner(child.PrimaryPart)
                    child:FindFirstChildOfClass("Humanoid").Health = 0
                end)
            end
        end

        if (child.Name == "RushMoving" or child.Name == "AmbushMoving") and Toggles.InfCrucifix.Value and alive and character then
            task.wait(1.5)
            
            local hasStoppedMoving = false --entity has stoped
            local lastPosition = child:GetPivot().Position
            local lastVelocity = Vector3.new(0, 0, 0)

            local frameCount = 0
            local nextTimer = tick()
            local maxSavedFrames = 10 --after that we can ignore velocity by 0
            local currentSavedFrames = 0
            local physicsTickRate = (1 / 60) * 0.90 --usually is stable also wtf roblox why 60 Hz isn't (1 / 60) ????

            local oldFrameHz = 0
            local frameHz = 0
            local frameRate = 1 -- in seconds
            local nextTimerHz = tick()

            local entityName = child.Name

            local crucifixConnection; crucifixConnection = RunService.RenderStepped:Connect(function(deltaTime)
                if not Toggles.InfCrucifix.Value or not alive or not character then crucifixConnection:Disconnect() return end

                local currentTimer = tick()
                frameCount += 1 
                frameHz += 1

                -- get the client FPS
                if currentTimer - nextTimerHz >= frameRate then
                    oldFrameHz = frameHz;
                    frameHz = 0
                    nextTimerHz = currentTimer
                    physicsTickRate = (1 / oldFrameHz) * 0.90
                end

                -- refresh rate (client) must be equal to the physics rate (server) for making the calculations properly.
                if physicsTickRate == 0 or not (currentTimer - nextTimer >= physicsTickRate) then
                    return
                end

                frameCount = 0
                nextTimer = currentTimer
            
                local currentPosition = child:GetPivot().Position
                -- Calculate velocity
                local velocity = (currentPosition - lastPosition) / deltaTime
                velocity = Vector3.new(velocity.X, 0, velocity.Z) -- Ignore Y
            
                -- Smooth velocity
                local smoothedVelocity = lastVelocity:Lerp(velocity, 0.3) --we do math stuff
                local entityVelocity = math.floor(smoothedVelocity.Magnitude)
            
                lastVelocity = smoothedVelocity
                lastPosition = currentPosition
            
            
                local inView = Script.Functions.IsInViewOfPlayer(child, EntityTable.InfCrucifixVelocity[entityName].minDistance)
                local distanceFromPlayer = (child:GetPivot().Position - character:GetPivot().Position).Magnitude
                local isInRangeOfPlayer = distanceFromPlayer <= EntityTable.InfCrucifixVelocity[entityName].minDistance
                --[[if currentSavedFrames < maxSavedFrames then
                    print(string.format("[In range: %s | In view: %s] [Hz: %d] - Entity velocity is: %.2f | Distance: %.2f | Delta: %.2f", tostring(isInRangeOfPlayer), tostring(inView), oldFrameHz, entityVelocity, distanceFromPlayer, 0))
                end]]
            
                if entityVelocity <= EntityTable.InfCrucifixVelocity[entityName].threshold then
                    if entityVelocity <= 0.5 and currentSavedFrames <= maxSavedFrames then
                        currentSavedFrames += 1
                    end
            
                    --switch and trigger a print
                    if not hasStoppedMoving then
                        --print("Entity has stopped moving!")
                        hasStoppedMoving = true
                    end
            
                    -- --ignore if raycast is false
                    if not inView then
                        return
                    end
            
                    --ignore if distance is greater than X
                    if not isInRangeOfPlayer then
                        return
                    end

                    if character:FindFirstChild("Crucifix") then
                        workspace.Drops.ChildAdded:Once(function(droppedItem)
                            if droppedItem.Name == "Crucifix" then
                                local targetProximityPrompt = droppedItem:WaitForChild("ModulePrompt", 3) or droppedItem:FindFirstChildOfClass("ProximityPrompt")
                                repeat task.wait()
                                    firePrompt(targetProximityPrompt)
                                until not droppedItem:IsDescendantOf(workspace)
                            end
                        end)

                        remotesFolder.DropItem:FireServer(character.Crucifix);
                    end

                    return
                end

                currentSavedFrames = 0
                if hasStoppedMoving then
                    --print("Entity started moving!")
                    hasStoppedMoving = false
                end
            end)
            
            local childRemovedConnection; childRemovedConnection = workspace.ChildRemoved:Connect(function(model: Model)
                if model ~= child then return end

                crucifixConnection:Disconnect()
                childRemovedConnection:Disconnect()
            end)

            Library:GiveSignal(crucifixConnection)
            Library:GiveSignal(childRemovedConnection)
        end

    end)
end))

for _, drop in pairs(workspace.Drops:GetChildren()) do
    task.spawn(Script.Functions.SetupDropConnection, drop)
end
Library:GiveSignal(workspace.Drops.ChildAdded:Connect(function(child)
    task.spawn(Script.Functions.SetupDropConnection, child)
end))

for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
    task.spawn(Script.Functions.SetupRoomConnection, room)
end
Library:GiveSignal(workspace.CurrentRooms.ChildAdded:Connect(function(room)
    task.spawn(Script.Functions.SetupRoomConnection, room)
    
    if isMines then
        task.spawn(Script.Functions.Minecart.Pathfind, room, tonumber(room.Name))
    end
end))


if camera then task.spawn(Script.Functions.SetupCameraConnection, camera) end
Library:GiveSignal(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        camera = workspace.CurrentCamera
        task.spawn(Script.Functions.SetupCameraConnection, camera)
    end
end))

for _, player in pairs(Players:GetPlayers()) do
    if player == localPlayer then continue end
    Script.Functions.SetupOtherPlayerConnection(player)
end
Library:GiveSignal(Players.PlayerAdded:Connect(function(player)
    if player == localPlayer then return end
    Script.Functions.SetupOtherPlayerConnection(player)
end))

Library:GiveSignal(localPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
    if Script.FakeRevive.Enabled then
        Script.FakeRevive.Enabled = false

        for _, connection in pairs(Script.FakeRevive.Connections) do
            connection:Disconnect()
        end
        
        table.clear(Script.FakeRevive.Connections)

        if Toggles.FakeRevive.Value then
            Script.Functions.Alert({
                Title = "Fake Revive",
                Description = "You have revived, fake revive has stopped working.",
                Reason = "Enable it again to start fake revive",

                LinoriaMessage = "Fake Revive has stopped working, enable it again to start fake revive",
            })
            Toggles.FakeRevive:SetValue(false)
        end

        if isMines and Toggles.EnableJump.Value then
            Options.SpeedSlider:SetMax((Toggles.TheMinesAnticheatBypass.Value and bypassed) and 45 or 3)
        else
            Options.SpeedSlider:SetMax((isMines and Toggles.TheMinesAnticheatBypass.Value and bypassed) and 45 or 7)
        end

        Options.FlySpeed:SetMax((isMines and Toggles.TheMinesAnticheatBypass.Value and bypassed) and 75 or 22)
    end
end))

Library:GiveSignal(localPlayer.OnTeleport:Connect(function(state)
    if (state == Enum.TeleportState.RequestedFromServer or state == Enum.TeleportState.Started) and Toggles.ExecuteOnTeleport.Value and not getgenv().queued_to_teleport then
        getgenv().queued_to_teleport = true
        queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Lonely_Hub_Doors/Doors/main/main.lua"))()]])
    end
end))

Library:GiveSignal(localPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    alive = localPlayer:GetAttribute("Alive")

    if not alive and isFools and Toggles.InfRevives.Value then
        task.delay(1.25, function()
            remotesFolder.Revive:FireServer()
        end)
    end
end))

if workspace.CurrentRooms:FindFirstChild(currentRoom) then
    task.spawn(Script.Functions.SetupCurrentRoomConnection, workspace.CurrentRooms[currentRoom])
end
Library:GiveSignal(localPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    currentRoom = localPlayer:GetAttribute("CurrentRoom")
    nextRoom = currentRoom + 1
    task.spawn(Script.Functions.UpdateRPC)

    local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
    local nextRoomModel = workspace.CurrentRooms:FindFirstChild(nextRoom)

    if isMines and bypassed and currentRoomModel:GetAttribute("RawName") == "HaltHallway" then
        bypassed = false
        Script.Functions.Alert({
            Title = "Anticheat Bypass",
            Description = "Halt has broken anticheat bypass.",
            Reason = "Please go on a ladder again to fix it.",

            LinoriaMessage = "Halt has broken anticheat bypass, please go on a ladder again to fix it.",
        })

        Options.SpeedSlider:SetMax(Toggles.SpeedBypass.Value and 45 or (Toggles.EnableJump.Value and 3 or 7))
        Options.FlySpeed:SetMax(Toggles.SpeedBypass.Value and 75 or 22)
    end

    if Toggles.DoorESP.Value then
        for _, doorEsp in pairs(Script.ESPTable.Door) do
            doorEsp.Destroy()
        end

        if currentRoomModel then
            task.spawn(Script.Functions.DoorESP, currentRoomModel)
        end

        if nextRoomModel then
            task.spawn(Script.Functions.DoorESP, nextRoomModel)
        end
    end
    if Toggles.ObjectiveESP.Value then
        for _, objectiveEsp in pairs(Script.ESPTable.Objective) do
            objectiveEsp.Destroy()
        end
    end
    if Toggles.EntityESP.Value then
        for _, sideEntityESP in pairs(Script.ESPTable.SideEntity) do
            sideEntityESP.Destroy()
        end
    end
    if Toggles.ItemESP.Value then
        for _, itemEsp in pairs(Script.ESPTable.Item) do
            itemEsp.Destroy()
        end
    end
    if Toggles.ChestESP.Value then
        for _, chestEsp in pairs(Script.ESPTable.Chest) do
            chestEsp.Destroy()
        end
    end
    if Toggles.HidingSpotESP.Value then
        for _, hidingSpotEsp in pairs(Script.ESPTable.HidingSpot) do
            hidingSpotEsp.Destroy()
        end
    end
    if Toggles.GoldESP.Value then
        for _, goldEsp in pairs(Script.ESPTable.Gold) do
            goldEsp.Destroy()
        end
    end

    if currentRoomModel then
        for _, asset in pairs(currentRoomModel:GetDescendants()) do
            if Toggles.ObjectiveESP.Value then
                task.spawn(Script.Functions.ObjectiveESP, asset)
            end

            if Toggles.EntityESP.Value and table.find(EntityTable.SideNames, asset.Name) then    
                task.spawn(Script.Functions.SideEntityESP, asset)
            end
    
            if Toggles.ItemESP.Value and Script.Functions.ItemCondition(asset) then
                task.spawn(Script.Functions.ItemESP, asset)
            end

            if Toggles.ChestESP.Value and (asset:GetAttribute("Storage") == "ChestBox" or asset.Name == "Toolshed_Small") then
                task.spawn(Script.Functions.ChestESP, asset)
            end

            if Toggles.HidingSpotESP.Value and (asset:GetAttribute("LoadModule") == "Wardrobe" or asset:GetAttribute("LoadModule") == "Bed" or asset.Name == "Rooms_Locker" or asset.Name == "RetroWardrobe") then
                Script.Functions.HidingSpotESP(asset)
            end

            if Toggles.GoldESP.Value and asset.Name == "GoldPile" then
                Script.Functions.GoldESP(asset)
            end
        end
    
        Script.Functions.SetupCurrentRoomConnection(currentRoomModel)
    end
end))

Library:GiveSignal(playerGui.ChildAdded:Connect(function(child)
    if child.Name == "MainUI" then
        mainUI = child

        task.delay(1, function()
            if mainUI then
                mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")

                if mainGame then
                    if ExecutorSupport["require"] then mainGameSrc = require(mainGame) end

                    if mainGame:WaitForChild("Health", 5) then
                        if isHotel and Toggles.NoJammin.Value and liveModifiers:FindFirstChild("Jammin") then
                            local jamSound = mainGame:FindFirstChild("Jam", true)
                            if jamSound then jamSound.Playing = false end
                        end
                    end

                    if mainGame:WaitForChild("RemoteListener", 5) then
                        if Toggles.AntiScreech.Value then
                            local module = mainGame:FindFirstChild("Screech", true)
    
                            if module then
                                module.Name = "_Screech"
                            end
                        end
                        if (isHotel or isRooms) and Toggles.AntiA90.Value then
                            local module = mainGame:FindFirstChild("A90", true)
    
                            if module then
                                module.Name = "_A90"
                            end
                        end
                    end
                end
            end
        end)
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    Lighting.Brightness = Options.Brightness.Value
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Toggles.Fullbright.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
    if Toggles.NoFog.Value then
        Lighting.FogStart = 0
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if Toggles.NoFog.Value then
        Lighting.FogEnd = math.huge
    end
end))

Library:GiveSignal(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end

    if isFools and Library.IsMobile and input.UserInputType == Enum.UserInputType.Touch and Toggles.GrabBananaJeffToggle.Value then
        if Script.Temp.HoldingItem then
            return Script.Functions.ThrowBananaJeff()
        end

        local touchPos = input.Position
        local ray = workspace.CurrentCamera:ViewportPointToRay(touchPos.X, touchPos.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 500, RaycastParams.new())
        
        local target = result and result.Instance

        if target and isnetowner(target) then
            if target.Name == "BananaPeel" then
                Script.Temp.ItemHoldTrack:Play()

                if not target:FindFirstChildOfClass("BodyGyro") then
                    Instance.new("BodyGyro", target)
                end

                if not target:GetAttribute("Clip") then target:SetAttribute("Clip", target.CanCollide) end

                target.CanTouch = false
                target.CanCollide = false

                Script.Temp.HoldingItem = target
            elseif target:FindFirstAncestorWhichIsA("Model").Name == "JeffTheKiller" then
                Script.Temp.ItemHoldTrack:Play()

                local jeff = target:FindFirstAncestorWhichIsA("Model")

                for _, i in ipairs(jeff:GetDescendants()) do
                    if i:IsA("BasePart") then
                        if not i:GetAttribute("Clip") then i:SetAttribute("Clip", target.CanCollide) end

                        i.CanTouch = false
                        i.CanCollide = false
                    end
                end

                if not jeff.PrimaryPart:FindFirstChildOfClass("BodyGyro") then
                    Instance.new("BodyGyro", jeff.PrimaryPart)
                end

                Script.Temp.HoldingItem = jeff.PrimaryPart
            end
        end
    end
end))

Library:GiveSignal(RunService.RenderStepped:Connect(function()
    if not Toggles.ShowCustomCursor.Value and Library.Toggled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIcon = "rbxassetid://2833720882"
        UserInputService.MouseIconEnabled = true
    end

    local isThirdPersonEnabled = Toggles.ThirdPerson.Value and (Library.IsMobile or Options.ThirdPersonKey:GetState())
    if mainGameSrc then
        if isThirdPersonEnabled then
            camera.CFrame = mainGameSrc.finalCamCFrame * CFrame.new(1.5, -0.5, 6.5)
        end
        mainGameSrc.fovtarget = Options.FOV.Value

        if Toggles.NoCamBob.Value then
            mainGameSrc.bobspring.Position = Vector3.new()
            mainGameSrc.spring.Position = Vector3.new()
        end

        if Toggles.NoCamShake.Value then
            mainGameSrc.csgo = CFrame.new()
        end
    elseif camera then
        if isThirdPersonEnabled then
            camera.CFrame = camera.CFrame * CFrame.new(1.5, -0.5, 6.5)
        end
        camera.FieldOfView = Options.FOV.Value
    end

    if character then
        if character:FindFirstChild("Head") and not (mainGameSrc and mainGameSrc.stopcam or rootPart.Anchored and not character:GetAttribute("Hiding")) then
            character:SetAttribute("ShowInFirstPerson", isThirdPersonEnabled)
            character.Head.LocalTransparencyModifier = isThirdPersonEnabled and 0 or 1
        end

        local speedBoostAssignObj = if isFools then humanoid else character
        if isMines and Toggles.FastLadder.Value and character:GetAttribute("Climbing") then
            character:SetAttribute("SpeedBoostBehind", 50)
        else
            speedBoostAssignObj:SetAttribute("SpeedBoostBehind", Options.SpeedSlider.Value)
        end

        if rootPart then
            rootPart.CanCollide = not Toggles.Noclip.Value

            if rootPart.AssemblyLinearVelocity.Magnitude > (Options.VelocityLimiter.Value * 10) then
                velocityLimiter.Enabled = true
            else
                velocityLimiter.Enabled = false
            end
        end
        
        if collision then
            if Toggles.Noclip.Value then
                collision.CanCollide = not Toggles.Noclip.Value
                if collision:FindFirstChild("CollisionCrouch") then
                    collision.CollisionCrouch.CanCollide = not Toggles.Noclip.Value
                end
            end
        end

        if character:FindFirstChild("UpperTorso") then
            character.UpperTorso.CanCollide = not Toggles.Noclip.Value
        end
        if character:FindFirstChild("LowerTorso") then
            character.LowerTorso.CanCollide = not Toggles.Noclip.Value
        end

        if Toggles.DoorReach.Value and workspace.CurrentRooms:FindFirstChild(latestRoom.Value) then
            local door = workspace.CurrentRooms[latestRoom.Value]:FindFirstChild("Door")

            if door and door:FindFirstChild("ClientOpen") then
                door.ClientOpen:FireServer()
            end
        end

        -- The switch alone has to work. On desktop this used to require holding the
            -- keybind as well, so a user who turned Auto Interact on and walked up to a
            -- drawer got nothing and reported the feature as dead.
            if Toggles.AutoInteract.Value then
            
            local prompts = Script.Functions.GetAllPromptsWithCondition(function(prompt)
                if not prompt.Parent then return false end

                if prompt.Parent:GetAttribute("JeffShop") then return false end
                if prompt.Parent:GetAttribute("PropType") == "Battery" and ((character:FindFirstChildOfClass("Tool") and character:FindFirstChildOfClass("Tool"):GetAttribute("RechargeProp") ~= "Battery") or character:FindFirstChildOfClass("Tool") == nil) then return false end 
                if prompt.Parent:GetAttribute("PropType") == "Heal" and humanoid and humanoid.Health == humanoid.MaxHealth then return false end
                if prompt.Parent.Name == "MinesAnchor" then return false end

                if isRetro and prompt.Parent.Parent.Name == "RetroWardrobe" then return false end

                return PromptTable.Aura[prompt.Name] ~= nil
            end)
            for _, prompt: ProximityPrompt in pairs(prompts) do
                -- Selection marker. The swap below runs on its own coroutine and the
                -- smoke harness drops those, so this attribute is the only evidence the
                -- scan picked a prompt at all; in game it doubles as "auto interact
                -- already handled this one".
                pcall(function() prompt:SetAttribute("ReichtAutoInteract", true) end)
                task.spawn(function()
                    
                    -- Range check, but failing open. DistanceFromCharacter walks the
                    -- prompt's ancestor pivot and throws while a room is still
                    -- streaming; the old inline comparison let that throw kill the whole
                    -- spawn thread, so the scan ran and fired nothing.
                    local reachDistance = tonumber(prompt.MaxActivationDistance) or 0
                    local distance = nil
                    try(function() distance = Script.Functions.DistanceFromCharacter(prompt.Parent) end)
                    if type(distance) ~= "number" then distance = 0 end
                    if distance <= reachDistance and (not prompt:GetAttribute("Interactions" .. localPlayer.Name) or PromptTable.Aura[prompt.Name] or table.find(PromptTable.AuraObjects, prompt.Parent.Name)) then
                        -- painting checks
                        if prompt.Parent.Name == "Slot" and prompt.Parent:GetAttribute("Hint") and character then
                            if Script.Temp.PaintingDebounce then return end
                            
                            local currentPainting = character:FindFirstChild("Prop")
                            if not currentPainting and prompt.Parent:FindFirstChild("Prop") and prompt.Parent:GetAttribute("Hint") ~= prompt.Parent.Prop:GetAttribute("Hint") then
                                return firePrompt(prompt)
                            end

                            if prompt.Parent:FindFirstChild("Prop") then 
                                if prompt.Parent:GetAttribute("Hint") == prompt.Parent.Prop:GetAttribute("Hint") then
                                    return
                                end
                            end

                            if prompt.Parent:GetAttribute("Hint") == currentPainting:GetAttribute("Hint") then
                                Script.Temp.PaintingDebounce = true

                                local oldHint = currentPainting:GetAttribute("Hint")
                                repeat task.wait()
                                    firePrompt(prompt)
                                until not character:FindFirstChild("Prop") or character:FindFirstChild("Prop"):GetAttribute("Hint") ~= oldHint

                                task.wait(0.15)
                                Script.Temp.PaintingDebounce = false
                            end                            
                            
                            return
                        end
                        
                        -- Marks the prompt that auto interact actually reached. Harmless
                        -- in game (the stock prompt ignores unknown attributes) and it is
                        -- the only way the harness can tell "scan ran and fired" from
                        -- "scan never ran".
                        pcall(function() prompt:SetAttribute("ReichtFired", true) end)
                        firePrompt(prompt)
                    end
                end)
            end
        end

        if Toggles.SpamOtherTools.Value and  (Library.IsMobile or Options.SpamOtherTools:GetState()) then
            for _, player in pairs(Players:GetPlayers()) do
                if player == localPlayer then continue end
                
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    tool:FindFirstChildOfClass("RemoteEvent"):FireServer()
                end
                
                local toolRemote = player.Character:FindFirstChild("Remote", true)
                if toolRemote then
                    toolRemote:FireServer()
                end
            end
        end

        if isMines then
            if Toggles.AutoAnchorSolver.Value and latestRoom.Value == 50 and mainUI.MainFrame:FindFirstChild("AnchorHintFrame") then
                local prompts = Script.Functions.GetAllPromptsWithCondition(function(prompt)
                    return prompt.Name == "ActivateEventPrompt" and prompt.Parent:IsA("Model") and prompt.Parent.Name == "MinesAnchor" and not prompt.Parent:GetAttribute("Activated")
                end)

                local CurrentGameState = {
                    DesignatedAnchor = mainUI.MainFrame.AnchorHintFrame.AnchorCode.Text,
                    AnchorCode = mainUI.MainFrame.AnchorHintFrame.Code.Text
                }

                for _, prompt in pairs(prompts) do
                    task.spawn(function()
                        local Anchor = prompt.Parent
                        local CurrentAnchor = Anchor.Sign.TextLabel.Text

                        if not (Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance) then return end
                        if CurrentAnchor ~= CurrentGameState.DesignatedAnchor then return end

                        local result = Anchor:FindFirstChildOfClass("RemoteFunction"):InvokeServer(CurrentGameState.AnchorCode)
                        if result then
                            Script.Functions.Alert({
                                Title = "Auto Anchor Solver",
                                Description = "Solved Anchor " .. CurrentAnchor .. " successfully!",
                                Reason = "Solved anchor with the code " .. CurrentGameState.AnchorCode,
                            })
                        end
                    end)
                end
            end
        end

        if isFools then
            local HoldingItem = Script.Temp.HoldingItem
            if HoldingItem and not isnetowner(HoldingItem) then
                Script.Functions.Alert({
                    Title = "Banana/Jeff Throw",
                    Description = "You are no longer holding the item due to network owner change!",
                })
                Script.Temp.HoldingItem = nil
            end
    
            if HoldingItem and Toggles.GrabBananaJeffToggle.Value then
                if HoldingItem:FindFirstChildOfClass("BodyGyro") then
                    HoldingItem.CanTouch = false
                    HoldingItem.CFrame = character.RightHand.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                end
            end
            
            if not Library.IsMobile then
                local isGrabbing = Options.GrabBananaJeff:GetState() and Toggles.GrabBananaJeffToggle.Value
                local isThrowing = Options.ThrowBananaJeff:GetState()
                
                if isThrowing and HoldingItem and isnetowner(HoldingItem) then
                    Script.Functions.ThrowBananaJeff()
                end
                
                local target = localPlayer:GetMouse().Target
                
                if not target then return end
                if isGrabbing and isnetowner(target) then
                    if target.Name == "BananaPeel" then
                        Script.Temp.ItemHoldTrack:Play()
    
                        if not target:FindFirstChildOfClass("BodyGyro") then
                            Instance.new("BodyGyro", target)
                        end
    
                        if not target:GetAttribute("Clip") then target:SetAttribute("Clip", target.CanCollide) end
    
                        target.CanTouch = false
                        target.CanCollide = false
    
                        Script.Temp.HoldingItem = target
                    elseif target:FindFirstAncestorWhichIsA("Model").Name == "JeffTheKiller" then
                        Script.Temp.ItemHoldTrack:Play()
    
                        local jeff = target:FindFirstAncestorWhichIsA("Model")
    
                        for _, i in ipairs(jeff:GetDescendants()) do
                            if i:IsA("BasePart") then
                                if not i:GetAttribute("Clip") then i:SetAttribute("Clip", target.CanCollide) end
    
                                i.CanTouch = false
                                i.CanCollide = false
                            end
                        end
    
                        if not jeff.PrimaryPart:FindFirstChildOfClass("BodyGyro") then
                            Instance.new("BodyGyro", jeff.PrimaryPart)
                        end
    
                        Script.Temp.HoldingItem = jeff.PrimaryPart
                    end
                end
            end
        end

        if Toggles.AntiEyes.Value and (workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("BackdoorLookman")) then
            if not isFools then
                -- lsplash meanie for removing other args in motorreplication
                remotesFolder.MotorReplication:FireServer(-649)
            else
                remotesFolder.MotorReplication:FireServer(0, -90, 0, false)
            end
        end
    end

    task.spawn(function()
        for guidance, part in pairs(Script.Temp.Guidance) do
            if not guidance:IsDescendantOf(workspace) then continue end
            part.CFrame = guidance.CFrame
        end
    end)
end))

--// Script Load \\--

task.spawn(Script.Functions.SetupCharacterConnection, character)

--// Library Load \\--

Library:OnUnload(function()
    -- disconnect hook
    if mtHook then hookmetamethod(game, "__namecall", mtHook) end
    if _fixDistanceFromCharacter then hookmetamethod(localPlayer, "__namecall", _fixDistanceFromCharacter) end

    if Script.FakeRevive.Enabled then
        for _, connection in pairs(Script.FakeRevive.Connections) do
            if connection.Connected then connection:Disconnect() end
        end

        table.clear(Script.FakeRevive.Connections)
    end

    if getgenv().BloxstrapRPC then
        BloxstrapRPC.SetRichPresence({
            details = "<reset>",
            state = "<reset>",
            largeImage = {
                reset = true
            },
            smallImage = {
                reset = true
            }
        })
    end

    if character then
        character:SetAttribute("CanJump", false)

        local speedBoostAssignObj = isFools and humanoid or character
        speedBoostAssignObj:SetAttribute("SpeedBoostBehind", 0)

        if velocityLimiter then
            velocityLimiter:Destroy()
        end
    end

    if alive then
        Lighting.Ambient = workspace.CurrentRooms[localPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
    end

    if entityModules then
        local module = entityModules:FindFirstChild("_Shade")

        if module then
            module.Name = "Shade"
        end
    end

    if mainGame then
        local module = mainGame:FindFirstChild("_Screech", true)

        if module then
            module.Name = "Screech"
        end
    end

    if mainGameSrc then
        mainGameSrc.fovtarget = 70
    else
        camera.FieldOfView = 70
    end

    if rootPart then
        local existingProperties = rootPart.CustomPhysicalProperties
        rootPart.CustomPhysicalProperties = PhysicalProperties.new(Script.Temp.NoAccelValue, existingProperties.Friction, existingProperties.Elasticity, existingProperties.FrictionWeight, existingProperties.ElasticityWeight)
    end

    if isBackdoor then
        local clientRemote = floorReplicated.ClientRemote
        local internal_temp_lonelyhub = clientRemote:FindFirstChild("_lonelyhub")

        if internal_temp_lonelyhub and #internal_temp_lonelyhub:GetChildren() ~= 0 then
            for i,v in pairs(internal_temp_lonelyhub:GetChildren()) do
                v.Parent = clientRemote.Haste
            end
        end

        internal_temp_lonelyhub:Destroy()
    end

    if isMines then
        local acbypasspart = workspace:FindFirstChild("_internal_lonelyhub_acbypassprogress")
        if acbypasspart then acbypasspart:Destroy() end
    end

    if isRooms then
        if workspace:FindFirstChild("_internal_lonelyhub_pathfinding_nodes") then
            workspace:FindFirstChild("_internal_lonelyhub_pathfinding_nodes"):Destroy()
        end
        if workspace:FindFirstChild("_internal_lonelyhub_pathfinding_block") then
            workspace:FindFirstChild("_internal_lonelyhub_pathfinding_block"):Destroy()
        end
    end

    if _lonelyhub_custom_captions then
        _lonelyhub_custom_captions:Destroy()
    end

    if collision then
        collision.CanCollide = if mainGameSrc then not mainGameSrc.crouching else not character:GetAttribute("Crouching")
        if collision:FindFirstChild("CollisionCrouch") then
            collision.CollisionCrouch.CanCollide = if mainGameSrc then mainGameSrc.crouching else character:GetAttribute("Crouching")
        end
    end

    if collisionClone then collisionClone:Destroy() end

    for _, antiBridge in pairs(Script.Temp.Bridges) do antiBridge:Destroy() end
    if Script.Temp.FlyBody then Script.Temp.FlyBody:Destroy() end

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Destroy()
        end
    end

    for _, connection in pairs(Script.Connections) do
        connection:Disconnect()
    end

    for _, category in pairs(Script.FeatureConnections) do
        for _, connection in pairs(category) do
            connection:Disconnect()
        end
    end

    print("Unloaded!")
    Library.Unloaded = true
    getgenv().lonelyhub_loaded = false
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local CreditsGroup = Tabs["UI Settings"]:AddRightGroupbox("Credits")

MenuGroup:AddToggle("ExecuteOnTeleport", { Default = false, Text = "Execute on Teleport", Visible = ExecutorSupport["queue_on_teleport"] })
MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Join Discord", function()
    local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
    Inviter.Join("https://discord.gg/yVptwJPAcM")
    Inviter.Prompt({
        name = "Lonely Hub",
        invite = "https://discord.gg/yVptwJPAcM",
    })
end):AddButton("Copy Link", function()
    if setclipboard then
        setclipboard("https://discord.gg/yVptwJPAcM")
        Library:Notify("Copied discord link to clipboard!")
    else
        Library:Notify("Discord link: https://discord.gg/yVptwJPAcM", 10)
    end
end)
MenuGroup:AddButton("Unload", function() Library:Unload() end)

CreditsGroup:AddLabel("Developers:")
CreditsGroup:AddLabel("LongHip - Owner")
CreditsGroup:AddLabel("Aether - main script dev")
CreditsGroup:AddLabel("Join Discord For Update Log")
CreditsGroup:AddLabel("Lonely Hub On Top!")

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetFolder("Lonely Hub/doors")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

--== Reicht merge layer =======================================================
-- Folded in from the other public DOORS hubs this hub was compared against, so
-- the product stays ONE script instead of a loader that chains other loaders.
-- Each block drives the same mechanism the source hub drove; where a source
-- leaned on a hosted library (Vynixu entity/item spawner, MS-ESP) the effect is
-- reproduced natively here.
do
    local RS = game:GetService("ReplicatedStorage")
    local WS = game:GetService("Workspace")
    local PlayersS = game:GetService("Players")
    local RunS = game:GetService("RunService")
    local LP = PlayersS.LocalPlayer

    local function try(fn, ...)
        local ok, res = pcall(fn, ...)
        if ok then return res end
        return nil
    end

    local function gd(name)
        local folder = RS:FindFirstChild("GameData")
        return folder and folder:FindFirstChild(name) or nil
    end

    local function latestRoom()
        local value = gd("LatestRoom")
        return value and tonumber(value.Value) or 0
    end

    local function rooms()
        return WS:FindFirstChild("CurrentRooms")
    end

    local function roomAt(index)
        local folder = rooms()
        if not folder then return nil end
        return folder:FindFirstChild(tostring(index)) or folder[tostring(index)]
    end

    local function character()
        local model = LP.Character
        if not model then model = try(function() return LP.CharacterAdded:Wait() end) end
        return model
    end

    local function humanoid()
        local model = character()
        if not model then return nil end
        return model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("Humanoid")
    end

    local function bricks(name)
        local folder = RS:FindFirstChild("Bricks")
        return folder and folder:FindFirstChild(name) or nil
    end

    local function entityInfo(name)
        local folder = RS:FindFirstChild("EntityInfo")
        return folder and folder:FindFirstChild(name) or nil
    end

    local function mainGame()
        local gui = LP:FindFirstChild("PlayerGui")
        local mainUI = gui and gui:FindFirstChild("MainUI")
        local initiator = mainUI and mainUI:FindFirstChild("Initiator")
        return initiator and initiator:FindFirstChild("Main_Game") or nil
    end

    local function mainData()
        local module = mainGame()
        if not module then return nil end
        return try(function() return require(module) end)
    end

    local function moduleAt(root, ...)
        local node = root
        for _, key in ipairs({ ... }) do
            if not node then return nil end
            node = node:FindFirstChild(key)
        end
        if not node then return nil end
        return try(function() return require(node) end)
    end

    -- firesignal exists only in some executors; getconnections is the next best
    -- bridge and a plain :Fire keeps the call harmless in the rest.
    local function fireSignal(signal, ...)
        if not signal then return end
        local args = { ... }
        if type(firesignal) == "function" then
            try(firesignal, signal, table.unpack(args))
            return
        end
        if type(getconnections) == "function" then
            local conns = try(getconnections, signal)
            if conns then
                for _, conn in next, conns do
                    try(function() conn.Fire(conn, table.unpack(args)) end)
                end
                return
            end
        end
        try(function() signal:Fire(table.unpack(args)) end)
    end

    local function notify(text)
        try(function()
            Library:Notify(text, 3)
        end)
    end

    -- ---- entity modules -----------------------------------------------------
    -- DOORS ships its entity behaviour as client modules; calling them locally
    -- spawns the entity without asking the server for anything.
    local function spawnEntity(kind)
        local room = roomAt(latestRoom())
        if kind == "Screech" then
            local mod = moduleAt(mainGame(), "RemoteListener", "Modules", "Screech")
            if mod then try(mod, mainData()) end
        elseif kind == "Spider" then
            local mod = moduleAt(mainGame(), "RemoteListener", "Modules", "SpiderJumpscare")
            if mod then try(mod, mainData()) end
        elseif kind == "Halt" then
            local mod = moduleAt(RS:FindFirstChild("ClientModules"), "EntityModules", "Shade")
            if mod and room then try(mod.stuff, mainData(), room) end
        elseif kind == "Glitch" then
            local mod = moduleAt(RS:FindFirstChild("ClientModules"), "EntityModules", "Glitch")
            if mod and room then try(mod.stuff, mainData(), room) end
        elseif kind == "SeekEyes" then
            local mod = moduleAt(RS:FindFirstChild("ClientModules"), "EntityModules", "Seek")
            if mod and room then try(mod.tease, nil, room) end
        elseif kind == "Eyes" then
            -- GetObjects reads the model straight from the asset CDN.
            local model = try(function() return game:GetObjects("rbxassetid://11388700077")[1] end)
            if model then
                local nodes = room and room:FindFirstChild("Nodes")
                local anchor = nil
                if nodes and #nodes:GetChildren() > 0 then
                    local pick = nodes:GetChildren()[math.max(1, math.floor(#nodes:GetChildren() / 2))]
                    anchor = pick
                elseif room then
                    anchor = room:FindFirstChild("Base")
                end
                if anchor and anchor.CFrame then
                    model.CFrame = anchor.CFrame + Vector3.new(0, 7, 0)
                end
                model.Parent = WS
            end
        end
    end

    -- ---- world controls -----------------------------------------------------
    local function useEvent(event, ...)
        local module = bricks("UseEventModule")
        if not module then return end
        -- OnClientEvent is a signal property, not a child.
        local signal = module.OnClientEvent
        if not signal then return end
        fireSignal(signal, event, ...)
    end

    local function breakLights()
        useEvent("breakLights", roomAt(latestRoom()), 0.416, 60)
    end

    local function flickerLights()
        useEvent("flickerLights", latestRoom(), 1)
    end

    local function instantBreaker()
        local remote = bricks("EBF")
        if remote then try(function() remote:FireServer() end) end
    end

    local function heartbeatMinigame()
        local remote = bricks("ClutchHeartbeat")
        local signal = remote and remote.OnClientEvent
        if signal then fireSignal(signal) end
    end

    local function openAllDoors()
        local folder = rooms()
        if not folder then return end
        for _, room in ipairs(folder:GetChildren()) do
            local door = room:FindFirstChild("Door")
            local remote = door and door:FindFirstChild("ClientOpen")
            if remote then try(function() remote:FireServer() end) end
        end
    end

    local function skipDoor()
        local room = roomAt(latestRoom() + 1)
        local door = room and room:FindFirstChild("Door")
        local part = door and (door:FindFirstChild("Door") or door:FindFirstChildWhichIsA("BasePart"))
        local model = character()
        if part and model then
            try(function() model:PivotTo(CFrame.new(part.Position + Vector3.new(0, 3, 0))) end)
        end
    end

    local function redRoom()
        local events = moduleAt(RS:FindFirstChild("ClientModules"), "Module_Events")
        local room = roomAt(latestRoom())
        if events and room then try(events.tryp, room, 1000000) end
    end

    local function unlockAchievements()
        local list = try(function() return require(RS:FindFirstChild("Achievements")) end)
        if type(list) ~= "table" then
            notify("Achievements module not reachable here.")
            return
        end
        local unlock = moduleAt(mainGame(), "RemoteListener", "Modules", "AchievementUnlock")
        if not unlock then return end
        for identifier in pairs(list) do
            try(unlock, nil, identifier)
        end
    end

    local function giveCrucifix()
        local tool = try(function() return game:GetObjects("rbxassetid://11480603603")[1] end)
        if not tool then
            notify("Crucifix asset needs executor GetObjects.")
            return
        end
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then tool.Parent = backpack end
    end

    -- Tim3craft plushies: the models are rbxm files, so they only load where the
    -- executor exposes writefile + getcustomasset.
    local PLUSHIES = {
        ["A-90 Plush"] = {
            folder = "Reicht/Doors/Plush/A90",
            files = {
                ["model.rbxm"] = "https://raw.githubusercontent.com/tim3craft/A-90-A-120-Plushie/main/A-90%20Plush.rbxm",
            },
        },
        ["A-120 Plush"] = {
            folder = "Reicht/Doors/Plush/A120",
            files = {
                ["model.rbxm"] = "https://raw.githubusercontent.com/tim3craft/A-90-A-120-Plushie/main/A-120.rbxm",
            },
        },
    }

    local function givePlushie(name)
        local spec = PLUSHIES[name]
        if not spec then return end
        if type(writefile) ~= "function" or type(getcustomasset) ~= "function"
            or type(isfolder) ~= "function" or type(makefolder) ~= "function" then
            notify("Plushies need writefile/getcustomasset support.")
            return
        end
        for _, dir in ipairs({ "Reicht", "Reicht/Doors", "Reicht/Doors/Plush", spec.folder }) do
            if not isfolder(dir) then try(makefolder, dir) end
        end
        local path = spec.folder .. "/model.rbxm"
        local file = spec.files["model.rbxm"]
        if type(isfile) ~= "function" or not isfile(path) then
            local body = try(game.HttpGet, game, file)
            if not body or #body == 0 then
                notify("Plushie download failed.")
                return
            end
            try(writefile, path, body)
        end
        local asset = try(getcustomasset, path, true)
        if not asset then
            notify("Plushie asset could not be mounted.")
            return
        end
        local objects = try(function() return game:GetObjects(asset) end)
        local model = objects and objects[1]
        if not model then return end
        local tool = model:FindFirstChildWhichIsA("Tool", true) or model
        if tool:IsA("Model") and not tool:IsA("Tool") then
            local holder = Instance.new("Tool")
            holder.Name = name
            holder.RequiresHandle = true
            for _, child in ipairs(tool:GetChildren()) do child.Parent = holder end
            tool:Destroy()
            tool = holder
        end
        tool.Name = name
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then tool.Parent = backpack end
    end

    -- ---- per-room state -----------------------------------------------------
    local FLAGS = {}
    local ROOM_HOOKS = {}
    local PROMPT_SEEN = {}
    local HIDE_TICK = 0
    local LAST_ITEM_WASTE = 0
    local LAST_BREAKER = 0

    local function applyRoomProps()
        local folder = rooms()
        if folder then
            for _, object in ipairs(folder:GetDescendants()) do
                if object.Name == "DoorFake" then
                    local hidden = object:FindFirstChild("Hidden")
                    if hidden then hidden.CanTouch = not FLAGS.disable_dupe end
                    local lock = object:FindFirstChild("LockPart")
                    local prompt = lock and lock:FindFirstChild("UnlockPrompt")
                    if prompt then prompt.Enabled = not FLAGS.disable_dupe end
                elseif object.Name == "Snare" then
                    local hitbox = object:FindFirstChild("Hitbox")
                    if hitbox then hitbox.CanTouch = not FLAGS.disable_snare end
                elseif object.Name == "Collision" and FLAGS.disable_seek then
                    object.CanTouch = false
                end
                if FLAGS.all_interactions and try(function() return object:IsA("ProximityPrompt") end) then
                    PROMPT_SEEN[object] = true
                    object.Enabled = true
                    object.RequiresLineOfSight = false
                end
            end
        end

        if FLAGS.eyes then
            if WS:FindFirstChild("Eyes") then
                local motor = entityInfo("MotorReplication")
                if motor then try(function() motor:FireServer(0, -120, 0, false) end) end
            end
        end

        if FLAGS.a90 then
            local entity = WS:FindFirstChild("A90")
            if entity then
                for _, part in ipairs(entity:GetDescendants()) do
                    if try(function() return part:IsA("Sound") end) then
                        try(function() part:Stop() end)
                    elseif try(function() return part:IsA("BasePart") end) then
                        try(function() part.Transparency = 1 end)
                    end
                end
            end
        end
    end

    -- God mode used to be a single nudge of the Collision part on click and
    -- nothing else: FLAGS.god was written and never read, so the switch died the
    -- moment the game re-anchored the hitbox on the next room. Entities kill by
    -- touching that part, so it has to be kept out of reach on every frame, not
    -- once. CanTouch=false covers the client-side touch path; the position sink
    -- covers the server-side one that checks the part's own position.
    -- Vector test that holds in both worlds. `type(v) == "table"` is true for the
    -- harness Vector3 and false for the real one (userdata), so the old guard returned
    -- early on every real frame: godmode was green in the harness and dead in game.
    local function isVector(v)
        if v == nil then return false end
        return pcall(function() return v + Vector3.new(0, 0, 0) end)
    end

    local function vectorDistance(a, b)
        local ok, distance = pcall(function() return (a - b).Magnitude end)
        if ok and type(distance) == "number" then return distance end
        local ok2, fallback = pcall(function()
            local offset = a - b
            return math.sqrt(offset.X * offset.X + offset.Y * offset.Y + offset.Z * offset.Z)
        end)
        if ok2 and type(fallback) == "number" then return fallback end
        return nil
    end

    local GOD_SINK = Vector3.new(0, -500, 0)
    local function godStep()
        local model = character()
        if not model then return end
        local collision = model:FindFirstChild("Collision")
        if collision then
            try(function()
                collision.CanTouch = false
                collision.CanCollide = false
                local root = model:FindFirstChild("HumanoidRootPart")
                -- Anchor on the root, never on the part itself: the part is being
                -- pushed down every tick, so re-reading it would walk it to -infinity.
                if not root then return end
                local origin = root.Position
                if not isVector(origin) then return end
                collision.Position = origin + GOD_SINK
                -- Crouched hitbox is a second part and is what actually kills you while
                -- hiding; sinking only the standing one left the crouch path open.
                local crouch = collision:FindFirstChild("CollisionCrouch")
                if crouch then
                    crouch.CanTouch = false
                    crouch.CanCollide = false
                    crouch.Position = origin + GOD_SINK
                end
                -- The stock character carries a second hitbox, CollisionClone, welded to the
                -- torso and used for touch damage. Only sinking Collision left the clone
                -- sitting next to the entity, so godmode looked green and still died.
                local clone = model:FindFirstChild("CollisionClone")
                if clone then
                    clone.CanTouch = false
                    clone.CanCollide = false
                    clone.Position = origin + GOD_SINK
                    local cloneCrouch = clone:FindFirstChild("CollisionCrouch")
                    if cloneCrouch then
                        cloneCrouch.CanTouch = false
                        cloneCrouch.CanCollide = false
                        cloneCrouch.Position = origin + GOD_SINK
                    end
                end
            end)
        end
        -- Health top-up is a second line of defence for the deaths that never go
        -- through the touch path. It is best effort: a server-side kill still wins.
        local hp = model:FindFirstChildOfClass("Humanoid")
        if hp and hp.Health < hp.MaxHealth then
            try(function() hp.Health = hp.MaxHealth end)
        end
    end

    -- ---- instant interaction and grab range ----------------------------------
    -- Both are properties of a ProximityPrompt and Doors builds a fresh set for every
    -- room. Patching them only when the switch flipped covered the room that existed at
    -- that instant and nothing after it, which is why the range control read as dead.
    local PROMPT_BASE = {}
    local function applyPromptReach()
        local folder = rooms()
        if not folder then return end
        local reach = tonumber(FLAGS.grab_range) or 1
        local instant = FLAGS.all_interactions and true or false
        if reach <= 1 and not instant then return end
        for _, prompt in ipairs(folder:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                -- The game parks prompts behind the DisableWhenEnabledOnClient tag and flips
                -- Enabled off on the client. Firing a disabled prompt is a no-op, so auto
                -- interact read as dead even with the reach slider maxed.
                if prompt:HasTag("DisableWhenEnabledOnClient") then
                    try(function() prompt:RemoveTag("DisableWhenEnabledOnClient") end)
                end
                if prompt.Enabled == false then
                    try(function() prompt.Enabled = true end)
                end
                if reach > 1 then
                    try(function() prompt.RequiresLineOfSight = false end)
                end
                local base = PROMPT_BASE[prompt]
                if not base and type(prompt.MaxActivationDistance) == "number" then
                    base = prompt.MaxActivationDistance
                    PROMPT_BASE[prompt] = base
                end
                if type(base) == "number" and reach > 1 then
                    local want = base * reach
                    if prompt.MaxActivationDistance ~= want then
                        try(function() prompt.MaxActivationDistance = want end)
                    end
                end
                if instant then
                    if prompt:GetAttribute("Hold") == nil then
                        try(function() prompt:SetAttribute("Hold", prompt.HoldDuration) end)
                    end
                    if prompt.HoldDuration ~= 0 then
                        try(function() prompt.HoldDuration = 0 end)
                    end
                end
            end
        end
    end

    -- ---- remote grab ---------------------------------------------------------
    -- The game validates the interaction against where the character stands, so a big
    -- MaxActivationDistance alone never reaches something across the map. Working Doors
    -- hubs move the character onto the target, fire the prompt, and move back. Same
    -- trip here, with the return CFrame saved before the first hop.
    local GRAB_PARENTS = {
        KeyObtain = true, RoomKey = true, GoldPile = true, ChestBox = true,
        LiveHintBook = true, LiveBreakerPolePickup = true, BreakerPolePickup = true,
        LeverForGate = true, FlashlightPickup = true, VitaminsPickup = true,
    }
    local GRAB_BUSY = false

    local function grabAnchor(prompt)
        local parent = prompt.Parent
        if not parent then return nil end
        local part = parent.PrimaryPart
        if not part then part = parent:FindFirstChild("Hitbox") end
        if not part then part = parent:FindFirstChildWhichIsA("BasePart") end
        if part and part.Position ~= nil then return part end
        return nil
    end

    local function nearestGrabTarget(range)
        local folder = rooms()
        local model = character()
        if not folder or not model then return nil end
        local root = model:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local origin = root.Position
        if origin == nil then return nil end
        local bestPrompt, bestPart, bestDistance
        for _, prompt in ipairs(folder:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent and GRAB_PARENTS[prompt.Parent.Name] then
                local part = grabAnchor(prompt)
                if part then
                    local distance = vectorDistance(part.Position, origin)
                    if distance and distance > 8 and distance <= range and (not bestDistance or distance < bestDistance) then
                        bestPrompt, bestPart, bestDistance = prompt, part, distance
                    end
                end
            end
        end
        return bestPrompt, bestPart
    end

    local function remoteGrabStep()
        if GRAB_BUSY then return end
        local prompt, part = nearestGrabTarget(tonumber(FLAGS.grab_far) or 250)
        if not prompt or not part then return end
        local model = character()
        local root = model and model:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local saved = root.CFrame
        GRAB_BUSY = true
        task.spawn(function()
            try(function() model:PivotTo(CFrame.new(part.Position + Vector3.new(0, 3, 0))) end)
            task.wait(0.3)
            try(function() firePrompt(prompt) end)
            task.wait(0.15)
            if saved then try(function() model:PivotTo(saved) end) end
            task.wait(0.2)
            GRAB_BUSY = false
        end)
    end

    -- Wiring lives here, not in the toggle callback: FLAGS is declared in this block, so
    -- a callback written up in the menu section would write a global of the same name
    -- that nothing reads.
    if Toggles.RemoteGrab then
        Toggles.RemoteGrab:OnChanged(function(value) FLAGS.remote_grab = value end)
    end
    if Options.GrabRange then
        FLAGS.grab_far = tonumber(Options.GrabRange.Value) or 250
        Options.GrabRange:OnChanged(function(value) FLAGS.grab_far = tonumber(value) or 250 end)
    end
    if Options.PromptReachMultiplier then
        FLAGS.grab_range = tonumber(Options.PromptReachMultiplier.Value) or 1
        Options.PromptReachMultiplier:OnChanged(function(value) FLAGS.grab_range = tonumber(value) or 1 end)
    end

    local function applyRoomHooks()
        local room = roomAt(latestRoom())
        if not room then return end
        for id, hook in pairs(ROOM_HOOKS) do
            if FLAGS[id] then try(hook, room) end
        end
    end

    local roomSignal = gd("LatestRoom")
    if roomSignal then
        try(function()
            roomSignal.Changed:Connect(function()
                applyRoomHooks()
                applyRoomProps()
            end)
        end)
    end


    -- ---- room ESP -----------------------------------------------------------
    -- Targets recovered by decrypting an obfuscated Doors hub (dih_doors): its
    -- string table decoded to exactly these part names plus the menu labels
    -- "Key ESP", "Lever ESP", "Breaker Pole ESP", "Book ESP (LiveHintBook)" and
    -- "Exit / Dupe Check (RoomExit)". Names are the game's own, not guesses, so
    -- the scan hits what Doors actually spawns per room.
    local ESP_TARGETS = {
        key_esp = { "KeyObtain", "RoomKey", "Key" },
        lever_esp = { "LeverForGate", "GateLever", "Lever", "LEVER" },
        breaker_esp = { "LiveBreakerPolePickup", "BreakerPolePickup", "LiveBreakerPole", "BreakerPole" },
        book_esp = { "LiveHintBook", "HintBook" },
        exit_esp = { "RoomExit", "RoomEntrance" },
    }
    local ESP_MADE = {}
    local ESP_COLOR = Color3.fromRGB(214, 76, 64)

    local function applyRoomESP()
        local folder = rooms()
        if not folder then return end
        local wanted = {}
        for flag, names in pairs(ESP_TARGETS) do
            if FLAGS[flag] then
                for _, name in ipairs(names) do wanted[name] = true end
            end
        end
        for _, object in ipairs(folder:GetDescendants()) do
            if wanted[object.Name] then
                if not ESP_MADE[object] then
                    local ok, entry = pcall(function()
                        return ESPLibrary.ESP.Highlight({
                            Model = object,
                            FillColor = ESP_COLOR,
                            OutlineColor = Color3.fromRGB(255, 255, 255),
                            FillTransparency = 0.6,
                            OutlineTransparency = 0,
                        })
                    end)
                    if ok and entry then ESP_MADE[object] = entry end
                end
            elseif ESP_MADE[object] then
                try(function() ESP_MADE[object]:Remove() end)
                ESP_MADE[object] = nil
            end
        end
    end

    -- Single heartbeat keeps every continuous feature on one thread instead of
    -- one loop per toggle.
    local accumulator = 0
    try(function()
        RunS.Heartbeat:Connect(function(delta)
            accumulator = accumulator + (delta or 0)
            if accumulator < 0.25 then return end
            accumulator = 0
            -- One pcall per feature. These used to run bare in a single sequence, so the
            -- first nil index anywhere killed the rest of the tick: godmode, closet fix,
            -- breaker and the item waster all went dark at once while the menu still
            -- looked healthy. That is exactly the "semuanya ga work" report.
            try(applyRoomProps)
            try(applyRoomESP)
            try(applyPromptReach)

            if FLAGS.god then try(godStep) end
            if FLAGS.remote_grab then try(remoteGrabStep) end

            local now = tick()
            local model = try(character)
            if model then
                if FLAGS.closet_fix and model:GetAttribute("Hiding") == true then
                    if now - HIDE_TICK > 1 then
                        local camLock = entityInfo("CamLock")
                        if camLock then try(function() camLock:FireServer() end) end
                    end
                end
                if model:GetAttribute("Hiding") == true then HIDE_TICK = now end
            end

            if FLAGS.no_breaker and now - LAST_BREAKER > 1 then
                LAST_BREAKER = now
                try(instantBreaker)
            end

            if FLAGS.waste_items and now - LAST_ITEM_WASTE > 1 then
                LAST_ITEM_WASTE = now
                for _, player in ipairs(PlayersS:GetPlayers()) do
                    if player ~= LP then
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            for _, item in ipairs(backpack:GetChildren()) do
                                if item.Name == "Lighter" or item.Name == "Flashlight" or item.Name == "Vitamins" then
                                    local remote = item:FindFirstChild("Remote")
                                    if remote then try(function() remote:FireServer() end) end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)

    -- ---- menu surface -------------------------------------------------------
    local SpawnerTab = Tabs["Spawner"]
    local EntitiesGroup = SpawnerTab:AddLeftGroupbox("Entity Modules")
    EntitiesGroup:AddLabel("Calls the game's own client entity modules locally.")
    EntitiesGroup:AddButton("Spawn Screech", function() spawnEntity("Screech") end)
    EntitiesGroup:AddButton("Spawn Screech x100", function()
        for _ = 1, 100 do spawnEntity("Screech") end
    end)
    EntitiesGroup:AddButton("Spawn Halt", function() spawnEntity("Halt") end)
    EntitiesGroup:AddButton("Spawn Glitch", function() spawnEntity("Glitch") end)
    EntitiesGroup:AddButton("Seek Eyes", function() spawnEntity("SeekEyes") end)
    EntitiesGroup:AddButton("Spider Jumpscare", function() spawnEntity("Spider") end)
    EntitiesGroup:AddButton("Spawn Eyes (model)", function() spawnEntity("Eyes") end)

    local EveryGroup = SpawnerTab:AddRightGroupbox("Every Door")
    EveryGroup:AddToggle("reicht_screech_door", {
        Text = "Screech Every Door",
        Default = false,
        Callback = function(state)
            FLAGS.screech_door = state
            ROOM_HOOKS.screech_door = function() spawnEntity("Screech") end
        end,
    })
    EveryGroup:AddToggle("reicht_halt_door", {
        Text = "Halt Every Door",
        Default = false,
        Callback = function(state)
            FLAGS.halt_door = state
            ROOM_HOOKS.halt_door = function() spawnEntity("Halt") end
        end,
    })
    EveryGroup:AddToggle("reicht_glitch_door", {
        Text = "Glitch Every Door",
        Default = false,
        Callback = function(state)
            FLAGS.glitch_door = state
            ROOM_HOOKS.glitch_door = function() spawnEntity("Glitch") end
        end,
    })
    EveryGroup:AddToggle("reicht_breaklights_door", {
        Text = "Break Lights Every Door",
        Default = false,
        Callback = function(state)
            FLAGS.breaklights_door = state
            ROOM_HOOKS.breaklights_door = function() breakLights() end
        end,
    })
    EveryGroup:AddToggle("reicht_flicker_door", {
        Text = "Flicker Lights Every Door",
        Default = false,
        Callback = function(state)
            FLAGS.flicker_door = state
            ROOM_HOOKS.flicker_door = function() flickerLights() end
        end,
    })

    local ItemsTab = Tabs["Items"]
    local GiversGroup = ItemsTab:AddLeftGroupbox("Givers")
    GiversGroup:AddButton("Open All Doors (Skeleton Key)", function() openAllDoors() end)
    GiversGroup:AddButton("Give Crucifix", function() giveCrucifix() end)
    GiversGroup:AddButton("100 HP", function()
        local hp = humanoid()
        if hp then try(function() hp.Health = 100 end) end
    end)
    GiversGroup:AddButton("Instant Breaker", function() instantBreaker() end)
    GiversGroup:AddButton("Unlock All Achievements", function() unlockAchievements() end)

    local UtilityGroup = ItemsTab:AddRightGroupbox("Utility")
    UtilityGroup:AddButton("Skip Door", function() skipDoor() end)
    UtilityGroup:AddButton("Red Room", function() redRoom() end)
    UtilityGroup:AddButton("Heartbeat Minigame", function() heartbeatMinigame() end)
    UtilityGroup:AddButton("Break Lights", function() breakLights() end)
    UtilityGroup:AddButton("Flicker Lights", function() flickerLights() end)
    UtilityGroup:AddToggle("reicht_no_breaker", {
        Text = "No Breaker Puzzle",
        Default = false,
        Callback = function(state) FLAGS.no_breaker = state end,
    })

    local SurvivalTab = Tabs["Survival"]
    local ProtectGroup = SurvivalTab:AddLeftGroupbox("Protection")
    ProtectGroup:AddToggle("reicht_god_mode", {
        Text = "God Mode",
        Default = false,
        Callback = function(state)
            FLAGS.god = state
            -- Apply on the click so the switch reads as live, then let the
            -- heartbeat hold it. The single nudge this used to do was the whole
            -- old implementation, and it decayed the moment the next room loaded.
            if state then godStep() end
        end,
    })
    -- The five protection features below were declared a SECOND time here
    -- ("Eyes Invincibility", "Disable Snare", "Disable Dupe Doors", "Disable A-90
    -- Visuals", "Disable Seek Trigger") on top of the upstream Anti-* toggles, plus
    -- "Closet Exit Fix" and "Enable All Interactions" over FastClosetExit and
    -- InstaInteract. Two switches for one behaviour, and they disagreed about rooms
    -- that had already spawned: the upstream handlers only sweep on toggle, this
    -- layer swept on every heartbeat. Latch onto the existing control instead --
    -- upstream keeps its module work, this layer adds the sweep it was missing.
    local function latchFlag(toggleName, flag)
        local toggle = Toggles[toggleName]
        if not toggle then return end
        local function apply(value)
            FLAGS[flag] = value
            applyRoomProps()
        end
        apply(toggle.Value)
        toggle:OnChanged(apply)
    end
    latchFlag("AntiEyes", "eyes")
    latchFlag("AntiSnare", "disable_snare")
    latchFlag("AntiDupe", "disable_dupe")
    latchFlag("AntiA90", "a90")
    latchFlag("AntiSeekObstructions", "disable_seek")
    latchFlag("FastClosetExit", "closet_fix")
    latchFlag("InstaInteract", "all_interactions")

    local WorldGroup = SurvivalTab:AddRightGroupbox("World")

    -- Five ESP toggles from the decrypted hub above. One shared scan, so enabling
    -- all five costs the same as one.
    local EspGroup = SurvivalTab:AddRightGroupbox("Room ESP")
    for _, spec in ipairs({
        { "key_esp", "Key ESP" },
        { "lever_esp", "Lever ESP" },
        { "breaker_esp", "Breaker Pole ESP" },
        { "book_esp", "Book ESP (Hint Book)" },
        { "exit_esp", "Room Exit / Dupe Check" },
    }) do
        EspGroup:AddToggle(spec[1], {
            Text = spec[2],
            Default = false,
            Callback = function(value)
                FLAGS[spec[1]] = value
                -- Immediate pass so the highlight appears on the same click; the
                -- heartbeat keeps it in sync as rooms change.
                applyRoomESP()
            end,
        })
    end
    WorldGroup:AddToggle("reicht_no_jumpscare", {
        Text = "No Jumpscares",
        Default = false,
        Callback = function(state)
            if state then
                local remote = bricks("Jumpscare")
                if remote then try(function() remote:Destroy() end) end
            end
        end,
    })
    WorldGroup:AddToggle("reicht_waste", {
        Text = "Waste Other Players Items",
        Default = false,
        Callback = function(state) FLAGS.waste_items = state end,
    })
    WorldGroup:AddButton("Give A-90 Plush", function() givePlushie("A-90 Plush") end)
    WorldGroup:AddButton("Give A-120 Plush", function() givePlushie("A-120 Plush") end)

    print("[Reicht | Doors] merge layer ready")
end

    __abysallLayer(Library, Window)
Script.Functions.UpdateRPC()
getgenv().lonelyhub_loaded = true

end

local ok, err = xpcall(Run, debug.traceback)
if not ok then
    getgenv().lonelyhub_loaded = false
    Alert("Lonely Hub error: " .. tostring(err))
end
