#!/usr/bin/env python3
"""Load a built game file against a mocked Roblox + menu library, drive every control,
run a few frames, and fail on any runtime error.

Bug class this catches: a widget added through a variable that does not exist yet
(swapGroup:AddButton before `local swapGroup`). The main chunk aborts at that line, so
every tab built after it silently never appears - while compile and luau-analyze are clean.

    python3 sync/smoke.py games/Evade.lua

The mock surface is tuned for Evade (Drawing, Highlight, remotes, a fake character).
Other games in games/ need their own mocks before their FAIL means anything.
"""
import subprocess
import sys
from pathlib import Path

LUAU = "/tmp/luau/luau"
ROOT = Path(__file__).resolve().parent.parent

HARNESS = r"""
-- Minimal Roblox/executor surface so the authored Evade script can be executed
-- outside Roblox. Records every widget the script creates, so we can prove which
-- controls actually reach the menu.
local RECORD = { widgets = {}, tabs = {}, order = {} }
SPECS = {}
RECORD.log = function(...) end

local function mkEnum()
    -- Enum items need FromEnum/GetEnums the way Roblox exposes them: ui.lua maps
    -- saved key names back through Enum.KeyCode:FromEnum(...).
    local function mkItem(name, value)
        local item = { Name = name, Value = value, EnumType = nil }
        function item.FromValue(v) return mkItem(name, v) end
        return setmetatable(item, { __tostring = function() return name end })
    end
    return setmetatable({}, { __index = function(t, k)
        local items = {}
        local sub = {}
        function sub.GetEnumItems() return items end
        function sub.FromValue(v) return mkItem(k, v) end
        function sub.FromName(n) return mkItem(n, 0) end
        setmetatable(sub, { __index = function(_, name)
            local item = mkItem(name, #items + 1)
            table.insert(items, item)
            return item
        end })
        rawset(t, k, sub)
        return sub
    end })
end
Enum = mkEnum()
Font = {
    fromEnum = function(value) return { Enum = value, Name = tostring(value) } end,
    fromName = function(name) return { Name = name } end,
    new = function(...) return { Args = { ... } } end,
}

-- Properties scripts read before writing them (gradient.Rotation, ...).
local DEFAULTS = { Rotation = 0, Transparency = 0,
 AbsoluteSize = { X = 220, Y = 56 },
 AbsolutePosition = { X = 0, Y = 0 },
 AbsoluteContentSize = { X = 220, Y = 56 }, TextTransparency = 0, ImageTransparency = 0,
                   BackgroundTransparency = 0, TextSize = 14, Thickness = 1, Volume = 1,
                   ZIndex = 1, LayoutOrder = 0, Visible = true, Enabled = true,
                   TextBounds = { X = 42, Y = 16 } }

local newInstance
local OBJ = {}
-- Roblox GuiObjects expose their events as properties; without this list the
-- first :Connect() on a mock button kills the chunk.
local SIGNAL_NAMES = {}
for _, name in ipairs({
    "InputBegan", "InputChanged", "InputEnded", "MouseButton1Click", "MouseButton2Click",
    "Activated", "Focused", "FocusLost", "Changed", "Ended", "Touched", "TouchEnded",
    "AncestryChanged", "ChildAdded", "ChildRemoved", "DescendantAdded", "DescendantRemoving", "Destroying", "Touched", "TouchEnded", "MouseEnter", "MouseLeave", "SelectionChanged", "Deactivated",
    "CharacterAdded", "CharacterRemoving", "Died", "StateChanged", "Running", "Heartbeat",
    "RenderStepped", "Stepped", "PlayerAdded", "PlayerRemoving", "OnClientEvent",
    "OnServerEvent", "Completed", "PromptButtonHoldBegan", "Triggered", "TriggerEnded",
    "MouseEnter", "MouseLeave", "MouseMoved", "Deactivated", "DragBegin", "DragEnd",
    "MouseButton1Down", "MouseButton1Up", "MouseButton2Down", "MouseButton2Up",
    "DragStopped", "TouchTap", "TouchLongPress", "TouchPan", "TouchPinch",
    "TouchRotate", "TouchSwipe", "MouseWheelForward", "MouseWheelBackward",
    "DescendantRemoving", "ChildAdded", "Changed", "GetPropertyChangedSignal",
}) do SIGNAL_NAMES[name] = true end

OBJ.__index = function(self, k)
    local m = rawget(OBJ, "m_" .. k)
    if m then return m end
    local v = rawget(self, "_p")[k]
    if v ~= nil then return v end
    if SIGNAL_NAMES[k] then
        local s = newSignal()
        rawget(self, "_p")[k] = s
        return s
    end
    -- Dot-path module lookups (ReplicatedStorage.Objects.Game...) need a child
    -- that exists; only containers marked Permissive do this.
    local def = DEFAULTS[k]
    if def ~= nil then return def end
    if rawget(self, "_p").Permissive then
        local o = newInstance("Folder", k)
        o._p.Parent = self
        o._p.Permissive = true
        table.insert(rawget(self, "_p").Children, o)
        return o
    end
    return nil
end
OBJ.__newindex = function(self, k, v) rawget(self, "_p")[k] = v end

newInstance = function(class, name)
    local self = setmetatable({ _p = { ClassName = class, Name = name or class, Parent = nil, Children = {} } }, OBJ)
    return self
end

local function childOf(self, name)
    for _, c in ipairs(self._p.Children) do
        if c._p.Name == name then return c end
    end
    return nil
end

OBJ.m_FindFirstChild = function(self, name) return childOf(self, name) end
OBJ.m_WaitForChild = function(self, name)
    local c = childOf(self, name)
    if c then return c end
    local o = newInstance("Folder", name)
    o._p.Parent = self
    table.insert(self._p.Children, o)
    return o
end
OBJ.m_FindFirstChildOfClass = function(self, class)
    for _, c in ipairs(self._p.Children) do if c._p.ClassName == class then return c end end
end
OBJ.m_GetChildren = function(self) return self._p.Children end
OBJ.m_IsFocused = function() return false end
OBJ.m_CaptureFocus = function() end
OBJ.m_ReleaseFocus = function() end
OBJ.m_ClearAllChildren = function(self) self._p.Children = {} end
OBJ.m_IsDescendantOf = function() return true end
OBJ.m_GetAttributeChangedSignal = function() return newSignal() end
OBJ.m_TweenPosition = function() end
OBJ.m_TweenSize = function() end
OBJ.m_TweenSizeAndPosition = function() end
OBJ.m_FindFirstChildWhichIsA = function(self, class)
    for _, c in ipairs(self._p.Children) do
        if c._p.ClassName == class then return c end
    end
    return nil
end
OBJ.m_GetDescendants = function(self) return self._p.Children end
OBJ.m_IsA = function(self, class) return self._p.ClassName == class end
OBJ.m_Destroy = function(self) self._p.Destroyed = true end
OBJ.m_Clone = function(self) return newInstance(self._p.ClassName, self._p.Name) end
OBJ.m_GetAttribute = function(self, k) return (self._p.Attrs or {})[k] end
OBJ.m_SetAttribute = function(self, k, v) self._p.Attrs = self._p.Attrs or {}; self._p.Attrs[k] = v end
OBJ.m_GetPropertyChangedSignal = function(self) return newSignal() end
OBJ.m_GetDescendantsAsync = function(self) return self._p.Children end
OBJ.m_TranslateBy = function(self) end
OBJ.m_ChangeState = function(self) end
OBJ.m_FireServer = function(self) self.Fired = (self.Fired or 0) + 1 end
OBJ.m_Invoke = function(self) return nil end
OBJ.m_Play = function(self) end
OBJ.m_Remove = function(self) end
OBJ.m_GetPlayers = function(self) return {} end
OBJ.m_GetUserIdFromNameAsync = function(self) return 0 end
OBJ.m_GetNameFromUserIdAsync = function(self) return "" end
OBJ.m_Kick = function(self, msg) RECORD.kicked = msg end

function newSignal()
    local s = { handlers = {} }
    function s:Connect(fn) table.insert(self.handlers, fn); return { Disconnect = function() end } end
    function s:Wait()
    -- Roblox's :Wait() suspends the calling thread; returning immediately turns
    -- `while flag do Signal:Wait() end` into a busy loop that never ends.
    coroutine.yield()
    return 1 / 60
end
    function s:Once(fn) table.insert(self.handlers, fn) end
    s.Fire = function(self, ...) for _, fn in ipairs(self.handlers) do pcall(fn, ...) end end
    return s
end

-- Game modules (CharacterService, MovementModule, CameraService, ...) are
-- required by path inside the script; hand back a permissive stub so the menu
-- builds and callbacks stay callable.
-- A module stub has to behave like both a table and a function: the payload
-- reads fields (svc.Registry[key]) and calls methods (svc:Get()) off the same
-- value.
local function anyModule()
    local t = {}
    local mt = {}
    mt.__index = function(_, k)
        local v = anyModule()
        rawset(t, k, v)
        return v
    end
    mt.__call = function() return anyModule() end
    mt.__tostring = function() return "module" end
    return setmetatable(t, mt)
end
require = function() return anyModule() end

Instance = { new = function(class, parent)
    local o = newInstance(class)
    if parent then o._p.Parent = parent; table.insert(parent._p.Children, o) end
    return o
end }

local function service(name)
    local s = newInstance(name, name)
    s.ChildAdded = newSignal(); s.ChildRemoved = newSignal(); s.Heartbeat = newSignal()
    s.Stepped = newSignal(); s.RenderStepped = newSignal(); s.InputBegan = newSignal()
    s.InputEnded = newSignal(); s.InputChanged = newSignal(); s.PlayerAdded = newSignal()
    s.PlayerRemoving = newSignal(); s.OnClientEvent = newSignal(); s.Activated = newSignal()
    s.MouseButton1Click = newSignal(); s.CharacterAdded = newSignal(); s.Loaded = newSignal()
    s.Changed = newSignal()
    return s
end

local services = {}
local function get(name)
    services[name] = services[name] or service(name)
    return services[name]
end

get("GuiService").IsTenFootInterface = function() return false end
get("GuiService").TopbarInset = { Height = 36 }
get("RunService").IsStudio = function() return false end
get("UserInputService").TouchEnabled = false
get("UserInputService").MouseEnabled = true

local players = get("Players")
local lp = newInstance("Player", "Tester")
lp.Character = nil
lp.UserId = 1
lp.GetAttribute = OBJ.m_GetAttribute
lp.SetAttribute = OBJ.m_SetAttribute
lp.Idled = newSignal()
lp.PlayerGui = newInstance("PlayerGui", "PlayerGui")
lp.PlayerScripts = newInstance("PlayerScripts", "PlayerScripts")
players.LocalPlayer = lp
players.GetPlayers = function() return { lp } end
players.GetPlayerFromCharacter = function() return lp end
players.GetUserIdFromNameAsync = function() return 1 end

local rs = get("ReplicatedStorage")
rs.Permissive = true
local ws = get("Workspace")
ws.Gravity = 196.2
ws.CurrentCamera = newInstance("Camera", "Camera")
ws.CurrentCamera.FieldOfView = 70

game = newInstance("DataModel", "Game")
game.Workspace = ws
game.Players = players
game.GameId = GAME_ID
game.PlaceId = GAME_ID
game.IsLoaded = function() return true end
-- ui.lua animates with TweenService:Create(...):Play(); the mock has to hand back
-- a real tween object or the whole library aborts while building the window.
local TWEEN_SERVICE = {}
function TWEEN_SERVICE:Create()
    local tween = {}
    tween.Completed = newSignal()
    function tween.Play() return tween end
    function tween.Pause() return tween end
    function tween.Cancel() return tween end
    return tween
end
-- Configs round-trip through HttpService:JSONEncode -> writefile -> readfile ->
-- JSONDecode. Encoding for real and remembering the table per string keeps that
-- loop honest inside one process.
local JSON_MEMORY = {}
local function jsonEncode(value)
    local kind = type(value)
    if kind == "nil" then return "null" end
    if kind == "boolean" or kind == "number" then return tostring(value) end
    if kind == "string" then
        return '"' .. value:gsub('[%z\1-\31\\"]', function(c)
            return string.format("\\u%04x", c:byte())
        end) .. '"'
    end
    if kind == "table" then
        local parts = {}
        if #value > 0 then
            for _, item in ipairs(value) do table.insert(parts, jsonEncode(item)) end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        for key, item in pairs(value) do
            table.insert(parts, jsonEncode(tostring(key)) .. ":" .. jsonEncode(item))
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end
local HTTPSERVICE = {}
function HTTPSERVICE:JSONEncode(value)
    local text = jsonEncode(value)
    JSON_MEMORY[text] = value
    return text
end
function HTTPSERVICE:JSONDecode(text)
    if JSON_MEMORY[text] ~= nil then return JSON_MEMORY[text] end
    return {}
end
local TELEPORT_SERVICE = {}
function TELEPORT_SERVICE:TeleportToPlaceInstance() end
function TELEPORT_SERVICE:Teleport() end
function TELEPORT_SERVICE:TeleportAsync() end
local _getService = function(_, name) return get(name) end
game.GetService = function(self, name)
    if name == "TweenService" then return TWEEN_SERVICE end
    if name == "HttpService" then return HTTPSERVICE end
    if name == "TeleportService" then return TELEPORT_SERVICE end
    return _getService(self, name)
end
-- Real menu source, inlined by the runner: exercising the shipped ui.lua beats a
-- stand-in, because that is the code the user actually gets.
UI_SOURCE = __UI_SOURCE__
FBM_SOURCE = __FBM_SOURCE__
game.HttpGet = function(_, url)
    url = tostring(url)
    if url:find("ui%.lua") and type(UI_SOURCE) == "string" and #UI_SOURCE > 1024 then return UI_SOURCE end
    if url:find("FloatingButton") and type(FBM_SOURCE) == "string" and #FBM_SOURCE > 1024 then return FBM_SOURCE end
    return "return Library"
end

Workspace = ws
workspace = ws

PENDING = {}
task = {
    spawn = function(fn, ...)
        local co = coroutine.create(fn)
        table.insert(PENDING, co)
        local ok, err = coroutine.resume(co, ...)
        if not ok then table.insert(PENDING_ERRORS or {}, tostring(err)) end
    end,
    defer = function(fn, ...) task.spawn(fn, ...) end,
    delay = function(_, fn, ...) task.spawn(fn, ...) end,
    wait = function(t) coroutine.yield() return 0 end,
    cancel = function() end,
}
PENDING_ERRORS = {}
wait = function() coroutine.yield() return 0 end
-- Busy-wait loops (`while tick() - start < delay do end`) would hang the run on
-- real time; a fast clock makes them terminate in a bounded number of steps.
local FAKE_CLOCK = 0
local function fakeClock()
    FAKE_CLOCK = FAKE_CLOCK + 0.02
    return FAKE_CLOCK
end
tick = fakeClock
time = fakeClock
typeof = type
_PRINT = print
warn = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
    _PRINT("WARN " .. table.concat(parts, " "))
end

local C3 = {}
C3.__index = C3
local function c3(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, C3) end
C3.Lerp = function(a, b, t)
    return c3(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end
Color3 = { fromRGB = function(r, g, b) return c3((r or 0) / 255, (g or 0) / 255, (b or 0) / 255) end,
           new = function(r, g, b) return c3(r, g, b) end, fromHSV = function() return c3() end }
ColorSequence = { new = function() return {} end }
ColorSequenceKeypoint = { new = function(t, c) return { Time = t, Value = c } end }
NumberSequence = { new = function() return {} end }
NumberSequenceKeypoint = { new = function(t, v) return { Time = t, Value = v } end }
-- UDim2/UDim carry real fields and arithmetic: the payload animates sizes with
-- `+=` on .X.Scale, which a plain table cannot survive.
local UDIM2 = {}
UDIM2.__index = UDIM2
local function udim2(xs, xo, ys, yo)
    return setmetatable({ X = { Scale = xs or 0, Offset = xo or 0 }, Y = { Scale = ys or 0, Offset = yo or 0 } }, UDIM2)
end
UDIM2.__add = function(a, b)
    return udim2(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset)
end
UDIM2.__sub = function(a, b)
    return udim2(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset)
end
UDIM2.__mul = function(a, b)
    if type(b) == "number" then
        return udim2(a.X.Scale * b, a.X.Offset * b, a.Y.Scale * b, a.Y.Offset * b)
    end
    return udim2(a.X.Scale * b.X.Scale, a.X.Offset * b.X.Offset, a.Y.Scale * b.Y.Scale, a.Y.Offset * b.Y.Offset)
end
UDIM2.__div = function(a, b) return udim2(a.X.Scale / b, a.X.Offset / b, a.Y.Scale / b, a.Y.Offset / b) end
UDIM2.__tostring = function(a) return string.format("{%s, %s}, {%s, %s}", a.X.Scale, a.X.Offset, a.Y.Scale, a.Y.Offset) end
UDim2 = {
    new = function(a, b, c, d) return udim2(a, b, c, d) end,
    fromOffset = function(x, y) return udim2(0, x, 0, y) end,
    fromScale = function(x, y) return udim2(x, 0, y, 0) end,
}
local UDIM = {}
UDIM.__index = UDIM
local function udim(s, o) return setmetatable({ Scale = s or 0, Offset = o or 0 }, UDIM) end
UDIM.__add = function(a, b) return udim(a.Scale + b.Scale, a.Offset + b.Offset) end
UDIM.__sub = function(a, b) return udim(a.Scale - b.Scale, a.Offset - b.Offset) end
UDIM.__mul = function(a, b) return udim(a.Scale * b, a.Offset * b) end
UDim = {
    new = function(s, o) return udim(s, o) end,
    fromOffset = function(o) return udim(0, o) end,
    fromScale = function(s) return udim(s, 0) end,
}
local V2 = {}
V2.__index = V2
local function v2(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, V2) end
V2.__add = function(a, b) return v2(a.X + b.X, a.Y + b.Y) end
V2.__sub = function(a, b) return v2(a.X - b.X, a.Y - b.Y) end
V2.__mul = function(a, b)
    if type(b) == "number" then return v2(a.X * b, a.Y * b) end
    return v2(a.X * b.X, a.Y * b.Y)
end
V2.__div = function(a, b) return v2(a.X / b, a.Y / b) end
V2.Lerp = function(a, b, t) return v2(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t) end
Vector2 = { new = v2, zero = v2(0, 0), one = v2(1, 1) }
local V3 = {}
V3.__index = function(self, k)
    if k == "Magnitude" then
        return math.sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z)
    end
    if k == "Unit" then
        local m = math.sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z)
        if m == 0 then return v3(0, 0, 0) end
        return v3(self.X / m, self.Y / m, self.Z / m)
    end
    return V3[k]
end
local function v3(x, y, z)
    return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V3)
end
-- Roblox mixes Vector3 with CFrame/other types; a strict __add would abort the
-- whole feature, so unsupported operands pass through unchanged.
local function isVec3(b) return type(b) == "table" and b.X ~= nil end
V3.__add = function(a, b)
    if not isVec3(a) then return b end
    if not isVec3(b) then return a end
    return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
V3.__sub = function(a, b)
    if not isVec3(a) then return b end
    if not isVec3(b) then return a end
    return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
V3.__mul = function(a, b)
    if type(b) == "number" then return v3(a.X * b, a.Y * b, a.Z * b) end
    return v3(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V3.__div = function(a, b) return v3(a.X / b, a.Y / b, a.Z / b) end
V3.__eq = function(a, b) return a.X == b.X and a.Y == b.Y and a.Z == b.Z end
Vector3 = { new = v3, zero = v3(0, 0, 0), one = v3(1, 1, 1) }
CFrame = { new = function(...) return { Position = Vector3.new(0, 0, 0), LookVector = Vector3.new(0, 0, 0) } end,
           Angles = function() return {} end, fromEulerAnglesXYZ = function() return {} end }

RaycastParams = { new = function()
    return setmetatable({}, { __index = function() return nil end, __newindex = function(t, k, v) rawset(t, k, v) end })
end }
OverlapParams = { new = function() return {} end }
TweenInfo = { new = function() return {} end }
Ray = { new = function() return { Origin = Vector3.new(), Direction = Vector3.new() } end }
NumberRange = { new = function(a, b) return { Min = a, Max = b } end }
Rect = { new = function() return {} end }
BrickColor = { new = function() return {} end }
Random = { new = function() return { NextInteger = function() return 1 end, NextNumber = function() return 0 end } end }
Drawing = { new = function(kind)
    return setmetatable({ Kind = kind, Remove = function() end, Visible = true }, { __index = function() return function() end end })
end }
setfflag = function() return true end
firesignal = function() end
getgc = function() return {} end
readfile = function() return "" end
writefile = function() end
isfile = function() return false end
GENV = {}
getgenv = function() return GENV end
getrenv = function() return GENV end
hookfunction = function(a) return a end
request = nil

-- Mock menu library: records every widget the game script creates.
local function record(kind, tab, group, id, spec)
    table.insert(RECORD.widgets, { kind = kind, tab = tab, group = group, id = id,
        text = spec and (spec.Text or spec.Title) })
end
-- Fluent widgets are created empty and wired afterwards with :OnChanged(fn), so
-- the mock has to keep those handlers: driving only spec.Callback would leave
-- most of the payload's features untested.
WIDGETS = {}
local function mkWidget(kind, tab, group, id, spec)
    local w = { Kind = kind, Id = id, Spec = spec or {}, Handlers = {} }
    function w:OnChanged(fn) table.insert(self.Handlers, fn) return self end
    function w:OnClick(fn) table.insert(self.Handlers, fn) return self end
    function w:OnChanged2(fn) table.insert(self.Handlers, fn) return self end
    function w:SetValue(value)
        for _, fn in ipairs(self.Handlers) do pcall(fn, value) end
        if self.Spec.Callback then pcall(self.Spec.Callback, value) end
    end
    function w:Set(value) return self:SetValue(value) end
    function w:SetText() end
    function w:SetBadge() end
    function w:AddKeyPicker() return self end
    function w:AddColorPicker() return self end
    table.insert(WIDGETS, w)
    return w
end
local function mkContainer(tabName, groupName)
    local c = {}
    for _, kind in ipairs({ "Toggle", "Slider", "Input", "Dropdown", "Keybind", "Button", "ColorPicker", "Label", "Paragraph", "Divider", "Section", "Stepper", "RangeSlider", "Segmented" }) do
        c["Add" .. kind] = function(self, id, spec)
            local key = id
            if type(id) == "table" then key, spec = nil, id end
            record(kind, tabName, groupName, key, spec)
            local w = mkWidget(kind, tabName, groupName, key, spec)
            if key then SPECS[key] = spec end
            return w
        end
    end
    return c
end
__MOCK_LIBRARY = {}
function __MOCK_LIBRARY:CreateWindow()
    local win = { Tabs = {} }
    function win:AddTab(name, icon, desc)
        local t = { Name = name }
        table.insert(RECORD.tabs, name)
        function t:AddLeftGroupbox(gname) return mkContainer(name, gname) end
        function t:AddRightGroupbox(gname) return mkContainer(name, gname) end
        function t:AddGroupbox(gname) return mkContainer(name, gname) end
        function t:Select() end
        function t:AddSection() return mkContainer(name, "section") end
        setmetatable(t, { __index = function() return function() return mkContainer(name, "?") end end })
        return t
    end
    setmetatable(win, { __index = function() return function() return mkContainer("?", "?") end end })
    function win:SelectTab() end
    function win:Dialog() end
    function win:Toggle() end
    function win:Unload() end
    return win
end
setmetatable(__MOCK_LIBRARY, { __index = function() return function() return __MOCK_LIBRARY end end })
Library = __MOCK_LIBRARY

-- Capture the real library instance: the script loadstrings ui.lua and keeps the
-- result local, so the harness wraps loadstring to grab it on the way out.
CAPTURED = {}
do
    local raw = loadstring
    loadstring = function(src, name)
        local fn = raw(src, name)
        if type(src) == "string" and src:find("return Library", 1, true) and type(fn) == "function" then
            return function(...)
                local lib = fn(...)
                if type(lib) == "table" then CAPTURED.Library = lib end
                return lib
            end
        end
        return fn
    end
end

-- The chunk must run inside a coroutine: hub files call task.wait() in the main body, and
-- yielding the main thread is a hard error in Luau.
local chunk, cerr = loadstring(SCRIPT_SOURCE, "evade")
if not chunk then _PRINT("RUNTIME ERROR: COMPILE: " .. tostring(cerr)) end
MAIN = coroutine.create(chunk)
do
    local ok, err = coroutine.resume(MAIN)
    if not ok then _PRINT("RUNTIME ERROR: " .. tostring(err)) end
end
-- Builders yield on task.wait() between sections; keep resuming until the menu
-- is fully built, or the chunk stops making progress.
DRAIN_ERRORS = {}
for _ = 1, 600 do
    if coroutine.status(MAIN) ~= "suspended" then break end
    local ok, err = coroutine.resume(MAIN)
    if not ok then
        table.insert(DRAIN_ERRORS, tostring(err))
        break
    end
end
for _, e in ipairs(DRAIN_ERRORS) do _PRINT("BUILD ERROR " .. e) end

_PRINT("kicked: " .. tostring(RECORD.kicked))
_PRINT("tabs: " .. table.concat(RECORD.tabs, ", "))
_PRINT("widgets: " .. tostring(#RECORD.widgets))
local perTab = {}
for _, w in ipairs(RECORD.widgets) do
    perTab[w.tab] = (perTab[w.tab] or 0) + 1
end
for tab, n in pairs(perTab) do _PRINT(string.format("  %-10s %d", tab, n)) end
local ids = {}
for _, w in ipairs(RECORD.widgets) do
    if w.id then
        if ids[w.id] then _PRINT("DUPLICATE ID: " .. w.id) end
        ids[w.id] = true
    end
end

local byTab = {}
for _, w in ipairs(RECORD.widgets) do
    byTab[w.tab] = byTab[w.tab] or {}
    local g = w.group or "?"
    byTab[w.tab][g] = byTab[w.tab][g] or {}
    table.insert(byTab[w.tab][g], w.kind .. ":" .. tostring(w.id or w.text))
end
for _, want in ipairs({}) do
    _PRINT("==== " .. want .. " ====")
    for g, list in pairs(byTab[want] or {}) do
        _PRINT("  [" .. g .. "]")
        _PRINT("    " .. table.concat(list, " | "))
    end
end



-- ============ functional phase: drive every control, then run frames ============
local function mkPart(name)
    local p = newInstance("Part", name)
    p.Position = Vector3.new(0, 5, 0)
    p.CFrame = CFrame.new()
    p.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    p.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    p.CanCollide = true
    p.Size = Vector3.new(1, 1, 1)
    p.Velocity = Vector3.new(0, 0, 0)
    return p
end
local char = newInstance("Model", "Tester")
local hum = newInstance("Humanoid", "Humanoid")
hum.WalkSpeed = 16; hum.JumpPower = 50; hum.JumpHeight = 7.2; hum.HipHeight = 2
hum.MoveDirection = Vector3.new(0, 0, 0)
hum.GetState = function() return Enum.HumanoidStateType.Running end
hum.ChangeState = function() end
hum.GetStateEnabled = function() return true end
hum.SetStateEnabled = function() end
hum.PlatformStand = false
local hrp = mkPart("HumanoidRootPart")
local head = mkPart("Head")
char.PrimaryPart = hrp
table.insert(char._p.Children, hum); hum._p.Parent = char
table.insert(char._p.Children, hrp); hrp._p.Parent = char
table.insert(char._p.Children, head); head._p.Parent = char
char._p.Parent = ws
lp.Character = char
table.insert(lp._p.Children, char)

local uis = get("UserInputService")
uis.IsKeyDown = function() return false end
uis.GetFocusedTextBox = function() return nil end
local vu = get("VirtualUser")
vu.CaptureController = function() end
vu.ClickButton2 = function() end
vu.KeyPress = function() end
vu.Move = function() end
local cg = get("CoreGui")
table.insert(ws._p.Children, char)

local errors = {}
-- Callbacks may yield (task.wait inside a toggle handler); run each in its own
-- coroutine and hand the survivors to the frame loop.
local function try(label, fn)
    local co = coroutine.create(fn)
    local ok, err = coroutine.resume(co)
    if not ok then table.insert(errors, label .. " -> " .. tostring(err)) end
    if coroutine.status(co) == "suspended" then table.insert(PENDING, co) end
end

-- 1. drive every widget: its creation callback and every :OnChanged handler
local function valueFor(kind, spec)
    if kind == "Toggle" then return true end
    if kind == "Slider" then return spec.Default or spec.Min or 50 end
    if kind == "Input" then return spec.Default or "1" end
    if kind == "Dropdown" then return (spec.Values and spec.Values[1]) or "1" end
    if kind == "Keybind" then return true end
    if kind == "ColorPicker" then return { R = 1, G = 1, B = 1 } end
    return nil
end
local TRACE = rawget(_G, "SMOKE_TRACE")
local fired = 0

-- Real-library mode: drive every option the shipped ui.lua registered. The mock
-- recorder only sees widgets built through the stand-in library.
local LIB = CAPTURED.Library
if LIB and type(LIB.Options) == "table" then
    local total, driven = 0, 0
    for id, opt in pairs(LIB.Options) do
        total += 1
        if type(opt) == "table" and type(opt.SetValue) ~= "function" then
            _PRINT("option without SetValue: " .. tostring(id) .. " (" .. type(opt) .. ")")
        end
        if type(opt) == "table" and type(opt.SetValue) == "function" then
            local value
            local kind = type(opt.Value)
            if type(opt.Values) == "table" and #opt.Values > 0 then
                value = opt.Values[1]
            elseif kind == "boolean" then
                value = true
            elseif kind == "number" then
                value = opt.Default or opt.Value
            elseif kind == "string" then
                value = (type(opt.Default) == "string" and opt.Default ~= "") and opt.Default or "1"
            end
            if value ~= nil then
                local before = #errors
                try("option " .. tostring(id), function() opt:SetValue(value) end)
                if #errors == before then driven += 1 end
            end
        end
    end
    _PRINT("library: real ui.lua buttons=" .. type(LIB.Buttons) .. " tabs=" .. type(LIB.Tabs))
    _PRINT("options: " .. tostring(total) .. " driven: " .. tostring(driven))
    if type(LIB.Buttons) == "table" then
        local pressed = 0
        for _, button in ipairs(LIB.Buttons) do
            if type(button.Click) == "function" then
                try("button " .. tostring(button.Info and (button.Info.Text or button.Info.Title)), function() button:Click() end)
                pressed += 1
            end
        end
        _PRINT("buttons pressed: " .. tostring(pressed) .. " / " .. tostring(#LIB.Buttons))
    end
    if type(LIB.Tabs) == "table" then _PRINT("tabs: " .. tostring(#LIB.Tabs)) end
end

for _, w in ipairs(WIDGETS) do
    if TRACE then _PRINT("drive " .. tostring(w.Kind) .. ":" .. tostring(w.Id) .. string.rep(" ", 600)) end
    local value = valueFor(w.Kind, w.Spec)
    if w.Kind == "Button" then
        if w.Spec.Func then try("button " .. tostring(w.Spec.Text), w.Spec.Func); fired += 1 end
        if w.Spec.Callback then try("button " .. tostring(w.Spec.Text), w.Spec.Callback); fired += 1 end
        for _, fn in ipairs(w.Handlers) do try("button handler " .. tostring(w.Spec.Text), fn); fired += 1 end
    elseif value ~= nil then
        if w.Spec.Callback then
            try(w.Kind:lower() .. " " .. tostring(w.Id), function() w.Spec.Callback(value) end); fired += 1
        end
        for _, fn in ipairs(w.Handlers) do
            try(w.Kind:lower() .. " " .. tostring(w.Id), function() fn(value) end); fired += 1
        end
    end
end
local wired = 0
for _, w in ipairs(WIDGETS) do
    if #w.Handlers > 0 or w.Spec.Callback or w.Spec.Func then wired += 1 end
end
_PRINT("widgets wired: " .. tostring(wired) .. " / " .. tostring(#WIDGETS))
_PRINT("controls fired: " .. tostring(fired))

-- 2. run frames: 3 of each signal, the way the client would
local signals = {}
for name, svc in pairs(services) do
    for _, sig in ipairs({ "Heartbeat", "RenderStepped", "Stepped" }) do
        if svc[sig] and #svc[sig].handlers > 0 then table.insert(signals, { name = name .. "." .. sig, sig = svc[sig] }) end
    end
end
local frames = 0
for round = 1, 3 do
    if MAIN and coroutine.status(MAIN) == "suspended" then
        local ok, err = coroutine.resume(MAIN)
        if not ok then table.insert(errors, "main -> " .. tostring(err)); MAIN = nil end
    end
    for i = #PENDING, 1, -1 do
        local co = PENDING[i]
        if coroutine.status(co) == "dead" then table.remove(PENDING, i)
        else
            local ok, err = coroutine.resume(co)
            if not ok then table.insert(errors, "task -> " .. tostring(err)); table.remove(PENDING, i) end
        end
    end
    for _, s in ipairs(signals) do
        for _, fn in ipairs(s.sig.handlers) do
            local ok, err = pcall(fn, 1 / 60)
            frames += 1
            if not ok then table.insert(errors, s.name .. " frame -> " .. tostring(err)) end
        end
    end
end
_PRINT("frame handlers run: " .. tostring(frames))
_PRINT("main chunk: " .. tostring(MAIN and coroutine.status(MAIN) or "done"))
_PRINT("errors: " .. tostring(#errors))
local seen = {}
for _, e in ipairs(errors) do
    if not seen[e] then seen[e] = true; _PRINT("  ERR " .. e) end
end
"""


