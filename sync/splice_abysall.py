#!/usr/bin/env python3
"""Splice the Abysall feature layer into sync/extra/games/Doors.lua.

Abysall (therealcookiemonsterof1966/AbysallContinued) ships its Doors hub as one
monolithic Luau file: helper functions, then 200 UI controls whose callbacks are the
features. Its UI is Obsidian Library; ours is API-compatible (CreateWindow, AddTab,
AddLeftGroupbox, Container:AddToggle(idx, info), Library.Options/Toggles, Notify), so
the feature layer transplants instead of being retyped.

What this script does:
  * takes Abysall lines 90..end (helpers + every control + every callback)
  * rebinds its Library/Window to ours
  * namespaces every option idx with `ab_` so its 216 controls cannot overwrite ours
  * replaces the two Abysall component fetches (SaveManager, ThemeManager) with stubs
  * drops its own CreateWindow / ApplyInfoTab
  * wraps the whole block in `do ... end` so its ~200 locals stay private
"""
import json
import re
import sys

ABY = '/tmp/doorssrc/abysall_doors.luau'
TARGET = '/home/ubuntu/reicht-hub/sync/extra/games/Doors.lua'
MARK_BEGIN = '-- ===== ABYSALL FEATURE LAYER BEGIN ====='
MARK_END = '-- ===== ABYSALL FEATURE LAYER END ====='

src = open(ABY, encoding='utf-8', errors='replace').read()
lines = src.split('\n')
chunk = '\n'.join(lines[89:])          # line 90 onward: helpers + controls + callbacks

# ---------------------------------------------------------------- option namespacing
controls = json.load(open('/tmp/abysall_controls.json'))
names = sorted({c['name'] for c in controls if c['name']}, key=len, reverse=True)
nameset = set(names)

# 1. definitions: Groupbox:AddToggle("Name", {
kind_re = re.compile(r':(Add(?:Toggle|Slider|Dropdown|Button|Input|ColorPicker|Keybind))\(\s*"([A-Za-z0-9_]+)"')
def _def(m):
    kind, name = m.group(1), m.group(2)
    return ':%s("ab_%s"' % (kind, name) if name in nameset else m.group(0)
chunk, n_def = kind_re.subn(_def, chunk)

# 2. references: Toggles.Name / Options.Name / Library.Options.Name
ref_re = re.compile(r'\b(Toggles|Options)\.([A-Za-z0-9_]+)')
def _ref(m):
    head, name = m.group(1), m.group(2)
    return '%s.ab_%s' % (head, name) if name in nameset else m.group(0)
chunk, n_ref = ref_re.subn(_ref, chunk)

# 3. bracket references: Options["Name"]
br_re = re.compile(r'\b(Toggles|Options)\[\s*"([A-Za-z0-9_]+)"\s*\]')
def _br(m):
    head, name = m.group(1), m.group(2)
    return '%s["ab_%s"]' % (head, name) if name in nameset else m.group(0)
chunk, n_br = br_re.subn(_br, chunk)

# ---------------------------------------------------------------- rebind + strip
chunk = chunk.replace('local Library = Abysall.Interface.Library',
                      'local Library = ReichtLibrary')
chunk = chunk.replace('local SaveManager = Abysall.Interface.SaveManager',
                      'local SaveManager = ReichtStubs.SaveManager')
chunk = chunk.replace('local ThemeManager = Abysall.Interface.ThemeManager',
                      'local ThemeManager = ReichtStubs.ThemeManager')

# its own window: from `local Window = Library:CreateWindow({` to the matching `})`
win = re.search(r'local Window = Library:CreateWindow\(\{.*?\n\}\)', chunk, re.S)
if not win:
    sys.exit('window block not found')
chunk = chunk.replace(win.group(0), 'local Window = ReichtWindow')
chunk = chunk.replace('Abysall.Interface.ApplyInfoTab(Window)', '-- info tab: Reicht ships its own')
chunk = re.sub(r'Abysall\.Interface\.ApplySettingsTab\(Window\)', '-- settings tab: Reicht ships its own', chunk)

