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
import os
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
                   -- ProximityPrompt fields the reach multiplier multiplies. Absent
                   -- here, `prompt.MaxActivationDistance * value` was nil * number:
                   -- the grab-from-distance slider errored inside OnChanged and every
                   -- run reported the feature as fine because nothing was observed.
                   MaxActivationDistance = 10, HoldDuration = 0.4,
                   TextBounds = { X = 42, Y = 16 },
                   Position = { X = { Scale = 0, Offset = 0 }, Y = { Scale = 0, Offset = 0 } },
                   AnchorPoint = { X = 0, Y = 0 } }

-- Remote traffic is the only proof that a feature reaches the game server: a
-- callback that runs clean but fires nothing is a dead feature. Names carry their
-- first argument so Interact("Revive") is distinguishable from Interact("Carry").
TRACE = { fire = {}, made = {}, wrote = {} }
SUSPECT = {}
-- The buckets are also the proof source, so a cap silently truncates evidence:
-- once ESP name plates are traced alongside game state, the interesting writes
-- land past 4000 and a feature that ran looks dead. Keep it high; the entries are
-- short strings and one run is one process.
local TRACE_CAP = 200000
-- Harness gap #13. The mock used to answer WaitForChild with a freshly fabricated
-- Folder for any name, so a lookup that has no deadline in the live game always
-- looked instant here. In Roblox an unresolved WaitForChild parks the thread
-- forever: no menu, no error, nothing to read -- exactly the "script does not
-- load" report this flag exists to reproduce. REICHT_STRICT_WFC=1 makes the mock
-- honest: names that were never seeded do not exist.
local STRICT_WFC = __STRICT_WFC__
-- Names the live game may have renamed. REICHT_WFC_MISS="GameData,MainUI" makes
-- those lookups fail here exactly as they would in game, so a fix for "the script
-- does not load" can be proven against the build that had the bug.
local WFC_MISS = __WFC_MISS__
local HTTP_BLOCK = __HTTP_BLOCK__
local function bump(bucket, key)
    if #bucket > TRACE_CAP then return end
    table.insert(bucket, key)
end

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
    "PromptTriggered", "PromptButtonHoldEnded", "PromptShown", "PromptHidden", "OnTeleport",
    "PromptButtonHoldBegan", "PromptButtonHoldEnded", "Activated", "StateChanged",
    "MouseEnter", "MouseLeave", "MouseMoved", "Deactivated", "DragBegin", "DragEnd",
    "MouseButton1Down", "MouseButton1Up", "MouseButton2Down", "MouseButton2Up",
    "DragStopped", "TouchTap", "TouchLongPress", "TouchPan", "TouchPinch",
    "TouchRotate", "TouchSwipe", "MouseWheelForward", "MouseWheelBackward",
    "DescendantRemoving", "ChildAdded", "Changed", "GetPropertyChangedSignal",
    -- Sound.Played is a real event (Ended/Paused/Resumed/Stopped are its siblings); hubs hang
    -- the "tear the ESP down when the lever opens" cleanup on it.
    "Played", "Ended", "Paused", "Resumed", "Stopped",
}) do SIGNAL_NAMES[name] = true end