def lua_long(text: str) -> str:
    level = 0
    while "]" + "=" * level + "]" in text:
        level += 1
    return "[" + "=" * level + "[" + text + "]" + "=" * level + "]"


def main() -> int:
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "games" / "Evade.lua"
    if not target.is_absolute():
        target = (Path.cwd() / target).resolve()
    src = target.read_text(encoding="utf-8")
    level = 0
    while "]" + "=" * level + "]" in src:
        level += 1
    # Feed the harness the id the file's own guard expects, so the guard does not kick us.
    import re
    guard = re.search(r"game\.(?:GameId|PlaceId) ~= (\d+)", src)
    game_id = guard.group(1) if guard else "3647333358"
    script = HARNESS.replace("SCRIPT_SOURCE", "[" + "=" * level + "[" + src + "]" + "=" * level + "]")
    script = script.replace("GAME_ID", game_id)
    script = script.replace("__UI_SOURCE__", lua_long((ROOT / "ui.lua").read_text(encoding="utf-8")))
    fbm_path = ROOT / "FloatingButton.lua"
    fbm = fbm_path.read_text(encoding="utf-8") if fbm_path.exists() else ""
    script = script.replace("__FBM_SOURCE__", lua_long(fbm))
    run = Path("/tmp") / ("smoke_" + target.stem.replace(" ", "_") + ".lua")
    run.write_text(script, encoding="utf-8")

    proc = subprocess.run([LUAU, str(run)], capture_output=True, text=True, timeout=300)
    out = proc.stdout
    print("\n".join(l for l in out.splitlines() if not l.startswith("W|")))
    if proc.stderr.strip():
        print("stderr: " + proc.stderr.strip()[:2000])

    has_options = "options: " in out and "driven: 0" not in out
    has_widgets = "widgets: 0" not in out and "widgets wired: 0 / 0" not in out
    bad = ("RUNTIME ERROR" in out) or ("errors: 0" not in out) or not (has_options or has_widgets)
    print("SMOKE " + ("FAIL " + str(target) if bad else "PASS " + str(target)))
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