# Abysall's start-up gate spins `while not Character or not Rooms:FindFirstChildOfClass(
# "Model") do task.wait() end` and then sleeps 4s. Unbounded, that never returns when the
# game (or the harness) never hands over a room, and every control below it stays
# unregistered -- the whole feature layer silently does nothing. Bound it on a deadline.
bounded_gate = re.compile(
    r'if not LocalPlayer\.Character or not CurrentRooms:FindFirstChildOfClass\("Model"\) then'
    r'.*?\nend\n', re.S)
gate_repl = (
    'if not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") then\n'
    '    Functions.Notify({ Title = "Waiting for the game to load..." })\n'
    '    for _ = 1, 150 do\n'
    '        if LocalPlayer.Character and CurrentRooms:FindFirstChildOfClass("Model") then break end\n'
    '        task.wait()\n'
    '    end\n'
    '    task.wait(4)\n'
    'end\n')
chunk, n_gate = bounded_gate.subn(gate_repl, chunk, count=1)
if n_gate != 1:
    sys.exit('start-up gate not found')

# `<expr>.Played:Once(function() ... end)` walks a child chain the server may not have
# replicated yet (Object -> Main -> SoundToPlay -> Played). One nil link throws away the
# rest of the object handler, so each such registration runs inside pcall.
def guard_played(source):
    lines = source.split('\n')
    out, i, guarded = [], 0, 0
    while i < len(lines):
        line = lines[i]
        if '.Played:Once(function()' in line:
            indent = line[:len(line) - len(line.lstrip())]
            close = indent + 'end)'
            depth_end = i + 1
            while depth_end < len(lines) and lines[depth_end] != close:
                depth_end += 1
            if depth_end < len(lines):
                out.append(indent + 'pcall(function()')
                out.extend(lines[i:depth_end + 1])
                out.append(indent + 'end)')
                guarded += 1
                i = depth_end + 1
                continue
        out.append(line)
        i += 1
    print('played guards:', guarded)
    return '\n'.join(out)

chunk = guard_played(chunk)

# Room attributes only exist once the server has streamed the room in; `CurrentRoom + 1`
# on a nil attribute throws inside the ESP frame handler and the object never gets ESP.
chunk = chunk.replace(
    'ObjectRoom == CurrentRoom + 1',
    'ObjectRoom == (CurrentRoom or 0) + 1')

# The lever sound that tears the ESP down lives under a child the server may not have
# replicated yet; a nil index there throws away the rest of the objective handler.
chunk = chunk.replace(
    '\t\t\t\tObject:WaitForChild("Main").SoundToPlay.Played:Once(function()\n'
    '\t\t\t\t\tFunctions.RemoveESP(Object)\n'
    '\t\t\t\t\tFunctions.BlacklistESP(Object)\n'
    '\t\t\t\tend)',
    '\t\t\t\tdo\n'
    '\t\t\t\t\tlocal GateSound = Object:WaitForChild("Main")\n'
    '\t\t\t\t\tlocal SoundToPlay = GateSound and GateSound:FindFirstChild("SoundToPlay")\n'
    '\t\t\t\t\tif SoundToPlay and SoundToPlay.Played then\n'
    '\t\t\t\t\t\tSoundToPlay.Played:Once(function()\n'
    '\t\t\t\t\t\t\tFunctions.RemoveESP(Object)\n'
    '\t\t\t\t\t\t\tFunctions.BlacklistESP(Object)\n'
    '\t\t\t\t\t\tend)\n'
    '\t\t\t\t\tend\n'
    '\t\t\t\tend')