OBJ.__index = function(self, k)
    -- An explicitly assigned field wins over the generic method stub: the harness
    -- overrides e.g. Players.GetPlayers, and the old order silently returned the
    -- stub's empty list instead (every carry/status feature then saw no players).
    local v = rawget(self, "_p")[k]
    if v ~= nil then return v end
    local m = rawget(OBJ, "m_" .. k)
    if m then return m end
    if SIGNAL_NAMES[k] then
        local s = newSignal()
        s.SignalName = k
        rawget(self, "_p")[k] = s
        return s
    end
    -- Dot-path module lookups (ReplicatedStorage.Objects.Game...) need a child
    -- that exists; only containers marked Permissive do this.
    local def = DEFAULTS[k]
    if def ~= nil then
        -- GuiObject defaults are value types in Roblox; hand back a copy so one
        -- widget writing Position cannot leak into the next widget's read.
        if type(def) == "table" then
            local c = {}
            for dk, dv in pairs(def) do
                if type(dv) == "table" then
                    local inner = {}
                    for ik, iv in pairs(dv) do inner[ik] = iv end
                    c[dk] = inner
                else
                    c[dk] = dv
                end
            end
            return c
        end
        return def
    end
    -- Structural Instance members must never be fabricated. `Parent` especially:
    -- the permissive index used to hand back a brand-new Folder named "Parent" for
    -- every read, so any `while o and not o:IsA("Model") do o = o.Parent end` walk
    -- (Doors' GetHidingSpotModel) became an infinite chain that never yields -- the
    -- run hung at 100% CPU with zero output and looked like a payload deadlock.
    if k == "Parent" or k == "ClassName" then return nil end
    if rawget(self, "_p").Permissive and not STRICT_WFC then
        -- Detached on purpose: a real container does not grow a child just
        -- because someone read a dot. Caching here made repeated existence
        -- probes (`rs:FindFirstChild("Services")`) start returning true on the
        -- third call, which is how a Folder ended up being :Fire()'d.
        --
        -- Every real Roblox member is PascalCase. A lowercase read is a typo in the
        -- payload (`prompt.parent`), and fabricating a child for it turns an
        -- always-false guard into an always-true one -- that is how a scan that
        -- fired nothing in game stayed green here for months. Report and refuse.
        if type(k) == "string" and k:find("^%l") and k ~= "new" and k ~= "fromExisting" then
            bump(SUSPECT, tostring(rawget(self, "_p").Name) .. "." .. k)
            return nil
        end
        local o = newInstance("Folder", k)
        o._p.Permissive = true
        return o
    end
    return nil
end
-- Side-effect counter. A callback that runs clean but touches nothing is a dead
-- feature, and pcall hides that; the audit needs a number to point at.
EFFECTS = 0
OBJ.__newindex = function(self, k, v)
    EFFECTS += 1
    local p = rawget(self, "_p")
    -- Game state only: the menu rebuilds its own frames hundreds of times and
    -- drowns the interesting writes (Workspace.Gravity, Humanoid.WalkSpeed,
    -- BasePart.CanCollide) in UI noise.
    local cls = tostring(p.ClassName)
    -- ESP objects are billboards and labels, which the UI filter below would drop.
    -- They carry the Reicht prefix, so name-based admission keeps the proof that a
    -- visual switch actually reached the object instead of only running its handler.
    if tostring(p.Name):find("^Reicht") then
        -- Text writes carry their value: "the label was rewritten" is a weaker claim
        -- than "the label now says the localised name".
        bump(TRACE.wrote, tostring(p.Name) .. "|" .. k .. (type(v) == "string" and ("=" .. v) or ""))
    end
    if not cls:find("^UI") and not cls:find("Frame") and not cls:find("Label")
        and not cls:find("Button") and not cls:find("Image") and not cls:find("Sprite")
        and not cls:find("Gui") and not cls:find("Probe") and not cls:find("Canvas")
        and not cls:find("Scrolling") and not cls:find("Stroke") and not cls:find("Padding")
        and not cls:find("List") and not cls:find("Grid") and not cls:find("Corner")
        and not cls:find("Gradient") and not cls:find("Aspect") and not cls:find("Scale") then
        bump(TRACE.wrote, tostring(p.Name) .. "|" .. k)
    end
    -- Roblox parenting links both ways. Without this, anything the payload creates
    -- with `Instance.new(...)` then parents is invisible to FindFirstChild and to
    -- the harness's own descendant walk (floating buttons were lost this way).
    if k == "Parent" then
        local old = p.Parent
        if old and old._p and old._p.Children then
            for i = #old._p.Children, 1, -1 do
                if old._p.Children[i] == self then table.remove(old._p.Children, i) end
            end
        end
        if v and v._p and v._p.Children then
            local present = false
            for _, c in ipairs(v._p.Children) do if c == self then present = true break end end
            if not present then table.insert(v._p.Children, self) end
        end
    end
    p[k] = v
end

newInstance = function(class, name)
    EFFECTS += 1
    bump(TRACE.made, class)
    local self = setmetatable({ _p = { ClassName = class, Name = name or class, Parent = nil, Children = {} } }, OBJ)
    return self
end

local function childOf(self, name)
    for _, c in ipairs(self._p.Children) do
        if c._p.Name == name then return c end
    end
    return nil
end

-- Real Roblox FindFirstChild takes a recursive flag as its second argument.
-- Ignoring it makes every `ReplicatedStorage:FindFirstChild(name, true)` return nil
-- even when the object sits one folder down, so those features bail out silently --
-- the same class of fake-green as a missing PivotTo.
OBJ.m_FindFirstChild = function(self, name, recursive)
    local direct = childOf(self, name)
    if direct or not recursive then return direct end
    for _, child in ipairs(rawget(self, "_p").Children or {}) do
        local found = OBJ.m_FindFirstChild(child, name, true)
        if found then return found end
    end
    return nil
end
OBJ.m_WaitForChild = function(self, name)
    if WFC_MISS[name] then return nil end
    local c = childOf(self, name)
    if c then return c end
    -- Strict mode: an unseeded name stays missing, which is what the live game
    -- does. Everything else keeps the permissive fabrication so the other 18
    -- games' mocks stay valid.
    if STRICT_WFC then return nil end
    local o = newInstance("Folder", name)
    o._p.Parent = self
    -- Nested paths (ReplicatedStorage.Remotes.HideMonster) must keep resolving;
    -- a child created under a permissive parent inherits the flag.
    if rawget(self, "_p").Permissive then o._p.Permissive = true end
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
-- Walking the parent chain, not a blanket true. A blanket true made every weld in
-- the character look like a weld to somebody else's body, so "am I carrying this
-- player" answered yes for our own joints and the carry loop could never retry.
OBJ.m_IsDescendantOf = function(self, ancestor)
    local node = self._p and self._p.Parent
    while node do
        if node == ancestor then return true end
        node = node._p and node._p.Parent
    end
    return false
end
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
-- Roblox walks the whole tree; a shallow version hides every nested part
-- (room -> DoorFake -> Hidden) and makes room-scan features look inert.
OBJ.m_GetDescendants = function(self)
    local out = {}
    local function walk(node)
        for _, child in ipairs(node._p.Children) do
            table.insert(out, child)
            walk(child)
        end
    end
    walk(self)
    return out
end
-- Roblox classes inherit: `remote:IsA("BaseRemoteEvent")` is true for a RemoteEvent.
-- A flat equality check says no, and scripts that name the superclass (MM2 asks for
-- BaseRemoteEvent) reject their own remotes and go inert while errors stay at 0.
local CLASS_PARENTS = {
    RemoteEvent = { "BaseRemoteEvent" },
    UnreliableRemoteEvent = { "BaseRemoteEvent" },
    RemoteFunction = { "BaseRemoteEvent" },
    TextLabel = { "GuiObject", "GuiBase2d", "Instance" },
    Frame = { "GuiObject", "GuiBase2d", "Instance" },
    Part = { "BasePart" },
    MeshPart = { "BasePart" },
}
OBJ.m_IsA = function(self, class)
    local own = self._p.ClassName
    if own == class then return true end
    for _, parent in ipairs(CLASS_PARENTS[own] or {}) do
        if parent == class then return true end
    end
    return false
end
OBJ.m_Destroy = function(self) self._p.Destroyed = true end
-- Ancestor lookups. PromptCondition() opens with FindFirstAncestorOfClass("Model"),
-- and BOTH ancestor methods were missing from the mock entirely. Every handler that
-- gates on a prompt condition -- the reach multiplier, prompt clip, infinite items --
-- therefore died on the first descendant with "attempt to call a nil value", inside
-- Util.Try, silently, and reported clean.
local function classMatches(node, class)
    local own = node._p.ClassName
    if own == class then return true end
    for _, parent in ipairs(CLASS_PARENTS[own] or {}) do
        if parent == class then return true end
    end
    return false
end
OBJ.m_FindFirstAncestorOfClass = function(self, class)
    local node = rawget(self, "_p").Parent
    while node do
        if node._p.ClassName == class then return node end
        node = node._p.Parent
    end
    return nil
end
OBJ.m_FindFirstAncestorWhichIsA = function(self, class)
    local node = rawget(self, "_p").Parent
    while node do
        if classMatches(node, class) then return node end
        node = node._p.Parent
    end
    return nil
end
OBJ.m_Clone = function(self) return newInstance(self._p.ClassName, self._p.Name) end
OBJ.m_GetAttribute = function(self, k) return (self._p.Attrs or {})[k] end
OBJ.m_SetAttribute = function(self, k, v)
    self._p.Attrs = self._p.Attrs or {}
    self._p.Attrs[k] = v
    -- A filter decision is invisible unless it leaves a mark; tracing the value
    -- lets a proof assert "this entity was admitted / dropped", not just "ran".
    bump(TRACE.wrote, tostring(self._p.Name or "obj") .. "|SetAttribute|" .. tostring(k) .. "=" .. tostring(v))
end
OBJ.m_GetPropertyChangedSignal = function(self) return newSignal() end
-- PivotTo/GetPivot are how every modern hub moves a character (teleports, finish
-- pads, carry targets). They were missing, so those features silently took a
-- fallback branch and the run never proved the character actually moved.
OBJ.m_GetPivot = function(self) return CFrame.new(0, 0, 0) end
OBJ.m_PivotTo = function(self, target)
    bump(TRACE.wrote, tostring(rawget(self, "_p").Name or "obj") .. "|PivotTo")
end
OBJ.m_GetDescendantsAsync = function(self) return OBJ.m_GetDescendants(self) end
OBJ.m_TranslateBy = function(self) end
OBJ.m_ChangeState = function(self) end
-- Deprecated-but-shipped API hubs still call for low-graphics mode.
OBJ.m_Set3dRenderingEnabled = function(self, value) end
OBJ.m_FireServer = function(self, ...)
    -- rawget: on a Permissive container `self.Fired` would auto-create a child
    -- Folder and the counter becomes a table (arithmetic error, swallowed by the
    -- payload's own pcall -- a silent dead feature).
    local p = rawget(self, "_p")
    p.Fired = (p.Fired or 0) + 1
    local arg = select(1, ...)
    local key = tostring(rawget(self, "_p").Name) .. "|" .. tostring(type(arg) == "string" and arg or type(arg))
    bump(TRACE.fire, key)
end
OBJ.m_Invoke = function(self) return {} end
-- ProximityPrompt:InputHoldBegin()/End() is the engine's own activation path, so a
-- payload without fireproximityprompt fires prompts through it. The mock has to expose
-- both and record the begin, or that fallback looks dead when it is only untested.
OBJ.m_InputHoldBegin = function(self)
    local p = rawget(self, "_p")
    bump(TRACE.fire, tostring(type(p) == "table" and p.Name or "prompt") .. "|InputHoldBegin")
end
OBJ.m_InputHoldEnd = function(self) end
-- Real executors expose fireproximityprompt. The payload probes the global
-- (ExecutorSupport) and routes auto interact through that branch; with the global absent
-- the harness could only ever exercise the distance-gated fallback, which is the path
-- that needs a manual press in game.
fireproximityprompt = function(prompt)
    local name = "prompt"
    local okName, n = pcall(function() return prompt.Name end)
    if okName and type(n) == "string" and n ~= "" then name = n end
    bump(TRACE.fire, name .. "|prompt")
end
-- REICHT_NO_FPP=1 drops the global, which is what an executor without the function
-- looks like. Every capability gate in the payload then has to read false on its own,
-- and the prompt fallback has to carry the feature.
if __NO_FPP__ then fireproximityprompt = nil end
-- Server functions answer with a table in the real game; leaving InvokeServer as a
-- nil method made every profile read throw and a hub that guards on
-- `type(profile) == "table"` then re-raised "profile unavailable". Shaped per remote
-- name where the shape is actually read (Loot To Forge iterates Backpack.have).
-- Server functions answer with a table in the real game, but a half-shaped profile
-- is worse than none: Loot To Forge reads numbers off it (Eco.rebirth, goods Store)
-- and the mock's permissive folders turn those reads into tables, so arithmetic
-- crashes deeper in. Left nil until a run actually needs the shape.
OBJ.m_InvokeServer = function(self) return nil end
OBJ.m_QueryDescendants = function(self, class)
    -- Added to Roblox in 2025; hubs use it to find prompts/ImageLabels in one call.
    -- Without it the name is auto-created as a permissive child and the call is
    -- "attempt to call a table value".
    local out = {}
    local function walk(node)
        local p = rawget(node, "_p")
        for _, child in ipairs(p and p.Children or {}) do
            if child.ClassName == class then table.insert(out, child) end
            walk(child)
        end
    end
    walk(self)
    return out
end
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
    -- `while flag do Signal:Wait() end` into a busy loop that never ends. The
    -- value handed back must be the fired arguments or nil -- a made-up number
    -- became `character` in game code that does CharacterAdded:Wait().
    coroutine.yield()
    if self.lastArgs then return table.unpack(self.lastArgs) end
    return 1 / 60
end
    function s:Once(fn) table.insert(self.handlers, fn) end
    s.Fire = function(self, ...)
        self.lastArgs = table.pack(...)
        local args = table.pack(...)
        for _, fn in ipairs(self.handlers) do
            -- Every handler runs on its own thread, like Roblox. A handler that
            -- calls task.wait() would otherwise yield the thread that fired the
            -- signal; when that thread is the state's main thread (the prelude
            -- replays CharacterAdded before MAIN exists) Luau aborts the whole
            -- run with "thread yielded unexpectedly" and the game never builds.
            local co = coroutine.create(fn)
            for _ = 1, 8 do
                local ok = coroutine.resume(co, table.unpack(args, 1, args.n))
                if not ok or coroutine.status(co) == "dead" then break end
            end
        end
    end
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
-- A blanket truthy module makes every `if mod:Get("Downed") then` probe read as
-- true, which silently disables anything filtering on a boolean (auto carry saw
-- every candidate as ragdolled). CharacterService is deliberately unreachable so
-- the payload falls back to the attribute-based path the harness can seed.
-- Item registry: the shop dropdown reads this module. A permissive stub answers
-- every call with another stub, so `pairs(reg.GetAll())` yields nothing and the
-- auto-buy catalog is empty -- the feature then looks broken for a harness reason
-- instead of a real one. Seed the two shapes the payload actually reads.
local SHOP_REGISTRY = {
    { id = 101, Name = "Cola", PurchaseInfo = { AppearsIn = "Shop", OwnershipType = "Multiple" } },
    { id = 102, Name = "Medkit", PurchaseInfo = { AppearsIn = "Shop", OwnershipType = "Multiple" } },
    { id = 103, Name = "Lockpick", PurchaseInfo = { AppearsIn = "Inventory", OwnershipType = "Single" } },
}
local ITEM_REGISTRY = {
    GetAll = function()
        local map = {}
        for _, entry in ipairs(SHOP_REGISTRY) do map[entry.id] = entry end
        return map
    end,
    GetConfig = function(id)
        for _, entry in ipairs(SHOP_REGISTRY) do
            if entry.id == id then return entry end
        end
    end,
}
require = function(mod)
    local name = type(mod) == "table" and mod._p and mod._p.Name
    if name == "CharacterService" then return nil end
    if name == "Registry" then return ITEM_REGISTRY end
    -- Game config modules carry real numbers, and a permissive stand-in turns them
    -- into tables: `tonumber(reward.Minute)` reads nil and the feature looks dead
    -- while the code is fine. Shape the two modules whose fields are read as numbers.
    if name == "PlaytimeRewardsConfig" then
        return { Rewards = { { Minute = 1 }, { Minute = 5 }, { Minute = 10 } } }
    end
    if name == "TrailConfigurations" then
        return { Trails = {
            { ID = 1, Name = "Classic", WinCost = 0, TongueBoost = 1 },
            { ID = 2, Name = "Radiant", WinCost = 50, TongueBoost = 3 },
        } }
    end
    return anyModule()
end

Instance = { new = function(class, parent)
    local o = newInstance(class)
    if parent then o._p.Parent = parent; table.insert(parent._p.Children, o) end
    return o
end }

-- Tag registry. Games gate hazard/collectible logic on CollectionService tags
-- (`GetTagged("KillBrick")`), and a missing service reads as "no hazards", so the
-- protection feature silently protects nothing while still reporting success.
local COLLECTION_SERVICE = { _tags = {} }
function COLLECTION_SERVICE:GetTagged(tag)
    local out = {}
    for inst, tags in pairs(self._tags) do
        if tags[tag] then table.insert(out, inst) end
    end
    return out
end
function COLLECTION_SERVICE:GetAllTags()
    local seen, out = {}, {}
    for _, tags in pairs(self._tags) do
        for tag in pairs(tags) do
            if not seen[tag] then seen[tag] = true; table.insert(out, tag) end
        end
    end
    return out
end
function COLLECTION_SERVICE:AddTag(inst, tag)
    self._tags[inst] = self._tags[inst] or {}
    self._tags[inst][tag] = true
end
function COLLECTION_SERVICE:RemoveTag(inst, tag)
    if self._tags[inst] then self._tags[inst][tag] = nil end
end
function COLLECTION_SERVICE:HasTag(inst, tag)
    return self._tags[inst] ~= nil and self._tags[inst][tag] == true
end
COLLECTION_SERVICE._added = newSignal()
COLLECTION_SERVICE._removed = newSignal()
function COLLECTION_SERVICE:GetInstanceAddedSignal() return self._added end

-- Roblox exposes tags on the instance too, and hubs read `part:HasTag("X")` far more
-- often than the service call. Without the instance side every handler that touches a
-- tagged object dies on "missing method 'HasTag'".
OBJ.m_HasTag = function(self, tag) return COLLECTION_SERVICE:HasTag(self, tag) end
OBJ.m_AddTag = function(self, tag) COLLECTION_SERVICE:AddTag(self, tag) end
OBJ.m_RemoveTag = function(self, tag) COLLECTION_SERVICE:RemoveTag(self, tag) end
OBJ.m_GetTags = function(self) return COLLECTION_SERVICE:GetTags(self) end
function COLLECTION_SERVICE:GetInstanceRemovedSignal() return self._removed end

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
-- TextBoxFocused / TextBoxFocusReleased are what a hub hangs its "am I typing" guard on;
-- without them every `:Connect` on the pair is a nil index and the layer dies there.
for _, n in ipairs({ "JumpRequest", "TouchTap", "TouchLongPress", "TouchPan", "TouchSwipe",
        "TouchRotate", "TouchPinch", "WindowFocused", "WindowFocusReleased", "PointerAction",
        "TextBoxFocused", "TextBoxFocusReleased" }) do
    local uis = get("UserInputService")
    local sig = newSignal(); sig.SignalName = n
    rawget(uis, "_p")[n] = sig
end
get("UserInputService").TouchEnabled = false
get("UserInputService").MouseEnabled = true

local players = get("Players")
local lp = newInstance("Player", "Tester")
lp.Character = nil
lp.UserId = 1
-- Player:DistanceFromCharacter is the API a hub uses to decide whether something is in
-- reach; without it every reach-gated frame handler dies before it decides anything.
lp.DistanceFromCharacter = function(self, point)
    local char = self._p.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local origin = (root and root.Position) or v3(0, 0, 0)
    local function axis(v, k) return tonumber(type(v) == "table" and v[k]) or 0 end
    local dx = axis(point, "X") - axis(origin, "X")
    local dy = axis(point, "Y") - axis(origin, "Y")
    local dz = axis(point, "Z") - axis(origin, "Z")
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end
lp.GetAttribute = OBJ.m_GetAttribute
lp.SetAttribute = OBJ.m_SetAttribute
lp.Idled = newSignal()
-- Ride A Pet's offline-reward claim is gated on this attribute being positive; a
-- missing attribute reads nil, `tonumber(nil) or 0 <= 0` is true, and the feature
-- returns before it ever reaches the remote.
lp:SetAttribute("OfflineSeconds", 900)
lp.PlayerGui = newInstance("PlayerGui", "PlayerGui")
-- DOORS parks its HUD under PlayerGui.MainUI and its character setup blocks on that
-- folder before it hands out Humanoid -- so a missing MainUI silences speed, crouch and
-- auto interact all at once. The payload only ever got past that block because
-- WaitForChild on a permissive stand-in fabricated the child; now that lookups no longer
-- fabricate, the real folder has to exist on the PlayerGui the payload captures. (A
-- later block replaces PlayerGui entirely, which is too late: the payload has already
-- cached this instance.)
-- REICHT_NO_MAINUI drops the seed on purpose: the live game can ship without this
-- folder, and the layer has to stay wired when it does. This is the case the operator
-- hit in game -- menu opened, ESP and half the toggles dead.
local bootMainUI = nil
if not __NO_MAINUI__ then bootMainUI = newInstance("Folder", "MainUI") end
if bootMainUI then
    bootMainUI._p.ClassName = "Folder"
    bootMainUI._p.Permissive = true
    table.insert(rawget(lp.PlayerGui, "_p").Children, bootMainUI)
    bootMainUI._p.Parent = lp.PlayerGui
end
lp.PlayerScripts = newInstance("PlayerScripts", "PlayerScripts")
players.LocalPlayer = lp
-- The lock-prompt path demands a key in the bag and a room number that matches the
-- prompt's ParentRoom before it fires anything. Plant both in the fallback run, or that
-- run only proves the layer loads without the global -- not that it can still open a door.
lp.Backpack = newInstance("Folder", "Backpack")
lp.Backpack._p.Parent = lp
local keyTool = newInstance("Tool", "Key")
keyTool._p.Parent = lp.Backpack
table.insert(lp.Backpack._p.Children, keyTool)
lp:SetAttribute("CurrentRoom", 0)
players.GetPlayers = function() return { lp } end
players.GetPlayerFromCharacter = function() return lp end
players.GetUserIdFromNameAsync = function() return 1 end

local rs = get("ReplicatedStorage")
rs.Permissive = true
-- Emote source. The payload resolves an emote two ways: a folder scan under
-- ReplicatedStorage.Items.Emotes (ModuleScripts carrying an "ID" attribute) and the
-- registry's GetByCategory. With neither seeded, the emote proof used to pass only
-- because the permissive registry stub answered TryGetByName with a fabricated
-- module whose GetAttribute("ID") was truthy -- a fire on invented data. Seed the
-- folder so the fire is real.
local itemsFolder = newInstance("Folder", "Items")
itemsFolder._p.Parent = rs
table.insert(rs._p.Children, itemsFolder)
local emotesFolder = newInstance("Folder", "Emotes")
emotesFolder._p.Parent = itemsFolder
table.insert(itemsFolder._p.Children, emotesFolder)
for _, emote in ipairs({ { "BoldMarch", 7 }, { "DefaultEmote", 8 } }) do
    local mod = newInstance("ModuleScript", emote[1])
    mod:SetAttribute("ID", emote[2])
    mod._p.Parent = emotesFolder
    table.insert(emotesFolder._p.Children, mod)
end
-- DOORS derives its whole menu from ReplicatedStorage.GameData: the floor name
-- picks widget labels ("Auto " .. HidingPlaceName[floor.Value]), so an empty
-- GameData aborts the build instead of exercising it.
local function addChild(parent, child)
    child._p.Parent = parent
    table.insert(rawget(parent, "_p").Children, child)
    -- Dot access has to resolve to the real child. `workspace.CurrentRooms` is how
    -- most handlers walk the room, and with only Children populated the dot fell
    -- through to the Permissive stub, which hands back a detached empty Folder. Every
    -- feature that iterates by dot path therefore ran against nothing and looked
    -- clean: the reach multiplier looped over zero prompts for months.
    rawget(parent, "_p")[child._p.Name] = child
    return child
end
local gameData = addChild(rs, newInstance("Folder", "GameData"))
gameData.Permissive = true
local floorValue = addChild(gameData, newInstance("StringValue", "Floor"))
floorValue.Value = "Hotel"
local latestRoom = addChild(gameData, newInstance("IntValue", "LatestRoom"))
latestRoom.Value = 0

-- Merge-layer surfaces. The DOORS features folded in from the other hubs read
-- Bricks (breaker, light events, heartbeat, jumpscare), EntityInfo (camera lock,
-- motor replication) and walk CurrentRooms; seeding them turns each feature from
-- "callback ran" into "it actually touched the object it claims to touch".
local bricksFolder = addChild(rs, newInstance("Folder", "Bricks"))
bricksFolder.Permissive = true
local function addRemote(name, parent)
    local event = newInstance("RemoteEvent", name)
    addChild(parent, event)
    return event
end
addRemote("EBF", bricksFolder)
addRemote("Jumpscare", bricksFolder)
addRemote("ClutchHeartbeat", bricksFolder)
addRemote("UseEventModule", bricksFolder)
local remotesFolder = addChild(rs, newInstance("Folder", "RemotesFolder"))
remotesFolder.Permissive = true
addRemote("DropItem", remotesFolder)
-- Knob farm drives these two by name. Without real remotes the folder's Permissive
-- index hands back a fabricated child and the trace cannot tell a claim from a no-op.
addRemote("Statistics", remotesFolder)
addRemote("PlayAgain", remotesFolder)

-- Ride A Pet resolves every remote through GameLib.Remote, which walks
-- ReplicatedStorage.Remotes.Game.<name>, then Remotes.Reusable.<name>, then
-- packages.*.Net["RE/<name>"]. With none of those present every one of its 33 call
-- sites gets nil and the game looks inert while still reporting errors: 0.
local petRemotes = addChild(rs, newInstance("Folder", "Remotes"))
local petGame = addChild(petRemotes, newInstance("Folder", "Game"))
petGame.Permissive = true
for _, name in ipairs({
    "BasketDrop", "ConfirmRequest", "DoorKnocked", "EggPickup", "EggPlaced", "FeedPet",
    "FusionAction", "FusionPetPlace", "GameMessage", "Hatch", "Mounting", "PetCollect",
    "PetDismount", "PetFed", "PickupPet", "PlacePet", "RequestPlotEggs", "SellItems",
    "UpdateSetting", "VolcanoDip", "VolcanoDipCancelled", "VolcanoDipResult",
    "BuyHalloweenEgg", "BuyWithCash", "ClaimIndexReward", "CollectCandy", "GetCandyState",
    "GetDoorState", "GetPumpkinState", "KnockDoor", "OfflineEarnings", "Rebirth",
    "SearchPumpkin", "ShopStock",
}) do
    addRemote(name, petGame)
end

-- Murder Mystery 2 resolves its five remotes through Remotes.Gameplay / Remotes.Extras
-- and asks for the BaseRemoteEvent superclass, so both the tree and IsA have to be real.
local petExtras = addChild(petRemotes, newInstance("Folder", "Extras"))
petExtras.Permissive = true
local mmGameplay = addChild(petRemotes, newInstance("Folder", "Gameplay"))
mmGameplay.Permissive = true
for _, name in ipairs({ "CoinCollected", "CoinsStarted", "RoundStart" }) do
    addRemote(name, mmGameplay)
end
do
    local pd = newInstance("RemoteFunction", "GetCurrentPlayerData")
    addChild(mmGameplay, pd)
    pd.Permissive = true
    local rc = newInstance("RemoteFunction", "RedeemCode")
    addChild(petExtras, rc)
    rc.Permissive = true
end

local entityInfoFolder = addChild(rs, newInstance("Folder", "EntityInfo"))
entityInfoFolder.Permissive = true
addRemote("MotorReplication", entityInfoFolder)
addRemote("CamLock", entityInfoFolder)

local ws = get("Workspace")
-- Game code walks Workspace.CurrentRooms / .Map / .Generation by name; without
-- Permissive those reads are nil and every feature that touches the map bails.
ws.Permissive = true
ws.Gravity = 196.2
ws.CurrentCamera = newInstance("Camera", "Camera")
ws.CurrentCamera.FieldOfView = 70

-- +1 Tongue Escape. Every feature in that script is a remote fire or a map read,
-- so the surfaces have to exist before the menu builds or the run only proves the
-- toggles flip. Shapes follow the game: Events carries the four remotes,
-- Map.GiveWins.OneWin holds the finish pads, leaderstats carries the four numbers.
local eventsFolder = addChild(rs, newInstance("Folder", "Events"))
eventsFolder.Permissive = true
addRemote("AddTongue", eventsFolder)
addRemote("TrailAction", eventsFolder)
addRemote("PlaytimeClaim", eventsFolder)
local rebirthRemote = addChild(eventsFolder, newInstance("RemoteFunction", "RequestRebirth"))
-- Instance-level so the global InvokeServer stays nil: DOORS relies on that nil to
-- take its own fallback branch, and one game's mock must not reshape another's.
-- Assigned into _p, not onto the instance: OBJ.__index reads _p first and would
-- otherwise hand back the global stub that returns nil without a trace.
rebirthRemote._p.InvokeServer = function(self)
    bump(TRACE.fire, "RequestRebirth|invoke")
    return true
end
local modulesFolder = addChild(rs, newInstance("Folder", "Modules"))
modulesFolder.Permissive = true
addChild(modulesFolder, newInstance("ModuleScript", "PlaytimeRewardsConfig"))
addChild(modulesFolder, newInstance("ModuleScript", "TrailConfigurations"))
addChild(rs, newInstance("ModuleScript", "TongueShared"))

local stats = addChild(lp, newInstance("Folder", "leaderstats"))
stats.Permissive = true
local levelValue = addChild(stats, newInstance("IntValue", "Level"))
levelValue.Value = 5000
local rebirthValue = addChild(stats, newInstance("IntValue", "Rebirths"))
rebirthValue.Value = 0
local winsValue = addChild(stats, newInstance("IntValue", "Wins"))
winsValue.Value = 1000
local tongueValue = addChild(stats, newInstance("IntValue", "Tongue"))
tongueValue.Value = 0
local trailsFolder = addChild(lp, newInstance("Folder", "Trails"))
trailsFolder.Permissive = true
local equippedValue = addChild(trailsFolder, newInstance("StringValue", "Equipped"))
equippedValue.Value = ""

local mapFolder = addChild(ws, newInstance("Folder", "Map"))
mapFolder.Permissive = true
local giveWins = addChild(mapFolder, newInstance("Folder", "GiveWins"))
giveWins.Permissive = true
local oneWinRow = addChild(giveWins, newInstance("Folder", "OneWin"))
oneWinRow.Permissive = true
-- Two pads with different payouts: the scan is supposed to pick the bigger one, so
-- the proof carries the number and a wrong pick fails instead of passing quietly.
for _, spec in ipairs({ { Name = "WinPad25", Amount = 25 }, { Name = "WinPad100", Amount = 100 } }) do
    local pad = addChild(oneWinRow, newInstance("Model", spec.Name))
    pad:SetAttribute("WinAmount", spec.Amount)
    addChild(pad, newInstance("Part", "Touch"))
end
local stagesFolder = addChild(mapFolder, newInstance("Folder", "Stages"))
stagesFolder.Permissive = true
for index = 1, 3 do
    local stage = addChild(stagesFolder, newInstance("Folder", "Stage" .. index))
    stage.Permissive = true
    addChild(stage, newInstance("Part", "Portal"))
end

-- A live server ships the game's own framework tree (Knit Services/Controllers/
-- Modules, per-game packages). Without it every module-gated feature bails
-- before the menu is even built, and the run reports "0 options" instead of a
-- real defect. Seed exactly the paths the script itself asks for.
local function seedPath(path)
    local node = rs
    local parts = {}
    for part in path:gmatch("[^%.]+") do parts[#parts + 1] = part end
    for i, part in ipairs(parts) do
        local existing = childOf(node, part)
        if not existing then
            local last = i == #parts
            local class = "Folder"
            if last then
                class = (part:find("Remote") or part:find("Event")) and "RemoteEvent" or "ModuleScript"
            end
            existing = newInstance(class, part)
            existing._p.Parent = node
            existing._p.Permissive = true
            table.insert(rawget(node, "_p").Children, existing)
        end
        node = existing
    end
    return node
end
for _, root in ipairs({ "Services", "Controllers", "Modules", "Shared", "Packages", "Remotes" }) do
    if not childOf(rs, root) then
        local f = newInstance("Folder", root)
        f._p.Parent = rs
        f._p.Permissive = true
        table.insert(rawget(rs, "_p").Children, f)
    end
end
for _, path in ipairs(__RS_PATHS__) do seedPath(path) end

-- Knit package layout. Hubs that talk to a Knit game resolve their services as
-- ReplicatedStorage.Packages._Index.<sleitnick_knit@ver>.knit.Services; without
-- that tree the whole script bails with "needs an update" and builds no menu.
do
    local packages = childOf(rs, "Packages") or seedPath("Packages")
    local index = childOf(packages, "_Index")
    if not index then
        index = newInstance("Folder", "_Index")
        addChild(packages, index)
    end
    index.Permissive = true
    local pkg = childOf(index, "sleitnick_knit@1.7.0")
    if not pkg then
        pkg = newInstance("Folder", "sleitnick_knit@1.7.0")
        addChild(index, pkg)
    end
    pkg.Permissive = true
    local knit = childOf(pkg, "knit")
    if not knit then
        knit = newInstance("Folder", "knit")
        addChild(pkg, knit)
    end
    knit.Permissive = true
    for _, name in ipairs({ "Services", "Controllers" }) do
        local branch = childOf(knit, name)
        if not branch then
            branch = newInstance("Folder", name)
            addChild(knit, branch)
        end
        branch.Permissive = true
    end
    local shared = childOf(rs, "Shared") or seedPath("Shared")
    if not childOf(shared, "Config") then
        local cfg = newInstance("ModuleScript", "Config")
        addChild(shared, cfg)
        cfg.Permissive = true
    end
end

-- Remote pairs the script asks for by name. Hub code resolves them through
-- ReplicatedStorage.Remote.<folder>_Server.<name> and rejects anything that is not
-- a RemoteEvent/RemoteFunction, so the class matters as much as the name.
do
    local holder = childOf(rs, "Remote")
    if not holder then
        holder = newInstance("Folder", "Remote")
        addChild(rs, holder)
    end
    holder.Permissive = true
    for _, pair in ipairs(__REMOTE_PAIRS__) do
        local folder = childOf(holder, pair[1] .. "_Server")
        if not folder then
            folder = newInstance("Folder", pair[1] .. "_Server")
            addChild(holder, folder)
        end
        folder.Permissive = true
        if not childOf(folder, pair[2]) then
            local remote = newInstance("RemoteFunction", pair[2])
            addChild(folder, remote)
            remote.Permissive = true
        end
    end
end

local roomsFolder = addChild(ws, newInstance("Folder", "CurrentRooms"))
roomsFolder.Permissive = true
local roomZero = addChild(roomsFolder, newInstance("Model", "0"))
roomZero.Permissive = true
local roomDoor = addChild(roomZero, newInstance("Model", "Door"))
roomDoor.Permissive = true
addRemote("ClientOpen", roomDoor)
local fakeDoor = addChild(roomZero, newInstance("Model", "DoorFake"))
fakeDoor.Permissive = true
addChild(fakeDoor, newInstance("Part", "Hidden"))
local lockPart = addChild(fakeDoor, newInstance("Model", "LockPart"))
lockPart.Permissive = true
addChild(lockPart, newInstance("ProximityPrompt", "UnlockPrompt"))
-- Infinite Items path: a door lock the payload recognises, and the remote it drops
-- the key tool through. Without both the filter guard is never consulted.
local lockHolder = addChild(roomZero, newInstance("Model", "LockHolder"))
lockHolder.Permissive = true
lockHolder:SetAttribute("Opened", false)
local lockModel = addChild(lockHolder, newInstance("Model", "Lock"))
lockModel.Permissive = true
addChild(lockModel, newInstance("ProximityPrompt", "UnlockPrompt"))
local snareModel = addChild(roomZero, newInstance("Model", "Snare"))
snareModel.Permissive = true
addChild(snareModel, newInstance("Part", "Hitbox"))
addChild(roomZero, newInstance("Part", "Collision"))
addChild(roomZero, newInstance("ProximityPrompt", "RoomPrompt"))
-- Room ESP targets: the part names a decrypted Doors hub points at. Without them
-- the ESP scan has nothing to find and its proof would pass on an empty room.
for _, name in ipairs({ "KeyObtain", "LeverForGate", "LiveBreakerPolePickup", "LiveHintBook", "RoomExit" }) do
    addChild(roomZero, newInstance("Part", name))
end
local eyesModel = addChild(ws, newInstance("Model", "Eyes"))
eyesModel.Permissive = true
-- Entity ESP target. BackdoorRush is in the payload's own EntityTable, and the
-- option driver narrows the entity dropdown to Values[1] == "BackdoorRush", so this
-- is the model the scan must find. Eyes stays in the world as the negative: it is a
-- real entity name but it is filtered out, and highlighting it would mean the
-- filter is inert.
local rushModel = addChild(ws, newInstance("Model", "BackdoorRush"))
rushModel.Permissive = true
addChild(rushModel, newInstance("Part", "Root"))
-- Floor 2 name: proves the extended EntityTable reaches the ESP. Its name only
-- exists because the decrypted hub tables carried it, so a green here means the
-- extra names are wired, not merely typed into a list.
local brambleModel = addChild(ws, newInstance("Model", "LiveEntityBramble"))
brambleModel.Permissive = true
addChild(brambleModel, newInstance("Part", "Root"))

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
-- Roblox has this; the mock did not, and MM2 names its ESP folder with it. The
-- missing method raised inside a pcall, the whole ESP init aborted, and the game still
-- reported errors: 0 -- the warn line was the only trace.
function HTTPSERVICE:GenerateGUID(wrapInBraces)
    local hex = "0123456789abcdef"
    local out = {}
    for i = 1, 32 do
        local idx = (i * 7 + 3) % 16 + 1
        out[i] = hex:sub(idx, idx)
    end
    local guid = table.concat(out)
    guid = guid:sub(1, 8) .. "-" .. guid:sub(9, 12) .. "-" .. guid:sub(13, 16) .. "-" ..
        guid:sub(17, 20) .. "-" .. guid:sub(21, 32)
    if wrapInBraces ~= false then return "{" .. guid .. "}" end
    return guid
end

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
do
    -- Fires when the client shows an error dialog (kick, disconnect). Auto-rejoin
    -- hubs hang off it; without the signal the Connect is an index-nil.
    local gui = get("GuiService")
    if not gui.ErrorMessageChanged then
        gui.ErrorMessageChanged = newSignal()
        gui.ErrorMessageChanged.SignalName = "ErrorMessageChanged"
    end
end
TELEPORT_SERVICE.TeleportInitFailed = newSignal()
TELEPORT_SERVICE.TeleportInitFailed.SignalName = "TeleportInitFailed"
function TELEPORT_SERVICE:TeleportAsync() end
-- Games that talk in chat go through TextChatService.TextChannels.RBXGeneral;
-- a nil channel is a harness gap, not a game bug.
local TEXT_CHANNEL = newInstance("TextChannel", "RBXGeneral")
TEXT_CHANNEL.DisplayName = "RBXGeneral"
function TEXT_CHANNEL:SendAsync() end
local TEXTCHAT_SERVICE = newInstance("TextChatService", "TextChatService")
TEXTCHAT_SERVICE.TextChannels = { RBXGeneral = TEXT_CHANNEL }
TEXTCHAT_SERVICE.ChatVersion = "TextChatService"
local _getService = function(_, name) return get(name) end
game.GetService = function(self, name)
    if name == "CollectionService" then return COLLECTION_SERVICE end
    if name == "TweenService" then return TWEEN_SERVICE end
    if name == "HttpService" then return HTTPSERVICE end
    if name == "TeleportService" then return TELEPORT_SERVICE end
    if name == "TextChatService" then return TEXTCHAT_SERVICE end
    return _getService(self, name)
end
-- Real menu source, inlined by the runner: exercising the shipped ui.lua beats a
-- stand-in, because that is the code the user actually gets.
UI_SOURCE = __UI_SOURCE__
FBM_SOURCE = __FBM_SOURCE__
game.HttpGet = function(_, url)
    url = tostring(url)
    -- Simulate a dead route: REICHT_UI_BLOCK="raw.githubusercontent" makes that
    -- host answer like a 404, which is how a mirror fallback gets proven instead
    -- of assumed.
    if HTTP_BLOCK ~= "" and url:find(HTTP_BLOCK, 1, true) then return "" end
    if url:find("ui%.lua") and type(UI_SOURCE) == "string" and #UI_SOURCE > 1024 then return UI_SOURCE end
    if url:find("FloatingButton") and type(FBM_SOURCE) == "string" and #FBM_SOURCE > 1024 then return FBM_SOURCE end
    return "return Library"
end

Workspace = ws
workspace = ws

PENDING = {}
task = {
    -- Roblox hands back the thread; scripts key their bookkeeping tables on it
    -- (`children[thread] = true`), so returning nothing is a nil-index crash.
    spawn = function(fn, ...)
        local co = coroutine.create(fn)
        table.insert(PENDING, co)
        local ok, err = coroutine.resume(co, ...)
        if not ok then table.insert(PENDING_ERRORS or {}, tostring(err)) end
        return co
    end,
    defer = function(fn, ...) return task.spawn(fn, ...) end,
    delay = function(_, fn, ...) return task.spawn(fn, ...) end,
    wait = function(t)
        WAIT_TRACE = debug.traceback("", 2)
        coroutine.yield()
        return 0
    end,
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
-- typeof is Roblox's own type query and it answers "Instance" for every instance.
-- Leaving it as plain `type` made `typeof(x) == "Instance"` false for every mock, so
-- branches that take an instance (DistanceFromCharacter reads :GetPivot()) fell into the
-- vector path, produced a fabricated comparison that was always false, and reported a
-- dead feature that works in game.
typeof = function(v)
    if type(v) == "table" then
        local p = rawget(v, "_p")
        if type(p) == "table" and p.ClassName ~= nil then return "Instance" end
    end
    return type(v)
end
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
-- Rainbow ESPs call ToHSV/fromHSV every frame; a stub that returns nothing makes
-- the colour path throw and takes the whole menu down with it.
C3.ToHSV = function(c)
    local hi = math.max(c.R, c.G, c.B)
    local lo = math.min(c.R, c.G, c.B)
    local delta = hi - lo
    local h = 0
    if delta > 0 then
        if hi == c.R then h = ((c.G - c.B) / delta) % 6
        elseif hi == c.G then h = (c.B - c.R) / delta + 2
        else h = (c.R - c.G) / delta + 4 end
        h = h / 6
    end
    return h, (hi == 0 and 0 or delta / hi), hi
end
local function fromHSV(h, s, v)
    h, s, v = h or 0, s or 0, v or 0
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    local m = i % 6
    if m == 0 then return c3(v, t, p) end
    if m == 1 then return c3(q, v, p) end
    if m == 2 then return c3(p, v, t) end
    if m == 3 then return c3(p, q, v) end
    if m == 4 then return c3(t, p, v) end
    return c3(v, p, q)
end
Color3 = { fromRGB = function(r, g, b) return c3((r or 0) / 255, (g or 0) / 255, (b or 0) / 255) end,
           new = function(r, g, b) return c3(r, g, b) end, fromHSV = fromHSV }
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
-- Vector2 exposes Magnitude/Unit as properties in Roblox; hub radar code divides
-- by them. A plain V2 table leaves offset.Magnitude nil and the compare kills the
-- frame handler ("attempt to compare number < nil").
V2.__index = function(self, k)
    if k == "Magnitude" then
        return math.sqrt(self.X * self.X + self.Y * self.Y)
    end
    if k == "Unit" then
        local m = math.sqrt(self.X * self.X + self.Y * self.Y)
        if m == 0 then return v2(0, 0) end
        return v2(self.X / m, self.Y / m)
    end
    return V2[k]
end
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
-- Forward declaration: V3.__index reads .Unit, which calls v3, which is only
-- assigned further down. Without this the Unit read is a call to a nil global
-- and every aim/ESP frame dies on it.
local v3
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
v3 = function(x, y, z)
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
-- Aim/ESP math calls these as methods (`dir:Dot(toTarget)`); a missing method
-- aborts the whole frame handler, not just one feature.
V3.Dot = function(a, b) return a.X * b.X + a.Y * b.Y + a.Z * b.Z end
V3.Cross = function(a, b)
    return v3(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X)
end
V3.Lerp = function(a, b, t)
    return v3(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t, a.Z + (b.Z - a.Z) * t)
end
-- Aim/ESP code leans on the axis constants (`Vector3.yAxis * vertical`);
-- without them every fly/aim path dies on "arithmetic on nil".
Vector3 = { new = v3, zero = v3(0, 0, 0), one = v3(1, 1, 1),
    xAxis = v3(1, 0, 0), yAxis = v3(0, 1, 0), zAxis = v3(0, 0, 1) }
-- BasePart only ever answers a Vector3 for .Position. A mock with no default hands
-- back nil (or a number), so `part.Position - other` throws or fabricates and every
-- distance gate reads as failed -- auto interact's range check is exactly that.
do
    local baseIndex = OBJ.__index
    OBJ.__index = function(self, k)
        local value = baseIndex(self, k)
        if value == nil and k == "Position" then
            local meta = rawget(self, "_p")
            local cls = type(meta) == "table" and meta.ClassName
            if type(cls) == "string" and cls:find("Part") then return v3(0, 0, 0) end
        end
        return value
    end
end

-- Camera/aim/ESP math divides ViewportSize; a nil here kills the whole render
-- loop with "attempt to index nil with 'X'" while every option still reports ok.
ws.CurrentCamera.ViewportSize = Vector2.new(1280, 720)
-- Tracers project a world point every frame. The real camera returns
-- (Vector3, onScreen); a missing method kills the whole RenderStepped loop, so it
-- only surfaced once the ESP tracer toggle actually fired.
-- Workspace really does raise ChildAdded; entity spawns arrive through it, so the
-- mock needs the signal for any spawn-driven feature to be testable at all.
if rawget(ws, "ChildAdded") == nil then
    ws.ChildAdded = newSignal()
    ws.ChildAdded.SignalName = "ChildAdded"
end
ws.CurrentCamera.WorldToViewportPoint = function(self, point)
    return Vector3.new(640, 360, 1), true
end
ws.CurrentCamera.WorldToScreenPoint = function(self, point)
    return Vector3.new(640, 360, 1), true
end
ws.GetServerTimeNow = function(self) return os.time() end
OBJ.m_GetServerTimeNow = function(self) return os.time() end
-- BindToRenderStep is how real hubs schedule per-frame work; route it onto the
-- RenderStepped signal the frame loop already drives.
OBJ.m_BindToRenderStep = function(self, name, priority, fn)
    local p = rawget(self, "_p")
    local sig = p.RenderStepped
    if not sig then sig = newSignal(); sig.SignalName = "RenderStepped"; p.RenderStepped = sig end
    if type(fn) == "function" then table.insert(sig.handlers, fn) end
end
OBJ.m_UnbindFromRenderStep = function() end
OBJ.m_GenerateGUID = function() return "00000000-0000-4000-8000-000000000000" end
-- Camera code multiplies CFrames every frame (`camera.CFrame * CFrame.new(0,1,0)`),
-- so the mock needs the operator, not just the constructor.
local CF = {}
CF.__index = CF
local function cf(pos)
    local obj = setmetatable({
        Position = pos or v3(0, 0, 0),
        LookVector = v3(0, 0, -1),
        RightVector = v3(1, 0, 0),
        UpVector = v3(0, 1, 0),
    }, CF)
    -- Roblox CFrames carry a Rotation property and movement code multiplies by it
    -- (`CFrame.new(p) * root.CFrame.Rotation`). Without it the multiply indexes nil
    -- and the whole climb loop dies on the first step.
    obj.Rotation = obj
    return obj
end
local function isCF(b) return type(b) == "table" and getmetatable(b) == CF end
CF.__mul = function(a, b)
    if type(b) == "number" then return a end
    if isCF(b) then return cf(a.Position + b.Position) end
    if isVec3(b) then return a.Position + b end
    return a
end
CF.__add = function(a, b) if isVec3(b) then return cf(a.Position + b) end return a end
CF.__sub = function(a, b) if isVec3(b) then return cf(a.Position - b) end return a end
CF.__eq = function(a, b) return a.Position == b.Position end
CF.__tostring = function() return "CFrame" end
function CF.Inverse(a) return cf(v3(-a.Position.X, -a.Position.Y, -a.Position.Z)) end
function CF.Lerp(a, b) return b end
function CF.ToObjectSpace(a, b) return b end
function CF.ToWorldSpace(a, b) return b end
function CF.PointToObjectSpace(a, b) return b end
function CF.PointToWorldSpace(a, b) return b end
function CF.ToEulerAnglesXYZ() return 0, 0, 0 end
function CF.ToOrientation() return 0, 0, 0 end
function CF.ToWorldUp() return v3(0, 1, 0) end
local function cframeNew(x, y, z)
    if isVec3(x) then return cf(x) end
    if isCF(x) then return cf(x.Position) end
    return cf(v3(x or 0, y or 0, z or 0))
end
CFrame = { new = cframeNew, identity = cf(), Angles = function() return cf() end,
           fromEulerAnglesXYZ = function() return cf() end, fromOrientation = function() return cf() end,
           fromMatrix = function() return cf() end, lookAt = function() return cf() end,
           fromAxisAngle = function() return cf() end }

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
    -- A drawing object never touches the world, so a property write on it is the
    -- only evidence a visual feature ran. Trace them instead of dropping them.
    return setmetatable({ Kind = kind, Remove = function() end, Visible = true }, {
        __index = function() return function() end end,
        __newindex = function(self, key, value)
            rawset(self, key, value)
            bump(TRACE.wrote, tostring(kind) .. "|" .. tostring(key))
        end,
    })
end }
setfflag = function() return true end
firesignal = function(signal, ...)
        if type(signal) ~= "table" then return end
        -- A local signal fire is game traffic the same way :FireServer is, so it
        -- has to land in TRACE or "the button ran" is all the proof we get.
        local first = select(1, ...)
        local key = tostring(rawget(signal, "SignalName") or "signal")
            .. "|" .. tostring(type(first) == "string" and first or type(first))
        bump(TRACE.fire, key)
        if type(signal.Fire) == "function" then signal.Fire(signal, ...) end
    end
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
        -- Only a real library source counts. A hub that probes the executor with
        -- loadstring("return Library")() would otherwise capture the harness stand-in,
        -- and the audit would drive mock widgets instead of the shipped ui.lua ones.
        if type(src) == "string" and #src > 1024 and src:find("return Library", 1, true) and type(fn) == "function" then
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
-- A hub that gates its build on the world (waiting for a character or a room) burns one
-- resume per wait; 600 was not enough once a layer added its own start-up gate.
for _ = 1, 3000 do
    if coroutine.status(MAIN) ~= "suspended" then break end
    local ok, err = coroutine.resume(MAIN)
    if not ok then
        table.insert(DRAIN_ERRORS, tostring(err))
        break
    end
end
for _, e in ipairs(DRAIN_ERRORS) do _PRINT("BUILD ERROR " .. e) end
_PRINT("LAST WAIT: " .. tostring(WAIT_TRACE))

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
    ws.CurrentCamera.CFrame = CFrame.new()
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
hum.Health = 100; hum.MaxHealth = 100
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
-- Game code reads character.Head / character.Humanoid by name.
char.Permissive = true
lp.Character = char
-- The key tool the Infinite Items guard inspects: UniversalKey marks it, ID is what
-- the user's filter list is matched against.
local keyTool = newInstance("Tool", "Candle")
keyTool.Permissive = true
keyTool:SetAttribute("UniversalKey", true)
keyTool:SetAttribute("ID", "candle")
table.insert(char._p.Children, keyTool); keyTool._p.Parent = char
-- Game code resolves the character with CharacterAdded:Wait() when .Character is
-- still nil; replay the spawn so that call gets the rig instead of nothing.
lp.CharacterAdded.Fire(lp.CharacterAdded, char)
table.insert(lp._p.Children, char)

local uis = get("UserInputService")
uis.IsKeyDown = function() return false end
uis.GetFocusedTextBox = function() return nil end
-- Dragging a floating button reads the cursor; without this the click handler
-- throws and the button looks dead.
uis.GetMouseLocation = function() return v2(0, 0) end
uis.GetMouseDelta = function() return v2(0, 0) end

-- Tower of Hell (place 1962086868). Its climb reads workspace.tower.sectionData,
-- .sections and .sectionCount and refuses to route unless the count matches the
-- number of sections and the topmost section is named "finish". Without the tower
-- the autofarm has nowhere to walk and looks inert.
do
    local tower = addChild(ws, newInstance("Model", "tower"))
    tower.Permissive = true
    local sectionData = addChild(tower, newInstance("Folder", "sectionData"))
    sectionData.Permissive = true
    local sections = addChild(tower, newInstance("Folder", "sections"))
    sections.Permissive = true
    local names = { "1", "2", "3", "finish" }
    for index, label in ipairs(names) do
        local section = addChild(sectionData, newInstance("Model", label))
        section.Permissive = true
        local center = addChild(section, newInstance("Part", "center"))
        center.Size = Vector3.new(12, 1, 12)
        center.CFrame = CFrame.new(0, index * 20, 0)
        center.CanCollide = true
        local marker = addChild(section, newInstance("IntValue", "i"))
        marker.Value = index
        local platform = addChild(sections, newInstance("Part", label))
        platform.Size = Vector3.new(12, 1, 12)
        platform.CFrame = CFrame.new(0, index * 20, 0)
        platform.CanCollide = true
    end
    local count = addChild(tower, newInstance("IntValue", "sectionCount"))
    count.Value = #names
    -- A tagged hazard, so "hazard protection" is proven by the CanTouch write
    -- rather than by the toggle flipping.
    local killBrick = addChild(ws, newInstance("Part", "KillBrick"))
    killBrick.CanTouch = true
    killBrick.Size = Vector3.new(6, 1, 6)
    killBrick.CFrame = CFrame.new(0, 30, 0)
    COLLECTION_SERVICE:AddTag(killBrick, "KillBrick")
end

local vu = get("VirtualUser")
vu.CaptureController = function() end
vu.ClickButton2 = function() end
vu.KeyPress = function() end
vu.Move = function() end
local cg = get("CoreGui")
table.insert(ws._p.Children, char)
-- Real players always have these; the payload compares attributes against
-- DisplayName/UserId, and a nil DisplayName makes every candidate model match
-- `attr == nil` and be rejected as "the local player".
lp.DisplayName = lp.Name
lp.UserId = 1
lp.AccountAge = 1000

-- Seed the slice of game state the payload actually reads. Without this every
-- feature that needs a target (revive, carry, emote, token farm) bails on a nil
-- check and looks dead, even though its code is fine.
local function mkPlayerModel(folder, name, tag, team, status)
    local m = newInstance("Model", name)
    m._p.ClassName = "Model"
    local root = mkPart("HumanoidRootPart")
    local h = newInstance("Humanoid", "Humanoid")
    h.Health = 100; h.MaxHealth = 100; h.WalkSpeed = 16; h.JumpPower = 50
    h.MoveDirection = Vector3.new(0, 0, 1)
    h.GetState = function() return Enum.HumanoidStateType.Running end
    h.ChangeState = function() end
    h.GetStateEnabled = function() return true end
    h.SetStateEnabled = function() end
    table.insert(m._p.Children, root); root._p.Parent = m
    table.insert(m._p.Children, h); h._p.Parent = m
    m.PrimaryPart = root
    m.SetAttribute(m, "Tag", tag)
    m.SetAttribute(m, "Team", team)
    m.SetAttribute(m, "Status", status)
    table.insert(folder._p.Children, m); m._p.Parent = folder
    return m
end
local wsPlayers = newInstance("Folder", "Players")
wsPlayers._p.ClassName = "Folder"
table.insert(ws._p.Children, wsPlayers); wsPlayers._p.Parent = ws
mkPlayerModel(wsPlayers, "Target1", "tgt1", "Survivors", "DOWNED")
mkPlayerModel(wsPlayers, "Target2", "tgt2", "Survivors", "ALIVE")

local gameFolder = newInstance("Folder", "Game")
gameFolder._p.ClassName = "Folder"
table.insert(ws._p.Children, gameFolder); gameFolder._p.Parent = ws
local gamePlayers = newInstance("Folder", "Players")
gamePlayers._p.ClassName = "Folder"
table.insert(gameFolder._p.Children, gamePlayers); gamePlayers._p.Parent = gameFolder
mkPlayerModel(gamePlayers, "NPC1", "npc1", "Killers", "ALIVE")
local mapFolder = newInstance("Folder", "Map")
mapFolder._p.ClassName = "Folder"
table.insert(gameFolder._p.Children, mapFolder); mapFolder._p.Parent = gameFolder
local mapParts = newInstance("Folder", "Parts")
mapParts._p.ClassName = "Folder"
table.insert(mapFolder._p.Children, mapParts); mapParts._p.Parent = mapFolder
local objectives = newInstance("Folder", "Objectives")
objectives._p.ClassName = "Folder"
table.insert(mapParts._p.Children, objectives); objectives._p.Parent = mapParts
local obj1 = mkPart("Objective1")
obj1.SetAttribute(obj1, "Tag", "objtag")
obj1.SetAttribute(obj1, "Completed", false)
table.insert(objectives._p.Children, obj1); obj1._p.Parent = objectives
local safeZones = newInstance("Folder", "SafeZones")
safeZones._p.ClassName = "Folder"
table.insert(mapFolder._p.Children, safeZones); safeZones._p.Parent = mapFolder
local rigs = newInstance("Folder", "Rigs")
rigs._p.ClassName = "Folder"
table.insert(ws._p.Children, rigs); rigs._p.Parent = ws
mkPlayerModel(rigs, "Rig1", "rig1", "Survivors", "ALIVE")


-- Real games hand the payload RemoteEvents, not auto-created folders: Vote and
-- Carry only fire when `IsA("RemoteEvent")` is true, so the remote tree has to be
-- seeded explicitly or those features look dead.
local function mkRemote(parent, name, class)
    local r = newInstance(class or "RemoteEvent", name)
    r._p.ClassName = class or "RemoteEvent"
    table.insert(parent._p.Children, r); r._p.Parent = parent
    return r
end
local rsEvents = newInstance("Folder", "Events")
rsEvents._p.ClassName = "Folder"
table.insert(rs._p.Children, rsEvents); rsEvents._p.Parent = rs
mkRemote(rsEvents, "Interact")
mkRemote(rsEvents, "CharacterTask")
mkRemote(rsEvents, "Vote")
mkRemote(rsEvents, "UpdateCharacterDataRegistry")
mkRemote(rsEvents, "SetPlayerMode")
local adminFolder = newInstance("Folder", "Admin")
adminFolder._p.ClassName = "Folder"
table.insert(rsEvents._p.Children, adminFolder); adminFolder._p.Parent = rsEvents
mkRemote(adminFolder, "Command")
local shared = newInstance("Folder", "Shared")
shared._p.ClassName = "Folder"
table.insert(rs._p.Children, shared); shared._p.Parent = rs
local userData = newInstance("Folder", "UserData")
userData._p.ClassName = "Folder"
table.insert(shared._p.Children, userData); userData._p.Parent = shared
local udEvents = newInstance("Folder", "Events")
udEvents._p.ClassName = "Folder"
table.insert(userData._p.Children, udEvents); udEvents._p.Parent = userData
local requests = newInstance("Folder", "Requests")
requests._p.ClassName = "Folder"
table.insert(udEvents._p.Children, requests); requests._p.Parent = udEvents
mkRemote(requests, "SetSetting")
mkRemote(requests, "Purchase")

-- A downed teammate: workspace.Players model with Downed=true, plus a Player
-- object so Players:GetPlayers() can find it. Carry and revive target both.
local downedModel = wsPlayers:FindFirstChild("Target1")
if downedModel then
    downedModel.SetAttribute(downedModel, "Downed", true)
    downedModel.PrimaryPart.Anchored = false
end
local teammate = newInstance("Player", "Target1")
teammate._p.ClassName = "Player"
teammate.DisplayName = "Target1"
teammate.UserId = 2
teammate.Character = downedModel
if downedModel then table.insert(downedModel._p.Children, teammate) end
players.GetPlayers = function() return { lp, teammate } end
-- Carrying a body in Evade welds it to you; that is the only honest way to tell a
-- successful pick-up from a server that silently ignored the request. The harness
-- states the weld so "already carrying" is a fact the script can check: auto carry
-- must fire "Carry" once for this body, never again, because the action is a toggle
-- and a second fire drops it.
if downedModel and downedModel.PrimaryPart and hrp then
    local carryWeld = newInstance("WeldConstraint", "CarryWeld")
    carryWeld._p.ClassName = "WeldConstraint"
    carryWeld.Part0 = hrp
    carryWeld.Part1 = downedModel.PrimaryPart
    table.insert(hrp._p.Children, carryWeld)
    carryWeld._p.Parent = hrp
end

-- Vote popup: the vote features refuse to fire while the popup is hidden.
local pg = newInstance("Folder", "PlayerGui")
pg._p.ClassName = "PlayerGui"
table.insert(lp._p.Children, pg); pg._p.Parent = lp
lp.PlayerGui = pg
local guiShared = newInstance("Folder", "Shared")
guiShared._p.ClassName = "Folder"
table.insert(pg._p.Children, guiShared); guiShared._p.Parent = pg
local popups = newInstance("Folder", "Popups")
popups._p.ClassName = "Folder"
table.insert(guiShared._p.Children, popups); popups._p.Parent = guiShared
local voteActive = newInstance("Frame", "VoteActive")
voteActive._p.ClassName = "Frame"
voteActive.Visible = true
table.insert(popups._p.Children, voteActive); voteActive._p.Parent = popups

TRACE.fire, TRACE.made, TRACE.wrote = {}, {}, {}
local errors = {}
-- Callbacks may yield (task.wait inside a toggle handler); run each in its own
-- coroutine and hand the survivors to the frame loop.
local function try(label, fn)
    local co = coroutine.create(fn)
    local ok, err = coroutine.resume(co)
    if not ok then table.insert(errors, label .. " -> " .. tostring(err) .. "\n" .. debug.traceback(co)) end
    if coroutine.status(co) == "suspended" then table.insert(PENDING, co) end
end

-- 1. drive every widget: its creation callback and every :OnChanged handler
local function valueFor(kind, spec)
    if kind == "Toggle" then return true end
    if kind == "Slider" then
        -- Driving a slider to its own Default moves nothing, so its OnChanged never
        -- fires and every feature behind a slider looks proven while never having run.
        -- Pick a value that differs from Default whenever the range allows it.
        local d = spec.Default
        local lo, hi = spec.Min, spec.Max
        if d == nil then return lo or 50 end
        if hi ~= nil and d < hi then return hi end
        if lo ~= nil and d > lo then return lo end
        return d
    end
    -- An empty Default means the widget starts blank, not that it is never typed into.
    -- Returning "" leaves every callback that guards `if text == "" then return end`
    -- unreachable, so the button behind it can never be proven.
    if kind == "Input" then
        local d = spec.Default
        if d == nil or d == "" then return "1" end
        return d
    end
    if kind == "Dropdown" then return (spec.Values and spec.Values[1]) or "1" end
    if kind == "Keybind" then return true end
    if kind == "ColorPicker" then return { R = 1, G = 1, B = 1 } end
    return nil
end
local TRACE_WIDGETS = rawget(_G, "SMOKE_TRACE")
local fired = 0
-- Real-library mode: drive every option the shipped ui.lua registered. The mock
-- recorder only sees widgets built through the stand-in library.
local LIB = CAPTURED.Library
if LIB and type(LIB.Options) == "table" then
    local total, driven = 0, 0
    -- Registration order, not a sorted or hashed one: hubs wire their auto-farms so
    -- that a later widget assumes the earlier one ran (profile fetch, config load).
    -- Sorting the ids drove them out of that order and surfaced mock gaps as crashes.
    local ids = {}
    -- Destructive options are driven last. The knob farm kills the character, and every
    -- Humanoid-driven handler that runs afterwards sees a dead character and does
    -- nothing -- so driving it mid-pass made the whole sweep depend on pairs() order,
    -- which is not stable between runs. Deferring it keeps the pass deterministic.
    local deferred = {}
    for id in pairs(LIB.Options) do
        if id == "ab_KnobFarm" then table.insert(deferred, id) else table.insert(ids, id) end
    end
    for _, id in ipairs(deferred) do table.insert(ids, id) end
    for _, id in ipairs(ids) do
        local opt = LIB.Options[id]
        total += 1
        if type(opt) == "table" and type(opt.SetValue) ~= "function" then
            _PRINT("option without SetValue: " .. tostring(id) .. " (" .. type(opt) .. ")")
        end
        if type(opt) == "table" and type(opt.SetValue) == "function" then
            local value
            local kind = type(opt.Value)
            if type(opt.Values) == "table" and #opt.Values > 0 then
                -- A Multi dropdown turns SetValue into a set; handing it one string
                -- yields an empty set, so the handler would never see a selection.
                value = opt.Multi and opt.Values or opt.Values[1]
            elseif kind == "boolean" then
                value = true
            elseif kind == "number" then
                value = opt.Default or opt.Value
            elseif kind == "string" then
                value = (type(opt.Default) == "string" and opt.Default ~= "") and opt.Default or "1"
            end
            -- The library ignores SetValue when the value is unchanged, so a widget
            -- already sitting at its target would never run its handler and the run
            -- would report "driven" for something inert. Nudge it off first.
            if kind == "boolean" and value == true and opt.Value == true then
                try("option " .. tostring(id) .. " pre-off", function() opt:SetValue(false) end)
            elseif kind == "number" and value == opt.Value then
                local max = tonumber(opt.Max)
                local nudged = max and math.min(max, value + 1) or (value + 1)
                if nudged == value then nudged = value - 1 end
                try("option " .. tostring(id) .. " pre-nudge", function() opt:SetValue(nudged) end)
            elseif type(opt.Values) == "table" and #opt.Values > 1 and opt.Value == value then
                value = opt.Values[2]
            end
            local before = #errors
            local effectsBefore = EFFECTS
            local fireBefore, madeBefore = #TRACE.fire, #TRACE.made
            if value ~= nil then
                try("option " .. tostring(id), function() opt:SetValue(value) end)
                if #errors == before then driven += 1 end
            end
            local effectCount = EFFECTS - effectsBefore
            -- One line per option so the audit can tell "built but inert" (no
            -- callback, nothing wired) from "built and live".
            local fired, made = {}, {}
            for i = fireBefore + 1, math.min(#TRACE.fire, fireBefore + 8) do table.insert(fired, TRACE.fire[i]) end
            for i = madeBefore + 1, math.min(#TRACE.made, madeBefore + 8) do table.insert(made, TRACE.made[i]) end
            _PRINT(string.format("OPT|%s|%s|%s|%s|%s|%d|%s|%s",
                tostring(id), tostring(opt.Type or "?"), type(opt.Value),
                tostring(type(opt.Callback) == "function" or #(opt.Changed or {}) > 0),
                tostring(value ~= nil and #errors == before), effectCount,
                table.concat(fired, ","), table.concat(made, ",")))
        end
    end
    _PRINT("library: real ui.lua buttons=" .. type(LIB.Buttons) .. " tabs=" .. type(LIB.Tabs))
    _PRINT("options: " .. tostring(total) .. " driven: " .. tostring(driven))

    -- Second pass on the entity filter: the driver selects everything, and the case
    -- that matters is the filter actually dropping something already in the world.
    local filterOpt = LIB.Options.EntityESPFilter
    if type(filterOpt) == "table" and type(filterOpt.SetValue) == "function"
        and type(filterOpt.Values) == "table" and #filterOpt.Values > 0 then
        try("entity filter narrowed", function() filterOpt:SetValue({ filterOpt.Values[1] }) end)
    end

    -- Auto interact has to reach the executor's prompt primitive. The payload used to
    -- force ExecutorSupport["fireproximityprompt"] = false, so every beat took the
    -- distance-gated fallback and the feature needed a manual press. Drive the switch and
    -- let the heartbeat pump below run it; the proof reads the recorded fire.
    -- Widget ids are part of the contract. After the hub was reduced to one feature
    -- source these three lookups pointed at host widgets that no longer exist, so every
    -- drive below silently did nothing while the sweep still reported PASS. A missing
    -- id now prints DRIVE-MISS and turns the proof table red.
    local DRIVE_MISS = 0
    local function widget(kind, id)
        local group = LIB[kind]
        local found = type(group) == "table" and group[id] or nil
        if type(found) ~= "table" or type(found.SetValue) ~= "function" then
            DRIVE_MISS += 1
            _PRINT("DRIVE-MISS|" .. tostring(kind) .. "|" .. tostring(id))
            return nil
        end
        return found
    end

    local autoInteract = widget("Toggles", "ab_AutoInteractToggle")
    if autoInteract then
        try("auto interact on", function() autoInteract:SetValue(true) end)
    end

    -- Instant prompts is what makes every prompt reachable in one beat; drive it with
    -- the reach multiplier off so the range gate is exercised, not bypassed.
    local instantPrompts = widget("Toggles", "ab_InstantPrompts")
    if instantPrompts then
        try("instant prompts on", function() instantPrompts:SetValue(true) end)
    end
    local ignoreList = widget("Options", "ab_AutoInteractIgnoreList")
    if ignoreList then
        try("auto interact ignore list", function() ignoreList:SetValue({}) end)
    end
    _PRINT("drive targets: " .. tostring(3 - DRIVE_MISS) .. "/3")
    -- The layer drains one queued workspace object per RenderStepped frame, so the
    -- frame budget has to clear the whole tree before any seeded prompt is registered.
    _PRINT("ws descendants: " .. tostring(#ws:GetDescendants()))

    -- A prompt seeded before the payload loads never reaches PromptTable.GamePrompts --
    -- workspace.ChildAdded is the only entry point -- so the auto interact scan had
    -- nothing to fire here no matter what the switch said. Add one while the payload is
    -- live and park its part on the character.
    try("late unlock prompt", function()
        -- Attach to the real Lock, never to DoorFake: the payload drops prompts whose
        -- grandparent is DoorFake/FakeDoor, so a fake-door seed proves nothing about
        -- auto interact -- it only proves the guard works.
        local lockBody = newInstance("Part", "LockBody")
        lockBody.Position = Vector3.new(0, 0, 0)
        addChild(lockModel, lockBody)
        local latePrompt = newInstance("ProximityPrompt", "UnlockPrompt")
        latePrompt.MaxActivationDistance = 99999
        latePrompt.HoldDuration = 0
        latePrompt.Enabled = true
        addChild(lockBody, latePrompt)
        -- The registration handler hangs off workspace.ChildAdded, and a prompt nested
        -- under a part never raises it; fire the signal the way the game would when the
        -- room streams the prompt in.
        ws.ChildAdded:Fire(latePrompt)
    end)

    if type(LIB.Buttons) == "table" then
        local pressed = 0
        -- Unload and Rejoin tear the library down or teleport away, so pressing them
        -- mid-run proves nothing and kills every feature check that follows.
        local skip = { ["Unload"] = true, ["Rejoin"] = true, ["Unload UI"] = true, ["Rejoin Server"] = true }
        local skipped = 0
        for _, button in ipairs(LIB.Buttons) do
            local info = button.Info or {}
            local label = tostring(info.Text or info.Title or "")
            if type(button.Click) == "function" and not skip[label] then
                try("button " .. label, function() button:Click() end)
                pressed += 1
            elseif skip[label] then
                skipped += 1
            end
        end
        _PRINT("buttons pressed: " .. tostring(pressed) .. " / " .. tostring(#LIB.Buttons) .. " (skipped destructive: " .. tostring(skipped) .. ")")
        for _, button in ipairs(LIB.Buttons) do
            local info = button.Info or {}
            _PRINT(string.format("BTN|%s|%s", tostring(info.Text or info.Title or "?"),
                tostring(type(info.Func or info.Callback) == "function")))
        end
    end

    -- Knob farm needs two things from the harness before its cycle can run: the switch,
    -- and the Start button (the switch alone only prints a hint). Both are driven here so
    -- the proof reads a real Statistics/PlayAgain fire instead of an untested code path.
    local knobFarm = widget("Toggles", "ab_KnobFarm")
    if knobFarm then
        try("knob farm on", function() knobFarm:SetValue(true) end)
    end
    do
        local started = 0
        for _, button in ipairs(LIB.Buttons or {}) do
            local info = button.Info or {}
            if (info.Text or info.Title) == "Start Knob Farm" and type(button.Click) == "function" then
                try("start knob farm", function() button:Click() end)
                started += 1
            end
        end
        _PRINT("knob farm start button: " .. tostring(started))
    end
    local wtabs = (type(LIB.Tabs) == "table" and LIB.Tabs)
        or (LIB.Window and type(LIB.Window.Tabs) == "table" and LIB.Window.Tabs)
    if wtabs then
        _PRINT("tabs: " .. tostring(#wtabs))
        -- Tab order is part of the product: it must match the upstream menu.
        for i, tab in ipairs(wtabs) do
            local t = rawget(tab, "_p") or tab
            _PRINT(string.format("TAB|%d|%s|%s", i, tostring(t.Name), tostring(t.Icon or "")))
        end
    end
end

for _, w in ipairs(WIDGETS) do
    if TRACE_WIDGETS then _PRINT("drive " .. tostring(w.Kind) .. ":" .. tostring(w.Id)) end
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
        if svc[sig] and type(svc[sig].handlers) == "table" and #svc[sig].handlers > 0 then table.insert(signals, { name = name .. "." .. sig, sig = svc[sig] }) end
    end
end
local SRC_LINES = {}
for l in (SCRIPT_SOURCE):gmatch("[^\n]*") do table.insert(SRC_LINES, l) end
local frames = 0
for name, svc in pairs(services) do
    for _, sig in ipairs({ "Heartbeat", "RenderStepped", "Stepped", "PreSimulation", "PostSimulation" }) do
        local s = svc[sig]
        if s and type(s.handlers) == "table" and #s.handlers > 0 then
            local lines = {}
            for _, fn in ipairs(s.handlers) do
                local ok, l = pcall(function() return debug.info(fn, "l") end)
                local txt = "?"
                if ok and SRC_LINES and l and SRC_LINES[l] then txt = l .. ":" .. (SRC_LINES[l]:gsub("%s+", " "):sub(1, 40)) end
                table.insert(lines, txt)
            end
            _PRINT(string.format("SIG|%s.%s|%d|%s", name, sig, #s.handlers, table.concat(lines, ",")))
        end
    end
end
for round = 1, __FRAMES__ do
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
            -- Own thread per handler, like Roblox. A frame handler that calls
            -- task.wait() (a queue drain, a tween) cannot yield out of a plain
            -- pcall: Luau aborts the run with "thread yielded unexpectedly" and
            -- every later phase, the audit included, never executes.
            local co = coroutine.create(fn)
            local ok, err = coroutine.resume(co, 1 / 60)
            if coroutine.status(co) == "suspended" then table.insert(PENDING, co) end
            frames += 1
            if not ok then table.insert(errors, s.name .. " frame -> " .. tostring(err)) end
        end
    end
end

-- 3. click the floating buttons the payload built. Several features (auto carry,
-- lag switch, superbounce) live behind these TextButtons instead of a toggle, so
-- an option-only driver never reaches them.
local function walk(node, out, depth)
    if depth > 8 then return end
    for _, child in ipairs(node:GetChildren()) do
        local cls = child._p and child._p.ClassName
        if cls == "TextButton" then table.insert(out, child) end
        walk(child, out, depth + 1)
    end
end
local buttons = {}
walk(cg, buttons, 0)
if lp.PlayerGui then walk(lp.PlayerGui, buttons, 0) end
_PRINT("floating buttons found: " .. tostring(#buttons))
-- GuiButtons signal a click through Activated; MouseButton1Click is the older
-- path. Fire both, the way a real tap does.
local clicked = 0
for _, btn in ipairs(buttons) do
    local total = 0
    for _, key in ipairs({ "Activated", "MouseButton1Click" }) do
        local sig = btn._p[key]
        local handlers = sig and sig.handlers or {}
        total += #handlers
        for _, fn in ipairs(handlers) do
            -- Real clicks hand the handler an InputObject; the library's drag code
            -- reads input.Position.X.
            try("fb:" .. tostring(btn._p.Name), function()
                return fn({
                    Position = Vector3.new(0, 0, 0),
                    UserInputType = Enum.UserInputType.MouseButton1,
                    UserInputState = Enum.UserInputState.Begin,
                })
            end)
        end
    end
    if total > 0 then
        clicked += 1
        _PRINT(string.format("FBTN|%s|%s|%s|%d", tostring(btn._p.Name), tostring(btn._p.Text), tostring(btn._p.Parent and btn._p.Parent._p and btn._p.Parent._p.Name), total))
    end
end
_PRINT("floating buttons clicked: " .. tostring(clicked))
_PRINT("fires after click: " .. tostring(#TRACE.fire))
for round = 1, 30 do
    for i = #PENDING, 1, -1 do
        local co = PENDING[i]
        if coroutine.status(co) == "dead" then table.remove(PENDING, i)
        else
            local ok, err = coroutine.resume(co)
            if not ok then table.insert(errors, "task2 -> " .. tostring(err)); table.remove(PENDING, i) end
        end
    end
    for _, s in ipairs(signals) do
        for _, fn in ipairs(s.sig.handlers) do
            -- Own thread per handler, like Roblox. A frame handler that calls
            -- task.wait() (a queue drain, a tween) cannot yield out of a plain
            -- pcall: Luau aborts the run with "thread yielded unexpectedly" and
            -- every later phase, the audit included, never executes.
            local co = coroutine.create(fn)
            local ok, err = coroutine.resume(co, 1 / 60)
            if coroutine.status(co) == "suspended" then table.insert(PENDING, co) end
            frames += 1
            if not ok then table.insert(errors, s.name .. " frame2 -> " .. tostring(err)) end
        end
    end
end

_PRINT("frame handlers run: " .. tostring(#PENDING))
do
    local seen, order = {}, {}
    for _, k in ipairs(TRACE.fire) do
        if not seen[k] then seen[k] = 0 table.insert(order, k) end
        seen[k] += 1
    end
    table.sort(order)
    for _, k in ipairs(order) do _PRINT(string.format("FIRE|%s|%d", k, seen[k])) end
    _PRINT("trace fire total: " .. tostring(#TRACE.fire))
    local wseen, worder = {}, {}
    for _, k in ipairs(TRACE.wrote) do
        if not wseen[k] then wseen[k] = 0 table.insert(worder, k) end
        wseen[k] += 1
    end
    table.sort(worder, function(a, b)
        if wseen[a] ~= wseen[b] then return wseen[a] > wseen[b] end
        return a < b
    end)
    -- Every distinct key, not a top-N window: the proofs are parsed out of this
    -- list, so a window silently hides the evidence for whichever feature ranks
    -- below it and the run reports a live feature as dead.
    for _, key in ipairs(worder) do
        _PRINT(string.format("WROTE|%s|%d", key, wseen[key]))
    end
    local mseen, morder = {}, {}
    for _, k in ipairs(TRACE.made) do
        if not mseen[k] then mseen[k] = 0 table.insert(morder, k) end
        mseen[k] += 1
    end
    table.sort(morder, function(a, b)
        if mseen[a] ~= mseen[b] then return mseen[a] > mseen[b] end
        return a < b
    end)
    for _, key in ipairs(morder) do
        _PRINT(string.format("MADE|%s|%d", key, mseen[key]))
    end
end
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



# One claim per feature, tied to evidence the harness actually observed. "fire" is
# a remote call with its first argument, "write" is a property write on a game
# object (UI churn is filtered out in the harness), "made" is an Instance.new.
# A feature that merely runs without error does not satisfy any of these.
FEATURE_PROOFS = {
    "token farm fires Revive": ("fire", "Interact|Revive", 1),
    # Exactly one: "Carry" is a toggle, so a second fire for the same body drops it.
    # The old loop fired every 0.5s and the body came back down on its own.
    "auto carry fires Carry once per body": ("fire", "Interact|Carry", 1, 1),
    "emote fires CharacterTask": ("fire", "CharacterTask|Emote", 1),
    # Auto buy: the dropdown used to default to a hard-coded "Cola" that no registry
    # entry can match, so BuyItem returned before touching the remote. The harness
    # pumps the heartbeat, so this fires once per simulated interval -- the ceiling
    # catches a per-frame runaway, not the exact count.
    "auto buy fires Purchase": ("fire", "Purchase|number", 1, 20),
    "vignette off fires SetSetting": ("fire", "SetSetting|NextbotVignette", 1),
    "speed writes Humanoid.WalkSpeed": ("write", "Humanoid|WalkSpeed", 1),
    "jump power writes Humanoid.JumpPower": ("write", "Humanoid|JumpPower", 1),
    "gravity writes Workspace.Gravity": ("write", "Workspace|Gravity", 1),
    "ESP builds a Highlight": ("made", "Highlight", 1),
    "player ESP paints FillColor": ("write", "PlayerHighlight_D|FillColor", 1),
    "noclip writes CanCollide": ("write", "HumanoidRootPart|CanCollide", 1),
}


# DOORS ships its own set: the same rule applies, one evidence row per feature.
DOORS_PROOFS = {
    # Doors ships one feature source: the Abysall layer. Every proof below names the
    # toggle in that layer which produces the write, so a regression in the layer
    # fails the sweep instead of hiding behind a generic trace hit.
    "prompt clip widens the prompt it can reach": ("write", "UnlockPrompt|MaxActivationDistance", 1),
    "prompt clip drops the line of sight check": ("write", "UnlockPrompt|RequiresLineOfSight", 1),
    "prompt clip re-enables a disabled prompt": ("write", "UnlockPrompt|Enabled", 1),
    "prompt fixer records the original distance": ("write", "UnlockPrompt|SetAttribute|MaxActivationDistance_Old=10", 1),
    # InstantPrompts writes HoldDuration = 0 on the prompt it is standing on; the
    # restore path puts the old value back, so the write has to be observable.
    "instant prompts zero the hold duration": ("write", "UnlockPrompt|HoldDuration", 1),
    "instant prompt records the original hold": ("write", "UnlockPrompt|SetAttribute|HoldDuration_Old=0.4", 1),
    "speed boost raises Humanoid.WalkSpeed": ("write", "Humanoid|WalkSpeed", 1),
    "crouch spoof rewrites Humanoid.HipHeight": ("write", "Humanoid|HipHeight", 1),
    # The layer's own ESP library builds Highlight instances; the shared Reicht ESP
    # path is gone, so this is the only thing that can make one.
    # The bridge no longer builds its own Highlight: it hands the object to the shared
    # Reicht renderer, so the write lands on `ReichtESP`, not on a private
    # `ReichtAbysallESP`. Keying the row on the old name made the check pass on a
    # renderer that had already been replaced.
    "abysall ESP builds a highlight": ("made", "Highlight", 1),
    "abysall ESP fills the highlight": ("write", "ReichtESP|FillColor", 1),
    # Auto interact has to reach the executor's prompt primitive. Both rows were red
    # before: the layer threw on `Prompt.parent` for every prompt it touched, so the
    # trace recorded no fire at all while the attribute-write rows above stayed green.
    # A green here means the whole chain ran -- heartbeat, distance gate, TriggerPrompt,
    # drain loop, prompt fire -- not just that a prompt was seeded.
    "auto interact fires the door lock prompt": ("fire", ["UnlockPrompt|prompt", "UnlockPrompt|InputHoldBegin"], 1),
    "auto interact fires the room prompt": ("fire", ["RoomPrompt|prompt", "RoomPrompt|InputHoldBegin"], 1),
    # Knob farm: the claim and the re-queue are the two remotes the game rewards. The old
    # body fired neither, so a green here is the difference between "the toggle lights up"
    # and "the cycle actually pays out".
    "knob farm claims the room reward": ("fire", "Statistics|nil", 1),
    "knob farm asks for the next run": ("fire", "PlayAgain|nil", 1),
}


# +1 Tongue Escape ships its own set: same rule, one evidence row per feature.
TONGUE_PROOFS = {
    "auto tongue fires AddTongue": ("fire", "AddTongue|nil", 1),
    "auto rebirth invokes RequestRebirth": ("fire", "RequestRebirth|invoke", 1),
    "auto wins marks the highest value pad": ("write", "Tester|SetAttribute|ReichtWinTarget=100", 1),
    "auto wins moves the character onto the pad": ("write", "Tester|PivotTo", 1),
    # The remote's first argument is a verb string, and the trace keys on string
    # values, so this asserts the buy branch specifically -- not just "fired".
    "auto trails buys a trail with wins": ("fire", "TrailAction|BuyWins", 1),
}


# Violence District: the merge layer added by build.py, one row per feature.
VD_PROOFS = {
    "fly spawns a BodyVelocity": ("made", "BodyVelocity", 1),
    "field of view writes Camera": ("write", "Camera|FieldOfView", 1),
    "jump power writes Humanoid": ("write", "Humanoid|JumpPower", 1),
    "fps boost marks Lighting": ("write", "Lighting|SetAttribute|ReichtFpsBoost=true", 1),
    "free cam detaches the camera": ("write", "Camera|CameraType", 1),
}


# Games whose features are pure remote traffic: the proof is that the right remote
# carried the right verb. No geometry needed, so these are cheap to keep honest.
LOOT_PROOFS = {
    "auto claim sends the daily tick": ("fire", "TryClaimDailyTicRE|nil", 1),
    "auto quest claims the quest remote": ("fire", "TryClaimQuestRE|number", 1),
    "auto upgrade claims the upgrade remote": ("fire", "TryClaimUPDRewardRE|number", 1),
    "sell all fires the sell remote": ("fire", "TrySellAllRE|nil", 1),
    "rebirth fires the rebirth remote": ("fire", "TryRebirthRE|nil", 1),
    "offline reward is claimed": ("fire", "TryClaimOfflineRewardRE|nil", 1),
}

ANT_PROOFS = {
    "gear shop request reaches the server": ("fire", "RemoteEvent|GearShopRequest", 1),
    "ecs command reaches the server": ("fire", "RemoteEvent|ECS_COMMAND", 1),
}

STONE_PROOFS = {
    "code redemption carries the verb": ("fire", "Request|RedeemCode", 1),
}

PYRAMID_PROOFS = {
    "activity remote is fired": ("fire", "Activity|nil", 1),
}

AIRDROP_PROOFS = {
    "main remote receives a payload": ("fire", "Main|table", 1),
}


# Ride A Pet resolves all 33 of its remotes through GameLib.Remote, so these rows only
# pass once Remotes.Game is seeded -- a bare remote name would prove the seed, not the
# feature. Each pattern carries the argument shape the call site actually sends.
PET_PROOFS = {
    "offline reward claim reaches the server": ("fire", "OfflineEarnings|nil", 1),
    "plot egg request carries a boolean": ("fire", "RequestPlotEggs|boolean", 1),
    "pet view setting carries its verb": ("fire", "UpdateSetting|ViewOtherPets", 1),
}


# Four games whose features act on the game's own objects rather than on a remote.
# A WROTE/MADE row is still a real assertion: it says the feature reached the object
# it names. Where a remote does fire, the row carries the argument shape too.
MM2_PROOFS = {
    "fly drives a BodyVelocity": ("made", "BodyVelocity", 1),
    "kill platform-stands the target humanoid": ("write", "Humanoid|PlatformStand", 1),
    "jump power reaches the humanoid": ("write", "Humanoid|JumpPower", 1),
}
DICE_PROOFS = {
    "fly drives a BodyVelocity": ("made", "BodyVelocity", 1),
}
DE_PROOFS = {
    "vehicle despawn reaches the server": ("fire", "VehicleEvent|Despawn", 1),
}
# These four have no remote traffic the harness can reach -- their call sites hang off
# server-owned geometry (plots, ore blocks, map areas) -- but their local features do
# land on real objects. A row here asserts the write, not the intent.
# Tower of Hell has no remotes: its features move the character and touch tagged
# hazards. Each row asserts the write the feature claims to make, so a toggle that
# only flips its own flag fails here.
TOWER_PROOFS = {
    "hover builds a body velocity": ("made", "BodyVelocity", 1),
    "climb writes the root CFrame": ("write", "HumanoidRootPart|CFrame", 2),
    "hazard protection disables touch on the tagged KillBrick": ("write", "KillBrick|CanTouch", 1),
    "noclip clears collision on the character": ("write", "Head|CanCollide", 1),
    "climb speed reaches the humanoid": ("write", "Humanoid|WalkSpeed", 1),
}

BLOX_PROOFS = {
    "esp draws a tracer circle": ("write", "Circle|Radius", 1),
    "fps boost writes the lighting": ("write", "Lighting|ClockTime", 1),
}
SNIPER_PROOFS = {
    "esp draws a tracer circle": ("write", "Circle|Radius", 1),
}
TNT_PROOFS = {
    "walk speed reaches the humanoid": ("write", "Humanoid|WalkSpeed", 1),
}
SEA_PROOFS = {
    "noclip clears the head collision": ("write", "Head|CanCollide", 1),
    "fps boost writes the lighting": ("write", "Lighting|ClockTime", 1),
}

EGG_PROOFS = {
    "offline reward claim reaches the server": ("fire", "OfflineRewardRemote|Claim", 1),
    "index claim-all reaches the server": ("fire", "IndexRemote|ClaimAll", 1),
}


def check_proofs(out: str, table: dict | None = None) -> tuple[int, int]:
    """Report per-feature evidence. Returns (passed, failed)."""
    table = FEATURE_PROOFS if table is None else table
    seen = {"fire": {}, "write": {}, "made": {}, "opt": {}}
    prefixes = {"fire": "FIRE|", "write": "WROTE|", "made": "MADE|"}
    for line in out.splitlines():
        if line.startswith("OPT|"):
            # OPT|<id>|<type>|<valueType>|<wired>|<driven>|<effects>|<fired>|<made>
            parts = line.split("|")
            if len(parts) >= 9:
                for made_class in parts[8].split(","):
                    if made_class:
                        key = parts[1] + "|" + made_class
                        seen["opt"][key] = seen["opt"].get(key, 0) + 1
        for kind, prefix in prefixes.items():
            if line.startswith(prefix):
                parts = line[len(prefix):].rsplit("|", 1)
                if len(parts) == 2 and parts[1].isdigit():
                    seen[kind][parts[0]] = int(parts[1])
    passed = failed = 0
    for label, spec in table.items():
        kind, key, need = spec[0], spec[1], spec[2]
        # A fourth element caps the count. Some bugs are too many fires rather than
        # too few: a toggle-style remote fired twice undoes itself, and "at least
        # one" would call that healthy.
        most = spec[3] if len(spec) > 3 else None
        # A typo in the trace-kind name used to raise KeyError and kill the whole
        # proof run after the smoke itself had passed -- the game looked proven
        # because no FAIL line was printed. Report it as a failing row instead.
        bucket = seen.get(kind)
        if bucket is None:
            passed += 0
            failed += 1
            print(f"PROOF|FAIL|{label}|unknown trace kind {kind!r}")
            continue
        # The key may be a list of acceptable routes. A prompt counts as fired whether
        # the executor global carried it (`Name|prompt`) or the payload fell back to the
        # engine's own InputHoldBegin path (`Name|InputHoldBegin`). Pinning the proof to
        # one route reported a live feature as dead whenever the other route ran.
        keys = key if isinstance(key, list) else [key]
        got = sum(bucket.get(k, 0) for k in keys)
        ok = got >= need and (most is None or got <= most)
        passed += ok
        failed += not ok
        bound = f" max {most}" if most is not None else ""
        print(f"PROOF|{'PASS' if ok else 'FAIL'}|{label}|{got}/{need}{bound}")
    return passed, failed


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
    if not guard:
        # Guards written against named constants (`local UNIVERSE_ID = 123`) carry
        # the id in the declaration instead of the comparison.
        guard = re.search(r"local\s+UNIVERSE_ID\s*=\s*(\d+)", src)
    game_id = guard.group(1) if guard else "3647333358"
    script = HARNESS.replace("SCRIPT_SOURCE", "[" + "=" * level + "[" + src + "]" + "=" * level + "]")
    script = script.replace("GAME_ID", game_id)
    # Every module path this script looks up by name. Dotted strings cover
    # GameLib.Find-style lookups; the Needs blocks list bare names that live
    # under the Knit Services/Controllers/Modules roots.
    paths = set(re.findall(r'(?:Find|FindFirstChild|WaitForChild)\(\s*"([A-Za-z0-9_][A-Za-z0-9_.]*)"', src))
    paths.update(re.findall(r'"([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+)"', src))
    for block in re.findall(r"Needs\s*=\s*\{(.*?)\n\}", src, re.S):
        for bare in re.findall(r'"([A-Za-z0-9_]+)"', block):
            for root in ("Services", "Controllers", "Modules"):
                paths.add(root + "." + bare)
    paths = sorted(p for p in paths if not p.startswith("game.") and "http" not in p)
    lua_paths = "{" + ", ".join('"%s"' % p for p in paths) + "}"
    script = script.replace("__RS_PATHS__", lua_paths)
    # Remote pairs: Reicht.Util.Remote("Profile", "GetTotalDataRF") and friends.
    pairs = sorted(set(re.findall(
        r'Remote\(\s*"([A-Za-z0-9_]+)"\s*,\s*"([A-Za-z0-9_]+)"', src)))
    lua_pairs = "{" + ", ".join('{"%s", "%s"}' % (f, n) for f, n in pairs) + "}"
    script = script.replace("__REMOTE_PAIRS__", lua_pairs)
    script = script.replace("__STRICT_WFC__", "true" if os.environ.get("REICHT_STRICT_WFC") == "1" else "false")
    script = script.replace("__NO_FPP__", "true" if os.environ.get("REICHT_NO_FPP") == "1" else "false")
    script = script.replace("__NO_MAINUI__", "true" if os.environ.get("REICHT_NO_MAINUI") == "1" else "false")
    # Frame budget. A hub that drains a queue one object per frame needs more frames
    # than the default before its later handlers are reachable at all.
    script = script.replace("__FRAMES__", os.environ.get("REICHT_FRAMES", "60"))
    miss = [n.strip() for n in os.environ.get("REICHT_WFC_MISS", "").split(",") if n.strip()]
    script = script.replace("__WFC_MISS__", "{" + ", ".join('["%s"] = true' % n for n in miss) + "}")
    script = script.replace("__HTTP_BLOCK__", '"%s"' % os.environ.get("REICHT_UI_BLOCK", "").replace('"', ''))
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

    # The proof table describes Evade's features; other games still need their own
    # mock before any of these claims can be made about them.
    proofs_passed = proofs_failed = 0
    proofs = {"Evade": FEATURE_PROOFS, "Doors": DOORS_PROOFS,
              "Tongue Escape": TONGUE_PROOFS,
              "Violence District": VD_PROOFS,
              "Loot To Forge": LOOT_PROOFS,
              "Build An Ant Empire": ANT_PROOFS,
              "Stone Skipping": STONE_PROOFS,
              "Build the Pyramid": PYRAMID_PROOFS,
              "AirDrop Arena": AIRDROP_PROOFS,
              "Ride A Pet": PET_PROOFS,
              "Murder Mystery 2": MM2_PROOFS,
              "Anime Dice": DICE_PROOFS,
              "Driving Empire": DE_PROOFS,
              "Break and Steal an Egg": EGG_PROOFS,
              "BloxStrike": BLOX_PROOFS,
              "Sniper Arena": SNIPER_PROOFS,
              "TNT Mining": TNT_PROOFS,
              "Open Sea For Animals": SEA_PROOFS,
              "Tower of Hell": TOWER_PROOFS}.get(target.stem)
    if proofs and "trace fire total" in out:
        proofs_passed, proofs_failed = check_proofs(out, proofs)
    has_options = "options: " in out and "driven: 0" not in out
    has_widgets = "widgets: 0" not in out and "widgets wired: 0 / 0" not in out
    bad = (("RUNTIME ERROR" in out) or ("errors: 0" not in out) or not (has_options or has_widgets)
           or proofs_failed > 0)
    print("SMOKE " + ("FAIL " + str(target) if bad else "PASS " + str(target)))
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
