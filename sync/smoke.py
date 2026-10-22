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
    return setmetatable({}, { __index = function(t, k)
        local sub = setmetatable({}, { __index = function(_, name)
            local item = setmetatable({ Name = name, Value = 0 }, { __tostring = function() return name end })
            return item
        end })
        rawset(t, k, sub)
        return sub
    end })
end
Enum = mkEnum()

local OBJ = {}
OBJ.__index = function(self, k)
    local m = rawget(OBJ, "m_" .. k)
    if m then return m end
    local v = rawget(self, "_p")[k]
    if v ~= nil then return v end
    return nil
end
OBJ.__newindex = function(self, k, v) rawget(self, "_p")[k] = v end

local function newInstance(class, name)
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
OBJ.m_WaitForChild = function(self, name) return childOf(self, name) end
OBJ.m_FindFirstChildOfClass = function(self, class)
    for _, c in ipairs(self._p.Children) do if c._p.ClassName == class then return c end end
end
OBJ.m_GetChildren = function(self) return self._p.Children end
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
    function s:Wait() return nil end
    function s:Once(fn) table.insert(self.handlers, fn) end
    s.Fire = function(self, ...) for _, fn in ipairs(self.handlers) do pcall(fn, ...) end end
    return s
end

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
players.LocalPlayer = lp
players.GetPlayers = function() return { lp } end
players.GetPlayerFromCharacter = function() return lp end
players.GetUserIdFromNameAsync = function() return 1 end

local rs = get("ReplicatedStorage")
local ws = get("Workspace")
ws.Gravity = 196.2
ws.CurrentCamera = newInstance("Camera", "Camera")
ws.CurrentCamera.FieldOfView = 70

game = newInstance("DataModel", "Game")
game.GameId = GAME_ID
game.PlaceId = GAME_ID
game.IsLoaded = function() return true end
game.GetService = function(_, name) return get(name) end
game.HttpGet = function(_, url)
    -- The script validates the tail and loadstrings the body, expecting Library back.
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
tick = os.clock
typeof = type
warn = function() end
_PRINT = print

Color3 = { fromRGB = function(r, g, b) return { R = r, G = g, B = b } end, new = function(r,g,b) return {R=r,G=g,B=b} end, fromHSV = function() return {} end }
ColorSequence = { new = function() return {} end }
NumberSequence = { new = function() return {} end }
UDim2 = { new = function(...) return { ... } end, fromOffset = function(x, y) return { x, y } end, fromScale = function(x, y) return { x, y } end }
UDim = { new = function(...) return { ... } end, fromOffset = function(x) return x end, fromScale = function(x) return x end }
Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end, zero = { X = 0, Y = 0 } }
local V3 = {}
V3.__index = V3
local function v3(x, y, z)
    return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V3)
end
V3.__add = function(a, b) return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V3.__sub = function(a, b) return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
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
local function mkContainer(tabName, groupName)
    local c = {}
    for _, kind in ipairs({ "Toggle", "Slider", "Input", "Dropdown", "Keybind", "Button", "ColorPicker", "Label", "Paragraph", "Divider", "Section", "Stepper", "RangeSlider", "Segmented" }) do
        c["Add" .. kind] = function(self, id, spec)
            if kind == "Button" or kind == "Label" or kind == "Paragraph" or kind == "Divider" or kind == "Section" then
                record(kind, tabName, groupName, nil, id)
                if type(id) == "table" then SPECS["btn:" .. (id.Text or tostring(#RECORD.widgets))] = id end
                return { SetText = function() end, OnChanged = function() end }
            end
            if type(id) == "table" then record(kind, tabName, groupName, nil, id); return { SetValue = function() end, OnChanged = function() end } end
            record(kind, tabName, groupName, id, spec)
            SPECS[id] = spec
            return { SetValue = function() end, Set = function() end, OnChanged = function() end,
                     SetBadge = function() end, AddKeyPicker = function() end, AddColorPicker = function() end }
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

local ok, err = pcall(function()
    local chunk, cerr = loadstring(SCRIPT_SOURCE, "evade")
    if not chunk then error("COMPILE: " .. tostring(cerr), 0) end
    chunk()
end)
if not ok then _PRINT("RUNTIME ERROR: " .. tostring(err)) end

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
local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then table.insert(errors, label .. " -> " .. tostring(err)) end
end

-- 1. turn every toggle on, fill every input, pick every dropdown, press every button
local fired = 0
for _, w in ipairs(RECORD.widgets) do
    if w.id and SPECS[w.id] then
        local spec = SPECS[w.id]
        if w.kind == "Toggle" and spec.Callback then
            try("toggle " .. w.id, function() spec.Callback(true) end); fired += 1
        elseif w.kind == "Slider" and spec.Callback then
            try("slider " .. w.id, function() spec.Callback(spec.Default or 50) end); fired += 1
        elseif w.kind == "Input" and spec.Callback then
            try("input " .. w.id, function() spec.Callback(spec.Default or "1") end); fired += 1
        elseif w.kind == "Dropdown" and spec.Callback then
            local v = spec.Values and spec.Values[1] or "1"
            try("dropdown " .. w.id, function() spec.Callback(v) end); fired += 1
        elseif w.kind == "Keybind" and spec.Callback then
            try("keybind " .. w.id, function() spec.Callback(true) end); fired += 1
        end
    end
end
for key, spec in pairs(SPECS) do
    if key:sub(1, 4) == "btn:" and spec.Func then
        try("button " .. key, spec.Func); fired += 1
    end
end
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
_PRINT("errors: " .. tostring(#errors))
local seen = {}
for _, e in ipairs(errors) do
    if not seen[e] then seen[e] = true; _PRINT("  ERR " .. e) end
end
"""


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
    run = Path("/tmp") / ("smoke_" + target.stem.replace(" ", "_") + ".lua")
    run.write_text(script, encoding="utf-8")

    proc = subprocess.run([LUAU, str(run)], capture_output=True, text=True, timeout=300)
    out = proc.stdout
    print("\n".join(l for l in out.splitlines() if not l.startswith("W|")))
    if proc.stderr.strip():
        print("stderr: " + proc.stderr.strip()[:2000])

    bad = ("RUNTIME ERROR" in out) or ("errors: 0" not in out) or ("widgets: 0" in out)
    print("SMOKE " + ("FAIL " + str(target) if bad else "PASS " + str(target)))
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