# `while not Globals.MainUI do task.wait() end` gates the last few lines of the layer on
# the game's own GUI root. When that root never appears -- a room that has not streamed,
# or the harness -- the loop spins forever and everything after it (the settings tab, the
# loaded notification, the call site itself) never runs. Bound it.
chunk = chunk.replace(
    'while not Globals.MainUI do task.wait() end',
    'do local MainUIDeadline = os.clock() + 5\n'
    '   for _ = 1, 300 do if Globals.MainUI then break end task.wait() end end')

# Cosmetic Obsidian-only widgets Reicht's library does not implement. Each is a banner,
# not a feature, and stripping it keeps the rest of the tab registering.
chunk = re.sub(r'Tabs\.\w+:UpdateWarningBox\(\{.*?\n\}\)\n', '', chunk, flags=re.S)

import os
if os.environ.get('ABY_DEBUG'):
    # Debug aid: mark every original top-level statement so a hang can be located.
    marked = []
    depth = 0
    n_mark = 0
    for ln in chunk.split('\n'):
        stripped = ln.strip()
        opens = stripped.count('{') + stripped.count('(') + stripped.count('[')
        closes = stripped.count('}') + stripped.count(')') + stripped.count(']')
        starts_clean = stripped and not stripped.startswith(('--', 'end', 'else', '}', ')', ']', 'until'))
        if depth == 0 and ln and not ln[0].isspace() and starts_clean:
            n_mark += 1
            marked.append('print("ABY_AT %d")' % n_mark)
        marked.append(ln)
        depth += opens - closes
        if depth < 0:
            depth = 0
    chunk = '\n'.join(marked)

body = '\n'.join('    ' + ln if ln.strip() else ln for ln in chunk.split('\n'))

shim = r'''
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
'''

# Luau caps a function at 200 registers; the feature layer's ~60 top-level locals on
# top of Doors.lua's own would blow the main chunk, so it gets its own frame. The
# definition has to sit above `local function Run()` to be in lexical scope, and the
# call has to sit at the end of Run()'s body -- code appended past the closing xpcall
# never executes, because the harness resumes the chunk only until it stops yielding.
definition = (MARK_BEGIN + '\n'
              + 'local __abysallLayer = function(ReichtLibrary, ReichtWindow)\n'
              + shim + '\n'
              + body + '\n'
              + 'end\n'
              + MARK_END + '\n')
call = '\n    __abysallLayer(Library, Window)\n'
if os.environ.get('ABY_DEBUG'):
    # audit hook: how many options the layer actually registered
    call += ('    do local n = 0 for _ in pairs(Library.Options or {}) do n = n + 1 end\n'
             '       print("ABY_OPTS " .. tostring(n)) end\n')

target = open(TARGET, encoding='utf-8').read()
# drop any previous splice so re-running is idempotent
prev = re.search(re.escape(MARK_BEGIN) + r'.*?' + re.escape(MARK_END) + r'\n', target, re.S)
if prev:
    target = target.replace(prev.group(0), '')
target = re.sub(r'\n    __abysallLayer\(Library, Window\)\n    do local n = 0 for _ in pairs\(Library\.Options or \{\}\) do n = n \+ 1 end\n       print\("ABY_OPTS " \.\. tostring\(n\)\) end\n', '\n', target)

RUN_MARK = 'local function Run()\n'
if RUN_MARK not in target:
    sys.exit('Run() not found')
target = target.replace(RUN_MARK, definition + '\n' + RUN_MARK, 1)

TAIL_MARK = 'Script.Functions.UpdateRPC()\ngetgenv().lonelyhub_loaded = true\n'
if TAIL_MARK not in target:
    sys.exit('Run() tail not found')
target = target.replace(TAIL_MARK, call.lstrip('\n') + TAIL_MARK, 1)
open(TARGET, 'w', encoding='utf-8').write(target)

print('defs prefixed: %d | refs prefixed: %d | bracket refs: %d' % (n_def, n_ref, n_br))
print('chunk bytes: %d | layer bytes: %d' % (len(chunk), len(definition)))
print('target bytes: %d' % len(target))
